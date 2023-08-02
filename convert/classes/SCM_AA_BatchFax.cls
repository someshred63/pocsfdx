public class SCM_AA_BatchFax {

public string SelectedType {get;set;}
public string SelectedProduct {get;set;}
public string FromDate {get;set;}
public string ToDate {get;set;}
public string CaseStat {get;set;} 
public List<SelectOption> getBatchTypes()
{
  List<SelectOption> options = new List<SelectOption>();
      List<SCM_Batch_Fax_Types__c> batchTypes = [Select name,WS_Type__c from SCM_Batch_Fax_Types__c];  
          
   for( SCM_Batch_Fax_Types__c bt : batchTypes)
   {
      options.add(new SelectOption(bt.WS_Type__c, bt.Name));
   }       
   return options;
}
public List<SelectOption> getProd()
{
  List<SelectOption> options = new List<SelectOption>();
        
   Schema.DescribeFieldResult fieldResult =
 SCM_Batch_Fax_Types__c.Product__c.getDescribe();
   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
   for( Schema.PicklistEntry f : ple)
   {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
   }       
   return options;
}
public String BatchTypesList{get
{
 string opt = '';
      List<SCM_Batch_Fax_Types__c> batchTypes = [Select name,WS_Type__c,Product__c from SCM_Batch_Fax_Types__c];  
          
   for( SCM_Batch_Fax_Types__c bt : batchTypes)
   {
      opt += ';' + bt.Product__c + ',' + bt.name + ',' + bt.WS_Type__c;
   } 
   opt = opt.replaceFirst(';', '');      
   return opt;
}
set{BatchTypesList = value;}}

public String BatchLevel{get
{
    
return ApexPages.currentPage().getParameters().get('type');
 
}
set{BatchLevel = value;}}


public pageReference CreateNew() {
    
    SCM_FaxSender_WebService.FaxSenderSoap fsws = new SCM_FaxSender_WebService.FaxSenderSoap();
    SCM_Batch_Fax_Types__c batchType = [Select name,WS_Type__c,Workflow_Name__c from SCM_Batch_Fax_Types__c  where Product__c = :SelectedProduct and WS_Type__c = :SelectedType limit 1 ]; 
    string typ = ApexPages.currentPage().getParameters().get('type');
    if (batchType.Workflow_Name__c != '' && batchType.Workflow_Name__c != null){
        SCM_WebserviceV12.SpringCMServiceSoap scm12 = new SCM_WebserviceV12.SpringCMServiceSoap ();
        scm12.timeout_x = 60000;
       


        
        string xml = '<Params><params><AddressId>' + ApexPages.currentPage().getParameters().get('id') + '</AddressId><Product>' + SelectedProduct + '</Product><FromDate>' + FromDate + '</FromDate><ToDate>' + ToDate + '</ToDate><AddressType>' + typ + '</AddressType><CaseStatus>' + CaseStat + '</CaseStatus><Sender>' + userinfo.getUserId() +  '</Sender></params></Params>';
        string batchid = scm12.BPMInitiateWorkflow(SCM_Security.SCM_AuthenticateNonDefault(),batchType.Workflow_Name__c,xml);
        return new PageReference('/apex/SCM_BatchFaxpoll?jobKey=' + batchid);
    }
    
    fsws.timeout_x = 60000;
    SCM_FaxSender_WebService.BatchStatus bs = fsws.CreateNewBatchFax(SelectedType,typ,ApexPages.currentPage().getParameters().get('id'),userinfo.getOrganizationId(),SCM_security.getEnvironmentVariable('SCM_ServerInstanceURL'),userinfo.getSessionId(),userinfo.getUserId(),SelectedProduct,ApexPages.currentPage().getParameters().get('accountid'),CaseStat,FromDate,ToDate);
    SCM_WSLogger.InsertLog(fsws.log.MethodName__c,fsws.log.Parameters__c);
    string message;
    if (bs.errormessage != null)
    {
        message = bs.ErrorMessage.replace('<br>','$$returnLine$$');
    }
    return new PageReference('/apex/SCM_AA_Batch_Status?status=' + bs.Status + '&Message=' + message);
}

}