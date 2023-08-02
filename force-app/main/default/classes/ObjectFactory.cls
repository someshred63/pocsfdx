public class ObjectFactory
{
	private static String OBJECT_ALIAS_DELIMITER = '@';
	
	private static Map<String, Map<String, Object>> objectsDefaults = new Map<String, Map<String, Object>>();
	
	private static final Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();
	
	private SObject o;
	
	public ObjectFactory(String oName, Map<String,Object> fMap, Boolean useDefauls)
	{
		try {
			// init desired Object type
			Schema.SObjectType oType = GLOBAL_DESCRIBE.get(oName);
			if (oType == null) {
				throw new GNE_CM_Exception('Trying to create an instance of non-existing SObject type: ' + oName);
			}
			this.o = oType.newSObject();
			
			Map<String,Object> values = new Map<String,Object>();
			
			// handle passed fields' values			
			if (fMap != null && !fMap.isEmpty()) {
				Map<String,SObject> aliasedObjects = new Map<String,SObject>();
				for (String fName : fMap.keySet()) {
					if (fName.startsWithIgnoreCase(OBJECT_ALIAS_DELIMITER) && fMap.get(fName) instanceof SObject) {
						aliasedObjects.put(fName.substringAfter(OBJECT_ALIAS_DELIMITER), (SObject)fMap.get(fName));
						fMap.remove(fName);
					}
				}
				// handle refereced and regular fields; need a second pass on fMap
				for (String fName : fMap.keySet()) {
					List<String> fieldRef = fMap.get(fName) instanceof String ? ((String)fMap.get(fName)).split('\\.', 0) : null ;
					if (fieldRef != null && fieldRef.size() > 1 && aliasedObjects.containsKey(fieldRef.get(0))) { // treat as reference to an aliased object's field
						values.put(fName, aliasedObjects.get(fieldRef.get(0)).get(fieldRef.get(1)));
					}
					else { // treat as regular value
						values.put(fName, fMap.get(fName));
					}
				}
			}
						
			// handle defaults
			if (useDefauls) {
				for (String fName : objectsDefaults.get(oName).keySet()) {
					if (!values.containsKey(fName)) {
						values.put(fName, objectsDefaults.get(oName).get(fName));
					}
				}
			}
			
			// assign fields' values to the object's instance
			assignFields(this.o, values);
		}
		catch (Exception ex) {
			system.debug('An error occured while creating a ' + oName + ' Object: ' + GlobalUtils.getExceptionDescription(ex));
		}
	}
	
	public static void assignField(SObject o, String k, Object v)
	{
		if (o != null && k != null) {
			assignFields(o, new Map<String,Object>{k => v});
		}
	}
	
	public static void assignFields(SObject o, Map<String,Object> values)
	{
		if (o != null && values != null && !values.isEmpty()) {
			for (String fName : values.keySet()) {
				Object v = values.get(fName);
				if (v == null) {
					o.put(fName, null);
				} else if (v instanceof Boolean) {
					o.put(fName, Boolean.valueOf(v));
				} else if (v instanceof Date) {
					o.put(fName, Date.valueOf(v));
				} else if (v instanceof DateTime) {
					o.put(fName, DateTime.valueOf(v));
				} else if (v instanceof Integer) {
					o.put(fName, Integer.valueOf(v));
				} else if (v instanceof Decimal) {
					o.put(fName, Decimal.valueOf(String.valueOf(v)));
				} else { // default to String
					o.put(fName, v);
				}
			}
		}
	}
	
	public static SObject defaults(String oName)
	{
		ObjectFactory i = new ObjectFactory(oName, null, true);
		return i.o;
	}
	
	public static SObject make(String oName, Map<String,Object> fMap, Boolean useDefaults)
	{
		ObjectFactory i = new ObjectFactory(oName, fMap, useDefaults);
		return i.o;
	}
	
	public static SObject make(String oName, Map<String,Object> fMap)
	{
		ObjectFactory i = new ObjectFactory(oName, fMap, true);
		return i.o;
	}
	
	public static void setDefaults(Map<String,Map<String,Object>> defaults)
	{
		if (!defaults.isEmpty()) {
			for (String oName : defaults.keySet()) {
				setDefaults(oName, defaults.get(oName), true);
			}
		}
	}
	
	public static void setDefaults(String oName, Map<String,Object> fMap, Boolean overwrite)
	{
		if (!objectsDefaults.containsKey(oName)) {
			objectsDefaults.put(oName, fMap);
		}
		else if (overwrite) {
			for (String fName : fMap.keySet()) {
				objectsDefaults.get(oName).put(fName, fMap.get(fName));
			}
		}
	}
	
	public static void setDefaults(String oName, Map<String,Object> fMap)
	{
		setDefaults(oName, fMap, false);
	}
	
	public static void setObjectAliasDelimiter(String oad)
	{
		if (oad != null && oad != '') {
			OBJECT_ALIAS_DELIMITER = oad;
		}
	}
}