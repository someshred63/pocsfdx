@isTest
private class GNE_SFA2_Account_Delta_Dao_Test { 
    
    @isTest
    public static void test1(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		Address_vod__c add = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(acc.Id, 'abc', true, 'abc');
		insert add;

        GNE_SFA2_Account_Delta_Dao dao = new GNE_SFA2_Account_Delta_Dao(false);
		GNE_Account_Pager pager = new GNE_Account_Pager();
		//pager.currSearch.City_gne__c = 'NEW YORK';
		pager.CurrSearch.AccountType_gne__c = 'HCO';
		List<SFASearchStrings_gne__c> ab = dao.getByPager(pager);
		

    }



}