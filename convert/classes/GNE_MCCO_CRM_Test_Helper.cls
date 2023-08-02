/*
 * GNE_MCCO_CRM_Test_Helper
 *
 * Created By : Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 */

public with sharing class GNE_MCCO_CRM_Test_Helper {

    static public User getTestUser(String profileName, String territoryName) {

        Set<Id> userIds = new Set<Id>();

        Territory2 t = [SELECT Id FROM Territory2 WHERE Name = :territoryName LIMIT 1];

        for(UserTerritory2Association ut : [SELECT UserId FROM UserTerritory2Association WHERE Territory2Id = :t.Id]) {
            userIds.add(ut.UserId);
        }

        User u = [SELECT Id, Name, FirstName, LastName, ProfileId, TimeZoneSidKey FROM User WHERE Id IN :userIds AND Profile.Name = :profileName AND isActive = true LIMIT 1];

        return u;

    }

    static public SFA2_View_Config_gne__c createView(String appName, String objName, String role, String viewFields, String filter) {

        SFA2_View_Config_gne__c view = new SFA2_View_Config_gne__c(

            View_Name_gne__c        = objName + '__test',
            View_Fields_gne__c      = viewFields,
            Sorting_Field_gne__c    = 'Name',
            Sorting_Order_gne__c    = 'ASC',
            Filter_Statement_gne__c = filter,
            Application_Type_gne__c = appName,
            Role_gne__c             = role,
            Visibility_gne__c       = 'restricted',
            Page_Name_gne__c        = objName,
            Object_Type_gne__c      = objName

        );

        insert view;
        return view;

    }


    static public SFA2_View_Config_gne__c createView(String appName, String objName, String role, String viewFields, String filter, String sorting) {

        SFA2_View_Config_gne__c view = new SFA2_View_Config_gne__c(

            View_Name_gne__c        = objName + '__test',
            View_Fields_gne__c      = viewFields,
            Sorting_Field_gne__c    = sorting,
            Sorting_Order_gne__c    = 'ASC',
            Filter_Statement_gne__c = filter,
            Application_Type_gne__c = appName,
            Role_gne__c             = role,
            Visibility_gne__c       = 'restricted',
            Page_Name_gne__c        = objName,
            Object_Type_gne__c      = objName

        );

        insert view;
        return view;

    }

    static public SFA2_View_Config_gne__c createView(String appName, String objName, String role) {

        SFA2_View_Config_gne__c view = new SFA2_View_Config_gne__c(

            View_Name_gne__c        = objName + '__test',
            View_Fields_gne__c      = 'LastName;FirstName;Developer_Title_gne__c;Developer_Function_gne__c;Phone;Email;DO_NOT_CONTACT_gne__c;Account.Name;LastModifiedDate',
            Sorting_Field_gne__c    = 'Name',
            Sorting_Order_gne__c    = 'ASC',
            Filter_Statement_gne__c = '[{"valueType":"BOOLEAN","value":"true","operator":"eq","multiValue":null,"field":"Active_gne__c"}]',
            Application_Type_gne__c = appName,
            Role_gne__c             = role,
            Visibility_gne__c       = 'restricted',
            Page_Name_gne__c        = objName,
            Object_Type_gne__c      = objName

        );

        insert view;
        return view;

    }

    static public SFA2_View_Config_gne__c getView(String appName, String objName, String role) {
        return [SELECT Id, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Visibility_gne__c FROM SFA2_View_Config_gne__c WHERE Application_Type_gne__c = :appName AND Role_gne__c = :role AND Page_Name_gne__c = :objName LIMIT 1];
    }

    static public Territory2 getTerritory(String territoryName) {
        return [SELECT Id, Name FROM Territory2 WHERE Name = :territoryName LIMIT 1];
    }

    static public void removeViews(String appName, String objName, String pageName) {
        List<SFA2_View_Config_gne__c> views = [SELECT Id FROM SFA2_View_Config_gne__c WHERE Visibility_gne__c = 'restricted' AND Object_Type_gne__c = :objName AND Application_Type_gne__c = :appName];
        delete views;
    }

    static public Account getTestAccount(String territoryName) {
        TSF_vod__c tsf = [SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c = :territoryName LIMIT 1];
        Account account = [SELECT Id, Name FROM Account WHERE Id = :tsf.Account_vod__c];
        return account;
    }

    static public Contact getTestContact() {
        return [SELECT Id, Name FROM Contact LIMIT 1];
    }

    static public GNE_MCCO_CRM_Survey__c createTestSurvey(String territoryName, String recordType, Boolean readyToUse, Boolean closed) {

        Territory2 territory = [SELECT Id FROM Territory2 WHERE Name = :territoryName LIMIT 1];

        GNE_MCCO_CRM_Survey__c survey = new GNE_MCCO_CRM_Survey__c(
            Close_Survey_gne__c = closed,
            Ready_To_Use_gne__c = readyToUse,
            Territories_gne__c = territory.Id,
            Territories_Names_gne__c = territoryName,
            Title_gne__c = 'Survey for Unit Test',
            Record_Type_gne__c = recordType
        );

        insert survey;

        return survey;
    }

    static public GNE_MCCO_CRM_Survey__c createTestSurvey(String territoryName, String recordType, Boolean readyToUse, Boolean closed, String accountIds) {

        Territory2 territory = [SELECT Id FROM Territory2 WHERE Name = :territoryName LIMIT 1];

        GNE_MCCO_CRM_Survey__c survey = new GNE_MCCO_CRM_Survey__c(
            Close_Survey_gne__c = closed,
            Ready_To_Use_gne__c = readyToUse,
            Territories_gne__c = territory.Id,
            Territories_Names_gne__c = territoryName,
            Title_gne__c = 'Survey for Unit Test',
            Record_Type_gne__c = recordType,
            Account_Ids_gne__c = accountIds
        );

        insert survey;

        return survey;
    }

    static public GNE_MCCO_CRM_Field_Intelligence__c createTestFieldIntelligence(GNE_MCCO_CRM_Survey__c s, User u, String status) {

        GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligence = new GNE_MCCO_CRM_Field_Intelligence__c(
            Survey_gne__c = s.Id,
            Survey_Status_gne__c = status,
            User_gne__c = u.Id
        );

        insert fieldIntelligence;

        return fieldIntelligence;
    }

    static public GNE_MCCO_CRM_Field_Intelligence__c createTestFieldIntelligence(GNE_MCCO_CRM_Survey__c s, Account a, String status) {

        GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligence = new GNE_MCCO_CRM_Field_Intelligence__c(
            Survey_gne__c = s.Id,
            Survey_Status_gne__c = status,
            Account_gne__c = a.Id
        );

        insert fieldIntelligence;

        return fieldIntelligence;
    }

    static public GNE_MCCO_CRM_Field_Intelligence__c createTestFieldIntelligence(GNE_MCCO_CRM_Survey__c s, Account a, User u, String status, Boolean available) {

        GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligence = new GNE_MCCO_CRM_Field_Intelligence__c(
            Survey_gne__c = s.Id,
            Survey_Status_gne__c = status,
            Account_gne__c = a.Id,
            User_gne__c = u.Id,
            Available_gne__c = available
        );

        insert fieldIntelligence;

        return fieldIntelligence;
    }

    static public List<GNE_MCCO_CRM_Survey_Question__c> createTestSurveyQuestion(GNE_MCCO_CRM_Survey__c s) {

        List<GNE_MCCO_CRM_Survey_Question__c> questions = new List<GNE_MCCO_CRM_Survey_Question__c>();

        Integer randomNumber = 2;

        for (Integer i = 0; i < randomNumber; i++) {

            questions.add(
                new GNE_MCCO_CRM_Survey_Question__c(
                    Order_gne__c = i,
                    Question_gne__c = 'Test question ' + i,
                    Type_gne__c = 'Free text',
                    Survey_gne__c = s.Id
                )
            );

        }

        for (Integer i = 0; i < randomNumber; i++) {

            questions.add(
                new GNE_MCCO_CRM_Survey_Question__c(
                    Order_gne__c = i+1,
                    Question_gne__c = 'Test question ' + i,
                    Type_gne__c = 'Multi select picklist',
                    Values_gne__c = 'Test;;;Test2',
                    Survey_gne__c = s.Id
                )
            );

        }

        for (Integer i = 0; i < randomNumber; i++) {

            questions.add(
                new GNE_MCCO_CRM_Survey_Question__c(
                    Order_gne__c = i+1,
                    Question_gne__c = 'Test question ' + i,
                    Type_gne__c = 'Conditional',
                    Values_gne__c = 'Test---true;;;Test2---false',
                    Survey_gne__c = s.Id
                )
            );

        }

        insert questions;

        return questions;
    }

    static public List<GNE_MCCO_CRM_Survey_Question__c> createTestSurveyQuestion(GNE_MCCO_CRM_Survey__c s, GNE_MCCO_CRM_Survey_Group__c g) {

        List<GNE_MCCO_CRM_Survey_Question__c> questions = new List<GNE_MCCO_CRM_Survey_Question__c>();

        Integer randomNumber = 2;

        for (Integer i = 0; i < randomNumber; i++) {

            questions.add(
                new GNE_MCCO_CRM_Survey_Question__c(
                    Order_gne__c = i,
                    Question_gne__c = 'Test question ' + i,
                    Type_gne__c = 'Free text',
                    Survey_gne__c = s.Id,
                    Group_gne__c = g.Id
                )
            );

        }

        for (Integer i = 0; i < randomNumber; i++) {

            questions.add(
                new GNE_MCCO_CRM_Survey_Question__c(
                    Order_gne__c = i+1,
                    Question_gne__c = 'Test question ' + i,
                    Type_gne__c = 'Multi select picklist',
                    Values_gne__c = 'Test;;;Test2',
                    Survey_gne__c = s.Id,
                    Group_gne__c = g.Id
                )
            );

        }

        for (Integer i = 0; i < randomNumber; i++) {

            questions.add(
                new GNE_MCCO_CRM_Survey_Question__c(
                    Order_gne__c = i+1,
                    Question_gne__c = 'Test question ' + i,
                    Type_gne__c = 'Conditional',
                    Values_gne__c = 'Test---true;;;Test2---false',
                    Survey_gne__c = s.Id,
                    Group_gne__c = g.Id
                )
            );

        }

        insert questions;

        return questions;
    }

    static public GNE_MCCO_CRM_Survey_Group__c createTestSurveyGroup(GNE_MCCO_CRM_Survey__c s) {

       	GNE_MCCO_CRM_Survey_Group__c groupElement = new GNE_MCCO_CRM_Survey_Group__c(
            Order_gne__c = 0,
            Title_gne__c = 'Test group',
            Survey_gne__c = s.Id
        );

        insert groupElement;

        return groupElement;
    }

    static public List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> createTestFieldIntelligenceAnwser(GNE_MCCO_CRM_Field_Intelligence__c fi) {
        List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> anwsers = new List<GNE_MCCO_CRM_Field_Intelligence_Answer__c>();

        for(GNE_MCCO_CRM_Survey_Question__c question : [SELECT Id, Group_gne__c FROM GNE_MCCO_CRM_Survey_Question__c WHERE Survey_gne__c = :fi.Survey_gne__c]) {
            anwsers.add(
                new GNE_MCCO_CRM_Field_Intelligence_Answer__c(
                    Answer_gne__c = 'Test anwser',
                    Field_Intelligence_gne__c = fi.Id,
                    Survey_Question_gne__c = question.Id,
                    MCCO_CRM_Survey_Group_gne__c = question.Group_gne__c
                )
            );
        }

        insert anwsers;

        return anwsers;
    }

    static public List<Call2_vod__c> createTestInteractions(Account a, Integer howMuch) {
        List<Call2_vod__c> interactions = new List<Call2_vod__c>();

        for(Integer i = 0; i < howMuch; i++) {
            interactions.add(
                new Call2_vod__c(
                    Account_vod__c = a.Id,
                    Parent_Call_vod__c = null,
                    Call_Datetime_vod__c = System.today()
                )
            );
        }

        insert interactions;

        return interactions;
    }

    static public List<Call2_vod__c> getTestInteractions(Integer howMuch) {
        return [SELECT Id FROM Call2_vod__c WHERE Account_vod__c != null LIMIT :howMuch];
    }

    static public GNE_MCCO_CRM_Launch_Readiness_Page__c createTestLaunchReadinessPage() {

        GNE_MCCO_CRM_Launch_Readiness_Page__c testPage = new GNE_MCCO_CRM_Launch_Readiness_Page__c(
            Title_gne__c = 'Test',
            Color_gne__c = 'Test',
            Banner_gne__c = 'Test',
            Logo_gne__c = 'Test',
            Active_gne__c = true
        );

        insert testPage;

        return testPage;

    }

    static public List<GNE_MCCO_CRM_Launch_Readiness_Content__c> createTestLaucnhReadinessContent(GNE_MCCO_CRM_Launch_Readiness_Page__c p, Integer howMuch) {
        List<GNE_MCCO_CRM_Launch_Readiness_Content__c> contents = new List<GNE_MCCO_CRM_Launch_Readiness_Content__c>();

        for(Integer i = 0; i < howMuch; i++) {
            contents.add(
                new GNE_MCCO_CRM_Launch_Readiness_Content__c(
                    Name = 'Test ' + i,
                    Active_gne__c = true,
                    Content_gne__c = 'Test',
                    Target_Completion_Date_gne__c = System.Today(),
                    Launch_Readiness_Page__c = p.Id,
                    Order_gne__c = i
                )
            );
        }

        insert contents;

        return contents;
    }

    static public List<ContentDocument> getTestContentDocument(Set<Id> libIds) {
        return [SELECT Id, Title, ParentId FROM ContentDocument WHERE ParentId IN :libIds];
    }

}