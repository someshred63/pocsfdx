public class GNE_SFA2_FRM_RemovingAccShareBatch implements Database.Batchable<sObject>,Database.Stateful{
    public Enum RemoveType {
        Territory,
        SelfSharing,
        TsfRemoving,
        CasesUpdate,
        ContactsUpdate,
        AccountsUpdate,
        UsersUpdate,
        RemoveGroupMembers,
        ROLLBACK_RemoveGroupMembers,
        changeOwnerNonFRMContact,
        changeOwnerNonFRMAccount,
        changeOwnerFRMAccount,
        changeOwnerFRMContact
    }
    private RemoveType typeToExecute;

    public GNE_SFA2_FRM_RemovingAccShareBatch(RemoveType rt){
        this.typeToExecute = rt;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(typeToExecute!= RemoveType.UsersUpdate)updateAdminSetings(true);
        Group[] groups =[
            SELECT Id from Group
            WHERE Type='Territory'
            AND RelatedId IN (
                SELECT Id
                FROM Territory2
                 WHERE (External_id_gne__c Like 'GNE-US;MCCO;FRM;_FRM%')
                    AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%')
             )
        ];
        String query =
            'SELECT Id, AccountId, Account.RecordType.Name, UserOrGroupId '+
            'FROM AccountShare '+
            'WHERE (RowCause = \'Territory\' or RowCause =\'Territory2AssociationManual\') '+
            'AND UserOrGroupId IN :groups '+
            'AND Account.IsPersonAccount = false '+
            'AND Account.RecordType.Name != \'FRM_HCO\'';


        String accountShare =
            'SELECT Id '+
            'FROM AccountShare '+
            'WHERE (RowCause = \'ImplicitParent\' OR RowCause = \'Manual\') '+
            'AND UserOrGroupId IN (SELECT Id FROM User WHERE profile.Name like \'GNE-MCCO-FRM-%\') '+
            'AND Account.RecordType.Name != \'FRM_HCO\' '+
            'AND Account.IsPersonAccount = false ';

        Set<String> terNames = new Set<String> ();

        for(Territory2 t : [SELECT Id, name, External_id_gne__c FROM Territory2 WHERE (External_id_gne__c Like 'GNE-US;MCCO;FRM;_FRM%')]){
            terNames.add(t.Name);
        }

        String removingTSF =
            'SELECT Id '+
            'FROM TSF_vod__c '+
            'WHERE Account_vod__r.RecordType.Name != \'FRM_HCO\' '+
            'AND Account_vod__r.IsPersonAccount = false '+
            'AND Territory_New_Name_gne__c IN : terNames';

        String updateCases = 'SELECT Id FROM Case WHERE OwnerId In (SELECT Id FROM User WHERE profile.Name like \'%GNE-MCCO-FRM-%\') ';

        String removeGroupMembers =
            'SELECT GroupId, UserOrGroupId, Group.Name '+
            'FROM GroupMember '+
            'WHERE UserOrGroupId IN (SELECT Id FROM User WHERE profile.Name like \'GNE-MCCO-FRM-_FRM%\' OR profile.Name = \'GNE-MCCO-FRM-OPS\' OR profile.Name like \'GNE-CRM%\') '+
            'AND Group.Name IN (\'PRF_GRP_US\',\'GNE-Data-Master\',\'GNE-TLS-Group\',\'GNE-ATLS-Maintenance\',\'GNE-ATLS-SpeakerBureauLeads\', '+
            '\'GNE-TLS-Clinical-Group\',\'GNE-TLS-Brand-Group\',\'GNE-TLS-TLL-Group\', \'GNE-CM-Group\')';

        String ROLLBACK_RemoveGroupMembersQuery =
            'SELECT GroupId, UserOrGroupId, Group.Name '+
            'FROM GroupMember '+
            'WHERE UserOrGroupId IN (SELECT Id FROM User WHERE profile.Name like \'GNE-MCCO-FRM-%\') '+
            'AND Group.Name IN (\'PRF_GRP_US_FRM\')';

        String updateContacts =
            'SELECT Id, OwnerId, Owner.Name '+
            'FROM Contact '+
            'WHERE OwnerId In ( SELECT Id FROM User WHERE profile.Name like \'GNE-MCCO-FRM-%\')';

        String updateAccounts =
            'SELECT Id, OwnerId '+
            'FROM Account '+
            'WHERE OwnerId IN ( SELECT Id  FROM User WHERE profile.Name like \'GNE-MCCO-FRM-%\') '+
            'AND Account.RecordType.Name != \'FRM_HCO\' '+
            'AND  Account.RecordType.Name != \'Professional_vod\' '+
            'AND IsPersonAccount = false';

        String updateUsers = 'SELECT id, name,userRole.Name, isactive, profile.name FROM User '+
                            'WHERE Id  not In (SELECT UserOrGroupId FROM GroupMember WHERE  Group.Name = \'PRF_GRP_US_FRM\') '+
                            'AND profile.Name like \'GNE-MCCO-FRM-%\'';
                            
        String changeOwnerNonFRMContactQuery = 'SELECT Id, Account.OwnerId, OwnerId '+
           'FROM Contact WHERE OwnerId IN (SELECT Id FROM User WHERE profile.Name like \'GNE-MCCO-FRM%\' OR profile.Name like \'GNE-CRM%\') '+
           'AND Account.IsPersonAccount = false AND Account.RecordType.Name != \'FRM_HCO\' ';
           
        String changeOwnerFRMContactQuery = 'SELECT Id, Account.OwnerId, OwnerId '+
           'FROM Contact WHERE OwnerId IN (SELECT Id FROM User WHERE ( (NOT profile.Name like \'GNE-MCCO-FRM%\') AND (NOT profile.Name like \'GNE-CRM%\'))) '+
           'AND Account.IsPersonAccount = false AND Account.RecordType.Name = \'FRM_HCO\' ';
           
        String changeOwnerFRMAccountQuery = 'SELECT Id, Name, Owner.name, OwnerId '+
            'FROM Account WHERE OwnerId IN (SELECT Id FROM User WHERE (NOT profile.Name like \'GNE-MCCO-FRM%\') AND (NOT profile.Name like \'GNE-CRM%\')) '+
            'AND IsPersonAccount = false '+
            'AND RecordType.Name = \'FRM_HCO\' LIMIT 1';

        String queryToExecute = '';
        if(typeToExecute == RemoveType.Territory){
            queryToExecute = query;
        } else if(typeToExecute == RemoveType.SelfSharing){
            queryToExecute = accountShare;
        } else if(typeToExecute == RemoveType.TsfRemoving){
            queryToExecute = removingTSF;
        } else if(typeToExecute == RemoveType.CasesUpdate){
            queryToExecute = updateCases;
        } else if(typeToExecute == RemoveType.RemoveGroupMembers){
            queryToExecute = removeGroupMembers;
        }  else if(typeToExecute == RemoveType.ContactsUpdate){
            queryToExecute = updateContacts;
        } else if(typeToExecute == RemoveType.AccountsUpdate){
            queryToExecute = updateAccounts;
        } else if(typeToExecute == RemoveType.UsersUpdate){
            queryToExecute = updateUsers;
        } else if(typeToExecute == RemoveType.ROLLBACK_RemoveGroupMembers ){
            queryToExecute = ROLLBACK_RemoveGroupMembersQuery;
        } else if(typeToExecute == RemoveType.changeOwnerFRMContact ){
            queryToExecute = changeOwnerFRMContactQuery;
        } else if(typeToExecute == RemoveType.changeOwnerNonFRMContact ){
            queryToExecute = changeOwnerNonFRMContactQuery;
        } else if(typeToExecute == RemoveType.changeOwnerFRMAccount ){
            queryToExecute = changeOwnerFRMAccountQuery;
        }  else {
            return null;
        }
        return Database.getQueryLocator(queryToExecute);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(typeToExecute == RemoveType.UsersUpdate){
            //upsertRecords(scope);
            update scope;
        } else if(typeToExecute == RemoveType.CasesUpdate){
            Id userId =[SELECT Id, name FROM User WHERE Name = 'ETL Admin' LIMIT 1].Id;

            for(Case c: (List<Case>)scope){
                c.OwnerId = userId;
            }

            upsertRecords(scope);

        } else if(typeToExecute == RemoveType.ContactsUpdate){
            Id userId =[SELECT Id, name FROM User WHERE Name = 'ETL Admin' LIMIT 1].Id;

            for(Contact c: (List<Contact>)scope){
                c.OwnerId = userId;
            }

            upsertRecords(scope);

        } else if(typeToExecute == RemoveType.AccountsUpdate){

            Id userId =[SELECT Id, name FROM User WHERE Name = 'ETL Admin' LIMIT 1].Id;

            for(Account a: (List<Account>)scope){
                a.OwnerId = userId;
            }

            upsertRecords(scope);

        } else if(typeToExecute == RemoveType.changeOwnerNonFRMContact || typeToExecute == RemoveType.changeOwnerFRMContact){
            for(Contact c :(List<Contact>)scope){
               c.OwnerId = c.Account.OwnerId;
            }
            upsertRecords(scope);
        } else if(typeToExecute == RemoveType.changeOwnerNonFRMContact || typeToExecute == RemoveType.changeOwnerFRMContact){
            Id userId =[SELECT Id, name FROM User WHERE Name = 'FRM Admin User' LIMIT 1].Id;
            for(Account a: (List<Account>)scope){
               a.OwnerId = userId;
            }
            upsertRecords(scope);
        } else if(typeToExecute == RemoveType.Territory) {
            Set<Id> accountIds = new Set<Id>();
            Set<Id> groupsToProcess = new Set<Id>();
            Map<Id,Set<Id>> group2account = new Map<Id,Set<Id>>();
            for(AccountShare ash : (AccountShare[]) scope) {
                System.debug(ash.AccountId + ' '+ash.Account.RecordType.Name + ' > '+ash.UserOrGroupId);
                accountIds.add(ash.AccountId);
                groupsToProcess.add(ash.UserOrGroupId);
                Set<Id> nSet;
                if(group2account.get(ash.AccountId) == null){
                    nSet = new Set<Id>();
                } else {
                    nSet = group2account.get(ash.AccountId);
                }
                nSet.add(ash.UserOrGroupId);
                group2account.put(ash.AccountId,nSet);
                
            }
            
            Map<Id,Group> id2group = new Map <Id,Group>(
                [SELECT Id, RelatedId FROM Group WHERE Id IN:groupsToProcess]
            );
            Set<String>keysToRemove = new Set<String>();
            for(Id accId :group2account.keySet()){
                System.debug(accId + ' '+group2account.get(accId));
                for(Id gId : group2account.get(accId)){
                    if(id2group.get(gId) !=null){
                        keysToRemove.add(accId+'_'+id2group.get(gId).RelatedId);
                    }        
                }    
            }
            
            ObjectTerritory2Association [] toDelete = new ObjectTerritory2Association[]{};
            
            for(ObjectTerritory2Association ot2a :[
                SELECT Id,  ObjectId, Territory2Id, Territory2.Name
                FROM ObjectTerritory2Association
                WHERE ObjectId IN : accountIds
            ]) {
                String key = ot2a.ObjectId +'_'+ot2a.Territory2Id;
                System.debug(key); 
                if(keysToRemove.contains(key)){
                    toDelete.add(ot2a);
                    System.debug(ot2a.Territory2.Name);
                }
            }
            System.debug(toDelete.size());
            
            delete toDelete;            
        } else {
            Database.DeleteResult [] results = Database.delete(scope, false);
            for(Database.DeleteResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        String error = 'The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage()+'. Fields that affected this error: ' + err.getFields();
                        System.debug(error);
                    }
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        updateAdminSetings(false);
    }

    private void upsertRecords(List<sObject> scope) {
        Database.UpsertResult [] results = Database.upsert(scope, false);
        for(Database.UpsertResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    String error = 'The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage()+'. Fields that affected this error: ' + err.getFields();
                    System.debug(error);
                }
            }
        }
    }

    private void updateAdminSetings(Boolean adminMode) {
        List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [
            SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c
            FROM GNE_SFA2_Admin_Mode__c
            WHERE SetupOwnerId =: UserInfo.getUserId()  LIMIT 1
        ];

        if (adminModeSetting.isEmpty()) {
            insert new GNE_SFA2_Admin_Mode__c(SetupOwnerId = UserInfo.getUserId() , GNE_SFA2_Is_Admin_Mode__c = adminMode);
        } else {
            if(adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c != adminMode){
                adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c = adminMode;
                update adminModeSetting;
            }
        }
    }
}