/**
* @author GFRS Dev Team
* @date 05/09/2013
* @description GFRS_ApplicationController class - Controller specific to the Confirmation Page
*/
public with sharing class gFRS_ConfirmController {

    public static final String CONTENT_TYPE = 'Confirmation';
    public static final String FINAL_DISCLAIMER_KEY = 'FinalDisclaimer';
    public static final String FINAL_DISCLAIMER_INT_KEY = 'FinalDisclaimerInternal';
    public static final String NON_LEGAL_KEY = 'NonLegalAuthDisclaim';
    public static final String PATH_COMPLETE = '/apex/GFRS_Home';
    public static final String PATH_ACH_INFORMATION = '/apex/gFRS_ACHData';    
    public static final String PATH_ATTACHMENTS = '/apex/gFRS_FileAttachments';
    public static final String PATH_BUDGET = '/apex/gFRS_Budget';
    public static final String PATH_BLACKLISTED = '/apex/gFRS_Error?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=' + gFRS_ErrorController.CODE_BLACKLIST;
    public static final String SUBMITTED_STATUS = 'HC Compliance';
    public static final String SUBMITTED_SUB_STATUS = 'New';
    public static final String EXTERNAL_SUB_STATUS = 'Under Review';
    public static final String EXTERNAL_SUB_STATUS_RFI = 'Under Review';
    public static final String SUB_STATUS_RFI = 'RFI Received';
    public static final String SUB_STATUS_CCO = 'CCO Review';
    public static final String RFI = 'RFI';

    public static EmailWrapper emailConfirmation { get; set; }

    public static final String SIGNER_DATA_EMPTY_ERROR = 'Please specify the authorized signer\'s data';
    public Boolean showPaymentNoteSection { get; set; }

    public Boolean isShutdown { get; private set; }
    public String shutdownMessage { get; private set; }

    //-- local values

    /** current funding Request **/
    public GFRS_Funding_Request__c request { get; set; }

    public Boolean isSigned {
        get {
            return(request != null && request.Signing_Authority_Email__c != null);
        }
    }

    public Boolean isUserAuthorizedSigner { get; set; }

    public Boolean isEditable {
        get {
            return(request != null && (String.isNotBlank(request.Information_Needed__c) && ((request.LOA_Signed__c != 'Yes') || (isLOA_SignedButPaymentPending && request.LOA_Signed__c == 'Yes'))));
        }
    }

    public String authorizedEmail { get; set; }
    public String confirmedEmail { get; set; }
    public Boolean showAuthorization { get; set; }
    
    public Boolean hideResubmit { get; set; }

    public Boolean isRequestCloned { get; set; }
    public Boolean isInRfiStatus { get; set; }

    public String rfiStatusValue { get {return(RFI);} }

    public Map<String, String> contentItems { get; set; }

    public Boolean demoError { get; set; }

    public Boolean isInternal { get; set; }
    public String userEmail { get; set; }
    public String userEmailUnauthorize { get; set; }
    public Boolean isHavingUnfilledMandtryFields;
    public Boolean isLOA_SignedButPaymentPending;


    public gFRS_ConfirmController(ApexPages.StandardController std) {
        emailConfirmation = new EmailWrapper();
        isHavingUnfilledMandtryFields = false;
        isLOA_SignedButPaymentPending = false;
        this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter(CONTENT_TYPE, UserInfo.getLanguage());
        this.request = (GFRS_Funding_Request__c) std.getRecord();

        try {
            this.request = [
                    SELECT Name, Id, Approved_Amount__c, Program_Start_Date_Min__c, Benefits_Exchanged_for_Funding__c,Partner_Bank_Type__c,
                            Request_Cloned__c, Meeting_Agenda__c, Refundable_Deposit_Amount_if_any__c, Location__c,Location__r.Partner_Bank_Type__c,
                            Payment_Call_Counter__c,Accountable_Employee_Approval__c, Requested_Amount__c, Status__c, External_Sub_status__c, Send_By_FedEx_cost_center_will_be_charg__c,
                            Sub_Status__c, Organization__c, Record_Type_Name__c,Signing_Authority_Email__c, Foundation_Classified__c,
                            Authorized_Signer__c, Signing_Authority_First_Name__c, Signing_Authority_Last_Name__c,
                            Information_Needed__c,Payment_Delivery_Notifications__c, Total_Program_Budget__c, LOA_Signed__c, Payment_registration_due_date__c, Payment_registration_due_date_notes__c
                    FROM GFRS_Funding_Request__c
                    WHERE Id = :this.request.Id
            ];

            System.debug('LOA_Signed__c => ' + this.request.LOA_Signed__c);
            this.showAuthorization = gFRS_Util.isInternalRequest(request.Record_Type_Name__c) ? false : true;
            this.showPaymentNoteSection = !this.showAuthorization && request.Payment_registration_due_date__c != null;

            System.debug('isSigned:' + isSigned);
            System.debug('isUserAuthorizedSigner:' + isUserAuthorizedSigner);

            this.isUserAuthorizedSigner = (this.request.Authorized_Signer__c == UserInfo.getUserId());
            this.isInternal = gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c);
            User authorizedSigner = gFRS_DAO.getUserInfo(UserInfo.getUserId()).get(0);
            this.userEmail = authorizedSigner.Email;
            this.userEmailUnauthorize = System.Label.gFRS_ConfirmationError_UnauthorizedEmail;

            if (this.request.Sub_Status__c != null && this.request.Sub_Status__c == RFI) {
                emailConfirmation.email = this.request.Signing_Authority_Email__c;
                isInRfiStatus = true;
            }

            isRequestCloned = this.request.Request_Cloned__c == gFRS_Util.YES ? true : false;
            isHavingUnfilledMandtryFields = gFRS_Util.checkRequestForUnfilledMandtryFields(this.request);
            List <GFRS_Payment_History__c> paymentHistoryList = [select SAP_Doc_ID__c, Grant__c from GFRS_Payment_History__c where 
                                                                    Grant__c = :this.request.Id AND SAP_Doc_ID__c != null];
            isLOA_SignedButPaymentPending = (paymentHistoryList.size() == 0) ? True : False;

        } catch (Exception err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find the external funding request'));
            return;
        }

        isShutdown = false;
        gFRS_Shutdown_Rule__c shutdownRule = gFRS_Util_NoShare.checkShutdownRule(request.Record_Type_Name__c);
        if(shutdownRule != null) {
            isShutdown = true;
            shutdownMessage = shutdownRule.Message__c;
        }
        
        //hideResubmit 
      /*  Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()]; 
        if(userProfile.Name=='GNE-GFRS-Backoffice'){
           hideResubmit=false; 
        }
        else{
            hideResubmit=true;
        } */
        
        
    }

    public String finalDisclaimer { get {return(this.contentItems.get(FINAL_DISCLAIMER_KEY));} }

    public String nonLegalAuthDisclaimer { get {return(this.contentItems.get(NON_LEGAL_KEY));} }


    /**
  * @author GFRS Dev Team  
  * @date 26/08/2013
  * @description back method - moves back a page
  */
    public PageReference back() {
        if(gFRS_Util.isInternalRequest(this.request.Record_Type_name__c)){
            String backPath = (this.request.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME) ? PATH_BUDGET : PATH_ATTACHMENTS;
            return(new PageReference(gFRS_Util.initializeLink(backPath, this.request, null)));
        }
        else{
            if (this.request.Foundation_Classified__c == 'FALSE') {
                return(new PageReference('/apex/gFRS_ACHData?id='+this.request.Location__c + '&fundingreq=' + this.request.id));
            }
            else{
                String backPath = (this.request.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME) ? PATH_BUDGET : PATH_ATTACHMENTS;
                return(new PageReference(gFRS_Util.initializeLink(backPath, this.request, null)));
            }
        }
    }

    /**
     *  Method called to perform final submission
     **/
    public PageReference save() {

        //-- the save sets it to the authorized signer, so we need to copy that over.
        //SFDC-1759 change email authorized only if page is editable otherwise email authorize was cleared;
        if (isEditable) {
            this.request.Signing_Authority_Email__c = this.authorizedEmail;
        } else if (!isEditable) {
            authorizedEmail = this.request.Signing_Authority_Email__c;
        }

        if (!validateSave()) {
            //-- display error message if needed
            return (null);
        }

        String tmpValueInformationNeeded = '';
        Savepoint sp = Database.setSavepoint();
        try {
            //-- check for blacklist
            GFRS_Organization__c tmpOrg = [SELECT Tax_Id__c,Non_US_Organization_ID__c FROM GFRS_Organization__c WHERE Id = :this.request.Organization__c];
            String taxId = tmpOrg.Tax_Id__c;
            String nonUSTaxId = tmpOrg.Non_US_Organization_ID__c;

            if (gFRS_Util.isBlacklistedOrganization(taxId, nonUSTaxId, this.request.Record_Type_Name__c) == true) {
                return(new PageReference(PATH_BLACKLISTED));
            }

            //-- RFI is guaranteed non null, so should be used first in comparison.
            if (RFI.equals(this.request.External_Sub_status__c)) {
                this.request.Sub_Status__c = SUB_STATUS_RFI;
                this.request.External_Sub_status__c = EXTERNAL_SUB_STATUS_RFI;
            } else {
                this.request.Status__c = SUBMITTED_STATUS;
                this.request.Sub_Status__c = SUBMITTED_SUB_STATUS;
                this.request.External_Sub_status__c = EXTERNAL_SUB_STATUS;
            }
            
            if (gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c)){
                if(String.isNotBlank(this.request.Location__r.Partner_Bank_Type__c) && !RFI.equals(this.request.External_Sub_status__c)){
                    this.request.Partner_Bank_Type__c = this.request.Location__r.Partner_Bank_Type__c;
                    this.request.Payment_Method__c = 'ACH';
                    this.request.Send_By_FedEx_cost_center_will_be_charg__c = 'N/A';
                }
            }
            else{
                if(this.request.Foundation_Classified__c == 'TRUE'){
                    this.request.Payment_Method__c = '';
                }
                if(this.request.Partner_Bank_Type__c != null && this.request.Partner_Bank_Type__c != ''){
                    GFRS_Location__c loc = [SELECT Id, Name, Partner_Bank_Type__c FROM GFRS_Location__c WHERE id =: this.request.Location__c Limit 1];
                    if(loc.Partner_Bank_Type__c != this.request.Partner_Bank_Type__c){
                        loc.Partner_Bank_Type__c = this.request.Partner_Bank_Type__c;
                        gFRS_Util_NoShare.saveLockedLocation(loc);
                    }
                }
            }            

            //-- update the amount needed per person
            if (gFRS_Util.TYPE_IMED_NAME.equals(this.request.Record_Type_Name__c)) {
                Decimal totalAttendeeAmount = 0;
                for (GFRS_Program__c prog : [SELECT Total_Number_of_Expected_Learners__c FROM GFRS_Program__c WHERE Funding_Request__c = :this.request.Id]) {
                    totalAttendeeAmount += prog.Total_Number_of_Expected_Learners__c;
                }
                if (totalAttendeeAmount > 0) {
                    this.request.Total_Activity_Cost_per_Attendee__c = this.request.Total_Program_Budget__c / totalAttendeeAmount;
                } else {
                    this.request.Total_Activity_Cost_per_Attendee__c = null;
                }
            }

            //-- information is no longer needed
            tmpValueInformationNeeded = this.request.Information_Needed__c;
            this.request.Information_Needed__c = '';

            if (gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c) && this.request.Approved_Amount__c == null) {
                this.request.Approved_Amount__c = this.request.Requested_Amount__c;
                //if( this.request.Refundable_Deposit_Amount_if_any__c != null ) this.request.Approved_Amount__c -= this.request.Refundable_Deposit_Amount_if_any__c;
            }

            //assign authorized signer
            User[] potentialAuthorizedSigners = null;
            User authorizedSigner = null;

            if (this.isUserAuthorizedSigner == true) {
                this.request.Authorized_Signer__c = UserInfo.getUserId();

                authorizedSigner = [SELECT FirstName, LastName, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                this.request.Signing_Authority_Email__c = authorizedSigner.Email;
                this.request.Signing_Authority_First_Name__c = authorizedSigner.FirstName;
                this.request.Signing_Authority_Last_Name__c = authorizedSigner.LastName;
                this.request.Authorized_Signer__c = UserInfo.getUserId();
                authorizedEmail = this.request.Signing_Authority_Email__c;

            } else if (authorizedEmail != null) {
                System.debug(authorizedEmail);

                this.request.Signing_Authority_Email__c = authorizedEmail;
                System.debug('this ->' + this.authorizedEmail);
                potentialAuthorizedSigners = gFRS_Util_NoShare.userByEmail(this.authorizedEmail);

                if (potentialAuthorizedSigners.size() > 0) {
                    this.request.Authorized_Signer__c = potentialAuthorizedSigners[0].Id;
                    System.debug('new Authorized_Signer__c id set : ' + this.request.Authorized_Signer__c);
                }

                //-- share with the appropriate user
                System.debug('preparing to share with other users');
                if (!gFRS_Util_NoShare.applySharingRulesForSelectedUsers(this.request.Id, this.request.Signing_Authority_Email__c)) {
                    System.debug('Could not share with other user:' + this.request.Signing_Authority_Email__c + ']');
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify the authorized signer\'s email'));
                return(null);
            }

            System.debug('SIGNING AUTHORITY EMAIL:' + this.request.Signing_Authority_Email__c);
            //System.assertNotEquals( null, this.request.Signing_Authority_Email__c, 'Signing Authority Email MUST BE SET' );

            gFRS_Util_NoShare.saveLockedFundingRequest(this.request);

            if (this.isInternal) {
                //-- refresh the request, and verify that there are no payments
                GFRS_Funding_Request__c requestWithPayments = [SELECT Id, Payment_Call_Counter__c, (SELECT Name, SAP_Request_ID__c FROM Payment_History__r) FROM GFRS_Funding_Request__c WHERE Id = :this.request.Id LIMIT 1];

                //-- we only create a new paymentHistory if a payment history (or a payment history with matching criteria) does not already exist.
                if (requestWithPayments.Payment_History__r == null || requestWithPayments.Payment_History__r.size() < 1) {
                    //-- there is no payment history, so one must be created

                    try {
                        this.request.Payment_Call_Counter__c = requestWithPayments.Payment_Call_Counter__c + 1;
                        request.IsValidationExternalOnly__c = 'Yes';
                        update this.request;
                    } catch (Exception e) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(e)));
                    }
                    String sapRequestId = this.request.Name + '_' + this.request.Payment_Call_Counter__c;

                    GFRS_Payment_History__c paymentHistory = new GFRS_Payment_History__c();
                    paymentHistory.SAP_Request_ID__c = sapRequestId;
                    paymentHistory.Grant__c = this.request.Id;
                    paymentHistory.Payment_Type__c = 'Payment';

                    gFRS_Util_NoShare.saveLockedPaymentHistories(new GFRS_Payment_History__c[]{
                            paymentHistory
                    });
                }
            }

            //system.debug('Statusss:'+this.request.Sub_Status__c);
            if (this.request.Sub_Status__c.equals(SUB_STATUS_CCO)) {
                //-- setup the approval 
                Approval.ProcessSubmitRequest approvalItem = new Approval.ProcessSubmitRequest();
                approvalItem.setComments('Submitting request for approval.');
                approvalItem.setObjectId(this.request.Id);

                //-- submit the approval 
                Approval.ProcessResult result = Approval.process(approvalItem);
                //-- verify 
                if (!result.isSuccess()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while sending request for submission.'));
                    return (null);
                }
            }
        } catch (Exception err) {
            System.debug('some problems to update');
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
            this.request.Information_Needed__c = tmpValueInformationNeeded;
            return (null);
        }

        return(nextPage());
    }

    public PageReference nextPage() {
        //check if user is an internal user
        String targetPath = PATH_COMPLETE;
        if (gFRS_Util.isSystemAdministrator(UserInfo.getUserId())) {
            //if is an internal user
            targetPath = '/' + this.request.Id;
        }
        return(new PageReference(gFRS_Util.initializeLink(targetPath, null, null)));
    }

    /**
     *  Validates the page before submission
     *  @return (Boolean) - whether validation passed (True) or failed (false)
     **/
    public Boolean validateSave() {

        if (this.isInternal && this.request.Payment_registration_due_date__c != null && !gFRS_Util.isValidBusinessDaysBetweenDates(Date.today(), this.request.Payment_registration_due_date__c, 20)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Funding_Payment_Request_20_Business_Days_Error));
            return false;
        }

        if (this.isInternal) {
            List<GFRS_Program__c> programs = gFRS_DAO.getProgramListByRequestId(this.request.Id);
            for (GFRS_Program__c program : programs) {
                if (!gFRS_Util.isValidCalenderDaysBetweenDates(Date.today(), program.Start_Date__c, 0)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Minimum_Program_Start_Date_Error));
                    return false;
                }
            }

            for (GFRS_Program__c program : programs) {
                if (!gFRS_Util.isValidBusinessDaysBetweenDates(Date.today(), program.Start_Date__c, 20) && (program.Short_Start_Date_Resp__c == '' || program.Short_Start_Date_Resp__c == 'No' || program.Short_Start_Date_Resp__c == null)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Short_Start_Date_Acknowledge_Error));
                    return false;
                }
            }           
        } else {
            Date lastValidDate = Date.today().addDays(60);
            String errorMessage = System.Label.gFRS_Program_60_Days_Start_Date_Error;
            List<GFRS_Program__c> programsWithoutPropperStartDate = gFRS_DAO.getProgramListByRequestIdAndStartDate(this.request.Id, lastValidDate);

            System.debug('PN: LAST VALID DATE: ' + lastValidDate);
            System.debug('PN: INVALID PROGRAMS: ' + programsWithoutPropperStartDate);
            //Validation for GFRS-10 - we need to check only Programs with Start Date == null because on Programs page this Field is required, and if user set the date then validation will work on Program page.
            if (programsWithoutPropperStartDate.size() > 0 && this.request.Status__c == gFRS_Util.REQUEST_DEFAULT_STATUS) {//only for Intake
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                return false;
            }
        }

        if (this.isUserAuthorizedSigner == false || this.isInternal == true) {
            if (this.request.Signing_Authority_Email__c == null || this.request.Signing_Authority_First_Name__c == null || this.request.Signing_Authority_Last_Name__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SIGNER_DATA_EMPTY_ERROR));
                return(false);
            }

        }

        //Validate Internal FT attachments
        if (gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c) && !validateInternalAttachments(this.request.Id)) {
            return false;
        }

        //Validate HC Char attachments
        if (this.request.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME && !validateHcCharAttachments(this.request.Id)) {
            return false;
        }

        //Validate External FT attachments
        if (!gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c) && !validateExternalAttachments(this.request.Id)) {
            return false;
        }

        /* GFRS-659 validate wbs code and cost center for cloned internal requests (except for FIE)
        * error message had to be divided to 3 errors & hardcoded, as we couldn't insert line breaks in Custom Label 
        */
        if (this.isRequestCloned && gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c) && this.request.Record_Type_Name__c != gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) {
            if (!checkIfCostCenterAndWBSCodeIsPopulated(this.request.Id)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The following information is missing. Go to the Allocation Items in the Application section to enter:'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cost Center'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'WBS Code'));
                return false;
            }
        }
        
        /*
        * error message to stop if request is having any mandatory fields that are not filled
        */
        if(isHavingUnfilledMandtryFields){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill all the mandatory information prior to the submission of request.'));
            return false;
        } 

        return(true);
    }


    /**
    * @author GFRS Dev Team
    * @date 07/03/2016
    * @description checkIfCostCenterAndWBSCodeIsPopulated - whether the Cost Center and WBS Code is popuplated in all FA Line Items. 
    */
    private Boolean checkIfCostCenterAndWBSCodeIsPopulated(Id reqId) {
        Boolean result = true;

        if (reqId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occured. Please try again.'));
            return false;
        }

        List<GFRS_Funding_Allocation__c> fundingAllocations = [SELECT Id FROM GFRS_Funding_Allocation__c WHERE Grant_Request__c = :reqId];

        List<GFRS_Funding_Allocation_Line_Item__c> fundingAllocationLIs = [
                SELECT Id, Funding_Allocation__c, WBS_Code_Lookup__c, Cost_Center_Lookup__c
                FROM GFRS_Funding_Allocation_Line_Item__c
                WHERE Funding_Allocation__c IN :fundingAllocations
                ORDER BY CreatedDate ASC
        ];

        for (GFRS_Funding_Allocation_Line_Item__c fALI : fundingAllocationLIs) {
            if (fALI.WBS_Code_Lookup__c == null || fALI.Cost_Center_Lookup__c == null) {
                result = false;
            }
        }

        return result;

    }

    /**
    * @author GFRS Dev Team
    * @date 28/11/2014
    * @description validateExternalAttachments - whether the External requests has all required attachments. 
    */
    private Boolean validateExternalAttachments(Id requestId) {

        if (requestId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occured. Please try again.'));
            return false;
        }

        Boolean result = true;

        GFRS_Funding_Request__c requestToValidate = [SELECT Fellowship_Project_Description__c, Promotional_Event_Advertising__c, Meeting_Agenda__c, Record_Type_Name__c FROM GFRS_Funding_Request__c WHERE Id = :requestId LIMIT 1];

        if (requestToValidate != null) {
            if ((requestToValidate.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME || requestToValidate.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME) && requestToValidate.Fellowship_Project_Description__c == null) {

                result = false;

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ConfirmationAttachmentErrorTop));

                if (requestToValidate.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME || requestToValidate.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME) {

                    if (requestToValidate.Fellowship_Project_Description__c == null) {
                        if (requestToValidate.Meeting_Agenda__c == null) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GFRS_Funding_Request__c.Fellowship_Project_Description__c.getDescribe().label));
                        }
                    }
                }

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ConfirmationAttachmentErrorBottom));
            }
        }
        return result;
    }

    private Boolean validateHcCharAttachments(Id requestId) {

        if (requestId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occured. Please try again.'));
            return false;
        }

        Boolean result = true;

        List<GFRS_Program__c> programsToValidate = [
                SELECT
                        Name,
                        Meeting_Agenda__c,
                        Promotional_Event_Advertising__c,
                        Type__c
                FROM GFRS_Program__c
                WHERE Funding_Request__c = :requestId

        ];

        if (programsToValidate != null && programsToValidate.size() > 0) {

            for (GFRS_Program__c myProgram : programsToValidate) {

                if ((myProgram.Type__c == 'Live Activity' && myProgram.Meeting_Agenda__c == null) || myProgram.Promotional_Event_Advertising__c == null) {

                    result = false;

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ConfirmationAttachmentErrorTop));

                    if (myProgram.Meeting_Agenda__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GFRS_Program__c.Meeting_Agenda__c.getDescribe().label));
                    }
                    if (myProgram.Promotional_Event_Advertising__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GFRS_Program__c.Promotional_Event_Advertising__c.getDescribe().label));
                    }

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ConfirmationAttachmentErrorBottom));

                    return false;
                }
            }

        }

        return result;

    }

    /**
    * @author GFRS Dev Team
    * @date 28/11/2014
    * @description validateInternalAttachments - whether the Internal requests has all required attachments. 
    */
    private Boolean validateInternalAttachments(Id requestId) {


        if (requestId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occured. Please try again.'));
            return false;
        }

        Boolean result = true;

        GFRS_Funding_Request__c requestToValidate = [SELECT Benefits_Exchanged_for_Funding__c, Letter_of_Request__c, Promotional_Event_Advertising__c, Meeting_Agenda__c, Record_Type_Name__c FROM GFRS_Funding_Request__c WHERE Id = :requestId LIMIT 1];

        Boolean corpoMembException = (requestToValidate.Benefits_Exchanged_for_Funding__c != gFRS_Util.REQUEST_BENEFITS_EXCHANGED_EXHIBIT_SPACE && requestToValidate.Benefits_Exchanged_for_Funding__c != gFRS_Util.REQUEST_BENEFITS_EXCHANGED_EXHIBIT_SPACE_PREF_LOC);

        if (requestToValidate != null) {

            if (requestToValidate.Letter_of_Request__c == null || /* requestToValidate.Promotional_Event_Advertising__c == null || */ (!corpoMembException && requestToValidate.Meeting_Agenda__c == null)) {

                result = false;

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ConfirmationAttachmentErrorTop));

                if (requestToValidate.Letter_of_Request__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GFRS_Funding_Request__c.Letter_of_Request__c.getDescribe().label));
                }
               /* if (requestToValidate.Promotional_Event_Advertising__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GFRS_Funding_Request__c.Promotional_Event_Advertising__c.getDescribe().label));
                } */

                if (requestToValidate.Record_Type_Name__c.equals(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME) && !corpoMembException) {
                    if (requestToValidate.Meeting_Agenda__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GFRS_Funding_Request__c.Meeting_Agenda__c.getDescribe().label));
                    }
                }

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ConfirmationAttachmentErrorBottom));
            }

        }

        return result;
    }

    /**
    * @author GFRS Dev Team 
    * @date 05/09/2013
    * @description populateAuthorizedSigner method - when user checks 'I am legally authorized' radio button the corresponding fields of FUnding Request should be populated
    */
    public void populateAuthorizedSigner() {
        if (isEditable) {

            User authorizedSigner = gFRS_DAO.getUserInfo(UserInfo.getUserId()).get(0);

            this.request.Signing_Authority_Email__c = authorizedSigner.Email;
            this.request.Signing_Authority_First_Name__c = authorizedSigner.FirstName;
            this.request.Signing_Authority_Last_Name__c = authorizedSigner.LastName;
            this.request.Authorized_Signer__c = authorizedSigner.Id;
            this.authorizedEmail = this.request.Signing_Authority_Email__c;

            gFRS_Util_NoShare.saveLockedFundingRequest(this.request);
        }
    }

    /**
    * @author GFRS Dev Team 
    * @date 05/09/2013
    * @description clearAuthorizedSigner method - when user checks 'I am legally authorized' radio button the corresponding fields of FUnding Request should be populated
    */
    public void clearAuthorizedSigner() {
        if (isEditable) {
            this.request.Signing_Authority_Email__c = null;
            this.request.Signing_Authority_First_Name__c = null;
            this.request.Signing_Authority_Last_Name__c = null;
            this.request.Authorized_Signer__c = null;

            gFRS_Util_NoShare.saveLockedFundingRequest(this.request);
        }
    }

    /**
    * @author GFRS Dev Team 
    * @date 05/09/2013
    * @description saveConfirmationInfo method - saves 'onChange' changes from the form
    */
    public void saveConfirmationInfo() {
        if (isEditable) {
            System.debug('PN:saveConfirmationInfo: ' + this.request.Signing_Authority_Email__c);
            gFRS_Util_NoShare.saveLockedFundingRequest(this.request);
        }
    }

    /**
    * @author GFRS Dev Team 
    * @date 05/09/2013
    * @description saveConfirmationInfoEmail method - saves 'onChange' changes from the form
    */
    public void saveConfirmationInfoEmail() {
        try {
            if (isEditable) {
                this.request.Signing_Authority_Email__c = confirmedEmail;
                this.request.IsValidationExternalOnly__c = 'Yes';
                update this.request;
            }
        } catch (Exception err) {
            //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, String.valueOf(err) ) );
        }

    }

    /**
    * @author GFRS Dev Team
    * @date 31/10/2018
    * @description saveConfirmationInfo method - saves 'onChange' changes from the form
    */
    public void savePaymentDate() {
        if (request.Payment_registration_due_date__c != null) {
            showPaymentNoteSection = true;
        } else {
            showPaymentNoteSection = false;
        }
    }

    /**
    * @author GFRS Dev Team
    * @date 05/09/2013
    * @description EmailWrapper class
    */
    public class EmailWrapper {
        public String email { get; set; }

        public EmailWrapper(String email) {
            email = email;
        }

        public EmailWrapper() {
            email = '';
        }
    }
}