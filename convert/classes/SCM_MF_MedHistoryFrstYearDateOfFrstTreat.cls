// Added By: Deepak Yadav
// Logic: Join Case.Medical_History_gne__c to Medical History.ID and 
//		  select Medical History. Date_of_First_Treatment_gne__c and 
//	  	  add 365 days
public class SCM_MF_MedHistoryFrstYearDateOfFrstTreat extends SCM_MF_MedicalHistoryCollection {
	
	public SCM_MF_MedHistoryFrstYearDateOfFrstTreat(String medicalHistoryID){
		super(medicalHistoryID);
		key = 'Frst Year Date Of Frst Treat';
		className = 'SCM_MF_MedHistoryFrstYearDateOfFrstTreat';
	}
	
	public override String getFieldValue() {
		string ReturnVal ;
		try {
		if(medicalHistory != null && medicalHistory.Date_of_First_Treatment_gne__c != null) {
			ReturnVal = medicalHistory.Date_of_First_Treatment_gne__c.addDays(365).format(); 
		}
		else {
			ReturnVal = '';
		}
		}catch (exception ex){
    		returnval = '';	
    	}
		return ReturnVal ;
		
	}


}