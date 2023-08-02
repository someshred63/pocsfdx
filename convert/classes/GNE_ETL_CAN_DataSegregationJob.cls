global with sharing class GNE_ETL_CAN_DataSegregationJob extends GNE_ETL_DataSegregationVerificationJob 
    implements Database.Batchable<SObject>, Database.Stateful {

    public GNE_ETL_CAN_DataSegregationJob () {
        countryISOCode = 'CAN' ;
        init(); 
    }    
        
    global Database.QueryLocator start(Database.batchableContext bc) {
        return getQueryLocator();
    }

    global void execute(Database.BatchableContext BC, List<SObject> sObjectList){
        doExecute(BC, sObjectList);        
    }
            
    global void finish(Database.BatchableContext BC){
        doFinish(BC);
    }    
}