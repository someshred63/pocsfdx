@isTest
public class GNE_MCCO_Create_ART_Team_Test {
    
    private static ART_Team_gne__c insertSampleArtTeam() {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() limit 1 ];
        
        ART_Site_gne__c newArtSite = new ART_Site_gne__c(Name = 'testSite', ART_Site_Number_gne__c = 1, Primary_gne__c = false );
        System.runAs(thisUser){
            insert newArtSite;
        }
        
        ART_Team_gne__c newArtTeam = new ART_Team_gne__c(ART_Site_gne__c = newArtSite.Id, Team_Member_gne__c = thisUser.Id, Primary_ART_Site_gne__c = false );
   
        System.runAs(thisUser){
            insert newArtTeam;
        }
        return newArtTeam;
    }
    
    private static ART_Site_gne__c insertArtSite() {
        ART_Site_gne__c newArtSite = new ART_Site_gne__c(Name = 'testSite2', ART_Site_Number_gne__c = 2, Primary_gne__c = false );
        insert newArtSite;
        return newArtSite;
    }
    
    private static ART_Team_gne__c insertArtTeam(ART_Site_gne__c artSite, User user) {
        ART_Team_gne__c newArtTeam = new ART_Team_gne__c(ART_Site_gne__c = artSite.Id, Team_Member_gne__c = user.Id, Primary_ART_Site_gne__c = false );
        insert newArtTeam;
        return newArtTeam;
    }
    
    private static User insertUser(Profile profile){
        User testUser = new User(alias = 'u1', email='testUser@salesforce.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = profile.Id, country='United States',
          timezonesidkey='America/Los_Angeles', username='testUser@salesforce.com');
     
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser){
            insert testUser;
        }
        
        return testUser;
    }
    
    public static testMethod void testMccoCreateArtTeamRegularUserIsMember(){
        // select regular MCCO profiles
        List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-MCCO%' AND (NOT Name LIKE '%OPS%')
            AND (NOT Name LIKE '%Manager%') AND (NOT Name LIKE '%Leadership%') AND Name != 'GNE-MCCO-MCL-Manager'];
            
        // create user with regular MCCO profile
        User mccoUser = insertUser(mccoProfiles[0]);
        
        // create ART site
        ART_Site_gne__c artSite = insertArtSite();
        
        ART_Team_gne__c artTeam = insertSampleArtTeam();
        
        // add membership
        insertArtTeam(artSite, mccoUser);

        System.runAs(mccoUser) {
            Test.startTest();

            PageReference mccoCreateartTeamPage = Page.GNE_MCCO_Create_ART_Team_Page;
            // put retUrl parameter
            mccoCreateartTeamPage.getParameters().put('retUrl', '/' + artSite.Id);
            Test.setCurrentPage(mccoCreateartTeamPage);
                
            GNE_MCCO_Create_ART_Team_Controller ctrl = new GNE_MCCO_Create_ART_Team_Controller(new ApexPages.Standardcontroller(artTeam));
                
            PageReference result = ctrl.canBeCreated();
            System.assertNotEquals(result, null);
            System.assertEquals(result.getUrl(), '/' + ((String)artTeam.get('Id')).subString(0, 3) + '/e?nooverride=0&retUrl=%2F' + artSite.Id);
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testMccoCreateArtTeamRegularUserNotMember(){
        // select regular MCCO profiles
        List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-MCCO%' AND (NOT Name LIKE '%OPS%')
            AND (NOT Name LIKE '%Manager%') AND (NOT Name LIKE '%Leadership%') AND Name != 'GNE-MCCO-MCL-Manager'];
            
        // create user with regular MCCO profile
        User mccoUser = insertUser(mccoProfiles[0]);
        
        // create ART site
        ART_Site_gne__c artSite = insertArtSite();
        
        ART_Team_gne__c artTeam = insertSampleArtTeam();
        
        // membership is not added

        System.runAs(mccoUser) {
            Test.startTest();

            PageReference mccoCreateartTeamPage = Page.GNE_MCCO_Create_ART_Team_Page;
            // put retUrl parameter
            mccoCreateartTeamPage.getParameters().put('retUrl', '/' + artSite.Id);
            Test.setCurrentPage(mccoCreateartTeamPage);
                
            GNE_MCCO_Create_ART_Team_Controller ctrl = new GNE_MCCO_Create_ART_Team_Controller(new ApexPages.Standardcontroller(artTeam));
                
            PageReference result = ctrl.canBeCreated();
            System.assertEquals(null, result);
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testMccoCreateArtTeamManagerUserNotMember(){
        // select manager MCCO profiles
        List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-MCCO%' AND (Name LIKE '%OPS%'
            OR Name LIKE '%Manager%' OR Name LIKE '%Leadership%') AND Name != 'GNE-MCCO-MCL-Manager'];
            
        // create user with manager MCCO profile
        User mccoUser = insertUser(mccoProfiles[0]);
        
        // create ART site
        ART_Site_gne__c artSite = insertArtSite();
        
        ART_Team_gne__c artTeam = insertSampleArtTeam();
        
        // membership is not added

        System.runAs(mccoUser) {
            Test.startTest();

            PageReference mccoCreateArtTeamPage = Page.GNE_MCCO_Create_ART_Team_Page;
            // put retUrl parameter
            mccoCreateArtTeamPage.getParameters().put('retUrl', '/' + artSite.Id);
            Test.setCurrentPage(mccoCreateArtTeamPage);
                
            GNE_MCCO_Create_ART_Team_Controller ctrl = new GNE_MCCO_Create_ART_Team_Controller(new ApexPages.Standardcontroller(artTeam));
                
            PageReference result = ctrl.canBeCreated();
            System.assertNotEquals(result, null);
            System.assertEquals(result.getUrl(), '/' + ((String)artTeam.get('Id')).subString(0, 3) + '/e?nooverride=0&retUrl=%2F' + artSite.Id);
            
            Test.stopTest();
        }
    }
}