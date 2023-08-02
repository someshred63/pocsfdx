global class QuestionnaireAccounts_for_CFT_FRM implements Database.Batchable<sObject> 
{
    global String accountType;
    global String questID;
    global String mode;
    global String query; 
    List<Error_log_gne__c> errorLogList = new List<Error_log_gne__c>();
    
    global QuestionnaireAccounts_for_CFT_FRM(String questID, String mode, String accountType, List<String> TerNamesSt)
    {
        this.accountType = accountType;
        this.questID = questID;
        this.mode = mode;
        this.query = query;
        
        query = 'Select Account_vod__c ' + 'From TSF_vod__c ' + 'Where Territory_vod__c IN (';
        for(String s :TerNamesSt)
        {
            query = query + '\'' + s + '\',';
        }
        query = query.substring(0, query.length()-1);
        query = query + ') '; 
        if(AccountType == 'FRM' && Mode == 'Target')
        {
            query = query + ' AND Account_vod__r.FRM_Target_frm_gne__c != null';
        }
        query = query + ' AND Account_vod__c NOT IN (select Account__c from QuestionnaireAccount_gne__c' + 
        ' where Questionnaire_gne__c = \'' + questID + '\')';
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<TSF_vod__c> tsfs = (List<TSF_vod__c>)scope;
        List<QuestionnaireAccount_gne__c> toInsert = new List<QuestionnaireAccount_gne__c>();
        Set<QuestionnaireAccount_gne__c> toUpsert = new Set<QuestionnaireAccount_gne__c>();
        
        Schema.SObjectField extIdField = QuestionnaireAccount_gne__c.Fields.Questionnaire_Account_ExKey_gne__c  ;
        
        for(TSF_vod__c tsf : tsfs){
          toUpsert.add(new QuestionnaireAccount_gne__c(Account__c = tsf.Account_vod__c, Questionnaire_gne__c = questID, Questionnaire_Account_ExKey_gne__c = tsf.Account_vod__c + '_' + questID));  
        }
        
        toInsert = new List<QuestionnaireAccount_gne__c>(toUpsert);
        List<Database.Saveresult> result;
        Database.UpsertResult[] lur = Database.upsert(toInsert, extIdField, false);
        for(Database.UpsertResult ur : lur)
        {
            if(!ur.isSuccess())
            {
                Database.Error err = ur.getErrors()[0];
                System.debug('***error*** ' + err.getMessage());
                addEntryToErrorLog(err.getMessage());
            }
        }
        if (errorLogList.size() > 0) 
            insert errorLogList;
    }       

    global void finish(Database.BatchableContext BC)
    {
        
    }

    private void addEntryToErrorLog(String sErrorDescription) 
    { 
        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Medium',
        Code_Type__c = 'Apex Class',
        Snippet_Name__c = 'QuestionnaireAccounts_for_CFT_FRM',
        User_Name__c = UserInfo.getUserName(),
        Object_Name__c = 'QuestionnaireAccount_gne__c', 
        Error_Description__c = sErrorDescription
        ));
    }

}