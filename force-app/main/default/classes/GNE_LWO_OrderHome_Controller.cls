public without sharing class GNE_LWO_OrderHome_Controller extends GNE_LWO_Controller
{       
    public String[] announcements {
        get {
            String[] messages = getHomepageMessage();
            return messages;
        }
        set;
    }
    
    public Boolean hasAnnouncements {
        get {
            if(announcements != null && announcements.size() > 0) {
                return true;
            }
            return false;
        }
        set;
    }   

    public Boolean hasErrors 
    {
        get
        {
            if(errorMessage != null && errorMessage.length() > 0)
            {
                return true;
            }
            else    return false;
            //comment out by Jie
            
        }
        private set;
    }
    
    public String getAccountIndicator()
    {
        return accountIndicator;
    }
    
    public PageReference redirectToExternalHomePage()
    {
        PageReference pageRef = new PageReference(GNE_LWO_CustomSettingsHelper.self().getLWOConfig().LWO_Login_Page__c);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // constructor
    public GNE_LWO_OrderHome_Controller()
    {
        errorMessage='test errors';
        try
        {
            PageReference pageRef = System.currentPageReference();
            this.accountID=pageRef.getParameters().get('accountId');
            this.accountIndicator = pageRef.getParameters().get('accountIndicator');
            this.debugMessage +='| accountID = '+accountID+' | accountIndicator = '+accountIndicator;
            products = new List<LWOProduct>();   
            initProductList();                  
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + GlobalUtils.getExceptionDescription(ex)));
        }
    }
    
    private void initProductList()
    {
        log.addLine('Enter initProductList');
        List<Product_vod__c> parentPrds = [select id from Product_vod__c where name = 'Lucentis' and Product_Type_vod__c = 'Market'];
        if(parentPrds != null && parentPrds.size() == 1)
        {
            Product_vod__c parentPrd = parentPrds.get(0);
            for(Product_vod__c item : [select NDC_Number_gne__c, name, List_Price_gne__c, discount_price__c, max_QTY__c, LWO_Discount_Note__c, product_Image_name__c 
            from Product_vod__c where active__c=true and Web_Order_Enabled_gne__c=true and Product_Type_vod__c='NDC' and Parent_Product_vod__c =: parentPrd.id order by LWO_Product_List_Order__c])
            {                
                System.debug('[RK] Got item = ' + item);
                products.add(new LWOProduct(item));
                System.debug('[RK] Added product = ' + new LWOProduct(item));
            }
        }
        log.addLine('initProductList found '+products.size()+' product. Exit initProductList');
    }
    

    
    public PageReference continueCommercialOrder()
    {
        log.addLine('enter continueCommercialOrder');
        this.criticalError = null;
        
        if(!validateOrder())
        {
            if(this.criticalError!=null){
                log.addLine('continueCommercialOrder found critical error : '+criticalError);
                log.save('GNE_LWO_OrderHome_Controller - continueCommercialOrder() Exception: ' + criticalError, GNE_LWO_Logger.ERROR, GNE_LWO_Logger.SYSTEM_ERROR);
                PageReference errPage = new PageReference('/apex/LWO_ErrorPage');
                errPage.getParameters().put('ErrorMessage', criticalError);
                errPage.setRedirect(true);
                return errPage;
            }
            hasErrors = true;
            return null;
        }
        
        PageReference lwoReview = Page.GNE_LWO_Review;
        
        for(LWOProduct p : products)
        {
            p.qtyError = null;
            if(p.qty > 0)
            {
                lwoReview.getParameters().put(p.product.NDC_Number_gne__c, p.qty+'');
            }       
        }
        lwoReview.getParameters().put('SelectedShippingAddress', addressValue);
        lwoReview.getParameters().put('billToNum', billToNum);
        lwoReview.getParameters().put('accountId', accountID);
        lwoReview.getParameters().put('accountIndicator', accountIndicator);
        lwoReview.setRedirect(true);
        log.addLine('Exit GNE_LWO_OrderHome_Controller - continueCommercialOrder() - billToNum='+billToNum+' : accountID='+accountID+' : accountIndicator='+accountIndicator+' : addressValue='+addressValue);
        
        return lwoReview;
    }
    
    /**
    * Init method called when the LWO home page is displayed.
    */
    public PageReference initLWOHome()
    {   
        try
        {
            PageReference pageRef = System.currentPageReference();
            
            this.accountID = pageRef.getParameters().get('accountId');
            this.accountIndicator = pageRef.getParameters().get('accountIndicator');
            
            // check if user is to be converted to iHCP
            List<GNE_LWO_User__c> lwoUsers = [SELECT Id, Change_Password__c FROM GNE_LWO_User__c WHERE SFDC_User__c = :UserInfo.getUserId() LIMIT 1];
            
            if (lwoUsers != null && !lwoUsers.isEmpty() && lwoUsers.get(0).Change_Password__c == true)
            {
                // redirect to password change
                PageReference conversionPage = new PageReference('https://' + GNE_LWO_CustomSettingsHelper.self().getLWOConfig().Portal_Home__c + '/lwo/GNE_LWO_Convert_User');
                conversionPage.setRedirect(true);
                conversionPage.getParameters().put('sfdcUserId', UserInfo.getUserId());
                return conversionPage;              
            }       
            return getInfo();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + GlobalUtils.getExceptionDescription(ex)));
            return null;
        }
    }
    
    private Boolean validateOrder()
    {
        log.addLine('enter GNE_LWO_OrderHome_Controller - validateOrder()');
        Boolean isValid = true;
        Boolean continueOrder = false;  
        addressSelectionError = '';
        errorMessage = '';
        
        if(products == null){
            this.criticalError = 'No product available for purchase. Please contact a LUCENTIS Customer Specialist at 800.963.1778 for assistance';
            isValid = false;
        }
        
        if(accountID==null || accountID.trim().length()<=0 || 
                billToNum == null || billToNum.trim().length()<=0 ||
                accountIndicator==null || accountIndicator.trim().length()<=0){
            this.criticalError = 'here No account has been selected. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
            criticalError +='accountID='+accountID+' | billToNum='+billToNum+' | accountIndicator='+accountIndicator;
            isValid = false;
        }
        
        if(addressValue == null || addressValue.trim().length()<=0 || addressValue.trim() == 'default'){
            if(shippingAddresses == null || shippingAddresses.size()<=0){
                this.criticalError = 'This account does not have any shipping addresses set up.  Please contact a LUCENTIS Customer Specialist at 800.963.1778 for assistance';
            }else {
                addressSelectionError = 'Please select a shipping address.';
            }
            isValid = false;
        }               
        
        for(LWOProduct p : products)
        {   
            p.qtyError = '';
            
            if(p.qty < 0)
            {                               
                p.qtyError='Order quantity must be greater than 0.';
                isValid = false;                                        
            }   
            else if(p.qty > p.product.max_QTY__c)
            {                               
                p.qtyError = 'Maximum quantity of vials is '+p.product.max_QTY__c+' per order.';
                isValid = false;
            }
            else if(p.qty > 0)
            {                                
                continueOrder = true;
            }
        }
        
        if(isValid && (!continueOrder)){                        
            errorMessage = 'Order quantity must be greater than 0.';
            isValid = false;
        }               
        log.addLine('Exit GNE_LWO_OrderHome_Controller - validateOrder(), return '+isValid);
        return isValid;
    }    

    
    //booleans to decide which landing page section get rerendered
    public Boolean getCommercialOnlyUser(){
        return (accountIndicator!=null && (accountIndicator.trim()=='COM'));
    }
    
    public Boolean getSampleOnlyUser(){
        return (accountIndicator!=null && (accountIndicator.trim()=='SAM'));
    }
    
    public Boolean getBothUser(){
        return (accountIndicator!=null && accountIndicator.trim()=='BTH');
    }
    

    //wilczekk: this will be commented out once header is used everywhere
    public PageReference getHelp() {
        PageReference page;
        if (accountIndicator!=null && (accountIndicator=='SAM' || accountIndicator=='BTH')) {
            page = new PageReference('/apex/GNE_LWO_SampleHelp');
        }
        else {
            page = new PageReference('/apex/GNE_LWO_Help'); 
        } 
        page.setRedirect(true);
        return page;
    }

    public PageReference goHome() {
        return null;
    }
    
    
    
    /*      Populate shipping address dropdown      */
    public List<SelectOption> getShippingAddresses(){         
        return shipAddressOptions;                          
    }
    
}