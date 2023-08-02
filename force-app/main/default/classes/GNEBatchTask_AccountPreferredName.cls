// guruk@gene.com - populate preferred name using address info
// preferred Name is used to provide location specific info for account
public class GNEBatchTask_AccountPreferredName  {

        public static Set<Id> getPreferredNameAccountRecordTypeIdSet ( ) {
            
            Set<Id> recordTypeId = new Set<Id> (); 
            
            // Record Type - Stewardship System Mapping environment list                                 
            Environment_variables__c[] env_list = [select key__c, value__c from environment_variables__C 
                                                   where key__c like 'PreferredNameWithLocationInfo.AcountRecordTypeList' 
                                                         and environment__c = 'all'  
                                                         order by key__c];
 
            String[] recordTypeNames = new String[] { 'No Record Type' }; 
            for (Environment_variables__c env_item : env_list) 
                recordTypeNames.addAll (  env_item.value__c.split(':') );
                        
            System.debug ( recordTypeNames );
            
            RecordType[] recordTypeList = [select id from recordtype    
                                           where Name in :recordTypeNames and 
                                                 sObjectType ='Account' and  
                                                 isActive = True];
                                       
            for ( RecordType rt : recordTypeList ) {
                recordTypeId.add ( rt.Id );
            }
            
            return recordTypeId;        
        }

    public static void set_acct_preferred_name_with_address (Account acct) {

            // fetch all address
            Address_vod__c[] addrSet  = 
                                           ( [select id, account_vod__c,
                                                     account_vod__r.id, account_vod__r.name, 
                                                     account_vod__r.preferred_name_vod__c, 
                                                     primary_vod__c, active_flag_gne__c,
                                                     name, city_vod__c, state_vod__c, zip_vod__c
                                              from   address_vod__c 
                                              where  account_vod__c = :acct.Id and 
                                                     (active_flag_gne__c = null or active_flag_gne__c = true )
                                                order by account_vod__c,  primary_vod__c desc, 
                                                active_flag_gne__c desc, lastmodifieddate desc
                                             ]
                                           );


            if ( addrSet.size() > 0 ) {

            Address_vod__c addr = addrSet[0];                                          
            String preferredName = acct.Name;

             if (addr.Name != null && (addr.Name.equalsIgnoreCase('none')==false) && addr.Name.length() > 0  ) 

                    preferredName += '-' + addr.Name ;
                     
                     if (addr.city_vod__c != null && addr.city_vod__c.length() > 0 ) 
                        preferredName += '-' + addr.city_vod__c; 
        
                     if (addr.state_vod__c != null && addr.state_vod__c.length() > 0 )
                        preferredName += '-' + addr.state_vod__c;
                        
                     if (addr.zip_vod__c != null && addr.zip_vod__c.length() > 0 )
                        preferredName += '-' + addr.zip_vod__c ;
      
                     if ( preferredName.length() > 255)
                        preferredName = preferredName.substring(0,255);
        
                     preferredName = preferredName.toUpperCase();
                     
                     if ( acct.preferred_name_vod__c == null  ||
                         acct.preferred_name_vod__c.equals(preferredName) == false   ) {
                         acct.preferred_name_vod__c = preferredName  ;
                     }               
            } else {
                //acct.preferred_name_vod__c = acct.Name;
                acct.preferred_name_vod__c = null;
            }

    }
        

