public without sharing class C_OPS_SPLOA_ADDSITES_CNTRL {
    
    
    public C_OPS_SPLOA_ADDSITES_CNTRL(){
        productslsts = [
            SELECT Name FROM C_Ops_SPLOA_Product__c
            WHERE C_Ops_SPLOA_Active__c =  True AND C_Ops_SPLOA_Effective_Date__c <= TODAY];
    }
    
    public String DEANumber { get; set; }
    public String requestNumber { get; set; }
    public String EmailAddress{get;set;}
    public String Product{get;set;}
    public String errorMessage{get;set;}
    private List<C_Ops_SPLOA_Request__c>  reqlist ;
    public Boolean showList{get;set;}
    private List<C_Ops_SPLOA_Product__c> productslsts = new List<C_Ops_SPLOA_Product__c>();
    public List<SelectOption> productslist{get;set;}
    public String SelectedProductName{get;set;}
    public String searchKey{get;set;}
    public Id reqId;
    
    public PageReference checkforRequest() {
        errorMessage  ='';
        //if(String.IsBlank(emailAddress)  || String.IsBlank(DEANumber) || String.IsBlank(Product)){
        if(String.IsBlank(requestNumber)  || String.IsBlank(DEANumber)){
            errorMessage ='Please fill in all the details';
            handleError(errorMessage);  
        }
        if(errorMessage == ''){
            //reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c ,Name  ,C_Ops_SPLOA_DEA_Number__c, Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c,Submission_Date__c   FROM C_Ops_SPLOA_Request__c WHERE C_Ops_SPLOA_Email__c =: emailAddress AND C_Ops_SPLOA_Product_Name__c =: Product  AND C_Ops_SPLOA_DEA_Number__c =:DEANumber ORDER BY Submission_Date__c DESC ] );
            reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c,Name ,C_Ops_SPLOA_DEA_Number__c,Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c,Submission_Date__c 
                                                         FROM C_Ops_SPLOA_Request__c WHERE Name = :requestNumber AND C_Ops_SPLOA_DEA_Number__c = :DEANumber ORDER BY Submission_Date__c DESC]);
            
            if(reqlist.size() == 0){    
                
                errorMessage ='No Matching Request Found. Please contact indirectaccess@gene.com or Select Request Product Access for product access';
                handleError(errorMessage);
            }
            else if(reqlist.size() >0 && reqlist[0].C_Ops_SPLOA_Request_Status__c =='Denied' ){
                
                errorMessage ='Your request has already been denied. Please contact indirectaccess@gene.com or Select Request Product Access for product access';
                handleError(errorMessage); 
                
            }
            else if(reqlist.size() >0 && reqlist[0].C_Ops_SPLOA_Request_Status__c =='Expired' ){
                
                errorMessage ='Your product access has expired. Please contact indirectaccess@gene.com or Select Request Product Access for product access';
                handleError(errorMessage); 
                
            }
            else if(reqlist.size() >0 ){
                //       else if(reqlist.size() >0 && reqlist[0].C_Ops_SPLOA_Request_Status__c == 'Denied' ){
                reqId = reqlist[0].Id; 
                PageReference conPage = Page.C_OPS_SPLOA_CONTACT_INFOPG;
                conPage.getParameters().put('corrid',reqId);
                conPage.getParameters().put('reqtyp','addSite');
                return conPage ; 
            }
        }
        return null;
    }
    
    public void findProducts(){
        showList = false;
        
        List<C_Ops_SPLOA_Product__c> prdNameOptions= new  List<C_Ops_SPLOA_Product__c>();
        
        if(!String.isBlank(Product)) Product=Product.trim();
        searchKey = Product;
        
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
                        Product = SelectedProductName ;
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
        if(Product == 'None'){
            Product = '';
            showList = false;
        }
    }
    
    public void verifyValidProduct(){
        if(String.isBlank(Product )){
            errorMessage = 'Product Name is missing';
            handleError(errorMessage);
            return;
        }
    }
    
    
    public PageReference cancelToHome() {
        PageReference nextPage;    
        nextPage=Page.C_OPS_SPLOA_Request_Home;   
        return nextPage;    
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
    
    
}