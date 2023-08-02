@isTest(SeeAllData=true)
private class GNE_FeedComment_Trigger_Test {

    private static Set<String> chatterPermissionSetNames = GNE_Chatter_Permission_Set_Name__c.getAll().keySet();

    static testMethod void myUnitTest() {
        String profileName = 'GNE-MCCO-AM';
        String domain = 'gene.com';
        PermissionSet chatterPermission = [SELECT Id FROM PermissionSet WHERE Name IN : chatterPermissionSetNames LIMIT 1];

        User testUser = GNE_CM_Test_Helper.addTestUser(profileName, domain);

        PermissionSetAssignment permission = new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = chatterPermission.Id);
        insert permission;

        FeedItem fi = new FeedItem(Body = 'test', CreatedById = testUser.Id, ParentId = testUser.Id);

        Integer countBefore = [SELECT count() FROM FeedComment];
        system.runAs(testUser) {
            insert fi;
            FeedComment comment = new FeedComment(CommentBody = 'test', CreatedById = testUser.Id, FeedItemId = fi.id);
            insert comment;
        }
        Integer countAfter = [SELECT count() FROM FeedComment];
        system.assertEquals(countBefore + 1, countAfter);

        //no permission
        delete permission;

        countBefore = [SELECT count() FROM FeedComment];
        system.runAs(testUser) {
            try {
                FeedComment comment = new FeedComment(CommentBody = 'test', CreatedById = testUser.Id, FeedItemId = fi.id);
                insert comment;
                System.assert(false, 'Exception should be thrown and this line should not be achieved');
            } catch (DmlException e) {
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0) );
            }
        }
        countAfter = [SELECT count() FROM FeedComment];
        system.assertEquals(countBefore, countAfter);
    }
}