/************************************************************
*  @author: Grzegorz Skaruz
*  Date: 2016-11-02
*  This is a test for GNE_SFA2_SBC_Profiler class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest

private class GNE_SFA2_SBC_Profiler_Test {

    @testSetup
    static void init() {
		insert new List<GNE_Foun_Misc_Config_Items_gne__c> {
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'Batch_FRM_Rep2TerritoryNotifyEmail', Configuration_Value_gne__c = 'example1@example.com'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianIDetailPageSize', Configuration_Value_gne__c = '60')
		};    	

		insert new List<GNE_Foun_Role_Ranking_gne__c> {
			new GNE_Foun_Role_Ranking_gne__c(Name = 'MD', Account_Professional_Type_gne__c = 'Medical Doctor', Role_Rank_gne__c = 1)
		};    	
    } 

    static testMethod void testlogStartNoPage() {
		PageReference pr = Page.GNE_SFA2_Acc_Plan_Pay_Layout;
		Test.setCurrentPage(pr);
		Test.startTest();
			GNE_SFA2_SBC_Profiler.logStart('testSquery');
	        GNE_SFA2_SBC_Profiler.logActionStart('test.PrepareResults');
	        GNE_SFA2_SBC_Profiler.setLogActionDescription('test.PrepareResults', 'sample error message');
	        GNE_SFA2_SBC_Profiler.logActionEnd('test.PrepareResults');
	        GNE_SFA2_SBC_Profiler.setSiperianResultSize(11);
	        GNE_SFA2_SBC_Profiler.setSiperianData(1, 2, 3, 4, 5, true);
	        GNE_SFA2_SBC_Profiler.logEnd();
		Test.stopTest();
        
		List<SFA2_SBC_Profiler_Log_gne__c> dbResult = [ 
			SELECT Execution_Time_gne__c, Location_gne__c, Name, Query_Rows_gne__c, Query_Statements_gne__c, Result_Size_gne__c,
				Search_Query_gne__c, Siperian_Data_calc_gne__c, Siperian_Result_Page_Count_gne__c, Siperian_Result_Page_Number_gne__c, 
				Siperian_Result_Page_Size_gne__c, Siperian_Result_Query_More_gne__c, Siperian_Result_Size_gne__c, Siperian_Result_Total_Size_gne__c 
			FROM SFA2_SBC_Profiler_Log_gne__c 
		];
		System.AssertEquals(dbResult.size(), 1); 
		System.AssertEquals(dbResult.get(0).Search_Query_gne__c, 'testSquery');
		System.AssertEquals(dbResult.get(0).Location_gne__c, '/apex/gne_sfa2_acc_plan_pay_layout');
		System.AssertEquals(dbResult.get(0).Siperian_Result_Size_gne__c, 1);
		System.AssertEquals(dbResult.get(0).Siperian_Result_Total_Size_gne__c, 2);
		System.AssertEquals(dbResult.get(0).Siperian_Result_Page_Number_gne__c, 3);
		System.AssertEquals(dbResult.get(0).Siperian_Result_Page_Size_gne__c, 4);
		System.AssertEquals(dbResult.get(0).Siperian_Result_Page_Count_gne__c, 5);
		System.AssertEquals(dbResult.get(0).Siperian_Result_Query_More_gne__c, true);
     }
}