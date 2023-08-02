/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-08
*  Description: This is a helper class for Address related unit tests
*  
*  Modification History
*  Date        Name        Description
*  
*************************************************************/

public with sharing class GNE_SFA2_Address_Test_Helper {
    
    public static Integer BATCH_SIZE = 201; // 201 to test agains governor limits
    
    public static List<Address_vod__c> insertTestAddresses(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
        List<Address_vod__c> testAddresses = prepareTestAddresses(emptyFieldNames, testFieldValues);
        insert testAddresses;
        return testAddresses;
    }
    
    /* helper method used for preparing test data */
    public static List<Address_vod__c> prepareTestAddresses(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
        List<Address_vod__c> testData = new List<Address_vod__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            Address_vod__c address = new Address_vod__c();
            
            // populate Name field
            address.Name = (String) getFieldValue('Name', emptyFieldNames, testFieldValues);
            // populate Lock_vod__c field
            address.Lock_vod__c = (Boolean) getFieldValue('Lock_vod__c', emptyFieldNames, testFieldValues); 
            // populate Inactive_vod__c field
            address.Inactive_vod__c = (Boolean) getFieldValue('Inactive_vod__c', emptyFieldNames, testFieldValues);         
            // populate Primary_vod__c field
            address.Primary_vod__c = (Boolean) getFieldValue('Primary_vod__c', emptyFieldNames, testFieldValues);
            // populate Account_vod__c field
            address.Account_vod__c = (String) getFieldValue('Account_vod__c', emptyFieldNames, testFieldValues);
            // populate DEA_Address_vod__c field
            address.DEA_Address_vod__c =  (Boolean) getFieldValue('DEA_Address_vod__c', emptyFieldNames, testFieldValues);
            // populate DEA_Status_vod__c field
            address.DEA_Status_vod__c = (String) getFieldValue('DEA_Status_vod__c', emptyFieldNames, testFieldValues);
            // populate DEA_Schedule_vod__c field
            address.DEA_Schedule_vod__c = (String) getFieldValue('DEA_Schedule_vod__c', emptyFieldNames, testFieldValues);
            // populate DEA_vod__c field
            address.DEA_vod__c = (String) getFieldValue('DEA_vod__c', emptyFieldNames, testFieldValues);
            // populate Controlling_Address_vod__c field
            address.Controlling_Address_vod__c = (String) getFieldValue('Controlling_Address_vod__c', emptyFieldNames, testFieldValues);
            // populate No_Address_Copy_vod__c field
            address.No_Address_Copy_vod__c = (Boolean) getFieldValue('No_Address_Copy_vod__c', emptyFieldNames, testFieldValues);
            // populate Entity_Reference_Id_vod__c field
            address.Entity_Reference_Id_vod__c = (String) getFieldValue('Entity_Reference_Id_vod__c', emptyFieldNames, testFieldValues);
            // populate Controlled_Address_vod__c field
            address.Controlled_Address_vod__c = (Boolean) getFieldValue('Controlled_Address_vod__c', emptyFieldNames, testFieldValues);
            // populate External_ID_vod__c field
            address.External_ID_vod__c = (String) getUniqueFieldValue('External_ID_vod__c', emptyFieldNames, testFieldValues, i);
            // populate State_vod__c field
            address.State_vod__c = (String) getFieldValue('State_vod__c', emptyFieldNames, testFieldValues);
            // populate Country_vod__c field
            address.Country_vod__c = (String) getFieldValue('Country_vod__c', emptyFieldNames, testFieldValues);
            // populate License_vod__c field
            address.License_vod__c = (String) getFieldValue('License_vod__c', emptyFieldNames, testFieldValues);
            // populate License_Status_vod__c field
            address.License_Status_vod__c = (String) getFieldValue('License_Status_vod__c', emptyFieldNames, testFieldValues);
             // populate Fax_vod__c field
            address.Fax_vod__c = (String) getFieldValue('Fax_vod__c', emptyFieldNames, testFieldValues);
             // populate Fax_2_vod__c field
            address.Fax_2_vod__c = (String) getFieldValue('Fax_2_vod__c', emptyFieldNames, testFieldValues);
            
            // populate DEA_Expiration_Date_vod__c field
            if(emptyFieldNames != null && emptyFieldNames.contains('DEA_Expiration_Date_vod__c')) {
                address.DEA_Expiration_Date_vod__c = null;          
            } else if(testFieldValues != null && testFieldValues.containsKey('DEA_Expiration_Date_vod__c')) {
                address.DEA_Expiration_Date_vod__c = (Date) testFieldValues.get('DEA_Expiration_Date_vod__c');
            } else {
                address.DEA_Expiration_Date_vod__c = System.today();
            }
            
            // populate License_Expiration_date_vod__c field
            if(emptyFieldNames != null && emptyFieldNames.contains('License_Expiration_date_vod__c')) {
                address.License_Expiration_date_vod__c = null;          
            } else if(testFieldValues != null && testFieldValues.containsKey('License_Expiration_date_vod__c')) {
                address.License_Expiration_date_vod__c = (Date) testFieldValues.get('License_Expiration_date_vod__c');
            } else {
                address.License_Expiration_date_vod__c = System.today();
            }
            
            testData.add(address);
        }
        
        return testData;
    }
    
    /* helper method for getting field value */
    public static Object getFieldValue(String fieldName, Set<String> emptyFieldNames, Map<String, Object> testFieldValues){
        Object result = null;
        if(emptyFieldNames != null && emptyFieldNames.contains(fieldName)) {
            result = '';            
        } else if(testFieldValues != null && testFieldValues.containsKey(fieldName)) {
            result = (Object) testFieldValues.get(fieldName);
        } else {
            result = 'test';
        }
        return result;
    }
    
    /* helper method for getting field value which has to be unique */
    public static Object getUniqueFieldValue(String fieldName, Set<String> emptyFieldNames, Map<String, Object> testFieldValues, Integer i){
        Object result = null;
        if(emptyFieldNames != null && emptyFieldNames.contains(fieldName)) {
            result = '';            
        } else if(testFieldValues != null && testFieldValues.containsKey(fieldName)) {
            result = (Object) testFieldValues.get(fieldName) + String.valueOf(i);
        } else {
            result = 'testValue' + String.valueOf(i);
        }
        return result;
    }
    
    public static void insertCustomSettings() {
		// insert custom setting
		List<GNE_SFA2_Addr_Valid_Excluded_Profiles__c> excludedProfiles = [ SELECT Profile_Name__c FROM GNE_SFA2_Addr_Valid_Excluded_Profiles__c ];
		if(excludedProfiles == null || excludedProfiles.size() == 0) {
			List<GNE_SFA2_Addr_Valid_Excluded_Profiles__c> customSettingsToAdd = new List<GNE_SFA2_Addr_Valid_Excluded_Profiles__c>();
			customSettingsToAdd.add(new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'System Administrator', Profile_Name__c = 'System Administrator'));
			customSettingsToAdd.add(new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'GNE-SYS-DataSupport', Profile_Name__c = 'GNE-SYS-DataSupport'));
			customSettingsToAdd.add(new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'GNE-SYS-AutomatedJob', Profile_Name__c = 'GNE-SYS-AutomatedJob'));
			customSettingsToAdd.add(new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'GNE-LWO-CUSTOPS', Profile_Name__c = 'GNE-LWO-CUSTOPS'));
			customSettingsToAdd.add(new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'GNE-MCCO OPS', Profile_Name__c = 'GNE-MCCO OPS'));
			customSettingsToAdd.add(new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'Automated Job System Administrator', Profile_Name__c = 'Automated Job System Administrator (obsolete)'));
			insert customSettingsToAdd;
		} 
		
		List<GNE_SFA2_Addr_CA_Valid_Included_Profiles__c> includedProfiles = [ SELECT Profile_Name__c FROM GNE_SFA2_Addr_CA_Valid_Included_Profiles__c ];
		if(includedProfiles == null || includedProfiles.size() == 0) {
			List<GNE_SFA2_Addr_CA_Valid_Included_Profiles__c> customSettingsToAdd = new List<GNE_SFA2_Addr_CA_Valid_Included_Profiles__c>();
			customSettingsToAdd.add(new GNE_SFA2_Addr_CA_Valid_Included_Profiles__c(Name = 'RCanada-SFA-Manager', Profile_Name__c = 'RCanada-SFA-Manager'));
			customSettingsToAdd.add(new GNE_SFA2_Addr_CA_Valid_Included_Profiles__c(Name = 'RCanada-SFA-MSL', Profile_Name__c = 'RCanada-SFA-MSL'));
			customSettingsToAdd.add(new GNE_SFA2_Addr_CA_Valid_Included_Profiles__c(Name = 'RCanada-SFA-MSL-Manager', Profile_Name__c = 'RCanada-SFA-MSL-Manager'));
			customSettingsToAdd.add(new GNE_SFA2_Addr_CA_Valid_Included_Profiles__c(Name = 'RCanada-SFA-TS', Profile_Name__c = 'RCanada-SFA-TS'));
			insert customSettingsToAdd;
		} 
	}
}