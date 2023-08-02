@isTest
private class EDM_SBM_List_View_Controller_Test{

	public static testMethod void test_constuctorWithoutSettings() {
		//GNE_SFA2_My_Accounts_Setttings__c myAccSet = new GNE_SFA2_My_Accounts_Setttings__c(PageSize_gne__c = 3, Privileged_Profiles_gne__c = 'GNE-SFA-Actemra-CS');
		EDM_SBM_List_View_Controller lvC = new EDM_SBM_List_View_Controller();
		lvC.showViewSelection = false;
        lvC.nameOfThePage = 'GNE_SFA2_Questionnaires';
        lvC.sortingEnabled = false;
        lvC.checkboxesEnabled = false;
        lvC.editEnabled = false;
        lvC.deleteEnabled = false;
        lvC.editURL = null;
        lvC.baseListController = new GNE_SFA2_Questionnaires_Controller();
        lvc.objectType='Speaker_Bureau_Membership_gne__c';
		system.assertEquals(false, lvC.maxRecordsReached);
		system.assertEquals(null, lvC.sortDirection);
        system.assertEquals(1, lvC.pageNumber);
        system.assertEquals(1, lvC.pageNumbers);
        system.assertEquals(0, lvC.recordsCount);
        system.assertNotEquals(null, lvC.columnHeaders);
        system.assertEquals(0, lvC.columnHeaders.keySet().size());
        system.assertEquals(0, lvC.columnHeaders.values().size());
        system.assertNotEquals(null, lvC.columnSortable);
        system.assertEquals(0, lvC.columnSortable.keySet().size());
        system.assertEquals(0, lvC.columnSortable.values().size());
        system.assertEquals(false, lvC.isActivity);
        system.assertEquals('Speaker_Bureau_Membership_gne__c', lvC.objectType);
        system.assertNotEquals(null, lvC.visibleViews);
        system.assertEquals(0, lvC.visibleViews.size());
        system.assertNotEquals(null, lvC.views);
        system.assertEquals(1, lvC.views.size());
        system.assertEquals('No Views Defined', lvC.views[0].getLabel());
        system.assertEquals('', lvC.views[0].getValue());
        system.assertEquals(null, lvC.selectedViewId);
	}

