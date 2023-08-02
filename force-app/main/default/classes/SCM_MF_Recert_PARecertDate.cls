public class SCM_MF_Recert_PARecertDate extends SCM_MergeField {
	String physicianIdLocal;
	public SCM_MF_Recert_PARecertDate(Prior_Authorization_gne__c PA)
    {   
    	
        this.key = 'Recert PArecertdate';
        this.checked = false;
        this.displayCheck = false;
        this.displayLabel = false;
        this.displayTextbox = false;
        this.fieldValue = '';
                 
        try {
        	
   					fieldvalue = PA.Recertification_Date_gne__c.format();     		
        	
        }
        catch(Exception ex){
        fieldvalue = '';	
        }
    }
}