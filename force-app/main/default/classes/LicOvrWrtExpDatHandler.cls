global class LicOvrWrtExpDatHandler {
	private static final Date TODAY_PLUS_40_DAYS = System.today() + 40;
    private static final String ERR_MSG_LIC_STATE = 'Please enter License State';
    private static final String ERR_MSG_LIC_NUM = 'Please enter License Number';
    private static final String ERR_MSG_LIC_EXP_DAT = 'Please enter Adjusted License Expiration Date';
    private static final String DCR_STATUS_ACTIVE_OVERWRITE = 'Active Overwrite';
         
    public static Integer handleLiceExpDat(List<Change_Request_gne__c> changeReqOld, List<Change_Request_gne__c> changeReqNew) {
		Id licIssueRecTypeId = GNE_SFA2_DCR_Trigger_Helper.getLicIssueRecordTypeId();
        
        Integer idx = 0;
        for(Change_Request_gne__c crNew : changeReqNew) {
        	try {
        		if(crNew.RecordTypeId == licIssueRecTypeId) {
         			Change_Request_gne__c crOld = changeReqOld[idx++];
         			handleLiceExpDat(crOld, crNew);
         		}
         		
         	} catch(Exception e) {
         		crNew.addError(e.getMessage());
         	}
        }
         
        return 0;
	}
   
    private static void handleLiceExpDat(Change_Request_gne__c crOld, Change_Request_gne__c crNew) {
    	if (crNew.status_gne__c == DCR_STATUS_ACTIVE_OVERWRITE && crOld.status_gne__c != DCR_STATUS_ACTIVE_OVERWRITE) {
    		
    		Date adjLicExpDat = crNew.Adjusted_License_Expiration_Date_gne__c;
    		Boolean isValid = true;
            
            if(String.isBlank(crNew.License_State_gne__c)) {
                crNew.addError(ERR_MSG_LIC_STATE);
                isValid = false;
            }
            
            if(String.isBlank(crNew.License_Number_gne__c)) {
                crNew.addError(ERR_MSG_LIC_NUM);
                isValid = false;
            }
            if(adjLicExpDat == null) {
                crNew.addError(ERR_MSG_LIC_EXP_DAT);
                isValid = false;
            }
            
            if(isValid) {
	            if(TODAY_PLUS_40_DAYS >= adjLicExpDat) {
	                crNew.License_Overwrite_Expiration_Date_gne__c = adjLicExpDat;
	            } else {
	                crNew.License_Overwrite_Expiration_Date_gne__c = TODAY_PLUS_40_DAYS;
	            }
            }
        }
    }
}