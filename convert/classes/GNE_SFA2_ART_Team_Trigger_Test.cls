/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-18
*  Description: This is a test class for GNE_SFA2_ART_Team_Trigger
*    
*  Modification History
*  Date         Name                Description      
*  2014-01-30   Piotr Przesmycki    Removed seeAllData annotation, and changed class to with sharing
*************************************************************/
@isTest
public with sharing class GNE_SFA2_ART_Team_Trigger_Test {
    public static testMethod void testOwnershipChangeOnAfterInsert() {
        List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name Like 'GNE-340B' ];
        List<User> mccoUsers = [ SELECT Id FROM User WHERE ProfileId in :mccoProfiles AND isActive = true ];

        if(mccoUsers != null && mccoUsers.size() > 3) {
            System.runAs(mccoUsers[0]) {
                ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
                GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTTeamMembership(testArtSite, mccoUsers[2]);
                
                List<Art_Site_gne__Share> artSiteShare = [ SELECT Id FROM Art_Site_gne__Share WHERE UserOrGroupID = :mccoUsers[2].Id AND ParentId = :testArtSite.Id ];
                System.assertNotEquals(null, artSiteShare);
                System.assertEquals(1, artSiteShare.size());    
            }
        } else {
            System.assert(false, 'Could not find enough GNE-MCCO Users to perform the test.');
        }
    }
    
    public static testMethod void testDeleteSharesAfterDelete() {
        List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name Like 'GNE-340B' ];
        List<User> mccoUsers = [ SELECT Id FROM User WHERE ProfileId in :mccoProfiles AND isActive = true];
                
        if(mccoUsers != null && mccoUsers.size() > 3) {
            System.runAs(mccoUsers[0]) {
                ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
                ART_Team_gne__c teamMembership = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTTeamMembership(testArtSite, mccoUsers[2]);
                
                List<Art_Site_gne__Share> artSiteShare = [ SELECT Id FROM Art_Site_gne__Share WHERE UserOrGroupID = :mccoUsers[2].Id AND ParentId = :testArtSite.Id ];
                System.assertNotEquals(null, artSiteShare);
                System.assertEquals(1, artSiteShare.size());
                
                delete teamMembership;
                
                artSiteShare = [ SELECT Id FROM Art_Site_gne__Share WHERE UserOrGroupID = :mccoUsers[2].Id AND ParentId = :testArtSite.Id ];
                System.assertNotEquals(null, artSiteShare);
                System.assertEquals(0, artSiteShare.size());    
            }
        } else {
            System.assert(false, 'Could not find enough GNE-MCCO Users to perform the test.');
        }
    }
}