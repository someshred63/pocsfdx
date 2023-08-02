global class GNE_Batch_FRMAutoAlign implements Database.Batchable<SObject>  {

/* steps to run this in setup window:
   Id batchInstanceId = database.executeBatch(new GNE_Batch_FRMAutoAlign(<<StartDateTime>>)); 
*/
    // no state is maintained across each execute batch invocation
     
    DateTime startDate                             = null;
    Map<String,Set<String>> frmBrandCodeToZipCodes = new Map<String,Set<String>>();
    Map<String,Set<String>> productToFRMMap        = new Map<String, Set<String>>();

    Map<String,FRMBrandCodeZipToTerritoryInfo> frmBrandCodeToTerritoryInfoMap = 
            new Map<String,FRMBrandCodeZipToTerritoryInfo>();
    
    Map<String, case_acct_frm_auto_align_gne__c> frmAcctZipMap = 
            new Map<String, case_acct_frm_auto_align_gne__c>();
    
    private GNE_Batch_FRMAutoAlign() { }
  
        
    public GNE_Batch_FRMAutoAlign (DateTime startDate) {
    	this.startDate = startDate; 
    }

   void initializeProductToFRMMap() {        
        Map<String, FRMBrandCodeToCaseProductList_gne__c> customSettingMap = 
            FRMBrandCodeToCaseProductList_gne__c.getAll();

        for (String key : customSettingMap.keySet() ) {
            
            FRMBrandCodeToCaseProductList_gne__c frmBrandCodeToCaseProduct
                     = customSettingMap.get(key);
        
            String[] productList = frmBrandCodeToCaseProduct.product_list_gne__c.split(',');
            for ( String product : productList ) {
            	String productKey = product.toUpperCase();
                Set<String> productSet = productToFRMMap.get(productKey);
                if ( productSet == null ) {
                    productSet = new Set<String>();
                    productToFRMMap.put(productKey, productSet);
                }
                productSet.add (frmBrandCodeToCaseProduct.FRM_Brand_code_gne__c);
            }
        }
    }

    void initializeFRMBrandCodeZipToTerritoryInfo() {
        for (String frmBrandCode : frmBrandCodeToZipCodes.keySet() ) {

            FRMBrandCodeZipToTerritoryInfo frmBrandCodeZipToTerritoryInfo = 
                new FRMBrandCodeZipToTerritoryInfo( frmBrandCode, 
                                                    frmBrandCodeToZipCodes.get(frmBrandCode) );

            frmBrandCodeToTerritoryInfoMap.put ( frmBrandCode, 
                                                 frmBrandCodeZipToTerritoryInfo);
        }
    }

    void populateFRMAutoAlignZipToGroupId(){

        for (String frmAcctZipKey : frmAcctZipMap.keySet() ) {
            
            case_acct_frm_auto_align_gne__c objCaseAcctFRMAutoAlign = frmAcctZipMap.get(frmAcctZipKey);

            FRMBrandCodeZipToTerritoryInfo frmBrandCodeZipToTerritoryInfo = 
                frmBrandCodeToTerritoryInfoMap.get ( objCaseAcctFRMAutoAlign.frm_brand_code_gne__c );

            String territoryNumber = frmBrandCodeZipToTerritoryInfo.getTerritoryNumber( objCaseAcctFRMAutoAlign.zip_gne__c);

            if ( territoryNumber != null ) {
	            objCaseAcctFRMAutoAlign.territory_number_gne__c = territoryNumber;
                objCaseAcctFRMAutoAlign.group_gne__c = frmBrandCodeZipToTerritoryInfo.getGroupId(territoryNumber);                
                if ( objCaseAcctFRMAutoAlign.group_gne__c != null ) {                
                    objCaseAcctFRMAutoAlign.load_status_gne__c = 'Ready To Align';                                        
                }  else {
                    objCaseAcctFRMAutoAlign.load_status_gne__c = 'Territory Number To SFDC Territory Id Missing';
                }
            } else {
                objCaseAcctFRMAutoAlign.load_status_gne__c = 'Zip To Territory Number Missing';
            }
        }    
    }

    void removeFRMAutoAlignForExistingAcctShare() {

        set<string> acctIdSet        = new Set<String>();
        set<string> groupIdSet       = new Set<String>();
        Map<String, SEt<String>> acctGroupToFRMAcctZipMap  = new Map<String,Set<String>>();

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
                String acctGroupKey       = acctShare.accountId + '_' + acctShare.userOrGroupId;            
                Set<String> frmAcctZipIds = acctGroupToFRMAcctZipMap.get ( acctGroupKey );

                if ( frmAcctZipIds != null ) { // existing acct share 
                    for (String frmAcctZipKey : frmAcctZipIds ) 
                        frmAcctZipMap.remove ( frmAcctZipKey );
                }
            }
        }                       
    }

    void upsertFRMAutoAlign() {

        Set<String> frmAcctZipKeySet = frmAcctZipMap.keySet().clone();
        
        for ( case_acct_frm_auto_align_gne__c[] objCaseAcctFRMAutoAlignList : 
                    [ select id, account_gne__c, zip_gne__c, caseIds_gne__c,
                      frm_account_zip_gne__c  
                      from  case_acct_frm_auto_align_gne__c 
                      where frm_account_zip_gne__c in : frmAcctZipKeySet ] ) {

            for ( case_acct_frm_auto_align_gne__c objCaseAcctFRMAutoAlign : objCaseAcctFRMAutoAlignList ) {           
                case_acct_frm_auto_align_gne__c objCaseAcctFRMAutoAlignUpsert = 
                        frmAcctZipMap.get(objCaseAcctFRMAutoAlign.frm_account_zip_gne__c);
                
                if ( objCaseAcctFRMAutoAlign.caseIds_gne__c.contains (objCaseAcctFRMAutoAlign.caseIds_gne__c) )
	                    frmAcctZipMap.remove (objCaseAcctFRMAutoAlign.frm_account_zip_gne__c); 
                    else
		                objCaseAcctFRMAutoAlignUpsert.caseIds_gne__c = objCaseAcctFRMAutoAlign.caseIds_gne__c + 
		                                                               + ',' + 
		                                                               objCaseAcctFRMAutoAlignUpsert.caseIds_gne__c;
            }
        }
        
        
        if ( frmAcctZipMap.size() >0 ) 
            upsert frmAcctZipMap.values() case_acct_frm_auto_align_gne__c.frm_account_zip_gne__c;
    }

        
    global Database.QueryLocator start(Database.batchableContext bc) {
    	
    	String caseQuery = 'select id, zip_gne__c, product_gne__c, createdDate, ' + 
    	               'case_treating_physician_gne__c, practice_gne__c, ' + 
    	               'facility_gne__c from case ' + 
    	               'where ( case_treating_physician_gne__c != null or ' + 
    	               ' practice_gne__c != null or ' + 
    	               ' facility_gne__c != null ) ' +
    	               ' and product_gne__c != null ' +    
    	               ' and zip_gne__c != null ' + 
                       ' and (createdDate > :startDate or ' + 
                       '      lastmodifieddate > :startDate) ' +
    	               ' order by createdDate asc ' ;
        return Database.getQueryLocator ( caseQuery ); 
    }

    global void execute(Database.BatchableContext BC, List<SObject> caseList){        

        try {
    	initializeProductToFRMMap();
        for (Case caseRecord : (Case []) caseList ) {
        	
        	if ( caseRecord.product_gne__c.trim().length() == 0 ) 
        	   continue; // skip empty product cases 
        	   
            Set<String> frmSet = productToFRMMap.get(caseRecord.product_gne__c.toUpperCase());
            if ( frmSet == null )  
                continue;   
            
            Set<String> caseAccts = new Set<String>(); 
                
            if ( caseRecord.case_treating_physician_gne__c !=null ) 
                caseAccts.add ( caseRecord.case_treating_physician_gne__c );

            if ( caseRecord.practice_gne__c != null ) 
                caseAccts.add ( caseRecord.practice_gne__c );

            if ( caseRecord.facility_gne__c !=null )
                caseAccts.add ( caseRecord.facility_gne__c );
                    
            for ( String frmBrandCode : frmSet) {                    
                for ( String acct : caseAccts ) {                    
                    String frmAcctZipKey = frmBrandCode + '_' + acct + '_' + caseRecord.zip_gne__c;
                    case_acct_frm_auto_align_gne__c objCaseAcctFRMAutoAlign = frmAcctZipMap.get ( frmAcctZipKey );
                        
                    if ( objCaseAcctFRMAutoAlign == null ) {
                        objCaseAcctFRMAutoAlign                       = new case_acct_frm_auto_align_gne__c();
                        objCaseAcctFRMAutoAlign.zip_gne__c            = caseRecord.zip_gne__c;
                        objCaseAcctFRMAutoAlign.account_gne__c        = acct;
                        objCaseAcctFRMAutoAlign.frm_brand_code_gne__c = frmBrandCode;
                        objCaseAcctFRMAutoAlign.caseIds_gne__c        = caseRecord.Id;
                        objCaseAcctFRMAutoAlign.frm_account_zip_gne__c= frmAcctZipKey;                           
                        frmAcctZipMap.put ( frmAcctZipKey, objCaseAcctFRMAutoAlign );

                    } else {
                        objCaseAcctFRMAutoAlign.caseIds_gne__c = objCaseAcctFRMAutoAlign.caseIds_gne__c + 
                                                                 ',' + caseRecord.Id;
                    }

                    Set<String> zipCodeSet = frmBrandCodeToZipCodes.get(frmBrandCode);
                    if ( zipCodeSet == null ) {
                        zipCodeSet = new Set<String>();
                        frmBrandCodeToZipCodes.put(frmBrandCode, zipCodeSet);
                    }
                        zipCodeSet.add (caseRecord.zip_gne__c);                        
                } // for each account on case                 
            } // for each frm brand code mapping for case product
        } // for each case 
        
	        initializeFRMBrandCodeZipToTerritoryInfo(); // initialize FRM brand zip to territory info           
	        populateFRMAutoAlignZipToGroupId();         // populate frm auto align zip  to group Id
	        removeFRMAutoAlignForExistingAcctShare();   // remove FRM auto alignment for existing acct share entries    
	        upsertFRMAutoAlign();                       // upsert FRM Auto Align entries 
        } catch (Exception e) {        
            sendErrorEmail( BC, e );
        }
    }
    
    void sendErrorEmail (Database.BatchableContext BC, Exception e) {
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, ApexClass.Name, 
                          JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          from AsyncApexJob 
                          where Id =:BC.getJobId()
                          ];
        User createdUser         = a.CreatedBy;
        ApexClass batchApexClass = a.ApexClass;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {createdUser.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Job ' + batchApexClass.Name + ' Error Report');
        mail.setPlainTextBody (e.getTypeName() + '/'+ e.getMessage() + '\n' + 
                               'Total Job Items / Job Items Processed '+
                               a.TotalJobItems + '/'+ a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
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

    public Map<String, Set<String>> getProductToFRMMap() {
        initializeProductToFRMMap();
        return productToFRMMap;            
    }

}