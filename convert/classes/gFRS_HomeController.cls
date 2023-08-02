/**
*  Controller specific to the Home Page
**/
public with sharing class gFRS_HomeController {
    
    public Boolean isCopayUser { get; set; }
    
    public String debugPrefix = 'gFRS_HomeController ';
    
    //-- Lookup Constants
    /** The type of page this is **/
    public static final String CONTENT_TYPE = 'Homepage';
    
    /** final page to move to after completing the page **/
    public static final String PATH_ORG_INFO = '/apex/gFRS_Org_Info';
    public static final String PATH_ORG_INFOcopay = '/apex/gFRS_Org_Infocopay';
    
    /** decision page **/
    public static final String PATH_DECISION = '/apex/gFRS_Decision';
    
    /** List of translations **/
    public Map<String, String> contentItems { get; set; }
    
    public Date lockOutDate{ get; set; }
    
    public Date lockOutDate2{ get; set; }
    
    /** List of tasks for the specific user **/
    public List<gFRS_Tasks__c> myRequiredTasks { get; set; }
    
    /** List of tasks for the specific user **/
    public List<gFRS_Copay_Task__c> myRequiredCopayTasks { get; set; }
    
    /** List of tasks (Status report and Outcomse only)for the specific user **/
    public List<gFRS_Tasks__c> onGoingTasks { get; set; }
    
    /** List of tasks (Status report and Outcomse only)for the specific usr **/
    public List<gFRS_Copay_Task__c> onCopayGoingTasks { get; set; }
    
    /*flag to keep information if imedTask size >0 */
    public Boolean isOnGoingTaskListFilled { get; set; }
    
    /** Whether the Task Pop-up is shown **/
    public Boolean isTaskPopShown { get; set; }
    
    /** Id of the Funding Request to modify **/
    public Id currentRequestId { get; set; }
    
    public Boolean isCloneButtonVisible { get; set; }
    
    /** Current task to inspect **/
    public gFRS_Tasks__c currentTask { get; set; }
    
    /** Current Funding Request **/
    private GFRS_Funding_Request__c fundingRequest;
    
    /** List of Funding Requests to be displayed**/
    public GFRS_Funding_Request__c[] lFundingRequests { get; set; }
    public gFRS_Copay_Funding_Request__c[] lFundingRequestscopay { get; set; }
    
    /** The contact that represents the current user **/
    public Contact userContact;
    public User currentUser;
    
    /** Whether the user is associated with an organization ( true ) or not (false) **/
    public GFRS_Organization__c userOrganization { get; set; }
    
    public String welcomeMessage { get {return(this.contentItems.get('Welcome'));} }
    
    public Boolean isInternal { get {return(userContact == null);} }
    
    public Integer noOfRecords { get; set; }
    public Integer noOfRecordsCopay { get; set; }
    public Integer size { get; set; }
    public Integer sizeCopay { get; set; }
    public String selectedPageNumber { get; set; }
    public String selectedPageNumberCopay { get; set; }
    public Id requestIDToClone { get; set; }
    public Id organizationIDToClone { get; set; }
    public Id locationToClone { get; set; }
    public GFRS_Funding_Request__c clonedRequest { get; set; }
    public Boolean displayCloningPopUp { get; set; }
    public Boolean displayBlockReconciliaitonPopUp { get; set; }
    public Boolean displayBlockReconciliaitonPopUpStatusUpdate { get; set; }
    public Boolean displayBlockEvaluationPopUpSunshineAct { get; set; }
    public Boolean displayBlockAnnualReportPopUp { get; set; }
    
    public Map<Id, Boolean> paymentInfoVisibilityForRequest { get; set; }
    public Map<Id, Boolean> cloneLinkVisibilityForRequest { get; set; }
    
    public Map<Id, Boolean> paymentInfoVisibilityForRequestCopay { get; set; }
    public Map<Id, Boolean> cloneLinkVisibilityForRequestCopay { get; set; }
    
    
    public Profile userProfile;
    public Map<String, String> annualEvalTasksByRequest { get; set; }
    
    public String clonedRequestName {
        get {
            if (clonedRequest != null) {
                return clonedRequest.Name;
            } else {
                return '';
            }
        }
        set;
    }
    
    public void closeCloningPopup() {
        displayCloningPopUp = false;
    }
    public void showCloningPopup() {
        displayCloningPopUp = true;
    }
    
    public void closeBlockReconciliaitonPopup() {
        displayBlockReconciliaitonPopUp = false;
        currentRequestId = null;
    }
    public void showBlockReconciliaitonPopup() {
        displayBlockReconciliaitonPopUp = true;
    }
    public void checkIfStatusUpdateTaskIsCompleted() {
        if (this.isOnGoingTaskListFilled == true) {
            for (gFRS_Tasks__c task : onGoingTasks) {
                if (task.gFRS_Funding_Request__c == currentRequestId && task.Action_Type__c == 'Status Report' && task.Status__c != 'Completed') {
                    displayBlockReconciliaitonPopUpStatusUpdate = true;
                }
            }
        }
    }
    public void closeBlockReconciliaitonPopupStatusUpdate() {
        displayBlockReconciliaitonPopUpStatusUpdate = false;
        currentRequestId = null;
    }
    
    public void checkIfSunshineActTaskIsCompleted() {
        for (gFRS_Tasks__c task : myRequiredTasks) {
            if (task.gFRS_Funding_Request__c == currentRequestId && task.Action_Type__c == 'Sunshine Act Disclosure' && task.gFRS_Funding_Request__r.Sunshine_Act_Disclosure_Submitted__c != 'Yes') {
                displayBlockEvaluationPopUpSunshineAct = true;
            }
        }
    }
    
    public void closeBlockEvaluationPopupSunshineAct() {
        displayBlockEvaluationPopUpSunshineAct = false;
        currentRequestId = null;
    }       
    
    //Annual Report
    public void closeBlockAnnualReportPopup() {
        displayBlockAnnualReportPopUp = false;
    }
    public void showBlockAnnualReportPopup() {
        displayBlockAnnualReportPopUp = true;
    }
    
    
    /** 
* @Author ADMD Team
* @date 05/02/2013
* @description checkIfUserIsExternalRequester property - return true if user profile name is  GNE-GFRS-External Requestor
*/
    
    public Boolean checkIfUserIsExternalRequester {
        get {
            return gFRS_Util_NoShare.checkIfUserIsExternalRequester(UserInfo.getProfileId());
        }
    }
    
    /** 
* @Author ADMD Team
* @date 07/28/2014
* @description setCon property - return standard set controller resposible for collection pagination
*/
    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null) {
                size = 25;
                String userId = UserInfo.getUserId().center(20, '\'');
                
                String queryString = String.join(new String[]{
                    'SELECT Sunshine_Act_Disclosure_Submitted__c, OwnerId, Id,Funding_Sub_Type__c, Name, CreatedDate, Evaluation_submitted_date__c, ',
                        'Event_Program_Title__c, Date_Submitted__c, Requested_Amount__c, Approved_Amount__c, Sub_Status__c, External_Sub_status__c, SYS_Request_Approved__c,',
                        'Record_Type_Name__c, Organization__c,LOA_Signed__c,Location__c,LOA_PDF__c,Authorized_Signer__c, Status__c,',
                        '(SELECT Payment_Method__c, SAP_Payment_Sent_Date__c, Encashment_Date__c, Check_Number__c FROM Payment_History__r ',
                        'WHERE Status__c  NOT IN (\'Error\',\'Canceled\') AND Payment_Sub_status__c NOT IN (\'Error\',\'Void\',\'Void/Reissue\',\'Refund\') ',
                        'ORDER BY CreatedDate DESC LIMIT 1)',
                        'FROM GFRS_Funding_Request__c',
                        'WHERE',
                        '(',
                        'Authorized_Signer__c =', userId, ' AND Record_Type_Name__c!=\'Field Initiated Exhibits\'',
                        'AND',
                        '(',
                        '(Status__c IN (\'Processing & Disposition\') AND Sub_Status__c IN (\'Process Payment\', \'RFI\', \'RFI Received\'))',
                        'OR (Status__c = \'Closed\' AND External_Sub_status__c = \'Approved\')',
                        ')',
                        ')',
                        'OR (OwnerId =', userId, ' AND Status__c != \'Intake\')',
                        'ORDER BY Date_Submitted__c DESC ,CreatedDate  DESC'
                        }, ' ');
                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }
        set;
    }
    
    
    public ApexPages.StandardSetController setConCopay {
        get {
            noOfRecordsCopay = 0;
            sizeCopay = 25;
            if (Schema.SObjectType.gFRS_Copay_Funding_Request__c.isAccessible()) {
                
                
                if (setConCopay == null) {
                    String userId = UserInfo.getUserId().center(20, '\'');
                    
                    String queryString = String.join(new String[]{
                        
                        'SELECT  OwnerId, Id,Funding_Sub_Type__c, Name, CreatedDate, Donation_requested_for_quarter__c, Evaluation_submitted_date__c, ',
                            'Event_Program_Title__c, Date_Submitted__c, Requested_Amount__c, Requested_Amount1__c , Sub_Status__c, External_Sub_status__c,',
                            'Record_Type_Name__c, Organization__c,LOA_Signed__c, Locationcopay__c,LOA_PDF__c,Authorized_Signer__c, Status__c,',
                            '(SELECT Payment_Method__c, SAP_Payment_Sent_Date__c, Encashment_Date__c, Check_Number__c FROM gFRS_Payment_Refund_History__r ',
                            'WHERE Status__c  NOT IN (\'Error\',\'Canceled\') AND Payment_Sub_status__c NOT IN (\'Error\',\'Void\',\'Void/Reissue\',\'Refund\') ',
                            'ORDER BY CreatedDate DESC LIMIT 1)',
                            'FROM GFRS_copay_Funding_Request__c',
                            'WHERE',
                            '(',
                            'Authorized_Signer__c =', userId, ' AND Record_Type_Name__c!=\'Field Initiated Exhibits\'',
                            'AND',
                            '(',
                            '(Status__c IN (\'Processing & Disposition\') AND Sub_Status__c IN (\'Process Payment\', \'RFI\', \'RFI Received\'))',
                            'OR (Status__c = \'Closed\' AND External_Sub_status__c = \'Approved\')',
                            ')',
                            ')',
                            'OR (OwnerId =', userId, ' AND Status__c != \'Intake\')',
                            'ORDER BY CreatedDate  DESC'
                            }, ' ');
                    
                    
                    setConCopay = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    setConCopay.setPageSize(sizeCopay);
                    noOfRecordsCopay = setConCopay.getResultSize();
                }
                return setConCopay;
                
            }
            return null;
            
        }
        set;
    }
    
    
    /** 
* @Author ADMD Team
* @date 07/28/2014
* @description getFoundingRequests property - return collection of founding request from salected page
*/
    public List<GFRS_Funding_Request__c> getFoundingRequests() {
        
        System.debug(debugPrefix + '***** getFoundingRequests ****');
        
        List<GFRS_Funding_Request__c> frList = new List<GFRS_Funding_Request__c>();
        
        
        //JIRA -159
        //
        Map<Id, GFRS_Funding_Request__c> mapfrequest = new Map<Id, GFRS_Funding_Request__c>();
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        
        if(userProfile.Name=='GNE-GFRS-Backoffice'){
            String userId = UserInfo.getUserId().center(20, '\'');
            
            String queryString = String.join(new String[]{
                'SELECT Sunshine_Act_Disclosure_Submitted__c, OwnerId, Id,Funding_Sub_Type__c, Name, CreatedDate, Evaluation_submitted_date__c, ',
                    'Event_Program_Title__c, Date_Submitted__c, Requested_Amount__c, Approved_Amount__c, Sub_Status__c, External_Sub_status__c, SYS_Request_Approved__c,',
                    'Record_Type_Name__c, Organization__c,LOA_Signed__c,Location__c,LOA_PDF__c,Authorized_Signer__c, Status__c,',
                    '(SELECT Payment_Method__c, SAP_Payment_Sent_Date__c, Encashment_Date__c, Check_Number__c FROM Payment_History__r ',
                    'WHERE Status__c  NOT IN (\'Error\',\'Canceled\') AND Payment_Sub_status__c NOT IN (\'Error\',\'Void\',\'Void/Reissue\',\'Refund\') ',
                    'ORDER BY CreatedDate DESC LIMIT 1)',
                    'FROM GFRS_Funding_Request__c',
                    'WHERE',
                    '(',
                    'Record_Type_Name__c!=\'Field Initiated Exhibits\'',
                    'AND',
                    '(',
                    '(Status__c IN (\'Processing & Disposition\') AND Sub_Status__c IN (\'Process Payment\', \'RFI\', \'RFI Received\'))',
                    'OR (Status__c = \'Closed\' AND External_Sub_status__c = \'Approved\')',
                    ')',
                    ')',
                     'OR (createdbyId =', userId, ' AND Status__c != \'Intake\')',
                    'ORDER BY Date_Submitted__c DESC ,CreatedDate  DESC'
                    }, ' ');
            
            List<GFRS_Funding_Request__c> lstbackoffice=Database.Query(queryString);
            
            for(GFRS_Funding_Request__c f:lstbackoffice){
                
                frList.add(f);
                mapfrequest.put(f.id,f);
                System.debug(debugPrefix + '***** getFoundingRequests **** f: ' + f);
                
                cloneLinkVisibilityForRequest.put(f.Id, isCloneLinkVisible(f));
                paymentInfoVisibilityForRequest.put(f.Id, isPaymentInfoVisible(f));
                
            }            
            
            
        }
        for (GFRS_Funding_Request__c f : (List<GFRS_Funding_Request__c>) setCon.getRecords()) {
            
            
            if(mapfrequest.size()>0 && !mapfrequest.containskey(f.id) && showFundingRequest(f)){
                
                frList.add(f);
            }
            
            if(mapfrequest.isEmpty() && showFundingRequest(f)){
                
                frList.add(f);
            }
            
            
            System.debug(debugPrefix + '***** getFoundingRequests **** f: ' + f);
            
            cloneLinkVisibilityForRequest.put(f.Id, isCloneLinkVisible(f));
            paymentInfoVisibilityForRequest.put(f.Id, isPaymentInfoVisible(f));
            
        }
        
        System.debug(debugPrefix + '***** getFoundingRequests **** Stop: ' + cloneLinkVisibilityForRequest);
        return frList;
    }
    
    
    public List<gFRS_Copay_Funding_Request__c> getFoundingRequestscopay() {
        
        
        if (Schema.SObjectType.gFRS_Copay_Funding_Request__c.isAccessible()) {
            
            System.debug(debugPrefix + '***** getFoundingRequests ****');
            
            List<gFRS_Copay_Funding_Request__c> frList = new List<gFRS_Copay_Funding_Request__c>();
            List<gFRS_Copay_Funding_Request__c> frList1 = new List<gFRS_Copay_Funding_Request__c>();
            
            
            String userId = UserInfo.getUserId().center(20, '\'');
            
            String queryString = String.join(new String[]{
                
                'SELECT  OwnerId, Id,Funding_Sub_Type__c, Name, CreatedDate, Donation_requested_for_quarter__c, Evaluation_submitted_date__c, ',
                    'Event_Program_Title__c, Date_Submitted__c, Requested_Amount__c, Requested_Amount1__c, Approved_Amount__c, Sub_Status__c, External_Sub_status__c,',
                    'Record_Type_Name__c, Organization__c,LOA_Signed__c, Locationcopay__c,LOA_PDF__c,Authorized_Signer__c, Status__c,',
                    '(SELECT Payment_Method__c, SAP_Payment_Sent_Date__c, Encashment_Date__c, Check_Number__c FROM gFRS_Payment_Refund_History__r ',
                    'WHERE Status__c  NOT IN (\'Error\',\'Canceled\') AND Payment_Sub_status__c NOT IN (\'Error\',\'Void\',\'Void/Reissue\',\'Refund\') ',
                    'ORDER BY CreatedDate DESC LIMIT 1)',
                    'FROM GFRS_copay_Funding_Request__c',
                    'WHERE',
                    '(',
                    'Authorized_Signer__c =', userId, ' AND Record_Type_Name__c!=\'Field Initiated Exhibits\'',
                    'AND',
                    '(',
                    '(Status__c IN (\'Processing & Disposition\') AND Sub_Status__c IN (\'Process Payment\', \'RFI\', \'RFI Received\'))',
                    'OR (Status__c = \'Closed\' AND External_Sub_status__c = \'Approved\')',
                    ')',
                    ')',
                    'OR (OwnerId =', userId, ' AND Status__c != \'Intake\')',
                    'ORDER BY CreatedDate  DESC'
                    }, ' ');
            
            frList1 = Database.query(queryString);
            
            
            /*

for(GFRS_copay_Funding_Request__c f : frList1){

frList.add(f);

System.debug(debugPrefix + '***** getFoundingRequests **** f: ' + f);

cloneLinkVisibilityForRequestcopay.put(f.Id, isCloneLinkVisiblecopay(f));
paymentInfoVisibilityForRequestcopay.put(f.Id, isPaymentInfoVisiblecopay(f));

}*/
            
            
            for (gFRS_Copay_Funding_Request__c f : (List<gFRS_Copay_Funding_Request__c>) setConCopay.getRecords()) {
                
                frList.add(f);
                
                System.debug(debugPrefix + '***** getFoundingRequests **** f: ' + f);
                
                cloneLinkVisibilityForRequestCopay.put(f.Id, isCloneLinkVisiblecopay(f));
                paymentInfoVisibilityForRequestCopay.put(f.Id, isPaymentInfoVisiblecopay(f));
                
            }
            
            System.debug(debugPrefix + '***** getFoundingRequests **** Stop: ' + cloneLinkVisibilityForRequest);
            return frList;
            
            
            //System.debug(debugPrefix + '***** getFoundingRequests **** Stop: ' + cloneLinkVisibilityForRequestcopay);
            // return frList;
            
        } else {
            return null;
        }
        
        
    }
    
    
    private Boolean isPaymentInfoVisible(GFRS_Funding_Request__c fundreq) {
        
        Boolean result = false;
        
        System.debug('KK: IS INTERNAL REQUEST: ' + gFRS_Util.isInternalRequest(fundreq.Record_Type_Name__c));
        
        // rules for internal requests
        if (gFRS_Util.isInternalRequest(fundreq.Record_Type_Name__c)) {
            if (fundreq.Status__c == 'Processing & Disposition' && (fundreq.Sub_Status__c == 'Process Payment' || fundreq.Sub_Status__c == 'RFI' || fundreq.Sub_Status__c == 'RFI Received')) {
                result = true;
            }
            
            if (fundreq.Status__c == 'Closed' && fundreq.Sub_Status__c == 'Approved') {
                result = true;
            }
        }
        
        // rules for external requests
        else {
            if (fundreq.Status__c == 'Processing & Disposition' && fundreq.External_Sub_status__c != 'Approved-Awaiting LOA') {
                result = true;
            }
            
            if (fundreq.Status__c == 'Closed' && fundreq.External_Sub_status__c == 'Approved') {
                result = true;
            }
            
        }
        
        System.debug('KK: isPaymentInfoVisible: ' + result);
        
        return result;
        
    }
    
    
    private Boolean isPaymentInfoVisiblecopay(gFRS_Copay_Funding_Request__c fundreq) {
        
        Boolean result = false;
        
        System.debug('KK: IS INTERNAL REQUEST: ' + gFRS_Util.isInternalRequest(fundreq.Record_Type_Name__c));
        
        // rules for internal requests
        if (gFRS_Util.isInternalRequest(fundreq.Record_Type_Name__c)) {
            if (fundreq.Status__c == 'Processing & Disposition' && (fundreq.Sub_Status__c == 'Process Payment' || fundreq.Sub_Status__c == 'RFI' || fundreq.Sub_Status__c == 'RFI Received')) {
                result = true;
            }
            
            if (fundreq.Status__c == 'Closed' && fundreq.Sub_Status__c == 'Approved') {
                result = true;
            }
        }
        
        // rules for external requests
        else {
            if (fundreq.Status__c == 'Processing & Disposition' && fundreq.External_Sub_status__c != 'Approved-Awaiting LOA') {
                result = true;
            }
            
            if (fundreq.Status__c == 'Closed' && fundreq.External_Sub_status__c == 'Approved') {
                result = true;
            }
            
        }
        
        System.debug('KK: isPaymentInfoVisible: ' + result);
        
        return result;
        
    }
    
    
    private Boolean isCloneLinkVisible(GFRS_Funding_Request__c fundingRequest) {
        
        System.debug(debugPrefix + '***** isCloneLinkVisible **** Start');
        Boolean result = false;
        
        if (fundingRequest.Status__c != gFRS_Util.REQUEST_DEFAULT_STATUS && fundingRequest.OwnerId == UserInfo.getUserId()) {
            //request was submitted so we have green light to check more conditions
            
            if (userProfile.Name == gFRS_Util.PROFILE_NAME_GNEGFRSEXTERNALREQUESTOR) {
                //External User
                System.debug(debugPrefix + '***** isCloneLinkVisible **** external user');
                if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME || fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME) {
                    result = true;
                }
                
                
            } else {
                //Internal User
                System.debug(debugPrefix + '***** isCloneLinkVisible **** internal user');
                System.debug(debugPrefix + '***** isCloneLinkVisible **** internal user1: ' + gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME);
                System.debug(debugPrefix + '***** isCloneLinkVisible **** internal user2: ' + fundingRequest.Record_Type_Name__c);
                if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME || fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME || fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
                    result = true;
                }
            }
        } else {
            //There should not be ability to clone not submitted requests
            result = false;
        }
        
        System.debug(debugPrefix + '***** isCloneLinkVisible **** Stop: ' + result);
        
        return result;
    }
    
    
    private Boolean isCloneLinkVisiblecopay(gFRS_Copay_Funding_Request__c fundingRequest) {
        
        System.debug(debugPrefix + '***** isCloneLinkVisible **** Start');
        Boolean result = false;
        
        if (fundingRequest.Status__c != gFRS_Util.REQUEST_DEFAULT_STATUS && fundingRequest.OwnerId == UserInfo.getUserId()) {
            //request was submitted so we have green light to check more conditions
            
            if (userProfile.Name == gFRS_Util.PROFILE_NAME_GNEGFRSEXTERNALREQUESTOR) {
                //External User
                System.debug(debugPrefix + '***** isCloneLinkVisible **** external user');
                if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME || fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME) {
                    result = true;
                }
                
                
            } else {
                //Internal User
                System.debug(debugPrefix + '***** isCloneLinkVisible **** internal user');
                System.debug(debugPrefix + '***** isCloneLinkVisible **** internal user1: ' + gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME);
                System.debug(debugPrefix + '***** isCloneLinkVisible **** internal user2: ' + fundingRequest.Record_Type_Name__c);
                if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME || fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME || fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
                    result = true;
                }
            }
        } else {
            //There should not be ability to clone not submitted requests
            result = false;
        }
        
        System.debug(debugPrefix + '***** isCloneLinkVisible **** Stop: ' + result);
        
        return result;
    }
    
    
    /**
* @Author ADMD Team
* @date 07/28/2014
* @description hasNext property - checks if collection have more rows
*/
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    
    public Boolean hasNextcopay {
        get {
            
            
            if (Schema.SObjectType.gFRS_Copay_Funding_Request__c.isAccessible()) {
                return setConCopay.getHasNext();
            } else {
                return null;
            }
            
            
        }
        set;
    }
    
    
    /**
* @Author ADMD Team
* @date 07/28/2014
* @description hasPrevious property - checks if there is previous page for paginated collection
*/
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    
    public Boolean hasPreviousCopay {
        get {
            
            if (Schema.SObjectType.gFRS_Copay_Funding_Request__c.isAccessible()) {
                return setConCopay.getHasPrevious();
            } else {
                return null;
            }
        }
        set;
    }
    
    
    /**
* @Author ADMD Team
* @date 07/28/2014
* @description pageNumber property - return current page number of paginated collection
*/
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    public Integer pageNumberCopay {
        get {
            
            if (Schema.SObjectType.gFRS_Copay_Funding_Request__c.isAccessible()) {
                return setConCopay.getPageNumber();
            } else {
                return null;
            }
            
        }
        set;
    }
    
    /** 
* @Author ADMD Team
* @date 07/28/2014
* @description previous method - return collection of Funding Request from prevois paginated collection 
*/
    public void previous() {
        setCon.previous();
        this.lFundingRequests = getFoundingRequests();
        this.lFundingRequestscopay = getFoundingRequestscopay();
        selectedPageNumber = '';
    }
    
    
    public void previousCopay() {
        setConCopay.previous();
        // this.lFundingRequests=getFoundingRequests();
        this.lFundingRequestscopay = getFoundingRequestscopay();
        selectedPageNumberCopay = '';
    }
    
    
    /** 
* @Author ADMD Team
* @date 07/28/2014
* @description nextSet method - return collection of Funding Request for next page of paginated collection 
*/
    public void nextSet() {
        setCon.next();
        this.lFundingRequests = getFoundingRequests();
        // this.lFundingRequestscopay=getFoundingRequestscopay();
        selectedPageNumber = '';
    }
    
    
    public void nextSetCopay() {
        setConCopay.next();
        // this.lFundingRequests=getFoundingRequests();
        this.lFundingRequestscopay = getFoundingRequestscopay();
        selectedPageNumberCopay = '';
    }
    
    /**
* @Author ADMD Team
* @date 07/28/2014
* @description goToPage method - return collection of Funding Request for specific page of paginated collection
*/
    public void goToPage() {
        
        try {
            Integer pageNum = Integer.valueOf(selectedPageNumber);
            if (Math.mod(noOfRecords, size) == 0 && pageNum > noOfRecords / size || pageNum < 1) {
                setCon.setPageNumber(1);
                selectedPageNumber = '1';
            } else if (Math.mod(noOfRecords, size) != 0 && pageNum > (Math.floor(noOfRecords / size) + 1)) {
                setCon.setPageNumber(1);
                selectedPageNumber = '1';
            } else {
                setCon.setPageNumber(pageNum);
            }
            
            if (pageNum == 0) {
                selectedPageNumber = null;
            }
        } catch (Exception ex) {
            setCon.setPageNumber(1);
            selectedPageNumber = '1';
        }
        this.lFundingRequests = getFoundingRequests();
        //   this.lFundingRequestscopay=getFoundingRequestscopay();
        
    }
    
    
    public void goToPageCopay() {
        
        try {
            Integer pageNum = Integer.valueOf(selectedPageNumberCopay);
            if (Math.mod(noOfRecordsCopay, sizeCopay) == 0 && pageNum > noOfRecordsCopay / sizeCopay || pageNum < 1) {
                setConCopay.setPageNumber(1);
                selectedPageNumberCopay = '1';
            } else if (Math.mod(noOfRecordsCopay, sizeCopay) != 0 && pageNum > (Math.floor(noOfRecordsCopay / sizeCopay) + 1)) {
                setConCopay.setPageNumber(1);
                selectedPageNumberCopay = '1';
            } else {
                setConCopay.setPageNumber(pageNum);
            }
            
            if (pageNum == 0) {
                selectedPageNumberCopay = null;
            }
        } catch (Exception ex) {
            setConCopay.setPageNumber(1);
            selectedPageNumberCopay = '1';
        }
        //    this.lFundingRequests=getFoundingRequests();
        this.lFundingRequestscopay = getFoundingRequestscopay();
        
    }
    
    
    public gFRS_HomeController(ApexPages.StandardController std) {
        
        lockOutDate = Date.today();
        lockOutDate = lockOutDate.addDays(-91);
        
        lockOutDate2 = Date.today();
        lockOutDate2 = lockOutDate2.addDays(-31);
        
        System.debug(debugPrefix + '***** gFRS_HomeController controller ****');
        List<GFRS_CopayUser__c> lstcopayuser = new List<GFRS_CopayUser__c>();
        lstcopayuser = [SELECT User__r.Email FROM GFRS_CopayUser__c WHERE User__r.Email = :UserInfo.getUserEmail()];
        isCopayUser = false;
        if (lstcopayuser.size() > 0) {
            isCopayUser = true;
        }
        //-- get organization
        cloneLinkVisibilityForRequest = new Map<Id, Boolean>();
        paymentInfoVisibilityForRequest = new Map<Id, Boolean>();
        cloneLinkVisibilityForRequestCopay = new Map<Id, Boolean>();
        paymentInfoVisibilityForRequestCopay = new Map<Id, Boolean>();
        
        userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        userContact = gFRS_Utilcopay.getUserContact(UserInfo.getUserId());
        this.userOrganization = gFRS_Util.getContactOrganization(userContact);
        System.debug('userOrganization:' + this.userOrganization);
        
        this.fundingRequest = (GFRS_Funding_Request__c) std.getRecord();
        
        this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter(CONTENT_TYPE, UserInfo.getLanguage());
        
        this.lFundingRequests = new GFRS_Funding_Request__c[]{
        };
            this.lFundingRequestscopay = new gFRS_Copay_Funding_Request__c[]{
            };
                
                this.refreshFundingRequests();
        this.refreshFundingRequestsCopay();
        
        //profilesMap = new Map<Id, Profile>([ SELECT Id, Name FROM Profile WHERE Name IN ('GNE-GFRS-Admin', 'GNE-GFRS-External Requestor', 'GNE-GFRS-Super User', 'System Administrator')]);
        
        //-- ensure the tasks are not shown initially
        this.isTaskPopShown = false;
        this.isCloneButtonVisible = checkIfCloneButtonVisible();
    }
    
    public Boolean checkIfCloneButtonVisible() {
        if (!checkIfUserIsExternalRequester) {
            Group mcs = [SELECT Id, Name FROM Group WHERE Name = :gFRS_Util.MCS_GROUP_NAME LIMIT 1];
            if (mcs != null && mcs.Id != null) {
                if ([SELECT GroupId, Id, UserOrGroupId FROM GroupMember WHERE GroupId = :mcs.Id AND UserOrGroupId = :UserInfo.getUserId()].size() > 0) {
                    //curret user is member of 'GNE-GFRS-M&CS' public group and clone button should be visible
                    return true;
                }
            }
        }
        return false;
    }
    /**
*  Provides the Org Info page
**/
    public PageReference goOrgInfo() {
        return(new PageReference(gFRS_Util.initializeLink(PATH_ORG_INFO, null, 'soc=soc')));
    }
    
    
    /**
*  Moves to the next page
**/
    public PageReference next() {
        Id orgId = null;
        if (this.userOrganization != null) orgId = this.userOrganization.Id;
        
        if (this.userOrganization != null) {
            return(new PageReference(gFRS_Util.initializeLink(PATH_ORG_INFO, null, 'org=' + orgId)));
        } else {
            return(new PageReference(gFRS_Util.initializeLink(PATH_ORG_INFO, null, null)));
        }
    }
    
    
    public PageReference nextcopay2() {
        Id orgId = null;
        if (this.userOrganization != null) orgId = this.userOrganization.Id;
        
        if (this.userOrganization != null) {
            return(new PageReference(gFRS_Util.initializeLink(PATH_ORG_INFOcopay, null, 'org=' + orgId)));
        } else {
            return(new PageReference(gFRS_Util.initializeLink(PATH_ORG_INFOcopay, null, null)));
        }
    }
    
    
    /**
* Fetches the list of Funding requests.
* <p>Postcondition: this.lFundingRequests is populated with funding requests</p>
**/
    private void refreshFundingRequests() {
        //-- ONLY show the funding requests they belong to if they are an internal user or they have been assigned to an account
        Id userId = UserInfo.getUserId();
        this.lFundingRequests = getFoundingRequests();
        // this.lFundingRequestscopay = getFoundingRequestscopay();
        List<GFRS_Funding_Request__c> listOfTempRequests = new List<GFRS_Funding_Request__c>([
            SELECT Funding_Sub_Type__c,Id, Name, CreatedDate, Event_Program_Title__c, Date_Submitted__c, Evaluation_submitted_date__c, Requested_Amount__c, Sub_Status__c, External_Sub_status__c, Status__c, Record_Type_Name__c, Organization__c,LOA_Signed__c,Location__c,LOA_PDF__c,Authorized_Signer__c
            FROM GFRS_Funding_Request__c
            WHERE Authorized_Signer__c = :userId OR OwnerId = :userId
            ORDER BY Date_Submitted__c DESC, CreatedDate DESC
        ]);
        /**getting task for current user **/
        this.myRequiredTasks = gFRS_Util_NoShare.fetchUserTasks(listOfTempRequests, userId);
        annualEvalTasksByRequest = new Map<String, String>();
        
        for (gFRS_Tasks__c myTask : myRequiredTasks) {
            if (myTask.Action_Type__c == System.Label.gFRS_Annual_Evaluation) {
                if (annualEvalTasksByRequest.get(myTask.gFRS_Funding_Request__c) == null) {//already sorted per request- by creation date (equivalent of rule trigger date)
                    annualEvalTasksByRequest.put(myTask.gFRS_Funding_Request__c, myTask.Id);
                }
            }
        }
        
        /** Remove RFI Tasks if user is authorized signer **/
        List<gFRS_Tasks__c> tasksWithoutRFI = new List<gFRS_Tasks__c>();
        if (this.myRequiredTasks != null) {
            for (gFRS_Tasks__c t : this.myRequiredTasks) {
                if ((t.Action_Type__c.containsIgnoreCase('RFI') || t.Action_Type__c == 'Status Report') && t.gFRS_Funding_Request__r.Authorized_Signer__c == userId && t.gFRS_Funding_Request__r.OwnerId != userId) {
                    continue;
                } else {
                    tasksWithoutRFI.add(t);
                }
            }
            this.myRequiredTasks = tasksWithoutRFI;
        }
        
        /**Removing LOA Task if user isn't authorized signer**/
        List<gFRS_Tasks__c> tmpListOfTask = new List<gFRS_Tasks__c>();
        List<gFRS_Tasks__c> tmpListOngoingTask = new List<gFRS_Tasks__c>();
        List<gFRS_Tasks__c> tmpListOngoingTask1 = new List<gFRS_Tasks__c>();
        this.onGoingTasks = gFRS_Util_NoShare.fetchUserOngoingTasks(listOfTempRequests, userId);
        try {
            if (this.onGoingTasks != null) {
                //Below loop agregate ongoing task, fix order Status Report and Outcomes tasks
                for (Integer i = 0; i < this.onGoingTasks.size(); i++) {
                    if (this.onGoingTasks.size() >= i + 2 && this.onGoingTasks[i + 1].gFRS_Funding_Request__r.Name == this.onGoingTasks[i].gFRS_Funding_Request__r.Name) {
                        if (this.onGoingTasks[i].Action_Type__c == 'Status Report') {
                            tmpListOngoingTask.add(this.onGoingTasks[i]);
                            tmpListOngoingTask.add(this.onGoingTasks[i + 1]);
                            i++;
                        } else if (this.onGoingTasks[i].Action_Type__c == 'Outcomes') {
                            tmpListOngoingTask.add(this.onGoingTasks[i + 1]);
                            tmpListOngoingTask.add(this.onGoingTasks[i]);
                            i++;
                            continue;
                        }
                    } else {
                        tmpListOngoingTask.add(this.onGoingTasks[i]);
                    }
                }
                for(gFRS_Tasks__c taskLst : tmpListOngoingTask){
                    if ((taskLst.gFRS_Funding_Request__r.Record_Type_Name__c == 'Exhibits & Other Promos' || taskLst.gFRS_Funding_Request__r.Record_Type_Name__c == 'Sci/Pipeline Exhibits & Other Non-Promo') && taskLst.Action_Type__c == 'Status Report' && taskLst.gFRS_Funding_Request__r.OwnerId != userId) {
                        continue;
                    } else {
                        tmpListOngoingTask1.add(taskLst);
                    }   
                }
                this.onGoingTasks = tmpListOngoingTask1;
            }
        } catch (Exception ex) {
            // sorting table occurs with error set table to default
            System.debug('SORTING ONGOING TABLE OCCURS ERROR');
            this.onGoingTasks = gFRS_Util_NoShare.fetchUserOngoingTasks(listOfTempRequests, userId);
        }
        
        for (gFRS_Tasks__c taskItem : this.myRequiredTasks) {
            if ((taskItem.Action_Type__c == 'LOA' || taskItem.Action_Type__c == 'ACH') && taskItem.gFRS_Funding_Request__r.Authorized_Signer__c != userId) {
                continue;
            } else {
                tmpListOfTask.add(taskItem);
            }
        }
        this.myRequiredTasks = tmpListOfTask;
        if (this.onGoingTasks != null && this.onGoingTasks.size() > 0) {
            this.isOnGoingTaskListFilled = true;
        } else {
            this.isOnGoingTaskListFilled = false;
        }
    }
    
    
    private void refreshFundingRequestsCopay() {
        //-- ONLY show the funding requests they belong to if they are an internal user or they have been assigned to an account
        Id userId = UserInfo.getUserId();
        this.lFundingRequestscopay = getFoundingRequestscopay();
        // this.lFundingRequestscopay = getFoundingRequestscopay();
        List<gFRS_Copay_Funding_Request__c> listOfTempRequests = new List<gFRS_Copay_Funding_Request__c>([
            SELECT Funding_Sub_Type__c,Id, Name, CreatedDate, Donation_requested_for_quarter__c, Event_Program_Title__c, Date_Submitted__c, Evaluation_submitted_date__c, Requested_Amount__c, Requested_Amount1__c, Sub_Status__c, External_Sub_status__c, Status__c, Record_Type_Name__c, Organization__c,LOA_Signed__c, Locationcopay__c,LOA_PDF__c,Authorized_Signer__c
            FROM gFRS_Copay_Funding_Request__c
            WHERE Authorized_Signer__c = :userId OR OwnerId = :userId
            ORDER BY Date_Submitted__c DESC, CreatedDate DESC
        ]);
        /**getting task for current user **/
        this.myRequiredCopayTasks = gFRS_Util_NoSharecopay.fetchUserTaskscopay(listOfTempRequests, userId);
        /*
for (gFRS_Copay_Task__c myTask : myRequiredCopayTasks) {
if (myTask.Action_Type__c == System.Label.gFRS_Annual_Evaluation) {
if (annualEvalTasksByRequest.get(myTask.gFRS_Copay_Funding_Request__c) == null) {//already sorted per request- by creation date (equivalent of rule trigger date)
annualEvalTasksByRequest.put(myTask.gFRS_Copay_Funding_Request__c, myTask.Id);
}
}
}
*/
        /** Remove RFI Tasks if user is authorized signer **/
        List<gFRS_Copay_Task__c> tasksWithoutRFI = new List<gFRS_Copay_Task__c>();
        if (this.myRequiredCopayTasks != null) {
            for (gFRS_Copay_Task__c t : this.myRequiredCopayTasks) {
                if (t.Action_Type__c == 'RFI' && t.gFRS_Copay_Funding_Request__r.Authorized_Signer__c == userId && t.gFRS_Copay_Funding_Request__r.OwnerId != userId) {
                    continue;
                } else {
                    tasksWithoutRFI.add(t);
                }
            }
            this.myRequiredCopayTasks = tasksWithoutRFI;
        }
        
        /**Removing LOA Task if user isn't authorized signer**/
        List<gFRS_Copay_Task__c> tmpListOfTask = new List<gFRS_Copay_Task__c>();
        List<gFRS_Copay_Task__c> tmpListOngoingTask = new List<gFRS_Copay_Task__c>();
        this.onCopayGoingTasks = gFRS_Util_NoSharecopay.fetchUserOngoingTaskscopay(listOfTempRequests, userId);
        try {
            if (this.onCopayGoingTasks != null) {
                //Below loop agregate ongoing task, fix order Status Report and Outcomes tasks
                for (Integer i = 0; i < this.onGoingTasks.size(); i++) {
                    if (this.onCopayGoingTasks.size() >= i + 2 && this.onCopayGoingTasks[i + 1].gFRS_Copay_Funding_Request__r.Name == this.onCopayGoingTasks[i].gFRS_Copay_Funding_Request__r.Name) {
                        if (this.onCopayGoingTasks[i].Action_Type__c == 'Status Report') {
                            tmpListOngoingTask.add(this.onCopayGoingTasks[i]);
                            tmpListOngoingTask.add(this.onCopayGoingTasks[i + 1]);
                            i++;
                        } else if (this.onCopayGoingTasks[i].Action_Type__c == 'Outcomes') {
                            tmpListOngoingTask.add(this.onCopayGoingTasks[i + 1]);
                            tmpListOngoingTask.add(this.onCopayGoingTasks[i]);
                            i++;
                            continue;
                        }
                    } else {
                        tmpListOngoingTask.add(this.onCopayGoingTasks[i]);
                    }
                }
                this.onCopayGoingTasks = tmpListOngoingTask;
            }
        } catch (Exception ex) {
            // sorting table occurs with error set table to default
            System.debug('SORTING ONGOING TABLE OCCURS ERROR');
            this.onCopayGoingTasks = gFRS_Util_NoSharecopay.fetchUserOngoingTaskscopay(listOfTempRequests, userId);
        }
        
        for (gFRS_Copay_Task__c taskItem : this.myRequiredCopayTasks) {
            if (taskItem.Action_Type__c == 'LOA' && taskItem.gFRS_Copay_Funding_Request__r.Authorized_Signer__c != userId) {
                continue;
            } else {
                tmpListOfTask.add(taskItem);
            }
        }
        this.myRequiredCopayTasks = tmpListOfTask;
        if (this.onGoingTasks != null && this.onGoingTasks.size() > 0) {
            this.isOnGoingTaskListFilled = true;
        } else {
            this.isOnGoingTaskListFilled = false;
        }
    }
    
    
    /**
*  Finds the request in the list of funding requests
*  @param requestId
*  @return GFRS_Funding_Request - if a matching item was found or null if not
**/
    private GFRS_Funding_Request__c getFundingRequestById(String requestId) {
        Id targetId = null;
        try {
            targetId = Id.valueOf(requestId);
        } catch (Exception err) {
        }
        
        if (targetId == null) {
            System.debug('unable to delete request:' + requestId);
            ApexPages.addMessages(new CustomException('Unable to delete request'));
            return(null);
        }
        
        Map<Id, GFRS_Funding_Request__c> requestMap = new Map<Id, GFRS_Funding_Request__c>(this.lFundingRequests);
        if (requestMap.containsKey(targetId)) {
            return(requestMap.get(targetId));
        } else {
            return(null);
        }
    }
    
    
    private gFRS_Copay_Funding_Request__c getFundingRequestByIdCopay(String requestId) {
        Id targetId = null;
        try {
            targetId = Id.valueOf(requestId);
        } catch (Exception err) {
        }
        
        if (targetId == null) {
            System.debug('unable to delete request:' + requestId);
            ApexPages.addMessages(new CustomException('Unable to delete request'));
            return(null);
        }
        
        Map<Id, gFRS_Copay_Funding_Request__c> requestMap = new Map<Id, gFRS_Copay_Funding_Request__c>(this.lFundingRequestscopay);
        if (requestMap.containsKey(targetId)) {
            return(requestMap.get(targetId));
        } else {
            return(null);
        }
    }
    
    
    /**
*  Deletes a specific request.
*  @param currentRequestId (id)
**/
    public void deleteRequest() {
        System.debug('currentRequestId:' + this.currentRequestId);
        GFRS_Funding_Request__c targetRequest = getFundingRequestById(this.currentRequestId);
        
        try {
            if (targetRequest != null) {
                delete targetRequest;
            }
        } catch (Exception err) {
            System.debug('error while deleting:' + err.getMessage());
        }
        Integer pageNumBefDel = setCon.getPageNumber();
        setCon = null;
        setCon.setPageNumber(pageNumBefDel);
        refreshFundingRequests();
        selectedPageNumber = '';
    }
    
    
    public void deleteRequestCopay() {
        
        gFRS_Copay_Funding_Request__c targetRequest = getFundingRequestByIdCopay(this.currentRequestId);
        
        try {
            if (targetRequest != null) {
                delete targetRequest;
            }
        } catch (Exception err) {
            System.debug('error while deleting:' + err.getMessage());
        }
        Integer pageNumBefDel = setConCopay.getPageNumber();
        setConCopay = null;
        setConCopay.setPageNumber(pageNumBefDel);
        refreshFundingRequestsCopay();
        selectedPageNumber = '';
    }
    
    /**
*  Hides the Tasks Pop-Up
**/
    public void hideTaskPopup() {
        this.isTaskPopShown = false;
    }
    
    public PageReference startCloningOperation() {
        
        GFRS_Funding_Request__c targetRequest = getFundingRequestById(this.requestIDToClone);
        
        clonedRequest = gFRS_CloningUtil.customCloneWithInsert(targetRequest, UserInfo.getUserId(), targetRequest.Record_Type_Name__c, organizationIDToClone, locationToClone);
        
        clonedRequest = [SELECT Name FROM GFRS_Funding_Request__c WHERE Id = :clonedRequest.Id].get(0);
        
        this.setCon = null; // setCon is set to null for refresh
        
        refreshFundingRequests();
        showCloningPopup();
        return null;
    }
    
    class CustomException extends Exception {
    }
    
    public boolean showFundingRequest(GFRS_Funding_Request__c fundReq){
        if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c) && UserInfo.getUserId() == fundReq.Authorized_Signer__c){
            return false;
        }
        
        return true;
        
    }
}