//--------------------------------------------------------------------------------
// COMPONENT: Base Class 
//     CLASS: GNE_Base_Dao
//   PURPOSE: Base Data Access class
// 
//   CREATED: 05/2010 
//--------------------------------------------------------------------------------
Public abstract Class GNE_Base_Dao{
	public String WILDCARD = '*';
	
	//----------------------------------------- ATTRIBUTES ---------------------------
	public String ObjectName { get; set;}
	public String ClassName { get; set;}
	public Boolean IsTestCase { get; set;}
	
	public Boolean DeactivateChangeLog { get; set;}
	
	public Boolean HideDeleted { get; set;}
	
	//----------------------------------------- Data Methods ---------------------------
	public String clean(String value){
		String returnVal = '';
		
		if (!(value == null || value == '')){
			returnVal = value.replaceAll( '<>', '');
		}

		return String.escapeSingleQuotes(returnVal);
	}

	//----------------------------------------- LOG METHODS ---------------------------
	public void handleError(String method, Exception ex){
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO, ex.getMessage());
		ApexPages.addMessage( myMsg);
		ApexPages.addMessages(ex); 
	}

	//----------------------------------------- LOG METHODS ---------------------------
	public void debug(String message){
		System.debug( className + '::' +  message);
	}

	public void logMethod(String methodName){
		System.debug( className + '::' +  methodName);
	}
	
	public void log(String message){
		System.debug( className + '::' +  'e_out:' + message);
	}

	//----------------------------------------- LOG METHODS ---------------------------
	public void logSaved(SObject obj){
		System.debug( className + '::' +  'Saved: ' + obj);
	}

	public void logLoaded(SObject obj){
		System.debug( className + '::' +  'Loaded: ' + obj);
	}
	
	public List<SObject> getSObjectListByWhere(String fieldList, String objName, String whereClause){
		return getSObjectListByWhere( fieldList, objName, whereClause, '');
	}
	
	public List<SObject> getSObjectListByWhere(String fieldList, String objName, String whereClause, String orderClause){
		List<SObject> returnVal = null;
		
		if (HideDeleted != null && HideDeleted == true){                   
			if ((whereClause == null || whereClause == '')){
				whereClause = 'is_deleted__c = false';
			}else{
				whereClause += ' and is_deleted__c = false';
			}
		}

		String query = getSql( fieldList, objName, whereClause, orderClause);
		
		if (IsTestCase != null && IsTestCase == true) query += ' LIMIT 2';
		
		System.debug( 'e_OUT:' + query);

		try{
			returnVal = (List<SObject>)Database.query(query);
		}catch (Exception ex){
			handleError( 'getSObjectListByWhere', ex);
		}
		return returnVal;
	}
	
	public String getSql(String fieldList, String objName, String whereClause, String orderClause){
		String query = 'select ' + fieldList + ' from ' + objName;
		if (!(whereClause == null || whereClause == '')) query += ' where ' + whereClause;  
		if (!(orderClause == null || orderClause == '')) query += ' order by ' + orderClause;
		return query;
	}
	
	public SObject getSObjectById(String fieldList, String objName, String idInp){
		String id = clean(idInp);
		SObject returnVal = null;

		String query = 'select ' + fieldList + ' from ' + objName + ' where id = \'' + id + '\'';
		System.debug( 'e_OUT:' + query);

		try{
			returnVal = (SObject)Database.query(query);
		}catch (Exception ex){
			handleError( 'getSObjectById:' + query , ex);
		}
		return returnVal;
	}    

	public Boolean saveSObject(SObject obj){
		Boolean isSaved = false;
		String action = getAction(obj);
		try{
			upsert obj;
			isSaved = true;
		}
		catch (Exception ex){
			handleError( 'saveSObject', ex);
		}
		return isSaved;
	}

	public virtual Exception saveSObjectEx(SObject obj){
		Boolean isSaved = false;
		String action = getAction(obj);
		try{
			upsert obj;
			isSaved = true;
		}catch (Exception ex){
			return ex;
		}
		return null;
	}
	
	public Boolean saveSObjectList(List<SObject> objList){        
		Boolean isSaved = false;

		//---Build the list of actions for the change log
		List<String> actionList = new List<String>();
		isSaved = true;
		
		if (isSaved && (DeactivateChangeLog == null || DeactivateChangeLog == false)){
			if (objList != null && objList.size() >= 0){
				for(SObject row : objList){
					actionList.add( getAction(row));
				}
			}
		} 
		isSaved = false;
		try{
			upsert objList;
			isSaved = true;
		}catch (Exception ex){
			handleError( 'saveSObjectList', ex);
		}

		return isSaved;
	}
	
	private String getAction(SObject obj){
		String returnVal = '';
		
		String idStr = '' + obj.get('id');
		
		if (idStr == null || idStr == '' || idStr.length() < 10){
			returnVal = 'INSERT';
		}else{
			returnVal = 'UPDATE';
		}
		return returnVal;
	}
	
	public Boolean deleteSObject(SObject obj){        
		Boolean isOk = false;

		try{
			//soft delete
			obj.put('is_deleted__c',true);
			upsert obj;
			isOk = true;
		}catch (Exception ex){
			handleError( 'deleteSObject', ex);
		}
		return isOk;
	}
	
	public Boolean deleteSObjectById(String id){        
		Boolean isOk = false;

		try{
			Database.delete(id);
			isOk = true;
		}catch (Exception ex){
			handleError( 'deleteSObjectById', ex);
		}
		return isOk;
	}
	
	public Boolean deleteSObjectList(List<SObject> obj){        
		Boolean isOk = false;

		try{        
			for(SObject row: obj){
				deleteSObject(row);
			}
			isOk = true;
			delete obj;
		}catch (Exception ex){
			handleError( 'deleteSObjectList', ex);
		}
		return isOk;
	}
	
	//-----------------------Search methods --------------------------------
	public String addSqlWhere(String fieldName, String fieldVal){
		String returnVal = '';
		
		if (!(fieldVal == null || fieldVal == '')){
			//---Clean any illegal characters
			String inputVal = clean(fieldVal.trim()); 
			
			//---Build the base sql
			returnVal += ' AND ' + fieldName + ' LIKE \'';
			
			if (inputVal.contains(WILDCARD)){
				returnVal += inputVal.replace(WILDCARD, '%'); 
			}else{
				returnVal += '%' + inputVal + '%';  
			}       
			returnVal += '\'';  
		}
		return returnVal;
	}
	
	public String addSqlWhereLikeInside(String fieldName, String[] fieldsVal){
		String returnVal = null;
		
		if (!(fieldsVal == null || fieldsVal.isEmpty())){
			List<String> values = new List<String>();
			for(String tmp :fieldsVal){
				values.add(clean(tmp.trim()));
			}
			
			returnVal = String.format(' AND {0} LIKE {1}', new String[]{fieldName, '\'%' + String.join(values,'%') + '%\''}); 
		}

		return returnVal!=null ? returnVal : '';
	}
	
	//-----------------------Search methods --------------------------------
	public String addSqlLikeStart(String fieldName, String fieldVal){
		String returnVal = '';
		
		if (!(fieldVal == null || fieldVal == '')){
			//---Clean any illegal characters
			String inputVal = clean(fieldVal.trim()); 
			
			//---Build the base sql
			returnVal += ' and ' + fieldName + ' LIKE \'';
			
			if (inputVal.contains(WILDCARD)){
				returnVal += inputVal.replace(WILDCARD, '%'); 
			}else{
				returnVal += inputVal + '%';    
			}       
			returnVal += '\'';  
		}
		return returnVal;
	}
	
	public String addSqlWhereMatch(String fieldName, String fieldVal){
		return ' and ' + fieldName + ' = \'' + fieldVal + '\'';
	}
	
	public String addSqlWhereIN(String fieldName, String fieldVal){
		return ' and ' + fieldName + ' IN (\'' + fieldVal + '\')';
	}
	
	public String addSqlWhereInclude(String fieldName, String fieldVal){
		return ' and ' + fieldName + ' INCLUDES (\'' + fieldVal + '\')';
	}
	
	public String addSqlWhereMatch(String fieldName, Date fieldVal){
		Datetime dTime = datetime.newInstance(fieldVal.year(), fieldVal.month(), fieldVal.day());
		String dtStr = dTime.format('yyyy-MM-dd');
		return ' AND ' + fieldName + '=' + dtStr;
	}

	public String addSqlWhereMatch(String fieldName, Boolean fieldVal){
		return ' and ' + fieldName + ' = ' + String.valueOf(fieldVal);
	}	
	
	public String removeLeadingAnd(String inputVal){
		String returnVal = inputVal;
		if (returnVal.startsWith(' AND ')){
			returnVal = returnVal.substring(5);
		}else if (returnVal.startsWith(' and ')){
			returnVal = returnVal.substring(5);
		}
		return returnVal;
	}
	
	public static String getFieldSql(Map<String, Schema.SObjectField> fMap){
		return getFieldSql( fMap, '');  
	}
	
	public static String getFieldSql(Map<String, Schema.SObjectField> fMap, String prefix){
		String fieldList = '';      
		List<Schema.SObjectField> fTokens = fMap.values();

		for( Integer i = 0 ; i < fTokens.size() ; i++ ){
			Schema.DescribeFieldResult f = fTokens.get(i).getDescribe();
			
			if( f.isAccessible()){                       
				if (!(fieldList == null || fieldList == '')) fieldList += ',';              
				if (!(prefix == null || prefix == '')) fieldList += prefix + '.';                               
				fieldList += f.getName();   
			}  
		}
		return fieldList;    
	} 
	
	public static List<String> getLabelList(Map<String, Schema.SObjectField> fMap){
		List<String> returnList = new List<String>();       
		List<Schema.SObjectField> fTokens = fMap.values();

		for( Integer i = 0 ; i < fTokens.size() ; i++ ){
			Schema.DescribeFieldResult f = fTokens.get(i).getDescribe();
			if( f.isAccessible()) returnList.add(f.getLabel());
		}
		return returnList;    
	}
	
	public static List<String> getFieldList(Map<String, Schema.SObjectField> fMap){
		List<String> returnList = new List<String>();       
		List<Schema.SObjectField> fTokens = fMap.values();

		for( Integer i = 0 ; i < fTokens.size() ; i++ ){
			Schema.DescribeFieldResult f = fTokens.get(i).getDescribe();
			if( f.isAccessible()) returnList.add(f.getName());
		}
		return returnList;    
	} 
	
	public Boolean isNullOrEmpty(String value){
		return value == null || value == '';
	}
}