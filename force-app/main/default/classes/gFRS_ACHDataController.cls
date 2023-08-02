/**
* @author GFRS Dev Team
* @date 02/06/2015
* @description gFRS_ACHDataController class - controller for gFRS_SunshineData page. Class is responsible for handling request from page and communication with database. 
*/
public without sharing class gFRS_ACHDataController {
  
    public GFRS_Location__c location                { get; set; }
    public GFRS_Funding_Request__c fundReq          { get; set; }
    public id reqId                                 { get; set; }
    public boolean extRequest                       { get; set; }
    public boolean isNewVendor;
    public String selectedValue                     { get; set; }
    public String intVendorSelection                { get; set; }
    public String currentVendorId                   { get; set; }
    public String isExistingACHInfo                 { get; set; }
    public MatchedLocation[] matchedLocations       { get; set; }
    public MatchedBank[] matchedBanks               { get; set; }
    public Map<String, MatchedLocation> locationMap { get; set; }    
    public string extBanktype;
    public List<GFRS_Funding_Request__c> fundRequests;
    public Id locationId;
    public MatchedBank[] matchedBanksList;
    public MatchedBank[] matchedBanksLst;
    public Boolean isEditable                       { get; set; }
    public Boolean hasACHInfo                       { get; set; }
    public string authSigner;
    public Boolean allowSubmit                      { get; set; }
    public Boolean isBankSelected                   { get; set; }
    public string currentUser                       { get; set; }
    public Boolean isActiveUser                     { get; set; }
    public Boolean isApproved                       { get; set; }
    public Boolean isInternationalVendor            { get; set; }
    public static final String PATH_HOME   =  '/apex/gFRS_Home';
    public Attachment ACH_PDF{
        get {
        if (ACH_PDF == null)
            ACH_PDF = new Attachment();
            return ACH_PDF;
        }
        set;
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 02/06/2015
    * @description Public constructor
    */ 
    public gFRS_ACHDataController(ApexPages.StandardController std){
      
        this.location = (GFRS_Location__c)std.getRecord();
        this.reqId = apexpages.currentpage().getparameters().get('fundingReq');
        this.fundReq = [select Id, name, Record_Type_Name__c, ACH_Received__c, Location__c, ACH_PDF_Sent_to_SAP__c, SAP_Payment_ID__c,
                                Signing_Authority_Email__c, Payment_Method__c, Partner_Bank_Type__c, ACH_Task_Open__c, Organization__r.US_Organization__c,
                                ACH_Att_Obj__c,ACH_Details_PDF__c ,Bank_Lookup_Required__c, Information_Needed__c, Send_By_FedEx_cost_center_will_be_charg__c 
                                FROM GFRS_Funding_Request__c where id = :this.reqId];
        this.location = [SELECT Id, IsDeleted, Name, Organization__r.Name, Organization__r.Organization_Name__c,
                                Organization__r.Tax_Id__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Partner_Bank_Type__c, 
                                SystemModstamp, MayEdit, IsLocked, Organization__c, Address_Line_1__c, Address_Line_2__c, Address__c, 
                                City__c, Department_Chapter_Country__c, Fax__c, Payment_Method__c, Phone__c, State__c, Street_4__c, 
                                Street__c, Vendor_ID__c, Vendor_Name_1__c, Vendor_Name_2__c, Vendor_Name_3__c, Vendor_Name_4__c, Vendor_Name__c, Zip__c, 
                                W9_Form_W_8BEN_Form__c, City_1__c, State_1__c, Country_1__c, Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c
                                FROM GFRS_Location__c WHERE id =: this.location.id];
                                
        this.extRequest = gFRS_Util.isExternalRequest(this.fundReq.Record_Type_Name__c) ? true : (this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME ? true : false);     
        extBanktype = '';
        currentVendorId = '';
        isExistingACHInfo = 'Yes';
        this.isNewVendor = false;
        this.isApproved = false;
        locationId = this.fundReq.Location__c;
        authSigner = this.fundReq.Signing_Authority_Email__c;
        this.isInternationalVendor = (fundReq.Organization__r.US_Organization__c=='Yes'?false:true);
        checkActiveUser();
        
        if(String.isNotBlank(this.fundReq.SAP_Payment_ID__c) && !this.extRequest){
            this.isApproved = true;
        }

        if(this.fundReq.Partner_Bank_Type__c != null && this.fundReq.Partner_Bank_Type__c != ''){          
          extBanktype = this.fundReq.Partner_Bank_Type__c;
          isBankSelected = true;
        }else if(this.location.Partner_Bank_Type__c != null && this.location.Partner_Bank_Type__c != ''){          
          extBanktype = this.location.Partner_Bank_Type__c;
          isBankSelected = true;
        }
        
        getAttachment();
        this.hasACHInfo = hasMatchedBanks();//to be assigned only if page is rendered in edit mode
        preselectValues();
        if(!this.extRequest || (String.isNotBlank(this.fundReq.Information_Needed__c) && gFRS_Util.multiSelectHasItem( this.fundReq.Information_Needed__c, 'Payment Method' ))){
            this.isEditable = true;
            
        }
        
    }

    public void checkActiveUser(){
        User activeUser = [Select Email From User where Username = : UserInfo.getUserName() limit 1];
        String activeUserMail = activeUser.Email;
        if((activeUserMail == authSigner) || extRequest){
            this.isActiveUser = true;
            currentUser = UserInfo.getName();
        }
    }
    
    public void checkUserChoice(){
        isExistingACHInfo = null;
        clearExistingBank_Selection();
        System.debug(fundReq.Name + ' has opted for bank payment -' + selectedvalue);
        if(selectedvalue=='No'){
            this.searchVendor();
            //Temporary Hard Code
            this.currentVendorId = '';
            deleteElectronic_Payment_Form();
            this.fundReq.Partner_Bank_Type__c = '';
            this.allowSubmit = true;
        }else{
           this.allowSubmit = String.isNotBlank(this.ACH_PDF.Name)?True:False;
           this.allowSubmit = String.isNotBlank(extBanktype)?True:False;
        }
    }
    
    public void checkIntVendorChoice(){
        isExistingACHInfo = null;
        clearExistingBank_Selection();
        deleteElectronic_Payment_Form();
        this.allowSubmit = false;
        selectedvalue = 'Yes';
        this.fundReq.Payment_Method__c = intVendorSelection;
        System.debug(fundReq.Name + ' has opted for bank payment -' + intVendorSelection);
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 04/07/2013
    * @description 
    Page method - handler of 'Submit' button click.
    */    
    public ApexPages.Pagereference savePage(){

        Boolean locSelected;
        Boolean bankSelected;
        string  partnerBank;
        List<GFRS_Funding_Request__c> reqList = new List<GFRS_Funding_Request__c>();
        
        fundRequests = [SELECT Id, Name, Bank_Lookup_Required__c, Payment_Method__c FROM GFRS_Funding_Request__c WHERE Location__c = :locationId AND Signing_Authority_Email__c = :authSigner
                            AND Payment_Method__c = 'Check' AND Bank_Lookup_Required__c = 'Yes' AND Id != :this.fundReq.Id];
        
        if(this.selectedValue == null){
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Please select your Payment Method' ));
            return null;
        }

        if(this.selectedValue == 'No'){

            this.fundReq.ACH_Received__c                      = 'Cheque';
            this.fundReq.Payment_Method__c                    = 'Check';
            this.fundReq.Bank_Lookup_Required__c              = 'No';
            this.fundReq.ACH_Task_Open__c                     = 'No';

            for(GFRS_Funding_Request__c req : fundRequests){
                req.Payment_Method__c           = 'Check';
                req.Bank_Lookup_Required__c     = 'No';
                req.ACH_Received__c             = 'Cheque';
                reqList.add(req);
                
            }
        }
        else if(this.selectedValue == 'Yes'){
            
            if(this.isExistingACHInfo == null){
                ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Please select any existing bank info OR upload new PDF' ));
                return null;
            }
            
            if(this.isExistingACHInfo == 'No'){
                if(this.ACH_PDF.name == null){
                    ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Please upload the filled Electronic Payment form' ));
                    return null;
                }
                this.fundReq.ACH_Details_PDF__c = this.ACH_PDF.Id;
                this.fundReq.ACH_Received__c                      = 'ACH';
                this.fundReq.Payment_Method__c                    = isInternationalVendor ? intVendorSelection :'ACH';
                this.fundReq.Bank_Lookup_Required__c              = 'Yes';
                this.fundReq.ACH_Task_Open__c                     = 'No';
                this.fundReq.ACH_PDF_Sent_to_SAP__c               = false;
                this.fundReq.Partner_Bank_Type__c                 = '';
                this.fundReq.Send_By_FedEx_cost_center_will_be_charg__c = 'N/A';
            
                for(GFRS_Funding_Request__c req1 : fundRequests){
                    req1.Payment_Method__c              = 'ACH';
                    req1.Bank_Lookup_Required__c        = 'Yes';
                    req1.ACH_Received__c                = 'ACH';
                    reqList.add(req1);
                    
                }               
            }
            
            if(this.isExistingACHInfo == 'Yes'){
                
                bankSelected = false;
                if(MatchedBanks == null || MatchedBanks.size() == 0){
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Currently no bank details are available. Please submit bank info for a new account.' ));
                    return null;
                }
                
                for(MatchedBank mb: MatchedBanks){
                    if(mb.isselected == true){
                        this.fundReq.ACH_Received__c                      = 'ACH';
                        this.fundReq.Payment_Method__c                    = isInternationalVendor ? intVendorSelection :'ACH';
                        this.fundReq.Bank_Lookup_Required__c              = 'No';
                        this.fundReq.ACH_Task_Open__c                     = 'No';
                        this.fundReq.Partner_Bank_Type__c                 = mb.PartnerBankTypeString;
                        this.location.Partner_Bank_Type__c                 = mb.PartnerBankTypeString;
                        this.fundReq.Send_By_FedEx_cost_center_will_be_charg__c = 'N/A';
                        partnerBank                                       = mb.PartnerBankTypeString;
                        bankSelected = true;
                    }
                }
              if(bankSelected == false){
                    ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Please select bank info' ));
                } 
            
                for(GFRS_Funding_Request__c req2 : fundRequests){
                    req2.Payment_Method__c          = isInternationalVendor ? intVendorSelection :'ACH';
                    req2.Bank_Lookup_Required__c    = 'No';
                    req2.Partner_Bank_Type__c       = partnerBank;
                    req2.ACH_Received__c            = 'ACH';
                    reqList.add(req2);
                    
                }               
            }
        } 
        
        this.fundReq.ACH_Task_Open__c                     = 'No';
        
        reqList.add(this.fundReq);
        
        if( !ApexPages.hasMessages() ){
          
            gFRS_Util_NoShare.saveLockedLocation(this.location);
            gFRS_Util_NoShare.saveLockedFundingRequests(reqList);
        
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_HOME, null, null ) ));
        }

        return null;
    } 
    
    public ApexPages.Pagereference saveAndContinue(){
        
        Boolean locSelected;
        Boolean bankSelected;
        if(this.selectedValue == null){
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Please select your Payment Method' ));
            return null;
        }

        if(this.selectedValue == 'No'){
            this.fundReq.ACH_Received__c                      = 'Cheque';
            this.fundReq.Payment_Method__c                    = 'Check';
            this.fundReq.Bank_Lookup_Required__c              = 'No';
            this.fundReq.ACH_Task_Open__c                     = 'No';
        }
        else if(this.selectedValue == 'Yes'){
            
            if(this.isExistingACHInfo == null){
                ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Please select any existing bank info OR upload new PDF' ));
                return null;
            }
            
            if(this.isExistingACHInfo == 'No'){
                if(this.ACH_PDF.name == null){
                    ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Please upload the filled Electronic Payment form' ));
                    return null;
                }
                this.fundReq.ACH_Details_PDF__c = this.ACH_PDF.Id; 
                this.fundReq.ACH_Received__c                      = 'ACH';
                this.fundReq.Payment_Method__c                    = isInternationalVendor ? intVendorSelection :'ACH';
                this.fundReq.Bank_Lookup_Required__c              = 'Yes';
                this.fundReq.ACH_Task_Open__c                     = 'No';
                this.fundReq.Partner_Bank_Type__c                 = '';
                this.fundReq.ACH_PDF_Sent_to_SAP__c               = false;              
            }
            
            if(this.isExistingACHInfo == 'Yes'){
                bankSelected = false;
                if(MatchedBanks == null || MatchedBanks.size() == 0){
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Currently no bank details are available. Please submit bank info for a new account.' ));
                    return null;
                }
                
                for(MatchedBank mb: MatchedBanks){
                    if(mb.isselected == true){
                        this.fundReq.ACH_Received__c                      = 'ACH';
                        this.fundReq.Payment_Method__c                    = isInternationalVendor ? intVendorSelection :'ACH';
                        this.fundReq.Bank_Lookup_Required__c              = 'No';
                        this.fundReq.ACH_Task_Open__c                     = 'No';
                        this.fundReq.Partner_Bank_Type__c                 = mb.PartnerBankTypeString;
                        bankSelected = true;
                    }
                }
                
                if(bankSelected == false){
                    ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Please select bank info' ));
                    return null;
                }
               
            }
        } 
        
        this.fundReq.ACH_Task_Open__c                     = 'No';
        
        if( !ApexPages.hasMessages() ){
          
            gFRS_Util_NoShare.saveLockedLocation(this.location);
            gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(this.fundReq);
        
            return( new ApexPages.PageReference( '/apex/GFRS_Confirmation?id=' + this.fundReq.id ));
        }

        return null;
    }   
    
    public ApexPages.PageReference back() {
        if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME){
            return new ApexPages.PageReference('/apex/GFRS_Budget?id=' + this.fundReq.id);
        }
        else{
            return new ApexPages.PageReference('/apex/GFRS_FileAttachments?id=' + this.fundReq.id);
        }
    }
    
     public ApexPages.PageReference next() {
         return( new ApexPages.PageReference( '/apex/GFRS_Confirmation?id=' + this.fundReq.id ));
     }
    
    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description uploadFundingRequestAttachment method - generic method for uploads of attachments for gFRS Funding Request object. 
    */
    public void uploadACH_PDF(){
        
        this.isExistingACHInfo = 'No';
        EncryptionKey__c keySetting = EncryptionKey__c.getOrgDefaults();
        if(String.isBlank(keySetting.aeskey__c)) {
            keySetting.aeskey__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256));
            upsert keySetting;
        }
        Blob aesKey;
        aesKey = EncodingUtil.base64Decode(keySetting.AesKey__c);
        
        if(String.isBlank(this.fundReq.ACH_Details_PDF__c)){
            CustomObject__c childObj = new CustomObject__c();
            childObj.Name = this.fundReq.Name + '_attachments';
            gFRS_Util_NoShare.saveAchAttObject(childObj);
            this.ACH_PDF.ParentId = childObj.Id;
            gFRS_Util_NoShare.saveLockedAttachment(this.ACH_PDF);
            this.fundReq.ACH_Att_Obj__c = childObj.Id;
            this.fundReq.ACH_Details_PDF__c = this.ACH_PDF.Id;
        }

        this.ACH_PDF.body = Crypto.encryptWithManagedIV('AES256', aesKey, this.ACH_PDF.Body);
        
        update this.ACH_PDF;    
        ACH_PDF.body = null;//to prevent view state error
        this.allowSubmit = true;
        clearExistingBank_Selection();
    }
    
    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }
    
    public List<SelectOption> getACHOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Validate bank info submitted previously')); 
        options.add(new SelectOption('No','Submit bank info for a new account')); 
        return options; 
    }
    
    public List<SelectOption> getIntVendorOptions(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('ACH','ACH')); 
        options.add(new SelectOption('Wire','Wire')); 
        return options; 
    }
    
    public void banktypechanged(){
        string passedParam1 = Apexpages.currentPage().getParameters().get('myParam');
        this.isExistingACHInfo = 'Yes';
        deleteElectronic_Payment_Form();
        for(matchedBank m : matchedBanks){
            if(m.PartnerBankTypestring == passedParam1){
                if(this.extBanktype == passedParam1){
                    m.isselected = false;
                    this.extBanktype = null;
                    this.allowSubmit = false;
                    this.isBankSelected = false;
                }else{
                    m.isselected = true;
                    this.extBanktype = passedParam1;
                    this.allowSubmit = true;
                    this.isBankSelected = true;
                }
            }else{
                m.isselected = false;
            }
        }
    }
    
    public void vendorChanged(){
        string passedParam2 = Apexpages.currentPage().getParameters().get('myParam2');
        deleteElectronic_Payment_Form();
        for(matchedLocation m : matchedLocations){
            if(m.VendorId == passedParam2){
                if(this.currentVendorId == passedParam2){
                    if(m.isselected = true){
                        m.isselected =  false;
                        this.currentVendorId = null;
                        this.allowSubmit = false;
                    }
                }
                else{
                    m.isselected =  true;
                    this.currentVendorId = passedParam2;
                    this.allowSubmit = true;                        
                }
            }else if(m.VendorId == 'new'){
                if(this.currentVendorId == 'new'){
                    if(m.isselected = true){
                        m.isselected =  false;
                        this.currentVendorId = null;
                        this.allowSubmit = false;
                    }
                }else{
                        m.isselected =  true;
                        this.currentVendorId = 'new';
                        this.allowSubmit = true;                        
                    }
                }
            else{
                m.isselected = false;
            }
        }
    } 
    
    public void searchVendor(){
        
        matchedLocations = new List<MatchedLocation>();
        gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0 sapLookup = new gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0();
        sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
        
        GFRS_VendorLookupSAP.VendorLookupResponse_element response;
        //response = sapLookup.VendorLookup( '', '', this.location.Organization__r.Tax_Id__c, '', '', '100' );

        if(String.isBlank(this.location.Vendor_ID__c)){
            MatchedLocation l = new MatchedLocation();
            l.Address = this.location.Address__c;
            l.Street4 = this.location.Street_4__c;
            l.Street5 = this.location.Street__c;
            l.City = this.location.City__c;
            l.State = this.location.State__c;
            l.Country = this.location.Department_Chapter_Country__c;
            l.Zip = this.location.Zip__c;
            l.VendorId = 'new';
            l.concatenateLocationInfo();
            this.isNewVendor = True;
            matchedLocations.add(l);
            this.locationMap = new Map<String, MatchedLocation>();
            this.locationMap.put('new', l);
        }else{
            response = sapLookup.VendorLookup( '', this.location.Vendor_ID__c, '', '', '', '100' );
            handleResponse(response);
        }
    }
    
    public void handleResponse(GFRS_VendorLookupSAP.VendorLookupResponse_element response) {
        
        if ( response.MessageText != null ) {
            //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, response.MessageText ));
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'No Vendor found for current organization tax Id' ));
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
            l.PostingBlockAllCompanyCode    = d.PostingBlockAllCompanyCode;
            l.PaymentBlockIndicator        = d.PaymentBlockIndicator;
            l.PaymentBlockDescription      = d.PaymentBlockDescription;
            l.DeletionFlagSelectedCompanyCode  = d.DeletionFlagSelectedCompanyCode;
            l.DeletionFlagAllArea        = d.DeletionFlagAllArea;
            l.concatenateLocationInfo();

            matchedLocations.add(l);
        }
        this.locationMap = new Map<String, MatchedLocation>();
        for (MatchedLocation m : matchedLocations) {
            this.locationMap.put(m.VendorID, m);
        }        

    }
    
    public void searchBank(){
        if(string.isBlank(this.location.Vendor_ID__c)){
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Currently no bank details are available. Please submit bank info for a new account.' ));
            return;
        }else{
            matchedBanks = new List<MatchedBank>();
            matchedBanksLst = new List<MatchedBank>();
            GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0 sapLookup = new GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0();
            sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
             GFRS_BankLookupSAP.BankInfoLookupResponse_element response;
            try {
                response = sapLookup.BankInfoLookup(this.location.Vendor_ID__c);
                system.debug('responsevar'+response);
                GFRS_BankLookupSAP.BankInfoDetails_element[] BankInfoDetailsvar = response.BankInfoDetails;
                for(GFRS_BankLookupSAP.BankInfoDetails_element element : BankInfoDetailsvar){
                    matchedbank m = new matchedBank();
                    m.BankAccountNumberstring = element.BankAccountNumber; 
                    m.BankInfoKeystring = element.BankInfoKey;  
                    m.PartnerBankTypestring = element.PartnerBankType;
                    m.Countrystring = element.Country;
                    m.concatenateBankInfo();
                    if(isBankInfoValid(m)){
                        //matchedbanks.add(m);
                        if(extBanktype == element.PartnerBankType){
                            m.isselected = true;
                            matchedbanksLst.add(m);
                        }
                    }
                }
                matchedbanks.addall(matchedbanksLst);
                for(GFRS_BankLookupSAP.BankInfoDetails_element element : BankInfoDetailsvar){
                    matchedbank m = new matchedBank();
                    m.BankAccountNumberstring = element.BankAccountNumber; 
                    m.BankInfoKeystring = element.BankInfoKey;  
                    m.PartnerBankTypestring = element.PartnerBankType;
                    m.Countrystring = element.Country;
                    m.concatenateBankInfo();
                    if(isBankInfoValid(m)){
                        //matchedbanks.add(m);
                        if(extBanktype == element.PartnerBankType){
                                //Nothing to be done
                        }
                        else{
                            matchedbanks.add(m);
                        }
                    }
                }
            }catch(Exception err){
            System.debug( 'ERROR OCCURRED:' + err.getMessage() );
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem' ));
            return;
            }
        }
    }
    
    public void getAttachment(){
        
        if(this.fundReq.ACH_Att_Obj__c != null && String.isNotBlank(this.fundReq.ACH_Details_PDF__c)){
            Id attmntID = Id.valueOf(this.fundReq.ACH_Details_PDF__c);
            this.ACH_PDF = [SELECT Id, ParentId, Name, Body, CreatedDate, Description FROM Attachment WHERE ParentId = :this.fundReq.ACH_Att_Obj__c AND Id =:attmntID];
        }
    }
    
    public void deleteElectronic_Payment_Form(){
        
        if(this.fundReq.ACH_Att_Obj__c != null){
            CustomObject__c[] cstObj  = [SELECT Id, Name FROM CustomObject__c WHERE Id = :this.fundReq.ACH_Att_Obj__c];
            this.fundReq.ACH_Att_Obj__c = null;
            delete cstObj;
                        
        }
        
        if(String.isNotBlank(this.fundReq.ACH_Details_PDF__c)){
            Id attmntID = Id.valueOf(this.fundReq.ACH_Details_PDF__c);
            Attachment[] athcmnt = [SELECT Id, Name FROM Attachment WHERE Id = :attmntID];
            this.fundReq.ACH_Details_PDF__c = '';
            delete athcmnt;
        }
        
        this.ACH_PDF = new Attachment();
    }
    
    public void clearExistingBank_Selection(){
        this.currentVendorId = '';
        this.fundReq.Partner_Bank_Type__c = '';
        this.isBankSelected = false;
        if(hasACHInfo){
            for(MatchedBank mb : matchedBanks){
                mb.isselected = false;
            }
        }
    }
    
    public Boolean hasMatchedBanks(){
        boolean hasValidBank = false;
        if(string.isBlank(this.location.Vendor_ID__c)){
            return hasValidBank;
        }else{
            matchedBanks = new List<MatchedBank>();
            matchedBanksList = new List<MatchedBank>();
            GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0 sapLookup = new GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0();
            sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
            GFRS_BankLookupSAP.BankInfoLookupResponse_element response;
            try{
                response = sapLookup.BankInfoLookup(this.location.Vendor_ID__c);
                system.debug('responsevar'+response);
                GFRS_BankLookupSAP.BankInfoDetails_element[] BankInfoDetailsvar = response.BankInfoDetails;
                if(BankInfoDetailsvar.size()>0){
                    for(GFRS_BankLookupSAP.BankInfoDetails_element element : BankInfoDetailsvar){
                        matchedbank m = new matchedBank();
                        m.BankAccountNumberstring = element.BankAccountNumber; 
                        m.BankInfoKeystring = element.BankInfoKey;  
                        m.PartnerBankTypestring = element.PartnerBankType;
                        m.Countrystring = element.Country;
                        m.concatenateBankInfo();
                        if(isBankInfoValid(m)){
                            //matchedbanks.add(m);
                            hasValidBank = true;
                            if(extBanktype == element.PartnerBankType){
                                m.isselected = true;
                                matchedbanksList.add(m);
                            } 
                        }
                    }
                    matchedbanks.addall(matchedbanksList);
                    for(GFRS_BankLookupSAP.BankInfoDetails_element element1 : BankInfoDetailsvar){
                        matchedbank m1 = new matchedBank();
                        m1.BankAccountNumberstring = element1.BankAccountNumber; 
                        m1.BankInfoKeystring = element1.BankInfoKey;  
                        m1.PartnerBankTypestring = element1.PartnerBankType;
                        m1.Countrystring = element1.Country;
                        m1.concatenateBankInfo();
                        if(isBankInfoValid(m1)){
                            //matchedbanks.add(m1);
                            hasValidBank = true;
                            if(extBanktype == element1.PartnerBankType){
                                    //Nothing to be done
                            }
                            else{
                                matchedbanks.add(m1);
                            }
                        }
                    }
                }
                return hasValidBank;
            }catch(Exception err){
                System.debug( 'ERROR OCCURRED:' + err.getMessage() );
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem' ));
                return hasValidBank;  
            }
        }
    }
        
    public void preselectValues(){
        String userSelection;
        if(string.isBlank(this.fundReq.Payment_Method__c)){
            userSelection = 'None';
        }else{
            if(String.isNotBlank(this.fundReq.Payment_Method__c) && this.fundReq.Payment_Method__c.equalsIgnoreCase('check')){
                if((String.isNotBlank(this.fundReq.Bank_Lookup_Required__c) && this.fundReq.Bank_Lookup_Required__c.equalsIgnoreCase('No'))
                       && (String.isNotBlank(this.fundReq.ACH_Received__c) && this.fundReq.ACH_Received__c.equalsIgnoreCase('cheque'))){
                    this.extBanktype = null;
                    this.isBankSelected = false;
                    userSelection = 'Check';
                    this.searchVendor();
                    //Temporary Hard Code as a given vendor has only one location at a time.
                    matchedLocation loc = matchedLocations.get(0);
                    loc.isSelected = True;
                    if(String.isBlank(loc.VendorID)){
                       this.isNewVendor = true; 
                    }else{
                        this.currentVendorId = loc.VendorID;
                    }
                    
                }
            }else if(!this.fundReq.Payment_Method__c.equalsIgnoreCase('check')){
                if(String.isBlank(this.fundReq.Partner_Bank_Type__c)){
                    this.extBanktype = null;
                    this.isBankSelected = false;
                    this.currentVendorId = null;
                    userSelection = 'New_Account';
                }else{
                    this.currentVendorId = null;
                    userSelection = 'Existing_Account';
                    this.searchBank();
                }
            }
        }
        if(userSelection == 'check'){
            this.selectedValue = 'No';
            this.extBanktype = null;
            this.allowSubmit = true;
        }else if(userSelection == 'Existing_Account'){
            this.selectedValue = 'Yes';
            this.isExistingACHInfo = 'Yes';
            this.allowSubmit = true;
            this.currentVendorId = null;
        }else if(userSelection == 'New_Account'){
            this.selectedValue = 'Yes';
            this.isExistingACHInfo = 'No';
            this.allowSubmit = true;
            clearExistingBank_Selection();
        }else{
            this.selectedValue = 'Yes';
            this.intVendorSelection = 'Wire';
            if(this.hasACHInfo){
                isExistingACHInfo = 'Yes';
            }else{
                isExistingACHInfo = 'No';       
        }
            this.allowSubmit = String.isNotBlank(extBanktype)?True:False;
        }
        
        if(isInternationalVendor){
            if(String.isNotBlank(this.fundReq.Payment_Method__c) && !(this.fundReq.Payment_Method__c.trim()).equalsIgnoreCase('check')){
                this.intVendorSelection = this.fundReq.Payment_Method__c;   
            }
        }
    }
    
    public boolean isBankInfoValid(MatchedBank mb){
        if(String.isNotBlank(mb.BankAccountNumberString) && !(mb.BankAccountNumberString.trim()).equalsIgnoreCase('null')){
            return true;
        }else if(String.isNotBlank(mb.BankInfoKeyString) && !(mb.BankInfoKeyString.trim()).equalsIgnoreCase('null')){
            return true;
        }else if(String.isNotBlank(mb.CountryString) && !(mb.CountryString.trim()).equalsIgnoreCase('null')){
            return true;
        }
        return false;
    }
    
    public class MatchedLocation {
        public Boolean isSelected {get; set;}
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
        public String PostingBlockSpecifiedCompanyCode   { get; set; }
        public String PostingBlockAllCompanyCode    { get; set; }
        public String PaymentBlockIndicator        { get; set; }
        public String PaymentBlockDescription      { get; set; }
        public String DeletionFlagSelectedCompanyCode  { get; set; }
        public String DeletionFlagAllArea        { get; set; }
        public String locInfoStringForUI        { get; set; }
        
        public MatchedLocation(){
            this.isselected = False;
        }
        
        public void concatenateLocationInfo(){
            
            locInfoStringForUI = '';
            
            if(!String.isBlank(Address)){
                locInfoStringForUI = locInfoStringForUI + Address + ', '; 
            }
            if(!String.isBlank(Street4)){
                locInfoStringForUI =  locInfoStringForUI  + Street4 + ', ';
            }
            if(!String.isBlank(Street5)){
                locInfoStringForUI = locInfoStringForUI +Street5 + ', ';
            }
            if(!String.isBlank(City)){
                if(!String.isBlank(locInfoStringForUI)){
                    locInfoStringForUI = locInfoStringForUI + City +  ', ';
                }else{
                    locInfoStringForUI = locInfoStringForUI + City + ', ';
                }
                
            }
            if(!String.isBlank(State)){
                locInfoStringForUI = locInfoStringForUI + State + ', ';
            }
            if(!String.isBlank(Country)){
               locInfoStringForUI = locInfoStringForUI + Country + ', ';
            }
            if(!String.isBlank(Zip)){
               locInfoStringForUI = locInfoStringForUI + Zip+ '.' ;
            }
        }
    }
    
    public class MatchedBank {
        public boolean isselected{get; set;}
        public string BankId  {get; set;}
        public String BankAccountNumberString { get; set; }
        public String BankInfoKeyString { get; set; }
        public String PartnerBankTypeString { get; set; }
        public String CountryString { get; set; }
        public String bankInfoStringForUI {get; set;}
        
        public MatchedBank(){
            this.isselected = false;
        }
        
    public void concatenateBankInfo(){
        bankInfoStringForUI =   'lnbrx' + 'Bank Reference ID: ' + PartnerBankTypeString + 
                                'lnbrx' + 'Bank Account Number: ' + BankAccountNumberString + 
                                'lnbrx' + 'Bank Routing Number: ' + BankInfoKeyString + 
                                'lnbrx' + 'Country : ' + CountryString;
    }
        
    }
    
}