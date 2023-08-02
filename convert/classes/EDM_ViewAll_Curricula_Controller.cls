public with sharing class EDM_ViewAll_Curricula_Controller {
	public String viewObjectName { get; set; }
    public String viewFieldsCSV { get; set; }
    public String viewFilter { get; set; }
    public Integer viewPageSize { get; set; }
    public Id viewParentId { get; set; }
    public String viewParentFieldName { get; set; }
    public String viewOrderByFieldName { get; set; }
    public String viewUrlForNewRecord { get; set; }
    public String viewSortDirection { get; set; }
    public Boolean viewHideButtons { get; set; }
    public Boolean viewHideEditLink { get; set; }
    public Boolean viewHideDeleteLink { get; set; }
    public String viewRelatedListLabel { get; set; }
    //public String whereCondition { get; set; }
    public String curriculums { get; set; }
    public Boolean canAddCurriculas {get; set;}
    public Boolean canRemoveCurriculas {get; set;}
    private List<String> exIds;
    public Integer numOfSelectedCurricula { get; set; }
    public Integer numOfRemovedCurricula { get; set; }
    public String popUpMode { get; set; }

	public EDM_ViewAll_Curricula_Controller() {
		String viewParentObjectName = 'Speaker_Bureau_gne__c';//
        String viewRecordTypeName = '';
        viewObjectName = 'Curriculum_Speaker_Bureau_gne__c';
        List<SFA2_Configuration_Object_Detail_gne__c> configurations = getUIConfigurationObjectDetails(viewParentObjectName, viewRecordTypeName, viewObjectName);
        System.debug('$$ Curricula Configurations' + configurations);
        GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(configurations.get(0).Attributes_gne__c);
                            
        viewFieldsCSV = attributesWrapper.fieldsCSV;
        viewPageSize = 50;
        viewParentId = Id.valueOf(ApexPages.currentPage().getParameters().get('viewParentId'));
        viewParentFieldName = 'Speaker_Bureau_gne__c';
        viewOrderByFieldName = 'NAME';
        viewUrlForNewRecord = '#';
        viewSortDirection = attributesWrapper.sortDirection;
        viewHideEditLink = attributesWrapper.hideEditLink; 
        viewHideDeleteLink = attributesWrapper.hideDeleteLink;
        viewRelatedListLabel = 'Curricula';
        viewHideButtons = attributesWrapper.hideButtons;
        Set<String> profilesThatCanAddCurriculas = new Set<String>{'GNE-TLS-SpeakerBureauLead', 'GNE-TLS-AB-SB-Admin'};
        canAddCurriculas = profilesThatCanAddCurriculas.contains(GNE_SFA2_Util.getCurrentUserProfileName());
	
        Set<String> profilesThatCanRemoveCurriculas = new Set<String>{'GNE-TLS-AB-SB-Admin'};
        canRemoveCurriculas = profilesThatCanRemoveCurriculas.contains(GNE_SFA2_Util.getCurrentUserProfileName());
    }

	public static List<SFA2_Configuration_Object_Detail_gne__c> getUIConfigurationObjectDetails(String parentObjectName, String recordTypeName, String apiName) {
            GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
            return [SELECT API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Required_gne__c,
                            Is_Read_Only_gne__c, Order_gne__c, Type_gne__c, Style_gne__c, Availability_Mode_gne__c 
                    FROM SFA2_Configuration_Object_Detail_gne__c
                    WHERE Type_gne__c = 'Related List'
                        AND Configuration_Object_ref_gne__r.Object_Name_gne__c =  :parentObjectName 
                        AND Configuration_Object_ref_gne__r.Role_gne__c = :userApplicationContext.Role_gne__c
                        AND Configuration_Object_ref_gne__r.Brand_gne__c = :userApplicationContext.Brand_gne__c
                        AND Configuration_Object_ref_gne__r.Application_Type__c = :userApplicationContext.App_Name_gne__c
                        AND Configuration_Object_ref_gne__r.Record_Type_gne__c = :recordTypeName
                        AND Configuration_Object_ref_gne__r.Is_Active_gne__c = true
                        AND Configuration_Object_ref_gne__r.Configuration_Type_gne__c = 'Page' 
                        AND Is_Active_gne__c = true 
                        AND API_Name_gne__c = :apiName
                   ORDER BY Order_gne__c, API_Name_gne__c];
    }

    public void saveCurriculum(){
        System.debug('#-#-# IDS: '+curriculums);
        List<String> ids = new List<String>(curriculums.split(';'));    

        List<Event_Curriculum_gne__c> events = new List<Event_Curriculum_gne__c>([SELECT Id, Name FROM Event_Curriculum_gne__c WHERE Id IN :ids AND Id NOT IN :exIds]);

        List<Curriculum_Speaker_Bureau_gne__c> curr = new List<Curriculum_Speaker_Bureau_gne__c>();
        for(Event_Curriculum_gne__c e : events){
            Curriculum_Speaker_Bureau_gne__c curriculum = new Curriculum_Speaker_Bureau_gne__c();
            curriculum.Event_Curriculum_gne__c = e.id;
            curriculum.Speaker_Bureau_gne__c = viewParentId;
            curr.add(curriculum);
        }

        insert curr;
    }

    public void removeCurriculum(){
        System.debug('#-#-# IDS: ' + curriculums);
        List<String> ids = new List<String>(curriculums.split(';'));
        Set<Id> idsToRemove = new Set<Id>();
        Map<Id, Integer> curriculumId2eventsCount = new Map<Id, Integer>();

        for (String id : ids) {
            curriculumId2eventsCount.put(id, 0);
        }

        for (Event_Curriculum_Join_gne__c event : [
            SELECT 
                Id, Name, Event_Curriculum_gne__r.Id, Medical_Event_gne__c
            FROM 
                Event_Curriculum_Join_gne__c 
            WHERE 
                Event_Curriculum_gne__c IN :ids AND 
                Medical_Event_gne__c IN (SELECT Medical_Event_gne__c FROM Event_Bureaus_gne__c WHERE Speaker_Bureau_gne__c = :viewParentId)]) {

            if (curriculumId2eventsCount.containsKey(event.Event_Curriculum_gne__r.Id) && event.Medical_Event_gne__c != null) {
                curriculumId2eventsCount.put(
                    event.Event_Curriculum_gne__r.Id, 
                    curriculumId2eventsCount.get(event.Event_Curriculum_gne__r.Id) + 1);
            }
        }
        System.debug(curriculumId2eventsCount);
        for (Id key : curriculumId2eventsCount.keySet()) {
            if (curriculumId2eventsCount.get(key) == 0) {
                idsToRemove.add(key);
            }
        }

        System.debug('#-#-# IDS TO BE REMOVED: ' + idsToRemove);
        if (!idsToRemove.isEmpty()) {
            List<Member_Trainings_gne__c> trainingsToRemove = getTrainingMembers(new List<Id>(idsToRemove), viewParentId);
            List<Curriculum_Speaker_Bureau_gne__c> speakersToRemove = getCurriculumSpeakers(new List<Id>(idsToRemove), viewParentId);

            if (!trainingsToRemove.isEmpty())
                delete trainingsToRemove;

            if (!speakersToRemove.isEmpty())
                delete speakersToRemove;
        }

        numOfSelectedCurricula = ids.size();
        numOfRemovedCurricula = idsToRemove.size();
    }

    private List<Curriculum_Speaker_Bureau_gne__c> getCurriculumSpeakers(List<Id> curriculum, Id bureau) {
        return [SELECT Id 
                FROM Curriculum_Speaker_Bureau_gne__c 
                WHERE 
                    Event_Curriculum_gne__c IN :curriculum AND 
                    Speaker_Bureau_gne__c = :bureau];
    }

    private List<Member_Trainings_gne__c> getTrainingMembers(List<Id> curriculum, Id bureau) {
        return [SELECT Id 
                FROM Member_Trainings_gne__c 
                WHERE 
                    Speaker_Training_gne__r.Event_Curriculum_gne__c IN :curriculum AND 
                    Speaker_Bureau_Membership_gne__r.Speaker_Bureau_ID_gne__c = :bureau];
    }

    public String getWhereCondition() {
    	String whereCondition = '';
        List<Curriculum_Speaker_Bureau_gne__c> existingCurr = [SELECT Event_Curriculum_gne__c FROM Curriculum_Speaker_Bureau_gne__c WHERE Speaker_Bureau_gne__c = :viewParentId];
        exIds = new List<String>();
        if (existingCurr.size() > 0) {
            whereCondition = 'Id NOT IN (';
            Integer i = existingCurr.size();
            for(Curriculum_Speaker_Bureau_gne__c c : existingCurr) {
                exIds.add(c.Event_Curriculum_gne__c);

                i--;
                whereCondition += '\'' + c.Event_Curriculum_gne__c + '\'';
                
                if (i > 0) {
                    whereCondition += ',';
                }
            }
            whereCondition += ') AND Curriculum_Status_gne__c != \'Deleted\' AND Curriculum_External_Id_gne__c != null';
        }
        System.debug('#WC#: ' + whereCondition);
        return whereCondition;
    }

    public String getCurrentCurricula() {
        String whereCondition = '';
        List<Curriculum_Speaker_Bureau_gne__c> existingCurr = [SELECT Event_Curriculum_gne__c FROM Curriculum_Speaker_Bureau_gne__c WHERE Speaker_Bureau_gne__c = :viewParentId];
        exIds = new List<String>();
        if (existingCurr.size() > 0) {
            whereCondition = 'Id IN (';
            Integer i = existingCurr.size();
            for(Curriculum_Speaker_Bureau_gne__c c : existingCurr) {
                exIds.add(c.Event_Curriculum_gne__c);

                i--;
                whereCondition += '\'' + c.Event_Curriculum_gne__c + '\'';
                
                if (i > 0) {
                    whereCondition += ',';
                }
            }
            whereCondition += ') AND Curriculum_Status_gne__c != \'Deleted\' AND Curriculum_External_Id_gne__c != null';
        }
        System.debug('#WC#: ' + whereCondition);
        return whereCondition;
    }

    public PageReference backToSpeakerBureauPage() {
        PageReference pageRef = new PageReference('/'+ viewParentId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}