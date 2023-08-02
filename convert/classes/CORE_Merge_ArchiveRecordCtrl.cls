public with sharing class CORE_Merge_ArchiveRecordCtrl {
    public Id masterId {get; private set; }
    public Id selectedRecordId {get; set;}
    public List<SelectOption> viewOptions {get; private set; }
    public Map<Id,SourceRecordWrapper> sourceRecords {get; private set; }
    public List<String> sourceFieldNames {get; private set; }
    public List<String> relatedListNames {get; private set; }
    public Boolean canUnmerge {get; private set;}
    
    private transient List<CORE_Merge_Archive_Record__c> archiveRecords;
    private transient Map<Id,List<SObject>> archiveChildRecords;
    private transient Map<Id,List<CORE_Merge_Archive_JSON_Part__c>> archiveJsonParts;
    private static final Integer RELATED_LIST_MAX_COLUMNS = 10;
    private static final Integer RELATED_LIST_MAX_RECORDS = 100;
    
    public CORE_Merge_ArchiveRecordCtrl(ApexPages.StandardController controller) {
        this(controller.getRecord().Id);
    }
    
    public CORE_Merge_ArchiveRecordCtrl() {
        this((Id)null);
    }
    
    public CORE_Merge_ArchiveRecordCtrl(Id archiveRecId) {
        if(archiveRecId==null && ApexPages.currentPage()!=null) {
            String recId = ApexPages.currentPage().getParameters().get('id');
            archiveRecId = recId!=null && recId instanceof Id ? (Id)recId : null; 
        }
        
        this.viewOptions = new List<SelectOption>();
        this.canUnmerge = true;
        this.archiveChildRecords = new Map<Id,List<SObject>>();
        this.archiveJsonParts = new Map<Id,List<CORE_Merge_Archive_JSON_Part__c>>();
        
        try {
	        this.archiveRecords = getArchiveRecords(archiveRecId);
	        this.viewOptions.add(new SelectOption(masterId, 'Archive Record'));
	        if(!archiveRecords.isEmpty()) {
	            createSourceRecords();
	        }
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString()));
        }
    }
    
    private List<CORE_Merge_Archive_Record__c> getArchiveRecords(Id archiveRecId) {
        List<CORE_Merge_Archive_Record__c> result;
        this.masterId = null;
        
        if(archiveRecId!=null) {
	        List<CORE_Merge_Archive_Record__c> recs = [
	            SELECT Id, Master_Archive_Record_gne__c
	            FROM CORE_Merge_Archive_Record__c
	            WHERE Id = :archiveRecId
	        ];
	        
	        this.masterId = recs.isEmpty() ? null : String.isNotBlank(recs[0].Master_Archive_Record_gne__c) ? recs[0].Master_Archive_Record_gne__c : recs[0].Id;
        }
        
        if(masterId!=null) {
	        result = [
	            SELECT Id, Name, Master_Archive_Record_gne__c, Id_gne__c, Master_Id_gne__c, Value_json_gne__c,
	               Merge_Object_gne__r.Object_Type_gne__c, Merge_Object_gne__r.Object_Name_gne__c
	            FROM CORE_Merge_Archive_Record__c
	            WHERE Id = :this.masterId OR Master_Archive_Record_gne__c = :this.masterId
	            ORDER BY Master_Archive_Record_gne__c, Id
            ];
	        
            List<SObject> childRecs = new List<SObject>((List<SObject>)[
                SELECT Id, Name, Id_gne__c, Object_Type_gne__c, Field_Name_gne__c, Relationship_Name_gne__c, Value_json_gne__c, 
                    Merge_Archive_Record_gne__c, Merge_Archive_Record_gne__r.Id_gne__c, Merge_Archive_Record_gne__r.Master_Id_gne__c
                FROM CORE_Merge_Archive_App_Record__c
                WHERE Merge_Archive_Record_gne__c = :this.masterId OR Merge_Archive_Record_gne__r.Master_Archive_Record_gne__c = :this.masterId
	        ]);
	        
	        childRecs.addAll((List<SObject>)[
                SELECT Id, Name, Id_gne__c, Object_Type_gne__c, Field_Name_gne__c, Relationship_Name_gne__c, Value_json_gne__c, 
                    Merge_Archive_Record_gne__c, Merge_Archive_Record_gne__r.Id_gne__c, Merge_Archive_Record_gne__r.Master_Id_gne__c
                FROM CORE_Merge_Archive_Child_Record__c
                WHERE Merge_Archive_Record_gne__c = :this.masterId OR Merge_Archive_Record_gne__r.Master_Archive_Record_gne__c = :this.masterId
            ]);
            
            for(SObject childRec : childRecs) {
                Id parentId = (Id)childRec.get(String.valueOf(CORE_Merge_Archive_Child_Record__c.Merge_Archive_Record_gne__c));
                String objType = (String)childRec.get(String.valueOf(CORE_Merge_Archive_Child_Record__c.Object_Type_gne__c));
                
                if(objType!=null && !objType.endsWithIgnoreCase('History')) {
	                if(!this.archiveChildRecords.containsKey(parentId)) {
	                    this.archiveChildRecords.put(parentId, new List<SObject>());
	                }
	                
	                this.archiveChildRecords.get(parentId).add(childRec);
                }
            }
            
            List<CORE_Merge_Archive_JSON_Part__c> jsonParts = [
                SELECT Part_No_gne__c, Value_json_gne__c, Merge_Archive_Record_gne__c, Merge_Archive_App_Record_gne__c, Merge_Archive_Child_Record_gne__c
                FROM CORE_Merge_Archive_JSON_Part__c
                WHERE Merge_Archive_Record_gne__c = :this.masterId OR Merge_Archive_Record_gne__r.Master_Archive_Record_gne__c = :this.masterId
                ORDER BY Merge_Archive_App_Record_gne__c, Merge_Archive_Child_Record_gne__c, Part_No_gne__c
            ];
            
            for(CORE_Merge_Archive_JSON_Part__c jsonPart : jsonParts) {
                Id parentId = jsonPart.Merge_Archive_App_Record_gne__c!=null ? jsonPart.Merge_Archive_App_Record_gne__c : (jsonPart.Merge_Archive_Child_Record_gne__c!=null ? jsonPart.Merge_Archive_Child_Record_gne__c : jsonPart.Merge_Archive_Record_gne__c);
                
                if(!this.archiveJsonParts.containsKey(parentId)) {
                    this.archiveJsonParts.put(parentId, new List<SObject>());
                }
                
                this.archiveJsonParts.get(parentId).add(jsonPart);
            }
        }
        
         
        return result!=null ? result : new List<CORE_Merge_Archive_Record__c>();
    }
    
    private void createSourceRecords() {
        Integer loserIdx = 1;
        this.sourceRecords = new Map<Id,SourceRecordWrapper>();
        this.sourceFieldNames = new List<String>();
        this.selectedRecordId = masterId;
        
        Map<String,RelatedList> rlsMap = new Map<String,RelatedList>();
        
        for(CORE_Merge_Archive_Record__c aRec : archiveRecords) {
            Boolean isWinner = aRec.Id_gne__c==aRec.Master_Id_gne__c;
            String jsonValue = getJsonValue(aRec.Value_json_gne__c, aRec.Id);
            SObject sourceRec = String.isNotBlank(jsonValue)
                    ? (SObject)JSON.deserialize(jsonValue, Type.forName(aRec.Merge_Object_gne__r.Object_Type_gne__c)) 
                    : (SObject)Type.forName(aRec.Merge_Object_gne__r.Object_Type_gne__c).newInstance();
            sourceRec.Id = aRec.Id_gne__c;
            Set<String> fieldNames = getFieldNames(sourceRec, jsonValue);
            
            if(isWinner) {
                this.sourceFieldNames = new List<String>(fieldNames);
                this.sourceFieldNames.sort();
            }
            
            SourceRecordWrapper sWrapper = new SourceRecordWrapper(aRec.Id, aRec.Name, aRec.Merge_Object_gne__r.Object_Type_gne__c, isWinner ? 'WINNER' : 'LOSER ' + loserIdx++, sourceRec);
            createRelatedLists(aRec, sWrapper);
            rlsMap.putAll(sWrapper.relatedLists);
            this.sourceRecords.put(sWrapper.record.Id, sWrapper);
            this.viewOptions.add(new SelectOption(sWrapper.record.Id, sWrapper.description));
        }
        
        for(String rlName : rlsMap.keySet()) {
            for(SourceRecordWrapper sWrapper : this.sourceRecords.values()) {
                if(!sWrapper.relatedLists.containsKey(rlName)) {
                    sWrapper.addRelatedList(new RelatedList(rlsMap.get(rlName)));
                }
            }
        }
        
        this.relatedListNames = new List<String>(rlsMap.keySet());
        this.relatedListNames.sort();
    }
    
    private String getJsonValue(String jsonValue, Id archiveId) {
        String result = jsonValue;
        
        if(String.isNotBlank(result) && this.archiveJsonParts.containsKey(archiveId)) {
            result = result.mid(1,result.length()-2);
            for(CORE_Merge_Archive_JSON_Part__c jsonPart : this.archiveJsonParts.get(archiveId)) {
                if(String.isNotBlank(jsonPart.Value_json_gne__c)) {
                    result+=jsonPart.Value_json_gne__c.mid(1,jsonPart.Value_json_gne__c.length()-2);
                }
            }
        }
        
        return result;
    }
    
    private Set<String> getFieldNames(SObject sourceRec, String jsonFieldValue) {
        Map<String,Object> fieldValues = String.isNotBlank(jsonFieldValue) ? (Map<String,Object>)JSON.deserializeUntyped(jsonFieldValue) : new Map<String,Object>();
        Set<String> fieldNames = new Set<String>(fieldValues.keySet());
        return fieldNames;  
    }
    
    private void createRelatedLists(CORE_Merge_Archive_Record__c aRec, SourceRecordWrapper sWrapper) {
        List<ArchiveChildRecordWrapper> childWrappers = new List<ArchiveChildRecordWrapper>();
        
        if(this.archiveChildRecords.containsKey(aRec.Id)) {
            for(SObject childRec : this.archiveChildRecords.get(aRec.Id)) {
                if(childRec instanceof CORE_Merge_Archive_App_Record__c) {
                    childWrappers.add(new ArchiveChildRecordWrapper((CORE_Merge_Archive_App_Record__c)childRec));
                } else {
                    childWrappers.add(new ArchiveChildRecordWrapper((CORE_Merge_Archive_Child_Record__c)childRec));
                }
            }
        }
        
        ArchiveChildRecordWrapper lastChildWrapper;
        List<SourceRecordWrapper> rlListRecords = new List<SourceRecordWrapper>();
        List<String> rlColumnNames = new List<String>();
        
        for(Integer idx=0;idx<=childWrappers.size();idx++) {
            ArchiveChildRecordWrapper childWrapper = idx==childWrappers.size() ? null : childWrappers[idx];
            
            if(lastChildWrapper!=null && (childWrapper==null || childWrapper.relationshipName!=lastChildWrapper.relationshipName)) {
                RelatedList rl = new RelatedList(lastChildWrapper, rlColumnNames, rlListRecords);
                sWrapper.addRelatedList(rl);
                rlListRecords = new List<SourceRecordWrapper>();
                rlColumnNames = new List<String>();
            }
            
            lastChildWrapper = childWrapper;
            
            if(childWrapper!=null) {
                String jsonValue = getJsonValue(childWrapper.json, childWrapper.archiveId);
                SObject sourceRec = String.isNotBlank(jsonValue) ? (SObject)JSON.deserialize(jsonValue, Type.forName(childWrapper.objectType)) : (SObject)Type.forName(childWrapper.objectType).newInstance();
                sourceRec.Id = childWrapper.id;
                Set<String> fieldNames = getFieldNames(sourceRec, jsonValue);
                rlColumnNames = new List<String>(fieldNames);
                SourceRecordWrapper childRecWrapper = new SourceRecordWrapper(childWrapper.archiveId, childWrapper.archiveName, childWrapper.objectType, null, sourceRec);
                childRecWrapper.relatedLists = null;
                rlListRecords.add(childRecWrapper);
            }
        }
    }
    
    public PageReference unmerge() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Unmerge - TBD'));
        return null;
    }
    
    private class ArchiveChildRecordWrapper {
        private String archiveId;
        private String archiveName;
        private String id;
        private String relationshipName;
        private String fieldName;
        private String objectType;
        private String json;
        
        private ArchiveChildRecordWrapper(CORE_Merge_Archive_App_Record__c appRec) {
            this(appRec.Id, appRec.Name, appRec.Id_gne__c, appRec.Field_Name_gne__c, appRec.Relationship_Name_gne__c, appRec.Object_Type_gne__c, appRec.Value_json_gne__c);
        }
        
        private ArchiveChildRecordWrapper(CORE_Merge_Archive_Child_Record__c childRec) {
            this(childRec.Id, childRec.Name, childRec.Id_gne__c, childRec.Field_Name_gne__c, childRec.Relationship_Name_gne__c, childRec.Object_Type_gne__c, childRec.Value_json_gne__c);
        }
        
        private ArchiveChildRecordWrapper(String archiveId, String archiveName, String id, String fieldName, String relationshipName, String objectType, String json) {
            this.archiveId = archiveId;
            this.archiveName = archiveName;
            this.id = id;
            this.fieldName = fieldName;
            this.relationshipName = relationshipName;
            this.objectType = objectType;
            this.json = json;
        }
    }
    
    public class SourceRecordWrapper {
        public String sObjectType {get; private set;}
        public String description {get; private set;}
        public String name {get; private set;}
        public Id archiveId {get; private set;}
        public String archiveName {get; private set;}
        public SOBject record {get; private set;}
        public Map<String,RelatedList> relatedLists {get; private set;}
        
        public SourceRecordWrapper(String archiveId, String archiveName, String sObjectType, String description, SObject record) {
            this.archiveId = archiveId;
            this.archiveName = archiveName;
            this.sObjectType = sObjectType;
            this.name = this.description = String.isNotBlank(description) ? description : record.Id;
            this.record = record;
            this.relatedLists = new Map<String,RelatedList>();
            
            try {
                this.name = (String)this.record.get('Name');
                this.name = String.isNotBlank(this.name) ? this.name : this.description;
            } catch(Exception ex) {}
        }
        
        public void addRelatedList(RelatedList rl) {
            this.relatedLists.put(rl.name, rl);
        }
    }
    
    public class RelatedList {
        public String name {get; private set;}
        public String fieldName {get; private set;}
        public String sObjectType {get; private set;}
        public List<String> columnNames {get; private set;}
        public List<SourceRecordWrapper> records {get; private set;}
        public Boolean columnsTruncated {get; private set;}
        public Boolean recordsTruncated {get; private set;}
        
        public RelatedList(String name, String fieldName, String sObjectType, List<String> columnNames, List<SourceRecordWrapper> records) {
            this.name = name;
            this.fieldName = fieldName;
            this.sObjectType = sObjectType;
            this.columnNames = columnNames;
            this.columnNames.sort();
            this.columnsTruncated = false;
            
            if(this.columnNames.size()>RELATED_LIST_MAX_COLUMNS) {
                this.columnsTruncated = true;
                
                for(Integer idx=this.columnNames.size()-1;idx>=RELATED_LIST_MAX_COLUMNS;idx--) {
                    this.columnNames.remove(idx);
                }
            }
            
            this.records = records;
            this.recordsTruncated = false;
            
            if(this.records.size()>RELATED_LIST_MAX_RECORDS) {
                this.recordsTruncated = true;
                
                for(Integer idx=this.records.size()-1;idx>=RELATED_LIST_MAX_RECORDS;idx--) {
                    this.records.remove(idx);
                }
            }
        }
        
        public RelatedList(ArchiveChildRecordWrapper childRecWrapper, List<String> columnNames, List<SourceRecordWrapper> records) {
            this(childRecWrapper.relationshipName, childRecWrapper.fieldName, childRecWrapper.objectType, columnNames, records);
        }
        
        public RelatedList(RelatedList other) {
            this(other.name, other.fieldName, other.sObjectType, other.columnNames, new List<SourceRecordWrapper>());
        }
    }
}