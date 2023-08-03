/**********************************************************************************************************************
Purpose: ROBOCOPS-362
This requirement is to track the few fields of the Submitted Requests
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raju Manche  10/7/2020      INITIAL DEVELOPMENT

***********************************************************************************************************************/
trigger SPLOA_Request_HistoryTracker on C_Ops_SPLOA_Request__c (after insert,after update) {
    List<Schema.FieldSetMember> trackedFields =     SObjectType.C_Ops_SPLOA_Request__c.FieldSets.HistoryTracking.getFields();
    if (trackedFields.isEmpty()) return;
    
    List<C_Ops_SPLOA_Track_Request_History__c> trackChanges = new List<C_Ops_SPLOA_Track_Request_History__c>();
    
    List<string> apiNameList = new List<string>();        
    
    if(Trigger.isInsert){
        for (C_Ops_SPLOA_Request__c ReqNew : trigger.new) {
            String newValue; 
            for (Schema.FieldSetMember fsm : trackedFields) {
                
                String fieldName  = fsm.getFieldPath();
                String fieldLabel = fsm.getLabel();    
                String newUserName  = fsm.getFieldPath();                            
                if(fieldName=='Assign_To__c'){
                    Id newUserId = String.valueOf(ReqNew.get(fieldName)); 
                    if(newUserId!=null){               
                        newUserName = [select Id,name from user where Id =:newUserId].Name; 
                        system.debug('newUserName*****'+newUserName);
                        newValue = newUserName;                                                                      
                    }                    
                }  
                else{       
                    newValue = String.valueOf(ReqNew.get(fieldName));                    
                }
                if (newValue != null && newValue.length()>255) newValue = newValue.substring(0,255); 
                
                C_Ops_SPLOA_Track_Request_History__c ReqTrack = new C_Ops_SPLOA_Track_Request_History__c();
                ReqTrack.SPLOA_IAP_Submitted_Request__c = ReqNew.Id;
                ReqTrack.name = ReqNew.Name;
                //ReqTrack.name         = fieldLabel;
                //ReqTrack.SPLOA_Field_Name__c   = fieldName;
                ReqTrack.SPLOA_Action__c='Insert';
                ReqTrack.SPLOA_Field_Name__c   = fieldLabel;
                //ReqTrack.SPLOA_User__c      = ReqNew.Id;
                ReqTrack.SPLOA_User__c = UserInfo.getUserId();                    
                ReqTrack.SPLOA_New_Value__c  = newValue;
                ReqTrack.SPLOA_Date__c  = system.now();
                
                apiNameList.add(ReqTrack.SPLOA_Field_Name__c);
                trackChanges.add(ReqTrack);                       
            }
        }
    }
    if(Trigger.isUpdate){
        if(SPLOA_HelperClass.firstRun){
            for (C_Ops_SPLOA_Request__c ReqNew : trigger.new) {
                String oldValue;
                String newValue; 
                C_Ops_SPLOA_Request__c ReqOld = trigger.oldmap.get(ReqNew.Id);
                
                for (Schema.FieldSetMember fsm : trackedFields) {
                    
                    String fieldName  = fsm.getFieldPath();
                    String oldUserName  = fsm.getFieldPath();
                    String newUserName  = fsm.getFieldPath();
                    system.debug('fieldName*****'+fieldName);                
                    String fieldLabel = fsm.getLabel();                                
                    if (ReqNew.get(fieldName) != ReqOld.get(fieldName)) {
                        
                        if(fieldName!='Assign_To__c' && fieldName!='Submission_Date_Time__c'){
                            oldValue = String.valueOf(ReqOld.get(fieldName));
                            system.debug('oldfieldName*****'+ReqOld.get(fieldName));
                            //system.debug('getfieldName*****'+ReqOld.get(fieldName));
                            newValue = String.valueOf(ReqNew.get(fieldName));
                            system.debug('newfieldName*****'+ReqNew.get(fieldName));
                            if (oldValue != null && oldValue.length()>255) oldValue = oldValue.substring(0,255);
                            if (newValue != null && newValue.length()>255) newValue = newValue.substring(0,255); 
                        }
                        else if(fieldName=='Assign_To__c'){
                            Id oldUserId = String.valueOf(ReqOld.get(fieldName));
                            Id newUserId = String.valueOf(ReqNew.get(fieldName));
                            if(oldUserId!=null){               
                                oldUserName = [select Id,name from user where Id =:oldUserId].Name;
                                oldValue = oldUserName;
                                system.debug('oldUserName*****'+oldUserName);
                            }
                            if(newUserId!=null){               
                                newUserName = [select Id,name from user where Id =:newUserId].Name;                                                
                                system.debug('newUserName*****'+newUserName);
                                newValue = newUserName;
                            }
                        }      
                        else if(fieldName=='Submission_Date_Time__c'){
                            // Old Value
                            DateTime oldDT = DateTime.valueOf(ReqOld.get(fieldName));
                            oldValue = oldDT.format();                                                        
                            // New Value
                            DateTime newDT = DateTime.valueOf(ReqNew.get(fieldName));                                                        
                            //DateTime newDT = system.now();                            
                            newValue = newDT.format();
                        }  
                        /*
else {            
oldValue = String.valueOf(ReqOld.get(fieldName));
system.debug('oldfieldName*****'+ReqOld.get(fieldName));
//system.debug('getfieldName*****'+ReqOld.get(fieldName));
newValue = String.valueOf(ReqNew.get(fieldName));
system.debug('newfieldName*****'+ReqNew.get(fieldName));
if (oldValue != null && oldValue.length()>255) oldValue = oldValue.substring(0,255);
if (newValue != null && newValue.length()>255) newValue = newValue.substring(0,255); 
}
*/
                        C_Ops_SPLOA_Track_Request_History__c ReqTrack = new C_Ops_SPLOA_Track_Request_History__c();
                        ReqTrack.SPLOA_IAP_Submitted_Request__c = ReqNew.Id;
                        ReqTrack.name = ReqNew.Name;
                        //ReqTrack.name         = fieldLabel;
                        //ReqTrack.SPLOA_Field_Name__c   = fieldName;
                        ReqTrack.SPLOA_Action__c='Update';
                        ReqTrack.SPLOA_Field_Name__c   = fieldLabel;
                        //ReqTrack.SPLOA_User__c      = ReqNew.Id;
                        ReqTrack.SPLOA_User__c = UserInfo.getUserId();
                        ReqTrack.SPLOA_Old_Value__c  = oldValue;
                        ReqTrack.SPLOA_New_Value__c  = newValue;
                        ReqTrack.SPLOA_Date__c  = system.now();
                        
                        apiNameList.add(ReqTrack.SPLOA_Field_Name__c);
                        trackChanges.add(ReqTrack);
                    }                        
                }
            }
            SPLOA_HelperClass.firstRun=false;
        }
    }
    if (!trackChanges.isEmpty()) {
        insert trackChanges;
    }
}