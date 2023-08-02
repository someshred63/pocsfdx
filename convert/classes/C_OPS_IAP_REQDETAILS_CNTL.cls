public without sharing class C_OPS_IAP_REQDETAILS_CNTL {
    public Id mainRequestId;
    public C_Ops_SPLOA_Request__c Request { get; set;}
    public String reqstatus{get;set;}
    
    public C_OPS_IAP_REQDETAILS_CNTL(){
   mainRequestId = ApexPages.currentPage().getParameters().get('reqid');
   
   List<C_Ops_SPLOA_Request__c> req  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,Name,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c,Related_Product_s__c FROM C_Ops_SPLOA_Request__c WHERE Id=: mainRequestId ]);
                    If(req!=null && req.size() >0){
                    Request =req[0];
                   if(req[0].C_Ops_SPLOA_Request_Status__c == 'New' ){reqstatus = 'In Progress';}
                   else { reqstatus = req[0].C_Ops_SPLOA_Request_Status__c;}
                    }                                     
   }
}