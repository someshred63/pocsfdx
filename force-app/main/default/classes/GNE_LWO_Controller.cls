/* Controller for GNE_LWO_Welcome, GNE_LWO_SampleOrder, GNE_LWO_SampleAOC, GNE_LWO_SampleOrder,
* GNE_LWO_NoOrder, GNE_LWO_SampleOrderConfirmed, GNE_LWO_SampleOrderRejected, GNE_LWO_SampleOrderView
* 
* 4/6/11 FL - getHomepageMessage() to support multiple messages
*             Added error logging
* 7/13/11 Jie - add parameter accoutId to pass selected accountID between pages
* 1/4/12 Jie - add functions for LDE project, method name starts with led
* 1/10/12 Jie - billToNum is SAP bill to account number, accountID is SFDC account id
* 12/20/13 - Jie add a new role of FPM
*/
public virtual without sharing class GNE_LWO_Controller
{   
    //add by Jie for PODIS project on 1/27/14
    protected string accountName_PODIS;    
    
    public static GNE_LWO_Logger log = new GNE_LWO_Logger();
    public static Boolean debug = false;
    public static String testUser = null;
    public static String ENDPOINT = null;      
    public static final String GENERIC_ERROR_MSG = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
    public static final String LED_GENERIC_ERROR_MSG ='Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
    public static String INPROCESS_STATUS_ID = null;
    public static String OPEN_STATUS_ID = null;    
    public static String SHIPPED_STATUS_ID = null;
    public static String CANCELLED_STATUS_ID = null;

    static ProductOrderController orderController = new ProductOrderController();
    static ProductDataController dataController = new ProductDataController();
    static GneProductOrderGetAccountInfo.AccountInfo accountInfo = new GneProductOrderGetAccountInfo.AccountInfo();
    static GneProductOrderCancelOrder.CancelOrder cancelOrder = new GneProductOrderCancelOrder.CancelOrder();
    static GneProductOrderSimulateOrder.SimulateOrder simulateOrder = new GneProductOrderSimulateOrder.SimulateOrder();
    static GneProductOrderUpdateAOC.UpdateOrderAOC updateAOC = new GneProductOrderUpdateAOC.UpdateOrderAOC();
    
    // User info
    public static String userID;
    public static String userName;
    public static String userProfile;
    public  String aoc_response_status;
    public String SAP_ACC_ID;
    public String SAP_Order_Id;
    
    protected List<SelectOption> accountOptions = null; // Account drop down list
    protected Map<String,String> accountNames = null;
    protected List<List<SelectOption>> allAcntOptions = null;
    
    public Boolean searchOptionOn {get; set;}
    protected String searchAccountField {get; set;}
    public String searchMessage  {get; set;}
    public String accountStatusMessage  {get; set;}
    public String debugMessage  {get; set;}
    public Boolean debugOn {get; set;}

    
    public string emailBody { get; set; }
    public List<OrderEmailWrapper> emailsCom { get; set; }
    public List<OrderEmailWrapper> emailsSam { get; set; }
    public string unreadMessagesCom { get; set; }
    public string unreadMessagesSam { get; set; }
    
    protected Integer accountCount = 0;   
    
    // member variables
    protected Boolean encrypted = true;
    protected String currentEnv = null;

    protected String criticalError = null;
    public String errorMessage {get; protected set;} // Display at global alert message section
    protected String paymentError = null;
    
    public String menuOption {get; set;}
    
    public Boolean canPlaceOrder {get; set;}    
    public String cancelMessage {get; set;}    
    
    public Boolean sampleEnrolled {get; set;}
    public Boolean isDesignee {get; set;}      
    
    public Integer remainOrderDays{get;set;}
    public Integer remainEnrollmentDays{get;set;}
    
    public Boolean is30DayBeforeOrderExpire{get;set;}
    public Boolean is30DayBeforeEnrollmentExpire{get;set;}
    
    public Boolean complete6Month{get; set;}   
    public Boolean complete1Year{get; set;}    
    public integer counter {get; set;}
    
    protected Boolean waitForAOCUpdate;    
    protected Boolean waitForConfirmUpdate;
    protected Boolean waitForRejectUpdate;
    protected Boolean sampleOrderTimeout;
    protected Long requestStartTime = 0;
    protected Long requestEndTime = 0;
    
    protected String NDC;    
    protected String billToAddress = null;
    protected String shipToAddress = null;
    public String addressValue {set; get;}
    
    protected String sampleAccountId = null;
    protected String orderExpirationDateString = null;     
    protected String accountExpirationDateString;       
    protected String allotmentQuantity;           
    protected String sampleOrderDesigneeEmail1;   
    protected String sampleOrderDesigneeEmail2;   

    protected Product_Order_gne__c order = null;
    protected Product_Order_Item_gne__c item = null;
    protected Product_Order_AOC_gne__c aocItem = null;    
    protected List<Product_Order_Item_gne__c> items = null;    
    protected Product_Order_Address_gne__c billingAddress = null;
    protected Product_Order_Address_gne__c shippingAddress = null;
    
    protected Datetime recievedDate {get;set;}
    
    protected Map<String, Map<String,String>> shippingAddresses = null;    
    
    //A list of all LWO account lists
    protected List<List<Account>> allAcntForDropdown;
    protected Account selectedAccount;
    
    
    static
    {
        try
        {
            ENDPOINT = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().ESB_URL__c;
            //ENDPOINT = 'http://commesb8-dev.gene.com';
            system.debug('---------------------ENDPOINT'+ENDPOINT);
            system.debug('---------------------GNE_LWO_Logger.ENV='+GNE_LWO_Logger.ENV);
            /*
            // Set values for different environments
            if (GNE_LWO_Logger.ENV == 'PROD') {
                ENDPOINT = 'https://sfdcproxy.gene.com';
                testUser = null;
            } else if (GNE_LWO_Logger.ENV == 'UAT') {
                ENDPOINT = 'https://sfdcproxy-ua.gene.com';
            } else if (GNE_LWO_Logger.ENV == 'QA') {
                ENDPOINT = 'https://sfdcproxy-qa.gene.com';
    
                // Dev environment
            } else {
                ENDPOINT = 'https://sfdcproxy-dev.gene.com';
                //ENDPOINT = 'https://sfdcproxy-qa.gene.com';
               */ 
            if (GNE_LWO_Logger.ENV =='DEV')
            {
                //test users: hopeless-both account type; com_only - commercial only account; sam_only - sample only account; CCTester-expired CC card; maryarc - com account with multiple shipto
                //srinivan - live in a state charge sales tax, landonli - has one expried card, one card expires in January
                if (UserInfo.getUserName() == 'jiezhenw@gene.com.dev')
                testUser = 'hopeless';
                else if (UserInfo.getUserName() == 'flam@gene.com.dev')
                testUser = 'hopeless'; //ppautler jpereira lwo_warm hopeless
                else if (UserInfo.getUserName() == 'ramak1@gene.com.dev')
                testUser = 'hopeless'; 
                else if (UserInfo.getUserName() == 'krzyszwi@gene.com.dev')
                testUser = 'hopeless';
                else if (UserInfo.getUserName() == 'kaczmarl@gene.com.dev')
                testUser = 'hopeless'; 
                /*else if(UserInfo.getUserName() =='karanamk@gene.com.dev')
                testUser = 'hopeless';*/ 
                else if(UserInfo.getUserName() =='madiredr@gene.com.dev')
                testUser = 'hopeless'; 
                else if(UserInfo.getUserName() =='lazarev@gene.com.dev')
                testUser = 'hopeless'; 
                else if(UserInfo.getUserName() =='boinepar@gene.com.dev')
                testUser='hopeless';
            }
            
            // Get User ID, name and profile
            
            if (testUser == null)
            {    
                userId = UserInfo.getUserId();
                userName = UserInfo.getUserName();
                Profile profile = [select Name from Profile where id = :UserInfo.getProfileId()];
                userProfile = profile.Name;   
                // Use test user if specified
            }
            else
            {
                User user = [select Id, Username, ProfileId from User where alias = :testUser];
                userId = user.Id;
                userName = user.Username;
                Profile profile = [select Name from Profile where id = :user.ProfileId];
                userProfile = profile.Name;    
            }
    
    
            System.debug('USER PROFILE ---->' +userProfile + '****user info' +UserInfo.getUserName() );
            // Turn on debug if log record exists with Level=Debug Category=Setup
            List<LWO_Log__c> lwoLog = [select id from LWO_Log__c where Level__c = 'Debug' and Category__c = 'Setup' limit 1];
            if (lwoLog != null && lwoLog.size() > 0)
            debug = true;
            
            // Get the IDs of the different statuses
            Product_Order_Code_Lookup_gne__c statusCode = [select id from Product_Order_Code_Lookup_gne__c where Name = 'SHIPPED' limit 1];                         
            SHIPPED_STATUS_ID = statusCode.Id;    
            
            statusCode = [select id from Product_Order_Code_Lookup_gne__c where Name = 'CANCELLED' limit 1];                                
            CANCELLED_STATUS_ID = statusCode.Id;
            
            statusCode = [select id from Product_Order_Code_Lookup_gne__c where Name = 'PENDING' limit 1]; 
            system.debug('-----status code: '+statusCode);       
            INPROCESS_STATUS_ID = statusCode.Id;
            
            statusCode = [select id from Product_Order_Code_Lookup_gne__c where Name = 'OPEN' limit 1]; 
            system.debug('-----status code: '+statusCode);       
            OPEN_STATUS_ID = statusCode.Id;
        }
        catch (Exception e)
        {
            // log error
            GNE_CM_MPS_Utils.insertError('GNE_LWO_Controller', 'Error', 'Static init', 'Apex', GlobalUtils.getExceptionDescription(e)); 
        }       
    }
    
    /* Jie add on 12/20/13 for FPM role*/
    public static Boolean getFPMUser(){
        if (userProfile == 'GNE-CM-IHCP-PROFILE' || userProfile =='GNE-LWO-USER' || userProfile == 'GNE-LWO-CUSTOPS' ||
        userProfile == 'System Administrator' ||
        userProfile =='Web Ordering Admin' ) return false;
        else return true;
    }
    
    /* Jie add on 12/20/13 to set FPM access restriction */
    public Boolean getShownMC(){
        if(getFPMUser()) return false;
        else return true;
    }
    
    public static Boolean getAdminUser() {  
        
       // Jie change this logic on 11/25/13 to allow FPMs have LWO admin access
        return (userProfile == 'GNE-LWO-CUSTOPS' ||
        userProfile == 'System Administrator' ||
        userProfile =='Web Ordering Admin' ||getFPMUser());  
        
    }

    protected List<OrderEmailWrapperWidget> emailsList = new List<OrderEmailWrapperWidget>();
    public List<OrderEmailWrapperWidget> emails
    {
        get
        {
            return emailsList;
        }
        set;
    }

    /* Called when page loads */
    public PageReference getInfo() {
        log.addLine('Entered GNE_LWO_Controller.getInfo()');
        
        system.debug( 'in getInfo()<br/>');
        //this.debugOn = true;
        this.debugOn = false;

        PageReference pageRef = System.currentPageReference();
        
        this.accountID = pageRef.getParameters().get('accountId');
        this.accountIndicator = pageRef.getParameters().get('accountIndicator');
        String url = pageRef.getUrl();
        this.debugMessage +='| url is '+url+'<br/>';
        system.debug( '| url is '+url+'<br/>');
        log.addLine('URL=' + pageRef.getUrl());
        system.debug('---------------------GNE_LWO_Logger.ENV='+GNE_LWO_Logger.ENV+' | accountId passed from parameter is '+this.accountID+' ; accountIndicator = '+this.accountIndicator);
        system.debug( 'userProfile is - '+userProfile+' | username - '+userName+' | testuser - '+testuser);
        this.debugMessage += '---------------------GNE_LWO_Logger.ENV='+GNE_LWO_Logger.ENV;
        this.debugMessage += 'userProfile is - '+userProfile+' | username - '+userName+' | testuser - '+testuser;
        
        String secondEntry=pageRef.getParameters().get('SecondEntry');
        //redirect to GNE_LWO_Welcome page for cust op users if request from landing page
        if(/*(secondEntry==null || secondEntry!='true') &&*/(url.contains('GNE_LWO_Order') || url.contains('GNE_LWO_order'))  && GNE_LWO_Controller.getAdminUser()){
           system.debug( '&&&&&&Yes, should redirect to welcome page<br/>');
            pageRef=new PageReference('/apex/GNE_LWO_Welcome');
            if(accountID!=null) pageRef.getParameters().put('accountId', this.accountID);
            if(this.accountIndicator!=null) pageRef.getParameters().put('accountIndicator', this.accountIndicator);
            pageRef.setRedirect(true);
            return pageRef;
        }

        if (isDesignee != null ) {
            log.addLine('2nd time calling getInfo. Exiting early.');
            //log.logDebug('Exit getInfo()');
            system.debug( 'in getInfo()- 2nd entry<br/>');
            return null;
        }
        
        // set current environment
        currentEnv = GNE_LWO_Controller.ENDPOINT;

        try {
            //Check user profile to enforce whether user can place orders or not
            log.addLine('user profile=' + GNE_LWO_Controller.userProfile);

            // If admin user
            if (GNE_LWO_Controller.getAdminUser() ) {
                canPlaceOrder = false; 
                isDesignee = false;
                this.searchOptionOn = true;   
                
                this.accountIndicator = pageRef.getParameters().get('accountIndicator');
                //updateAccountsList();    
                updateAccountDropdownList();

                system.debug( 'user '+userName+' is admin, selected account '+this.accountID+'<br/>');
                this.debugMessage +='user '+userName+' is admin, selected account '+this.accountID+' | accountIndicator is '+this.accountIndicator;
                this.checkAccount();

                // HCP customers                     
            } else {
                system.debug( 'user '+userName+' is not admin<br/>');
                canPlaceOrder  = true;
                waitForAOCUpdate = false; 
                waitForConfirmUpdate = false;
                waitForRejectUpdate = false;
                criticalError = null;
                
                List<Account> accounts = dataController.getAccounts();
                
                if (accounts == null || accounts.size() == 0) {
                    system.debug( 'No account has been selected. |');
                    log.addLine('dataController.getAccounts() returned 0 accounts');
                    criticalError = 'No account has been selected. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance. ';
                    //direct to error page if no account found for user
                    PageReference page=new PageReference('/apex/LWO_ErrorPage');
                    page.getParameters().put('ErrorMessage', criticalError);
                    page.setRedirect(true);
                    return page; 
                } else {
                    system.debug( 'dataController.getAccounts() returned ' + accounts.size() + ' accounts<br/>');
                    log.addLine('dataController.getAccounts() returned ' + accounts.size() + ' accounts');
                }
                
                // check if sample Order.id is passed through AOC update, Confirm or Reject page, or some other controllers
                String orderId = pageRef.getParameters().get('oid');   
                this.debugMessage +='oid passed from parameter orderId is '+orderId+'<br/>';
                system.debug('orderId is '+orderId+'<br/>');
                if (orderId != null) {
                    items = orderController.getOrderItems(orderId);
                    if (items != null && items.size() > 0) {
                        item = items[0];
                    }
                }
                
                // check if sample account id is passed from other controllers
                String tempAccountId = pageRef.getParameters().get('sid');     //Account.Id       
                system.debug('\n sample account id passed from parameter is '+tempAccountId+'<br/>'); 
                
                if (tempAccountId != null) {
                    if (!getSampleAccountData(tempAccountId)) {                 
                        return null;
                    }

                    if (item == null)
                    initializeSampleOrder();                                                                                        

                    // first time when user logins in, check if user has access to sample accounts
                } else {
                    sampleEnrolled = false;
                    isDesignee = false;
                    complete6Month = false;
                    complete1Year = false;        
                    remainOrderDays = null;
                    remainEnrollmentDays = null;        
                    is30DayBeforeOrderExpire = false;
                    is30DayBeforeEnrollmentExpire = false;
                    
                    for (Account account : accounts) {
                        if (!getSAPAccountInfo(account, 1)) {
                            if( errorMessage == null && this.criticalError == null) {
                                criticalError = GENERIC_ERROR_MSG;
                            }     
                            if(this.criticalError!=null){
                                PageReference page=new PageReference('/apex/LWO_ErrorPage');
                                page.getParameters().put('ErrorMessage', criticalError);
                                page.setRedirect(true);
                                return page;
                            }
                            return null;          
                        }   
                        
                        accountID = account.Id;
                        billToNum = account.SAP_ID_gne__c;                 
                        // Can stop once sample account is found since there can only be one
                        if (sampleEnrolled == true) {
                            system.debug( 'in getInfo() sampleEnrolled is '+sampleEnrolled+'<br/');
                            break;
                        }
                    }
                }
                //check credit card expiration date to populate global alert message
                checkCreditCardExpirationDate();
                InitializeEmailTooltips(accounts);
                String cancelOrderMSG = pageRef.getParameters().get('cancelConfirmation');  
                if(cancelOrderMSG!=null && cancelOrderMSG.trim().length()>0) this.errorMessage = cancelOrderMSG;
 
            } // HCP customers

            system.debug('\n sampleEnrolled is '+this.sampleEnrolled+'<br/>');
            log.addLine('Exit getInfo');        
        } catch (Exception e) {
            logObjectContent();
            log.save('ERROR getInfo() Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            errorMessage = e.getMessage()+' '+LED_GENERIC_ERROR_MSG;
            
        }
        
        if(!GNE_LWO_Controller.getAdminUser()) trackingLogin();
        
        return null;
    }

    /* Retrieve SAP account information for a given Account object. Determines if account is a sample account.
* true: account info is retrieved successfully
* false: failed to retrieve account info 
*/
    public Boolean getSAPAccountInfo(Account acctInfo, Integer attempt) {
        this.debugMessage += 'in get sap account info<br/>';
        log.addLine('Entered GNE_LWO_Controller.getSAPAccountInfo(acnt=' + acctInfo.SAP_ID_gne__c + ', attempt=' + attempt + ')');

        // This should never happen
        if (attempt > 2) {
            logObjectContent();
            log.save('ERROR: attempt > 2', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
            return false;
        }

        try {
            errorMessage = null;
            this.criticalError = null;
            this.debugMessage +='Calling accountInfo.accountInfo(' + acctInfo.SAP_ID_gne__c + ')';
            log.addLine('Calling accountInfo.accountInfo(' + acctInfo.SAP_ID_gne__c + ')');
            GneProductOrderGetAccountInfo.AccountInfoResponseItem[] responseItems = accountInfo.accountInfo(acctInfo.SAP_ID_gne__c, 'S');
            
            if (responseItems == null || responseItems.size() == 0) {
                logObjectContent();
                log.save('ERROR: accountInfo.accountInfo() returned 0 responses', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                this.criticalError = GENERIC_ERROR_MSG;
                system.debug( 'SAP responseItems is null for getAccountInfo<br/>');
                return false;
            }
            log.addLine('accountInfo.accountInfo() returned ' + responseItems.size() + ' records');

            shippingAddresses = new Map<String, Map<String,String>>();       
            if (shipAddressOptions == null){
                shipAddressOptions = new List<SelectOption>();
                shipAddressOptions.add(new SelectOption('default', 'Select a Shipping Address'));
            } else {
                shipAddressOptions.clear();
                shipAddressOptions.add(new SelectOption('default', 'Select a Shipping Address'));
            }
            
            //clear shipping address selection
            if (addressValue!=null) addressValue=null;

            for (GneProductOrderGetAccountInfo.AccountInfoResponseItem response:responseItems) {
                String responseType = response.ResponseItemType;
                String status = response.Status;
                
                System.debug('ACCOUNT INDICATOR^^^^^^^^^&&&&&&&&&&&&***********'+response.accountIndicator);
                System.debug('ACCOUNT INDICATOR^^^^^^^^^&&&&&&&&&&&&***********'+response.accountIndicator);
                SYstem.debug('status &&&&*********'+ status);
                log.addLine('response type=' + responseType + ' status=' + status);
                this.debugMessage += 'response type=' + responseType + ' status=' + status;
                if (status == null || status.trim().length() == 0) {
                    status = 'true';
                }

                if (status != 'true') {
                    errorMessage = GENERIC_ERROR_MSG;
                    
                    if (response.Message != null && response.Message.length() > 0 ) {
                        logObjectContent();
                        log.save('ERROR: ' + response.Message, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                        
                        // Use actual error message instead of generic message for this status
                        if (status == 'false')
                        errorMessage = response.Message + '. '+LED_GENERIC_ERROR_MSG;
                        system.debug( 'SAP response status is false --'+response.Message+'<br/>');
                    } else {
                        System.debug('45345345SAP responseMessage is null or empty for getAccountInfo');
                        system.debug('SAP responseMessage is null or empty for getAccountInfo<br/>');
                        logObjectContent();
                        log.save('ERROR: status!=true but no error message returned in webservice response', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    }
                    this.criticalError = errorMessage;
                    return false;
                }
                
                // Status OK
                if (responseType == 'account') {
                    this.accountName_PODIS=response.accountName;
                    orderExpirationDateString   = response.orderExpirationDate;   
                    accountExpirationDateString = response.accountExpirationDate;       
                    allotmentQuantity           = response.allotmentQuantity;           
                    sampleOrderDesigneeEmail1   = response.sampleOrderDesigneeEmail1;   
                    sampleOrderDesigneeEmail2   = response.sampleOrderDesigneeEmail2;
                    accountIndicator = response.accountIndicator;
                    
                    if(accountIndicator==null || accountIndicator.trim().length()<=0){
                        errorMessage ='Can not identify account type. '+LED_GENERIC_ERROR_MSG;
                    }
                    system.debug(' *******accountIndicator '+accountIndicator);
                    // Sample accounts always have 2 designees.
                    // There's only 1 sample account affiliated with a user.
                    System.debug('phone and fax ^^^^^^^^^&&&&&&&&&&&&***********'+response.phone+' %%%%%%%%%%%%%%%%%%%%%%%'+ response.fax);
                    
                    System.debug('*************'+sampleOrderDesigneeEmail1+'*************'+sampleOrderDesigneeEmail2);
                    if (sampleOrderDesigneeEmail2 != null && sampleOrderDesigneeEmail2.length() > 0) {
                        
                        log.addLine('Sample account ' + acctInfo.SAP_ID_gne__c + ' designee1=' + sampleOrderDesigneeEmail1
                        + ' designee2=' + sampleOrderDesigneeEmail2 + ' allotmentQuantity=' + allotmentQuantity);
                        system.debug('Sample account ' + acctInfo.SAP_ID_gne__c + ' designee1=' + sampleOrderDesigneeEmail1
                        + ' designee2=' + sampleOrderDesigneeEmail2 + ' allotmentQuantity=' + allotmentQuantity+'<br/>');

                        system.debug('user name is '+GNE_LWO_Controller.userName+'<br/>');

                        if (allotmentQuantity == null)
                        errorMessage = 'Invalid Sample Allotment data. ';
                        sampleEnrolled = true;       
                        sampleAccountId = acctInfo.Id;                                                     
                        isDesignee = false;
                        sampleOrderDesigneeEmail1 = sampleOrderDesigneeEmail1.toLowerCase();
                        sampleOrderDesigneeEmail2 = sampleOrderDesigneeEmail2.toLowerCase();
                        System.debug('username*******'+GNE_LWO_Controller.userName+'sampleOrderDesigneeEmail1*****'+sampleOrderDesigneeEmail1+'********sampleOrderDesigneeEmail2'+sampleOrderDesigneeEmail2);                                                         
                        this.debugMessage +='username*******'+GNE_LWO_Controller.userName+'sampleOrderDesigneeEmail1*****'+sampleOrderDesigneeEmail1+'********sampleOrderDesigneeEmail2'+sampleOrderDesigneeEmail2;                                                         
                        if (!GNE_LWO_Controller.getAdminUser()) {
                            if (GNE_LWO_Controller.userName.indexOf(sampleOrderDesigneeEmail1) >= 0 ||
                                    GNE_LWO_Controller.userName.indexOf(sampleOrderDesigneeEmail2) >= 0) {
                                isDesignee = true;
                                log.addLine('User is sample account designee');
                                this.debugMessage +='isDesignee = '+isDesignee+'<br/>';
                            }
                        }
                        
                        if (remainOrderDays <= 30 && remainOrderDays >= 0) {
                            is30DayBeforeOrderExpire = true;                   
                        } else if (remainOrderDays < 0) {
                            complete6Month = true;
                        }
                        
                        if (accountExpirationDateString != null ) {                                        
                            if (remainEnrollmentDays <= 30 && remainEnrollmentDays >=0 ) {
                                is30DayBeforeEnrollmentExpire = true;                                   
                            } else if (remainEnrollmentDays <0 ) {
                                complete1Year = true;
                            }           
                        }                                                                                                                                 
                    } else { // if sample account
                        log.addLine('Not a sample account');
                    }
                    
                } else if (responseType == 'address') {                    
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
                    
                    if (response.billing ) {
                        billingAddress = dataController.populateAddress(responseAddress,true);
                        this.billToAddress = dataController.constructSampleAddressForDisplayMap(responseAddress);                                                            
                    } else {
                        system.debug('Shipping ');                                                       //System.debug('shipping->phone and fax ^^^^^^^^^&&&&&&&&&&&&***********'+response.phone+' %%%%%%%%%%%%%%%%%%%%%%%'+ response.fax);
                        
                        shippingAddresses.put(response.addressNo,responseAddress);
                        //shippingAddress = dataController.populateAddress(responseAddress,false);
                        shipAddressOptions.add(new SelectOption(response.addressNo, dataController.constructDisplayAddressForSelect(responseAddress)));
                        
                        if(response.preferredShipToFlag!=null && (response.preferredShipToFlag=='X' || response.preferredShipToFlag=='x')){
                            addressValue=response.addressNo;
                        }   
                        if(GNE_LWO_Controller.getAdminUser()){
                            addressValue = response.addressNo;
                        }           
                    }
                }   else if (responseType == 'creditcard') {
                    System.debug('CC Number'+ response);
                    Map<String,String> responseCC = new Map<String,String>();
                    responseCC.put('number',response.cardNumber);
                    responseCC.put('type',response.cardType);
                    responseCC.put('expirationDate',response.expirationDate);
                    responseCC.put('holder',response.cardHolder);
                    creditCards.add(responseCC);
                    this.debugMessage += 'getSAPInfor: credit card number - '+response.cardNumber+' '+
                    'expirationDate '+response.expirationDate+'';
                }  
                               
            }  // for reponseItems loop
            
        } catch (Exception e) {
            system.debug(e.getMessage());
            // Retry once if timed out
            if (attempt == 1 && e.getMessage().toLowerCase().indexOf('timed out') > 0) {
                log.addLine(e.getMessage());
                return getSAPAccountInfo(acctInfo, 2);
            }

            logObjectContent();
            log.save('ERROR getSAPAccountInfo Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);        
            this.criticalError = GENERIC_ERROR_MSG;                        
            return false;
        }
        
        system.debug( 'getSAPInfo accountIfo '+acctInfo.Id+ ' sampleEnrolled is '+this.sampleEnrolled+'<br/>');
        log.addLine('Exit getSAPAccountInfo returning true');
        return true;
    }

    /**
* For a given Account.Id, retrieve its Sample account data
*/
    protected Boolean getSampleAccountData(String accountIdParam) {
        log.addLine('Entered GNE_LWO_Controller.getSampleAccountData(accountIdParam=' + accountIdParam + ')');

        Account account = dataController.getAccountInfoForID(accountIdParam);
        log.addLine('dataController.getAccountInfoForID returned SAP ID=' + account.SAP_ID_gne__c);

        Integer attempt = 1;                                                                   
        if (!getSAPAccountInfo(account, attempt))
        return false;

        log.addLine('Exit getSampleAccountData returning true');
        return true;
    }
    
    /*
* process menu/tab selection from VF pages
*/
    public PageReference doCommercialOrder() { 
        log.addLine('Enter GNE_LWO_Controller.doCommercialOrder');
        return doOperation(1);      
    }   
    
    public PageReference doChargeSummary () {
        log.addLine('Enter GNE_LWO_Controller.doChargeSummary');
        return doOperation(2);      
    }
    
    public PageReference doOrderSummary () {
        log.addLine('Enter GNE_LWO_Controller.doOrderSummary');
        return doOperation(3);      
    }
    
    public PageReference doAccountProfile () {
        log.addLine('Enter GNE_LWO_Controller.doAccountProfile');
        return doOperation(4);      
    }
    
    public PageReference doContactProcess () {
        log.addLine('Enter GNE_LWO_Controller.doContactProcess');
        return doOperation(6);      
    }

    public PageReference doHelpProcess () {      
        log.addLine('Enter GNE_LWO_Controller.doHelpProcess');
        return doOperation(7);      
    }
    
    public PageReference doGoHomeProcess() {
        log.addLine('Enter GNE_LWO_Controller.doGoHomeProcess');
        return doOperation(8);  
    }

    public PageReference doInvoiceReport() {
        log.addLine('Enter GNE_LWO_Controller.doInvoiceReport');
        return doOperation(9);      
    }
    
    // pass all Sample related parameters to Commercial
    protected PageReference doOperation(Integer operation) {
        
        PageReference page = null;

        log.addLine('Enter doOperation(' + operation + ')');

        try {
            if (operation == 1) {                                  
                page = new PageReference('/apex/GNE_LWO_OrderEntry');    
            } else if (operation == 2) {    
                page = new PageReference('/apex/GNE_LWO_ChargeSummary');  
            } else if (operation == 3) {     
                page = new PageReference('/apex/GNE_LWO_OrderSummary');
            } else if (operation == 4) {   
                if(this.accountIndicator!=null && this.accountIndicator=='SAM'){
                    page = new PageReference('/apex/GNE_LWO_AccountProfileSample');
                } else    page = new PageReference('/apex/GNE_LWO_AccountProfile');
            } else if (operation == 6) {        
                page = new PageReference('/apex/GNE_LWO_Contact');
            } else if (operation == 7) {
                if (sampleEnrolled) {
                    page = new PageReference('/apex/GNE_LWO_SampleHelp');
                }
                else {
                    page = new PageReference('/apex/GNE_LWO_Help'); 
                } 
            } else if (operation == 8) {
                page = new PageReference('/apex/GNE_LWO_Welcome');
            }
            else if( operation == 9) {
                page = new PageReference('/apex/GNE_LWO_InvoiceReport');
            }
            
            if(GNE_LWO_Controller.getAdminUser()){
                if(this.accountID !=null)
                page.getParameters().put('accountId', accountID);
                page.getParameters().put('accountIndicator', this.accountIndicator);
            }

            if (sampleEnrolled) {
                //log.addLine('after sampleEnrolled');
                log.addLine('sampleEnrolled= '+ sampleEnrolled);
                
                // pass sample account id
                page.getParameters().put('sid', sampleAccountId);
                
                // pass isDesignee parameter
                if(isDesignee)          
                page.getParameters().put('du', 'true');
                else
                page.getParameters().put('du', 'false');
                
                // pass current order item's Order.Id
                if( this.item == null)
                doSample();    
                
                if( item != null)  {
                    page.getParameters().put('oid', item.Order__r.Id);  
                }
                
            }

        } catch(Exception e) {
            logObjectContent();
            log.save('ERROR Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
            errorMessage = GENERIC_ERROR_MSG;
            return page;
        }

        log.logDebug('Exit doOperation returning ' + page.getUrl());        
        page.setRedirect(false);
        return page;
    }
    
    
    /**
* get current Sample Order item
*/
    public Product_Order_Item_gne__c getCurOrderItem() {
        
        return item;
    }
    
    public String getProductDesc() {

        String productDesc = '';
        if( item != null)
        productDesc = item.Product__r.description_vod__c;    
        
        return productDesc;    }

    /**
* check if the current sample order is the last one for 6 month period
*/
    public Boolean getLastAOC() {

        Date shipDate = item.Expected_Ship_Date__c;
        return shipDate.isSameDay(Date.valueOf(orderExpirationDateString));
    }

    public Boolean getPassCutoffTime() {
        
        //System.debug('Enter getPassCutoffTime>>>>>>>>>>>>>>');
        
        // fwang: 5/22/2010 fixed Attempt to de-reference a null object production error        
        if( item == null) {
            System.debug('sample order item is null!!!!!!!!!!!!!!!');
            return false;   
        }
        
        Date shipDate = item.Expected_Ship_Date__c;
        Date currentDate = System.Today();
        
        if( shipDate.isSameDay(currentDate)) {
            
            Datetime currentTime = datetime.now();
            
            //conver time to PST time            
            String pstDate = currentTime.format('yyyy-MM-dd HH:mm:ss', 'PST'); // 
            
            Integer currentHour = Integer.valueOf(pstDate.substring(11, 13));
            
            //System.debug('current PST date==========='+pstDate);
            //System.debug('current PST date hour ==========='+currentHour);            
            
            if( currentHour >= 16) {          
                return true;
            }
            else
            return false;                       
        }
        else {
            
            Integer daysOffset = currentDate.daysBetween(shipDate);
            System.debug('daysoffset value --->'+daysOffset);
            if(  daysOffset > 0)
            return false;
            else 
            return true;
        }        
    }
    
    public String getBillToAddress(){
        if( billToAddress == null) {
            System.debug('billToAddress ======================null');
        }
        return billToAddress;
    }
    
    public String getSampleAccountId() {
        return sampleAccountId;
    }
    
    public String getUserName() {
        return UserInfo.getUserName();
    }

    /* Click on Sample Shipment icon or button */
    public PageReference doSample() {
    this.debugMessage +='<br/> enter doSample method. sampleAccountId is '+sampleAccountId+'<br/>';
        system.debug('<br/> enter doSample method. sampleAccountId is '+sampleAccountId+'<br/>');
        log.addLine('Entered GNE_LWO_Controller.doSample(sampleAccountId=' + sampleAccountId + ')');
        this.errorMessage = null;
        PageReference nextPage = null;   

        if (sampleAccountId == null) {
            system.debug('ERROR: sampleAccountId is null');
            logObjectContent();
            log.save('ERROR: sampleAccountId is null', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            errorMessage = GENERIC_ERROR_MSG;
            //errorMessage = 'You are not a sample user.';
            nextPage = new PageReference('/apex/GNE_LWO_Order');
            nextPage.setRedirect(false);
            return nextPage; 
        }
        
        clearError();
        Integer orderType = 1;
        
        // get 'In Process' order           
        item = orderController.getSampleOrder(sampleAccountId, orderType);
       // this.debugMessage='';
        this.debugMessage +='#########sampleAccountId '; 
        
        if (item != null ) {
            log.addLine('orderController.getSampleOrder(' + sampleAccountId + ', ' + orderType + ') returned ' + item.Product__c);       
            nextPage = new PageReference('/apex/GNE_LWO_SampleOrderView?accountId='+accountId+'&accountIndicator='+accountIndicator);          
            
            // get the order before the earliest 'Pending Confirmation' order based on Order Id
        } else {
            log.addLine('orderController.getSampleOrder(' + sampleAccountId + ', ' + orderType + ') returned 0 records');       

            orderType = 3;
            item = orderController.getSampleOrder(sampleAccountId, orderType);
            if(item != null && item.Order__r != null) {
              system.debug('<br/>*****find item '+item.Order__r.SAP_Order_ID__c+'<br/>');
            }    
            
            if (item != null) {
                log.addLine('orderController.getSampleOrder(' + sampleAccountId + ', ' + orderType + ') returned ' + item.Product__c);       
                system.debug('^^^sampleAccountId='+sampleAccountId+' : orderType'+orderType+' : item.Product__c='+item.Product__c+'<br/>');
                // Only when the order is 'Shipped', check AOC                                            
                if (item.Status__c == SHIPPED_STATUS_ID &&              
                        (item.Order__r.AOC_Status__c == null || item.Order__r.AOC_Status__c == 'INCOMPLETE')) {           
                    system.debug('item.Status__c ='+item.Status__c);
                    nextPage = new PageReference('/apex/GNE_LWO_SampleAOC?accountId='+accountId+'&accountIndicator='+accountIndicator); 
                }
            } else {
                log.addLine('orderController.getSampleOrder(' + sampleAccountId + ', ' + orderType + ') returned 0 records');       
            }
        }
        
        // get earliest Pending Conf. order
        if (nextPage == null) {
            orderType = 2;
            item = orderController.getSampleOrder(sampleAccountId, orderType);
            if(item != null && item.Order__r != null) {
             this.debugMessage +='#########item '+item.Order__r.SAP_Order_ID__c;
            }
             
            if( item != null) {
                log.addLine('orderController.getSampleOrder(' + sampleAccountId + ', ' + orderType + ') returned ' + item.Product__c);            
                nextPage = new PageReference('/apex/GNE_LWO_SampleOrder?accountId='+accountId+'&accountIndicator='+accountIndicator);
            } else {            
                log.addLine('orderController.getSampleOrder(' + sampleAccountId + ', ' + orderType + ') returned 0 records');       
                nextPage = new PageReference('/apex/GNE_LWO_NoOrder?accountId='+accountId+'&accountIndicator='+accountIndicator);                                                                                                  
            }
        }

        if(nextPage != null && GNE_LWO_Controller.getAdminUser() && this.accountID != null){
            nextPage.getParameters().put('accountId', accountID);
        }

        log.addLine('Exit doSample returning ' + nextPage.getUrl());
        
        nextPage.setRedirect(false);                              
        return nextPage;
    }

    protected void initializeSampleOrder() {
        
        /*  
        if( (complete6Month != null && complete6Month) || 
            (complete1Year != null && complete1Year)) {  

            // to-do: needs to check if AOC order exists or not.
            return;
        }
    */
        system.debug('initializeSampleOrder()<br/>');
        Integer orderType = 1;
        // get 'In Process' order                
        item = orderController.getSampleOrder(sampleAccountId, orderType);
        
        if( item == null ) {            
            
            orderType = 3;
            
            // get the order before the most recent 'Pending Confirmation' order based on ship date
            item = orderController.getSampleOrder(sampleAccountId, orderType);

            if( item == null) {

                orderType = 2;
                item = orderController.getSampleOrder(sampleAccountId, orderType);
            }
        }    
    }

    
    public Boolean getWaitForAOCUpdate() {      
        return waitForAOCUpdate;
    }
    
    public Boolean getWaitForConfirmUpdate() {      
        return waitForConfirmUpdate;
    }
    
    public Boolean getsampleOrderTimeout(){
        return sampleOrderTimeout;

    }
    public Boolean getWaitForRejectUpdate() {       
        return waitForRejectUpdate;
    }

    protected String getUserNameNoSuffix() {
        log.addLine('Entered getUserNameNoSuffix');
        String usernameSuffix = null;
        
        if (GNE_LWO_Logger.ENV == 'DEV') {            
            usernameSuffix = '.dev';             
        } else if (GNE_LWO_Logger.ENV == 'QA') {
            usernameSuffix = '.gene.sqa';
        } else if (GNE_LWO_Logger.ENV == 'UAT') {
            usernameSuffix = '.gene.uat';            
        } else if (GNE_LWO_Logger.ENV == 'ORD') {
            usernameSuffix = '.gene.uat';
        } else {
            usernameSuffix = '.gene';         
        }

        integer suffixPos = GNE_LWO_Controller.userName.lastIndexOf(usernameSuffix);
        log.addLine('usernameSuffix=' + usernameSuffix + ' pos=' + suffixPos);
        
        String userNameNoSuffix;
        if (suffixPos > 0)
        userNameNoSuffix = GNE_LWO_Controller.userName.substring(0, suffixPos);
        else
        userNameNoSuffix = GNE_LWO_Controller.userName;          

        log.addLine('Exit getUserNameNoSuffix returning ' + userNameNoSuffix);                           
        return userNameNoSuffix;                    
    }
    
    /*
* Go to sample order AOC Update page
*/

    public PageReference submitAOC() {
        boolean successfull =false;
        log.addLine('Entered GNE_LWO_Controller.submitAOC()');
        system.debug('in submitAOC<br/>');
        if(item == null) {
            system.debug( 'item is null, return.<br/>');
            return null;
        }
        
        Long startTime=System.currentTimeMillis();
        // invoke ESB interface to update AOC
        try {
            log.addLine('before call confirm AOC interface takes '+(System.currentTimeMillis()-startTime));
            GneProductOrderUpdateAOC.UpdateOrderAOCResponseItem responseItem = null;            
            SAP_Order_Id=item.Order__r.SAP_Order_ID__c;
            system.debug('SAP_Order_Id='+item.Order__r.SAP_Order_ID__c+'<br/>');
            List<Product_Order_gne__c> po=[select Bill_To__r.SAP_ID_gne__c from Product_Order_gne__c where SAP_Order_ID__C=:SAP_Order_Id];
            SAP_ACC_ID=po[0].Bill_To__r.SAP_ID_gne__c!=null?po[0].Bill_To__r.SAP_ID_gne__c:'';
            log.addLine('Calling updateAOC.updateOrderAOC(' + item.Order__r.SAP_Order_ID__c + 'COMPLETE, Now())');
            system.debug('Calling updateAOC.updateOrderAOC(' + item.Order__r.SAP_Order_ID__c + 'COMPLETE, Now())<br/>');
            responseItem = updateAOC.updateOrderAOC(item.Order__r.SAP_Order_ID__c,SAP_ACC_ID,'COMPLETE', System.Now().format('yyyy-MM-dd HH:mm:ss'),String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00',getUserNameNoSuffix(),UserInfo.getFirstName(),UserInfo.getLastName());
            log.addLine('after call confirm AOC interface takes '+(System.currentTimeMillis()-startTime));
            
            System.debug ('Recieved Date --> '+ item.Expected_Delivery_Date__c);
            
            
            System.debug('********************'+ UserInfo.getFirstName()+'****'+ UserInfo.getLastName()+'*******'+getUserNameNoSuffix());
            
            System.debug('recieved date '+ String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00');
            
            String status = responseItem.messageCode;
            
            System.debug('$$$$$$ESB RESPONSED STATUS'+ status);
            
            
            system.debug('recieved date '+ String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00 | '+responseItem.messageCode+' | '+responseItem.responseMsg);
            log.addLine('Response status=' + status);

            if (status == null) {              
                status = 'true';
            }
            
            aoc_response_status=status;
            
            if (status != 'true') {
                logObjectContent();
                log.save('ERROR: message=' + responseItem.responseMsg, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);        
                errorMessage = GENERIC_ERROR_MSG;
                return null;
            }
            
            List<Product_Order_AOC_gne__c> aocIds = [select id, SAP_Order_ID__c, FirstName__c,LastName__c, Username__c, OwnerId from Product_Order_AOC_gne__c where SAP_Order_ID__c = :item.Order__r.SAP_Order_ID__c];
            
            if( aocIds == null || aocIds.size() == 0) {
                log.addLine('Inserting Product_Order_AOC_gne__c ');
                system.debug( '<br/>Inserting Product_Order_AOC_gne__c <br/>');
                // Use LWO user as the owner
                List<User> lwouser = [Select Id from User where firstname = 'lwouser' and lastname = 'runas' limit 1];       
                if (lwouser.size() == 0)
                log.addLine('ERROR: lwouser not found in User table');

                // insert aoc user data for ESB lookup  
                aocItem = new Product_Order_AOC_gne__c();                          
                aocItem.SAP_Order_ID__c = item.Order__r.SAP_Order_ID__c;
                aocItem.FirstName__c = UserInfo.getFirstName();
                aocItem.LastName__c = UserInfo.getLastName();
                
                aocItem.OwnerId = lwouser.get(0).Id;
                aocItem.Username__c = getUserNameNoSuffix();                                                                                            
                insert aocItem;                

            } else {     
                log.addLine('Updating Product_Order_AOC_gne__c');
                Product_Order_AOC_gne__c aocItem = aocIds[0];   
                aocItem.FirstName__c = UserInfo.getFirstName();                  
                aocItem.LastName__c = UserInfo.getLastName();                                                   
                aocItem.Username__c = getUserNameNoSuffix();                  
                
                update aocItem;
            }
            
            // set waiting flags                                                
            //counter = 0;          
            //waitForAOCUpdate = true;     
            requestStartTime = System.Now().getTime();     
            errorMessage = null;                                            
            successfull = true;
        } catch(Exception e) {
            
            logObjectContent();
            log.save('ERROR Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
            errorMessage = GENERIC_ERROR_MSG;
            system.debug('Exception '+e.getMessage()+'<br/>');
        }

        finally {
            // whether success or failue insert into custom table for auditing. 
            
            System.debug('insert aoc record into sfdc table ');
            
            if(item!=null){
            LWO_AOC_Audit__c lwo_aoc=new LWO_AOC_Audit__c(AOC_Status__c='COMPLETE',Recieved_date__c=String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00',Status_Response__c=aoc_response_status,SAP_Account_ID__c=SAP_ACC_ID,Order_ID__c=SAP_Order_Id,System_Date__c=System.Now().format('yyyy-MM-dd HH:mm:ss'),User_First_Name__c= UserInfo.getFirstName(),
            User_Last_Name__c=UserInfo.getLastName(),User_Name__c=getUserNameNoSuffix());
            
            integer check_orders=[select count() from LWO_AOC_Audit__c where Order_Id__c=:SAP_Order_Id];
            Database.SaveResult results ;
            if(check_orders>0)
            {
                LWO_AOC_Audit__c lwoaocupdate=[select id,AOC_Status__c,Recieved_date__c,Status_Response__c,SAP_Account_ID__c,Order_ID__c from LWO_AOC_Audit__c where Order_Id__c=:SAP_Order_Id] ;
                lwoaocupdate.Recieved_date__c=String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00';
                lwoaocupdate.Status_Response__c=aoc_response_status;
                results = Database.Update(lwoaocupdate,false);
            }
            else
            results = Database.Insert(lwo_aoc,false);
            if (results != null){
                if (!results.isSuccess()) {
                    Database.Error[] errs = results.getErrors();
                    for(Database.Error err : errs)
                    System.debug(err.getStatusCode() + ' - ' + err.getMessage());

                }
            }
            }
            
        }
        //log.addLine('Exit GNE_LWO_Controller.submitAOC');   
        if(successfull) {
            log.addLine('before update item '+(System.currentTimeMillis()-startTime)+' order id '+item.Order__r.SAP_Order_ID__c);
            //Jie PRD Fix code - begin
            Product_Order_gne__c sampleOrder =item.Order__r;
            sampleOrder.AOC_Status__c = 'COMPLETE';
            sampleOrder.AOC_Update_Date__c=System.now();
            update sampleOrder;
            //Jie PRD Fix code - end
            log.addLine('after update item '+(System.currentTimeMillis()-startTime)+' order id '+item.Order__r.SAP_Order_ID__c);
            
            //log.save('done AOC confirm ' + (System.currentTimeMillis()-startTime), GNE_LWO_Logger.DEBUG, GNE_LWO_Logger.SAP_INT);
            return doSample();
        }
        else  {
            log.save('not success AOC confirm ' + (System.currentTimeMillis()-startTime), GNE_LWO_Logger.DEBUG, GNE_LWO_Logger.SAP_INT);
            return null;
        }
    }
   
   /* 
    public PageReference submitAOC() {
        log.addLine('Entered GNE_LWO_Controller.submitAOC()');
        system.debug('in submitAOC<br/>');
        PageReference nextPage=null;
        if(item == null) {
            system.debug( 'item is null, return.<br/>');
            return nextPage;
        }
        
        
        // invoke ESB interface to update AOC
        try {
            
            GneProductOrderUpdateAOC.UpdateOrderAOCResponseItem responseItem = null;            
            SAP_Order_Id=item.Order__r.SAP_Order_ID__c;
            system.debug('SAP_Order_Id='+item.Order__r.SAP_Order_ID__c+'<br/>');
            List<Product_Order_gne__c> po=[select Bill_To__r.SAP_ID_gne__c from Product_Order_gne__c where SAP_Order_ID__C=:SAP_Order_Id];
            SAP_ACC_ID=po[0].Bill_To__r.SAP_ID_gne__c!=null?po[0].Bill_To__r.SAP_ID_gne__c:'';
            log.addLine('Calling updateAOC.updateOrderAOC(' + item.Order__r.SAP_Order_ID__c + 'COMPLETE, Now())');
            system.debug('Calling updateAOC.updateOrderAOC(' + item.Order__r.SAP_Order_ID__c + 'COMPLETE, Now())<br/>');
            responseItem = updateAOC.updateOrderAOC(item.Order__r.SAP_Order_ID__c,SAP_ACC_ID,'COMPLETE', System.Now().format('yyyy-MM-dd HH:mm:ss'),String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00',getUserNameNoSuffix(),UserInfo.getFirstName(),UserInfo.getLastName());
            
            System.debug ('Recieved Date --> '+ item.Expected_Delivery_Date__c);
            
            
            System.debug('********************'+ UserInfo.getFirstName()+'****'+ UserInfo.getLastName()+'*******'+getUserNameNoSuffix());
            
            System.debug('recieved date '+ String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00');
            
            String status = responseItem.messageCode;
            
            System.debug('$$$$$$ESB RESPONSED STATUS'+ status);
            
            
            system.debug('recieved date '+ String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00 | '+responseItem.messageCode+' | '+responseItem.responseMsg);
            log.addLine('Response status=' + status);

            if (status == null) {              
                status = 'true';
            }
            
            aoc_response_status=status;
            
            if (status != 'true') {
                logObjectContent();
                log.save('ERROR: message=' + responseItem.responseMsg, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);        
                errorMessage = GENERIC_ERROR_MSG;
                return null;
            }
            
            //Jie PRD Fix code - begin
            item.Order__r.AOC_Status__c = 'COMPLETE';
            upsert(item);
            //Jie PRD Fix code - end

            List<Product_Order_AOC_gne__c> aocIds = [select id, SAP_Order_ID__c, FirstName__c,LastName__c, Username__c, OwnerId from Product_Order_AOC_gne__c where SAP_Order_ID__c = :item.Order__r.SAP_Order_ID__c];
            
            if( aocIds == null || aocIds.size() == 0) {
                log.addLine('Inserting Product_Order_AOC_gne__c ');
                system.debug( '<br/>Inserting Product_Order_AOC_gne__c <br/>');
                // Use LWO user as the owner
                List<User> lwouser = [Select Id from User where firstname = 'lwouser' and lastname = 'runas' limit 1];       
                if (lwouser.size() == 0)
                log.addLine('ERROR: lwouser not found in User table');

                // insert aoc user data for ESB lookup  
                aocItem = new Product_Order_AOC_gne__c();                          
                aocItem.SAP_Order_ID__c = item.Order__r.SAP_Order_ID__c;
                aocItem.FirstName__c = UserInfo.getFirstName();
                aocItem.LastName__c = UserInfo.getLastName();
                
                aocItem.OwnerId = lwouser.get(0).Id;
                aocItem.Username__c = getUserNameNoSuffix();                                                                                            
                insert aocItem;                

            } else {     
                log.addLine('Updating Product_Order_AOC_gne__c');
                Product_Order_AOC_gne__c aocItem = aocIds[0];   
                aocItem.FirstName__c = UserInfo.getFirstName();                  
                aocItem.LastName__c = UserInfo.getLastName();                                                   
                aocItem.Username__c = getUserNameNoSuffix();                  
                
                update aocItem;
            }
                
            requestStartTime = System.Now().getTime();     
            errorMessage = null;   
            nextPage= doSample();                                         
            
        } catch(Exception e) {
            
            logObjectContent();
            log.save('ERROR Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
            errorMessage = GENERIC_ERROR_MSG;
            system.debug('Exception '+e.getMessage()+'<br/>');
        }

        finally {
            // whether success or failue insert into custom table for auditing. 
            
            System.debug('insert aoc record into sfdc table ');
            
            if(item!=null){
            LWO_AOC_Audit__c lwo_aoc=new LWO_AOC_Audit__c(AOC_Status__c='COMPLETE',Recieved_date__c=String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00',Status_Response__c=aoc_response_status,SAP_Account_ID__c=SAP_ACC_ID,Order_ID__c=SAP_Order_Id,System_Date__c=System.Now().format('yyyy-MM-dd HH:mm:ss'),User_First_Name__c= UserInfo.getFirstName(),
            User_Last_Name__c=UserInfo.getLastName(),User_Name__c=getUserNameNoSuffix());
            
            integer check_orders=[select count() from LWO_AOC_Audit__c where Order_Id__c=:SAP_Order_Id];
            Database.SaveResult results ;
            if(check_orders>0)
            {
                LWO_AOC_Audit__c lwoaocupdate=[select id,AOC_Status__c,Recieved_date__c,Status_Response__c,SAP_Account_ID__c,Order_ID__c from LWO_AOC_Audit__c where Order_Id__c=:SAP_Order_Id] ;
                lwoaocupdate.Recieved_date__c=String.valueof(item.Expected_Delivery_Date__c)+' 00:00:00';
                lwoaocupdate.Status_Response__c=aoc_response_status;
                results = Database.Update(lwoaocupdate,false);
            }
            else
            results = Database.Insert(lwo_aoc,false);
            if (results != null){
                if (!results.isSuccess()) {
                    Database.Error[] errs = results.getErrors();
                    for(Database.Error err : errs)
                    System.debug(err.getStatusCode() + ' - ' + err.getMessage());

                }
            }
            }
            
        }
        log.logDebug('Exit GNE_LWO_Controller.submitAOC');        
        return nextPage;
    }
    */
    public PageReference checkAOCUpdate() {
        
        system.debug('entered check aoc update <br/>');
        if(!waitForAOCUpdate) return null;
        
        PageReference nextPage = null;
        
        counter++;
        requestEndTime = System.Now().getTime();
        
        if(requestEndTime - requestStartTime > 60000) {
            waitForAOCUpdate = false;
            errorMessage= GENERIC_ERROR_MSG;
            return null;
        }       
        
        if( item == null) {
            waitForAOCUpdate = false;
            System.debug('item is null ');
            return null;
        }
        

        
        String name = item.Order__r.name;
        
        System.debug('order number -->'+name);
        Product_Order_gne__c tempOrder = orderController.getOrderByOrderNum(name, false);
        
        System.debug('valuess.......aoc status '+ tempOrder.AOC_Status__c);
        
        
        
        if( tempOrder != null && tempOrder.AOC_Status__c == 'COMPLETE') {
            log.addLine('AOC confirm takes '+(requestEndTime - requestStartTime)/1000+' seconds');
            //log.save('confirm AOC', GNE_LWO_Logger.DEBUG, GNE_LWO_Logger.SAP_INT);
            waitForAOCUpdate = false;  
            nextPage = doSample();   
            
            if( item != null)
            nextPage.getParameters().put('oid', item.Order__r.Id);  
            nextPage.setRedirect(true);
            return nextPage;
            
        }
        
        return null;
        
    }
    
    /*
* Confirm, Reject sample order or cancel sample/commercial order
* confirmOrder: true to confirm a sample order
*               false to reject a sample order
*/   
/*    
    protected Boolean confirmCancelRejectOrder(String sapOrderId, String orderId, Boolean confirmOrder, Integer attempt) {
        log.addLine('Entered confirmCancelRejectOrder(sapOrderId=' + sapOrderId + ', orderId=' + orderId
        + ', confirmOrder=' + confirmOrder + ', attempt=' + attempt + ')');
        system.debug( 'Entered confirmCancelRejectOrder(sapOrderId=' + sapOrderId + ', orderId=' + orderId
        + ', confirmOrder=' + confirmOrder + ', attempt=' + attempt + ')<br/>');
        // This should never happen
        if( attempt > 2 ) {
            logObjectContent();
            log.save('ERROR: attempt > 2', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
            return false;
        }
        
        try {        
            GneProductOrderCancelOrder.CancelOrderResponseItem responseItem = null;
            
            if (confirmOrder)
            responseItem = cancelOrder.cancelOrder(sapOrderId, 'true', '');
            else
            responseItem = cancelOrder.cancelOrder(sapOrderId, '', 'true');
            
            String status = responseItem.Status;
            log.addLine('cancelOrder.cancelOrder() status=' + status);
            
            System.debug('status returned by ESB ' + status );
            
            if (status == null || status.trim().length()==0) {
                status = 'true';
            }
            system.debug( 'responseItem.Status='+responseItem.Status+' : responseItem.Message='+responseItem.Message+'<br/>');
            if (status != 'true') {
                if (status == 'false') {
                    if (responseItem.Message.contains('Delivery Completed')) {
                        errorMessage = ' Your order is being processed for delivery and cannot be cancelled at this time.';
                        log.addLine(responseItem.Message);
                    } else {
                        errorMessage = ' Your order cannot be cancelled due to ' +  responseItem.Message +')';
                        logObjectContent();
                        log.save('ERROR: ' + responseItem.Message, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    }
                } else {                                
                    errorMessage = GENERIC_ERROR_MSG;
                    
                    logObjectContent();
                    if (responseItem.Message != null && responseItem.Message.length() > 0 ) {
                        log.save('ERROR: ' + responseItem.Message, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    } else {
                        log.save('ERROR: status!=true but no error message returned in webservice response', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    }
                }
                
                return false;
            }
            
            // Call was successful, set wait flag                         
            counter = 0;
            if (confirmOrder) {
                waitForConfirmUpdate = true;                    
            } else {
                waitForRejectUpdate = true;                    
            }
            
        } catch(Exception e) {
            // Retry once if timed out
            if (attempt == 1 && e.getMessage().toLowerCase().indexOf('timed out') > 0) {
                log.addLine(e.getMessage());
                return confirmCancelRejectOrder(sapOrderId, orderId, confirmOrder, 2);
            }
            
            logObjectContent();
            log.save('ERROR Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);        
            errorMessage = GENERIC_ERROR_MSG;  
            errorMessage =e.getMessage()   ;                   
            return false;
        }
        
        log.addLine('Exit confirmCancelRejectOrder returning true');        
        return true;
    }
    */
    
    protected Boolean confirmCancelRejectOrder(String sapOrderId, String orderId, Boolean confirmOrder, Integer attempt) {
        log.addLine('Entered confirmCancelRejectOrder(sapOrderId=' + sapOrderId + ', orderId=' + orderId
        + ', confirmOrder=' + confirmOrder + ', attempt=' + attempt + ')');
        system.debug( 'Entered confirmCancelRejectOrder(sapOrderId=' + sapOrderId + ', orderId=' + orderId
        + ', confirmOrder=' + confirmOrder + ', attempt=' + attempt + ')<br/>');
        // This should never happen
        if( attempt > 2 ) {
            logObjectContent();
            log.save('ERROR: attempt > 2', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
            return false;
        }
        
        try {        
            GneProductOrderCancelOrder.CancelOrderResponseItem responseItem = null;
            log.addLine('before call interface '+(System.Now().getTime()-requestStartTime)/1000);
            if (confirmOrder)
            responseItem = cancelOrder.cancelOrder(sapOrderId, 'true', '');
            else
            responseItem = cancelOrder.cancelOrder(sapOrderId, '', 'true');
            log.addLine('get ESB response at '+(System.Now().getTime()-requestStartTime)/1000);
            String status = responseItem.Status;
            log.addLine('cancelOrder.cancelOrder() status=' + status);
            
            System.debug('status returned by ESB ' + status );
            
            if (status == null || status.trim().length()==0) {
                status = 'true';
            }
            system.debug( 'responseItem.Status='+responseItem.Status+' : responseItem.Message='+responseItem.Message+'<br/>');
            if (status != 'true') {
                if (status == 'false') {
                    if (responseItem.Message.contains('Delivery Completed')) {
                        errorMessage = ' Your order is being processed for delivery and cannot be cancelled at this time.';
                        log.addLine(responseItem.Message);
                    } else {
                        errorMessage = ' Your order cannot be cancelled due to ' +  responseItem.Message +')';
                        logObjectContent();
                        log.save('ERROR: ' + responseItem.Message, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    }
                } else {                                
                    errorMessage = GENERIC_ERROR_MSG;
                    
                    logObjectContent();
                    if (responseItem.Message != null && responseItem.Message.length() > 0 ) {
                        log.save('ERROR: ' + responseItem.Message, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    } else {
                        log.save('ERROR: status!=true but no error message returned in webservice response', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    }
                }
                
                return false;
            }
            
            // Call was successful, set wait flag                         
            counter = 0;
            Product_Order_Code_Lookup_gne__c statusCode;
           
            log.addLine('before upsert SFDC '+(System.Now().getTime()-requestStartTime)/1000);
            if (confirmOrder) {
                waitForConfirmUpdate = true;  
                log.addLine('confirmOrder ');
                if(item!=null){
                    log.addLine('confirmOrder item is not null, order id is '+item.Order__r.SAP_Order_ID__c);
                    statusCode = [select id, Name from Product_Order_Code_Lookup_gne__c where Name = 'PENDING' limit 1]; 
                    log.addLine('staus to be '+statusCode.Name);
                    item.Status__c = statusCode.id;
                    update item;
                    log.addLine('confirmOrder upsert successfully');
                }                  
            } else {
                waitForRejectUpdate = true;  
                log.addLine('reject order'); 
                if(item!=null){
                    log.addLine('reject order item is not null, order id is '+item.Order__r.SAP_Order_ID__c);
                    statusCode = [select id, Name from Product_Order_Code_Lookup_gne__c where Name = 'CANCELLED' limit 1];     
                    log.addLine('staus to be '+statusCode.Name);
                    item.Status__c=statusCode.id;
                    update item;
                    log.addLine('reject upsert successfully');
                }                 
            }
            log.addLine('done upsert SFDC '+(System.Now().getTime()-requestStartTime)/1000);
            
        } catch(Exception e) {
            // Retry once if timed out
            if (attempt == 1 && e.getMessage().toLowerCase().indexOf('timed out') > 0) {
                log.addLine(e.getMessage());
                return confirmCancelRejectOrder(sapOrderId, orderId, confirmOrder, 2);
            }
            
            logObjectContent();
            log.save('ERROR Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);        
            errorMessage = GENERIC_ERROR_MSG;  
            errorMessage =e.getMessage()   ;                   
            return false;
        }
        
        log.addLine('Exit confirmCancelRejectOrder returning true');        
        return true;
    }
    
    
    public PageReference rejectSampleOrder() {
        log.clear();
        log.addLine('Entered GNE_LWO_Controller.rejectSampleOrder()');
        
        if (item == null) {
            logObjectContent();
            log.save('ERROR: Product order item is null', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            errorMessage = GENERIC_ERROR_MSG;                        
            return null;
        }

        waitForRejectUpdate = false;
        requestStartTime = System.Now().getTime();
        log.addLine('start reject sample order at - '+String.valueOf(requestStartTime)+' | order id '+item.Order__r.SAP_Order_ID__c);
        //begin of Jie PRD fix code -
        //confirmCancelRejectOrder(item.Order__r.SAP_Order_ID__c, item.Order__r.Id, false, 1);
        if(confirmCancelRejectOrder(item.Order__r.SAP_Order_ID__c, item.Order__r.Id, false, 1)){
            log.addLine('return from confirmCancelRejectOrder at: '+(System.Now().getTime()-requestStartTime)/1000);
            PageReference   nextPage = new PageReference('/apex/GNE_LWO_SampleOrderRejected?accountId='+accountId+'&accountIndicator='+accountIndicator);
                if( item != null) {
                
                nextPage.getParameters().put('oid', item.Order__r.Id); 
                }
                nextPage.setRedirect(true);  
                //log.logDebug('Exit rejectSampleOrder');   
               // log.save('before return at '+(System.Now().getTime()-requestStartTime)/1000, GNE_LWO_Logger.DEBUG, GNE_LWO_Logger.SAP_INT);                        
                return nextPage;
        }
        //end of Jie PRD fix code
        
        log.addLine('Exit rejectSampleOrder with error');
        return null;
    }
    
    public PageReference confirmSampleOrder() {
        log.clear();
        log.addLine('Entered GNE_LWO_Controller.confirmSampleOrder()');
        
        if (item == null) {
            logObjectContent();
            log.save('ERROR: Product order item is null', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            errorMessage = GENERIC_ERROR_MSG;                        
            return null;
        }
        
        waitForConfirmUpdate = false;
        requestStartTime = System.Now().getTime();
        log.addLine('start confirm sample order at: '+requestStartTime);
        //Begin of Jie PRD fix code
        //confirmCancelRejectOrder(item.Order__r.SAP_Order_ID__c, item.Order__r.Id, true, 1); 
        if(confirmCancelRejectOrder(item.Order__r.SAP_Order_ID__c, item.Order__r.Id, true, 1)){
          PageReference nextPage = new PageReference('/apex/GNE_LWO_SampleOrderConfirmed?accountId='+accountId+'&accountIndicator='+accountIndicator);
                if( item != null)
                nextPage.getParameters().put('oid', item.Order__r.Id); 
                nextPage.setRedirect(true);   
                //log.save('before redirect to next page: '+(System.Now().getTime()-requestStartTime)/1000, GNE_LWO_Logger.DEBUG, GNE_LWO_Logger.SAP_INT);                                             
                return nextPage;
        }
        
        log.addLine('Exit confirmSampleOrder with error');
        return null;         
    }

    public PageReference checkConfirmUpdate() {
        this.debugMessage += 'in checkConfirmUpdate<br/>';
        if(!waitForConfirmUpdate){
            //Not waiting for response, do nothing
            return null;
        }
        
        
        
        requestEndTime = System.Now().getTime();
        
        if(requestEndTime - requestStartTime > 120000) {
            waitForConfirmUpdate = false;
            
            sampleOrderTimeout=true;
            errorMessage= GENERIC_ERROR_MSG;
            return null;
        }       
 
        PageReference nextPage = null;
        
        counter++;
        //System.debug('counter========================='+counter);
        if( item == null) {
            
            waitForConfirmUpdate = false;
            return null;
        }
        
        String orderId =  item.Order__r.Id;    
        
        items = orderController.getOrderItems(orderId);
        
        system.debug( ', sapOrderId====' + item.Order__r.SAP_Order_ID__c +', orderId======='+orderId +', items.size()========='+items.size());                                   
        //System.debug(debugMessage);
        
        if( items != null && items.size() > 0) {
            
            item = items[0];                                               
            
            if( item.Status__r.id == INPROCESS_STATUS_ID || item.Status__r.id == OPEN_STATUS_ID) {
            log.addLine('confirm sample order takes '+(requestEndTime - requestStartTime)/1000+' seconds');
            //log.save('confirm sample order', GNE_LWO_Logger.DEBUG, GNE_LWO_Logger.SAP_INT);
                waitForConfirmUpdate = false;
                
                nextPage = new PageReference('/apex/GNE_LWO_SampleOrderConfirmed?accountId='+accountId+'&accountIndicator='+accountIndicator);
                if( item != null)
                nextPage.getParameters().put('oid', item.Order__r.Id); 
                nextPage.setRedirect(true);                               
                return nextPage;
            }
            
            
        }
        
        return null;                    
    }
    
    
    public PageReference checkRejectUpdate() {
        
        PageReference nextPage = null;
        requestEndTime = System.Now().getTime();
        counter++;
        if( item == null) {
            
            waitForRejectUpdate = false;
            return null;
        }

        String orderId =  item.Order__r.Id;     
        items = orderController.getOrderItems(orderId);
        
        if( items != null && items.size() > 0) {
            
            item = items[0];                                               
            
            if( item.Status__r.id == CANCELLED_STATUS_ID) {
                log.addLine('reject sample order takes '+(requestEndTime - requestStartTime)/1000+' seconds');
                //log.save('reject sample order', GNE_LWO_Logger.DEBUG, GNE_LWO_Logger.SAP_INT);
                waitForConfirmUpdate = false;
                
                nextPage = new PageReference('/apex/GNE_LWO_SampleOrderRejected?accountId='+accountId+'&accountIndicator='+accountIndicator);
                if( item != null) {
                
                nextPage.getParameters().put('oid', item.Order__r.Id); 
                }
                nextPage.setRedirect(true);  
                                           
                return nextPage;
            }
        }
        
        return null;                    
        
    }     
    
    public String getDebugMessage() { return debugMessage;}

    public String accountID {get; set;}

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
        if(accountOptions!=null)
        return accountCount = accountOptions.size();
        else      return accountCount;
        //return accountOptions.size();
    }
    
    /*
    Clear out error message
    */
    protected void clearError(){
        errorMessage = '';
        criticalError = '';         
        debugMessage = '';
    }
    
    /*
* Get list of accounts that match selection. Otherwise, return all accounts.
*/
    protected Boolean updateAccountsList() {
        log.addLine('Entered updateAccountsList()');
        
        try {
            List<Account> accounts;
            
            // Dec 09 2010 - search beyond 999 accounts
            Boolean searchBySAPId = (searchAccountField != null && searchAccountField != 'all' && searchAccountField != '' );
            if (searchBySAPID) { 
                accounts = dataController.getAccountBySAPId(searchAccountField);
                log.addLine('dataController.getAccountBySAPId(' + searchAccountField + ') returned ' + accounts.size() + ' records');
            } else {
                accounts = dataController.getAccounts();
                log.addLine('dataController.getAccounts() returned ' + accounts.size() + ' records');
            }
            
            if (accounts == null || accounts.size() == 0) {
                criticalError = 'No accounts available.';
                log.addLine('Exit updateAccountsList() returning false');
                return false;
            }
            
            if (accountOptions == null) {
                accountOptions = new List<SelectOption>();
            } else {
                accountOptions.clear();
            }
            
            if (accountNames == null) {
                accountNames = new Map<String,String>();
            }

            // Account search field was filled in
            if (searchBySAPID) {
                for (Account account : accounts){
                    if (account.Name.toLowerCase().contains(searchAccountField.toLowerCase())
                            || account.SAP_ID_gne__c.contains(searchAccountField)) {
                        
                        if (accountOptions.size() == 0 )
                        accountID = account.Id;
                        
                        accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')' ));
                        accountNames.put(account.id,account.Name);
                    }
                }

                if (accountOptions.size() == 0) {
                    searchMessage = 'No account found matching <b>"' + searchAccountField + '"</b>';
                    
                    //revert back to the full list
                    searchBySAPID = false;
                } else if (searchAccountField != null) {
                    String suffix  = (accountOptions.size() == 1) ? '' : 's';
                    searchMessage = '<b>' + accountOptions.size() + '</b> account' + suffix + ' found';
                } else {
                    searchMessage = '';
                }
            }
            
            // If list all accounts
            if (!searchBySAPID) {
                if (accountID == null)
                accountID = accounts[0].Id;

                for (Account account : accounts) {
                    accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')'));
                    accountNames.put(account.id,account.Name);
                }
            }
            
            if (searchOptionOn == null && accountOptions.size() >= 10) {
                searchOptionOn = true;
            }
            
            accountCount = accountOptions.size();

        } catch (Exception e) {
            logObjectContent();
            log.save('ERROR updateAccountsList() Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            errorMessage = GENERIC_ERROR_MSG;
        }

        log.addLine('Exit updateAccountsList() returning ' + accountCount + ' accounts');
        return true;
    }
    
    public PageReference updateView(){
        
        clearError();
        
        log.clear();
        log.addLine('Enter GNE_LWO_Controller updateView');
        
        /*if (searchAccountField == null) {
            searchMessage = null;
            log.addLine('SearchAccountField is null and searchMessage is null');
        }*/
        this.searchMessage = null;
        searchAccountField = null;
        
        checkAccount();
        
        return null;
    }

    /* When Search button pressed (admin users)*/    
    public PageReference searchAccounts() {
        log.addLine('Entered GNE_LWO_Controller.searchAccounts()');

        PageReference pageRef = System.currentPageReference();
        searchAccountField = pageRef.getParameters().get('searchAccountField');
        //updateAccountsList();   
        this.accountID=null;
        this.updateAccountDropdownList(); 
        
        /*if( this.accountID !=null) {
        checkAccount();          
    }*/
        this.checkAccount();

        log.logDebug('Exit searchAccounts');
        
        return null;
    }

    /* When Show All Accounts button pressed (admin users)*/
    public PageReference showAllAccounts() {
        log.addLine('Entered GNE_LWO_Controller.showAllAccounts()');
        
        searchAccountField = null;
        this.accountID=null;
        //updateAccountsList();
        this.updateAccountDropdownList();

        /*if (this.accountID != null) {
    checkAccount();          
    }*/
        this.checkAccount();

        log.logDebug('Exit showAllAccounts');

        return null;
    }
    
    /* Get system messages for display at bottom of welcome page */
    public String[] getHomepageMessage() {
        List<System_Message_gne__c> message;        
        Date today = Date.today();
        
        //cust op user should see all type messages
        if(GNE_LWO_Controller.getAdminUser()){
            message = [select Id, System_Downtime_Required_gne__c, Message_gne__c
            from System_Message_gne__c
            where Target_Application_gne__c = 'LWO' 
            and (Valid_From_gne__c <= :today and Valid_To_gne__c >= :today)
            order by Display_Sequence_Number__c];
        }else{
            //regular user should only see messages for their account type
            message = [select Id, System_Downtime_Required_gne__c, Message_gne__c
            from System_Message_gne__c
            where Target_Application_gne__c = 'LWO' 
            and (Valid_From_gne__c <= :today and Valid_To_gne__c >= :today)
            and LWO_Cust_type__c=:accountIndicator
            order by Display_Sequence_Number__c];
        }
        String[] msg = null;
        if (message != null) {
            msg = new String[message.size()];
            
            for (Integer i = 0; i < message.size(); i++) {
                msg[i] = message.get(i).Message_gne__c;
            }
        } else {
            msg = new String[0];
        }
        
        return msg;
    }

    /* Get account info for the current selected account */
    protected void checkAccount() {
        log.addLine('Entered GNE_LWO_Controller.checkAccount()');
        
        this.debugMessage += 'selected accountID is '+this.accountID+'<br/>';
        accountStatusMessage ='';
        
        if( this.accountID == null) {
            log.addLine('Exit checkAccount. accountID is null.');
            return;
        }
        
        try {
            Account accountObj = dataController.getAccountInfoForID(this.accountID);
            this.debugMessage += 'get Account '+accountObj.Id+'<br/>';
            if (accountObj != null) {
                log.addLine('dataController.getAccountInfoForID(' + accountID + ') returned ' + accountObj.name);
                sampleEnrolled = false;
                isDesignee = false;
                complete6Month = false;
                complete1Year = false;        
                remainOrderDays = null;
                remainEnrollmentDays = null;        
                is30DayBeforeOrderExpire = false;
                is30DayBeforeEnrollmentExpire = false;
                
                if (!getSAPAccountInfo(accountObj, 1)) {
                    // getSAPAccountInfo will log the errors
                    this.debugMessage+='getSAPAccountInfo return false <br/>';
                    return;                                                        
                }                                                
                this.debugMessage +=' <br/>^^^^ SAP account id is '+accountObj.SAP_ID_gne__c+' | accountIndicator is '+this.accountIndicator+'<br/>';
                this.billToNum = accountObj.SAP_ID_gne__c;
                if (!sampleEnrolled)
                accountStatusMessage = 'This account is not a sample account.';
                else
                accountStatusMessage='';
                
                InitializeEmailTooltips(null);                                                            
            } else {
                log.addLine('dataController.getAccountInfoForID(' + accountID + ') returned 0 record');
            }
            
        } catch (Exception e) {
            logObjectContent();
            log.save('ERROR checkAccount() Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
            errorMessage = GENERIC_ERROR_MSG;
        }
        
        log.addLine('Exit checkAccount');
    }
    
    public PageReference openEmail()
    {
        Id id = System.currentPageReference().getParameters().get('id'); 
        string emailType = System.currentPageReference().getParameters().get('type');  
        OrderEmailWrapper email = GetEmailById(id, emailType);
        Order_Email__c dbEmail = email.data;
        
        if (GNE_LWO_Controller.userProfile != 'GNE-LWO-CUSTOPS')
        dbEmail.IsRead__c = true;
        
        try
        {
            update dbEmail;
        }       
        catch (DmlException e) 
        {
            for (Integer i = 0; i < e.getNumDml(); i++) 
            {
                emailBody += 'Error: ' + e.getDmlMessage(i);            
                System.debug(e.getDmlMessage(i)); 
            }
            return null;    
        }        
        email.isOpen = true;    
        emailBody = email.data.Body__c;     
        return null;
    }
    
    public PageReference closeEmail()
    {
        Id id = System.currentPageReference().getParameters().get('id');
        string emailType = System.currentPageReference().getParameters().get('type');
        OrderEmailWrapper email = GetEmailById(id, emailType);
        email.isOpen = false; 
        emailBody = '';
        return null;
    }
    
    public PageReference CalculateUnreadCom()
    {
        unreadMessagesCom = string.valueOf(GetNumberOfUnread(emailsCom)) + ' UNREAD';
        CloseAllOpenEmails(emailsCom);
        emailBody = '';
        return null;
    }
    
    public PageReference CalculateUnreadSam()
    {
        unreadMessagesSam = string.valueOf(GetNumberOfUnread(emailsSam)) + ' UNREAD';
        CloseAllOpenEmails(emailsSam);
        emailBody = '';
        return null;
    }
    
    public PageReference openPDF() 
    {
        Id id = System.currentPageReference().getParameters().get('id');
        PageReference pageRef = new PageReference('/apex/GNE_LWO_DisplayOrderEmail?id=' + Id);
        
        return pageRef;
    }
    
    public PageReference fake()
    {return null;}
    
    protected void CloseAllOpenEmails(List<OrderEmailWrapper> emails)
    {
        for (OrderEmailWrapper email : emails)
        {
            email.isOpen = false;
        }
    }
    
    protected OrderEmailWrapper GetEmailById(Id id, string emailType)
    {
        OrderEmailWrapper result;
        List<OrderEmailWrapper> emails = null;
        
        if (emailType == 'Commercial')
        emails = emailsCom;
        else if (emailType == 'Sample')
        emails = emailsSam;
        
        for (OrderEmailWrapper email : emails)
        {
            if (email.data.Id == id)
            {
                result = email;
                break;
            }
        }   
        return result;
    }
    
    protected Integer GetNumberOfUnread(List<OrderEmailWrapper> emails)
    {
        Integer counter = 0;
        for (OrderEmailWrapper email : emails)
        {
            if (email.data.IsRead__c == false)
            counter++;
        }
        return counter;
    }
    
    protected void InitializeEmailTooltips(List<Account> accounts) {
        if (accounts == null)
        log.addLine('Entered InitializeEmailTooltips(accounts=null)');
        else
        log.addLine('Entered InitializeEmailTooltips(accounts=' + accounts.size() + ')');
        
        //initialize bubble popup member variables
        emailBody = '';     
        emailsCom = new List<OrderEmailWrapper>();
        emailsSam = new List<OrderEmailWrapper>();
        
        integer counterCom = 0;
        integer counterSam = 0;
        
        // Get email list    
        List<Order_Email__c> records;
        List<Order_Email__c> orgEmailsList;
        
        // If admin user, get email for selected account
        //if (GNE_LWO_Controller.getAdminUser()) {
        if(accountIndicator == 'BTH')
        {
            records = [Select o.hasAttachment__c, o.Subject__c, o.Id, o.CreatedDate, o.Body__c, o.IsRead__c, o.Email_Type__c, (Select Id From Attachments) 
            From Order_Email__c o
            Where o.CreatedDate = LAST_N_DAYS:210 
            AND o.Account__c = :this.accountID  
            AND IsRead__c=false     
            AND Account_type_gne__c != '' 
            Order by o.CreatedDate desc limit 5];
        }
        else
        {
            records = [Select o.hasAttachment__c, o.Subject__c, o.Id, o.CreatedDate, o.Body__c, o.IsRead__c, o.Email_Type__c, (Select Id From Attachments) 
            From Order_Email__c o
            Where o.CreatedDate = LAST_N_DAYS:210 
            AND o.Account__c = :this.accountID  
            AND o.Account_type_gne__c = :accountIndicator   
            AND IsRead__c=false   
            Order by o.CreatedDate desc limit 5];
        }
        orgEmailsList  = records;
        log.addLine(records.size() + ' email records found for account ' + accountID);
        
        // If customer, get email for all affiliated accounts
        /*    } else {
        if (accounts == null)
            accounts = dataController.getAccounts();
            
        if (accounts == null || accounts.size() == 0) {
            records = new List<Order_Email__c>();
            orgEmailsList = new List<Order_Email__c>();
        } else {
            List<string> affiliatedAccountID = new List<string>();

            for (Account account : accounts) {               
                affiliatedAccountID.add(account.Id); 
            }
            if(accountIndicator == 'BTH')
            {
                records = [Select o.hasAttachment__c, o.Subject__c, o.Id, o.CreatedDate, o.Body__c, o.IsRead__c, o.Email_Type__c, (Select Id From Attachments) 
                        From Order_Email__c o
                        Where o.CreatedDate = LAST_N_DAYS:210
                        AND o.Account__c IN :affiliatedAccountID
                        Order by o.CreatedDate desc];
            }
            else
            {
                records = [Select o.hasAttachment__c, o.Subject__c, o.Id, o.CreatedDate, o.Body__c, o.IsRead__c, o.Email_Type__c, (Select Id From Attachments) 
                        From Order_Email__c o
                        Where o.CreatedDate = LAST_N_DAYS:210
                        AND o.Account__c IN :affiliatedAccountID
                        AND o.Account_type_gne__c = :accountIndicator
                        Order by o.CreatedDate desc];
            }
            orgEmailsList  = records;
        }
        log.addLine(records.size() + ' email records found for affiliated accounts');
    }*/
        
        for (Order_Email__c record : records) {
            if (record.Email_Type__c == 'Commercial') {
                if (record.IsRead__c == false)
                counterCom++;
                emailsCom.add(new OrderEmailWrapper(record));
            }
            
            if (record.Email_Type__c == 'Sample') {
                if (record.IsRead__c == false)
                counterSam++;
                emailsSam.add(new OrderEmailWrapper(record));
            }
        }
        for(Order_Email__c email: orgEmailsList)
        {
            OrderEmailWrapperWidget oew = new OrderEmailWrapperWidget(email.Subject__c,email.CreatedDate,email.Id);
            emailsList.add(oew);
        }    
        unreadMessagesCom = string.valueOf(counterCom) + ' UNREAD';
        unreadMessagesSam = string.valueOf(counterSam) + ' UNREAD';

        log.addLine('Exit InitializeEmailTooltips');
    }
    
    /************************************************************    
*  Date        Name        Description
*  2010-04-20  wilczekk    Added wrapper pattern to Order_Email__c object - it would be good 
                            to have a Map with Id as a key instead of List of emails
                            but Map is not sorted collection and output table is messed up with every rerender.
                            Sorting Map items by CreateDate would be inefficient when performed with every rerender.              
*************************************************************/
    class OrderEmailWrapper
    {
        public Order_Email__c data { get; protected set; }
        public Boolean isOpen { get; set; }
        public Boolean hasBody { get; set; }
        public string mailSubject { get; set; }
        
        public OrderEmailWrapper(Order_Email__c data)
        {
            this.data = data;
            this.isOpen = false;
            
            if (data.Body__c != null && data.Body__c.length() > 0)    
            {       
                if (data.Body__c == '<html><body></body></html>')
                this.hasBody = false;
                else
                this.hasBody = true;
            }            
            else
            this.hasBody = false;
            
            this.mailSubject = data.Subject__c + ' - ' + data.CreatedDate.format();
        }       
    }
    
    public PageReference openEmailWidget()
    { 
        Id emailId = System.currentPageReference().getParameters().get('id');
        PageReference pr = new PageReference('/apex/LWO_Message_Center?eid='+emailId+'&accountId='+this.accountID+'&accountIndicator='+accountIndicator);
        pr.setRedirect(true);
        return pr;
    }
    
    class OrderEmailWrapperWidget
    {
        public ID mailId { get; set; }
        public string mailSubject { get; set; }
        public string emailDate { get; set; }
        public string dateFormat { get; set; }
        
        public OrderEmailWrapperWidget(string mailSubject, Datetime emailDate,ID mailId)
        {
            this.mailId = mailId;
            this.mailSubject = mailSubject;
            this.emailDate = emailDate.format('MMMM d,yyyy H:m a');  
            this.dateFormat = this.emailDate;
        }       
    }   

    /* Dump object contect for debugging */
    protected String getLogStr(String str) { return (str == null) ? '<null>' : str; }
    protected String getLogStr(Boolean bool) { return (bool == null) ? '<null>' : ((bool) ? 'true' : 'false'); }
    protected String getLogStr(Integer num) { if (num == null) return '<null>'; return ''+num; }
    protected String getLogStr(Long num) { if (num == null) return '<null>'; return ''+num; }
    protected void logObjectContent() {
        log.addLine('*** GNE_LWO_Controller ***');
        log.addLine('CANCELLED_STATUS_ID=' + getLogStr(GNE_LWO_Controller.CANCELLED_STATUS_ID));
        log.addLine('ENDPOINT=' + getLogStr(GNE_LWO_Controller.ENDPOINT));
        log.addLine('INPROCESS_STATUS_ID=' + getLogStr(GNE_LWO_Controller.INPROCESS_STATUS_ID));
        log.addLine('OPEN_STATUS_ID=' + getLogStr(GNE_LWO_Controller.OPEN_STATUS_ID));        
        log.addLine('SHIPPED_STATUS_ID=' + getLogStr(GNE_LWO_Controller.SHIPPED_STATUS_ID));
        log.addLine('accountCount=' + getLogStr(this.getAccountCount()));
        log.addLine('accountExpirationDateString=' + getLogStr(accountExpirationDateString));
        log.addLine('accountID=' + getLogStr(accountID));
        log.addLine('accountNames[]=' + ((accountNames==null)?'<null>':''+accountNames.size()));
        log.addLine('accountOptions[]=' + ((accountOptions==null)?'<null>':''+accountOptions.size()));
        log.addLine('accountStatusMessage=' + getLogStr(accountStatusMessage));
        log.addLine('addressValue=' + getLogStr(addressValue));
        log.addLine('allotmentQuantity=' + getLogStr(allotmentQuantity));
        log.addLine('billToAddress=' + getLogStr(billToAddress));
        log.addLine('billingAddress=' + ((billingAddress==null)?'<null>':billingAddress.id));
        log.addLine('canPlaceOrder=' + canPlaceOrder);
        log.addLine('cancelMessage=' + getLogStr(cancelMessage));
        log.addLine('complete1Year=' + getLogStr(complete1Year));
        log.addLine('complete6Month=' + getLogStr(complete6Month));
        log.addLine('counter=' + counter);
        log.addLine('criticalError=' + getLogStr(criticalError));
        log.addLine('currentEnv=' + getLogStr(currentEnv));
        log.addLine('debug=' + GNE_LWO_Controller.debug);
        log.addLine('debugMessage=' + getLogStr(debugMessage));
        log.addLine('emailBody=' + getLogStr(emailBody));
        log.addLine('emailsCom[]=' + ((emailsCom==null)?'<null>':''+emailsCom.size()));
        log.addLine('emailsSam[]=' + ((emailsSam==null)?'<null>':''+emailsSam.size()));
        log.addLine('encrypted=' + getLogStr(encrypted));
        log.addLine('errorMessage=' + getLogStr(errorMessage));
        log.addLine('is30DayBeforeEnrollmentExpire=' + getLogStr(is30DayBeforeEnrollmentExpire));
        log.addLine('is30DayBeforeOrderExpire=' + getLogStr(is30DayBeforeOrderExpire));
        log.addLine('isDesignee=' + getLogStr(isDesignee));
        log.addLine('items=' + ((items==null)?'<null>':''+items.size()));
        log.addLine('menuOption=' + getLogStr(menuOption));
        log.addLine('NDC=' + getLogStr(NDC));
        log.addLine('orderExpirationDateString=' + getLogStr(orderExpirationDateString));
        log.addLine('paymentError=' + getLogStr(paymentError));
        log.addLine('remainEnrollmentDays=' + getLogStr(remainEnrollmentDays));
        log.addLine('remainOrderDays=' + getLogStr(remainOrderDays));
        log.addLine('requestEndTime=' + getLogStr(requestEndTime));
        log.addLine('requestStartTime=' + getLogStr(requestStartTime));
        log.addLine('sampleAccountId=' + getLogStr(sampleAccountId));
        log.addLine('sampleEnrolled=' + getLogStr(sampleEnrolled));
        log.addLine('sampleOrderDesigneeEmail1=' + getLogStr(sampleOrderDesigneeEmail1));
        log.addLine('sampleOrderDesigneeEmail2=' + getLogStr(sampleOrderDesigneeEmail2));
        log.addLine('searchAccountField=' + getLogStr(searchAccountField));
        log.addLine('searchOptionOn=' + getLogStr(searchOptionOn));
        log.addLine('shipToAddress=' + getLogStr(shipToAddress));
        log.addLine('shippingAddress=' + ((shippingAddress==null)?'<null>':shippingAddress.id));
        log.addLine('shippingAddresses=' + ((shippingAddresses==null)?'<null>':''+shippingAddresses.size()));
        log.addLine('testUser=' + getLogStr(GNE_LWO_Controller.testUser));
        log.addLine('unreadMessagesCom=' + getLogStr(unreadMessagesCom));
        log.addLine('unreadMessagesSam=' + getLogStr(unreadMessagesSam));
        log.addLine('userID=' + getLogStr(GNE_LWO_Controller.userID));
        log.addLine('userName=' + getLogStr(GNE_LWO_Controller.userName));
        log.addLine('userProfile=' + getLogStr(GNE_LWO_Controller.userProfile));
        log.addLine('waitForAOCUpdate=' + getLogStr(waitForAOCUpdate));
        log.addLine('waitForConfirmUpdate=' + getLogStr(waitForConfirmUpdate));
        log.addLine('waitForRejectUpdate=' + getLogStr(waitForRejectUpdate));
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
        if (aocItem==null){
            log.addLine('aocItem=<null>');
        } else {
            log.addLine('aocItem=');
            log.addLine('. ID='+aocItem.id);
            log.addLine('. SAP_ORDER_ID__C='+aocItem.SAP_ORDER_ID__C);
        }
        log.addLine('*** End GNE_LWO_Controller ***');
    }    

    public Boolean updateAccountDropdownList(){
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
        
        Boolean searchAccount= (this.searchAccountField !=null && this.searchAccountField.trim().length()>0)? true:false;
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
    
/********** LED project code ****************/

    public String billToNum {get; protected set;}
    protected List<SelectOption> shipAddressOptions;
    protected String accountIndicator;
    protected List<Map<String,String>> creditCards = new List<Map<String,String>>();
        //display shipping address selection error
    public String addressSelectionError {get; protected set;}
        //properties    
    public List<LWOProduct> products {get; protected set;}
    

    
//LED project requirment - to display an alert message if any credit card is expiring in 75 days
    protected void checkCreditCardExpirationDate(){
        log.addLine('Enter checkCreditCardExpirationDate()');
        if(accountIndicator==null || accountIndicator=='SAM') return;

        if(creditCards!=null && creditCards.size()>0){          
            Integer counter=0; 
            Date today= Date.today();
            //Jie fix - on hold
            Integer expiredCardCounter=0;
            for(Map<String,String> card: creditCards){  
                String dateString =  card.get('expirationDate');
                Date expiredDate;
                try{
                    if(dateString!=null && dateString.trim().length()>0)
                    expiredDate =  (Date.valueOf(dateString));
                    
                    if(today.daysBetween(expiredDate)<=0) expiredCardCounter++;
                    else if(today.daysBetween(expiredDate) <=75)  counter+=1;  
                    
                    system.debug( 'ard.expirationDate='+expiredDate+', WILL EXPIRE IN '+today.daysBetween(expiredDate)+' days.'); 
                }catch(TypeException e){
                    log.addLine(e.getMessage());
                }                    
            }
            
            if(counter>0)
            errorMessage='You have a card expiring within 75 days. Please go to Your Account to update your credit cards.';
            if(expiredCardCounter == creditCards.size())
            errorMessage ='Your credit card on file has expired. Please add a new credit card to your account.  If you would like to pay by wire transfer, please contact a LUCENTIS Direct Customer Specialist at 800.963.1778.';            
            log.addLine('Exit checkCreditCardExpirationDate() - '+counter+' cards expired');
        }  
    }   
    
    //wilczekk: this function will be commented out when entire wizard is ready
    public PageReference ContinueCommercial(){
        this.debugMessage +=('here we go, continue commercial order');
        PageReference nextPage = new PageReference('/apex/LWO_CommercialOrder');
        Boolean pageError=false;
        Boolean continueOrder=false;
        this.errorMessage = '';
        if(addressValue!=null && addressValue.trim()!='default'){
            nextPage.getParameters().put('SelectedShippingAddress', addressValue);
        }
        else 
        {
            addressSelectionError = 'Please select a shipping address';
            return null;
        }
        if(products!=null) {
            for(LWOProduct p : products){   
                if(p.qty <0){
                    pageError=true;
                    p.qtyError='Order quantity must be greater than 0.';
                    
                }   else if(p.qty>p.product.max_QTY__c){
                    pageError=true;
                    p.qtyError='Maximum quantity of vials is '+p.product.max_QTY__c+' per order.';
                }  else {  
                    p.qtyError=null;
                    if(p.qty>0){
                        nextPage.getParameters().put(p.product.NDC_Number_gne__c, p.qty+''); 
                        continueOrder=true;
                    }
                }
                system.debug(p.product.NDC_Number_gne__c);
            }
        }else{
            criticalError='System error! No Product found.';
            PageReference page=new PageReference('/apex/LWO_ErrorPage');
            page.getParameters().put('ErrorMessage', criticalError);
            page.setRedirect(true);
        }
        
        if((!pageError) && (!continueOrder)){
            //user hasn't add qty to any product
            this.errorMessage = 'You need to add QTY for at lease one product to continue commercial order process';
        }
        
        if((!pageError) && continueOrder){
            nextPage.getParameters().put('billToNum', billToNum);
            nextPage.getParameters().put('accountId', accountID);
            nextPage.setRedirect(true);
        }else{
            nextPage=System.currentPageReference();
            nextPage.setRedirect(false);
        }
        return nextPage;
    } 
    
    
     public Boolean getIsIe9(){
       String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');        
        if(userAgent.contains('Trident/5'))
       return true;
       else 
       return false; 
      
    }
    
    
    public PageReference AdminContinueCommercial(){
        log.addLine('Enter AdminContinueCommercial()');
        this.errorMessage = null;
        if(this.accountID==null || this.accountID.length()<=0){
            this.errorMessage = 'Please select an account before continue commercial order';
            log.addLine('AdminContinueCommercial() - '+errorMessage);
            return null;
        }
        Account acc=dataController.getAccountInfoForID(this.accountID);
        if(acc==null || acc.SAP_ID_gne__c==null || acc.SAP_ID_gne__c.length()<=0){
            this.errorMessage ='Can not find SAP sold to account number for selected account';
            log.addLine('AdminContinueCommercial() - '+errorMessage);
            return null;
        }
        if(shippingAddresses == null || shippingAddresses.size()<=0){
            this.errorMessage = 'There is no shipping addresses set up for selected account.';
            log.addLine('AdminContinueCommercial() - '+errorMessage);
            return null;
        }
        if(accountIndicator == null || accountIndicator.length()<=0){
            this.errorMessage = 'Can not find Account type for selected account.';
            log.addLine('AdminContinueCommercial() - '+errorMessage);
            return null;
        }
        billToNum = acc.SAP_ID_gne__c; 
        //PageReference nextPage = Page.GNE_LWO_Review;
        PageReference nextPage = Page.GNE_LWO_Order;
        nextPage.getParameters().put('SelectedShippingAddress', addressValue);
        nextPage.getParameters().put('billToNum', billToNum);
        nextPage.getParameters().put('accountId', accountID);
        nextPage.getParameters().put('accountIndicator', accountIndicator);
        //nextPage.getParameters().put('secondEntry', 'true');
        nextPage.setRedirect(true);
        log.addLine('Exit AdminContinueCommercial() - billToNum='+billToNum+' : accountID='+accountID+' : accountIndicator='+accountIndicator+' : addressValue='+addressValue);
        this.debugMessage='';
        return nextPage;
    }
    
        //Object model class for product
     public class LWOProduct {
        public Product_vod__c product {get; set;}
        public Integer qty {get; set;}
        public String qtyError {get; set;}
        
        
        public LWOProduct (Product_vod__c item) {
            this.product = item;
            qty=0;
            qtyError=null;
        }
        
        public LWOProduct (Product_vod__c item, Integer q) {
            this.product = item;
            qty=q;
            qtyError=null;
        }
    }
    
    //Jie added on 1/27/14 for PODIS project
    private void trackingLogin(){
        PageReference pageRef = System.currentPageReference();
        String ims=pageRef.getParameters().get('IMS');
        
        if(ims!=null && ims.trim().length()>0 && billToNum!='333459') {
            try{
                LWO_Login_Tracking__c tracking = new LWO_Login_Tracking__c();
                DateTime now=System.now();
                tracking.IMS__c = ims;
                tracking.login_date__c = System.today();
                tracking.login_timestampe__c = now;
                tracking.SAP_account_Number__c=billToNum;
                tracking.AccountName__c=accountName_PODIS;
                tracking.Login_User__c=UserInfo.getUserId();
                Integer hour=now.hour();
                Integer minute=now.minute();
                Integer second=now.second();
                String timeStr=hour+':'+minute+':'+second;
                tracking.login_time__c=timeStr;
                
                insert tracking;
            
            }catch(Exception e){
                log.addLine('Error happened in trackingLogin - '+e.getMessage());
            }
        }
    }
    
    protected string testTracking='';
}