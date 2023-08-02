public class GNE_SFA2_Pact_Redir_Ctrl {	
	Boolean showConnectionAlert;

    public PageReference redirect() {        
        
    	if(GNE_SFA2_Util.isUserConnectedToCorporateNetwork()){
	    	PageReference pr;
            if(GNE_SFA2_Util.isCrmFrmUser()) {
                pr = new PageReference(GNE_SFA2_Util.getPaceUrl()+'/lightning/n/PX_Patient');
            } else {
                pr = new PageReference(GNE_SFA2_Util.getPactUrl()+'/console');
            }
	    	pr.setRedirect(true);
	        return pr;
    	} else {
    		showConnectionAlert = true;
    		return null;
    	}    	
    }
}