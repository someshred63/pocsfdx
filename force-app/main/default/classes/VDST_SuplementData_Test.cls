/** @date 2/20/2014
* @Author Konrad Malinowski
* @description Test Class for VDST_SuplementData class
*/
@isTest
private class VDST_SuplementData_Test {
	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementTransaction(String transId, String transType) method
	*/
	@isTest static void shouldFailGetTransactionDueToBlankTransactionId() {
		// GIVEN
		String blankTransId = '';

		// WHEN
		VDST_SuplementData.SuplementedTransaction supTrans = VDST_SuplementData.getSuplementTransaction(blankTransId, '');

		// THEN
		System.assert( !supTrans.status );
		System.assertEquals( 'Transaction ID is empty.', supTrans.error_message );
	}

	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementTransaction(String transId, String transType) method
	*/
	@isTest static void shouldFailGetTransactionDueToNonExistingTransactionIdTypeRsch() {
		// GIVEN
		String blankTransId = 'nonExistingId';
		String transType = 'RSCH';

		// WHEN
		VDST_SuplementData.SuplementedTransaction supTrans = VDST_SuplementData.getSuplementTransaction(blankTransId, transType);

		// THEN
		System.assert( !supTrans.status );
		System.assertEquals( 'Transaction ID not found.', supTrans.error_message );
	}

	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementTransaction(String transId, String transType) method
	*/
	@isTest static void shouldFailGetTransactionDueToNonExistingTransactionIdTypeIndvspnd() {
		// GIVEN
		String blankTransId = 'nonExistingId';
		String transType = 'INDVSPND';

		// WHEN
		VDST_SuplementData.SuplementedTransaction supTrans = VDST_SuplementData.getSuplementTransaction(blankTransId, transType);

		// THEN
		System.assert( !supTrans.status );
		System.assertEquals( 'Transaction ID not found.', supTrans.error_message );
	}

	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementTransaction(String transId, String transType) method
	*/
	@isTest static void shouldFailGetTransactionDueToMoreThanOneTransactions() {
		// GIVEN
		String transId = 'transactionId';
		AGS_Spend_Expense_Transaction_gne__c trans1 = VDST_TestUtils.createSpendExpenseTrans(transId + '1', 'CLINICAL');
		AGS_Spend_Expense_Transaction_gne__c trans2 = VDST_TestUtils.createSpendExpenseTrans(transId + '2', 'CLINICAL', false);
		AGS_Spend_Expense_Transaction_gne__c trans3 = VDST_TestUtils.createSpendExpenseTrans(transId + '3', 'CLINICAL', false);
		trans2.Spend_User_Unix_ID_gne__c = VDST_TestUtils.createUser('Mary', 'Jane', '00002').User_External_Id_gne__c;
		trans3.Spend_User_Unix_ID_gne__c = VDST_TestUtils.createUser('Ellen', 'Page', '00003').User_External_Id_gne__c;
		update new List<AGS_Spend_Expense_Transaction_gne__c>{ trans1, trans2, trans3 };

		Test.setFixedSearchResults(new List<Id>{trans1.Id, trans2.Id, trans3.Id});

		// WHEN
		VDST_SuplementData.SuplementedTransaction supTrans = VDST_SuplementData.getSuplementTransaction(transId, 'RSCH');

		// THEN
		System.assert( !supTrans.status );
		System.assertEquals( 'More than one transaction found.', supTrans.error_message );
	}
	
	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementTransaction(String transId, String transType) method
	*/
	@isTest static void shouldSuccessfullyGetTransactionIndirect() {
		// GIVEN
		String transId = 'transactionId';
		AGS_Spend_Expense_Transaction_gne__c trans = VDST_TestUtils.createSpendExpenseTrans(transId, 'CLINICAL');
		trans.Primary_Recipient_gne__c = VDST_TestUtils.createSpendRecipient().Id;
		update trans;

		Test.setFixedSearchResults(new List<Id>{trans.Id});

		// WHEN
		VDST_SuplementData.SuplementedTransaction supTrans = VDST_SuplementData.getSuplementTransaction(transId, 'RSCH');

		// THEN
		System.assert( supTrans.status );
	}

	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementTransaction(String transId, String transType) method
	*/
	@isTest static void shouldSuccessfullyGetTransactionDirect() {
		// GIVEN
		String transId = 'transactionId';
		AGS_Spend_Expense_Transaction_gne__c trans = VDST_TestUtils.createSpendExpenseTrans(transId, 'CLINICAL');
		trans.Primary_Recipient_gne__c = VDST_TestUtils.createSpendRecipient().Id;
		update trans;

		Test.setFixedSearchResults(new List<Id>{trans.Id});

		// WHEN
		VDST_SuplementData.SuplementedTransaction supTrans = VDST_SuplementData.getSuplementTransaction(transId, 'RSCH');

		// THEN
		System.assert( supTrans.status );
	}

	/** @date 2/21/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementedParticipants(String transId, String transType) method
	*/
	@isTest static void shouldFailGetParticipantDueToNonExistingTransactionIdTypeRsch() {
		// GIVEN
		String blankTransId = 'nonExistingId';
		String transType = 'RSCH';

		// WHEN
		VDST_SuplementData.SuplementedParticipants supTrans = VDST_SuplementData.getSuplementedParticipants(blankTransId, transType);

		// THEN
		System.assert( !supTrans.status );
		System.assertEquals( 'This is new, not supplemented transaction.', supTrans.error_message );
	}

