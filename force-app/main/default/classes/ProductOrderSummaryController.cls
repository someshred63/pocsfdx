public without sharing class ProductOrderSummaryController {
    public static GNE_LWO_Logger log = new GNE_LWO_Logger();  
        
    private List<Product_Order_Payment_gne__c> payments = null;
    private List<Product_Order_Item_gne__c> items = null;
    private List<SelectOption> accountOptions = null;
    private Map<String,String> accountNames = null;
    private List<SelectOption> creditCardOptions = null;
    private Map<String,Date> itemChargeDate = null;

    static String SHIPPED_STATUS_ID = null;    
    static ProductOrderController orderController = null;
    static ProductDataController dataController = null;
        
    private List<String>fullSummary = null;
    private String summaryHeader = null;
    private String summaryFooter = null;
    private Set<String> creditCardsUsed = null;
    private Map<Integer,String> ccList = null;
    
    private List<String>chargeFullSummary = null;
    
    private String pendingSummaryHeader = null;
    
    private Map<Date, List<Product_Order_Payment_gne__c>> sPayments;
    
    private Map<String, List<Product_Order_Payment_gne__c>> ccPayments;  
    
    private Integer listSize = 0;
    private Integer columnCount = 0;
    private Integer accountCount = 0;

        
    private String title = null;
    private Set<Id> accountIds = null;
    private String accountID = null;
    public String accountIndicator = null;
    private String creditCardID = null;
    
    public Integer chargeFullSummarysize {get;set;} 
    public Boolean searchOptionOn {get; set;}
    public String searchAccountField {get; set;}
    public String searchMessage  {get; set;}
    public String debugMessage  {get; set;}
    public Boolean debug  {get; set;}
        
    private Boolean sampleEnrolled;
    public String sampleAccountId {get; set;}
    public String sampleOrderId {get; set;}      
    public String isDesigneeUser {get; set;}
        
    private Boolean outputExcel = false;

    String currentDateValue = null;
    private Date currentDate = null;
    
    private Product_Order_gne__c order;
    private String criticalError = null;
    private String errorMessage = null;
    
    private Pattern hasDecimal1 = Pattern.compile('[\\d,]+\\.\\d');
    private Pattern hasDecimal2 = Pattern.compile('[\\d,]+\\.\\d{2}');
    
    //A list of all LWO account lists
    private List<List<Account>> allAcntForDropdown;
    private Account selectedAccount;
    private List<List<SelectOption>> allAcntOptions = null;
        
    static {
        dataController = new ProductDataController();   
        orderController = new ProductOrderController();
        
        Product_Order_Code_Lookup_gne__c statusCode = [select id from Product_Order_Code_Lookup_gne__c where Name = 'SHIPPED' limit 1];                         
        SHIPPED_STATUS_ID = statusCode.Id;             
    }
    
    
    public String getCreditCardID(){
        return this.creditCardID;
    }
    
    public void setCreditCardID(String id){
        this.creditCardID = id;
    }

    public  List<SelectOption> getCreditCards(){
        if (creditCardOptions == null || creditCardOptions.size() == 0) {
            if (creditCardOptions == null) {
                creditCardOptions = new List<SelectOption>();
            }
            creditCardOptions.add(new SelectOption('-1','No credit cards'));    
            creditCardID = '-1';
        }
            return creditCardOptions;
    }
    
    public String getAccountID(){
        return this.accountID;
    }
    
    public void setAccountID(String id){
        this.accountID = id;
    }

    public String getAccountIndicator()
    {
        return this.accountIndicator;
    }

    public void setAccountIndicator(String id)
    {
        
        Account account = dataController.getAccountInfoForID(id);
        if(account == null)
        {
            return;
        }
        GneProductOrderGetAccountInfo.AccountInfo accountInfo = new GneProductOrderGetAccountInfo.AccountInfo();
        system.debug('Account Info '+ accountInfo);
        system.debug('SAP Accoun ID ' + Id);
        GneProductOrderGetAccountInfo.AccountInfoResponseItem[] responseItems = accountInfo.accountInfo(account.SAP_ID_gne__c, 'C');
        system.debug('Response Items' + responseItems);
        if (responseItems == null || responseItems.size() == 0) 
        {
            this.debugMessage += 'SAP responseItems is null for getAccountInfo<br/>';
            system.debug('ResponseItems'+ responseItems);
        }
        
        for (GneProductOrderGetAccountInfo.AccountInfoResponseItem response:responseItems) 
        {
                String responseType = response.ResponseItemType;
                String status = response.Status;
                system.debug('Status' + status);       
                if (status == null || status.trim().length() == 0) {
                    status = 'true';
                }

                if (status != 'true') 
                {
                    if (response.Message != null && response.Message.length() > 0 ) 
                    {
                        this.debugMessage += 'SAP response status is false --'+response.Message+'<br/>';
                    } 
                    else 
                    {
                        this.debugMessage += 'SAP responseMessage is null or empty for getAccountInfo<br/>';
                    }
                    break;
                }
                
                // Status OK
                if (responseType == 'account') 
                {
                    this.accountIndicator = response.accountIndicator;
                    system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'+accountIndicator);
                }
        }
                
    }


    public String getAccountName(){
        return this.accountNames.get(accountID);
    }
    
    public  List<SelectOption> getAccounts(){
            //return accountOptions;
      if(this.allAcntForDropdown !=null && this.allAcntForDropdown.size()>0)      
            return this.allAcntOptions.get(0);
      else return new List<SelectOption>();
    }
    
     public Integer getAccountCount() {
        return accountCount;
        //return accountOptions.size();
    }
    
    
    public String getTitle(){
        return this.title;
    }
    
    public String getCriticalError(){
            return criticalError;
    }
    
    public String getErrorMessage(){
            return errorMessage;
    }
    public void setErrorMessage(String msg){
            this.errorMessage = msg;
    }
    
    public Integer getListSize() {
        system.debug('------------------------------------Full Summary: '+fullSummary);
        if (fullSummary == null || fullSummary.size() == 0) {
            //errorMessage = 'No order payment records found for display.';
          
            return 0;
        } else {
            return fullSummary.size(); 
        }
    }
    public Integer getColumnCount() {
        return columnCount;
    }
    
   
    public ProductOrderSummaryController() {
              
        debug = false;
        //debug = true;
            
        //First check to see if this is invoked with the right entry point or not
        PageReference pageRef = System.currentPageReference();
        String url = pageRef.getUrl();

            //Jie code
        if(GNE_LWO_Controller.getAdminUser()){
            this.searchOptionOn = true;
            String aID = pageRef.getParameters().get('accountID');
            if(aID != null && aID.trim().length()>0) {
                accountID = aID.trim();
                this.debugMessage +='accountID '+accountID+'<br/>';
            }
    }
        
        //check if sample parameter are passed          
        sampleAccountId = pageRef.getParameters().get('sid');
        sampleOrderId = pageRef.getParameters().get('oid');   
        isDesigneeUser = pageRef.getParameters().get('du'); 
        if( sampleAccountId != null && sampleAccountId.length() >0)
           sampleEnrolled = true;
        else
          sampleEnrolled = false;
                                                           
        //if(!url.contains('ProductOrderChargeSummary')){
                        
        if(!url.contains('GNE_LWO_ChargeSummary')){
            //User trying to enter order entry process from a wrong entry point
            criticalError = 'Please click "Pending Charges" link on the top to view pending charge summary';
            return;
        }
        currentDate = System.Today();
        currentDateValue = System.Now().format('MMM d, yyyy');
        
             
        //getAccountsList();
        //updateAccountsList();
        //this.updateAccountDropdownList();
        setCreditCardID('ALL');
           String aIndicator = pageRef.getParameters().get('accountIndicator');
           if(aIndicator != null && aIndicator.trim().length()>0) {
                accountIndicator = aIndicator.trim();
           } 
        updateView();
        
    }
    
    public PageReference updateViewAccount(){
        PageReference currentPageRef = System.currentPageReference();
        //String selectedAccount = currentPageRef.getParameters().get('accountID');
        //accountID = (selectedAccount == null) ? accountID : selectedAccount;
                      
        //setAccountID(accountID);
        setCreditCardID('ALL');
                
        updateView();
        return null;
    }
    
    public PageReference updateViewCC(){
        PageReference currentPageRef = System.currentPageReference();
        String selectedCreditCard = currentPageRef.getParameters().get('creditCardID');
        creditCardID = (selectedCreditCard == null) ? creditCardID : selectedCreditCard;
              
        setCreditCardID(creditCardID);
        
        updateView();
        return null;
    }
    
    public PageReference downloadToExcel() {
        PageReference currentPageRef = System.currentPageReference();
        
        String selectedAccount = currentPageRef.getParameters().get('accountID');
        accountID = (selectedAccount == null) ? accountID : selectedAccount;
        
        String selectedCreditCard = currentPageRef.getParameters().get('creditCardID');
        creditCardID = (selectedCreditCard == null) ? creditCardID : selectedCreditCard;
      
        setAccountID(accountID);
        setCreditCardID(creditCardID);
        
        outputExcel = true;
        
        updateView();
        
        PageReference excelPage = new PageReference('/apex/ProductOrderChargeSummaryExcel');
        excelPage.setRedirect(false);
        return excelPage;
        
    }
    
    
    public PageReference updateView(){
         clearErrorMessages();
        
       
        
        // reset table values
        
        summaryHeader = null;
        summaryFooter = null;
        
        pendingSummaryHeader = null;
        
        if (fullSummary != null && fullSummary.size() > 0) {
            fullSummary.clear();
        }
        if (creditCardOptions != null && creditCardOptions.size() > 0) {
            creditCardOptions.clear();
        }
        
        //getOrderPayments();
        if (payments != null && payments.size() > 0) {
            //sortPayments();
        }
        
         if (searchAccountField == null) {
            searchMessage = null;
         }
         
         searchAccountField = null;
         getPendingCharges();
         getCreditCardList();
        return null;
    }
    
    public List<Product_Order_Payment_gne__c> getPayments() {
        return payments;
    }
    
    public List<String> getSummary() {
        return fullSummary;
    }

    public List<String> getChargeSummary() {
    
        if(chargeFullSummary != null)
        {
            chargeFullSummarysize = chargeFullSummary.size();
            System.debug('chargeFullSummary============'+chargeFullSummary);
        }        

        return chargeFullSummary;
    }
    
    public String getSummaryHeader() {
        return summaryHeader;
    }
    public String getSummaryFooter() {
        return summaryFooter;
    }
    
    public List<String>  getCardUsed() {
        return ccList.values();
    }

    public String getPendingSummaryHeader() {
        return pendingSummaryHeader;
    }
    
    /*
    Get list of accounts
    */
    private void getAccountsList(){
          List<Account> accounts = dataController.getAccounts();
          if(accounts==null || accounts.size()==0){
              return;
          }
         if(accountOptions==null){
             accountOptions = new List<SelectOption>();
         }
         else{
            accountOptions.clear();
         }
         if (accountNames == null) {
            accountNames = new Map<String,String>();
         }
         if(accounts!=null){
            for (Account account : accounts){
                if (accountID == null) {
                    setAccountID(account.id);
                }
                accountOptions.add(new SelectOption(account.Id, account.Name ));
                accountNames.put(account.id,account.Name);
            }
         }
         accountCount = accountOptions.size();
    }
    
     /*
     Update account selection list
    */
     public boolean updateAccountsList(){
           List<Account> accounts = dataController.getAccounts();
           if(accounts==null || accounts.size()==0){
                   criticalError = 'You are not affiliated with any account. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
                   return false;
           }
           if(accountOptions==null){
                   accountOptions = new List<SelectOption>();
           } else{
                   accountOptions.clear();
           }
            if (accountNames == null) {
            accountNames = new Map<String,String>();
           }
                                
           if(accounts!=null){
                
                for (Account account : accounts){
                    
                    // Account search field was filled in
                    if (searchAccountField != null && searchAccountField != 'all' && searchAccountField != '') {
                        if (account.Name.toLowerCase().contains(searchAccountField.toLowerCase())
                            || account.SAP_ID_gne__c.contains(searchAccountField)) {
                            accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')' ));
                            accountNames.put(account.id,account.Name);
                        }
                    } else {
                        if (accountID == null) {
                            accountID = account.Id;
                        }
                        accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')'));
                        accountNames.put(account.id,account.Name);
                   }
                }
           }
           
           if (accountOptions.size() == 0) {
                searchMessage = 'No account found matching <b>"' + searchAccountField + '"</b>';
                //revert back to the full list
                for (Account account : accounts){
                    
                    if (accountID == null) {
                            accountID = account.Id;
                    }
                    
                    accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')'));
                }
                
           } else {
                if (searchAccountField != null) {
                    String suffix  = (accountOptions.size() == 1) ? '' : 's';
                    searchMessage = '<b>' + accountOptions.size() + '</b> account' + suffix + ' found';
                } else {
                    searchMessage = '';
                }
           }
           
           if (searchOptionOn == null && accountOptions.size() >= 10) {
                searchOptionOn = true;
           }
            accountCount = accountOptions.size();
           return true;
    }
    
    /* 
    get list of credit cards used
    */
    private void getCreditCardList() {
        if (creditCardOptions == null) {
            creditCardOptions = new List<SelectOption>();
        } else {
            creditCardOptions.clear();
        }
    	
        if (creditCardsUsed == null || creditCardsUsed.size() == 0) {
            creditCardOptions.clear();
            return;
        }

        if (creditCardsUsed != null) {
            creditCardOptions.add(new SelectOption('ALL','All Cards'));
            for (String cc : creditCardsUsed) {
                creditCardOptions.add(new SelectOption(cc,'XXXX-XXXX-XXXX-' + cc)); 
            }
            
        }   
        
        //debugMessage += 'credit cards: ' + creditCardOptions.size() + '<br/>';
    }
    
    /* Jie code for pending charge report M&E in Feb 2015 */
    
    public List<CCardPayments> allPendingCharges {set; get;}
    public String grandTotalStr {set; get;}
    public boolean hasPendingCharge{set; get;}
    
    private void getPendingCharges(){
    	//accountID='0017000000Sb64uAAB';
    	//accountID='0017000000YuNkiAAF';
    	System.debug('$$$$$$$$$In getPendingCharges');
    	
    	if(accountID==null || accountID.trim().length()==0) {
    		PageReference currentPageRef = System.currentPageReference();
        
        	accountID = currentPageRef.getParameters().get('accountID');
    	}
        if (items == null) {    
            items = new List<Product_Order_Item_gne__c>();
        } else {
            items.clear();
        }
        
        for(Product_Order_Item_gne__c item : [select Name,  Expected_Settlement_Date__c,   Order__r.Bill_To__r.Name, Order__r.Name, Status__r.Name, 
        										order__r.Ordered_On__c, order__r.SAP_Order_ID__c
                                                from Product_Order_Item_gne__c
                                                where  Order__r.Bill_To__r.Id =: accountID and (Status__r.Name = 'SHIPPED' or Status__r.Name = 'PENDING') 
                                                and Expected_Settlement_date__c >=: System.Today()
                                                order by Expected_Settlement_date__c asc limit 150]) {
            items.add(item);   
 
        }
        
        if(items==null || items.size()==0){
        	this.hasPendingCharge=false;
        	return;
        }
        System.debug('$$$$$$$$$items size:'+items.size());
        if (payments == null) {
            payments = new List<Product_Order_Payment_gne__c>();
        } else {
            payments.clear();
        }
        
        if (creditCardsUsed == null) {
            creditCardsUsed = new Set<String>();
        } else {
            creditCardsUsed.clear();
        }
        
        //Map<String,String> ccInfo = new Map<String,String>();
        
        //debugMessage += 'getOrderPayments: items/payments: ' + items.size() + '/' + payments.size() + '<br/>';
        if (items != null && items.size() > 0) {
            List<String> orderIds = new List<String>();
            for(Product_Order_Item_gne__c item : items) {                
                orderIds.add(item.Order__c);
            }
               
                for(Product_Order_Payment_gne__c payment : [select Name,  Card_Holder_Name__c, Card_Type__c, Total__c,   Order__r.Bill_To__r.Name, Order__r.Name,
                											order__r.Ordered_On__c, order__r.SAP_Order_ID__c
                                                            from Product_Order_Payment_gne__c
                                                            where Order__r.Bill_To__r.Id =: accountID and Order__c in :orderIds limit 300]) {                                               
                
                    payments.add(payment);
                }
            
        }
        System.debug('$$$$$$$$$payments size:'+payments.size());
          
        if (itemChargeDate == null) {
            itemChargeDate = new Map<String,Date>();
        } else {
            itemChargeDate.clear();
        }
        if (items != null && items.size() > 0) {
            for (Product_Order_Item_gne__c item: items) {
                if (item.Expected_Settlement_date__c >= System.Today()) {
                    itemChargeDate.put(item.order__r.SAP_Order_ID__c,item.Expected_Settlement_date__c);
                }
            }
        }
        
         List<PendingCharges> pCharges = new List<PendingCharges>();
            
         if(payments!=null && payments.size()>0){
            	for(Product_Order_Payment_gne__c p: payments){
            		PendingCharges pc= new PendingCharges();
            		pc.cardInfo=p.Name+ '<br/>' + p.Card_Type__c + '<br/>' + p.Card_Holder_name__c;
            		pc.cardInfoDownload =p.Name+ '-' + p.Card_Type__c + '-' + p.Card_Holder_name__c;
            		pc.orderNum=p.order__r.SAP_Order_ID__c;
            		pc.orderDate=p.order__r.Ordered_On__c;
            		System.debug('$$$$$$$$$ order date '+pc.orderDate.date().format());
            		pc.amount=p.Total__c;
            		System.debug('$$$$$$$$$ total='+dataController.convertToCurrency(pc.amount.format()));
            		pc.cardId = p.Name + ' : ' + p.Card_Holder_name__c;
            		if (itemChargeDate.containsKey(p.order__r.SAP_Order_ID__c)) {
                        pc.chargeDate = itemChargeDate.get(p.order__r.SAP_Order_ID__c);
            		}
            		
            		pCharges.add(pc);
            		
                	String cardID =  p.Name + ' : ' + p.Card_Holder_name__c;
                	if (!creditCardsUsed.contains(cardID)) {
                    	creditCardsUsed.add(cardID);
		                //String cardInfo =  p.Name+ '<br/>' + p.Card_Type__c + '<br/>' + p.Card_Holder_name__c;
                    	//ccInfo.put(cardID,cardInfo);
                	}
            	}
        }
        System.debug('$$$$$$$$$pCharges size:'+pCharges.size());
        hasPendingCharge = false;
        if(allPendingCharges ==null) allPendingCharges = new List<CCardPayments>();
        else if(allPendingCharges.size()>0) allPendingCharges.clear();
        
        if(pCharges!=null && pCharges.size()>0){
        	hasPendingCharge = true;   
        	Double grandTotalAmount=0.0; 	
        	Map<String, CCardPayments> ccardPaymentsMap = new Map<String, CCardPayments>();
        	
        	if(this.creditCardID==null || this.creditCardID.trim()=='') {
        		creditCardID = 'ALL';
        		
        	}
        	System.debug('$$$$$$$$$creditCardID: '+creditCardID);
        	for(PendingCharges p: pCharges) { 	
        		if(this.creditCardID == 'ALL' || this.creditCardID==p.cardId){	
        			CCardPayments cp = ccardPaymentsMap.get(p.cardId);
        			boolean addToMap=false;
        			if(cp==null) {
        				cp=new CCardPayments();
        				addToMap =true;
        			}
        			cp.cardInfo = p.cardInfo;
        			cp.cardInfoDownload = p.cardInfoDownload;
        			cp.charges.add(p);
        			cp.total+=p.amount;        			
        			cp.listSize +=1;
        		    if(addToMap)ccardPaymentsMap.put(p.cardId, cp);
        		    grandTotalAmount +=p.amount;
        		}
        	}
        	allPendingCharges = ccardPaymentsMap.values();
        	grandTotalStr = dataController.convertToCurrency(grandTotalAmount.format());
        }else {
        	hasPendingCharge = false;
        }
 System.debug('$$$$$$$$$allPendingCharges size:'+allPendingCharges.size()+' | hasPendingCharge= '+hasPendingCharge+' | allPendingCharges 1 '+allPendingCharges[0].charges.size());
		if(hasPendingCharge) {
			for(CCardPayments cp: allPendingCharges) {
				cp.charges.sort();
				
			}
			
			allPendingCharges.sort();
		}
    }
    
    

    public class CCardPayments implements Comparable{
    	public  CCardPayments(){
    		charges=new List<PendingCharges>();
    		listSize=0;
    		total=0.00;
    	}
    	public String cardInfo {get; set;}
    	public String cardInfoDownload {set; get;}
    	public Double total{get; set;}
    	public List<PendingCharges> charges {get; set;}
    	public Integer listSize {get; set;}
    	
    	public String getTotalAmount(){
    		return dataController.convertToCurrency(total.format());
    	}
    	
    	 public Integer compareTo(Object compareTo) {
    	 	if(this.cardInfo==((CCardPayments)compareTo).cardInfo) return 0;
    	 	if(this.cardInfo>((CCardPayments)compareTo).cardInfo) return 1;
    	 	else return -1;
    	 }
    
    }
    
    public class PendingCharges implements Comparable{
        	public String cardInfo {get; set;}
        	public String cardInfoDownload {set; get;}
        	public Date chargeDate{get; set;}
        	public String orderNum{get; set;}
        	public DateTime orderDate{get; set;}
        	public Double amount{get; set;}
        	public String cardId {get; set;}
        	
        	public String getChargeAmount(){
        		return dataController.convertToCurrency(amount.format());
        	}
        	
        	public String getChargeDateStr(){
        		if(chargeDate!=null) return chargeDate.format();
        		else return '';
        	}
        	
        	public String getorderDateStr(){
        		if(orderDate!=null){
        			return orderDate.date().format();
        		}else return '';
        	}
        	
        	public Integer compareTo(Object compareTo) {
        		if(this.chargeDate==((PendingCharges)compareTo).chargeDate) return 0;
        		if(this.chargeDate>((PendingCharges)compareTo).chargeDate) return 1;
        		else return -1;
        	}
    }

