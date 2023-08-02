// Created By: Paras Sharma

public class SCM_MF_MedHistory_Agent extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_MedHistory_Agent(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'Agent';
        className = 'SCM_MF_MedHistory_Agent';
    }
    
    public override String getFieldValue(){
    	if(medicalHistory != null && medicalHistory.Agent_1_gne__c != null) {
			return medicalHistory.Agent_1_gne__c; 
		}
		else {
			return '';
		}

    }
}