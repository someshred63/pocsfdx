/*
* @author ADMD GFRS Dev Team
* @date 08/20/2013
* @description Controller for Organization info page 
*/
public with sharing class gFRS_OrgInfoController {

    public static final String CONTENT_TYPE = 'Organization';
    public static final String PATH_COMPLETE = '/apex/GFRS_Decision';
    public static final String PATH_COMPLETE_VIEW = '/apex/GFRS_Application';
    public static final String ORG_TYPE_PRIV_PHYSICIAN = 'Private physician office';
    public static final String ORG_TYPE_GROUP_PRACTICE = 'Group practice';
    public static final String ORG_TYPE_INDIVIDUAL = 'Individual';
    public static final String ORG_TYPE_POL_ORG = 'Political organization';
    public static final String ORG_TYPE_SECT_ORG = 'Sectarian organization';
    public static final String PATH_HOME = '/apex/gFRS_Home'; /** Page to move to when moving 'back' **/
    public static final String PATH_ORG_A = '/apex/gFRS_Org_Info';  /** Page to move to the first org info section **/
    public static final String PATH_ORG_B = '/apex/gFRS_org_Info_File'; /** Page to move to the second org info section **/
    public static final String PATH_INV_ORG = '/apex/gFRS_Error?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=';  /** Path to the Invalid organization **/
    public static final String PARAM_TAX_ID = 'taxId'; /** GET parameter name for the Organization taxId to work with **/
    public static final String PARAM_ORG_ID = 'org'; /** GET parameter name for the Organization id to work with **/
    public static final String PARAM_LOCATION_ID = 'loc'; /** GET parameter name for the Location id to work with **/
    public static final String PARAM_SOC = 'soc'; /** GET parameter name for stop on complete **/
    public static final String PARAM_SHOW = 'show'; /** GET parameter name for show (currently defaults to show current org) **/
    public static final String CHFoundationType = 'Charitable Foundation';

    private GFRS_OrgSettings__c myGFRSOrgSettings = GFRS_OrgSettings__c.getOrgDefaults();
    public GFRS_Funding_Request__c fundReq { get; set; } /** Funding request being modified **/
    public GFRS_Location__c[] lLocs { get; set; } /** Locations being used **/
    public GFRS_Location__c currentLocation { get; set; } /** Current location to be updated **/
    public GFRS_Organization__c organization { get; set; } /** Organization to work with **/
    public Contact userContact = null; /** contact that represents the current user (if applicable) **/
    public Attachment w9FormAttachment { get; set; }
    public Attachment taxStatus501DeterminationLetterAttachment { get; set; }
    public Attachment form990Attachment { get; set; }
    public Map<String, String> contentItems { get; set; } /** Translations organized by their Name/Keys **/

    public Boolean isRFI { get; set; }
    public Boolean isEditable { get; set; }
    public Boolean isLocationEditable { get; set; }
    public Boolean isLocationSelectable { get; set; }
    public Boolean isInternalUser { get; set; }
    public Boolean isDescriptionEditable { get; set; }
    public Boolean isAnnualBudgetEditable { get; set; }
    public Boolean annualBudgetMandatory { get; set; }
    public Boolean IsCharitableFundation { get; set; }
    public Boolean shouldStopOnComplete { get; set; }/** True if the page should stop on completion of the page **/
    public Boolean isTaxInfoEditable { get; set; }  /** Whether the tax information is no longer editable This is no longer editable if the user is assigned to an organization**/
    public Boolean IsCHValueYes { get; set; }

    public Integer currentIndex { get; set; } /** Current accordion index only applicable if all organization information has been found**/
    public String selectedLocation { get; set; } /** The selected location **/
    public String serializedLocationForm { get; set; }/** Serialized location form **/
    public String initialOrgType { get; set; }
    public String orgType { get; set; }
    public String orgTypeValue { get; set; }
    public String IsCHValue { get; set; }

    public String org { get; set; }

    public Boolean isOrgUsBasedAndForProfit {
        get {
            if (this.organization.US_Organization__c == 'Yes' && this.organization.Tax_Status__c == 'For-Profit') {
                return true;
            } else {
                return false;
            }
        }
        set;
    }

    public Boolean isOrgExternal {
        get {
            return(this.organization.RecordType != null && gFRS_Util.RT_ORG_EXTERNAL.equals(this.organization.RecordType.DeveloperName));
        }
    }

    public Boolean isLocationExternal {
        get {
            return(this.currentLocation != null && this.currentLocation.RecordType != null && gFRS_Util.RT_LOC_EXTERNAL.equals(this.currentLocation.RecordType.DeveloperName));
        }
    }

    public Boolean isFundingTypeExternal {
        get {
            return(String.isBlank(this.fundReq.Record_Type_Name__c)
                    || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME
                    || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME
                    || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME
                    || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME
                    || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME
            );
        }
    }

    public Boolean isW9Editable {
        get {
            return true;
        }
    }

    /** determines whether the page currently has messages **/
    public Boolean hasMessages {
        get {
            return(ApexPages.hasMessages());
        }
    }

    /** True if organization already exists **/
    public Boolean organizationExists {
        get {
            return(this.organization != null && this.organization.Id != null);
        }
    }

    public Boolean locationExists {
        get {
            return(this.currentLocation != null && this.currentLocation.Id != null);
        }
    }

    /** Whether the current organization is US Based **/
    public Boolean isUSBased {
        get {
            return(this.organization == null
                    || this.organization.Country__c == null
                    || IsUSBasedOrg(this.organization.Country__c));
        }
    }

    public Boolean isW9Attached {
        get {
            return ((this.w9FormAttachment != null && this.w9FormAttachment.Id != null) ? true : false);
        }
    }

    public Boolean isTaxStatus501DeterminationLetterAttached {
        get {
            return ((this.taxStatus501DeterminationLetterAttachment != null && this.taxStatus501DeterminationLetterAttachment.Id != null) ? true : false);
        }
    }

    public Boolean isForm990Attached {
        get {
            return ((this.form990Attachment != null && this.form990Attachment.Id != null) ? true : false);
        }
    }

    public String getW9PageUrl {
        get {
            if (organizationExists && locationExists) {
                return(gFRS_Util.initializeLink(PATH_ORG_B, this.fundReq, PARAM_ORG_ID + '=' + String.valueOf(this.organization.Id) + '&' + PARAM_LOCATION_ID + '=' + String.valueOf(this.currentLocation.Id)));
            } else {
                return null;
            }
        }
    }

    public String getOrgTaxIdSectionUrl {
        get {
            this.currentIndex = 0;
            String params = '';
            params = gFRS_Util.PARAM_CURRENT_INDEX + '=0&' + PARAM_ORG_ID + '=' + String.valueOf(this.organization.Id) + '&' + PARAM_LOCATION_ID + '=' + String.valueOf(this.currentLocation.Id);
            return(gFRS_Util.initializeLink(PATH_ORG_A, this.fundReq, params));
        }
    }

    public String getOrgDetailSectionUrl {
        get {
            this.currentIndex = 1;
            String params = '';
            params = gFRS_Util.PARAM_CURRENT_INDEX + '=1&' + PARAM_ORG_ID + '=' + String.valueOf(this.organization.Id) + '&' + PARAM_LOCATION_ID + '=' + String.valueOf(this.currentLocation.Id);
            return(gFRS_Util.initializeLink(PATH_ORG_A, this.fundReq, params));
        }
    }

    public String getLocationSelectSectionUrl {
        get {
            this.currentIndex = 3;
            String params = '';
            params = gFRS_Util.PARAM_CURRENT_INDEX + '=3&' + PARAM_ORG_ID + '=' + String.valueOf(this.organization.Id) + '&' + PARAM_LOCATION_ID + '=' + String.valueOf(this.currentLocation.Id);
            return(gFRS_Util.initializeLink(PATH_ORG_A, this.fundReq, params));
        }
    }

    public Boolean isExtenralHolderAccount {
        get {
            return (this.userContact != null && this.userContact.Account.Id == (gFRS_Util.getCustomSettingStringValue('Portal_Account_ID') == null ? System.Label.GFRS_HOLDING_ACCOUNT : gFRS_Util.getCustomSettingStringValue('Portal_Account_ID')));
        }
    }

    public gFRS_OrgInfoController Instance {
        get {
            return this;
        }
    }

    public Boolean isUserExternal { get {return gFRS_Util_NoShare.checkIfUserIsExternalRequester(UserInfo.getProfileId());} private set; }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Main contructor class
        * 
        */
    public gFRS_OrgInfoController(ApexPages.StandardController std) {
        Id organizationId = null;
        Id locationId = null;

        if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('UserInfo.getUserId()->' + UserInfo.getUserId());

        this.userContact = gFRS_Util_NoShare.getUserContact(UserInfo.getUserId());
        this.isInternalUser = userContact == null;

        if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('this.isInternalUser =' + this.isInternalUser);

        this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter(CONTENT_TYPE, UserInfo.getLanguage());

        this.fundReq = (GFRS_Funding_Request__c) std.getRecord();

        if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('this.fundReq.id=' + this.fundReq.Id);

        //query for retrieving field used below
        if (this.fundReq.Id != null) {
            this.fundReq = [SELECT Id, External_Sub_status__c,Status__c, Information_Needed__c, Organization__c, Location__c, Record_Type_Name__c, RecordTypeId, Requested_Amount__c, Total_Program_Budget__c, Sub_Status__c,Authorized_Signer__c, Signing_Authority_Email__c FROM GFRS_Funding_Request__c WHERE Id = :THIS.fundReq.Id];
            organizationId = this.fundReq.Organization__c;
            locationId = this.fundReq.Location__c;
            if (this.fundReq.Information_Needed__c != null && this.fundReq.External_Sub_status__c == 'RFI') {
                isRFI = true;
            } else {
                isRFI = false;
            }

            if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('this.fundReq.Id=' + this.fundReq.Id + '|organizationId=' + organizationId + '|locationId=' + locationId + '|isRFI=' + isRFI);
        }

        if (organizationId == null) organizationId = getSentTaxId();
        if (locationId == null) locationId = getSentLocationId();
        this.selectedLocation = String.valueOf(locationId);

        if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('organizationId=' + organizationId + '|locationId=' + locationId + '|this.selectedLocation=' + this.selectedLocation);

        if (organizationId != null) this.organization = fetchOrganizationById(organizationId);

        //http://jira.intranet.roche.com/jira/browse/SFDC-1507
        if (myGFRSOrgSettings.TraceOrgInfoController__c) {
            System.debug('this.organization.Country__c=' + this.organization.Country__c);
            System.debug('this.organization=' + this.organization);
            System.debug('this.organization.W9_Form_W_8BEN_Form__c=' + this.organization.W9_Form_W_8BEN_Form__c);
        }

        if (this.organization != null) {
            GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector(this.organization.Attachments);
            this.w9FormAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(this.organization.W9_Form_W_8BEN_Form__c, this.organization.Id);
            this.taxStatus501DeterminationLetterAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(this.organization.Tax_Status_501_c_3_Determination_Letter__c, this.organization.Id);
            this.form990Attachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(this.organization.Form_990__c, this.organization.Id);
        }

        if (myGFRSOrgSettings.TraceOrgInfoController__c) {
            System.debug('this.w9FormAttachment.id=' + this.w9FormAttachment.Id);
            System.debug('this.w9FormAttachment.name=' + this.w9FormAttachment.Name);
        }

        SetupCHFoundationDynaFields();
        if (this.organization == null) resetOrganization();

        this.selectedLocation = null;
        fetchLocation(locationId);

        /*--
        We want the organization to be editable if there was no funding request,
        or the funding request is new, or that the funding request needs information
        from the organization.
        It is acceptable that once they have found a tax id, they cannot enter a new one.
        --*/
        refreshAccordionVisibility();

        this.currentIndex = 0;

        if (this.organization != null && this.organization.Id != null &&
                this.currentLocation != null && this.currentLocation.Id != null
                ) {
            this.currentIndex = gFRS_Util.getCurrentIndex();
        }

        this.shouldStopOnComplete = false;

        Map<String, String> params = ApexPages.currentPage().getParameters();
        if (params != null) {
            if (params.containsKey(PARAM_SOC)) this.shouldStopOnComplete = true;
        }

        setIsUSBasedPickList(); //set US_Organization__c picklist flag

        if (myGFRSOrgSettings.TraceOrgInfoController__c) {
            System.debug('System.Label.GFRS_HOLDING_ACCOUNT=' + (gFRS_Util.getCustomSettingStringValue('Portal_Account_ID') == null ? System.Label.GFRS_HOLDING_ACCOUNT : gFRS_Util.getCustomSettingStringValue('Portal_Account_ID')));
            System.debug('this.userContact=' + userContact);
            System.debug('this.isOrgExternal=' + this.isOrgExternal);
            System.debug('this.organization.RecordTypeId=' + this.organization.RecordTypeId);
            System.debug('this.isEditable=' + this.isEditable);
            System.debug('this.isLocationEditable=' + this.isLocationEditable);
            System.debug('this.isLocationSelectable=' + this.isLocationSelectable);
            System.debug('this.isTaxInfoEditable=' + this.isTaxInfoEditable);
        }
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Determines the id of the organization based on the taxid or organization id
        * 
        */
    public Id fetchOrganizationByTaxOrOrg(Boolean useTaxId, String taxId, String organizationId) {
        GFRS_Organization__c result = null;
        try {
            if (useTaxId) {
                result = [SELECT Id FROM GFRS_Organization__c WHERE Tax_Id__c = :taxId LIMIT 1];
            } else {
                result = [SELECT Id FROM GFRS_Organization__c WHERE Non_US_Organization_ID__c = :organizationId LIMIT 1];
            }
        } catch (Exception err) {
            System.debug('unable to find organization[' + taxId + ',' + organizationId + ']:' + err.getMessage());
            result = null;
        }

        if (result != null) {
            return(result.Id);
        } else {
            return(null);
        }
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Fetches the appropriate organization and location information for a specific organization id
        * 
        */
    public GFRS_Organization__c fetchOrganizationById(Id orgId) {
        this.lLocs = new GFRS_Location__c[]{
        };

        //-- all organizations are subject to firewall, the value is only checked if of type imed.
        GFRS_Organization__c result = null;

        if (orgId != null) {
            try {
                result = [
                        SELECT Id, Is_your_organization_a_Sole_Proprietorsh__c, OwnerId, IsDeleted, RecordTypeId, RecordType.DeveloperName, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, ACCME_Accreditations__c, Account__c, Authorized_Signer_Name__c, Description__c, Email_Address_Person_with_Authority__c, Firewall_for_Strategic_Promo_Mktg__c, Grant_Requestor_Subject_to_Firewall__c, Country__c, Mission_Statement__c, Number_of_Employees_Working_in_Complianc__c, Number_of_Employees__c, Number_of_Employees_with_Advanced_Degree__c, Operational_Budget__c, Other_Accredidations__c, Outstanding_Accounts_Payable__c, Is_Part_of_Parent_Org__c, Parent_Organization_Tax_ID__c, Non_US_Organization_ID__c, Salary_of_the_Highest_Paid_Executive__c, State_Affiliation__c, Tax_Id__c, Tax_Status__c, Type__c,IsCHOrg__c, Website_Address__c, of_Physicians_in__c, NCI_Designated_Cancer_Center__c, Accreditation_s_Received__c, Audited_financials_for_the_previous_year__c, Form_990_for_the_previous_year__c, Form_990_for_the_previous_two_year__c, Form_990_for_the_previous_three_year__c, Audited_Financials_for_the_previous_URL__c, Form_990_for_the_previous_two_year_URL__c, Form_990_for_for_the_previous_three_URL__c, Form_990_for_the_previous_year_URL__c, Organization_Name__c, Do_you_have_Legal_Authority_to_Sign__c, Roche_Prescriber__c, Roche_Purchaser__c, Medicare_Guideline_Development__c, Pending_Litigation__c, Physician_Ownership__c, Sister_Parent_Org_Strategic_Promo_Mktg__c, Strategic_Promo_Mkt_Related_Services__c, W8BEN_Status__c, US_Organization__c, Parent_Org_Name__c, W9_Form_W_8BEN_Form__c, W9_Form_W_8BEN_Form_URL__c, Tax_Status_501_c_3_Determination_Letter__c, Tax_Status_501_c_3_Det_Letter_URL__c, Form_990__c, Form_990_URL__c, (SELECT Id,ParentId,Name FROM Attachments)
                        FROM GFRS_Organization__c
                        WHERE Id = :orgId
                        LIMIT 1
                ];

                if (result != null) {
                    //-- save the intial organization type, so it can be compared later
                    this.initialOrgType = result.Type__c;

                    this.lLocs = [
                            SELECT Id, RecordTypeId, RecordType.DeveloperName, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Organization__c, Address_Line_1__c, Address_Line_2__c, Address__c, Address2__c,City__c, Department_Chapter_Country__c, Fax__c, Payment_Method__c, Phone__c, State__c, Street_4__c, Street__c, Vendor_ID__c, Vendor_Name_1__c, Vendor_Name_2__c, Vendor_Name_3__c, Vendor_Name_4__c, Vendor_Name__c, Zip__c, W9_Form_W_8BEN_Form__c, City_1__c, State_1__c, Country_1__c, Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c, Province_Region_Territory__c, Partner_Bank_Type__c, Old_Vendor_ID__c, Vendor_Account_Group__c, Payment_Delivery_Translation__c, PO_Box_available__c, Department_PO_Box__c
                            FROM GFRS_Location__c
                            WHERE Organization__c = :result.Id
                    ];

                    System.debug('locs[' + result.Id + ']:' + this.lLocs);
                } else {
                    if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('fetchOrganizationById ->results NOT found');
                    this.initialOrgType = null;
                }

            } catch (Exception err) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find Organization:' + orgId));
                result = null;
                this.lLocs = new GFRS_Location__c[]{
                };
                this.currentLocation = new GFRS_Location__c();
            }
        } else {
            if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('fetchOrganizationById -> orgId IS null');
            this.initialOrgType = null;
        }

        return(result);
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Fetches a specific location
        * 
        */
    public GFRS_Location__c fetchLocation(Id locationId) {
        this.currentLocation = new GFRS_Location__c();
        //this.w9FormAttachment = null;

        if (locationId == null) return(this.currentLocation);

        try {
            this.currentLocation = [
                    SELECT Id, IsDeleted, Name, RecordTypeId, RecordType.DeveloperName, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Organization__c, Address_Line_1__c, Address_Line_2__c, Address__c,Address2__c, City__c, Department_Chapter_Country__c, Fax__c, Payment_Method__c, Phone__c, State__c, Street_4__c, Street__c, Vendor_ID__c, Vendor_Name_1__c, Vendor_Name_2__c, Vendor_Name_3__c, Vendor_Name_4__c, Vendor_Name__c, Zip__c, W9_Form_W_8BEN_Form__c, City_1__c, State_1__c, Country_1__c, Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c, Province_Region_Territory__c, Old_Vendor_ID__c, Vendor_Account_Group__c, Partner_Bank_Type__c, PO_Box_available__c, Department_PO_Box__c, (SELECT Id,ParentId,Name FROM Attachments)
                    FROM GFRS_Location__c
                    WHERE Id = :locationId
                    AND Organization__c = :THIS.organization.Id
                    LIMIT 1
            ];

        } catch (Exception err) {
            if (myGFRSOrgSettings.TraceOrgInfoController__c) System.debug('fetchLocation()->location could not be found[' + locationId + ']:' + err.getMessage());
            this.currentLocation = new GFRS_Location__c();
        }

        return(this.currentLocation);
    }
    
    /**
        * @author gFRS Dev Team
        * @date 28/02/2020
        * @description Sets the flag to make the Annual Budget field mandatory.
        * 
        */
    public void annBudgetMandatoryDecision() {
            annualBudgetMandatory = false;
            if((isUSBased && (this.organization.Tax_Status__c == '501 (c)(3)' || this.organization.Tax_Status__c == '501 (c)(4)' || this.organization.Tax_Status__c == '501 (c)(6)' || this.organization.Tax_Status__c == 'Governmental Org')) || (!isUSBased && this.organization.Tax_Status__c == 'Non-Profit')){
                annualBudgetMandatory = true;
            }
    }
    
    public void dummyMethod() {
        //Dummy method for action function
    }    

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Checks the organization to see if it already exists (and replace the instance if it is found). Used as action under [Continue] button.
        * 
        */
    public void refreshOrganization() {
        if (validateTaxInfo()) {
            annualBudgetMandatory = false;
            if((isUSBased && (this.organization.Tax_Status__c == '501 (c)(3)' || this.organization.Tax_Status__c == '501 (c)(4)' || this.organization.Tax_Status__c == '501 (c)(6)' || this.organization.Tax_Status__c == 'Governmental Org')) || (!isUSBased && this.organization.Tax_Status__c == 'Non-Profit')){
                annualBudgetMandatory = true;
            }           
            GFRS_Organization__c oldOrg = new GFRS_Organization__c(Country__c = this.organization.Country__c);

            //-- assign only the one needed
            if (isUSBased) {
                //-- validate that the taxId is a valid format
                Pattern taxPattern = Pattern.compile('^\\d{2}[-]\\d{7}$');
                Matcher taxMatcher = taxPattern.matcher(this.organization.Tax_Id__c);

                if (!taxMatcher.matches()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_TAX_FORMAT));
                    return;
                }

                oldOrg.Non_US_Organization_ID__c = null;
                oldOrg.W8BEN_Status__c = null;
                oldOrg.US_Organization__c = 'Yes';
                oldOrg.Tax_Id__c = this.organization.Tax_Id__c;
                oldOrg.Tax_Status__c = this.organization.Tax_Status__c;
            } else {
                oldOrg.Organization_Name__c = this.organization.Organization_Name__c;
                oldOrg.Non_US_Organization_ID__c = this.organization.Non_US_Organization_ID__c;
                oldOrg.W8BEN_Status__c = this.organization.W8BEN_Status__c;
                oldOrg.US_Organization__c = 'No';
                oldOrg.Tax_Id__c = null;
                oldOrg.Tax_Status__c = this.organization.Tax_Status__c;
            }

            Id orgId = this.fetchOrganizationByTaxOrOrg(this.isUSBased, this.organization.Tax_Id__c, this.organization.Non_US_Organization_ID__c);
            System.debug('check current tax id' + this.organization.Tax_Id__c);

            //-- update ONLY if a value was found
            GFRS_Organization__c result = this.fetchOrganizationById(orgId);

            if (result != null) {
                this.organization = result;
                SetupCHFoundationDynaFields();
                //-- fetch the current location again if one currently exists
                if (this.currentLocation != null && this.currentLocation.Id != null) this.fetchLocation(this.currentLocation.Id);
                //if( this.w9FormAttachment == null ) this.w9FormAttachment = new Attachment( ParentId = this.organization.id );
                GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector(this.organization.Attachments);
                this.w9FormAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(this.organization.W9_Form_W_8BEN_Form__c, this.organization.Id);
                this.taxStatus501DeterminationLetterAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(this.organization.Tax_Status_501_c_3_Determination_Letter__c, this.organization.Id);
                this.form990Attachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(this.organization.Form_990__c, this.organization.Id);
                System.debug('PN: this.w9FormAttachment: ' + this.w9FormAttachment);
            } else {
                String orgName = null;
                if (!isUSBased) {
                    orgName = this.organization.Organization_Name__c;
                    if (orgName == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Orgranization Name: You must enter a value'));
                        return;
                    }

                }
                this.resetOrganization();
                this.organization.Organization_Name__c = orgName;
            }

            refreshAccordionVisibility();

            if (this.isInternalUser && this.isOrgExternal) {
                //If user is internal and org is externaly owned do nothing!
            } else {
                this.organization.Tax_Id__c = oldOrg.Tax_Id__c;
                this.organization.Non_US_Organization_ID__c = oldOrg.Non_US_Organization_ID__c;
                this.organization.Country__c = oldOrg.Country__c;
                this.organization.W8BEN_Status__c = oldOrg.W8BEN_Status__c;
                this.organization.Tax_Status__c = oldOrg.Tax_Status__c;
                this.organization.US_Organization__c = oldOrg.US_Organization__c;

                //if organization is internal and user is external clear organization data
                if (result != null && !this.isOrgExternal && !this.isInternalUser) {
                    System.debug('clearing data...');

                    result.of_Physicians_in__c = null;
                    result.Operational_Budget__c = null;
                    result.Website_Address__c = null;
                    result.Mission_Statement__c = null;
                    result.Number_of_Employees__c = null;
                    result.Roche_Purchaser__c = null;
                    result.Roche_Prescriber__c = null;
                    result.Medicare_Guideline_Development__c = null;
                    result.Physician_Ownership__c = null;
                    result.ParentOrganization__c = null;
                    result.Parent_Org_Name__c = null;
                    result.Parent_Organization_Tax_ID__c = null;
                }
            }
            //http://jira.intranet.roche.com/jira/browse/SFDC-1455
            if (this.organization != null) {
                if (this.organization.Tax_Status__c == '501 (c)(3)' || this.organization.Tax_Status__c == '501 (c)(6)' || this.organization.Tax_Status__c == 'Governmental Org' || (this.organization.US_Organization__c == 'No' && this.organization.Tax_Status__c == 'Non-Profit')) {
                    this.organization.Physician_Ownership__c = 'No';
                }
            }
        }

        return;
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Validate the tax information
        * 
        */
    private Boolean validateTaxInfo() {

        Boolean isValid = true;

        if (isUSBased) // Organization based in US
        {
            if (this.organization.Tax_Id__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_TAX_ID));
                isValid = false;
            }
            if (this.organization.Tax_Status__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_TAX_STATUS));
                isValid = false;
            }
        } else {// Organization non-US based
            if (this.organization.Non_US_Organization_ID__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_ORG_ID));
                isValid = false;
            }
            if (this.organization.W8BEN_Status__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_W8BEN_STATUS));
                isValid = false;
            }
            if (this.organization.Tax_Status__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_TAX_STATUS));
                isValid = false;
            }
        }

        return(isValid);
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Method to find the current location
        * 
        */
    public void setLocation() {
        if (this.selectedLocation == null || this.selectedLocation == '') {
            this.currentLocation = new GFRS_Location__c();
            this.isLocationEditable = true;
            return;
        }

        Id selectedLocationId = null;
        try {
            selectedLocationId = Id.valueOf(this.selectedLocation);
        } catch (Exception err) {
            if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('setLocation()-> selectedLocationId ex sink ok');
        }

        Map<Id, GFRS_Location__c> locationMap = new Map<Id, GFRS_Location__c>(this.lLocs);

        if (locationMap.containsKey(selectedLocationId)) {
            this.currentLocation = locationMap.get(selectedLocationId);

            // For United States location we need to check and trim Zip Code to retrieve Po Box if it's present.
            if (currentLocation.Zip__c.length() > 5 && currentLocation.Department_Chapter_Country__c == 'United States') {
                String[] zipCode = currentLocation.Zip__c.split('-');
                if (zipCode.size() == 2) {
                    currentLocation.Zip__c = zipCode[0];
                    currentLocation.Department_PO_Box__c = zipCode[1];
                    currentLocation.PO_Box_available__c = 'Yes';
                }
            }

            if (gFRS_Util.RT_LOC_INTERNAL.equals(this.currentLocation.RecordType.DeveloperName)) {
                this.isLocationEditable = true;
            } else if (isInternalUser == true) {
                this.isLocationEditable = false;
            }
        } else {
            this.currentLocation = new GFRS_Location__c();
            this.isLocationEditable = true;
        }
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Validates the page before submission
        * 
        */
    public Boolean validateSaveOrganization() {
        Boolean isValid = true;
        Boolean soleProprietorshipRequired = false;

        if (this.organizationExists == true) {
            //if Organization exists then 'Is_your_organization_a_Sole_Proprietorsh__c' field should not be requred. Unless Request is in RFI.
            if (this.fundReq.Sub_Status__c == gFRS_Util.REQUEST_STATUS_RFI) {
                soleProprietorshipRequired = true;
            } else {
                soleProprietorshipRequired = false;
            }

        } else if (this.organizationExists == false) {
            soleProprietorshipRequired = true;
        }

        if (soleProprietorshipRequired && this.isOrgUsBasedAndForProfit == true && this.organization.Is_your_organization_a_Sole_Proprietorsh__c == null) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Is_Org_Sole_Proprietorship_Error));
            return false;

        }
        
        if((this.organization.Operational_Budget__c == null || this.organization.Operational_Budget__c <= 0) && !this.isInternalUser && this.annualBudgetMandatory){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_MinimumAnnualBudgetError));
            return false;           
        }


        if (ApexPages.hasMessages()) {
            return(false);
        }
        if (this.initialOrgType != null && this.initialOrgType != '' && !this.initialOrgType.equals(this.organization.Type__c)) {
            isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_ORG_TYPE_CHANGED + ' ' + this.initialOrgType));
            this.organization.Type__c = this.initialOrgType;
            orgTypeValue = this.initialOrgType;
        }

        SetupCHFoundationDynaFields();

        return(isValid);
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Validates saving the location
        * 
        */
    public Boolean validateSaveLocation() {
        Boolean isValid = true;

        if (isValid && (this.currentLocation.Name == null)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select location or insert the new one (Chapter Name and W9/WBEN fields are required)'));
            currentIndex = 3;
            isValid = false;
        }
        //If Org is not US Based and has W8 status-need W8 attachment.
        if (this.organization.W8BEN_Status__c != null && this.organization.W8BEN_Status__c == 'Yes') {
            if (!isW9Attached) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_MSG_W9W8_MISSING));
                isValid = false;
            }
        } else if (this.organization.W8BEN_Status__c == null) {
            if (!isW9Attached) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_MSG_W9W8_MISSING));
                isValid = false;
            }
        }

        //check if 501(c) attachment has been uploaded when Tax Status = 501(c)
        if (this.organization.Tax_Status__c != null && this.organization.Tax_Status__c == '501 (c)(3)' && isUserExternal) {
            if (!isTaxStatus501DeterminationLetterAttached) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_MSG_501C_ATTACHMENT_MISSING));
                isValid = false;
            }
        }

        if (this.organization.Tax_Status__c != null
                && this.organization.Tax_Status__c == '501 (c)(3)'
                && isFundingTypeExternal
                && isUserExternal
                ) {
            if (!isForm990Attached) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_MSG_990_FORM_ATTACHMENT_MISSING));
                isValid = false;
            }
        }

        // For United States location merge Po Box into Zip Code field before we save them to database.
        if (currentLocation.PO_Box_available__c == 'Yes' && currentLocation.Department_Chapter_Country__c == 'United States') {
            String uspsValidation = validatePoBox();
            if (String.isNotBlank(uspsValidation)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uspsValidation));
                isValid = false;
            }
        }

        return(isValid);
    }

    /**
     * Method to validate Po Box on save. It uses USPS API to check for Zip Code and Po Box for entered address.
     *
     * @return Error description/message. If it's null or empty then no error was returned from API (address exists).
     */
    private String validatePoBox() {
        Map<String, String> params = new Map<String, String>{
                'address2' => currentLocation.Address__c,
                'city' => currentLocation.City__c,
                'state' => currentLocation.State__c,
                'zip5' => currentLocation.Zip__c,
                'zip4' => currentLocation.Department_PO_Box__c
        };
        gFRS_USPSUtils.USPSAddress uspsAddress = new gFRS_USPSUtils.USPSAddress();
        String request = gFRS_USPSUtils.buildZipCodeLookupRequest(gFRS_USPSUtils.defaultUspsUsername, params);
        String response = gFRS_USPSUtils.callUSPSApi(String.valueOf(gFRS_USPSUtils.uspsApiType.ZipCodeLookup), request);
        uspsAddress = gFRS_USPSUtils.parseUSPSApiCallResponse(response);

        if (String.isNotBlank(uspsAddress.errorDescription)) {
            return uspsAddress.errorDescription;
        }

        if (uspsAddress.zip5 != currentLocation.Zip__c) {
            return String.format(Label.gFRS_ERROR_ZIP_CODE_IS_INVALID, new List<String>{
                    uspsAddress.zip5
            });
        } else if (uspsAddress.zip4 != currentLocation.Department_PO_Box__c) {
            if (String.isBlank(currentLocation.Department_PO_Box__c)) {
                return Label.gFRS_ERROR_PO_BOX_IS_BLANK;
            } else if (String.isNotBlank(uspsAddress.zip4)) {
                return String.format(Label.gFRS_ERROR_PO_BOX_IS_INVALID, new List<String>{
                        uspsAddress.zip4
                });
            } else {
                return Label.gFRS_ERROR_PO_BOX_NOT_FOUND;
            }
        }

        return null;
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Validates the W9 information has been uploaded
        * 
        */
    public Boolean validateRequiredFiles() {
        Boolean isValid = true;

        if (ApexPages.hasMessages()) {
            isValid = false;
        }

        if (this.organization.W8BEN_Status__c != null && this.organization.W8BEN_Status__c == gFRS_Util.NO) {
            //-- w9 is not needed
        } else if (this.w9FormAttachment == null || this.w9FormAttachment.Name == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_MSG_W9W8_MISSING));
            isValid = false;
        }

        //check if 501(c) attachment has been uploaded when Tax Status = 501(c)
        if (this.organization.Tax_Status__c != null && this.organization.Tax_Status__c == '501 (c)(3)' && isUserExternal) {
            if (this.taxStatus501DeterminationLetterAttachment == null || this.taxStatus501DeterminationLetterAttachment.Name == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_MSG_501C_ATTACHMENT_MISSING));
                isValid = false;
            }
        }

        if (this.organization.Tax_Status__c != null
                && this.organization.Tax_Status__c == '501 (c)(3)'
                && isFundingTypeExternal
                && isUserExternal
                ) {
            if (!isForm990Attached) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_MSG_990_FORM_ATTACHMENT_MISSING));
                isValid = false;
            }
        }

        return(isValid);
    }


    public void uploadW9Form() {
        if (this.organization == null || this.organization.Id == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_ORG_REQUIRED));
            return;
        }

        try {
            this.currentIndex = 2;

            Attachment oldAttachment = this.w9FormAttachment;
            Attachment newAttachment = new Attachment(ParentId = this.organization.Id, Name = oldAttachment.Name);
            newAttachment.Body = oldAttachment.Body;
            gFRS_Util_NoShare.saveLockedAttachment(newAttachment);

            newAttachment.Body = null;
            oldAttachment.Body = null;

            this.organization.W9_Form_W_8BEN_Form__c = newAttachment.Id;

            //refactoring for SFDC-1724 
            //-- touch the organization for record type change consideration
            this.organization.Organization_LastModifiedBy__c = UserInfo.getUserId();
            organization.IsValidationExternalOnly__c = 'Yes';
            gFRS_Util_NoShare.saveLockedOrganization(this.organization);

            this.w9FormAttachment = [SELECT Id,ParentId,Name FROM Attachment WHERE Id = :newAttachment.Id];
            this.w9FormAttachment.Body = null;
        } catch (Exception err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
        } finally {
            if (this.w9FormAttachment != null && this.w9FormAttachment.Body != null) this.w9FormAttachment.Body = null;
        }
    }

    public void uploadTaxStatus501DeterminationLetter() {
        if (this.organization == null || this.organization.Id == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_ORG_REQUIRED));
            return;
        }

        try {
            this.currentIndex = 2;

            Attachment oldAttachment = this.taxStatus501DeterminationLetterAttachment;
            Attachment newAttachment = new Attachment(ParentId = this.organization.Id, Name = oldAttachment.Name);
            newAttachment.Body = oldAttachment.Body;
            gFRS_Util_NoShare.saveLockedAttachment(newAttachment);


            newAttachment.Body = null;
            oldAttachment.Body = null;

            this.organization.Tax_Status_501_c_3_Determination_Letter__c = newAttachment.Id;

            this.organization.Organization_LastModifiedBy__c = UserInfo.getUserId();
            organization.IsValidationExternalOnly__c = 'Yes';
            gFRS_Util_NoShare.saveLockedOrganization(this.organization);

            this.taxStatus501DeterminationLetterAttachment = [SELECT Id,ParentId,Name FROM Attachment WHERE Id = :newAttachment.Id];
            this.taxStatus501DeterminationLetterAttachment.Body = null;

        } catch (Exception err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
        } finally {
            if (this.taxStatus501DeterminationLetterAttachment != null && this.taxStatus501DeterminationLetterAttachment.Body != null) this.taxStatus501DeterminationLetterAttachment.Body = null;
        }
    }

    public void uploadForm990() {
        if (this.organization == null || this.organization.Id == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_ORG_REQUIRED));
            return;
        }

        try {
            this.currentIndex = 2;

            Attachment oldAttachment = this.form990Attachment;
            Attachment newAttachment = new Attachment(ParentId = this.organization.Id, Name = oldAttachment.Name);
            newAttachment.Body = oldAttachment.Body;
            gFRS_Util_NoShare.saveLockedAttachment(newAttachment);


            newAttachment.Body = null;
            oldAttachment.Body = null;

            this.organization.Form_990__c = newAttachment.Id;

            this.organization.Organization_LastModifiedBy__c = UserInfo.getUserId();
            organization.IsValidationExternalOnly__c = 'Yes';
            gFRS_Util_NoShare.saveLockedOrganization(this.organization);

            this.form990Attachment = [SELECT Id,ParentId,Name FROM Attachment WHERE Id = :newAttachment.Id];
            this.form990Attachment.Body = null;

        } catch (Exception err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
        } finally {
            if (this.form990Attachment != null && this.form990Attachment.Body != null) this.form990Attachment.Body = null;
        }
    }

    /** ### PageReference methods ### **/

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description This method is needed to save values from Org Details accordion
        * 
        */
    public PageReference saveOrganizationDetails() {
        if (validateSaveOrganization() == false) {
            //-- display error message if needed
            return(null);
        }
        //-- touch the organization for record type change consideration
        this.organization.Organization_LastModifiedBy__c = UserInfo.getUserId();

        Savepoint sp = Database.setSavepoint();
        try {
            if(!isAnnualBudgetEditable){
                if (isInternalUser) {
                    this.organization.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Organization__c' AND DeveloperName = 'Internal'][0].Id;
                } else {
                    this.organization.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Organization__c' AND DeveloperName = 'External'][0].Id;
                }

                if (this.organizationExists == false) {
                    Account a = gFRS_Util_NoShare.createAccountFromOrganization(this.organization);
                    this.organization.Account__c = a.Id;
                    this.organization.IsValidationExternalOnly__c = 'Yes';
                    gFRS_Util_NoShare.saveLockedOrganization(this.organization);
                } else {
                    this.organization.IsValidationExternalOnly__c = 'Yes';
                    gFRS_Util_NoShare.saveLockedOrganization(this.organization);
                }
            } else {
                gFRS_Util_NoShare.saveLockedOrganization(this.organization);
            }
            //-- always try to associate the user with the account
            //-- the tax information is no longer editable if currently assigned to an organization
            if (!this.isInternalUser) {
                this.isTaxInfoEditable = !gFRS_Util_NoShare.associateUserWithAccount(UserInfo.getUserId(), this.organization.Account__c, this.organization.Id);
            }
            System.debug('could associate user with account:' + !this.isTaxInfoEditable);
            if (this.fundReq != null && this.fundReq.Id != null) {
                this.fundReq.Organization__c = this.organization.Id;
            }

            //-- please note that the page refreshes after this is called, and the w9FormAttachment is loaded often from the constructor when calling org_info_file
            if (this.w9FormAttachment == null) this.w9FormAttachment = new Attachment(ParentId = this.organization.Id);
            if (this.taxStatus501DeterminationLetterAttachment == null) this.taxStatus501DeterminationLetterAttachment = new Attachment(ParentId = this.organization.Id);
        } catch (Exception err) {
            Database.rollback(sp);
            String errMsg = gFRS_Util.getPrettyMessage(err);
            System.debug('error occurred:' + errMsg);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
        }
        //refreshAccordionVisibility();
        return (null);
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Method called that returns to the 'previous' page
        * 
        */
    public PageReference back() {
        return(new PageReference(PATH_HOME));
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Method called that returns to the 'next' page
        * 
        */
    public PageReference next() {
        if (!validateRequiredFiles()) return(null);

        if (this.shouldStopOnComplete) {
            return(new PageReference(PATH_HOME));
        } else {
            //-- move to the decision result IF there was a funding request sent
            String path = this.fundReq != null && this.fundReq.Id != null ? PATH_COMPLETE_VIEW : PATH_COMPLETE;
            return(new PageReference(gFRS_Util.initializeLink(path, this.fundReq, PARAM_ORG_ID + '=' + String.valueOf(this.organization.Id) + '&' + PARAM_LOCATION_ID + '=' + String.valueOf(this.currentLocation.Id))));
        }
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Method called to perform final submission
        * 
        */
    public PageReference saveLocationDetails() {
        if (validateSaveLocation() == false) {
            //-- display error message if needed
            return(null);
        }
        try {

            if (this.currentLocation.Id == null) currentLocation.Organization__c = this.organization.Id;
            if (this.currentLocation.Id != null && checkIfLocationWasModified(this.currentLocation)) {
                GFRS_Location__c newlock = this.currentLocation.clone(false, true);
                newlock = setPoBoxToCurrentLocation(newlock);
                gFRS_Util_NoShare.saveLockedLocation(newlock);
                this.currentLocation = newlock;
                this.selectedLocation = newlock.Id;
            } else {
                checkIfLocationWasModified(this.currentLocation);
                currentLocation = setPoBoxToCurrentLocation(currentLocation);
                gFRS_Util_NoShare.saveLockedLocation(this.currentLocation);
                this.selectedLocation = currentLocation.Id;
            }
            //update funding request location
            if (this.fundReq != null && this.fundReq.Id != null && currentLocation.Id != null) {
                this.fundReq.Location__c = currentLocation.Id;
                //funding request validations shouldn't be visible only on application page
                gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(this.fundReq);
            }

            //-- check for blacklist
            //SObject blacklist = gFRS_Util.isBlacklistedOrganization(taxId);
            String invalidOrgCode = null;
            /*
            
            if( gFRS_Util.isBlacklistedOrganization(this.organization.Tax_Id__c) ){
                blackListCode = gFRS_ErrorController.CODE_BLACKLIST;
            } else 
            */
            if (this.organization.Type__c == ORG_TYPE_PRIV_PHYSICIAN ||
                    this.organization.Type__c == ORG_TYPE_GROUP_PRACTICE ||
                    this.organization.Type__c == ORG_TYPE_INDIVIDUAL ||
                    this.organization.Type__c == ORG_TYPE_POL_ORG ||
                    this.organization.Type__c == ORG_TYPE_SECT_ORG
                    ) {
                invalidOrgCode = gFRS_ErrorController.CODE_INV_ORG;
            }

            /*
            //-- please note that the page refreshes after this is called, and the w9FormAttachment is loaded often from the constructor when calling org_info_file
            if( this.w9FormAttachment == null ) this.w9FormAttachment = new Attachment( ParentId = this.organization.id );
            */

            if (invalidOrgCode != null) {

                return(new PageReference(PATH_INV_ORG + invalidOrgCode));
            }

            String path = this.fundReq != null && this.fundReq.Id != null ? PATH_COMPLETE_VIEW : PATH_COMPLETE;
            return(new PageReference(gFRS_Util.initializeLink(path, this.fundReq, PARAM_ORG_ID + '=' + String.valueOf(this.organization.Id) + '&' + PARAM_LOCATION_ID + '=' + String.valueOf(this.currentLocation.Id))));
        } catch (Exception err) {
            ApexPages.addMessages(err);
            return (null);
        }
    }

    private GFRS_Location__c setPoBoxToCurrentLocation(GFRS_Location__c location) {
        // Only if we want to save PO Box on Zip code field as xxxxx-xxxx
        if (location.Zip__c.length() == 5 && location.Department_PO_Box__c.length() == 4) {
            location.Zip__c = location.Zip__c + '-' + location.Department_PO_Box__c;
        }
        return location;
    }
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Validates the W9 information has been uploaded
        * 
        */
    public PageReference validateW9File() {

        if (this.organization.W8BEN_Status__c != null && this.organization.W8BEN_Status__c == gFRS_Util.NO) {
            this.currentIndex = 3;
        } else if (this.w9FormAttachment == null || this.w9FormAttachment.Name == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_MSG_W9W8_MISSING));
            this.currentIndex = 2;
        } else if (this.w9FormAttachment != null && this.w9FormAttachment.Name != null) {
            this.currentIndex = 3;
        }

        return null;
    }

    public PageReference validateTaxStatus501DeterminationLetter() {

        if (this.organization.Tax_Status__c != null && this.organization.Tax_Status__c == '501 (c)(3)' && isUserExternal) {
            if (taxStatus501DeterminationLetterAttachment == null || taxStatus501DeterminationLetterAttachment.Name == null) {
                this.currentIndex = 2;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_MSG_501C_ATTACHMENT_MISSING));
            } else {
                this.currentIndex = 3;
            }
        } else {
            this.currentIndex = 3;
        }
        return null;
    }

    public PageReference validate990FormFile() {

        if (this.organization.Tax_Status__c != null
                && this.organization.Tax_Status__c == '501 (c)(3)'
                && isFundingTypeExternal
                && isUserExternal
                ) {
            if (form990Attachment == null || form990Attachment.Name == null) {
                this.currentIndex = 2;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_MSG_990_FORM_ATTACHMENT_MISSING));
            } else {
                this.currentIndex = 3;
            }
        }
        return null;
    }

    public PageReference validateFileAttachments() {
        validateW9File();
        Integer curIndW9 = this.currentIndex;
        validateTaxStatus501DeterminationLetter();
        Integer curInd501 = this.currentIndex;
        validate990FormFile();
        Integer curInd990 = this.currentIndex;
        this.currentIndex = curIndW9 < curInd501 ? (curIndW9 < curInd990 ? curIndW9 : curInd990) : (curInd501 < curInd990 ? curInd501 : curInd990);
        return null;
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Method used for partial rerender Tax ID accordion while organization location is changed
        * 
        */
    public PageReference partialRerenderTaxIdAccordion() {
        if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('partialRerenderTaxIdAccordion()->this.organization.Country__c ' + this.organization.Country__c);
        if (!isUSBased) {
            this.organization.Organization_Name__c = null;
            this.organization.Non_US_Organization_ID__c = null;
            this.organization.W8BEN_Status__c = null;
            this.organization.Tax_Status__c = null;
        }
        setIsUSBasedPickList(); //set US_Organization__c picklist flag

        return(null);
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description used for partial refresh org type section.
        * 
        */
    public PageReference OrgTypeOnChange() {
        if (orgTypeValue == CHFoundationType) {
            IsCharitableFundation = true;
            if (IsCHValue == 'Yes') {
                IsCHValueYes = true;
            } else {
                IsCHValueYes = false;

            }
            System.debug('getIsCharitableFundation()==true.  Org Type get :' + orgTypeValue);
        } else {
            IsCharitableFundation = false;
            IsCHValueYes = false;
            IsCHValue = null;

            organization.IsCHOrg__c = null;
            organization.of_Physicians_in__c = null;
            System.debug('getIsCharitableFundation()==false.  Org Type get :' + orgTypeValue);

        }
        return null;
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description used for partial rendering details accordion
        * 
        */
    public PageReference IsCHChangedOnChange() {
        if (IsCHValue == 'Yes') {
            IsCHValueYes = true;
        } else {
            if (IsCHValue == 'No' || IsCHValue == null) {
                organization.of_Physicians_in__c = null;
                IsCHValueYes = false;
            }

            if (IsCHValue == null) {
                organization.IsCHOrg__c = null;
            }
        }
        return null;
    }


    /*** ### Private Methods ### ***/

    private void setIsUSBasedPickList() {
        if (this.organization.Country__c != null) {
            if (IsUSBasedOrg(this.organization.Country__c)) {
                this.organization.US_Organization__c = 'Yes';
            } else {
                this.organization.US_Organization__c = 'No';
            }
        } else {
            this.organization.US_Organization__c = 'Yes';
        }

    }

    /**
       * @author ADMD Dev Team
       * @date 21/08/2013
       * @description Method returns true if country should be treated as US
       *
       */
    private Boolean IsUSBasedOrg(String country) {
        Boolean retValue = false;

        String strlistUSBasedCountries = myGFRSOrgSettings.USBasedOrganizations__c;
        String[] listOfUsBasedCountries = strlistUSBasedCountries.split('\\|');
        if (country != null && country != '') {
            for (String tmpCountryName : listOfUsBasedCountries) {
                if (tmpCountryName == country) {
                    retValue = true;
                    break;
                }
            }
        } else {
            //as default we treat org as US based.
            retValue = true;
        }
        if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('IsUSBasedOrg? ' + country + ' ->' + retValue);
        return retValue;
    }

    /**
       * @author ADMD Dev Team
       * @date 20/08/2013
       * @description Determines the id of of the location sent by GET (if there was one )
       *
       */
    private Id getSentLocationId() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        if (params.containsKey(PARAM_LOCATION_ID)) {
            return(Id.valueOf(params.get(PARAM_LOCATION_ID)));
        } else {
            return(null);
        }
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Determines the org id sent by GET (if there was one)
        * 
        */
    private String getSentTaxId() {
        Map<String, String> params = ApexPages.currentPage().getParameters();

        if (this.userContact != null) {
            try {
                if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('getSentTaxId()->User contact not null');
                GFRS_Organization__c userOrg = gFRS_Util.getContactOrganization(this.userContact);
                return(userOrg.Id);
            } catch (Exception err) {
                if (myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('getSentTaxId()-> exception:' + err.getMessage());
            }
        } else if (params.containsKey(PARAM_ORG_ID)) {
            return(Id.valueOf(params.get(PARAM_ORG_ID)));
        }

        return(null);
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Resets the Organization to a new organization
        * 
        */
    private void resetOrganization() {
        this.selectedLocation = null;
        this.lLocs = new GFRS_Location__c[]{
        };
        this.organization = new GFRS_Organization__c(Grant_Requestor_Subject_to_Firewall__c = true);
        this.currentLocation = new GFRS_Location__c();
        this.w9FormAttachment = new Attachment();
        this.taxStatus501DeterminationLetterAttachment = new Attachment();
        this.form990Attachment = new Attachment();
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Resets setup valuse for partial rendering org details
        * 
        */
    private void SetupCHFoundationDynaFields() {
        System.debug('SetupCHFoundationDynaFields() start...');

        if (organization != null) {

            IsCHValue = organization.IsCHOrg__c;
            orgTypeValue = organization.Type__c;

            System.debug('SetupCHFoundationDynaFields() org type=' + orgTypeValue);
            if (orgTypeValue == CHFoundationType) {
                IsCharitableFundation = true;

                if (IsCHValue == 'Yes') {
                    IsCHValueYes = true;
                } else if (IsCHValue == 'No') {
                    IsCHValueYes = false;
                    organization.of_Physicians_in__c = null;

                } else {
                    IsCHValueYes = false;
                    organization.IsCHOrg__c = null;
                    organization.of_Physicians_in__c = null;
                }
            } else {
                organization.IsCHOrg__c = null;
                organization.of_Physicians_in__c = null;
                IsCharitableFundation = false;
                IsCHValueYes = false;
            }
        } else {
            IsCharitableFundation = false;
            IsCHValueYes = false;
        }
    }

    /**
    * @author ADMD Dev Team
    * @date 20/08/2013
    * @description check if location was modified
    * 
    */
    private Boolean checkIfLocationWasModified(GFRS_Location__c newLock) {
        Boolean shouldCompare = true;
        if (newLock == null || (newLock != null && newLock.Id == null)) {
            shouldCompare = false;
        }
        GFRS_Location__c oldLock = null;
        if (shouldCompare) {
            oldLock = [
                    SELECT Id, RecordTypeId, RecordType.DeveloperName, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Organization__c, Address_Line_1__c, Address_Line_2__c, Address__c, City__c, Department_Chapter_Country__c, Fax__c, Payment_Method__c, Phone__c, State__c, Street_4__c, Street__c, Vendor_ID__c, Vendor_Name_1__c, Vendor_Name_2__c, Vendor_Name_3__c, Vendor_Name_4__c, Vendor_Name__c, Zip__c, W9_Form_W_8BEN_Form__c, City_1__c, State_1__c, Country_1__c, Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c, Province_Region_Territory__c, Old_Vendor_ID__c, Vendor_Account_Group__c, Partner_Bank_Type__c, Department_PO_Box__c
                    FROM GFRS_Location__c
                    WHERE Id = :newLock.Id
            ];
        }
        //GFRS_Location__c loc2=loc.clone(false,true);
        String [] fieldsToCompare = new String[]{
                'Name', 'Address_Line_1__c', 'Address_Line_2__c', 'Address__c', 'City__c', 'Department_Chapter_Country__c', 'Fax__c', 'Payment_Method__c', 'Phone__c', 'State__c', 'Street_4__c', 'Street__c', 'Vendor_ID__c', 'Vendor_Name_1__c', 'Vendor_Name_2__c', 'Vendor_Name_3__c', 'Vendor_Name_4__c', 'Vendor_Name__c', 'City_1__c', 'State_1__c', 'Country_1__c', 'Zip_Code_1__c', 'Province_Region_Territory__c', 'Old_Vendor_ID__c', 'Vendor_Account_Group__c', 'Partner_Bank_Type__c', 'Zip__c', 'Department_PO_Box__c'
        };
        Boolean fieldsWereChanged = false;
        for (String fname : fieldsToCompare) {
            String newVal = ((String) newLock.get(fname)) == null ? '' : (String) newLock.get(fname);
            if (oldLock != null && shouldCompare) {
                String oldVal = ((String) oldLock.get(fname)) == null ? '' : (String) oldLock.get(fname);
                if (newVal.toLowerCase().trim().replaceAll('\\s+', ' ') != oldVal.toLowerCase().trim().replaceAll('\\s+', ' ')) {
                    if (fname == 'Zip__c' && newLock.Department_Chapter_Country__c == 'United States') {
                        if (String.isNotBlank(newVal) && String.isNotBlank(oldVal)) {
                            if (newVal.left(5) != oldVal.left(5)) {
                                fieldsWereChanged = true;
                                break;
                            } else {
                                fieldsWereChanged = false;
                                continue;
                            }
                        }
                    }
                    fieldsWereChanged = true;
                    break;
                }
            }
            newLock.put(fname, newVal.trim().replaceAll('\\s+', ' '));
        }
        return fieldsWereChanged;
    }

    /**
    * @author ADMD Dev Team
    * @date 20/08/2013
    * @description Refresh org accordion visibility
    * 
    */
    private void refreshAccordionVisibility() {
        if (this.fundReq == null || this.fundReq.Id == null) {
            System.debug('SECTION 1');
            this.isEditable = true;
            this.isAnnualBudgetEditable = false;
            if (this.organization != null && (this.organization.Tax_Id__c != null || this.organization.Non_US_Organization_ID__c != null)) {
                System.debug('SECTION 2');
                System.debug(this.organization.Tax_Id__c);
                this.isDescriptionEditable = gFRS_Util_NoShare.getSubmitedRequestUnderOrg(this.organization.Tax_Id__c, this.organization.Non_US_Organization_ID__c) < 1;
                if(this.organization.Operational_Budget__c == null || this.organization.Operational_Budget__c <= decimal.valueOf(System.Label.gFRS_MinimumAnnualBudget) ){
                    this.isAnnualBudgetEditable = true;
                } else {
                    this.isAnnualBudgetEditable = false;
                }
                if (this.isInternalUser && this.isOrgExternal) {
                    this.isDescriptionEditable = false;
                } else if (!this.isInternalUser && !this.isOrgExternal) {
                    this.isDescriptionEditable = true;
                }
            } else {
                this.isDescriptionEditable = true;
            }
            this.isTaxInfoEditable = (this.userContact == null || this.userContact.Account.Id == (gFRS_Util.getCustomSettingStringValue('Portal_Account_ID') == null ? System.Label.GFRS_HOLDING_ACCOUNT : gFRS_Util.getCustomSettingStringValue('Portal_Account_ID')));
            this.isLocationEditable = true;
            this.isLocationSelectable = true;
            System.debug('flag was set to true: 1');
        } else if (this.fundReq.Information_Needed__c != null) {
            //-- the record exists and can be modified
            System.debug('SECTION 4');
            this.isAnnualBudgetEditable = false;            
            this.isEditable = gFRS_Util.multiSelectHasItem(this.fundReq.Information_Needed__c, 'Organization');
            if (this.isEditable && this.fundReq.Sub_Status__c != null && this.fundReq.Sub_Status__c == 'RFI') {
                this.isDescriptionEditable = this.isEditable;

                //this.isTaxInfoEditable = false;
                System.debug('SECTION 5');
            } else if (this.organization != null && (this.organization.Tax_Id__c != null || this.organization.Non_US_Organization_ID__c != null)) {
                //this.isTaxInfoEditable = (this.userContact == null || this.userContact.Account.id == System.Label.GFRS_HOLDING_ACCOUNT ) && isEditable;
                this.isDescriptionEditable = gFRS_Util_NoShare.getSubmitedRequestUnderOrg(this.organization.Tax_Id__c, this.organization.Non_US_Organization_ID__c) < 1;

                System.debug('SECTION 6');
            }
            System.debug('flag was set to' + this.isDescriptionEditable + ' false: 1');
            this.isLocationEditable = gFRS_Util.multiSelectHasItem(this.fundReq.Information_Needed__c, 'Location');
            this.isLocationSelectable = gFRS_Util.multiSelectHasItem(this.fundReq.Information_Needed__c, 'Location');
            this.isTaxInfoEditable = false;
            if (this.isInternalUser) {
                //-- restrict if the user is internal viewing an external organization or location
                if (this.isOrgExternal) {
                    this.isEditable = false;
                    this.isDescriptionEditable = false;
                    //this.isTaxInfoEditable = false;
                    System.debug('SECTION 7');
                    System.debug('flag was set to false: 1');
                }
                if (this.isLocationExternal) {
                    System.debug('SECTION 8');
                    //this.isLocationEditable = false;
                }
            } else if (!this.isInternalUser && !this.isOrgExternal) {
                this.isDescriptionEditable = true;
            }
        } else {
            System.debug('SECTION 9');
            this.isAnnualBudgetEditable = false;            
            this.isEditable = false;
            this.isDescriptionEditable = false;
            this.isLocationEditable = false;
            this.isLocationSelectable = false;
            this.isTaxInfoEditable = false;
            System.debug('flag was set to false: 2');
        }
    }

    private List<GFRS_Organization__c> orgranizationsInCountry;

    public String orgranizationNamesInCountry {
        get {
            if (!isUSBased) {
                orgranizationsInCountry = [SELECT Id, Organization_Name__c, W8BEN_Status__c, Non_US_Organization_ID__c, Tax_Status__c, Country__c, Tax_Id__c FROM GFRS_Organization__c WHERE Country__c = :organization.Country__c];
                return JSON.serialize(orgranizationsInCountry);
            }
            return null;
        }
        set;
    }
}