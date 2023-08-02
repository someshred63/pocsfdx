@isTest
public without sharing class CORE_Merge_Test_Util {
    
    @TestVisible private static void configureUser() {
        configureUser(UserInfo.getUserId(), 'OPS');
    }
    
    @TestVisible private static void configureUser(Id userId) {
        configureUser(userId, 'OPS');
    }
    
    @TestVisible private static void configureUser(Id userId, String role) {
        String permName = 'CORE_Merge_' + role;
        List<PermissionSet> pSets = [SELECT Id FROM PermissionSet WHERE Name = :permName];
        Id pSetId = !pSets.isEmpty() ? pSets[0].Id : null;
        
        if(pSetId!=null) {
            if([SELECT ID FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId = :pSetId].isEmpty()) {
                insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = pSetId);
            }
        }
        
        Set<String> grNamesToMembership = new Set<String>();
        String queueName = 'CORE_Merge_Queue';
        String groupName = 'CORE_Merge_' + (role=='Admin' ? 'Admin_' : '') + 'Group';
        
        if([SELECT ID FROM GroupMember WHERE UserOrGroupId = :userId AND Group.DeveloperName = :queueName].isEmpty()) {
            grNamesToMembership.add(queueName);
        }
        
        if([SELECT ID FROM GroupMember WHERE UserOrGroupId = :userId AND Group.DeveloperName = :groupName].isEmpty()) {
            grNamesToMembership.add(groupName);
        }
        
        if(!grNamesToMembership.isEmpty()) {
            List<Group> groups = [SELECT ID FROM Group WHERE DeveloperName IN :grNamesToMembership];
            List<GroupMember> grMembersToInsert = new List<GroupMember>();
            
            for(Group gr : groups) {
                grMembersToInsert.add(new GroupMember(UserOrGroupId = userId, GroupId = gr.Id));
            }
            
            Database.insert(grMembersToInsert, false);
        }
    }
    
    @TestVisible private static Map<String,CORE_Merge_Object__c> prepareMergeObjects() {
        CORE_Merge_Object__c parentMO = new CORE_Merge_Object__c(Object_Type_gne__c='ALL', Object_Name_gne__c='ALL');
        
        List<CORE_Merge_Object__c> mobjs = new List<CORE_Merge_Object__c>{
            parentMO,
            new CORE_Merge_Object__c(Object_Type_gne__c='Account', Object_Name_gne__c='Account'), 
            new CORE_Merge_Object__c(Object_Type_gne__c='Contact', Object_Name_gne__c='Contact'),
            new CORE_Merge_Object__c(Object_Type_gne__c='Case', Object_Name_gne__c='Case')
        };

        Id ownerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName ='CORE_Merge_Queue'].Id;
        List<RecordType> rts = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'CORE_Merge_Object__c' AND DeveloperName IN ('Group', 'Main') ORDER BY DeveloperName];

        Integer order=0;
        for(CORE_Merge_Object__c mobj : mobjs) {
            mobj.Order_gne__c = order++;
            mobj.Region_Code_gne__c = 1;
            mObj.External_Id_gne__c = String.format('{0}-{1}', new String[]{mObj.Object_Name_gne__c, 'US'});
            mObj.OwnerId = ownerId;
    
            if(mobj.Order_gne__c>0) {
                mobj.Parent_Merge_Object_gne__r = new CORE_Merge_Object__c(External_Id_gne__c=parentMO.External_Id_gne__c);
                mobj.RecordTypeId = rts[1].Id;
            } else {
                mobj.RecordTypeId = rts[0].Id;
            }
        }

        Database.upsert(mobjs[0], CORE_Merge_Object__c.External_Id_gne__c, false);
        Database.UpsertResult[] insertResults = Database.upsert(mobjs, CORE_Merge_Object__c.External_Id_gne__c, false);
        for(Database.UpsertResult sr : insertResults) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    String error = 'The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage()+' in prepareMergeObjects function.';
                    System.debug(error);    
                }
            }
        }
        
        Map<String,CORE_Merge_Object__c> result = new Map<String,CORE_Merge_Object__c>();
        
        for(CORE_Merge_Object__c mo : mobjs) {
            result.put(mo.Object_Name_gne__c, mo);
        }
        
        return result;
    }
    
    @TestVisible private static List<CORE_Merge_Configuration__c> prepareMergeConfiguration(Map<String,CORE_Merge_Object__c> mObjsMap) {
        CORE_Merge_Object__c allMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('ALL').External_Id_gne__c);
        CORE_Merge_Object__c accMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Account').External_Id_gne__c);
        CORE_Merge_Object__c contactMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Contact').External_Id_gne__c);
        CORE_Merge_Object__c caseMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Case').External_Id_gne__c);
        
        List<CORE_Merge_Configuration__c> mconfigs = new List<CORE_Merge_Configuration__c>{
		    // General
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'ArchiveCloningEnabled', Key_gne__c = 'ArchiveCloningEnabled', Value_gne__c = 'true', Merge_Object_gne__r = allMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'ArchiveJsonEnabled', Key_gne__c = 'ArchiveJsonEnabled', Value_gne__c = 'true', Merge_Object_gne__r = allMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'AdminModeManager', Key_gne__c = 'AdminModeManager', Value_gne__c = 'CORE_Merge_Test_Util.AdminModeManager', Merge_Object_gne__r = allMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'SupportEmail', Key_gne__c = 'SupportEmail', Value_gne__c = 'osowiecb@contractors.roche.com', Merge_Object_gne__r = allMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'ReportEmail', Key_gne__c = 'ReportEmail', Value_gne__c = 'osowiecb@contractors.roche.com', Merge_Object_gne__r = allMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'MergeEngine', Key_gne__c = 'MergeEngine', Value_gne__c = 'CORE_Merge_Engine', Merge_Object_gne__r = allMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'MergeEngineBatch', Key_gne__c = 'MergeEngineBatch', Value_gne__c = 'CORE_Merge_Engine_Batch', Value_json_gne__c = '{"scopeSize": 20}', Merge_Object_gne__r = allMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'PopulateCandidatesBatch', Key_gne__c = 'PopulateCandidatesBatch', Value_gne__c = 'CORE_Merge_Populate_Candidates_Batch', Value_json_gne__c = '{"scopeSize": 2000}', Merge_Object_gne__r = allMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'SchedulerConfig', Key_gne__c = 'SchedulerConfig', Value_json_gne__c = '[{"jobType":"Merge","cronExpression":"* ? MON","jobArguments":{}}]', Merge_Object_gne__r = allMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'WikiPage', Key_gne__c = 'WikiPage', Value_gne__c = 'http://merge-wiki-page.gene.test.com', Merge_Object_gne__r = allMergeObjRef),
		    // Account
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'ArchiveEnabled', Key_gne__c = 'ArchiveEnabled', Value_gne__c = 'true', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'MatchingRecord', Key_gne__c = 'MatchingRecord', Value_json_gne__c = '{"CreatedById":"{{UserInfo.getUserId()}}"}', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'CustomMergeEngineListner', Key_gne__c = 'CustomMergeEngineListner', Value_gne__c = 'CORE_Merge_Test_Util.CustomActionHandler', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveJsonFields', Key_gne__c = 'ArchiveJsonFields', Value_json_gne__c = '["Name","OwnerId"]', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveOwner', Key_gne__c = 'ArchiveOwner', Value_gne__c = UserInfo.getName(), Merge_Object_gne__r = accMergeObjRef),
		    //new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveRecordType', Key_gne__c = 'ArchiveRecordType', Value_gne__c = 'Archived_Person_Account_gne', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveMasterIdField', Key_gne__c = 'ArchiveMasterIdField', Value_gne__c = 'SicDesc', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveIdField', Key_gne__c = 'ArchiveIdField', Value_gne__c = 'SicDesc', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveCloneFieldDefaults', Key_gne__c = 'ArchiveCloneFieldDefaults', Value_json_gne__c = '{"AccountSource":"Other"}', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveCloneLoserFieldDefaults', Key_gne__c = 'ArchiveCloneLoserFieldDefaults', Value_json_gne__c = '{"AccountSource":"Loser"}', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveCloneWinnerFieldDefaults', Key_gne__c = 'ArchiveCloneWinnerFieldDefaults', Value_json_gne__c = '{"AccountSource":"Winner"}', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveCloneExcludedFields', Key_gne__c = 'ArchiveCloneExcludedFields', Value_json_gne__c = '["Fax","Phone"]', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveChildRelationship', Key_gne__c = 'Cases', Value_json_gne__c = '{"queryOrderBy":"CreatedDate DESC","queryLimit":100,"queryFields":["IsClosedOnCreate"]}', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveChildRelationship', Key_gne__c = 'Contacts', Value_json_gne__c = '{"archiveType":"APP","queryWhere":"Email <> null","queryFields":["Email","Fax","Phone","Birthdate","DoNotCall"]}', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'DeferOnConflict', Key_gne__c = 'IsPartner', Error_Code_gne__c = 'Partner Conflict', Group_gne__c = 'Partner Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'DeferOnConflictWithNulls', Key_gne__c = 'Phone', Error_Code_gne__c = 'Name Conflict', Group_gne__c = 'General Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'DeferOnChildRelationship', Key_gne__c = 'Contracts', Error_Code_gne__c = 'Cotracts Conflict', Group_gne__c = 'General Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'ExcludeMatching', Key_gne__c = 'NumberOfEmployees', Value_json_gne__c = '{"NumberOfEmployees":100}', Error_Code_gne__c = 'Account with Employees', Group_gne__c = 'Employees Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'CustomMergeValidation', Key_gne__c = 'casesValidation', Value_gne__c = 'CORE_Merge_Test_Util.CustomActionHandler', Error_Code_gne__c = 'Case Conflict', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldToQuery', Key_gne__c = 'Website', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'RelationshipToQuery', Key_gne__c = 'Contracts', Value_json_gne__c = '{"queryLimit": 1}', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldSum', Key_gne__c = 'NumberOfEmployees', Group_gne__c = 'General Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldAvg', Key_gne__c = 'NumberOfEmployees', Group_gne__c = 'General Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldNotNull', Key_gne__c = 'Website', Group_gne__c = 'General Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldNotNull', Key_gne__c = 'Ownership', Value_json_gne__c='{"nullValues":["Other"]}', Group_gne__c = 'General Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldNotNull', Key_gne__c = 'Phone', Value_json_gne__c='{"nullValues":["Other"]}', Group_gne__c = 'General Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldConcatenate', Key_gne__c = 'SicDesc', Value_json_gne__c='{"valueSeparator":";"}', Group_gne__c = 'General Rules', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'RelationshipToExclude', Key_gne__c = 'Contracts', Merge_Object_gne__r = accMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'CustomPreMergeAction', Key_gne__c = 'action1', Value_gne__c = 'CORE_Merge_Test_Util.CustomActionHandler', Merge_Object_gne__r = accMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'CustomPostMergeAction', Key_gne__c = 'action1', Value_gne__c = 'CORE_Merge_Test_Util.CustomActionHandler', Merge_Object_gne__r = accMergeObjRef),
		    //Contact
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'ArchiveEnabled', Key_gne__c = 'ArchiveEnabled', Value_gne__c = 'true', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'MatchingRecord', Key_gne__c = 'MatchingRecord', Value_json_gne__c = '{"CreatedById":"{{UserInfo.getUserId()}}"}', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveJsonFields', Key_gne__c = 'ArchiveJsonFields', Value_json_gne__c = '["Name","OwnerId"]', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveOwner', Key_gne__c = 'ArchiveOwner', Value_gne__c = UserInfo.getName(), Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveMasterIdField', Key_gne__c = 'ArchiveMasterIdField', Value_gne__c = 'Department', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveIdField', Key_gne__c = 'ArchiveIdField', Value_gne__c = 'AssistantName', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveCloneFieldDefaults', Key_gne__c = 'ArchiveCloneFieldDefaults', Value_json_gne__c = '{"DoNotCall":true}', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveCloneExcludedFields', Key_gne__c = 'ArchiveCloneExcludedFields', Value_json_gne__c = '[]', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Merge Rule', Type_gne__c = 'ArchiveChildRelationship', Key_gne__c = 'Cases', Value_json_gne__c = '{"queryOrderBy":"CreatedDate DESC","queryLimit":100}', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldBooleanAND', Key_gne__c = 'DoNotCall', Group_gne__c = 'General Rules', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldBooleanOR', Key_gne__c = 'HasOptedOutOfEmail', Group_gne__c = 'General Rules', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldPreferLow', Key_gne__c = 'Birthdate', Group_gne__c = 'General Rules', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldNotNull', Key_gne__c = 'Fax', Group_gne__c = 'General Rules', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'RelationshipToMove', Key_gne__c = 'Cases', Merge_Object_gne__r = contactMergeObjRef),
            
            //Case
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'PopulateCandidatesConfig', Key_gne__c = 'PopulateCandidatesConfig', Value_json_gne__c = '{"enabled":true,"populateFromParentEnabled":true,"mergeFromParentEnabled":true,"querySortBy":["LastModifiedDate DESC"],"queryUniqueField":"Subject","queryWhere":"IsEscalated = false","queryBatchWhere":"IsEscalated = false AND Account.LastModifiedDate >= {{LAST_POPULATE_JOB_DATETIME}}"}', Merge_Object_gne__r = caseMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'SchedulerConfig', Key_gne__c = 'SchedulerConfig', Value_json_gne__c = '[{"jobType":"PopulateCandidates","cronExpression":"* ? *","jobArguments":{}}]', Merge_Object_gne__r = caseMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldNotNull', Key_gne__c = 'SuppliedEmail', Merge_Object_gne__r = caseMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldConcatenate', Key_gne__c = 'Description', Merge_Object_gne__r = caseMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldNotNull', Key_gne__c = 'SuppliedCompany', Merge_Object_gne__r = caseMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldCustomTransfer', Key_gne__c = 'SuppliedName', Value_gne__c = 'CORE_Merge_Test_Util.CustomActionHandler', Merge_Object_gne__r = caseMergeObjRef),
		    new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'FieldToQuery', Key_gne__c = 'SuppliedName', Merge_Object_gne__r = caseMergeObjRef)
		};
		
		for(CORE_Merge_Configuration__c mconfig : mconfigs) {
		    mconfig.External_Id_gne__c = String.format('{0}|{1}_{2}', new String[]{mconfig.Merge_Object_gne__r.External_Id_gne__c, mconfig.Type_gne__c, mconfig.Key_gne__c});
		    mconfig.Active_gne__c = true;
		}
		
		Database.upsert(mconfigs, CORE_Merge_Configuration__c.External_Id_gne__c, false);
		
		return mconfigs;
    }
    
    @TestVisible private static List<CORE_Merge_Job__c> prepareMergeJobs(Map<String,CORE_Merge_Object__c> mObjsMap) {
        CORE_Merge_Object__c allMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('ALL').External_Id_gne__c);
        CORE_Merge_Object__c accMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Account').External_Id_gne__c);
        CORE_Merge_Object__c contactMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Contact').External_Id_gne__c);
        CORE_Merge_Object__c caseMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Case').External_Id_gne__c);
        
        List<CORE_Merge_Job__c> mjobs = new List<CORE_Merge_Job__c>{
            new CORE_Merge_Job__c(Type_gne__c= CORE_Merge_Util.MERGE_JOB_TYPE_MERGE_PERVIEW_MODE, Merge_Object_gne__r = allMergeObjRef),
            new CORE_Merge_Job__c(Type_gne__c= CORE_Merge_Util.MERGE_JOB_TYPE_MERGE_SINGLE_MODE, Merge_Object_gne__r = accMergeObjRef),
            new CORE_Merge_Job__c(Type_gne__c= CORE_Merge_Util.MERGE_JOB_TYPE_UNMERGE, Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Job__c(Type_gne__c= CORE_Merge_Util.MERGE_JOB_TYPE_POPULATE_CANDIDATES, Merge_Object_gne__r = caseMergeObjRef),
            new CORE_Merge_Job__c(Type_gne__c= CORE_Merge_Util.MERGE_JOB_TYPE_MERGE, Merge_Object_gne__r = allMergeObjRef)
        };
        
        Database.insert(mjobs, false);
        return mjobs;
    }
    
    @TestVisible private static List<CORE_Merge_Error__c> prepareMergeErrors(Map<String,CORE_Merge_Object__c> mObjsMap) {
        CORE_Merge_Object__c accMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Account').External_Id_gne__c);
        CORE_Merge_Object__c contactMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Contact').External_Id_gne__c);
        
        List<CORE_Merge_Error__c> merrs = new List<CORE_Merge_Error__c>{
            new CORE_Merge_Error__c(Type_gne__c='System.WrongTypeException', Error_Code_gne__c = 'RUNTIME EXCEPTION', Level_gne__c = 'HIGH', Description_gne__c = 'System.Type - Wrong Type', Merge_Object_gne__r = accMergeObjRef),
            new CORE_Merge_Error__c(Type_gne__c='DeferOnConflict', Error_Code_gne__c = 'General Rules', Level_gne__c = 'MEDIUM', Description_gne__c = 'Conflict on FirstName field', Merge_Object_gne__r = contactMergeObjRef),
            new CORE_Merge_Error__c(Type_gne__c='DeferOnChildRelationship', Error_Code_gne__c = 'General Rules', Level_gne__c = 'MEDIUM', Description_gne__c = 'Conflict on Cases relationship', Merge_Object_gne__r = contactMergeObjRef)
        };
        
        Database.insert(merrs, false);
        return merrs;
    }
    
    @TestVisible private static List<CORE_Merge_Candidate__c> prepareDuplicateData() {
        Id ownerId = UserInfo.getUserId();
        AdminModeManager adminModeMgr = (AdminModeManager)CORE_Merge_Configuration.getCustomClassInstance('CORE_Merge_Test_Util.AdminModeManager');
        adminModeMgr.switchAdminMode(true);
        List<Account> accs = new List<Account>{
            //Duplicate Group 1
            new Account(Name='ACC1', OwnerId = ownerId, Website = 'http://test.website.com', Ownership='Other', Phone = '454554778', Fax = '123456789', NumberOfEmployees=1, AccountSource = 'MDM'),
            new Account(Name='ACC1 (Duplicate)', OwnerId = ownerId, Website = 'http://test.website.com', Ownership='Public', Phone = '454554778', Fax = '123456789', NumberOfEmployees=5, AccountSource = 'Manual'),
            //Duplicate Group 2
            new Account(Name='ACC2', OwnerId = ownerId, Website = 'http://test.website.com', Ownership='Public', Phone = '454554778', Fax = '123456789', NumberOfEmployees=2, AccountSource = 'MDM'),
            new Account(Name='ACC2 (Duplicate 1)', OwnerId = ownerId, Website = 'http://test.website.com', Ownership='Other', Phone = '454554778', Fax = '123456789', NumberOfEmployees=1, AccountSource = 'Manual'),
            new Account(Name='ACC2 (Duplicate 2)', OwnerId = ownerId, Website = 'http://test.website.com', Ownership='Private', Phone = '454554778', Fax = '123456789', NumberOfEmployees=3, AccountSource = 'Manual')
        };
        
        insert accs;
        
        List<Contact> cts = new List<Contact>{
            //Duplicate Group 1
            new Contact(FirstName = 'Contact1', LastName='ACC1', AccountId = accs[0].Id, OwnerId = ownerId, DoNotCall=true, Birthdate=Date.today().addDays(-3000), Fax=null, HasOptedOutOfEmail = false),
            new Contact(FirstName = 'Contact1', LastName='ACC1 (Duplicate)', AccountId = accs[1].Id, OwnerId = ownerId, DoNotCall=false, Birthdate=Date.today().addDays(-6000), Fax='(123) 456-7890', HasOptedOutOfEmail = true),
            //Duplicate Group 2
            new Contact(FirstName = 'Contact2', LastName='ACC1', AccountId = accs[0].Id, OwnerId = ownerId, DoNotCall=false, Birthdate=Date.today().addDays(-6000), Fax='(123) 456-7890', HasOptedOutOfEmail = true),
            new Contact(FirstName = 'Contact2', LastName='ACC1 (Duplicate)', AccountId = accs[0].Id, OwnerId = ownerId, DoNotCall=false, Birthdate=Date.today().addDays(-6000), Fax='(123) 456-7890', HasOptedOutOfEmail = false),
            //Duplicate Group 3
            new Contact(FirstName = 'Contact1', LastName='ACC2', AccountId = accs[2].Id, OwnerId = ownerId, DoNotCall=true, Birthdate=Date.today().addDays(-3000), Fax=null, HasOptedOutOfEmail = false),
            new Contact(FirstName = 'Contact1', LastName='ACC2 (Duplicate 1)', AccountId = accs[3].Id, OwnerId = ownerId, DoNotCall=true, Birthdate=Date.today().addDays(-8000), Fax='(123) 456-7890', HasOptedOutOfEmail = false),
            new Contact(FirstName = 'Contact1', LastName='ACC2 (Duplicate 2)', AccountId = accs[4].Id, OwnerId = ownerId, DoNotCall=true, Birthdate=Date.today().addDays(-6000), Fax='(123) 456-7890', HasOptedOutOfEmail = true),
            // Non Duplicates
            new Contact(FirstName = 'Contact3', LastName='ACC1', AccountId = accs[0].Id, OwnerId = ownerId, DoNotCall=false, Birthdate=Date.today().addDays(-6000), Fax='(123) 456-7890'),
            new Contact(FirstName = 'Contact4', LastName='ACC1', AccountId = accs[0].Id, OwnerId = ownerId, DoNotCall=false, Birthdate=Date.today().addDays(-6000), Fax='(123) 456-7890'),
            new Contact(FirstName = 'Contact5', LastName='ACC1  (Duplicate)', AccountId = accs[1].Id, OwnerId = ownerId, DoNotCall=false, Birthdate=Date.today().addDays(-6000), Fax='(123) 456-7890'),
            new Contact(FirstName = 'Contact6', LastName='ACC1 (Duplicate)', AccountId = accs[1].Id, OwnerId = ownerId, DoNotCall=false, Birthdate=Date.today().addDays(-6000), Fax='(123) 456-7890')
        };
        
        insert cts;
        
        List<Case> cases = new List<Case>{
            //Duplicate Group 1
            new Case(Subject = 'ACC1.SUB1', AccountId = accs[0].Id, ContactId = cts[0].Id, Description = 'DESC1', SuppliedEmail='test@test.com', SuppliedCompany='ABC', SuppliedName='CDE'),
            new Case(Subject = 'ACC1.SUB1', AccountId = accs[1].Id, ContactId = cts[1].Id, Description = 'DESC2', SuppliedEmail='test@test.com', SuppliedCompany='ABC', SuppliedName='CDE'),
            new Case(Subject = 'ACC1.SUB1', AccountId = accs[1].Id, ContactId = cts[1].Id, Description = 'DESC3', SuppliedEmail='test@test.com', SuppliedCompany='ABC', SuppliedName='CDE'),
            //Duplicate Group 2
            new Case(Subject = 'ACC1.SUB2', AccountId = accs[0].Id, ContactId = cts[0].Id, Description = 'DESC1'),
            new Case(Subject = 'ACC1.SUB2', AccountId = accs[0].Id, ContactId = cts[0].Id, Description = 'DESC2'),
            new Case(Subject = 'ACC1.SUB2', AccountId = accs[1].Id, ContactId = cts[1].Id, Description = 'DESC3'),
            // Non Duplicates
            new Case(Subject = 'ACC1.SUB3', AccountId = accs[0].Id, ContactId = cts[0].Id, Description = 'DESC1'),
            new Case(Subject = 'ACC1.SUB4', AccountId = accs[1].Id, ContactId = cts[1].Id, Description = 'DESC1'),
            new Case(Subject = 'ACC1.SUB5', AccountId = accs[3].Id, ContactId = cts[5].Id, Description = 'DESC1'),
            new Case(Subject = 'ACC1.SUB6', AccountId = accs[4].Id, ContactId = cts[6].Id, Description = 'DESC1'),
            new Case(Subject = 'ACC1.SUB7', AccountId = accs[2].Id, ContactId = cts[4].Id, Description = 'DESC1')
        };
        
        insert cases;
        adminModeMgr.switchAdminMode(false);
        Map<String,CORE_Merge_Object__c>nameToMergeObject = fetchMergeObjectsMap();
        Id mergeObjectId = nameToMergeObject.get('Account-US').Id;
        
        List<CORE_Merge_Candidate__c> mcs = new List<CORE_Merge_Candidate__c>{            
            new CORE_Merge_Candidate__c(Id_gne__c = accs[0].Id, Master_Id_gne__c = accs[0].Id, Merge_Object_gne__c = mergeObjectId),
            new CORE_Merge_Candidate__c(Id_gne__c = accs[1].Id, Master_Id_gne__c = accs[0].Id, Merge_Object_gne__c = mergeObjectId),
            new CORE_Merge_Candidate__c(Id_gne__c = accs[2].Id, Master_Id_gne__c = accs[2].Id, Merge_Object_gne__c = mergeObjectId),
            new CORE_Merge_Candidate__c(Id_gne__c = accs[3].Id, Master_Id_gne__c = accs[2].Id, Merge_Object_gne__c = mergeObjectId),
            new CORE_Merge_Candidate__c(Id_gne__c = accs[4].Id, Master_Id_gne__c = accs[2].Id, Merge_Object_gne__c = mergeObjectId)
        };
        
        for(CORE_Merge_Candidate__c mc : mcs) {
            mc.External_Id_gne__c = String.format('{0}_{1}_Merge_Loaded', new String[]{mc.Id_gne__c, mc.Master_Id_gne__c});
        }

        Database.UpsertResult[] insertResults = Database.upsert(mcs, CORE_Merge_Candidate__c.External_Id_gne__c, false); 
        for(Database.UpsertResult sr : insertResults) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    String error = 'The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage()+'.';
                    System.debug(error);    
                }
            }
        }
        
        return mcs;
    }
    
    private static Map<String,CORE_Merge_Object__c> fetchMergeObjectsMap() {
        Map<String, CORE_Merge_Object__c> nameToMergeObjectMap = new Map<String, CORE_Merge_Object__c>();
        for(CORE_Merge_Object__c obj :[
            SELECT Id, Name FROM CORE_Merge_Object__c WHERE Name IN ('Account-US', 'Address-US')
        ]){
            nameToMergeObjectMap.put(obj.Name, obj);
        }
        return nameToMergeObjectMap;
    }
    
    @TestVisible private static Map<String,List<SObject>> prepareArchiveData() {
        List<Account> acs = [
            SELECT Id, Name, Phone, Fax,
                (SELECT Id, Name, Phone, Fax FROM Contacts),
                (SELECT Id, Subject, Description, SuppliedEmail FROM Cases)
            FROM Account
            WHERE Name IN ('ACC1', 'ACC2')
        ];
        
        Set<Id> accIds = new Map<Id,Account>(acs).keySet();
        List<CORE_Merge_Candidate__c> mcs = [SELECT Id, Id_gne__c, Merge_Object_gne__c FROM CORE_Merge_Candidate__c WHERE Id_gne__c IN :accIds];
        Map<Id,CORE_Merge_Candidate__c> mcsMap = new Map<Id,CORE_Merge_Candidate__c>();
        
        for(CORE_Merge_Candidate__c mc : mcs) {
            mcsMap.put((Id)mc.Id_gne__c, mc);
        }
        
        Map<String,List<SObject>> archiveRecsToInsert = new Map<String,List<SObject>>();
        String archiveTimestamp = System.now().formatGmt('YYYYMMDD_HHmmss');
        
        for(Account ac : acs) {
            List<SObject> archiveRecs = archiveRecord(ac, ac, mcsMap.get(ac.Id), new CORE_Merge_Object__c(Id = mcsMap.get(ac.Id).Merge_Object_gne__c), archiveTimestamp, 
                new Set<String>{'Name', 'ID', 'Phone', 'Fax'},
                new Map<String,Set<String>>{
                    'Contacts' => new Set<String>{'Name', 'ID', 'Phone', 'Fax'},
                    'Cases' => new Set<String>{'Subject', 'ID', 'Description', 'SuppliedEmail'}
            });
            
            for(SObject rec : archiveRecs) {
                String sOBjectName = String.valueOf(rec.getSObjectType());
                
                if(!archiveRecsToInsert.containsKey(sOBjectName)) {
                    archiveRecsToInsert.put(sOBjectName, new List<SObject>());
                }
                
                archiveRecsToInsert.get(sOBjectName).add(rec);
            }
        }
        
        return archiveRecsToInsert;
    }
    
    private static List<SObject> archiveRecord(SObject rec, SObject winner, CORE_Merge_Candidate__c mc, CORE_Merge_Object__c mObj, String archiveTimestamp, Set<String> fieldsToArchive, Map<String,Set<String>> childrenToArchive) {
	    List<SObject> archiveToInsert = new List<SObject>();        
	    CORE_Merge_Archive_Record__c archiveRec = new CORE_Merge_Archive_Record__c(Id_gne__c = rec.Id, Master_Id_gne__c = winner.Id, Merge_Object_gne__c = mObj.Id, Merge_Candidate_gne__c = mc.Id);
	    Map<String,Object> fields = getFieldsMap(rec, fieldsToArchive);
	    String jsonValue = JSON.serialize(fields);
	    archiveRec.Value_json_gne__c = '|' + jsonValue.substring(0,10) + '|';
	    archiveRec.External_Id_gne__c = String.format('{0}_{1}_{2}', new String[]{archiveRec.Id_gne__c, archiveRec.Master_Id_gne__c, archiveTimestamp});
	    
	    if(archiveRec.Id_gne__c!=archiveRec.Master_Id_gne__c) {
	        archiveRec.Master_Archive_Record_gne__r = new CORE_Merge_Archive_Record__c(External_Id_gne__c = String.format('{0}_{1}_{2}', new String[]{archiveRec.Master_Id_gne__c, archiveRec.Master_Id_gne__c, archiveTimestamp}));
	    }
	    
	    archiveToInsert.add(archiveRec);
	    
	    List<CORE_Merge_Archive_Child_Record__c> childArchiveRecs = new List<CORE_Merge_Archive_Child_Record__c>();
	    CORE_Merge_Archive_Record__c masterRec = new CORE_Merge_Archive_Record__c(External_Id_gne__c = archiveRec.External_Id_gne__c);
	    
	    for(String childRelationName : childrenToArchive.keySet()) {
	        List<SObject> children = rec.getSObjects(childRelationName);
	        if(children!=null) {
	            for(SObject child : children) {
	                SObject childArchiveRec = childRelationName=='Contacts' ? (SObject)new CORE_Merge_Archive_App_Record__c() : (SObject)new CORE_Merge_Archive_Child_Record__c();
	                
	                Map<String,Object> childFields = getFieldsMap(child, childrenToArchive.get(childRelationName));
	                
	                childArchiveRec.put('Id_gne__c', child.Id);
	                childArchiveRec.put('Relationship_Name_gne__c', childRelationName);
	                childArchiveRec.put('Field_Name_gne__c', 'AccountId');
	                childArchiveRec.put('Object_Type_gne__c', child.getSObjectType().getDescribe().getName());
	                childArchiveRec.putSObject('Merge_Archive_Record_gne__r', masterRec);
	                childArchiveRec.put('External_Id_gne__c', String.format('{0}_{1}_{2}_{3}_{4}', new String[]{child.Id, archiveRec.Id_gne__c, archiveRec.Master_Id_gne__c, childRelationName, archiveTimestamp}));
	                childArchiveRec.put('Value_json_gne__c', childFields!=null && !childFields.isEmpty() ? JSON.serialize(childFields) : null);
	                archiveToInsert.add(childArchiveRec);
	            }
	        }
	    }
	    
	    archiveToInsert.add(new CORE_Merge_Archive_JSON_Part__c(Merge_Archive_Record_gne__r = new CORE_Merge_Archive_Record__c(External_Id_gne__c = archiveRec.External_Id_gne__c), Part_No_gne__c = 1, Value_json_gne__c = '|' + jsonValue.substring(10) + '|'));
	    
	    return archiveToInsert;
	}
	
	private static Map<String,Object> getFieldsMap(SObject rec, Set<String> fieldsToArchive) {
	    Map<String,Object> fields = new Map<String,Object>();
	    
	    if(fieldsToArchive!=null) {
	        for(String fieldName : fieldsToArchive) {
	            fields.put(fieldName, rec.get(fieldName));
	        }
	    }
	    
	    return fields;
	}
    
    private class AdminModeMetadata {
        private String sObjectName;
        private String queryWhere;
        private String flagField;
        private String recordTemplate;
        
        private AdminModeMetadata(String sObjectName, String queryWhere, String flagField, String recordTemplate) {
            this.sObjectName = sObjectName;
            this.queryWhere = queryWhere;
            this.flagField = flagField;
            this.recordTemplate = recordTemplate;
        }
    }
    
    public class AdminModeManager implements CORE_Merge_Interface.AdminModeManagerInterface {
        private transient SObject adminModeRec;
        private Map<String,AdminModeMetadata> adminModeMetadata;
        
        public Boolean switchAdminMode(Boolean turnOnOrOff) {
            Boolean result = false;
            SObject adminModeSetting = getAdminModeRec();
            
            if(adminModeSetting!=null) {
                String flagField = getFlagFieldName();
                result = (Boolean)adminModeSetting.get(flagField);
                adminModeSetting.put(flagField, turnOnOrOff);
                upsert adminModeSetting;
            }
            
            return result==true;
        }
        
        public Boolean isAdminMode() {
            Boolean result = false;
            SObject adminModeSetting = getAdminModeRec();
            
            if (adminModeSetting!=null) {               
                result = (Boolean)adminModeSetting.get(getFlagFieldName());
            }
            
            return result==true;
        }
        
        private SObject getAdminModeRec() {
            if(adminModeMetadata==null) {
                adminModeMetadata = new Map<String,AdminModeMetadata>{
                    'GNE_SFA2_ADMIN_MODE__C' => new AdminModeMetadata('GNE_SFA2_Admin_Mode__c', 'SetupOwnerId = \'' + UserInfo.getUserId() + '\'','GNE_SFA2_Is_Admin_Mode__c', '{"SetupOwnerId":"' + UserInfo.getUserId() + '","GNE_SFA2_Is_Admin_Mode__c":false}'),
                    'SYN_TRIGGER_BLOCKED__C' => new AdminModeMetadata('SYN_Trigger_Blocked__c', 'SetupOwnerId = \'' + UserInfo.getUserId() + '\'','All_Blocked__c', '{"SetupOwnerId":"' + UserInfo.getUserId() + '","All_Blocked__c":false}'),
                    'CM_ADMINMODE__C' => new AdminModeMetadata('CM_AdminMode__c', 'SetupOwnerId = \'' + UserInfo.getUserId() + '\'','Is_Admin_Mode__c', '{"SetupOwnerId":"' + UserInfo.getUserId() + '","Is_Admin_Mode__c":false}'),
                    'ADMIN_MODE__C' => new AdminModeMetadata('Admin_Mode__c', 'SetupOwnerId = \'' + UserInfo.getUserId() + '\'','Enabled__c', '{"SetupOwnerId":"' + UserInfo.getUserId() + '","Enabled__c":false}')
                    
                };
                for(AdminModeMetadata amMetaData : adminModeMetadata.values()) {
                    try {
                        List<SObject> sObjs = Database.query(String.format('SELECT Id, {0} FROM {1} WHERE {2}', new String[]{
                            amMetaData.flagField,
                            amMetaData.sObjectName,
                            amMetaData.queryWhere
                        }));
                        
                        for(SObject sObj : sObjs) {
                            adminModeRec = sObj;
                        }
                        
                        if(adminModeRec==null) {
                            adminModeRec = (SObject)JSON.deserialize(amMetaData.recordTemplate, System.Type.forName(amMetaData.sObjectName));
                        }
                        
                        break;
                    } catch (Exception e) {}
                }
            }
            
            return adminModeRec;
        }
        
        private String getFlagFieldName() {
            String result=null;
            SObject adminModeSetting = getAdminModeRec();
            
            if(adminModeSetting!=null) {
                String sObjName = adminModeSetting.getSObjectType().getDescribe().getName().toUpperCase();
                result = adminModeMetadata.get(sObjName).flagField;
            }
            
            return result;
        }
    }
    
    public class CustomActionHandler implements 
            CORE_Merge_Interface.CustomMergeEngineListnerInterface,
            CORE_Merge_Interface.CustomValidationInterface,
            CORE_Merge_Interface.CustomFieldTransferInterface,
            CORE_Merge_Interface.CustomPreMergeActionInterface,
            CORE_Merge_Interface.CustomPostMergeActionInterface {
        
        public void mergeNotifyOnAction(CORE_Merge_Interface.MergeProcessState state, CORE_Merge_Interface.MergeObjectInterface mergeObject, List<CORE_Merge_Interface.MergeGroupInterface> mergeGroups, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            
        }
        
        public Boolean mergeValidate(String vrName, CORE_Merge_Interface.MergeObjectInterface mergeObject, CORE_Merge_Interface.MergeGroupInterface mergeGroup, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            Boolean isOk = true;
            
            if(vrName=='casesValidation') {

            }    
            
            return isOk;
        }
        
        public Object mergeTransferField(String fieldName, CORE_Merge_Interface.MergeObjectInterface mergeObject, CORE_Merge_Interface.MergeGroupInterface mergeGroup, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            Object result = null;
            
            if(mergeObject.getSObjectName()=='Case') {
                if(fieldName=='SuppliedName') {
                    result = mergeGroup.getWinnerCandidate().getSourceRecord().get('SuppliedName');
                } 
            }
            
            return result;
        }
        
        public Boolean mergeExecutePreAction(String actionName, CORE_Merge_Interface.MergeObjectInterface mergeObject, CORE_Merge_Interface.MergeGroupInterface mergeGroup, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            Boolean winnerChanged = false;
            
            if(mergeObject.getSObjectName()=='Account') {
                if(actionName=='action1') {
                    
                } 
            }
            
            return winnerChanged;
        }
        
        public void mergeExecutePostAction(String actionName, CORE_Merge_Interface.MergeObjectInterface mergeObject, CORE_Merge_Interface.MergeGroupInterface mergeGroup, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            if(mergeObject.getSObjectName()=='Account') {
                if(actionName=='action1') {
                    
                } 
            }
        }
    }
}