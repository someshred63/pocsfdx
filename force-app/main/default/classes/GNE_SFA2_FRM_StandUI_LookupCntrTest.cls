@isTest
private class GNE_SFA2_FRM_StandUI_LookupCntrTest {
    @testSetup
    private static void initData(){
        List<Account> accs = new List<Account>();
        for(Integer x = 1; x< 30; x++){
            Account acc = GNE_FRM_TestUtilities.createAccount('Test 000'+x, 'FRM_HCO', 'Clinic', false);
            acc.MDMID_gne__c = '100'+x;
            accs.add(acc);
        }
        insert accs;
        
        List<Contact> conts = new List<Contact>();
        for(Integer x=1; x< 30; x++){
            Contact c = new Contact(LastName = 'LastName00'+x, FirstName = 'fName00'+x);
            conts.add(c);
        }
        insert conts;
            
        GNE_Foun_Misc_Config_Items_gne__c cit = new GNE_Foun_Misc_Config_Items_gne__c(
            Name = 'FRMAccountDCRLookup', 
            Configuration_Value_gne__c = 
                '{"obNa":"Account", '+
                '"fs":[{"n":"Name","s":"Y"},{"n":"Account_Type_gne__c"},{"n":"Name_and_Address_gne__c"},{"n":"MDMID_gne__c"}],'+
                '"wc":"WHERE RecordType.Name=\'FRM_HCO\'",'+
                '"rfs":[{"n":"RecordType.Name","l":"Record Type"}],'+
                '"lim":"20"}'
        );
        GNE_Foun_Misc_Config_Items_gne__c cit2 = new GNE_Foun_Misc_Config_Items_gne__c(
            Name = 'FRMAccountDCRLookup2', 
            Configuration_Value_gne__c = 
                '{"obNa":"Account", '+
                '"fs":[{"n":"Name","s":"Y"},{"n":"Account_Type_gne__c"},{"n":"Name_and_Address_gne__c"},{"n":"MDMID_gne__c","s":"Y"}],'+
                '"wc":"WHERE RecordType.Name=\'FRM_HCO\'",'+
                '"rfs":[{"n":"RecordType.Name","l":"Record Type"}],'+
                '"lim":"20"}'
        );
        GNE_Foun_Misc_Config_Items_gne__c cit1 = new GNE_Foun_Misc_Config_Items_gne__c(
            Name = 'FRMContactDCRLookup', 
            Configuration_Value_gne__c = 
                '{"obNa":"Contact", '+
                '"fs":[{"n":"Name","s":"Y"},{"n":"LastName"},{"n":"FirstName"}],'+
                '"lim":"20"}'
        );
        GNE_Foun_Misc_Config_Items_gne__c incorrect1 = new GNE_Foun_Misc_Config_Items_gne__c(
            Name = 'FRMincorrect1', 
            Configuration_Value_gne__c = 
                '{"obNa":"Account__c", '+
                '"fs":[{"n":"Name","s":"Y"},{"n":"Account_Type_gne__c"},{"n":"MDMID_gne__c"}],'+
                '"wc":"WHERE RecordType.Name=\'FRM_HCO\'",'+
                '"rfs":[{"n":"RecordType.Name","l":"Record Type"}],'+
                '"lim":"20"}'
        );
        GNE_Foun_Misc_Config_Items_gne__c incorrect2 = new GNE_Foun_Misc_Config_Items_gne__c(
            Name = 'FRMincorrect2', 
            Configuration_Value_gne__c = 
                '{"obNa":"Account", '+
                '"fs":[{"n":"Name","s":"Y"},{"n":"Account_Type_gne__c"},{"n":"MDMID_gne__c"}],'+
                '"wc":"WHERE RecordType.Name=\'FRM_HCO\'",'+
                '"rfs":[{"n":"dd","l":"Record Type"}],'+
                '"lim":"20"}'
        );
        GNE_Foun_Misc_Config_Items_gne__c incorrect3 = new GNE_Foun_Misc_Config_Items_gne__c(
            Name = 'FRMincorrect3', 
            Configuration_Value_gne__c = 
                '{"obNat":"Account", '+
                '"fs":[{"n":"Name","s":"Y"},{"n":"Account_Type_gne__c"},{"n":"MDMID_gne__c"}],'+
                '"wc":"WHERE RecordType.Name=\'FRM_HCO\'",'+
                '"rfs":[{"n":"dd","l":"Record Type"}],'+
                '"lim":"20"}'
        );
        insert new List<GNE_Foun_Misc_Config_Items_gne__c>{cit, cit1, cit2,incorrect1, incorrect2, incorrect3};
    }
    
