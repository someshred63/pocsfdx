public without sharing class ProductOrderHistoryController extends LWO_PaginationBase{
 //Jie added on 11/5/14

    String reportDateRange;
    String reportDateType='Order_Date';
   
    public String getReportDateRange(){
         PageReference pageRef = System.currentPageReference();
         reportDateRange = pageRef.getParameters().get('reportDateRange');
        if(reportDateRange==null || reportDateRange.length()<=0) reportDateRange='Default';
        return reportDateRange;
    }
    
    public String getReportDateType(){
         PageReference pageRef = System.currentPageReference();
         reportDateType = pageRef.getParameters().get('reportDateType');
        if(reportDateType==null || reportDateType.trim().length()<=0) reportDateType='Order_Date';
        return reportDateType;
    }
    
    public void setReportDateType(String s){
        if(s==null || s.trim().length()<=0) s='Order_Date';
        reportDateType = s;
    }
       
    public void setReportDateRange(String s){
        reportDateRange=s;
        if(reportDateRange=='THIS_MONTH')       dummyItem.Expected_Ship_Date__c=system.today().toStartOfMonth();
        else if(reportDateRange=='THIS_WEEK')       dummyItem.Expected_Ship_Date__c=system.today().toStartOfWeek();
        else if(reportDateRange=='THIS_QUARTER')        dummyItem.Expected_Ship_Date__c=firstDayOfQuarter();
        else if(reportDateRange=='Default') dummyItem.Expected_Ship_Date__c=null;
        if(s!='Customize') dummyItem.Expected_Delivery_Date__c=system.today();
      
    }
    
    private Date firstDayOfQuarter(){
        Date currDay=system.today();
        Integer quarterNumber = (currDay.Month()-1)/3+1;
        Date firstDayOfQuarter = Date.newInstance(currDay.Year(), (quarterNumber-1)*3+1,1);
        return firstDayOfQuarter;
    }
    private List<SelectOption> reportDateRangeSelections;
    public List<SelectOption> getReportDateRangeSelections(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Default','Default'));
        options.add(new SelectOption('THIS_WEEK','Weekly (Current Week)'));
        options.add(new SelectOption('THIS_QUARTER','Quarterly (Current Quarter)'));
        options.add(new SelectOption('THIS_MONTH','Monthly (Current Month)'));
        options.add(new SelectOption('Customize','Customized'));
        return options;
    }
    
    private List<SelectOption> reportDateTypeSelections;
    public List<SelectOption> getReportDateTypeSelections(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Order_Date','Order Date'));
        options.add(new SelectOption('Delivery_Date','Delivery Date'));
        return options;
    }    
 
    //end of Jie added on 11/5/14


    public static GNE_LWO_Logger log = new GNE_LWO_Logger();
    static GneProductOrderCancelOrder.CancelOrder cancelOrder = null;
    static String SHIPPED_STATUS_ID = null;      
    private Map<String, Boolean> sortDirection;
    public List<LWO_Invoice_Report_Calc__c> invreportscolumns = new List<LWO_Invoice_Report_Calc__c>(); 
      
    String  newsumaryId;
    String sortingOrder; 
    public String sortImage {get; set;}
    public String sortField {get; set;}
        public String recordsNumber {get; set;}
        
    private List<Product_Order_gne__c> orders;
    public  List<SummaryReportWrap> Sorderreport = new List<SummaryReportWrap>(); 

    private List<Product_Order_Item_gne__c> items;
    private Map<ID, List<Product_Order_Item_Shipment_gne__c>> batchNumbers;
    private List<SelectOption> accountOptions = null;
    public  Map<String,String> Accountholder=new Map<String,String>();
    public  List<SelectOption> shiptooptions=null;
    public  SET<ID> OrderIds= new SET<ID>(); 
    public  SET<String>  OrderSAPIds = new SET<String>(); 
    public  SET<String> shipto_addresses = new SET<String>();
    public List<InvoiceReportWrap> InvoiceReport=new List<InvoiceReportWrap>();
    public Map<String,InvoiceReportWrap>  Invoicewrap_map=new Map<String,InvoiceReportWrap>();
    public List<SummaryReportWrap> SummaryReport=new List<SummaryReportWrap>();
    public Map<String,SummaryReportWrap> summarywrap_map = new Map<String,SummaryReportWrap>();
    Public String invoice_searchfield {get;set;}
    public Map<String,Product_Order_Address_gne__c>  ValidAddressesmap=new Map<String,Product_Order_Address_gne__c>();
    
    // its date fields used for date range searching
    private Product_Order_Item_gne__c dummyItem =  new Product_Order_Item_gne__c();
    
    private Product_Order_Item_gne__c item = null;
    
    private Set<Id> accountIds = null;
    public String accountID = null;
    public String accountIndicator = null;
    public String viewName = null;
    private String title = null;
    private List<SelectOption> viewOptions = null;
    private String cancelledOrderId = null;
    public String searchField {get; set;}
    public String searchwrap {get;set;}
    public String search_shipto {get;set;}
    
    public String criticalError {get; set;}
    public String errorMessage {get; set;}
    public String searchMessage  {get; set;}
    public String cancelMessage  {get; set;}
    public String debugMessage  {get; set;}
    public String dateMessage  {get; set;}
    public Boolean searchOptionOn {get; set;}
    public Boolean debug {get; set;}
    
    private Boolean sampleEnrolled;
    public String sampleAccountId {get; set;}
    public String sampleOrderId {get; set;}     
    public String isDesigneeUser {get; set;}
    
    private Product_Order_gne__c order;
    private Integer listSize = 0;
    private Integer InvoiceSize=0;
    private String currentDateValue = null;
    private Date currentDate = null;
    
    private String searchAccountField {get; set;}
    public boolean canPlaceOrder {get; set;}
    
    private String summaryHeader = null;
    private List<String>fullSummary = null; 
     private List<String>fullInvoice = null;
     private boolean isshiptosearch=false; 
    
    private String billToAddress = null;
    private String shipToAddress = null;
    private String billToName = null;
    private String billToAccountNumber = null;
    private String productName = null;
    public boolean ischargemenowenabled{get;set;}
    
    private Datetime lowerRange = Datetime.valueOf('2008-01-01 00:00:00');
    private Datetime upperRange = System.Now();
    
    // check for spaces at beginning of search field
    private Pattern begSearchPattern = Pattern.compile('^( +)(\\w[\\w ]+)$');
    // and trailing spaces...
    private Pattern endSearchPattern = Pattern.compile('^(\\w+ ?\\w+)( +)$');
    
    //A list of all LWO account lists
    private List<List<Account>> allAcntForDropdown;
    //private Account selectedAccount;
    
    //Jie add on 12/23/13 for FPM access restriction
    public Boolean getShownMC(){
        if(GNE_LWO_Controller.getFPMUser()) return false;
        else return true;
    }
    
    // Jie 2/6/13 added
    public Account getSelectedAccount(){
        Account a;
        if(accountID==null){
            PageReference pageRef = System.currentPageReference();
            String aid = pageRef.getParameters().get('accountID');
            if (aid != null && aid != '') {
                accountID = aid;
            }
        }
        if(accountID!=null){
            a=[select Id, Name, SAP_ID_gne__c  from Account where id = :accountID]; 
            billToAccountNumber=a.SAP_ID_gne__c;
        }
        else {
            a= new Account();
            billToAccountNumber='';
        }
        return a;
    }
    
    public List<SelectOption> getAccount(){
        Account a= getSelectedAccount();
        SelectOption so= new SelectOption(a.id, a.Name+' ('+a.SAP_ID_gne__c+')');
        List<SelectOption> alist=new List<SelectOption>();
        alist.add(so);
        return alist;
    }
    
    /* Jie 2/6/13
    private List<List<SelectOption>> allAcntOptions = null;
    */
    static ProductDataController dataController = null;
    static ProductOrderController orderController = null;
    static ProductOrderEntryController entryController = null;
    static {
            dataController = new ProductDataController();
            orderController = new ProductOrderController();
           // entryController = new ProductOrderEntryController();
            
            //cancelOrder = new ProductOrderSFDCProxyController.CancelOrder();
            cancelOrder = new GneProductOrderCancelOrder.CancelOrder();
            
            Product_Order_Code_Lookup_gne__c statusCode = [select id from Product_Order_Code_Lookup_gne__c where Name = 'SHIPPED' limit 1];                         
            SHIPPED_STATUS_ID = statusCode.Id;                         
    }
    //Devi added street address
    Set<String> originalvalues = new Set<String>{'Order#','Order Date','Order By','Ship To#','Ship to Name','Phone/Web','Order Type'};
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    Public List<string> invleftselected{get;set;}
    Public List<string> invrightselected{get;set;}    
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    Set<string> invleftvalues = new Set<string>();
    Set<string> invrightvalues = new Set<string>();
    public String[] selectedcolumns =new String[]{};   
    public boolean saveDefaultColumns {get;set;}
    public boolean Order_num{get;set;}
    public boolean Order_Date{get;set;}
    public boolean Order_By{get;set;}
    public boolean Shipto_num{get;set;}
    public boolean Shipto_name{get;set;}
    public boolean Phone_web{get;set;}
    public boolean Order_type{get;set;}
    public boolean PONum{get;set;}
    public boolean  isQty {get;set;}
    public boolean islotnum {get;set;}
    public boolean isnum_vials {get;set;}
    public boolean istotal {get;set;} 
    public boolean isstatus {get;set;}
    public boolean istracking {get;set;}
    public boolean ischarge_date {get;set;}
    public boolean isdelivery_date {get;set;} 
    public boolean isshiptoname {get;set;} 
    //added by devi 11/11
    public boolean isStreetName {get;set;}
    public boolean isshipdate {get;set;}
    //ended devi 11/11
    public boolean isrefresh=false;
    public boolean invOrder_Date{get;set;}
    public boolean invOrder_Num{get;set;}
    public boolean invInvoice_num{get;set;}
    public boolean invCharge_Date{get;set;}
    public boolean invShipName{get;set;}
    public boolean invQty{get;set;}
    public boolean invAmount{get;set;}
    public boolean invAuthAmount{get;set;}
    public boolean invLot{get;set;}
    public boolean invShipNum {get;set;}
    public boolean invStreet {get;set;} 
    public boolean invCity {get;set;}
    public boolean invState {get;set;}
    public boolean invZipCode {get;set;} 
    public boolean invCCType {get;set;} 
    public boolean invCCNum{get;set;}
    public boolean invCCHolder{get;set;}
    public boolean invCCExp{get;set;} 
    public boolean invPONum{get;set;}
    public boolean invMaterialDesc{get;set;}
    public boolean MaterialDesc{get;set;}    
    
    public Integer numberOfRecods = 500;
       
    public ProductOrderHistoryController() {
        
        if(GNE_LWO_CustomSettingsHelper.self().getLWOConfig().NUMBER_OF_RECORDS__c != null) {
          numberOfRecods = Integer.valueOf(GNE_LWO_CustomSettingsHelper.self().getLWOConfig().NUMBER_OF_RECORDS__c);
        }
    
        sortDirection = new Map<String, Boolean>();
        
                System.debug('inside controller');
                
                
      ischargemenowenabled=false;
        //First check to see if this is invoked with the right entry point or not
        PageReference pageRef = System.currentPageReference();
        String url = pageRef.getUrl();
        
        System.debug('here is url message '+ url);
                
        if(!url.contains('GNE_LWO_OrderSummary') && !url.contains('/ProductOrderHistoryRedirect') && !url.contains('/GNE_LWO_InvoiceReport')){ 
            //User trying to enter order entry process from a wrong entry point
            //criticalError = 'Please click "History" link on the top to view order history';
            criticalError = 'Please click "Account Order Summary" under "Report" to view order summary';
            return;
        }
        
        leftselected = new List<String>();
        rightselected = new List<String>();
        invleftselected = new List<String>();
        invrightselected = new List<String>();   
              
             
        //   List<LWO_Summary_Report_Calc__c> reportscolumns= [select Charge_Date__c,Lot_num__c,Order_By__c,Order_Date__c,Order_Num__c,Order_Type__c,Phone_Web__c,    Quantity__c,Ship_to_Name__c,Ship_to_Number__c,Status__c,Total__c,Tracking_num__c,Vials_Lot__c  from LWO_Summary_Report_Calc__c where User__c=:UserInfo.getUserId()];
                //Street__c added by Devi
                 List<LWO_Summary_Report_Calc__c> reportscolumns= [select Charge_Date__c, Material_Description__c, Delivery_Date__c, PO_Num__c, Lot_num__c, Order_By__c,Order_Date__c,Order_Num__c,Order_Type__c,Phone_Web__c,Quantity__c,Ship_to_Name__c,Ship_to_Number__c,Status__c,Total__c,Tracking_num__c,Vials_Lot__c,Street__c,Ship_Date__c  from LWO_Summary_Report_Calc__c where User__c=:UserInfo.getUserId()];
              System.debug(' size....->'+ reportscolumns.size());
              if(reportscolumns.size()>0){
                // order num is req field . 
                /* if(!reportscolumns[0].Order_Num__c){
                  leftvalues.add('Order #');
                  Order_num=false;
                  }
                  else{ 
                  rightvalues.add('Order #');
                  Order_num=true;
                  }*/
                 
                  if(!reportscolumns[0].PO_Num__c){
                  leftvalues.add('PO#');
                  PONum=false;
                  }
                  else{ 
                  rightvalues.add('PO#');
                  PONum=true;
                  }                 
                
                  if(!reportscolumns[0].Phone_Web__c){
                  leftvalues.add('Phone/Web');
                  Phone_web=false;
                  }
                  else{ 
                  rightvalues.add('Phone/Web');
                  Phone_web=true;
                  }
                  
                  if(!reportscolumns[0].Order_Date__c){
                  leftvalues.add('Order Date');
                  Order_Date=false;
                  }
                  else{
                  rightvalues.add('Order Date');
                  Order_Date=true;
                  }
                     
                  if(!reportscolumns[0].Order_By__c){
                  leftvalues.add('Ordered By');
                  Order_By=false;                  
                  }
                  else{ 
                  rightvalues.add('Ordered By');
                  Order_By=true;
                  }
                  
                  if(!reportscolumns[0].Ship_to_Number__c){
                  leftvalues.add('Ship To#');
                   Shipto_num=false;                  
                  }
                  else{ 
                  rightvalues.add('Ship To#');
                  Shipto_num=true;
                  }
                  
                  if(!reportscolumns[0].Order_Type__c){
                  leftvalues.add('Order Type');
                  Order_type=false;                 
                  }
                  else{ 

                  rightvalues.add('Order Type');
                  Order_type=true; 
                  }
                   
                  if(!reportscolumns[0].Quantity__c){
                    leftvalues.add('Qty');
                    isQty=false;                    
                  }
                  else {
                    rightvalues.add('Qty');
                    isQty=true;
                       }

                  if( !reportscolumns[0].Material_Description__c ){
                    leftvalues.add('Material Description');
                    MaterialDesc =false;
                  }
                  else {
                       rightvalues.add('Material Description');
                       MaterialDesc=true;
                       }    
                                              
                //-----------------       
                if(!reportscolumns[0].Ship_to_Name__c){
                    leftvalues.add('Ship to Name');
                    isshiptoname=false;                  
                  }
                  else {

                    rightvalues.add('Ship to Name');
                    isshiptoname=true;  
                       }
                   
               if( !reportscolumns[0].Lot_num__c){
                         leftvalues.add('Lot #');
                        islotnum =false;
                  }
                  else {
                    rightvalues.add('Lot #');
                    islotnum =true;                        
                       }
                       

              if(!reportscolumns[0].Status__c){
                         leftvalues.add('Status');
                        isstatus=false;                    
                  }
                  else {
                    rightvalues.add('Status');
                    isstatus =true;
                       }
                 
              if( !reportscolumns[0].Total__c){
                         leftvalues.add('SKU Sub Total');
                        istotal=false;
                  }
                  else {
                    rightvalues.add('SKU Sub Total');
                    istotal=true;                        
                       }
                       
              if( !reportscolumns[0].Tracking_num__c){
                         leftvalues.add('Tracking#');
                        istracking=false;
                  }
                  else {
                    rightvalues.add('Tracking#');
                    istracking =true;                        
                       }
                       
               if(!reportscolumns[0].Vials_Lot__c){
                         leftvalues.add('#Vials/Lot');
                       isnum_vials =false;                    
                  }
                  else {

                    rightvalues.add('#Vials/Lot');
                    isnum_vials=true;
                  }         
                
                    
               if(!reportscolumns[0].Charge_Date__c  ){
                         leftvalues.add('Charge Date');
                       ischarge_date  =false;                    
                  }
                  else {
                    rightvalues.add('Charge Date');
                    ischarge_date =true;
                       }          
            
               if( !reportscolumns[0].Delivery_Date__c  ){
                         leftvalues.add('Expected Delivery Date');
                       isdelivery_date   =false;                    
                  }
                  else {
                    rightvalues.add('Expected Delivery Date');
                    isdelivery_date  =true;
                       }
             //Added by Devi 11/11
              if( !reportscolumns[0].Street__c){
                         leftvalues.add('Street Address');
                        isStreetName=false;
                  }
                  else {
                    rightvalues.add('Street Address');
                    isStreetName=true;  
                       }
               if( !reportscolumns[0].Ship_Date__c){
                         leftvalues.add('Expected Ship Date');
                        isshipdate=false;
                  }
                  else {
                    rightvalues.add('Expected Ship Date');
                    isshipdate=true;                        
                       }                           
                       
                //ended Devi 11/11
              }
  
                        
         /*    invreportscolumns= new ApexPages.StandardSetController(Database.getQueryLocator([select Authorized_Amount__c, Charge_Date__c, City__c, Credit_Card_Last_4__c, 
                                                                    Credit_Card_Expiration_Date__c, Credit_Card_Type__c, Invoice__c,    
                                                                    Invoice_Amount__c, Lot__c, Name_of_Card_Holder__c, Order_Num__c,
                                                                    Order_Date__c, Quantity__c, Ship_to_Account__c, Ship_to_Name__c,
                                                                    State__c, Street__c, Zip_Code__c from LWO_Invoice_Report_Calc__c where User__c =:UserInfo.getUserId()])); */
                                                                    
              List<LWO_Invoice_Report_Calc__c> invreportscolumns = [select Authorized_Amount__c, PO_Num__c, Charge_Date__c, City__c, Credit_Card_Last_4__c, 
                                                                    Credit_Card_Expiration_Date__c, Credit_Card_Type__c, Invoice__c,    
                                                                    Invoice_Amount__c, Lot__c, Name_of_Card_Holder__c, Order_Num__c,
                                                                    Order_Date__c, Quantity__c, Ship_to_Account__c, Ship_to_Name__c,
                                                                    State__c, Street__c, Zip_Code__c, Material_Description__c from LWO_Invoice_Report_Calc__c where User__c =:UserInfo.getUserId() LIMIT 1];
                                                                    
          //  initSetController(invreportscolumns,10);
         //   system.debug('------------------------------------------invreportscolumns.getResultSize();---------------'+invreportscolumns.getResultSize());
          
          //  invreportscolumns.setPageSize(10);
        //    system.debug('------------------------------------------invreportscolumns.getResultSize();---------------'+invreportscolumns.getResultSize());
         //   invreportscolumns.getResultSize();
             
            if(invreportscolumns.Size()>0)
            {
                
              if(!invreportscolumns[0].PO_Num__c ){
                   invleftvalues.add('PO / Reference #');
                   invPONum=false;
              }
              else {
                    invrightvalues.add('PO / Reference #');
                    invPONum =true;
                   } 
                       
                  if(!invreportscolumns[0].Order_Date__c){
                    invleftvalues.add('Order Date');
                    invOrder_Date=false;
                  }
                  else{
                      invrightvalues.add('Order Date');
                      invOrder_Date=true;
                  }
                     
                
                  if( !invreportscolumns[0].Charge_Date__c){
                  invleftvalues.add('Charge Date');
                  invCharge_Date=false;     
                  }
                  else{ 
                  invrightvalues.add('Charge Date');
                  invCharge_Date=true;
                  }
                  
                  /*if(!invreportscolumns[0].Lot__c){
                  invleftvalues.add('Lot #');
                  invLot=false; 
                  }
                  else{
                  invrightvalues.add('Lot #');
                  invLot=true;
                  }
               
                  if(!invreportscolumns[0].Material_Description__c ){
                    invleftvalues.add('Material Description');
                    invMaterialDesc =false;
                  }
                  else {
                       invrightvalues.add('Material Description');
                       invMaterialDesc=true;
                       }    
                                      
                  if( !invreportscolumns[0].Quantity__c){
                    invleftvalues.add('Qty(vials)');
                    invQty=false;
                  }
                  else {

                       invrightvalues.add('Qty(vials)');
                       invQty=true;
                       }
                  */    
                if(!invreportscolumns[0].Invoice_Amount__c){
                        invleftvalues.add('Invoice Amount');
                        invAmount=false;
                  }
                  else {
                    invrightvalues.add('Invoice Amount');
                    invAmount=true;                        
                       }
                   
               if(!invreportscolumns[0].Authorized_Amount__c){
                        invleftvalues.add('Auth. Amount');
                        invAuthAmount =false;
                  }
                  else {
                    invrightvalues.add('Auth. Amount');
                    invAuthAmount =true;
                       }
                       
              if( !invreportscolumns[0].Ship_to_Name__c){

                    invleftvalues.add('Ship to Name');
                    invShipName =false; 
                  }
                  else {
                        invrightvalues.add('Ship to Name');
                        invShipName=true;                      
                       }
                       
              if( !invreportscolumns[0].Ship_to_Account__c){
                        invleftvalues.add('Ship to Number');
                        invShipNum=false;
                  }
                  else {
                    invrightvalues.add('Ship to Number');
                    invShipNum =true;                        
                       }
               
              if( !invreportscolumns[0].Street__c){
                    invleftvalues.add('Street');
                    invStreet=false;
                  }
                  else {

                        invrightvalues.add('Street');
                        invStreet=true;
                       }
                                     
              if( !invreportscolumns[0].City__c){
                    invleftvalues.add('City');
                    invCity =false;
                  }
                  else {

                        invrightvalues.add('City');
                        invCity=true;
                       }
                       
               if( !invreportscolumns[0].State__c){
                    invleftvalues.add('State');
                       invState =false;
                    
                  }
                  else {

                      invrightvalues.add('State');
                    invState=true;
                       }         
                
                    
               if( !invreportscolumns[0].Zip_Code__c ){
                   invleftvalues.add('Zip Code');
                       invZipCode  =false;
                   
                  }
                  else {
                       invrightvalues.add('Zip Code');
                    invZipCode =true;
                       
                       }          
   
               if( !invreportscolumns[0].Credit_Card_Type__c ){
                       invleftvalues.add('CC Type');
                       invCCType=false;
                  }
                  else {
                    invrightvalues.add('CC Type');
                    invCCType =true;
                       }    
                       
               if( !invreportscolumns[0].Credit_Card_Last_4__c ){
                       invleftvalues.add('CC Number');
                       invCCNum=false;
                  }
                  else {
                    invrightvalues.add('CC Number');
                    invCCNum =true;
                       }    
               
               if(!invreportscolumns[0].Credit_Card_Expiration_Date__c ){
                       invleftvalues.add('CC Holder');
                       invCCHolder=false;
                  }
                  else {
                    invrightvalues.add('CC Holder');
                    invCCHolder =true;
                       } 
               
               if(!invreportscolumns[0].Name_of_Card_Holder__c ){
                       invleftvalues.add('CC Expiration');
                       invCCExp=false;
                  }
                  else {
                    invrightvalues.add('CC Expiration');
                    invCCExp =true;
                       } 
            }
        
        currentDate = System.Today();
        accountIds = dataController.getAccountIDs();
        
        debug = false;
        
        //Check user profile to enforce whether user can place an order or not
         String profileId = UserInfo.getProfileId();
         
         Profile userProfile = [select Name from Profile where id =: profileId];
         String profileName = userProfile.Name;
         
         //Jie changed on 12/23/13 for FPM access restriction
         if( profileName == 'System Administrator' || profileName=='Web Ordering Admin' || profileName=='GNE-LWO-CUSTOPS' || GNE_LWO_Controller.getFPMUser()) {
            canPlaceOrder = false;
            this.searchOptionOn = true;
           
         }
         else {
            canPlaceOrder  = true;
         }


        //check if sample parameter are passed          
        sampleAccountId = pageRef.getParameters().get('sid');
        sampleOrderId = pageRef.getParameters().get('oid');   
        isDesigneeUser = pageRef.getParameters().get('du'); 
        if( sampleAccountId != null && sampleAccountId.length() >0)
            sampleEnrolled = true;
        else
            sampleEnrolled = false;
                                                
        String selectedAccount = pageRef.getParameters().get('accountID');
        if (selectedAccount != null && selectedAccount != '') {
                accountID = selectedAccount;
        }
        
        String selectedStatus = pageRef.getParameters().get('selectedStatus');
      
        if (selectedStatus != null && selectedStatus != '') {
            setViewName(selectedStatus);
        } 
        else {
            setViewName('ALL');
        }
        // from the History page
        String selectedSearchField = pageRef.getParameters().get('searchField');
        
        search_shipto=pageRef.getParameters().get('search_shipto')!=null?pageRef.getParameters().get('search_shipto'):null;
      
        System.debug('search field selected ***' + selectedSearchField);
        
        if (selectedSearchField != null) {
                searchField = selectedSearchField;
        }
        
       
        
        if (searchField == null || searchField == '') {
            // saved searchField
            selectedSearchField = pageRef.getParameters().get('selectedSearchField');
            if (selectedSearchField != null) {
                    searchField = selectedSearchField;
            }
        }
        
        
        
      
        /* Jie 2/6/13
        if (accountOptions == null || accountOptions.size() == 0) {
            //updateAccountsList();
            this.updateAccountDropdownList();
        }
        */
        if (viewOptions == null || viewOptions.size() == 0) {
            getItemStatusList();
        }
       //setaccountID(accountID);
       //setAccountIndicator(accountID);
       String aIndicator = pageRef.getParameters().get('accountIndicator');
           if(aIndicator != null && aIndicator.trim().length()>0) {
                accountIndicator = aIndicator.trim();
           }
        cancelledOrderId = pageRef.getParameters().get('cancelledOrderId');
        if (cancelledOrderId != null) {
                cancelMessage = 'Order Changed Successfully: Order ' + cancelledOrderId + ' has been cancelled ';                
        }
        if (searchField == null) {
            updateView();
        } else {
            searchOrders();
          
            
        }
        system.debug('COUNT CALLING CALCULATESUMMARY 1');
        
        if(searchField!=null){
            if(url.contains('GNE_LWO_OrderSummary')){// && !url.contains('/ProductOrderHistoryRedirect') && !url.contains('/GNE_LWO_InvoiceReport')){
            CalculateSummary();
           }
            
           if(url.contains('/GNE_LWO_InvoiceReport')){
           generateInvoice();
          }
        }

        system.debug('final method call');
        
    }
    
    
    
    
   
    
    private PageReference updateViewPrepare(){
        
        
        PageReference currentPageRef = System.currentPageReference();
        String url = currentPageRef.getUrl();
        
        String selectedView = currentPageRef.getParameters().get('viewName');
        //String selectedAccount = currentPageRef.getParameters().get('accountID');
        viewName = (selectedView == null) ? viewName : selectedView;
        
        //accountID = (selectedAccount == null) ? accountID : selectedAccount;
       
        selectedView = null;
        //selectedAccount = null;
        searchField = null;
       
        
        if (searchAccountField == null) {
            searchMessage = null;
         }
         
        searchAccountField = null;
        
        setViewName(viewName);
        //setaccountID(accountID);
        setTimeRanges();
        viewAllOrders();
        // add this logic to eliminate unnecessary calculations : by rakesh : 3/22/2012  
        if(url.contains('/GNE_LWO_OrderSummary')){// && !url.contains('/ProductOrderHistoryRedirect') && !url.contains('/GNE_LWO_InvoiceReport')){
        
        currentPageRef.getParameters().put('reportDateRange', reportDateRange);   
        currentPageRef.getParameters().put('reportDateType', reportDateType); 
        CalculateSummary();
        }
        
        if(url.contains('/GNE_LWO_InvoiceReport')){
        generateInvoice();
        }
        
        //System.debug('size of soorder report inside update view prepare' +sorderreport.size());
         
        currentPageRef.getParameters().put('accountID', accountID);
        currentPageRef.getParameters().put('selectedStatus', viewName);
               saveTimeRanges(currentPageRef);
        
        System.debug('****curentpagereference***'+ currentPageRef);
        System.debug('value os refresh'+ isrefresh);
        if(!isrefresh)
        currentPageRef.setRedirect(true);
        else
        currentPageRef.setRedirect(false);
        return currentPageRef;
       
    }
    
    public PageReference updateView(){
        
        System.debug('inside update view');
        clearError();
        dateMessage = '';
        if (cancelledOrderId == null) {
            cancelMessage ='';
        } else {
            cancelledOrderId = null;
        }
        search_shipto='ALL';
        searchField='';
        updateViewPrepare();
        
        return null;
    }
   
    /*
    View all orders
    */
    public void viewAllOrders() {
        
        System.debug('VIEW ALL:SEARCH SHIPTO NAME VALUES '+search_shipto);
        orders = null;
        Date OrdersFrom, OrdersTo;
        
        if (lowerRange != null  && upperRange != null ) {
            OrdersFrom = Date.newInstance(lowerRange.year(),lowerRange.month(),lowerRange.day());
            OrdersTo = Date.newInstance(upperRange.year(),upperRange.month(),(upperRange.day()+1));
            Integer diff = OrdersFrom.daysBetween(OrdersTo);
            debugMessage += 'from/to/diff: ' + OrdersFrom + '/' + OrdersTo + '/' + diff + '<br/>';
            //Integer currentDiff = System.today().daysBetween(OrdersFrom);
            if ((diff < 0) ) {
                dateMessage += 'The "From" date must occur before the "To" date';
                
                lowerRange = Datetime.valueOf('2000-01-01 00:00:00');
                upperRange = System.Now();
                
            }
        }
        
        debugMessage += 'account:' + accountID + ' /view:' + viewName + '<br/>';
        
        // SFDC functional limit for SPQL results set assignments is 200
        // duyent - 021411: added filter to exclude orders with INVALID status
        //Expected_ship_date__c field in the query added by Devi 11/11
        if (viewName == 'ALL') {
            title = 'All orders';   
            debugMessage +='/view:' + viewName + ' /title:'+title+' /reportDateType:'+reportDateType+' /OrdersFrom:'+OrdersFrom+' /OrdersTo:'+OrdersTo+' /system today:'+system.today()+'<br/>';
          if(reportDateType=='Order_Date'){ 
            //filter by order date
            if(reportDateRange=='THIS_WEEK'){
            items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,   Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c, Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c 
                where Order__r.Bill_To__c = :accountID  and (Order__r.Ordered_On__c >= THIS_WEEK)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods];
              
            }else if (reportDateRange=='THIS_MONTH'){   
            items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,   Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c, Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c 
                where Order__r.Bill_To__c = :accountID  and (Order__r.Ordered_On__c >= THIS_MONTH)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods];
            
            }else if (reportDateRange=='THIS_QUARTER'){
             items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,   Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c, Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c 
                where Order__r.Bill_To__c = :accountID  and (Order__r.Ordered_On__c >= THIS_QUARTER)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods];
            
             } else  {  
            items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,   Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c, Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c,Expected_ship_date__c
                from Product_Order_Item_gne__c 
                where Order__r.Bill_To__c = :accountID  and (Order__r.Ordered_On__c >= :OrdersFrom and Order__r.Ordered_On__c <= :OrdersTo)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods];
           }
          }else{
            //filter by delivery date
            if(reportDateRange=='THIS_WEEK'){
            items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,   Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c, Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c 
                where Order__r.Bill_To__c = :accountID  and (Expected_Delivery_Date__c >= THIS_WEEK)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods];
            }else if (reportDateRange=='THIS_MONTH'){   
            items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,   Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c, Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c 
                where Order__r.Bill_To__c = :accountID  and (Expected_Delivery_Date__c >= THIS_MONTH)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods];
            
            }else if (reportDateRange=='THIS_QUARTER'){
             items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,   Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c, Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c 
                where Order__r.Bill_To__c = :accountID  and (Expected_Delivery_Date__c >= THIS_QUARTER)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods];
            
             } else  {  
            items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,   Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c, Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c,Expected_ship_date__c
                from Product_Order_Item_gne__c 
                where Order__r.Bill_To__c = :accountID  and (Expected_Delivery_Date__c >= :OrdersFrom and Expected_Delivery_Date__c <= :OrdersTo)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods];
                
           }
          }
        } else {
            
            title = viewName;
           
            if(reportDateRange=='THIS_WEEK'){
                items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,  Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c,  Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c where Order__r.Bill_To__c = :accountID and Status__r.Name = :viewName 
                and (Order__r.Ordered_On__c >= THIS_WEEK)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by Order__r.SAP_Order_ID__c desc limit :numberOfRecods];
            }else if (reportDateRange=='THIS_MONTH'){ 
                items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,  Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c,  Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c where Order__r.Bill_To__c = :accountID and Status__r.Name = :viewName 
                and (Order__r.Ordered_On__c >= THIS_MONTH)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by Order__r.SAP_Order_ID__c desc limit :numberOfRecods];
            }else if (reportDateRange=='THIS_QUARTER'){
                items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,  Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c,  Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c where Order__r.Bill_To__c = :accountID and Status__r.Name = :viewName 
                and (Order__r.Ordered_On__c >= THIS_QUARTER)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by Order__r.SAP_Order_ID__c desc limit :numberOfRecods];
            }else  {             
            // duyent - 021411: added filter to exclude orders with INVALID status
            items = [select Id, product__r.Description_vod__c,Name, Order__r.PO_Num__c,Order__r.Name,  Order__r.Order_Type__c, Expected_Settlement_Date__c, Expected_Delivery_Date__c,  Order__r.Bill_To__r.Name,  CreatedDate, CreatedBy.FirstName, 
                CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, CreatedBy.Id, Tracking_Number__c,
                Tracking_URL__c,  Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c where Order__r.Bill_To__c = :accountID and Status__r.Name = :viewName 
                and (Order__r.Ordered_On__c >= :OrdersFrom and Order__r.Ordered_On__c <= :OrdersTo)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by Order__r.SAP_Order_ID__c desc limit :numberOfRecods];
            }
        }
          
          
          updatebatchNumbers();  
          
          
          
         System.debug('done with view all orders size'+items.size());      
     }
        
      public void updatebatchNumbers(){
      
        if( items != null && items.size() > 0) {
                        
            batchNumbers = new Map<ID, List<Product_Order_Item_Shipment_gne__c>>();
            
            // get item ids         
            Set<ID> orderItemIds = new Set<ID>();
                        
            for (Product_Order_Item_gne__c item : this.items){              
                orderItemIds.add(item.Id);
            }
                        
            List<Product_Order_Item_Shipment_gne__c> shipments = [Select Batch_Number__c, Order_Item__r.Order__c, Quantity__c from Product_Order_Item_Shipment_gne__c where Order_Item__c in :orderItemIds order by  Order_Item__r.Order__c, id];
            
            
            ID itemId = null;
            List<Product_Order_Item_Shipment_gne__c> itemShipments = new List<Product_Order_Item_Shipment_gne__c>();
            
            // get each Order item's batch numbers, batchNumbers
            for(Product_Order_Item_Shipment_gne__c shipment : shipments) {
                
                if ( itemId == null) {                  
                    itemId = shipment.Order_Item__c;
                    itemShipments.add(shipment);
                    batchNumbers.put(itemId, itemShipments);                    
                }
                else if( itemId == shipment.Order_Item__c) {
                    itemShipments = batchNumbers.get(itemId);                   
                    itemShipments.add(shipment);
                    batchNumbers.put(itemId, itemShipments);
                }
                else {
                    batchNumbers.put(itemId, itemShipments);
                    
                    //start with a new item Id
                    itemId = shipment.Order_Item__c;
                    itemShipments = new  List<Product_Order_Item_Shipment_gne__c>();                    
                    itemShipments.add(shipment);
                    batchNumbers.put(itemId, itemShipments);
                }
            }           
        }
        
       
    }
    //added by Devi on 11/11
    
    public void updatestreetAddress(){

    }

  public  Map<ID, Product_Order_Address_gne__c> getOrderIdToOrderAddress(Set<Id> orderIdSet, List<Product_Order_Item_gne__c> productOrderItemList){

      Map<ID, Product_Order_Address_gne__c> orderIdToOrderAddressMap = new Map<ID, Product_Order_Address_gne__c>();

      if( productOrderItemList != null && productOrderItemList.size() > 0){
   
 
          List<Product_Order_Address_gne__c> addresses = 
            [select id,Billto_Shipto_Name__c,Order__c,Order__r.SAP_Order_ID__c,
             Billing__c,SAP_Address_ID__c,Name,City__c,State__c,Zip__c,Address_line_2__c 
            from Product_Order_Address_gne__c  
            where Order__c in : orderIdSet 
            order by Order__r.SAP_Order_ID__c desc];
        
            // get each Order item's Street Address
            for(Product_Order_Address_gne__c address : addresses) {
                orderIdToOrderAddressMap.put(address.order__c, address);
            }
        }         

        return orderIdToOrderAddressMap;
  }


