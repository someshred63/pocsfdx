global class Merge_Type_Engine_Batch_Scheduler implements Schedulable{
    private Integer regionCode;
    private static final Set<Integer> APPLICABLE_REGIONS = new Set<Integer>{2};
    private MergeTypeWrapper [] orderedObjectsToExecute;
    private Merge_Type_gne__c[] objectsToExecute;
    private static Map <Integer, MergeTypeWrapper> executionOrder2MergeType = new Map <Integer, MergeTypeWrapper> {
        1 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_MERGE, 'Account : Canada'),
        2 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_MERGE, 'Person Account : Canada'),    
        3 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_MERGE, 'Account Address : Canada'),
        4 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_MERGE, 'Person Account Address : Canada'),
        5 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_INSERT_CANDIDATES, 'Territory Fields : Canada'),
        6 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_MERGE, 'Territory Fields : Canada'),
        7 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_INSERT_CANDIDATES, 'Targets and Tiers : Canada'),
        8 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_MERGE, 'Targets and Tiers : Canada'),
        9 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_INSERT_CANDIDATES, 'Affiliation : Canada'),
        10 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_MERGE, 'Affiliation : Canada'),
        11 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_INSERT_CANDIDATES, 'Brand Affiliations : Canada'),
        12 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_MERGE, 'Brand Affiliations : Canada'),
        13 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_INSERT_CANDIDATES, 'OTR User Preference : Canada'),
        14 => new MergeTypeWrapper(Merge_Type_Util.APEX_JOB_TYPE_MERGE, 'OTR User Preference : Canada')
    };
    
    global Merge_Type_Engine_Batch_Scheduler(Integer regionCode) {
        this.regionCode = regionCode;
        if(!APPLICABLE_REGIONS.contains(regionCode)){
            throw new EmptyListException('Region Code '+regionCode + ' is not applicable for this Scheduler class.');
        }
        objectsToExecute = [SELECT Id, Name,Object_Name_gne__c, Unique_Name_gne__c FROM Merge_Type_gne__c WHERE Region_Code_gne__c =:regionCode];
        if(objectsToExecute.isEmpty()){
            throw new EmptyListException('No records of Merge_Type_gne__c sObject found for Region Code '+regionCode); 
        }
    }
    
    global void execute(SchedulableContext sc) {
        if(objectsToExecute.isEmpty()){
            throw new EmptyListException('No records of Merge_Type_gne__c sObject found for Region Code '+regionCode); 
        }
        
		orderedObjectsToExecute = prepareCollection();
        Merge_Type_gne__c mergeType = orderedObjectsToExecute[0].mergeType;
        Merge_Type_Apex_Job_gne__c job = new Merge_Type_Apex_Job_gne__c(Merge_Type_ref_gne__c = mergeType.Id, Apex_Job_Type_gne__c = Merge_Type_Util.APEX_JOB_TYPE_MERGE);
		insert job;
        Merge_Type_Engine_Batch asyncJob = new Merge_Type_Engine_Batch(orderedObjectsToExecute, mergeType, false, job);
        Database.executeBatch (asyncJob, 10);
    }
    
    private MergeTypeWrapper [] prepareCollection() {
        MergeTypeWrapper [] result = new MergeTypeWrapper []{};
        Map<String, Merge_Type_gne__c> uniqueName2MergeType = fetchUniqueName2MergeType();
        List<Integer> sortedOrder = new List<Integer>();
        for(Integer key: executionOrder2MergeType.keySet()){
            sortedOrder.add(key);
            MergeTypeWrapper mtw = executionOrder2MergeType.get(key);
            if(uniqueName2MergeType.get(mtw.uniqueName) != null) {
                Merge_Type_gne__c mt = uniqueName2MergeType.get(mtw.uniqueName);
                mtw.mergeType = mt;
                executionOrder2MergeType.put(key, mtw);
            }
        }
        sortedOrder.sort();
        for(Integer order : sortedOrder){
            MergeTypeWrapper mtw = executionOrder2MergeType.get(order);
            if(mtw.isMergeTypeSet())result.add(mtw);
        }
        return result;    
    }
    
    private Map<String, Merge_Type_gne__c> fetchUniqueName2MergeType() {
        Map<String, Merge_Type_gne__c> uniqueName2MergeType = new Map<String, Merge_Type_gne__c>();
        for(Merge_Type_gne__c mt :objectsToExecute){
            uniqueName2MergeType.put(mt.Unique_Name_gne__c, mt);
        }
        return uniqueName2MergeType;
    }
    
    class EmptyListException extends Exception{}
    
    global class MergeTypeWrapper {
        global Merge_Type_gne__c mergeType {get;set;}
        global String apexJobType {get;set;} 
		global String uniqueName {get;set;}     
        
        global MergeTypeWrapper(String apexJobType, String uniqueName) {
            this.apexJobType = apexJobType;
            this.uniqueName = uniqueName;
        }
        
        global Boolean isMergeTypeSet() {
            return mergeType != null;
        }
    }    
}