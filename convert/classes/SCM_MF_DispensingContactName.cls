// Added By: Rajesh Sinha
/**
Join Case.CaseNumber to Fulfillment.Case_Fulfillment_gne__c and
select Fulfillment.In_network_name_gne__c AND 
Fulfillment.Out_network_name_gne__c 
-If Fulfillment.In_Network_Selected_Distributor_gne__c = Yes,
 merge Fulfillment.In_network_Contact_Name_gne__c
-If Fulfillment.Out_Network_Selected_Distributor_gne__c = Yes,
 merge Fulfillment.Out_network_Contact_Name_gne__c
*/

public class SCM_MF_DispensingContactName extends SCM_MF_FulFillmentCollection  {
	private string fulfillmentContactName = '';
	private string  fulfillmentIN ;
	private string fulfillmentOut;
	
	
	public SCM_MF_DispensingContactName(String caseId) {    
    	super(caseId);
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'DispensingContactName';
    	ClassName = 'SCM_MF_DispensingContactName';
    	fieldValue = GetDispensingContactName();    	
  	}
  	
  	private string GetDispensingContactName() {
  		if(fulfillmentRecord != null) {
  			fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
  			fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
  			fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
    		fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
	  			if(fulfillmentIN.equalsIgnoreCase('Yes')) {
					fulfillmentContactName = fulfillmentRecord.In_network_Contact_Name_gne__c;
				}
				else if(fulfillmentOut.equalsIgnoreCase('Yes')) {
					fulfillmentContactName = fulfillmentRecord.Out_network_Contact_Name_gne__c;	
				} 
				else if((fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('Yes')) ||
				 (fulfillmentIN.equalsIgnoreCase('No') && fulfillmentOut.equalsIgnoreCase('No'))) {
					 	if(fulfillmentRecord.In_network_Contact_Name_gne__c != null && fulfillmentRecord.In_network_Contact_Name_gne__c != ''){
			 				fulfillmentContactName = fulfillmentRecord.In_network_Contact_Name_gne__c;
			 			}
			 			else if(fulfillmentRecord.Out_network_Contact_Name_gne__c != null && fulfillmentRecord.Out_network_Contact_Name_gne__c != ''){
			 				fulfillmentContactName = fulfillmentRecord.Out_network_Contact_Name_gne__c;
			 			}
				 	
				 }
				 fulfillmentContactName = (fulfillmentContactName == null)?'':fulfillmentContactName ;
	             return fulfillmentContactName ; 
				 	
  		}
  		return fulfillmentContactName ; 
  			
  	}
  	public override String getFieldValue() { 
         	return fieldValue;    
  		}
  		
	

}