//Devi changes end 11/11
    
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }

    public PageReference inv_selectclick(){
        invrightselected.clear();
        for(String s : invleftselected){
            invleftvalues.remove(s);
            invrightvalues.add(s);
        }
        return null;
    }                
    
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }

    public PageReference inv_unselectclick(){
        invleftselected.clear();
        for(String s : invrightselected){
            invleftvalues.add(s);
            system.debug('unselect : invleftvalues: '+invleftvalues);
            invrightvalues.remove(s);
        }
        return null;
    }
    
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }


    public List<SelectOption> getSelectedValues(){
       List<SelectOption> options = new List<SelectOption>();
       Map<String,Boolean> columnHolder = new Map<String,Boolean>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList){
          options.add(new SelectOption(s,s));
          columnHolder.put(s,true);
        }       

          PONum = columnHolder.containsKey('PO#')?true:false;
          Order_num=columnHolder.containsKey('Order #')?true:false;
          Order_Date=columnHolder.containsKey('Order Date')?true:false;
          Order_By=columnHolder.containsKey('Ordered By')?true:false;
          Shipto_num=columnHolder.containsKey('Ship To#')?true:false;
          Phone_web=columnHolder.containsKey('Phone/Web')?true:false;
          Order_type=columnHolder.containsKey('Order Type')?true:false;
          MaterialDesc=columnHolder.containsKey('Material Description')?true:false;
          isQty=columnHolder.containsKey('Qty')?true:false;
          islotnum=columnHolder.containsKey('Lot #')?true:false;
          isnum_vials=columnHolder.containsKey('#Vials/Lot')?true:false;
          isshiptoname=columnHolder.containsKey('Ship to Name')?true:false;
          istotal=columnHolder.containsKey('SKU Sub Total')?true:false;
          isstatus=columnHolder.containsKey('Status')?true:false;
          istracking=columnHolder.containsKey('Tracking#')?true:false;
          ischarge_date =columnHolder.containsKey('Charge Date')?true:false;
          isdelivery_date =columnHolder.containsKey('Expected Delivery Date')?true:false;
           
           //Added by Devi 11/11
           isStreetName=columnHolder.containsKey('Street Address')?true:false;
           isshipdate=columnHolder.containsKey('Expected Ship Date')?true:false;
           //Ended by Devi 11/11
           
        return options;
    }  
    
     public List<SelectOption> getInvUnselectedValues(){
        system.debug('invleftvalues: '+invleftvalues);
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();

        tempList.addAll(invleftvalues);

        tempList.sort();
        for(String s : tempList){
            options.add(new SelectOption(s,s));
        }
        return options;
    }


    public List<SelectOption> getInvSelectedValues(){
       List<SelectOption> options = new List<SelectOption>();
       Map<String,Boolean> columnHolder = new Map<String,Boolean>();
        List<string> tempList = new List<String>();
        tempList.addAll(invrightvalues);
        tempList.sort();
        for(String s : tempList){
          options.add(new SelectOption(s,s));
          columnHolder.put(s,true);
        }

          invPONum = columnHolder.containsKey('PO / Reference #')?true:false;
          invOrder_Num=columnHolder.containsKey('Order #')?true:false;
          invOrder_Date=columnHolder.containsKey('Order Date')?true:false;
          invInvoice_num=columnHolder.containsKey('Invoice Number')?true:false;
          invCharge_Date=columnHolder.containsKey('Charge Date')?true:false;
          /*invLot=columnHolder.containsKey('Lot #')?true:false;
          invMaterialDesc = columnHolder.containsKey('Material Description')?true:false;          
          invQty=columnHolder.containsKey('Qty(vials)')?true:false;*/
          invAmount=columnHolder.containsKey('Invoice Amount')?true:false;
          invAuthAmount=columnHolder.containsKey('Auth. Amount')?true:false;
          invShipName=columnHolder.containsKey('Ship to Name')?true:false;
          invShipNum=columnHolder.containsKey('Ship to Number')?true:false;
          invStreet=columnHolder.containsKey('Street')?true:false;
          invCity=columnHolder.containsKey('City')?true:false;
          invState=columnHolder.containsKey('State')?true:false;
          invZipCode=columnHolder.containsKey('Zip Code')?true:false;
          invCCType=columnHolder.containsKey('CC Type')?true:false;
          invCCNum=columnHolder.containsKey('CC Number')?true:false;
          invCCHolder=columnHolder.containsKey('CC Holder')?true:false;
          invCCExp=columnHolder.containsKey('CC Expiration')?true:false;
           
        return options;
    }  
    
    
     public boolean getOrder_Date(){
        SYstem.debug('Order_Date retuned value '+ Order_Date);
        return Order_Date;
    }
      public boolean getOrder_By(){
        return Order_By;
    }
      public boolean getShipto_num(){
        return Shipto_num;
    }
    
      public boolean getPhone_web(){
        return Phone_web;
    }
    
      public boolean getOrder_type(){
        return Order_type;
    }
    
    
    public PageReference fetchSummaryColumns(){
        SYstem.debug('entering here very first');
         integer count = [select count() from LWO_Summary_Report_Calc__c where User__c=:UserInfo.getUserId()];
             
             
             if(count<1)
             {
                LWO_Summary_Report_Calc__c reportselection = new LWO_Summary_Report_Calc__c(User__c=UserInfo.getUserId());
                Insert reportselection;
                PageReference pageRef = System.currentPageReference();
                String url = pageRef.getUrl();
                PageReference pg = new PageReference(url);
                pg.setredirect(true);
                return pg;
             }
             
        
        return null;
        
    }
    
    public pageReference fetchInvoiceColumns(){
        
         integer count = [select count() from LWO_Invoice_Report_Calc__c where User__c=:UserInfo.getUserId()];
             
             
             if(count<1)
             {
                LWO_Invoice_Report_Calc__c invoiceselection = new LWO_Invoice_Report_Calc__c(User__c=UserInfo.getUserId());
                Insert invoiceselection;
                PageReference pageRef = System.currentPageReference();
                String url = pageRef.getUrl();
                PageReference pg = new PageReference(url);
                pg.setredirect(true);
                return pg;
             }
             
        
        return null;
        
    }    
    
    public PageReference refershColumns(){
    isrefresh=true; 
    Map<String,Boolean> checkColumns = new Map<String,Boolean>();   
        
        if(saveDefaultColumns!=null)
        {
            if(saveDefaultColumns){
        List<LWO_Summary_Report_Calc__c> updatereportcols= [select Charge_Date__c, Material_Description__c, Delivery_Date__c, PO_Num__c, Lot_num__c,Order_By__c,Order_Date__c,Order_Num__c,Order_Type__c,Phone_Web__c,  Quantity__c,Ship_to_Name__c,Ship_to_Number__c,Status__c,Total__c,Tracking_num__c,Vials_Lot__c,Street__c,Ship_Date__c,User__c  from LWO_Summary_Report_Calc__c where User__c=:UserInfo.getUserId()];
           //Added Street__c,Ship_Date__c by Devi
          for(String s : rightvalues)
          checkColumns.put(s,true);

        LWO_Summary_Report_Calc__c updatereportcol;
        if(updatereportcols!=null && updatereportcols.size()>0){
            updatereportcol = updatereportcols[0];
        }else {
            updatereportcol = new LWO_Summary_Report_Calc__c();
            updatereportcol.User__c = UserInfo.getUserId();
        }

          updatereportcol.PO_Num__c=checkColumns.containsKey('PO#')?true:false;           
          updatereportcol.Order_Num__c=checkColumns.containsKey('Order #')?true:false;     
          updatereportcol.Order_Date__c=checkColumns.containsKey('Order Date')?true:false;
          updatereportcol.Order_By__c=checkColumns.containsKey('Ordered By')?true:false;
          updatereportcol.Phone_Web__c=checkColumns.containsKey('Phone/Web')?true:false;
          updatereportcol.Ship_to_Number__c=checkColumns.containsKey('Ship To#')?true:false;
          updatereportcol.Order_Type__c=checkColumns.containsKey('Order Type')?true:false;
          updatereportcol.Material_Description__c=checkColumns.containsKey('Material Description')?true:false;          
          updatereportcol.Quantity__c=checkColumns.containsKey('Qty')?true:false;
          updatereportcol.Lot_num__c=checkColumns.containsKey('Lot #')?true:false;
          updatereportcol.Vials_Lot__c =checkColumns.containsKey('#Vials/Lot')?true:false;
          updatereportcol.Ship_to_Name__c=checkColumns.containsKey('Ship to Name')?true:false;
          updatereportcol.Total__c=checkColumns.containsKey('SKU Sub Total')?true:false;
          updatereportcol.Status__c=checkColumns.containsKey('Status')?true:false;
          updatereportcol.Tracking_num__c=checkColumns.containsKey('Tracking#')?true:false;
          updatereportcol.Charge_Date__c=checkColumns.containsKey('Charge Date')?true:false;
          updatereportcol.Delivery_Date__c=checkColumns.containsKey('Expected Delivery Date')?true:false;
          //Added by Devi
          updatereportcol.Street__c=checkColumns.containsKey('Street Address')?true:false;
          updatereportcol.Ship_Date__c=checkColumns.containsKey('Expected Ship Date')?true:false;

         upsert updatereportcol;

        /*List<LWO_Invoice_Report_Calc__c> invupdatereportcol= [select Authorized_Amount__c, Charge_Date__c, City__c, Credit_Card_Last_4__c, 
                                                                    Credit_Card_Expiration_Date__c, Credit_Card_Type__c, Invoice__c,    
                                                                    Invoice_Amount__c, Lot__c, Name_of_Card_Holder__c, Order_Num__c,
                                                                    Order_Date__c, Quantity__c, Ship_to_Account__c, Ship_to_Name__c,
                                                                    State__c, Street__c, Zip_Code__c from LWO_Invoice_Report_Calc__c where User__c =:UserInfo.getUserId()];
  */  
           
            checkColumns.clear();
    
          LWO_Invoice_Report_Calc__c invupdatereportcol;
          List<LWO_Invoice_Report_Calc__c> invupdatereportcols= [select PO_Num__c,Order_Num__c,Order_Date__c,Invoice__c,Charge_Date__c,Authorized_Amount__c, Material_Description__c,Lot__c, Invoice_Amount__c,  Quantity__c,Ship_to_Name__c,Ship_to_Account__c,Street__c,City__c,Zip_code__c,state__c,Credit_Card_Type__c,Credit_Card_Last_4__c,Name_of_Card_Holder__c,Credit_Card_Expiration_Date__c, User__c from LWO_Invoice_Report_Calc__c  where User__c=:UserInfo.getUserId()];
          
          for(String s : invrightvalues)
          checkColumns.put(s,true);
          
          if(invupdatereportcols!=null && invupdatereportcols.size()>0) invupdatereportcol=invupdatereportcols[0];
          else {
            invupdatereportcol = new LWO_Invoice_Report_Calc__c();
            invupdatereportcol.User__c = UserInfo.getUserId();  
          }
          
          invupdatereportcol.PO_Num__c=checkColumns.containsKey('PO / Reference #')?true:false;           
          invupdatereportcol.Order_Num__c=checkColumns.containsKey('Order #')?true:false;
          invupdatereportcol.Order_Date__c=checkColumns.containsKey('Order Date')?true:false;
          invupdatereportcol.Invoice__c=checkColumns.containsKey('Invoice Number')?true:false;
          invupdatereportcol.Charge_Date__c=checkColumns.containsKey('Charge Date')?true:false;
         /* invupdatereportcol.Lot__c=checkColumns.containsKey('Lot #')?true:false;
          invupdatereportcol.Material_Description__c=checkColumns.containsKey('Material Description')?true:false; 
          invupdatereportcol.Quantity__c=checkColumns.containsKey('Qty(vials)')?true:false;*/
          invupdatereportcol.Invoice_Amount__c=checkColumns.containsKey('Invoice Amount')?true:false;
          invupdatereportcol.Authorized_Amount__c=checkColumns.containsKey('Auth. Amount')?true:false;
          invupdatereportcol.Ship_to_Name__c=checkColumns.containsKey('Ship to Name')?true:false;
          invupdatereportcol.Ship_to_Account__c=checkColumns.containsKey('Ship to Number')?true:false;
          invupdatereportcol.Street__c=checkColumns.containsKey('Street')?true:false;
          invupdatereportcol.City__c=checkColumns.containsKey('City')?true:false;
          invupdatereportcol.State__c=checkColumns.containsKey('State')?true:false;
          invupdatereportcol.Zip_Code__c=checkColumns.containsKey('Zip Code')?true:false;
          invupdatereportcol.Credit_Card_Type__c=checkColumns.containsKey('CC Type')?true:false;
          invupdatereportcol.Credit_Card_Last_4__c=checkColumns.containsKey('CC Number')?true:false;
          invupdatereportcol.Name_of_Card_Holder__c=checkColumns.containsKey('CC Holder')?true:false;
          invupdatereportcol.Credit_Card_Expiration_Date__c=checkColumns.containsKey('CC Expiration')?true:false;
             

         upsert invupdatereportcol;
         }
     }
            
            return null;    
    }
            
    
    public boolean getisrefresh(){
        
        
        return isrefresh;
        
    }   
    
    
      public void setrightselected(String[] rightselected) {
        
         this.selectedcolumns = rightselected;
     //    System.debug 
         System.debug('right selected columns --->'+ selectedcolumns);
        } 

      public void setinvrightselected(String[] invrightselected) {
        
         this.selectedcolumns = invrightselected;
     //    System.debug 
         System.debug('right selected columns --->'+ selectedcolumns);
        }     
    
    /*
    View my open orders : search
    */
    public PageReference searchOrders() {
    
        Date OrdersFrom, OrdersTo;
        
       if (lowerRange != null  && upperRange != null ) {
            OrdersFrom = Date.newInstance(lowerRange.year(),lowerRange.month(),lowerRange.day());
            OrdersTo = Date.newInstance(upperRange.year(),upperRange.month(),(upperRange.day()+1));
            Integer diff = OrdersFrom.daysBetween(OrdersTo);
            debugMessage += 'from/to/diff: ' + OrdersFrom + '/' + OrdersTo + '/' + diff + '<br/>';
            //Integer currentDiff = System.today().daysBetween(OrdersFrom);
            if ((diff < 0) ) {
                dateMessage += 'The "From" date must occur before the "To" date';
                
                lowerRange = Datetime.valueOf('2000-01-01 00:00:00');
                upperRange = System.Now();
                
            }
        }
        
        System.debug('inside serach orders');
        
        System.debug('SERACH : SEARCH SHIPTO NAME VALUES '+search_shipto);
        Matcher searchMatcher = null;
        Boolean searchMatched = null;
        Boolean issearchable=true;
        
        if(searchField==null || searchField=='')
        {
            
           if(search_shipto==null|| search_shipto=='' || search_shipto=='ALL'){
            
            issearchable=false;
           viewAllOrders();
          
            
           }
            
        }
        if(issearchable) {
            
            System.debug('&%$#@ inside');
            // first the front end - remove blank spaces
            searchMatcher = begSearchPattern.matcher(searchField);
            searchMatched = searchMatcher.lookingAt();
            if (searchMatched) {
                debugMessage += 'beg 0:' + searchMatcher.group(0) + '/1: ' + + searchMatcher.group(1) + '/2: ' + searchMatcher.group(2) + '<br/>';
                searchField = searchMatcher.group(2);
            }
            // then the trailing end
            searchMatcher = endSearchPattern.matcher(searchField);
            searchMatched = searchMatcher.lookingAt();
            if (searchMatched) {
                debugMessage += 'trail 0:' + searchMatcher.group(0) + '/1: ' + + searchMatcher.group(1) + '/2: ' + searchMatcher.group(2) + '<br/>';
                searchField = searchMatcher.group(1);
            }
            
                    
            // field to be searched = %searchString%
            String currentField = searchField;
            if(!searchField.startsWith('%')){
                currentField =  '%' + currentField;
            }
            if(!searchField.endsWith('%')){
                currentField =   currentField + '%';
            }
           
            debugMessage += ' search field now: ' + currentField + '<br/>';
            invoice_searchfield = currentField;
            //String saveSearchField = searchField;
            items=null;

            
             if (viewName == 'ALL') {
        
            title = 'All orders';  
             System.debug('serach field %&**'+ currentField);
             if(search_shipto!='ALL'){
                
                    items = [select Id,product__r.Description_vod__c, Name, Order__r.PO_Num__c,Order__r.Name,  Order__r.Order_Type__c, Expected_Settlement_Date__c,Expected_Delivery_Date__c, Order__r.Bill_To__r.Name, Order__r.Bill_To__r.AccountNumber, 
                    CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, 
                    CreatedBy.Id, Tracking_Number__c,Tracking_URL__c,  Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                    ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                    from Product_Order_Item_gne__c 
                    where Order__r.Bill_To__c = :accountID  and (Order__r.Ordered_On__c >= :OrdersFrom and Order__r.Ordered_On__c <= :OrdersTo) 
                    and Order__r.Ship_to_Name__c=:search_shipto
                    and ( Order__r.SAP_Order_ID__c like :currentField or Order__r.Ordered_By__c like :currentField or Tracking_Number__c like :currentField or Order__r.PO_Num__c like :currentField) 
                    and Status__r.Visible_To_User__c = true
                    and Status__r.Name <> 'INVALID'
                    order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods];
                
                
             }
             else if(currentField!='%%' && search_shipto=='ALL'){ 
                

                    items = [select Id,product__r.Description_vod__c, Name, Order__r.PO_Num__c,Order__r.Name,  Order__r.Order_Type__c, Expected_Settlement_Date__c,Expected_Delivery_Date__c, Order__r.Bill_To__r.Name, Order__r.Bill_To__r.AccountNumber, 
                    CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, 
                    CreatedBy.Id, Tracking_Number__c,Tracking_URL__c,  Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c
                    ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                    from Product_Order_Item_gne__c 
                    where Order__r.Bill_To__c = :accountID  and (Order__r.Ordered_On__c >= :OrdersFrom and Order__r.Ordered_On__c <= :OrdersTo) 
                    and (Order__r.SAP_Order_ID__c like :currentField or Order__r.Ordered_By__c like :currentField or Tracking_Number__c like :currentField or Order__r.PO_Num__c like :currentField) 
                    and Status__r.Visible_To_User__c = true
                    and Status__r.Name <> 'INVALID'
                    order by  Order__r.SAP_Order_ID__c desc  limit :numberOfRecods]; 
                
                

             }
             
            
             
        } else {
            
            title = viewName;
            // duyent - 021411: added filter to exclude orders with INVALID status
            if(search_shipto!='ALL'){
            items = [select Id, product__r.Description_vod__c,Name, Order__r.Name, Order__r.PO_Num__c, Order__r.Order_Type__c, Expected_Settlement_Date__c,Expected_Delivery_Date__c, Order__r.Bill_To__r.Name, Order__r.Bill_To__r.AccountNumber, 
                CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, 
                CreatedBy.Id, Tracking_Number__c,Tracking_URL__c,  Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c 
                ,Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c  where Order__r.Bill_To__c = :accountID and Status__r.Name = :viewName 
                and (Order__r.Ordered_On__c >= :OrdersFrom and Order__r.Ordered_On__c <= :OrdersTo)
                and Order__r.Ship_to_Name__c=:search_shipto 
                and ( Order__r.SAP_Order_ID__c like :currentField or Order__r.Ordered_By__c like :currentField or Tracking_Number__c like :currentField)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by Order__r.SAP_Order_ID__c desc limit :numberOfRecods];
            }
       
            else if(currentField!='%%' && search_shipto=='ALL'){ 
            items = [select Id,product__r.Description_vod__c, Name, Order__r.Name, Order__r.PO_Num__c, Order__r.Order_Type__c, Expected_Settlement_Date__c,Expected_Delivery_Date__c, Order__r.Bill_To__r.Name, Order__r.Bill_To__r.AccountNumber, 
                CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, Status__r.Name, Status__r.Display_Text__c, Total__c, Order__r.Total__c, Quantity__c, Product__r.Name, 
                CreatedBy.Id, Tracking_Number__c,Tracking_URL__c,  Order__r.Ordered_By__c, Order__r.Ordered_On__c, Order__r.SAP_Order_ID__c, Order__r.order_category__c,Order__r.Ship_to_Name__c,Order__r.Ship_to_Number__c,
                Order__r.payment_term_changed__c, Order__r.payment_term_change_date__c, Expected_ship_date__c
                from Product_Order_Item_gne__c  where Order__r.Bill_To__c = :accountID and Status__r.Name = :viewName 
                and (Order__r.Ordered_On__c >= :OrdersFrom and Order__r.Ordered_On__c <= :OrdersTo)
                and ( Order__r.SAP_Order_ID__c like :currentField or Order__r.Ordered_By__c like :currentField or Tracking_Number__c like :currentField)
                and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID'
                order by Order__r.SAP_Order_ID__c desc limit :numberOfRecods];
           }
           
           
                
        }
            
          
        }
        
          //added by Devi 
          updatestreetAddress();
          
          updatebatchNumbers();
          
          
        
        debugMessage += 'Search field: ' + searchField + '<br/>';

         PageReference pageRef = System.currentPageReference();
         String url = pageRef.getUrl();
         PageReference currentPage;
        if(url.contains('/GNE_LWO_InvoiceReport'))
        currentPage = new PageReference('/apex/GNE_LWO_InvoiceReport');
        else {
        currentPage = new PageReference('/apex/GNE_LWO_OrderSummary');
        //currentPage.getParameters().put('reportDateRange', reportDateRange);
        }
        currentPage.getParameters().put('accountID', accountID);
        currentPage.getParameters().put('selectedStatus', viewName);
        currentPage.getParameters().put('selectedSearchField', searchField);
        currentPage.getParameters().put('search_shipto',search_shipto);
        currentPage.getParameters().put('accountIndicator', accountIndicator);
        
        currentPage.getParameters().put('selectedFrom',null);
        currentPage.getParameters().put('selectedTo',null);
        
        currentPage.getParameters().put('sid', this.sampleAccountId);
        currentPage.getParameters().put('oid', this.sampleOrderId);  
        currentPage.getParameters().put('du', this.isDesigneeUser);
        
        //saveTimeRanges(currentPage);
        system.debug('inside search orders with size'+items.size());
        currentPage.setRedirect(true);
        return currentPage;
       
       return null;
    }
    
    /*
    View selected order
    */
   public PageReference viewOrder() {
        
        String reference ; 
        
        PageReference pageRef = System.currentPageReference();
        String name = pageRef.getParameters().get('name');
         String url = pageRef.getUrl();
        System.debug('order name in order detail ' + name);
              System.debug('INSIDE VIEW ORDER FROM INVOICE -->'+ url );
       
        if(name==null) {
            sYSTEM.DEBUG('NAME IS -->'+ name);
            return null;
        }
        
        //Select Order
        order = orderController.getOrderByOrderNum(name, false);
        
        sYSTEM.DEBUG('order is from order controller' + order);
       
       System.debug('NAME IS ----'+ name);
        if (order != null) {
            String orderId = order.Id;
            order = null;
          
                  
        if(url.contains('/GNE_LWO_OrderSummary')) 
        reference='summary';
        else if (url.contains('/GNE_LWO_InvoiceReport'))
        reference='invoice';
          //&& !url.contains('/ProductOrderHistoryRedirect') && !url.contains('/GNE_LWO_InvoiceReport')){ */
            //PageReference detailPage = new PageReference('/apex/ProductOrderDetail');
            PageReference detailPage = new PageReference('/apex/GNE_LWO_OrderDetail');
            detailPage.getParameters().put('id', orderId);
            detailPage.getParameters().put('selectedStatus', viewName);
            detailPage.getParameters().put('selectedSearchField', searchField);
            
            detailPage.getParameters().put('sid', this.sampleAccountId);  
            detailPage.getParameters().put('oid', this.sampleOrderId);                                
            detailPage.getParameters().put('du', isDesigneeUser); 
            detailPage.getParameters().put('accountId', this.accountId);     
            detailPage.getParameters().put('reference',reference);
                       
            saveTimeRanges(detailPage);
            
            detailPage.setRedirect(false);
            
            System.debug('returning ---->'+ detailPage);
            return detailPage;
        } else {
            System.debug('returning ---null');
            return null;
        }
        
       
        
    }
    /*
    Cancel order
    */
    public PageReference cancelOrder() {
        clearError();
        PageReference pageRef = System.currentPageReference();
        String name = pageRef.getParameters().get('name');
        String sapOrderId = pageRef.getParameters().get('sapOrderId');
       
        if(name==null) {
            return null;
        }
        
        if (sapOrderId == null || sapOrderId == '') {
            debugMessage += 'SAP order id null<br/>';
            cancelMessage = 'Your order cannot be cancelled. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
            return null;
        }
        
        criticalError = '';
        
        Product_Order_Code_Lookup_gne__c cancelledCodeInfo = [select id from Product_Order_Code_Lookup_gne__c where Name = 'CANCELLED' limit 1];
        Product_Order_Item_gne__c item = dataController.getItemInfoForID(name);
        
        return cancelOrderSAP(sapOrderId,item,cancelledCodeInfo,1);
    }
    
     private PageReference cancelOrderSAP(String sapOrderId, Product_Order_Item_gne__c item, Product_Order_Code_Lookup_gne__c cancelledCodeInfo, Integer attempt) {
        
        String message = null;
        try{
           message = '';
               
            GneProductOrderCancelOrder.CancelOrderResponseItem  responseItem = cancelOrder.cancelOrder(sapOrderId, '', 'true');
            //ProductOrderSFDCProxyController.CancelOrderResponseItem  responseItem = cancelOrder.cancelOrder(sapOrderId);
            
            String status = responseItem.Status;
            if(status==null){
                status='true';
            }
        
            if (status == 'syserror') {
            // duyent - 022511 add notification
            String username = UserInfo.getUserName();
            string MessageBody = 'LWO User: ' + username + ' experienced System error - ProductOrderHistoryController - cancelOrderSAP() status = syserror';
              sendNotification (MessageBody);
                debugMessage += 'ERROR: System error : '  + responseItem.Message + ' - Order could not be cancelled.  Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
                cancelMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
                
            } else if (status == 'false') {
                String userMessage;
                if (responseItem.Message.contains('Delivery Completed')) {
                    userMessage = 'Your order is being processed for delivery and cannot be cancelled at this time.';
                } else {
                    userMessage = 'Your order cannot be cancelled.';
                    //userMessage = responseItem.Message;
                }
                cancelMessage = userMessage + '<br/>If you have questions, Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
            } else {   
                // update order item status
                Savepoint sp = Database.setSavepoint();
                try {
                    
                    item.Status__c = cancelledCodeInfo.id;
                    update item;
                    cancelMessage = ' Order Changed Successfully: Order ' + item.Order__r.SAP_Order_ID__c + ' has been cancelled ';
                                            
                } catch (Exception u) {
                    Database.rollback(sp);
                    cancelMessage = u.getMessage();
                    
                }
                
                //now, get the updated record
                //save user selected filters so that they can be restored
                //if view is not ALL, default to CANCELLED so that cancelled order is visible
                String targetStatus = (viewName == 'ALL') ? 'ALL' : 'CANCELLED';
                
                //PageReference currentPage = new PageReference('/apex/ProductOrderHistory');
                PageReference currentPage = new PageReference('/apex/GNE_LWO_OrderSummary');
                currentPage.getParameters().put('accountID', accountID);
                currentPage.getParameters().put('selectedStatus', targetStatus);
                currentPage.getParameters().put('selectedSearchField', searchField);
                currentPage.getParameters().put('cancelledOrderId', item.Order__r.SAP_Order_ID__c);
                
                currentPage.getParameters().put('sid', this.sampleAccountId);
                currentPage.getParameters().put('oid', this.sampleOrderId);  
                currentPage.getParameters().put('du', this.isDesigneeUser);
                
                saveTimeRanges(currentPage);
                
                currentPage.setRedirect(false);
                return currentPage;
                
            }
       } catch(Exception e) {
            message = e.getMessage();
            if(attempt==1){
                    //Only retry for the first time
                    if(message.toLowerCase().indexOf('timed out')>0){
                        return cancelOrderSAP(sapOrderId,item,cancelledCodeInfo, 2);
                    }
            }
            // duyent - 022511 add notification
            String username = UserInfo.getUserName();
            string MessageBody = 'LWO User: ' + username + ' experienced  System error - ProductOrderHistoryController - cancelOrderSAP() status exception';
              sendNotification (MessageBody);
            cancelMessage = 'We are experiencing some technical difficulties. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
                
       }
        return null;
        
    }
    
    // duyent 022511 - send notification
 private void SendNotification(string MessageBody)
    { 
    String SUPPORT_EMAIL = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().SUPPORT_EMAIL__c;
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.setToAddresses( new String[] { SUPPORT_EMAIL } ); 
    message.setSubject( 'SFDC - LWO error');
    message.setPlainTextBody( MessageBody );
    // Send our message.
    Messaging.sendEmail( new Messaging.Email[] { message } );

    }

    private void saveTimeRanges(PageReference targetPageRef) {
        if (dummyItem.Expected_Ship_Date__c != null) {
                String searchFrom = String.valueOf(dummyItem.Expected_Ship_Date__c.year()) + '-' +
                    String.valueOf(dummyItem.Expected_Ship_Date__c.month()) + '-' +
                    String.valueOf(dummyItem.Expected_Ship_Date__c.day());
                targetPageRef.getParameters().put('selectedFrom', searchFrom);
            
        }
        if (dummyItem.Expected_Delivery_Date__c != null) {
                String searchTo = String.valueOf(dummyItem.Expected_Delivery_Date__c.year()) + '-' +
                    String.valueOf(dummyItem.Expected_Delivery_Date__c.month()) + '-' +
                    String.valueOf(dummyItem.Expected_Delivery_Date__c.day());
                targetPageRef.getParameters().put('selectedTo', searchTo);
        }
    }
    
            
    public List<Product_Order_gne__c> getOrders() {
        return orders;
    }
    
    public List<Product_Order_Item_gne__c> getItems() {
        return items;
    }

     
     /*Create a wrapper to hold address, Line item and order details */
    
    
    
    public class SummaryReportWrap
    {
      public ID LineitemID {get;set;}
      //addedd by Devi
      public ID SFDCOrderID {get;set;}
      //ended by Devi
      public String Ordernum {get;set;}
      public String OrderName {get;set;}
      public String  OrderDate {get;set;}
      public String  OrderedBy {get;set;}
      public String  Phone_Web {get;set;}
      public String  OrderType {get;set;}
      public String  MaterialDesc {get;set;}
      public String  Qty {get;set;}
      public String  Total {get;set;}
      public String  Status {get;set;}
      public String  Tracking_url {get;set;}
      public String  Tracking_num {get;set;}
      public String  ChargeDate {get;set;}
      public String  DeliveryDate {get;set;}
      //Added by Devi 11/11
      public String  StreetName {get;set;}
      public String  ShipDate {get;set;}
      //Devi Ended 
      public String Soldtonum {get;set;} 
      public String SoldtoName {get;set;}
      public String ShiptoName {get;set;}
      public String Shiptonum {get;set;}
      public String Display_text {get;set;}
      public String Lotnum {get;set;}
      public String Vials_Lot_num {get;set;}
      public String po_num {get;set;}
      public boolean ischargemenow {get;set;}
     
    }
    
    public void CalculateSummary()
    {
         
          boolean checksearchfield=false;
          set<ID> AccIds = new SET<ID>();  
          SET<String> Account_SAP = new Set<String>();
          Map<String,String> ShipToInfo=new Map<String,String>();
          Map<String,String> SoldToInfo=new Map<String,String>();
          Map<String,String> Shipto_Billto_Name= new Map<String,String>();
          
          System.debug('SEARCH SHIPTO NAME VALUES '+search_shipto);
       //   System.debug('batch numbers size -->'+ batchNumbers.size());
          
          if(search_shipto!=null && search_shipto!='')
          {
            if(search_shipto!='ALL')
           isshiptosearch=true;
           
            
          }
          System.debug('SEARCH FIELD  ****'+searchField +'items size '+ items.size()); 
         
                  
          if(OrderIds.size()>0)
          OrderIds.clear();   
          SummaryReport.clear();           
          for(Product_Order_Item_gne__c poi: items )
        {
            OrderIds.add(poi.Order__r.Id);
            OrderSAPIds.add(poi.Order__r.SAP_Order_ID__c);
            
        }      
            
           /* for(Product_Order_Address_gne__c shiptoorder : [select id,Billto_Shipto_Name__c,Order__c,Order__r.SAP_Order_ID__c,Billing__c,SAP_Address_ID__c,Name,  City__c,State__c,Zip__c from Product_Order_Address_gne__c  where Order__c in : OrderIds order by Order__r.SAP_Order_ID__c desc LIMIT 300])
           {
             if(shiptoorder.Billing__c==true)
             {
                if(!SoldToINfo.containsKey(shiptoorder.Order__c))
                SoldToInfo.put(shiptoorder.Order__c,shiptoorder.SAP_Address_ID__c);
             }
             else if (shiptoorder.Billing__c==false)
             {
                            
              if(!ShipToINfo.containsKey(shiptoorder.Order__c)){
              ShipToInfo.put(shiptoorder.Order__c,shiptoorder.SAP_Address_ID__c);
              Shipto_Billto_Name.put(shiptoorder.Order__c,shiptoorder.Billto_Shipto_Name__c);
              
              }
             }
             
             Account_SAP.add(shiptoorder.SAP_Address_ID__c);
             ValidAddressesmap.put(shiptoorder.Order__r.SAP_Order_ID__c,shiptoorder);
           }
           */ 
           
           if(Accountholder.size()>0)
           Accountholder.clear();
           /*
         for(Account LWOAcc: [select id,name,SAP_ID_gne__c from Account where SAP_ID_gne__c in : Account_SAP and SAP_ID_gne__c!=null LIMIT 300])
         {
          if(!Accountholder.containsKey(LWOAcc.SAP_ID_gne__c))
          Accountholder.put(LWOAcc.SAP_ID_gne__c,LWOAcc.name);
         }   */
         
            
              if(Sorderreport.size()>0)
               Sorderreport.clear();
             
             
             //Added By Devi
            Map<Id,Product_Order_Address_gne__c> orderIdToProductOrderAddressMap = getOrderIdToOrderAddress(OrderIds, items);
            //Ended by Devi
            
             for(Product_Order_Item_gne__c poi: items )
           {
            
            Date dateTemp=null;
            SummaryReportWrap s= new SummaryReportWrap();
            s.LineitemID=poi.id;
            //added by Devi 
            s.SFDCOrderID=poi.Order__r.id;
            //ended by Devi
            s.po_num=(poi.Order__r.PO_Num__c!=null)?poi.Order__r.PO_Num__c:'';
            s.Ordernum=(poi.Order__r.SAP_Order_ID__c!=null)?poi.Order__r.SAP_Order_ID__c:'';
            s.OrderName=(poi.Order__r.Name!=null)?poi.Order__r.Name:'';
            try{
            dateTemp = Date.newInstance(poi.Order__r.Ordered_On__c.year(),poi.Order__r.Ordered_On__c.month(),poi.Order__r.Ordered_On__c.day());
            }catch(Exception e){System.debug('Order On is null');}
            s.OrderDate= String.valueof(dateTemp);
            s.Soldtonum='';//(SoldToInfo.get(poi.Order__r.id)!=null)?SoldToInfo.get(poi.Order__r.id):'';
            s.soldtoName='';//s.SoldtoName=(Accountholder.get(s.Soldtonum)!=null)?Accountholder.get(s.Soldtonum):'';
            s.Shiptonum=poi.Order__r.Ship_to_Number__c;//(ShipToInfo.get(poi.Order__r.id)!=null)?ShipToInfo.get(poi.Order__r.id):'';
            s.ShiptoName=poi.Order__r.Ship_to_Name__c;//(Shipto_Billto_Name.get(poi.Order__r.id)!=null)?Shipto_Billto_Name.get(poi.Order__r.id):'';
            s.OrderedBy=poi.Order__r.Ordered_By__c!=null?poi.Order__r.Ordered_By__c:'';
            s.Phone_web=(poi.Order__r.Order_Type__c!=null)?poi.Order__r.Order_Type__c:'';
            s.OrderType=(poi.Order__r.Order_Category__c!=null)?poi.Order__r.Order_Category__c:'';
            s.MaterialDesc = (poi.product__r.Description_vod__c!=null)?poi.product__r.Description_vod__c:'';
            s.Qty=(poi.Quantity__c!=null)?poi.Quantity__c.format():null;
            
             if( batchNumbers != null && batchNumbers.size() > 0) {                                 
                    List<Product_Order_Item_Shipment_gne__c> itemShipments = batchNumbers.get(s.LineitemID);
                    
                    if( itemShipments != null && itemShipments.size() > 0) {
                        s.Lotnum=itemShipments[0].Batch_Number__c;
                        s.Vials_Lot_num=itemShipments[0].Quantity__c.format();
                    }                   
                }
                else {
                    s.Lotnum='';
                    s.Vials_Lot_num=null;
                }
                
                
               //added by Devi 11/11

                if (s.SFDCOrderID != null) {
                    s.StreetName = '';
                    Product_Order_Address_gne__c orderAddress = orderIdToProductOrderAddressMap.get(s.SFDCOrderID);
                    if (orderAddress != null) {
                        s.StreetName = orderAddress.Name;
                    }
                }
                 
                //ended by devi 
                
            s.Total=(poi.Total__c!=null)?'$' + dataController.convertToCurrency(poi.Total__c.format()):null;    
           // s.Total=(poi.Order__r.Total__c!=null)?'$' + dataController.convertToCurrency(poi.Order__r.Total__c.format()):null;
            s.Status=(poi.Status__r.Name!=null)?poi.Status__r.Name:'';
            s.Tracking_url=(poi.Tracking_URL__c!=null)?poi.Tracking_URL__c:'';
            s.Tracking_num=(poi.Tracking_Number__c!=null)?poi.Tracking_Number__c:'';
            s.ChargeDate=(poi.Expected_Settlement_Date__c!=null)?String.valueof(poi.Expected_Settlement_Date__c):null;
            s.DeliveryDate=(poi.Expected_Delivery_Date__c!=null)?String.valueof(poi.Expected_Delivery_Date__c):null;
            //Added by Devi 11/11
            s.ShipDate=(poi.Expected_Ship_Date__c!=null)?String.valueof(poi.Expected_Ship_Date__c):null;
            //Ended by Devi
            s.Display_text=poi.Status__r.Display_Text__c!=null?poi.Status__r.Display_Text__c:null;
            System.debug('value of shipto search '+isshiptosearch);         
            //if(s.status =='SHIPPED' && poi.Order__r.order_category__c=='Commercial' ){
            if(s.status =='SHIPPED' && poi.Order__r.order_category__c=='Commercial' && 
                (poi.Expected_Settlement_Date__c!=null && poi.Expected_Settlement_Date__c > system.today())
                && (poi.Order__r.payment_term_changed__c==false || (poi.Order__r.payment_term_changed__c==true && poi.Order__r.payment_term_change_date__c<system.today()))){
                s.ischargemenow=true;
            }
            
            else s.ischargemenow=false;
            
        
            Sorderreport.add(s);
            summarywrap_map.put(s.Ordernum,s);  
           // }
       
                   
                   if( batchNumbers != null && batchNumbers.size() > 0) {                                 
                    List<Product_Order_Item_Shipment_gne__c> itemShipments = batchNumbers.get(s.LineitemID);
                    
                    //addd by Devi

                    Product_Order_Address_gne__c itemAddress = orderIdToProductOrderAddressMap.get(s.SFDCOrderID);

                    //ended ny Devi
                    
                    //System.debug('count zise**** '+itemShipments.size() );  
                    if( itemShipments != null && itemShipments.size() > 1) {
                        for(Integer i=1; i < itemShipments.size(); i++) {
                       SummaryReportWrap s1= new SummaryReportWrap();
                        s1.Ordernum=s.Ordernum;
                        s1.po_num=s.po_num;
                        s1.OrderName=s.OrderName;
                        s1.OrderDate=s.OrderDate;
                        s1.Shiptonum=s.Shiptonum;
                        s1.shiptoName=s.ShiptoName;
                        s1.OrderedBy=s.OrderedBy;
                        s1.Phone_web=s.Phone_web;
                        s1.OrderType=s.OrderType;
                        s1.MaterialDesc=s.MaterialDesc ;
                        s1.Qty='0';
                        s1.Lotnum=itemShipments[i].Batch_Number__c;
                        s1.Vials_Lot_num=itemShipments[i].Quantity__c.format();
                        s1.Total='$0.00';
                        s1.Status= s.Status;
                        s1.Tracking_url=s.Tracking_url;
                        s1.Tracking_num=s.Tracking_num;
                        s1.ChargeDate=s.ChargeDate;
                        s1.DeliveryDate=s.DeliveryDate;
                        //Added by Devi
                        s1.ShipDate=s.ShipDate;
                        
                         s1.StreetName = '';
                         if (itemAddress != null) {
                            s1.StreetName=itemAddress.Name;
                         }

                         /*
                         if( itemAddress != null && itemAddress.size() > 0) {
                        
                           s1.StreetName=itemAddress[0].Name;
                         } 
                         */     
                       
                         System.debug('value of shipto address '+s1.StreetName);  
                        //Ended by Devi
                        s1.Display_text=s.Display_text;
                        Sorderreport.add(s1);
                        //summarywrap_map.put(s.Ordernum,s);  
                          
                                        
                        }
                                                
           }
           
          }
                       
        }
 
      
        
        System.debug('size of soorder report inside calculate summary' +sorderreport.size());
                
          
    }
    
      
   /*Following wrapper for Invoice report */
   
   
       
     public class InvoiceReportWrap
    {
      public String PONum {get;set;}
      public String Ordernum {get;set;}
      public String OrderName {get;set;}
      public String  OrderDate {get;set;}
      public String  Invoicenum {get;set;}
      public String ChargeDate {get;set;}
      public String Lotnum {get;set;}
      public String MaterialDesc {get;set;}
      public String  Qty {get;set;}
      public String  Invoice_Amt {get;set;}
      public String  Authorization_Amt {get;set;}
      public String ShiptoName {get;set;}
      public String Shiptonum {get;set;}
      public String Street {get;set;}
      public String City {get;set;}
      public String State {get;set;}
      public String Zipcode {get;set;}
      public String CCtype {get;set;}
      public String CCnum {get;set;}
      public String CCHolder {get;set;}
      public String  CCExp {get;set;}
      public String Display_text {get;set;}
      public boolean hasbillingdoc {get;set;}
      public String attachmentId {get;set;}
      public boolean chargeInvNow {get;set;}
    }
    
   
    public void generateInvoice()
    {
        Integer num_of_creditcards;
        Date invoice_lower;
        Date invoice_upper;
        
        invoice_lower=Date.newInstance(lowerRange.year(),lowerRange.month(),lowerRange.day());
         invoice_upper=Date.newInstance(upperRange.year(),upperRange.month(),upperRange.day());
        //List<LWO_Invoice_Report__c> invoice_storage=new List<LWO_Invoice_Report__c>();
        //List<Product_Order_Payment_gne__c> payment_details=new List<Product_Order_Payment_gne__c>();
        Map<String,LWO_Invoice_Report__c> invoice_map=new Map<String,LWO_Invoice_Report__c>();
        Map<String,InvoiceReportWrap > invoicer_map = new Map<String,InvoiceReportWrap>();
        Map<String,Product_Order_Payment_gne__c> payment_map=new Map<String,Product_Order_Payment_gne__c>();
        List<Product_Order_gne__c> orders_in=new List<Product_Order_gne__c>();
        List<Product_Order_Payment_gne__c> payments_in=new List<Product_Order_Payment_gne__c>();
        orders_in=[select id,SAP_Order_ID__c  from Product_Order_gne__c where id in :OrderIds];
        
        Set<ID> missingPaymentOrders;
        set<ID> validPaymentOrders = new SET<ID>();
        Map<String,String> OrderNamemap = new Map<String,String>();
        if(invoice_map.size()>0)
        invoice_map.clear();
        InvoiceReport.clear();
        OrderSAPIds.clear();
        OrderNamemap.clear();
       
        /*
         for(Product_Order_Item_gne__c poi: items) 
        {
            
            OrderSAPIds.add(poi.Order__r.SAP_Order_ID__c);
            //OrderNamemap.put(poi.Order__r.SAP_Order_ID__c,poi.Order__r.Name);
            
        }      
        */
        
        System.debug('inside invoice report 1 '); 
        
         
        
        
        
        
        System.debug('account id ....'+ accountId);
        String sapId = [select sap_id_gne__c from account where id=:accountId limit 1][0].sap_id_gne__c;
        System.debug('sap id ---'+ SAPID);
        String invoice_query;
        System.debug('invoice quiery----  ' + invoice_query);
        
         if(searchField==null || searchField=='')
        {
            
           if(search_shipto==null|| search_shipto=='' || search_shipto=='ALL'){
             //return updateView();
             
            //issearchable=false;
            invoice_query = 'select id , PO_Num__c, Invoice__c,Invoice_Amount__c,Credit_Card_Last_4__c,SAP_Order_ID__c,Order_Date__c,Charge_Date__c,Lot__c,Material_Description__c, Quantity__c,Authorized_Amount__c,Ship_to_Name__c,Ship_to_Account__c,Street__c,City__c,State__c,Zip_Code__c,Credit_Card_Type__c,Name_of_Card_Holder__c,Credit_Card_Expiration_Date__c ,(select id from attachments order by CreatedDate desc)  from LWO_Invoice_Report__c where Authorized_Amount__c>0 and Account_SAP_ID__c like ' + '\'%'+ sapID+ '%\'' + ' and  (Cancelled__c!=\'X\' or Cancelled__c!=\'x\') and  (Order_Date__c>= :invoice_lower and Order_Date__c <= :invoice_upper) order by SAP_Order_ID__c desc limit :numberOfRecods';

           //return null;
            
           }
           
           else {
            
            invoice_query = 'select id , PO_Num__c, Invoice__c,Invoice_Amount__c,Credit_Card_Last_4__c,SAP_Order_ID__c,Order_Date__c,Charge_Date__c,Lot__c,Material_Description__c, Quantity__c,Authorized_Amount__c,Ship_to_Name__c,Ship_to_Account__c,Street__c,City__c,State__c,Zip_Code__c,Credit_Card_Type__c,Name_of_Card_Holder__c,Credit_Card_Expiration_Date__c ,(select id from attachments order by CreatedDate desc)  from LWO_Invoice_Report__c where Authorized_Amount__c>0 and Account_SAP_ID__c like ' + '\'%'+ sapID+ '%\'' + ' and  (Cancelled__c!=\'X\' or Cancelled__c!=\'x\') and  (Order_Date__c>= :invoice_lower and Order_Date__c <= :invoice_upper)  and Ship_to_Name__c=:search_shipto order by SAP_Order_ID__c desc limit :numberOfRecods';

            
           }
            
        }
        
        else {
            
              if(search_shipto==null|| search_shipto=='' || search_shipto=='ALL')
            invoice_query = 'select id , PO_Num__c, Invoice__c,Invoice_Amount__c,Credit_Card_Last_4__c,SAP_Order_ID__c,Order_Date__c,Charge_Date__c,Lot__c,Material_Description__c, Quantity__c,Authorized_Amount__c,Ship_to_Name__c,Ship_to_Account__c,Street__c,City__c,State__c,Zip_Code__c,Credit_Card_Type__c,Name_of_Card_Holder__c,Credit_Card_Expiration_Date__c ,(select id from attachments order by CreatedDate desc)  from LWO_Invoice_Report__c where Authorized_Amount__c>0 and Account_SAP_ID__c like ' + '\'%'+ sapID+ '%\'' + ' and  (Cancelled__c!=\'X\' or Cancelled__c!=\'x\') and  (Order_Date__c>= :invoice_lower and Order_Date__c <= :invoice_upper)  and  (SAP_Order_ID__c like :invoice_searchfield   or  PO_Num__c like: invoice_searchfield or  Invoice__c like:invoice_searchfield  ) order by SAP_Order_ID__c desc limit :numberOfRecods';

            else 
              invoice_query = 'select id , PO_Num__c, Invoice__c,Invoice_Amount__c,Credit_Card_Last_4__c,SAP_Order_ID__c,Order_Date__c,Charge_Date__c,Lot__c,Material_Description__c, Quantity__c,Authorized_Amount__c,Ship_to_Name__c,Ship_to_Account__c,Street__c,City__c,State__c,Zip_Code__c,Credit_Card_Type__c,Name_of_Card_Holder__c,Credit_Card_Expiration_Date__c ,(select id from attachments order by CreatedDate desc)  from LWO_Invoice_Report__c where Authorized_Amount__c>0 and Account_SAP_ID__c like ' + '\'%'+ sapID+ '%\'' + ' and  (Cancelled__c!=\'X\' or Cancelled__c!=\'x\') and  (Order_Date__c>= :invoice_lower and Order_Date__c <= :invoice_upper)  and  (SAP_Order_ID__c like :invoice_searchfield  or   PO_Num__c like: invoice_searchfield or Invoice__c like:invoice_searchfield ) and  Ship_to_Name__c=:search_shipto order by SAP_Order_ID__c desc limit :numberOfRecods';
            
            
            
        }
        
        
        
        for(LWO_Invoice_Report__c inv: database.query(invoice_query)){
            
            
            OrderSAPIds.add(inv.sap_order_id__c);
            System.debug('sap order id ' +inv.sap_order_id__c );    
            
        }
        
        
        for(Product_order_gne__c prodo : [ select name,sap_order_id__c from product_order_gne__c where sap_order_id__c in : OrderSAPIds])
        {
            if(prodo.sap_order_id__c.contains('1580929'))
            System.debug('sap order is ' + prodo.sap_order_id__c);
            OrderNamemap.put(prodo.SAP_Order_ID__c,prodo.Name);
        }
        
        System.debug('size of map ' + OrderNamemap.size());
        for(LWO_Invoice_Report__c invoicer: database.query(invoice_query))  
        {
             String[] ccNumber;
             Pattern x = Pattern.compile('-');
             if(invoicer.Credit_Card_Last_4__c!=null){
              ccNumber = x.split(invoicer.Credit_Card_Last_4__c);
              System.debug('cc number orig '+ invoicer.Credit_Card_Last_4__c);
            
            }
            InvoiceReportWrap invoice = new InvoiceReportWrap();
            invoice.PONum = (invoicer.PO_Num__c!=null)?invoicer.PO_Num__c:'';
            invoice.Invoicenum=(invoicer.Invoice__c!=null)?invoicer.Invoice__c:'';
            if(invoice.Invoicenum!=null && invoice.Invoicenum!='' && invoicer_map.containskey(invoice.Invoicenum)){
                invoice.Invoice_Amt='0';
            }
            else{
                invoice.Invoice_Amt=(invoicer.Invoice_Amount__c!=null)?dataController.convertToCurrency(invoicer.Invoice_Amount__c.format()):null;
            }
            invoice.Ordernum =(invoicer.SAP_Order_ID__c!=null)?invoicer.SAP_Order_ID__c:''; 
            invoice.OrderName= (invoicer.SAP_Order_ID__C != null && OrderNamemap.containsKey(invoicer.SAP_Order_ID__C))?OrderNamemap.get(invoicer.SAP_Order_ID__C):'' ;
            System.debug('order invoice name '+ invoice.ordername);        
            invoice.OrderDate=invoicer.Order_Date__c!=null?String.valueof(invoicer.Order_Date__c):'';
            invoice.ChargeDate=invoicer.Charge_Date__c!=null?String.valueof(invoicer.Charge_Date__c):'';
            invoice.Lotnum=invoicer.Lot__c!=null?invoicer.Lot__c:null;
            invoice.MaterialDesc = invoicer.Material_Description__c!=null?invoicer.Material_Description__c:'';
            invoice.Qty=invoicer.Quantity__c!=null?dataController.convertToCurrency(invoicer.Quantity__c.format()):'';
            invoice.Authorization_Amt=invoicer.Authorized_Amount__c!=null?dataController.convertToCurrency(invoicer.Authorized_Amount__c.format()):'';
            invoice.ShiptoName=invoicer.Ship_to_Name__c!=null?invoicer.Ship_to_Name__c:'';
            invoice.Shiptonum=invoicer.Ship_to_Account__c!=null?invoicer.Ship_to_Account__c:'';
            invoice.Street=invoicer.Street__c!=null?invoicer.Street__c:'';
            invoice.City=invoicer.City__c!=null?invoicer.City__c:'';
            invoice.State=invoicer.State__c!=null?invoicer.State__c:'';
            invoice.Zipcode=invoicer.Zip_Code__c!=null?invoicer.Zip_Code__c:'';
            invoice.CCtype=invoicer.Credit_Card_Type__c!=null?invoicer.Credit_Card_Type__c:'';
            invoicer.Credit_Card_Last_4__c='';
            invoice.chargeInvNow =(invoicer.SAP_Order_ID__C != null && Summarywrap_map.containsKey(invoicer.SAP_Order_ID__C))?Summarywrap_map.get(invoicer.SAP_Order_ID__C).ischargemenow:null ;        
            
             
           if(ccNumber!=null && ccNumber.size()>1)
            invoice.CCnum=ccNumber[2];//invoicer.Credit_Card_Last_4__c!=null?dataController.convertToCurrency(invoicer.Credit_Card_Last_4__c.format()):null;
           else
            invoice.CCnum=invoicer.Credit_Card_Last_4__c!=null?invoicer.Credit_Card_Last_4__c:'';
            invoice.CCHolder=invoicer.Name_of_Card_Holder__c!=null?invoicer.Name_of_Card_Holder__c:'';
            invoice.CCExp=invoicer.Credit_Card_Expiration_Date__c!=null?String.valueof(invoicer.Credit_Card_Expiration_Date__c):'';
            invoice.hasbillingdoc=false;
            invoice.attachmentId='';
              if(invoicer.attachments.size()>0)
             {
                invoice.attachmentId=invoicer.attachments[0].id;
                invoice.hasbillingdoc=true; 
             } 
                
            
           if(Invoice.Invoicenum!='') 
           {
            
            InvoiceReport.add(invoice);
           }
        
            invoicer_map.put(invoice.Invoicenum,invoice);
        }
        
          System.debug('inside invoice report 2 ');
    }   
        
        
        
        
        
        
   //To be edit
        public PageReference chargeMeNow()
    {
        
        System.debug('reaching here payment ter');
        PageReference pageRef = System.currentPageReference();
        String ordernum = pageRef.getParameters().get('sapOrdernum');   
        String paymentterm='CC00';
        //System.debug(' default payment term'+ paymentterm);
      
      
       GnecommPaymentteras.PaymentTermsRequest2 request = new GnecommPaymentteras.PaymentTermsRequest2();
       request.accountNumber= accountID;
       request.orderNumber=ordernum;
       request.paymentTerm=paymentterm;

    try{
       GnecommPaymentteras.GneCOMM_PaymentTerms_PaymentTerms_SFDC_O_1_WSD_UpdatePaymentTerms_Port submitrequest = new GnecommPaymentteras.GneCOMM_PaymentTerms_PaymentTerms_SFDC_O_1_WSD_UpdatePaymentTerms_Port();
       GnecommPaymentteras.PaymentTermsReply2 reply=submitrequest.processInbound(request,'off');
       String status = 'false';
       if(reply!=null && reply.status!=null)        status = reply.status;
       System.debug('resposne status '+ reply.status );
       System.debug('response message '+ reply.message);
       
       //boolean status =mickSAPPaymentTermChange(ordernum,accountID,paymentterm);
       
       //when status is true, mean order payment term is successfully changed in SAP
       if(status=='true'){
            List<Product_Order_gne__c> orders=[select id, SAP_Order_ID__c,  payment_term_changed__c, payment_term_change_date__c from Product_Order_gne__c where SAP_Order_ID__c =:ordernum];
            if(orders!=null && orders.size()>0){
                Product_Order_gne__c pod=orders[0];
                pod.payment_term_changed__c = true;
                pod.payment_term_change_date__c = system.today();
                update pod;
            }
            if(Sorderreport!=null && Sorderreport.size()>0){
                for(SummaryReportWrap s: Sorderreport){
                if(s.Ordernum==ordernum) s.ischargemenow=false;
                }
            }
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
  
  //Jie test code, need to be removed after development
    private boolean mickSAPPaymentTermChange(String orderid, String accid, String pt){
        List<Product_Order_Item_gne__c> ordItems = [select id, Expected_Settlement_Date__c, Order__r.id, Order__r.SAP_Order_ID__c from Product_Order_Item_gne__c where Order__r.SAP_Order_ID__c =:orderid];
        if(ordItems !=null && ordItems.size()>0){
            for(Product_Order_Item_gne__c ordItem: ordItems){
                ordItem.Expected_Settlement_Date__c = System.today();
            }
            update ordItems;
            return true;
        }
        else return false;
    }  
        
            
   
      
     public List<selectOption>  getShiptoitems()
     {
        
            //shiptooptions.add(new SelectOption('ALL','ALL'));
         List<SelectOption> shiptooptions = new List<SelectOption>();
            
            
        Set<ID> all_orderIds = new Set<ID>();
        Map<String,String> all_shiptos= new Map<String,String>();
        
        /*
          for(Product_Order_Item_gne__c all_orders: [select Order__r.id
                from Product_Order_Item_gne__c 
                where Order__r.Bill_To__c = :accountID and Status__r.Visible_To_User__c = true
                and Status__r.Name <> 'INVALID' order by  Order__r.SAP_Order_ID__c desc  limit 300] )
        {
           // System.debug('*****test tes tes ***'+all_orders.Order__r.Id);
            all_orderIds.add(all_orders.Order__r.Id);
            
        }      
            
          */
          
            System.debug('done adding order ids ');
                          
          /*  for(Product_Order_Address_gne__c all_shiptoorder : [select id,Order__c,Billing__c,Billto_Shipto_Name__c,SAP_Address_ID__c from Product_Order_Address_gne__c  where Order__c in :all_orderIds order by Order__r.SAP_Order_ID__c desc LIMIT 300])
           {
             if (all_shiptoorder.Billing__c==false && all_shiptoorder.Billto_Shipto_Name__c!=null)
             {
              shipto_addresses.add(all_shiptoorder.Billto_Shipto_Name__c);
             }
             
          }  */
        
        for(Product_Order_Address_gne__c all_shiptoorder : [select Billto_Shipto_Name__c from Product_Order_Address_gne__c where Billing__c=false and Billto_Shipto_Name__c!=null and  Order__r.Bill_To__c = :accountID  limit 1000])
        {
             shipto_addresses.add(all_shiptoorder.Billto_Shipto_Name__c);
        } 
       
            
     /*    for(Account LWOAccs: [select id,name,SAP_ID_gne__c from Account where SAP_ID_gne__c in : shipto_addresses and SAP_ID_gne__c!=null LIMIT 300])
         {
          if(!all_shiptos.containsKey(LWOAccs.SAP_ID_gne__c))
          all_shiptos.put(LWOAccs.SAP_ID_gne__c,LWOAccs.name);
         }  */
        
         System.debug('about to enter adding ship to name ');
         shiptooptions.add(new SelectOption('ALL','ALL'));
         
         System.debug('size--->'+shipto_addresses.size());
        for(String s : shipto_addresses)
        {
           //System.debug('adding---->'+s);
            shiptooptions.add(new SelectOption(s,s));
        }
        
        System.debug('done with adding ship to names ');
        return shiptooptions;
        }
            
            
        public void setsearch_shipto(String search_shipto) {
         this.search_shipto = search_shipto;
        }
           

         
    public List<SummaryReportWrap> getSummaryReport()
    {
       system.debug('------------------------------------------Sorderreport.size()-------------------------'+Sorderreport.size());
       
      // initSetController(invreportscolumns,10);
       return Sorderreport;
    }
    
    
    
      public List<InvoiceReportWrap> getInvoiceReport()
    {
        
    
        return InvoiceReport;
        
    }
    
   
    
   
    /*
    Construct Item Status select list
    */
    private void getItemStatusList() {
        List<Product_Order_Code_Lookup_gne__c> orderStatus = dataController.getOrderStatus();
          if(orderStatus==null || orderStatus.size()==0){
              return;
          }
         if(viewOptions==null){
             viewOptions = new List<SelectOption>();
         }
         else{
            viewOptions.clear();
         }
         
        Map<String, String> statusCodes = new Map<String, String>();
         if(orderStatus!=null){
            for (Product_Order_Code_Lookup_gne__c status : orderStatus){
               statusCodes.put(status.Name, status.Display_Text__c);
            }
         }
        
        
         viewOptions.add(new SelectOption('ALL', 'ALL'));
         viewOptions.add(new SelectOption('OPEN', statusCodes.get('OPEN')));
         viewOptions.add(new SelectOption('BEINGPICKED', statusCodes.get('BEINGPICKED')));
         viewOptions.add(new SelectOption('SHIPPED', statusCodes.get('SHIPPED')));
         viewOptions.add(new SelectOption('CHARGED', statusCodes.get('CHARGED')));
         viewOptions.add(new SelectOption('CANCELLED', statusCodes.get('CANCELLED')));
         
         if( getSampleEnrolled()) {
            //viewOptions.add(new SelectOption('PENDING', statusCodes.get('PENDING')));
            viewOptions.add(new SelectOption('PENDINGCONF', statusCodes.get('PENDINGCONF')));
            viewOptions.add(new SelectOption('EXPIRED', statusCodes.get('EXPIRED')));   
         }
        
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
         if(accounts!=null){
            for (Account account : accounts){
                if (accountID == null) {
                    setAccountID(account.id);
                }
                accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')' ));
            }
         }
        
         
    }
    
    
    
    /*
     Update account selection list
    */
     public boolean updateAccountsList(){
           clearError();
           List<Account> accounts = dataController.getAccounts();
           if(accounts==null || accounts.size()==0){
                   criticalError = 'You are not affiliated with any account. Please contact a LUCENTIS Direct Customer Specialist at 800.963.1778 for assistance.';
                   return false;
           }
           if(accountOptions==null){
                   accountOptions = new List<SelectOption>();
           } else{
                   accountOptions.clear();
           }
           String accountNumber = null;
                                
           if(accounts!=null){
                
                for (Account account : accounts){
                    
                    // Account search field was filled in
                    if (searchAccountField != null && searchAccountField != 'all' && searchAccountField != '') {
                        if (account.Name.toLowerCase().contains(searchAccountField.toLowerCase())
                        || account.SAP_ID_gne__c.contains(searchAccountField)) {
                            accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')' ));
                        }
                    } else {
                        if (accountID == null) {
                            accountID = account.Id;
                        }
                        accountOptions.add(new SelectOption(account.Id, account.Name + ' (' + account.SAP_ID_gne__c + ')'));
                   
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
           
           //to-do change it back to accountOptions.size() >= 10
           //if (searchOptionOn == null && accountOptions.size() >= 10) {
           if (searchOptionOn == null && accountOptions.size() >= 4) {
                searchOptionOn = true;
           }
           
           return true;
    }
    
            
    private void setTimeRanges() {
        PageReference pageRef = System.currentPageReference();
        String dateFrom = pageRef.getParameters().get('selectedFrom');
        String dateTo = pageRef.getParameters().get('selectedTo');
        
        System.debug('datefrom and dateto---->' +dateFrom + '--'+ dateTo);
        
        if (dateFrom != null) {
            dummyItem.Expected_Ship_Date__c = Date.valueOf(dateFrom);
            dateFrom = null;
        }
        if (dateTo != null) {
            dummyItem.Expected_Delivery_Date__c = Date.valueOf(dateTo);
            dateTo = null;
        }
        
        
        if (dummyItem.Expected_Ship_Date__c == null) {
            lowerRange = Datetime.valueOf('2000-01-01 00:00:00');
        } else {
            
            lowerRange = Datetime.newInstance(dummyItem.Expected_Ship_Date__c.year(),dummyItem.Expected_Ship_Date__c.month(),dummyItem.Expected_Ship_Date__c.day());
        }
       
        if (dummyItem.Expected_Delivery_Date__c == null) {
            upperRange = System.Now();
        } else {
            
            upperRange = Datetime.newInstance(dummyItem.Expected_Delivery_Date__c.year(),dummyItem.Expected_Delivery_Date__c.month(),dummyItem.Expected_Delivery_Date__c.day(),23,59,59);
        }
        debugMessage += 'from:' + lowerRange + '/to:' + upperRange + '<br/>';
        
        
        System.debug('lower and upper range '+ lowerRange+''+upperRange);
     
    } 
    
    /* Jie 2/6/13
    public  List<SelectOption> getAccounts(){
           // return accountOptions;
      if(this.allAcntForDropdown !=null && this.allAcntForDropdown.size()>0)      
            return this.allAcntOptions.get(0);
      else return new List<SelectOption>();
    }
    */
    public Integer getAccountCount() {
        if (accountOptions !=  null) {
            return accountOptions.size();
        } else {
            return 0;
        }
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
        
        PageReference pageRef = System.currentPageReference();
        String url = pageRef.getUrl();
        GneProductOrderGetAccountInfo.AccountInfo accountInfo = new GneProductOrderGetAccountInfo.AccountInfo();
        system.debug('Account Info '+ accountInfo);
        system.debug('SAP Accoun ID ' + Id);
         GneProductOrderGetAccountInfo.AccountInfoResponseItem[] responseItems;
         if(url.contains('accountIndicator=SAM')){
                 responseItems = accountInfo.accountInfo(account.SAP_ID_gne__c, 'S');
           }
           else         
           {
         responseItems = accountInfo.accountInfo(account.SAP_ID_gne__c, 'C');
           }
        
        
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

    public String getViewName(){
        return this.viewName;
    }
    
    public void setViewName(String name){
        this.viewName = name;
    }
    
    public  List<SelectOption> getViews(){
            return viewOptions;
    }
    
    public String getCriticalError(){
            return criticalError;
    }
    
    public Integer getListSize() {
        if (Sorderreport != null) {
           // return items.size();
           return Sorderreport.size();
        } else {
            return 0;
        }
    }
    
    
    
      public Integer getInvoiceSize() {
        if (InvoiceReport!= null) {
           // return items.size();
           return InvoiceReport.size();
        } else {
            return 0;
        }
    }
    
    
    //public Integer get
    
    
    public String getTitle(){
        return this.title;
    }
    
    public Product_Order_Item_gne__c getItem() {
        //item record instantiated to use its Date fields for time range searching
        return dummyItem;
    }
  
    /*
    Clear out error message
    */
    private void clearError(){
             errorMessage = '';
             criticalError = '';
             //cancelMessage = '';
    }
    
    
    /*
    Back to order list
    */
    public PageReference backToOrderList() {
        //PageReference nextPage  = new PageReference('/apex/ProductOrderHistory');
        PageReference nextPage  = new PageReference('/apex/GNE_LWO_OrderSummary');
        nextPage.setRedirect(false);
        return nextPage;
    }
    
    /* Jie 2/6/13
    public PageReference searchAccounts() {
        PageReference pageRef = System.currentPageReference();
        searchAccountField = pageRef.getParameters().get('searchAccountField');
        this.accountID=null;
        this.updateAccountDropdownList();
        //updateAccountsList();
        //searchAccountField = null;
        return null;
    }
    
    public PageReference showAllAccounts() {
        PageReference pageRef = System.currentPageReference();
        searchAccountField = null;
        this.accountID=null;
        //updateAccountsList();
        this.updateAccountDropdownList();
        return null;
    }
    */
    
    public PageReference viewAllOrderSummary () {
        
        PageReference pageRef = new PageReference('/apex/GNE_LWO_AllOrderSummary');
        return pageRef;         
    }
    
    
      public PageReference viewAllInvoiceSummary () {
        
        PageReference pageRef = new PageReference('/apex/GNE_LWO_AllInvoiceSummary');
        return pageRef;         
    }
    
    
    
    
    public Boolean getAllowCancel() {
        
        if( getSampleEnrolled()) {
            if( isDesigneeUser == 'true')
                return true;
            else return false;
        }
        else return true;
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
    
     public PageReference doInvoiceReport () {
        return doOperation(9);      
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
    
    
    
    
    // pass all Sample related parameters to Commercial
    private PageReference doOperation(Integer operation) {
                        
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
        
          else if( operation == 9){
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
        
        
        
        Boolean acctStatus = null;
        System.debug(' ACCOUNT INDICATOR' + acctStatus);
         PageReference pageRef = System.currentPageReference();
        String aIndicator = pageRef.getParameters().get('accountIndicator');
           if(aIndicator != null && aIndicator.trim().length()>0) {
               aIndicator = aIndicator.trim();
           }
        if(aIndicator=='BTH' || aIndicator=='SAM')
        acctStatus=true;
        else 
        acctStatus=false;
       /* if( sampleAccountId != null && sampleAccountId.length() > 0)
            acctStatus = true;
        else
            acctStatus = false;
         */   
        return acctStatus;
    }    
    
    public PageReference doSample() {
      
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
            if(GNE_LWO_Controller.getAdminUser() && this.accountID != null)
                nextPage.getParameters().put('accountID', this.accountID);                                                                   
            nextPage.setRedirect(false);                              
            return nextPage;
        }
        
        return null;        
            
    }
          
    public String getSummaryHeader() {
        
        summaryHeader ='<td><b>PO#</b></td>';
        summaryHeader +='<td><b>Order #</b></td>';
        summaryHeader +='<td><b>Order Date</b></td>';
        summaryHeader +='<td><b>Ordered By</b></td>';
        summaryHeader +='<td style="text-align:right"><b>Ship To#</b></td>';
        // Added by Devi on 12/1
        summaryHeader +='<td><b>Street Address</b></td>';
        summaryHeader +='<td style="text-align:right"><b>Ship To<br/>Name</b></td>';
        summaryHeader +='<td><b>Phone/<br/>Web</b></td>';
        summaryHeader +='<td><b>Order Type</b></td>';
        summaryHeader +='<td><b>Material Description</b></td>';
        summaryHeader +='<td class="right"><b>Qty</b></td>';
        summaryHeader +='<td><b>Vial<br/>Lot #</b></td>';
        summaryHeader +='<td class="right"><b># Vials/<br/>Lot</b></td>';
        summaryHeader +='<td style="text-align:right"><b>SKU Sub Total</b></td>';
        summaryHeader +='<td><b>Status</b></td>';
        summaryHeader +='<td><b>Charge Date</b></td>';
        summaryHeader +='<td><b>Expected Delivery Date</b></td>';
        // Added by Devi
        //summaryHeader +='<td><b>Street</b></td>';
        summaryHeader +='<td><b>Expected Ship Date</b></td>';
        summaryHeader +='<td><b>Tracking#</b></td>';
                
        return summaryHeader;
    }
          
          
        public String getInvoiceHeader() {

        summaryHeader ='<td><b>PO/Reference #</b></td>';        
        summaryHeader +='<td><b>Order #</b></td>';
        summaryHeader +='<td><b>Order Date</b></td>';
        summaryHeader +='<td><b>Invoice #</b></td>';
        summaryHeader +='<td><b>Charge/<br/>Date</b></td>';
        /*summaryHeader +='<td><b>Lot#</b></td>';
        summaryHeader +='<td><b>Material Description</b></td>';
        summaryHeader +='<td class="right"><b>Qty(vials)</b></td>';*/
        summaryHeader +='<td class="right"><b>Invoice<br/>Amount</b></td>';
        summaryHeader +='<td class="right"><b>Auth<br/>Amount</b></td>'; 
        summaryHeader +='<td style="text-align:right"><b>Ship To Number</b></td>';
        summaryHeader +='<td style="text-align:right"><b>Ship To<br/>Name</b></td>';
        summaryHeader +='<td><b>Street</b></td>';
        summaryHeader +='<td><b>City</b></td>';
        summaryHeader +='<td><b>State</b></td>';
         summaryHeader +='<td><b>Zip<br/>Code</b></td>';
        summaryHeader +='<td><b>CC Type</b></td>';
       summaryHeader +='<td><b>CC<br/>(last-4)</b></td>';
        summaryHeader +='<td><b>CC Holder</b></td>';
         summaryHeader +='<td><b>CC Expiration</b></td>';    
                
        return summaryHeader;
    }    
          
              
    public Boolean getIsFirefox() {
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');        
        if( userAgent.contains('Firefox'))
            return true;
        else
            return false;        
    }
    
    //return true for bothe ie8 and ie9(trident 4.0 and ie9 trident 5.0)
    public Boolean getIsIe9(){
         String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');        
        if(userAgent.contains('Trident/5') || userAgent.contains('Trident/4'))
       return true;
       else 
       return false; 
        
    }
   
    public Boolean getIsIe11(){
         String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');        
        if(userAgent.contains('Trident/7'))
       return true;
       else 
       return false; 
        
    } 
    
   
    
    
    
    public List<String> getFullSummary() {
        
          viewAllOrders();
          CalculateSummary();
        // loop through all line items
        if (fullSummary == null) {
            fullSummary = new List<String>();
        } else {
            fullSummary.clear();
        }
        
        if( Sorderreport == null || Sorderreport.size() == 0)
            fullSummary.add('<tr><td>No order data.</td></tr>');
        else {
            
            String summary = '';
            Integer rownum = 0;
            Integer remainder = 0;
            String lineColor = '';
            List<String> multiBatch;
            
            for(SummaryReportWrap item : this.Sorderreport) {
                
                remainder = math.mod(rownum, 2);
                if( remainder == 0)
                    lineColor = '#EDEDED';
                else
                    lineColor = '#FFFFFF';
                    
                summary = '<tr>';
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                summary += item.po_num;
                summary +='</td>';
                                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                summary += item.Ordernum;
                summary +='</td>';
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top;word-wrap: break-word" width="80px">';
                summary += item.OrderDate;
                summary +='</td>';


                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.OrderedBy == null)
                    summary +='';
                else
                    summary += item.OrderedBy ;
                summary +='</td>';

                summary +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">'; 
                if(item.Shiptonum  == null )
                    summary += '';
                else
                    summary += item.Shiptonum ;
                summary +='</td>';    
                
                //Added by Devi 12/1
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.StreetName == null)
                    summary += '';  
                else            
                    summary += item.StreetName ;             
                summary +='</td>';
                
                //Ended by Devi                     
                
                  summary +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">'; 
                if(item.ShiptoName == null )
                    summary += '';
                else
                    summary += item.ShiptoName ;
                summary +='</td>';    
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                summary += item.Phone_Web;
                summary +='</td>';
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                
                if( item.OrderType == 'Commercial')
                    summary += 'C';
                else
                if(item.OrderType =='Sample')
                    summary += 'S';
                    else summary +='';
                    
                    
                summary +='</td>';

                summary +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                if(item.MaterialDesc == null )
                    summary += '';
                else
                    summary += item.MaterialDesc;
                summary +='</td>';
                                
                summary +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                if(item.Qty == null )
                    summary += '';
                else
                    summary += item.Qty;
                summary +='</td>';
                                                
                // add batch #              
                summary +='<td style="background-color:' + lineColor + '; vertical-align:top">';
                
                                   
                    if( item.Lotnum==null) {
                        summary +=''; 
                    }                   
                
                else summary +=item.Lotnum;
                summary +='</td>';
                
                // add batch qty
                summary +='<td style="background-color:' + lineColor + '; text-align:right; vertical-align:top">';
               
                
                    if( item.Vials_Lot_num==null) {                                                
                        summary += '';
                       
                    }
                
                else summary +=item.Vials_Lot_num;  
                summary +='</td>';
                
                                      
                                              
                summary +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                if( item.Total != null)              
                    //summary += '$' + dataController.convertToCurrency(item.Total.format());
                    summary+=item.Total;
                else
                    summary +='';                             
                summary +='</td>';
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.Status == 'PENDINGCONF')
                    summary += 'PENDING<br/>CONFIRMATION';
                else
                    summary += item.Display_text ;
                summary +='</td>';

                
                
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.ChargeDate != null) {             
                    summary += item.ChargeDate;//.format();
                }
                else
                    summary +='';           
                summary +='</td>';

                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.DeliveryDate != null) {             
                    summary += item.DeliveryDate;//.format();
                }
                else
                    summary +='';           
                summary +='</td>';
                
                //Added by Devi
                
                
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.ShipDate != null) {             
                    summary += item.ShipDate;//.format();
                }
                else
                    summary +='';           
                summary +='</td>';
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.Tracking_num == null)
                    summary += '';  
                else            
                    summary += item.Tracking_num ;             
                summary +='</td>';
                
                
                //Ended by Devi
                                
                summary +='</tr>';
                fullSummary.add(summary);
                rownum +=1;
                
                /*
                if( batchNumbers != null && batchNumbers.size() > 0) {                                 
                    List<Product_Order_Item_Shipment_gne__c> itemShipments = batchNumbers.get(item.LineitemID);
                    if( itemShipments != null && itemShipments.size() > 1) {
                        for(Integer i=1; i < itemShipments.size(); i++) {
                                                
                            remainder = math.mod(rownum, 2);
                            if( remainder == 0)
                                lineColor = '#EDEDED';
                            else
                                lineColor = '#FFFFFF';
                                
                            summary = '<tr>';

                            for(Integer j=0; j < 6; j++) {
                                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top;">';
                                summary +='';
                                summary +='</td>';
                            }
                                                                
                            // add batch #                          
                            summary +='<td style="background-color:' + lineColor + '; vertical-align:top; height:16px">';                           
                            summary +=itemShipments[i].Batch_Number__c;
                            summary +='</td>';
                            
                            // add batch qty
                            summary +='<td style="background-color:' + lineColor + '; text-align:right; vertical-align:top">';
                            summary += itemShipments[i].Quantity__c.format();
                            summary +='</td>';
    
    
                            for(Integer j=0; j < 6; j++) {
                                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top;">';
                                summary +='';
                                summary +='</td>';
                            }
                                
                            summary +='</tr>';
                            fullSummary.add(summary);
                            rownum +=1;
                        }   // for          
                    }// if shipments
                }// if batchNumbers      */                       
            }
        }
                        
        return fullSummary;
    }  
    
    
    
     public List<String> getFullInvoice() {
          
          /*viewAllOrders();
          CalculateSummary();
          */
          generateInvoice();
        // loop through all line items
        if (fullInvoice == null) {
            fullInvoice = new List<String>();
        } else {
            fullInvoice.clear();
        }
        
        if( InvoiceReport.size() == null ||InvoiceReport.size() == 0)
            fullInvoice.add('<tr><td>No order data.</td></tr>');
        else {
            
            String summary = '';
            Integer rownum = 0;
            Integer remainder = 0;
            String lineColor = '';
            List<String> multiBatch;
            
            for(InvoiceReportWrap item : this.InvoiceReport) {
                
                remainder = math.mod(rownum, 2);
                if( remainder == 0)
                    lineColor = '#EDEDED';
                else
                    lineColor = '#FFFFFF';
                    
                summary = '<tr>';
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                summary += item.PONum;
                summary +='</td>';
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                summary += item.Ordernum;
                summary +='</td>';
                
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top;word-wrap: break-word" width="80px">';
                summary += item.OrderDate;
                summary +='</td>';


                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.Invoicenum == null)
                    summary +='';
                else
                    summary += item.Invoicenum ;
                summary +='</td>';

              summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.ChargeDate == null)
                    summary +='';
                else
                    summary += item.ChargeDate;
                summary +='</td>';
             
              summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
               /* if( item.Lotnum== null)
                    summary +='';
                else
                    summary += item.Lotnum ;
                summary +='</td>';
                
              summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.MaterialDesc == null)
                    summary +='';
                else
                    summary += item.MaterialDesc ;
                summary +='</td>';     
                       
              summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.Qty == null)
                    summary +='';
                else
                    summary += item.Qty;
                summary +='</td>';
             
              summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';*/
                if( item.Invoice_Amt == null)
                    summary +='';
                else
                    summary += item.Invoice_Amt ;
                summary +='</td>';
             
              summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.Authorization_Amt== null)
                    summary +='';
                else
                    summary += item.Authorization_Amt ;
                summary +='</td>';
             
              summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.ShiptoName == null)
                    summary +='';
                else
                    summary += item.ShiptoName ;
                summary +='</td>';
                             
               summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.Shiptonum== null)
                    summary +='';
                else
                    summary += item.Shiptonum ;
                summary +='</td>';
             
             summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.Street== null)
                    summary +='';
                else
                    summary += item.Street ;
                summary +='</td>';
             
             summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.City== null)
                    summary +='';
                else
                    summary += item.City ;
                summary +='</td>';
             
             summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.State== null)
                    summary +='';
                else
                   summary+=item.State;
                    summary +='</td>';
                    
                summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.ZipCode== null)
                    summary +='';
                else
                    
                    summary += item.ZipCode;
                summary +='</td>';
             
             summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.CCtype== null)
                    summary +='';
                else
                    summary += item.CCtype;
                summary +='</td>';
             
             summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.CCnum== null)
                    summary +='';
                else
                    summary += item.CCnum;
                summary +='</td>';
             
             summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.CCHolder== null)
                    summary +='';
                else
                    summary += item.CCHolder ;
                summary +='</td>';
             
             summary +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                if( item.CCExp== null)
                    summary +='';
                else
                    summary += item.CCExp ;
                summary +='</td>';
             
             fullInvoice.add(summary);
                             
            }
        }
                        
        return fullInvoice;
    } 
    
    
    
    public PageReference downloadOrderSummary() {
        
                        
        PageReference currentPageRef = System.currentPageReference();
        
        String selectedAccount = currentPageRef.getParameters().get('accountID');
        accountID = (selectedAccount == null) ? accountID : selectedAccount;
        
        
        PageReference excelPage = new PageReference('/apex/GNE_LWO_OrderSummaryExcel');
        excelPage.setRedirect(false);
        return excelPage;
        
    }
    
    
  public PageReference downloadInvoiceSummary(){  
    
     PageReference currentPageRef = System.currentPageReference();
        
        String selectedAccount = currentPageRef.getParameters().get('accountID');
        accountID = (selectedAccount == null) ? accountID : selectedAccount;
       
        PageReference excelPage = new PageReference('/apex/GNE_LWO_InvoiceSummaryExcel');
        excelPage.setRedirect(false);
        return excelPage;
        
    
  }
      
