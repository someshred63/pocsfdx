public class GNE_Subscribe_Utility {

    public static boolean populateLookupRefColumnByLookupTable (SObject[] recordList,
                                                                String lookupTable, 
                                                                String lookupIdColumn,
                                                                String lookupIdRefColumn) {        
        Boolean bOk = true;        
        try {                       
            Set<String> cadsIdSet = new Set<String>();
            for (SObject record : recordList ) {
                String value = (String) record.get(lookupIdColumn);
                if ( value != null ) 
                  cadsIdSet.add ( value );     
            }
            
            if ( cadsIdSet.size() > 0 ) {
                Map<String,String> cadsId2SfdcIdMap = 
                        GNE_Subscribe_Utility.getCADSId2SFDCIdMap ( cadsIdSet, lookupTable);

                for (SObject record : recordList ) {
                    String sfdcId = cadsId2SfdcIdMap.get( (String) record.get(lookupIdColumn) );
                    record.put(lookupIdRefColumn, sfdcId);                        
               }
            }                      
        } catch (Exception excep) {                                
            System.debug (LoggingLevel.INFO, excep);
            bOk = false;    
        }
        
        return bOk;
    }

    public static boolean populateLookupRefColumn (SObject[] recordList) {        
        Boolean bOk = true;        
        try {	    	        	
		    Map<String, Schema.SObjectField> mapField = 
		            recordList[0].getSObjectType().getDescribe().fields.getMap();

		    for ( String fieldName : mapField.keySet() ) {
		
		        if ( fieldName.endsWith ('_id_ref_gne__c') ) {
		        
		            Integer nIndex        = fieldName.indexOf('_id_ref_gne__c');            
		            String columnPrefix   = fieldName.substring(0, nIndex);                              
		            String lookupTable    = 'stg_' + columnPrefix + '_gne__c';
		            String columnName     = columnPrefix + '_id_gne__c';
		            
		            
		            System.debug (LoggingLevel.INFO, 'lookup column / lookup Table ' + 
		                          columnName + '/' + lookupTable );
		
		            Set<String> cadsIdSet = new Set<String>();
		            for (SObject record : recordList ) {
		            	String value = (String) record.get(columnName);
		            	if ( value != null ) 
		                  cadsIdSet.add ( value );     
		            }
		            
                    if ( cadsIdSet.size() > 0 ) {
			            Map<String,String> cadsId2SfdcIdMap = 
			                    GNE_Subscribe_Utility.getCADSId2SFDCIdMap ( cadsIdSet, lookupTable);
		
			            for (SObject record : recordList ) {
			                String sfdcId = cadsId2SfdcIdMap.get( (String) record.get(columnName) );
		                    record.put(fieldName, sfdcId);                        
			           }
                    }			           
                }
		    } 
        } catch (Exception excep) {		    		        	   
            System.debug (LoggingLevel.INFO, excep);
            bOk = false;	
        }
        
        return bOk;
    }
    


     public static Map<String, String> getCADSId2SFDCIdMap (Set<String> cadsIdSet, String lookupTable) {

        Map<String, String> cadsId2SfdcIdMap = new Map<String,String>();

        try {            
			String sql = 'select id, external_id_gne__c ' + 
			             'from ' + lookupTable + 
			             ' where external_id_gne__c in :cadsIdSet ' ; 
	
	
	        System.debug (LoggingLevel.INFO, sql );
	        
			SObject[] objectList = Database.query(sql);
	          
			for ( SObject record : objectList ) {
			    cadsId2SfdcIdMap.put ( (String) record.get('external_id_gne__c'), 
			                           (String) record.get('id') );
			}        
			System.debug(loggingLevel.INFO, cadsIdSet.size() + '/' + cadsId2SfdcIdMap.size() );
        } catch (Exception excep) {
            System.debug (LoggingLevel.INFO, excep);            	       
        }
        return cadsId2SfdcIdMap;        
    }

}