@isTest(SeeAllData=true)
private class GNE_CollaborationGroup_Trigger_Test {

    private static Set<String> chatterPermissionSetNames = GNE_Chatter_Permission_Set_Name__c.getAll().keySet();

    static testMethod void myUnitTest() {
        String profileName = 'System Administrator';
        String domain = 'gene.com';
        PermissionSet chatterPermission = [SELECT Id FROM PermissionSet WHERE Name IN : chatterPermissionSetNames LIMIT 1];

        User testUser = GNE_CM_Test_Helper.addTestUser(profileName, domain);

        //no permission
        Integer countBefore = [SELECT count() FROM CollaborationGroup];
        system.runAs(testUser) {
            try {
                CollaborationGroup cGroup = new CollaborationGroup(CollaborationType = 'Public', Name = 'test group', OwnerId = testUser.Id);
                insert cGroup;
                System.assert(false, 'Exception should be thrown and this line should not be achieved');
            } catch (DmlException e) {
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0) );
            }
        }
        Integer countAfter = [SELECT count() FROM CollaborationGroup];
        system.assertEquals(countBefore, countAfter);

        PermissionSetAssignment permission = new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = chatterPermission.Id);
        insert permission;

        //user has permission
        countBefore = [SELECT count() FROM CollaborationGroup];
        system.debug('countBefore: ' + countBefore);
        system.runAs(testUser) {
            CollaborationGroup cGroup = new CollaborationGroup(CollaborationType = 'Public', Name = 'test group2', OwnerId = testUser.Id);
            insert cGroup;
        }
        countAfter = [SELECT count() FROM CollaborationGroup];
        system.assertEquals(countBefore + 1, countAfter);

        delete permission;

        //no permission
        countBefore = [SELECT count() FROM CollaborationGroup];
        system.runAs(testUser) {
            try {
                CollaborationGroup cGroup = new CollaborationGroup(CollaborationType = 'Public', Name = 'test group3', OwnerId = testUser.Id);
                insert cGroup;
                System.assert(false, 'Exception should be thrown and this line should not be achieved');
            } catch (DmlException e) {
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0) );
            }
        }
        countAfter = [SELECT count() FROM CollaborationGroup];
        system.assertEquals(countBefore, countAfter);
    }
}