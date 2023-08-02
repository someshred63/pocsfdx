/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-07-20
*  Description: This is a batch process used for Sharing Management
*    
*  Modification History
*  Date        Name        Description
*************************************************************/

global class GNE_SFA2_SharingMgmt_Batch implements Database.Batchable<sObject> {
    
    private String query = 'SELECT Object_Name_gne__c, External_Id_gne__c, Operation_gne__c, Schedule_Date_Time_gne__c, '
                                        + 'Status_gne__c, Territory_Name_gne__c, User_Name_gne__c, User_Id_gne__c, '
                                        + 'Case_Access_Level_gne__c, Account_Access_Level_gne__c, Opportunity_Access_Level_gne__c, ' 
                                        + 'Account_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Status_gne__c = \'New\'';
    
    
   public GNE_SFA2_SharingMgmt_Batch() {
   }
   
   public GNE_SFA2_SharingMgmt_Batch(String queryLimit) {
        query += queryLimit;
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Sharing Management batch started.');

        return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Sharing_Mgmt_gne__c> validShareMgmts = new List<Sharing_Mgmt_gne__c>();
        List<Sharing_Mgmt_gne__c> inValidShareMgmts = new List<Sharing_Mgmt_gne__c>();
        
        // validate data
        for(Sharing_Mgmt_gne__c shareMgmt : (List<Sharing_Mgmt_gne__c>) scope) {
            if(GNE_SFA2_SharingMgmt_Validation_Rules.isValidSharingMgmt(shareMgmt)) {
                validShareMgmts.add(shareMgmt);
            } else {
                shareMgmt.Status_gne__c = 'Error';
                shareMgmt.Comments_gne__c = System.Label.GNE_SFA2_ErrorMsg_ALL_Required_Fields;
                inValidShareMgmts.add(shareMgmt);
            }
        }
        // perform necessary field updates
        GNE_SFA2_SharingMgmt_Field_Updates.onBeforeInsertUpdate(null, validShareMgmts);
        // insert AccountShares and CaseShares
        GNE_SFA2_SharingMgmt_Child_Record_Update.onAfterInsertUpdate(validShareMgmts);

        // save all changes to Sharing Management records
        update validShareMgmts;  
        update inValidShareMgmts;
    }

   global void finish(Database.BatchableContext BC){
        System.debug('Sharing Management batch finished.');
   }
}