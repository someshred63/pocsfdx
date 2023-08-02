global class GNE_SFA2_Remoting_Base {
	
	public static String getErrorPageUrl(String messagePrefix, Exception ex){
		return getErrorPageUrl(messagePrefix, ex, null);
	}
	
	public static String getErrorPageUrl(String messagePrefix, Exception ex, PageReference currentPageRef){
		PageReference pageref = Page.GNE_SFA2_Exception_Layout;
        pageref.setredirect(true);
        pageref.getParameters().put('exMessage', (messagePrefix != null ? (messagePrefix + ': ') : '') + ex.getMessage());
        pageref.getParameters().put('exUrl', currentPageRef != null ? currentPageRef.getUrl() : 'N/A');
        pageref.getParameters().put('developerMessage', ex.getStackTraceString());
        return pageref.getUrl();        
	}
	
	global virtual class RemoteActionResult {
	  	public List<String> errorMessages { get; set; }
	  	public List<String> infoMessages { get; set; }
	  	public String retURL { get; set; }
	  	
	  	public RemoteActionResult() {
	  		this.errorMessages = new List<String>();
	  		this.infoMessages = new List<String>();
	  	}
	  	
	  	public void setRedirectToErrorPage(String messagePrefix, Exception ex) {
	  		this.retUrl = GNE_SFA2_Remoting_Base.getErrorPageUrl(messagePrefix, ex, null);    		
    	}
	  	
	  	public void setRedirectToErrorPage(String messagePrefix, Exception ex, PageReference currentPageRef){
	  		this.retUrl = GNE_SFA2_Remoting_Base.getErrorPageUrl(messagePrefix, ex, currentPageRef);	  		
	  	}
	}
}