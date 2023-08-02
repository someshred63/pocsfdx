public class AAR_Refresh_Contacts {
    @AuraEnabled
    public static List<Integer> getCampaignsData(String recordId) {  
        Id RECORD_TYPE_ID_FRM_ADVOCACY = Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Advocacy').getRecordTypeId();    
        List <CampaignMember> cmmemberList = new List <CampaignMember>();
        List <CampaignMember> existedMemberList = new List <CampaignMember>();
        List <CampaignMember> removableMemberList = new List <CampaignMember>();
        List<Integer>InsertableCount= new List<Integer>();        
        Campaign campaignDetails;
        List<String> tumorTypeList= new List<String>();
        List<String> diseaselistList= new List<String>();
        List<String> adcategoryList= new List<String>();        
        List<Account> accList;
        List<Contact> matchedConList;
        List<Contact> existedmatchedConList;    
        set<id> accId = new set<Id> ();
        set<id> existedconId = new set<Id> ();
        set<id> existedconAccId = new set<Id> ();
        set<id> unmatchedcmpId = new set<Id> ();
        system.debug('*****recordId****'+recordId);
        if(String.isNotEmpty(recordId)) {            
            campaignDetails = [SELECT Id, Name,Tumor_Type_AAR__c,Advocacy_Category_AAR__c,Disease_Area_AAR__c FROM Campaign              
                               WHERE Id =:recordId and recordtype.DeveloperName='AAR'];                        
            existedMemberList = [SELECT Id, Name, Email,ContactId,Contact.AccountId FROM CampaignMember WHERE campaignid =:recordId];            
        }          
        String tumorList = (String) campaignDetails.get('Tumor_Type_AAR__c');  
        String diseaseList = (String) campaignDetails.get('Disease_Area_AAR__c');
        String adcategory = (String) campaignDetails.get('Advocacy_Category_AAR__c');
        if(tumorList!=null){
            tumorTypeList = tumorList.split(';');  
        }
        if(diseaseList!=null){
            diseaselistList = diseaseList.split(';'); 
        }
        if(adcategory!=null){
            adcategoryList = adcategory.split(';'); 
        }
        String newString='';        
        newString=newString.removeEnd(',') ;   
        if(tumorList!=null || diseaseList!=null||adcategory!=null) {
            String queryString = 'SELECT Id,Tumor_Type_AAR__c,Advocacy_Category_AAR__c,Disease_Area_AAR__c,Name FROM Account  WHERE recordtype.DeveloperName=\'AAR\' AND (';
            if(!tumorTypeList.isEmpty()){
                queryString += 'Tumor_Type_AAR__c INCLUDES(';
                for(String includeValue :tumorTypeList)
                    queryString += '\''+ includeValue + '\',';
                queryString = queryString.removeEnd(',') +')';
                if(diseaselistList.isEmpty() && adcategoryList.isEmpty()){
                    queryString +=  ')';
                }
            }
            if((!tumorTypeList.isEmpty() && !diseaselistList.isEmpty()) ||( !tumorTypeList.isEmpty() && !adcategoryList.isEmpty() )){
                queryString += ' OR';
            }
            if(!adcategoryList.isEmpty()){
                queryString += ' Advocacy_Category_AAR__c INCLUDES(';
                for(String includeValue3 :adcategoryList)
                    queryString += '\''+ includeValue3 + '\',';
                queryString = queryString.removeEnd(',') ;
                queryString +=  ')';     
                if((!tumorTypeList.isEmpty() && !adcategoryList.isEmpty()) && diseaselistList.isEmpty()){
                    queryString +=  ')';
                }
                if(tumorTypeList.isEmpty() && diseaselistList.isEmpty()){
                    queryString +=  ')';
                }
            }
            if((!adcategoryList.isEmpty() && !diseaselistList.isEmpty())){
                queryString += ' OR';
            }
            if(!diseaselistList.isEmpty()){
                queryString += ' Disease_Area_AAR__c INCLUDES(';
                for(String includeValue2 :diseaselistList)
                    queryString += '\''+ includeValue2 + '\',';
                queryString = queryString.removeEnd(',') ;
                queryString +=  ')';
                queryString +=  ')';
            }
            //system.debug('queryString*****'+queryString);
            if(queryString!=null){
                accList = (List<Account>)Database.query(queryString);
            }
            System.debug('****acclist'+accList);
            if(accList.size()==0){
                InsertableCount.add(9999);
                System.debug('****acclist InsertableCount'+InsertableCount);
                //public static List<Integer> getCampaignsData(String recordId) {  
            }  
            else if(!accList.isEmpty()){
                for(account acc : accList){
                    accId.add(acc.Id);        
                }                                    
                if(!existedMemberList.isEmpty()){
                    for(CampaignMember exCmp:existedMemberList){
                        existedconId.add(exCmp.ContactId);    
                        existedconAccId.add(exCmp.Contact.AccountId);
                    }               
                }
                system.debug('existedconAccId*****'+existedconAccId);
                if(!accId.isEmpty()){
                    matchedConList = [select id,Email,Name from Contact where accountId In :accId and Status_AAR__c='Active' and recordtype.DeveloperName='AAR'];
                    existedmatchedConList = [select id,Email,Name from Contact where accountId In :accId and Status_AAR__c='Active' and Id NOT In:existedconId and recordtype.DeveloperName='AAR'];
                    //removalbeConList = [select id,Email,Name from Contact where accountId In :accId and Id In:existedconId]
                    system.debug('entering to the accId ****'+accId);
                    if(matchedConList.size()==0){
                        InsertableCount.add(8888);
                        System.debug('****no Contact InsertableCount'+InsertableCount);                
                    }                      
                }
                //system.debug('existedmatchedConList ****'+existedmatchedConList);
                //system.debug('matchedConList ****'+matchedConList.size());
                if(!accId.isEmpty()){
                    if(!matchedConList.isEmpty()&&!accList.isEmpty()){
                        for(Contact conMatch : matchedConList){
                            unmatchedcmpId.add(conMatch.Id);  
                        }   
                    }
                }
                if(!unmatchedcmpId.isEmpty()||!existedconAccId.isEmpty()){
                    removableMemberList =[SELECT Id, Name, Email,ContactId FROM CampaignMember WHERE campaignid =:recordId and (ContactId NOT In:unmatchedcmpId OR Contact.AccountId NOT In:existedconAccId)];
                }
                system.debug('removableMemberList*****'+removableMemberList);
                if(!removableMemberList.isEmpty()){
                    InsertableCount.add(removableMemberList.size());
                    system.debug('InsertableCount Delete one*****'+InsertableCount);
                    //delete removableMemberList;
                }   
                else if(removableMemberList.size()==0&&!accList.isEmpty()){
                    InsertableCount.add(0);
                    system.debug('InsertableCount Delete Zero one*****'+InsertableCount);
                }
                if(!accId.isEmpty()){
                    for(Contact con:existedmatchedConList){
                        CampaignMember cml = new CampaignMember();                        
                        cml.campaignid = recordId;
                        cml.ContactId = con.id;   
                        //cml.recordtypeId=RECORD_TYPE_ID_FRM_ADVOCACY;
                        cmmemberList.add(cml);            
                    }   
                }
                system.debug('cmmemberList****'+cmmemberList);
                if(!cmmemberList.isEmpty()){ 
                    InsertableCount.add(cmmemberList.size());
                    system.debug('InsertableCount Insert one*****'+InsertableCount);
                    //insert cmmemberList;
                }
                else if(cmmemberList.size()==0&&!accList.isEmpty()){
                    InsertableCount.add(0);   
                    system.debug('InsertableCount Insert zero one*****'+InsertableCount);
                }
            }
        }
        //return matchedConList.size();
        return InsertableCount;
    }
    @AuraEnabled
    public static void getCampaignsInsertionData(String recordId) {  
        Id RECORD_TYPE_ID_FRM_ADVOCACY = Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Advocacy').getRecordTypeId();    
        List <CampaignMember> cmmemberList = new List <CampaignMember>();
        List <CampaignMember> existedMemberList = new List <CampaignMember>();
        List <CampaignMember> removableMemberList = new List <CampaignMember>();
        List<Integer>InsertableCount= new List<Integer>();        
        Campaign campaignDetails;
        List<String> tumorTypeList= new List<String>();
        List<String> diseaselistList= new List<String>();
        List<String> adcategoryList= new List<String>();        
        List<Account> accList;
        List<Contact> matchedConList;
        List<Contact> existedmatchedConList;    
        set<id> accId = new set<Id> ();
        set<id> existedconId = new set<Id> ();
        set<id> existedconAccId = new set<Id> ();
        set<id> unmatchedcmpId = new set<Id> ();
        system.debug('*****recordId****'+recordId);
        if(String.isNotEmpty(recordId)) {            
            campaignDetails = [SELECT Id, Name,Tumor_Type_AAR__c,Advocacy_Category_AAR__c,Disease_Area_AAR__c FROM Campaign              
                               WHERE Id =:recordId and recordtype.DeveloperName='AAR'];                        
            existedMemberList = [SELECT Id, Name, Email,ContactId,Contact.AccountId FROM CampaignMember WHERE campaignid =:recordId];            
        }          
        String tumorList = (String) campaignDetails.get('Tumor_Type_AAR__c');  
        String diseaseList = (String) campaignDetails.get('Disease_Area_AAR__c');
        String adcategory = (String) campaignDetails.get('Advocacy_Category_AAR__c');
        if(tumorList!=null){
            tumorTypeList = tumorList.split(';');  
        }
        if(diseaseList!=null){
            diseaselistList = diseaseList.split(';'); 
        }
        if(adcategory!=null){
            adcategoryList = adcategory.split(';'); 
        }
        String newString='';        
        newString=newString.removeEnd(',') ;        
        String queryString = 'SELECT Id,Tumor_Type_AAR__c,Advocacy_Category_AAR__c,Disease_Area_AAR__c,Name FROM Account  WHERE recordtype.DeveloperName=\'AAR\' AND (';
        if(!tumorTypeList.isEmpty()){
            queryString += 'Tumor_Type_AAR__c INCLUDES(';
            for(String includeValue :tumorTypeList)
                queryString += '\''+ includeValue + '\',';
            queryString = queryString.removeEnd(',') +')';
            if(diseaselistList.isEmpty() && adcategoryList.isEmpty()){
                queryString +=  ')';
            }
        }
        if((!tumorTypeList.isEmpty() && !diseaselistList.isEmpty()) ||( !tumorTypeList.isEmpty() && !adcategoryList.isEmpty() )){
            queryString += ' OR';
        }
        if(!adcategoryList.isEmpty()){
            queryString += ' Advocacy_Category_AAR__c INCLUDES(';
            for(String includeValue3 :adcategoryList)
                queryString += '\''+ includeValue3 + '\',';
            queryString = queryString.removeEnd(',') ;
            queryString +=  ')';     
            if((!tumorTypeList.isEmpty() && !adcategoryList.isEmpty()) && diseaselistList.isEmpty()){
                queryString +=  ')';
            }
            if(tumorTypeList.isEmpty() && diseaselistList.isEmpty()){
                queryString +=  ')';
            }
        }
        if((!adcategoryList.isEmpty() && !diseaselistList.isEmpty())){
            queryString += ' OR';
        }
        if(!diseaselistList.isEmpty()){
            queryString += ' Disease_Area_AAR__c INCLUDES(';
            for(String includeValue2 :diseaselistList)
                queryString += '\''+ includeValue2 + '\',';
            queryString = queryString.removeEnd(',') ;
            queryString +=  ')';
            queryString +=  ')';
        }
        system.debug('queryString*****'+queryString);
        accList = (List<Account>)Database.query(queryString);
        System.debug('****acclist'+accList);
        if(accList.size()==0){
            InsertableCount.add(9999);
            System.debug('****acclist InsertableCount'+InsertableCount);
            //public static List<Integer> getCampaignsData(String recordId) {  
        }
        else if(!accList.isEmpty()){
            for(account acc : accList){
                accId.add(acc.Id);        
            }              
            
            if(!existedMemberList.isEmpty()){
                for(CampaignMember exCmp:existedMemberList){
                    existedconId.add(exCmp.ContactId);    
                    existedconAccId.add(exCmp.Contact.AccountId);        
                }               
            }
            if(!accId.isEmpty()){
                matchedConList = [select id,Email,Name from Contact where accountId In :accId and Status_AAR__c='Active' and recordtype.DeveloperName='AAR'];
                existedmatchedConList = [select id,Email,Name from Contact where accountId In :accId and Status_AAR__c='Active' and Id NOT In:existedconId and recordtype.DeveloperName='AAR'];
                //removalbeConList = [select id,Email,Name from Contact where accountId In :accId and Id In:existedconId]
                if(matchedConList.size()==0){
                    InsertableCount.add(8888);
                    System.debug('****no Contacts InsertableCount'+InsertableCount);                
                }                      
            }
            //system.debug('existedmatchedConList ****'+existedmatchedConList);
            //system.debug('matchedConList ****'+matchedConList);
            if(!accId.isEmpty()){
                if(!matchedConList.isEmpty()&&!accList.isEmpty()){
                    for(Contact conMatch : matchedConList){
                        unmatchedcmpId.add(conMatch.Id);  
                    }   
                }                
            }
            if(!unmatchedcmpId.isEmpty()||!existedconAccId.isEmpty()){
                removableMemberList =[SELECT Id, Name, Email,ContactId FROM CampaignMember WHERE campaignid =:recordId and (ContactId NOT In:unmatchedcmpId OR Contact.AccountId NOT In:existedconAccId)];
            }
            system.debug('removableMemberList*****'+removableMemberList);
            if(!removableMemberList.isEmpty()){
                InsertableCount.add(removableMemberList.size());
                delete removableMemberList;
            }                                              
            if(!accId.isEmpty()){
                for(Contact con:existedmatchedConList){
                    CampaignMember cml = new CampaignMember();                        
                    cml.campaignid = recordId;
                    cml.ContactId = con.id;   
                    //cml.recordtypeId=RECORD_TYPE_ID_FRM_ADVOCACY;
                    cmmemberList.add(cml);            
                }   
            }
            system.debug('cmmemberList****'+cmmemberList);
            if(!cmmemberList.isEmpty()){ 
                InsertableCount.add(cmmemberList.size());
                insert cmmemberList;
            }
        }
        //return matchedConList.size();
        //return null;
    }
}