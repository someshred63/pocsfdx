/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-08-27
*  Description: This is a extension controller for GNE_SFA2_Create_MedComm_Layout Page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Create_MedComm_Ext {
    
    public Account account {get; set;}
    public String profileName {get; set;}
    public List<Product_vod__c> products {get; set;}
    public List<Product_vod__c> molecules {get; set;}
    public List<Address_vod__c> addresses {get; set;}
    public List<Account> emails {get; set;}
    Set<String> productsToAddList = new Set<String>();
    Set<String> moleculesToAddList = new Set<String>();
    List<String> emailsToAddList = new List<String>();
    List<String> phonesToAddList = new List<String>();
    List<String> faxesToAddList = new List<String>();
    public Boolean canadianUserIsExist {get; set;}
    public Boolean medAffairUserIsExist {get; set;}
    public String product {get; set;}
    public String molecule {get; set;}
    public String priority {get; set;}
    public String address {get; set;}
    public String addressLongName {get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public String fax {get; set;}
    public Boolean cCRep {get; set;}
    public String followName {get; set;}
    public String sectionVisible {get; set;}
    public Boolean sectionItemVisible {get; set;}
    public Boolean sectionCopyMeReq {get; set;}
    public String preferenceLang {get; set;}
    public String disclaimerText {get; private set;}
    public String medCommQuestion {get; set;}
    public List<SelectOption> followUpMethodList {get; set;}
    private SFA2_Configuration_Object_gne__c pageConfiguration;    
    private Map<String, GNE_SFA2_Canadian_Users__c> canadianProfilesMap = GNE_SFA2_Canadian_Users__c.getAll();
    private Map<String, GNE_SFA2_MedAffair_Users__c> medAffairProfilesMap = GNE_SFA2_MedAffair_Users__c.getAll();
    public String message {get;set;}
    public Medical_Communication_gne__c newMedComm { get; set; }

    public GNE_SFA2_Create_MedComm_Ext(ApexPages.StandardController controller) {
        newMedComm = new Medical_Communication_gne__c();
    }

    public PageReference init() {
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Medical_Communication_gne__c');        
        if(GNE_SFA2_Util.isCanadaUser()){
        	disclaimerText = System.Label.GNE_SFA2_MedComm_Canada_Disclaimer_Text;
        }else{
        	disclaimerText = System.Label.GNE_SFA2_MedComm_Disclaimer_Text;
        }
        
        sectionCopyMeReq = !GNE_Referral_Utils.isUSCSUser() && !GNE_Referral_Utils.isCanadaUser();
        cCRep = sectionCopyMeReq;
        
        sectionItemVisible = true;
        
        try{
            account = [Select Id from Account where Id =: ApexPages.currentPage().getParameters().get('AcctId') limit 1];
        } catch (System.QueryException ex){
            PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
            pageref.setredirect(true);
            System.debug('pageref: '+pageref);
            pageref.getParameters().put('ex', 'Record not found or Id parameter missing!');
            return pageref;
        }
        
        profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        
        products = [Select Id, Name from Product_vod__c where Product_Type_vod__c = 'Detail' order by Name];
        for(Product_vod__c product : products){
            productsToAddList.add(product.Name);
        }
        
        molecules = [Select Id, Name from Product_vod__c where Detail_Product_Subtype_Code_gne__c ='Molecule' order by Name];
        for(Product_vod__c molecule : molecules){
            moleculesToAddList.add(molecule.Name);
        }
        
        Set<Id> hiddenAddrIds = getHiddenAddressIds();
        addresses = [Select Id, Name, Address_Line_2_vod__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Account_vod__c =: account.Id AND ID NOT IN :hiddenAddrIds];
        
        if(!addresses.isEmpty()){
            sectionVisible = 'address';
        } else {
        	sectionVisible = 'addAddress';
        }
        for(Address_vod__c address : addresses){
            if(address.Phone_vod__c != null){   
                phonesToAddList.add(address.Phone_vod__c);
            }
            if (address.Phone_2_vod__c != null){
                phonesToAddList.add(address.Phone_2_vod__c);
            }   
            if(address.Fax_vod__c != null){
                faxesToAddList.add(address.Fax_vod__c);
            }
            if (address.Fax_2_vod__c != null){
                faxesToAddList.add(address.Fax_2_vod__c);
            }   
        }
        
        emails = [Select PersonEmail, Secondary_Email_gne__c from Account where id = : account.Id limit 1];
        for(Account email : emails){
            if(email.PersonEmail != null){
                emailsToAddList.add(email.PersonEmail);
            }
            if(email.Secondary_Email_gne__c != null){   
                emailsToAddList.add(email.Secondary_Email_gne__c);
            }
        }
        
        followUpMethodList = buildFollowUpMethodList();
        if(followUpMethodList[0].getLabel() == 'Memo' || followUpMethodList[0].getLabel() == 'Verbal'){
        	sectionItemVisible = false;
        }
        
        return null;
    }
    
    private Set<Id> getHiddenAddressIds() {
        return (new GNE_SFA2_UserPreference_Ctrl()).getHiddenAddressIds(UserInfo.getUserId(), account.id);
    }
    
    public Account getAccountInfo(){
        Account accountName = [Select Name from Account where id =: account.Id limit 1];
        return accountName;
    }
    
    //checking if user has Canadian Profile
    public Boolean getUserHasCanadianProfile(){
        return canadianProfilesMap.containsKey(profileName);
    }
    //checking if user has MedAffair Profile
    public Boolean getUserHasMedAffairProfile(){
        return medAffairProfilesMap.containsKey(profileName);
    }
    
    public String getPriorityHelpText() {
        String priorityLabel;
        if(getUserHasCanadianProfile()) {
            return 'Normal: Target timeline is ≥2 business days<BR>High: Target timeline is <2 business days (if required sooner, please specify timeline in Medical Question field)';
        }

        return priorityLabel;
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
    //creating a list of molecules
    public List<SelectOption> getMoleculeList() {
        List<SelectOption> options = new List<SelectOption>();
        List<String> tempList = new List<String>();
        String defaultValue = 'N/A';        
        Boolean containsDefaultValue = moleculesToAddList.contains(defaultValue);
        
        // Set default value as first
        if (containsDefaultValue){
        	options.add(new SelectOption(defaultValue, defaultValue));
        }
        
        tempList.addAll(moleculesToAddList);
        tempList.sort();
        for(String s : tempList){
        	if (containsDefaultValue && s == defaultValue){
        		continue;
        	}
            options.add(new SelectOption(s,s));
        }
        
        return options;
    }
    //creating a list of follow-up method options
    public List<SelectOption> buildFollowUpMethodList() {               
        List<SelectOption> options = new List<SelectOption>();

            if(canadianProfilesMap.containsKey(profileName)){
                options.add(new SelectOption('Mail','Mail'));
                options.add(new SelectOption('Email','Email'));
                options.add(new SelectOption('Memo','Memo'));
                options.add(new SelectOption('Fax','Fax'));
                options.add(new SelectOption('Verbal','Verbal'));
            } else {
                options.add(new SelectOption('Normal Mail','Normal Mail'));
                options.add(new SelectOption('Overnight Express','Overnight Express'));
                options.add(new SelectOption('Email','Email'));
                options.add(new SelectOption('Phone','Phone'));
                options.add(new SelectOption('Fax','Fax'));
            }
            
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
    
    // creating a list of preference language options
    public List<SelectOption> getPreferenceLangList() {               
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult dfr = Medical_Communication_gne__c.Language_of_Preference_can_gne__c.getDescribe();
        for(Schema.Picklistentry preferenceLanguages : dfr.getPicklistValues()){
            options.add(new SelectOption(preferenceLanguages.getValue(),preferenceLanguages.getLabel()));
        }
        return options;
    }
    
    // MedComm Request save method
    public PageReference saveMedCommRequest() {
        newMedComm.Account_gne__c = account.Id;
        newMedComm.Notify_for_Education_gne__c = cCRep;
        newMedComm.Follow_up_Method_gne__c = followName;
        newMedComm.Medical_Question_gne__c = medCommQuestion;        
        
        if(medAffairProfilesMap.containsKey(profileName)){
            Product_vod__c newMolecule = [Select Id from Product_vod__c where Name =: molecule and Detail_Product_Subtype_Code_gne__c ='Molecule' limit 1];
            newMedComm.Product_gne__c = newMolecule.Id;
            newMedComm.Molecule_gne__c = newMolecule.Id;
        } else {
            Product_vod__c newProduct = [Select Id from Product_vod__c where Name =: product and Product_Type_vod__c = 'Detail' limit 1];
            newMedComm.Product_gne__c = newProduct.Id;
        }
        
        Boolean isCanada = canadianProfilesMap.containsKey(profileName);
        String primaryEmail = emails.get(0).PersonEmail;
        newMedComm.Email_gne__c = primaryEmail;
        Set<Id> hiddenAddrIds = getHiddenAddressIds();
        
        if((followName == 'Normal Mail' || followName == 'Overnight Express' || followName == 'Mail') && String.isNotEmpty(address)) {
            Boolean isIdValue = false; try { Id.valueOf(address); isIdValue = true; } catch(Exception ex) {}
            if(isIdValue) {
                List<Address_vod__c> addressToInsert = [Select Id, Name, Address_Line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Id =: address limit 1];
                fillAddressInfo(newMedComm, addressToInsert, isCanada);
            } else {
                newMedComm.Address_Line_1_gne__c = address;
            }
        } else if(followName == 'Phone' && String.isNotEmpty(phone)) {
            List<Address_vod__c> addressToInsert = [Select Id, Name, Address_Line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Account_vod__c = :account.Id and (Phone_vod__c =: phone or Phone_2_vod__c =: phone) limit 1];
            fillAddressInfo(newMedComm, addressToInsert, isCanada);
            newMedComm.Phone_gne__c = phone; 
        } else if(followName == 'Fax' && String.isNotEmpty(fax)) {
            List<Address_vod__c> addressToInsert = [Select Id, Name, Address_Line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Account_vod__c = :account.Id and (Fax_vod__c =: fax or Fax_2_vod__c =: fax) limit 1];
            fillAddressInfo(newMedComm, addressToInsert, isCanada);
	        newMedComm.Fax_gne__c = fax;
        } else if(followName == 'Memo' || followName == 'Verbal' || followName == 'Email') {
            List<Address_vod__c> addressToInsert = [Select Id, Name, Address_Line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, City_vod__c, State_vod__c, Province_can_gne__c, Zip_vod__c, Zip_4_vod__c, Postal_Code_can_gne__c, Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c where Account_vod__c = :account.Id and Id not in :hiddenAddrIds order by Primary_vod__c desc limit 1];
            fillAddressInfo(newMedComm, addressToInsert, isCanada);
            newMedComm.Email_gne__c = String.isNotBlank(email) ? email : newMedComm.Email_gne__c;
        }
        
        insert newMedComm;
        return null;
    }
    
    private void fillAddressInfo(Medical_Communication_gne__c newMedComm, List<Address_vod__c> addrs, Boolean isCanada) {
        if(!addrs.isEmpty()) {
            Address_vod__c addr = addrs[0];
            newMedComm.Address_Line_1_gne__c = addr.Name;
            newMedComm.Address_Line_2_gne__c = addr.Address_Line_2_vod__c;
            newMedComm.Address_Line_3_gne__c = addr.Address_Line_3_gne__c;
            newMedComm.Address_Line_4_gne__c = addr.Address_Line_4_gne__c;
            newMedComm.City_gne__c = addr.City_vod__c;
            newMedComm.Fax_gne__c = addr.Fax_vod__c;
            newMedComm.Phone_gne__c = addr.Phone_vod__c;
              
            if(isCanada) {
                newMedComm.Province_can_gne__c = addr.Province_can_gne__c;
                newMedComm.Postal_Code_can_gne__c = addr.Postal_Code_can_gne__c;
                newMedComm.Language_of_Preference_can_gne__c = preferenceLang;
            } else {
                newMedComm.State_gne__c = addr.State_vod__c;
                String zip = addr.Zip_vod__c;
                newMedComm.Zip_gne__c = zip!=null ? zip.substring(0, Math.min(5, zip.length())) : zip;
                newMedComm.Zip_4_gne__c = addr.Zip_4_vod__c;
            }  
        }
    }
    
    // MedComm Request create method
    public PageReference create(){
        PageReference result = null;
        if (followName == 'Email' && String.isEmpty(email)) {
            message = 'An E-mail address is required to save the Med Comm Request.';
        } else if(followName == 'Phone' && String.isEmpty(phone)) { 
        	message = 'A Phone Number is required to save the Med Comm Request.';
        } else if(followName == 'Fax' && String.isEmpty(fax)) {
    		message = 'A Fax Number is required to save the Med Comm Request.';
        } else if((followName == 'Normal Mail' || followName == 'Overnight Express' || followName == 'Mail') && String.isEmpty(address)) {
    	    message = 'An Address is required to save the Med Comm Request.';
    	}else if(String.isEmpty(medCommQuestion)){
    		message = 'A Medical Question is required to save the Med Comm Request.';
        } else {
            try{
            	saveMedCommRequest();
            	PageReference acctPage = new ApexPages.StandardController(account).view();
            	acctPage.setRedirect(true);
            	result = acctPage;
            } catch (Exception ex){
            	result = GNE_SFA2_Util.redirectToErrorPage('Unable to save a record.', Apexpages.currentPage().getUrl(), ex.getMessage());
            }
        }
        
        return result;
    }
    
    // MedComm Request cancel method
    public PageReference cancel(){
        PageReference acctPage = new ApexPages.StandardController(account).view();
        acctPage.setRedirect(true);
        return acctPage;
    }
    
    public String getActiveMenuItem() {
       String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
        result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }
}