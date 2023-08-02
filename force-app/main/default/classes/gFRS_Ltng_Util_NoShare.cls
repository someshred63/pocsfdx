public without sharing class gFRS_Ltng_Util_NoShare{
    public static boolean upAccNamewithOrgName(gFRS_Ltng_Organization__c orgObj,Id userId){
        Account accObj;
        List<Account> accs = new List<Account>();
        boolean boolRslt;
        User usrObj;
        System.System.debug('@@@::obj:::'+orgObj);
        System.System.debug('@@@::id::::'+orgObj.id);
        System.System.debug('@@@::user::'+userId);
        //GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
        try{
            accs = [SELECT Id, Name FROM Account WHERE Name =: orgObj.Organization_Name__c];
            RecordType accRecdType = [SELECT Id FROM RecordType WHERE DeveloperName = 'gFRS' AND SobjectType = 'Account' LIMIT 1];
            if(accs.size() <= 0){
                if (orgObj != null){
                    accObj = new Account();
                    accObj.Name = orgObj.Organization_Name__c;
                    accObj.RecordTypeId = accRecdType.id;
                    // insert accObj;
                    Database.SaveResult lstAcc = Database.insert(accObj,false);
                    //System.debug('@@::id::'+accObj.id);
                    //System.debug('@@::acc::'+accObj);
                    system.debug('@@@ Database:::'+lstAcc);
                    
                    if(lstAcc.isSuccess()){
                        usrObj = [SELECT Id, Contact.Id, Contact.Account.Id FROM User WHERE Id = :userId];
                        if(usrObj == null || usrObj.contactId == null || usrObj.contact.id == null){
                            system.debug('@@ Exception:::23:::');
                            boolRslt = false;                        
                        }else{
                            usrObj.Contact.AccountId = lstAcc.getId();
                            usrObj.Contact.gFRS_Organization2__c = orgObj.id;
                            update usrObj.Contact;
                            boolRslt = true;
                        }
                    }else{
                        system.debug('@@ Exception:::33:::');
                        boolRslt = false;                    
                    }
                    
                }else{
                    system.debug('@@ Exception:::36:::');
                    boolRslt = false;                
                }
            }else{
                usrObj = [SELECT Id, Contact.Id, Contact.Account.Id FROM User WHERE Id = :userId];
                if(usrObj == null || usrObj.contactId == null || usrObj.contact.id == null){
                    system.debug('@@ Exception:::222:::');
                    boolRslt = false;                        
                }else{
                    usrObj.Contact.AccountId = accs[0].Id;
                    usrObj.Contact.gFRS_Organization2__c = orgObj.id;
                    update usrObj.Contact;
                    boolRslt = true;
                }                
            }
        } catch (Exception ex){
            system.debug('@@ Exception:::40:::');
            boolRslt = false;
            System.System.debug('### Exception in upAccNamewithOrgName method:::::');
            system.debug('@@::Line num:::'+ex.getLineNumber()+'::::Msg:::'+ex.getMessage());
            System.debug('@@:::'+ex.getCause());
        }
        //GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
        return boolRslt;
    }
    
    /*
Method Name:updateUserContact
Description: This method will update user contact
*/
    
    public static boolean updateUserContact(string orgIdVal, string orgName){
        Id orgID = Id.valueOf(orgIdVal);
        Account acc = new Account();
        system.debug('Org Id Is : '+orgID);
        system.debug('Org Name Is : '+orgName);
        
        acc = [SELECT Id, name FROM Account WHERE name = :orgName limit 1];
        user usrObj = [SELECT Id, Contact.Id, Contact.Account.Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        usrObj.Contact.AccountId = acc.Id;
        usrObj.Contact.gFRS_Organization2__c = orgID;
        update usrObj.Contact;        
        return true;
    }  
    
    public static List<User> userByEmail(String p_email) {
        return [SELECT Id, FirstName, LastName, Email FROM User WHERE Email = :p_email LIMIT 1];
    }    
    
    /**
* @author GFRS Dev Team
* @date 20/11/2020
* @description getUserContact method - Determines the contact that represents the current user (and account they belong to).
*/
    public static Contact getUserContact(Id userId) {
        try {
            User u = [SELECT Contact.Id, Contact.AccountId, Contact.Account.Id, Contact.Account.Name, Contact.gFRS_Organization2__c, Contact.gFRS_Organization2__r.Id, Contact.gFRS_Organization2__r.Organization_Name__c FROM User WHERE Id = :userId];
            if (u.Contact == null || u.Contact.Account == null) {
                return(null);
            } else {
                return(u.Contact);
            }
        } catch (Exception err) {
            System.debug('unable to find user:' + userId);
            return(null);
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 20/11/2020
* @description getContactOrganization method - Method used to allow either the link of the user's contact
* or the method by finding the organization aligned with the same account as the contact (deprecated)
* Once the second method is no longer supported, this method should only support the former.
*/
    public static gFRS_Ltng_Organization__c getContactOrganization(Contact userContact) {
        if (userContact == null) {
            return(null);
        } else if (userContact.gFRS_Organization2__r != null) {
            return(userContact.gFRS_Organization2__r);
        } else {
            if (userContact.AccountId != null) {
                return(gFRS_Ltng_Util_NoShare.getAccountOrganization(userContact.AccountId));
            } else if (userContact.Account.Id != null) {
                return(gFRS_Ltng_Util_NoShare.getAccountOrganization(userContact.Account.Id));
            } else {
                System.debug('account not selected for contact, nor link for organization found. nothing to do.');
                return(null);
            }
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 20/11/2020
* @description getAccountOrganization method - Determines the Organization affiliated with a specific account.
*/
    public static gFRS_Ltng_Organization__c getAccountOrganization(Id accountId) {
        System.debug('organization connected with account: ' + accountId);
        gFRS_Ltng_Organization__c[] organizations = [
            SELECT Id, Tax_Id__c
            FROM gFRS_Ltng_Organization__c
            WHERE Account__c = :accountId
        ];
        if (organizations == null || organizations.size() < 1) {
            System.debug('no organization found');
            return(null);
        } else if (organizations.size() > 1) {
            System.debug('more than one organization associated to this account...');
            return(null);
        } else {
            return(organizations[0]);
        }
    }
    
    /**
* @author gFRS Dev Team
* @date 20/11/2020
* @description getSubmitedRequestUnderOrg method - retunr numer of request sumbmited under one org.
*
*/
    
    public static Integer getSubmitedRequestUnderOrg(Id orgId) {
        AggregateResult submitedRequestUnderOrg = null;
        AggregateResult submitedCAFRequestUnderOrg = null;
        if (orgId != null) {
            submitedRequestUnderOrg = [SELECT COUNT(Id) counter FROM gFRS_Ltng_Application__c WHERE Organization__c = :orgId AND Status__c != 'Intake'];
            submitedCAFRequestUnderOrg = [SELECT COUNT(Id) counter FROM gFRS_Ltng_CAF_Application__c WHERE gFRS_Organization__c = :orgId AND Status__c != 'Intake'];
        }
        if (submitedRequestUnderOrg == null && submitedCAFRequestUnderOrg == null) {
            return 0;
        }
        
        Integer submittedRequestCount = Integer.valueOf(submitedRequestUnderOrg.get('counter')) + Integer.valueOf(submitedCAFRequestUnderOrg.get('counter'));
        return submittedRequestCount;
    }   
    
    public static void updateGfrsAPP(gFRS_Ltng_Application__c objApp){
        if(objApp.Will_You_be_Working_With_a_third_Party__c == 'No'){
            list<gFRS_Ltng_Third_Party__c> gfThirdParty=[select id,gFRS_Application__c from gFRS_Ltng_Third_Party__c where gFRS_Application__c =:objApp.Id];
            if(gfThirdParty.size()>0){
                delete gfThirdParty;
            }
        }        
    	
        update objApp;
    }
     /*public static void updateGfrsReviewAproveAPP(gFRS_Ltng_Application__c objApp){
        if(objApp.Will_You_be_Working_With_a_third_Party__c == 'No'){
            list<gFRS_Ltng_Third_Party__c> gfThirdParty=[select id,gFRS_Application__c from gFRS_Ltng_Third_Party__c where gFRS_Application__c =:objApp.Id];
            if(gfThirdParty.size()>0){
                delete gfThirdParty;
            }
        }
            gFRS_Ltng_Organization__c org=[select id,name,X33_Limit_Percentage__c from gFRS_Ltng_Organization__c where id=:objApp.organization__c];	            
            org.X33_Limit_Percentage__c=objApp.Organization__r.X33_Limit_Percentage__c;
            update org;         
    	
        update objApp;
    } */
    
    public static void saveLockedAttachment(Attachment a) {
        upsert a;
    }
    
    public static void updateAppRecord(gFRS_Ltng_Application__c appRecord){
        upsert appRecord;
    }
    
    public static void updateApplicationRecords(List<gFRS_Ltng_Application__c> appRecords){
        upsert appRecords;
    }    
    
    public static Database.UpsertResult updateAppRec(gFRS_Ltng_Application__c appInfoRec){
        Database.UpsertResult result = Database.upsert(appInfoRec,false);
        return result;
    }    

    public static void updateProgram(gFRS_Ltng_Program__c program){
       
        upsert program;
    }
    public static void updatePrograms(List<gFRS_Ltng_Program__c> programs){
        upsert programs;
    }
    public static void deletePrograms(List<gFRS_Ltng_Program__c> programs){
        delete programs;
    }

    public static void updateComplianceFlagRec(gFRS_Ltng_Compliance_Flag__c ComplianceFlagRec){
        upsert ComplianceFlagRec;
    } 

    public static void updatePgmAudGroupRec(List<gFRS_Ltng_Program_Audience_Group__c> PgmAudGroupRec){
        upsert PgmAudGroupRec;
    }     
    
    public static void updateBudgetRec(gFRS_Ltng_Request_Budget__c budgetRec){
        update budgetRec;
    } 
    
    public static void updateBudgetRecList(List<gFRS_Ltng_Request_Budget__c> budgetRecs){
        update budgetRecs;
    }
    
    public static void insertBudgetLineItemRecList(List<gFRS_Ltng_Request_Budget_Detail__c> budgetLineItemRec){
        insert budgetLineItemRec;
    }
    
    public static void updateBudgetLineItemRecList(List<gFRS_Ltng_Request_Budget_Detail__c> budgetLineItemRec){
        update budgetLineItemRec;
    }
    
    public static void updateTask(gFRS_Ltng_Task__c taskRec){
        upsert taskRec;
    }
    
    public static void updateCAFTask(gFRS_CAF_Task__c CAFTaskRec){
        upsert CAFTaskRec;
    }
    
    public static void updateUserRec(List<User> userRecs){
        update userRecs;
    }
    
    public static void deleteTask(Id appId, String actionType){
        list<gFRS_Ltng_Task__c> taskACH = new list<gFRS_Ltng_Task__c>();
        taskACH = [SELECT Id, Name, Status__c, Action_Type__c FROM gFRS_Ltng_Task__c WHERE gFRS_Application__c =: appId AND Action_Type__c =: actionType AND Status__c != 'Completed'];
        if(taskACH.size() > 0){
            gFRS_Ltng_Task__c taskRec = taskACH[0];
            taskRec.Status__c = 'Completed';
            update taskRec;           
        } 
    }    
    
    public static void updateCAFAPP(gFRS_Ltng_CAF_Application__c objCAF){
        update objCAF;
    }
    
    public static void deleteThirdParty(list<gFRS_Ltng_Third_Party__c> thirdParties){
        delete thirdParties;
    }
    
    public static gFRS_Ltng_Application__c fetchAppRec(String applicationId){
        Id rId = Id.valueOf(applicationId);
        DescribeSObjectResult describeResult = rId.getSObjectType().getDescribe();      
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        fieldNames.add('Organization__r.Organization_Name__c');
        fieldNames.add('Organization__r.Tax_Id__c');
        fieldNames.add('Organization__r.Id');
        fieldNames.add('Organization__r.gFRS_Organization_Purchase__c');
        fieldNames.add('Organization__r.gFRS_Organization_Prescribe__c');
        fieldNames.add('Organization__r.gFRS_Organization_Develop__c');
        fieldNames.add('Organization__r.Org_Medicare_guideline_development__c');
        fieldNames.add('Organization__r.Country__c');
        String query = ' SELECT ' + String.join( fieldNames, ',' ) +	',Finance_Approver__r.External_ID_gne__c,Vendor_Detail__r.Name,Vendor_Detail__r.Vendor_ID__c,Vendor_Detail__r.Province__c,Vendor_Detail__r.Payment_Method__c,Vendor_Detail__r.Send_Payment_Attention_To__c,Vendor_Detail__r.Email_address_for_remittance_advice__c,Vendor_Detail__r.Address__c,Vendor_Detail__r.Address2__c,Vendor_Detail__r.City__c,Vendor_Detail__r.State__c,Vendor_Detail__r.Zip__c,Vendor_Detail__r.Department_Chapter_Country__c FROM ' + describeResult.getName() + ' WHERE ' + ' id = :rId ' + ' LIMIT 1 ';        
        gFRS_Ltng_Application__c appRec = Database.query( query );
        return appRec;
    }
    
    public static gFRS_Ltng_CAF_Application__c fetchCopayAppRec(String applicationId){
        Id rId = Id.valueOf(applicationId);
        DescribeSObjectResult describeResult = rId.getSObjectType().getDescribe();      
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        fieldNames.add('gFRS_Organization__r.Organization_Name__c');
        fieldNames.add('gFRS_Organization__r.Tax_Id__c');
        fieldNames.add('gFRS_Organization__r.Id');
        fieldNames.add('gFRS_Organization__r.gFRS_Organization_Purchase__c');
        fieldNames.add('gFRS_Organization__r.gFRS_Organization_Prescribe__c');
        fieldNames.add('gFRS_Organization__r.gFRS_Organization_Develop__c');
        fieldNames.add('gFRS_Organization__r.Country__c');
        String query = ' SELECT ' + String.join( fieldNames, ',' ) +	',Vendor_Detail__r.Vendor_ID__c,Vendor_Detail__r.Name,Vendor_Detail__r.Province__c,Vendor_Detail__r.Payment_Method__c,Vendor_Detail__r.Payment_Contact_Person__c,Vendor_Detail__r.Payment_Contact_Email_Address__c,Vendor_Detail__r.Address_1__c,Vendor_Detail__r.Address_2__c,Vendor_Detail__r.City__c,Vendor_Detail__r.State__c,Vendor_Detail__r.Zip__c,Vendor_Detail__r.Country__c FROM ' + describeResult.getName() + ' WHERE ' + ' id = :rId ' + ' LIMIT 1 ';        
        gFRS_Ltng_CAF_Application__c appRec = Database.query( query );
        return appRec;
    }    
    
    public static Database.SaveResult[] insertSharingRecs(List<GFRS_Ltng_Application__Share> sharingRecords){
        Database.SaveResult [] srList = Database.insert(sharingRecords, false);
        return srList;
    }   
    
    public static void addSharingToUser(Id userId){
        List<gFRS_Ltng_Application__c> appRecords = new List<gFRS_Ltng_Application__c>();
        List<GFRS_Ltng_Application__Share> listBASharing = new List<GFRS_Ltng_Application__Share>();
        
        try{
            appRecords = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Record_Type__c = 'Field Exhibits' and Business_Approver__c =: userId];
            
            if(appRecords.size() > 0){
                for(gFRS_Ltng_Application__c appRec : appRecords){
                    GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                    shrFundingRequest.ParentId = appRec.Id;
                    shrFundingRequest.UserOrGroupId = userId;
                    shrFundingRequest.AccessLevel = 'Read';
                    shrFundingRequest.RowCause = 'Manual';
                    listBASharing.add(shrFundingRequest); 
                }
                
                Database.SaveResult [] srList = gFRS_Ltng_Util_NoShare.insertSharingRecs(listBASharing);
            }
        } catch(Exception e) {
            system.debug('@@ Error at line# '+e.getLineNumber()+':'+e.getMessage());
        }  
        
    }    
    
    public static List<gFRS_CGN_PLNG_Bulk_Email__c> getCGNrecs(){
        List<gFRS_CGN_PLNG_Bulk_Email__c> CGN_Title_List;
        CGN_Title_List = [SELECT Id,CGN_PLNG_Status__c,SkipRFPCheck__c,CGN_PLNG_Title__c,Purpose_of_CGN_PLNG__c,Survey_Link__c,invitationId__c FROM gFRS_CGN_PLNG_Bulk_Email__c Where CGN_PLNG_Status__c = true and RFP_Visibleity_on_Entry_Page__c=TRUE];
        return CGN_Title_List;
    } 
    public static List<gFRS_CGN_PLNG_Bulk_Email__c> getCGNrecsFoundation(){
        List<gFRS_CGN_PLNG_Bulk_Email__c> CGN_Title_List;
        CGN_Title_List = [SELECT id,CGN_PLNG_Status__c,CGN_PLNG_Title__c,Purpose_of_CGN_PLNG__c,Survey_Link__c,invitationId__c FROM gFRS_CGN_PLNG_Bulk_Email__c Where CGN_PLNG_Status__c = true and RFP_Visibleity_on_Entry_Page__c=TRUE];
        return CGN_Title_List;
    }
    
    public static void getFundingAllocationRecord(Id appId){

        gFRS_Ltng_App_Funding_Allocation__c fundingAllocation = [SELECT Id,Name,Approved_Amount__c,gFRS_GL_Account__c,gFRS_Application__r.Refund_Amount_Internal__c,gFRS_Application__r.Refund_Due_External__c,gFRS_Application__r.Record_Type__c FROM gFRS_Ltng_App_Funding_Allocation__c Where gFRS_Application__c=:appId limit 1];
        
        gFRS_Ltng_App_Funding_Allocation__c gfrsAlc = new gFRS_Ltng_App_Funding_Allocation__c();
        gfrsAlc.gFRS_Application__c=appId;
        gfrsAlc.gFRS_GL_Account__c = fundingAllocation.gFRS_GL_Account__c;
        gfrsAlc.RecordTypeId= Schema.SObjectType.gFRS_Ltng_App_Funding_Allocation__c.getRecordTypeInfosByDeveloperName().get('Refund').getRecordTypeId();            
        if(fundingAllocation.gFRS_Application__r.Record_Type__c =='Field Exhibits'||fundingAllocation.gFRS_Application__r.Record_Type__c=='Commercial Sponsorship'||
           fundingAllocation.gFRS_Application__r.Record_Type__c =='Non-Commercial Sponsorship' || 
           fundingAllocation.gFRS_Application__r.Record_Type__c =='Corporate Memberships'){
               gfrsAlc.Refund_Amount__c = fundingAllocation.gFRS_Application__r.Refund_Amount_Internal__c; 
           }
        if(fundingAllocation.gFRS_Application__r.Record_Type__c =='Community Giving' || fundingAllocation.gFRS_Application__r.Record_Type__c =='Education Focused Giving Graduate and Post-Graduate' ||fundingAllocation.gFRS_Application__r.Record_Type__c =='Education Focused Giving K12'  ||fundingAllocation.gFRS_Application__r.Record_Type__c =='Patient and Health Focused Giving' ||fundingAllocation.gFRS_Application__r.Record_Type__c =='Scientific and Research Focused Giving'){
            gfrsAlc.Refund_Amount__c = fundingAllocation.gFRS_Application__r.Refund_Due_External__c; 
        }
        if(fundingAllocation.gFRS_Application__r.Record_Type__c =='Independent Medical Education (CME)'){
            gfrsAlc.Refund_Amount__c = fundingAllocation.gFRS_Application__r.Refund_Due_External__c;
        }
            insert gfrsAlc;
        
        List<gFRS_Ltng_Task__c> taskList = new List<gFRS_Ltng_Task__c>();
        for(gFRS_Ltng_Task__c task:  [SELECT Id, Name, Status__c, Action_Type__c FROM gFRS_Ltng_Task__c WHERE gFRS_Application__c =:appId  AND Action_Type__c = 'Refund' AND Status__c != 'Completed' limit 1]){
            task.Status__c = 'Completed'; 
            taskList.add(task);
            
        }
        gFRS_Ltng_Util_NoShare.updateTask(taskList[0]);
    }     
    
    public static List<User> getUserRec(string userName){
        return [SELECT Id, Name, Alias, Role_Name_gne__c, Department FROM User WHERE Name LIKE :userName];
    }
    
    public static Id getUserByUnixId(String unixId) {
        try {
            return([SELECT Id FROM User WHERE External_ID_gne__c = :unixId LIMIT 1][0].Id);
        } catch (Exception err) {
            System.debug('unable to find user:' + unixId);
            return(null);
        }
    }
    
     public static string createEvulationtask (gFRS_Ltng_Task_Update__c objEval){
        	upsert objEval;
            return objEval.Id;
    }
    
     public static void insertContDocLink (ContentDocumentLink contDocLink){
        	insert contDocLink;
    }
}