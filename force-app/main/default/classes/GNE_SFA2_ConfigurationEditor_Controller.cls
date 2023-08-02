public with sharing class GNE_SFA2_ConfigurationEditor_Controller {
    
    @RemoteAction
    public static Map<SFA2_Configuration_Object_gne__c, List<SFA2_Configuration_Object_Detail_gne__c>>getPageConfiguration(String applicationType,  String objectName, String recordType, String brand, String role){
        Map<SFA2_Configuration_Object_gne__c, List<SFA2_Configuration_Object_Detail_gne__c>> result = new Map<SFA2_Configuration_Object_gne__c, List<SFA2_Configuration_Object_Detail_gne__c>>();
        
        List<SFA2_Configuration_Object_gne__c>config = [SELECT  Id, Application_Type__c, Attributes_gne__c, Brand_gne__c, Configuration_Type_gne__c, Is_Active_gne__c, Is_Default_Record_Type_gne__c, Name,
                                                            Object_Name_gne__c, Order_gne__c, OTR2_gne__c, Record_Type_gne__c, Role_gne__c, RT_Available_On_Create_gne__c, Section_Header_gne__c, Style_gne__c,
                                                            (SELECT Id, API_Name_gne__c, Attributes_gne__c, Availability_Mode_gne__c, Configuration_Object_ref_gne__c, Is_Active_gne__c, Is_Read_Only_gne__c,
                                                            Is_Required_gne__c, Label_gne__c, Name, OTR2_gne__c, Order_gne__c, Style_gne__c, Type_gne__c from Configuration_Objects__r)
                                                        FROM SFA2_Configuration_Object_gne__c
                                                        WHERE Application_Type__c = :applicationType AND Object_Name_gne__c =:objectName AND Record_Type_gne__c =:recordType AND Brand_gne__c = :brand AND Role_gne__c= :role];
        
        for(SFA2_Configuration_Object_gne__c configObject: config){
            result.put(configObject, configObject.Configuration_Objects__r);
        }
        return result;
    }
    
    @RemoteAction
    public static void saveLayout(List<LayoutSectionWrapper> layout, String applicationType, String brand, String role, String objectName, String recordType){
    	system.debug(LoggingLevel.INFO, layout);
    	
		RecordType rt = [SELECT Id, Name, Description, DeveloperName, IsPersonType FROM RecordType WHERE id=:recordType];
    	system.debug(LoggingLevel.INFO, '*'+applicationType+'*, *'+brand+'*, *'+role+'*, *'+objectName+'*, *'+rt.DeveloperName+'*');
    	
    	Map<Id, SFA2_Configuration_Object_gne__c>config = new Map<Id,SFA2_Configuration_Object_gne__c>([SELECT Id, Application_Type__c, Attributes_gne__c, Brand_gne__c, Configuration_Type_gne__c, Is_Active_gne__c, Is_Default_Record_Type_gne__c, Name,
                                                            Object_Name_gne__c, Order_gne__c, OTR2_gne__c, Record_Type_gne__c, Role_gne__c, RT_Available_On_Create_gne__c, Section_Header_gne__c, Style_gne__c,
                                                            (SELECT Id, API_Name_gne__c, Attributes_gne__c, Availability_Mode_gne__c, Configuration_Object_ref_gne__c, Is_Active_gne__c, Is_Read_Only_gne__c,
                                                            Is_Required_gne__c, Label_gne__c, Name, OTR2_gne__c, Order_gne__c, Style_gne__c, Type_gne__c FROM Configuration_Objects__r WHERE Is_Active_gne__c=true)
                                                        FROM SFA2_Configuration_Object_gne__c
                                                        WHERE Application_Type__c = :applicationType AND Object_Name_gne__c =:objectName AND Record_Type_gne__c =:rt.DeveloperName AND Brand_gne__c = :brand AND Role_gne__c= :role AND Is_Active_gne__c=true]);
		
    	system.debug(LoggingLevel.INFO, 'config: '+config);
		Boolean isDefaultRecordType = false;
		Boolean isOtr = false;
		Boolean isRtAvailableOnCreate = false;
		if(!config.isEmpty()){
			isDefaultRecordType = config.values().get(0).Is_Default_Record_Type_gne__c;
			isOtr = config.values().get(0).OTR2_gne__c;
			isRtAvailableOnCreate = config.values().get(0).RT_Available_On_Create_gne__c;
		}	                                               
		                                                        
    	List<SFA2_Configuration_Object_gne__c>toUpdate = new List<SFA2_Configuration_Object_gne__c>();
    	List<SFA2_Configuration_Object_gne__c>toDelete = new List<SFA2_Configuration_Object_gne__c>();
    	
    	List<SFA2_Configuration_Object_Detail_gne__c>detailsToInsert = new List<SFA2_Configuration_Object_Detail_gne__c>();
    	List<SFA2_Configuration_Object_Detail_gne__c>detailsToUpdate = new List<SFA2_Configuration_Object_Detail_gne__c>();
    	List<SFA2_Configuration_Object_Detail_gne__c>detailsToDelete = new List<SFA2_Configuration_Object_Detail_gne__c>();
    	
    	for(LayoutSectionWrapper sectionWrapper: layout){
    		SFA2_Configuration_Object_gne__c sectionConfig = config.get(sectionWrapper.id);
    		system.debug(LoggingLevel.INFO, 'sectionWrapper: '+sectionWrapper.id+'; '+sectionWrapper.name);
    		system.debug(LoggingLevel.INFO, 'sectionConfig: '+sectionConfig);
    		if(sectionConfig == null){
    			sectionConfig = convertLayoutSectionWrapperToConfigObject(sectionWrapper, applicationType, brand, objectName, recordType, role, isDefaultRecordType, isOtr, isRtAvailableOnCreate);
    			insert sectionConfig;
    			for(LayoutItemWrapper item: sectionWrapper.items){
    				detailsToInsert.add(convertLayoutItemWrapperToConfigObjectDetail(item, sectionConfig.id));
    			}
    		}else{
    			if(isSectionUpdated(sectionWrapper, sectionConfig)){
    				sectionConfig.Section_Header_gne__c = htmlDecode(sectionWrapper.label);
    				sectionConfig.Order_gne__c = sectionWrapper.itemOrder;
    				toUpdate.add(sectionConfig);
    			}
    			List<SFA2_Configuration_Object_Detail_gne__c>details = sectionConfig.Configuration_Objects__r;
    			Map<Id, SFA2_Configuration_Object_Detail_gne__c>detailsMap = new Map<Id, SFA2_Configuration_Object_Detail_gne__c>();
    			for(SFA2_Configuration_Object_Detail_gne__c detail: details){
    				detailsMap.put(detail.id, detail);
    			}
    			List<LayoutItemWrapper>itemsWrapper =  sectionWrapper.items;
    			for(LayoutItemWrapper detailWrapper: itemsWrapper){
    				system.debug(LoggingLevel.INFO, detailWrapper);
    				if(detailWrapper.id!=null){
    					SFA2_Configuration_Object_Detail_gne__c detailConfig = detailsMap.remove(detailWrapper.id);
    					if(detailConfig != null){
    						if(isDetailChanged(detailConfig, detailWrapper)){
	    						copyDetailProperties(detailConfig, detailWrapper);
	    						detailsToUpdate.add(detailConfig);
    						}
    					}else{
    						system.debug(LoggingLevel.INFO, 'lk null: '+detailWrapper.id);
    					}
    					
    				}else{
    					system.debug(LoggingLevel.INFO, 'sectionConfig.id: '+sectionConfig.id);
    					SFA2_Configuration_Object_Detail_gne__c it = convertLayoutItemWrapperToConfigObjectDetail(detailWrapper, sectionConfig.id);
    					system.debug(LoggingLevel.INFO, it);
 						detailsToInsert.add(it);
    				}
    			}
    			system.debug(LoggingLevel.INFO, 'detailsMap.values(): '+detailsMap.values());
    			detailsToDelete.addAll(detailsMap.values());
    		}
    	}
    	system.debug(LoggingLevel.INFO, 'To update: '+detailsToDelete);
    	system.debug(LoggingLevel.INFO, 'To insert: '+detailsToInsert);
    	system.debug(LoggingLevel.INFO, 'To delete: '+detailsToUpdate);
    	delete detailsToDelete;
    	insert detailsToInsert;
    	update detailsToUpdate;
    	update toUpdate;
    	
    }
    
    public static void copyDetailProperties(SFA2_Configuration_Object_Detail_gne__c configObjectDetail, LayoutItemWrapper detail){
    	configObjectDetail.Type_gne__c = detail.itemType;
    	configObjectDetail.API_Name_gne__c = detail.name;
    	configObjectDetail.Label_gne__c = htmlDecode(detail.label);
    	configObjectDetail.Order_gne__c = detail.itemOrder;
    	configObjectDetail.Is_Required_gne__c = detail.isRequired;
    	configObjectDetail.Is_Read_Only_gne__c = detail.isReadOnly;
    }
    
    public static Boolean isDetailChanged(SFA2_Configuration_Object_Detail_gne__c configObjectDetail, LayoutItemWrapper detail){
    	if(configObjectDetail.Type_gne__c!=detail.itemType || configObjectDetail.API_Name_gne__c!=detail.name || configObjectDetail.Label_gne__c!=detail.label || 
    		configObjectDetail.Order_gne__c!=detail.itemOrder || configObjectDetail.Is_Required_gne__c!=detail.isRequired || configObjectDetail.Is_Read_Only_gne__c!=detail.isReadOnly){
    			return true;
    		}
    		return false;
    }
    
    private static Boolean isSectionUpdated(LayoutSectionWrapper sectionWrapper, SFA2_Configuration_Object_gne__c sectionConfig){
    	if(sectionWrapper.itemOrder != sectionConfig.Order_gne__c.intValue() ||   
    	sectionWrapper.label != sectionConfig.Section_Header_gne__c){
    		return true;
    	}
    	return false;
    }
    
    @RemoteAction
    public static void saveLayoutString(String layoutJSON){
    	List<LayoutSectionWrapper> layout = (List<LayoutSectionWrapper>) JSON.deserialize(layoutJSON, List<LayoutSectionWrapper>.class);
    	system.debug(layout);
    }
    
    @RemoteAction
    public static List<LayoutSectionWrapper> getLayout(String applicationType, String brand, String role, String objectName, String recordTypeId){
    	system.debug('applicationType: '+applicationType+'; brand: '+brand+'; role: '+role+'; objectName: '+objectName+'; '+recordTypeId);
    	Map<String, FieldWrapper>fieldsAttributes = getFieldsAsMap(objectName);
    	system.debug('fieldsAttributes: '+fieldsAttributes);
    	
    	String recordTypeDeveloperName = [SELECT developerName FROM RecordType WHERE id = :recordTypeId limit 1].developerName;
        List<LayoutSectionWrapper> result = new List<LayoutSectionWrapper>();
        
        List<SFA2_Configuration_Object_gne__c>config = [SELECT Id, Application_Type__c, Attributes_gne__c, Brand_gne__c, Configuration_Type_gne__c, Is_Active_gne__c, Is_Default_Record_Type_gne__c, Name,
                                                            Object_Name_gne__c, Order_gne__c, OTR2_gne__c, Record_Type_gne__c, Role_gne__c, RT_Available_On_Create_gne__c, Section_Header_gne__c, Style_gne__c,
                                                            (SELECT Id, API_Name_gne__c, Attributes_gne__c, Availability_Mode_gne__c, Configuration_Object_ref_gne__c, Is_Active_gne__c, Is_Read_Only_gne__c,
                                                            Is_Required_gne__c, Label_gne__c, Name, OTR2_gne__c, Order_gne__c, Style_gne__c, Type_gne__c FROM Configuration_Objects__r WHERE Is_Active_gne__c=true)
                                                        FROM SFA2_Configuration_Object_gne__c
                                                        WHERE Application_Type__c = :applicationType AND Object_Name_gne__c =:objectName AND Record_Type_gne__c =:recordTypeDeveloperName AND Brand_gne__c = :brand AND Role_gne__c= :role AND Is_Active_gne__c=true]; 
		system.debug('config: '+config);                                                        	
        for(SFA2_Configuration_Object_gne__c configObject: config){
        	system.debug('configObject: '+configObject);
            List<LayoutItemWrapper>items = new List<LayoutItemWrapper>();
            for(SFA2_Configuration_Object_Detail_gne__c detail: configObject.Configuration_Objects__r){
            	LayoutItemWrapper itemWrapper = new LayoutItemWrapper(detail);
            	if(detail.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD){
            		system.debug(detail.API_Name_gne__c);
            		if(fieldsAttributes.get(detail.API_Name_gne__c)!=null){
            			itemWrapper.fieldType = String.valueOf(fieldsAttributes.get(detail.API_Name_gne__c).fieldType);
            		}	            	
            	}
            	items.add(itemWrapper);
            } 
            result.add(new LayoutSectionWrapper(configObject, items));
        }
        return result;
    }
    
    @RemoteAction
    public static List<ObjectWrapper>getObjects(){
    	Set<String> tmp = new Set<String>();
        for (AggregateResult ar : [SELECT Object_Name_gne__c FROM SFA2_Configuration_Object_gne__c GROUP BY Object_Name_gne__c]){
            tmp.add((String)ar.get('Object_Name_gne__c'));
        }
        List<ObjectWrapper> result = new List<ObjectWrapper>();
        for(Schema.SObjectType o : Schema.getGlobalDescribe().values()){
        	if(tmp.contains(o.getDescribe().getName())){
            	result.add(new ObjectWrapper(o.getDescribe()));
        	}
        }
        result.sort();
        return result;
    }
    
    @RemoteAction
    public static List<FieldWrapper>getFields(String objectName){
        List<FieldWrapper> result = new List<FieldWrapper>();
        DescribeSObjectResult describeSObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, Schema.SObjectField> objectFieldsDescribe = describeSObjectResult.fields.getMap();
        for(Schema.SObjectField f: objectFieldsDescribe.values()){
            result.add(new FieldWrapper(f.getDescribe()));
            system.debug(new FieldWrapper(f.getDescribe()));
        }
        result.sort();
        return result;
    }
    
    @RemoteAction
    public static Map<String, FieldWrapper>getFieldsAsMap(String objectName){
        Map<String, FieldWrapper> result = new Map<String, FieldWrapper>();
        DescribeSObjectResult describeSObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, Schema.SObjectField> objectFieldsDescribe = describeSObjectResult.fields.getMap();
        for(Schema.SObjectField f: objectFieldsDescribe.values()){
            result.put(f.getDescribe().getName(), new FieldWrapper(f.getDescribe()));
        }
        return result;
    }
    
    @RemoteAction
    public static List<RecordTypeWrapper>getRecordType(String objectName){
        DescribeSObjectResult describeSObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        List<RecordTypeWrapper>result = new List<RecordTypeWrapper>();
        for(RecordType rt: [SELECT Id, Name, Description, DeveloperName, IsPersonType FROM RecordType WHERE SobjectType=:objectName AND IsActive=true]){
            result.add(new RecordTypeWrapper(rt));
        }
        result.sort();
        return result;
    }
    
    @RemoteAction
    public static List<String>getApplicationTypes(){
        List<String> result = new List<String>();
        for (AggregateResult ar : [SELECT Application_Type__c FROM SFA2_Configuration_Object_gne__c GROUP BY Application_Type__c]){
            result.add((String)ar.get('Application_Type__c'));
        }
        result.sort();
        return result;
    }
    
    @RemoteAction
    public static List<String>getRoles(String applicationType){
        List<String> result = new List<String>();
        for (AggregateResult ar : [SELECT Role_gne__c FROM SFA2_Configuration_Object_gne__c WHERE Application_Type__c=:applicationType GROUP BY Role_gne__c]){
            result.add((String)ar.get('Role_gne__c'));
        }
        result.sort();
        return result;
    }
    
    @RemoteAction
    public static List<String>getBrands(String applicationType, String role){
        List<String> result = new List<String>();
        for (AggregateResult ar : [SELECT Brand_gne__c FROM SFA2_Configuration_Object_gne__c  WHERE Application_Type__c=:applicationType AND Role_gne__c=:role GROUP BY Brand_gne__c]){
            result.add((String)ar.get('Brand_gne__c'));
        }
        result.sort();
        return result;
    }
    
    
    public class ObjectWrapper implements Comparable{
        public String name {get; set;}
        public String label {get; set;}
        
        public ObjectWrapper(Schema.DescribeSObjectResult o){
            this.name = o.getName();
            this.label = o.getLabel();
        }
        
        public Integer compareTo(Object o) {
            return name.toLowerCase().compareTo(((ObjectWrapper)o).name.toLowerCase());
        }
    }
    
    public class FieldWrapper implements Comparable{
        public String name {get; set;}
        public String label {get; set;}
        public String fieldType {get; set;}
        public Boolean isRequired {get; set;}
        public Boolean isReadOnly {get; set;}
        public Boolean isCustom {get; set;}
        
        public FieldWrapper(Schema.DescribeFieldResult f){
            this.name = f.getName();
            this.label = f.getLabel();
            this.fieldType = String.valueOf(f.getType());
            this.isReadOnly = !f.isUpdateable();
            this.isRequired = f.isNillable();
            this.isCustom = f.isCustom();
        }
        
        public Integer compareTo(Object o) {
            if(o==null || String.isEmpty(((FieldWrapper)o).label) || String.isEmpty(label)){
                return 1;
            }
            return label.toLowerCase().compareTo(((FieldWrapper)o).label.toLowerCase());
        }
    }
     
    public class RelatedListColumn{
    	public String label;
    	public String apiName;
    	
    	public 	RelatedListColumn(String label, String apiName){
    		this.label = label;
    		this.apiName = apiName;
    	}
    }
    
    public class RecordTypeWrapper implements Comparable{
        public String name {get; set;}
        public String id {get; set;}
        
        public RecordTypeWrapper(Schema.RecordTypeInfo rt){
            this.name = rt.getName();
            this.id = rt.getRecordTypeId();
        }
        
        public RecordTypeWrapper(RecordType rt){
            this.name = rt.DeveloperName;
            this.id = rt.Id;
        }
        
        public Integer compareTo(Object o) {
            return name.toLowerCase().compareTo(((RecordTypeWrapper)o).name.toLowerCase());
        }
    }
    
    public class LayoutSectionWrapper{
    	public String id {get; set;}
        public String name {get; set;}
        public String label {get; set;}
        public Integer itemOrder {get; set;}
        public Boolean isTwoColumnLayout;
        public List<LayoutItemWrapper> items {get; set;} 
        
        public LayoutSectionWrapper(SFA2_Configuration_Object_gne__c configObject, List<LayoutItemWrapper> items){
        	this.id = configObject.id;
            this.name = configObject.Name;
            this.itemOrder = configObject.Order_gne__c.intValue();
            this.label = configObject.Section_Header_gne__c;
            this.items = items;
        }
    }
    
    public virtual class LayoutItemWrapper implements Comparable{
    	public String id {get; set;}
    	public String parentId {get; set;}
        public String itemType {get; set;}
        public String name {get; set;}
        public String label {get; set;}
        public String fieldType {get; set;}
        public Integer itemOrder {get; set;}
        public Boolean isRequired {get; set;}
        public Boolean isReadOnly {get; set;}
        public String attributes {get; set;}
        public Boolean isActive {get; set;}
        public String availabilityMode{get; set;}
        
        //Related List specific fields
        public List<RelatedListColumn>columns {get; set;}
    	public Boolean hideEditLink {get; set;}
    	public Boolean hideDeleteLink {get; set;}
    	public Boolean hideButtons {get; set;}
    	
    	public Integer pageSize {get; set;}
    	public String urlForNewRecord {get; set;}
    	public String parentFieldName {get; set;}
    	public String sortDirection {get; set;}
    	//public List<RLButtonWrapper>customButtons {get; set;}
    	public String filter {get; set;}
    	public String orderByFieldName {get; set;}
        
        public LayoutItemWrapper(SFA2_Configuration_Object_Detail_gne__c configObjectDetail){
        	this.id = configObjectDetail.id;
        	this.parentId = configObjectDetail.Configuration_Object_ref_gne__c;
            this.itemType = configObjectDetail.Type_gne__c;
            this.name = configObjectDetail.API_Name_gne__c;
            this.label = configObjectDetail.Label_gne__c;
            this.itemOrder = Integer.valueof(configObjectDetail.Order_gne__c);
            this.isRequired = configObjectDetail.Is_Required_gne__c;
            this.isReadOnly = configObjectDetail.Is_Read_Only_gne__c;
            if(itemType=='Related List'){
            	initializeRelatedListFields(configObjectDetail);
            }
        }
        
       public void initializeRelatedListFields(SFA2_Configuration_Object_Detail_gne__c configObjectDetail){
    		GNE_SFA2_RL_Component_AttributesWrapper attributes = new GNE_SFA2_RL_Component_AttributesWrapper(configObjectDetail.Attributes_gne__c);
    		this.hideEditLink = attributes.hideEditLink;
    		this.hideDeleteLink = attributes.hideDeleteLink;
    		this.hideButtons = attributes.hideButtons;
    		this.sortDirection = attributes.sortDirection;
    		this.parentFieldName = attributes.parentFieldName;
    		this.filter = attributes.filter;
    		this.pageSize = attributes.pageSize;
    		this.orderByFieldName = attributes.orderByFieldName;
    		this.hideEditLink = attributes.hideEditLink;
    		if(!configObjectDetail.API_Name_gne__c.contains('(')){
    			this.columns = getRLColumns(configObjectDetail.API_Name_gne__c, attributes);
    		}else{
    			this.columns = new List<RelatedListColumn>();
    		}
    	}
    	
    	private List<RelatedListColumn>getRLColumns(String objectName, GNE_SFA2_RL_Component_AttributesWrapper attributes){
    		system.debug(objectName);
    		DescribeSObjectResult describeSObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        	Map<String, Schema.SObjectField> objectFieldsDescribe = describeSObjectResult.fields.getMap();
    		List<RelatedListColumn>columns = new List<RelatedListColumn>();
    		for(String apiName: attributes.fieldsCSV.split(',')){
    			if(apiName.contains('#')){
    				apiName = apiName.split('#')[0];
    			}
    			Schema.SObjectField fieldDescribe = objectFieldsDescribe.get(apiName);
    			String label = apiName;
    			if(fieldDescribe != null){
    				label = fieldDescribe.getDescribe().getLabel();
    			}
    			columns.add(new RelatedListColumn(label, apiName));
    		}
    		return columns;
    	}
    	
    	 public Integer compareTo(Object o) {
            return itemOrder - ((LayoutItemWrapper)o).itemOrder;
        }
    }
    
    public static SFA2_Configuration_Object_gne__c convertLayoutSectionWrapperToConfigObject(LayoutSectionWrapper sectionWrapper, String applicationType, String brand, String objectName, String recordType, String role, Boolean isDefaultRecordType, Boolean isOtr, Boolean isRtAvailableOnCreate){
    	 return new SFA2_Configuration_Object_gne__c(Application_Type__c=applicationType, Brand_gne__c = brand, Configuration_Type_gne__c='Page', Is_Active_gne__c=true, 
    										Object_Name_gne__c=objectName, Order_gne__c = sectionWrapper.itemOrder, Record_Type_gne__c=recordType, Role_gne__c = role,
    										Section_Header_gne__c = htmlDecode(sectionWrapper.label), Is_Default_Record_Type_gne__c=isDefaultRecordType, OTR2_gne__c=isOtr, RT_Available_On_Create_gne__c=isRtAvailableOnCreate);
    										
    }
    
    public static SFA2_Configuration_Object_Detail_gne__c convertLayoutItemWrapperToConfigObjectDetail(LayoutItemWrapper detail, String parentId){
    	
    	return new SFA2_Configuration_Object_Detail_gne__c(id = detail.id, Type_gne__c=detail.itemType, Configuration_Object_ref_gne__c=parentId, API_Name_gne__c=detail.name, 
    				Label_gne__c=htmlDecode(detail.label), Order_gne__c=detail.itemOrder, Is_Required_gne__c=detail.isRequired, Is_Read_Only_gne__c=detail.isReadOnly, 
    				Availability_Mode_gne__c = detail.availabilityMode , Is_Active_gne__c = true);
    	
    }
    
	public static String htmlDecode (String s) {  
	    Map<String, String> htmlDecodingMap = new Map<String, String>();
	    htmlDecodingMap.put('&lt;', '<');
	    htmlDecodingMap.put('&gt;', '>');
	    htmlDecodingMap.put('&amp;quot;', '"');
	    htmlDecodingMap.put('&amp;', '&');
	
	    for (String token : htmlDecodingMap.keySet()) {
	        s = s.replace(token, htmlDecodingMap.get(token));
	    }
	    return s;
	}

}