public class GNE_ObjectMerge_Controller {

      List<String> deferOnConflictFields               = new List<String>();
      List<String> deferOnConflictConsiderNullFields   = new List<String>();
      List<String> deferProfessionalTypeFields     = new List<String>();
      List<String> deferOnLoserRelatedListCount    = new List<String>();
      List<String> notNullFields                   = new List<String>();
      List<String> booleanORFields                 = new List<String>();
      List<String> preferLowValueFields            = new List<String>();
      List<String> preferHighValueFields           = new List<String>();
      Map<String, List<String>> peckingOrderFields = new Map<String,List<String>>();                        
      Map<String,SObjectField> relationshipMap     = new Map<String,SObjectField>();
      Map<String,SObjectField> excludedRelationshipMap	= new Map<String,SObjectField>();

      Map<String,String> fieldToExceptionCode      = new Map<String,String>();
      Map<String,Boolean> fieldToAddExceptionDesc  = new Map<String,Boolean>();

      String sort_by_columns = null;
      String mdm_id_field_name = null;
      String objectName = null;
      String objectType = null;
      String objectSQL = null;  
      
      boolean bCheckMode = false;        
    
      GNE_Merge_DuplicateSet duplicateSet = null;      
      static final String DEFAULT_BUSINESS_RULE_EXCEPTION_CODE = 'EXCEPTION CODE NOT DEFINED';
      
      
    void initialize() {    	               
        GNE_Merge_BusinessRules_gne__c[] gneMergeList = 
                        [select field_type_gne__c, field_name_gne__c,
                                relatedlist_query_text_gne__c,
                                exception_code_gne__c, log_exception_column_values_gne__c   
                         from gne_merge_businessrules_gne__c  
                         where     object_name_gne__c      = :objectName 
                               and active_gne__c           = true
                               and field_applies_to_gne__c includes( :objectType )
                         order by field_type_gne__c, field_name_gne__c desc];
    
        objectSQL = 'select id ';
        
        for (GNE_Merge_BusinessRules_gne__c gneMerge : gneMergeList) {            

            if ( gneMerge.field_type_gne__c.equalsIgnoreCase('DeferOnConflict') ) {
                objectSQL += ',' + gneMerge.field_name_gne__c ;
                deferOnConflictFields.add(gneMerge.field_name_gne__c);
            } else if ( gneMerge.field_type_gne__c.equalsIgnoreCase('DeferOnConflictConsiderNullAsUnique') ) {
                objectSQL += ',' + gneMerge.field_name_gne__c ;
                deferOnConflictConsiderNullFields.add(gneMerge.field_name_gne__c);
            } else if ( gneMerge.field_type_gne__c.equalsIgnoreCase('Not Null') ) {
                objectSQL += ',' + gneMerge.field_name_gne__c ;
                notNullFields.add(gneMerge.field_name_gne__c);
            } else if ( gneMerge.field_type_gne__c.equalsIgnoreCase('PreferLowValue') ) {
                objectSQL += ',' + gneMerge.field_name_gne__c ;
                preferLowValueFields.add(gneMerge.field_name_gne__c);
            } else if ( gneMerge.field_type_gne__c.equalsIgnoreCase('PreferHighValue') ) {
                objectSQL += ',' + gneMerge.field_name_gne__c ;
                preferHighValueFields.add(gneMerge.field_name_gne__c);
            } else if ( gneMerge.field_type_gne__c.equalsIgnoreCase('Boolean OR') ) {
                objectSQL += ',' + gneMerge.field_name_gne__c ;
                booleanORFields.add(gneMerge.field_name_gne__c);
            } else if ( gneMerge.field_type_gne__c.startsWith('Pecking') ) {
                objectSQL += ',' + gneMerge.field_name_gne__c ;
                List<String> fieldList = peckingOrderFields.get(gneMerge.field_type_gne__c.toUpperCase());
                if ( fieldList == null ){                    
                    fieldList = new List<String>();
                    peckingOrderFields.put(gneMerge.field_type_gne__c.toUpperCase(), fieldList);
                }
                fieldList.add(gneMerge.field_name_gne__c);
            } else if ( gneMerge.field_type_gne__c.startsWith('Sort By Columns') ) {
            	sort_by_columns = gneMerge.field_name_gne__c;
            } else if ( gneMerge.field_type_gne__c.equalsIgnoreCase('MDM Id Field Name') ) {
                mdm_id_field_name = gneMerge.field_name_gne__c;
            } else if ( gneMerge.field_type_gne__c.equalsIgnoreCase('Relationship To Move') ) {
                relationshipMap.put(gneMerge.field_name_gne__c.toUpperCase(), null);
            } else if ( gneMerge.field_type_gne__c.equalsIgnoreCase('Relationship To Exclude') ) {
                excludedRelationshipMap.put(gneMerge.field_name_gne__c.toUpperCase(), null);
            } else if ( gneMerge.field_type_gne__c.equalsIgnoreCase('DeferOnLoserSignificantRelatedListCount') ) {           
                deferOnLoserRelatedListCount.add (gneMerge.field_name_gne__c);
                objectSQL += ',' + '('+ gneMerge.relatedlist_query_text_gne__c + ')'  ;
            }            
            
            if (gneMerge.exception_code_gne__c != null ) {
                fieldToExceptionCode.put ( gneMerge.field_name_gne__c,
                                           gneMerge.exception_code_gne__c); 
            }                        

            Boolean bAddExceptionCodeDesc = gneMerge.log_exception_column_values_gne__c;
            fieldToAddExceptionDesc.put ( gneMerge.field_name_gne__c, 
                                           bAddExceptionCodeDesc);
                                           
            
        }   
        
        // add one more scan for professional type 
        for (GNE_Merge_BusinessRules_gne__c gneMerge : gneMergeList) {            
            if ( gneMerge.field_type_gne__c.equalsIgnoreCase('DeferWhenProfessionalTypeIsNotPrescriber') ) {
                deferProfessionalTypeFields.add (gneMerge.field_name_gne__c);
                objectSQL += ',' + '('+ gneMerge.relatedlist_query_text_gne__c + ')'  ;
                if (objectSQL.indexOf(',professional_type_gne__c') == -1) 
                    objectSQL += ',professional_type_gne__c' ;            
            }                            
        }                   
        objectSQL += ' from ' + objectName ; 

        // get relationship field name in child object 
        if ( !relationshipMap.isEmpty() || !excludedRelationshipMap.isEmpty()) {            
            Map<String,SObjectField> tempMap= new Map<String,SObjectField>{};
            Schema.DescribeSObjectResult objectChildren = getDescribe(objectName);
            List<Schema.ChildRelationship> childRelationship = objectChildren.getChildRelationships();
            for (Schema.ChildRelationship child : childRelationship ) {
            	// Workaround for Salesforce Case #10482798 - Some Schema Child Relationship Names are not set
            	if(String.isNotBlank(child.getRelationshipName())) {
                	tempMap.put(child.getRelationshipName().toUpperCase(), child.getField());
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
    
    private Schema.DescribeSObjectResult getDescribe(String objectName) {        
        Schema.DescribeSObjectResult objectChildren = null;        
        if ( objectName.equalsIgnoreCase('Account'))
            objectChildren = Account.SObjectType.getDescribe();
        else if (objectName.equalsIgnoreCase('Address_vod__c'))
            objectChildren = Address_vod__c.SObjectType.getDescribe();
        else if (objectName.equalsIgnoreCase('Product_Metrics_vod__c'))
            objectChildren = Product_Metrics_vod__c.SObjectType.getDescribe();
        else if (objectName.equalsIgnoreCase('Affiliation_vod__c'))
            objectChildren = Affiliation_vod__c.SObjectType.getDescribe();
        else if ( objectName.equalsIgnoreCase('TSF_vod__c') ) 
            objectChildren = TSF_vod__c.SObjectType.getDescribe();
            
        return objectChildren;        	
    }    	

    public String getObjectChildRelationsipSQL () {
    	return getObjectChildRelationsipSQL(relationshipMap);
    }
    
    public String getObjectChildRelationsipSQL (Map<String,SObjectField> childRelationshipsMap) {
        String sql = 'select id ';
        for (String relationshipName : childRelationshipsMap.keySet() ) {
            sql += ', ( select id, ' + childRelationshipsMap.get(relationshipName) + 
                                   ' from ' + relationshipName  + ') ' ;             
        }
        sql += ' from ' + objectName;
        return sql;
    }
    
    public GNE_ObjectMerge_Controller (String objectName, String objectType, boolean MergeRunMode) {
    	this.objectName = objectName;
    	this.objectType = objectType;
    	bCheckMode = MergeRunMode;
        initialize();
    }

    private GNE_ObjectMerge_Controller () {
    }
            
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
              if ( currentValue == null  && newValue != null   ) {
                  winnerObject.put (fieldName, newValue);
                  bwinnerObjectUpdated = true;
              }                  
          }
          return bwinnerObjectUpdated;
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
          for ( String fieldKey : peckingOrderFields.keySet() ) {              
              for ( String fieldName : peckingOrderFields.get(fieldKey) ) {                  
                  Object newValue = loserObject.get (fieldName); 
                  if ( newValue != null ) {   
                      Boolean bCanCopy = true;                
                      for ( String winnerFieldName : peckingOrderFields.get(fieldKey) ) {
                          Object winnerFieldValue = winnerObject.get(winnerFieldName);
                          if ( winnerFieldValue == newValue  ) {
                              bCanCopy = false; 
                              break;
                          }
                      } // check to see if this value can be copied over.
                      if ( bCanCopy ) {               
                          for ( String winnerFieldName : peckingOrderFields.get(fieldKey) ) {
                              Object winnerFieldValue = winnerObject.get(winnerFieldName);
                              if ( winnerFieldValue == null ) {
                                  winnerObject.put(winnerFieldName, newValue);
                                  bWinnerObjectUpdated = true;
                                  break;
                              }
                          } // first empty field value - winner object  
                      }
                  } // non-empty field value - loser object 
              } // for each field within a pecking order group
          } // for each pecking order group                     
          return bWinnerObjectUpdated;
      }

      void AnyDeferOnConflictFieldValues (SObject winnerObject, SObject loserObject) {  
          System.debug (LoggingLevel.INFO, 'AnyDeferOnConflictFieldValules invoked winnerObject/loserObject ->' + 
                         winnerObject.get('id') + '/' + loserObject.get('id') + '.' );    
          for ( String fieldName : deferOnConflictFields ) {
              Object currentValue = winnerObject.get ( fieldName );
              Object newValue     = loserObject.get ( fieldName );                            
              if ( currentValue != null && newValue != null && currentValue != newValue) {                  
                  String msg = fieldName +  ' value conflict - ' + 
                                currentValue + '/' + newValue    + '. ' +
                                'Winner / Loser Object Id -> '  + 
                                winnerObject.get('id')          + '/' + 
                                loserObject.get('id')           + '.';                  
                  System.debug (LoggingLevel.INFO, 'AnyDeferOnConflictFieldValues --> ' + msg );                                                                    
                  addException (fieldName, (String)loserObject.get('id'), msg);                                    
                  //throw new GNE_Merge_Exception(msg);                  
              }              
          }
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
                  //throw new GNE_Merge_Exception(msgPrefix + msg);
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

      void AnyDeferOnLoserRelatedListCount  (SObject winnerObject, SObject loserObject) {  
          System.debug (LoggingLevel.INFO, 'AnyDeferOnLoserRelatedListCount invoked winnerObject/loserObject ->' + 
                         winnerObject.get('id') + '/' + loserObject.get('id') + '.' );    
          for ( String fieldName : deferOnLoserRelatedListCount ) {
              SObject[] relatedList  = loserObject.getSObjects ( fieldName );
              
              if ( relatedList != null ) {
	              if ( relatedList.size() > 0 ) {              
	                  String msg = 'Account Id ' + loserObject.get('id') + 
	                               ' has related list record for child relationship: ' +
	                               fieldName + '.  Total related list count is '+ 
	                               relatedList.size()  ;                               
	                  System.debug (LoggingLevel.INFO, 'AnyDeferOnLoserRelatedListCount  --> ' + msg );                                
	                  addException (fieldName, (String)loserObject.get('id'), msg);
	                  //throw new GNE_Merge_Exception(msg);
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
		for ( Sobject loserObject : getChildRecords(loserObjectIdSet, excludedRelationshipMap) ) {              
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
    	SObject[] loserObjects = getChildRecords(loserObjectIdSet, relationshipMap);
    	//Boolean isAdminModePrevValue = switchAdminMode(true);
		
		try {
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
		} finally {
			//switchAdminMode(isAdminModePrevValue);
		}
		
		return loserObjects;
    }
    /*
    private Boolean switchAdminMode(Boolean isAdminMode) {
    	GNE_SFA2_Admin_Mode__c adminModeSetting = GNE_SFA2_Admin_Mode__c.getInstance(UserInfo.getUserId());
    	Boolean isAdminModePrevValue = adminModeSetting.GNE_SFA2_Is_Admin_Mode__c;
    	
    	if(adminModeSetting.Id==null || isAdminMode!=isAdminModePrevValue) {
    		adminModeSetting.GNE_SFA2_Is_Admin_Mode__c = isAdminMode;
    		upsert adminModeSetting;
    	}
    	
    	return isAdminModePrevValue;
    }
    */

    private SObject[] getChildRecords(Set<Id> loserObjectIdSet, Map<String,SObjectField> childRelationshipMap) {
		String sql = getObjectChildRelationsipSQL(childRelationshipMap) + 
				' where id in :loserObjectIdSet ';                       
		System.debug (LoggingLevel.INFO,  'child relationship dynamic sql prepared --> ' + sql );
		return Database.query ( sql );
	}
      
    private void addException (String fieldName, 
                               String loserId,
                               String errorDesc) {

	  String  exceptionCode     = fieldToExceptionCode.get ( fieldName );
	  Boolean bAddExceptionDesc = fieldToAddExceptionDesc.get(fieldName);
	  
	   
	  if ( exceptionCode == null ) 
	    exceptionCode = GNE_ObjectMerge_Controller.DEFAULT_BUSINESS_RULE_EXCEPTION_CODE;
	  
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
                                     

    public String getObjectSQL() {
        return objectSQL;   
    }  
            

      boolean anyExceptionsCaptured (SObject[] objectList, 
                                    GNE_Merge_DuplicateSet duplicateSet) {
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
            
      public String doMerge(Set<String> objectIdSet, String winnerAccountId,
                            GNE_Merge_DuplicateSet duplicateSet) {
                                      	
          String returnMsg = null;
          this.duplicateSet = duplicateSet;
                    
          SObject winnerObject   = null;                  
          SObject[] objectList = orderObjectMergeList ( objectIdSet, winnerAccountId );                     
          if ( objectList == null || objectList.size() == 0 )
              return null; 
          
          //select the winner what is passed in  
			for (SObject tempObject : objectList ) {
				String recordId = (String ) tempObject.get('id');
				if ( recordId.equals(winnerAccountId) ) {
					winnerObject = tempObject;
					break;             	
				 } 
		    }
          
          for ( Integer i = 0; i < objectList.size(); i++ ) {
              
              SObject loserObject = objectList[i];              
              if ( loserObject.get('id') == winnerObject.get('id') ) 
                  continue;
              
              System.debug (LoggingLevel.INFO, 'add loser object Id  -> ' + 
                            loserObject.get('id') );
              
              // replaced with AnyDeferOnConflictFieldValuesAcrossLoserObjects
              // to look at all accounts at once.                             
              //AnyDeferOnConflictFieldValues(winnerObject, loserObject);
              AnydeferOnConflictConsiderNullFieldValues(winnerObject,loserObject);
          }   
          AnyDeferOnConflictFieldValuesAcrossLoserObjects(winnerObject,objectList);
          MoreThanOneAccountHavingRelatedListCount(winnerObject, objectList);      
          deferWhenProfessionalTypeIsNotPrescriber(winnerObject, objectList);
          
          if ( bCheckMode ) 
            return (String )winnerObject.get('id');           

          // 04/13/2010 captured via sqa test cycle
          if ( anyExceptionsCaptured(objectList, duplicateSet) ) 
            return null; // skip merge process.
                    	
          Boolean bWinnerObjectUpdated = false;    
          Set<Id> loserObjectIdSet = new Set<Id>();
          for ( Integer i = 0; i < objectList.size(); i++ ) {              

              SObject loserObject = objectList[i];
              if ( loserObject.get('id') == winnerObject.get('id') ) 
                  continue;
                  
              loserObjectIdSet.add ( (Id)loserObject.get('id') );
              bWinnerObjectUpdated = copyNotNullFieldValues (winnerObject,loserObject);  
              bWinnerObjectUpdated = copyPeckingOrderFieldValues (winnerObject,loserObject) || bWinnerObjectUpdated;            
              bWinnerObjectUpdated = copyBooleanORFieldValues (winnerObject,loserObject) || bWinnerObjectUpdated;
              bWinnerObjectUpdated = copyPreferLowFieldValues (winnerObject,loserObject) || bWinnerObjectUpdated;
              bWinnerObjectUpdated = copyPreferHighFieldValues (winnerObject,loserObject) || bWinnerObjectUpdated;
          }          
          
          if ( bWinnerObjectUpdated ){
              update winnerObject;    
              System.debug (LoggingLevel.INFO, 'Winner Object updated..');
          }                            


          // move losing address child record/relationship to winner address
          if ( loserObjectIdSet.size() > 0 ) {
          	  
          	  excludeChildRelationships(loserObjectIdSet);
          	  
	          try {                             	
	          	  if ( objectName.equalsIgnoreCase('Account') ) {
	          	  	String accountId = (String)winnerObject.get('id');	          	  	
	          	  	Account acct = [select id from account where id = :accountId];
	          	  	
	          	  	// update parent interaction in case of merged looser account is bind
	          	  	// to child interaction (to update parent interaction lastmodifieddate)
	          	  	List<Call2_vod__c> childCallsRelatedToLooserAccount = [Select Id, Account_vod__c, Parent_Call_vod__c from Call2_vod__c where Account_vod__c in :loserObjectIdSet and Parent_Call_vod__c != null];
	          	  	
	          	  	Set<String> parentCallsIdsToUpdate = new Set<String>();
	          	  	
					for (Call2_vod__c call : childCallsRelatedToLooserAccount) {
	          	  		parentCallsIdsToUpdate.add(call.Parent_Call_vod__c);
	          	  	}
	          	  	
	          	  	if (parentCallsIdsToUpdate.size() > 0) {
	          	  		List<Call2_vod__c> callsToUpdate = [Select Id from Call2_vod__c where Id in :parentCallsIdsToUpdate];
	          	  	
		          	  	if (callsToUpdate != null && callsToUpdate.size() > 0){	          	  	
		          	  		update callsToUpdate;
		          	  	}
	          	  	}
	          	  	
	          	  	
	          	  	
	          	  	for (Id id : loserObjectIdSet) { 
	          	  		System.debug (LoggingLevel.INFO, 'calling merge for Id ' + id );
	          	  	    merge acct id;
	          	  	}
	          	  } else {   
		              // custom object merge functionality 
		              SObject[] objects = moveChildRelationships(winnerObject, loserObjectIdSet);
		              delete objects;
	          	  }
	          } catch (Exception e) {
	              System.debug (LoggingLevel.INFO,  'Error moving losing ' + objectName + ' child records -> '+ e.getMessage() );
	              throw e; 
	          }
          } else {
              String msg = 'No losing ' + objectName + ' record present in this group.';
              throw new GNE_Merge_Exception(msg);
          }          
          // return winner
          return (String )winnerObject.get('id');   
      }
}