    public static testMethod void testFiltering(){
        SFA2_View_Config_gne__c view = prepareView(null, null, null, 'Name',
                                                '[{"valueType":"BOOLEAN","value":"true","operator":"eq","multiValue":[],"field":"Contract_Active_gne__c"},' +
                                                '{"valueType":"BOOLEAN","value":"false","operator":"ne","multiValue":[],"field":"Is_Contracted_Speaker_gne__c"},' + 
                                                '{"valueType":"PICKLIST","value":"","operator":"inc","multiValue":["Yes","No"],"field":"Meets_Speaker_Criteria_gne__c"},' + 
                                                '{"valueType":"PICKLIST","value":"","operator":"ecl","multiValue":["Rejected"],"field":"Speaker_Status_gne__c"},' +
                                                '{"valueType":"MULTIPICKLIST","value":"","operator":"inc","multiValue":["Actemra"],"field":"Speaker_Bureau_ID_gne__r.Brands_gne__c"},' + 
                                                '{"valueType":"MULTIPICKLIST","value":"","operator":"ecl","multiValue":["Anaprox"],"field":"Speaker_Bureau_ID_gne__r.Brands_gne__c"},' +
                                                '{"valueType":"REFERENCE","value":"CURRENT_USER","operator":"eq","multiValue":[],"field":"OwnerId"},' + 
                                                '{"valueType":"EMAIL","value":"aaa@bb.com","operator":"ne","multiValue":[],"field":"Nominated_By_gne__r.Email"},' + 
                                                '{"valueType":"URL","value":"www.google.com","operator":"lt","multiValue":[],"field":"Bureau_Member_gne__r.Website"},' + 
                                                '{"valueType":"STRING","value":"test1","operator":"lte","multiValue":[],"field":"EDM_Bureau_Type_gne__c"},' + 
                                                '{"valueType":"STRING","value":"test0","operator":"gt","multiValue":[],"field":"EDM_Bureau_Type_gne__c"},' +
                                                '{"valueType":"STRING","value":"test1","operator":"gte","multiValue":[],"field":"EDM_Bureau_Type_gne__c"},' +
                                                '{"valueType":"STRING","value":"est","operator":"c","multiValue":[],"field":"EDM_Bureau_Type_gne__c"},' +
                                                '{"valueType":"STRING","value":"aab","operator":"nc","multiValue":[],"field":"EDM_Bureau_Type_gne__c"},' +
                                                '{"valueType":"STRING","value":"tes","operator":"sw","multiValue":[],"field":"EDM_Bureau_Type_gne__c"},' +
                                                '{"valueType":"DOUBLE","value":"12","operator":"eq","multiValue":[],"field":"Completed_Programs_gne__c"},' +
                                                '{"valueType":"INTEGER","value":"15","operator":"ne","multiValue":[],"field":"Completed_Programs_gne__c"},' +
                                                '{"valueType":"DATE","value":"TODAY","operator":"lt","multiValue":[],"field":"CreatedDate"},' +
                                                '{"valueType":"DATETIME","value":"TODAY","operator":"lte","multiValue":[],"field":"LastModifiedDate"},' +
                                                '{"valueType":"DATETIME","value":"LAST_N_DAYS:30","operator":"gt","multiValue":[],"field":"LastModifiedDate"},' +
                                                '{"valueType":"ID","value":"' + UserInfo.getUserId() + '","operator":"gte","multiValue":[],"field":"OwnerId"},' +
                                                '{"valueType":"ELSE","value":"test","operator":"eq","multiValue":[],"field":"Name"},' +
                                                '{"valueType":"DATETIME","value":"wrongValueToTestCatch","operator":"eq","multiValue":[],"field":"CreatedDate"},' +
                                                '{"valueType":"CUSTOM_FILTER","value":"Excluded","operator":"eq","multiValue":[],"field":"Exclusion_Status_gne__c"}' +
                                                ']',
                                                 true, 'testName', 'public', 'Name');
        insert view;
        EDM_SBM_List_View_Controller lvC = new EDM_SBM_List_View_Controller();
        lvC.showViewSelection = false;
        lvC.nameOfThePage = 'GNE_SFA2_MyAccounts';
        lvC.selectedViewId = view.Id;
        lvC.editEnabled = false;
        lvC.deleteEnabled = false;
        lvC.baseListController = new GNE_SFA2_Questionnaires_Controller();
        lvC.showViewSelection = true;
        lvc.objectType='Speaker_Bureau_Membership_gne__c';
        lvC.changeSelectedView();
        system.assertEquals(23, lvC.filterStatements.size());
        system.assertEquals('Contract_Active_gne__c = true', lvC.filterStatements[0]);
        system.assertEquals('Is_Contracted_Speaker_gne__c != false', lvC.filterStatements[1]);
        system.assertEquals('Meets_Speaker_Criteria_gne__c IN (\'Yes\', \'No\')', lvC.filterStatements[2]);
        system.assertEquals('Speaker_Status_gne__c NOT IN (\'Rejected\')', lvC.filterStatements[3]);
        system.assertEquals('Speaker_Bureau_ID_gne__r.Brands_gne__c INCLUDES (\'Actemra\')', lvC.filterStatements[4]);
        system.assertEquals('Speaker_Bureau_ID_gne__r.Brands_gne__c EXCLUDES (\'Anaprox\')', lvC.filterStatements[5]);
        system.assertEquals('OwnerId = \''+ UserInfo.getUserId() + '\'', lvC.filterStatements[6]);
        system.assertEquals('Nominated_By_gne__r.Email != \'aaa@bb.com\'', lvC.filterStatements[7]);
        system.assertEquals('Bureau_Member_gne__r.Website < \'www.google.com\'', lvC.filterStatements[8]);
        system.assertEquals('EDM_Bureau_Type_gne__c <= \'test1\'', lvC.filterStatements[9]);
        system.assertEquals('EDM_Bureau_Type_gne__c > \'test0\'', lvC.filterStatements[10]);
        system.assertEquals('EDM_Bureau_Type_gne__c >= \'test1\'', lvC.filterStatements[11]);
        system.assertEquals('EDM_Bureau_Type_gne__c LIKE \'%est%\'', lvC.filterStatements[12]);
        system.assertEquals('(NOT EDM_Bureau_Type_gne__c LIKE \'%aab%\')', lvC.filterStatements[13]);
        system.assertEquals('EDM_Bureau_Type_gne__c LIKE \'tes%\'', lvC.filterStatements[14]);
        system.assertEquals('Completed_Programs_gne__c = 12', lvC.filterStatements[15]);
        system.assertEquals('Completed_Programs_gne__c != 15', lvC.filterStatements[16]);
        String currentDate = String.valueOf(System.today());
        List<String> dateParts = currentDate.split('-');
        DateTime tempDate = DateTime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
        currentDate = tempDate.format('yyyy-MM-dd');
        system.assertEquals('CreatedDate < ' + currentDate, lvC.filterStatements[17]);
        system.assertEquals('DAY_ONLY(CONVERTTIMEZONE(LastModifiedDate)) <= ' + currentDate, lvC.filterStatements[18]);
        system.assertEquals('DAY_ONLY(CONVERTTIMEZONE(LastModifiedDate)) > LAST_N_DAYS:30', lvC.filterStatements[19]);
        system.assertEquals('OwnerId >= \'' + UserInfo.getUserId() + '\'', lvC.filterStatements[20]);
        system.assertEquals('Name = \'test\'', lvC.filterStatements[21]);
        system.assertEquals('DAY_ONLY(CONVERTTIMEZONE(CreatedDate)) = \'\'', lvC.filterStatements[22]);
        /*CUSTOM FILTER won't return filter statement, since GNE_SFA2_List_View_Base_Controller returns empty string and GNE_SFA2_DCR_Controller doesn't override this behavior*/

    }

