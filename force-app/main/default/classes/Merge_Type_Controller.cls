public class Merge_Type_Controller {

      List<String> deferOnConflictFields               = new List<String>();
      List<String> deferOnConflictConsiderNullFields   = new List<String>();
      List<String> deferProfessionalTypeFields     = new List<String>();
      List<String> deferOnLoserRelatedListCount    = new List<String>();
      List<String> notNullFields                   = new List<String>();
      List<String> booleanORFields                 = new List<String>();
      List<String> preferLowValueFields            = new List<String>();
      List<String> preferHighValueFields           = new List<String>();
      Set<String> customPreMergeActions			   = new Set<String>();
      Set<String> customPostMergeActions		   = new Set<String>();
      Map<String, List<String>> peckingOrderFields = new Map<String,List<String>>();
      Map<String,SObjectField> relationshipMap     = new Map<String,SObjectField>();
      Map<String,SObjectField> excludedRelationshipMap	= new Map<String,SObjectField>();
      Map<String,String> excludeMatchingFields     = new Map<String,String>();
      Map<String,Map<String,Object>> fieldAttributes = new Map<String,Map<String,Object>>();

      Map<String,String> fieldToExceptionCode      = new Map<String,String>();
      Map<String,Boolean> fieldToAddExceptionDesc  = new Map<String,Boolean>();

      String sort_by_columns = null;
      String mdm_id_field_name = null;
      String objectName = null;
      Merge_Type_gne__c mergeType = null;
      String objectSQL = null;

      boolean bCheckMode = false;

      Merge_Type_DuplicateSet duplicateSet = null;
      private static final String DEFAULT_BUSINESS_RULE_EXCEPTION_CODE = 'EXCEPTION CODE NOT DEFINED';
      private static final String FIELD_ATTRIBUTE_NULL_VALUES = 'NullValues';


    void initialize() {
        Merge_Type_Business_Rule_gne__c[] mergeTypeRuleList =
                        [select id, field_type_gne__c, field_name_gne__c,
                                relatedlist_query_text_gne__c,
                                exception_code_gne__c, log_exception_column_values_gne__c
                         from Merge_Type_Business_Rule_gne__c
                         where     Merge_Type_ref_gne__c = :mergeType.Id
                               and active_gne__c           = true
                         order by field_type_gne__c, field_name_gne__c desc];

		Set<String> soqlFields = new Set<String>{'id'};
		system.debug('Business Ruless');
		
        for (Merge_Type_Business_Rule_gne__c mergeTypeRule : mergeTypeRuleList) {
			system.debug('BR Id, field_name_gne__c: ' + mergeTypeRule.id + ', ' + mergeTypeRule.field_name_gne__c);
 
            if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('DeferOnConflict') ) {
                soqlFields.add(mergeTypeRule.field_name_gne__c);
                deferOnConflictFields.add(mergeTypeRule.field_name_gne__c);
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('DeferOnConflictConsiderNullAsUnique') ) {
                soqlFields.add(mergeTypeRule.field_name_gne__c);
                deferOnConflictConsiderNullFields.add(mergeTypeRule.field_name_gne__c);
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('Not Null') ) {
                soqlFields.add(mergeTypeRule.field_name_gne__c);
                notNullFields.add(mergeTypeRule.field_name_gne__c);
                readFieldAttributes(mergeTypeRule);
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('PreferLowValue') ) {
                soqlFields.add(mergeTypeRule.field_name_gne__c);
                preferLowValueFields.add(mergeTypeRule.field_name_gne__c);
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('PreferHighValue') ) {
                soqlFields.add(mergeTypeRule.field_name_gne__c);
                preferHighValueFields.add(mergeTypeRule.field_name_gne__c);
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('Boolean OR') ) {
                soqlFields.add(mergeTypeRule.field_name_gne__c);
                booleanORFields.add(mergeTypeRule.field_name_gne__c);
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('ExcludeMatching') ) {
                soqlFields.add(mergeTypeRule.field_name_gne__c);
                excludeMatchingFields.put(mergeTypeRule.field_name_gne__c, mergeTypeRule.relatedlist_query_text_gne__c!=null
                		? mergeTypeRule.relatedlist_query_text_gne__c.toUpperCase() : null);
            } else if ( mergeTypeRule.field_type_gne__c.startsWith('Pecking') ) {
                soqlFields.add(mergeTypeRule.field_name_gne__c);
                List<String> fieldList = peckingOrderFields.get(mergeTypeRule.field_type_gne__c.toUpperCase());
                if ( fieldList == null ){
                    fieldList = new List<String>();
                    peckingOrderFields.put(mergeTypeRule.field_type_gne__c.toUpperCase(), fieldList);
                }
                fieldList.add(mergeTypeRule.field_name_gne__c);
            } else if ( mergeTypeRule.field_type_gne__c.startsWith('Sort By Columns') ) {
                sort_by_columns = mergeTypeRule.field_name_gne__c;
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('MDM Id Field Name') ) {
                mdm_id_field_name = mergeTypeRule.field_name_gne__c;
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('Relationship To Move') ) {
                String relName = getRelationshipName(mergeTypeRule.field_name_gne__c);
                relationshipMap.put(relName, null);
                readFieldAttributes(relName, mergeTypeRule);
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('Relationship To Exclude') ) {
                String relName = getRelationshipName(mergeTypeRule.field_name_gne__c);
                excludedRelationshipMap.put(relName, null);
                readFieldAttributes(relName, mergeTypeRule);
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('DeferOnLoserSignificantRelatedListCount') ) {
                deferOnLoserRelatedListCount.add (mergeTypeRule.field_name_gne__c);
                soqlFields.add('('+ mergeTypeRule.relatedlist_query_text_gne__c + ')');
            } else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('CustomPreMergeAction') ) {
            	customPreMergeActions.add(mergeTypeRule.field_name_gne__c.toUpperCase());
            }  else if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('CustomPostMergeAction') ) {
            	customPostMergeActions.add(mergeTypeRule.field_name_gne__c.toUpperCase());
            }

            if (mergeTypeRule.exception_code_gne__c != null ) {
                fieldToExceptionCode.put ( mergeTypeRule.field_name_gne__c,
                                           mergeTypeRule.exception_code_gne__c);
            }

            Boolean bAddExceptionCodeDesc = mergeTypeRule.log_exception_column_values_gne__c;
            fieldToAddExceptionDesc.put ( mergeTypeRule.field_name_gne__c,
                                           bAddExceptionCodeDesc);

        }

        // add one more scan for professional type
        for (Merge_Type_Business_Rule_gne__c mergeTypeRule : mergeTypeRuleList) {
            if ( mergeTypeRule.field_type_gne__c.equalsIgnoreCase('DeferWhenProfessionalTypeIsNotPrescriber') ) {
                deferProfessionalTypeFields.add (mergeTypeRule.field_name_gne__c);
                soqlFields.add('('+ mergeTypeRule.relatedlist_query_text_gne__c + ')');
                soqlFields.add('professional_type_gne__c');
            }
        }
        
        objectSQL = String.format('SELECT {0} FROM {1}', new String[]{
        		String.join(new List<String>(soqlFields),','),
        		objectName
        });

        // get relationship field name in child object 
        if (!relationshipMap.isEmpty() || !excludedRelationshipMap.isEmpty()) {            
            Map<String,SObjectField> tempMap= new Map<String,SObjectField>{};
            Schema.DescribeSObjectResult objectChildren = Schema.getGlobalDescribe().get(mergeType.Object_Name_gne__c).getDescribe();
            List<Schema.ChildRelationship> childRelationship = objectChildren.getChildRelationships();
            for (Schema.ChildRelationship child : childRelationship ) {
            	// Workaround for Salesforce Case #10482798 - Some Schema Child Relationship Names are not set
            	if(String.isNotBlank(child.getRelationshipName())) {
                	tempMap.put(getRelationshipName(child.getRelationshipName()), child.getField());
            	}
            }
            
            for (String relationshipName : relationshipMap.keySet()) {
                relationshipMap.put ( relationshipName, tempMap.get(relationshipName) );
            }
            
            for (String relationshipName : excludedRelationshipMap.keySet()) {
                excludedRelationshipMap.put ( relationshipName, tempMap.get(relationshipName) );
            } 
        }

        System.debug (LoggingLevel.INFO, 'DeferOnConflict/deferOnConflictConsiderNull/NotNull/PeckingOrderFields/Boolean OR fields configured-> ' +
                       deferOnConflictFields.size()  + '/' +
                       deferOnConflictConsiderNullFields.size()  + '/' +
                       notNullFields.size() + '/' +
                       peckingOrderFields.size()  +
                       booleanORFields.size()    ) ;
    }
    
    private String getRelationshipName(String rName) {
        return Pattern.matches('^R00[^_]+(?!__r)$', rName) ? rName : rName.toUpperCase();
    }
    
    private void readFieldAttributes(Merge_Type_Business_Rule_gne__c mergeTypeRule) {
        readFieldAttributes(mergeTypeRule.field_name_gne__c.toUpperCase(), mergeTypeRule);
    }
    
    private void readFieldAttributes(String fieldName, Merge_Type_Business_Rule_gne__c mergeTypeRule) {
    	if(String.isNotBlank(fieldName) && String.isNotBlank(mergeTypeRule.relatedlist_query_text_gne__c)) {
    	    try {
    		  fieldAttributes.put(fieldName, (Map<String,Object>)JSON.deserializeUntyped(mergeTypeRule.relatedlist_query_text_gne__c));
    	    } catch(System.JSONException je) {
    	       System.debug (LoggingLevel.INFO,  'Error while parsing relatedlist_query_text_gne__c --> ' + mergeTypeRule.relatedlist_query_text_gne__c);
    	    }
    	}
    }
    
    public String getObjectChildRelationsipSQL () {
    	return getObjectChildRelationsipSQL(relationshipMap);
    }
    
    public String getObjectChildRelationsipSQL(Map<String,SObjectField> childRelationshipsMap) {
        List<String> childQueries = new List<String>();
        
        for (String relationshipName : childRelationshipsMap.keySet() ) {
            String childWhereStatement = fieldAttributes.containsKey(relationshipName) ? (String)fieldAttributes.get(relationshipName).get('WHERE') : null;
            
            childQueries.add(String.format('(SELECT Id, {0} FROM {1}{2})', new String[]{
                String.valueOf(childRelationshipsMap.get(relationshipName)), relationshipName,
                String.isNotBlank(childWhereStatement) ? (' WHERE ' + childWhereStatement) : ''
            }));
        }
        
        return String.format('SELECT Id{0} FROM {1}', new String[]{
            childQueries.isEmpty() ? '' : (',' + String.join(childQueries, ',')),
            objectName
        });
    }

    public Merge_Type_Controller (Merge_Type_gne__c mergeType,boolean MergeRunMode) {
        this.mergeType = mergeType;
        this.objectName = mergeType.Object_Name_gne__c;
        bCheckMode = MergeRunMode;
        initialize();
    }

    public Merge_Type_Controller () {}

      SObject[] orderObjectMergeList (Set<String> objectIdSet, String winnerAccountId) {
      // order object list by given sort columns
          String object_sql = '';
          object_sql = objectSQL +
                     ' where Id in :objectIdSet ' +
                     ' order by ' + sort_by_columns;
          System.debug (LoggingLevel.INFO,  'orderObjectMergeList --> ' + object_sql  );
          SObject[] objectList = Database.query(object_sql);
          return objectList;
      }

      Boolean copyNotNullFieldValues (SObject winnerObject, SObject loserObject) {
          Boolean bwinnerObjectUpdated = false;
          List<String> copyFieldValues = new List<String>();
          copyFieldValues.addAll(notNullFields);
          copyFieldValues.addAll(deferOnConflictFields);
          for ( String fieldName : copyFieldValues) {
              Object currentValue = winnerObject.get ( fieldName );
              Object newValue     = loserObject.get ( fieldName );
              if (isNullFieldValue(fieldName, currentValue) && !isNullFieldValue(fieldName, newValue)) {
                  winnerObject.put (fieldName, newValue);
                  bwinnerObjectUpdated = true;
              }
          }
          return bwinnerObjectUpdated;
      }
      
	private Boolean isNullFieldValue(String fieldName, Object fieldValue) {
    	Boolean result = fieldValue==null;
    	String fieldNameUc;
    	if(!result && fieldAttributes.containsKey((fieldNameUc = fieldName.toUpperCase())) && fieldAttributes.get(fieldNameUc).containsKey(FIELD_ATTRIBUTE_NULL_VALUES)) {
    		List<Object> nullValues = (List<Object>)fieldAttributes.get(fieldNameUc).get(FIELD_ATTRIBUTE_NULL_VALUES);
    		
    		if(nullValues!=null) {
    			for(Object nullValue : nullValues) {
    				if((result=String.valueOf(fieldValue)==String.valueOf(nullValue!=null ? nullValue : ''))) {
    					break;
    				}
    			}
    		}
    	}
    	
    	return result;
    }

      Boolean copyBooleanORFieldValues (SObject winnerObject, SObject loserObject) {
          Boolean bwinnerObjectUpdated = false;
          for ( String fieldName : booleanORFields) {
              Object currentValue = winnerObject.get ( fieldName );
              Object newValue     = loserObject.get ( fieldName );
              System.debug (LoggingLevel.INFO, '---Boolean OR Logic Field Name / current Value / new Value --> ' + fieldName + '/' + currentValue + '/' + newValue);
              if ( newValue == true && (currentValue == null || currentValue == false) ){
                  winnerObject.put (fieldName, newValue);
                  bwinnerObjectUpdated = true;
              }
          }
          return bwinnerObjectUpdated;
      }

      // pending low value check cannot use inequality operator..
      Boolean copyPreferLowFieldValues (SObject winnerObject, SObject loserObject) {
          Boolean bwinnerObjectUpdated = false;
          for ( String fieldName : preferLowValueFields) {

              Object currentValue = winnerObject.get ( fieldName );
              Object newValue     = loserObject.get ( fieldName );

              System.debug (LoggingLevel.INFO, '---Prefer Low Field Name / current Value / new Value --> ' + fieldName + '/' + currentValue + '/' + newValue);
              if ( newValue != null  && (currentValue == null || ((Double)currentValue > (Double)newValue)) ){
                  winnerObject.put (fieldName, newValue);
                  bwinnerObjectUpdated = true;
              }
          }
          return bwinnerObjectUpdated;
      }

      Boolean copyPreferHighFieldValues (SObject winnerObject, SObject loserObject) {
          Boolean bwinnerObjectUpdated = false;
          for ( String fieldName : preferHighValueFields) {

              Object currentValue = winnerObject.get ( fieldName );
              Object newValue     = loserObject.get ( fieldName );

              System.debug (LoggingLevel.INFO, '---Prefer High Field Name / current Value / new Value --> ' + fieldName + '/' + currentValue + '/' + newValue);
              if ( newValue != null  && (currentValue == null || ((Double)currentValue < (Double)newValue)) ){
                  winnerObject.put (fieldName, newValue);
                  bwinnerObjectUpdated = true;
              }
          }
          return bwinnerObjectUpdated;
      }

      Boolean copyPeckingOrderFieldValues (SObject winnerObject, SObject loserObject) {
          // unoptimize code - inner winner object loop to find first empty field
          // within a given pecking order field group
          Boolean bwinnerObjectUpdated = false;
          return bWinnerObjectUpdated;
      }

      // improved defer on conflict across all record at one time
      // 4/12/2010
      void AnyDeferOnConflictFieldValuesAcrossLoserObjects (SObject winnerObject, SObject[] objectList) {

          String allRecordIds = '';
          for ( SObject loserObject : objectList ) {
            allRecordIds = allRecordIds + loserObject.get('id') + ':' ;
          }

          for ( String fieldName : deferOnConflictFields ) {

              Object currentValue     = winnerObject.get ( fieldName );
              String firstIdWithValue = (String ) winnerObject.get('id');

              for ( SObject loserObject : objectList ) {

                  if ( loserObject == winnerObject )
                     continue;

                  Object newValue     = loserObject.get ( fieldName );
                  if ( currentValue == null && newValue != null ) {
                       currentValue = newValue;
                       firstIdWithValue = (String ) loserObject.get('id');
                       continue;
                  }

                  if ( currentValue != null && newValue != null && currentValue != newValue) {
                      String msg = fieldName +  ' value conflict - ' +
                                    currentValue + '/' + newValue    + '. ' +
                                    'First Record Id / Conflicting Loser Object Id -> '  +
                                    firstIdWithValue          + '/' +
                                    loserObject.get('id')           + '. ' +
                                    'AllRecordIds -> ' + allRecordIds + '.' ;
                      System.debug (LoggingLevel.INFO, 'AnyDeferOnConflictFieldValuesAcrossLoserObjects --> ' + msg );
                      addException (fieldName, (String)loserObject.get('id'), msg);
                  }
              }
          }
      }

      void AnydeferOnConflictConsiderNullFieldValues (SObject winnerObject, SObject loserObject) {

          System.debug (LoggingLevel.INFO, 'AnydeferOnConflictConsiderNullFieldValues invoked winnerObject/loserObject ->' +
                         winnerObject.get('id') + '/' + loserObject.get('id') + '.' );
          for ( String fieldName : deferOnConflictConsiderNullFields ) {
              Object currentValue = winnerObject.get ( fieldName );
              Object newValue     = loserObject.get ( fieldName );

              if ( currentValue == null && newValue == null )
                  continue; // not an issue

              if ( currentValue == null || newValue == null ||
                   currentValue != newValue ) {

                  String msg = fieldName +  ' value conflict - (' +
                                currentValue + ')/(' + newValue    + '). ' +
                                'Winner / Loser Object Id -> '  +
                                winnerObject.get('id')          + '/' +
                                loserObject.get('id')           + '.';

                  System.debug (LoggingLevel.INFO, 'AnydeferOnConflictConsiderNullFieldValues-->' +  msg );
                  addException ( fieldName, (String)loserObject.get('id'), msg );
              }
          }
      }

      void deferWhenProfessionalTypeIsNotPrescriber (SObject winnerObject, SObject[] objectList) {

          System.debug (LoggingLevel.INFO, 'deferWhenProfessionalTypeIsNotPrescriber invoked winnerObject ->' +
                         winnerObject.get('id') );
          if ( deferProfessionalTypeFields.size() > 0 ) {
              String validProfessionalTypes = System.Label.DCH_CM_Valid_Professional_Types_gne;
              String winnerProfessionalType = (String)winnerObject.get('professional_type_gne__c');
              if ( winnerProfessionalType != null &&
                   validProfessionalTypes.indexOf(winnerProfessionalType + ':') != -1)
                return ; // prescriber winner account
          }

          for ( String fieldName : deferProfessionalTypeFields ) {
              for ( SObject loserObject : objectList ) {
                  if ( loserObject == winnerObject )
                     continue;
                  SObject[] relatedList  = loserObject.getSObjects ( fieldName );
                  if ( relatedList != null ) {
                      if ( relatedList.size() > 0 ) {
                          String msg = 'Account Id ' + loserObject.get('id') +
                                       ' has related list record for child relationship: ' +
                                       fieldName + '.  Total related list count is '+
                                       relatedList.size()  ;
                          System.debug (LoggingLevel.INFO, 'deferWhenProfessionalTypeIsNotPrescriber on winner --> ' + msg );
                          addException (fieldName, (String)loserObject.get('id'), msg);
                      }
                  }
              }
          }
      }

      // 03/16/2010 - need to check all relationship
      void MoreThanOneAccountHavingRelatedListCount  (SObject winnerObject, SObject[] objectList) {

          for ( String fieldName : deferOnLoserRelatedListCount ) {
              Integer numOfAcctsHavingRelatedListCount = 0;
              for ( SObject objectRecord : objectList ) {
                  SObject[] relatedList  = objectRecord.getSObjects ( fieldName );
                  if ( relatedList != null) {
                      if ( relatedList.size() > 0 ) {
                          numOfAcctsHavingRelatedListCount += 1;
                      }
                  }
              }

            if ( numOfAcctsHavingRelatedListCount > 1 ){
                String msg = 'More than one account has related list for Relationship-> '+
                             fieldName ;
                System.debug (LoggingLevel.INFO, 'MoreThanOneAccountHavingRelatedListCount  --> ' + msg );
                for ( SObject objectRecord : objectList ) {
                    SObject[] relatedList  = objectRecord.getSObjects ( fieldName );
                    if ( relatedList != null) {
                        if ( relatedList.size() > 0 ) {
                            addException (fieldName, (String)objectRecord.get('id'), msg);
                        }
                    }
                }
            }

          }
      }
      
    private void excludeChildRelationships(Set<Id> loserObjectIdSet) {
		for ( Sobject loserObject : getChildRecords(loserObjectIdSet, excludedRelationshipMap, false) ) {              
			for (String relationshipName : excludedRelationshipMap.keySet() ) {
				SObject[] childObjects = loserObject.getSObjects (relationshipName);
		        
		        if (childObjects!=null && !childObjects.isEmpty()) {
		        	for(SObject child : childObjects) {
			        	System.debug (LoggingLevel.INFO, 'Deleting loser id / excluded child relationship / child Ids ' + 
			                	loserObject.get('id') + '/' + 
			                    relationshipName + '/' +
			                    child.get('id') );
		        	}
		        	
		        	delete childObjects;
		        }
			}
		}
    }
    
    private SObject[] moveChildRelationships(SObject winnerObject, Set<Id> loserObjectIdSet) {
    	SObject[] loserObjects = getChildRecords(loserObjectIdSet, relationshipMap, true);
    	for ( Sobject loserObject : loserObjects) {              
			for (String relationshipName : relationshipMap.keySet() ) {
				SObject[] childObjects = loserObject.getSObjects (relationshipName);
		        
		        if (childObjects!=null && !childObjects.isEmpty()) {
					for (SObject child : childObjects) {
		            	System.debug (LoggingLevel.INFO, 'Moving loser address / child relationship / child Id ' + 
		                	loserObject.get('id') + '/' + 
		                    relationshipName + '/' +
		                    child.get('id') );
		                child.put(relationshipMap.get(relationshipName), winnerObject.get('id'));
		            }
		            
		            update childObjects;
		    	}    
			}
		}
		
		return loserObjects;
    }
    
    private SObject[] getChildRecords(Set<Id> loserObjectIdSet, Map<String,SObjectField> childRelationshipMap, Boolean forceQuery) {
        SObject[] result = new SObject[]{};
        
        if(forceQuery==true || !childRelationshipMap.isEmpty()) {
            String sql = String.format('{0} WHERE Id IN :loserObjectIdSet', new String[]{getObjectChildRelationsipSQL(childRelationshipMap)});
            System.debug (LoggingLevel.INFO,  'child relationship dynamic sql prepared --> ' + sql ); 
            result = Database.query (sql);
        }
        
        return result;
	}
	
	private Boolean isAffiliationMerge() {
		return objectName=='Affiliation_vod__c';
	}
	
	private void handleMissingWinnerRecord() {
		if(!isAffiliationMerge()) {
        	String msg = 'No winner ' + objectName + ' record present in this group.';
          	throw new Merge_Type_Exception(msg);
        }
	}
	
	private void handleMissingLosersRecords() {
		if(!isAffiliationMerge()) {
			String msg = 'No losing ' + objectName + ' record present in this group.';
		    throw new Merge_Type_Exception(msg);
	    }
	}
	
	private void updateWinnerObject(SObject winnerObject, Boolean bWinnerObjectUpdated) {
		// Winner Affiliations with loops can be deleted before reaching this code.
        // This is correct, because affiliations with loops are not allowed and should be removed from the system.
        // No exception should be reported.
        Id winnerId = winnerObject.Id;
        if(bWinnerObjectUpdated && (!isAffiliationMerge() || !Database.query('SELECT Id FROM Affiliation_vod__c WHERE Id = :winnerId').isEmpty())) {
        	update winnerObject;
		    System.debug (LoggingLevel.INFO, 'Winner Object updated..');
   		}
	}
	
    private void addException (String fieldName,
                               String loserId,
                               String errorDesc) {

      String  exceptionCode     = fieldToExceptionCode.get ( fieldName );
      Boolean bAddExceptionDesc = fieldToAddExceptionDesc.get(fieldName);


      if ( exceptionCode == null )
        exceptionCode = Merge_Type_Controller.DEFAULT_BUSINESS_RULE_EXCEPTION_CODE;

      List<String> exceptionCodeList =
            duplicateSet.LoserToExceptionCodeList.get(loserId);
      List<String> errorDescList     =
            duplicateSet.LoserToErrorDescList.get(loserId);

      if ( exceptionCodeList == null ) {
          exceptionCodeList = new List<String>();
          errorDescList     = new List<String>();
      }

      exceptionCodeList.add ( exceptionCode );
      if ( bAddExceptionDesc )
        errorDescList.add ( errorDesc );
      else
        errorDescList.add ( fieldName );

      duplicateSet.LoserToExceptionCodeList.put ( loserId, exceptionCodeList);
      duplicateSet.LoserToErrorDescList.put ( loserId, errorDescList);

    }

      boolean anyExceptionsCaptured (SObject[] objectList,
                                    Merge_Type_DuplicateSet duplicateSet) {
        Boolean bExceptionPresent = false;
        String allExceptionListString = '';
        for ( SObject objectRecord : objectList ){
            List<String> exceptionCodeList =
                duplicateSet.LoserToExceptionCodeList.get((String)objectRecord.get('id'));
            if ( exceptionCodeList != null ) {
                bExceptionPresent = true;
                break;
            }
        }
        return bExceptionPresent;
      }
      
	private void checkIfContainsExcludedRecords(SObject winnerObject, SObject[] objectList) {
		String msg = 'Exclude matching record -> ';
		for(String excludedField : excludeMatchingFields.keySet()) {
			String matchingValue = excludeMatchingFields.get(excludedField);
			
			for(SObject objectRecord : objectList) {
				Object objFieldValue = objectRecord.get(excludedField);
				String fieldValue = objFieldValue!=null ? String.valueOf(objFieldValue) : null;
				
				if(fieldValue == matchingValue) {
					addException(excludedField, (String)objectRecord.get('id'), String.format(
						'Exclude matching record -> {0} = {1} (Id: {2}, Type: {3})', new String[]{
							excludedField, matchingValue, objectRecord.Id, (objectRecord.Id == winnerObject.Id ? 'Winner' : 'Loser') 
					}));
				}
			}
		}
	}

      public String doMerge(Set<String> objectIdSet, String winnerAccountId,
                            Merge_Type_DuplicateSet duplicateSet) {
          String returnMsg = null;
          this.duplicateSet = duplicateSet;
          SObject winnerObject   = null;
          SObject[] objectList = orderObjectMergeList ( objectIdSet, winnerAccountId );
          
          //select the winner what is passed in
          for(SObject tempObject : objectList) {
              Id recordId = tempObject.Id;
              
              if(recordId == (Id)winnerAccountId) {
                 winnerObject = tempObject;
                 break;
              }
          }
          
          if(winnerObject==null) {
          	  handleMissingWinnerRecord();
          	  return null;
          }

          for ( Integer i = 0; i < objectList.size(); i++ ) {
              SObject loserObject = objectList[i];

              if ( loserObject.get('id') == winnerObject.get('id') ) {
                  continue;
              }

              System.debug (LoggingLevel.INFO, 'add loser object Id  -> ' + loserObject.get('id') );
              AnydeferOnConflictConsiderNullFieldValues(winnerObject,loserObject);
          }

          checkIfContainsExcludedRecords(winnerObject,objectList);
          AnyDeferOnConflictFieldValuesAcrossLoserObjects(winnerObject,objectList);
          MoreThanOneAccountHavingRelatedListCount(winnerObject, objectList);
          deferWhenProfessionalTypeIsNotPrescriber(winnerObject, objectList);

          if ( bCheckMode ) {
            return (String )winnerObject.get('id');
          }

          // 04/13/2010 captured via sqa test cycle
          if ( anyExceptionsCaptured(objectList, duplicateSet) ) {
            return null; // skip merge process.
          }

          System.Savepoint sp = Database.setSavepoint();
          try {
	          Boolean bWinnerObjectUpdated = false;
	          Set<Id> loserObjectIdSet = new Set<Id>();
	          
	          for (Integer i=0; i<objectList.size(); i++) {
	              SObject loserObject = objectList[i];
	
	              if(loserObject.id == winnerObject.id) {
	                  continue;
	              }
	
	              loserObjectIdSet.add(loserObject.id);
	              bWinnerObjectUpdated = copyNotNullFieldValues (winnerObject,loserObject);
	              bWinnerObjectUpdated |= copyPeckingOrderFieldValues (winnerObject,loserObject);
	              bWinnerObjectUpdated |= copyBooleanORFieldValues (winnerObject,loserObject);
	              bWinnerObjectUpdated |= copyPreferLowFieldValues (winnerObject,loserObject);
	              bWinnerObjectUpdated |= copyPreferHighFieldValues (winnerObject,loserObject);
	          }
	
	          // move losing address child record/relationship to winner address
              if (!loserObjectIdSet.isEmpty()) {
              	  bWinnerObjectUpdated |= perfromPreMergeActions(objectName, winnerObject, loserObjectIdSet, objectList);
            	  excludeChildRelationships(loserObjectIdSet);
            	  
                  if ( objectName.equalsIgnoreCase('Account') ) {
                  	String accountId = (String)winnerObject.get('id');
                    Account acct = new Account(Id = accountId);

                    for (Id id : loserObjectIdSet) {
                        System.debug (LoggingLevel.INFO, 'calling merge for Id ' + id );
                        merge acct id;
                    }
                  } else {
                      // custom object merge functionality
                      SObject[] objects = moveChildRelationships(winnerObject, loserObjectIdSet);
		              delete objects;
                  }
                  
                  // Update winner after all loser records are deleted - there could be DUPLICATED_VALUE exception raised on unique fields.
                  updateWinnerObject(winnerObject, bWinnerObjectUpdated);
                  perfromPostMergeActions(objectName, winnerObject, loserObjectIdSet, objectList);
	          } else {
	          	  handleMissingLosersRecords();
	          }
          } catch (Exception e) {
              database.rollback(sp);
              System.debug (LoggingLevel.INFO,  'Error moving losing ' + objectName + ' child records -> '+ e.getMessage() );
              throw e;
          }
          // return winner
          return (String )winnerObject.get('id');
      }
      
      private Boolean perfromPreMergeActions(String objectName, SObject winnerObject, Set<Id> loserIds, SObject[] objectList) {
      	  Boolean bWinnerObjectUpdated = false;
      	  if(customPreMergeActions.contains('updateLoserParentCalls()'.toUpperCase())) {
      	  	  // update parent interaction in case of merged looser account is bind
          	  // to child interaction (to update parent interaction lastmodifieddate)
          	  bWinnerObjectUpdated |=updateLoserParentCalls(loserIds);
      	  }
      	  
      	  if(customPreMergeActions.contains('updateClassifications()'.toUpperCase())){
      	  	// update clinical and business classification values and dates
      	  	// in the winner record to the most recent value
      	  	bWinnerObjectUpdated |= updateClassifications(winnerObject, objectList);
      	  }
      	  
      	  if(customPreMergeActions.contains('updateExclusions()'.toUpperCase())){
      	  	// update exclusion status and date
      	  	// in the winner record to the most recent value
      	  	bWinnerObjectUpdated |= updateExclusions(winnerObject, objectList);
      	  }
      	  
      	  return bWinnerObjectUpdated;
      }
      
      private void perfromPostMergeActions(String objectName, SObject winnerObject, Set<Id> loserIds, SObject[] objectList) {
      	  if(customPostMergeActions.contains('updateAddressPrimaryFlag()'.toUpperCase())) {
      	  	  updateAddressPrimaryFlag(objectName, winnerObject);
      	  }
      	  
      	  if(customPostMergeActions.contains('setTSFAddress()'.toUpperCase())) {
      	  	  setTSFAddress(winnerObject);
      	  }
      	  
      	  if(customPostMergeActions.contains('updateExternalId()'.toUpperCase())) {
              updateExternalId(new List<SObject>{winnerObject});
          }
      }
      
      private Boolean updateLoserParentCalls(Set<Id> loserObjectIdSet) {
      	  List<Call2_vod__c> childCallsRelatedToLooserAccount = [
          	SELECT Id, Account_vod__c, Parent_Call_vod__c 
          	FROM Call2_vod__c
          	WHERE Account_vod__c in :loserObjectIdSet
          		AND Parent_Call_vod__c != null
          ];

          Map<Id,Call2_vod__c> parentCallsToUpdate = new Map<Id,Call2_vod__c>();
          for (Call2_vod__c call : childCallsRelatedToLooserAccount) {
          	if(!parentCallsToUpdate.containsKey(call.Parent_Call_vod__c)) {
          		parentCallsToUpdate.put(call.Parent_Call_vod__c, new Call2_vod__c(Id = call.Parent_Call_vod__c));
          	}
          }

          if(!parentCallsToUpdate.isEmpty()) {
          	update parentCallsToUpdate.values();
          }
          
          return false;
      }
      
      private Boolean updateClassifications(SObject winnerObject, SObject[] objectList){
      	Boolean bWinnerObjectUpdated = false;
      	Account winnerAccount = (Account)winnerObject;
      	
      	List<Account> accounts = [
      		SELECT
      			Id,
      			EDM_Business_Classification_gne__c,
      			EDM_Business_Classification_Date_gne__c,
      			EDM_Clinical_Classification_gne__c,
      			EDM_Clinical_Classification_Date_gne__c
      		FROM Account
      		WHERE Id in :objectList
      	];
      		
      	Date winnerBCDate = null; Date winnerCCDate = null;
      	Date nearestBCDate = null; Date nearestCCDate = null;
      	String nearestBCValue = null; String nearestCCValue = null;
      	
      	for(Account acc : accounts) {
      		if(acc.Id == winnerAccount.Id) {
      			winnerBCDate = acc.EDM_Business_Classification_Date_gne__c;
      			winnerCCDate = acc.EDM_Clinical_Classification_Date_gne__c;
      		} else {
      			if(acc.EDM_Business_Classification_Date_gne__c!=null && (nearestBCDate==null || acc.EDM_Business_Classification_Date_gne__c > nearestBCDate)) {
	    			nearestBCDate = acc.EDM_Business_Classification_Date_gne__c;
	    			nearestBCValue = acc.EDM_Business_Classification_gne__c;
	    		}
	    			
	    		if(acc.EDM_Clinical_Classification_Date_gne__c!=null && (nearestCCDate==null || acc.EDM_Clinical_Classification_Date_gne__c > nearestCCDate)) {
	    			nearestCCDate = acc.EDM_Clinical_Classification_Date_gne__c;
	    			nearestCCValue = acc.EDM_Clinical_Classification_gne__c;
	    		}
      		}
      	}
      		
      	if(nearestBCDate!=null && (winnerBCDate==null || nearestBCDate > winnerBCDate)) {
      		winnerAccount.EDM_Business_Classification_Date_gne__c = nearestBCDate;
      		winnerAccount.EDM_Business_Classification_gne__c = nearestBCValue;
      		bWinnerObjectUpdated = true;
      	}
      	
      	if(nearestCCDate!=null && (winnerCCDate==null || nearestCCDate > winnerCCDate)) {
      		winnerAccount.EDM_Clinical_Classification_Date_gne__c = nearestCCDate;
      		winnerAccount.EDM_Clinical_Classification_gne__c = nearestCCValue;
      		bWinnerObjectUpdated = true;
      	}
      		
      	return bWinnerObjectUpdated;
      }
      
	private Boolean updateExclusions(SObject winnerObject, SObject[] objectList){
      	Boolean bWinnerObjectUpdated = false;
      	Account winnerAccount = (Account)winnerObject;
      	
      	List<Account> accounts = [
      		SELECT
      			Id,
      			AGS_EX_Exclusion_Status_base_gne__c,
      			AGS_EX_Date_Checked_Exclusion_gne__c
      		FROM Account
      		WHERE Id in :objectList
      	];
      		
      	Date winnerExDate = null;
      	Date nearestExDate = null;
      	String nearestExValue = null;
      	
      	for(Account acc : accounts) {
      		if(acc.Id == winnerAccount.Id) {
      			winnerExDate = acc.AGS_EX_Date_Checked_Exclusion_gne__c;
      		} else {
      			if(acc.AGS_EX_Date_Checked_Exclusion_gne__c!=null && (nearestExDate==null || acc.AGS_EX_Date_Checked_Exclusion_gne__c > nearestExDate)) {
	    			nearestExDate = acc.AGS_EX_Date_Checked_Exclusion_gne__c;
	    			nearestExValue = acc.AGS_EX_Exclusion_Status_base_gne__c;
	    		}
      		}
      	}
      		
      	if(nearestExDate!=null && (winnerExDate==null || nearestExDate > winnerExDate)) {
      		winnerAccount.AGS_EX_Date_Checked_Exclusion_gne__c = nearestExDate;
      		winnerAccount.AGS_EX_Exclusion_Status_base_gne__c = nearestExValue;
      		bWinnerObjectUpdated = true;
      	}
      		
      	return bWinnerObjectUpdated;
      }
      
      private void updateAddressPrimaryFlag(String objectName, SObject winnerObject) {
      	  updateAddressPrimaryFlag(objectName.equalsIgnoreCase('Address_vod__c') ? (Id)winnerObject.get('Account_vod__c') : winnerObject.Id);
      }
      
      private void updateAddressPrimaryFlag(Id accId) {
          List<Address_vod__c> addrs = [
          	SELECT
          		Id,
          		Primary_vod__c,
          		Inactive_vod__c,
          		Account_vod__r.Main_Address_gne__c, 
          		(SELECT Call_Datetime_vod__c FROM Call2_vod__r ORDER BY Call_Datetime_vod__c DESC NULLS LAST LIMIT 1)
          	FROM Address_vod__c
          	WHERE Account_vod__c = :accId
          	ORDER BY Inactive_vod__c ASC, LastModifiedDate ASC
          ];
          
          List<Id> primaryAddrIds = new List<Id>();
          Boolean activeAddressExists = false;
          DateTime lastCallDateTime = null;
          Id addrIdWithLatestCall = null;
          
          for(Address_vod__c addr : addrs) {
          	if(addr.Primary_vod__c == true) {
          		primaryAddrIds.add(addr.Id);
          	}
          	
          	if(!activeAddressExists && !addr.Inactive_vod__c) {
          		activeAddressExists = true;
          	}
          	
          	if((!activeAddressExists || !addr.Inactive_vod__c) && !addr.Call2_vod__r.isEmpty() && (lastCallDateTime==null || addr.Call2_vod__r[0].Call_Datetime_vod__c>lastCallDateTime)) {
          		addrIdWithLatestCall = addr.Id;
          		lastCallDateTime = addr.Call2_vod__r[0].Call_Datetime_vod__c;
          	}
          }
          
          List<Address_vod__c> addrsToUpdate = new List<Address_vod__c>();
          Id primaryAddrId = null;
          
          if(primaryAddrIds.isEmpty() && !addrs.isEmpty()) {
          	primaryAddrId = addrIdWithLatestCall!=null ? addrIdWithLatestCall : addrs[0].Id;
          	addrsToUpdate.add(new Address_vod__c(Id = primaryAddrId, Primary_vod__c = true));
          } else if(!primaryAddrIds.isEmpty()) {
          	primaryAddrId= primaryAddrIds.remove(0);
          	
          	for(Id addrId : primaryAddrIds) {
          		addrsToUpdate.add(new Address_vod__c(Id = addrId, Primary_vod__c = false));
          	}
          }
          
          if(!addrsToUpdate.isEmpty()) {
          	update addrsToUpdate;
          }
          
          if(primaryAddrId!=null) {
          	Address_vod__c primaryAddr = new Map<Id,Address_vod__c>(addrs).get(primaryAddrId);
          	if(primaryAddr.Account_vod__r.Main_Address_gne__c != primaryAddr.Id) {
          		update new Account(Id = accId, Main_Address_gne__c =  primaryAddr.Id);
          	}
          }
      }
      
      private void setTSFAddress(SObject winnerObject) {
      	  List<TSF_vod__c> tsfs;
      	  
      	  if(objectName.equalsIgnoreCase('Address_vod__c')) {
      	  	Id accId = (Id)winnerObject.get('Account_vod__c');
      	  	// get all TSFs from loser addresses (reference to address won't be set)
      	  	tsfs = [SELECT Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Account_vod__c = :accId AND Address_vod__r.Id = null];
      	  } else { // objectName == TSF_vod__c
      	  	tsfs = [SELECT External_Id_vod__c, Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Id = :winnerObject.Id];
      	  	GNE_SFA2_TSF_Field_Updates.updateExternalIdField(tsfs);
      	  }
      	  
      	  if(!tsfs.isEmpty()) {
      	  	GNE_SFA2_TSF_Field_Updates.updateAddressField(tsfs, false);
          	Database.update(tsfs);
      	  }
      }
      
      public void updateExternalId(List<SObject> recs) {
          List<SObject> recsToUpdate;
          SObject firstRec = recs.isEmpty() ? null : recs[0];
          
          if(firstRec!=null && firstRec instanceof TSF_vod__c) {
              List<TSF_vod__c> tsfs = [SELECT External_Id_vod__c, Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Id IN :recs];
              recsToUpdate = GNE_SFA2_TSF_Field_Updates.updateExternalIdField(tsfs);
          } else if(firstRec!=null && firstRec instanceof Targets_and_Tiers_can_gne__c) {
              List<Targets_and_Tiers_can_gne__c> tats = [SELECT External_Id_gne__c, Unique_Key_Calc_gne__c FROM Targets_and_Tiers_can_gne__c WHERE Id IN :recs];
              recsToUpdate = GNE_SFA2_TargetsTiers_Field_Update.updateExternalId(tats);
          } else if(firstRec!=null && firstRec instanceof Affiliation_vod__c) {
              List<Affiliation_vod__c> affs = [SELECT External_Id_vod__c, From_Account_vod__c, From_Contact_vod__c, To_Account_vod__c, To_Contact_vod__c, Role_vod__c FROM Affiliation_vod__c WHERE Id IN :recs];
              recsToUpdate = GNE_SFA2_Affiliation_Field_Updates.updateExternalId(affs);
          } else if(firstRec!=null && firstRec instanceof Product_Metrics_vod__c) {
              List<Product_Metrics_vod__c> bAffs = [SELECT Unique_Key_gne__c, Unique_Key_Calc_gne__c FROM Product_Metrics_vod__c WHERE Id IN :recs];
              recsToUpdate = GNE_SFA2_Brand_Affil_Field_Updates.updateUniqueKey(bAffs);
          } else if(firstRec!=null && firstRec instanceof User_Preference_gne__c) {
              List<User_Preference_gne__c> uPrefs = [SELECT External_Id_gne__c, Unique_Key_Calc_gne__c FROM User_Preference_gne__c WHERE Id IN :recs];
              recsToUpdate = GNE_SFA2_ExternalIdUpdater.setExternalId(uPrefs, String.valueOf(User_Preference_gne__c.External_Id_gne__c), String.valueOf(User_Preference_gne__c.Unique_Key_Calc_gne__c));
          }
          
          if(recsToUpdate!=null && !recsToUpdate.isEmpty()) {
              Boolean prevValue = switchAdminMode(true);
              try {
                Database.update(recsToUpdate, false);
              } finally {
                switchAdminMode(prevValue);
              }
          }
      }
      
      private Boolean switchAdminMode(Boolean newVal) {
          Boolean result = false;
          GNE_SFA2_Admin_Mode__c adminModeSetting = GNE_SFA2_Admin_Mode__c.getInstance();
          
          if (adminModeSetting == null) {
              adminModeSetting = new GNE_SFA2_Admin_Mode__c(SetupOwnerId = UserInfo.getUserId());
          } else {
              result = adminModeSetting.GNE_SFA2_Is_Admin_Mode__c;
          }
          
          if(result!=newVal) {
              adminModeSetting.GNE_SFA2_Is_Admin_Mode__c = newVal;
              upsert adminModeSetting;
          }
          
          return result;
      }
}