        public static void acct_preferred_name_with_address (Set<id> acctSet) {

            List<Account> acctListToUpdate = new List<Account>();

            for (Account acct : [select id, name, preferred_name_vod__c, isPersonAccount, firstname, lastname,
                                 ( select id, name, city_vod__c, state_vod__c, zip_vod__c from address_vod__r 
                                   where active_flag_gne__c = null or active_flag_gne__c = true 
                                   order by primary_vod__c desc, active_flag_gne__c desc, lastmodifieddate desc
                                   limit 1
                                 )
                              from account 
                              where id in :acctSet 
                             ] )   {

                if ( acct.address_vod__r.size() == 0 ) {
                    acct.preferred_name_vod__c = null;     
                    acctListToUpdate.add (acct);                        
                } else {
                
                     Address_vod__c addr = acct.address_vod__r[0];
                     String preferredName = null;
                     if ( acct.isPersonAccount ) 
                         preferredName = acct.FirstName + ' '  + acct.LastName;
                     else 
                         preferredName = acct.Name ; 
                
                     // street           
                     if (addr.Name != null &&  addr.Name.length() > 0  ) 
                        preferredName += '-' + addr.Name ;
                     
                     if (addr.city_vod__c != null && addr.city_vod__c.length() > 0 ) 
                        preferredName += '-' + addr.city_vod__c; 
        
                     if (addr.state_vod__c != null && addr.state_vod__c.length() > 0 )
                        preferredName += '-' + addr.state_vod__c;
                        
                     if (addr.zip_vod__c != null && addr.zip_vod__c.length() > 0 )
                        preferredName += '-' + addr.zip_vod__c ;
                     
                     if ( preferredName.length() > 255)
                        preferredName = preferredName.substring(0,255);
                        
                     preferredName = preferredName.toUpperCase();
                     
                     //System.debug ( 'acct id/preferred_name ' + acct.Id + '/'+ preferredName );
                     if ( acct.preferred_name_vod__c == null  ||
                         acct.preferred_name_vod__c.equals(preferredName) == false   ) {
                         acct.preferred_name_vod__c = preferredName  ;
                         acctListToUpdate.add(acct);
                     }    
                 }         
             }
               
            // update account
            if ( acctListToUpdate.size() > 0 ) 
                update acctListToUpdate;                 
        }
            
        /*        
        //@future 
        public static void run (String objBatchTaskInstanceId, Datetime lastTaskStartTime) {
    
          GNE_Batch_Task_Instance_gne__c obj= null;
          try {
          
            obj = [Select Id, Status_gne__c,rows_read_gne__c,rows_updated_gne__c, log_gne__c, end_datetime_gne__c
                  from GNE_Batch_Task_Instance_gne__c where Id =  :objBatchTaskInstanceId ][0];                   
            obj.status_gne__c ='Running';
            update obj;
                       
            Set<Id> recordTypeId = GNEBatchTask_AccountPreferredName.getPreferredNameAccountRecordTypeIdSet();
             
            Integer rowsAllowedToProcess = Limits.getLimitQueryRows();

            //fetch accounts, address where record created or modified  
            for (Address_vod__c[] updatedAddrSet :  [select account_vod__c 
                                                     from address_vod__c 
                                                     where ( (createddate >      :lastTaskStartTime or 
                                                              lastmodifieddate > :lastTaskStartTime) 
                                                             or 
                                                             (account_vod__r.createdDate >      :lastTaskStartTime or 
                                                              account_vod__r.lastmodifieddate > :lastTaskStartTime)
                                                           )
                                                           and account_vod__r.recordTypeId in :recordTypeId 
                                                           and account_vod__r.lastmodifiedbyId != :UserInfo.getUserId() 
                                                           limit :rowsAllowedToProcess
                                                      ] 
                                                  ) {

                Set<Id> updatedAddrAcctSet = new Set<Id>();                                              
                for ( Address_vod__c addr : updatedAddrSet )  {
                    if ( UpdatedAddrAcctSet.contains(addr.account_vod__c) == false )
                        UpdatedAddrAcctSet.add(addr.account_vod__c);                      
                }            
                
                rowsAllowedToProcess = Limits.getLimitQueryRows() - Limits.getQueryRows();
                if ( rowsAllowedToProcess < (updatedAddrAcctSet.size()*2) ) {
                    obj.status_gne__c ='Initialized';
                    break; // cannot process as limits reached.
                }                    
                    
                acct_preferred_name_with_address(updatedAddrAcctSet);
                
                if ( (Limits.getQueryRows()+400) >= 10000 ){
                    obj.status_gne__c ='Initialized';
                    break;
                }                    
            }
            
            if ( obj.status_gne__c != 'Initialized' )
                obj.status_gne__c = 'Completed';
            
            obj.rows_read_gne__c     = obj.rows_read_gne__c + Limits.getQueryRows();
            obj.rows_updated_gne__c  = obj.rows_updated_gne__c + Limits.getDMLRows();
            obj.end_datetime_gne__c = datetime.now();            
            obj.log_gne__c          = null;
            update obj; 
        
         } catch (Exception e) {
            
            if ( obj != null ) {
                obj.status_gne__c = 'Error';
                obj.end_datetime_gne__c = datetime.now();
                String message = e.getMessage();
                if ( message.length() > 255 ) 
                    message = message.substring(0,255);
                    
                obj.log_gne__c = message; 
                update obj; 
            }
         }       
            
        }                
        */
    
}