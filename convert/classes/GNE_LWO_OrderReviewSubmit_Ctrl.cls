public without sharing class GNE_LWO_OrderReviewSubmit_Ctrl extends ProductOrderAsyncEntryController 
{
    //properties
    public String getAccountID()
    {
            return accountID;
    }
    public Boolean hasErrors 
    {
            get
            {

                        if(errorMessage != null && errorMessage.length() > 0)
                     {
                              return true;
                      }
                      else
                              return false; 
            }
            private set;
    }
    public String accountIndicator {get; private set;}
    //public String alertMessage {get; private set;}
    public boolean checkedAgreement {get; set;}
    //constructor
    public GNE_LWO_OrderReviewSubmit_Ctrl()
    {
            super();
            this.accountIndicator = System.CurrentPageReference().getParameters().get('accountIndicator');
        	//Jie Aug 2015 Repeat order M&E
            sapOrderId=System.currentPageReference().getParameters().get('sapOrdernum');
        	repeatOrderMSG=System.currentPageReference().getParameters().get('repeatOrderError');
        	reenter=false;
    }
    
    public PageReference goToReview()
    {
        debugMessage +='!!!!enter goToReview - GNE_LWO_Review';
        PageReference lwoReview = Page.GNE_LWO_Review;
        //lwoReview.getParameters().put('reenterPage', 'true');
        lwoReview.setRedirect(false);
        reenter=true;
        checkedAgreement = false;
        return lwoReview; 
        
    }
    
    public PageReference goToSubmit()
    {
        reenter=true;
        System.debug('enter goToSubmit()');
        this.debugMessage += 'enter goToSubmit, Click continue button | payment term is '+paymentTerm+' | amount '+orderPayments.get(0).Total__c+' | ';
        system.debug('Click continue button | payment term is '+paymentTerm+' | amount '+orderPayments.get(0).Total__c+' | ');
        this.criticalError=null;
        this.errorMessage=null;
        if(vildateOrderForSubmition()){
         debugMessage +='******totalCharge=';
			System.debug('Submit button clicked. Ctrl goes to GNE_LWO_Submit');
            log.addLine('goToSubmit() - valid order, forward to GNE_LWO_Submit page');
            PageReference nextpage = Page.GNE_LWO_Submit;
            //nextpage.getParameters().put('reenterPage', 'true');
            reenter=true;
            nextPage.setRedirect(false);
            return nextPage;
        }else{
            if(criticalError!=null){
                log.addLine('goToSubmit() - invalid order, forward to error page : '+criticalError);
                log.save('GNE_LWO_OrderReviewSubmit_Ctrl - goToSubmit() Exception: ' + criticalError, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
                
                PageReference page=new PageReference('/apex/LWO_ErrorPage');
                page.getParameters().put('ErrorMessage', criticalError);
                page.setRedirect(true);
                return page; 
            }else{
                return null;
            }
        }

        
        return null;
    }
    
    public PageReference goToOrder()
    {
        System.debug('enter goToOrder()');
        order = null;
        items = null;
        system.debug('----orderPayments3351');
        orderPayments = null;  
        
        //return to GNE_LWO_Welcome for admin users
        if(GNE_LWO_Controller.getAdminUser()){
                log.addLine('admin user, forward to GNE_LWO_Welcome page');
                PageReference homePage = Page.GNE_LWO_Welcome;
                if(this.accountID !=null)
                                homePage.getParameters().put('accountId', accountID);
                        homePage.setRedirect(true);
                        return homePage;
        }
        log.addLine('forward user to GNE_LWO_Order page ');
        PageReference lwoOrder = Page.GNE_LWO_Order;
        lwoOrder.getParameters().put('billToNum', billToNum);
        lwoOrder.getParameters().put('accountId', accountID);
        lwoOrder.setRedirect(false);//SFDC changed to false from true
        return lwoOrder;
    }   
    
    public PageReference goToConfirm()
    {
        log.addLine('enter goToConfirm()');
        reenter=true;
System.debug('Ctrl goes to GNE_LWO_Confirm');
        PageReference lwoConfirm = Page.GNE_LWO_Confirm;
        //lwoConfirm.getParameters().put('reenterPage', 'true');
        lwoConfirm.setRedirect(false);
        return lwoConfirm;
    }
    
    
    
    /***********************JIe's code **************************/
    //GNE_LWO_Logger log = new GNE_LWO_Logger();
    GNE_LWO_Controller.LWOProduct[] products; //only list products user doesn't select to order
    public String poNum {set; get;}
    public String billToNum {set; get;}
    private String orderRefNum; //automatically generated reference number if PO number is empty
    private double totalChargeAMT;//total amount user put in his(her) credit card(s)
    private double totalAuthorizedAmount; //total authorized amount
    private double balanceDue {set; get;}// = order.Total__c-totalAuthorizedAmount
    private List<Product_Order_Payment_gne__c> declinedPayments=new List<Product_Order_Payment_gne__c>(); // a list of credit card payments declined by PayMatrix
    public List<DeclinedPaymentCard> declinedPaymentCards {get; private set;}
    private List<Product_Order_Payment_gne__c> authorizedPayments=new List<Product_Order_Payment_gne__c>();
    private Date expectedDeliveryDate;
    private boolean orderUpdated;
    public String expectedDeliveryDateStr {set; get;}
    public String updateOrderErrorMSG {set; get;}
    private String addressValueEdit;
    public String newCardType{set; get;}
    public String newCardNumber {set; get;}
    public String newCardExpirationMonth {set; get;}
    public String newCardExpirationYear {set; get;}
    public String newCardholder {set; get;}
    public boolean orderCanceled {set; get;}
    public String deliveryDateMSG {get; private set;}

     public PageReference checkAgreement(){
        String isChecked = ApexPages.CurrentPage().getParameters().get('isChecked');
        if(isChecked=='true'){
            if(this.getBalanceDue()<=0 || this.getBalanceDue()==this.getTotalChargeAMT())
                checkedAgreement = true;
        }
        else
            checkedAgreement = false;
        return null;
    }
    
    public String getBalanceDueStr(){
        return Decimal.valueOf(getBalanceDue()).setScale(2)+'';
    }
    
    public double getBalanceDue(){
        if(order == null || order.Total__c==null || order.Total__c<=getTotalAuthorizedAmount()) return 0.0;
        return order.Total__c-getTotalAuthorizedAmount();
    }
    
    public void setBalanceDue(double d){
        balanceDue = d;
    }
    
    public String getTotalAuthorizedAmountStr(){
        return Decimal.valueOf(getTotalAuthorizedAmount()).setScale(2)+'';
    }
    
    public double getTotalAuthorizedAmount(){
        totalAuthorizedAmount = 0;
        if(authorizedPayments==null) return totalAuthorizedAmount;
        for(Product_Order_Payment_gne__c payment: authorizedPayments){
            totalAuthorizedAmount +=payment.authorizedAmount__c;
        }
        return totalAuthorizedAmount;
    }
    
    public void setTotalAuthorizedAmount(double d){
        totalAuthorizedAmount = d;
    }
    
    public List<SelectOption> getCCardTypeSelections(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('VISA','Visa')); 
        options.add(new SelectOption('AMEX','Amex')); 
        options.add(new SelectOption('MC','Master')); 
        return options;
    }
    
    public List<SelectOption> getNewCardExpirationMonthOptions(){
        List<SelectOption> options = new List<SelectOption>(); 
        Integer i=1;
        while(i<=12){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i))); 
            i++;
        }
        return options;
    }
    
    public List<SelectOption> getNewCardExpirationYearOptions(){
        List<SelectOption> options = new List<SelectOption>(); 
        if(this.currentDate==null) this.currentDate=system.today();
        Integer curYear = currentDate.year();
        Integer counter=0;
        while(counter<10){
            Integer year=curYear+counter;
            options.add(new SelectOption(String.valueOf(year),String.valueOf(year))); 
            counter++;
        }
        return options;
    }
    
    public void setAddressValueEdit(String addNo){
        this.addressValueEdit = addNo;
    }
    
    public String getAddressValueEdit(){
        if(this.addressValueEdit==null || this.addressValueEdit.trim().length()<=0) this.addressValueEdit = this.addressValue;
        return this.addressValueEdit;
    }
    
    public date getExDelDate(){
        if(expectedDeliveryDate==null) expectedDeliveryDate=System.today().addDays(1);
        return expectedDeliveryDate;
    }
    
    
    public String getExpectedDeliveryDate(){
        if(expectedDeliveryDate==null) expectedDeliveryDate=System.today().addDays(1);
        String[] expectedDelDate = String.valueOf(expectedDeliveryDate).split('-');
        String deliveryDate=expectedDelDate.get(1)+'-'+expectedDelDate.get(2)+'-'+expectedDelDate.get(0); 
        return deliveryDate;
    }
    

    public List<Product_Order_Payment_gne__c> getDeclinedPayments(){
        if(declinedPayments==null) declinedPayments = new List<Product_Order_Payment_gne__c>();
        return this.declinedPayments;
    }
    
    public List<Product_Order_Payment_gne__c> getAuthorizedPayments(){
        if(authorizedPayments==null) authorizedPayments = new List<Product_Order_Payment_gne__c>();
        return this.authorizedPayments;
    }
    
    public void setAuthorizedPayments(List<Product_Order_Payment_gne__c> payments){
        this.authorizedPayments = payments;
    }
    
    public void setDeclinedPayments(List<Product_Order_Payment_gne__c> payments){
        this.declinedPayments = payments;
    }

    public PageReference initShippingBillingPage(){
        this.debugMessage +='initShippingBillingPage ';
        system.debug('initShippingBillingPage');
        log.addLine('Enter initShippingBillingPage - ');
        //Jie
        //debugOn=true;
        PageReference curPage = System.currentPageReference();
        /*if(curPage.getParameters().get('reenterPage')=='true'){
            debugMessage +=' reenterPage ';
            log.addLine('reneter page from back button');
            return null;
        }*/
        if(reenter) return null;
        criticalError = null;
        
        Account billToAccount;
        intiParamters();
        
        if(curPage.getParameters() !=null) {
            addressValue = curPage.getParameters().get('SelectedShippingAddress');
            debugMessage +='selected shipto '+addressValue+' | ';
            system.debug('selected shipto '+addressValue+' | ');
            billToNum = curPage.getParameters().get('billToNum');
            debugMessage += 'bill to number is '+billToNum+' | ';
            system.debug('bill to number is '+billToNum+' | ');
            accountID = curPage.getParameters().get('accountId');
            this.debugMessage += 'accountID is '+accountID;
            system.debug('accountID =  '+accountID+' | ');
        } 
        //redirect to error page if bill to number is not past in parameter
        if(billToNum==null){
            criticalError = 'No account has been selected. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
        }else{
                
            List<Account> sapAccounts= dataController.getAccountBySAPId(billToNum);
            if(sapAccounts!=null && sapAccounts.size()==1) {
                billToAccount = sapAccounts[0];
            }else{
                criticalError = 'No account has been selected. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
            }
        }
        
        initProductList();
        if(billToAccount!=null) {
            if(getSAPAccountInfo(billToAccount, 1)){
              
            sapSimulateOrder(1);
            }
        }else{
            criticalError = 'No account has been selected. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
        }
               
        //critical system error happened, need to redirect to error page
        if(criticalError!=null && criticalError.trim().length()>=0){
                log.addLine('initShippingBillingPage error - '+criticalError);
               log.save('GNE_LWO_OrderReviewSubmit_Ctrl - initShippingBillingPage() Exception: ' + criticalError, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
                
            PageReference page=new PageReference('/apex/LWO_ErrorPage');
            page.getParameters().put('ErrorMessage', criticalError);
            page.setRedirect(true);
            return page; 
        }
        //for repeat order error
       
        //Jie add on Aug 2015 for repeat order

        //debugMessage+='!!!!!'+errorMessage+' hasErrors is '+hasErrors+' counter: '+System.currentPageReference().getParameters().get('counter');
        if(repeatOrderMSG!=null && repeatOrderMSG.length()>0){
            matchWithOldCCard(sapOrderId);
            this.getBalanceDue();
            errorMessage=repeatOrderMSG;
        }
        
        log.addLine('Exit initShippingBillingPage() - billToNum '+billToNum+' : accountId '+accountID);
        return null;     
        
    }

    private void initProductList(){
        //this.debugMessage += 'in init product list | ';
        log.addLine('enter initProductList');
        products = new GNE_LWO_Controller.LWOProduct[]{};
        
        items=new List<Product_Order_Item_gne__c>();
        
        PageReference curPage=System.currentPageReference();
        List<Product_vod__c> parentPrds=[select id from Product_vod__c where name='Lucentis' and Product_Type_vod__c='Market'];
        if(parentPrds!=null && parentPrds.size()==1){
            Product_vod__c parentPrd = parentPrds.get(0);
            for(Product_vod__c prd:[select id, NDC_Number_gne__c, name, List_Price_gne__c, discount_price__c, max_QTY__c, LWO_Discount_Note__c, product_Image_name__c 
                                    from Product_vod__c where active__c=true and Product_Type_vod__c='NDC' and Web_Order_Enabled_gne__c=true and Parent_Product_vod__c=:parentPrd.id]){                
                
                GNE_LWO_Controller.LWOProduct prdItem= new GNE_LWO_Controller.LWOProduct(prd);
               
                Product_Order_Item_gne__c lineItem = orderCOntroller.initLineItem();
                lineItem.Product__r=prd;
                lineItem.Unit_Price__c=prd.List_Price_gne__c;
                if(curPage.getParameters()!=null && curPage.getParameters().get(prd.NDC_Number_gne__c) !=null){
                    Integer qty=Integer.valueOf(curPage.getParameters().get(prd.NDC_Number_gne__c));
                    if(qty>0 ){
                        lineItem.Quantity__c=qty;
                        prdItem.qty=qty;
                        log.addLine('user selected PRD - '+prd.NDC_Number_gne__c+' : QTY '+qty);
                    }else lineItem.Quantity__c=0;
                }else lineItem.Quantity__c=0;
                items.add(lineItem);
                products.add(prdItem);
            }
        }
        log.addLine('Exit initProductList');
    }
    

    public GNE_LWO_Controller.LWOProduct[] getProducts(){
        if(products == null){
            products = new GNE_LWO_Controller.LWOProduct[]{};
        }
        return products;
    }
    
    
    public List<Product_Order_Item_gne__c> getItems(){
        if(items==null) items= new List<Product_Order_Item_gne__c>();
        return items;
    }
    
    public String generateOrderRefNum(){
         log.addLine('enter generateOrderRefNum()');
        String refNum;
        String userName = GNE_LWO_COntroller.userName;
        String subUserName;
        if(userName!=null) {
            Integer index= userName.indexOf('@');
            if(index>=0) subUserName=userName.subString(0,index-1);
            if(subUserName.length()>5) subUserName = userName.subString(0,5);
        }
        Integer rdm = Math.round((Math.random()*1000000000));
        refNum = subUserName+(rdm+'').subString(0,5);
        log.addLine('exit generateOrderRefNum() - refNum='+refNum);
        return refNum;
    }
    
    public PageReference ContinueCommercial(){
        reenter=true;
        this.debugMessage +='enter ContinueCommercial()';
        this.debugMessage += 'Click continue button | payment term is '+paymentTerm+' | amount '+orderPayments.get(0).Total__c+' | ';
        system.debug('Click continue button | payment term is '+paymentTerm+' | amount '+orderPayments.get(0).Total__c+' | ');
        this.criticalError=null;
        this.errorMessage=null;
        if(vildateOrderForSubmition()){
            this.debugMessage +='ContinueCommercial() - valid order, forward to submit order page';
            PageReference nextpage = Page.GNE_LWO_Submit; //SFDC changed from new PageReference(URL). Page was also wrong calling submitOrder
            nextPage.setRedirect(false);
            return nextPage;
        }else{
            if(criticalError!=null){
                log.addLine('ContinueCommercial() - invalid order, forward to error page');
                log.save('GNE_LWO_OrderReviewSubmit_Ctrl - ContinueCommercial() Exception: ' + criticalError, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
                
                PageReference page=new PageReference('/apex/LWO_ErrorPage');
                page.getParameters().put('ErrorMessage', criticalError);
                page.setRedirect(true);
                return page; 
            }else{
                return null;
            }
        }
        
    }
    
    private boolean vildateOrderForSubmition(){
        debugMessage+='enter vildateOrderForSubmition()';
        //if any of the following inportant order info is missing, direct user to error page
        //bill to No, ship to No, order, line items, credit cards, payment term
        if(this.billToNum==null) {
                log.addLine('vildateOrderForSubmition() invalid order for - billToNum is null');
            this.criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            return false;
        }else if(this.addressValue==null) {
                log.addLine('vildateOrderForSubmition() invalid order for - addressValue/shipToNum is null');
            this.criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            return false;
        }else if(this.order == null || this.items==null || items.size()<=0){
            log.addLine('vildateOrderForSubmition() invalid order for - order or order line item is null');
            this.criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            return false;
        }else if(this.orderPayments==null || orderPayments.size()<=0 || paymentTerm==null){
            log.addLine('vildateOrderForSubmition() invalid order for - No order payment has been specified');
            this.criticalError = 'No order payment has been specified. Please contact a LUCENTIS Direct Customer Specialist  at 800.963.1778 for assistance';
            return false;
        }
        
        double dueAMT = this.getBalanceDue();
        double authorziedAMT = this.getTotalAuthorizedAmount();
        double totalCharge = this.getTotalChargeAMT();
        
        if(dueAMT>0 ){
            if(totalCharge!=dueAMT){
                
                log.addLine('vildateOrderForSubmition() invalid order for - charge AMT != due AMY, totalCharge='+totalCharge+': dueAMT='+dueAMT);
                this.errorMessage = 'The total charges on the credit card(s) do not match the order price. Please enter an additional $'+(dueAMT-totalCharge)+' to complete your order.';
                return false;
            }else return true;
        }else{
            
            //if due amount <=0, user should not put in any new charge amount
            //therefore balance should equals to total authorized amount
            if(totalCharge > authorziedAMT){
                log.addLine('vildateOrderForSubmition() invalid order for - credit card charge amount '+totalCharge+' does not match with the balance due amount '+dueAMT);
                this.errorMessage = 'Your credit card charge amount '+totalCharge+' does not match with the balance due amount '+dueAMT;
                return false;
            }else return true;
        }
       
        return true;
        
    }
    
    private void intiParamters(){
        System.debug('Enter intiParamters()');
        currentDate = System.Today();
        currentTime = System.Now();
        currentDateValue = currentTime.format('MMM d, yyyy');
        //expectedDeliveryDate = System.today().addDays(1);
        //expectedDeliveryDateStr=String.valueOf(expectedDeliveryDate);
        expectedDeliveryDateStr='';
        expectedDeliveryDate =null;
        orderUpdated = false;
        deliveryDateMSG = null;
        //initiate a new order
        if(order==null) {
                order = orderController.createNewOrder();
        }
        if(items==null){
            items=new List<Product_Order_Item_gne__c>();
        }
        if(orderPayments == null) orderPayments = new List<Product_Order_Payment_gne__c>();
        if(paymentTerm == null) paymentTerm = 60;
        initOneTimeCCard();
        totalChargeAMT = 0;
        totalAuthorizedAmount = 0;
        balanceDue = 0;
        
        canPlaceOrder = !GNE_LWO_Controller.getAdminUser();
        log.addLine('Exit intiParamters()');
    }
    
    public List<SelectOption> getPaymentTermSelections(){
        List<SelectOption> options = new List<SelectOption>(); 
        //options.add(new SelectOption('75','Charge 75 days after ship date')); 
        options.add(new SelectOption('60','Charge 60 days after ship date')); 
        options.add(new SelectOption('0','Charge at time of shipping ')); 
        return options;
    }
    
    public void setTotalChargeAMT(double d){
        this.totalChargeAMT=d;
    }
    
    public String getTotalChargeAMTStr(){
        this.debugMessage +='totalChargeAMT ='+getTotalChargeAMT();
        return Decimal.valueOf(getTotalChargeAMT()).setScale(2)+'';
    }
    
    public double getTotalChargeAMT(){
        log.addLine('enter getTotalChargeAMT()');
        totalChargeAMT = 0.00;
        if(orderPayments==null) return totalChargeAMT;
        if(paymentTerm == null) paymentTerm = 60;
        //check ccard expiration date against payment term before update totalChargeAMT
        //only payment put to ccard expires in days longer than payment term to be added to totalChargeAMT
        
        this.debugMessage +='^^^^^orderPayments '+orderPayments.size()+' paymentTerm='+paymentTerm;
        system.debug('^^^^^orderPayments '+orderPayments.size()+' paymentTerm='+paymentTerm);
        for (Product_Order_Payment_gne__c payment: orderPayments){
            if(payment.Total__c==null) {
                payment.Total__c=0;
            }
            /*
            if(expectedDeliveryDate.daysBetween(payment.Expiration_Date__c)<paymentTerm){
                if(payment.Total__c!=0) payment.Total__c=0;
            }else{
                this.totalChargeAMT += payment.Total__c;
            }
            */
            
            if(currentDate.daysBetween(payment.Expiration_Date__c)<=0){
                if(payment.Total__c!=0) payment.Total__c=0;
            }else {
                this.totalChargeAMT += payment.Total__c;
            }
        }
        log.addLine('exit getTotalChargeAMT(): totalChargeAMT='+totalChargeAMT);
        return totalChargeAMT;
    }
    
    /*
* Simulate order
* Invoked between Step #1 and Step #2
*/
    private Boolean sapSimulateOrder(Integer attempt) {
        log.addLine('Entered sapSimulateOrder(attempt=' + attempt + ')');
        this.debugMessage += ' in sapSimulateOrder | ';
        system.debug(' in sapSimulateOrder | ');
        try{
            message = '';
            
            if(this.items == null || this.items.size() == 0){
                return false;
            }
            
            Integer requestItemCount = orderLineItemCounter()+1;
            
            //Populate request object
            GneProductOrderSimulateOrder.SimulateOrderRequestItem[] requestItems = new GneProductOrderSimulateOrder.SimulateOrderRequestItem[requestItemCount];
            
            //Set order level request
            GneProductOrderSimulateOrder.SimulateOrderRequestItem requestItem = new GneProductOrderSimulateOrder.SimulateOrderRequestItem();
     
                String logLine = 'Simulate order billToId=' + billToNum + ', shipToId=' + addressValue+', order line items: ';
            
            Integer index=0;
            
            requestItem.requestItemType='order';
            requestItem.billToId = this.billToNum;
            requestItem.shipToId = addressValue;
            requestItems[index] = requestItem;
            
            this.debugMessage += ' order level - billto '+billToNum+'; shipTo '+addressValue;
            system.debug(' order level - billto '+billToNum+'; shipTo '+addressValue);
            
            for(Product_Order_Item_gne__c lineItem: items) {
                //set line level request 
                if(lineItem.Quantity__c!=null && lineItem.Quantity__c>0){
                    requestItem = new GneProductOrderSimulateOrder.SimulateOrderRequestItem();
                    requestItem.requestItemType='lineitem';
                    requestItem.productNDC= lineItem.Product__r.NDC_Number_gne__c;
                    requestItem.quantity = String.valueOf(lineItem.Quantity__c.intValue());
                    requestItem.expectedDeliveryDate = expectedDeliveryDateStr;
                    this.debugMessage +=' | send to SAP requestItem.quantity '+ requestItem.quantity+' | NDC='+requestItem.productNDC+' | expectedDeliveryDate='+requestItem.expectedDeliveryDate;
                    system.debug(' | send to SAP requestItem.quantity '+ requestItem.quantity+' | NDC='+requestItem.productNDC+' | expectedDeliveryDate='+requestItem.expectedDeliveryDate);
                    requestItems[++index]=requestItem;
                    logLine +=requestItem.productNDC+' QTY '+requestItem.quantity+' : ';
                }
            }       
            
             log.addLine(logLine);  
            this.debugMessage +='before call out';
            GneProductOrderSimulateOrder.SimulateOrderResponseItem[] simulateOrderResponseItems =  simulateOrder.simulateOrder(requestItems);
            this.debugMessage +='after call out';
            if (simulateOrderResponseItems == null ||simulateOrderResponseItems.size() == 0) {
                log.addLine('simulateOrderResponseItems is null or empty');
                logObjectContent();
                 log.save('ERROR: sapSimulateOrder returned no reponses', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;        
                return false;
            }
             log.addLine('sapSimulateOrder returned ' + simulateOrderResponseItems.size() + ' responses');
            
            for (GneProductOrderSimulateOrder.SimulateOrderResponseItem response:simulateOrderResponseItems) {
                String responseType = response.ResponseItemType;
                String status = response.Status;
                 log.addLine('responseType=' + responseType + ' status=' + status);
                this.debugMessage +='$$$$$$$$$$$$$status**********'+status+'$$$$$response message '+response.Message+'|';
                system.debug('$$$$$$$$$$$$$status**********'+status+'$$$$$response message '+response.Message+'|');
                if (status == null || status.trim().length()==0) {
                    status = 'true';
                }
                
                if (status != 'true') {
                    criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
                    
                    logObjectContent();
                    if (response.Message != null && response.Message.length() > 0 ) {
                         log.save('ERROR: ' + response.Message, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    } else {
                        log.save('ERROR: status!=true but no error message returned in webservice response', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                    }
                    
                    return false;
                }

                if (responseType == 'order') {
                    this.debugMessage += 'in type order | ';
                    order.Tax__c = (Decimal.valueOf(response.Tax)).setScale(2);
                    order.Total__c = (Decimal.valueOf(response.Total) + Decimal.valueOf(response.Tax)).setScale(2);
                    order.discountAmount__c=(Decimal.valueOf(response.totalDiscount)).setScale(2);
                    //To do - add total discount value here
                     this.debugMessage += 'Total=' + order.Total__c + ' tax=' + order.Tax__c+' discountAMT='+order.discountAmount__c;
                     log.addLine('Total=' + order.Total__c + ' tax=' + order.Tax__c+' discountAMT='+order.discountAmount__c);

                } else if (responseType =='lineitem') {
                    this.debugMessage += 'in type lineItem | ';
                    if(items == null) {
                        this.debugMessage += ' null items | ';
                        log.addLine('in sapSimulateOrder response parse section, found items null, recreate a new items list');
                        items = new List<Product_Order_Item_gne__c>();
                    }
                    String ndc=response.productNDC;
                    if(ndc!=null && ndc.trim().length()>0){
                        for(Product_Order_Item_gne__c lineItem: items){
                            if(lineItem.Product__r.NDC_Number_gne__c == ndc){
                                lineItem.Net_Price__c = (Decimal.valueOf(response.NetPrice)).setScale(2);
                                lineItem.Unit_Price__c = ((Decimal.valueOf(response.unitPrice))/ lineItem.Quantity__c).setScale(2);
                                lineItem.Tax__c = (Decimal.valueOf(response.LineTax)).setScale(2);
                                lineItem.Total__c = (Decimal.valueOf(response.unitPrice)).setScale(2);
                                this.debugMessage += '**** Unit price = '+response.unitPrice;
                                system.debug('**** Unit price = '+response.unitPrice);
                                if (lineItem.Unit_Price__c == null || lineItem.Unit_Price__c == 0) {
                                    logObjectContent();
                                     log.save('ERROR: Order line item missing unit price', GNE_LWO_Logger.ERROR, GNE_LWO_Logger.DATA);
                                    criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
                                    this.debugMessage += ' Unit price is null |';
                                    return false;                                
                                }       
                                this.debugMessage +='ndc= '+ndc+ ' net:' + response.NetPrice + ' subtotal:' + response.SubTotal + 'tax:' + response.LineTax + 'quan:' + lineItem.Quantity__c+' | ';
                                system.debug('ndc= '+ndc+ ' net:' + response.NetPrice + ' subtotal:' + response.SubTotal + 'tax:' + response.LineTax + 'quan:' + lineItem.Quantity__c+' | ');
                                this.expectedDeliveryDate = Date.valueOf(response.ExpectedDeliveryDate);
                                this.expectedDeliveryDateStr = String.valueOf(expectedDeliveryDate);
                                lineItem.Expected_Delivery_Date__c = Date.valueOf(expectedDeliveryDateStr);
                                this.debugMessage += 'SAP response.ExpectedDeliveryDate - '+response.ExpectedDeliveryDate+'|';
                                system.debug('SAP response.ExpectedDeliveryDate - '+response.ExpectedDeliveryDate+'|');
                                if(response.deliveryDateChangeFlag!=null && response.deliveryDateChangeFlag=='Y' && orderUpdated) this.deliveryDateMSG='** IMPORTANT ** - Your selected delivery date is unavailable. The next available delivery date has been recommended or you may select a new delivery date. Our apologies for any inconvenience.';
                                this.debugMessage += expectedDeliveryDateStr;
                                lineItem.Expected_Ship_Date__c = Date.valueOf(response.ExpectedShippingDate);
                                lineItem.Expected_Settlement_Date__c = Date.valueOf(response.ExpectedSettlementDate);
                                log.addLine('ndc='+ndc+' net=' + lineItem.Net_Price__c + ' price=' + lineItem.Unit_Price__c + ' tax=' + lineItem.Tax__c + ' total=' + lineItem.Total__c+' expected delivery date='+expectedDeliveryDateStr);
                            
                            }
                        }
                    } 

                    this.debugMessage += 'end type lineItem | ';

                } else if (responseType == 'discitem') {
                    this.debugMessage += 'in type price | ';
                    // price item                                    
                    price = new Product_Order_Price_gne__c();
                    
                    price.Condition_Class__c = response.priceTypeClass;
                    price.Condition_Type__c = response.priceTypeCode;
                    price.Unit_Price__c = Double.valueOf(response.priceTypeUnitPrice);   
                    price.Total_Price__c = Double.valueOf(response.priceTypeTotalPrice);
                    price.Description__c = response.priceTypeDesc;
                    
                    if(prices==null) prices =new  List<Product_Order_Price_gne__c>();
                    prices.add(price);  
                    this.debugMessage += 'end type price | ';                          
                }
            } // for loop
            
        } catch (Exception e) {
            this.debugMessage += ' | '+e.getMessage();
            system.debug(e.getMessage());
            //Only retry for the first time
            if (attempt == 1 && e.getMessage().toLowerCase().indexOf('timed out') > 0) {
                 log.addLine(e.getMessage());
                return sapSimulateOrder(2);
            }
            
            logObjectContent();
             log.save('ERROR sapSimulateOrder Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
            criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
            return false;
        }
        
         log.addLine('Exit sapSimulateOrder returning true');
        return true;
    }

    public PageReference updateBalance() {
        this.getTotalChargeAMT();
        return null;
    }
    
    
    public PageReference updateOrder(){
        log.addLine('enter updateOrder()');
        boolean qtyError=false;
        boolean noPrdQty=true;
        updateOrderErrorMSG=null;
        criticalError = null;
        if(addressValueEdit==null) {
            updateOrderErrorMSG = 'Please select a shipping address';
            return null;
        }
        if(products!=null) {
            for(GNE_LWO_Controller.LWOProduct p:  products){   
                p.qtyError=null;
                if(p.qty!=0){
                    noPrdQty=false;
                }
                if(p.qty <0){
                    p.qty = 0;
                    qtyError=true;
                    p.qtyError='Order quantity must be greater than 0.';
                    
                }   else if(p.qty>p.product.max_QTY__c){
                    qtyError=true;
                    p.qtyError='Maximum quantity of vials is '+p.product.max_QTY__c+' per order.';
                }  else {  
                    p.qty = Math.round(p.qty);
                    
                }
                
            }
        }else{
            criticalError =GNE_LWO_Controller.GENERIC_ERROR_MSG;
            log.addLine('updateOrder() - products is null');
        }
        
        if(noPrdQty){
            //user hasn't add qty to any product
            updateOrderErrorMSG = 'Order quantity must be greater than 0.';
        }
        
        //only updtae order data elements when user data entry are validated
        if(!qtyError && !noPrdQty){
            //keep a copy of the before edit version lineitems, expected delivery date, and ship to No
            //in case to convert back if edit process failed
            List<Product_Order_Item_gne__c> keepItems =updateItemsFromProducts();
            Date keepDeliveryDate = this.expectedDeliveryDate;
            String keepAddNo = this.addressValue;
            this.addressValue = this.addressValueEdit;
            this.orderUpdated = true;
            this.deliveryDateMSG = null;
            if(!sapSimulateOrder(1)){
                items = keepItems;
                this.expectedDeliveryDate = keepDeliveryDate;
                this.expectedDeliveryDateStr = String.valueOf(this.expectedDeliveryDate);
                this.addressValue = keepAddNo;
                this.addressValueEdit = this.addressValue;
            }
            shippingAddress = dataController.populateAddress(shippingAddresses.get(addressValue),false);          
            shipToAddress = dataController.constructAddressForDisplayMap(shippingAddresses.get(addressValue));
        }
        
        if(criticalError!=null){
                log.addLine('updateOrder criticalError - '+criticalError);
                log.save('ERROR updateOrder Exception: ' + criticalError, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
                
            PageReference page=new PageReference('/apex/LWO_ErrorPage');
            page.getParameters().put('ErrorMessage', criticalError);
            page.setRedirect(true);
            return page;
        }
        
        return this.updateBalance();
        //return checkAgreement();
    }
    
    private List<Product_Order_Item_gne__c> updateItemsFromProducts(){
        log.addLine('enter updateItemsFromProducts()');
        if(products==null) return null;
        if(items==null) return null;
        List<Product_Order_Item_gne__c> keepItems=new List<Product_Order_Item_gne__c>();
        
        for(Product_Order_Item_gne__c litem: items){
            Product_Order_Item_gne__c i=litem.clone(false, true);
            keepItems.add(i);
            
            for(GNE_LWO_Controller.LWOProduct prdItem : products){
                if(litem.Product__r.NDC_Number_gne__c==prdItem.product.NDC_Number_gne__c){
                    litem.Quantity__c=prdItem.qty;
                }
            }
            
        }
        log.addLine('exit updateItemsFromProducts()');
        return keepItems;
        
    }
    
    public PageReference goToHome(){
        order = null;
        items = null;
        system.debug('----orderPayments3351');
        orderPayments = null;
        PageReference nextPage = new PageReference('/apex/LWO_LandingHome'); 
        nextPage.getParameters().put('billToNum', billToNum);
        nextPage.getParameters().put('accountId', accountID);
        nextPage.setRedirect(true);
        return nextPage;
    }
    
    public boolean getDisableContinueOrder(){
        if(order.Total__c==this.totalChargeAMT) return false;
        else return true;
    }
    
    public void cancelEdit(){
        log.addLine('enter cancelEdit()');
        this.debugMessage +='in cancel Edit method';
        this.expectedDeliveryDateStr = String.valueOf(this.expectedDeliveryDate);
        this.addressValueEdit = this.addressValue;
        for(GNE_LWO_Controller.LWOProduct prdItem : products){
            for(Product_Order_Item_gne__c litem: items){
                if(litem.Product__r.NDC_Number_gne__c==prdItem.product.NDC_Number_gne__c){
                    prdItem.qty = Integer.valueOf(litem.Quantity__c);
                }
            }
        }
        log.addLine('exit cancelEdit()');
    }
    
    public PageReference saveCreditCard(){
        log.addLine('enter saveCreditCard()');
        this.debugMessage +='in saveCreditCard method | ';
        this.debugMessage +='the payment list size is '+this.orderPayments.size();
        if(orderPayments == null) orderPayments = new List<Product_Order_Payment_gne__c>();
        log.addLine('saveCreditCard() - before add card orderpayments has '+orderPayments.size()+' cards');
        system.debug('saveCreditCard() - before add card orderpayments has '+orderPayments.size()+' cards');
        if(this.orderPayments!=null){
            
            Product_Order_Payment_gne__c payment = new Product_Order_Payment_gne__c();
            payment.name = newCardNumber.substring (newCardNumber.length()-4);
            payment.sapCardToken__c = newCardNumber;
            
            payment.Card_Holder_Name__c = newCardholder;
            payment.Card_Type__c = newCardType;
            Integer day;
            Integer month=Integer.valueof(newCardExpirationMonth);
            Integer year = Integer.valueof(newCardExpirationYear);
            if(month == 1 || month == 3 || month ==5 || month==7 || month==8|| month ==10 || month==12) day=31;
            else if(month==2) {
                if(math.mod(year, 4)==0) day=29;
                else day=28;
                
            }else day=30;
            if(day!=null && year!=null && month!=null)
                payment.Expiration_Date__c = date.newinstance(year, month, day);
            payment.Quantity__c = null;
            payment.Total__c = 0;
            orderPayments.add(payment);
            this.debugMessage +='card number '+payment.name+' : '+payment.sapCardToken__c+' date '+payment.Expiration_Date__c;
            system.debug('card number '+payment.name+' : '+payment.sapCardToken__c+' date '+payment.Expiration_Date__c);
            log.addLine('new card number '+payment.name+' : '+payment.sapCardToken__c+', expiration date '+payment.Expiration_Date__c+', card holder '+newCardholder);
                
        }
        
        initOneTimeCCard();
        log.addLine('saveCreditCard() - after add card orderpayments has '+orderPayments.size()+' cards');
        system.debug('saveCreditCard() - after add card orderpayments has '+orderPayments.size()+' cards');
        this.debugMessage +='the payment list size is '+this.orderPayments.size()+' |';
        log.addLine('exit saveCreditCard()');
        return null;
    }

    public void cancelCCardSave(){
        log.addLine('enter cancelCCardSave()');
        this.debugMessage +='in cancelCCardSave method';
        initOneTimeCCard();
        log.addLine('exit cancelCCardSave()');
    }
    
    private void initOneTimeCCard(){
        log.addLine('enter initOneTimeCCard()');
        newCardType='';
        newCardNumber ='';
        newCardExpirationMonth = '';
        newCardExpirationYear = '';
        newCardholder ='';
        log.addLine('exit initOneTimeCCard()');
    }   
    
    public PageReference submitCommercialOrder(){
        reenter=true;
        checkedAgreement = false;
        System.debug('enter submitCommercialOrder()');
        this.debugMessage += '<br/>##############################################'+System.currentPageReference().getUrl()+'<br/>submitCommercialOrder() - submit order to sap |';
        this.criticalError = null;
        this.errorMessage = null;
        List<Product_Order_Payment_gne__c> submittedPayments = new List<Product_Order_Payment_gne__c>();
        if(orderPayments!=null){
            for(Product_Order_Payment_gne__c payment:orderPayments){
                if(currentDate.daysBetween(payment.Expiration_Date__c)<=0){
                //if(expectedDeliveryDate.daysBetween(payment.Expiration_Date__c)<paymentTerm) {
                        if(payment.Total__c!=0) payment.Total__c=0;
                }else{
                        if(payment.Total__c!=0){
                            Product_Order_Payment_gne__c ccardPay=payment.clone(false, true);
                            submittedPayments.add(ccardPay);
                        //set payment.Total__c=0 after copy payment object to the submittedPayments list, orderPayments only for user
                        //add payments, therefore intial toal charge should be 0
                            payment.Total__c=0;
                        }
                }
             }
        }
        
        //add authorized payments if this is called from payment adjustment
        if(authorizedPayments!=null && authorizedPayments.size()>0){
            for(Product_Order_Payment_gne__c aPayment:authorizedPayments){
                submittedPayments.add(aPayment);
            }
        }
        System.debug('submitCommercialOrder() - to be submitted payment cards size ='+submittedPayments.size());        
        PageReference nextPage;
        this.debugMessage += 'submitCommercialOrder before call the submit order interface';
        
        if(submitOrderToSAP(submittedPayments, 1, '')){
                log.addLine('submitCommercialOrder() - successfull, forward to OrderConfirmation page');
            orderCanceled = false;
            this.debugMessage += 'authorized payment has '+this.authorizedPayments.size()+' Authorized amount  = '+this.getTotalAuthorizedAmount();
            system.debug('authorized payment has '+this.authorizedPayments.size()+' Authorized amount  = '+this.getTotalAuthorizedAmount());
            
            nextPage= Page.GNE_LWO_Orderconfirmation;//SFDC changed from new Pagereference
            nextPage.setRedirect(false);
        }else{
          this.debugMessage +='<br/>submitOrderToSAP() returned false';
            if(this.errorMessage != null) {
                log.addLine('submitCommercialOrder() - not successfull, forward to payment adjustment page');
                //nextPage= new PageReference('/apex/LWO_PaymentAdjustment');
                nextPage= Page.GNE_LWO_PaymentAdjustment; //SFDC changed from PageRference
                nextPage.setRedirect(false);
            }else{
              
              if(this.criticalError ==null || this.criticalError.trim().length()<=0){
                criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;
              }
                log.addLine('submitCommercialOrder() - not successfull, forward to error page');
                log.save('GNE_LWO_OrderReviewSubmit_Ctrl - submitCommercialOrder() Exception: ' + criticalError, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
                
                nextPage=new PageReference('/apex/LWO_ErrorPage');
                nextPage.getParameters().put('ErrorMessage', criticalError);
                nextPage.setRedirect(true);
              
            }
        }
         System.debug('Exit submitCommercialOrder returning ' + nextPage.getUrl());
        return nextPage; 
    }
    
  
    private boolean submitOrderToSAP(List<Product_Order_Payment_gne__c> ccardPayments, Integer attempt, String cancelFlag){
      this.debugMessage += '<br/>$$$$$$$$called submitOrderToSAP at '+system.now();
        log.addLine('enter submitOrderToSAP, attempt='+attempt +' : cancel order flag='+cancelFlag);
        if(cancelFlag!=null && cancelFlag=='X' && (ccardPayments==null || ccardPayments.size()==0)){
                //cancel order call but has no authorized payment amount needs to be canceled
                //directly return true without call SAP
                return true;
        }
        //no order, no order line item, system error
        if(order==null || items==null ) {
                log.addLine('submitOrderToSAP() - return false for : order or items is null');
            criticalError =GNE_LWO_Controller.GENERIC_ERROR_MSG;
            return false;
        }
                //no payment systeme error
        if(ccardPayments==null || ccardPayments.size()<=0){
                log.addLine('submitOrderToSAP() - return false for : credit card payments is null');

            criticalError =GNE_LWO_Controller.GENERIC_ERROR_MSG;
            return false;
        }
        this.debugMessage += ' submitOrderToSAP 1 |';
        try{
                this.debugMessage += ' submitOrderToSAP - in try |';
            GeneWeborderCreateOrder.GneCOMM_WebOrder_CreateOrder_SFDC_O_1_WSD_CreateOrder_Port sapCreateOrder = new GeneWeborderCreateOrder.GneCOMM_WebOrder_CreateOrder_SFDC_O_1_WSD_CreateOrder_Port();
            sapCreateOrder.timeout_x = 60000;
            this.debugMessage += 'create order url = '+sapCreateOrder.endpoint_x+' | ';
            system.debug('create order url = '+sapCreateOrder.endpoint_x);
            GeneWeborderCreateOrder.CreateOrderRequest2 request = new GeneWeborderCreateOrder.CreateOrderRequest2();
            requestSenderId = UserInfo.getUserId() + System.now().getTime() + String.ValueOf(Math.RoundToLong(Math.Random()*10));
            //header level request items
            request.uniqueIDSFDC = requestSenderId;
            request.billTo=this.billToNum;
            request.shipTo=this.addressValue;
            request.createdBy = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            request.currencyCode = 'USD';
            if(this.poNum==null || this.poNum.trim().length()<=0) poNum=this.generateOrderRefNum();
            request.poNumber = this.poNum;
            if(this.paymentTerm==0) request.paymentTerm = 'CC00';
            else request.paymentTerm = 'CC'+paymentTerm;
            request.cancelOrderFlag =cancelFlag;
            String logStr='submitOrder requests - billTo='+billToNum+' : shipTo='+addressValue+' : createdBy='+request.createdBy+' : paymentTerm='+request.paymentTerm+' : cancel flag='+cancelFlag;
            this.debugMessage += ' submitOrderToSAP - logStr= '+logStr+' | ';
            system.debug(' submitOrderToSAP - '+logStr);
            //order line item level
            request.RequestLineItems = new GeneWeborderCreateOrder.RequestLineItems[orderLineItemCounter()];
            request.RequestPaymentItems =new GeneWeborderCreateOrder.RequestPaymentItems[ccardPayments.size()];
            Integer index=0;
            for(Product_Order_Item_gne__c litem: items) {
                //set line level request 
                if(litem.Quantity__c!=null && litem.Quantity__c>0){
                    GeneWeborderCreateOrder.RequestLineItems lineItem= new GeneWeborderCreateOrder.RequestLineItems();
                    lineItem.materialNDC= litem.Product__r.NDC_Number_gne__c;
                    lineItem.quantity = String.valueOf(litem.Quantity__c.intValue());
                    lineItem.expectedDeliveryDate = expectedDeliveryDateStr;
                    system.debug('send to SAP date string '+ lineItem.expectedDeliveryDate);
                    request.RequestLineItems[index++]=lineItem;
                    logStr +=' : ndc='+lineItem.materialNDC+' : lineItem.quantity'+lineItem.quantity+' : expectedDeliveryDate'+expectedDeliveryDateStr;
                }
            }
            //this.debugMessage += ' submitOrderToSAP - request done line item | ';
            this.debugMessage='SFDC to SAP CCard info';
            index=0;
            for(Product_Order_Payment_gne__c ccard:ccardPayments){
                GeneWeborderCreateOrder.RequestPaymentItems paymentItem = new GeneWeborderCreateOrder.RequestPaymentItems();
                paymentItem.cCardNumber = ccard.sapCardToken__c;
                this.debugMessage += '<br/>send to SAP - credit card number: '+ccard.sapCardToken__c;
                paymentItem.cCardType=ccard.Card_Type__c;
                paymentItem.cCardHolderName=ccard.Card_Holder_Name__c;
                paymentItem.cCardExpirationDate=String.valueOf(ccard.Expiration_Date__c);
                paymentItem.cCardTotalCharge=String.valueOf(ccard.Total__c);
                system.debug('send to sap total cahrge - '+String.valueOf(ccard.Total__c));
                this.debugMessage+=' - ccard charge '+String.valueOf(ccard.Total__c);
                if(ccard.authorizationNo__c!=null) paymentItem.cCardAuthNumber=ccard.authorizationNo__c;
                if(ccard.authorizationRefNo__c!=null) paymentItem.cCardAuthRefNumber=ccard.authorizationRefNo__c;
                if(ccard.authorizedAmount__c!=null)
                    paymentItem.cCardTotalAuthAmount=String.valueOf(ccard.authorizedAmount__c);
                paymentItem.cCardAuthTime=ccard.authorizationTime__c;
                if(ccard.merchantId__c!=null) paymentItem.merchantId=ccard.merchantId__c;
                if(ccard.glAccountNumber__c!=null) paymentItem.glAccountNumber=ccard.glAccountNumber__c;
                if(ccard.resultCode__c!=null) paymentItem.resultCode=ccard.resultCode__c;
                if(ccard.resultMessage__c!=null) paymentItem.resultMessage=ccard.resultMessage__c;
                if(ccard.autherizationDate__c!=null) paymentItem.cCardAuthDate=ccard.autherizationDate__c;
                request.RequestPaymentItems[index++]=paymentItem;
            }
                log.addLine(logStr+' : payment card list size='+index);
                system.debug(' submitOrderToSAP - done payment request, payment card list size='+index);
            GeneWeborderCreateOrder.CreateOrderReply2 reply= sapCreateOrder.processInbound(request, 'off');
           system.debug('after called service - reply.status '+reply.status+' : reply.message '+reply.message);
            if(reply.ReplyPaymentItems !=null && reply.ReplyPaymentItems.size()>0){
                List<Product_Order_Payment_gne__c> tempAuthorizedPayments = new List<Product_Order_Payment_gne__c>();
                List<Product_Order_Payment_gne__c> tempDeclinedPayments = new List<Product_Order_Payment_gne__c>();
                double tempAuthAMT=0.0;
                this.debugMessage += '<br/>before for loop | reply.ReplyPaymentItems.size() '+reply.ReplyPaymentItems.size()+' | ';
                for(GeneWeborderCreateOrder.ReplyPaymentItems replyPayment: reply.ReplyPaymentItems){
                        Product_Order_Payment_gne__c payment = new Product_Order_Payment_gne__c();
                        String cardNum=replyPayment.cCardNumber;
                        String cardNum2 = cardNum.trim();
                        if(cardNum2.contains('-')){
                          cardNum2 = cardNum2.replace('-', '');
                        }
                        
                        this.debugMessage += '<br/>SAP response card number: '+cardNum+' | remove -: '+cardNum2+' length is '+cardNum2.length();
                        Pattern x = Pattern.compile('-');
                        Matcher nonEncryptedCC = numbersOnly.matcher(cardNum);
                        if(cardNum2.length()==15 || cardNum2.length()==16){
                          //find a unencrypted card, maybe a one time card
                          
                          //payment.Name = nonEncryptedCC.group(1);
                          payment.Name = cardNum2.substring(cardNum2.length()-4);
                          this.debugMessage +='find a unencrypted card: '+cardNum+' last 4: '+payment.Name;
                            encrypted = false;
                        }else{
                          this.debugMessage +='find an encrypted card: '+cardNum;
                          String[] ccNumber = x.split(cardNum);
                            payment.Name = ccNumber[2];
                        }
                        
                       /* if (nonEncryptedCC.matches()) {
                                this.debugMessage += 'before env varaible | ';
                            // accept unencrypted value only in UAT
                             if(GNE_LWO_Logger.ENV=='UAT' || GNE_LWO_Logger.ENV=='DEV') {
                                payment.Name = nonEncryptedCC.group(1);
                                encrypted = false;
                            } 
                    
                        } else {
                            String[] ccNumber = x.split(cardNum);
                            payment.Name = ccNumber[2];
                        }*/
                    this.debugMessage += 'after split, payment name: '+payment.Name;
                        payment.sapCardToken__c = replyPayment.cCardNumber;
                        String temp='';
                        if(replyPayment.cCardHolderName!=null) temp=replyPayment.cCardHolderName.replace('%','-');
                        payment.Card_Holder_Name__c = temp;
                        payment.Card_Type__c = replyPayment.cCardType;
                        payment.Expiration_Date__c = Date.valueOf(replyPayment.cCardExpirationDate);
                        //comment out by Jie
                        //if(replyPayment.cCardTotalCharge!=null) payment.Total__c = Double.valueOf(replyPayment.cCardTotalCharge);
                        payment.authorizationNo__c = replyPayment.cCardAuthNumber;
                        payment.authorizationRefNo__c = replyPayment.cCardAuthRefNumber;
                        if(replyPayment.cCardTotalAuthAmount!=null) payment.authorizedAmount__c = Double.valueOf(replyPayment.cCardTotalAuthAmount);
                        system.debug('replyPayment.cCardAuthTime - '+replyPayment.cCardAuthTime+' | replyPayment.cCardTotalCharge = '+replyPayment.cCardTotalCharge);
                        //add by Jie
                        payment.Total__c=payment.authorizedAmount__c;
                        this.debugMessage +='- authorized amount is '+payment.authorizedAmount__c;
                        if(replyPayment.cCardAuthTime!=null)        
                            payment.authorizationTime__c = replyPayment.cCardAuthTime;
                        if(replyPayment.cCardAuthDate!=null)        
                            payment.autherizationDate__c = replyPayment.cCardAuthDate;
                    
                        payment.merchantId__c = replyPayment.merchantId;
                        payment.glAccountNumber__c = replyPayment.glAccountNumber;
                        payment.resultCode__c = replyPayment.resultCode;
                        payment.resultMessage__c = replyPayment.resultMessage;
                        
                        //if(payment.authorizationNo__c!=null && payment.authorizedAmount__c!=null && payment.authorizedAmount__c>0){
                         if(replyPayment.resultCode!=null && replyPayment.resultCode.trim()=='A'){
                           this.debugMessage +=' is authorized payment ';
                            tempAuthorizedPayments.add(payment);
                            tempAuthAMT += payment.authorizedAmount__c;
                        }else{
                          this.debugMessage +=' is declined payment ';
                            //if(this.declinedPayments==null) declinedPayments = new List<Product_Order_Payment_gne__c>();
                            //declinedPayments.add(payment);
                            tempDeclinedPayments.add(payment);
                        }
                        
                        system.debug('replyPayment.resultCode = '+replyPayment.resultCode+' : replyPayment.resultMessage = '+replyPayment.resultMessage);

                }//end for
                if(tempAuthorizedPayments!=null && tempAuthorizedPayments.size()>0){
                     this.authorizedPayments=tempAuthorizedPayments;
                     this.totalAuthorizedAmount = tempAuthAMT;
                }
                if(tempDeclinedPayments!=null && tempDeclinedPayments.size()>0) {
                    declinedPayments = tempDeclinedPayments;
                }
                log.addLine('submitOrderToSAP() response '+authorizedPayments.size()+' authorized card, '+declinedPayments.size()+' declined cards, total authorized AMT='+totalAuthorizedAmount);
                
            }else{
                    //SAP response payment items is null
                    criticalError =GNE_LWO_Controller.GENERIC_ERROR_MSG;
                    log.addLine('submitOrderToSAP() response items is null');
                    this.debugMessage +='|submitOrderToSAP() response items is null|';
            }
            
            //order create success or order cancel success
            if(reply.status=='true') {
              this.debugMessage +='reply.status '+reply.status+' : reply.message '+reply.message;
                system.debug('reply.status '+reply.status+' : reply.message '+reply.message);
                return true;
            }
            else{
                if(reply.message!=null && reply.message=='Authorized amount is less than the Order amount'){
                    //need to do payment adjustment
                    this.errorMessage = reply.message;
                }else 
                //sap response message is null or is not for payment adjustment
                criticalError =GNE_LWO_Controller.GENERIC_ERROR_MSG;
                log.addLine('submitOrderToSAP() response status is false, message is '+reply.message);
                    
            }
        }catch(Exception e){
          this.debugMessage +=' submit order interface exception happended at '+system.now();
            system.debug( ' exception | '+e.getMessage());
            //Stop second try when web service call time out to eliminate duplicate orders
           /* if (attempt == 1 && e.getMessage().toLowerCase().indexOf('timed out') > 0) {
                 log.addLine(e.getMessage());
                 this.debugMessage +=' about to call submit order interface again at '+system.now();
                return submitOrderToSAP(ccardPayments, 2, cancelFlag);
            }*/
            
            logObjectContent();
             log.save('ERROR CreateOrder Exception: ' + e.getMessage(), GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SAP_INT);
            if((cancelFlag==null || cancelFlag!='X') && e.getMessage().toLowerCase().indexOf('timed out') > 0)
            criticalError = 'Your order has timed out. DO NOT resubmit the order. Please check your order history in 10 minutes to determine if your order has been successfully placed. You may also contact us at 800.963.1778 between 9 am and 8 pm ET, Monday to Friday, for assistance. Thank you.';
            else criticalError =GNE_LWO_Controller.GENERIC_ERROR_MSG;
            //criticalError += debugMessage+' | PO Num - '+this.poNum+'<br/>'+e.getMessage();
            //criticalError = e.getMessage();
        }
        
        return false;
    }
    
    private Integer orderLineItemCounter(){
        Integer counter=0;
        if(items!=null){
            for(Product_Order_Item_gne__c litem: items) {
                if(litem.Quantity__c!=null && litem.Quantity__c>0){
                    counter++;
                }
            }
        }
        return counter;
    }
    
    public PageReference cancelPaymentAdjustmentOrder(){
        log.addLine('enter cancelPaymentAdjustmentOrder()');
        String cancelMsg = 'Your order is successfully canceled. Your Purchase Order/Reference Number is '+this.poNum;
        this.criticalError = null;
        this.errorMessage = null;
        PageReference nextPage;
        system.debug('cancel order |');
        if(this.authorizedPayments==null || this.authorizedPayments.size()==0){
                //no need to call SAP cancel order when there is no authorized payment needs to be canceled
             orderCanceled = true;
            //nextPage= new PageReference('/apex/GNE_LWO_Orderconfirmation');
            log.addLine('forward user to GNE_LWO_Order page ');
            nextPage = Page.GNE_LWO_Order;
            nextPage.getParameters().put('billToNum', billToNum); 
            nextPage.getParameters().put('accountId', accountID);
            nextpage.getParameters().put('cancelConfirmation', cancelMsg);
            nextPage.setRedirect(true);
            return nextPage;
        }else{
                String CancelFlag='X';
            this.debugMessage += '^^^^^^ cancelPaymentAdjustmentOrder before call submit order';
                if(submitOrderToSAP(authorizedPayments, 1, CancelFlag)){
                    orderCanceled = true;
                    system.debug( 'authorized payment has '+this.authorizedPayments.size()+' Authorized amount  = '+this.getTotalAuthorizedAmount());
                    log.addLine('forward user to GNE_LWO_Order page ');
                    nextPage = Page.GNE_LWO_Order;
                    nextPage.getParameters().put('billToNum', billToNum);
                    nextPage.getParameters().put('accountId', accountID);
                    nextpage.getParameters().put('cancelConfirmation', cancelMsg);
                    nextPage.setRedirect(true);
                    return nextPage;
                }else{
                if(this.criticalError !=null && this.criticalError.trim().length()>0){
                        log.addLine('cancelPaymentAdjustmentOrder() forward to error page for - '+criticalError);
                        log.save('GNE_LWO_OrderReviewSubmit_Ctrl - cancelPaymentAdjustmentOrder() Exception: ' + criticalError, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
                        
                        nextPage=new PageReference('/apex/LWO_ErrorPage');
                        nextPage.getParameters().put('ErrorMessage', criticalError);
                        nextPage.setRedirect(true);
                }
                }
        }
        
         log.addLine('enter cancelPaymentAdjustmentOrder()' + nextPage.getUrl());
        
        return nextPage; 
    }
    
    public class DeclinedPaymentCard{
      public Product_Order_Payment_gne__c declinedPayment {set; get;}
      public String declineMSG {set; get;}
      
      public DeclinedPaymentCard(Product_Order_Payment_gne__c dPayment, String dMSG){
        declinedPayment = dPayment;
        declineMSG = dMSG;
      }
      
    }
    
    //Begin of Jie 2015 repeat order M&E
    private String sapOrderId;
    private String repeatOrderMSG;
    private Boolean reenter=false;
    public PageReference repeatOrderProcess(){
        if(reenter){
            debugMessage+=' reenterPage in repeatOrderProcess';
            return null;
        }else{
			
            PageReference tempPage=initShippingBillingPage();
            getAddressValueEdit();
            if(tempPage!=null) return tempPage;
            String pst=System.currentPageReference().getParameters().get('paymentTerm');
            debugMessage+=':::::pst::'+pst;
            if(pst!=null && pst.length()>0){
                try{
                    paymentTerm=Integer.valueOf(pst);
                }catch(Exception e){
                    
                }
                
            }
            matchWithOldCCard(sapOrderId);

           If(vildateOrderForSubmition()==false){
                errorMessage='vildateOrderForSubmition caught error';
                debugMessage+=' errorMessage is '+errorMessage+' --- '+'vildateOrderForSubmition caught error';
               
            } 
    	

        return null;
        }
    }
    
    private void matchWithOldCCard(String sapOId){
        	debugMessage +=' in matchWithOldCCard. .'+sapOId+'. .sapOId';
			List<Product_Order_Payment_gne__c> oldPayments=[select Name, sapCardToken__c, Card_Holder_Name__c, Card_Type__c, Expiration_Date__c, Quantity__c, Total__c from Product_Order_Payment_gne__c where order__r.SAP_Order_ID__c =:sapOId];
            //debugMessage+='oldPayments size '+oldPayments.size();
            if(orderPayments==null || orderPayments.size()<=0) orderPayments=oldPayments;
            if(oldPayments!=null && oldPayments.size()>0 && orderPayments!=null && orderPayments.size()>0) {
            	for(Product_Order_Payment_gne__c p: orderPayments){
               		for(Product_Order_Payment_gne__c o: oldPayments){
                   		if(p.Name==o.Name && p.Card_Holder_Name__c==o.Card_Holder_Name__c && p.Expiration_Date__c==o.Expiration_Date__c && p.Card_Type__c==o.Card_Type__c){
                       		Date d=System.today();
                            If (d.daysBetween(p.Expiration_Date__c)>0){
                            	p.Quantity__c=o.Quantity__c;
                       			p.Total__c=o.Total__c;
                            }
                   		}
               		}
            	}
            }
        	debugMessage+=' getTotalChargeAMT '+getTotalChargeAMT()+' order total '+order.Total__c;
            
    }
}