/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-28
*  Description: This is a test class for GNE_SFA2_Territory_Alignment_Ext class.
*
*  Modification History
*  Date        Name        			Description
*  27-08-2014  Lukasz Bieniawski	Tests rebuilded because of remote action methods being used in controller
*************************************************************/

@isTest
private class GNE_SFA2_Territory_Alignment_Ext_Test {

	private static String MASK_SFA2_PROFILES = 'GNE-SFA%';
	private static String MASK_MEDAFFAIR_PROFILES = 'GNE-MedAffairs-%';

	static testMethod void loadControllerDataTest(){
		User sfa2User = selectUser(MASK_SFA2_PROFILES);
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				PageContext pageContext = new PageContext(true);
				GNE_SFA2_Territory_Alignment_Ext pageController = pageContext.initPageController();
				system.assertEquals(pageContext.accountId, pageController.accountId);
				system.assertEquals(pageContext.isPersonAccount, pageController.isPersonAccount);
				Test.startTest();
				GNE_SFA2_Territory_Alignment_Ext.ControllerData remoteActionResult = pageContext.loadControllerData();
				Test.stopTest();
				system.assertEquals(pageContext.userContext.userTerritoriesMap.size(), remoteActionResult.territoryToAccountAlignmentSortedList.size());
				system.assertEquals(true, remoteActionResult.columnDescriptions.size() > 1);
				system.assertEquals(true, remoteActionResult.columnDescriptions.containsKey(0)); // Territory Name
			}
		}
	}

	static testMethod void setAlignedInMyViewTest(){
		User sfa2User = selectUser(MASK_SFA2_PROFILES);
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				PageContext pageContext = new PageContext(true);
				Territory2 territory = pageContext.getFirstUserTerritory();
				if (territory != null){
					Boolean hasBrandAffiliationToInsert = pageContext.hasBrandAffiliationToInsert(territory.Name);
					Test.startTest();
					GNE_SFA2_Territory_Alignment_Ext.AlignmentRemoteActionResult remoteActionResult = pageContext.setAlignedInMyView(territory.Id, territory.Name);
					Test.stopTest();
					system.assertEquals(territory.Name, remoteActionResult.territoryName);
					system.assertEquals(false, remoteActionResult.infoMessages.isEmpty());
					system.assertEquals(hasBrandAffiliationToInsert, remoteActionResult.hasBrandAffiliationChanged);
					checkAfterAlignment(pageContext.accountId, territory, true, false);
				}
			}
		}
	}

	static testMethod void setAlignedInAllViewTest(){
		User sfa2User = selectUser(MASK_SFA2_PROFILES);
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				PageContext pageContext = new PageContext(true);
				Territory2 territory = pageContext.getFirstUserTerritory();
				if (territory != null){
					Boolean hasBrandAffiliationToInsert = pageContext.hasBrandAffiliationToInsert(territory.Name);
					Test.startTest();
					GNE_SFA2_Territory_Alignment_Ext.AlignmentRemoteActionResult remoteActionResult = pageContext.setAlignedInAllView(territory.Id, territory.Name);
					Test.stopTest();
					system.assertEquals(territory.Name, remoteActionResult.territoryName);
					system.assertEquals(false, remoteActionResult.infoMessages.isEmpty());
					system.assertEquals(hasBrandAffiliationToInsert, remoteActionResult.hasBrandAffiliationChanged);
					checkAfterAlignment(pageContext.accountId, territory, false, false);
				}
			}
		}
	}

	static testMethod void setNotAlignedSFATest(){
		setNotAlignedTest(MASK_SFA2_PROFILES);
	}

	static testMethod void setNotAlignedMedAffairsTest(){
		setNotAlignedTest(MASK_MEDAFFAIR_PROFILES);
	}

	static testMethod void setAlignedInMyViewErrorHandlingTest(){
		User sfa2User = selectUser(MASK_SFA2_PROFILES);
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				PageContext pageContext = new PageContext(true);
				GNE_SFA2_Territory_Alignment_Ext.AlignmentRemoteActionResult remoteActionResult = pageContext.setAlignedInMyView(null, null);
				system.assertNotEquals(null, remoteActionResult.retURL);
				system.assertEquals(true, remoteActionResult.retURL.startsWithIgnoreCase(Page.GNE_SFA2_Exception_Layout.getUrl()));
			}
		}
	}

	static testMethod void setAlignedInAllViewErrorHandlingTest(){
		User sfa2User = selectUser(MASK_SFA2_PROFILES);
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				PageContext pageContext = new PageContext(true);
				GNE_SFA2_Territory_Alignment_Ext.AlignmentRemoteActionResult remoteActionResult = pageContext.setAlignedInAllView(null, null);
				system.assertNotEquals(null, remoteActionResult.retURL);
				system.assertEquals(true, remoteActionResult.retURL.startsWithIgnoreCase(Page.GNE_SFA2_Exception_Layout.getUrl()));
			}
		}
	}

	private static void setNotAlignedTest(String profileMask){
		User testUser = selectUser(profileMask);
		if(testUser != null) {
			System.runAs(testUser) {
				PageContext pageContext = new PageContext(true);
				Territory2 territory = pageContext.getFirstUserTerritory();
				if (territory != null){
					GNE_SFA2_Territory_Alignment_Ext.ControllerData remoteLoadActionResult = pageContext.loadControllerData();
					GNE_SFA2_Territory_Alignment_Ext.AccountAlignmentItem alignmentItem = pageContext.getAccountAlignmentItem(remoteLoadActionResult, territory.Id);
					GNE_SFA2_Territory_Alignment_Ext.AlignmentRemoteActionResult remoteAlignedActionResult = pageContext.setAlignedInMyView(territory.Id, territory.Name);
					Test.startTest();
					GNE_SFA2_Territory_Alignment_Ext.AlignmentRemoteActionResult remoteUnalignedActionResult = pageContext.setNotAligned(territory.Id, territory.Name, alignmentItem.editMode);
					Test.stopTest();
					system.assertEquals(territory.Name, remoteUnalignedActionResult.territoryName);
					if (alignmentItem.editMode == true){
						system.assertEquals(false, remoteUnalignedActionResult.infoMessages.isEmpty());
						checkAfterAlignment(pageContext.accountId, territory, null, true);
					}
				}
			}
		}
	}

	private static void checkAfterAlignment(Id accountId, Territory2 territory, Boolean inMyView, Boolean isUnaligned){
		if (isUnaligned){
			system.assertEquals(true, [SELECT Id FROM TSF_vod__c WHERE Account_vod__c = :accountId AND Territory_vod__c = :territory.Name].isEmpty());
		} else {
			system.assertEquals(false, [SELECT id FROM TSF_vod__c WHERE Account_vod__c = :accountId AND Territory_vod__c = :territory.Name
				AND My_Target_vod__c = :inMyView AND Is_Self_Alignment_gne__c = true].isEmpty());
		}
		system.assertEquals(isUnaligned, GNE_SFA2_Territory_Alignment_Ext.getAccountShares(GNE_SFA2_Territory_Alignment_Helper.getGroupId(territory.Id), accountId).isEmpty());
	}

	public static User selectUser(String profileMask) {
		User testUser = null;
		List<User> testUsers = [SELECT Id FROM User WHERE Profile.Name LIKE :profileMask AND Profile.Name <> 'GNE-SFA-Ops' AND IsActive = true
			AND Id In (SELECT UserId FROM UserTerritory2Association) LIMIT 1];
		if (!testUsers.isEmpty()){
			testUser = testUsers[0];
		}
		return testUser;
    }

	private class PageContext {
		public Id accountId { get; private set; }
		public Boolean isPersonAccount { get; private set; }
		public Account account { get; private set; }
		public GNE_SFA2_Territory_Alignment_Ext.UserContext userContext { get; private set; }

		public PageContext(Boolean hcoAccountContext){
			this.prepareAccount(hcoAccountContext);
			this.userContext = new GNE_SFA2_Territory_Alignment_Ext.UserContext();
		}

		private void prepareAccount(Boolean hcoAccountContext){
			if (hcoAccountContext == true){
				this.account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
				this.isPersonAccount = false;
			} else {
				this.account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('test');
				this.isPersonAccount = true;
			}
			insert this.account;
			this.accountId = this.account.Id;
		}

		public GNE_SFA2_Territory_Alignment_Ext initPageController(){
			return new GNE_SFA2_Territory_Alignment_Ext(new ApexPages.StandardController(this.account));
		}

		public GNE_SFA2_Territory_Alignment_Ext.ControllerData loadControllerData(){
			return GNE_SFA2_Territory_Alignment_Ext.loadControllerData(this.accountId, this.isPersonAccount);
		}

		public GNE_SFA2_Territory_Alignment_Ext.AlignmentRemoteActionResult setAlignedInMyView(Id territoryId, String territoryName){
			return GNE_SFA2_Territory_Alignment_Ext.setAlignedInMyView(this.accountId, territoryId, territoryName);
		}

		public GNE_SFA2_Territory_Alignment_Ext.AlignmentRemoteActionResult setAlignedInAllView(Id territoryId, String territoryName){
			return GNE_SFA2_Territory_Alignment_Ext.setAlignedInAllView(this.accountId, territoryId, territoryName);
		}

		public GNE_SFA2_Territory_Alignment_Ext.AlignmentRemoteActionResult setNotAligned(Id territoryId, String territoryName, Boolean editMode){
			return GNE_SFA2_Territory_Alignment_Ext.setNotAligned(this.accountId, territoryId, territoryName, editMode);
		}

		public GNE_SFA2_Territory_Alignment_Ext.AccountAlignmentItem getAccountAlignmentItem(GNE_SFA2_Territory_Alignment_Ext.ControllerData controllerData, Id territoryId){
			GNE_SFA2_Territory_Alignment_Ext.AccountAlignmentItem result = null;
			for (GNE_SFA2_Territory_Alignment_Ext.AccountAlignmentItem item : controllerData.territoryToAccountAlignmentSortedList){
				if (item.territoryId == territoryId){
					result = item;
					break;
				}
			}
			return result;
		}

		public Boolean hasBrandAffiliationToInsert(String territoryName){
			return GNE_SFA2_Territory_Alignment_Ext.getBrandAffiliationsToInsert(this.accountId, territoryName).size() > 0;
		}

		public Territory2 getFirstUserTerritory(){
			Territory2 territory = null;
			if (this.userContext.userTerritoriesMap.size() > 0){
				territory = this.userContext.userTerritoriesMap.values()[0];
			}
			return territory;
		}
	}
}