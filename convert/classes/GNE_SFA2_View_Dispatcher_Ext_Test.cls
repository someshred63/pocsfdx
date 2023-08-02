/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-07-29 
*  This is a test class for GNE_SFA2_View_Dispatcher_Ext
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_View_Dispatcher_Ext_Test {

	public static testMethod void testAccessDenied() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pr);
		User u = selectUser('GNE_TISL_USER');
		system.assertNotEquals(null, u);
		System.runAs(u){
			GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(acc));
			insert new GNE_SFA2_User_App_Context_gne__c(Name = u.Id, SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = u.Id);
			pr = controller.doRedirect();
			system.assertEquals(true, pr.getRedirect());
			system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Access_Denied'), pr.getUrl());
		}
	}

	public static testMethod void testAccountRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(acc));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account') || pr.getUrl().contains('/apex/GNE_SFA2_Account_Layout'), pr.getUrl());
	}

	public static testMethod void testPersonAccountRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Account Last Name');
		insert acc;
		acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :acc.Id LIMIT 1];
		Contact cont = [SELECT Id FROM Contact WHERE Id = :acc.PersonContactId LIMIT 1];
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', cont.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(cont));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account_Layout'), pr.getUrl());
		system.assertEquals(acc.Id, pr.getParameters().get('id'));
	}

	public static testMethod void testContactRedirection() {
		Contact cont = GNE_SFA2_Triggers_Test_Util.prepareContact('Last Name');
		insert cont;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', cont.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(cont));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Contact_Layout'), pr.getUrl());
	}

	public static testMethod void testAddressRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Name');
		insert acc;
		Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(acc.Id, 'address', true, 'addressName');
		insert addr;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', addr.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(addr));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Address_Layout'), pr.getUrl());
	}

	public static testMethod void testChangeRequestRedirection() {
		insert new GNE_SFA2_DCR_Config_Items_gne__c( Name = 'AddressDcrFields', Value_gne__c = 'Name,City_vod__c,State_vod__c,Zip_vod__c', Key_gne__c = 'AddressDcrFields', Configuration_Type_gne__c = 'Main' );
		Change_Request_gne__c cr = GNE_SFA2_Triggers_Test_Util.prepareChange_Request_gne();
		insert cr;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', cr.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(cr));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_DCR_Layout'), pr.getUrl());
	}

	public static testMethod void testIssueRedirection() {
		Issue_gne__c issue = new Issue_gne__c();
		insert issue;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', issue.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(issue));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_IRF_Layout'), pr.getUrl());
	}

	public static testMethod void testToTRedirection() {
		Time_Off_Territory_gne__c tot = GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne();
		insert tot;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', tot.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(tot));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_ToT_Layout'), pr.getUrl());
	}

	public static testMethod void testIRFCaseRedirection() {
		IRF_Case_gne__c irf = new IRF_Case_gne__c();
		insert irf;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', irf.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(irf));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_IRF_Case_Layout'), pr.getUrl());
	}

	public static testMethod void testAffiliationRedirection() {
		List<Account> accs = new List<Account>();
		accs.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Name'));
		accs.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Name2'));
		insert accs;
		Affiliation_vod__c aff = GNE_SFA2_Triggers_Test_Util.prepareAffiliation_vod(accs[0].Id, null, accs[1].Id, null);
		insert aff;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', aff.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(aff));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Affiliation_Layout'), pr.getUrl());
	}

	public static testMethod void testAccountPlanRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		Account_Plan_vod__c ap = GNE_SFA2_Triggers_Test_Util.prepareAccount_Plan_vod(acc.Id, 'team');
		insert ap;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', ap.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(ap));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account_Plan_Layout'), pr.getUrl());
	}

	public static testMethod void testAccountTeamRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		Account_Team_gne__c at = GNE_SFA2_Triggers_Test_Util.prepareAccount_Team_gne(acc.Id, UserInfo.getUserId());
		insert at;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', at.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(at));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account_Team_Layout'), pr.getUrl());
	}

	public static testMethod void testEducationalBackgroundRedirection() {
		Educational_Background_gne__c eb = new Educational_Background_gne__c();
		insert eb;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', eb.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(eb));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Edu_Backgnd_Layout'), pr.getUrl());
	}

	public static testMethod void testQualificationsCapabilitiesAssessRedirection() {
		Qualifications_Capabilities_Assess_gne__c qca = new Qualifications_Capabilities_Assess_gne__c();
		insert qca;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', qca.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(qca));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Qualif_Capab_Layout'), pr.getUrl());
	}

	public static testMethod void testAdvocacyAssessmentRedirection() {
		Advocacy_Assessment_gne__c aa = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
		insert aa;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', aa.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(aa));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Advoc_Assess_Layout'), pr.getUrl());
	}

	public static testMethod void testTSFRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		TSF_vod__c tsf = GNE_SFA2_Triggers_Test_Util.prepareTSF_vod(acc.Id);
		insert tsf;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', tsf.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(tsf));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_TSF_Layout'), pr.getUrl());
	}

	public static testMethod void testProfileIDLicenseRedirection(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		ProfileID_License_gne__c pil = new ProfileID_License_gne__c(Account_Name_gne__c = acc.Id);
		insert pil;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', pil.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(pil));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_PID_License_Layout'), pr.getUrl());
	}

	public static testMethod void testQuestionnaireBureauRedirection(){
		Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		insert q;
		Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('aprimoBureau');
		insert sb;
		QuestionnaireBureau_gne__c qb = new QuestionnaireBureau_gne__c(Questionnaire_gne__c = q.Id, Speaker_Bureau_gne__c = sb.Id);
		insert qb;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', qb.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(qb));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_BCoverage_Layout'), pr.getUrl());
	}

	public static testMethod void testCurriculumModuleRedirection() {
		Curriculum_Module_gne__c cm = new Curriculum_Module_gne__c(Aprimo_ID_gne__c = 'test');
		insert cm;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', cm.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(cm));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_CModule_Layout'), pr.getUrl());
	}

	public static testMethod void testProductRedirection() {
		Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
		insert prod;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', prod.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(prod));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_PCatalog_Layout'), pr.getUrl());
	}

	public static testMethod void testProductStrategyRedirection() {
		Product_Strategy_vod__c ps = GNE_SFA2_Triggers_Test_Util.prepareProduct_Strategy_vod();
		insert ps;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', ps.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(ps));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_PStrategy_Layout'), pr.getUrl());
	}

	public static testMethod void testProductTacticRedirection() {
		Product_Tactic_vod__c pt = new Product_Tactic_vod__c();
		insert pt;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', pt.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(pt));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_PTactics_Layout'), pr.getUrl());
	}

	public static testMethod void testProductPlanRedirection() {
		Product_Plan_vod__c pp = new Product_Plan_vod__c();
		insert pp;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', pp.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(pp));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Product_Plan_Layout'), pr.getUrl());
	}

	public static testMethod void testSpeakerBureauProductRedirection() {
		Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
		insert prod;
		Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('aprimoBureau');
		insert sb;
		Speaker_Bureau_Product_gne__c sbp = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Product_gne(prod.Id, sb.Id);
		insert sbp;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', sbp.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(sbp));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_ProductTeam_layout'), pr.getUrl());
	}

	public static testMethod void testMembershipContractsRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
        insert acc;
        Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
        insert prod;
        Product_Metrics_vod__c pm = GNE_SFA2_Triggers_Test_Util.prepareProduct_Metrics_vod(acc.Id);
        pm.Products_vod__c = prod.Id;
        insert pm;
        Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('test');
        insert sb;
        Speaker_Bureau_Membership_gne__c sbm = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Membership_gne(sb.Id, acc.Id,'Pending');
        insert sbm;
        Speaker_Bureau_Product_gne__c sbp = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Product_gne(prod.Id, sb.Id);
        insert sbp;
        Speaker_Contract_gne__c sc = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Contract_gne(acc.Id, Date.today());
        insert sc;

		Membership_Contracts_gne__c mc = new Membership_Contracts_gne__c(Speaker_Contract_gne__c = sc.Id);
		insert mc;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', mc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(mc));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_MContract_Layout'), pr.getUrl());
	}

	public static testMethod void testSpeakerContractLineItemRedirection() {
		Speaker_Contract_Line_Item_gne__c scli = new Speaker_Contract_Line_Item_gne__c();
		insert scli;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', scli.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(scli));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_SC_Line_Item_Layout'), pr.getUrl());
	}

	public static testMethod void testEventBureausRedirection() {
		Medical_Event_vod__c med = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
        med.Event_Type_gne__c='test';
        Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('testId');
        sb.Name = 'test';
        insert med;
        insert sb;

		Event_Bureaus_gne__c eb = new Event_Bureaus_gne__c(Medical_Event_gne__c = med.Id,Speaker_Bureau_gne__c=sb.Id);
		insert eb;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', eb.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(eb));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_EBureau_Layout'), pr.getUrl());
	}

	public static testMethod void testProductMetricsRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
        insert acc;
        Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
        insert prod;
        
        Product_Metrics_vod__c pm = GNE_SFA2_Triggers_Test_Util.prepareProduct_Metrics_vod(acc.Id);
        pm.Products_vod__c = prod.Id;
        insert pm;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', pm.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(pm));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Brand_Aff_Layout'), pr.getUrl());
	}

	public static testMethod void testEventAttendeeRedirection() {
		Medical_Event_vod__c med = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
        med.Event_Type_gne__c='test';
        insert med;
		Event_Attendee_vod__c ea = GNE_SFA2_Triggers_Test_Util.prepareEvent_Attendee_vod(null, UserInfo.getUserId(), null, med.Id);
		insert ea;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', ea.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(ea));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_EventAttendee_Layout'), pr.getUrl());
	}

	public static testMethod void testSpeakerTrainingRedirection() {
		Speaker_Training_gne__c st = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Training_gne(Date.today());
		insert st;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', st.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(st));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_STraining_Layout'), pr.getUrl());
	}

	public static testMethod void testCurriculumSpeakerBureauRedirection() {
		Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('aprimoBureau');
		insert sb;
		Event_Curriculum_gne__c ec = GNE_SFA2_Triggers_Test_Util.prepareEvent_Curriculum_gne();
		insert ec;
		Curriculum_Speaker_Bureau_gne__c csb = GNE_SFA2_Triggers_Test_Util.prepareCurriculum_Speaker_Bureau_gne(ec.Id, sb.Id);
		insert csb;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', csb.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(csb));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_SBCurriculum_Layout'), pr.getUrl());
	}

	public static testMethod void testSpeakerBureauMembershipRedirection() {
		Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('aprimoBureau');
		insert sb;
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		Speaker_Bureau_Membership_gne__c sbm = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Membership_gne(sb.Id, acc.Id,'Pending');
		insert sbm;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', sbm.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(sbm));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_SBMembership_Layout'), pr.getUrl());
	}

	public static testMethod void testEventCurriculumRedirection() {
		Event_Curriculum_gne__c ec = GNE_SFA2_Triggers_Test_Util.prepareEvent_Curriculum_gne();
		insert ec;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', ec.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(ec));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_EventCurclmBureau_Layout'), pr.getUrl());
	}

	public static testMethod void testEventCurriculumJoinRedirection() {
		Event_Curriculum_Join_gne__c ecj = new Event_Curriculum_Join_gne__c();
		insert ecj;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', ecj.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(ecj));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_ECurriculum_Layout'), pr.getUrl());
	}

	public static testMethod void testSpeakerBureauRedirection() {
		Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('aprimoBureau');
		insert sb;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', sb.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(sb));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_SpeakerBureau'), pr.getUrl());
	}

	public static testMethod void testMemberTrainingsRedirection() {
		Speaker_Training_gne__c st = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Training_gne(Date.today());
		insert st;
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('aprimoBureau');
		insert sb;
		Speaker_Bureau_Membership_gne__c sbm = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Membership_gne(sb.Id, acc.Id,'Pending');
		insert sbm;
		Member_Trainings_gne__c mt = GNE_SFA2_Triggers_Test_Util.prepareMember_Trainings_gne(st.Id, sbm.Id);
		insert mt;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', mt.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(mt));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Membership_Training_Layout'), pr.getUrl());
	}

	public static testMethod void testMedicalEventRedirection() {
		Medical_Event_vod__c med = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
        med.Event_Type_gne__c='test';
        insert med;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', med.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(med));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_MedicalEvent_Layout'), pr.getUrl());
	}

	public static testMethod void testAccountExternalIdRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_External_Id_gne__c aei = new Account_External_Id_gne__c(Account_gne__c = acc.Id);
		insert aei;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', aei.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(aei));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Acc_Ext_Id_Layout'), pr.getUrl());
	}

	public static testMethod void testTaskRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
        Task t = GNE_SFA2_Triggers_Test_Util.prepareTask( acc.Id );
        insert t;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', t.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(t));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Task_Layout'), pr.getUrl());
	}

	public static testMethod void testSurveyRedirection() {
		Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		insert q;
		Survey_gne__c sur = GNE_SFA2_Triggers_Test_Util.prepareSurvey_gne(q.Id);
		insert sur;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', sur.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(sur));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Edit_Survey_Layout'), pr.getUrl());
	}

	public static testMethod void testQuestionnaireRedirection() {
		Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		insert q;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', q.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(q));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Questionnaire_Layout'), pr.getUrl());
	}

	public static testMethod void testKeyMessageRedirection() {
		Key_Message_vod__c key = new Key_Message_vod__c();
		insert key;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', key.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(key));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Key_Message_Layout'), pr.getUrl());
	}

	public static testMethod void testCADSAccountAddressIssuesRedirection() {
		CADS_Account_Address_Issues_gne__c adi = new CADS_Account_Address_Issues_gne__c();
		insert adi;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', adi.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(adi));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_CADS_Issue_Layout'), pr.getUrl());
	}

	public static testMethod void testReferralAssignmentRedirection() {
		Referral_Assignment_gne__c ra = new Referral_Assignment_gne__c();
		insert ra;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', ra.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(ra));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Referral_Layout'), pr.getUrl());
	}

	public static testMethod void testToTDayRedirection() {
		Time_Off_Territory_gne__c tot = GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne();
		insert tot;
		Time_off_Territory_Day_gne__c totD = GNE_SFA2_Triggers_Test_Util.prepareTime_off_Territory_Day_gne(tot.Id, Date.today());
		insert totD;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', totD.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(totD));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_ToT_Day_Layout'), pr.getUrl());
	}

	public static testMethod void testARTSiteRedirection() {
		ART_Site_gne__c artS = new ART_Site_gne__c();
		insert artS;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', artS.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(artS));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_ART_Site_Layout'), pr.getUrl());
	}

	public static testMethod void testARTIssueRedirection() {
		ART_Site_gne__c artS = new ART_Site_gne__c();
		insert artS;
		ART_Issue_gne__c ai = new ART_Issue_gne__c(Name ='test', ART_Site_Local_gne__c = artS.Id);
		insert ai;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', ai.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(ai));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_ART_Issue_Layout'), pr.getUrl());
	}

	public static testMethod void testARTTeamRedirection() {
		ART_Site_gne__c artS = new ART_Site_gne__c();
		insert artS;
		ART_Team_gne__c artT = new ART_Team_gne__c(ART_Site_gne__c = artS.Id);
		insert artT;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', artT.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(artT));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_ART_Team_Layout'), pr.getUrl());
	}

	public static testMethod void testAccountGoalAndObjectiveRedirection() {
		Account_Goal_and_Objective_gne__c ago = new Account_Goal_and_Objective_gne__c();
		insert ago;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', ago.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(ago));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account_Goal_Layout'), pr.getUrl());
	}

	public static testMethod void testAccountProductObjectiveRedirection() {
		Account_Product_Objective_gne__c apo = new Account_Product_Objective_gne__c();
		insert apo;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', apo.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(apo));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account_Product_Layout'), pr.getUrl());
	}

	public static testMethod void testAccountTacticRedirection() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		Account_Tactic_vod__c accT = GNE_SFA2_Triggers_Test_Util.prepareAccount_Tactic_vod(acc.Id);
		insert accT;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', accT.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(accT));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account_Tactic_Layout'), pr.getUrl());
	}

	public static testMethod void testQuestionRedirection() {
		Questionnaire_gne__c quest = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		insert quest;
		Question_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestion_gne(quest.Id);
		insert q;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', q.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(q));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Question_Layout'), pr.getUrl());
	}

	public static testMethod void testQuestionnaireAccountRedirection() {
		QuestionnaireAccount_gne__c qa = new QuestionnaireAccount_gne__c();
		insert qa;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', qa.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(qa));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Questionnaire_Account_Layout'), pr.getUrl());
	}

	public static testMethod void testMedicalCommunicationRedirection() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		insert mc;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', mc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(mc));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Med_Comm_Layout'), pr.getUrl());
	}

	public static testMethod void testCall2DiscussionRedirection() {
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		insert call;
		Call2_Discussion_vod__c cd = GNE_SFA2_Triggers_Test_Util.prepareCall2_Discussion_vod(call.Id);
		insert cd;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', cd.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(cd));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Interaction_Layout'), pr.getUrl());
		system.assertEquals(call.Id, pr.getParameters().get('id'));
	}

	public static testMethod void testCall2DetailRedirection() {
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		insert call;
		Call2_Detail_vod__c cd = GNE_SFA2_Triggers_Test_Util.prepareCall2_Detail_vod(call.Id);
		insert cd;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', cd.Id);
		pr.getParameters().put('editMode','true');
		pr.getParameters().put('test','param');
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(cd));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Interaction_Edit_Create'), pr.getUrl());
		system.assertEquals(call.Id, pr.getParameters().get('id'));
		system.assertEquals(null, pr.getParameters().get('editMode'));
		system.assertEquals('param', pr.getParameters().get('test'));

		pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', cd.Id);
		pr.getParameters().put('editMode','false');
		pr.getParameters().put('test','param');
		Test.setCurrentPage(pr);
		controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(cd));
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Interaction_Layout'), pr.getUrl());
		system.assertEquals(call.Id, pr.getParameters().get('id'));
		system.assertEquals(null, pr.getParameters().get('editMode'));
		system.assertEquals(null, pr.getParameters().get('test'));
	}      

	public static testMethod void testCall2Redirection() {
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		insert call;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', call.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(call));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Interaction_Layout'), pr.getUrl());
	}

	public static testMethod void testCopayCardRedirection() {
		Copay_Card_gne__c cc = new Copay_Card_gne__c(Card_Number_gne__c = '1');
		insert cc;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', cc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(cc));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_CopayCard_Layout'), pr.getUrl());
	}

	public static testMethod void testCommentRedirection() {
		Contact cont = GNE_SFA2_Triggers_Test_Util.prepareContact('lastName');
		insert cont;
		Comment_gne__c c = new Comment_gne__c(Contact_gne__c = cont.Id);
		insert c;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', c.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(c));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Comment_Layout'), pr.getUrl());
	}

	public static testMethod void testTumorBoardRedirection() {
		Tumor_Board_gne__c tb = new Tumor_Board_gne__c();
		insert tb;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', tb.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(tb));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Tumor_Board_Layout'), pr.getUrl());
	}
	
	public static testMethod void testBenefitDesignRedirection() {
		Benefit_Design_vod__c bd = new Benefit_Design_vod__c();
		insert bd;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', bd.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(bd));
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true, SetupOwnerId = UserInfo.getUserId());
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Benefit_Design_Layout'), pr.getUrl());
	}

	public static testMethod void testChangeRequestNotSFA2Redirection() {
		insert new GNE_SFA2_DCR_Config_Items_gne__c( Name = 'AddressDcrFields', Value_gne__c = 'Name,City_vod__c,State_vod__c,Zip_vod__c', Key_gne__c = 'AddressDcrFields', Configuration_Type_gne__c = 'Main' );
		Change_Request_gne__c cr = GNE_SFA2_Triggers_Test_Util.prepareChange_Request_gne();
		insert cr;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', cr.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(cr));
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNEViewDCR'), pr.getUrl());
		system.assertEquals(cr.Id, pr.getParameters().get('id'));
	}

	public static testMethod void testCADSAccountAddressIssuesNotSFA2Redirection() {
		CADS_Account_Address_Issues_gne__c adi = new CADS_Account_Address_Issues_gne__c();
		insert adi;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', adi.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(adi));
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/CADS_Account_Address_Issues_View'), pr.getUrl());
	}

	public static testMethod void testReferralAssignmentNotSFA2Redirection() {
		Referral_Assignment_gne__c ra = new Referral_Assignment_gne__c();
		insert ra;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', ra.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(ra));
		pr = controller.doRedirect();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_ViewReferralPage'), pr.getUrl());
	}

	public static testMethod void testCall2NotSFA2Redirection() {
		User u = selectUser('GNE-CM-%');
		system.assertNotEquals(null, u);
		System.runAs(u){
			Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
			insert call;
			PageReference pr = Page.GNE_SFA2_AACharts;
			pr.getParameters().put('id', call.Id);
			Test.setCurrentPage(pr);
			GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(call));
			pr = controller.doRedirect();
			system.assertEquals(true, pr.getRedirect());
			system.assert(pr.getUrl().contains('/apex/AGS_Interaction_Details_gne'), pr.getUrl());
			system.assertEquals(call.Id, pr.getParameters().get('id'));
		}
	}

	public static testMethod void testRedirectionToStandardLayout() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_View_Dispatcher_Ext controller = new GNE_SFA2_View_Dispatcher_Ext(new ApexPages.StandardController(acc));
		pr = controller.doRedirect();		
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account'));
		system.assertEquals('1', pr.getParameters().get('sfdc.override'));

		GNE_SFA2_Account_Ctrl accController = new GNE_SFA2_Account_Ctrl(new ApexPages.StandardController(acc));
		pr = accController.getDispatcherOtherPage();
		System.assertEquals(false, accController.pageDispatcher());
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('/'+acc.Id), pr.getUrl());
		system.assertEquals('1', pr.getParameters().get('nooverride'));
	}
		
	private static User selectUser(String profileNameLike){
		List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name Like :profileNameLike];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
            List<User> sfa2Users = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true ];
            if(sfa2Users != null && sfa2Users.size() > 0) {
                return sfa2Users[0];
            }
        }
        return null;
	}

}