@isTest
private class SFA2_SBC_Profiler_Log_Action_LogicTest {
    @testSetup
    static void testData() {
        GNE_Foun_Misc_Config_Items_gne__c config = new GNE_Foun_Misc_Config_Items_gne__c(
            Name = 'SBCEmailAlerts', 
            Configuration_Value_gne__c= '{"To":["mdm_admin-d@gene.com","apho@gene.com"],"cc":["reddy.divya@gene.com","leszekk@gene.com","shirts.leslie@gene.com","sfdc-mainorg-tech-d@gene.com"]}'
        );
        GNE_Foun_Misc_Config_Items_gne__c configCode = new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SbcEmailAlertCodes', Configuration_Value_gne__c= 'Code = 404;Code = 500;Code = 502;Code = 600;Code = 601');

        insert new List<GNE_Foun_Misc_Config_Items_gne__c>{config, configCode};
    }
    
    @isTest
    static void testSendEmail() {
        SFA2_SBC_Profiler_Log_gne__c log1 = new SFA2_SBC_Profiler_Log_gne__c();
        SFA2_SBC_Profiler_Log_gne__c log2 = new SFA2_SBC_Profiler_Log_gne__c();
        insert new List<SFA2_SBC_Profiler_Log_gne__c>{log1, log2};
            
        SFA2_SBC_Profiler_Log_Action_gne__c record = new SFA2_SBC_Profiler_Log_Action_gne__c();
        record.Action_Name_gne__c = 'MDMSearch.ServiceError';
        record.Description_gne__c = 'Siperian Service Error [Status = Technical Exception, Code = 404, Method = FindHCOByProfile]';
        record.SBC_Profiler_Log_ref_gne__c = log1.Id;
        
        SFA2_SBC_Profiler_Log_Action_gne__c record1 = new SFA2_SBC_Profiler_Log_Action_gne__c();
        record1.Action_Name_gne__c = 'MDMSearch.ServiceError';
        record1.Description_gne__c = 'Siperian Service Error [Status = Technical Exception, Code = 502, Method = FindHCOByProfile]';
        record1.SBC_Profiler_Log_ref_gne__c = log2.Id;
        
        Test.startTest();
        	insert new List<SFA2_SBC_Profiler_Log_Action_gne__c>{record, record1};        
        Test.stopTest();
  
        System.assertNotEquals(null, SFA2_SBC_Profiler_Log_Action_Logic.emails);
		Messaging.SingleEmailMessage emailMsg = SFA2_SBC_Profiler_Log_Action_Logic.emails[0];   
        String emailBody = emailMsg.getHtmlBody();
        List<String> ccAddress = emailMsg.getCcAddresses();
        List<String> toAddress = emailMsg.getToAddresses();
        System.assertEquals(true, emailBody.contains('Code = 502'));
        System.assertEquals(true, emailBody.contains('Code = 404'));
        System.assertEquals(new List<String>{'mdm_admin-d@gene.com','apho@gene.com'}, toAddress);
        System.assertEquals(new List<String>{'reddy.divya@gene.com','leszekk@gene.com','shirts.leslie@gene.com','sfdc-mainorg-tech-d@gene.com'}, ccAddress);
    }
    
    @isTest
    static void testInsertNoEmail() {
        SFA2_SBC_Profiler_Log_gne__c log1 = new SFA2_SBC_Profiler_Log_gne__c();
        SFA2_SBC_Profiler_Log_gne__c log2 = new SFA2_SBC_Profiler_Log_gne__c();
        insert new List<SFA2_SBC_Profiler_Log_gne__c>{log1, log2};
            
        SFA2_SBC_Profiler_Log_Action_gne__c record = new SFA2_SBC_Profiler_Log_Action_gne__c();
        record.Action_Name_gne__c = 'MDMSearch.ServiceError';
        record.Description_gne__c = 'Siperian Service Error [Status = Technical Exception, Code = 555, Method = FindHCOByProfile]';
        record.SBC_Profiler_Log_ref_gne__c = log1.Id;
        
        SFA2_SBC_Profiler_Log_Action_gne__c record1 = new SFA2_SBC_Profiler_Log_Action_gne__c();
        record1.Action_Name_gne__c = 'no action';
        record1.Description_gne__c = 'Siperian Service Error [Status = Technical Exception, Code = 500, Method = FindHCOByProfile]';
        record1.SBC_Profiler_Log_ref_gne__c = log2.Id;
        
        Test.startTest();
        	insert new List<SFA2_SBC_Profiler_Log_Action_gne__c>{record, record1};        
        Test.stopTest();
             
        System.assertEquals(null, SFA2_SBC_Profiler_Log_Action_Logic.emails);
    }

}