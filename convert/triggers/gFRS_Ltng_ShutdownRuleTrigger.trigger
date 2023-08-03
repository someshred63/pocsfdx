trigger gFRS_Ltng_ShutdownRuleTrigger on gFRS2_0_Shutdown_Rule__c (before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        Map<Id, gFRS2_0_Shutdown_Rule__c> shutdownRuleMap = new Map<Id, gFRS2_0_Shutdown_Rule__c>([SELECT Id, Start_date__c, End_date__c, Funding_type__c FROM gFRS2_0_Shutdown_Rule__c WHERE Active__c = true]);
        for(gFRS2_0_Shutdown_Rule__c sr : Trigger.new) {
            if(sr.End_date__c < sr.Start_date__c) {
                sr.End_date__c.addError(System.Label.Shutdown_End_Date);
            }
            Set<String> tempFundingTypes = new Set<String>(sr.Funding_type__c.split(';'));
            for(Id key : shutdownRuleMap.keySet()) {
                if(sr.Active__c == true && sr.Id != key) {
                    gFRS2_0_Shutdown_Rule__c existingSR = shutdownRuleMap.get(key);
                    Set<String> fundingTypes = new Set<String>(existingSR.Funding_type__c.split(';'));
                    for(String ft : tempFundingTypes) {
                        if(fundingTypes.contains(ft)) {
                            if((sr.Start_date__c <= existingSR.Start_date__c && sr.End_date__c <= existingSR.End_date__c && sr.End_date__c >= existingSR.Start_date__c)
                                    || (sr.Start_date__c <= existingSR.Start_date__c && sr.End_date__c >= existingSR.End_date__c)
                                    || (sr.Start_date__c >= existingSR.Start_date__c && sr.End_date__c >= existingSR.End_date__c && sr.Start_date__c <= existingSR.End_date__c)) {
                                sr.addError(System.Label.Shutdown_Message);
                            }
                        }
                    }
                }
            }
        }
    }

}