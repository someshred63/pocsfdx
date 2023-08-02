public without sharing class AGS_Corrections_gne {
    public AGS_Spend_Expense_Transaction_gne__c    expDetails   { get; set; }
    public AGS_Spend_Correction_gne__c             correction   { get; set; }
    public Boolean                                 isSaved      { get; set; }
    public Boolean                                 isEditable   { get; set; }
    
    public AGS_Corrections_gne(ApexPages.StandardController controller) {
        String expenseId   = ApexPages.currentPage().getParameters().get('id');
        String corrId      = ApexPages.currentPage().getParameters().get('corrId');

        isEditable = false;  
        if(expenseId != null) {
            expDetails = [select Name, Event_ID_gne__c, Source_Transaction_Amount_gne__c, Is_Correction_gne__c, Spend_User_gne__c, Report_Code_gne__c, 
                           Spend_User_Unix_ID_gne__c, Event_Date_gne__c, Source_System_Code_gne__c, Allocated_Transaction_Amount_gne__c,
                           Infrequent_User_Flag_gne__c, SAP_T_E_Trip_Number_gne__c, SAP_T_E_Serial_Number_gne__c, Source_Transaction_ID_gne__c
                           from AGS_Spend_Expense_Transaction_gne__c where id = :expenseId];   
            if('XC_MON'.equals(expDetails.Report_Code_gne__c)) {
            	isEditable = true;
            } 
        }
        if(corrId != null) {
            isSaved = true;
            List<AGS_Spend_Correction_gne__c> corrections = [select id, Corrected_SL_Number_gne__c, Createdby.Name, 
                                                             Corrected_Source_Transaction_Amount_gne__c, Corrected_SAP_T_E_Interaction_Name_gne__c,
                                                             Corrected_Spend_Transaction_Date_gne__c, Source_Transaction_ID_gne__c,
                                                             Correction_for_SAP_T_E_Trip_Number_gne__c, Correction_SAP_T_E_Serial_Number__c
                                                             from AGS_Spend_Correction_gne__c where id = :corrId and createddate=today limit 1];
            correction = corrections[0];
        } else { 
            isSaved = false;
            correction = new AGS_Spend_Correction_gne__c();
            correction.AGS_Spend_Expense_Transaction_gne__c        = expenseId;            
            correction.Corrected_Source_Transaction_Amount_gne__c  = expDetails.Source_Transaction_Amount_gne__c;
            correction.Corrected_SAP_T_E_Interaction_Name_gne__c   = expDetails.Event_ID_gne__c;
            correction.Corrected_Spend_Transaction_Date_gne__c     = expDetails.Event_Date_gne__c;
            correction.Source_Transaction_ID_gne__c                = 'CO_'+expDetails.Source_Transaction_ID_gne__c;
        }
    }
    
    public PageReference save() {
    	if(isEditable) {
	        String retURL      = ApexPages.currentPage().getParameters().get('retURL');
	        String expenseId   = ApexPages.currentPage().getParameters().get('id');

	        List<AGS_Spend_Correction_gne__c> correctionRecords = [SELECT id, AGS_Spend_Expense_Transaction_gne__r.Report_Code_gne__c, CreatedDate 
	                                                               FROM AGS_Spend_Correction_gne__c 
	                                                               WHERE AGS_Spend_Expense_Transaction_gne__c = :expenseId 
	                                                               ORDER BY CreatedDate DESC 
	                                                               LIMIT 1];
	        if(correctionRecords != null && correctionRecords.size() > 0) {
                if(correctionRecords[0].AGS_Spend_Expense_Transaction_gne__r.Report_Code_gne__c !='XC_MON') {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You can only update XC_MON spend transactions.'));
                    return null;
                }
                if(Date.newInstance(correctionRecords[0].CreatedDate.year(),correctionRecords[0].CreatedDate.month(),correctionRecords[0].CreatedDate.day()) == Date.today()) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'The one correction record was created today. You cannot create a correction record for the same transaction in the same date.'));
                    return null;
                }
	        }
	        insert correction;

	        PageReference pr = new PageReference('/apex/AGS_Corrections_gne?id='+expenseId+'&corrId='+correction.id+'&retURL='+retURL);
	        pr.setRedirect(true);
	        return pr;
    	} else {
    		return null;
    	}
    }
    
    public PageReference backToList() {
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pr = new PageReference(retURL);
        pr.setRedirect(true);
        return pr;
    }
}