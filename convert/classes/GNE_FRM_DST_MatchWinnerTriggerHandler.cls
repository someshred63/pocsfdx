public class GNE_FRM_DST_MatchWinnerTriggerHandler {
    public static void populateFields() {
        Set<Id> looserAccounts = new Set<Id>();
        Map<String, Account> id2Account = fetchAccounts(looserAccounts);
        Map<Id, Id> accountId2DST_LoserId = fetchDSTLosers(looserAccounts);
        for(DST_Match_Winner__c winner : (DST_Match_Winner__c[])Trigger.new){
            if(isRecordApplicable(winner)){
                populateFieldsOnRecord(winner, id2Account, accountId2DST_LoserId);
            }
        }
    }
    
    private static Boolean isRecordApplicable(DST_Match_Winner__c newRecord) {
        Boolean result = false;
        if (Trigger.isInsert){
            result =  true;
        } else if (Trigger.isUpdate){
            DST_Match_Winner__c oldRecord = (DST_Match_Winner__c)Trigger.OldMap.get(newRecord.Id);
            result = checkConditionsForUpdate(oldRecord, newRecord);
        }
        
        return result;
    }
    
    /*
     * execute only if someone change reference to Account
     * This prevent clean up fields when we merge Account (looser will be removed from system and lookup field will becomes null)
     * In next impelementation we will add logic to handle scenarios for statuses
     */ 
    private static Boolean checkConditionsForUpdate(DST_Match_Winner__c oldRecord, DST_Match_Winner__c newRecord) {
        return oldRecord.Match_Winner_SfdcId__c != newRecord.Match_Winner_SfdcId__c &&
            newRecord.Match_Winner_SfdcId__c != null; 
    }
    
    private static Map<String, Account> fetchAccounts(Set<Id> looserAccounts) {
        Set<Id> accIds = new Set<Id>();
        for(DST_Match_Winner__c winner : (DST_Match_Winner__c[])Trigger.new){
            if(winner.Match_Winner_SfdcId__c != null ){
                accIds.add(winner.Match_Winner_SfdcId__c);
            }
            if(String.isNotBlank(winner.Match_Loser_Account_SfdcId__c)){
                looserAccounts.add(winner.Match_Loser_Account_SfdcId__c);
            }
        }
        
        String query = 'SELECT Id, MDMID_gne__c, CreatedBy.Name, LastModifiedBy.Name, Account_Type_gne__c, '+
            'RecordType.Name, Name, Group_Name_gne__c, '+
            '(SELECT Name, City_vod__c, State_vod__c, Zip_vod__c, Address_line_2_vod__c FROM Address_vod__r LIMIT 1) '+
            'FROM Account '+
            'WHERE Id IN : accIds ';
        Map<String, Account> result =  new Map<String, Account>();

        try{
            for(Account acc :Database.query(query)){
                result.put(acc.Id, acc);
            }
        } catch(Exception ex){
            System.debug(ex.getMessage());
            Trigger.new[0].addError('Database error: '+ex.getTypeName() + '. Please, report this issue to administrator.');
        }

        return result;
    }
    
    private static Map<Id, Id> fetchDSTLosers(Set<Id> looserAccounts){
        Map<Id, Id> result = new Map<Id, Id> ();
        String query = 'SELECT Id, Match_Loser_Account_SfdcId__c '+
            'FROM DST_Match_Loser__c '+
            'WHERE Match_Loser_Account_SfdcId__c IN :looserAccounts '+
            '    AND Is_Open_gne__c = true';
        
        try{
            for(DST_Match_Loser__c loser :Database.query(query)){
                result.put(loser.Match_Loser_Account_SfdcId__c, loser.Id);
            }
        } catch(Exception ex){
            System.debug(ex.getMessage());
            Trigger.new[0].addError('Database error: '+ex.getTypeName() + '. Please, report this issue to administrator.');
        }
        
        return result;
    }
    
    private static void populateFieldsOnRecord(DST_Match_Winner__c winner, Map<String, Account> id2Account, Map<Id, Id> accountId2DST_LoserId) {
        Account acc = id2Account.get(winner.Match_Winner_SfdcId__c) != null ? id2Account.get(winner.Match_Winner_SfdcId__c) : null;
        if(acc == null) return;
        Address_vod__c address = acc.Address_vod__r.isEmpty() ? new Address_vod__c() : acc.Address_vod__r[0];
        if(Trigger.isInsert)winner.Match_Loser__c = winner.Match_Loser__c == null ? fetchDST_LoserId(accountId2DST_LoserId, winner) : winner.Match_Loser__c;
        winner.Match_Winner_MdmId__c              = acc.MDMID_gne__c;
        winner.Match_Winner_Text_SfdcId__c        = acc.Id;
        winner.Account_Group_gne__c               = acc.Group_Name_gne__c;
        winner.Winner_Accnt_Created_By__c         = acc.CreatedBy.Name;
        winner.Winner_Accnt_Last_Modified_By__c   = acc.LastModifiedBy.Name;
        winner.Match_Winner_Name__c               = acc.Name;
        winner.Match_Winner_Accnt_Rec_Type__c     = acc.RecordType.Name;
        winner.Match_Winner_Accnt_Type__c         = acc.Account_Type_gne__c;
        winner.Match_Winner_State__c              = address.State_vod__c;
        winner.Match_Winner_Zip_Code__c           = address.Zip_vod__c;
        winner.Match_Winner_Address1__c           = address.Name;
        winner.Match_Winner_Address2__c           = address.Address_line_2_vod__c;
        winner.Match_Winner_City__c               = address.City_vod__c;      
        winner.Match_Winner_Address_SfdcId_gne__c = address.Id == null ? null : address.Id;
    }
    
    private static Id fetchDST_LoserId(Map<Id, Id> accountId2DST_LoserId, DST_Match_Winner__c winner){
        return accountId2DST_LoserId.get(winner.Match_Loser_Account_SfdcId__c) == null ? null : accountId2DST_LoserId.get(winner.Match_Loser_Account_SfdcId__c);
    }
}