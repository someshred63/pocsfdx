/**********************************************************************
 *  @author: Adam Bebenek, Roche ADMD
 *  Date: 10-March-2010 
 *  Description: Unit tests for testing ImedEventsExtension apex class.
 *                           
 *  Modification History
 *  Date        Name        Description
 *  7/21/2011 Michal Gajewski - crated on DEV              
 **********************************************************************/
@isTest
private class TestImedEventsExtension {
    
    @isTest
    static void testController() {
        User testUser = getTestUser();
        
        System.runAs(testUser) {
            //User opens calendar preferences in first window
            PageReference pageReference;        
            UnifiedCalendarUserEventPreference_gne__c imedPreference = new UnifiedCalendarUserEventPreference_gne__c();
            ApexPages.StandardController sc = new ApexPages.standardController(imedPreference);
            ImedEventsExtension imedEventsExtension = new ImedEventsExtension(sc);
            pageReference = imedEventsExtension.init();
            System.assertEquals(pageReference,null); 

            //Before he/she saves the preferences in first window, the second one is opened            
            PageReference pageReference2;        
            UnifiedCalendarUserEventPreference_gne__c imedPreference2 = new UnifiedCalendarUserEventPreference_gne__c();
            ApexPages.StandardController sc2 = new ApexPages.standardController(imedPreference2);
            ImedEventsExtension imedEventsExtension2 = new ImedEventsExtension(sc2);
            pageReference2 = imedEventsExtension2.init();
            System.assertEquals(pageReference2,null); 
            
            //Changes from first window are saved to DB
            pageReference = imedEventsExtension.save();
            System.assertEquals(pageReference.getParameters().get('id'),imedPreference.id);
            //One record of user preferences exists in DB
            System.assertEquals([SELECT count() FROM UnifiedCalendarUserEventPreference_gne__c WHERE OwnerId = :testUser.Id], 1);
            
            //Changes from second window are saved
            pageReference2 = imedEventsExtension2.save();
            System.assertEquals(pageReference2.getParameters().get('id'),imedPreference2.id); 
            //This caused, that the record from first window has been deleted - still one record of user preferences exists in DB
            System.assertEquals([SELECT count() FROM UnifiedCalendarUserEventPreference_gne__c WHERE OwnerId = :testUser.Id], 1);
            
            //Refresh page if the preference record, associated to user, has been already found.  
            pageReference2 = imedEventsExtension2.init();         
        }
    }
    
    //-----------------------------------------------//
    // Returns User for test methods.
    //-----------------------------------------------//
    @isTest
    static User getTestUser() {
        // Test user
        User testUser;
        
        // Existing user
        User existingUser = [select Id, LastName, Email, Alias, TimeZoneSidKey,
                LocaleSidKey, EmailEncodingKey, LanguageLocaleKey
                from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        try {
            // Set fields of user and insert it
            testUser = new User();
            testUser.Username = 'testUserForEventPref@gene.com';
            testUser.LastName = existingUser.LastName;
            testUser.Email = 'testUserForEventPref@gene.com';
            testUser.Alias = existingUser.Alias;
            testUser.CommunityNickname = 'testUser';
            testUser.TimeZoneSidKey = existingUser.TimeZoneSidKey;
            testUser.LocaleSidKey = existingUser.LocaleSidKey;
            testUser.EmailEncodingKey = existingUser.EmailEncodingKey;
            testUser.LanguageLocaleKey = existingUser.LanguageLocaleKey;
            testUser.ProfileId = [select Id from Profile where Name = 'System Administrator' limit 1].Id;
            insert testUser;
        } catch(Exception ex) {
            System.debug('Debug: Error while creating test user - ' + ex.getMessage());
            
            // If was unsuccessful in creating new user then use existing one
            testUser = existingUser;
            delete [SELECT Id FROM UnifiedCalendarUserEventPreference_gne__c WHERE OwnerId = :testUser.Id];
            
            update testUser;
        }
        
        // return new or existing user
        return testUser;
    }
}