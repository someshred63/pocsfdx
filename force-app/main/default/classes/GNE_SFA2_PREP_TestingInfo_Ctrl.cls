public class GNE_SFA2_PREP_TestingInfo_Ctrl extends GNE_SFA2_PREP_Base_Ctrl {
	public Id recId {get; private set;}
	public Id accId {get; private set;}
	public SFA2_PREP_Account_Testing_Info_gne__c record {get; private set;}
	public Map<String,SFA2_PREP_Account_Testing_Info_gne__c> recordPerTestType {get; private set;}
	public String objectType {get; private set;}
	public List<SFA2_Configuration_Object_gne__c> sectionsList {get; private set;}
    public Map<Id, List<SFA2_Configuration_Object_Detail_gne__c>> sectionsMap {get; private set;}
    public String numericFieldRangesInJSON {get {return JSON.serialize(GNE_SFA2_PREP_ATI_Validation_Rules.numericFieldRanges); } }
    
    public String requiredFieldsInJSON {get { return JSON.serialize(requiredFields);} }
    public GNE_SFA2_Lookup_Ctrl_Engine customLookupEngine {get; private set;}
    public String testTypeApiNamesInJSON {get; private set;}
    
    private Set<String> requiredFields;
    private Map<String,Set<String>> requiredFieldsPerTestType;
    private Map<String,Set<String>> fieldsPerTestType;
    private Map<String,String> fieldLabels;
    private GNE_SFA2_User_App_Context_gne__c userApplicationContext;
	
	public GNE_SFA2_PREP_TestingInfo_Ctrl(ApexPages.StandardController controller) {
		this(controller.getRecord().Id, ApexPages.currentPage().getParameters().get('accId'), false);
	}
	
	public GNE_SFA2_PREP_TestingInfo_Ctrl(Id recId, Id accId, Boolean initMode) {
		this.recId = recId;
		this.accId = accId;
		this.objectType = SFA2_PREP_Account_Testing_Info_gne__c.sObjectType.getDescribe().getName();
		this.userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
		
		if(initMode==true) {
			intInit();
		}
	}
	
	public PageReference init() {
		PageReference result = null;
		
		try {
			result = intInit();
		} catch (Exception ex) {
			result = setErrorPageReference('Init Page', ex);
		}
		
		return result;
	}
	
	private PageReference intInit() {
		Set<String> usedFields = readConfiguration();
		setRecord(usedFields);
		Set<Id> territoryGroupsIds = GNE_SFA2_PREP_Util.getPrepTerritoriesGroupIds();
		Set<String> accIds = new Set<String>();
		
		for(AccountShare aShare : GNE_SFA2_PREP_DAO.getHcoAccountSharesForGroupIds(territoryGroupsIds)) {
			accIds.add(((String)aShare.AccountId).substring(0,15));
		}
		
		String accIdsInString = String.join(new List<String>(accIds), ',');
		customLookupEngine = new GNE_SFA2_Lookup_Ctrl_Engine();
		customLookupEngine.addFieldData(
				objectType,
				String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Referred_Account_gne__c),
				'Name,Account_Type_gne__c',
				null,
				accIdsInString
		);
		
		testTypeApiNamesInJSON = JSON.serialize(GNE_SFA2_PREP_Config.TestTypeToApiNameMap);
		return null;
	}
	
	private Set<String> readConfiguration() {
		Set<String> usedFields = new Set<String>();
		sectionsList = new List<SFA2_Configuration_Object_gne__c>();
		sectionsMap = new Map<Id, List<SFA2_Configuration_Object_Detail_gne__c>>();
		requiredFields = new Set<String>();
		requiredFieldsPerTestType = new Map<String,Set<String>>();
		fieldsPerTestType = new Map<String,Set<String>>();
		fieldLabels = new Map<String,String>();
		
		for(SFA2_Configuration_Object_gne__c co : GNE_SFA2_DynamicVFLoader.getUIConfigurationObjects(userApplicationContext, objectType, null)) {
			Boolean sectionWithFields = false;
			String testTypeApiName = String.isNotBlank(co.Attributes_gne__c) ? co.Attributes_gne__c.toLowerCase() : null;
			
			if(!fieldsPerTestType.containsKey(testTypeApiName)) {
				requiredFieldsPerTestType.put(testTypeApiName, new Set<String>());
				fieldsPerTestType.put(testTypeApiName, new Set<String>());
			}
			
			for(SFA2_Configuration_Object_Detail_gne__c cod : co.Configuration_Objects__r) {
				if(cod.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD) {
					usedFields.add(cod.API_Name_gne__c);
					sectionWithFields = true;
					fieldLabels.put(cod.API_Name_gne__c,cod.Label_gne__c);
					
					fieldsPerTestType.get(testTypeApiName).add(cod.API_Name_gne__c);
						
					if(cod.Is_Required_gne__c) {
						requiredFieldsPerTestType.get(testTypeApiName).add(cod.API_Name_gne__c);
					}
					
					if(cod.Is_Required_gne__c) {
						requiredFields.add(cod.API_Name_gne__c);
						cod.Is_Required_gne__c = false;
					}
				}
			}
			
			if(sectionWithFields) {
				sectionsList.add(co);
				sectionsMap.put(co.Id, new List<SFA2_Configuration_Object_Detail_gne__c>(co.Configuration_Objects__r));
			}
		}
		
		return usedFields;
	}
	
	public Component.Apex.PageBlockButtons getCustomButtons() {
		return GNE_SFA2_DynamicVFLoader.getActiveCustomButtons(userApplicationContext, objectType, '', recId);
	}
	
	private void setRecord(Set<String> usedFields) {
		if(String.isNotBlank(recId)) {
			Set<String> allFields = new Set<String>{'Id', 'Name', String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Account_gne__c)};
			allFields.addAll(usedFields);
			
			String queryString = String.format('SELECT {0} FROM {1} WHERE Id = :recId', new String[]{String.join(new List<String>(allFields), ','), objectType});
			record = Database.query(queryString);
		} else {
			record = new SFA2_PREP_Account_Testing_Info_gne__c(Account_gne__c = accId);
		}
		
		recordPerTestType = new Map<String,SFA2_PREP_Account_Testing_Info_gne__c>();
		
		for(Schema.PicklistEntry ple : SFA2_PREP_Account_Testing_Info_gne__c.Test_Type_gne__c.getDescribe().getPicklistValues()) {
			SFA2_PREP_Account_Testing_Info_gne__c rec = record.clone(false);
			rec.Test_Type_gne__c = ple.getLabel();
			String testTypeApiName = getTestTypeApiName(rec.Test_Type_gne__c);
			recordPerTestType.put(testTypeApiName, rec);
			Set<String> allVisibleFields = new Set<String>(fieldsPerTestType.get(null));
			allVisibleFields.addAll(fieldsPerTestType.get(testTypeApiName));
			
			if(String.isNotBlank(recId)) {
				for(String fieldName : fieldLabels.keySet()) {
					if(!allVisibleFields.contains(fieldName)) {
						rec.put(fieldName, null);
					}
				}
			}
		}
	}
	
	private String getTestTypeApiName(String testType) {
		return GNE_SFA2_PREP_Config.getTestTypeApiName(testType);
	}
	
	public PageReference save() {
		PageReference result = null;
		
		try {
			result = intSave();
		} catch (Exception ex) {
			result = setErrorPageReference('Save', ex);
		}
		
		return result;
	}
	
	private PageReference intSave() {
		SavePoint savePoint = Database.setSavepoint();
		Boolean isOK = false;
		try {
			validate();
			SFA2_PREP_Account_Testing_Info_gne__c tInfoRec = recordPerTestType.get(getTestTypeApiName(record.Test_Type_gne__c));
			tInfoRec.Id = record.Id;
			upsert tInfoRec;
			isOK = true;
		} catch(GNE_SFA2_PREP_Base_Ctrl.InvalidInputValueException ex) {
            for(String errorMsg : ex.errorMessages) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, errorMsg));
            }
        } catch(Exception ex) {
            Apexpages.addMessages(ex);
            Database.rollback(savePoint);
        }
        
		return isOK? redirectToAccountLayoutUrl() : null;
	}
	
	private void validate() {
		List<String> errorMsgs = new List<String>();
		
		if(String.isBlank(record.Test_Type_gne__c)) {
			errorMsgs.add(String.format(System.Label.GNE_SFA2_PREP_REQUIRED_FIELD,new String[]{fieldLabels.get(String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Test_Type_gne__c))}));
		} else {
			String testTypeApiName = getTestTypeApiName(record.Test_Type_gne__c);	
			SFA2_PREP_Account_Testing_Info_gne__c tInfoRec = recordPerTestType.get(testTypeApiName);
			
			Set<String> reqFields = new Set<String>(requiredFieldsPerTestType.get(null));
			reqFields.addAll(requiredFieldsPerTestType.get(testTypeApiName));
			
			for(String fieldName : reqFields) {
				Object fieldValue = tInfoRec.get(fieldName);
				if(fieldValue==null || String.isBlank(String.valueOf(fieldValue))) {
					errorMsgs.add(String.format(System.Label.GNE_SFA2_PREP_REQUIRED_FIELD,new String[]{fieldLabels.get(fieldName)}));
				}
			}
		}
		
		if(!errorMsgs.isEmpty()){
			errorMsgs.sort();
            throw new GNE_SFA2_PREP_Base_Ctrl.InvalidInputValueException(errorMsgs);
        } 
	}
	
	public PageReference deleteClick() {
		PageReference result = null;
		
		try {
			result = intDeleteClick();
		} catch (Exception ex) {
			result = setErrorPageReference('Delete', ex);
		}
		
		return result;
	}
	
	private PageReference intDeleteClick() {
		PageReference result = null;
		Boolean isOK = false;
		
		try {
			delete record;
			isOK = true;
		} catch (DMLException ex){
            if(ex.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_OR_READONLY || ex.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY) {
                result = Page.GNE_SFA2_Access_Denied;
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getdmlMessage(0)));
            }
		}
		
		return isOK? redirectToAccountLayoutUrl() : result;
	}
	
	private PageReference redirectToAccountLayoutUrl() {
        Pagereference pageref = Page.GNE_SFA2_Account_Layout;
        pageref.getParameters().put('id', record.Account_gne__c);
        pageref.setredirect(true);
        return pageref;
    }
}