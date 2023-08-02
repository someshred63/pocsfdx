/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-08-19
*  Description: This is a test class for GNE_SFA2_TSF_Trigger trigger.
*
*  Modification History
*  Date        Name        			Description
*  2013/12/16  Piotr Przesmycki 	Fixed unit test
*  2014-02-13  Piotr Przesmycki 	Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*  2014-12-03  Mateusz Michalczyk  	Added after delete logic test for OTR_Deleted_Record_gne__c record creation. (testTSFOTRDeletedRecordCreation)
*************************************************************/
@isTest
public with sharing class GNE_SFA2_TSF_Trigger_Test {
    private static Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();

	public static final String TERRITORY_NAME = 'N1111-NEW YORK CITY_TEST';
	public static final String TERRITORY_NAME2 = 'N2222-NEW YORK CITY_TEST';

	public static final String HCP_NAME = 'Smith';
	public static final String HCP_NAME2 = 'Clark';

	@testSetup static void setup() {
		User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		GNE_SFA2_Util.switchAdminMode(false);
		Territory2 territory = GNE_SFA2_Triggers_Test_Util.prepareTerritory(TERRITORY_NAME);
		Territory2 territory2 = GNE_SFA2_Triggers_Test_Util.prepareTerritory(TERRITORY_NAME2);
		system.runAs(u){
			insert new List<Territory2>{territory, territory2};
		}
		Account a = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP(HCP_NAME);
		Account a2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP(HCP_NAME2);
		insert new List<Account>{a, a2};
	}

	public static testMethod void testLastInteractionDate() {
		Territory2 territory = getTerritory(TERRITORY_NAME);
		Account acc = getAccount(HCP_NAME);
        
        User testUser = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('System Administrator'), true);
        
        System.runAs(testUser) {

            Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc.Id, TERRITORY_NAME, Date.today(), true);
            Call2_vod__c call2 = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc.Id, TERRITORY_NAME, Date.today().addDays(-10), true);
            Call2_vod__c call3 = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc.Id, TERRITORY_NAME, Date.today().addDays(10), false);
    
            insert new List<Call2_vod__c>{call, call2, call3};


            Test.startTest();
                
            	insert new TSF_vod__c(Account_vod__c = acc.id, Territory_vod__c = territory.name);               
                
            Test.stopTest();
        }
        TSF_vod__c tsfs = [Select Id, Name, Account_vod__c, Territory_vod__c, Last_Interaction_Date_gne__c from TSF_vod__c WHERE Territory_vod__c = :territory.name AND Account_vod__c = :acc.Id];
            
        System.assertEquals(Date.today(), tsfs.Last_Interaction_Date_gne__c);
	}

	public static testMethod void testLastInteractionDate2() {
		Territory2 territory = getTerritory(TERRITORY_NAME);
		Territory2 territory2 = getTerritory(TERRITORY_NAME2);
		Account acc = getAccount(HCP_NAME);
		Account acc2 = getAccount(HCP_NAME2);
        
        User testUser = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('System Administrator'), true);
        TSF_vod__c tsf_acc1_terr1; 
        TSF_vod__c tsf_acc1_terr2; 
        
        TSF_vod__c tsf_acc2_terr1; 
        TSF_vod__c tsf_acc2_terr2;
        
        System.runAs(testUser) {

            Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc.Id, TERRITORY_NAME, Date.today(), true);
            Call2_vod__c call2 = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc.Id, TERRITORY_NAME, Date.today().addDays(-10), true);
            Call2_vod__c call3 = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc.Id, TERRITORY_NAME, Date.today().addDays(10), false);
            Call2_vod__c call4 = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc.Id, TERRITORY_NAME2, Date.today().addDays(10), false);
    
            ///
    
            Call2_vod__c call5 = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc2.Id, TERRITORY_NAME, Date.today(), true);
            Call2_vod__c call7 = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc2.Id, TERRITORY_NAME, Date.today().addDays(10), false);
            Call2_vod__c call6 = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc2.Id, TERRITORY_NAME2, Date.today().addDays(-10), true);
            Call2_vod__c call8 = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod(acc2.Id, TERRITORY_NAME2, Date.today(), true);
    
            insert new List<Call2_vod__c>{call, call2, call3, call4, call5, call6, call7, call8};
    
            Test.startTest();
    
                tsf_acc1_terr1 = new TSF_vod__c(Account_vod__c = acc.id, Territory_vod__c = territory.name);
                tsf_acc1_terr2 = new TSF_vod__c(Account_vod__c = acc.id, Territory_vod__c = territory2.name);
        		tsf_acc2_terr1 = new TSF_vod__c(Account_vod__c = acc2.id, Territory_vod__c = territory.name);
                tsf_acc2_terr2 = new TSF_vod__c(Account_vod__c = acc2.id, Territory_vod__c = territory2.name);
        
                List<TSF_vod__c> tsfes = new List<TSF_vod__c>{tsf_acc1_terr1, tsf_acc1_terr2, tsf_acc2_terr1, tsf_acc2_terr2};

                insert tsf_acc1_terr1;
                insert tsf_acc1_terr2;
                insert tsf_acc2_terr1;
                insert tsf_acc2_terr2;
            
            Test.stopTest();
        }

		List<TSF_vod__c> tsfs = [Select Id, Name, Account_vod__c, Territory_vod__c, Last_Interaction_Date_gne__c from TSF_vod__c];
		for(TSF_vod__c tsf: tsfs) {
			if(tsf.Account_vod__c == tsf_acc1_terr1.Account_vod__c && tsf.Territory_vod__c == tsf_acc1_terr1.Territory_vod__c){
				system.assertEquals(Date.today(), tsf.Last_Interaction_Date_gne__c);
			} else if(tsf.Account_vod__c == tsf_acc1_terr2.Account_vod__c && tsf.Territory_vod__c == tsf_acc1_terr2.Territory_vod__c){
				system.assertEquals(null, tsf.Last_Interaction_Date_gne__c);
			} else if(tsf.Account_vod__c == tsf_acc2_terr1.Account_vod__c && tsf.Territory_vod__c == tsf_acc2_terr1.Territory_vod__c){
				system.assertEquals(Date.today(), tsf.Last_Interaction_Date_gne__c);
			} else if(tsf.Account_vod__c == tsf_acc2_terr2.Account_vod__c && tsf.Territory_vod__c == tsf_acc2_terr2.Territory_vod__c){
				system.assertEquals(Date.today(), tsf.Last_Interaction_Date_gne__c);
			}
		}
		
	}

	public static testMethod void testExternalIdFieldUpdate() {
		Territory2 territory = getTerritory(TERRITORY_NAME);
		Account acc = getAccount(HCP_NAME);

		List<TSF_vod__c> tsfs = GNE_SFA2_TSF_Test_Helper.insertTestTSFs(null, new Map<String, Object>{'Account_vod__c' => acc.Id, 'Territory_vod__c' => territory.Name});

		tsfs = [Select Id, Name, Account_vod__c, Territory_vod__c, External_Id_vod__c from TSF_vod__c];

		for(TSF_vod__c tsf : tsfs){
			System.assertEquals(tsf.Account_vod__c+'__'+tsf.Territory_vod__c, tsf.External_Id_vod__c);
		}

		update tsfs;
		tsfs = [Select Id, Name, Account_vod__c, Territory_vod__c, External_Id_vod__c from TSF_vod__c];

		for(TSF_vod__c tsf : tsfs){
			System.assertEquals(tsf.Account_vod__c+'__'+tsf.Territory_vod__c, tsf.External_Id_vod__c);
		}
    }

    public static testMethod void testDuplicateTsfEntryInsert() {
		Territory2 territory = getTerritory(TERRITORY_NAME);
		Account acc = getAccount(HCP_NAME);

		List<TSF_vod__c> tsfs = GNE_SFA2_TSF_Test_Helper.insertTestTSFs(null, new Map<String, Object>{'Account_vod__c' => acc.Id, 'Territory_vod__c' => territory.Name});
		try {
			List<TSF_vod__c> tsfsDuplicate = GNE_SFA2_TSF_Test_Helper.insertTestTSFs(null, new Map<String, Object>{'Account_vod__c' => acc.Id, 'Territory_vod__c' => territory.Name});		
		}
		catch (DMLException ex) {
            System.assert(true, ex.getMessage().contains('DUPLICATE_VALUE'));
        }
    }


	public static testMethod void testTSFOTRDeletedRecordCreation() {

		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		system.runAs(sfa2User){
			Account acc = new Account(name= 'testAcc');
			insert acc;
			TSF_vod__c tsf = GNE_SFA2_Triggers_Test_Util.prepareTSF_vod(acc.id);
			insert tsf;
			Test.startTest();
				try{
					delete tsf;
				} catch (DmlException e ){
					System.assert(false, 'TSF deletion failed');
				}
			Test.stopTest();
		}
		String nameOfDeletedObject = GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(TSF_vod__c.getSObjectType());
		List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Object_name__c LIKE :nameOfDeletedObject];
		System.assertEquals(1, deletedRecords.size());
	}

	private static Territory2 getTerritory(String name) {
		return [SELECT id, Name FROM Territory2 WHERE name = :name LIMIT 1].get(0);
	}

	private static Account getAccount(String lastName) {
		return [SELECT id, Name FROM Account WHERE lastName = :lastName LIMIT 1];
	}
}