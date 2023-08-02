/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-02-13
*  Description: This is a util class that contains methods for creating various objects with required fields filled
*
*  Modification History
*  Date			Name					Description
*  2015.07.08	Przemyslaw Giszczak		add new prepareSpeaker_Bureau_Membership_gne method with status setting
*************************************************************/
@isTest
public class GNE_SFA2_Triggers_Test_Util {
	private static Territory2Model terrModel;
    private static Territory2Type terrType;

    public static Id getRecordTypeId(String objectName, String developerName){
        RecordType[] objRecordType = [Select Id, Name, sObjectType from RecordType where developerName =:developerName and sObjectType=:objectName];
        return objRecordType[0].Id;
    }

    public static Account prepareAccountHCO(String name){
        return new Account(Name = name);
    }

    public static Account prepareAccountHCO(String name, Id recordType){
        return new Account(Name = name, RecordTypeId = recordType);
    }

    public static Account prepareAccountHCP(String lastName){
        RecordType hcpRT = Utility.getRecordTypes('Health Care Professional (Prescriber)','Account')[0];
        return new Account(LastName = lastName, RecordTypeId = hcpRT.Id);
    }

    public static AccountShare prepareAccountShareDefault(Id accountId, Id userOrGroupId, Boolean isManualTerritoryAssignment){
        AccountShare acs = new  AccountShare(AccountId = accountId, UserOrGroupId = userOrGroupId);
        if(isManualTerritoryAssignment){
            return acs;
        } else {
            acs.AccountAccessLevel = 'Read';
            acs.OpportunityAccessLevel = 'None';
            return acs;
        }
    }

    public static Account_Plan_vod__c prepareAccount_Plan_vod(Id accountId, String team){
        return new Account_Plan_vod__c(Account_vod__c = accountId,
                                       Team_gne__c    = team
                                      );
    }

    public static Account_Tactic_vod__c prepareAccount_Tactic_vod(Id accountId){
        return new Account_Tactic_vod__c(Account_vod__c = accountId);
    }

    public static Account_Team_gne__c prepareAccount_Team_gne(Id accountId, Id userId){
        return new Account_Team_gne__c( Account_gne__c      = accountId,
                                        Team_Member_gne__c  = userId
                                      );
    }

    public static Address_vod__c prepareAddress_vod(Id accountId, String address, Boolean isActive, String addressName){
        return new Address_vod__c(Account_vod__c     = accountId,
                                  Address_1_gne__c   = address,
                                  Active_Flag_gne__c = isActive,
                                  Name               = addressName
                                 );
    }

    public static Advocacy_Assessment_gne__c prepareAdvocacy_Assessment_gne(){
        return new Advocacy_Assessment_gne__c();
    }

    public static Affiliation_vod__c prepareAffiliation_vod(Id accountFromId, Id contactFromId, Id accountToId, Id contactToId){
        /*****************
        *   You must fill only one From field and one To field.
        *   Sample use would be GNE_SFA2_Triggers_Test_Util.prepareAffiliation_vod(hco.Id, null, null, contact.Id);
        ********************/
        return new Affiliation_vod__c(  From_Account_vod__c = accountFromId,
                                        From_Contact_vod__c = contactFromId,
                                        To_Account_vod__c   = accountToId,
                                        To_Contact_vod__c   = contactToId
                                     );
    }

    public static CADS_Account_Address_Issues_gne__c prepareCADS_Account_Address_Issues_gne(){
        return new CADS_Account_Address_Issues_gne__c();
    }

    public static Call2_vod__c prepareCall2_vod(String salesCollateral){
        /*actually Sales_Collateral_gne__c field is required only if call is completed, but it's better to set it*/
        return new Call2_vod__c(Sales_Collateral_gne__c = salesCollateral);
    }

    public static Call2_vod__c prepareCall2_vod(String accountId, String territory, Date callDate, Boolean isComplited) {
        return new Call2_vod__c(Sales_Collateral_gne__c = 'No Collateral', Account_vod__c= accountId, Territory_vod__c = territory, Call_Date_vod__c = callDate, Completed_gne__c = isComplited);
    }
    
    public static Call2_vod__c prepareCall2_vod(String accountId, String territory, Date callDate, Boolean isComplited, Id territoryId) {
        return new Call2_vod__c(Sales_Collateral_gne__c = 'No Collateral', Account_vod__c= accountId, Territory_vod__c = territory, Territory_Id_gne__c = territoryId, Call_Date_vod__c = callDate, Completed_gne__c = isComplited);
    }

    public static Call2_Detail_vod__c prepareCall2_Detail_vod(Id callId){
        return new Call2_Detail_vod__c(Call2_vod__c = callId);
    }

