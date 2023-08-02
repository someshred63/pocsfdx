/* 
 * GNE_MCCO_CRM_Tools_And_Resources_Test
 *
 * Test for GNE_MCCO_CRM_Tools_And_Resources_Ctrl ApexClass
 *
 * Created By : Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 */
 //TODO: this test class has poor quality - it should be improved
@isTest 
private class GNE_MCCO_CRM_Tools_And_Resources_Test {
        
    static final String PROFILE_NAME    = 'GNE-MCCO-FRM-BFRM';
    static final String DOMAIN          = 'gene.com';
    static final String TERRITORY       = '007F106-NY/PA';
    
    private static User createUser(String name, Id profileId, Boolean toInsert) {
        User user = new User(
            Alias = 'standt',
            Email = name + 'user@veevasystems.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = name + 'user@veevasystems.com'
        );
        system.debug(user);
        if (toInsert) insert user;
        return user;
    }    
    
    private static void createTerritoryAssociation() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = :PROFILE_NAME ].Id;
        User u = createUser('example1', profileId, true);
        
        Territory2 t = [SELECT Id FROM Territory2 WHERE Name = :TERRITORY LIMIT 1];
        insert new UserTerritory2Association(
            Territory2Id = t.Id,
            UserId = u.Id
        );
    }    

    @testSetup 
	private static void init() {
		List<GNE_MCCO_CRM_Link__c> links = new List<GNE_MCCO_CRM_Link__c>();
		links.add(new GNE_MCCO_CRM_Link__c(Link_Name_gne__c='Test1', gConnect_Required_gne__c=false, Link_Url_gne__c='ww.test.com', Is_Application_gne__c=false, Available_for_Salesforce1_gne__c=true, Available_for_gne__c='BFRM,AM,PFRM'));
		links.add(new GNE_MCCO_CRM_Link__c(Link_Name_gne__c='Test2', gConnect_Required_gne__c=false, Link_Url_gne__c='ww.test2.com', Is_Application_gne__c=false, Available_for_Salesforce1_gne__c=true, Available_for_gne__c='BFRM,AM,PFRM'));
		links.add(new GNE_MCCO_CRM_Link__c(Link_Name_gne__c='Test Not Unique URL', gConnect_Required_gne__c=false, Link_Url_gne__c='ww.test.com', Is_Application_gne__c=false, Available_for_Salesforce1_gne__c=true, Available_for_gne__c='BFRM,AM,PFRM'));
		insert links;
		
		insert new GNE_SFA2_MCCO_CRM_Profiles__c(name='GNE-MCCO-FRM-BFRM');
	}
	
    /*
     * Test Constructor
     */
    private static testMethod void testConstructor() {
        
        createTerritoryAssociation();
        User testUser = GNE_MCCO_CRM_Test_Helper.getTestUser(PROFILE_NAME, TERRITORY);
        System.AssertNotEquals(testUser, null);

        Test.startTest();

            System.runAs(testUser) {
                GNE_MCCO_CRM_Tools_And_Resources_Ctrl controller = new GNE_MCCO_CRM_Tools_And_Resources_Ctrl();
            }
            
        Test.stopTest();
        
    }  
      
    /*
     * testGetFeedItems()
     * 
     * Test @RemoteAction getFeedItems()
     */
    private static testMethod void testGetFeedItems() {
        
        createTerritoryAssociation();
        User testUser = GNE_MCCO_CRM_Test_Helper.getTestUser(PROFILE_NAME, TERRITORY);
        System.AssertNotEquals(testUser, null);
        
        ConnectApi.FeedItemPage testPage = new ConnectApi.FeedItemPage();
        ConnectApi.FeedItem feedItem = new ConnectApi.FeedItem();
        ConnectApi.Comment comment = new ConnectApi.Comment();

        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(feedItem);
        testPage.items = testItemList;

        Test.startTest();
        
        	System.runAs(testUser) {

		//		ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed(null, ConnectApi.FeedType.News, 'me', testPage);
        //        List<GNE_MCCO_CRM_Tools_And_Resources_Ctrl.ChatterFeedItem> chatterFeedItems = GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getFeedItems();
                
        	}

        Test.stopTest();
        
    }
          
    /*
     * testGetUserAccounts()
     * 
     * Test @RemoteAction getUserAccounts(Integer displayLength, Integer displayStart, String search)
     */
    private static testMethod void testGetUserAccounts() {
        
        createTerritoryAssociation();
        User testUser = GNE_MCCO_CRM_Test_Helper.getTestUser(PROFILE_NAME, TERRITORY);
        System.AssertNotEquals(testUser, null);

        Test.startTest();

            System.runAs(testUser) {
                List<Account> accountList = GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getUserAccounts(50, 0, '', 'a');
                //GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getUserAccountDetails(accountList[0].Id);
            }

        Test.stopTest();
        
    }
                  
    /*
     * testGetUserAccounts()
     * 
     * Test @RemoteAction getLinkList(Boolean adminMode)
     */
    private static testMethod void testGetLinkList() {
        
        createTerritoryAssociation();
        User testUser = GNE_MCCO_CRM_Test_Helper.getTestUser(PROFILE_NAME, TERRITORY);
        System.AssertNotEquals(testUser, null);

        Test.startTest();

            System.runAs(testUser) {
                List<GNE_MCCO_CRM_Link__c> links = GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getLinkList(true);
                System.AssertEquals(3, links.size());
                
                links = GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getLinkList(false);
                System.AssertEquals(2, links.size());
            }

        Test.stopTest();
        
    }
                        
    /*
     * testGetUserAccounts()
     * 
     * Test @RemoteAction getSF1LinkList()
     */
    private static testMethod void testGetSF1LinkList() {
        
        createTerritoryAssociation();
        User testUser = GNE_MCCO_CRM_Test_Helper.getTestUser(PROFILE_NAME, TERRITORY);
        System.AssertNotEquals(testUser, null);

        Test.startTest();

            System.runAs(testUser) {
                GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getSF1LinkList();
            }

        Test.stopTest();
        
    }
              
    /*
     * testGetChatterGroupList()
     * 
     * Test @RemoteAction getChatterGroupList()
     */
    private static testMethod void testGetChatterGroupList() {
        
        createTerritoryAssociation();
        User testUser = GNE_MCCO_CRM_Test_Helper.getTestUser(PROFILE_NAME, TERRITORY);
        System.AssertNotEquals(testUser, null);

        Test.startTest();

            System.runAs(testUser) {
                List<CollaborationGroupMember> collaborationGroupMembers = GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getChatterGroupList();
            }
            
        Test.stopTest();
        
    }
                       
    /*
     * testGetUserLibraries()
     * 
     * Test @RemoteAction getUserLibraries()
     */
    private static testMethod void testGetUserLibraries() {
        
        createTerritoryAssociation();
        User testUser = GNE_MCCO_CRM_Test_Helper.getTestUser(PROFILE_NAME, TERRITORY);
        System.AssertNotEquals(testUser, null);

        Test.startTest();

            System.runAs(testUser) {
                List<GNE_MCCO_CRM_Tools_And_Resources_Ctrl.Library> libraries = GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getUserLibraries();
                //List<GNE_MCCO_CRM_Tools_And_Resources_Ctrl.LibraryContent> libraryContents = GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getUserLibraryContent(libraries[0].Id, 50, 0, 'a');
                //GNE_MCCO_CRM_Tools_And_Resources_Ctrl.LibraryContent libraryContent = GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getLibraryDetails(libraryContents[0].Id);
            }
            
        Test.stopTest();
        
    }

}