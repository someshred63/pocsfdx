public class SCM_MF_Recert_PAEffectDate extends SCM_MergeField {
	String physicianIdLocal;
	public SCM_MF_Recert_PAEffectDate(Prior_Authorization_gne__c PA)
    {   
    	
        this.key = 'Recert PAEffective';
        this.checked = false;
        this.displayCheck = false;
        this.displayLabel = false;
        this.displayTextbox = false;
        this.fieldValue = '';
                 
        try {
        	
   					fieldvalue = PA.PA_Effective_Date_gne__c.format();     		
        	
        }
        catch(Exception ex){
        fieldvalue = '';	
        }
    }
}