/** @date 6/25/2012
* @Author Pawel Sprysak
* @description Controller Extension for AGS_ST_DisputeDetail_gne
*/
global without sharing class AGS_ST_DisputeDetail_ControllerExt_gne {
    private final static String CCO_GROUP_NAME                  = 'GNE-AGS-CCO-Analyst-Group';
    private final static String TRIAGE_TEAM_GROUP_NAME          = 'Data Support Group';
    private final static String CCO_QUEUE_NAME                  = 'AGS ST CCO Analyst Queue';
    private final static String DISPUTE_RESOLVER_OBJ_TYPE_NAME  = 'AGS_ST_DisputeResolver_gne__c';

    private AGS_ST_DisputeManagement_gne__c disputeMgmtObj;
    private Profile userProfile;
    public AGS_ST_DMPagingAndSortingUtils noteAndAttachUtil { get; set; }
    public String actionMessages                            { get; set; }
    // Collision Pop-up Page
    //public Boolean isCollision { get; set; }
    public Boolean isDisputeExplanation                     { get; set; }
    // Dispute Detail
    private String epi;
    public String npiNum                                    { get; set; }
    public String licenseStateNum                           { get; set; }
    public String address                                   { get; set; }
    public String internalStatus                            { get; set; }
    public Boolean isEditable                               { get; set; }
    public String userName                                  { get; set; }
    public DateTime activityDate                            { get; set; }
    public TransferOfValueClass ccoTov                      { get; set; }
    public Boolean primaryCmsDispute                        { get; set; }
    public String primaryCmsDisputeId                       { get; set; }
    public Id disputeOwnerId                                { get; set; }
    public Id primaryOwnerId                                { get; set; }
    public Id disputeResolverId                             { get; set; }
    public Id primaryResolverId                             { get; set; }
    public String primaryInternalStatus                     { get; set; }
    public String[] multiDrugNames                          { get; set; }
    /* HD Decommissioning *** public Integer relatedHeldNum                           { get; set; } */
    public Integer showChangeToExtBtn                       { get; set; }
    public AGS_ST_User_gne__c   stUser                      { get; set; }
    public Integer numOpenSpends                            { get; set; }
    // Notes and Attachments
    Map<String,AGS_ST_Email_Templates_gne> emailTemplates;
    public Boolean isPrivateNote                            { get; set; }
    public String noteValue                                 { get; set; }
    public String noteCommunicationMethod                   { get; set; }
    public String noteCommunicationType                     { get; set; }
    public AGS_ST_Dispute_Note_and_Attachment_gne__c noteDate { get; set; }
    public Attachment attachment1                           { get; set; }
    public Attachment attachment2                           { get; set; }
    public Attachment attachment3                           { get; set; }
    public Attachment attachment4                           { get; set; }
    public Attachment attachment5                           { get; set; }
    public Attachment attachmentEmail                       { get; set; }
    public Attachment attachmentEmailResolution             { get; set; }
    public String emailSubject                              { get; set; }
    public String externalEmailBodyResolution               { get; set; }
    public String email_type                                { get; set; }
    public String email_type_resolution                     { get; set; }
    public String externalEmailBody                         { get; set; }
    public Boolean isHcpCommunicated                        { get; set; }
    public List<DisputeNotesAttachments> disputeExternalNotes { get; set; }
    public List<DisputeNotesAttachments> disputeAllNotes    { get; set; }
    public DisputeNotesAttachments tovNote                  { get; set; }
    public List<String> emailRecipients                     { get; set; }
    public List<String> emailRecipientsResolution           { get; set; }
    public String inputStatus                               { get; set; }
    public String amountHidden                              { get; set; }
    public String groupAmountHidden                         { get; set; }
    public String attendeesHidden                           { get; set; }
    public String fopHidden                                 { get; set; }
    public String nopHidden                                 { get; set; }
    public String brandHidden                               { get; set; }
    public String optOutHidden                              { get; set; }
    public Boolean isCCOUser                                { get; set; } // is in CCO group
    public Boolean isSuperUser                              { get; set; }
    public String diputeExplanationToEdit                   { get; set; }
    //public Set<String> excludeNames = new Set<String>();
    // Usable lists
    private Set<User> ccoUsersList                          { get; set; }
    private Set<User> triageUsersList                       { get; set; }
    private Set<Group> queuesList                           { get; set; }
    // changeBodyResolution function params
    public String cbrFOP                                    { get; set; }
    public String cbrNOP                                    { get; set; }
    public String cbrAmount                                 { get; set; }
    public String cbrDrug                                   { get; set; }

    // Flag for checkick, wheather Opt/Out checkbox should be visible
    public Boolean showOptOut {
        get {
            /*
            if (this.disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Source_System_Code_gne__c=='APRIMO' && this.disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.SCH_Activity_gne__c=='Speaker Program') {
                return true;
            }
            return false;
            */
            return AGS_ST_Utils.isOptOutForSpend(
                    new AGS_Spend_Expense_Transaction_gne__c(SCH_Activity_gne__c = this.disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.SCH_Activity_gne__c,
                        SCh_Category_gne__c = this.disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.SCh_Category_gne__c,
                        SCH_Spend_gne__c = this.disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.SCH_Spend_gne__c,
                        SCH_Expense__c = this.disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.SCH_Expense__c
                ));
        }
    }
    // Returns whether the current user is able to make corrections in the dispute management object
    // and dispute status is set to correctable one.
    public Boolean isCorrectable {
        get {
            if( null != this.disputeMgmtObj.Dispute_Resolver_gne__c
                && ('Submitted' != this.disputeMgmtObj.Internal_Status_gne__c)
                && ('Corrected Pending SSR' != this.disputeMgmtObj.Internal_Status_gne__c)
                && ('Resolved With Correction' != this.disputeMgmtObj.Internal_Status_gne__c)
                && ('Resolved No Correction' != this.disputeMgmtObj.Internal_Status_gne__c)
                && ( UserInfo.getUserId() == String.valueOf(disputeResolverId) || UserInfo.getUserId() == String.valueOf(disputeOwnerId) )
            ) {
                return true;
            }
            return false;
        }
    }
    // Returns whether the current user is able to make corrections in the dispute management object.
    public Boolean isCorrectableUser {
        get {
            if( null != this.disputeMgmtObj.Dispute_Resolver_gne__c
                && (UserInfo.getUserId() == String.valueOf(disputeResolverId) || UserInfo.getUserId() == String.valueOf(disputeOwnerId))
            ) {
                return true;
            }
            return false;
        }
    }
    // Returns whether the current user is able to make corrections in the dispute management object
    // and dispute status is set to correctable one.
    public Boolean isResolved {
        get {
            if( ('Corrected Pending SSR'.equals(this.disputeMgmtObj.Internal_Status_gne__c))
                || ('Resolved With Correction'.equals(this.disputeMgmtObj.Internal_Status_gne__c))
                || ('Resolved No Correction'.equals(this.disputeMgmtObj.Internal_Status_gne__c))
            ) {
                return true;
            }
            return false;
        }
    }
    public Boolean isSubmitted {
        get {
            if('Submitted'.equals(this.disputeMgmtObj.Internal_Status_gne__c)) {
                return true;
            }
            return false;
        }
    }
    public Boolean isOwnerResolverChangeable {
        get {
        	if(isCorrectable // Already Resolver/Owner in In Progress and Assigned statuses
        	   || (isSuperUser && (!isResolved) )// || 'Corrected Pending SSR'.equals(this.disputeMgmtObj.Internal_Status_gne__c) ) ) // Super User privileges
        	) {
        		return true;
        	} else {
        		return false;
        	}
        }
    }
    public Boolean isCmsDispute {
        get {
            return disputeMgmtObj.Dispute_List_gne__r.IsCmsDispute_gne__c;
        }
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Dispute Detail Page Extension Constructor
    * @param ApexPages.StandardController controller
    */
    public AGS_ST_DisputeDetail_ControllerExt_gne(ApexPages.StandardController controller) {
        this.prepareDisputeMgmtStdController(controller);
        this.disputeMgmtObj = (AGS_ST_DisputeManagement_gne__c) controller.getRecord();
        this.activityDate = this.disputeMgmtObj.LastModifiedDate;
        noteAndAttachUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        ccoUsersList = AGS_ST_DbUtils.getUsersFromGroupsByGroupNames(new List<String> {CCO_GROUP_NAME});
        triageUsersList = AGS_ST_DbUtils.getUsersFromGroupsByGroupNames(new List<String> {TRIAGE_TEAM_GROUP_NAME});
        queuesList = AGS_ST_DbUtils.getQueuesForObjectTypes(new List<String> {DISPUTE_RESOLVER_OBJ_TYPE_NAME});

        isCCOUser = false;
        for (User u : ccoUsersList) {
            if(Userinfo.getUserId() == u.Id) isCCOUser = true;
        }
        isSuperUser = false;
        AGS_ST_Settings_gne__c settingsData = AGS_ST_Utils.getDefaultCustomSettings();
        if( (settingsData.SuperAdmin1_gne__c != null && settingsData.SuperAdmin1_gne__c.equals(UserInfo.getUsername()))
            || (settingsData.SuperAdmin2_gne__c != null && settingsData.SuperAdmin2_gne__c.equals(UserInfo.getUsername()))
            || (settingsData.SuperAdmin3_gne__c != null && settingsData.SuperAdmin3_gne__c.equals(UserInfo.getUsername()))
        ) {
            isSuperUser = true;
        }

        if(disputeMgmtObj.Internal_Status_gne__c != 'Submitted') {
            disputeOwnerId = disputeMgmtObj.OwnerId;
        }
        if(disputeMgmtObj.Dispute_Resolver_gne__c != null) {
            disputeResolverId = disputeMgmtObj.Dispute_Resolver_gne__r.OwnerId;
        }
        primaryCmsDispute = disputeMgmtObj.Dispute_List_gne__r.IsCmsDispute_gne__c;
        primaryCmsDisputeId = disputeMgmtObj.Dispute_List_gne__r.CmsDisputeId_gne__c;
        primaryResolverId = disputeResolverId;
        primaryOwnerId = disputeOwnerId;
        primaryInternalStatus = disputeMgmtObj.Internal_Status_gne__c;
        isEditable = false;
        userName = '';
        actionMessages = '';
        String com = ApexPages.currentPage().getParameters().get('com');
        if(com!=null && com.equals('1')) {
            actionMessages = 'Dispute has been corrected<br/>';
        }
        emailRecipients = new List<String>();
        emailRecipientsResolution = new List<String>();
        isPrivateNote = true;
        noteDate = new AGS_ST_Dispute_Note_and_Attachment_gne__c();
        attachment1 = new Attachment();
        attachment2 = new Attachment();
        attachment3 = new Attachment();
        attachment4 = new Attachment();
        attachment5 = new Attachment();
        attachmentEmail = new Attachment();
        attachmentEmailResolution = new Attachment();
        // Filling NPI# from Primary Recipient
        npiNum = disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_NPI_gne__c;
        // Filling Address
        address = '';
        if( !String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_ADDRESS_LINE1_gne__c) ) {
            address = disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_ADDRESS_LINE1_gne__c;
        }
        if( !String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_ADDRESS_LINE2_gne__c) ) {
            address += (String.isBlank(address) ? '' : ', ') + disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_ADDRESS_LINE2_gne__c;
        }
        if( !String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_CITY_gne__c) ) {
            address += (String.isBlank(address) ? '' : ', ') + disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_CITY_gne__c;
        }
        if( !String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_State_gne__c) ) {
            address += (String.isBlank(address) ? '' : ', ') + disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_State_gne__c;
        }
        if( !String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_State_gne__c) && !String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_ZIP_gne__c) ) {
            address += ' - ' + disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_ZIP_gne__c;
        } else if( !String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_ZIP_gne__c) ) {
            address += (String.isBlank(address) ? '' : ', ') + disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Party1_ZIP_gne__c;
        }
        // Filling License State Number
        licenseStateNum = ((!String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_ST_CD_gne__c)) ? disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_ST_CD_gne__c : '');
        licenseStateNum += (!String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_ST_CD_gne__c) || !String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_NUM_gne__c)) ? ' - ' : '';
        licenseStateNum += ((!String.isBlank(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_NUM_gne__c)) ? disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_NUM_gne__c : '');
        //checkPhysicianDisputeCollision();
        // Filling other values
        /* HD Decommissioning
        relatedHeldNum = AGS_ST_DbUtils.getRelatedHeldNumByDispId(disputeMgmtObj.Id);
        */
        userProfile = AGS_ST_DbUtils.getProfileNameById(UserInfo.getProfileId());
        epi = AGS_ST_DbUtils.getExpenseProductInteractionByTransactionId(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__c);

        String drugNameVal = '';
        if(disputeMgmtObj.Corrected_gne__c == true) {
            drugNameVal = disputeMgmtObj.Drug_Name_gne__c;
            Decimal attendeesCount = disputeMgmtObj.Attendees_gne__c;
            if(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Source_System_Code_gne__c != null 
                && (disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Source_System_Code_gne__c.equals('SAPBW') 
                    || disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Source_System_Code_gne__c.equals('A/P'))
            ) {
                attendeesCount = 1;
            }
            ccoTov = new TransferOfValueClass('CCO', disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c,
                                         disputeMgmtObj.Amount_gne__c,
                                         disputeMgmtObj.Form_Of_Payment_gne__c,
                                         disputeMgmtObj.Nature_Of_Payment_gne__c,
                                         disputeMgmtObj.Drug_Name_gne__c,activityDate,disputeMgmtObj.Source_Amount_gne__c,
                                         disputeMgmtObj.Opt_Out_gne__c,attendeesCount,
                                         String.valueOf(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Event_Planned_Attendee_Count_gne__c));
        } else {
            drugNameVal = disputeMgmtObj.Orig_Drug_Name_gne__c;
            Decimal attendeesCount = disputeMgmtObj.Orig_Event_Actual_Attendee_Count_gne__c;
            if(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Source_System_Code_gne__c != null 
                && (disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Source_System_Code_gne__c.equals('SAPBW') 
                    || disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Source_System_Code_gne__c.equals('A/P'))
            ) {
                attendeesCount = 1;
            }
            ccoTov = new TransferOfValueClass('CCO', disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c,
                                         disputeMgmtObj.Orig_Allocated_Transaction_Amount_gne__c,
                                         disputeMgmtObj.Orig_Form_Of_Payment_gne__c,
                                         disputeMgmtObj.Orig_Nature_Of_Payment_gne__c,
                                         epi,activityDate,
                                         disputeMgmtObj.Orig_Source_Transaction_Amount_gne__c,
                                         disputeMgmtObj.Opt_Out_gne__c,attendeesCount,
                                         String.valueOf(disputeMgmtObj.Orig_Event_Planned_Attendee_Count_gne__c));
        }
        if(drugNameVal != null) {
            multiDrugNames = drugNameVal.split(',', -2);
        } else {
            multiDrugNames = new List<String>{''};
        }
        emailTemplates = new AGS_ST_Email_Templates_gne('', '', '', '').getEmailTemplates(disputeMgmtObj.Id);
        disputeExternalNotes = new List<DisputeNotesAttachments>();
        disputeAllNotes = new List<DisputeNotesAttachments>();
        setNotesAndAttachments();
        setExternalNotes();
        noteAndAttachUtil.duplicateValues();
        isDisputeExplanation = false;
        if(tovNote != null) {
            if(tovNote.About.equals('HCP Dispute')) {
                isDisputeExplanation = true;
            }
        }
        showChangeToExtBtn = AGS_ST_DbUtils.getDMNumForSpend(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Id);
        stUser = null;
        if(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_MDM_ID_gne__c != null) {
           stUser = AGS_ST_DbUtils.getAgsStUserByMDMId(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_MDM_ID_gne__c);
        }
        if(stUser == null && disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Secondary_Recipient_MDM_ID_gne__c != null) {
           stUser = AGS_ST_DbUtils.getAgsStUserByMDMId(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Secondary_Recipient_MDM_ID_gne__c);
        }
        if(stUser == null) {
            showChangeToExtBtn = 1;
        }
        numOpenSpends = AGS_ST_DbUtils.getDMNumForSpend(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__c);
        system.debug(LoggingLevel.INFO,'isCCOUser ' + isCCOUser);
        system.debug(LoggingLevel.INFO,'isCorrectable ' + isCorrectable);
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Prepares the standard controller for Dispute Management object (adds fields not bound in VF page but needed here).
    * @param ApexPages.StandardController aController
    */
    private void prepareDisputeMgmtStdController(ApexPages.StandardController aController) {
        List<String> fieldList = new List<String>();
        fieldList.add('Id');
        fieldList.add('Amount_gne__c');
        fieldList.add('Attendees_gne__c');
        fieldList.add('Corrected_gne__c');
        fieldList.add('CreatedDate');
        fieldList.add('Drug_Name_gne__c');
        fieldList.add('Form_Of_Payment_gne__c');
        fieldList.add('Internal_Status_gne__c');
        fieldList.add('LastModifiedDate');
        fieldList.add('Nature_Of_Payment_gne__c');
        fieldList.add('Opt_Out_gne__c');
        fieldList.add('Orig_Drug_Name_gne__c');
        fieldList.add('Orig_Form_Of_Payment_gne__c');
        fieldList.add('Orig_Nature_Of_Payment_gne__c');
        fieldList.add('Orig_Source_Transaction_Amount_gne__c');
        fieldList.add('Orig_Allocated_Transaction_Amount_gne__c');
        fieldList.add('Orig_Event_Actual_Attendee_Count_gne__c');
        fieldList.add('Orig_Event_Planned_Attendee_Count_gne__c');
        fieldList.add('OwnerId');
        fieldList.add('Source_Amount_gne__c');
        fieldList.add('Dispute_Resolver_gne__c');
        fieldList.add('Dispute_Resolver_gne__r.OwnerId');
        fieldList.add('Dispute_Resolver_gne__r.Owner.Name');
        fieldList.add('Dispute_List_gne__r.AGS_ST_Proxy_gne__c');
        fieldList.add('Dispute_List_gne__r.AGS_ST_Proxy_gne__r.User_gne__r.Email');
        fieldList.add('Dispute_List_gne__r.AGS_ST_Proxy_gne__r.User_gne__r.Name');
        fieldList.add('Dispute_List_gne__r.Amount_gne__c');
        fieldList.add('Dispute_List_gne__r.CmsDisputeId_gne__c');
        fieldList.add('Dispute_List_gne__r.CreatedDate');
        fieldList.add('Dispute_List_gne__r.Drug_Name_gne__c');
        fieldList.add('Dispute_List_gne__r.Form_Of_Payment_gne__c');
        fieldList.add('Dispute_List_gne__r.Nature_Of_Payment_gne__c');
        fieldList.add('Dispute_List_gne__r.IsCmsDispute_gne__c');
        fieldList.add('Dispute_List_gne__r.OwnerId');
        fieldList.add('Dispute_List_gne__r.Owner.username');
        fieldList.add('Dispute_List_gne__r.Owner.Name');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Allocated_Transaction_Amount_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.CreatedDate');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Event_Actual_Attendee_Count_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Event_Planned_Attendee_Count_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Form_Of_Payment_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.LogicalDeleteFlag_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_MDM_ID_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Secondary_Recipient_MDM_ID_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Nature_Of_Payment_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.SCH_Activity_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Source_Transaction_Amount_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Source_System_Code_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Unique_Transaction_Id_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Party1_NPI_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Party1_ADDRESS_LINE1_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Party1_ADDRESS_LINE2_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Party1_CITY_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Party1_State_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.Party1_ZIP_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_ST_CD_gne__c');
        fieldList.add('AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_NUM_gne__c');
        if(!Test.isRunningTest()) aController.addFields(fieldList);
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for Internal Status (depending of actual status)
    * @return List<SelectOption>
    */
    public List<SelectOption> getInternalStatuses() {
        List<SelectOption> options = new List<SelectOption>();
        if(disputeMgmtObj.Internal_Status_gne__c == 'Assigned' || disputeMgmtObj.Internal_Status_gne__c == 'In Progress') {
            options.add(new SelectOption('Assigned', 'Assigned'));
            options.add(new SelectOption('In Progress', 'In Progress'));
            options.add(new SelectOption('Resolved No Correction', 'Resolved No Correction'));
        } else if (disputeMgmtObj.Internal_Status_gne__c == 'Corrected Pending SSR') {
            options.add(new SelectOption('In Progress', 'In Progress'));
            options.add(new SelectOption('Corrected Pending SSR', 'Corrected Pending SSR'));
            options.add(new SelectOption('Resolved With Correction', 'Resolved With Correction'));
        }
        internalStatus = disputeMgmtObj.Internal_Status_gne__c;
        return options;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for Form Of Payments
    * @return List<SelectOption>
    */
    public List<SelectOption> getFormsOfPayment() {
        return AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Form_Of_Payment_gne__c.getDescribe());
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for Nature Of Payments
    * @return List<SelectOption>
    */
    public List<SelectOption> getNaturesOfPayment() {
        return AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Nature_Of_Payment_gne__c.getDescribe());
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for Communication Methods
    * @return List<SelectOption>
    */
    public List<SelectOption> getCommunicationMethods() {
        return AGS_ST_Utils.getPickListValues(AGS_ST_Dispute_Note_and_Attachment_gne__c.Communication_Method_gne__c.getDescribe());
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for Communication Types
    * @return List<SelectOption>
    */
    public List<SelectOption> getCommunicationTypes() {
        return AGS_ST_Utils.getPickListValues(AGS_ST_Dispute_Note_and_Attachment_gne__c.Communication_Type_gne__c.getDescribe());
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for Drug Names
    * @return List<SelectOption>
    */
    public List<SelectOption> getDrugNames() {
        /*
        List<SelectOption> allLstDrugNames = AGS_ST_DbUtils.getDrugNames();
        List<SelectOption> lstDrugNames = new List<SelectOption>();
        excludeNames.add('');
        excludeNames.add('-NONE-');
        excludeNames.add('All Products');
        boolean isExcluded = false;
        for(SelectOption o : allLstDrugNames){
            isExcluded = false;
            for(String n : excludeNames){
                if(n == o.getValue())
                    isExcluded = true;
            }
            if(isExcluded == false){
                lstDrugNames.add(o);
            }
        }
        return lstDrugNames;
        */
        return AGS_ST_DbUtils.getDrugNames();
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Returns the list of select options for the Dispute Owner combobox. It reads the users from the CCO group,
    * since only these can be set as the owners of the dispute management objects.
    * @return List<SelectOption>
    */
    public List<SelectOption> getDisputeOwners() {
        List<SelectOption> result = new List<SelectOption>();
        for (User u : ccoUsersList) {
            if((u.IsActive == true && u.Profile_Name_gne__c.equals('GNE-AGS-CCO-Analyst')) || u.Id == primaryOwnerId) {
                result.add(new SelectOption(u.Id, u.Name));
            }
        }
        result.sort();
        return result;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for Dispute Owner Name
    * @return String
    */
    public String getOwnerName() {
        for (User u : ccoUsersList) {
            if(u.Id == disputeOwnerId) return u.Name;
        }
        return '';
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for Activity Date
    * @return String
    */
    public String getActivityDateField() {
        return activityDate.format('M/d/yyyy h:mm a');
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Returns the list of select options for the Dispute Resolver combobox. It reads the users from the CCO group,
    * Triage Team Members Group and a Queue, since only these can be set as the resolvers of the dispute management objects.
    * @return List<SelectOption>
    */
    public List<SelectOption> getDisputeResolvers() {
        List<SelectOption> result = new List<SelectOption>();
        List<SelectOption> ccoList = new List<SelectOption>();
        for (User u : ccoUsersList) {
            if((u.IsActive == true && u.Profile_Name_gne__c.equals('GNE-AGS-CCO-Analyst')) || u.Id == primaryResolverId) {
                ccoList.add(new SelectOption(u.Id, u.Name));
            }
        }
        List<SelectOption> triageList = new List<SelectOption>();
        for (User u : triageUsersList) {
            if ((u.IsActive == true && u.Profile_Name_gne__c.equals('GNE-SYS-DataSupport')) || u.Id == primaryResolverId) {
                triageList.add(new SelectOption(u.Id, u.Name));
            }
        }
        List<SelectOption> queueList = new List<SelectOption>();
        for (Group g : queuesList) {
            queueList.add(new SelectOption(g.Id, g.Name));
        }
        ccoList.sort();
        triageList.sort();
        queueList.sort();
        result.addAll(ccoList);
        result.addAll(triageList);
        result.addAll(queueList);
        return result;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for updating Activity Date
    */
    private void refreshActivityDate() {
        this.activityDate = AGS_ST_DbUtils.getDisputeModifiedDateById(this.disputeMgmtObj.Id);
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for redirecting to Dispute List
    * @return PageReference
    */
    public PageReference goToDisputeList() {
        return new PageReference('/apex/AGS_ST_DisputeList_gne');
    }

    /* HD Decommissioning
    public PageReference refreshRelatedListInfo() {
        relatedHeldNum = AGS_ST_DbUtils.getRelatedHeldNumByDispId(disputeMgmtObj.Id);
        return null;
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for changing correction mode to non-editable
    * @return PageReference
    */
    public PageReference cancelDispute() {
        this.isEditable = false;
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for changing correction mode to editable
    * @return PageReference
    */
    public PageReference editDispute() {
        this.isEditable = true;
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for setting new Drug Name value on Dispute Detail in CCO row
    * @return PageReference
    */
    public PageReference setDrugNames() {
        String newDrugNames = '';
        for(String newDrugName : multiDrugNames) {
            if(newDrugNames.equals('')) newDrugNames = newDrugName;
            else newDrugNames += ',' + newDrugName;
        }
        if( !(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.SCh_Category_gne__c.contains('CRO') && newDrugNames.contains(',')) ){
            ccoTov.drugName = newDrugNames;
        }
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for changing dispute from Internal to External
    * @return PageReference
    */
    public PageReference changeToExternal() {
        showChangeToExtBtn = AGS_ST_DbUtils.getDMNumForSpend(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Id);
        if(stUser == null) {
            showChangeToExtBtn = 1;
        }
        if(showChangeToExtBtn<1) {
            disputeMgmtObj.isPrivate__c = false;
            AGS_ST_DisputeManagement_gne__c dm = AGS_ST_DbUtils.getDisputeIsPrivateFlagByDispId(disputeMgmtObj.Id);
            dm.isPrivate__c = false;
            update dm;
            AGS_ST_Dispute_List_gne__c dl = AGS_ST_DbUtils.getDisputeListIsPrivateFlagByDispId(disputeMgmtObj.Dispute_List_gne__c);
            dl.OwnerId = stUser.SFDC_User__r.Id;
            dl.isPrivate_gne__c = false;
            update dl;
        }
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for setting Do Not Report Flag to true
    * @return PageReference
    */
    public PageReference setDoNotReport() {
    	this.isEditable = false;
        disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.LogicalDeleteFlag_gne__c = true;
        AGS_Spend_Expense_Transaction_gne__c spendClone = AGS_ST_DbUtils.getSpendWithLogicalDeleteFlagId(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Id);
        spendClone.LogicalDeleteFlag_gne__c = true;
        update spendClone;
        List<AGS_Expense_Products_Interaction__c> prodInteractions = [SELECT LogicalDeleteFlag__c, Expense_Transaction_ID_gne__c, Id FROM AGS_Expense_Products_Interaction__c WHERE Expense_Transaction_ID_gne__c = :spendClone.Id];
        List<AGS_Expense_Products_Interaction__c> updProdInteractions = new List<AGS_Expense_Products_Interaction__c>();
        for(AGS_Expense_Products_Interaction__c p : prodInteractions){
            p.LogicalDeleteFlag__c = true;
            updProdInteractions.add(p);
        }
        update updProdInteractions;
        AGS_ST_DisputeManagement_gne__c dispmgmt = [SELECT Do_Not_Report_Flag_gne__c, Internal_Status_gne__c, Id FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :disputeMgmtObj.Id];
        dispmgmt.Do_Not_Report_Flag_gne__c = true;
        dispmgmt.Internal_Status_gne__c = 'Corrected Pending SSR';
        update dispmgmt;
        disputeMgmtObj.Internal_Status_gne__c = 'Corrected Pending SSR';
        disputeMgmtObj.External_Status_gne__c = 'Resolved';
        disputeMgmtObj.Corrected_gne__c = true;
        primaryInternalStatus = disputeMgmtObj.Internal_Status_gne__c;
        actionMessages = 'Marked as invalid transaction';
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for cancelling changes on Dispute Management Summary
    * @return PageReference
    */
    public PageReference cancelDetails() {
        disputeMgmtObj.Dispute_List_gne__r.IsCmsDispute_gne__c = primaryCmsDispute;
        disputeMgmtObj.Dispute_List_gne__r.CmsDisputeId_gne__c = primaryCmsDisputeId;
        disputeResolverId = primaryResolverId;
        disputeOwnerId = primaryOwnerId;
        disputeMgmtObj.Internal_Status_gne__c = primaryInternalStatus;
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for saving changes on Dispute Management Summary
    * @return PageReference
    */
    public PageReference saveDetails() {
        actionMessages = '';
        if(isCCOUser || isSuperUser) {
            if(disputeMgmtObj.Dispute_Resolver_gne__c == null) {
                if(disputeOwnerId != null) {
                    assignUserToOwnerAndResolver(disputeOwnerId);
                }
            } else {
                if(disputeResolverId != null && disputeOwnerId != null) {
                    disputeMgmtObj.Dispute_Resolver_gne__r.OwnerId = disputeResolverId;
                    disputeMgmtObj.OwnerId = disputeOwnerId;
                    update disputeMgmtObj;
                    update disputeMgmtObj.Dispute_Resolver_gne__r;
                    update disputeMgmtObj.Dispute_List_gne__r;
                }
                disputeMgmtObj.External_Status_gne__c = AGS_ST_DbUtils.getDisputeExternalStatusById(disputeMgmtObj.Id);
            }
        }/* TODO: Probably old code - to remove
         else {
            disputeMgmtObj.Dispute_Resolver_gne__r.OwnerId = disputeResolverId;
            update disputeMgmtObj.Dispute_Resolver_gne__r;
        }*/
        //checkPhysicianDisputeCollision();
        this.refreshActivityDate();
        actionMessages += 'Dispute data has been saved<br/>';
        if(primaryResolverId != disputeResolverId) {
            actionMessages += 'Dispute Resolver has been saved<br/>';
        }
        if(primaryOwnerId != disputeOwnerId) {
            actionMessages += 'Dispute Owner has been saved<br/>';
        }
        if(primaryInternalStatus != disputeMgmtObj.Internal_Status_gne__c) {
            actionMessages += 'Dispute Status has been saved<br/>';
        }
        primaryCmsDispute = disputeMgmtObj.Dispute_List_gne__r.IsCmsDispute_gne__c;
        primaryCmsDisputeId = disputeMgmtObj.Dispute_List_gne__r.CmsDisputeId_gne__c;
        primaryResolverId = disputeResolverId;
        primaryOwnerId = disputeOwnerId;
        primaryInternalStatus = disputeMgmtObj.Internal_Status_gne__c;
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for changing Dispute Owner and Dispute Resolver to actual logged user
    * @return PageReference
    */
    public PageReference assignToMe() {
        if(disputeMgmtObj.Internal_Status_gne__c == 'Submitted') {
            disputeOwnerId = Userinfo.getUserId();
        } else {
            disputeResolverId = Userinfo.getUserId();
        }
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for changing Dispute Owner and Dispute Resolver to selected user
    * @param Id userId
    */
    public void assignUserToOwnerAndResolver(Id userId) {
        disputeResolverId = userId;
        disputeOwnerId = userId;

        if(disputeMgmtObj.Dispute_Resolver_gne__c == null) {
            AGS_ST_DisputeResolver_gne__c newResolver = new AGS_ST_DisputeResolver_gne__c();
            newResolver.OwnerId = disputeResolverId;
            insert newResolver;
            disputeMgmtObj.Dispute_Resolver_gne__c = newResolver.Id;
            disputeMgmtObj.Dispute_Resolver_gne__r = AGS_ST_DbUtils.getResolverById(newResolver.Id);
        } else {
            disputeMgmtObj.Dispute_Resolver_gne__r.OwnerId = disputeResolverId;
            update disputeMgmtObj.Dispute_Resolver_gne__r;
        }
        disputeMgmtObj.OwnerId = disputeOwnerId;
        if (disputeMgmtObj.Internal_Status_gne__c == 'Submitted') {
            disputeMgmtObj.Internal_Status_gne__c = 'Assigned';
        }
        update disputeMgmtObj;
        this.refreshActivityDate();
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for getting and creating Transfer of Values (Original and Dispute Transaction Types)
    * @return List<TransferOfValueClass>
    */
    public List<TransferOfValueClass> getTransferOfValues() {
        List<TransferOfValueClass> transferOfValuesList = new List<TransferOfValueClass>();
        transferOfValuesList.add(new TransferOfValueClass('Original', disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c, this.disputeMgmtObj.Orig_Allocated_Transaction_Amount_gne__c, this.disputeMgmtObj.Orig_Form_Of_Payment_gne__c, this.disputeMgmtObj.Orig_Nature_Of_Payment_gne__c, disputeMgmtObj.Orig_Drug_Name_gne__c, disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.CreatedDate,this.disputeMgmtObj.Orig_Source_Transaction_Amount_gne__c,false,this.disputeMgmtObj.Orig_Event_Actual_Attendee_Count_gne__c,String.valueOf(this.disputeMgmtObj.Orig_Event_Planned_Attendee_Count_gne__c)));
        //transferOfValuesList.add(new TransferOfValueClass('Original', disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c, disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Allocated_Transaction_Amount_gne__c, disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Form_Of_Payment_gne__c, disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Nature_Of_Payment_gne__c, epi, disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.CreatedDate,disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Source_Transaction_Amount_gne__c,false,disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Event_Actual_Attendee_Count_gne__c,String.valueOf(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Event_Planned_Attendee_Count_gne__c)));
        transferOfValuesList.add(new TransferOfValueClass('Dispute', disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c, disputeMgmtObj.Dispute_List_gne__r.Amount_gne__c, disputeMgmtObj.Dispute_List_gne__r.Form_Of_Payment_gne__c, disputeMgmtObj.Dispute_List_gne__r.Nature_Of_Payment_gne__c, disputeMgmtObj.Dispute_List_gne__r.Drug_Name_gne__c, disputeMgmtObj.Dispute_List_gne__r.CreatedDate,0,false,0,''));

        return transferOfValuesList;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Class used to hold the data for Transfer Of Value section rows.
    */
    public class TransferOfValueClass {
        public String transactionType { get; set; }
        public String paymentDate { get; set; }
        public Decimal amount { get; set; }
        public String formOfPayment { get; set; }
        public String natureOfPayment { get; set; }
        public String drugName { get; set; }
        public DateTime activityDate { get; set; }
        public Decimal mealAmount { get; set; }
        public Boolean optOut { get; set; }
        public Integer attendeeCount { get; set; }
        public String plannedAttendeeCount { get; set; }

        public String getActivityDateField() {
            return activityDate.format('M/d/yyyy h:mm a');
        }

        public TransferOfValueClass(String transactionTypeVal, Date paymentDateVal, Decimal amountVal, String formOfPaymentVal, String natureOfPaymentVal, String drugNameVal, DateTime activityDateVal,Decimal mealAmountVal,Boolean optOutVal,Decimal attendeeCountVal,String plannedAttendees) {
            if(paymentDateVal == null) {
                paymentDate = '';
            } else {
                Datetime dt = paymentDateVal;
                paymentDate = dt.formatGmt('M/d/yyyy');
            }
            plannedAttendeeCount = plannedAttendees;
            transactionType = transactionTypeVal;
            amount = amountVal;
            if(formOfPaymentVal == null) {
                formOfPayment = 'UNCLASSIFIED';
            } else {
                formOfPayment = formOfPaymentVal;
            }
            if(natureOfPaymentVal == null) {
                natureOfPayment = 'UNCLASSIFIED';
            } else {
                natureOfPayment = natureOfPaymentVal;
            }
            drugName = drugNameVal;
            activityDate = activityDateVal;
            mealAmount = mealAmountVal;
            optOut = optOutVal;
            attendeeCount = Integer.valueOf(attendeeCountVal);
        }
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for getting and setting new values on Physician Dispute List
    */
    /*
    public void checkPhysicianDisputeCollision() {
        isCollision = AGS_ST_DbUtils.isDisputeCollision(disputeMgmtObj.Dispute_List_gne__r.OwnerId, disputeResolverId);
    }
    */

    @RemoteAction
    global static Boolean isCollisionCheck(String physicianId, String disputeResolverId, String thisDisputeId) {
        return AGS_ST_DbUtils.isDisputeCollision(physicianId, disputeResolverId, thisDisputeId);
    }

    /** @date 24/9/2014
    * @Author Konrad Malinowski
    * @description Method for checking CMS Dispute ID uniqueness
    * @param String cmsDisputeId
    * @param String disputeId
    * @return Boolean
    */
    @RemoteAction
    global static Boolean isCmsDisputeIdUnique(String cmsDisputeId, String disputeId) {
        return AGS_ST_DbUtils.isCmsDisputeIdUnique(cmsDisputeId, disputeId);
    }

    /** @date 24/9/2014
    * @Author Konrad Malinowski
    * @description Method for isCmsDispute checkbox change
    * @return PageReference
    */
    public PageReference isCmsDisputeOnChange() {
        disputeMgmtObj.Dispute_List_gne__r.CmsDisputeId_gne__c = null;
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for cleaning Note boxes
    * @return PageReference
    */
    public PageReference clearNewNote() {
        noteValue = '';
        noteCommunicationMethod = '';
        noteCommunicationType = '';
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for adding new Note and Attachment
    * @return PageReference
    */
    public PageReference addNewNoteAndAttachment() {
        List<Attachment> attachmentsToAdd = new List<Attachment>();
        Integer attachmentCount = 0;
        if(attachment1.body != null) attachmentCount++;
        checkAndAddAttachment(attachment1, attachmentsToAdd);
        if(attachment2.body != null) attachmentCount++;
        checkAndAddAttachment(attachment2, attachmentsToAdd);
        if(attachment3.body != null) attachmentCount++;
        checkAndAddAttachment(attachment3, attachmentsToAdd);
        if(attachment4.body != null) attachmentCount++;
        checkAndAddAttachment(attachment4, attachmentsToAdd);
        if(attachment5.body != null) attachmentCount++;
        checkAndAddAttachment(attachment5, attachmentsToAdd);
        if(noteValue != '' && attachmentsToAdd.size() == attachmentCount) {
            AGS_ST_Dispute_Note_and_Attachment_gne__c newNoteAndAttachment = new AGS_ST_Dispute_Note_and_Attachment_gne__c();
            newNoteAndAttachment.AGS_ST_Dispute_Management_gne__c = disputeMgmtObj.Id;
            if(userProfile.Name == 'GNE-SYS-DataSupport') {
                newNoteAndAttachment.isPrivate_gne__c = true;
            } else {
                newNoteAndAttachment.isPrivate_gne__c = isPrivateNote;
            }
            if(!isPrivateNote && noteCommunicationMethod!='' && noteCommunicationMethod!=null) {
                newNoteAndAttachment.Communication_Method_gne__c = noteCommunicationMethod;
                newNoteAndAttachment.Communication_Type_gne__c = noteCommunicationType;
                newNoteAndAttachment.Communication_Date_gne__c = noteDate.Communication_Date_gne__c;
                newNoteAndAttachment.Dispute_Status_gne__c = disputeMgmtObj.External_Status_gne__c;
            }
            insert newNoteAndAttachment;

            if(noteValue != '') {
                Note newNote = new Note();
                newNote.Body = noteValue;
                if(isPrivateNote == true) {
                    newNote.Title = 'Internal Note';
                } else {
                    newNote.Title = 'External Note';
                }
                newNote.IsPrivate = false;
                newNote.parentId = newNoteAndAttachment.Id;
                insert newNote;

                clearNewNote();
            }
            if(attachmentsToAdd.size() > 0) {
                for(Integer i = 0; i < attachmentsToAdd.size(); i++) {
                    attachmentsToAdd[i].parentId = newNoteAndAttachment.Id;
                }

                try {
                    insert attachmentsToAdd;
                    for(Attachment att : attachmentsToAdd) {
                        att.body = null;
                    }
                } catch (DMLException e) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error while uploading attachment'));
                    return null;
                } finally {
                    attachment1 = new Attachment();
                    attachment2 = new Attachment();
                    attachment3 = new Attachment();
                    attachment4 = new Attachment();
                    attachment5 = new Attachment();
                    attachmentsToAdd.clear();
                }
            }
            setNotesAndAttachments();
            setExternalNotes();
            actionMessages = 'New Note has been added<br/>';
        }
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for checking Attachment size
    * @param Attachment attachment
    * @param List<Attachment> attachmentsList
    * @return Boolean
    */
    private Boolean checkAndAddAttachment(Attachment attachment, List<Attachment> attachmentsList) {
        if(attachment.BodyLength > 0) {
            if(attachment.BodyLength < 5242880) {
                attachment.Description = 'Internal Attachment';
                attachment.OwnerId = UserInfo.getUserId();
                attachment.IsPrivate = false;
                if(attachmentsList != null) {
                    attachmentsList.add(attachment);
                }
                return true;
            } else {
                attachment.Body = null;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This file exceeds the maximum size limit of 5MB.'));
                return false;
            }
        }
        return false;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for getting Email Templates
    * @return List<SelectOption>
    */
    public List<SelectOption> getEmailTemplates()
    {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', 'Free Form'));
        for(AGS_ST_Email_Templates_gne email:emailTemplates.values())
        {
            if(!'Resolve dispute'.equals(email.name)) {
                result.add(new SelectOption(email.api_name, email.name));
        	}
        }
        return result;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for getting Email Templates for Resolution
    * @return List<SelectOption>
    */
    public List<SelectOption> getEmailTemplatesResolution()
    {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', 'Free Form'));
        result.add(new SelectOption(emailTemplates.get('Resolution').api_name, emailTemplates.get('Resolution').name));
        return result;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for getting Dispute Owner Proxy
    * @return List<SelectOption>
    */
    public List<SelectOption> getownerProxy()
    {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption(disputeMgmtObj.Dispute_List_gne__r.Owner.username,'HCP ' + disputeMgmtObj.Dispute_List_gne__r.Owner.Name));
        if(disputeMgmtObj.Dispute_List_gne__r.AGS_ST_Proxy_gne__c != null) {
            result.add(new SelectOption(disputeMgmtObj.Dispute_List_gne__r.AGS_ST_Proxy_gne__r.User_gne__r.username, 'Proxy ' + disputeMgmtObj.Dispute_List_gne__r.AGS_ST_Proxy_gne__r.User_gne__r.Name));
        }
        return result;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description All Disputes for this Physician to date -> Getter for list
    * @return List<DisputeNotesAttachments>
    */
    public List<DisputeNotesAttachments> getDisputeAllNotesInOrder() {
        if(!noteAndAttachUtil.compareValues()) {
            setNotesAndAttachments();
            setExternalNotes();
            noteAndAttachUtil.duplicateValues();
        }
        return disputeAllNotes;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for getting all Notes and Attachments for dispute and converting them to DisputeNotesAttachments wrapper class
    */
    private void setNotesAndAttachments() {
        disputeAllNotes.clear();
        tovNote = null;
        List<AGS_ST_Dispute_Note_and_Attachment_gne__c> notesAndAtt = AGS_ST_DbUtils.getDisputeNotesAndAtt(disputeMgmtObj.Id, noteAndAttachUtil.sortField, noteAndAttachUtil.sortOrder);
        Set<Id> naIds = new Set<Id>();
        for(AGS_ST_Dispute_Note_and_Attachment_gne__c na:notesAndAtt) {
            naIds.add(na.id);
        }
        List<Attachment> listAttchmnts = [SELECT Id, ParentId FROM Attachment WHERE ParentId in :naIds];
        Map<String,Note> notes = AGS_ST_DbUtils.getNotesByNotesAndAttachments(naIds);
        for(AGS_ST_Dispute_Note_and_Attachment_gne__c na : notesAndAtt) {
            if(na.About_gne__c == '' || na.About_gne__c == null) {
                DisputeNotesAttachments dna = new DisputeNotesAttachments();
                dna.dnaObject = na;
                dna.CommunicationType = na.Communication_Type_gne__c;
                dna.hasAttachments = false;
                for(Attachment att : listAttchmnts){
                    if(att.ParentId == na.Id) dna.hasAttachments = true;
                }
                if(notes.get(na.id) != null) {
                    dna.note = notes.get(na.id);
                }
                disputeAllNotes.add(dna);
            } else {
                DisputeNotesAttachments dna = new DisputeNotesAttachments();
                dna.About = na.About_gne__c;
                dna.hasAttachments = false;
                for(Attachment att : listAttchmnts){
                    if(att.ParentId == na.Id) dna.hasAttachments = true;
                }
                if(notes.get(na.id) != null) {
                    dna.note = notes.get(na.id);
                }
                tovNote = dna;
            }
        }
        noteAndAttachUtil.setParameters(disputeAllNotes.size());
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for setting new values in External Note List
    */
    private void setExternalNotes() {
        disputeExternalNotes.clear();
        for(DisputeNotesAttachments dna : disputeAllNotes) {
            if(!dna.dnaObject.isPrivate_gne__c) {
                disputeExternalNotes.add(dna);
            }
        }
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for invoking sending email method
    * @return PageReference
    */
    public PageReference sendExternalEmail() {
        if(attachmentEmail.body!=null && !checkAndAddAttachment(attachmentEmail,null)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot send email: Attachment exceeds the maximum size limit of 5MB.'));
        } else {
            sendHcpEmail(attachmentEmail, email_type, externalEmailBody, emailSubject, false, emailRecipients);
            actionMessages = 'New Email has been sended<br/>';
            emailSubject = '';
            externalEmailBody = '';
            email_type = '';
        }
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for resolving particular dispute
    * @return PageReference
    */
    public PageReference resolveDispute() {
        if(!disputeMgmtObj.isPrivate__c) {
            if(isHcpCommunicated) {
                AGS_ST_Dispute_Note_and_Attachment_gne__c noteAtt = new AGS_ST_Dispute_Note_and_Attachment_gne__c();
                for(DisputeNotesAttachments dna :disputeExternalNotes) {
                    if(dna.isSelected) {
                        noteAtt = AGS_ST_DbUtils.getDisputeNotesAndAttById(dna.dnaObject.id);
                    }
                }
                noteAtt.Dispute_Status_gne__c = 'Resolved';
                try {
                    update noteAtt;
                } catch (DMLException e) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No communication method was selected.'));
                    return null;
                }
            } else {
                if(attachmentEmailResolution.body!=null && !checkAndAddAttachment(attachmentEmailResolution,null)) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot send email: Attachment exceeds the maximum size limit of 5MB.'));
                    return null;
                } else {
                    sendHcpEmail(attachmentEmailResolution,email_type_resolution,externalEmailBodyResolution,emailSubject,true,emailRecipientsResolution);
                }
            }
        }
        if(inputStatus =='Resolved No Correction') {
            disputeMgmtObj.Internal_Status_gne__c = 'Resolved No Correction';
            update disputeMgmtObj;
        } else {
            updateDispute();
        }
        numOpenSpends = AGS_ST_DbUtils.getDMNumForSpend(disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__c);
        PageReference pr = new PageReference('/apex/AGS_ST_DisputeDetail_gne?id='+disputeMgmtObj.id+'&com=1');
        pr.setRedirect(true);
        return pr;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for updating values of Dispute after Resolving
    */
    public void updateDispute() {
        this.isEditable = false;
        disputeMgmtObj.Amount_gne__c = Decimal.valueOf(amountHidden.replace('$','').replace(',',''));
        disputeMgmtObj.Form_Of_Payment_gne__c = fopHidden;
        disputeMgmtObj.Nature_Of_Payment_gne__c = nopHidden;
        if(brandHidden.contains('[') && brandHidden.contains(']')) {
            disputeMgmtObj.Drug_Name_gne__c = brandHidden.substring(1, brandHidden.length()-1);
        } else {
            disputeMgmtObj.Drug_Name_gne__c = brandHidden;
        }
        disputeMgmtObj.Source_Amount_gne__c = Decimal.valueOf(groupAmountHidden.replace('$',''));
        disputeMgmtObj.Opt_Out_gne__c = Boolean.valueOf(optOutHidden);
        disputeMgmtObj.Attendees_gne__c = Integer.valueOf(attendeesHidden);
        disputeMgmtObj.Internal_Status_gne__c = 'Corrected Pending SSR';
        update disputeMgmtObj;
        if (this.disputeMgmtObj.Dispute_Resolver_gne__r != null) {
            update this.disputeMgmtObj.Dispute_Resolver_gne__r;
        }
        this.refreshActivityDate();
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for sending Email to HCP
    * @param Attachment emailAtt
    * @param String emailType
    * @param String emailBody
    * @param String emailSubject
    * @param Boolean isResolution
    * @param List<String> emailRecipientsList
    */
    private void sendHcpEmail(Attachment emailAtt, String emailType, String emailBody, String emailSubject, Boolean isResolution, List<String> emailRecipientsList) {
        //Email validation
        List<String> emailRecipients = new List<String>();
        for(String emailRecip : emailRecipientsList) {
            if(AGS_ST_Utils.validateEmail(emailRecip)) {
                emailRecipients.add(emailRecip);
            }
        }
        AGS_ST_DisputeManagement_gne__c orgDisputeDetails = AGS_ST_DbUtils.getDisputeDetailsByDisputeManagementId(this.disputeMgmtObj.Id);
        if(emailRecipients.size() < 1) {
            if(orgDisputeDetails.Preferred_communication_method_gne__c == 'Email' && AGS_ST_Utils.validateEmail(orgDisputeDetails.Preferred_communication_value_gne__c)) {
                emailRecipients.add(orgDisputeDetails.Preferred_communication_value_gne__c);
            } else if(AGS_ST_Utils.validateEmail(orgDisputeDetails.Dispute_List_gne__r.owner.username)) {
                emailRecipients.add(orgDisputeDetails.Dispute_List_gne__r.owner.username);
            }
        }
        if(emailRecipients.size() < 1) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot send email: No valid recipient email'));
        } else {
            try {
                // Sending email
                if(emailAtt.body != null) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setBody(emailAtt.Body);
                    efa.setFileName(emailAtt.Name);
                    Messaging.SendEmailResult email = AGS_ST_MailUtil.sendExternalEmail(emailTemplates.get(emailType),emailBody,emailSubject,efa,orgDisputeDetails,emailRecipients);
                } else {
                    Messaging.SendEmailResult email = AGS_ST_MailUtil.sendExternalEmail(emailTemplates.get(emailType),emailBody,emailSubject,null,orgDisputeDetails,emailRecipients);
                }
                // Adding extra information to body
                if(emailSubject != null && !emailSubject.equals('')) {
                    emailBody = 'Subject: ' + emailSubject + '\n\n' + emailBody;
                }
                emailBody += '\n\n Sent to: ' + emailRecipients;
                // Saving note
                if(emailTemplates.get(emailType) == null) {
                    saveEmailAsNote(emailBody,emailAtt,disputeMgmtObj.Id,DateTime.Now(),null,false,isResolution,emailRecipients);
                } else {
                    saveEmailAsNote(emailBody,emailAtt,disputeMgmtObj.Id,DateTime.Now(),emailTemplates.get(emailType).name,false,isResolution,emailRecipients);
                }
                emailAtt = null;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot send email.'));
            }
        }
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for saving sended emails
    * @param String emailBody
    * @param Attachment attachmentEmail
    * @param Id disputeId
    * @param DateTime emailDate
    * @param String emailType
    * @param Boolean isPrivate
    * @param Boolean isResolution
    * @param List<String> emailRecipients
    */
    private void saveEmailAsNote(String emailBody, Attachment attachmentEmail,Id disputeId, DateTime emailDate, String emailType, Boolean isPrivate, Boolean isResolution,List<String> emailRecipients) {
        AGS_ST_Dispute_Note_and_Attachment_gne__c newNoteAndAttachment = new AGS_ST_Dispute_Note_and_Attachment_gne__c();
        newNoteAndAttachment.AGS_ST_Dispute_Management_gne__c = disputeId;
        newNoteAndAttachment.Communication_Date_gne__c = emailDate;
        newNoteAndAttachment.Communication_Method_gne__c = 'Email';
        newNoteAndAttachment.Communication_Type_gne__c = 'To Physician';
        if(isResolution) {
            newNoteAndAttachment.Dispute_Status_gne__c = 'Resolved';
        } else {
            newNoteAndAttachment.Dispute_Status_gne__c = disputeMgmtObj.External_Status_gne__c;
        }
        newNoteAndAttachment.Email_Type_gne__c = emailType;
        newNoteAndAttachment.isPrivate_gne__c = isPrivate;
        for(integer i=0; i<emailRecipients.size();i++) {
            newNoteAndAttachment.Email_Recipients_gne__c =+ emailRecipients[i] + ',';
        }
        insert newNoteAndAttachment;

        Note newNote = new Note();
        newNote.Body = emailBody;
        newNote.Title = 'Email';
        newNote.IsPrivate = isPrivate;
        newNote.parentId = newNoteAndAttachment.Id;
        insert newNote;
        if(attachmentEmail.body != null) {
            try {
                attachmentEmail.parentId = newNoteAndAttachment.Id;
                insert attachmentEmail;
                attachmentEmail.body = null;
            } catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error while uploading attachment'));
            } finally {
                attachmentEmail = new Attachment();
            }
        }
        setNotesAndAttachments();
        setExternalNotes();
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for changing email body
    * @return PageReference
    */
    public PageReference changeBody() {
        emailSubject = '';
        if(email_type != '' && email_type != null ) {
            externalEmailBody = emailTemplates.get(email_type).body;
        } else {
            externalEmailBody = '';
        }
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for changing resolution email body
    * @return PageReference
    */
    public PageReference changeBodyResolution() {
        emailSubject = '';
        emailTemplates = new AGS_ST_Email_Templates_gne(cbrFOP, cbrNOP, cbrDrug, cbrAmount).getEmailTemplates(disputeMgmtObj.Id);
        if(email_type_resolution != '' && email_type_resolution != null ) {
            externalEmailBodyResolution = emailTemplates.get(email_type_resolution).body;
        } else {
            externalEmailBodyResolution = '';
        }
        return null;
    }

    /** @date 7/14/2014
    * @Author Konrad Malinowski
    * @description Method for saving Dispute Explanation
    * @return PageReference
    */
    public PageReference saveDisputeExplanation() {
        if( String.isBlank(diputeExplanationToEdit) ) {
            return null;
        }
        if(tovNote != null) {
            tovNote.Note.Body = diputeExplanationToEdit;
            update tovNote.Note;
        } else {
            AGS_ST_DbUtils.saveDisputeNotesFromDisputeId(disputeMgmtObj.Id, diputeExplanationToEdit, 'HCP Dispute');
            setNotesAndAttachments();
        }
        return null;
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Dispute Note and Attachment wrapper class
    */
    public class DisputeNotesAttachments {
        public String CommunicationType {
            get {
                if(dnaObject.Communication_Method_gne__c == null || dnaObject.Communication_Method_gne__c == '') {
                    return '';
                } else {
                    return CommunicationType;
                }
            }
            set;
        }
        public String About {get;set;}
        public String getCommunicationDateFormat() {
            if(dnaObject.Communication_Date_gne__c != null) {
                return dnaObject.Communication_Date_gne__c.format('M/d/yyyy h:mm a');
            } else {
                return '';
            }
        }
        public String NoteTxt{
            get{
                if(note != null && note.Body != null) {
                    if(note.Body.length() >= 100) {
                        return note.Body.substring(0,100)+'...';
                    } else {
                        return note.Body.substring(0,note.Body.length());
                    }
                } else {
                    return '';
                }
            }
        }
        public Note note {get;set;}
        public AGS_ST_Dispute_Note_and_Attachment_gne__c dnaObject {get;set;}
        public Boolean isSelected {get;set;}
        public Boolean hasAttachments {get; set;}
    }
}