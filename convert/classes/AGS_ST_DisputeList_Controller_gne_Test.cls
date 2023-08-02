/** @date 2/25/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Dispute List Controller
*/
@isTest
private class AGS_ST_DisputeList_Controller_gne_Test {
	
	/** @date 2/25/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for 
	*/
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		AGS_ST_TestUtils.createRecipientSpecialities();

		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();

		// WHEN
		Boolean isMaxDisputes = ctrl.isMaxDisputes;
		String disputeReportId = ctrl.getDisputesReportId();

		// THEN
		System.debug(isMaxDisputes);
		System.assertEquals( null, disputeReportId );
	}

	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getViews() method
	*/
	@isTest static void shouldGetViews() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();

		// WHEN
		List<SelectOption> selOpts = ctrl.getViews();
		
		// THEN
		System.assertNotEquals( 0, selOpts.size() );
	}

	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getNaturesOfPayment() method
	*/
	@isTest static void shouldGetNaturesOfPayment() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();

		// WHEN
		List<SelectOption> selOpts = ctrl.getNaturesOfPayment();
		
		// THEN
		System.assertNotEquals( 0, selOpts.size() );
	}

	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getFormsOfPayment() method
	*/
	@isTest static void shouldGetFormsOfPayment() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();

		// WHEN
		List<SelectOption> selOpts = ctrl.getFormsOfPayment();
		
		// THEN
		System.assertNotEquals( 0, selOpts.size() );
	}

	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getDrugNames() method
	*/
	@isTest static void shouldGetDrugNames() {
		// GIVEN
		List<AGS_Brand_gne__c> brands = AGS_ST_TestUtils.createBrands();
		Set<String> pickVals = new Set<String>{'All'};
		for(AGS_Brand_gne__c b : brands) {
			pickVals.add(b.Brand_Name__c);
		}

		// WHEN
		List<SelectOption> selOpts = (new AGS_ST_DisputeList_Controller_gne()).getDrugNames();
		
		// THEN
		System.assertEquals( pickVals.size(), selOpts.size() );
		for(SelectOption so : selOpts) {
			System.assert( pickVals.contains( so.getValue() ) );
		}
	}

	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getResolvers() method
	*/
	@isTest static void shouldGetResolvers() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();

		// WHEN
		List<SelectOption> selOpts = ctrl.getResolvers();

		// THEN
		System.assertNotEquals( 0,  selOpts.size() );
	}
	
	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getDisputes() method
	*/
	@isTest static void shouldGetDisputes() {
		// GIVEN
		String status = 'Submitted';
		List<AGS_ST_DisputeManagement_gne__c> disputes = AGS_ST_TestUtils.createDisputes(status);

		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.selectedView = status;

		// WHEN
		List<AGS_ST_DMPagingAndSortingUtils.Dispute> queriedDisputes = ctrl.getDisputes();

		// THEN
		System.assertEquals( disputes.size(), queriedDisputes.size() );
	}

	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updateView() method
	*/
	@isTest static void shouldGetDisputesSettingSortField() {
		// GIVEN
		String status = 'Submitted';
		List<AGS_ST_DisputeManagement_gne__c> disputes = AGS_ST_TestUtils.createDisputes(status);

		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.selectedView = status;

		// WHEN
		ctrl.disputeUtil.sortField = 'Dispute_Resolver_gne__r.Owner.Name';
		ctrl.updateView();
		List<AGS_ST_DMPagingAndSortingUtils.Dispute> queriedDisputes = ctrl.getDisputes();

		// THEN
		System.assertEquals( disputes.size(), queriedDisputes.size() );
	}


	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updateAssignedToMe() method
	*/
	@isTest static void shouldGetAssignedToMeDisputes() {
		// GIVEN
		String status = 'Assigned';
		List<AGS_ST_DisputeManagement_gne__c> disputes = AGS_ST_TestUtils.createDisputes(status);

		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.selectedView = status;
		ctrl.updateAssignedToMe();

		// WHEN
		List<AGS_ST_DMPagingAndSortingUtils.Dispute> queriedDisputes = ctrl.getDisputes();

		// THEN
		System.assertEquals( disputes.size(), queriedDisputes.size() );
	}
	
	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updateFilter() method
	*/
	@isTest static void shouldUpdateFiltersWithSettingValues() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		
		ctrl.isSubmitted 				= true;
		ctrl.isAssigned 				= true;
		ctrl.isInProgress 				= true;
		ctrl.isCorrectedPendingSSR 		= true;
		ctrl.isResolvedWithCorrection 	= true;
		ctrl.isResolvedNoCorrection 	= true;

		ctrl.amountFromStr 		= '0';
		ctrl.amountToStr 		= '10';
		ctrl.natureOfPaymet 	= 'Consulting Fee';
		ctrl.formOfPaymet 		= 'Cash or cash equivalent';
		ctrl.drugName 			= 'Avastin';
		ctrl.disputeName 		= 'D-0000001';
		ctrl.firstName 			= 'Mary';
		ctrl.lastName			= 'Jane';
		ctrl.state 				= 'California';
		ctrl.speciality 		= 'FAMILY MEDICINE';
		ctrl.resolver 			= UserInfo.getUserId();
		ctrl.disputeDateFromContainer.Payment_Date_gne__c 	= Date.today();
		ctrl.disputeDateToContainer.Payment_Date_gne__c 	= Date.today();
		ctrl.paymentDateFromContainer.Payment_Date_gne__c 	= Date.today();
		ctrl.paymentDateToContainer.Payment_Date_gne__c 	= Date.today();
		
		// WHEN
		ctrl.updateFilter();
		List<AGS_ST_DMPagingAndSortingUtils.Dispute> queriedDisputes = ctrl.getDisputes();

		// THEN
		System.assertEquals( 0, queriedDisputes.size() );
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveAsANewFilter() method
	*/
	@isTest static void shouldSaveNewFilterWithAllStatuses() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		ApexPages.currentPage().getParameters().put('namefilter', 'Test Filter Name');
		ctrl.isSubmitted 				= true;
		ctrl.isAssigned 				= true;
		ctrl.isInProgress 				= true;
		ctrl.isCorrectedPendingSSR 		= true;
		ctrl.isResolvedWithCorrection 	= true;
		ctrl.isResolvedNoCorrection 	= true;
		ctrl.amountFromStr				= '0';
		ctrl.amountToStr				= '10';

		// WHEN
		ctrl.saveAsANewFilter();

		// THEN
		List<SelectOption> savedFilters = ctrl.getSavedFilters();
		System.assertEquals( 2, savedFilters.size() );
		System.assertEquals( 'All', savedFilters[0].getValue() );
		System.assertEquals( 'Test Filter Name', savedFilters[1].getValue() );
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveAsANewFilter() method
	*/
	@isTest static void shouldSaveNewFilterWithStatusAssigned() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		ApexPages.currentPage().getParameters().put('namefilter', 'Test Filter Name');
		ctrl.isAssigned 	= true;
		ctrl.amountFromStr	= null;
		ctrl.amountToStr	= null;

		// WHEN	
		ctrl.saveAsANewFilter();

		// THEN
		Integer numberOfExistingFilters = [SELECT Name FROM AGS_ST_SearchFilter_gne__c].size();
		System.assertEquals(1, numberOfExistingFilters);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveAsANewFilter() method
	*/
	@isTest static void shouldSaveNewFilterWithStatusInProgress() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		ApexPages.currentPage().getParameters().put('namefilter', 'Test Filter Name');
		ctrl.isInProgress 	= true;
		ctrl.amountFromStr	= 'invalid';
		ctrl.amountToStr	= 'invalid';

		// WHEN
		ctrl.saveAsANewFilter();

		// THEN
		Integer numberOfExistingFilters = [SELECT Name FROM AGS_ST_SearchFilter_gne__c].size();
		System.assertEquals(1, numberOfExistingFilters);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveAsANewFilter() method
	*/
	@isTest static void shouldSaveNewFilterWithStatusCorrectedPendingSSR() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		ApexPages.currentPage().getParameters().put('namefilter', 'Test Filter Name');
		ctrl.isCorrectedPendingSSR 	= true;

		// WHEN
		ctrl.saveAsANewFilter();

		// THEN
		Integer numberOfExistingFilters = [SELECT Name FROM AGS_ST_SearchFilter_gne__c].size();
		System.assertEquals(1, numberOfExistingFilters);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveAsANewFilter() method
	*/
	@isTest static void shouldSaveNewFilterWithStatusResolvedWithCorrection() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		ApexPages.currentPage().getParameters().put('namefilter', 'Test Filter Name');
		ctrl.isResolvedWithCorrection 	= true;

		// WHEN
		ctrl.saveAsANewFilter();

		// THEN
		Integer numberOfExistingFilters = [SELECT Name FROM AGS_ST_SearchFilter_gne__c].size();
		System.assertEquals(1, numberOfExistingFilters);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveAsANewFilter() method
	*/
	@isTest static void shouldSaveNewFilterWithStatusResolvedNoCorrection() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		ApexPages.currentPage().getParameters().put('namefilter', 'Test Filter Name');
		ctrl.isResolvedNoCorrection 	= true;

		// WHEN
		ctrl.saveAsANewFilter();

		// THEN
		Integer numberOfExistingFilters = [SELECT Name FROM AGS_ST_SearchFilter_gne__c].size();
		System.assertEquals(1, numberOfExistingFilters);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for RemoveFilter() method
	*/
	@isTest static void shouldRemoveFilter() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		String filterName = 'Test Filter Name';
		ApexPages.currentPage().getParameters().put('namefilter', filterName);
		ctrl.saveAsANewFilter();

		// WHEN
		ctrl.selectedFilterName = filterName;
		ctrl.RemoveFilter();

		// THEN
		Integer numberOfExistingFilters = [SELECT Name FROM AGS_ST_SearchFilter_gne__c].size();
		System.assertEquals(0, numberOfExistingFilters);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for SaveFilter() method
	*/
	@isTest static void shouldUpdateFilterWithAllStatuses() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		String filterName = 'Test Filter Name';
		ApexPages.currentPage().getParameters().put('namefilter', filterName);
		ctrl.saveAsANewFilter();

		// WHEN
		ctrl.selectedFilterName = filterName;
		ctrl.isSubmitted 				= true;
		ctrl.isAssigned 				= true;
		ctrl.isInProgress 				= true;
		ctrl.isCorrectedPendingSSR 		= true;
		ctrl.isResolvedWithCorrection 	= true;
		ctrl.isResolvedNoCorrection 	= true;
		ctrl.amountFromStr				= '0';
		ctrl.amountToStr				= '10';
		Date today = Date.today();
		ctrl.disputeDateFromContainer.Payment_Date_gne__c 	= today.addDays(1);
		ctrl.disputeDateToContainer.Payment_Date_gne__c 	= today.addDays(2);
		ctrl.paymentDateFromContainer.Payment_Date_gne__c 	= today.addDays(3);
		ctrl.paymentDateToContainer.Payment_Date_gne__c 	= today.addDays(4);
		ctrl.SaveFilter();

		// THEN
		AGS_ST_SearchFilter_gne__c updatedFilter = 
			[SELECT Name, 
				Amount_From__c, 			Amount_To__c, 
				Date_of_Payment_From__c, 	Date_of_Payment_To__c, 
				Dispute_Date_From__c, 		Dispute_Date_To__c,
				Dispute_Name__c, 			Drug_Name__c, 
				Form_of_Payment__c, 		Nature_of_Payment__c, 
				Physician_First_Name__c, 	Physician_Last_Name__c, 
				Resolver__c, Speciality__c, State__c, Status__c, Id 
			FROM AGS_ST_SearchFilter_gne__c 
			WHERE Name = :filterName
			LIMIT 1];
		System.assertEquals('Assigned;Corrected Pending SSR;In Progress;' 
			+ 'Resolved No Correction;Resolved With Correction;Submitted', updatedFilter.Status__c);
		System.assertEquals(0, 					updatedFilter.Amount_From__c			);
		System.assertEquals(10, 				updatedFilter.Amount_To__c				);
		System.assertEquals(today.addDays(1), 	updatedFilter.Dispute_Date_From__c		);
		System.assertEquals(today.addDays(2), 	updatedFilter.Dispute_Date_To__c		);
		System.assertEquals(today.addDays(3), 	updatedFilter.Date_of_Payment_From__c	);
		System.assertEquals(today.addDays(4), 	updatedFilter.Date_of_Payment_To__c		);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for SaveFilter() method
	*/
	@isTest static void shouldUpdateFilterWithStatusAssigned() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		String filterName = 'Test Filter Name';
		ApexPages.currentPage().getParameters().put('namefilter', filterName);
		ctrl.saveAsANewFilter();

		// WHEN
		ctrl.selectedFilterName = filterName;
		ctrl.isAssigned 	= true;
		ctrl.amountFromStr	= null;
		ctrl.amountToStr	= null;
		ctrl.SaveFilter();

		// THEN
		AGS_ST_SearchFilter_gne__c updatedFilter = 
			[SELECT Amount_From__c, Amount_To__c, Status__c
			FROM AGS_ST_SearchFilter_gne__c 
			WHERE Name = :filterName
			LIMIT 1];
		System.assertEquals('Assigned', updatedFilter.Status__c		);
		System.assertEquals(null, 		updatedFilter.Amount_From__c);
		System.assertEquals(null, 		updatedFilter.Amount_To__c	);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for SaveFilter() method
	*/
	@isTest static void shouldUpdateFilterWithStatusInProgress() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		String filterName = 'Test Filter Name';
		ApexPages.currentPage().getParameters().put('namefilter', filterName);
		ctrl.saveAsANewFilter();

		// WHEN
		ctrl.selectedFilterName = filterName;
		ctrl.isInProgress 	= true;
		ctrl.amountFromStr	= 'invalid';
		ctrl.amountToStr	= 'invalid';
		ctrl.SaveFilter();

		// THEN
		AGS_ST_SearchFilter_gne__c updatedFilter = 
			[SELECT Amount_From__c, Amount_To__c, Status__c
			FROM AGS_ST_SearchFilter_gne__c 
			WHERE Name = :filterName
			LIMIT 1];
		System.assertEquals('In Progress', 	updatedFilter.Status__c		);
		System.assertEquals(null, 			updatedFilter.Amount_From__c);
		System.assertEquals(null, 			updatedFilter.Amount_To__c	);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for SaveFilter() method
	*/
	@isTest static void shouldUpdateFilterWithStatusCorrectedPendingSSR() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		String filterName = 'Test Filter Name';
		ApexPages.currentPage().getParameters().put('namefilter', filterName);
		ctrl.saveAsANewFilter();

		// WHEN
		ctrl.selectedFilterName = filterName;
		ctrl.isCorrectedPendingSSR = true;
		ctrl.SaveFilter();

		// THEN
		AGS_ST_SearchFilter_gne__c updatedFilter = 
			[SELECT Amount_From__c, Amount_To__c, Status__c
			FROM AGS_ST_SearchFilter_gne__c 
			WHERE Name = :filterName
			LIMIT 1];
		System.assertEquals('Corrected Pending SSR', updatedFilter.Status__c);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for SaveFilter() method
	*/
	@isTest static void shouldUpdateFilterWithStatusResolvedWithCorrection() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		String filterName = 'Test Filter Name';
		ApexPages.currentPage().getParameters().put('namefilter', filterName);
		ctrl.saveAsANewFilter();

		// WHEN
		ctrl.selectedFilterName = filterName;
		ctrl.isResolvedWithCorrection = true;
		ctrl.SaveFilter();

		// THEN
		AGS_ST_SearchFilter_gne__c updatedFilter = 
			[SELECT Amount_From__c, Amount_To__c, Status__c
			FROM AGS_ST_SearchFilter_gne__c 
			WHERE Name = :filterName
			LIMIT 1];
		System.assertEquals('Resolved With Correction', updatedFilter.Status__c);
	}

	/** @date 2/27/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for SaveFilter() method
	*/
	@isTest static void shouldUpdateFilterWithStatusResolvedNoCorrection() {
		// GIVEN
		AGS_ST_DisputeList_Controller_gne ctrl = new AGS_ST_DisputeList_Controller_gne();
		ctrl.clearFilterList();
		String filterName = 'Test Filter Name';
		ApexPages.currentPage().getParameters().put('namefilter', filterName);
		ctrl.saveAsANewFilter();

		// WHEN
		ctrl.selectedFilterName = filterName;
		ctrl.isResolvedNoCorrection = true;
		ctrl.SaveFilter();

		// THEN
		AGS_ST_SearchFilter_gne__c updatedFilter = 
			[SELECT Amount_From__c, Amount_To__c, Status__c
			FROM AGS_ST_SearchFilter_gne__c 
			WHERE Name = :filterName
			LIMIT 1];
		System.assertEquals('Resolved No Correction', updatedFilter.Status__c);
	}
}