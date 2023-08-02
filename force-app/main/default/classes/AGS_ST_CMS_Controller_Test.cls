/** @date 3/13/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track CMS Controller
*/
@isTest
private class AGS_ST_CMS_Controller_Test {
	/** @date 3/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters
	*/
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjectsMap = AGS_ST_TestUtils.createCmsObjects();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_CMS_Controller ctrl = new AGS_ST_CMS_Controller(null);

			// WHEN
			List<AGS_ST_FAQ_DYK_gne__c> popups = ctrl.getPopups();
			List<AGS_ST_FAQ_DYK_gne__c> faqs = ctrl.faqs;
			List<AGS_ST_FAQ_DYK_gne__c> dyks = ctrl.dyks;

			ctrl.popupId = null;
			PageReference popupPageIdBlank = ctrl.goToPopup();
			ctrl.popupId = 'popupId';
			PageReference popupPageIdNotBlank = ctrl.goToPopup();
			PageReference popupPageViewIdNotBlank = ctrl.goToPopupView();

			// THEN
			System.assertEquals( 1, popups.size() );
			System.assertEquals( 1, faqs.size() );
			System.assertEquals( 1, dyks.size() );

			System.assertNotEquals( null, popupPageIdNotBlank.getUrl() );
			System.assertNotEquals( null, popupPageIdBlank.getUrl() );
			System.assertNotEquals( null, popupPageViewIdNotBlank.getUrl() );
		}
	}

	/** @date 4/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveCmsPaymentId() method
	*/
	@isTest static void shouldSaveCmsPaymentIdDate() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjectsMap = AGS_ST_TestUtils.createCmsObjects();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_CMS_Controller ctrl = new AGS_ST_CMS_Controller(null);
			String cmsPaymentIdDisplayDate = '1/1/2014';
			ctrl.cmsPaymentIdDisplayDate = cmsPaymentIdDisplayDate;

			// WHEN
			ctrl.saveCmsPaymentId();

			// THEN
			AGS_ST_Settings_gne__c agsSettings = AGS_ST_Utils.getCustomSettings();
			System.assertEquals( Date.parse(cmsPaymentIdDisplayDate), agsSettings.CmsPaymentIdDisplayDate_gne__c );
		}
	}
	
	/** @date 3/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for create, edit and delete 'Did you know' CMS object
	*/
	@isTest static void shouldCreateEditDeleteDyk() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_CMS_Controller ctrl = new AGS_ST_CMS_Controller(null);

			// WHEN

			// create
			ctrl.saveDyk();
			System.assertEquals( 1, ctrl.dyks.size() );
			Integer numberOfCreatedDyks = ctrl.dyks.size();

			// get to edit
			AGS_ST_FAQ_DYK_gne__c dykToEdit = AGS_ST_CMS_Controller.editDyk( ctrl.dyks[0].Id );

			// save edit
			String saveResult = AGS_ST_CMS_Controller.saveEditDyk(ctrl.dyks[0].Id, 'label', 'text');

			// delete
			ApexPages.currentPage().getParameters().put('dykId', ctrl.dyks[0].Id);
			ctrl.deleteDyk();
			Integer numberOfDyksAfterDelete = ctrl.dyks.size();

			// THEN
			System.assertEquals( 1, numberOfCreatedDyks );
			System.assertNotEquals( null, dykToEdit );
			System.assertEquals( 'suc', saveResult );
			System.assertEquals( 0, numberOfDyksAfterDelete );
		}
	}

	/** @date 3/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for create, edit and delete 'FAQ' CMS object
	*/
	@isTest static void shouldCreateEditDeleteFaq() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_CMS_Controller ctrl = new AGS_ST_CMS_Controller(null);

			// WHEN

			// create
			ctrl.saveFaq();
			System.assertEquals( 1, ctrl.faqs.size() );
			Integer numberOfCreatedFaqs = ctrl.faqs.size();

			// get to edit
			AGS_ST_FAQ_DYK_gne__c faqToEdit = AGS_ST_CMS_Controller.editFaq( ctrl.faqs[0].Id );

			// save edit
			String saveResult = AGS_ST_CMS_Controller.saveEditFaq(ctrl.faqs[0].Id, 'answer', 'question', '1');

			// delete
			ApexPages.currentPage().getParameters().put('faqId', ctrl.faqs[0].Id);
			ctrl.deleteFaq();
			Integer numberOfFaqsAfterDelete = ctrl.faqs.size();

			// THEN
			System.assertEquals( 1, numberOfCreatedFaqs );
			System.assertNotEquals( null, faqToEdit );
			System.assertEquals( 'suc', saveResult );
			System.assertEquals( 0, numberOfFaqsAfterDelete );
		}
	}

	/** @date 3/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for editing 'About Sunshine Act' CMS object
	*/
	@isTest static void shouldEditSunshineAct() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjectsMap = AGS_ST_TestUtils.createCmsObjects();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_CMS_Controller ctrl = new AGS_ST_CMS_Controller(null);

			// WHEN

			// set edit
			ctrl.editSunAct();
			Boolean isEditSunAct = ctrl.isEditSunAct;

			// save edit
			String expectedDescriptionUpdate = 'aboutSunshineAct';
			ctrl.aboutSunshineAct = expectedDescriptionUpdate;
			ctrl.saveSunAct();
			String actualDescriptionUpdate = [SELECT TC_Description_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'About Sunshine Act' LIMIT 1].TC_Description_Text_gne__c;

			// cancel edit
			ctrl.aboutSunshineAct = 'changeAboutSunshineAct';
			ctrl.cnclSunAct();
			String actualDescriptionCancel = ctrl.aboutSunshineAct;

			// THEN
			System.assert( isEditSunAct );
			System.assertEquals( expectedDescriptionUpdate, actualDescriptionUpdate );
			System.assertEquals( expectedDescriptionUpdate, actualDescriptionCancel );
		}
	}

	/** @date 3/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for editing 'Terms Conditions' CMS object
	*/
	@isTest static void shouldEditTermsConditions() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjectsMap = AGS_ST_TestUtils.createCmsObjects();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_CMS_Controller ctrl = new AGS_ST_CMS_Controller(null);

			// WHEN

			// set edit
			ctrl.editTermsCond();
			Boolean isEditTermsCond = ctrl.isEditTermsCond;

			// save edit
			String expectedDescriptionUpdate = 'TermsConditions';
			ctrl.termsCond = expectedDescriptionUpdate;
			ctrl.saveTermsCond();
			String actualDescriptionUpdate = [SELECT TC_Description_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'Terms Conditions' LIMIT 1].TC_Description_Text_gne__c;

			// cancel edit
			ctrl.termsCond = 'ChangeTermsConditions';
			ctrl.cnclTermsCond();
			String actualDescriptionCancel = ctrl.termsCond;

			// THEN
			System.assert( isEditTermsCond );
			System.assertEquals( expectedDescriptionUpdate, actualDescriptionUpdate );
			System.assertEquals( expectedDescriptionUpdate, actualDescriptionCancel );
		}
	}

	/** @date 3/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for editing Payment List Description CMS objects
	*/
	@isTest static void shouldEditPaymentListDescription() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjectsMap = AGS_ST_TestUtils.createCmsObjects();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_CMS_Controller ctrl = new AGS_ST_CMS_Controller(null);

			// WHEN

			// set edit
			ctrl.editPLD();
			Boolean isEditPLD = ctrl.isEditPLD;

			// save edit
			String expectedDescriptionUpdate = 'PaymentListDescription';
			ctrl.researchPLD = expectedDescriptionUpdate;
			ctrl.nonresearchPLD = expectedDescriptionUpdate;
			ctrl.bothPLD = expectedDescriptionUpdate;
			ctrl.savePLD();
			List<AGS_ST_FAQ_DYK_gne__c> paymentListDescriptionsUpdate = [SELECT TC_Description_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c 
				WHERE Type_gne__c = 'ToolTip' AND ToolTip_Type_gne__c IN ('BothPaymentTypesDescription', 'ResearchTypeDescription', 'NonResearchTypeDescription')];

			// cancel edit
			ctrl.researchPLD = 'ChangePaymentListDescription';
			ctrl.nonresearchPLD = 'ChangePaymentListDescription';
			ctrl.bothPLD = 'ChangePaymentListDescription';
			ctrl.cnclPLD();
			List<AGS_ST_FAQ_DYK_gne__c> paymentListDescriptionsCancel = [SELECT TC_Description_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c 
				WHERE Type_gne__c = 'ToolTip' AND ToolTip_Type_gne__c IN ('BothPaymentTypesDescription', 'ResearchTypeDescription', 'NonResearchTypeDescription')];

			// THEN
			System.assert( isEditPLD );
			for(AGS_ST_FAQ_DYK_gne__c pld : paymentListDescriptionsUpdate) {
				System.assertEquals( expectedDescriptionUpdate, pld.TC_Description_Text_gne__c );
			}
			for(AGS_ST_FAQ_DYK_gne__c pld : paymentListDescriptionsCancel) {
				System.assertEquals( expectedDescriptionUpdate, pld.TC_Description_Text_gne__c );
			}
		}
	}

	/** @date 3/20/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for deletePopup() method
	*/
	@isTest static void shouldDeletePopup() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		AGS_ST_FAQ_DYK_gne__c popup = AGS_ST_TestUtils.createPopup( AGS_ST_TestUtils.createFaq() );

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_CMS_Controller ctrl = new AGS_ST_CMS_Controller(null);

			// WHEN
			ctrl.popupId = popup.Id;
			ctrl.deletePopup();
			
			// THEN
			Integer numberOfPopupsAfterDeleteSuccess = [SELECT COUNT() FROM AGS_ST_FAQ_DYK_gne__c WHERE Id = :popup.Id];
			System.assertEquals( 0, numberOfPopupsAfterDeleteSuccess );
		}
	}

	/** @date 4/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for edit 'ToolTip' CMS object
	*/
	@isTest static void shouldEditToolTip() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjectsMap = AGS_ST_TestUtils.createCmsObjects();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			String toolTipType = 'User Details';
			AGS_ST_CMS_Controller ctrl = new AGS_ST_CMS_Controller(null);
			ctrl.ttHandler.toolTipType = toolTipType;

			// WHEN
			ctrl.ttHandler.editToolTip();
			AGS_ST_FAQ_DYK_gne__c ttObj = ctrl.ttHandler.typeToObjWrapTtMap.get(toolTipType).ttObj;
			String subject = 'Subject';
			String text = 'Text';
			ttObj.ToolTip_Subject_gne__c = subject;
			ttObj.ToolTip_Text_gne__c = text;
			ctrl.ttHandler.saveToolTip();
			ctrl.ttHandler.cancelToolTip();

			// THEN
			AGS_ST_FAQ_DYK_gne__c ttObjUpdated = [SELECT ToolTip_Subject_gne__c, ToolTip_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Id = :ttObj.Id];
			System.assertEquals( subject, ttObjUpdated.ToolTip_Subject_gne__c );
			System.assertEquals( text, ttObjUpdated.ToolTip_Text_gne__c );
		}
	}
}