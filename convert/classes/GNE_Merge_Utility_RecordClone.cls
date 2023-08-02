public with sharing class GNE_Merge_Utility_RecordClone {

    static final String RECORD_UNAVAILABLE  = 'Some Parent Records Not Present/Unavailable.';
    
    public static void  cloneRecordList (Set<String>  parentRecordIdSet, 
                                         Set<String>  clonedRecordIdSet,
                                         Set<String> fieldNameSet, 
                                         String objectName,
                                         Boolean IsPersonAccount) {
                
        String sql = 'select ';
        for (String fieldName: fieldNameSet) {            
            sql = sql + fieldName + ',' ;   
        }
        sql = sql + ' RecordType.Name ' ;
        sql = sql + ' from ' + objectName;
        
        System.debug ( LoggingLevel.INFO, sql );
        SObject[] parentRecordList = Database.query(sql + ' where id in :parentRecordIdSet ');
        Sobject[] clonedRecordList = Database.query(sql + ' where id in :clonedRecordIdSet ');
        
        if ( parentRecordList.size() != parentRecordIdSet.size()  )
            throw new GNE_Merge_Exception(GNE_Merge_Utility_RecordClone.RECORD_UNAVAILABLE);
        
        for ( String cloneRecordId : clonedRecordIdSet ) {
            
            SObject clonedRecord  = null;
            SObject parentRecord = null;
            String  previousId   = null;
            
            for (SObject recordObject : clonedRecordList) {
            	String recordId = (String ) recordObject.get('id');
                if ( recordId == cloneRecordId ) {
                    clonedRecord = recordObject;
                    previousId   = (String ) recordObject.get('dch_previous_id_gne__c');
                    break;	
                }
            }
            
            if ( previousId != null ) {
	            for (SObject recordObject : parentRecordList) {
	                String recordId = (String ) recordObject.get('id');
	                if ( recordId == previousId ) {
	                    parentRecord = recordObject;
	                    break;  
	                }
	            }
            }
            
            if ( parentRecord == null ) {
	            throw new GNE_Merge_Exception(GNE_Merge_Utility_RecordClone.RECORD_UNAVAILABLE);
            }            
            	
	        for (String fieldName : fieldNameSet) {
	                                    
	            String fieldNameUpperCase = fieldName.toUpperCase();
	            
	            if ( fieldNameUpperCase.startsWith('DCH') || 
	                 fieldNameUpperCase.equals('RECORDTYPEID') ||
	                 fieldNameUpperCase.equals('AMS_ID_GNE__C') ||
	                 fieldNameUpperCase.equals('MDMID_GNE__C') ||
	                 fieldNameUpperCase.equals('MDM_UPDATE_DATE_GNE__C') ||
	                 fieldNameUpperCase.equals('STEWARDSHIP_SYSTEM_NAME_GNE__C') || 
	                 fieldNameUpperCase.equals('MDM_PLAN_PRODUCT_ID_GNE__C') ||
	                 fieldNameUpperCase.equals('MDM_ADDRESS_ID_GNE__C') ||
                     fieldNameUpperCase.equals('MDMID_STATUS_GNE__C') ||	                 
                     fieldNameUpperCase.equals('STATUS_GNE__C') ||                     
	                 fieldNameUpperCase.equals('SCORECARD_ACCOUNT_ID_GNE__C') ||
	                 fieldNameUpperCase.equals('SAP_ID_GNE__C') 
	            )
	                continue;
	            
	            if ( objectName.toUpperCase().equals('ACCOUNT') && 
	                 ( (fieldNameUpperCase.equals('NAME') && IsPersonAccount == TRUE ) ||
	                   (fieldNameUpperCase.equals('FIRSTNAME') && IsPersonAccount == FALSE ) ||
	                   (fieldNameUpperCase.equals('LASTNAME') && IsPersonAccount == FALSE ) 
	                 )
	               ) 
	               continue;
	                            
	            Object currentValue = parentRecord.get(fieldName);
	            if ( currentValue != null ) 
	                clonedRecord.put(fieldName, currentValue);
                else if ( clonedRecord.get(fieldName) != null ) 
                    clonedRecord.put ( fieldName, null );	                                       
	            
	        }
		        
	        if ( fieldNameSet.contains('MDMID_GNE__C') )
	            if ( parentRecord.get('MDMID_GNE__C') != null )
	                clonedRecord.put('DCH_PREVIOUS_MDMID_GNE__C', 
	                                    parentRecord.get('MDMID_GNE__C') );
	                
	        if ( fieldNameSet.contains('MDM_PLAN_PRODUCT_ID_GNE__C') )
	            if ( parentRecord.get('MDM_PLAN_PRODUCT_ID_GNE__C') != null )
	                clonedRecord.put('DCH_PREVIOUS_MDM_PLAN_PRODUCT_ID_GNE__C', 
	                                   parentRecord.get('MDM_PLAN_PRODUCT_ID_GNE__C') );
	
	        if ( fieldNameSet.contains('MDM_ADDRESS_ID_GNE__C') )
	            if ( parentRecord.get('MDM_ADDRESS_ID_GNE__C') != null )
	                clonedRecord.put('DCH_PREVIOUS_MDM_ADDRESS_ID_GNE__C', 
	                                    parentRecord.get('MDM_ADDRESS_ID_GNE__C') );
	
	        if ( fieldNameSet.contains('RECORDTYPEID') && 
	             fieldNameSet.contains('DCH_PREVIOUS_RECORDTYPE_ID_GNE__C') )
	            if ( parentRecord.get('RECORDTYPEID') != null )
	                clonedRecord.put('DCH_PREVIOUS_RECORDTYPE_ID_GNE__C', 
	                                    parentRecord.get('RECORDTYPEID') );
	        
	        Sobject recordTypeObject = parentRecord.getSObject('RecordType');
	        if ( recordTypeObject != null ) {
	            String recordTypeName = (String ) recordTypeObject.get('Name');
	            if ( recordTypeName != null ) { 
	                clonedRecord.put('DCH_PREVIOUS_RECORDTYPE_GNE__C', recordTypeName); 
	            }
	        }
	        clonedRecord.put ('DCH_Clone_gne__c', True);
        }
        
        if ( clonedRecordList.size() > 0 )             
            update clonedRecordList;
    }
}