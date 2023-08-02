/**
* @author ADMD Team
* @date 08/03/2013
* @description gFRS_FundingRequestReadController class - Controller class used by GFRS_Funding_Request_Read apex page.
*/
public with sharing class gFRS_FundingRequestReadControllercopay {
    
    public static String debugPrefix                        = '***gFRS_FundingRequestReadController*** ';
    
    public static final String EMAIL_TEMPLATES_FOLDER       = 'gFRS_RFI_Templates';// Email templates folder, where available for use templates are stored
    public static final String EMAIL_CLOSE_TEMPLATES_FOLDER = 'gFRS_Close_Request_Templates';
    public static final String CONTENT_TYPE                 = 'RFI'; // The type of page this is
    public static final String PATH_DECISION_RESULT         = Page.gFRS_Application.getURL() + '?id='; //The URL address to send teh client on their task.
    public static final String PATH_REQUEST                 = Page.gFRS_Funding_Request_Read.getURL();//The URL address of the funding request Read
    public static final String PATH_RFI_TARGET              = System.Label.GFRS_Server_URL + '/apex/gFRS_Org_Info?id=';// the URL address to send the client when receiving the RFI **/
    public static final Map<String, String> URLs            = new Map<String, String>{'Organization' => '/apex/GFRS_Org_Info', 'Budget'=>'gFRS_Budget', 'Program' => 'GFRS_Program', 'Application' => 'GFRS_Home'}; // URL used in email templates
        
    public User recipient;
    public List<SelectOption> lETs;//  List of Email Templates taken from db
    public List<SelectOption> recipientsList;  //  List of available recipients, build in controller constructor
    public List<Selectoption> recipientListSelected { get; set; }//  List of selected recipients
    public Map<Id, EmailTemplate> mEtId2Body = new Map<Id, EmailTemplate>(); 
    public Map<Id, User> recipientsToBeDisplayed; // list of possibile recipients and its criteria - to be defined
    private RecordType RT_PAY_HISTORY_READONLY;// READONLY payment history record type
    
    public String subjectContent                { get; set; }
    public List<String> finalSelectedRecipients { get; set; }        
    
    public Boolean isClosingPopUpShown         { get; set; }// Whether the funding request 'closing' pop-up is shown
    public Boolean isClongPopUpShown           { get; set; }
    public Boolean canCreateAnotherPaymentFA   { get { return checkIfUserCanCrateAnotherFundingAllocation();}}//Property can user create another Payment Funding Allocation
    public Boolean isRFI_PopUpShown            { get; set; }// Whether the RFI pop-up is shown.
    public Boolean isCCChecked                 { get; set; }
    public Boolean isAuthorizedSignerSelected  { get; set; }
    public Boolean isAccountableEmploySelected { get; set; }
    public Boolean showAccountableRecipient    { get; set; }
    public Boolean showAuthorizedSigner        { get; set; }
    public String selectedET                   { get; set; }// Points Email Template which has been send
    public string etBody                       { get; set; }//  Email body content variable
    
    public GFRS_copay_Funding_Request__c fundReq                { get; set; }// The Funding Request object used  
    public GFRS_copay_Funding_Request__c requestTemp            { get; set; }// Stores only the email recipient address, fake record
    public GFRS_copay_Funding_Request__c originalStatusValues   { get; set; }// original status values when the funding request
    public Map<String,String> contentItems                { get; set; }
    public Boolean isRFIdisabled                          { get; set; }
    public String selectedDecisionReason                  { get; set; }
    public List<Selectoption> decisionReasonForFoundation { get; set; }
    public String bccEmailAddress                         { get; set; }
    public String ccEmailAddress                          { get; set; }
    public User ownerOfReqest                             { get; set; }
    public GFRS_copay_Funding_Request__c clonedRequest          { get; set; }
    public String clonedRequestName                       { get; set; }
    public Boolean cloningProcessFinished                 { get; set; }
    public boolean disButton                              { get; set; }// Specifies, whether the button SEND should be disabled or not and its negation is used for Email Content visibility
    public String vendorBlockMessage                      { get; set; }
    
    Map<Id, Profile> profileIdToRecord;
    Set<String> profileNames;
    
    
    public String parentRecord
    {
        get{
            return fundReq.ParentRecord__c;
            return null;
        }
        
        set;
    }
    
    
    
    public Boolean checkIfReqestWasApprovedAndUserIsFA{
        get{
            String userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;
            if( userProfileName != gFRS_Util.PROFILE_NAME_GFRS_ADMIN && userProfileName != gFRS_Util.PROFILE_NAME_SYS_ADMIN ){
                if(this.fundReq != null){
                    Id userId=Userinfo.getUserId();
                    if(this.fundReq.Financial_Approver_1__c == userId && this.fundReq.Financial_Approver_1_Decision_Date__c != null){
                        return true;
                    }else if(this.fundReq.Financial_Approver_2__c == userId && this.fundReq.Financial_Approver_2_Decision_Date__c != null){
                        return true;
                    }else if(this.fundReq.Financial_Approver_3__c == userId && this.fundReq.Financial_Approver_3_Decision_Date__c != null){
                        return true;
                    }else{
                        return false;
                    }
                }
            }
            return false;
        }
        set;    
    }
    
    
    /** 
* @Author ADMD Team
* @date 24/07/2014
* @description : checkIfReqestWaitingForBAOrLRApprovalForFoundation property which set if cuurent user should have visible communication, edit links
* if method return true edit links and buttons will be hidden on page
*/
    public Boolean checkIfReqestWaitingForBAOrLRApprovalForFoundation{
        get{
            String userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;
            if( userProfileName != gFRS_Util.PROFILE_NAME_GFRS_ADMIN && userProfileName != gFRS_Util.PROFILE_NAME_SYS_ADMIN ){
                if(this.fundReq != null){
                    Id userId=Userinfo.getUserId();
                    
                    if(this.fundReq.Foundation_Classified__c == 'TRUE' 
                            && (userId == fundReq.Business_Approver__c 
                                || userId == fundReq.Legal_Reviewer_1__c)){

                        if(fundReq.Business_Approver__c != fundReq.Business_Reviewer_1__c 
                            && fundReq.Business_Approver__c != fundReq.Business_Approver_2__c 
                            && fundReq.Business_Approver__c != fundReq.Business_Approver_3__c){

                            //BA1 have only read access for Foundation
                            return true;
                        }else if(fundReq.Legal_Reviewer_1__c != fundReq.Business_Reviewer_1__c 
                                    && fundReq.Legal_Reviewer_1__c != fundReq.Business_Approver_2__c 
                                    && fundReq.Legal_Reviewer_1__c != fundReq.Business_Approver_3__c){

                            //Legal Reviewer have only read access for Foundation 
                            return true;
                        }
                    }
                }
            }
            return false;
        }
        set;
    }
    
    public List<Selectoption> getEmpytSelectList(){
        
        return new List<SelectOption>();
    }
    
    public List<SelectOption> rightOptionForCloseForm { get; set; }
    
    private Map<String,List<String>> mappingForCorrespondingEmailTemplateAndDecisonReason = null;
    private List<EmailTemplate> emailTemplatedForClosingForm                              = null;

    public String closeFundingEmailBody    { get; set; }
    public String closeFundingEmailSubject { get; set; }
    public String baseUrl                  { get; set; }
    public String requestID                { get; set; }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description : class constructor
*/
    public gFRS_FundingRequestReadControllercopay( ApexPages.Standardcontroller std ){

        baseUrl   = URL.getSalesforceBaseUrl().toExternalForm();
        fundReq   = (GFRS_copay_Funding_Request__c) std.getRecord();
        requestID = this.fundReq.id;
        
        try {
            fundReq = [
                SELECT  Id, Decision_Reasons__c, name, LOA_Signed__c, Owner.Id , owner.name, owner.email, Information_Needed__c , Reconciliation_Completed__c, Record_Type_Name__c, ParentRecord__c, OwnerId, Foundation_Classified__c, Payment_Call_Counter__c 
                FROM GFRS_copay_Funding_Request__c 
                WHERE Id = :this.fundReq.id LIMIT 1 ];
            
            if( this.fundReq.Payment_Call_Counter__c == null ) this.fundReq.Payment_Call_Counter__c = 0;
            
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, err.getMessage() ));
            return;
        }
        
        RT_PAY_HISTORY_READONLY = [ SELECT Id 
                                    FROM RecordType 
                                    WHERE DeveloperName = :gFRS_Util.RT_PAYHISTORY_READONLY 
                                        AND SobjectType = 'GFRS_Payment_History__c' ];
        
        this.requestTemp = new GFRS_copay_Funding_Request__c();
        
        //get email used in email service to attached sent emails
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){

            bccEmailAddress = myOrgCS.gFRS_Inbound_Email__c;
        }
        //By default athorized signer checkbox shouldn't be visible variable initialization    
        showAuthorizedSigner = false;
        
        profileNames      = new Set<String>{gFRS_Util.PROFILE_NAME_GFRS_ADMIN, gFRS_Util.PROFILE_NAME_NO_SSO_SUPER_USER, gFRS_Util.PROFILE_NAME_SUPER_USER, gFRS_Util.PROFILE_NAME_SYS_ADMIN, gFRS_Util.PROFILE_NAME_SYS_SUPPORT};
        profileIdToRecord = getProfiles(profileNames);
        /*Set proper Recipitants available for each fuunding types
Internal Funding: Owner,Authorized Signer, Accountable Employ
External Fundings: Owner,Authorized Signer
*/
    }
    /* ### End of constructor ### */
    
    
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description getRecipientsList method - returns recipients list.
*/
    public List<SelectOption> getRecipientsList(){ return this.recipientsList; }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description getAvailableET method - returns Email Templates.
