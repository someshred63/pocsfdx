//<<Documentnumber>> Condn:Join Case.CaseNumber to Shipment.Case_shipment_gne__c 
//                         and merge Shipment.Order_Number_gne__c


// For the above condition pls refer SCM_MF_DocandPurNum class.


//<<Purchasenumber>> Condn:Join Case.CaseNumber to Shipment.Case_Shipment_gne__c 
//                         and merge concatenated “PO-“ & Shipment.Name


// Merge Field For Purchase Number

public class SCM_MF_PurNum extends SCM_MergeField
  
{ 
    
	protected Shipment_gne__c ForCase;
	List<Shipment_gne__c> ForCaseList; 
	
	public SCM_MF_PurNum(String selectedCase)
    {
    	checked = false;
        displayCheck = false;
        displayTextBox = false; 
        displayLabel = true;
        key = 'PurchaseNumber'; 
        
        try
        {
        ForCaseList = [Select s.Name  From Shipment_gne__c s 
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