@isTest
public class ART_Check_Membership_Test {
	
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
    
    private static ART_Issue_gne__c insertArtIssue(ART_Site_gne__c artSite) {
        ART_Issue_gne__c newArtIssue = new ART_Issue_gne__c(Name = 'Test issue', Issue_Status_gne__c = 'Open', ART_Site_Local_gne__c = artSite.Id, Matrix_Coordinate_gne__c = 'A3 - YELLOW' );
		insert newArtIssue;
		return newArtIssue;
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
    
	static TestMethod void testMccoRegularUserIsMember() {
		// select regular MCCO profiles
		List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-MCCO%' AND (NOT Name LIKE '%OPS%')
			AND (NOT Name LIKE '%Manager%') AND (NOT Name LIKE '%Leadership%') AND Name != 'GNE-MCCO-MCL-Manager'];
			
		// create user with regular MCCO profile
		User mccoUser = insertUser(mccoProfiles[0]);
		
		// create ART site
        ART_Site_gne__c artSite = insertArtSite();
		
		// add membership
        insertArtTeam(artSite, mccoUser);
		
		System.runAs(mccoUser) {
			// insert ART Issue
			Test.startTest();
			ART_Issue_gne__c artIssue = new ART_Issue_gne__c();
			artIssue.Name = 'Test issue';
			artIssue.Issue_Status_gne__c = 'Open';
			artIssue.ART_Site_Local_gne__c = artSite.Id;
			artIssue.Matrix_Coordinate_gne__c = 'A3 - YELLOW';
				
			try {
				insert artIssue;
			} catch(DMLException ex) {
				System.assert(false, ex.getMessage());
			}
				
			Test.stopTest();
		}
	}
	
	static TestMethod void testMccoRegularUserIsNotMember() {
		
		// select regular MCCO profiles
		List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-MCCO%' AND (NOT Name LIKE '%OPS%')
			AND (NOT Name LIKE '%Manager%') AND (NOT Name LIKE '%Leadership%') AND Name != 'GNE-MCCO-MCL-Manager'];
		
		// create user with regular MCCO profile
		User mccoUser = insertUser(mccoProfiles[0]);
		
		// create ART site
        ART_Site_gne__c artSite = insertArtSite();
		
		// membership is not added
			
		System.runAs(mccoUser) {
			// insert ART Issue
			Test.startTest();
			ART_Issue_gne__c artIssue = new ART_Issue_gne__c();
			artIssue.Name = 'Test issue';
			artIssue.Issue_Status_gne__c = 'Open';
			artIssue.ART_Site_Local_gne__c = artSite.Id;
			artIssue.Matrix_Coordinate_gne__c = 'A3 - YELLOW';
				
			try {
				insert artIssue;
				System.assert(false, 'Failure! Added ART Issue to a site, which user is not member of.');
			} catch(DMLException ex) {
				// record is not added - everything's ok
			}
				
			Test.stopTest();
		}
	}
	
	static TestMethod void testMccoManagerIsMember() {
		// select manager MCCO profiles
		List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-MCCO%' AND (Name LIKE '%OPS%'
			OR Name LIKE '%Manager%' OR Name LIKE '%Leadership%') AND Name != 'GNE-MCCO-MCL-Manager'];
			
		// create user with manager MCCO profile
		User mccoUser = insertUser(mccoProfiles[0]);
		
		// create ART site
        ART_Site_gne__c artSite = insertArtSite();
		
		// add membership
        insertArtTeam(artSite, mccoUser);
			
		System.runAs(mccoUser) {
			// insert ART Issue
			Test.startTest();
			ART_Issue_gne__c artIssue = new ART_Issue_gne__c();
			artIssue.Name = 'Test issue';
			artIssue.Issue_Status_gne__c = 'Open';
			artIssue.ART_Site_Local_gne__c = artSite.Id;
			artIssue.Matrix_Coordinate_gne__c = 'A3 - YELLOW';
			
			try {
				insert artIssue;
			} catch(DMLException ex) {
				System.assert(false, ex.getMessage());
			}
			
			Test.stopTest();
		}
	}
	
	static TestMethod void testMccoManagerUserIsNotMember() {
		
		// select regular MCCO profiles
		List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-MCCO%' AND (Name LIKE '%OPS%'
			OR Name LIKE '%Manager%' OR Name LIKE '%Leadership%') AND Name != 'GNE-MCCO-MCL-Manager'];
		
		// create user with manager MCCO profile
		User mccoUser = insertUser(mccoProfiles[0]);
		
		// create ART site
        ART_Site_gne__c artSite = insertArtSite();
		
		// membership is not added

		System.runAs(mccoUser) {
			// insert ART Issue
			Test.startTest();
			ART_Issue_gne__c artIssue = new ART_Issue_gne__c();
			artIssue.Name = 'Test issue';
			artIssue.Issue_Status_gne__c = 'Open';
			artIssue.ART_Site_Local_gne__c = artSite.Id;
			artIssue.Matrix_Coordinate_gne__c = 'A3 - YELLOW';
			
			try {
				insert artIssue;
				System.assert(false, 'Failure! Added ART Issue to a site, which user is not member of.');
			} catch(DMLException ex) {
				// record is not added - everything's ok
			}
			
			Test.stopTest();
		}
	}
}