/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2010-09-13
*  Description:
*  The class contains utils functions that are used globally by SFDC Development Team
*  Modification History
*  Date        Name        Description
*
*************************************************************/

public class GlobalUtils
{
	public interface ObjectComparator
	{
	    Integer compare(Object object1, Object object2);
	}

	public class IllegalArgumentException extends Exception {}

    /**
    * PI constant
    * @author: Robert Kostusiak
    */
    public static final Double PI = 3.14159265;
    /**
    * Get Map<String, RecordType> by specified object name and list of record types names
    * @author: Sebastian Wajrych
    */
    public static Map<String, RecordType> getRecordTypes(String objTypeName, List<String> recordTypeNames){

        Map<String, RecordType> recordTypesMap = new Map<String, RecordType>();
        List<RecordType> recordTypesList;
        if(recordTypeNames != null && recordTypeNames.size()>0){
            recordTypesList = [Select Name,Id From RecordType where Name IN :recordTypeNames AND SObjectType = :objTypeName];
        }else{
            recordTypesList = [Select Name,Id From RecordType where SObjectType = :objTypeName];
        }

        for(Integer i=0; i<recordTypesList.size(); i++){
            recordTypesMap.put(recordTypesList[i].Name, recordTypesList[i]);
        }

        return recordTypesMap;
    }

    /**
    * Get String determining current environment - cmr2; mefull; dev; sqa; uat; prod
    * @author: Krzysztof Wilczek
    */
    public static String getEnvironment()
    {
        String env ='';
        String userName = Userinfo.getUsername();
        if(userName !='')
        {
            if(userName.indexOf('@gene.com') > 0 && userName.indexOf('@gene.com.') <0)
                env = 'prod';
            else if(userName.indexOf('@gene.com.') >0)
                env = userName.substring(userName.indexOf('@gene.com.')+10, userName.length());
        }
        return env;
    }

    public static String getRandomAlphaNumeric(Integer length)
    {
    	return getRandomAlphaNumeric(length, null, null);
    }

    public static String getRandomAlphaNumeric(Integer length, String prefix)
    {
    	return getRandomAlphaNumeric(length, prefix, null);
    }

    public static String getRandomAlphaNumeric(Integer length, String prefix, String suffix)
    {
    	String ran = '';
    	List<String> chars = new List<String>{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};

    	for (Integer i = 0; i < length; i++)
    	{
    		Integer index = null;
    		Boolean isLowercase = false;
    		do
    		{
    			index = Math.round(Math.random() * chars.size());
    			isLowercase = Math.random() < 0.5;
    		}
    		while (index > (chars.size() - 1));
    		ran += isLowercase ? chars[index].toLowerCase() : chars[index];
    	}

    	if (prefix != null)
    	{
    		ran = prefix + ran;
    	}
    	if (suffix != null)
    	{
    		ran += suffix;
    	}

    	return ran;
    }

    /**
    * Convert double value (degrees) to radians
    * @author: Robert Kostusiak
    */
    public static Double toRadians(Double value)
    {
      return value * (PI / 180);
    }

    /**
    * Convert double value (radians) to degrees
    * @author: Robert Kostusiak
    */
    public static Double toDegrees(Double value)
    {
      return value * (180 / PI);
    }

    /**
    * Convert String to Decimal
    * @author: Wojciech Twardowski
    */
    public static Decimal toDecimal(String input)
	{
		return GlobalUtils.toDecimal(input, null);
	}

	/**
    * Convert String to Decimal; set defaultValue if input String equals null
    * @author: Wojciech Twardowski
    */
	public static Decimal toDecimal(String input, Decimal defaultValue)
	{
		if (input == null)
		{
			return defaultValue == null ? null : defaultValue ;
		}
		return Decimal.valueOf(input);
	}

	/**
    * Convert Decimal to Integer
    * @author: Wojciech Twardowski
    */
	public static Integer toInteger(Decimal input)
	{
		return GlobalUtils.toInteger(input, null);
	}

