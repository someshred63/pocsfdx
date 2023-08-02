/************************************************************
*  @author: Grzegorz Skaruz
*  Date: 2016-11-09
*  This is a test for GNE_SFA2_SBM_Export_Ctrl class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest

private class GNE_SFA2_SBM_Export_Ctrl_Test {

    static testMethod void testCtrlNoParam() {
		Test.startTest();
			GNE_SFA2_SBM_Export_Ctrl testCtrl = new GNE_SFA2_SBM_Export_Ctrl();
		Test.stopTest();
		system.assertEquals(testCtrl.docName, 'no-records.xls');
		system.assertEquals(testCtrl.SBMs.size(), 0);
		system.assertEquals(testCtrl.fieldNames, null);
		system.assertEquals(testCtrl.headerByApiName, null);
    }
    
    static testMethod void testCtrlWithParam() {
		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert bureau;
		Account a = new Account(Name = 'TestAccount1');
		insert a;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		Account b = new Account(Name = 'TestAccount2');
		insert b;
		Speaker_Bureau_Membership_gne__c sbm2 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Approved',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = b.Id
		);
		insert sbm2;
		
		ApexPages.currentPage().getParameters().put('br_id',bureau.Id);    
    		
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
    		
        SFA2_Configuration_Object_gne__c conf = new SFA2_Configuration_Object_gne__c(Attributes_gne__c='fieldsCSV=Name,Speaker_Status_gne__c;action=test;styleClass=test;dir=test;onclick=test;rerender=test1,test2;immediate=true;', 
        			Section_Header_gne__c='test',
                    Configuration_Type_gne__c = 'Page', Is_Active_gne__c = true, 
                    Object_Name_gne__c = 'Speaker_Bureau_gne__c', Role_gne__c = userApplicationContext.Role_gne__c,
                    Brand_gne__c = userApplicationContext.Brand_gne__c, Application_Type__c = userApplicationContext.App_Name_gne__c,
                    Record_Type_gne__c = ''
                    );
        insert conf;

        List<SFA2_Configuration_Object_Detail_gne__c> det = new List<SFA2_Configuration_Object_Detail_gne__c>();
        det.add(new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Speaker_Bureau_Membership_gne__c', Label_gne__c = 'button1', Attributes_gne__c = 'fieldsCSV=Name,Speaker_Status_gne__c;action=test;styleClass=test;dir=test;onclick=test;rerender=test1,test2;immediate=true;', Is_Required_gne__c = false,
                                                            Is_Read_Only_gne__c = true, Order_gne__c = 1.0, Type_gne__c = 'Related List', Style_gne__c=null,
                                                            Configuration_Object_ref_gne__c=conf.Id, Is_Active_gne__c=true));
        insert det;

		insert new GNE_SFA2_RelatedList_Limit__c(Name = 'GNE_SFA2_RelatedList_Limit',
												 GNE_SFA2_RelatedList_Limit__c = '70',
												 Page_Size_gne__c = 5
												 );

		Test.startTest();
			GNE_SFA2_SBM_Export_Ctrl testCtrl = new GNE_SFA2_SBM_Export_Ctrl();
		Test.stopTest();
		system.assertEquals(testCtrl.docName, 'SBM-List.xls');
		system.assertEquals(testCtrl.SBMs.size(), 2);
		system.assertEquals(testCtrl.SBMs.get(0).Speaker_Status_gne__c, 'Pending');
		system.assertEquals(testCtrl.SBMs.get(1).Speaker_Status_gne__c, 'Approved');
		system.assertEquals(testCtrl.fieldNames.size(), 2);		
		system.assertEquals(testCtrl.fieldNames.get(0), 'Name');		
		system.assertEquals(testCtrl.fieldNames.get(1), 'Speaker_Status_gne__c');		
		system.assertEquals(testCtrl.headerByApiName.size(), 2);		
		system.assertEquals(testCtrl.headerByApiName.get('Name'), 'Membership ID');		
		system.assertEquals(testCtrl.headerByApiName.get('Speaker_Status_gne__c'), 'Membership Status');		
    }
    
    static testMethod void testCtrlWithParamNoRecord() {
		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert bureau;
		Account a = new Account(Name = 'TestAccount1');
		insert a;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		Account b = new Account(Name = 'TestAccount2');
		insert b;
		Speaker_Bureau_Membership_gne__c sbm2 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Approved',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = b.Id
		);
		insert sbm2;
		
		ApexPages.currentPage().getParameters().put('br_id',bureau.Id);    
    		
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
    	
		Test.startTest();
			GNE_SFA2_SBM_Export_Ctrl testCtrl = new GNE_SFA2_SBM_Export_Ctrl();
		Test.stopTest();
		system.assertEquals(testCtrl.docName, 'SBM-List.xls');
		system.assertEquals(testCtrl.SBMs.size(), 2);
		system.assertEquals(testCtrl.fieldNames.size(), 1);		
		system.assertEquals(testCtrl.fieldNames.get(0), 'Name');		
		system.assertEquals(testCtrl.headerByApiName.size(), 1);		
		system.assertEquals(testCtrl.headerByApiName.get('Name'), 'Membership ID');		
    }    
}