    public static testMethod void testColumnHeadersAndSortable(){

        PageReference pr = Page.GNE_SFA2_MyAccounts;
        Test.setCurrentPage(pr);

        SFA2_View_Config_gne__c view = prepareView(null, null, null, 'Name', null, true, 'testName', 'public', 
            'Id;Name;Bureau_Member_gne__c;Contract_Active_gne__c;Contract_End_Date_gne__c;Contract_Start_Date_gne__c;'+
            'Speaker_Bureau_ID_gne__c;Speaker_Category_gne__c;Speaker_Scope_gne__c;Speaker_Status_gne__c;Survey_gne__c;'+
            'owner.firstname;owner.lastname;owner.alias;createdby.alias;lastmodifiedby.alias;account.name;accountid;account.parentid;'+
            'reportstoid;reportsto.lastname;reportsto.firstname;EDM_Parent_AABP_gne__r.EDM_Group_gne__c;EDM_Parent_AABP_gne__r.EDM_Unit_gne__c;'+
            'EDM_Parent_AABP_gne__r.EDM_Team_gne__c;EDM_Parent_AABP_gne__r.EDM_Plan_Year_gne__c;createdbyid;lastmodifiedbyId;recordtypeid'
            );
        insert view;
        EDM_SBM_List_View_Controller lvC = new EDM_SBM_List_View_Controller();
        lvC.showViewSelection = true;
        lvC.nameOfThePage = 'GNE_SFA2_MyAccounts';
        lvC.selectedViewId = view.Id;
        lvC.editEnabled = false;
        lvC.deleteEnabled = false;
        lvC.baseListController = new GNE_SFA2_Questionnaires_Controller();
        lvc.objectType='Speaker_Bureau_Membership_gne__c';
        lvC.changeSelectedView();
        system.assertEquals(29, lvC.columnHeaders.keySet().size());
        system.assertEquals(29, lvC.columnSortable.keySet().size());
    }

