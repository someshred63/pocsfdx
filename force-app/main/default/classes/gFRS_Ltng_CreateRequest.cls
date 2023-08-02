public class gFRS_Ltng_CreateRequest {
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c createRequest(String fundingType,String fsubType,string inviteCode, string requestedAmt,string accEmpRole,string intOrgArea,string benefits){
        system.debug('fundingType VS Code Delete'+fundingType);
        gFRS_Ltng_Application__c appInfoRec=new gFRS_Ltng_Application__c();
        gFRS_Ltng_Organization__c orgInfo=[Select id,Name from gFRS_Ltng_Organization__c WHERE  Organization_Name__c = 'Testing record 1' LIMIT 1];
        Id appRcdTypeId;
        String fundName=fundingType;
        
        if(fsubType=='Programs and Events'){
            string funSubName='Patient and Health Focused Giving';
            appRcdTypeId = Schema.SObjectType.gFRS_Ltng_Application__c.getRecordTypeInfosByName().get(funSubName).getRecordTypeId();
            
        }else if (fsubType=='Research Projects and Scientific Meetings'){
            string funSubName='Scientific and Research Focused Giving';
            appRcdTypeId = Schema.SObjectType.gFRS_Ltng_Application__c.getRecordTypeInfosByName().get(funSubName).getRecordTypeId();
            
        }else{
            appRcdTypeId = Schema.SObjectType.gFRS_Ltng_Application__c.getRecordTypeInfosByName().get(fundingType).getRecordTypeId();
            
        }
        //system.debug('appRcdTypeId'+appRcdTypeId);
        appInfoRec.RecordTypeId = appRcdTypeId;
        appInfoRec.Funding_Sub_Type__c=fsubType;
        appInfoRec.Accountable_Employee_Role__c=accEmpRole;
        appInfoRec.Internal_Organization_Area__c=intOrgArea;
        appInfoRec.Benefits_Exchanged_for_Internal_Funding__c=benefits;
        
        appInfoRec.Organization__c=orgInfo.Id;
        appInfoRec.Invite_Code__c = inviteCode;
        if(inviteCode=='MEM' || inviteCode=='mem')  {
            appInfoRec.FPO_Review_Required__c = 'No';
        } else{
            appInfoRec.FPO_Review_Required__c = 'Yes';
        }                                             
        appInfoRec.External_Tracking_Code__c = inviteCode;
        
        if(requestedAmt != null && requestedAmt != ''){
            appInfoRec.Requested_Amount__c = Decimal.valueOf(requestedAmt);
        }
        
        try{
            
            Database.UpsertResult srList = Database.upsert(appInfoRec,false);
            
            if(srList.isSuccess()){
                system.debug('@@@@:::Value of upsert record:::' + appInfoRec);
                system.debug('@@@@:::Value of upsert ID:::' + appInfoRec.id);
                Id recID = srList.getId();
                
                gFRS_Ltng_Application__c appRecord = [SELECT Id, Name,RecordTypeId FROM gFRS_Ltng_Application__c WHERE Id =: recID];
                system.debug('appRecord'+appRecord);
                return appRecord;
            }else{
                return null;
            }
            
        }
        catch(Exception e){
            system.debug('@@ Into Catch block::::');
            
            system.debug('@@ Excep::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
            //return null;
        }
        
    }
    @AuraEnabled
    public static gFRS_Ltng_Application__c createRequestdup(String fundingType,String fsubType){
        system.debug('fundingType'+fundingType);//Education Focused Giving
        
        gFRS_Ltng_Application__c gpapp;
        gFRS_Ltng_Application__c appInfoRec=new gFRS_Ltng_Application__c();
        gFRS_Ltng_Organization__c orgInfo=[Select id,Name from gFRS_Ltng_Organization__c Where Organization_Name__c='Testing record 1' LIMIT 1];
        Id appRcdTypeId;
        String fundName=fundingType;
        
        appRcdTypeId = Schema.SObjectType.gFRS_Ltng_Application__c.getRecordTypeInfosByName().get(fundingType).getRecordTypeId();
        system.debug('appRcdTypeId'+appRcdTypeId);
        appInfoRec.RecordTypeId = appRcdTypeId;
        appInfoRec.Funding_Sub_Type__c=fsubType;
        appInfoRec.Organization__c=orgInfo.Id;
        return gpapp;
    }
    @AuraEnabled
    public static Profile getProfileInfo(){
        try{
            String profileId = UserInfo.getProfileId();
            Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId];
            return profile;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
    }      
    
    @AuraEnabled
    public static User getUserInfo(){
        try{
            String userId = UserInfo.getUserId();
            User User = [SELECT Id, Name, Alias FROM User WHERE Id =:userId];
            return User;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static list<User> acctEmpSearch(string acctbleEmp){
        try{
            system.debug('@@@Search string passed : '+acctbleEmp);
            String acctEmp = '%' + acctbleEmp + '%';
            system.debug('@@@Search string : '+acctEmp);
            list<User> userList = new list<User>();
            userList = gFRS_Ltng_Util_NoShare.getUserRec(acctEmp);
            system.debug('User list : '+userList);
            if(userList.size() > 0){
                return userList;
            } else {
                return null;
            }
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static List<gFRS_CGN_PLNG_Bulk_Email__c> getCGNActiveTitleList() {
        
        try{
            List<gFRS_CGN_PLNG_Bulk_Email__c> CGN_Title_List;
            CGN_Title_List = gFRS_Ltng_Util_NoShare.getCGNrecs();
            system.debug('@@@ CGN_Title_List : '+CGN_Title_List);
            return CGN_Title_List;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
    @AuraEnabled
    public static List<gFRS_CGN_PLNG_Bulk_Email__c> getCGNActiveTitleListFoundation() {
        
        try{
            List<gFRS_CGN_PLNG_Bulk_Email__c> CGN_Title_List;
            CGN_Title_List = gFRS_Ltng_Util_NoShare.getCGNrecsFoundation();
            system.debug('@@@ CGN_Title_List : '+CGN_Title_List);
            return CGN_Title_List;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
    
    @AuraEnabled
    public static gFRS_CGN_PLNG_Bulk_Email__c getCGN(String grantName) {
        
        try{
            
            return [SELECT Id,CGN_PLNG_Status__c,CGN_PLNG_Title__c,Survey_Link__c,invitationId__c,Users_to_whom_email_sent__c
                    FROM gFRS_CGN_PLNG_Bulk_Email__c where CGN_PLNG_Title__c=:grantName];
            
        }catch(Exception e){
            system.debug('@@@:::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
    @AuraEnabled
    public static String validateInviteCode(String inviteCode){
        String response = null;
        Id userId = UserInfo.getUserId();
        gFRS_Ltng_CAF_User__c copayUserData = [select User__c, Invite_Code__c, Incorrect_Attempts__c from gFRS_Ltng_CAF_User__c where User__c =: userId];
        String actualInviteCode = copayUserData.Invite_Code__c;
        Decimal incorrectCodeCnt = copayUserData.Incorrect_Attempts__c == null ? 0 : copayUserData.Incorrect_Attempts__c;
        Decimal maxIncrtCodeAlwd = 3;
        if(actualInviteCode == inviteCode){
            incorrectCodeCnt = 0;
            response = '0';//Success
        }
        else{
            incorrectCodeCnt = incorrectCodeCnt + 1;
            if(incorrectCodeCnt >= maxIncrtCodeAlwd){
                response = '2';//HardStop    
            }else{
                response = '1';//Warning
            }
        }
        
        copayUserData.Incorrect_Attempts__c = incorrectCodeCnt;
        update copayUserData;
        
        return response;
    }
    
    @AuraEnabled
    public static String createCopayUser(String orgName){
        try{
            gFRS_Ltng_Copay_Util.createCAFuserRcrd(orgName);
            return 'successful';            
        }catch(Exception e){
            system.debug('@@@:::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
    @AuraEnabled
    public static List<String> getCAFuserData(){
        try{
            List<String> resp = gFRS_Ltng_Copay_Util.getCAFuserData();
            return resp;            
        }catch(Exception e){
            system.debug('@@@:::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @AuraEnabled
    public static lockoutWrapper fetchLockoutData(){
        try{
            String userId = UserInfo.getUserId();
            date refundPastDate = date.today().addDays(-31);
            date evaluationPastDate = date.today().addDays(-90);
            date reconciliationPastDate = date.today().addDays(-91);
            List<gFRS_Ltng_Task__c> PHFGrecordsEval = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> PHFGrecordsRefund = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> SRFGrecordsEval = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> SRFGrecordsRefund = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> EFGPrecordsEval = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> EFGPrecordsRefund = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> EFK12recordsEval = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> EFK12recordsRefund = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> CMErecordsRecon = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> CMErecordsRefund = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> CGrecordsEval = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> CGrecordsRefund = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> FoundUGrecordsEval = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> FoundUGrecordsRefund = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> FoundSNrecordsEval = new List<gFRS_Ltng_Task__c>();
            List<gFRS_Ltng_Task__c> FoundSNrecordsRefund = new List<gFRS_Ltng_Task__c>();
            
            PHFGrecordsEval = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                               WHERE (Action_Type__c = 'Evaluation' AND gFRS_Application__r.Program_End_Date_max__c <: evaluationPastDate) AND
                               gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                               gFRS_Application__r.RecordType_Values__c = 'Patient and Health Focused Giving'];
            PHFGrecordsRefund = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                 WHERE (Action_Type__c = 'Refund' AND gFRS_Application__r.Refund_Task_Created_Date__c <: refundPastDate) AND
                                 gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                 gFRS_Application__r.RecordType_Values__c = 'Patient and Health Focused Giving'];
            SRFGrecordsEval = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                               WHERE (Action_Type__c = 'Evaluation' AND gFRS_Application__r.Program_End_Date_max__c <: evaluationPastDate) AND
                               gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                               gFRS_Application__r.RecordType_Values__c = 'Scientific and Research Focused Giving'];
            SRFGrecordsRefund = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                 WHERE (Action_Type__c = 'Refund' AND gFRS_Application__r.Refund_Task_Created_Date__c <: refundPastDate) AND
                                 gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                 gFRS_Application__r.RecordType_Values__c = 'Scientific and Research Focused Giving'];
            EFGPrecordsEval = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                               WHERE (Action_Type__c = 'Evaluation' AND gFRS_Application__r.Program_End_Date_max__c <: evaluationPastDate) AND
                               gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                               gFRS_Application__r.RecordType_Values__c = 'Education Focused Giving Graduate and Post-Graduate'];
            EFGPrecordsRefund = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                 WHERE (Action_Type__c = 'Refund' AND gFRS_Application__r.Refund_Task_Created_Date__c <: refundPastDate) AND
                                 gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                 gFRS_Application__r.RecordType_Values__c = 'Education Focused Giving Graduate and Post-Graduate'];
            EFK12recordsEval = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                WHERE (Action_Type__c = 'Evaluation' AND gFRS_Application__r.Program_End_Date_max__c <: evaluationPastDate) AND
                                gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                gFRS_Application__r.RecordType_Values__c = 'Education Focused Giving K-12'];
            EFK12recordsRefund = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                  WHERE (Action_Type__c = 'Refund' AND gFRS_Application__r.Refund_Task_Created_Date__c <: refundPastDate) AND
                                  gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                  gFRS_Application__r.RecordType_Values__c = 'Education Focused Giving K-12'];
            CMErecordsRecon = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                               WHERE (Action_Type__c = 'Post Payment' AND gFRS_Application__r.Program_End_Date_max__c <: reconciliationPastDate) AND
                               gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                               gFRS_Application__r.RecordType_Values__c = 'Independent Medical Education (CME)'];
            CMErecordsRefund = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                WHERE (Action_Type__c = 'Refund' AND gFRS_Application__r.Refund_Task_Created_Date__c <: refundPastDate) AND
                                gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                gFRS_Application__r.RecordType_Values__c = 'Independent Medical Education (CME)'];
            CGrecordsEval = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                             WHERE (Action_Type__c = 'Evaluation' AND gFRS_Application__r.Program_End_Date_max__c <: evaluationPastDate) AND
                             gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                             gFRS_Application__r.RecordType_Values__c = 'Community Giving'];
            CGrecordsRefund = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                               WHERE (Action_Type__c = 'Refund' AND gFRS_Application__r.Refund_Task_Created_Date__c <: refundPastDate) AND
                               gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                               gFRS_Application__r.RecordType_Values__c = 'Community Giving'];
            FoundUGrecordsEval = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                  WHERE (Action_Type__c = 'Evaluation' AND gFRS_Application__r.Program_End_Date_max__c <: evaluationPastDate) AND
                                  gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                  gFRS_Application__r.RecordType_Values__c = 'Foundation Undergraduate'];
            FoundUGrecordsRefund = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                    WHERE (Action_Type__c = 'Refund' AND gFRS_Application__r.Refund_Task_Created_Date__c <: refundPastDate) AND
                                    gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                    gFRS_Application__r.RecordType_Values__c = 'Foundation Undergraduate'];
            FoundSNrecordsEval = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                  WHERE (Action_Type__c = 'Evaluation' AND gFRS_Application__r.Program_End_Date_max__c <: evaluationPastDate) AND
                                  gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                  gFRS_Application__r.RecordType_Values__c = 'Foundation Safety Net Support'];
            FoundSNrecordsRefund = [SELECT Id, Name, Action_Type__c FROM gFRS_Ltng_Task__c 
                                    WHERE (Action_Type__c = 'Refund' AND gFRS_Application__r.Refund_Task_Created_Date__c <: refundPastDate) AND
                                    gFRS_Application__r.CreatedById =: userId AND Status__c = 'Open' AND
                                    gFRS_Application__r.RecordType_Values__c = 'Foundation Safety Net Support'];
            
            lockoutWrapper lockoutWrap = new lockoutWrapper();
            
            lockoutWrap.PHFGrecordsEvalCount 	= PHFGrecordsEval.size();
            lockoutWrap.PHFGrecordsRefundCount 	= PHFGrecordsRefund.size();
            lockoutWrap.SRFGrecordsEvalCount 	= SRFGrecordsEval.size();
            lockoutWrap.SRFGrecordsRefundCount 	= SRFGrecordsRefund.size();
            lockoutWrap.EFGPrecordsEvalCount 	= EFGPrecordsEval.size();
            lockoutWrap.EFGPrecordsRefundCount 	= EFGPrecordsRefund.size();
            lockoutWrap.EFK12recordsEvalCount 	= EFK12recordsEval.size();
            lockoutWrap.EFK12recordsRefundCount 	= EFK12recordsRefund.size();
            lockoutWrap.CMErecordsReconCount 	= CMErecordsRecon.size();
            lockoutWrap.CMErecordsRefundCount 	= CMErecordsRefund.size();
            lockoutWrap.CGrecordsEvalCount 		= CGrecordsEval.size();
            lockoutWrap.CGrecordsRefundCount 		= CGrecordsRefund.size();
            lockoutWrap.FoundUGrecordsEvalCount = FoundUGrecordsEval.size();
            lockoutWrap.FoundUGrecordsRefundCount = FoundUGrecordsRefund.size();
            lockoutWrap.FoundSNrecordsEvalCount = FoundSNrecordsEval.size();
            lockoutWrap.FoundSNrecordsRefundCount = FoundSNrecordsRefund.size();
            
            return lockoutWrap;
        }catch(Exception e){
            system.debug('@@@:::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }  
    
    public class lockoutWrapper{
        @AuraEnabled public Integer PHFGrecordsEvalCount{get;set;}
        @AuraEnabled public Integer PHFGrecordsRefundCount{get;set;}
        @AuraEnabled public Integer SRFGrecordsEvalCount{get;set;}
        @AuraEnabled public Integer SRFGrecordsRefundCount{get;set;}
        @AuraEnabled public Integer EFGPrecordsEvalCount{get;set;}  
        @AuraEnabled public Integer EFGPrecordsRefundCount{get;set;}
        @AuraEnabled public Integer EFK12recordsEvalCount{get;set;} 
        @AuraEnabled public Integer EFK12recordsRefundCount{get;set;} 
        @AuraEnabled public Integer CMErecordsReconCount {get;set;}
        @AuraEnabled public Integer CMErecordsRefundCount {get;set;}
        @AuraEnabled public Integer CGrecordsEvalCount {get;set;}
        @AuraEnabled public Integer CGrecordsRefundCount {get;set;}
        @AuraEnabled public Integer FoundUGrecordsEvalCount {get;set;} 
        @AuraEnabled public Integer FoundUGrecordsRefundCount {get;set;} 
        @AuraEnabled public Integer FoundSNrecordsEvalCount {get;set;} 
        @AuraEnabled public Integer FoundSNrecordsRefundCount {get;set;} 
    } 
    
    @AuraEnabled
    public static void inviteCodeCounter(Integer num){
        try{
            gFRS_Ltng_Copay_Util.inviteCodeCounter(num);          
        }catch(Exception e){
            system.debug('@@@:::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    @AuraEnabled 
    public static String checkShutdownRule(String recordtype){
        try{

            Boolean isShutdown=false;
            String shutdownMessage;
            
            gFRS2_0_Shutdown_Rule__c shutdownRule=gFRS_Ltng_Util.checkShutdownRule(recordtype);
            if(shutdownRule != null) {
                isShutdown = true;
                shutdownMessage = shutdownRule.Message__c;
            }
            System.debug('MEssage1>'+shutdownMessage);
            return shutdownMessage;
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }
}