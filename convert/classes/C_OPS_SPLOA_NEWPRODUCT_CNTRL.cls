public without sharing class C_OPS_SPLOA_NEWPRODUCT_CNTRL {
    
    public String emailAddress {get;set;}
    public String requestNumber {get;set;}
    public String DEANumber {get;set;}
    public String errorMessage{get;set;}
    private List<C_Ops_SPLOA_Request__c>  reqlist ;
    public List<String> prodlist ;
    Public Set<String> productlist;
    public Id reqId;
    
    public PageReference cancelToHome(){
        PageReference nextPage;    
        nextPage=Page.C_OPS_SPLOA_Request_Home;
        system.debug('Entering****'+nextPage);    
        return nextPage;    
    }
    public PageReference checkforRequest() {
        errorMessage  ='';
        //if(String.IsBlank(emailAddress)  || String.IsBlank(DEANumber)){
        if(String.IsBlank(requestNumber)  || String.IsBlank(DEANumber)){
            errorMessage ='Please fill in all the details';
            handleError(errorMessage);  
        }
        if(errorMessage == ''){
            //reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c ,Name  ,C_Ops_SPLOA_DEA_Number__c, Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c,Submission_Date__c ,Submission_Date_Time__c  FROM C_Ops_SPLOA_Request__c WHERE C_Ops_SPLOA_Email__c =: emailAddress  AND C_Ops_SPLOA_DEA_Number__c =:DEANumber ORDER BY Submission_Date_Time__c DESC ] );
            reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c,Name ,C_Ops_SPLOA_DEA_Number__c,Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c,Submission_Date__c ,Submission_Date_Time__c 
                                                         FROM C_Ops_SPLOA_Request__c WHERE Name = :requestNumber AND C_Ops_SPLOA_DEA_Number__c = :DEANumber ORDER BY Submission_Date_Time__c DESC]);
            if(reqlist.size() == 0){
                PageReference conPage =Page.C_OPS_SPLOA_CONTACT_INFOPG;
                conPage.getParameters().put('reqtyp','addProd');
                conPage.getParameters().put('email',emailAddress);
                conPage.getParameters().put('dea',DEANumber);
                return conPage ; 
            }
            if(reqlist.size() > 0){
                productlist = new Set<String>();
                reqId = reqlist[0].Id; 
                PageReference conPage =Page.C_OPS_SPLOA_CONTACT_INFOPG; 
                conPage.getParameters().put('reqtyp','addProd');
                conPage.getParameters().put('corrid',reqId);
                return conPage ; 
            }
        }
        return null;
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