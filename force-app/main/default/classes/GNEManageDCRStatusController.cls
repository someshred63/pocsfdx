public class GNEManageDCRStatusController {
 
	public GNEManageDCRStatusController() {

	}
    
    public void process () {          
        try {        	
        	List<ApexPages.Message> msgList = ChangeRequestControllerHelper.moveToAMSQueue();
        	
        	for ( ApexPages.Message msg : msgList ) 
        	   ApexPages.addMessage ( msg );
        	   
        	   
        }catch (Exception ex) {
            ApexPages.addMessages ( ex);	
        }        	                
    }
}