    public static Call2_Discussion_vod__c prepareCall2_Discussion_vod(Id callId){
        return new Call2_Discussion_vod__c(Call2_vod__c = callId);
    }

    public static Call2_Key_Message_vod__c prepareCall2_Key_Message_vod(Id callId){
        return new Call2_Key_Message_vod__c(Call2_vod__c = callId);
    }

    public static Call2_Sample_vod__c prepareCall2_Sample_vod(Id callId, Integer quantity){
        return new Call2_Sample_vod__c( Call2_vod__c    = callId,
                                        Quantity_vod__c = quantity
                                      );
    }

    public static Change_Request_gne__c prepareChange_Request_gne(){
        return new Change_Request_gne__c();
    }

    public static Contact prepareContact(String lastName){
        return new Contact(LastName = lastName);
    }

    public static Curriculum_Speaker_Bureau_gne__c prepareCurriculum_Speaker_Bureau_gne(Id eventCurriculumId, Id speakerBureauId){
        return new Curriculum_Speaker_Bureau_gne__c(Event_Curriculum_gne__c = eventCurriculumId,
                                                    Speaker_Bureau_gne__c   = speakerBureauId
                                                   );
    }

    public static Event_Attendee_vod__c prepareEvent_Attendee_vod(Id accountId, Id userId, Id contactId, Id medicalEventId){
        /*Note: medicalEventId and ONE of account/user/contact Id is required.
        Sample use: GNE_SFA2_Triggers_Test_Util.prepareEvent_Attendee_vod(null, null, contact.Id, medicalEvent.Id);*/
        return new Event_Attendee_vod__c(Account_vod__c = accountId,
                                         User_vod__c = userId,
                                         Contact_vod__c = contactId,
                                         Medical_Event_vod__c = medicalEventId
                                         );
    }

    public static Event_Curriculum_gne__c prepareEvent_Curriculum_gne(){
        return new Event_Curriculum_gne__c();
    }

    public static Medical_Event_vod__c prepareMedical_Event_vod(Date startDate, Date endDate){
        return new Medical_Event_vod__c(Start_Date_vod__c = startDate,
                                        End_Date_vod__c   = endDate
                                        );
    }

    public static Member_Trainings_gne__c prepareMember_Trainings_gne(Id speakerTrainingId, Id speakerBureauMembershipId){
        return new Member_Trainings_gne__c( Speaker_Training_gne__c             = speakerTrainingId,
                                            Speaker_Bureau_Membership_gne__c    = speakerBureauMembershipId
                                          );
    }

    public static Product_Metrics_vod__c prepareProduct_Metrics_vod(Id accountId){
        return new Product_Metrics_vod__c(Account_vod__c = accountId);
    }

    public static Product_Strategy_vod__c prepareProduct_Strategy_vod(){
        return new Product_Strategy_vod__c();
    }

    public static Product_vod__c prepareProduct_vod(){
        return new Product_vod__c();
    }

    public static Question_gne__c prepareQuestion_gne(Id questionnaireId){
        return new Question_gne__c(Questionnaire_gne__c = questionnaireId);
    }

    public static Questionnaire_gne__c prepareQuestionnaire_gne(Boolean isATLS){
        if(isATLS){
            return new Questionnaire_gne__c(Category_gne__c='ATLS Test');
        }
        return new Questionnaire_gne__c(Category_gne__c='Sales');
    }

    public static Referral_Roster_Detail_gne__c prepareReferral_Roster_Detail_gne(Id referralRosterId){
        return new Referral_Roster_Detail_gne__c(Referral_Roster_gne__c = referralRosterId);
    }

    public static Referral_Roster_gne__c prepareReferral_Roster_gne(){
        return new Referral_Roster_gne__c();
    }

    public static SFASearchStrings_gne__c prepareSFASearchStrings_gne(){
        return new SFASearchStrings_gne__c();
    }

    public static SFA2_Configuration_Object_gne__c prepareSFA2_Configuration_Object_gne(){
        return new SFA2_Configuration_Object_gne__c();
    }

    public static SFA2_User_Preferences_gne__c prepareSFA2_User_Preferences_gne(){
        return new SFA2_User_Preferences_gne__c();
    }

    public static SFA2_UI_Setting_gne__c prepareSFA2_UI_Setting_gne(){
        return new SFA2_UI_Setting_gne__c();
    }

    public static SFA2_View_Config_gne__c prepareSFA2_View_Config(String objType, String pageName, String viewName){
        return new SFA2_View_Config_gne__c(Object_Type_gne__c   = objType,
                                           Page_Name_gne__c     = pageName,
                                           View_Name_gne__c     = viewName
                                          );
    }

