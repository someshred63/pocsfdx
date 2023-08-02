@isTest
private class EDM_Classif_Requests_Log_Ctrl_Test{

	static testMethod void crListControllerTest(){

		Profile p = [select id from profile where name='GNE-TLS-Manager'];
        User u = new User(alias = 'atlsMana', email='atlsMana@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='atlsMana@gene.com');
        insert u;
        
        System.runAs(u){
            insert new GNE_SFA2_User_App_Context_gne__c(Run_in_SFA2_UI_gne__c = true, SFA2_Mode_gne__c = true, App_Name_gne__c = 'TLCRM', Role_gne__c = 'ATLS', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

            EDM_Classif_Requests_Log_Controller ctrl = new EDM_Classif_Requests_Log_Controller();

            System.assert(!ctrl.hasAccountFilter);

			Account acc = new Account(Name='testAccount');
	        insert acc;

            ApexPages.currentPage().getParameters().put('accountId',acc.Id);

            SFA2_Configuration_Object_gne__c config = new SFA2_Configuration_Object_gne__c(
            	Configuration_Type_gne__c = 'List Page',
				Is_Active_gne__c = true,
				Application_Type__c = 'TLCRM',
				Role_gne__c = 'ATLS',
				Brand_gne__c = '',
				Object_Name_gne__c = 'EDM_Classification_Request_gne__c',
				Section_Header_gne__c = 'Classification Log'
			);
			insert config;

			ctrl = new EDM_Classif_Requests_Log_Controller();

			System.assert(ctrl.hasAccountFilter);	
        }        
	}

	static testMethod void crInitAccessDeniedTest(){
		Profile p = [select id from profile where name='GNE-TLS-Manager'];
        User u = new User(alias = 'atlsMana', email='atlsMana@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='atlsMana@gene.com');
        insert u;

        System.runAs(u){
            
            EDM_Classif_Requests_Log_Controller ctrl = new EDM_Classif_Requests_Log_Controller();

			PageReference pr = ctrl.init();
			System.assertEquals(GNE_SFA2_Util.redirectToAccessDeniedPage().getURL(),pr.getURL());
        }
	}

	static testMethod void crInitPassTest(){
		Profile p = [select id from profile where name='GNE-TLS-Manager'];
        User u = new User(alias = 'atlsMana', email='atlsMana@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='atlsMana@gene.com');
        insert u;

        assignPermissionSet(u.Id, 'EDM_Classification_Review');

        System.runAs(u){
            
            EDM_Classif_Requests_Log_Controller ctrl = new EDM_Classif_Requests_Log_Controller();

			PageReference pr = ctrl.init();
			System.assertEquals(null,pr);
        }
	}

	static testMethod void crExportToExcelWithoutUserPreferencesTest(){

		Profile p = [select id from profile where name='GNE-TLS-Manager'];
        User u = new User(alias = 'atlsMana', email='atlsMana@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='atlsMana@gene.com');
        insert u;
        
        System.runAs(u){
            EDM_Classif_Requests_Log_Controller ctrl = new EDM_Classif_Requests_Log_Controller();

            SFA2_View_Config_gne__c v = new SFA2_View_Config_gne__c(
            	Visibility_gne__c = 'public',
            	Page_Name_gne__c = 'Classification Log',
            	Object_Type_gne__c = 'EDM_Classification_Request_gne__c', 
            	View_Name_gne__c = 'Test View'
            );
            insert v;

            PageReference pageRef = new PageReference('/apex/EDM_Classif_Requests_Log_Export');
            pageRef.setredirect(false);
            pageRef.getParameters().put('viewId', v.Id);

			PageReference pr = ctrl.exportToExcel();
			System.assertEquals(pageRef.getUrl(),pr.getUrl());
        }        
	}

	static testMethod void crExportToExcelWithUserPreferencesTest(){

		Profile p = [select id from profile where name='GNE-TLS-Manager'];
        User u = new User(alias = 'atlsMana', email='atlsMana@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='atlsMana@gene.com');
        insert u;
        
        System.runAs(u){
            EDM_Classif_Requests_Log_Controller ctrl = new EDM_Classif_Requests_Log_Controller();

            SFA2_View_Config_gne__c v = new SFA2_View_Config_gne__c(
            	Visibility_gne__c = 'public',
            	Page_Name_gne__c = 'Classification Log',
            	Object_Type_gne__c = 'EDM_Classification_Request_gne__c', 
            	View_Name_gne__c = 'Test View'
            );
            insert v;

            SFA2_User_Preferences_gne__c pref = new SFA2_User_Preferences_gne__c(
            	Last_View_Used_gne__c = v.Id,
            	User_gne__c = u.Id
            );
            insert pref;            

            PageReference pageRef = new PageReference('/apex/EDM_Classif_Requests_Log_Export');
            pageRef.setredirect(false);
            pageRef.getParameters().put('viewId', pref.Last_View_Used_gne__c);

			PageReference pr = ctrl.exportToExcel();
			System.assertEquals(pageRef.getUrl(),pr.getUrl());
        }        
	}

	static testMethod void crGetRecordsTest(){

		Profile p = [select id from profile where name='GNE-TLS-Manager'];
        User u = new User(alias = 'atlsMana', email='atlsMana@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='atlsMana@gene.com');
        insert u;
        
        System.runAs(u){
            
            SFA2_View_Config_gne__c v = new SFA2_View_Config_gne__c(
            	Visibility_gne__c = 'public',
            	Page_Name_gne__c = 'Classification Log',
            	Object_Type_gne__c = 'EDM_Classification_Request_gne__c', 
            	View_Name_gne__c = 'Test View',
            	View_Fields_gne__c = 'name;edm_account_gne__c;edm_business_classification_gne__c;edm_business_classification_date_gne__c',
            	Sorting_Field_gne__c = 'name',
            	Sorting_Order_gne__c = 'desc'
            );
            insert v;

            ApexPages.currentPage().getParameters().put('viewId',v.Id);

            EDM_Classif_Requests_Log_Controller ctrl;

        //hasAccountFilter = true
            Account acc = new Account(Name='testAccount');
	        insert acc;

            ApexPages.currentPage().getParameters().put('accountId',acc.Id);

            EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(
            	EDM_Account_gne__c = acc.Id,
            	EDM_Type_of_Classification_gne__c = 'Business',
            	EDM_Status_gne__c = 'Completed'            	
            );
	        insert req;
	        ctrl = new EDM_Classif_Requests_Log_Controller();
            List<EDM_Classification_Request_gne__c> records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //whereStatementList.size() > 0 && viewConf[0].Records_Visibility__c == 'My Records'
        	ApexPages.currentPage().getParameters().put('accountId',null);
        	acc.EDM_business_classification_gne__c = 'National';
        	update acc;
			v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"National","operator":"eq","multiValue":["Pending"],"field":"edm_business_classification_gne__c"}]';
			update v;
			ctrl = new EDM_Classif_Requests_Log_Controller();
            records = ctrl.getLogViewRecords();
			
			System.assertEquals(1,records.size());
		//whereStatementList.size() == 0 && viewConf[0].Records_Visibility__c == 'My Records'
        	ApexPages.currentPage().getParameters().put('accountId',null);
			v.Filter_Statement_gne__c = '';
			update v;
			ctrl = new EDM_Classif_Requests_Log_Controller();
            records = ctrl.getLogViewRecords();
			
			System.assertEquals(1,records.size());
		//whereStatementList.size() > 0 && viewConf[0].Records_Visibility__c == 'All Records'
        	ApexPages.currentPage().getParameters().put('accountId',null);
			v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"National","operator":"eq","multiValue":["Pending"],"field":"edm_business_classification_gne__c"}]';
			v.Records_Visibility__c = 'All Records';
			update v;
			ctrl = new EDM_Classif_Requests_Log_Controller();
            records = ctrl.getLogViewRecords();
			
			System.assertEquals(1,records.size());
        }        
	}
 
 	static testMethod void crFiltersTest(){

		Profile p = [select id from profile where name='GNE-TLS-Manager'];
        User u = new User(alias = 'atlsMana', email='atlsMana@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='GMT', username='atlsMana@gene.com');
        insert u;
        
        System.runAs(u){
            
            Account acc = new Account(Name='testAccount');
	    	insert acc;

            SFA2_View_Config_gne__c v = new SFA2_View_Config_gne__c(
            	Visibility_gne__c = 'public',
            	Page_Name_gne__c = 'Classification Log',
            	Object_Type_gne__c = 'EDM_Classification_Request_gne__c', 
            	View_Name_gne__c = 'Test View',
            	View_Fields_gne__c = 'name;edm_account_gne__c;edm_business_classification_gne__c;edm_business_classification_date_gne__c',
            	Sorting_Field_gne__c = 'name',
            	Sorting_Order_gne__c = 'desc'
            );
            insert v;

            ApexPages.currentPage().getParameters().put('viewId',v.Id);

            EDM_Classif_Requests_Log_Controller ctrl = new EDM_Classif_Requests_Log_Controller();
            
            EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(
            	EDM_Account_gne__c = acc.Id,
            	EDM_Type_of_Classification_gne__c = 'Business',
            	EDM_Status_gne__c = 'Completed',
            	EDM_Pending_days_gne__c = 4.0,
            	EDM_Date_Submitted_gne__c = Date.newInstance(2005, 3, 1)
            );
	        insert req;
	        req = new EDM_Classification_Request_gne__c(
            	EDM_Account_gne__c = acc.Id,
            	EDM_Type_of_Classification_gne__c = 'Clinical',
            	EDM_Status_gne__c = 'Pending',
            	EDM_Pending_days_gne__c = 1.0,
            	EDM_Date_Submitted_gne__c = Date.today()
            );
	        insert req;

	        List<EDM_Classification_Request_gne__c> records = new List<EDM_Classification_Request_gne__c>();
        //PICKLIST IN
        	v.Filter_Statement_gne__c = '[{"valueType":"PICKLIST","value":"","operator":"inc","multiValue":["Completed","Pending"],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(2,records.size());
        //PICKLIST NOT IN
        	v.Filter_Statement_gne__c = '[{"valueType":"PICKLIST","value":"","operator":"ecl","multiValue":["Pending"],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //STRING EQUALS
        	v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"Pending","operator":"eq","multiValue":[],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //STRING NOT EQUALS
        	v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"Pending","operator":"ne","multiValue":[],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //STRING LIKE
        	v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"e","operator":"c","multiValue":[],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(2,records.size());
        //STRING NOT LIKE
        	v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"en","operator":"nc","multiValue":[],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //STRING LIKE SW
        	v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"Pending","operator":"sw","multiValue":[],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //STRING LOWER
        	v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"O","operator":"lt","multiValue":[],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //STRING LOWER OR EQUALS
        	v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"R","operator":"lte","multiValue":[],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(2,records.size());
        //STRING GREATER
        	v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"D","operator":"gt","multiValue":[],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //STRING GREATER OR EQUALS
        	v.Filter_Statement_gne__c = '[{"valueType":"STRING","value":"C","operator":"gte","multiValue":[],"field":"EDM_Status_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(2,records.size());
        //DOUBLE EQUALS
        	v.Filter_Statement_gne__c = '[{"valueType":"DOUBLE","value":"4.0","operator":"eq","multiValue":[],"field":"EDM_Pending_days_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //INTEGER NOT EQUALS
        	v.Filter_Statement_gne__c = '[{"valueType":"INTEGER","value":"4","operator":"ne","multiValue":[],"field":"EDM_Pending_days_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //DATE LOWER
        	v.Filter_Statement_gne__c = '[{"valueType":"DATE","value":"TODAY","operator":"lt","multiValue":[],"field":"EDM_Date_Submitted_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //DATE GREATER OR EQUALS
        	v.Filter_Statement_gne__c = '[{"valueType":"DATE","value":"TODAY","operator":"gte","multiValue":[],"field":"EDM_Date_Submitted_gne__c"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        //DATETIME GREATER
        	v.Filter_Statement_gne__c = '[{"valueType":"DATETIME","value":"TODAY","operator":"gt","multiValue":[],"field":"CreatedDate"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(0,records.size());
        //DATETIME LOWER OR EQUALS
        	v.Filter_Statement_gne__c = '[{"valueType":"DATETIME","value":"LAST_N_DAYS:1","operator":"lte","multiValue":[],"field":"CreatedDate"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(2,records.size());
        //ID EQUALS
        	v.Filter_Statement_gne__c = '[{"valueType":"ID","value":"'+req.Id+'","operator":"eq","multiValue":[],"field":"Id"}]';
			update v;
            records = ctrl.getLogViewRecords();
            System.assertEquals(1,records.size());
        }        
	}

	static testMethod void crExportToExcelRestrictedViewAppWideTest(){

		Profile p = [select id from profile where name='GNE-TLS-Manager'];
        User u = new User(alias = 'atlsMana', email='atlsMana@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='atlsMana@gene.com');
        insert u;
         
        // app wide view
        System.runAs(u){
            insert new GNE_SFA2_User_App_Context_gne__c(
	        	Run_in_SFA2_UI_gne__c = true, 
	        	SFA2_Mode_gne__c = true, 
	        	App_Name_gne__c = 'TLCRM', 
	        	Role_gne__c = 'ATLS', 
	        	Brand_gne__c = null,
	        	SetupOwnerId = UserInfo.getUserId()
	        );

            SFA2_View_Config_gne__c v = new SFA2_View_Config_gne__c(
            	Application_Type_gne__c = 'TLCRM',
            	Visibility_gne__c = 'restricted',
            	Page_Name_gne__c = 'Classification Log',
            	Object_Type_gne__c = 'EDM_Classification_Request_gne__c', 
            	View_Name_gne__c = 'Test View',
            	View_Fields_gne__c = 'name;edm_account_gne__c;edm_business_classification_gne__c;edm_business_classification_date_gne__c',
            	Sorting_Field_gne__c = 'name',
            	Sorting_Order_gne__c = 'desc'
            );
            insert v;

            ApexPages.currentPage().getParameters().put('viewId',v.Id);

            EDM_Classif_Requests_Log_Controller ctrl = new EDM_Classif_Requests_Log_Controller();
            
            PageReference pr = ctrl.exportToExcel();
            System.assertEquals(v.Id,pr.getParameters().get('viewId'));
        }
    }
    static testMethod void crExportToExcelRestrictedViewBrandWideTest(){

		Profile p = [select id from profile where name='GNE-TLS-Manager'];
        User u = new User(alias = 'atlsMana', email='atlsMana@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='atlsMana@gene.com');
        insert u;
         
        // app wide view
        System.runAs(u){
            insert new GNE_SFA2_User_App_Context_gne__c(
	        	Run_in_SFA2_UI_gne__c = true, 
	        	SFA2_Mode_gne__c = true, 
	        	App_Name_gne__c = 'TLCRM', 
	        	Role_gne__c = null, 
	        	Brand_gne__c = 'TestBrand',
	        	SetupOwnerId = UserInfo.getUserId()
	        );

            SFA2_View_Config_gne__c v = new SFA2_View_Config_gne__c(
            	Application_Type_gne__c = 'TLCRM',
            	Brand_gne__c = 'TestBrand',
            	Visibility_gne__c = 'restricted',
            	Page_Name_gne__c = 'Classification Log',
            	Object_Type_gne__c = 'EDM_Classification_Request_gne__c', 
            	View_Name_gne__c = 'Test View',
            	View_Fields_gne__c = 'name;edm_account_gne__c;edm_business_classification_gne__c;edm_business_classification_date_gne__c',
            	Sorting_Field_gne__c = 'name',
            	Sorting_Order_gne__c = 'desc'
            );
            insert v;

            ApexPages.currentPage().getParameters().put('viewId',v.Id);

            EDM_Classif_Requests_Log_Controller ctrl = new EDM_Classif_Requests_Log_Controller();
            
            PageReference pr = ctrl.exportToExcel();
            System.assertEquals(v.Id,pr.getParameters().get('viewId'));
        }
    }
    
	private static void assignPermissionSet(Id userId, String permissionSetName) {
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = :permissionSetName];
            list <PermissionSetAssignment> PSAssignments = new list <PermissionSetAssignment>();
            List<User> users = [SELECT Id, (Select Id FROM PermissionSetAssignments WHERE PermissionSetId = :ps.Id) FROM User WHERE Id = :userId];
            
            for (User u : users) {
                if (u.PermissionSetAssignments.size() == 0) 
                    PSAssignments.add( new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id ) );
            }

            if (!PSAssignments.isEmpty()) {
                insert PSAssignments;
            }
        }
    }
}