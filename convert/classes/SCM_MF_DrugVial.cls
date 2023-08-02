//condition is as  follows
//Join Case.Medical_History_gne__c to Medical History.ID and select Medical History. Drug_gne__c.
public class SCM_MF_DrugVial extends SCM_MergeField
{
	 public SCM_MF_DrugVial(String medHis)
	 {
	  checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='DrugVial';
      className='SCM_MF_DrugVial';
      fieldValue = obtainDrugVial(medHis); 
	 } 
	 
	 public String obtainDrugVial(String medHis)
  	 {
  	 	
  	 try {
  	   String returnString='';
  	   List<Case> cseDrug=[Select c.Medical_History_gne__r.Drug_gne__c, c.Medical_History_gne__c From Case c
  	   						where c.Medical_History_gne__c=:medHis LIMIT 1];
  	   if(cseDrug.Size()==1)
  	   {
  	    returnString=(cseDrug[0].Medical_History_gne__r.Drug_gne__c==null)?'':cseDrug[0].Medical_History_gne__r.Drug_gne__c;
  	   }
  	   
  	   if(returnString==null)
  	   {
  	    returnString='';
  	   }
  	   return returnString;
  	      	} 
   	catch (Exception ex){
   	return '';
   		}
  	 }
  	
  	
  	 public override String getFieldvalue()
   	{
    return fieldValue;

   	}    
}