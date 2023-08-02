public with sharing class gFRS_VendorBankLookupController {
        
        
        
        public GFRS_Location_Copay__c currentLocation         { get; set; }
        public String currentVendorId                   { get; set; }
        public Boolean isSuccessRedirect                { get; set; }
        public Boolean hasMessages                      { get { return( ApexPages.hasMessages() );}}
        public Map<String, MatchedBank> BankMap { get; set; }
        public String currentBankId                   { get; set; }
        public MatchedBank[] matchedBanks       { get; set; }
        public Boolean hasMatchedBanks              { get {return( this.matchedBanks != null && this.matchedBanks.size() > 0 );}}
        public string extBanktype;
        
        public gFRS_VendorBankLookupController( ApexPages.StandardController std ) {
        this.currentLocation = (GFRS_Location_Copay__c)std.getRecord();
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
                    Zip_Code_1__c, W9_Form_W_8BEN_Form_URL__c,
                    Partner_Bank_Type__c
                    FROM GFRS_Location_Copay__c 
                    WHERE id =: this.currentLocation.id];
          extBanktype = '';
          if(this.currentLocation.Partner_Bank_Type__c != null && this.currentLocation.Partner_Bank_Type__c != ''){          
          extBanktype = this.currentLocation.Partner_Bank_Type__c;          
          }
          
        } catch( Exception err ){
        
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find location' ));
        return;
        }
        
        this.searchBank();
        this.isSuccessRedirect = this.checkIsSuccessRedirect();
        }
        
        public Boolean checkIsSuccessRedirect() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        return params.containsKey('success');
        }
        
        public void banktypechanged(){
        string passedParam1 = Apexpages.currentPage().getParameters().get('myParam');
        for(matchedBank m :matchedBanks){
        system.debug(m+passedParam1);
        if(m.PartnerBankTypestring == passedParam1){
        m.isselected = true;
        system.debug(m);
        }
        else{
        m.isselected = false;
        system.debug(m);
        }
        system.debug(m);
      
        }
          }
        
        public void searchBank(){
        matchedBanks = new List<MatchedBank>();
        GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0 sapLookup = new GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0();
        sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
         GFRS_BankLookupSAP.BankInfoLookupResponse_element response;
        try {
        response = sapLookup.BankInfoLookup(this.currentLocation.Vendor_ID__c);
        system.debug('responsevar'+response);
        GFRS_BankLookupSAP.BankInfoDetails_element[] BankInfoDetailsvar = response.BankInfoDetails;
        for(GFRS_BankLookupSAP.BankInfoDetails_element element : BankInfoDetailsvar){
        matchedbank m = new matchedBank();
        m.BankAccountNumberstring = element.BankAccountNumber; 
        m.BankInfoKeystring = element.BankInfoKey;  
        m.PartnerBankTypestring = element.PartnerBankType;
        m.Countrystring = element.Country;
        if(extBanktype == element.PartnerBankType){
        m.isselected = true;
        }
        matchedbanks.add(m);
        }
        } catch( Exception err ){
        System.debug( 'ERROR OCCURRED:' + err.getMessage() );
        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem' ));
        return;
        }
        }
        
        public ApexPages.PageReference savePage() {
        for(MatchedBank mb: MatchedBanks){
        if(mb.isselected == true){
        this.currentLocation.Partner_Bank_Type__c = mb.PartnerBankTypeString;
        }
        }
        update this.currentlocation;
        return redirectToLocation();
        }
        
        public ApexPages.PageReference redirectToLocation() {
        return new ApexPages.StandardController( this.currentLocation ).view();
        }
        
        public class MatchedBank {
        public boolean isselected{get; set;}
        public string BankId  {get; set;}
        public String BankAccountNumberString { get; set; }
        public String BankInfoKeyString { get; set; }
        public String PartnerBankTypeString { get; set; }
        public String CountryString { get; set; }
        public MatchedBank(){
        this.isselected = false;
        }
        
        }
        
        }