/* Jie 2/6/13
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
*/
/* Jie 2/6/13
    public  List<SelectOption> getAccounts2(){
            //return accountOptions;
       if(this.allAcntOptions !=null && this.allAcntForDropdown.size()>1)
            return this.allAcntOptions.get(1);
       else return new List<SelectOption>();
    }   
 */   
    //Generate order summary download string
    public String getOrderItemsDownloadStr(){
        //Street, Expected Ship Date  Added by Devi
               String str='PO#\t Order #\t Order Date\t Ordered By\t Ship To#\t Street Address\t Shipped To Name\t Phone/Web\t Order Type\t Material Description\t Qty\t Lot#\t #Vials/Lot\t SKU Sub Total\t Status\t Charge Date\t Expected Delivery Date\t Expected Ship Date\t Tracking#';
        if(items!=null && items.size()>0){
            for(SummaryReportWrap item : this.Sorderreport){
                str +='\n';
                str +=(item.po_Num==null)? '\t': item.po_Num+'\t';
                str +=(item.Ordernum==null)? '\t': item.Ordernum+'\t';
                str +=(item.OrderDate == null) ? '\t': item.OrderDate+'\t';
                str +=(item.OrderedBy ==null)? '\t': item.OrderedBy +'\t';
                str +=(item.Shiptonum  == null) ? '\t':item.Shiptonum +'\t';
                //Added by Devi on 12/1
                str +=(item.StreetName==null) ? '\t': item.StreetName+'\t';
                str +=(item.ShiptoName  ==null)? '\t': item.ShiptoName +'\t';
                
                if( item.Phone_Web!='SMPL') str += item.Phone_Web+'\t';
                else str +='\t';
                 
                if( item.OrderType =='Commercial') str +='C\t';
                else if(item.OrderType=='Sample') str +='S\t';
                else str+='\t';
                
                str +=(item.MaterialDesc == null) ? '\t':  item.MaterialDesc+'\t';
                str +=(item.Qty == null) ? '\t':  item.Qty+'\t';
                str+=(item.Lotnum == null) ? '\t': item.Lotnum +'\t';
                str+=(item.Vials_Lot_num== null) ? '\t': item.Vials_Lot_num +'\t';
               

                str +=(item.Total == null) ? '\t':item.Total+'\t';
                
                if(item.Status  =='PENDINGCONF') str +='PENDING CONF.\t';
                else if(item.Status  =='BEINGPICKED') str +='IN PROCESS\t';
                else str +=( item.Display_text  == null) ? '\t': item.Display_text +'\t';
                
                str +=( item.ChargeDate==null) ? '\t': item.ChargeDate+'\t';
                str +=(item.DeliveryDate==null) ? '\t': item.DeliveryDate+'\t';
                
                //Added by Devi
                
                str +=(item.ShipDate==null) ? '\t': item.ShipDate+'\t';
                str +=( item.Tracking_num ==null) ? '\t': item.Tracking_num +'\t';
                //Ended by Devi
            }
        }
        return str;
    }
    
    
     //Generate Invoice report download string
    public String getInvoiceItemsDownloadStr(){
       
             String str='PO/Reference #\t Order #\t Order Date\t Invoice #\t Charge Date\t Invoice Amt\t Auth Amt\t Ship to Name\t Ship to #\t Street\t City\t State\t Zip\t CC Type\t CC Number\t CC Holder\t CC Expiration';
       
        if( InvoiceReport.size()== null ||InvoiceReport.size() == 0)
            System.debug('No invoice data to download');
        else {
                            
            for(InvoiceReportWrap item : this.InvoiceReport) {
                
     
                str +='\n';
                str +=(item.PONum==null)? '\t': item.PONum+'\t';
                str +=(item.Ordernum==null)? '\t': item.Ordernum+'\t';
                str +=(item.OrderDate == null) ? '\t': item.OrderDate+'\t';
                str +=(item.Invoicenum ==null)? '\t': item.Invoicenum +'\t';
                str +=(item.ChargeDate  == null) ? '\t':item.ChargeDate +'\t';
                /*str +=(item.Lotnum  ==null)? '\t': item.Lotnum +'\t';
                str +=(item.MaterialDesc==null)? '\t': item.MaterialDesc+'\t';                              
                str +=(item.Qty == null) ? '\t':  item.Qty+'\t';*/
                str +=(item.Invoice_Amt == null) ? '\t': item.Invoice_Amt  +'\t';
                str +=(item.Authorization_Amt == null) ? '\t': item.Authorization_Amt +'\t';
                str +=(item.ShiptoName == null) ? '\t': item.ShiptoName  +'\t';
                str +=(item.Shiptonum == null) ? '\t': item.Shiptonum  +'\t';
                str +=(item.Street==null) ? '\t': item.Street+'\t';
                str +=(item.City==null) ? '\t': item.City+'\t';
                str +=(item.State==null) ? '\t': item.State+'\t';
                str +=(item.Zipcode==null) ? '\t': item.Zipcode+'\t';   
                str +=(item.CCtype==null) ? '\t': item.CCtype+'\t'; 
                str +=(item.CCnum==null) ? '\t': item.CCnum+'\t'; 
                str +=(item.CCHolder==null) ? '\t': item.CCHolder+'\t'; 
                str +=(item.CCExp==null) ? '\t': item.CCExp+'\t'; 
              //  str +=( item.Display_text==null) ? '\t': item.Display_text+'\t'; 
                
            }
        }
        return str;
    }        
       
 
     public boolean getEnableSampleOrderTab(){
        if(this.getSampleEnrolled()==false || (GNE_LWO_Controller.getAdminUser()==true)){
            return false;
        }   else {
                return true;
        }
    }     
    
      private integer getPageNumberForWidget(integer pageSize,integer emailsListSize, integer emailNo)
      {       
        integer pageNo = 0;
        integer counter = 0;
        do
        {
            counter+=pageSize;
            pageNo++;
        }
        while(counter < emailNo);
        return pageNo;
    }
    
    public Integer getnumberOfRecods(){
        
        return numberOfRecods;
    }
    
    
   
    
    //Jie 2015 repeat order M&E
    public PageReference repeatOrder(){
        
        PageReference pageRef = System.currentPageReference();
        String ordernum = pageRef.getParameters().get('sapOrdernum'); 
        boolean goodRepeat=true;   
        String errorMSG='';  
        String paymentTerm='';
        
        
        Product_Order_gne__c curOrder=[select Bill_To__r.SAP_ID_gne__c,Ship_to_Number__c,Total__c from Product_Order_gne__c where SAP_Order_ID__c=:ordernum];
        List<Product_Order_Item_gne__c> orderLineNums=[select Product__r.NDC_Number_gne__c, Quantity__c, Expected_Settlement_Date__c,Expected_Ship_Date__c from Product_Order_Item_gne__c where Order__r.SAP_Order_ID__c =:ordernum];

        if(orderLineNums!=null && orderLineNums.size()>0){
        
             //Jie 3/2/17 disable reorder when some product inventory is not avaliable
            //To check whether any product is disabled for reorderrMSG='';
            for(Product_Order_Item_gne__c curItem: orderLineNums){
                List<Product_vod__c> prds=[select Disable_reorder__c, Disable_reorder_MEssage__c, NDC_Number_gne__c, Web_Order_Enabled_gne__c, active__c from Product_vod__c where Web_Order_Enabled_gne__c=true and NDC_Number_gne__c =: curItem.Product__r.NDC_Number_gne__c ];
                if(prds!=null && prds.size()==1 && PRDS[0].Disable_reorder__c==true){
                    this.cancelMessage=PRDS[0].Disable_reorder_MEssage__c;
                    return null;
                }
            }
            // end of Jie 3/2/17 update for disable reorder
            
            Date startD=orderLineNums[0].Expected_Ship_Date__c;
            Date endD=orderLineNums[0].Expected_Settlement_Date__c;
            Integer days=startD.daysBetween(endD);
            if(days>1) paymentTerm='60';
            else paymentTerm='0';
        }
       if(sapSimulateOrder(orderLineNums,curOrder.Bill_To__r.SAP_ID_gne__c, curOrder.Ship_to_Number__c, curOrder.Total__c )==false) {
            goodRepeat = false;
            errorMSG='There have been recent order total changes to the order that you are copying.  Please reallocate the Charge Amount for this purchase.';
        }
        else if(getSAPAccountInfo(curOrder.Bill_To__r.SAP_ID_gne__c,ordernum, curOrder.Total__c)==false){
            
                goodRepeat = false;
                errorMSG='There have been recent changes to your payment options. Please update your payment option or add another credit card for this purchase.';
            
        }
        
        if(goodRepeat==true){
            PageReference orderSubmit = new PageReference('/apex/gne_lwo_submit');
            
            orderSubmit.getParameters().put('sapOrdernum', ordernum);
            orderSubmit.getParameters().put('paymentTerm', paymentTerm);
            orderSubmit.getParameters().put('accountIndicator', accountIndicator);
            orderSubmit.getParameters().put('accountId',accountId);
            orderSubmit.getParameters().put('billToNum',curOrder.Bill_To__r.SAP_ID_gne__c);
            orderSubmit.getParameters().put('SelectedShippingAddress',curOrder.Ship_to_Number__c);
            if(orderLineNums!=null && orderLineNums.size()>0){
                for(Product_Order_Item_gne__c i:orderLineNums){
                    orderSubmit.getParameters().put(i.Product__r.NDC_Number_gne__c,i.Quantity__c+'');
                }
            
            }
            orderSubmit.setRedirect(true);
            return orderSubmit;
        }else {
            PageReference orderReview = new PageReference('/apex/gne_lwo_review');
            orderReview.getParameters().put('counter', debugCCard);
            orderReview.getParameters().put('repeatOrderError', errorMSG);
            orderReview.getParameters().put('sapOrdernum', ordernum);
            orderReview.getParameters().put('accountIndicator', accountIndicator);
            orderReview.getParameters().put('accountId',accountId);
            orderReview.getParameters().put('billToNum',curOrder.Bill_To__r.SAP_ID_gne__c);
            orderReview.getParameters().put('SelectedShippingAddress',curOrder.Ship_to_Number__c);
            if(orderLineNums!=null && orderLineNums.size()>0){
                for(Product_Order_Item_gne__c i:orderLineNums){
                    orderReview.getParameters().put(i.Product__r.NDC_Number_gne__c,i.Quantity__c+'');
                }
            
            }
            orderReview.setRedirect(true);
            return orderReview;
        }
            
        
    }
    
    
    private boolean compareCCard(){
        return true;
    }
    
