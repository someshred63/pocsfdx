public class SCM_CopyToCase_poll {
public boolean istest = false;
public string complete {
      get {
      		string jobkey = ApexPages.currentPage().getParameters().get('Jobkey');
      	if (jobkey != null || istest == true) {
      		SCM_FaxSender_WebService.FaxSenderSoap fsws = new SCM_FaxSender_WebService.FaxSenderSoap();
      		SCM_FaxSender_WebService.WebServiceJobStatus wj = new SCM_FaxSender_WebService.WebServiceJobStatus();
      		if (istest == false) {
      		wj = fsws.CheckWebserviceJob(jobkey);
      		}
      		if (wj.status == 'Failed') {
      			return wj.Error + ';' + wj.NewDocid;
      		}
      		else {
      			return wj.status + ';' + wj.NewDocid;
      		}
      	
      	}
      	
      	return 'jobkey null'; 
      
      
      }
      set { complete = value; }
   } 
   
   public string folid {
      get {
      		
      	
      	return apexpages.currentpage().getParameters().get('folid'); 
      
      
      }
      set { folid  = value; }
   } 
    public string redir {
      get {
      		
      	
      	return apexpages.currentpage().getParameters().get('redir'); 
      
      
      }
      set { redir  = value; }
   } 
      public string isUpload {
      get {
      		
      	
      	return apexpages.currentpage().getParameters().get('isupload'); 
      	
      
      }
      set { isUpload  = value; }
   } 
   public string issave {
      get {
      		
      	
      	return apexpages.currentpage().getParameters().get('issave'); 
      
      
      }
      set { issave  = value; }
   } 
}