	/**
    * Convert Decimal to Integer; set defaultValue if input Decimal equals null
    * @author: Wojciech Twardowski
    */
	public static Integer toInteger(Decimal input, Integer defaultValue)
	{
		if (input == null)
		{
			return defaultValue == null ? null : defaultValue ;
		}
		return Integer.valueOf(input);
	}

	/**
    * Convert String to Integer
    * @author: Wojciech Twardowski
    */
	public static Integer toInteger(String input)
	{
		return GlobalUtils.toInteger(input, null);
	}

	/**
    * Convert String to Integer; set defaultValue if input String equals null
    * @author: Wojciech Twardowski
    */
	public static Integer toInteger(String input, Integer defaultValue)
	{
		if (input == null)
		{
			return defaultValue == null ? null : defaultValue ;
		}
		return Integer.valueOf(input);
	}

    /**
    * Calculating distance between two points by their lat and lng positions
    * @author: Robert Kostusiak
    */
    public static Double twoPointsDistance(Double lat1, Double lon1, Double lat2, Double lon2, Boolean km_mi_switch)
    {
      Integer r = 0;
      if(km_mi_switch)
        r = 6371; //for kilometers
      else
        r = 3960; //for miles

      Double dLat = toRadians(lat2 - lat1);
      Double dLon = toRadians(lon2 - lon1);
      Double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
      Math.sin(dLon/2) * Math.sin(dLon/2);
      Double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      return r * c;
    }

    /**
    * Calculates age based on date of birth
    * @author: Krzysztof Wilczek
    */
    public static Integer getAge(Date dateOfBirth)
    {
        Integer result = 0;
        if(Date.today().month() > dateOfBirth.month())
        {
            result = Date.today().year() - dateOfBirth.year();
        }
        else
        {
            if(Date.today().month() == dateOfBirth.month() && Date.today().day() >= dateOfBirth.day())
            {
                result = Date.today().year() - dateOfBirth.year();
            }
            else
            {
                result = Date.today().year() - dateOfBirth.year() - 1;
            }
        }
        return result;
    }

    /**
    * Adds value to Map<String, Set<String>>
    * @author: Krzysztof Wilczek
    */
    public static void addValueToCollection(Map<String, Set<String>> col, String key, String value)
    {
        if(col.containsKey(key))
        {
            col.get(key).add(value);
        }
        else
        {
            col.put(key, new Set<String>{value});
        }
    }

    /**
     * Escapes a string so that it can be used in Javascript.
     */
    public static String escapeForJS (String s)
    {
    	return s != null ? s.replace('"', '\\"') : null;
    }

    /**
    * The function returns string with important information from caught exception object
    * @author: Krzysztof Wilczek
    */
    public static String getExceptionDescription(Exception ex)
    {
    	String errorText = '';
    	if(ex.getCause() != null)
    	{
    		errorText += getExceptionDescription(ex.getCause());
    	}
    	errorText += ' Error Stack Trace: ' + ex.getStackTraceString();
    	errorText += ' Error Line Number: ' + ex.getLineNumber();
    	errorText += ' Error Message: ' + ex.getMessage();
		return errorText;
    }

    /**
    * Gets environment name from user name
    * @author: Krzysztof Wilczek
    */
    public static String getUserTail(String userName)
    {
        string userTail = '';
        if(userName.indexOf('@gene.com') > 0 && userName.indexOf('@gene.com.') <0)
            userTail = 'prod';
        else if(userName.indexOf('@gene.com.') >0)
            userTail = userName.Substring(userName.indexOf('@gene.com.')+10, userName.length());

        if (userTail != '' && userTail != 'prod')
            userTail = '.' + userTail;
        return userTail;
    }

     /**
    * Gets environment name from user name
    * @author: Michal Szewczyk
    */

