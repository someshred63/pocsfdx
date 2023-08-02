public without sharing class GNE_MCCO_CRM_Survey_Builder_New_Ctrl extends GNE_MCCO_CRM_Survey_Util {

    public String copyId { get; private set; }
    public GNE_MCCO_CRM_Survey__c surveyObj { get; private set; }
    public Boolean editMode { get; private set; }
    public Boolean copyMode { get; private set; }
    public String territoriesJson { get; private set; }
    public String selectedTerritoriesJson { get; private set; }
    public SurveyWrapper survey { get; set; }
    public String iconBase64 { get; private set; }

    public GNE_MCCO_CRM_Survey_Builder_New_Ctrl() {

        String surveyId = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
        copyId = (ApexPages.currentPage().getParameters().get('copy') != null && ApexPages.currentPage().getParameters().get('copy') != '') ? ApexPages.currentPage().getParameters().get('copy') : null;

        List<Territory2> territoriesList = GNE_MCCO_CRM_Survey_Util.getTerritories();
        territoriesJson = JSON.serializePretty(territoriesList);

        editMode = String.isNotBlank(surveyId);
        copyMode = String.isNotBlank(copyId);

        if (editMode || copyMode) {
            Id sId = editMode ? surveyId : copyId;
            try {
                // SurveyObject with Questions and Groups
                surveyObj = [SELECT Id, Name, Assignment_Mode_gne__c, Close_Survey_gne__c, Account_Ids_gne__c, Ready_To_Use_gne__c, Record_Type_gne__c, Territories_gne__c, Title_gne__c, Status_gne__c, Notification_gne__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, Requested_By_gne__r.Id, Requested_By_gne__r.Name, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate FROM GNE_MCCO_CRM_Survey__c WHERE Id = :sId LIMIT 1];

                // QuestionsList
                List<GNE_MCCO_CRM_Survey_Question__c> questionsList = [SELECT Id, Name, Conditional_Help_Text_gne__c, Group_gne__c, Help_Text_gne__c, Order_gne__c, Required_gne__c, Question_gne__c, Type_gne__c, Values_gne__c FROM GNE_MCCO_CRM_Survey_Question__c WHERE Survey_gne__c = :sId];

                // GroupsList
                List<GNE_MCCO_CRM_Survey_Group__c> groupsList = [SELECT Id, Name, Order_gne__c, Title_gne__c FROM GNE_MCCO_CRM_Survey_Group__c WHERE Survey_gne__c = :sId];

                // Create Wrapper From Objects
                survey = new SurveyWrapper();
                survey = survey.createWrapperFromObjects(surveyObj, questionsList, groupsList, copyMode);

                selectedTerritoriesJson = JSON.serializePretty(survey.Territories);
            } catch (Exception ex) {
                selectedTerritoriesJson = JSON.serializePretty(new List<String>());
                System.debug(LoggingLevel.ERROR, ex.getMessage());
            }

        } else {
            selectedTerritoriesJson = JSON.serializePretty(new List<String>());
        }

        iconBase64 = GNE_MCCO_CRM_Util.getDocumentBase64('GNE_MCCO_CRM_Survey_Builder_Icon');
    }

    public PageReference checkIfSurveyCanBeEdit() {
        if (surveyObj != null && surveyObj.Close_Survey_gne__c && !copyMode) {
            PageReference pageRef = new PageReference('/apex/GNE_MCCO_CRM_Survey_Builder_Detail?id=' + surveyObj.Id);
            pageRef.setRedirect(true);
            return pageRef;
        } else {
            return null;
        }
    }

    @RemoteAction
    @ReadOnly
    public static List<User> loadUsers(String searchValue) {
        List<User> users = new List<User>();

        if (String.isNotBlank(searchValue)) {
            searchValue = '%' + searchValue + '%';
            users = [SELECT Id, Name FROM User WHERE IsActive = TRUE AND Name LIKE :searchValue ORDER BY Name LIMIT 100];
        } else {
            users = [SELECT Id, Name FROM User WHERE IsActive = TRUE ORDER BY Name LIMIT 100];
        }
        return users;
    }

    @RemoteAction
    public static Map<String, String> save(String surveyJson, String elementsToDeleteJson) {
        Map<String, String> result = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        Boolean isEdit = false;
        try {
            SurveyWrapper surveyData = (SurveyWrapper) JSON.deserialize(surveyJson, SurveyWrapper.class);
            if(surveyData.AssignmentMode == 'Account'){
                surveyData.Territories.clear();
            } else if(surveyData.AssignmentMode == 'Territory'){
                surveyData.AccountIds.clear();
            }
            System.debug('surveyData: ' + surveyData);
            List<String> elementsToDelete = (List<String>) JSON.deserialize(elementsToDeleteJson, List<String>.class);

            List<GNE_MCCO_CRM_Survey_Question__c> questionList = new List<GNE_MCCO_CRM_Survey_Question__c>();
            List<GNE_MCCO_CRM_Survey_Group__c> groupList = new List<GNE_MCCO_CRM_Survey_Group__c>();

            List<GNE_MCCO_CRM_Survey_Question__c> questionsToDelete = new List<GNE_MCCO_CRM_Survey_Question__c>();
            List<GNE_MCCO_CRM_Survey_Group__c> groupsToDelete = new List<GNE_MCCO_CRM_Survey_Group__c>();

            if (surveyData.AccountIds.size() > 0) {
                Set<String> accountSet = new Set<String>();
                for (Id accountId : (new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :surveyData.AccountIds])).keySet()) {
                    accountSet.add(String.valueOf(accountId));
                }
                if (accountSet.size() != surveyData.AccountIds.size()) {
                    Set<String> invalidIds = surveyData.AccountIds;
                    invalidIds.removeAll(accountSet);

                    String errorMsg = 'There are some invalid Account Ids: ';

                    for (String invalidId : invalidIds) {
                        errorMsg += invalidId + ', ';
                    }
                    errorMsg = errorMsg.removeEnd(',');
                    result.put('status', 'INVALID_ACCOUNTS');
                    result.put('message', errorMsg);
                    return result;
                }
            }

            if (elementsToDelete.size() > 0) {
                questionsToDelete = [SELECT Id FROM GNE_MCCO_CRM_Survey_Question__c WHERE Id IN :elementsToDelete];
                groupsToDelete = [SELECT Id FROM GNE_MCCO_CRM_Survey_Group__c WHERE Id IN :elementsToDelete];
            }

            String territoriesNames = '';

            if (surveyData.Territories.size() > 0) {
                for (Territory2 t : [SELECT Name FROM Territory2 WHERE Id IN :surveyData.Territories]) {
                    territoriesNames += t.Name + ';';
                }
            }

            GNE_MCCO_CRM_Survey__c survey = new GNE_MCCO_CRM_Survey__c(
                    Account_Ids_gne__c = surveyData.getAccountIdsAsString(),
                    Close_Survey_gne__c = surveyData.Closed,
                    Ready_To_Use_gne__c = surveyData.ReadyToUse,
                    Territories_gne__c = surveyData.getTerritoryIdsAsString(),
                    Territories_Names_gne__c = territoriesNames.removeEnd(';'),
                    Title_gne__c = surveyData.Title,
                    Notification_gne__c = surveyData.Notification,
                    Record_Type_gne__c = surveyData.Type,
                    Assignment_Mode_gne__c = surveyData.AssignmentMode
            );


            if (!String.isEmpty(surveyData.Id)) {
                survey.Id = surveyData.Id;
                isEdit = true;
            }

            if (!String.isEmpty(surveyData.RequestedBy)) {
                survey.Requested_By_gne__c = surveyData.RequestedBy;
            }

            upsert survey;

            for (SurveyElementWrapper element : surveyData.Elements) {

                if (element.Type == 'Group') {

                    GNE_MCCO_CRM_Survey_Group__c groupElement = new GNE_MCCO_CRM_Survey_Group__c (
                            Order_gne__c = element.Order,
                            Survey_gne__c = survey.Id,
                            Title_gne__c = element.Title
                    );

                    if (!String.isEmpty(element.Id)) {
                        groupElement.Id = element.Id;
                    }

                    groupList.add(groupElement);

                } else {

                    GNE_MCCO_CRM_Survey_Question__c questionElement = new GNE_MCCO_CRM_Survey_Question__c (
                            Conditional_Help_Text_gne__c = element.CondHelp,
                            Group_gne__c = null,
                            Help_Text_gne__c = element.Help,
                            Order_gne__c = element.Order,
                            Required_gne__c = element.Required,
                            Survey_gne__c = survey.Id,
                            Question_gne__c = element.Title,
                            Type_gne__c = element.Type,
                            Values_gne__c = element.getValuesAsString()
                    );

                    if (!String.isEmpty(element.Id)) {
                        questionElement.Id = element.Id;
                    }

                    questionList.add(questionElement);

                }

            }

            upsert groupList;

            for (GNE_MCCO_CRM_Survey_Group__c groupElement : groupList) {

                for (SurveyElementWrapper element : surveyData.Elements) {

                    if (element.Type == 'Group' && element.Title == groupElement.Title_gne__c) {

                        if (element.Elements.size() > 0) {

                            for (SurveyElementWrapper childElement : element.Elements) {

                                GNE_MCCO_CRM_Survey_Question__c questionElement = new GNE_MCCO_CRM_Survey_Question__c (
                                        Conditional_Help_Text_gne__c = childElement.CondHelp,
                                        Group_gne__c = groupElement.Id,
                                        Help_Text_gne__c = childElement.Help,
                                        Order_gne__c = childElement.Order,
                                        Required_gne__c = childElement.Required,
                                        Survey_gne__c = survey.Id,
                                        Question_gne__c = childElement.Title,
                                        Type_gne__c = childElement.Type,
                                        Values_gne__c = childElement.getValuesAsString()
                                );

                                if (!String.isEmpty(childElement.Id)) {
                                    questionElement.Id = childElement.Id;
                                }
                                questionList.add(questionElement);
                            }
                        }
                    }
                }
            }

            upsert questionList;

            // Delete Questions
            if (questionsToDelete.size() > 0) {
                delete questionsToDelete;
            }

            // Delete Groups
            if (groupsToDelete.size() > 0) {
                delete groupsToDelete;
            }

            // Execute Batch When Survey is Published
            if (survey.Ready_To_Use_gne__c) {
                if (survey.Record_Type_gne__c == 'General') {
                    updateGeneralFieldIntelligence(survey);
                } else {
                    Database.executeBatch(new GNE_MCCO_CRM_Survey_Batch(JSON.serializePretty(survey), isEdit), 200);
                }
            }

            // Close all Surveys
            if (survey.Close_Survey_gne__c) {
                closeAllFI(survey.Id);
            }

            result.put('status', 'OK');
            result.put('message', '');
            result.put('id', survey.Id);

        } catch (Exception ex) {
            Database.rollback(sp);
            result.put('status', 'ERROR');
            result.put('message', ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
        return result;
    }

    public static void updateGeneralFieldIntelligence(GNE_MCCO_CRM_Survey__c survey) {
        List<GNE_MCCO_CRM_Field_Intelligence__c> fis = new List<GNE_MCCO_CRM_Field_Intelligence__c>();
        Set<Id> userIdsSet = new Set<Id>();
        Set<Id> userHasFiIdsSet = new Set<Id>();
        // Upsert Field Intelligence based on Survey' Territories
        if (!String.isEmpty(survey.Territories_gne__c)) {
            for (UserTerritory2Association ut : [SELECT UserId FROM UserTerritory2Association WHERE IsActive = TRUE AND Territory2Id IN :survey.Territories_gne__c.split(';', 0)]) {
                userIdsSet.add(ut.UserId);
            }

            fis = [SELECT User_gne__c, Available_gne__c, Comment_gne__c, Survey_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Survey_gne__c = :survey.Id];
            Datetime dateTimeNow = System.now();

            for (GNE_MCCO_CRM_Field_Intelligence__c fi : fis) {
                userHasFiIdsSet.add(fi.User_gne__c);
                if (userIdsSet.contains(fi.User_gne__c)) {
                    if (!fi.Available_gne__c) {
                        fi.Available_gne__c = true;
                        fi.Comment_gne__c = '';
                    }
                } else {
                    if (fi.Available_gne__c) {
                        fi.Available_gne__c = false;
                        fi.Comment_gne__c = dateTimeNow.format('MM/dd/yyyy') + ' - survey hidden as user / account should no longer see the survey.';
                    }
                }
            }

            userIdsSet.removeAll(userHasFiIdsSet);

            for (Id userId : userIdsSet) {
                fis.add(
                        new GNE_MCCO_CRM_Field_Intelligence__c(
                                Available_gne__c = true,
                                User_gne__c = userId,
                                Survey_gne__c = survey.Id
                        )
                );
            }

            // Field Intelligence
            System.debug('# Field Intelligence To Upsert #');
            for (GNE_MCCO_CRM_Field_Intelligence__c fi : fis) {
                System.debug(fi);
            }
            upsert fis;
        }
    }

    private static void closeAllFI(Id surveyId) {
        List<GNE_MCCO_CRM_Field_Intelligence__c> fiToClose = [SELECT Survey_Status_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Survey_gne__c = :surveyId];
        for (GNE_MCCO_CRM_Field_Intelligence__c s : fiToClose) {
            s.Survey_Status_gne__c = 'Closed';
        }
        update fiToClose;
    }
}