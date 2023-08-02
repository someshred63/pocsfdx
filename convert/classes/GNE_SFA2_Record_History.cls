public with sharing class GNE_SFA2_Record_History {
    private final static Integer PAGE_SIZE = 5;
    
    public Integer pageSize {get; set;}
    public Integer numnberOfbatches {get; set;}
    public Integer currentBatchNumber {get; set;} 
    private Integer offset {get; set;}
    private String recordId {get; set;}
    private String objectName {get; set;}
    public String objectLabel {get; set;}
    private String idFieldName {get; set;}
    private Map<String, String> parentObjFieldsMap {get; set;}
    public String historyObjectName {get;  set;}
    public String userIdToViewLink {get;set;}
    private Boolean isInitialized = false;

    public Boolean hasPrevious{
        get{
            if(currentBatchNumber == 1) return false;
            else return true;
        }
    }
    
    public Boolean hasNext{
        get{
            if(currentBatchNumber >= numnberOfbatches ) return false;
            else return true;
        }
    }
    public GNE_SFA2_Record_History(){
        //recordId = System.currentPageReference().getParameters().get('id');
        //init();
    } 
    
    public void init(){
        isInitialized=true;
        recordId = System.currentPageReference().getParameters().get('id');
        pageSize = PAGE_SIZE;
        for(String objName : Schema.getGlobalDescribe().keySet()){
            Schema.DescribeSObjectResult localDescribe=  Schema.getGlobalDescribe().get(objName).getDescribe();
            if(recordId.substring(0,3).equals(localDescribe.getKeyPrefix())){
                objectName = localDescribe.getLocalName();
                objectLabel = localDescribe.getLabel();

                Map<String, Schema.SObjectField> objectFieldsDescribe = localDescribe.fields.getMap();
                if(objectName.endsWith('__c')){
                    historyObjectName = objectName.removeEnd('__c')+'__History';
                    idFieldName = 'ParentID';
                }else{
                     historyObjectName = objectName+'History';
                     idFieldName = objectName+'Id';
                }
                if(Schema.getGlobalDescribe().get(historyObjectName.toLowerCase()) == null ){
                    historyObjectName = null;
                } else {
                    if(parentObjFieldsMap == null){
                    	parentObjFieldsMap = new Map<String, String>();
                    }
                    for(String fieldName : objectFieldsDescribe.keySet()){
                        parentObjFieldsMap.put(fieldName, objectFieldsDescribe.get(fieldName).getDescribe().getLabel());
                    }
                    numnberOfbatches = calculateNumberOfBatches();
                }
                break;
            }
        }
        currentBatchNumber = 1;
        offSet = 0;
    }
    
    public Integer getRecordCount(){
        if(!isInitialized){
            return -1;
        }
        String queryString = 'select count()  from '+ historyObjectName +' where ' + idFieldName + '=\'' + recordId +'\'';
        return Database.countQuery(queryString);
    }
    
    public Integer calculateNumberOfBatches(){
        Decimal temp = (1.0 * getRecordCount()/PAGE_SIZE);
        return temp.round(System.RoundingMode.UP).intValue();
    }

    public List<HistoryWrapper> getRecords(){
        if(!isInitialized){
            return new List<HistoryWrapper>();
        }
        List<SObject> queriedData  = new List<SObject>();
        List<HistoryWrapper> wrapperObjects = new List<HistoryWrapper>();
        if(historyObjectName != null){
            String query = buildQueryString(); 
            queriedData = Database.query(query); 
            
            for(SObject obj : queriedData){
                String fieldApiName = String.valueOf(obj.get('Field'));
                String fieldLabel = parentObjFieldsMap.get(fieldApiName.toLowerCase());
                if(fieldLabel != null){
                    HistoryWrapper wrapper= new HistoryWrapper();
                    wrapper.fieldLabel = fieldLabel;
                    wrapper.historyObject = obj;
                    wrapperObjects.add(wrapper);
                } else{
                    HistoryWrapper wrapper= new HistoryWrapper();
                    wrapper.fieldLabel = fieldApiName=='created'?'Created':fieldApiName;
                    wrapper.historyObject = obj;
                    wrapperObjects.add(wrapper);
                }
            }
        }
        
        return wrapperObjects;
    }
    
    public String buildQueryString(){
        String queryString = 'select Id, IsDeleted, '+ idFieldName + ', CreatedById,CreatedBy.Name, CreatedDate, Field, OldValue, NewValue from '+ historyObjectName +' where ' + idFieldName + '=\'' + recordId + '\' Order by CreatedDate desc ' +' limit '+ PAGE_SIZE +' offset  ' + offset ;
        System.debug('@@@@@@' + queryString);
        return queryString; 
    }
    public Pagereference next(){
        currentBatchNumber += 1;
        offset+=PAGE_SIZE;
        return null;
    }
    public Pagereference previous(){
        currentBatchNumber -= 1;
        offset -= PAGE_SIZE;
        return null;
    }
    public Pagereference changeBatch(){
        if(currentBatchNumber >=1) offset = (currentBatchNumber - 1)* PAGE_SIZE;
        return null;
    }
    
    public class HistoryWrapper{
        public String fieldLabel {get; set;}
        public SObject historyObject {get; set;}    
    }
    
    public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref; 
    } 
    
    public pageReference first(){
        currentBatchNumber = 1;
        offset = 0;
        return null;
    }
    public pageReference last(){
        currentBatchNumber = numnberOfbatches ;
        offset = (currentBatchNumber - 1)* pageSize;
        return null;
    }
}