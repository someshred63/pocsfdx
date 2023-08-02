//Join Case.CaseNumber to Fulfillment.Case_Fulfillment_gne__c  and 
//select Fulfillment.In_network_name_gne__c AND Fulfillment.Out_network_name_gne__c 
//   -If Fulfillment.In_Network_Selected_Distributor_gne__c = Yes, 
//    Join Fulfillment.In_network_name_gne__c to Account.ID 
//    and merge Account.Name
//   -If Fulfillment.Out_Network_Selected_Distributor_gne__c = Yes,  
//    Join Fulfillment.Out_network_name_gne__c to Account.ID 
//    and merge Account.Name
//   -If both = No OR Yes, then merge “”

  
//Developer Name:Shobha

public class SCM_MF_FulFillmentAddressTo extends SCM_MF_FulFillmentCollection {
	private string fulfillmentName = '';
	private string  fulfillmentIN ;
	private string fulfillmentOut;
	private Boolean getLastMod = false;
	
	public SCM_MF_FulFillmentAddressTo(String caseId) {
        super(caseId);
        checked = false;
        displayCheck = false;
        displayTextBox =true ;
        displayLabel = true;
        Key='FulFillment name';
        className = 'SCM_MF_FulFillmentAddressTo';  
        Label='Addressed To:';  
    }
    
    public SCM_MF_FulFillmentAddressTo(String caseId, Boolean getLastModified) {
        super(caseId);
        checked = false;
        displayCheck = false;
        displayTextBox =true ;
        displayLabel = true;
        Key='FulFillment name';
        className = 'SCM_MF_FulFillmentAddressTo';
        Label='Addressed To:'; 
        getLastMod = getLastModified;    
    }
    
    public override String getFieldValue() { 
    	if(fulfillmentRecord != null) {
    		fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
			fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
    		fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
    		fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
    	    	    		 
			if(fulfillmentIN.equalsIgnoreCase('Yes')) {
				fulfillmentName = fulfillmentRecord.In_network_name_gne__r.Name;
			}
			else if(fulfillmentOut.equalsIgnoreCase('Yes')) {
				fulfillmentName = fulfillmentRecord.Out_network_Name_gne__r.Name;	
			} 
			else if((fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('Yes')) ||
				 (fulfillmentIN.equalsIgnoreCase('No') && fulfillmentOut.equalsIgnoreCase('No'))) {
		 		if(getLastMod == true){
		 			if(fulfillmentRecord.In_network_name_gne__r.Name != null && fulfillmentRecord.In_network_name_gne__r.Name != ''){
		 				fulfillmentName = fulfillmentRecord.In_network_name_gne__r.Name;
		 			}
		 			else if(fulfillmentRecord.Out_network_Name_gne__r.Name != null && fulfillmentRecord.Out_network_Name_gne__r.Name != ''){
		 				fulfillmentName = fulfillmentRecord.Out_network_Name_gne__r.Name;
		 			}
		 		}
			}
    	}	
		
	    fulfillmentName = (fulfillmentName == null)?'':fulfillmentName ;
	    
	    return fulfillmentName ;           
    }
}