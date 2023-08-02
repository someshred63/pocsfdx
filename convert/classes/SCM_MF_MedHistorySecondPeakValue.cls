// Added By: Deepak Yadav
// logic: Join Case.Medical_History_gne__c to Medical History.ID 
//		  and select Medical History. Agent2_Peak_Response_gne__c. 
public class SCM_MF_MedHistorySecondPeakValue extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_MedHistorySecondPeakValue(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'secPeakValue';
        className = 'SCM_MF_MedHistorySecondPeakValue';
    }
    
    public override String getFieldValue(){
    	if(medicalHistory != null && medicalHistory.Agent_2_Peak_Response_gne__c != null) {
			return medicalHistory.Agent_2_Peak_Response_gne__c; 
		}
		else {
			return '';
		}

    }
}