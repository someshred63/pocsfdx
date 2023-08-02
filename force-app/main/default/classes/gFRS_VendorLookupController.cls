public with sharing class gFRS_VendorLookupController {
    
    public static final String TEMPLATE_CREATE_SAP_LOC     = 'gFRS_Add_SAP_Location';
    public static final String TEMPLATE_UPDATE_SAP_LOC     = 'gFRS_Update_SAP_Location';
    public static final String PATH_CURRENT_PAGE           = '/apex/GFRS_Vendor_Lookup';
    public static final String TAG_ORGANIZATION_NAME       = '[[ORGANIZATION_NAME]]';
    public static final String TAG_ORGANIZATION_TAX_ID     = '[[TAX_ID]]';
    public static final String TAG_ORGANIZATION_TAX_STATUS = '[[TAX_STATUS]]';
    
    public static final String TAG_VENDOR_ID               = '[[VENDOR_ID]]';
    public static final String TAG_VENDOR_NAME             = '[[VENDOR_NAME]]';
    public static final String TAG_VENDOR_ADDRESS          = '[[VENDOR_ADDRESS]]';
    public static final String TAG_VENDOR_CITY             = '[[VENDOR_CITY]]';
    public static final String TAG_VENDOR_STATE            = '[[VENDOR_STATE]]';
    public static final String TAG_VENDOR_PROVINCE         = '[[PROVINCE]]';
    public static final String TAG_VENDOR_ZIP              = '[[VENDOR_ZIP]]';
    public static final String TAG_VENDOR_COUNTRY          = '[[VENDOR_COUNTRY]]';
    public static final String TAG_USER_NAME               = '[[USER_NAME]]';
    public static final String TAG_USER_EMAIL              = '[[USER_EMAIL]]';
    
    public static final String TAG_REQUEST_IDS             = '[[REQUEST_IDS]]';
    public static final String TAG_PAYEE_NAME              = '[[PAYEE_NAME]]';

    public GFRS_Location__c currentLocation         { get; set; }
    public String matchedLocation                   { get; set; }
    public Map<String, MatchedLocation> locationMap { get; set; }
    public String currentVendorId                   { get; set; }
    public String searchBy                          { get; set; }
    public MatchedLocation[] matchedLocations       { get; set; }
    public Boolean isSuccessRedirect                { get; set; }
    public Boolean hasMatchedLocations              { get {return( this.matchedLocations != null && this.matchedLocations.size() > 0 );}}
    public Boolean hasMessages                      { get { return( ApexPages.hasMessages() );}}

    public gFRS_VendorLookupController( ApexPages.StandardController std ) {
        this.currentLocation = (GFRS_Location__c)std.getRecord();
        try {
            this.currentLocation = [SELECT Id, IsDeleted, Name, Organization__r.Name, 
                                            Organization__r.Organization_Name__c, 
                                            Organization__r.Tax_Id__c, CreatedDate, 
                                            CreatedById, LastModifiedDate, LastModifiedById, 
                                            SystemModstamp, MayEdit, IsLocked, Organization__c, 
                                            Address_Line_1__c, Address_Line_2__c, Address__c, 
                                            City__c, Department_Chapter_Country__c, Fax__c, 
                                            Payment_Method__c, Phone__c, State__c, Street_4__c, 
                                            Street__c, Vendor_ID__c, Vendor_Name_1__c, Vendor_Name_2__c, 
                                            Vendor_Name_3__c, Vendor_Name_4__c, Vendor_Name__c, Zip__c, 
                                            W9_Form_W_8BEN_Form__c, City_1__c, State_1__c, Country_1__c, 
                                            Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c
                                            FROM GFRS_Location__c 
                                            WHERE id =: this.currentLocation.id];
        } catch( Exception err ){
            
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find location' ));
            return;
        }

        this.searchBy = 'taxId';
        this.searchVendor();
        this.isSuccessRedirect = this.checkIsSuccessRedirect();
    }

    public Boolean checkIsSuccessRedirect() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        return params.containsKey('success');
    }

    public void searchVendor(){
        matchedLocations = new List<MatchedLocation>();
        gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0 sapLookup = new gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0();
        sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
        
        GFRS_VendorLookupSAP.VendorLookupResponse_element response;

        try {
            if (searchBy == 'taxId') {
                response = sapLookup.VendorLookup( '', '', this.currentLocation.Organization__r.Tax_Id__c, '', '', '100' );
            } else if(searchBy == 'vendorId'){
                response = sapLookup.VendorLookup( '', this.currentLocation.Vendor_ID__c, '', '', '', '100' );
            } else if(searchBy == 'companyName'){
                response = sapLookup.VendorLookup( this.currentLocation.Organization__r.Organization_Name__c, '', '', '', '', '100' );
            } else {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Invalid value of search filter.' ));
                return;
            }
        } catch( Exception err ){
            System.debug( 'ERROR OCCURRED:' + err.getMessage() );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem' ));
            return;
        }
        handleResponse(response);
    }
    public void handleResponse(GFRS_VendorLookupSAP.VendorLookupResponse_element response) {
        if ( response.MessageText != null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, response.MessageText ));
            return;
        }
        for (GFRS_VendorLookupSAP.VendorDetails_element  d : response.VendorDetails) {
            
            MatchedLocation l = new MatchedLocation();
            l.Organization_Name = d.NameLine1+' '+d.NameLine2+' '+d.NameLine3+' '+d.NameLine4;
            l.Tax_ID            = d.TaxId;
            l.Phone             = d.TelephoneExt+' '+d.Telephone;
            l.Address           = d.AddressLine1; 
            l.City              = d.City;
            l.State             = d.State;
            l.Zip               = d.Zip;
            l.PoBox             = d.PoBox;
            l.PoBoxPostalCode   = d.PoBoxPostalCode; 
            l.VendorId          = d.VendorID;
            l.PaymentMethod     = d.PaymentMethod;
            l.Country           = d.Country;
            l.Street4           = d.Street4;
            l.Street5           = d.Street5;
            l.NameLine1         = d.NameLine1;
            l.NameLine2         = d.NameLine2;
            l.NameLine3         = d.NameLine3;
            l.NameLine4         = d.NameLine4;
            l.PostingBlockSpecifiedCompanyCode  = d.PostingBlockSpecifiedCompanyCode;
            l.PostingBlockAllCompanyCode        = d.PostingBlockAllCompanyCode;
            l.PaymentBlockIndicator             = d.PaymentBlockIndicator;
            l.PaymentBlockDescription           = d.PaymentBlockDescription;
            l.DeletionFlagSelectedCompanyCode   = d.DeletionFlagSelectedCompanyCode;
            l.DeletionFlagAllArea               = d.DeletionFlagAllArea;
                   
            
            matchedLocations.add(l);
        }

        this.locationMap = new Map<String, MatchedLocation>();
        for (MatchedLocation m : matchedLocations) {
            this.locationMap.put(m.VendorID, m);
        }
    }

    public ApexPages.PageReference savePage() {
        MatchedLocation selectedLocation = this.locationMap.get( this.currentVendorId );
        if ( currentVendorId == null || currentVendorId == '' ) {
            System.debug( 'currentVendorId is not sent' );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'VendorId not sent' ));
            return null;
        }
        selectedLocation = this.locationMap.get(this.currentVendorId);
        if ( selectedLocation == null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'System Error - unable to find selected location' ));
            return null;
        }

        try {
            this.currentLocation.Vendor_Id__c       = this.currentVendorId;
            this.currentLocation.Payment_Method__c  = selectedLocation.PaymentMethod;
            this.currentLocation.Address_Line_1__c  = selectedLocation.Address;
            this.currentLocation.State_1__c         = selectedLocation.State;
            this.currentLocation.Zip_Code_1__c      = selectedLocation.Zip;
            this.currentLocation.City_1__c          = selectedLocation.City;
            this.currentLocation.Country_1__c       = selectedLocation.Country;
            this.currentLocation.Street_4__c        = selectedLocation.Street4;
            this.currentLocation.Street__c          = selectedLocation.Street5;
            this.currentLocation.Vendor_Name_1__c   = selectedLocation.NameLine1;
            this.currentLocation.Vendor_Name_2__c   = selectedLocation.NameLine2;
            this.currentLocation.Vendor_Name_3__c   = selectedLocation.NameLine3;
            this.currentLocation.Vendor_Name_4__c   = selectedLocation.NameLine4;
            this.currentLocation.Vendor_Name__c     = selectedLocation.Organization_Name;
            this.currentLocation.PO_Box__c            =selectedLocation.PoBox;
            this.currentLocation.PO_Box_Postal_Code__c=selectedLocation.PoBoxPostalCode;
            this.currentLocation.Posting_block_for_1000_or_1010__c      =selectedLocation.PostingBlockSpecifiedCompanyCode;
            this.currentLocation.Posting_block_for_all_company_codes__c =selectedLocation.PostingBlockAllCompanyCode;
            this.currentLocation.Payment_Block_Indicator__c             =selectedLocation.PaymentBlockIndicator;
            this.currentLocation.Payment_Block_Description__c           =selectedLocation.PaymentBlockDescription;
            this.currentLocation.Deletion_Flag_for_all_1000_or_1010__c  =selectedLocation.DeletionFlagSelectedCompanyCode;
            this.currentLocation.Deletion_Flag_for_all_company_codes__c =selectedLocation.DeletionFlagAllArea;
            
            update this.currentLocation;
        } catch( Exception err ) {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
            return null;
        }
        return redirectToLocation();
    }

    public ApexPages.PageReference redirectToLocation() {
        return new ApexPages.StandardController( this.currentLocation ).view();
    }

    public ApexPages.PageReference sendEmailToCreateLocation() {
        sendSAPEmail( this.currentLocation.id, true );
        if( !ApexPages.hasMessages() ){
        setVendorAddRequestedDate();
        return( new ApexPages.PageReference( PATH_CURRENT_PAGE + '?id=' + this.currentLocation.id + '&success=true' ).setRedirect(true));
        }
        return null;
    }

    public ApexPages.PageReference sendEmailToUpdateLocation() {
        sendSAPEmail( this.currentLocation.id, false );
        return( new ApexPages.PageReference( PATH_CURRENT_PAGE + '?id=' + this.currentLocation.id + '&success=true' ).setRedirect(true));
    }
    
    public void setVendorAddRequestedDate(){
        GFRS_Location__c loc = [SELECT Id,Vendor_Add_Requested_Date__c FROM GFRS_Location__c WHERE Id =: this.currentLocation.id];
        loc.Vendor_Add_Requested_Date__c = date.today();
        update loc;
    }

    public static void sendSAPEmail( Id locationId, Boolean shouldCreate ) {
        String targetEmailStr                             = gFRS_Util.getCustomSettingStringValue('SAP_ContactList') == null ? System.Label.GFRS_SAP_ContactList : gFRS_Util.getCustomSettingStringValue('SAP_ContactList');
        String[] targetEmailList                          = targetEmailStr.split( ';' );
        GFRS_Location__c location                         = null;
        GFRS_Organization__c objOrg                       = null;
        List<GFRS_Funding_Request__c> fundingRequestsList = null;

        GFRS_OrgSettings__c orgCS = GFRS_OrgSettings__c.getOrgDefaults();
        
        try {
            location = [ SELECT Name, Vendor_Id__c, Organization__r.Id, 
                                Organization__r.Organization_Name__c, 
                                Organization__r.Tax_Id__c, Organization__r.Tax_Status__c, 
                                Vendor_Name__c, Address__c, City__c, State__c, 
                                Province_Region_Territory__c, Zip__c, Department_Chapter_Country__c 
                                FROM GFRS_Location__c 
                                WHERE Id = :locationId ];
        } catch(Exception e){
            System.debug( 'unable to find the location:' + locationId );
        }
        
        try
        {
            objOrg = [SELECT Id, W9_Form_W_8BEN_Form__c, 
                            (SELECT Id, ParentID, Name FROM Attachments) 
                        FROM GFRS_Organization__c 
                        WHERE Id= : location.Organization__r.Id];
        } catch(Exception e){
            System.debug( 'unable to find the org:' + locationId );
        }

        if( location == null || objOrg==null) {
            System.debug( 'unable to find location :' + locationId + ' or org.');
            ApexPages.addMessage( new Apexpages.Message( ApexPages.Severity.ERROR, 'Error occurred when attempting to send email. Please contact your system administrator.' ));
            return;
        }
        
        /*
            Gathering gFRS Funding Requests that are assigned to given location, but only with Status != "Intake","Closed".
        */
        fundingRequestsList = gFRS_Util.getFundingRequestsByLocationId(locationId);
        
        
        String targetEmailName = (shouldCreate)? TEMPLATE_CREATE_SAP_LOC : TEMPLATE_UPDATE_SAP_LOC;
        EmailTemplate template = null;
        try {
            template = [ SELECT TemplateType, Subject, Name, Description, HtmlValue, Body 
                            FROM EmailTemplate 
                            WHERE DeveloperName = :targetEmailName limit 1 ];
        } catch(Exception e){ template = null; }

        if ( template == null ) {
            System.debug( 'Unable to find template[' + TEMPLATE_CREATE_SAP_LOC + ']');
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while attempting to send email. Please contact your system administrator.' ));
            return;
        }

        User currentUser = [ SELECT Id, Email, Name FROM User WHERE Id = :(UserInfo.getUserId()) limit 1 ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setUseSignature( true );
        mail.setSaveAsActivity(true);
        
        if(shouldCreate){
            List<gFRS_Tasks__c> tasks = new List<gFRS_Tasks__c>();
            tasks = [SELECT Id, Name FROM gFRS_Tasks__c WHERE Action_Type__c = 'ACH' AND gFRS_Funding_Request__r.Location__c = :locationId];
            if(tasks.size() > 0){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Waiting for ACH task to complete' ));
                return;
            }
        }
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

        if (objOrg.W9_Form_W_8BEN_Form__c != null) {
            System.debug( 'w9 form is not considered null' );
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( objOrg.Attachments );
            Attachment w9FormAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(objOrg.W9_Form_W_8BEN_Form__c, objOrg.id);
            system.debug('###');
            
            Blob attBody = [SELECT Body FROM Attachment WHERE Id = :w9FormAttachment.Id].Body; 
            if (attBody!= null) {
                att.setBody(attBody);
                att.setFileName(w9FormAttachment.Name);
                att.setInline(false);
                att.setContentType('application/octet-stream');
                attachments.add(att);
                system.debug(attachments);
            }
        }
        
        mail.setSubject(formatEmailSubject(template.Subject, location.Name));
        mail.setPlainTextBody( formatEmailText( template.Body, location, currentUser, fundingRequestsList ));
        
        if(attachments.size() > 0){
            mail.setFileAttachments(attachments);
        }       

        List<String> ccAddresses = new List<String>{currentUser.Email};
        if(String.isNotBlank(orgCS.Vendor_Update_CC_Email__c))
            ccAddresses.add(orgCS.Vendor_Update_CC_Email__c); 
        mail.setToAddresses(ccAddresses);       
        
        List<Messaging.SendEmailResult> result = Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
        
        List<GFRS_Funding_Request__c> fundingReq = new List<GFRS_Funding_Request__c>();
        fundingReq = [SELECT Id, Name, ACH_Details_PDF__c, ACH_Att_Obj__c FROM GFRS_Funding_Request__c WHERE Location__c = :locationId AND ACH_Details_PDF__c != null AND ACH_Details_PDF__c != '' AND ACH_PDF_Sent_to_SAP__c   = false AND Status__c != 'Intake' ];
        Map<Id,Id> custObjMap = new Map<Id,Id>();
        
        for(GFRS_Funding_Request__c fundReq : fundingReq){
            custObjMap.put(fundReq.ACH_Att_Obj__c, fundReq.ACH_Details_PDF__c);
        }
        
        List<Attachment> attachmentPDF = new List<Attachment>();
        attachmentPDF = [SELECT Id,ParentID FROM Attachment WHERE ParentID in :custObjMap.keySet()];
        Map<Id,List<Attachment>> customAttachments = new Map<Id,List<Attachment>>();
        
        for(Attachment a : attachmentPDF){
            if(customAttachments.containsKey(a.ParentID)){
                List<Attachment> attchmt = customAttachments.get(a.ParentID);
                attchmt.add(a);
                customAttachments.put(a.ParentID, attchmt);
            }
            else{
                customAttachments.put(a.ParentID, new List<Attachment> {a});
            }
        }
        
        if(fundingReq.size() > 0){
            for(GFRS_Funding_Request__c req : fundingReq){
                Messaging.EmailFileAttachment attch = new Messaging.EmailFileAttachment();
             //   GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( customAttachments.get(req.ACH_Att_Obj__c) );
                Id attId = Id.valueof(req.ACH_Details_PDF__c);
                Attachment ACHForm = [SELECT Id,Name, Body FROM Attachment WHERE Id = :attId]; 
                Blob attchBody = ACHForm.Body;
            
                EncryptionKey__c keySetting = EncryptionKey__c.getOrgDefaults();
                Blob aesKey = EncodingUtil.base64Decode(keySetting.AesKey__c);
                attchBody = Crypto.decryptWithManagedIV('AES256', aesKey, attchBody);
                
                if (attchBody!= null) {
                    attch.setBody(attchBody);
                    attch.setFileName(ACHForm.Name);
                    attch.setInline(false);
                    attch.setContentType('application/pdf');
                    attachments.add(attch);
                }
            }
        }
        
        if(attachments.size() > 0){
            mail.setFileAttachments(attachments);
        }
        
        mail.setToAddresses( targetEmailList ); 
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        String serverURL = myOrgCS.Vendor_Update_CC_Email__c;       
        mail.setOrgWideEmailAddressId([
                    SELECT Id, Address
                    FROM OrgWideEmailAddress
                    WHERE Address = :serverURL
                    limit 1
            ][0].id);

        List<Messaging.SendEmailResult> result1 = Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );        
        
        if(fundingReq.size() > 0){
            for(GFRS_Funding_Request__c request : fundingReq){
                request.ACH_PDF_Sent_to_SAP__c = true;
            }
            gFRS_Util_NoShare.saveLockedFundingRequests(fundingReq);
        }
        
    }

     /** 
    * @Author ADMD Team
    * @date 04/18/2013
    * @description formatEmailText method - Replaces tags from template with data taken from database
    */
    public static String formatEmailText( String emailText, GFRS_Location__c location, User user, List<GFRS_Funding_Request__c> fundingRequestsList) {
        if( emailText == null || location == null || user == null || fundingRequestsList == null) return( null );
        
        String requestsListText = '';
        
        emailText = emailText.replace(TAG_ORGANIZATION_NAME,   gFRS_Util.blankValue( location.Organization__r.Organization_Name__c, '' ));
        emailText = emailText.replace(TAG_ORGANIZATION_TAX_ID, gFRS_Util.blankValue( location.Organization__r.Tax_Id__c, '' ));
        emailText = emailText.replace(TAG_ORGANIZATION_TAX_STATUS, gFRS_Util.blankValue( location.Organization__r.Tax_Status__c, '' ));
        
        emailText = emailText.replace(TAG_VENDOR_ID,           gFRS_Util.blankValue( location.Vendor_Id__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_NAME,         gFRS_Util.blankValue( location.Name, '' ));
        emailText = emailText.replace(TAG_VENDOR_ADDRESS,      gFRS_Util.blankValue( location.Address__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_CITY,         gFRS_Util.blankValue( location.City__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_STATE,        gFRS_Util.blankValue( location.State__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_PROVINCE,     gFRS_Util.blankValue( location.Province_Region_Territory__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_ZIP,          gFRS_Util.blankValue( location.Zip__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_COUNTRY,      gFRS_Util.blankValue( location.Department_Chapter_Country__c, '' ));
        emailText = emailText.replace(TAG_USER_NAME,           user.Name);
        emailText = emailText.replace(TAG_USER_EMAIL,          user.Email);
        
        
        for(GFRS_Funding_Request__c fundingRequest : fundingRequestsList){
            requestsListText += fundingRequest.Funding_Type__c + ': ' + fundingRequest.Name + '\n';
        }
        
        emailText = emailText.replace(TAG_REQUEST_IDS,          requestsListText);
        

        return( emailText );
    }

    /**
   * @Author ADMD Team
   * @date 10/03/2018
   * @description formatEmailSubject method - Replaces tags from email subject with data taken from database
   */
    public static String formatEmailSubject( String emailSubject, String payeeName) {
        if(emailSubject == null) {
            return null;
        }

        emailSubject = emailSubject.replace(TAG_PAYEE_NAME, gFRS_Util.blankValue(payeeName, ''));
        return emailSubject;
    }

    class MatchedLocation {
        
        public String Organization_Name { get; set; }
        public String Tax_ID            { get; set; }
        public String Organization_Type { get; set; }
        public String Phone             { get; set; }
        public String Parent_Account    { get; set; }
        public String Address           { get; set; }
        public String Tax_Status        { get; set; }
        public String City              { get; set; }
        public String State             { get; set; }
        public String Zip               { get; set; }
        public String PoBox             { get; set; }
        public String PoBoxPostalCode   { get; set; }
        public String VendorId          { get; set; }
        public String PaymentMethod     { get; set; }
        public String VendorName        { get; set; }
        public String Country           { get; set; }
        public String Street4           { get; set; }
        public String Street5           { get; set; }
        public String NameLine1         { get; set; }
        public String NameLine2         { get; set; }
        public String NameLine3         { get; set; }
        public String NameLine4         { get; set; }
        public String PostingBlockSpecifiedCompanyCode  { get; set; }
        public String PostingBlockAllCompanyCode        { get; set; }
        public String PaymentBlockIndicator             { get; set; }
        public String PaymentBlockDescription           { get; set; }
        public String DeletionFlagSelectedCompanyCode   { get; set; }
        public String DeletionFlagAllArea               { get; set; }
    }
}