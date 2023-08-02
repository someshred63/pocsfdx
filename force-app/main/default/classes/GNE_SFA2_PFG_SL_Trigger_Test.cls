@isTest
public without sharing class GNE_SFA2_PFG_SL_Trigger_Test {
    
    private static final String SALES_REP_USER_NAME = 'CS1';
    private static final String DM_USER_NAME = 'DM1';
    
    public static testMethod void testRequiredFieldsFailedValidation() {
        User testU = prepareEnv(SALES_REP_USER_NAME);
        
        System.assertNotEquals(null,testU);
        
        System.runAs(testU) {
            
            Test.startTest();
            DMLException ex = null;
            
            try {
                createStorageLocation(null, GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED,
                    'TEST STR', null, 'TEST CITY', 'TEST STATE', '99999', 
                    null, true);
            } catch(DMLException e) {
                ex = e;
            }
            
            System.assertNotEquals(null,ex);
            System.assert(ex.getMessage().contains(GNE_SFA2_PFG_SL_Trigger_Helper.ERROR_FIELD_REQUIRED), ex.getMessage());
            
            SFA2_PFG_Storage_Location_gne__c slRec = createStorageLocation(testU.Id, GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED,
                    'TEST STR', null, 'TEST CITY', 'TEST STATE', '99999', 
                    null, true);
                    
            ex = null;
            
            try {
                upsertStorageLocation(slRec, new Map<String,Object>{
                    'Status_gne__c' => null
                },true);
            } catch(DMLException e) {
                ex = e;
            }
            
            System.assertNotEquals(null,ex);
            System.assert(ex.getMessage().contains(GNE_SFA2_PFG_SL_Trigger_Helper.ERROR_FIELD_REQUIRED), ex.getMessage());
            
            slRec = createStorageLocation(testU.Id, GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED,
                    'TEST STR', null, 'TEST CITY', 'TEST STATE', '99999', 
                    null, true);
                    
            ex = null;
            
            try {
                upsertStorageLocation(slRec, new Map<String,Object>{
                    'State_gne__c' => null
                },true);
            } catch(DMLException e) {
                ex = e;
            }
            
            System.assertNotEquals(null,ex);
            System.assert(ex.getMessage().contains(GNE_SFA2_PFG_SL_Trigger_Helper.ERROR_FIELD_REQUIRED), ex.getMessage());
                                
            Test.stopTest();
        }
    }
    
    public static testMethod void testPhoneNumberFailedValidation() {
        User testU = prepareEnv(SALES_REP_USER_NAME);
        
        System.assertNotEquals(null,testU);
        
        System.runAs(testU) {
            
            Test.startTest();
            DMLException ex = null;
            
            try {
                createStorageLocation(testU.Id, GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED,
                    'TEST STR', null, 'TEST CITY', 'TEST STATE', '99999', 
                     new Map<String,Object>{
                        'Phone_gne__c' => 'WRONG FORMAT'
                    }, true);
            } catch(DMLException e) {
                ex = e;
            }
            
            System.assertNotEquals(null,ex);
            System.assert(ex.getMessage().contains(GNE_SFA2_PFG_SL_Trigger_Helper.ERROR_PHONE_FORMAT_NOT_VALID), ex.getMessage());
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testUserFieldChangedFailedValidation() {
        User testU = prepareEnv(SALES_REP_USER_NAME);
        
        System.assertNotEquals(null,testU);
        
        System.runAs(testU) {
            
            Test.startTest();
            DMLException ex = null;
            
            SFA2_PFG_Storage_Location_gne__c slRec = createStorageLocation(testU.Id, GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED,
                    'TEST STR', null, 'TEST CITY', 'TEST STATE', '99999', 
                     null, true);

            GNE_SFA2_PFG_TestHelper.userHelper.userCache.put('CS2', GNE_SFA2_PFG_TestHelper.getUser('DM1'));
            try {
                upsertStorageLocation(slRec, new Map<String,Object>{
                    'User_gne__c' => GNE_SFA2_PFG_TestHelper.getUser('CS2').Id
                },true);
            } catch(DMLException e) {
                ex = e;
            }
            
            System.assertNotEquals(null,ex);
            System.assert(ex.getMessage().contains(GNE_SFA2_PFG_SL_Trigger_Helper.ERROR_CANNOT_CHANGE_USER), ex.getMessage());
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testSumbitForApprovalOnInsert() {
        User testU = prepareEnv(SALES_REP_USER_NAME);
        
        System.assertNotEquals(null,testU);
        
        System.runAs(testU) {
            
            Test.startTest();
            
            SFA2_PFG_Storage_Location_gne__c slRec = createStorageLocation(testU.Id, GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED,
                'TEST STR', null, 'TEST CITY', 'TEST STATE', '99999', 
                null, true);
                
            List<ProcessInstance> pi = [Select Id, Status, TargetObjectId from ProcessInstance 
                                where TargetObjectId = :slRec.Id];
            System.assertEquals(1,pi.size());

            Test.stopTest();
        }
    }
    
    public static testMethod void testSumbitForApprovalOnAddressChange() {
        User testU = prepareEnv(SALES_REP_USER_NAME);
        
        System.assertNotEquals(null,testU);
        
        System.runAs(testU) {
            
            Test.startTest();
            
            SFA2_PFG_Storage_Location_gne__c slRec = createStorageLocation(testU.Id, GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED,
                'TEST STR', null, 'TEST CITY', 'TEST STATE', '99999', 
                null, true);
                
            slRec = [SELECT Address_Changed_gne__c, Status_gne__c FROM SFA2_PFG_Storage_Location_gne__c WHERE Id = :slRec.Id];
            
            System.assertEquals(false,slRec.Address_Changed_gne__c);
            System.assertEquals(GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED,slRec.Status_gne__c);
            
            List<ProcessInstance> pi = [Select Id, Status, TargetObjectId from ProcessInstance 
                                where TargetObjectId = :slRec.Id];
            System.assertEquals(1,pi.size());
            
            upsertStorageLocation(slRec, new Map<String,Object>{
                    'Address_Line_1_gne__c' => 'TEST STR 2'
                },true);
                
            slRec = [SELECT Address_Changed_gne__c, Status_gne__c FROM SFA2_PFG_Storage_Location_gne__c WHERE Id = :slRec.Id];
            
            System.assertEquals(false,slRec.Address_Changed_gne__c);
            System.assertEquals(GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED,slRec.Status_gne__c);
                
            pi = [Select Id, Status, TargetObjectId from ProcessInstance 
                                where TargetObjectId = :slRec.Id];
            System.assertEquals(1,pi.size());

            Test.stopTest();
        }
    }
    
    private static SFA2_PFG_Storage_Location_gne__c createStorageLocation(Id userId, String status,
                                        String addr1, String addr2, String city, String state, String zip,
                                        Map<String,Object> proposedValues, Boolean runDbOperation) {
        
        SFA2_PFG_Storage_Location_gne__c sl = new SFA2_PFG_Storage_Location_gne__c();
        
        if(proposedValues==null) {
            proposedValues = new Map<String,Object>();
        }
        
        proposedValues.putAll(new Map<String,Object>{
            'User_gne__c' => userId,
            'Status_gne__c' => status,
            'Address_Line_1_gne__c' => addr1, 'Address_Line_2_gne__c' => addr2, 
            'City_gne__c' => city, 'State_gne__c' => state, 'Zip_gne__c' => zip});
        
        return upsertStorageLocation(sl, proposedValues, runDbOperation);
    }
    
    private static SFA2_PFG_Storage_Location_gne__c upsertStorageLocation(SFA2_PFG_Storage_Location_gne__c sl, 
                                        Map<String,Object> proposedValues, Boolean runDbOperation) {
        for(String fieldName : proposedValues.keySet()) {
            sl.put(fieldName, proposedValues.get(fieldName));
        }
        
        if(runDbOperation) {
            upsert sl;
        }
        
        return sl;
    }
    
    private static User prepareEnv(String userName) {
    	GNE_SFA2_PFG_TestHelper.preparePfgSettings();
        GNE_SFA2_PFG_TestHelper.prepareBrand2Salesforce();
        GNE_SFA2_PFG_TestHelper.userHelper = new GNE_SFA2_PFG_TestHelper.UserHelper();
        GNE_SFA2_PFG_TestHelper.accountHelper = new GNE_SFA2_PFG_TestHelper.AccountHelper();
        return GNE_SFA2_PFG_TestHelper.getUser(userName);
    }
}