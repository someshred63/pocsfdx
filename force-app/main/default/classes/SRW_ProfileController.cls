public without sharing class SRW_ProfileController {
    public SRW_Trading_Partner_Profile__c tradingPartner {get; set;}
    public User currentUser {get; set;}
    public TradingPartnerWrapper tradingPartnerData {get; set;}
    public String tradingPartnerId {get; set;}
    public List<ProductsWrapper> tradingPartnerProducts {get; set;}
    public SRW_UserOperationUtils currentTradingPartnerMethods;
    
    public List<Product_vod__c> contractSelectedProducts {get; set;}
    
    public List<SelectOption> tradingPartnerStateOptions;
    public List<SelectOption> tradingPartnerTypeOfIdentifierOptions;
    public List<SelectOption> TPSecurityQuestionOptions;
    public boolean isFOIM {get; set;}

    public String TPoldPassword{set; get;}
    public String TPnewPassword{set; get;}
    public String TPconfirmPassword{set; get;}
    
    public String TPoldUsername{set; get;}
    public String TPconfirmUsername{set; get;}
    public String TPnewUsername{set; get;}
    
    public String TPSecurityQuestion {get; set;}
    public String TPSecurityAnswer {get; set;}
    
    public List<String> selectedProducts {get; set;}
    public boolean selectAllProducts {get;set;}
    public Boolean noAccess {get; set;}
    
    public SRW_ProfileController() {
        List<Profile> FOIMs = [SELECT Name, Id FROM Profile WHERE (Id = :UserInfo.getProfileId() AND Name = 'GNE-GST-Partner-External')];
        isFOIM = FOIMs.isEmpty();

        selectAllProducts = false;
        currentUser = [SELECT id, username, ContactId FROM User WHERE id = :UserInfo.getUserId()];
        retainTradingPartnerProfileInfomration();
        tradingPartnerId = tradingPartner.Id;
        tradingPartnerProducts = new List<ProductsWrapper>();
        List<User> temp = [SELECT id, username, ContactId FROM User WHERE ContactId = :tradingPartner.Contact_gne__c LIMIT 1];
        currentTradingPartnerMethods = temp.isEmpty() ? null : new SRW_UserOperationUtils(temp[0].id);
        if(tradingPartner == null) {
            noAccess = true;
            return;
        }
        else 
            noAccess = false;
    }

    public String identifierMatchNotFound(){
        List<SRW_Identifiers__c> identifier = [SELECT id FROM SRW_Identifiers__c WHERE Name = :tradingPartnerData.tradingPartner.Identifier_gne__c AND Identifier_Type_gne__c = :tradingPartnerData.tradingPartner.Type_of_Identifier_gne__c];
        if (identifier.isEmpty()){
            List<SRW_TP_Exception__c> exceptions = [SELECT id,Exception_Type_gne__c, Trading_Partner_gne__c FROM SRW_TP_Exception__c WHERE Trading_Partner_gne__c = :tradingPartnerData.tradingPartner.id LIMIT 1];
            if(!exceptions.isEmpty()){
                try{
                    delete exceptions;
                } catch (Exception e){
                    System.debug('Delete exception: ' + e.getMessage());
                }
            }
            SRW_TP_Exception__c incorrectIdentifier = new SRW_TP_Exception__c();
            incorrectIdentifier.Exception_Type_gne__c = 'Identifier Not Found Exception';
            incorrectIdentifier.Trading_Partner_gne__c = tradingPartnerData.tradingPartner.Id;
            insert incorrectIdentifier;
            sendExceptionEmail();
            return 'YES';
        } else {
            return 'NO';
        }
    }

    public void sendExceptionEmail(){
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
        String htmlBody = '<div>Trading Partner: ' + tradingPartner.Trading_Partner_Name_gne__c +'</div><div>Identifier: ' + tradingPartnerData.tradingPartner.Type_of_Identifier_gne__c + ' ' + tradingPartnerData.tradingPartner.Identifier_gne__c + '</div>';
        String subject = 'TRADING PARTNER IDENTIFIER DOES NOT MATCH';
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

    public Boolean isProfileValid(SRW_Trading_Partner_Profile__c tp){
        return (!String.isBlank(tp.Trading_Partner_Name_gne__c) && 
                !String.isBlank(tp.Trading_Partner_Phone_gne__c) && 
                !String.isBlank(tp.Trading_Partner_Address_1_gne__c) && 
                !String.isBlank(tp.City_gne__c) && 
                !String.isBlank(tp.Zip_Code_gne__c) && 
                !String.isBlank(tp.Identifier_gne__c) && 
                !String.isBlank(tp.Contact_First_Name_gne__c) && 
                !String.isBlank(tp.Contact_Last_Name_gne__c) && 
                !String.isBlank(tp.Contact_Phone_gne__c) && 
                !String.isBlank(tp.Contact_Email_Address_gne__c));
    }

    public Boolean isIdentifierValid(SRW_Trading_Partner_Profile__c tp){
        if('DEA'.equals(tp.Type_of_Identifier_gne__c)){
            Pattern dea = Pattern.compile('[a-zA-Z]{2}[0-9]{7}');
            Matcher deaMatcher = dea.matcher(tp.Identifier_gne__c);
            return deaMatcher.matches();
        }
        if ('HIN'.equals(tp.Type_of_Identifier_gne__c)){
            Pattern hin = Pattern.compile('[0-9]{7}[a-zA-Z]{2}');
            Matcher hinMatcher = hin.matcher(tp.Identifier_gne__c);
            return hinMatcher.matches();
        }
        if('NPI'.equals(tp.Type_of_Identifier_gne__c)){
            Pattern npi = Pattern.compile('[0-9]{10}');
            Matcher npiMatcher = npi.matcher(tp.Identifier_gne__c);
            return npiMatcher.matches();
        }
        return true;
    }

    public Boolean isPhoneValid(String phone){
        Pattern phonePattern = Pattern.compile('[0-9]{10}');
        Matcher phoneMatcher = phonePattern.matcher(phone);
        return phoneMatcher.matches();
    }
    
    public Boolean isZIPValid(String zip){
        Pattern zipPattern = Pattern.compile('[0-9]{5}');
        Matcher zipMatcher = zipPattern.matcher(zip);
        return zipMatcher.matches();
    }
    
    public PageReference saveTradingPartnerProfile(){
        SRW_Trading_Partner_Profile__c tradingPartnerToSave = new SRW_Trading_Partner_Profile__c();
        tradingPartnerData.changePhones();
        tradingPartnerToSave = tradingPartnerData.tradingPartner;
        if(tradingPartnerToSave.Contract_Termination_Date_gne__c != null && tradingPartnerToSave.Contract_Effective_Date_gne__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contract Effective Date is mandatory when Termination Date is filled in.'));
            return null;
        }

        if(tradingPartnerToSave.Contract_Termination_Date_gne__c != null && tradingPartnerToSave.Contract_Effective_Date_gne__c != null 
            && (tradingPartnerToSave.Contract_Termination_Date_gne__c < tradingPartnerToSave.Contract_Effective_Date_gne__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contract Termination Date cannot be prior to Contract Effective Date. '));
            return null;
        }

        if(!isProfileValid(tradingPartnerToSave)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill all required fields.'));
            return null;
        }
        if(!isIdentifierValid(tradingPartnerToSave)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Incorrect identifier format.'));
            return null;
        }
        if(!isPhoneValid(tradingPartnerToSave.Trading_Partner_Phone_gne__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Trading Partner Phone with Area Code must be 10 digits long.'));
                return null;
            }
        if(!isPhoneValid(tradingPartnerToSave.Contact_Phone_gne__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Phone with Area Code must be 10 digits long.'));
            return null;
        }
        if(!isZIPValid(tradingPartnerToSave.Zip_Code_gne__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid ZIP Code.'));
            return null;
        }
        if(!String.isBlank(tradingPartnerToSave.Trading_Partner_Fax_gne__c)){
            if(!isPhoneValid(tradingPartnerToSave.Trading_Partner_Fax_gne__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Trading Partner Fax with Area Code must be 10 digits long.'));
                return null;
            }
        }
        if(!String.isBlank(tradingPartnerToSave.Alt_Contact_Phone_gne__c)){
            if(!isPhoneValid(tradingPartnerToSave.Alt_Contact_Phone_gne__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Alt Contact Phone with Area Code must be 10 digits long.'));
                return null;
            }
        }
        tradingPartnerToSave.Identifier_Not_Found_gne__c = identifierMatchNotFound(); //tradingPartner.Contact_gne__c
        List<User> u = [SELECT id, Email, FirstName, LastName, TPName__c, Username FROM User WHERE ContactId = :tradingPartner.Contact_gne__c LIMIT 1];
        if(!u.isEmpty()){
            u[0].FirstName = tradingPartnerToSave.Contact_First_Name_gne__c;
            u[0].LastName = tradingPartnerToSave.Contact_Last_Name_gne__c;
            u[0].Email = tradingPartnerToSave.Contact_Email_Address_gne__c;
            u[0].TPName__c = tradingPartnerToSave.Trading_Partner_Name_gne__c;
        }
        List<Contact> c = [SELECT id, FirstName, LastName, Email, TPName__c FROM Contact WHERE id = :tradingPartner.Contact_gne__c LIMIT 1];
        if(!c.isEmpty()){
            c[0].FirstName = tradingPartnerToSave.Contact_First_Name_gne__c;
            c[0].LastName = tradingPartnerToSave.Contact_Last_Name_gne__c;
            c[0].Email = tradingPartnerToSave.Contact_Email_Address_gne__c;
            c[0].TPName__c = tradingPartnerToSave.Trading_Partner_Name_gne__c;
            c[0].SRW_Username__c = u[0].Username;
        }
        try {
            if (!u.isEmpty() && !c.isEmpty()){
                switchAdminMode(true, u[0].id);
                switchAdminMode(true, currentUser.id);
                update c;
                update u;
                switchAdminMode(false, u[0].id);
                switchAdminMode(false, currentUser.id);
            }
            update tradingPartnerToSave;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_TP_profile_changed));
        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Profile_Change_Error));
        }
        return null;
    }

    private void switchAdminMode(Boolean isAdminMode, Id userid) {
      Id currentUserId = userid;
      List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId = :currentUserId LIMIT 1];
      if (adminModeSetting.isEmpty()) {
        insert new GNE_SFA2_Admin_Mode__c(SetupOwnerId = currentUserId, GNE_SFA2_Is_Admin_Mode__c = isAdminMode);
      } else {
        adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c = isAdminMode;
        update adminModeSetting;
      }
    }
    
    public void retainTradingPartnerProfileInfomration(){
        if(!isFOIM) {
                tradingPartner = [SELECT Alt_Contact_Email_Address_gne__c, Contact_gne__c, Alt_Contact_First_Name_gne__c, Alt_Contact_Last_Name_gne__c, Alt_Contact_Phone_Extn_gne__c, Alt_Contact_Phone_gne__c,
                         Contact_Email_Address_gne__c, Contact_Fax_Number_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c, Contact_Phone_Extn_gne__c, Contact_Phone_gne__c,
                         Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, MCCO_Account_Manger_gne__c, Comment_gne__c, 
                         Trading_Partner_Name_gne__c, Trading_Partner_Phone_gne__c, TP_Phone_Extn_gne__c, Trading_Partner_Fax_Extn_gne__c, Trading_Partner_Fax_gne__c, Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c,
                         City_gne__c, State_gne__c, Zip_Code_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c                 
                         FROM SRW_Trading_Partner_Profile__c 
                         WHERE Contact_gne__c = :currentUser.ContactId LIMIT 1];
        } else {
            List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: currentUser.Id]; 
            if(!mimicData.isEmpty()) {
                    tradingPartner = [SELECT Alt_Contact_Email_Address_gne__c, Contact_gne__c, Alt_Contact_First_Name_gne__c, Alt_Contact_Last_Name_gne__c, Alt_Contact_Phone_Extn_gne__c, Alt_Contact_Phone_gne__c,
                         Contact_Email_Address_gne__c, Contact_Fax_Number_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c, Contact_Phone_Extn_gne__c, Contact_Phone_gne__c,
                         Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, MCCO_Account_Manger_gne__c, Comment_gne__c, 
                         Trading_Partner_Name_gne__c, Trading_Partner_Phone_gne__c, TP_Phone_Extn_gne__c, Trading_Partner_Fax_Extn_gne__c, Trading_Partner_Fax_gne__c, Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c,
                         City_gne__c, State_gne__c, Zip_Code_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c                 
                         FROM SRW_Trading_Partner_Profile__c 
                         WHERE Id =: mimicData.get(0).SRW_Trading_Partner_Profile_gne__c LIMIT 1];
            }             
        }
        
        System.debug('--- tradingPartner ' + tradingPartner);

        tradingPartnerData = new TradingPartnerWrapper(tradingPartner);
        
    }

    @RemoteAction
    public static String assignProductsToTradingPartner(List<String> assignmentList,String tradingPartner){
        
        List<SRW_Trd_Prt_Product_gne__c> insertPrdAssign = new List<SRW_Trd_Prt_Product_gne__c>();
        for(String tmp :assignmentList){

                SRW_Trd_Prt_Product_gne__c newAssignment = new SRW_Trd_Prt_Product_gne__c();
                    newAssignment.Product_gne__c = tmp;
                    newAssignment.Trading_Partner_gne__c = tradingPartner;
                    newAssignment.Is_Visible_gne__c = true;
                insertPrdAssign.add(newAssignment);
        }
        try {
                insert  insertPrdAssign;
            } catch (Exception e) {

            return 'Error:' + e;

            }
        return 'Success';

    }

    @RemoteAction
    public static String unassignProductsToTradingPartner(List<String> assignmentList,String tradingPartner){

        Set<Id> prodIds = new Set<Id>();
        for(String tmp :assignmentList){
                prodIds.add(tmp);
        }

        List<SRW_Trd_Prt_Product_gne__c> delProdToPartner = [Select Id,Name,Trading_Partner_gne__c,Product_gne__c from SRW_Trd_Prt_Product_gne__c where Product_gne__c IN :prodIds and Trading_Partner_gne__c = :tradingPartner];
        try {
                delete delProdToPartner;
            } catch (Exception e) {

            return 'Error' + e;
            }

        return 'Success';
    }
    
    public PageReference calculateAssignedTradingPartnerProductsList(){
        System.debug('filling assigned products');
        tradingPartnerProducts.clear();
        for (Product_vod__c existAssignedJunction : [SELECT id, Name FROM Product_vod__c WHERE Product_Type_vod__c = 'SRW' AND Active__c = true AND id IN (SELECT Product_gne__c FROM SRW_Trd_Prt_Product_gne__c WHERE Trading_Partner_gne__c = :tradingPartnerData.tradingPartner.Id AND is_Visible_gne__c = true) ORDER BY Name ASC NULLS LAST]){
                tradingPartnerProducts.add(new ProductsWrapper(existAssignedJunction, false));
            }
        system.debug('lis complete: ' + tradingPartnerProducts);
        return null;
    }

    public PageReference calculateUnassignedTradingPartnerProductsList(){
        tradingPartnerProducts.clear();
        for (Product_vod__c existNotAssignedJunction : [SELECT id, Name FROM Product_vod__c WHERE Product_Type_vod__c = 'SRW' AND Active__c = true AND id NOT IN (SELECT Product_gne__c FROM SRW_Trd_Prt_Product_gne__c WHERE Trading_Partner_gne__c = :tradingPartnerData.tradingPartner.Id AND is_Visible_gne__c = true) ORDER BY Name ASC NULLS LAST]){
                tradingPartnerProducts.add(new ProductsWrapper(existNotAssignedJunction, false));
            }
        system.debug('lis complete: ' + tradingPartnerProducts);
        return null;
    }
    
    
    public List<SelectOption> getTradingPartnerStateOptions(){
        Schema.DescribeFieldResult fieldResult = SRW_Trading_Partner_Profile__c.State_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry ple : pickListEntry) {
            options.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }
        return options;
    }
    
    public List<SelectOption> getTradingPartnerTypeOfIdentifierOptions(){
        Schema.DescribeFieldResult fieldResult = SRW_Trading_Partner_Profile__c.Type_of_Identifier_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry ple : pickListEntry) {
            options.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }
        return options;
    }
    
    public List<SelectOption> getTPSecurityQuestionOptions(){
        Schema.DescribeFieldResult fieldResult = SRW_Security_Community_Data__c.SecurityQuestion__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry ple : pickListEntry) {
            options.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }
        return options;
    }
        
    public PageReference resetCurrentTradingPartnerPassword(){
        if(!isFOIM){
           System.resetPassword(currentUser.id, true);
        }else {
            List<User> usrs = [Select id, username from User where ContactId =: tradingPartner.Contact_gne__c and isActive = true];
            if(usrs.size() == 1) {
                System.resetPassword(usrs[0].id, true);
                    SRW_Security_Community_Data__c securityQAData = [SELECT id, securityAnswer__c, securityQuestion__c FROM SRW_Security_Community_Data__c WHERE Trading_Partner_gne__r.Contact_gne__c = :tradingPartner.Contact_gne__c];
                    securityQAData.securityQuestion__c = null;
                    securityQAData.securityAnswer__c = null;
                    update securityQAData;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Could not reset password.'));
            }
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_Forgot_email_sent));
        return null;
    }
        
    public PageReference resetCurrentTradingPartnerSecurityQA(){
        return currentTradingPartnerMethods.resetCurrentTradingPartnerSecurityQA();
    }
    
    public void clearChangePasswordModal(){
        TPoldPassword = null;
        TPnewPassword = null;
        TPconfirmPassword = null;
    }
    public PageReference changeCurrentTradingPartnerPassword(){
        PageReference pr = currentTradingPartnerMethods.changeCurrentUserPassword(TPnewPassword, TPconfirmPassword, TPoldPassword);
        clearChangePasswordModal();
        return pr; 
    }
    
    public void clearChangeUsernameModal(){
        TPoldUsername = null;
        TPnewUsername = null;
        TPconfirmUsername = null;
    }
    public PageReference changeCurrentTradingPartnerUsername(){
        if(currentTradingPartnerMethods == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please recreate user. Press Stop Mimic, and on new page press Recreate Trading Partner User button'));
            return null;
        } else {
            PageReference pr = currentTradingPartnerMethods.changeCurrentUserUsername(TPnewUsername, TPconfirmUsername, TPoldUsername);
            clearChangeUsernameModal();
            return pr;
        }
    }
    
    public void clearChangeSecurityQAModal(){
        TPSecurityQuestion = null;
        TPSecurityAnswer = null;
    }
    public PageReference changeCurrentTradingPartnerSecurityQA(){
        PageReference pr =  currentTradingPartnerMethods.assignSecurityQAForCurrentUser(TPSecurityQuestion, TPSecurityAnswer, false);
        clearChangeSecurityQAModal();
        return pr;
    }

    public class ProductsWrapper{
        public Product_vod__c product {get; set;}
        public boolean isSelected {get; set;}
        
        public ProductsWrapper(Product_vod__c product, boolean isSelected){
            this.product = product;
            this.isSelected = isSelected;
        }
    }
    
    
    public class TradingPartnerWrapper {
        public SRW_Trading_Partner_Profile__c tradingPartner {get;set;}
        
        public String tradingPartnerPhoneNumber {get; set;}
        public String tradingPartnerPhoneAreaCode {get; set;}
        public String tradingPartnerFaxAreaCode {get; set;}
        public String tradingPartnerFaxNumber {get; set;}
        public String contactPhoneAreaCode {get; set;}
        public String contactPhoneNumber {get; set;}
        public String altContactPhoneAreaCode {get; set;}
        public String altContactPhoneNumber {get; set;}

        public TradingPartnerWrapper(SRW_Trading_Partner_Profile__c tradingPartner) {
            if(tradingPartner == null)
                return;
            this.tradingPartner = tradingPartner;
            if(!String.isBlank(tradingPartner.Trading_Partner_Phone_gne__c) && tradingPartner.Trading_Partner_Phone_gne__c.length() == 10){
                this.tradingPartnerPhoneAreaCode = tradingPartner.Trading_Partner_Phone_gne__c.substring(0,3);
                this.tradingPartnerPhoneNumber = tradingPartner.Trading_Partner_Phone_gne__c.substring(3);
            }else {
                this.tradingPartnerPhoneAreaCode = null;
                this.tradingPartnerPhoneNumber = null;
            }
            if(!String.isBlank(tradingPartner.Trading_Partner_Fax_gne__c) && tradingPartner.Trading_Partner_Fax_gne__c.length() == 10){
                tradingPartnerFaxAreaCode = tradingPartner.Trading_Partner_Fax_gne__c.substring(0,3);
                tradingPartnerFaxNumber = tradingPartner.Trading_Partner_Fax_gne__c.substring(3);
            } else {
                tradingPartnerFaxAreaCode = null;
                tradingPartnerFaxNumber = null;
            }
            if(!String.isBlank(tradingPartner.Contact_Phone_gne__c) && tradingPartner.Contact_Phone_gne__c.length() == 10){
                contactPhoneAreaCode = tradingPartner.Contact_Phone_gne__c.substring(0,3);
                contactPhoneNumber = tradingPartner.Contact_Phone_gne__c.substring(3);
            } else {
                contactPhoneAreaCode = null;
                contactPhoneNumber = null;
            }
            if(!String.isBlank(tradingPartner.Alt_Contact_Phone_gne__c) && tradingPartner.Alt_Contact_Phone_gne__c.length() == 10){
                altContactPhoneAreaCode = tradingPartner.Alt_Contact_Phone_gne__c.substring(0,3);
                altContactPhoneNumber = tradingPartner.Alt_Contact_Phone_gne__c.substring(3);
            } else {
                altContactPhoneAreaCode = null;
                altContactPhoneNumber = null;
            }
        }

        public void changePhones(){
            tradingPartner.Trading_Partner_Phone_gne__c = tradingPartnerPhoneAreaCode + tradingPartnerPhoneNumber;
            tradingPartner.Trading_Partner_Fax_gne__c = tradingPartnerFaxAreaCode + tradingPartnerFaxNumber;
            tradingPartner.Contact_Phone_gne__c = contactPhoneAreaCode + contactPhoneNumber;
            tradingPartner.Alt_Contact_Phone_gne__c = altContactPhoneAreaCode + altContactPhoneNumber;
        }
    }
   
}