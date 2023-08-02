// Created By: Paras Sharma

public class SCM_MF_MedHistory_PeakValue extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_MedHistory_PeakValue(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'PeakValue';
        className = 'SCM_MF_MedHistory_PeakValue';
    }
    
    public override String getFieldValue(){
    	if(medicalHistory != null && medicalHistory.Agent1_Peak_Response_gne__c != null) {
			return medicalHistory.Agent1_Peak_Response_gne__c; 
		}
		else {
			return '';
		}

    }
}