    /**
     * No configuration in custom settings for FRMAccount
     * we expect values will be set to default
     */ 
    @isTest
    static void initTestDafaultValues(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRM_StandUI_Lookup?txt=page%3ADCRForm%3Aj_id138%3Aj_id169%3Aj_id176%3Aduplicate_02&conf=FRMAccount&frm=page%3ADCRForm&lksearch=&lksrch=');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            GNE_SFA2_FRM_StandUI_LookupCntr contr = new GNE_SFA2_FRM_StandUI_LookupCntr();
            String title = contr.getTitle();
            Integer resultSize = contr.results.size();
            Integer fieldSize = contr.fieldsOrdered.size();
            sObject obj = contr.results[0];
            String objectApiName = obj.getSObjectType().getDescribe().getName();
            contr.getFormTag();
            contr.getTextBox();
        Test.stopTest();  
        
        System.assertEquals('Search Account', title);
        System.assertEquals(25, resultSize);
        System.assertEquals(1, fieldSize);
        System.assertEquals('Account', objectApiName);
        
    }
    
    /**
     * Read configuration of FRMAccountDCRLookup
     * we expect values will be read from custom settings and set for controller's variables
     */ 
    @isTest
    static void initTestWithConfiguration(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRM_StandUI_Lookup?txt=page%3ADCRForm%3Aj_id138%3Aj_id169%3Aj_id176%3Aduplicate_02&conf=FRMAccountDCRLookup&title=Select%20Duplicate%20Account&frm=page%3ADCRForm&lksearch=&lksrch=');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            GNE_SFA2_FRM_StandUI_LookupCntr contr = new GNE_SFA2_FRM_StandUI_LookupCntr();
            String title = contr.getTitle();
            Integer resultSize = contr.results.size();
            Integer fieldSize = contr.fieldsOrdered.size();
            sObject obj = contr.results[0];
            String objectApiName = obj.getSObjectType().getDescribe().getName();
        Test.stopTest();  
        
        System.assertEquals('Select Duplicate Account', title);
        System.assertEquals(20, resultSize);
        System.assertEquals(5, fieldSize);
        System.assertEquals('Account', objectApiName);
    } 
    
    @isTest
    static void testSearchForAccount(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRM_StandUI_Lookup?conf=FRMAccountDCRLookup2');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            GNE_SFA2_FRM_StandUI_LookupCntr contr = new GNE_SFA2_FRM_StandUI_LookupCntr();
            contr.searchString = 'Test 000';
            contr.search();
            Integer resultSize = contr.results.size();
            System.assertEquals(20, resultSize); //limit size
            contr.searchString = 'Test 0001';
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(11, resultSize); 
            contr.searchString = 'Test 001';
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(0, resultSize); 
            contr.searchString = 'Test 00011';
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(1, resultSize); 
            contr.searchString = '10011'; //search by MDMId
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(1, resultSize);
            contr.searchString = '';
            contr.condition =  ' MDMID_gne__c =\'10011\'';
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(1, resultSize);
        Test.stopTest();  
    }
    
