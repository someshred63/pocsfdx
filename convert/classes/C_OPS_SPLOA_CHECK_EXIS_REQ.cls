public with sharing class C_OPS_SPLOA_CHECK_EXIS_REQ{
    
    public String emailAddress {get;set;}
    public String searchKey{get;set;}
    public String requestNumber {get;set;}
    public String DEANumber {get;set;}
    public String productName{get;set;}
    public String errorMessage{get;set;}
    private List<C_Ops_SPLOA_Request__c>  reqlist ;
    public Id reqId{get;set;}
    // private Integer monthsBetween;
    public Integer monthsBetween{get;set;}
    Decimal numberofRenewalmonths;
    public String pageName;
    public Boolean showList{get;set;}
    private List<C_Ops_SPLOA_Product__c> productslsts = new List<C_Ops_SPLOA_Product__c>();
    public List<SelectOption> productslist{get;set;}
    public String SelectedProductName{get;set;}
    public DateTime renewaldate{get;set;}
    
    public C_OPS_SPLOA_CHECK_EXIS_REQ(){
        pageName = ApexPages.currentPage().getUrl();
        
        productslsts = [SELECT Name FROM C_Ops_SPLOA_Product__c
                        WHERE C_Ops_SPLOA_Active__c = True AND C_Ops_SPLOA_Effective_Date__c <= TODAY];
        
    }
    
    public PageReference cancelToHome(){
        PageReference nextPage;    
        nextPage=Page.C_OPS_IAP_Request_HomePage;  
        return nextPage;    
    }
    
    public PageReference checkforrenew(){
        C_Ops_Captcha_Property__c prop = [SELECT Id,Active__c,Months_to_Expired__c,Auto_Renewal_Send_Cadence__c FROM C_Ops_Captcha_Property__c WHERE Active__c = true LIMIT 1];
        errorMessage  ='';
        
        //if(String.IsBlank(emailAddress) || String.IsBlank(productName) || String.IsBlank(DEANumber)){
        if(String.IsBlank(requestNumber) || String.IsBlank(DEANumber)){
            errorMessage = 'Please fill in all the details';
            handleError(errorMessage);  
        }
        /* if(!(isValidDEA(DEANumber))) {
        errorMessage = 'DEA number format is incorrect';
        handleError(errorMessage);
        }*/
        if(errorMessage == ''){
            //reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c ,Name  ,C_Ops_SPLOA_DEA_Number__c, Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c  FROM C_Ops_SPLOA_Request__c WHERE C_Ops_SPLOA_Email__c =: emailAddress AND C_Ops_SPLOA_Product_Name__c=:productName AND C_Ops_SPLOA_DEA_Number__c =:DEANumber] );
            reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c,Name,C_Ops_SPLOA_DEA_Number__c,Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c 
                                                         FROM C_Ops_SPLOA_Request__c WHERE Name = :requestNumber AND C_Ops_SPLOA_DEA_Number__c = :DEANumber]);
            if(reqlist.size() == 0){
                /*PageReference conPage =Page.C_OPS_SPLOA_CONTACT_INFOPG; 
                conPage.getParameters().put('reqTyp','renew');                
                conPage.getParameters().put('prodName',productName);
                conPage.getParameters().put('email',emailAddress);
                conPage.getParameters().put('dea',DEANumber);
                return conPage;*/

                errorMessage ='No Matching Request Found. Please contact indirectaccess@gene.com or Select Request Product Access for product access';
                handleError(errorMessage);
            }
            else if(reqlist.size() > 0){
                if(reqlist[0].Processed_Date__c != null && reqlist[0].C_Ops_SPLOA_Request_Status__c != 'Expired'){
                    Integer numberofRenewalmonths = Integer.valueOf(prop.Auto_Renewal_Send_Cadence__c);
                    DateTime dT = reqlist[0].Processed_Date__c  ;
                    renewaldate = System.now().addMonths(-numberofRenewalmonths);
                }
                reqId = reqlist[0].Id;
                if(renewaldate >= reqlist[0].Processed_Date__c ){  
                    PageReference conPage =Page.C_OPS_SPLOA_CONTACT_INFOPG; 
                    conPage.getParameters().put('corrid',reqId);
                    conPage.getParameters().put('reqTyp','renew');
                    return conPage ; 
                }
                else if((renewaldate < reqlist[0].Processed_Date__c) || reqlist[0].C_Ops_SPLOA_Request_Status__c != 'Processed'){
                    errorMessage = 'You are not eligible to renew this Product Access request. Please contact indirectaccess@gene.com';
                    handleError(errorMessage);
                }                
            }
        }
        return null;
    }
      private without sharing class IAP_Controller_internal{
        Public list<C_Ops_SPLOA_Request__c> Getrequest(string requestNumber,string DEANumber){
            
            return [SELECT Id,C_Ops_SPLOA_Email__c,Name,C_Ops_SPLOA_DEA_Number__c,Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c,Request_Type__c 
                                                         FROM C_Ops_SPLOA_Request__c WHERE Name = :requestNumber AND C_Ops_SPLOA_DEA_Number__c = :DEANumber ];
        }
      }
    
    public PageReference checkdetails(){        
        errorMessage  ='';
        //if(String.IsBlank(emailAddress) || String.IsBlank(requestNumber) || String.IsBlank(DEANumber)){
        if(String.IsBlank(requestNumber) || String.IsBlank(DEANumber)){
            errorMessage ='Please fill in all the details';
            handleError(errorMessage);  
        }
        /*
        if(!(isValidDEA(DEANumber))) {
        errorMessage = 'DEA number format is incorrect';
        handleError(errorMessage);
        }
        */
        if(errorMessage == ''){
            //reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c ,Name ,C_Ops_SPLOA_DEA_Number__c, Processed_Date__c,C_Ops_SPLOA_Request_Status__c  FROM C_Ops_SPLOA_Request__c WHERE C_Ops_SPLOA_Email__c =: emailAddress AND Name =:requestNumber  AND C_Ops_SPLOA_DEA_Number__c =:DEANumber ] );
            reqlist  = new List<C_Ops_SPLOA_Request__c>();
            IAP_Controller_internal internalclass= new IAP_Controller_internal();
            reqlist=internalclass.Getrequest(requestNumber,DEANumber);
            if(reqlist.size() == 0){
                errorMessage ='No Access Request found with the entered details';
                handleError(errorMessage);  
            }
            else if(reqlist.size()>0){
                if(reqlist[0].C_Ops_SPLOA_Request_Status__c == 'Processed'){
                    errorMessage ='Your request has already been processed. Please contact indirectaccess@gene.com if you have any questions.';
                    handleError(errorMessage); 
                }
                else if(reqlist[0].C_Ops_SPLOA_Request_Status__c == 'Denied'){
                    errorMessage ='Your request has already been denied. Please contact indirectaccess@gene.com if you have any questions.';
                    handleError(errorMessage); 
                }        
                else if(reqlist[0].C_Ops_SPLOA_Request_Status__c == 'Expired'){
                    errorMessage ='Your product access has expired. Please contact indirectaccess@gene.com if you have any questions.';
                    handleError(errorMessage); 
                }
                else if(reqlist[0].C_Ops_SPLOA_Request_Status__c == 'New' || reqlist[0].C_Ops_SPLOA_Request_Status__c == 'On Hold'){
                    errorMessage ='This request was recently submitted and is pending review. Please contact indirectaccess@gene.com if you have any questions';
                    handleError(errorMessage); 
                }
                else if(reqlist[0].C_Ops_SPLOA_Request_Status__c == 'In Process' || reqlist[0].C_Ops_SPLOA_Request_Status__c == 'Revised by Customer' ){
                    reqId = reqlist[0].Id;
                    if(reqlist[0].Processed_Date__c != null){
                    }
                }
            }
            if(reqId != null){
              /*  PageReference conPage =Page.C_OPS_SPLOA_CONTACT_INFOPG;
                conPage.getParameters().put('corrid',reqId);
                conPage.getParameters().put('reqTyp','update');
                */
                 PageReference conPage = New PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
             //   PageReference conPage =Page.C_OPS_IAP_CONTACT_INFOPG;
                conPage.getParameters().put('corrid',reqId);
                 conPage.getParameters().put('reqTyp','update');
                conPage.getParameters().put('requestType',reqlist[0].Request_Type__c);
                    
                    return conPage ; 
            }
        }
        return null;
    }    
    
    public boolean isValidDEA(string z){        
        if(z.length() == 0 ){            
            return false;
        }
        
        Pattern zipCodeChecker = Pattern.compile('[a-zA-Z]{2}[0-9]{7}');
        Matcher zipMatcher = ZipCodeChecker.matcher(z);
        
        return (zipMatcher.matches());            
    }
    public void handleError(string errorText){
        if(String.isBlank(errorText)){
            return;
        }
        ApexPages.Message[] curMsgs=ApexPages.getMessages();
        boolean notFind=true;
        if(curMsgs!=null && curMsgs.size()>=1){
            for (ApexPages.Message msg:curMsgs){
                if(msg!=null && (!String.isBlank(msg.getSummary())) && msg.getSummary().trim().equalsIgnoreCase(errorText.trim())){
                    notFind=false;
                    break;
                }
            }
        }
        
        if(notFind) {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorText);
            ApexPages.addMessage(errorMsg);
        }
        
        return;
    }
    public void findProducts(){
        showList = false;
        
        List<C_Ops_SPLOA_Product__c> prdNameOptions= new  List<C_Ops_SPLOA_Product__c>();
        
        if(!String.isBlank(productName)) productName=productName.trim();
        searchKey = productName;
        
        if(searchKey!=null && searchKey.trim().length() >= 3 ){ 
            
            errorMessage ='';
            for(C_Ops_SPLOA_Product__c prod:productslsts ){
                String prodName = prod.Name; 
                if (prodName.startsWithIgnoreCase(searchKey)) {
                    prdNameOptions.add(prod);
                }                
            }
            
            if(prdNameOptions!= null ){
                if(prdNameOptions.size() == 0 && searchKey!='None'){
                    errorMessage = 'The Product you entered is not a Genentech Product, please confirm the product name on the prescription.';
                    handleError(errorMessage);
                }
                else{
                    if(prdNameOptions.size() == 1 ){
                        SelectedProductName =prdNameOptions[0].Name;
                        productName = SelectedProductName ;
                    }
                    else{
                        showList = true;
                        productslist = new List<SelectOption>();
                        for(C_Ops_SPLOA_Product__c prod : prdNameOptions){
                            productslist.add(new SelectOption(prod.Name,prod.Name));
                        }
                        productslist.add(new SelectOption('None','Enter Other Genentech Product'));
                    }  
                }
            }
            
        }
        UpdateselectedProduct();
    }
    
    public void UpdateselectedProduct(){
        if(productName  == 'None'){
            productName  = '';
            showList = false;
        }
    }
    
    public void verifyValidProduct(){
        if(String.isBlank(productName )){
            errorMessage = 'Product Name is missing';
            handleError(errorMessage);
            return;
        }
        
        boolean findit=false;
        productName =productName.trim();
        for(C_Ops_SPLOA_Product__c prod:productslsts ){
            String prodName = prod.Name; 
            if (productName.equalsIgnoreCase(prodName )) {
                findit=true;  
                break;
            }          
        }
        
        if(!findit) {
            errorMessage = 'The Product you entered is not a Genentech Product, please confirm the product name on the prescription';
            handleError(errorMessage);
        }        
    }
}