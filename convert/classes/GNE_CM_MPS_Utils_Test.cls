/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-12-29
*  Description: 
*  Test for GNE_CM_MPS_Utils 
*  Modification History
*  Date        Name        Description
*                
*************************************************************/

@isTest
private class GNE_CM_MPS_Utils_Test {

    static testMethod void testGetAccountId() 
    {
    	Map<String, RecordType> recordTypes = GlobalUtils.getRecordTypes('Account', new List<String>{'Professional_vod'});
        GNE_CM_MPS_UnitTestDataCreator.MpsUserWithAccount userWithAcct = GNE_CM_MPS_UnitTestDataCreator.getMPSUser('incognit', recordTypes);
    	System.runAs(userWithAcct.mpsUser)
		{
			System.assertEquals(userWithAcct.mpsAcct.Id, GNE_CM_MPS_Utils.getAccountId());
		}
    }
    
    static testMethod void testGetMPSRegistration()
    {
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', true);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Account_Trigger', true);
    	//create test data
    	Map<String, RecordType> recordTypes = GlobalUtils.getRecordTypes('Account', new List<String>{'Professional_vod'});
    	GNE_CM_MPS_UnitTestDataCreator.MpsUserWithAccount userWithAcct = GNE_CM_MPS_UnitTestDataCreator.getMPSUser('incognit', recordTypes);
    	
