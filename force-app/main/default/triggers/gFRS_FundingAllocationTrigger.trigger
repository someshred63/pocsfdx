trigger gFRS_FundingAllocationTrigger on GFRS_Funding_Allocation__c (after insert, before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {

        final GFRS_Funding_Allocation__c[] items = new GFRS_Funding_Allocation__c[]{ };
        final Map<Id, GFRS_Funding_Request__c> requests = new Map<Id, GFRS_Funding_Request__c>();

        for (GFRS_Funding_Allocation__c item : Trigger.new) {
            if(Trigger.isInsert || (item.GL_Account_ref__c != Trigger.oldMap.get(item.Id).GL_Account_ref__c) &&
                    item.Grant_Request__c != null) {
                requests.put(item.Grant_Request__c, new GFRS_Funding_Request__c());
                items.add(item);
            }
        }
        requests.remove(null);

        if(Trigger.isInsert) {
            /* populate default values for GL_Account_ref__c */

            requests.putAll([
                SELECT Record_Type_Name__c FROM GFRS_Funding_Request__c
                WHERE Id IN :requests.keySet() LIMIT :requests.size()
            ]);

            final Map<String, Id> accs = new Map<String, Id>();

            for (GFRS_Funding_Allocation__c item : items) {
                if(requests.containsKey(item.Grant_Request__c)) {
                    if(GFRS_Util.DEF_GL_ACCS_BY_TYPE.containsKey(requests.get(item.Grant_Request__c).Record_Type_Name__c)) {
                        item.GL_Account__c = GFRS_Util.DEF_GL_ACCS_BY_TYPE.get(requests.get(item.Grant_Request__c).Record_Type_Name__c);
                        accs.put(item.GL_Account__c, null);
                    } else {
                        item.GL_Account__c = null;
                    }
                }
            }
            accs.remove(null);
            for(GFRS_GL_Account__c acc : [
                SELECT Name
                FROM GFRS_GL_Account__c
                WHERE Name IN :accs.keySet()
                LIMIT :accs.size()
            ]) {
                accs.put(acc.Name, acc.Id);
            }
            for(GFRS_Funding_Allocation__c item : items) {
                if(item.GL_Account__c != null)
                    item.GL_Account_ref__c = accs.get(item.GL_Account__c);
            }
        }

        if(Trigger.isUpdate) {
            /* check for GL_Account_ref__c change and update GL_Account__c accordingly */

            final Map<Id, String> accs = new Map<Id, String>();

            for(GFRS_Funding_Allocation__c item : items) {
                if (item.GL_Account_ref__c == null)
                    item.GL_Account__c = null;
                else {
                    accs.put(item.GL_Account_ref__c, null);
                }
            }
            accs.remove(null);
            for(GFRS_GL_Account__c acc : [
                SELECT Name
                FROM GFRS_GL_Account__c
                WHERE Id IN :accs.keySet()
                LIMIT :accs.size()
            ]) {
                accs.put(acc.Id, acc.Name);
            }
            for(GFRS_Funding_Allocation__c item : items) {
                if(item.GL_Account_ref__c != null)
                    item.GL_Account__c = accs.get(item.GL_Account_ref__c);
            }
        }
    } else
    // SFDC-1996: New Payment/Refund Processing
    if(Trigger.isAfter && Trigger.isInsert) {
        ((gFRS_FundingProcess) Type.forName('gFRS_PaymentProcess').newInstance()).createDefaultFALineItems(Trigger.new);
    }
}