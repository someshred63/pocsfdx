/** @date 2/28/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Dispute Detail Extension Controller
*/
@isTest
private class AGS_ST_DisputeDetail_CtrlExt_gne_Test {

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieve getters for Dispute with status In Progress
	*/
	@isTest static void shouldRetrieveGettersOfDisputeInProgress() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.currentPage().getParameters().put('com', '1');
		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		Boolean showOptOut = ctrlExt.showOptOut;
		Boolean isCorrectable = ctrlExt.isCorrectable;
		Boolean isCorrectableUser = ctrlExt.isCorrectableUser;
		Boolean isResolved = ctrlExt.isResolved;
		Boolean isSubmitted = ctrlExt.isSubmitted;
		Boolean isOwnerResolverChangeable = ctrlExt.isOwnerResolverChangeable;
		Boolean isCmsDispute = ctrlExt.isCmsDispute;

		List<SelectOption> internalStatuses = ctrlExt.getInternalStatuses();
		String internalStatus = ctrlExt.internalStatus;

		List<SelectOption> formsOfPayment = ctrlExt.getFormsOfPayment();
		List<SelectOption> naturesOfPayment = ctrlExt.getNaturesOfPayment();
		List<SelectOption> communicationMethods = ctrlExt.getCommunicationMethods();
		List<SelectOption> communicationTypes = ctrlExt.getCommunicationTypes();
		List<SelectOption> drugNames = ctrlExt.getDrugNames();
		List<SelectOption> disputeOwners = ctrlExt.getDisputeOwners();
		String ownerName = ctrlExt.getOwnerName();
		String activityDateField = ctrlExt.getActivityDateField();
		List<SelectOption> disputeResolvers = ctrlExt.getDisputeResolvers();
		List<AGS_ST_DisputeDetail_ControllerExt_gne.TransferOfValueClass> transferOfValues = ctrlExt.getTransferOfValues();
		Boolean isCollisionCheck = AGS_ST_DisputeDetail_ControllerExt_gne.isCollisionCheck(null, null, null);
		List<SelectOption> emailTemplates = ctrlExt.getEmailTemplates();
		List<SelectOption> emailTemplatesResolution = ctrlExt.getEmailTemplatesResolution();
		List<AGS_ST_DisputeDetail_ControllerExt_gne.DisputeNotesAttachments> disputeAllNotesInOrder = ctrlExt.getDisputeAllNotesInOrder();

		// THEN
		System.assert( !showOptOut );
		System.assert( isCorrectable );
		System.assert( isCorrectableUser );
		System.assert( !isResolved );
		System.assert( !isSubmitted );
		System.assert( isOwnerResolverChangeable );
		System.assert( !isCmsDispute );

		System.assertNotEquals( 0, internalStatuses.size() );
		System.assertEquals( disputeInternalStatus, internalStatus );

