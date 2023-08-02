global  class GNE_Run_ObjectMerge {
        
    public static Boolean GovernorsLimitReached() {
        
        Integer limitQueries     = Limits.getLimitQueries();
        Integer numOfQueries     = Limits.getQueries();     
        Integer remainingQueries = limitQueries - numOfQueries;     
        if ( remainingQueries <  (limitQueries / 2 ) )  
            return FALSE;       
        
        Integer limitRows     = Limits.getLimitQueryRows();
        Integer numOfRows     = Limits.getQueryRows();        
        Integer remainingRows = limitRows - numOfRows;
        if ( remainingRows < (limitRows/4))
            return FALSE;


        Integer limitFieldDescribe     = Limits.getLimitFieldsDescribes(); 
        Integer numOfFieldDescribe     = Limits.getFieldsDescribes();        
        Integer remainingFieldDescribe = limitFieldDescribe - numOfFieldDescribe;
        if ( remainingFieldDescribe < 5 )
            return FALSE;


        System.debug ('limitQueries / numOfQueries / limitRows / numOfRows ' + 
                      limitQueries + '/' + numOfQueries + '/' + limitRows + '/' + numOfRows );            
        return TRUE;            
    }
    
    WebService static Double AccountMerge (String accountType, Integer startGroupId, Integer endGroupId) {

        GNE_Merge_Record_gne__c[] gneMergeList = [select id, account_gne__c,
                                                  group_Id_gne__c,  
                                                  address_gne__c,
                                                  account_update_log_gne__c,
                                                  winner_account_gne__c,
                                                  restart_task_gne__c,
                                                  governors_limit_log_gne__c,
                                                  governors_limit_log_copy_gne__c 
                                                  from gne_merge_record_gne__c 
                                                  where     group_id_gne__c >= :startGroupId  
                                                        and group_id_gne__c <= :endGroupId  
                                                        and account_type_gne__c = : accountType  
                                                  order by group_id_gne__c, account_gne__c
                                                  limit 990];
                
        List<GNE_Merge_Record_gne__c> mergedList   = new List<GNE_Merge_Record_gne__c>();
        List<GNE_Merge_Record_gne__c> deferredList = new List<GNE_Merge_Record_gne__c>();
        GNE_Merge_Record_gne__c gneMergeLimitReached = null;
        
        GNE_ObjectMerge_Controller addrMerge          = new GNE_ObjectMerge_Controller('Account', accountType);
        Set<String> acctIdSet                         = new Set<String>();
        List<GNE_Merge_Record_gne__c> acctMergeSet    = new List<GNE_Merge_Record_gne__c>();
        Double groupId                                = null;
        Integer numRecords                            = gneMergeList.size();
        
        Double retGroupId = null;
        
        for (Integer i = 0; i < numRecords; i++ ) {
        
                GNE_Merge_Record_gne__c gneMergeRecord = gneMergeList[i];
                
                if ( gneMergeRecord.restart_task_gne__c != null ) {
                    System.debug ('Resetting Restart Task flag for record id -> ' + gneMergeRecord.Id );
                    gneMergeRecord.governors_limit_log_copy_gne__c = gneMergeRecord.governors_limit_log_gne__c;
                    gneMergeRecord.governors_limit_log_gne__c = null; // reset governros limit info
                    gneMergeRecord.restart_task_gne__c        = null; // reset restart flag
                    update gneMergeRecord;                  
                }
                
                if ( (groupId != null && groupId != gneMergeRecord.group_Id_gne__c) ||
                     ((i+1) == numRecords) ) {
                    
                    // identify new group 
                    if ( (i+1) == numRecords ) {
                        acctIdSet.add (gneMergeRecord.account_gne__c);
                        acctMergeSet.add (gneMergeRecord);
                    }
                        
                    try {
                        
                        if ( GovernorsLimitReached()== FALSE ){
                            System.debug ('updating governors_limit_log_gne__c column');
                            gneMergeLimitReached = gneMergeList[i-1];
                            gneMergeLimitReached.governors_limit_log_gne__c =  'Task:AccountMerge:EndGroupId:' + endGroupId;  
                            break;
                        } 
                                                    
                        String winnerId  = addrMerge.doMerge(acctIdSet,null);
                        for (GNE_Merge_Record_gne__c mergeRecord : acctMergeSet){ 
                            mergeRecord.winner_account_gne__c = winnerId;
                        }
                        mergedList.addAll (acctMergeSet);                    
                        
                    } catch (GNE_Merge_Exception e) {
                        System.debug ( 'merge skipped--> ' + e.getMessage() );
                        for (GNE_Merge_Record_gne__c mergeRecord : acctMergeSet) {
                            mergeRecord.winner_account_gne__c = null;
                            mergeRecord.account_update_log_gne__c     = e.getMessage();
                        }
                        deferredList.addAll (acctMergeSet);
                    } catch (Exception e) {
                         System.debug ( 'unhandled exception, merge record skipped --> ' + e.getMessage() );
                         for (GNE_Merge_Record_gne__c mergeRecord : acctMergeSet) {
                             mergeRecord.winner_account_gne__c = null;
                             mergeRecord.account_update_log_gne__c     = e.getMessage();
                         }
                         deferredList.addAll (acctMergeSet);
                    }                           
                    acctIdSet.clear();
                    acctMergeSet.clear();                       
                }   
                groupId = gneMergeRecord.group_id_gne__c;
                acctIdSet.add(gneMergeRecord.account_gne__c );       
                acctMergeSet.add(gneMergeRecord);
        }

        if ( mergedList.size() > 0 )
            update mergedList;
            
        if ( deferredList.size() > 0   )
            update deferredList;
    
        if ( gneMergeLimitReached != null ) {
            update gneMergeLimitReached;
            retGroupId = gneMergeLimitReached.group_id_gne__c;
        }            
        
        
        return retGroupId;
        
    }
    
    
    Webservice static Double AddressMerge (String accountType,Integer startGroupId, Integer endGroupId) {
    
        GNE_Merge_Record_gne__c[] gneMergeList = [select id, winner_account_gne__c, 
                                                  address_gne__c,
                                                  address_update_log_gne__c
                                                  from gne_merge_record_gne__c
                                                  where     group_id_gne__c >= :startGroupId  
                                                        and group_id_gne__c <= :endGroupId  
                                                        and winner_account_gne__c != null   
                                                        and account_type_gne__c = : accountType
                                                  order by group_id_gne__c, account_gne__c
                                                  limit 990];        
        
        List<GNE_Merge_Record_gne__c> mergedList   = new List<GNE_Merge_Record_gne__c>();
        List<GNE_Merge_Record_gne__c> deferredList = new List<GNE_Merge_Record_gne__c>();

        GNE_ObjectMerge_Controller addrMerge          = new GNE_ObjectMerge_Controller('Address_vod__c', null);
        Set<String> addrIdSet                         = new Set<String>();
        List<GNE_Merge_Record_gne__c> addrMergeSet    = new List<GNE_Merge_Record_gne__c>();
        String prevAccount                            = null;
        Integer numRecords                            = gneMergeList.size();

        Double retGroupId = null;
        GNE_Merge_Record_gne__c gneMergeLimitReached = null;
        
        for (Integer i = 0; i < numRecords; i++ ) {
        
                GNE_Merge_Record_gne__c gneMergeRecord = gneMergeList[i];
        
                if ( (prevAccount != null && prevAccount != gneMergeRecord.winner_account_gne__c) ||
                     ((i+1) == numRecords) ) {
                    
                    if ( (i+1) == numRecords ) {
                        addrIdSet.add (gneMergeRecord.address_gne__c);
                        addrMergeSet.add (gneMergeRecord);
                    }
                        
                    try {

                        if ( GovernorsLimitReached()== FALSE ){
                            System.debug ('updating governors_limit_log_gne__c column');
                            gneMergeLimitReached = gneMergeList[i-1];
                            gneMergeLimitReached.governors_limit_log_gne__c =  'Task:AddressMerge:EndGroupId:' + endGroupId;  
                            break;
                        } 

                        String winnerId  = addrMerge.doMerge(addrIdSet,prevAccount);
                        for (GNE_Merge_Record_gne__c mergeRecord : addrMergeSet){ 
                            mergeRecord.winner_address_gne__c = winnerId;
                            mergeRecord.address_update_log_gne__c = null;
                        }
                        mergedList.addAll (addrMergeSet);                    
                             
                    } catch (GNE_Merge_Exception e) {
                        System.debug ( 'merge skipped--> ' + e.getMessage() );
                        for (GNE_Merge_Record_gne__c mergeRecord : addrMergeSet) {
                            mergeRecord.winner_address_gne__c = null;
                            mergeRecord.address_update_log_gne__c = e.getMessage();
                        }
                        deferredList.addAll (addrMergeSet);
                    } catch (Exception e) {
                         System.debug ( 'unhandled exception, merge record skipped --> ' + e.getMessage() );
                         for (GNE_Merge_Record_gne__c mergeRecord : addrMergeSet) {
                             mergeRecord.winner_address_gne__c = null;
                             mergeRecord.address_update_log_gne__c     = e.getMessage();
                         }
                         deferredList.addAll (addrMergeSet);
                    }                           
                    addrIdSet.clear();
                    addrMergeSet.clear();                       
            }   
            prevAccount = gneMergeRecord.winner_account_gne__c;
            addrIdSet.add(gneMergeRecord.address_gne__c );       
            addrMergeSet.add(gneMergeRecord);
        }

        if ( mergedList.size() > 0 )
            update mergedList;
            
        if ( deferredList.size() > 0   )
            update deferredList;

        if ( gneMergeLimitReached != null ) {
            update gneMergeLimitReached;
            retGroupId = gneMergeLimitReached.group_id_gne__c;
        }            
                
        return retGroupId;
    
    }

}