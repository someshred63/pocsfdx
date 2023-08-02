//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care
//     CLASS: GNE_Account_Affiliation_Dao
//   PURPOSE: Dao for Affiliation_vod__c, a related list on Account   
// 
//   CREATED: 10/2010  
//--------------------------------------------------------------------------------
public without sharing class GNE_Account_Affiliation_Dao extends GNE_Base_Dao {
	
	private static final String OBJECT_NAME = 'Affiliation_vod__c';
	
	private static final String RECORD_TYPE_CANADA = 'GNE_SFA_Canada';
	
	private static final String soqlDelimeter = ', ';
	
	private static String iPhoneRequestIdFn = null;
	public static String IPHONE_REQUEST_ID_FN {
		get {
			if (iPhoneRequestIdFn == null){
				iPhoneRequestIdFn = String.valueOf(Affiliation_vod__c.Iphone_request_id_gne__c);
			}
			return iPhoneRequestIdFn;
		}
	}
	
	private static String fieldListStr = null;
	public static String FIELD_LIST {
		get {
			if (fieldListStr == null){
				fieldListStr = String.format('{0}{1}{2}',
					new String[]{
						ACTIVE_FOR_MY_BRAND_FIELD_LIST_STR,
						soqlDelimeter,
						OTHER_FIELD_LIST_STR
					}
				);				
			}
			return fieldListStr;
		}
	}
	
	private static String activeForMyBrandFieldStr = null;	
	public static String ACTIVE_FOR_MY_BRAND_FIELD_LIST_STR {
		get {
			if (activeForMyBrandFieldStr == null){
				activeForMyBrandFieldStr = String.join(new List<String> {
					String.valueOf(Affiliation_vod__c.Active_for_Actemra_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_BioOnc_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_FRM_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_Lytics_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_Nutropin_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_Pulmozyme_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_Rituxan_RA_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_Xolair_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_Lucentis_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_PFT_gne__c),
					String.valueOf(Affiliation_vod__c.Active_for_Primary_Care__c),
					String.valueOf(Affiliation_vod__c.Active_for_Neurology_gne__c)
					},
					soqlDelimeter
				);
			}
			return activeForMyBrandFieldStr;
		}
	}
	
	private static String otherFieldListStr = null;
	private static String OTHER_FIELD_LIST_STR {
		get {
			if (otherFieldListStr == null){
				otherFieldListStr = String.join(new List<String> {
					String.valueOf(Affiliation_vod__c.Id),
					String.valueOf(Affiliation_vod__c.Affiliation_Type_gne__c),
					String.valueOf(Affiliation_vod__c.From_Contact_vod__c),
					String.valueOf(Affiliation_vod__c.From_Account_vod__c),
					String.valueOf(Affiliation_vod__c.To_Account_vod__c),
					String.valueOf(Affiliation_vod__c.To_Contact_vod__c),
					String.valueOf(Affiliation_vod__c.Comments_vod__c),
					String.valueOf(Affiliation_vod__c.Role_vod__c),
					String.valueOf(Affiliation_vod__c.Role_opposite_vod__c),
					String.valueOf(Affiliation_vod__c.Influence_vod__c),
					String.valueOf(Affiliation_vod__c.Applies_to_My_Brand_gne__c),
					'Owner.Name',
					String.valueOf(Affiliation_vod__c.Drug_gne__c),
					String.valueOf(Affiliation_vod__c.Web_order_enabled_gne__c),
					String.valueOf(Affiliation_vod__c.Primary_gne__c),
					String.valueOf(Affiliation_vod__c.Primary_fpm_gne__c),
					IPHONE_REQUEST_ID_FN
					}, 
					soqlDelimeter
				);
			}
			return otherFieldListStr;
		}
	}
	
	private static Map<String, Schema.SObjectField> objectFieldsMap = null;
	private static Map<String, Schema.SObjectField> OBJECT_FIELDS_MAP {
		get {
			if (objectFieldsMap == null){
				objectFieldsMap = GNE_SFA2_Application_Cache.describeObject(OBJECT_NAME).Fields.getMap();
			}
			return objectFieldsMap;
		}
	}
	
	private static Map<String, Schema.DescribeFieldResult> objectFieldsDescribeMap = null;
	private static Schema.DescribeFieldResult getObjectFieldDescribe(String fieldApiName) {
		if (objectFieldsDescribeMap == null){
			objectFieldsDescribeMap = new Map<String, Schema.DescribeFieldResult>();
		}
		String fieldApiNameLC = fieldApiName.toLowerCase();
		if (!objectFieldsDescribeMap.containsKey(fieldApiNameLC)){
			objectFieldsDescribeMap.put(fieldApiNameLC, OBJECT_FIELDS_MAP.get(fieldApiName).getDescribe());
		}
		return objectFieldsDescribeMap.get(fieldApiNameLC);		
	}
	
    private static String getDefaultPicklistValue(String fieldName){
		String result = null;
		Schema.DescribeFieldResult fieldDescribe = getObjectFieldDescribe(fieldName);
		if (fieldDescribe.getType() != Schema.DisplayType.Picklist){
			return result;
		}
		for (Schema.PicklistEntry pentry : fieldDescribe.getPicklistValues()){
			if (pentry.isDefaultValue()){
				result = pentry.getValue();
				break;
			}
		}		
   		return result;
    }
    
    private void cloneValues(Affiliation_vod__c affiliationToUpdate, Affiliation_vod__c userAffiliation){
   		Set<String> queriedFieldsSet = new Set<String>(OTHER_FIELD_LIST_STR.toLowerCase().split(soqlDelimeter));
   		for (String fieldName : OBJECT_FIELDS_MAP.keyset()){
   			if (!queriedFieldsSet.contains(fieldName.toLowerCase())){
				continue;
   			}
   			Schema.DescribeFieldResult fieldDescribe = getObjectFieldDescribe(fieldName);
			if (userAffiliation.get(fieldName) != null && fieldDescribe.getName() != IPHONE_REQUEST_ID_FN && fieldDescribe.isAccessible() && fieldDescribe.isCreateable() && fieldDescribe.isUpdateable() && fieldDescribe.isCustom()){
				affiliationToUpdate.put(fieldName, userAffiliation.get(fieldName));
   			}
   		}
   		String activeForMyBrandFieldName = getMyBrandFieldApiName();
   		if (String.isNotBlank(activeForMyBrandFieldName)){
   			affiliationToUpdate.put(activeForMyBrandFieldName, true);
   		}
    }
    
    private Affiliation_vod__c calculateAffiliation(Affiliation_vod__c affiliation){
   		Affiliation_vod__c existedRecord = calculateByExternalId(affiliation);
   		if (existedRecord != null){
   			Affiliation_vod__c affToUpdate = new Affiliation_vod__c(Id = existedRecord.Id);   				   				
   			cloneValues(affToUpdate, affiliation);
   			affiliation = affToUpdate;
   		}
   		return affiliation;
    }
    
    private static Affiliation_vod__c getByExternalId(String extIdStr) {    	
    	String whereExpr = String.valueOf(Affiliation_vod__c.External_Id_vod__c) + ' = \'' + String.escapeSingleQuotes( extIdStr ) + '\'';
    	whereExpr += !GNE_SFA2_Util.isCanadaUser() ? ' AND RecordType.DeveloperName != \'' + RECORD_TYPE_CANADA + '\'' : ' AND RecordType.DeveloperName = \'' + RECORD_TYPE_CANADA + '\'';
    	String query = String.format('SELECT {0} FROM {1} WHERE {2}',
    		new String[]{
    			FIELD_LIST,
    			OBJECT_NAME,
    			whereExpr
    		}
    	);    	 
		List<Affiliation_vod__c> objList = Database.query(query);		
		return !objList.isEmpty() ? (Affiliation_vod__c)objList[0] : null;
    }
    
    public GNE_Account_Affiliation_Dao(boolean testCase) {
		IsTestCase = testCase;
	}
	
	public GNE_Account_Affiliation_Dao() {
		IsTestCase = false;
	}

	public Affiliation_vod__c getById(String idInp) {
		Affiliation_vod__c obj = (Affiliation_vod__c)getSObjectById(FIELD_LIST, OBJECT_NAME, idInp);
		return obj;
    }
    
    public static Affiliation_vod__c calculateByExternalId(Affiliation_vod__c affiliation){
    	if (String.isBlank(affiliation.Role_vod__c)){
    		affiliation.Role_vod__c = getDefaultPicklistValue(String.valueOf(Affiliation_vod__c.Role_vod__c));
    	}    	
   		return getByExternalId(createExternalId(affiliation));
    }
    
    public override Exception saveSObjectEx(SObject obj){
    	Affiliation_vod__c affiliation = (Affiliation_vod__c)obj;
    	if (affiliation.Id == null && isMyBrandCalculated()){
    		affiliation = calculateAffiliation(affiliation);
    	}
    	return super.saveSObjectEx(affiliation);
    }
    
    /* Returns the Api Name of 'Active For ...' brand field if user has access to it. */
    private static String myBrandFieldApiName;    
    public static String getMyBrandFieldApiName(){
    	if (String.isNotBlank(myBrandFieldApiName)){
    		return myBrandFieldApiName;
    	}    	
    	Set<String> fieldResults = new Set<String>();
    	Set<String> queriedFieldsSet = new Set<String>(ACTIVE_FOR_MY_BRAND_FIELD_LIST_STR.toLowerCase().split(soqlDelimeter));
    	for (String fieldName : OBJECT_FIELDS_MAP.keyset()){
   			if (!queriedFieldsSet.contains(fieldName.toLowerCase())){
   				continue;
   			}
   			Schema.DescribeFieldResult fieldDescribe = getObjectFieldDescribe(fieldName);
   			if (fieldDescribe.isAccessible() && fieldDescribe.isCreateable() && fieldDescribe.isUpdateable()){
   				fieldResults.add(fieldName);   				
   			}
   		}
   		myBrandFieldApiName = fieldResults.size() == 1 ? new List<String>(fieldResults)[0] : null;
   		return myBrandFieldApiName;
    }
    
    // Get all config entries for user profile
    private static List<GNE_SFA2_Affiliation_Calculated_Profiles__c> calculatedProfilesConfigEntries = null;
    private static List<GNE_SFA2_Affiliation_Calculated_Profiles__c> getCalculatedProfilesConfigEntries(){
    	if (calculatedProfilesConfigEntries != null){
    		return calculatedProfilesConfigEntries;
    	}    	
    	String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
    	calculatedProfilesConfigEntries = new List<GNE_SFA2_Affiliation_Calculated_Profiles__c>();
    	for (GNE_SFA2_Affiliation_Calculated_Profiles__c profileConfig : GNE_SFA2_Affiliation_Calculated_Profiles__c.getAll().values()){
			if (profileName.startsWithIgnoreCase(profileConfig.Name)){
				calculatedProfilesConfigEntries.add(profileConfig);
			}
		}
		// Calculate whether user profile is excluded from scope
		GNE_SFA2_Affiliation_Calculated_Profiles__c configWinner = null;
		for (GNE_SFA2_Affiliation_Calculated_Profiles__c profileConfig : calculatedProfilesConfigEntries){
			if (configWinner == null || (configWinner != null && profileConfig.Name.length() > configWinner.Name.length())){
				configWinner = profileConfig;
			}
		}
		if (configWinner != null && configWinner.Except_gne__c){
			calculatedProfilesConfigEntries.clear();
		}
		
		return calculatedProfilesConfigEntries;
    }
    
    // Check config entries whether user profile is not excluded
    private static Boolean calculatedByConfig = null;
    private static Boolean isCalculatedByConfig(){
    	if (calculatedByConfig != null){
    		return calculatedByConfig;
    	}
    	Boolean result = false;
    	// Calculate by best fit
		GNE_SFA2_Affiliation_Calculated_Profiles__c configWinner = null;
		for (GNE_SFA2_Affiliation_Calculated_Profiles__c profileConfig : getCalculatedProfilesConfigEntries()){
			if (configWinner == null || (configWinner != null && profileConfig.Name.length() > configWinner.Name.length())){
				configWinner = profileConfig;
			}
		}
		if (configWinner != null){
			result = !configWinner.Except_Sharing_Calculation_gne__c;
		}
		calculatedByConfig = result;
		return calculatedByConfig;
    }
    
    private static Boolean hasActiveForMyBrandButton(){
    	return String.isNotBlank(getMyBrandFieldApiName());
    }
    
    private static Boolean isInCalculatedProfilesConfigScope(){
    	return !getCalculatedProfilesConfigEntries().isEmpty();
    }
    
    /* [SFA-901] Determines whether user has an access to 'Active For ...' brand button and is not excluded in the custom setting.
    *  Visibility of hidden affiliations depends on sharing configuration - sharing by the 'Active For..' field.
    *  For profiles in scope while creating a new affiliation system checks if it already exists and if true then un-hides them by selecting 'Active For ...' field.
    *  Profiles can be excluded because of sharing settings configuration which does not allow to share records with others. */
    private static Boolean myBrandCalculated = null;
    public static Boolean isMyBrandCalculated(){
    	if (myBrandCalculated != null){
    		return myBrandCalculated;
    	}
    	myBrandCalculated = isCalculatedByConfig() && hasActiveForMyBrandButton();
    	return myBrandCalculated;
    }
    
    /* [SFA-901] Determines whether user can set record as 'Active For ...' his brand. */
    private static Boolean canActiveForMyBrand = null;
    public static Boolean canSetActiveForMyBrand(){
    	if (canActiveForMyBrand != null){
    		return canActiveForMyBrand;
    	}
    	canActiveForMyBrand = isInCalculatedProfilesConfigScope() && hasActiveForMyBrandButton();
    	return canActiveForMyBrand;
    }
    
    public static String createExternalId(Affiliation_vod__c affiliation){
    	return (affiliation.From_Account_vod__c + ':' + affiliation.From_Contact_vod__c + ':' + affiliation.To_Account_vod__c + ':' + affiliation.To_Contact_vod__c + ':' + affiliation.Role_vod__c);
    }
}