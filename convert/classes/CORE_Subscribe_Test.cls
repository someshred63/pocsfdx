@isTest
public with sharing class CORE_Subscribe_Test {
	
	@testSetup 
	static void init() {
        String userExtId = 'uniqueemail@gene.com';
        CORE_Subscribe_Test_Util.initCustomSettings();
        CORE_Subscribe_Test_Util.insertDefaultRecordOwner(userExtId);
        initMappingConfig(userExtId);
	} 

    private static void initMappingConfig(String defaultRecordOwner){   
		CORE_Subscribe_Object__c subscribeObject = new CORE_Subscribe_Object__c(Name='test object', Retriever_Interface_gne__c='CORE_Subscribe_Process_Test.RecordRetriever', Validation_Interface_gne__c='CORE_Subscribe_Process_Test.SubscribeValidation', Postprocess_Interface_gne__c='CORE_Subscribe_Process_Test.SubscribePostprocess');
		insert subscribeObject;
		
		String jobName = 'Test job';
    	Core_Subscribe_Job__c subscribeJob = new Core_Subscribe_Job__c(Name= jobName, Status_gne__c='New', Subscribe_Object_gne__c = subscribeObject.Id);
    	insert subscribeJob;

		CORE_Subscribe_Mapping_Configuration__c accConfOrg = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_Party__c', Target_Object_gne__c='Account', Default_Record_Owner_gne__c=defaultRecordOwner, Type_gne__c='ORG', Order_gne__c=1, Create_New_Record_gne__c=true);
		insert accConfOrg;
		List<CORE_Subscribe_Field_Configuration_gne__c>fieldsConfig = new List<CORE_Subscribe_Field_Configuration_gne__c>();
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfOrg.id, Source_Field_gne__c = 'Org_Name_gne__c', Target_Field_gne__c='Name', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=1, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfOrg.id, Source_Field_gne__c = 'MDM_Id_gne__c', Target_Field_gne__c='AccountNumber', Overwrite_Type_gne__c =	CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=true, Order_gne__c=2, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfOrg.id, Source_Field_gne__c = 'Org_Type_json_gne__c', Target_Field_gne__c='Description', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true, Reference_CustomSetting_gne__c='CORE_Pub_Org_Typ_Map__c', Reference_Field_gne__c='Stewardship_System_Name_gne__c'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfOrg.id, Source_Field_gne__c = 'Alt_Names_json_gne__c', Target_Field_gne__c='Website', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true, Handler_gne__c='CORE_Subscribe_Field_Handler_JsonList'));
		
		
		CORE_Subscribe_Mapping_Configuration__c accConfInd = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_Party__c', Target_Object_gne__c='Account', Default_Record_Owner_gne__c=defaultRecordOwner, Type_gne__c='IND', Order_gne__c=1, Create_New_Record_gne__c=true);
		insert accConfInd;
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.id, Source_Field_gne__c = 'LastName_gne__c', Target_Field_gne__c='Name', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=1, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.id, Source_Field_gne__c = 'MDM_Id_gne__c', Target_Field_gne__c='AccountNumber', Overwrite_Type_gne__c =	CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=true, Order_gne__c=2, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.id, Source_Field_gne__c = 'FirstName_gne__c', Target_Field_gne__c='Description', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.id, Source_Field_gne__c = 'Alt_Names_json_gne__c', Target_Field_gne__c='Website', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true, Handler_gne__c='CORE_Subscribe_Field_Handler_JsonList'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.id, Source_Field_gne__c = 'Salutation_gne__c', Target_Field_gne__c='Site', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=6, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.id, Source_Field_gne__c = 'Suffix_gne__c', Target_Field_gne__c='Site', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=7, Active_gne__c=true, Handler_gne__c='CORE_Subscribe_Field_Handler_Concatenate'));
		
		insert fieldsConfig;
	}

    static testmethod void autoSubscribeScheduleTest() {
		String cronExp = '0 0 0 15 3 ? 2022';
		Test.startTest();

		String jobId = System.schedule('CORE_Auto_Sub_Test', cronExp, new CORE_Subscribe_Auto());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(cronExp, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', 
		String.valueOf(ct.NextFireTime));
		List<Core_Subscribe_Job__c> sJob = [SELECT Id FROM Core_Subscribe_Job__c WHERE Name LIKE 'SUB_AUTO%'];
		System.assertEquals(sJob.size(),0);
		Test.stopTest();

		sJob = [SELECT Id FROM Core_Subscribe_Job__c WHERE Name LIKE 'SUB_AUTO%'];
		System.assertEquals(sJob.size(), 1);
	}

	static testMethod void handlerTest(){
		CORE_Subscribe_Object__c subscribeObject = new CORE_Subscribe_Object__c(Name='test object', Retriever_Interface_gne__c='CORE_Subscribe_Process_Test.RecordRetriever', Validation_Interface_gne__c='CORE_Subscribe_Process_Test.SubscribeValidation', Postprocess_Interface_gne__c='CORE_Subscribe_Process_Test.SubscribePostprocess');
		insert subscribeObject;
		
		CORE_Subscribe_Mapping_Configuration__c opportunityMapping = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_Party__c', Target_Object_gne__c='Opportunity', Order_gne__c=1, Create_New_Record_gne__c=true);
		insert opportunityMapping;
		CORE_Subscribe_Field_Configuration_gne__c fc = new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = opportunityMapping.id, Source_Field_gne__c = 'Do_Not_Contact_gne__c', Target_Field_gne__c='	IsPrivate', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=1, Active_gne__c=true, Handler_gne__c='CORE_Subscribe_Field_Handler_ToBoolean');
		CORE_Subscribe_Field_Configuration_gne__c fc2 = new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = opportunityMapping.id, Source_Field_gne__c = 'Suffix_gne__c', Target_Field_gne__c='NextStep', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=2, Active_gne__c=true, Handler_gne__c='CORE_Subscribe_Field_Handler_Concatenate');
	
		
		CORE_Pub_Party__c party = new CORE_Pub_Party__c();
		party.Do_Not_Contact_gne__c = 'Y';
		party.Suffix_gne__c = 'suffix';
		
		Opportunity opportunity = new Opportunity();
		CORE_Subscribe_Field_Handler_ToBoolean booleanHandler = new CORE_Subscribe_Field_Handler_ToBoolean();
		booleanHandler.handle(party, opportunity, fc);
		system.assertEquals(true, booleanHandler.handle(party, opportunity, fc));
		
		
		opportunity.NextStep = 'test';
		CORE_Subscribe_Field_Handler_Concatenate concatenateHandler = new CORE_Subscribe_Field_Handler_Concatenate();
		system.assertEquals('test suffix', concatenateHandler.handle(party, opportunity, fc2));
	}
	
	static testMethod void exceptionTest(){
		CORE_Subscribe_Exception subException = new CORE_Subscribe_Exception('just for test coverage');
		try{
			throw subException;
			system.assert(false);
		}catch(Exception e){
			system.assertEquals(e.getMessage(), subException.getMessage());			
		}
	}
	
	static testMethod void daoTest(){
		Core_Subscribe_Job__c job = [Select id, name from Core_Subscribe_Job__c];
		Core_Subscribe_Job__c job2 = CORE_Subscribe_DAO.getSubscribeJob(job.Id);
		system.assertEquals(job.name, job2.name);
		
		List<CORE_Pub_Party__c>publishParties = CORE_Subscribe_DAO.getPublishParties(new Map<String, Set<String>>(), new Map<String, Set<String>>(), new Set<String>());
		system.assertEquals(0, publishParties.size());
		
		Map<String, Object> mapping =  CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Org_Sts_Typ__c', 'Value_gne__c');
		List<CORE_Pub_Org_Sts_Typ__c> orgStatuses =  CORE_Pub_Org_Sts_Typ__c.getall().values();
		system.assertEquals(orgStatuses.size(), mapping.size());
		for(CORE_Pub_Org_Sts_Typ__c sts : orgStatuses){
			system.assertEquals(sts.Value_gne__c, mapping.get(sts.name));
		}
		
		mapping =  CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Gndr_Typ__c', 'Value_gne__c');
		List<CORE_Pub_Gndr_Typ__c> genders =  CORE_Pub_Gndr_Typ__c.getall().values();
		system.assertEquals(orgStatuses.size(), mapping.size());
		for(CORE_Pub_Gndr_Typ__c gender : genders){
			system.assertEquals(gender.Value_gne__c, mapping.get(gender.name));
		}
		
		mapping =  CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Edu_Degr_Typ__c', 'Description_gne__c');
		for(CORE_Pub_Edu_Degr_Typ__c degree : CORE_Pub_Edu_Degr_Typ__c.getall().values()){
			system.assertEquals(degree.Description_gne__c, mapping.get(degree.Name));
		}
		
		mapping =  CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Hlth_Pln_Typ__c', 'Description_gne__c');
		for(CORE_Pub_Hlth_Pln_Typ__c hltPlan : CORE_Pub_Hlth_Pln_Typ__c.getall().values()){
			system.assertEquals(hltPlan.Description_gne__c, mapping.get(hltPlan.Name));
		}
		
		mapping =  CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Indv_Role_Typ__c', 'Description_gne__c');
		for(CORE_Pub_Indv_Role_Typ__c indRole : CORE_Pub_Indv_Role_Typ__c.getall().values()){
			system.assertEquals(indRole.Description_gne__c, mapping.get(indRole.Name));
		}
		
		mapping =  CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Loc_Use_Typ__c', 'Value_gne__c');
		for(CORE_Pub_Loc_Use_Typ__c locUsage : CORE_Pub_Loc_Use_Typ__c.getall().values()){
			system.assertEquals(locUsage.Value_gne__c, mapping.get(locUsage.Name));
		}
		
		mapping =  CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Pln_Prodt_Model_Typ__c', 'Value_gne__c');
		for(CORE_Pub_Pln_Prodt_Model_Typ__c plnProdtModelType : CORE_Pub_Pln_Prodt_Model_Typ__c.getall().values()){
			system.assertEquals(plnProdtModelType.Value_gne__c, mapping.get(plnProdtModelType.Name));
		}
		
		mapping =  CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Pln_Prodt_Typ__c', 'Value_gne__c');
		for(CORE_Pub_Pln_Prodt_Typ__c plnProdtType : CORE_Pub_Pln_Prodt_Typ__c.getall().values()){
			system.assertEquals(plnProdtType.Value_gne__c, mapping.get(plnProdtType.Name));
		}
	}
	
	static testMethod void prepareJobTest(){
		String jobName = 'testJob';
		Id jobId = CORE_Subscribe_Util.prepareSubscribeJobId(jobName);
		Core_Subscribe_Job__c job = CORE_Subscribe_DAO.getSubscribeJob(jobId);
		system.assert(job.Name.startsWith(jobName));
		system.assertEquals(jobId, job.Id);
	}
	
	static testMethod void utilMethodsTest(){
		Datetime etlUpsertDate = Datetime.now();
		
		CORE_Pub_Party__c party = new CORE_Pub_Party__c(Party_Id_gne__c='1612170', MDM_Id_gne__c='2308068', Status_gne__c='A', FirstName_gne__c='MICHELLE', MiddleName_gne__c='LAM CHING-WEN', LastName_gne__c='CHU', Salutation_gne__c='Dr.', Suffix_gne__c='V', Gender_gne__c='F', PDRP_Opt_Out_gne__c='Y');
		party.Mdm_Updt_Date_gne__c = DateTime.newInstance(2015, 7, 12, 15, 20, 35);
		party.Birthdate_gne__c = Date.newInstance(1982, 1, 1);
		party.PDRP_Opt_Out_Date_gne__c = Date.newInstance(2014, 1, 14);
		party.Type_gne__c='IND';
		party.Prof_Type_json_gne__c = '[{"Code" : "MD"}, {"Code" : "CLNCL"}, {"Code" : "PSCR"}]';
		party.Education_json_gne__c = '[{"Code" : "MD"}, {"Code" : "LVT"}]';
		party.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6505231432"}, {"Code" : "EML", "Value" : "test@test.com"}, {"Code" : "PGR",  "Value" : "5231234321"}]';
		party.Credentials_json_gne__c = '[{"Code" : "MD"}, {"Code" : "MBA"}, {"Code" : "MPT"}]';
		party.Specialties_json_gne__c = '[{"Code" : "A"}, {"Code" : "DEN"}, {"Code" : "ACA"}]';
		party.Alt_Names_json_gne__c = '[{"Value" : "MICHELLE CHING-WEN LAM"}, {"Value" : "MICHELLE CHING-W CHU"}, {"Value" : "MICHELLE CHING-W LAM"}, {"Value" : "MICHELLE L CHU"} ]';
		party.Do_Not_Contact_gne__c = 'Y';
		party.Last_Pub_Upsert_Date_gne__c = etlUpsertDate;
		
		CORE_Pub_Party__c party2 = new CORE_Pub_Party__c(Party_Id_gne__c='1682933', MDM_Id_gne__c='2439927', Status_gne__c='I', Org_Name_gne__c='POTOMAC CENTER FOR MEDICAL EDUCATION');
		party2.Mdm_Updt_Date_gne__c = DateTime.newInstance(2015, 7, 12, 15, 20, 35);
		party2.Type_gne__c='ORG';
		party2.Org_Type_json_gne__c = '[{"Code" : "MISC"}]';
		party2.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6503231432",  "Extension" : "x123"}, {"Code" : "URL", "Value" : "www.google.com"}]';
		party2.Do_Not_Contact_gne__c = 'N';
		party2.Alt_Names_json_gne__c = '[{"Value" : "POTOMAC CENTER"}]';
		party.Last_Pub_Upsert_Date_gne__c = etlUpsertDate;
		
		insert new List<CORE_Pub_Party__c> {party, party2};  
		Database.QueryLocator queryLocator = CORE_Subscribe_Util.fetchPartiesByTimestamp(etlUpsertDate.addDays(-10), etlUpsertDate.addDays(10));
		Database.QueryLocatorIterator it =  queryLocator.iterator();
		Integer partyCount = 0;
		while (it.hasNext()) {
		    CORE_Pub_Party__c p = (CORE_Pub_Party__c)it.next();
		    partyCount++;
		}
		system.assertEquals(2, partyCount);
	}
}