public class SPCM_AttachmentUtils
{
    public static Set<String> MCC_OBJECTS = new Set<String> {'SPCM_MCC_Approval_Sheet__c', 'SPCM_MCC_Exception_Sheet__c', 'SPCM_MCC_Tracking_Sheet__c'};
    public static Set<String> GP_OBJECTS = new Set<String> {'SPCM_GP_Payment_Packet__c'};
    public static Set<String> C_OPS_OBJECTS = new Set<String> {'SPCM_CARS_Contract_Summary_Form__c', 'SPCM_CARS_ICFR_Sign_Off__c', 'SPCM_CARS_Payment_Packet__c'};
    public static Set<String> MEDICAID_OBJECTS = new Set<String> {'SPCM_Medicaid_Payment_Packet__c'};
    
    public static Map<String, Set<String>> approvalTypeToObjects = new Map<String, Set<String>> {
        'MCC' => MCC_OBJECTS,
        'GP' => GP_OBJECTS,
        'C-OPS' => C_OPS_OBJECTS,
        'MEDICAID' => MEDICAID_OBJECTS
    };
    
    // method to handle attachment insert
    public static void HandleBeforeInsert(List<Attachment> records)
    {
    
        // retrieve SPCM object key prefixes
        Map<String, SObjectType> spcmPrefixes = GetSPCMKeyPrefixes();
        
        // loop through records to find SPCM attachments to insert
        List<Attachment> spcmInserts = new List<Attachment>();
        Map<SObjectType, List<String>> parentIds = new Map<SObjectType, List<String>>();
        for (Attachment record : records)
        {
            String parentId = record.ParentId;
            String parentKeyPrefix = parentId.substring(0, 3);
            if (spcmPrefixes.containsKey(parentKeyPrefix))
            {
                spcmInserts.add(record);
                if (!parentIds.containsKey(spcmPrefixes.get(parentKeyPrefix)))
                {
                    parentIds.put(spcmPrefixes.get(parentKeyPrefix), new List<String>());
                }
                parentIds.get(spcmPrefixes.get(parentKeyPrefix)).add('\'' + parentId + '\'');
            }
        }
        
        // if there are SPCM attachments to insert
        if (spcmInserts.size() > 0)
        {
            ProcessSPCMInserts(spcmInserts, parentIds);
        }
    }

    // method to handle attachment updates
    public static void HandleBeforeUpdate(List<Attachment> records)
    {
    
        // retrieve SPCM object key prefixes
        Map<String, SObjectType> spcmPrefixes = GetSPCMKeyPrefixes();
        
        // loop through records to find SPCM attachments to update
        List<Attachment> spcmUpdates = new List<Attachment>();
        Map<SObjectType, List<String>> parentIds = new Map<SObjectType, List<String>>();
        for (Attachment record : records)
        {
            String parentId = record.ParentId;
            String parentKeyPrefix = parentId.substring(0, 3);
            if (spcmPrefixes.containsKey(parentKeyPrefix))
            {
                spcmUpdates.add(record);
                if (!parentIds.containsKey(spcmPrefixes.get(parentKeyPrefix)))
                {
                    parentIds.put(spcmPrefixes.get(parentKeyPrefix), new List<String>());
                }
                parentIds.get(spcmPrefixes.get(parentKeyPrefix)).add('\'' + parentId + '\'');
            }
        }
        
        // if there are SPCM attachments to update
        if (spcmUpdates.size() > 0)
        {
            ProcessSPCMUpdates(spcmUpdates, parentIds);
        }
    }

    // method to handle attachment deletes
    public static void HandleBeforeDelete(List<Attachment> records)
    {
    
        // retrieve SPCM object key prefixes
        Map<String, SObjectType> spcmPrefixes = GetSPCMKeyPrefixes();
        
        // loop through records to find SPCM attachments to delete
        List<Attachment> spcmDeletes = new List<Attachment>();
        Map<SObjectType, List<String>> parentIds = new Map<SObjectType, List<String>>();
        for (Attachment record : records)
        {
            String parentId = record.ParentId;
            String parentKeyPrefix = parentId.substring(0, 3);
            if (spcmPrefixes.containsKey(parentKeyPrefix))
            {
                spcmDeletes.add(record);
                if (!parentIds.containsKey(spcmPrefixes.get(parentKeyPrefix)))
                {
                    parentIds.put(spcmPrefixes.get(parentKeyPrefix), new List<String>());
                }
                parentIds.get(spcmPrefixes.get(parentKeyPrefix)).add('\'' + parentId + '\'');
            }
        }
        
        // if there are SPCM attachments to delete
        if (spcmDeletes.size() > 0)
        {
            ProcessSPCMDeletes(spcmDeletes, parentIds);
        }
    }
    
