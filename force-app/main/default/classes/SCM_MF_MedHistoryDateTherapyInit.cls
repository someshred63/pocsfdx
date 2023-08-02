// Added By: Deepak Yadav
// logic: Join Case.Medical_History_gne__c to Medical History.ID and 
//		 select Medical History. Date_Therapy_Initiated_gne__c.
public class SCM_MF_MedHistoryDateTherapyInit extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_MedHistoryDateTherapyInit(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'DateTherapyInit';
        className = 'SCM_MF_MedHistoryDateTherapyInit';
    }
    
    public override String getFieldValue(){
    	if(medicalHistory != null && medicalHistory.Date_Therapy_Initiated_gne__c != null) {
			return medicalHistory.Date_Therapy_Initiated_gne__c.format(); 
		}
		else {
			return '';
		}

    }
}