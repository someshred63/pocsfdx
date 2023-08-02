public without sharing class SRW_AddNewTradingPartnerController {

    public TradingPartnerWrapper                    newTradingPartner       { get; set; }
    
    public Product_vod__c[] products { get{
                                    products =  [SELECT active__c,Description_vod__c,Name FROM Product_vod__c 
                                                 WHERE active__c = true AND Product_Type_vod__c = 'SRW' 
                                                 ORDER BY Name ASC NULLS LAST];
                                    if(products.isEmpty()){
                                         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No products are available. Please contact system administrator.');
                                         ApexPages.addMessage(myMsg);
                                    }
                                    return products;
                                }
                            set; }
                             
    public List<Product_vod__c> selectedProducts { set; get;}
    public string selectedProductName   { get; private set;}
    
    public void setselectedProductName(string productName){
        this.selectedProductName = productName;
        system.debug('setter: '+selectedProductName+'  '+productName);
    }                               
    public List<SelectOption> productsSelect {get{
                                                List<SelectOption> optionList = new List<SelectOption>();
                                                for(Product_vod__c tempProduct: products){
                                                    optionList.add(new SelectOption(tempProduct.name, tempProduct.name));
                                                }
                                                return optionList;
                                                } set;}
    private boolean isTradingPartnerDuplicated(string name){
        List<SRW_Trading_Partner_Profile__c> duplicatedTradingPartnerProfile = [select id from SRW_Trading_Partner_Profile__c where Trading_Partner_Name_gne__c = :name limit 1];
        if(duplicatedTradingPartnerProfile.size() != 0){
            return true;
        }else{
            return false;
        }
    }
    public boolean selectAllProducts {get;set;}
    public  List<ProductsWrapper> tradingPartnerProducts {get; set{
        tradingPartnerProducts = value;
        System.debug('--- set tradingPartnerProducts ' + value);
        }}
    public  String selectedTPProdIds { get; 
        set{
            selectedTPProdIds = value;
            System.debug('-------- setter value ' + value);

            } }
   
    
    
    public SRW_AddNewTradingPartnerController() {
        System.debug('---------- init ');
        newTradingPartner = new TradingPartnerWrapper();
        selectedProducts = new List<Product_vod__c>();
        tradingPartnerProducts = fillTradingPartnerProductsList();
        //selectedTPProdIds = '';
    }
     public PageReference clear(){
         clearImpl();
         PageReference pg = new PageReference(System.currentPageReference().getURL());
         pg.setRedirect(false);
         
         return null;
     }
    
    public void clearImpl() {
         System.debug('---------- CLEAR ----------');
         newTradingPartner = new TradingPartnerWrapper();
         selectedProducts = new List<Product_vod__c>();
         selectedTPProdIds  = '';
         system.debug('tradingPartnerProducts: '+tradingPartnerProducts);
         for(ProductsWrapper pw : tradingPartnerProducts){
            pw.isSelected = false;
        }
    }
    public PageReference assignProduct(){
        system.debug('selectedProductName: '+ selectedProductName);
        for(Product_vod__c tempProduct: products){
                if(tempProduct.Name == selectedProductName){
                    if(selectedProducts == null) {
                        List<Product_vod__c> selectedProducts = new List<Product_vod__c>();
                        selectedProducts.add(tempProduct);
                    }else{
                    selectedProducts.add(tempProduct);
                    }
                }
            }
        return null;
    }

    
    public  void setupNewProductToTPAssignment(){
        system.debug('----- new - selectedTPProdIds: '+selectedTPProdIds);
        for(ProductsWrapper pw : tradingPartnerProducts){
            if(pw.isSelected == true){system.debug('----- before input hidden selected:' + pw.product.Name);}
        }
        List<Id> selectedTPProdIdsList = new list<Id>();
        if(selectedTPProdIds != null && selectedTPProdIds != ''){
            system.debug('----- inside if - selectedTPProdIds: '+selectedTPProdIds);
            if(selectedTPProdIds.contains(',')){
                selectedTPProdIdsList = selectedTPProdIds.split(',');
            }else{
                selectedTPProdIdsList.add(selectedTPProdIds);
            }
        }
        system.debug('----- new - selectedTPProdIdsList: '+selectedTPProdIdsList);
        for(ProductsWrapper pw : tradingPartnerProducts){
            pw.isSelected = false;
        }
        for(string tmp: selectedTPProdIdsList){
            for(ProductsWrapper pw : tradingPartnerProducts){
                if(tmp == string.valueOf(pw.product.Id)){ 
                    pw.isSelected = true;
                }
            }
        }
        for(ProductsWrapper pw : tradingPartnerProducts){
            if(pw.isSelected == true){system.debug('----- after input hidden selected:' + pw.product.Name);}
        }   
        
        
    } 
      
    public PageReference submitAndStartAnother() {
        pageReference pr = ApexPages.currentPage();
        if(submitImpl()==true){
            clear();
        }
        
        return null;
    }

    public PageReference submit() {
        if(submitImpl()==true){
            PageReference pr = new PageReference('/apex/SRW_TradingPartnerManagement');
            pr.setRedirect(true);
            return pr;
        }else{
            return null;
        }
        
    }
    
    public boolean submitImpl() {
        System.debug('---- submit impl selectedTPProdIds ' + selectedTPProdIds);
        
        
        List<Id> selectedTPProdIdsList = new list<Id>();
        if(selectedTPProdIds != null && selectedTPProdIds != ''){
            system.debug('----- inside if - selectedTPProdIds: '+selectedTPProdIds);
            if(selectedTPProdIds.contains(',')){
                selectedTPProdIdsList = selectedTPProdIds.split(',');
            }else{
                selectedTPProdIdsList.add(selectedTPProdIds);
            }
        }
        system.debug('----- new - selectedTPProdIdsList: '+selectedTPProdIdsList);
        for(ProductsWrapper pw : tradingPartnerProducts){
            pw.isSelected = false;
        }
        for(string tmp: selectedTPProdIdsList){
            for(ProductsWrapper pw : tradingPartnerProducts){
                if(tmp == string.valueOf(pw.product.Id)){ 
                    pw.isSelected = true;
                }
            }
        }
        
        
        for(ProductsWrapper pw : tradingPartnerProducts){
            if(pw.isSelected == true){system.debug('---- submit: selected:' + pw.product.Name);}
        }
        
        if(newTradingPartner.tradingPartnerName == null || newTradingPartner.tradingPartnerName == '' ||
        newTradingPartner.tradingPartnerPhoneNumberArea == null || newTradingPartner.tradingPartnerPhoneNumberArea == '' ||
        newTradingPartner.tradingPartnerPhoneNumber == null || newTradingPartner.tradingPartnerPhoneNumber == '' ||
        newTradingPartner.contactFirstName == null || newTradingPartner.contactFirstName == '' ||
        newTradingPartner.contactLastName == null || newTradingPartner.contactLastName == '' ||
        newTradingPartner.contactEmailAddress == null || newTradingPartner.contactLastName == '' ||
        newTradingPartner.userName == null || newTradingPartner.userName == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Trading Partner Name,\n Phone Number,\n Contact First Name,\n Contact Last Name,\n Contact Email Address, \n Trading Partner User Name \n are required');
            ApexPages.addMessage(myMsg);
            return false;
        } 
        
        string TPphoneNumber = newTradingPartner.tradingPartnerPhoneNumberArea+newTradingPartner.tradingPartnerPhoneNumber;
        string TPFaxNumber = newTradingPartner.tradingPartnerFaxNumberArea+newTradingPartner.tradingPartnerFaxNumber;
        string TPPhoneExt = newTradingPartner.tradingPartnerPhoneNumberExtn;
        
        //String phoneRegEx = '^[0-9]{10}*$';
        String phoneRegEx = '\\d{10}';
        String phoneExtRegEx = '^[0-9]*$';
        Pattern MyPatternPhone = Pattern.compile(phoneRegEx);
        Pattern MyPatternPhoneExt = Pattern.compile(phoneExtRegEx);
        
        Matcher MyMatcherPhone = MyPatternPhone.matcher(TPphoneNumber);
        Boolean resultPhone = MyMatcherPhone.matches();
        
        Matcher MyMatcherPhoneExt = MyPatternPhoneExt.matcher(TPPhoneExt); 
        Boolean resultPhoneExt = MyMatcherPhoneExt.matches();
        
        Matcher MyMatcherFax = MyPatternPhone.matcher(TPFaxNumber);
        Boolean resultFax = MyMatcherFax.matches();
        
        
        if(resultPhone == false  || (!string.isBlank(TPFaxNumber) && resultFax == false) ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Wrong phone number or phone number area or fax number format. Please use 10 digits');
            ApexPages.addMessage(myMsg);
            return false;
        }
        if(resultPhoneExt == false){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Wrong extension phone number format. Please use max. 5 digits.');
            ApexPages.addMessage(myMsg);
            return false;
        }
            
        string contactEmailAddress = newTradingPartner.contactEmailAddress;
        String emailRegEx = '[a-zA-Z0-9\\.\\!\\#\\$\\%\\&\\*\\/\\=\\?\\^\\_\\+\\-\\`\\{\\|\\}\\~\'._%+-]+@[a-zA-Z0-9\\-.-]+\\.[a-zA-Z]+';
        Pattern MyPatternEmail = Pattern.compile(emailRegEx);
        Matcher MyMatcherEmail = MyPatternEmail.matcher(contactEmailAddress);
        Boolean resultEmail = MyMatcherEmail.matches();
        if(!resultEmail ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Wrong email format. Proper format is : username@domainname.com');
            ApexPages.addMessage(myMsg);
            return false;
        }
        // checking username format
        string userNameString = newTradingPartner.userName;
        String userNameRegEx = '^[a-zA-Z0-9]{8,}$';//'[A-Z]|[a-z]|[0-9]';
        Pattern MyPattern = Pattern.compile(userNameRegEx);
        Matcher MyMatcher = MyPattern.matcher(userNameString);
        Boolean result = MyMatcher.matches();
        if(!result){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'User name should contain only letters and/or numbers. No special chars or spaces are available. Minimum 8 chars');
            ApexPages.addMessage(myMsg);
            return false;
        }
        // checking if username is duplicated
        String usernameSuffix = SRW_Utils.getSettingByName('UsernameSufix');
        try{
            String userNameQuery = newTradingPartner.userName + usernameSuffix;
            List<User> tempUsrList = [select Id From User where Username =: userNameQuery];
            if(!tempUsrList.isEmpty()) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'UserName: '+newTradingPartner.userName+' is not unique.');
                ApexPages.addMessage(myMsg);
                system.debug('--- tp username not unique');
                return false;
            } else if(![Select id from SRW_Trading_Partner_Profile__c where Trading_Partner_User_Name_gne__c = :newTradingPartner.userName].isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'UserName: '+newTradingPartner.userName+' is not unique.'));
                return false;
            }
        }catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Error during checking if username is duplicated. Please try other.'+e.getMessage());
                ApexPages.addMessage(myMsg);
                return false;
        }
        if(newTradingPartner.contractEffectiveDate != ''){
            try {
                Date checkerE = date.parse(newTradingPartner.contractEffectiveDate);
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Contract Effective Date: '+newTradingPartner.contractEffectiveDate+' is not valid.'));
                system.debug('exception: ' + e.getMessage());
                return false;
            }
        }
        if(newTradingPartner.contractTerminationDate != ''){
            try{
                Date checkerT = date.parse(newTradingPartner.contractTerminationDate);
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Contract Termination Date: '+newTradingPartner.contractTerminationDate+' is not valid.'));
                system.debug('exception: ' + e.getMessage());
                return false;   
            }      
        }
         //check if there are any duplicated Trading Partner Profiles
        boolean duplicated_TPP = isTradingPartnerDuplicated(newTradingPartner.tradingPartnerName);
        //boolean duplicated_TPP = false;
        boolean isTradingProfileCraetedwithSuccess = false;
        system.debug(duplicated_TPP);
        if (duplicated_TPP == true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Trading Partner Named: '+newTradingPartner.tradingPartnerName+' is duplicated. '));
            system.debug('--- tp duplicated');
            return false;
        }
        
        
        
        Savepoint sp = Database.setSavepoint();
        //getAccount for contacts for tpprof
        String accountIdForTradingPartner = SRW_Utils.getSettingByName('AccountId');//SRW_Settings__c.getAll().get('sqa').AccountId__c;
        Account[] acc = [select id, name from Account where Id = :accountIdForTradingPartner limit 1];
        Account accForContact = acc.size()==0 ? null : acc[0];
        
        //create contact
        
        Contact con = new Contact(AccountId = accForContact.Id,
        FirstName = newTradingPartner.contactFirstName,
        LastName = newTradingPartner.contactLastName,
        Email = newTradingPartner.contactEmailAddress,
        TPName__c = newTradingPartner.tradingPartnerName,
        SRW_Username__c = newTradingPartner.userName + usernameSuffix);
        try{
        insert con;
        }catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_TP_creation_problem+e.getMessage()));
            // Rollback to the previous null value
            Database.rollback(sp);
            return false;
        }
        
        //create Trading Partner Profile
       
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Name: '+newTradingPartner.tradingPartnerName));
        system.debug('tradingPartnerWrapper: '+ newTradingPartner.tradingPartnerName);
        
        SRW_Trading_Partner_Profile__c newTradingPartnerProfile = new SRW_Trading_Partner_Profile__c(
            Trading_Partner_Phone_gne__c = newTradingPartner.tradingPartnerPhoneNumberArea+newTradingPartner.tradingPartnerPhoneNumber,
            Trading_Partner_Fax_gne__c = newTradingPartner.tradingPartnerFaxNumberArea+newTradingPartner.tradingPartnerFaxNumber,
            Trading_Partner_Name_gne__c = newTradingPartner.tradingPartnerName,
            Trading_Partner_User_Name_gne__c = newTradingPartner.userName,
            TP_Phone_Extn_gne__c = string.ValueOf(newTradingPartner.tradingPartnerPhoneNumberExtn),
            Contact_gne__c = con.Id,
            Contact_First_Name_gne__c = newTradingPartner.contactFirstName,
            Contact_Last_Name_gne__c = newTradingPartner.contactLastName,
            Contact_Phone_gne__c = newTradingPartner.tradingPartnerPhoneNumberArea+newTradingPartner.tradingPartnerPhoneNumber,
            Contact_Fax_Number_gne__c = newTradingPartner.tradingPartnerFaxNumberArea+newTradingPartner.tradingPartnerFaxNumber,
            Contact_Email_Address_gne__c = newTradingPartner.contactEmailAddress,
            Contract_Effective_Date_gne__c = newTradingPartner.contractEffectiveDate != '' ? date.parse(newTradingPartner.contractEffectiveDate) : null,
            Contract_Termination_Date_gne__c = newTradingPartner.contractTerminationDate != '' ? date.parse(newTradingPartner.contractTerminationDate) : null,
            MCCO_Account_Manger_gne__c = newTradingPartner.MCCOAccountManager,
            Comment_gne__c = newTradingPartner.comments);
        try{
            if(newTradingPartnerProfile.Contract_Termination_Date_gne__c != null && newTradingPartnerProfile.Contract_Effective_Date_gne__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contract Effective Date is mandatory when Termination Date is filled in.'));
                return false;
            }

            if(newTradingPartnerProfile.Contract_Termination_Date_gne__c != null && newTradingPartnerProfile.Contract_Effective_Date_gne__c != null 
                && (newTradingPartnerProfile.Contract_Termination_Date_gne__c < newTradingPartnerProfile.Contract_Effective_Date_gne__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contract Termination Date cannot be prior to Contract Effective Date. '));
                return false;
            }

            insert newTradingPartnerProfile;
            assignProductToTradingPartner(newTradingPartnerProfile.Id);
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'newTradingPartnerProfile created. '));
            isTradingProfileCraetedwithSuccess = true;
        }catch(exception e){
            isTradingProfileCraetedwithSuccess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_TP_creation_problem +e.getMessage()));
            // Rollback to the previous null value
            Database.rollback(sp);
             return false;
        }
        system.debug(newTradingPartnerProfile);
        
        //create Security Community Object
        SRW_Security_Community_Data__c securityCommunityDataForUser = new SRW_Security_Community_Data__c();
        try{
            securityCommunityDataForUser.Trading_Partner_gne__c = newTradingPartnerProfile.Id;
            insert securityCommunityDataForUser; 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'securityCommunityDataForUser created. '));
            }catch(exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR during updating Contact : '+e.getMessage()));
                // Rollback to the previous null value
                Database.rollback(sp);
                return false;
            }
        string roleId = [select id, name from Userrole where name like :accForContact.Name+'%' and name like '%Partner Executive' limit 1][0].Id;
        System.debug('--- roleId ' + roleId);
        string profileId = [select id from Profile where name = 'GNE-GST-Partner-External'][0].Id;
        //Database.rollback(sp);
        futureCreateUser(newTradingPartner.contactEmailAddress, newTradingPartner.userName, newTradingPartner.contactFirstName, newTradingPartner.contactLastName, con.Id, roleId, profileId, newTradingPartnerProfile.Id, newTradingPartner.tradingPartnerName);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_TP_creation_success));
        return true;
    }
    
    @future
    public static void futureCreateUser(String email, String userName, String firstName, string lastName, String contactId, String roleId, String ProfileId, String newTradingPartnerProfileId, String newTradingPartnerName){
        User u = new User();
        String usernameSuffix = SRW_Utils.getSettingByName('UsernameSufix');//SRW_Settings__c.getAll().get('sqa').Username_Suffix_gne__c;
        u.UserName = userName + usernameSuffix;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.Email = email;
        u.EmailEncodingKey = 'UTF-8';
        u.CommunityNickname = userName;
        u.ProfileId = ProfileId;
        u.UserRoleId = roleId;
        u.ContactId = contactId;
        u.CommunityNickname = userName+usernameSuffix;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.TPName__c = newTradingPartnerName;
        
        try{
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.EmailHeader.triggerUserEmail = false;
            dml.EmailHeader.triggerAutoResponseEmail = false;
            dml.EmailHeader.triggerOtherEmail = false;
            Database.SaveResult sr = Database.Insert(u, dml);
            System.debug('Save Results: ' + sr);
        }catch(Exception e){
           System.debug('----- ex ' + e.getMessage());
           Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
           String htmlBody = '<div>User: ' + userName + usernameSuffix +'</div><div>Email: ' + email + '</div><div> Errod message: '+e.getMessage()+'</div>';
           String subject = 'CREATING USER FOR TRADING PARTNER EXCEPTION';
           List<String> addresses = new List<String>();
           sem.setHtmlBody(htmlBody);
           sem.setSubject(subject);
           String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
           OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
           addresses.add(owea[0].Address);
           sem.setToAddresses(addresses);
           sem.setOrgWideEmailAddressId(owea[0].id);
           Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
        }
       
    }
    
    
    
    public class ProductsWrapper{
        public Product_vod__c product {get; set;}
        public boolean isSelected {get; set;}
        
        public ProductsWrapper(Product_vod__c product, boolean isSelected){
            this.product = product;
            this.isSelected = isSelected;
        }
    }

        
    public void assignProductToTradingPartner(string tpId){
        List<SRW_Trd_Prt_Product_gne__c> productsToAssign = new List<SRW_Trd_Prt_Product_gne__c>();
        List<SRW_Trd_Prt_Product_gne__c> productsToUnassign = new List<SRW_Trd_Prt_Product_gne__c>();
        Map<id, SRW_Trd_Prt_Product_gne__c> productsMap = new Map<id, SRW_Trd_Prt_Product_gne__c>(); 
        for(SRW_Trd_Prt_Product_gne__c tpp: [SELECT id, Product_gne__c, Trading_Partner_gne__c, is_Visible_gne__c FROM SRW_Trd_Prt_Product_gne__c WHERE Trading_Partner_gne__c = :tpId]){
            productsMap.put(tpp.Product_gne__c, tpp);
        }
        
        for(ProductsWrapper pw : tradingPartnerProducts){
            if(pw.isSelected){
                if(productsMap.containsKey(pw.product.id)){
                    SRW_Trd_Prt_Product_gne__c toAssign = productsMap.get(pw.product.id);
                    toAssign.is_Visible_gne__c = true;
                    productsToAssign.add(toAssign); 
                } else {
                    productsToAssign.add(new SRW_Trd_Prt_Product_gne__c(Product_gne__c = pw.product.id, Trading_Partner_gne__c = tpId, is_Visible_gne__c = true));
                }
            } else {
                if(productsMap.containsKey(pw.product.id)){
                    SRW_Trd_Prt_Product_gne__c toUnassign = productsMap.get(pw.product.id);
                    productsToUnassign.add(toUnassign);    
                }               
            }   
        }
        upsert productsToAssign;
        upsert productsToUnassign;
        system.debug('productsToAssign: '+productsToAssign+'\n\n'+ 'productsToUnassign'+'\n\n'+productsToUnassign);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Products assigned.'));
    }
    
     public List<ProductsWrapper> fillTradingPartnerProductsList(){
        //SRW_DataMonths__c currentDataMonth = [SELECT id FROM SRW_DataMonths__c WHERE Sweep_Status_gne__c = 'Current' LIMIT 1];
        List<ProductsWrapper> tradingProducts = new List<ProductsWrapper>();
        for (Product_vod__c notAssigned : [SELECT id, Name FROM Product_vod__c WHERE Product_Type_vod__c = 'SRW' and active__c = true ORDER BY Name ASC NULLS LAST]){
            tradingProducts.add(new ProductsWrapper(notAssigned, false));
        }
        
        selectAllProducts = false;
        return tradingProducts;
    }
    // gST - product managment methods - END
   
    
    public class TradingPartnerWrapper {
        public SRW_Trading_Partner_Profile__c tradingPartner {get;set;}
        
        public String tradingPartnerName {get; set;}
        public String tradingPartnerPhoneNumberArea {get; set;}
        public String tradingPartnerPhoneNumber {get; set;}
        public String tradingPartnerPhoneNumberExtn {get; set;}
        public String tradingPartnerFaxNumberArea {get;set;}
        public String tradingPartnerFaxNumber {get;set;}
        
        public String contactFirstName {get; set;}
        public String contactLastName {get; set;}
        public String contactEmailAddress {get; set;}
        
        public String contractEffectiveDate {get;set;}
        public String contractTerminationDate {get;set;}
        
        public String userName {get;set;}
        
        public String MCCOAccountManager {get;set;}
        public String comments {get;set;}
        

        public TradingPartnerWrapper(String tradingPartnerName, String tradingPartnerPhoneNumber, String tradingPartnerPhoneNumberExtn, String tradingPartnerFaxNumber,String contactFirstName, String contactLastName, String contactEmailAddress, String contractEffectiveDate,String contractTerminationDate, String MCCOAccountManager, String comments) {
            this.tradingPartner = tradingPartner;
            this.tradingPartnerName = tradingPartnerName;
            this.tradingPartnerPhoneNumber = tradingPartnerPhoneNumber;
            this.tradingPartnerPhoneNumberExtn = tradingPartnerPhoneNumberExtn;
            this.tradingPartnerFaxNumber = tradingPartnerFaxNumber;
            
            this.contactFirstName = contactFirstName;
            this.contactLastName = contactLastName;
            this.contactEmailAddress = contactEmailAddress;
            
            this.contractEffectiveDate = contractEffectiveDate;
            this.contractTerminationDate = contractTerminationDate;
            
            this.MCCOAccountManager = MCCOAccountManager;
            this.comments = comments;
        }

        public TradingPartnerWrapper() {}
    }

    
}