public without sharing class iPhoneApex_SampleTransactionLogUtility {

     static final String UNABLE_TO_LOG_ERROR  = 'Unable to log error';
 
     public static void  writeErrorLog (String objectName,
                                       String methodName, 
                                       Exception exceptionRecord) {               
        try {
               Error_log_gne__c errorLog     = new Error_log_gne__c(
                   error_level_gne__c   = 'High',
                   object_name__c       = objectName,
                   code_type__c         = 'iPhoneApex',
                   snippet_name__c      = methodName,
                   error_description__c =  exceptionRecord.getMessage()  + ':' +  
                                           exceptionRecord.getCause() + ':' +
                                           exceptionRecord.getStackTraceString() );            
               insert errorLog;         
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 
                          UNABLE_TO_LOG_ERROR + ' ( ' + 
                          exceptionRecord.getMessage() + '). ' + 
                          'writeErrorLog exception --> ' + e.getStackTraceString() );    
        }
    }
    
    public static Integer
            getSampleTransactionInfo (List<String> callIdList,
                                  List<Sample_Transaction_vod__c> sampleTransacionVodList,
                                  List<Missing_Sample_Transaction_Log_gne__c> missingSampleTransactionLogList) {                        
        
        List<Call2_Sample_vod__c> csList = 
           [select Id, Is_Parent_Call_vod__c, 
                   Call_Date_vod__c, Account_vod__c, 
                   Quantity_vod__c, Lot_vod__c,  Call2_vod__c,
                   call2_vod__r.call_datetime_vod__c, 
                   call2_vod__r.call_date_vod__c,
                   call2_vod__r.signature_vod__c,
                   call2_vod__r.signature_date_vod__c,
                   call2_vod__r.disclaimer_vod__c, 
                   call2_vod__r.license_vod__c,
                   call2_vod__r.account_vod__c,
                   call2_vod__r.ship_address_line_1_vod__c,
                   call2_vod__r.ship_address_line_2_vod__c,
                   call2_vod__r.city_vod__c,
                   call2_vod__r.state_vod__c,
                   call2_vod__r.zip_vod__c,
                   call2_vod__r.name, 
                   product_vod__r.manufacturer_vod__c, 
                   Product_vod__r.name,  
                   product_vod__r.Distributor_vod__c 
            from Call2_Sample_vod__c 
            where       
                      Lot_vod__c != null 
                  and call2_vod__c in ( select id from call2_vod__c 
                                        where id in :callIdList 
                                               or parent_call_vod__c in :callIdList )
            ];                                                    
        
        Map<String,Call2_Sample_vod__c> csMap = new Map<String, Call2_Sample_vod__c>();
        Set<String> callNameSet = new Set<String>();      
        for (Call2_Sample_vod__c cs : csList) {
            csMap.put ( cs.call2_vod__r.name + '-' + cs.Lot_vod__c , cs);
            callNameSet.add ( cs.call2_vod__r.name);
        }
        
        for ( Sample_Transaction_vod__c tx : [select call_name_vod__c, lot_name_vod__c
                                               from sample_transaction_vod__c 
                                               where call_name_vod__c in :callNameSet ] ) {
            csMap.remove (tx.call_name_vod__c + '-' + tx.lot_name_vod__c);
        }
        
        String recordTypeId = '';
        if ( csMap.size() > 0 ) {
            recordTypeId = [select id from recordType where name = 'Disbursement_vod' and sobjectType ='Sample_Transaction_vod__c'].Id;
        }
        
        for ( String csNameWithLotName : csMap.keySet() ) {
            Call2_Sample_vod__c cs = csMap.get (csNameWithLotName) ;
            
            // make it bulk
            Sample_Lot_vod__c sampleLot = [select id from Sample_Lot_vod__c where ownerId = :UserInfo.getUserId() and name = :cs.Lot_vod__c];
            
            Sample_Transaction_vod__c sampleTransaction = 
                new Sample_Transaction_vod__c ( RECORDTYPEID = recordTypeId, 
                                                CALL_NAME_VOD__C = cs.call2_vod__r.name, 
                                                CALL_DATE_VOD__C = cs.call2_vod__r.call_date_vod__c, 
                                                CALL_DATETIME_VOD__C = cs.call2_vod__r.call_datetime_vod__c,
                                                SIGNATURE_VOD__C  = cs.call2_vod__r.signature_vod__c,
                                                SIGNATURE_DATE_VOD__C = cs.call2_vod__r.signature_date_vod__c,
                                                DISCLAIMER_VOD__C = cs.call2_vod__r.disclaimer_vod__c, 
                                                LOT_NAME_VOD__C = cs.Lot_vod__c, 
                                                LOT_VOD__C = sampleLot.Id,
                                                QUANTITY_VOD__C = cs.Quantity_vod__c,
                                                ACCOUNT_VOD__C  = cs.call2_vod__r.account_vod__c, 
                                                LICENSE_VOD__C  = cs.call2_vod__r.license_vod__c, 
                                                ADDRESS_LINE_1_VOD__C   = cs.call2_vod__r.ship_address_line_1_vod__c,
                                                ADDRESS_LINE_2_VOD__C   = cs.call2_vod__r.ship_address_line_2_vod__c,
                                                ZIP_VOD__C  = cs.call2_vod__r.zip_vod__c, 
                                                CITY_VOD__C = cs.call2_vod__r.city_vod__c, 
                                                STATE_VOD__C = cs.call2_vod__r.state_vod__c,
                                                STATUS_VOD__C = 'Submitted_vod',   
                                                TYPE_VOD__C  = 'Disbursement_vod',
                                                MANUFACTURER_VOD__C =cs.product_vod__r.manufacturer_vod__c
                                               );            

            Missing_Sample_Transaction_Log_gne__c missingSampleTransactionLog = 
                new Missing_Sample_Transaction_Log_gne__c ( RECORDTYPEID_GNE__c = recordTypeId, 
                                                CALL_NAME_GNE__C = cs.call2_vod__r.name, 
                                                CALL_DATE_GNE__C = cs.call2_vod__r.call_date_vod__c, 
                                                CALL_DATETIME_GNE__C = cs.call2_vod__r.call_datetime_vod__c,
                                                SIGNATURE_GNE__C  = cs.call2_vod__r.signature_vod__c,
                                                SIGNATURE_DATE_GNE__C = cs.call2_vod__r.signature_date_vod__c,
                                                DISCLAIMER_GNE__C = cs.call2_vod__r.disclaimer_vod__c, 
                                                LOT_NAME_GNE__C = cs.Lot_vod__c, 
                                                LOT_GNE__C = sampleLot.Id,
                                                QUANTITY_GNE__C = cs.Quantity_vod__c,
                                                ACCOUNT_GNE__C  = cs.call2_vod__r.account_vod__c, 
                                                LICENSE_GNE__C  = cs.call2_vod__r.license_vod__c, 
                                                ADDRESS_LINE_1_GNE__C   = cs.call2_vod__r.ship_address_line_1_vod__c,
                                                ADDRESS_LINE_2_GNE__C   = cs.call2_vod__r.ship_address_line_2_vod__c,
                                                ZIP_GNE__C  = cs.call2_vod__r.zip_vod__c, 
                                                CITY_GNE__C = cs.call2_vod__r.city_vod__c, 
                                                STATE_GNE__C = cs.call2_vod__r.state_vod__c,
                                                STATUS_GNE__C = 'Submitted_vod',   
                                                TYPE_GNE__C  = 'Disbursement_vod',
                                                MANUFACTURER_GNE__C =cs.product_vod__r.manufacturer_vod__c,
                                                external_id_gne__c = csNameWithLotName
                                               );            

            sampleTransacionVodList.add (sampleTransaction);
            missingSampleTransactionLogList.add ( missingSampleTransactionLog);            
        }
                
        return sampleTransacionVodList.size(); 
    }

}