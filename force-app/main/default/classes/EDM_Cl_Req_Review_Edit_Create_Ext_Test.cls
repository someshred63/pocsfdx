@isTest(seeAllData=false)
private class EDM_Cl_Req_Review_Edit_Create_Ext_Test{

	static testMethod void crrExistingClassificationTest(){
		
        createConfiguration();

		Profile p = [select id from profile where name='GNE-MedAffairs-SP'];
        User u = new User(alias = 'spManagr', email='spManager@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='spManager@gene.com');
        insert u;

        assignPermissionSet(u.Id, 'EDM_Classification_Review');
        
        System.runAs(u){
            insert new GNE_SFA2_User_App_Context_gne__c(Run_in_SFA2_UI_gne__c = true, SFA2_Mode_gne__c = true, App_Name_gne__c = 'MedAffairs', Role_gne__c = 'SP', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];

            Account acc = new Account(Name='testAccount');
	        insert acc;
			EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Business',RecordTypeId = rt.Id);
	        insert req;

			ApexPages.StandardController sc = new ApexPages.StandardController(req);

			ApexPages.currentPage().getParameters().put('Id',req.Id);
	        ApexPages.currentPage().getParameters().put('accountId',acc.Id);

            EDM_Cl_Req_Review_Edit_Create_Ext ext = new EDM_Cl_Req_Review_Edit_Create_Ext(sc);
			PageReference pr = ext.initWithAccount();

            System.assertEquals(acc.Id,ext.acc.Id);
            System.assert(ext.existingRequest);

            List<SelectOption> lo = ext.getPossibleActions();
            System.assertEquals(5,lo.size());

            System.assertEquals(EDM_Classification_Utils.createPageRef(ext.getReturnURL()).getURL(),ext.cancel().getURL());

            ext.classificationRequest.EDM_Action_Taken_gne__c = 'Decline to Classify';

            pr = ext.save();
            System.assertEquals(null,pr);

            List<Apexpages.Message> msgs = ApexPages.getMessages();
            System.assertEquals(1,msgs.size(),msgs);
            System.assert(msgs[0].getDetail().contains('Please add classification comment'));


		}
	}

    static testMethod void crrNewClassificationTest(){
        
        createConfiguration();

        Profile p = [select id from profile where name='GNE-MedAffairs-SP'];
        User u = new User(alias = 'spManagr', email='spManager@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='spManager@gene.com');
        insert u;

        assignPermissionSet(u.Id, 'EDM_Classification_Review');
        
        System.runAs(u){
            insert new GNE_SFA2_User_App_Context_gne__c(Run_in_SFA2_UI_gne__c = true, SFA2_Mode_gne__c = true, App_Name_gne__c = 'MedAffairs', Role_gne__c = 'SP', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];

            Account acc = new Account(Name='testAccount');
            insert acc;
            EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();

            ApexPages.StandardController sc = new ApexPages.StandardController(req);

            ApexPages.currentPage().getParameters().put('accountId',acc.Id);

            EDM_Cl_Req_Review_Edit_Create_Ext ext = new EDM_Cl_Req_Review_Edit_Create_Ext(sc);
            PageReference pr = ext.initWithAccount();

            System.assertEquals(acc.Id,ext.acc.Id);
            System.assert(!ext.existingRequest);
            System.assertEquals(0,[Select id from EDM_Classification_Request_gne__c].size());

            List<SelectOption> lo = ext.getPossibleActions();
            System.assertEquals(4,lo.size());

            ext.classificationRequest.EDM_Business_Role_gne__c = '';
            ext.classificationRequest.EDM_Type_of_Classification_gne__c = 'Business';
            System.assertEquals('',ext.classificationRequest.EDM_Business_Role_gne__c);
            System.assertEquals('Business',ext.classificationRequest.EDM_Type_of_Classification_gne__c);
            
            pr = ext.save();
            System.assertEquals(null,pr);

            List<Apexpages.Message> msgs = ApexPages.getMessages();
            System.assertEquals(2,msgs.size(),msgs);
            System.assert(msgs[0].getDetail().contains('Please select Business Role'));
            System.assert(msgs[1].getDetail().contains('Please choose a CV to upload'));

        }
    }

    static testMethod void crrExistingClassificationSaveTest(){
        
        createConfiguration();

        Profile p = [select id from profile where name='GNE-MedAffairs-SP'];
        User u = new User(alias = 'spManagr', email='spManager@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='spManager@gene.com');
        insert u;

        assignPermissionSet(u.Id, 'EDM_Classification_Review');
        
        System.runAs(u){
            insert new GNE_SFA2_User_App_Context_gne__c(Run_in_SFA2_UI_gne__c = true, SFA2_Mode_gne__c = true, App_Name_gne__c = 'MedAffairs', Role_gne__c = 'SP', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];

            Account acc = new Account(Name='testAccount');
            insert acc;
            EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Business',RecordTypeId = rt.Id);
            insert req;

            ApexPages.StandardController sc = new ApexPages.StandardController(req);

            ApexPages.currentPage().getParameters().put('Id',req.Id);
            ApexPages.currentPage().getParameters().put('accountId',acc.Id);

            EDM_Cl_Req_Review_Edit_Create_Ext ext = new EDM_Cl_Req_Review_Edit_Create_Ext(sc);
            PageReference pr = ext.initWithAccount();

            ext.classificationRequest.EDM_Business_Role_gne__c = 'Some role';
            ext.classificationRequest.EDM_Type_of_Classification_gne__c = 'Business';

            String body = 'Test Method Call';
            Blob b = Blob.valueOf(body);
            ext.attachmentCV = new Attachment(Body = b, Name='testFile.txt');

            ext.save();

            System.assertEquals(ext.classificationRequest.EDM_Status_gne__c,ext.getStatus());
        }
    }

    static testMethod void crrNewClassificationSaveTest(){
        
        createConfiguration();

        Profile p = [select id from profile where name='GNE-MedAffairs-SP'];
        User u = new User(alias = 'spManagr', email='spManager@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='spManager@gene.com');
        insert u;

        assignPermissionSet(u.Id, 'EDM_Classification_Review');
        
        System.runAs(u){
            insert new GNE_SFA2_User_App_Context_gne__c(Run_in_SFA2_UI_gne__c = true, SFA2_Mode_gne__c = true, App_Name_gne__c = 'MedAffairs', Role_gne__c = 'SP', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];

            Account acc = new Account(Name='testAccount');
            insert acc;
            EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();

            ApexPages.StandardController sc = new ApexPages.StandardController(req);

            ApexPages.currentPage().getParameters().put('accountId',acc.Id);


            EDM_Cl_Req_Review_Edit_Create_Ext ext = new EDM_Cl_Req_Review_Edit_Create_Ext(sc);
            PageReference pr = ext.initWithAccount();

            ext.classificationRequest.EDM_Business_Role_gne__c = 'Some role';
            ext.classificationRequest.EDM_Type_of_Classification_gne__c = 'Business';

            String body = 'Test Method Call';
            Blob b = Blob.valueOf(body);
            ext.attachmentCV = new Attachment(Body = b, Name='testFile.txt');

            ext.save();

            System.assertEquals('',ext.getStatus());
        }
    }

    static testMethod void crrNewClinicalClassificationSaveTest(){
        
        createConfiguration();

        Profile p = [select id from profile where name='GNE-MedAffairs-SP'];
        User u = new User(alias = 'spManagr', email='spManager@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='spManager@gene.com');
        insert u;

        assignPermissionSet(u.Id, 'EDM_Classification_Review');
        
        System.runAs(u){
            insert new GNE_SFA2_User_App_Context_gne__c(Run_in_SFA2_UI_gne__c = true, SFA2_Mode_gne__c = true, App_Name_gne__c = 'MedAffairs', Role_gne__c = 'SP', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];

            Account acc = new Account(Name='testAccount');
            insert acc;
            EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();

            ApexPages.StandardController sc = new ApexPages.StandardController(req);

            ApexPages.currentPage().getParameters().put('accountId',acc.Id);


            EDM_Cl_Req_Review_Edit_Create_Ext ext = new EDM_Cl_Req_Review_Edit_Create_Ext(sc);
            PageReference pr = ext.initWithAccount();

            ext.classificationRequest.EDM_Business_Role_gne__c = 'Some role';
            ext.classificationRequest.EDM_Type_of_Classification_gne__c = 'Clinical';

            String body = 'Test Method Call';
            Blob b = Blob.valueOf(body);
            ext.attachmentCV = new Attachment(Body = b, Name='testFile.txt');

            ext.save();

            System.assertEquals('',ext.getStatus());
        }
    }

    private static void assignPermissionSet(Id userId, String permissionSetName) {
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = :permissionSetName];
            list <PermissionSetAssignment> PSAssignments = new list <PermissionSetAssignment>();
            List<User> users = [SELECT ID, (Select ID FROM PermissionSetAssignments WHERE PermissionSetID = :ps.id) FROM User WHERE Id = :userId];
            
            for (User u : users) {
                if (u.PermissionSetAssignments.size() == 0) 
                    PSAssignments.add( new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.ID ) );
            }

            if (!PSAssignments.isEmpty()) {
                insert PSAssignments;
            }
        }
    }

    private static void createConfiguration() {
        
        List<SFA2_Configuration_Object_Detail_gne__c> cods = new List<SFA2_Configuration_Object_Detail_gne__c>();
        SFA2_Configuration_Object_gne__c co = new SFA2_Configuration_Object_gne__c();
        SFA2_Configuration_Object_Detail_gne__c cod = new SFA2_Configuration_Object_Detail_gne__c();
        
        co = new SFA2_Configuration_Object_gne__c(
            Name = 'Classification_Request_Review',
            Application_Type__c = 'MedAffairs',
            Configuration_Type_gne__c = 'Page', 
            Is_Active_gne__c = true, 
            Is_Default_Record_Type_gne__c = true,  
            Object_Name_gne__c = 'EDM_Classification_Request_gne__c', 
            Order_gne__c = 0, 
            Record_Type_gne__c = 'Business', 
            Role_gne__c = 'SP', 
            RT_Available_On_Create_gne__c = true, 
            Section_Header_gne__c = 'Account Information'
        );
        insert co;

        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Account_Primary_Address_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Address',
            Order_gne__c = 1, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Account_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Account',
            Order_gne__c = 0, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Account_Specialty_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Speciality',
            Order_gne__c = 2, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Business_Classification_CV_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Business CV',
            Order_gne__c = 3, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Business_Cl_Role_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Business Speciality',
            Order_gne__c = 4, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Business_Cl_Performed_By_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Performed By',
            Order_gne__c = 5, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Business_Classification_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Business Classification',
            Order_gne__c = 6, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Business_Classification_Date_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Business Classification Date',
            Order_gne__c = 7, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Type_of_Classification_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Type of Classification',
            Order_gne__c = 8, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        cod = new SFA2_Configuration_Object_Detail_gne__c(
            Name = 'Classification_Request_Review_detail', 
            API_Name_gne__c = 'EDM_Business_Role_gne__c', 
            Availability_Mode_gne__c = 'Edit;View', 
            Configuration_Object_ref_gne__c = co.Id, 
            Is_Active_gne__c = true, 
            Is_Read_Only_gne__c = true, 
            Is_Required_gne__c = false, 
            Label_gne__c = 'Specialty / Business Role',
            Order_gne__c = 9, 
            Type_gne__c = 'Field'
        );
        cods.add(cod);
        insert cods;

        cods = new List<SFA2_Configuration_Object_Detail_gne__c>();
    }
}