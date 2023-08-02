global with sharing class gFRS_Ltng_Internal_User_Activation_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query;
    global set<Id> reqIds;
	global Database.Querylocator start(Database.BatchableContext BC){     

        system.debug('@@ in batch');
        reqIds = new set<Id>();
    	query = 'SELECT Id, Name, Record_Type_Name__c, Status__c, OwnerId, Legal_Approver__c, Legal_Approver__r.isactive, Business_Approver__c, Business_Approver__r.isactive, Finance_Approver__c, Finance_Approver__r.isactive, Finance_Manager__c, Finance_Manager__r.isactive FROM gFRS_Ltng_Application__c WHERE Record_Type_Name__c  in (\'Field Exhibits\',\'Corporate Memberships\',\'Commercial Sponsorship\',\'Non-Commercial Sponsorship\') AND Status__c in (\'Decision\') AND (( Legal_Approver__c != null) OR (Business_Approver__c != null) OR (Finance_Approver__c != null) OR (Finance_Manager__c != null ))';
    	system.debug('@@ Query : '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('@@ in execute');
        List<User> userList 	 = new List<User>();
        List<User> userListFinal = new List<User>();
        set<User> userSet = new set<User>();
        map<Id,Id> reqMap 	= new map<Id,Id>();
        //reqIds = new set<Id>();
        List<gFRS_Ltng_Application__Share> fundReqShareList = new List<gFRS_Ltng_Application__Share>();
        
        for(gFRS_Ltng_Application__c obj : (List<gFRS_Ltng_Application__c>)scope){
            
            if(obj.Legal_Approver__r.isactive == false && obj.Legal_Approver__c != null){
                if(obj.Legal_Approver__c != obj.OwnerId){
                    reqMap.put(obj.Legal_Approver__c, obj.Legal_Approver__c);
                    reqIds.add(obj.Id);
                } else {
                    reqMap.put(obj.Legal_Approver__c, obj.Legal_Approver__c);
                }
            } else if(obj.Legal_Approver__r.isactive == true && obj.Legal_Approver__c != null){
                if(obj.Legal_Approver__c != obj.OwnerId){
                    reqIds.add(obj.Id);
                }
            }
            
            if(obj.Business_Approver__r.isactive == false && obj.Business_Approver__c != null){
                if(obj.Business_Approver__c != obj.OwnerId){
                    reqMap.put(obj.Business_Approver__c, obj.Business_Approver__c);
                    reqIds.add(obj.Id);
                } else {
                    reqMap.put(obj.Business_Approver__c, obj.Business_Approver__c);
                }
            } else if(obj.Business_Approver__r.isactive == true && obj.Business_Approver__c != null){
                if(obj.Business_Approver__c != obj.OwnerId){
                    reqIds.add(obj.Id);
                }
            }
            
            if(obj.Finance_Approver__r.isactive == false && obj.Finance_Approver__c != null){
                if(obj.Finance_Approver__c != obj.OwnerId){
                    reqMap.put(obj.Finance_Approver__c, obj.Finance_Approver__c);
                    reqIds.add(obj.Id);
                } else {
                    reqMap.put(obj.Finance_Approver__c, obj.Finance_Approver__c);
                }
            } else if(obj.Finance_Approver__r.isactive == true && obj.Finance_Approver__c != null){
                if(obj.Finance_Approver__c != obj.OwnerId){
                    reqIds.add(obj.Id);
                }
            }
            
            if(obj.Finance_Manager__r.isactive == false && obj.Finance_Manager__c != null){
                if(obj.Finance_Manager__c != obj.OwnerId){
                    reqMap.put(obj.Finance_Manager__c, obj.Finance_Manager__c);
                    reqIds.add(obj.Id);
                } else {
                    reqMap.put(obj.Finance_Manager__c, obj.Finance_Manager__c);
                }
            } else if(obj.Finance_Manager__r.isactive == true && obj.Finance_Manager__c != null){
                if(obj.Finance_Manager__c != obj.OwnerId){
                    reqIds.add(obj.Id);
                }
            }
            
        }
		
        try{
            if(reqMap.size() > 0){
                userList = [SELECT Id, Name, isactive FROM USER WHERE Id =: reqMap.keySet()];
                map<Id,User> userMap = new map<Id,User>(userList);
                
                userList = new List<User>();
                
                for(gFRS_Ltng_Application__c obj : (List<gFRS_Ltng_Application__c>)scope){
                    
                    if(obj.Legal_Approver__r.isactive == false && obj.Legal_Approver__c != null){
                        User userRec = new User();
                        userRec = userMap.get(obj.Legal_Approver__c);
                        userRec.isactive = true;
                        userSet.add(userRec);
                    }
                    
                    if(obj.Business_Approver__r.isactive == false && obj.Business_Approver__c != null){
                        User userRec = new User();
                        userRec = userMap.get(obj.Business_Approver__c);
                        userRec.isactive = true;
                        userSet.add(userRec);
                    }
                    
                    if(obj.Finance_Approver__r.isactive == false && obj.Finance_Approver__c != null){
                        User userRec = new User();
                        userRec = userMap.get(obj.Finance_Approver__c);
                        userRec.isactive = true;
                        userSet.add(userRec);
                    }
                    
                    if(obj.Finance_Manager__r.isactive == false && obj.Finance_Manager__c != null){
                        User userRec = new User();
                        userRec = userMap.get(obj.Finance_Manager__c);
                        userRec.isactive = true;
                        userSet.add(userRec);
                    }
                    
                    userList = new List<User>();
                    
                }
                
                userListFinal.addAll(userSet);
                update userListFinal;
            }
        }
        catch (Exception ex) {
            system.debug('@@ Error while activating Financial Approver 1 :' +ex.getMessage());
        }  
    }
    
    global void finish(Database.BatchableContext BC){
        
        if(reqIds.size() > 0){
            gFRS_Ltng_Internal_Record_Sharing_Batch sharingBatch = new gFRS_Ltng_Internal_Record_Sharing_Batch(reqIds);
            //sharingBatch.requestIds = reqIds;
            Database.executeBatch(sharingBatch);            
        }

    }
    
}