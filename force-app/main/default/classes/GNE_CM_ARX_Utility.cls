global class GNE_CM_ARX_Utility {
    
    //variables
    public static Set<String> envVarNameSet = new Set<String>{GNE_CM_MPS_Utils.GNE_CM_MPS_ARX_ESIGN_INVITE, GNE_CM_MPS_Utils.GNE_CM_MPS_ARX_EPAN, GNE_CM_MPS_Utils.GNE_CM_MPS_ARX_ESIGN_ENDPOINT};
    public static Map<String, List<Environment_Variables__c>> envVarMultiValues;
    
    public static String createPANTracking(String case_id, String per_id, String PANMethod, String PANOperation) 
    {
        String transaction_id = '';
        try
        {
            GNE_CM_MPS_ARX_EPAN_MANAGEMENT__c epanMgmtRec = new GNE_CM_MPS_ARX_EPAN_MANAGEMENT__c();
            if(case_id != null && case_id.trim() != ''){
                epanMgmtRec.case__c = case_id;
                if(PANOperation=='CMGT INVITE')
                	epanMgmtRec.PAN_Origin_MPS__c='CMGT Case Invitation';
                else if(PANOperation=='MPS CASE INVITE')
                	epanMgmtRec.PAN_Origin_MPS__c='MPS Case Invitation';
                else if(PANOperation=='MPS CASE SUBMIT')	
                	epanMgmtRec.PAN_Origin_MPS__c='MPS Case Submit Now';
    
            }
            if(per_id != null && per_id.trim() != ''){
                epanMgmtRec.Patient_Enrollment_Request__c = per_id;
                if(PANOperation=='MPS PER INVITE')
                	epanMgmtRec.PAN_Origin_MPS__c='MPS PER Invitation';
                else if(PANOperation=='MPS PER SUBMIT') 
                	epanMgmtRec.PAN_Origin_MPS__c='MPS PER Submit Now';
            }
            epanMgmtRec.PAN_Status__c = 'NEW'; //Always
            epanMgmtRec.Status_Description__c = PANMethod;
             
            List<GNE_CM_MPS_ARX_EPAN_MANAGEMENT__c> epanMgmtRecList = new List<GNE_CM_MPS_ARX_EPAN_MANAGEMENT__c>();
            epanMgmtRecList.add(epanMgmtRec);
            Database.SaveResult[] lsr=Database.insert(epanMgmtRecList, false);
            for(Database.SaveResult sr:lsr){
                if(!sr.isSuccess())
                Database.Error err = sr.getErrors()[0];
            }
           // insert epanMgmtRec;
            transaction_id = epanMgmtRecList[0].Id;
        }
        catch(Exception ex)
        {
            system.debug('Inside catch----->'+ ex);   
            Error_Log_gne__c error = GNE_CM_MPS_Utils.createError('GNE_CM_MPS_ARX_Utility', 'High', 'createPANTracking', 'Apex Webservice', ex);
            system.debug('error----->'+error);   
            insert error;
            system.debug('transaction_id---->'+transaction_id);
            return transaction_id;
        }
        return transaction_id; 
    }
    //Change this method to change the return Type to String. After Insert, the Record Id is sent back to Apex class 
    public static String eSMNTracking(List<String> eSMNResult, String transactionId) 
    {
        try
        {
            if(transactionId == '')
            {
                GNE_CM_MPS_ARX_ESMN_MANAGEMENT__c esmnMgmtRec = new GNE_CM_MPS_ARX_ESMN_MANAGEMENT__c();   
                esmnMgmtRec.SMN_Status__c = eSMNResult[0];
                esmnMgmtRec.Spring_CM_Document_Id__c = eSMNResult[1];
                esmnMgmtRec.Status_Description__c = eSMNResult[2];
                esmnMgmtRec.Patient_Enrollment_Request__c = eSMNResult[3];
                insert esmnMgmtRec;
                return esmnMgmtRec.id;
            }
            else
            {
                List<GNE_CM_MPS_ARX_ESMN_MANAGEMENT__c> esmnMgmt =[select id,SMN_Status__c,Status_Description__c,Patient_Enrollment_Request__c,Spring_CM_Document_Id__c 
                    from GNE_CM_MPS_ARX_ESMN_MANAGEMENT__c where id=:transactionId AND Patient_Enrollment_Request__c =:eSMNResult[3]];
        
                if(esmnMgmt !=null && esmnMgmt.size() > 0)
                {
                    //esmnMgmt.Patient_Enrollment_Request__c=smnTracking.per_id;
                    esmnMgmt[0].SMN_Status__c = eSMNResult[0];
                    esmnMgmt[0].Status_Description__c = eSMNResult[2];
                    esmnMgmt[0].Spring_CM_Document_Id__c = eSMNResult[1];
                    update esmnMgmt;
                }
                return transactionId;
            }
          
        }
        catch(Exception ex)
        {
            Error_Log_gne__c error = GNE_CM_MPS_Utils.createError('GNE_CM_MPS_ARX_Utility', 'High', 'eSMNTracking', 'Apex Webservice', ex);            
            insert error;
            return '';            
        }
      
    }
    
    
    // Method for collecting all required information and creating the callout for inviting Prescribers for eSignature Registration with AssistRx
    public static String eSignInvitation()
    {
        String eSignInviteURL;
        string userid = Userinfo.getuserid();
        envVarMultiValues = GNE_CM_MPS_Utils.populateEnvVariables(envVarNameSet);
        List<Environment_Variables__c> envVarList = envVarMultiValues.get(GNE_CM_MPS_Utils.GNE_CM_MPS_ARX_ESIGN_INVITE);
        List<User> user_Info = new List<User>([Select Contact.AccountId From User where Id =: userid limit 1]);
        String accIdUser = user_Info[0].Contact.Accountid; //'001Q000000Q2WHs';
        String sessionID = UserInfo.getSessionId();
        String encodedSessionId = EncodingUtil.urlEncode(sessionID, 'UTF-8');
        eSignInviteURL = (envVarList[0].value__c + '/invitation/mpsuser/' + accIdUser + '/sfsession/' + encodedSessionId + '/');
        system.debug('URL::: ' + eSignInviteURL);
        return eSignInviteURL;  
    }
    
    // Method for collecting all required information and creating the callout for initiating the eSignature process with AssistRx
    //New Parameter is added to call the new Webservice method on 30 Nov 11
    public static List<String> eSMNSignature(String patenrolId,String transaction_id)
    {
        string userid = Userinfo.getuserid();
        List<String> ResultList = new List<String>();
        List<User> user_Info = new List<User>([Select Contact.AccountId From User where Id =: userid limit 1]);
        String accIdUser = user_Info[0].Contact.Accountid; //'001Q000000Q2WHs';
        String sessionID = UserInfo.getSessionId();
        String encodedSessionId = EncodingUtil.urlEncode(sessionID, 'UTF-8');
        String SMNStatus = 'ERROR';
        String SMNDocumentId = '';
        String SMNStatusDesc = 'NO RESPONSE FROM ARX';
        String SMNTrackignID=transaction_id;
            
        try
        {
           
            GNE_CM_ARX_eSignWebservice.AssistRx_SMN_SoapPort arxSMNWS = new  GNE_CM_ARX_eSignWebservice.AssistRx_SMN_SoapPort();
            GNE_CM_ARX_eSignWebservice.ProcessDocumentResponseType arxSMNResponse = new GNE_CM_ARX_eSignWebservice.ProcessDocumentResponseType();
          
            arxSMNWS.timeout_x = 60000; //timeout in milliseconds
            //Method call is changed to add a new parameter on 30 Nov 11
            arxSMNResponse = arxSMNWS.ProcessDocument(accIdUser, sessionID, patenrolId,transaction_id);
            SMNStatus = arxSMNResponse.Status;
            SMNDocumentId = arxSMNResponse.DocumentId;
            SMNStatusDesc = arxSMNResponse.StatusDescription;
            ResultList.add(SMNStatus);
            ResultList.add(SMNDocumentId);
            ResultList.add(SMNStatusDesc);
            ResultList.add(patenrolId);
            ResultList.add(transaction_id);
            system.debug('STATUS:::: ' + SMNStatus + ' :::DOC ID::: ' + SMNDocumentId + ' :::DESC::: ' + SMNStatusDesc + 'PER ID::: ' + patenrolId);
            return ResultList;
        }
        catch(exception e)
        {
            ResultList.add(SMNStatus);
            ResultList.add(SMNDocumentId);
            ResultList.add(SMNStatusDesc);
            ResultList.add(patenrolId);
            ResultList.add(transaction_id);
            GNE_CM_ARX_Utility.eSMNTracking(ResultList, transaction_id);
            Error_Log_gne__c error = GNE_CM_MPS_Utils.createError('GNE_CM_MPS_ARX_Utility', 'High', 'eSMNSignature', 'Apex Webservice', e);
            insert error;
            return ResultList;            
        }
        
    }
    // Method for collecting all required information and creating the callout for inviting the patient for ePAN process with AssistRx
   
    public static String ePANInvite(String objectId, String ObjectName)
    { 
        String ePANURL = '';
        envVarMultiValues = GNE_CM_MPS_Utils.populateEnvVariables(envVarNameSet);
        List<Environment_Variables__c> envVarList = envVarMultiValues.get(GNE_CM_MPS_Utils.GNE_CM_MPS_ARX_EPAN);
        if(ObjectName == 'PER')
        {
            String ePANTrackingId = GNE_CM_ARX_Utility.createPANTracking('', ObjectId, 'ePAN Invite Initiated for PER from MPS','MPS PER INVITE');
            ePANURL = envVarList[0].value__c + '/epan/tagged/enrollment/' + ObjectId + '/transactionId/' + ePANTrackingId + '/';
            system.debug('EPAN LINK::: ' + ePANURL);
            return ePANURL;
        }
        else
        {
            String ePANTrackingId = GNE_CM_ARX_Utility.createPANTracking(objectId, '', 'ePAN Invite Initiated for Case from MPS','MPS CASE INVITE');
            ePANURL = envVarList[0].value__c + '/epan/tagged/case/' + ObjectId +'/transactionId/' + ePANTrackingId + '/';
            system.debug('EPAN LINK::: ' + ePANURL);
            return ePANURL;
        }
    }
   
    // Web service Method for Case collecting all required information and creating the callout for inviting the patient for ePAN process with AssistRx
    
     webservice static String ePANCaseInvite(String objectId, String ObjectName)
	    { 
	        String ePANURL = '';
	        envVarMultiValues = GNE_CM_MPS_Utils.populateEnvVariables(envVarNameSet);
	        List<Environment_Variables__c> envVarList = envVarMultiValues.get(GNE_CM_MPS_Utils.GNE_CM_MPS_ARX_EPAN);
	        if(ObjectName == 'PER')
	        {
	            String ePANTrackingId = GNE_CM_ARX_Utility.createPANTracking('', ObjectId, 'ePAN Invite Initiated for PER', 'invite');
	            ePANURL = envVarList[0].value__c + '/epan/tagged/enrollment/' + ObjectId + '/transactionId/' + ePANTrackingId + '/';
	            system.debug('EPAN LINK::: ' + ePANURL);
	            return ePANURL;
	        }
	        else
	        {
	            String ePANTrackingId = GNE_CM_ARX_Utility.createPANTracking(objectId, '', 'ePAN Invite Initiated for Case from CMGT', 'CMGT INVITE');
	            ePANURL = envVarList[0].value__c + '/epan/tagged/case/' + ObjectId +'/transactionId/' + ePANTrackingId + '/';
	            system.debug('EPAN LINK::: ' + ePANURL);
	            return ePANURL;
	        }
	    }
    
    // Method for collecting all required information and creating the callout for initiating the ePAN process with AssistRx   
    public static String ePANSubmitNow(String ObjectId, String ObjectName)
    {
        String ePANURL = '';
        String ePANTrackingId='';
        String uniqueTransId = ObjectId+System.currenttimeMillis();
        envVarMultiValues = GNE_CM_MPS_Utils.populateEnvVariables(envVarNameSet);
        List<Environment_Variables__c> envVarList = envVarMultiValues.get(GNE_CM_MPS_Utils.GNE_CM_MPS_ARX_EPAN);
        if(ObjectName == 'PER')
        {
             ePANTrackingId = GNE_CM_ARX_Utility.createPANTracking('', ObjectId, 'ePAN Submit Now Initiated for PER from MPS','MPS PER SUBMIT');
             ePANURL = envVarList[0].value__c + '/epan/tagged/enrollment/' + ObjectId +'/displayform' + '/transactionId/' + ePANTrackingId;
        }
        else
        {
             ePANTrackingId = GNE_CM_ARX_Utility.createPANTracking(ObjectId, '', 'ePAN Submit Now Initiated for Case from MPS','MPS CASE SUBMIT');
             ePANURL = envVarList[0].value__c + '/epan/tagged/case/' + ObjectId +'/displayform' + '/transactionId/' + ePANTrackingId;
        }
        //ePANURL = envVarList[0].value__c + '/epan/tagged/enrollment/' + ObjectId +'/displayform' + '/transactionId/' + ePANTrackingId; 
        
        system.debug('EPAN LINK::: ' + ePANURL);
        return ePANURL;
    }
    
    
    

}