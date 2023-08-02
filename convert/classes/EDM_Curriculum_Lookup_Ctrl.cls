public with sharing class EDM_Curriculum_Lookup_Ctrl {
    public ApexPages.StandardSetController setCon {	get; set; }
    public String SearchPRCText { get; set; }
    public Boolean showInactiveCurricula { get; set; }
    
    public EDM_Curriculum_Lookup_Ctrl() {
        showInactiveCurricula = false;
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, EDM_Title_Multiselect_gne__c,Aprimo_ID_gne__c,Approval_Date_gne__c,Curriculum_Status_gne__c 
                                                                                FROM Event_Curriculum_gne__c
                                                                                WHERE Curriculum_Status_gne__c = 'Active'
                                                                                AND Curriculum_External_Id_gne__c != null]));
    }

    public List<Event_Curriculum_gne__c> getCurricula() {
    	setCon.setpagesize(200);
        return (List<Event_Curriculum_gne__c>) setCon.getRecords();
    }

    public PageReference Search() {
        String status = showInactiveCurricula ? 'Inactive' : 'Active';
        if (String.isBlank(SearchPRCText)) {
            setCon = new ApexPages.StandardSetController(
                        Database.getQueryLocator([SELECT Id, EDM_Title_Multiselect_gne__c, Aprimo_ID_gne__c, Approval_Date_gne__c, Curriculum_Status_gne__c 
                                                    FROM Event_Curriculum_gne__c 
                                                    WHERE (Curriculum_Status_gne__c = 'Active' OR Curriculum_Status_gne__c = :status)
                                                    AND Curriculum_External_Id_gne__c != null])
                    );
        }
        else {
            SearchPRCText = SearchPRCText.trim();
            if (!SearchPRCText.endsWith('*')) {
                SearchPRCText += '*';
            }
            String PRCFilter = SearchPRCText.replace('*', '%'); //'%' + SearchPRCText + '%';
            setCon = new ApexPages.StandardSetController(
                        Database.getQueryLocator([SELECT Id, EDM_Title_Multiselect_gne__c, Aprimo_ID_gne__c, Approval_Date_gne__c, Curriculum_Status_gne__c 
                                                    FROM Event_Curriculum_gne__c 
                                                    WHERE (Curriculum_Status_gne__c = 'Active' OR Curriculum_Status_gne__c = :status)
                                                    AND Curriculum_External_Id_gne__c != null
                                                    AND Aprimo_ID_gne__c LIKE :PRCFilter])
                    );
        }        
		return null;
	}
}