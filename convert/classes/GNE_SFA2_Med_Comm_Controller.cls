public with sharing class GNE_SFA2_Med_Comm_Controller {
	
	public boolean sfaCanada {get;set;}
	public Medical_Communication_gne__c medCommuncation{get;set;}
	public String accountId{get;set;}
	public List<SelectOption> addressOptions = new List<SelectOption>();
	public List<SelectOption> phoneOptions = new List<SelectOption>();
	public List<SelectOption> faxOptions = new List<SelectOption>();
	public String Description{get;set;}
	public String medEmail {get;set;}
	public String medPhone {get;set;}
	public String medFax {get;set;}
	public String medAddress{get;set;}
	public String medFollowUpMethod{get;set;}
	public String medCCRep{get;set;}
	public String medProduct{get;set;}
	public String medPriority{get;set;}
	public String accountName{get;set;}
	public boolean showAddress = false;
	public String languagePreference{get;set;}
	public String medMolecule{get;set;}
	public boolean isMolecule {get;set;}
	public Map<Id,Address_vod__c> addressMap = new Map<Id,Address_vod__c>();
		
	 	 
	 	
	public  GNE_SFA2_Med_Comm_Controller(ApexPages.StandardController controller){
		
		
		if(checkIfIsCanadaUser()){
			sfaCanada=true;
		}
		else{
			sfaCanada=false;
		}
		if(checkIfIsMolecule()){
			isMolecule=true;
		}
		else{
			isMolecule=false;
		}
		Description='';
		medCommuncation=(Medical_Communication_gne__c)controller.getRecord();
		PageReference currentPageRef = System.currentPageReference();
		/*accountId = (currentPageRef.getParameters().get('retURL')!=null)?currentPageRef.getParameters().get('retURL'):null;
		//System.debug('*******' + accountId.replace('/',''));
		if(accountId!=null)
		accountId = accountId.replace('/','');*/
		
		accountId = (currentPageRef.getParameters().get('accountId')!=null)?currentPageRef.getParameters().get('accountId'):null;
		//System.debug('*******' + accountId.replace('/',''));
			/*if(accountId!=null)
		accountId = accountId.replace('/','');*/
		List<Account> accName;
	    if(accountId!=null){
	    	accName = [select Id,Name from Account where Id= : accountId];
	    }
		if(accName!=null && accName.size()>0){
			this.medCommuncation.Account_gne__c= accName[0].Id;
			this.accountName = accName[0].Name;
		}
		//default values : 
		this.medCCRep='N';
		if(!sfaCanada){
			this.medFollowUpMethod='Normal Mail';
			this.medPriority='Normal';
		}
		else{
			this.medFollowUpMethod='Mail';
		}
		
		if(isMolecule){
			this.medMolecule='N/A';
		}
	
		populateList();
		
	}
	
	public boolean getshowAddress(){
		return showAddress;
	}
	
	
	/*public PageReference changeSelection(){
		System.debug('**followup***'+medFollowUpMethod);
		if(medFollowUpMethod.equals('Normal Mail') || medFollowUpMethod.equals('Mail') || medFollowUpMethod.equals('Overnight Express') ){
			showAddress = true;
		}
		else{
			showAddress = false;
		}
		return null;
		
	}*/
	
	
	public List<SelectOption> getLanguages(){
		
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('English','English'));options.add(new SelectOption('French','French'));
		return options;
		
	}
	
	public List<SelectOption> getPhones(){
		return phoneOptions;
	}
	
	public List<SelectOption> getFaxes(){
		return faxOptions;
	}
	
	public List<SelectOption> getAddresses(){
		return addressOptions;
	}
	
	
	public List<SelectOption> getEmails(){
		List<SelectOption> emailOptions = new List<SelectOption>();
		List<Account> accs = [Select Secondary_Email_gne__c from Account where Id=:accountId];
		if(accs!=null && accs.size()>0){
			for(Account acc : accs ){
				if(acc.Secondary_Email_gne__c!=null)
				emailOptions.add(new SelectOption(acc.Secondary_Email_gne__c,acc.Secondary_Email_gne__c));
			}
		}
		
		List<Contact> cons = [select Email from Contact where AccountId=: accountId];
		
		if(cons!=null && cons.size()>0){
			for(Contact con : cons){
				if(con.Email!=null)
				emailOptions.add(new SelectOption(con.Email,con.Email));
			}
		}
		
		return emailOptions;
		
	}
	
	
	public List<SelectOption> getMolecules(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('N/A','N/A'));
		List<Product_vod__c> molecules = [Select Name,Id from Product_vod__c where Detail_Product_Subtype_Code_gne__c ='Molecule' order by Name];
		for(Product_vod__c prod : molecules ){
			options.add(new SelectOption(prod.Id,prod.Name));
		}
		
		return options;
		
   }
	
	
	
	public List<SelectOption> getProducts(){
		 List<SelectOption> options = new List<SelectOption>();
		List<Product_vod__c> products = [Select Id, Name from Product_vod__c where Product_Type_vod__c = 'Detail' order by Name];
		
		for(Product_vod__c prod : products){
			options.add(new SelectOption(prod.Id,prod.Name));
		}
		return options;
	}
	
	
	public List<SelectOption> getPriorities(){
		List<SelectOption> options = new List<SelectOption>();
		if(!sfaCanada){
			options.add(new SelectOption('Normal','Normal'));
			options.add(new SelectOption('High','High'));
		}
		else{
			options.add(new SelectOption('Same Day','Same Day'));
			options.add(new SelectOption('<24 hours','<24 hours'));
			options.add(new SelectOption('<2 days','<2 days'));
			options.add(new SelectOption('3-7 days','3-7 days'));
			options.add(new SelectOption('>7 days','>7 days'));
			
		}
		return options;
	}
	
	public boolean checkIfIsCanadaUser(){
		
		List<User> canadaUser = [select id,Profile_Name_gne__c from User where id=:userInfo.getUserId()];
		
		if(canadaUser!=null && canadaUser.size()>0){
			if(canadaUser[0].Profile_Name_gne__c.toLowerCase().contains('canada')){
				return true;
			}
		}
		return false;
	}
	
	public boolean checkIfIsMolecule(){
		List<User> moleculeUser = [select id,Profile_Name_gne__c from User where id=:userInfo.getUserId() and (Profile_Name_gne__c like '%GNE-MedAffairs-MCL%' or Profile_Name_gne__c like '%GNE-MedAffairs-MSL%' or Profile_Name_gne__c like '%GNE-MedAffairs-SP%')];
		
		if(moleculeUser!=null && moleculeUser.size()>0){
			return true;
			}
		
		return false;
		
	}
	
	public List<SelectOption> getCCReps(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('N','N'));options.add(new SelectOption('Y','Y'));
		return options;
	}
	
	
	public List<SelectOption> getFollowUpMethods(){
		List<SelectOption> options = new List<SelectOption>();
		if(!sfaCanada){
			options.add(new SelectOption('Normal Mail','Normal Mail'));
			options.add(new SelectOption('Overnight Express','Overnight Express'));
			options.add(new SelectOption('Email','Email'));
			options.add(new SelectOption('Phone','Phone'));
			options.add(new SelectOption('Fax','Fax'));
			if(isMolecule){
				options.add(new SelectOption('Verbal','Verbal'));
			}
		}
		else{
			options.add(new SelectOption('Mail','Mail'));
			options.add(new SelectOption('Email','Email'));
			options.add(new SelectOption('Memo','Memo'));
			options.add(new SelectOption('Fax','Fax'));
			options.add(new SelectOption('Verbal','Verbal'));
		}
		
		return options;
		
	}	
	
	
	public void  populateList(){

		List<Address_vod__c> addresses = [select ID, Name, Address_line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, City_vod__c, State_vod__c,Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c,Country_gen__c, Fax_vod__c, Fax_2_vod__c, Phone_vod__c, Phone_2_vod__c from Address_vod__c Where Account_vod__c =:accountId];
		for(Address_vod__c addr : addresses){
			
			addressMap.put(addr.Id,addr);
			if(!sfaCanada){
				addressOptions.add(new SelectOption(addr.Id,addr.Name+''+addr.City_vod__c+''+addr.State_vod__c+''+addr.Zip_vod__c));
			}
			else{
				addressOptions.add(new SelectOption(addr.Id,addr.Name+''+addr.City_vod__c+''+addr.Province_can_gne__c+''+addr.Postal_Code_can_gne__c));
			}
			if(addr.Phone_vod__c!=null){
				phoneOptions.add(new SelectOption(addr.Phone_vod__c,addr.Phone_vod__c));
			}
			if(addr.Phone_2_vod__c!=null){
				phoneOptions.add(new SelectOption(addr.Phone_2_vod__c,addr.Phone_2_vod__c));
			}
			
			if(addr.Fax_vod__c!=null){
				faxOptions.add(new SelectOption(addr.Fax_vod__c,addr.Fax_vod__c));
			}
			if(addr.Fax_2_vod__c!=null){
				faxOptions.add(new SelectOption(addr.Fax_2_vod__c,addr.Fax_2_vod__c));
			}
		}
		
		if(sfaCanada && accountId!=null){
			List<Account> acc = [Select Language_of_Preference_can_gne__c from Account where Id=:accountId ];
			if(acc!=null && acc.size()>0){
				if(acc[0].Language_of_Preference_can_gne__c.equals('French')){
					this.languagePreference='French';
				}
				else{
					if(acc[0].Language_of_Preference_can_gne__c.equals('English')){
					this.languagePreference='English';
				}
			}
			}
		}
	}
	
	
	public PageReference createMedComRequest(){
		
		System.debug('***cananda value' + sfaCanada);
		if(accountId==null || accountName==null){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Account Id not passed. Please try again!'));
			return null;
			
		}
		
		System.debug('********Description' + Description);
		
		if(Description==null ||  (Description!=null && Description.length()<1)){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'A Description is required to save the Med Comm Request.'));
			return null;
		}
		
		else if(medFollowUpMethod!=null){
			if(medFollowUpMethod.equals('Email') && (medEmail==null || (medEmail!=null && medEmail.length()<1))){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An E-mail address is required to save the Med Comm Request.'));
				return null;
			}
			
			else if (medFollowUpMethod.equals('Phone') && (medPhone==null || (medPhone!=null && medPhone.length()<1))){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'A Phone Number is required to save the Med Comm Request.'));
				return null;
			}
			 
			else if (medFollowUpMethod.equals('Fax') && (medFax==null || (medFax!=null && medFax.length()<1))){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'A Fax Number is required to save the Med Comm Request.'));
				return null;
			}
			
		}
		else{//medFollowUpMethod is null which should never happen . 
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please choose followup method. '));
			return null; 
			
		}
		
	   System.debug('Done with valdiations');	
		System.debug('Inside med com request '); 
		
		Medical_Communication_gne__c medicalCom = new Medical_Communication_gne__c();
		try{
		medicalCom.Account_gne__c = accountId;
		medicalCom.Follow_up_Method_gne__c=medFollowUpMethod;
		medicalCom.Medical_Question_gne__c=Description;
		
		if(medCCRep.equals('Y')){
			medicalCom.Notify_For_Education_gne__c=true;
		}
		else{
			medicalCom.Notify_For_Education_gne__c=false;
		}
		
		medicalCom.Priority_gne__c =medPriority;
		
		System.debug('*****map' + addressMap);
		
		if(medAddress!=null && addressMap!=null){
			medicalCom.Address_Line_1_gne__c = (addressMap.get(medAddress).Name!=null)?(addressMap.get(medAddress).Name):null;
			medicalCom.Address_Line_2_gne__c =(addressMap.get(medAddress).Address_line_2_vod__c!=null)?(addressMap.get(medAddress).Address_line_2_vod__c):null; 
			medicalCom.Address_Line_3_gne__c = (addressMap.get(medAddress).Address_line_3_gne__c!=null)?(addressMap.get(medAddress).Address_line_3_gne__c):null; 
			medicalCom.Address_Line_4_gne__c = (addressMap.get(medAddress).Address_line_4_gne__c!=null)?(addressMap.get(medAddress).Address_line_4_gne__c):null; 
			medicalCom.City_gne__c =(addressMap.get(medAddress).City_vod__c!=null)?(addressMap.get(medAddress).City_vod__c):null; 
			medicalCom.Country_gne__c = (addressMap.get(medAddress).Country_gen__c!=null)?(addressMap.get(medAddress).Country_gen__c):null; 
				 
		       
		if(!sfaCanada){

			medicalCom.State_gne__c = (addressMap.get(medAddress).State_vod__c!=null)?(addressMap.get(medAddress).State_vod__c):null; 
			medicalCom.Zip_gne__c = (addressMap.get(medAddress).Zip_vod__c!=null)?(addressMap.get(medAddress).Zip_vod__c.substring(0,5)):null; 
			medicalCom.Zip_4_gne__c = (addressMap.get(medAddress).Zip_4_vod__c!=null)?(addressMap.get(medAddress).Zip_4_vod__c):null; 
			 
		}
		else{
			medicalCom.Province_can_gne__c = addressMap.get(medAddress).Province_can_gne__c; 
			medicalCom.Postal_Code_can_gne__c = addressMap.get(medAddress).Postal_Code_can_gne__c; 
			medicalCom.Language_of_Preference_can_gne__c=languagePreference;
						
		}
		}
		
		
		
		medicalCom.Phone_gne__c = medPhone!=null?medPhone:null;
        medicalCom.Email_gne__c = medEmail!=null?medEmail:null;
        medicalCom.Fax_gne__c = medFax!=null?medFax:null;
        if(!isMolecule){
        	medicalCom.Product_gne__c=medProduct;
        }
		
        if(isMolecule && medMolecule!=null){
        	if(!medMolecule.equals('N/A')){
        	  medicalCom.Molecule_gne__c =medMolecule;
              medicalCom.Product_gne__c = medMolecule;
        	}
        	else{
        		List<Product_vod__c> nonMolecule = [Select p.Id from Product_vod__c p where p.name = 'Non-Product/Non-Molecule'];
        		if(nonMolecule!=null && nonMolecule.size()>0){
        			medicalCom.Molecule_gne__c =nonMolecule[0].Id;
        		    medicalCom.Product_gne__c = nonMolecule[0].Id;
        		}
        	}
        	
        	
        }
        
   
        	insert medicalCom;
		}
        catch(Exception e){
        	System.debug('Exception occured +++' + e.getMessage());
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        	return null;
        }
        
        if(accountId==null){
			return null;
		}
        
        PageReference pg = new PageReference('/'+accountId);
        pg.setRedirect(true);
        return pg;
		 
	}
	
	
	public pageReference cancel(){
		
		if(accountId==null){
			return null;
		}
		PageReference pg = new PageReference('/'+accountId);
        pg.setRedirect(true);
        return pg;
		 
	}
	
	
	
	
	
	
	
	
	
	
			
			
			
		
}