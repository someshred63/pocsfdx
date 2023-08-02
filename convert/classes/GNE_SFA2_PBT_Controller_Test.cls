/**
*  @author: Przemek Giszczak
*  Date: 2014-09-09
*  This is a test class for GNE_SFA2_PBT_Controller
*
*  Modification History
*  Date        Name        Description
 */
@isTest
public with sharing class GNE_SFA2_PBT_Controller_Test {

	static testMethod void test_GNE_SFA2_PBT_Controller() {
		GNE_SFA2_PBT_Controller pbtc = new GNE_SFA2_PBT_Controller();
		pbtc.objectType = 'SFA2_PFG_to_Territory_Detail_gne__c';

		pbtc.editEnabled = true;
		pbtc.deleteEnabled = true;
		pbtc.columnNamesInString = 'Name[label=test;link=Id],Territory_Number_gne__c[label=test;label=test2],Expiration_Date_gne__c[label=test],Product_gne__r.NDC_Number_gne__c[label=NDC],Merged_gne__c[label=test]';
		pbtc.actionListInString = 'action1[label=testLabel;href=testHref],action2[label=testLabel;href=testHref]';
		pbtc.pageNumber = 1;
		pbtc.pageSize = 1;
		pbtc.isAllSelected = false;
		pbtc.sortColumn = 'Name';

		Product_vod__c prod = new Product_vod__c();
		insert prod;
		List<Territory2> terr =  [SELECT Id FROM Territory2 LIMIT 1];
		SFA2_PFG_to_Territory_Detail_gne__c terrRec = new SFA2_PFG_to_Territory_Detail_gne__c( Merged_gne__c = true, Distribution_Method_gne__c = 'DTP', Product_gne__c = prod.Id, Territory_gne__c = terr[0].Id, Territory_Number_gne__c = 'test', Expiration_Date_gne__c = Date.newInstance(2015, 01, 01), Year_gne__c = 2015 );
		insert terrRec;
		pbtc.inputRecords = new List<SObject>();
		pbtc.inputRecords.add( terrRec );

		System.assertEquals( null, pbtc.loadRecords() );
		System.assertEquals( null, pbtc.checkAll() );

		System.assertEquals( false, pbtc.records[0].selected );
		System.assertEquals( 0, pbtc.records[0].compareTo( pbtc.records[0] ) );

		pbtc.sortColumn = 'Merged_gne__c';
		pbtc.loadRecords();
		System.assertEquals( 0, pbtc.records[0].compareTo( pbtc.records[0] ) );

		pbtc.changeSorting();
		System.assertEquals( null, pbtc.changeSorting() );
		System.assertEquals( null, pbtc.checkAll() );

		pbtc.nextPage();
		pbtc.previousPage();
		System.assertEquals( 1, pbtc.pageNumber );


		Set<Id> selectedRecords = new Set<Id>();
		selectedRecords.add( terrRec.Id );

		GNE_SFA2_PBT_Controller.ListenerEngine le = new GNE_SFA2_PBT_Controller.ListenerEngine();
		le.connectTo( pbtc );
		le.setSelectedRecords( selectedRecords );
		le.setSelectedRecords( selectedRecords, true );

		System.assertEquals( 0, le.getSelectedRecords().size() );
		System.assertEquals( null, le.getColumnValueForRecord( terrRec, 'test' ) );
		System.assertEquals( '/TBD?Id=' + terrRec.Id , le.getCustomActionLink( 'test', terrRec ) );
	}

}