    public static testMethod void testVisibility(){
        insert new GNE_SFA2_User_App_Context_gne__c(App_Name_gne__c = 'SFA-US', Brand_gne__c = 'Actemra', Role_gne__c ='CS', SetupOwnerId = UserInfo.getUserId());
        List<SFA2_View_Config_gne__c> views = new List<SFA2_View_Config_gne__c>();
        views.add(prepareView(null, null, null, 'Account.Name', null, true, 'testName1', 'public', null));
        views.add(prepareView('SFA-US', null, null, 'Account.Name', null, true, 'testName2', 'restricted', null));
        views.add(prepareView('SFA-US', 'Actemra', null, 'Account.Name', null, true, 'testName3', 'restricted', null));
        views.add(prepareView('SFA-US', 'Actemra', 'CS', 'Account.Name', null, true, 'testName4', 'restricted', null));
        views.add(prepareView('SFA-US', null, 'CS', 'Account.Name', null, true, 'testName5', 'restricted', null));
        views.add(prepareView('SFA-US', null, 'DM', 'Account.Name', null, true, 'testName6', 'restricted', null));
        insert views;
        EDM_SBM_List_View_Controller lvC = new EDM_SBM_List_View_Controller();
        lvC.showViewSelection = false;
        lvC.nameOfThePage = 'GNE_SFA2_MyAccounts';
        lvC.selectedViewId = views[0].Id;
        lvC.editEnabled = false;
        lvC.deleteEnabled = false;
        lvC.baseListController = new GNE_SFA2_Questionnaires_Controller();
        lvc.objectType='Speaker_Bureau_Membership_gne__c';
        lvC.changeSorting();
        EDM_SBM_List_View_Controller.PAGE_SIZE = 50;
        lvC.pageNumber = 1;
        lvC.changeSelectedView();
        system.assertEquals(5, lvC.visibleViews.size());

    }

    public static testMethod void overrideUserviewLinkTest(){
    	EDM_SBM_List_View_Controller lvC = new EDM_SBM_List_View_Controller();
    	System.assertEquals('/apex/GNE_SFA2_User_Layout?Id=' + lvC.userIdToViewLink,lvC.overrideUserViewLink().getUrl());
    }

    public static testMethod void deleteRecordTest(){

        PageReference pr = Page.GNE_SFA2_MyAccounts;
        Test.setCurrentPage(pr);

    	Account a = new Account(Name = 'TestAccount1');
		insert a;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = businessBureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;

		insert new GNE_SFA2_User_App_Context_gne__c(App_Name_gne__c = 'SFA-US', Brand_gne__c = 'Actemra', Role_gne__c ='CS', SetupOwnerId = UserInfo.getUserId());
        List<SFA2_View_Config_gne__c> views = new List<SFA2_View_Config_gne__c>();
        views.add(prepareView(null, null, null, 'Account.Name', null, true, 'testName1', 'public', null));
        insert views;
        EDM_SBM_List_View_Controller lvC = new EDM_SBM_List_View_Controller();
        lvC.showViewSelection = false;
        lvC.nameOfThePage = 'GNE_SFA2_MyAccounts';
        lvC.selectedViewId = views[0].Id;
        lvC.editEnabled = false;
        lvC.deleteEnabled = false;
        lvC.baseListController = new GNE_SFA2_Questionnaires_Controller();
        lvc.objectType='Speaker_Bureau_Membership_gne__c';
        lvC.changeSorting();
        EDM_SBM_List_View_Controller.PAGE_SIZE = 50;
        lvC.pageNumber = 1;
        lvC.changeSelectedView();

		System.assertEquals(1,lvC.recordsCount);

		lvC.deleteRecordId = sbm1.Id;
		lvC.deleteRecord();
		lvC.changeSelectedView();

		System.assertEquals(0,lvC.recordsCount);
    }

    private static SFA2_View_Config_gne__c prepareView(String appType, String brand, String role, String sortingField, String filter, Boolean allRecords, String viewName, String visibility, String viewFields){
        return new SFA2_View_Config_gne__c(
            Application_Type_gne__c = appType,
            Brand_gne__c = brand,
            Filter_Statement_gne__c = filter, 
            Object_Type_gne__c = 'Speaker_Bureau_Membership_gne__c', 
            Page_Name_gne__c = 'GNE_SFA2_MyAccounts',
            Records_Visibility__c = allRecords ? 'All Records' : 'My Records',
            Role_gne__c = role,
            Sorting_Field_gne__c = sortingField,
            Sorting_Order_gne__c = 'DESC',
            View_Fields_gne__c = viewFields,
            View_Name_gne__c = viewName,
            Visibility_gne__c = visibility
        );
    }
}