    public static Boolean isUserInTerr(String userId,String TerrName)
    {
		String rootTerrName = TerrName ;
		Map<Id,Territory2> root = new Map<Id,Territory2>([select Id from Territory2 where Name = :rootTerrName]);

		set<Id> tmpIds = new Set<Id>(root.keySet());
		set<Id> finalIds = new Set<Id>(root.keySet());

		for(integer i=0;i<99;i++)
		{
		   Map<Id,Territory2> tempMap = new Map<Id,Territory2>([select Id  from Territory2 where ParentTerritory2Id IN :tmpIds]);
		   finalIds.addAll(tempMap.keySet());
		   if(tempMap.keySet().size() < 1) break;
		   tmpIds.clear();
		   tmpIds.addAll(tempMap.keySet());
		}

		List<UserTerritory2Association> userAssignment = [select Id, Territory2Id, UserId from UserTerritory2Association where UserId =:userId AND Territory2Id IN : finalIds];
		if(userAssignment.size() > 0) {
			return true;
		}
		else {
			return false;
		}
    }

    /**
    * Apex Objects sorting method
    * @author: Krzysztof Wilczek, source apex-lang-1.14 (http://code.google.com/p/apex-lang/)
    */
    public static List<Object> qsort(List<Object> theList, ObjectComparator comparator)
    {
        return qsort(theList, comparator, true);
    }

    public static List<Object> qsort(List<Object> theList, ObjectComparator comparator, Boolean sortAsc)
    {
        return qsort(theList, 0, (theList == null ? 0 : theList.size()-1), comparator, sortAsc);
    }

    private static List<Object> qsort(List<Object> theList,
                                Integer lo0,
                                Integer hi0,
                                ObjectComparator comparator,
                                Boolean sortAsc)
    {
        Integer lo = lo0;
        Integer hi = hi0;

        if (lo >= hi) {
            return theList;
        } else if( lo == hi - 1 ) {

            if (( comparator.compare(theList[lo],theList[hi])>0 && sortAsc) ||
                  (comparator.compare(theList[lo],theList[hi])<0 && !sortAsc)
                ) {
                 Object prs = theList[lo];
                 theList[lo]         = theList[hi];
                 theList[hi]         = prs;
            }
            return theList;
        }

        Object pivot = theList[(lo + hi) / 2];
        theList[(lo + hi) / 2] = theList[hi];
        theList[hi] = pivot;

        while( lo < hi ) {
            while ((comparator.compare(theList[lo], pivot)<=0 && lo < hi && sortAsc) ||
                   (comparator.compare(theList[lo], pivot)>=0 && lo < hi && !sortAsc)
                  ) { lo++; }
            while (( comparator.compare(pivot,theList[hi])<=0 && lo < hi && sortAsc) ||
                   ( comparator.compare(pivot,theList[hi])>=0 && lo < hi && !sortAsc)
                  ) { hi--; }

            if( lo < hi ){
                 Object prs = theList[lo];
                 theList[lo]   = theList[hi];
                 theList[hi]    = prs;
            }
        }

        theList[hi0] = theList[hi];
        theList[hi] = pivot;

        qsort(theList, lo0, lo-1,comparator,sortAsc);
        qsort(theList, hi+1, hi0,comparator,sortAsc);
        return theList;
    }

    /**
    * Method returning Map of environment variables objects
    * @author: Krzysztof Wilczek
    */
    public static Map<String, List<Environment_Variables__c>> populateEnvVariables(Set<String> envVarNameSet)
    {
    	Map<String, List<Environment_Variables__c>> result = new Map<String, List<Environment_Variables__c>>();
        for (Environment_Variables__c envVar : GNE_CM_Environment_variable.get_env_variable(envVarNameSet))
        {
        	if(result.containsKey(envVar.Key__c))
        	{
        		result.get(envVar.Key__c).add(envVar);
        	}
        	else
        	{
        		List<Environment_Variables__c> variables = new List<Environment_Variables__c>();
        		variables.add(envVar);
        		result.put(envVar.Key__c, variables);
        	}
        }
        return result;
    }

    /**
    * Custom dictionary class for accessing directly both key and values collection
    * @author: Krzysztof Wilczek
    */
    public class Dictionary
    {
        private Map<String, String> keyMap;
        private Map<String, String> valueMap;

        public Dictionary(Map<String, String> customMap)
        {
            valueMap = customMap;
            keyMap = new Map<String, String>();
            for(String itemKey : customMap.keySet())
                keyMap.put(customMap.get(itemKey), itemKey);
        }

        public String getKey(String value)
        {
            return keyMap.get(value);
        }

