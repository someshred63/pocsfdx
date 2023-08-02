//Created By: shobha Rawat


//Join Case.CaseNumber to Fulfillment.Case_Fulfillment_gne__c  and select Fulfillment.In_network_name_gne__c AND Fulfillment.Out_network_name_gne__c 
 //  -If Fulfillment.In_Network_Selected_Distributor_gne__c = Yes, merge Fulfillment.In_network_Phone_Number_gne__c
 //  -If Fulfillment.Out_Network_Selected_Distributor_gne__c = Yes,  merge Fulfillment.Out_network_Phone_Number_gne__c
 //  -If both = No OR Yes, then select the last modified


 
public class SCM_MF_FulFillmentPhone extends SCM_MF_FulFillmentCollection {
	private string fulfillmentFax = '';
	private string  fulfillmentIN ;
	private string fulfillmentOut;
	private Boolean getLastMod = false;
	
	public SCM_MF_FulFillmentPhone(String caseId) {
        super(caseId);
        checked = false;
        displayCheck = false;
        displayTextBox = false; 
        displayLabel = false;
        key='FulFillment Phone';
        className = 'SCM_MF_FulFillmentPhone';
    }
    
    public SCM_MF_FulFillmentPhone(String caseId, Boolean getLastModified) {
        super(caseId);
        checked = false;
        displayCheck = false;
        displayTextBox = false; 
        displayLabel = false;
        key='FulFillment Phone';
        className = 'SCM_MF_FulFillmentPhone';
        getLastMod = getLastModified;
    }

    public override String getFieldValue() {
    	if(fulfillmentRecord != null) {
    		fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
			fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
    		fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
    		fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
    	
			if(fulfillmentIN.equalsIgnoreCase('Yes')) {
				fulfillmentFax = fulfillmentRecord.In_network_Phone_Number_gne__c;
			}
			else if(fulfillmentOut.equalsIgnoreCase('Yes')) {
				fulfillmentFax = fulfillmentRecord.Out_network_Phone_Number_gne__c;	
			} 
			else if((fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('Yes')) ||
				 (fulfillmentIN.equalsIgnoreCase('No') && fulfillmentOut.equalsIgnoreCase('No'))) {
		 		if(getLastMod == true){
		 			if(fulfillmentRecord.In_network_Phone_Number_gne__c != null && fulfillmentRecord.In_network_Phone_Number_gne__c != ''){
		 				fulfillmentFax = fulfillmentRecord.In_network_Phone_Number_gne__c;
		 			}
		 			else if(fulfillmentRecord.Out_network_Phone_Number_gne__c != null && fulfillmentRecord.Out_network_Phone_Number_gne__c != ''){
		 				fulfillmentFax = fulfillmentRecord.Out_network_Phone_Number_gne__c;
		 			}
		 		}
			}
    	}	
		
	    fulfillmentFax = (fulfillmentFax == null)?'':fulfillmentFax ;
	    
	    return fulfillmentFax ; 
  
    }
}