/**
* @author ADMD Team
* @date 08/03/2013
* @description gFRS_FundingRequestReadController class - Controller class used by GFRS_Funding_Request_Read apex page.
*/
public with sharing class gFRS_FundingRequestReadController {
    
    public static String debugPrefix = '***gFRS_FundingRequestReadController*** ';
    
    public static final String EMAIL_TEMPLATES_FOLDER = 'gFRS_RFI_Templates';// Email templates folder, where available for use templates are stored
    public static final String EMAIL_CLOSE_TEMPLATES_FOLDER = 'gFRS_Close_Request_Templates';
    public static final String COMPLIANCE_FLAGS_NOTES_PERM_SET_NAME = 'gFRS_Compliance_Flags_Notes';
    public static final String CONTENT_TYPE = 'RFI'; // The type of page this is
    public static final String PATH_DECISION_RESULT = Page.gFRS_Application.getURL() + '?id='; //The URL address to send teh client on their task.
    public static final String PATH_REQUEST = Page.gFRS_Funding_Request_Read.getURL();//The URL address of the funding request Read
    public static final Map<String, String> URLs = new Map<String, String>{
        'Organization' => '/apex/GFRS_Org_Info', 'Budget' => 'gFRS_Budget', 'Program' => 'GFRS_Program', 'Application' => 'GFRS_Home'
            }; // URL used in email templates
                
                public static final String AP_REJECTED_STATUS = 'Rejected';
    public static final Set<String> RECALL_APPROVAL_PROCESSES = new Set<String>{'CAPP/DEV Approval Process', 'CAPP/DEV Approval Process for Recall' /*, 'Philanthropic Approval Process', 'Philanthropic Approval Process For Recal'*/};
        public static final String GC_REVIEW_SUB_STATUS = 'GC Review';
    public static final String DECISION_STATUS = 'Decision';
    public static final String RECALL_PERMISSIONSET_NAME = 'gFRS_Funding_Request_Recall';
    public static final Set<String> RECALL_SUB_STATUSES = new Set<String>{'Denied','Canceled','Legal Review','Committee Review','Business Approval','Financial Approval','Approved-Awaiting LOA'};
        public static final String UNDER_REVIEW_STATUS = 'Under Review';
    
    public User recipient;
    public Id rfiOtherUserId{ get; set; }
    public string decisReason;
    public List<SelectOption> lETs;//  List of Email Templates taken from db
    public List<SelectOption> recipientsList;  //  List of available recipients, build in controller constructor
    public List<Selectoption> recipientListSelected { get; set; }//  List of selected recipients
    public Map<Id, EmailTemplate> mEtId2Body = new Map<Id, EmailTemplate>();
    public Map<Id, User> recipientsToBeDisplayed; // list of possibile recipients and its criteria - to be defined
    private RecordType RT_PAY_HISTORY_READONLY;// READONLY payment history record type
    
    public String subjectContent { get; set; }
    public List<String> finalSelectedRecipients { get; set; }
    
    public Boolean isClosingPopUpShown { get; set; }// Whether the funding request 'closing' pop-up is shown
    public Boolean isClongPopUpShown { get; set; }
    public Boolean canCreateAnotherPaymentFA { get {return checkIfUserCanCrateAnotherFundingAllocation();} }//Property can user create another Payment Funding Allocation
    public Boolean isRFI_PopUpShown { get; set; }// Whether the RFI pop-up is shown.
    public Boolean isRFI_BackOffice { get; set; }// Whether the RFI pop-up is shown.
    public Boolean isACHOverride_PopUpShown { get; set; }// Whether the ACH pop-up is shown.
    public Boolean isCCChecked { get; set; }
    public Boolean isAuthorizedSignerSelected { get; set; }
    public Boolean isAccountableEmploySelected { get; set; }
    public Boolean showAccountableRecipient { get; set; }
    public Boolean showAuthorizedSigner { get; set; }
    public Boolean isChangeApproverPopupShown { get; set; }
    public Boolean canUserChangeApprover { get; set; }
    
    public Boolean isCSUser { get; set; }
    public Boolean isCSAEUser { get; set; }
    
    public Boolean isOwnerAESame { get; set; }
    public Boolean isOwnerAEDiffernt { get; set; }
    
    public Boolean isOwnerAEDifferntchk1 { get; set; }
    public Boolean isOwnerAEDifferntchk2 { get; set; }
    public Boolean isLOAEmail { get; set; }
    public Boolean isCCHide { get; set; }
    
    public String selectedET { get; set; }// Points Email Template which has been send
    public Id extendPaymentMethodTemplateId { get; set; }// Points to Extending Payment Method Submission task Email Template
    public Id doNotExtendPaymentMethodTemplateId { get; set; }// Points to Do Not Extend Payment Method Submission task Email Template
    public string etBody { get; set; }//  Email body content variable
    
    public GFRS_Funding_Request__c fundReq { get; set; }// The Funding Request object used
    public GFRS_Funding_Request__c requestTemp { get; set; }// Stores only the email recipient address, fake record
    public gFRS_Funding_Request__c originalStatusValues { get; set; }// original status values when the funding request
    public Map<String, String> contentItems { get; set; }
    public Boolean isRFIdisabled { get; set; }
    public String selectedDecisionReason { get; set; }
    public List<Selectoption> decisionReasonForFoundation { get; set; }
    public String bccEmailAddress { get; set; }
    public String ccEmailAddress { get; set; }
    public User ownerOfReqest { get; set; }
    public GFRS_Funding_Request__c clonedRequest { get; set; }
    public String clonedRequestName { get; set; }
    public Boolean cloningProcessFinished { get; set; }
    public boolean disButton { get; set; }// Specifies, whether the button SEND should be disabled or not and its negation is used for Email Content visibility
    public boolean disACHButton { get; set; }// Specifies, whether the button SUBMIT should be disabled or not
    public boolean mailToAuthSignerOnly { get; set; }
    public boolean mailToOwnerOnly { get; set; }
    public String vendorBlockMessage { get; set; }
    public Boolean recallMode { get; set; }
    
    public Map<Id, Profile> profileIdToRecord;
    public Set<String> profileNames;
    public date dueDate;
    
    //JIRA 159
    public User usr {get;set;}
    public Boolean validatebackoffice { get {return checkIfUserBackOfficeProfile();} }//Property can user create another Payment Funding Allocation
    public List<String> listOfStrings {get; set;}
    
    public String parentRecord {
        get {
            return fundReq.ParentRecord__c;
            return null;
        }
        
        set;
    }
    
    public Boolean isUserHasPermissionOrAdmin {
        get {
            return gFRS_Util_NoShare.isUserHasPermissionOrAdmin(COMPLIANCE_FLAGS_NOTES_PERM_SET_NAME);
        }
        private set;
    }
    
    public Boolean isRequestInPendingQCO {
        get {
            List<ProcessInstance> processInstances = gFRS_Util_NoShare.getProcessInstancesForAffectedSteps(new List<Id>{
                fundReq.Id
                    }, new List<String>{
                        gFRS_Util_NoShare.PENDING
                            });
            if (processInstances.size() > 0) {
                return gFRS_Util_NoShare.getProcessInstanceNodes(processInstances, new List<String>{
                    'QCO Review'
                        }).containsKey(fundReq.Id) ? true : false;
            }
            return false;
        }
        private set;
    }
    
    public Boolean checkIfReqestWasApprovedAndUserIsFA {
        get {
            String userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;
            if (userProfileName != gFRS_Util.PROFILE_NAME_GFRS_ADMIN && userProfileName != gFRS_Util.PROFILE_NAME_SYS_ADMIN) {
                if (this.fundReq != null) {
                    Id userId = Userinfo.getUserId();
                    if (this.fundReq.Financial_Approver_1__c == userId && this.fundReq.Financial_Approver_1_Decision_Date__c != null) {
                        return true;
                    } else if (this.fundReq.Financial_Approver_2__c == userId && this.fundReq.Financial_Approver_2_Decision_Date__c != null) {
                        return true;
                    } else if (this.fundReq.Financial_Approver_3__c == userId && this.fundReq.Financial_Approver_3_Decision_Date__c != null) {
                        return true;
                    } else {
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
    public Boolean checkIfReqestWaitingForBAOrLRApprovalForFoundation {
        get {
            String userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;
            if (userProfileName != gFRS_Util.PROFILE_NAME_GFRS_ADMIN && userProfileName != gFRS_Util.PROFILE_NAME_SYS_ADMIN) {
                if (this.fundReq != null) {
                    Id userId = Userinfo.getUserId();
                    
                    if (this.fundReq.Foundation_Classified__c == 'TRUE'
                        && (userId == fundReq.Business_Approver__c
                            || userId == fundReq.Legal_Reviewer_1__c)) {
                                
                                if (fundReq.Business_Approver__c != fundReq.Business_Reviewer_1__c
                                    && fundReq.Business_Approver__c != fundReq.Business_Approver_2__c
                                    && fundReq.Business_Approver__c != fundReq.Business_Approver_3__c) {
                                        
                                        //BA1 have only read access for Foundation
                                        return true;
                                    } else if (fundReq.Legal_Reviewer_1__c != fundReq.Business_Reviewer_1__c
                                               && fundReq.Legal_Reviewer_1__c != fundReq.Business_Approver_2__c
                                               && fundReq.Legal_Reviewer_1__c != fundReq.Business_Approver_3__c) {
                                                   
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
    
    public List<Selectoption> getEmpytSelectList() {
        
        return new List<SelectOption>();
    }
    
    public List<SelectOption> rightOptionForCloseForm { get; set; }
    
    private Map<String, List<String>> mappingForCorrespondingEmailTemplateAndDecisonReason = null;
    private List<EmailTemplate> emailTemplatedForClosingForm = null;
    
    public String closeFundingEmailBody { get; set; }
    public String closeFundingEmailSubject { get; set; }
    public String baseUrl { get; set; }
    public String requestID { get; set; }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description : class constructor
*/
    public gFRS_FundingRequestReadController(ApexPages.Standardcontroller std) {
        
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        fundReq = (GFRS_Funding_Request__c) std.getRecord();
        requestID = this.fundReq.id;
        
        try {
            fundReq = [
                SELECT Last_Live_Program_End_Date__c, Funding_Sub_Type__c, CreatedDate, Funding_Type__c, Location__c,
                ParentRecord__c, clonedRequestOwner__c, Request_Cloned__c, Bank_Lookup_Required__c, Partner_Bank_Type__c,
                Id, Business_Reviewer_1__c, Legal_Reviewer_1__c, Therapeutic_Area__c,Program_Status_Task_Override_By__c,
                Business_Approver_2__c, Business_Approver_3__c, Financial_Approver_1__c, Program_Status_Task_Expiration_Date__c,
                Financial_Approver_1_Decision_Date__c, Financial_Approver_2__c, ACH_Task_Open__c, ACH_Override_by__c,
                Financial_Approver_2_Decision_Date__c, Financial_Approver_3__c, Overriden_On__c, Overriding_reason__c,
                Financial_Approver_3_Decision_Date__c, isLocked, Name,owner.id, Organization__r.US_Organization__c,
                Owner.Email, Owner.Name, Approved_Amount__c, Date_Submitted__c, Number_of_Programs__c,
                gCOI_Pending_Actions__c, Refundable_Deposit_Amount_if_any__c, Foundation_Classified__c,
                Attention_To__c, Building__c, Delivery_Method__c,Payment_Method__c, Event_Program_Title__c,
                External_Sub_status__c, Information_Needed__c, LOA_Signed__c,StatusUpdate_Communication_Sent__c,
                Location__r.Vendor_Id__c, Organization__r.Id,Communication_CC__c, Payment_Call_Counter__c,Date_for_33_logic__c,
                Payment_Email_Notification__c, Record_Type_Name__c, Request_AutoNumber__c,
                Requested_Amount__c, Send_By_FedEx_cost_center_will_be_charg__c, Status__c,
                Sub_Status__c, Decision_Reasons__c, Will_You_be_Working_With_a_3rd_Party__c,
                Unix_ID__c, createdById, Accountable_Employee_Approval__c, Payment_Method_Due_Date__c,
                Accountable_Employee_Approval__r.Email,Accountable_Employee_Approval__r.Name,
                SYS_Request_Approved__c,LOA_PDF__c, LastModifiedBy.Name,Compliance_flags_PDF__c,
                Decision_Date__c, HC_Compliance_Date__c, HC_Compliance_Flags_PDF__c, Authorized_Signer__c,
                Signing_Authority_First_Name__c, Signing_Authority_Last_Name__c, Signing_Authority_Email__c,
                Program_Start_Date_Min__c, Program_End_Date_max__c, Evaluation_Completed__c,Accountable_Employee_Approval__r.ProfileId,
                Business_Approver__c, Business_Reviewer_Decision_Date__c, Business_Reviewer_Decision__c,
                Business_Approver_Decision_Date__c,Financial_Approver_1__r.Email, Reconciliation_Completed__c,
                Closed_Date__c, Refund_Due__c,CreatedBy.profileid,Owner.Profileid,(SELECT Id FROM Payment_History__r)
                FROM GFRS_Funding_Request__c
                WHERE Id = :this.fundReq.id
                LIMIT 1
            ];
            
            if (this.fundReq.Payment_Call_Counter__c == null) this.fundReq.Payment_Call_Counter__c = 0;
            
        } catch (Exception err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage()));
            return;
        }
        
        if (GFRS_Util.showWarningMessageForGLAccount(fundReq)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.gFRS_Check_GL_Account));
        }
        
        RT_PAY_HISTORY_READONLY = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :gFRS_Util.RT_PAYHISTORY_READONLY
            AND SobjectType = 'GFRS_Payment_History__c'
        ];
        
        this.requestTemp = new GFRS_Funding_Request__c();
        
        //get email used in email service to attached sent emails
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        if (myOrgCS.gFRS_Inbound_Email__c != null) {
            
            bccEmailAddress = myOrgCS.gFRS_Inbound_Email__c;
        }
        //By default athorized signer checkbox shouldn't be visible variable initialization    
        showAuthorizedSigner = false;
        
        profileNames = new Set<String>{
            gFRS_Util.PROFILE_NAME_GFRS_ADMIN, gFRS_Util.PROFILE_NAME_NO_SSO_SUPER_USER, gFRS_Util.PROFILE_NAME_SUPER_USER, gFRS_Util.PROFILE_NAME_SYS_ADMIN, gFRS_Util.PROFILE_NAME_SYS_SUPPORT
                };
                    profileIdToRecord = getProfiles(profileNames);
        recallMode = checkIfRecallIsAvailable();
        
        //isCSUser
        
        //List<Profile> csProfile=[Select Id From Profile where Name='GNE-SFA-CS' LIMIT 1];
        
        Set<id> csIds=new Set<id>();
        
        for(Profile csProfile:[Select Id, name From Profile where Name like 'GNE-SFA%-CS']){
            
            csIds.add(csProfile.id);
            
        }
        
        fundReq.Communication_CC__c=null;
        If((csIds.contains(this.fundReq.Owner.Profileid)) && this.fundReq.Accountable_Employee_Approval__c!=null && (this.fundReq.Accountable_Employee_Approval__c!=this.fundReq.OwnerId) ){
            isCSUser=true;
            //isAccountableEmploySelected=true;
            //fundReq.Communication_CC__c=this.fundReq.Ownerid;
        }
        else{
            isCSUser=false;
        }
        
        //isCSAEUser
        
        if(this.fundReq.Accountable_Employee_Approval__c!=null){
            if(this.fundReq.Ownerid==this.fundReq.Accountable_Employee_Approval__c){
                isOwnerAESame=true;
                isOwnerAEDiffernt=false;
            }
            else{
                isOwnerAEDiffernt=true;
                isOwnerAESame=false;
            }
        }
        
    }
    /* ### End of constructor ### */
    
    public void CheckSharingApprover() {
        gFRS_Util_NoShare.CreateSharingOnFundingRequest(fundReq);
    }
    
    
    /**
* @Author ADMD Team
* @date 20/01/2014
* @description getRecipientsList method - returns recipients list.
*/
    public List<SelectOption> getRecipientsList() {
        return this.recipientsList;
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description getAvailableET method - returns Email Templates.
*/
    public List<SelectOption> getAvailableET() {
        return this.lETs;
    }
    
    
    public void showClone_Popup() {
        isClongPopUpShown = true;
        fundReq.clonedRequestOwner__c = fundReq.owner.Id;
        cloningProcessFinished = false;
        
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        if(userProfile.Name=='GNE-GFRS-Backoffice'){
            isClongPopUpShown = false;
        }
        
        //For MSC Group cloning process stating automatically without selecting owner for cloned request
        if (checkIfUserBelonsToMCSGroup && !checkIfCloneSuperUser || (fundReq.OwnerId == UserInfo.getUserId())
            && (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME
                || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME
                || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME)) {
                    clonedRequest = gFRS_CloningUtil.customCloneWithInsert(this.fundReq, UserInfo.getUserId(), fundReq.Record_Type_Name__c, fundReq.Organization__c, fundReq.Location__c);
                    clonedRequestName = gFRS_CloningUtil.getClonedRequestName(clonedRequest);
                    cloningProcessFinished = true;
                }
        
    }
    
    public void hideClone_Popup() {
        isClongPopUpShown = false;
    }
    
    public void checkIfVendorBlocked() {
        System.debug('check if vendor is blocked, id: ' + this.fundReq.Location__r.Vendor_Id__c);
        
        
        if (this.fundReq.Location__r.Vendor_Id__c != null) {
            try {
                gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0 sapLookup = new gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0();
                sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
                GFRS_VendorLookupSAP.VendorLookupResponse_element response = sapLookup.VendorLookup('', this.fundReq.Location__r.Vendor_Id__c, '', '', '', '100');
                
                if (response.MessageType == 'S') {
                    handleResponse(response);
                    vendorBlockMessage = 'blocked';
                } else {
                    System.debug(response);
                    vendorBlockMessage = 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem';
                }
                
            } catch (Exception err) {
                System.debug('ERROR OCCURRED:' + err.getMessage());
                vendorBlockMessage = 'asdsada';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem'));
            }
        } else {
            System.debug('No vendor id has been provided');
        }
    }
    
    public void handleResponse(GFRS_VendorLookupSAP.VendorLookupResponse_element response) {
        if (response.MessageText != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, response.MessageText));
            return;
        }
        for (GFRS_VendorLookupSAP.VendorDetails_element d : response.VendorDetails) {
            GFRS_Location__c l = new GFRS_Location__c();
            this.fundReq.Location__r.Posting_block_for_all_company_codes__c = d.PostingBlockAllCompanyCode;
            this.fundReq.Location__r.Posting_block_for_1000_or_1010__c = d.PostingBlockSpecifiedCompanyCode;
            this.fundReq.Location__r.Deletion_Flag_for_all_company_codes__c = d.DeletionFlagAllArea;
            this.fundReq.Location__r.Deletion_Flag_for_all_1000_or_1010__c = d.DeletionFlagSelectedCompanyCode;
            this.fundReq.Location__r.Payment_Block_Indicator__c = d.PaymentBlockIndicator;
            this.fundReq.Location__r.Payment_Block_Description__c = d.PaymentBlockDescription;
        }
        //update this.fundReq.Location__r;
    }
    
    public Boolean isNewToCCOButtonVisible {
        get {
            return true;
        }
        set;
    }
    
    /** 
* @Author gFRS Team
* @date 13/02/2019
* @description showACH_Popup method - Opens the ACH Pop-up.
*/
    public void showACH_Popup() {
        this.isACHOverride_PopUpShown = true;
        disACHButton = false;
        //  List<gFRS_Tasks__c> tasks = [SELECT Id, Name FROM gFRS_Tasks__c WHERE Action_Type__c = 'ACH' AND gFRS_Funding_Request__c =: this.fundReq.Id AND gFRS_Funding_Request__r.Organization__r.US_Organization__c='Yes'];
        if(this.fundReq.Status__c != 'HC Compliance' || this.fundReq.Organization__r.US_Organization__c == 'No'){
            disACHButton = true;
        }
    }
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description showRFI_Popup method - Opens the RFI Pop-up.
*/
    public void showRFI_Popup() {
        
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        if(userProfile.Name=='GNE-GFRS-Backoffice'){
            this.isRFI_BackOffice=true;
        }
        disButton = true;
        this.isRFI_PopUpShown = true;
        this.dueDate = fundReq.Payment_Method_Due_Date__c;
        selectedET = 'NONE';
        
        isRFIdisabled = true;
        this.lETs = new List<SelectOption>();
        String userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;
        
        Profile checkProfile = [SELECT Id, Name FROM Profile WHERE Id=:fundReq.createdby.Profileid];
        
        if (fundReq.Record_Type_Name__c != null && (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME
                                                    || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME
                                                    || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME
                                                    || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)
            && this.fundReq.Accountable_Employee_Approval__c != null && checkProfile.Name!='GNE-GFRS-Backoffice') {
                showAccountableRecipient = true;
            } else {
                showAccountableRecipient = false;
            }
        
        this.recipient = [
            SELECT Id, FirstName, LastName, Name, Email, ContactId
            FROM User
            WHERE Id = :fundReq.OwnerId
        ].get(0);
        
        
        this.lETs.add(new SelectOption('NONE', ' - please select template -'));
        
        EmailTemplate[] ets = [
            SELECT Subject, Name, Id, Description, Body,DeveloperName
            FROM EmailTemplate
            WHERE Folder.DeveloperName = :EMAIL_TEMPLATES_FOLDER
            ORDER BY Name ASC
        ];
        for (EmailTemplate et1 : ets) {
            this.mEtId2Body.put(et1.Id, et1);
            if (this.fundReq.Foundation_Classified__c == 'TRUE') {
                if (et1.DeveloperName.contains('Foundation')) {
                    this.lETs.add(new SelectOption(et1.Id, et1.Name));
                }
            } else {
                if (this.fundReq.Record_Type_Name__c == 'IMED') {
                    
                    if (et1.DeveloperName == 'gFRS_RFI'
                        || et1.DeveloperName == 'gFRS_RFI_Outcomes'
                        || (et1.DeveloperName == 'gFRS_RFI_Reconciliation_Request_Communication' && this.fundReq.Reconciliation_Completed__c == 'No') //GFRS-900
                        || et1.DeveloperName == 'LOA_Reminder_Communication'
                        || et1.DeveloperName == 'General_Communication_External'
                        || et1.DeveloperName == 'Canceled_Post_Funding_Communication'
                        || et1.DeveloperName == 'Payment_Method_Communication') {
                            
                            this.lETs.add(new SelectOption(et1.Id, et1.Name));
                        }
                    
                    /* Jira 211
                    if (((this.fundReq.Last_Live_Program_End_Date__c != null
                          && et1.DeveloperName == 'Sunshine_Act_Disclosure_Request_Communication'
                          && this.fundReq.Closed_Date__c == null) || (et1.DeveloperName == 'Sunshine_Act_Disclosure_Request_Communication'
                                                                      && this.fundReq.Closed_Date__c != null && userProfileName == gFRS_Util.PROFILE_NAME_GFRS_ADMIN)) && this.fundReq.Sub_Status__c != gFRS_Util.REQUEST_SUB_STATUS_REFUND_REQ) {
                                                                          this.lETs.add(new SelectOption(et1.Id, et1.Name));
                                                                      }*/
                    
                } else if (this.fundReq.Record_Type_Name__c == 'HC CHAR') {
                    if (et1.DeveloperName == 'gFRS_RFI'
                        || et1.DeveloperName == 'Program_Cancelation_Communication'
                        || et1.DeveloperName == 'Program_Denial_Communication'
                        || et1.DeveloperName == 'Evaluation_Reminder_Communication'
                        || et1.DeveloperName == 'LOA_Reminder_Communication'
                        || et1.DeveloperName == 'General_Communication_External'
                        || et1.DeveloperName == 'Payment_Method_Communication') {
                            
                            this.lETs.add(new SelectOption(et1.Id, et1.Name));
                        }
                } else if (this.fundReq.Record_Type_Name__c == 'Philanthropic') {
                    if (et1.DeveloperName == 'gFRS_RFI'
                        || et1.DeveloperName == 'Evaluation_Reminder_Communication'
                        || et1.DeveloperName == 'LOA_Reminder_Communication'
                        || et1.DeveloperName == 'General_Communication_External'
                        || et1.DeveloperName == 'Payment_Method_Communication') {
                            
                            this.lETs.add(new SelectOption(et1.Id, et1.Name));
                            
                        }
                } else if (this.fundReq.Record_Type_Name__c == 'Scientific Projects') {
                    if (et1.DeveloperName == 'gFRS_RFI'
                        || et1.DeveloperName == 'Evaluation_Reminder_Communication'
                        || et1.DeveloperName == 'LOA_Reminder_Communication'
                        || et1.DeveloperName == 'General_Communication_External'
                        || et1.DeveloperName == 'Payment_Method_Communication') {
                            
                            this.lETs.add(new SelectOption(et1.Id, et1.Name));
                            
                        }
                } else if (this.fundReq.Record_Type_Name__c == 'Fellowships') {
                    if (et1.DeveloperName == 'gFRS_RFI'
                        || et1.DeveloperName == 'Evaluation_Reminder_Communication'
                        || et1.DeveloperName == 'LOA_Reminder_Communication'
                        || et1.DeveloperName == 'General_Communication_External'
                        || et1.DeveloperName == 'Payment_Method_Communication') {
                            
                            this.lETs.add(new SelectOption(et1.Id, et1.Name));
                            
                        }
                } else if (this.fundReq.Record_Type_Name__c == 'Field Initiated Exhibits'
                           || this.fundReq.Record_Type_Name__c == 'Exhibits & Other Promos'
                           || this.fundReq.Record_Type_Name__c == 'Corporate Memberships'
                           || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
                               
                               if (et1.DeveloperName == 'gFRS_RFI_Internal'
                                   || et1.DeveloperName == 'General_Communication_Internal') {
                                       this.lETs.add(new SelectOption(et1.Id, et1.Name));
                                   }
                               if ((this.fundReq.Record_Type_Name__c == 'Exhibits & Other Promos'
                                    || this.fundReq.Record_Type_Name__c == 'Corporate Memberships'
                                    || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)
                                   && et1.DeveloperName == 'LOA_Reminder_Communication') {
                                       this.lETs.add(new SelectOption(et1.Id, et1.Name));
                                   }
                               if ((this.fundReq.Record_Type_Name__c == 'Exhibits & Other Promos'
                                    || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)
                                   && this.fundReq.Number_of_Programs__c > 1
                                   && (this.fundReq.Status__c == 'Closed' || this.fundReq.Status__c == 'Processing & Disposition')
                                   && (this.fundReq.Program_End_Date_max__c <= date.today())
                                   && et1.DeveloperName == 'Re_open_Program_Status_Task_Email_Notification') {
                                       this.lETs.add(new SelectOption(et1.Id, et1.Name));
                                   }
                               if(et1.DeveloperName == 'Extend_Payment_Method_Due_Date'){
                                   this.lETs.add(new SelectOption(et1.id, et1.Name));
                                   this.extendPaymentMethodTemplateId = et1.id;
                               }
                               if(et1.DeveloperName == 'Do_Not_Extend_Payment_Method_Due_Date'){
                                   this.lETs.add(new SelectOption(et1.id, et1.Name));
                                   this.doNotExtendPaymentMethodTemplateId = et1.id;
                               }                   
                           }
            }
        }
        // }
        //System.debug( 'isRFI_PopUpShown:' + isRFI_PopUpShown );
    }
    
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description showRFI_Popup method - Closes the RFI Popup.
*/
    public void hideRFI_Popup() {
        
        selectedET = 'NONE';
        this.isRFI_PopUpShown = false;
        this.fundReq.Communication_CC__c=null;
        if(isOwnerAEDifferntchk1!=null&&isOwnerAEDifferntchk2!=null){
            isOwnerAEDifferntchk1=null;
            isOwnerAEDifferntchk2=null;
        }
    }
    /** 
* @Author gFRS Team
* @date 13/02/2019
* @description hideACH_Popup method - Closes the ACH Override Popup.
*/
    public void hideACH_Popup() {
        this.isACHOverride_PopUpShown = false;
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description showClosingPopup method - Opens the RFI Pop-up.
*/
    public ApexPages.PageReference showClosingPopup() {
        if (gFRS_Util.REQUEST_STATUS_CLOSED.equals(this.fundReq.Status__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.gFRS_ERROR_ALREADY_CLOSED));
            return(null);
        }
        
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        if(userProfile.Name=='GNE-GFRS-Backoffice'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Insufficient Privileges'));
            return(null);
            
        }
        
        
        //-- clone the values before the status
        this.originalStatusValues = this.fundReq.clone();
        
        List<User> tmpUsers = new List<User>([SELECT Id, FirstName, LastName, Name, Email, ContactId FROM User WHERE Id = :fundReq.OwnerId]);
        if (tmpUsers.size() > 0) {
            this.recipient = tmpUsers[0];
            rightOptionForCloseForm = new List<SelectOption>();
            rightOptionForCloseForm.add(new SelectOption(recipient.Id, 'Owner - ' + recipient.Name));
        }
        this.fundReq.Status__c = gFRS_Util.REQUEST_STATUS_CLOSED;
        this.fundReq.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_CANCELLED;
        this.fundReq.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_CANCELLED;
        
        this.isClosingPopUpShown = true;
        populateDecisionReasonForFoundation();
        
        return(null);
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description populateDecisionReasonForFoundation method - method populate values for Decision Reason select list if funding type is Foundation classified.
*/
    public void populateDecisionReasonForFoundation() {
        
        decisionReasonForFoundation = new List<Selectoption>();
        if (this.fundReq != null && this.fundReq.Sub_Status__c == 'Denied') {
            decisionReasonForFoundation = new List<Selectoption>{
                new Selectoption('', '--None--'),
                    new Selectoption('Compliance Denial', 'Compliance Denial'),
                    new Selectoption('Limited Funding Availability', 'Limited Funding Availability'),
                    new Selectoption('Out of Scope', 'Out of Scope')
                    };
                        
                        } else if (this.fundReq != null && this.fundReq.Sub_Status__c == 'Canceled') {
                            decisionReasonForFoundation = new List<Selectoption>{
                                new Selectoption('', '--None--'),
                                    new Selectoption('Canceled at the Request of Applicant', 'Canceled at the Request of Applicant'),
                                    new Selectoption('Cannot Agree to LOA Terms', 'Cannot Agree to LOA Terms'),
                                    new Selectoption('Did Not Receive Response to RFI(s)', 'Did Not Receive Response to RFI(s)'),
                                    new Selectoption('Duplicate Request in System', 'Duplicate Request in System'),
                                    new Selectoption('Incorrect Funding Type - Donations to CAF', 'Incorrect Funding Type - Donations to CAF')
                                    };
                                        
                                        } else {
                                            decisionReasonForFoundation = new List<Selectoption>{  new Selectoption('', '--None--') };
                                                }
        
        selectedDecisionReason = '';
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description hideClosingPopup method - Closes the RFI Popup.
*/
    public void hideClosingPopup() {
        this.revertStatusChanges();
        this.isClosingPopUpShown = false;
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description revertStatusChanges method - Revert the status changes.
*/
    private void revertStatusChanges() {
        if (this.originalStatusValues != null) {
            
            this.fundReq.Status__c = this.originalStatusValues.Status__c;
            this.fundReq.Sub_Status__c = this.originalStatusValues.Sub_Status__c;
            this.fundReq.External_Sub_status__c = this.originalStatusValues.External_Sub_status__c;
            this.fundReq.Decision_Reasons__c = this.originalStatusValues.Decision_Reasons__c;
        }
        this.originalStatusValues = null;
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description closeFundingRequest method - Method used by the custom button to close the funding request
* (so the status can remain read-only through the page layouts)
*/
    public ApexPages.PageReference closeFundingRequest() {
        this.fundReq.Status__c = gFRS_Util.REQUEST_STATUS_CLOSED;
        
        //-- make the decision reason required only if the sub status is approved
        
        if (!gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED.equals(this.fundReq.Sub_Status__c) &&
            this.fundReq.Decision_Reasons__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_DECISION_REASON_REQ));
                return(null);
            }
        
        
        try {
            
            if (fundReq.Sub_Status__c != 'Approved') {
                if (closeFundingEmailSubject == null || closeFundingEmailSubject == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptySubject));
                    return null;
                }
                if (closeFundingEmailBody == null || closeFundingEmailBody == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptyContent));
                    return null;
                }
                
                sendCloseFundingEmail();
            }
            
            if (this.fundReq.Sub_Status__c == 'Denied')//mark denial as UI denial not from standard reject approval process screen.
            {
                this.fundReq.UICloseRequestDenial__c = true;
            }
            
            gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(this.fundReq);
            
            //Automaticy reject the request if needed
            if (this.fundReq.SYS_Request_Approved__c != 'No') {
                
                gFRS_InternalCancellationProcess.autoRejectRecord(this.fundReq);
            }
            
            
            //-- not needed since the page must refresh, but makes things clearer
            this.isClosingPopUpShown = false;
            
            //-- redirect to show the changes
            return(new ApexPages.PageReference(gFRS_Util.initializeLink(PATH_REQUEST, this.fundReq, null)).setRedirect(true));
        } catch (Exception err) {
            System.debug('ERROR OCURRED:' + err.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
        }
        
        return(null);
    }
    
    
    /** 
* @Author ADMD Team
* @date 21/02/2014
* @description sendCloseFundingEmail method - Method used to sent email if user  
* close the funding request using custom button Close Funding Request
*/
    public void sendCloseFundingEmail() {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{
                recipient.Email
                    });
            mail.setSubject(this.closeFundingEmailSubject);
            
            // (Optional) Set list of people who should be CC'ed
            if (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) {
                
                String ccEmailAddress = null;
                ccEmailAddress = fundReq.Financial_Approver_1__r.Email;
                
                system.debug('CC email ' + ccEmailAddress);
                if (ccEmailAddress != null) {
                    mail.setCcAddresses(new List<String>{
                        ccEmailAddress
                            });
                }
            }
            
            if (bccEmailAddress != null) {
                if (decisReason == 'Incorrect Funding Type - Donations to CAF') {
                    mail.setBccAddresses(new List<String>{
                        bccEmailAddress, system.Label.gFRS_Copay_CC_Mail_Id
                            });
                } else {
                    mail.setBccAddresses(new List<String>{
                        bccEmailAddress
                            });
                }
            }
            
            closeFundingEmailBody += '\n\n' + '[ref:' + fundReq.id + ']';
            mail.setPlainTextBody(closeFundingEmailBody);
            
            mail.setOrgWideEmailAddressId([
                SELECT Id, Address
                FROM OrgWideEmailAddress
                WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com'
                limit 1
            ][0].id);
            
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
                    });
            
        } catch (Exception ex) {
            
        }
    }
    
    /* @Author ADMD Team
* @date 07/23/2012
* @description generateEmailContent  - Method generates Email Content according to choosen options
*/
    public void generateEmailContent() {
        
        String selectedTemplateLabel = getSelectedTemplateLabel(this.lETs, this.selectedET);
        List<gFRS_Tasks__c> tsklist = [Select Id, name FROM gFRS_Tasks__c WHERE gFRS_Funding_Request__c = :this.fundReq.Id AND Action_Type__c = 'Status Report'];
        
        System.debug('@@@ isOwnerAEDiffernt'+ isOwnerAEDiffernt);
        
        // JIRA -159 Payment method Template changes : To hide CC field 
        
        if (selectedTemplateLabel != null && (selectedTemplateLabel == 'Extend Payment Method Due Date' || selectedTemplateLabel == 'Do Not Extend Payment Method Due Date' || selectedTemplateLabel == 'Payment Method Communication')) {
            isCCHide=false;
            this.fundReq.Communication_CC__c=null;
            if(rfiOtherUserId!=null){
                rfiOtherUserId=null;
            }
            if(isOwnerAEDifferntchk1!=null&&isOwnerAEDifferntchk2!=null){
                isOwnerAEDifferntchk1=null;
                isOwnerAEDifferntchk2=null;
            }
        } else {
            isCCHide=true;
        }
        
        // Ending -- JIRA -159  
        
        if (selectedTemplateLabel != null && (selectedTemplateLabel == 'LOA Reminder Communication' || selectedTemplateLabel == 'Extend Payment Method Due Date' || selectedTemplateLabel == 'Do Not Extend Payment Method Due Date')) {
            
            isAuthorizedSignerSelected = true;
            showAuthorizedSigner = true;
        } else {
            
            isAuthorizedSignerSelected = false;
            showAuthorizedSigner = false;
            
        }
        if (selectedTemplateLabel != null && (selectedTemplateLabel == 'Extend Payment Method Due Date' || selectedTemplateLabel == 'Do Not Extend Payment Method Due Date')) {
            mailToAuthSignerOnly = true;
            isOwnerAEDiffernt=false;
        } else {
            mailToAuthSignerOnly = false;
            if(this.fundReq.Accountable_Employee_Approval__c!=null){
                if(this.fundReq.Ownerid==this.fundReq.Accountable_Employee_Approval__c){
                    isOwnerAESame=true;
                    isOwnerAEDiffernt=false;
                }
                else{
                    isOwnerAEDiffernt=true;
                    isOwnerAESame=false;
                }
            }
            else{
                isOwnerAESame=true;
            }
        }
        if (selectedTemplateLabel != null && selectedTemplateLabel == 'Re-open Program Status Task') {
            mailToOwnerOnly = true;
        } else {
            mailToOwnerOnly = false;
        } 
        
        if (selectedTemplateLabel != null && selectedTemplateLabel == 'LOA Reminder Communication' ) {
            isLOAEmail = true;
        } else {
            isLOAEmail = false;
        } 
        
        if (selectedTemplateLabel != 'NONE' && selectedTemplateLabel != '') {
            
            this.disButton = false;
            
            if (selectedTemplateLabel != null && (selectedTemplateLabel.contains('RFI') || selectedTemplateLabel.contains('Program')) && selectedTemplateLabel != 'Re-open Program Status Task') {
                isRFIdisabled = false;
            } else {
                isRFIdisabled = true;
            }
            try {
                EmailTemplate selectedEmailTemlate = mEtId2Body.get(this.selectedET);
                if (selectedEmailTemlate != null) {
                    this.etBody = selectedEmailTemlate.Body;
                    this.subjectContent = replaceEmailSubject(selectedEmailTemlate.Subject);
                    this.etBody = replaceEmailBody(selectedEmailTemlate.Body, this.recipient);
                }
            } catch (Exception ex) {
                this.etBody = ' ';
                this.disButton = true;
                this.isRFIdisabled = true;
            }
            
            
        } else {
            this.etBody = '';
            this.isRFIdisabled = true;
            this.disButton = true;
        }
        if(selectedTemplateLabel == 'Extend Payment Method Due Date' && this.fundReq.Status__c != 'HC Compliance'){
            this.disButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This action is only permitted in sub-status New or QCO review'));
        }
        if(selectedTemplateLabel == 'Re-open Program Status Task' && tsklist.size() > 0){
            this.disButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This action is only permitted when there is no open Status Updates task.'));
        } else if(selectedTemplateLabel == 'Re-open Program Status Task' && fundReq.StatusUpdate_Communication_Sent__c == true){
            this.disButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This action is permitted only once.'));
        }       
        
        if (selectedTemplateLabel != null && selectedTemplateLabel.contains('RFI') && fundReq.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME && fundReq.Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_NEW){
            this.disButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This is a Philanthropic request and FPO review is not required.'));
        }
        
        if(fundReq.LOA_Signed__c == 'Yes' && selectedTemplateLabel != null && (selectedTemplateLabel.contains('RFI') || selectedTemplateLabel == 'LOA Reminder Communication' || selectedTemplateLabel == 'Payment Method Communication')){
            Boolean isPaymentProcessed = False;
            List <GFRS_Payment_History__c> paymentHistoryList = [select SAP_Doc_ID__c, Grant__c from GFRS_Payment_History__c where 
                                                                 Grant__c = :this.fundReq.Id AND SAP_Doc_ID__c != null];
            isPaymentProcessed = (paymentHistoryList.size() > 0) ? True : False;
            if(isPaymentProcessed){
                this.disButton = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This action is only permitted when there is no history of Payment.')); 
            }
            
        }
    }
    
    
    /**
* @Author ADMD Team
* @date 20/01/2014
* @description dateToString method - Converts a null to a blank string for replacement.
*/
    private String checkNull(String v) {
        return(v == null || v == 'null' ? '' : v);
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description sendEmail method - Method for email sending.
*/
    public ApexPages.PageReference sendEmail() {
        //method for email sending
        
        User ccUser;
        String ccProName;
        
        if(this.fundReq.Communication_CC__c !=null)
        {
            ccUser = [SELECT id, Profile.Name, Profile.Id FROM User WHERE ID=:this.fundReq.Communication_CC__c];
            ccProName= ccUser.Profile.Name;
        }
        
        
        if(ccProName=='GNE-GFRS-Backoffice'){
            ApexPages.addMessage( new ApexPages.Message( Apexpages.Severity.ERROR, System.Label.gFRS_BO_Communication_Error));
            return( null );
        }
        
        System.debug('@@ isOwnerAEDifferntchk1 '+isOwnerAEDifferntchk1);
        System.debug('@@ isOwnerAEDifferntchk2  '+isOwnerAEDifferntchk2);
        if( isOwnerAEDifferntchk1 == false && isOwnerAEDifferntchk2 == false && isLOAEmail==false){
            ApexPages.addMessage( new ApexPages.Message( Apexpages.Severity.ERROR, System.Label.gFRS_TO_Communication_Error));
            return( null );
        }
        
        
        String[] toAddresses = new String[]{
        };
            String ccEmailAddresses;
        
        //isOwnerAEDifferntchk2 -- Owner Check
        //isOwnerAEDifferntchk1 -- Accountable Employee Check
        
        if(fundReq.Owner.Email != null && isOwnerAEDifferntchk2 == true){
            toAddresses.add(fundReq.Owner.Email);
        }
        
        System.debug('@@@ isOwnerAESame'+isOwnerAESame);
        System.debug('@@ isOwnerAEDifferntchk2  '+isOwnerAEDifferntchk2);
        
        if( isOwnerAESame==true && fundReq.Owner.Email != null && isOwnerAEDifferntchk2 == false  ){
            toAddresses.add(fundReq.Owner.Email);
        }
        
        if(fundReq.Accountable_Employee_Approval__r.Email != null && isOwnerAEDifferntchk1 == true){
            toAddresses.add(fundReq.Accountable_Employee_Approval__r.Email);
        }
        
        if (fundReq.Owner.Email != null && mailToAuthSignerOnly == false && isOwnerAESame==true) {
            toAddresses.add(fundReq.Owner.Email);
        }
        if (isAuthorizedSignerSelected && fundReq.Signing_Authority_Email__c != null && mailToOwnerOnly == false) {
            if (!checkIfStringIsInList(toAddresses, fundReq.Signing_Authority_Email__c)) {
                toAddresses.add(fundReq.Signing_Authority_Email__c);
            }
        }
        if (isAccountableEmploySelected != null && isAccountableEmploySelected && fundReq.Accountable_Employee_Approval__c != null && fundReq.Accountable_Employee_Approval__r.Email != null && mailToAuthSignerOnly == false && mailToOwnerOnly == false) {
            if (!checkIfStringIsInList(toAddresses, fundReq.Accountable_Employee_Approval__r.Email)) {
                toAddresses.add(fundReq.Accountable_Employee_Approval__r.Email);
            } 
            
        } 
        
        if(rfiOtherUserId!=null){
            
            User usr=[Select id,Email from User Where Id=:rfiOtherUserId];
            ccEmailAddresses=usr.Email;
            
        }
        
        
        //String[] ccAddresses = new String[]{};
        
        /* temporary email address */
        String selectedTemplate = '';
        for (SelectOption item : this.lETs) {
            if (item.getValue() == this.selectedET) {
                
                selectedTemplate = item.getLabel();
            }
        }
        
        if ((selectedTemplate == 'RFI - Information Request Internal' || selectedTemplate == 'RFI - Information Request External' || selectedTemplate == 'Program Denial Communication' || selectedTemplate == 'Program Cancelation Communication') && fundReq.Information_Needed__c == null) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_CommunicationErrorEmptyInfoNeeded));
            return null;
        }
        if(String.isNotBlank(string.valueOf(dueDate))){
            if (selectedTemplate == 'Extend Payment Method Due Date' && (fundReq.Payment_Method_Due_Date__c <= dueDate || fundReq.Payment_Method_Due_Date__c <= date.today() || fundReq.Payment_Method_Due_Date__c == null)) {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Extended Payment Method Task Due On should be greater than today/current due date'));
                return null;
            }
        }else{
            if (selectedTemplate == 'Extend Payment Method Due Date' && (fundReq.Payment_Method_Due_Date__c <= date.today() || fundReq.Payment_Method_Due_Date__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Extended Payment Method Task Due On should be greater than today'));
                return null;
            }
        }
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            
            if (ccEmailAddresses != null) {
                mail.SetccAddresses(new String[]{ccEmailAddresses});
            }
            
            if (bccEmailAddress != null) {
                mail.setBccAddresses(new List<String>{
                    bccEmailAddress
                        });
            }
            
            mail.setSubject(this.subjectContent);
            if (this.subjectContent == null || this.subjectContent == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptySubject));
                return null;
            }
            if (this.etBody == null || this.etBody == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptyContent));
                return null;
            }
            
            
            etBody += '\n\n' + '[ref:' + fundReq.id + ']';
            mail.setPlainTextBody(etBody);
            
            //Cancel Post Funding email should be sent from following address: fundingrequestsystem-donotreply-d@gene.com
            if (selectedTemplate == 'Canceled Post Funding Communication' || selectedTemplate == 'Extend Payment Method Due Date' || selectedTemplate == 'Do Not Extend Payment Method Due Date' || selectedTemplate == 'Re-open Program Status Task') {
                mail.setOrgWideEmailAddressId([
                    SELECT Id, Address
                    FROM OrgWideEmailAddress
                    WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com'
                    limit 1
                ][0].id);
            }
            //for rest communication email notification is sent from current user context
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
                    });
            
            try {
                
                if (selectedTemplate == 'RFI - Information Request Internal' || selectedTemplate == 'RFI - Information Request External' || selectedTemplate == 'Program Denial Communication' || selectedTemplate == 'Program Cancelation Communication' || selectedTemplate == 'Payment Method Communication') {
                    
                    if(selectedTemplate == 'Payment Method Communication'){
                        fundReq.Partner_Bank_Type__c = '';
                        fundReq.ACH_Received__c      = '';
                        fundReq.Information_Needed__c = 'Payment Method';
                    }
                    fundReq.Sub_Status__c = gFRS_Util.REQUEST_STATUS_RFI;
                    fundReq.External_Sub_status__c = gFRS_Util.REQUEST_STATUS_RFI;
                    
                    
                    //System.debug( 'newRequest:' + fundReq + ', newStatus:' + fundReq.Sub_Status__c + ', external:' + fundReq.External_Sub_status__c );
                    
                    
                } else if (selectedTemplate == 'Re-open Program Status Task') {
                    
                    String RfiLink  = '/apex/GFRS_Status_Report?id=' + fundReq.Id;
                    Id currentUser = UserInfo.getUserId();
                    date dt = date.today();
                    date dt1 = dt.adddays(14);
                    gFRS_Tasks__c task = new gFRS_Tasks__c( 
                        Status__c               = 'Not Submitted',
                        Subject__c              = 'Status Report Required',
                        RFI_Link__c             = RfiLink,
                        Description__c          = 'Please provide monthly Status Report/Scope Changes for Funding Request: ' + fundReq.Name,
                        gFRS_Funding_Request__c = fundReq.id,
                        User__c                 = currentUser,
                        Action_Type__c          = 'Status Report' 
                    );
                    gFRS_Util_NoShare.saveLockedTask(task);
                    
                    fundReq.Program_Status_Task_Override_By__c = '';
                    fundReq.Program_Status_Task_Expiration_Date__c = dt1;
                    fundReq.StatusUpdate_Communication_Sent__c = true;
                    fundReq.Status_Updates_Submitted__c = 'No';                    
                    
                    list<GFRS_Program__c> progs = new list<GFRS_Program__c>();
                    progs = [SELECT Id, name, Did_you_exhibit_sponsor_at_the_event__c,Why_didnt_you_exhibit_at_the_event__c,Unable_to_Exhibit_Event_Other__c FROM GFRS_Program__c WHERE Funding_Request__c =:fundReq.Id];
                    
                    for(GFRS_Program__c prg : progs){
                        prg.Did_you_exhibit_sponsor_at_the_event__c = '';
                        prg.Why_didnt_you_exhibit_at_the_event__c   = '';                        
                        prg.Unable_to_Exhibit_Event_Other__c        = '';
                    }
                    gFRS_Util_NoShare.savePrograms(progs);
                    
                } else if (selectedTemplate == 'Reconciliation Request Communication') {
                    
                    fundReq.Status__c = 'Processing & Disposition';
                    fundReq.Sub_Status__c = 'Reconciliation Required';
                    fundReq.External_Sub_status__c = 'Reconciliation Required';
                    fundReq.Reconciliation_Completed__c = 'No';
                    fundReq.Is_Reconciliation_In_RFI__c = true;
                    
                } else if (selectedTemplate == 'Canceled Post Funding Communication') {
                    
                    fundReq.Status__c = 'Processing & Disposition';
                    fundReq.Sub_Status__c = 'Reconciliation Required';
                    fundReq.External_Sub_status__c = 'Reconciliation Required';
                    fundReq.Reconciliation_Completed__c = 'No';
                    fundReq.Is_Reconciliation_In_RFI__c = true;
                    
                } else if (selectedTemplate == 'Outcomes Request Communication') {
                    fundReq.Is_Outcomes_In_RFI__c = true;
                    
                } else if (selectedTemplate == 'Extend Payment Method Due Date') {
                    gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(this.fundReq);
                    List<gFRS_Tasks__c> FRT = [SELECT Id, Name FROM gFRS_Tasks__c WHERE Action_Type__c = 'ACH' AND gFRS_Funding_Request__c = : fundReq.Id ];
                    if(FRT.size() > 0){
                        //no action required
                    }
                    else{
                        String RfiLink  = '/apex/gFRS_ACHData?id=' + fundReq.Location__c + '&fundingreq=' + fundReq.id;
                        Id currentUser = UserInfo.getUserId();
                        gFRS_Tasks__c task = new gFRS_Tasks__c( 
                            Status__c               = 'Open',
                            Subject__c              = 'ACH Required',
                            RFI_Link__c             = RfiLink,
                            Description__c          = 'If approved, select the payment method via which you would prefer to receive the funds',
                            gFRS_Funding_Request__c = fundReq.id,
                            User__c                 = currentUser,
                            Action_Type__c          = 'ACH' 
                        );
                        gFRS_Util_NoShare.saveLockedTask(task);
                        this.fundReq.ACH_Task_Open__c = 'Yes';
                        this.fundReq.ACH_Override_by__c = null;
                        this.fundReq.Overriden_On__c = null;
                        this.fundReq.Overriding_reason__c = '';
                        this.fundReq.ACH_Received__c = '';
                        this.fundReq.Partner_Bank_Type__c = '';                        
                        gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(this.fundReq);
                    }
                } else if (selectedTemplate == 'Evaluation Reminder Communication') {
                    fundReq.Status__c = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
                    fundReq.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                    fundReq.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                    fundReq.Evaluation_Completed__c = 'No';
                    
                } else if (selectedTemplate == gFRS_Util.SUNSHINE_ACT_DISCLOSURE_REQUEST_COMMUNICATION_NAME) {
                    fundReq.Sunshine_Act_Disclosure_Submitted__c = gFRS_Util.NO;
                    fundReq.Sunshine_Communication_Sent__c = true;
                    fundReq.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE;
                    fundReq.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE;
                    fundReq.Status__c = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
                }
                
                if ((this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME
                     || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME)
                    && (this.fundReq.Information_Needed__c != null
                        && this.fundReq.Information_Needed__c.contains('Application')
                        && !this.fundReq.Information_Needed__c.contains('Third Party'))) {
                            
                            this.fundReq.Information_Needed__c += ';Third Party';
                        }
                
                gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(this.fundReq);
                
            } catch (Exception err) {
                System.debug('err:' + err.getMessage());
            }
            
            //hideRFI_Popup();
            
            //-- return to the current page to ensure the information is updated and refreshed
            return(new ApexPages.PageReference('/' + this.fundReq.id));
        } catch (Exception err) {
            System.debug('ERROR OCURRED:' + err.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
        }
        
        return(null);
    }
    
    /** 
* @Author ADMD Team
* @date 06/05/2014
* @description checkIfStringIsInList method check if string is in list
* 
*/
    public Boolean checkIfStringIsInList(List<String> lOfStrings, String stringToFind) {
        for (String s : lOfStrings) {
            if (s == stringToFind) {
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
    public String replaceEmailSubject(String emailSub) {
        if (emailSub != null) {
            String paymentDate = fundReq.Payment_Method_Due_Date__c == null ? '' : fundReq.Payment_Method_Due_Date__c.format();
            emailSub = emailSub.replace('<<Payment Method Submission Date>>', paymentDate);        
            emailSub = emailSub.replace('{!GFRS_Funding_Request__c.Name}', this.fundReq.Name);
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
    public String replaceEmailBody(String emailBody, User recipient) {
        
        String outputBody = '';
        
        if (emailBody != null) {
            outputBody = emailBody.replace('<<G-#####>>', this.fundReq.Name).replace('<<Program/Event Title>>', checkNull(this.fundReq.Event_Program_Title__c));
            String senderName = checkNull(Userinfo.getFirstName()) + ' ' + checkNull(Userinfo.getLastName());
            outputBody = outputBody.replace('<<Sender First Name Last Name>>', senderName);
            outputBody = outputBody.replace('{!GFRS_Funding_Request__c.Name}', fundReq.name);
            outputBody = outputBody.replace('{!GFRS_Funding_Request__c.Event_Program_Title__c}', fundReq.Event_Program_Title__c);
            outputBody = outputBody.replace('{!GFRS_Funding_Request__c.OwnerFullName}', fundReq.Owner.Name);
            String recipientName = '';
            
            if (showAuthorizedSigner) {
                //flag showAuthorizedSigner is true only for LOA reminder recipiet shuld be always Authorized Signer
                recipientName = checkNull(fundReq.Signing_Authority_First_Name__c) + ' ' + checkNull(fundReq.Signing_Authority_Last_Name__c);
            } else {
                //recipient will be always owner of requesx
                recipientName = checkNull(recipient.FirstName) + ' ' + checkNull(recipient.LastName);
            }
            outputBody = outputBody.replace('<<First Name Last Name>>', recipientName);
            
            String authorizedSingnerName = checkNull(fundReq.Signing_Authority_First_Name__c) + ' ' + checkNull(fundReq.Signing_Authority_Last_Name__c);
            outputBody = outputBody.replace('<<Authorized Signer>>', authorizedSingnerName);
            outputBody = outputBody.replace('<<Authorized Signer Email>>', checkNull(fundReq.Signing_Authority_Email__c));
            
            String programStartDateMin = fundReq.Program_Start_Date_Min__c == null ? '' : fundReq.Program_Start_Date_Min__c.format();
            outputBody = outputBody.replace('<<First Program Start Date>>', programStartDateMin);
            
            String programEndDateMax = fundReq.Program_End_Date_max__c == null ? '' : fundReq.Program_End_Date_max__c.format();
            outputBody = outputBody.replace('<<Last Program End Date>>', programEndDateMax);
            
            //Disease State
            String diseaseState = checkNull(fundReq.Therapeutic_Area__c);
            outputBody = outputBody.replace('<<Disease State>>', diseaseState);
            
            
            //ModifiedBy
            String modifUser = checkNull(fundReq.LastModifiedBy.Name);
            outputBody = outputBody.replace('<<LastModifyBy>>', modifUser);
            
            String lastLiveProgramEndDate = fundReq.Last_Live_Program_End_Date__c == null ? '' : fundReq.Last_Live_Program_End_Date__c.format();
            outputBody = outputBody.replace('<<Last Live Program End Date>>', lastLiveProgramEndDate);
            String paymentDate = fundReq.Payment_Method_Due_Date__c == null ? '' : fundReq.Payment_Method_Due_Date__c.format();
            outputBody = outputBody.replace('<<Payment Method Submission Date>>', paymentDate);
            if(outputBody.contains('<<Extension Declined>>')){
                outputBody = gFRS_Util_NoShare.replaceEmailBody(outputBody, fundReq);
            }
            
            // GFRS-964
            outputBody = outputBody.replace('{!$Label.gFRS_ComplianceTeamEmail}', System.Label.gFRS_ComplianceTeamEmail);
            outputBody = outputBody.replace('{!$Label.gFRS_ComplianceTeamPhone}', System.Label.gFRS_ComplianceTeamPhone);
            outputBody = outputBody.replace('{!$Label.gFRS_ComplianceTeamFullName}', System.Label.gFRS_ComplianceTeamFullName);
            outputBody = outputBody.replace('{!$Label.gFRS_ComplianceTeamShortName}', System.Label.gFRS_ComplianceTeamShortName);
        }
        
        return outputBody;
    }
    
    
    /**
* @Author ADMD Team
* @date 20/01/2014
* @description managePDF method - create appropriate attachments and relate them with FUnding Request.
* SFDC-1710 method which adding LOA PDF attachment or Compliance documents
*/
    public ApexPages.PageReference managePDF() {
        
        Savepoint sp = null;
        
        if (this.fundReq.LOA_Signed__c == 'Yes' && this.fundReq.LOA_PDF__c == null) {
            Attachment LoaDocument = null;
            List<Attachment> tmpAtachmentLi = [
                SELECT Id, Name, body, Parent.Id
                FROM Attachment
                WHERE Name = 'LOADocument.pdf'
                AND Parent.Id = :this.fundReq.Id
            ];
            try {
                if (tmpAtachmentLi == null || tmpAtachmentLi.size() < 1) {
                    PageReference pageRefPdf = null;
                    if (this.fundReq.Record_Type_Name__c == 'Field Initiated Exhibits') {
                        pageRefPdf = new ApexPages.Pagereference(Page.GFRS_LOA_PDF_FieldExhibits.getURL());
                        pageRefPdf.getParameters().put('id', fundReq.id);
                    } else {
                        pageRefPdf = new ApexPages.Pagereference(Page.gFRS_LOA_PDF.getURL());
                        pageRefPdf.getParameters().put('id', fundReq.id);
                    }
                    pageRefPdf.setRedirect(true);
                    gFRS_Util_NoShare.insertLOAattachment('LOADocument.pdf', pageRefPdf.getContent(), this.fundReq);
                }
            } catch (Exception ex) {
                system.debug('get exception form method managePDF' + ex.getMessage());
            }
        }
        
        try {
            Date decisionDate = date.parse(System.Label.gFRS_Compliance_Flag_Snapshot_Start_Date);
            
            GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
            Date hcComplianceFlagsStartDate = myOrgCS.gFRS_HC_Compliance_Flag_Start_Date__c;
            
            if (this.fundReq.Decision_Date__c != null
                && this.fundReq.Decision_Date__c >= decisionDate
                && this.fundReq.Compliance_flags_PDF__c == null
                && this.fundReq.Foundation_Classified__c == 'FALSE') {
                    
                    try {
                        PageReference pageRefPdf = null;
                        pageRefPdf = new ApexPages.Pagereference(Page.gFRS_ComplianceCheckFlagPDF.getURL());
                        pageRefPdf.getParameters().put('id', fundReq.id);
                        pageRefPdf.setRedirect(true);
                        String documentName = 'Decision_Flags_' + this.fundReq.Name + '.pdf';
                        sp = Database.setSavepoint();
                        
                        gFRS_Util_NoShare.insertComplianceAttachment(documentName, pageRefPdf.getContent(), this.fundReq);
                        
                    } catch (Exception ex) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.gFRS_UnableToCreateDecisionFLagsPDF));
                        System.debug(System.Label.gFRS_UnableToCreateDecisionFLagsPDF);
                        Database.rollback(sp);
                    }
                } else if (this.fundReq.Decision_Date__c == null && this.fundReq.Compliance_flags_PDF__c != null) {
                    
                    List<Attachment> tmpAtachmentLi = [
                        SELECT Id, Parent.Id
                        FROM Attachment
                        WHERE Id = :this.fundReq.Compliance_flags_PDF__c
                    ];
                    if (tmpAtachmentLi.size() > 0) {
                        gFRS_Util_NoShare.deleteLockedAttachments(tmpAtachmentLi);
                    }
                    this.fundReq.Compliance_flags_PDF__c = null;
                    update this.fundReq;
                }
            
            
            if (this.fundReq.HC_Compliance_Date__c >= hcComplianceFlagsStartDate && this.fundReq.HC_Compliance_Date__c != null && this.fundReq.HC_Compliance_Flags_PDF__c == null && this.fundReq.Foundation_Classified__c == 'FALSE') {
                try {
                    PageReference pageRefPdf = null;
                    pageRefPdf = new ApexPages.Pagereference(Page.gFRS_ComplianceCheckFlagPDF.getURL());
                    pageRefPdf.getParameters().put('id', fundReq.id);
                    pageRefPdf.setRedirect(true);
                    
                    String documentName = 'HC_Compliance_Flags_' + this.fundReq.Name + '.pdf';
                    sp = Database.setSavepoint();
                    gFRS_Util_NoShare.insertFundingRequestAttachment('HC_Compliance_Flags_PDF__c', documentName, pageRefPdf.getContent(), this.fundReq);
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.gFRS_UnableToCreateHcComplianceFLagsPDF));
                    System.debug(System.Label.gFRS_UnableToCreateHcComplianceFLagsPDF);
                    Database.rollback(sp);
                }
                
                
            } else if (this.fundReq.HC_Compliance_Date__c == null && this.fundReq.HC_Compliance_Flags_PDF__c != null) {
                
                List<Attachment> tempAttachmentList = [
                    SELECT Id
                    FROM Attachment
                    WHERE Id = :this.fundReq.HC_Compliance_Flags_PDF__c
                ];
                if (tempAttachmentList.size() > 0) {
                    gFRS_Util_NoShare.deleteLockedAttachments(tempAttachmentList) ;
                }
                
                this.fundReq.HC_Compliance_Flags_PDF__c = null;
                update this.fundReq;
            }
            
            /**
* Author : gFRS CoPay Team
* Date : 02/06/2018
* Description : Estimated Current Revenue Percent is also to be calculated on page load
* */
            Set<String> allFundingTypes = new Set<String>{
                'Health Care-Related Charitable', 'Fellowships', 'Scientific Project Support'
                    };
                        if (allFundingTypes.contains(fundReq.Funding_Type__c) && fundReq.Foundation_Classified__c == 'FALSE') {
                            fundReq.Estimated_Current_Revenue_Percent__c = gFRS_CoPay_Operational_Budget.getFiscalRevenuePercent(fundReq);
                            update this.fundReq;
                        }
            
            
        } catch (Exception ex) {
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
    private boolean checkIfUserCanCrateAnotherFundingAllocation() {
        Boolean bRetVal = false;
        Integer intCounter = 0;
        
        intCounter = [
            SELECT Id
            FROM GFRS_Funding_Allocation__c
            WHERE RecordType.Name != 'Refund'
            AND Grant_Request__c = :fundReq.Id
        ].Size();
        
        if (intCounter == 0)bRetVal = true;
        
        return bRetVal;
    }
    
    
    
    private boolean checkIfUserBackOfficeProfile() {
        Boolean bRetVal = false;
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        if(userProfile.Name=='GNE-GFRS-Backoffice'){
            bRetVal=true;
        }
        else
        {
            bRetVal=false; 
        }
        
        return bRetVal;
    }
    
    /** 
* @Author ADMD Team
* @date 08/03/2013
* @description Creates a new payment funding allocation record. Used by button New Payment Allocation.
* 
*/
    public ApexPages.PageReference createNewPaymentAllocation() {
        
        try {
            Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
            if(userProfile.Name=='GNE-GFRS-Backoffice'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Insufficient Privileges'));
                return(null);
                
            }
            RecordType rt = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Payment'
                AND SobjectType = 'GFRS_Funding_Allocation__c'
                limit 1
            ];
            
            GFRS_Funding_Allocation__c paymentFA = new GFRS_Funding_Allocation__c(Grant_Request__c = fundReq.Id, Fiscal_Year__c = String.valueOf(date.today().year()), RecordTypeId = rt.id);
            
            insert paymentFA;
            return(new ApexPages.PageReference('/apex/GFRS_FundingAllocationRead?id=' + paymentFA.id).setRedirect(true));
            
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex)));
            return null;
        }
    }
    
    /** 
* @Author ADMD Team
* @date 08/03/2013
* @description Creates a new refund funding allocation record. Used by button New Refund Allocation.
* 
*/
    public ApexPages.PageReference createNewRefundAllocation() {
        
        try {
            
            Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
            if(userProfile.Name=='GNE-GFRS-Backoffice'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Insufficient Privileges'));
                return(null);
                
            }
            Set<String> affectedFundingTypes = new Set<String>{
                gFRS_Util.TYPE_PHILANTHROPIC_NAME,
                    gFRS_Util.TYPE_HC_CHAR_NAME,
                    gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME,
                    gFRS_Util.TYPE_FELLOWSHIPS_NAME
                    };
                        
                        if (!checkIfRefundCanBeCreated(fundReq)) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_ERROR_REFDUE_GRT_THAN_250));
                            return null;
                        }
            
            RecordType rt = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Refund'
                AND SobjectType = 'GFRS_Funding_Allocation__c'
                limit 1
            ];
            
            GFRS_Funding_Allocation__c paymentFA = new GFRS_Funding_Allocation__c(Grant_Request__c = fundReq.Id, Fiscal_Year__c = String.valueOf(date.today().year()), RecordTypeId = rt.id);
            insert paymentFA;
            
            return(new ApexPages.PageReference('/apex/GFRS_FundingAllocationRead?id=' + paymentFA.id).setRedirect(true));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex)));
            return null;
        }
    }
    
    private Boolean checkIfRefundCanBeCreated(GFRS_Funding_Request__c request) {
        return request.Refund_Due__c > 250 ? true : false;
    }
    
    private List<GFRS_Funding_Allocation__c> getAllocationsForRequest(GFRS_Funding_Request__c request) {
        return [SELECT Id, Grant_Request__c, Refund_Due__c FROM GFRS_Funding_Allocation__c WHERE Grant_Request__c = :request.Id];
    }
    
    /** 
* @Author ADMD Team
* @date 02/19/2013
* @description refresh page.
* 
*/
    public ApexPages.PageReference refreshCloseFundingForm() {
        if (fundReq.Foundation_Classified__c == 'TRUE') {
            fundReq.Decision_Reasons__c = selectedDecisionReason;
        }
        
        if (mappingForCorrespondingEmailTemplateAndDecisonReason == null) {
            
            //Keeping mapping Decision Reason => Proper Email Template 
            //Templates for Foundation funding type should contain Foundation word 
            //All Emails template are keeped in following folder:gFRS Close Request Templates
            mappingForCorrespondingEmailTemplateAndDecisonReason = new Map < String, List < String >> {
                'CCO Compliance Denial' => new List < String > {
                    'CCO_Compliance_Denial_External',
                        'CCO_Compliance_Denial_Internal'
                        },
                            'Compliance Denial' => new List < String > {
                                'Compliance_Denial_IMED',
                                    'Compliance_Denial_CAPP',
                                    'Foundation_Denied_Decision_Reasons_Compliance_Denial'
                                    },
                                        'Limited Funding Availability' => new List < String > {
                                            'Limited_Funding_Availability',
                                                'Limited_Funding_Availability_CAPP',
                                                'Limited_Funding_Availability_HCchar',
                                                'Foundation_Denied_Decision_Reasons_Limited_Funding_Availability'
                                                },
                                                    'Low Priority' => new List < String > {
                                                        'IMED_Low_Priority',
                                                            'CAPP_Low_Priority'
                                                            },
                                                                'No Funding Available' => new List < String > {
                                                                    'IMED_No_Funding_Available',
                                                                        'Fellowship_Scientific_No_Funding_Available'
                                                                        },
                                                                            'Outside Therapeutic Area of Interest' => new List < String > {
                                                                                'IMED_Outside_Therapeutic_Area_of_Interest',
                                                                                    'CAPP_Outside_Therapeutic_Area_of_Interest'
                                                                                    },
                                                                                        'Philanthropic Request Decline' => new List < String > {
                                                                                            'Philanthropic_Request_Decline'
                                                                                                },
                                                                                                    'Unaligned to our Educational Objectives' => new List < String > {
                                                                                                        'Unaligned_to_our_Educational_Objectives'
                                                                                                            },
                                                                                                                'Denied by Business/Financial Approver' => new List < String > {
                                                                                                                    'Denied_by_Business_Financial_Approver_Internal'
                                                                                                                        },
                                                                                                                            'Denied by Legal Approver' => new List < String > {
                                                                                                                                'Denied_by_Legal_Approver_Internal'
                                                                                                                                    },
                                                                                                                                        'Canceled at the Request of Applicant' => new List < String > {
                                                                                                                                            'Canceled_at_the_Request_of_Applicant',
                                                                                                                                                'Canceled_at_the_Request_of_Applicant_Internal',
                                                                                                                                                'Foundation_Canceled_Decision_Reasons_Canceled_at_the_Request_of_Applicant'
                                                                                                                                                },
                                                                                                                                                    'Canceled Post Funding' => new List < String > {
                                                                                                                                                        'Canceled_Post_Funding_IMED',
                                                                                                                                                            'Canceled_Post_Funding_CAPP',
                                                                                                                                                            'Canceled_Post_Funding_Internal'
                                                                                                                                                            },
                                                                                                                                                                'Cannot Agree to LOA Terms' => new List < String > {
                                                                                                                                                                    'Cannot_Agree_to_LOA_Terms',
                                                                                                                                                                        'Cannot_Agree_to_LOA_Terms_Internal',
                                                                                                                                                                        'Foundation_Canceled_Decision_Reasons_Cannot_Agree_to_LOA_Terms'
                                                                                                                                                                        },
                                                                                                                                                                            'Did Not Receive Response to RFI(s)' => new List < String > {
                                                                                                                                                                                'Did_Not_Receive_Response_to_RFI_s',
                                                                                                                                                                                    'Did_Not_Receive_Response_to_RFI_s_Internal',
                                                                                                                                                                                    'Foundation_Canceled_Decision_Reasons_Did_Not_Receive_Response_to_RFI_s'
                                                                                                                                                                                    },
                                                                                                                                                                                        'Duplicate Request in System' => new List < String > {
                                                                                                                                                                                            'Duplicate_Request_in_System',
                                                                                                                                                                                                'Duplicate_Request_in_System_Internal',
                                                                                                                                                                                                'Foundation_Canceled_Decision_Reasons_Duplicate_Request_in_System'
                                                                                                                                                                                                },
                                                                                                                                                                                                    'Insufficient Lead Time to Review Grant' => new List < String > {
                                                                                                                                                                                                        'Insufficient_Lead_Time_to_Review_Grant',
                                                                                                                                                                                                            'Insufficient_Lead_Time_to_Review_Grant_Internal'
                                                                                                                                                                                                            },
                                                                                                                                                                                                                'Cancel Request' => new List < String > {
                                                                                                                                                                                                                    'Cancel_Request',
                                                                                                                                                                                                                        'Cancel_Request_Internal'
                                                                                                                                                                                                                        },
                                                                                                                                                                                                                            'Out of Scope' => new List < String > {
                                                                                                                                                                                                                                'Foundation_Denied_Decision_Reasons_Out_of_Scope'
                                                                                                                                                                                                                                    },
                                                                                                                                                                                                                                        'Business Reason Denial' => new List < String > {
                                                                                                                                                                                                                                            'Business_Reason_Denial_HC_Char'
                                                                                                                                                                                                                                                },
                                                                                                                                                                                                                                                    'Incorrect Funding Type - Donations to CAF' => new List < String > {
                                                                                                                                                                                                                                                        'Incorrect_funding_type_Non_CoPay'
                                                                                                                                                                                                                                                            },
                                                                                                                                                                                                                                                                'No Interest' => new List < String > {
                                                                                                                                                                                                                                                                    'No_Interest_Philanthropic'
                                                                                                                                                                                                                                                                        }
                
            };
                
                }
        String decisionReasonKey = fundReq.Decision_Reasons__c;
        decisReason = decisionReasonKey;
        
        if (decisionReasonKey != null && mappingForCorrespondingEmailTemplateAndDecisonReason.containsKey(decisionReasonKey)) {
            
            List<String> emailTemplatesNames = mappingForCorrespondingEmailTemplateAndDecisonReason.get(decisionReasonKey);
            
            emailTemplatedForClosingForm = [
                SELECT TemplateType, Subject, Name, DeveloperName, Body,HtmlValue
                FROM EmailTemplate
                WHERE DeveloperName in :emailTemplatesNames
                AND Folder.DeveloperName = :EMAIL_CLOSE_TEMPLATES_FOLDER
                ORDER BY Name ASC
            ];
            
            if (emailTemplatedForClosingForm.size() > 0) {
                if (emailTemplatesNames.size() == 1) {
                    closeFundingEmailBody = replaceEmailBody(emailTemplatedForClosingForm[0].Body, this.recipient) ;
                    closeFundingEmailSubject = replaceEmailSubject(emailTemplatedForClosingForm[0].Subject);
                } else {
                    //Select Foundation template
                    if (fundReq.Foundation_Classified__c == 'TRUE') {
                        for (EmailTemplate et : emailTemplatedForClosingForm) {
                            if (et.DeveloperName.contains('Foundation')) {

                                closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                break;
                            }
                        }
                    } else {
                        
                        
                        if (fundReq.Decision_Reasons__c == 'CCO Compliance Denial') {
                            String emailTemplateToUse = '';
                            if (checkIfRequestIsExternal(fundReq.Record_Type_Name__c)) {
                                
                                emailTemplateToUse = 'CCO_Compliance_Denial_External';
                            } else if (gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)) {
                                
                                emailTemplateToUse = 'CCO_Compliance_Denial_Internal';
                            }
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                        } else if (fundReq.Decision_Reasons__c == 'Compliance Denial') {
                            String emailTemplateToUse = '';
                            if (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) {
                                
                                emailTemplateToUse = 'Compliance_Denial_IMED';
                            } else if (checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)) {
                                
                                emailTemplateToUse = 'Compliance_Denial_CAPP';
                            }
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Limited Funding Availability') {
                            
                            String emailTemplateToUse = '';
                            if (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) {
                                
                                emailTemplateToUse = 'Limited_Funding_Availability';
                            } else if (checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)) {
                                if(fundReq.Record_Type_Name__c == 'HC Char'){
                                    emailTemplateToUse = 'Limited_Funding_Availability_HCchar';
                                }else{
                                    emailTemplateToUse = 'Limited_Funding_Availability_CAPP';
                                }
                                
                                
                            }
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Low Priority') {
                            
                            String emailTemplateToUse = '';
                            if (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) {
                                
                                emailTemplateToUse = 'IMED_Low_Priority';
                            } else if (checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'CAPP_Low_Priority';
                            }
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'No Funding Available') {
                            
                            String emailTemplateToUse = '';
                            if (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) {
                                
                                emailTemplateToUse = 'IMED_No_Funding_Available';
                            } else if (checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)) {
                                
                                emailTemplateToUse = 'Fellowship_Scientific_No_Funding_Available';
                            }
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Outside Therapeutic Area of Interest') {
                            
                            String emailTemplateToUse = '';
                            if (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) {
                                
                                emailTemplateToUse = 'IMED_Outside_Therapeutic_Area_of_Interest';
                            } else if (checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)) {
                                
                                emailTemplateToUse = 'CAPP_Outside_Therapeutic_Area_of_Interest';
                            }
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Canceled at the Request of Applicant') {
                            
                            String emailTemplateToUse = '';
                            if (gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)) {
                                
                                emailTemplateToUse = 'Canceled_at_the_Request_of_Applicant_Internal';
                            } else if (checkIfRequestIsExternal(fundReq.Record_Type_Name__c)) {
                                
                                emailTemplateToUse = 'Canceled_at_the_Request_of_Applicant';
                            }
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Canceled Post Funding') {
                            
                            String emailTemplateToUse = '';
                            if (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) {
                                emailTemplateToUse = 'Canceled_Post_Funding_IMED';
                            } else if (checkIfRequestIsCAPP(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Canceled_Post_Funding_CAPP';
                            } else if (gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Canceled_Post_Funding_Internal';
                            }
                            
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Cannot Agree to LOA Terms') {
                            
                            String emailTemplateToUse = '';
                            if (checkIfRequestIsExternal(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Cannot_Agree_to_LOA_Terms';
                            } else if (gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Cannot_Agree_to_LOA_Terms_Internal';
                            }
                            
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Did Not Receive Response to RFI(s)') {
                            
                            String emailTemplateToUse = '';
                            if (checkIfRequestIsExternal(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Did_Not_Receive_Response_to_RFI_s';
                            } else if (gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Did_Not_Receive_Response_to_RFI_s_Internal';
                            }
                            
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Duplicate Request in System') {
                            
                            String emailTemplateToUse = '';
                            if (checkIfRequestIsExternal(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Duplicate_Request_in_System';
                            } else if (gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Duplicate_Request_in_System_Internal';
                            }
                            
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Insufficient Lead Time to Review Grant') {
                            
                            String emailTemplateToUse = '';
                            if (checkIfRequestIsExternal(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Insufficient_Lead_Time_to_Review_Grant';
                            } else if (gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Insufficient_Lead_Time_to_Review_Grant_Internal';
                            }
                            
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
                                    break;
                                }
                            }
                            
                        } else if (fundReq.Decision_Reasons__c == 'Cancel Request') {
                            
                            String emailTemplateToUse = '';
                            if (checkIfRequestIsExternal(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Cancel_Request';
                            } else if (gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)) {
                                emailTemplateToUse = 'Cancel_Request_Internal';
                            }
                            
                            for (EmailTemplate et : emailTemplatedForClosingForm) {
                                if (et.DeveloperName == emailTemplateToUse) {
                                    closeFundingEmailBody = replaceEmailBody(et.Body, this.recipient) ;
                                    closeFundingEmailSubject = replaceEmailSubject(et.Subject);
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
    
    public ApexPages.PageReference resetForm() {
        
        fundReq.External_Sub_status__c = fundReq.Sub_Status__c;
        fundReq.Decision_Reasons__c = null;
        populateDecisionReasonForFoundation();
        return null;
    }
    
    public Boolean checkIfRequestIsCAPP(String recordType) {
        if (recordType == gFRS_Util.TYPE_FELLOWSHIPS_NAME
            || recordType == gFRS_Util.TYPE_HC_CHAR_NAME
            || recordType == gFRS_Util.TYPE_PHILANTHROPIC_NAME
            || recordType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME) {
                return true;
            }
        
        return false;
    }
    
    public Boolean checkIfRequestIsExternal(String recordType) {
        if (recordType == gFRS_Util.TYPE_FELLOWSHIPS_NAME
            || recordType == gFRS_Util.TYPE_HC_CHAR_NAME
            || recordType == gFRS_Util.TYPE_PHILANTHROPIC_NAME
            || recordType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME
            || recordType == gFRS_Util.TYPE_IMED_NAME) {
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
    public String getSelectedTemplateLabel(List<Selectoption> emailTemplateList, String idOfSelectedTemplate) {
        try {
            for (SelectOption option : emailTemplateList) {
                if (option.getValue() == idOfSelectedTemplate) {
                    return option.getLabel();
                }
            }
        } catch (Exception ex) {
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
    
    public void removeEditSharingForFA1AfterApproveReject() {
        if (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME &&
            fundReq.Financial_Approver_1__c == UserInfo.getUserId() &&
            fundReq.Financial_Approver_1_Decision_Date__c != null
           ) {
               final GFRS_Funding_Request__Share[] shares = [
                   SELECT ParentId
                   FROM GFRS_Funding_Request__Share
                   WHERE UserOrGroupId = :UserInfo.getUserId()
                   AND ParentId = :fundReq.Id
                   AND AccessLevel != 'Read'
                   AND RowCause = 'Manual'
               ];
               for (GFRS_Funding_Request__Share share : shares) {
                   share.AccessLevel = 'Read'; // revoke write access
               }
               try {
                   gFRS_Util_NoShare.upsertRequestShares(shares, new Map<Id, GFRS_Funding_Request__c>{
                       fundReq.Id => fundReq
                           });
               } catch (Exception e) {
                   ApexPages.addMessages(e);
               }
           }
    }
    
    /** 
* @Author ADMD Team
* @date 20/01/2014
* @description dateToString method - Converts a date to a string representation.
*/
    private String dateToString(Date d) {
        if (d == null) {
            return('');
        } else {
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            return(dt.format('MM/dd/yyyy'));
        }
    }
    
    /** 
* @Author ADMD Team
* @date 10/21/2013
* @description method repsonsible for presenting correct currency format
* 
*/
    public static String formatToCurrency(String i) {
        String s = (Decimal.valueOf(i == null || i.trim() == '' ? '0' : i).setScale(2) + 0.001).format();
        return s.substring(0, s.length() - 1);
    }
    
    
    /** 
* @Author GFRS Dev Team 
* @date 26/11/2014
* @description startCloningOperation method - cloning handler
*/
    public ApexPages.PageReference startCloningOperation() {
        
        if (checkIfCloneSuperUser) {
            clonedRequest = gFRS_CloningUtil.customCloneWithInsert(this.fundReq, fundReq.clonedRequestOwner__c, this.fundReq.Record_Type_Name__c, fundReq.Organization__c, fundReq.Location__c);
            clonedRequestName = gFRS_CloningUtil.getClonedRequestName(clonedRequest);
        }
        cloningProcessFinished = true;
        
        return null;
        
    }
    
    /**
* @author GFRS Dev Team 
* @date 26/11/2014
* @description isCloneButtonVisible variable - indicates whether 'Clone' button should be displayed on layout.
*/
    public Boolean isCloneButtonVisible {
        get {
            String profileName = profileIdToRecord.get(UserInfo.getProfileId()) == null ? '' : profileIdToRecord.get(UserInfo.getProfileId()).Name;
            
            //cloning button is visible only for submitted requests 
            if (fundReq.Status__c != 'Intake') {
                //button visible only for Exhibits & Other Promos
                if (checkIfCloneSuperUser && fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) {
                    System.debug(debugPrefix + ' isCloneButtonVisible super user AND EXHIBITS');
                    return true;
                } else if (checkIfUserBelonsToMCSGroup && (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME)) {
                    System.debug(debugPrefix + ' isCloneButtonVisible MCS group AND EXHIBITS');
                    return true;
                } else if (profileName != '' && profileName == gFRS_Util.PROFILE_NAME_GFRS_ADMIN) {
                    System.debug(debugPrefix + ' isCloneButtonVisible Admin' + profileName);
                    return true;
                } else if (profileName != '' && profileName == gFRS_Util.PROFILE_NAME_SUPER_USER && checkIfSuperUserCanClone(fundReq.Record_Type_Name__c)) {
                    System.debug(debugPrefix + ' isCloneButtonVisible Super User ' + profileName);
                    return true;
                } else if (fundReq.OwnerId == UserInfo.getUserId()) {
                    return true;
                }
            }
            return false;
        }
        set;
    }
    
    public Boolean checkIfSuperUserCanClone(String recordTypeName) {
        
        if (gFRS_Util.isInternalRequest(recordTypeName)
            || recordTypeName == gFRS_Util.TYPE_HC_CHAR_NAME
            || recordTypeName == gFRS_Util.TYPE_PHILANTHROPIC_NAME) {
                return true;
            }
        
        return false;
    }
    
    public Boolean checkIfUserBelonsToMCSGroup {
        get {
            Group mcsGroup = [
                SELECT Id, Name
                FROM Group
                WHERE Name = :gFRS_Util.MCS_GROUP_NAME
                LIMIT 1
            ];
            
            if (mcsGroup != null && mcsGroup.Id != null) {
                if ([SELECT GroupId, Id, UserOrGroupId FROM GroupMember WHERE GroupId = :mcsGroup.id AND UserOrGroupId = :UserInfo.getUserId()].size() > 0) {
                    //curret user is member of 'GNE-GFRS-M&CS' public group and clone button should be visible
                    return true;
                }
            }
            return false;
        }
        set;
    }
    
    public Boolean checkIfCloneSuperUser {
        get {
            Set<String> profileNames = new Set<String>{
                gFRS_Util.PROFILE_NAME_GFRS_ADMIN, gFRS_Util.PROFILE_NAME_NO_SSO_SUPER_USER, gFRS_Util.PROFILE_NAME_SUPER_USER, gFRS_Util.PROFILE_NAME_SYS_ADMIN, gFRS_Util.PROFILE_NAME_SYS_SUPPORT
                    };
                        
                        if (profileIdToRecord.get(UserInfo.getProfileId()) != null
                            && profileNames.contains(profileIdToRecord.get(UserInfo.getProfileId()).Name)) {
                                return true;
                            } else {
                                return false;
                            }
            
        }
        set;
    }
    
    private Map<Id, Profile> getProfiles(Set<String> profilesNames) {
        
        Map<Id, Profile> profileIdToRecord = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE name IN :profileNames]);
        
        return profileIdToRecord;
    }
    
    /**
* Show change approver information popup if user cannot change approver (don't have permission) or redirect to change approval page.
*
* @return PageReference
*/
    public PageReference showChangeApproverPopup() {
        
        isChangeApproverPopupShown = true;
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        if(userProfile.Name=='GNE-GFRS-Backoffice'){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Insufficient Privileges'));
            return(null);
        }
        else{
            if (gFRS_Util_NoShare.getProcessInstances(fundReq.Id).size() > 0 && gFRS_Util_NoShare.checkIfUserHasCustomPermission('gFRS_Change_Approver')) {
                canUserChangeApprover = true;
            } else if (gFRS_Util.isSystemAdministrator(UserInfo.getUserId())) {
                canUserChangeApprover = true;
            } else {
                canUserChangeApprover = false;
            }
            return canUserChangeApprover ? goToChangeApproverPage() : null;
        }
    }
    
    public void hideChangeApproverPopup() {
        isChangeApproverPopupShown = false;
    }
    
    
    public PageReference rfiOtherSender() {
        System.debug('@@@ RFI'+fundReq.Communication_CC__c);
        rfiOtherUserId=fundReq.Communication_CC__c;
        return null;
    }
    
    
    public PageReference rfiCsOtherSender() {
        //System.debug('@@@ RFI'+fundReq.Accountable_Employee_Approval__c);
        rfiOtherUserId=fundReq.Communication_CC__c;
        return null;
    }
    
    public PageReference goToChangeApproverPage() {
        PageReference pageRef = new PageReference(gFRS_Util.PATH_CHANGEAPPROVER);
        pageRef.getParameters().put('id', fundReq.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public ApexPages.PageReference overridePaymentToCheck(){
        List<gFRS_Tasks__c> postDueTasks = [SELECT Id, Name, Payment_Method_Due_On__c FROM gFRS_Tasks__c 
                                            WHERE  Action_Type__c = 'ACH' AND gFRS_Funding_Request__r.id =: fundReq.Id];
        delete postDueTasks;
        fundReq.Payment_Method__c = 'Check';
        fundReq.Bank_Lookup_Required__c = 'No';
        fundReq.ACH_Task_Open__c = 'No'; 
        fundReq.Partner_Bank_Type__c = '';       
        fundReq.ACH_Override_by__c = UserInfo.getUserId();
        fundReq.Overriden_On__c = DateTime.now();
        fundReq.Overriding_reason__c = 'QCO Override';      
        gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(this.fundReq);
        emailtemplate et = [SELECT Subject, Name, Id, Description, Body,DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'gFRS_Templates' and DeveloperName = 'QCO_Payment_Method_override_communication_email'];
        String body = gFRS_Util_NoShare.replaceEmailBody(et.Body, this.fundReq);
        body += '\n\n' + '[ref:' + fundReq.id + ']'; 
        String subject = gFRS_Util_NoShare.replaceEmailSubject(et.Subject, this.fundReq);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{fundReq.Signing_Authority_Email__c});
        if(bccEmailAddress != null){
            mail.setBccAddresses(new List<String>{bccEmailAddress});
        }
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setOrgWideEmailAddressId([SELECT Id, Address FROM OrgWideEmailAddress
                                       WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        this.isACHOverride_PopUpShown = false;
        return(new ApexPages.PageReference('/' + fundReq.id));
    }
    
    public PageReference recallApprovalProcess() {
        try {
            GFRS_Funding_Request__c funReq = new GFRS_Funding_Request__c(Id = requestID,
                                                                         Status__c = DECISION_STATUS,
                                                                         Sub_Status__c = GC_REVIEW_SUB_STATUS,
                                                                         GC_Decision__c = null,
                                                                         GC_Review_Decision_Date__c = null,
                                                                         External_Sub_status__c = UNDER_REVIEW_STATUS,
                                                                         Decision_Reasons__c = null
                                                                        );
            gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(funReq);
            
            List<gFRS_Tasks__c> loaTasks = [SELECT Id FROM gFRS_Tasks__c WHERE Action_Type__c = 'LOA' AND gFRS_Funding_Request__c =: requestID];
            
            if(!loaTasks.isEmpty()) {
                gFRS_Util_NoShare.removeTasks(loaTasks);
            }
            
            /*   List<ProcessInstance> instance = [SELECT Id FROM ProcessInstance WHERE TargetObjectId =: requestID AND Status = 'Pending' LIMIT 1];
if(!instance.isEmpty()) {
ProcessInstanceWorkitem workItem = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =: instance.get(0).Id LIMIT 1];
Approval.ProcessWorkItemRequest workReq = new Approval.ProcessWorkItemRequest();
workReq.setWorkItemId(workItem.Id);
workReq.setAction('Reject');
Approval.ProcessResult result = Approval.process(workReq);
} */
            gFRS_Util_NoShare.recallRejection(requestID);
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(requestID);
            Approval.ProcessResult result = Approval.process(req);
            
            PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
            pageRef.setRedirect(true);
            return pageRef;
        } catch (Exception err) {
            System.debug('ERROR OCURRED:' + err.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
            return null;
        }
    }
    
    private Boolean checkIfRecallIsAvailable() {
        Boolean result = false;
        
        if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME || (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME && fundReq.Foundation_Classified__c == 'FALSE') || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME || (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME && fundReq.Foundation_Classified__c == 'FALSE')) {
            for (ProcessInstance pi : [SELECT Id, ProcessDefinition.Name, (SELECT ActorId, StepStatus FROM StepsAndWorkitems ORDER BY CreatedDate DESC) FROM ProcessInstance WHERE TargetObjectId = :requestID ORDER BY CreatedDate DESC LIMIT 1]) {
                if (RECALL_APPROVAL_PROCESSES.contains(pi.ProcessDefinition.Name)){
                    if(RECALL_SUB_STATUSES.contains(fundReq.Sub_Status__c) || pi.StepsAndWorkitems.get(0).StepStatus == AP_REJECTED_STATUS) {
                        result = true;
                    }
                }
            }
        }
        
        return result && checkIfUserHasPermissionSet();
    }
    
    private Boolean checkIfUserHasPermissionSet() {
        Boolean result = false;
        for(PermissionSetAssignment pr : [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: RECALL_PERMISSIONSET_NAME]) {
            result = true;
        }
        
        return result;
    }
    
    
    
    
}