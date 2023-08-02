public with sharing class AGS_User_activation_controller{

    public AGS_User_activation_controller(ApexPages.StandardController controller){}

    public PageReference activateUsers(){
        system.debug(LoggingLevel.INFO, '****** param : '+ApexPages.currentPage().getParameters().get('action'));
        if(ApexPages.currentPage().getParameters().get('action').equals('Reopen')){
            return activateUsers_reopen();
        } else if(ApexPages.currentPage().getParameters().get('action').equals('CloseAllRelatedCases')){
            return activateUsers_close_related_cases();
        } else if(ApexPages.currentPage().getParameters().get('action').equals('DeActivate')){
            return deactivateUsers();
        } else {
            return null;
        }
    }

    public PageReference activateUsers_close_related_cases(){
        String theId = ApexPages.currentPage().getParameters().get('id');
        system.debug(LoggingLevel.INFO, '****** param id : ' + ApexPages.currentPage().getParameters().get('id'));
        AGS_Case_gne__c objAGScase;
        if (theId == null){ 
            PageReference pageRef = new PageReference('/apex/AGS_Close_Related_Cases?id='+theId);
            pageRef.setRedirect(true);                 
            return pageRef;                    
        }
        try {
            objAGSCase = [select Id, Name,Reason_Type_gne__c,Case_Status_gne__c, AGS_CCO_Reason_Name_gne__c from AGS_Case_gne__c where Id=:theId];
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        List<AGSSpendCCOCase_gne__c> relatedCases = new List<AGSSpendCCOCase_gne__c>();
        List<AGSSpendCCOCase_gne__c> caseDetails = new List<AGSSpendCCOCase_gne__c>([select Event_Id_gne__c from AGSSpendCCOCase_gne__c where AGS_Case_gne__c =:objAGSCase.Id and Event_Id_gne__c !=null]);
        if(caseDetails != null && caseDetails.size()>0){
            relatedCases = new List<AGSSpendCCOCase_gne__c>([select AGS_Case_gne__r.Id,AGS_Case_gne__r.AGS_CCO_Reason_Name_gne__c,AGS_Case_gne__r.Case_Status_gne__c from AGSSpendCCOCase_gne__c where Event_Id_gne__c =:caseDetails[0].Event_ID_gne__c]);
        } else{
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'There are no events associated to this case'));
            relatedCases = new List<AGSSpendCCOCase_gne__c>([select AGS_Case_gne__r.Id,AGS_Case_gne__r.AGS_CCO_Reason_Name_gne__c,AGS_Case_gne__r.Case_Status_gne__c from AGSSpendCCOCase_gne__c where AGS_Case_gne__c =:objAGSCase.Id]);
        }
        set<string> resolverSet = new set<string>();
        set<id> caseIdSet = new set<id>();
        for(AGSSpendCCOCase_gne__c relatedCase : relatedCases){
            caseIdSet.add(relatedCase.AGS_Case_gne__c);
        }
        List<AGSSpendCCOCase_gne__c> juncObj = new List<AGSSpendCCOCase_gne__c>([select AGS_Case_gne__r.Reason_Type_gne__c, AGS_Case_gne__r.Name, AGS_Case_gne__r.Resolver_gne__c, AGS_Case_gne__r.Case_Status_gne__c, AGS_Case_gne__r.AGS_CCO_Reason_Name_gne__c, User_External_ID__c, AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c from AGSSpendCCOCase_gne__c where AGS_Case_gne__c IN: caseIdSet]);      

        for (AGSSpendCCOCase_gne__c ju : juncObj){   
            if(ju.AGS_Case_gne__r.Resolver_gne__c != null && ju.AGS_Case_gne__r.Reason_Type_gne__c =='Instance Rule' && ju.AGS_Case_gne__r.Case_Status_gne__c.toLowerCase().Contains('open') && ju.AGS_Case_gne__r.AGS_CCO_Reason_Name_gne__c == objAGScase.AGS_CCO_Reason_Name_gne__c){
                resolverSet.add(ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c); 
            }
        }  
         
        List<User> usr_list = new List<User>([select email, name, IsActive, id ,External_ID_gne__c from User where External_ID_gne__c in : resolverSet and UserType ='Standard' order by email]); 
        List<User> usersToActivate = new List<User>();
        String userIdParam = '';
        for(User usr : usr_list){
            if(usr.isActive == false){
                usr.isActive = true;
                usersToActivate.add(usr);
                userIdParam += usr.Id + ',';
            }
        }
        userIdParam = userIdParam.substring(0, userIdParam.length() - 1);
        if(usersToActivate != null && usersToActivate.size() > 0){
            update usersToActivate ;
        }
        
        PageReference pageRef = new PageReference('/apex/AGS_Close_Related_Cases?id='+theId + '&usersIds='+userIdParam);
        pageRef.setRedirect(true);
        return pageRef;
    }

 
    public PageReference activateUsers_reopen(){
        String theId = ApexPages.currentPage().getParameters().get('id');
        if (theId == null){
            // Display the Visualforce page's content if no Id is passed over                   
            return null;                    
        }
        
        List<AGSSpendCCOCase_gne__c> juncObj = new List<AGSSpendCCOCase_gne__c>
                                                ([select AGS_Case_gne__r.Name, 
                                                AGS_Case_gne__r.Resolver_gne__c,
                                                AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c                                                
                                                from AGSSpendCCOCase_gne__c where AGS_Case_gne__c=:theId]);
                                                
        set<string> UnixidSet = new set<string>();                                                   
        set<ID> id_list = new set<ID>();                                        
        for (AGSSpendCCOCase_gne__c ju : juncObj){   
            if(ju.AGS_Case_gne__r.Resolver_gne__c != null){
                UnixidSet.add(ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c); 
            }
        }   
        
        List<User> usr_list = new List<User>([
                                            select email, name, id,External_ID_gne__c, IsActive  
                                            from User where External_ID_gne__c IN : UnixidSet order by email]);  
                        
        List<User> userToActivate = new List<User>();                                        
        for(User usr : usr_list){
            if(usr.isActive == false){
                usr.isActive = true;
                userToActivate.add(usr);
            }
        }                 
        
        if(userToActivate != null && userToActivate.size() > 0){
            update userToActivate;
        }               
                                                
        PageReference pageRef = new PageReference('/apex/Re_open_custom_button?id='+theId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageREference deactivateUsers(){
        String theId = ApexPages.currentPage().getParameters().get('id');
        String usersToDeactivate = ApexPages.currentPage().getParameters().get('usersIds');
        String[] usersToDeactivateIds = usersToDeactivate.split(',');
        Set<String> userIdSet = new Set<String>();
        for(String id : usersToDeactivateIds){
            userIdSet.add(id);
        }
        List<User> usrList = [SELECT Id, isActive FROM User WHERE Id IN: userIdSet];
        for(User usr : usrList){
            usr.isActive = false;
        }
        update usrList;
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;        
    }

}