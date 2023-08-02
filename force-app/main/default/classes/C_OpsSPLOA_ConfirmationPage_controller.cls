public without sharing class C_OpsSPLOA_ConfirmationPage_controller {
private ID requestId;
public boolean approveStatus{get;set;}
public boolean denielStatus{get;set;}
public boolean updateRequest{get;set;}
public boolean renewRequest{get;set;}
public boolean addSiteRequest{get;set;}
public String updateexistingrecord{get;set;}
public String requestRefNum {set; get;}
public String requestRefProd {set; get;}
public C_Ops_SPLOA_Request__c request {set; get;}
    public C_OpsSPLOA_ConfirmationPage_controller(ApexPages.StandardController controller) {
    approveStatus=false;
    denielStatus=false;
PageReference curPage=ApexPages.currentPage();   
    if(curPage.getParameters()!=null) {
               requestId=curPage.getParameters().get('id');
               updateexistingrecord = curPage.getParameters().get('reqtyp');
           }  
           else requestId=controller.getRecord().id; 
           request=[select id,Name,Request_Type__c,C_Ops_SPLOA_Product_Name__c,C_Ops_SPLOA_Request_Status__c from C_Ops_SPLOA_Request__c where id=:requestId limit 1];

           if(request!=null) {
           requestRefNum = request.Name;
           requestRefProd = request.C_Ops_SPLOA_Product_Name__c;
           }
           if(updateexistingrecord  != null && updateexistingrecord == 'renew'){
           renewRequest= true;
           }
           else if(updateexistingrecord  != null && updateexistingrecord == 'update'){
           updateRequest= true;
           }
           else if(updateexistingrecord  != null && updateexistingrecord == 'addSite'){
            addSiteRequest=true;
           }
           else if(request.C_Ops_SPLOA_Request_Status__c=='New'){
           approveStatus=true;                         
           }
           else if(request.C_Ops_SPLOA_Request_Status__c=='Denied') {
           denielStatus=true;                        
           }
 
    }
    
    public PageReference redirectoHome(){
     PageReference homePage=Page.C_OPS_SPLOA_Request_Home;
         return homePage; 
    }
    
    public PageReference redirectoconpage() {                
      PageReference nextPage=Page.C_OPS_SPLOA_CONTACT_INFOPG;
         nextPage.getParameters().put('id',request.id);
         nextPage.getParameters().put('requestType',request.Request_Type__c);
         return nextPage; 
    }
    public PageReference viewRequestPDFPage() {
     
         PageReference nextPage=Page.C_OpsSPLOA_SubmittedRequest_PDF;
         nextPage.getParameters().put('id',request.id);
         nextPage.getParameters().put('requestType',request.Request_Type__c);
         return nextPage;
    }

}