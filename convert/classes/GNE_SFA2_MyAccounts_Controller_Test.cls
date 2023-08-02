/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-03-14
*  This is a test class for GNE_SFA2_MyAccounts_Controller
*
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_MyAccounts_Controller_Test {

	public static testMethod void testInitialization(){
		User sfa2User = selectSFA2UserWithTerritory();
		System.runAs(sfa2User){
			Product_vod__c product = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
			product.Name='Avastin';
			insert product;
			GNE_SFA2_My_Accounts_Setttings__c settings = new GNE_SFA2_My_Accounts_Setttings__c(PageSize_gne__c=23, Roles_With_Territory_Hierarchy_gne__c='', Application_Type__c = null, Role_gne__c = null, Brand_gne__c = null);
			insert settings;
	        GNE_SFA2_MyAccounts_Controller controller = new GNE_SFA2_MyAccounts_Controller();
	        system.assertEquals(false, controller.isMedAffair);
	        system.assertEquals(23, controller.PAGE_SIZE);
	        system.assertEquals('ASC', controller.sortDirection);
	        system.assertEquals('All', controller.filterLetter);
	        system.assertEquals(true, controller.userTerritoriesExist);
	        system.assertEquals(1, controller.accountViewsSelectOptions.size());
	        system.assertEquals('', controller.accountViewsSelectOptions[0].getValue());
	        system.assertEquals('No Views Defined', controller.accountViewsSelectOptions[0].getLabel());
	        system.assertEquals(null, controller.loadRecords());
	        system.assertEquals(0, controller.viewWrappers.size());
	        delete settings;
	       	insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'MedAffairs', Role_gne__c = 'CS', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

			createConfiguration('MedAffairs', 'CS', product.Id);

			//test with isExportToExcel flag set to false
	       	controller = new GNE_SFA2_MyAccounts_Controller();
	       	system.assertEquals(true, controller.isMedAffair);
	       	system.assertEquals(50, controller.PAGE_SIZE);
	      	system.assertEquals('ASC', controller.sortDirection);
	       	system.assertEquals('All', controller.filterLetter);
	       	system.assertEquals(true, controller.userTerritoriesExist);
	       	system.assertEquals(3, controller.accountViewsSelectOptions.size());
	        system.assertEquals('PrivateTest', controller.accountViewsSelectOptions[0].getLabel());
	        system.assertEquals('PublicTest', controller.accountViewsSelectOptions[1].getLabel());
	        system.assertEquals('RestrictedTest', controller.accountViewsSelectOptions[2].getLabel());

	        system.assertEquals(UserInfo.getUserId(), controller.selectedView.OwnerId);
	        system.assertEquals('PrivateTest', controller.selectedView.View_Name_gne__c);
	        system.assertEquals('Account.Name;Address.Name;Address.City_vod__c;Address.State_vod__c;BrandAffiliation.'+product.Id+'.Tier_gne__c;', controller.selectedView.View_Fields_gne__c);
	        system.assertEquals('Account.Name', controller.selectedView.Sorting_Field_gne__c);
	        system.assertEquals('[]', controller.selectedView.Filter_Statement_gne__c);
	        system.assertEquals(null, controller.selectedView.Person_Record_Types_gne__c);
	        system.assertEquals('Institution_vod, Board_vod, Agency_gne', controller.selectedView.Account_Record_Types_gne__c);

	        system.assertEquals(0, controller.recordsCount);
	        system.assertEquals(0, controller.offset);
	        system.assertEquals(1, controller.pageNumber);
	        system.assertEquals(true, controller.containsBrandAffiliationColumn);

	        system.assertEquals(5, controller.viewColumns.size());
			system.assertEquals(('Account.Name;Address.Name;Address.City_vod__c;Address.State_vod__c;BrandAffiliation.'+product.Id+'.Tier_gne__c;').split(';'), controller.viewColumns);

			system.assertNotEquals(null, controller.columnsHeaders);
	        system.assertEquals('Name', controller.columnsHeaders.get('Account.Name'));
	        system.assertEquals('Street Address', controller.columnsHeaders.get('Address.Name'));
	        system.assertEquals('City', controller.columnsHeaders.get('Address.City_vod__c'));
	        system.assertEquals('State', controller.columnsHeaders.get('Address.State_vod__c'));
	        system.assertEquals('Avastin - Tier', controller.columnsHeaders.get('BrandAffiliation.'+product.Id+'.Tier_gne__c'));

	        system.assertNotEquals(null, controller.columnsHeadersType);
	        system.assertEquals('STRING', controller.columnsHeadersType.get('Account.Name'));
	        system.assertEquals('STRING', controller.columnsHeadersType.get('Address.Name'));
	        system.assertEquals('STRING', controller.columnsHeadersType.get('Address.City_vod__c'));
	        system.assertEquals('PICKLIST', controller.columnsHeadersType.get('Address.State_vod__c'));
	        system.assertEquals('PICKLIST', controller.columnsHeadersType.get('BrandAffiliation.'+product.Id+'.Tier_gne__c'));

	        system.assertEquals('Account.Name', controller.sortColumn);

	        //test with isExportToExcel flag set to true
	        controller = new GNE_SFA2_MyAccounts_Controller(true);
	       	system.assertEquals(true, controller.isMedAffair);
	       	system.assertEquals(50, controller.PAGE_SIZE);
	      	system.assertEquals('ASC', controller.sortDirection);
	       	system.assertEquals('All', controller.filterLetter);
	       	system.assertEquals(true, controller.userTerritoriesExist);
	       	system.assertEquals(3, controller.accountViewsSelectOptions.size());
	        system.assertEquals('PrivateTest', controller.accountViewsSelectOptions[0].getLabel());
	        system.assertEquals('PublicTest', controller.accountViewsSelectOptions[1].getLabel());
	        system.assertEquals('RestrictedTest', controller.accountViewsSelectOptions[2].getLabel());

	        system.assertEquals(UserInfo.getUserId(), controller.selectedView.OwnerId);
	        system.assertEquals('PrivateTest', controller.selectedView.View_Name_gne__c);
	        system.assertEquals('Account.Name;Address.Name;Address.City_vod__c;Address.State_vod__c', controller.selectedView.View_Fields_gne__c);
	        system.assertEquals('Account.Name', controller.selectedView.Sorting_Field_gne__c);
	        system.assertEquals('[]', controller.selectedView.Filter_Statement_gne__c);
	        system.assertEquals(null, controller.selectedView.Person_Record_Types_gne__c);
	        system.assertEquals('Institution_vod, Board_vod, Agency_gne', controller.selectedView.Account_Record_Types_gne__c);

	        system.assertEquals(0, controller.recordsCount);
	        system.assertEquals(0, controller.offset);
	        system.assertEquals(1, controller.pageNumber);
	        system.assertEquals(false, controller.containsBrandAffiliationColumn);

	        system.assertEquals(4, controller.viewColumns.size());
	        system.assertEquals('Account.Name;Address.Name;Address.City_vod__c;Address.State_vod__c'.split(';'), controller.viewColumns);

	        system.assertNotEquals(null, controller.columnsHeaders);
	        system.assertEquals('Name', controller.columnsHeaders.get('Account.Name'));
	        system.assertEquals('Street Address', controller.columnsHeaders.get('Address.Name'));
	        system.assertEquals('City', controller.columnsHeaders.get('Address.City_vod__c'));
	        system.assertEquals('State', controller.columnsHeaders.get('Address.State_vod__c'));

	        system.assertNotEquals(null, controller.columnsHeadersType);
	        system.assertEquals('STRING', controller.columnsHeadersType.get('Account.Name'));
	        system.assertEquals('STRING', controller.columnsHeadersType.get('Address.Name'));
	        system.assertEquals('STRING', controller.columnsHeadersType.get('Address.City_vod__c'));
	        system.assertEquals('PICKLIST', controller.columnsHeadersType.get('Address.State_vod__c'));

	        system.assertEquals('Account.Name', controller.sortColumn);
	        Test.startTest();
	        system.assertEquals(null, controller.loadRecords());
	        system.assertEquals(0, controller.viewWrappers.size());
	        insertAccountsAndTSF();
	        controller = new GNE_SFA2_MyAccounts_Controller();
	        system.assertEquals(null, controller.loadRecords());
	        system.assertEquals(50, controller.viewWrappers.size());
	        Test.stopTest();
	    }
	}

	public static testMethod void testPrepareFieldReferenceMaps(){
		List<String> columns = new List<String>{
			'Account.Owner.Name',
			'Account.LastModifiedById',
			'Account.RecordTypeId',
			'Account.ParentId',
			'Account.NumberOfEmployees',
			'Account.InvalidFieldName',
			'Address.CreatedBy.Name',
			'Address.LastModifiedById',
			'Address.RecordTypeId',
			'Address.SystemModstamp',
			'Address.InvalidFieldName',
			'BrandAffiliation.CreatedBy.Name',
			'BrandAffiliation.LastModifiedById',
			'BrandAffiliation.RecordTypeId',
			'BrandAffiliation.SystemModstamp',
			'BrandAffiliation.InvalidFieldName',
			'TSF.CreatedBy.Name',
			'TSF.LastModifiedById',
			'TSF.SystemModstamp',
			'TSF.InvalidFieldName'
		};
		GNE_SFA2_MyAccounts_Controller controller = new GNE_SFA2_MyAccounts_Controller();
		controller.prepareFieldReferenceMaps(columns);

		system.assertNotEquals(null, controller.fieldOfUserReferenceMap);
		system.assertNotEquals(null, controller.userReferenceHasExist);
		system.assertNotEquals(null, controller.fieldReferenceToExportMap);
		system.assertNotEquals(null, controller.fieldReferenceToExportHasExist);
		system.debug('userReferenceHasExist: ' + controller.userReferenceHasExist.keySet());
		system.debug('fieldReferenceToExportMap: ' + controller.fieldReferenceToExportMap);
		system.debug('fieldReferenceToExportHasExist: ' + controller.fieldReferenceToExportHasExist);
		//Account fields
		system.assertEquals(false, controller.userReferenceHasExist.get('Account.Owner.Name'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('Account.Owner.Name'));

		system.assertEquals('Account.LastModifiedBy.Name', controller.fieldOfUserReferenceMap.get('Account.LastModifiedById'));
		system.assertEquals('Account.LastModifiedBy.Name', controller.fieldReferenceToExportMap.get('Account.LastModifiedById'));
		system.assertEquals(true, controller.userReferenceHasExist.get('Account.LastModifiedById'));
		system.assertEquals(true, controller.fieldReferenceToExportHasExist.get('Account.LastModifiedById'));

		system.assertEquals(false, controller.userReferenceHasExist.get('Account.RecordTypeId'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('Account.RecordTypeId'));

		system.assertEquals('Account.Parent.Name', controller.fieldReferenceToExportMap.get('Account.ParentId'));
		system.assertEquals(false, controller.userReferenceHasExist.get('Account.ParentId'));
		system.assertEquals(true, controller.fieldReferenceToExportHasExist.get('Account.ParentId'));

		system.assertEquals(false, controller.userReferenceHasExist.get('Account.NumberOfEmployees'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('Account.NumberOfEmployees'));

		system.assertEquals(false, controller.userReferenceHasExist.get('Account.InvalidFieldName'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('Account.InvalidFieldName'));

		//Address fields
		system.assertEquals(false, controller.userReferenceHasExist.get('Address.CreatedBy.Name'));

		system.assertEquals('Address.LastModifiedBy.Name', controller.fieldOfUserReferenceMap.get('Address.LastModifiedById'));
		system.assertEquals('Address.LastModifiedBy.Name', controller.fieldReferenceToExportMap.get('Address.LastModifiedById'));
		system.assertEquals(true, controller.userReferenceHasExist.get('Address.LastModifiedById'));
		system.assertEquals(true, controller.fieldReferenceToExportHasExist.get('Address.LastModifiedById'));

		system.assertEquals(false, controller.userReferenceHasExist.get('Address.RecordTypeId'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('Address.RecordTypeId'));

		system.assertEquals(false, controller.userReferenceHasExist.get('Address.SystemModstamp'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('Address.SystemModstamp'));

		system.assertEquals(false, controller.userReferenceHasExist.get('Address.InvalidFieldName'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('Address.InvalidFieldName'));

		//BrandAffiliation fields
		system.assertEquals(false, controller.userReferenceHasExist.get('BrandAffiliation.CreatedBy.Name'));

		system.assertEquals('BrandAffiliation.LastModifiedBy.Name', controller.fieldOfUserReferenceMap.get('BrandAffiliation.LastModifiedById'));
		system.assertEquals('BrandAffiliation.LastModifiedBy.Name', controller.fieldReferenceToExportMap.get('BrandAffiliation.LastModifiedById'));
		system.assertEquals(true, controller.userReferenceHasExist.get('BrandAffiliation.LastModifiedById'));
		system.assertEquals(true, controller.fieldReferenceToExportHasExist.get('BrandAffiliation.LastModifiedById'));

		system.assertEquals(false, controller.userReferenceHasExist.get('BrandAffiliation.RecordTypeId'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('BrandAffiliation.RecordTypeId'));

		system.assertEquals(false, controller.userReferenceHasExist.get('BrandAffiliation.SystemModstamp'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('BrandAffiliation.SystemModstamp'));

		system.assertEquals(false, controller.userReferenceHasExist.get('BrandAffiliation.InvalidFieldName'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('BrandAffiliation.InvalidFieldName'));

		//TSF fields
		system.assertEquals(false, controller.userReferenceHasExist.get('TSF.CreatedBy.Name'));

		system.assertEquals('TSF.LastModifiedBy.Name', controller.fieldOfUserReferenceMap.get('TSF.LastModifiedById'));
		system.assertEquals('TSF.LastModifiedBy.Name', controller.fieldReferenceToExportMap.get('TSF.LastModifiedById'));
		system.assertEquals(true, controller.userReferenceHasExist.get('TSF.LastModifiedById'));
		system.assertEquals(true, controller.fieldReferenceToExportHasExist.get('TSF.LastModifiedById'));

		system.assertEquals(false, controller.userReferenceHasExist.get('TSF.SystemModstamp'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('TSF.SystemModstamp'));

		system.assertEquals(false, controller.userReferenceHasExist.get('TSF.InvalidFieldName'));
		system.assertEquals(false, controller.fieldReferenceToExportHasExist.get('TSF.InvalidFieldName'));
	}

	public static testMethod void testPageReferences(){
		GNE_SFA2_MyAccounts_Controller controller;
		PageReference pr;
		User sfa2User = selectSFA2UserWithTerritory();
		System.runAs(sfa2User){
			Product_vod__c product = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
			product.Name='Avastin';
			insert product;
			insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'SFA-US', Role_gne__c = 'CS', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());
			createConfiguration('SFA-US', 'CS', product.Id);

			controller = new GNE_SFA2_MyAccounts_Controller();
	        system.assertEquals(0, controller.offset);
	        system.assertEquals(1, controller.pageNumber);
	        system.assertEquals(null, controller.nextPage());
			system.assertEquals(0, controller.offset);
	        system.assertEquals(1, controller.pageNumber);
			insertAccountsAndTSF();
			controller = new GNE_SFA2_MyAccounts_Controller();
			system.assertEquals(null, controller.userIdToViewLink);
			pr = controller.overrideUserViewLink();
			system.assert(pr.getUrl().contains('/apex/GNE_SFA2_User_Layout'), 'Wrong URL');
			system.assertEquals(true, pr.getRedirect());
			controller.userIdToViewLink = UserInfo.getUserId();

			pr = controller.overrideUserViewLink();
			system.assert(pr.getUrl().contains('/apex/GNE_SFA2_User_Layout'), 'Wrong URL');
			system.assertEquals(true, pr.getRedirect());
			system.assertEquals(UserInfo.getUserId(), pr.getParameters().get('Id'));

			Test.startTest();
			controller.loadRecords();
			controller.recordsCount = 100;
	        system.assertEquals(0, controller.offset);
	        system.assertEquals(1, controller.pageNumber);
	        system.assertEquals(null, controller.nextPage());
	        system.assertEquals(2, controller.pageNumber);
			system.assertEquals(50, controller.offset);
			system.assertEquals(null, controller.previousPage());
	        system.assertEquals(1, controller.pageNumber);
			system.assertEquals(0, controller.offset);
			system.assertEquals(null, controller.previousPage());
	        system.assertEquals(1, controller.pageNumber);
			system.assertEquals(0, controller.offset);

			system.assertEquals(true, controller.getDisablePrevious());
			controller.offset=1;
			system.assertEquals(false, controller.getDisablePrevious());

			system.assertEquals(false, controller.getDisableNext());
			controller.pageNumber=7;
			system.assertEquals(true, controller.getDisableNext());

	        system.assertEquals(null, controller.changeSelectedView());
	        system.assertEquals(1, controller.pageNumber);
			system.assertEquals(0, controller.offset);

			controller.offset=1;
			controller.pageNumber=7;

			system.assertEquals(null, controller.changeFiltering());
	        system.assertEquals(1, controller.pageNumber);
			system.assertEquals(0, controller.offset);

			system.assertEquals(true, controller.getIsViewEditable());
		}
		User u = GNE_SFA2_Util.selectSFA2User();
		system.runAs(u){
			system.assertEquals(false, controller.getIsViewEditable());
		}
		System.runAs(sfa2User){
			pr = controller.newClick();
			system.assert(pr.getUrl().contains('/apex/gne_sfa2_sbc'), 'Wrong URL');
			system.assertEquals(true, pr.getRedirect());

			controller.viewWrappers[0].selected=true;
			GNE_SFA2_MyAccounts_Controller.ViewWrapper vw = controller.viewWrappers[0];
			GNE_SFA2_MyAccounts_Controller.ViewWrapper vw2 = controller.viewWrappers[1];

			pr = controller.scheduleInteractionClick();
			system.assert(pr.getUrl().contains(Page.GNE_SFA2_MyAccounts_InteractionScheduler.getUrl()), 'Wrong URL');
			system.assertEquals(true, pr.getRedirect());

			pr = controller.multipleInteractionClick();
			system.assert(pr.getUrl().contains(Page.GNE_SFA2_Interaction_Edit_Create.getUrl()), 'Wrong URL');
			system.assertEquals(true, pr.getRedirect());
			system.assertEquals('apex/GNE_SFA2_MyAccounts', pr.getParameters().get('retURL'));

			system.assertEquals(null, controller.refreshSelectedAccounts());
			List<String> selectedAccounts = controller.getSelectedAccounts();
			system.assertEquals(1, selectedAccounts.size());
			system.assertEquals(vw.accountId, selectedAccounts[0]);
			controller.viewWrappers[1].selected=true;
			selectedAccounts = controller.getSelectedAccounts();
			system.assertEquals(2, selectedAccounts.size());
			system.assertEquals(vw.accountId, selectedAccounts[0]);
			system.assertEquals(vw2.accountId, selectedAccounts[1]);

			system.assertEquals(2, controller.getSelectedTSFs().size());

			pr = controller.editView();
			system.assert(pr.getUrl().contains(Page.GNE_SFA2_My_Accounts_View_Setup.getUrl()), 'Wrong URL');
			system.assertEquals(true, pr.getRedirect());

			pr = controller.createView();
			system.assert(pr.getUrl().contains(Page.GNE_SFA2_My_Accounts_View_Setup.getUrl()), 'Wrong URL');
			system.assertEquals(true, pr.getRedirect());

			pr = controller.exportToExcelClick();
			system.assert(pr.getUrl().contains('/apex/GNE_SFA2_MyAccounts_Export'), 'Wrong URL');
			system.assertEquals(false, pr.getRedirect());
			system.assertEquals('ASC', pr.getParameters().get('sortDirection'));

			Test.stopTest();
		}
	}

	public static testMethod void testGetConfiguration(){
		GNE_SFA2_MyAccounts_Controller controller = new GNE_SFA2_MyAccounts_Controller();

		insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'SFA-US', Role_gne__c = 'CS');
		system.assertEquals('', controller.getListPageName());
		system.assertEquals('', controller.getActiveMenuItem());

        createConfiguration('SFA-US', 'CS', null);

        controller = new GNE_SFA2_MyAccounts_Controller();
        system.assertEquals('My Accounts', controller.getListPageName());
        system.assertEquals('My Accounts', controller.getActiveMenuItem());

		Component.Apex.PageBlockButtons buttons = controller.getCustomButtons();
        system.assertEquals('top', buttons.location);
        List<ApexPages.Component> buttonsList = buttons.childComponents;
        system.assertEquals(2, buttonsList.size());
        Map<String, Component.Apex.CommandButton> buttonLabelToButton = new Map<String, Component.Apex.CommandButton>();
        for(ApexPages.Component cb :buttonsList){
        	Component.Apex.CommandButton commandButton = (Component.Apex.CommandButton) cb;
        	buttonLabelToButton.put(String.valueOf(commandButton.value),  commandButton);
        	system.assertEquals(false, commandButton.disabled);
        	system.assertEquals(null, commandButton.style);
        }

        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();

        Component.Apex.CommandButton buttonBeingTested = buttonLabelToButton.get('Plan/ Record an Interaction');
        system.assertEquals(null, buttonBeingTested.id);
        system.assertEquals('#{scheduleInteractionClick}', buttonBeingTested.action.getExpression());
        system.assertEquals('image-button sfa-plh sfa-plh-action-bar', buttonBeingTested.styleClass);
        system.assertEquals('img/icon-interact.png', buttonBeingTested.dir);
        system.assertEquals(null, buttonBeingTested.onclick);
        system.assertEquals(new Set<String>{'main-content', 'test'}, buttonBeingTested.rerender);
        system.assertEquals(true, buttonBeingTested.immediate);

        buttonBeingTested = buttonLabelToButton.get('Export To Excel');
        system.assertEquals(null, buttonBeingTested.id);
        system.assertEquals('#{exportToExcelClick}', buttonBeingTested.action.getExpression());
        system.assertEquals('image-button sfa-plh sfa-plh-action-bar button export-to-excel', buttonBeingTested.styleClass);
        system.assertEquals(null, buttonBeingTested.dir);
        system.assertEquals('doNothing', buttonBeingTested.onclick);
        system.assertEquals(new Set<String>{null}, buttonBeingTested.rerender);
        system.assertEquals(false, buttonBeingTested.immediate);
	}

	public static testMethod void  testSortByBrandAffiliationAndSomeGetterMethods(){
		User sfa2User = selectSFA2UserWithTerritory();
		System.runAs(sfa2User){
			
			Product_vod__c product = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
			product.Name='Avastin';
			insert product;
			insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'SFA-US', Role_gne__c = 'CS', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());
			insertHCPAndTSF(10);
			createConfiguration('SFA-US', 'CS', product.Id);
			GNE_SFA2_MyAccounts_Controller controller = new GNE_SFA2_MyAccounts_Controller();
			system.assertEquals('PublicTest', controller.accountViewsSelectOptions[1].getLabel());
	       	controller.selectedViewId = controller.accountViewsSelectOptions[1].getValue();
	       	controller.changeSelectedView();
	       	system.assertEquals('BrandAffiliation.'+product.Id+'.Tier_gne__c', controller.sortColumn);
	       	controller.changeSorting();
	       	system.assertEquals('DESC', controller.sortDirection);

	       	controller.changeSorting();
	       	system.assertEquals('ASC', controller.sortDirection);
	       	controller.sortColumn = 'Address.Name';
	       	controller.changeSorting();
	       	system.assertEquals('ASC', controller.sortDirection);
	       	system.assertEquals('PublicTest - '+String.valueOf(Date.Today()), controller.getFileName());
	       	system.assertEquals(null, controller.getHostName());
	       	PageReference currentPage = Page.GNE_SFA2_MyAccounts;
	       	currentPage.getParameters().put('selectedViewId', controller.selectedViewId);
	       	Test.setCurrentPage(currentPage);
	       	system.assertEquals(currentPage.getHeaders().get('host'), controller.getHostName());
	       	String workbookProp = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>PublicTest</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
	       	system.assertEquals(workbookProp, controller.getWorkbookProperties());
	       	controller.newValue = 'notaligned';
	       	controller.massUpdateMessage = 'test';
            Test.startTest();
	       	system.assertEquals(null, controller.updateAlignment());
	       	system.assertEquals('', controller.massUpdateMessage);
	       	controller.newValue = 'myview';
	       	controller.massUpdateMessage = 'test';
	       	system.assertEquals(null, controller.updateAlignment());
	       	system.assertEquals('', controller.massUpdateMessage);
			Test.stopTest();
	    }
	}

	public static testMethod void  testExportToExcel(){
		User sfa2User = selectSFA2UserWithTerritory();
		System.runAs(sfa2User){
			Test.startTest();
			Product_vod__c product = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
			product.Name='Avastin';
			insert product;
			insertHCPAndTSF(10);
			createConfiguration('SFA-US', 'CS', product.Id);
			GNE_SFA2_MyAccounts_Controller controller = new GNE_SFA2_MyAccounts_Controller();

	       	controller.selectedViewId = controller.accountViewsSelectOptions[1].getValue();
	       	controller.changeSelectedView();

	       	Test.setCurrentPage(controller.exportToExcelClick());
	       	controller.exportToExcel();
	        system.assertEquals('PublicTest', controller.selectedViewInExport.View_Name_gne__c);
	        system.assertEquals('Account.Name;Address.Name;Address.City_vod__c;Address.State_vod__c', controller.selectedViewInExport.View_Fields_gne__c);
	        Test.stopTest();
	    }
	}

	public static testMethod void testFiltering(){
		User sfa2User = selectSFA2UserWithTerritory();
		System.runAs(sfa2User){
			insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'SFA-US', Role_gne__c = 'CS', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());
			createConfiguration('SFA-US', 'CS', null);
			Integer listSize = 6;
			insertHCPAndTSF(listSize);
			List<String> valueType = new List<String>{'PICKLIST', 'PICKLIST', 'MULTIPICKLIST', 'MULTIPICKLIST', 'BOOLEAN', 'BOOLEAN'};
			List<String> value = new List<String>{null, null, null, null, 'true', 'false'};
			List<String> record = new List<String>{'Account', 'Account', 'Account', 'Account', 'Account', 'Account'};
			List<String> operator = new List<String>{'inc', 'ecl', 'inc', 'ecl', 'eq', 'ne'};
			List<List<String>> multiValue = new List<List<String>>{new List<String>{'Active'}, new List<String>{'Active', 'Wrong'}, new List<String>{'Art'}, new List<String>{'Art', 'Wrong'}, null, null};
			List<String> field = new List<String>{'Status_gne__c', 'Status_gne__c', 'Hobbies_gne__c', 'Hobbies_gne__c', 'KOL_vod__c', 'KOL_vod__c'};
			List<String> brand = new List<String>{null, null, null, null, null, null};
			List<SFA2_View_Config_gne__c> createdViews = createFilteredViews(valueType, value, record, operator, multiValue, field, brand);
			List<Account> allAccounts = [SELECT Id, Status_gne__c, Hobbies_gne__c, KOL_vod__c FROM Account];
			system.assertEquals(listSize, allAccounts.size());
			Account a1 = allAccounts[0];
			a1.Status_gne__c='Active';
			a1.Hobbies_gne__c='Wrong';
			Account a2 = allAccounts[1];
			a2.Status_gne__c='Inactive';
			a2.Hobbies_gne__c='Wrong';
			Account a3 = allAccounts[2];
			a3.Status_gne__c='Wrong';
			a3.Hobbies_gne__c='Art';
			Account a4 = allAccounts[3];
			a4.Status_gne__c='Wrong';
			a4.Hobbies_gne__c='Books';
			Account a5 = allAccounts[4];
			a5.Status_gne__c='Wrong';
			a5.Hobbies_gne__c='Wrong';
			a5.KOL_vod__c=true;
			Account a6 = allAccounts[5];
			a6.Status_gne__c='Wrong';
			a6.Hobbies_gne__c='Wrong';
			a6.KOL_vod__c=false;
			List<Account> toUpdate = new List<Account>{a1, a2, a3, a4, a5, a6};
			update toUpdate;
			GNE_SFA2_MyAccounts_Controller controller = new GNE_SFA2_MyAccounts_Controller();
			controller.selectedViewId=createdViews[0].Id;
			controller.changeSelectedView();
			system.assertEquals(1, controller.viewWrappers.size());
			system.assertEquals(a1.Id, controller.viewWrappers[0].accountId);

			controller.selectedViewId=createdViews[1].Id;
			controller.changeSelectedView();
			system.assertEquals(1, controller.viewWrappers.size());
			system.assertEquals(a2.Id, controller.viewWrappers[0].accountId);
			Test.startTest();
			controller.selectedViewId=createdViews[2].Id;
			controller.changeSelectedView();
			system.assertEquals(1, controller.viewWrappers.size());
			system.assertEquals(a3.Id, controller.viewWrappers[0].accountId);

			controller.selectedViewId=createdViews[3].Id;
			controller.changeSelectedView();
			system.assertEquals(1, controller.viewWrappers.size());
			system.assertEquals(a4.Id, controller.viewWrappers[0].accountId);

			controller.selectedViewId=createdViews[4].Id;
			controller.changeSelectedView();
			system.assertEquals(1, controller.viewWrappers.size());
			system.assertEquals(a5.Id, controller.viewWrappers[0].accountId);

			controller.selectedViewId=createdViews[5].Id;
			controller.changeSelectedView();
			system.assertEquals(1, controller.viewWrappers.size());
			system.assertEquals(a5.Id, controller.viewWrappers[0].accountId);
			Test.stopTest();
		}
	}

	public static testMethod void testGetMyTargetAndTiersTsfQueryCondition(){
		User usr = createUserWithSelectedProfile('RCanada-SFA-Manager', 'testUser');
		Product_vod__c prod = new Product_vod__c(Product_Type_vod__c = 'Detail', Region_Code_gne__c = 2,
			Detail_Product_Subtype_Code_gne__c = 'Diagnostic', OwnerId = usr.Id);
		insert prod;
		My_Setup_Products_vod__c mySetupProd = new My_Setup_Products_vod__c(Product_vod__c = prod.Id, OwnerId = usr.Id);
		insert mySetupProd;
		GNE_SFA2_Canadian_Users__c sfaManagerCanada = new GNE_SFA2_Canadian_Users__c(Name = 'RCanada-SFA-Manager');
		insert sfaManagerCanada;
		List<String> territoryNames = new List<String>{'territoryName'};
		System.runAs(usr){
			String toCompare = ' AND Territory_vod__c In (\'territoryName\') AND Id In (SELECT Territory_Field_parent_gne__c FROM Targets_and_Tiers_can_gne__c ' +
			'WHERE Territory_gne__c In (\'territoryName\') AND Product_Catalog_gne__c In (\'' + prod.Id + '\') ' +
			'AND (My_Target_gne__c <> null OR Target_gne__c <> null OR Segment_gne__c <> null OR Tier_can_gne__c <> null)) ';

			System.assertEquals(toCompare, GNE_SFA2_MyAccounts_Controller.getMyTargetAndTiersTsfQueryCondition(territoryNames));
		}
	}

	public static testMethod void testGetIsViewCreatable(){
		User usr = createUserWithSelectedProfile('RCanada-SFA-Manager', 'testUser');
		System.runAs(usr){
			GNE_SFA2_MyAccounts_Controller controller = new GNE_SFA2_MyAccounts_Controller();
			System.assertEquals(true, controller.getIsViewCreatable());
		}

		User usr2 = createUserWithSelectedProfile('GNE-Field', 'testUser2');
		System.runAs(usr2){
			GNE_SFA2_MyAccounts_Controller controller = new GNE_SFA2_MyAccounts_Controller();
			System.assertEquals(true, controller.getIsViewCreatable());
		}
	}

	private static List<SFA2_View_Config_gne__c> createFilteredViews(List<String> valueType, List<String> value, List<String> record, List<String> operator, List<List<String>> multiValue, List<String> field, List<String> brand){
		List<SFA2_View_Config_gne__c> views = new List<SFA2_View_Config_gne__c>();
		for(Integer i = 0; i < valueType.size(); i++){
			views.add(createFilteredView(valueType[i], value[i], record[i], operator[i], multiValue[i], field[i], brand[i], i));
		}
		insert views;
		return views;
	}

	private static SFA2_View_Config_gne__c createFilteredView(String valueType, String value, String record, String operator, List<String> multiValue, String field, String brand, Integer num){
		String multiValueString = '';
		if(multiValue != null && multiValue.size()>0){
			for(String mValue :multiValue){
				if(multiValueString!=''){
					multiValueString+=',';
				}
				if(mValue != null){
					multiValueString+='"' + mValue + '"';
				} else {
					multiValueString+=mValue;
				}
			}
		}
		valueType = valueType == null ? valueType : '"' + valueType + '"';
		value = value == null ? value : '"' + value + '"';
		record = record == null ? record : '"' + record + '"';
		operator = operator == null ? operator : '"' + operator + '"';
		field = field == null ? field : '"' + field + '"';
		brand = brand == null ? brand : '"' + brand + '"';

		String filter = '[{'
						+	'"valueType": ' + valueType + ','
						+	'"value": ' + value + ','
 						+	'"record": ' + record + ','
  						+	'"operator": ' + operator + ','
  						+	'"multiValue": [' + multiValueString + '],'
  						+	'"field": ' + field + ','
  						+	'"brand": ' + brand + ''
  						+ '}]';

  		SFA2_View_Config_gne__c viewToReturn = new SFA2_View_Config_gne__c(
													Visibility_gne__c 			= 'public',
													View_Name_gne__c 			= 'PublicTest'+num,
													Sorting_Field_gne__c 		= 'Account.Name',
													Filter_Statement_gne__c 	= filter,
													Person_Record_Types_gne__c 	= 'Professional_vod,',
													Account_Record_Types_gne__c = null,
													Page_Name_gne__c 			= 'My Accounts',
													View_Fields_gne__c			= 'Account.Name;',
													Object_Type_gne__c 			= 'Account'
												);
  		return viewToReturn;
	}

	private static void createConfiguration(String appType, String role, Id productId){

		SFA2_Configuration_Object_gne__c myAccountsLP = new SFA2_Configuration_Object_gne__c(
			Configuration_Type_gne__c 		= 'List Page',
			Object_Name_gne__c  			= 'Account',
			Name 							= 'My Accounts List Page',
			Section_Header_gne__c 			= 'My Accounts',
			Attributes_gne__c 				= 'activeMenuItem=My Accounts;',
			Application_Type__c 			= appType,
			Role_gne__c  					= role,
			Is_Active_gne__c  				= true
		);

		insert myAccountsLP;

		List<SFA2_Configuration_Object_Detail_gne__c> configurationObjectDetails = new List<SFA2_Configuration_Object_Detail_gne__c>();

		Integer ord = 0;
		configurationObjectDetails.add(
			new SFA2_Configuration_Object_Detail_gne__c(
				Configuration_Object_ref_gne__c = myAccountsLP.Id,
				Order_gne__c 				= ord++,
				Label_gne__c 				= 'Plan/ Record an Interaction',
				API_Name_gne__c 			= 'Plan/ Record an Interaction',
				Name 						= 'Plan/ Record an Interaction',
				Attributes_gne__c 			= 'action=scheduleInteractionClick;rerender=main-content,test;immediate=true;styleClass=image-button sfa-plh sfa-plh-action-bar;dir=img/icon-interact.png;',
				Type_gne__c 				= 'Button'
			)
		);
		configurationObjectDetails.add(
			new SFA2_Configuration_Object_Detail_gne__c(
				Configuration_Object_ref_gne__c = myAccountsLP.Id,
				Order_gne__c 				= ord++,
				Label_gne__c 				= 'Export To Excel',
				API_Name_gne__c 			= 'Export To Excel',
				Name 						= 'Export To Excel',
				Attributes_gne__c 			= 'action=exportToExcelClick;onclick=doNothing;immediate=somethingElse;styleClass=image-button sfa-plh sfa-plh-action-bar button export-to-excel;',
				Type_gne__c 				= 'Button'
			)
		);

		for(SFA2_Configuration_Object_Detail_gne__c det : configurationObjectDetails) {
			det.OTR2_gne__c 				= false;
			det.Is_Active_gne__c 			= true;
			det.Is_Required_gne__c 			= false;
			det.Is_Read_Only_gne__c 		= false;
			det.Availability_Mode_gne__c 	= null;
		}

		insert configurationObjectDetails;

		List<SFA2_View_Config_gne__c> views = new List<SFA2_View_Config_gne__c>();
		views.add(
			new SFA2_View_Config_gne__c(
				Visibility_gne__c 			= 'private',
				OwnerId 					= UserInfo.getUserId(),
				View_Name_gne__c 			= 'PrivateTest',
				Sorting_Field_gne__c 		= 'Account.Name',
				Filter_Statement_gne__c 	= '[]',
				Person_Record_Types_gne__c 	= null,
				Account_Record_Types_gne__c = 'Institution_vod, Board_vod, Agency_gne'
			)
		);
		views.add(
			new SFA2_View_Config_gne__c(
				Visibility_gne__c 			= 'public',
				View_Name_gne__c 			= 'PublicTest',
				Sorting_Field_gne__c 		= 'BrandAffiliation.'+productId+'.Tier_gne__c',
				Filter_Statement_gne__c 	= '[{"valueType":"BOOLEAN","value":"true","record":"Account","operator":"eq",'
				 								+ '"multiValue":[],"field":"IsPersonAccount","brand":""}]',
				Person_Record_Types_gne__c 	= 'Archived_Person_Account_gne, HCP_Canada, '
					+ 'Health_Care_Business_Professional_HBP_gne, Professional_vod, Health_Care_Professional_Non_Prescriber_gne, '
					+ 'Health_Care_Professional_Prescriber_gne, LWOHealthcareProfessional_gne,',
				Account_Record_Types_gne__c = null
			)
		);
		views.add(
			new SFA2_View_Config_gne__c(
				Visibility_gne__c 			='restricted',
				Application_Type_gne__c		= appType,
				Brand_gne__c 				= null,
				Role_gne__c 				= role,
				View_Name_gne__c 			= 'RestrictedTest',
				Sorting_Field_gne__c 		= 'Account.Name',
				Filter_Statement_gne__c 	= '[]',
				Person_Record_Types_gne__c  = null,
				Account_Record_Types_gne__c = null
			)
		);

		for(SFA2_View_Config_gne__c viewC :views){
			viewC.Page_Name_gne__c 		= 'My Accounts';
			if(productId!=null){
				viewC.View_Fields_gne__c= 'Account.Name;Address.Name;Address.City_vod__c;Address.State_vod__c;BrandAffiliation.'+productId+'.Tier_gne__c;';
			}
			viewC.Object_Type_gne__c 	= 'Account';
		}

		insert views;
	}

	private static void insertAccountsAndTSF(){
		Territory2 t = [SELECT Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId()) LIMIT 1];
		Id recordTypeId = [SELECT Id FROM RecordType WHERE Name ='Institution_vod' AND SobjectType = 'Account' LIMIT 1].Id;
		List<Account> accs = new List<Account>();
		for(Integer i=0; i<100; i++){
			Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName'+i);
			acc.RecordTypeId = recordTypeId;
			accs.add(acc);
		}
		insert accs;
		Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(accs[0].Id, 'address', true, 'addressName');
		insert addr;
		List<TSF_vod__c> tsfs = new List<TSF_vod__c>();
		for(Account acc :accs){
			TSF_vod__c tsf = GNE_SFA2_Triggers_Test_Util.prepareTSF_vod(acc.Id);
			tsf.Territory_vod__c = t.Name;
			tsf.Address_vod__c =addr.Id;
			tsfs.add(tsf);
		}
		insert tsfs;
	}

	private static void insertHCPAndTSF(Integer listSize){
		Territory2 t = [SELECT Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId()) LIMIT 1];
		Id recordTypeId = [SELECT Id FROM RecordType WHERE Name ='Professional_vod' AND SobjectType = 'Account' LIMIT 1].Id;
		List<Account> accs = new List<Account>();
		for(Integer i=0; i<listSize; i++){
			Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName'+i);
			acc.RecordTypeId = recordTypeId;
			accs.add(acc);
		}
		insert accs;
		Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(accs[0].Id, 'address', true, 'addressName');
		insert addr;
		List<TSF_vod__c> tsfs = new List<TSF_vod__c>();
		for(Account acc :accs){
			TSF_vod__c tsf = GNE_SFA2_Triggers_Test_Util.prepareTSF_vod(acc.Id);
			tsf.Territory_vod__c = t.Name;
			tsf.Address_vod__c =addr.Id;
			tsfs.add(tsf);
		}
		insert tsfs;
	}

	private static User selectSFA2UserWithTerritory(){
		List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-Field'];
		if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
			List<User> sfa2Users = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true AND Id IN (SELECT UserId FROM UserTerritory2Association)];
			if(sfa2Users != null && sfa2Users.size() > 0) {
				return sfa2Users[0];
			}
		}
		return null;
	}

	private static User createUserWithSelectedProfile(String profileName, String userName){
		Profile prof = [SELECT Id, Name FROM Profile WHERE Name = :profileName LIMIT 1];
		User usr = GNE_SFA2_Triggers_Test_Util.createUser(userName, prof);

		return usr;
	}

}