/* Controller for GNE_LWO_OrderEntry, GNE_LWO_OrderDetail, GNE_LWO_OrderConfirm, GNE_LWO_OrderPayment,
* GNE_LWO_OrderReview, GNE_LWO_SubmitOrder
*
* 4/6/11  FL - Deleted getHomepageMessage()
* 4/12/11 FL - Added getInfo() and logging
*
*/
public virtual without sharing class ProductOrderAsyncEntryController {

    public class OrderItemInformation{
        public  String productDesc{get; set;}
        public String fullTotalPrice{get;set;}
        public Decimal quantity{get;set;}
        public String itemPrice{get;set;}
        public String taxPrice{get;set;}
       
        public OrderItemInformation(String productDesc,String fullTotalPrice,String itemPrice,String taxPrice,Decimal quantity)
        {
            this.productDesc = productDesc;
            this.fullTotalPrice = fullTotalPrice;
            this.quantity = quantity;
            this.itemPrice = itemPrice;
            this.taxPrice = taxPrice;
        }
    }
    public static GNE_LWO_Logger log = new GNE_LWO_Logger();
    
    public  static ProductDataController dataController = null;
    public  static ProductOrderController orderController = null;
    
    static GneProductOrderGetAccountInfo.AccountInfo accountInfo = null;
    public static GneProductOrderSimulateOrder.SimulateOrder simulateOrder = null;

    static GneProductOrderCreateOrderAsync.CreateOrderAsync createOrder = null;
    static GneProductOrderCancelOrder.CancelOrder cancelOrder = null;
    static String PENDING_STATUS_ID = GNE_LWO_Controller.INPROCESS_STATUS_ID;
    static String OPEN_STATUS_ID = GNE_LWO_Controller.OPEN_STATUS_ID;
    static String SHIPPED_STATUS_ID = GNE_LWO_Controller.SHIPPED_STATUS_ID;    
    static final Long REQUEST_TIME_OUT = 60 * 1000;
    public String acctID = null;
    public String acctIndicator = null;
     public String accountconemail {get;set;}
    //Member variables
    public List<OrderItemInformation> orderItems = new List<OrderItemInformation>();
    public Boolean waitingForResponse {get; set;}
    public integer counter {get; set;}
    public String requestSenderId {get; set;}
    public String packingSlipPdf {get;set;}
    public String attachmentPdf {get;set;}
    //protected Async_Request_gne__c asyncRequest = null;
    protected List<Async_Request_gne__c> asyncRequest = null;
    protected Long requestStartTime = 0;
    protected Long requestEndTime = 0;
    
    protected Product_Order_gne__c order = null;
    protected Product_Order_Price_gne__c price = null;
    protected Product_Order_Item_gne__c item = null;
    protected Product_Order_Address_gne__c billingAddress = null;
    protected Product_Order_Address_gne__c shippingAddress = null;
    
    protected String accountID;
    
    protected List<Map<String,String>> creditCards = null;
    
    protected List<Product_Order_Payment_gne__c> orderPayments = null;
    protected List<Product_Order_Payment_gne__c> orderPaymentsKeep = null;
    protected List<Product_Order_Item_gne__c> items = null;
    
    protected List<Product_Order_Price_gne__c> prices = null;    

    protected Boolean encrypted = true;
    
    protected Map<String, Map<String,String>> shippingAddresses = null;
    
    protected String currentDateValue = null;
    protected List<SelectOption> accountOptions = null;
    protected List<SelectOption> productionOptions = null;
    protected List<SelectOption> shipAddressOptions = null;
    
    protected String billToAddress = null;
    protected String shipToAddress = null;
    protected String productName = null;
    protected String productDesc = null;
    protected Decimal productListPrice = null;
    protected String NDC;
    protected String addressValue = null;
    
    protected String orderNumber = null;
    protected String billToName = null;
    protected String billToAccountNumber = null;
    protected String searchAccountField = null;
    
    protected String sapOrderId = null;
    protected String itemIdFromHistory = null;
    
    // History page search filters - passed in with Detail page viewing
    public String selectedStatus = null;
    public String selectedSearchField = null;
    public String selectedFrom = null;
    public String selectedTo = null;

    protected String criticalError = null;
    protected String errorMessage = null;
    protected String paymentError = null;
    public String debugMessage;
    protected String searchMessage  = null;
    protected String ccExpMessage = null;
    
    
    protected String balanceColor = '#000';
    protected String balanceMsg = 'Select "Continue" and review your order';
    
    protected Datetime currentTime = null;
    protected Date currentDate = null;
    protected String profileName = null;
    
    public Boolean sampleEnrolled;
    public String sampleAccountId {get; set;}
    public String sampleOrderId {get; set;}     
    public String isDesigneeUser {get; set;}
    
    public boolean canPlaceOrder {get; set;}
    public boolean firstView {get; set;}
    public Integer paymentTerm {get; set;}
    public String createOrderMessage {get; set;}
    public String cancelMessage {get; set;}
    public Boolean driveChangeByQuantity {get; set;}
    public Boolean searchOptionOn {get; set;}
    public Integer expiredcccount {get;set;}
    public Boolean disableInput {get; set;} 
    //public Boolean disableChargemeNow{set;}      
    public boolean debug {set; get;}
    //A list of all LWO account lists
    protected List<List<Account>> allAcntForDropdown;
    protected Account selectedAccount;
    protected List<List<SelectOption>> allAcntOptions = null;
    protected List<CreditCard_Storage> ccstore =new List<CreditCard_Storage>();
    protected Map<String,CreditCard_Storage> ccstore_map=new Map<String,CreditCard_Storage>();
    
    Product_Order_Item_gne__c priceHolder = null;
    Product_Order_Payment_gne__c totalPayment = null;
    
    protected boolean enableSampleOrderTab = false;
    public boolean commercialAccount{get; set;}
    public boolean debugOn{get; set;}
    public boolean haspackingslip{get;set;}
    public boolean hasAttachment{get;set;}
    public boolean renderPrintDoc{get;set;}
    
    public Boolean getDisableChargemeNow(){
    	if(this.item==null || this.order==null ) getInfo();
            //Display_Text__c
        if(this.canPlaceOrder && item!=null && order!=null && (item.Status__r.Name =='SHIPPED' && order.order_category__c=='Commercial' && 
              (item.Expected_Settlement_Date__c!=null && item.Expected_Settlement_Date__c > system.today()) && 
              (order.payment_term_changed__c==false || (order.payment_term_changed__c==true && order.payment_term_change_date__c<system.today()))
             )){
               return false;
         }
            
         return true;
    }

    static {
        dataController = new ProductDataController();
        orderController = new ProductOrderController();
        
        accountInfo = new GneProductOrderGetAccountInfo.AccountInfo();
        simulateOrder = new GneProductOrderSimulateOrder.SimulateOrder();
        createOrder = new GneProductOrderCreateOrderAsync.CreateOrderAsync();
        cancelOrder = new GneProductOrderCancelOrder.CancelOrder();
    }
    
    // response message containing SAP credit card number
    // e.g. -PMOS-6037-00001000000025 Invalid Credit Card
    // group(1) = 6037
    // group(2) = 'Invalid Credit Card'
    
    protected Pattern ccPattern = Pattern.compile('\\-[A-Z]\\w{3}\\-(\\d{4})\\-\\w+ ?(.*)$');
    
    // group(1) = cc number
    // group(2) = trailing message
    // group(3) = last 4 digits of cc number
    
    protected Pattern numbersOnlyPattern = Pattern.compile('(\\d+(\\d{4})) ?(.*)$');
    
    // group(1) = last 4 digits
    protected Pattern numbersOnly = Pattern.compile('\\d+(\\d{4})$');
    
    /*
    Default constructor
    */
    public ProductOrderAsyncEntryController(){ 
        
        haspackingslip=false;
        hasAttachment = false;
        renderPrintDoc = false;
        PageReference pageRef = System.currentPageReference();
        String selAccountId=pageRef.getParameters().get('accountID');
        if (selAccountId != null && selAccountId.trim().length()>0) {
            accountID = selAccountId.trim();
            system.debug('------------------------Inside constructor account Id'+accountID);
        setacctID(accountID);
        setAcctIndicator(accountID);
        }
        
    }

    /*
* Called when GNE_LWO_OrderEntry page loads
*/
    public void getInfo() {
        this.debugOn=false;
        debug = true;
        //this.debugMessage = 'here I debug';
        log.addLine('Entered ProductOrderAsyncEntryController.getInfo()');

        // First check to see if this is invoked with the right entry point or not
        PageReference pageRef = System.currentPageReference();
        String url = pageRef.getUrl();
        log.addLine('url=' + url);
        
        
        //check if sample parameter are passed          
        sampleAccountId = pageRef.getParameters().get('sid');
        sampleOrderId = pageRef.getParameters().get('oid');   
        isDesigneeUser = pageRef.getParameters().get('du');
        
        if (sampleAccountId != null && sampleAccountId.length() > 0)
        sampleEnrolled = true;
        else                  
        sampleEnrolled = false;
        
        // Is this even possible?
        if (!url.contains('/GNE_LWO_OrderEntry') && !url.contains('/GNE_LWO_OrderDetail')) {
            //User tries to enter order entry process from a wrong entry point
            criticalError = 'Please click "Order" link on the top to start web ordering';
            logObjectContent();
            log.save('ERROR: Invalid URL entry', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            return;
        }
        
        //Check user profile to enforce whether user can place orders or not
        canPlaceOrder = !GNE_LWO_Controller.getAdminUser();
        
        //Jie code
        if(GNE_LWO_Controller.getAdminUser()){
            this.searchOptionOn = true;
        }
        
        driveChangeByQuantity = false;
        
        currentDate = System.Today();
        currentTime = System.Now();
        currentDateValue = currentTime.format('MMM d, yyyy');
        
        priceHolder = new Product_Order_Item_gne__c();
        totalPayment = new Product_Order_Payment_gne__c();
        totalPayment.Total__c = 0;
        totalPayment.Quantity__c = 0;
        
        //Order Loaded Already, no need to do anything
        if (order != null) {
            log.logDebug('Exit getInfo: Page already loaded for SAP Order=' + order.SAP_ORDER_ID__C);
            return;
        }
        
        // from () 
        String orderId = pageRef.getParameters().get('id');
        selectedStatus = pageRef.getParameters().get('selectedStatus');
        selectedSearchField = pageRef.getParameters().get('selectedSearchField');
        selectedFrom = pageRef.getParameters().get('selectedFrom');
        selectedTo = pageRef.getParameters().get('selectedTo');
        
        if (orderId != null) {
            order = orderController.getOrderByOrderId(orderId, false);
            if (order == null)
            log.addLine('orderController.getOrderByOrderId(' + orderId + ') returned null');
            else
            log.addLine('orderController.getOrderByOrderId(' + orderId + ') returned SAP Order=' + order.SAP_Order_ID__c);
            
            // retrieve price data
            prices = [select Condition_Class__c, Condition_Type__c, Total_Price__c, Unit_Price__c from Product_Order_Price_gne__c where Order__r.Id = :orderId];
        }
       //Populate new order if parameter is not passed in to retrieve existing order failed to retrieve order by id or name
        if (order == null) {
            log.addLine('Creating new order');
            
            order = orderController.createNewOrder();
            item = orderController.initLineItem();
            
            // Default selected account
            String selectedAccountId=pageRef.getParameters().get('accountID');
            if (selectedAccountId != null && selectedAccountId.trim().length()>0) {
                order.Bill_To__c = selectedAccountId.trim();
                accountID = selectedAccountId.trim();
                this.debugMessage += 'accountID passed from Home page is '+this.accountID;
                system.debug( 'accountID passed from Home page is '+this.accountID);
            }
            
            System.debug('reaching here in disablechargemenow');
            //check to enable or disable charge me now
            /*disableChargemeNow = true;
            //Display_Text__c
            if(this.canPlaceOrder && ( item.Status__r.Name =='SHIPPED' && order.order_category__c=='Commercial' && 
              (item.Expected_Settlement_Date__c!=null && item.Expected_Settlement_Date__c > system.today()) && 
              (order.payment_term_changed__c==false || (order.payment_term_changed__c==true && order.payment_term_change_date__c<system.today()))
             )){
                disableChargemeNow=false;
            }
            
            else disableChargemeNow=true;*/
            if(!this.updateAccountDropdownList()) return;
            
            //Get Product Info
            updateProductInfo();
            
            firstView = true;
            if (!updateBillToRelated())
            return;

            // If existing order found
        } else {                        
            populateOrderInfoForExistingOrder(orderId);
            /*List<Attachment> att = [select id from Attachment where parentid=:order.Id limit 1];
            system.debug('-------------------------att-------------------------------------'+att);
            if(att.size()>0){
                haspackingslip=true;
                packingSlipPdf=att[0].id;
                
            }*/
            getorderdoc();  
            if(!hasAttachment || acctIndicator == 'SAM')
            {
                renderPrintDoc = true;
            }
        }
              
        log.logDebug('Exit getInfo');
        return;
    }
    
  //  print order method
  
    public void getorderdoc(){
    
    if(order != null)
    {
        system.debug('----------------------orderNumber----------------------------------'+orderNumber);
        List<Order_Email__c> orderEmailList = [select id from Order_Email__c where Order_Number__c =:order.SAP_Order_ID__c and hasAttachment__c =:true and Email_Type__c =: 'ORD'];
        system.debug('---------Order Email List-------' + orderEmailList);
        if(orderEmailList.size() > 0)
        {
            List<Attachment> att = [select id from Attachment where parentid=:orderEmailList.get(0).Id limit 1];
            system.debug('-------------------------att-------------------------------------'+att);
            if(att.size()>0)
            {
                hasAttachment = true;
                attachmentPdf = att[0].id;
                system.debug('---------Attachment pdf-------' + attachmentPdf);                
            }
        }
        orderEmailList = [select id from Order_Email__c where Order_Number__c =:order.SAP_Order_ID__c and hasAttachment__c =:true and Email_Type__c =: 'PACK'];
        system.debug('---------Order Email List-------' + orderEmailList);
        if(orderEmailList.size() > 0)
        {
            List<Attachment> att = [select id from Attachment where parentid=:orderEmailList.get(0).Id limit 1];
            system.debug('-------------------------att-------------------------------------'+att);
            if(att.size()>0)
            {
                haspackingslip=true;
                packingSlipPdf=att[0].id;               
            }
        }
    }
   
    
      
     
    // orderNumber      
    
    }
   
   // print packing slip doc

    /*
    Populate account dropdown
    */
    public List<SelectOption> getAccounts(){        
        //return accountOptions;
        if(this.allAcntForDropdown !=null && this.allAcntForDropdown.size()>0)      
        return this.allAcntOptions.get(0);
        else return new List<SelectOption>();
    }
    
    public Integer getAccountCount() {                  
        return accountOptions.size();
    }
    
    /*
* Populate order info
*/
    public void populateOrderInfoForExistingOrder(String existingOrderId){     
        log.addLine('Entered populateOrderInfoForExistingOrder(' + existingOrderId + ')');
        
        /*                                    
    if (!updateAccountsList()) {
        return;
    }
    */
        
        if(!this.updateAccountDropdownList())     return;                
        //Populate order info    
        billToName = order.Bill_To__r.Name;
        orderNumber = order.Name;    
        billToAccountNumber = order.Bill_To__r.SAP_ID_gne__c;
        driveChangeByQuantity = false;
        
        //Select order payments
        items = orderController.getOrderItems(existingOrderId);
        log.addLine('orderController.getOrderItems returned ' + items.size() + ' records');
        
        
        if (item == null && items.size() > 0) {
            item = items[0];
            
            productName = items[0].Product__r.Name;
            productDesc = items[0].Product__r.description_vod__c;
            productListPrice = items[0].Product__r.List_Price_gne__c;
        }
        
        orderPayments = new List<Product_Order_Payment_gne__c>();
        system.debug('----orderPayments');
        List<Product_Order_Payment_gne__c> oldPayments = orderController.getOrderPayments(existingOrderId);
        if (oldPayments != null && oldPayments.size()>0) {
            log.addLine('orderController.getOrderPayments returned ' + oldPayments.size() + ' records');
            
            if (oldPayments.get(0).Quantity__c != null) {
                driveChangeByQuantity=true;
            }
            
            for (Product_Order_Payment_gne__c payment : oldPayments) {
                orderPayments.add(payment.clone(false));
            }
            
        } else {
            log.addLine('orderController.getOrderPayments returned 0 records');
        }
        
        //Get Product Info
        updateProductInfo();
        
        //Construct Bill To Address 
        List <Product_Order_Address_gne__c> orderAddresses
        = [select Id, Name, Order__r.Name, Address_Line_2__c, Address_Line_4__c, City__c,  State__c, Zip__c, Zip_4__c, Country__c, Billing__c
        from Product_Order_Address_gne__c where Order__c = :existingOrderId];
        log.addLine(orderAddresses.size() + ' addresses found for order=' + existingOrderId);
        
        for (Product_Order_Address_gne__c address:orderAddresses) {
            if(address.Billing__c){
                this.billToAddress = dataController.constructAddressForDisplay(address);
            } else {
                this.shipToAddress = dataController.constructAddressForDisplay(address);
            }
            orderNumber = address.Order__r.Name;
        }
        
        log.addLine('Exit populateOrderInfoForExistingOrder');
    } 

    /*
* Update account selection list
*/
    public boolean updateAccountsList(){
        log.addLine('Entered updateAccountsList())');
        
        List<Account> accounts = dataController.getAccounts();
        if (accounts == null || accounts.size() == 0) {
            criticalError = 'You are not affiliated with any account to place a web order. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
            logObjectContent();
            log.save('Error: No accounts found for user', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
            return false;
        }
        
        log.addLine('dataController.getAccounts() returned ' + accounts.size() + ' accounts');
        
        if (accountOptions == null) {
            accountOptions = new List<SelectOption>();
        } else {
            accountOptions.clear();
        }
        String accountNumber = null;
        searchMessage = '';
        
        // If account search string entered
        if (searchAccountField != null && searchAccountField != 'all' && searchAccountField != '') {
            log.addLine('search accounts matching <' + searchAccountField + '>');
            
            for (Account account : accounts) {
                if (account.Name.toLowerCase().contains(searchAccountField.toLowerCase())
                        || account.SAP_ID_gne__c.contains(searchAccountField)) {
                    
                    if (order.Bill_To__c == null) {
                        order.Bill_To__c = account.Id;
                    }
                    
                    accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')' ));
                }
            }
            
            if (accountOptions.size() > 0) {
                String suffix  = (accountOptions.size() == 1) ? '' : 's';
                searchMessage = '<b>' + accountOptions.size() + '</b> account' + suffix + ' found';
            } else {
                searchMessage = 'No account found matching <b>"' + searchAccountField + '"</b>';
                log.addLine('No accounts match search string');
            }
        }
        
        // If search string not specified or no accounts match search string, list all accounts
        if (accountOptions.size() == 0) {
            for (Account account : accounts) {            
                if (order.Bill_To__c == null) {
                    order.Bill_To__c = account.Id;
                }
                
                accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')'));
            }
        }                
        log.addLine('account selection list size=' + accountOptions.size());
        
        // need to change the size to be 10
        if (searchOptionOn == null && accountOptions.size() >= 10) {
            searchOptionOn = true;
        }
        
        log.addLine('Exit updateAccountsList returning true');
        return true;      
    }
    
    public PageReference searchAccounts() {     

        PageReference pageRef = System.currentPageReference();
        searchAccountField = pageRef.getParameters().get('searchAccountField');
        
        this.accountID = null;
        this.order.Bill_To__c =null;
        this.updateAccountDropdownList();
        //updateAccountsList();
        //searchAccountField = null;
        return null;
    }
    
    public PageReference showAllAccounts() {            

        PageReference pageRef = System.currentPageReference();
        searchAccountField = null;
        //updateAccountsList();
        this.updateAccountDropdownList();
        return null;
    }
    
    
    /*
* Bill To Account Changed
*/
    public PageReference billToChanged(){         
        log.clear();
        log.addLine('Entered ProductOrderAsyncEntryController.billToChanged()');

        addressValue = null;
        billingAddress = null;
        shippingAddress = null;
        
        firstView = true;
        
        //clear previous payments
        orderPayments = null;
        system.debug('----orderPayments472');
        
        //Update BillTo related info
        if (!updateBillToRelated())
        return null;
        
        log.logDebug('Exit billToChanged'); 
        return null;
    }
    
    /*
* Update Bill to Related Information, including
* -Shipping Address
* -Billing Address
* -Account Name, Email
*/
    protected boolean updateBillToRelated(){        
        log.addLine('Entered updateBillToRelated()');
        
        String accountId  = (order.Bill_To__c!=null)?order.Bill_To__c:null;
        clearError();
        
        if (accountId == null) {
            //No billto has selected for the order
            errorMessage += 'No account has been selected for this order. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
            logObjectContent();
            log.save('Error: No account ID selected', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            return false;
        }
        
        this.accountID = accountId;
        
        // Get account information
        billToAccountNumber = accountId;
        Account acctInfo = dataController.getAccountInfoForID(accountId);
        log.addLine('dataController.getAccountInfoForID(' + accountId + ') returned SAP ID=' + acctInfo.SAP_ID_gne__c);
        
        if (acctInfo.SAP_ID_gne__c == null || acctInfo.SAP_ID_gne__c == '') {
            logObjectContent();
            //log.save('ERROR: Order missing SAP ID', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
            errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;    
            return false;
        }
        
        if (!getSAPAccountInfo(acctInfo, 1))
        return false;
        
        log.addLine('Exit updateBillToRelated returning true');
        
        return true;
    }
    
    protected boolean getSAPAccountInfo(Account acctInfo, Integer attempt) {
    
               
        String commercialNoCard= '<i>This account has not been set up for credit card payments. Please contact a LUCENTIS Direct Customer Specialist at '+
        '<font color=\'#326E8F\'><u>800.963.1778</u></font>'+' for assistance.</i>';
        
        String nonCommercialNoCard='<i>Thank you for your interest in commercial LUCENTIS.<br/></br>'+
        'You currently have a LUCENTIS Sampling account. To order commercial LUCENTIS, you need to enable a LUCENTIS Direct account. Please download and complete the LUCENTIS Direct <a href="http://www.lucentisdirect.com/LucentisDirect/pdfs/newToProgram.pdf'+
        '"> New Account Setup form.</a>. Be sure to provide a physical signature, then fax it to '+
        '<font color=\'#326E8F\'><u>877.329.6737</u></font>.<br/><br/>'+
        'Once your forms are processed, you will receive a LUCENTIS Commercial Enrollment Confirmation, and you will be ready to start ordering from LUCENTIS Direct.</i>';
        
        String commercialCardExpried='<i>Your credit card on file is expired. Please contact a LUCENTIS Direct Customer Specialist at '+
        '<font color=\'#326E8F\'><u>800.963.1778</u></font> for assistance.</i>';
        
        system.debug('<br/>Enter getSAPAccountInfor method</br>');
        log.addLine('Entered getSAPAccountInfo(acctInfo=' + acctInfo.SAP_ID_gne__c + ', attempt=' + attempt + ')');

        try {
            message = '';
            Matcher ccMatcher = null;
            Boolean ccMatched = null;
            this.criticalError = null;
            boolean sapReturnError = false; 
            this.errorMessage=null;  
            
            //Jie - Should be set to false once SAP add accountIndicator value to all accounts in SAP
            commercialAccount=false;
            
            GneProductOrderGetAccountInfo.AccountInfoResponseItem[] responseItems = accountInfo.accountInfo(acctInfo.SAP_ID_gne__c, 'S');
            
            
            if (responseItems == null || responseItems.size() == 0) {
                system.debug( 'getSAPAccountInfor: responseItems is null or responseItems.size() = 0</br>');
                logObjectContent();
                log.save('ERROR: accountInfo.accountInfo() returned 0 responses', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
                this.criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
                return false;
            }
            log.addLine('accountInfo.accountInfo() returned ' + responseItems.size() + ' records');
            
            system.debug( 'getSAPAccountInfor: responseItems.size() ='+responseItems.size()+' records<br/>');
            
            shippingAddresses = new Map<String, Map<String,String>>();       
            if (shipAddressOptions == null){
                shipAddressOptions = new List<SelectOption>();
            } else {
                shipAddressOptions.clear();
            }
            
            creditCards = new List<Map<String,String>>();
            String paymentTermString; 
          
            
            // Loop through each account
            for(GneProductOrderGetAccountInfo.AccountInfoResponseItem response:responseItems){
                
                System.debug('response items&&'+ response);
                //this.debugMessage +='************Here comes one response items ***************<br/>';
                String responseType = response.ResponseItemType;
                String status = response.Status;
                log.addLine('response type=' + responseType + ': status=' + status+ ': SAP message - '+response.message);

                if (status == null || status.trim().length()<=0) {
                    status = 'true';
                }
                
                //give a default value for responseType in case SAP return null responseType, which should never happen
                if(responseType == null) responseType='';

                system.debug( 'response type=' + responseType + ': status=' + status+': SAP response message - '+response.message+'</br>');
                this.debugMessage += 'response type=' + responseType + ': status=' + status+': SAP response message - '+response.message+'</br>';
                //commen out by Jie
                if (status != 'true') {
                    
                    sapReturnError = true;
                    billToAddress = '';
                    criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
                    
                    logObjectContent();
                    if (response.Message != null && response.Message.length() > 0 ) {
                        log.save('ERROR: ' + response.Message, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    } else {
                        log.save('ERROR: status!=true but no error message returned in webservice response', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    }
                    return false;
                }
                
                //this.debugMessage +=' before account type |';
                
                if (responseType == 'account') {
                    if(response.accountIndicator!=null){
                        
                        if (response.accountIndicator=='BTH' || response.accountIndicator=='COM' ) {
                            commercialAccount=true;
                        }else {
                            commercialAccount=false;
                            this.criticalError = nonCommercialNoCard;
                            return false;
                        }
                    }
                    
                    else if(response.accountIndicator==null)
                    {
                        commercialAccount=false;
                        this.criticalError=GNE_LWO_Controller.GENERIC_ERROR_MSG;
                        return false; 
                    }
                    //this.debugMessage +=' after indicator |';
                    
                    
                    System.debug('***********Account Indicator'+ response.accountIndicator);
                    //this.debugMessage +=' before billToName |';
                    billToName = response.accountName;
                    
                    
                    System.debug('account con email *&^'+ accountconemail);
                    //this.debugMessage +=' after billToName |';
                    order.Order_Contact_Email__c = response.contactEmail;
                    paymentTermString = response.defaultPaymentTerm.trim();
                    
                    system.debug( 'payment term string is '+paymentTermString+' | ');
                    
                    //this.debugMessage +=' before payment term |';
                    // paymentTermString = 'Z080' for cash payment termf
                    if (paymentTermString == null
                            || paymentTermString.length() == 0
                            || paymentTermString.startsWith('Z')) {
                        paymentTerm = -1;
                    } else if (paymentTermString == 'CC') {
                        paymentTerm = 60;
                    } else {
                        paymentTermString = (paymentTermString).split('CC',2)[1];
                        if (paymentTermString == '00') {
                            paymentTerm = 0;
                        } else {
                            paymentTerm = Integer.valueOf(paymentTermString);
                        } 
                    }
                    system.debug( 'payment term is '+paymentTerm+' | ');
                    log.addLine('SAP payment term=' + response.defaultPaymentTerm + ', payment term=' + paymentTerm);
                    //this.debugMessage +=' after payment term |';                            
                } else if (responseType == 'address') {
                    //this.debugMessage +=' in address |';
                    // create a map of address data
                    Map<String,String> responseAddress = new Map<String,String>();
                    responseAddress.put('id',response.addressNo);
                    responseAddress.put('name',response.addressLine1);
                    responseAddress.put('name2',response.addressLine4);
                    responseAddress.put('line2',response.addressLine2);
                    responseAddress.put('city',response.city);
                    responseAddress.put('state',response.state);
                    responseAddress.put('zip',response.zipCode);
                    responseAddress.put('country',response.country);
                    
                    if (response.billing) {
                        //System.debug('billing->phone and fax ^^^^^^^^^&&&&&&&&&&&&***********'+response.phone+' %%%%%%%%%%%%%%%%%%%%%%%'+ response.fax);
                        
                        log.addLine(response.addressLine1 + ' is billing address');
                        //this.debugMessage +='Billing ';
                        billingAddress = dataController.populateAddress(responseAddress,true);
                        this.billToAddress = dataController.constructAddressForDisplayMap(responseAddress);
                        
                    } else {
                        this.debugMessage +='Shipping ';
                        //System.debug('shipping->phone and fax ^^^^^^^^^&&&&&&&&&&&&***********'+response.phone+' %%%%%%%%%%%%%%%%%%%%%%%'+ response.fax);
                        
                        shippingAddresses.put(response.addressNo,responseAddress);
                        shippingAddress = dataController.populateAddress(responseAddress,false);
                        //shipAddressOptions.add(new SelectOption(response.addressNo, dataController.constructAddressForSelect(responseAddress)));
                        shipAddressOptions.add(new SelectOption(response.addressNo, dataController.constructDisplayAddressForSelect(responseAddress)));
         
                        if(addressValue == null && response.preferredShipToFlag!=null && (response.preferredShipToFlag=='X' || response.preferredShipToFlag=='x')){
                            addressValue=response.addressNo;
                            this.shipToAddress = dataController.constructAddressForDisplayMap(responseAddress );
                        } 
                        
                        if(addressValue != null && addressValue==response.addressNo)  {
                            this.shipToAddress = dataController.constructAddressForDisplayMap(responseAddress);
                        }   
                        
                        //this.debugMessage += ' ship to address string '+  shipToAddress+' | ';   
                    }
                    
                    //this.debugMessage +='address: '+response.addressNo+' '+response.addressLine1+' '+response.addressLine2+' '+response.addressLine4+' '+response.zipCode+'</br>';
                    
                } else if (responseType == 'creditcard') {
                    System.debug('CC Number'+ response);
                    Map<String,String> responseCC = new Map<String,String>();
                    responseCC.put('number',response.cardNumber);
                    this.debugMessage += 'Card num: '+response.cardNumber;
                    responseCC.put('type',response.cardType);
                    responseCC.put('expirationDate',response.expirationDate);
                    //responseCC.put('expirationDate','2012-03-31');
                    string temp='';
                    if(response.cardHolder!=null) temp=response.cardHolder.replace('%','-');
                    responseCC.put('holder',temp);
                    creditCards.add(responseCC);
                    
                    //this.debugMessage += 'getSAPInfor: credit card number - '+response.cardNumber+' '+'expirationDate '+response.expirationDate+'';
                }
                //this.debugMessage +='*****end of this response item ******</br></br>';
            }  // for reponseItems loop
            
            // there are no shipping addresses associated with the chosen account
            if (shipAddressOptions == null || shipAddressOptions.size() == 0) {
                if(this.errorMessage ==null || this.errorMessage.trim().length()<=0){
                    log.logDebug('WARNING: SAP ID ' + acctInfo.SAP_ID_gne__c + ' missing shipping address');
                    errorMessage = 'This account does not have any shipping addresses set up.  Please contact a LUCENTIS Customer Specialist  at 800.963.1778 for assistance';
                    
                }
                this.criticalError = errorMessage;
                return false;       
            }

            // default payment term is cash
            if (paymentTerm < 0 ) {
                log.logDebug('WARNING: SAP ID ' + acctInfo.SAP_ID_gne__c + ' negative payment term found. paymentTerm = '+paymentTerm);
                if(commercialAccount)
                errorMessage = commercialNoCard;
                else errorMessage = nonCommercialNoCard;
                this.criticalError = errorMessage;
                //debugMessage += 'debug **** '+errorMessage;
                return false;       
            }
            
            if(creditCards == null || creditCards.size() == 0){
                //this.criticalError = commercialNoCard;
                this.errorMessage = 'You do not have an active credit card on file. Please add a credit card to Your Account.';
                //return false;
            }
            
            Integer chargeableCardCount;
            
            chargeableCardCount = initializePayments();
            // there are no credit cards associated with the chosen account
            if ((creditCards != null && creditCards.size() > 0)&&(chargeableCardCount == 0)) {
                errorMessage = commercialCardExpried;
                log.logDebug('WARNING: SAP ID ' + acctInfo.SAP_ID_gne__c + ' has no credit cards on file');
                //return false;       
            }
            
            if(chargeableCardCount>0 && expiredcccount>0)
            ccExpMessage = commercialCardExpried;
            
            
            
            //unhandled error from SAP response items
            if(sapReturnError == true){
                if(errorMessage == null && this.criticalError==null){
                    this.errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
                    this.debugMessage += 'unhandled error happens';
                }
                criticalError = errorMessage;
                return false;
            }
            
        } catch (Exception e) {
            message = e.getMessage();
            system.debug( ' here exception '+message+'|');
            // Retry once if timed out
            if (attempt == 1 && e.getMessage().toLowerCase().indexOf('timed out') > 0) {
                log.addLine(e.getMessage());
                return getSAPAccountInfo(acctInfo, 2);
            }

            logObjectContent();
            log.save('ERROR getSAPAccountInfo Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
            errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            this.criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            return false;
        }
        
        log.addLine('Exit getSAPAccountInfo returning true');
        
        system.debug(this.debugMessage += ' getSAPInfo done successfully |');
        
        return true;
    }
    
    /*
* Update Product Info
*/
    protected void updateProductInfo() {
        log.addLine('Entered updateProductInfo');

        try {
            //Get Product Info
            Product_vod__c matchedProduct = null;
            productionOptions = new List<SelectOption>();
            List<Product_vod__c> products = dataController.getProducts();
            log.addLine('dataController.getProducts returned ' + products.size() + ' records');

            for (Product_vod__c product : products) {
                if (item.Product__c == product.Id) {
                    matchedProduct = product;
                }
                
                productionOptions.add(new SelectOption(product.Id, product.Name));
            }
            
            if (matchedProduct == null) {
                //Set default value to the first product
                matchedProduct = products[0];
            }
            
            item.Product__c = matchedProduct.Id;
            this.NDC = products[0].NDC_Number_gne__c;
            this.productName = matchedProduct.Name;
            this.productDesc = matchedProduct.Description_vod__c;
            this.productListPrice = matchedProduct.List_Price_gne__c;
            
        } catch (Exception e) {
            logObjectContent();
            log.save('ERROR updateProductInfo Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            throw e;
        }
        
        log.addLine('Exit updateProductInfo');
    }

    /* 
* prepare for Step #2 - Payment. Called when Continue button pressed
*/
    public PageReference gotoPayment() {
        log.clear();
        log.addLine('Entered ProductOrderAsyncEntryController.gotoPayment()');
        
        clearError();
        // simulte order before going on to Step #2, payment screen
        if (simulateOrder(1)) {
            // validate the order part, but not the payment
            // however, if reorder, validate payment as well
            if (!validateOrder(false)) {
                return null;
            }
            
            updateCCInfo(true);

            PageReference paymentPage = new PageReference('/apex/GNE_LWO_OrderPayment');
            paymentPage.setRedirect(false);
            log.logDebug('Exit gotoPayment returning GNE_LWO_OrderPayment');
            return paymentPage;
        }
        
        // SimulateOrder returned false
        PageReference entryPage = new PageReference('/apex/GNE_LWO_OrderEntry');
        entryPage.setRedirect(false);
        log.logDebug('Exit gotoPayment returning GNE_LWO_OrderEntry');
        return entryPage;
    }
    
    public PageReference gotoFinalSubmitOrder() {
        log.addLine('Entered ProductOrderAsyncEntryController.gotoFinalSubmitOrder()');      
        clearError();
        
        PageReference submitOrderPage = new PageReference('/apex/GNE_LWO_SubmitOrder');
        submitOrderPage.setRedirect(false);
        
        log.logDebug('Exit gotoFinalSubmitOrder returning ' + submitOrderPage.getUrl());
        return submitOrderPage;        
    }
    
    /*
* Initialize available credit cards and prepopulate payment entry for each
*/
    protected Integer initializePayments() {

        log.addLine('Entered initializePayments()');
        orderPayments = new List<Product_Order_Payment_gne__c>();
        // any credit cards to init?
        if (creditCards == null || creditCards.size() == 0) {
            log.addLine('Exit initializePayments returning 0 - No credit cards on file');
            return 0;
        }
        
        log.addLine(creditCards.size() + ' credit cards on file');
        
        System.debug('CREDIT CARDS ON FILE ---------'+ creditCards.size());
        
        system.debug('----orderPayments919');
        expiredcccount=0;                    
        Boolean defaultSet = false;
        Product_Order_Payment_gne__c payment = null;

        Pattern x = Pattern.compile('-');
        Matcher nonEncryptedCC;
        List<Product_Order_Payment_gne__c> chargeableCards = new List<Product_Order_Payment_gne__c>();

        for (Map<String,String> cc :  creditCards) {
            // Example credit card numbers from SAP 
            // encrypted: -E803-4448-B000000000P
            // plain text: 0123456789012345
            payment = new Product_Order_Payment_gne__c();
            
            if (currentDate.daysBetween(Date.valueOf(cc.get('expirationDate'))) > -120) {        
                nonEncryptedCC = numbersOnly.matcher(cc.get('number'));
                if (nonEncryptedCC.matches()) {
                    // accept unencrypted value only in UAT
                    /*if (GNE_LWO_Controller.ENDPOINT.contains('sfdcproxy-ua') ||
                            GNE_LWO_Controller.ENDPOINT.contains('sfdcproxy-dev'))*/
                   if(GNE_LWO_Logger.ENV=='UAT' || GNE_LWO_Logger.ENV=='DEV') { 
                        payment.Name = nonEncryptedCC.group(1);
                        encrypted = false;
                        log.addLine('NOT encrypted card number=' + payment.Name);
                    } else {
                        continue;
                    }
                    
                } else {
                    String[] ccNumber = x.split(cc.get('number'));
                    payment.Name = ccNumber[2];
                    log.addLine('Encrypted card number=' + payment.Name);
                }
                
                payment.sapCardToken__c = cc.get('number');
                payment.Card_Holder_Name__c = cc.get('holder');
                payment.Card_Type__c = cc.get('type');
                payment.Expiration_Date__c = Date.valueOf(cc.get('expirationDate'));
                //payment.expirationDateString__c = String.valueOf(Date.valueOf(cc.get('expirationDate')));
                payment.Quantity__c = null;
                payment.Total__c = 0;
                
                orderPayments.add(payment);
                
                system.debug('currentDate.daysBetween(payment.Expiration_Date__c) is '+currentDate.daysBetween(payment.Expiration_Date__c)+' : ');
                system.debug( 'paymentTerm is '+paymentTerm+'<br/>');
                
                // keep track of cards that are chargeable
                //if (currentDate.daysBetween(payment.Expiration_Date__c) >= paymentTerm) 
                
                if (currentDate.daysBetween(payment.Expiration_Date__c) >= 0) {
                    chargeableCards.add(payment);
                    this.debugMessage += 'add one chargeable card <br/>';
                } else {
                    expiredcccount++;
                    log.addLine('Card not chargable. Expiration Date=' + payment.Expiration_Date__c);
                }
            }
        }
        
        return chargeableCards.size();                    
    }
    
    /*
* Update credit card level info
*/
    protected void updateCCInfo(Boolean ignoreZeroQuantity){
        log.addLine('Entered updateCCInfo(ignoreZeroQuantity=' + ignoreZeroQuantity + ')');        
        
        totalPayment.Quantity__c = 0;
        totalPayment.Total__c = 0;
        clearError();
        
        Integer totalPayments = null;
        if (orderPayments != null) {
            totalPayments = orderPayments.size();
            log.addLine('totalPayments=' + orderPayments.size());  
            
            if (totalPayments > 0) {
                for(Product_Order_Payment_gne__c payment:orderPayments){            
                    if (driveChangeByQuantity) {
                        //if (currentDate.daysBetween(payment.Expiration_Date__c) <=59) {
                        if (currentDate.daysBetween(payment.Expiration_Date__c) < paymentTerm) {
                            payment.Quantity__c = 0;
                        }
                        if (payment.Quantity__c == null) {
                            payment.Quantity__c = 0;
                        } else {
                            payment.Quantity__c = Math.roundToLong(payment.Quantity__c);
                        }
                        
                        payment.Total__c = (payment.Quantity__c / item.Quantity__c) * order.Total__c;
                        totalPayment.Quantity__c = totalPayment.Quantity__c + payment.Quantity__c;
                    } else {                     
                        if(totalPayments>1) {
                            payment.Quantity__c = null;
                        } else {
                            totalPayment.Quantity__c = payment.Quantity__c;
                        }
                        
                        if (payment.Total__c == null) {
                            payment.Total__c = 0;
                        }
                        
                        if (currentDate.daysBetween(payment.Expiration_Date__c) < paymentTerm) {
                            payment.Total__c = 0;
                        }
                    }
                    
                    totalPayment.Total__c = totalPayment.Total__c + payment.Total__c;
                }
            }
        }  
        
        if (!driveChangeByQuantity && totalPayments > 1) {
            totalPayment.Quantity__c = null;
        } 
        
        // decide whether we should enable user to submit an order or remove a payment              
        this.balanceColor = '#000';
        this.balanceMsg = 'Select "Continue" and review your order';
        
        if (orderPayments != null && orderPayments.size()>0) {  
            //Use Net Price to store price diff 
            if (totalPayment.Total__c == null) {
                totalPayment.Total__c = 0;
            }     
            if (order.Tax__c == null) {
                order.Tax__c = 0;
            }
            if (item.Quantity__c == null) {
                item.Quantity__c = 0;
            }     
            if (priceHolder.Net_Price__c == null) {
                priceHolder.Net_Price__c  = 0;
            }
            
            // Payment obj doesn't have Net_Price__c field anymore!   
            // Use priceHolder.Total for delta balance   
            priceHolder.Total__c  = (order.Total__c  - totalPayment.Total__c).setScale(2);
            if (priceHolder.Total__c > 0) {
                this.balanceColor = 'red';
                this.balanceMsg = 'enter an additional ';
            } else if (priceHolder.Total__c < 0){
                this.balanceColor = 'red';
                this.balanceMsg = 'subtract ';        
            } 
            priceHolder.Total__c = priceHolder.Total__c.abs();
        } 
        
        log.addLine('Exit updateCCInfo');        
    }       

    /*
    This method is used to decide whether we should enable user to submit an order or remove a payment
    */
    protected void updateOrderSaveStatus(){
        
        this.balanceColor = '#000';
        this.balanceMsg = 'Select "Continue" and review your order';
        
        if(orderPayments!=null && orderPayments.size()>0) {
            
            
            //Use Net Price to store price diff 
            if(totalPayment.Total__c==null){
                totalPayment.Total__c = 0;
            }
            
            if(order.Tax__c==null){
                order.Tax__c = 0;
            }
            if(item.Quantity__c==null){
                item.Quantity__c = 0;
            }
            
            if(priceHolder.Net_Price__c ==null){
                priceHolder.Net_Price__c  = 0;
            }
            
            /* Payment obj doesn't have Net_Price__c field anymore!   
                Use priceHolder.Total for delta balance
            */        
            
            priceHolder.Total__c  = (order.Total__c  - totalPayment.Total__c).setScale(2);
            if (priceHolder.Total__c > 0) {
                this.balanceColor = 'red';
                this.balanceMsg = 'enter an additional ';
            } else if (priceHolder.Total__c < 0){
                this.balanceColor = 'red';
                this.balanceMsg = 'subtract ';
                
            } 
            priceHolder.Total__c = priceHolder.Total__c.abs();
        }                      
    }
    
    /*
* validate order
*/
    protected boolean validateOrder(boolean validatePayment) {
        log.addLine('Entered validateOrder(validatePayment=' + validatePayment + ')');

        clearError();
        
        if (order.Bill_To__c == null) {
            errorMessage = 'Order bill to account must be selected first';
        } else if (billingAddress == null) {
            errorMessage = 'A "Bill To" address must be selected first';
        } else if (shippingAddress == null) {
            errorMessage = 'A "Ship To" address must be selected first';
        }
        
        item.Quantity__c = Math.roundToLong(item.Quantity__c);
        if (item.Unit_Price__c == null) {
            logObjectContent();
            log.save('ERROR: Order item unit price is null', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
            errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            return false;
        }
        
        item.Net_Price__c = item.Unit_Price__c * item.Quantity__c;
        
        orderPaymentsKeep = new List<Product_Order_Payment_gne__c>();
        if (validatePayment) {
            if (orderPayments == null || orderPayments.size()==0) {
                errorMessage += 'You must select at least one payment method for this order<br/>';
            } else {
                //Integer i = 0;
                totalPayment.Total__c = 0;
                //Check CC level quantity match and price match
                for(Product_Order_Payment_gne__c payment:orderPayments){
                    if (driveChangeByQuantity) {
                        payment.Quantity__c = Math.roundToLong(payment.Quantity__c);
                        
                        if (totalPayment.Quantity__c != null)
                        totalPayment.Quantity__c = totalPayment.Quantity__c + payment.Quantity__c;
                        else
                        totalPayment.Quantity__c = payment.Quantity__c;
                    }
                    totalPayment.Total__c = totalPayment.Total__c + payment.Total__c;
                    if (payment.Total__c != null && payment.Total__c > 0) {
                        orderPaymentsKeep.add(payment);
                    }
                }
                
                if (orderPaymentsKeep.isEmpty() ) { 
                    paymentError = paymentError + 'Total charges on credit card do not match the order price.<br/>'; 
                } 
                
                if (!driveChangeByQuantity) {
                    totalPayment.Quantity__c = null;
                }
            }
        }
        
        if (paymentError!='' || errorMessage!='') {
            log.logDebug('Exit validateOrder returning false');
            return false;
        }
        
        log.addLine('Exit validateOrder returning true');
        return true;
    }
    
    /*
* Simulate order
* Invoked between Step #1 and Step #2
*/
    protected Boolean simulateOrder(Integer attempt) {
        log.addLine('Entered simulateOrder(attempt=' + attempt + ')');
        
        try{
            message = '';
            
            prices = new List<Product_Order_Price_gne__c>();
            
            //Populate request object
            GneProductOrderSimulateOrder.SimulateOrderRequestItem[] requestItems = new GneProductOrderSimulateOrder.SimulateOrderRequestItem[2];
            
            //Set order level request
            GneProductOrderSimulateOrder.SimulateOrderRequestItem requestItem = new GneProductOrderSimulateOrder.SimulateOrderRequestItem();
            
            Account acctInfo = dataController.getAccountInfoForID(order.Bill_To__c);
            log.addLine('dataController.getAccountInfoForID(' + order.Bill_To__c + ') returned SAP ID=' + acctInfo.SAP_ID_gne__c);   
            
            requestItem.requestItemType='order';
            requestItem.billToId = acctInfo.SAP_ID_gne__c;
            requestItem.shipToId = addressValue;
            requestItems[0] = requestItem;
            
            //set line level request 
            requestItem = new GneProductOrderSimulateOrder.SimulateOrderRequestItem();
            requestItem.requestItemType='lineitem';
            requestItem.productNDC= NDC;
            
            requestItem.quantity = String.valueOf(item.Quantity__c.intValue());
            requestItems[1] = requestItem;
            
            log.addLine('Simulate order billToId=' + requestItems[0].billToId + ', shipToId=' + requestItems[0].shipToId
            + ', productNDC=' + requestItems[1].productNDC);   
            GneProductOrderSimulateOrder.SimulateOrderResponseItem[] simulateOrderResponseItems = simulateOrder.simulateOrder(requestItems);
            
            if (simulateOrderResponseItems == null ||simulateOrderResponseItems.size() == 0) {
                
                logObjectContent();
                log.save('ERROR: simulateOrder returned no reponses', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;        
                return false;
            }
            log.addLine('simulateOrder returned ' + simulateOrderResponseItems.size() + ' responses');
            
            for (GneProductOrderSimulateOrder.SimulateOrderResponseItem response:simulateOrderResponseItems) {
                String responseType = response.ResponseItemType;
                String status = response.Status;
                log.addLine('responseType=' + responseType + ' status=' + status);
                System.debug('$$$$$$$$$$$$$status**********'+status+'$$$$$response message '+response.Message);
                if (status == null) {
                    status = 'true';
                }
                
                if (status != 'true') {
                    errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
                    
                    logObjectContent();
                    if (response.Message != null && response.Message.length() > 0 ) {
                        log.save('ERROR: ' + response.Message, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    } else {
                        log.save('ERROR: status!=true but no error message returned in webservice response', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    }
                    
                    return false;
                }

                if (responseType == 'order') {
                    order.Tax__c = (Decimal.valueOf(response.Tax)).setScale(2);
                    order.Total__c = (Decimal.valueOf(response.Total) + order.Tax__c).setScale(2);
                    log.addLine('Total=' + order.Total__c + ' tax=' + order.Tax__c);

                } else if (responseType =='lineitem') {
                    item.Net_Price__c = (Decimal.valueOf(response.NetPrice)).setScale(2);
                    item.Unit_Price__c = (Decimal.valueOf(response.NetPrice)).setScale(2) / item.Quantity__c;
                    item.Tax__c = (Decimal.valueOf(response.LineTax)).setScale(2);
                    item.Total__c = item.Unit_Price__c * item.Quantity__c;
                    log.addLine('net=' + item.Net_Price__c + ' price=' + item.Unit_Price__c + ' tax=' + item.Tax__c + ' total=' + item.Total__c);
                    
                    if (item.Unit_Price__c == null || item.Unit_Price__c == 0) {
                        logObjectContent();
                        log.save('ERROR: Order line item missing unit price', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
                        errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
                        return false;                                
                    }
                    
                    message += 'net:' + response.NetPrice + ' subtotal:' + response.SubTotal + 'tax:' + response.LineTax + 'quan:' + item.Quantity__c;
                    item.Expected_Delivery_Date__c = Date.valueOf(response.ExpectedDeliveryDate);
                    item.Expected_Ship_Date__c = Date.valueOf(response.ExpectedShippingDate);
                    item.Expected_Settlement_Date__c = Date.valueOf(response.ExpectedSettlementDate);

                } else if (responseType == 'discitem') {
                    // price item                                    
                    price = new Product_Order_Price_gne__c();
                    
                    price.Condition_Class__c = response.priceTypeClass;
                    price.Condition_Type__c = response.priceTypeCode;
                    price.Unit_Price__c = Double.valueOf(response.priceTypeUnitPrice);   
                    price.Total_Price__c = Double.valueOf(response.priceTypeTotalPrice);
                    price.Description__c = response.priceTypeDesc;
                    
                    prices.add(price);                            
                }
            } // for loop
            
        } catch (Exception e) {
            message = e.getMessage();
            //Only retry for the first time
            if (attempt == 1 && e.getMessage().toLowerCase().indexOf('timed out') > 0) {
                log.addLine(e.getMessage());
                return simulateOrder(2);
            }
            
            logObjectContent();
            log.save('ERROR SimulateOrder Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
            
            return false;
        }
        
        log.addLine('Exit simulateOrder returning true');
        return true;
    }
    
    /*
Go to order review
*/
    public PageReference submitOrder() {
        log.addLine('Entered ProductOrderAsyncEntryController.submitOrder()');
        
        //validate the order part and the payment
        if(!validateOrder(true)){
            log.logDebug('Exit submitOrder failing validation');
            return null;
        }
        
        Datetime currentTime = System.Now();
        Date currentDate = System.Today();
        Integer currentHour = Integer.valueOf(currentTime.format('HH'));
        
        shippingAddress = dataController.populateAddress(shippingAddresses.get(addressValue),false);          
        shipToAddress = dataController.constructAddressForDisplayMap(shippingAddresses.get(addressValue));
        
        //Create Account Name String value
        Account billToAccount = [select Name, SAP_ID_gne__c from Account where id =:order.Bill_To__c];
        billToName = billToAccount.Name;
        billToAccountNumber = billToAccount.SAP_ID_gne__c;
        log.addLine('billToAccountNumber=' + billToAccountNumber);
        
        //PageReference confirmPage = new PageReference('/apex/ProductOrderReview');
        PageReference confirmPage = new PageReference('/apex/GNE_LWO_OrderReview');
        confirmPage.setRedirect(false);
        
        log.logDebug('Exit submitOrder returning ' + confirmPage.getUrl());
        return confirmPage;
    }
    
    /*
Save Order: Need to insert:
- order
- item
- payments
- billing & shipping addresses
*/
    public PageReference save() {
        log.addLine('Entered ProductOrderAsyncEntryController.save()');
        
        //clearError();
        if(orderPayments==null || orderPayments.size()==0){
            logObjectContent();
            log.save('ERROR: Missing orderPayments', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            errorMessage = 'No order payment has been specified. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
            return null;
        }
        
        system.debug( 'orderPayments size '+orderPayments.size());
        
        //Generate sender Id
        requestSenderId = UserInfo.getUserId() + System.now().getTime() + String.ValueOf(Math.RoundToLong(Math.Random()*10));
        log.addLine('requestSenderId=' + requestSenderId);        
        
        // create order in SAP
        
        
        Boolean successfulOrder = createOrder();
        System.debug('successfull order ------------->'+successfulOrder);
        this.debugMessage += 'successfulOrder '+successfulOrder;
        if (!successfulOrder){
            
            return null;
        }
        
        
        
        
        PageReference nextPage= Page.GNE_LWO_OrderConfirm;
        nextPage.setRedirect(false);
        
        log.logDebug('Exit save returning ' + nextPage.getUrl());
        return nextPage; 
    }
    
    public void cancelOrder() {
        system.debug('-----------Inside cancel order ');
        Product_Order_Code_Lookup_gne__c cancelledCodeInfo = [select id, Display_Text__c from Product_Order_Code_Lookup_gne__c where Name = 'CANCELLED' limit 1];
        cancelOrderSAP(cancelledCodeInfo, 1);
    }
    
    
    public void cancelOrderSAP(Product_Order_Code_Lookup_gne__c cancelledCodeInfo, Integer attempt) {
        system.debug('-----------Inside cancel order SAP');       
        log.clear();
        log.addLine('Entered ProductOrderAsyncEntryController.getcancelOrderSAP(attempt=' + attempt + ')');
        
        try{
            
            message = '';
            cancelMessage = ''; 
            GneProductOrderCancelOrder.CancelOrderResponseItem  responseItem = cancelOrder.cancelOrder(order.SAP_Order_ID__c, '', 'true');
            
            String status = responseItem.Status;
            if(status==null){
                status='true';
            }
            
            if (status == 'syserror') {
                logObjectContent();
                log.save('ERROR: cancelOrder(' + order.SAP_Order_ID__c + ') returned syserror status', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
                cancelMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;                
                
            } else if (status == 'false') {
                String userMessage;
                if (responseItem.Message.contains('Delivery Completed')) {
                    userMessage = 'Your order is already being processed for delivery and cannot be cancelled at this time.';
                } else {
                    userMessage = 'Your order cannot be cancelled.';
                }
                cancelMessage = userMessage + '<br/>If you have questions, please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778.';
                
            } else {
                // update order item status
                Savepoint sp = Database.setSavepoint();
                try {                    
                    item.Status__c = cancelledCodeInfo.id;
                    update item;
                    //cancelMessage = 'Order Changed Successfully: Order ' + order.SAP_Order_ID__c + ' has been cancelled successfully. ' ;
                    cancelMessage = 'Your order is being cancelled at this time. If you have questions, please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778';
                    
                    items = orderController.getOrderItems(order.Id);
                    item = items[0];
                    if(debug){
                        debugMessage += 'New item status : ' + item.Status__r.Display_Text__c;
                    }
                } catch (Exception u) {
                    Database.rollback(sp);
                    errorMessage = u.getMessage();
                    
                }
            }
        } catch(Exception e) {
            message = e.getMessage();
            if(attempt==1){
                //Only retry for the first time
                if(message.toLowerCase().indexOf('timed out')>0){
                    log.addLine(e.getMessage());
                    cancelOrderSAP(cancelledCodeInfo, 2);
                    return;
                }
            }
            
            logObjectContent();
            log.save('ERROR cancelOrderSAP Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
            cancelMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            if(debug){
                debugMessage += 'ERROR: failed to Cancel order in SAP : ' + message;
            }
            
        }        
    }
    
    /*
    Save Async Request
    */
    protected boolean startRequest(){
        try{
            
            waitingForResponse = true;
            counter = 0;
            requestStartTime = System.Now().getTime();
            return true;
        }
        catch(Exception e){
            errorMessage = 'Failed to save request: ' + e.getMessage();
            return false;
        }
    }
    
    public PageReference checkRequestStatus(){
        
        asyncRequest=new List<Async_Request_gne__c>();
        boolean isSuccessful=true;
        boolean isCreditcardwritten=true;
        String paymenterror_header='<table>'
        +'<tr>'
        +'<td width="100px">Card Type</td>'
        +'<td width="200px">Card Number</td>'
        +'<td width="100px">Card Holder\'s<br/> Name</td>'
        +'<td width="100px">Exp. Date</td>'
        +'</tr>'
        +'<tr>'
        +'<td colspan=4><hr  width=100%></hr></td>'
        +'</tr>';
        String paymenterror_footer='</table>';
        System.debug('size of order payments before '+ orderpaymentsKeep.size());
        log.addLine('Entered ProductOrderAsyncEntryController.checkRequestStatus()');
        
        
        if(!waitingForResponse){
            log.logDebug('Exit checkRequestStatus - waitingForResponse=false');
            //Not waiting for response, do nothing
            return null;
        }
        
        requestEndTime = System.Now().getTime();
        if(REQUEST_TIME_OUT > 0 && ((requestEndTime - requestStartTime) > REQUEST_TIME_OUT)){
            completeRequest();
            criticalError = 'Your order has timed out.  DO NOT resubmit the order.  Please check your order history in 10 minutes to determine if your order has been successfully placed.  You may also contact us at 800.963.1778 between 9am and 8pm ET, Monday to Friday for assistance. Thank you.';
            logObjectContent();
            log.save('ERROR: Order timed out', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
            return null;
        }
        counter ++;
        List <Async_Request_gne__c> requests = [select Id, Request_Status__c,  Request_Message__c, Response_For__c,Credit_Card_Number__c from Async_Request_gne__c where Request_Sender__c =: requestSenderId];
        
        
        // system.debug('****CHECKING AGAINST ASYNC_REQUEST TABLE '+ requests.size()+'  ID'+requests[0].id);
        if (requests != null) {
            debugMessage += 'checkStatus : request size: ' +  requests.size() + ' for ' + requestSenderId + '<br/>';
            
        } else {
            debugMessage += 'checkStatus : request size: NULL for ' + requestSenderId + '<br/>';
        } 
        
        System.debug('request size '+ requests.size());
        if(requests.size()>0){
            System.debug('entered here1 -->');
            asyncRequest = requests;
            for(integer i=0;i<asyncRequest.size();i++)
            log.addLine('asyncRequest.Request_Status__c=' + asyncRequest[i].Request_Status__c);
        }
        else {
            asyncRequest = null;
            log.addLine('asyncRequest=null');
        }
        
        
        
        
        if(requests.size()>0){
            for(Integer i=0;i<asyncRequest.size();i++){
                if(asyncRequest!=null &&  asyncRequest[i].Request_Status__c != 'Request Sent'){
                    if(asyncRequest[i].Request_Status__c != 'Successful'){
                        
                        try{       
                            String requestMessage = asyncRequest[i].Request_Message__c;
                            
                            
                            String creditcardNum = asyncRequest[i].Credit_Card_Number__c;
                            debugMessage += 'message:' + requestMessage + '<br/>';
                            
                            
                            System.debug('Error occured at credit card authorization checkpoint');
                            
                            
                            
                            if(i==0)    
                            {     
                                
                                if(creditcardNum==null || creditcardNum.length()<=0)
                                {
                                    isSuccessful=false;
                                    paymentError=requestMessage;
                                    break;
                                }                              
                                paymentError =paymenterror_header+'<tr>'+'<td width="100px">'+ccstore_map.get(creditcardNum).cardType+'</td>'
                                +'<td width="200px">'+ccstore_map.get(creditcardNum).cardNumber+'</td>'
                                +'<td width="100px">'+ccstore_map.get(creditcardNum).cardHolder+'</td>'
                                +'<td width="100px">'+String.valueof(ccstore_map.get(creditcardNum).cardExpDate)+'</td>'+'</tr>'
                                +paymenterror_footer+'<br/>'+ requestMessage;
                            }                                    
                            else
                            paymentError=paymentError+'<br/><br/><br/>'+paymenterror_header+'<tr>'+'<td width="100px">'+ccstore_map.get(creditcardNum).cardType+'</td>'
                            +'<td width="200px">'+ccstore_map.get(creditcardNum).cardNumber+'</td>'
                            +'<td width="100px">'+ccstore_map.get(creditcardNum).cardHolder+'</td>'
                            +'<td width="100px">'+String.valueof(ccstore_map.get(creditcardNum).cardExpDate)+'</td>'+'</tr>'
                            +paymenterror_footer+'<br/>'+ requestMessage;
                            isSuccessful=false;
                            
                        }
                        
                        
                        catch(Exception e)
                        {
                            
                            System.debug('Error occured while displaying error message');
                            
                            paymentError=asyncRequest[0].Request_Message__c;
                            
                            isSuccessful=false;
                            break;
                            
                        }
                    }
                }
            }
            
            if(!isSuccessful){ 
                
                System.debug('payment error---->'+ paymentError);
                completeRequest();
                
                logObjectContent();
                log.save('ERROR: ' + paymentError, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                //System.debug('size of order payments after '+ orderpaymentsKeep.size());
                
                return null;
            }

            if(issuccessful && asyncRequest!=null)
            {
                // Order creation is successful
                String orderId = asyncRequest[0].Response_For__c;
                
                System.debug('order id is '+ orderId);
                
                //Retrieve updated order information from local database
                Product_Order_gne__c updatedOrder = orderController.getOrderByOrderId(orderId, false);                  
                
                //Update order item
                List <Product_Order_Item_gne__c> items = orderController.getOrderItems(orderId);
                
                //extract just the payment records with charges against it
                List<Product_Order_Payment_gne__c> keep = new List<Product_Order_Payment_gne__c>();
                for(Product_Order_Payment_gne__c payment:orderPayments) {
                    
                    System.debug('m reaching here checkpost1, Order Id -->'+ orderId);
                    payment.Order__c = orderId;
                    payment.Expiration_Date__c = null;
                    System.debug('m reaching here checkpost2, Order Id -->'+ orderId);
                    if(payment.Total__c!=null && payment.Total__c > 0 ){
                        keep.add(payment);
                    }
                }      
                if (!keep.isEmpty() ) { 
                    orderPayments.clear();
                    for(Product_Order_Payment_gne__c p : keep) {
                        orderPayments.add(p);
                    }
                }  
                
                /*
                * jan 5 2009 : spark: don't update/insert; let ESB finish the transactions
                *
                if (updatedItem.Status__r.Name == 'INCOMPLETE') {
                        debugMessage = 'item status INCOMPLETE - adding payment and address <br/>';
                        updatedItem.Status__c = PENDING_STATUS_ID;
                        updatedItem.Quantity__c = item.Quantity__c;
                        updatedItem.Unit_Price__c = item.Unit_Price__c;
                        update updatedItem;
                        
                        item = null;
                        item = updatedItem;
                        
                        // insert addresses
                        billingAddress.Order__c = orderId;
                        billingAddress.Billing__c = true;
                        shippingAddress.Order__c = orderId;
                        insert billingAddress;
                        insert shippingAddress;
                        
                        // insert payments
                        for(Product_Order_Payment_gne__c payment:orderPayments) {
                            insert payment;
                        }                        
                }
                * 
                *
                */
                
                // Update item status
                /*
                updatedItem.Status__c = PENDING_STATUS_ID;
                updatedItem.Quantity__c = item.Quantity__c;
                updatedItem.Unit_Price__c = item.Unit_Price__c;
                updatedItem.Total__c = item.Quantity__c * item.Unit_Price__c;
                */
                //update updatedItem;
                /*
                item = null;
                item = updatedItem;
                */
                
                /*
                updatedOrder.Order_Contact_Email__c = order.Order_Contact_Email__c;
                updatedOrder.Ordered_By__c = UserInfo.getFirstName() + ' '+ UserInfo.getLastName();
                updatedOrder.Ordered_On__c = System.Now();
                */
                
                // Update order
                //#fwang: fixed a Null pointer exception by adding checking order object
                
                System.debug('before entering into danger area ');
                try{
                    if( order != null) {
                        
                        System.debug('entered in danger area ');
                        updatedOrder.Bill_To__c = order.Bill_To__c;
                        updatedOrder.Order_Contact_Email__c = order.Order_Contact_Email__c;
                        updatedOrder.Total__c = order.Total__c;
                        System.debug('i never reach here ');
                        update updatedOrder;
                    }
                }
                
                catch(Exception e)
                {
                    logObjectContent();
                    log.save('ERROR at Check Request status :  ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    
                }
                
                order = null;
                order = updatedOrder;
                
                //Delete the request object
                completeRequest();
                
                log.addLine('Order successfully created');
            }
        }
        log.logDebug('Exit checkRequestStatus');
        return null;
        
    }
    
    public void completeRequest(){
        waitingForResponse = false;
        if(asyncRequest!=null){
            delete asyncRequest;
        }
    }
    
    /*
    Create order in SAP
    */
    protected Boolean createOrder() {
        
        log.addLine('Entered createOrder()');
        
        Integer paymentCount = orderPayments.size();
        Integer requestItemSize = 2 + paymentCount;
        Boolean createSFDCOrder = null;
        
        Matcher ccMatcher = null;
        Boolean ccMatched = null;
        
        Boolean userMsg = false;
        Boolean SAPOrderCreated = false;
        
        try{
            //Populate request object
            GneProductOrderCreateOrderAsync.CreateOrderRequestItem[] requestItems = new GneProductOrderCreateOrderAsync.CreateOrderRequestItem[requestItemSize];
            
            //Set order level request
            GneProductOrderCreateOrderAsync.CreateOrderRequestItem requestItem = new GneProductOrderCreateOrderAsync.CreateOrderRequestItem();
            
            billingAddress.SAP_Address_ID__c = billToAccountNumber;
            shippingAddress.SAP_Address_ID__c = addressValue;
            
            requestItem.sfdcOrderNumber = requestSenderId;
            requestItem.requestItemType='order';
            requestItem.billToId=billToAccountNumber;
            requestItem.shipToId=addressValue;
            requestItem.createdBy = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            requestItems[0] = requestItem;
            if(debug){
                debugMessage += 'bill & ship: ' + billToAccountNumber + '|' + addressValue + '<br/>';
            }
            //set line level request 
            requestItem = new GneProductOrderCreateOrderAsync.CreateOrderRequestItem();
            requestItem.requestItemType='lineitem';
            requestItem.productNDC=NDC;
            requestItem.quantity=String.valueOf(item.Quantity__c.intValue());
            requestItems[1] = requestItem;
            if(debug){
                debugMessage += 'ndc & quantity: ' + NDC + '|' + String.valueOf(item.Quantity__c.intValue()) + '<br/>';
            }
            //set payment level request 
            Integer paymentItemIndex = 2;
            if(debug){
                debugMessage += 'payment size: ' + orderPaymentsKeep.size() + '<br/>';
            }
            for(Product_Order_Payment_gne__c payment:orderPayments) {
                if(payment.Total__c != null && payment.Total__c > 0 ){
                    
                    
                    
                    requestItem = new GneProductOrderCreateOrderAsync.CreateOrderRequestItem();
                    requestItem.requestItemType='payment';
                    
                    requestItem.cardNumber = getSAPCreditCardNumber(payment);
                    requestItem.cardHolder = payment.Card_Holder_Name__c;
                    
                    // Expiration date must be in YYYY-MM-DD format
                    String expMonth;
                    String expDay;
                    if (payment.Expiration_Date__c.month() < 10) {
                        expMonth = '0' + payment.Expiration_Date__c.month();
                    } else {
                        expMonth = '' + payment.Expiration_Date__c.month();
                    }
                    if (payment.Expiration_Date__c.day() < 10) {
                        expDay = '0' + payment.Expiration_Date__c.day();
                    } else {
                        expDay = '' + payment.Expiration_Date__c.day();
                    }
                    //requestItem.expirationDate = payment.Expiration_Date__c.year() + '-' + payment.Expiration_Date__c.month() + '-' + payment.Expiration_Date__c.day();
                    requestItem.expirationDate = payment.Expiration_Date__c.year() + '-' + expMonth + '-' + expDay;
                    debugMessage += 'CC exp date: ' + requestItem.expirationDate + '<br/>';
                    
                    requestItem.cardType = payment.Card_Type__c;
                    payment.Total__c = payment.Total__c.setScale(2);
                    
                    requestItem.totalCharge = String.valueOf(payment.Total__c);
                    //requestItem.totalCharge = String.valueOf((payment.Total__c).setScale(2));
                    if(debug){
                        debugMessage +=  requestItem.cardNumber + ' : ' + payment.Name + '|' + payment.Card_Holder_Name__c + '|' + payment.Expiration_Date__c.format() + '|' + 
                        String.valueOf(payment.Total__c) + '<br/>'; 
                    }
                    requestItems[paymentItemIndex] = requestItem;
                    paymentItemIndex++;
                    
                    
                    
                }
                
                
            } 
            
            if(debug){
                debugMessage +='<br/>createOrderAsync';
            }
            
            log.addLine('Calling createOrder.createOrderAsync webservice');
            GneProductOrderCreateOrderAsync.CreateOrderResponseItem[] responseItems = createOrder.createOrderAsync(requestItems);
            if(debug){
                debugMessage +='<br/>createOrderAsync done';
            }
            if (responseItems == null ||responseItems.size() == 0) {
                logObjectContent();
                log.save('ERROR: createOrder.createOrderAsync() returned no responses', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;

                if(debug){
                    debugMessage += 'Order creation failed - no reponse<br/>';
                }
                createSFDCOrder =  false;
                
                return false;
            }
            
            System.debug('********REPSONSE ITEMS SIZE******'+responseItems.size());
            for(integer i=0;i<responseItems.size();i++)
            {
                GneProductOrderCreateOrderAsync.CreateOrderResponseItem response = responseItems[i];
                System.debug('****MESSAGES--RESPONSES ****'+response.message+'STATUS --->'+response.Status);
            }
            
            
            Integer i = 0;
            
            if(debug){
                debugMessage += '<br/>response size: ' + responseItems.size() + '<br/>';
            }
            
            GneProductOrderCreateOrderAsync.CreateOrderResponseItem response = responseItems[0];
            String status = response.Status;
            String msg=response.Message;
            log.addLine('status=' + status+' message = '+msg);

            if(status==null){
                status='syserror';
            }
            if (status == 'published') {
                //Mark the  start of the request 
                startRequest();
                
                log.addLine('Exit createOrder returning true');
                return true;
            } else {
                logObjectContent();
                log.save('ERROR: createOrder.createOrderAsync() returned status ' + status, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                String temp='';
                
                errorMessage ='I am here: status is '+status+ GNE_LWO_Controller.GENERIC_ERROR_MSG;
                return false;
            }
            
            
        } catch(Exception e) {
            logObjectContent();
            log.save('ERROR createOrder Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            errorMessage = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            
            message = e.getMessage();
            return false;
        }
    }
    
    protected String getSAPCreditCardNumber(Product_Order_Payment_gne__c payment) {
        String SAPCreditCardNumber = null;
        Boolean numberMatches = null;
        for( Map<String,String>  cc :creditCards ) {
            numberMatches = (encrypted) ? cc.get('number').contains(payment.Name) : cc.get('number').endsWith(payment.Name);
            if (numberMatches && cc.get('holder').equals(payment.Card_Holder_Name__c)) {
                SAPCreditCardNumber = cc.get('number');
            }
        }
        return SAPCreditCardNumber;
    }
    
    /*
    Clear out error message
    */
    protected void clearError(){
        paymentError = '';
        errorMessage = '';
        criticalError = '';
        createOrderMessage = '';
        // debugMessage = '';
    }
    
    protected void setErrorMessage(String error){
        errorMessage = error;
    }
    protected void setPaymentError(String error){
        paymentError = error;
    }
    public String getDebugMessage(){
        return debugMessage;
    }
    public String getErrorMessage(){
        return errorMessage;
    }
    public String getccExpMessage(){
        return ccExpMessage;
    }
    public String getSearchMessage(){
        return searchMessage;
    }
    public String getCriticalError(){
        return criticalError;
    }
    public String getPaymentError(){
        return paymentError;
    }
    public String getAddressValue(){
        return addressValue;
    }
    public void setAddressValue(String value){
        this.addressValue=value;
    }
    
    public String getBalanceColor(){
        return this.balanceColor;
    }
    public String getBalanceMsg(){
        return this.balanceMsg;
    }
    
    public String getBillToName(){
        return this.billToName;
    }
    public String getBillToAccountNumber(){
        return this.billToAccountNumber;
    }
    //Get Bill-To Address for the selected account
    public String getBillToAddress(){
        return billToAddress;
    }
    
    public String getShipToAddress(){               
        return this.shipToAddress;
    }
    public String getProductName(){
        return this.productName;
    }    

    public String getProductDesc(){
        return this.productDesc;
    }    
    
    public String getDateToday(){
        return System.Now().format('MM/d/yyyy');
        
    }

    /*
    Populate shipping address dropdown
    */
    public List<SelectOption> getShippingAddresses(){
        
        if( shipAddressOptions == null) {           
            updateBillToRelated();
            // shipAddressOptions = new List<SelectOption>();
        }
        
        return shipAddressOptions;
    }
    
    public Product_Order_gne__c getOrder(){
        return order;
    }
    
    public Product_Order_Item_gne__c getItem(){     
        return item;
    }
    
    public List<OrderItemInformation> getOrderItems(){
        if(orderItems.size()>0)
        {
            orderItems.clear();
        }
        for(Product_Order_Item_gne__c orderItem : items)
        {
            String productDesc = 'NA';
            String fullTotalPrice = '';
            Decimal quantity = 0;
            String itemPrice = '';
            String taxPrice = '';
            quantity = orderItem.Quantity__c;
            System.debug('PRODUCT 22222');// + orderItem);
            if(orderItem.Product__c != null && orderItem.Product__r.description_vod__c != null && orderItem.Product__r.description_vod__c != '')
            {
                productDesc = orderItem.Product__r.description_vod__c;
            }
            if(orderItem.Product__c != null && orderItem.Product__r.List_Price_gne__c != null )         
            {
                itemPrice = '$' +orderItem.Product__r.List_Price_gne__c;
            }
            if(orderItem.Total__c != null &&  orderItem.Quantity__c!=null && orderItem.Product__r.List_Price_gne__c!=null)
            {
                //fullTotalPrice = '$' + dataController.convertToCurrency(orderItem.Total__c.format());
                fullTotalPrice = '$' + orderItem.Quantity__c * orderItem.Product__r.List_Price_gne__c;
            }
            if(orderItem.Tax__c != null && orderItem.Tax__c > 0)
            {
                taxPrice = '$' + dataController.convertToCurrency(orderItem.Tax__c.format());
            }
            
            
            orderItems.add(new OrderItemInformation(productDesc,fullTotalPrice,itemPrice,taxPrice,quantity));
        }     
        
        System.debug(' &**((((()))))');
        return orderItems;
    }
    
    /*
    Get Order Payments
    */
    public List<Product_Order_Payment_gne__c> getPayments(){
        system.debug('----orderPayments2015'+orderPayments);
        return orderPayments;
    }
    
    /*
    Get Total Charged Amount
    */
    public String getTotalChargedAmount(){
        
        if( orderPayments.size() == 0) {    
            return '';
        }
        else {
            
            Double totalCharged = 0;
            for(Product_Order_Payment_gne__c payment:orderPayments){                        
                if( payment.Total__c != null)                       
                totalCharged = totalCharged + payment.Total__c;
            }
            
            String convertedNumber = '$' + dataController.convertToCurrency(totalCharged.format());         
            return convertedNumber;             
        }
    }
    
    public void setPayments(List<Product_Order_Payment_gne__c> payments){
        this.orderPayments = payments;
        system.debug('----orderPayments2042');
    }
    
    /*
    Get Order Payments - ones to be kept
    */
    public List<Product_Order_Payment_gne__c> getPaymentsKeep(){
        
        if(ccstore.size()>0)
        ccstore.clear();
        if(ccstore_map.size()>0)
        ccstore_map.clear();
        
        for(integer i=0;i<orderpaymentskeep.size();i++)
        {
            CreditCard_Storage ccstr=new CreditCard_Storage();
            ccstr.cardType=orderpaymentskeep[i].Card_Type__c;
            ccstr.cardHolder=orderpaymentskeep[i].Card_Holder_Name__c;
            ccstr.cardNumber='XXXX-XXXX-XXXX-'+orderpaymentskeep[i].Name;
            ccstr.cardExpDate=orderpaymentskeep[i].Expiration_Date__c;
            ccstore.add(ccstr);
            ccstore_map.put(ccstr.cardNumber,ccstr);
            
        }
        system.debug('----------------------order expiration date'+orderpaymentskeep);
        return orderPaymentsKeep;
    }
    
    public void setPaymentsKeep(List<Product_Order_Payment_gne__c> payments){
        this.orderPaymentsKeep = payments;
         system.debug('----------------------order expiration date '+payments);
        
    }
    
    public Product_Order_Item_gne__c getPriceHolder(){
        return this.priceHolder;
    }
    
    public void setPriceHolder(Product_Order_Item_gne__c payment){
        this.priceHolder = item;
    }   
    
    public String getOrderNumber() {
        return orderController.getOrderNumber(order.Id);
    }
    
    public Product_Order_Payment_gne__c getTotalPayment(){
        return this.totalPayment;
    }
    
    public void setTotalPayment(Product_Order_Payment_gne__c payment){
        this.totalPayment =payment;
    }
    

    
    public List<String> responses {get; set;}
    public String message {get; set;}

    public PageReference cancel() {
        order = null;
        // Send the user to home page
        //PageReference homePage = new PageReference('/apex/ProductOrderHome');
        PageReference homePage = new PageReference('/apex/GNE_LWO_Welcome');
        homePage.setRedirect(true);
        return homePage;
    }
    
    
    /*
* Update Quantity or charge amount in payments
*/
    public PageReference updatePayments()
    {
        log.addLine('Entered ProductOrderAsyncEntryController.updatePayments()');                
        
        clearError();
        
        updateCCInfo(false);
        firstView = false;
        
        log.logDebug('Exit updatePayments');
        return null;
    }
    
    
    /*
    Edit Order
    */
    public PageReference editOrder() {
        clearError();         
        PageReference entryPage = new PageReference('/apex/GNE_LWO_OrderEntry');
        entryPage.setRedirect(false);
        return entryPage;
    }
    
    /*
    Edit Order Payment
    */
    public PageReference editOrderPayment() {

        clearError();         
        PageReference paymentPage = new PageReference('/apex/GNE_LWO_OrderPayment');
        paymentPage.setRedirect(false);
        return paymentPage;
    }
    
    /*
    Back to order list
    */ 
    public PageReference backToOrderList() {
        PageReference pageRef = System.currentPageReference();
        String url = pageRef.getUrl();
        PageReference nextPage;
        
       String reference = PageRef.getParameters().get('reference');
        if(reference=='summary')
        nextPage  = new PageReference('/apex/GNE_LWO_OrderSummary?accountId='+acctID+'&accountIndicator='+acctIndicator);
        else if(reference=='invoice') 
         nextPage  = new PageReference('/apex/GNE_LWO_InvoiceReport?accountId='+acctID+'&accountIndicator='+acctIndicator);
      /*  nextPage.getParameters().put('accountId', order.Bill_To__c);
        nextPage.getParameters().put('selectedStatus', selectedStatus);
        nextPage.getParameters().put('selectedSearchField', selectedSearchField);
        nextPage.getParameters().put('selectedFrom', selectedFrom);
        nextPage.getParameters().put('selectedTo', selectedTo);
        
        nextPage.getParameters().put('sid', sampleAccountId);
        nextPage.getParameters().put('oid', sampleOrderId);
        nextPage.getParameters().put('du', isDesigneeUser);*/
        
        nextPage.setRedirect(false);
        return nextPage;
    }
    
    public PageReference doCommercialOrder() {
        clearError();
        return doOperation(1);      
    }   
    
    public PageReference doChargeSummary () {
        return doOperation(3);      
    }
    
    public PageReference doOrderSummary () {
        return doOperation(4);      
    }
    
    public PageReference doAccountProfile () {
        return doOperation(5);      
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
    
    
    // pass all Sample related parameters to Commercial
    protected PageReference doOperation(Integer operation) {
        
        PageReference page = null;
        if( operation == 1) {                                       
            page = new PageReference('/apex/GNE_LWO_OrderEntry');

            if( getSampleEnrolled()) {                          
                page.getParameters().put('sid', sampleAccountId);
                page.getParameters().put('oid', sampleOrderId);                
                page.getParameters().put('du', isDesigneeUser);
            }
            
            if(GNE_LWO_Controller.getAdminUser() && this.accountID != null){
                page.getParameters().put('accountId', accountID);
            }
            page.setRedirect(true);
            return page;                                                
            
        }
        else if( operation == 3){
            page = new PageReference('/apex/GNE_LWO_ChargeSummary');
        }
        else if( operation == 4){
            page = new PageReference('/apex/GNE_LWO_OrderSummary');
        }
        else if( operation == 5){
            page = new PageReference('/apex/GNE_LWO_AccountProfile');
        }
        else if( operation == 6)
        page = new PageReference('/apex/GNE_LWO_Contact');
        else if( operation == 7) {
            
            if( getSampleEnrolled()) 
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
        
        page.getParameters().put('sid', sampleAccountId);
        page.getParameters().put('oid', sampleOrderId);                
        page.getParameters().put('du', isDesigneeUser);
        if(GNE_LWO_Controller.getAdminUser() && this.accountID != null){
            page.getParameters().put('accountId', accountID);
        }
        page.setRedirect(false);
        return page;                                                
    }
    
    
    
    
    /* Add wrapper class to store Credit card details 
    
    By Rakesh : 
    */
    
    
    public class CreditCard_Storage
    { 
        public String cardType {get;set;}
        public String cardHolder {get;set;}
        public String cardNumber {get;set;}
        public Date cardExpDate {get;set;}
        
    }
    
    
    public PageReference doSample() {
        
        PageReference nextPage = null;
        
        if( sampleAccountId == null) {
            //System.debug('Sample Account is not available');
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
        
        nextPage.getParameters().put('sid', this.sampleAccountId);  
        
        if( item != null)
        nextPage.getParameters().put('oid', item.Order__r.Id);
        
        nextPage.getParameters().put('du', isDesigneeUser);     

        if( nextPage != null ) {        
            if(GNE_LWO_Controller.getAdminUser() && this.accountID != null){
                nextPage.getParameters().put('accountId', accountID);
            }                              
            nextPage.setRedirect(false);                              
            return nextPage;
        }
        
        return null;                    
    }
    
    public Boolean getSampleEnrolled() {
        
        if( sampleAccountId != null && sampleAccountId.length() > 0) 
        return true;
        else
        return false;
    }
    
    public String getFullUnitPrice() {
        
        if( prices == null || prices.size() == 0) {
            //errorMessage = ', No price information available';
            return null;    
        }
        else {
            for (Product_Order_Price_gne__c price : prices){
                if( price.Condition_Type__c == 'PR00')
                return '$' + dataController.convertToCurrency(price.Unit_Price__c.format());
            }                           
        }
        
        return null;
    } 
    
                
    
    public String getTotalDiscount() {
        Decimal totalDisc=0.0;
        integer count =0;
        if( prices == null || prices.size() == 0) {            
            return null;    
        }
        else {
            for (Product_Order_Price_gne__c price : prices){
                if( price.Condition_Type__c == 'ZD01') {
                	count++;
                	System.debug('disc price ' +price.Total_Price__c );
                	totalDisc=totalDisc+price.Total_Price__c;
                    
                }
            } 
            System.debug('total count ' + count);
            System.debug('total discounted price ' + totalDisc);                          
            return '$' + dataController.convertToCurrency(totalDisc.format());       
        }
        
        return null;
    }              




    public String getFullTotalPrice() {
        
        if( prices == null || prices.size() == 0) {            
            return null;    
        }
        else {
            for (Product_Order_Price_gne__c price : prices){
                if( price.Condition_Type__c == 'PR00') {
                    return '$' + dataController.convertToCurrency(price.Total_Price__c.format());
                }
            }                           
        }
        
        return null;
    }              
    
    
    public PageReference chargeMeNow()
    {

        System.debug('reaching here payment ter');
        PageReference pageRef = System.currentPageReference();
        Account acctInfo = dataController.getAccountInfoForID(accountId);
        log.addLine('dataController.getAccountInfoForID(' + accountId + ') returned SAP ID=' + acctInfo.SAP_ID_gne__c);
        
        String ordernum = order.SAP_ORDER_ID__C; //pageRef.getParameters().get('sapOrdernum');   //!=null)?pageRef.getParameters().get('sapOrderId'):pageRef.getParameters().get('paymentterm00');
        String paymentterm='CC00';
        System.debug(' default payment term'+ paymentterm);
       // iscc60success=true;
      
       GnecommPaymentteras.PaymentTermsRequest2 request = new GnecommPaymentteras.PaymentTermsRequest2();
       request.accountNumber= acctInfo.SAP_ID_gne__c;
       request.orderNumber=ordernum;
       request.paymentTerm=paymentterm;
//         GnecommPaymentteras.PaymentTermsReply2 reply= submitpayment.processInbound(request,'test');
    try{
       GnecommPaymentteras.GneCOMM_PaymentTerms_PaymentTerms_SFDC_O_1_WSD_UpdatePaymentTerms_Port submitrequest = new GnecommPaymentteras.GneCOMM_PaymentTerms_PaymentTerms_SFDC_O_1_WSD_UpdatePaymentTerms_Port();
       GnecommPaymentteras.PaymentTermsReply2 reply=submitrequest.processInbound(request,'off');
        String status = 'false';
       if(reply!=null && reply.status!=null)        status = reply.status;
       System.debug('resposne status '+ reply.status );
       System.debug('response message '+ reply.message);
       //when status is true, mean order payment term is successfully changed in SAP
       if(status=='true'){
       		order.payment_term_changed__c = true;
       	    order.payment_term_change_date__c	= system.today();
       		update order;
       		//this.disableChargemeNow = true;
       		this.cancelMessage = 'Your payment term has been changed for Order #'+ordernum+'.';
       		
       	}else{
       		this.cancelMessage = 'Your payment term can not be changed for Order #'+ordernum+'. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
       		String msg='';
       		if(reply!=null && reply.message!=null) msg=reply.message;
       		log.save('Error: order payment term change failed for order #'+ordernum+'. SAP error message: '+msg, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
       	}
      }
  
     catch(Exception e){ 
           PageReference page=new PageReference('/apex/LWO_ErrorPage');
          errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Relationship Specialist at 800.963.1778 for assistance.';
          page.getParameters().put('ErrorMessage', errorMessage);
          page.setredirect(true);
          return page ;
       }
       return null;
    }

    
    
    /**
    * Retrieve SAP account information for a given Account object, profile.
    * true: account info is retrieved successfully
    * false: failed to retrieve account info 
    */
    /* 4/25/11 FL - Comment out since method not called anywhere
    protected boolean getSampleSAPAccountInfo(Account acctInfo, String userProfileName, Integer attempt){
        if( attempt > 2)
            return false;
            
        String status = '';
        
        try {
            message = '';
            
            GneProductOrderGetAccountInfo.AccountInfoResponseItem[] responseItems = accountInfo.accountInfo(acctInfo.SAP_ID_gne__c, 'C');
                                            
            if (responseItems == null || responseItems.size() == 0) {
                
            // duyent - 022511 add notification
            String username = UserInfo.getUserName();
            string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderAsyncEntryController - getSampleSAPAccountInfo() responseItems is null';
            sendNotification (MessageBody);
                                
                errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
                return false;
            }
                                                    
            for(GneProductOrderGetAccountInfo.AccountInfoResponseItem response:responseItems) {
                                    
                String responseType = response.ResponseItemType;
                status = response.Status;
                                                        
                if(debug){
                    debugMessage = responseType + ':' + status + ':' + response.Message + ':' + response.cardNumber + '<br/>';
                }

                if (status == null || status.length()==0) {
                    status = 'true';                    
                }
                    
                if (status == 'syserror') {                    
                    errorMessage = response.Message;
                    
                    return false;

                } else if (status == 'false') {
                    
                    errorMessage = response.Message;
                    return false;
                    
                } 
                                
                if( status == 'true') {
                    if (responseType == 'account') {

                        String orderExpirationDateString   = response.orderExpirationDate;   
                        String accountExpirationDateString = response.accountExpirationDate   ;       
                        String allotmentQuantity           = response.allotmentQuantity       ;           
                        String sampleOrderDesigneeEmail1   = response.sampleOrderDesigneeEmail1;   
                        String sampleOrderDesigneeEmail2   = response.sampleOrderDesigneeEmail2; 
                                                                                                            
                        debugMessage += '  orderExpirationDateString: ' + orderExpirationDateString;
                        debugMessage += '  accountExpirationDate: ' + accountExpirationDateString;
                        debugMessage += '  allotmentQuantity: ' + allotmentQuantity;
                        debugMessage += '  sampleOrderDesigneeEmail1: ' + sampleOrderDesigneeEmail1;
                        debugMessage += '  sampleOrderDesigneeEmail2: ' + sampleOrderDesigneeEmail2;
                        
                        if( sampleOrderDesigneeEmail1 != null && sampleOrderDesigneeEmail1.length() > 0 &&
                            sampleOrderDesigneeEmail2 != null && sampleOrderDesigneeEmail2.length() > 0) {
                            
                            if( allotmentQuantity == null)
                                errorMessage = 'Invalid Sample Allotment data. ';
                                                                                        
                            try {
                                Integer remainOrderDays = currentDate.daysBetween(Date.valueOf(orderExpirationDateString));
                            }
                            catch(Exception dateE){
                                errorMessage = 'Invalid sample order expiration date: ' + dateE.getMessage();
                                return false; 
                            }   
                            
                            if (accountExpirationDateString != null ) {
                            
                                try {   
                                    Integer remainEnrollmentDays = currentDate.daysBetween(Date.valueOf(accountExpirationDateString));
                                }
                                catch( Exception dateE) {
                                    errorMessage = ' Invalid sample order enrollment expiration date: ' + dateE.getMessage();
                                    return false;                                         
                                }                            
                            }
                                                            
                            sampleEnrolled = true;       
                            sampleAccountId = acctInfo.Id;                          
                                
                            if(userProfileName!='Web Ordering Admin' && userProfileName!='GNE-LWO-CUSTOPS') {
                                if( sampleOrderDesigneeEmail1 != null &&
                                    UserInfo.getUserName().indexOf(sampleOrderDesigneeEmail1) >= 0)
                                    isDesigneeUser = 'true';
                                else if( sampleOrderDesigneeEmail2 != null &&
                                        UserInfo.getUserName().indexOf(sampleOrderDesigneeEmail2) >= 0){
                                    isDesigneeUser = 'true';                                          
                                }
                                else isDesigneeUser = 'false';
                            }
                            else isDesigneeUser = 'false';                                                                                                                        
                        }                        
                    }
                                                                                            
                }  // if false
                
                if( sampleEnrolled) {                   
                    return true;
                }
                
            }  // for reponseItems loop
            
            return true;
            
        } catch (Exception e) {
            System.debug('caught exception, error = ' + e.getMessage());
            message = e.getMessage();
            if(attempt==1){
                //Only retry for the first time
                if(message.toLowerCase().indexOf('timed out')>0){
                    return getSampleSAPAccountInfo(acctInfo, userProfileName, 2);
                }
            }
            // duyent - 022511 add notification
            String username = UserInfo.getUserName();
            string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderAsyncEntryController - getSampleSAPAccountInfo() exception error';
            sendNotification (MessageBody);
    
            errorMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
            if(debug){
                debugMessage = 'ERROR: Failed to retrieve Account information: ' + e.getMessage();
            }
            
            return false;
    }       
    }
    */
    
    public Boolean getAllowCancel() {
        system.debug('-----------item Status'+item.Status__c);
        if( item.Status__c == PENDING_STATUS_ID || item.Status__c == OPEN_STATUS_ID) {
        system.debug('-----------item Status'+item.Status__c);            
            if( this.canPlaceOrder) 
            return true;                
        }
        
        return false;
    }

    /* Dump object contect for debugging */    
    protected String getLogStr(String str) { return (str == null) ? '<null>' : str; }
    protected String getLogStr(Boolean bool) { return (bool == null) ? '<null>' : ((bool) ? 'true' : 'false'); }
    protected String getLogStr(Integer num) { if (num == null) return '<null>'; return ''+num; }
    protected String getLogStr(Long num) { if (num == null) return '<null>'; return ''+num; }
    protected void logObjectContent() {
        log.addLine('*** ProductOrderAsyncEntryController ***');
        log.addLine('PENDING_STATUS_ID=' + getLogStr(ProductOrderAsyncEntryController.PENDING_STATUS_ID));
        log.addLine('OPEN_STATUS_ID=' + getLogStr(ProductOrderAsyncEntryController.OPEN_STATUS_ID));
        log.addLine('SHIPPED_STATUS_ID=' + getLogStr(ProductOrderAsyncEntryController.SHIPPED_STATUS_ID));
        log.addLine('REQUEST_TIME_OUT=' + getLogStr(ProductOrderAsyncEntryController.REQUEST_TIME_OUT));

        log.addLine('accountOptions=' + ((accountOptions==null)?'<null>':''+accountOptions.size()));
        log.addLine('addressValue=' + getLogStr(addressValue));
        log.addLine('billToAccountNumber=' + getLogStr(billToAccountNumber));
        log.addLine('billToAddress=' + getLogStr(billToAddress));
        log.addLine('billToName=' + getLogStr(billToName));
        log.addLine('billingAddress=' + ((billingAddress==null)?'<null>':billingAddress.id));
        log.addLine('canPlaceOrder=' + canPlaceOrder);
        log.addLine('cancelMessage=' + getLogStr(cancelMessage));
        log.addLine('counter=' + counter);
        log.addLine('createOrderMessage=' + getLogStr(createOrderMessage));
        log.addLine('creditCards=' + ((creditCards==null)?'<null>':''+creditCards.size()));
        log.addLine('criticalError=' + getLogStr(criticalError));
        log.addLine('currentDateValue=' + getLogStr(currentDateValue));
        log.addLine('debugMessage=' + getLogStr(debugMessage));
        log.addLine('driveChangeByQuantity=' + getLogStr(driveChangeByQuantity));
        log.addLine('encrypted=' + getLogStr(encrypted));
        log.addLine('errorMessage=' + getLogStr(errorMessage));
        log.addLine('firstView=' + firstView);
        log.addLine('isDesigneeUser=' + getLogStr(isDesigneeUser));
        log.addLine('itemIdFromHistory=' + getLogStr(itemIdFromHistory));
        log.addLine('items=' + ((items==null)?'<null>':''+items.size()));
        log.addLine('NDC=' + getLogStr(NDC));
        log.addLine('orderNumber=' + getLogStr(orderNumber));
        log.addLine('orderPayments=' + ((orderPayments==null)?'<null>':''+orderPayments.size()));
        log.addLine('orderPaymentsKeep=' + ((orderPaymentsKeep==null)?'<null>':''+orderPaymentsKeep.size()));
        log.addLine('paymentError=' + getLogStr(paymentError));
        log.addLine('paymentTerm=' + getLogStr(paymentTerm));
        log.addLine('prices=' + ((prices==null)?'<null>':''+prices.size()));
        log.addLine('productDesc=' + getLogStr(productDesc));
        log.addLine('productName=' + getLogStr(productName));
        log.addLine('productionOptions=' + ((productionOptions==null)?'<null>':''+productionOptions.size()));
        log.addLine('profileName=' + getLogStr(profileName));
        log.addLine('requestEndTime=' + getLogStr(requestEndTime));
        log.addLine('requestSenderId=' + getLogStr(requestSenderId));
        log.addLine('requestStartTime=' + getLogStr(requestStartTime));
        log.addLine('sampleAccountId=' + getLogStr(sampleAccountId));
        log.addLine('sampleEnrolled=' + getLogStr(sampleEnrolled));
        log.addLine('sampleOrderId=' + getLogStr(sampleOrderId));
        log.addLine('sapOrderId=' + getLogStr(sapOrderId));
        log.addLine('searchAccountField=' + getLogStr(searchAccountField));
        log.addLine('searchMessage=' + getLogStr(searchMessage));
        log.addLine('searchOptionOn=' + getLogStr(searchOptionOn));
        log.addLine('selectedFrom=' + getLogStr(selectedFrom));
        log.addLine('selectedSearchField=' + getLogStr(selectedSearchField));
        log.addLine('selectedStatus=' + getLogStr(selectedStatus));
        log.addLine('selectedTo=' + getLogStr(selectedTo));
        log.addLine('shipAddressOptions=' + ((shipAddressOptions==null)?'<null>':''+shipAddressOptions.size()));
        log.addLine('shipToAddress=' + getLogStr(shipToAddress));
        log.addLine('shippingAddress=' + ((shippingAddress==null)?'<null>':shippingAddress.id));
        log.addLine('shippingAddresses=' + ((shippingAddresses==null)?'<null>':''+shippingAddresses.size()));
        log.addLine('waitingForResponse=' + getLogStr(waitingForResponse)); 
        if (priceHolder==null){
            log.addLine('priceHolder=<null>');
        } else {
            log.addLine('priceHolder=<not null>');
            log.addLine('. ID='+priceHolder.id);
            log.addLine('. Net_Price__c='+priceHolder.Net_Price__c);
            log.addLine('. Total__c='+priceHolder.Total__c);
        }
        if (price==null){
            log.addLine('price=<null>');
        } else {
            log.addLine('price=');
            log.addLine('. ID='+price.id);
            log.addLine('. Description__c='+price.Description__c);
            log.addLine('. Condition_Type__c='+price.Condition_Type__c);
        }
        if (totalPayment==null){
            log.addLine('totalPayment=<null>');
        } else {
            log.addLine('totalPayment=');
            log.addLine('. ID='+totalPayment.id);
            log.addLine('. Quantity__c='+totalPayment.Quantity__c);
            log.addLine('. Total__c='+totalPayment.Total__c);
        }
        if (asyncRequest==null){
            log.addLine('asyncRequest=<null>');
        } else {
            for(Integer i=0;i<asyncRequest.size();i++){
                log.addLine('asyncRequest=');
                log.addLine('. ID='+asyncRequest[i].id);
                log.addLine('. Request_Status__c='+asyncRequest[i].Request_Status__c);
            }
        }
        if (order==null){
            log.addLine('order=<null>');
        } else {
            log.addLine('order=');
            log.addLine('. ID='+order.id);
            log.addLine('. SAP_ORDER_ID__C='+order.SAP_ORDER_ID__C);
        }
        if (item==null){
            log.addLine('item=<null>');
        } else {
            log.addLine('item=<not null>');
        }
        log.addLine('*** End ProductOrderAsyncEntryController ***');
    }

    public boolean updateAccountDropdownList(){
        this.searchMessage='';
        this.allAcntOptions = new List<List<SelectOption>>();
        
        //only retrive account lists when it's null or empty
        if(this.allAcntForDropdown==null ||this.allAcntForDropdown.size()<=0){
            if(GNE_LWO_Controller.getAdminUser()){
                this.allAcntForDropdown = dataController.getAccountsForAdmin();
                if(this.allAcntForDropdown == null || this.allAcntForDropdown.size()<=0 || 
                        this.allAcntForDropdown.get(0)== null ||this.allAcntForDropdown.get(0).size()<=0){
                    criticalError = 'You are not affiliated with any account to place a web order. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
                    logObjectContent();
                    log.save('Error: No accounts found for user', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
                    return false;
                }
                System.debug('******Get '+this.allAcntForDropdown.size()+' account list');
            }else{
                List<Account> acnts=dataController.getAccounts();
                if(acnts == null || acnts.size()<=0) {
                    criticalError = 'You are not affiliated with any account to place a web order. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance.';
                    logObjectContent();
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
                                this.order.Bill_To__c = acc.Id;
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
        if(this.accountID == null || this.order.Bill_To__c == null ){
            if(this.allAcntForDropdown.get(0)!=null && this.allAcntForDropdown.get(0).size() >0){
                Account acc = this.allAcntForDropdown.get(0).get(0);
                this.accountID=acc.Id;
                this.order.Bill_To__c = acc.Id;
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
    
   public String getAcctID(){
        return this.acctID;
    }

    public void setAcctID(String id){
        this.acctID = id;
    }

    public String getAcctIndicator()
    {
        return this.acctIndicator;
    }

    public void setAcctIndicator(String id)
    {
        
        Account account = dataController.getAccountInfoForID(id);
        if(account == null)
        {
            return;
        }
        GneProductOrderGetAccountInfo.AccountInfo acctInfo = new GneProductOrderGetAccountInfo.AccountInfo();
        system.debug('Account Info '+ accountInfo);
        system.debug('SAP Accoun ID ' + id);
        GneProductOrderGetAccountInfo.AccountInfoResponseItem[] responseItems = acctInfo.accountInfo(account.SAP_ID_gne__c, 'S');
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
                    this.acctIndicator = response.accountIndicator;
                    accountconemail = response.contactEmail;
                    system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'+acctIndicator);
                }
        }
                
    }    
    


}