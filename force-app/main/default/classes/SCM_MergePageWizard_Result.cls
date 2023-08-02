public class SCM_MergePageWizard_Result {

    
    public String jobKey {get;set;}
    public SCM_FaxSender_WebService.MergeJobStatus jobStatus {get;set;}
    
    public void createJobStatus()
    {
        try
        {
            SCM_FaxSender_WebService.FaxSenderSoap sender = new SCM_FaxSender_WebService.FaxSenderSoap(); 
            jobStatus = sender.CheckMailMergeJob(jobKey);
        }
        catch(Exception exp)
        {
            jobStatus= null;
        }
    }
    public void setStatus(String status)
    {
        if(status=='Success')
            mailMergeStatus=  'Document created successfully!';
        else if(status=='Failed')
        {
            mailMergeStatus=  'Document creation failed! \nJob Key : ' + jobKey;
            if(jobStatus!=null)
              mailMergeStatus = ' \nError Message : ' + jobStatus.Error;
            SCM_LogError.sendEmail('Merger Webservice Error!',mailMergeStatus,true);    
        }
        else
            mailMergeStatus=  'Invalid Status!';
    }
    
     public PageReference initialize()
     {
         if(ApexPages.currentPage().getParameters().get('key')!=null)
         {
            jobKey = ApexPages.currentPage().getParameters().get('key');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
            //                   'JobKey=' + jobKey));
            
            createJobStatus();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
            //                   'jobStatus=' + jobStatus.status));
            if(jobStatus!=null)
                setStatus(jobStatus.status);
         }
         else if(ApexPages.currentPage().getParameters().get('key')==null && 
                 ApexPages.currentPage().getParameters().get('wizard_error')!=null)
            mailMergeStatus=  'The document could not be created due to an error in the system!';
         else
            mailMergeStatus= 'Key parameter not found!';
         
         return null;
    }
    
    
    private String mailMergeStatus;
    public String getmailMergeStatus()
    {
        return mailMergeStatus;
    }
}