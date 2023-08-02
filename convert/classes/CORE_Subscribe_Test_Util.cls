public with sharing class CORE_Subscribe_Test_Util {
	
	public static User insertDefaultRecordOwner(String externalId){
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		String uniqueUserIdent = 'uniqueemail@gene.com';
       	User user = new User(Alias = 'uniquea', Email= externalId,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@gene.com');
        insert user;
        return user;
	}
	
	public static void initMappingConfig(String defaultRecordOwner){   
		//person account
		CORE_Subscribe_Object__c subscribeObject = new CORE_Subscribe_Object__c(Name='SFA_US', Retriever_Interface_gne__c='GNE_SFA2_Subscribe_Helper', Validation_Interface_gne__c='GNE_SFA2_Subscribe_Helper', Postprocess_Interface_gne__c='GNE_SFA2_Subscribe_Postprocess');
		insert subscribeObject;
		
		String jobName = 'Test job';
    	Core_Subscribe_Job__c subscribeJob = new Core_Subscribe_Job__c(Name= jobName, Status_gne__c='New', Subscribe_Object_gne__c = subscribeObject.Id);
    	insert subscribeJob;

		CORE_Subscribe_Mapping_Configuration__c personAccConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_Party__c', Target_Object_gne__c='Account', Default_Record_Owner_gne__c=defaultRecordOwner, Type_gne__c='IND', Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler', Order_gne__c=1, Create_New_Record_gne__c=true);
		insert personAccConf;
		List<CORE_Subscribe_Field_Configuration_gne__c>fieldsConfig = new List<CORE_Subscribe_Field_Configuration_gne__c>();
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'MDM_Id_gne__c', Target_Field_gne__c='MDMID_gne__c', Overwrite_Type_gne__c =	CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=true, Order_gne__c=1, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Mdm_Updt_Date_gne__c', Target_Field_gne__c='MDM_Update_Date_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=2, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Salutation_gne__c', Target_Field_gne__c='Salutation', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Suffix_gne__c', Target_Field_gne__c='Suffix_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'FirstName_gne__c', Target_Field_gne__c='Firstname', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=5, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'MiddleName_gne__c', Target_Field_gne__c='Middle_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=6, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'LastName_gne__c', Target_Field_gne__c='Lastname', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=7, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Gender_gne__c', Target_Field_gne__c='Gender_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=8, Active_gne__c=true, Reference_CustomSetting_gne__c='CORE_Pub_Gndr_Typ__c', Reference_Field_gne__c='Value_gne__c'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Birthdate_gne__c', Target_Field_gne__c='Date_of_Birth_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=9, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Credentials_json_gne__c', Target_Field_gne__c='Credentials_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=10, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler', Reference_CustomSetting_gne__c='CORE_Pub_Prof_Typ__c', Reference_Field_gne__c='Value_gne__c'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Specialties_json_gne__c', Target_Field_gne__c='Specialties_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=11, Active_gne__c=true, Reference_CustomSetting_gne__c='CORE_Pub_Spcl_Typ__c', Reference_Field_gne__c='Value_gne__c'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'PDRP_Opt_Out_Date_gne__c', Target_Field_gne__c='PDRP_Opt_Out_Date_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=12, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'PDRP_Opt_Out_gne__c', Target_Field_gne__c='PDRP_Opt_Out_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=13, Active_gne__c=true,  Handler_gne__c='CORE_Subscribe_Field_Handler_ToBoolean'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Prof_Type_json_gne__c', Target_Field_gne__c='Professional_Type_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=14, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Prof_Type_json_gne__c', Target_Field_gne__c='RecordTypeId', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=14, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Prof_Type_json_gne__c', Target_Field_gne__c='Stewardship_System_Name_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=14, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Status_gne__c', Target_Field_gne__c='Status_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=15, Active_gne__c=true, Reference_CustomSetting_gne__c='CORE_Pub_Ind_Sts_Typ__c', Reference_Field_gne__c='Value_gne__c'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Status_gne__c', Target_Field_gne__c='MDMID_Status_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=16, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler'));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Do_Not_Contact_gne__c', Target_Field_gne__c='DO_NOT_CONTACT_gne__pc', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=17, Active_gne__c=true, Handler_gne__c='CORE_Subscribe_Field_Handler_ToBoolean'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Alt_Names_json_gne__c', Target_Field_gne__c='Alternate_Name_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=18, Active_gne__c=true, Handler_gne__c='CORE_Subscribe_Field_Handler_JsonList'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = personAccConf.id, Source_Field_gne__c = 'Spend_Rest_json_gne__c', Target_Field_gne__c='Spend_Rest_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=19, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler'));
		//organization account
		CORE_Subscribe_Mapping_Configuration__c orgAccConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_Party__c', Target_Object_gne__c='Account', Default_Record_Owner_gne__c=defaultRecordOwner, Type_gne__c='ORG', Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler', Order_gne__c=2, Create_New_Record_gne__c=true);
		insert orgAccConf;
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = orgAccConf.id, Source_Field_gne__c = 'Org_Name_gne__c', Target_Field_gne__c='Name', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=2, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = orgAccConf.id, Source_Field_gne__c = 'MDM_Id_gne__c', Target_Field_gne__c='MDMID_gne__c', Overwrite_Type_gne__c =	CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=true, Order_gne__c=1, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = orgAccConf.id, Source_Field_gne__c = 'Mdm_Updt_Date_gne__c', Target_Field_gne__c='MDM_Update_Date_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=2, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = orgAccConf.id, Source_Field_gne__c = 'Status_gne__c', Target_Field_gne__c='Status_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=15, Active_gne__c=true, Reference_CustomSetting_gne__c='CORE_Pub_Org_Sts_Typ__c', Reference_Field_gne__c='Value_gne__c'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = orgAccConf.id, Source_Field_gne__c = 'Status_gne__c', Target_Field_gne__c='MDMID_Status_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=16, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = orgAccConf.id, Source_Field_gne__c = 'Org_Type_json_gne__c', Target_Field_gne__c='Stewardship_System_Name_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=16, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = orgAccConf.id, Source_Field_gne__c = 'Org_Type_json_gne__c', Target_Field_gne__c='Account_Type_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=16, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = orgAccConf.id, Source_Field_gne__c = 'Org_Type_json_gne__c', Target_Field_gne__c='RecordTypeId', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=17, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Account_Handler.FieldHandler'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = orgAccConf.id, Source_Field_gne__c = 'Alt_Names_json_gne__c', Target_Field_gne__c='Alternate_Name_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=18, Active_gne__c=true, Handler_gne__c='CORE_Subscribe_Field_Handler_JsonList'));
		
		//address
		CORE_Subscribe_Mapping_Configuration__c addressConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_Location__c', Target_Object_gne__c='Address_vod__c', Order_gne__c=3, Create_New_Record_gne__c=true, Handler_gne__c='GNE_SFA2_Subscribe_Address_Handler');
		insert addressConf;
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Party_Id_ref_gne__c', Target_Field_gne__c='Account_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=1, Active_gne__c=true, Parent_Object_gne__c='Account', Parent_External_Field_Name_gne__c='MDMID_gne__c'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'MDM_Id_gne__c', Target_Field_gne__c='MDM_Address_ID_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=true, Order_gne__c=2, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'MDM_Status_gne__c', Target_Field_gne__c='MDM_Status_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'MDM_Status_gne__c', Target_Field_gne__c='Active_Flag_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true,  Handler_gne__c='CORE_Subscribe_Field_Handler_ToBoolean'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Street_gne__c', Target_Field_gne__c='Name', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=5, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Default_gne__c', Target_Field_gne__c='Primary_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=6, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'City_gne__c', Target_Field_gne__c='City_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=7, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'State_gne__c', Target_Field_gne__c='State_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=8, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Zip_4_gne__c', Target_Field_gne__c='Zip_4_vod__c	', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=9, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Zip_gne__c', Target_Field_gne__c='Zip_vod__c	', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=10, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Latitude_gne__c', Target_Field_gne__c='Latitude_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=11, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Longitude_gne__c', Target_Field_gne__c='Longitude_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=12, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Country_gne__c', Target_Field_gne__c='Country_gen__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=13, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Bldg_Desc_gne__c', Target_Field_gne__c='Address_Line_3_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=14, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Bldg_Fl_Desc_gne__c', Target_Field_gne__c='Address_Line_3_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=15, Active_gne__c=true, Handler_gne__c='CORE_Subscribe_Field_Handler_Concatenate'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressConf.id, Source_Field_gne__c = 'Default_gne__c', Target_Field_gne__c='Inactive_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=16, Active_gne__c=true, Handler_gne__c='GNE_SFA2_Field_Handler_AddressInactive'));
		
		CORE_Subscribe_Mapping_Configuration__c licenseConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_License__c', Target_Object_gne__c='Address_vod__c', Order_gne__c=4, Create_New_Record_gne__c=false);
		insert licenseConf;
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf.id, Source_Field_gne__c = 'Designation_gne__c', Target_Field_gne__c='Designation_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=1, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf.id, Source_Field_gne__c = 'Adj_Lic_Exp_Date_gne__c', Target_Field_gne__c='License_Expiration_Date_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=2, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf.id, Source_Field_gne__c = 'Exp_Date_gne__c', Target_Field_gne__c='License_Expiration_Date_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf.id, Source_Field_gne__c = 'License_Number_gne__c', Target_Field_gne__c='License_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf.id, Source_Field_gne__c = 'License_Status_gne__c', Target_Field_gne__c='License_Status_vod__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=5, Active_gne__c=true));
		
		CORE_Subscribe_Mapping_Configuration__c licenseConf2 = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_License__c', Target_Object_gne__c='Prescriber_License_gne__c', Order_gne__c=5, Create_New_Record_gne__c=true, Is_Full_Synchronization_gne__c=true);
		insert licenseConf2;
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf2.id, Source_Field_gne__c = 'License_Number_gne__c', Target_Field_gne__c='Name', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=1, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf2.id, Source_Field_gne__c = 'Adj_Lic_Exp_Date_gne__c', Target_Field_gne__c='License_Expiration_Date_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=2, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf2.id, Source_Field_gne__c = 'Exp_Date_gne__c', Target_Field_gne__c='License_Expiration_Date_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true));
		//fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf2.id, Source_Field_gne__c = 'Designation_gne__c', Target_Field_gne__c='Designation_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf2.id, Source_Field_gne__c = 'Smpl_Ovrl_Elig_Flag_gne__c', Target_Field_gne__c='License_Status_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=5, Active_gne__c=true,  Handler_gne__c='GNE_SFA2_Field_Handler_Lic_Status'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf2.id, Source_Field_gne__c = 'License_State_gne__c', Target_Field_gne__c='License_State_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=6, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf2.id, Source_Field_gne__c = 'Party_Id_ref_gne__c', Target_Field_gne__c='Account_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=1, Active_gne__c=true, Parent_Object_gne__c='Account', Parent_External_Field_Name_gne__c='MDMID_gne__c'));
		
		CORE_Subscribe_Mapping_Configuration__c externalIdConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_External_Id__c', Target_Object_gne__c='Account_External_Id_gne__c', Type_gne__c='PTY', Order_gne__c=6, Create_New_Record_gne__c=true);
		insert externalIdConf;
		
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = externalIdConf.id, Source_Field_gne__c = 'Party_Id_ref_gne__c', Target_Field_gne__c='Account_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=1, Active_gne__c=true, Parent_Object_gne__c='Account', Parent_External_Field_Name_gne__c='MDMID_gne__c'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = externalIdConf.id, Source_Field_gne__c = 'Ctrb_Src_gne__c', Target_Field_gne__c='Third_Party_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = externalIdConf.id, Source_Field_gne__c = 'Ctrb_Src_Id_gne__c', Target_Field_gne__c='Third_Party_Id_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true));
		
		CORE_Subscribe_Mapping_Configuration__c addressExternalIdConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_External_Id__c', Target_Object_gne__c='Address_External_Id_gne__c', Type_gne__c='PTYLOC', Order_gne__c=7, Create_New_Record_gne__c=true);
		insert addressExternalIdConf;
		
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressExternalIdConf.id, Source_Field_gne__c = 'Party_Location_Id_ref_gne__c', Target_Field_gne__c='Address_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=2, Active_gne__c=true, Parent_Object_gne__c='Address_vod__c', Parent_External_Field_Name_gne__c='MDM_Address_ID_gne__c'));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressExternalIdConf.id, Source_Field_gne__c = 'Ctrb_Src_gne__c', Target_Field_gne__c='Third_Party_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true));
		fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = addressExternalIdConf.id, Source_Field_gne__c = 'Ctrb_Src_Id_gne__c', Target_Field_gne__c='Third_Party_Id_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true));
		
		insert fieldsConfig;
	}
	
	 public static void initCustomSettings(){
    	List<CORE_Found_Misc_Config__c> misc = new List<CORE_Found_Misc_Config__c>();
    	misc.add(new CORE_Found_Misc_Config__c(Name='DefaultIndividualRoleCode', Configuration_Value_gne__c='HCPNPSCR'));
    	misc.add(new CORE_Found_Misc_Config__c(Name='LoggingLevel', Configuration_Value_gne__c='DEBUG'));
    	misc.add(new CORE_Found_Misc_Config__c(Name='CreateAccountXREFList', Configuration_Value_gne__c='BOT,TSG,PW,CC'));
    	misc.add(new CORE_Found_Misc_Config__c(Name='CreateAccountExternalXREFList', Configuration_Value_gne__c='BOT,PW,TSG,CDNT,CREATIVE,RVWT,BISHOPMC,GNEEMGT,CC,[IND]CRO,[IND]SAPBW,MEDFORCE,HCOS,DDD_HCOS'));
    	misc.add(new CORE_Found_Misc_Config__c(Name='CreateAddressXREFList', Configuration_Value_gne__c='BOT'));
    	misc.add(new CORE_Found_Misc_Config__c(Name='CreateAddressExternalXREFList', Configuration_Value_gne__c='PW,TSG,CC,[IND]CRO,[IND]SAPBW,MEDFORCE'));
    	misc.add(new CORE_Found_Misc_Config__c(Name='EnableUpdateOnMDMId', Configuration_Value_gne__c='TRUE'));
    	misc.add(new CORE_Found_Misc_Config__c(Name='ValidSourcesXREFList',	Configuration_Value_gne__c='BOT,TSG,PW,SFDC,AMS,MDM,CDNT,CREATIVE,RVWT,BISHOPMC,GNEEMGT,CC,CRO,SAPBW,NPI,MEDFORCE,HCOS'));
    	misc.add(new CORE_Found_Misc_Config__c(Name = 'PublishLastSynchDateTime', Configuration_Value_gne__c = String.valueOfGmt(Datetime.now().addDays(-1))));
    	misc.add(new CORE_Found_Misc_Config__c(Name = 'AutoSubscribeLastSynchDateTime', Configuration_Value_gne__c = null));
    	misc.add(new CORE_Found_Misc_Config__c(Name = 'SubscribeNotifyEmail', Configuration_Value_gne__c = 'test@test.com'));
    	insert misc;
    	
		List<CORE_Pub_Prof_Typ__c>credentials = new List<CORE_Pub_Prof_Typ__c>();
		credentials.add(new CORE_Pub_Prof_Typ__c(Name='MD', Description_gne__c='DOCTOR OF MEDICINE', Value_gne__c='MD'));
		credentials.add(new CORE_Pub_Prof_Typ__c(Name='MBA', Description_gne__c='MASTERS OF BUSINESS ADMINISTRATION', Value_gne__c='MBA'));
		credentials.add(new CORE_Pub_Prof_Typ__c(Name='MPT', Description_gne__c='MASTER OF PHYSICAL THERAPY', Value_gne__c='MPT'));
		credentials.add(new CORE_Pub_Prof_Typ__c(Name='AAPC', Description_gne__c='ADULT ADVANCED PRACTICAL NURSE', Value_gne__c='AAPC'));
		credentials.add(new CORE_Pub_Prof_Typ__c(Name='AAS', Description_gne__c='ASSOCIATE OF APPLIED SCIENCE', Value_gne__c='AAS'));
		credentials.add(new CORE_Pub_Prof_Typ__c(Name='AC', Description_gne__c='ACUPUNCTURIST', Value_gne__c='AC'));
		credentials.add(new CORE_Pub_Prof_Typ__c(Name='ACDT', Description_gne__c='ACUPUNCTURE DETOXIFICATION TECHNICIAN', Value_gne__c='ACDT'));
		credentials.add(new CORE_Pub_Prof_Typ__c(Name='ACHRN', Description_gne__c='ADVANCED CERTIFIED HYPERBARIC REGISTERED NURSE', Value_gne__c='ACHRN'));		
		insert credentials;
		
		List<CORE_Pub_Spcl_Typ__c>spclTypes = new List<CORE_Pub_Spcl_Typ__c>();
		spclTypes.add(new CORE_Pub_Spcl_Typ__c(Name='A', Description_gne__c='ALLERGY', Value_gne__c='ALLERGY'));
		spclTypes.add(new CORE_Pub_Spcl_Typ__c(Name='AC', Description_gne__c='ACUTE CARE', Value_gne__c='ACUTE CARE'));
		spclTypes.add(new CORE_Pub_Spcl_Typ__c(Name='ACA', Description_gne__c='ADULT CARDIOTHORACIC ANESTHES(RESIDENTS)', Value_gne__c='ADULT CARDIOTHORACIC ANESTHES(RESIDENTS)'));
		spclTypes.add(new CORE_Pub_Spcl_Typ__c(Name='ACC', Description_gne__c='ACC', Value_gne__c='ACC'));
		spclTypes.add(new CORE_Pub_Spcl_Typ__c(Name='ACP', Description_gne__c='ACUTE CARE PEDIATRICS', Value_gne__c='ACUTE CARE PEDIATRICS'));
		spclTypes.add(new CORE_Pub_Spcl_Typ__c(Name='ACU', Description_gne__c='ACUPUNCTURE', Value_gne__c='ACUPUNCTURE'));
		spclTypes.add(new CORE_Pub_Spcl_Typ__c(Name='DEN', Description_gne__c='DENTISTRY', Value_gne__c='DENTISTRY'));
		insert spclTypes;
		
		List<CORE_Pub_Org_Typ_Map__c>orgTypes = new List<CORE_Pub_Org_Typ_Map__c>();
		orgTypes.add(new CORE_Pub_Org_Typ_Map__c(Name='MISC', Active_gne__c=true, Account_Record_Type_gne__c='Practice_vod', Account_Record_Type_Display_gne__c='Miscellaneous', Account_Type_gne__c='Miscellaneous', Stewardship_System_Name_gne__c='ams'));
		insert orgTypes;
		
		List<CORE_Pub_Gndr_Typ__c>genderTypes = new List<CORE_Pub_Gndr_Typ__c>();
		genderTypes.add(new CORE_Pub_Gndr_Typ__c(Name='M', Description_gne__c='MALE', Value_gne__c='M'));
		genderTypes.add(new CORE_Pub_Gndr_Typ__c(Name='F', Description_gne__c='FEMALE', Value_gne__c='F'));
		genderTypes.add(new CORE_Pub_Gndr_Typ__c(Name='U', Description_gne__c='UNKNOWN'));
		insert genderTypes;
		
		List<CORE_Pub_Indv_Role_To_Prof_Type_Map__c>profTypes = new List<CORE_Pub_Indv_Role_To_Prof_Type_Map__c>();
		profTypes.add(new CORE_Pub_Indv_Role_To_Prof_Type_Map__c(Name='MD', Professional_Type_gne__c='Medical Doctor', Role_Rank_gne__c=1));
		profTypes.add(new CORE_Pub_Indv_Role_To_Prof_Type_Map__c(Name='CLNCL', Professional_Type_gne__c='Health Care Professional - Non-Prescribing', Role_Rank_gne__c=15));
		profTypes.add(new CORE_Pub_Indv_Role_To_Prof_Type_Map__c(Name='PSCR', Professional_Type_gne__c='Health Care Professional - Prescribing', Role_Rank_gne__c=5));
		profTypes.add(new CORE_Pub_Indv_Role_To_Prof_Type_Map__c(Name='PATIENTAMB', Professional_Type_gne__c='Patient Ambassador', Role_Rank_gne__c=6));
		insert profTypes;
		
		List<CORE_Pub_Ind_Sts_Typ__c>indStatusType = new List<CORE_Pub_Ind_Sts_Typ__c>();
		indStatusType.add(new CORE_Pub_Ind_Sts_Typ__c(Name='A', Description_gne__c='ACTIVE', Value_gne__c='Active'));
		indStatusType.add(new CORE_Pub_Ind_Sts_Typ__c(Name='D', Description_gne__c='DEAD', Value_gne__c='Dead'));
		indStatusType.add(new CORE_Pub_Ind_Sts_Typ__c(Name='I', Description_gne__c='INDETERMINATE', Value_gne__c='Indeterminate'));
		indStatusType.add(new CORE_Pub_Ind_Sts_Typ__c(Name='R', Description_gne__c='RETIRED', Value_gne__c='Retired'));
		insert indStatusType;
		
		List<CORE_Pub_Org_Sts_Typ__c>orgStatusType = new List<CORE_Pub_Org_Sts_Typ__c>();
		orgStatusType.add(new CORE_Pub_Org_Sts_Typ__c(Name='A', Description_gne__c='ACTIVE', Value_gne__c='Active'));
		orgStatusType.add(new CORE_Pub_Org_Sts_Typ__c(Name='I', Description_gne__c='INACTIVE', Value_gne__c='Inactive'));
		orgStatusType.add(new CORE_Pub_Org_Sts_Typ__c(Name='U', Description_gne__c='UNKNOWN', Value_gne__c='Unknown'));
		insert orgStatusType;
		
		List<CORE_Comm_Chnl_Typ__c>commChannels = new List<CORE_Comm_Chnl_Typ__c>();
		commChannels.add(new CORE_Comm_Chnl_Typ__c(Name='BUS_PHN', Description_gne__c='BUSINESS PHONE', Value_gne__c='Account.Phone'));
		commChannels.add(new CORE_Comm_Chnl_Typ__c(Name='FAX', Description_gne__c='FAX', Value_gne__c='Account.Fax'));
		commChannels.add(new CORE_Comm_Chnl_Typ__c(Name='PHN', Description_gne__c='PHONE'));
		commChannels.add(new CORE_Comm_Chnl_Typ__c(Name='PHN_EXT', Description_gne__c='PHONE EXTENSION', Value_gne__c='Contact.Phone'));
		commChannels.add(new CORE_Comm_Chnl_Typ__c(Name='URL', Description_gne__c='URL', Value_gne__c='Account.Website'));
		insert commChannels;
		
		List<CORE_Pub_Edu_Degr_Typ__c>eduDegrees = new List<CORE_Pub_Edu_Degr_Typ__c>();
		eduDegrees.add(new CORE_Pub_Edu_Degr_Typ__c(Name='AA', Description_gne__c='ANESTHESIOLOGY ASSISTANT'));
		eduDegrees.add(new CORE_Pub_Edu_Degr_Typ__c(Name='AACNP', Description_gne__c='ADULT ACUTE CARE NURSE PRACTITIONER'));
		eduDegrees.add(new CORE_Pub_Edu_Degr_Typ__c(Name='AAPC', Description_gne__c='ADULT ADVANCED PRACTICAL NURSE'));
		eduDegrees.add(new CORE_Pub_Edu_Degr_Typ__c(Name='AC', Description_gne__c='ACUPUNCTURIST'));
		eduDegrees.add(new CORE_Pub_Edu_Degr_Typ__c(Name='ACDT', Description_gne__c='ACUPUNCTURE DETOXIFICATION TECHNICIAN'));
		insert eduDegrees;
		
		List<CORE_Pub_Hlth_Pln_Typ__c>hlthPlans = new List<CORE_Pub_Hlth_Pln_Typ__c>();
		hlthPlans.add(new CORE_Pub_Hlth_Pln_Typ__c(Name='ABC', Description_gne__c='ABC'));
		hlthPlans.add(new CORE_Pub_Hlth_Pln_Typ__c(Name='CASH', Description_gne__c='CASH PLAN'));
		hlthPlans.add(new CORE_Pub_Hlth_Pln_Typ__c(Name='CENTENLCRE', Description_gne__c='CENTENNIAL CARE'));
		hlthPlans.add(new CORE_Pub_Hlth_Pln_Typ__c(Name='CHRTY', Description_gne__c='CHARITY'));
		hlthPlans.add(new CORE_Pub_Hlth_Pln_Typ__c(Name='CMCL', Description_gne__c='COMMERCIAL'));
		insert hlthPlans;
		
		List<CORE_Pub_Indv_Role_Typ__c>roleTypes = new List<CORE_Pub_Indv_Role_Typ__c>();
		roleTypes.add(new CORE_Pub_Indv_Role_Typ__c(Name='ACAD', Description_gne__c='ACADEMIC - PARENT ROLE OF FACULTY MEMBER AND RELATED ROLES'));
		roleTypes.add(new CORE_Pub_Indv_Role_Typ__c(Name='ACAD_INST', Description_gne__c='ACADEMIC INSTITUTION'));
		insert roleTypes;
		
		List<CORE_Pub_Loc_Use_Typ__c>locUsages = new List<CORE_Pub_Loc_Use_Typ__c>();
		locUsages.add(new CORE_Pub_Loc_Use_Typ__c(Name='ADM', Description_gne__c='ADMINISTRATION'));
		locUsages.add(new CORE_Pub_Loc_Use_Typ__c(Name='AMS_GOLD', Description_gne__c='GOLD RECORD', Value_gne__c='Address.GOLD_RECORD_gne__c = TRUE;Address.AMS_gold_record_gne__c = TRUE'));
		insert locUsages;
		
		List<CORE_Pub_Pln_Prodt_Model_Typ__c>plnProdtModelTypes = new List<CORE_Pub_Pln_Prodt_Model_Typ__c>();
		plnProdtModelTypes.add(new CORE_Pub_Pln_Prodt_Model_Typ__c(Name='HMO', Description_gne__c='HEALTH MAINTENANCE ORGANIZATION'));
		plnProdtModelTypes.add(new CORE_Pub_Pln_Prodt_Model_Typ__c(Name='NOT_HMO_PPO', Description_gne__c='NOT HMO OR PPO'));
		insert plnProdtModelTypes;
		
		List<CORE_Pub_Pln_Prodt_Typ__c>plnProdtTypes = new List<CORE_Pub_Pln_Prodt_Typ__c>();
		plnProdtTypes.add(new CORE_Pub_Pln_Prodt_Typ__c(Name='ACCS_PLS', Description_gne__c='ACCESS PLUS'));
		plnProdtTypes.add(new CORE_Pub_Pln_Prodt_Typ__c(Name='ADVBNFTADM', Description_gne__c='ADVANTEK BENEFIT ADM'));
		insert plnProdtTypes;
    }
	
	public class JsonList{
    	public String code;
    }
    
    public static String getListValues(String jsonString, Map<String, Object>codeMapping){
    	if(jsonString == null){
    		return null;
    	}
    	String result = '';
    	List<JsonList>values = (List<JsonList>)JSON.deserialize(jsonString, List<JsonList>.class);
    	for(JsonList value : values){
    		result += codeMapping.get(value.code)+';';
    	}
    	result = result.substring(0, result.length() -1);
    	return result;
    }

    public static String getListValuesForSpendRest(String jsonString){
    	if(jsonString == null){
    		return null;
    	}
    	String result = '';
    	List<JsonList>values = (List<JsonList>)JSON.deserialize(jsonString, List<JsonList>.class);
    	for(JsonList value : values){
    		result += value.code +';';
    	}
    	result = result.substring(0, result.length() -1);
    	return result;
    }
    
    public static Map<Id, CORE_Pub_Location__c>getPublishPartyLocations(Set<String>partyIds){
		return new Map<Id, CORE_Pub_Location__c>([SELECT Id, Bldg_Desc_gne__c, Bldg_Fl_Desc_gne__c, City_gne__c, Comm_Chan_json_gne__c, Country_gne__c, Default_gne__c, 
    													Latitude_gne__c, Loc_Use_json_gne__c, Longitude_gne__c, MDM_Id_gne__c, MDM_Status_gne__c, Party_Id_gne__c, Party_Id_ref_gne__c, 
    													Party_Location_Id_gne__c, State_gne__c, Street_gne__c, Unit_Type_gne__c, Unit_Value_gne__c, Zip_4_gne__c, Zip_gne__c 
    											FROM CORE_Pub_Location__c WHERE Party_Id_ref_gne__c IN :partyIds]);
    }
    
    public static Map<Id, CORE_Pub_External_Id__c>getPublishExternalIds(Set<String>partyIds){
		return new Map<Id, CORE_Pub_External_Id__c>([SELECT Id, Cnncl_Enty_Type_gne__c, Ctrb_Src_gne__c, Ctrb_Src_Id_gne__c, Party_Id_gne__c, Party_Location_Id_gne__c, Party_Location_Id_ref_gne__c, 
    													Party_Id_ref_gne__c 
    											FROM CORE_Pub_External_Id__c WHERE Party_Id_ref_gne__c IN :partyIds]);
	}
	
	public static Map<String, CORE_Pub_Party__c> getParties(){
		return new Map<String, CORE_Pub_Party__c>([SELECT Id, Alt_Names_json_gne__c, Birthdate_gne__c, Comm_Channel_json_gne__c, Credentials_json_gne__c, Do_Not_Contact_gne__c, 
    												Education_json_gne__c, FirstName_gne__c, Gender_gne__c, LastName_gne__c, Mdm_Id_gne__c, Mdm_Updt_Date_gne__c, 
    												MiddleName_gne__c, Org_Name_gne__c, Org_Type_json_gne__c, Party_Id_gne__c, PDRP_Opt_Out_Date_gne__c, PDRP_Opt_Out_gne__c,
    												Prof_Type_json_gne__c,	Salutation_gne__c, Specialties_json_gne__c, Spend_Rest_json_gne__c, Status_gne__c, Suffix_gne__c, Type_gne__c,
    												Last_Sub_Exec_gne__c, Sub_Exec_Status_gne__c, Comments_gne__c 
    										FROM CORE_Pub_Party__c]);
	}
	
    
}