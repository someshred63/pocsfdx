/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-18
*  Description: This is a helper class for Contact related unit tests
*  
*  Modification History
*  Date        Name        Description
*  
*************************************************************/
public without sharing class GNE_SFA2_Contact_Test_Helper {
	
	private static Integer BATCH_SIZE = 201;
	
	/* helper method used for preparing test data */
    public static List<Contact> prepareTestContacts(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
        List<Contact> testData = new List<Contact>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            Contact contact = new Contact();
            
            // populate FirstName field
            contact.FirstName = (String) getFieldValue('FirstName', emptyFieldNames, testFieldValues);
            // populate LastName field
            contact.LastName = (String) getUniqueFieldValue('LastName', emptyFieldNames, testFieldValues, i); 
            // populate MCL_Last_Interaction_Date_gne__c field
            contact.MCL_Last_Interaction_Date_gne__c = (Date) getFieldValue('MCL_Last_Interaction_Date_gne__c', emptyFieldNames, testFieldValues);
            // populate MCL_Last_Interaction_Date_gne__c field
            contact.PFT_Last_Interaction_Date_gne__c = (Date) getFieldValue('PFT_Last_Interaction_Date_gne__c', emptyFieldNames, testFieldValues);
            // populate Contact_Type_gne__c field
            contact.Contact_Type_gne__c = (String) getFieldValue('Contact_Type_gne__c', emptyFieldNames, testFieldValues);
            // populate Title field
            contact.Title = (String) getFieldValue('Title', emptyFieldNames, testFieldValues);
            // populate Role_gne__c field
            contact.Role_gne__c = (String) getFieldValue('Role_gne__c', emptyFieldNames, testFieldValues);
            // populate Name_Other_gne__c field
            contact.Name_Other_gne__c = (String) getFieldValue('Name_Other_gne__c', emptyFieldNames, testFieldValues);
            // populate Department_gne__c field
            contact.Department_gne__c = (String) getFieldValue('Department_gne__c', emptyFieldNames, testFieldValues);
            // populate Salutation field
            contact.Salutation = (String) getFieldValue('Salutation', emptyFieldNames, testFieldValues);
            // populate Fax field
            contact.Fax = (String) getFieldValue('Fax', emptyFieldNames, testFieldValues);
            // populate Alternate_Fax_gne__c  field
            contact.Alternate_Fax_gne__c  = (String) getFieldValue('Alternate_Fax_gne__c', emptyFieldNames, testFieldValues);
            
            testData.add(contact);
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
}