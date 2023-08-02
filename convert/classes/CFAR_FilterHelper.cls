public class CFAR_FilterHelper {
    public static final Id RT_CLINICAL = Schema.SObjectType.CFAR_Filter_gne__c.getRecordTypeInfosByName().get('gSTAR Clinical').getRecordTypeId();
    public static final Id RT_TEAMCONTACTS = Schema.SObjectType.CFAR_Filter_gne__c.getRecordTypeInfosByName().get('gStars TeamContacts').getRecordTypeId();

    public static void saveFilter(
        Map <String, List<String>> stringToSelected, 
        String filterName, 
        Id filterId, 
        Id recordTypeId
    ) {
        Savepoint sp = Database.setSavepoint();
        String msg;
        try {
            CFAR_Filter_gne__c filter = (filterId == null) ? 
                new CFAR_Filter_gne__c(Name = filterName, RecordTypeId = recordTypeId) : 
                new CFAR_Filter_gne__c(Id = filterId, Name = filterName, RecordTypeId = recordTypeId);
            upsert filter;

            if(String.isNotBlank(filterId)) {
                List<CFAR_Filter_Option_gne__c> options = [
                    SELECT Id, Field_Name_gne__c, Value_gne__c 
                    FROM CFAR_Filter_Option_gne__c 
                    WHERE CFAR_Filter_ref_gne__c = :filterId
                ];
                if(options != null && !options.isEmpty()){
                    CFAR_SecurityUtils.deleteRecords(options);
                }
            }
            filterId = filter.Id;
            List<CFAR_Filter_Option_gne__c> newFilterOptions = collectParameters(stringToSelected, filterId);
            insert newFilterOptions;
        } catch (Exception e) {
            Database.rollback(sp);
            CFAR_Utils.logError(e, filterId);
            msg = e.getMessage();
        }
    } 

    private static List<CFAR_Filter_Option_gne__c> collectParameters(Map<String, List<String>> stringToSelected, Id filterId ){
        List<CFAR_Filter_Option_gne__c> fOptions = new List<CFAR_Filter_Option_gne__c>();
        for(String param: stringToSelected.keySet()){
            if(stringToSelected.get(param) == null){
                continue;
            }
            for(String value : stringToSelected.get(param)){
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = param, Value_gne__c = value));
            }
        }
        return fOptions;
    }
}