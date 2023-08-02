/** 
* @Author chavvas
* @date 4/26/2021
* @description gFRS_Ltng_Copay_Util class - utility class for copay (lightning) related methods.
*/
public without sharing class gFRS_Ltng_Copay_Util {
    
    public static final String Code_Approved = 'Approved';
    public static final String Code_Requested = 'Requested';
    public static final String Code_Denied = 'Denied';
    public static final String FiscalYr_Jan_Dec = 'Jan - Dec';
    public static final String FiscalYr_Jul_Jun = 'Jul - Jun';
    public static final String APPROVAL_SUBMITTED = 'Submitted';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_CST_REVIEW = 'Grant Approver 1';
    /** 
     * @Author chavvas
     * @date 4/26/2021
     * @description generateInviteCode method - generates a unique 8 char invite code.
     */
    public static String generateInviteCode(gFRS_Ltng_CAF_User__c newUser) {
        
        String inviteCode;
        List < gFRS_Ltng_CAF_User__c > copayUsersList = [select Invite_Code__c,User__c, User__r.Name  from gFRS_Ltng_CAF_User__c];
        Set < String > inviteCodeSet = new Set < String > ();

        for (gFRS_Ltng_CAF_User__c copayUser: copayUsersList) {
            inviteCodeSet.add(copayUser.Invite_Code__c);
        }

        do {
            inviteCode = generateAlphaNumCode();
        } while (inviteCodeSet.contains(inviteCode));

        return inviteCode;

    }
    
	 /** 
     * @Author chavvas
     * @date 4/26/2021
     * @description generateAlphaNumCode method - generates a random 8 char long alpha numeric string.
     */
    public static String generateAlphaNumCode() {

        String hexDigest = '';

        do {
            String hashString = String.valueOf(Crypto.getRandomInteger());
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            hexDigest = EncodingUtil.convertToHex(hash);
        } while (hexDigest.length() < 8);

        return hexDigest.SubString(0, 8);
    }
    
   	/** 
    * @Author chavvas
    * @date 4/26/2021
    * @description inviteCodeCounter method - maintains a record of invite code attempts.
    */
    public static void inviteCodeCounter(Integer num){
        
        Id userId = UserInfo.getUserId();
        gFRS_Ltng_CAF_User__c userData = [select Incorrect_Attempts__c from gFRS_Ltng_CAF_User__c where User__c =: userId];
        userData.Incorrect_Attempts__c = num;
        update userData;

    }
    
    /** 
    * @Author chavvas
    * @date 4/26/2021
    * @description getCAFuserData method - returns invite code info, max allowed wrong code attempts and number of incorrect attemtps by the user in a list.
    */
    public static List<String> getCAFuserData(){
        List<String> resp = new List<String>();
        Id userId = UserInfo.getUserId();
        List<gFRS_Ltng_CAF_User__c> userData = [select Invite_Code__c, Invite_Code_Status__c,Incorrect_Attempts__c from gFRS_Ltng_CAF_User__c where User__c =: userId];
        gFRS_CAF__mdt copayMdt = [select MasterLabel, Max_Incorrect_Code_Attempts__c from gFRS_CAF__mdt where MasterLabel = 'Default'];
        
        String invCodeLimit = copayMdt.Max_Incorrect_Code_Attempts__c;
        resp.add(invCodeLimit);//max number of tries for invite code
        
        //No Copay User record available
        if(userData.size() == 0){
        	resp.add('0');//numbr of incorrect invite code attempts
            resp.add('NoUsr');
            resp.add('NoCod');
   		}else if(userData.size() == 1){
            resp.add(String.valueOf(userData[0].Incorrect_Attempts__c));
            resp.add(userData[0].Invite_Code_Status__c);

            if(userData[0].Invite_Code_Status__c == Code_Approved){
            	resp.add(userData[0].Invite_Code__c);
            }else{
            	resp.add('NoCod');    
            }
			
    	}else{
            resp.add('0');
            resp.add('Multi');
            resp.add('NoCod');
        }
	   	
		return resp;
    }
    
	/** 
    * @Author chavvas
    * @date 4/26/2021
    * @description createCAFuserRcrd method - create a record for CAF Users.
    */
    public static void createCAFuserRcrd(String orgName){

        Id userId = UserInfo.getUserId();        
        gFRS_Ltng_CAF_User__c userData = new gFRS_Ltng_CAF_User__c();

        List<gFRS_Ltng_CAF_User__c> userRecs = [select id from gFRS_Ltng_CAF_User__c where User__c =: userId];
        gFRS_CAF__mdt copayMdt = [select MasterLabel, Code_Reviewer_Id__c from gFRS_CAF__mdt where MasterLabel = 'Default'];
        
        if(userRecs.size() == 0){
        	userData.User__c = UserInfo.getUserId();
        	userData.Code_Req_Approver__c = copayMdt.Code_Reviewer_Id__c;
        	userData.Invite_Code_Status__c = Code_Requested;
        	userData.Incorrect_Attempts__c = 0;
            userData.Organization_Name__c = orgName;
        
        insert userData;
            
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
       	req.setComments('User initiated request for invite code');        
        req.setObjectId(userData.Id);
            
        // Submit for approval request         
        Approval.ProcessResult result = Approval.process(req); 
		System.debug(userData.Id + ' Submission for Approval ' + result.isSuccess());
        }else{
            System.debug('createCAFuserRcrd - A Copay User already exists');
        }

    }
    
    @AuraEnabled
    public static List<gFRS_CAF_Disease_State__c> getEmptyDS(Integer num){
        List<gFRS_CAF_Disease_State__c> DsList = new List<gFRS_CAF_Disease_State__c>();
        for(integer i=0; i<num; i++){
            gFRS_CAF_Disease_State__c ds = new gFRS_CAF_Disease_State__c();
            ds.Disease_Fund_Name__c = null; 
            ds.Fund_Type__c = null;
            ds.Requested_Donation_Amount__c = null;
            ds.Time_Frame_for_Requested_Donation__c = null;
            DsList.add(ds);
        }
        return DsList;
	}
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId,String typOfFile) {
        try{            
            if (fileId == '') {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            } else {
                appendToFile(fileId, base64Data);
            }
            if(fileId != null && String.isNotBlank(typOfFile)){
                gFRS_Ltng_CAF_Application__c objApp = [Select id ,Addition_Document_2__c,Addition_Document_3__c,OIG_Opinion_Attchmnt__c, Program_Audit_Attachment__c, Addition_Document_1__c From gFRS_Ltng_CAF_Application__c where id=: parentId];
				if(typOfFile == 'OIG'){
                    objApp.id = parentId;
                    objApp.OIG_Opinion_Attchmnt__c = Id.valueOf(fileId);
                }else if(typOfFile == 'Prg'){
                    objApp.id = parentId;
                    objApp.Program_Audit_Attachment__c = Id.valueOf(fileId);
                }else if(typOfFile == 'AdDoc1'){
                    objApp.id = parentId;
                    objApp.Addition_Document_1__c = Id.valueOf(fileId);
                }else if(typOfFile == 'AdDoc2'){
                    objApp.id = parentId;
                    objApp.Addition_Document_2__c = Id.valueOf(fileId);
                }else if(typOfFile == 'AdDoc3'){
                    objApp.id = parentId;
                    objApp.Addition_Document_3__c = Id.valueOf(fileId);
                }
                upsert objApp;
            }
            return Id.valueOf(fileId);
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @AuraEnabled    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');            
            
            Attachment attach = new Attachment();
            attach.parentId = parentId;
            attach.OwnerId = UserInfo.getUserId();
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = fileName;
            attach.ContentType = contentType;
            
            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attach.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = attach.OwnerId;//Owner of the file
            cVersion.Title = attach.Name;//Name of the file
            cVersion.VersionData = attach.Body;//File content
            cVersion.isMajorVersion = false;
            Insert cVersion;
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;
            
            system.debug('@@@ value of :::'+cDocLink);
            return cDocLink.ContentDocumentId;            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }       
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
          
            ContentVersion cVersion = [ 
                SELECT VersionData 
                FROM ContentVersion 
                WHERE ContentDocumentId = :fileId AND IsLatest = true];
            
            String existingBody = EncodingUtil.base64Encode(cVersion.VersionData);
            
            cVersion.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
            
            update cVersion;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @AuraEnabled
    public static void saveDSRecords(List<gFRS_CAF_Disease_State__c> dsList, Id appId,String cafAppobj){
        try{
            
            upsert dsList;
            if(String.isNotEmpty(cafAppobj)){
               gFRS_Ltng_CAF_Application__c cafApp1 = [Select Id,DS_Other_Please_specify__c FROM gFRS_Ltng_CAF_Application__c WHERE Id=:appId];
                update cafApp1;
            }
          //  update cafAppobj;
            
            //Get DS record Ids (if available) to list - dsListIds in UI Data
            List<Id> dsListIds = new List<Id>();            
            for(gFRS_CAF_Disease_State__c dsObj : dsList){        
                if(dsObj.Id != null){
                    dsListIds.add(dsObj.Id);     
                }                   
            }
            
            if(dsListIds.size() != 0){                
                //Get DS records (if available) from the salesforce
            	gFRS_Ltng_CAF_Application__c cafApp = [Select Id, (SELECT Id, Disease_Fund_Name__c from gFRS_CAF_Disease_State__r) FROM gFRS_Ltng_CAF_Application__c WHERE Id = :appId ];                
                
                //Find records that are missing(deleted) in UI, added to List - recordsToDelete 
                List<gFRS_CAF_Disease_State__c> recordsToDelete = new List<gFRS_CAF_Disease_State__c>();
                for(gFRS_CAF_Disease_State__c dsObj : cafApp.gFRS_CAF_Disease_State__r){
                    if(!(dsListIds.contains(dsObj.Id))){
                        recordsToDelete.add(dsObj);
                    }
                }
                
                //Delete User deleted records in salesforce
                delete recordsToDelete;			
            }
            
        }catch(DmlException e){
            System.debug('saveDSRecords ' + e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static gFRS_Ltng_CAF_Application__c createNewCAFapp(gFRS_Ltng_CAF_Application__c cafApp){
        try{
            insert cafApp;
        }catch(DmlException e){
            System.debug('createNewCAFapp ' + e.getMessage());
        }
        return cafApp;
    }
    
    @AuraEnabled
    public static void updateCAFApp(gFRS_Ltng_CAF_Application__c cafApp){
        try{
            update cafApp;
        }catch(DmlException e){
            System.debug('updateCAFApp ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void updateCAFAppcon(gFRS_Ltng_CAF_Application__c cafApp,Boolean RFIcheck){
        try{
           if(RFIcheck==true){
               gFRS_CAF_Task__c caftsk=[select Status__c,gFRS_CAF_Application__c from gFRS_CAF_Task__c WHERE Status__c!='Completed' and gFRS_CAF_Application__c=:cafApp.Id LIMIT 1];
                caftsk.Status__c='Completed';
                update caftsk;
               cafApp=[select  Status__c,Internal_Sub_Status__c,External_Status__c,RFI_Previous_Status__c,RFI_Previous_Sub_Status__c,RFI_Previous_External_Status__c from gFRS_Ltng_CAF_Application__c WHERE  Id=:cafApp.Id LIMIT 1];
               cafApp.Status__c=cafApp.RFI_Previous_Status__c;
               cafApp.Internal_Sub_Status__c=cafApp.RFI_Previous_Sub_Status__c;
               cafApp.External_Status__c=cafApp.RFI_Previous_External_Status__c;
           }
            update cafApp;
           
        }catch(DmlException e){
            System.debug('updateCAFApp ' + e.getMessage());
        }
    }
    
    public static void doLimtCal_NonCopay(List<gFRS_Ltng_CAF_Application__c> newAppList ,map<id,gFRS_Ltng_CAF_Application__c> oldAppMap){
        if(oldAppMap!= null){
            List<gFRS_Ltng_Organization__c> orgList = new List<gFRS_Ltng_Organization__c>();
			gFRS_Ltng_ApplicationTriggerHandler handler = new gFRS_Ltng_ApplicationTriggerHandler();
            
            for(gFRS_Ltng_CAF_Application__c appObj : newAppList){                
                gFRS_Ltng_CAF_Application__c oldApp = oldAppMap.get(appObj.ID);                
                Boolean recalculate =  checkRequestEligibilty(appObj,oldApp);                
                if(recalculate == true){
                    gFRS_Ltng_Organization__c org = [select id, gFRS_Tot_Aprv_Crnt_Yr__c, 
                                                     (select id, sub_status__c, Date_Submitted__c, Record_Type__c, Approved_Amount__c from FRS_Applications__r),
                                                     (select id, Internal_Sub_Status__c, Date_for_Limit_Calculation__c, Total_Approved_Amount__c from gFRS_CAF_Applications__r)
                                                     from gFRS_Ltng_Organization__c where id =:appObj.gFRS_Organization__c];                    
                    org.gFRS_Tot_Aprv_Crnt_Yr__c = 0.0;                    
                    for(gFRS_Ltng_Application__c orgApp : org.FRS_Applications__r){
                        Boolean considerApp = handler.checkRequestEligibilty(orgApp,null);
                        if(considerApp == true){
                            org.gFRS_Tot_Aprv_Crnt_Yr__c = org.gFRS_Tot_Aprv_Crnt_Yr__c + orgApp.Approved_Amount__c;    
                        }
                    }
					
					for(gFRS_Ltng_CAF_Application__c orgApp : org.gFRS_CAF_Applications__r){
                        Boolean considerApp = checkRequestEligibilty(orgApp,null);
                        if(considerApp == true){
                            org.gFRS_Tot_Aprv_Crnt_Yr__c = org.gFRS_Tot_Aprv_Crnt_Yr__c + orgApp.Total_Approved_Amount__c;    
                        }
                    }                     
                    orgList.add(org); 
                }
            }
        }    
    }
    
    public static boolean checkRequestEligibilty(gFRS_Ltng_CAF_Application__c newApp, gFRS_Ltng_CAF_Application__c oldApp){
        Date dateSubmitted = newApp.Date_for_Limit_Calculation__c;
        Boolean isEligible = false;
        
        if(dateSubmitted != null && dateSubmitted.year() == Date.today().year()){
            if(oldApp != null){
                if((newApp.Internal_Sub_Status__c != null && (oldApp.Internal_Sub_Status__c == null || newApp.Internal_Sub_Status__c != oldApp.Internal_Sub_Status__c)) 
                   || (newApp.Total_Approved_Amount__c != null && (oldApp.Total_Approved_Amount__c == null || newApp.Total_Approved_Amount__c != oldApp.Total_Approved_Amount__c))
                   || (newApp.Total_Approved_Amount__c == null && oldApp.Total_Approved_Amount__c != null)){
                       isEligible = True;    
                   }
            }else{
                if(newApp.Internal_Sub_Status__c != null 
                   && (newApp.Internal_Sub_Status__c != 'Canceled' || newApp.Internal_Sub_Status__c != 'Denied')
                   && newApp.Total_Approved_Amount__c != null){
                       isEligible = True;   
                   }    
            }
        }
        return isEligible;
    }
    
    public static void doLimtCal_NonCopay(Id orgId, Date dateForLimitCal){
        
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.CAF_App_for_Hybrid_Calculation__c != null){
            gFRS_Ltng_CAF_Application__c cafApp = [Select id, gFRS_Organization__c, Date_for_Limit_Calculation__c 
                                                  		FROM gFRS_Ltng_CAF_Application__c
                                                  		WHERE id = :myOrgCS.CAF_App_for_Hybrid_Calculation__c];
            cafApp.gFRS_Organization__c = orgId;
            cafApp.Date_for_Limit_Calculation__c = dateForLimitCal;
            update cafApp;
            
            doLimtCal(cafApp.Id);
        }        
    }
    
    @AuraEnabled
    public static void doLimtCal(Id cafAppId){
        
		gFRS_Ltng_CAF_Application__c cafApp = [SELECT Id, Name,  Date_for_Limit_Calculation__c, Date_Submitted__c, Org_Quarter__c,
         	gFRS_Organization__c, gFRS_Organization__r.Act_YTD_Annual_Revenue__c, gFRS_Organization__r.Actual_Revenue_for_Prior_Fiscal_Y__c, 
         	gFRS_Organization__r.Proj_Annual_Revenue_Next_Fiscal_Year__c, gFRS_Organization__r.Org_Fiscal_Year__c, Total_Approved_Amount__c, Total_Payment_Amount_Rollup__c, 
         	gFRS_Organization__r.Proj_Ann_Rev_CrntYear__c, Limit_Calculation_Start_Date__c, Limit_Calculation_End_Date__c, Stringified_Copay_Requests__c,
            Rule_Considered__c, Revenue_Considered__c, Revenue__c, YTD_Total_Approved_Amounts_Copay__c, YTD_Total_Amount_Non_Copay__c, Stringified_Non_Copay_Requests__c,
            Estimated_Current_Revenue__c, Estimated_Donation_Limit__c, Estimated_Remaining_Donation_Limit__c, YTD_Total_Approved_Donations__c 
            	FROM gFRS_Ltng_CAF_Application__c WHERE Id = :cafAppId LIMIT 1];
       
        if(cafApp.Date_for_Limit_Calculation__c != null){            
			cafApp = setLimtCalStartDate(cafApp);
        	cafApp = setLimtCalEndDate(cafApp);
            cafApp = setRuleForLimtCal(cafApp);
			cafApp = setRevForLimtCal(cafApp);
            cafApp = setYTDAppAmtCopay(cafApp);
            cafApp = setYTDAppAmtNonCopay(cafApp);
            Boolean isSaved = saveLimtCalValues(cafApp);
        }else{
            
        }		
    }
    
    public static gFRS_Ltng_CAF_Application__c setLimtCalStartDate(gFRS_Ltng_CAF_Application__c cafApp){
        
        Date limtCalDate = cafApp.Date_for_Limit_Calculation__c;
        String fiscalYr = cafApp.gFRS_Organization__r.Org_Fiscal_Year__c;
        Integer month = limtCalDate.month();
        Integer Year = limtCalDate.year();
        Date startDate = null;
        
        if(fiscalYr == FiscalYr_Jan_Dec){
            startDate =  Date.newinstance(Year,1,1); 
        }else if(fiscalYr == FiscalYr_Jul_Jun){
            if(month < 7){
                startDate =  Date.newinstance(Year-1,7,1);
            }else{
                startDate =  Date.newinstance(Year,7,1);
            }
        }
        cafApp.Limit_Calculation_Start_Date__c = startDate;
        return cafApp;
    }
    
    public static gFRS_Ltng_CAF_Application__c setLimtCalEndDate(gFRS_Ltng_CAF_Application__c cafApp){
                
        Date limtCalDate = cafApp.Date_for_Limit_Calculation__c;
        String fiscalYr = cafApp.gFRS_Organization__r.Org_Fiscal_Year__c;
        Integer month = limtCalDate.month();
        Integer Year = limtCalDate.year();
        Date endDate = null;
        
        if(fiscalYr == FiscalYr_Jan_Dec){
            endDate =   Date.newinstance(Year,12,31); 
        }else if(fiscalYr == FiscalYr_Jul_Jun){
            if(month < 7){
                endDate =   Date.newinstance(Year,6,30);
            }else{
                endDate =   Date.newinstance(Year+1,6,30);
            }
        }
        cafApp.Limit_Calculation_End_Date__c = endDate;
        return cafApp;
    }
    
    public static gFRS_Ltng_CAF_Application__c setRuleForLimtCal(gFRS_Ltng_CAF_Application__c cafApp){
        
        String orgQtr = cafApp.Org_Quarter__c; 
        Date limtCalDate = cafApp.Date_for_Limit_Calculation__c; 
        String fiscalYr = cafApp.gFRS_Organization__r.Org_Fiscal_Year__c;
        String ruleVal = '';
        
		if(orgQtr == 'Q1'){
            if(fiscalYr == FiscalYr_Jan_Dec){
                if(limtCalDate.month() == 12){
                	ruleVal = 'Rule 2';
                }else{
                    ruleVal = 'Rule 3';
                }
            }else if(fiscalYr == FiscalYr_Jul_Jun){
                if(limtCalDate.month() == 6){
                	ruleVal = 'Rule 2';
                }else{
                    ruleVal = 'Rule 3';
                }
            }
        }        
        else if(orgQtr == 'Q2'){
            ruleVal = 'Rule 1';
        }        
        else if(orgQtr == 'Q3'){
            if(fiscalYr == FiscalYr_Jan_Dec){
                if(limtCalDate.month() == 6){
                	ruleVal = 'Rule 1';
                }else{
                    ruleVal = 'Rule 2';
                }
            }else if(fiscalYr == FiscalYr_Jul_Jun){
                if(limtCalDate.month() == 12){
                	ruleVal = 'Rule 1';
                }else{
                    ruleVal = 'Rule 2';
                }
            }
        }        
        else if(orgQtr == 'Q4'){
            ruleVal = 'Rule 2';
        }
        
		cafApp.Rule_Considered__c =  ruleVal;
        return cafApp;
    }
    
    public static gFRS_Ltng_CAF_Application__c setRevForLimtCal(gFRS_Ltng_CAF_Application__c cafApp){
        
        String rule = cafApp.Rule_Considered__c;
        Decimal ActRev_PrYr = cafApp.gFRS_Organization__r.Actual_Revenue_for_Prior_Fiscal_Y__c;
        Decimal ActRev_CrYr = cafApp.gFRS_Organization__r.Act_YTD_Annual_Revenue__c;
        Decimal ProjRev_CrYr = cafApp.gFRS_Organization__r.Proj_Ann_Rev_CrntYear__c;
        Decimal ProjRev_NxtYr = cafApp.gFRS_Organization__r.Proj_Annual_Revenue_Next_Fiscal_Year__c;
        String revenueConsider = '';
        Decimal revenue = 0.0;
        
        if(rule == 'Rule 1'){
            if(ProjRev_CrYr < ActRev_PrYr){
                revenueConsider = 'ProjRev_CrYr';
                revenue = ProjRev_CrYr;
            }else{
                revenueConsider = 'ActRev_PrYr';
                revenue = ActRev_PrYr;
            }
        }
        else if(rule == 'Rule 2'){
            revenueConsider = 'ActRev_CrYr';
            revenue = ActRev_CrYr;
        }
        else if(rule == 'Rule 3'){
            if(ProjRev_CrYr < ProjRev_NxtYr){
            	revenueConsider = 'ProjRev_CrYr';
				revenue = ProjRev_CrYr;          	
            }else{
                revenueConsider = 'ProjRev_NxtYr';
                revenue = ProjRev_NxtYr;
            }
        }
		cafApp.Revenue_Considered__c = revenueConsider;
		cafApp.Revenue__c = revenue;
        return cafApp;
    }
    
    public static gFRS_Ltng_CAF_Application__c setYTDAppAmtCopay(gFRS_Ltng_CAF_Application__c cafApp){
        
        Date startDate = cafApp.Limit_Calculation_Start_Date__c;
        Date endDate = cafApp.Limit_Calculation_End_Date__c;
        Id orgId = cafApp.gFRS_Organization__c;
        Id cafAppId = cafApp.Id;
        Decimal YTDApprovedAmtCopay = 0.0;
        
        List<gFRS_Ltng_CAF_Application__c> cafAppList = [SELECT Id, Name, Total_Apprv_Amount__c, Org_Quarter__c, Status__c, Internal_Sub_Status__c FROM gFRS_Ltng_CAF_Application__c
                                                        	WHERE Date_for_Limit_Calculation__c != NULL AND Date_for_Limit_Calculation__c >= :startDate AND Date_for_Limit_Calculation__c <= :endDate 
                                                         	AND Total_Apprv_Amount__c > 0 AND Internal_Sub_Status__c NOT IN ('Canceled','Denied')
                                                         	AND gFRS_Organization__c =: orgId ORDER BY Date_for_Limit_Calculation__c, Name ASC NULLS LAST];
        
        for(gFRS_Ltng_CAF_Application__c cafItm : cafAppList){
            YTDApprovedAmtCopay = YTDApprovedAmtCopay + cafItm.Total_Apprv_Amount__c;                
        }
        
        cafApp.YTD_Total_Approved_Amounts_Copay__c = YTDApprovedAmtCopay;
        cafApp.Stringified_Copay_Requests__c = JSON.serialize(cafAppList);
	    return cafApp;
    }
    
    public static gFRS_Ltng_CAF_Application__c setYTDAppAmtNonCopay(gFRS_Ltng_CAF_Application__c cafApp){
        //Not yet implemented.
        Date startDate = cafApp.Limit_Calculation_Start_Date__c;
        Date endDate = cafApp.Limit_Calculation_End_Date__c;
        Id orgId = cafApp.gFRS_Organization__c;
        Id cafAppId = cafApp.Id;
        Decimal YTDApprovedAmtNonCopay = 0.0;
        
        List<gFRS_Ltng_Application__c> appList = [SELECT Id, Name, Status__c, Sub_Status__c, Approved_Amount__c, Date_for_Limit_Calculation__c, Record_Type__c, Record_Type_Name__c FROM gFRS_Ltng_Application__c
                                                  	WHERE Date_for_Limit_Calculation__c != NULL AND Date_for_Limit_Calculation__c >= :startDate AND Date_for_Limit_Calculation__c <= :endDate 
                                                  	AND Approved_Amount__c > 0 AND Sub_Status__c NOT IN ('Canceled','Denied')
                                                    AND Record_Type__c IN ('Community Giving', 'Independent Medical Education (CME)', 'Patient and Health Focused Giving', 'Scientific and Research Focused Giving', 'Education Focused Giving K-12', 'Education Focused Giving Graduate and Post-Graduate')
                                                  	AND Organization__c =: orgId ORDER BY Date_for_Limit_Calculation__c, Name ASC NULLS LAST];
        
        for(gFRS_Ltng_Application__c appItm : appList){
            YTDApprovedAmtNonCopay = YTDApprovedAmtNonCopay + appItm.Approved_Amount__c;                
        }
        
        cafApp.YTD_Total_Amount_Non_Copay__c = YTDApprovedAmtNonCopay;
        cafApp.Stringified_Non_Copay_Requests__c = JSON.serialize(appList);
        return cafApp;
    }
    public static void submitForApprovalcopay(gFRS_Ltng_CAF_Application__c[] newRequests, Map < id, gFRS_Ltng_CAF_Application__c > oldRequests) {

        try {
            gFRS_Ltng_CAF_Application__c[] changedRequests = new gFRS_Ltng_CAF_Application__c[] {};
            gFRS_Ltng_CAF_Application__c[] changedRequestsFiltered = new gFRS_Ltng_CAF_Application__c[] {};

            gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Internal_Sub_Status__c', changedRequests);
            gFRS_Ltng_CAF_Application__c oldRequest = null;
            system.debug('changedRequests =>' + changedRequests);
            for (gFRS_Ltng_CAF_Application__c item: changedRequests) {

                if (oldRequests.containsKey(item.id)) {

                    /*oldRequest = oldRequests.get(item.Id);
                    if (oldRequest.Internal_Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_NEW &&
                        item.Internal_Sub_Status__c == gFRS_Utilcopay.REQUEST_SUB_STATUS_QCO) {
                        changedRequestsFiltered.add(item);
                    }*/


                    if (item.Funding_Approval_Step_Status__c == APPROVAL_SUBMITTED &&
                        item.Inside_Grant_CFO_Approval__c == 'NO' &&
                        item.Internal_Sub_Status__c == REQUEST_EXTERNAL_SUB_STATUS_CST_REVIEW) {
                        changedRequestsFiltered.add(item);
                    }
                }
            }
            if (changedRequestsFiltered.size() > 0) {
                
                List<gFRS_Ltng_CAF_Application__c> copayList = new List<gFRS_Ltng_CAF_Application__c>();

                for (gFRS_Ltng_CAF_Application__c f: changedRequestsFiltered) {


                    Approval.ProcessSubmitRequest approvalItem = new Approval.ProcessSubmitRequest();
                    approvalItem.setComments('Submitting request for approval.');
                    approvalItem.setObjectId(f.id);

                    // -- In case of rejection approval is submitted as owner rather than the rejected approver.
                    approvalItem.setSubmitterId(f.OwnerId);

                    //-- submit the approval
                    Approval.ProcessResult result = Approval.process(approvalItem);
                    //-- verify
                    if (!result.isSuccess()) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while sending request for submission.'));
                    }

                }
                
                update copayList;

            }
        } catch (Exception ex) {
            //System.assertEquals('Error',ex.GetMessage());
            string exMsg = ex.GetMessage();
            system.debug('submitForApproval error=>' + ex.GetMessage());
        }
    }
    public static Boolean saveLimtCalValues(gFRS_Ltng_CAF_Application__c cafApp){
        
        Decimal totalCopayYTDamt = cafApp.YTD_Total_Approved_Amounts_Copay__c;
        Decimal totalNonCopayYTDamt = cafApp.YTD_Total_Amount_Non_Copay__c;
        //Decimal reqTotalAprvAmt = cafApp.Total_Apprv_Amount__c + cafApp.Total_Payment_Amount_Rollup__c;
        Decimal revenue = cafApp.Revenue__c;
        
        Decimal YTDtotalDonations =  totalCopayYTDamt +  totalNonCopayYTDamt;// + reqTotalAprvAmt;
        Decimal limitPercent = YTDtotalDonations/revenue * 100;
        Decimal donationLimit = 0.33 * revenue;
        Decimal donationRemaining = donationLimit - YTDtotalDonations;
        
        cafApp.YTD_Total_Approved_Donations__c = YTDtotalDonations;
        cafApp.Estimated_Current_Revenue__c = limitPercent;
        cafApp.Estimated_Donation_Limit__c = donationLimit;
        cafApp.Estimated_Remaining_Donation_Limit__c = donationRemaining;        
		update cafApp;
        
        gFRS_Ltng_Organization__c cafOrg = [select id, X33_Limit_Percentage_Hybrid__c from gFRS_Ltng_Organization__c where id =: cafApp.gFRS_Organization__c LIMIT 1];
        cafOrg.X33_Limit_Percentage_Hybrid__c = limitPercent;
        update cafOrg;
        
        return true;
    }
    
    @AuraEnabled
    public static gFRS_Ltng_CAF_Application__c[] getCAFList(Id recordId){
        
        gFRS_Ltng_CAF_Application__c cafApp = [SELECT Id, Stringified_Copay_Requests__c  FROM gFRS_Ltng_CAF_Application__c WHERE ID = :recordId];
        List<gFRS_Ltng_CAF_Application__c> cafAppList = new List<gFRS_Ltng_CAF_Application__c>();
        if(cafApp.Stringified_Copay_Requests__c != null){
        	cafAppList = (List<gFRS_Ltng_CAF_Application__c>) JSON.deserialize(cafApp.Stringified_Copay_Requests__c, List<gFRS_Ltng_CAF_Application__c>.class); 
        }
        
        return cafAppList;
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c[] getAppList(Id recordId){
        
        gFRS_Ltng_CAF_Application__c cafApp = [SELECT Id, Stringified_Non_Copay_Requests__c  FROM gFRS_Ltng_CAF_Application__c WHERE ID = :recordId];
        List<gFRS_Ltng_Application__c> appList = new List<gFRS_Ltng_Application__c>();
        if(cafApp.Stringified_Non_Copay_Requests__c != null){
            appList = (List<gFRS_Ltng_Application__c>) JSON.deserialize(cafApp.Stringified_Non_Copay_Requests__c, List<gFRS_Ltng_Application__c>.class); 
        }
        
        return appList;
    }
    
    @AuraEnabled
    public static gFRS_Ltng_CAF_Application__c getCAFApp(Id appId){
    	gFRS_Ltng_CAF_Application__c cafApp = [SELECT id,Donation_Requested_for_Quarter_Check__c,DS_Other_Please_specify__c,gFRS_Organization__r.Act_YTD_Annual_Revenue__c, gFRS_Organization__r.Proj_Annual_Revenue_Next_Fiscal_Year__c, Donation_Requested_for_Quarter_CreatedDt__c,
                                                gFRS_Organization__r.Proj_Ann_Rev_CrntYear__c, gFRS_Organization__r.Actual_Revenue_for_Prior_Fiscal_Y__c, gFRS_Organization__r.Id, 
       											gFRS_Organization__r.Org_Fiscal_Year__c, gFRS_Ltng_CAF_Application__c.Acknowledge_Submit__c, Status__c, SelectedTab__c,Information_Needed__c,RFI_Previous_Status__c,RFI_Previous_Sub_Status__c,RFI_Previous_External_Status__c, 
                                                (Select Id, Disease_Fund_Name__c, Fund_Type__c, Requested_Donation_Amount__c, Time_Frame_for_Requested_Donation__c from gFRS_CAF_Disease_State__r)
                                                FROM gFRS_Ltng_CAF_Application__c  WHERE Id= :appId];
        return cafApp;
    }
    
    @AuraEnabled
    public static void deleteAttachment(Id attchId, string attchmentName,Id parentId) {
        try{            
            System.debug('-attchId->'+attchId);
            System.debug('-attchmentName->'+attchmentName);
            System.debug('-parentId->'+parentId);
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =:attchId]; 
            delete entries;            
            
            gFRS_Ltng_CAF_Application__c objApp = [SELECT id, Addition_Document_2__c,Addition_Document_3__c,OIG_Opinion_Attchmnt__c, Program_Audit_Attachment__c, Addition_Document_1__c FROM gFRS_Ltng_CAF_Application__c WHERE id=: parentId LIMIT 1];
            
            if(attchmentName == 'file1'){
                objApp.id = parentId;
                objApp.OIG_Opinion_Attchmnt__c = '';
            }else if(attchmentName == 'file2'){
                objApp.id = parentId;
                objApp.Program_Audit_Attachment__c = '';
            }else if(attchmentName == 'file3'){
                objApp.id = parentId;
                objApp.Addition_Document_1__c = '';
            }else if(attchmentName == 'file4'){
                objApp.id = parentId;
                objApp.Addition_Document_2__c = '';
            }else if(attchmentName == 'file5'){
                objApp.id = parentId;
                objApp.Addition_Document_3__c = '';
            }
            
            upsert objApp;
            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }  
    public class fileResWrapper{        
        @AuraEnabled public String file1{get;set;} 
        @AuraEnabled public Id file1Id{get;set;} 
        @AuraEnabled public String file2{get;set;}
        @AuraEnabled public Id file2Id{get;set;} 
        @AuraEnabled public String file3{get;set;}
        @AuraEnabled public Id file3Id{get;set;} 
        @AuraEnabled public String file4{get;set;}
        @AuraEnabled public Id file4Id{get;set;} 
        @AuraEnabled public String file5{get;set;}
        @AuraEnabled public Id file5Id{get;set;} 
        @AuraEnabled public String fileType1{get;set;}
        @AuraEnabled public String fileType2{get;set;}
        @AuraEnabled public String fileType3{get;set;}
        @AuraEnabled public String fileType4{get;set;}
        @AuraEnabled public String fileType5{get;set;}
    }
    
   @AuraEnabled
    public static fileResWrapper getAttachmentDetails(String appId) {
        fileResWrapper filewp = new fileResWrapper();
        try{
		    gFRS_Ltng_CAF_Application__c objApp=[SELECT id,Addition_Document_2__c,Addition_Document_3__c,OIG_Opinion_Attchmnt__c,Program_Audit_Attachment__c,Addition_Document_1__c from gFRS_Ltng_CAF_Application__c  where Id=:appId] ;
            system.debug('attList'+objApp);
            system.debug('objApp.OIG_Opinion_Attchmnt__c>>'+objApp.OIG_Opinion_Attchmnt__c);
            if(String.isNotBlank(objApp.OIG_Opinion_Attchmnt__c)){
                System.debug('coming');
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.OIG_Opinion_Attchmnt__c]; 
                system.debug('file1'+a.Title);
                filewp.file1 = a.Title;
                filewp.file1Id = a.Id;
                filewp.fileType1=a.FileType;
            }System.debug('i am working');
            if(String.isNotBlank(objApp.Program_Audit_Attachment__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Program_Audit_Attachment__c]; 
                filewp.file2 = a.Title;
                filewp.file2Id = a.Id;
                filewp.fileType2=a.FileType;
                system.debug('file2'+a.Title);
            } if(String.isNotBlank(objApp.Addition_Document_1__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Addition_Document_1__c]; 
                filewp.file3 = a.Title;
                filewp.file3Id = a.Id;
                filewp.fileType3=a.FileType;
                system.debug('file3'+a.Title);
            }if(String.isNotBlank(objApp.Addition_Document_2__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Addition_Document_2__c]; 
                filewp.file4 = a.Title;
                filewp.file4Id = a.Id;
                filewp.fileType4=a.FileType;
                system.debug('file4'+a.Title);
            }if(String.isNotBlank(objApp.Addition_Document_3__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Addition_Document_3__c]; 
                filewp.file5 = a.Title;
                filewp.file5Id = a.Id;
                filewp.fileType5=a.FileType;
                system.debug('file5'+a.Title);
            }
            System.debug('filewp>>'+filewp);
            return filewp;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    @AuraEnabled
    public static Id updateApplicationRecd (Id parentId, Id docId, string typOfFile, string contentType) {
        try{ 
            gFRS_Ltng_CAF_Application__c objApp =new gFRS_Ltng_CAF_Application__c();
            	objApp.Id=parentId;                   
                    if(typOfFile == 'file1'){
                        objApp.id = parentId;
                        objApp.OIG_Opinion_Attchmnt__c = docId;
                    }else if(typOfFile == 'file2'){
                        objApp.id = parentId;
                        objApp.Program_Audit_Attachment__c = docId;
                    }else if(typOfFile == 'file3'){
                        objApp.id = parentId;
                        objApp.Addition_Document_1__c = docId;
                    }else if(typOfFile == 'file4'){
                        objApp.id = parentId;
                        objApp.Addition_Document_2__c = docId;
                    }else if(typOfFile == 'file5'){
                        objApp.id = parentId;
                        objApp.Addition_Document_3__c = docId;
                    }
                 update objApp;
            		return docId;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
	 @AuraEnabled
    public static List<gFRS_CAF_Disease_State__c> getCAFDonation(Id appId){
        List<gFRS_CAF_Disease_State__c> lstdis=[select Id,gFRS_CAF_Application__c,Disease_Fund_Name__c,Fund_Type__c,Requested_Donation_Amount__c,Time_Frame_for_Requested_Donation__c from gFRS_CAF_Disease_State__c where gFRS_CAF_Application__c=:appId];
        return lstdis;
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