/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-07
*  Description: This is a helper class for handling Address field updates
*  Test class: GNE_SFA2_Address_Trigger_Test
*
*  Modification History
*  Date        Name                 Description
*  2014-01-23  Marta Malinowska     Exclude invalid addresses from further processing, methods: onBeforeUpdate, onBeforeInsert and onBeforeDelete
*************************************************************/
public with sharing class GNE_SFA2_Address_Field_Updates {

    private static final Map<String, Id> recTypeDevNameToId;
    private static final Map<Id, String> recTypeIdToDevName;
    public static final String ADDRESS_COMPANY_MAINTEINED_REC_TYPE = 'CompanyMaintained';
    public static final String ADDRESS_REP_MAINTEINED_REC_TYPE = 'RepMaintained';
    public static final String ADDRESS_CANADA_HCO_COMPANY_MAINTEINED_REC_TYPE = 'SFA_Canada_Company_Maintained_HCO';
    public static final String ADDRESS_CANADA_HCP_COMPANY_MAINTEINED_REC_TYPE = 'SFA_Canada_Company_Maintained_HCP';
    public static final String ADDRESS_CANADA_HCO_REP_MAINTEINED_REC_TYPE = 'SFA_Canada_Rep_Maintained_HCO';
    public static final String ADDRESS_CANADA_HCP_REP_MAINTEINED_REC_TYPE = 'SFA_Canada_Rep_Maintained_HCP';

    // USPS Variables
    public static Boolean isUSPSMode = false;
    private static String uspsUserId = '079GENEN5934';
    private static String uspsApiUrl = 'https://production.shippingapis.com/ShippingAPITest.dll';
    private static final Set<String> USPS_XML_LABELS = new Set<String>{'Address1','Address2','City','State','Zip5','Zip4','Number','Source','Description','HelpFile','HelpContext'};

    static {
        recTypeDevNameToId = new Map<String, Id>();
        recTypeIdToDevName = new Map<Id, String>();
        for (RecordType recType : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Address_vod__c']) {
            recTypeDevNameToId.put(recType.DeveloperName, recType.Id);
            recTypeIdToDevName.put(recType.Id, recType.DeveloperName);
        }
    }

    public static void onBeforeUpdate(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        if(!isUSPSMode) {
            //Create cloned collections from triggerNew and triggerOld
            List<Address_vod__c> new_triggerNew = triggerNew.clone();
            List<Address_vod__c> new_triggerOld = triggerOld.clone();
            //Remove records that are included in failed validations collection
            GNE_SFA2_Address_Trigger_Helper.removeFailedValidationRecords(new_triggerNew);
            GNE_SFA2_Address_Trigger_Helper.removeFailedValidationRecords(new_triggerOld);

            if (!GNE_SFA2_Util.isMergeMode()) {
                addressDeactivationFieldUpdatesOnUpdate(new_triggerOld, new_triggerNew);
                addressFieldUpdatesOnUpdate(new_triggerNew);
                setProperRecordType(new_triggerNew);

                if (!GNE_SFA2_Account_Trigger_Helper.inAccountTrig()) {
                    GNE_SFA2_DCR_Util.onBeforeUpdateParent(new_triggerNew);
                }

                updateAddressLocation(new_triggerOld, new_triggerNew, true);
            } 
        }
    }

    public static void onAfterUpdate(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        if(!System.isBatch() && !System.isFuture()  && !System.isQueueable() && !System.isScheduled()) {
            List<Address_vod__c> addressesToUSPSValidation = prepareCandidatesToUSPSValidation(triggerOld, triggerNew, getUSRecordTypes());
            if(!addressesToUSPSValidation.isEmpty()) {
                try {
                    uspsValidation(JSON.serialize(addressesToUSPSValidation));
                } catch(Exception ex) {
                    System.debug(ex);
                }  
            }
        }
    }

    public static void onBeforeInsert(List<Address_vod__c> triggerNew) {
        //Create a cloned collection from triggerNew
        List<Address_vod__c> new_triggerNew = triggerNew.clone();
        //Remove records that are included in failed validations collection
        GNE_SFA2_Address_Trigger_Helper.removeFailedValidationRecords(new_triggerNew);

        if (!GNE_SFA2_Util.isMergeMode()) {
            addressDeactivationFieldUpdatesOnInsert(new_triggerNew);
            addressFieldUpdatesOnInsert(new_triggerNew);
            setProperRecordType(new_triggerNew);
            updateAddressLocation(null, new_triggerNew, false);
        }
    }

    public static void onAfterInsert(List<Address_vod__c> triggerNew) {
        //Create a cloned collection from triggerNew
        List<Address_vod__c> new_triggerNew = triggerNew.clone();
        //Remove records that are included in failed validations collection
        GNE_SFA2_Address_Trigger_Helper.removeFailedValidationRecords(new_triggerNew);

        if (!GNE_SFA2_Util.isMergeMode()) {
            updateAddressLocation(null, new_triggerNew, true);
        }

        if(!System.isBatch() && !System.isFuture()  && !System.isQueueable() && !System.isScheduled()) {
            List<Address_vod__c> addressesToUSPSValidation = prepareCandidatesToUSPSValidation(null, triggerNew, getUSRecordTypes());
            if(!addressesToUSPSValidation.isEmpty()) {
                try {
                    uspsValidation(JSON.serialize(addressesToUSPSValidation));
                } catch(Exception ex) {
                    System.debug(ex);
                }
            }    
        }
        
    }

    public static void onBeforeDelete(List<Address_vod__c> triggerOld) {
        //Create a cloned collection from triggerOld
        List<Address_vod__c> new_triggerOld = triggerOld.clone();
        //Remove records that are included in failed validations collection
        GNE_SFA2_Address_Trigger_Helper.removeFailedValidationRecords(new_triggerOld);
        if (!GNE_SFA2_Util.isMergeMode()) {
            createChildAddressesMap(new_triggerOld);
        }
    }

    public static Boolean isRecordCompanyMaintained(String recTypeDevName) {
        return String.isNotBlank(recTypeDevName) && (
                   recTypeDevName == ADDRESS_COMPANY_MAINTEINED_REC_TYPE ||
                   recTypeDevName == ADDRESS_CANADA_HCO_COMPANY_MAINTEINED_REC_TYPE ||
                   recTypeDevName == ADDRESS_CANADA_HCP_COMPANY_MAINTEINED_REC_TYPE);
    }

    /* Indicate whether address related fields have changed. This field is mainly used by OTR */
    public static void setAddressChangedFlag(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        for(Integer i = 0; i < triggerNew.size(); i++) {   
            
            if(triggerNew[i].Name != triggerOld[i].Name ||
                triggerNew[i].Address_line_2_vod__c != triggerOld[i].Address_line_2_vod__c ||
                triggerNew[i].City_vod__c != triggerOld[i].City_vod__c ||
                triggerNew[i].State_vod__c != triggerOld[i].State_vod__c ||
                triggerNew[i].Zip_vod__c != triggerOld[i].Zip_vod__c) 
            {
                triggerNew[i].Changed_Address_gne__c = true;
            }
        }
    }

    private static void incrementInactiveCount(Address_vod__c address) {
        if (address.Inactivate_Count_gne__c == null) {
            address.Inactivate_Count_gne__c = 1;
        } else {
            address.Inactivate_Count_gne__c += 1;
        }
    }

    private static Set<Id> getUSRecordTypes() {
        Set<Id> result = new Set<Id>();
        Map<Id, RecordType> usRecordTypes = new Map<Id, RecordType>([SELECT Id FROM RecordType WHERE (DeveloperName =: ADDRESS_COMPANY_MAINTEINED_REC_TYPE OR DeveloperName =: ADDRESS_REP_MAINTEINED_REC_TYPE)]);
        if(!usRecordTypes.isEmpty()) {
            result.addAll(usRecordTypes.keySet());
        }

        return result;
    }

    private static void addressDeactivationFieldUpdatesOnInsert(List<Address_vod__c> triggerNew) {
        Id currentUserId = UserInfo.getUserId();

        for (Address_vod__c address : triggerNew) {
            if (address.Inactive_vod__c) {
                // if is inactive
                address.Inactivate_User_gne__c = currentUserId;
                incrementInactiveCount(address);
            } else {
                address.Inactivate_Reason_gne__c = null;
                address.Inactivate_User_gne__c = null;
            }
        }
    }

    private static void addressDeactivationFieldUpdatesOnUpdate(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        Id currentUserId = UserInfo.getUserId();

        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (!triggerNew[i].Inactive_vod__c) {
                // if is active
                triggerNew[i].Inactivate_Reason_gne__c = null;
                triggerNew[i].Inactivate_User_gne__c = null;
            } else if (triggerNew[i].Inactive_vod__c && !triggerOld[i].Inactive_vod__c) {
                // was changed from active to inactive
                triggerNew[i].Inactivate_User_gne__c = currentUserId;
                incrementInactiveCount(triggerNew[i]);
            }
        }
    }

    private static void addressFieldUpdatesOnUpdate(List<Address_vod__c> triggerNew) {
        for (Address_vod__c address : triggerNew) {
            if (address.No_Address_Copy_vod__c == true ) {
                GNE_SFA2_Address_Trigger_Helper.addCopySetFalse(address.Id);
                address.No_Address_Copy_vod__c = false;
            }

            if ((address.Controlled_Address_vod__c == true) && (address.External_ID_vod__c == null)) {
                address.External_ID_vod__c = address.Account_vod__c + '_' + address.Controlling_Address_vod__c;
            }
        }
    }

    private static void addressFieldUpdatesOnInsert(List<Address_vod__c> triggerNew) {
        for (Address_vod__c address : triggerNew) {

            // Set Active Flag
            address.Active_Flag_gne__c = true;

            if (address.No_Address_Copy_vod__c == true ) {
                GNE_SFA2_Address_Trigger_Helper.addCopySetFalse(address.Id);
                address.No_Address_Copy_vod__c = false;
            }

            if (address.Entity_Reference_Id_vod__c != null && address.Entity_Reference_Id_vod__c.length() > 0) {
                address.Account_vod__c = address.Entity_Reference_Id_vod__c;
                address.Entity_Reference_Id_vod__c = null;
            }

            if ((address.Controlled_Address_vod__c == true) && (address.External_ID_vod__c == null)) {
                address.External_ID_vod__c = address.Account_vod__c + '_' + address.Controlling_Address_vod__c;
            }
        }
    }

    private static void createChildAddressesMap(List<Address_vod__c> triggerOld) {
        Map <Id, Address_vod__c> addMap = new Map <Id, Address_vod__c> ([SELECT Id, (SELECT Id FROM Controlling_Address_vod__r),
                (SELECT Id FROM Call2_vod__r WHERE Status_vod__c = 'Submitted_vod' or Status_vod__c = 'Saved_vod')
                FROM Address_vod__c WHERE ID in :triggerOld]);

        for (Address_vod__c address : triggerOld) {
            Address_vod__c myAddItem = addMap.get(address.Id);
            if (myAddItem != null) {
                for (Address_vod__c childAddress : myAddItem.Controlling_Address_vod__r) {
                    GNE_SFA2_Address_Trigger_Helper.addDelSet(childAddress.Id);
                }
            }
        }
    }

    /* Change record type of address form Rep Maintained to Company Maintained (only USA addresses)
    once the address has MDM assigned via data load and/or the subscribe interface */
    private static void setProperRecordType(List<Address_vod__c> triggerNew) {
        for (Address_vod__c address : triggerNew) {
            if (String.isNotEmpty(address.MDM_Address_ID_gne__c) && address.Region_Code_gne__c == 1) {
                address.RecordTypeId = getCompanyRecordType(address);
            }
        }
    }

    /*Return company record type for address base on region code and current address record type*/
    private static Id getCompanyRecordType(Address_vod__c address) {
        Id recordTypeId = address.RecordTypeId;
        if (address.Region_Code_gne__c == 1) {
            recordTypeId = recTypeDevNameToId.get(ADDRESS_COMPANY_MAINTEINED_REC_TYPE);
        } else if (address.Region_Code_gne__c == 2) {
            if (recTypeIdToDevName.get(address.RecordTypeId) == ADDRESS_CANADA_HCO_COMPANY_MAINTEINED_REC_TYPE || recTypeIdToDevName.get(address.RecordTypeId) == ADDRESS_CANADA_HCO_REP_MAINTEINED_REC_TYPE ) {
                recordTypeId = recTypeDevNameToId.get(ADDRESS_CANADA_HCO_COMPANY_MAINTEINED_REC_TYPE);
            } else {
                recordTypeId = recTypeDevNameToId.get(ADDRESS_CANADA_HCP_COMPANY_MAINTEINED_REC_TYPE);
            }
        }
        return recordTypeId;
    }

    private static void updateAddressLocation(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew, Boolean allowFutureCall) {
        Integer idx = 0;
        List<Address_vod__c> addrsToUpdate = new List<Address_vod__c>();

        for (Address_vod__c addrNew : triggerNew) {
            Address_vod__c addrOld = triggerOld != null ? triggerOld[idx++] : null;
            Boolean locationUpdatedInSubscribeProcess = CORE_Subscribe_Util.isSubscribeProcess() && addrNew.Force_Location_Update_gne__c == false;

            if (!locationUpdatedInSubscribeProcess) {
                Boolean needLocationUpdateInInsertMode = addrOld == null && (addrNew.Location_gne__Latitude__s == null || addrNew.Location_gne__Longitude__s == null);
                Boolean needLocationUpdateInUpdateMode = addrOld != null && (addrNew.Location_gne__Latitude__s == null || addrNew.Location_gne__Longitude__s == null ||
                        addrOld.Name != addrNew.Name || addrOld.City_vod__c != addrNew.City_vod__c ||
                        addrOld.State_vod__c != addrNew.State_vod__c || addrOld.Zip_vod__c != addrNew.Zip_vod__c);

                if (needLocationUpdateInInsertMode || needLocationUpdateInUpdateMode) {
                    addrsToUpdate.add(addrNew);
                }
            }
        }

        if (!addrsToUpdate.isEmpty()) {
            GNE_SFA2_AddressLocation_Util.setAddressLocation(addrsToUpdate, allowFutureCall, triggerOld != null || !allowFutureCall);
        }
    }

    private static List<Address_vod__c> prepareCandidatesToUSPSValidation(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew, Set<Id> recTypes) {
        List<Address_vod__c> result = new List<Address_vod__c>();
        Boolean isInsert = triggerOld == null ? true : false;
        if(isInsert) {
            for(Address_vod__c addr : triggerNew) {
                if(recTypes.contains(addr.RecordTypeId) && (addr.USPS_Status_gne__c == null || addr.USPS_Status_gne__c == 'Unverified')) {
                    result.add(addr);
                }
            }
        } else {
            for (Integer i = 0; i < triggerNew.size(); i++) {
                if(recTypes.contains(triggerOld[i].RecordTypeId) && (triggerNew[i].Name != triggerOld[i].Name || triggerNew[i].Address_line_2_vod__c != triggerOld[i].Address_line_2_vod__c || triggerNew[i].City_vod__c != triggerOld[i].City_vod__c || triggerNew[i].State_vod__c != triggerOld[i].State_vod__c || triggerNew[i].Zip_vod__c != triggerOld[i].Zip_vod__c || triggerNew[i].Zip_4_vod__c != triggerOld[i].Zip_4_vod__c)) {
                    result.add(triggerNew[i]);
                }
            } 
        }

        return result;
    }

    @future(callout=true)
    private static void uspsValidation(String addrToValid) {
        if(Test.isRunningTest()) {
            return;
        } 
        
        new GNE_SFA2_Address_Field_Updates.USPSValidation(addrToValid);
    }

    public without sharing class USPSValidation {

        public USPSValidation(String addrToValid) {
            executeWithoutSharingLogic(addrToValid);
        }

        private void executeWithoutSharingLogic(String addrToValid) {
            isUSPSMode = true;
            List<Address_vod__c> addressesToValidation = String.isNotBlank(addrToValid) ? (List<Address_vod__c>)JSON.deserialize(addrToValid, List<Address_vod__c>.class) : null;

            Map<Id, Address_vod__c> addressesToValidationMap = new Map<Id, Address_vod__c>();
            addressesToValidationMap.putAll(addressesToValidation);
            Map<String, Map<String, String>> addressesWrappersMap = new Map<String, Map<String, String>>();
            for(Address_vod__c addr : addressesToValidationMap.values()) {
                addressesWrappersMap.put(addr.Id, new Map<String, String>{
                    'address1' => addr.Address_line_2_vod__c,
                    'address2' => addr.Name,
                    'city' => addr.City_vod__c,
                    'state' => addr.State_vod__c,
                    'zip5' => addr.Zip_vod__c,
                    'zip4' => addr.Zip_4_vod__c
                });

                if(addressesWrappersMap.size() == 5) {
                    Map<String, Map<String, String>> addressesValidatedMap = addressesValidate(addressesWrappersMap);
                    addressesToValidationMap = prepareAddressesToUpdate(addressesToValidationMap, addressesValidatedMap);
                    addressesWrappersMap = new Map<String, Map<String, String>>();
                }
            }

            if(!addressesWrappersMap.isEmpty()) {
                Map<String, Map<String, String>> addressesValidatedMap = addressesValidate(addressesWrappersMap);
                addressesToValidationMap = prepareAddressesToUpdate(addressesToValidationMap, addressesValidatedMap);
                addressesWrappersMap = new Map<String, Map<String, String>>();
            }
            update addressesToValidationMap.values();
        }
    }

    private static Map<Id, Address_vod__c> prepareAddressesToUpdate(Map<Id, Address_vod__c> addressesToValidationMap, Map<String, Map<String, String>> addressesValidatedMap) {
        for(String addrId : addressesValidatedMap.keySet()) {
            Address_vod__c currentAddress = addressesToValidationMap.get(addrId);
            Map<String, String> validationResult = addressesValidatedMap.get(addrId);
            Map<String, Map<String, String>> validationComment = new Map<String, Map<String, String>>();
            
            if(String.isNotBlank(validationResult.get('Description'))) {
                currentAddress.USPS_Status_gne__c  = 'Invalid';
                validationComment.put('error', new Map<String, String>{
                    'description' => validationResult.get('Description')
                });
            } else {
                currentAddress.USPS_Status_gne__c  = 'Valid';

                // Street Address Differences
                if(currentAddress.Name != validationResult.get('Address2')) {
                    validationComment.put('addressDifferences', new Map<String, String>{
                        'sfdcAddress' => currentAddress.Name,
                        'uspsAddress' => validationResult.get('Address2')
                    });
                }

                // City Differences
                if(currentAddress.City_vod__c != validationResult.get('City')) {
                    validationComment.put('cityDifferences', new Map<String, String>{
                        'sfdcCity' => currentAddress.City_vod__c,
                        'uspsCity' => validationResult.get('City')
                    });
                }

                // State Differences
                if(currentAddress.State_vod__c != validationResult.get('State')) {
                    validationComment.put('stateDifferences', new Map<String, String>{
                        'sfdcState' => currentAddress.State_vod__c,
                        'uspsState' => validationResult.get('State')
                    });
                }

                // Zip 5 Code Differences
                if(currentAddress.Zip_vod__c != validationResult.get('Zip5')) {
                    validationComment.put('zip5CodeDifferences', new Map<String, String>{
                        'sfdcZip5Code' => currentAddress.Zip_vod__c,
                        'uspsZip5Code' => validationResult.get('Zip5')
                    });
                }

                // Zip 4 Code Differences
                if(currentAddress.Zip_4_vod__c != validationResult.get('Zip4')) {
                    validationComment.put('zip4CodeDifferences', new Map<String, String>{
                        'sfdcZip4Code' => currentAddress.Zip_4_vod__c,
                        'uspsZip4Code' => validationResult.get('Zip4')
                    });
                }

                if(!validationComment.isEmpty()) {
                    currentAddress.USPS_Status_gne__c = 'Partially valid';
                }
            }
            

            if(!validationComment.isEmpty()) {
                currentAddress.USPS_Comment_gne__c = JSON.serialize(validationComment);
            } else {
                currentAddress.USPS_Comment_gne__c = null;     
            }

            addressesToValidationMap.put(addrId, currentAddress);
        }
        
        return addressesToValidationMap;
    }

    private static Map<String, Map<String, String>> callUspsApi(String apiName, String request) {
        HttpRequest req = new HttpRequest();
        String endPoint = uspsApiUrl + '?API=' + apiName + '&XML=' + EncodingUtil.urlEncode(request, 'UTF-8');
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setTimeout(120000);
        
        HTTPResponse res = (new Http()).send(req);
        System.debug('##### Status = ' + res.getStatus());
        return getValuesForListOfXMLElements('AddressValidateResponse', USPS_XML_LABELS, res);
    }

    public static Map<String, Map<String, String>> addressesValidate(Map<String, Map<String, String>> params) {
        String request = GNE_SFA2_USPSUtil.buildAddressesValidateRequest(uspsUserId, params);
        return callUspsApi('Verify', request);
    }

    public static List<dom.XMLNode> getRootList(String label, HttpResponse res){
        List<dom.XMLNode> result = null;
        if (res.getStatus() == 'OK') {
            dom.Document doc = res.getBodyDocument();
            if (doc != null) {
                dom.XMLNode root = doc.getRootElement();
                dom.XMLNode listRoot = findRootListInXML(label, root);
                if(listRoot != null){
                    result = listRoot.getChildElements();
                }
            }
        }

        return result;
    }

    public static dom.XMLNode findRootListInXML(String label, dom.XMLNode xmlNode){
        if (xmlNode != null) {
            if(xmlNode.getName() == label){
                return xmlNode;
            }
            if (xmlNode.getChildElements().isEmpty()) {
                if (xmlNode.getName() == label) {
                    return xmlNode;
                } else {
                    return null;
                }
            } else {
                for (dom.XMLNode child : xmlNode.getChildElements()) {
                    if (child.getName() == label) {
                        return child;
                    } else {
                        for (dom.XMLNode grandChild : child.getChildElements()) {
                            if (findRootListInXML(label, grandchild) != null) {
                                return findRootListInXML(label, grandchild);
                            }
                        }
                    }
                }
            }
        }

        return null;
    }

    public static Map<String, Map<String, String>> getValuesForListOfXMLElements(String rootLabel, Set<String> labels, HttpResponse res){
            List<dom.XMLNode> root = getRootList(rootLabel, res);
            String responseStatus = res.getStatus();
            Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
            if(!labels.isEmpty()){
                if(root != null){
                    for(dom.XMLNode r : root){
                        Map<String, String> item = new Map<String, String>();
                        for(String label :labels){
                            item.put(label, findValueInXML(label, r));
                        }
                        item.put('responseStatus', responseStatus);
                        result.put(r.getAttribute('ID', null) ,item);
                    }
                }
            }
            return result;
        }
        
    private static String findValueInXML(String label, dom.XMLNode xmlNode) {
        if (xmlNode != null) {
            if (xmlNode.getChildElements().isEmpty()) {
                if (xmlNode.getName() == label) {
                    return xmlNode.getText();
                } else {
                    return null;
                }
            } else {
                for (dom.XMLNode child : xmlNode.getChildElements()) {
                    if (child.getName() == label) {
                        return child.getText();
                    } else {
                        for (dom.XMLNode grandChild : child.getChildElements()) {
                            if (findValueInXML(label, grandchild) != null) {
                                return findValueInXML(label, grandchild);
                            }
                        }
                    }
                }
            }
        }

        return null;
    }
}