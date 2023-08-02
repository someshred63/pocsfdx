/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-18
*  Description: This is a test class for GNE_SFA2_ART_Site_Trigger
*    
*  Modification History
*  Date         Name            Description     
*  2014-30-01 Piotr Przesmycki  Removed seeAllData annotation
*  2017-23-08 Konrad Maluszkiewicz  Adjusted assert conditions to current logic
*  2017-31-08 Konrad Maluszkiewicz  Fixed dependency on already existing users. Now users are generated dynamically during the test.
*************************************************************/
@isTest
public without sharing class GNE_SFA2_ART_Site_Trigger_Test {
  
  public static testMethod void testOwnershipChangeOnAfterUpdate() {

    List<User> mccoUsers = [ SELECT Id, ProfileId FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name Like 'GNE-MCCO%') AND isActive = true AND LastName LIKE 'GNE-MCCO-USR-TEST_USR-%' ];

    if(mccoUsers != null && mccoUsers.size() > 3) {
      System.runAs(mccoUsers[0]) {
        ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
        GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTTeamMembership(testArtSite, mccoUsers[2]);
        
        List<Art_Site_gne__Share> artSiteShare = [ SELECT Id, UserOrGroupID, ParentId FROM Art_Site_gne__Share WHERE UserOrGroupID = :mccoUsers[2].Id AND ParentId = :testArtSite.Id ];
        System.assertNotEquals(null, artSiteShare);
        System.assertEquals(1, artSiteShare.size());

        Art_Site_gne__Share artSiteShareBeforeTriggering = new Art_Site_gne__Share(Id = artSiteShare[0].Id, UserOrGroupID = artSiteShare[0].UserOrGroupID, ParentId = artSiteShare[0].ParentId);

        testArtSite.OwnerID = mccoUsers[1].Id;
        update testArtSite;
        
        artSiteShare = [ SELECT Id, UserOrGroupID, ParentId FROM Art_Site_gne__Share WHERE UserOrGroupID = :mccoUsers[2].Id AND ParentId = :testArtSite.Id ];

        System.assertNotEquals(null, artSiteShare);
        System.assertEquals(1, artSiteShare.size());
        System.assertNotEquals(artSiteShareBeforeTriggering.Id, artSiteShare[0].Id);
        System.assertEquals(artSiteShareBeforeTriggering.UserOrGroupID, artSiteShare[0].UserOrGroupID);
        System.assertEquals(artSiteShareBeforeTriggering.ParentId, artSiteShare[0].ParentId);
      }
    } else {
      System.assert(false, 'Could not find enough GNE-MCCO Users to perform the test.');
    }
  }

  @testSetup static void createTestUsersList() {
    List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name Like 'GNE-MCCO%' ];
    List<User> usersList = new List<User>();

    Id userRoleId = [ SELECT Id FROM UserRole WHERE Name='BFRM' ].Id;
    System.assertNotEquals(null, userRoleId, 'There is no role required for this test in the system.');

    for(Integer i=0;i<4;i++) {
      usersList.add(new User(LastName = 'GNE-MCCO-USR-TEST_USR-' + i, Email = 'test@roche.com', Alias = 'Gnemc', Username = 'test123' + i + '4444@test.com', LocaleSidKey = 'en_US', TimeZoneSidKey = 'GMT', ProfileId = mccoProfiles[0].Id, LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', isActive = true, UserRoleId = userRoleId));
    }
    insert usersList;
  }
}