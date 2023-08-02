//<<Purchasenumber>> Condn:Join Case.CaseNumber to Shipment.Case_Shipment_gne__c 
//                         and merge concatenated “PO-“ & Shipment.Name
//<<Documentnumber>> Condn:Join Case.CaseNumber to Shipment.Case_shipment_gne__c 
//                         and merge Shipment.Order_Number_gne__c

// Merge Field For Document Number

public class SCM_MF_DocandPurNum extends SCM_MergeField
  
{ 
    
	protected Shipment_gne__c ForCase;
	List<Shipment_gne__c> ForCaseList; 
	
	public SCM_MF_DocandPurNum(String selectedCase)
    {
    	checked = false;
        displayCheck = false;
        displayTextBox = false; 
        displayLabel = true;
        key = 'OrdNumber'; 
        
        try
        {
        	
        ForCaseList = [Select s.Order_Number_gne__c From Shipment_gne__c s 
  	                          where s.Case_Shipment_gne__r.CaseNumber = : selectedCase LIMIT 1];
    
        }
        catch(Exception ex)
        {
        	ForCaseList = null;
        }
    }
    
    public override String getFieldValue()
          {
    	   if(ForCaseList.size() >= 1)
    	       {
        	     ForCase = ForCaseList[0];
        	     	if(ForCase.Order_Number_gne__c != null)
        	    	{
        	     	return ForCase.Order_Number_gne__c;
        	    	}
        	        else{return '';}                        
                }
            
             else
                {        	
        	     return '';       
                }
           }
}