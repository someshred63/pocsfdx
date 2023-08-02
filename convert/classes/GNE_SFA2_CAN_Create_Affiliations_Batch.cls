global class GNE_SFA2_CAN_Create_Affiliations_Batch implements Schedulable, Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Main_Address_gne__c,Main_Address_gne__r.Inactive_vod__c, Main_Address_gne__r.Id,Main_Address_gne__r.Status_gne__c, Main_Address_gne__r.City_vod__c, ' +
          'Main_Address_gne__r.Province_can_gne__c, Main_Address_gne__r.Postal_Code_can_gne__c, Main_Address_gne__r.Name, Account_Type_gne__c FROM Account WHERE isPersonAccount = true ' +
          'AND (Account_Type_gne__c IN (\'Physician\', \'Pharmacist\') OR Account_Type_gne__c LIKE \'%Nurse%\') AND Region_Code_gne__c = 2 AND Main_Address_gne__c <> null';

        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GNE_SFA2_CAN_Create_Affiliations_Batch(), 10);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Account> hcpAccounts = (List<Account>)scope;
        List<String> provinces = new List<String>();
        List<String> postalCodes = new List<String>();

        for(Account account : hcpAccounts) {
            provinces.add(account.Main_Address_gne__r.Province_can_gne__c);
            postalCodes.add(account.Main_Address_gne__r.Postal_Code_can_gne__c);
        }

        List<Account> hcoAccounts = [SELECT  Id, 
                                    Main_Address_gne__c, 
                                    Main_Address_gne__r.Id,
                                    Main_Address_gne__r.City_vod__c, 
                                    Main_Address_gne__r.Province_can_gne__c, 
                                    Main_Address_gne__r.Postal_Code_can_gne__c, 
                                    Main_Address_gne__r.Name,
                                    Main_Address_gne__r.Inactive_vod__c,
                                    Account_Type_gne__c
                                    FROM Account 
                                    WHERE isPersonAccount = false 
                                        AND Main_Address_gne__c <> null 
                                        AND Main_Address_gne__r.Province_can_gne__c IN :provinces
                                        AND Main_Address_gne__r.Postal_Code_can_gne__c IN :postalCodes
                                        AND Prim_IMS_Id_can__c <> null 
                                        AND (Account_Type_gne__c = 'Hospital' OR Account_Type_gne__c LIKE '%Pharmacy')
                                        AND Region_Code_gne__c = 2];

        List<Affiliation_vod__c> affiliationsToInsert = new List<Affiliation_vod__c>();
        for(Account hcpAccount : hcpAccounts) {
            for(Account hcoAccount : hcoAccounts) {
                if(isMatchForHospital(hcpAccount, hcoAccount) || isMatchForPharmacy(hcpAccount, hcoAccount)) {
                    if(GNE_SFA2_Address_Util.isAddressTheSame(hcpAccount.Main_Address_gne__r, hcoAccount.Main_Address_gne__r)) {
                        affiliationsToInsert.add(new Affiliation_vod__c(From_Account_vod__c=hcpAccount.Id, To_Account_vod__c=hcoAccount.Id, Role_vod__c = 'Affiliated with'));
                    }
                } 
            }
        }
        Database.insert(affiliationsToInsert, false);
    }

    global void finish(Database.BatchableContext BC) {

    }

    private Boolean isMatchForHospital(Account hcpAccount, Account hcoAccount) {
        return (hcpAccount.Account_Type_gne__c == 'Physician' || hcpAccount.Account_Type_gne__c.contains('Nurse')) && 
                hcoAccount.Account_Type_gne__c == 'Hospital';
    } 

    private Boolean isMatchForPharmacy(Account hcpAccount, Account hcoAccount) {
        return hcpAccount.Account_Type_gne__c == 'Pharmacist' && hcoAccount.Account_Type_gne__c.contains('Pharmacy');
    }
}