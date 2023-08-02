public without sharing class GNE_CM_MHRA_Case_Util
{
    private static Set<String> fields2Hide = new Set<String> { 'Id', 'Name', 'CaseNumber', 'Subject', 'IsDeleted', 'IsLocked', 'MayEdit', 'SpringCM_PoC__c', 'IsHighPriority', 'ConnectionReceived', 'ConnectionSent', 'ConnectionReceivedId', 'ConnectionSentId'};
    
    public static Map<String, String> getSObjectLabelMap(String objectName)
    {
         //Getting field list for the sObject 
        Map<String, String> objectLabels =  new Map<String, String>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        Schema.sObjectType sObjType = globalDescription.get(objectName);
 
        Schema.DescribeSObjectResult res = sObjType.getDescribe();
 
        Map<String , Schema.SObjectField> mapFieldList = res.fields.getMap();
        for(Schema.SObjectField field : mapFieldList.values())
        {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            objectLabels.put(fieldResult.getName(), fieldResult.getLabel());
        }
        return objectLabels;
    }

    public static List<String> getSObjectFieldList(String objectName)
    {
         //Getting field list for the sObject 
        List<String> objectFields =  new List<String>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        Schema.sObjectType sObjType = globalDescription.get(objectName);
 
        Schema.DescribeSObjectResult res = sObjType.getDescribe();
 
        Map<String , Schema.SObjectField> mapFieldList = res.fields.getMap();
        for(Schema.SObjectField field : mapFieldList.values())
        {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            if(fieldResult.isAccessible() && !fields2Hide.contains(fieldResult.getName()))
            {
                objectFields.add(fieldResult.getName());
            }
        }
        return objectFields;
    }

    public static String getSObjectList(String objectName, List<String> objectFields, String relationToCase, String caseId)
    {
        if (caseId == null)
        {
            throw new GNE_CM_Exception('Cannot call getSObjectList with empty ID for object ' + objectName); 
        }
        
        //Building Query with the fields
        Integer i = 0;
        String fieldsToFetch = '';
        Integer len = objectFields.size();

        for(String temp:objectFields)
        {
            if(i==len-1)
            {
                  fieldsToFetch = fieldsToFetch + temp;
            }
            else
            {
                  fieldsToFetch = fieldsToFetch + temp + ',';
            }
            i++;
        }
        String qryStr = 'Select ' + fieldsToFetch + ' From ' + objectName + ' WHERE ' + relationToCase + '= \'' + caseId + '\'';
        return  qryStr;
    }
    
    public static String getListOfSObjectList(String objectName, List<String> objectFields, String relationToCase)
    {
        //Building Query with the fields
        Integer i = 0;
        String fieldsToFetch = '';
        Integer len = objectFields.size();

        for(String temp:objectFields)
        {
            if(i==len-1)
            {
                  fieldsToFetch = fieldsToFetch + temp;
            }
            else
            {
                  fieldsToFetch = fieldsToFetch + temp + ',';
            }
            i++;
        }
        String qryStr = 'Select ' + fieldsToFetch + ' From ' + objectName + ' WHERE ' + relationToCase + ' IN :XXXXXXXXXXXXXXX';
        return  qryStr;
    }
    
    public static String getActivitiesList(List<String> activityHistoryObjectFields, List<String> openActivitiesObjectFields, String caseId)
    {
        //Building Query with the fields
        Integer i = 0;
        String ahFieldsToFetch = '';
        Integer ahLen = activityHistoryObjectFields.size();

        for(String temp:activityHistoryObjectFields)
        {
            if(i==ahLen-1)
            {
                  ahFieldsToFetch = ahFieldsToFetch + temp;
            }
            else
            {
                  ahFieldsToFetch = ahFieldsToFetch + temp + ',';
            }
            i++;
        }
        
        Integer j = 0;
        String oaFieldsToFetch = '';
        Integer oaLen = openActivitiesObjectFields.size();

        for(String temp:openActivitiesObjectFields)
        {
            if(j==oaLen-1)
            {
                  oaFieldsToFetch = oaFieldsToFetch + temp;
            }
            else
            {
                  oaFieldsToFetch = oaFieldsToFetch + temp + ',';
            }
            j++;
        }
        String qryStr = 'Select id, (Select ' + ahFieldsToFetch + ' From ActivityHistories), (Select ' + oaFieldsToFetch + ' From OpenActivities) FROM Case  WHERE id ' + '= \'' + caseId + '\'';
        return  qryStr;
    }
    
    public static String implodeWithPrefix (List<String> items, String prefix)
    {
    	List<String> prefixedItems = new List<String>();
    	for (String item : items)
    	{
    		prefixedItems.add(prefix + item);
    	}
    	
    	return GlobalUtils.implode(prefixedItems, ', ');
    }
    
    public static list<Account> initAccountObject(Case caseRecord, list<String> accountFields)
    {
        set<Id> accountIds = new set <Id>();

        if (caseRecord.AccountId != null)
        {
            accountIds.add(caseRecord.AccountId);
        }
        if (caseRecord.Facility_gne__c != null)
        {
            accountIds.add(caseRecord.Facility_gne__c);
        }
        if (caseRecord.Practice_gne__c != null)
        {
            accountIds.add(caseRecord.Practice_gne__c);
        }
        if (caseRecord.Case_Treating_Physician_gne__c != null)
        {
            accountIds.add(caseRecord.Case_Treating_Physician_gne__c);
        }
        if (caseRecord.Referred_By_Party_gne__c != null)
        {
            accountIds.add(caseRecord.Referred_By_Party_gne__c);
        }
        if (caseRecord.Site_of_Treatment_Name_gne__c != null)
        {
            accountIds.add(caseRecord.Site_of_Treatment_Name_gne__c);
        }
        
        String accountSOQL = GNE_CM_MHRA_Case_Util.getListOfSObjectList('Account', accountFields, 'id');
        return Database.query(accountSOQL.replace('XXXXXXXXXXXXXXX','accountIds'));
    }   

    public static list<Address_vod__c> initAddressObject(Case caseRecord, List<Account>accountList, list<String> addressFields)
    {
        String addressSOQL = GNE_CM_MHRA_Case_Util.getListOfSObjectList('Address_vod__c', addressFields, 'Account_vod__c');
        if (caseRecord.Address_gne__c != null)
        {
            addressSOQL += ' OR id = \'' + caseRecord.Address_gne__c + '\'';
        }
        
        if (caseRecord.Referral_Address_Line_1_gne__c != null)
        {
             addressSOQL += ' OR id = \'' + caseRecord.Referral_Address_Line_1_gne__c + '\'';
        }
        
        if (caseRecord.Site_of_Treatment_addr1_gne__c != null)
        {
             addressSOQL += ' OR id = \'' + caseRecord.Site_of_Treatment_addr1_gne__c + '\'';
        }
        return Database.query(addressSOQL.replace('XXXXXXXXXXXXXXX','accountList'));
       
    }

    public static void addIds2Set(Set<String> ids, List<sObject> objs)
    {
        for (sObject sobj : objs)
        {
            ids.add(sobj.Id);
        }
    }
}