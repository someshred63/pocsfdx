@isTest
private class GNE_CommunicationPrefTriggerHandlerTest {
    @testSetup
    static void testData() {
        Account acc = new Account(Name = 'test account');
        insert acc;
        
        Communication_Preference_gne__c cp1 = new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = false, 	Type_gne__c = 'Email', Value_gne__c = 'test@test.org');
        Communication_Preference_gne__c cp2 = new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = true, 	Type_gne__c = 'Email', Value_gne__c = '2test2@test.org');
        Communication_Preference_gne__c cp3 = new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = true, 	Type_gne__c = 'Fax', Value_gne__c = '44444444444');
        Communication_Preference_gne__c cp4 = new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = false, 	Type_gne__c = 'Fax', Value_gne__c = '55534554241');
        Communication_Preference_gne__c cp5 = new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = false, 	Type_gne__c = 'Phone', Value_gne__c = '44444444444');
        Communication_Preference_gne__c cp6 = new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = true, 	Type_gne__c = 'Phone', Value_gne__c = '55534554242');
        insert new List<Communication_Preference_gne__c> {cp1, cp2, cp3, cp4, cp5, cp6};
    }
    
    @isTest
    static void testPersonalDuplicateEmail() {
        test.startTest();
        	Boolean isError = false;
            try {
                Account acc =[Select Id FROM Account WHERE Name = 'test account' LIMIT 1];
                insert new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = true, 	Type_gne__c = 'Email', Value_gne__c = '2test2@test.org');                
                
            } catch(Exception ex){
                Boolean isCorrectErrorMessage = ex.getMessage().contains('Provided Email already exists in the database. Please enter a different value to save the record.')? true : false;
                System.assertEquals(isCorrectErrorMessage, true);
                isError = true;
            }
        test.stopTest();
        
        System.assert(isError);
    }
    
    @isTest
    static void testPersonalDuplicatePhone() {
        test.startTest();
        	Boolean isError = false;
            try {
                Account acc =[Select Id FROM Account WHERE Name = 'test account' LIMIT 1];
                insert new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = true, 	Type_gne__c = 'Phone', Value_gne__c = '55534554242');                
                
            } catch(Exception ex){
                Boolean isCorrectErrorMessage = ex.getMessage().contains('Provided Phone already exists in the database. Please enter a different value to save the record.')? true : false;
                System.assertEquals(isCorrectErrorMessage, true);
                isError = true;
            }
        test.stopTest(); 
        
        System.assert(isError);
    }
    
    @isTest
    static void testPersonalDuplicateFax() {
        test.startTest();
        	Boolean isError = false;
            try {                
                Account acc =[Select Id FROM Account WHERE Name = 'test account' LIMIT 1];
                insert new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = true, Type_gne__c = 'Fax', Value_gne__c = '44444444444');                
                
            } catch(Exception ex){
                Boolean isCorrectErrorMessage = ex.getMessage().contains('Provided Fax already exists in the database. Please enter a different value to save the record.')? true : false;
                System.assertEquals(isCorrectErrorMessage, true);
                isError = true;                
            }
        test.stopTest();    
        
        System.assert(isError);
    }
    
    @isTest
    static void testPublicDuplicateEmail() {
        test.startTest();
        	Boolean isError = false;
            try {                
                Account acc =[Select Id FROM Account WHERE Name = 'test account' LIMIT 1];
                insert new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = false, Type_gne__c = 'Email', Value_gne__c = 'test@test.org');                
                
            } catch(Exception ex){
                Boolean isCorrectErrorMessage = ex.getMessage().contains('Provided Email already exists in the database. Please enter a different value to save the record.')? true : false;
                System.assertEquals(isCorrectErrorMessage, true);
                isError = true;                
            }
        test.stopTest();    
        
        System.assert(isError);      
    }
    
    @isTest
    static void testPublicDuplicatePhone() {
        test.startTest();
        	Boolean isError = false;
            try {                
                Account acc =[Select Id FROM Account WHERE Name = 'test account' LIMIT 1];
                insert new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = false, Type_gne__c = 'Phone', Value_gne__c = '44444444444');                
                
            } catch(Exception ex){
                Boolean isCorrectErrorMessage = ex.getMessage().contains('Provided Phone already exists in the database. Please enter a different value to save the record.')? true : false;
                System.assertEquals(isCorrectErrorMessage, true);
                isError = true;                
            }
        test.stopTest();    
        
        System.assert(isError);         
    }
    
    @isTest
    static void testPublicDuplicateFax() {
        test.startTest();
        	Boolean isError = false;
            try {                
                Account acc =[Select Id FROM Account WHERE Name = 'test account' LIMIT 1];
                insert new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = false, Type_gne__c = 'Fax', Value_gne__c = '55534554241');                
                
            } catch(Exception ex){
                Boolean isCorrectErrorMessage = ex.getMessage().contains('Provided Fax already exists in the database. Please enter a different value to save the record.')? true : false;
                System.assertEquals(isCorrectErrorMessage, true);
                isError = true;                
            }
        test.stopTest();    
        
        System.assert(isError);         
    }
    
    @isTest
    static void testPublicDuplicatePersonalFax() {
        test.startTest();
            Account acc =[Select Id FROM Account WHERE Name = 'test account' LIMIT 1];
        	Communication_Preference_gne__c testCp = new Communication_Preference_gne__c(Account_gne__c = acc.Id, Is_Personal_gne__c = false, Type_gne__c = 'Fax', Value_gne__c = '44444444444'); 
            insert testCp;                
        test.stopTest();
        
        Communication_Preference_gne__c[] cps = [SELECT Type_gne__c, Value_gne__c FROM Communication_Preference_gne__c WHERE Account_gne__c = :acc.Id AND Type_gne__c = 'Fax' AND Is_Personal_gne__c = false];
        Boolean isRecordFound = false;
        for(Communication_Preference_gne__c cp : cps){
            if(cp.Id == testCp.Id){
                isRecordFound = true;
                System.assertEquals('44444444444', testCp.Value_gne__c);
        		System.assertEquals('Fax', testCp.Type_gne__c);                
            }
        }
        System.assertEquals(2, cps.size());
        System.assert(isRecordFound);
    }
}