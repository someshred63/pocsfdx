/**
Class to support account profile page
*/   
global without sharing class ProductOrderAccountProfileController {
	public static GNE_LWO_Logger log = new GNE_LWO_Logger();
	private static ProductDataController dataController = null;
	private static ProductOrderController orderController = null;
	
	private static GneProductOrderGetAccountInfo.AccountInfo accountInfo = null;
	//private static ProductOrderSFDCProxyController.AccountInfo accountInfo = null; 
	public List<Account> accounts = null;
	
	static String SHIPPED_STATUS_ID = null;    
	public String simsURL {get;set;} 
	public Boolean accountSelected {get; set;}
	public Account selectedAccount {get; set;}
	public String accountId {get; set;}
	public Integer accountCount {get; set;}
	public Integer foundAccounts {get; set;}
	public List<SelectOption> accountOptions {get; set;}
	public String searchAccountField {get; set;}
	public String searchMessage {get; set;}
	public Boolean searchOptionOn {get; set;}
	public String ccerrormessage {get;set;}
	public boolean isbillingedit=false; 
	public boolean sentemail=false;
	public boolean iscc60=false;
	public boolean iscc0=false; 
	public boolean iscc90=false;
	public boolean iscc0success=false;   
	public boolean iscc60success=false;
	public String defaultPaymentTerm {get; set;}
	public String contactEmail {get; set;}
	public String newAccountNum {get;set;}
	public String billingAddress {get; set;}
	public String Phone {get;set;}
	public String Fax {get;set;}
	public String accountName {get;set;} 
	public String billingStreet {get;set;}
	public String ccactiontype {get;set;}
	public String billingCity {get;set;}
	public String billingState {get;set;}
	public String billingZip {get;set;}
	public String eshiptonum {get;set;}
	public transient String eshiptoname {get;set;}
	public String eshiptocontact {get;set;}
	public String eshiptodelayalertemail {get;set;}
	public String eshiptopresciberName {get;set;}
	public String eshiptostateMedicalLicense {get;set;}
	public String eshiptostateMedicalExp {get;set;}
	public String eshiptoDEALicense {get;set;}
	public String eshiptoDesignee1 {get;set;}
	public String eshiptoDesignee2 {get;set;}   
	public String eshiptoaddress{get;set;}
	public String eshiptoPhone{get;set;}
	public String eshiptoFax {get;set;}
	public Boolean eshiptoisDefault {get;set;}
	public Boolean editshiptosloc {get;set;} 
	public Boolean changeinpaymentterm{get;set;}
	public  String ecreditcardtype {get;set;}
	public String ecreditcardnumber {get;set;}
	public String ecreditcardholder {get;set;}
	public String ecreditcardnname {get;set;}
	public Date  ecreditcardexpdate {get;set;}
	public  String newcardexpmonth {get;set;}
	public  String newcardexpyear {get;set;}
	public  String  ecreditcardexpmonth {get;set;}
	public  String ecreditcardexpyear {get;set;}
	public  String ecreditcardexpdd {get;set;}
	public String ecreditcardorignumber {get;set;}
	public static  boolean editccmode {get;set;}
	public static  boolean addccmode {get;set;}
	public Map<String,Product_Order_Payment_gne__c> accountCreditCardsmap = new Map<String,Product_Order_Payment_gne__c>();
	public Map<String,Product_Order_Payment_gne__c> accountCreditCardsmapOriginal = new Map<String,Product_Order_Payment_gne__c>();
	public List<ShippingInfo> satelliteAccountList = new List<ShippingInfo>();
	global Map<String,ShippingInfo>  satelliteAccountMap = new Map<String,ShippingInfo>();  
	public Map<String,String> nicknamesearch = new Map<String,String>();
	public List <String> shippingAddresses {get; set;}
	public List <User> users {get; set;}
	public boolean cccardcalled {get;set;}
	public String updatesuccessful {get;set;}
	public String accountIndicator {get;set;}
	
	public Boolean debug {get; set;}
	public String message {get; set;}
	public String debugMessage {get; set;}
	public String errorMessage {get; set;}
	public boolean isccerror {get;set;}

	private Boolean sampleEnrolled;
	public String sampleAccountId {get; set;}
	public String sampleOrderId {get; set;}     
	public String isDesigneeUser {get; set;}
	
	public static boolean issampleuser=false;
	//A list of all LWO account lists
	private List<List<Account>> allAcntForDropdown;
	private List<List<SelectOption>> allAcntOptions = null;
	private String profileName = null;    
	public List<BillingInfo> billinglist= new List<billingInfo>();
	public Map<String,BillingInfo> billinglistmap = new Map<String,BillingInfo>();
	public List<Product_Order_Payment_gne__c> accountCreditCardslist = new List<Product_Order_Payment_gne__c>(); 
	
	public List<CreditCardInfo>  accountCClist = new List<CreditCardInfo>();
	public  List<CreditCardInfo> acccreditcards {get;set;}
	public Map<String,CreditCardInfo> accountCCmap = new Map<String,CreditCardInfo>();
	public Map<String,CreditCardInfo> accountCCmapOriginal= new Map<String,CreditCardInfo>();
	public String samplePrescriber {get;set;}
	public String sampleStatemedlic {get;set;}
	public String sampleStatemedlicexp {get;set;}
	public String sampledelayEmail {get;set;}
	public String sampleAddress {get;set;}
	public String samplePhone {get;set;}
	public String sampleFax {get;set;} 
	public String sampleOrderDesigneecontact1 {get;set;}
	public String sampleOrderDesigneecontact2 {get;set;}
	public String ccMessage {get;set;}

	/* Jie add on 12/23/13 to set FPM access restriction */
    public Boolean getShownMC(){
    	if(GNE_LWO_Controller.getFPMUser()) return false;
    	else return true;
    }
	
	
	public String CurrentaccId {get;set;}  
	static {
		dataController = new    ProductDataController();
		orderController = new ProductOrderController();        
		accountInfo = new GneProductOrderGetAccountInfo.AccountInfo();
		system.debug('--------------------accountInfo'+accountInfo);
		Product_Order_Code_Lookup_gne__c statusCode = [select id from Product_Order_Code_Lookup_gne__c where Name = 'SHIPPED' limit 1];                         
		SHIPPED_STATUS_ID = statusCode.Id;                                 
	}
	
	private  String htmlBody='<style type="text/css">'
	+ 'a'
	+ '{'
	+ ' text-decoration:none;'
	+ '}'
	+ 'span.main'
	+ '{'
	+ ' font-family: Verdana;    '
	+ '    font-size:12px;'
	+ '}'
	+ 'span.footer'
	+ '{'
	+ ' font-family: Verdana;    '
	+ '    font-size:10px;'
	+ ' text-align:center;'
	+ '}'
	+ '</style>'
	+ '<span class="main">'
	+ '<img src="http://www.lucentisdirect.com/media/image/LucentisLogo.gif" />'
	+ '<h3>You have a new message from LUCENTIS Direct</h3>';    
	
	
	public ProductOrderAccountProfileController(){
		this.debugMessage += 'in constructor';

		changeinpaymentterm=false;
		editccmode=false;
		addccmode=false;
		isccerror=false;
		cccardcalled=false;
		editshiptosloc=false;
		updatesuccessful='';
		ccerrormessage='test';
		ecreditcardnname='nickname';
		System.debug('ProductOrderAccountProfileController constructor............');
		accounts = dataController.getAccounts();
		ecreditcardtype='test';
		newcardexpmonth='';
		newcardexpyear='';
		simsURL = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().SIMS_URL__c;  
		
		PageReference pageRef = System.currentPageReference();        
		
		//check if sample parameter are passed          
		sampleAccountId = pageRef.getParameters().get('sid');
		sampleOrderId = pageRef.getParameters().get('oid');   
		isDesigneeUser = pageRef.getParameters().get('du'); 
		if( sampleAccountId != null && sampleAccountId.length() >0)
		sampleEnrolled = true;
		else
		sampleEnrolled = false;
		
		System.debug('sampleAccountId===='+sampleAccountId+', sampleOrderId=====' +sampleOrderId + ', isDesigneeUser====='+isDesigneeUser +'.................');        
		
		String selectedAccountID = pageRef.getParameters().get('accountId');
		if(selectedAccountID !=null && selectedAccountID.trim().length()>0){
			this.accountId = selectedAccountID; 
		}
		this.debugMessage +='Account info controller : accountID='+ accountId+' | accountID in parameter is ' +pageRef.getParameters().get('accountId');    
		//updateAccountsList();
		this.updateAccountDropdownList();
		getAccountInfo(selectedAccount.SAP_Id_gne__c);
		getAccountUsers();
		
		debug = false;
		//debug = true;
		
	}
	
	private String constructAccountDisplay(Account account){
		return account.Name + ' (' + account.SAP_Id_gne__c+')';
	}
	
	/*
	Update accounts list using optional search
	*/
	private boolean updateAccountsList(){
		//Create or clear existing selection option
		foundAccounts = 0;
		message = '';
		boolean allAccounts = searchAccountField == null || searchAccountField=='' || searchAccountField == 'all';                
		
		if(allAccounts){
			debugMessage += '<br/> Search all account';
		}
		else{
			debugMessage += '<br/> Search by '+searchAccountField;
		}
		if(accounts==null || accounts.size()==0){
			accountSelected = false;
			selectedAccount = null;
			accountCount = 0;
		}
		else {
			accountCount = accounts.size();
			
			if(allAccounts) {
				foundAccounts = accountCount;
			}
			/*
				if(accountCount==1){
						selectedAccount = accounts[0];
						accountSelected = true;     
						accountId = selectedAccount.Id;
						getAccountInfo (selectedAccount.SAP_Id_gne__c);
						getAccountUsers();              
				}
				else {
				*/
			//accountSelected = false;
			//selectedAccount = null;
			
			
			
			String accountNumber = null;
			
			if(accountOptions==null){
				accountOptions = new List<SelectOption>();
			} else{
				accountOptions.clear();
			}                
			
			
			for (Account account : accounts){
				// Account search field was filled in
				if (!allAccounts) {
					if (account.Name.toLowerCase().contains(searchAccountField.toLowerCase())
							|| account.SAP_Id_gne__C.toLowerCase().contains(searchAccountField.toLowerCase())
							) {
						foundAccounts ++;   
						selectedAccount = account;
						accountOptions.add(new SelectOption(account.Id, constructAccountDisplay(account)));
					} 
				} else {
					if (selectedAccount == null) {
						selectedAccount = account;
						accountSelected = true;
						accountId = selectedAccount.Id;
					}
					accountOptions.add(new SelectOption(account.Id, constructAccountDisplay(account)));
				}
			}
			
			if(foundAccounts>0){
				if(foundAccounts==1){
					accountSelected = true;
					accountId = selectedAccount.Id;
					getAccountInfo (selectedAccount.SAP_Id_gne__c);
					getAccountUsers();
				}
				
			}
			// }
		}
		
		if(!allAccounts){
			if (foundAccounts== 0) {
				searchMessage = 'No account found matching <b>"' + searchAccountField + '"</b>';
				//revert back to the full list
				for (Account account : accounts){
					if (selectedAccount == null) {
						selectedAccount = account;
						accountSelected = true;
						accountId = selectedAccount.Id;
					}
					accountOptions.add(new SelectOption(account.Id, constructAccountDisplay(account)));
				}
				
			} else {
				String suffix  = (foundAccounts == 1) ? '' : 's';
				searchMessage = '<b>' + foundAccounts+ '</b> account' + suffix + ' found';
			}
		}
		else {
			searchMessage = '';
		}
		
		if (searchOptionOn == null && (accountOptions!= null && accountOptions.size() >= 10)) {
			searchOptionOn = true;
		}
		
		return true;
		
	}
	
	
	/*
	Search accounts by search account field
	*/
	public PageReference searchAccounts (){
		PageReference pageRef = System.currentPageReference();
		searchAccountField = pageRef.getParameters().get('searchAccountField');
		this.accountId=null;
		this.selectedAccount = null;
		this.accountSelected = false;
		this.updateAccountDropdownList();
		getAccountInfo (selectedAccount.SAP_Id_gne__c);
		getAccountUsers();
		//updateAccountsList();
		return null;
	}
	

	/*
	Show all accounts
	*/
	public PageReference showAllAccounts (){
		searchAccountField = '';
		searchMessage = '';
		this.accountId = null;
		this.selectedAccount = null;
		this.accountSelected = false;
		this.updateAccountDropdownList();
		getAccountInfo (selectedAccount.SAP_Id_gne__c);
		getAccountUsers();
		//updateAccountsList();
		return null;
	}
	
	
	/*
	New Account Selected
	*/
	public PageReference billToChanged(){
		
		System.debug('calling billToChanged..........');
		System.debug('accountId=========================='+accountId);
		
		errorMessage = '';
		
		//if(accountId!='-1'){
		selectedAccount = null;
		if (shippingAddresses != null && shippingAddresses.size() > 0) {
			shippingAddresses.clear();
		}
		if (users != null && users.size() > 0) {
			users.clear();
		}
		contactEmail = '';
		for (Account account : accounts){
			if(account.Id == accountId){
				selectedAccount = account;
				break;
			}
		}
		
		System.debug('selectedAccount=========================='+selectedAccount);
		if(selectedAccount!=null){
			accountSelected = true;
			getAccountInfo (selectedAccount.SAP_Id_gne__c);
			getAccountUsers();
			
			System.debug('billintAddress===================='+billingAddress);
			System.debug('shippingAddresses==============================='+shippingAddresses);
		}
		else {
			accountSelected = false;
		}
		/*
		}
		else {
		
			accountSelected = false;
			selectedAccount = null;
			
		}
		*/
		
		System.debug('selectedAccount===================='+selectedAccount);
		searchMessage = null;
		searchAccountField = null;
		
		return null;
	}
	
	/*
	Retrieve account information for the givein SAP ID
	*/
	public boolean getAccountInfo(String sapId) {
		CurrentaccId=sapId;
		System.debug('calling getAccountInfo..............................');
		List<String> creditCards = new List<String>();
		Pattern x = Pattern.compile('-');
		Matcher nonEncryptedCC;
		BillingInfo accountproinfo = new BillingInfo();
		billinglist = new List<BillingInfo>();
		Integer index=0;
		PageReference pageRef = System.currentPageReference();
		String url = pageRef.getUrl();
		try{
			if(shippingAddresses==null){
				shippingAddresses = new List<String>();
			}
			else {
				shippingAddresses.clear();
			}
			String shippingAddress = null;
			GneProductOrderGetAccountInfo.AccountInfoResponseItem[] responseItems;
			
			if(url.contains('GNE_LWO_AccountProfileSample')){
				responseItems = accountInfo.accountInfo(sapId,'S');
			}
			else      	
			if(url.contains('GNE_LWO_AccountProfile')){
				responseItems = accountInfo.accountInfo(sapId,'C');
			}   
			system.debug('---------------------------responseItemsKKKK'+responseItems);       
			system.debug('---------------------------responseItems'+responseItems.size());
			if (responseItems == null || responseItems.size() == 0) {
				// duyent - 022511 add notification
				String username = UserInfo.getUserName();
				string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderAccountProfileController - getAccountInfo() responseItems is null';
				sendNotification (MessageBody);
				errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
				System.debug('ist phase errror');
				return null;
			}

			for(GneProductOrderGetAccountInfo.AccountInfoResponseItem responseItem:responseItems){
				
				
				String responseType = responseItem.ResponseItemType;
				String status = responseItem.Status;
				
				System.debug('responseType==============='+responseType);
				System.debug('status==============='+status);
				if (status == null) {
					status = 'true';
				}
				if (status == 'syserror') {
					// duyent - 022511 add notification
					String username = UserInfo.getUserName();
					string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderAccountProfileController - getAccountInfo() status = syserror';
					sendNotification (MessageBody);

					errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
					System.debug('2nd phase errror');
					billingAddress = '';
					
					return null;
				} else if (status == 'false') {
					// duyent - 022511 add notification
					String username = UserInfo.getUserName();
					String MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderAccountProfileController - getAccountInfo() status = false';
					sendNotification (MessageBody);
					System.debug('error messaege '+ errorMessage);
					errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
					System.debug('3rd phase errror');
					billingAddress = '';
					//return null;
				} else {
					
					if(responseType =='account'){
						defaultPaymentTerm = responseItem.defaultPaymentTerm;
						accountIndicator=responseItem.accountIndicator;
						System.debug('account indicator'+responseItem.accountIndicator );
						System.debug('payment term ->'+ defaultPaymentTerm);
						System.debug('KKK222 ' + (responseItem.accountIndicator.compareTo('SAM') == 0 || responseItem.accountIndicator.compareTo('BTH') == 0));
						contactEmail = responseItem.contactEmail;
						accountName=responseItem.accountName;
						if(defaultPaymentTerm=='CC' || defaultPaymentTerm=='CC60')
						iscc60=true;
						else if(defaultPaymentTerm == 'CC90')
						iscc90 = true;
						else 
						iscc0=true;
						if(responseItem.accountIndicator.compareTo('SAM') == 0)
						{
							issampleuser=true;
						}
						//if(issampleuser || responseItem.accountIndicator.compareTo('BTH') == 0)
						{
							eshiptopresciberName=responseItem.physicianName;
							eshiptostateMedicalLicense=responseItem.stateMedicalLicenseNo;
							eshiptostateMedicalExp=responseItem.stateMedicalLicenseExp;
							eshiptoaddress=shippingAddress;
							eshiptoPhone=responseItem.phone;
							eshiptoFax=responseItem.fax;
							eshiptodelayalertemail=responseItem.DSNEmail;
							system.debug('--------------------------------sampleOrderDesignee1FirstName'+responseItem.sampleOrderDesignee1FirstName);
							system.debug('--------------------------------sampleOrderDesignee2FirstName'+responseItem.sampleOrderDesignee2FirstName);
							eshiptoDesignee1 = responseItem.sampleOrderDesignee1FirstName+' '+responseItem.sampleOrderDesignee1LastName;
							eshiptoDesignee2 = responseItem.sampleOrderDesignee2FirstName+' '+responseItem.sampleOrderDesignee2LastName;
						}
						
						
						
					} else if(responseType =='address'){
						if(responseItem.billing){
							
							
							System.debug('billing adress number ,name --->' +responseItem.addressNo+ responseItem.addressName);
							Phone=responseItem.Phone;
							Fax=responseItem.Fax;
							System.debug('phone number for billing'+ responseItem.phone);
							if(responseItem.addressLine4!=''){
								// billingAddress = responseItem.addressLine4 + '<br/>';
								
							} else {
								billingAddress = '';
							}
							billingAddress = responseItem.addressLine1;
							if(responseItem.addressLine2!=''){
								billingAddress +=  responseItem.addressLine2;
							}
							billingStreet=billingAddress;
							billingCity=responseItem.city;
							billingState=responseItem.state;
							billingZip=responseItem.zipCode;
							billingAddress +=  ', ' + responseItem.city + ', '+responseItem.state+'  '+responseItem.zipCode;
							billingAddress +=  ', ' + responseItem.country;
							
							accountproinfo.street=billingStreet;
							accountproinfo.city=billingCity;
							accountproinfo.state=billingState;
							accountproinfo.zip=billingZip;
							accountproinfo.accountAddress=billingAddress;
							accountproinfo.accountConEmail=contactEmail;
							accountproinfo.accountNum=sapId;
							accountproinfo.accountName=accountName;
							billinglist.add(accountproinfo);
							
							samplePrescriber=responseItem.physicianName;
							sampleStatemedlic=responseItem.stateMedicalLicenseNo;
							sampleStatemedlicexp=responseItem.stateMedicalLicenseExp;
							sampledelayEmail=responseItem.DSNEmail;
							sampleAddress=responseItem.addressLine1; 
							if(responseItem.addressLine2 != null && responseItem.addressLine2  != '') {
								sampleAddress += ', '+responseItem.addressLine2;
							}
							if(responseItem.city != null && responseItem.city  != '') {
								sampleAddress += ', '+ responseItem.city; 
							}
							if(responseItem.state != null && responseItem.state  != '') {
								sampleAddress+= ', '+responseItem.state;
							}
							if(responseItem.zipCode != null && responseItem.zipCode  != '') {
								sampleAddress+='  '+responseItem.zipCode;
							}
							samplePhone=responseItem.phone;
							sampleFax=responseItem.fax;
							
							
						}
						else { //for shipping addresses
							index++;
							ShippingInfo shippinglocs= new ShippingInfo();
							System.debug('shipping  adress number,name --->' +responseItem.addressNo+responseItem.addressName);
							if(responseItem.addressLine4!=''){
								// shippingAddress = responseItem.addressLine4 + ', ';
							} else {
								shippingAddress = '';
							}
							shippingAddress = responseItem.addressLine1;
							if(responseItem.addressLine2!=''){
								shippingAddress += ', '+ responseItem.addressLine2;
							}
							
							shippinglocs.street = shippingAddress;
							shippingAddress += ', '+ responseItem.city + ', '+responseItem.state+'  '+responseItem.zipCode;
							shippingAddress += ', '+ responseItem.country;
							
							shippingAddresses.add(shippingAddress);
							shippinglocs.address=shippingAddress;
							shippinglocs.addressNum=responseItem.addressNo;
							shippinglocs.addressName=responseItem.addressName;
							shippinglocs.contact_name =responseItem.careOf;
							shippinglocs.delayAlertEmail=responseItem.DSNEmail;
							shippinglocs.presciberName=responseItem.physicianName;
							shippinglocs.stateMedicalLicense=responseItem.stateMedicalLicenseNo;
							shippinglocs.stateMedicalExp=responseItem.stateMedicalLicenseExp;
							shippinglocs.DEALicense=responseItem.DEALicenseNo;
							shippinglocs.City=responseItem.city;
							shippinglocs.State=responseItem.state;
							shippinglocs.Zip=responseItem.zipCode;
							shippinglocs.Phone=responseItem.phone;
							shippinglocs.Fax=responseItem.fax;
							shippinglocs.index=index;
							if(responseItem.preferredShipToFlag!=null)
							shippinglocs.isDefault=(responseItem.preferredShipToFlag=='X')?true:false;
							else 
							shippinglocs.isDefault=false;
							satelliteAccountList.add(shippinglocs);
							satelliteAccountMap.put(shippinglocs.addressNum,shippinglocs);
							
							if(issampleuser){
								eshiptopresciberName=responseItem.physicianName;
								eshiptostateMedicalLicense=responseItem.stateMedicalLicenseNo;
								eshiptostateMedicalExp=responseItem.stateMedicalLicenseExp;
								eshiptoaddress=shippingAddress;
								eshiptoPhone=responseItem.phone;
								eshiptoFax=responseItem.fax;
								eshiptodelayalertemail=responseItem.DSNEmail;
							}
							
							
						}
					}
					
					else if (responseType == 'creditcard') {
						Product_Order_Payment_gne__c payment =new Product_Order_Payment_gne__c();
						Product_Order_Payment_gne__c payment_original =new Product_Order_Payment_gne__c();
						CreditCardInfo payment_cc = new CreditCardInfo();
						CreditCardInfo payment_original_cc = new CreditCardInfo();
						System.debug('credit card number '+ responseItem.cardNumber);
						//if(responseItem.cardNumber=='-E803-0460-0B100000000003' ||responseItem.cardNumber=='-E803-4396-3S10000000000Q'  || responseItem.cardNumber=='-E803-1216-1B100000000004'){
						String[] ccNumber = x.split(responseItem.cardNumber);
						payment.Name = ccNumber[2];
						payment_original.Name=responseItem.cardNumber;
						payment.Card_Holder_Name__c = responseItem.cardHolder;
						System.debug('card holder name'+responseItem.cardHolder);
						payment.Card_Type__c =responseItem.cardType;
						payment_original.Card_Type__c =responseItem.cardType;
						payment.Expiration_Date__c = Date.valueOf(responseItem.expirationDate);
						payment_original.Expiration_Date__c = Date.valueOf(responseItem.expirationDate);
						accountCreditCardslist.add(payment); 
						accountCreditCardsmap.put(payment.Name,payment);
						accountCreditCardsmapOriginal.put(payment.Name,payment_original);
						System.debug('credit card number &*^---> '+ responseItem.cardNumber);
						System.debug('expiration date '+payment.Expiration_Date__c );
						
						creditCards.add(responseItem.cardNumber);
						payment_cc.Name=ccNUmber[2];
						payment_cc.account_number=CurrentaccId;
						payment_cc.original_number=responseItem.cardNumber;
						payment_original_cc.Name=responseItem.cardNumber;
						payment_cc.Card_Holder_Name = responseItem.cardHolder;
						System.debug('card holder name'+responseItem.cardHolder);
						payment_original_cc.Card_Holder_Name = responseItem.cardHolder;
						payment_cc.Card_Type =responseItem.cardType;
						payment_original_cc.Card_Type =responseItem.cardType;
						payment_cc.Expiration_Date = Date.valueOf(responseItem.expirationDate);
						payment_original_cc.Expiration_Date = Date.valueOf(responseItem.expirationDate);
						accountCClist.add(payment_cc); 
						accountCCmap.put(payment_cc.Name,payment_cc);
						accountCCmapOriginal.put(payment_cc.Name,payment_original_cc);
						System.debug('credit card number &*^---> '+ responseItem.cardNumber);
						System.debug('expiration date '+payment.Expiration_Date__c );
						
						
						
						
						
						
						
						
					}
				}
				
				
				
			}
			
			System.debug('billing list size '+billinglist.size() );
			if(billinglist.size()>0){
				System.debug('atleast one billing address found ');
				billinglistmap.put(sapId,billinglist[0]);
			}
			
			
			if (creditCards == null || creditCards.size() == 0) {
				errorMessage = 'This account does not currently have a valid credit card on file.  Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 to add credit cards to your account, or to place your order by phone.';
				return false;
			}
			
			
			
			
			
			
			return true;
			
		}catch(Exception e) {
			
			errorPage();
			message = e.getMessage();
			// duyent - 022511 add notification
			String username = UserInfo.getUserName();
			string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderAccountProfileController - getAccountInfo() exception error' + message;
			sendNotification (MessageBody);

			errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
			return false;
		}
		
		
		
		
		
		
		
	}
	
	
	public PageReference errorPage(){
		
		PageReference page=new PageReference('/apex/LWO_ErrorPage');
		errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
		page.getParameters().put('ErrorMessage', errorMessage);
		page.setredirect(true);
		return page ;
		
	}
	
	public boolean getiscc0(){
		
		return iscc0;
	}
	
	
	public boolean getiscc60(){
		
		return iscc60;
	} 
	
	public boolean getiscc90(){
		
		return iscc90;
	}
	


	public List<CreditCardInfo> getcreditcardList(){
		
		acccreditcards = new List<CreditCardInfo>();
		Pattern x = Pattern.compile('%');
		
		Integer index = 0;
		for(CreditCardInfo prodpayment : accountCClist){
			index++; 
			prodpayment.index = index;
			prodpayment.exp_date=String.valueof(prodpayment.Expiration_Date.day());
			prodpayment.exp_month=String.valueof(prodpayment.Expiration_Date.month());
			prodpayment.exp_year=String.valueof(prodpayment.Expiration_Date.year());
			
			if(prodpayment.exp_date=='1')
			prodpayment.exp_date='01';
			else if(prodpayment.exp_date=='2')
			prodpayment.exp_date='02';
			else if(prodpayment.exp_date=='3')
			prodpayment.exp_date='03';
			else if(prodpayment.exp_date=='4')
			prodpayment.exp_date='04';
			else if(prodpayment.exp_date=='5')
			prodpayment.exp_date='05';
			else if(prodpayment.exp_date=='6')
			prodpayment.exp_date='06';
			else if(prodpayment.exp_date=='7')
			prodpayment.exp_date='07';
			else if(prodpayment.exp_date=='8')
			prodpayment.exp_date='08';
			else if(prodpayment.exp_date=='9')
			prodpayment.exp_date='09';
			
			if(prodpayment.exp_month=='1')
			prodpayment.exp_month='01';
			else if(prodpayment.exp_month=='2')
			prodpayment.exp_month='02';
			else if(prodpayment.exp_month=='3')
			prodpayment.exp_month='03';
			else if(prodpayment.exp_month=='4')
			prodpayment.exp_month='04';
			else if(prodpayment.exp_month=='5')
			prodpayment.exp_month='05';
			else if(prodpayment.exp_month=='6')
			prodpayment.exp_month='06';
			else if(prodpayment.exp_month=='7')
			prodpayment.exp_month='07';
			else if(prodpayment.exp_month=='8')
			prodpayment.exp_month='08';
			else if(prodpayment.exp_month=='9')
			prodpayment.exp_month='09';
			
			if(prodpayment.Expiration_Date < Date.today()){
				prodpayment.expirationflag = true;             
			} 
			
			if(prodpayment.Card_Holder_Name.contains('%')){
				String[] ccholderfullname = x.split(prodpayment.Card_Holder_Name);
				String holderName = ccholderfullname[1];
				String nickname = ccholderfullname[0];
				prodpayment.Card_Holder_Name=holderName;
				prodpayment.nick_name=nickname;
				nicknamesearch.put(prodpayment.Name,nickname);
				
			}
			acccreditcards.add(prodpayment);
			
		}
		
		
		
		return acccreditcards;
		
	}
	
	
	
	

	
	// below method returns list of ship to locations to the VF page .
	public List<ShippingInfo> getsatelliteAccounts(){
		
		System.debug('m here in shipping locs repeat ');
		System.debug('8************'+ satelliteAccountList);
		return satelliteAccountList;
		
	}
	

	//when user clicks on edit credit card 
	public PageReference editCreditCards(){
		
		System.debug('reached cc here ');
		
		//ccactiontype='U';
		PageReference pageRef = System.currentPageReference();
		String ccname = pageRef.getParameters().get('ccname');
		System.debug('ccname inside edit '+ ccname);   
		if(ccname!=null){
			calculateCCFields(ccname);
		}
		
		
		else //this is when user clicks on add new credit card link 
		{
			System.debug('reaching here add credit card ');
			ecreditcardexpdd='01';//set first day of the month 
			addccmode=true;
			ecreditcardorignumber=ecreditcardtype=ecreditcardnumber=ecreditcardholder=ecreditcardnname=ecreditcardexpyear=ecreditcardexpmonth='';
		}
		
		System.debug('cc type' + ecreditcardtype);
		return null;
	}    



	public PageReference editshippinglocations(){
		
		
		System.debug('reaching here in edit shipping locations');
		
		PageReference pageref = System.currentPageReference();
		String addressnum=pageRef.getParameters().get('dummynum');
		System.debug('address number '+ addressnum);
		eshiptoname='rakesh';
		editshiptosloc=true;
		
		
		
		
		return null;

	}
	
	
	
	public void calculateCCFields(String ccname){
		System.debug('inside cccalculate');
		editccmode=true;
		ecreditcardtype=accountCreditCardsmap.get(ccname).Card_Type__c;
		System.debug('ecreditcardtype***'+ ecreditcardtype);
		ecreditcardnumber=ccname;
		ecreditcardorignumber=accountCreditCardsmapOriginal.get(ccname).Name;
		ecreditcardholder = accountCreditCardsmap.get(ccname).Card_Holder_Name__c;
		ecreditcardnname=nicknamesearch.get(ccname);
		System.debug('ecreditcardnname' +ecreditcardnname);
		ecreditcardexpdate=accountCreditCardsmap.get(ccname).Expiration_Date__c;
		ecreditcardexpyear=String.valueof(ecreditcardexpdate.year());
		ecreditcardexpmonth=String.valueof(ecreditcardexpdate.month());
		ecreditcardexpdd=String.valueof(ecreditcardexpdate.day());
		System.debug('cc details -->'+ ecreditcardexpdate+ 'month'+ecreditcardexpmonth);
		System.debug('ecreditcardexyear'+ecreditcardexpyear);
	}
	
	
	@RemoteAction
	global static String updatecreditcard(String actiontype,String ccindex,String accname,String cctype,String ccholder,String ccname,String ccnickname,String ccexpday,String ccexpmonth,String ccexpyear){
		
		System.debug('***********reaching here updateeee*****'+cctype+'ccholder '+ ccholder+'name'+ccname+'nickiname '+ccnickname+'exp month '+ccexpmonth+'expyear '+ ccexpyear);
		//String expmonth=
		//String ccactiontype='U';  
		GeneComGnecommCreditcard.CreateUpdateCCardRequest2 request= new GeneComGnecommCreditcard.CreateUpdateCCardRequest2();
		request.accountNumber =accname;
		// if this is new cc .... request.creditCardNumber=ecreditcardnumber;
		request.creditCardNumber= ccname;
		request.creditCardTypeCode=cctype;
		request.creditCardExpirationDate=ccexpyear+'-'+ccexpmonth+'-'+ccexpday;
		request.cardHolderName=(ccnickname!='')?ccnickname+'%'+ccholder:ccholder;// this is combination of nickname and holder
		request.action=actiontype;
		
		System.debug('action type -->'+ actiontype);
		System.debug('credit card number --->'+request.creditCardNumber );
		System.debug('credit card type --->'+request.creditCardTypeCode );
		System.debug('credit card holder --->'+request.cardHolderName );
		System.debug('credit exp date  --->'+request.creditCardExpirationDate);
		try{
			GeneComGnecommCreditcard.GneCOMM_CreditCard_CreateUpdateCreditCard_SFDC_O_1_WSD_CreateUpdateCreditCard_Port service = new GeneComGnecommCreditcard.GneCOMM_CreditCard_CreateUpdateCreditCard_SFDC_O_1_WSD_CreateUpdateCreditCard_Port();
			GeneComGnecommCreditcard.CreateUpdateCCardReply2 reply = service.processInbound(request, 'off');
			System.debug('resposne status '+ reply.status );
			System.debug('response message '+ reply.message);
			
			//  ccerrormessage=reply.message;
			
			return reply.message;
			

			
		}
		catch(Exception e){
			return 'Error in updating credit card due to technical difficulties';
		}
		
		
	}   
	
	
	@RemoteAction    
	global static String updateshippinglocation(String actiontype,String slindex,String accountname,String addressnum,String shiptoname,String contact,String demial,String prescriber,String statemedlic,String statemedlicexp,String dealic,String street,String city,String state,String zip,String phone,String fax,String isdefault )
	{
		
		String l_shipToName='Ship to  Name:  &nbsp;';
		String l_shipToContact='Ship to  Contact:  &nbsp;';
		String  l_prescriber='Prescriber Name:  &nbsp;';
		String  l_state_med_lic= 'State Medical License #:  &nbsp;';
		String  l_state_med_lic_exp='State Medical License Exp.:  &nbsp;';
		String l_dea_lic_num='DEA License #:  &nbsp;';
		String l_address='Address:  &nbsp;';
		String l_phone='Phone:  &nbsp;';
		String l_fax='Fax:  &nbsp;';
		
		System.debug('inside update shipping lcoation ');
		boolean donotSendEmail=false;
		String contactEmail='';
		String nslinfo = '';
		if(actiontype == 'U'){
			nslinfo  = 'Request to update Shipping Location Information:';        
		}else if(actiontype == 'I'){
			nslinfo  = 'Request to add new Shipping Location Information:';           
		}else if(actiontype == 'D'){
			nslinfo  = 'Request to delete Shipping Location Information:'; 
		}    
		
		ShippingInfo a = new ShippingInfo();
		Map<String,ShippingInfo> satelliteAccountMap = new Map<String,ShippingInfo>();   
		String shippingAddress,soldToAccountName;
		String esbstatus='false';
		boolean readytosendmessage;
		
		//call get accoutn info again to retrieve existing values for delete and update operations . 
		
		if(actiontype!='' || actiontype!=null ){
			try{
				GneProductOrderGetAccountInfo.AccountInfoResponseItem[] responseItems = accountInfo.accountInfo(accountname,'C');
				if (responseItems == null || responseItems.size() == 0) {
					// duyent - 022511 add notification
					return 'Technical difficulties.. Please try later';
				}

				for(GneProductOrderGetAccountInfo.AccountInfoResponseItem responseItem:responseItems){
					
					
					String responseType = responseItem.ResponseItemType;
					String status = responseItem.Status;
					
					
					if (status == null) {
						status = 'true';
					}
					
					System.debug('status -->'+ status);
					if (status !='true') {
						return 'Technical difficulties.. Please try later';
					}
					if(status=='true'){    
						
						System.debug('Status value --->');                  
						
						if(responseType =='account'){
							
							contactEmail = responseItem.contactEmail;
							soldToAccountName=responseItem.accountName;
							
						}
						
						if(responseType =='address'){
							if(!responseItem.billing){
								
								//for shipping addresses
								
								ShippingInfo shippinglocs= new ShippingInfo();
								System.debug('shipping  adress number,name --->' +responseItem.addressNo+responseItem.addressName);
								if(responseItem.addressLine4!=''){
									// shippingAddress = responseItem.addressLine4 + ', ';
								} else {
									shippingAddress = '';
								}
								shippingAddress = responseItem.addressLine1;
								
								if(responseItem.addressLine2 != null && responseItem.addressLine2  != '') {
									shippingAddress += ', '+responseItem.addressLine2;
								}
								if(responseItem.city != null && responseItem.city  != '') {
									// shippingAddress += ', '+ responseItem.city; 
								}
								if(responseItem.state != null && responseItem.state  != '') {
									//shippingAddress+= ', '+responseItem.state;
								}
								if(responseItem.zipCode != null && responseItem.zipCode  != '') {
									// shippingAddress+='  '+responseItem.zipCode;
								}
								if(responseItem.country != null && responseItem.country  != '') {
									//shippingAddress+='  '+responseItem.country;
								}
								
								// shippingAddress += ', '+ responseItem.city + ', '+responseItem.state+'  '+responseItem.zipCode;
								//shippingAddress += ', '+ responseItem.country;
								shippinglocs.addressNum=responseItem.addressNo;
								shippinglocs.addressName=responseItem.addressName;
								shippinglocs.contact_name =responseItem.careOf;
								
								/* change this once business decides to include dsn email alert */
								//demial=shippinglocs.delayAlertEmail;
								shippinglocs.delayAlertEmail=responseItem.DSNEmail;
								shippinglocs.presciberName=responseItem.physicianName;
								shippinglocs.stateMedicalLicense=responseItem.stateMedicalLicenseNo;
								shippinglocs.stateMedicalExp=responseItem.stateMedicalLicenseExp;
								shippinglocs.DEALicense=responseItem.DEALicenseNo;
								shippinglocs.address=shippingAddress;
								shippinglocs.City=responseItem.city;
								shippinglocs.State=responseItem.state;
								shippinglocs.Zip=responseItem.zipCode;
								shippinglocs.Phone=responseItem.phone;
								shippinglocs.Fax=responseItem.fax;
								if(responseItem.preferredShipToFlag!=null)
								shippinglocs.isDefault=(responseItem.preferredShipToFlag=='X')?true:false;
								else 
								shippinglocs.isDefault=false;
								satelliteAccountMap.put(shippinglocs.addressNum,shippinglocs);
							}}}}    
				
				
				
				
				
				
			}catch(Exception e) {
				
				return 'Technical difficulties.. Please try later';
			}
			
			
			
			
			
			try{
				
				Gne_LWO_CommManagelocation.UpdateLocationRequest2 request = new Gne_LWO_CommManagelocation.UpdateLocationRequest2();
				request.accountNumber=accountname;
				request.preferredShipToNumber=addressnum;
				request.preferredShipToFlag=(isDefault=='true')?'X':'';
				request.DSNEmail=demial;
				System.debug('isdefault value '+ isDefault);
				if(isDefault=='true' ){
					System.debug('entering here');
					if(satelliteAccountMap.get(addressnum).addressName.trim().equals(shiptoname.trim()) && satelliteAccountMap.get(addressnum).contact_name.trim().equals(contact.trim()) && satelliteAccountMap.get(addressnum).delayAlertEmail.trim().equals(demial.trim()) && satelliteAccountMap.get(addressnum).presciberName.trim().equals(prescriber.trim()) && satelliteAccountMap.get(addressnum).stateMedicalLicense.trim().equals(statemedlic.trim()) && satelliteAccountMap.get(addressnum).stateMedicalExp.trim().equals(statemedlicexp.trim()) && satelliteAccountMap.get(addressnum).DEALicense.trim().equals(dealic.trim()) && satelliteAccountMap.get(addressnum).address.trim().equals(street.trim()) && satelliteAccountMap.get(addressnum).City.trim().equals(city.trim()) && satelliteAccountMap.get(addressnum).State.trim().equals(state.trim()) && satelliteAccountMap.get(addressnum).Zip.trim().equals(zip.trim()) && satelliteAccountMap.get(addressnum).Phone.trim().equals(phone.trim()) &&  satelliteAccountMap.get(addressnum).Fax.trim().equals(fax.trim())  ){
						System.debug('condition verified do not send email ');
						donotSendEmail=true;}
				}
				
				
				System.debug('request******'+addressnum);
				System.debug('dsn email -->'+request.DSNEmail + 'prefeered ship to ***'+request.preferredShipToFlag );
				Gne_LWO_CommManagelocation.GneCOMM_ManageLocation_ManageLocation_SFDC_O_1_WSD_UpdateLocation_Port submitrequest= new Gne_LWO_CommManagelocation.GneCOMM_ManageLocation_ManageLocation_SFDC_O_1_WSD_UpdateLocation_Port();
				Gne_LWO_CommManagelocation.UpdateLocationReply2 reply=submitrequest.processInbound(request, 'off');
				System.debug('ship to locs resposne status '+ reply.status );
				System.debug('ship to locs response message '+ reply.message);
				esbstatus=reply.status;
			}
			
			catch(Exception e){ 

				return 'syserror';
			}
			
			readytosendmessage=true;
			/*if(esbstatus=='true')
			readytosendmessage=true;
			else
			readytosendmessage=false;*/
			
		}
		//send email to custops iff status is true 
		String reqdate = System.Now().format('MM-dd-yy');
		String reqtime = System.Now().format('HH:mm a', 'PST');  

		
		if(actiontype!='U')
		readytosendmessage=true;
		
		
		if(!donotSendEmail){
			if(readytosendmessage){
				
				
				SYstem.debug('before submitting email ');
				String custOps = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().CUSTOPS_EMAIL__c;                
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.setToAddresses( new String[] {custOps } );   
				message.setSubject( 'Update Ship to Locations received');
				String emailBody='';
				if(actiontype=='U')
				{
					
					if(satelliteAccountMap.get(addressnum).addressName.trim().equals(shiptoname.trim()))
					l_shipToName ='Ship to  Name:  &nbsp;';
					else
					l_shipToName ='<font  color="red"><b>Ship to  Name:  &nbsp;</b></font>';
					
					if(satelliteAccountMap.get(addressnum).contact_name.trim().equals(contact.trim())) 
					l_shipToContact = 'Ship to  Contact:  &nbsp;';
					else 
					l_shipToContact = '<font  color="red"><b>Ship to  Contact:  &nbsp;</b></font>'; 
					
					l_prescriber=(satelliteAccountMap.get(addressnum).presciberName.trim().equals(prescriber.trim()))?'Prescriber Name:  &nbsp;':'<font  color="red"><b>Prescriber Name:  &nbsp;</b></font>';
					l_state_med_lic =satelliteAccountMap.get(addressnum).stateMedicalLicense.trim().equals(statemedlic.trim())? 'State Medical License #:  &nbsp;':'<font  color="red"><b>State Medical License #:  &nbsp;</b></font>';
					l_state_med_lic_exp=satelliteAccountMap.get(addressnum).stateMedicalExp.trim().equals(statemedlicexp.trim())?'State Medical License Exp.:  &nbsp;':'<font  color="red"><b>State Medical License #:  &nbsp;</b></font>';
					l_dea_lic_num=satelliteAccountMap.get(addressnum).DEALicense.trim().equals(dealic.trim())?'DEA License #:  &nbsp;':'<font  color="red"><b>DEA License #:  &nbsp;</b></font>';
					if(satelliteAccountMap.get(addressnum).address.trim().equals(street.trim()) && satelliteAccountMap.get(addressnum).City.trim().equals(city.trim()) && satelliteAccountMap.get(addressnum).State.trim().equals(state.trim()) && satelliteAccountMap.get(addressnum).Zip.trim().equals(zip.trim()))
					l_address='Address:  &nbsp;';
					else 
					l_address='<font  color="red"><b>Address:  &nbsp;</b></font>';
					l_phone= satelliteAccountMap.get(addressnum).Phone.trim().equals(phone.trim())?'Phone:  &nbsp;':'<font  color="red"><b>Phone:  &nbsp;</b></font>';
					l_fax= satelliteAccountMap.get(addressnum).Fax.trim().equals(fax.trim())? 'Fax:  &nbsp;': '<font  color="red"><b>Fax:  &nbsp;</b></font>';
					
					emailBody=  emailbody+'<b> Existing values : </b>'+'<br/><br/>'+
					
					'Sold to Account Number:  &nbsp;' + accountname+'<br/>'+
					'Sold to Account Name : &nbsp;' + soldToAccountName+'<br/>'+
					'Ship to Account:  &nbsp;' +addressnum + '<br/>'+
					l_shipToName+satelliteAccountMap.get(addressnum).addressName+ '<br/>'+
					l_shipToContact + satelliteAccountMap.get(addressnum).contact_name + '<br/>'+             
					'Delay Alert Email:  &nbsp;' + satelliteAccountMap.get(addressnum).delayAlertEmail + '<br/>'+
					l_prescriber + satelliteAccountMap.get(addressnum).presciberName + '<br/>'+
					l_state_med_lic + satelliteAccountMap.get(addressnum).stateMedicalLicense + '<br/>'+
					l_state_med_lic_exp + satelliteAccountMap.get(addressnum).stateMedicalExp + '<br/>'+
					l_dea_lic_num + satelliteAccountMap.get(addressnum).DEALicense + '<br/>'+
					l_address + satelliteAccountMap.get(addressnum).address + ',' + satelliteAccountMap.get(addressnum).City + ',' + satelliteAccountMap.get(addressnum).State + ',' + satelliteAccountMap.get(addressnum).Zip  +'<br/>'+
					l_phone + satelliteAccountMap.get(addressnum).Phone + '<br/>'+
					l_fax+ satelliteAccountMap.get(addressnum).Fax + '<br/>';
					
				} 
				
				emailBody=emailBody+'<br/><b>'+ nslinfo +'</b><br/><br/>'+
				'Sold to Account Number:  &nbsp;' + accountname+'<br/>'+
				'Ship to Account:  &nbsp;' +addressnum + '<br/>'+
				l_shipToName+ shiptoname+'<br/>'+
				l_shipToContact + contact +'<br/>'+
				'Delay Alert Email:  &nbsp;' + demial +'<br/>'+
				l_prescriber + prescriber +'<br/>'+ 
				l_state_med_lic + statemedlic +'<br/>'+
				l_state_med_lic_exp  + statemedlicexp +'<br/>'+
				l_dea_lic_num  + dealic +'<br/>'+
				l_address + street+ ',' + city + ',' + state +','+zip+ '<br/>'+
				l_phone + phone + '<br/>'+             
				l_fax + fax + '<br/>'+'<br/>'+'<br/>'+
				'--<i> <b>Requester Details :</i>--</b><br/>'+
				'Requester Name:  &nbsp;' + UserInfo.getFirstName()+' '+Userinfo.getLastName()+'<br/>'+ 
				'Requester Email: &nbsp;'+ contactEmail+'<br/>'+
				'Request Date:  &nbsp;' + reqdate + '<br/>'+ 
				'Request Time:  &nbsp;' +  reqtime;
				
				
				
				message.setHtmlBody(emailBody);
				// Send our message.
				Messaging.sendEmail( new Messaging.Email[] { message } );   
				SYstem.debug('email sent  '); 
				//sentemail=true;
				
			}
		}
		
		return 'successful';
	}

	
	/*
	public String submitccrequest(String actiontype){
		//editccmode=false;
		GeneComGnecommCreditcard.CreateUpdateCCardRequest2 request= new GeneComGnecommCreditcard.CreateUpdateCCardRequest2();
		request.accountNumber =CurrentaccId;
	// if this is new cc .... request.creditCardNumber=ecreditcardnumber;
		request.creditCardNumber= ecreditcardorignumber;
		request.creditCardTypeCode=ecreditcardtype;
		request.creditCardExpirationDate=ecreditcardexpyear+'-'+ecreditcardexpmonth+'-'+ecreditcardexpdd;
		request.cardHolderName=(ecreditcardnname!='')?ecreditcardnname+'%'+ecreditcardholder:ecreditcardholder;// this is combination of nickname and holder
		request.action=actiontype;
		SYstem.debug('credit card number --->'+request.creditCardNumber );
		SYstem.debug('credit card type --->'+request.creditCardTypeCode );
		SYstem.debug('credit card holder --->'+request.cardHolderName );
		SYstem.debug('credit exp date  --->'+request.creditCardExpirationDate);
		try{
		GeneComGnecommCreditcard.GneCOMM_CreditCard_CreateUpdateCreditCard_SFDC_O_1_WSD_CreateUpdateCreditCard_Port service = new GeneComGnecommCreditcard.GneCOMM_CreditCard_CreateUpdateCreditCard_SFDC_O_1_WSD_CreateUpdateCreditCard_Port();
		GeneComGnecommCreditcard.CreateUpdateCCardReply2 reply = service.processInbound(request);
		System.debug('resposne status '+ reply.status );
		System.debug('response message '+ reply.message);
		ccerrormessage=reply.message;
		return reply.status;
		}
		catch(Exception e){
		return 'syserror';
	}
	
	}
	
	
	
	
		public PageReference addCreditCard(){
		//addcmode=true;
	
		String status=submitccrequest('I');
		if(status=='true'){
		updatesuccessful='validcard';   
		return null;
		}
		else if(status=='false'){
			updatesuccessful='invalidcard';
			return null;
		}
		else 
		{
		updatesuccessful='syserror';  
		PageReference page=new PageReference('/apex/LWO_ErrorPage');
		errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
		page.getParameters().put('ErrorMessage', errorMessage);
		page.setredirect(true);
		return page ;
		}
		
		return null;    
	}
	
	
	public PageReference deleteCreditCard(){
		System.debug('delete method called ');
		PageReference pageRef = System.currentPageReference();
		String ccname = pageRef.getParameters().get('ccnamed'); 
		calculateCCFields(ccname);
		String status=submitccrequest('D');
		if(status=='true'){
		updatesuccessful='validcard';   
		return null;
		}
		else if(status=='false'){
			updatesuccessful='invalidcard';
			return null;
		}
		else 
		{
		updatesuccessful='syserror';  
		PageReference page=new PageReference('/apex/LWO_ErrorPage');
		errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
		page.getParameters().put('ErrorMessage', errorMessage);
		page.setredirect(true);
		return page ;
		}
		return null;
		
	}
	
	
	*/
	


	//payment term

	public PageReference updatepaymentterm()
	{
		changeinpaymentterm=true;
		System.debug('------------------------------------------------------reaching here payment ter'+changeinpaymentterm);
		PageReference pageRef = System.currentPageReference();
		//String paymentterm = (pageRef.getParameters().get('paymentterm60')!=null)?pageRef.getParameters().get('paymentterm60'):pageRef.getParameters().get('paymentterm00');
		String paymentterm=pageRef.getParameters().get('paymentterm');
		System.debug(' default payment term'+ paymentterm);
		// iscc60success=true;
		
		GnecommPaymentteras.PaymentTermsRequest2 request = new GnecommPaymentteras.PaymentTermsRequest2();
		request.accountNumber= CurrentaccId;
		request.orderNumber='';
		request.paymentTerm=paymentterm;
		//         GnecommPaymentteras.PaymentTermsReply2 reply= submitpayment.processInbound(request,'test');
		try{
			GnecommPaymentteras.GneCOMM_PaymentTerms_PaymentTerms_SFDC_O_1_WSD_UpdatePaymentTerms_Port submitrequest = new GnecommPaymentteras.GneCOMM_PaymentTerms_PaymentTerms_SFDC_O_1_WSD_UpdatePaymentTerms_Port();
			GnecommPaymentteras.PaymentTermsReply2 reply=submitrequest.processInbound(request,'off');
			System.debug('resposne status '+ reply.status );
			System.debug('response message '+ reply.message);
		}

		catch(Exception e){ 
			system.debug('--------------------------------------------------------------------------'+e);
			PageReference page=new PageReference('/apex/LWO_ErrorPage');
			errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
			page.getParameters().put('ErrorMessage', errorMessage);
			page.setredirect(true);
			return page ;
		}
		return null;
	}


	


	public boolean getiscc0success(){
		return iscc0success;
	}


	public boolean getiscc60success(){
		return iscc60success;
	}
	
	public boolean geteditshiptosloc(){
		return editshiptosloc;
	}
	


	//send update requst to customer ops ... 

	public PageReference updateAccountEmail(){
		String b_AccountName = 'Account Name:';
		String b_AccountNumber='Account Number:';
		String b_ReqEmail ='Requester Email:';
		String b_Accountaddr='Account Address:';
		String custOps = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().CUSTOPS_EMAIL__c; 
		System.debug('inside account email update  ');
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setToAddresses( new String[] { custOps } ); 
		message.setSubject( 'Update Account recieved');
		System.debug('size of map -->'+ billinglistmap);
		System.debug('value of id -->'+ CurrentaccId);
		
		String reqdate = System.Now().format('MM-dd-yy');
		String reqtime = System.Now().format('HH:mm a', 'PST');  
		if(!billinglistmap.get(CurrentaccId).accountName.trim().equals(accountName.trim()))
		b_AccountName = '<font  color="red"><b>Account Name:</b></font>';
		if(billinglistmap.get(CurrentaccId).accountConEmail!=null){
			if(!billinglistmap.get(CurrentaccId).accountConEmail.trim().equals(contactEmail.trim()))
			b_ReqEmail = '<font  color="red"><b>Requester Email:</b></font>';
		}
		if(billinglistmap.get(CurrentaccId).street.trim().equals(billingStreet.trim()) && billinglistmap.get(CurrentaccId).city.trim().equals(billingCity.trim()) && billinglistmap.get(CurrentaccId).state.trim().equals(billingState.trim()) && billinglistmap.get(CurrentaccId).zip.trim().equals(billingZip.trim()))
		{ System.debug('no changes made for sodl to account');}
		else
		b_Accountaddr='<font  color="red"><b>Account Address:</b></font>';      
		String emailBody= '<br/>'+ '<b>Existing values :</b>'+'<br/><br/>'+
		b_AccountName + billinglistmap.get(CurrentaccId).accountName + '<br/>'+
		b_AccountNumber + billinglistmap.get(CurrentaccId).accountNum + '<br/>'+
		b_ReqEmail + billinglistmap.get(CurrentaccId).accountConEmail +'<br/>'+
		b_Accountaddr + billinglistmap.get(CurrentaccId).accountAddress+'<br/><br/>';

		emailBody=emailBody+'<b>Requested Update Information:</b> '+'<br/><br/>'+ 

		b_AccountName+ accountName+'<br/>'+  
		b_AccountNumber+ billinglistmap.get(CurrentaccId).accountNum  + '<br/>'+
		b_ReqEmail + contactEmail+'<br/>'+
		b_Accountaddr+ billingStreet+','+billingCity+','+ billingState +','+ billingZip +'<br/>'+
		'--<i> <b>Requester Details :</i>--</b><br/>'+
		'Requestor Name:' + UserInfo.getFirstName()+' '+Userinfo.getLastName()+'<br/>'+ 
		'Request Date:' + reqdate + '<br/>'+ 
		'Request Time:' +  reqtime;
		
		message.setHtmlBody(emailBody);
		// Send our message.
		Messaging.sendEmail( new Messaging.Email[] { message } );   
		sentemail=true;

		return null;
		
	}        
	
	
	
	public PageReference updateShiptosEmail(){
		sentemail=true;
		//first update dsnemail and default ship to then call email update....
		System.debug('new value for contact '+eshiptocontact );
		String custOps = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().CUSTOPS_EMAIL__c;         
		PageReference pageRef = System.currentPageReference();
		String changedefault = pageRef.getParameters().get('changetodefault'); 
		String status;
		if(changedefault!=null)
		eshiptoisDefault=true;
		
		status=submitShiptoUpdate();
		if(status=='true')
		{
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.setToAddresses( new String[] { custOps } ); 
			message.setSubject( 'Update Ship to Locations recieved');
			String emailBody=htmlBody+ '<br/>'+ 'Existing values : '+'<br/>'+
			'Ship to  Name: '+satelliteAccountMap.get(eshiptonum).addressName+ '<br/>'+
			'Ship to  Contact  ' + satelliteAccountMap.get(eshiptonum).contact_name + '<br/>';

			emailBody=emailBody+'<br/>'+ 'Requested Update Information: '+'<br/>'+

			'Ship to  Name:'+ eshiptoname+'<br/>'+
			'Ship to  Contact : '+ eshiptocontact+'<br/>';
			
			
			message.setHtmlBody(emailBody);
			// Send our message.
			Messaging.sendEmail( new Messaging.Email[] { message } );   
			sentemail=true;
			
			return null;
			
		}

		else {
			PageReference page=new PageReference('/apex/LWO_ErrorPage');
			errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
			page.getParameters().put('ErrorMessage', errorMessage);
			page.setredirect(true);
			return page ;
			
		}
		
		
	}
	
	
	
	public String submitShiptoUpdate(){

		try{
			Gne_LWO_CommManagelocation.UpdateLocationRequest2 request = new Gne_LWO_CommManagelocation.UpdateLocationRequest2();
			request.accountNumber=CurrentaccId;
			request.preferredShipToNumber=eshiptonum;
			request.preferredShipToFlag=eshiptoisDefault?'X':'';
			request.DSNEmail=eshiptodelayalertemail;
			
			System.debug('request******');
			System.debug('dsn email -->'+request.DSNEmail + 'prefeered ship to ***'+request.preferredShipToFlag );
			Gne_LWO_CommManagelocation.GneCOMM_ManageLocation_ManageLocation_SFDC_O_1_WSD_UpdateLocation_Port submitrequest= new Gne_LWO_CommManagelocation.GneCOMM_ManageLocation_ManageLocation_SFDC_O_1_WSD_UpdateLocation_Port();
			Gne_LWO_CommManagelocation.UpdateLocationReply2 reply=submitrequest.processInbound(request, 'off');
			System.debug('ship to locs resposne status '+ reply.status );
			System.debug('ship to locs response message '+ reply.message);
			String status=reply.status;
			return status;
		}

		catch(Exception e){ 

			return 'syserror';
		}
	}
	
	
	// duyent 022511 - send notification
	private void SendNotification(string MessageBody)
	{ 
		String SUPPORT_EMAIL = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().SUPPORT_EMAIL__c;         
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setToAddresses( new String[] {SUPPORT_EMAIL} ); 
		message.setSubject( 'SFDC - LWO error');
		message.setPlainTextBody( MessageBody );
		// Send our message.
		Messaging.sendEmail( new Messaging.Email[] { message } );

	}
	
	
	
	
	public PageReference editbilling(){
		
		isbillingedit=true;
		return null;
	}
	
	public boolean getisbillingedit(){
		
		return isbillingedit;
	}
	
	public boolean getsentemail(){
		
		return sentemail;
	}
	
	public boolean geteditccmode(){
		
		return editccmode;
	}
	
	
	public List<selectOption>  getmonths()
	{
		
		//shiptooptions.add(new SelectOption('ALL','ALL'));
		List<SelectOption> months = new List<SelectOption>();
		if(ecreditcardexpmonth=='' || ecreditcardexpmonth==null)
		ecreditcardexpmonth='1';
		months.add(new SelectOption(ecreditcardexpmonth,ecreditcardexpmonth));
		for(integer i=1;i<13;i++){
			if(!String.valueof(i).equals(ecreditcardexpmonth))
			months.add(new SelectOption(String.valueof(i),String.valueof(i)));
		}
		
		return months;
	}
	
	
	
	public List<selectOption>  getyears()
	{
		List<SelectOption> years = new List<SelectOption>();
		if(ecreditcardexpyear=='' || ecreditcardexpyear==null)
		ecreditcardexpyear='2012';
		years.add(new SelectOption(ecreditcardexpyear,ecreditcardexpyear));
		for(integer i=2012;i<2020;i++){
			if(!String.valueof(i).equals(ecreditcardexpyear))
			years.add(new SelectOption(String.valueof(i),String.valueof(i)));
		}
		
		return years;
	}
	
	
	public List<selectoption> getcctypes(){
		
		List<SelectOption> cctypes = new List<SelectOption>();
		cctypes.add(new SelectOption('AMEX','Amex'));
		cctypes.add(new SelectOption('VISA','Visa'));
		cctypes.add(new SelectOption('MC','Master Card'));
		
		return cctypes;
	}
	
	
	
	/*
	Get a list of users affiliated with the selected account
	*/
	public void getAccountUsers() {
		Map<Id,Account> accountaffsMap = new Map<Id,Account>();
		Set<Id> affAccountsSet = new Set<Id>();
		try{
			debugMessage += '<br/>In getAccountUsers';
			message = '';
			if(accountId=='-1'){
				return;
			}
			if(users!=null){
				users.clear();
			}
			
			debugMessage += '<br/>'+' for '+accountId;
			
			//Get all affiliated accounts
			List <Affiliation_vod__c> affiliations = [select Id,to_account_vod__c, to_contact_vod__c  from Affiliation_vod__c where from_account_vod__c = :accountId];
			Map<Id,Id> affiliation_map = new Map<Id,Id>();
			for(Affiliation_vod__c aff : affiliations){
				affiliation_map.put(aff.to_account_vod__c,aff.Id);
				affAccountsSet.add(aff.to_account_vod__c);
				//accountaffsMap.put(aff.to_account_vod__c)
			}
			
			for(Account acc :[select id,IsPersonAccount,PersonContactId from Account where Id in :affAccountsSet]){
				accountaffsMap.put(affiliation_map.get(acc.Id),acc);
			}
			
			Set<ID> contactIds = new Set<ID>();
			debugMessage += '<br/> size is ' + affiliations.size();
			for(Affiliation_vod__c affiliation: affiliations){
				if(affiliation.to_account_vod__c!=null){
					//Affiliation to an account
					debugMessage += '<br/>person account '+' for '+affiliation.to_account_vod__c;
					//List <Account> accounts= [select Id, IsPersonAccount, PersonContactId from Account where Id = :affiliation.to_account_vod__c];
					Account account = accountaffsMap.get(affiliation.Id);//affiliation.to_account_vod__c);
					if(account!=null){
						//Account account = accounts.get(0);
						if(account.IsPersonAccount){
							debugMessage += '<br/>person contact is  '+' for '+account.PersonContactId;
							contactIds.add(account.PersonContactId);
						}
					}
				}
				else  if(affiliation.to_contact_vod__c!=null){
					//Affiliation to a contact
					debugMessage += '<br/>contact '+' for '+affiliation.to_contact_vod__c;
					// contactIds.add(affiliation.to_contact_vod__c);
				}
			}
			debugMessage += '<br/> size is ' + contactIds.size();
			if(contactIds.size()==0){
				return;
			}
			for(Id contactId : contactIds){
				debugMessage +='<br/>'+contactId+',';
			}
			users = [select FirstName, LastName, Email from User where ContactId in :contactIds];
			
			return;
		}
		catch(Exception e) {
			message = e.getMessage();
			return;
		}
	}
	
	public PageReference doCommercialOrder() {
		System.debug('calling doCommercialOrder in AccountProfileController..............');
		return doOperation(1);      
	}   
	
	public PageReference doChargeSummary () {
		return doOperation(2);      
	}
	
	public PageReference doOrderSummary () {
		return doOperation(3);      
	}
	
	public PageReference doContactProcess() {
		return doOperation(6);
	}
	
	public PageReference doHelpProcess() {
		return doOperation(7);
	}
	
	public PageReference doGoHomeProcess() {
		return doOperation(8);  
	}
	
	public PageReference doInvoiceReport() {
		return doOperation(9);      
	}
	
	
	public PageReference doGoMessagecenter(){
		
		return doOperation(10);
	}
	
	
	// pass all Sample related parameters to Commercial
	private PageReference doOperation(Integer operation) {

		//System.debug('calling doOperation, operation ==================' + operation);
		
		PageReference page = null;
		if( operation == 1) {                                       
			page = new PageReference('/apex/GNE_LWO_OrderEntry');
		}
		else if( operation == 2){
			page = new PageReference('/apex/GNE_LWO_ChargeSummary');
		}
		else if( operation == 3){
			page = new PageReference('/apex/GNE_LWO_OrderSummary');
		}
		else if( operation == 4){
			if(issampleuser)
			page = new PageReference('/apex/GNE_LWO_AccountProfileSample');
			else
			page = new PageReference('/apex/GNE_LWO_AccountProfile');
		}
		
		
		else if( operation == 6)
		page = new PageReference('/apex/GNE_LWO_Contact');
		else if( operation == 7) {
			
			if( this.getSampleEnrolled())
			page = new PageReference('/apex/GNE_LWO_SampleHelp');
			else
			page = new PageReference('/apex/GNE_LWO_Help');         
		}
		else if( operation == 8) {
			page = new PageReference('/apex/GNE_LWO_Welcome');
		} 
		else if( operation == 9) {
			page = new PageReference('/apex/GNE_LWO_InvoiceReport');
		}    
		
		else if(operation==10){
			
			page=new PageReference('/apex/LWO_Message_Center');
		}   

		if( sampleAccountId != null && sampleAccountId.length() > 0) {

			// pass sample account id
			page.getParameters().put('sid', sampleAccountId);
			page.getParameters().put('du', 'true');
			page.getParameters().put('oid', sampleOrderId);  
		}
		if(GNE_LWO_Controller.getAdminUser() && this.accountId != null)
		page.setRedirect(false);
		return page;                                                
	}
	
	
	public Boolean getSampleEnrolled() {
		
		System.debug('sampleAccountId================='+sampleAccountId);
		if( sampleAccountId != null && sampleAccountId.length() > 0)
		return true;
		else
		return false;
	}    
	
	public PageReference doSample() {
		
		System.debug('calling ProductOrderAccountProfileController.doSample for account=====' + sampleAccountId + '................');
		
		PageReference nextPage = null;
		
		if( sampleAccountId == null) {
			System.debug('Sample Account is not available');
			return null;
		}        
		
		Integer orderType = 1;
		
		// get 'In Process' order                
		Product_Order_Item_gne__c item = orderController.getSampleOrder(sampleAccountId, orderType);
		
		if( item != null ) {            
			nextPage = new PageReference('/apex/GNE_LWO_SampleOrderView');          
		}
		else {
			
			orderType = 3;
			
			// get the order before the earliest 'Pending Confirmation' order based on ship date
			item = orderController.getSampleOrder(sampleAccountId, orderType);
			
			if( item != null ) {
				
				// Only when the order is 'Shipped', check AOC                            
				//System.debug('item.Status__c==='+ item.Status__c +', SHIPPED_STATUS_ID===='+SHIPPED_STATUS_ID);
				if( item.Status__c == SHIPPED_STATUS_ID) {   
					
					if( item.Order__r.AOC_Status__c == null || item.Order__r.AOC_Status__c == 'INCOMPLETE') {
						
						nextPage = new PageReference('/apex/GNE_LWO_SampleAOC'); 
					}
				}
			}
		}
		
		if( nextPage == null ) {
			
			// get earliest Pending Conf. order
			orderType = 2;
			item = orderController.getSampleOrder(sampleAccountId, orderType);
			
			if( item != null)                    
			nextPage = new PageReference('/apex/GNE_LWO_SampleOrder');
			else
			nextPage = new PageReference('/apex/GNE_LWO_NoOrder');                                                                                          
		}
		
		System.debug('setting sample parameters>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>') ;
		nextPage.getParameters().put('sid', this.sampleAccountId);  
		if( item != null)
		nextPage.getParameters().put('oid', item.Order__r.Id);
		
		nextPage.getParameters().put('du', isDesigneeUser);     
		

		if( nextPage != null ) {        
			if(GNE_LWO_Controller.getAdminUser() && this.accountId != null)
			nextPage.getParameters().put('accountID', this.accountId);                                 
			nextPage.setRedirect(false);                              
			return nextPage;
		}
		
		return null;        
		
	}    
	
	
	public boolean updateAccountDropdownList(){
		this.debugMessage +='<br/>updateAccountDropdownList';
		this.searchMessage='';
		this.allAcntOptions = new List<List<SelectOption>>();
		
		//only retrive account lists when it's null or empty
		if(this.allAcntForDropdown==null ||this.allAcntForDropdown.size()<=0){
			if(GNE_LWO_Controller.getAdminUser()){
				this.allAcntForDropdown = dataController.getAccountsForAdmin();
				if(this.allAcntForDropdown == null || this.allAcntForDropdown.size()<=0 || 
						this.allAcntForDropdown.get(0)== null ||this.allAcntForDropdown.get(0).size()<=0){
					//criticalError = 'You are not affiliated with any account to place a web order. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
					log.save('Error: No accounts found for user', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
					return false;
				}
				System.debug('******Get '+this.allAcntForDropdown.size()+' account list');
			}else{
				List<Account> acnts=dataController.getAccounts();
				if(acnts == null || acnts.size()<=0) {
					//criticalError = 'You are not affiliated with any account to place a web order. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
					//logObjectContent();
					log.save('Error: No accounts found for user', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
					return false;
				}else {
					this.allAcntForDropdown = new List<List<Account>>();
					this.allAcntForDropdown.add(acnts);
				}
			}
		}
		
		boolean searchAccount= (this.searchAccountField !=null && this.searchAccountField.trim().length()>0)? true:false;
		Integer foundAccountCount=0;
		List <List<SelectOption>> searchSelections = new List<List<SelectOption>>();
		
		
		//create dropdown selectOption list
		if(this.allAcntForDropdown !=null && this.allAcntForDropdown.size()>0){     
			for(List<Account> acntList: this.allAcntForDropdown){
				if(acntList!=null && acntList.size()>0){
					//selectOption list for search account
					List<SelectOption> so = new List<SelectOption>();
					//selectOption list for all accounts
					List<SelectOption> allo = new List<SelectOption>();
					for(Account acc: acntList){
						allo.add(new SelectOption(acc.Id, acc.Name+' ('+acc.SAP_ID_gne__c+' )'));

						//logic for search account
						if(searchAccount){
							if (acc.Name.toLowerCase().contains(searchAccountField.toLowerCase())
									|| acc.SAP_ID_gne__c.contains(searchAccountField)){
								this.accountID = acc.Id;
								this.selectedAccount = acc;
								this.accountSelected = true;
								foundAccountCount++;
								so.add(new SelectOption(acc.Id, acc.Name+' ('+acc.SAP_ID_gne__c+' )'));
							}
						}else{
							if(this.accountID!=null && this.accountID.equals(acc.Id)){
								this.selectedAccount = acc;
								this.accountSelected = true;
							}
						}
					}
					if(searchAccount){
						searchSelections.add(so);
					}
					this.allAcntOptions.add(allo);
					
				}
			}
		}
		
		//update searchMessage according to search result.
		if(searchAccount){
			if(foundAccountCount<=0){
				this.searchMessage='No account found matching <b>"' + searchAccountField + '"</b>';
				this.selectedAccount=null;
				this.accountID=null;
				this.accountSelected = false;
			}else{
				String suffix  = (foundAccountCount == 1) ? '' : 's';
				searchMessage = '<b>' + foundAccountCount + '</b> account' + suffix + ' found';
				//replace all account list with the found account list
				this.allAcntOptions = searchSelections;
			}
		}
		
		if(this.searchOptionOn == false && this.allAcntOptions != null && this.allAcntOptions.size()>0 &&
				this.allAcntOptions.get(0) !=null && this.allAcntOptions.get(0).size()>10){
			this.searchOptionOn=true;
		}
		
		//If no account selected, the 1st account on the accounts list is set as selected account
		if(this.accountID == null ){
			if(this.allAcntForDropdown.get(0)!=null && this.allAcntForDropdown.get(0).size() >0){
				Account acc = this.allAcntForDropdown.get(0).get(0);
				this.accountID=acc.Id;
				this.selectedAccount = acc;
				this.accountSelected = true;
			}
		}
		
		System.debug('********Have '+this.allAcntOptions.size()+' option list, which contains '+this.allAcntOptions.get(0).size()+' options');
		return true;
	} 

	public  List<SelectOption> getAccounts2(){
		//return accountOptions;
		if(this.allAcntOptions !=null && this.allAcntForDropdown.size()>1)
		return this.allAcntOptions.get(1);
		else return new List<SelectOption>();
	}     
	
	public  List<SelectOption> getAccounts(){
		//return accountOptions;
		if(this.allAcntOptions !=null && this.allAcntForDropdown.size()>0)
		return this.allAcntOptions.get(0);
		else return new List<SelectOption>();
	}    

	public boolean getEnableSampleOrderTab(){
		if(this.getSampleEnrolled()==false || (GNE_LWO_Controller.getAdminUser()==true)){
			return false;
		}   else {
			return true;
		}
	}
	
	
	// define  classes for holding billing and shipping addresses. 
	
	
	public class BillingInfo{
		
		public String accountNum {get;set;} 
		public String accountConEmail {get;set;}
		public String street {get;set;}
		public String city {get;set;}
		public String state {get;set;}
		public String zip {get;set;}
		
		public String accountAddress {get;set;}
		public String accountName {get;set;} 
	}
	
	
	global class ShippingInfo{
		public Integer index {get;set;}
		public String addressNum {get;set;} 
		public String addressName {get;set;} //ship to name 
		public String contact_name {get;set;} //careof
		public String delayAlertEmail {get;set;} 
		public String presciberName {get;set;}
		public String stateMedicalLicense {get;set;} 
		public String stateMedicalExp {get;set;} 
		public String DEALicense {get;set;} 
		public String street {get;set;}
		public String address {get;set;}
		public String City {get;set;}
		public String State {get;set;}
		public String Zip {get;set;} 
		public String Phone {get;set;} 
		public String Fax {get;set;}  
		public boolean isDefault {get;set;} 
		
	}

	
	public class CreditCardInfo{
		public Integer index {get;set;}
		public String Card_Type {get;set;}
		public String Name {get;set;}
		public String original_number {get;set;} 
		public String Card_Holder_Name {get;set;}
		public Date Expiration_Date {get;set;}
		public String nick_name {get;set;}
		public String exp_date {get;set;}
		public String exp_month {get;set;}
		public String exp_year {get;set;}
		public String account_number {get;set;}
		public Boolean expirationflag{get;set;}
	}
	
	// ------------------------Code added to replace html  months,years and states----------------------------------
	
	public List<SelectOption> getExpMonths(){
		List<SelectOption> options = new List<SelectOption>(); 
		/*  Integer i=01;
		while(i<=12){
			options.add(new SelectOption(String.valueOf(i),String.valueOf(i))); 
			i++;
		}   */
		options.add(new SelectOption('01','01'));
		options.add(new SelectOption('02','02'));
		options.add(new SelectOption('03','03'));
		options.add(new SelectOption('04','04'));
		options.add(new SelectOption('05','05'));
		options.add(new SelectOption('06','06'));
		options.add(new SelectOption('07','07'));
		options.add(new SelectOption('08','08'));
		options.add(new SelectOption('09','09'));
		options.add(new SelectOption('10','10'));
		options.add(new SelectOption('11','11'));
		options.add(new SelectOption('12','12'));                
		return options;
	}
	
	public List<SelectOption> getExpYears(){
		List<SelectOption> options = new List<SelectOption>(); 
		Date currentDate = System.Today();
		if(currentDate==null) currentDate=system.today();
		
		Integer curYear = currentDate.year();
		Integer counter=0;
		while(counter<10){
			Integer year=curYear+counter;
			options.add(new SelectOption(String.valueOf(year),String.valueOf(year))); 
			counter++;
		}
		return options;
	}
	
	
	

	public List<SelectOption> getUsStates() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('AA','AA'));  
		options.add(new SelectOption('AE','AE'));  
		options.add(new SelectOption('AK','AK'));   
		options.add(new SelectOption('AL','AL'));
		options.add(new SelectOption('AL','AL'));
		options.add(new SelectOption('AP','AP'));
		options.add(new SelectOption('AR','AR'));
		options.add(new SelectOption('AS','AS'));        
		options.add(new SelectOption('AZ','AZ'));
		options.add(new SelectOption('CA','CA'));               
		options.add(new SelectOption('CO','CO'));
		options.add(new SelectOption('CT','CT')); 
		options.add(new SelectOption('DC','DC'));
		options.add(new SelectOption('DE','DE'));
		options.add(new SelectOption('FL','FL'));
		options.add(new SelectOption('GA','GA'));
		options.add(new SelectOption('GU','GU'));
		options.add(new SelectOption('HI','HI'));
		options.add(new SelectOption('IA','IA'));
		options.add(new SelectOption('ID','ID'));
		options.add(new SelectOption('IL','IL'));
		options.add(new SelectOption('IN','IN')); 
		options.add(new SelectOption('KS','KS')); 
		options.add(new SelectOption('KY','KY')); 
		options.add(new SelectOption('LA','LA'));
		options.add(new SelectOption('MA','MA'));         
		options.add(new SelectOption('MD','MD')); 
		options.add(new SelectOption('ME','ME'));
		options.add(new SelectOption('MI','MI')); 
		options.add(new SelectOption('MN','MN')); 
		options.add(new SelectOption('MO','MO')); 
		options.add(new SelectOption('MP','MP')); 
		options.add(new SelectOption('MS','MS'));         
		options.add(new SelectOption('MT','MT')); 
		options.add(new SelectOption('NC','NC')); 
		options.add(new SelectOption('ND','ND'));
		options.add(new SelectOption('NE','NE'));
		options.add(new SelectOption('NH','NH'));
		options.add(new SelectOption('NJ','NJ')); 
		options.add(new SelectOption('NM','NM')); 
		options.add(new SelectOption('NV','NV')); 
		options.add(new SelectOption('NY','NY'));         
		options.add(new SelectOption('OH','OH')); 
		options.add(new SelectOption('OK','OK')); 
		options.add(new SelectOption('OR','OR')); 
		options.add(new SelectOption('PA','PA')); 
		options.add(new SelectOption('PR','PR')); 
		options.add(new SelectOption('RI','RI')); 
		options.add(new SelectOption('SC','SC')); 
		options.add(new SelectOption('SD','SD')); 
		options.add(new SelectOption('TN','TN'));         
		options.add(new SelectOption('TX','TX'));         
		options.add(new SelectOption('UT','UT')); 
		options.add(new SelectOption('VA','VA'));
		options.add(new SelectOption('VI','VI'));
		options.add(new SelectOption('VT','VT'));        
		options.add(new SelectOption('WA','WA')); 
		options.add(new SelectOption('WI','WI'));
		options.add(new SelectOption('WV','WV'));         
		options.add(new SelectOption('WY','WY'));                 
		return options;
	}  
	Integer newccexpmonth = System.Today().month();
	Integer newccexpyear = System.Today().year();
	
	public Integer getNewccexpmonth() {
		return newccexpmonth;
	}
	
	public void setNewccexpmonth(Integer newccexpmonth) {
		this.newccexpmonth = newccexpmonth;
	}  
	public Integer getNewccexpyear() {
		return newccexpmonth;
	}           
	public void setNewccexpyear(Integer newccexpyear) {
		this.newccexpyear = newccexpyear;
	}  
	
	String newccstate  = '';
	
	public String getNewccstate(){
		return newccstate;
	}
	public void setNewccstate(String newccstate){
		this.newccstate = newccstate;
	}
	
}