/** @date 2/14/2014
* @Author Konrad Malinowski
* @description Test Class with methods for Event List Controller
*/
@isTest
private class VDST_EventListController_Test {
	
	/** @date 2/14/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters values
	*/
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		VDST_EventListController ctrl = new VDST_EventListController();

		// WHEN
		VDST_Utils.PrivilegesWrapper staticPrivileges = VDST_EventListController.getStaticPrivileges();

		// THEN
		System.assertEquals( VDST_EventListController.staticPrivileges, staticPrivileges );
		System.assertNotEquals( null, ctrl.usrName );
		System.assertNotEquals( null, ctrl.today );
	}

	/** @date 2/14/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for going to apex pages
	*/
	@isTest static void shouldGoToPages() {
		// GIVEN
		VDST_EventListController ctrl = new VDST_EventListController();

		// WHEN
		PageReference prLogOut 		= ctrl.logOut();
		PageReference prUserManag 	= ctrl.goToUserManagement();

		// THEN
		System.assertEquals( '/secur/logout.jsp', 			prLogOut.getUrl() );
		System.assertEquals( '/apex/VDST_Users_Management',	prUserManag.getUrl() );

		System.assert( prLogOut.getRedirect() && prUserManag.getRedirect() );
	}
	
	/** @date 2/14/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for removeEventsById(String jsonValue) method
	*/
	@isTest static void shouldSuccessfullyDeleteEvents() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		List<VDST_Event_gne__c> events = VDST_TestUtils.createVdstEvents( 'ADBOARD', 'PENDING', geneProvider );

		String eventsToDeleteJson = 
		'{"ids" : [' 					+
			'"' + events[0].Id + '",' 	+ 
			'"' + events[1].Id + '"' 	+
		']}';

		// WHEN
		Boolean areEventsDeleted = VDST_EventListController.removeEventsById( eventsToDeleteJson );

		// THEN
		System.assert( areEventsDeleted );
		for(VDST_Event_gne__c ev : [ SELECT CurrentStatus_gne__c FROM VDST_Event_gne__c ]) {
			System.assertEquals( 'DROPPED', ev.CurrentStatus_gne__c );
		}
	}

	/** @date 2/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getDataWrapperRemote() method
	*/
	@isTest static void shouldSuccessfullyRetrieveDataWrapper() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		List<VDST_Event_gne__c> events = VDST_TestUtils.createVdstEvents( 'ADBOARD', 'PENDING', geneProvider );
		List<VDST_Address_gne__c> addresses = VDST_TestUtils.createVdstAddresses( events );
		List<VDST_EventSite_gne__c> sites = new List<VDST_EventSite_gne__c>();
		for(Integer i = 0; i < events.size(); i++) {
			sites.add( VDST_TestUtils.initiateVdstSite( events[i], addresses[i] ) );
		}
		insert sites;
		for(VDST_EventSite_gne__c site : sites) {
			System.assertNotEquals( null, site.Id );
		}

		// WHEN
		VDST_EventListController.EventDataWrapper dataWrapper = VDST_EventListController.getDataWrapperRemote();

		// THEN
		Integer numberOfSites = 2;
		System.assert( !dataWrapper.moreRecords );
		System.assertEquals( numberOfSites, dataWrapper.fieldWrappers.size() );
		System.assertEquals( sites.size(), dataWrapper.fieldWrappers.size() ); 
	}

	/** @date 2/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getDataWrapperByFilterRemote(String filterJSONData) method
	*/
	@isTest static void shouldSuccessfullyRetrieveDataWrapperWithFilters() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		String eventType = 'ADBOARD';
		String eventStatus = 'PENDING';
		List<VDST_Event_gne__c> events = VDST_TestUtils.createVdstEvents( eventType, eventStatus, geneProvider );
		List<VDST_Address_gne__c> addresses = VDST_TestUtils.createVdstAddresses( events );
		List<VDST_EventSite_gne__c> sites = new List<VDST_EventSite_gne__c>();
		for(Integer i = 0; i < events.size(); i++) {
			sites.add( VDST_TestUtils.initiateVdstSite( events[i], addresses[i] ) );
		}
		insert sites;
		for(VDST_EventSite_gne__c site : sites) {
			System.assertNotEquals( null, site.Id );
		}

		String fromDate = DateTime.now().addMonths(-3).format('yyyy-MM-dd');
		String toDate = DateTime.now().addMonths(3).format('yyyy-MM-dd');
		String fromCreatedDate = DateTime.now().addDays(-1).format('MM/dd/yyyy hh:mm a');
		String toCreatedDate = DateTime.now().addDays(1).format('MM/dd/yyyy hh:mm a');
		String jsonString = 
		'{'															+
			'"LastModifiedByName": "' + UserInfo.getName() + '",'	+
			'"EventType_gne": "' + eventType + '",'					+
  			'"CurrentStatus_gne": "' + eventStatus + '",' 			+
			'"MasterDate_gne": {'									+
		    	'"from": "' + fromDate + '",'						+
		    	'"to": "' + toDate + '"'							+
		  	'},'													+
		  	'"TransactionDate_gne": {'								+
		    	'"from": "' + fromDate + '",'						+
		    	'"to": "' + toDate + '"'							+
		  	'},'													+
		  	'"CreatedDate": {'										+
		    	'"from": "' + fromCreatedDate + '",'				+
		    	'"to": "' + toCreatedDate + '"'						+
		  	'}'														+
		'}';

		// WHEN
		VDST_EventListController.EventDataWrapper dataWrapper = VDST_EventListController.getDataWrapperByFilterRemote(jsonString);

		// THEN
		Integer numberOfSites = 2;
		System.assert( !dataWrapper.moreRecords );
		System.assertEquals( numberOfSites, dataWrapper.fieldWrappers.size() );
		System.assertEquals( sites.size(), dataWrapper.fieldWrappers.size() ); 
	}

	/** @date 2/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getFilterList() method
	*/
	@isTest static void shouldSuccessfullyRetrieveFilterList() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		VDST_TestUtils.createFilter();

		// WHEN
		List<VDST_EventListController.FilterData> filterData = VDST_EventListController.getFilterList();

		// THEN
		Integer numberOfExistingFilters = 1;
		System.assertEquals( numberOfExistingFilters, filterData.size() );
	}

	/** @date 2/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getFilterDataByFilterId(String dataVal) method
	*/
	@isTest static void shouldSuccessfullyRetrieveFilterData() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		VDST_Filter_gne__c filter = VDST_TestUtils.createFilter();
		VDST_TestUtils.createFilterData(filter.Id);

		// WHEN
		VDST_EventListController.FilterHolder fHold = VDST_EventListController.getFilterDataByFilterId(filter.Id);

		// THEN
		Integer numberOfFilterFields = 12;
		System.assertEquals( numberOfFilterFields, fHold.fieldList.size() );
	}

	/** @date 2/18/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for removeFilterDataByFilterId(String dataVal) method
	*/
	@isTest static void shouldSuccessfullyDeleteFilter() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		VDST_Filter_gne__c filter = VDST_TestUtils.createFilter();
		VDST_TestUtils.createFilterData(filter.Id);

		// WHEN
		Boolean isFilterDeleted = VDST_EventListController.removeFilterDataByFilterId(filter.Id);

		// THEN
		System.assert(isFilterDeleted);
	}

	/** @date 2/18/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveFilterData(String filterJSONData) method
	*/
	@isTest static void shouldSuccessfullySaveFilter() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		String userName = UserInfo.getName();
		String jsonString =
		'{'														+
			'"fieldList": ['									+
		    	'{"columnVisibility": true,'					+
		    		'"filterName": "LogisticVendorCode_gne"},'	+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "VendorEventID_gne"},'		+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "LastModifiedDate"},'		+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "LastModifiedByName",'		+
		      		'"filterValue": "' + userName + '"},'		+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "EventType_gne"},'			+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "EventMeetingName_gne"},'	+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "EventSiteName_gne"},'		+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "CurrentStatus_gne"},'		+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "EventStartDate_gne"},'		+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "MasterDate_gne"},'			+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "TransactionDate_gne"},'		+
		    	'{"columnVisibility": true,'					+
		      		'"filterName": "CreatedDate"}'				+
			'],'												+
		 	'"filterName": "Test Filter",'						+
		  	'"filterId": "",'									+
		  	'"sortBy": "EventType_gne",'						+
		  	'"sortOrder": "ASC"'								+
		'}';	

		// WHEN
		VDST_EventListController.FilterData filterData = VDST_EventListController.saveFilterData(jsonString);

		// THEN
		System.assertNotEquals( null, filterData );
		Integer numberOfExistingFilters = 1;
		System.assertEquals( numberOfExistingFilters, [SELECT Id FROM VDST_Filter_gne__c].size() );
		Integer numberOfExistingFilterFields = 12;
		System.assertEquals( numberOfExistingFilterFields, [SELECT Id FROM VDST_FilterData_gne__c].size() );
		Integer numberOfQueriedFilterFields = 1;
		System.assertEquals( numberOfQueriedFilterFields, [SELECT Id FROM VDST_FilterData_gne__c WHERE FilterField_gne__c  = 'LastModifiedByName' AND FilterValue_gne__c = :userName].size() );
	}

	/** @date 2/18/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getColumnsWrapperRemote() method for Genentech users
	*/
	@isTest static void shouldSuccessfullyGetColumnsWrapperForGeneUser() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		// WHEN
		VDST_EventListController.InitDataWrapper initDataWrapper = VDST_EventListController.getColumnsWrapperRemote();

		// THEN
		System.assert( initDataWrapper.columnList.size() > 0 );
		System.assert( initDataWrapper.quickList.size() > 0 );
		System.assert( initDataWrapper.eventTypesList.size() > 0 );
	}

	/** @date 2/18/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getColumnsWrapperRemote() method for non-Genentech users
	*/
	@isTest static void shouldSuccessfullyGetColumnsWrapperForNonGeneUser() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c cdntProvider = providers[1];
		VDST_TestUtils.createVdstUser(cdntProvider);

		// WHEN
		VDST_EventListController.InitDataWrapper initDataWrapper = VDST_EventListController.getColumnsWrapperRemote();

		// THEN
		System.assert( initDataWrapper.columnList.size() > 0 );
		System.assert( initDataWrapper.quickList.size() > 0 );
		System.assert( initDataWrapper.eventTypesList.size() > 0 );
	}
}