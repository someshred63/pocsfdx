//Created By:Shobha Rawat


//Join Case.CaseNumber to Fulfillment.Case_Fulfillment_gne__c  and 
//select Fulfillment.In_network_name_gne__c AND Fulfillment.Out_network_name_gne__c 
  // -If Fulfillment.In_Network_Selected_Distributor_gne__c = Yes, 
  //merge Fulfillment.In_network_Contact_Name_gne__c
  //-If Fulfillment.Out_Network_Selected_Distributor_gne__c = Yes,  
  //merge Fulfillment.Out_network_Contact_Name_gne__c
  //-If both = No OR Yes, then merge “”


public class SCM_MF_Attn extends SCM_MF_FulFillmentCollection {
      private string fulfillmentName = '';
      private string  fulfillmentIN ;
      private string fulfillmentOut;
      private Boolean getLastMod = false;
      
      public SCM_MF_Attn(String caseId) {
        super(caseId);
        checked = false; 
        displayCheck = false;
        displayTextBox = true;
        displayLabel = true;
        key='FulFillment Attn';
        className = 'SCM_MF_Attn';
        Label='Attn:';          
      }
      public SCM_MF_Attn(String caseId, Boolean getLastModified) {
      	super(caseId);
        checked = false; 
        displayCheck = false;
        displayTextBox = true;
        displayLabel = true;
        key='FulFillment Attn';
        className = 'SCM_MF_Attn';
        getLastMod = getLastModified;
        Label='Attn:' ;
      }
    

    public override String getFieldValue() 
    {
        if(fulfillmentRecord != null)
        {
            fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
            fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
            fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
            fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
             
            if(fulfillmentIN.equalsIgnoreCase('Yes')) 
            {
                fulfillmentName = fulfillmentRecord.In_network_Contact_Name_gne__c ;
            }
            else if(fulfillmentOut.equalsIgnoreCase('Yes')) 
            {
                fulfillmentName = fulfillmentRecord.Out_network_Contact_Name_gne__c;    
            } 
            else if((fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('Yes')) ||
                 (fulfillmentIN.equalsIgnoreCase('No') && fulfillmentOut.equalsIgnoreCase('No'))) 
            {
                if(getLastMod == true)
                {
                	if(fulfillmentRecord.In_network_Contact_Name_gne__c != null && fulfillmentRecord.In_network_Contact_Name_gne__c != '')
                	{
                		fulfillmentName = fulfillmentRecord.In_network_Contact_Name_gne__c ;
                	}
                	else if(fulfillmentRecord.Out_network_Contact_Name_gne__c != null && fulfillmentRecord.Out_network_Contact_Name_gne__c != '')
                	{
                		fulfillmentName = fulfillmentRecord.Out_network_Contact_Name_gne__c;
                	}
                }
            }
        }
        
        fulfillmentName = (fulfillmentName == null)?'':fulfillmentName ;
        
        return fulfillmentName ;    
           
    }

    
}