@isTest(seeAllData=false)
private class CFAR_NewTrial_Controller_Test 
{
	@isTest static void addNewTrialNotPassed() 
	{
		User cfarUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(cfarUser)
		{
			CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
			CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
			CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();
			 List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());
            /*
            CFAR_Roles_To_Users_Mapping_gne__c setting = new CFAR_Roles_To_Users_Mapping_gne__c();
            setting.role_function_gne__c = 'Medical Science Liaison';
            setting.drop_down_value_gne__c  = 'MSL = Medical Science Liaison';
            setting.Name = 'MSL';
            setting.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
            insert setting;
            CFAR_Roles_To_Users_Mapping_gne__c setting2 = new CFAR_Roles_To_Users_Mapping_gne__c();
            setting2.role_function_gne__c = 'Medical Science Liaison';
            setting2.drop_down_value_gne__c = 'MSD = Medical Science Director';
            setting2.Name = 'MSD';
            setting2.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
            insert setting2;
            */
            List<CFAR_Roles_To_Users_Mapping_gne__c> roles = [Select c.SystemModstamp, c.SetupOwnerId, c.Role_Function_gne__c, c.Permissions_gne__c, c.Name, c.MayEdit, c.LastModifiedDate, c.LastModifiedById, c.IsLocked, c.IsDeleted, c.Id, c.Drop_down_value_gne__c, c.CreatedDate, c.CreatedById From CFAR_Roles_To_Users_Mapping_gne__c c];
            system.debug('---roles to users mapping: ');
            for(CFAR_Roles_To_Users_Mapping_gne__c role : roles) {
                system.debug(role);
            }
			CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
			system.assertNotEquals(newTrialCtrl.trialWrapper, null);
			system.assertNotEquals(newTrialCtrl.trialWrapper.receivedDateString, '');
			//system.assertEquals(newTrialCtrl.trialWrapper.sampleSize, '');
			system.assertNotEquals(newTrialCtrl.trialWrapper.validationErrors, null);
			newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c',area.Id);
			 //newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
			newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
			newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
			newTrialCtrl.trialWrapper.innerObject.put('CFAR_Specific_Indication_ref_gne__c', si.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
			newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
			newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id); 
			newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', System.today());
			newTrialCtrl.add();
			system.debug('newTrialCtrl.wrapperValidationErrors= '+newTrialCtrl.wrapperValidationErrors);
			system.assertEquals(newTrialCtrl.wrapperValidationErrors.values().isEmpty(), false);
		}
		
	}

    @isTest static void addNewTrialPassedCorrect()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());



            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.getProductSelectOptions();
            newTrialCtrl.trialWrapper.getShowSpecificIndicationOther();
            newTrialCtrl.trialWrapper.getShowGeneralIndicationOther();
            newTrialCtrl.trialWrapper.getTrialStatusSelectOptions();
            newtrialCtrl.trialWrapper.getTrialTypeSelectOptions();
            newTrialCtrl.trialWrapper.getTrialSelectOptions4();
            newTrialCtrl.trialWrapper.getTrialSelectOptions3();
            newTrialCtrl.trialWrapper.getTrialSelectOptions2();
            newTrialCtrl.trialWrapper.getTrialSelectOptions1();
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.getTherapeuticAreasSelectOptions();
            newTrialCtrl.trialWrapper.getDollarAndDrugSelectOptions();
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', today);
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
            System.assertNotEquals('', newTrialCtrl.trialWrapper.ThemeNo);

        }

    }
    
    @isTest static void addNewTrialSampleSizeNegativeError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;




            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            CFAR_Trial_Redirect_Controller rc = new CFAR_Trial_Redirect_Controller(new ApexPages.StandardController(address));
            rc.redirectToTrial();

            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '-1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }
    
    @isTest static void addNewTrialInvestigatorError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());



            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            //newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            //newTrialCtrl.investigatorChange();
            //newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            //newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }
    
    @isTest static void addNewTrialSubjectTypeError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());


            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            //newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }
    
    @isTest static void addNewTrialStudyPhaseBlankError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());

            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            //newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            //newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            //newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }

    @isTest static void addNewTrialTrialTypeBlankError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());

            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            //newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }
    
    @isTest static void addNewTrialMSLBlankError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());

            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            //newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }
    
    @isTest static void addNewTrialGIBlankError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());

            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            //newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            //newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }
    
    @isTest static void addNewTrialtherapeuticAreaBlankError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());

            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            //newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            //newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }
    
    @isTest static void addNewTrialPCBlankError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());

            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            //newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }



    @isTest static void addNewTrialReceivedDateInfutureAndSubjectTypeEqualsOtherError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());

            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Other');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = today.Month() + 1+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }

    @isTest static void addNewTrialReceivedDateBlankAndsubjectTypeEqualsHumanError()
    {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser)
        {
            CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;

            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
            parent.Name = 'testparent';
            parent.Active_gne__c = true;
            insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
            institution.Name = 'TestInstitution';
            institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution.Active_gne__c = true;
            insert institution;

            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
            institution2.Name = 'TestInstitution2';
            institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
            institution2.Active_gne__c = true;
            insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());

            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());

            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
            address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
            address.Country_gne__c = 'Argentina';
            address.Province_gne__c = 'TestProvince';
            address.City_gne__c = 'TestCity';
            address.Address_gne__c = 'TestAddress';
            address.Postal_Code_gne__c = '12345';
            address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
            insert address;

            CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
            joinAddress.Name = 'test';
            joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
            joinAddress.Contact_Address_ref_gne__c = address.id;
            insert joinAddress;

            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());

            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Human');
            newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();

            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddr = joinAddress.id;
            //newTrialCtrl.selAddr = newTrialCtrl.getcontactAddressOptions().get(0).getValue().id;
            newTrialCtrl.selAddrType = addressType.id;
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id);
            Date today = System.today();
            newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', (today + 1));
            newTrialCtrl.trialWrapper.sampleSize = '1';
            String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
            //newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            //newTrialCtrl.trialWrapper.receivedDateString = today.Month() + 1+'/'+today.day()+'/'+today.year();
            newTrialCtrl.trialWrapper.receivedDateString = '';
            newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.add();
            System.assertEquals(0, [SELECT ID FROM CFAR_Trial_gne__c].size());

        }

    }


    @isTest static void addNewTrialPassed()
	{
		User cfarUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(cfarUser)
		{
			CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
			CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
			CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();
            
            CFAR_General_Indication_gne__c gi1 = CFAR_TestUtils.createGeneralIndication('testind1');
			List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;
            
            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());
            
			CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
			system.assertNotEquals(newTrialCtrl.trialWrapper, null);
			system.assertNotEquals(newTrialCtrl.trialWrapper.receivedDateString, '');
			//system.assertEquals(newTrialCtrl.trialWrapper.sampleSize, '');
			system.assertNotEquals(newTrialCtrl.trialWrapper.validationErrors, null);
			newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue()};
			newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
			newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.trialWrapper.selectedGeneralIndications = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
			//newTrialCtrl.trialWrapper.innerObject.put('CFAR_Specific_Indication_ref_gne__c', [select Id from CFAR_Specific_Indication_gne__c where Name = 'Aerodigestive Tract' limit 1][0].Id);
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
			newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
			newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.investigatorChange();
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id); 
			Date today = System.today();
			newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', today);
			newTrialCtrl.trialWrapper.sampleSize = '1';
			String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
			newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
			newTrialCtrl.trialWrapper.productId = product.Id;
            newTrialCtrl.getContactAddressOptions();
            newTrialCtrl.getGneSupportSelectOptions();
            newTrialCtrl.getContactAddressTypeOptions();
            newTrialCtrl.getIsExternalInvestigatorRole();
			system.debug('newTrialCtrl.wrapperValidationErrors= '+newTrialCtrl.wrapperValidationErrors);
            newTrialCtrl.clearGeneralAndSpecificIndicationsForBiooncology();
            //newTrialCtrl.submitGeneralIndication();
            newTrialCtrl.getSelectedGeneralIndicationMappings();
            newTrialCtrl.add();
			//system.assertEquals(String.valueOf(newTrialCtrl.add()), 'System.PageReference[/apex/cfar_trial?Id='+newTrialCtrl.trialWrapper.innerObject.get('Id')+'&trialadded='+newTrialCtrl.trialWrapper.innerObject.get('Name')+']');
		}
		
	}
    
    @isTest static void addNewTrialOK() 
	{
		User cfarUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(cfarUser)
		{
            
            CFAR_Theme_gne__c theme = CFAR_TestUtils.createTheme('100', 'theme');
            
            CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
            
            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Abbreviation_gne__c = 'Ac';
            product.Generic_Name_gne__c = 'Accutane';
            product.Theme_ref_gne__c = theme.Id;
            product.Active_gne__c = true; 
            product.Other_GNE_Agent_Active_gne__c = true;
            insert product;
            
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            
            CFAR_Contact_gne__c primaryContact = CFAR_TestUtils.createTestPrimaryContact();
            
            CFAR_Therapeutic_Area_gne__c therapeuticArea = new CFAR_Therapeutic_Area_gne__c();
            therapeuticArea.Name = 'BioOncology';
            insert therapeuticArea;
            
            CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
            
            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
         	parent.Name = 'testparent';
         	parent.Active_gne__c = true;
         	insert parent;
            
            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
        	institution.Name = 'TestInstitution';
        	institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
        	institution.Active_gne__c = true;
        	insert institution;
            
            CFAR_Address_Type_gne__c addType = new CFAR_Address_Type_gne__c();
            addType.Name = 'Fedex Delivery';
            addType.Active_gne__c = true;
            insert addType;
            
            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
    		address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
    		address.Country_gne__c = 'USA';
    		address.Province_gne__c = 'TestProvince';
			address.City_gne__c = 'TestCity';
			address.Address_gne__c = 'TestAddress';
			address.Postal_Code_gne__c = '12345';
            address.Zip_gne__c = '99999';
            address.State_gne__c = 'LA';
        	address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
			insert address;
            
            CFAR_Dollar_and_Drug_gne__c DollarAndDrug = new CFAR_Dollar_and_Drug_gne__c();
            DollarAndDrug.Name = 'Only Drug';
            DollarAndDrug.Active_gne__c = true;
            insert DollarAndDrug;
            
            CFAR_Contact_Address_JO_gne__c jaddress = new CFAR_Contact_Address_JO_gne__c();
            jaddress.CFAR_Contact_ref_gne__c = investigator.id;
            jaddress.Contact_Address_ref_gne__c = address.id;
            jaddress.Department_Division_gne__c = 'USA';
            jaddress.active_gne__c = true;
            insert jaddress;
            
            
			CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();
            
            CFAR_General_Indication_gne__c generalIndication = new CFAR_General_Indication_gne__c();
            generalIndication.Name = 'Aerodigestive Tract';
            insert generalIndication;
            
			List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
            
            CFAR_Specific_Indication_gne__c specificIndication = new CFAR_Specific_Indication_gne__c();
            specificIndication.Name = 'Aerodigestive Tract';
            insert specificIndication;
            
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c = generalIndication.Id;
            ifta.Therapeutic_Area_gne__c= therapeuticArea.Name;
            insert ifta;
            
            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;
            
            Test.startTest();
            
            CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
            newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.id);
            newTrialCtrl.trialWrapper.productId = product.id;
            newTrialCtrl.trialWrapper.innerObject.put('Trial_type_ref_gne__c', trialType.id);
            newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', primaryContact.Id);
            newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', therapeuticArea.Id);
            newTrialCtrl.clearGeneralAndSpecificIndicationsForBiooncology();
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
            newTrialCtrl.trialWrapper.selectedStudyPhase = new List<String>{newTrialCtrl.trialWrapper.availableStudyPhase.get(0).getValue(), newTrialCtrl.trialWrapper.availableStudyPhase.get(1).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal'); 
            newTrialCtrl.trialWrapper.selectedGeneralIndicationsPopup = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.submitGeneralIndication();
            newTrialCtrl.getSelectedGeneralIndicationMappings();
            newTrialCtrl.cancelGeneralIndication();
            newTrialCtrl.submitGeneralIndication();
            newTrialCtrl.trialWrapper.selectedGeneralIndicationsPopup = new List<String>{newTrialCtrl.trialWrapper.availableGeneralIndications.get(0).getValue()};
            newTrialCtrl.submitGeneralIndication();
            newTrialCtrl.getSelectedGeneralIndicationMappings();
            newTrialCtrl.trialWrapper.selectedSpecificIndications = new List<String>{newTrialCtrl.trialWrapper.availableSpecificIndications.get(0).getValue()};
            newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 100);
			newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
            newTrialCtrl.trialWrapper.getPrimaryContactSelectOptions1();
            newTrialCtrl.trialWrapper.getPrimaryContactSelectOptions2();
            newTrialCtrl.trialWrapper.getPrimaryContactSelectOptions3();
            newTrialCtrl.trialWrapper.getPrimaryContactSelectOptions4();
            newTrialCtrl.trialWrapper.getInvestigatorSelectOptions1();
            newTrialCtrl.trialWrapper.getInvestigatorSelectOptions2();
            newTrialCtrl.trialWrapper.getInvestigatorSelectOptions3();
            newTrialCtrl.trialWrapper.getInvestigatorSelectOptions4();
            newTrialCtrl.trialWrapper.getMSLSelectOptions1();
            newTrialCtrl.trialWrapper.getMSLSelectOptions2();
            newTrialCtrl.trialWrapper.getMSLSelectOptions3();
            newTrialCtrl.trialWrapper.getMSLSelectOptions4();
            
            newTrialCtrl.getContactAddressOptions();
            jaddress.active_gne__c = false;
            update jaddress;
            newTrialCtrl.getContactAddressOptions();
            
            newTrialCtrl.trialWrapper.innerObject.put('Dollar_and_Drug_ref_gne__c', DollarAndDrug.id);
            newTrialCtrl.selPIGneSupport = DollarAndDrug.id;
            
            newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id); 
			Date today = System.today();
			newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', today);
			newTrialCtrl.trialWrapper.sampleSize = '1';
			String todayDateFormatted= today.month()+'/'+today.day()+'/'+today.year();
			newTrialCtrl.trialWrapper.receivedDateString = todayDateFormatted;
            
            newTrialCtrl.selAddr = address.id;
            newTrialCtrl.selAddrType = addType.id;
            
            
            newTrialCtrl.add();
            Test.stopTest();
            
}
		
	}
    
    
	@isTest static void testDuplicate()
	{
		User cfarUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(cfarUser)
		{

            CFAR_Product_gne__c product = new CFAR_Product_gne__c();
            product.Name = 'Accutane';
            product.Generic_Name_gne__c = 'generic';
            insert product;
            CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
            trialType.Name = 'Collaborative Study';
            insert trialType;
            CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
            area.Name = 'BioOncology';
            insert area;
            CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
            gi.Name = 'Aerodigestive Tract';
            insert gi;
            CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
            si.Name = 'Aerodigestive Tract';
            insert si;
            CFAR_Indication_for_Therapeutic_Area_gne__c ifta= new CFAR_Indication_for_Therapeutic_Area_gne__c();
            ifta.General_Indication_gne__c=gi.Id;
            ifta.Therapeutic_Area_gne__c= area.Name;
            insert ifta;
            
            CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
            srt.Name = 'test';
            srt.Active_gne__c = true;
            srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
            insert srt;

            System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());
            
            List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
			CFAR_Trial_gne__c trial = new CFAR_Trial_gne__c
			(
				Product_ref_gne__c = product.Id,
				Trial_Type_ref_gne__c = trialType.Id,
				Genentech_Primary_Contact_ref_gne__c = CFAR_TestUtils.createTestPrimaryContact().Id,
				Therapeutic_Area_ref_gne__c = area.Id,
				//Study_Phase_gne__c = 'Phase I',
                Study_Phase_Multi_gne__c = 'I',
				Subject_Type__c = 'Animal',
				CFAR_General_Indication_ref_gne__c = gi.Id,
				CFAR_Specific_Indication_ref_gne__c = si.Id,
				Planned_Enrollment_gne__c = 1,
                SRT_Team_ref_gne__c = srt.id,
				Investigator_ref_gne__c = CFAR_TestUtils.createTestInvestigator().Id,
				MSL_ref_gne__c = CFAR_TestUtils.createTestMSL().Id,
				Received_Date_gne__c = System.today(),
                IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-12343',
				Other_Trial_gne_Id__c = 'THE_SAME_VALUE'
			);
			insert trial;

			CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
			CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
			CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();
			CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
			newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
		 	newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'Phase I');
            newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
			newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
			newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
            newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
			newTrialCtrl.trialWrapper.innerObject.put('CFAR_Specific_Indication_ref_gne__c', si.Id);
			newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
			newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
			newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id); 
			newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', System.today());
			newTrialCtrl.trialWrapper.sampleSize = '1';
			newTrialCtrl.trialWrapper.productId = product.Id;
			newTrialCtrl.trialWrapper.innerObject.put('Other_Trial_gne_Id__c', 'THE_SAME_VALUE');
			system.assertEquals(newTrialCtrl.add(), null);
		}
	}
	@isTest	static void testOtherFunctions()
	{
		CFAR_Product_gne__c product = new CFAR_Product_gne__c();
        product.Name = 'Accutane';
        product.Generic_Name_gne__c = 'generic';
        insert product;
        CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
        trialType.Name = 'Collaborative Study';
        insert trialType;
        CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
        area.Name = 'BioOncology';
        insert area;
        CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c();
        gi.Name = 'Aerodigestive Tract';
        insert gi;
        CFAR_Specific_Indication_gne__c si = new CFAR_Specific_Indication_gne__c();
        si.Name = 'Aerodigestive Tract';
        insert si;
            
        CFAR_Picklist_Value_gne__c srt = new CFAR_Picklist_Value_gne__c();
        srt.Name = 'test';
        srt.Active_gne__c = true;
        srt.RecordTypeId = [SELECT ID FROM RecordType WHERE Name = 'SRT Team' LIMIT 1].id;
        insert srt;

        System.assertEquals(1, [SELECT ID FROM CFAR_Picklist_Value_gne__c].size());
            
		CFAR_Contact_gne__c prmCnt = CFAR_TestUtils.createTestPrimaryContact();
		CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
		List<CFAR_Roles_To_Users_Mapping_gne__c> mappings = CFAR_TestUtils.createRolesToUsersMapping();
		CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();
		CFAR_NewTrial_Controller newTrialCtrl = new CFAR_NewTrial_Controller();
		system.assertEquals(newTrialCtrl.getConfirmMessage(), 'A new Trial has been created, Trial No#:');
		system.assertEquals(String.valueOf(newTrialCtrl.redirect()) ,'System.PageReference[/apex/cfar_home]');
		newTrialCtrl.trialWrapper.innerObject.put('Product_ref_gne__c', product.Id);
		newTrialCtrl.trialWrapper.innerObject.put('Trial_Type_ref_gne__c', trialType.Id);
		newTrialCtrl.trialWrapper.innerObject.put('Genentech_Primary_Contact_ref_gne__c', prmCnt.Id);
		newTrialCtrl.trialWrapper.innerObject.put('Therapeutic_Area_ref_gne__c', area.Id);
		//newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_gne__c', 'Phase I');
        newTrialCtrl.trialWrapper.innerObject.put('Study_Phase_Multi_gne__c', 'I');
		newTrialCtrl.trialWrapper.innerObject.put('Subject_Type__c', 'Animal');
        newTrialCtrl.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
		newTrialCtrl.trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', gi.Id);
		newTrialCtrl.trialWrapper.innerObject.put('CFAR_Specific_Indication_ref_gne__c', si.Id);
		newTrialCtrl.trialWrapper.innerObject.put('Planned_Enrollment_gne__c', 1);
        newTrialCtrl.trialWrapper.innerObject.put('SRT_Team_ref_gne__c', srt.id);
		newTrialCtrl.trialWrapper.innerObject.put('Investigator_ref_gne__c', investigator.Id);
		newTrialCtrl.trialWrapper.innerObject.put('MSL_ref_gne__c', msl.Id); 
		newTrialCtrl.trialWrapper.innerObject.put('Received_Date_gne__c', System.today());
		newTrialCtrl.trialWrapper.sampleSize = '1';
		newTrialCtrl.trialWrapper.productId = product.Id;
		newTrialCtrl.trialWrapper.innerObject.put('Other_Trial_gne_Id__c', 'THE_SAME_VALUE');
		newTrialCtrl.clearGeneralAndSpecificIndicationsForBiooncology();
		newTrialCtrl.clear();
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Product_ref_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Trial_Type_ref_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Genentech_Primary_Contact_ref_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Therapeutic_Area_ref_gne__c'), null);
		//system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Study_Phase_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Study_Phase_Multi_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Subject_Type__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('CFAR_General_Indication_ref_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('CFAR_Specific_Indication_ref_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Planned_Enrollment_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Investigator_ref_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('MSL_ref_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Received_Date_gne__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.innerObject.get('Other_Trial_gne_Id__c'), null);
		system.assertEquals(newTrialCtrl.trialWrapper.receivedDateString, '');
		system.assertEquals(newTrialCtrl.trialWrapper.sampleSize,'');
		system.assertEquals(newTrialCtrl.trialWrapper.productId, null);
		system.assertEquals(newTrialCtrl.trialWrapper.primaryContactId, null);
		system.assertEquals(newTrialCtrl.trialWrapper.investigatorId, null);
		system.assertEquals(newTrialCtrl.trialWrapper.mslId, null);
		system.assertEquals(newTrialCtrl.trialWrapper.mslId, null);
		system.assertNotEquals(newTrialCtrl.trialWrapper.validationErrors, null);
	}
}