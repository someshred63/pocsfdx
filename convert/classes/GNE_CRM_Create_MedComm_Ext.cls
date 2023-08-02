public with sharing class GNE_CRM_Create_MedComm_Ext {

	public final Medical_Communication_gne__c medCommObject {get; set;} 
    private ApexPages.StandardController stdController;
    public String priority {get; set;}
    private Set<String> productsToAddList = new Set<String>();
    public String product {get; set;}
    public Boolean sectionCopyMeReq {get; set;}
    public Boolean cCRep {get; set;}
    public String followName {get; set;}
    public Boolean sectionItemVisible {get; set;}
    public List<SelectOption> followUpMethodList {get; set;}
    private List<String> emailsToAddList = new List<String>();
    private List<String> phonesToAddList = new List<String>();
    private List<String> faxesToAddList = new List<String>();
    private List<Address_vod__c> addresses {get; set;}
    private List<Account> emails {get; set;}
    public Account account {get; set;}
    public String sectionVisible {get; set;}
    public String address {get; set;}    
    public String email {get; set;}
    public String phone {get; set;}
    public String fax {get; set;}
    public String medCommQuestion {get; set;}
    public String disclaimerText {get; private set;}
    public String accountId {get; set;}
    public Boolean isNewMedCommWithoutAccount {get; set;}

    public GNE_CRM_Create_MedComm_Ext(ApexPages.StandardController stdController) {
        this.medCommObject = (Medical_Communication_gne__c)stdController.getRecord();
        this.stdController = stdController;

        try{           
            account = [Select Id, Name from Account where Id = :getLookupId() limit 1];
        } catch (System.QueryException ex){
            // invalid account id
            isNewMedCommWithoutAccount = true;
        }

        disclaimerText = System.Label.GNE_SFA2_MedComm_Disclaimer_Text;

        sectionCopyMeReq = !GNE_Referral_Utils.isUSCSUser() && !GNE_Referral_Utils.isCanadaUser();
        cCRep = sectionCopyMeReq;
        
        List<Product_vod__c> products = [Select Id, Name from Product_vod__c where Product_Type_vod__c = 'Detail' order by Name];
        for(Product_vod__c product : products){
            productsToAddList.add(product.Name);
        }
        initContactAddressInfo();

        sectionItemVisible = true;
        followUpMethodList = buildFollowUpMethodList();
        if(followUpMethodList[0].getLabel() == 'Memo' || followUpMethodList[0].getLabel() == 'Verbal'){
            sectionItemVisible = false;
        }
    }

    private void initContactAddressInfo() {
        addresses = new List<Address_vod__c>();

        if (account != null) {
            Set<Id> hiddenAddrIds = getHiddenAddressIds();
            addresses = [Select Id, Name, Address_Line_2_vod__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Account_vod__c = :account.Id AND ID NOT IN :hiddenAddrIds];
        }

        if (!addresses.isEmpty()) {
            sectionVisible = 'address';
        } else {
            sectionVisible = 'addAddress';
        }
        for (Address_vod__c address : addresses) {
            if (address.Phone_vod__c != null) {
                phonesToAddList.add(address.Phone_vod__c);
            }
            if (address.Phone_2_vod__c != null) {
                phonesToAddList.add(address.Phone_2_vod__c);
            }
            if (address.Fax_vod__c != null) {
                faxesToAddList.add(address.Fax_vod__c);
            }
            if (address.Fax_2_vod__c != null) {
                faxesToAddList.add(address.Fax_2_vod__c);
            }
        }

        if (account != null) {
            emails = [Select PersonEmail, Secondary_Email_gne__c from Account where id = :account.Id limit 1];
            for (Account email : emails) {
                if (email.PersonEmail != null) {
                    emailsToAddList.add(email.PersonEmail);
                }
                if (email.Secondary_Email_gne__c != null) {
                    emailsToAddList.add(email.Secondary_Email_gne__c);
                }
            }
        }
    }
    public void onChangeAccount() {
        account = [Select Id, Name from Account where Id =: medCommObject.Account_gne__c LIMIT 1];
        initContactAddressInfo();
    }

    //creating a list of priority options
    public List<SelectOption> getPriorityList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Normal','Normal'));
        options.add(new SelectOption('High','High'));
       
        return options;
    }
    
     //creating a list of products
    public List<SelectOption> getProductList() {
        List<SelectOption> options = new List<SelectOption>();
        List<String> tempList = new List<String>();
        tempList.addAll(productsToAddList);
        tempList.sort();
        for(String s : tempList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }  

     //creating a list of follow-up method options
    private List<SelectOption> buildFollowUpMethodList() {               
        List<SelectOption> options = new List<SelectOption>();
         
        options.add(new SelectOption('Normal Mail','Normal Mail'));
        options.add(new SelectOption('Overnight Express','Overnight Express'));
        options.add(new SelectOption('Email','Email'));
        options.add(new SelectOption('Phone','Phone'));
        options.add(new SelectOption('Fax','Fax'));
            
        return options;
    } 

    public PageReference availableType() {
        if (followName == 'Normal Mail' || followName == 'Overnight Express' || followName == 'Mail'){
            if(!addresses.isEmpty()) {
                sectionVisible = 'address';
            } else {
                sectionVisible = 'addAddress';
            } 
            sectionItemVisible = true;
        } else if (followName == 'Email'){
            if(!emailsToAddList.isEmpty()) {
                sectionVisible = 'email';
            } else {
                sectionVisible = 'addEmail';
            }
            sectionItemVisible = true;
        } else if (followName == 'Phone'){
            if(!phonesToAddList.isEmpty()) {
                sectionVisible = 'phone';
            } else {
                sectionVisible = 'addPhone';
            }
            sectionItemVisible = true;
        } else if (followName == 'Fax'){
            if(!faxesToAddList.isEmpty()) {
                sectionVisible = 'fax';
            } else {
                sectionVisible = 'addFax';
            }
            sectionItemVisible = true;
        } else if ((followName == 'Memo' || followName == 'Verbal')){
            sectionVisible = '';
            sectionItemVisible = false;
        }
        return null;
    }

     // creating a list of available addresses
    public List<SelectOption> getAddressesList() {
        List<SelectOption> options = new List<SelectOption>();
        for(Address_vod__c ad : addresses){
            String addressLongName = GNE_SFA2_Util.getAddressAsString(ad);
            options.add(new SelectOption(ad.Id,addressLongName)); 
        }
        return options;
    }
    
    // creating a list of available emails
    public List<SelectOption> getEmailsList() {
        List<SelectOption> options = new List<SelectOption>();
        for(String s : emailsToAddList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }
    
    // creating a list of available phones
    public List<SelectOption> getPhonesList() {
        List<SelectOption> options = new List<SelectOption>();
        for(String s : phonesToAddList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }
    
    // creating a list of available faxes
    public List<SelectOption> getFaxesList() {
        List<SelectOption> options = new List<SelectOption>();
        for(String s : faxesToAddList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }

    private Set<Id> getHiddenAddressIds() {
        return (new GNE_SFA2_UserPreference_Ctrl()).getHiddenAddressIds(UserInfo.getUserId(), account.id);
    }

    // MedComm Request create method
    public PageReference save(){
        PageReference result = null;
       
        String validateMessage = validateMedComm();
        if (String.isEmpty(validateMessage)) {    
            try{            	
                saveMedCommRequest();
                PageReference acctPage = new ApexPages.StandardController(account).view();
                acctPage.setRedirect(true);
                result = acctPage;
            } catch (Exception ex){
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to save a record. ' + ex.getMessage()));                
            }
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, validateMessage);
            ApexPages.addMessage(myMsg);  
        }
        
        return result;
    }

    private String validateMedComm() {
        String message = null;
        if (followName == 'Email' && String.isEmpty(email)) {
            message = 'An E-mail address is required to save the Med Comm Request.';
        } else if(followName == 'Phone' && String.isEmpty(phone)) { 
            message = 'A Phone Number is required to save the Med Comm Request.';
        } else if(followName == 'Fax' && String.isEmpty(fax)) {
            message = 'A Fax Number is required to save the Med Comm Request.';
        } else if((followName == 'Normal Mail' || followName == 'Overnight Express' || followName == 'Mail') && String.isEmpty(address)) {
            message = 'An Address is required to save the Med Comm Request.';
        } else if(String.isEmpty(medCommQuestion)){
            message = 'A Medical Question is required to save the Med Comm Request.';                      
        } else if(account == null){
            message = 'Account must be chosen.';
        }

        return message;
    }

    // MedComm Request save method
    private PageReference saveMedCommRequest() {
        Medical_Communication_gne__c newMedComm = new Medical_Communication_gne__c();
        newMedComm.Account_gne__c = account.Id;
        newMedComm.Priority_gne__c = priority;
        newMedComm.Notify_for_Education_gne__c = cCRep;
        newMedComm.Follow_up_Method_gne__c = followName;
        newMedComm.Medical_Question_gne__c = medCommQuestion;        
        
        Product_vod__c newProduct = [Select Id from Product_vod__c where Name =: product and Product_Type_vod__c = 'Detail' limit 1];
        newMedComm.Product_gne__c = newProduct.Id;
              
        String primaryEmail = emails.get(0).PersonEmail;
        newMedComm.Email_gne__c = primaryEmail;
        Set<Id> hiddenAddrIds = getHiddenAddressIds();
        
        if((followName == 'Normal Mail' || followName == 'Overnight Express' || followName == 'Mail') && String.isNotEmpty(address)) {
            Boolean isIdValue = false; try { Id.valueOf(address); isIdValue = true; } catch(Exception ex) {}
            if(isIdValue) {
                List<Address_vod__c> addressToInsert = [Select Id, Name, Address_Line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Id =: address limit 1];
                fillAddressInfo(newMedComm, addressToInsert);
            } else {
                newMedComm.Address_Line_1_gne__c = address;
            }
        } else if(followName == 'Phone' && String.isNotEmpty(phone)) {
            List<Address_vod__c> addressToInsert = [Select Id, Name, Address_Line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Account_vod__c = :account.Id and (Phone_vod__c =: phone or Phone_2_vod__c =: phone) limit 1];
            fillAddressInfo(newMedComm, addressToInsert);
            newMedComm.Phone_gne__c = phone; 
        } else if(followName == 'Fax' && String.isNotEmpty(fax)) {
            List<Address_vod__c> addressToInsert = [Select Id, Name, Address_Line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Account_vod__c = :account.Id and (Fax_vod__c =: fax or Fax_2_vod__c =: fax) limit 1];
            fillAddressInfo(newMedComm, addressToInsert);
            newMedComm.Fax_gne__c = fax;
        } else if(followName == 'Memo' || followName == 'Verbal' || followName == 'Email') {
            List<Address_vod__c> addressToInsert = [Select Id, Name, Address_Line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Account_vod__c = :account.Id and Id not in :hiddenAddrIds order by Primary_vod__c desc limit 1];
            fillAddressInfo(newMedComm, addressToInsert);
            newMedComm.Email_gne__c = String.isNotBlank(email) ? email : newMedComm.Email_gne__c;
        }
        
        insert newMedComm;
        return null;
    }
    
    private void fillAddressInfo(Medical_Communication_gne__c newMedComm, List<Address_vod__c> addrs) {
        if(!addrs.isEmpty()) {
            Address_vod__c addr = addrs[0];
            newMedComm.Address_Line_1_gne__c = addr.Name;
            newMedComm.Address_Line_2_gne__c = addr.Address_Line_2_vod__c;
            newMedComm.Address_Line_3_gne__c = addr.Address_Line_3_gne__c;
            newMedComm.Address_Line_4_gne__c = addr.Address_Line_4_gne__c;
            newMedComm.City_gne__c = addr.City_vod__c;
            newMedComm.Fax_gne__c = addr.Fax_vod__c;
            newMedComm.Phone_gne__c = addr.Phone_vod__c;
              
            newMedComm.State_gne__c = addr.State_vod__c;
            String zip = addr.Zip_vod__c;
            newMedComm.Zip_gne__c = zip!=null ? zip.substring(0, Math.min(5, zip.length())) : zip;
            newMedComm.Zip_4_gne__c = addr.Zip_4_vod__c;
              
        }
    }

    // MedComm Request cancel method
    public PageReference cancel(){
        PageReference redirectPage;
        if(account != null) {
            redirectPage = new ApexPages.StandardController(account).view();
        } else {
            redirectPage = new PageReference('/a0l');
        }
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    private Id getLookupId() {
        Id result = null;
        Map<String, String> paramsMap = ApexPages.currentPage().getParameters();
        
        //get lookup id from _lkid or objectId
        for (String param : paramsMap.keySet()) {
            if (param.endsWithIgnoreCase('_lkid')) {
                result = Id.valueOf(paramsMap.get(param));
                medCommObject.Account_gne__c = result;
                break;
            }
        }
        if (result == null) {
            //get lookup id from retUrl
            Boolean isSaveNew = false;
            String accIdFromRetUrl = null;
            String medIdFromRetUrl = null;
            for (String param : paramsMap.keySet()) {
                String paramValue = paramsMap.get(param);
                if(param == 'retURL' && String.isNotBlank(paramValue) && paramValue.startsWith('/' + Schema.SObjectType.Account.sObjectType.getDescribe().getKeyPrefix())) {
                    accIdFromRetUrl = paramValue.contains('?') ? paramValue.substringBetween('/', '?') : paramValue.substringAfter('/');
                    accIdFromRetUrl = accIdFromRetUrl instanceof Id ? accIdFromRetUrl : null;
                    result = Id.valueOf(accIdFromRetUrl);
                } else if(param == 'retURL' && String.isNotBlank(paramValue) && paramValue.startsWith('/' + Medical_Communication_gne__c.sObjectType.getDescribe().getKeyPrefix())) {
                    medIdFromRetUrl = paramValue.contains('?') ? paramValue.substringBetween('/', '?') : paramValue.substringAfter('/');
                    medIdFromRetUrl = medIdFromRetUrl instanceof Id ? medIdFromRetUrl : null;
                } else if (param == 'save_new') {
                    isSaveNew = (paramValue == '1'); 
                }
            }
            if (isSaveNew) {
                if (String.isNotBlank(accIdFromRetUrl)) {
                    result = Id.valueOf(accIdFromRetUrl);
                } else if (String.isNotBlank(medIdFromRetUrl)) {
                    List<Medical_Communication_gne__c> medList = [select Account_gne__c from Medical_Communication_gne__c where Id = :medIdFromRetUrl];
                    if (medList.size() > 0) {
                        result = medList[0].Account_gne__c;
                    }
                }
            }
        }

        return result;
    }
}