    	GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure struct;
		system.runAs(new User(id = userInfo.getUserId()))
		{	
    		struct  = new GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure(3, 2, 1, recordTypes, userWithAcct);        
		}	
		System.runAs(userWithAcct.mpsUser)
		{	
			System.assertEquals(struct.registration.Id, GNE_CM_MPS_Utils.getMPSRegistration());
		}
    }
    
    static testMethod void testGetAccount()
    {
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', true);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Account_Trigger', true);
    	//create test data
    	Map<String, RecordType> recordTypes = GlobalUtils.getRecordTypes('Account', new List<String>{'Professional_vod'});
    	GNE_CM_MPS_UnitTestDataCreator.MpsUserWithAccount userWithAcct = GNE_CM_MPS_UnitTestDataCreator.getMPSUser('incognit', recordTypes);
		GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure struct;
		system.runAs(new User(id = userInfo.getUserId()))
		{	
    		struct = new GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure(3, 5, 1, recordTypes, userWithAcct);
		}
    	System.runAs(userWithAcct.mpsUser)
		{
			List<GNE_CM_MPS_Practice_Agreement_Location__c> mpsUserLocations = struct.mpsUserLocations;
			System.assertNotEquals(0, mpsUserLocations.size(), 'MPS User Locations do not exist.');
			System.assertNotEquals(null, GNE_CM_MPS_Utils.getAccount(userWithAcct.mpsAcct.Id, struct.registration.Id, mpsUserLocations[0].MPS_Location__c));
		}
    }
    
    static testMethod void testGetTherapeuticAreaItems()
    {
    	//wilczekk: just call the function - values are defined in the utils class
    	List<SelectOption> result = GNE_CM_MPS_Utils.getTherapeuticAreaItems();
    }
    
    static testMethod void testGetUniquePrescribers()
    {
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', true);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Account_Trigger', true);
    	Integer numberOfPrescribers = 3;
    	Map<String, RecordType> recordTypes = GlobalUtils.getRecordTypes('Account', new List<String>{'Professional_vod'});
    	GNE_CM_MPS_UnitTestDataCreator.MpsUserWithAccount userWithAcct = GNE_CM_MPS_UnitTestDataCreator.getMPSUser('incognit', recordTypes);
    	GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure struct;
    	system.runAs(new User(id = userInfo.getUserId()))
		{
    		struct = new GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure(3, 5, numberOfPrescribers, recordTypes, userWithAcct);        
		}
        System.runAs(userWithAcct.mpsUser)
		{
			System.assertEquals(numberOfPrescribers, struct.practiceAgreements.size(), 'Practice Agreement number does not match!');			
    		List<GNE_CM_MPS_Practice_Agreement__c> paWithUniquePrescriber = GNE_CM_MPS_Utils.getUniquePrescribers();
    		System.assertEquals(numberOfPrescribers, paWithUniquePrescriber.size(), 'Unique prescribers number does not match!');
		}
    }
    
    static testMethod void testGetPrescriberLocation()
    {   
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', true);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Account_Trigger', true);
    	//create test data
    	Integer numberOfLocations = 5;
    	Map<String, RecordType> recordTypes = GlobalUtils.getRecordTypes('Account', new List<String>{'Professional_vod'});
    	GNE_CM_MPS_UnitTestDataCreator.MpsUserWithAccount userWithAcct = GNE_CM_MPS_UnitTestDataCreator.getMPSUser('incognit', recordTypes);
    	GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure struct;
    	system.runAs(new User(id = userInfo.getUserId()))
		{
    		struct = new GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure(3, numberOfLocations, 1, recordTypes, userWithAcct);        
		}       				
		System.runAs(userWithAcct.mpsUser)
		{			
			List<GNE_CM_MPS_Location__c> result = GNE_CM_MPS_Utils.getPrescriberLocation();			
			System.assertEquals(numberOfLocations, result.size(), 'Prescriber locations number does not match.');
		}
    }
    
    static testMethod void testGetLicenseInformation()
    {
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', true);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Account_Trigger', true);
    	//create test data
    	Map<String, RecordType> recordTypes = GlobalUtils.getRecordTypes('Account', new List<String>{'Professional_vod'});
    	GNE_CM_MPS_UnitTestDataCreator.MpsUserWithAccount userWithAcct = GNE_CM_MPS_UnitTestDataCreator.getMPSUser('incognit', recordTypes);
    	GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure struct;
    	system.runAs(new User(id = userInfo.getUserId()))
		{
    		struct = new GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure(3, 2, 3, recordTypes, userWithAcct);        
		}
		System.runAs(userWithAcct.mpsUser)
		{	
			for(GNE_CM_MPS_Practice_Agreement__c pa : struct.practiceAgreements)
			{				
				Map<String, String> result = GNE_CM_MPS_Utils.getLicenseInformation(pa.Account__c);		
				System.assert(result.size() > 0, 'License Information did not return any values');						
			}
			//real test of get license info
			List<GNE_CM_MPS_Practice_Agreement_Location__c> mpsUserLocations = struct.mpsUserLocations;
			System.assertNotEquals(0, mpsUserLocations.size(), 'MPS User Locations do not exist.');
			
			Id locationId = mpsUserLocations[0].MPS_Location__c;
			Account prescriberAccount = GNE_CM_MPS_Utils.getAccount(userWithAcct.mpsAcct.Id, struct.registration.Id, locationId);
			System.assertEquals(userWithAcct.mpsAcct.Id, prescriberAccount.Id, 'Prescriber account not populated correctly.');	
			Map<String, String> currentLicenseInfo = GNE_CM_MPS_Utils.getLicenseInformation(prescriberAccount.Id);
			System.assert(currentLicenseInfo.size() > 0, 'Current License Info not populated properly.');
			
			//getting practice agreement location
			List<GNE_CM_MPS_Practice_Agreement_Location__c>  prac_agr_loc = [select Address__c from GNE_CM_MPS_Practice_Agreement_Location__c
                                                                        where MPS_Location__c =: locationId and account__c =: prescriberAccount.Id and MPS_Registration__c =: struct.registration.Id];
            System.assert(prac_agr_loc.size() > 0, 'Practice Agreement Location not found.');
			
			List<Address_vod__c> address = [select id, State_vod__c from Address_vod__c where id =: prac_agr_loc[0].Address__c];
			System.assert(address.size() > 0, 'address_vod__c not found.');
						
			System.assert(currentLicenseInfo.containsKey(String.ValueOf(prescriberAccount.Id) + 'Tax ID' + String.ValueOf(address[0].State_vod__c) + address[0].id), 'Prescriber_Tax_ID_gne__c not populated.');				
			System.assert(currentLicenseInfo.containsKey(String.ValueOf(prescriberAccount.Id) + 'PTAN' + String.ValueOf(address[0].State_vod__c) + address[0].id), 'PTAN_gne__c not populated.');				           
			System.assert(currentLicenseInfo.containsKey(String.ValueOf(prescriberAccount.Id) + 'DEA #' + String.ValueOf(address[0].State_vod__c) + address[0].id), 'Prescriber_DEA_gne__c not populated.');				          
			System.assert(currentLicenseInfo.containsKey(String.ValueOf(prescriberAccount.Id) + String.ValueOf(address[0].State_vod__c) + address[0].id), 'Prescriber_State_License_Number_gne__c not populated.');				
			System.assert(currentLicenseInfo.ContainsKey(String.ValueOf(prescriberAccount.Id) + 'NPI #' + String.valueOf(address[0].State_vod__c) + address[0].id), 'Prescriber_NPI_gne__c not populated.');
		}
    }
    
    static testMethod void testEbiFunctionalityForRegistrationEnabled()
    {
    	testEbiFunctionalityForRegistration(GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED, 'disabled', true);
    }
    
    static testMethod void testEbiFunctionalityForRegistrationDisabled()
    {
    	testEbiFunctionalityForRegistration(GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED, 'enabled', false);
    }
    
    static testMethod void testEbiFunctionalityForRegistrationSelectedRegistationFalse()
    {
    	testEbiFunctionalityForRegistration(GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED_FOR_SELECTED, 'disabled', false);
    }
    
    static testMethod void testEbiFunctionalityForRegistrationSelectedRegistationDefault()
    {
    	testEbiFunctionalityForRegistration(GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED_FOR_SELECTED, 'default', false);
    }
        
    static testMethod void testEbiFunctionalityForRegistrationSelectedRegistationTrue()
    {
    	testEbiFunctionalityForRegistration(GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED_FOR_SELECTED, 'enabled', true);
    }   
    
    static testMethod void testEbiFunctionalityForRegistrationDisabledForSelectedRegistationFalse()
    {
    	testEbiFunctionalityForRegistration(GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED_FOR_SELECTED, 'disabled', false);
    }
    
    static testMethod void testEbiFunctionalityForRegistrationDisabledForSelectedRegistationDefault()
    {
    	testEbiFunctionalityForRegistration(GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED_FOR_SELECTED, 'default', true);
    }
        
    static testMethod void testEbiFunctionalityForRegistrationDisabledForSelectedRegistationTrue()
    {
    	testEbiFunctionalityForRegistration(GNE_CM_MPS_CustomSettingsHelper.EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED_FOR_SELECTED, 'enabled', true);
    }
    
    private static void testEbiFunctionalityForRegistration(String customSetting, String ebiFunctionality, boolean functionTemplateResponse){
    	GNE_CM_MPS_Custom_Setting__c custom = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG);
   		custom.EBI_Functionality_For_Registration_gne__c = customSetting;
   		upsert custom;		
    	GNE_CM_MPS_Registration__c registration = GNE_CM_MPS_Test_Helper.createMpsRegistration();
    	registration.EBI_Functionality_gne__c = ebiFunctionality;    	
    	insert registration;    	
    	boolean functionRealResponse  = GNE_CM_MPS_Utils.isEbiFunctionalityEnabledForMPSRegistration(registration.id);
    	System.assertEquals(functionRealResponse, functionTemplateResponse);	
    }  

    static testMethod void testCreateAndLogErrorsMethod()
    {
        Case c = GNE_CM_Test_Helper.createCase('Actemra', 'GATCF - Standard Case');
        c.Ins_Eligibility_Determination_gne__c = 'Approved';
        insert c;
        User runUser = GNE_CM_Test_Helper.createUser('GNE-CM-INTAKE');
        insert runUser;
        Test.startTest();
            System.runAs(runUser)
            {
                //c.Anticipated_Date_of_Treatment_gne__c = System.today().addDays(50);
                c.Status = 'Closed. Family Financial Decision';
                c.GATCF_Status_gne__c = 'Pending Case Review';
                c.Ins_Eligibility_Determination_gne__c = 'Denied';
                try
                {   
                    List<Database.SaveResult> caseUpdateResults = Database.update(new List<Case>{c},false);
                    System.debug('update results---'+caseUpdateResults);
                    GNE_CM_MPS_Utils.createAndLogErrors(caseUpdateResults, 'Error in updating Case with ID: {sr} with GATCF Status: {0}', new List<String>{String.valueOf(c.GATCF_Status_gne__c)}, 'Case','GNE_CM_MPS_Utils_Test.testCreateAndLogErrorsMethod',new List<Case>{c});
                }catch(Exception e)
                {
                    System.debug('exception---'+e.getMessage());
                    GNE_CM_MPS_Utils.createAndLogErrors(new List<Database.SaveResult>(), 'Exception in updating Case with GATCF Status: {0} and exception message is {1}', new List<String>{String.valueOf(c.GATCF_Status_gne__c),GlobalUtils.getExceptionDescription(e)}, 'Case','GNE_CM_MPS_Utils_Test.testCreateAndLogErrorsMethod',null);
                }
                
            }
        Test.stopTest();
    }  
}