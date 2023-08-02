/** @date 3/25/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Paging and Sorting Util Class
*/
@isTest
private class AGS_ST_DMPagingAndSortingUtils_Test {
	/** @date 3/25/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getPerPageOptions() method
	*/
	@isTest static void shouldGetPerPageOptions() {
		// GIVEN
		AGS_ST_DMPagingAndSortingUtils util = new AGS_ST_DMPagingAndSortingUtils(5);
		AGS_ST_DMPagingAndSortingUtils util2 = new AGS_ST_DMPagingAndSortingUtils(5, 'sortingFieldVal', 'sortingOrderVal');

		// WHEN
		List<SelectOption> perPageOptions = util.getPerPageOptions();
		util.duplicateValues();

		// THEN
		Integer numberOfPerPageOptions = 6;
		System.assertEquals( numberOfPerPageOptions, perPageOptions.size() );

		Set<String> recordsPerPageSet = new Set<String>{'5', '10', '25', '50', '100', '500'};
		for(SelectOption so : perPageOptions) {
			System.assert( recordsPerPageSet.contains( so.getValue() ) );
			System.assert( recordsPerPageSet.contains( so.getLabel() ) );
			System.assertEquals( so.getValue(), so.getLabel() );
		}
		System.assert( util.compareValues() );
	}

	/** @date 3/25/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changing actual page
	*/
	@isTest static void shouldChangePage() {
		// GIVEN
		AGS_ST_DMPagingAndSortingUtils util = new AGS_ST_DMPagingAndSortingUtils(5);
		Integer numberOfListElements = 10;
		util.setParameters( numberOfListElements );

		// WHEN
		util.firstPage();
		Integer firstPage = util.actualPage;

		util.changePerPageValue();
		Integer firstPageAfterChange = util.actualPage;
		
		util.nextPage();
		Integer secondPageAfterNext = util.actualPage;

		util.prevPage();
		Integer firstPageAfterPrevious = util.actualPage;

		util.lastPage();
		Integer lastPage = util.actualPage;

		// THEN
		System.assertEquals( 1, firstPage );
		System.assertEquals( 1, firstPageAfterChange );
		System.assertEquals( 2, secondPageAfterNext );
		System.assertEquals( 1, firstPageAfterPrevious );
		System.assertEquals( 2, lastPage );
	}

	/** @date 3/25/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for setting paging parameters
	*/
	@isTest static void shouldSetParameters() {
		// GIVEN
		AGS_ST_DMPagingAndSortingUtils util = new AGS_ST_DMPagingAndSortingUtils(5);
		Integer numberOfListElements = 20;
		util.setParameters( numberOfListElements );

		// WHEN
		util.perPage = null;
		util.setParameters( numberOfListElements );
		Integer perPageShouldBeSetToFive = util.perPage;

		util.perPage = 10;
		util.setParameters( numberOfListElements );
		Integer totalPagesAfterChangeNumberOfDisplayedElements = util.totalPages;

		util.actualPage = 0;
		util.setParameters( numberOfListElements );
		Integer actualPageShouldBeSetToFirst = util.actualPage;

		util.actualPage = 3;
		util.setParameters( numberOfListElements );
		Integer actualPageShouldBeSetToLast = util.actualPage;

		util.setParameters( 0 );
		Integer totalElementsShouldBeZero = util.totalDisputes;
		Integer totalPagesShouldBeZero = util.totalPages;

		// THEN
		System.assertEquals( 5, perPageShouldBeSetToFive );
		System.assertEquals( 2, totalPagesAfterChangeNumberOfDisplayedElements );
		System.assertEquals( 1, actualPageShouldBeSetToFirst );
		System.assertEquals( 2, actualPageShouldBeSetToLast );
		System.assertEquals( 0, totalElementsShouldBeZero );
		System.assertEquals( 0, totalPagesShouldBeZero );
	}

	/** @date 3/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for createDisputeList(List<AGS_ST_DisputeManagement_gne__c>, Boolean) method
	*/
	@isTest static void shouldCreateDisputeList() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		AGS_ST_DMPagingAndSortingUtils util = new AGS_ST_DMPagingAndSortingUtils();

