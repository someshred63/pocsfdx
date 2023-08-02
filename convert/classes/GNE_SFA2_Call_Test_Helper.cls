/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-09
*  Description: This is a helper class for Call related triggers
*    
*  Modification History
*  Date        Name                    Description
* 01/08/2013  Sreedhar Karukonda    Added Alternate Fax, Fax to insertTestContact method
*            
*************************************************************/
public with sharing class GNE_SFA2_Call_Test_Helper {
    private static Integer BATCH_SIZE = 201;
    
    public static Call2_vod__c insertTestCall(String status) {
        Call2_vod__c testCall = new Call2_vod__c(Status_vod__c = status);
        insert testCall;
        return testCall;    
    }
    
    public static Account insertTestAccount() {
        Account testAccount = new Account(FirstName = 'testFirstName', LastName = 'testLastName');
        insert testAccount;
        return testAccount; 
    }
    
    public static Contact insertTestContact() {
        Contact testContact = new Contact(FirstName = 'testFirstName', LastName = 'testLastName',Alternate_Fax_gne__c='(123) 456-7890', Fax='(123) 456-7890');
        insert testContact;
        return testContact; 
    }
    
    /* helper method for getting field value */
    public static String getFieldValue(String fieldName, Set<String> emptyFieldNames, Map<String, Object> testFieldValues){
        String result = null;
        if(emptyFieldNames != null && emptyFieldNames.contains(fieldName)) {
            result = '';            
        } else if(testFieldValues != null && testFieldValues.containsKey(fieldName)) {
            result = (String) testFieldValues.get(fieldName);
        } else {
            result = 'test';
        }
        return result;
    }
    
    public static List<Call2_Detail_vod__c> insertTestCallDetails(Call2_vod__c testCall) {
        List<Call2_Detail_vod__c> testCallDetails = new List<Call2_Detail_vod__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            testCallDetails.add(new Call2_Detail_vod__c(Call2_vod__c = testCall.Id));
        }
        insert testCallDetails;
        return testCallDetails;
    }
    
    public static List<Call2_Key_Message_vod__c> insertTestCallKeyMessages(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
        List<Call2_Key_Message_vod__c> testCallKeyMessages = new List<Call2_Key_Message_vod__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            Call2_Key_Message_vod__c testCallKeyMessage = new Call2_Key_Message_vod__c();
            testCallKeyMessage.Call2_vod__c = (Id) getFieldValue('Call2_vod__c', emptyFieldNames, testFieldValues);
            testCallKeyMessage.Attendee_Type_vod__c = (String) getFieldValue('Attendee_Type_vod__c', emptyFieldNames, testFieldValues);
            testCallKeyMessage.Entity_Reference_Id_vod__c = (Id) getFieldValue('Entity_Reference_Id_vod__c', emptyFieldNames, testFieldValues);
            testCallKeyMessages.add(testCallKeyMessage);
        }
        insert testCallKeyMessages;
        return testCallKeyMessages;
    }
}