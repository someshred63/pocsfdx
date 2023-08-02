@isTest(seeAllData=false)
private class CFAR_Address_Book_Dispatcher_Test {

    static testMethod void testEnteringABByAverageUser() {
    	User avgUsr = CFAR_TestUtils.createTestAverageUser();
    	//operations on user and other objects can't be done by the same user in one context, so IT Admin is needed to overcome this
    	User itAdm = CFAR_TestUtils.createTestITAdminUser();
    	PageReference pRef = Page.CFAR_Address_Book_Dispatcher;
        Test.setCurrentPage(pRef);
        //test retUrl
        ApexPages.currentPage().getParameters().put('retURL', '/apex/CFAR_Trial');
        Test.startTest();
        	/* 1. tests for user without contact */
        	System.runAs(avgUsr){
        		CFAR_Address_Book_Dispatcher cabd = new CFAR_Address_Book_Dispatcher();
        		//must call getTargetUrl() method few times to check assertions
        		System.assert(cabd.getTargetUrl().getURL().startsWith('/apex/CFAR_AddressBookNew'));
        		System.assertEquals(null, cabd.getTargetUrl().getParameters().get('id'));
        		System.assertEquals('/apex/CFAR_Trial', cabd.getTargetUrl().getParameters().get('retURL'));	
        	}
        	/* 2. tests for user with contact */
        	CFAR_Contact_gne__c cntForAvgUsr;
        	System.runAs(itAdm){
        		cntForAvgUsr = CFAR_TestUtils.createTestPrimaryContact();
        		cntForAvgUsr.User_ref_gne__c = avgUsr.Id;
        		update cntForAvgUsr;
        	}
        	System.runAs(avgUsr){
        		CFAR_Address_Book_Dispatcher cabd = new CFAR_Address_Book_Dispatcher();
        		System.assertEquals(String.valueOf(cntForAvgUsr.Id), cabd.getTargetUrl().getParameters().get('id'));
        	}
        Test.stopTest();
    }
    
    static testMethod void testEnteringABByAdminUser() {
        User adm = CFAR_TestUtils.createTestAdminUser();
        System.runAs(adm){
        	Test.startTest();
        		CFAR_Address_Book_Dispatcher cabd = new CFAR_Address_Book_Dispatcher();
        		System.assertEquals(null, cabd.getTargetUrl().getParameters().get('id'));
        		CFAR_Contact_gne__c cntForAdminUsr = CFAR_TestUtils.createTestAdminContact();
        		cntForAdminUsr.User_ref_gne__c = adm.Id;
        		update cntForAdminUsr;
        		cabd = new CFAR_Address_Book_Dispatcher();
        		//for admins don't redirect to contact view (only for AVG and RO (incl. MSL))
        		System.assertEquals(null, cabd.getTargetUrl().getParameters().get('id'));
        	Test.stopTest();
        }
    }
    
    static testMethod void testEnteringABByITAdminUser() {
        User itAdm = CFAR_TestUtils.createTestITAdminUser();
        System.runAs(itAdm){
        	Test.startTest();
        		CFAR_Address_Book_Dispatcher cabd = new CFAR_Address_Book_Dispatcher();
        		System.assertEquals(null, cabd.getTargetUrl().getParameters().get('id'));
        		CFAR_Contact_gne__c cntForITAdminUsr = CFAR_TestUtils.createTestITAdminContact();
        		cntForITAdminUsr.User_ref_gne__c = itAdm.Id;
        		update cntForITAdminUsr;
        		cabd = new CFAR_Address_Book_Dispatcher();
        		//for admins don't redirect to contact view (only for AVG and RO (incl. MSL))
        		System.assertEquals(null, cabd.getTargetUrl().getParameters().get('id'));
        	Test.stopTest();
        }
    }
    
    static testMethod void testEnteringABByReadOnlyUser() {
        User roUsr = CFAR_TestUtils.createTestReadOnlyUser();
        User itAdm = CFAR_TestUtils.createTestITAdminUser();
        Test.startTest();
        	System.runAs(roUsr){
        		CFAR_Address_Book_Dispatcher cabd = new CFAR_Address_Book_Dispatcher();
        		System.assertEquals(null, cabd.getTargetUrl().getParameters().get('id'));
        	}
        	CFAR_Contact_gne__c cntForROUsr;
        	System.runAs(itAdm){
        		cntForROUsr = CFAR_TestUtils.createTestReadOnlyContact();
        		cntForROUsr.User_ref_gne__c = roUsr.Id;
        		update cntForROUsr;
        	}
        	System.runAs(roUsr){
        		CFAR_Address_Book_Dispatcher cabd = new CFAR_Address_Book_Dispatcher();
        		System.assertEquals(String.valueOf(cntForROUsr.Id), cabd.getTargetUrl().getParameters().get('id'));
        	}
        Test.stopTest();
    }
    
    static testMethod void testEnteringABByMSLUser() {
        User mslUsr = CFAR_TestUtils.createTestMSLUser();
        User itAdm = CFAR_TestUtils.createTestITAdminUser();
        Test.startTest();
        	System.runAs(mslUsr){
        		CFAR_Address_Book_Dispatcher cabd = new CFAR_Address_Book_Dispatcher();
        		System.assertEquals(null, cabd.getTargetUrl().getParameters().get('id'));
        	}
        	CFAR_Contact_gne__c cntForMSLUsr;
        	System.runAs(itAdm){
        		cntForMSLUsr = CFAR_TestUtils.createTestMSL();
        		cntForMSLUsr.User_ref_gne__c = mslUsr.Id;
        		update cntForMSLUsr;
        	}
        	System.runAs(mslUsr){
        		CFAR_Address_Book_Dispatcher cabd = new CFAR_Address_Book_Dispatcher();
        		System.assertEquals(String.valueOf(cntForMSLUsr.Id), cabd.getTargetUrl().getParameters().get('id'));
        	}
        Test.stopTest();
    }
    
}