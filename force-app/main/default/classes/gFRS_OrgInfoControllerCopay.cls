/*
* @author ADMD GFRS Dev Team
* @date 08/20/2013
* @description Controller for Organization info page 
*/
public with sharing class gFRS_OrgInfoControllerCopay {

    public boolean copayreadonly{get; set;}
    public boolean isnoncopay1{get; set;} 
    public boolean isnoncopay2{get; set;}
    public boolean forprofitOrg{get; set;}
    public boolean ismorethanonelocation{get; set;}
    
    public static final String CONTENT_TYPE            = 'Organization';
    public static final String PATH_COMPLETE           = '/apex/GFRS_Decision';
    public static final String PATH_COMPLETE_VIEW      = '/apex/GFRS_Application';
    public static final String PATH_COMPLETEcopay           = '/apex/GFRS_Decisioncopay';
    public static final String PATH_COMPLETE_VIEWcopay      = '/apex/GFRS_Applicationcopay';
    public static final String ORG_TYPE_PRIV_PHYSICIAN = 'Private physician office';
    public static final String ORG_TYPE_GROUP_PRACTICE = 'Group practice';
    public static final String ORG_TYPE_INDIVIDUAL     = 'Individual';
    public static final String ORG_TYPE_POL_ORG        = 'Political organization';
    public static final String ORG_TYPE_SECT_ORG       = 'Sectarian organization';
    public static final String PATH_HOME               = '/apex/gFRS_Home'; /** Page to move to when moving 'back' **/
    public static final String PATH_ORG_A              = '/apex/gFRS_Org_Info';  /** Page to move to the first org info section **/
    public static final String PATH_ORG_B              = '/apex/gFRS_org_Info_File'; /** Page to move to the second org info section **/
    public static final String PATH_INV_ORG            = '/apex/gFRS_Error?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=';  /** Path to the Invalid organization **/
    public static final String PARAM_TAX_ID            = 'taxId'; /** GET parameter name for the Organization taxId to work with **/
    public static final String PARAM_ORG_ID            = 'org'; /** GET parameter name for the Organization id to work with **/
    public static final String PARAM_LOCATION_ID       = 'loc'; /** GET parameter name for the Location id to work with **/  
    public static final String PARAM_SOC               = 'soc'; /** GET parameter name for stop on complete **/  
    public static final String PARAM_SHOW              = 'show'; /** GET parameter name for show (currently defaults to show current org) **/
    public static final String CHFoundationType        = 'Charitable Foundation'; 
    public Integer invitecodetrial     = 0; 
    
    private GFRS_OrgSettings__c myGFRSOrgSettings = GFRS_OrgSettings__c.getOrgDefaults();
    //public GFRS_Funding_Request__c fundReq { get; set; } /** Funding request being modified **/
    public gFRS_Copay_Funding_Request__c fundReqcopay { get; set; } /** Funding request being modified **/
    public GFRS_Location_Copay__c[] lLocs { get; set; } /** Locations being used **/
    public GFRS_Location_Copay__c currentLocation { get; set; } /** Current location to be updated **/
    public GFRS_Location_Copay__c LocationCopay { get; set; } /** Current location to be updated **/
    public GFRS_Location_Copay__c LocationCopaytemp { get; set; } /** Current location to be updated **/
 
    public boolean locationreadonly {get;set;}
    public GFRS_Organization__c organization { get; set; } /** Organization to work with **/
   // public gFRS_OrganizationCopay__c organizationCopay { get; set; } /** Organization to work with **/
    public Contact userContact = null; /** contact that represents the current user (if applicable) **/
    public Attachment w9FormAttachment { get; set; }
    public Attachment taxStatus501DeterminationLetterAttachment {get; set; }
    public attachment w9att{get; set;}
    public Map<String,String> contentItems { get; set; } /** Translations organized by their Name/Keys **/ 
      
    public Boolean isRFI { get; set; }
    public Boolean isEditable { get; set; }             
    public Boolean reqnotsubmitted { get; set; }                 
    public Boolean isLocationEditable { get; set; }
    public Boolean isLocationSelectable { get; set; }
    public Boolean isInternalUser { get; set; }
    public Boolean isDescriptionEditable {get;set;}
    public boolean IsCharitableFundation{get;set;}
    public Boolean shouldStopOnComplete { get; set; }/** True if the page should stop on completion of the page **/
    public Boolean isTaxInfoEditable { get; set; }  /** Whether the tax information is no longer editable This is no longer editable if the user is assigned to an organization**/
    public Boolean isInviteCodeEditable { get; set; }
    public boolean IsCHValueYes {get;set;}
    
    public Integer currentIndex { get; set; } /** Current accordion index only applicable if all organization information has been found**/ 
    public String selectedLocation { get; set; } /** The selected location **/
    public String serializedLocationForm { get; set; }/** Serialized location form **/
    public String initialOrgType { get; set; }
    public String orgType {get;set;}
    public string orgTypeValue{get;set;}
    public string IsCHValue {get;set;}
    public string isCharitablevalue{get;set;}
    public boolean isCharitable{get;set;}
    public string isreligiousvalue{get;set;}
    public boolean isreligious{get;set;}
    public String org {get;set;}
    
    
    public Boolean isOrgUsBasedAndForProfit {
        get{
            if(this.organization.US_Organization__c == 'Yes' && this.organization.Tax_Status__c == 'For-Profit'){
                return true;
            }else{
                return false;
            }
        }
        
        set;
    }
    
    public Boolean isOrgExternal
    {
        get {return( this.organization.RecordType != null && gFRS_Util.RT_ORG_EXTERNAL.equals( this.organization.RecordType.DeveloperName ));}
    }
    
    public Boolean isLocationExternal
        {
        get {return( this.currentLocation != null && this.currentLocation.RecordType != null && gFRS_UTIL.RT_LOC_EXTERNAL.equals( this.currentLocation.RecordType.DeveloperName ));}
    }
    
    public Boolean isW9Editable{
        get{return true;}
    }
    
    /** determines whether the page currently has messages **/
    public Boolean hasMessages
    {
        get { return( ApexPages.hasMessages() ); }
    }
    
    /** True if organization already exists **/
    public Boolean organizationExists
    {
        get { return( this.organization != null && this.organization.id != null ); }
    }
    
     public Boolean fundingRequestExists
    {
        get { return( this.fundReqcopay != null && this.fundReqcopay.id != null ); }
    }
    
    public Boolean locationExists
    {
        get { return( this.currentLocation != null && this.currentLocation.id != null ); }
    }
    
    /** Whether the current organization is US Based **/
    public Boolean isUSBased
    {
        get {return( this.organization == null 
                || this.organization.Country__c == null 
                || IsUSBasedOrg(this.organization.Country__c));}
    }
    
    public Boolean isW9Attached
    {
        get{return ((this.w9FormAttachment != null && this.w9FormAttachment.id != null)?true:false); }
    }

    public Boolean isTaxStatus501DeterminationLetterAttached
    {
        get{return ((this.taxStatus501DeterminationLetterAttachment != null && this.taxStatus501DeterminationLetterAttachment.id != null)?true:false); }
    }

    public string getW9PageUrl
    {
        get {
            if(organizationExists && locationExists)
            {
                 return(gFRS_Utilcopay.initializeLinkcopay( PATH_ORG_B, this.fundReqcopay, PARAM_ORG_ID + '='+String.valueOf(this.organization.id)+'&' + PARAM_LOCATION_ID + '='+String.valueOf(this.currentLocation.id)));
            }
            else
            {
                return null;
            }
        }
    }
    
     public string getOrgTaxIdSectionUrl
     {
        get {
            this.currentIndex = 0;
            String params = '';
            params = gFRS_Util.PARAM_CURRENT_INDEX + '=0&' + PARAM_ORG_ID + '='+String.valueOf(this.organization.id)+'&' + PARAM_LOCATION_ID + '='+String.valueOf(this.currentLocation.id );
            return(gFRS_Utilcopay.initializeLinkcopay( PATH_ORG_A, this.fundReqcopay, params ));
            }
     }
    
    public string getOrgDetailSectionUrl
    {
        get {
            this.currentIndex = 1;
            String params = '';
            params = gFRS_Util.PARAM_CURRENT_INDEX + '=1&' + PARAM_ORG_ID + '='+String.valueOf(this.organization.id)+'&' + PARAM_LOCATION_ID + '='+String.valueOf(this.currentLocation.id );
            return(gFRS_Utilcopay.initializeLinkcopay( PATH_ORG_A, this.fundReqcopay, params ));
            }
    }
    
     public string getLocationSelectSectionUrl
     {
        get {
            this.currentIndex = 3;
            String params = '';
            params = gFRS_Util.PARAM_CURRENT_INDEX + '=3&' + PARAM_ORG_ID + '='+String.valueOf(this.organization.id)+'&' + PARAM_LOCATION_ID + '='+String.valueOf(this.currentLocation.id );
            return(gFRS_Utilcopay.initializeLinkcopay( PATH_ORG_A, this.fundReqcopay, params ));
            }
     }
    
    public Boolean isExtenralHolderAccount
    {
        get{
                return (this.userContact != null && this.userContact.Account.id == (gFRS_Util.getCustomSettingStringValue('Portal_Account_ID') == null ? System.Label.GFRS_HOLDING_ACCOUNT : gFRS_Util.getCustomSettingStringValue('Portal_Account_ID')));
        }
    }
    
    public gFRS_OrgInfoControllerCopay Instance 
    {
        get{return this;}   
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Main contructor class
        * 
        */
    public gFRS_OrgInfoControllerCopay( ApexPages.StandardController std )
    {
        locationreadonly = false;
        at = new attachment();
        w9FormAttachment = new attachment();
        taxStatus501DeterminationLetterAttachment = new Attachment();
        ismorethanonelocation = false;
        copayreadonly = false;
        forprofitOrg = false;
        isnoncopay1 = false;
        isnoncopay2 = false;
        isEditable = false;
        reqnotsubmitted = false;        
        Id organizationId = null;
        Id locationId = null;
        organization = new gFRS_Organization__c(Country__c = 'United States' ); 
        fundReqcopay = new gFRS_Copay_Funding_Request__c();
        if(myGFRSOrgSettings.TraceOrgInfoController__c)system.debug('UserInfo.getUserId()->'+UserInfo.getUserId());
       
        this.userContact = gFRS_Utilcopay.getUserContact( UserInfo.getUserId() );
        this.isInternalUser = userContact == null;
  
        if(myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('this.isInternalUser =' +  this.isInternalUser);
  
        this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( CONTENT_TYPE, UserInfo.getLanguage() );
 
        this.fundReqcopay = (GFRS_copay_Funding_Request__c)std.getRecord();
        
        if(myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('this.fundReqcopay.id=' +  this.fundReqcopay.id);
          
        //query for retrieving field used below
        if(this.fundReqcopay.Id != null)
        {
            this.fundReqcopay = [select Id, Please_enter_the_co_pay_donation_request__c , Do_you_have_a_donation_agreement__c , Are_you_requesting_a_co_pay_donation__c, Date_Submitted__c, External_Sub_status__c,Status__c,  Information_Needed__c, Organization__c, Locationcopay__c, Record_Type_name__c, RecordTypeId, Requested_Amount__c, Total_Program_Budget__c, Sub_Status__c,Authorized_Signer__c, Signing_Authority_Email__c from GFRS_copay_Funding_Request__c where Id = :this.fundReqcopay.Id];
            organizationId = this.fundReqcopay.Organization__c;
            locationId = this.fundreqcopay.Locationcopay__c;
            if(this.fundreqcopay.Please_enter_the_co_pay_donation_request__c != null){
            copayreadonly = true;
            }
            if(this.fundreqcopay.Status__c == 'Intake'){
            reqnotsubmitted = true;
            }            
            if(this.fundreqcopay.Information_Needed__c != null && this.fundreqcopay.External_Sub_status__c == 'RFI'){
                isRFI = true;   
            }else{
                isRFI = false;  
            }
            
            if(myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('this.fundreqcopay.Id=' +  this.fundreqcopay.id +'|organizationId='+ organizationId +'|locationId=' + locationId + '|isRFI=' + isRFI );
        }
        
        if( organizationId == null ) organizationId = getSentTaxId();
        if( locationId == null ) locationId = getSentLocationId();
        this.selectedLocation = String.valueOf( locationId );
        
        if(myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('organizationId='+ organizationId +'|locationId=' + locationId + '|this.selectedLocation=' + this.selectedLocation );
      
        if( organizationId != null ) this.organization = fetchOrganizationById( organizationId );
        
        //http://jira.intranet.roche.com/jira/browse/SFDC-1507
        if(myGFRSOrgSettings.TraceOrgInfoController__c)
        {
        system.debug('this.organization.Country__c='+ this.organization.Country__c);
        system.debug('this.organization=' + this.organization);
        system.debug('this.organization.W9_Form__c=' + this.organization.W9_Form__c); 
        }

        if (this.organization !=  null) {
            GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector(this.organization.Attachments);
            this.w9FormAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(this.organization.W9_Form__c, this.organization.id);
            this.taxStatus501DeterminationLetterAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(this.organization.Tax_Status_501_c_3_Determination_Letter__c, this.organization.id);
        }

        if(myGFRSOrgSettings.TraceOrgInfoController__c)
        {
            system.debug('this.w9FormAttachment.id=' + this.w9FormAttachment.id);
            system.debug('this.w9FormAttachment.name=' + this.w9FormAttachment.name);
        }
         
        SetupCHFoundationDynaFields();
        if( this.organization == null ) resetOrganization();
        
        this.selectedLocation = null;
        fetchLocation( locationId );
        
        /*--
        We want the organization to be editable if there was no funding request,
        or the funding request is new, or that the funding request needs information
        from the organization.
        It is acceptable that once they have found a tax id, they cannot enter a new one.
        --*/
        refreshAccordionVisibility();
             
        this.currentIndex = 0;
        
        if( this.organization != null && this.organization.id != null &&
            this.currentLocation != null && this.currentLocation.id != null
        ){
            this.currentIndex = gFRS_Util.getCurrentIndex();
        }

        this.shouldStopOnComplete = false;
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if( params != null ){
            if( params.containsKey( PARAM_SOC )) this.shouldStopOnComplete = true;
        }
        
        setIsUSBasedPickList(); //set US_Organization__c picklist flag
        
        if(myGFRSOrgSettings.TraceOrgInfoController__c)
        {
            system.debug('System.Label.GFRS_HOLDING_ACCOUNT=' + (gFRS_Util.getCustomSettingStringValue('Portal_Account_ID') == null ? System.Label.GFRS_Holding_ACCOUNT : gFRS_Util.getCustomSettingStringValue('Portal_Account_ID')));
            system.debug('this.userContact='+userContact);
            system.debug('this.isOrgExternal='+this.isOrgExternal);
            system.debug('this.organization.RecordTypeId='+this.organization.RecordTypeId);
            system.debug('this.isEditable='+ this.isEditable);
            system.debug('this.isLocationEditable='+ this.isLocationEditable );
            system.debug('this.isLocationSelectable='+ this.isLocationSelectable );
            system.debug('this.isTaxInfoEditable='+ this.isTaxInfoEditable );
        }   
       // this.organization.TypeCopay__c = 'Co-pay Assistance Foundation';
        
        LocationCopay = new GFRS_Location_Copay__c(Department_Chapter_Country__c = 'United States');
        list<GFRS_Location_Copay__c> lstloc = new list<GFRS_Location_Copay__c>();
        if(this.organization.id != null){
        lstloc = [
                        select Id, RecordTypeId, RecordType.DeveloperName, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Organization__c, Address_Line_1__c, Address_Line_2__c, Address__c, City__c, Department_Chapter_Country__c, Fax__c, Payment_Method__c, Phone__c, State__c, Street_4__c, Street__c, Vendor_ID__c, Vendor_Name_1__c, Vendor_Name_2__c, Vendor_Name_3__c, Vendor_Name_4__c, Vendor_Name__c, Zip__c,  City_1__c, State_1__c, Country_1__c, Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c, Province_Region_Territory__c, PO_Box_available__c, Department_PO_Box__c
                        From GFRS_Location_Copay__c
                        where Organization__c = :this.organization.id ORDER BY CreatedDate DESC limit 1
                    ];
        if(lstloc.size()>0){
        LocationCopay = lstloc[0];  
        //LocationCopaytemp = lstloc[0]; 
        locationreadonly = true;
        
         string copayrequestid = ApexPages.currentPage().getParameters().get('id');
      if(copayrequestid != null){
      GFRS_copay_Funding_Request__c copayrequest = [select Information_Needed__c from GFRS_copay_Funding_Request__c where id =: copayrequestid]; 
      if(copayrequest.Information_Needed__c != null){
      locationreadonly = ! gFRS_Util.multiSelectHasItem( copayrequest.Information_Needed__c, 'Location' );
      }
      }
   
        
        
        }          
        }
        
    }
         
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Determines the id of the organization based on the taxid or organization id
        * 
        */
    public Id fetchOrganizationByTaxOrOrg( Boolean useTaxId, String taxId, String organizationId )
    {
        GFRS_Organization__c result = null;
        try
        {
            if( useTaxId )
            {
                result = [ select id from GFRS_Organization__c where Tax_Id__c = :taxId limit 1 ];
            } else {
                result = [ select id from GFRS_Organization__c where Non_US_Organization_ID__c = :organizationId limit 1 ];
            }
        } 
        catch( Exception err )
        {
            System.debug( 'unable to find organization[' + taxId + ',' + organizationId + ']:' + err.getMessage() );
            result = null;
        }
        
        if( result != null ){
            return( result.id );
        } else {
            return( null );
        }
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Fetches the appropriate organization and location information for a specific organization id
        * 
        */ 
    public GFRS_Organization__c fetchOrganizationById( id orgId )
    {
        this.lLocs = new GFRS_Location_Copay__c[]{};
        
        //-- all organizations are subject to firewall, the value is only checked if of type imed.
        GFRS_Organization__c result = null;
        
        if( orgId != null ){
            try {
                result = [ select Id,  
                Is_this_a_political_or_sectarian_organiz__c, 
                Is_this_a_religious_organization__c, 
                Is_this_support_for_a_religious_purpose__c, 
                How_many_physicians_are_in_the_group_pra__c, 
                Is_your_organization_a_charitable_founda__c, 
                Is_this_organization_owned_in_whole_or_i__c, 
                Is_your_organization_an_individual_grou__c, 
                 Fiscal_Year_Ending__c, Actual_Annual_Revenue_for_Prior_Fiscal_Y__c,Projected_Annual_Revenue_for_Fiscal_Year__c,Actual_YeartoDate_Annual_Revenue_for_Fis__c,
                Is_your_organization_a_Sole_Proprietorsh__c, 
                OwnerId, IsDeleted, RecordTypeId, RecordType.DeveloperName, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, ACCME_Accreditations__c, Account__c, Authorized_Signer_Name__c, Description__c, Email_Address_Person_with_Authority__c, Firewall_for_Strategic_Promo_Mktg__c, Grant_Requestor_Subject_to_Firewall__c, Country__c, Mission_Statement__c, Number_of_Employees_Working_in_Complianc__c, Number_of_Employees__c, Number_of_Employees_with_Advanced_Degree__c, Operational_Budget__c, Other_Accredidations__c, Outstanding_Accounts_Payable__c, Is_Part_of_Parent_Org__c, Parent_Organization_Tax_ID__c, Non_US_Organization_ID__c, Salary_of_the_Highest_Paid_Executive__c, State_Affiliation__c, Tax_Id__c, Tax_Status__c, Type__c , TypeCopay__c,IsCHOrg__c, Website_Address__c, of_Physicians_in__c, NCI_Designated_Cancer_Center__c, Accreditation_s_Received__c, Audited_financials_for_the_previous_year__c, Form_990_for_the_previous_year__c, Form_990_for_the_previous_two_year__c, Form_990_for_the_previous_three_year__c, Audited_Financials_for_the_previous_URL__c, Form_990_for_the_previous_two_year_URL__c, Form_990_for_for_the_previous_three_URL__c, Form_990_for_the_previous_year_URL__c, Organization_Name__c, Do_you_have_Legal_Authority_to_Sign__c, Roche_Prescriber__c, Roche_Purchaser__c, Medicare_Guideline_Development__c, Pending_Litigation__c, Physician_Ownership__c, Sister_Parent_Org_Strategic_Promo_Mktg__c, Strategic_Promo_Mkt_Related_Services__c, W8BEN_Status__c, US_Organization__c, Parent_Org_Name__c,W9_Form__c,W9_Form_W_8BEN_Form_URL__c, Tax_Status_501_c_3_Determination_Letter__c, Tax_Status_501_c_3_Det_Letter_URL__c,
                    (select id,ParentID,name from Attachments)
                    from GFRS_Organization__c
                    where id = :orgId limit 1
                ];
                
                if( result != null )
                {                 
                    //-- save the intial organization type, so it can be compared later
                    this.initialOrgType = result.TypeCopay__c;
                    
                    this.lLocs = [
                        select Id, RecordTypeId, RecordType.DeveloperName, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Organization__c, Address_Line_1__c, Address_Line_2__c, Address__c, City__c, Department_Chapter_Country__c, Fax__c, Payment_Method__c, Phone__c, State__c, Street_4__c, Street__c, Vendor_ID__c, Vendor_Name_1__c, Vendor_Name_2__c, Vendor_Name_3__c, Vendor_Name_4__c, Vendor_Name__c, Zip__c,  City_1__c, State_1__c, Country_1__c, Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c, Province_Region_Territory__c, PO_Box_available__c, Department_PO_Box__c
                        From GFRS_Location_Copay__c
                        where Organization__c = :result.id limit 1
                    ]; 
                    if(this.lLocs.size()>0){
                    ismorethanonelocation = true;
                    }
                    
                    system.debug( 'locs[' + result.id + ']:' + this.lLocs);
                } 
                else
                {
                     if(myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('fetchOrganizationById ->results NOT found' );
                    this.initialOrgType=null;
                }
                
            } catch( Exception err )
            {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find Organization:' + orgId ));
                result = null;
                this.lLocs = new GFRS_Location_Copay__c[]{};
                this.currentLocation = new GFRS_Location_Copay__c();
            }
        } 
        else
        {
            if(myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('fetchOrganizationById -> orgId IS null' );
            this.initialOrgType=null;
        }
        
        return( result );
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Fetches a specific location
        * 
        */ 
    public GFRS_Location_Copay__c fetchLocation( id locationId )
    {
        this.currentLocation = new GFRS_Location_Copay__c();
        //this.w9FormAttachment = null;
        
        if( locationId == null ) return( this.currentLocation );
        
        try {
            this.currentLocation = [
                select Id, IsDeleted, Name, RecordTypeId, RecordType.DeveloperName, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Organization__c, Address_Line_1__c, Address_Line_2__c, Address__c, City__c, Department_Chapter_Country__c, Fax__c, Payment_Method__c, Phone__c, State__c, Street_4__c, Street__c, Vendor_ID__c, Vendor_Name_1__c, Vendor_Name_2__c, Vendor_Name_3__c, Vendor_Name_4__c, Vendor_Name__c, Zip__c,  City_1__c, State_1__c, Country_1__c, Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c, Province_Region_Territory__c, PO_Box_available__c, Department_PO_Box__c,
                (select id,ParentID,name from Attachments)
                From GFRS_Location_Copay__c
                where id = :locationId
                and Organization__c = :this.organization.id
                limit 1
            ];
            
        } catch( Exception err ){
            if(myGFRSOrgSettings.TraceOrgInfoController__c) System.debug('fetchLocation()->location could not be found[' + locationId + ']:' + err.getMessage() );
            this.currentLocation = new GFRS_Location_Copay__c();
        }
        
        return( this.currentLocation );
    }
    
    
    
    
    public pagereference invitecoderefresh(){
    if(fundReqcopay.Are_you_requesting_a_co_pay_donation__c == 'No'){
    fundReqcopay.Are_you_requesting_a_co_pay_donation__c = 'Yes' ; 
     ApexPages.PageReference pageRef = new ApexPages.PageReference('/apex/gFRS_Org_Info');
       return pageRef;
     }
     else{
     
     if( this.fundReqcopay.Do_you_have_a_donation_agreement__c == 'No'  ){
                   ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, system.label.gFRS_no_donation_agreement_for_Copay_request ) );
                 return null;
     }
     
     if( this.fundReqcopay.Do_you_have_a_donation_agreement__c == null ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Do you have a donation agreement with Genentech ?: You must enter a value' ));
               return null;
     }
     if( this.fundReqcopay.Please_enter_the_co_pay_donation_request__c == null ){
               
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Please enter the co-pay donation request invite code: You must enter a value' ));
                return null;
     }
     if( this.fundReqcopay.Please_enter_the_co_pay_donation_request__c != null ){
      list<GFRS_CopayUser__c> lstcopayuser = new list<GFRS_CopayUser__c>();
        lstcopayuser = [select User__r.email, Invite_Code__c from GFRS_CopayUser__c where User__r.email =: UserInfo.getUserEmail()];
        if(!lstcopayuser[0].Invite_Code__c.equals(this.fundReqcopay.Please_enter_the_co_pay_donation_request__c)){
         invitecodetrial  += 1;
         if(invitecodetrial > 2){
             ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'You have exceeded the maximum number of tries to enter the invite code. Please contact gnecst@gene.com' ));
         }
         else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Incorrect invite code, please enter again.' ));
         }
        }
                       
               
                
     }
     }
     if(this.fundReqcopay.Id != null){
         gFRS_Util_NoSharecopay.saveLockedFundingRequestcopay( this.fundReqcopay );
     }
     return null;
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Checks the organization to see if it already exists (and replace the instance if it is found). Used as action under [Continue] button.
        * 
        */  
        
        
       
    public void refreshOrganization()
    {
        if(validateTaxInfo())
        { 
           GFRS_Organization__c oldOrg = new GFRS_Organization__c( Country__c = this.organization.Country__c );
        
            //-- assign only the one needed
            if( isUSBased )
            { 
                //-- validate that the taxId is a valid format
                Pattern taxPattern = Pattern.compile( '^\\d{2}[-]\\d{7}$' );
                Matcher taxMatcher = taxPattern.matcher( this.organization.Tax_Id__c );
            
                if( !taxMatcher.matches() )
                {
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.severity.ERROR, System.Label.gFRS_ERROR_TAX_FORMAT ));
                    return;
                }
            
                oldOrg.Non_US_Organization_ID__c = null;
                oldOrg.W8BEN_Status__c = null;
                oldOrg.US_Organization__c='Yes';
                oldOrg.Tax_Id__c = this.organization.Tax_Id__c;
                oldOrg.Tax_Status__c = this.organization.Tax_Status__c;
            } 
            else
            {   oldOrg.Organization_Name__c = this.organization.Organization_Name__c;
                oldOrg.Non_US_Organization_ID__c = this.organization.Non_US_Organization_ID__c;
                oldOrg.W8BEN_Status__c = this.organization.W8BEN_Status__c;
                oldOrg.US_Organization__c='No';
                oldOrg.Tax_Id__c = null;
                oldOrg.Tax_Status__c = this.organization.Tax_Status__c;
            }
            
            Id orgId = this.fetchOrganizationByTaxOrOrg( this.isUSBased, this.organization.Tax_Id__c, this.organization.Non_US_Organization_ID__c );
            system.debug('check current tax id'+this.organization.Tax_Id__c);
            
            //-- update ONLY if a value was found
            GFRS_Organization__c result = this.fetchOrganizationById( orgId );
        
            if( result != null )
            {
                this.organization = result;
                SetupCHFoundationDynaFields();
                //-- fetch the current location again if one currently exists
                if( this.currentLocation != null && this.currentLocation.id != null ) this.fetchLocation( this.currentLocation.id );
                //if( this.w9FormAttachment == null ) this.w9FormAttachment = new Attachment( ParentId = this.organization.id );
                GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( this.organization.Attachments );
                this.w9FormAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.organization.W9_Form__c, this.organization.id );
                this.taxStatus501DeterminationLetterAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.organization.Tax_Status_501_c_3_Determination_Letter__c, this.organization.id );
                System.debug( 'PN: this.w9FormAttachment: ' + this.w9FormAttachment );
             }
            else
            {   
                String orgName = null;
                if(!isUSBased){                 
                     orgName =this.organization.Organization_Name__c;
                     if(orgName==null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Orgranization Name: You must enter a value'));
                        return;
                     }
                
                }
                this.resetOrganization();
                this.organization.Organization_Name__c = orgName;
            }

        refreshAccordionVisibility();
        
        if(this.isInternalUser && this.isOrgExternal)
        {
          //If user is internal and org is externaly owned do nothing!
        }
        else
        {
            this.organization.Tax_Id__c = oldOrg.Tax_Id__c;
            this.organization.Non_US_Organization_ID__c = oldOrg.Non_US_Organization_ID__c;
            this.organization.Country__c = oldOrg.Country__c;
            this.organization.W8BEN_Status__c = oldOrg.W8BEN_Status__c;
            this.organization.Tax_Status__c = oldOrg.Tax_Status__c;
            this.organization.US_Organization__c = oldOrg.US_Organization__c;
            
            //if organization is internal and user is external clear organization data
            if( result != null && !this.isOrgExternal && !this.isInternalUser )
            { 
                system.debug('clearing data...');
                  
                  result.of_Physicians_in__c               = null;
                  result.Operational_Budget__c             = null;
                  result.Website_Address__c                = null;
                  result.Mission_Statement__c              = null;
                  result.Number_of_Employees__c            = null;
                  result.Roche_Purchaser__c                = null;
                  result.Roche_Prescriber__c               = null;
                  result.Medicare_Guideline_Development__c = null;
                  result.Physician_Ownership__c            = null;
                  result.ParentOrganization__c             = null;
                  result.Parent_Org_Name__c                = null;
                  result.Parent_Organization_Tax_ID__c     = null;
            }
        }
        //http://jira.intranet.roche.com/jira/browse/SFDC-1455
        if( this.organization!=null)
        {
           if(this.organization.Tax_Status__c == '501 (c)(3)' || this.organization.Tax_Status__c == '501 (c)(6)' || this.organization.Tax_Status__c == 'Governmental Org' || (this.organization.US_Organization__c == 'No' && this.organization.Tax_Status__c == 'Non-Profit'))
           {
             this.organization.Physician_Ownership__c='No';
           }
           if(this.organization.Tax_Status__c == 'For-Profit'){
           forprofitOrg = true;
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
    private Boolean validateTaxInfo(){

        Boolean isValid = true;
        if(organization.Country__c != 'United States'){
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Non US Orgs are not eligible for the selected funding type ' ));
                isValid = false;
        }
        
        if( isUSBased ) // Organization based in US
        {
            if( this.organization.Tax_Id__c == null ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, System.Label.gFRS_ERROR_TAX_ID ));
                isValid = false;
            }
            if( this.organization.Tax_Status__c == null ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, System.Label.gFRS_ERROR_TAX_STATUS));
                isValid = false;
            }
            if( this.organization.Tax_Status__c == 'Governmental Org' || this.organization.Tax_Status__c == 'For-Profit' ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'This tax status is not eligible for Co-pay Assistance Foundation Donations.'));
                isValid = false;
            }
        } 
        
        return( isValid );
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Method to find the current location
        * 
        */
    public void setLocation()
    {
        if( this.selectedLocation == null || this.selectedLocation == '' )
        {
            this.currentLocation = new GFRS_Location_Copay__c();
            this.isLocationEditable = true;
            return;
        }
        
        Id selectedLocationId = null;
        try
        {
            selectedLocationId = Id.valueOf( this.selectedLocation );
        }
        catch( Exception err )
        {
             if(myGFRSOrgSettings.TraceOrgInfoController__c)system.debug('setLocation()-> selectedLocationId ex sink ok');
        }
        
        Map<id,GFRS_Location_Copay__c> locationMap = new Map<id,GFRS_Location_Copay__c>( this.lLocs );

        if( locationMap.containsKey( selectedLocationId ))
        {
            this.currentLocation = locationMap.get( selectedLocationId );

            if( gFRS_Util.RT_LOC_INTERNAL.equals( this.currentLocation.RecordType.DeveloperName) )
            {
                this.isLocationEditable = true;
            } else if(isInternalUser == true){
                this.isLocationEditable = false;
            }
        } 
        else
        {
            this.currentLocation = new GFRS_Location_Copay__c();
            this.isLocationEditable = true;
        }    
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Validates the page before submission
        * 
        */ 
    public Boolean validateSaveOrganization()
    {
        Boolean isValid = true;
        Boolean soleProprietorshipRequired = false;

        if( this.organizationExists == true ){
            //if Organization exists then 'Is_your_organization_a_Sole_Proprietorsh__c' field should not be requred. Unless Request is in RFI.
            if( this.fundreqcopay.Sub_Status__c == gFRS_Util.REQUEST_STATUS_RFI ){
                soleProprietorshipRequired = true;      
            }else{
                soleProprietorshipRequired = false; 
            }
        
        }else if( this.organizationExists == false ){
            soleProprietorshipRequired = true;      
        }
        
        if(soleProprietorshipRequired && this.isOrgUsBasedAndForProfit == true && this.organization.Is_your_organization_a_Sole_Proprietorsh__c == null){
            
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_Is_Org_Sole_Proprietorship_Error  ));  
                return false;
                
        }

        
        if( ApexPages.hasMessages() )
        {
            return( false );
        }
      //  if( this.initialOrgType != null && this.initialOrgType != '' && !this.initialOrgType.equals( this.organization.TypeCopay__c )){
       //     isValid = false;
       //     ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_ORG_TYPE_CHANGED +' ' + this.initialOrgType ));
       //     this.organization.TypeCopay__c = this.initialOrgType;
       //     orgTypeValue = this.initialOrgType;
       // }
        
        SetupCHFoundationDynaFields();
    
        return( isValid );
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Validates saving the location
        * 
        */  
    public Boolean validateSaveLocation()
    {
        Boolean isValid = true;        
 
        if( isValid && (this.LocationCopay.Name == null) ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select location or insert the new one (Chapter Name and W9/WBEN fields are required)'));
            currentIndex=3;
            isValid = false;
        }
        //If Org is not US Based and has W8 status-need W8 attachment.
        if(this.organization.W8BEN_Status__c !=null && this.organization.W8BEN_Status__c=='Yes')
        {
                if(!isW9Attached)
                {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.gFRS_MSG_W9W8_MISSING));
                isValid = false;
                }
        }
        else if(this.organization.W8BEN_Status__c == null)
        {
                if(!isW9Attached)
                {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.gFRS_MSG_W9W8_MISSING));
                isValid = false;
                }
        }

        //check if 501(c) attachment has been uploaded when Tax Status = 501(c)
        if(this.organization.Tax_Status__c != null && this.organization.Tax_Status__c == '501 (c)(3)') {
            if(!isTaxStatus501DeterminationLetterAttached) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.gFRS_MSG_501C_ATTACHMENT_MISSING));
                isValid = false;
            }
        }

        return( isValid );
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Validates the W9 information has been uploaded
        * 
        */   
    public Boolean validateRequiredFiles()
    {
        Boolean isValid = true;
        
        if( ApexPages.hasMessages() ){
            isValid = false;
        }

        if( this.organization.W8BEN_Status__c != null && this.organization.W8BEN_Status__c == gFRS_Util.NO ){
            //-- w9 is not needed
        } else if( this.w9FormAttachment == null || this.w9FormAttachment.name == null ){
            ApexPages.addMessage( new ApexPages.message( ApexPages.Severity.ERROR, System.Label.gFRS_MSG_W9W8_MISSING ));
            isValid = false;
        }

        //check if 501(c) attachment has been uploaded when Tax Status = 501(c)
        if(this.organization.Tax_Status__c != null && this.organization.Tax_Status__c == '501 (c)(3)') {
            if(this.taxStatus501DeterminationLetterAttachment == null || this.taxStatus501DeterminationLetterAttachment.name == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.gFRS_MSG_501C_ATTACHMENT_MISSING));
                isValid = false;
            }
        }
        
        return( isValid );
    }
    public attachment at{get; set;}
    
    public void uploadW9Form(){
        if( this.organization == null || this.organization.id == null ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.severity.ERROR, System.Label.gFRS_ERROR_ORG_REQUIRED ));
            return;
        }
        
        try{ 
        system.debug(w9att);
            this.currentIndex = 3;
            
            Attachment oldAttachment = this.w9FormAttachment;
            
            Attachment newAttachment = new Attachment( ParentId = this.organization.Id, name = w9FormAttachment.name );
            newAttachment.body = w9FormAttachment.body;
            gFRS_Util_NoShare.saveLockedAttachment( newAttachment );
            
            newAttachment.body = null;
            oldAttachment.body = null;
            
            this.organization.W9_Form__c = newAttachment.id;
            
            //refactoring for SFDC-1724 
            //-- touch the organization for record type change consideration
            this.organization.Organization_LastModifiedBy__c = UserInfo.getuserId();
            organization.IsValidationExternalOnly__c='Yes';
            this.organization.RecordTypeId = [SELECT id from RecordType where SobjectType = 'GFRS_Organization__c' and DeveloperName='Copay'][0].ID;

            gFRS_Util_NoShare.saveLockedOrganization( this.organization );
            
            this.w9FormAttachment = [ select id,ParentID,name from Attachment where id = :newAttachment.id ];
            this.w9FormAttachment.body = null;
        } catch( Exception err ){
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
        } finally {
            if (this.w9FormAttachment != null && this.w9FormAttachment.body != null) this.w9FormAttachment.body = null;
        }
    }

    public void uploadTaxStatus501DeterminationLetter(){
        if( this.organization == null || this.organization.id == null ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.severity.ERROR, System.Label.gFRS_ERROR_ORG_REQUIRED ));
            return;
        }

        try{

            this.currentIndex = 3;

            Attachment newAttachment = new Attachment( ParentId = this.organization.Id, name = taxStatus501DeterminationLetterAttachment.name );
            newAttachment.body = taxStatus501DeterminationLetterAttachment.body;
            gFRS_Util_NoShare.saveLockedAttachment( newAttachment );

            newAttachment.body = null;

            this.organization.Tax_Status_501_c_3_Determination_Letter__c = newAttachment.id;

            this.organization.Organization_LastModifiedBy__c = UserInfo.getuserId();
            organization.IsValidationExternalOnly__c='Yes';
            this.organization.RecordTypeId = [SELECT id from RecordType where SobjectType = 'GFRS_Organization__c' and DeveloperName='Copay'][0].ID;

            gFRS_Util_NoShare.saveLockedOrganization( this.organization );

            this.taxStatus501DeterminationLetterAttachment = [ select id,ParentID,name from Attachment where id = :newAttachment.id ];
            this.taxStatus501DeterminationLetterAttachment.body = null;
        } catch( Exception err ){
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
        } finally {
            if (this.taxStatus501DeterminationLetterAttachment != null && this.taxStatus501DeterminationLetterAttachment.body != null) this.taxStatus501DeterminationLetterAttachment.body = null;
        }
    }
     
    /** ### PageReference methods ### **/

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description This method is needed to save values from Org Details accordion
        * 
        */  
        
    public void disableinvitecodefields1(){
     if(fundReqcopay.Are_you_requesting_a_co_pay_donation__c == 'No'){  
     isnoncopay1 = true;
     isnoncopay2 = true;
    // fundReqcopay.Do_you_have_a_donation_agreement__c = '';
    // fundReqcopay.Please_enter_the_co_pay_donation_request__c = '';
     }
     if(fundReqcopay.Are_you_requesting_a_co_pay_donation__c != 'No'){  
     isnoncopay1 = false;
     isnoncopay2 = false;
     }
        
    }
    
    
    public void disableinvitecodefields2(){
    if(fundReqcopay.Do_you_have_a_donation_agreement__c == 'No'){  
     isnoncopay2 = true;
       if(this.fundReqcopay.Are_you_requesting_a_co_pay_donation__c == 'Yes'){
           ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, system.label.gFRS_no_donation_agreement_for_Copay_request ) );
       }
     
     }
     if(fundReqcopay.Do_you_have_a_donation_agreement__c != 'No'){  
     isnoncopay2 = false;
     
     }
        
    }
    
   
          
    public ApexPages.PageReference saveOrganizationDetails(){
        if( validateSaveOrganization() == false){
            //-- display error message if needed
            return( null );
        }
        //-- touch the organization for record type change consideration
        this.organization.Organization_LastModifiedBy__c = UserInfo.getuserId();

        SavePoint sp = Database.setSavePoint();
        try {
            
           
                 this.organization.RecordTypeId = [SELECT id from RecordType where SobjectType = 'GFRS_Organization__c' and DeveloperName='Copay'][0].ID;
            
            
            if(this.organizationExists == false){
                Account a = gFRS_Util_NoShare.createAccountFromOrganization( this.organization );
                this.organization.Account__c = a.Id;
                this.organization.IsValidationExternalOnly__c='Yes';
                gFRS_Util_NoShare.saveLockedOrganization( this.organization );
            } else {
                this.organization.IsValidationExternalOnly__c='Yes';
                gFRS_Util_NoShare.saveLockedOrganization( this.organization );
            }
            //-- always try to associate the user with the account
            //-- the tax information is no longer editable if currently assigned to an organization
            if(!this.isInternalUser){
               system.debug('==');
                this.isTaxInfoEditable = !gFRS_Util_NoShare.associateUserWithAccount( UserInfo.getUserId(), this.organization.Account__c, this.organization.id );
            }   
            System.debug( 'could associate user with account:' + !this.isTaxInfoEditable );
            if( this.fundReqcopay != null && this.fundreqcopay.id != null ){
                this.fundreqcopay.Organization__c = this.organization.id;
            }
            
            //-- please note that the page refreshes after this is called, and the w9FormAttachment is loaded often from the constructor when calling org_info_file
            if( this.w9FormAttachment == null ) this.w9FormAttachment = new Attachment( ParentId = this.organization.id );
            if( this.taxStatus501DeterminationLetterAttachment == null ) this.taxStatus501DeterminationLetterAttachment = new Attachment( ParentId = this.organization.id );
        } catch( Exception err ){
            Database.rollback(sp);
            String errMsg = gFRS_Util.getPrettyMessage(err);
            System.debug( 'error occurred:' + errMsg );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ) );
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
    public ApexPages.PageReference back()
    {
        return( new ApexPages.PageReference( PATH_HOME ));
    }

    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Method called that returns to the 'next' page
        * 
        */    
    public ApexPages.PageReference next(){
        if( !validateRequiredFiles() ) return( null );
        
        if( this.shouldStopOnComplete ){
            return( new ApexPages.PageReference( PATH_HOME ));
        } else {
             //-- move to the decision result IF there was a funding request sent
            String path = this.fundreqcopay != null && this.fundreqcopay.id != null ? PATH_COMPLETE_VIEWcopay : PATH_COMPLETEcopay;
            return( new ApexPages.PageReference( gFRS_Utilcopay.initializeLinkcopay( path, this.fundReqcopay, PARAM_ORG_ID + '='+String.valueOf(this.organization.id)+'&' + PARAM_LOCATION_ID + '='+String.valueOf(this.locationcopay.id)) ) );
        }   
    }
     
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Method called to perform final submission
        * 
        */   
        
     public ApexPages.PageReference saveLocationDetailscopay(){
     
     return (new ApexPages.PageReference('/apex/GFRS_DecisionCopay'));
     } 
     
        
    public ApexPages.PageReference saveLocationDetails(){
        if( validateSaveLocation() == false){
            return( null );
        }
        try {

                        
            String invalidOrgCode = null;
            if( this.organization.TypeCopay__c != 'Charitable Foundation' &&
                this.organization.TypeCopay__c != 'Co-pay Assistance Foundation' &&
                this.organization.TypeCopay__c != 'Patient Organization' &&
                this.organization.TypeCopay__c != 'Other' 
                
            ){
                invalidOrgCode = gFRS_ErrorController.CODE_INV_ORGcopay;
            }
            
            
            if( invalidOrgCode != null ){
                
                return( new ApexPages.PageReference( PATH_INV_ORG + invalidOrgCode ));
            }
            
            
            
              string copayrequestid = ApexPages.currentPage().getParameters().get('id');
              boolean islocationRFI = false;
      if(copayrequestid != null){
      GFRS_copay_Funding_Request__c copayrequest = [select Information_Needed__c from GFRS_copay_Funding_Request__c where id =: copayrequestid]; 
      if(copayrequest.Information_Needed__c != null){
      islocationRFI = gFRS_Util.multiSelectHasItem( copayrequest.Information_Needed__c, 'Location' );
      }
      }
            
            if(islocationRFI){
            GFRS_Location_Copay__c loccloned = new GFRS_Location_Copay__c ();
            loccloned.Organization__c = this.organization.Id;
            loccloned.Name = this.LocationCopay.Name;
            loccloned.Address__c = this.LocationCopay.Address__c;
            loccloned.City__c = this.LocationCopay.City__c;
            loccloned.State__c = this.LocationCopay.State__c;
            loccloned.Province_Region_Territory__c = this.LocationCopay.Province_Region_Territory__c;
            loccloned.Zip__c = this.LocationCopay.Zip__c;
            loccloned.Department_Chapter_Country__c = this.LocationCopay.Department_Chapter_Country__c;
            boolean islocchanged = false;
                  LocationCopaytemp = new GFRS_Location_Copay__c();
            LocationCopaytemp = [select Name, Address__c, City__c, State__c, Province_Region_Territory__c, Zip__c, Department_Chapter_Country__c, PO_Box_available__c, Department_PO_Box__c from GFRS_Location_Copay__c where id =: this.LocationCopay.Id];
        
         system.debug(this.LocationCopaytemp.Name.deleteWhitespace());
            system.debug(this.LocationCopay.Name.deleteWhitespace());
       
            if(this.LocationCopaytemp.Name != null && this.LocationCopay.Name != null)
            if(this.LocationCopaytemp.Name.deleteWhitespace() != this.LocationCopay.Name.deleteWhitespace()){
               islocchanged = true;
            }
            
            if(this.LocationCopaytemp.Address__c != null && this.LocationCopay.Address__c != null)
            if(this.LocationCopaytemp.Address__c.deleteWhitespace() != this.LocationCopay.Address__c.deleteWhitespace()){
            islocchanged = true;
            }
            
            if(this.LocationCopaytemp.City__c != null && this.LocationCopay.City__c != null)
            if(this.LocationCopaytemp.City__c.deleteWhitespace() != this.LocationCopay.City__c.deleteWhitespace()){
            islocchanged = true;
            }
            
            if(this.LocationCopaytemp.State__c != null && this.LocationCopay.State__c != null)
            if(this.LocationCopaytemp.State__c.deleteWhitespace() != this.LocationCopay.State__c.deleteWhitespace()){
            islocchanged = true;
            }
            
            //if(this.LocationCopaytemp.Province_Region_Territory__c != null && this.LocationCopaytemp.Province_Region_Territory__c != '')
           // if(this.LocationCopaytemp.Province_Region_Territory__c.deleteWhitespace() != this.LocationCopay.Province_Region_Territory__c.deleteWhitespace()){
           // }
            
            if(this.LocationCopaytemp.Zip__c != null && this.LocationCopay.Zip__c != null)
            if(this.LocationCopaytemp.Zip__c.deleteWhitespace() != this.LocationCopay.Zip__c.deleteWhitespace()){
            islocchanged = true;
            }
            
            if(this.LocationCopaytemp.Department_Chapter_Country__c != null && this.LocationCopay.Department_Chapter_Country__c != null)
            if(this.LocationCopaytemp.Department_Chapter_Country__c.deleteWhitespace() != this.LocationCopay.Department_Chapter_Country__c.deleteWhitespace() ){
            islocchanged = true;
            }
            
            if(islocchanged){
            insert loccloned;
            this.fundReqcopay.Locationcopay__c = loccloned.Id;
            }
            else{
            update this.LocationCopay;
            }
            //this.fundReqcopay.Locationcopay__c = loccloned.Id;
            string infoneeded = this.fundReqcopay.Information_Needed__c; 
            if(infoneeded == 'Location'){
            this.fundReqcopay.Information_Needed__c ='';
            infoneeded = '';
            }
            if(infoneeded.contains('Location')){
            infoneeded = infoneeded.replace(';Location','');
            infoneeded = infoneeded.replace('Location;','');
            this.fundReqcopay.Information_Needed__c = infoneeded;
            }
            //update this.fundReqcopay;
            gFRS_Util_NoSharecopay.saveLockedFundingRequestcopay(this.fundReqcopay);
            }
            else{
            if( this.LocationCopay.id == null ) LocationCopay.Organization__c = this.organization.Id;
            upsert LocationCopay;
            }


            String path = this.fundreqcopay != null && this.fundreqcopay.id != null ? PATH_COMPLETE_VIEWcopay : PATH_COMPLETEcopay;
            return( new ApexPages.PageReference( gFRS_Utilcopay.initializeLinkcopay( path, this.fundReqcopay, PARAM_ORG_ID + '='+String.valueOf(this.organization.id)+'&' + PARAM_LOCATION_ID + '='+String.valueOf(this.locationcopay.id)) ) );
        } catch( Exception err ){
            ApexPages.addMessages(err);
            return (null);
        }
    }
     
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Validates the W9 information has been uploaded
        * 
        */ 
    public ApexPages.PageReference validateW9File(){

         if( this.w9FormAttachment == null || this.w9FormAttachment.name == null ){
            ApexPages.addMessage( new ApexPages.message( ApexPages.Severity.ERROR, System.Label.gFRS_MSG_W9W8_MISSING ));
            this.currentIndex = 3;
        } else if(this.w9FormAttachment != null && this.w9FormAttachment.name != null){
            this.currentIndex = 4;  
        }
        
        return null;
    }

    public ApexPages.PageReference validateTaxStatus501DeterminationLetter(){

        if(this.organization.Tax_Status__c != null && this.organization.Tax_Status__c == '501 (c)(3)') {
            if(taxStatus501DeterminationLetterAttachment == null || taxStatus501DeterminationLetterAttachment.name == null){
                this.currentIndex = 3;
                ApexPages.addMessage( new ApexPages.message( ApexPages.Severity.ERROR, Label.gFRS_MSG_501C_ATTACHMENT_MISSING));
            } else {
                this.currentIndex = 4;
            }
        }
        return null;
    }

    public ApexPages.PageReference validateW9FileAndTaxStatus501Attachment() {
        validateW9File();
        Integer curIndW9 = this.currentIndex;
        validateTaxStatus501DeterminationLetter();
        Integer curInd501 = this.currentIndex;
        this.currentIndex = curIndW9 < curInd501? curIndW9 : curInd501;
        return null;
    }

    public ApexPages.PageReference savenCntRevenueDetails(){

        if( this.organization.Fiscal_Year_Ending__c == null || 
           this.organization.Projected_Annual_Revenue_for_Fiscal_Year__c == null ||
           this.organization.Actual_YeartoDate_Annual_Revenue_for_Fis__c == null ||
           this.organization.Actual_Annual_Revenue_for_Prior_Fiscal_Y__c == null 
         ){
           ApexPages.addMessage( new ApexPages.message( ApexPages.Severity.ERROR, System.Label.gFRS_MSG_W9W8_MISSING ));
       
        // this.currentIndex = 3;
         }
         else{
        //saveOrganizationDetails();
         }
      
         
        return null;
    }
    
    
    
    
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description  Method used for partial rerender Tax ID accordion while organization location is changed
        * 
        */ 
 /* Sudhakar  public ApexPages.PageReference partialRerenderTaxIdAccordion()
   {    
       if(myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('partialRerenderTaxIdAccordion()->this.organization.Country__c '+ this.organization.Country__c);
       if(!isUSBased){
               this.organization.Organization_Name__c      = null;
               this.organization.Non_US_Organization_ID__c =null;
               this.organization.W8BEN_Status__c           = null;                                       
               this.organization.Tax_Status__c             =null;  
       }
       setIsUSBasedPickList(); //set US_Organization__c picklist flag
       
       return( null );
   }  */
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description used for partial refresh org type section.
        * 
        */ 
        
     public PageReference isChartableOrgchange()
    {
    if(isCharitablevalue =='Yes')
        {
        isCharitable = true;
        }
        else{
        isCharitable = false;
        }
      return null;  
    }
    
     public PageReference orgreligiousChanged()
    {
    if(isreligiousvalue =='Yes')
        {
        isreligious = true;
        }
     else{
     isreligious = false;
     }   
      return null;  
    }
       
        
    public PageReference OrgTypeOnChange()
    {
        if(orgTypeValue == CHFoundationType)
        {
            IsCharitableFundation = true;
            if(IsCHValue=='Yes')
            {
                IsCHValueYes=true;
            }
            else
            {
                IsCHValueYes=false;
                
            }
            system.debug('getIsCharitableFundation()==true.  Org Type get :'+  orgTypeValue );
        }
        else
        {
            IsCharitableFundation = false;
            IsCHValueYes = false;
            IsCHValue = null;
            
            organization.IsCHOrg__c = null;
            organization.of_Physicians_in__c = null;
            system.debug('getIsCharitableFundation()==false.  Org Type get :'+  orgTypeValue);
            
        }   
        return null;
    } 
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description used for partial rendering details accordion
        * 
        */
    public PageReference IsCHChangedOnChange()
    {
        if(IsCHValue == 'Yes')
        {
            IsCHValueYes = true;
        }
        else
        {
            if(IsCHValue=='No' || IsCHValue==null)
            {
                organization.of_Physicians_in__c = null;
                IsCHValueYes = false;
            }
            
            if(IsCHValue==null)
            {
                organization.IsCHOrg__c = null;
            }
        }
        return null;
    }   
    
    
    /*** ### Private Methods ### ***/
    
    private void setIsUSBasedPickList()
    { 
        if(this.organization.Country__c!=null)
        {
            if(IsUSBasedOrg(this.organization.Country__c))
            {
              this.organization.US_Organization__c ='Yes';
            }
            else
            {
              this.organization.US_Organization__c ='No';
            }
        }else{this.organization.US_Organization__c ='Yes';}
        
    }
    
     /**
        * @author ADMD Dev Team
        * @date 21/08/2013
        * @description Method returns true if country should be treated as US
        * 
        */
    private Boolean IsUSBasedOrg(String country)
    {
        Boolean retValue = false;
        
        String strlistUSBasedCountries = myGFRSOrgSettings.USBasedOrganizations__c;
        String[] listOfUsBasedCountries = strlistUSBasedCountries.split('\\|');
        if( country != null && country != '' )
        {
            for(String tmpCountryName : listOfUsBasedCountries){
                if(tmpCountryName == country){
                    retValue = true;
                    break;
                }
            }
        }
        else
        {
            //as default we treat org as US based.
            retValue = true;
        }
        if(myGFRSOrgSettings.TraceOrgInfoController__c)System.debug('IsUSBasedOrg? '+ country + ' ->'+retValue);
        return retValue;
    }
    
     /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Determines the id of of the location sent by GET (if there was one )
        * 
        */  
    private Id getSentLocationId()
    {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if( params.containsKey( PARAM_LOCATION_ID ) )
        {
            return( Id.valueOf( params.get( PARAM_LOCATION_ID )));
        } 
        else
        {
            return( null );
        }
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Determines the org id sent by GET (if there was one)
        * 
        */ 
    private string getSentTaxId()
    {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        
        if( this.userContact != null )
        {
            try
            {
                if(myGFRSOrgSettings.TraceOrgInfoController__c)system.debug('getSentTaxId()->User contact not null');
                gFRS_Organization__c userOrg = gFRS_Util.getContactOrganization( this.userContact );
                return( userOrg.id );
            } 
            catch( Exception err )
            {
                if(myGFRSOrgSettings.TraceOrgInfoController__c)System.debug( 'getSentTaxId()-> exception:' + err.getMessage() );
            }
        } 
        else if( params.containsKey( PARAM_ORG_ID ) )
        {
            return( Id.valueOf( params.get( PARAM_ORG_ID )));
        }
        
        return( null );
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Resets the Organization to a new organization
        * 
        */
    private void resetOrganization()
    {
        this.selectedLocation = null;
        this.lLocs = new GFRS_Location_Copay__c[]{};
        this.organization = new GFRS_Organization__c( Grant_Requestor_Subject_to_Firewall__c = true, Country__c = 'United States'  );
        this.currentLocation = new GFRS_Location_Copay__c();
        this.w9FormAttachment = new Attachment();
        this.taxStatus501DeterminationLetterAttachment = new Attachment();
    }
    
    /**
        * @author ADMD Dev Team
        * @date 20/08/2013
        * @description Resets setup valuse for partial rendering org details
        * 
        */
    private void SetupCHFoundationDynaFields()
    {
        system.debug('SetupCHFoundationDynaFields() start...');
        
        if (organization!=null)
        {
            
            IsCHValue = organization.IsCHOrg__c;
            orgTypeValue = organization.TypeCopay__c;
            
            system.debug('SetupCHFoundationDynaFields() org type=' +orgTypeValue ); 
            if (orgTypeValue == CHFoundationType)
            {
                IsCharitableFundation=true;
                
                if (IsCHValue == 'Yes')
                {
                    IsCHValueYes=true;
                }
                else if(IsCHValue == 'No')
                {
                    IsCHValueYes=false;
                    organization.of_Physicians_in__c = null;
                        
                }
                else
                {
                    IsCHValueYes=false;
                    organization.IsCHOrg__c = null;
                    organization.of_Physicians_in__c = null;
                }
            }
            else
            {
                organization.IsCHOrg__c = null;
                organization.of_Physicians_in__c = null;
                IsCharitableFundation=false;
                IsCHValueYes= false;    
            }
        }
        else
        {
            IsCharitableFundation=false;
            IsCHValueYes= false;
        }
    }
    
    /**
    * @author ADMD Dev Team
    * @date 20/08/2013
    * @description check if location was modified
    * 
    */
    private Boolean checkIfLocationWasModified(GFRS_Location_Copay__c newLock){
        Boolean shouldCompare=true;
        if(newLock == null || (newLock != null && newLock.id ==null)){
                shouldCompare=false;
        }
        GFRS_Location_Copay__c oldLock=null;
        if(shouldCompare){
                oldLock=[select Id, RecordTypeId, RecordType.DeveloperName, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Organization__c, Address_Line_1__c, Address_Line_2__c, Address__c, City__c, Department_Chapter_Country__c, Fax__c, Payment_Method__c, Phone__c, State__c, Street_4__c, Street__c, Vendor_ID__c, Vendor_Name_1__c, Vendor_Name_2__c, Vendor_Name_3__c, Vendor_Name_4__c, Vendor_Name__c, Zip__c,  City_1__c, State_1__c, Country_1__c, Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c, Province_Region_Territory__c, PO_Box_available__c, Department_PO_Box__c
                        From GFRS_Location_Copay__c
                        where id =: newLock.id];
        }       
                //GFRS_Location_Copay__c loc2=loc.clone(false,true);
                String [] fieldsToCompare= new string[]{'Name','Address_Line_1__c', 'Address_Line_2__c', 'Address__c', 'City__c', 'Department_Chapter_Country__c', 'Fax__c', 'Payment_Method__c', 'Phone__c', 'State__c', 'Street_4__c', 'Street__c', 'Vendor_ID__c', 'Vendor_Name_1__c', 'Vendor_Name_2__c', 'Vendor_Name_3__c', 'Vendor_Name_4__c', 'Vendor_Name__c', 'Zip__c', 'City_1__c', 'State_1__c', 'Country_1__c', 'Zip_Code_1__c', 'Province_Region_Territory__c'};
                Boolean fieldsWereChanged=false;
                for(String fname : fieldsToCompare){
                    String newVal=((String)newLock.get( fname )) == null?'':(String)newLock.get( fname );
                    if(oldLock != null && shouldCompare){
                            String oldVal=((String)oldLock.get( fname )) == null?'':(String)oldLock.get( fname );
                                if( newVal.toLowerCase().trim().replaceAll('\\s+',' ') != oldVal.toLowerCase().trim().replaceAll('\\s+',' ')){
                                        fieldsWereChanged=true;
                                }
                    }
                        newLock.put( fname,newVal.trim().replaceAll('\\s+',' '));
                }
                return fieldsWereChanged;
    }
    
    /**
    * @author ADMD Dev Team
    * @date 20/08/2013
    * @description Refresh org accordion visibility
    * 
    */
    private void refreshAccordionVisibility(){
        if(this.fundreqcopay == null || this.fundreqcopay.id == null)
        {
                system.debug('SECTION 1');
            this.isEditable = true;
            if(this.organization != null && (this.organization.Tax_Id__c != null || this.organization.Non_US_Organization_ID__c != null)){
                system.debug('SECTION 2');
                system.debug(this.organization.Tax_Id__c);
                        this.isDescriptionEditable=gFRS_Util_NoShare.getSubmitedRequestUnderOrg(this.organization.Tax_Id__c,this.organization.Non_US_Organization_ID__c) < 1;
                        if( this.isInternalUser && this.isOrgExternal){
                        this.isDescriptionEditable=false;
                    }else if(!this.isInternalUser && !this.isOrgExternal){
                        this.isDescriptionEditable=true;
                        }
            }else{      
                this.isDescriptionEditable=true;
            }
            system.debug(this.userContact+'=='+this.userContact.Account.id + '=='+gFRS_Util.getCustomSettingStringValue('Portal_Account_ID')+'=='+System.Label.GFRS_HOLDING_ACCOUNT +'=='+gFRS_Util.getCustomSettingStringValue('Portal_Account_ID'));
            this.isTaxInfoEditable = (this.userContact == null || this.userContact.Account.id == (gFRS_Util.getCustomSettingStringValue('Portal_Account_ID') == null ? System.Label.GFRS_HOLDING_ACCOUNT : gFRS_Util.getCustomSettingStringValue('Portal_Account_ID')));
            this.isLocationEditable = true;
            this.isLocationSelectable = true;
            system.debug('flag was set to true: 1');
        } else if(this.fundreqcopay.Information_Needed__c != null){
            //-- the record exists and can be modified
            system.debug('SECTION 4');
            this.isEditable =  gFRS_Util.multiSelectHasItem( this.fundreqcopay.Information_Needed__c, 'Organization' );
            system.debug(this.isEditable);
            if(this.isEditable && this.fundreqcopay.Sub_Status__c != null && this.fundreqcopay.Sub_Status__c == 'RFI'){
                this.isDescriptionEditable=this.isEditable;
                
                //this.isTaxInfoEditable = false;
                system.debug('SECTION 5');
            }else if(this.organization != null && (this.organization.Tax_Id__c != null || this.organization.Non_US_Organization_ID__c != null)){
                //this.isTaxInfoEditable = (this.userContact == null || this.userContact.Account.id == System.Label.GFRS_HOLDING_ACCOUNT ) && isEditable;
                        this.isDescriptionEditable=gFRS_Util_NoShare.getSubmitedRequestUnderOrg(this.organization.Tax_Id__c,this.organization.Non_US_Organization_ID__c)<1;
                        
                        system.debug('SECTION 6');
            }   
            system.debug('flag was set to'+this.isDescriptionEditable+' false: 1');
            this.isLocationEditable =  gFRS_Util.multiSelectHasItem( this.fundreqcopay.Information_Needed__c, 'Organization' );
            this.isLocationSelectable =  gFRS_Util.multiSelectHasItem( this.fundreqcopay.Information_Needed__c, 'Organization' );
            this.isTaxInfoEditable = false;
            if( this.isInternalUser ){
                //-- restrict if the user is internal viewing an external organization or location
                if( this.isOrgExternal ){
                    this.isEditable = false;
                    this.isDescriptionEditable=false;
                    //this.isTaxInfoEditable = false;
                    system.debug('SECTION 7');
                    system.debug('flag was set to false: 1');
                }
                if( this.isLocationExternal ){
                        system.debug('SECTION 8');
                    //this.isLocationEditable = false;
                }
            }else if(!this.isInternalUser && !this.isOrgExternal){
                this.isDescriptionEditable=true;
            }
        } 
        else
        {
            system.debug('SECTION 9');      
            this.isEditable = false;
            this.isDescriptionEditable=false;
            this.isLocationEditable = false;
            this.isLocationSelectable = false;
            this.isTaxInfoEditable = false;
            system.debug('flag was set to false: 2');
        }
    }
   
    private List<GFRS_Organization__c> orgranizationsInCountry; 
    
    public String orgranizationNamesInCountry {get{  
      if(!isUSBased){   
        orgranizationsInCountry =[select Id, Organization_Name__c, W8BEN_Status__c, Non_US_Organization_ID__c, Tax_Status__c, Country__c, Tax_Id__c from GFRS_Organization__c WHERE Country__c = :organization.Country__c];
        return JSON.serialize(orgranizationsInCountry);
      }
      return null;
    } set;}
       
}