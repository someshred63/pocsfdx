/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-08-27
*  This is a test class for multiple classes with similiar construction, e.g. controllers
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_TestCoverage_Helper_Part1 {
	
	/*public static testMethod void testEmptyClasses() {
		new GNE_SFA2_Account_Delete_Child_Records();
		new GNE_SFA2_Acct_Plan_Email_Notifications();
		new GNE_SFA2_Acct_Plan_Field_Updates();
		new GNE_SFA2_Acct_Tactic_Email_Notifications();
		new GNE_SFA2_Acct_Tactic_Field_Updates();
		new GNE_SFA2_Acct_Tactic_Validation_Rules();
		new GNE_SFA2_Acct_Team_Email_Notification();
		new GNE_SFA2_Acct_Team_Field_Updates();
		new GNE_SFA2_Acct_Team_Validation_Rules();
		new GNE_SFA2_Address_Email_Notifications();
		new GNE_SFA2_Affiliation_Email_Notifications();
		new GNE_SFA2_ART_Issue_Child_Record_Updates();
		new GNE_SFA2_ART_Issue_Email_Notifications();
		new GNE_SFA2_ART_Site_Email_Notifications();
		new GNE_SFA2_ART_Site_Field_Updates();
		new GNE_SFA2_ART_Site_Validation_Rules();
		new GNE_SFA2_ART_Team_Email_Notifications();
		new GNE_SFA2_ART_Team_Field_Updates();
		new GNE_SFA2_ART_Team_Validation_Rules();
		new GNE_SFA2_Brand_Affil_Child_Record_Update();
		new GNE_SFA2_Brand_Affil_Email_Notifications();
		new GNE_SFA2_Brand_Affil_Validation_Rules();
		new GNE_SFA2_Call_Detail_Child_Record_Update();
		new GNE_SFA2_Call_Detail_Email_Notifications();
		new GNE_SFA2_Call_Detail_Field_Updates();
		new GNE_SFA2_Call_K_M_Child_Record_Updates();
		new GNE_SFA2_Call_K_M_Email_Notifications();
		new GNE_SFA2_Call_Key_Message_Trigger();
		new GNE_SFA2_Call_Sample_Field_Updates();
		new GNE_SFA2_Contact_Email_Notifications();
		new GNE_SFA2_IRF_Child_Record_Updates();
		new GNE_SFA2_IRF_Email_Notifications();
		new GNE_SFA2_IRF_Trigger_Helper();
		new GNE_SFA2_IRF_Validation_Rules();
		new GNE_SFA2_MedComm_Child_Record_Updates();
		new GNE_SFA2_MedComm_Email_Notifications();
		new GNE_SFA2_Prod_Strategy_Child_Record_Updt();
		new GNE_SFA2_Prod_Strategy_Email_Notif();
		new GNE_SFA2_Prod_Strategy_Field_Updates();
		new GNE_SFA2_Prod_Tactic_Child_Record_Update();
		new GNE_SFA2_Prod_Tactic_Email_Notifications();
		new GNE_SFA2_Prod_Tactic_Field_Updates();
		new GNE_SFA2_Product_Child_Record_Updates();
		new GNE_SFA2_Product_Email_Notifications();
		new GNE_SFA2_Product_Plan_Child_Record_Updat();
		new GNE_SFA2_Product_Plan_Email_Notification();
		new GNE_SFA2_Product_Plan_Field_Updates();
		new GNE_SFA2_Questionnaire_Email_Notif();
		new GNE_SFA2_Questionnaire_Field_Updates();
		new GNE_SFA2_Questionnaire_Validation_Rules();
		new GNE_SFA2_ToT_Day_Validation_Rules();
		new GNE_SFA2_ToT_Email_Notifications();
		new GNE_SFA2_ToT_Validation_Rules();
		new GNE_SFA2_TSF_Child_Record_Updates();
		new GNE_SFA2_TSF_Email_Notifications();
		new GNE_SFA2_TSF_Validation_Rules();
	}*/

	public static testMethod void testClassesWithConstructorOnly(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		PageReference pr = Page.GNE_SFA2_BCoverage_Layout;
		pr.getParameters().put('objectId',acc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_SpeakerTraining_list_Ctlr stlController = new GNE_SFA2_SpeakerTraining_list_Ctlr();
		system.assertNotEquals(null, stlController.thisController);
		new GNE_SFA2_TSF_Edit_Create_Ctrl(new ApexPages.StandardController(GNE_SFA2_Triggers_Test_Util.prepareTSF_vod(acc.Id)));
		new GNE_SFA2_ToT_Edit_Create_Ext(new ApexPages.StandardController(GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne()));
		new GNE_SFA2_Account_Goal_Edit_Create_Ext(new ApexPages.StandardController(new Account_Goal_and_Objective_gne__c()));
		new GNE_SFA2_Account_Plan_Edit_Create_Ext(new ApexPages.StandardController(GNE_SFA2_Triggers_Test_Util.prepareAccount_Plan_vod(acc.Id, 'team name')));
		new GNE_SFA2_Account_Prod_Edit_Create_Ext(new ApexPages.StandardController(new Account_Product_Objective_gne__c()));
		QuestionnaireBureau_gne__c qb = new QuestionnaireBureau_gne__c();
		Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('aprimoBureau');
		insert sb;
		pr = Page.GNE_SFA2_BCoverage_Layout;
		pr.getParameters().put('objectId',sb.Id);
		Test.setCurrentPage(pr);
		new GNE_SFA2_BCoverage_Edit_Create_Ctrl(new ApexPages.StandardController(qb));

		pr = Page.GNE_SFA2_Benefit_Design_Layout;
		pr.getParameters().put('objectId',acc.Id);
		pr.getParameters().put('br_id',sb.Id);
		Test.setCurrentPage(pr);
		new GNE_SFA2_Benefit_Design_Edit_Create_Ext(new ApexPages.StandardController(new Benefit_Design_vod__c()));
		new GNE_SFA2_Brand_Aff_Edit_Create_Ext(new ApexPages.StandardController(new Product_Metrics_vod__c()));
		new GNE_SFA2_Calendar_Item(acc.Id, 'itemDate', 'itemDescription');
		new GNE_SFA2_CModule_Edit_Create_Ctrl(new ApexPages.StandardController(new Curriculum_Module_gne__c()));
		new GNE_SFA2_Comment_Edit_Create_Ext(new ApexPages.StandardController(new Comment_gne__c()));
		system.assertEquals( 0, (new GNE_SFA2_DCR_Controller().getRecords()).size() );
		system.assertEquals(null, new GNE_SFA2_Speaker_Contract_Controller().newClick());
		system.assertEquals(null, new GNE_SFA2_SBureau_Membership_Ctrl().newClick());
		new GNE_SFA2_Tumor_Board_Edit_Create_Ext(new ApexPages.StandardController(new Tumor_Board_gne__c()));
		new GNE_SFA2_STraining_Edit_Create_Ctrl(new ApexPages.StandardController(new Speaker_Training_gne__c()));
		new GNE_SFA2_SContract_Edit_Create_Ctrl(new ApexPages.StandardController(new Speaker_Contract_gne__c()));
		new GNE_SFA2_SC_Line_Item_Edit_Create_Ctrl(new ApexPages.StandardController(new Speaker_Contract_Line_Item_gne__c()));
		new GNE_SFA2_SBureau_Edit_Create_Ctrl(new ApexPages.StandardController(new Speaker_Bureau_gne__c()));
		new GNE_SFA2_SB_Membership_Edit_Create_Ctrl(new ApexPages.StandardController(new Speaker_Bureau_Membership_gne__c()));
		GNE_SFA2_Qstnr_Help_Controller qstnrHC = new GNE_SFA2_Qstnr_Help_Controller();
		system.assertEquals('',qstnrHC.helpText);
		new GNE_SFA2_Qstnr_Acc_Edit_Create_Ext(new ApexPages.StandardController(new QuestionnaireAccount_gne__c()));
		new GNE_SFA2_Qstner_Acc_Edit_Create_Ext(new ApexPages.StandardController(new QuestionnaireAccount_gne__c()));
		new GNE_SFA2_PTactics_Edit_Create_Ctrl(new ApexPages.StandardController(new Product_Tactic_vod__c()));
		new GNE_SFA2_PStrategy_Edit_Create_Ctrl(new ApexPages.StandardController(new Product_Strategy_vod__c()));
		GNE_SFA2_ProductTeam_list_Ctlr productTeamCtrl = new GNE_SFA2_ProductTeam_list_Ctlr();
		system.assertNotEquals(null, productTeamCtrl.thisController);
		new GNE_SFA2_ProductTeam_Edit_Create_Ctrl(new ApexPages.StandardController(new Speaker_Bureau_Product_gne__c()));
		new GNE_SFA2_ProductOrder_Edit_Create_Ctrl(new ApexPages.StandardController(new Product_Order_gne__c()));
		system.assertEquals('/apex/GNE_SFA2_PCatalog', new GNE_SFA2_ProductCatalog_list_Ctlr().newClick().getParameters().get('retURL'));
		new GNE_SFA2_Product_Plan_Edit_Create_Ctrl(new ApexPages.StandardController(new Product_Plan_vod__c()));
		system.assertEquals('/apex/GNE_SFA2_Product_Plans', new GNE_SFA2_Product_Plans_Controller().newClick().getParameters().get('retURL'));

		GNE_SFA2_PROSPECT_MyEvents_Controller prospEv = new GNE_SFA2_PROSPECT_MyEvents_Controller();
		system.assertNotEquals(null, prospEv.thisController);
		GNE_SFA2_PROSPECT_MyLocations_Controller prospEvLoc = new GNE_SFA2_PROSPECT_MyLocations_Controller();
		system.assertNotEquals(null, prospEvLoc.thisController);
		GNE_SFA2_PROSPECT_MySponsors_Controller prospSponsor = new GNE_SFA2_PROSPECT_MySponsors_Controller();
		system.assertNotEquals(null, prospSponsor.thisController);


		//ApexPages.currentPage().getParameters().put('retUrl', '/apex/GNE_SFA2_PROSPECT_Event_Edit_Create');
		//system.assert(new GNE_SFA2_PROSPECT_Location_EditCreateExt(new ApexPages.StandardController(new CONGA_Event_Location_gne__c())).saveClick().getUrl().contains('/apex/GNE_SFA2_PROSPECT_Event_Edit_Create'));
		//system.assert(new GNE_SFA2_PROSPECT_Sponsor_EditCreate_Ext(new ApexPages.StandardController(new CONGA_Sponsor_gne__c())).saveClick().getUrl().contains('/apex/GNE_SFA2_PROSPECT_Event_Edit_Create'));
		//system.assert(new GNE_SFA2_PROSPECT_Event_Edit_Create_Ext(new ApexPages.StandardController(new CONGA_Event_gne__c())).saveClick().getUrl().contains('/apex/GNE_SFA2_PROSPECT_Event_Edit_Create'));
	}

	public static testMethod void testStandardExtClass(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test acc');
		insert acc;
		Product_Metrics_vod__c prodM = GNE_SFA2_Triggers_Test_Util.prepareProduct_Metrics_vod(acc.Id);
		insert prodM;
		Product_vod__c product = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
		insert product;
		
		Benefit_Design_vod__c bd = new Benefit_Design_vod__c();
		insert bd;
		GNE_SFA2_Benefit_Design_Ext bdExt = new GNE_SFA2_Benefit_Design_Ext(new ApexPages.StandardController(bd));
		PageReference pr = bdExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(bd.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Benefit_Dsgn_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());
		
		Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		insert q;
		Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('aprimoBureau');
		insert sb;
		Speaker_Bureau_Product_gne__c sbp = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Product_gne(product.Id, sb.Id);
		insert sbp;
		QuestionnaireBureau_gne__c qb = new QuestionnaireBureau_gne__c(Questionnaire_gne__c = q.Id, Speaker_Bureau_gne__c = sb.Id);
		insert qb;
		GNE_SFA2_Bureau_Coverage_Ctrl bcExt = new GNE_SFA2_Bureau_Coverage_Ctrl(new ApexPages.StandardController(qb));
		pr = bcExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(qb.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_BCoverage_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Contact c = GNE_SFA2_Triggers_Test_Util.prepareContact('lastName');
		insert c;
		Comment_gne__c comm = new Comment_gne__c(Contact_gne__c = c.Id);
		insert comm;
		GNE_SFA2_Comment_Ext commExt = new GNE_SFA2_Comment_Ext(new ApexPages.StandardController(comm));
		pr = commExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(comm.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Comment_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Copay_Card_gne__c cop = new Copay_Card_gne__c(Card_Number_gne__c='1');
		insert cop;
		GNE_SFA2_Copay_Card_Ext copExt = new GNE_SFA2_Copay_Card_Ext(new ApexPages.StandardController(cop));
		pr = copExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(cop.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Copay_Card_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Curriculum_Module_gne__c cm = new Curriculum_Module_gne__c(Aprimo_ID_gne__c = 'test');
		insert cm;
		GNE_SFA2_Curriculum_Module_Ctrl cmExt = new GNE_SFA2_Curriculum_Module_Ctrl(new ApexPages.StandardController(cm));
		pr = cmExt.editCurriculumModule();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(cm.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_CModule_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Event_Curriculum_gne__c ec = GNE_SFA2_Triggers_Test_Util.prepareEvent_Curriculum_gne();
		insert ec;
		Curriculum_Speaker_Bureau_gne__c sbcurc = GNE_SFA2_Triggers_Test_Util.prepareCurriculum_Speaker_Bureau_gne(ec.Id, sb.Id);
		insert sbcurc;
		GNE_SFA2_SB_Curclm_Ctrl sbcurcExt = new GNE_SFA2_SB_Curclm_Ctrl(new ApexPages.StandardController(sbcurc));
		pr = sbcurcExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(sbcurc.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_SBCurriculum_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		GNE_SFA2_Product_Catalog_Ctrl productCatalogCtrl = new GNE_SFA2_Product_Catalog_Ctrl(new ApexPages.StandardController(product));
		pr = productCatalogCtrl.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(product.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_PCatalog_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Product_Order_gne__c prodOrder = new Product_Order_gne__c();
		insert prodOrder;
		GNE_SFA2_Product_Order_Ctrl productOrderCtrl = new GNE_SFA2_Product_Order_Ctrl(new ApexPages.StandardController(prodOrder));
		pr = productOrderCtrl.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(prodOrder.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_ProductOrder_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Product_Plan_vod__c pp = new Product_Plan_vod__c();
		insert pp;
		GNE_SFA2_Product_Plan_Ctrl ppCtrl = new GNE_SFA2_Product_Plan_Ctrl(new ApexPages.StandardController(pp));
		pr = ppCtrl.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(pp.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Product_Plan_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());
		pr = ppCtrl.addAttachmentsClick();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(pp.Id, pr.getParameters().get('id'));
		system.assertEquals('/'+pp.Id, pr.getParameters().get('retURL'));
		system.assert(pr.getUrl().contains('GNE_SFA2_UploadAttachment'), 'Wrong URL: ' + pr.getUrl());
		pr = ppCtrl.viewAttachmentsClick();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(pp.Id, pr.getParameters().get('id'));
		system.assertEquals('/'+pp.Id, pr.getParameters().get('retURL'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Attachment_layout'), 'Wrong URL: ' + pr.getUrl());

		Product_Strategy_vod__c ps = new Product_Strategy_vod__c();
		insert ps;
		GNE_SFA2_Product_Strategy_Ctrl psCtrl = new GNE_SFA2_Product_Strategy_Ctrl(new ApexPages.StandardController(ps));
		pr = psCtrl.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(ps.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_PStrategy_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());
		pr = psCtrl.addAttachmentsClick();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(ps.Id, pr.getParameters().get('id'));
		system.assertEquals('/'+ps.Id, pr.getParameters().get('retURL'));
		system.assert(pr.getUrl().contains('GNE_SFA2_UploadAttachment'), 'Wrong URL: ' + pr.getUrl());
		pr = psCtrl.viewAttachmentsClick();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(ps.Id, pr.getParameters().get('id'));
		system.assertEquals('/'+ps.Id, pr.getParameters().get('retURL'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Attachment_layout'), 'Wrong URL: ' + pr.getUrl());

		Product_Tactic_vod__c pt = new Product_Tactic_vod__c();
		insert pt;
		GNE_SFA2_Product_Tactics_Ctrl ptCtrl = new GNE_SFA2_Product_Tactics_Ctrl(new ApexPages.StandardController(pt));
		pr = ptCtrl.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(pt.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_PTactics_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		GNE_SFA2_Product_Strategy_Ctrl productTeamCtrl = new GNE_SFA2_Product_Strategy_Ctrl(new ApexPages.StandardController(sbp));
		pr = productTeamCtrl.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(sbp.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_PStrategy_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Speaker_Contract_Line_Item_gne__c scli = new Speaker_Contract_Line_Item_gne__c();
		insert scli;
		GNE_SFA2_SC_Line_Item_Ctrl scliExt = new GNE_SFA2_SC_Line_Item_Ctrl(new ApexPages.StandardController(scli));
		pr = scliExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(scli.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_SC_Line_Item_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Speaker_Bureau_Membership_gne__c sbm = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Membership_gne(sb.Id, acc.Id, 'Approved');
		insert sbm;
		Speaker_Contract_gne__c sc = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Contract_gne(acc.Id, Date.today());
		insert sc;
		GNE_SFA2_Speaker_Contract_Ctrl scExt = new GNE_SFA2_Speaker_Contract_Ctrl(new ApexPages.StandardController(sc));
		pr = scExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(sc.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_SContract_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Speaker_Training_gne__c st = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Training_gne(Date.today());
		insert st;
		GNE_SFA2_STraining_Ctrl stExt = new GNE_SFA2_STraining_Ctrl(new ApexPages.StandardController(st));
		pr = stExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(st.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_STraining_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Time_Off_Territory_gne__c tot = GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne();
		insert tot;
		GNE_SFA2_ToT_Ext totExt = new GNE_SFA2_ToT_Ext(new ApexPages.StandardController(tot));
		pr = totExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(tot.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_ToT_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		TSF_vod__c tsf = GNE_SFA2_Triggers_Test_Util.prepareTSF_vod(acc.Id);
		insert tsf;
		GNE_SFA2_TSF_Ctrl tsfExt = new GNE_SFA2_TSF_Ctrl(new ApexPages.StandardController(tsf));
		pr = tsfExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(tsf.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_TSF_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Tumor_Board_gne__c tumorB = new Tumor_Board_gne__c();
		insert tumorB;
		GNE_SFA2_Tumor_Board_Ext tbExt = new GNE_SFA2_Tumor_Board_Ext(new ApexPages.StandardController(tumorB));
		pr = tbExt.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(tumorB.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Tumor_Board_Edit_Create_Layout'), 'Wrong URL: ' + pr.getUrl());

		Vendor_gne__c vend = new Vendor_gne__c();
		GNE_SFA2_Vendor_Ext vExt = new GNE_SFA2_Vendor_Ext(new ApexPages.StandardController(vend));
		system.assertEquals(System.Label.GNE_SFA2_PFG_MAIN_PAGE_NAME, vExt.getPfgActiveMenuItem());		

		CONGA_Event_Location_gne__c prospEventLoc = new CONGA_Event_Location_gne__c(Latitude__c = 0, Longitude__c = 0, Postal_Code__c = '12345');
		insert prospEventLoc;
		GNE_SFA2_PROSPECT_Location_Ext prospLocExt = new GNE_SFA2_PROSPECT_Location_Ext(new ApexPages.StandardController(prospEventLoc));
		pr = prospLocExt.editClick();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(prospEventLoc.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('gne_sfa2_prospect_location_edit_create'), 'Wrong URL: ' + pr.getUrl());

		CONGA_Event_gne__c prospEvent = new CONGA_Event_gne__c(Event_Location__c = prospEventLoc.Id, BU__c = 'sample');
		insert prospEvent;
		GNE_SFA2_PROSPECT_Event_Ext prospEvExt = new GNE_SFA2_PROSPECT_Event_Ext(new ApexPages.StandardController(prospEvent));
		pr = prospEvExt.editClick();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(prospEvent.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('gne_sfa2_prospect_event_edit_create'), 'Wrong URL: ' + pr.getUrl());

		CONGA_Sponsor_gne__c prospSponsor = new CONGA_Sponsor_gne__c();
		insert prospSponsor;
		GNE_SFA2_PROSPECT_Sponsor_Ext prospSpExt = new GNE_SFA2_PROSPECT_Sponsor_Ext(new ApexPages.StandardController(prospSponsor));
		pr = prospSpExt.editClick();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(prospSponsor.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains('gne_sfa2_prospect_sponsor_edit_create'), 'Wrong URL: ' + pr.getUrl());
	}

	public static testMethod void testGettersAndSetters(){
		GNE_SFA2_Call_To_Calendar.setCallTrig(true);
		system.assertEquals(true, GNE_SFA2_Call_To_Calendar.getCallTrig());
		GNE_SFA2_Call_To_Calendar.setCalendarTrig (true);
		system.assertEquals(true, GNE_SFA2_Call_To_Calendar.getCalendarTrig ());
		GNE_SFA2_Call_To_Calendar.setDelCallTrig (true);
		system.assertEquals(true, GNE_SFA2_Call_To_Calendar.getDelCallTrig ());
		system.assertEquals(GNE_SFA2_Util.isSFA2UserForUI(), GNE_SFA2_Call_webservice.isSFA2User(UserInfo.getUserId()));
	}
}