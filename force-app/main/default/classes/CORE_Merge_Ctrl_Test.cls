@isTest
public class CORE_Merge_Ctrl_Test {
    @testSetup
    private static void init() {
        CORE_Merge_Test_Util.configureUser();
    }
    
    private static testMethod void testArchiveRecordCtrlInit() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        Map<String,List<SObject>> archiveRecsMap = CORE_Merge_Test_Util.prepareArchiveData();
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_App_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Child_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_JSON_Part__c.sObjectType)),false);
        Id archiveRecId = archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Record__c.sObjectType))[0].Id;
        PageReference pageRef = Page.CORE_Merge_ArchiveRecord;
        pageRef.getParameters().put('id', archiveRecId);
        Test.setCurrentPage(pageRef);
            
        Test.startTest();
        CORE_Merge_ArchiveRecordCtrl ctrl = new CORE_Merge_ArchiveRecordCtrl(new ApexPages.StandardController(new CORE_Merge_Archive_Record__c(Id = archiveRecId)));
        Test.stopTest();
        
        System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages during Controller initialization' + getPageMessagesAsString());
    }
    
    private static testMethod void testArchiveRecordCtrlActions() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        Map<String,List<SObject>> archiveRecsMap = CORE_Merge_Test_Util.prepareArchiveData();
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_App_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Child_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_JSON_Part__c.sObjectType)),false);
        Id archiveRecId = archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Record__c.sObjectType))[0].Id;
        PageReference pageRef = Page.CORE_Merge_ArchiveRecord;
        pageRef.getParameters().put('id', archiveRecId);
        Test.setCurrentPage(pageRef);
            
        Test.startTest();
        CORE_Merge_ArchiveRecordCtrl ctrl = new CORE_Merge_ArchiveRecordCtrl();
        System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages during Controller initialization' + getPageMessagesAsString());
        PageReference unmergeResult = ctrl.unmerge();
        System.assertEquals(null, unmergeResult, 'CORE_Merge_ArchiveRecordCtrl.unmerge() should return null');
        System.assertEquals(1, ApexPages.getMessages().size(), 'CORE_Merge_ArchiveRecordCtrl.unmerge() - There should be one info message');
        
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity(), 'Wrong Severity of the page\'s message: ' + msg.getSummary());
        }
        Test.stopTest();
        
        
    }
    
    private static testMethod void testMergeObjectCtrlInit() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        
        Id mObjId = mObjsMap.get('ALL').Id;
        PageReference pageRef = Page.CORE_Merge_ObjectConsole;
        pageRef.getParameters().put('id', mObjId);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        CORE_Merge_ConsoleCtrl ctrl = new CORE_Merge_ConsoleCtrl(new ApexPages.StandardController(new CORE_Merge_Object__c(Id = mObjId)));
        Test.stopTest();
        
        System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages during Controller initialization' + getPageMessagesAsString());
    }
    
    private static testMethod void testMergeJobCtrlInit() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        List<CORE_Merge_Job__c> mJobs = CORE_Merge_Test_Util.prepareMergeJobs(mObjsMap);
        
        Id mjobId = mJobs[0].Id;
        PageReference pageRef = Page.CORE_Merge_JobConsole;
        pageRef.getParameters().put('id', mjobId);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        CORE_Merge_ConsoleCtrl ctrl = new CORE_Merge_ConsoleCtrl(new ApexPages.StandardController(new CORE_Merge_Job__c(Id = mjobId)));
        Test.stopTest();
        
        System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages during Controller initialization' + getPageMessagesAsString());
    }
    
    private static testMethod void testMergeCandidateCtrlInit() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        
        Id mcId = mcs[0].Id;
        PageReference pageRef = Page.CORE_Merge_JobConsole;
        pageRef.getParameters().put('id', mcId);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        CORE_Merge_ConsoleCtrl ctrl = new CORE_Merge_ConsoleCtrl(new ApexPages.StandardController(new CORE_Merge_Candidate__c(Id = mcId)));
        Test.stopTest();
        
        System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages during Controller initialization' + getPageMessagesAsString());
    }
    
    private static testMethod void testMergeTabCtrlInit() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        
        PageReference pageRef = Page.CORE_Merge_ObjectTab;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        CORE_Merge_ConsoleCtrl ctrl = new CORE_Merge_ConsoleCtrl();
        List<CORE_Merge_ConsoleCtrl.QuickLinkWrapper> qLinks = ctrl.getQuickLinks();
        Test.stopTest();
        
        System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages during Controller initialization' + getPageMessagesAsString());
        System.assertEquals(5+1, qLinks.size(), 'Wrong number of quick links, ctrl.getQuickLinks()=' + qLinks);
    }
    
    private static testMethod void testMergeObjectCtrlProperties() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        List<CORE_Merge_Job__c> mJobs = CORE_Merge_Test_Util.prepareMergeJobs(mObjsMap);
        
        Id mObjId = mObjsMap.get('ALL').Id;
        PageReference pageRef = Page.CORE_Merge_ObjectConsole;
        pageRef.getParameters().put('id', mObjId);
        Test.setCurrentPage(pageRef);
        CORE_Merge_ConsoleCtrl ctrl = new CORE_Merge_ConsoleCtrl(new ApexPages.StandardController(new CORE_Merge_Object__c(Id = mObjId)));
        
        Test.startTest();
        System.assert(!ctrl.getIsJobInProgress(), 'CORE_Merge_ConsoleCtrl.isJobInProgress should return false');
        System.assert(ctrl.getCanEditMergeObject(), 'CORE_Merge_ConsoleCtrl.canEditMergeObject should return true');
        System.assert(ctrl.getHasAccessToMergeBatch(), 'CORE_Merge_ConsoleCtrl.hasAccessToMergeBatch should return true');
        System.assert(ctrl.getCanExecuteMerge(), 'CORE_Merge_ConsoleCtrl.canExecuteMerge should return true');
        System.assert(ctrl.getCanExecuteMergeInPreviewMode(), 'CORE_Merge_ConsoleCtrl.canExecuteMergeInPreviewMode should return true');
        System.assert(!ctrl.getHasAccessToPopulateCandidatesBatch(), 'CORE_Merge_ConsoleCtrl.hasAccessToPopulateCandidatesBatch should return false');
        System.assert(!ctrl.getCanExecutePopulateCandidates(), 'CORE_Merge_ConsoleCtrl.canExecutePopulateCandidates should return false');
        System.assertEquals(0, ApexPages.getMessages().size(), 'There should be no error messages' + getPageMessagesAsString());
        System.assertEquals(null, ctrl.actionPollerSupport(), 'CORE_Merge_ConsoleCtrl.actionPollerSupport() should return null'); 
        System.assertEquals(1, ApexPages.getMessages().size(), 'There should be one info message' + getPageMessagesAsString());
        Test.stopTest();
    }
    
    private static testMethod void testMergeObjectCtrlExecuteMerge() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        List<CORE_Merge_Job__c> mJobs = CORE_Merge_Test_Util.prepareMergeJobs(mObjsMap);
        
        Id mObjId = mObjsMap.get('ALL').Id;
        PageReference pageRef = Page.CORE_Merge_ObjectConsole;
        pageRef.getParameters().put('id', mObjId);
        Test.setCurrentPage(pageRef);
        CORE_Merge_ConsoleCtrl ctrl = new CORE_Merge_ConsoleCtrl(new ApexPages.StandardController(new CORE_Merge_Object__c(Id = mObjId)));
        
        Test.startTest();
        CORE_Merge_ConsoleCtrl.MergeData mData = new CORE_Merge_ConsoleCtrl.MergeData(false, null, null, null);
        ctrl.mergeDataAsJson = JSON.serialize(mData);
        PageReference result = ctrl.executeMerge();
        Test.stopTest();
        System.assertEquals(null, result, 'CORE_Merge_ConsoleCtrl.executeMerge() should return null');
        System.assertEquals(1, ApexPages.getMessages().size(), 'There should be one info message' + getPageMessagesAsString());
        
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity(), 'Wrong Severity of the page\'s message: ' + msg.getSummary());
        }
    }
    
    private static testMethod void testMergeObjectCtrlExecuteMergePerviewMode() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        List<CORE_Merge_Job__c> mJobs = CORE_Merge_Test_Util.prepareMergeJobs(mObjsMap);
        CORE_Merge_Test_Util.prepareDuplicateData();
        
        Id mObjId = mObjsMap.get('ALL').Id;
        PageReference pageRef = Page.CORE_Merge_ObjectConsole;
        pageRef.getParameters().put('id', mObjId);
        Test.setCurrentPage(pageRef);
        CORE_Merge_ConsoleCtrl ctrl = new CORE_Merge_ConsoleCtrl(new ApexPages.StandardController(new CORE_Merge_Object__c(Id = mObjId)));
        
        Test.startTest();
        CORE_Merge_ConsoleCtrl.MergeData mData = new CORE_Merge_ConsoleCtrl.MergeData(true, null, null, null);
        ctrl.mergeDataAsJson = JSON.serialize(mData);
        PageReference result = ctrl.executeMerge();
        Test.stopTest();
        System.assertEquals(null, result, 'CORE_Merge_ConsoleCtrl.executeMerge() should return null');
        System.assertEquals(1, ApexPages.getMessages().size(), 'There should be one info message' + getPageMessagesAsString());
        
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity(), 'Wrong Severity of the page\'s message: ' + msg.getSummary());
        }
    }
    
    private static testMethod void testMergeObjectCtrlBlockExecutePopulateCandidates() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        List<CORE_Merge_Job__c> mJobs = CORE_Merge_Test_Util.prepareMergeJobs(mObjsMap);
        CORE_Merge_Test_Util.prepareDuplicateData();
        
        Id mObjId = mObjsMap.get('ALL').Id;
        PageReference pageRef = Page.CORE_Merge_ObjectConsole;
        pageRef.getParameters().put('id', mObjId);
        Test.setCurrentPage(pageRef);
        CORE_Merge_ConsoleCtrl ctrl = new CORE_Merge_ConsoleCtrl(new ApexPages.StandardController(new CORE_Merge_Object__c(Id = mObjId)));
        
        Test.startTest();
        PageReference result = ctrl.executePopulateCandidates();
        Test.stopTest();
        System.assertEquals(null, result, 'CORE_Merge_ConsoleCtrl.executePopulateCandidates() should return null');
        System.assertEquals(1, ApexPages.getMessages().size(), 'There should be one error message' + getPageMessagesAsString());
        
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity(), 'Wrong Severity of the page\'s message: ' + msg.getSummary());
        }
    }
    
    private static testMethod void testMergeObjectCtrlExecutePopulateCandidates() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        List<CORE_Merge_Job__c> mJobs = CORE_Merge_Test_Util.prepareMergeJobs(mObjsMap);
        CORE_Merge_Test_Util.prepareDuplicateData();
        
        Id mObjId = mObjsMap.get('Case').Id;
        PageReference pageRef = Page.CORE_Merge_ObjectConsole;
        pageRef.getParameters().put('id', mObjId);
        Test.setCurrentPage(pageRef);
        CORE_Merge_ConsoleCtrl ctrl = new CORE_Merge_ConsoleCtrl(new ApexPages.StandardController(new CORE_Merge_Object__c(Id = mObjId)));
        
        Test.startTest();
        PageReference result = ctrl.executePopulateCandidates();
        Test.stopTest();
        System.assertEquals(null, result, 'CORE_Merge_ConsoleCtrl.executePopulateCandidates() should return null');
        System.assertEquals(1, ApexPages.getMessages().size(), 'There should be one info message' + getPageMessagesAsString());
        
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity(), 'Wrong Severity of the page\'s message: ' + msg.getSummary());
        }
    }
    
    private static String getPageMessagesAsString() {
        List<String> result = new List<String>();
        
        for(ApexPages.Message pMsg : ApexPages.getMessages()) {
            result.add(pMsg.getSeverity().name() + ': ' + pMsg.getSummary());
        }
        
        return !result.isEmpty() ? ', Page Messages:' + String.join(result,'|') : '';
    }
}