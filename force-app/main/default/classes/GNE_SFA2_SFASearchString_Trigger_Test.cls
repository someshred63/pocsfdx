/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 1/7/2013
*  Description: This class GNE_SFA2_SFASearchString_Trigger_Test test class to test the triggers on SFASearchStrings_gne__c object
*  
*  Modification History
*  Date        Name             Description
*  2013/12/16  Piotr Przesmycki Fixed unit test and removed SeeAllData=true annotation
*  2014-02-17  Piotr Przesmycki Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*************************************************************/
@isTest
private class GNE_SFA2_SFASearchString_Trigger_Test {
    
    static testMethod void testSFASearchString() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(sfa2User){
			try{
				Test.StartTest();
					SFASearchStrings_gne__c sfaSearch = GNE_SFA2_Triggers_Test_Util.prepareSFASearchStrings_gne();
					sfaSearch.License_Number_gne__c = '12345';
					sfaSearch.License_State_gne__c 	= 'CA';
					sfaSearch.Mode_gne__c 			= 'License';
					insert sfaSearch;

					sfaSearch.License_State_gne__c = 'None';
					update sfaSearch;
					System.assert(false, 'Should not reach here');
				Test.stopTest();
			}catch (System.Exception e){
            	System.debug('EXCEPTION MESSAGE : '+e.getMessage());
            	System.assert(e.getMessage().contains(Label.GNE_SFA2_SFASreachString_LICENCE_STATE_Required), e.getMessage());
        	}
		}    
    }

    static testMethod void testSFASeatchStringJustForCoverage(){
    	/*insert and before update are tested in previous method. After update, before and after delete and undelete actions 
    	  doesn't contain any logic in trigger, so this method is just placeholder to achieve good coverage*/
    	User sfa2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(sfa2User){
			SFASearchStrings_gne__c sfaSearch = GNE_SFA2_Triggers_Test_Util.prepareSFASearchStrings_gne();
			insert sfaSearch;
			update sfaSearch;
			delete sfaSearch;
			undelete sfaSearch;
		}
    }
}