*/
    public List<SelectOption> getAvailableET(){ return this.lETs; }
    
    
    public void showClone_Popup(){
        isClongPopUpShown             = true;
        fundReq.clonedRequestOwner__c = fundReq.owner.Id;
        cloningProcessFinished        = false;
        //For MSC Group cloning process stating automatically without selecting owner for cloned request
        if(checkIfUserBelonsToMCSGroup && !checkIfCloneSuperUser || (fundReq.OwnerId == UserInfo.getUserId())
        && ( fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME 
        || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME 
        || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME ))
        {
             cloningProcessFinished = true;
        }
        
    }
    
    public void hideClone_Popup(){
        isClongPopUpShown = false;
    }
    
    public void checkIfVendorBlocked(){
        System.debug('check if vendor is blocked, id: '+this.fundReq.Locationcopay__r.Vendor_Id__c);
        
        
        if (this.fundReq.Locationcopay__r.Vendor_Id__c != null) {
            try {
                gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0 sapLookup = new gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0();
                sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
                GFRS_VendorLookupSAP.VendorLookupResponse_element response = sapLookup.VendorLookup( '', this.fundReq.Locationcopay__r.Vendor_Id__c, '', '', '', '100' );
                
                if (response.MessageType=='S') {
                    handleResponse( response );
                    vendorBlockMessage = 'blocked';
                } else {
                    System.debug(response);
                    vendorBlockMessage = 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem';
                }
                
            } catch( Exception err ) {
                System.debug( 'ERROR OCCURRED:' + err.getMessage() );
                vendorBlockMessage ='asdsada';
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem' ));
            }
        } else {
            System.debug('No vendor id has been provided');
        }
    }
    
    public void handleResponse(GFRS_VendorLookupSAP.VendorLookupResponse_element response) {
        if ( response.MessageText != null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, response.MessageText ));
            return;
        }
        for (GFRS_VendorLookupSAP.VendorDetails_element  d : response.VendorDetails) {
            GFRS_Location__c l = new GFRS_Location__c();
            this.fundReq.Locationcopay__r.Posting_block_for_all_company_codes__c = d.PostingBlockAllCompanyCode;
            this.fundReq.Locationcopay__r.Posting_block_for_1000_or_1010__c      = d.PostingBlockSpecifiedCompanyCode;
            this.fundReq.Locationcopay__r.Deletion_Flag_for_all_company_codes__c = d.DeletionFlagAllArea;
            this.fundReq.Locationcopay__r.Deletion_Flag_for_all_1000_or_1010__c  = d.DeletionFlagSelectedCompanyCode;
            this.fundReq.Locationcopay__r.Payment_Block_Indicator__c             = d.PaymentBlockIndicator;
            this.fundReq.Locationcopay__r.Payment_Block_Description__c           = d.PaymentBlockDescription;
        }
        //update this.fundReq.Locationcopay__r;
    }
    
    public Boolean isNewToCCOButtonVisible{
        get{
            return true;
        }
        set;
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description showRFI_Popup method - Opens the RFI Pop-up.
*/
    public void showRFI_Popup(){
        this.isRFI_PopUpShown = true;
        selectedET            = 'NONE';
        disButton             = true;
        isRFIdisabled         = true;
        this.lETs             = new List<SelectOption>();
        String userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;
        
        if(fundReq.Record_Type_Name__c != null && (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME
                                                   || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME
                                                   || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME
                                                   || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)
           && this.fundReq.Accountable_Employee_Approval__c != null)
        {    
            showAccountableRecipient = true;
        }
        else
        {
            showAccountableRecipient = false;
        }
        
        this.recipient=[SELECT Id, FirstName, LastName, Name, Email, ContactId 
                        FROM User 
                        WHERE Id =:fundReq.OwnerId].get(0);
        
        
        this.lETs.add(new SelectOption('NONE', ' - please select template -'));

        EmailTemplate[] ets = [SELECT Subject, Name, Id, Description, Body,DeveloperName 
                                FROM EmailTemplate 
                                WHERE Folder.DeveloperName = :EMAIL_TEMPLATES_FOLDER 
                                ORDER BY Name ASC];
        for(EmailTemplate et1 : ets){
            this.mEtId2Body.put(et1.Id, et1);
            if(this.fundReq.Foundation_Classified__c == 'TRUE'){
                if(et1.DeveloperName.contains('Foundation')){
                    this.lETs.add(new SelectOption(et1.Id, et1.Name));
                }         
            }else{ 
                if(this.fundReq.Record_Type_Name__c == 'Copay'){
                    
                    if(et1.DeveloperName == 'gFRS_RFI' 
                        || et1.DeveloperName == 'gFRS_RFI_Outcomes' 
                        || (et1.DeveloperName == 'gFRS_RFI_Reconciliation_Request_Communication' && this.fundReq.Reconciliation_Completed__c=='No') //GFRS-900 
                        || et1.DeveloperName == 'LOA_Reminder_Communication' 
                        || et1.DeveloperName == 'General_Communication_External' 
                        ||  et1.DeveloperName == 'Canceled_Post_Funding_Communication' ) {

                        this.lETs.add(new SelectOption(et1.Id, et1.Name));                 
                    }
                    /*
                    if(((this.fundReq.Last_Live_Program_End_Date__c != null 
                        && et1.DeveloperName == 'Sunshine_Act_Disclosure_Request_Communication' 
                        && this.fundReq.Closed_Date__c == null) || (et1.DeveloperName == 'Sunshine_Act_Disclosure_Request_Communication' 
                        && this.fundReq.Closed_Date__c != null && userProfileName == gFRS_Util.PROFILE_NAME_GFRS_ADMIN)) && this.fundReq.Sub_Status__c!=gFRS_Util.REQUEST_SUB_STATUS_REFUND_REQ) {
                        this.lETs.add(new SelectOption(et1.Id, et1.Name));
                    }*/
                    
                }else if(this.fundReq.Record_Type_Name__c == 'HC CHAR'){
                    if(et1.DeveloperName == 'gFRS_RFI' 
                        || et1.DeveloperName == 'Program_Cancelation_Communication' 
                        || et1.DeveloperName == 'Program_Denial_Communication'  
                        || et1.DeveloperName == 'Evaluation_Reminder_Communication' 
                        || et1.DeveloperName == 'LOA_Reminder_Communication' 
                        || et1.DeveloperName == 'General_Communication_External' ){

                        this.lETs.add(new SelectOption(et1.Id, et1.Name));
                    }
                }else if(this.fundReq.Record_Type_Name__c == 'Philanthropic'){
                    if(et1.DeveloperName == 'gFRS_RFI' 
                        || et1.DeveloperName == 'Evaluation_Reminder_Communication' 
                        || et1.DeveloperName == 'LOA_Reminder_Communication' 
                        || et1.DeveloperName == 'General_Communication_External' ){

                        this.lETs.add(new SelectOption(et1.Id, et1.Name));  
                        
                    }
                }else if(this.fundReq.Record_Type_Name__c == 'Scientific Projects'){
                    if(et1.DeveloperName == 'gFRS_RFI' 
                        || et1.DeveloperName == 'Evaluation_Reminder_Communication' 
                        || et1.DeveloperName == 'LOA_Reminder_Communication' 
                        || et1.DeveloperName == 'General_Communication_External' ){

                        this.lETs.add(new SelectOption(et1.Id, et1.Name));  
                        
                    }
                }else if(this.fundReq.Record_Type_Name__c == 'Fellowships'){
                    if(et1.DeveloperName == 'gFRS_RFI' 
                        || et1.DeveloperName == 'Evaluation_Reminder_Communication' 
                        || et1.DeveloperName == 'LOA_Reminder_Communication' 
                        || et1.DeveloperName == 'General_Communication_External' ){

                        this.lETs.add(new SelectOption(et1.Id, et1.Name));  
                        
                    }
                }else if(this.fundReq.Record_Type_Name__c == 'Field Initiated Exhibits' 
                    || this.fundReq.Record_Type_Name__c =='Exhibits & Other Promos' 
                    || this.fundReq.Record_Type_Name__c =='Corporate Memberships' 
                    || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME){

                    if(et1.DeveloperName == 'gFRS_RFI_Internal' 
                        || et1.DeveloperName == 'General_Communication_Internal'){
                        this.lETs.add(new SelectOption(et1.Id, et1.Name));  
                    }
                    if((this.fundReq.Record_Type_Name__c =='Exhibits & Other Promos' 
                            || this.fundReq.Record_Type_Name__c =='Corporate Memberships' 
                            || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) 
                        &&   et1.DeveloperName == 'LOA_Reminder_Communication'){
                        this.lETs.add(new SelectOption(et1.Id, et1.Name)); 
                    }
                }
            }
        }
        //System.debug( 'isRFI_PopUpShown:' + isRFI_PopUpShown );
    }
    
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description showRFI_Popup method - Closes the RFI Popup.
*/
    public void hideRFI_Popup(){

        selectedET            = 'NONE';
        this.isRFI_PopUpShown = false;
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description showClosingPopup method - Opens the RFI Pop-up.
*/
    public ApexPages.PageReference showClosingPopup(){
        if( gFRS_Util.REQUEST_STATUS_CLOSED.equals( this.fundReq.Status__c )){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.severity.ERROR , System.Label.gFRS_ERROR_ALREADY_CLOSED ));
            return( null );
        }
        
        //-- clone the values before the status
        this.originalStatusValues = this.fundReq.clone();

        List<User> tmpUsers = new List<User>([SELECT Id, FirstName, LastName, Name, Email, ContactId FROM User WHERE Id = : fundReq.OwnerId]);
        if(tmpUsers.size()>0){
            this.recipient          = tmpUsers[0];
            rightOptionForCloseForm = new List<SelectOption>();
            rightOptionForCloseForm.add(new SelectOption(recipient.Id,'Owner - '+recipient.Name));
        }         
        this.fundReq.Status__c              = gFRS_Util.REQUEST_STATUS_CLOSED;
        this.fundReq.Sub_Status__c          = gFRS_Util.REQUEST_SUB_STATUS_CANCELLED;
        this.fundReq.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_CANCELLED;
        
        this.isClosingPopUpShown = true;
        populateDecisionReasonForFoundation();
        
        return( null );
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description populateDecisionReasonForFoundation method - method populate values for Decision Reason select list if funding type is Foundation classified.
*/
    public void populateDecisionReasonForFoundation()
    {
        
        decisionReasonForFoundation =new List<Selectoption>();
        if(this.fundReq != null && this.fundReq.Sub_Status__c == 'Denied'){
            decisionReasonForFoundation = new List<Selectoption>{ 
                new Selectoption('','--None--'),
                    new Selectoption('Compliance Denial','Compliance Denial'),
                    new Selectoption('Limited Funding Availability','Limited Funding Availability'),
                    new Selectoption('Out of Scope','Out of Scope')
                    };
                        
                        }else if(this.fundReq != null && this.fundReq.Sub_Status__c == 'Canceled'){
                            decisionReasonForFoundation = new List<Selectoption>{   
                                new Selectoption('','--None--'), 
                                    new Selectoption('Canceled at the Request of Applicant','Canceled at the Request of Applicant'),
                                    new Selectoption('Cannot Agree to LOA Terms','Cannot Agree to LOA Terms'),
                                    new Selectoption('Did Not Receive Response to RFI(s)','Did Not Receive Response to RFI(s)'),
                                    new Selectoption('Duplicate Request in System','Duplicate Request in System')
                                    };
                                        }else{
                                            
                                            decisionReasonForFoundation= new List<Selectoption>{new Selectoption('','--None--')};
                                                }
        
        selectedDecisionReason = ''; 
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description hideClosingPopup method - Closes the RFI Popup.
*/
    public void hideClosingPopup(){
        this.revertStatusChanges();
        this.isClosingPopUpShown = false;
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description revertStatusChanges method - Revert the status changes.
*/
    private void revertStatusChanges(){
        if( this.originalStatusValues != null ){

            this.fundReq.Status__c              = this.originalStatusValues.Status__c;
            this.fundReq.Sub_Status__c          = this.originalStatusValues.Sub_Status__c;
            this.fundReq.External_Sub_status__c = this.originalStatusValues.External_Sub_status__c;
            this.fundReq.Decision_Reasons__c    = this.originalStatusValues.Decision_Reasons__c;
        }
        this.originalStatusValues = null;
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description closeFundingRequest method - Method used by the custom button to close the funding request
* (so the status can remain read-only through the page layouts)
*/
    public ApexPages.PageReference closeFundingRequest(){
        this.fundReq.Status__c = gFRS_Util.REQUEST_STATUS_CLOSED;
        
        //-- make the decision reason required only if the sub status is approved
        
        if( !gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED.equals( this.fundReq.Sub_Status__c ) &&
           this.fundReq.Decision_Reasons__c == null)
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_DECISION_REASON_REQ ) );
            return( null );
        }
        
        
        try {
            
            if(fundReq.Sub_Status__c != 'Approved')
            {
                if(closeFundingEmailSubject == null || closeFundingEmailSubject== '' ){
                    ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptySubject ) );
                    return null;
                }
                if(closeFundingEmailBody == null || closeFundingEmailBody== ''){
                    ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptyContent ) );
                    return null;    
                }
                
                sendCloseFundingEmail();
            }
            
            if(this.fundReq.Sub_Status__c == 'Denied')//mark denial as UI denial not from standard reject approval process screen.
            {
               // this.fundReq.UICloseRequestDenial__c = true;
            }
            
           // gFRS_Util_NoShare.saveLockedFundingRequestInternalPage( this.fundReq );
            
            //Automaticy reject the request if needed
            if(this.fundReq.SYS_Request_Approved__c != 'No')
            {

               // gFRS_InternalCancellationProcess.autoRejectRecord(this.fundReq);
            }
            
            
            //-- not needed since the page must refresh, but makes things clearer
            this.isClosingPopUpShown = false;
            
            //-- redirect to show the changes
            return( new ApexPages.PageReference( gFRS_Utilcopay.initializeLinkcopay( PATH_REQUEST, this.fundReq, null ) ).setRedirect(true) );
        } catch( Exception err ){
            System.debug( 'ERROR OCURRED:' + err.getMessage() );
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
        }
        
        return( null );
    }
    
    
    /** 
* @Author ADMD Team
* @date 21/02/2014
* @description sendCloseFundingEmail method - Method used to sent email if user  
* close the funding request using custom button Close Funding Request
*/
    public void sendCloseFundingEmail(){
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{recipient.Email});
            mail.setSubject( this.closeFundingEmailSubject );
            
            // (Optional) Set list of people who should be CC'ed
            if (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME){

                String ccEmailAddress = null;
                ccEmailAddress        = fundReq.Financial_Approver_1__r.Email;
                
                system.debug('CC email '+ccEmailAddress);
                if(ccEmailAddress != null){      
                    mail.setCcAddresses(new List<String>{ccEmailAddress});
                }
            }
            
            if(bccEmailAddress != null){
                mail.setBccAddresses(new List<String>{bccEmailAddress});
            }
            
            closeFundingEmailBody +='\n\n'+'[ref:'+fundReq.id+']';
            mail.setPlainTextBody(closeFundingEmailBody);
            
            mail.setOrgWideEmailAddressId([SELECT Id, Address 
                                            FROM OrgWideEmailAddress 
                                            WHERE Address='fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
            
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }catch(Exception ex){
            
        }  
    }
    
    /* @Author ADMD Team
* @date 07/23/2012
* @description generateEmailContent  - Method generates Email Content according to choosen options
*/
    public void generateEmailContent(){
        
        String selectedTemplateLabel = getSelectedTemplateLabel(this.lETs,this.selectedET);
        
        if(selectedTemplateLabel != null && selectedTemplateLabel =='LOA Reminder Communication'){

            isAuthorizedSignerSelected = true;
            showAuthorizedSigner       = true;
        }else{

            isAuthorizedSignerSelected = false;
            showAuthorizedSigner       = false;
        }
        
        if(selectedTemplateLabel != 'NONE' && selectedTemplateLabel !=''){

            this.disButton = false;
            
            if(selectedTemplateLabel!= null && (selectedTemplateLabel.contains('RFI') || selectedTemplateLabel.contains('Program'))){
                isRFIdisabled = false;
            }else{
                isRFIdisabled = true;
            }
            try{
                EmailTemplate selectedEmailTemlate = mEtId2Body.get(this.selectedET);
                if(selectedEmailTemlate != null){
                    this.etBody           = selectedEmailTemlate.Body;
                    this.subjectContent   = replaceEmailSubject(selectedEmailTemlate.Subject);
                    this.etBody           = replaceEmailBody(selectedEmailTemlate.Body,this.recipient);
                }
            }catch(Exception ex){
                this.etBody        = ' ';
                this.disButton     = true;
                this.isRFIdisabled = true;
            }       
            
            
            
        } else {
            this.etBody        = '';
            this.isRFIdisabled = true;
            this.disButton     = true;
        }
    }
    
    
    
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description dateToString method - Converts a null to a blank string for replacement.
*/
    private String checkNull( String v ){
        return( v == null || v == 'null' ? '' : v );
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description sendEmail method - Method for email sending.
*/
    public ApexPages.PageReference sendEmail(){
        //method for email sending
        
        String[] toAddresses = new String[] {};
            
            if(fundReq.Owner.Email != null){
                toAddresses.add(fundReq.Owner.Email);   
            }
        if(isAuthorizedSignerSelected && fundReq.Signing_Authority_Email__c != null ){
            if(!checkIfStringIsInList(toAddresses,fundReq.Signing_Authority_Email__c)){
                toAddresses.add(fundReq.Signing_Authority_Email__c);
            }   
        }
        if(isAccountableEmploySelected != null && isAccountableEmploySelected && fundReq.Accountable_Employee_Approval__c != null && fundReq.Accountable_Employee_Approval__r.Email != null ){
            if(!checkIfStringIsInList(toAddresses,fundReq.Accountable_Employee_Approval__r.Email)){
                toAddresses.add(fundReq.Accountable_Employee_Approval__r.Email);
            }
            
        }
        
        
        //String[] ccAddresses = new String[]{};
        
        /* temporary email address */
        String selectedTemplate = '';
        for(SelectOption item:this.lETs){
            if(item.getValue() == this.selectedET){

                selectedTemplate = item.getLabel();
            }       
        }
        
        if((selectedTemplate == 'RFI - Information Request Internal' || selectedTemplate ==  'RFI - Information Request External' || selectedTemplate == 'Program Denial Communication' || selectedTemplate ==  'Program Cancelation Communication') && fundReq.Information_Needed__c == null ){
            
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_CommunicationErrorEmptyInfoNeeded ) );
            return null;
        }
        
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            if(bccEmailAddress != null){
                mail.setBccAddresses(new List<String>{bccEmailAddress});
            }
            
            mail.setSubject( this.subjectContent );
            if(this.subjectContent == null || this.subjectContent== '' ){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptySubject ) );
                return null;
            }
            if(this.etBody == null || this.etBody== ''){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptyContent ) );
                return null;    
            }
            
            
            
            etBody += '\n\n'+'[ref:'+fundReq.id+']';
            mail.setPlainTextBody(etBody);
            
            //Cancel Post Funding email should be sent from following address: fundingrequestsystem-donotreply-d@gene.com
            if(selectedTemplate == 'Canceled Post Funding Communication'){
                mail.setOrgWideEmailAddressId([SELECT Id, Address 
                                                FROM OrgWideEmailAddress 
                                                WHERE Address='fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
            }   
            //for rest communication email notification is sent from current user context
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            try {
                
                if(selectedTemplate == 'RFI - Information Request Internal' || selectedTemplate ==  'RFI - Information Request External' || selectedTemplate == 'Program Denial Communication' || selectedTemplate ==  'Program Cancelation Communication'){
                    
                    fundReq.Sub_Status__c          = gFRS_Util.REQUEST_STATUS_RFI;
                    fundReq.External_Sub_status__c = gFRS_Util.REQUEST_STATUS_RFI;
                    
                    
                    //System.debug( 'newRequest:' + fundReq + ', newStatus:' + fundReq.Sub_Status__c + ', external:' + fundReq.External_Sub_status__c );
                    
                    
                }else if(selectedTemplate ==  'Reconciliation Request Communication'){

                    fundReq.Status__c                   = 'Processing & Disposition';
                    fundReq.Sub_Status__c               = 'Reconciliation Required';
                    fundReq.External_Sub_status__c      = 'Reconciliation Required';
                    fundReq.Reconciliation_Completed__c = 'No';
                    fundReq.Is_Reconciliation_In_RFI__c = true;
                    
                }else if(selectedTemplate == 'Canceled Post Funding Communication'){

                    fundReq.Status__c                   = 'Processing & Disposition';
                    fundReq.Sub_Status__c               = 'Reconciliation Required';
                    fundReq.External_Sub_status__c      = 'Reconciliation Required';
                    fundReq.Reconciliation_Completed__c = 'No';
                    fundReq.Is_Reconciliation_In_RFI__c = true;
                    
                }else if(selectedTemplate == 'Outcomes Request Communication'){
                    fundReq.Is_Outcomes_In_RFI__c = true;
                    
                }else if(selectedTemplate == 'Evaluation Reminder Communication'){
                    fundReq.Status__c               = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
                    fundReq.Sub_Status__c           = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                    fundReq.External_Sub_status__c  = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                    fundReq.Evaluation_Completed__c = 'No';
                    
                }
                else if(selectedTemplate == gFRS_Util.SUNSHINE_ACT_DISCLOSURE_REQUEST_COMMUNICATION_NAME){
                    //fundReq.Sunshine_Act_Disclosure_Submitted__c = gFRS_Util.NO;
                   // fundReq.Sunshine_Communication_Sent__c       = true;
                    fundReq.Sub_Status__c           = gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE;
                    fundReq.External_Sub_status__c  = gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE;
                    fundReq.Status__c               = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION; 
                }
                
                if((this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME 
                        || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) 
                    && (this.fundReq.Information_Needed__c != null 
                        && this.fundReq.Information_Needed__c.contains('Application') 
                        && !this.fundReq.Information_Needed__c.contains('Third Party'))){

                    this.fundReq.Information_Needed__c += ';Third Party';
                }
                
               // gFRS_Util_NoShare.saveLockedFundingRequestInternalPage( this.fundReq );
                
            } catch( Exception err ){
                System.debug( 'err:' + err.getMessage() );
            }
            
            //hideRFI_Popup();
            
            //-- return to the current page to ensure the information is updated and refreshed
            return( new ApexPages.PageReference( '/' + this.fundReq.id ));
        } catch( Exception err ){
            System.debug( 'ERROR OCURRED:' + err.getMessage() );
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
        }
        
        return( null );
    }
    
    /** 
* @Author ADMD Team
* @date 06/05/2014
* @description checkIfStringIsInList method check if string is in list
* 
*/
    public Boolean checkIfStringIsInList(List<String> lOfStrings,String stringToFind){
        for(String s : lOfStrings){
            if(s == stringToFind){
                return true;
            }
        }
        return false;
    }
    /** 
* @Author ADMD Team
* @date 01/24/2014
* @description replaceEmailSubject method replace dynamic values defined in subject of emailTemplate
* 
*/
    public String replaceEmailSubject(String emailSub){
        if(emailSub != null){
            return EmailSub.replace('<<G-#####>>', this.fundReq.Name);
        }
        return '';      
        
    }
    
    /** 
* @Author ADMD Team
* @date 02/20/2014
* @description replaceEmailBody method set dynamic values in defined in body of emailTemplate
* 
*/
    public String replaceEmailBody(String emailBody, User recipient){
        
        String outputBody = '';
        
        if(emailBody != null){
            outputBody           = emailBody.replace('<<G-#####>>', this.fundReq.Name).replace('<<Program/Event Title>>',checkNull( this.fundReq.Event_Program_Title__c ));
            String senderName    = checkNull(Userinfo.getFirstName()) + ' ' +checkNull(Userinfo.getLastName());
            outputBody           = outputBody.replace('<<Sender First Name Last Name>>',senderName );
            String recipientName = '';

            if(showAuthorizedSigner){
                //flag showAuthorizedSigner is true only for LOA reminder recipiet shuld be always Authorized Signer
                recipientName = checkNull(fundReq.Signing_Authority_First_Name__c)+' '+ checkNull(fundReq.Signing_Authority_Last_Name__c);
            }else{
                //recipient will be always owner of requesx
                recipientName = checkNull(recipient.FirstName) +' '+ checkNull(recipient.LastName);
            }   
            outputBody = outputBody.replace('<<First Name Last Name>>',recipientName );
            
            String authorizedSingnerName  = checkNull(fundReq.Signing_Authority_First_Name__c)+' '+ checkNull(fundReq.Signing_Authority_Last_Name__c);
            outputBody                    = outputBody.replace('<<Authorized Signer>>',authorizedSingnerName );
            outputBody                    = outputBody.replace('<<Authorized Signer Email>>', checkNull(fundReq.Signing_Authority_Email__c));
            
            String programStartDateMin    = 'test';
            outputBody                    = outputBody.replace('<<First Program Start Date>>', programStartDateMin);
            
            String programEndDateMax      = 'test';
            outputBody                    = outputBody.replace('<<Last Program End Date>>', programEndDateMax);
            
            //Disease State
            String diseaseState           = 'test';
            outputBody                    = outputBody.replace('<<Disease State>>', diseaseState);
            
            
            //ModifiedBy
            String modifUser              = checkNull(fundReq.LastModifiedBy.Name);
            outputBody                    = outputBody.replace('<<LastModifyBy>>', modifUser);
            
            String lastLiveProgramEndDate = 'testdate';
            outputBody                    = outputBody.replace('<<Last Live Program End Date>>', lastLiveProgramEndDate);
            
            
        }
        
        return outputBody;
    }
    
    
    
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description managePDF method - create appropriate attachments and relate them with FUnding Request.
* SFDC-1710 method which adding LOA PDF attachment or Compliance documents
*/
    public  ApexPages.PageReference managePDF(){
        
        Savepoint sp = null;
        
        if(this.fundReq.LOA_Signed__c == 'Yes' && this.fundReq.LOA_PDF__c == null){
            Attachment LoaDocument = null;
            List<Attachment> tmpAtachmentLi = [ SELECT Id, Name, body, Parent.Id 
                                                FROM Attachment 
                                                WHERE Name = 'LOADocument.pdf' 
                                                    AND Parent.Id = :this.fundReq.Id ];
            try{
                if(tmpAtachmentLi == null || tmpAtachmentLi.size()<1){
                    PageReference pageRefPdf = null;
                    if(this.fundReq.Record_Type_Name__c == 'Field Initiated Exhibits'){
                        pageRefPdf =  new ApexPages.Pagereference( Page.GFRS_LOA_PDF_FieldExhibits.getURL());
                        pageRefPdf.getParameters().put('id',fundReq.id);
                    }else{
                        pageRefPdf = new ApexPages.Pagereference( Page.gFRS_LOA_PDF.getURL() );
                        pageRefPdf.getParameters().put('id',fundReq.id);
                    }   
                    pageRefPdf.setRedirect(true);
                   // gFRS_Util_NoShare.insertLOAattachment('LOADocument.pdf',pageRefPdf.getContent(),this.fundReq);  
                }
            }catch(Exception ex){
                system.debug('get exception form method managePDF' + ex.getMessage());
            }                   
        }
        
        try{
            Date decisionDate = date.parse(System.Label.gFRS_Compliance_Flag_Snapshot_Start_Date);
            
            GFRS_OrgSettings__c myOrgCS     = GFRS_OrgSettings__c.getOrgDefaults();  
            Date hcComplianceFlagsStartDate = myOrgCS.gFRS_HC_Compliance_Flag_Start_Date__c;                  
            
            if(this.fundReq.Decision_Date__c != null 
                && this.fundReq.Decision_Date__c         >= decisionDate  
                && this.fundReq.Compliance_flags_PDF__c  == null 
                && this.fundReq.Foundation_Classified__c == 'FALSE'){

                try{    
                    PageReference pageRefPdf = null;
                    pageRefPdf               = new ApexPages.Pagereference( Page.gFRS_ComplianceCheckFlagPDF.getURL() );
                    pageRefPdf.getParameters().put('id',fundReq.id);   
                    pageRefPdf.setRedirect(true);
                    String documentName      = 'Decision_Flags_' + this.fundReq.Name + '.pdf';
                    sp = Database.setSavepoint();

                   // gFRS_Util_NoShare.insertComplianceAttachment(documentName, pageRefPdf.getContent(), this.fundReq); 
                       
                }catch(Exception ex){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, System.Label.gFRS_UnableToCreateDecisionFLagsPDF));
                    System.debug(System.Label.gFRS_UnableToCreateDecisionFLagsPDF);
                    Database.rollback(sp);
                }
            }else if(this.fundReq.Decision_Date__c == null && this.fundReq.Compliance_flags_PDF__c != null){
                
                List<Attachment> tmpAtachmentLi = [ SELECT Id, Parent.Id 
                                                    FROM Attachment 
                                                    WHERE Id = :this.fundReq.Compliance_flags_PDF__c ];
                if(tmpAtachmentLi.size()>0){
                    gFRS_Util_NoShare.deleteLockedAttachments(tmpAtachmentLi);
                }   
                this.fundReq.Compliance_flags_PDF__c = null;
                update this.fundReq;
            }
            
            
            if( this.fundReq.HC_Compliance_Date__c >= hcComplianceFlagsStartDate && this.fundReq.HC_Compliance_Date__c != null && this.fundReq.HC_Compliance_Flags_PDF__c == null && this.fundReq.Foundation_Classified__c == 'FALSE'){
                try{
                    PageReference pageRefPdf = null;
                    pageRefPdf               = new ApexPages.Pagereference( Page.gFRS_ComplianceCheckFlagPDF.getURL());
                    pageRefPdf.getParameters().put('id',fundReq.id);
                    pageRefPdf.setRedirect(true);

                    String documentName      = 'HC_Compliance_Flags_' + this.fundReq.Name + '.pdf';
                    sp                       = Database.setSavepoint();
                   // gFRS_Util_NoShare.insertFundingRequestAttachment('HC_Compliance_Flags_PDF__c', documentName, pageRefPdf.getContent(), this.fundReq);        
                }catch(Exception ex){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, System.Label.gFRS_UnableToCreateHcComplianceFLagsPDF));
                    System.debug(System.Label.gFRS_UnableToCreateHcComplianceFLagsPDF);
                    Database.rollback(sp);
                }
                
                
            }else if(this.fundReq.HC_Compliance_Date__c == null && this.fundReq.HC_Compliance_Flags_PDF__c != null){
                
                List<Attachment> tempAttachmentList = [SELECT Id 
                                                        FROM Attachment 
                                                        WHERE Id = :this.fundReq.HC_Compliance_Flags_PDF__c];
                if(tempAttachmentList.size()>0){
                    gFRS_Util_NoShare.deleteLockedAttachments(tempAttachmentList) ;
                }
                
                this.fundReq.HC_Compliance_Flags_PDF__c = null;
                update this.fundReq;
            }
        }catch(Exception ex){
            system.debug('THERE WAS PROBLEM WITH GENERATING COMPLIANCE CHECK FLAG RESON:' + ex.getMessage());
        }
        
        //
        removeEditSharingForFA1AfterApproveReject();
        
        return null;
    }
    
    /* --- Process payment/refund funding allocation --- */
    
    /** 
* @Author ADMD Team
* @date 03/08/2013
* @description Function checks can user create another payment funding allocation.
* Only one payment allocation allowed for funding request.
*/    
    private boolean checkIfUserCanCrateAnotherFundingAllocation()
    {
        Boolean bRetVal    = false;
        Integer intCounter = 0;
        
        intCounter = [SELECT Id 
                        FROM GFRS_Funding_Allocation__c 
                        WHERE RecordType.Name != 'Refund' 
                        AND Grant_Request__c=: fundReq.Id].Size();
        
        if(intCounter==0)bRetVal=true;       
        
        return bRetVal;
    }
    
    /** 
* @Author ADMD Team
* @date 08/03/2013
* @description Creates a new payment funding allocation record. Used by button New Payment Allocation.
* 
*/    
    public ApexPages.PageReference createNewPaymentAllocation(){
        
        try
        {
            RecordType rt = [SELECT Id 
                                FROM RecordType 
                                WHERE Name = 'Payment' 
                                AND SobjectType = 'GFRS_Funding_Allocation__c' limit 1];

            GFRS_Funding_Allocation__c paymentFA = new GFRS_Funding_Allocation__c(Grant_Request__c = fundReq.Id,Fiscal_Year__c =  String.valueOf(date.today().year()),RecordTypeId=rt.id);
            
            insert paymentFA;
            
            return( new ApexPages.PageReference('/apex/GFRS_FundingAllocationRead?id=' + paymentFA.id).setRedirect(true) );
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex) ) );
            return null;
        }   
    }
    
    /** 
* @Author ADMD Team
* @date 08/03/2013
* @description Creates a new refund funding allocation record. Used by button New Refund Allocation.
* 
*/  
    public ApexPages.PageReference createNewRefundAllocation(){
        
        try
        {
            RecordType rt = [SELECT Id 
                                FROM RecordType 
                                WHERE Name = 'Refund' 
                                AND SobjectType = 'GFRS_Funding_Allocation__c' limit 1];

            GFRS_Funding_Allocation__c paymentFA = new GFRS_Funding_Allocation__c(Grant_Request__c = fundReq.Id,Fiscal_Year__c =  String.valueOf(date.today().year()),RecordTypeId=rt.id);
            
            insert paymentFA;
            
            return( new ApexPages.PageReference('/apex/GFRS_FundingAllocationRead?id=' + paymentFA.id).setRedirect(true) );
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex) ) );
            return null;
        }   
    }
    
    /** 
* @Author ADMD Team
* @date 02/19/2013
* @description refresh page.
* 
*/  
    public ApexPages.PageReference refreshCloseFundingForm()
    {
        if(fundReq.Foundation_Classified__c =='TRUE'){
            fundReq.Decision_Reasons__c=selectedDecisionReason;
        }
        
        if(mappingForCorrespondingEmailTemplateAndDecisonReason == null){
            
            //Keeping mapping Decision Reason => Proper Email Template 
            //Templates for Foundation funding type should contain Foundation word 
            //All Emails template are keeped in following folder:gFRS Close Request Templates
            mappingForCorrespondingEmailTemplateAndDecisonReason=new Map<String,List<String>>{    
                'CCO Compliance Denial' => new List<String>{'CCO Compliance Denial External','CCO Compliance Denial Internal'},
                    'Compliance Denial' => new List<String>{'Compliance Denial IMED','Compliance Denial CAPP','Foundation - Denied - Decision Reasons = Compliance Denial'},
                        'Limited Funding Availability' => new List<String>{'Limited Funding Availability IMED','Limited Funding Availability CAPP','Foundation - Denied - Decision Reasons = Limited Funding Availability'},
                            'Low Priority' => new List<String>{'IMED Low Priority','CAPP Low Priority'},
                                'No Funding Available' => new List<String>{'IMED No Funding Available','Fellowship/Scientific No Funding Available'},
                                    'Outside Therapeutic Area of Interest' => new List<String>{'IMED Outside Therapeutic Area of Interest','CAPP Outside Therapeutic Area of Interest'},
                                        'Unaligned to our Educational Objectives' => new List<String>{'Unaligned to our Educational Objectives'},
                                            'Denied by Business/Financial Approver' => new List<String>{'Denied by Business/Financial Approver Internal'},
                                                'Denied by Legal Approver' => new List<String>{'Denied by Legal Approver Internal'},
                                                    'Canceled at the Request of Applicant' => new List<String>{'Canceled at the Request of Applicant External','Canceled at the Request of Applicant Internal','Foundation - Canceled - Decision Reasons = Canceled at the Request of Applicant'},
                                                        'Canceled Post Funding' => new List<String>{'Canceled Post Funding IMED','Canceled Post Funding CAPP','Canceled Post Funding Internal'},
                                                            'Cannot Agree to LOA Terms'=>new List<String>{'Cannot Agree to LOA Terms External','Cannot Agree to LOA Terms Internal','Foundation - Canceled - Decision Reasons = Cannot Agree to LOA Terms'},
                                                                'Did Not Receive Response to RFI(s)' => new List<String>{'Did Not Receive Response to RFI(s) External','Did Not Receive Response to RFI(s) Internal','Foundation - Canceled - Decision Reasons = Did Not Receive Response to RFI(s)'},
                                                                    'Duplicate Request in System' =>new List<String>{'Duplicate Request in System External','Duplicate Request in System Internal','Foundation - Canceled - Decision Reasons = Duplicate Request in System'},
                                                                        'Insufficient Lead Time to Review Grant' => new List<String>{'Insufficient Lead Time to Review Grant External','Insufficient Lead Time to Review Grant Internal'},
                                                                            'Cancel Request' => new List<String>{'Cancel Request External','Cancel Request Internal'},
                                                                                'Out of Scope' => new List<String>{'Foundation - Denied - Decision Reasons = Out of Scope'},
                                                                                    'Business Reason Denial' => new List<String>{'Business Reason Denial HC Char'}
                
            };
                
                }
        String decisionReasonKey=fundReq.Decision_Reasons__c;
        
        if(decisionReasonKey != null && mappingForCorrespondingEmailTemplateAndDecisonReason.containsKey(decisionReasonKey)){
            
            List<String> emailTemplatesNames=mappingForCorrespondingEmailTemplateAndDecisonReason.get(decisionReasonKey);
            emailTemplatedForClosingForm=[SELECT TemplateType, Subject, Name, Body,HtmlValue 
                                            FROM EmailTemplate 
                                            WHERE Name in : emailTemplatesNames 
                                            AND Folder.DeveloperName=:EMAIL_CLOSE_TEMPLATES_FOLDER 
                                            ORDER BY Name ASC ];
            
            if(emailTemplatedForClosingForm.size()>0 ){
                if(emailTemplatesNames.size() == 1){
                    closeFundingEmailBody    = replaceEmailBody(emailTemplatedForClosingForm[0].Body, this.recipient) ;
                    closeFundingEmailSubject = replaceEmailSubject(emailTemplatedForClosingForm[0].Subject);
                }else{
                    //Select Foundation template
                    if(fundReq.Foundation_Classified__c == 'TRUE'){
                        for(EmailTemplate et: emailTemplatedForClosingForm){
                            if(et.Name.contains('Foundation')){

                                closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                break;
                            }
                        }
                    }else{
                        
                        
                        if(fundReq.Decision_Reasons__c == 'CCO Compliance Denial'){
                            String emailTemplateToUse='';
                            if(checkIfRequestIsExternal(fundReq.Record_Type_Name__c)){

                                emailTemplateToUse = 'CCO Compliance Denial External';
                            }else if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)){

                                emailTemplateToUse = 'CCO Compliance Denial Internal';
                            }
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){
                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                        }else if(fundReq.Decision_Reasons__c == 'Compliance Denial'){
                            String emailTemplateToUse='';
                            if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){

                                emailTemplateToUse = 'Compliance Denial IMED';
                            }else if(checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)){

                                emailTemplateToUse = 'Compliance Denial CAPP';
                            }
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){
                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if( fundReq.Decision_Reasons__c == 'Limited Funding Availability'){
                            
                            String emailTemplateToUse='';
                            if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){

                                emailTemplateToUse = 'Limited Funding Availability IMED';
                            }else if(checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)){

                                emailTemplateToUse = 'Limited Funding Availability CAPP';
                            }
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){
                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if( fundReq.Decision_Reasons__c == 'Low Priority'){
                            
                            String emailTemplateToUse='';
                            if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){

                                emailTemplateToUse = 'IMED Low Priority';
                            }else if(checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse = 'CAPP Low Priority';
                            }
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){
                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if(fundReq.Decision_Reasons__c ==  'No Funding Available'){
                            
                            String emailTemplateToUse='';
                            if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){

                                emailTemplateToUse = 'IMED No Funding Available';
                            }else if(checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)){

                                emailTemplateToUse = 'Fellowship/Scientific No Funding Available';
                            }
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){

                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if(fundReq.Decision_Reasons__c == 'Outside Therapeutic Area of Interest'){
                            
                            String emailTemplateToUse='';
                            if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){

                                emailTemplateToUse = 'IMED Outside Therapeutic Area of Interest';
                            }else if(checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)){

                                emailTemplateToUse = 'CAPP Outside Therapeutic Area of Interest';
                            }
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){

                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if(fundReq.Decision_Reasons__c == 'Canceled at the Request of Applicant'){
                            
                            String emailTemplateToUse='';
                            if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)){

                                emailTemplateToUse = 'Canceled at the Request of Applicant Internal';
                            }else if(checkIfRequestIsExternal(fundReq.Record_Type_Name__c)){

                                emailTemplateToUse = 'Canceled at the Request of Applicant External';
                            }
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){

                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if(fundReq.Decision_Reasons__c == 'Canceled Post Funding'){
                            
                            String emailTemplateToUse='';
                            if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){
                                emailTemplateToUse = 'Canceled Post Funding IMED';
                            }else if(checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse = 'Canceled Post Funding CAPP';
                            }else if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse = 'Canceled Post Funding Internal';
                            }
                            
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){

                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if(fundReq.Decision_Reasons__c == 'Cannot Agree to LOA Terms'){
                            
                            String emailTemplateToUse='';
                            if(checkIfRequestIsExternal(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse = 'Cannot Agree to LOA Terms External';
                            }else if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse = 'Cannot Agree to LOA Terms Internal';
                            }
                            
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){

                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if(fundReq.Decision_Reasons__c == 'Did Not Receive Response to RFI(s)'){
                            
                            String emailTemplateToUse='';
                            if(checkIfRequestIsExternal(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse = 'Did Not Receive Response to RFI(s) External';
                            }else if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse = 'Did Not Receive Response to RFI(s) Internal';
                            }
                            
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){
                                    closeFundingEmailBody    = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if(fundReq.Decision_Reasons__c == 'Duplicate Request in System'){
                            
                            String emailTemplateToUse='';
                            if(checkIfRequestIsExternal(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse ='Duplicate Request in System External';
                            }else if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse ='Duplicate Request in System Internal';
                            }
                            
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){
                                    closeFundingEmailBody    =replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject =replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if(fundReq.Decision_Reasons__c == 'Insufficient Lead Time to Review Grant'){
                            
                            String emailTemplateToUse='';
                            if(checkIfRequestIsExternal(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse ='Insufficient Lead Time to Review Grant External';
                            }else if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse ='Insufficient Lead Time to Review Grant Internal';
                            }
                            
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){
                                    closeFundingEmailBody    =replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject =replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }else if(fundReq.Decision_Reasons__c == 'Cancel Request'){
                            
                            String emailTemplateToUse='';
                            if(checkIfRequestIsExternal(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse = 'Cancel Request External';
                            }else if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)){
                                emailTemplateToUse = 'Cancel Request Internal';
                            }
                            
                            for(EmailTemplate et: emailTemplatedForClosingForm){
                                if(et.Name == emailTemplateToUse){
                                    closeFundingEmailBody    =replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject =replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        }
                    }
                }       
            }
        }       
        
        return null;
    }
    
    public ApexPages.PageReference resetForm(){

        fundReq.External_Sub_status__c =fundReq.Sub_Status__c;
        fundReq.Decision_Reasons__c    =null;
        populateDecisionReasonForFoundation();
        return null;
    }
    
    public Boolean checkIfRequestIsCAPP(String recordType){
        if(recordType == gFRS_Util.TYPE_FELLOWSHIPS_NAME 
            || recordType == gFRS_Util.TYPE_HC_CHAR_NAME 
            || recordType == gFRS_Util.TYPE_PHILANTHROPIC_NAME 
            || recordType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
            return true;
        }
        
        return false;
    }
    
    public Boolean checkIfRequestIsExternal(String recordType){
        if(recordType == gFRS_Util.TYPE_FELLOWSHIPS_NAME 
            || recordType == gFRS_Util.TYPE_HC_CHAR_NAME 
            || recordType == gFRS_Util.TYPE_PHILANTHROPIC_NAME 
            || recordType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME 
            || recordType == gFRS_Util.TYPE_IMED_NAME){
            return true;
        }
        
        return false;
    }
    
    /** 
* @Author ADMD Team
* @date 01/24/2014
* @description getSelectedTemplateLabel method retruns email template name
* 
*/
    public String getSelectedTemplateLabel(List<Selectoption> emailTemplateList, String idOfSelectedTemplate){
        try{
            for(SelectOption option: emailTemplateList){
                if(option.getValue() == idOfSelectedTemplate){
                    return option.getLabel();
                }
            }
        }catch(Exception ex){
            system.debug('user selected empty email template');
            return '';
        }
        
        return '';
    }
    
    /** 
* @Author ADMD Team
* @date 01/24/2014
* @description removeEditSharingForFA1AfterApproveReject method set update sharing to Funding Request from edit to Read after FA1 Approved/Rejected
approval process- basing on Financial_Approver_1_Decision_Date__c field wich is populated after each FA1 approve rejcection.
Method applicable only for FIE funding type - only for FIE funidng types FA1 have edit rights.
* 
*/
    
    public void removeEditSharingForFA1AfterApproveReject(){
        if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME 
            && this.fundReq.Financial_Approver_1__c == UserInfo.getUserId() 
            && this.fundReq.Financial_Approver_1_Decision_Date__c != null){

            List<gFRS_copay_Funding_Request__Share>  FA1Sharings=[SELECT Id, AccessLevel, ParentId,UserOrGroupId,RowCause 
                                                            FROM gFRS_copay_Funding_Request__Share 
                                                            WHERE ParentId =: this.fundReq.id 
                                                            AND UserOrGroupId =: UserInfo.getUserId() 
                                                            AND RowCause='Manual'];
            for(gFRS_copay_Funding_Request__Share itemShare:FA1Sharings){
                itemShare.AccessLevel='Read';
            }
            gFRS_Util_NoSharecopay.upsertRequestSharescopay(FA1Sharings);      
        }
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description dateToString method - Converts a date to a string representation.
*/
    private String dateToString( Date d ){
        if( d == null ){
            return( '' );
        } else {
            DateTime dt = DateTime.newInstance( d.year(), d.month(), d.day() );
            return( dt.format( 'MM/dd/yyyy' ));
        }
    }
    
    /** 
* @Author ADMD Team
* @date 10/21/2013
* @description method repsonsible for presenting correct currency format
* 
*/
    public static String formatToCurrency(String i) {
        String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
        return  s.substring(0,s.length()-1);
    }
    
    
    /** 
* @Author GFRS Dev Team 
* @date 26/11/2014
* @description startCloningOperation method - cloning handler
*/
    public ApexPages.PageReference startCloningOperation(){
        
        if(checkIfCloneSuperUser){ 
           // clonedRequest     = gFRS_CloningUtil.customCloneWithInsert(this.fundReq, fundReq.clonedRequestOwner__c, this.fundReq.Record_Type_Name__c, fundReq.Organization__c, fundReq.Location__c);
           // clonedRequestName = gFRS_CloningUtil.getClonedRequestName(clonedRequest);                
        }
        cloningProcessFinished = true;
        
        return null;
        
    }
    
    /**
* @author GFRS Dev Team 
* @date 26/11/2014
* @description isCloneButtonVisible variable - indicates whether 'Clone' button should be displayed on layout.
*/
    public Boolean isCloneButtonVisible{
        get{
            
                    return true;
           
        }
        set;
    }
    
    public Boolean checkIfSuperUserCanClone(String recordTypeName){
        
        if(gFRS_Util.isInternalRequest(recordTypeName) 
            || recordTypeName == gFRS_Util.TYPE_HC_CHAR_NAME 
            || recordTypeName == gFRS_Util.TYPE_PHILANTHROPIC_NAME ){
            return true;
        }
        
        return false;
    }
    
    public Boolean checkIfUserBelonsToMCSGroup{
        get{
            Group mcsGroup = [SELECT Id, Name 
                                FROM Group 
                                WHERE Name =:gFRS_Util.MCS_GROUP_NAME LIMIT 1];

            if(mcsGroup != null && mcsGroup.Id != null){
                if([SELECT GroupId, Id, UserOrGroupId FROM GroupMember WHERE GroupId =: mcsGroup.id AND UserOrGroupId =: UserInfo.getUserId()].size() >0){
                    //curret user is member of 'GNE-GFRS-M&CS' public group and clone button should be visible
                    return true;
                }
            }
            return false;
        }
        set;
    }
    
    public Boolean checkIfCloneSuperUser
    {
        get
        {
            Set<String> profileNames = new Set<String>{gFRS_Util.PROFILE_NAME_GFRS_ADMIN, gFRS_Util.PROFILE_NAME_NO_SSO_SUPER_USER, gFRS_Util.PROFILE_NAME_SUPER_USER, gFRS_Util.PROFILE_NAME_SYS_ADMIN, gFRS_Util.PROFILE_NAME_SYS_SUPPORT};
                
               return true;
            
        }   
        set;
    }
    
    private Map<Id, Profile> getProfiles(Set<String> profilesNames){
        
        Map<Id, Profile> profileIdToRecord = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE name IN :profileNames ]);
        
        return profileIdToRecord;
    }
    class CustomException extends Exception {}
}