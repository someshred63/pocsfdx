// Added By: Prabha
// Logic: Join Case.Medical_History_gne__c to Medical History.ID and 
//		  If Medical History. GATCF_SMN_Expiration_Date_gne__c > system date + 42 days, then 
//				   else merge “Yes”
//	

public class SCM_MF_MedHistory_SMNFlag extends SCM_MF_MedicalHistoryCollection {
		public SCM_MF_MedHistory_SMNFlag(String medicalHistoryID){
		super(medicalHistoryID);
		key = 'SMN_Flag';
		className = 'SCM_MF_MedHistory_SMNFlag';
	}
	
	public override String getFieldValue() {
		string ReturnVal ;
		if(medicalHistory != null && medicalHistory.GATCF_SMN_Expiration_Date_gne__c != null ) {
			if (medicalHistory.GATCF_SMN_Expiration_Date_gne__c > Date.today().addDays(42)){
					ReturnVal = '';}
				else {ReturnVal = 'Yes'; 
				} 
		}
		else {
			ReturnVal = '';
		}
		
		return ReturnVal ;
		
	}

}