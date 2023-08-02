@isTest
public without sharing class GNE_SFA2_Account_Trigger_Test {
	
	/*****************
	* testBusinessProfPersonFailedValidation must be commented - it checks validation rule from Account_Validation_Rules, that cannot be executed.
	* The record type for which validation rule is fired is inactive - we cannot create an Account wiht inactive recordType
	**************/
	/*public static testMethod void testBusinessProfPersonFailedValidation() {
		prepareEnv('GNE-SFA2');
		
		User testU = GNE_SFA2_Util.selectSFA2User();
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Account hco1 = createAccount('TEST HCO');
			
			Test.startTest();
			DMLException ex = null;
			
			try {
				Account hcp1 = createAccount('John', 'Smith', new Map<String,String> {
					'RecordTypeId' => getAccountRecordTypeID('Business_Professional_vod'),
					'Business_Professional_Person_vod__c' => hco1.Id});
			} catch(DMLException e) {
				ex = e;
			}
			
			System.assertNotEquals(null,ex);
			System.assert(ex.getMessage().contains(System.Label.Account_BPP_Must_Be_Person), ex.getMessage());
					
			Test.stopTest();
		}
	}*/
	
	
	public static testMethod void testAccountNameChangeFailedValidation() {
		prepareEnv('GNE-SFA2');
		
		User testU = GNE_SFA2_Util.selectSFA2User();
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID('Professional_vod')});
			Account hco1 = createAccount('TEST HCO');
			
			Test.startTest();
			DMLException ex = null;
			
			try {
				hcp1.FirstName += '_Changed';
				update hcp1;	
			} catch(DMLException e) {
				ex = e;
			}
			System.assertNotEquals(null,ex);
			System.assert(ex.getMessage().contains(System.Label.Account_Name_Cannot_Be_Modified), ex.getMessage());
			
			ex = null;
			
			try {
				hco1.Name += '_Changed';
				update hco1;	
			} catch(DMLException e) {
				ex = e;
			}
			
			System.assertNotEquals(null,ex);
			System.assert(ex.getMessage().contains(System.Label.Account_Name_Cannot_Be_Modified), ex.getMessage());
			
			Test.stopTest();
		}
	}
	
	public static testMethod void testPrimaryParentFailedValidation() {
		prepareEnv('GNE-SFA2');
		
		User testU = GNE_SFA2_Util.selectSFA2User();
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID('Professional_vod')});
			
			Test.startTest();
			DMLException ex = null;
			
			try {
				Account hcp2 = createAccount('Jane', 'Smith', new Map<String,String> {
					'Primary_Parent_vod__c' => hcp1.Id,
					'RecordTypeId' => getAccountRecordTypeID('Professional_vod')});
			} catch(DMLException e) {
				ex = e;
			}
			
			System.assertNotEquals(null,ex);
			System.assert(ex.getMessage().contains(System.Label.Account_Primary_Parent_Must_Be_HCO), ex.getMessage());
					
			Test.stopTest();
		}
	}
	
	public static testMethod void testCanadaHcoFailedValidation() {
		system.debug('testCanadaHcoFailedValidation');
		
		User testU = getSFA2User('RCanada-SFA-TS');
		
		System.assertNotEquals(null,testU);
		System.runAs(testU) {
			GNE_SFA2_Util.getCurrentUserProfileName();
		}
		prepareEnv('RCanada-SFA-TS');
		System.runAs(testU) {
			system.debug('userHasCanadaProfile ' + GNE_SFA2_Account_Trigger_Helper.userHasCanadaProfile());
			Account hco1 = createAccount('Test HCO', new Map<String, Object>{
				'Account_Type_gne__c' => new List<String>(GNE_SFA2_Account_Validation_Rules.CANADA_HCO_ACCOUNT_TYPES_NOT_FOR_EDIT)[0],
				'RecordTypeId' => getAccountRecordTypeID(GNE_SFA2_Account_Validation_Rules.RECORD_TYPE_CANADA_HCO)});
			
			Test.startTest();
			DMLException ex = null;
			
			try {
				hco1.Phone = '99999 999';
				update hco1;
			} catch(DMLException e) {
				ex = e;
			}
			
			System.assertNotEquals(null,ex);
			System.assert(ex.getMessage().contains(System.Label.Account_CAN_HCO_Cannot_Be_Modified), ex.getMessage());
					
			Test.stopTest();
		}
	}
	
	public static testMethod void testCanadaHcpFailedValidation() {
		system.debug('testCanadaHcpFailedValidation');
		
		User testU = getSFA2User('RCanada-SFA-TS');
		
		System.assertNotEquals(null,testU);
		System.runAs(testU) {
			GNE_SFA2_Util.getCurrentUserProfileName();
		}
		prepareEnv('RCanada-SFA-TS');
		System.runAs(testU) {
			system.debug('userHasCanadaProfile ' + GNE_SFA2_Account_Trigger_Helper.userHasCanadaProfile());
			Account hcp1 = createAccount('John', 'Canada', new Map<String, Object>{
				'Account_Type_gne__c' => new List<String>(GNE_SFA2_Account_Validation_Rules.CANADA_HCP_ACCOUNT_TYPES_NOT_FOR_EDIT)[0],
				'RecordTypeId' => getAccountRecordTypeID(GNE_SFA2_Account_Validation_Rules.RECORD_TYPE_CANADA_HCP)});
			
			Test.startTest();
			DMLException ex = null;
			
			try {
				hcp1.Middle_vod__c = 'changed';
				update hcp1;
			} catch(DMLException e) {
				ex = e;
			}
			
			System.assertNotEquals(null,ex);
			System.assert(ex.getMessage().contains(System.Label.Account_CAN_HCP_Cannot_Be_Modified), ex.getMessage());
					
			Test.stopTest();
		}
	}
	
	public static testMethod void testHospitalDepartmentAssignment() {
		prepareEnv('RCanada-SFA-TS');
		User testU = createSFA2User('RCanada-SFA-TS');
		
		System.assertNotEquals(null,testU);
		insert testU;
		System.runAs(testU) {
			Account hco1 = createAccount('Dep1', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID(GNE_SFA2_Account_Field_Updates.RECORD_TYPE_CAN_HOSPITAL)});
			
			Test.startTest();
				
			Account hco2 = createAccount('Dep2', new Map<String, Object>{
				'ParentId' => hco1.Id,
				'RecordTypeId' => getAccountRecordTypeID(GNE_SFA2_Account_Field_Updates.RECORD_TYPE_CAN_HOSPITAL)});
				
			Account savedAccount = [SELECT ParentId, Parent_Hospital_gne__c FROM Account WHERE Id = :hco2.Id];
			
			System.assertEquals(savedAccount.ParentId,savedAccount.Parent_Hospital_gne__c);

			Test.stopTest();
		}
	}
	
	public static testMethod void testDCRCreatedOnUpdate() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{
				'Stewardship_System_Name_gne__c' => 'TEST',
				'RecordTypeId' => getAccountRecordTypeID('Professional_vod')});
			
			Test.startTest();
			
			hcp1.Stewardship_System_Name_gne__c = GNE_SFA2_Account_Child_Record_Updates.STEWARDSHIP_SYSTEM_NAME;
			hcp1.Internal_Stewardship_Reason_gne__c = 'TEST';
			
			insert new GNE_SFA2_DCR_Config_Items_gne__c( Name = 'AddressDcrFields', Value_gne__c = 'Name,City_vod__c,State_vod__c,Zip_vod__c', Key_gne__c = 'AddressDcrFields', Configuration_Type_gne__c = 'Main' );
			update hcp1;
			
			List<Change_Request_gne__c> dcrs = [SELECT RecordType.Name, Type_gne__c, Vendor_Type_gne__c 
												FROM Change_Request_gne__c
												WHERE Account_gne__c = :hcp1.Id];
			System.assertEquals(1, dcrs.size());
			System.assertEquals(GNE_SFA2_Account_Child_Record_Updates.DCR_RECORD_TYPE_SYSTEM_CREATED, dcrs[0].RecordType.Name);
			System.assertEquals(GNE_SFA2_Account_Child_Record_Updates.DCR_RECORD_TYPE_SYSTEM_CREATED, dcrs[0].Type_gne__c);
			System.assertEquals(GNE_SFA2_Account_Child_Record_Updates.DCR_DEFAULT_VENDOR_TYPE, dcrs[0].Vendor_Type_gne__c);
			
			Test.stopTest();
		}
	}
	
	public static testMethod void testDeleteAccountWithSavedCallsFailedvaludation() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID('Professional_vod')});
				
			Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
			call.Account_vod__c = hcp1.Id;
			call.Status_vod__c = 'Saved_vod';
			insert call;
			
			Test.startTest();
			
			DMLException ex = null;
			
			try {
				delete hcp1;
			} catch(DMLException e) {
				ex = e;
			}
			
			System.assertNotEquals(null,ex);
			System.assert(ex.getMessage().contains(System.Label.Account_With_Saved_Calls_Cannot_Be_Deleted), ex.getMessage());
			update hcp1;

			Test.stopTest();
		}
	}
	
	public static testMethod void testDeleteAccountWithRelatedAffiliations() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID('Professional_vod')});
				
			Account hcp2 = createAccount('Jane', 'Smith', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID('Professional_vod')});
			
			Affiliation_vod__c aff = GNE_SFA2_Triggers_Test_Util.prepareAffiliation_vod(hcp1.Id, null, hcp2.Id, null);
			aff.Comments_vod__c			= 'TEST';
			aff.Role_vod__c				= 'Affiliated with';
			aff.Affiliation_Type_gne__c = 'AFFILIATION';
            insert aff;
            
            Test.startTest();
            
            List<Affiliation_vod__c> affs = [SELECT Id 
											 FROM Affiliation_vod__c
											 WHERE From_Account_vod__c = :hcp1.Id];
			
            System.assertEquals(1,affs.size());
			
			delete hcp1;
			
			affs = [SELECT Id 
					FROM Affiliation_vod__c
					WHERE From_Account_vod__c = :hcp1.Id];
			
			
			System.assertEquals(0,affs.size());

			Test.stopTest();
		}
	}
	
	public static testMethod void testcreateDoCAffilationOnParentChange() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Account hco1 = createAccount('DoC1', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID('Practice_vod'),
				'Account_Type_gne__c' => 'Prison'});
			
			Account hco2 = createAccount('DoC Loc', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID(GNE_SFA2_Account_Child_Record_Updates.RECORD_TYPE_DOC)});
			
			Test.startTest();
			
			hco2.Parent_DoC_gne__c = hco1.Id;
			
			update hco2;
			
			List<Affiliation_vod__c> affs = [SELECT Id, To_Account_vod__c, Role_vod__c 
											 FROM Affiliation_vod__c
											 WHERE From_Account_vod__c = :hco2.Id];
			
            System.assertEquals(1,affs.size());
            System.assertEquals(hco1.Id,affs[0].To_Account_vod__c);
            System.assertEquals('DoC Location',affs[0].Role_vod__c);
			
			Test.stopTest();
		}
	}
	
	public static testMethod void testAccountTypeAssignment() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
		
		Map<String, String> envVariablesMap = GNE_SFA2_Account_Trigger_Helper.getEnvironmentVariablesMap();
		String key_prefix = 'AccountType.account.';
	    String defaultAccountType = envVariablesMap.get(key_prefix + 'default');
	        
		
		System.runAs(testU) {
			Test.startTest();
			Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID('Professional_vod')});
			hcp1 = [SELECT Account_Type_gne__c, RecordType.Name FROM Account WHERE Id = :hcp1.Id];
			String accType = envVariablesMap.get(key_prefix + hcp1.RecordType.Name);
			
			System.assertNotEquals(null,hcp1.Account_Type_gne__c);
			System.assertEquals(accType!=null ? accType : defaultAccountType, hcp1.Account_Type_gne__c);

			Test.stopTest();
		}
	}
	
	public static testMethod void testAccountTypeAssignmentForCanada() {
		system.debug('testAccountTypeAssignmentForCanada');
		User testU = getSFA2User('RCanada-SFA-TS');
		
		System.assertNotEquals(null,testU);
		System.runAs(testU) {
			GNE_SFA2_Util.getCurrentUserProfileName();
		}
		prepareEnv('RCanada-SFA-TS');
		Map<String, String> envVariablesMap = GNE_SFA2_Account_Trigger_Helper.getEnvironmentVariablesMap();
		String key_prefix = 'AccountType.account.';
	    String defaultAccountType = envVariablesMap.get(key_prefix + 'default');
	        
		
		System.runAs(testU) {
			system.debug('userHasCanadaProfile ' + GNE_SFA2_Account_Trigger_Helper.userHasCanadaProfile());
			Test.startTest();
			
			Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID('Professional_vod')});
			hcp1 = [SELECT Account_Type_gne__c, RecordType.Name FROM Account WHERE Id = :hcp1.Id];
			system.debug('hcp1: ' + hcp1);
			String accType = envVariablesMap.get(key_prefix + hcp1.RecordType.Name);
			
			System.assertEquals(null,hcp1.Account_Type_gne__c);
			
			Test.stopTest();
		}
	}
	
	public static testMethod void testStewardshipSystemAssignment() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
	    String defaultSS = GNE_SFA2_Account_Trigger_Helper.DEFAULT_STEWARDSHIP_SYSTEM_NAME;
	        
		
		System.runAs(testU) {
			Test.startTest();
			Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{
				'RecordTypeId' => getAccountRecordTypeID('Professional_vod'), 'Account_Type_gne__c' => 'Health Care Professional'});
			hcp1 = [SELECT Stewardship_System_Name_gne__c, RecordType.Name FROM Account WHERE Id = :hcp1.Id];
			System.assertEquals('ams',hcp1.Stewardship_System_Name_gne__c);
			Test.stopTest();
		}
	}
		
	public static testMethod void testCanadaMRMLockFailedValidation() {
		system.debug('testCanadaMRMLockFailedValidation');
		
		User testU = getSFA2User('RCanada-SFA-TS');
		
		System.assertNotEquals(null,testU);
		System.runAs(testU) {
			GNE_SFA2_Util.getCurrentUserProfileName();
		}
		prepareEnv('RCanada-SFA-TS');
		System.runAs(testU) {
			system.debug('userHasCanadaProfile ' + GNE_SFA2_Account_Trigger_Helper.userHasCanadaProfile());
			Test.startTest();
            
            DMLException ex = null;
            Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{ 
				'MRM_Lock_can_gne__c' => false
				});
           
			hcp1.MRM_Lock_can_gne__c = true;
			
			try {
				update hcp1;
			} catch(DMLException e) {
				ex = e;
			}
			
			//System.assertNotEquals(null,ex);
			//System.assert(ex.getMessage().contains(System.Label.Account_CAN_MRM_Lock_Cannot_Be_Modified), ex.getMessage());
			System.assertEquals(null,ex);

			ex = null;
			Account hco1 = createAccount('HCO1', new Map<String, Object>{ 
				'MRM_Lock_can_gne__c' => false});
			hco1.MRM_Lock_can_gne__c = true;
			
			try {
				update hco1;
			} catch(DMLException e) {
				ex = e;
			}
			
			//System.assertNotEquals(null,ex);
			//System.assert(ex.getMessage().contains(System.Label.Account_CAN_MRM_Lock_Cannot_Be_Modified), ex.getMessage());
            System.assertEquals(null,ex);

            Test.stopTest();

		}
	}
	
	public static testMethod void testCanadaMRMLockPassValidation() {
		prepareEnv('RCanada-SFA-TS');
		User testU = createSFA2User('RCanada-SFA-TS');
		
		System.assertNotEquals(null,testU);
		insert testU;
		System.runAs(testU) {
			Account hcp1 = createAccount('John', 'Smith', new Map<String, Object>{ 
				'MRM_Lock_can_gne__c' => false});
				
			Account hco1 = createAccount('HCO1', new Map<String, Object>{ 
				'MRM_Lock_can_gne__c' => false});
			
				
            Test.startTest();
            
            DMLException ex = null;
			
			try {
				hcp1.Cell_Phone_gne__c = '999 99999';
            	update hcp1;
			} catch(DMLException e) {
				ex = e;
			}
			
			System.assertEquals(null,ex);
			
			try {
				hco1.Preferred_Name_vod__c = 'TEST';
            	update hco1;
			} catch(DMLException e) {
				ex = e;
			}
			
			System.assertEquals(null,ex);
			Test.stopTest();
		}
	}
	
	public static testMethod void testContractNameSet() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Test.startTest();
			
			Account hco1 = createAccount('HCO1');
			
			hco1 = [SELECT Contract_Name_gne__c, Name FROM Account WHERE Id = :hco1.Id];
			
			System.assertEquals(hco1.Contract_Name_gne__c, hco1.Name);
			Test.stopTest();
		}
	}
	
	public static testMethod void testInactiveDateSet() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Test.startTest();
			
			Account hco1 = createAccount('HCO1', new Map<String, Object>{ 
				'Status_gne__c' => 'Inactive'});
			
			hco1 = [SELECT Date_Inactive_gne__c FROM Account WHERE Id = :hco1.Id];
			
			System.assertNotEquals(null, hco1.Date_Inactive_gne__c);
			
			hco1.Status_gne__c = 'Active';
			update hco1;
			
			hco1 = [SELECT Date_Inactive_gne__c FROM Account WHERE Id = :hco1.Id];
			
			System.assertEquals(null, hco1.Date_Inactive_gne__c);
			
			Test.stopTest();
		}
	}
	
	public static testMethod void testAlternateNameCreatedOnNameChange() {
		prepareEnv('GNE-SYS-Support');
		User testU = createSFA2User('GNE-SYS-Support');
		
		System.assertNotEquals(null,testU);
		insert testU;
		System.runAs(testU) {
			Account hcp1 = createAccount('John', 'Smith');
			
			String oldName = hcp1.FirstName + ' ' + hcp1.LastName;
			
			Test.startTest();
			
			hcp1.LastName = 'Johnson';
			update hcp1;
			
			List<Alternate_Name_gne__c> altNames = [SELECT Alternate_Name_gne__c, Status_gne__c  
													FROM Alternate_Name_gne__c WHERE Account_Name_gne__c = :hcp1.Id];
			
			//System.assertEquals(1, altNames.size());
			System.assertEquals(oldName, altNames[0].Alternate_Name_gne__c);
			System.assertEquals(GNE_SFA2_Account_Child_Record_Updates.ALTERNATE_NAME_STATUS, altNames[0].Status_gne__c);
			
			Test.stopTest();
		}
	}
	
	public static testMethod void testDCRChangeAMSId() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			Test.startTest();
            
			Account hcp1 = createAccount('John', 'Smith');
			
			insert new GNE_SFA2_DCR_Config_Items_gne__c( Name = 'AddressDcrFields', Value_gne__c = 'Name,City_vod__c,State_vod__c,Zip_vod__c', Key_gne__c = 'AddressDcrFields', Configuration_Type_gne__c = 'Main' );
			Change_Request_gne__c dcr = GNE_SFA2_Triggers_Test_Util.prepareChange_Request_gne();
			dcr.RecordTypeId= [Select Id from Recordtype 
                    		   where Name= :GNE_SFA2_Account_Child_Record_Updates.DCR_RECORD_TYPE_SYSTEM_CREATED 
                    		   and SobjectType='Change_Request_gne__c'].Id;
            dcr.Type_gne__c=GNE_SFA2_Account_Child_Record_Updates.DCR_RECORD_TYPE_SYSTEM_CREATED;
            dcr.Description_gne__c='test';
            dcr.Account_gne__c=hcp1.Id;
            dcr.Vendor_Type_gne__c='ams';
            dcr.Status_gne__c='Submitted';
            dcr.ams_id_1_gne__c='test';
            
            insert dcr;
            
            dcr = [SELECT Id, ams_id_1_gne__c, status_gne__c, ams_id_gne__c FROM Change_Request_gne__c WHERE Account_gne__c = :hcp1.Id];
            
            hcp1.Stewardship_System_Name_gne__c='ams';
            hcp1.ams_id_gne__c = 'test'; 
			
			update hcp1;
			
			dcr = [SELECT Id, ams_id_1_gne__c, status_gne__c, ams_id_gne__c FROM Change_Request_gne__c WHERE Account_gne__c = :hcp1.Id];
			
			System.assertEquals( false, GNE_SFA2_Util.isMergeMode() ); 
			System.assertEquals(dcr.ams_id_1_gne__c, dcr.ams_id_gne__c);
			System.assertEquals('Submitted',dcr.status_gne__c);
			
			Test.stopTest();
		}
	}
	
	public static testMethod void testManyAccountsDmlInSafeMode() {
		prepareEnv('GNE-SFA2');
		User testU = GNE_SFA2_Util.selectSFA2User();
		
		System.assertNotEquals(null,testU);
		
		System.runAs(testU) {
			
			final String cellPhone = '999 999';
			final Integer batchSize = 80;
			
			Test.startTest();
			
			List<Account> accs = new List<Account>();
			for(Integer i = 0; i<batchSize;i++) {
				accs.add(createAccount('John' + i, 'Smith',null,new Map<String,Object>(),false));
			}
			
			insert accs;
			
			for(Integer i = 0; i<batchSize;i++) {
				
				if (Math.mod(i,2) == 0) {
					accs[i].LastName += '_CHANGED';
				} else {
					accs[i].Cell_Phone_gne__c = cellPhone;
				}
			}
			
			Database.SaveResult[] results = Database.update(accs, false);
			
			for(Integer i = 0; i<batchSize;i++) {
				Database.SaveResult sr = results[i];
				if (Math.mod(i,2) == 0) {
					System.assert(!sr.isSuccess());
					System.assert(sr.getErrors()[0].getMessage().contains(System.Label.Account_Name_Cannot_Be_Modified), sr.getErrors()[0].getMessage());
				} else {
					System.assert(sr.isSuccess());
				}
			}
			
			Integer changedSize = [SELECT count() FROM Account
								   WHERE Id IN :accs AND Cell_Phone_gne__c = :cellPhone];
								   	
			System.assertEquals(batchSize/2, changedSize);				   	
			
			Test.stopTest();
		}
	}
	
	public static testMethod void onAfterUpdateAccountSBMsTest(){

		insert new Speaker_Bureau_Notification_Email__c(Name = 'Email',Value__c = 'sbs-d@gene.com');
		insert new Speaker_Bureau_Notification_Email__c(Name = 'DateTimeFormat',Value__c = 'dd/MM/yyyy hh:mm:ss a');
		insert new Speaker_Bureau_Notification_Email__c(Name = 'DateTimeZone',Value__c = 'PST');
		insert new Speaker_Bureau_Notification_Email__c(Name = 'SenderDisplayName',Value__c = 'Salesforce');
		List<Account> triggerOld = new List<Account>();
		Account a = new Account(
			Name = 'TestAccount1',
			OwnerId = UserInfo.getUserId(),
			EDM_Business_Classification_gne__c = 'Regional',
			EDM_Clinical_Classification_gne__c = 'Local',
			AGS_EX_Exclusion_Status_base_gne__c = 'Rejected'
		);
		triggerOld.add(a);
		insert triggerOld;

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year()));
		insert businessBureau;
		insert new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = businessBureau.Id,
			Bureau_Member_gne__c = triggerOld[0].Id
		);
		Speaker_Bureau_gne__c clinicalBureau = new Speaker_Bureau_gne__c(Name='ClinicalBureau',Speaker_Bureau_Type_gne__c = 'Clinical',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year()));
		insert clinicalBureau;
		insert new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = clinicalBureau.Id,
			Bureau_Member_gne__c = triggerOld[0].Id
		);

		List<Account> triggerNew = triggerOld.deepClone(true,true,true);
		triggerNew[0].EDM_Business_Classification_gne__c = 'Global';
		triggerNew[0].EDM_Clinical_Classification_gne__c = 'National';
		triggerNew[0].AGS_EX_Exclusion_Status_base_gne__c = 'Pending';
		update triggerNew;
		
		GNE_SFA2_Account_Child_Record_Updates.onAfterUpdate(triggerOld,triggerNew);

		List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>([
			Select Speaker_Scope_gne__c From Speaker_Bureau_Membership_gne__c
		]);
		System.assertEquals(2,sbm.size());
		System.assertEquals('National',sbm[0].Speaker_Scope_gne__c);
		System.assertEquals('National',sbm[1].Speaker_Scope_gne__c);
	}
	
	private static Account createAccount(String Name) {
		return createAccount(Name, new Map<String,Object>());
	}
	
	private static Account createAccount(String Name, Map<String,Object> proposedValues) {
		return createAccount(null, null, Name, proposedValues, true);
	}
	
	private static Account createAccount(String FirstName, String LastName) {
		return createAccount(FirstName, LastName, new Map<String,Object>());
	}
	
	private static Account createAccount(String FirstName, String LastName, Map<String,Object> proposedValues) {
		return createAccount(FirstName, LastName, null, proposedValues,true);
	}
	
	private static Account createAccount(String FirstName, String LastName, String Name, Map<String,Object> proposedValues, Boolean runDbOperation) {
		Account acc;
		if(FirstName!=null) {
			acc = new Account(FirstName = FirstName, LastName = LastName);
			acc.RecordTypeId = [Select Id From RecordType Where sObjectType='Account' AND DeveloperName ='Professional_vod' Limit 1].Id;
		} else {
			acc = new Account(Name = Name);
			acc.RecordTypeId = [Select Id From RecordType Where sObjectType='Account' AND DeveloperName ='Hospital_vod' Limit 1].Id;
		}
		
		for(String fieldName : proposedValues.keySet()) {
			acc.put(fieldName, proposedValues.get(fieldName));
		}
		
		if(runDbOperation) {
			insert acc;
		}
		
		return acc;
	}
	
	private static User createSFA2User(String profileName) {
		
		for( Profile p : [ SELECT Id FROM Profile WHERE Name LIKE :profileName ]) {
			User u2 = new User(Alias = 'testUser', Email='testuser@gene.com', 
         		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         		LocaleSidKey='en_US', ProfileId = p.Id, 
         		TimeZoneSidKey='America/Los_Angeles', UserName='accounttestuser@gene.com');
			return u2;
		}
		
		return null;
	}

	private static User getSFA2User(String profileName) {
		try{
			User u = [SELECT Id FROM User WHERE Profile.Name LIKE :profileName AND isActive = true LIMIT 1];
			return u;
		} catch(Exception ex){
		}
		return null;		
	}
	
	private static void prepareEnv(String profileNamePrefix) {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Account_Trigger__c', false);
		
		/*List<GNE_SFA2_ALL_Profiles_Prefix__c> prefixCustomSettingList = [SELECT Id, GNE_SFA2_ALL_Profiles_Prefix__c FROM GNE_SFA2_ALL_Profiles_Prefix__c];
		
		if(prefixCustomSettingList.isEmpty()) {
        	GNE_SFA2_ALL_Profiles_Prefix__c prefixCustomSetting = new GNE_SFA2_ALL_Profiles_Prefix__c();
        	prefixCustomSetting.GNE_SFA2_ALL_Profiles_Prefix__c = profileNamePrefix;
        	insert prefixCustomSetting;
        } else {
        	prefixCustomSettingList[0].GNE_SFA2_ALL_Profiles_Prefix__c = profileNamePrefix;
        	update prefixCustomSettingList;
        }*/
        
        GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
        insertCanadaProfilesVRcSettings();
        insertUSProfilesVRcSettings();
        insertSBMSettings();
        insertEnvVariables();
        insertAccountTypeSettings();
	}
	
	public static void insertCanadaProfilesVRcSettings() {
		Map<String, GNE_SFA2_Acct_CA_Valid_Included_Profiles__c> canSett = GNE_SFA2_Acct_CA_Valid_Included_Profiles__c.getAll();
        if(canSett == null || canSett.isEmpty()) {
        	Set<String> canadaProfileNames = new Set<String>{
				'RCanada-SFA-MSL-Manager',
				'RCanada-SFA-Manager',
				'RCanada-SFA-MSL',
				'RCanada-SFA-TS'};
			List<GNE_SFA2_Acct_CA_Valid_Included_Profiles__c> canSettToInsert = new List<GNE_SFA2_Acct_CA_Valid_Included_Profiles__c>();
		
			for (String pName : canadaProfileNames) {
				canSettToInsert.add(new GNE_SFA2_Acct_CA_Valid_Included_Profiles__c(Name = pName, Profile_Name__c = pName));
			}
			
			insert canSettToInsert;		
        }
	}
	
	public static void insertUSProfilesVRcSettings() {
		Map<String, GNE_SFA2_Acct_Name_Valid_Excl_Prfs__c> settings = GNE_SFA2_Acct_Name_Valid_Excl_Prfs__c.getAll();
        if(settings == null || settings.isEmpty()) {
        	Map<String,String> usProfileNames = new Map<String,String>{
				'Automated Job System Administrator' => 'Automated Job System Administrator (obsolete)',
				'GNE-LWO-CUSTOPS' => 'GNE-LWO-CUSTOPS',
				'GNE-MCCO OPS' => 'GNE-MCCO OPS',
				'GNE-SYS-AutomatedJob' => 'GNE-SYS-AutomatedJob',
				'GNE-SYS-DataSupport' => 'GNE-SYS-DataSupport',
				'GNE-SYS-DataSupport-Merge' => 'GNE-SYS-DataSupport-Merge',
				'GNE-SYS-Support' => 'GNE-SYS-Support',
				'System Administrator' => 'System Administrator'
			};
				
			List<GNE_SFA2_Acct_Name_Valid_Excl_Prfs__c> usSettToInsert = new List<GNE_SFA2_Acct_Name_Valid_Excl_Prfs__c>();
			for (String pName : usProfileNames.keySet()) {
				usSettToInsert.add(new GNE_SFA2_Acct_Name_Valid_Excl_Prfs__c(Name = pName, Profile_Name__c = usProfileNames.get(pName)));
			}
			
			insert usSettToInsert;
        }
	}
	
	public static void insertSBMSettings() {
		Map<String, Speaker_Bureau_Notification_Email__c> settings = Speaker_Bureau_Notification_Email__c.getAll();
        if(settings == null || settings.isEmpty()) {
        	Map<String,String> sbmMailSettings = new Map<String,String>{
				'DateTimeFormat' => 'dd/MM/yyyy hh:mm:ss a',
				'DateTimeZone' => 'PST',
				'Email' => 'choudhs7@gene.com',
				'SenderDisplayName' => 'Salesforce'};
						
			List<Speaker_Bureau_Notification_Email__c> sbmMailSettingsToInsert = new List<Speaker_Bureau_Notification_Email__c>();
			for (String pName : sbmMailSettings.keySet()) {
				sbmMailSettingsToInsert.add(new Speaker_Bureau_Notification_Email__c(
															Name = pName, 
															Value__c = sbmMailSettings.get(pName)));
			}
			
			insert sbmMailSettingsToInsert;
        }
	}
	
	public static void insertEnvVariables() {
		List<Environment_Variables__c> vars = new List<Environment_Variables__c>();
		vars.add(new Environment_Variables__c(
			Description_Name__c = 'Account Type Mapping for RecordType value specified by Key__c field',
			Environment__c = 'all',
			Key__c = 'AccountType.account.Professional_vod',
			Type__c = 'Other',
			Value__c = 'Health Care Professional'));
			
		vars.add(new Environment_Variables__c(
			Description_Name__c = 'Account Type Mapping for RecordType value specified by Key__c field',
			Environment__c = 'all',
			Key__c = 'AccountType.account.default',
			Type__c = 'Other',
			Value__c = 'Health Care Professional'));
			
		vars.add(new Environment_Variables__c(
			Description_Name__c = 'Stewardship System Name for RecordType value specified Key__c field',
			Environment__c = 'all',
			Key__c = 'stewardshipSystem.account.Professional_vod',
			Type__c = 'Other',
			Value__c = 'ams'));
		
		insert vars;
	}
	
	public static void insertAccountTypeSettings(){
		GNE_Foun_Org_Type_Map_gne__c mapping = new GNE_Foun_Org_Type_Map_gne__c(name='HCP',Account_Record_Type_gne__c='Professional_vod', Account_Record_Type_Display_gne__c='Health Care Professional', Account_Type_gne__c='Health Care Professional',Stewardship_System_Name_gne__c='ams', Active_gne__c=true);
		insert mapping;
	}
	
	private static Id getAccountRecordTypeID(String recordTypeName) {
		Id result = null;
		return [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :recordTypeName].Id;
	}
}