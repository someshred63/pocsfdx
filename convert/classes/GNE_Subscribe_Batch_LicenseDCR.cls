global class GNE_Subscribe_Batch_LicenseDCR 
    implements Database.Batchable<SObject>, Database.Stateful  {
    	
    	                               
    Integer nRows = 0;
    Integer nUpdates  = 0;   
    Integer nTotal    = 0;
    Integer nFailures = 0;
    
    Integer lUpdates  = 0;
    Integer lCreated  = 0;   
    Integer lTotal    = 0;
    Integer lFailures = 0;
    
    DateTime startTime = DateTime.now();
                                 
    void addErrorLog (Database.SaveResult[] results) {
    	                
        try {
	        List<Error_Log_gne__c> errorLogList = new List<Error_Log_gne__c>();	        
	        for ( Database.SaveResult result : results ) {	        	
	        	if ( result.isSuccess() == false ) {
		            String errorDesc           = '';                          
		            Id recordId                =  result.getId();                                                
		            Database.Error[] errorList = result.getErrors();
		            for(Database.Error errorRecord : errorList) { 	            	
		                errorDesc = recordId +  ' - update failed. Error Code/Desc ' + 
						                          errorRecord.getStatusCode() + ' | ' + 
						                          errorRecord.getMessage() ;
		                break;
		            }
			        errorLogList.add(
			                         new Error_log_gne__c(Error_Level_gne__c    = 'High',
			                                              Code_Type__c          = 'Apex Class',
			                                              Snippet_Name__c       = 'GNE_Subscribe_Batch_LicenseDCR',
			                                              User_Name__c          = UserInfo.getUserName(),
			                                              Object_Name__c        = 'Address_vod__c',           
			                                              Error_Description__c  = errorDesc
			                                              )
			                        );

	        	}


	        }  	             
            database.insert ( errorLogList );                                   
        } catch ( Exception ex ) {
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + ex.getMessage() );    
        }
    }
    
    global Database.QueryLocator start(Database.batchableContext bc) {        
        
        String activeOverwrite   = 'Active Overwrite';
        String recordTypeName    = 'License/Sampleability Info';
        
        String sql =    'Select c.Account_gne__c, c.License_Designation_gne__c,           ' +  
					    '      c.License_Overwrite_Expiration_Date_gne__c, c.License_Number_gne__c, ' + 
					    '      c.Adjusted_License_Expiration_Date_gne__c,                ' +
					    '      c.License_State_gne__c from Change_Request_gne__c c        ' + 
					    ' where  c.recordtype.name = :recordTypeName and                  ' + 
					    '       c.status_gne__c = :activeOverwrite                          ' + 
					    ' order by c.account_gne__c, createdDate asc ' ; 
					                
        return Database.getQueryLocator ( sql );      
    }

    global void execute(Database.BatchableContext BC, List<SObject> objectList){        
    	        
        nRows = nRows + objectList.size();        
	    Set<String>   acctIdSet   = new Set<String>();
	    Set<String>   stateNameSet= new Set<String>();
	    Map <String,  Change_Request_gne__c>  mapAcctLicenseDCR = new Map<String, Change_Request_gne__c> () ;

        try {
	        for (SObject record : objectList ) {        
	            Change_Request_gne__c dcr = (Change_Request_gne__c) record;
		        acctIdSet.add ( dcr.account_gne__c);
		        stateNameSet.add ( dcr.license_state_gne__c ) ;
		        mapAcctLIcenseDCR.put ( dcr.account_gne__c + '.' + dcr.license_state_gne__c, 
		                                dcr );        
	        }
	
	
		    for (  List<address_vod__c> addrList : 
		                        [select id, account_vod__c, state_vod__c,
		                         license_vod__c, license_status_vod__c,
		                         license_expiration_date_vod__c ,
		                         designation_gne__c 
		                         from   address_vod__c 
		                         where  state_vod__c       in :stateNameSet 
		                                and account_vod__c in :acctIdSet ] )  {                
                
		        nTotal = nTotal + addrList.size();
		        
		        List<address_vod__c> updateAddrList = new List<address_vod__c>();
		        	                                        
		        for ( address_vod__c addr : addrList ) {                        	
		            String accountStateKey    = addr.account_vod__c + '.' + addr.state_vod__c;            
		            Change_Request_gne__c dcr = mapAcctLicenseDCR.get ( accountStateKey );
		            if ( dcr != null ) {

		                Boolean bChanged = false;
		                
		                if ( addr.license_vod__c == null || 
		                    addr.license_vod__c != dcr.license_number_gne__c ) {                		                          		                
                            addr.license_vod__c                 = dcr.license_number_gne__c;
                            bChanged = true;
                        }

                        if ( addr.license_status_vod__c == null || 
                            addr.license_status_vod__c != 'Valid_vod' ) {                                                                       
                            addr.license_status_vod__c          = 'Valid_vod';                      
                            bChanged = true;
                        }

                        if ( addr.license_expiration_date_vod__c == null || 
                            addr.license_expiration_date_vod__c != dcr.Adjusted_License_Expiration_Date_gne__c ) {                                                                       
	                        addr.license_expiration_date_vod__c = dcr.Adjusted_License_Expiration_Date_gne__c;                     
                            bChanged = true;
                        }

                        if ( addr.designation_gne__c == null || 
                            addr.designation_gne__c != dcr.license_designation_gne__c ) {                                                                       
                            addr.designation_gne__c = dcr.license_designation_gne__c;                     
                            bChanged = true;
                        }
                       
		                if ( bChanged ) 
		                  updateAddrList.add ( addr );
		                
		            }                
		        }
		        
		        if ( updateAddrList.size() > 0 ) { 
	    	        Database.SaveResult[] results = Database.update(updateAddrList, false);   
                    for (Database.SaveResult result : results) {
                    	if ( result.isSuccess()  )  
                            nUpdates++;
                        else
                            nFailures++;                                                		
                    }
                    addErrorLog ( results );
		        }    	         
	        }
	        
	        List<Prescriber_License_gne__c> updateLicenseList = new List<Prescriber_License_gne__c>();
	        Map<String, Prescriber_License_gne__c> accStateToLicensne = new Map<String, Prescriber_License_gne__c>();
	        
	        for (Prescriber_License_gne__c license : [SELECT Name, Account_gne__c, Designation_gne__c, License_Expiration_Date_gne__c, License_State_gne__c, License_Status_gne__c FROM Prescriber_License_gne__c WHERE Account_gne__c in :acctIdSet] ){
	        	lTotal++;
	        	String key    = license.Account_gne__c + '.' + license.License_State_gne__c;
	        	accStateToLicensne.put(key, license);
	        	Change_Request_gne__c dcr = mapAcctLicenseDCR.get ( key );
	        	 if ( dcr != null ) {
		                Boolean bChanged = false;
		                if ( license.name != dcr.license_number_gne__c ) {                		                          		                
                            license.name = dcr.license_number_gne__c;
                            bChanged = true;
                        }

                        if ( license.License_Status_gne__c == null ||  license.License_Status_gne__c != 'Valid_vod' ) {                                                                       
                            license.License_Status_gne__c  = 'Valid_vod';                      
                            bChanged = true;
                        }

                        if ( license.License_Expiration_Date_gne__c == null || license.License_Expiration_Date_gne__c != dcr.Adjusted_License_Expiration_Date_gne__c ) {                                                                       
	                        license.License_Expiration_Date_gne__c = dcr.Adjusted_License_Expiration_Date_gne__c;                     
                            bChanged = true;
                        }

                        if ( license.designation_gne__c == null ||  license.designation_gne__c != dcr.license_designation_gne__c ) {                                                                       
                            license.designation_gne__c = dcr.license_designation_gne__c;                     
                            bChanged = true;
                        }
                       
		                if ( bChanged ) { 
		                  updateLicenseList.add ( license );
		                }
		         }
	        }
	        
	        List<Prescriber_License_gne__c> licenseToInsert = new List<Prescriber_License_gne__c>();
	        
	        for (String key : mapAcctLIcenseDCR.keySet()) {
	        	if (!accStateToLicensne.containsKey(key)) {
	        		Change_Request_gne__c dcr = mapAcctLIcenseDCR.get(key);
	        		licenseToInsert.add(new Prescriber_License_gne__c(name = dcr.license_number_gne__c, License_Status_gne__c  = 'Valid_vod', License_Expiration_Date_gne__c = dcr.Adjusted_License_Expiration_Date_gne__c, designation_gne__c = dcr.license_designation_gne__c, Account_gne__c = dcr.account_gne__c, License_State_gne__c = dcr.license_state_gne__c));
	        	}	
	        }
	        
	        if ( updateLicenseList.size() > 0 ) { 
	    	        Database.SaveResult[] results = Database.update(updateLicenseList, false);   
                    for (Database.SaveResult result : results) {
                    	if ( result.isSuccess()  )  
                            lUpdates++;
                        else
                            lFailures++;                                                		
                    }
                    addErrorLog ( results );
		        }  
		    
		    if ( licenseToInsert.size() > 0 ) { 
	    	        Database.SaveResult[] results = Database.insert(licenseToInsert, false);   
                    for (Database.SaveResult result : results) {
                    	if ( result.isSuccess()  )  
                            lCreated++;
                        else
                            lFailures++;                                                		
                    }
                    addErrorLog ( results );
		        }         
	                                                     
        }catch (Exception ex) {
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + ex.getMessage() );    
        }        
    }        

               
    global void finish(Database.BatchableContext BC){
        try {
            AsyncApexJob a = [Select Id, Status, NumberOfErrors, ApexClass.Name, 
                              JobItemsProcessed, TotalJobItems, CreatedBy.Email,
                              CreatedDate, CompletedDate
                              from AsyncApexJob 
                              where Id =:BC.getJobId()
                              ];
            User createdUser = a.CreatedBy;
            ApexClass batchApexClass = a.ApexClass;

	        Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
	        String addr = configItemsMap.get('SubscribeNotfyEmail').Configuration_Value_gne__c;
                                              
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses ( new String[] {addr} );
            mail.setSubject('Apex Job ' + batchApexClass.Name +
                            ' status ' + a.Status);
            
            mail.setPlainTextBody
                            ('The batch Apex job processed DCR | Address Read | Update | Failed  - >' + 
                              nRows  + ' | ' + nTotal + ' | ' +  nUpdates + ' | ' + nFailures + '.\n' +
                             'The batch Apex job processed DCR | Prescriber License Read | Update | Created | Failed  - >' + 
                              nRows  + ' | ' + lTotal + ' | ' +  lUpdates + ' | ' +  lCreated + ' | ' + lFailures + '.\n' + 
                              'Start | End Times --> ' + startTime + ' - ' + DateTime.now() );

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 'Unable to send email ' + e.getMessage() );    
        }
     }    
}