/* end of Jie code for Feb 2015 LWO M&E request */
    
    public void getOrderPayments() {
               
        getSettlementDates();
        
        // payments for items found in getSettlementDates() only!       
        // get around the max functional limit of 200 in a result set for direct assignment to a list from a SOQL statement w/ a FOR loop
        if (payments == null) {
            payments = new List<Product_Order_Payment_gne__c>();
        } else {
            payments.clear();
        }
        
        //debugMessage += 'getOrderPayments: items/payments: ' + items.size() + '/' + payments.size() + '<br/>';
        if (items != null && items.size() > 0) {
            List<String> orderIds = new List<String>();
            for(Product_Order_Item_gne__c item : items) {                
                orderIds.add(item.Order__c);
            }
               
                for(Product_Order_Payment_gne__c payment : [select Name,  Card_Holder_Name__c, Card_Type__c, Total__c,   Order__r.Bill_To__r.Name, Order__r.Name,
                											order__r.Ordered_On__c, order__r.SAP_Order_ID__c
                                                            from Product_Order_Payment_gne__c
                                                            where Order__r.Bill_To__r.Id =: accountID and Order__c in :orderIds limit 150]) {                                               
                
                    payments.add(payment);
                }
            
        }
        //debugMessage += 'getOrderPayments final: items/payments: ' + items.size() + '/' + payments.size() + '<br/>';
                
        
    }
    
    private void getSettlementDates() {
        

        if (items == null) {    
            items = new List<Product_Order_Item_gne__c>();
        } else {
            items.clear();
        }
       // debugMessage += 'getSettlementDates (should be 0/0): items/payments: ' + items.size() + '/0<br/>';
        for(Product_Order_Item_gne__c item : [select Name,  Expected_Settlement_Date__c,   Order__r.Bill_To__r.Name, Order__r.Name, Status__r.Name, 
        										order__r.Ordered_On__c, order__r.SAP_Order_ID__c
                                                from Product_Order_Item_gne__c
                                                where  Order__r.Bill_To__r.Id =: accountID and (Status__r.Name = 'SHIPPED' or Status__r.Name = 'PENDING') 
                                                and Expected_Settlement_date__c >=: System.Today()
                                                order by Expected_Settlement_date__c asc limit 150]) {
            items.add(item);
              
        }
        
        
        if (itemChargeDate == null) {
            itemChargeDate = new Map<String,Date>();
        } else {
            itemChargeDate.clear();
        }
        if (items != null && items.size() > 0) {
            for (Product_Order_Item_gne__c item: items) {
                if (item.Expected_Settlement_date__c >= System.Today()) {
                    itemChargeDate.put(item.Order__r.Name,item.Expected_Settlement_date__c);
                }
            }
        }
    }
    
    private void sortPayments() {
        if (sPayments == null) {
            sPayments = new Map<Date, List<Product_Order_Payment_gne__c>>();
        } else {
            sPayments.clear();
        }
        
        if (ccPayments == null) {
            ccPayments = new Map<String, List<Product_Order_Payment_gne__c>>();
        } else {
            ccPayments.clear();
        }
                
        if (creditCardsUsed == null) {
            creditCardsUsed = new Set<String>();
        } else {
            creditCardsUsed.clear();
        }
        Map<String,String> ccInfo = new Map<String,String>();
        
        if ((payments == null || payments.size() == 0) || (itemChargeDate == null || itemChargeDate.size() == 0)) {
                // set errorMessage here!!!
                //errorMessage = 'No order payment records found for display.';
                return;
        }
    
        
        // create map of payments based on settlement date
        // key = settlement date
        // value = List of payments for that date

        String cardID = null;
        List<Product_Order_Payment_gne__c> tempList = null;
        
        for(Product_Order_Payment_gne__c payment: payments){

            if (itemChargeDate.containsKey(payment.Order__r.Name)) {
                
                Date sDate = itemChargeDate.get(payment.Order__r.Name);
                if (sPayments.containsKey(sDate)) {
                    templist = sPayments.get(sDate);
                    
                    //templist.add(payment);
                    //sPayments.put(sDate,templist);

                    // make sure that tempList has uniqueue payment for the same credit card by merging payment totals
                    if( tempList == null || tempList.size() == 0) {
                        templist.add(payment);
                        sPayments.put(sDate,templist);
                    }
                    else {
                        // earch for cc match
                        Boolean foundMatch = false;
                        for(Integer i=0; i < tempList.size(); i++) {

                            if( payment.Card_Type__c == tempList[i].Card_Type__c &&
                                payment.Name == tempList[i].Name && 
                                payment.Card_Holder_name__c == tempList[i].Card_Holder_name__c) {
                                
                                if (tempList[i].Total__c != null) {

                                    if (payment != null && payment.Total__c != null) {
                                        tempList[i].Total__c += payment.Total__c;
                                    }
                                }
                                else {
                                    if (payment != null && payment.Total__c != null) 
                                        tempList[i].Total__c = payment.Total__c;
                                }

                                foundMatch = true;
                            }
                        }

                        if( !foundMatch) {
                            templist.add(payment);
                            sPayments.put(sDate,templist);
                        }
                    }                   

                } else {
                    // new date not yet in the grid
                    List<Product_Order_Payment_gne__c> dPayment = new List<Product_Order_Payment_gne__c>();
                    dPayment.add(payment);
                    sPayments.put(sDate,dPayment);
                }
            
                cardID =  payment.Name + ' : ' + payment.Card_Holder_name__c;
                if (!creditCardsUsed.contains(cardID)) {
                    creditCardsUsed.add(cardID);
                    //String cardInfo = 'XXXX-XXXX-XXXX-' + payment.Name + '<br/>' + payment.Card_Type__c + '<br/>' + payment.Card_Holder_name__c;
                    //String cardInfo =  '<td>'+payment.Name + payment.Card_Type__c + '<br/>' + payment.Card_Holder_name__c+'</td>';
                    String cardInfo =  payment.Name+ '<br/>' + payment.Card_Type__c + '<br/>' + payment.Card_Holder_name__c;
                    ccInfo.put(cardID,cardInfo);
                }
            }
        }
        

        // create map of payments based on credit card
        // key = credit card last 4 digits and card holder name
        // value = List of payments for that credit card
        cardID = null;
        tempList = null;
        String ccKey = null;
        
        for(Product_Order_Payment_gne__c payment: payments){
            
            
            ccKey  =   payment.Card_Type__c + '<br/>' + payment.Name + '<br/>' + payment.Card_Holder_name__c;
                                
            if (ccPayments.containsKey(ccKey)) {
                
                templist = ccPayments.get(ccKey);
                templist.add(payment);
                ccPayments.put(ccKey,templist);
            } else {
                
                // new credit card not yet in the grid
                List<Product_Order_Payment_gne__c> dPayment = new List<Product_Order_Payment_gne__c>();
                dPayment.add(payment);
                ccPayments.put(ccKey,dPayment);
            }     
               
        }
                              
        // prepare select list for credit cards
        getCreditCardList();
        
        // establish credit card order as they will be displayed as columns
        if (ccList == null) {
            ccList = new Map<Integer,String>();
        } else {
            ccList.clear();
        }
        Integer i = 2;
        if (creditCardID == 'ALL') {
            for (String cc : creditCardsUsed) {
                ccList.put(i,cc);
                i = i + 1;
            }
        } else {
            ccList.put(i,creditCardID);
        }
        
        // now, separate charges for each CC for each settlement date
        Map<String,Double> chargeAmount = null;
        Set<Date> settlementDates = sPayments.keySet();
        
        // transfer dates in the Set to a List so that dates can be sorted (needed for the Excel download feature)
        List<Date> sortedSettlementDates = new List<Date>();
        for(Date uniqueDate : settlementDates) {
            //System.debug('payment date============='+uniqueDate.format());
            sortedSettlementDates.add(uniqueDate);
        }
        sortedSettlementDates.sort();

        
        // sort charges by credit card        
        Set<String> settlementCards = ccPayments.keySet();
                
        List<String> sortedSettlementCards = new List<String>();
        for(String uniqueCard : settlementCards) {
            //System.debug('adding credit card...................'+uniqueCard);
            sortedSettlementCards.add(uniqueCard);            
        }
        sortedSettlementCards.sort();
        
                
        if (fullSummary == null) {
            fullSummary = new List<String>();
        } else {
            fullSummary.clear();
        }
        
                       
        columnCount = ccList.size() + 2;
        String summary = '';
        Double dayTotal = 0;
        Double grandTotal = 0;
        
        summaryHeader = '<th "width=150">Expected<br/>Charge Date</th>';
        
                
        for (Integer j =2; j < columnCount; j++ ) {
            summaryHeader = summaryHeader + '<th>' + ccInfo.get(cclist.get(j)) + '</th>';
        }
        summaryHeader = summaryHeader + '<th "width=150">Total<br/>Amount To Be <br/>Charged</th>';
        summaryFooter = '<th>Total</th>';
        String convertedNumber = '';
        
        List<Double> cardTotal = new List<Double>();
        // loop over all the settlement dates
        Integer dayCounter = 0;
        for(Date sDate : sortedSettlementDates) {
            // all payments for a given settlement date
            dayCounter = dayCounter + 1;
            chargeAmount = new Map<String,Double>();
            for(Product_Order_Payment_gne__c payment: sPayments.get(sDate)) {
                                
                if (payment != null && payment.Total__c != null) {
                    payment.Total__c = payment.Total__c.setScale(2);
                    cardID =  payment.Name + ' : ' + payment.Card_Holder_name__c;
                    if (creditCardID == 'ALL' || creditCardID == cardId) {
                        if (chargeAmount.containsKey(cardID)) {
                            chargeAmount.put(cardID,chargeAmount.get(cardID) + payment.Total__c);
                        } else {
                            chargeAmount.put(cardID,payment.Total__c);
                        }
                    }
                }
            }
            summary = '<td style="background-color:#e6EEEE; border:1px #09c solid; text-align:left;">' + sDate.format() + '</td>';
            
            String chargeDetail = '';
            
            for (Integer j =2; j < columnCount; j++ ) {
                Double ccTotal = 0;
                if (chargeAmount.containsKey(cclist.get(j))) {
                    ccTotal = chargeAmount.get(cclist.get(j));
                    convertedNumber = dataController.convertToCurrency(ccTotal.format());
                    chargeDetail = chargeDetail + '<td>' + + '$' + convertedNumber  +  '</td>';
                    
                    dayTotal = dayTotal + ccTotal;
                } else {
                    ccTotal = 0;
                    chargeDetail = chargeDetail + '<td>$0.00</td>';
                }
                if (dayCounter == 1) {
                    cardTotal.add(ccTotal);
                } else {
                    cardTotal[j-2] = cardTotal[j-2] + ccTotal;
                }
                
                
            }
            grandTotal = grandTotal + dayTotal;
            summary = summary + chargeDetail;
            convertedNumber = dataController.convertToCurrency(dayTotal.format());
            summary = summary + '<td style="background-color:#e6EEEE; border:1px #09c solid;"><b>' + '$' + convertedNumber + '</b></td>';
            
            fullSummary.add(summary);
            dayTotal = 0;
            
        }
                        
        for ( Integer m =0; m < columnCount - 2; m++) {
            convertedNumber = dataController.convertToCurrency(cardTotal[m].format());
            summaryFooter = summaryFooter + '<th>' + '$' + convertedNumber + '</th>';
            
        }
        convertedNumber = dataController.convertToCurrency(grandTotal.format());
        summaryFooter = summaryFooter + '<th>' + '$' + convertedNumber + '</th>' ;
        
        // are there any payment records?
        if (fullSummary.size() == 0) {
            summaryHeader = '<th>No Payments records found for this account</th>';
            summaryFooter = '<th></th>';
        }
        
        
        
        if (chargeFullSummary == null) {
            chargeFullSummary = new List<String>();
        } else {
            chargeFullSummary.clear();
        }


        columnCount = 3;
        summary = '';
        dayTotal = 0;
        grandTotal = 0;
                
        pendingSummaryHeader ='<td width="200">Personal<br/>Information</td>';
        pendingSummaryHeader +='<td width="200">Expected<br/>Charge Date*</td>';
        pendingSummaryHeader +='<td width="200"><br/>Amount</td>';
        

        convertedNumber = '';
        
        cardTotal = new List<Double>();
        
                
        Integer cardCount = 0;
        Integer remainder = 0;
        String lineColor = '';
        Double currentCardTotal = 0;
        
        grandTotal = 0;

        // loop over all the settlement card charges
        for(String card : sortedSettlementCards) {
                    
            dayCounter = 1;                
            List<Product_Order_Payment_gne__c> curCardList = ccPayments.get(card);
                                                     
            if( curCardList.size() > 0 ) {

               String tempSummary = '';
               currentCardTotal = 0;
               
               Product_Order_Payment_gne__c paymentItem = curCardList[0];
                                                             
               for(Date sDate : sortedSettlementDates) {
                                        
                    //System.debug('date================'+sDate.format());
                    chargeAmount = new Map<String,Double>();
                    
                    List<Product_Order_Payment_gne__c> paymentList = sPayments.get(sDate);
                    
                    Date prevDate = null;
                    for(Product_Order_Payment_gne__c payment: sPayments.get(sDate)) {
                                                                                                    
                        if (payment != null && payment.Total__c != null) {
                    
                            ccKey = payment.Card_Type__c + '<br/>' + payment.Name + '<br/>' + payment.Card_Holder_name__c;
                            cardID =  payment.Name + ' : ' + payment.Card_Holder_name__c;                           
                            payment.Total__c = payment.Total__c.setScale(2);                                        
                                       
                            //System.debug('ccKey=========='+ccKey);                 
                            //System.debug('creditCardID==========='+creditCardID +', card==========='+card);
                            
                            if ((creditCardID == 'ALL' && ccKey == card)|| (creditCardID==cardID && ccKey == card)) {
                        
                                // all payments for a given settlement date
                                dayCounter = dayCounter + 1;     
                                
                                currentCardTotal += payment.Total__c;
                                                            
                                if (chargeAmount.containsKey(cardID)) {                                                                 
                                    chargeAmount.put(cardID,chargeAmount.get(cardID) + payment.Total__c);                                   
                                } else {                                                            
                                    chargeAmount.put(cardID,payment.Total__c);                                  
                                }
                                                                              
                                if( currentCardTotal > 0) {
                                                                  
                                    remainder = math.mod(cardCount, 2);
                                    if( remainder == 0)
                                        lineColor = 'white';
                                    else
                                        lineColor = '#EEF8FD';
                                                        
                                    tempSummary += '<tr><td style="background-color:' + lineColor + '; text-align:left;vertical-align:top;padding:10px;padding-right:30px;">' + sDate.format() + '</td>';
                                  
                                    convertedNumber = dataController.convertToCurrency(chargeAmount.get(cardID).format());
                                    tempSummary += '<td style="background-color:' + lineColor +'; text-align:left;vertical-align:top;padding:10px;padding-right:30px;">' + '$' + convertedNumber + '</td></tr>';                                        
                                    
                                    summary = '<tr><td rowspan="'+ dayCounter + '" ' +
                                              'style="background-color:' + lineColor + '; text-align:left;vertical-align:middle;padding:10px;width:390px;">' + card + '</td>';
                                    
                                    summary += tempSummary + '</tr>';                                                                   
                                }
                                                                                         
                            }//card match
                        }//payment not null
                    }//all payments for the specific date
                    
               }
            }
            
            if( dayCounter > 0 && currentCardTotal > 0) {           
                chargeFullSummary.add(summary);
                              
                convertedNumber = dataController.convertToCurrency(currentCardTotal.format());
                grandTotal = grandTotal + currentCardTotal;
                              
                summary ='<td style="background-color:' + lineColor +'"> </td>';
                summary +='<td style="background-color:' + lineColor +'; text-align:left;vertical-align:top;border-top:1px #808285 solid;padding:10px;">Total</td>' +
                           '<td style="background-color:' + lineColor +'; text-align:left;vertical-align:top;border-top:1px #808285 solid;padding:10px;">' + '$' + convertedNumber +'</td>';
                chargeFullSummary.add(summary);
                
                cardCount = cardCount + 1;
                  
                summary = '<tr><td height="1" colspan="3" style="border-top: 1px solid #52BDEC;"></td></tr>';
                chargeFullSummary.add(summary);
                
            }
                                                                      
        }//for each settlement card     
        

        if( grandTotal > 0) {        
            convertedNumber = dataController.convertToCurrency(grandTotal.format());
            summary = summary + '<tr><td>&nbsp;</td><td>Total Amount To Be Charged</td><td>' + '$' + convertedNumber + '</td></tr>';            
            chargeFullSummary.add(summary);
            
            summary = '<td colspan="3" height="8" > </td>';
            chargeFullSummary.add(summary);            
        }                  
    }
    
    /*
    private void sortPayments() {
        if (sPayments == null) {
            sPayments = new Map<Date, List<Product_Order_Payment_gne__c>>();
        } else {
            sPayments.clear();
        }
        
        if (ccPayments == null) {
            ccPayments = new Map<String, List<Product_Order_Payment_gne__c>>();
        } else {
            ccPayments.clear();
        }
                
        if (creditCardsUsed == null) {
            creditCardsUsed = new Set<String>();
        } else {
            creditCardsUsed.clear();
        }
        Map<String,String> ccInfo = new Map<String,String>();
        
        if ((payments == null || payments.size() == 0) || (itemChargeDate == null || itemChargeDate.size() == 0)) {
                // set errorMessage here!!!
                //errorMessage = 'No order payment records found for display.';
                return;
        }
    
        
        // create map of payments based on settlement date
        // key = settlement date
        // value = List of payments for that date
        String cardID = null;
        List<Product_Order_Payment_gne__c> tempList = null;
        
        for(Product_Order_Payment_gne__c payment: payments){
            if (itemChargeDate.containsKey(payment.Order__r.Name)) {
                
                Date sDate = itemChargeDate.get(payment.Order__r.Name);
                if (sPayments.containsKey(sDate)) {
                    templist = sPayments.get(sDate);
                    templist.add(payment);
                    sPayments.put(sDate,templist);
                } else {
                    // new date not yet in the grid
                    List<Product_Order_Payment_gne__c> dPayment = new List<Product_Order_Payment_gne__c>();
                    dPayment.add(payment);
                    sPayments.put(sDate,dPayment);
                }
            
                cardID =  payment.Name + ' : ' + payment.Card_Holder_name__c;
                if (!creditCardsUsed.contains(cardID)) {
                    creditCardsUsed.add(cardID);
                    //String cardInfo = 'XXXX-XXXX-XXXX-' + payment.Name + '<br/>' + payment.Card_Type__c + '<br/>' + payment.Card_Holder_name__c;
                    String cardInfo =  payment.Name + '<br/>' + payment.Card_Type__c + '<br/>' + payment.Card_Holder_name__c;
                    ccInfo.put(cardID,cardInfo);
                }
            }
        }
        

        // create map of payments based on credit card
        // key = credit card last 4 digits and card holder name
        // value = List of payments for that credit card
        cardID = null;
        tempList = null;
        String ccKey = null;
        
        for(Product_Order_Payment_gne__c payment: payments){
            
            ccKey = payment.Card_Type__c + '<br/>' + payment.Name + '<br/>' + payment.Card_Holder_name__c;
                                
            if (ccPayments.containsKey(ccKey)) {
                
                templist = ccPayments.get(ccKey);
                templist.add(payment);
                ccPayments.put(ccKey,templist);
            } else {
                
                // new credit card not yet in the grid
                List<Product_Order_Payment_gne__c> dPayment = new List<Product_Order_Payment_gne__c>();
                dPayment.add(payment);
                ccPayments.put(ccKey,dPayment);
            }     
               
        }
                              
        // prepare select list for credit cards
        getCreditCardList();
        
        // establish credit card order as they will be displayed as columns
        if (ccList == null) {
            ccList = new Map<Integer,String>();
        } else {
            ccList.clear();
        }
        Integer i = 2;
        if (creditCardID == 'ALL') {
            for (String cc : creditCardsUsed) {
                ccList.put(i,cc);
                i = i + 1;
            }
        } else {
            ccList.put(i,creditCardID);
        }
        
        // now, separate charges for each CC for each settlement date
        Map<String,Double> chargeAmount = null;
        Set<Date> settlementDates = sPayments.keySet();
        
        // transfer dates in the Set to a List so that dates can be sorted (needed for the Excel download feature)
        List<Date> sortedSettlementDates = new List<Date>();
        for(Date uniqueDate : settlementDates) {
            System.debug('payment date============='+uniqueDate.format());
            sortedSettlementDates.add(uniqueDate);
        }
        sortedSettlementDates.sort();

        
        // sort charges by credit card        
        Set<String> settlementCards = ccPayments.keySet();
                
        List<String> sortedSettlementCards = new List<String>();
        for(String uniqueCard : settlementCards) {
            System.debug('adding credit card...................'+uniqueCard);
            sortedSettlementCards.add(uniqueCard);            
        }
        sortedSettlementCards.sort();
        
                
        if (fullSummary == null) {
            fullSummary = new List<String>();
        } else {
            fullSummary.clear();
        }
        
                       
        columnCount = ccList.size() + 2;
        String summary = '';
        Double dayTotal = 0;
        Double grandTotal = 0;
        
        summaryHeader = '<th "width=150">Expected<br/>Charge Date</th>';
        
                
        for (Integer j =2; j < columnCount; j++ ) {
            summaryHeader = summaryHeader + '<th>' + ccInfo.get(cclist.get(j)) + '</th>';
        }
        summaryHeader = summaryHeader + '<th "width=150">Total<br/>Amount To Be <br/>Charged</th>';
        summaryFooter = '<th>Total</th>';
        String convertedNumber = '';
        
        List<Double> cardTotal = new List<Double>();
        // loop over all the settlement dates
        Integer dayCounter = 0;
        for(Date sDate : sortedSettlementDates) {
            // all payments for a given settlement date
            dayCounter = dayCounter + 1;
            chargeAmount = new Map<String,Double>();
            for(Product_Order_Payment_gne__c payment: sPayments.get(sDate)) {
                
                payment.Total__c = payment.Total__c.setScale(2);
                if (payment != null && payment.Total__c != null) {
                    cardID =  payment.Name + ' : ' + payment.Card_Holder_name__c;
                    if (creditCardID == 'ALL' || creditCardID == cardId) {
                        if (chargeAmount.containsKey(cardID)) {
                            chargeAmount.put(cardID,chargeAmount.get(cardID) + payment.Total__c);
                        } else {
                            chargeAmount.put(cardID,payment.Total__c);
                        }
                    }
                }
            }
            summary = '<td style="background-color:#e6EEEE; border:1px #09c solid; text-align:left;">' + sDate.format() + '</td>';
            
            String chargeDetail = '';
            
            for (Integer j =2; j < columnCount; j++ ) {
                Double ccTotal = 0;
                if (chargeAmount.containsKey(cclist.get(j))) {
                    ccTotal = chargeAmount.get(cclist.get(j));
                    convertedNumber = convertToCurrency(ccTotal.format());
                    chargeDetail = chargeDetail + '<td>' + + '$' + convertedNumber  +  '</td>';
                    
                    dayTotal = dayTotal + ccTotal;
                } else {
                    ccTotal = 0;
                    chargeDetail = chargeDetail + '<td>$0.00</td>';
                }
                if (dayCounter == 1) {
                    cardTotal.add(ccTotal);
                } else {
                    cardTotal[j-2] = cardTotal[j-2] + ccTotal;
                }
                
                
            }
            grandTotal = grandTotal + dayTotal;
            summary = summary + chargeDetail;
            convertedNumber = convertToCurrency(dayTotal.format());
            summary = summary + '<td style="background-color:#e6EEEE; border:1px #09c solid;"><b>' + '$' + convertedNumber + '</b></td>';
            
            fullSummary.add(summary);
            dayTotal = 0;
            
        }
                        
        for ( Integer m =0; m < columnCount - 2; m++) {
            convertedNumber = convertToCurrency(cardTotal[m].format());
            summaryFooter = summaryFooter + '<th>' + '$' + convertedNumber + '</th>';
            
        }
        convertedNumber = convertToCurrency(grandTotal.format());
        summaryFooter = summaryFooter + '<th>' + '$' + convertedNumber + '</th>' ;
        
        // are there any payment records?
        if (fullSummary.size() == 0) {
            summaryHeader = '<th>No Payments records found for this account</th>';
            summaryFooter = '<th></th>';
        }
        
        
        
        if (chargeFullSummary == null) {
            chargeFullSummary = new List<String>();
        } else {
            chargeFullSummary.clear();
        }


        columnCount = 3;
        summary = '';
        dayTotal = 0;
        grandTotal = 0;
                
        pendingSummaryHeader ='<td width="200">Personal<br/>Information</td>';
        pendingSummaryHeader +='<td width="200">Expected<br/>Charge Date*</td>';
        pendingSummaryHeader +='<td width="200"><br/>Amount</td>';
        

        convertedNumber = '';
        
        cardTotal = new List<Double>();
        
        // loop over all the settlement card charges
                
        Integer cardCount = 0;
        Integer remainder = 0;
        String lineColor = '';
        Double currentCardTotal = 0;
        
        grandTotal = 0;
        for(String card : sortedSettlementCards) {
                    
            dayCounter = 1;                
            List<Product_Order_Payment_gne__c> curCardList = ccPayments.get(card);
                                                     
            if( curCardList.size() > 0 ) {

               String tempSummary = '';
               currentCardTotal = 0;
               
               Product_Order_Payment_gne__c paymentItem = curCardList[0];
                                                             
               for(Date sDate : sortedSettlementDates) {
                                        
                    System.debug('date================'+sDate.format());
                    chargeAmount = new Map<String,Double>();
                    
                    List<Product_Order_Payment_gne__c> paymentList = sPayments.get(sDate);
                    
                    Date prevDate = null;
                    for(Product_Order_Payment_gne__c payment: sPayments.get(sDate)) {
                                                                                                    
                        if (payment != null && payment.Total__c != null) {
                    
                            ccKey = payment.Card_Type__c + '<br/>' + payment.Name + '<br/>' + payment.Card_Holder_name__c;
                            cardID =  payment.Name + ' : ' + payment.Card_Holder_name__c;                           
                            payment.Total__c = payment.Total__c.setScale(2);                                        
                                       
                            System.debug('ccKey=========='+ccKey);                 
                            System.debug('creditCardID==========='+creditCardID +', card==========='+card);
                            
                            if ((creditCardID == 'ALL' && ccKey == card)|| (creditCardID==cardID && ccKey == card)) {
                        
                                // all payments for a given settlement date
                                dayCounter = dayCounter + 1;     
                                
                                currentCardTotal += payment.Total__c;
                                                            
                                if (chargeAmount.containsKey(cardID)) {                                                                 
                                    chargeAmount.put(cardID,chargeAmount.get(cardID) + payment.Total__c);                                   
                                } else {                                                            
                                    chargeAmount.put(cardID,payment.Total__c);                                  
                                }
                                                                              
                                if( currentCardTotal > 0) {
                                                                  
                                    remainder = math.mod(cardCount, 2);
                                    if( remainder == 0)
                                        lineColor = '#EDEDED';
                                    else
                                        lineColor = '#FFFFFF';
                                                        
                                    tempSummary += '<tr><td style="background-color:' + lineColor + '; text-align:left;vertical-align:middle">' + sDate.format() + '</td>';
                                  
                                    convertedNumber = convertToCurrency(chargeAmount.get(cardID).format());
                                    tempSummary += '<td style="background-color:' + lineColor +'; text-align:left;vertical-align:middle;padding-bottom:5px">' + '$' + convertedNumber + '</td></tr>';                                        
                                    
                                    summary = '<tr><td rowspan="'+ dayCounter + '" ' +
                                              'style="background-color:' + lineColor + '; text-align:left;vertical-align:middle">' + card + '</td>';
                                    
                                    summary += tempSummary + '</tr>';                                                                   
                                }
                                                                                         
                                /*                                                                                   
                                System.debug('dayCounter==============='+dayCounter);
                                if( currentCardTotal > 0) {
                                    
                                    remainder = math.mod(cardCount, 2);
                                    if( remainder == 0)
                                        lineColor = '#EDEDED';
                                    else
                                        lineColor = '#FFFFFF';
                                                        
                                    tempSummary += '<tr><td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">' + sDate.format() + '</td>';
                                      
                                    convertedNumber = convertToCurrency(chargeAmount.get(cardID).format());
                                    tempSummary += '<td style="background-color:' + lineColor +'; text-align:left;vertical-align:top;padding-bottom:5px">' + '$' + convertedNumber + '</td></tr>';                                        
                                    
                                    summary = '<tr><td rowspan="'+ dayCounter + '" ' +
                                              'style="background-color:' + lineColor + '; text-align:left;vertical-align:top">' + card + '</td>';
                                    
                                    summary += tempSummary + '</tr>';
                                }
                                //*
                    
                            }//card match
                        }//payment not null
                    }//all payments for the specific date
                    
               }
            }
            
            if( dayCounter > 0 && currentCardTotal > 0) {           
                chargeFullSummary.add(summary);
                              
                convertedNumber = convertToCurrency(currentCardTotal.format());
                grandTotal = grandTotal + currentCardTotal;
                              
                summary ='<td style="background-color:' + lineColor +'";> </td>';
                summary +='<td style="background-color:' + lineColor +'; text-align:left;vertical-align:top;border-top:1px #808285 solid;padding-top:10px;">Total</td>' +
                           '<td style="background-color:' + lineColor +'; text-align:left;vertical-align:top;border-top:1px #808285 solid;padding-top:10px;padding-bottom:10px">' + '$' + convertedNumber +'</td>';
                chargeFullSummary.add(summary);
                
                cardCount = cardCount + 1;
                  
                summary = '<td colspan="3" height="8" > </td>';
                chargeFullSummary.add(summary);
                
            }
                           

                
                /*
                cardID =  paymentItem.Name + ' : ' + paymentItem.Card_Holder_name__c;                
                //System.debug('creditCardID==============='+creditCardID+', current card======='+cardID);
                if (creditCardID == 'ALL' || creditCardID == cardId) {
                              
                    remainder = math.mod(cardCount, 2);
                    if( remainder == 0)
                        lineColor = '#EDEDED';
                    else
                        lineColor = '#FFFFFF';
                                    
                    // all payments for a given credit card                
                    dayCounter = dayCounter + 1;
                    chargeAmount = new Map<String,Double>();
                    Double currentCardTotal = 0;
                                                                                              
                    summary = '<tr><td rowspan="'+ totalItems + '" ' +
                              'style="background-color:' + lineColor + '; text-align:left;vertical-align:top">' + card + '</td>';
                                  
                    firstRow = true;
                    for(Product_Order_Payment_gne__c payment:  curCardListByDate) {
                                                      
                        payment.Total__c = payment.Total__c.setScale(2);
                        currentCardTotal += payment.Total__c;
                        if (payment != null && payment.Total__c != null) {
                              cardID =  payment.Name + ' : ' + payment.Card_Holder_name__c;
                                                          
                              if (creditCardID == 'ALL' || creditCardID == cardId) {
                                  if (chargeAmount.containsKey(cardID)) {
                                      chargeAmount.put(cardID,chargeAmount.get(cardID) + payment.Total__c);
                                  } else {
                                      chargeAmount.put(cardID,payment.Total__c);
                                  }                                                                        
                              }
                              
                              // use payment name to find settlement date
                              Date sDate = itemChargeDate.get(payment.Order__r.Name);
                                                  
                              summary += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">' + sDate.format() + '</td>';
                              
                              convertedNumber = convertToCurrency(payment.Total__c.format());
                              summary += '<td style="background-color:' + lineColor +'; text-align:left;vertical-align:top;padding-bottom:5px">' + '$' + convertedNumber + '</td>';                                        
                        }
                                                            
                        summary += '</tr>';
                          
                        if( firstRow )
                            firstRow = false;
                    }
                      
                    chargeFullSummary.add(summary);
                                  
                    convertedNumber = convertToCurrency(currentCardTotal.format());
                    grandTotal = grandTotal + currentCardTotal;
                                  
                    summary ='<td style="background-color:' + lineColor +'";> </td>';
                    summary +='<td style="background-color:' + lineColor +'; text-align:left;vertical-align:top;border-top:1px #808285 solid;padding-top:10px;">Total</td>' +
                               '<td style="background-color:' + lineColor +'; text-align:left;vertical-align:top;border-top:1px #808285 solid;padding-top:10px;padding-bottom:10px">' + '$' + convertedNumber +'</td>';
                    chargeFullSummary.add(summary);
                       
                    cardCount = cardCount + 1;
                      
                    summary = '<td colspan="3" height="8" > </td>';
                    chargeFullSummary.add(summary);
                                                                                                                  
                }//totalItems>0
                
                
                
            }//credit card match
            //*
                                          
        }//for each settlement card     
        

        if( grandTotal > 0) {        
            convertedNumber = convertToCurrency(grandTotal.format());
            summary = summary + '<tr><td></td><td>Total Amount To Be Charged</td><td>' + '$' + convertedNumber + '</td></tr>';            
            chargeFullSummary.add(summary);
            
            summary = '<td colspan="3" height="8" > </td>';
            chargeFullSummary.add(summary);            
        }                  
    }
    */
    
    
    private String convertToCurrency(String amount) {
        
        String newAmount;
        
        // matcher 1: e.g. 2355.5 
        // matcher 2: e.g. 2355.55
        Matcher dotMatcher1 = hasDecimal1.matcher(amount);
        Matcher dotMatcher2 = hasDecimal2.matcher(amount);
        dotMatcher1.lookingAt();
        dotMatcher2.lookingAt();
        if (dotMatcher1.lookingAt()) {
            newAmount = amount + '0';
        } else if (dotMatcher2.lookingAt()) {
            newAmount = amount;
        } else {
            newAmount = amount + '.00';
        }
            
        //debugMessage += 'old/new: ' + amount + '/' + newAmount + '<br/>';
        return newAmount;
    }
    
    public String getCurrentDateValue(){
        return currentDateValue;
    }
    
    private void clearErrorMessages() {
        if (errorMessage != null) {
            errorMessage = '';
        }
        if (criticalError != null) {
            criticalError = '';
        }
    }
    
    public PageReference searchAccounts() {
        PageReference pageRef = System.currentPageReference();
        searchAccountField = pageRef.getParameters().get('searchAccountField');
        this.accountID = null;
        this.searchMessage='';
        this.updateAccountDropdownList();
        //updateAccountsList();
        //searchAccountField = null;
        return null;
    }
    
    public PageReference showAllAccounts() {
        PageReference pageRef = System.currentPageReference();
        searchAccountField = null;
        this.searchMessage='';
        this.accountID = null;
        this.updateAccountDropdownList();
        //updateAccountsList();
        
        return null;
    }
    
    /*
    * process menu/tab selection from VF pages
    */
    public PageReference doCommercialOrder() {
        return doOperation(1);      
    }   
        
    public PageReference doChargeSummary () {
        return doOperation(2);      
    }
    
    public PageReference doOrderSummary () {
        return doOperation(3);      
    }
    
    public PageReference doAccountProfile () {
        return doOperation(4);      
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
       
     public PageReference doInvoiceReport () {
      return doOperation(9);      
    }
    
    
    // pass all Sample related parameters to Commercial
    private PageReference doOperation(Integer operation) {

       // System.debug('calling doOperation, operation ==================' + operation);
        
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
        
        if( sampleAccountId != null && sampleAccountId.length() > 0) {

      // pass sample account id
            page.getParameters().put('sid', sampleAccountId);
            page.getParameters().put('du', 'true');
             page.getParameters().put('oid', sampleOrderId);  
        }
        if(GNE_LWO_Controller.getAdminUser() && this.accountID != null){
            page.getParameters().put('accountID', accountID);
        }
        if(operation==3 || operation==9)
        page.setRedirect(true);
        else
        page.setRedirect(false);
        return page;                                                
    }
    
    public Boolean getSampleEnrolled() {
      
      System.debug('sampleAccountId================='+sampleAccountId);
      Boolean acctStatus = null;
      if( sampleAccountId != null && sampleAccountId.length() > 0)
        acctStatus = true;
      else
        acctStatus = false;
        
      System.debug('acctStatus=======' + acctStatus);
      return acctStatus;
    }    
    
    public PageReference doSample() {
      
        System.debug('calling ProductOrderAsyncEntryController.doSample for account=====' + sampleAccountId + '................');
        
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
          if(GNE_LWO_Controller.getAdminUser() && this.accountID != null)
                nextPage.getParameters().put('accountID', this.accountID);                                                                   
          nextPage.setRedirect(false);                              
          return nextPage;
    }
    
    return null;        
            
    }               
    