/*
* Simulate order
* Invoked between Step #1 and Step #2
*/
    private Boolean sapSimulateOrder(List<Product_Order_Item_gne__c> items, String billToNum, String addressValue, Decimal oldTotal) {
        
        this.debugMessage += ' in sapSimulateOrder | ';
        system.debug(' in sapSimulateOrder | ');
        try{
            
            
            if(items == null || items.size() == 0){
                return false;
            }
            
            Integer requestItemCount = orderLineItemCounter(items)+1;
            
            //Populate request object
            GneProductOrderSimulateOrder.SimulateOrderRequestItem[] requestItems = new GneProductOrderSimulateOrder.SimulateOrderRequestItem[requestItemCount];
            
            //Set order level request
            GneProductOrderSimulateOrder.SimulateOrderRequestItem requestItem = new GneProductOrderSimulateOrder.SimulateOrderRequestItem();

            
            Integer index=0;
            
            requestItem.requestItemType='order';
            requestItem.billToId = billToNum;
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
                    requestItem.expectedDeliveryDate = '';
                    this.debugMessage +=' | send to SAP requestItem.quantity '+ requestItem.quantity+' | NDC='+requestItem.productNDC+' | expectedDeliveryDate='+requestItem.expectedDeliveryDate;
                    system.debug(' | send to SAP requestItem.quantity '+ requestItem.quantity+' | NDC='+requestItem.productNDC+' | expectedDeliveryDate='+requestItem.expectedDeliveryDate);
                    requestItems[++index]=requestItem;

                }
            }       
            
              
            this.debugMessage +='before call out';
            GneProductOrderSimulateOrder.SimulateOrderResponseItem[] simulateOrderResponseItems =  new GneProductOrderSimulateOrder.SimulateOrder().simulateOrder(requestItems);
            this.debugMessage +='after call out';
            if (simulateOrderResponseItems == null ||simulateOrderResponseItems.size() == 0) {

                criticalError = GNE_LWO_Controller.GENERIC_ERROR_MSG;        
                return false;
            }
            
            for (GneProductOrderSimulateOrder.SimulateOrderResponseItem response:simulateOrderResponseItems) {
                String responseType = response.ResponseItemType;
                String status = response.Status;
                this.debugMessage +='$$$$$$$$$$$$$status**********'+status+'$$$$$response message '+response.Message+'|';
                system.debug('$$$$$$$$$$$$$status**********'+status+'$$$$$response message '+response.Message+'|');
                if (status == null || status.trim().length()==0) {
                    status = 'true';
                }
                
                if (status != 'true')                   return false;

                if (responseType == 'order') {
                    debugMessage += 'in type order | ';
                    //order.Tax__c = (Decimal.valueOf(response.Tax)).setScale(2);
                    Decimal newTotal = (Decimal.valueOf(response.Total) + Decimal.valueOf(response.Tax)).setScale(2);
                    //order.discountAmount__c=(Decimal.valueOf(response.totalDiscount)).setScale(2);
                   if(newTotal==oldTotal) return true;
                     this.debugMessage += 'Total=' + newTotal + ' old total= '+oldTotal;

                } 
                
            } // for loop
            
        } catch (Exception e) {
            
            return false;
        }
        return false;
    }
    
    private Integer orderLineItemCounter(List<Product_Order_Item_gne__c> items){
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
    
    String debugCCard='';
    
/* Retrieve SAP account information for a given Account object. Determines if account is a sample account.
* true: account info is retrieved successfully
* false: failed to retrieve account info 
*/
    private Boolean getSAPAccountInfo(String billTo, String sapOrderId, Decimal newOrderTotal) {
        Integer counter=0;
        Decimal oldPaymentTotal=0.00;
        List<Product_Order_Payment_gne__c> oldPayments=[select Name, sapCardToken__c, Card_Holder_Name__c, Card_Type__c, Expiration_Date__c, Quantity__c, Total__c from Product_Order_Payment_gne__c where order__r.SAP_Order_ID__c =:sapOrderId];
        
        try {

            GneProductOrderGetAccountInfo.AccountInfoResponseItem[] responseItems = new GneProductOrderGetAccountInfo.AccountInfo().accountInfo(billTo, 'S');
            
            if (responseItems == null || responseItems.size() == 0)   return false;
            
            if(oldPayments==null || oldPayments.size()<=0) return false;
            Integer oIndex=0;   
            for (GneProductOrderGetAccountInfo.AccountInfoResponseItem response:responseItems) {
                String responseType = response.ResponseItemType;
                String status = response.Status;
                
                if (status == null || status.trim().length() == 0) {
                    status = 'true';
                }

                if (status != 'true') return false;

                if (responseType == 'creditcard') {
                    String name=getCCardName(response.cardNumber);
                    Date cardDate=viladeCard(response.expirationDate);
                    String ccholder='';
                    if(response.cardHolder!=null) ccholder=response.cardHolder.replace('%','-');
                    if(cardDate!=null && response.cardType!=null && response.cardType.length()>0 && ccholder.trim().length()>0 && name!=null && name.length()>0){
                        
                        for(Product_Order_Payment_gne__c o:oldPayments){
        
                            if(o!=null&&name==o.Name && ccholder==o.Card_Holder_Name__c && response.cardType==o.Card_Type__c && cardDate==o.Expiration_Date__c){
                                counter++;
                                 oldPaymentTotal+=o.Total__c;
                            }else {
                                debugCCard+=' ...SAP... '+String.valueOf(cardDate)+'/'+name+'/'+response.cardHolder+'/'+response.cardType;
                                debugCCard+=' ...Order... '+String.valueOf(o.Expiration_Date__c)+'/'+o.Name+'/'+o.Card_Holder_Name__c+'/'+o.Card_Type__c;
                            }       
                        }
                        oIndex++;
                    }
                        
                
                    
                }  
                               
            }  // for reponseItems loop
            
        } catch (Exception e) {
                                 
        }
        
        if(counter == oldPayments.size() && oldPaymentTotal==newOrderTotal) return true;
        debugCCard+='...MATCH counter...'+counter+'...oldPayments...'+oldPayments.size();
        return false;
    }
 
    private Date viladeCard(String dateString){
 
            Date today= Date.today();
           
                Date expiredDate;
                try{
                    if(dateString!=null && dateString.trim().length()>0)
                    expiredDate =  (Date.valueOf(dateString));
                    
                    if(today.daysBetween(expiredDate)>0) return expiredDate;
                   
                    
                }catch(TypeException e){
                    
                }                    
            
            
             return null; 
        
    }   

    private String getCCardName(String ccardStr) {
        
        if(ccardStr==null || ccardStr.trim().length()<=0) return null;
    // response message containing SAP credit card number
    // e.g. -PMOS-6037-00001000000025 Invalid Credit Card
    // group(1) = 6037
    // group(2) = 'Invalid Credit Card'
    
        Pattern ccPattern = Pattern.compile('\\-[A-Z]\\w{3}\\-(\\d{4})\\-\\w+ ?(.*)$');
    
    // group(1) = cc number
    // group(2) = trailing message
    // group(3) = last 4 digits of cc number
    
        Pattern numbersOnlyPattern = Pattern.compile('(\\d+(\\d{4})) ?(.*)$');
    
    // group(1) = last 4 digits
        Pattern numbersOnly = Pattern.compile('\\d+(\\d{4})$');
        Pattern x = Pattern.compile('-');
        
        Matcher nonEncryptedCC=numbersOnly.matcher(ccardStr);
 
        if (nonEncryptedCC.matches()) {
                    // accept unencrypted value only in UAT
             if(GNE_LWO_Logger.ENV=='UAT' || GNE_LWO_Logger.ENV=='DEV')
                        return nonEncryptedCC.group(1);
                     
         } 

         String[] ccNumber = x.split(ccardStr);
         return ccNumber[2];
                 
                 //if not match find   
               return null;     
       
    }
 
}