	/** @date 2/21/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementedParticipants(String transId, String transType) method
	*/
	@isTest static void shouldFailGetParticipantDueToNonExistingTransactionIdTypeIndvspnd() {
		// GIVEN
		String blankTransId = 'nonExistingId';
		String transType = 'INDVSPND';

		// WHEN
		VDST_SuplementData.SuplementedParticipants supTrans = VDST_SuplementData.getSuplementedParticipants(blankTransId, transType);

		// THEN
		System.assert( !supTrans.status );
		System.assertEquals( 'This is new, not supplemented transaction.', supTrans.error_message );
	}

	/** @date 2/21/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementedParticipants(String transId, String transType) method
	*/
	@isTest static void shouldFailGetParticipantDueToMoreThanTwoTransactions() {
		// GIVEN
		String transId = 'transactionId';
		AGS_Spend_Expense_Transaction_gne__c trans1 = VDST_TestUtils.createSpendExpenseTrans(transId + '1', 'CLINICAL');
		AGS_Spend_Expense_Transaction_gne__c trans2 = VDST_TestUtils.createSpendExpenseTrans(transId + '2', 'CLINICAL', false);
		AGS_Spend_Expense_Transaction_gne__c trans3 = VDST_TestUtils.createSpendExpenseTrans(transId + '3', 'CLINICAL', false);
		trans2.Spend_User_Unix_ID_gne__c = VDST_TestUtils.createUser('Mary', 'Jane', '00002').User_External_Id_gne__c;
		trans3.Spend_User_Unix_ID_gne__c = VDST_TestUtils.createUser('Ellen', 'Page', '00003').User_External_Id_gne__c;
		update new List<AGS_Spend_Expense_Transaction_gne__c>{ trans1, trans2, trans3 };

		Test.setFixedSearchResults(new List<Id>{trans1.Id, trans2.Id, trans3.Id});

		// WHEN
		VDST_SuplementData.SuplementedParticipants supTrans = VDST_SuplementData.getSuplementedParticipants(transId, 'RSCH');

		// THEN
		System.assert( !supTrans.status );
		System.assertEquals( 'More then two transaction found.', supTrans.error_message );
	}

	/** @date 2/21/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementedParticipants(String transId, String transType) method
	*/
	@isTest static void shouldSuccessfullyGetParticipantIndirectRsch() {
		// GIVEN
		String transId = 'transactionId';
		AGS_Spend_Expense_Transaction_gne__c trans = VDST_TestUtils.createSpendExpenseTrans(transId, 'CLINICAL');
		trans.Primary_Recipient_gne__c = VDST_TestUtils.createSpendRecipient().Id;
		update trans;

		Test.setFixedSearchResults(new List<Id>{trans.Id});

		// WHEN
		VDST_SuplementData.SuplementedParticipants supTrans = VDST_SuplementData.getSuplementedParticipants(transId, 'RSCH');

		// THEN
		System.assert( supTrans.status );
	}

	/** @date 2/21/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementedParticipants(String transId, String transType) method
	*/
	@isTest static void shouldSuccessfullyGetParticipantIndirectIndvspnd() {
		// GIVEN
		String transId = 'transactionId';
		AGS_Spend_Expense_Transaction_gne__c trans = VDST_TestUtils.createSpendExpenseTrans(transId, 'TEST');
		trans.Primary_Recipient_gne__c = VDST_TestUtils.createSpendRecipient().Id;
		update trans;

		Test.setFixedSearchResults(new List<Id>{trans.Id});

		// WHEN
		VDST_SuplementData.SuplementedParticipants supTrans = VDST_SuplementData.getSuplementedParticipants(transId, 'INDVSPND');

		// THEN
		System.assert( supTrans.status );
	}

	/** @date 2/21/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementedParticipants(String transId, String transType) method
	*/
	@isTest static void shouldSuccessfullyGetParticipantIndirectIndvspndNoFirstNameOfRecipient() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = VDST_TestUtils.createSpendRecipient();
		recipient.First_Name_gne__c = null;
		update recipient;
		String transId = 'transactionId';
		AGS_Spend_Expense_Transaction_gne__c trans = VDST_TestUtils.createSpendExpenseTrans(transId, 'TEST');
		trans.Primary_Recipient_gne__c = recipient.Id;
		update trans;

		Test.setFixedSearchResults(new List<Id>{trans.Id});

		// WHEN
		VDST_SuplementData.SuplementedParticipants supTrans = VDST_SuplementData.getSuplementedParticipants(transId, 'INDVSPND');

		// THEN
		System.assert( supTrans.status );
	}

	/** @date 2/21/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSuplementedParticipants(String transId, String transType) method
	*/
	@isTest static void shouldSuccessfullyGetParticipantDirect() {
		// GIVEN
		String transId = 'transactionId';
		AGS_Spend_Expense_Transaction_gne__c trans = VDST_TestUtils.createSpendExpenseTrans(transId, 'CLINICAL');
		trans.Primary_Recipient_gne__c = VDST_TestUtils.createSpendRecipient().Id;
		update trans;

		Test.setFixedSearchResults(new List<Id>{trans.Id});

		// WHEN
		VDST_SuplementData.SuplementedParticipants supTrans = VDST_SuplementData.getSuplementedParticipants(transId, 'RSCH');

		// THEN
		System.assert( supTrans.status );
	}
}