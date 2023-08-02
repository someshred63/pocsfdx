public class gFRS_Ltng_VendorSAPLookupController {
    
    public static list<MatchedBank> matchedBankDetails;
    public static Map<String, MatchedLocation> locationMap;
    public static final String TEMPLATE_CREATE_SAP_LOC     = 'gFRS_Add_SAP_Location';
    public static final String TEMPLATE_UPDATE_SAP_LOC     = 'gFRS_Update_SAP_Location';   
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
    
    @AuraEnabled
    public static vendorWrapper fetchVendorReqDtls(String recordID) {
        system.debug('recordID'+recordID);
        List<LayoutSection> lstSections = new List<LayoutSection>();
        Set<String> sectionSets=new Set<String>();
        vendorWrapper vdwrapper=new vendorWrapper();
        
        try {
            gFRS_Ltng_Application__c appRec = [SELECT Id, Name,Vendor_Detail__c,Record_Type_Name__c FROM gFRS_Ltng_Application__c WHERE id =:recordID];
            	 Profile p = [Select id,Name from Profile where Id =: userinfo.getProfileid()];
            system.debug('Profile'+p.Name);
            List<String> componentNameList = new List<String>{'gFRS_Ltng_Vendor_Detail__c-gFRS Vendor Detail Layout'};
                // Retrieve page layout details 
                List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
            Metadata.Layout contLayout = (Metadata.Layout) components.get(0);
            if(appRec.Record_Type_Name__c=='Foundation Undergraduate' || appRec.Record_Type_Name__c=='Foundation Safety Net Support')
            {
                sectionSets.add('Information');
                sectionSets.add('Department/Chapter Address');
                
            }
            else{
                sectionSets.add('Information');
                sectionSets.add('SAP'); 
                sectionSets.add('Department/Chapter Address');
                
            }
            // We are going to find the fields names and will keep them according to columns so 
            // we can show them as per page layout 
            for( Metadata.LayoutSection ls : contLayout.layoutSections ) {
                
                if(sectionSets.contains(ls.label))
                {
                    LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );
                    
                    List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                    Integer maxFieldsInColumn = 0;
                    for( Metadata.LayoutColumn lc : ls.layoutColumns ) {
                        
                        LayoutColumn column = new LayoutColumn();
                        // check if there are fields available in that column
                        if( lc.layoutItems != null ) { 
                            // Get the max number of fields in a column to preserve the alignment 
                            if( maxFieldsInColumn < lc.layoutItems.size() ) {
                                maxFieldsInColumn = lc.layoutItems.size();
                            }
                            for( Metadata.LayoutItem li : lc.layoutItems ) {
                                
                                // Pass the LayoutItem object in the LayoutField consturctor        
                                column.lstFields.add( new LayoutField( li ) );
                            }
                        }
                        // No need to add a column in the section if there is no field available 
                        if( column.lstFields.size() > 0 ) {
                            lstColumns.add( column );
                        }
                    }
                    
                    // Now, we need to arrange the fields in section so we can use them in the iteration 
                    // on the component so we will have to arrange them in the order 
                    if( maxFieldsInColumn > 0 ) {
                        for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                            for( Integer j = 0; j < lstColumns.size(); j++ ){
                                if( lstColumns[j].lstFields.size() > i ) {
                                    section.lstFields.add( lstColumns[j].lstFields[i] );    
                                }    
                                else {
                                    section.lstFields.add( new LayoutField() );
                                }
                            }    
                        }    
                    }
                    
                    lstSections.add( section );
                }
            }
            gFRS_Ltng_Vendor_Detail__c vcdetail = [select 
                                                   id,name,gFRS_Organization__c,Telephone_Number__c,Address__c,City__c,State__c,Zip__c,Company_Payee_Name__c,Posting_block_for_all_company_codes__c,
                                                   Department_Chapter_Country__c,Department_Do_you_have_PO_Box__c,gFRS_Application__c,gFRS_Application__r.Record_Type_Name__c,Vendor_ID__c,Partner_Bank_Type__c,Payment_Block_Indicator__c,Deletion_Flag_for_all_company_codes__c,
                                                   gFRS_Organization__r.Name,gFRS_Organization__r.Organization_Name__c,gFRS_Organization__r.Type__c,gFRS_Organization__r.Tax_Id__c,gFRS_Payment_Type__c,
                                                   gFRS_Organization__r.Account__r.Name,gFRS_Organization__r.Tax_Status__c,Organization_Tax_ID__c,CompanyCodeFor1000__c,CompanyCodeFor1000Blocked__c,CompanyCodeFor1010__c,CompanyCodeFor1010Blocked__c , Request_for_New_Vendor_sent_pending__c 
                                                   from gFRS_Ltng_Vendor_Detail__c where Id=:appRec.Vendor_Detail__c];
            
            vdwrapper.lstFields=lstSections;
            vdwrapper.vendorRecord=vcdetail;
            
            vdwrapper.RecordType=appRec.Record_Type_Name__c;             
            vdwrapper.profileName=p.Name;
        }
        catch( Exception e ){
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage() );
        }
        
        return vdwrapper;
    }
    
    public class LayoutSection {   
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
        }
    }
    public class vendorWrapper {  
        @AuraEnabled public List<LayoutSection> lstFields {get;set;}
        @AuraEnabled public gFRS_Ltng_Vendor_Detail__c vendorRecord {get;set;}
        @AuraEnabled public string RecordType {get;set;}
        @AuraEnabled public string profileName {get;set;}
    }
    private class LayoutColumn {
        private List<LayoutField> lstFields;    
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }
    
    public class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        
        public LayoutField() {}
        
        public LayoutField( Metadata.LayoutItem li ) {
            
            this.fieldName = li.field;
            if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
            else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }    
        }
    }   
    
    @AuraEnabled
    public static void updateVendorRecord(string selectedVendor, Id vendorRecId, map<string,MatchedLocation> locMap){
        
        try{
            MatchedLocation selectedLocation = new MatchedLocation();
            gFRS_Ltng_Vendor_Detail__c currentLocation = [select id from gFRS_Ltng_Vendor_Detail__c where id =: vendorRecId];
            system.debug('@@ locationMap 1 :'+locMap);
            selectedLocation = locMap.get(selectedVendor);
            
            currentLocation.Vendor_Id__c            = selectedLocation.VendorId;
            currentLocation.Payment_Method__c       = selectedLocation.PaymentMethod;
            currentLocation.State_1__c              = selectedLocation.State;
            currentLocation.Zip_Code_1__c           = selectedLocation.Zip;
            currentLocation.City1__c                = selectedLocation.city;
            currentLocation.Vendor_Account_Group__c = selectedLocation.Parent_Account;
            currentLocation.Country__c              = selectedLocation.Country;
            currentLocation.Street_4__c             = selectedLocation.Street4;
            currentLocation.Street_5__c             = selectedLocation.Street5;
            currentLocation.Vendor_Name_1__c        = selectedLocation.NameLine1;
            currentLocation.Vendor_Name_2__c        = selectedLocation.NameLine2;
            currentLocation.Vendor_Name_3__c        = selectedLocation.NameLine3;
            currentLocation.Vendor_Name_4__c        = selectedLocation.NameLine4;
            currentLocation.Vendor_Name__c          = selectedLocation.Organization_Name;
            currentLocation.Vendor_tax_ID__c        = selectedLocation.Tax_ID;
            currentLocation.PO_Box__c               = selectedLocation.PoBox;
            currentLocation.PO_Box_Postal_Code__c   = selectedLocation.PoBoxPostalCode;
            currentLocation.Payment_Block_Indicator__c             = selectedLocation.PaymentBlockIndicator;
            currentLocation.Payment_Block_Description__c           = selectedLocation.PaymentBlockDescription;
            currentLocation.Deletion_Flag_for_all_company_codes__c = selectedLocation.DeletionFlagAllArea;
            currentLocation.CompanyCodeFor1000__c=selectedLocation.CompanyCodeFor1000;
            currentLocation.CompanyCodeFor1000Blocked__c=selectedLocation.CompanyCodeFor1000Blocked;
            currentLocation.CompanyCodeFor1010__c=selectedLocation.CompanyCodeFor1010;
            currentLocation.CompanyCodeFor1010Blocked__c=selectedLocation.CompanyCodeFor1010Blocked;
            currentLocation.Request_for_New_Vendor_sent_pending__c = false;
            update currentLocation;
            
        } catch(Exception e){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @AuraEnabled
    public static void updateBankDetails(string partnerBankType, Id vendorRecId){
        
        try{
            gFRS_Ltng_Vendor_Detail__c currentLocation = [select id,Partner_Bank_Type__c from gFRS_Ltng_Vendor_Detail__c where id =: vendorRecId];
            
            currentLocation.Partner_Bank_Type__c = partnerBankType;
            
            update currentLocation;
            
            List<gFRS_Ltng_Application__c> appRecords = new List<gFRS_Ltng_Application__c>();
            List<gFRS_Ltng_Application__c> appRecList = new List<gFRS_Ltng_Application__c>();
            
            appRecords = [SELECT Id, Name, Partner_Bank_Type__c, Payment_Method__c FROM gFRS_Ltng_Application__c WHERE Vendor_Detail__c =: vendorRecId AND (Payment_Method__c = 'ACH' OR Payment_Method__c = 'Wire') AND (Partner_Bank_Type__c = '' OR Partner_Bank_Type__c = null)];
            
            if(appRecords.size() > 0){
                for(gFRS_Ltng_Application__c appRec : appRecords){
                    appRec.Partner_Bank_Type__c = partnerBankType;
                    appRecList.add(appRec);
                }
                gFRS_Ltng_Util_NoShare.updateApplicationRecords(appRecList);
            }
            
            /* List<gFRS_Ltng_Task__c> tasks = new List<gFRS_Ltng_Task__c>();
            set<Id> appIDs = new set<Id>();
            tasks = [SELECT Id, Name, Action_Type__c, gFRS_Application__c FROM gFRS_Ltng_Task__c WHERE Action_Type__c = 'Payment Method' AND status__c = 'Open' AND gFRS_Application__r.Vendor_Detail__c = :vendorRecId];
            
            if(tasks.size() > 0){
                for(gFRS_Ltng_Task__c task : tasks){
                    appIDs.add(task.gFRS_Application__c);
                }
            }
            
            List<gFRS_Ltng_Application__c> applRecords = new List<gFRS_Ltng_Application__c>();
            applRecords = [SELECT Id, Name, Partner_Bank_Type__c FROM gFRS_Ltng_Application__c WHERE Vendor_Detail__c =:vendorRecId AND Payment_Method__c = 'ACH' AND Partner_Bank_Type__c = null AND Id NOT IN :appIDs];
            
            if(applRecords.size() > 0){
                for(gFRS_Ltng_Application__c app : applRecords){
                    app.Partner_Bank_Type__c = partnerBankType;
                }
                
                gFRS_Ltng_Util_NoShare.updateApplicationRecords(applRecords);
            } */
            
        } catch(Exception e){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }    
    
    @AuraEnabled
    public static MatchedLocationsWrapper getVendorDetails(String searchKey, Id appId){
        gFRS_Ltng_Application__c applRecord = [SELECT Id, Name, Organization__r.Tax_Id__c, Organization__r.Organization_Name__c, Vendor_Detail__r.Vendor_ID__c FROM gFRS_Ltng_Application__c WHERE Id =: appId];
        MatchedLocationsWrapper matchedLocations = new MatchedLocationsWrapper();
        
        // gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0 sapLookup = new gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0();
        gFRS_Ltng_VendorLookup_SAP_WS.GneCOMM_VendorMaster_GFRS_I_1_V2_WSD_Vendor_Lookup_Port sapLookup = new gFRS_Ltng_VendorLookup_SAP_WS.GneCOMM_VendorMaster_GFRS_I_1_V2_WSD_Vendor_Lookup_Port();
        sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
        sapLookup.timeout_x = 120000;
        //  GFRS_VendorLookupSAP.VendorLookupResponse_element response;
        gFRS_Ltng_VendorLookup_SAP_WS.VendorLookupResponse response;
        
        /* VendorLookup_Ltng_WS.VendorLookup  details = new VendorLookup_Ltng_WS.VendorLookup();
        if (searchKey == 'taxId') {
            details.Name ='';
            details.Id   ='';
            details.TaxId=applRecord.Organization__r.Tax_Id__c;
        } else if (searchKey == 'vendorId') {
            details.Name='';
            details.Id=applRecord.Vendor_Detail__r.Vendor_ID__c;
            details.TaxId='';
        } else if (searchKey == 'companyName') {
            details.Name= applRecord.Organization__r.Organization_Name__c;
            details.Id='';
            details.TaxId='';
        } 
        
        details.Sort_x= '';
        details.filterInactive='';
        details.MaxRecords= '100'; */
        
        try{
            if (searchKey == 'taxId') {
                response = sapLookup.VendorLookup('', '', applRecord.Organization__r.Tax_Id__c, '', '', '100');
            } else if(searchKey == 'vendorId'){
                response = sapLookup.VendorLookup('', applRecord.Vendor_Detail__r.Vendor_ID__c, '', '', '', '100');
            } else if(searchKey == 'companyName'){
                response = sapLookup.VendorLookup(applRecord.Organization__r.Organization_Name__c, '', '', '', '', '100');
            } 
        } catch( Exception e ){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj; 
        }
        
        matchedLocations = handleResponse(response);  
        
        return matchedLocations;
    }  
    
    public static MatchedLocationsWrapper handleResponse( gFRS_Ltng_VendorLookup_SAP_WS.VendorLookupResponse response) {
        
        list<MatchedLocation> matchedLocations = new list<MatchedLocation>();
        if ( response.MessageText != null ) {
            system.debug('@@ Message text : '+response.MessageText);
            MatchedLocation l = new MatchedLocation();
            if(response.MessageText == 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator about this problem.'){
                l.errorMsg = response.MessageText;
            } else {
                l.errorMsg = 'There is no vendor that matches your search criteria. Please try a different search.';
            }
            
            matchedLocations.add(l);
            
            MatchedLocationsWrapper locationWrapper = new MatchedLocationsWrapper();
            locationWrapper.matchedLocations = matchedLocations;
            return locationWrapper;
        }
        for (gFRS_Ltng_VendorLookup_SAP_WS.VendorDetails  d : response.VendorDetails) {
            
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
            l.CompanyCodeFor1000=d.CompanyCodeFor1000;
            l.CompanyCodeFor1000Blocked=d.CompanyCodeFor1000Blocked;
            l.CompanyCodeFor1010=d.CompanyCodeFor1010;
            l.CompanyCodeFor1010Blocked=d.CompanyCodeFor1010Blocked;
            
            matchedLocations.add(l);
        }
        
        if(matchedLocations.size() > 0){
            locationMap = new Map<String, MatchedLocation>();
            for(MatchedLocation loc : matchedLocations){
                locationMap.put(loc.VendorId, loc);
            }
        }
        
        MatchedLocationsWrapper locationWrapper = new MatchedLocationsWrapper();
        locationWrapper.matchedLocations = matchedLocations;
        locationWrapper.matchedLocationsMap = locationMap;
        return locationWrapper;
    }    
    
    @AuraEnabled
    public static string addUpdateVendorInSAP( Id vendorRecId, Boolean createVendor ) {
        User currentUserRec = [ SELECT Id, Email, Name FROM User WHERE Id = :(UserInfo.getUserId()) limit 1 ];
        
        gFRS_Ltng_Vendor_Detail__c vd = new gFRS_Ltng_Vendor_Detail__c();
        vd.id = vendorRecId;
        vd.Request_for_New_Vendor_sent_pending__c = true;
        update vd;
        
        /* if(createVendor == true){
            List<gFRS_Ltng_Task__c> tasks = new List<gFRS_Ltng_Task__c>();
            tasks = [SELECT Id, Name FROM gFRS_Ltng_Task__c WHERE Action_Type__c = 'Payment Method' AND status__c = 'Open' AND gFRS_Application__r.Vendor_Detail__c = :vendorRecId];
            if(tasks.size() > 0){
                return 'Waiting for ACH task to complete';
                system.debug('@@ Waiting for ACH task to complete which is still open.');
taskOpen = true;
system.debug('@@ taskOpen inside : '+taskOpen);
            }
        }         */
        
        sendSAPEmail(vendorRecId, createVendor, currentUserRec.Name, currentUserRec.Email);
        return 'Success';
    }
    
    @future(callout=true)
    public static void sendSAPEmail( Id locationId, Boolean shouldCreate, string userName, string userEmail ) {
        //String targetEmailStr                             = gFRS_Util.getCustomSettingStringValue('SAP_ContactList') == null ? System.Label.GFRS_SAP_ContactList : gFRS_Util.getCustomSettingStringValue('SAP_ContactList');
        //String[] targetEmailList                          = targetEmailStr.split( ';' );
        gFRS_Ltng_Vendor_Detail__c location               = null;
        gFRS_Ltng_Organization__c objOrg                  = null;
        List<gFRS_Ltng_Application__c> fundingRequestsList = new List<gFRS_Ltng_Application__c>();
        
        GFRS_Ltng_OrgSettings__c orgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        
        String targetEmailStr;
        if(orgCS.SAP_ContactList__c == '' || orgCS.SAP_ContactList__c == null){
            targetEmailStr   = System.Label.GFRS_SAP_ContactList;
        } else {
            targetEmailStr   = orgCS.SAP_ContactList__c;
        }
        
        String[] targetEmailList                          = targetEmailStr.split( ';' );
        
        try {
            location = [ SELECT Name, Vendor_Id__c, gFRS_Organization__r.Id, 
                        gFRS_Organization__r.Organization_Name__c, 
                        gFRS_Organization__r.Tax_Id__c, gFRS_Organization__r.Tax_Status__c, 
                        Vendor_Name__c, Address__c, Address2__c, City__c, State__c, Province__c,
                        Zip__c, Department_Chapter_Country__c 
                        FROM gFRS_Ltng_Vendor_Detail__c 
                        WHERE Id = :locationId ];
        } catch(Exception e){
            //return 'Unable to find the location:';
            system.debug('@@ Unable to find the location:');
        }
        
        try
        {
            objOrg = [SELECT Id, gFRS_W9_Form_W_8BEN_Form__c
                      FROM gFRS_Ltng_Organization__c 
                      WHERE Id= : location.gFRS_Organization__r.Id];
        } catch(Exception e){
            //return 'Unable to find the org:';
            system.debug('@@ Unable to find the org:');
        }
        
        /*
Gathering gFRS Application records that are assigned to given location, but only with Status != "Intake","Closed".
*/
        fundingRequestsList = gFRS_Ltng_Util.getFundingRequestsByLocationId(locationId);
        
        
        String targetEmailName = (shouldCreate)? TEMPLATE_CREATE_SAP_LOC : TEMPLATE_UPDATE_SAP_LOC;
        EmailTemplate template = null;
        try {
            template = [ SELECT TemplateType, Subject, Name, Description, HtmlValue, Body 
                        FROM EmailTemplate 
                        WHERE DeveloperName = :targetEmailName limit 1 ];
        } catch(Exception e){ 
            template = null; 
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setUseSignature( true );
        mail.setSaveAsActivity(true);
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        
        if (objOrg.gFRS_W9_Form_W_8BEN_Form__c != null) {
            
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            //GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( objOrg.Attachments );
            //Attachment w9FormAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(objOrg.gFRS_W9_Form_W_8BEN_Form__c, objOrg.id);
            Set<id> ContentDocumentids = new Set<id>();
            
            for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid=:objOrg.Id])
            {
                ContentDocumentids.add(CDLink.ContentDocumentid);  
            }
            
            ContentVersion cv = [SELECT title,PathOnClient, FileType, versiondata FROM contentversion 
                                 WHERE ContentDocumentId =: objOrg.gFRS_W9_Form_W_8BEN_Form__c Limit 1 
                                ];
            Blob attBody = cv.VersionData;
            
            //Blob attBody = [SELECT Body FROM Attachment WHERE Id = :w9FormAttachment.Id].Body; 
            if (attBody != null) {
                att.setBody(attBody);
                att.setFileName(cv.title);
                att.setInline(false);
                att.setContentType('application/octet-stream');
                attachments.add(att);
            }
        }
        
        mail.setSubject(formatEmailSubject(template.Subject, location.Name));
        mail.setPlainTextBody( formatEmailText( template.Body, location, userName, userEmail, fundingRequestsList ));
        
        if(attachments.size() > 0){
            mail.setFileAttachments(attachments);
        }       
        
        List<String> ccAddresses = new List<String>{userEmail};
            
            /* if(String.isNotBlank(orgCS.Vendor_Update_CC_Email__c)){
                ccAddresses.add(orgCS.Vendor_Update_CC_Email__c); 
            } */
        
        mail.setccAddresses(ccAddresses);       
        
        //List<Messaging.SendEmailResult> result = Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
        
        List<gFRS_Ltng_Application__c> fundingReq = new List<gFRS_Ltng_Application__c>();
        fundingReq = [SELECT Id, Name, ACH_Details_Rec_ID__c FROM gFRS_Ltng_Application__c WHERE Vendor_Detail__c = :locationId AND ACH_Details_Rec_ID__c != null AND ACH_Details_Rec_ID__c != '' AND ACH_PDF_Sent_to_SAP__c = false AND Status__c != 'Intake' ];
        
        if(fundingReq.size() > 0){
            Integer count = 1;
            for(gFRS_Ltng_Application__c req : fundingReq){
                gFRS_Ltng_ACH_Details__c ACHDecryptedRec = new gFRS_Ltng_ACH_Details__c();
                gFRS_Ltng_ACH_Details__c ACHRec = [SELECT  Id,gFRS_Vendor_Detail__c,Account_Type__c,Payment_Method_UI__c,Bank_Routing_ID__c,Bank_Name__c,
                                                   Bank_Account_Number__c,IBAN__c,Account_Holder_Name__c,Payment_Information_Approver_Name__c,
                                                   Title__c,Do_you_require_intermediary_bank__c,Intermediary_Bank_Name__c,Intermediary_Bank_Country__c,
                                                   Intermediary_Bank_Account_Number__c,Intermediary_Bank_Swift_Code__c,Intermediary_Bank_Routing_ID__c 
                                                   FROM gFRS_Ltng_ACH_Details__c WHERE Id =: req.ACH_Details_Rec_ID__c];
                
                /*  ACHDecryptedRec.Bank_Routing_ID__c                  = decryptACH(ACHRec.Bank_Routing_ID__c);
ACHDecryptedRec.Bank_Name__c                        = decryptACH(ACHRec.Bank_Name__c);
ACHDecryptedRec.Bank_Account_Number__c              = decryptACH(ACHRec.Bank_Account_Number__c);
ACHDecryptedRec.IBAN__c                             = decryptACH(ACHRec.IBAN__c);
ACHDecryptedRec.Account_Holder_Name__c              = decryptACH(ACHRec.Account_Holder_Name__c);
ACHDecryptedRec.Account_Type__c                     = ACHRec.Account_Type__c;
ACHDecryptedRec.Payment_Method_UI__c                = ACHRec.Payment_Method_UI__c;
ACHDecryptedRec.Title__c                            = decryptACH(ACHRec.Title__c);
ACHDecryptedRec.Do_you_require_intermediary_bank__c = ACHRec.Do_you_require_intermediary_bank__c;

if(ACHRec.Do_you_require_intermediary_bank__c == 'Yes'){
ACHDecryptedRec.Intermediary_Bank_Name__c           = decryptACH(ACHRec.Intermediary_Bank_Name__c);
ACHDecryptedRec.Intermediary_Bank_Country__c        = decryptACH(ACHRec.Intermediary_Bank_Country__c);
ACHDecryptedRec.Intermediary_Bank_Account_Number__c = decryptACH(ACHRec.Intermediary_Bank_Account_Number__c);
ACHDecryptedRec.Intermediary_Bank_Swift_Code__c     = decryptACH(ACHRec.Intermediary_Bank_Swift_Code__c);
ACHDecryptedRec.Intermediary_Bank_Routing_ID__c     = decryptACH(ACHRec.Intermediary_Bank_Routing_ID__c);
}

insert ACHDecryptedRec;   */        
                
                PageReference ref = new PageReference('/apex/pages/gFRS_Ltng_ACHForm?id=' + ACHRec.Id + '&reqId=' + req.Id);
                ref.setRedirect(false);
                
                Messaging.EmailFileAttachment attch = new Messaging.EmailFileAttachment();
                Blob b = ref.getContent();
                attch.setBody(b);
                attch.setFileName('ACHForm '+count+'.pdf');
                attch.setInline(false);
                attch.setContentType('application/pdf');
                attachments.add(attch);
                
                //delete ACHDecryptedRec;
                
                count++;
                
            }
        }
        
        if(attachments.size() > 0){
            mail.setFileAttachments(attachments);
        }
        
        mail.setToAddresses( targetEmailList ); 
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        String serverURL = myOrgCS.Vendor_Update_CC_Email__c;       
        mail.setOrgWideEmailAddressId([
            SELECT Id, Address
            FROM OrgWideEmailAddress
            WHERE Address = :serverURL
            limit 1
        ][0].id);  
        
        List<Messaging.SendEmailResult> result1 = Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );        
        
        if(fundingReq.size() > 0){
            for(gFRS_Ltng_Application__c request : fundingReq){
                request.ACH_PDF_Sent_to_SAP__c = true;
            }
            gFRS_Ltng_Util_NoShare.updateApplicationRecords(fundingReq);
        }
        //return 'Success'; 
    } 
    
    public static string decryptACH(string stringToDecrypt){
        EncryptionKey__c keySetting = EncryptionKey__c.getOrgDefaults();
        Blob aesKey = EncodingUtil.base64Decode(keySetting.AesKey__c);
        Blob decoder = EncodingUtil.base64Decode(stringToDecrypt);
        Blob decryptor = Crypto.decryptWithManagedIV('AES256', aesKey, decoder);
        string decryptedStr = decryptor.toString();
        return decryptedStr;
    }    
    
    public static String formatEmailSubject( String emailSubject, String payeeName) {
        if(emailSubject == null) {
            return null;
        }
        
        emailSubject = emailSubject.replace(TAG_PAYEE_NAME, gFRS_Util.blankValue(payeeName, ''));
        return emailSubject;
    }
    
    public static String formatEmailText( String emailText, gFRS_Ltng_Vendor_Detail__c location, string userName, string userEmail, List<gFRS_Ltng_Application__c> fundingRequestsList) {
        if( emailText == null || location == null || userName == null || fundingRequestsList == null) return( null );
        
        String requestsListText = '';
        
        emailText = emailText.replace(TAG_ORGANIZATION_NAME,   gFRS_Util.blankValue( location.gFRS_Organization__r.Organization_Name__c, '' ));
        emailText = emailText.replace(TAG_ORGANIZATION_TAX_ID, gFRS_Util.blankValue( location.gFRS_Organization__r.Tax_Id__c, '' ));
        emailText = emailText.replace(TAG_ORGANIZATION_TAX_STATUS, gFRS_Util.blankValue( location.gFRS_Organization__r.Tax_Status__c, '' ));
        
        emailText = emailText.replace(TAG_VENDOR_ID,           gFRS_Util.blankValue( location.Vendor_Id__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_NAME,         gFRS_Util.blankValue( location.Name, '' ));
        emailText = emailText.replace(TAG_VENDOR_ADDRESS,      location.Address2__c == null ? gFRS_Util.blankValue( location.Address__c, '' ) : gFRS_Util.blankValue( location.Address__c + ' ' + location.Address2__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_CITY,         gFRS_Util.blankValue( location.City__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_STATE,        gFRS_Util.blankValue( location.State__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_PROVINCE,        gFRS_Util.blankValue( location.Province__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_ZIP,          gFRS_Util.blankValue( location.Zip__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_COUNTRY,      gFRS_Util.blankValue( location.Department_Chapter_Country__c, '' ));
        emailText = emailText.replace(TAG_USER_NAME,           userName);
        emailText = emailText.replace(TAG_USER_EMAIL,          userEmail);
        
        for(gFRS_Ltng_Application__c fundingRequest : fundingRequestsList){
            String giactResp = '';
            if(fundingRequest.Giact_Response__c != '' && fundingRequest.Giact_Response__c != null){
                giactResp = fundingRequest.Giact_Response__c;
            }
            requestsListText += fundingRequest.Record_Type__c + ': ' + fundingRequest.Name + '\n';
            requestsListText += 'Payment Contact Email Address' + ': ' + fundingRequest.Person_To_Whom_Payment_should_addressed__c + '\n';
            requestsListText += 'GIACT Response' + ': ' + giactResp + '\n\n';
        }
        
        emailText = emailText.replace(TAG_REQUEST_IDS, requestsListText);
        
        
        return( emailText );
    }    
    
    @AuraEnabled
    public static list<MatchedBank> getVendorBankDetails(String vendorID, String partnerBankType){
        list<MatchedBank> matchedBanks = new List<MatchedBank>();
        GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0 sapLookup = new GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0();
        sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
        GFRS_BankLookupSAP.BankInfoLookupResponse_element response;
        try {
            response = sapLookup.BankInfoLookup(vendorID);
            
            GFRS_BankLookupSAP.BankInfoDetails_element[] BankInfoDetailsvar = response.BankInfoDetails;
            
            if(BankInfoDetailsvar.size() > 0){
                for(GFRS_BankLookupSAP.BankInfoDetails_element element : BankInfoDetailsvar){
                    
                    if(String.isBlank(element.BankAccountNumber) && String.isBlank(element.BankInfoKey) && String.isBlank(element.PartnerBankType) && String.isBlank(element.Country)){
                        //nothing to do
                    } else {
                        matchedbank m = new matchedBank();
                        m.BankAccountNumberstring = element.BankAccountNumber; 
                        m.BankInfoKeystring = element.BankInfoKey;  
                        m.PartnerBankTypestring = element.PartnerBankType;
                        m.Countrystring = element.Country;
                        m.isselected = false;
                        if(partnerBankType == element.PartnerBankType){
                            m.isselected = true;
                        }
                        matchedBanks.add(m);                        
                    }
                }                
            }
            
            matchedBankDetails = matchedBanks;
            
            return matchedBanks;
        } catch( Exception e ){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj; 
        }
    }  
    
    public class MatchedBank {
        @AuraEnabled public boolean isselected{get; set;}
        @AuraEnabled public String BankAccountNumberString { get; set; }
        @AuraEnabled public String BankInfoKeyString { get; set; }
        @AuraEnabled public String PartnerBankTypeString { get; set; }
        @AuraEnabled public String CountryString { get; set; }
        
    }
    
    public class MatchedLocationsWrapper {
        @AuraEnabled public list<MatchedLocation> matchedLocations { get; set; }
        @AuraEnabled public map<string, MatchedLocation> matchedLocationsMap { get; set; }
    }
    
    public class MatchedLocation {
        
        @AuraEnabled public String errorMsg { get; set; }
        @AuraEnabled public String Organization_Name { get; set; }
        @AuraEnabled public String Tax_ID            { get; set; }
        @AuraEnabled public String Organization_Type { get; set; }
        @AuraEnabled public String Phone             { get; set; }
        @AuraEnabled public String Parent_Account    { get; set; }
        @AuraEnabled public String Address           { get; set; }
        @AuraEnabled public String Tax_Status        { get; set; }
        @AuraEnabled public String City              { get; set; }
        @AuraEnabled public String State             { get; set; }
        @AuraEnabled public String Zip               { get; set; }
        @AuraEnabled public String PoBox             { get; set; }
        @AuraEnabled public String PoBoxPostalCode   { get; set; }
        @AuraEnabled public String VendorId          { get; set; }
        @AuraEnabled public String PaymentMethod     { get; set; }
        @AuraEnabled public String VendorName        { get; set; }
        @AuraEnabled public String Country           { get; set; }
        @AuraEnabled public String Street4           { get; set; }
        @AuraEnabled public String Street5           { get; set; }
        @AuraEnabled public String NameLine1         { get; set; }
        @AuraEnabled public String NameLine2         { get; set; }
        @AuraEnabled public String NameLine3         { get; set; }
        @AuraEnabled public String NameLine4         { get; set; }
        @AuraEnabled public String PostingBlockSpecifiedCompanyCode  { get; set; }
        @AuraEnabled public String PostingBlockAllCompanyCode        { get; set; }
        @AuraEnabled public String PaymentBlockIndicator             { get; set; }
        @AuraEnabled public String PaymentBlockDescription           { get; set; }
        @AuraEnabled public String DeletionFlagSelectedCompanyCode   { get; set; }
        @AuraEnabled public String DeletionFlagAllArea      { get; set; }
        @AuraEnabled public String CompanyCodeFor1000        { get; set; }
        @AuraEnabled public String CompanyCodeFor1000Blocked     { get; set; }
        @AuraEnabled public String CompanyCodeFor1010      { get; set; }
        @AuraEnabled public String CompanyCodeFor1010Blocked      { get; set; }
    } 
    
    @AuraEnabled
    public static void generateACHForm(Id ACHRecId, Id appId){
        generatePDF(ACHRecId,appId);    
    }
    
    @future(callout=true)
    public static void generatePDF(Id ACHRecId, Id appId){
        
        //PageReference ref = new PageReference('https://genentech--gfrsdev08.my.salesforce.com/apex/pages/gFRS_Ltng_ACHForm?id=' + vendorDetailId);
        PageReference ref = new PageReference('/apex/pages/gFRS_Ltng_ACHForm?id=' + ACHRecId);
        System.debug(ref);
        ContentVersion cont = new ContentVersion();
        cont.Title = 'Auto-generated ACH Form';
        cont.PathOnClient = 'file.pdf';
        cont.VersionData = ref.getContentAsPdf();
        cont.OwnerId = UserInfo.getUserId();
        cont.Origin = 'H';
        Insert cont;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cont.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = ACHRecId;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        
    }    
    
}