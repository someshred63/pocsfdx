// Created By: Paras Sharma

public class SCM_MF_GHStimTestDate extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_GHStimTestDate(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'GHStimTestDate';
        className = 'SCM_MF_GHStimTestDate';
    }
    
    public override String getFieldValue(){
    	if(medicalHistory != null && medicalHistory.Agent_1_Date_gne__c != null) {
			return medicalHistory.Agent_1_Date_gne__c.format(); 
		}
		else {
			return '';
		}

    }
}