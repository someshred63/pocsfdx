public class GNE_Merge_UI_Controller {

    String  recordId     = null;
    String  actionType   = 'Winner';
    String  objectName   = null;
    Id batchInstanceId    = null;
    Id previousInstanceId = null;
    
    String accountSQL           = 'select id, dch_action_gne__c, dch_approval_status_gne__c,ispersonaccount ' + 
                                   'from account ' + 
                                   'where dch_action_date_gne__c = null and ' +
                                   'dch_parent_id_gne__c = null and ' + 
                                   '(dch_action_gne__c = :actionType ) and  ' +  
                                   'id = :recordId ';

    String addressSQL           = 'select id, dch_action_gne__c, dch_approval_status_gne__c ' + 
                                   'from address_vod__c ' + 
                                   'where dch_action_date_gne__c = null and ' +
                                   'dch_parent_id_gne__c = null and ' + 
                                   '(dch_action_gne__c = :actionType ) and  ' +  
                                   'id = :recordId ';
    
    boolean bShowMergeButton = false;

    void runMerge (Boolean bCheckMode) {
        if ( recordId != null && bShowMergeButton ) {
            Set<String> parentIdSet = new Set<String>();
            parentIdSet.add ( recordId );
            
            if ( objectName.equalsIgnoreCase('Account') ) {
                batchInstanceId = database.executeBatch(new GNE_Merge_Batch_OrgAccount(bCheckMode, parentIdSet),1);
            } else if ( objectName.equalsIgnoreCase('PersonAccount') ) {
                batchInstanceId = database.executeBatch(new GNE_Merge_Batch_PersonAccount(bCheckMode, parentIdSet),1);
            } else if ( objectName.equalsIgnoreCase('Address_vod__c') ) {
                batchInstanceId = database.executeBatch(new GNE_Merge_Batch_Address(bCheckMode, parentIdSet),1);
            }            
            
            previousInstanceId = batchInstanceId;          
        }           
    }
    
    public void CallMergeInCheckMode () {    
        runMerge(True);        
    }
    
    public void CallMerge () {
        runMerge(False);    
    }
    
    public boolean getEnableMergeButton() {
        init();
        boolean bRunning = isRunning();
        return ( (bShowMergeButton == true ) && (bRunning == false) )  ;
    }

    public PageReference checkMergeStatus() {
        /*
        if ( previousInstanceId != null && batchInstanceId == null ) {
        	previousInstanceId = null;    	
	        PageReference recordPage = new PageReference ('/' + recordId ); 
	        recordPage.setRedirect(true);
	        return recordPage;
        }
        */
        return null;        
    }

    public boolean getIsMergeComplete() {
        Boolean bComplete = false;
        if ( previousInstanceId != null && batchInstanceId == null ) {
            bComplete = true;       
        }
        return bComplete;
    }
    
    public boolean getIsMergeInProgress() {
        Boolean bInProgress = false;
        if ( batchInstanceId != null ) 
            bInProgress = true;
        return bInProgress;              	
    }

    public GNE_Merge_UI_Controller(ApexPages.StandardController stdController) {       
        SObject sobjectInstance = stdController.getRecord();
        recordId                = (String) sobjectInstance.get('Id');
        String sql              = null;

        /* commented need to review why the account.sobjectype does not work
           very strange - 04/05/2010 guruk

            if (sobjectInstance.getSObjectType() ==  Account.sObjectType) {
                objectName = 'Account';
            } if (sobjectInstance.getSObjectType() == Address_vod__c.sObjectType) {
                objectName = 'Address_vod__c';
            } else {
                objectName = 'Not supported';   
            }
        */
    }


    boolean isRunning () {
        Boolean bRunning = false;
        if ( batchInstanceId != null ) {
            AsyncApexJob[] asyncApexJobList = [Select Id, Status, NumberOfErrors, 
                                               JobItemsProcessed, TotalJobItems,  
                                               ApexClass.Name 
                                               from AsyncApexJob 
                                               where id = :batchInstanceId and 
                                                     status in ('Processing','Queued') ];
            if ( asyncApexJobList.size() > 0 )      {
                bRunning = true;
            } else {
               previousInstanceId = batchInstanceId;
               batchInstanceId = null;
            }        
        }
        System.debug (LoggingLevel.INFO, 'IsRunning return value --> ' + bRunning);
        return bRunning;                  
    }


    void init () {
        String sql = null;
        if ( recordId.startsWith('001') ) {
            objectName = 'Account'; 
            sql        = accountSQL;
        } else {
            objectName ='Address_vod__c';
            sql        = addressSQL;    
        }
        
        try {
            System.debug (LoggingLevel.INFO, 'sql query--> ' + sql );
            System.debug (LoggingLevel.INFO, 'Action Type / Object Name / Record Id --> ' + 
                          actionType + '/' + objectName + '/' + recordId);
                          
            SObject parentRecord = Database.query (sql);
             
            String approvalStatus = (String ) 
                           parentRecord.get('dch_approval_status_gne__c');

            if ( approvalStatus != null && 
                 (approvalStatus.equalsIgnoreCase ('Approved' ) || 
                  approvalStatus.equalsIgnoreCase ('Default Approval')
                 )
               ) {                         
                bShowMergeButton = true;
                System.debug (LoggingLevel.INFO, 'bShowMergeButton is set to true.');
                
                // for person account merges
                if ( objectName.equalsIgnoreCase ('Account') ) {
                    Boolean isPersonAccount = (Boolean ) parentRecord.get('isPersonAccount');
                    if ( isPersonAccount ) 
                        objectName = 'PersonAccount';
                }                    
            }
        } catch (Exception e) {
            bShowMergeButton = false;
            System.debug ( LoggingLevel.INFO, e.getMessage() );
            //ApexPages.addMessages(e);           
        }
    }            

}