    /**
     * Read configuration of FRMContactDCRLookup
     * we expect values will be read from custom settings and set for controller's variables
     */ 
    @isTest
    static void initContactWithConfiguration(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRM_StandUI_Lookup?txt=page%3ADCRForm%3Aj_id138%3Aj_id169%3Aj_id176%3Aduplicate_02&conf=FRMContactDCRLookup&title=Select%20Contact&frm=page%3ADCRForm&lksearch=&lksrch=');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            GNE_SFA2_FRM_StandUI_LookupCntr contr = new GNE_SFA2_FRM_StandUI_LookupCntr();
            String title = contr.getTitle();
            Integer resultSize = contr.results.size();
            Integer fieldSize = contr.fieldsOrdered.size();
            sObject obj = contr.results[0];
            String objectApiName = obj.getSObjectType().getDescribe().getName();
        Test.stopTest();  
        
        System.assertEquals('Select Contact', title);
        System.assertEquals(20, resultSize);
        System.assertEquals(3, fieldSize);
        System.assertEquals('Contact', objectApiName);
    } 
    
    @isTest
    static void testSearchForContact(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRM_StandUI_Lookup?txt=page%3ADCRForm%3Aj_id138%3Aj_id169%3Aj_id176%3Aduplicate_02&conf=FRMContactDCRLookup');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            GNE_SFA2_FRM_StandUI_LookupCntr contr = new GNE_SFA2_FRM_StandUI_LookupCntr();
            contr.searchString = 'LastName00';
            contr.search();
            Integer resultSize = contr.results.size();
            System.assertEquals(20, resultSize); //limit size
            contr.searchString = 'LastName001';
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(11, resultSize); 
            contr.searchString = 'LastName01';
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(0, resultSize); 
            contr.searchString = 'LastName0011';
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(1, resultSize); 
            contr.searchString = 'fName0021'; //search by first name
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(1, resultSize);
            contr.searchString = '';
            contr.condition =  ' LastName =\'LastName0011\'';
            contr.search();
            resultSize = contr.results.size();
            System.assertEquals(1, resultSize);
        Test.stopTest();  
    }
    
    /**
     * test messages for inccorect value of Configuration_Value_gne__c in GNE_Foun_Misc_Config_Items_gne__c record
     */ 
    @isTest
    static void testObjectNameIncorrectConfiguration(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRM_StandUI_Lookup?&conf=FRMincorrect1');
        Test.setCurrentPage(pageRef);
        String error;
        Test.startTest();
            try{
                 GNE_SFA2_FRM_StandUI_LookupCntr contr = new GNE_SFA2_FRM_StandUI_LookupCntr();
            } catch (Exception ex){
                error = ex.getMessage();
            }            
        Test.stopTest();  
        
        System.assertEquals('Problem with object name: Account__c. Please, check object name in JSON in configuration object.', error);
    }
    
     /**
     * test messages for inccorect value of Configuration_Value_gne__c in GNE_Foun_Misc_Config_Items_gne__c record
     */ 
    @isTest
    static void testFieldIncorrectConfiguration(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRM_StandUI_Lookup?&conf=FRMincorrect2');
        Test.setCurrentPage(pageRef);
        String error;
        Test.startTest();
            try{
                 GNE_SFA2_FRM_StandUI_LookupCntr contr = new GNE_SFA2_FRM_StandUI_LookupCntr();
            } catch (Exception ex){
                error = ex.getMessage();
            }            
        Test.stopTest();  

        System.assert(error.contains('Problem details: No such column \'dd\' on entity \'Account\'.'));
    } 
    
    /**
     * test messages for inccorect value of Configuration_Value_gne__c in GNE_Foun_Misc_Config_Items_gne__c record
     */ 
    @isTest
    static void testIncorrectConfiguration(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRM_StandUI_Lookup?&conf=FRMincorrect3');
        Test.setCurrentPage(pageRef);
        String error;
        Test.startTest();
            try{
                 GNE_SFA2_FRM_StandUI_LookupCntr contr = new GNE_SFA2_FRM_StandUI_LookupCntr();
            } catch (Exception ex){
                error = ex.getMessage();
            }            
        Test.stopTest();  
        System.debug('error '+ error);

        System.assert(error.contains('Please, check JSON in configuration object.'));
    } 
}