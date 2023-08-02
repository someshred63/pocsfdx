/** @date 2/20/2013
* @Author Pawel Sprysak
* @description Class with VDST Util methods
*/
public without sharing class VDST_Utils {
    public static final String GENENTECH_CODE             = 'GNE';
    public static final String PROVISIONER_NAME           = 'Provisioner';
    public static final String VDST_PERMISSION_SET_NAME   = 'VDST_Permission_Set_gne';
    // Status data
    public static final String EVENT_STATUS_CANCEL        = 'CANCEL';
    public static final String EVENT_STATUS_CLOSED        = 'CLOSED';
    // Common
    public static final List<String> EVENT_ADBOAD_TRANSACTIONS      = new List<String> { 'HCPTRVL', 'HCPLODGNG', 'OOPTRVL', 'OOPLODGNG', 'OOPMEALS', 'OOPOTHR', 'HONORARIA' }; // Code Sequence like in CSV
    public static final List<String> EVENT_NONRESEARCH_TRANSACTIONS = new List<String> { 'CHARITY', 'HONORARIA', 'FCLTYFEE', 'HCPMEALS', 'GRANT', 'SVCFEE', 'NONACRDFEE', 'OOPTRVL', 'OOPLODGNG', 'OOPMEALS', 'OOPOTHR', 'ROYALTY' };
    public static final List<String> EVENT_SS_TRANSACTIONS          = new List<String> { 'ECOUPON', 'JRNLRPRT', 'MEDWRTG', 'TXTBOOK' };
    // Event Transaction Types
    public static final String EVT_HCP_MEALS_TXN        = 'EVTHCPMLS';
    public static final String EVT_HCP_TOTAL_TXN        = 'TOTLHCPEVT';
    /**
     * AGGSPENDME-166: AdBoard event related auxiliary transaction codes.
     */
    public static final Set<String> ADBOARD_AUX_TXNS = new Set<String>{
        EVT_HCP_TOTAL_TXN,
        EVT_HCP_MEALS_TXN
    };
    /**
     * AGGSPENDME-166: Transactions ignored in total calculations for ABM events.
     */
    public static final Map<String, Set<String>> TOTAL_CALC_EXCLUDED_TXNS = new Map<String, Set<String>>{
        EVT_HCP_TOTAL_TXN => new Set<String>{
            'EVTMEALS',
            'VENUEAV'
        },
        'TOTALEVENT' => new Set<String>{
            EVT_HCP_MEALS_TXN
        }
    };
    /**
     * AGGSPENDME-166: Used by VDST_TotalValUpdates trigger to prevent its circular execution.
     */
    public static final Map<Id, String> RECURSED_EVT_TXNS = new Map<Id, String>();

    public static final Map<Boolean, Map<String, String>> EVT_TXNS_MAPPING = new Map<Boolean, Map<String, String>>{
        true => new Map<String, String>{
            // NonResearch Spends
            'CHARITY' => 'EVTCHARITY',
            'HONORARIA' => 'EVTHNRAR',
            'FCLTYFEE' => 'EVTFCLTY',
            'HCPMEALS' => 'EVTMEALS',
            'GRANT' => 'EVTGRANT',
            'SVCFEE' => 'EVTSVCFEE',
            'NONACRDFEE' => 'EVTNONACRD',
            'OOPTRVL' => 'EVTOOPTRVL',
            'OOPLODGNG' => 'EVTOOPLODG',
            'OOPMEALS' => 'EVTOOPMEAL',
            'OOPOTHR' => 'EVTOOPOTHR',
            'ROYALTY' => 'EVTRYLTY'
        },
        false => new Map<String, String>{
            // Std Spends
            'ADBOARD_HCPMEALS_CNTRCTD' => EVT_HCP_MEALS_TXN, // AGGSPENDME-166
            'HCPTRVL' => 'EVTHCPTRVL',
            'HCPLODGNG' => 'HOTEL',
            'OOPTRVL' => 'EVTOOP',
            'OOPLODGNG' => 'EVTOOP',
            'OOPMEALS' => 'EVTOOP',
            'OOPOTHR' => 'EVTOOP',
            'HONORARIA' => 'EVTFEES',
            // Single Spends
            'ECOUPON' => 'TOTECOUPON',
            'JRNLRPRT' => 'TOTJRNLRPRT',
            'TXTBOOK' => 'TOTTXTBOOK',
            'MEDWRTG' => 'TOTMEDWRTG',
            // Research Spends
            'PRECLINCL' => 'EVTPRECLINCL',
            'RSCH' => 'EVTRSCH'
        }
    };

    /** @date 4/19/2013
    * @Author Pawel Sprysak
    * @description  Get Salesforce Environment Name
    * @return String
    */
    public static String getEnvName() {
        String env ='prod';
        String userName = Userinfo.getUsername();
        if (userName != '') {
            if (userName.lastIndexOf('.') > 0) {
                env = userName.substring(userName.lastIndexOf('.')+1, userName.length());
            }
        }
        if ('com'.equalsIgnoreCase(env) || 'org'.equalsIgnoreCase(env) || 'net'.equalsIgnoreCase(env) || env.length() < 3) {
            env = 'prod';
        }
        return env;
    }

    /** @date 4/19/2013
    * @Author Pawel Sprysak
    * @description  Get Custom Settings
    * @return VDST_Settings__c
    */
    public static VDST_Settings__c getCustomSettingsIntExt() {
        if (Site.getDomain() != null) {
            return getCustomSettingsInSite();
        } else {
            return getCustomSettings();
        }
    }

    /** @date 4/19/2013
    * @Author Pawel Sprysak
    * @description  Get Environment Domain
    * @return VDST_Settings__c
    */
    public static VDST_Settings__c getCustomSettings() {
        MAP<String,VDST_Settings__c> domains = VDST_Settings__c.getAll();
        for (VDST_Settings__c env_domain : domains.values()) {
            if (getEnvName().equals(env_domain.Name)){
                return env_domain;
            }
        }
        return null;
    }

    /** @date 4/19/2013
    * @Author Pawel Sprysak
    * @description  Get Environment Domain in Site
    * @return VDST_Settings__c
    */
    public static VDST_Settings__c getCustomSettingsInSite()
    {
        MAP<String,VDST_Settings__c> domains = VDST_Settings__c.getAll();
        for (VDST_Settings__c env_domain : domains.values())
        {
            if (env_domain.Site_Domain__c != null)
            {
                if (env_domain.Site_Domain__c.contains(Site.getDomain()))
                {
                    return env_domain;
                }
            }
        }
        return null;
    }

    /** @date 4/19/2013
    * @Author Pawel Sprysak
    * @description  Get User Data by Unix Id
    * @param String unixId
    * @return All_User_Hierarchy_gne__c
    */
    public static All_User_Hierarchy_gne__c getUserData(String unixId) {
        try {
            if (!String.isBlank(unixId)) {
                return [SELECT FirstName_gne__c, LastName_gne__c, User_External_Id_gne__c FROM All_User_Hierarchy_gne__c WHERE User_External_Id_gne__c LIKE :unixId LIMIT 1];
            } else {
                return null;
            }
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 8/25/2014
    * @Author Konrad Malinowski
    * @description Method for checking if Participant Unix Id is Unique In Event
    * @param String eventId
    * @param String participantId
    * @param String unixId
    * @return Boolean
    */
    public static Boolean isParticipantUnixIdUniqueInEvent(String eventId, String participantId, String unixId) {
        try {
            return [
                SELECT  Id
                FROM    VDST_EventPrtcpntAccnt_gne__c
                WHERE   VDST_Event_gne__c = :eventId
                AND     Id != :participantId
                AND     UnixID_gne__c = :unixId
                LIMIT 1
            ].size() == 0;
        } catch (QueryException e) {
            return true;
        }
    }

    /** @date 6/27/2013
    * @Author Pawel Sprysak
    * @description  Get Users Data by Unix Id
    * @param List<String> unixIds
    * @return Map<String, All_User_Hierarchy_gne__c>
    */
    public static Map<String, All_User_Hierarchy_gne__c> getUsersData(List<String> unixIds) {
        try {
            if (unixIds != null) {
                Map<String, All_User_Hierarchy_gne__c> userMap = new Map<String, All_User_Hierarchy_gne__c>();
                for (All_User_Hierarchy_gne__c userH : [SELECT FirstName_gne__c, LastName_gne__c, User_External_Id_gne__c FROM All_User_Hierarchy_gne__c WHERE User_External_Id_gne__c IN :unixIds]) {
                    userMap.put(userH.User_External_Id_gne__c.toLowerCase(), userH);
                }
                return userMap;
            } else {
                return null;
            }
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 10/29/2013
    * @Author Pawel Sprysak
    * @description Get flag for Standard Event Types
    * @param String eventTypeCode
    * @return Boolean
    */
    public static Boolean isStdEventType(String eventTypeCode) {
        if ('ADBOARD'.equals(eventTypeCode) || 'MISCEVENT'.equals(eventTypeCode) || 'ISTGRMTG'.equals(eventTypeCode) || 'CFF'.equals(eventTypeCode)) {
            return true;
        }
        return false;
    }

    /** @date 8/4/2014
    * @Author Pawel Sprysak
    * @description Get flag for Standard Event Types (without CFF)
    * @param String eventTypeCode
    * @return Boolean
    */
    public static Boolean isNewStdEventType(String eventTypeCode) {
        if ('ADBOARD'.equals(eventTypeCode) || 'MISCEVENT'.equals(eventTypeCode) || 'ISTGRMTG'.equals(eventTypeCode)) {
            return true;
        }
        return false;
    }

    /** @date 10/29/2013
    * @Author Pawel Sprysak
    * @description Get flag for Single Spend Event Types
    * @param String eventTypeCode
    * @return Boolean
    */
    public static Boolean isSSEventType(String eventTypeCode) {
        if ('MEDWRTG'.equals(eventTypeCode) || 'BOOK'.equals(eventTypeCode) || 'JOURNAL'.equals(eventTypeCode) || 'ECOUPON'.equals(eventTypeCode)) {
            return true;
        }
        return false;
    }

    /** @date 10/29/2013
    * @Author Pawel Sprysak
    * @description Get flag for Research Event Types
    * @param String eventTypeCode
    * @return Boolean
    */
    public static Boolean isResearchEventType(String eventTypeCode) {
        if ('RSCH'.equals(eventTypeCode)) {
            return true;
        }
        return false;
    }

    /** @date 10/29/2013
    * @Author Pawel Sprysak
    * @description Get flag for Non-Research Event Types
    * @param String eventTypeCode
    * @return Boolean
    */
    public static Boolean isNonResearchEventType(String eventTypeCode) {
        if ('INDVSPND'.equals(eventTypeCode)) {
            return true;
        }
        return false;
    }

    /** @date 9/30/2013
    * @Author Pawel Sprysak
    * @description  Get Role Map by Event Type
    * @param String eventTypeCode
    * @return Map<String, String>
    */
    public static Map<String, String> getBatchRoleMap(String eventTypeCode) {
        Map<String, Id> roleMap = new Map<String, Id>();
        for (VDST_EventPrtcpntRole_gne__c role : [SELECT Id, EventParticipantRoleCode_gne__c FROM VDST_EventPrtcpntRole_gne__c WHERE EventType_gne__c = :eventTypeCode]) {
            roleMap.put(role.EventParticipantRoleCode_gne__c, role.Id);
        }
        return roleMap;
    }

    /** @date 9/30/2013
    * @Author Pawel Sprysak
    * @description  Get Mapping from Event to Expense Type
    * @return Map<String, String>
    */
    public static Map<String, String> eventToExpenseTypeMap() {
        Map<String, String> eventToExpenseTypeMap = new Map<String, String>{
            'ECOUPON'   => 'ECOUPON',
            'JOURNAL'   => 'JRNLRPRT',
            'MEDWRTG'   => 'MEDWRTG',
            'RSCH'      => 'RSCH',
            'BOOK'      => 'TXTBOOK',
            'CFF'       => 'HCPMEALS'
        };
        return eventToExpenseTypeMap;
    }

    /** @date 10/20/2013
    * @Author Konrad Malinowski
    * @description  Get Mapping from Expense Type Code To Name
    * @return Map<String, String>
    */
    public static Map<String, String> expenseTypeCodeToNameMap() {
        Map<String, String> expenseTypeCodeToNameMap = new Map<String, String>{
            'ECOUPON'       => 'e-Coupon',
            'JRNLRPRT'      => 'Journal Reprint',
            'MEDWRTG'       => 'Medical Editing Support',
            'RSCH'          => 'Research',
            'TXTBOOK'       => 'Textbook',
            'HCPMEALS'    => 'Daily Event Meals'
        };
        return expenseTypeCodeToNameMap;
    }

    /** @date 2/20/2013
    * @Author Pawel Sprysak
    * @description  Method for getting Picklist BY Field Description
    * @param Schema.DescribeFieldResult fieldResult
    * @return List<SelectOption>
    */
    public static List<SelectOption> getPickListValues(Schema.DescribeFieldResult fieldResult) {
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.Picklistentry p : fieldResult.getPicklistValues()) {
            options.add(new SelectOption(p.getValue(), p.getValue()));
        }
        return options;
    }

    /** @date 2/20/2013
    * @Author Pawel Sprysak
    * @description  Method for getting Picklist List BY Field Description
    * @param Schema.DescribeFieldResult fieldResult
    * @return List<String>
    */
    public static Map<String, String> getPickListMap(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> values = new Map<String, String>();
        for (Schema.Picklistentry p : fieldResult.getPicklistValues()) {
            values.put(p.getValue(), p.getValue());
        }
        return values;
    }

    /** @date 5/20/2013
    * @Author Pawel Sprysak
    * @description  Method for getting Select Option List by picklist and custom settings
    * @param Schema.DescribeFieldResult fieldResult,
    * @return List<SelectOption>
    */
    public static List<SelectOption> getMappedSelectOption(Schema.DescribeFieldResult fieldResult, Map<String, VDST_Mapping_gne__c> mapping) {
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.Picklistentry p : fieldResult.getPicklistValues()) {
            if (mapping.containsKey(p.getValue())) {
                options.add(new SelectOption(p.getValue(), mapping.get(p.getValue()).LabelValue_gne__c));
            } else {
                options.add(new SelectOption(p.getValue(), p.getValue()));
            }
        }
        return options;
    }

    /** @date 11/8/2013
    * @Author Pawel Sprysak
    * @description  Method for sorting Select Option values
    * @param List<SelectOption> notSortedList
    * @return List<SelectOption>
    */
    public static List<SelectOption> getSortedSOListByLabel(List<SelectOption> notSortedList) {
        List<SelectOption> sortedList = new List<SelectOption>();
        Map<String, String> valueToCodeMap = new Map<String, String>();
        for (SelectOption so : notSortedList) {
            valueToCodeMap.put(so.getLabel(), so.getValue());
        }
        if (notSortedList.size() != valueToCodeMap.keySet().size()) {
            return notSortedList;
        }
        List<String> listOfSortedValues = new List<String>();
        listOfSortedValues.addAll(valueToCodeMap.keySet());
        listOfSortedValues.sort();
        for (String label : listOfSortedValues) {
            sortedList.add(new SelectOption(valueToCodeMap.get(label), label));
        }
        return sortedList;
    }

    /** @date 2/20/2013
    * @Author Pawel Sprysak
    * @description Only detail type products not owned by GNE-SFA-Canada-Queue are part of display list. Product name needs
    * to be truncated till first '-' and the list should not contain duplicates.
    * @return Map<SelectOption>
    */
    public static List<SelectOption> getDrugNames() {
        try {
            List<SelectOption> result = new List<SelectOption>();
            Set<String> uniqueValues = new Set<String>();
            for (Product_vod__c product : [
                    SELECT Id, Name
                    FROM Product_vod__c
                    WHERE Product_Type_vod__c = 'Detail' AND Detail_Product_Subtype_Code_gne__c = 'Brand' AND Brand_Code_gne__c != NULL AND Region_Code_gne__c = 1
                    ORDER BY Name
            ]) {
                if (uniqueValues.add(product.Name.toLowerCase())) {
                    result.add(new SelectOption(product.Id, product.Name));
                }
            }
            return result;
        } catch (QueryException e) {
            return new List<SelectOption>();
        }
    }

    /** @date 2/20/2013
    * @Author Pawel Sprysak
    * @description Method for getting Map of Drug Names
    * @return Map<String,String>
    */
    public static Map<String,String> getMapOfDrugNames() {
        try {
            Map<String,String> result = new Map<String,String>();
            for (SelectOption product : getDrugNames()) {
                result.put(product.getLabel(), product.getValue());
            }
            return result;
        } catch (QueryException e) {
            return new Map<String,String>();
        }
    }

    /** @date 2/20/2013
    * @Author Pawel Sprysak
    * @description Method for getting State Names for Select List
    * @return List<SelectOption>
    */
    public static List<SelectOption> getStatesNames() {
        Map<String, String> stateMap = getStatesMap();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-Select-'));
        for (String stateCode : stateMap.keySet()) {
            options.add(new SelectOption(stateCode, stateMap.get(stateCode)));
        }
        return options;
    }

    /** @date 7/3/2013
    * @Author Pawel Sprysak
    * @description Sorting SelectOption
    * @param List<SelectOption>
    * @return List<SelectOption>
    */
    public static List<SelectOption> selectOptionSortByLabel(List<SelectOption> selectOptionsToSort) {
        if (selectOptionsToSort == null || selectOptionsToSort.size() <= 1) {
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        Integer pivot = selectOptionsToSort.size() / 2;
        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];
        selectOptionsToSort.remove(pivot);
        for (selectOption SO : selectOptionsToSort) {
            if (SO.getLabel() <= pivotValue.getLabel()) {
                lessSelectOption.add(SO);
            } else if (SO.getLabel() > pivotValue.getLabel()) {
                greaterSelectOption.add(SO);
            }
        }
        List<SelectOption> sortedSelectOptions = new List<SelectOption>();
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return sortedSelectOptions;
    }

    /** @date 5/22/2013
    * @Author Pawel Sprysak
    * @description Method for getting map of State Codes/Names
    * @return Map<String, String>
    */
    public static Map<String, String> getStatesMap() {
        final Map<String, String> results = new Map<String, String>();
        for (VDST_States__c state : VDST_States__c.getAll().values()) {
            results.put(state.Code__c, state.Name);
        }
        return results;
    }

    /** @date 5/22/2013
    * @Author Pawel Sprysak
    * @description Method for getting inverse map of State Codes/Names
    * @return Map<String, String>
    */
    public static Map<String, String> getInverseStatesMap() {
        final Map<String, String> results = new Map<String, String>();
        for (VDST_States__c state : VDST_States__c.getAll().values()) {
            results.put(state.Name.toLowerCase(), state.Code__c);
        }
        return results;
    }

    /** @date 6/26/2014
    * @Author Konrad Malinowski
    * @description Method for getting State Upper Code from any case of Code or Name of State
    * @param String stateVal
    * @return String
    */
    public static String convertStateToUpperCode(String stateVal) {
        String blankState = '';
        if (String.isBlank(stateVal)) {
            return blankState;
        }
        stateVal = stateVal.trim();
        String stateCode = stateVal.toUpperCase();
        String stateCodeFromName = getInverseStatesMap().get( stateVal.toLowerCase());
        Boolean isStateCode = (getStatesMap().get(stateCode) != null);
        Boolean isStateName = (stateCodeFromName != null);
        return isStateCode ? stateCode : (isStateName ? stateCodeFromName : blankState);
    }

    /** @date 11/3/2013
    * @Author Pawel Sprysak
    * @description Wrapper class for User Privileges
    */
    public class PrivilegesWrapper extends VDST_PrivilegesWrapper {
        public PrivilegesWrapper() {
            isProxy = false;
            VDST_User_gne__c usrObj = VDST_Utils.getUserPrivilegesObj();
            if (usrObj != null) {
                userRole = usrObj.Role_gne__c;
                VDST_EventProvider_gne__c epObj = VDST_Utils.getUserGroupCode(usrObj);
                providerId = epObj.Id;
                providerCode = epObj.VendorCode_gne__c;
                providerName = epObj.VendorName_gne__c;
                providerFullName = epObj.VendorName_gne__c;
                isProxy = false;
                if (usrObj.VDST_Proxy_gne__c != null) {
                    providerFullName += ' (Genentech)';
                    isProxy = true;
                }
                hasPrivileges = true;
            } else {
                hasPrivileges = false;
            }
        }
    }

    /** @date 4/11/2013
    * @Author Pawel Sprysak
    * @description Get logged user privileges
    * @return List<VDST_User_gne__c>
    */
    public static List<VDST_User_gne__c> getUserPrivileges() {
        try {
            return [SELECT Id, Role_gne__c, User_gne__c, VDST_Proxy_gne__c, VDST_Proxy_gne__r.VendorCode_gne__c, VDST_Proxy_gne__r.VendorName_gne__c, VDST_Event_Provider__c, VDST_Event_Provider__r.VendorCode_gne__c, VDST_Event_Provider__r.VendorName_gne__c FROM VDST_User_gne__c WHERE User_gne__c = :UserInfo.getUserId()];
        } catch (QueryException e) {
            return new List<VDST_User_gne__c>();
        }
    }

    /** @date 9/26/2013
    * @Author Pawel Sprysak
    * @description Get logged user privileges
    * @return VDST_User_gne__c
    */
    public static VDST_User_gne__c getUserPrivilegesObj() {
        List<VDST_User_gne__c> privileges = getUserPrivileges();
        if (privileges.size() > 0) {
            return privileges.get(0);
        }
        return null;
    }

    /** @date 9/26/2013
    * @Author Pawel Sprysak
    * @description Get logged user Provider object
    * @return VDST_EventProvider_gne__c
    */
    public static VDST_EventProvider_gne__c getUserGroupCode(VDST_User_gne__c usrPrivileges) {
        if (usrPrivileges.VDST_Proxy_gne__c == null) {
            return new VDST_EventProvider_gne__c(Id = usrPrivileges.VDST_Event_Provider__c, VendorCode_gne__c = usrPrivileges.VDST_Event_Provider__r.VendorCode_gne__c, VendorName_gne__c = usrPrivileges.VDST_Event_Provider__r.VendorName_gne__c);
        } else {
            return new VDST_EventProvider_gne__c(Id = usrPrivileges.VDST_Proxy_gne__c, VendorCode_gne__c = usrPrivileges.VDST_Proxy_gne__r.VendorCode_gne__c, VendorName_gne__c = usrPrivileges.VDST_Proxy_gne__r.VendorName_gne__c);
        }
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak
    * @description Get logged user privileges
    * @param String evProviderId (Event Provider Id)
    * @return List<VDST_User_gne__c>
    */
    public static List<VDST_User_gne__c> getAllRelatedUsers(String evProviderId) {
        try {
            return [SELECT Id, User_gne__r.Name, Role_gne__c, User_gne__r.Email, User_gne__r.Username FROM VDST_User_gne__c WHERE VDST_Event_Provider__c = :evProviderId ORDER BY User_gne__r.Username];
        } catch (QueryException e) {
            return new List<VDST_User_gne__c>();
        }
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak
    * @description Get logged user privileges
    * @param String userId (User Id)
    * @return VDST_User_gne__c
    */
    public static VDST_User_gne__c getUserRelationById(String userId) {
        try {
            return [SELECT Id, User_gne__c FROM VDST_User_gne__c where Id = :userId];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak, Marcin Pawlak
    * @description Method for checking is Assignment already exist
    * @param VDST_User_gne__c usr (User Relation object)
    * @return Boolean
    */
    public static Boolean checkIfAssignmentExists(VDST_User_gne__c usr) {
        try {
            List<VDST_User_gne__c> usrs = [SELECT Id FROM VDST_User_gne__c where VDST_Event_Provider__c =: usr.VDST_Event_Provider__c and User_gne__c =: usr.User_gne__c and Role_gne__c =: usr.Role_gne__c];
            return (usrs != null && usrs.size() > 0);
        } catch (QueryException e) {
            return true;
        }
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak, Marcin Pawlak
    * @description Method for checking is User assigned to other group
    * @param VDST_User_gne__c usr (User Relation object)
    * @return String
    */
    public static String checkIfAssignedToOtherGroup(VDST_User_gne__c usr) {
        try {
            List<VDST_User_gne__c> usrs = [SELECT Id, VDST_Event_Provider__r.VendorName_gne__c, VDST_Event_Provider__r.VendorCode_gne__c FROM VDST_User_gne__c where User_gne__c =: usr.User_gne__c];
            if (usrs != null && usrs.size() > 0) {
                return usrs.get(0).VDST_Event_Provider__r.VendorCode_gne__c + ' - ' + usrs.get(0).VDST_Event_Provider__r.VendorName_gne__c;
            }
            return null;
        } catch (QueryException e) {
            return 'Unknown';
        }
    }

    /** @date 4/4/2013
    * @Author Pawel Sprysak
    * @description Get Event Status History By Event Id
    * @param Id eventId (Event Id)
    * @return List<VDST_Event_gne__History>
    */
    public static List<VDST_Event_gne__History> getEventHistoryByEventId(Id eventId) {
        try {
            return [SELECT Id, Field, CreatedDate, CreatedBy.Name, NewValue, OldValue FROM VDST_Event_gne__History WHERE (Field = 'CurrentStatus_gne__c' OR Field = 'created') AND ParentId = :eventId ORDER BY CreatedDate DESC];
        } catch (QueryException e) {
            return new List<VDST_Event_gne__History>();
        }
    }

    /** @date 7/15/2014
    * @Author Konrad Malinowski
    * @description Method for getting Event Id To History Record Number Map
    * @param List<VDST_EventSite_gne__c>
    * @return Map<Id, Integer>
    */
    public static Map<Id, Integer> getEventIdToHistoryRecordNumberMap(List<VDST_EventSite_gne__c> sites) {
        Set<Id> eventIdSet = new Set<Id>();
        for (VDST_EventSite_gne__c s : sites) {
            eventIdSet.add(s.VDST_Event_gne__c);
        }
        Map<Id, Integer> evIdToEvHistRecNumMap = new Map<Id, Integer>();
        for (VDST_Event_gne__History eH : [
            SELECT  ParentId
            FROM    VDST_Event_gne__History
            WHERE   (Field = 'CurrentStatus_gne__c' OR Field = 'created')
            AND     ParentId IN :eventIdSet
        ]) {
            if ( evIdToEvHistRecNumMap.get(eH.ParentId) == null) {
                evIdToEvHistRecNumMap.put( eH.ParentId, 0);
            }
            evIdToEvHistRecNumMap.put( eH.ParentId, ( evIdToEvHistRecNumMap.get(eH.ParentId) + 1));
        }
        return evIdToEvHistRecNumMap;
    }

    /** @date 4/7/2013
    * @Author Pawel Sprysak
    * @description Get Total Planned Attendee Count
    * @param Id eventId (Event Id)
    * @return Decimal
    */
    public static Decimal getTotalPlannedAttCount(Id eventId) {
        try {
            return [SELECT TotalPlannedAttendeeCount_gne__c FROM VDST_Event_gne__c WHERE Id = :eventId LIMIT 1].TotalPlannedAttendeeCount_gne__c;
        } catch (QueryException e) {
            return 0;
        }
    }

    /** @date 2/28/2013
    * @Author Pawel Sprysak
    * @description Get Event Details By Id
    * @param Id eventId (Event Id)
    * @return VDST_Event_gne__c
    */
    public static VDST_Event_gne__c getEventById(Id eventId) {
        try {
            return [SELECT Id, Name, AccountableGNE_FirstName_gne__c, AccountableGNE_LastName_gne__c, AccountableGNE_UnixID_gne__c,
                        Comment_gne__c, ContentVendor_gne__c, ContentVendorCode_gne__c, ContentVendorName_gne__c,
                        CurrentStatus_gne__c, CurrentStatusDate_gne__c, EventEndDate_gne__c, EventMeetingName_gne__c,
                        EventStartDate_gne__c, EventTimeZone_gne__c, EventType_gne__c, Function_gne__c, GNE_EventID_gne__c,
                        GL_Code_gne__c, GL_Description_gne__c, HasException_gne__c, InvitationSentDate_gne__c, Invoice_ID_gne__c,
                        ItemAmount_gne__c, ItemCode_gne__c, ItemName_gne__c, ProtocolID_gne__c, ResearchPaymentTypeCode_gne__c,
                        Site_ID_gne__c, Source_Product_Name_gne__c, MostRecentDisputeName_gne__c, OtherIDs_gne__c, Region_Code_gne__c,
                        TotalAudioVisual_gne__c, TotalPlannedAttendeeCount_gne__c, VendorEventID_gne__c, LogisticVendor_gne__c,
                        LogisticVendorCode_gne__c, LogisticVendorName_gne__c, Study_Location_gne__c, Study_Manager_Email_gne__c,
                        TotPlanAttCntUser_gne__c, StudyDescription_gne__c, SupplementStatusCode_gne__c, ThemeNumber_gne__c, TransactionID_gne__c,
                        TransactionSource_gne__c, TrialStatus_gne__c, Legal_Entity_Company_Code_gne__c, Legal_Entity_Company_Name_gne__c,
                        Legal_Entity_Company_Location_gne__c, WBS_Element_gne__c, WBS_Description_gne__c, Delayed_Payment_Indicator_gne__c,
                        CMS_Payment_ID_gne__c, Home_Payment_ID_gne__c, IsBatch_gne__c, IsABMevent_gne__c,
                        PO_number_gne__c,           // AGGSPENDME-179
                        SourceTransactionID_gne__c,  // AGGSPENDME-155, AGGSPENDME-188
                        MealLoc_gne__c
                    FROM VDST_Event_gne__c
                    WHERE Id = :eventId LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 5/24/2013
    * @Author Pawel Sprysak
    * @description Get Event Codes By Id
    * @param Id eventId (Event Id)
    * @return VDST_Event_gne__c
    */
    public static VDST_Event_gne__c getEventCodesById(Id eventId) {
        try {
            return [SELECT Id, Name, LogisticVendorCode_gne__c, CurrentStatus_gne__c FROM VDST_Event_gne__c WHERE Id = :eventId LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 2/28/2013
    * @Author Pawel Sprysak
    * @description Get Event Information By Id
    * @param Id eventId (Event Id)
    * @return VDST_Event_gne__c
    */
    public static VDST_Event_gne__c getEventInfo(Id eventId) {
        try {
            return [SELECT CreatedDate, CreatedBy.Name, CreatedByName_gne__c, LastModifiedDate, LastModifiedBy.Name, LastModifiedByName_gne__c FROM VDST_Event_gne__c WHERE Id = :eventId LIMIT 1];
        } catch (QueryException e) {
            return new VDST_Event_gne__c();
        }
    }

    /** @date 3/29/2013
    * @Author Pawel Sprysak
    * @description Get Event Start and End Date By Id
    * @param Id eventId (Event Id)
    * @return VDST_Event_gne__c
    */
    public static VDST_Event_gne__c getEventStartEndDateById(Id eventId) {
        try {
            return [SELECT EventStartDate_gne__c, EventEndDate_gne__c, Id FROM VDST_Event_gne__c WHERE Id = :eventId];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 3/20/2013
    * @Author Pawel Sprysak
    * @description Get Event Type by Event Id
    * @param String eventId (Event Id)
    * @return VDST_Event_gne__c
    */
    public static String getEventTypeByEventId(String eventId) {
        try {
            return [SELECT EventType_gne__c FROM VDST_Event_gne__c WHERE Id = :eventId LIMIT 1].EventType_gne__c;
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 2/28/2013
    * @Author Pawel Sprysak
    * @description Get Event Site By Event Id
    * @param Id eventId (Event Id)
    * @return VDST_EventSite_gne__c
    */
    public static VDST_EventSite_gne__c getEventSiteByEventId(Id eventId) {
        try {
            return [SELECT Id, VDST_Address_gne__c, EventSiteName_gne__c FROM VDST_EventSite_gne__c WHERE VDST_Event_gne__c = :eventId LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 2/28/2013
    * @Author Pawel Sprysak
    * @description Get Address By Id
    * @param String addressId (Address Id)
    * @return VDST_Address_gne__c
    */
    public static VDST_Address_gne__c getAddressById(String addressId) {
        try {
            return [SELECT Id, Name, AddressType_gne__c, City_gne__c, Country_gne__c, StatesNameHolder_gne__c, PostalCode_gne__c, StateProvince_gne__c, StreetAddress_gne__c, StreetAddress2_gne__c FROM VDST_Address_gne__c WHERE Id = :addressId LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 2/28/2013
    * @Author Pawel Sprysak
    * @description Get Brand Topic List By Event Id
    * @param Id eventId (Event Id)
    * @return List<VDST_EventBrandTopic_gne__c>
    */
    public static List<VDST_EventBrandTopic_gne__c> getBrandTopicList(Id eventId) {
        try {
            return [SELECT Id, Product_Catalog_gne__c FROM VDST_EventBrandTopic_gne__c WHERE VDST_Event_gne__c = :eventId];
        } catch (QueryException e) {
            return new List<VDST_EventBrandTopic_gne__c>();
        }
    }

    /** @date 2/28/2013
    * @Author Pawel Sprysak
    * @description Get Event Date Transactions By Event Id
    * @param Id eventId (Event Id)
    * @return List<VDST_EventDateTransaction_gne__c>
    */
    public static List<VDST_EventDateTransaction_gne__c> getEventDateTransactions(Id eventId) {
        try {
            return [SELECT Id, EventDateTransactionAmount_gne__c, EventDateTransactionTypeCode_gne__c, NumberOfMeals_gne__c, VDST_EventDate_gne__r.EventDate_gne__c, VDST_EventDate_gne__r.ActualAttendeeRollup_gne__c FROM VDST_EventDateTransaction_gne__c WHERE VDST_EventDate_gne__r.VDST_Event_gne__c = :eventId ORDER BY VDST_EventDate_gne__r.EventDate_gne__c ASC];
        } catch (QueryException e) {
            return new List<VDST_EventDateTransaction_gne__c>();
        }
    }

    /** @date 3/13/2013
    * @Author Pawel Sprysak
    * @description Get Event Date Transactions By Event Date Id Set
    * @param Set<Id> eventDateIds (Event Date Id Set)
    * @return List<VDST_EventDateTransaction_gne__c>
    */
    public static List<VDST_EventDateTransaction_gne__c> getEvDateTransIdsByEvDateIds(Set<Id> eventDateIds) {
        try {
            return [SELECT Id FROM VDST_EventDateTransaction_gne__c WHERE VDST_EventDate_gne__c IN :eventDateIds];
        } catch (QueryException e) {
            return new List<VDST_EventDateTransaction_gne__c>();
        }
    }

    /** @date 3/25/2013
    * @Author Pawel Sprysak
    * @description Preparing new Attendance list based on new Event Date records
    * @description Method used in: VDST_ManageTransactions trigger
    * @param List<VDST_EventDate_gne__c> edList (List of Event Dates)
    * @return List<VDST_EventPrtcpntAttendance_gne__c>
    */
    public static List<VDST_EventPrtcpntAttendance_gne__c> prepareTriggerNewAttendanceList(List<VDST_EventDate_gne__c> edList) {
        // Generate Event Map with Event Date Id List
        Map<String, List<Id>> edMap = new Map<String, List<Id>>();
        for (VDST_EventDate_gne__c ed: edList) {
            if (!edMap.containsKey(ed.VDST_Event_gne__c)) {
                edMap.put(ed.VDST_Event_gne__c, new List<Id>{ed.Id});
            } else {
                edMap.get(ed.VDST_Event_gne__c).add(ed.Id);
            }
        }
        String eventType = edList.get(0).EventType_gne__c;
        // Generate Event Map with Participant Account Id List
        Map<String, List<Id>> epaMap = new Map<String, List<Id>>();
        for (VDST_EventPrtcpntAccnt_gne__c pa : VDST_Utils.getPrtcpntAccntByIdAndPartyType(edMap.keySet(), (!String.isBlank(eventType) && VDST_Utils.isStdEventType(eventType)))) {
            if (!epaMap.containsKey(pa.VDST_Event_gne__c)) {
                epaMap.put(pa.VDST_Event_gne__c, new List<Id>{pa.Id});
                if (pa.VDST_Event_gne__r.iAdviseEvent_gne__c == null) {
                    pa.VDST_Event_gne__r.iAdviseEvent_gne__c = false;
                }
            } else {
                epaMap.get(pa.VDST_Event_gne__c).add(pa.Id);
            }
        }
        // Generate Event Participant Attendance List to create
        List<VDST_EventPrtcpntAttendance_gne__c> newAttendance = new List<VDST_EventPrtcpntAttendance_gne__c>();
        for (String eventId : epaMap.keySet()) { // for each event
            for (String prtcpntId: epaMap.get(eventId)) { // for each Participant Account
                for (String eventDateId : edMap.get(eventId)) { // for each Event Date
                    String consumedStatus = 'CONSUMED';
                    newAttendance.add(new VDST_EventPrtcpntAttendance_gne__c(VDST_EventDate_gne__c = eventDateId, Event_PrtcpntAccnt_gne__c = prtcpntId, MealAmount_gne__c = 0, AttendanceStatus_gne__c = 'ATND', ParticipantMealConsumptionStatus_gne__c = consumedStatus));
                }
            }
        }
        return newAttendance;
    }

    /** @date 3/25/2013
    * @Author Pawel Sprysak
    * @description Modify Meal Amount for Participant before update
    * @description Method used in: VDST_UpdateAttendanceObj trigger
    * @param List<VDST_EventPrtcpntAttendance_gne__c> epaList, Map<Id,VDST_EventPrtcpntAttendance_gne__c> oldMap, Map<Id,VDST_EventPrtcpntAttendance_gne__c> newMap (Trigger params)
    */
    public static void changeMealAmountForPrtcpntBeforeModification(List<VDST_EventPrtcpntAttendance_gne__c> epaList, Map<Id,VDST_EventPrtcpntAttendance_gne__c> oldMap, Map<Id,VDST_EventPrtcpntAttendance_gne__c> newMap) {
        // When Attendance object statuses changed
        Set<Id> edSet = new Set<Id>();
        Set<Id> attChanged = new Set<Id>();
        Map<Id, Integer> attChangeMap = new Map<Id, Integer>();
        for (VDST_EventPrtcpntAttendance_gne__c epa : epaList) {
            edSet.add(epa.VDST_EventDate_gne__c);
            if ( oldMap.get(epa.Id).AttendanceStatus_gne__c != newMap.get(epa.Id).AttendanceStatus_gne__c) {
                Integer i = 'ATND'.equals(newMap.get(epa.Id).AttendanceStatus_gne__c) ? 1 : -1 ;
                if ( attChangeMap.containsKey(epa.VDST_EventDate_gne__c)) {
                    attChangeMap.put(epa.VDST_EventDate_gne__c, attChangeMap.get(epa.VDST_EventDate_gne__c)+i);
                } else {
                    attChangeMap.put(epa.VDST_EventDate_gne__c, i);
                }
            }
        }

        Map<Id, Decimal> prtcpntCountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> edtAmountMap = new Map<Id, Decimal>();
        for (VDST_EventDateTransaction_gne__c edt : [SELECT VDST_EventDate_gne__c, VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c, EventDateTransactionAmount_gne__c,
                                                            VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c,
                                                            VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c
                                                        FROM VDST_EventDateTransaction_gne__c
                                                        WHERE VDST_EventDate_gne__c IN :edSet]) {
            prtcpntCountMap.put(edt.VDST_EventDate_gne__c, edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c);
            edtAmountMap.put(edt.VDST_EventDate_gne__c, edt.EventDateTransactionAmount_gne__c);
            // API
            if (edt.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c) {
                Integer EventDateActualAttendeeCount = Integer.valueOf(edt.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c);
                if ( attChangeMap.containsKey(edt.VDST_EventDate_gne__c)) {
                    EventDateActualAttendeeCount += attChangeMap.get(edt.VDST_EventDate_gne__c);
                }
                if ( EventDateActualAttendeeCount > edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c ) {
                    prtcpntCountMap.put(edt.VDST_EventDate_gne__c, EventDateActualAttendeeCount);
                } else {
                    prtcpntCountMap.put(edt.VDST_EventDate_gne__c, edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c);
                }
                System.debug('CALC_UTO CHG: true; look later / ' + EventDateActualAttendeeCount + ' vs ' + edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c + ' for ' + edt.VDST_EventDate_gne__c);
            }
        }
        Map<Id, Map<Id, Id>> updatedEPA = new Map<Id, Map<Id, Id>>();
        List<VDST_EventPrtcpntAttendance_gne__c> epaListToUpdate = new List<VDST_EventPrtcpntAttendance_gne__c>();
        for (VDST_EventPrtcpntAttendance_gne__c epa : epaList) {
            if ( oldMap.get(epa.Id).AttendanceStatus_gne__c != newMap.get(epa.Id).AttendanceStatus_gne__c || oldMap.get(epa.Id).ParticipantMealConsumptionStatus_gne__c != newMap.get(epa.Id).ParticipantMealConsumptionStatus_gne__c) {
                VDST_EventPrtcpntAttendance_gne__c newEpa = new VDST_EventPrtcpntAttendance_gne__c(Id = epa.Id);
                if ( 'ATND'.equals(epa.AttendanceStatus_gne__c) && 'CONSUMED'.equals(epa.ParticipantMealConsumptionStatus_gne__c)
                        && edtAmountMap.get(epa.VDST_EventDate_gne__c) != null && prtcpntCountMap.get(epa.VDST_EventDate_gne__c) != null ) {
                    if ( prtcpntCountMap.get(epa.VDST_EventDate_gne__c) < 1 ) {
                        newEpa.MealAmount_gne__c = edtAmountMap.get(epa.VDST_EventDate_gne__c);
                    } else {
                        newEpa.MealAmount_gne__c = edtAmountMap.get(epa.VDST_EventDate_gne__c) / prtcpntCountMap.get(epa.VDST_EventDate_gne__c);
                    }
                    System.debug('CALC_UTO final1: ' + ', ' + edtAmountMap.get(epa.VDST_EventDate_gne__c) + ' / ' + prtcpntCountMap.get(epa.VDST_EventDate_gne__c) + ' for ' + epa.VDST_EventDate_gne__c);
                } else {
                    newEpa.MealAmount_gne__c = 0;
                }
                epaListToUpdate.add(newEpa);
                if (!updatedEPA.containsKey(epa.VDST_EventDate_gne__c)) {
                    updatedEPA.put(epa.VDST_EventDate_gne__c, new Map<Id, Id>());
                }
                updatedEPA.get(epa.VDST_EventDate_gne__c).put(epa.Id, epa.Id);
            }
        }
        for (VDST_EventPrtcpntAttendance_gne__c epa : [SELECT Id, VDST_EventDate_gne__c, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c FROM VDST_EventPrtcpntAttendance_gne__c WHERE VDST_EventDate_gne__c IN :updatedEPA.keySet()]) {
            if ( !updatedEPA.get(epa.VDST_EventDate_gne__c).containsKey(epa.Id)) {
                if ( 'ATND'.equals(epa.AttendanceStatus_gne__c) && 'CONSUMED'.equals(epa.ParticipantMealConsumptionStatus_gne__c)
                        && edtAmountMap.get(epa.VDST_EventDate_gne__c) != null && prtcpntCountMap.get(epa.VDST_EventDate_gne__c) != null ) {
                    if ( prtcpntCountMap.get(epa.VDST_EventDate_gne__c) < 1 ) {
                        epa.MealAmount_gne__c = edtAmountMap.get(epa.VDST_EventDate_gne__c);
                    } else {
                        epa.MealAmount_gne__c = edtAmountMap.get(epa.VDST_EventDate_gne__c) / prtcpntCountMap.get(epa.VDST_EventDate_gne__c);
                    }
                    System.debug('CALC_UTO final2: ' + ', ' + edtAmountMap.get(epa.VDST_EventDate_gne__c) + ' / ' + prtcpntCountMap.get(epa.VDST_EventDate_gne__c) + ' for ' + epa.VDST_EventDate_gne__c);
                } else {
                    epa.MealAmount_gne__c = 0;
                }
                epaListToUpdate.add(epa);
            }
        }
        if (epaListToUpdate.size() > 0) {
            update epaListToUpdate;
        }
    }

    public static void mealCalculationOnEvDateChange(Map<Id,VDST_EventDate_gne__c> oldMap, Map<Id,VDST_EventDate_gne__c> newMap) {
        List<Id> edIdsList = new List<Id>();
        for ( Id key: oldMap.keySet()) {
            // Only on Adboard we can change non-HCP counts
            if (oldMap.get(key).NonHcpActualAttendeeCount_gne__c != newMap.get(key).NonHcpActualAttendeeCount_gne__c && 'ADBOARD'.equals(newMap.get(key).EventType_gne__c)) {
                edIdsList.add(key);
            }
        }
        if (edIdsList.size() > 0) {
            // Meal Amount for Editable Participant Counts
            List<VDST_EventPrtcpntAttendance_gne__c> epaList = [SELECT Id, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__c FROM VDST_EventPrtcpntAttendance_gne__c WHERE VDST_EventDate_gne__c IN :edIdsList];
            List<VDST_EventDateTransaction_gne__c> edtList = [SELECT Id, VDST_EventDate_gne__c, EventDateTransactionAmount_gne__c, VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__c FROM VDST_EventDateTransaction_gne__c WHERE VDST_EventDate_gne__c IN :edIdsList];
            if (edtList.size() > 0 && epaList.size() > 0) {
                Integer attCount;
                for (VDST_EventDateTransaction_gne__c edt : edtList) {
                    attCount = Integer.valueOf(edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c);
                    for (VDST_EventPrtcpntAttendance_gne__c epa : epaList) {
                        if (epa.VDST_EventDate_gne__c == edt.VDST_EventDate_gne__c) {
                            if ('ATND'.equals(epa.AttendanceStatus_gne__c) && 'CONSUMED'.equals(epa.ParticipantMealConsumptionStatus_gne__c)) {
                                System.debug('CALC_MT, BEG: ' + edt.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c + '; ' + edt.EventDateTransactionAmount_gne__c + ' / ' + attCount + ' for ' + epa.VDST_EventDate_gne__c);
                                if (edt.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c) {
                                    if ( edt.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c > edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c ) {
                                        attCount = Integer.valueOf(edt.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c);
                                    } else {
                                        attCount = Integer.valueOf(edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c);
                                    }
                                    System.debug('CALC_MT, CHG: ' + edt.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c + '; ' + edt.EventDateTransactionAmount_gne__c + ' / ' + edt.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c + ' vs ' + edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c + ' for ' + epa.VDST_EventDate_gne__c);
                                }
                                if (attCount > 0) {
                                    epa.MealAmount_gne__c = edt.EventDateTransactionAmount_gne__c / attCount;
                                } else {
                                    epa.MealAmount_gne__c = edt.EventDateTransactionAmount_gne__c;
                                }
                            } else {
                                epa.MealAmount_gne__c = 0;
                            }
                        }
                    }
                }
            }
            update epaList;
        }
    }

    /** @date 3/31/2013
    * @Author Pawel Sprysak
    * @description Create or Update Total Summary value in Summary transaction object for Event
    * @description Method used in: VDST_TotalValUpdates trigger
    * @param Set<Id> eventIds
    */
    public static void updateTotalSummaryValue(Set<Id> eventIds) {
        // Create Map for Event Id's and List of Summary Transactions fot them
        if (eventIds.size() > 0) {
            final Map<Id, Decimal> initialTotals = new Map<Id, Decimal>();
            final VDST_EventTransactionSummary_gne__c[] modifiedTotals = new VDST_EventTransactionSummary_gne__c[]{ };
            final Map<Id, Map<String, VDST_EventTransactionSummary_gne__c>> sums = new Map<Id, Map<String, VDST_EventTransactionSummary_gne__c>>();
            final Map<Id, Map<String, VDST_EventTransactionSummary_gne__c>> totals = new Map<Id, Map<String, VDST_EventTransactionSummary_gne__c>>();
            for (VDST_EventTransactionSummary_gne__c sum : [
                SELECT EventTransactionTypeCode_gne__c, EventTransactionAmount_gne__c, VDST_Event_gne__r.IsABMEvent_gne__c
                FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c IN :eventIds
            ]) {
                if (totals.get(sum.VDST_Event_gne__c) == null) {
                    totals.put(sum.VDST_Event_gne__c, new Map<String, VDST_EventTransactionSummary_gne__c>{
                        'TOTALEVENT' => new VDST_EventTransactionSummary_gne__c(
                            EventTransactionTypeCode_gne__c = 'TOTALEVENT',
                            VDST_Event_gne__c = sum.VDST_Event_gne__c,
                            EventTransactionLevel_gne__c = 'EVNT'
                        )
                    });
                    // AGGSSPENDME-166: Calculate EVT_HCP_TOTAL_TXN for ADBOARD events only
                    if (sum.VDST_Event_gne__r.IsABMEvent_gne__c) {
                        totals.get(sum.VDST_Event_gne__c).put(EVT_HCP_TOTAL_TXN, new VDST_EventTransactionSummary_gne__c(
                            EventTransactionTypeCode_gne__c = EVT_HCP_TOTAL_TXN,
                            VDST_Event_gne__c = sum.VDST_Event_gne__c,
                            EventTransactionLevel_gne__c = 'EVNT'
                        ));
                    }
                }
                if (sum.EventTransactionTypeCode_gne__c == 'TOTALEVENT' ||
                    sum.EventTransactionTypeCode_gne__c == EVT_HCP_TOTAL_TXN
                ) {
                    totals.get(sum.VDST_Event_gne__c).put(sum.EventTransactionTypeCode_gne__c, sum);
                } else if (sums.containsKey(sum.VDST_Event_gne__c)) {
                    sums.get(sum.VDST_Event_gne__c).put(sum.EventTransactionTypeCode_gne__c, sum);
                } else {
                    sums.put(sum.VDST_Event_gne__c, new Map<String, VDST_EventTransactionSummary_gne__c>{
                        sum.EventTransactionTypeCode_gne__c => sum
                    });
                }
            }
            for (Id evtId : eventIds) {
                for (VDST_EventTransactionSummary_gne__c total : totals.get(evtId).values()) {
                    initialTotals.put(total.Id, total.EventTransactionAmount_gne__c);
                    total.EventTransactionAmount_gne__c = 0;
                }
                for (VDST_EventTransactionSummary_gne__c sum : sums.get(evtId).values()) {
                    for (String totalCode : totals.get(evtId).keySet()) {
                        if (!TOTAL_CALC_EXCLUDED_TXNS.get(totalCode).contains(sum.EventTransactionTypeCode_gne__c)) {
                            totals.get(evtId).get(totalCode).EventTransactionAmount_gne__c += sum.EventTransactionAmount_gne__c;
                        }
                    }
                }
                // create EVT_HCP_MEALS_TXN transaction if not exist
                if (sums.get(evtId).get(EVT_HCP_MEALS_TXN) == null &&
                    totals.get(evtId).containsKey(EVT_HCP_TOTAL_TXN) &&
                    RECURSED_EVT_TXNS.put(evtId, EVT_HCP_MEALS_TXN) == null
                ) {
                    modifiedTotals.add(new VDST_EventTransactionSummary_gne__c(
                        EventTransactionTypeCode_gne__c = EVT_HCP_MEALS_TXN,
                        EventTransactionLevel_gne__c = 'EVNT',
                        EventTransactionAmount_gne__c = 0,
                        VDST_Event_gne__c = evtId
                    ));
                }
                for (VDST_EventTransactionSummary_gne__c total : totals.get(evtId).values()) {
                    if (initialTotals.get(total.Id) != total.EventTransactionAmount_gne__c) {
                        modifiedTotals.add(total);
                    }
                }
            }
            upsert modifiedTotals;
        }
    }

    /** @date 3/31/2013
    * @Author Pawel Sprysak
    * @description Add postfix to VendorEventID_gne__c and GNE_EventID_gne__c fields after changing status to DROPPED
    * @description Method used in: VDST_UpdateAVSummary_gne trigger
    * @param List<VDST_Event_gne__c> newData, List<VDST_Event_gne__c> oldData
    */
    public static void updateDroppedEventUniqueIds(List<VDST_Event_gne__c> newData, List<VDST_Event_gne__c> oldData) {
        // Change Vendor and Genentech Event Id's
        if ( newData.get(0).CurrentStatus_gne__c != oldData.get(0).CurrentStatus_gne__c && 'DROPPED'.equals(newData.get(0).CurrentStatus_gne__c)) {
            String ticket = '_DR' + String.valueOf(DateTime.now().getTime()).right(6);
            for (VDST_Event_gne__c event : newData) {
                if (event.VendorEventID_gne__c != null) {
                    event.VendorEventID_gne__c += ticket;
                }
                if (event.GNE_EventID_gne__c != null) {
                    event.GNE_EventID_gne__c += ticket;
                }
            }
        }
    }

    /** @date 3/31/2013
    * @Author Pawel Sprysak
    * @description Update related values after changing Event data
    * @description Method used in: VDST_UpdateAVSummary_gne trigger
    * @param List<VDST_Event_gne__c> newData, List<VDST_Event_gne__c> oldData, Map<Id,VDST_Event_gne__c> oldMap, Map<Id,VDST_Event_gne__c> newMap
    */
    public static void updateValuesAfterChangingEventData(List<VDST_Event_gne__c> newData, List<VDST_Event_gne__c> oldData, Map<Id,VDST_Event_gne__c> newMap, Map<Id,VDST_Event_gne__c> oldMap) {
        String evType = newData.get(0).EventType_gne__c;
        // Meal Amount for Editable Participant Counts
        if (!String.isBlank(evType) && VDST_Utils.isStdEventType(evType)) {
            Set<String> evntIds = new Set<String>();
            Boolean newValue = false;
            for (VDST_Event_gne__c ev : newData) {
                if (oldMap.get(ev.Id).TotPlanAttCntUser_gne__c != newMap.get(ev.Id).TotPlanAttCntUser_gne__c) {
                    newValue = true;
                }
                evntIds.add(ev.Id);
            }
            if (newValue) {
                List<VDST_EventPrtcpntAttendance_gne__c> epaList = [SELECT Id, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__c FROM VDST_EventPrtcpntAttendance_gne__c WHERE VDST_EventDate_gne__r.VDST_Event_gne__c IN :evntIds];
                List<VDST_EventDateTransaction_gne__c> edtList = [SELECT Id, EventDateTransactionAmount_gne__c, VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__c FROM VDST_EventDateTransaction_gne__c WHERE VDST_EventDate_gne__r.VDST_Event_gne__c IN :evntIds];
                if (edtList.size() > 0 && epaList.size() > 0) {
                    Integer attCount;
                    for (VDST_EventDateTransaction_gne__c edt : edtList) {
                        attCount = Integer.valueOf(edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c);
                        for (VDST_EventPrtcpntAttendance_gne__c epa : epaList) {
                            if (epa.VDST_EventDate_gne__c == edt.VDST_EventDate_gne__c) {
                                if ('ATND'.equals(epa.AttendanceStatus_gne__c) && 'CONSUMED'.equals(epa.ParticipantMealConsumptionStatus_gne__c)) {
                                    System.debug('CALC_UAVS, BEG: ' + edt.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c + '; ' + edt.EventDateTransactionAmount_gne__c + ' / ' + attCount + ' for ' + epa.VDST_EventDate_gne__c);
                                    if (edt.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c) {
                                        if ( edt.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c > edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c ) {
                                            attCount = Integer.valueOf( edt.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c );
                                        } else {
                                            attCount = Integer.valueOf( edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c );
                                        }
                                        System.debug('CALC_UAVS, CHG: ' + edt.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c + '; ' + edt.EventDateTransactionAmount_gne__c + ' / ' + edt.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c + ' vs ' + edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c + ' for ' + edt.VDST_EventDate_gne__c);
                                    }
                                    if (attCount > 0) {
                                        epa.MealAmount_gne__c = edt.EventDateTransactionAmount_gne__c / attCount;
                                    } else {
                                        epa.MealAmount_gne__c = edt.EventDateTransactionAmount_gne__c;
                                    }
                                } else {
                                    epa.MealAmount_gne__c = 0;
                                }
                            }
                        }
                    }
                }
                update epaList;
            }
        }

        // Update Single Spends Item Amounts on transactions
        if ( isSSEventType(evType)) {
            // updateTransactionAmountAfterChangingItemAmount
            Double eventAmount = Double.valueOf(newData.get(0).ItemAmount_gne__c);
            Double oldEventAmount = Double.valueOf(oldData.get(0).ItemAmount_gne__c);
            if (eventAmount != oldEventAmount) {
                List<VDST_PrtcpntTransaction_gne__c> evPrtcpntList = [SELECT Id, ItemQuantity_gne__c, TransactionAmount_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__c IN :newMap.keySet()];
                for (VDST_PrtcpntTransaction_gne__c evPrtcpnt : evPrtcpntList) {
                    if ('MEDWRTG'.equals(evType)) {
                        evPrtcpnt.TransactionAmount_gne__c = eventAmount;
                    } else {
                        Integer quantity = 0;
                        if (evPrtcpnt.ItemQuantity_gne__c != null) {
                            quantity = Integer.valueOf(evPrtcpnt.ItemQuantity_gne__c);
                        }
                        evPrtcpnt.TransactionAmount_gne__c = eventAmount * quantity;
                    }
                }
                update evPrtcpntList;
            }
        }

        // Update Research Item Amounts on transactions
        if ( isResearchEventType(evType)) {
            Double eventAmount = Double.valueOf(newData.get(0).ItemAmount_gne__c);
            String eventPaymentType = String.valueOf(newData.get(0).ResearchPaymentTypeCode_gne__c);
            Double oldEventAmount = Double.valueOf(oldData.get(0).ItemAmount_gne__c);
            String oldEventPaymentType = String.valueOf(oldData.get(0).ResearchPaymentTypeCode_gne__c);
            if (eventPaymentType == null) {
                eventPaymentType = '';
            }
            if (oldEventPaymentType == null) {
                oldEventPaymentType = '';
            }
            if (eventAmount != oldEventAmount || !eventPaymentType.equals(oldEventPaymentType)) {
                List<VDST_PrtcpntTransaction_gne__c> evPrtcpntList = [SELECT Id, TransactionTypeCode_gne__c, TransactionAmount_gne__c, VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__r.ResearchPaymentTypeCode_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__c IN :newMap.keySet()];
                for (VDST_PrtcpntTransaction_gne__c evPrtcpnt : evPrtcpntList) {
                    evPrtcpnt.TransactionAmount_gne__c = eventAmount;
                    if ('PRECLINICAL'.equals(evPrtcpnt.VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__r.ResearchPaymentTypeCode_gne__c)) {
                        evPrtcpnt.TransactionTypeCode_gne__c = 'PRECLINCL';
                    } else {
                        evPrtcpnt.TransactionTypeCode_gne__c = 'RSCH';
                    }
                }
                update evPrtcpntList;
            }
        }
    }

    /** @date 3/31/2013
    * @Author Pawel Sprysak
    * @description Update AV transaction value after changing AV on Event
    * @description Method used in: VDST_UpdateAVSummary_gne trigger
    * @param List<VDST_Event_gne__c> evts
    */
    public static void updateAvTransaction(final VDST_Event_gne__c[] evts) {
        final Map<String, VDST_EventField_gne__c> evtFlds = new Map<String, VDST_EventField_gne__c>();
        final Map<Id, VDST_EventTransactionSummary_gne__c> avMap = new Map<Id, VDST_EventTransactionSummary_gne__c>();
        // collect all event types
        for (VDST_Event_gne__c evt : evts) {
            evtFlds.put(evt.EventType_gne__c, null);
        }
        // Create Set of Event Types where AV is needed
        for (VDST_EventField_gne__c evtFld : [
            SELECT EventType_gne__c FROM VDST_EventField_gne__c
            WHERE EventStatus_gne__c = 'Transactions'
            AND EventType_gne__c IN :evtFlds.keySet()
            AND FieldName_gne__c = 'VENUEAV'
            LIMIT :evtFlds.size()
        ]) {
            evtFlds.put(evtFld.EventType_gne__c, evtFld);
        }
        // Get actual AV values
        for (VDST_EventTransactionSummary_gne__c ets : [
            SELECT VDST_Event_gne__c, EventTransactionAmount_gne__c FROM VDST_EventTransactionSummary_gne__c
            WHERE VDST_Event_gne__c IN :evts AND EventTransactionTypeCode_gne__c = 'VENUEAV'
            LIMIT :evts.size()
        ]) {
            avMap.put(ets.VDST_Event_gne__c, ets);
        }
        // Fill with new Summary values
        for (VDST_Event_gne__c evt : evts) {
            if (evtFlds.get(evt.EventType_gne__c) != null) {
                final Decimal totalAV = evt.TotalAudioVisual_gne__c == null ? 0 : evt.TotalAudioVisual_gne__c;
                if (avMap.containsKey(evt.Id)) {
                    avMap.get(evt.Id).EventTransactionAmount_gne__c = totalAV;
                } else {
                    avMap.put(evt.Id, new VDST_EventTransactionSummary_gne__c(
                        EventTransactionTypeCode_gne__c = 'VENUEAV',
                        EventTransactionAmount_gne__c = totalAV,
                        EventTransactionLevel_gne__c = 'EVNT',
                        VDST_Event_gne__c = evt.Id
                    ));
                }
            }
        }
        // DB Method
        upsert avMap.values();
    }

    /** @date 3/31/2013
    * @Author Pawel Sprysak
    * @description Prepare data for Event Date and Event Date Transaction objects
    * @description Method used in: VDST_UpdateAVSummary_gne trigger
    * @param List<VDST_EventDate_gne__c> eventDateToDelList, List<VDST_EventDate_gne__c> eventDateToInsList, Map<String, Double> eventIdToAmount, List<VDST_Event_gne__c> newData, Map<Id,VDST_Event_gne__c> newMap, Map<Id,VDST_Event_gne__c> oldMap, Boolean isInsert
    */
    public static Boolean prepareEventDateData(List<VDST_EventDate_gne__c> eventDateToDelList, List<VDST_EventDate_gne__c> eventDateToInsList, Map<String, Double> eventIdToAmount, List<VDST_Event_gne__c> newData, Map<Id,VDST_Event_gne__c> newMap, Map<Id,VDST_Event_gne__c> oldMap, Boolean isInsert) {
        // Create Event Date map for each Event
        Map<Id, List<VDST_EventDate_gne__c>> eventToDateMap = new Map<Id, List<VDST_EventDate_gne__c>>();
        for (VDST_EventDate_gne__c eventDate : [SELECT Id, Name, VDST_Event_gne__c, EventDate_gne__c FROM VDST_EventDate_gne__c WHERE VDST_Event_gne__r.Id IN :newMap.keySet() ORDER BY EventDate_gne__c ASC]) {
            if (eventToDateMap.containsKey(eventDate.VDST_Event_gne__c)) {
                eventToDateMap.get(eventDate.VDST_Event_gne__c).add(eventDate);
            } else {
                eventToDateMap.put(eventDate.VDST_Event_gne__c, new List<VDST_EventDate_gne__c>{eventDate});
            }
        }
        // Go through the Event's
        Boolean errorMessage = false;
        for (VDST_Event_gne__c event : newData) {
            if (
                (
                    isInsert ||
                    event.EventStartDate_gne__c != oldMap.get(event.Id).EventStartDate_gne__c || event.EventEndDate_gne__c != oldMap.get(event.Id).EventEndDate_gne__c
                )
            ) {
                if ('CFF'.equals(event.EventType_gne__c) && event.ItemAmount_gne__c != null && event.ItemAmount_gne__c >= 0) {
                   eventIdToAmount.put(event.Id, event.ItemAmount_gne__c);
                }
                if (event.EventEndDate_gne__c != null && event.EventStartDate_gne__c != null) {
                    if (event.EventEndDate_gne__c < event.EventStartDate_gne__c) {
                        event.addError('Event Start Date must be earlier than Event End Date');
                        errorMessage = true;
                    } else {
                        Integer numDays = event.EventStartDate_gne__c.daysBetween(event.EventEndDate_gne__c);
                        if (!event.iAdviseEvent_gne__c && numDays > 4) {
                            event.addError('Event End Date could be max 4 days after Event Start Date');
                            errorMessage = true;
                        } else {
                            // Create Event Date Lists to Delete/Insert
                            Map<Date, Boolean> mapExDates = new Map<Date, Boolean>();
                            if (eventToDateMap.containsKey(event.Id)) {
                                for (VDST_EventDate_gne__c ed : eventToDateMap.get(event.Id)) {
                                    if (ed.EventDate_gne__c >= event.EventStartDate_gne__c && ed.EventDate_gne__c <= event.EventEndDate_gne__c) {
                                        // Add to map with already existing Event Dates
                                        mapExDates.put(ed.EventDate_gne__c, true);
                                    } else {
                                        // Add to delete list
                                        eventDateToDelList.add(ed);
                                    }
                                }
                            }
                            // Check is there any need to add Event Date
                            for (Integer i=0; i<=numDays; i++){
                                if (mapExDates.get(event.EventStartDate_gne__c.addDays(i)) != true) {
                                    VDST_EventDate_gne__c evDate = new VDST_EventDate_gne__c();
                                    evDate.VDST_Event_gne__c = event.Id;
                                    evDate.EventDate_gne__c = event.EventStartDate_gne__c.addDays(i);
                                    eventDateToInsList.add(evDate);
                                }
                            }
                        }
                    }
                } else {
                    event.addError('Event Start Date or Event End Date are required.');
                    errorMessage = true;
                }
            }
        }
        return errorMessage;
    }

    /** @date 3/31/2013
    * @Author Pawel Sprysak
    * @description Create Event Date Transaction data
    * @description Method used in: VDST_UpdateAVSummary_gne trigger
    * @param List<VDST_EventDate_gne__c> eventDateToInsList, Map<String, Double> eventIdToAmount
    */
    public static void createEventDateTransaction(List<VDST_EventDate_gne__c> eventDateToInsList, Map<String, Double> eventIdToAmount) {
        List<VDST_EventDateTransaction_gne__c> eventDateTransInsList = new List<VDST_EventDateTransaction_gne__c>();
        for (VDST_EventDate_gne__c evDate : eventDateToInsList) {
            Double edta = 0;
            if (eventIdToAmount.containsKey(evDate.VDST_Event_gne__c)) {
                edta = eventIdToAmount.get(evDate.VDST_Event_gne__c);
            }
            VDST_EventDateTransaction_gne__c evDtTrns = new VDST_EventDateTransaction_gne__c();
            evDtTrns.VDST_EventDate_gne__c = evDate.Id;
            evDtTrns.EventDateTransactionLevel_gne__c = 'EVNT';
            evDtTrns.EventDateTransactionTypeCode_gne__c = 'DLYEVTMEAL';
            evDtTrns.EventDateTransactionAmount_gne__c = edta;
            eventDateTransInsList.add(evDtTrns);
        }
        insert eventDateTransInsList;
    }

    /** @date 11/4/2013
    * @Author Pawel Sprysak
    * @description Get Event Participant Account By Event Id and Participant Role Name
    * @param String eventId, String participantRole
    * @return VDST_EventPrtcpntAccnt_gne__c
    */
    public static VDST_EventPrtcpntAccnt_gne__c getPrtcpntAccntByEventIdAndRole(String eventId, String participantRole) {
        try {
            return [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c WHERE EventParticipantRole_gne__r.EventParticipantRoleName__c = :participantRole AND VDST_Event_gne__c = :eventId LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 10/29/2013
    * @Author Pawel Sprysak
    * @description Get Event Participant Accounts by Event Id and Party Type
    * @param Set<String> eventIds, Boolean isIndv
    * @return List<VDST_EventPrtcpntAccnt_gne__c>
    */
    public static List<VDST_EventPrtcpntAccnt_gne__c> getPrtcpntAccntByIdAndPartyType(Set<String> eventIds, Boolean isIndv) {
        try {
            if (isIndv) {
                return [SELECT Id, VDST_Event_gne__c, VDST_Event_gne__r.iAdviseEvent_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c IN :eventIds AND PartyType_gne__c = 'INDV'];
            } else {
                return [SELECT Id, VDST_Event_gne__c, VDST_Event_gne__r.iAdviseEvent_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c IN :eventIds];
            }
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntAccnt_gne__c>();
        }
    }

    /** @date 5/22/2013
    * @Author Pawel Sprysak
    * @description Get Vendor Participant information List By Event Id
    * @param Id eventId (Event Id)
    * @return List<VDST_EventPrtcpntAccnt_gne__c>
    */
    public static List<VDST_EventPrtcpntAccnt_gne__c> getVendorPrtcpntInfoList(Id eventId) {
        try {
            return [SELECT Id, VDST_Address_gne__c, FirstName_gne__c, LastName_gne__c, LegalName_gne__c, VendorParticipantCode_gne__c, VendorParticipantID_gne__c, VDST_Event_gne__r.LogisticVendorCode_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :eventId ORDER BY VendorParticipantID_gne__c ASC NULLS LAST];
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntAccnt_gne__c>();
        }
    }

    /** @date 3/7/2013
    * @Author Pawel Sprysak
    * @description Get Event Participant List By Event Id
    * @param Id eventId (Event Id)
    * @return List<VDST_EventPrtcpntAccnt_gne__c>
    */
    public static List<VDST_EventPrtcpntAccnt_gne__c> getParticipantList(Id eventId) {
        try {
            return getParticipantList(eventId, 'INDV');
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntAccnt_gne__c>();
        }
    }

    /** @date 10/28/2013
    * @Author Pawel Sprysak
    * @description Get Event Participant List By Event Id and Participant Type
    * @param Id eventId (Event Id)
    * @return List<VDST_EventPrtcpntAccnt_gne__c>
    */
    public static List<VDST_EventPrtcpntAccnt_gne__c> getParticipantList(Id eventId, String partyType) {
        try {
            if ('INDV'.equals(partyType)) {
                return [SELECT Id, FirstName_gne__c, LastName_gne__c, EventParticipantRole_gne__r.EventParticipantRoleName__c, UnixID_gne__c, Credential_gne__c, ParticipantAffiliation_gne__c, EventParticipantCurrentStatus_gne__c, VDST_Address_gne__r.StatesNameHolder_gne__c, VDST_Address_gne__r.City_gne__c, VDST_Address_gne__r.StateProvince_gne__c, VDST_Address_gne__r.Country_gne__c, VendorParticipantID_gne__c, LegalName_gne__c, VDST_Event_gne__r.LogisticVendorCode_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :eventId AND PartyType_gne__c = 'INDV' ORDER BY LastName_gne__c ASC, FirstName_gne__c ASC];
            } else {
                return [SELECT Id, FirstName_gne__c, LastName_gne__c, EventParticipantRole_gne__r.EventParticipantRoleName__c, UnixID_gne__c, Credential_gne__c, ParticipantAffiliation_gne__c, EventParticipantCurrentStatus_gne__c, VDST_Address_gne__r.StatesNameHolder_gne__c, VDST_Address_gne__r.City_gne__c, VDST_Address_gne__r.StateProvince_gne__c, VDST_Address_gne__r.Country_gne__c, VendorParticipantID_gne__c, LegalName_gne__c, VDST_Event_gne__r.LogisticVendorCode_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :eventId ORDER BY LastName_gne__c ASC, FirstName_gne__c ASC, LegalName_gne__c ASC];
            }
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntAccnt_gne__c>();
        }
    }

    /** @date 10/28/2013
    * @Author Pawel Sprysak
    * @description Get Event Participant List By Participant Ids
    * @param List<Id> participantIds
    * @return List<VDST_EventPrtcpntAccnt_gne__c>
    */
    public static List<VDST_EventPrtcpntAccnt_gne__c> getParticipantList(List<Id> participantIds) {
        try {
            return [SELECT Id, FirstName_gne__c, LastName_gne__c, LegalName_gne__c, EventParticipantRole_gne__r.EventParticipantRoleName__c, PartyType_gne__c , UnixID_gne__c, Credential_gne__c, ParticipantAffiliation_gne__c, EventParticipantCurrentStatus_gne__c, VDST_Address_gne__r.StatesNameHolder_gne__c, VDST_Address_gne__r.City_gne__c, VDST_Address_gne__r.StateProvince_gne__c, VDST_Address_gne__r.Country_gne__c, VendorParticipantID_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE ID IN :participantIds ORDER BY LastName_gne__c ASC, FirstName_gne__c ASC, LegalName_gne__c ASC];
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntAccnt_gne__c>();
        }
    }

    /** @date 10/28/2013
    * @Author Pawel Sprysak
    * @description Get Event Participant List By Event Id
    * @param Id eventId
    * @return List<VDST_EventPrtcpntAccnt_gne__c>
    */
    public static List<VDST_EventPrtcpntAccnt_gne__c> getParticipantsFullDataList(Id eventId) {
        try {
            return getParticipantsFullDataList(eventId, 'INDV');
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntAccnt_gne__c>();
        }
    }

    /** @date 10/28/2013
    * @Author Pawel Sprysak
    * @description Get Event Participant List By Event Id and Party Type
    * @param Id eventId
    * @param String partyType
    * @return List<VDST_EventPrtcpntAccnt_gne__c>
    */
    public static List<VDST_EventPrtcpntAccnt_gne__c> getParticipantsFullDataList(Id eventId, String partyType) {
        try {
            if ('INDV'.equals(partyType)) {
                return [SELECT BusinessPhone_gne__c, Charitable_Organization_gne__c, Credential_gne__c, DEA_gne__c, Email_gne__c, EventParticipantRole_gne__c, ExceptionReason_gne__c, FirstName_gne__c, GNE_SFDC_ID_gne__c, HasException_gne__c, LastName_gne__c, LegalName_gne__c, LicenseNumber_gne__c, LicenseState_gne__c, MiddleName_gne__c, MDMID_gne__c, NPI_gne__c, ParticipantAffiliation_gne__c, ParticipantContractStatus_gne__c, ParticipantProfession_gne__c, ParticipantRole_gne__c, PartyType_gne__c, Suffix_gne__c, TIN_gne__c, UnixID_gne__c, VendorParticipantID_gne__c, VDST_Address_gne__c, VDST_Address_gne__r.StatesNameHolder_gne__c, VDST_Address_gne__r.City_gne__c, VDST_Address_gne__r.StateProvince_gne__c, VDST_Address_gne__r.PostalCode_gne__c, VDST_Address_gne__r.Country_gne__c, VDST_Address_gne__r.StreetAddress_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :eventId AND PartyType_gne__c = 'INDV'];
            } else {
                return [SELECT BusinessPhone_gne__c, Charitable_Organization_gne__c, Credential_gne__c, DEA_gne__c, Email_gne__c, EventParticipantRole_gne__c, ExceptionReason_gne__c, FirstName_gne__c, GNE_SFDC_ID_gne__c, HasException_gne__c, LastName_gne__c, LegalName_gne__c, LicenseNumber_gne__c, LicenseState_gne__c, MiddleName_gne__c, MDMID_gne__c, NPI_gne__c, ParticipantAffiliation_gne__c, ParticipantContractStatus_gne__c, ParticipantProfession_gne__c, ParticipantRole_gne__c, PartyType_gne__c, Suffix_gne__c, TIN_gne__c, UnixID_gne__c, VendorParticipantID_gne__c, VDST_Address_gne__c, VDST_Address_gne__r.StatesNameHolder_gne__c, VDST_Address_gne__r.City_gne__c, VDST_Address_gne__r.StateProvince_gne__c, VDST_Address_gne__r.PostalCode_gne__c, VDST_Address_gne__r.Country_gne__c, VDST_Address_gne__r.StreetAddress_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :eventId];
            }
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntAccnt_gne__c>();
        }
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description Get Participant By Id
    * @param Id prtcpntId (Participant Id), String partyType (Party Type = INDV/ORG)
    * @return VDST_EventPrtcpntAccnt_gne__c
    */
    public static VDST_EventPrtcpntAccnt_gne__c getPrtcpntById(Id prtcpntId) {
        try {
            return [SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, LastModifiedByName_gne__c, BusinessPhone_gne__c, Charitable_Organization_gne__c, Credential_gne__c, DEA_gne__c, Email_gne__c, EventParticipantCurrentStatus_gne__c, EventParticipantRole_gne__c, EventParticipantRole_gne__r.EventParticipantRoleCode_gne__c, EventParticipantRole_gne__r.EventParticipantRoleName__c, ExceptionReason_gne__c, FirstName_gne__c, isBatch_gne__c, GNE_SFDC_ID_gne__c, HasException_gne__c, LastName_gne__c, LegalName_gne__c, LicenseNumber_gne__c, LicenseState_gne__c, MiddleName_gne__c, MDMID_gne__c, NPI_gne__c, ParticipantAffiliation_gne__c, ParticipantContractStatus_gne__c, ParticipantProfession_gne__c, ParticipantRole_gne__c, PartyType_gne__c, Region_Code_gne__c, Suffix_gne__c, TIN_gne__c, UnixID_gne__c, VDST_Address_gne__c, VDST_Event_gne__c, VDST_Event_gne__r.LogisticVendor_gne__r.VendorCode_gne__c, VendorParticipantID_gne__c, VendorParticipantCode_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE Id = :prtcpntId];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 3/29/2013
    * @Author Pawel Sprysak
    * @description Method for deleting Participant with Org
    * @param Id prtcpntId (Participant Id)
    */
    public static void deleteParticipant(Id prtcpntId) {
        try {
            Set<Id> idList = new Set<Id>{prtcpntId};
            List<VDST_PrtcpntTransaction_gne__c> orgTransaction = [SELECT VDST_EventPrtcpntAccnt_gne__c, VDST_PaidToParty_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE FeePayToPartyType_gne__c = 'ORG' AND VDST_PaidToParty_gne__c = :prtcpntId];
            if (orgTransaction.size() > 0 && orgTransaction.get(0).VDST_EventPrtcpntAccnt_gne__c != null) {
                idList.add(orgTransaction.get(0).VDST_EventPrtcpntAccnt_gne__c);
            }
            List<VDST_EventPrtcpntAccnt_gne__c> epaList = [SELECT Id, VDST_Address_gne__c, VendorParticipantID_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE Id IN :idList];
            Set<Id> addressIds = new Set<Id>();
            Set<String> vendorIds = new Set<String>();
            for (VDST_EventPrtcpntAccnt_gne__c epa : epaList) {
                addressIds.add(epa.VDST_Address_gne__c);
                if (!String.isBlank(epa.VendorParticipantID_gne__c)) {
                    vendorIds.add(epa.VendorParticipantID_gne__c);
                }
            }
            List<VDST_Address_gne__c> adrList = [SELECT Id FROM VDST_Address_gne__c WHERE Id IN :addressIds];
            delete epaList;
            delete adrList;
            List<VDST_DeletedParticipantsId_gne__c> dpiToAdd = new List<VDST_DeletedParticipantsId_gne__c>();
            for (String str : vendorIds) {
                dpiToAdd.add(new VDST_DeletedParticipantsId_gne__c(VendorParticipantId_gne__c = str));
            }
            if (dpiToAdd.size() > 0) {
                insert dpiToAdd;
            }
        } catch (QueryException e) {
            //Error message
        }
    }

    /** @date 3/28/2013
    * @Author Pawel Sprysak
    * @description Get Attendance By Participant Id
    * @param Id prtcpntId (Participant Account Id)
    * @return List<VDST_EventPrtcpntAttendance_gne__c>
    */
    public static List<VDST_EventPrtcpntAttendance_gne__c> getAttByPrtcpntId(Id prtcpntId) {
        try {
            return [SELECT Id, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c, VDST_EventDate_gne__r.EventDate_gne__c, MealAmount_gne__c FROM VDST_EventPrtcpntAttendance_gne__c WHERE Event_PrtcpntAccnt_gne__c = :prtcpntId ORDER BY VDST_EventDate_gne__r.EventDate_gne__c ASC];
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntAttendance_gne__c>();
        }
    }

    /** @date 3/29/2013
    * @Author Pawel Sprysak
    * @description Get Event Participant Attendance List By Event Id
    * @param String eventId (Event Id)
    * @return List<VDST_EventPrtcpntAttendance_gne__c>
    */
    public static List<VDST_EventPrtcpntAttendance_gne__c> getEvPrtpcntAttendanceByEventId(String eventId) {
        try {
            return [SELECT Id, VDST_EventDate_gne__c, VDST_EventDate_gne__r.EventDate_gne__c, Event_PrtcpntAccnt_gne__c, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c FROM VDST_EventPrtcpntAttendance_gne__c WHERE Event_PrtcpntAccnt_gne__r.VDST_Event_gne__c = :eventId AND Event_PrtcpntAccnt_gne__r.PartyType_gne__c = 'INDV' ORDER BY VDST_EventDate_gne__r.EventDate_gne__c];
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntAttendance_gne__c>();
        }
    }

    /** @date 3/28/2013
    * @Author Pawel Sprysak
    * @description Get Participant Transaction List
    * @param Id accId (Participant Account Id)
    * @return List<VDST_PrtcpntTransaction_gne__c>
    */
    public static List<VDST_PrtcpntTransaction_gne__c> getPrtcpntTransByAccount(Id accId, Boolean isOnly) {
        try {
            if (isOnly) {
                return [SELECT Id, ItemQuantity_gne__c, ItemAmount_gne__c, FeePayToPartyType_gne__c, TransactionAmount_gne__c, TransactionTypeCode_gne__c, VDST_EventPrtcpntAccnt_gne__c, VDST_PaidToParty_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__c = :accId];
            } else {
                return [SELECT Id, ItemQuantity_gne__c, ItemAmount_gne__c, FeePayToPartyType_gne__c, TransactionAmount_gne__c, TransactionTypeCode_gne__c, VDST_EventPrtcpntAccnt_gne__c, VDST_PaidToParty_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__c = :accId OR VDST_PaidToParty_gne__c = :accId];
            }
        } catch (QueryException e) {
            return new List<VDST_PrtcpntTransaction_gne__c>();
        }
    }

    /** @date 3/28/2013
    * @Author Pawel Sprysak
    * @description Get Participant Transaction List by Account Id set
    * @param Set<Id> accIds
    * @return List<VDST_PrtcpntTransaction_gne__c>
    */
    public static List<VDST_PrtcpntTransaction_gne__c> getPrtcpntTransByAccounts(Set<Id> accIds) {
        try {
            return [SELECT Id, FeePayToPartyType_gne__c, TransactionAmount_gne__c, TransactionTypeCode_gne__c, VDST_EventPrtcpntAccnt_gne__c, VDST_PaidToParty_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__c in :accIds];
        } catch (QueryException e) {
            return new List<VDST_PrtcpntTransaction_gne__c>();
        }
    }

    /** @date 23/9/2014
    * @Author Konrad Malinowski
    * @description Get Home Payment Id Participant Transaction by Event Id
    * @param Id eventId
    * @return VDST_PrtcpntTransaction_gne__c
    */
    public static VDST_PrtcpntTransaction_gne__c getHomePaymentIdParticipantTransactionByEventId(Id eventId) {
        try {
            List<VDST_PrtcpntTransaction_gne__c> trans = [
                SELECT  Id, VDST_EventPrtcpntAccnt_gne__c, TransactionTypeCode_gne__c
                FROM    VDST_PrtcpntTransaction_gne__c
                WHERE   VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__c = :eventId
                AND     Home_Payment_ID_flag_gne__c = true
            ];
            return ( trans.isEmpty() ? null : trans[0]);
        } catch (QueryException e) {
            return null;
        }
    }

     /** @date 8/4/2014
    * @Author Pawel Sprysak
    * @description Method for checking whether Event has Participants with Travel and Lodging Expenses
    * @param String eventId (Event Id)
    * @return Boolean
    */
    public static Boolean hasTravelAndLodgingExpenses(String eventId) {
        try {
            List<VDST_PrtcpntTransaction_gne__c> etsList =
                [SELECT Id
                    FROM VDST_PrtcpntTransaction_gne__c
                    WHERE VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__c = :eventId
                        AND (
                            (TransactionTypeCode_gne__c = 'HCPTRVL' AND TransactionAmount_gne__c > 0)
                            OR (TransactionTypeCode_gne__c = 'HCPLODGNG' AND TransactionAmount_gne__c > 0)
                            OR (TransactionTypeCode_gne__c = 'OOPTRVL' AND TransactionAmount_gne__c > 0)
                            OR (TransactionTypeCode_gne__c = 'OOPLODGNG' AND TransactionAmount_gne__c > 0)
                        )
                    LIMIT 1
                 ];
            if (etsList.size() > 0) {
                return true;
            } else {
                return false;
            }
        } catch (QueryException e) {
            return true;
        }
    }

    /** @date 11/4/2013
    * @Author Pawel Sprysak
    * @description Update Paid To Party reference for Participant Transaction objects
    * @param Id eventId, Id accountId
    */
    public static void updatePaidToPartyRef(Id eventId, Id accountId) {
        try {
            List<VDST_PrtcpntTransaction_gne__c> ptList = [SELECT Id, VDST_PaidToParty_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__c = :eventId];
            for (VDST_PrtcpntTransaction_gne__c pt : ptList) {
                pt.VDST_PaidToParty_gne__c = (Id)accountId;
            }
            update ptList;
        } catch (QueryException e) {
            // Do nothing
        }
    }

    /** @date 3/12/2013
    * @Author Pawel Sprysak
    * @description Get Event List (only with status different than "DROPPED")
    * @param Id providerId (Provider Id)
    * @return List<VDST_Event_gne__c>
    */
    public static List<VDST_Event_gne__c> getEventList(Id providerId) {
        try {
            if (providerId == null) {
                return [SELECT Id, CreatedDate, EventMeetingName_gne__c, CurrentStatus_gne__c, LogisticVendorName_gne__c, EventStartDate_gne__c, (SELECT EventSiteName_gne__c FROM VDST_Event_Sites__r LIMIT 1) FROM VDST_Event_gne__c WHERE CurrentStatus_gne__c != 'DROPPED' ORDER BY CreatedDate DESC LIMIT 10000];
            } else {
                return [SELECT Id, CreatedDate, EventMeetingName_gne__c, CurrentStatus_gne__c, LogisticVendorName_gne__c, EventStartDate_gne__c, (SELECT EventSiteName_gne__c FROM VDST_Event_Sites__r LIMIT 1) FROM VDST_Event_gne__c WHERE CurrentStatus_gne__c != 'DROPPED' AND LogisticVendor_gne__c = :providerId ORDER BY CreatedDate DESC LIMIT 10000];
            }
        } catch (QueryException e) {
            return new List<VDST_Event_gne__c>();
        }
    }

    /** @date 10/4/2013
    * @Author Pawel Sprysak
    * @description Method for converting JSON to Id's and removing Events by those Id's
    * @description Used on VDST_FileUploadController
    * @param String jsonString (JSON to convert with Event Id's)
    * @return Boolean
    */
    public static Boolean getEventsFromJSONToRemove(String jsonString){
        // Convert JSON to Event List Id's
        List<String> eventIdList = new List<String>();
        Map<String, Object> eventIdMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        List<Object> idList = (List<Object>)eventIdMap.get('ids');
        for (Object str : idList) {
            eventIdList.add((String)str);
        }
        // Remove Event by Id's List
        try {
            List<VDST_Event_gne__c> eventList = [SELECT Id FROM VDST_Event_gne__c WHERE Id IN: eventIdList];
            for (VDST_Event_gne__c ev : eventList) {
                ev.CurrentStatus_gne__c = 'DROPPED';
                ev.CurrentStatusDate_gne__c = Date.today();
            }
            update eventList;
        } catch (QueryException e) {
            return false;
        }
        return true;
    }

    /** @date 3/4/2013
    * @Author Pawel Sprysak
    * @description Vendor Code Mapping Wrapper class
    */
    public class VendorCodeMapping {
        public String vendorCode { get; set; }
        public String vendorName { get; set; }

        public VendorCodeMapping(String vc, String vn) {
            vendorCode = vc;
            vendorName = vn;
        }
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description Get Participant field requirements
    * @param String roleId (Event Participant Role Id)
    * @return List<VDST_EventPrtcpntField_gne__c>
    */
    public static List<VDST_EventPrtcpntField_gne__c> getFieldReqList(String roleId) {
        try {
            return [SELECT DefaultValue_gne__c, FieldLabel_gne__c, FieldName_gne__c, IsRequired_gne__c, IsVisible_gne__c, VDST_EventPrtcpntRole__c FROM VDST_EventPrtcpntField_gne__c WHERE VDST_EventPrtcpntRole__c = :roleId];
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntField_gne__c>();
        }
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description Get Participant field requirements by Event Type
    * @param String eventType
    * @return List<VDST_EventPrtcpntField_gne__c>
    */
    public static List<VDST_EventPrtcpntField_gne__c> getPrtcpntFieldReqList(String eventType) {
        try {
            return [SELECT DefaultValue_gne__c, FieldLabel_gne__c, FieldName_gne__c, IsRequired_gne__c, IsVisible_gne__c, VDST_EventPrtcpntRole__c FROM VDST_EventPrtcpntField_gne__c WHERE VDST_EventPrtcpntRole__r.EventType_gne__c = :eventType];
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntField_gne__c>();
        }
    }

    /** @date 4/4/2013
    * @Author Pawel Sprysak
    * @description Setting map for visibility/required Participant fields
    */
    public static Map<String, Map<String, VDST_EventPrtcpntField_gne__c>> setPrtcpntRoleFieldsMap(String eventType) {
        Map<String, Map<String, VDST_EventPrtcpntField_gne__c>> prtcpntFieldMap = new Map<String, Map<String, VDST_EventPrtcpntField_gne__c>>();
        // Create Participant map structure
        for (VDST_EventPrtcpntField_gne__c pField : VDST_Utils.getPrtcpntFieldReqList(eventType)) {
            if (!prtcpntFieldMap.containsKey(pField.VDST_EventPrtcpntRole__c)) {
                prtcpntFieldMap.put(pField.VDST_EventPrtcpntRole__c, new Map<String, VDST_EventPrtcpntField_gne__c>());
            }
            prtcpntFieldMap.get(pField.VDST_EventPrtcpntRole__c).put(pField.FieldName_gne__c, pfield);
        }
        return prtcpntFieldMap;
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description Get Event field requirements by Event Type
    * @param String eventType
    * @return List<VDST_EventField_gne__c>
    */
    public static List<VDST_EventField_gne__c> getEventsFieldReqList(String eventType) {
        try {
            return [SELECT DefaultValue_gne__c, EventStatus_gne__c, EventType_gne__c, FieldLabel_gne__c, FieldName_gne__c, IsRequired_gne__c, IsVisible_gne__c FROM VDST_EventField_gne__c WHERE EventType_gne__c =:eventType ORDER BY FieldLabel_gne__c ASC];
        } catch (QueryException e) {
            return new List<VDST_EventField_gne__c>();
        }
    }

    /** @date 3/29/2016
    * @Author Pawel Sprysak
    * @description Validation Map
    * @param String eventType
    * @return Map<String, Map<String, VDST_EventField_gne__c>>
    */
    public static Map<String, Map<String, VDST_EventField_gne__c>> setStatusFieldsMap(String eventType) {
        Map<String, Map<String, VDST_EventField_gne__c>> statusFieldMap = new Map<String, Map<String, VDST_EventField_gne__c>>();
        // Create Event map structure
        for (VDST_EventField_gne__c ef : VDST_Utils.getEventsFieldReqList(eventType)) {
            if (!statusFieldMap.containsKey(ef.EventStatus_gne__c)) {
                statusFieldMap.put(ef.EventStatus_gne__c, new Map<String, VDST_EventField_gne__c>());
            }
            statusFieldMap.get(ef.EventStatus_gne__c).put(ef.FieldName_gne__c, ef);
        }
        // Add to map fields which are not in DB
        for (String status : VDST_EventDetailCommon.EVENT_VALIDATION_STATUSES) {
            if (!statusFieldMap.containsKey(status)) {
                statusFieldMap.put(status, new Map<String, VDST_EventField_gne__c>());
            }
            // Add Event fields
            for (String field : VDST_EventDetailCommon.EVENT_VALIDATION_FIELDS) {
                if (!statusFieldMap.get(status).containsKey(field)) {
                    String notConf = field + ' - Not Configured';
                    statusFieldMap.get(status).put(field, new VDST_EventField_gne__c(EventStatus_gne__c = status, EventType_gne__c = eventType, FieldLabel_gne__c = notConf, FieldName_gne__c = field, DefaultValue_gne__c = notConf, IsRequired_gne__c = false, IsVisible_gne__c = false));
                }
            }
        }
        return statusFieldMap;
    }

    /** @date 10/30/2013
    * @Author Pawel Sprysak
    * @description Get Transaction Code to Label Map
    * @param String eventType (Event Type)
    * @return Map<String, String>
    */
    public static Map<String, String> getTransacionCodeToLabelMap(String eventType) {
        try {
            Map<String, String> returnMap = new Map<String, String>();
            for (VDST_EventField_gne__c ef : [SELECT FieldLabel_gne__c, FieldName_gne__c FROM VDST_EventField_gne__c WHERE EventType_gne__c = :eventType AND EventStatus_gne__c = 'Transactions']) {
                returnMap.put(ef.FieldName_gne__c, ef.FieldLabel_gne__c);
            }
            return returnMap;
        } catch (QueryException e) {
            return new Map<String, String>();
        }
    }

    /** @date 4/7/2013
    * @Author Pawel Sprysak
    * @description Get Transaction Data from Event Field object
    * @param String eventType (Event Type)
    * @return List<VDST_EventField_gne__c>
    */
    public static List<VDST_EventField_gne__c> getTransCodesFromEvField(String eventType) {
        try {
            return [SELECT Id, DefaultValue_gne__c, IsVisible_gne__c, FieldLabel_gne__c, FieldName_gne__c FROM VDST_EventField_gne__c WHERE EventType_gne__c = :eventType AND EventStatus_gne__c = 'Transactions' AND IsVisible_gne__c = true ORDER BY FieldLabel_gne__c];
        } catch (QueryException e) {
            return new List<VDST_EventField_gne__c>();
        }
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description Get Participant Role List
    * @param String eventType (Event Type)
    * @return List<VDST_EventPrtcpntRole_gne__c>
    */
    public static List<VDST_EventPrtcpntRole_gne__c> getVendorCodeList(String eventType) {
        try {
            return [SELECT Id, EventParticipantRoleName__c, EventParticipantRoleCode_gne__c FROM VDST_EventPrtcpntRole_gne__c WHERE EventType_gne__c = :eventType];
        } catch (QueryException e) {
            return new List<VDST_EventPrtcpntRole_gne__c>();
        }
    }

    /** @date 11/4/2013
    * @Author Pawel Sprysak
    * @description Get Participant Role By Id
    * @param String roleId
    * @return VDST_EventPrtcpntRole_gne__c
    */
    public static VDST_EventPrtcpntRole_gne__c getPrtcpntRoleById(String roleId) {
        try {
            return [SELECT Id, EventParticipantRoleName__c, EventParticipantRoleCode_gne__c FROM VDST_EventPrtcpntRole_gne__c WHERE Id = :roleId];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 4/3/2013
    * @Author Pawel Sprysak
    * @description Get Event Provider values
    * @return List<VDST_EventProvider_gne__c>
    */
    public static List<VDST_EventProvider_gne__c> getVendorCodeMappings() {
        try {
            return [SELECT Id, VendorName_gne__c, VendorCode_gne__c FROM VDST_EventProvider_gne__c ORDER BY VendorName_gne__c ASC];
        } catch (QueryException e) {
            return new List<VDST_EventProvider_gne__c>();
        }
    }

    /** @date 4/6/2016
    * @Author Pawel Sprysak
    * @description Get Event Provider values
    * @param Vendor Name List
    * @return List<VDST_EventProvider_gne__c>
    */
    public static List<VDST_EventProvider_gne__c> getVendorGroupDataByName(List<String> nameList) {
        try {
            return [SELECT Id, VendorName_gne__c, VendorCode_gne__c FROM VDST_EventProvider_gne__c WHERE VendorName_gne__c IN :nameList];
        } catch (QueryException e) {
            return new List<VDST_EventProvider_gne__c>();
        }
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak
    * @description Get Event Provider values by Id or Parent Id
    * @param Boolean searchForParent (Flag for searching in Parent Id), String provId (Event Provider Id)
    * @return List<VDST_EventProvider_gne__c>
    */
    public static List<VDST_EventProvider_gne__c> getEvProviderById(Boolean searchForParent, String provId) {
        try {
            if (searchForParent) {
                return [SELECT Id, VendorCode_gne__c, VendorID_gne__c, VendorName_gne__c, VDST_EventProvider_gne__c FROM VDST_EventProvider_gne__c WHERE Id = :provId OR VDST_EventProvider_gne__c = :provId ORDER BY VendorCode_gne__c];
            } else {
                return [SELECT Id, VendorCode_gne__c, VendorID_gne__c, VendorName_gne__c, VDST_EventProvider_gne__c FROM VDST_EventProvider_gne__c WHERE Id = :provId];
            }
        } catch (QueryException e) {
            return new List<VDST_EventProvider_gne__c>();
        }
    }

    /** @date 4/7/2013
    * @Author Pawel Sprysak
    * @description Get Event Transaction Summary objects By Event Id
    * @param String eventId (Event Id)
    * @return List<VDST_EventTransactionSummary_gne__c>
    */
    public static List<VDST_EventTransactionSummary_gne__c> getEvTransSummaryByEventId(String eventId) {
        try {
            return [
                SELECT Id, EventTransactionAmount_gne__c, EventTransactionTypeCode_gne__c
                FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c = :eventId
            ];
        } catch (QueryException e) {
            return new List<VDST_EventTransactionSummary_gne__c>();
        }
    }

    /** @date 10/30/2013
    * @Author Pawel Sprysak
    * @description Check is EVTOOPTRVL or EVTOOPLODG amounts exists
    * @param String eventId (Event Id)
    * @return Boolean
    */
    public static Boolean isOOPAmountExist(String eventId) {
        try {
            return [
                SELECT Id FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c = :eventId AND (
                    (EventTransactionTypeCode_gne__c = 'EVTOOPTRVL' AND EventTransactionAmount_gne__c > 0) OR
                    (EventTransactionTypeCode_gne__c = 'EVTOOPLODG' AND EventTransactionAmount_gne__c > 0)
                )
            ].size() > 0;
        } catch (QueryException e) {
            return true;
        }
    }

    /** @date 2/5/2014
    * @Author Pawel Sprysak
    * @description Get Event Summary transactions list
    * @param String eventId (Event Id)
    * @return List<VDST_EventTransactionSummary_gne__c>
    */
    public static List<VDST_EventTransactionSummary_gne__c> getSummaryTransactionsList(final String eventId) {
        try {
            return String.isBlank(eventId) ? new VDST_EventTransactionSummary_gne__c[]{ } : [
                SELECT EventTransactionAmount_gne__c, EventTransactionTypeCode_gne__c
                FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c = :eventId
                AND EventTransactionTypeCode_gne__c NOT IN :ADBOARD_AUX_TXNS
                AND EventTransactionAmount_gne__c > 0
                ORDER BY EventTransactionTypeCode_gne__c
            ];
        } catch (QueryException e) {
            return new VDST_EventTransactionSummary_gne__c[]{ };
        }
    }

    /** @date 11/1/2013
    * @Author Pawel Sprysak
    * @description Get transaction summary data
    * @param String eventId (Event Id)
    * @return List<VDST_EventTransactionSummary_gne__c>
    */
    public static List<VDST_EventTransactionSummary_gne__c> getTotalSummaryTransactions(final String eventId) {
        try {
            return String.isBlank(eventId) ? new VDST_EventTransactionSummary_gne__c[]{ } : [
                SELECT EventTransactionAmount_gne__c, VDST_Event_gne__r.ItemAmount_gne__c
                FROM VDST_EventTransactionSummary_gne__c
                WHERE VDST_Event_gne__c = :eventId
                AND EventTransactionTypeCode_gne__c = 'TOTALEVENT'
                LIMIT 1
            ];
        } catch (QueryException e) {
            return new VDST_EventTransactionSummary_gne__c[]{ };
        }
    }

    /** @date 10/4/2013
    * @Author Pawel Sprysak
    * @description Get user filters list method
    * @description Used on VDST_EventListController
    * @return List<VDST_Filter_gne__c>
    */
    public static List<VDST_Filter_gne__c> getUserFiltersList() {
        try {
            return [SELECT Id, FilterName_gne__c FROM VDST_Filter_gne__c WHERE FilterOwner_gne__c = :UserInfo.getUserId()];
        } catch (QueryException e) {
            return new List<VDST_Filter_gne__c>();
        }
    }

    /** @date 10/4/2013
    * @Author Pawel Sprysak
    * @description Get user filter by Id method
    * @description Used on VDST_EventListController
    * @param Id filterId (Filter Id)
    * @return VDST_Filter_gne__c
    */
    public static VDST_Filter_gne__c getUserFilterById(Id filterId) {
        try {
            return [SELECT Id, FilterName_gne__c, SortBy_gne__c, SortOrder_gne__c, (SELECT ColumnVisibility_gne__c, FilterField_gne__c, FilterValue_gne__c, FilterValueFrom_gne__c, FilterValueTo_gne__c, VDST_Filter_gne__c FROM VDST_Filter_Data__r) FROM VDST_Filter_gne__c WHERE Id = :filterId AND FilterOwner_gne__c = :UserInfo.getUserId()];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 10/4/2013
    * @Author Pawel Sprysak
    * @description Remove Filter by Id method
    * @description Used on VDST_EventListController
    * @param Id filterId (Filter Id)
    * @return Boolean
    */
    public static Boolean removeFilterById(Id filterId) {
        try {
            VDST_Filter_gne__c filterToRemove = [SELECT Id FROM VDST_Filter_gne__c WHERE Id = :filterId AND FilterOwner_gne__c = :UserInfo.getUserId()];
            if (filterToRemove != null) {
                delete filterToRemove;
                return true;
            }
            return false;
        } catch (QueryException e) {
            return false;
        }
    }

    /** @date 10/4/2013
    * @Author Pawel Sprysak
    * @description Get Only Genentech Event Types Map
    * @return Map<String, String>
    */
    public static Map<String, String> getOnlyGenentechEventTypes() {
        return new Map<String, String> {
            'BOOK'      => 'BOOK',
            'ECOUPON'   => 'ECOUPON',
            'JOURNAL'   => 'JOURNAL',
            'MEDWRTG'   => 'MEDWRTG',
            'RSCH'      => 'RSCH',
            'INDVSPND'  => 'INDVSPND'
        };
    }

    /** @date 3/20/2013
    * @Author Pawel Sprysak
    * @description Email validation method
    * @param Strin email (Email value)
    * @return Boolean
    */
    public static Boolean validateEmail(String email) {
        if (email == null) {
            return false;
        }
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(email);
        return emailMatcher.matches();
    }

    public static Boolean validateAddress(String address) {
        if (address == null) {
            return false;
        }
        for (Integer i = 0; i < address.length(); i++) {
            if (address.charAt(i) < 32 || address.charAt(i) > 127) {
                return false;
            }
        }
        return true;
    }

    public static Boolean validateCity(String city) {
        if (city == null) {
            return false;
        }
        for (Integer i = 0; i < city.length(); i++) {
            if (city.charAt(i) < 32 || city.charAt(i) > 127 || (city.charAt(i) > 47 && city.charAt(i) < 58)) {
                return false;
            }
        }
        return true;
    }

    public static Boolean validateState(String state) {
        return validateAddress(state);
    }

    /** @date 3/13/2013
    * @Author Pawel Sprysak
    * @description Get Event Date Transactions By Event Id Set (also deleted)
    * @param Set<Id> eventIdList (Event Id Set)
    * @return List<VDST_EventDateTransaction_gne__c>
    */
    public static List<VDST_EventDateTransaction_gne__c> getAllRowsEvDateTransByIdList(Set<Id> eventIdList) {
        try {
            return [SELECT Id, VDST_EventDate_gne__r.VDST_Event_gne__c  FROM VDST_EventDateTransaction_gne__c WHERE id IN :eventIdList ALL ROWS];
        } catch (QueryException e) {
            return new List<VDST_EventDateTransaction_gne__c>();
        }
    }

    /** @date 3/5/2013
    * @Author Pawel Sprysak
    * @description Method for trigger VDST_EventTransactionsUpdateDT on VDST_EventDateTransaction_gne__c
    * @param Set<String> eventIds (Set of Event Id's)
    */
    public static void updateEventsTransactionsDT(Set<String> eventIds) {
        Map<String, VDST_EventTransactionSummary_gne__c> etMap = new Map<String, VDST_EventTransactionSummary_gne__c>();
        // Get actual Event Transaction Summary objects for event Id's
        for (VDST_EventTransactionSummary_gne__c et : [SELECT Id, EventTransactionAmount_gne__c, EventTransactionTypeCode_gne__c, VDST_Event_gne__c FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c IN :eventIds AND EventTransactionTypeCode_gne__c =: 'EVTMEALS']) {
            et.EventTransactionAmount_gne__c = 0;
            etMap.put(et.VDST_Event_gne__c, et);
        }
        // Create new Event Transaction Summary objects if they do not exist
        for (String evId : eventIds) {
            if (!etMap.containsKey(evId)) {
                VDST_EventTransactionSummary_gne__c et = new VDST_EventTransactionSummary_gne__c(EventTransactionLevel_gne__c = 'EVNT', EventTransactionAmount_gne__c=0, EventTransactionTypeCode_gne__c='EVTMEALS', VDST_Event_gne__c=evId);
                etMap.put(evId, et);
            }
        }
        // Update all Amounts in Event Transacion Summary Objects
        for (VDST_EventDateTransaction_gne__c edt : [SELECT EventDateTransactionAmount_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__c  FROM VDST_EventDateTransaction_gne__c WHERE VDST_EventDate_gne__r.VDST_Event_gne__c IN :eventIds]) {
            etMap.get(edt.VDST_EventDate_gne__r.VDST_Event_gne__c).EventTransactionAmount_gne__c += edt.EventDateTransactionAmount_gne__c;
        }
        // Create or Update Event Transaction Summary objects
        upsert etMap.values();
    }

    /** @date 5/28/2013
    * @Author Pawel Sprysak
    * @description Method for trigger VDST_EventTransactionsUpdateDT on VDST_EventDateTransaction_gne__c
    * @param Set<String> accntToUpdate (Set of Event Id's)
    */
    public static void updatePrtcpntTransactionsDM(Set<String> accntToUpdate) {
        if (accntToUpdate.size() > 0) {
            Map<String, List<VDST_EventPrtcpntAttendance_gne__c>> epaMap = new Map<String, List<VDST_EventPrtcpntAttendance_gne__c>>();
            for (VDST_EventPrtcpntAttendance_gne__c epa : [SELECT Id, Event_PrtcpntAccnt_gne__c, MealAmount_gne__c FROM VDST_EventPrtcpntAttendance_gne__c WHERE Event_PrtcpntAccnt_gne__c IN :accntToUpdate]) {
                if (epaMap.containsKey(epa.Event_PrtcpntAccnt_gne__c)) {
                    epaMap.get(epa.Event_PrtcpntAccnt_gne__c).add(epa);
                } else {
                    epaMap.put(epa.Event_PrtcpntAccnt_gne__c, new List<VDST_EventPrtcpntAttendance_gne__c>{epa});
                }
            }
            List<VDST_PrtcpntTransaction_gne__c> ptList = [SELECT Id, TransactionAmount_gne__c, VDST_EventPrtcpntAccnt_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__c IN :accntToUpdate AND TransactionTypeCode_gne__c = 'HCPMEALS'];
            Map<String, VDST_PrtcpntTransaction_gne__c> ptMap = new Map<String, VDST_PrtcpntTransaction_gne__c>();
            for (VDST_PrtcpntTransaction_gne__c pt : ptList) {
                ptMap.put(pt.VDST_EventPrtcpntAccnt_gne__c, pt);
            }
            if (ptList.size() < accntToUpdate.size()) {
                for (String accntId : accntToUpdate) {
                    if (!ptMap.containsKey(accntId)) {
                        ptList.add(new VDST_PrtcpntTransaction_gne__c(VDST_EventPrtcpntAccnt_gne__c = accntId, VDST_PaidToParty_gne__c = accntId, TransactionAmount_gne__c = 0, TransactionLevel_gne__c = 'INDV', TransactionTypeCode_gne__c = 'HCPMEALS', TransactionAllocationType_gne__c = 'DIRECT', FeePayToPartyType_gne__c = 'INDV'));
                    }
                }
            }
            for (VDST_PrtcpntTransaction_gne__c pt : ptList) {
                pt.TransactionAmount_gne__c = 0;
                if (!epaMap.containsKey(pt.VDST_EventPrtcpntAccnt_gne__c)) {
                    break;
                }
                for (VDST_EventPrtcpntAttendance_gne__c epa : epaMap.get(pt.VDST_EventPrtcpntAccnt_gne__c)) {
                    if (epa.MealAmount_gne__c != null) {
                       pt.TransactionAmount_gne__c += epa.MealAmount_gne__c;
                    }
                }
            }
            upsert ptList;
        }
    }

    /** @date 3/15/2013
    * @Author Pawel Sprysak
    * @description Method for trigger VDST_EventTransactionsUpdatePT on VDST_PrtcpntTransaction_gne__c
    * @param Set<String> eventIds (Set of Event Id's)
    */
    public static void updateEventsTransactionsPT(final Set<String> eventIds) {
        // Create Map of Event Types with Set of Transactions for this Event Type
        final Map<String, Set<String>> txnTypes = new Map<String, Set<String>>{
            'ADBOARD' => new Set<String>{ EVT_HCP_MEALS_TXN } // AGGSPENDME-166
        };
        for (VDST_EventField_gne__c evtFld : [
            SELECT EventType_gne__c, FieldName_gne__c FROM VDST_EventField_gne__c
            WHERE EventStatus_gne__c = 'Transactions' AND FieldName_gne__c != 'VENUEAV'
        ]) {
            if (txnTypes.containsKey(evtFld.EventType_gne__c)) {
                txnTypes.get(evtFld.EventType_gne__c).add(evtFld.FieldName_gne__c);
            } else {
                txnTypes.put(evtFld.EventType_gne__c, new Set<String>{ evtFld.FieldName_gne__c });
            }
        }
        // Create Map of Event Id's with Existing Summary Transactions for them
        final Map<Id, Map<String, VDST_EventTransactionSummary_gne__c>> evtTxns = new Map<Id, Map<String, VDST_EventTransactionSummary_gne__c>>();
        for (VDST_EventTransactionSummary_gne__c txn : [
            SELECT
                EventTransactionAmount_gne__c,
                EventTransactionTypeCode_gne__c,
                VDST_Event_gne__r.EventType_gne__c
            FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c IN :eventIds
            AND EventTransactionTypeCode_gne__c NOT IN :TOTAL_CALC_EXCLUDED_TXNS.keySet()
            AND EventTransactionTypeCode_gne__c != 'VENUEAV'
        ]) {
            if ((isNonResearchEventType(txn.VDST_Event_gne__r.EventType_gne__c) ||
                txn.EventTransactionTypeCode_gne__c != 'EVTMEALS'
            ) && txnTypes.containsKey(txn.VDST_Event_gne__r.EventType_gne__c) &&
                txnTypes.get(txn.VDST_Event_gne__r.EventType_gne__c).contains(txn.EventTransactionTypeCode_gne__c)
            ) {
                txn.EventTransactionAmount_gne__c = 0;
                if (!evtTxns.containsKey(txn.VDST_Event_gne__c)) {
                    evtTxns.put(txn.VDST_Event_gne__c, new Map<String, VDST_EventTransactionSummary_gne__c>());
                }
                evtTxns.get(txn.VDST_Event_gne__c).put(txn.EventTransactionTypeCode_gne__c, txn);
            }
        }
        // Create Map with Participant Transactions
        for (VDST_PrtcpntTransaction_gne__c txn : [
            SELECT
                EventType_gne__c,
                VDST_Event_gne__c,
                TransactionAmount_gne__c,
                TransactionTypeCode_gne__c,
                VDST_EventPrtcpntAccnt_gne__r.ParticipantContractStatus_gne__c,
                VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__r.IsABMEvent_gne__c
            FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__c IN :eventIds
            AND ((FeePayToPartyType_gne__c = 'INDV' OR EventType_gne__c = 'INDVSPND') OR (FeePayToPartyType_gne__c = 'ORG' AND  VDST_EventPrtcpntAccnt_gne__r.ParticipantRole_gne__c = 'PAYEEPI'))
        ]) {
            if (!evtTxns.containsKey(txn.VDST_Event_gne__c)) {
                evtTxns.put(txn.VDST_Event_gne__c, new Map<String, VDST_EventTransactionSummary_gne__c>());
            }
            final String extKey = txn.VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__r.IsABMEvent_gne__c ?
                txn.EventType_gne__c + '_' +
                txn.TransactionTypeCode_gne__c + '_' +
                txn.VDST_EventPrtcpntAccnt_gne__r.ParticipantContractStatus_gne__c : txn.EventType_gne__c;
            final Map<String, String> txnMapping = EVT_TXNS_MAPPING.get(isNonResearchEventType(txn.EventType_gne__c));
            if (txnMapping.containsKey(txn.TransactionTypeCode_gne__c) || txnMapping.containsKey(extKey)) {
                final String code = txnMapping.get(extKey) == null ?
                    txnMapping.get(txn.TransactionTypeCode_gne__c) : txnMapping.get(extKey);
                if (!evtTxns.get(txn.VDST_Event_gne__c).containsKey(code)) {
                    evtTxns.get(txn.VDST_Event_gne__c).put(code, new VDST_EventTransactionSummary_gne__c(
                        VDST_Event_gne__c = txn.VDST_Event_gne__c,
                        EventTransactionTypeCode_gne__c = code,
                        EventTransactionLevel_gne__c = 'EVNT',
                        EventTransactionAmount_gne__c = 0
                    ));
                }
                if (txn.TransactionAmount_gne__c != null) {
                    evtTxns.get(txn.VDST_Event_gne__c).get(code).EventTransactionAmount_gne__c += txn.TransactionAmount_gne__c;
                }
            }
        }
        // Create final List of Summary Transactions to Insert/Update
        final VDST_EventTransactionSummary_gne__c[] modifiedSums = new VDST_EventTransactionSummary_gne__c[]{ };
        for (Map<String, VDST_EventTransactionSummary_gne__c> sums : evtTxns.values()) {
            for (VDST_EventTransactionSummary_gne__c sum : sums.values()) {
                modifiedSums.add(sum);
            }
        }
        upsert modifiedSums;
    }

    /** @date 11/14/2013
    * @Author Pawel Sprysak
    * @description Wrapper class for Event Transaction
    */
    public class EventTransaction {
        public Decimal HCPFaB       {get; set;}
        public Decimal HCPLodging   {get; set;}
        public Decimal HCPTravel    {get; set;}
        public Decimal HCPFees      {get; set;}
        public Decimal OOPFaB       {get; set;}
        public Decimal OOPLodging   {get; set;}
        public Decimal OOPTravel    {get; set;}
        public Decimal OOPOther     {get; set;}

        public EventTransaction() {
            HCPFaB      = 0;
            HCPLodging  = 0;
            HCPTravel   = 0;
            HCPFees     = 0;
            OOPFaB      = 0;
            OOPLodging  = 0;
            OOPTravel   = 0;
            OOPOther    = 0;
        }
    }

    /*** MANAGING VENDOR EVENT/PARTICIPANT ID - BEGIN ***/

    /** @date 11/20/2013
    * @Author Pawel Sprysak
    * @description Check is Vendor Event Id unique in application
    * @description Used in: VDST_EventDetailController
    * @param String logisticVendorCode, String vendorParticipantId, String excludeSFDCId
    * @return Boolean
    */
    public static Boolean isVendorEventIdUnique(String logisticVendorCode, String vendorEventId, String excludeSFDCId) {
        if (String.isBlank(vendorEventId)) {
            return true;
        }
        if (!String.isBlank(logisticVendorCode)) {
            Set<String> vendorEventIds = generateVendorIdsSet(logisticVendorCode, vendorEventId);
            try {
                // Check in final table
                List<VDST_Event_gne__c> evtsList = [ SELECT Id FROM VDST_Event_gne__c WHERE VendorEventID_gne__c IN :vendorEventIds AND Id != :excludeSFDCId ];
                // Check in R2 batch table
                List<VDST_BatchRecord_gne__c> batchRecsList = [ SELECT Id FROM VDST_BatchRecord_gne__c
                                                            WHERE EventId_gne__c IN :vendorEventIds
                                                                 AND VDST_BatchFile_gne__r.isDeleted_gne__c = false
                                                                 AND VDST_BatchFile_gne__r.Status_frm_gne__c != 'Stored' ];
                if ((evtsList == null || evtsList.isEmpty()) && (batchRecsList == null || batchRecsList.isEmpty())) {
                    return true;
                }
            } catch (QueryException e) {
                return false;
            }
        }
        return false;
    }

    /** @date 11/20/2013
    * @Author Pawel Sprysak
    * @description Check is Vendor Participant Id unique in application
    * @description Used in: VDST_EventDetailController
    * @param String logisticVendorCode, String vendorParticipantId, String excludeSFDCId
    * @return Boolean
    */
    public static Boolean isVendorParticipantIdUnique(String logisticVendorCode, String vendorParticipantId, String excludeSFDCId) {
        if (String.isBlank(vendorParticipantId)) {
            return true;
        }
        if (!String.isBlank(logisticVendorCode)) {
            Set<String> vendorParticipantIds = generateVendorIdsSet(logisticVendorCode, vendorParticipantId);
            try {
                // Check in final table
                List<VDST_EventPrtcpntAccnt_gne__c> prtcpntsList = [ SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c WHERE VendorParticipantID_gne__c IN :vendorParticipantIds AND Id != :excludeSFDCId ];
                // Check in R2 batch table
                List<VDST_BatchRecord_gne__c> batchRecsList = [ SELECT Id FROM VDST_BatchRecord_gne__c
                                                                 WHERE ParticipantID_gne__c IN :vendorParticipantIds
                                                                     AND VDST_BatchFile_gne__r.isDeleted_gne__c = false
                                                                     AND VDST_BatchFile_gne__r.Status_frm_gne__c != 'Stored' ];
                // Check in removed participant table
                List<VDST_DeletedParticipantsId_gne__c> removedPrtcpntsList = [ SELECT Id FROM VDST_DeletedParticipantsId_gne__c WHERE VendorParticipantId_gne__c IN :vendorParticipantIds ];
                if ((prtcpntsList == null || prtcpntsList.isEmpty()) && (batchRecsList == null || batchRecsList.isEmpty()) && (removedPrtcpntsList == null || removedPrtcpntsList.isEmpty())) {
                    return true;
                }
            } catch (QueryException e) {
                return false;
            }
        }
        return false;
    }

    /** @date 11/21/2013
    * @Author Pawel Sprysak
    * @description Method for returning not unique Vendor Participant Ids
    * @description Used in: VDST_EventDetailController
    * @param String logisticVendorCode, Set<String> vendorParticipantIdList, String excludeSFDCId
    * @return List<String>
    */
    public static List<String> notUniqueVendorParticipantIds(String logisticVendorCode, Set<String> vendorParticipantIdList, String excludeSFDCId, String eventId) {
        if (!String.isBlank(logisticVendorCode)) {
            Set<String> vendorParticipantIds = new Set<String>();
            for (String str : vendorParticipantIdList) {
                vendorParticipantIds.addAll(generateVendorIdsSet(logisticVendorCode, str));
            }
            try {
                List<String> finalIdsList = new List<String>();
                // Check in final table
                if (String.isBlank(eventId)) {
                    for (VDST_EventPrtcpntAccnt_gne__c epa : [ SELECT Id, VendorParticipantID_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VendorParticipantID_gne__c IN :vendorParticipantIds]) {
                        finalIdsList.add(epa.VendorParticipantID_gne__c);
                    }
                } else {
                    for (VDST_EventPrtcpntAccnt_gne__c epa : [ SELECT Id, VendorParticipantID_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VendorParticipantID_gne__c IN :vendorParticipantIds AND VDST_Event_gne__c != :eventId]) {
                        finalIdsList.add(epa.VendorParticipantID_gne__c);
                    }
                }
                // Check in R2 batch table
                for (VDST_BatchRecord_gne__c br : [ SELECT Id, ParticipantID_gne__c FROM VDST_BatchRecord_gne__c
                                                                 WHERE ParticipantID_gne__c IN :vendorParticipantIds
                                                                     AND VDST_BatchFile_gne__r.isDeleted_gne__c = false
                                                                     AND VDST_BatchFile_gne__r.Status_frm_gne__c != 'Stored' ]) {
                    finalIdsList.add(br.ParticipantID_gne__c);
                }
                // Check in removed participant table
                for (VDST_DeletedParticipantsId_gne__c dpi : [ SELECT Id, VendorParticipantId_gne__c FROM VDST_DeletedParticipantsId_gne__c WHERE VendorParticipantId_gne__c IN :vendorParticipantIds ]) {
                    finalIdsList.add(dpi.VendorParticipantId_gne__c);
                }
                return finalIdsList;
            } catch (QueryException e) {
                return new List<String>();
            }
        }
        return new List<String>();
    }

    /** @date 11/20/2013
    * @Author Pawel Sprysak
    * @description Get set of logistic vendor code and vendor id combinations
    * @description Used in: VDST_Utils
    * @param String logisticVendorCode, String vendorId
    * @return Set<String>
    */
    public static Set<String> generateVendorIdsSet(String logisticVendorCode, String vendorId) {
        vendorId = vendorId.toUpperCase();
        Set<String> vendorIdsSet = new Set<String>();
        vendorIdsSet.add(vendorId);
        vendorIdsSet.add(logisticVendorCode + '_' + vendorId);
        vendorIdsSet.add(vendorId.removeStartIgnoreCase(logisticVendorCode + '_'));
        return vendorIdsSet;
    }

    /** @date 11/20/2013
    * @Author Pawel Sprysak
    * @description Method for generating first free Vendor Event Id
    * @description Used in: VDST_EventDetailController
    * @param String logisticVendorCode
    * @return String
    */
    public static String generateFirstFreeVendorEventId(String logisticVendorCode) {
        if (logisticVendorCode != null) {
            String firstIter = getGeneratedStringId();
            if ( isVendorEventIdUnique(logisticVendorCode, firstIter, null)) {
                return logisticVendorCode + '_' + firstIter;
            } else { // Very unlikely
                return generateFirstFreeVendorEventId(logisticVendorCode);
            }
        } else {
            return null;
        }
    }

    /** @date 11/20/2013
    * @Author Pawel Sprysak
    * @description Method for generating first free Vendor Participant Id
    * @description Used in: VDST_EventDetailPrtcpntUtils
    * @param String logisticVendorCode
    * @return String
    */
    public static String generateFirstFreeVendorParticipantId(String logisticVendorCode) {
        String firstIter = getGeneratedStringId();
        if ( isVendorParticipantIdUnique(logisticVendorCode, firstIter, null)) {
            return logisticVendorCode + '_' + firstIter;
        } else { // Very unlikely
            return generateFirstFreeVendorParticipantId(logisticVendorCode);
        }
    }

    /** @date 11/20/2013
    * @Author Pawel Sprysak
    * @description Method for generating first free Vendor Participant Id
    * @description Used in: VDST_EventDetailPrtcpntUtils
    * @param String logisticVendorCode
    * @return String
    */
    public static List<String> generateFirstCoupleFreeVendorParticipantId(String logisticVendorCode, Integer howMany) {
        List<String> finalList = new List<String>();
        // Generate list of Id's
        List<String> firstList = new List<String>();
        for (Integer i = 0; i<howMany; i++) {
            firstList.add(logisticVendorCode + '_' + getGeneratedStringId());
        }
        // Fix duplicates
        Set<String> idsSet = new Set<String>();
        idsSet.addAll(firstList);
        List<String> listOfDuplicates = notUniqueVendorParticipantIds(logisticVendorCode, idsSet, null, null);
        if (listOfDuplicates.isEmpty()) {
            return firstList;
        }
        while (!listOfDuplicates.isEmpty()) {
            for (String str : firstList) {
                Boolean isDuplicated = false;
                for (String duplStr : listOfDuplicates) {
                    if (duplStr.equalsIgnoreCase(str)) {
                        isDuplicated = true;
                    }
                }
                if (!isDuplicated) {
                    finalList.add(str);
                }
            }
            firstList.clear();
            for (Integer i = 0; i<listOfDuplicates.size(); i++) {
                firstList.add(getGeneratedStringId());
            }
            idsSet = new Set<String>();
            idsSet.addAll(firstList);
            listOfDuplicates = notUniqueVendorParticipantIds(logisticVendorCode, idsSet, null, null);
        }
        return finalList;
    }

    /** @date 11/21/2013
    * @Author Pawel Sprysak
    * @description Get generated String Vendor Id
    * @description Used in: VDST_Utils
    * @return String
    */
    public static String getGeneratedStringId() {
        return String.valueOf(DateTime.now().getTime()) + String.valueOf(Integer.valueOf(Math.random()*100000)).leftPad(5).replace(' ', '0');
    }

    /*** MANAGING VENDOR EVENT/PARTICIPANT ID - END ***/

    /** @date 8/14/2014
    * @Author Konrad Malinowski
    * @description Method for returning not unique Participant's Unix Ids With Vendor Ids Map
    * @param String eventId
    * @param List<String> unixIds
    * @return Map<String, String>
    */
    public static Map<String, String> getNotUniqueParticipantUnixIdsWithVendorIdsForEvent(String eventId, List<String> unixIds) {
        try {
            Map<String, String> nonUniqueUnixIds = new Map<String, String>();
            for (VDST_EventPrtcpntAccnt_gne__c p : [
                SELECT  UnixID_gne__c, VendorParticipantID_gne__c
                FROM    VDST_EventPrtcpntAccnt_gne__c
                WHERE   VDST_Event_gne__c = :eventId
                AND     UnixID_gne__c IN :unixIds
            ]){
                nonUniqueUnixIds.put(p.UnixID_gne__c, p.VendorParticipantID_gne__c);
            }
            return nonUniqueUnixIds;
        } catch (QueryException e) {
            return new Map<String, String>();
        }
    }

    /** @date 6/24/2014
    * @Author Konrad Malinowski
    * @description Method for trimming String value
    * @param String val
    * @return String
    */
    public static String getTrimValFromStr(String val) {
        return (val != null ? val.trim() : null);
    }

    /** @date 7/21/2014
    * @Author Konrad Malinowski
    * @description Method for removing blank lines from String value
    * @param String val
    * @return String
    */
    public static String getValWithoutBlankLinesFromStr(String val) {
        String whitespaceRegexPattern = '\\' + 's';
        return (val != null ? val.replaceAll('\r', '\n').replaceAll('\n' + whitespaceRegexPattern + '+', '\n')
            .replaceAll('^' + whitespaceRegexPattern + '+', '').replaceAll(whitespaceRegexPattern + '+$', '') : null);
    }

    /** @date 7/17/2014
    * @Author Konrad Malinowski
    * @description Method for converting Blob to String with given encoding
    * @param Blob file
    * @return String
    */
    public static String convertBlobToString(Blob file, String encoding) {
        // Example of process of converting text file saved as Blob to String:
        // [When file is not UTF-8 valid method does not throw exception (unlike method blobInstance.toString()]
        // Text: [dog]
        // Text to Hex: [64 6f 67]
        // Hex to Bytes: [0110 0100   0110 1111   0110 0111]
        // Hex grouped into Bytes in x-www-form-urlencoded format: [%64%6f%67]
        // Text decoded from x-www-form-urlencoded format: [dog]
        String fileConvertedToHex = EncodingUtil.convertToHex(file);
        Boolean isNumberOfHexesEven = (Math.mod(fileConvertedToHex.length(), 2) == 0);
        if (!isNumberOfHexesEven) {
            return null;
        }
        Integer numberOfFileBytes = fileConvertedToHex.length() / 2;
        String[] fileBytes = new String[numberOfFileBytes];
        for (Integer i = 0; i < numberOfFileBytes; i++) {
            fileBytes[i] =  fileConvertedToHex.mid((i * 2), 2);
        }
        String fileInUrlEncodedFormat = '%' + String.join(fileBytes, '%');
        return EncodingUtil.urlDecode(fileInUrlEncodedFormat, encoding);
    }

    /** @date 4/24/2015
    * @Author Konrad Malinowski
    * @description Method for assigning Permission Set to User
    * @param Id userId
    * @param String permissionSetName
    */
    public static void assignPermissionSetToUser(Id userId, String permissionSetName) {
       PermissionSet permissionSet = [SELECT Name, Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
       if ([SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId = :permissionSet.Id LIMIT 1] == 0) {
           insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permissionSet.Id);
       }
    }

    /** @date 4/24/2015
    * @Author Konrad Malinowski
    * @description Method for unassigning Permission Set from User
    * @param Id userId
    * @param String permissionSetName
    */
    public static void unassignPermissionSetFromUser(Id userId, String permissionSetName) {
       PermissionSet permissionSet = [SELECT Name, Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
       delete [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId = :permissionSet.Id];
    }

    public static List<EventDateTransactions> convertEventDateTransactionsToWrapper(List<VDST_EventDateTransaction_gne__c> evDateTransObjList) {
        List<EventDateTransactions> evDateTransList = new List<EventDateTransactions>();
        if (evDateTransList == null) {
            evDateTransList = new List<VDST_Utils.EventDateTransactions>();
        } else {
            evDateTransList.clear();
        }
        for (VDST_EventDateTransaction_gne__c edt : evDateTransObjList) {
            Datetime dt = edt.VDST_EventDate_gne__r.EventDate_gne__c;
            evDateTransList.add(
                new EventDateTransactions(
                    dt.formatGmt('MMM dd, yyyy'),
                    edt.EventDateTransactionAmount_gne__c,
                    Integer.valueOf(edt.VDST_EventDate_gne__r.ActualAttendeeRollup_gne__c),
                    edt.EventDateTransactionTypeCode_gne__c,
                    edt.NumberOfMeals_gne__c
                )
            );
        }
        return evDateTransList;
    }

    /** @date 2/28/2013
    * @Author Pawel Sprysak
    * @description Wrapper class for Event Date Transaction object
    */
    public class EventDateTransactions {
        public String      eventType            { get; set; }
        public String      eventDate            { get; set; }
        public Decimal     totalFaB             { get; set; }
        public Integer     attendeesCount       { get; set; }
        public String      inputTotalFaB        { get; set; }
        public String      numberOfMeals        { get; set; }

        public EventDateTransactions(String evDate, Decimal total, Integer attCount, String evType, String evNumOfMeals) {
            if (total==null) {
                this.totalFaB = 0.00;
                this.inputTotalFaB = '0.00';
            } else {
                this.totalFaB = total;
                this.inputTotalFaB = String.valueOf(total);
            }
            if (attCount==null) {
                this.attendeesCount = 0;
            } else {
                this.attendeesCount = attCount;
            }
            this.eventType = evType;
            this.eventDate = evDate;
            this.numberOfMeals = evNumOfMeals;
        }
    }
}