    public static Speaker_Bureau_gne__c prepareSpeaker_Bureau_gne(String aprimoBureau){
        return new Speaker_Bureau_gne__c(/*Aprimo_Bureau_ID_gne__c = aprimoBureau*/);
    }

    public static Speaker_Bureau_Membership_gne__c prepareSpeaker_Bureau_Membership_gne(Id speakerBureauId, Id accountId){
        /*Account Id is normally not required, but you have to set this field in order to insert Speaker_Contract_gne__c*/
        return new Speaker_Bureau_Membership_gne__c(Speaker_Bureau_ID_gne__c = speakerBureauId,
                                                    Bureau_Member_gne__c     = accountId
                                                    );
    }

    public static Speaker_Bureau_Membership_gne__c prepareSpeaker_Bureau_Membership_gne(Id speakerBureauId, Id accountId, String status){
        /*Account Id is normally not required, but you have to set this field in order to insert Speaker_Contract_gne__c*/
        return new Speaker_Bureau_Membership_gne__c(Speaker_Bureau_ID_gne__c = speakerBureauId,
                                                    Bureau_Member_gne__c     = accountId,
                                                    Speaker_Status_gne__c	 = status
                                                    );
    }

    public static Speaker_Bureau_Product_gne__c prepareSpeaker_Bureau_Product_gne(Id productId, Id speakerBureauId){
        return new Speaker_Bureau_Product_gne__c(Product_vod_gne__c     = productId,
                                                 Speaker_Bureau_gne__c  = speakerBureauId
                                                );
    }

    public static Speaker_Contract_gne__c prepareSpeaker_Contract_gne(Id accountId, Date endDate){
        /*Note: to be able to insert Speaker_Contract_gne__c you need Speaker_Bureau_Membership_gne__c with account set*/
        return new Speaker_Contract_gne__c( Contracted_Party_ID__c  = accountId,
                                            End_Date_gne__c         = endDate
                                          );
    }

    public static Speaker_Training_gne__c prepareSpeaker_Training_gne(Date trainedDate){
        return new Speaker_Training_gne__c(Trained_Date_gne__c = trainedDate);
    }

    public static Survey_gne__c prepareSurvey_gne(Id questionnaireId){
        return new Survey_gne__c(Questionnaire_gne__c = questionnaireId);
    }

    public static Survey_Response_gne__c prepareSurvey_Response_gne(Id surveyId){
        return new Survey_Response_gne__c(Survey_gne__c = surveyId);
    }

    public static Targets_and_Tiers_can_gne__c prepareTargets_and_Tiers_can_gne(){
        return new Targets_and_Tiers_can_gne__c();
    }

    public static Task prepareTask(Id whatId){
        return new Task(whatId = whatId);
    }

    public static Task_Replica_gne__c prepareTask_Replica_gne(){
        return new Task_Replica_gne__c();
    }