    // retrieves SPCM object key prefixes
    private static Map<String, SObjectType> GetSPCMKeyPrefixes()
    {
    
        // declaration(s)
        Map<String, SObjectType> keyPrefixes = new Map<String, SObjectType>();
        
        // retrieve SPCM object key prefixes
        keyPrefixes.put(SPCM_CARS_Contract_Summary_Form__c.sObjectType.getDescribe().getKeyPrefix(),
            SPCM_CARS_Contract_Summary_Form__c.sObjectType);
        keyPrefixes.put(SPCM_CARS_ICFR_Sign_Off__c.sObjectType.getDescribe().getKeyPrefix(),
            SPCM_CARS_ICFR_Sign_Off__c.sObjectType);
        keyPrefixes.put(SPCM_CARS_Payment_Packet__c.sObjectType.getDescribe().getKeyPrefix(),
            SPCM_CARS_Payment_Packet__c.sObjectType);
        keyPrefixes.put(SPCM_GP_Payment_Packet__c.sObjectType.getDescribe().getKeyPrefix(),
            SPCM_GP_Payment_Packet__c.sObjectType);
        keyPrefixes.put(SPCM_MCC_Approval_Sheet__c.sObjectType.getDescribe().getKeyPrefix(),
            SPCM_MCC_Approval_Sheet__c.sObjectType);
        keyPrefixes.put(SPCM_MCC_Exception_Sheet__c.sObjectType.getDescribe().getKeyPrefix(),
            SPCM_MCC_Exception_Sheet__c.sObjectType);
        keyPrefixes.put(SPCM_MCC_Tracking_Sheet__c.sObjectType.getDescribe().getKeyPrefix(),
            SPCM_MCC_Tracking_Sheet__c.sObjectType);
        keyPrefixes.put(SPCM_Medicaid_Payment_Packet__c.sObjectType.getDescribe().getKeyPrefix(),
            SPCM_Medicaid_Payment_Packet__c.sObjectType);
            
        // return map
        return (keyPrefixes);
    }

