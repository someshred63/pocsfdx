/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-03
*  Description: This is a helper class for handling Address child record updates
*  Test class: GNE_SFA2_Address_Trigger_Test
*  
*  Modification History
*  Date        Name                 Description
*  2014-01-23  Marta Malinowska     Change the way to call update in method updateSobjects, add error messages to records from trigger collection.
*  2016-04-15  Lukasz Kozminski     Fix problem for recursive update
*
*************************************************************/
public without sharing class GNE_SFA2_Address_Child_Record_Updates {
    
    private enum LicenseInfoAction { NONE, PUSH, PULL, RESET, PUSH_NULL }
    
    private static List<Address_vod__c> prepareAddressList(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        List<Address_vod__c> addressList = new List<Address_vod__c>();
        if(triggerOld == null) {
            for(Integer i = 0; i < triggerNew.size(); i++) {
                if(triggerNew[i].BI_Interval_gne__c != null || triggerNew[i].Proactive_BI_Opt_In_gne__c != null)
                    addressList.add(triggerNew[i]);
            }
        } else {
            for(Integer i = 0; i < triggerNew.size(); i++) {
                if(triggerOld[i].BI_Interval_gne__c != triggerNew[i].BI_Interval_gne__c ||
                    triggerOld[i].Proactive_BI_Opt_In_gne__c != triggerNew[i].Proactive_BI_Opt_In_gne__c)
                    addressList.add(triggerNew[i]);   
            }
        }
        
        return addressList;
    }
    
    /* Case Management method for processing Addresses after insert or update */
    private static void caseManagementAddressPostProcessing(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        List<Address_vod__c> addressList = prepareAddressList(triggerOld, triggerNew);
        Map<Id, Boolean> proactiveBIMap = new Map<Id, Boolean>();
        String sErrorDescription = 'Error: Unable to execute Batch Fax AA Maint Logic, please contact System Administrator';
        
        try {
            for(Address_vod__c address : addressList) {
                proactiveBIMap.put(address.Account_vod__c, address.Proactive_BI_Opt_In_gne__c);
            }
            if(!System.isBatch() && !System.isFuture()  && !System.isQueueable() && !System.isScheduled()) {
                GNE_CM_Batch_Fax_AA_post_processing.processAddressData(proactiveBIMap);
            }
        }
        catch (Exception ex)
        {
            insert GNE_CM_MPS_Utils.createError('Address_vod__c', 'High', 'GNE_CM_address_post_processing', 'Trigger', sErrorDescription);
        }
    }
    
    private static String getKeyCode(Address_vod__c address) {
        String result;
        if(address.Country_vod__c != null && address.Country_vod__c.equalsIgnoreCase('CA')) { // Canada
            result = address.Country_vod__c;
        }
        else {
            result = address.State_vod__c;
        }
        return result;
    }
    
    private static Boolean isLicenseChanged(Address_vod__c addrToUpdate, Address_vod__c addrToCopyLicenceInfo){
        return (addrToUpdate.License_vod__c != addrToCopyLicenceInfo.License_vod__c 
            || addrToUpdate.License_Status_vod__c != addrToCopyLicenceInfo.License_Status_vod__c
            || addrToUpdate.License_Expiration_date_vod__c != addrToCopyLicenceInfo.License_Expiration_date_vod__c);
    }
    
    private static Boolean isLicenseNotEmpty(Address_vod__c addrToUpdate){
        return (addrToUpdate.License_vod__c != null || addrToUpdate.License_Status_vod__c != null
            || addrToUpdate.License_Expiration_date_vod__c != null);
    }
    
    private static void handleAddressLicenseUpdateAction(LicenseInfoAction action, Address_vod__c addr, Address_vod__c address, Map<Id, Address_vod__c> updLic, Map<Id, Address_vod__c> relatedWithAddrToUpd){
        if (action == LicenseInfoAction.PUSH) {
            if(isLicenseChanged(addr, address) && addr.DCH_Approval_Status_gne__c != 'Pending Approval'){
                Address_vod__c addrObj = updLic.get(addr.Id); 
                if (addrObj == null){
                    addrObj = new Address_vod__c(ID=addr.Id);
                }
                addrObj.License_Expiration_date_vod__c = address.License_Expiration_date_vod__c;
                addrObj.License_Status_vod__c = address.License_Status_vod__c;
                addrObj.License_vod__c = address.License_vod__c;
                addrObj.Designation_gne__c = address.Designation_gne__c;
                System.debug('PUSH: License - ' + addrObj.License_vod__c + ', ExpDate -  ' + addrObj.License_Expiration_date_vod__c + ', Status - ' + addrObj.License_Status_vod__c + ', Designation - ' + addrObj.Designation_gne__c);
                updLic.put(addr.Id, addrObj);
                relatedWithAddrToUpd.put(addrObj.Id, address);
            }
            
        }
        else if (action == LicenseInfoAction.PUSH_NULL) {
            if(isLicenseNotEmpty(addr) && addr.DCH_Approval_Status_gne__c != 'Pending Approval'){
                Address_vod__c addrObj = updLic.get(addr.Id); 
                if (addrObj == null) {
                    addrObj = new Address_vod__c(ID=addr.Id);
                }
                addrObj.License_Expiration_date_vod__c = null;
                addrObj.License_Status_vod__c = null;
                addrObj.License_vod__c = null;
                addrObj.Designation_gne__c = null;
                System.debug('PUSH_NULL: License - ' + addrObj.License_vod__c + ', ExpDate -  ' + addrObj.License_Expiration_date_vod__c + ', Status - ' + addrObj.License_Status_vod__c + ', Designation - ' + addrObj.Designation_gne__c);
                updLic.put(addr.Id, addrObj);
                relatedWithAddrToUpd.put(addrObj.Id, address);
            }
        }
        else if (action == LicenseInfoAction.PULL) {
            if(isLicenseChanged(address, addr) && address.DCH_Approval_Status_gne__c != 'Pending Approval'){
                Address_vod__c addrObj = updLic.get(address.Id);
                if (addrObj == null) {
                    addrObj = new Address_vod__c(ID=address.Id);
                }
                addrObj.License_Expiration_date_vod__c=addr.License_Expiration_date_vod__c;
                addrObj.License_Status_vod__c=addr.License_Status_vod__c;
                addrObj.License_vod__c=addr.License_vod__c;
                addrObj.Designation_gne__c = addr.Designation_gne__c;
                updLic.put(address.Id, addrObj);
                relatedWithAddrToUpd.put(addrObj.Id, address);
                System.debug('PULL: License - ' + addrObj.License_vod__c + ', ExpDate -  ' + addrObj.License_Expiration_date_vod__c + ', Status - ' + addrObj.License_Status_vod__c + ', Designation - ' + addrObj.Designation_gne__c);
            }
        }
        else if (action == LicenseInfoAction.RESET) {
            if(isLicenseNotEmpty(address) && address.DCH_Approval_Status_gne__c != 'Pending Approval'){
                Address_vod__c addrObj = updLic.get(address.Id);
                if (addrObj == null) {
                    addrObj = new Address_vod__c(ID=address.Id);
                }
                addrObj.License_Expiration_date_vod__c=null;
                addrObj.License_Status_vod__c=null;
                addrObj.License_vod__c=null;
                addrObj.Designation_gne__c = null;
                updLic.put(address.Id, addrObj);
                relatedWithAddrToUpd.put(addrObj.Id, address);
                System.debug('RESET: License - ' + addrObj.License_vod__c + ', ExpDate -  ' + addrObj.License_Expiration_date_vod__c + ', Status - ' + addrObj.License_Status_vod__c + ', Designation - ' + addrObj.Designation_gne__c);
            }
        }
        else if (action != LicenseInfoAction.NONE) {
            System.debug('Unhandled action: ' + action);
        }
    }
    
    /* Handles license info updates */
    private static void handleLicenseInfoUpdatesOnAfterUpdate(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        String key;
        String keyCode;
        String oldKeyCode;
        String addrKeyCode;
        Set<String> accountIds = new Set<String>();
        Set<String> updateLicenses = new Set<String>();
        Map<Id, Address_vod__c> addressesToUpdate = new Map<Id, Address_vod__c>();
        //The map of addresses from Trigger.new related with addresses to update
        Map<Id, Address_vod__c> relatedWithAddrToUpdate = new Map<Id, Address_vod__c>();
        
        // gather account ids associated with address
        for(Address_vod__c address : triggerNew) {
            accountIds.add(address.Account_vod__c);
        }
        
        // create a map of associated accounts
        Map<Id,Account> accounts  = new Map<Id,Account>([Select Id,(Select Id,Account_vod__c,Primary_vod__c,License_Expiration_date_vod__c,License_Status_vod__c,License_Valid_to_Sample_vod__c,License_vod__c,State_vod__c,Country_vod__c, DCH_Approval_Status_gne__c, Designation_gne__c From Address_vod__r) From Account Where Id In :accountIds]);
        for(Integer i = 0; i < triggerNew.size(); i++) {
            key = triggerNew[i].Account_vod__c;
            keyCode = getKeyCode(triggerNew[i]);
            oldKeyCode = getKeyCode(triggerOld[i]);
            key += '-' + keyCode;
            if (updateLicenses.contains(key) == false) {
                Account acct = accounts.get(triggerNew[i].Account_vod__c);
                if (acct != null) {
                    Boolean keyMatchFound = false;
                    // loop through addresses associated with account
                    for (Address_vod__c addr : acct.Address_vod__r) {
                        LicenseInfoAction action = LicenseInfoAction.NONE;
                        // look for same state matches but ignore itself and addresses which fails validation
                        addrKeyCode = getKeyCode(addr);
                        if (addrKeyCode == keyCode && addr.Id != triggerNew[i].Id && !GNE_SFA2_Address_Trigger_Helper.getFailedValidation(addr.Id)) {
                            keyMatchFound = true;       // found another address with the same keyCode 
                            if(oldKeyCode != keyCode && triggerOld[i].License_Expiration_date_vod__c == triggerNew[i].License_Expiration_date_vod__c &&
                               triggerOld[i].License_Status_vod__c == triggerNew[i].License_Status_vod__c && triggerOld[i].License_vod__c == triggerNew[i].License_vod__c) {
                                    System.debug('Pull license info from first matching state/country');
                                    action = LicenseInfoAction.PULL;
                            } else if(triggerNew[i].License_Valid_to_Sample_vod__c == 'Valid'){
                                System.debug('Push valid license info to other same-state/country addresses');
                                action = LicenseInfoAction.PUSH;
                            } else if(triggerNew[i].License_vod__c == null || triggerNew[i].License_vod__c == ''){
                                if ((triggerOld[i].License_vod__c == null) || (triggerOld[i].License_vod__c  == '')) {
                                    if (addr.License_Valid_to_Sample_vod__c == 'Valid') {
                                        System.debug('Pull valid license info from a same state/country address (after update, no license info before/after)');
                                        action = LicenseInfoAction.PULL;
                                    }
                                } else { // The license info was intentionally nulled out by the user
                                    System.debug('Push null license info values to other same state/country addresses');
                                    action = LicenseInfoAction.PUSH_NULL;
                                }
                            } else {    // handle cases when license information is populated and the user wants to invalidate license
                                System.debug('Push invalid license info to other same state/country addresses');
                                action = LicenseInfoAction.PUSH;
                            }
                        }
                        // handle specified action for address
                        handleAddressLicenseUpdateAction(action, addr, triggerNew[i], addressesToUpdate, relatedWithAddrToUpdate);
                    }
                    // handle case when only state was changed but no matching state address was found
                    if (!keyMatchFound && (oldKeyCode != keyCode) &&
                            triggerOld[i].License_Expiration_date_vod__c == triggerNew[i].License_Expiration_date_vod__c &&
                            triggerOld[i].License_Status_vod__c == triggerNew[i].License_Status_vod__c &&
                            triggerOld[i].License_vod__c == triggerNew[i].License_vod__c) {
                        handleAddressLicenseUpdateAction(LicenseInfoAction.RESET, null, triggerNew[i], addressesToUpdate, relatedWithAddrToUpdate);
                    }
                }
                updateLicenses.add(key);
            }
        }
        // update license info on address
        updateSObjects(addressesToUpdate.values(), relatedWithAddrToUpdate);
    }
    
    private static void handleLicenseInfoUpdatesOnAfterInsert(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        String key;
        String keyCode;
        String oldKeyCode;
        String addrKeyCode;
        Set<String> accountIds = new Set<String>();
        Set<String> updateLicenses = new Set<String>();
        Map<Id, Address_vod__c> addressesToUpdate = new Map<Id, Address_vod__c>();    
        //The map of addresses from Trigger.new related with addresses to update
        Map<Id, Address_vod__c> relatedWithAddrToUpdate = new Map<Id, Address_vod__c>();    
        
        // gather account ids associated with address
        for(Address_vod__c address : triggerNew) {
            accountIds.add(address.Account_vod__c);
        }
        // create a map of associated accounts
        Map<Id,Account> accounts  = new Map<Id,Account>([Select Id,(Select Id,Account_vod__c,Primary_vod__c,License_Expiration_date_vod__c,License_Status_vod__c,License_Valid_to_Sample_vod__c,License_vod__c,State_vod__c,Country_vod__c, DCH_Approval_Status_gne__c, Designation_gne__c From Address_vod__r) From Account Where Id In :accountIds]);
        
        for(Integer i = 0; i < triggerNew.size(); i++) {
            key = triggerNew[i].Account_vod__c;
            keyCode = getKeyCode(triggerNew[i]);
            key += '-' + keyCode;
            if (updateLicenses.contains(key) == false) {
                Account acct = accounts.get(triggerNew[i].Account_vod__c);
                if (acct != null) {
                    Boolean keyMatchFound = false;
                    // loop through addresses associated with account
                    for (Address_vod__c addr : acct.Address_vod__r) {
                        LicenseInfoAction action = LicenseInfoAction.NONE;
                        // look for same state matches but ignore itself
                        addrKeyCode = getKeyCode(addr);
                        if (addrKeyCode == keyCode && addr.Id != triggerNew[i].Id) {
                            keyMatchFound = true;       // found another address with the same keyCode 
                            if(triggerNew[i].License_Valid_to_Sample_vod__c == 'Valid'){
                                System.debug('Push valid license info to other same-state/country addresses');
                                action = LicenseInfoAction.PUSH;
                            } else if(triggerNew[i].License_vod__c == null || triggerNew[i].License_vod__c == ''){
                                if (addr.License_Valid_to_Sample_vod__c == 'Valid') {
                                    System.debug('Pull valid license info from a same state/country address (after insert, no license info)');
                                    action = LicenseInfoAction.PULL;
                                }
                            } else {    // handle cases when license information is populated and the user wants to invalidate license
                                System.debug('Push invalid license info to other same state/country addresses');
                                action = LicenseInfoAction.PUSH;
                            }
                        }
                        // handle specified action for address
                        handleAddressLicenseUpdateAction(action, addr, triggerNew[i], addressesToUpdate, relatedWithAddrToUpdate);
                    }
                }
                updateLicenses.add(key);
            }
        }
        // update license info on address
        updateSObjects(addressesToUpdate.values(), relatedWithAddrToUpdate);
    }
    
    /* Helper method for inserting SObjects and handling errors */
    private static void updateSobjects(List<SObject> objectsToUpdate) {
        updateSobjects(objectsToUpdate, null);
    }
    
    private static void updateSobjects(List<SObject> objectsToUpdate, Map<Id,SObject> relatedObjects) {
        system.debug('start updating: ' + objectsToUpdate);
        if(objectsToUpdate.size() > 0) {
            
            Database.SaveResult[] saveResults = Database.update(objectsToUpdate, false);
            for (Integer i=0; i<saveResults.size(); i++) {
                Id thisId = objectsToUpdate[i].Id;
                if (saveResults[i].isSuccess()) {
                    //System.debug('Successfully updated. ID: ' + thisId);
                }
                else {        
                    String error = '';      
                    for(Database.Error err : saveResults[i].getErrors()) {                    
                        System.debug('Error: ' + err.getStatusCode() + ': ' + err.getMessage());
                        error += err.getMessage() + '\n';
                    }
                    if (thisId != null && relatedObjects != null && relatedObjects.containsKey(thisId)) {
                        System.debug('Error on related object: '+objectsToUpdate.getSObjectType());
                        relatedObjects.get(thisId).addError(error);     
                    }
                }
            }
        }
    }
    
    /* Handles marking address as primary */
    private static void handleMarkingAddressAsPrimary(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        Boolean insertMode = triggerOld==null;
        Set<Id> accountIdsToAnalyze = new Set<Id>();
        Map<Id,Id> newPrimaryAddrMap = new Map<Id,Id>();
        Map<Id,Address_vod__c> relatedWithTriggerAddressMap = new Map<Id,Address_vod__c>();     
        Integer idx=0;
        Set<Id> addrIdsWithPrimFlagDisabled = new Set<Id>();
        
        for(Address_vod__c addrNew : triggerNew) {
            Address_vod__c addrOld = !insertMode ? triggerOld[idx++] : null;
            Boolean primaryFlagChanged = insertMode || addrOld.Primary_vod__c!=addrNew.Primary_vod__c;
            Boolean inactiveFlagChanged = addrOld!=null && addrOld.Inactive_vod__c!=addrNew.Inactive_vod__c;
            
            if((inactiveFlagChanged && addrNew.Inactive_vod__c) || (!addrNew.Inactive_vod__c && primaryFlagChanged)) {
                accountIdsToAnalyze.add(addrNew.Account_vod__c);
                relatedWithTriggerAddressMap.put(addrNew.Account_vod__c, addrNew);
                
                if(!addrNew.Inactive_vod__c && primaryFlagChanged) {
                    if (addrNew.Primary_vod__c){
                        newPrimaryAddrMap.put(addrNew.Account_vod__c, addrNew.Id);
                    } else {
                        addrIdsWithPrimFlagDisabled.add(addrNew.Id);
                    }                   
                }
            }
        }
        
        if(!accountIdsToAnalyze.isEmpty()) {
            Map<Id,Account> accountsMap = new Map<Id,Account>([
                SELECT Id, Main_Address_gne__c,
                    (SELECT Id, Account_vod__c, Primary_vod__c FROM Address_vod__r WHERE Inactive_vod__c = false AND Id NOT IN :addrIdsWithPrimFlagDisabled ORDER BY Primary_vod__c DESC),
                    (SELECT Id, Account_vod__c, Address_vod__c FROM TSF_vod__r)
                FROM Account
                WHERE Id IN :accountIdsToAnalyze
            ]);
            
            List<Account> accsToUpdate = new List<Account>();
            List<TSF_vod__c> tsfsToUpdate = new List<TSF_vod__c>();
            List<Address_vod__c> addrsToUpdate = new List<Address_vod__c>();
            
            for(Id accId : accountsMap.keySet()) {
                Account acc = accountsMap.get(accId);
                Id newPrimaryAddrId = newPrimaryAddrMap.get(accId);
                Id oldPrimaryAddrId = !acc.Address_vod__r.isEmpty() && acc.Address_vod__r[0].Primary_vod__c ? acc.Address_vod__r[0].Id : null;
                Address_vod__c triggerNewAddr = relatedWithTriggerAddressMap.get(accId);
                
                if(newPrimaryAddrId==null && oldPrimaryAddrId==null && !acc.Address_vod__r.isEmpty()) {
                    newPrimaryAddrId = acc.Address_vod__r[0].Id;
                    addrsToUpdate.add(new Address_vod__c(Id = newPrimaryAddrId, Primary_vod__c = true));
                    relatedWithTriggerAddressMap.put(newPrimaryAddrId, triggerNewAddr);
                } else if(newPrimaryAddrId==null && oldPrimaryAddrId!=null) {
                    newPrimaryAddrId = oldPrimaryAddrId;
                } else if(newPrimaryAddrId!=null) {
                    for(Address_vod__c addr : acc.Address_vod__r) {
                        if(addr.Primary_vod__c && addr.Id!=newPrimaryAddrId) {
                            addrsToUpdate.add(new Address_vod__c(Id = addr.Id, Primary_vod__c = false));
                            relatedWithTriggerAddressMap.put(addr.Id, triggerNewAddr);
                        } else if(!addr.Primary_vod__c) {
                            break;
                        }
                        
                    }
                }
                
                if(newPrimaryAddrId!=null) {
                    for(TSF_vod__c tsf : acc.TSF_vod__r) {
                        if(tsf.Address_vod__c!=newPrimaryAddrId) {
                            tsfsToUpdate.add(new TSF_vod__c(Id = tsf.Id, Address_vod__c = newPrimaryAddrId));
                            relatedWithTriggerAddressMap.put(tsf.Id, triggerNewAddr);
                        }
                    }
                    
                    if(acc.Main_Address_gne__c!=newPrimaryAddrId) {
                        accsToUpdate.add(new Account(Id = accId, Main_Address_gne__c = newPrimaryAddrId));
                    }
                }
            }

            if(GNE_SFA2_Util.isCanadaUser()) {
                try {
                    Set<Id> modifiedAddresses = new Set<Id>();
                    for(Address_vod__c addr : addrsToUpdate) {
                        if(addr.Primary_vod__c == false) {
                            modifiedAddresses.add(addr.Id);
                        }
                    }
                    removeAffiliationsByAddressesIds(modifiedAddresses);
                }
                catch(Exception ex) {
                    System.debug(ex.getMessage());
                }
            }
            
            updateSobjects(addrsToUpdate, relatedWithTriggerAddressMap);
            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
            updateSobjects(accsToUpdate, relatedWithTriggerAddressMap);
            GNE_SFA2_TSF_Trigger_Helper.setTSFTrig(true);
            updateSobjects(tsfsToUpdate, relatedWithTriggerAddressMap);
            GNE_SFA2_TSF_Trigger_Helper.setTSFTrig(false);
            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
        }
    }

    private static void createCanadaAffiliations(List<Address_vod__c> triggerNew) {
        try {
            List<Id> hcpAccountIds = new List<Id>();
            List<Id> hcoAccountIds = new List<Id>();
            List<String> addressNames = new List<String>();
            List<Id> accountsIds = new List<Id>();
            List<String> provinces = new List<String>();
            List<String> postalCodes = new List<String>();

            for(Address_vod__c address : triggerNew) {
                if(address.Primary_vod__c && address.Region_Code_gne__c == 2) {
                    accountsIds.add(address.Account_vod__c);
                    addressNames.add(address.Name);
                    provinces.add(address.Province_can_gne__c);
                    postalCodes.add(address.Postal_Code_can_gne__c);
                }
            }
            
            List<Account> hcpAccounts = new List<Account>();
            List<Account> hcoAccounts = new List<Account>();
            
            if(!accountsIds.isEmpty()) {
                List<Account> accounts = [SELECT Id, Account_Type_gne__c, isPersonAccount,Main_Address_gne__c, Main_Address_gne__r.Id, Main_Address_gne__r.Inactive_vod__c, Main_Address_gne__r.Address_line_2_vod__c, Main_Address_gne__r.City_vod__c, Main_Address_gne__r.Province_can_gne__c, Main_Address_gne__r.Postal_Code_can_gne__c, Main_Address_gne__r.Name, Prim_IMS_Id_can__c FROM Account WHERE Id IN :accountsIds];
                for(Account account : accounts) {       
                    if(account.isPersonAccount) {
                        hcpAccounts.add(account);
                    } else if(!account.isPersonAccount) {
                        hcoAccounts.add(account);
                    } 
                }

                List<Account> accountsWithSameAddress = [SELECT Id, Account_Type_gne__c, isPersonAccount,Main_Address_gne__c, Main_Address_gne__r.Id, Main_Address_gne__r.Inactive_vod__c, Main_Address_gne__r.Address_line_2_vod__c, Main_Address_gne__r.City_vod__c, Main_Address_gne__r.Province_can_gne__c, Main_Address_gne__r.Postal_Code_can_gne__c, Main_Address_gne__r.Name, Prim_IMS_Id_can__c FROM Account 
                                                        WHERE Main_Address_gne__r.Province_can_gne__c IN :provinces AND Main_Address_gne__r.Postal_Code_can_gne__c IN :postalCodes AND Status_gne__c = 'Active' AND Region_Code_gne__c = 2 AND Id NOT IN :hcoAccountIds AND Id NOT IN :hcpAccountIds];
                List<Affiliation_vod__c> affiliationsToInsert = new List<Affiliation_vod__c>();

                for(Account account : hcpAccounts) {
                    for(Account queriedAccount : accountsWithSameAddress) {
                        if(!queriedAccount.isPersonAccount && queriedAccount.Prim_IMS_Id_can__c != null
                            && (isMatchForHospital(account, queriedAccount)
                            || isMatchForPharmacy(account, queriedAccount))) {
                            if(GNE_SFA2_Address_Util.isAddressTheSame(account.Main_Address_gne__r, queriedAccount.Main_Address_gne__r)) {
                                affiliationsToInsert.add(new Affiliation_vod__c(From_Account_vod__c=account.Id, To_Account_vod__c=queriedAccount.Id, Role_vod__c = 'Affiliated with'));
                           }
                        }
                    }
                }
                for(Account account : hcoAccounts) {
                    for(Account queriedAccount : accountsWithSameAddress) {
                        if(queriedAccount.isPersonAccount && account.Prim_IMS_Id_can__c != null
                            && (isMatchForHospital(account, queriedAccount)
                            || isMatchForPharmacy(account, queriedAccount))) {
                            if(GNE_SFA2_Address_Util.isAddressTheSame(account.Main_Address_gne__r, queriedAccount.Main_Address_gne__r)) {
                                affiliationsToInsert.add(new Affiliation_vod__c(From_Account_vod__c=account.Id, To_Account_vod__c=queriedAccount.Id, Role_vod__c = 'Affiliated with'));
                           }
                        }
                    }
                }
                insert affiliationsToInsert;
            }
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
    }

    private static void removeExistingAffiliations(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        try {
            Integer index = 0;
            List<Id> changedAddressesAccounts = new List<Id>();
            Set<Id> addressesIds = new Set<Id>();

            for(Address_vod__c newAddress : triggerNew) {
                Address_vod__c oldAddress = triggerOld[index++];

                if(!GNE_SFA2_Address_Util.isAddressTheSame(newAddress, oldAddress) || newAddress.Account_vod__c != oldAddress.Account_vod__c || wasStatusChanged(oldAddress, newAddress) || addressChangedToNonPrimary(oldAddress, newAddress)) {   
                    if(oldAddress.Region_Code_gne__c == 2 && newAddress.Region_Code_gne__c == 2) {
                        addressesIds.add(newAddress.Id);
                    }
                }
            }
            removeAffiliationsByAddressesIds(addressesIds);
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
    }

    private static void removeAffiliationsByAddressesIds(Set<Id> addressesIds) {
        List<Affiliation_vod__c> affiliationsToRemove = [SELECT Id FROM Affiliation_vod__c WHERE (From_Account_vod__r.Main_Address_gne__r.Id IN :addressesIds OR To_Account_vod__r.Main_Address_gne__r.Id IN :addressesIds)
                                                            AND Region_Code_gne__c = 2 
                                                            AND ((                    
                                                                (From_Account_vod__r.Account_Type_gne__c = 'Hospital' AND 
                                                                        (To_Account_vod__r.Account_Type_gne__c = 'Physician' OR To_Account_vod__r.Account_Type_gne__c LIKE '%Nurse%'))
                                                                OR 
                                                                (From_Account_vod__r.Account_Type_gne__c LIKE '%Pharmacy' AND To_Account_vod__r.Account_Type_gne__c = 'Pharmacist')
                                                            ) OR ((To_Account_vod__r.Account_Type_gne__c = 'Hospital' AND 
                                                                (From_Account_vod__r.Account_Type_gne__c = 'Physician' OR From_Account_vod__r.Account_Type_gne__c LIKE '%Nurse%'))
                                                                OR 
                                                                (To_Account_vod__r.Account_Type_gne__c LIKE '%Pharmacy' AND From_Account_vod__r.Account_Type_gne__c = 'Pharmacist'))
                                                            )]; 
        delete affiliationsToRemove;
    }

    private static Boolean addressChangedToNonPrimary(Address_vod__c oldAddress, Address_vod__c newAddress) {
        return oldAddress.Primary_vod__c == true && newAddress.Primary_vod__c == false;
    }

    private static Boolean wasStatusChanged(Address_vod__c oldAddress, Address_vod__c newAddress) {
        return (newAddress.Account_vod__c != null && oldAddress.Account_vod__c != null) && (newAddress.Account_vod__r.Status_gne__c == 'Inactive' && oldAddress.Account_vod__r.Status_gne__c == 'Active');
    }

    private static Boolean isMatchForHospital(Account hcpAccount, Account hcoAccount) {
        return (hcpAccount.Account_Type_gne__c == 'Physician' || hcpAccount.Account_Type_gne__c.contains('Nurse')) && 
                hcoAccount.Account_Type_gne__c == 'Hospital';
    } 

    private static Boolean isMatchForPharmacy(Account hcpAccount, Account hcoAccount) {
        return hcpAccount.Account_Type_gne__c == 'Pharmacist' && hcoAccount.Account_Type_gne__c.contains('Pharmacy');
    }

    private static Boolean isManagedType(Account account) {
        return account.Account_Type_gne__c == 'Physician' ||
            account.Account_Type_gne__c.contains('Nurse') ||
            account.Account_Type_gne__c == 'Hospital' ||
            account.Account_Type_gne__c =='Pharmacist' ||
            account.Account_Type_gne__c.contains('Pharmacy');
    }
    
    private static void updateMergeTypeCandidates(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        Integer idx = 0;
        Map<Id,String> approvalStatuses = new Map<Id,String>();
        
        for(Address_vod__c newRec : triggerNew) {
            Address_vod__c oldRec = triggerOld[idx++];
            
            if(newRec.DCH_Approval_Status_gne__c!=oldRec.DCH_Approval_Status_gne__c) {
                approvalStatuses.put(newRec.Id, newRec.DCH_Approval_Status_gne__c);
            }
        }
        
        if(!approvalStatuses.isEmpty()) {
            Merge_Type_Util.updateCandidatesApprovalStatus(approvalStatuses);
        }
    }
    
    public static void onAfterUpdate(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        //Create cloned collections from triggerNew and triggerOld 
        List<Address_vod__c> new_triggerNew = triggerNew.clone();
        List<Address_vod__c> new_triggerOld = triggerOld.clone();
        //Remove records that are included in failed validations collection
        GNE_SFA2_Address_Trigger_Helper.removeFailedValidationRecords(new_triggerNew);
        GNE_SFA2_Address_Trigger_Helper.removeFailedValidationRecords(new_triggerOld);
        
        // .........:::::::::::::: THIS CODE RULE MUST BE ACTIVE DURING MERGE - NOT ADDING BYPASS :::::::::::::::::.................
        caseManagementAddressPostProcessing(new_triggerOld, new_triggerNew);
        updateMergeTypeCandidates(new_triggerOld, new_triggerNew);
        
        if(!GNE_SFA2_Util.isMergeMode()){
            handleMarkingAddressAsPrimary(new_triggerOld, new_triggerNew);
            handleLicenseInfoUpdatesOnAfterUpdate(new_triggerOld, new_triggerNew);
            
            if(!GNE_SFA2_Account_Trigger_Helper.inAccountTrig()) {
                GNE_SFA2_DCR_Util.onAfterUpdateParent(new_triggerOld, new_triggerNew);
            }
        }

        if(GNE_SFA2_Util.isCanadaUser()) {
           removeExistingAffiliations(new_triggerOld, new_triggerNew); 
           createCanadaAffiliations(new_triggerNew);
        }
    }
    
    public static void onAfterInsert(List<Address_vod__c> triggerNew) {
        //Create a cloned collection from triggerNew
        List<Address_vod__c> new_triggerNew = triggerNew.clone();
        //Remove records that are included in failed validations collection
        GNE_SFA2_Address_Trigger_Helper.removeFailedValidationRecords(new_triggerNew);
        
        // .........:::::::::::::: THIS CODE RULE MUST BE ACTIVE DURING MERGE - NOT ADDING BYPASS :::::::::::::::::.................
        caseManagementAddressPostProcessing(null, new_triggerNew);
        
        if(!GNE_SFA2_Util.isMergeMode()){
            handleMarkingAddressAsPrimary(null, new_triggerNew);
            handleLicenseInfoUpdatesOnAfterInsert(null, new_triggerNew);
        }

        if(GNE_SFA2_Util.isCanadaUser() && GNE_SFA2_Util.getCurrentUserProfileName() != 'RCanada-SYS-AutomatedJob') {
           createCanadaAffiliations(triggerNew);
        }
    }


}