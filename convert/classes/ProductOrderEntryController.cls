public  without sharing class ProductOrderEntryController {
    
    static ProductOrderController orderController = null;
    static ProductDataController dataController = null;
    
    /*
    static GneProductOrderGetAccountInfo.AccountInfo accountInfo = null;
    static GneProductOrderSimulateOrder.SimulateOrder simulateOrder = null;
    static GneProductOrderCreateOrder.CreateOrder createOrder = null;
    static GneProductOrderCancelOrder.CancelOrder cancelOrder = null;
    */
    static ProductOrderSFDCProxyController.AccountInfo accountInfo = null;
    static ProductOrderSFDCProxyController.SimulateOrder simulateOrder = null;
    static ProductOrderSFDCProxyController.CreateOrder createOrder = null;
    static ProductOrderSFDCProxyController.CancelOrder cancelOrder = null;
    
    
    
    
   
    //Member variables
    private Product_Order_gne__c order = null;
    private Product_Order_Item_gne__c item = null;
    private Product_Order_Address_gne__c billingAddress = null;
    private Product_Order_Address_gne__c shippingAddress = null;
    
    private List<Map<String,String>> creditCards = null;
     
    private List<Product_Order_Payment_gne__c> orderPayments = null;
    private List<Product_Order_Payment_gne__c> orderPaymentsKeep = null;
    private List<Product_Order_Item_gne__c> items = null;
   
    private Boolean encrypted = true;
    private String currentEnv = null;
    
    private Map<String, Map<String,String>> shippingAddresses = null;
    
    private String currentDateValue = null;
    private List<SelectOption> accountOptions = null;
    private List<SelectOption> productionOptions = null;
    private List<SelectOption> shipAddressOptions = null;
    
    private String billToAddress = null;
    private String shipToAddress = null;
    private String productName = null;
    private String NDC;
    private String addressValue = null;
    
    private String orderNumber = null;
    private String billToName = null;
    private String billToAccountNumber = null;
    private String searchAccountField = null;
    
    private String sapOrderId = null;
    private String itemIdFromHistory = null;
    
    // History page search filters - passed in with Detail page viewing
    public String selectedStatus = null;
    public String selectedSearchField = null;
    public String selectedFrom = null;
    public String selectedTo = null;
   
    private String criticalError = null;
    private String errorMessage = null;
    private String paymentError = null;
    private String debugMessage  = null;
    private String searchMessage  = null;
    
    
    private String balanceColor = '#000';
    private String balanceMsg = 'Select "Continue" and review your order';
                
    private Datetime currentTime = null;
    private Date currentDate = null;
    
    public boolean canPlaceOrder {get; set;}
    public boolean firstView {get; set;}
    public Integer paymentTerm {get; set;}
    public String createOrderMessage {get; set;}
    public String cancelMessage {get; set;}
    public Boolean driveChangeByQuantity {get; set;}
    public Boolean searchOptionOn {get; set;}
    
    public Boolean debug {get; set;}
     
    Product_Order_Item_gne__c priceHolder = null;
    Product_Order_Payment_gne__c totalPayment = null;
    
    
    
    static {
         dataController = new ProductDataController();
         orderController = new ProductOrderController();
         
         accountInfo = new ProductOrderSFDCProxyController.AccountInfo();
         simulateOrder = new ProductOrderSFDCProxyController.SimulateOrder();
         createOrder = new ProductOrderSFDCProxyController.CreateOrder();
         cancelOrder = new ProductOrderSFDCProxyController.CancelOrder();
         
         /*
         accountInfo = new GneProductOrderGetAccountInfo.AccountInfo();
         simulateOrder = new GneProductOrderSimulateOrder.SimulateOrder();
         createOrder = new GneProductOrderCreateOrder.CreateOrder();
         cancelOrder = new GneProductOrderCancelOrder.CancelOrder();
         */
    }
    
    // response message containing SAP credit card number
    // e.g. -PMOS-6037-00001000000025 Invalid Credit Card
    // group(1) = 6037
    // group(2) = 'Invalid Credit Card'
    Pattern ccPattern = Pattern.compile('\\-[A-Z]\\w{3}\\-(\\d{4})\\-\\w+ ?(.*)$');
    Pattern numbersOnlyPattern = Pattern.compile('(\\d+) ?(.*)$');
    Pattern numbersOnly = Pattern.compile('\\d+');

    public String supportEmail {
      get {
      	if(supportEmail == null) {
      		return 'lwo-support-d@gene.com';
      	}  
      	return supportEmail;
      }
      set;	
    } 

    /*
    Default constructor
    */
    public ProductOrderEntryController(){
    	
		if(GNE_LWO_CustomSettingsHelper.self().getLWOConfig().SUPPORT_EMAIL__c != null) {
          supportEmail = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().SUPPORT_EMAIL__c;
        }    	
        
        debug = false;
        
        
          /*
          First check to see if this is invoked with the right entry point or not
          */
          PageReference pageRef = System.currentPageReference();
          String url = pageRef.getUrl();
                 
          if(!url.contains('/ProductOrderEntry') && !url.contains('/ProductOrderDetail') ){
            // wrong entry point
            criticalError = 'Please click "Buy" link on the top to start web ordering';
            return;
          }
         
         currentEnv = ProductOrderSFDCProxyController.invokeEndpoint;
         debugMessage = 'endPoint: ' +  currentEnv + '<br/>';
         
         //Check user profile to enforce whether user can place an order or not
         String profileId = UserInfo.getProfileId();
         Profile userProfile = [select Name from Profile where id =: profileId];
         String profileName = userProfile.Name;
         if(profileName=='Web Ordering Admin' || profileName=='GNE-LWO-CUSTOPS') {
         //if(profileName == 'System Administrator' || profileName=='Web Ordering Admin' || profileName=='GNE-LWO-CUSTOPS') {
            canPlaceOrder = false;
         }
         else {
            canPlaceOrder  = true;
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
          if(order!=null){
              return;
          }
                        
          // from ViewOrder 
          String orderId = pageRef.getParameters().get('id');
          selectedStatus = pageRef.getParameters().get('selectedStatus');
          selectedSearchField = pageRef.getParameters().get('selectedSearchField');
          selectedFrom = pageRef.getParameters().get('selectedFrom');
          selectedTo = pageRef.getParameters().get('selectedTo');
          if(orderId!=null){
                order = orderController.getOrderByOrderId(orderId, false);
          }
                
           //Populate new order if parameter is not passed in to retrieve existing order failed to retrieve order by id or nmae
           if(order==null) {
                order = orderController.createNewOrder();
                item = orderController.initLineItem();
                populateNewOrderInfo();
           } else {          
                populateOrderInfoForExistingOrder(orderId);
           }
     }
                
    /*
    Populate account dropdown
    */
    public List<SelectOption> getAccounts(){
        return accountOptions;
    }
                
    public Integer getAccountCount() {
         return accountOptions.size();
    }
    
    /*
     Populate Information for a brand New Order
    */
    private void populateNewOrderInfo(){
         if(order==null){
              return;
         }
                                
         if(!updateAccountsList()){
             return;
         }
         
         //Get Product Info
         updateProductInfo();
        
         updateBillToRelated();
         firstView = true;
       
    }
    
    /*
    Populate order info
    */
    public void populateOrderInfoForExistingOrder(String existingOrderId){
        if(order==null){
              return;
        }
                        
        if(!updateAccountsList()){
             return;
        }
                                
        //Populate order info
        
        billToName = order.Bill_To__r.Name;
        orderNumber = order.Name;
        
        billToAccountNumber = order.Bill_To__r.SAP_ID_gne__c;
        driveChangeByQuantity=false;
                       
        //Select order payments
        List<Product_Order_Payment_gne__c> oldPayments = null;
        orderPayments = new List<Product_Order_Payment_gne__c>();
        oldPayments  = orderController.getOrderPayments(existingOrderId);
        
        items = orderController.getOrderItems(existingOrderId);
        item = items[0];
        
        productName = item.Product__r.Name;
                              
        if(oldPayments!=null && oldPayments.size()>0){
            if(oldPayments.get(0).Quantity__c!=null){
                 driveChangeByQuantity=true;
            }
        }               
                
        //Get Product Info
        updateProductInfo();
        
        //Construct Bill To Address 
        List <Product_Order_Address_gne__c> orderAddresses = [select Id, Name, Order__r.Name, Address_Line_2__c, Address_Line_4__c,
            City__c,  State__c, Zip__c, Zip_4__c, Country__c, Billing__c from Product_Order_Address_gne__c where Order__c=:existingOrderId];
            
        for(Product_Order_Address_gne__c address:orderAddresses){
            if(address.Billing__c){
                  this.billToAddress = dataController.constructAddressForDisplay(address);
            } else {
                  this.shipToAddress = dataController.constructAddressForDisplay(address);
            }
            orderNumber = address.Order__r.Name;
        }
        
       //Set payment information
       if(oldPayments!=null && oldPayments.size()>0){
             Integer i = 0;
             for(Product_Order_Payment_gne__c payment:oldPayments){
                  orderPayments.add(payment.clone(false));
             }
        }
        
     }
 
     /*
     Update account selection list
     */
     public boolean updateAccountsList(){
           List<Account> accounts = dataController.getAccounts();
           if(accounts==null || accounts.size()==0){
                   criticalError = 'You are not affiliated with any account to place a web order. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                   return false;
           }
           if(accountOptions==null){
                   accountOptions = new List<SelectOption>();
           } else{
                   accountOptions.clear();
           }
           String accountNumber = null;
                                
           if(accounts!=null){
                //accountOptions.add(new SelectOption('-1', '--Select an Account --'));
                for (Account account : accounts){
                    
                    // Account search field was filled in
                    if (searchAccountField != null && searchAccountField != 'all' && searchAccountField != '') {
                        if (account.Name.toLowerCase().contains(searchAccountField.toLowerCase())
                            || account.SAP_ID_gne__c.contains(searchAccountField)) {
                            
                            if(order.Bill_To__c==null){
                                order.Bill_To__c = account.Id;
                            }
                            
                            accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')' ));
                        }
                    } else {
                        
                        if(order.Bill_To__c==null){
                          order.Bill_To__c = account.Id;
                        }
                        
                        accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')'));
                   
                   }
                }
           }
           
           if (accountOptions.size() == 0) {
                searchMessage = 'No account found starting with <b>"' + searchAccountField + '"</b>';
                //revert back to the full list
                for (Account account : accounts){
                    
                    if(order.Bill_To__c==null){
                          order.Bill_To__c = account.Id;
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
           
           return true;
          
    }
    
    public PageReference searchAccounts() {
        PageReference pageRef = System.currentPageReference();
        searchAccountField = pageRef.getParameters().get('searchAccountField');
        
        updateAccountsList();
        //searchAccountField = null;
        return null;
    }
    
    public PageReference showAllAccounts() {
        PageReference pageRef = System.currentPageReference();
        searchAccountField = null;
        updateAccountsList();
        
        return null;
    }
    
                
    /*
    Bill To Account Changed
    */
    public PageReference billToChanged(){
         
         addressValue = null;
         billingAddress = null;
         shippingAddress = null;
         
         if (searchAccountField == null) {
            searchMessage = null;
         }
         searchAccountField = null;
         
         firstView = true;
         
         //clear previous payments
         orderPayments = null;
                         
         //Update BillTo related info
         updateBillToRelated();
         
         return null;
    }
                
    /*
    Update Bill to Related Information, including
    -Shipping Address
    -Billing Address
    -Account Name, Email
     */
    private PageReference updateBillToRelated(){
        
            String accountId  = order.Bill_To__c;
            clearError();
             
            if(accountId==null) {
                //No billto has selected for the order
                errorMessage += 'No account has been selected for this order. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                debugMessage += 'accountID == null<br/>';
                return null;
            }
            
            // call ESB interface to get account information
            Account acctInfo = dataController.getAccountInfoForID(accountId);
            if (acctInfo.SAP_ID_gne__c == null || acctInfo.SAP_ID_gne__c == '') {
            // duyent - 022511 add notification
            String username = UserInfo.getUserName();
            string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - updateBillToRelated() acctInfo.SAP_ID_gne__c is null OR acctInfo.SAP_ID_gne__c is blank ';
             sendNotification (MessageBody);
                errorMessage = 'We are experiencing some technical difficulties. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                return null;
            }
            
         return getSAPAccountInfo(acctInfo, 1);
           
    }
   
   // duyent 022511 - send notification
 private void SendNotification(string MessageBody)
    { 
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.setToAddresses( new String[] { supportEmail } ); 
    message.setSubject( 'SFDC - LWO error');
    message.setPlainTextBody( MessageBody );
    // Send our message.
    Messaging.sendEmail( new Messaging.Email[] { message } );

    }

    private PageReference getSAPAccountInfo(Account acctInfo, Integer attempt){
          try {
                message = '';
                Matcher ccMatcher = null;
                Boolean ccMatched = null;
            
                ProductOrderSFDCProxyController.AccountInfoResponseItem[] responseItems = accountInfo.accountInfo(acctInfo.SAP_ID_gne__c);
                
                if (responseItems == null || responseItems.size() == 0) {
                // duyent - 022511 add notification
                String username = UserInfo.getUserName();
                string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - getSAPAccountInfo() responseItems is NULL';
                sendNotification (MessageBody);
                    errorMessage += 'We are experiencing some technical difficulties. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                    return null;
                }
                
                shippingAddresses = new Map<String, Map<String,String>>();
                
                if(shipAddressOptions==null){
                    shipAddressOptions = new List<SelectOption>();
                } else {
                    shipAddressOptions.clear();
                }
                creditCards = new List<Map<String,String>>();
                String status;  
                String paymentTermString;       
                for(ProductOrderSFDCProxyController.AccountInfoResponseItem response:responseItems){
                    String responseType = response.ResponseItemType;
                    status = response.Status;
                    debugMessage += responseType + ':' + status + ':' + response.Message + ':' + response.cardNumber + '<br/>';
                    if (status == null) {
                        status = 'true';
                    }
                    if (status == 'syserror') {
                       // duyent - 022511 add notification
                       String username = UserInfo.getUserName();
                        string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - ProductOrderSFDCProxyController.AccountInfoResponseItem[] response status = syserror';
                       sendNotification (MessageBody);
                        errorMessage = 'We are experiencing some technical difficulties. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                        message += response.Message + '; ';
                        billToAddress = '';
                        return null;
                    } else if (status == 'false') {
                        // duyent - 022511 add notification
                        String username = UserInfo.getUserName();
                        string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - ProductOrderSFDCProxyController.AccountInfoResponseItem[] response status = false';
                         sendNotification (MessageBody);
                        errorMessage = 'We were not able to create your order. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                        message += response.Message + '; ';
                        billToAddress = '';
                        //return null;
                    } else {
                        if (responseType == 'account') {
                            order.Order_Contact_Email__c = response.contactEmail;
                            paymentTermString = response.defaultPaymentTerm;
                            
                            // paymentTermString = 'Z080' for cash payment term
                            if (response.defaultPaymentTerm.startsWith('Z')) {
                                paymentTerm = null;
                            } else if (response.defaultPaymentTerm == 'CC') {
                                paymentTerm = 60;
                            } else {
                                paymentTermString = (response.defaultPaymentTerm).split('CC',2)[1];
                                if (paymentTermString == '00') {
                                    paymentTerm = 0;
                                } else if (paymentTermString == '60') {
                                    paymentTerm = 60;
                                }
                            }
                            debugMessage += 'payment term: ' + response.defaultPaymentTerm + '/' + paymentTerm + '<br/>';
                            
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
                            if (response.billing) {
                                billingAddress = dataController.populateAddress(responseAddress,true);
                                this.billToAddress = dataController.constructAddressForDisplayMap(responseAddress);
                                
                            } else {
                                shippingAddresses.put(response.addressNo,responseAddress);
                                shippingAddress = dataController.populateAddress(responseAddress,false);
                                shipAddressOptions.add(new SelectOption(response.addressNo, dataController.constructAddressForSelect(responseAddress)));
                                
                                if(addressValue==null){
                                    addressValue = response.addressNo;
                                    shippingAddress = dataController.populateAddress(responseAddress,false);
                                }
                            }
                            
                        } else if (responseType == 'creditcard') {
                            // test Message ; is it about a credit card?
                            
                            Map<String,String> responseCC = new Map<String,String>();
                            responseCC.put('number',response.cardNumber);
                            responseCC.put('type',response.cardType);
                            responseCC.put('expirationDate',response.expirationDate);
                            responseCC.put('holder',response.cardHolder);
                            creditCards.add(responseCC);
                            
                        }
                        debugMessage += 'billing/shipping: ' + order.Bill_To__c + '/' + addressValue + '<br/>';
                    }  // if false
                }  // for reponseItems loop
                
                // there are no shipping addressres associated with the chosen account
                if (shipAddressOptions == null || shipAddressOptions.size() == 0) {
                   errorMessage = 'This account does not have any shipping addresses set up.  Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                   PageReference entryPage = new PageReference('/apex/ProductOrderEntry');
                   entryPage.setRedirect(false);
                   return entryPage;
                   
                }

                // default payment term is cash
                if (paymentTerm == null ) {
                   errorMessage = ' This account has not been set up for credit card payments.  Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                   PageReference entryPage = new PageReference('/apex/ProductOrderEntry');
                   entryPage.setRedirect(false);
                   return entryPage;
                   
                }
                
                // there are no credit cards associated with the chosen account
                if (creditCards == null || creditCards.size() == 0) {
                   errorMessage = ' This account does not have any valid credit cards associated with it.  Please contact a Lucentis Direct Specialist at (800) 963-1778 to add credit cards to your account, or to place your order by phone.';
                   PageReference entryPage = new PageReference('/apex/ProductOrderEntry');
                   entryPage.setRedirect(false);
                   return entryPage;
                   
                }
                
                if (errorMessage == '' && orderPayments == null) {
                   Integer chargeableCardCount = initializePayments();
                   // there are no valid cards for ordering
                   
                   return null;
                }
                else {
                    return null;
                }    
              
            } catch (Exception e) {
                message = e.getMessage();
                if(attempt==1){
                    //Only retry for the first time
                    if(message.toLowerCase().indexOf('timed out')>0){
                        return getSAPAccountInfo(acctInfo, 2);
                    }
                }
                // duyent - 022511 add notification
                String username = UserInfo.getUserName();
                string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - ProductOrderSFDCProxyController failed to retrieve Account info NULL';
                sendNotification (MessageBody);
                errorMessage += 'We are experiencing some technical difficulties. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                debugMessage = 'ERROR: Failed to retrieve Account information: ' + e.getMessage();
                return null;
            }
    }
                               
    /*
    Update Product Info
    */
    private void updateProductInfo(){
           //Get Product Info
           Product_vod__c matchedProduct = null;
           productionOptions = new List<SelectOption>();
           List<Product_vod__c> products = dataController.getProducts();
           for (Product_vod__c product : products){
                  if(item.Product__c== product.Id){
                           matchedProduct = product;
                  }
                  productionOptions.add(new SelectOption(product.Id, product.Name));
           }
                        
           if(matchedProduct==null){
                     //Set default value to the first product
                     matchedProduct = products[0];
           }
                        
           item.Product__c = matchedProduct.Id;
           this.NDC = products[0].NDC_Number_gne__c;
           this.productName = matchedProduct.Name;
    }
   
    /* 
    prepare for Step #2 - Payment
    */
    public PageReference gotoPayment(){
        
        clearError();
         // simulte order before going on to Step #2, payment screen
        debugMessage =  'about to start call simulateOrder...<br/>';
        if (simulateOrder(1)) {
            
            debugMessage =+ 'after simulate: unit/total/tax : ' + item.Unit_Price__c + '/' + order.Total__c + '/' + order.Tax__c + '<br/>';
            
            //validate the order part, but not the payment
            //however, if reorder, validate payment as well
            if(!validateOrder(false)){
                   return null;
            }
            
             updateCCInfo(true);
                                            
             PageReference paymentPage = new PageReference('/apex/ProductOrderPayment');
             paymentPage.setRedirect(false);
             return paymentPage;
        } else {
             PageReference entryPage = new PageReference('/apex/ProductOrderEntry');
             entryPage.setRedirect(false);
             return entryPage;
        }
    }
    
    /*
    Initialize available credit cards and prepopulate payment entry for each
    */
    private Integer initializePayments(){
        // any credit cards to init?
        if(creditCards==null || creditCards.size() == 0){
            return 0;
        }
        orderPayments = new List<Product_Order_Payment_gne__c>();
                        
        Boolean defaultSet = false;
        Product_Order_Payment_gne__c payment = null;
          
        Pattern x = Pattern.compile('-');
        Matcher nonEncryptedCC;
        List<Product_Order_Payment_gne__c> chargeableCards = new List<Product_Order_Payment_gne__c>();
        for( Map<String,String> cc :  creditCards) {
              // Example CC number from SAP 
              // encrypted: -E803-4448-B000000000P
              // plain: 0123456789012345
              payment = new Product_Order_Payment_gne__c();
              
              if (currentDate.daysBetween(Date.valueOf(cc.get('expirationDate'))) > -120) {
                
                  nonEncryptedCC = numbersOnly.matcher(cc.get('number'));
                  if (nonEncryptedCC.matches()) {
                      payment.Name = cc.get('number').substring(12);
                      encrypted = false;
                      debugMessage += ' numbers only - NOT encrypted: ' + payment.Name + '<br/>';
                  } else {
                      String[] ccNumber = x.split(cc.get('number'));
                      payment.Name = ccNumber[2];
                      debugMessage += ' encrypted: ' + payment.Name + '<br/>';
                  }
                  
                  payment.Card_Holder_Name__c = cc.get('holder');
                  payment.Card_Type__c = cc.get('type');
                  payment.Expiration_Date__c = Date.valueOf(cc.get('expirationDate'));
                  payment.Quantity__c = null;
                  payment.Total__c = 0;
                  
                  orderPayments.add(payment);
                  // keep track of cards that are chargeable
                  if (currentDate.daysBetween(payment.Expiration_Date__c) > 59) {
                    chargeableCards.add(payment);
                  }
              }
              
         }
         return chargeableCards.size();
    }
             
    /*
    Update credit card level info
    */
    private void updateCCInfo(Boolean ignoreZeroQuantity){
        
         totalPayment.Quantity__c = 0;
         totalPayment.Total__c = 0;
         clearError();
        
         Integer totalPayments = null;
         if (orderPayments != null) {
            totalPayments = orderPayments.size();
            if(totalPayments>0){
                for(Product_Order_Payment_gne__c payment:orderPayments){
                        
                      if(driveChangeByQuantity){
                             if (currentDate.daysBetween(payment.Expiration_Date__c) <=59) {
                                  payment.Quantity__c = 0;
                             }
                             if(payment.Quantity__c==null){
                                  payment.Quantity__c=0;
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
                             if (currentDate.daysBetween(payment.Expiration_Date__c) <=59) {
                                   payment.Total__c = 0;
                             }
                      }
                      totalPayment.Total__c = totalPayment.Total__c + payment.Total__c;
                }
            }
         }  
                     
          if(!driveChangeByQuantity && totalPayments>1){
                totalPayment.Quantity__c = null;
          } 
        
          updateOrderSaveStatus();
    }       
   
    /*
    This method is used to decide whether we should enable user to submit an order or remove a payment
    */
    private void updateOrderSaveStatus(){
                    
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
    validate order
    */
    private boolean validateOrder(boolean validatePayment){
          clearError();
          

          if(order.Bill_To__c==null){
                 errorMessage = 'Order bill to account must be selected first';
          }
          if(billingAddress ==null){
                 errorMessage = 'Order bill to address must be selected first';
          }
          if(shippingAddress ==null){
                 errorMessage = 'Order ship to address must be selected first';
          }
           
                       
          item.Quantity__c = Math.roundToLong(item.Quantity__c);
          if (item.Unit_Price__c == null) {
          // duyent - 022511 add notification
          String username = UserInfo.getUserName();
          string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - validateOrder() unit price is null';
             sendNotification (MessageBody);
                errorMessage += 'We are experiencing some technical difficulties creating your order. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
          } else {
            item.Net_Price__c = item.Unit_Price__c * item.Quantity__c;
          }
           
          orderPaymentsKeep = new List<Product_Order_Payment_gne__c>();
          if(validatePayment){
                 if(orderPayments==null || orderPayments.size()==0){
                 errorMessage = errorMessage + 'You must select at least one payment method for this order<br/>';
          } else {
                 Integer i = 0;
                 totalPayment.Total__c = 0;
                 //Check CC level quantity match and price match
                 for(Product_Order_Payment_gne__c payment:orderPayments){
                      if(driveChangeByQuantity){
                            payment.Quantity__c = Math.roundToLong(payment.Quantity__c);
                            totalPayment.Quantity__c = totalPayment.Quantity__c + payment.Quantity__c;
                      }
                      totalPayment.Total__c = totalPayment.Total__c + payment.Total__c;
                      if (payment.Total__c != null && payment.Total__c > 0) {
                             orderPaymentsKeep.add(payment);
                      }
                       i = i + 1;
                    }
                                        
                    // clear then copy non-zero, saved payment entries
                    
                    if (orderPaymentsKeep.isEmpty() ) { 
                        paymentError = paymentError + 'Total charges on credit card do not match the order price.<br/>'; 
                    } 
                   
                    if(!driveChangeByQuantity){
                         totalPayment.Quantity__c = null;
                    }
                }
        }
                        
        if(paymentError!='' || errorMessage!=''){
                return false;
        } else {
                return true;
        }
    }
    
    /*
    Simulate order
    Invoked between Step #1 and Step #2
    */
    public Boolean simulateOrder(Integer attempt) {
            
            try{
                message = '';
               
               //Populate request object
               ProductOrderSFDCProxyController.SimulateOrderRequestItem[] requestItems = new ProductOrderSFDCProxyController.SimulateOrderRequestItem[2];
                
               //Set order level request
               ProductOrderSFDCProxyController.SimulateOrderRequestItem requestItem = new ProductOrderSFDCProxyController.SimulateOrderRequestItem();
               
               Account acctInfo = dataController.getAccountInfoForID(order.Bill_To__c);
               requestItem.requestItemType='order';
               requestItem.billToId = acctInfo.SAP_ID_gne__c;
               requestItem.shipToId = addressValue;
               requestItems[0] = requestItem;
                
                //set line level request 
               requestItem = new ProductOrderSFDCProxyController.SimulateOrderRequestItem();
               requestItem.requestItemType='lineitem';
               requestItem.productNDC= NDC;
               
               requestItem.quantity= String.valueOf(item.Quantity__c.intValue());
               requestItems[1] = requestItem;
                
               ProductOrderSFDCProxyController.SimulateOrderResponseItem[] simulateOrderResponseItems = simulateOrder.simulateOrder(requestItems);
              
                if (simulateOrderResponseItems == null ||simulateOrderResponseItems.size() == 0) {
                    // duyent - 022511 add notification
                    String username = UserInfo.getUserName();
                    string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - simulateOrder() simulateOrderResponseItems is null';
                    sendNotification (MessageBody);
                    errorMessage += 'We are experiencing some technical difficulties creating your order. Please contact a Lucentis Direct Specialist at (800) 963-1778.<br/>';
                    debugMessage += 'Simulate order failed - no reponse<br/>';
                    return false;
                }
             
               for(ProductOrderSFDCProxyController.SimulateOrderResponseItem response:simulateOrderResponseItems){
                  
                    String responseType = response.ResponseItemType;
                    String status = response.Status;
                    if(status==null){
                        status='true';
                    }
                    if (status == 'syserror') {
                    // duyent - 022511 add notification
                    String username = UserInfo.getUserName();
                    string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - ProductOrderSFDCProxyController.SimulateOrderResponseItem status = syserror';
                   sendNotification (MessageBody);
                        errorMessage += 'We are experiencing some technical difficulties creating your order. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                        return false;
                    } else if (status == 'false') {
                        errorMessage +=  'We were not able to create your order. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                        
                        return false;
                    } else {
                        
                        if(responseType =='order'){
                            order.Tax__c = (Decimal.valueOf(response.Tax)).setScale(2);
                            order.Total__c = (Decimal.valueOf(response.Total) + order.Tax__c).setScale(2);
                            debugMessage += 'Total/tax: ' + order.Total__c + '/' + order.Tax__c + '<br/>';
                        } else if(responseType =='lineitem') {
                        
                            item.Net_Price__c = (Decimal.valueOf(response.NetPrice)).setScale(2);
                            //item.Unit_Price__c = item.Net_Price__c / item.Quantity__c;
                            item.Unit_Price__c = (Decimal.valueOf(response.NetPrice)).setScale(2) / item.Quantity__c;
                            item.Tax__c = (Decimal.valueOf(response.LineTax)).setScale(2);
                            item.Total__c = item.Unit_Price__c * item.Quantity__c;
                            
                            debugMessage += 'net/unit/quantity: ' + item.Net_Price__c + '/' + item.Unit_Price__c + '/' + item.Quantity__c + '/';
                            if (item.Unit_Price__c == null || item.Unit_Price__c == 0) {
                                   // duyent - 022511 add notification
                                    String username = UserInfo.getUserName();
                                    string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - ProductOrderSFDCProxyController.SimulateOrderResponseItem unit price is null';
                                 sendNotification (MessageBody);
                                errorMessage = 'We are experiencing some technical difficulties creating your order. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                                // should send user back to the entry page here if no unit price
                            }
                        
                            message += 'net:' + response.NetPrice + ' subtotal:' + response.SubTotal + 'tax:' + response.LineTax + 'quan:' + item.Quantity__c;
                            item.Expected_Delivery_Date__c = Date.valueOf(response.ExpectedDeliveryDate);
                            item.Expected_Ship_Date__c = Date.valueOf(response.ExpectedShippingDate);
                            item.Expected_Settlement_Date__c = Date.valueOf(response.ExpectedSettlementDate);
                            debugMessage += 'ship:' +  response.ExpectedShippingDate + ' del:' + response.ExpectedDeliveryDate + '<br/>';
                        }
                    }
               
               }
            } catch (Exception e) {
                message = e.getMessage();
                if(attempt==1){
                    //Only retry for the first time
                    if(message.toLowerCase().indexOf('timed out')>0){
                        return simulateOrder(2);
                    }
                }
                   // duyent - 022511 add notification
                   String username = UserInfo.getUserName();
                   string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - ProductOrderSFDCProxyController.SimulateOrderResponseItem exception error';
                   sendNotification (MessageBody);
                errorMessage +=  'We are experiencing some technical difficulties creating your order. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                return false;
            }
           return true;
    }
    
    /*
    Go to order review
    */
    public PageReference submitOrder() {
          //validate the order part and the payment
          
          if(!validateOrder(true)){
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
                        
          PageReference confirmPage = new PageReference('/apex/ProductOrderReview');
          confirmPage.setRedirect(false);
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
         //clearError();
         if(orderPayments==null || orderPayments.size()==0){
                 errorMessage = 'No order payment has been specified. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                 return null;
         }
         
         // create order in SAP
         Boolean successfulOrder = createOrder();
         debugMessage += 'order create status: ' + successfulOrder;
         //if (createOrderStatus != '' || order.SAP_Order_ID__c == null) {
         if (!successfulOrder || order.SAP_Order_ID__c == null) {
            //errorMessage += 'Failed to create order';
            PageReference completePage = new PageReference('/apex/ProductOrderPayment');
            completePage.setRedirect(false);
            return completePage;
         }
              
         Savepoint sp = Database.setSavepoint();
         Datetime now = System.Now();
         try{
              order.Order_Type__c = 'Web';
              order.Ordered_On__c = System.Now();
              // Note: error on insert when UserInfo.getName() used. Don't know why...
              order.Ordered_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
              insert order;         
              
              // insert billing and shipping addresses
              billingAddress.Order__c = order.Id;
              billingAddress.Billing__c = true;
              shippingAddress.Order__c = order.Id;
              insert billingAddress;
              insert shippingAddress;
              
              // insert item
              item.Tracking_Number__c = null;
              item.Order__c = order.Id;
              item.SAP_Line_Number_gne__c = '000010';
              insert item;
                                
              List<Product_Order_Payment_gne__c> keep = new List<Product_Order_Payment_gne__c>();
                        
              // Insert Order Payments
              Integer cardNoLength = 0;
              for(Product_Order_Payment_gne__c payment:orderPayments) {
                         payment.Order__c = order.id;
                         payment.Expiration_Date__c = null;
                         if(payment.Total__c!=null && payment.Total__c > 0 ){
                               insert payment;
                               keep.add(payment);
                         }
                     
              }      
              // this should always be true!
              // transfer added payments to orderPayments for final display
              if (!keep.isEmpty() ) { 
                  orderPayments.clear();
                  for(Product_Order_Payment_gne__c p : keep) {
                       orderPayments.add(p);
                  }
               }     
                        
               // Send the user to home page
               PageReference completePage = new PageReference('/apex/ProductOrderConfirm');
               completePage.setRedirect(false);
               return completePage;
               
          } catch(Exception e) {
               Database.rollback(sp);
               PageReference completePage = new PageReference('/apex/ProductOrderReview');
               errorMessage = e.getMessage();
               completePage.setRedirect(false);
               return completePage;
          }
    }
    
   public void cancelOrder() {
        
        Product_Order_Code_Lookup_gne__c cancelledCodeInfo = [select id, Display_Text__c from Product_Order_Code_Lookup_gne__c where Name = 'CANCELLED' limit 1];
        cancelOrderSAP(cancelledCodeInfo, 1);
    }
    
    
    public void cancelOrderSAP(Product_Order_Code_Lookup_gne__c cancelledCodeInfo, Integer attempt) {
        
          
        try{
            
            message = '';
            cancelMessage = ''; 
            ProductOrderSFDCProxyController.CancelOrderResponseItem  responseItem = cancelOrder.cancelOrder(order.SAP_Order_ID__c);
            
            String status = responseItem.Status;
            if(status==null){
                status='true';
            }
        
            if (status == 'syserror') {
               // duyent - 022511 add notification
               String username = UserInfo.getUserName();
               string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - cancelOrderSAP() status = syserror';
                   sendNotification (MessageBody);
                cancelMessage = 'We are experiencing some technical difficulties cancelling your order. Please contact a Lucentis Direct Specialist at (800) 963-1778.';
            } else if (status == 'false') {
                String userMessage;
                if (responseItem.Message.contains('Delivery Completed')) {
                    userMessage = 'Your order is being processed for delivery and cannot be cancelled at this time.';
                } else {
                    //userMessage = responseItem.Message;
                    userMessage = 'Your order cannot be cancelled.';
                }
                //cancelMessage += 'We are experiencing some technical difficulties cancelling your order.  Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                cancelMessage = userMessage + '<br/>Please contact a Lucentis Direct Specialist at (800) 963-1778.';
            } else {
                // update order item status
                Savepoint sp = Database.setSavepoint();
                try {
                    
                    item.Status__c = cancelledCodeInfo.id;
                    update item;
                    cancelMessage = 'Order Changed Successfully: Order ' + order.SAP_Order_ID__c + ' has been cancelled successfully. ' ;
                    
                    items = orderController.getOrderItems(order.Id);
                    item = items[0];
                    debugMessage = 'New item status : ' + item.Status__r.Display_Text__c;
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
                        cancelOrderSAP(cancelledCodeInfo, 2);
                    }
            }
              // duyent - 022511 add notification
              String username = UserInfo.getUserName();
              string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderEntryController - cancelOrderSAP() exception error';
              sendNotification (MessageBody);
            cancelMessage = 'We are experiencing some technical difficulties cancelling your order.  Please contact a Lucentis Direct Specialist at (800) 963-1778.';
            debugMessage += 'ERROR: failed to Cancel order in SAP : ' + message;
       }
        
    }
    
    /*
    Create order in SAP
    */
    private Boolean createOrder() {
        
        // How many payments for this order? Set requestItemSize accordingly
        Integer paymentCount = orderPayments.size();
        Integer requestItemSize = 2 + paymentCount;
        Boolean createSFDCOrder = null;
        
        Matcher numbersMatcher = null;
        Boolean numbersMatched = null;
        Matcher ccMatcher = null;
        Boolean ccMatched = null;
        
        Boolean userMsg = false;
        Boolean SAPOrderCreated = false;
          
        try{
            
            
             //Populate request object
             ProductOrderSFDCProxyController.CreateOrderRequestItem[] requestItems = new ProductOrderSFDCProxyController.CreateOrderRequestItem[requestItemSize];
                    
             //Set order level request
             ProductOrderSFDCProxyController.CreateOrderRequestItem requestItem = new ProductOrderSFDCProxyController.CreateOrderRequestItem();
             
             Account acctInfo = dataController.getAccountInfoForID(order.Bill_To__c);
             requestItem.requestItemType='order';
             requestItem.billToId=acctInfo.SAP_ID_gne__c;
             requestItem.shipToId=addressValue;
             requestItem.createdBy = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
             requestItems[0] = requestItem;
             
             debugMessage += 'bill & ship: ' + acctInfo.SAP_ID_gne__c + '|' + addressValue + '<br/>';
                    
             //set line level request 
             requestItem = new ProductOrderSFDCProxyController.CreateOrderRequestItem();
             requestItem.requestItemType='lineitem';
             requestItem.productNDC=NDC;
             requestItem.quantity=String.valueOf(item.Quantity__c.intValue());
             requestItems[1] = requestItem;
                    
             debugMessage += 'ndc & quantity: ' + NDC + '|' + String.valueOf(item.Quantity__c.intValue()) + '<br/>';
             
             //set payment level request 
             Integer paymentItemIndex = 2;
             debugMessage += 'payment size: ' + orderPaymentsKeep.size() + '<br/>';
             for(Product_Order_Payment_gne__c payment:orderPaymentsKeep) {
                 if(payment.Total__c != null && payment.Total__c > 0 ){
                      requestItem = new ProductOrderSFDCProxyController.CreateOrderRequestItem();
                      requestItem.requestItemType='payment';
            
                      //requestItem.cardNumber format : '-E803-5004-6000000000000P';
                      String x = getSAPCreditCardNumber(payment);
                      requestItem.cardNumber = getSAPCreditCardNumber(payment);
                      requestItem.cardHolder = payment.Card_Holder_Name__c;
                      requestItem.expirationDate = payment.Expiration_Date__c.year() + '-' + payment.Expiration_Date__c.month() + '-' + payment.Expiration_Date__c.day();
                      requestItem.cardType = payment.Card_Type__c;
                      
                      payment.Total__c = payment.Total__c.setScale(2);
                      requestItem.totalCharge = String.valueOf(payment.Total__c);
                     
                      debugMessage +=  x + ' : ' + payment.Name + '|' + payment.Card_Holder_Name__c + '|' + payment.Expiration_Date__c.format() + '|' + 
                        String.valueOf(payment.Total__c) + '<br/>';
                      requestItems[paymentItemIndex] = requestItem;
                      paymentItemIndex++;
                 }
             } 
                   
             ProductOrderSFDCProxyController.CreateOrderResponseItem[] responseItems = createOrder.createOrder(requestItems);
             
             if (responseItems == null ||responseItems.size() == 0) {
                    errorMessage += 'Your order has timed out.  DO NOT resubmit the order.  Please check your order history in 10 minutes to determine if your order has been successfully placed.  You may also contact us at (800) 963-1778 between 9am and 8pm ET Monday through Friday. Thank you.';
                    debugMessage += 'Order creation failed - no reponse<br/>';
                    createSFDCOrder =  false;
                    return false;
             }
             
             Integer i = 0;
             
             debugMessage += 'response size: ' + responseItems.size() + '<br/>';
             for(ProductOrderSFDCProxyController.CreateOrderResponseItem response:responseItems){
                String responseType = response.ResponseItemType;
                String status = response.Status;
                i++;
                            
                if(status==null){
                    status='true';
                }
                if (responseType == 'order') {
                    if (status == 'true') {
                        SAPOrderCreated = true;
                        order.SAP_Order_ID__c = response.orderId;
                        order.Tax__c = (Decimal.valueOf(response.Tax)).setScale(2);
                        order.Total__c = (Decimal.valueOf(response.Total) + order.Tax__c).setScale(2);
                        createSFDCOrder =  true;
                    } else {
                        if (status == 'syserror') {
                            errorMessage = 'Your order has timed out.  DO NOT resubmit the order.  Please check your order history in 10 minutes to determine if your order has been successfully placed.  You may also contact us at (800) 963-1778 between 9am and 8pm ET Monday through Friday. Thank you.';
                            
                        } else if (status == 'false') {
                            // check Message ; is it about a credit card? If yes, extract credit card number and message
                            // e.g., -PMOS-6037-00001000000025 Invalid Credit Card
                            // group(1) = card number; group(2) = error message
                            
                            numbersMatcher = numbersOnlyPattern.matcher(response.Message);
                            numbersMatched = numbersMatcher.lookingAt();
                            ccMatcher = ccPattern.matcher(response.Message);
                            ccMatched = ccMatcher.lookingAt();
                            debugMessage += 'cc pattern : ' + ccMatched + ': ' + response.Message + '<br/>';
                            if (ccMatched ||  numbersMatched) {
                                if (!userMsg) {
                                        createOrderMessage = '<div style="font-size:12px; color:red; font-weight:bold;">We were not able to authorize your credit card, and your order has not been placed.  Please call (800) 963-1778 for further assistance.<p/>';
                                        createOrderMessage += '<ul>';
                                        
                                }
                                if (encrypted) {
                                    createOrderMessage +=  '<li>XXXX-XXXX-XXXX-' + ccMatcher.group(1)  + '</li>';
                                } else {
                                    createOrderMessage +=  '<li>XXXX-XXXX-XXXX-' + numbersMatcher.group(1).substring(12)  + '</li>';
                                }
                                userMsg = true;
                            } else {
                                errorMessage = 'We were not able to place your order.<br/>Please contact a Lucentis Direct Specialist at (800) 963-1778.';
                            }
                        }
                        createSFDCOrder =  false;
                    }
                } else if  (responseType == 'lineitem') {
                    if (status == 'true' && SAPOrderCreated) {
                        item.Net_Price__c = (Decimal.valueOf(response.NetPrice)).setScale(2);
                        item.Tax__c = (Decimal.valueOf(response.LineTax)).setScale(2);
                        item.Expected_Delivery_Date__c = Date.valueOf(response.ExpectedDeliveryDate);
                        item.Expected_Ship_Date__c = Date.valueOf(response.ExpectedShippingDate);
                        item.Expected_Settlement_Date__c = Date.valueOf(response.ExpectedSettlementDate);
                    }
                } else if (responseType == 'payment') {
                    
                  /*
                  status = 'false';
                  encrypted = false;
                  response.cardNumber = '3700001000000025';
                 */
                    if (status == 'false') {
                        if (!userMsg) {
                                    createOrderMessage = '<div style="font-size:12px; color:red; font-weight:bold;">We were not able to authorize your credit card(s), and your order has not been placed.  Please call (800) 963-1778 for further assistance.<p/>';
                                    createOrderMessage += '<ul>';
                                    userMsg = true;
                        }
                        if (response.cardNumber != null) {
                            String ccNumber;
                            if (encrypted) {
                                ccNumber = response.cardNumber.split('-',4)[2];
                            } else {
                                ccNumber = response.cardNumber.substring(12);
                            }
                            if (ccNumber != null) {
                                createOrderMessage += '<li>XXXX-XXXX-XXXX-' + ccNumber + '</li>' ;
                            }
                        }
                        /*
                        if (response.Message.startsWith('[XiPay')) {
                                //message = responseStatus;
                                // credit cards
                                String ccMessage = response.Message.split(' ',3)[2];
                                String ccNumber = response.cardNumber.split('-',4)[2];
                                if (!userMsg) {
                                    createOrderMessage = 'We were not able to authorize your credit card, and your order has not been placed.  Please call (800) 963-1778 for assistance.<p/>';
                                    createOrderMessage += '<table class="chargeError"><tr><th>Card Number</th><th>Status</th></tr>';
                                }
                                createOrderMessage +=  '<tr><td style="color:red; padding:2px 5px 2px 5px" >XXXX-XXXX-XXXX-' + ccNumber + '</td><td style="color:red; padding:2px 5px 2px 0px" >' + ccMessage + '</td></tr>';
                                userMsg = true;
                         } else if (response.Message.startsWith('R 202 Bad Amount')) {
                                // response.Message = 'R 202 Bad Amount Non-numeric Amount - Am';
                                String ccNumber = response.cardNumber.split('-',4)[2];
                                if (!userMsg) {
                                    createOrderMessage = 'We were not able to authorize your credit card, and your order has not been placed.  Please call (800) 963-1778 for assistance.<p/>';
                                    createOrderMessage += '<table class="chargeError"><tr><th>Card Number</th><th>Status</th></tr>';
                                }
                                createOrderMessage +=  '<tr><td style="color:red; padding:2px 5px 2px 5px" >XXXX-XXXX-XXXX-' + ccNumber + '</td><td style="color:red; padding:2px 5px 2px 0px" >Order on hold </td></tr>';
                                userMsg = true;
                         } else {
                                //'If you have questions, please contact a Lucentis Direct Specialist at (800) 963-1778.';
                                errorMessage +=  response.Message + '<br/>';
                         }
                         */
                         createSFDCOrder =  false;
                     }
                        
                }
                debugMessage += 'SFDC order: ' + createSFDCOrder + ': SAP order created: ' + SAPOrderCreated + ' - Create Order: ' + i + ':' + response.Status + ':' +  response.ResponseItemType + ':' +   response.Message+ ':' +response.total + ':'  + response.subTotal +'<br/>';
                
            }
            
                
        } catch(Exception e) {
               message = e.getMessage();
               errorMessage += 'Your order has timed out.  DO NOT resubmit the order.  Please check your order history in 10 minutes to determine if your order has been successfully placed.  You may also contact us at (800) 963-1778 between 9am and 8pm ET Monday through Friday. Thank you.';
               createSFDCOrder =  false;
               return false;
        }
        
        if (userMsg) {
              createOrderMessage += '</ul></div>';
        }
        
        return createSFDCOrder;
    }
    
    
    private String getSAPCreditCardNumber(Product_Order_Payment_gne__c payment) {
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
    private void clearError(){
             paymentError = '';
             errorMessage = '';
             criticalError = '';
             createOrderMessage = '';
    }
                
    private void setErrorMessage(String error){
            errorMessage = error;
    }
    private void setPaymentError(String error){
             paymentError = error;
    }
    public String getDebugMessage(){
             return debugMessage;
    }
    public String getErrorMessage(){
            return errorMessage;
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
    
    public String getDateToday(){
        return System.Now().format('MM/d/yyyy');
        
    }
    /*
    public Boolean getFromHistory(){
        return System.currentPageReference().getUrl().contains('&id=');
    }
    */
    /*
    Populate shipping address dropdown
    */
    public List<SelectOption> getShippingAddresses(){
        return shipAddressOptions;
    }
                
    public Product_Order_gne__c getOrder(){
        return order;
    }
         
    public Product_Order_Item_gne__c getItem(){
        return item;
    }
    
    
             
    /*
    Get Order Payments
    */
    public List<Product_Order_Payment_gne__c> getPayments(){
          return orderPayments;
    }
                
    public void setPayments(List<Product_Order_Payment_gne__c> payments){
          this.orderPayments = payments;
    }
                
    /*
    Get Order Payments - ones to be kept
    */
    public List<Product_Order_Payment_gne__c> getPaymentsKeep(){
          return orderPaymentsKeep;
    }
                
    public void setPaymentsKeep(List<Product_Order_Payment_gne__c> payments){
          this.orderPaymentsKeep = payments;
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
         PageReference homePage = new PageReference('/apex/ProductOrderHome');
         homePage.setRedirect(true);
         return homePage;
    }
    
    /*
    Line level Quntity Changed
    */
    public PageReference quantityChanged(){
        clearError();
        
         //Update price info
         driveChangeByQuantity = true;
                        
        //Update credit card charge, do not allow zero quantity
        /*
        updateCCInfo(false);
        firstView = false;
        */
        return null;
    }
                
    /*
    Line level charge changed
    */
    public PageReference chargeChanged(){
         clearError();
            
         //Update order by total charge
         driveChangeByQuantity = false;
         totalPayment.Quantity__c = null;
                        
         //Update credit card charge, ignore zero quantity
         /*
         updateCCInfo(true);
         firstView = false;
         */
         return null;
    }
    
    /*
    Update Quantity or charge amount in payments
    */
    public PageReference updatePayments(){
         clearError();
         PageReference currentPageRef = System.currentPageReference();
         
         updateCCInfo(false);
         firstView = false;
         return null;
    }
    
    
    /*
    Edit Order
    */
    public PageReference editOrder() {
         clearError();
         PageReference entryPage = new PageReference('/apex/ProductOrderEntry');
         entryPage.setRedirect(false);
         return entryPage;
    }
    
    /*
    Edit Order Payment
    */
    public PageReference editOrderPayment() {
         clearError();
         PageReference paymentPage = new PageReference('/apex/ProductOrderPayment');
         paymentPage.setRedirect(false);
         return paymentPage;
    }
    
    /*
    Back to order list
    */ 
    public PageReference backToOrderList() {
        PageReference nextPage  = new PageReference('/apex/ProductOrderHistory');
        nextPage.getParameters().put('selectedAccount', order.Bill_To__c);
        nextPage.getParameters().put('selectedStatus', selectedStatus);
        nextPage.getParameters().put('selectedSearchField', selectedSearchField);
        nextPage.getParameters().put('selectedFrom', selectedFrom);
        nextPage.getParameters().put('selectedTo', selectedTo);
        nextPage.setRedirect(false);
        return nextPage;
    }
              
}