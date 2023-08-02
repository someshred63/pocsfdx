/** @date 3/27/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Home Controller
*/
@isTest
private class AGS_ST_HomeController_gne_Test {

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for loadDyk() method
	*/
	@isTest static void shouldLoadDyk() {
		// GIVEN
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjects = AGS_ST_TestUtils.createCmsObjects();

		AGS_ST_HomeController_gne ctrl = new AGS_ST_HomeController_gne();

		// WHEN
		ctrl.loadDyk();
		String dykText = ctrl.didYouKnow;

		// THEN
		List<AGS_ST_FAQ_DYK_gne__c> dykList = (List<AGS_ST_FAQ_DYK_gne__c>)JSON.deserialize(dykText, List<AGS_ST_FAQ_DYK_gne__c>.class);
		System.assertEquals( 1, dykList.size() );
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for toolTips getter
	*/
	@isTest static void shouldGetToolTips() {
		// GIVEN
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjects = AGS_ST_TestUtils.createCmsObjects();

		AGS_ST_HomeController_gne ctrl = new AGS_ST_HomeController_gne();

		// WHEN
		String toolTips = ctrl.toolTips;

		// THEN
		List<AGS_ST_FAQ_DYK_gne__c> toolTipsList = (List<AGS_ST_FAQ_DYK_gne__c>)JSON.deserialize(toolTips, List<AGS_ST_FAQ_DYK_gne__c>.class);
		System.assertEquals( 12, toolTipsList.size() );
	}

	/** @date 4/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for showCmsPaymentId getter
	*/
	@isTest static void shouldShowCmsPaymentId() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		// WHEN
		Boolean showCmsPaymentId = (new AGS_ST_HomeController_gne()).showCmsPaymentId;

		// THEN
		System.assert(showCmsPaymentId);
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for stSettingPub getter
	*/
	@isTest static void shouldGetStSettingPub() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			// WHEN
			AGS_ST_Settings_gne__c settings = AGS_ST_HomeController_gne.stSettingPub;

			// THEN
			System.assertNotEquals( null, settings );
		}
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for stUser getter
	*/
	@isTest static void shouldGetStUser() {
		// GIVEN
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		System.runAs(ccoAnalyst) {
			// WHEN
			AGS_ST_User_gne__c currentUser = AGS_ST_HomeController_gne.stUser ;

			// THEN
			System.assertNotEquals( null, currentUser );
		}
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getCurrentUserName() getter
	*/
	@isTest static void shouldGetCurrentUserName() {
		// GIVEN
		AGS_ST_HomeController_gne ctrl = new AGS_ST_HomeController_gne();

		// WHEN
		String currentUserName = ctrl.getCurrentUserName();

		// THEN
		System.assert( String.isNotBlank(currentUserName) );
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for loadTcAction() method
	*/
	@isTest static void shouldLoadTcAction() {
		// GIVEN
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		System.runAs(ccoAnalyst) {
			// WHEN
			AGS_ST_HomeController_gne ctrl = new AGS_ST_HomeController_gne();
			PageReference homePage = ctrl.loadTcAction();

			// THEN
			System.assertNotEquals( null, homePage );
		}
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for acceptTcAction() method
	*/
	@isTest static void shouldAcceptTcAction() {
		// GIVEN
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		agsUser.IsTCaccepted__c = false;
		update agsUser;
		System.runAs(ccoAnalyst) {
			// WHEN
			AGS_ST_HomeController_gne ctrl = new AGS_ST_HomeController_gne();
			PageReference homePage = ctrl.acceptTcAction();

			// THEN
			AGS_ST_User_gne__c agsUserUpdated = [SELECT IsTCaccepted__c FROM AGS_ST_User_gne__c WHERE Id = :agsUser.Id];
			System.assert( agsUserUpdated.IsTCaccepted__c );
			System.assertNotEquals( null, homePage );
		}
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for methods returning PageReference
	*/
	@isTest static void shouldGoToPages() {
		// GIVEN
		AGS_ST_HomeController_gne ctrl = new AGS_ST_HomeController_gne();

		// WHEN
		PageReference loginPage = ctrl.goToLoginPage();
		PageReference homePage = ctrl.goToHomePage();
		PageReference accountSettingsPage = ctrl.goToAccountSettings();
		PageReference sysLogoutPage = ctrl.sysLogout();

		// THEN
		System.assertNotEquals( null, loginPage );
		System.assertNotEquals( null, homePage );
		System.assertNotEquals( null, accountSettingsPage );
		System.assertNotEquals( null, sysLogoutPage );
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for  updateStUserWithFilter(Boolean, Boolean, Boolean, String, String, Decimal, String) method
	*/
	@isTest static void shouldUpdateStUserWithFilterResearchPaymentIsDateFilterApply() {
		// GIVEN
		Boolean researchPayment = true;
		Boolean isDateFilterApply = true;
		Boolean isAmountFilterApply = true;
		DateTime today = DateTime.now();
		DateTime tomorrow = today.addDays(1);
		String dateFrom = today.format('yyyy-MM-dd');
		String dateTo = tomorrow.format('yyyy-MM-dd');
		Decimal dateRangeDays = today.date().daysBetween(tomorrow.date());
		String amount = '1';

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		System.runAs(ccoAnalyst) {
			// WHEN
			AGS_ST_HomeController_gne.updateStUserWithFilter(researchPayment, isDateFilterApply, isAmountFilterApply, dateFrom, dateTo, dateRangeDays, amount);

			// THEN
			AGS_ST_User_gne__c agsUserUpdated = [SELECT Research_Spends_Date_From_gne__c, Research_Spends_Date_To_gne__c,
					Research_Spends_Date_Range_gne__c, Research_Spends_Filter_Amount_gne__c
				FROM AGS_ST_User_gne__c WHERE Id = :agsUser.Id];
			System.assertEquals( dateFrom, 		agsUserUpdated.Research_Spends_Date_From_gne__c );
			System.assertEquals( dateTo, 		agsUserUpdated.Research_Spends_Date_To_gne__c );
			System.assertEquals( dateRangeDays, agsUserUpdated.Research_Spends_Date_Range_gne__c );
			System.assertEquals( amount, 		agsUserUpdated.Research_Spends_Filter_Amount_gne__c );
		}
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for  updateStUserWithFilter(Boolean, Boolean, Boolean, String, String, Decimal, String) method
	*/
	@isTest static void shouldUpdateStUserWithFilterNonResearchPaymentIsDateFilterApply() {
		// GIVEN
		Boolean researchPayment = false;
		Boolean isDateFilterApply = true;
		Boolean isAmountFilterApply = true;
		DateTime today = DateTime.now();
		DateTime tomorrow = today.addDays(1);
		String dateFrom = today.format('yyyy-MM-dd');
		String dateTo = tomorrow.format('yyyy-MM-dd');
		Decimal dateRangeDays = today.date().daysBetween(tomorrow.date());
		String amount = '1';

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		System.runAs(ccoAnalyst) {
			// WHEN
			AGS_ST_HomeController_gne.updateStUserWithFilter(researchPayment, isDateFilterApply, isAmountFilterApply, dateFrom, dateTo, dateRangeDays, amount);

			// THEN
			AGS_ST_User_gne__c agsUserUpdated = [SELECT Filter_date_from_gne__c, Filter_date_to_gne__c,
					Filter_date_range_gne__c, Filter_amount__c
				FROM AGS_ST_User_gne__c WHERE Id = :agsUser.Id];
			System.assertEquals( dateFrom, 		agsUserUpdated.Filter_date_from_gne__c );
			System.assertEquals( dateTo, 		agsUserUpdated.Filter_date_to_gne__c );
			System.assertEquals( dateRangeDays, agsUserUpdated.Filter_date_range_gne__c );
			System.assertEquals( amount, 		agsUserUpdated.Filter_amount__c );
		}
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getHistoryDescription(AGS_ST_DisputeManagement_gne__History) method
	*/
	@isTest static void shouldGetHistoryDescription() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		// WHEN
		AGS_ST_DisputeManagement_gne__History disputeHistoryFieldCreated = AGS_ST_TestUtils.createDisputeHistory(dispute, 'created');
		String histDescFieldCreated = AGS_ST_HomeController_gne.getHistoryDescription(disputeHistoryFieldCreated);

		AGS_ST_DisputeManagement_gne__History disputeHistoryFieldExternalStatus = AGS_ST_TestUtils.createDisputeHistory(dispute, 'External_Status_gne__c');
		String histDescFieldExternalStatus = AGS_ST_HomeController_gne.getHistoryDescription(disputeHistoryFieldExternalStatus);

		AGS_ST_DisputeManagement_gne__History disputeHistoryFieldAmount = AGS_ST_TestUtils.createDisputeHistory(dispute, 'Amount_gne__c');
		String histDescFieldAmount = AGS_ST_HomeController_gne.getHistoryDescription(disputeHistoryFieldAmount);

		// THEN
		System.assert( String.isNotBlank(histDescFieldCreated) );
		System.assert( histDescFieldCreated.contains('Disputed on') );
		System.assert( String.isNotBlank(histDescFieldExternalStatus) );
		System.assert( histDescFieldExternalStatus.contains('Status changed to') );
		System.assertEquals( null, histDescFieldAmount );
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSpendTransactions(Boolean, Boolean, Boolean, ...) method
	*/
	@isTest static void shouldGetSpendTransactions() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);

		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = agsUser.Mapped_Account__r.MDMID_gne__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);

		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		agsTransaction.Research_Pymt_Typ_Cd_gne__c = 'TEST';
		update agsTransaction;

		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_Expense_Bookmark__c bookmark = AGS_ST_TestUtils.createExpenseBookmark(agsTransaction.Id);

		String formOfPayment = 'Cash or cash equivalent';
		String natureOfPayment = 'Consulting Fee';
		String drugName = 'AVASTIN';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'Corrected Pending SSR');
		dispute.Form_Of_Payment_gne__c = formOfPayment;
		dispute.Nature_Of_Payment_gne__c = natureOfPayment;
		dispute.Drug_Name_gne__c = drugName;
		update dispute;

		Boolean isFirstCall = true;
		Boolean isDateFilterApply = true;
		Boolean isAmountFilterApply = true;
		Boolean isYearFilterApply = true;
		DateTime dateFromDT = DateTime.now();
		dateFromDT = dateFromDT.addDays(-5);
		DateTime dateToDT = dateFromDT.addDays(5);
		String dateFrom = dateFromDT.format('yyyy-MM-dd');
		String dateTo = dateToDT.format('yyyy-MM-dd');
		String amountFrom = '1';
		List<String> status = new List<String>{ 'Resolved' };
		List<String> method = new List<String>{ formOfPayment };
		List<String> reason =  new List<String>{ natureOfPayment };
		List<String> brand = new List<String>{ drugName };
		Boolean getBookmarked = true;
		Boolean getNewest = true;
		Decimal dateRangeDays = dateFromDT.date().daysBetween(dateToDT.date());
		String cmsPaymentId = '';

		AGS_ST_SpendSearch_Utils_gne.NonResearchPaymentsData spendTransactionsIsWithCorrectedDispute;
		AGS_ST_SpendSearch_Utils_gne.NonResearchPaymentsData spendTransactionsIsWithDisputeInProgress;
		AGS_ST_SpendSearch_Utils_gne.NonResearchPaymentsData spendTransactionsWithoutDispute;

		// WHEN
		System.runAs(userWithContact) {
			System.debug('km!!! ' + AGS_ST_SpendSearch_Utils_gne.stUser);
			spendTransactionsIsWithCorrectedDispute = AGS_ST_HomeController_gne.getSpendTransactions(
				isFirstCall, isDateFilterApply, isAmountFilterApply, isYearFilterApply, dateFrom, dateTo, amountFrom,
				status, method, reason, brand, getBookmarked, getNewest, dateRangeDays, cmsPaymentId
			);
		}

		dispute.Internal_Status_gne__c = 'In Progress';
		update dispute;
		System.runAs(userWithContact) {
			spendTransactionsIsWithDisputeInProgress = AGS_ST_HomeController_gne.getSpendTransactions(
				isFirstCall, isDateFilterApply, isAmountFilterApply, isYearFilterApply, dateFrom, dateTo, amountFrom,
				status, method, reason, brand, getBookmarked, getNewest, dateRangeDays, cmsPaymentId
			);
		}

		delete dispute;
		bookmark.Bookmarked_User_gne__c = userWithContact.Id;
		update bookmark;
		status = new List<String>();
		System.runAs(userWithContact) {
			spendTransactionsWithoutDispute = AGS_ST_HomeController_gne.getSpendTransactions(
				!isFirstCall, !isDateFilterApply, isAmountFilterApply, !isYearFilterApply, dateFrom, dateTo, amountFrom,
				status, method, reason, brand, !getBookmarked, !getNewest, dateRangeDays, cmsPaymentId
			);
		}

		// THEN
		System.assertNotEquals( null, spendTransactionsIsWithCorrectedDispute );
		System.assertNotEquals( null, spendTransactionsIsWithDisputeInProgress );
		System.assertNotEquals( null, spendTransactionsWithoutDispute );
	}

	/** @date 4/2/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getResearchSpendTransactions(Boolean, Boolean, Boolean, ...) method
	*/
	@isTest static void shouldGetResearchSpendTransactions() {
		// GIVEN
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjects = AGS_ST_TestUtils.createCmsObjects();
		AGS_ST_TestUtils.createAgsSetting();

		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);

		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = agsUser.Mapped_Account__r.MDMID_gne__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);

		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		agsTransaction.Research_Pymt_Typ_Cd_gne__c = 'CLINICAL';
		update agsTransaction;

		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_Expense_Bookmark__c bookmark = AGS_ST_TestUtils.createExpenseBookmark(agsTransaction.Id);

		String drugName = 'AVASTIN';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'Corrected Pending SSR');
		dispute.Drug_Name_gne__c = drugName;
		dispute.IsPrivate__c = false;
		update dispute;

		Boolean isFirstCall = true;
		Boolean isDateFilterApply = true;
		Boolean isAmountFilterApply = true;
		Boolean isYearFilterApply = true;
		DateTime dateFromDT = DateTime.now();
		dateFromDT = dateFromDT.addDays(-5);
		DateTime dateToDT = dateFromDT.addDays(5);
		String dateFrom = dateFromDT.format('yyyy-MM-dd');
		String dateTo = dateToDT.format('yyyy-MM-dd');
		String amountFrom = '1';
		List<String> status = new List<String>{ 'Resolved' };
		List<String> brand = new List<String>{ drugName };
		Boolean getBookmarked = true;
		Boolean getNewest = false;
		Decimal dateRangeDays = dateFromDT.date().daysBetween(dateToDT.date());
		String cmsPaymentId = '';

		AGS_ST_SpendSearch_Utils_gne.ResearchPaymentsData researchPayment;

		// WHEN
		System.runAs(userWithContact) {
			researchPayment = AGS_ST_HomeController_gne.getResearchSpendTransactions(
				isFirstCall, isDateFilterApply, isAmountFilterApply, isYearFilterApply, dateFrom, dateTo,
				amountFrom, status, brand, getBookmarked, getNewest, dateRangeDays, cmsPaymentId
			);
		}
	}

