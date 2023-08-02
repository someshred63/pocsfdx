global  class GNE_Batch_InsertFRMAutoAlignments implements Database.Batchable<SObject>   {

	/* steps to run this in setup window:
	   Id batchInstanceId = database.executeBatch(new GNE_Batch_InsertFRMAutoAlignments()); 
	*/
    // no state is maintained across each execute batch invocation
     
    Map<String,Set<String>> frmBrandCodeToZipCodes = new Map<String,Set<String>>();

    Map<String,FRMBrandCodeZipToTerritoryInfo> frmBrandCodeToTerritoryInfoMap = 
            new Map<String,FRMBrandCodeZipToTerritoryInfo>();
    
    Map<String, case_acct_frm_auto_align_gne__c> frmAcctZipMap = 
            new Map<String, case_acct_frm_auto_align_gne__c>();
    
    public GNE_Batch_InsertFRMAutoAlignments() { }

    String query = 'select id, frm_account_zip_gne__c, load_status_gne__c, '   +          
			       'territory_number_gne__c,  group_gne__c, ' + 
			       'frm_brand_code_gne__c, zip_gne__c, account_gne__c '        +  
                   'from   case_acct_frm_auto_align_gne__c '                   + 
                   ' where  load_status_gne__c in ' +  
                   '(\'Zip To Territory Number Missing\', '                    + 
                   '\'Territory Number To SFDC Territory Id Missing\','             + 
                   '\'Ready To Align\' ) ' ; 
                    
    void initializeFRMBrandCodeZipToTerritoryInfo() {
        for (String frmBrandCode : frmBrandCodeToZipCodes.keySet() ) {

            FRMBrandCodeZipToTerritoryInfo frmBrandCodeZipToTerritoryInfo = 
                new FRMBrandCodeZipToTerritoryInfo( frmBrandCode, 
                                                    frmBrandCodeToZipCodes.get(frmBrandCode) );

            frmBrandCodeToTerritoryInfoMap.put ( frmBrandCode, 
                                                 frmBrandCodeZipToTerritoryInfo);
        }
    }

    void removeFRMAutoAlignForExistingAcctShare() {

        set<string> acctIdSet        = new Set<String>();
        set<string> groupIdSet       = new Set<String>();
        Map<String,  set<String>> acctGroupToFRMAcctZipMap  = new Map<String,set<String>>();

        case_acct_frm_auto_align_gne__c[] alreadyAlignedCaseAcctFRMAutoAlignList = 
                        new case_acct_frm_auto_align_gne__c[] { };

        for (String frmAcctZipKey : frmAcctZipMap.keySet() ) {
            case_acct_frm_auto_align_gne__c objCaseAcctFRMAutoAlign = frmAcctZipMap.get(frmAcctZipKey);
            if ( objCaseAcctFRMAutoAlign.group_gne__c  != null ) {
                acctIdSet.add  (objCaseAcctFRMAutoAlign.account_gne__c);
                groupIdSet.add (objCaseAcctFRMAutoAlign.group_gne__c);            
                String acctgroupKeySet = objCaseAcctFRMAutoAlign.account_gne__c + '_' + 
                                         objCaseAcctFRMAutoAlign.group_gne__c;

                Set<String> frmAcctZipIds = acctGroupToFRMAcctZipMap.get (acctGroupKeySet);
                if ( frmAcctZipIds == null ) {                         
                    frmAcctZipIds= new Set<String>();   
                    acctGroupToFRMAcctZipMap.put ( acctGroupKeySet, frmAcctZipIds );    
                }
                frmAcctZipIds.add(frmAcctZipKey);
            }
        }
        
        for (AccountShare[] acctShareList : 
                    [select accountId, userorgroupId 
                     from accountshare 
                     where     accountId in :acctIdSet 
                           and userorgroupId in :groupIdSet ] ) {

            for ( AccountShare acctShare : acctShareList ) {            
                String acctGroupKey  = acctShare.accountId + '_' + acctShare.userOrGroupId;            
                Set<String> frmAcctZipIds = acctGroupToFRMAcctZipMap.get ( acctGroupKey );
                if ( frmAcctZipIds != null ) { // existing acct share 
                	for (String frmAcctZipKey : frmAcctZipIds ) {
	                    case_acct_frm_auto_align_gne__c objCaseAcctFRMAutoAlign = frmAcctZipMap.remove ( frmAcctZipKey );
	                    objCaseAcctFRMAutoAlign.load_status_gne__c = 'Alignment Exists';
	                    alreadyAlignedCaseAcctFRMAutoAlignList.add (objCaseAcctFRMAutoAlign); 
                	} // for each alignment already present 	                    
                } 
            } // for each accountshare 
        }   
        
        if ( alreadyAlignedCaseAcctFRMAutoAlignList.size() >0 )
            update alreadyAlignedCaseAcctFRMAutoAlignList;
    }

    global Database.QueryLocator start(Database.batchableContext bc) {
        return Database.getQueryLocator ( query ); 
    }

    void reprocessPendingFRMAutoAlign (List<SObject> caseAcctFRMAutoAlignList) {
        for ( SObject objectRecord : caseAcctFRMAutoAlignList ) {
            case_acct_frm_auto_align_gne__c objCaseAcctFRMAutoAlign = 
                        ( case_acct_frm_auto_align_gne__c ) objectRecord;

            String frmAcctZipKey =   objCaseAcctFRMAutoAlign.frm_account_zip_gne__c;

            if ( objCaseAcctFRMAutoAlign.load_status_gne__c.endsWith('Missing') ) {
                String frmBrandCode = objCaseAcctFRMAutoAlign.frm_brand_code_gne__c;
                String zip          = objCaseAcctFRMAutoAlign.zip_gne__c;                                                                  
                Set<String> zipCodeSet = frmBrandCodeToZipCodes.get(frmBrandCode);
                if ( zipCodeSet == null ) {
                    zipCodeSet = new Set<String>();
                    frmBrandCodeToZipCodes.put(frmBrandCode, zipCodeSet);
                }
                zipCodeSet.add (zip);
            } else if ( objCaseAcctFRMAutoAlign.load_status_gne__c.equalsIgnoreCase ('Ready To Align') ) {                                    
                frmAcctZipMap.put (frmAcctZipKey, objCaseAcctFRMAutoAlign); 
            }
        }

        initializeFRMBrandCodeZipToTerritoryInfo();
        
    }
    
    void repopulateFRMAutoAlignZipToGroupId (List<SObject> caseAcctFRMAutoAlignList) {
    	
        case_acct_frm_auto_align_gne__c[] updateCaseAcctFRMAutoAlignList = 
                        new case_acct_frm_auto_align_gne__c[] { };

        for ( SObject objectRecord : caseAcctFRMAutoAlignList ) {

            case_acct_frm_auto_align_gne__c objCaseAcctFRMAutoAlign = ( case_acct_frm_auto_align_gne__c ) objectRecord;
            String frmAcctZipKey =   objCaseAcctFRMAutoAlign.frm_account_zip_gne__c;

            if ( objCaseAcctFRMAutoAlign.load_status_gne__c.endsWith('Missing') ) {
                
                String territoryNumber = null;
                String groupId         = null;
                String loadStatus      = null;                

                FrmBrandCodeZipToTerritoryInfo frmBrandCodeZipToTerritoryInfo = 
                    frmBrandCodeToTerritoryInfoMap.get ( objCaseAcctFRMAutoAlign.frm_brand_code_gne__c );
                territoryNumber = frmBrandCodeZipToTerritoryInfo.getTerritoryNumber(objCaseAcctFRMAutoAlign.zip_gne__c);
                
                if ( territoryNumber !=null ) {
                    groupId = frmBrandCodeZipToTerritoryInfo.getGroupId(territoryNumber);
                    if ( groupId != null ) {
                        objCaseAcctFRMAutoAlign.territory_number_gne__c = territoryNumber;
                        objCaseAcctFRMAutoAlign.group_gne__c            = groupId;
                        objCaseAcctFRMAutoAlign.load_status_gne__c      = 'Ready To Align';
                        frmAcctZipMap.put (frmAcctZipKey, objCaseAcctFRMAutoAlign);
                        
                        updateCaseAcctFRMAutoAlignList.add ( objCaseAcctFRMAutoAlign ); // update 'Ready To Align'
                        
                    } else {
                        loadStatus = 'Territory Number To SFDC Territory Id Missing';
                    }
                } else {
                    loadStatus = 'Zip To Territory Number Missing';                    
                }
                
                if ( groupId == null && 
                     (objCaseAcctFRMAutoAlign.load_status_gne__c.equalsIgnoreCase (loadStatus) == false) ) {              
                    objCaseAcctFRMAutoAlign.load_status_gne__c = loadStatus;
                    updateCaseAcctFRMAutoAlignList.add ( objCaseAcctFRMAutoAlign );  
                }
            }    
        }
        
        if ( updateCaseAcctFRMAutoAlignList.size() >0 ) 
            update updateCaseAcctFRMAutoAlignList;
    }

    void insertAccountShareForFRMAutoAlign() {
    	    	
    	AccountShare[] accountShareList = new AccountShare[] { };
    	DateTime accountAlignedDate = System.Now();
    	    	
    	for (case_acct_frm_auto_align_gne__c objCaseAcctFRMAutoAlign :
    	                   frmAcctZipMap.values() ) {            
            AccountShare accountShare  = new AccountShare();
            accountShare.accountId     = objCaseAcctFRMAutoAlign.account_gne__c;
            accountShare.userOrGroupId = objCaseAcctFRMAutoAlign.group_gne__c;            
            accountShareList.add ( accountShare );       	                   	
            
            objCaseAcctFRMAutoAlign.load_status_gne__c = 'Aligned via Batch';
            objCaseAcctFRMAutoAlign.account_aligned_date_gne__c = accountAlignedDate;
        }
        
        if ( accountShareList.size() > 0 ) {  
            upsert accountShareList;
            upsert frmAcctZipMap.values();
        }                    
                        
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> caseAcctFRMAutoAlignList){        
        try {
	        reprocessPendingFRMAutoAlign (caseAcctFRMAutoAlignList);        
	        repopulateFRMAutoAlignZipToGroupId(caseAcctFRMAutoAlignList);
	        removeFRMAutoAlignForExistingAcctShare();
            insertAccountShareForFRMAutoAlign(); // upsert ready to align into accountshare 
        } catch (Exception e) {        
            System.debug ( e.getMessage()); 
        }
    }

    global void finish(Database.BatchableContext BC){
    
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, ApexClass.Name, 
                          JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          from AsyncApexJob 
                          where Id =:BC.getJobId()
                          ];
        User createdUser = a.CreatedBy;
        ApexClass batchApexClass = a.ApexClass;
                                          
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {createdUser.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Job ' + + batchApexClass.Name + 
                        ' status ' + a.Status);
                        
        mail.setPlainTextBody
                        ('The batch Apex job ' + batchApexClass.Name + 
                        ' processed ' + a.TotalJobItems +
                        ' batches with '                 + a.NumberOfErrors + 
                        ' failures.'  );
                        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
    
    }
}