public boolean updateAccountDropdownList(){
    this.searchMessage='Here search message';
    this.allAcntOptions = new List<List<SelectOption>>();
    
    //only retrive account lists when it's null or empty
    if(this.allAcntForDropdown==null ||this.allAcntForDropdown.size()<=0){
        if(GNE_LWO_Controller.getAdminUser()){
            this.allAcntForDropdown = dataController.getAccountsForAdmin();
            if(this.allAcntForDropdown == null || this.allAcntForDropdown.size()<=0 || 
                this.allAcntForDropdown.get(0)== null ||this.allAcntForDropdown.get(0).size()<=0){
                    criticalError = 'You are not affiliated with any account to place a web order. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
                    log.save('Error: No accounts found for user', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
                    return false;
                }
            System.debug('******Get '+this.allAcntForDropdown.size()+' account list');
        }else{
            List<Account> acnts=dataController.getAccounts();
            if(acnts == null || acnts.size()<=0) {
                criticalError = 'You are not affiliated with any account to place a web order. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
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
    this.debugMessage +='need to search account for '+this.searchAccountField;
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
                            foundAccountCount++;
                            so.add(new SelectOption(acc.Id, acc.Name+' ('+acc.SAP_ID_gne__c+' )'));
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
    
        public boolean getEnableSampleOrderTab(){
        if(this.getSampleEnrolled()==false || (GNE_LWO_Controller.getAdminUser()==true)){
            return false;
        }   else {
                return true;
        }
    }
}