/** @date 3/18/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track CMS Popup Controller
*/
@isTest
private class AGS_ST_CMS_PopupController_gne_Test {
	/** @date 3/18/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for getting invalid Popup Ids from Apex Page parameters
    */
    @isTest static void shouldFailGetPopupId() {
    	// GIVEN
    	Account wrongObj = new Account( Name = 'Account Name' );
    	insert wrongObj;

    	AGS_ST_FAQ_DYK_gne__c faq = AGS_ST_TestUtils.createFaq();
    	AGS_ST_FAQ_DYK_gne__c popup = AGS_ST_TestUtils.createPopup(faq);
    	delete [SELECT Id FROM AGS_ST_FAQ_DYK_gne__c WHERE Id = :popup.Id];

    	// WHEN
    	AGS_ST_CMS_PopupController_gne ctrl = new AGS_ST_CMS_PopupController_gne();
    	Id popupIdNull = ctrl.popupId;

    	ApexPages.currentPage().getParameters().put('id', wrongObj.Id);
    	ctrl = new AGS_ST_CMS_PopupController_gne();
    	Id popupIdWrongObjId = ctrl.popupId;

    	ApexPages.currentPage().getParameters().put('id', popup.Id);
    	ctrl = new AGS_ST_CMS_PopupController_gne();
    	Id popupIdNotExists = ctrl.popupId;

    	// THEN
    	System.assertEquals( null, popupIdNull );
    	System.assertEquals( null, popupIdWrongObjId );
    	System.assertEquals( null, popupIdNotExists );
    	System.assert( !ctrl.isPopupIdValid );
    }

    /** @date 3/18/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for save() method
    */
    @isTest static void shouldSavePopup() {
    	User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');
    	System.runAs(ccoAnalyst) {
    		// GIVEN
	    	AGS_ST_FAQ_DYK_gne__c faq = AGS_ST_TestUtils.createFaq();
	    	AGS_ST_FAQ_DYK_gne__c popup = AGS_ST_TestUtils.createPopup(faq);

	    	ApexPages.currentPage().getParameters().put('viewMode', '1');
	    	ApexPages.currentPage().getParameters().put('id', popup.Id);
	    	AGS_ST_CMS_PopupController_gne ctrl = new AGS_ST_CMS_PopupController_gne();

	    	// WHEN
	    	String newDescription = 'New description: ' + ctrl.popup.TC_Description_Text_gne__c;
	    	ctrl.popup.TC_Description_Text_gne__c = newDescription;
	    	ctrl.save();

	    	// THEN
	    	System.assertEquals( 2, ctrl.getFaqs().size() );
	    	System.assertEquals( newDescription, ctrl.popup.TC_Description_Text_gne__c );
	    	PageReference listPage = ctrl.backToList();
	    	System.assertNotEquals( null, listPage );
	    	System.assertEquals( '/apex/AGS_ST_CMS_gne', listPage.getUrl() );
    	}
    }

    /** @date 3/18/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for setInactive() and setActive()  methods for existing popup
    */
    @isTest static void shouldSetInactiveActiveStatusOfExistingPopup() {
    	User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');
    	System.runAs(ccoAnalyst) {
	    	// GIVEN
	    	AGS_ST_FAQ_DYK_gne__c faq = AGS_ST_TestUtils.createFaq();
	    	AGS_ST_FAQ_DYK_gne__c popup = AGS_ST_TestUtils.createPopup(faq);

	    	ApexPages.currentPage().getParameters().put('viewMode', '1');
	    	ApexPages.currentPage().getParameters().put('id', popup.Id);
	    	AGS_ST_CMS_PopupController_gne ctrl = new AGS_ST_CMS_PopupController_gne();
	    	String statusBefore = ctrl.popup.Status_gne__c;

	    	// WHEN
	    	ctrl.setInactive();
	    	String statusAfterInactivation = ctrl.popup.Status_gne__c;

	    	ctrl.setActive();
	    	String statusAfterActivation = ctrl.popup.Status_gne__c;

	    	// THEN
	    	System.assertEquals( 'Active', statusBefore );
	    	System.assertEquals( 'Inactive', statusAfterInactivation );
	    	System.assertEquals( 'Active', statusAfterActivation );
    	}
    }

    /** @date 3/18/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for setActive() and setInactive() methods for new popup
    */
    @isTest static void shouldSetActiveSInactivetatusOfNewPopup() {
    	// GIVEN
    	AGS_ST_CMS_PopupController_gne ctrl = new AGS_ST_CMS_PopupController_gne();
    	String statusBefore = ctrl.popup.Status_gne__c;

    	// WHEN
    	ctrl.setActive();
    	String statusAfterActivation = ctrl.popup.Status_gne__c;
    	
    	ctrl.setInactive();
    	String statusAfterInactivation = ctrl.popup.Status_gne__c;

    	// THEN
    	System.assertEquals( 'Inactive', statusBefore );
    	System.assertEquals( 'Active', statusAfterActivation );
    	System.assertEquals( 'Inactive', statusAfterInactivation );	
    }
}