		System.assertNotEquals( 0, formsOfPayment.size() );
		System.assertNotEquals( 0, naturesOfPayment.size() );
		System.assertNotEquals( 0, communicationMethods.size() );
		System.assertNotEquals( 0, communicationTypes.size() );
		System.assertNotEquals( 0, drugNames.size() );
		System.assertNotEquals( 0, disputeOwners.size() );
		System.assertEquals( activityDateField, dispute.LastModifiedDate.format('M/d/yyyy h:mm a') );
		System.assertNotEquals( 0, disputeResolvers.size() );
		System.assertEquals( 2, transferOfValues.size() );
		System.assert( !isCollisionCheck );
		System.assertNotEquals( 0, emailTemplates.size() );
		System.assertNotEquals( 0, emailTemplatesResolution.size() );
		System.assertEquals( 1, disputeAllNotesInOrder.size() );
	}

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieve getters for Dispute with status Corrected Pending SSR
	*/
	@isTest static void shouldRetrieveGettersOfDisputeCorrectedPendingSsr() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.State_gne__c = null;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'Corrected Pending SSR';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		dispute.Corrected_gne__c  = true;
		update dispute;
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		Boolean isCorrectable = ctrlExt.isCorrectable;
		List<SelectOption> internalStatuses = ctrlExt.getInternalStatuses();

		// THEN
		System.assert( !isCorrectable );
		System.assertEquals( 3, internalStatuses.size() );
	}

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for goToDisputeList() method
	*/
	@isTest static void shouldGoToDisputeList() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		PageReference pr = ctrlExt.goToDisputeList();

		// THEN
		System.assertEquals( '/apex/AGS_ST_DisputeList_gne', pr.getUrl() );
	}

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for refreshRelatedListInfo() method
	*/
	/* HD Decommissioning
	@isTest static void shouldRefreshRelatedListInfo() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.refreshRelatedListInfo();
		Integer relatedHeldNum = ctrlExt.relatedHeldNum;

		// THEN
		System.assertEquals( 0, relatedHeldNum );
	}
	*/

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for cancelDispute() method
	*/
	@isTest static void shouldCancelDispute() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.cancelDispute();

		// THEN
		System.assert( !ctrlExt.isEditable );
	}

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for editDispute() method
	*/
	@isTest static void shouldEditDispute() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.editDispute();

		// THEN
		System.assert( ctrlExt.isEditable );
	}

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for setDrugNames() method
	*/
	@isTest static void shouldSetDrugNames() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.multiDrugNames = new String[]{'Avastin', 'Herceptin'};
		ctrlExt.setDrugNames();

		// THEN
		System.assertEquals( 'Avastin,Herceptin', ctrlExt.ccoTov.drugName );
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeToExternal() method
	*/
	@isTest static void shouldNotChangeToExternalAlreadyExternalDispute() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.changeToExternal();

		// THEN
		Boolean isExternal = ![SELECT isPrivate__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :dispute.Id LIMIT 1][0].isPrivate__c;
		System.assert(isExternal);
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for setDoNotReport() method
	*/
	@isTest static void shouldSetDoNotReport() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.setDoNotReport();

		// THEN
		AGS_ST_DisputeManagement_gne__c disputeAfter = [SELECT Do_Not_Report_Flag_gne__c, Corrected_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :dispute.Id];
		System.assert(disputeAfter.Do_Not_Report_Flag_gne__c);
		System.assert(disputeAfter.Corrected_gne__c);
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for cancelDetails() method
	*/
	@isTest static void shouldCancelDetails() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.disputeMgmtObj.Internal_Status_gne__c = 'Submitted';
		ctrlExt.cancelDetails();

		// THEN
		AGS_ST_DisputeManagement_gne__c disputeAfter = [SELECT Internal_Status_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :dispute.Id LIMIT 1];
		System.assertEquals(disputeInternalStatus, disputeAfter.Internal_Status_gne__c);
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDetails() method
	*/
	@isTest static void shouldSaveDetailsForNonCcoUser() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');

		// WHEN
		ctrlExt.setDoNotReport();
		ctrlExt.disputeResolverId = ccoAnalyst.Id;
		ctrlExt.disputeOwnerId = ccoAnalyst.Id;
		ctrlExt.saveDetails();

		// THEN
		System.assertEquals(ccoAnalyst.Id, ctrlExt.primaryResolverId);
		System.assertEquals(ccoAnalyst.Id, ctrlExt.primaryOwnerId);
		System.assert( String.isNotBlank(ctrlExt.actionMessages) );
		System.assert( ctrlExt.actionMessages.contains('Dispute Resolver has been saved') );
		System.assert( ctrlExt.actionMessages.contains('Dispute Owner has been saved') );
		//System.assert( ctrlExt.actionMessages.contains('Dispute Status has been saved') );
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDetails() method
	*/
	@isTest static void shouldSaveDetailsWithNoResolverForCcoUser() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');
		Id thisUserId =  UserInfo.getUserId();
		System.runAs(ccoAnalyst) {
			AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
			AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
			AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
			String disputeInternalStatus = 'Submitted';
			AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
			dispute.Dispute_Resolver_gne__c = null;
			update dispute;

			ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
			AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

			// WHEN
			ctrlExt.disputeOwnerId = thisUserId;
			ctrlExt.saveDetails();

			// THEN
			System.assertEquals(thisUserId, ctrlExt.primaryOwnerId);
		}
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDetails() method
	*/
	@isTest static void shouldSaveDetailsWithRecolverForCcoUser() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');
		Id thisUserId =  UserInfo.getUserId();
		System.runAs(ccoAnalyst) {
			AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
			AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
			AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
			String disputeInternalStatus = 'Submitted';
			AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);

			ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
			AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

			// WHEN
			ctrlExt.disputeResolverId = thisUserId;
			ctrlExt.disputeOwnerId = thisUserId;
			ctrlExt.saveDetails();

			// THEN
			System.assertEquals(thisUserId, ctrlExt.primaryResolverId);
			System.assertEquals(thisUserId, ctrlExt.primaryOwnerId);
		}
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assignToMe() method
	*/
	@isTest static void shouldAssignToMeDisputeSubmitted() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');
		AGS_ST_DisputeManagement_gne__c dispute;
		System.runAs(ccoAnalyst) {
			AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
			AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
			AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
			String disputeInternalStatus = 'Submitted';
			dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		}

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.assignToMe();

		// THEN
		System.assertEquals(UserInfo.getUserId(), ctrlExt.disputeOwnerId );
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assignToMe() method
	*/
	@isTest static void shouldAssignToMeDisputeInProgress() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');
		AGS_ST_DisputeManagement_gne__c dispute;
		System.runAs(ccoAnalyst) {
			AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
			AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
			AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
			String disputeInternalStatus = 'In Progress';
			dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		}

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.assignToMe();

		// THEN
		System.assertEquals(UserInfo.getUserId(), ctrlExt.disputeResolverId );
	}

	/** @date 3/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for clearNewNote() method
	*/
	@isTest static void shouldClearNewNote() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.clearNewNote();

		// THEN
		System.assertEquals('', ctrlExt.noteValue);
		System.assertEquals('', ctrlExt.noteCommunicationMethod);
		System.assertEquals('', ctrlExt.noteCommunicationType);
	}

	/** @date 3/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for addNewNoteAndAttachment() method
	*/
	@isTest static void shouldAddNewNoteAndAttachment() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.attachment1 = AGS_ST_TestUtils.prepareAttachment(dispute.Id);
		ctrlExt.noteCommunicationMethod = 'Email';
		ctrlExt.isPrivateNote = false;
		ctrlExt.addNewNoteAndAttachment();

		// THEN
		System.assert( String.isNotBlank(ctrlExt.actionMessages) );
		System.assert( ctrlExt.actionMessages.contains('New Note has been added') );
		Integer numberOfCreatedAttachments = 1;
		System.assertEquals( numberOfCreatedAttachments, [SELECT Id FROM Attachment WHERE OwnerId = :UserInfo.getUserId()].size() );
	}

	/** @date 3/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for sendExternalEmail() method
	*/
	@isTest static void shouldFailSendExternalEmail() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.attachmentEmail.Body = Blob.valueOf('Test');
		ctrlExt.sendExternalEmail();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('Cannot send email') );
	}

	/** @date 3/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for sendExternalEmail() method
	*/
	@isTest static void shouldSuccessfullySendExternalEmail() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		AGS_ST_TestUtils.createAgsSetting();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');

		System.runAs(ccoAnalyst) {
			ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
			AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

			// WHEN
			ctrlExt.attachmentEmail = AGS_ST_TestUtils.prepareAttachment(dispute.Id);
			ctrlExt.emailRecipients.add( 'test.address@gmail.com' );
			ctrlExt.externalEmailBody = 'Email Body';
			ctrlExt.sendExternalEmail();

			// THEN
			System.assert( String.isNotBlank(ctrlExt.actionMessages) );
			System.assert( ctrlExt.actionMessages.contains('New Email has been sended') );
			System.assertEquals( 0, ApexPages.getMessages().size() );
		}
	}

	/** @date 3/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for resolveDispute() method
	*/
	@isTest static void shouldSuccessfullyResolveDispute() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		AGS_ST_TestUtils.createAgsSetting();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		ctrlExt.attachment1 = AGS_ST_TestUtils.prepareAttachment(dispute.Id);
		ctrlExt.noteCommunicationMethod = 'Email';
		ctrlExt.isPrivateNote = false;
		ctrlExt.addNewNoteAndAttachment();
		System.assertEquals( 1, ctrlExt.disputeExternalNotes.size() );
		ctrlExt.disputeExternalNotes[0].isSelected = true;

		// WHEN
		ctrlExt.isHcpCommunicated 	= true;
		ctrlExt.amountHidden 		= '$123,456';
		ctrlExt.brandHidden 		= 'Actemra';
		ctrlExt.groupAmountHidden 	= '$123456';
		ctrlExt.fopHidden 			= 'Cash or cash equivalent';
		ctrlExt.nopHidden 			= 'Consulting Fee';
		ctrlExt.optOutHidden 		= 'true';
		ctrlExt.attendeesHidden 	= '1';
		ctrlExt.resolveDispute();

		// THEN
		AGS_ST_DisputeManagement_gne__c disputeAfter = [ SELECT Internal_Status_gne__c, (SELECT Dispute_Status_gne__c  FROM AGS_ST_Dispute_Notes_and_Attachments__r)
			FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :dispute.Id LIMIT 1 ];
		System.assertEquals( 'Corrected Pending SSR', disputeAfter.Internal_Status_gne__c );
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> dnas = disputeAfter.AGS_ST_Dispute_Notes_and_Attachments__r;
		System.assertEquals( 1, dnas.size() );
		System.assertEquals( 'Resolved', dnas[0].Dispute_Status_gne__c );
	}

	/** @date 3/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for resolveDispute() method
	*/
	@isTest static void shouldFailResolveDisputeDueToNoCommunicationMethodSelected() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		AGS_ST_TestUtils.createAgsSetting();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.isHcpCommunicated = true;
		ctrlExt.resolveDispute();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('No communication method was selected') );
	}

	/** @date 3/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for resolveDispute() method
	*/
	@isTest static void shouldFailResolveDisputeDueToInvalidAttachmentEmailResolution() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		AGS_ST_TestUtils.createAgsSetting();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.isHcpCommunicated = false;
		ctrlExt.attachmentEmailResolution.Body = Blob.valueOf('Test');
		ctrlExt.resolveDispute();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('Cannot send email') );
	}

	/** @date 3/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeBody() method
	*/
	@isTest static void shouldChangeBodyWithEmptyEmailType() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		AGS_ST_TestUtils.createAgsSetting();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.externalEmailBody = 'Email Body';
		ctrlExt.email_type = null;
		ctrlExt.changeBody();

		// THEN
		System.assertEquals( '', ctrlExt.externalEmailBody );
	}

	/** @date 3/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeBody() method
	*/
	@isTest static void shouldChangeBodyWithInformationEmailType() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		AGS_ST_TestUtils.createAgsSetting();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.externalEmailBody = 'Email Body';
		String emailType = 'Information';
		ctrlExt.email_type = emailType;
		ctrlExt.changeBody();

		// THEN
		Map<String,AGS_ST_Email_Templates_gne> emailTemplates = new AGS_ST_Email_Templates_gne('', '', '', '').getEmailTemplates(dispute.Id);
		System.assertEquals( emailTemplates.get(emailType).body, ctrlExt.externalEmailBody );
	}

	/** @date 3/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeBodyResolution() method
	*/
	@isTest static void shouldChangeBodyResolutionWithEmptyEmailTypeResolution() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		AGS_ST_TestUtils.createAgsSetting();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.externalEmailBodyResolution = 'Email Body';
		ctrlExt.email_type_resolution = null;
		ctrlExt.changeBodyResolution();

		// THEN
		System.assertEquals( '', ctrlExt.externalEmailBodyResolution );
	}

	/** @date 3/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeBodyResolution() method
	*/
	@isTest static void shouldChangeBodyResolutionWithInformationEmailTypeResolution() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		AGS_ST_TestUtils.createAgsSetting();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.externalEmailBodyResolution = 'Email Body';
		String emailType = 'Information';
		ctrlExt.email_type_resolution = emailType;
		ctrlExt.changeBodyResolution();

		// THEN
		Map<String,AGS_ST_Email_Templates_gne> emailTemplates = new AGS_ST_Email_Templates_gne('', '', '', '').getEmailTemplates(dispute.Id);
		System.assertEquals( emailTemplates.get(emailType).body, ctrlExt.externalEmailBodyResolution );
	}

	/** @date 3/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for AGS_ST_DisputeDetail_ControllerExt_gne.DisputeNotesAttachments class
	*/
	@isTest static void shouldTestDisputeNotesAttachmentsClass() {
		// GIVEN
		AGS_ST_DisputeDetail_ControllerExt_gne.DisputeNotesAttachments dna = new AGS_ST_DisputeDetail_ControllerExt_gne.DisputeNotesAttachments();

		// WHEN
		String communicationType = 'Communication Type';
		dna.CommunicationType = communicationType;
		dna.dnaObject = new AGS_ST_Dispute_Note_and_Attachment_gne__c();
		String communicationTypeEmpty = dna.CommunicationType;
		dna.dnaObject = new AGS_ST_Dispute_Note_and_Attachment_gne__c(Communication_Method_gne__c = 'Communication Method');
		String communicationTypeNotEmpty = dna.CommunicationType;

		DateTime now = DateTime.now();
		String communicationDateFormatEmpty = dna.getCommunicationDateFormat();
		dna.dnaObject = new AGS_ST_Dispute_Note_and_Attachment_gne__c(Communication_Date_gne__c = now);
		String communicationDateFormatNotEmpty = dna.getCommunicationDateFormat();

		String noteBodyEmpty = dna.NoteTxt;
		String noteBodyShort = 'Note Body';
		dna.note = new Note(Body = noteBodyShort);
		String noteBodyNotEmptyShort = dna.NoteTxt;
		String noteBodyLong = '';
		for(Integer i = 0; i < 100; i++) {
			noteBodyLong += 'a';
		}
		dna.note = new Note(Body = noteBodyLong);
		String noteBodyNotEmptyLong = dna.NoteTxt;

		// THEN
		System.assertEquals( '', communicationTypeEmpty );
		System.assertEquals( communicationType, communicationTypeNotEmpty );

		System.assertEquals( '', communicationDateFormatEmpty );
		System.assertEquals( now.format('M/d/yyyy h:mm a'), communicationDateFormatNotEmpty );

		System.assertEquals( '', noteBodyEmpty );
		System.assertEquals( noteBodyShort, noteBodyNotEmptyShort );
		System.assertEquals( noteBodyLong.substring(0, 100) + '...', noteBodyNotEmptyLong );
	}

	/** @date 10/3/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDisputeExplanation() method
	*/
	@isTest static void shouldSaveDisputeExplanation() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		String disputeInternalStatus = 'In Progress';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
		AGS_ST_TestUtils.createAgsSetting();

		ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
		AGS_ST_DisputeDetail_ControllerExt_gne ctrlExt = new AGS_ST_DisputeDetail_ControllerExt_gne(standardCtrl);

		// WHEN
		ctrlExt.tovNote = null;
		String explanationAdd = 'Test1';
		String explanationUpdate = 'Test2';

		ctrlExt.diputeExplanationToEdit = null;
		ctrlExt.saveDisputeExplanation();
		Boolean explanationIsNotAdded = (ctrlExt.tovNote == null);

		ctrlExt.diputeExplanationToEdit = explanationAdd;
		ctrlExt.saveDisputeExplanation();
		Boolean explanationIsAdded = (ctrlExt.tovNote != null);
		String explanationAdded = ctrlExt.tovNote.Note.Body;

		ctrlExt.diputeExplanationToEdit = explanationUpdate;
		ctrlExt.saveDisputeExplanation();
		String explanationUpdated = ctrlExt.tovNote.Note.Body;

		// THEN
		System.assert(explanationIsNotAdded);
		System.assert(explanationIsAdded);
		System.assertEquals(explanationAdd, explanationAdded);
		System.assertEquals(explanationUpdate, explanationUpdated);
	}
}