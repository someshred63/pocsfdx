trigger GFRS_GLAccountTrigger on GFRS_GL_Account__c (before update, before insert) {

    List<GFRS_GL_Account__c> allGlAccounts = [
            SELECT
                    Id,
                    Name
            FROM GFRS_GL_Account__c
    ];

    for (GFRS_GL_Account__c acc : Trigger.new) {
        if (Trigger.isInsert) {
            if (gFRS_Util_NoShare.checkByNameIfGLAccountExist(acc.Name, allGlAccounts)) {
                System.debug(LoggingLevel.ERROR, Label.gFRS_ERROR_GL_ACCOUNT_DUPLICATED);
                acc.addError(Label.gFRS_ERROR_GL_ACCOUNT_DUPLICATED);
            }
        }
        acc.sfdc_Associated_Funding_Types__c = acc.FundingTypes__c;
    }
}