    public static Territory2 prepareTerritory(String name){
        return new Territory2(Name = name,
        	DeveloperName = 'DM_' + name.replaceAll('[|\\,|\\.|\\,||"||\\:|\\~|\\!|\\@|\\#|\\$|\\%|\\^|\\&|\\*|\\-|\\_| |\\+|\\=|\\<|\\>|\\?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ''),
            Territory2ModelId = getTerrModelId(),
            Territory2TypeId = getTerrTypeId(),
            Parent_External_Id_gne__c = 'Root',
            external_id_gne__c = 'Root;'+name
        );
    }
    
    private static Id getTerrModelId() {
    	Id result;
    	if (terrModel == null) {
    		terrModel = [SELECT Id FROM Territory2Model LIMIT 1];
    	}
    	
    	result = terrModel.Id;
    	return result;
    }
    
    private static Id getTerrTypeId() {
    	Id result;
    	if (terrType == null) {
    		terrType = [SELECT Id FROM Territory2Type LIMIT 1];
    	}
    	
    	result = terrType.Id;
    	return result;
    }

    public static Time_off_Territory_Day_gne__c prepareTime_off_Territory_Day_gne(Id timeOffTerritoryId, Date activityDate){
        return new Time_off_Territory_Day_gne__c(Time_Off_Territory_gne__c = timeOffTerritoryId,
                                                 Date_gne__c               = activityDate
                                                );
    }

    public static Time_Off_Territory_gne__c prepareTime_Off_Territory_gne(){
        return new Time_Off_Territory_gne__c();
    }

    public static TSF_vod__c prepareTSF_vod(Id accountId){
        return new TSF_vod__c(Account_vod__c = accountId);
    }


    /*test methods to check if all required fields are filled*/
    private static testMethod void checkIfEverythingWorksPart1(){
        try{
            Account hco = prepareAccountHCO('testName');
            insert hco;
            system.debug('HCO inserted');
            insert prepareAccountHCP('testLastName');
            system.debug('HCP inserted');
            insert prepareSFA2_View_Config('Account', 'My Accounts', 'test');
            system.debug('SFA2_View_Config__c inserted');
            insert prepareSFA2_User_Preferences_gne();
            system.debug('SFA2_User_Preferences_gne__c inserted');
            insert prepareSFA2_UI_Setting_gne();
            system.debug('SFA2_UI_Setting_gne__c inserted');
            Test.startTest();
            system.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]){
                insert prepareTerritory('N1111-NEW YORK CITY');
                system.debug('Territory inserted');
            }
            Test.stopTest();
            Time_Off_Territory_gne__c tot = prepareTime_Off_Territory_gne();
            insert tot;
            system.debug('Time_Off_Territory_gne__c inserted');
            insert prepareTime_off_Territory_Day_gne(tot.Id, Date.today());
            system.debug('Time_off_Territory_Day_gne__c inserted');
            insert prepareTask( hco.Id );
            system.debug('Task inserted');
            insert prepareTask_Replica_gne();
            system.debug('Task_Replica_gne__c inserted');
            insert prepareTSF_vod(hco.Id);
            system.debug('TSF_vod__c inserted');
            insert prepareTargets_and_Tiers_can_gne();
            system.debug('Targets_and_Tiers_can_gne__c inserted');
            insert prepareAddress_vod(hco.Id, '611 Gateway Blvd', true, 'testAddress');
            system.debug('Address_vod__c inserted');
            insert prepareProduct_vod();
            system.debug('Product_vod__c inserted');
        } catch (Exception ex){
            System.assert(false,ex);
        }
    }

    private static testMethod void checkIfEverythingWorksPart2(){
        try{
            Account hco = prepareAccountHCO('testName');
            insert hco;
            system.debug('HCO inserted');
            Product_vod__c product = prepareProduct_vod();
            insert product;
            system.debug('Product_vod__c inserted');
            insert prepareProduct_Strategy_vod();
            system.debug('Product_Strategy_vod__c inserted');
            Speaker_Bureau_gne__c speakerBureau = prepareSpeaker_Bureau_gne('test');
            insert speakerBureau;
            system.debug('Speaker_Bureau_gne__c inserted');
            Event_Curriculum_gne__c eventCurriculum = prepareEvent_Curriculum_gne();
            insert eventCurriculum;
            system.debug('Event_Curriculum_gne__c inserted');
            insert prepareCurriculum_Speaker_Bureau_gne(eventCurriculum.Id, speakerBureau.Id);
            system.debug('Curriculum_Speaker_Bureau_gne__c inserted');
            Speaker_Training_gne__c speakerTraining = prepareSpeaker_Training_gne(Date.today());
            insert speakerTraining;
            system.debug('Speaker_Training_gne__c inserted');
            Speaker_Bureau_Membership_gne__c speakerBureauMembership = prepareSpeaker_Bureau_Membership_gne(speakerBureau.Id, hco.Id, 'Approved');
            insert speakerBureauMembership;
            system.debug('Speaker_Bureau_Membership_gne__c inserted');
            insert prepareMember_Trainings_gne(speakerTraining.Id, speakerBureauMembership.Id);
            system.debug('Member_Trainings_gne__c inserted');
            insert prepareProduct_Metrics_vod(hco.Id);
            system.debug('Product_Metrics_vod__c inserted');
            insert prepareSpeaker_Bureau_Product_gne(product.Id, speakerBureau.Id);
            system.debug('Speaker_Bureau_Product_gne__c inserted');
            insert prepareSpeaker_Contract_gne(hco.Id, Date.today());
            system.debug('Speaker_Contract_gne__c inserted');
        } catch (Exception ex){
            System.assert(false,ex);
        }
    }

    private static testMethod void checkIfEverythingWorksPart3(){
        //try{
            Account hco = prepareAccountHCO('testName');
            insert hco;
            system.debug('HCO inserted');
            Account hcp = prepareAccountHCP('testLastName');
            insert hcp;
            system.debug('HCP inserted');
            insert prepareSFASearchStrings_gne();
            system.debug('SFASearchStrings_gne__c inserted');
            Referral_Roster_gne__c referralRoster = prepareReferral_Roster_gne();
            insert referralRoster;
            system.debug('Referral_Roster_gne__c inserted');
            insert prepareReferral_Roster_Detail_gne(referralRoster.Id);
            system.debug('Referral_Roster_Detail_gne__c inserted');
            insert prepareAccount_Plan_vod(hco.Id, 'testTeam');
            system.debug('Account_Plan_vod__c inserted');
            insert prepareAccount_Tactic_vod(hco.Id);
            system.debug('Account_Tactic_vod__c inserted');
            insert prepareAccount_Team_gne(hco.Id, UserInfo.getUserId());
            system.debug('Account_Team_gne__c inserted');
            insert prepareAffiliation_vod(hco.Id, null, hcp.Id, null);
            system.debug('Affiliation_vod__c inserted');
            insert new GNE_SFA2_DCR_Config_Items_gne__c( Name = 'AddressDcrFields', Value_gne__c = 'Name,City_vod__c,State_vod__c,Zip_vod__c', Key_gne__c = 'AddressDcrFields', Configuration_Type_gne__c = 'Main' );
            insert prepareChange_Request_gne();
            system.debug('Change_Request_gne__c inserted');
            insert prepareAdvocacy_Assessment_gne();
            system.debug('Advocacy_Assessment_gne__c inserted');
            Contact contact = prepareContact('testLastName');
            insert contact;
            system.debug('Contact inserted');
            insert prepareAccountShareDefault(hco.Id, GNE_SFA2_Util.selectSFA2User().Id, false);
            system.debug('AccountShare inserted');
            insert prepareSFA2_Configuration_Object_gne();
            system.debug('SFA2_Configuration_Object_gne__c inserted');
            Medical_Event_vod__c me = prepareMedical_Event_vod(Date.today()-1, Date.today()+1);
            insert me;
            system.debug('Medical_Event_vod__c inserted');
            insert prepareEvent_Attendee_vod(hco.Id, null, null, me.Id);
            system.debug('Event_Attendee_vod__c with accountId inserted');
            insert prepareEvent_Attendee_vod(null, UserInfo.getUserId(), null, me.Id);
            system.debug('Event_Attendee_vod__c with userId inserted');
            insert prepareEvent_Attendee_vod(null, null, contact.Id, me.Id);
            system.debug('Event_Attendee_vod__c with contactId inserted');
            try{
                insert prepareEvent_Attendee_vod(hco.Id, UserInfo.getUserId(), contact.Id, me.Id);
                system.debug('Event_Attendee_vod__c with contactId inserted');
                system.assert(false, 'it shouldn\'t succeed');
            } catch(Exception ex){
            }
        //} catch (Exception ex){
        //    System.assert(false,ex);
        //}
    }

    private static testMethod void checkIfEverythingWorksPart4(){
        try{
            Call2_vod__c call = prepareCall2_vod('No Collateral');
            insert call;
            system.debug('Call2_vod__c inserted');
            insert prepareCall2_Key_Message_vod(call.Id);
            system.debug('Call2_Key_Message_vod__c inserted');
            insert prepareCall2_Discussion_vod(call.Id);
            system.debug('Call2_Discussion_vod__c inserted');
            insert prepareCall2_Detail_vod(call.Id);
            system.debug('Call2_Detail_vod__c inserted');
            insert prepareCall2_Sample_vod(call.Id, 7);
            system.debug('Call2_Sample_vod__c inserted');
        } catch (Exception ex){
            System.assert(false,ex);
        }
    }

    private static testMethod void checkIfEverythingWorksPart5(){
        try{
            Questionnaire_gne__c questionnaire = prepareQuestionnaire_gne(true);
            insert questionnaire;
            system.debug('Questionnaire_gne__c inserted');
            Survey_gne__c survey = prepareSurvey_gne(questionnaire.Id);
            insert survey;
            system.debug('Survey_gne__c inserted');
            insert prepareQuestion_gne(questionnaire.Id);
            system.debug('Question_gne__c inserted');
            insert prepareSurvey_Response_gne(survey.Id);
            system.debug('Survey_Response_gne__c inserted');
            insert prepareCADS_Account_Address_Issues_gne();
            system.debug('CADS_Account_Address_Issues_gne__c inserted');
        } catch (Exception ex){
            System.assert(false,ex);
        }
    }

    public static User createUser(String name, Profile p) {
        User usr = new User(
            Alias = name.substring(0, 8),
            Email = name + '@test.gene.com',
            Username = name + '@test.gne_sfa2.dev',
            FirstName = 'Testy',
            LastName = name,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'GMT',
            ProfileId = p.Id
        );
        insert usr;
        return usr;
    }

    public static User createUser(String userName, String profile) {
    	Profile p = [SELECT id FROM Profile WHERE name = :profile];
    	return createUser(userName, p);
    }
}