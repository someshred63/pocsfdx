//Created By: shobha Rawat

//Join Case.CaseNumber to Fulfillment.Case_Fulfillment_gne__c  and 
//select Fulfillment.In_network_name_gne__c AND Fulfillment.Out_network_name_gne__c 
//-If Fulfillment.In_Network_Selected_Distributor_gne__c = Yes, 
 //merge Fulfillment.In_network_Fax_Number_gne__c
//-If Fulfillment.Out_Network_Selected_Distributor_gne__c = Yes,  
 //merge Fulfillment.Out_network_Fax_Number_gne__c
 //-If both = No OR Yes, then merge “”

 
public class SCM_MF_FulFillmentFaxNumber extends SCM_MF_FulFillmentCollection {
	private string fulfillmentFax = '';
	private string  fulfillmentIN ;
	private string fulfillmentOut;
	private Boolean getLastMod = false;
	
	public SCM_MF_FulFillmentFaxNumber(String caseId) {
        super(caseId);
        checked = false;
        displayCheck = false;
        displayTextBox = true; 
        displayLabel = true;
        key='RECFAX_Fax';
        Label= 'Fax Number:'; 
        className = 'SCM_MF_FulFillmentFaxNumber';
    }
    
    public SCM_MF_FulFillmentFaxNumber(String caseId, Boolean getLastModified) {
        super(caseId);
        checked = false;
        displayCheck = false;
        displayTextBox = true; 
        displayLabel = true;
        key='RECFAX_Fax';
        className = 'SCM_MF_FulFillmentFaxNumber';
        Label='Fax Number:'; 
        getLastMod = getLastModified;
    }

    public override String getFieldValue() {
    	if(fulfillmentRecord != null) {
    		fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
			fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
    		fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
    		fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
    	
			if(fulfillmentIN.equalsIgnoreCase('Yes')) {
				fulfillmentFax = fulfillmentRecord.In_network_Fax_Number_gne__c;
			}
			else if(fulfillmentOut.equalsIgnoreCase('Yes')) {
				fulfillmentFax = fulfillmentRecord.Out_network_Fax_Number_gne__c;	
			} 
			else if((fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('Yes')) ||
				 (fulfillmentIN.equalsIgnoreCase('No') && fulfillmentOut.equalsIgnoreCase('No'))) {
		 		if(getLastMod == true){
		 			if(fulfillmentRecord.In_network_Fax_Number_gne__c != null && fulfillmentRecord.In_network_Fax_Number_gne__c != ''){
		 				fulfillmentFax = fulfillmentRecord.In_network_Fax_Number_gne__c;
		 			}
		 			else if(fulfillmentRecord.Out_network_Fax_Number_gne__c != null && fulfillmentRecord.Out_network_Fax_Number_gne__c != ''){
		 				fulfillmentFax = fulfillmentRecord.Out_network_Fax_Number_gne__c;
		 			}
		 		}
			}
    	}	
		
	    fulfillmentFax = (fulfillmentFax == null)?'':fulfillmentFax ;
	    
	    return fulfillmentFax ; 
  
    }
}