        public String getValue(String key)
        {
            return valueMap.get(key);
        }
    }

    /**
     * If the value is null or an empty string, returns true. Otherwise returns false.
     */
    public static Boolean isBlank (String val)
    {
    	return val == null || val == '';
    }

    /**
     * Returns the first non-null value of the two arguments passed.
     */
    public static object coalesce (object item1, object item2)
    {
    	return item1 != null ? item1 : item2;
    }

    /**
     * Returns the first non-null value of the two arguments passed.
     */
    public static String coalesce (String item1, String item2)
    {
    	return item1 != null ? item1 : item2;
    }

    /**
     * Removes all occurrences of trimmedVal from the end of the 'val' string.
     */
    public static String trimRight (String val, String trimmedVal)
    {
    	if (val == null || val == '')
    	{
    		return val;
    	}

    	if (trimmedVal == null || trimmedVal == '')
    	{
    		throw new IllegalArgumentException('Argument trimmedVal in method trimRight must not be empty or null');
    	}

    	// cut off all occurrences of trimmedVal at the end
    	while (val.endsWith(trimmedVal))
    	{
    		val = val.substring(0, val.length() - trimmedVal.length());
    	}

    	return val;
    }

    public static String implode (List<object> items, String delimeter)
    {
    	return implode (items, delimeter, null);
    }

    /**
     * Converts a list of string to a set.
     */
    public static Set<String> listToSet (List<String> items)
    {
    	Set<String> itemSet = new Set<String>();
    	itemSet.addAll(items);
    	return itemSet;
    }

    /**
     * Converts a set of string to a list.
     */
    public static List<String> setToList (Set<String> items)
    {
    	List<String> itemList = new List<String>();
    	itemList.addAll(items);
    	return itemList;
    }

	public static String implode (List<object> items, String delimeter, String wrapper)
	{
		String result = '';

		if (items == null || items.isEmpty())
		{
			return result;
		}

		wrapper = coalesce (wrapper, '');
		delimeter = coalesce (delimeter, '');

		for (object item : items)
		{
			result += wrapper + item + wrapper + delimeter;
		}

		return isBlank(delimeter) ? result : trimRight(result, delimeter);
	}

	/**
	 * Tells if the string represents a number (integer or decimal).
	 */
	public static Boolean isDecimal(String val)
	{
		try
		{
			Decimal.valueOf(val);
			return true;
		}
		catch (System.TypeException e)
		{
			return false;
		}
	}

	public static String formatDate (Date dateObj, String format)
    {
    	if (dateObj == null)
    	{
    		return '';
    	}

    	return DateTime.newInstance(dateObj.year(), dateObj.month(), dateObj.day()).format(format);
    }

	//Bartek changes 20140114

	public static list<selectOption> selectOptionSortByLabel(list<selectOption>
                                                            selectOptionsToSort) {
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1){
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;

        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];
        selectOptionsToSort.remove(pivot);
        for(selectOption SO : selectOptionsToSort){
            if(SO.getLabel() <= pivotValue.getLabel()){
                lessSelectOption.add(SO);
            }else if(SO.getLabel() > pivotValue.getLabel()){
                greaterSelectOption.add(SO);
            }
        }
        list<selectOption> sortedSelectOptions = new list<selectOption>();
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return SortedSelectOptions;
    }

    public static list<selectOption> selectOptionSortByValue(list<selectOption>
                                                            selectOptionsToSort){
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1){
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;

        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];
        selectOptionsToSort.remove(pivot);
        for(selectOption SO : selectOptionsToSort){
            if(SO.getValue() <= pivotValue.getValue()){
                lessSelectOption.add(SO);
            }else if(SO.getValue() > pivotValue.getValue()){
                greaterSelectOption.add(SO);
            }
        }
        list<selectOption> SortedSelectOptions = new list<selectOption>();
        SortedSelectOptions.addAll(selectOptionSortByValue(lessSelectOption));
        SortedSelectOptions.add(pivotValue);
        SortedSelectOptions.addAll(selectOptionSortByValue(greaterSelectOption));
        return SortedSelectOptions;
    }
}