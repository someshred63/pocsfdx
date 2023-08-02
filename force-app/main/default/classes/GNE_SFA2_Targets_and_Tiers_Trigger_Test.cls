/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/12/2012
*  Description: This class GNE_SFA2_Targets_and_Tiers_Trigger_Test test class to test the triggers on Targets_and_Tiers_can_gne__c object
*  
*  Modification History
*  Date        Name                 Description
*  2013/12/16  Piotr Przesmycki     Unit test fix    
*  2014-02-14  Piotr Przesmycki 	Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data  
*  2014-12-03   Mateusz Michalczyk  Added after delete logic test for OTR_Deleted_Record_gne__c record creation.         
*************************************************************/

@isTest
private class GNE_SFA2_Targets_and_Tiers_Trigger_Test {
	
	static testMethod void testUpdateTSF() {
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(sfa2User){ 
	        try{
                insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-Canada');
		    	Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Test Account');
                insert acc;
		    	TSF_vod__c tsf = GNE_SFA2_Triggers_Test_Util.prepareTSF_vod(acc.Id);
		    	tsf.Territory_vod__c 	= '00X3607-SPOKANE-STD';
		    	tsf.External_Id_vod__c 	= acc.id+'__00X3607-SPOKANE-STD';
		    	insert tsf;
		    	System.assert(tsf.id != null, 'TSF insert failed');
		    	Targets_and_Tiers_can_gne__c tnt = GNE_SFA2_Triggers_Test_Util.prepareTargets_and_Tiers_can_gne();
		    	tnt.Territory_gne__c 	= '00X3607-SPOKANE-STD';
		    	tnt.Account_can_gne__c 	= acc.id;
		    	tnt.My_Target_gne__c 	= 'true';
		    	insert tnt;
		    	System.assert(tnt.id != null, 'Targets and Tiers is not created');
		    	update tnt;
		    	
		    	List<TSF_vod__c> qtsf = [select id, My_Target_vod__c from TSF_vod__c where id =: tsf.Id];
		    	System.assert(qtsf[0].My_Target_vod__c == false, 'TSF should be updated with my Target as false, because there is no assosiated product.');
		    	
		    	delete tnt;
		    	undelete tnt;
	        }catch(Exception e){
	            System.debug(e.getMessage());
	            System.assert(false, e.getMessage());
	        }
        }
    }

