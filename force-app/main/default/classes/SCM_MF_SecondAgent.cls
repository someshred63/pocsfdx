// Added By: Deepak Yadav
// logic: Join Case.Medical_History_gne__c to
//		  Medical History.ID and select Medical History. Agent_2_gne__c. 
public class SCM_MF_SecondAgent extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_SecondAgent(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'secAgent';
        className = 'SCM_MF_SecondAgent';
    }
    
    public override String getFieldValue(){
    	if(medicalHistory != null && medicalHistory.Agent_2_gne__c != null) {
			return medicalHistory.Agent_2_gne__c; 
		}
		else {
			return '';
		}

    }
}