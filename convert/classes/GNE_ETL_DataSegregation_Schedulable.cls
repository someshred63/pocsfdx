global class GNE_ETL_DataSegregation_Schedulable implements Schedulable {    
    
    String isoCountryCode = 'USA';
    
    public GNE_ETL_DataSegregation_Schedulable (String countryCode) {
    	isoCountryCode = countryCode;
    }
    
    global void execute(SchedulableContext sc) {        
        try {           			        	
        	if ( isoCountryCode.equalsIgnoreCase('USA') ) {
				GNE_ETL_USA_DataSegregationJob dsCheckUSA = new GNE_ETL_USA_DataSegregationJob();
				Database.executeBatch ( dsCheckUSA, 1 );
        	} else {
	            GNE_ETL_CAN_DataSegregationJob dsCheckCAN = new GNE_ETL_CAN_DataSegregationJob();
	            Database.executeBatch ( dsCheckCAN, 1 );
        	}
            
        } catch ( Exception e ) {
            GNE_ETL_EventTaskReplicator_Utility.writeErrorLog('Data Segregation Schedulable' ,'execute', e);            
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + e.getMessage() );
        }
    }   
}