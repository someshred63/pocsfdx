// Added By: Prabha
// Logic: Join Case.Medical_History_gne__c to Medical History.ID and 
//		  If Medical History. GATCF_SMN_Expiration_Date_gne__c > system date + 42 days, then 
//	  	     If Medical History.Rx_Expiration_gne__c > today +42 days then merge “”, 
//				   else merge “Yes”
//					else merge “”


public class SCM_MF_MedHistory_RXFlag extends SCM_MF_MedicalHistoryCollection {
		public SCM_MF_MedHistory_RXFlag(String medicalHistoryID){
		super(medicalHistoryID);
		key = 'Rx_Flag';
		className = 'SCM_MF_MedHistory_RXFlag';
	}
	
	public override String getFieldValue() {
		string ReturnVal ;
		if(medicalHistory != null && medicalHistory.GATCF_SMN_Expiration_Date_gne__c != null && medicalHistory.Rx_Expiration_gne__c != null) {
			if (medicalHistory.GATCF_SMN_Expiration_Date_gne__c > Date.today().addDays(42)){
				if (medicalHistory.Rx_Expiration_gne__c > Date.today().addDays(42)){
					ReturnVal = '';}
				else {ReturnVal = 'Yes'; 
				} 
			}
			else {ReturnVal = ''; 
			} 
		}
		else {
			ReturnVal = '';
		}
		
		return ReturnVal ;
		
	}


}