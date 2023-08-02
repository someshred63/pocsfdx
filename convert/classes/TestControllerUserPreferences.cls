/********************************************************************************************
Name   : TestControllerUserPreferences
Usage  : Unit tests for testing ControllerUserPreferences apex class.
Author : Appirio
Date   : November 12, 2009
********************************************************************************************/

@isTest
private class TestControllerUserPreferences {
    static List<Territory2> territoryList;
    
    @isTest
    static void testController() {
        User testUser = getTestUser();
        territoryList = new List<Territory2>();
        territoryList = [select name from territory2 limit 5];
        
        final String DELIMITER = ';';
        
        System.runAs(testUser) {
            ControllerUserEventPreferences controller = new ControllerUserEventPreferences();
            
            controller.initializePreferences();
            System.assertEquals([SELECT count() FROM UnifiedCalendarUserEventPreference_gne__c
                    WHERE OwnerId = :testUser.Id], 1);
            
            controller.brandRowsList[0][0].isSelected = true;
            controller.save();
            UnifiedCalendarUserEventPreference_gne__c userEventPreference = [SELECT Event_Type__c,
                brands__c, territories__c, prev_eventtype__c, prev_brands__c, prev_territories__c
                FROM UnifiedCalendarUserEventPreference_gne__c
                WHERE OwnerId = :testUser.Id];
            
            Set<String> selectedEventTypes = new Set<String>();
            selectedEventTypes.addAll(userEventPreference.Event_Type__c.split(DELIMITER));
            Set<String> selectedBrands = new Set<String>();
            selectedBrands.addAll(userEventPreference.brands__c.split(DELIMITER));
            Set<String> selectedTerritories = new Set<String>();
            selectedTerritories.addAll(userEventPreference.territories__c.split(DELIMITER));
            
            System.assert(selectedEventTypes.contains('Speaker Program'));
            System.assert(selectedEventTypes.contains('Speaker Training'));
            System.assert(selectedBrands.contains(controller.brandRowsList[0][0].LABEL));
            System.assert(selectedTerritories.contains(territoryList[0].Name));
            System.assert(selectedTerritories.contains(territoryList[1].Name));
            
            controller = new ControllerUserEventPreferences();
            if (territoryList != null && territoryList[2].Id != null) {
                controller.addTerri = territoryList[2].Name;
            }
            
            controller.addTerritory();
            
            if (controller.territoryRowsList.size() > 0) {
              controller.removeTerri = 0;
              controller.removeTerritory();
            }
            
            if (territoryList != null && territoryList[2].Id != null
                    && controller.territoryRowsList.size() > 0) {
                controller.save();
              userEventPreference = [SELECT Event_Type__c, brands__c, territories__c,
                      prev_eventtype__c, prev_brands__c, prev_territories__c
                      FROM UnifiedCalendarUserEventPreference_gne__c
                      WHERE OwnerId = :testUser.Id];
              
              selectedTerritories = new Set<String>();
                selectedTerritories.addAll(userEventPreference.territories__c.split(DELIMITER));
                Set<String> prevSelectedTerritories = new Set<String>();
              prevSelectedTerritories.addAll(userEventPreference.prev_territories__c.split(DELIMITER));
              
              System.assert(selectedTerritories.contains(territoryList[0].Name));
              System.assert(selectedTerritories.contains(territoryList[1].Name));
              System.assert(prevSelectedTerritories.contains(territoryList[0].Name));
                System.assert(prevSelectedTerritories.contains(territoryList[1].Name));
                System.assertEquals(userEventPreference.Event_Type__c, userEventPreference.prev_eventtype__c);
                System.assertEquals(userEventPreference.brands__c, userEventPreference.prev_brands__c);
            }
        }
    }
    
    //---------------------------------//
    // Returns User for test methods.
    //---------------------------------//
    @isTest
    public static User getTestUser() {
        // Test user
        User testUser;
        territoryList = null;
        
        // Existing user
        User existingUser = [select Id, LastName, Email, Alias, TimeZoneSidKey,
                LocaleSidKey, EmailEncodingKey, LanguageLocaleKey
                from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        /***
        territoryList = new List<Territory2>();
        
        Territory__c territory = new Territory2();
        territory.Name = 'Territory1';
        territoryList.add(territory);
        
        territory = new Territory2();
        territory.Name = 'Territory2';
        territoryList.add(territory);
        
        territory = new Territory2();
        territory.Name = 'Territory3';
        territoryList.add(territory);
        
        insert territoryList;
        ***/
        
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