		// WHEN
		util.createDisputeList(new List<AGS_ST_DisputeManagement_gne__c>{dispute}, true);

		// THEN
		System.assertEquals( 1, util.totalDisputes );
		System.assertEquals( 1, util.getDisputeForPage().size() );
	}

	/** @date 3/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for createDMList(ApexPages.StandardSetController) method
	*/
	@isTest static void shouldCreateDMList() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		AGS_ST_DMPagingAndSortingUtils util = new AGS_ST_DMPagingAndSortingUtils();

		// WHEN
		ApexPages.StandardSetController sscObject = new ApexPages.StandardSetController( [SELECT Id FROM AGS_ST_DisputeManagement_gne__c] );
		util.createDMList(sscObject);

		// THEN
		System.assertEquals( 1, util.getDisputeIdList().size() );
	}

	/** @date 3/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters of AGS_ST_DMPagingAndSortingUtils.Dispute class
	*/
	@isTest static void shouldRetrieveDisputeGetters() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient                  = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction      = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute                  = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		AGS_ST_DMPagingAndSortingUtils.Dispute disputeWrap = new AGS_ST_DMPagingAndSortingUtils.Dispute(dispute);

		// WHEN
		//String address 				= disputeWrap.getAddress();
		Boolean isFromDM 			= disputeWrap.isFromDM();
		String disputeDate 			= disputeWrap.getDisputeDate();
		String spendActivityDate 	= disputeWrap.getSpendActivityDate();
		String paymentDate 			= disputeWrap.getPaymentDate();

		Decimal amount 				= (Decimal)disputeWrap.getValue('Amount_gne__c');
		String intenalStatus 		= (String)disputeWrap.getValue('Internal_Status_gne__c');
		String formOfPayment 		= (String)disputeWrap.getValue('Form_Of_Payment_gne__c');
		String natureOfPayment 		= (String)disputeWrap.getValue('Nature_Of_Payment_gne__c');
		String drugName 			= (String)disputeWrap.getValue('Drug_Name_gne__c');
		String recipientSpecialty 	= (String)disputeWrap.getValue('AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Specialty_gne__c');
		String recipientNpi 		= (String)disputeWrap.getValue('AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.NPI_gne__c');
		String recipientName 		= (String)disputeWrap.getValue('AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_Name_gne__c');
		String name 				= (String)disputeWrap.getValue('Name');
		String resolverOwnerName 	= (String)disputeWrap.getValue('Dispute_Resolver_gne__r.Owner.Name');
		String transactionnDate 	= (String)disputeWrap.getValue('AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c');
		String createdDate 			= (String)disputeWrap.getValue('CreatedDate');
		String lastModifiedDate 	= (String)disputeWrap.getValue('LastModifiedDate');
		String ownerName 			= (String)disputeWrap.getValue('Owner.Name');
		
		// THEN
		//System.assert( String.isNotBlank(address) );
		System.assert( !isFromDM );
		System.assert( String.isNotBlank(disputeDate) );
		System.assert( String.isNotBlank(spendActivityDate) );
		System.assert( String.isNotBlank(paymentDate) );

		System.assertEquals( 0, amount );
		System.assert( String.isNotBlank(intenalStatus) );
		System.assert( String.isBlank(formOfPayment) );
		System.assert( String.isBlank(natureOfPayment) );
		System.assert( String.isBlank(drugName) );
		System.assert( String.isBlank(recipientSpecialty) );
		System.assert( String.isBlank(recipientNpi) );
		//System.assert( String.isNotBlank(recipientName) );
		System.assert( String.isNotBlank(name) );
		System.assert( String.isBlank(resolverOwnerName) );
		System.assert( String.isNotBlank(transactionnDate) );
		System.assert( String.isNotBlank(createdDate) );
		System.assert( String.isNotBlank(lastModifiedDate) );
		System.assert( String.isBlank(ownerName) );
	}
}