	/** @date 4/4/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveBookmark(String) method
	*/
	@isTest static void shouldSaveBookmark() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		String spendId = agsTransaction.Id;

		// WHEN
		String result = AGS_ST_HomeController_gne.saveBookmark(spendId);
		String resultError = AGS_ST_HomeController_gne.saveBookmark('');

		// THEN
		System.assertEquals( 'Success',  result );
		System.assertEquals( 1, [SELECT COUNT() FROM AGS_ST_Expense_Bookmark__c] );
		System.assertNotEquals( 'Success',  resultError );
	}

	/** @date 4/4/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for removeBookmark(String) method
	*/
	@isTest static void shouldRemoveBookmark() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		String spendId = agsTransaction.Id;

		// WHEN
		AGS_ST_HomeController_gne.saveBookmark(spendId);
		String result = AGS_ST_HomeController_gne.removeBookmark(spendId);
		String resultError = AGS_ST_HomeController_gne.removeBookmark('');

		// THEN
		System.assertEquals( 'Success',  result );
		System.assertEquals( 0, [SELECT COUNT() FROM AGS_ST_Expense_Bookmark__c] );
		System.assertNotEquals( 'Success',  resultError );
	}

	/** @date 4/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getCommunications() method
	*/
	@isTest static void shouldGetCommunications() {
		// GIVEN
		String phoneNumber = '1';
		String phoneNumberExt = '2';
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		agsUser.Phone_number__c = phoneNumber;
		update agsUser;

		// WHEN
		AGS_ST_HomeController_gne.DisputeCommunication disputeComPhone = AGS_ST_HomeController_gne.getCommunications();

		agsUser.Phone_number__c = null;
		agsUser.Phone_number_ext__c  = phoneNumberExt;
		update agsUser;
		AGS_ST_HomeController_gne.DisputeCommunication disputeComPhoneExt = AGS_ST_HomeController_gne.getCommunications();

		// THEN
		System.assertEquals( phoneNumber, disputeComPhone.dispPhone );
		System.assertEquals( phoneNumberExt, disputeComPhoneExt.dispPhone );
	}

	/** @date 4/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDispute(String, String, String, String, String, String, String, String, Boolean) method
	*/
	@isTest static void shouldFailSaveDisputeDueToBlankSpendId() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		// WHEN
		AGS_ST_HomeController_gne.DisputeCreationResult dcResultWithError = AGS_ST_HomeController_gne.saveDispute(
			'', '', '', '', '', 'hcpNote', 'Email', 'communication', true
		);

		// THEN
		System.assert( String.isNotBlank(dcResultWithError.errorMessage) );
	}

	/** @date 4/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDispute(String, String, String, String, String, String, String, String, Boolean) method
	*/
	@isTest static void shouldFailSaveDisputeDueToExistingDispute() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		// WHEN
		AGS_ST_HomeController_gne.DisputeCreationResult dcResultWithExistingDispute = AGS_ST_HomeController_gne.saveDispute(
			agsTransaction.Id, '', '', '', '', 'hcpNote', 'Email', 'test@gmail.com', true
		);

		// THEN
		System.assert( String.isNotBlank(dcResultWithExistingDispute.errorMessage) );
	}

	/** @date 4/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDispute(String, String, String, String, String, String, String, String, Boolean) method
	*/
	@isTest static void shouldSuccessfullySaveDispute1() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		// WHEN
		AGS_ST_HomeController_gne.DisputeCreationResult dcResultSuccess1 = AGS_ST_HomeController_gne.saveDispute(
			agsTransaction.Id, '10', 'Cash or cash equivalent', 'Consulting Fee', 'Avastin', 'hcpNote', 'Phone', '123456789', true
		);

		// THEN
		System.assertNotEquals( null, dcResultSuccess1.disputeName );
		System.assert( String.isBlank(dcResultSuccess1.errorMessage) );
	}

	/** @date 4/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDispute(String, String, String, String, String, String, String, String, Boolean) method
	*/
	@isTest static void shouldSuccessfullySaveDispute2() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		// WHEN
		AGS_ST_HomeController_gne.DisputeCreationResult dcResultSuccess2 = AGS_ST_HomeController_gne.saveDispute(
			agsTransaction.Id, '', '', '', '', 'hcpNote', 'Email', 'test@gmail.com', true
		);

		// THEN
		System.assertNotEquals( null, dcResultSuccess2.disputeName );
		System.assert( String.isBlank(dcResultSuccess2.errorMessage) );
	}

	/** @date 4/9/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveResearchDispute(String, String, String, String, Boolean) method
	*/
	@isTest static void shouldSFailSaveResearchDisputeDueToBlankSpendId() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		// WHEN
		AGS_ST_HomeController_gne.DisputeCreationResult dcResult = AGS_ST_HomeController_gne.saveResearchDispute(
			'', 'hcpNote', 'Email', 'test@gmail.com', true
		);

		// THEN
		System.assert( String.isNotBlank(dcResult.errorMessage) );
	}

	/** @date 4/9/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveResearchDispute(String, String, String, String, Boolean) method
	*/
	@isTest static void shouldSFailSaveResearchDisputeDueToExistingDispute() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		// WHEN
		AGS_ST_HomeController_gne.DisputeCreationResult dcResult = AGS_ST_HomeController_gne.saveResearchDispute(
			agsTransaction.Id, 'hcpNote', 'Email', 'test@gmail.com', true
		);

		// THEN
		System.assert( String.isNotBlank(dcResult.errorMessage) );
	}

	/** @date 4/9/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveResearchDispute(String, String, String, String, Boolean) method
	*/
	@isTest static void shouldSuccessfullySaveResearchDispute1() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		// WHEN
		AGS_ST_HomeController_gne.DisputeCreationResult dcResult = AGS_ST_HomeController_gne.saveResearchDispute(
			agsTransaction.Id, 'hcpNote', 'Email', 'test@gmail.com', true
		);

		// THEN
		System.assertNotEquals( null, dcResult.disputeName );
		System.assert( String.isBlank(dcResult.errorMessage) );
	}

	/** @date 4/9/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveResearchDispute(String, String, String, String, Boolean) method
	*/
	@isTest static void shouldSuccessfullySaveResearchDispute2() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		// WHEN
		AGS_ST_HomeController_gne.DisputeCreationResult dcResult = AGS_ST_HomeController_gne.saveResearchDispute(
			agsTransaction.Id, 'hcpNote', 'Phone', '123456789', true
		);

		// THEN
		System.assertNotEquals( null, dcResult.disputeName );
		System.assert( String.isBlank(dcResult.errorMessage) );
	}

	/** @date 4/9/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDisputeNotesFromDisputeId(String, String) method
	*/
	@isTest static void shouldFailSaveDisputeNotesFromDisputeId() {
		// GIVEN
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		// WHEN
		String result = AGS_ST_HomeController_gne.saveDisputeNotesFromDisputeId('', '');

		// THEN
		System.assertNotEquals( 'Success', result );
	}

	/** @date 4/9/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getDisputeDetails(String) method
	*/
	@isTest static void shouldSuccessfullyGetDisputeDetails() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		agsTransaction.Research_Pymt_Typ_Cd_gne__c = 'TEST';
		update agsTransaction;
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachmentsNoEmail = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		for(AGS_ST_Dispute_Note_and_Attachment_gne__c dna : disputeNoteAndAttachmentsNoEmail) {
			dna.Email_Recipients_gne__c = null;
			dna.About_gne__c = null;
		}
		update disputeNoteAndAttachmentsNoEmail;
		List<Note> disputeNotes = AGS_ST_TestUtils.createNotesForDistputes(disputeNoteAndAttachments);
		List<Note> disputeNotesNoEmail = AGS_ST_TestUtils.createNotesForDistputes(disputeNoteAndAttachmentsNoEmail);

		// WHEN
		AGS_ST_HomeController_gne.NonResearchSpendDetailsView result = AGS_ST_HomeController_gne.getDisputeDetails(agsTransaction.Id);

		// THEN
		System.assertNotEquals( 0, result.detailTab.size() );
	}

	/** @date 4/9/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getDisputeDetails(String) method
	*/
	@isTest static void shouldFailGetDisputeDetails() {
		// GIVEN
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());

		// WHEN
		AGS_ST_HomeController_gne.NonResearchSpendDetailsView result = AGS_ST_HomeController_gne.getDisputeDetails('');

		// THEN
		System.assertEquals( 0, result.detailTab.size() );
	}

	/** @date 4/9/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getResearchDisputeDetails(String) method
	*/
	@isTest static void shouldGetResearchDisputeDetails() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		agsTransaction.Research_Pymt_Typ_Cd_gne__c = 'TEST';
		update agsTransaction;
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		for(AGS_ST_Dispute_Note_and_Attachment_gne__c dna : disputeNoteAndAttachments) {
			dna.About_gne__c = null;
		}
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachmentsNoEmail = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
		for(AGS_ST_Dispute_Note_and_Attachment_gne__c dna : disputeNoteAndAttachmentsNoEmail) {
			dna.Email_Recipients_gne__c = null;
			dna.About_gne__c = null;
		}
		update disputeNoteAndAttachmentsNoEmail;
		List<Note> disputeNotes = AGS_ST_TestUtils.createNotesForDistputes(disputeNoteAndAttachments);
		List<Note> disputeNotesNoEmail = AGS_ST_TestUtils.createNotesForDistputes(disputeNoteAndAttachmentsNoEmail);

		// WHEN
		AGS_ST_HomeController_gne.ResearchSpendDetailsView result = AGS_ST_HomeController_gne.getResearchDisputeDetails(agsTransaction.Id);

		// THEN
		System.assertNotEquals( 0, result.historyTab.size() );
	}

	/** @date 4/10/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveDisputeNotes(String, String) method
	*/
	@isTest static void shouldSuccessfullySaveDisputeNotes() {
		// GIVEN
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		// WHEN
		String result = AGS_ST_HomeController_gne.saveDisputeNotes(agsTransaction.Id, 'noteTxt');

		// THEN
		System.assertNotEquals( 0, [SELECT COUNT() FROM Note] );
	}

	/** @date 4/10/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getDisputeTypesValues() method
	*/
	@isTest static void shouldGetDisputeTypesValues() {
		// GIVEN
		List<AGS_Brand_gne__c> createdBrands = AGS_ST_TestUtils.createBrands();

		// WHEN
		AGS_ST_HomeController_gne.DisputeTypesValues disputeTypesValues = AGS_ST_HomeController_gne.getDisputeTypesValues();

		// THEN
		System.assertNotEquals( 0, disputeTypesValues.methodsList.size() );
		System.assertNotEquals( 0, disputeTypesValues.reasonsList.size() );
		System.assertEquals( createdBrands.size(), disputeTypesValues.brandsList.size() );
	}

	/** @date 4/10/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for deactivatePopup() method
	*/
	@isTest static void shouldDeactivatePopup() {
		// GIVEN
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		AGS_ST_FAQ_DYK_gne__c popup1 = AGS_ST_TestUtils.createPopup(AGS_ST_TestUtils.createFaq());
		AGS_ST_FAQ_DYK_gne__c popup2 = AGS_ST_TestUtils.createPopup(AGS_ST_TestUtils.createFaq());
		AGS_ST_Popup_gne__c userPopup = AGS_ST_TestUtils.createUserPopup(popup1, agsUser);

		// WHEN
		Boolean isPopupDeactivated = AGS_ST_HomeController_gne.deactivatePopup();

		// THEN
		System.assert(isPopupDeactivated);
	}

	/** @date 4/10/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getPopupData() method
	*/
	@isTest static void shouldGetPopupData() {
		// GIVEN
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		AGS_ST_FAQ_DYK_gne__c popup1 = AGS_ST_TestUtils.createPopup(AGS_ST_TestUtils.createFaq());
		AGS_ST_FAQ_DYK_gne__c popup2 = AGS_ST_TestUtils.createPopup(AGS_ST_TestUtils.createFaq());
		AGS_ST_Popup_gne__c userPopup = AGS_ST_TestUtils.createUserPopup(popup1, agsUser);

		// WHEN
		AGS_ST_HomeController_gne.PopupData popupData = AGS_ST_HomeController_gne.getPopupData();

		// THEN
		System.assertEquals( 1, popupData.popupDescriptions.size() );
		System.assertEquals( 2, popupData.faqData.size() );
	}
}