    // method to handle spcm attachment inserts
    private static void ProcessSPCMInserts(List<Attachment> records, Map<SObjectType, List<String>> parentIds)
    {
        // get parent data
        Map<String, SObject> parentData = GetParentData(parentIds);
        Map<String,SPCM_Bypass_Attachment_Validation__c> bypass = SPCM_Bypass_Attachment_Validation__c.getAll();
        Set<String> bypassObjects = new Set<String>();
        for (PermissionSetAssignment psa : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN :bypass.keySet()]) {
            if (bypass.get(psa.PermissionSet.Name).MCC__c) {
                bypassObjects.addAll(approvalTypeToObjects.get('MCC'));
            }
            if (bypass.get(psa.PermissionSet.Name).GP__c) {
                bypassObjects.addAll(approvalTypeToObjects.get('GP'));
            }
            if (bypass.get(psa.PermissionSet.Name).C_OPS__c) {
                bypassObjects.addAll(approvalTypeToObjects.get('C-OPS'));
            }
            if (bypass.get(psa.PermissionSet.Name).Medicaid__c) {
                bypassObjects.addAll(approvalTypeToObjects.get('MEDICAID'));
            }
        }
        system.debug(bypassObjects);
        // loop through attachments
        for (Attachment record : records)
        {
            // get parent data
            SObject parent = parentData.get(record.ParentId);
            SObjectType sType = parent.getSObjectType();
            if (!bypassObjects.contains(String.valueOf(sType))) {
	            String parentStatus = String.valueOf(parent.get('Approval_Status__c'));
	            
	            // error if attempting to insert attachment for request not in 'New', 'Recalled'
	            // or 'Submitted for Approval' status
	            if (parentStatus != 'New' && parentStatus != 'Recalled' && 
	                parentStatus != 'Submitted for Approval')
	            {
	                record.addError('Attachments cannot be added in this approval status.');
	            }
            }
        }
    }

    // method to handle spcm attachment updates
    private static void ProcessSPCMUpdates(List<Attachment> records, Map<SObjectType, List<String>> parentIds)
    {
        
        // get parent data
        Map<String, SObject> parentData = GetParentData(parentIds);
        
        // loop through attachments
        for (Attachment record : records)
        {
        
            // get parent data
            SObject parent = parentData.get(record.ParentId);
            String parentStatus = String.valueOf(parent.get('Approval_Status__c'));
            
            // error if attempting to update attachment for request not in 'New', 'Recalled'
            // or 'Submitted for Approval' status
            if (parentStatus != 'New' && parentStatus != 'Recalled' && 
                parentStatus != 'Submitted for Approval')
            {
                record.addError('Attachments cannot be edited in this approval status.');
            }
        }
    }
    
    // method to handle spcm attachment deletes
    private static void ProcessSPCMDeletes(List<Attachment> records, Map<SObjectType, List<String>> parentIds)
    {
        
        // get parent data
        Map<String, SObject> parentData = GetParentData(parentIds);
        
        // loop through attachments
        for (Attachment record : records)
        {
        
            // get parent data
            SObject parent = parentData.get(record.ParentId);
            String parentStatus = String.valueOf(parent.get('Approval_Status__c'));
            
            // if attempting to delete attachment for request not in 'New' or 'Recalled' status
            if (parentStatus != 'New' && parentStatus != 'Recalled')
            {                
                record.addError('Attachments cannot be deleted in this approval status.');
            }
        }
    }
    
    // method to dynamically retrieve parent data for attachments
    private static Map<String, SObject> GetParentData(Map<SObjectType, List<String>> parentIds)
    {
    
        // declaration(s)
        Map<String, SObject> parentData = new Map<String, SObject>();
        
        // loop through each parent type
        for (SObjectType parentType : parentIds.keySet())
        {
        
            // query for parent data for type and add to map
            String queryString = 'SELECT Id, OwnerId, Initiated_By__c, Approval_Status__c FROM ' + 
                parentType + ' WHERE Id IN ' + parentIds.get(parentType);
            for (SObject parent : Database.query(queryString))
            {
                parentData.put(parent.Id, parent);
            }
        }
        
        // return data
        return (parentData);
    }
    
    // test method for code coverage
    static testMethod void runTests()
    {
    
        // create test utility class
        SPCM_TestUtils testUtils = new SPCM_TestUtils();
        
        // run as analyst
        System.runAs(testUtils.userAnalyst)
        {
        
            // start test
            Test.startTest();
        
            // create test record
            SPCM_CARS_Contract_Summary_Form__c newRecord = new SPCM_CARS_Contract_Summary_Form__c(
                Requested_Final_Approval_Date__c = Date.today(),
                Customer_Name__c = testUtils.customerName.Id,
                Customer_Type__c = testUtils.customerType.Id,
                Account_Manager__c = testUtils.accountManager.Id,
                Agreement_Type__c = testUtils.agreementType.Id,
                Market_Type__c = testUtils.marketType.Id,
                Contract_Manager__c = testUtils.contractManager.Id,
                Contract_Title__c = 'TEST',
                Product__c = 'TEST');
            insert(newRecord);
            System.assert(newRecord.Id != null);
            
            // test positive attachment insert
            Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf('TEST');
            attachment.Name = String.valueOf('test.txt');
            attachment.ContentType = 'txt';
            attachment.ParentId = newRecord.Id; 
            insert (attachment);
            System.assert(attachment.Id != null);
            
            // test positive attachment update
            attachment.Description = 'Updated';
            update (attachment);
            
            // test positive attachment delete
            delete (attachment);
            
            // create attachment again
            attachment = new Attachment();
            attachment.Body = Blob.valueOf('TEST');
            attachment.Name = String.valueOf('test.txt');
            attachment.ContentType = 'txt';
            attachment.ParentId = newRecord.Id; 
            insert (attachment);
            System.assert(attachment.Id != null);
            
            // update parent status
            newRecord.Approval_Status__c = 'Approved';
            update (newRecord);
            
            // test negative attachment insert
            Attachment attachment2 = new Attachment();
            attachment2.Body = Blob.valueOf('TEST2');
            attachment2.Name = String.valueOf('test2.txt');
            attachment2.ContentType = 'txt';
            attachment2.ParentId = newRecord.Id;
            boolean exCaught = false;
            try
            {
                insert (attachment2);
            }
            catch (Exception ex)
            {
                exCaught = true;
            }
            System.assertEquals(exCaught, true);
            
            // test negative update
            exCaught = false;
            attachment.Description = 'Updated';
            try
            {
                update (attachment);
            }
            catch (Exception ex)
            {
                exCaught = true;
            }
            System.assertEquals(exCaught, true);
            
            // test negative delete
            exCaught = false;
            try
            {
                delete (attachment);
            }
            catch (Exception ex)
            {
                exCaught = true;
            }
            System.assertEquals(exCaught, true);

            // stop test
            Test.stopTest();
        }
    }
}