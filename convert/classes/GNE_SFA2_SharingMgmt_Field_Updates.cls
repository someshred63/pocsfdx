/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-07-12
*  Description: This is a class used for performing necessary field updates on Sharing_Mgmt_gne__c object invoked by GNE_SFA2_SharingMgmt_Trigger
*
*  Modification History
*  Date        Name        Description
*  2012-08-10  kwiatkol    Added more descriptive error messages
*  2012-08-10  kwiatkol    Changed User name field expected value from User name (first name + last name) to Username field
*  2012-08-16  kwiatkol    Changed CaseShare field update logic to update User name field instead of User id field
*  2012-10-05  kwiatkol    Updated AccountShare logic to update MDM Id field if Account Id field is provided
*  2012-10-15  kwiaktol    Added inserting AccountShares with User Id specified
*************************************************************/

public without sharing class GNE_SFA2_SharingMgmt_Field_Updates {
    public static void onBeforeInsertUpdate(List<Sharing_Mgmt_gne__c> triggerOld, List<Sharing_Mgmt_gne__c> triggerNew) {

        // define sets necessary to perform field updates
        Set<String> extIdsSet = new Set<String>();
        Set<String> terrNamesSet = new Set<String>();
        Set<String> userIdsSet = new Set<String>();
        Set<String> accountIdsSet = new Set<String>();

        // gather required data
        for(Sharing_Mgmt_gne__c shareMgmt : triggerNew) {
            if(shareMgmt.External_Id_gne__c != null && shareMgmt.External_Id_gne__c != '') {
                extIdsSet.add(shareMgmt.External_Id_gne__c);
            }
            if(shareMgmt.Territory_Name_gne__c != null && shareMgmt.Territory_Name_gne__c != '') {
                terrNamesSet.add(shareMgmt.Territory_Name_gne__c);
            }
            if(shareMgmt.User_Id_gne__c != null && shareMgmt.User_Id_gne__c != '') {
                userIdsSet.add(shareMgmt.User_Id_gne__c);
            }

            if(shareMgmt.Account_Id_gne__c != null) {
                accountIdsSet.add(shareMgmt.Account_Id_gne__c);
            }
        }

        // query for necessary ids
        Map<String, Account> externalIdToAccountMap = new Map<String, Account>();
        for(Account acc : [ SELECT MDMID_gne__c, Id, Name FROM Account WHERE MDMID_gne__c in :extIdsSet ]) {
            externalIdToAccountMap.put(acc.MDMID_gne__c, acc);
        }

        Map<String, Account> accountIdToAccountMap = new Map<String, Account>();
        for(Account acc : [ SELECT MDMID_gne__c, Id, Name FROM Account WHERE Id in :accountIdsSet ]) {
            accountIdToAccountMap.put(acc.Id, acc);
        }

        Map<String, Case> externalIdToCaseMap = new Map<String, Case>();
        for(Case c : [ SELECT CaseNumber, Id FROM Case WHERE CaseNumber in :extIdsSet ]) {
            externalIdToCaseMap.put(c.CaseNumber, c);
        }

        Map<String, Territory2> terrNameToIdMap = new Map<String, Territory2>();
        for(Territory2 terr : [ SELECT Name, Id FROM Territory2 WHERE Name in :terrNamesSet ]) {
            terrNameToIdMap.put(terr.Name, terr);
        }

        Map<String, User> userIdToNameMap = new Map<String, User>();
        for(User usr : [ SELECT Username, Id FROM User WHERE Id in :userIdsSet ]) {
            userIdToNameMap.put(usr.Id, usr);
        }

        // perform field updates
        for(Sharing_Mgmt_gne__c shareMgmt : triggerNew) {
            if(shareMgmt.Object_Name_gne__c == 'AccountShare') {
                if(externalIdToAccountMap.containsKey(shareMgmt.External_Id_gne__c) && (terrNameToIdMap.containsKey(shareMgmt.Territory_Name_gne__c) || userIdToNameMap.containsKey(shareMgmt.User_Id_gne__c))) {
                    shareMgmt.Account_Id_gne__c = externalIdToAccountMap.get(shareMgmt.External_Id_gne__c).Id;
                    shareMgmt.Reference_Name_gne__c = externalIdToAccountMap.get(shareMgmt.External_Id_gne__c).Name;
                    if(terrNameToIdMap.containsKey(shareMgmt.Territory_Name_gne__c) && shareMgmt.Territory_Id_gne__c==null) {
                        shareMgmt.Territory_Id_gne__c = terrNameToIdMap.get(shareMgmt.Territory_Name_gne__c).Id;
                    }

                } else if(accountIdToAccountMap.containsKey(shareMgmt.Account_Id_gne__c) && (terrNameToIdMap.containsKey(shareMgmt.Territory_Name_gne__c) || userIdToNameMap.containsKey(shareMgmt.User_Id_gne__c))){
                    shareMgmt.External_Id_gne__c = accountIdToAccountMap.get(shareMgmt.Account_Id_gne__c).MDMID_gne__c;
                    shareMgmt.Reference_Name_gne__c = accountIdToAccountMap.get(shareMgmt.Account_Id_gne__c).Name;
                    if(terrNameToIdMap.containsKey(shareMgmt.Territory_Name_gne__c) && shareMgmt.Territory_Id_gne__c==null) {
                        shareMgmt.Territory_Id_gne__c = terrNameToIdMap.get(shareMgmt.Territory_Name_gne__c).Id;
                    }
                } else {
                    shareMgmt.Status_gne__c = 'Error';
                    shareMgmt.Comments_gne__c = System.Label.Account_Territory_User_Not_Exists;
                    // To be defined
                }
            } else if(shareMgmt.Object_Name_gne__c == 'CaseShare') {
                if(externalIdToCaseMap.containsKey(shareMgmt.External_Id_gne__c) && userIdToNameMap.containsKey(shareMgmt.User_Id_gne__c)) {
                    shareMgmt.Case_Id_gne__c = externalIdToCaseMap.get(shareMgmt.External_Id_gne__c).Id;
                    sharemgmt.User_Name_gne__c = userIdToNameMap.get(shareMgmt.User_Id_gne__c).Username;
                } else {
                    shareMgmt.Status_gne__c = 'Error';
                    shareMgmt.Comments_gne__c = System.Label.User_Case_Not_Exists;
                    // To be defined
                }
            }
        }
    }
}