    static testMethod void testORDDeletedRecordsCreation(){
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(sfa2User){ 
            try{
                Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Test Account');
                insert acc;
                Targets_and_Tiers_can_gne__c tnt = GNE_SFA2_Triggers_Test_Util.prepareTargets_and_Tiers_can_gne();
                tnt.Account_can_gne__c  = acc.id;
                insert tnt;
                Test.startTest();
                    delete tnt;
                Test.stopTest();
            }catch(Exception e){
                System.debug(e.getMessage());
                System.assert(false, e.getMessage());
            }
        }
        String nameOfDeletedObject =GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(Targets_and_Tiers_can_gne__c.getSObjectType());
        List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Object_name__c LIKE :nameOfDeletedObject];
        System.assertEquals(1, deletedRecords.size());
    }
	
	/*private static String profileCanadaMask = 'RCanada-SFA%';
    
    static testMethod void insertTntNotMyTargetTest(){
    	UserContext userContext = new UserContext(profileCanadaMask);    	
    	if (userContext.userData == null){
    		return;
    	}
    	System.runAs(userContext.userData){    		
    		insertAppContext(userContext.userData);
    		Account account = insertAccountHCP();
    		TSF_vod__c tsf = insertTSF(account, userContext.userFirstTerritory);
    		
    		Test.startTest();
    		Targets_and_Tiers_can_gne__c tnt = insertTNT(tsf, false);
    		Test.stopTest();
    		
    		List<TSF_vod__c> qtsf = [select id, My_Target_vod__c from TSF_vod__c where id =: tsf.Id];
		    System.assert(qtsf[0].My_Target_vod__c == false, 'TSF should be updated with my Target as false.');
    	}
    }
    
    static testMethod void insertTntMyTargetTest(){
    	UserContext userContext = new UserContext(profileCanadaMask);    	
    	if (userContext.userData == null){
    		return;
    	}
    	System.runAs(userContext.userData){    		
    		insertAppContext(userContext.userData);
    		Account account = insertAccountHCP();
    		TSF_vod__c tsf = insertTSF(account, userContext.userFirstTerritory);
    		
    		Test.startTest();
    		Targets_and_Tiers_can_gne__c tnt = insertTNT(tsf, true);
    		Test.stopTest();
    		
    		List<TSF_vod__c> qtsf = [select id, My_Target_vod__c from TSF_vod__c where id =: tsf.Id];
		    System.assert(qtsf[0].My_Target_vod__c == true, 'TSF should be updated with my Target as true.');
    	}
    }
    
    private static Targets_and_Tiers_can_gne__c insertTNT(TSF_vod__c tsf, Boolean myTarget){
    	Product_vod__c product = new Product_vod__c(
    		Name = 'Test product'
    	);
    	insert product;
    	System.assert(product.Id != null, 'Product has not been created.');
    	
    	Targets_and_Tiers_can_gne__c tnt = new Targets_and_Tiers_can_gne__c(
    		Territory_gne__c = tsf.Territory_vod__c,
    		Account_can_gne__c = tsf.Account_vod__c,
    		Product_Catalog_gne__c = product.id,
    		My_Target_gne__c = myTarget ? 'Low' : null
    	);
		insert tnt;
		System.assert(tnt.Id != null, 'Target and Tier has not been created.');
		
		return tnt;
    }
    
    private static TSF_vod__c insertTSF(Account account, Territory territory){
    	TSF_vod__c tsf = new TSF_vod__c(
    		Account_vod__c = account.Id,
    		Address_vod__c = account.Main_Address_gne__c,    		
    		Territory_vod__c = territory.Name,
    		External_Id_vod__c = account.id + '__' + territory.Name
    	);
    	insert tsf;    	
    	System.assert(tsf.Id != null, 'Tsf has not been created.');
    	return tsf;
    }
    
    private static Account insertAccountHCP(){    	
    	Account account = new Account(
    		LastName = 'Test Account'
    	);
    	insert account;
    	System.assert(account.Id != null, 'Account has not been created.');
    	
    	Address_vod__c address = new Address_vod__c(
    		Account_vod__c = account.Id,
    		Address_1_gne__c = '611 Gateway Blvd',
			Active_Flag_gne__c = true,
			Primary_vod__c = true,
			Name = 'primaryTestAddress'
		);    	 
    	insert address;
    	System.assert(address.Id != null, 'Address has not been created.');
    	
    	account.Main_Address_gne__c = address.Id;
    	    	
    	return account;
    }
    
    private static void insertAppContext(User sfa2User){
    	GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(
    		Run_in_SFA2_UI_gne__c = true,
    		SFA2_Mode_gne__c = true, 
    		App_Name_gne__c = sfa2User.Profile.Name.containsIgnoreCase('Canada') ? 'SFA-Canada' : 'SFA-US'
    	);
    	insert appContext;
    	System.assert(appContext.Id != null, 'User context has not been created.');
    }
    
    private class UserContext {
    	public User userData { get; private set; }
    	public Territory userFirstTerritory { get; private set; }
    	
    	public UserContext(String profileMask){
    		this.userData = selectUser(profileMask);
    		this.userFirstTerritory = selectUserFirstTerritory(this.userData);
    	}
    	
    	private User selectUser(String profileMask) {
			List<User> testUsers = [SELECT Id, Profile.Name FROM User WHERE Profile.Name LIKE :profileMask AND IsActive = true AND Id In (SELECT UserId FROM UserTerritory Where IsActive = true) LIMIT 1];
			return testUsers.isEmpty() ? null : testUsers[0];
    	}
    	
    	private Territory selectUserFirstTerritory(User user){
    		return [Select Id, Name From Territory Where Id In (Select TerritoryId From UserTerritory Where UserId = :user.Id And IsActive = true) LIMIT 1];
    	}
    }*/
}