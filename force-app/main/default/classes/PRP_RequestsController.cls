/**
* @author Venky Kambham
* @date 3/25/21
* @description Handles PRP_Request related actions.
**/
public with sharing class PRP_RequestsController {
    //PRP_Home VF page variables
    public Boolean showLWCPanel {get;set;}
    public Boolean showUpdatePanel {get;set;}
    public String requestType {get;set;}
    public String requestNumber {get;set;}
    public String submissionNumber {get;set;}
    public String submitterEmail {get;set;}
    public String greCaptchaKey {get;set;}
    public Boolean isCaptchaVerified {get;set;}
    public String messageType {get;set;}
    public Boolean showReCaptcha {get;set;}
    public Boolean newRequest {get;set;}
    public Boolean updateRequest {get;set;}
    public Boolean transferRequest {get;set;}
    public Boolean displaySigningAuthority {get;set;} 
    public Boolean displaySubmitterInfo {get;set;}
    public Boolean displayNoticesToBeAddressed {get;set;}
    public Boolean displayPaymentInfo {get;set;}
    
    //PRP_Home,PRP_RequestSummaryPDF VF page variable
    public PRP_Request__c request {get;set;}
    public List<PRP_Site__c> addtnlSites{get;set;}
    public List<ContentDocumentLink> docsUpl{get;set;}
    public List<PRP_Additional_Contact__c> prpAddtnlContacts{get;set;}
    
    //Constants
    public static final String RT_NEW_REQUEST = 'PRP_New_Request';
    public static final String RT_UPDATE_REQUEST = 'PRP_Update_Request';
    public static final String RT_TRANSFER_REQUEST = 'PRP_Transfer_Request';
    public static final String REQUEST_TYPE_NEW = 'New Request';
    public static final String REQUEST_TYPE_UPDATE = 'Update Information';
    public static final String REQUEST_TYPE_TRANSFER = 'Transfer and / or Terminate';
    public static final String SIT_PRODUCTS = 'siteProducts';
    public static final String FIELD_API_PRODUCTS = 'Products__c';
    public static final String SEMICOLON = ';';
    public static final String COMMA = ',';
    public static final String COLON = ':';
    public static final String ADD_SITE = 'Add';
    public static final String REMOVE_SITE = 'Remove';
    public static final String BEM_IS_NOT_ACTIVE = 'BEM you entered is not active. Only active BEM\'s are allowed.';
    public static final String PROSPECTIVE_TERMINATION_DATE = 'Prospective_Termination_Date__c';
    public static final String IS_DEFAULT_SITE = 'Is_Default_Site__c';
    public static final String PRP_ACCOUNT_RT = 'Provider_Rebate_Program';
    public static final String RANDOM_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    public static final String PRFIX_GNE = 'GNE-';
    public static final String PRODUCT_OCREVUS = 'Ocrevus';
    public static final Integer RANDOM_CHARS_LENGTH = 6;
    public static List<String> siteFields = new List<String> {'siteProducts'}; 
                
    public PRP_RequestsController()
    {
        Map<String,String> pageParams = ApexPages.currentPage().getParameters();
        //PRP_Home VF page related
        
        showLWCPanel = false;
        showReCaptcha = false;
        showUpdatePanel = pageParams.containsKey('update') && pageParams.get('update') == 'true';
        List<PRP_Request__c> requests = new List<PRP_Request__c> ();
        List<PRP_Site_Request__c> siteRequests = new List<PRP_Site_Request__c>();
        List<PRP_Request_Contact__c> contactRequests = new List<PRP_Request_Contact__c>();
        prpAddtnlContacts = new List<PRP_Additional_Contact__c> ();
        addtnlSites = new List<PRP_Site__c>();
        docsUpl = new List<ContentDocumentLink>();
        Set<Id> siteIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        //PRP_RequestSummaryPDF VF page related
        String requestId = pageParams.containsKey('id') ? pageParams.get('id') : '';
        System.debug('Controller - requestId: ' + requestId);
        
        if (String.isNotBlank(requestId)) {
            requests = new PRP_RequestsController_WOS().getRequest(requestId);
            docsUpl = new PRP_RequestsController_WOS().docsUploaded(requestId);
        }
        
        if (!requests.isEmpty())
        {
            request = requests[0];

            //Get Additional Contact Information 
            if (request.PRP_Request_Contacts__r != null) 
            {
                contactRequests.addAll(request.PRP_Request_Contacts__r);
            }

            if (contactRequests?.size() > 0)
            {
                for (PRP_Request_Contact__c cr:contactRequests)
                {
                    contactIds.add(cr.Additional_Contact__c);
                }
            }
            prpAddtnlContacts = new PRP_RequestsController_WOS().getAdditionalContacts(contactIds);
            
            //Get Additional Location Information 
            siteRequests = request.PRP_Site_Requests__r;
            if (siteRequests?.size() > 0) 
            {
                for (PRP_Site_Request__c sr:siteRequests)
                {
                    siteIds.add(sr.site__c);
                }
            }
            addtnlSites = new PRP_RequestsController_WOS().getAdditionalSites(siteIds);

            handleSectionsDisplay(request);
            
            Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+request.Name+'.pdf');
        }
        
        //Get Google ReCaptcha Data site key
        C_Ops_LOC_App_Properties__c gprops = new PRP_RequestsController_WOS().getGReCaptchaDetails();
        if (gprops != null) 
        {
            greCaptchaKey = gprops.GClient__c;
            showReCaptcha = gprops.Active__c;
        }
    }
    
    /**
    * @author Venky Kambham
    * @date 6/17/21
    * @description Processes the user input from PRP_Home page and shows the prp_home lwc.
    **/
    private void handleSectionsDisplay(PRP_Request__c prp)
    {
        
        if (String.isNotBlank(request.Request_Type__c))
        {
            if (request.Request_Type__c == 'Transfer and / or Terminate')
            {
                transferRequest = true;
                updateRequest = false;
                newRequest = false;
            } 
            else if (request.Request_Type__c == 'Update Information') 
            {
                updateRequest = true;
                newRequest = false;
                transferRequest = false;
            } 
            else 
            {
                newRequest = true;
                transferRequest = false;
                updateRequest = false;
            }
        }
        
        if (transferRequest == true)
        {
            displaySubmitterInfo = true;
            displaySigningAuthority = false;
            displayNoticesToBeAddressed = false;
            displayPaymentInfo = false;
        }
        else if (updateRequest == true)
        {
            displaySubmitterInfo = true;
            displaySigningAuthority = false;
            if(request.Update_Notice_Address__c == true){
                displayNoticesToBeAddressed = true;
            }else{
                displayNoticesToBeAddressed = false;
            }
            if(request.Update_Payment_Information__c == true){
                displayPaymentInfo = true;
            }else{
                displayPaymentInfo = false;
            }
            
        } 
        else if (newRequest = true)
        {
            displaySubmitterInfo = true;
            displaySigningAuthority = true;
            displayNoticesToBeAddressed = true;
            displayPaymentInfo = true;
        }
    }
    
    /**
    * @author Venky Kambham
    * @date 6/17/21
    * @description Processes the user input from PRP_Home page and shows the prp_home lwc.
    **/
    public Pagereference handleRequest()
    {
        request = null;
        showLWCPanel = false;
        messageType = '';
        isCaptchaVerified = true;
        
        if (showUpdatePanel)
        {
            if (String.isBlank(submissionNumber) || String.isBlank(submitterEmail) || !isCaptchaVerified)
            {
                showMessage('error','Please fill in all the required fields.');
                return null;
            }
            
            List<PRP_Request__c> requests = new PRP_RequestsController_WOS().getRequest(submissionNumber, submitterEmail);
            System.debug('requests at update: ' + requests);
            
            if (requests.isEmpty())
            {
                showMessage('error','Information entered does not match the original request.');
                return null;
            } 
            
            request = requests[0];
            if (request != null && request.PRP_Site_Requests__r != null)
            {
                addtnlSites = new PRP_RequestsController_WOS().getAddtnlSites(request.PRP_Site_Requests__r);
            }
            
            if (request.Request_Type__c == 'Transfer and / or Terminate')
            {
                requestType =  'Transfer Request';    
            }
            else if (request.Request_Type__c == 'Update Information')
            {
                requestType =  'Update Request';    
            }
            else
            {
                requestType = request.Request_Type__c;
            }
        }
        else
        {
            if (String.isBlank(requestType) || !isCaptchaVerified)
            {
                showMessage('error','Please fill in all the required fields.');
                return null;
            }
        } 
        showLWCPanel = true;
        
        return null;
    }
    
    /**
    * @author Venky Kambham
    * @date 6/21/21
    * @description Fetch PRP request based on request number and submitter's email.
    **/
    @RemoteAction
    public static PRP_FetchRequestWrapper fetchRequest(String subId, String submitterEmail)
    {
        System.debug('fetchRequest@@@@ Submission Number: ' + subId + 'submitterEmail: ' + submitterEmail);
        Boolean isInRevisionStatus = false;
        PRP_FetchRequestWrapper wrapper = new PRP_FetchRequestWrapper();
        Set<Id> contactIds = new Set<Id>();
        List<PRP_Site_Request__c> siteRequests = new List<PRP_Site_Request__c>();
        List<PRP_Request_Contact__c> contactRequests = new List<PRP_Request_Contact__c>();
        List<PRP_Additional_Contact__c> addtnlContacts = new List<PRP_Additional_Contact__c> ();
        List<PRP_Request__c> requests = new PRP_RequestsController_WOS().getRequest(subId, submitterEmail);
        
        if (requests?.size() > 0)
        {
            for (PRP_Request__c req:requests) {
                if (req.Request_Status__c == 'In Revision') 
                {
                    isInRevisionStatus = true;
                }
            }
            
            if (isInRevisionStatus) 
            {
                for (PRP_Request__c req:requests) 
                {
                    if (String.isNotBlank(req.Legal_Name__c)) {
                        String unescasepedLegalName = req.Legal_Name__c.unescapeHtml4();
                        req.Legal_Name__c = unescasepedLegalName;
                    }

                    if (req.PRP_Site_Requests__r != null) 
                    {
                        siteRequests.addAll(req.PRP_Site_Requests__r);
                    }
                    
                    if (req.PRP_Request_Contacts__r != null) 
                    {
                        contactRequests.addAll(req.PRP_Request_Contacts__r);
                    }
                }
                
                if (contactRequests?.size() > 0)
                {
                    for (PRP_Request_Contact__c cr:contactRequests)
                    {
                        contactIds.add(cr.Additional_Contact__c);
                    }
                }
                
                wrapper.requests.addAll(requests);
                wrapper.siteRequests.addAll(siteRequests);
                
                if (siteRequests?.size() > 0) 
                {
                    wrapper.addtnlSites = new PRP_RequestsController_WOS().getAddtnlSites(siteRequests);
                } 
                
                if (contactRequests?.size() > 0) 
                {
                    wrapper.addtnlContacts = new PRP_RequestsController_WOS().getAdditionalContacts(contactIds);
                }
            } else {
                //Initialize wrapper with null values
                wrapper.requests = null;
                wrapper.siteRequests = null;
                wrapper.addtnlSites = null;
                wrapper.addtnlContacts = null;
            }
        } else {
            //Initialize wrapper with null values
            wrapper.requests = null;
            wrapper.siteRequests = null;
            wrapper.addtnlSites = null;
            wrapper.addtnlContacts = null;
        }
        
        System.debug('Fetch wrapper: ' + wrapper); 
        
        return wrapper;
    }
    
    /**
    * @author Venky Kambham
    * @date 6/21/21
    * @description Show VF page messages.
    **/
    public void showMessage(String type, String msg)
    {
        messageType = type;
        ApexPages.Message message;
        
        if (messageType == 'success') message = new ApexPages.Message(ApexPages.Severity.CONFIRM,msg);
        if (messageType == 'error') message = new ApexPages.Message(ApexPages.Severity.ERROR,msg);
        if (messageType == 'info') message = new ApexPages.Message(ApexPages.Severity.INFO,msg);
        ApexPages.addMessage(message);
    }
    
    /**
    * @author Venky Kambham
    * @date 4/14/21
    * @description Get PRP Request record based on Request Number and Submitter's email.
    **/
    @AuraEnabled
    public static PRP_Request__c getRequest(String requestNumber, String submitterEmail) {
        try
        {
            List<PRP_Request__c> requests = new PRP_RequestsController_WOS().getRequest(requestNumber,submitterEmail);
            System.debug('requests at update: ' + requests);
            if (!requests.isEmpty()) return requests[0];
            return null;
        }
        catch(Exception e)
        {
            System.debug('Error*** '+e.getMessage()+' @ '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @author Venky Kambham
    * @date 3/25/21
    * @description Get Picklist options of fields of PRP Request object.
    **/
    @AuraEnabled
    public static Map<String,String> getPicklistValues(String fieldAPIName)
    {
        Map<String,String> pickListValuesMap = new Map<String,String>();
        
        Schema.DescribeSObjectResult objResult = PRP_Request__c.sObjectType.getDescribe();
        Schema.DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldAPIName).getDescribe();
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry pickListVal : pickListEntries)
        {
            if (pickListVal.isActive())
            {
                pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
        }
        
        return pickListValuesMap;
    }

    /**
    * @author Palani Jayachandran
    * @date 6/6/23
    * @description Get Picklist options of fields of PRP Sites object.
    **/
    @AuraEnabled
    public static Map<String, String> getSitePicklistValues(String fieldAPIName)
    {
        Map<String, String> pickListValuesMap = new Map<String, String>();
        
        Schema.DescribeSObjectResult objResult = PRP_Site__c.sObjectType.getDescribe();
        Schema.DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldAPIName).getDescribe();
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry pickListVal : pickListEntries)
        {
            if (pickListVal.isActive())
            {
                pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
        }
        
        return pickListValuesMap;
    }
    
    /**
    * @author Venky Kambham
    * @date 3/25/21
    * @description Get list of active BEMs.
    **/
    @AuraEnabled
    public static Map<String,Object> getBEMs()
    {
        Map<String,Object> pickListValuesMap = new Map<String,Object>();
        
        for (PRP_BEM__c bem : new PRP_RequestsController_WOS().getBEMs())
        {
            pickListValuesMap.put(bem.Id, bem);
        }
        
        return pickListValuesMap;
    }

    /**
    * @author Palani Jayachandran
    * @date 8/22/21
    * @description Check Account ID.
    **/
    @AuraEnabled
    public static Boolean checkAccountID(String prpCustomAccountId)
    {
        System.debug('Account ID: ' + prpCustomAccountId);
        return new PRP_RequestsController_WOS().getPRPAccountDetails(prpCustomAccountId);
    }
    
    
    /**
    * @author Venky Kambham
    * @date 3/25/21
    * @description Save PRP Requests, Sites and it's supporting documents.
    **/
    @AuraEnabled
    public static List<PRP_Request__c> saveRequests(List<PRP_Request__c> requests, 
                                                    String supportDocsString, 
                                                    Map<String,List<PRP_Site__c>> prod2SitesMap, 
                                                    String addSiteFileString, 
                                                    String removeSiteFileString,
                                                    String siteInfo,
                                                    String addtnlContactsToBeAdded,
                                                    List<String> sitesIdsToBeDeleted, 
                                                    List<String> contactIdsToDelete)
    {
        
        System.debug('-----------------------------------------');
        System.debug('        Passed Parameters                ');
        System.debug('-----------------------------------------');
        System.debug('requests              : ' + requests);
        System.debug('supportDocsString     : ' + supportDocsString);
        System.debug('prod2SitesMap         : ' + prod2SitesMap);
        System.debug('addSiteFileString     : ' + addSiteFileString);
        System.debug('removeSiteFileString  : ' + removeSiteFileString);
        System.debug('siteInfo              : ' + siteInfo);
        System.debug('Additional Contacts   : ' + addtnlContactsToBeAdded);
        System.debug('Site Ids To Be Deleted: ' + sitesIdsToBeDeleted);
        System.debug('Contact Ids To Delete : ' + contactIdsToDelete);
        System.debug('-----------------------------------------');
        try
        {
            Id newRecordTypeId = Schema.SObjectType.PRP_Request__c.getRecordTypeInfosByDeveloperName().get(RT_NEW_REQUEST).getRecordTypeId();
            Id updateRecordTypeId = Schema.SObjectType.PRP_Request__c.getRecordTypeInfosByDeveloperName().get(RT_UPDATE_REQUEST).getRecordTypeId();
            Id transferRecordTypeId = Schema.SObjectType.PRP_Request__c.getRecordTypeInfosByDeveloperName().get(RT_TRANSFER_REQUEST).getRecordTypeId();
            PRP_RequestsController_WOS withoutSharing = new PRP_RequestsController_WOS();
           
            List<Object> files = new List<Object>();
            List<Object> addtnlContactObjects = new List<Object>();
            List<PRP_Site__c> sites2Insert = new List<PRP_Site__c>();
            List<PRP_Additional_Contact__c> addtnlContacts2Insert = new List<PRP_Additional_Contact__c>();
            List<PRP_Additional_Contact__c> parsedAddtnlContacts = new List<PRP_Additional_Contact__c>();
            List<String> requestProductNames = new List<String>();
            List<PRP_Contract__c> contracts = new List<PRP_Contract__c>();
            Set<Id> existingRequestIds = new Set<Id>();
            Set<Id> existingSiteIds = new Set<Id>();
            Set<Id> existingContactIds = new Set<Id>();
            Set<String> existingRequestProducts = new Set<String>();
            Map<String, Id> contractProductIdMap = new Map<String, Id>();
            Account existingPrpAccount;
            Boolean isUpdateRequest = false;
            Boolean isNoticeAddressSameAsSigner = false;
            Boolean isAddingSigningAuthourityAsAddtnlContact = false;
            String siteFieldsString = withoutSharing.config.Sites_Query_Fields__c;
            String prpSubmissionNumber = '';
            String bemEmail = '';
            String newAccountId = '';
            String newCustomAccountId = '';
            String accountProducts = '';
        
            if (String.isNotBlank(siteFieldsString))
            {
                for (String sfs:siteFieldsString.split(COMMA))
                {
                    if (String.isNotBlank(sfs))
                    {
                        siteFields.add(sfs.trim());
                    }
                }
            }

            if (requests?.size() > 0) 
            {
                //Validate Business Engagement Manager status
                if (String.isNotBlank(requests[0]?.BEM__c)) 
                {
                    PRP_BEM__c bem = withoutSharing.validateBEM(requests[0].BEM__c);
                    Boolean isBemActive = bem != null && bem.Is_Active__c;
                    bemEmail = bem != null && String.isNotBlank(bem.Email__c) ? bem.Email__c : '';
                    
                    if (!isBemActive) 
                    {
                        AuraHandledException e = new AuraHandledException(BEM_IS_NOT_ACTIVE);
                        e.setMessage(BEM_IS_NOT_ACTIVE);
                        throw e;
                    }
                }
                
                for (PRP_Request__c pr:requests) 
                {
                    //Set Ocrevus Prescriber
                    if (pr.Product_Name__c != PRODUCT_OCREVUS)
                    {
                        pr.Ocrevus_Prescriber__c = false;
                    }

                    //Additional contact role set flag
                    isNoticeAddressSameAsSigner = pr.Is_NA_Same_as_SA__c;
                    isAddingSigningAuthourityAsAddtnlContact = pr.Add_Signing_Authority_As_Addtnl_Contact__c;

                    //Get all product names
                    if (String.isNotBlank(pr.Product_Name__c)) 
                    {
                        requestProductNames.add(pr.Product_Name__c);
                    }

                    //Get Account Id if its a in revision request
                    if (String.isBlank(newAccountId) && String.isNotBlank(pr.Account__c))
                    {
                        newAccountId = pr.Account__c;
                    }

                    //Get Custom Account Id in case of new as well as in revision request
                    if (String.isBlank(newCustomAccountId) && String.isNotBlank(pr.Account_ID__c))
                    {
                        newCustomAccountId = pr.Account_ID__c;
                    }
                }

                if (requestProductNames?.size() > 0) 
                {
                    accountProducts = String.join(requestProductNames, SEMICOLON);
                }

                System.debug('PJ -- newAccountId: ' + newAccountId);
                System.debug('PJ -- newCustomAccountId: ' + newCustomAccountId);

                //prepare accounts to be inserted
                if (String.isNotBlank(newAccountId) || String.isNotBlank(newCustomAccountId))
                {
                    existingPrpAccount = withoutSharing.getPrpAccountDetails(newAccountId, newCustomAccountId);
                    if (existingPrpAccount != null)
                    {
                        newAccountId = existingPrpAccount.Id;
                    }
                    System.debug('PJ -- existingPrpAccount: ' + existingPrpAccount);
                } 
                else 
                {
                    Boolean isRandomNumberNotGenrated = true;
                    String randomGeneratedPrpAccountId;
                    Set<String> existingCustomAccountIds = new Set<String>();
                    
                    /* Commented out part of JIRA TICKET ROBOCOPS-1697
                    existingCustomAccountIds = withoutSharing.getAllPrpAccountIds();
                    
                    While(isRandomNumberNotGenrated) 
                    {
                        randomGeneratedPrpAccountId = PRFIX_GNE + generateRandomString(RANDOM_CHARS_LENGTH);
                        if (existingCustomAccountIds != null && !existingCustomAccountIds.contains(randomGeneratedPrpAccountId)) 
                        {
                            isRandomNumberNotGenrated = false;
                        }
                    }
                    */

                    newAccountId = withoutSharing.createAccount(requests[0], accountProducts, randomGeneratedPrpAccountId);
                }
                
                System.debug('PJ -- Account ID: ' + newAccountId);
            }

            //Get Contract details
            if (String.isNotBlank(newAccountId))
            {
                contracts = withoutSharing.getContractDetails(newAccountId);
                if (contracts?.size() > 0)
                {
                    for (PRP_Contract__c cntr:contracts)
                    {
                        contractProductIdMap.put(cntr.Product_name__c, cntr.Id);
                    }
                }
            }
            
            //Process Additional Contacts String
            if (String.isNotBlank(addtnlContactsToBeAdded)) 
            {
                addtnlContactObjects = (List<Object>) JSON.deserializeUntyped(addtnlContactsToBeAdded);
                if (addtnlContactObjects?.size() > 0)
                {
                    for(Object aComMap:addtnlContactObjects)
                    {
                        Map<String, Object> objMap = (Map<String, Object>) aComMap;
                        PRP_Additional_Contact__c aCon = new PRP_Additional_Contact__c();
                        for(String acKey:objMap.keySet())
                        {
                            aCon.put(acKey, objMap.get(acKey));
                        }
                        addtnlContacts2Insert.add(aCon);
                    }
                }
            } 
            System.debug('Parsed Contacts: ' + addtnlContacts2Insert);
            
            for (PRP_Additional_Contact__c ac:addtnlContacts2Insert)
            {
                if (String.isNotBlank(ac.Id))
                {
                    existingContactIds.add(ac.Id);
                }
            }
            
            //Process Support Documents
            if (String.isNotBlank(supportDocsString)) 
            {
                files = (List<Object>) JSON.deserializeUntyped(supportDocsString);
            } 
            
            //Process Add Site files
            if (String.isNotBlank(addSiteFileString))
            {
                Object addFile = (Object) JSON.deserializeUntyped(addSiteFileString);
                if (addFile != null) 
                {
                    files.add(addFile);
                    sites2Insert.addAll(parseSitesFile(addFile));
                }
            }
            
            //Process Remove Site files
            if (String.isNotBlank(removeSiteFileString))
            {
                Object removeFile = (Object) JSON.deserializeUntyped(removeSiteFileString);
                if (removeFile != null) 
                {
                    files.add(removeFile);
                    sites2Insert.addAll(parseSitesFile(removeFile));
                }
            }
            
            //Process manually entered Site informations
            if (String.isNotBlank(siteInfo))
            {
                List<Object> siteInfoObj = new List<Object>();
                siteInfoObj = (List<Object>) JSON.deserializeUntyped(siteInfo);
                System.debug('Parsed Object: ' + siteInfoObj);
                if (siteInfoObj?.size() > 0)
                {
                    sites2Insert.addAll(prepareSites2Insert(siteInfoObj));
                }
            }
            
            System.debug('sites2Insert: ' + sites2Insert);
            
            Set<String> zipCodes = new Set<String>();
            for (PRP_Request__c pr :requests) 
            {
                if (String.isNotBlank(pr.Id))
                {
                    isUpdateRequest = true;
                }
                
                if (String.isNotBlank(pr.Submission_Number__c))
                {
                    prpSubmissionNumber = pr.Submission_Number__c;
                }
                
                zipCodes.add(pr.Zip__c);
            } 
            
            for (PRP_Site__c ps :sites2Insert)
            {
                zipCodes.add(ps.Zip__c);
            } 
            
            Map<String,String> zip2EcosystemMap = new Map<String,String>();
            for (Ecosystem_Details_gne__c es : withoutSharing.getEcosystems(zipCodes))
            {
                zip2EcosystemMap.put(es.ECO_ZIP_Code_gne__c,es.ECO_Name_gne__c);
            }
            
            ////////////////////////////////////////
            //                                    //
            //    1. Create/Update Requests       //
            //                                    //
            ////////////////////////////////////////
            Map<String,PRP_Request__c> prod2RequestMap = new Map<String,PRP_Request__c>();
            
            //Generate PRP Subscription Number
            if (!isUpdateRequest && String.isBlank(prpSubmissionNumber)) 
            {
                prpSubmissionNumber = withoutSharing.generateSubmissionNumber();
            }
            
            System.debug('prpSubmissionNumber*****' + prpSubmissionNumber);
            
            if (requests.isEmpty()) return prod2RequestMap.values();
            
            for (PRP_Request__c pr: requests)
            {
                
                if (String.isNotBlank(newAccountId)){
                    pr.Account__c = newAccountId;
                }
                
                if (String.isNotBlank(newCustomAccountId)){
                    pr.Account_Id__c = newCustomAccountId;
                }

                pr.Ecosystem__c = zip2EcosystemMap.containsKey(pr.Zip__c) ? zip2EcosystemMap.get(pr.Zip__c) : '';

                if (pr.Request_PDF_Version_Number__c  != null){
                    pr.Request_PDF_Version_Number__c += 1;
                } else {
                    pr.Request_PDF_Version_Number__c = 1;
                }

                if (String.isNotBlank(bemEmail)){
                    pr.BEM_Email__c = bemEmail;
                }
                
                if (String.isBlank(pr.Id)) 
                {
                    pr.Request_Status__c = 'New';
                } 
                else {
                    existingRequestIds.add(pr.Id);

                    if (pr.Request_Status__c == 'New' || pr.Request_Status__c == 'In Revision') 
                    {
                        pr.Request_Status__c = 'Revised';
                    }

                    if (pr.Request_Status__c == 'Closed') 
                    {
                        pr.Status_Category__c = 'Withdrawn';
                    }

                    if (String.isNotBlank(pr.Product_Name__c)) {
                        existingRequestProducts.add(pr.Product_Name__c);
                    }
                }
                
                if (String.isBlank(pr.Submission_Number__c))
                {
                    pr.Submission_Number__c = prpSubmissionNumber;
                }
                
                if (String.isBlank(pr.RecordTypeId)) 
                {
                    if (pr.Request_Type__c == REQUEST_TYPE_NEW) 
                    {
                        pr.RecordTypeId = newRecordTypeId;
                    } else if (pr.Request_Type__c == REQUEST_TYPE_UPDATE) 
                    {
                        pr.RecordTypeId = updateRecordTypeId;
                    } else if (pr.Request_Type__c == REQUEST_TYPE_TRANSFER) 
                    {
                        pr.RecordTypeId = transferRecordTypeId;
                    }
                }

                //Populate the contract relationship based on products
                if (!contractProductIdMap.isEmpty() && contractProductIdMap.containsKey(pr.Product_Name__c))
                {
                    pr.ContractId1__c = contractProductIdMap.get(pr.Product_Name__c);
                }
                
                System.debug('requests*****' + pr);
            }
            
            Set<Id> requestIds = new Set<Id>();
            if (requests?.size() > 0)
            {
                requestIds = withoutSharing.upsertRequests(requests);
            }

            /////////////////////////////////
            //                             //
            //    2. Create Documents      //
            //                             //
            ///////////////////////////////// 
            Set<Id> docIds = new Set<Id>();
            if (files?.size() > 0)
            {
                //docIds = createDocuments(files); 
                //Added By Raheem to resolve multiple files insert
                System.enqueueJob(new PRP_CreateDocuments_Queueable(files, requestIds));
            }
            
            List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
            for (PRP_Request__c req : withoutSharing.getRequests(requestIds))
            {
                prod2RequestMap.put(req.Product_Name__c, req);
                
                if (docIds.isEmpty()) { continue; }

                /////////////////////////////////////////////////////
                //                                                 //
                //   3. Attach all documents for each request      //
                //                                                 //
                /////////////////////////////////////////////////////
                /* commented by Raheem to resolve multiple files insert 
                for (Id docId:docIds)
                {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = docId;
                    cdl.LinkedEntityId = req.Id;
                    cdl.ShareType = 'V';
                    docLinks.add(cdl);
                }
                */
            }
                
            /* commented by Raheem to resolve multiple files insert   
            if (docLinks?.size() > 0)
            {
                withoutSharing.createDocumentLinks(docLinks);
            }
            */

            ///////////////////////////////////////
            //                                   //
            //   4. Create Additional Contacts   //
            //                                   //
            ///////////////////////////////////////
            if (addtnlContacts2Insert?.size() > 0)
            {
                if (String.isNotBlank(newAccountId)){
                    for (PRP_Additional_Contact__c pac:addtnlContacts2Insert) {
                        System.debug('[DEBUG] PAC Before: ' + pac);
                        pac.Account__c = newAccountId;
                    }
                }
                withoutSharing.createAdditionContacts(addtnlContacts2Insert);
            }

            System.debug('addtnlContacts2Insert: ' + addtnlContacts2Insert);
            
            ///////////////////////////////////////////////////////
            //                                                   //
            //    5.Create Contact Request (Junction Object)     //
            //                                                   //
            ///////////////////////////////////////////////////////
            List<PRP_Request_Contact__c> contactRequests2Insert = new List<PRP_Request_Contact__c>();

            if (isUpdateRequest)
            {
                if (existingRequestIds != null && existingRequestIds.size() > 0)
                {
                    withoutSharing.deleteAllContactRequests(existingRequestIds);
                }
            }
            
            if (addtnlContacts2Insert?.size() > 0)
            {
                for (PRP_Additional_Contact__c ac:addtnlContacts2Insert) 
                {
                    String productString = ac.Product__c;
                    List<String> listOfProducts = new List<String>();
                    
                    if (String.isNotBlank(productString)) 
                    {
                        if (productString.contains(SEMICOLON)) 
                        {
                            listOfProducts = productString.split(SEMICOLON);
                        } else {
                            listOfProducts.add(productString);
                        }
                    }
                    
                    System.debug('listOfProducts in contact: ' + listOfProducts);
                    if (listOfProducts?.size() > 0) 
                    {
                        for (String prod:listOfProducts)
                        {
                            System.debug('Contact Prod: ' + prod);
                            System.debug('prod2RequestMap*****' + prod2RequestMap.get(prod));
                            if (prod2RequestMap.containsKey(prod))
                            {
                                PRP_Request_Contact__c contactRequest = new PRP_Request_Contact__c();
                                contactRequest.Request__c = prod2RequestMap.get(prod).Id;
                                contactRequest.Additional_Contact__c = ac.Id;
                                contactRequests2Insert.add(contactRequest);
                            }
                        }
                    }
                }
            }
            
            System.debug('contactRequests2Insert: ' + addtnlContacts2Insert);
            if (contactRequests2Insert?.size() > 0)
            {
                withoutSharing.createContactRequests(contactRequests2Insert);
            }

            /////////////////////////
            //                     //
            //   6.Create Sites    //
            //                     //
            /////////////////////////
            Map<Id, String> siteProductsMap = new Map<Id, String>();
            for (PRP_Site__c ps : sites2Insert)
            {
                if (String.isNotBlank(ps.Id)) 
                {
                    existingSiteIds.add(ps.Id);
                    siteProductsMap.put(ps.Id, ps.Products__c);
                }
                ps.Ecosystem__c = zip2EcosystemMap.containsKey(ps.Zip__c) ? zip2EcosystemMap.get(ps.Zip__c) : '';
                if (String.isNotBlank(newAccountId)){
                    ps.Account__c = newAccountId;
                }
            }

            //De-reference site request in case of products mismatch
            System.debug('prod2RequestMap*****' + prod2RequestMap);
            System.debug('PJ -- existingSiteIds : ' + existingSiteIds);
            if (!existingSiteIds.isEmpty()){
                withoutSharing.linkOrDelinkSiteRequest(existingSiteIds, siteProductsMap, prpSubmissionNumber);
            }
            
            System.debug('sites2Insert*****' + sites2Insert);
            if (sites2Insert?.size() > 0)
            {
                withoutSharing.createSites(sites2Insert);
            }

            /////////////////////////////////////////////////////
            //                                                 //
            //    7.Create Site Requests (Junction Object)     //
            //                                                 //
            /////////////////////////////////////////////////////

            List<PRP_Site_Request__c> siteRequests = new List<PRP_Site_Request__c>();

            for(PRP_Site__c ps : sites2Insert)
            {
                //Create Site Request records only for new sites
                if (!existingSiteIds.contains(ps.Id)) 
                {
                    String productString = ps.Products__c;
                    List<String> listOfProducts = new List<String>();
                    
                    if (String.isNotBlank(productString)) 
                    {
                        if (productString.contains(SEMICOLON)) 
                        {
                            listOfProducts = productString.split(SEMICOLON);
                        } else {
                            listOfProducts.add(productString);
                        }
                    }
                    
                    System.debug('listOfProducts*****' + listOfProducts);
                    if (listOfProducts?.size() > 0) 
                    {
                        for (String prod:listOfProducts)
                        {
                            System.debug('prod*****' + prod);
                            System.debug('prod2RequestMap*****' + prod2RequestMap.get(prod));
                            if(prod2RequestMap.containsKey(prod))
                            {
                                PRP_Site_Request__c sr = new PRP_Site_Request__c();
                                sr.Request__c = prod2RequestMap.get(prod).Id;
                                sr.Site__c	= ps.Id;
                                if (String.isNotBlank(newAccountId)){
                                    sr.Account__c = newAccountId;
                                }
                                siteRequests.add(sr);
                            }
                        }
                    }
                }
            }
            
            System.debug('siteRequests*****' + siteRequests);
            if (siteRequests?.size() > 0)
            {
                withoutSharing.createSiteRequests(siteRequests);
            }
            
            ///////////////////////////////////////////////////
            //                                               //
            //  8. Delete site and associated site requests  //
            //                                               //
            ///////////////////////////////////////////////////
            /*
            if (sitesIdsToBeDeleted?.size() > 0) {
                withoutSharing.deleteSites(existingRequestIds, sitesIdsToBeDeleted);
            }
            */

            ///////////////////////////////////////////////////////////////
            //                                                           //
            //    9. Delete contacts and associated contact requests     //
            //                                                           //
            ///////////////////////////////////////////////////////////////
            if (contactIdsToDelete?.size() > 0) {
                withoutSharing.deleteContacts(existingRequestIds, contactIdsToDelete);
            }

            /*
            if (!requestIds.isEmpty() && requestIds.size() > 0){
                withoutSharing.saveRequestsAsPdf(requestIds);
            }
            */

            /////////////////////////////////////////
            //                                     //
            //    10. Update Account products      //
            //                                     //
            /////////////////////////////////////////
            if (existingPrpAccount != null && existingPrpAccount.Provider_Rebate_Program_Requests__r != null) {
                for (PRP_Request__c pr:existingPrpAccount.Provider_Rebate_Program_Requests__r) {
                    if (String.isNotBlank(pr.Product_Name__c) && 
                       (requestProductNames?.size() == 0 || !requestProductNames.contains(pr.Product_Name__c))) 
                    {
                        requestProductNames.add(pr.Product_Name__c);
                    }
                }

                if (requestProductNames?.size() > 0) {
                    String productNames = String.join(requestProductNames, SEMICOLON);
                    withoutSharing.updateAccountProducts(existingPrpAccount, productNames);
                }
            }

            return prod2RequestMap.values();
        }
        catch(Exception e)
        {
            System.debug('Error: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<String> generateListOfItemsFromString(String inputString)
    {
        List<String> listOfItems = new List<String>(); 

        if (String.isNotBlank(inputString)) 
        {
            if (inputString.contains(SEMICOLON)) 
            {
                listOfItems = inputString.split(SEMICOLON);
            } else {
                listOfItems.add(inputString);
            }
        }

        return listOfItems;
    }

    /**
    * @author Venky Kambham
    * @date 3/25/21
    * @description Create content documents.
    **/
   
    private static Set<Id> createDocuments(List<Object> files)
    {
        Set<Id> docIds = new Set<Id>();
        List<ContentVersion> cvs = new List<ContentVersion>();
        if (files.isEmpty()) return docIds;
        
        for (Object file : files)
        {
            Map<String,Object> fileMap = (Map<String,Object>) file;
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode((String)fileMap.get('base64'));
            cv.Title = (String)fileMap.get('name');
            cv.PathOnClient = (String)fileMap.get('name');
            cvs.add(cv);
        }
        System.debug('PJ --> cvs: ' + cvs);
        
        List<Database.SaveResult> dbSaveResults = new List<Database.SaveResult>();
        try {
            //dbSaveResults = Database.insert(cvs,true);
            insert cvs;
        } catch (Exception e) {
            System.debug('PJ --> DB insert error: ' + e);
        }
        
        Set<Id> contentVersionIds = new Set<Id>();
        for (Database.SaveResult sr : dbSaveResults)
        {
            if (sr.isSuccess())
            {
                contentVersionIds.add(sr.getId());
            }
            else {
                System.debug('PJ --> sr: ' + sr);
            }
        } 
        
        for (ContentVersion cv : new PRP_RequestsController_WOS().getDocuments(contentVersionIds))
        {
            docIds.add(cv.ContentDocumentId);
        } 
        
        return docIds;
    }

    /**
    * @author Palani Jayachandran
    * @date 10/12/22
    * @description Generate Random Alphanumeric String.
    **/
    public static String generateRandomString(Integer len) {
        String randString = '';
        while (randString.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), RANDOM_CHARS.length());
           randString += RANDOM_CHARS.substring(idx, idx + 1);
        }

        return randString; 
    }
    
    /**
    * @author Palani Jayachandran
    * @date 5/20/21
    * @description Site information and prepare the additional site details.
    **/
    public static List<PRP_Site__c> prepareSites2Insert (List<Object> siteInfoObj) 
    {
        List<PRP_Site__c> sites2Insert = new List<PRP_Site__c>();
        List<String> formulaFieldsToSkip = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.PRP_Site__c.fields.getMap();

        for (Schema.SObjectField field : fieldMap.values())
        {
            Schema.DescribeFieldResult fieldResults = field.getDescribe();
            if ((fieldResults.isCalculated() && fieldResults.getCalculatedFormula() != null) || fieldResults.isAutoNumber())
            {
                formulaFieldsToSkip.add(fieldResults.getName());
                System.debug('Formula Field:: ' + fieldResults.getName() + ' - Formula:: ' + fieldResults.getCalculatedFormula());
            }
        }
        
        for (Object so:siteInfoObj) 
        {
            PRP_Site__c site = new PRP_Site__c();
            Map<String, Object> siteInfoObjMap = new Map<String, Object>();
            List<String> siteProducts = new List<String>();

            siteInfoObjMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(so));

            for (String sf:siteFields) 
            {
                System.debug('Site Fields: ' + sf);
                if (siteInfoObjMap.containsKey(sf)) 
                {
                    if (sf.equalsIgnoreCase(SIT_PRODUCTS)) 
                    {
                        for (Object prd:(List<Object>) JSON.deserializeUntyped(JSON.serialize(siteInfoObjMap.get(sf)))) 
                        {
                            siteProducts.add((String) prd);
                        }
                        //siteProducts = (List<String>) jsonObjMap.get(sf);
                        site.put(FIELD_API_PRODUCTS, String.join(siteProducts, SEMICOLON));
                    } 
                    else 
                    {
                        if (sf.equalsIgnoreCase(PROSPECTIVE_TERMINATION_DATE)) 
                        {
                            String strDate = (String) siteInfoObjMap.get(sf);
                            site.put(sf, date.valueOf(strDate));
                        } 
                        else if (sf.equalsIgnoreCase(IS_DEFAULT_SITE))
                        {
                            site.put(sf, (Boolean) siteInfoObjMap.get(sf));
                        }
                        else 
                        {
                            String siteFieldValue = (String) siteInfoObjMap.get(sf);
                            System.debug('formulaFieldsToSkip: ' + formulaFieldsToSkip);
                            if (formulaFieldsToSkip?.size() > 0 && !formulaFieldsToSkip.contains(sf))
                            {
                                if (String.isNotBlank(siteFieldValue))
                                {
                                    site.put(sf, siteFieldValue);
                                }
                            }
                        }
                    }
                }
            }

            System.debug('Site: ' + site);
            if (site != null)
            {
                sites2Insert.add(site);
            } 
        }

        System.debug('sites2Insert: ' + sites2Insert);
        return sites2Insert;
    }
    
    /**
    * @author Venky Kambham
    * @date 5/20/21
    * @description Parse Affiliate Sites csv file and create Sites.
    **/
    public static List<PRP_Site__c> parseSitesFile(Object file)
    {
        Map<String,List<PRP_Site__c>> prod2SitesMap = new Map<String,List<PRP_Site__c>>();
        List<PRP_Site__c> sites2Insert = new List<PRP_Site__c>();
        
        if(file == null) return sites2Insert;
        
        Map<String,Object> fileMap = (Map<String,Object>) file;
        String fileBody = EncodingUtil.base64Decode((String)fileMap.get('base64')).toString();
        String[] rows = fileBody.split('\r');
        String[] colHeaders = rows[0].split(',');
        rows.remove(0);
        
        Map<String,String> products = getPicklistValues('Product_Name__c');
        Map<String,String> states = getPicklistValues('State__c');
        Map<Integer,String> index2ProdMap = new Map<Integer,String>();
        Map<Integer,String> index2FieldMap = new Map<Integer,String>();
        Set<Integer> prodIndexes = new Set<Integer>();
        for (Integer i=0; i<colHeaders.size(); i++)
        {
            if (colHeaders[i].contains('(Yes/No)'))
            {
                String prod = colHeaders[i].substringBefore('(Yes/No)').normalizeSpace();
                System.debug('prod: ' + prod);
                if (products.containsKey(prod))
                {
                    prod2SitesMap.put(prod, new List<PRP_Site__c>());
                    index2ProdMap.put(i, prod);
                }
            }
            else
            {
                if(String.isNotBlank(colHeaders[i])){
                    if(colHeaders[i].containsIgnoreCase('Site Name')) index2FieldMap.put(i,'Name');
                    if(colHeaders[i].containsIgnoreCase('Address 1')) index2FieldMap.put(i,'Address1__c');
                    if(colHeaders[i].containsIgnoreCase('Address 2')) index2FieldMap.put(i,'Address2__c');
                    if(colHeaders[i].containsIgnoreCase('City')) index2FieldMap.put(i,'City__c');
                    if(colHeaders[i].containsIgnoreCase('State')) index2FieldMap.put(i,'State__c');
                    if(colHeaders[i].containsIgnoreCase('Zip')) index2FieldMap.put(i,'Zip__c');
                    if(colHeaders[i].containsIgnoreCase('Site Type')) index2FieldMap.put(i,'Site_Type__c');
                    if(colHeaders[i].containsIgnoreCase('HIN Number')) index2FieldMap.put(i,'HIN_Number__c');
                    if(colHeaders[i].containsIgnoreCase('Distributor Number')) index2FieldMap.put(i,'Distributor_Number__c');
                    if(colHeaders[i].containsIgnoreCase('Prospective Termination Date')) index2FieldMap.put(i,'Prospective_Termination_Date__c');
                    //if(colHeaders[i].containsIgnoreCase('DEA Number')) index2FieldMap.put(i,'DEA_Number__c');
                }
                
            }
        }
        System.debug('colHeaders: ' + colHeaders);
        System.debug('index2ProdMap: ' + index2ProdMap);
        System.debug('index2FieldMap: ' + index2FieldMap);
        
        for (String row : rows)
        {
            String[] fields = row.split(',');
            PRP_Site__c site = new PRP_Site__c();
            List<String> siteFileProducts = new List<String>();
            for (Integer i=0; i<fields.size(); i++)
            {
                if(index2FieldMap.containsKey(i))
                {
                    site.put(index2FieldMap.get(i), fields[i]);
                }
                else if(index2ProdMap.containsKey(i) && fields[i] == 'Yes')
                {
                    String prod = index2ProdMap.get(i);
                    prod2SitesMap.get(prod).add((PRP_Site__c)site);
                    siteFileProducts.add(prod);
                }
            }
            if (siteFileProducts?.size() > 0)
            {
                site.put(FIELD_API_PRODUCTS, String.join(siteFileProducts, SEMICOLON));
            }
            sites2Insert.add(site);
        }
        System.debug('sites2Insert: ' + sites2Insert);
        
        System.debug('prod2SitesMap1****'+prod2SitesMap);
        for (String prod : prod2SitesMap.keySet())
        {
            System.debug('prod2****'+prod);
            Integer i=0;
            for (PRP_Site__c site : prod2SitesMap.get(prod))
            {
                System.debug('iteration****'+(i++));
                System.debug('site-before****'+site);
                site.Distributor_Number__c = prod == 'Lucentis' ? site.Distributor_Number__c : '';
                //site.DEA_Number__c = prod == 'Xolair' ? site.DEA_Number__c : '';
                site.HIN_Number__c = prod != 'Lucentis' ? site.HIN_Number__c : '';
                System.debug('site-after****'+site);
            }
        }
        System.debug('prod2SitesMap2****'+prod2SitesMap);
        return sites2Insert;
    }

    /**
    * @author Palani Jayachandran
    * @date 11/30/21
    * @description Generate request pdf and save as an attachments.
    **/
    @AuraEnabled
    public static String generateAndSaveRequestPDF(List<PRP_Request__c> requests) {
        System.debug('generateAndSaveRequestPDF - requests: ' + requests);
        PRP_RequestsController_WOS withoutSharing = new PRP_RequestsController_WOS();
        Set<Id> requestIds = new Set<Id>();
        String successMsg = 'Request PDF\'s Generated Successfully.';

        try {
            for (PRP_Request__c req:requests) {
                requestIds.add(req.Id);
            }

            if (!requestIds.isEmpty() && requestIds.size() > 0){
                withoutSharing.saveRequestsAsPdf(requestIds);
            }
            return successMsg;
        }
        catch(Exception e)
        {
            System.debug('Error*** '+e.getMessage()+' @ '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class PRP_FetchRequestWrapper
    {
        public List<PRP_Request__c> requests {get;set;}
        public List<PRP_Site_Request__c> siteRequests {get;set;}
        public List<PRP_Site__c> addtnlSites {get;set;}
        public List<PRP_Additional_Contact__c> addtnlContacts {get;set;}
        public List<ContentDocumentLink> documents {get;set;}
        
        public PRP_FetchRequestWrapper()
        {
            siteRequests = new List<PRP_Site_Request__c>();
            requests = new List<PRP_Request__c> ();
            addtnlSites = new List<PRP_Site__c>();
            addtnlContacts  = new List<PRP_Additional_Contact__c>();
            documents = new List<ContentDocumentLink>();
        }
    }
    
    //With out sharing class to get excessive access to the Guest user profile
    public without sharing class PRP_RequestsController_WOS
    {
        String requestFields = 'Id';
        String siteFields = 'Id';
        String siteRequestFields = 'Id';
        String contractFields = 'Id';
        String contactFields = 'Id';
        String reqToAccFieldsString = 'Name:Legal_Name__c';
        
        public PRP_Settings__mdt config {get;set;}
        
        public PRP_RequestsController_WOS (){
            System.debug('Executing');
            config = getPrpConfigurations();
            requestFields = config.Request_Query_Fields__c;
            siteFields = config.Sites_Query_Fields__c;
            siteRequestFields = config.Site_Request_Fields__c;
            contractFields = config.Contract_Query_Fields__c;
            contactFields = config.Contact_Query_Fields__c;
            reqToAccFieldsString = config.Request_To_Account_Fields_Map__c;
            
        }
        
        public PRP_Settings__mdt getPrpConfigurations(){
            return [
                SELECT Request_Query_Fields__c
                ,Site_Request_Fields__c
                ,Sites_Query_Fields__c
                ,Contract_Query_Fields__c
                ,Contact_Query_Fields__c
                ,Request_To_Account_Fields_Map__c
                FROM PRP_Settings__mdt
                WHERE DeveloperName = 'PRP'
            ];
        }

        public Map<String, String> getAccountFieldsMap() {
            Map<String, String> requestToAccountFieldsMap = new Map<String, String>();
            if (String.isNotBlank(reqToAccFieldsString)) 
            {
                for (String kpv:reqToAccFieldsString.split(COMMA))
                {
                    if (String.isNotBlank(kpv) && kpv.contains(COLON)) 
                    {
                        String[] keyPairValues = kpv.split(COLON);
                        requestToAccountFieldsMap.put(keyPairValues[0], keyPairValues[1]);
                    }
                }
            }

            return requestToAccountFieldsMap;
        }

        public Id getPrpAccountId(String prpAccountId) 
        {
            Id accId = [SELECT Id FROM Account WHERE PRP_Account_ID__c = :prpAccountId AND RecordType.DeveloperName = :PRP_ACCOUNT_RT LIMIT 1]?.Id;
            return accId;
        }

        public Set<String> getAllPrpAccountIds() {
            List<Account> accounts = new List<Account>();
            Set<String> prpAccountIds = new Set<String>();
            Id prpAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PRP_ACCOUNT_RT).getRecordTypeId();
            
            accounts = [SELECT PRP_Account_ID__c FROM Account WHERE RecordTypeId = :prpAccountRecordTypeId];
            
            for (Account a:accounts) {
                prpAccountIds.add(a.PRP_Account_ID__c);
            }

            return prpAccountIds;
        }

        public Account getPrpAccountDetails(String accId, String customAccountId) 
        {
            PRP_Contract__c contract;
            List<Account> accounts = new List<Account>();
            String query = 'SELECT Id, PRP_Account_ID__c, PRP_Products__c, (SELECT Id, Product_Name__c FROM Provider_Rebate_Program_Requests__r) FROM Account WHERE ';
            
            if (String.isBlank(accId) && String.isBlank(customAccountId)) {
                return null;
            }
            
            if (String.isNotBlank(accId)) {
                query += 'Id=:accId';
            } else {
                query += 'PRP_Account_ID__c=:customAccountId';
            }

            accounts = Database.query(query);
            System.debug('accounts: ' + accounts);

            //The custom account id can also be a contract name. So, check the contract and get the related account;
            //if the account not found from the above query execution.
            if (accounts?.size() == 0)
            {
                contract = getPrpContractDetails(customAccountId);
                System.debug('contract: ' + contract);
                if (contract != null && String.isNotBlank(contract.Account_Id__c)) {
                    String contractsAccId = contract.Account_Id__c;
                    accounts = [
                        SELECT Id, PRP_Account_ID__c, PRP_Products__c, 
                               (SELECT Id, Product_Name__c FROM Provider_Rebate_Program_Requests__r) 
                          FROM Account 
                         WHERE Id = :contractsAccId
                    ];
                    System.debug('Contract related account: ' + accounts);
                }
            }

            return accounts?.size() > 0 ? accounts[0] : null;
        }

        public PRP_Contract__c getPrpContractDetails(String contractName) 
        {
            List<PRP_Contract__c> contracts = new List<PRP_Contract__c>();
            contracts = [SELECT Id, Name, Account_Id__c FROM PRP_Contract__c WHERE Name = :contractName];

            return contracts?.size() > 0 ? contracts[0] : null;
        }

        public List<PRP_Contract__c> getContractDetails(String accountId) 
        {
            List<PRP_Contract__c> contracts = new List<PRP_Contract__c>();
         	
            contracts = [
                SELECT Id, Name, Account_Id__c, Product_name__c
                  FROM PRP_Contract__c 
                WHERE Account_Id__c = :accountId AND IsActive__c = true];
			
            return contracts;
        }

        public Boolean getPRPAccountDetails(String customAccountId)
        {
            Account account;
            PRP_Contract__c contract;
            Boolean isPRPAccountOrContractExists = false;
            
            account = getPRPAccountDetails(null, customAccountId);
            System.debug('Account: ' + account);

            if (account != null) {
                isPRPAccountOrContractExists = true;
            }

            return isPRPAccountOrContractExists;
        }

        public void updateAccountProducts(Account accountToUpdate, String products) 
        {
            accountToUpdate.PRP_Products__c = products;
            update accountToUpdate;
        }
        
        public String createAccount(PRP_Request__c req, String accountProducts, String randomGeneratedAccId)
        {
            String accountFields = '';
            String accId = '';
            Account accountToBeCreated = new Account();
            Map<String, String> requestToAccountFieldsMap = new Map<String, String>();

            try
            {

                Account existingAccount;
                Map<String,String> zip2EcosystemMap = new Map<String,String>();
                Set<String> zipCodes = new Set<String>();

                if (String.isNotBlank(req.Id) && String.isNotBlank(req.Account__c)) {
                    existingAccount = getPrpAccountDetails(req.Account__c, null);
                }
                System.debug('PJ -- Account: ' + existingAccount);

                if (existingAccount != null) {
                    return existingAccount.Id;
                }

                requestToAccountFieldsMap = getAccountFieldsMap();   
                System.debug('requestToAccountFieldsMap: ' + requestToAccountFieldsMap);

                if (!requestToAccountFieldsMap.isEmpty()) 
                {
                    Id prpAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PRP_ACCOUNT_RT).getRecordTypeId();
                    accountToBeCreated.RecordTypeId = prpAccountRecordTypeId;

                    for (String accField:requestToAccountFieldsMap.keySet())
                    {
                        String requestField = requestToAccountFieldsMap.get(accField);
                        System.debug('PJ requestField: ' + requestField + ' accField: ' + accField + ' Record Value: ' + req.get(requestField));
                        accountToBeCreated.put(accField, req.get(requestField));
                    }

                    if (String.isNotBlank(accountProducts)) {
                        accountToBeCreated.PRP_Products__c = accountProducts;
                    }

                    /*Commented part of JIRA TICKET ROBOCOPS-1697
                    if (String.isNotBlank(randomGeneratedAccId)) {
                        accountToBeCreated.PRP_Account_ID__c = randomGeneratedAccId;
                    }
                    */

                    //Populate ECOSYSTEM Name
                    if (String.isNotBlank(accountToBeCreated.PRP_Zip__c))
                    {
                        zipCodes.add(accountToBeCreated.PRP_Zip__c);
                        List<Ecosystem_Details_gne__c> es = new List<Ecosystem_Details_gne__c>();
                        es = getEcosystems(zipCodes);
                        if (es?.size() > 0)
                        {
                            accountToBeCreated.PRP_Ecosystem__c = es[0].ECO_Name_gne__c;
                        }
                    }

                    if (accountToBeCreated != null) 
                    {
                        insert accountToBeCreated;
                        accId = accountToBeCreated.Id;
                    }
                }
            }
            catch(Exception e)
            {
                System.debug('Account Create Exception Occured ::: ' + e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }

            return accId;
        }

        public List<PRP_Additional_Contact__c> getAdditionalContacts(Set<Id> contactIds)
        {
            String query = 'SELECT ' + contactFields + ' FROM PRP_Additional_Contact__c WHERE Id IN :contactIds ORDER BY Contact_Display_Order__c NULLS LAST';
            return Database.query(query);
        }
        
        public List<PRP_Site__c> getAdditionalSites(Set<Id> siteIds)
        {
            String query = 'SELECT ' + siteFields + ' FROM PRP_Site__c WHERE Id IN :siteIds';
            return Database.query(query);
        }

        public List<PRP_Request__c> getRequest(String requestId)
        {
            String query =                                                                                     +
                'SELECT ' + requestFields + ',(SELECT ' + siteRequestFields + ' FROM PRP_Site_Requests__r),'   +
                '(SELECT Id, Request__c, Additional_Contact__c FROM PRP_Request_Contacts__r) '                 +
                'FROM PRP_Request__c WHERE Id = :requestId LIMIT 1';
            return Database.query(query);
        }

        public List<PRP_Request__c> getRequest(Set<Id> requestIds)
        {
            String query =                                                                                     +
                'SELECT ' + requestFields + ',(SELECT ' + siteRequestFields + ' FROM PRP_Site_Requests__r),'   +
                '(SELECT Id, Request__c, Additional_Contact__c FROM PRP_Request_Contacts__r) '                 +
                'FROM PRP_Request__c WHERE Id IN :requestIds';
            return Database.query(query);
        }

        public List<ContentDocumentLink> docsUploaded(String reqId)
        {
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            contentDocumentLinks = [SELECT Id,ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                                      FROM ContentDocumentLink 
                                     WHERE LinkedEntityId = :reqId];
            return contentDocumentLinks;
        }

        public List<ContentDocumentLink> docsUploaded(Set<Id> reqIds)
        {
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            contentDocumentLinks = [SELECT Id,ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                                      FROM ContentDocumentLink 
                                     WHERE LinkedEntityId IN :reqIds];
            return contentDocumentLinks;
        }
        
        public List<PRP_Request__c> getRequest(String submissionNumber, String submitterEmail)
        {
            List<String> requestStatuses = new List<String> {'New','In Revision','Revised'};
            System.debug('requestFields at update: ' + requestFields);
            String query = 
                'SELECT ' + requestFields + ',(SELECT ' + siteRequestFields + ' FROM PRP_Site_Requests__r),'   +
                '(SELECT Id, Request__c, Additional_Contact__c FROM PRP_Request_Contacts__r) '                 +
                'FROM PRP_Request__c WHERE Submission_Number__c = :submissionNumber '                          +
                'AND Email__c = :submitterEmail AND Request_Status__c IN :requestStatuses';
            return Database.query(query);
        }
        
        public List<PRP_Request__c> getRequests(Set<Id> requestIds)
        {
            return [SELECT Id,Name,Product_Name__c FROM PRP_Request__c WHERE Id IN :requestIds];
        }
        
        public List<Ecosystem_Details_gne__c> getEcosystems(Set<String> zipCodes)
        {
            
            return [SELECT Id,ECO_Name_gne__c,ECO_ZIP_Code_gne__c FROM Ecosystem_Details_gne__c 
                    WHERE ECO_ZIP_Code_gne__c IN :zipCodes];
        }
        
        public List<PRP_BEM__c> getBEMs()
        {
           
            return [SELECT Id, Name, Email__c, Is_Active__c,Field_Title_Code__c FROM PRP_BEM__c WHERE Is_Active__c = True ];
           
        }
        
        public PRP_BEM__c validateBEM(String bemId)
        {
            List<PRP_BEM__c> bems = new List<PRP_BEM__c>();
            Boolean isBemActive = false;
            bems = [SELECT Id, Name, Email__c, Is_Active__c FROM PRP_BEM__c WHERE Id = :bemId AND Is_Active__c = True];
            if (bems?.size() > 0) {
                isBemActive = bems[0].Is_Active__c;
            }
            return bems?.size() > 0 ? bems[0] : null;
        }
        
        public Set<Id> upsertRequests(List<PRP_Request__c> requests)
        {
            Set<Id> requestIds = new Set<Id>();
            for (Database.UpsertResult sr : Database.upsert(requests,true))
            {
                if (sr.isSuccess())
                {
                    requestIds.add(sr.getId());
                }
            }
            return requestIds;
        }
        
        public List<ContentVersion> getDocuments(Set<Id> contentVersionIds)
        {
            return [SELECT Id,ContentDocumentId,Title FROM ContentVersion WHERE Id IN :contentVersionIds];
        }
        
        public void createDocumentLinks(List<ContentDocumentLink> docLinks)
        {
            if(!docLinks.isEmpty()) upsert docLinks;
        }
        
        public void createSites(List<PRP_Site__c> sites)
        {
            if(!sites.isEmpty()) upsert sites;
        }
        
        public void createContracts(List<PRP_Contract__c> contracts)
        {
            if(!contracts.isEmpty()) upsert contracts;
        }
        
        public C_Ops_LOC_App_Properties__c getGReCaptchaDetails()
        {
            List<C_Ops_LOC_App_Properties__c> props = [
                SELECT Id,GClient__c,GSecurityKey__c,GSite__c,Active__c 
                FROM C_Ops_LOC_App_Properties__c WHERE Active__c = true LIMIT 1
            ];
            return props.isEmpty() ? null : props[0];
        }
        
        public String generateSubmissionNumber()
        {
            String submissionId = '';
            PRP_Submission_Number_Generator__c submission = new PRP_Submission_Number_Generator__c();
            
            insert submission;
            submissionId = [SELECT Name FROM PRP_Submission_Number_Generator__c WHERE Id = :submission.Id Limit 1]?.Name;
            
            return submissionId;
        }
        
        public void createSiteRequests(List<PRP_Site_Request__c>  siteRequests) 
        {
            if (siteRequests?.size() > 0) upsert siteRequests;
        }

        public void linkOrDelinkSiteRequest(Set<Id> existingSiteIds, Map<Id, String> siteProductsMap, String subNumber)
        {
            List<PRP_Site__c> existingSites = new List<PRP_Site__c>();
            List<String> existingProducts = new List<String>();
            List<String> currentProducts = new List<String>();
            Map<Id, List<String>> deLinkSiteIdAndProductsMap = new Map<Id, List<String>>();
            Map<Id, List<String>> reLinkSiteIdAndProductsMap = new Map<Id, List<String>>();
            
            existingSites = [SELECT Id, Products__c FROM PRP_Site__c WHERE Id IN :existingSiteIds];
            System.debug('PJ -- existingSites : ' + existingSites);

            if (existingSites?.size() > 0) {
                for (PRP_Site__c s : existingSites) {
                    String newProducts = siteProductsMap.get(s.Id);
                    String oldProducts = s.Products__c;
                    System.debug('PJ -- newProducts : ' + newProducts);
                    System.debug('PJ -- oldProducts : ' + oldProducts);
                    if (newProducts != oldProducts) {
                        
                        if (String.isNotBlank(newProducts) && newProducts.contains(SEMICOLON)) {
                            currentProducts = newProducts.split(SEMICOLON);
                        } else if (String.isNotBlank(newProducts)) {
                            currentProducts.add(newProducts);
                        }
                        System.debug('PJ -- currentProducts : ' + currentProducts);

                        if (String.isNotBlank(oldProducts) && oldProducts.contains(SEMICOLON)) {
                            existingProducts = oldProducts.split(SEMICOLON);
                        } else if (String.isNotBlank(oldProducts)) {
                            existingProducts.add(oldProducts);
                        }
                        System.debug('PJ -- existingProducts : ' + existingProducts);

                        List<String> deLinkProducts = new List<String>();
                        for (String prd:existingProducts) {
                            if (!currentProducts.contains(prd)) {
                                deLinkProducts.add(prd);
                            }
                        }

                        System.debug('PJ -- deLinkProducts : ' + deLinkProducts);
                        if (deLinkProducts?.size() > 0) {
                            deLinkSiteIdAndProductsMap.put(s.Id, deLinkProducts);
                        }

                        List<String> reLinkProducts = new List<String>();
                        for (String prd:currentProducts) {
                            if (!existingProducts.contains(prd)) {
                                reLinkProducts.add(prd);
                            }
                        }

                        System.debug('PJ -- reLinkProducts : ' + reLinkProducts);
                        if (reLinkProducts?.size() > 0) {
                            reLinkSiteIdAndProductsMap.put(s.Id, reLinkProducts);
                        }
                    }
                }

                System.debug('PJ -- deLinkSiteIdAndProductsMap : ' + deLinkSiteIdAndProductsMap);

                if (!deLinkSiteIdAndProductsMap.isEmpty()) {
                    List<PRP_Site_Request__c> sitesRequests = new List<PRP_Site_Request__c>();
                    List<PRP_Site_Request__c> sitesRequests2delete = new List<PRP_Site_Request__c>();
                    
                    sitesRequests = [
                        SELECT Id, Site__c, Request__c, Request_Product__c 
                        FROM PRP_Site_Request__c 
                        WHERE Site__c IN :deLinkSiteIdAndProductsMap.keySet()
                    ];

                    System.debug('PJ -- sitesRequests : ' + sitesRequests);

                    for (PRP_Site_Request__c sr:sitesRequests) {
                        List<String> sitePrds = new List<String>();
                        sitePrds = deLinkSiteIdAndProductsMap.get(sr.Site__c);
                        if (sitePrds.contains(sr.Request_Product__c)) {
                            sitesRequests2delete.add(sr);
                        }
                    }

                    System.debug('PJ -- sitesRequests2delete : ' + sitesRequests2delete);

                    if (sitesRequests2delete?.size() > 0) {
                        delete sitesRequests2delete;
                    }
                }

                System.debug('PJ -- reLinkSiteIdAndProductsMap : ' + reLinkSiteIdAndProductsMap);
                if (!reLinkSiteIdAndProductsMap.isEmpty()) 
                {
                    List<PRP_Site_Request__c> sitesRequests2create = new List<PRP_Site_Request__c>();
                    Map<String, Id> existingRequestsProductMap = new Map<String, Id>();
                    
                    for (PRP_Request__c pr:[SELECT Id, Product_Name__c 
                                            FROM PRP_Request__c 
                                            WHERE Submission_Number__c = :subNumber])
                    {
                        existingRequestsProductMap.put(pr.Product_Name__c, pr.Id);
                    }

                    for (Id sId:reLinkSiteIdAndProductsMap.keySet()) {
                        for (String prd:reLinkSiteIdAndProductsMap.get(sId)){
                            if (existingRequestsProductMap.containsKey(prd))
                            {
                                PRP_Site_Request__c sr = new PRP_Site_Request__c();
                                sr.Request__c = existingRequestsProductMap.get(prd);
                                sr.Site__c	= sId;
                                sitesRequests2create.add(sr);
                            }
                        }
                    }

                    System.debug('PJ -- sitesRequests2create : ' + sitesRequests2create);
                    if (sitesRequests2create?.size() > 0) {
                        createSiteRequests(sitesRequests2create);
                    }
                }
            }
        }
        
        public void createContactRequests(List<PRP_Request_Contact__c>  contactRequests) 
        {
            if (contactRequests?.size() > 0) upsert contactRequests;
        }
        
        public void createAdditionContacts(List<PRP_Additional_Contact__c>  addtnlContacts) 
        {
            if (addtnlContacts?.size() > 0) upsert addtnlContacts;
        }
        
        public List<PRP_Site__c> getAddtnlSites(List<PRP_Site_Request__c>  siteRequests)
        {
            List<PRP_Site__c> addtnlSites = new List<PRP_Site__c>();
            Set<Id> siteIds = new Set<Id>();
            
            if (siteRequests?.size() > 0) 
            {
                for (PRP_Site_Request__c sr:siteRequests)
                {
                    siteIds.add(sr.site__c);
                }
            }
            addtnlSites = getAdditionalSites(siteIds);
            
            return addtnlSites;
        }
        
        //Delete Site and respective site request object records entries
        public void deleteSites(Set<Id> existingRequestIds, List<String> siteIds)
        {
            Boolean isOkToDeleteSites = false;
            List<Id> siteIdsToDelete = new List<Id>();
            List<PRP_Site__c> sites2delete = new List<PRP_Site__c>();
            List<PRP_Site_Request__c> sitesRequest2delete = new List<PRP_Site_Request__c>();
            List<PRP_Site_Request__c> otherRelatedSitesRequests = new List<PRP_Site_Request__c>();

            otherRelatedSitesRequests = [
                SELECT Id, Site__c 
                  FROM PRP_Site_Request__c 
                 WHERE Site__c IN :siteIds
                   AND Request__c NOT IN :existingRequestIds
            ];
            
            sitesRequest2delete = [
                SELECT Id, Site__c, Request__c, Request_Product__c 
                  FROM PRP_Site_Request__c 
                 WHERE Site__c IN :siteIds
                   AND Request__c IN :existingRequestIds
            ];
            System.debug('sites2delete: ' + sites2delete);
            System.debug('otherRelatedSitesRequests: ' + otherRelatedSitesRequests);
            System.debug('sitesRequest2delete: ' + sitesRequest2delete);
            
            if (sitesRequest2delete?.size() > 0) {
                if (otherRelatedSitesRequests?.size() > 0) {
                    Set<Id> otherRelatedSiteIds = new Set<Id>();
                    for (PRP_Site_Request__c osr:otherRelatedSitesRequests) {
                        otherRelatedSiteIds.add(osr.Site__c);
                    }
                    for (PRP_Site_Request__c sr:sitesRequest2delete) {
                        if (!otherRelatedSiteIds.contains(sr.Site__c)) {
                            siteIdsToDelete.add(sr.Site__c);
                        }
                    }
                } else {
                    siteIdsToDelete.addAll(siteIds);
                }
                delete sitesRequest2delete;
            }
            
            if (siteIdsToDelete?.size() > 0) {
                sites2delete = [SELECT Id FROM PRP_Site__c WHERE Id IN :siteIdsToDelete];
                if (sites2delete?.size() > 0){
                    delete sites2delete;
                }
            }
        }

        //Fetch Request Contacts junction object
        public void deleteAllContactRequests(Set<Id> existingRequestIds)
        {
            List<PRP_Request_Contact__c> contactRequests2Delete = new List<PRP_Request_Contact__c>();
            
            contactRequests2Delete = [
                SELECT Id, Additional_Contact__c, Additional_Contact__r.Product__c, Request__c, Request__r.Product_Name__c
                  FROM PRP_Request_Contact__c 
                 WHERE Request__c IN :existingRequestIds
            ];

            if (contactRequests2Delete?.size() > 0)
            {
                delete contactRequests2Delete;
            }
        }

        //Delete Contact and respective contact request object records entries
        public void deleteContacts(Set<Id> existingRequestIds, List<String> contactIdsToBeDeleted)
        {
            Boolean isOkToDeleteContacts = false;
            List<PRP_Additional_Contact__c> contacts2delete = new List<PRP_Additional_Contact__c>();
            List<PRP_Request_Contact__c> contactRequest2delete = new List<PRP_Request_Contact__c>();
            List<PRP_Request_Contact__c> allRelatedContactRequest = new List<PRP_Request_Contact__c>();
            
            contacts2delete = [SELECT Id FROM PRP_Additional_Contact__c WHERE Id IN :contactIdsToBeDeleted];

            allRelatedContactRequest = [SELECT Id FROM PRP_Request_Contact__c WHERE Additional_Contact__c IN :contactIdsToBeDeleted];
            
            contactRequest2delete = [
                SELECT Id
                  FROM PRP_Request_Contact__c 
                 WHERE Additional_Contact__c IN :contactIdsToBeDeleted
                   AND Request__c IN :existingRequestIds
            ];
            System.debug('contacts2delete: ' + contacts2delete);
            System.debug('contactRequest2delete: ' + contactRequest2delete);
            System.debug('allRelatedContactRequest: ' + allRelatedContactRequest);
            
            if (contactRequest2delete?.size() > 0){
                if (contactRequest2delete?.size() == allRelatedContactRequest?.size()) {
                    isOkToDeleteContacts = true;
                }
                delete contactRequest2delete;
            }
            
            if (contacts2delete?.size() > 0 && isOkToDeleteContacts){
                delete contacts2delete;
            }
        }

        //Generate PDF and Save as an attachment
        public void saveRequestsAsPdf(Set<Id> reqIds){
            List<Attachment> attachments = new List<Attachment>();
            List<PRP_Request__c> requests = new List<PRP_Request__c>();  

            requests = getRequest(reqIds);
            for (PRP_Request__c req:requests) {
                Attachment att = new Attachment();
                Pagereference pdf = Page.PRP_RequestSummaryPDF;

                // add the request id to the parameters for standardcontroller
                String reqId = req.Id;
                pdf.getParameters().put('id', reqId);
                att.Body = pdf.getContent();
                att.Name = req.Name + ' Version ' + req.Request_PDF_Version_Number__c;
                att.IsPrivate = false;
                att.ParentId = req.Id;
                att.ContentType = 'application/pdf';
                attachments.add(att);
            }

            if (attachments?.size() > 0){
                insert attachments;
            }
        }
    }
}