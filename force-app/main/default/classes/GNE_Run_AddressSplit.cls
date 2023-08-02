global class GNE_Run_AddressSplit {

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
    
    WebService static Double AddressSplit (String accountType, Integer startGroupId, Integer endGroupId) {

        GNE_Merge_Record_gne__c[] gneMergeList = [select id,  
                                                  group_Id_gne__c,  
                                                  account_gne__c,
                                                  address_gne__c,
                                                  account_update_log_gne__c,
                                                  winner_account_gne__c,
                                                  restart_task_gne__c,
                                                  governors_limit_log_gne__c,
                                                  governors_limit_log_copy_gne__c 
                                                  from gne_merge_record_gne__c 
                                                  where     group_id_gne__c >= :startGroupId  
                                                        and group_id_gne__c <= :endGroupId  
                                                        and account_type_gne__c = 'AddressSplit'   
                                                  order by group_id_gne__c, account_gne__c
                                                  limit 990];
                
        
        Double retGroupId = null;

        List<GNE_Merge_Record_gne__c> clonedList   = new List<GNE_Merge_Record_gne__c>();
        List<GNE_Merge_Record_gne__c> deferredList = new List<GNE_Merge_Record_gne__c>();
        GNE_Merge_Record_gne__c gneLimitReached = null;
                        
        GNE_AddressSplit_Controller addrSplit = new GNE_AddressSplit_Controller();
                                    
        for (GNE_Merge_Record_gne__c gneAddressSplit : gneMergeList ) {
        
            try {
                
                if ( GovernorsLimitReached()== FALSE ){
                    System.debug ('updating governors_limit_log_gne__c column');
                    gneLimitReached = gneAddressSplit;
                    gneLimitReached.governors_limit_log_gne__c =  'Task:AddressSplit:EndGroupId:' + endGroupId;  
                    break;
                } 
                                            
                gneAddressSplit.winner_account_gne__c  = addrSplit.doSplit(gneAddressSplit.account_gne__c,  
                                                                           gneAddressSplit.address_gne__c);
                gneAddressSplit.account_update_log_gne__c = null;                                                                           
                clonedList.add(gneAddressSplit);                    
                                
            } catch (GNE_Merge_Exception e) {
                System.debug ( 'Address Split skipped--> ' + e.getMessage() );
                gneAddressSplit.winner_account_gne__c = null; 
                gneAddressSplit.account_update_log_gne__c     = e.getMessage();
                deferredList.add (gneAddressSplit);
            } catch (Exception e) {
	            System.debug ( 'unhandled exception, addr split record skipped --> ' + e.getMessage() );
	            gneAddressSplit.winner_account_gne__c = null; 
	            gneAddressSplit.account_update_log_gne__c     = e.getMessage();
	            deferredList.add (gneAddressSplit);
            }                           

        }
        
        if ( clonedList.size() > 0 )
            update clonedList;
            
        if ( deferredList.size() > 0   )
            update deferredList;
    
        if ( gneLimitReached != null ) {
            update gneLimitReached;
            retGroupId = gneLimitReached.group_id_gne__c;
        }            
        
        return retGroupId;
        
    }
    
   
}