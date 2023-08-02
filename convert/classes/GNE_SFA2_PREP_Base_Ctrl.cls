public abstract class GNE_SFA2_PREP_Base_Ctrl {
	@TestVisible protected Boolean isDebugMode;
	@TestVisible protected List<String> errorMessages;
	@TestVisible protected List<String> infoMessages;
	
	public GNE_SFA2_PREP_Base_Ctrl() {
		errorMessages = new List<String>();
		infoMessages = new List<String>();
	}
	
	public static PageReference redirectToReturnUrl() {
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        
        if(String.isBlank(retUrl)) {
            retUrl = Page.GNE_SFA2_MyAccounts.getUrl();
        }

        Pagereference pageref = new pagereference(retUrl);
        pageref.setredirect(true);
        return pageref;
    }
    
    public static PageReference cancel() {
        return redirectToReturnUrl();
    }
	
	public static PageReference setErrorPageReference(Exception ex) {
        return setErrorPageReference(null,ex);
    }
    
    public static PageReference setErrorPageReference(String messagePrefix, Exception ex) {
    	return setErrorPageReference(messagePrefix, ex, ApexPages.currentPage());
    }
    
    public static PageReference setErrorPageReference(String messagePrefix, Exception ex, PageReference currentPageRef) {
    	PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
        pageref.setredirect(true);
        pageref.getParameters().put('exMessage', (messagePrefix!=null ? (messagePrefix + ': ') : '') + ex.getMessage());
        pageref.getParameters().put('exUrl', currentPageRef!=null ? currentPageRef.getUrl() : 'N/A');
        pageref.getParameters().put('developerMessage', ex.getStackTraceString());
        return pageref;
    }
	
	public abstract class ControllerData extends GNE_SFA2_Remoting_Base.RemoteActionResult {
	  	@TestVisible public transient GNE_SFA2_PREP_Base_Ctrl ctrl;
	  	@TestVisible protected transient DateTime startTimeStamp;
	  	@TestVisible public String debugInfoMessage;
	  	
	  	protected ControllerData() {
	  		super();
	  		startTimeStamp = System.now();
	  	}
	  	
	  	public virtual void onActionFinish( String actionName) {
	  		if(ctrl.isDebugMode == true) {
		  		Long execTimeMilis = startTimeStamp!= null ? (System.now().getTime()  - startTimeStamp.getTime()) : null;
		  		debugInfoMessage = String.format(
		  			'Action: {0}<br/>Exec Time : {1} ms | CPU Time:  {2}/{3} ms | Script Statements : {4}/{5}<br/>' + 
		  			'Query Statements:  {6}/{7} | Query Rows:  {8}/{9}<br/>' +
		  			'DML Statements:  {10}/{11} | DML Rows:  {12}/{13}', new String[]{
		  				actionName, execTimeMilis.format(),
		  				Limits.getCpuTime().format(), Limits.getLimitCpuTime().format(),
		  				Limits.getScriptStatements().format(), Limits.getLimitScriptStatements().format(),
		  				Limits.getQueries().format(), Limits.getLimitQueries().format(),
		  				Limits.getQueryRows().format(), Limits.getLimitQueryRows().format(),
		  				Limits.getDmlStatements().format(), Limits.getLimitDmlStatements().format(),
		  				Limits.getDmlRows().format(), Limits.getLimitDmlRows().format()
		  		});
	  		}
	  	}
	  	
	  	protected virtual void copyFrom(GNE_SFA2_PREP_Base_Ctrl a_ctrl) {
	  		errorMessages = a_ctrl.errorMessages;
  			infoMessages = a_ctrl.infoMessages;
	  	}
	  	
	  	protected virtual void copyTo(GNE_SFA2_PREP_Base_Ctrl a_ctrl) {
	  		
	  	}
	}
	
	public class InvalidInputValueException extends Exception {
        public List<String> errorMessages;
        public InvalidInputValueException(List<String> errorMsgs) {
            errorMessages = errorMsgs;
        }
    }
}