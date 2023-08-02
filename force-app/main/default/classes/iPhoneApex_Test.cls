@isTest
public with sharing class iPhoneApex_Test {
    private static final String US_REGION_CODE = 'US';
    private static final String CANADA_REGION_CODE = 'CAN';
    private static final String CANADA_PROFILE_NAME = 'RCANADA-SFA-TS';
    private static final String US_PROFILE_NAME = 'GNE-Field'; //'GNE-SFA-Ops'; //'GNE-SFA-CS';
    private static final String US_HCP_RECORD_TYPE_NAME = 'Health Care Professional (Prescriber)';
    private static final String US_HCO_RECORD_TYPE_NAME = 'Hospital';
    private static final String CAN_HCP_RECORD_TYPE_NAME = 'HCP Canada';
    private static final String CAN_HCO_RECORD_TYPE_NAME = 'GNE-SFA-Roche_Canada';
    private static final String US_ADDRESS_RECORD_TYPE_NAME = 'Rep Maintained';
    private static final String CAN_HCP_ADDRESS_RECORD_TYPE_NAME = 'SFA Canada Rep Maintained HCP';
    private static final String CAN_HCO_ADDRESS_RECORD_TYPE_NAME = 'SFA Canada Rep Maintained HCO';
    private static final String COLLATERAL_VALUE = 'No Collateral';
    private static final String REQUEST_SIGNATURE_VALUE = 'SIGNATURE';

    private static Integer requestIdIdx;
    private static Boolean isOtrRequest;
    private static User usOwner;
    private static User canOwner;
    private static Map<String,Id> accRecTypesCache;
    private static Map<String,Id> addrRecTypesCache;
    private static Map<String,List<Product_vod__c>> detailProductsCache;
    private static Map<String,List<Product_vod__c>> sampleProductsCache;
    private static Map<String,List<Product_vod__c>> pfgProductsCache;
    private static Map<String,Object> callAttributesCache;
    private static Map<Id,Call2_vod__c> callsCache;
    private static Map<Id,Call2_Sample_vod__c> callSampleCache;
    private static AccountTestHelper accountTestHelper;
    private static MergeTestHelper mergeTestHelper;
    private static Map<Id,Id> loserToWinnerMap;
    private static Boolean pfgMode = true;
    private static final Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
    
    @testSetup
    static void initData() {
        User adminUser = GNE_FRM_TestUtilities.createUser('archivedUser', ids2ProfilesMap.get('GNE-SYS-Support'), true);
        createTestUsers();
    }

    static void createTestUsers() {
        List<User> usersToInsertList = new List<User> {
                new User(
                        ProfileId           = [SELECT Id FROM Profile WHERE Name = :US_PROFILE_NAME LIMIT 1].Id,
                        TimeZoneSidKey      = 'America/Los_Angeles',
                        Email               = 'us@gene.com',
                        FirstName           = 'usUser',
                        External_ID_gne__c  = 'ustest',
                        Alias               = 'ustest',
                        Username            = 'UsTest@gene.com',
                        EmailEncodingKey    = 'UTF-8',
                        LanguageLocaleKey   = 'en_US',
                        LocaleSidKey        = 'en_US',
                        LastName            = 'User',
                        IsActive            = true
                ),
                new User(
                        ProfileId           = [SELECT Id FROM Profile WHERE Name = :CANADA_PROFILE_NAME LIMIT 1].Id,
                        TimeZoneSidKey      = 'America/Los_Angeles',
                        Email               = 'can@gene.com',
                        FirstName           = 'canUser',
                        External_ID_gne__c  = 'cantest',
                        Alias               = 'cantest',
                        Username            = 'CanTest@gene.com',
                        EmailEncodingKey    = 'UTF-8',
                        LanguageLocaleKey   = 'en_US',
                        LocaleSidKey        = 'en_US',
                        LastName            = 'User',
                        IsActive            = true
                )};
        insert usersToInsertList;
    }

    static testMethod void createCall() {
        intCreateCall(false, true, US_REGION_CODE, 'HCP');
    }

    static testMethod void createCompletedCall() {
        intCreateCall(true, true, US_REGION_CODE, 'HCP');
    }

    static testMethod void updateCall() {
    	pfgMode = false;
        intUpdateCall(true, true, US_REGION_CODE, 'HCP');
    }

    static testMethod void createHcoCall() {
        intCreateCall(false, true, US_REGION_CODE, 'HCO');
    }

    static testMethod void createHcoCompletedCall() {
        intCreateCall(true, true, US_REGION_CODE, 'HCO');
    }

    static testMethod void updateHcoCall() {
        intUpdateCall(true, true, US_REGION_CODE, 'HCO');
    }

    static testMethod void createCanadaCall() {
        intCreateCall(false, true, CANADA_REGION_CODE, 'HCP');
    }

    static testMethod void createCanadaCompletedCall() {
        intCreateCall(true, true, CANADA_REGION_CODE, 'HCP');
    }

    static testMethod void updateCanadaCall() {
        intUpdateCall(true, true, CANADA_REGION_CODE, 'HCP');
    }

    static testMethod void createCanadaHcoCall() {
        intCreateCall(false, true, CANADA_REGION_CODE, 'HCO');
    }

    static testMethod void createCanadaHcoCompletedCall() {
        intCreateCall(true, true, CANADA_REGION_CODE, 'HCO');
    }

    static testMethod void updateCanadaHcoCall() {
        intUpdateCall(true, true, CANADA_REGION_CODE, 'HCO');
    }

    static testMethod void updateCallAfterAccountMerge() {
    	pfgMode = false;
        intUpdateCallAfterMerge('HCP', true, false);
    }

    static testMethod void updateHcoCallAfterAccountMerge() {
        intUpdateCallAfterMerge('HCO', true, false);
    }

    static testMethod void updateCallAfterAddressMerge() {
        intUpdateCallAfterMerge('HCP', false, true);
    }

    static void createCallFailedValidation() {
        initEnv();

        System.runAs(usOwner) {
            List<Product_vod__c> detailProds = detailProductsCache.get('US');
            List<Product_vod__c> sampleProds = sampleProductsCache.get('US');

            Set<Id> accIds = accountTestHelper.accountsByTypeCache.get('US_HCP');

            Account parentAcc;
            List<Account> attendees = new List<Account>();
            Boolean isFirst = true;

            for(Id accId : accIds) {
                if(isFirst) {
                    isFirst = false;
                    parentAcc = accountTestHelper.accountsCache.get(accId);
                } else {
                    attendees.add(accountTestHelper.accountsCache.get(accId));
                }
            }

            iPhoneApex_2.CallAttributes cAttrs = createCallAttributes(parentAcc,
                    null, null, true, 'Account Call', null, null,
                    attendees, detailProds, sampleProds, null);

            cAttrs.CallDateTime = cAttrs.CallDateTime.addDays(1);

            Test.startTest();

            iPhoneApex_2.Response wsResult = iPhoneApex_2.updateOrCreateCall(cAttrs);

            Test.stopTest();

            cacheCall(cAttrs.RequestId);

            System.assertEquals(0, callsCache.size(), 'Call shouldn\'t be created');
            System.assertEquals(0, callSampleCache.size(), 'Call Samples shouldn\'t be created');

            assertErrorLog(cAttrs, Label.GNE_SFA2_ErrMsg_Interaction_GNE_COMPLETED);
        }
    }

    private static void intCreateCall(Boolean isCompleted, Boolean isAssertMode, String region, String accType) {
        initEnv();
        intCreateCall(isCompleted, isAssertMode, region, accType, new List<Id>(accountTestHelper.accountsByTypeCache.get(region + '_' + accType)));
    }

    private static void intCreateCall(Boolean isCompleted, Boolean isAssertMode, String region, String accType, List<Id> accIds) {
        intCreateCall(isCompleted, isAssertMode, region, accType, accIds, null);
    }

    private static void intCreateCall(Boolean isCompleted, Boolean isAssertMode, String region, String accType, List<Id> accIds, Id addrId) {
        initEnv();
        System.runAs(region == US_REGION_CODE ? usOwner : canOwner) {
            List<Product_vod__c> detailProds = detailProductsCache.get(region);
            List<Product_vod__c> sampleProds = accType!='HCO' ? sampleProductsCache.get(region) : null;
            List<Product_vod__c> pfgProds = (pfgMode==true && accType!='HCO') ? pfgProductsCache.get(region) : null;

            Account parentAcc;
            List<Account> attendees = new List<Account>();
            Boolean isFirst = true;

            for(Id accId : accIds) {
                if(isFirst) {
                    isFirst = false;
                    parentAcc = accountTestHelper.accountsCache.get(accId);
                } else {
                    attendees.add(accountTestHelper.accountsCache.get(accId));
                }
            }

            iPhoneApex_2.CallAttributes cAttrs = createCallAttributes(null, parentAcc, (addrId!=null ? accountTestHelper.addressCache.get(addrId) : null),
                    null, null, isCompleted, 'Account Call', null, null,
                    attendees, detailProds, sampleProds, pfgProds);

            if(isAssertMode) {
                Test.startTest();
            }

            iPhoneApex_2.Response wsResult = iPhoneApex_2.intUpdateOrCreateCall(cAttrs, new iPhoneApex_2.Response());
            cacheCall(cAttrs.RequestId);

            if(isAssertMode) {
                Test.stopTest();

                assertWsResponse(wsResult, cAttrs, true);
                assertCall(cAttrs);
            }
        }
    }

    private static void intUpdateCall(Boolean isCompleted, Boolean isAssertMode, String region, String accType) {
        intUpdateCall(true, isCompleted, isAssertMode, region, accType);
    }

    private static void intUpdateCall(Boolean createFirstMode, Boolean isCompleted, Boolean isAssertMode, String region, String accType) {
        if(createFirstMode) {
            intCreateCall(false, false, region, accType);
        }

        System.runAs(region == US_REGION_CODE ? usOwner : canOwner) {
            Call2_vod__c call = callsCache.values()[0];
            iPhoneApex_2.CallAttributes cAttrs = createCallAttributes(call,
                    null, isCompleted, 'Sales Call', null, null,
                    null, null, null, null);

            // clear PFG cache
            iPhoneApex_PFG_Util.proposedCallPfgDetailMap = null;
            GNE_SFA2_PFG_Util.callDetailsCache = null;
            GNE_SFA2_PFG_Util.callDetailTransactionsCache = null;
            iPhoneApex_2.Response wsResult = iPhoneApex_2.intUpdateOrCreateCall(cAttrs, new iPhoneApex_2.Response());
            cacheCall(cAttrs.RequestId);

            if(isAssertMode) {
                assertWsResponse(wsResult, cAttrs, true);
                assertCall(cAttrs);
            }
        }
    }

    private static void intUpdateCallAfterMerge(String accType, Boolean accountMergeMode, Boolean addrMergeMode) {
        initEnv();
        Map<Id,Id> winnerToLoserMap = mergeTestHelper.createLoserAccountsWithPlaceholders(accountTestHelper.accountsByTypeCache.get(US_REGION_CODE + '_' + accType));
        Set<Id> allIds = new Set<Id>(winnerToLoserMap.keySet());
        allIds.addAll(winnerToLoserMap.values());
        accountTestHelper.cacheAccounts(allIds);

        loserToWinnerMap = new Map<Id,Id>();
        List<Id> accIds = new List<Id>();
        Id addrId = null;
        Set<Id> winnerAccIds = new Set<Id>();
        Set<Id> winnerAddrIds = new Set<Id>();
        Map<Id,Id> accToAddrId = new Map<Id,Id>();

        for(Id winnerId : winnerToLoserMap.keySet()) {
            String objName = winnerId.getSObjectType().getDescribe().getName();
            Id loserId = winnerToLoserMap.get(winnerId);

            if(accountMergeMode && objName == 'Account') {
                winnerAccIds.add(winnerId);
                loserToWinnerMap.put(loserId, winnerId);

            } else if (addrMergeMode && objName == 'Address_vod__c') {
                winnerAddrIds.add(winnerId);
                loserToWinnerMap.put(loserId, winnerId);

                accToAddrId.put(accountTestHelper.addressCache.get(loserId).Account_vod__c, loserId);
            }

            if(objName == 'Account') {
                accIds.add(accountMergeMode ? loserId : winnerId);
            }
        }


        intCreateCall(false,false, US_REGION_CODE, accType, accIds, accToAddrId.get(accIds[0]));

        Test.startTest();

        if(accountMergeMode) {
            mergeTestHelper.executeMerge(accType, winnerAccIds);
            System.assertEquals(0,[SELECT Id FROM Account WHERE Id IN :loserToWinnerMap.keySet()].size(),'Loser Accounts should be deleted');
        }

        if(addrMergeMode) {
            mergeTestHelper.executeMerge(null, winnerAddrIds);
            System.assertEquals(0,[SELECT Id FROM Address_vod__c WHERE Id IN :loserToWinnerMap.keySet()].size(),'Loser Addresses should be deleted');
        }

        intUpdateCall(false, true, true, US_REGION_CODE, accType);

        Test.stopTest();
    }

    public static void initEnv() {
        initEnv(true,true,true,true,true,true,true);
    }

    public static void initEnv(Boolean prepareAll) {
        initEnv(prepareAll,prepareAll,prepareAll,prepareAll,prepareAll,prepareAll,prepareAll);
    }

    public static void initEnv(Boolean initMergeHelper, Boolean prepareUsers, Boolean cacheRecordTypes, Boolean inserAccounts,
            Boolean prepareDetailProds, Boolean prepareSampleProds, Boolean preparePfg) {
        if(requestIdIdx==null) {
            requestIdIdx = 0;
            isOtrRequest = true;

            insert new List<GNE_SFA2_User_Notification_Email__c>{
                new GNE_SFA2_User_Notification_Email__c(Name = 'iPhoneApexNotifications:1', Email__c = 'osowiecb@contractors.roche.com')
            };

            accountTestHelper = new AccountTestHelper();
            mergeTestHelper = new MergeTestHelper();

            if(initMergeHelper) {
                mergeTestHelper.init();
            }

            if(prepareUsers) {
                cacheUsers();
            }

            if(cacheRecordTypes) {
                cacheRecordTypes();
            }

            if(inserAccounts) {
                accountTestHelper.insertAccountsWithAddresses(3);
            }

            List<Product_vod__c> prodsToInsert = new List<Product_vod__c>();

            if(prepareDetailProds) {
                prepareDetailProducts(prodsToInsert);
                insert prodsToInsert;
            }

            prodsToInsert = new List<Product_vod__c>();

            if(prepareSampleProds) {
                prepareSampleProducts(prodsToInsert);
            }

            if(preparePfg) {
                preparePfgProducts(prodsToInsert);
            }

            if(!prodsToInsert.isEmpty()) {
                insert prodsToInsert;
            }
        }
    }

    private static void cacheUsers() {
        for(Profile p : [SELECT Name,
                            (SELECT Id, Name, Alias FROM Users WHERE IsActive = true LIMIT 1)
                         FROM Profile
                         WHERE Name IN (:CANADA_PROFILE_NAME, :US_PROFILE_NAME)]) {
            if(p.Name == US_PROFILE_NAME && !p.Users.isEmpty()) {
                usOwner = p.Users[0];
            } else if(p.Name == CANADA_PROFILE_NAME && !p.Users.isEmpty()) {
                canOwner = p.Users[0];
            }
        }
    }

    private static void cacheRecordTypes() {
        accRecTypesCache = new Map<String,Id>();
        List<Schema.RecordTypeInfo> rtInfos = Account.getSobjectType().getDescribe().getRecordTypeInfos();

        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            Id rtId = rtInfo.getRecordTypeId();
            String rtName = rtInfo.getName();
            if(rtName == US_HCP_RECORD_TYPE_NAME) {
                accRecTypesCache.put('US_HCP', rtId);
            } else if(rtName == US_HCO_RECORD_TYPE_NAME) {
                accRecTypesCache.put('US_HCO', rtId);
            } else if(rtName == CAN_HCP_RECORD_TYPE_NAME) {
                accRecTypesCache.put('CAN_HCP', rtId);
            } else if(rtName == CAN_HCO_RECORD_TYPE_NAME) {
                accRecTypesCache.put('CAN_HCO', rtId);
            }
        }

        addrRecTypesCache = new Map<String,Id>();
        rtInfos = Address_vod__c.getSobjectType().getDescribe().getRecordTypeInfos();

        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            Id rtId = rtInfo.getRecordTypeId();
            String rtName = rtInfo.getName();
            if(rtName == US_ADDRESS_RECORD_TYPE_NAME) {
                addrRecTypesCache.put('US_HCP', rtId);
                addrRecTypesCache.put('US_HCO', rtId);
            } else if(rtName == CAN_HCP_ADDRESS_RECORD_TYPE_NAME) {
                addrRecTypesCache.put('CAN_HCP', rtId);
            } else if(rtName == CAN_HCO_ADDRESS_RECORD_TYPE_NAME) {
                addrRecTypesCache.put('CAN_HCO', rtId);
            }
        }
    }


    public static iPhoneApex_2.CallAttributes createCallAttributes(Account acc,
            Id ownerId, DateTime callDateTime, Boolean isComplete, String interactionType, iPhoneApex_2.AttendeeType callAttendeeType, String territoryName,
            List<Account> atts, List<Product_vod__c> details, List<Product_vod__c> sampleProds, List<Product_vod__c> pfgProds) {

        return createCallAttributes(null, acc, null,
            ownerId, callDateTime, isComplete, interactionType, callAttendeeType, territoryName,
            atts, details, sampleProds, pfgProds);
    }

    public static iPhoneApex_2.CallAttributes createCallAttributes(Call2_vod__c call,
            DateTime callDateTime, Boolean isComplete, String interactionType, iPhoneApex_2.AttendeeType callAttendeeType, String territoryName,
            List<Account> atts, List<Product_vod__c> details, List<Product_vod__c> sampleProds, List<Product_vod__c> pfgProds) {

        return createCallAttributes(call, null, null,
            null, callDateTime, isComplete, interactionType, callAttendeeType, territoryName,
            atts, details, sampleProds, pfgProds);
    }

    public static iPhoneApex_2.CallAttributes createCallAttributes(Call2_vod__c call, Account acc, Address_vod__c addr,
            Id ownerId, DateTime callDateTime, Boolean isComplete, String interactionType, iPhoneApex_2.AttendeeType callAttendeeType, String territoryName,
            List<Account> atts, List<Product_vod__c> details, List<Product_vod__c> sampleProds, List<Product_vod__c> pfgProds) {
        callAttributesCache = new Map<String,Object>();
        addr = addr!=null ? addr : (acc!=null ? acc.Address_vod__r[0] : call.Parent_Address_vod__r);
        acc = acc!=null ? acc : call.Account_vod__r;

        iPhoneApex_2.CallAttributes result = new iPhoneApex_2.CallAttributes();
        result.Id = call!=null ? call.Id : null;
        result.RequestId = call!=null ? call.iPhone_Request_Id_gne__c : getRequestId();
        result.OwnerId = ownerId!=null ? ownerId : (call!=null ? call.OwnerId : UserInfo.getUserId());
        result.Account = acc.Id;
        result.Address = addr.Id;
        result.AddressText = GNE_SFA2_Util.getAddressAsString(addr);
        result.CallDateTime = callDateTime!=null ? callDateTime : (call!=null ? call.Call_Datetime_vod__c : System.now());
        result.IsComplete = isComplete!=null ? isComplete : (call!=null ? call.Completed_Gne__c : false);
        result.isOtrRequest = isOtrRequest!=false;
        result.InteractionType = interactionType!=null ? interactionType : (call!=null ? call.Interaction_Type_gne__c : 'Account Call');
        result.CallAttendeeType = callAttendeeType!=null
                ? callAttendeeType
                : (acc.IsPersonAccount ? iPhoneApex_2.AttendeeType.PERSONACCOUNT : iPhoneApex_2.AttendeeType.ACCOUNT);
        result.TerritoryName = territoryName!=null ? territoryName : (call!=null ? call.Territory_vod__c : getUserTerrritoryName(UserInfo.getUserId()));
        result.SalesCollateral = COLLATERAL_VALUE;
        result.callAttendeeList = new List<iPhoneApex_2.CallAttendee>();

        List<Account> allAccs = new List<Account>{acc};

        if(atts!=null) {
            for(Account att : atts) {
                allAccs.add(att);
                iPhoneApex_2.CallAttendee attAttr = createCallAttendeeAttribute(att);
                result.callAttendeeList.add(attAttr);
                callAttributesCache.put(attAttr.RequestId, attAttr);
            }
        } else if(call!=null) {
            for(Call2_vod__c callAtts : call.Call2_vod__r) {
                allAccs.add(callAtts.Account_vod__r);
                iPhoneApex_2.CallAttendee attAttr = createCallAttendeeAttribute(callAtts);
                result.callAttendeeList.add(attAttr);
                callAttributesCache.put(attAttr.RequestId, attAttr);
            }
        }

        result.callDetailList = new List<iPhoneApex_2.CallDetail>();

        if(details!=null) {
            for(Product_vod__c dProd : details) {
                iPhoneApex_2.CallDetail detailAttr = createCallDetailAttribute(dProd);
                result.callDetailList.add(detailAttr);
                callAttributesCache.put(detailAttr.RequestId, detailAttr);
            }
        } else if(call!=null) {
            for(Call2_Detail_vod__c cDetail : call.Call2_Detail_vod__r) {
                iPhoneApex_2.CallDetail detailAttr = createCallDetailAttribute(cDetail);
                result.callDetailList.add(detailAttr);
                callAttributesCache.put(detailAttr.RequestId, detailAttr);
            }
        }

        if(!result.callDetailList.isEmpty() && result.IsComplete==true) {
            result.RequestSignature = REQUEST_SIGNATURE_VALUE;
            result.RequestSignatureDate = System.now();
        }

        result.callDiscussionList = new List<iPhoneApex_2.CallDiscussion>();

        if(call!=null) {
            for(Call2_Discussion_vod__c cDiscussion : call.Call2_Discussion_vod__r) {
                iPhoneApex_2.CallDiscussion discAttr = createCallDiscussionAttribute(cDiscussion);
                result.callDiscussionList.add(discAttr);
                callAttributesCache.put(discAttr.RequestId, discAttr);
            }
        }

        result.callSampleList = new List<iPhoneApex_2.CallSample>();

        if(sampleProds!=null) {
            Integer idx = 0;
            for(Product_vod__c sampleProd : sampleProds) {
                Account sampleAcc = allAccs[Math.mod(idx++,allAccs.size())];
                iPhoneApex_2.CallSample sampleAttr = createCallSampleAttribute(sampleAcc, sampleProd);
                result.callSampleList.add(sampleAttr);
                callAttributesCache.put(sampleAttr.RequestId, sampleAttr);
            }
        } else if(call!=null && callSampleCache!=null) {
            for(Call2_Sample_vod__c cSample : callSampleCache.values()) {
                iPhoneApex_2.CallSample sampleAttr = createCallSampleAttribute(cSample);
                result.callSampleList.add(sampleAttr);
                callAttributesCache.put(sampleAttr.RequestId, sampleAttr);
            }
        }

        result.callPfgDetailList = new List<iPhoneApex_2.CallPfgDetail>();

        if(pfgProds!=null) {
            for(Product_vod__c pfgProd : pfgProds) {
                Account pfgAcc = acc;
                iPhoneApex_2.CallPfgDetail pfgDetailAttr = createCallPfgDetailAttribute(pfgAcc, pfgProd);
                result.callPfgDetailList.add(pfgDetailAttr);
                callAttributesCache.put(pfgDetailAttr.RequestId, pfgDetailAttr);
            }
        } else if(call!=null) {
            for(Call_PFG_Detail_gne__c cPfgDetail : call.Call_PFG_Details__r) {
                iPhoneApex_2.CallPfgDetail pfgDetailAttr = createCallPfgDetailAttribute(cPfgDetail);
                result.callPfgDetailList.add(pfgDetailAttr);
                callAttributesCache.put(pfgDetailAttr.RequestId, pfgDetailAttr);
            }
        }

        callAttributesCache.put(result.RequestId, result);
        return result;
    }

    private static String getUserTerrritoryName(Id userId) {
        return null;
    }

    private static String getRequestId() {
        if(requestIdIdx==null) {
            requestIdIdx = 0;
        }

        return 'test_request_id' + (requestIdIdx++);
    }

    private static iPhoneApex_2.CallAttendee createCallAttendeeAttribute(Call2_vod__c att) {
        iPhoneApex_2.CallAttendee cAttendeeAttr = createCallAttendeeAttribute(att.Account_vod__r);
        cAttendeeAttr.RequestId = String.isNotBlank(att.iPhone_Request_Id_gne__c) ? att.iPhone_Request_Id_gne__c : cAttendeeAttr.RequestId;
        cAttendeeAttr.MealOptOut = att.HCP_Attendee_Meal_Opt_Out_gne__c;
        cAttendeeAttr.Id = att.Id;
        return cAttendeeAttr;
    }

    private static iPhoneApex_2.CallAttendee createCallAttendeeAttribute(Account acc) {
        iPhoneApex_2.CallAttendee cAttendeeAttr = new iPhoneApex_2.CallAttendee();
        cAttendeeAttr.Attendee = acc.Id;
        cAttendeeAttr.CallAttendeeType = acc.isPersonAccount ? iPhoneApex_2.AttendeeType.PERSONACCOUNT : iPhoneApex_2.AttendeeType.ACCOUNT;
        cAttendeeAttr.RequestId = getRequestId();
        return cAttendeeAttr;
    }

    private static iPhoneApex_2.CallDetail createCallDetailAttribute(Call2_Detail_vod__c cDetail) {
        iPhoneApex_2.CallDetail cDetailAttr = createCallDetailAttribute(new Product_vod__c(Id = cDetail.Product_vod__c));
        cDetailAttr.DetailPriority = String.valueOf(cDetail.Detail_Priority_vod__c);
        cDetailAttr.RequestId = String.isNotBlank(cDetail.iPhone_Request_Id_gne__c) ? cDetail.iPhone_Request_Id_gne__c : cDetailAttr.RequestId;
        cDetailAttr.TherapeuticArea = cDetail.Therapeutic_Area_gne__c;
        cDetailAttr.DiseaseIndication = cDetail.Indication_gne__c;
        cDetailAttr.Id = cDetail.Id;
        return cDetailAttr;
    }

    private static iPhoneApex_2.CallDetail createCallDetailAttribute(Product_vod__c dProduct) {
        iPhoneApex_2.CallDetail cDetailAttr = new iPhoneApex_2.CallDetail();
        cDetailAttr.Product = dProduct.Id;
        cDetailAttr.DetailPriority = '1';
        cDetailAttr.RequestId = getRequestId();
        return cDetailAttr;
    }

    private static iPhoneApex_2.CallDiscussion createCallDiscussionAttribute(Call2_Discussion_vod__c cDiscussion) {
        iPhoneApex_2.CallDiscussion cDiscussionAttr = new iPhoneApex_2.CallDiscussion();
        cDiscussionAttr.Product = cDiscussion.Product_vod__c;
        cDiscussionAttr.ProductStrategy = cDiscussion.Product_Strategy_vod__c;
        //cDiscussionAttr.ProductTactic = cDiscussion.Product_Tactic_vod__c;
        cDiscussionAttr.Reaction = cDiscussion.Reaction_gne__c;
        cDiscussionAttr.RequestId = cDiscussion.iPhone_Request_Id_gne__c;
        cDiscussionAttr.NbrPatientsImpacted = cDiscussion.Number_of_Patients_Impacted_gne__c!=null ? cDiscussion.Number_of_Patients_Impacted_gne__c.intValue() : null;
        cDiscussionAttr.AccountTactic = cDiscussion.Account_Tactic_vod__c;
        cDiscussionAttr.Curriculum = cDiscussion.Event_Curriculum_gne__c;
        cDiscussionAttr.Activity = cDiscussion.Activity_gne__c;
        cDiscussionAttr.EventRelated = cDiscussion.Event_gne__c;
        cDiscussionAttr.DetailPriority = cDiscussion.Detail_Priority_gne__c!=null ? String.valueOf(cDiscussion.Detail_Priority_gne__c) : '';
        cDiscussionAttr.ActivityTimeSpent = cDiscussion.Activity_Time_Spent_gne__c;

        cDiscussionAttr.Answer = cDiscussion.Answer_gne__c;
        cDiscussionAttr.Question = cDiscussion.Question_gne__c;
        cDiscussionAttr.Topic = cDiscussion.Topic_gne__c;
        cDiscussionAttr.CurrentIssue = cDiscussion.Current_Issue_gne__c;
        //cDiscussionAttr.Molecule = cDiscussion.Molecule_gne__c;
        cDiscussionAttr.Id = cDiscussion.Id;
        return cDiscussionAttr;
    }

    private static iPhoneApex_2.CallSample createCallSampleAttribute(Account acc, Product_vod__c sProd) {
        iPhoneApex_2.CallSample cSampleAttr = new iPhoneApex_2.CallSample();
        cSampleAttr.Account = acc.Id;
        cSampleAttr.Product = sProd.Id;
        cSampleAttr.Quantity = 1;
        cSampleAttr.RequestId = getRequestId();
        //cSampleAttr.LotNo = null;
        return cSampleAttr;
    }

    private static iPhoneApex_2.CallSample createCallSampleAttribute(Call2_Sample_vod__c cSample) {
        iPhoneApex_2.CallSample cSampleAttr = new iPhoneApex_2.CallSample();
        cSampleAttr.Account = cSample.Account_vod__c;
        cSampleAttr.Product = cSample.Product_vod__c;
        cSampleAttr.Quantity = cSample.Quantity_vod__c;
        cSampleAttr.RequestId = cSample.iPhone_Request_Id_gne__c;
        cSampleAttr.LotNo = cSample.Lot_vod__c;
        cSampleAttr.Id = cSample.Id;
        return cSampleAttr;
    }

    private static iPhoneApex_2.CallPfgDetail createCallPfgDetailAttribute(Account acc, Product_vod__c pfgProd) {
        iPhoneApex_2.CallPfgDetail cPfgDetailAttr = new iPhoneApex_2.CallPfgDetail();
        cPfgDetailAttr.Account = acc.Id;
        cPfgDetailAttr.cDate = System.today();
        cPfgDetailAttr.DistributionMethod = 'DTP';
        cPfgDetailAttr.LotNo = null;
        cPfgDetailAttr.Product = pfgProd.Id;
        cPfgDetailAttr.Quantity = 1;
        cPfgDetailAttr.RequestId = getRequestId();
        return cPfgDetailAttr;
    }

    private static iPhoneApex_2.CallPfgDetail createCallPfgDetailAttribute(Call_PFG_Detail_gne__c cPfgDetail) {
        iPhoneApex_2.CallPfgDetail cPfgDetailAttr = new iPhoneApex_2.CallPfgDetail();
        cPfgDetailAttr.Account = cPfgDetail.Account_gne__c;
        cPfgDetailAttr.cDate = cPfgDetail.Date_gne__c;
        cPfgDetailAttr.DistributionMethod = cPfgDetail.Distribution_Method_gne__c;
        cPfgDetailAttr.LotNo = cPfgDetail.Lot_No_gne__c;
        cPfgDetailAttr.Product = cPfgDetail.Product_gne__c;
        cPfgDetailAttr.Quantity = cPfgDetail.Quantity_gne__c!=null ? cPfgDetail.Quantity_gne__c.intValue() : null;
        cPfgDetailAttr.RequestId = cPfgDetail.iPhone_Request_Id_gne__c;
        return cPfgDetailAttr;
    }



    private static void prepareDetailProducts(List<Product_vod__c> prodsToInsert) {
        Map<String,Set<String>> productByRegionMap = new Map<String,Set<String>>{
            US_REGION_CODE => new Set<String>{'Nutropin', 'Actemra'},
            CANADA_REGION_CODE => new Set<String>{'Avastin', 'Xeloda'}
        };

        detailProductsCache = new Map<String,List<Product_vod__c>>();

        for(String regionCode : productByRegionMap.keySet()) {
            detailProductsCache.put(regionCode,new List<Product_vod__c>());

            for(String prodName : productByRegionMap.get(regionCode)) {
                Product_vod__c prod = new Product_vod__c(
                    Name = prodName,
                    Product_Type_vod__c = 'Detail',
                    Company_Product_vod__c = true,
                    OwnerId = (regionCode == US_REGION_CODE ? usOwner.Id : canOwner.Id));
                prodsToInsert.add(prod);
                detailProductsCache.get(regionCode).add(prod);
            }
        }
    }

    private static void prepareSampleProducts(List<Product_vod__c> prodsToInsert) {
        Map<String,Set<String>> productByRegionMap = new Map<String,Set<String>>{
            US_REGION_CODE => new Set<String>{'Nutropin Sample 1', 'Nutopin Sample 1'},
            CANADA_REGION_CODE => new Set<String>{'Avastin Sample 1', 'Avastin Sample 1'}
        };

        sampleProductsCache = new Map<String,List<Product_vod__c>>();

        for(String regionCode : productByRegionMap.keySet()) {
            sampleProductsCache.put(regionCode,new List<Product_vod__c>());
            Product_vod__c parentProd = detailProductsCache.get(regionCode)[0];

            for(String prodName : productByRegionMap.get(regionCode)) {
                Product_vod__c prod = new Product_vod__c(
                    Parent_Product_vod__c = parentProd.Id,
                    Name = prodName,
                    Product_Type_vod__c = 'Sample',
                    Company_Product_vod__c = true,
                    OwnerId = (regionCode == US_REGION_CODE ? usOwner.Id : canOwner.Id));
                prodsToInsert.add(prod);
                sampleProductsCache.get(regionCode).add(prod);
            }
        }
    }

    private static void preparePfgProducts(List<Product_vod__c> prodsToInsert) {
        Map<String,Set<String>> productByRegionMap = new Map<String,Set<String>>{
            US_REGION_CODE => new Set<String>{'Nutropin PFG 1', 'Nutopin PFG 1'}
        };

        pfgProductsCache = new Map<String,List<Product_vod__c>>();

        for(String regionCode : productByRegionMap.keySet()) {
            pfgProductsCache.put(regionCode,new List<Product_vod__c>());
            Product_vod__c parentProd = detailProductsCache.get(regionCode)[0];

            for(String prodName : productByRegionMap.get(regionCode)) {
                Product_vod__c prod = new Product_vod__c(
                    Parent_Product_vod__c = parentProd.Id,
                    Name = prodName,
                    Product_Type_vod__c = 'PFG',
                    Company_Product_vod__c = true,
                    OwnerId = (regionCode == US_REGION_CODE ? usOwner.Id : canOwner.Id));
                prodsToInsert.add(prod);
                pfgProductsCache.get(regionCode).add(prod);
            }
        }
    }

    public static void copyIdsFromResponseToAttrs(iPhoneApex_2.Response wsResult, iPhoneApex_2.CallAttributes cAttrs) {
        if(wsResult.RequestIdResponseIdList!=null) {
            for(iPhoneApex_2.RequestIdResponseIdMap reqResMap : wsResult.RequestIdResponseIdList) {
                if(reqResMap.RequestId == cAttrs.RequestId) {
                    cAttrs.Id = reqResMap.ResponseId;
                } else if(callAttributesCache.containsKey(reqResMap.RequestId)) {
                    Object attrObj = callAttributesCache.get(reqResMap.RequestId);

                    if(attrObj instanceOf iPhoneApex_2.CallAttendee) {
                        ((iPhoneApex_2.CallAttendee)attrObj).Id = reqResMap.ResponseId;
                    } else if(attrObj instanceOf iPhoneApex_2.CallDetail) {
                        ((iPhoneApex_2.CallDetail)attrObj).Id = reqResMap.ResponseId;
                    } else if(attrObj instanceOf iPhoneApex_2.CallDiscussion) {
                        ((iPhoneApex_2.CallDiscussion)attrObj).Id = reqResMap.ResponseId;
                    } else if(attrObj instanceOf iPhoneApex_2.CallSample) {
                        ((iPhoneApex_2.CallSample)attrObj).Id = reqResMap.ResponseId;
                    }
                }
            }
        }
    }

    private static void cacheCall(String iPhoneRequestId) {
        callsCache = new Map<Id,Call2_vod__c>();
        callSampleCache = new Map<Id,Call2_Sample_vod__c>();

        for(Call2_vod__c call :
        [
            SELECT iPhone_Request_Id_gne__c, Name, Parent_Call_vod__c,
                Account_vod__c, Account_vod__r.Id, Account_vod__r.IsPersonAccount,
                Call_Datetime_vod__c, OwnerId, Completed_gne__c, Interaction_Status_gne__c, Date_Completed_gne__c, Call_Type_vod__c, Status_vod__c,
                Parent_Address_vod__c, Address_vod__c, Address_Line_1_vod__c, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c,
                Parent_Address_vod__r.Name, Parent_Address_vod__r.Address_Line_2_vod__c, Parent_Address_vod__r.City_vod__c,
                Parent_Address_vod__r.State_vod__c, Parent_Address_vod__r.Zip_vod__c, Parent_Address_vod__r.Zip_4_vod__c,
                Parent_Address_vod__r.Province_can_gne__c, Parent_Address_vod__r.Postal_Code_can_gne__c,
                Detailed_Products_vod__c, Last_Device_vod__c, HCP_Account_Meal_Opt_Out_gne__c,
                Territory_vod__c, Interaction_Type_gne__c,
                (SELECT Id, iPhone_Request_Id_gne__c, Account_vod__c, Attendee_Type_vod__c, HCP_Attendee_Meal_Opt_Out_gne__c,
                    Account_vod__r.Id, Account_vod__r.IsPersonAccount,
                    Address_vod__c, Parent_Address_vod__c, Address_Line_1_vod__c, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c,
                    Parent_Address_vod__r.Name, Parent_Address_vod__r.Address_Line_2_vod__c, Parent_Address_vod__r.City_vod__c,
                    Parent_Address_vod__r.State_vod__c, Parent_Address_vod__r.Zip_vod__c,
                    Detailed_Products_vod__c, Business_sponsor_gne__c, City_gne__c, State_gne__c, Meal_Amount_gne__c, Interaction_Location_gne__c,
                    Account_Plan_vod__c, Territory_vod__c, Last_Device_vod__c,
                    Completed_gne__c, Call_Datetime_vod__c, OwnerId, Interaction_Status_gne__c,
                    Date_Completed_gne__c, call_type_vod__c, Status_vod__c
                 FROM Call2_vod__r),
                (SELECT Id, iPhone_Request_Id_gne__c, Product_vod__c, Detail_Priority_vod__c, Therapeutic_Area_gne__c, Indication_gne__c
                 FROM Call2_Detail_vod__r),
                (SELECT Id, iPhone_Request_Id_gne__c, Product_vod__c, Account_vod__c, Detail_Priority_gne__c, Product_Strategy_vod__c, Product_Tactic_vod__c, Account_Tactic_vod__c,
                    Reaction_gne__c, Number_of_Patients_Impacted_gne__c, Event_Curriculum_gne__c, Activity_gne__c, Event_gne__c, Activity_Time_Spent_gne__c,
                    Answer_gne__c, Question_gne__c, Topic_gne__c
                 FROM Call2_Discussion_vod__r),
                (SELECT Id, iPhone_Request_Id_gne__c, Call2_vod__c, Product_vod__c, Account_vod__c, Call_Date_vod__c, Quantity_vod__c, Lot_vod__c
                 FROM Call2_Sample_vod__r),
                (SELECT Id, iPhone_Request_Id_gne__c, Account_gne__c, Distribution_Method_gne__c, Lot_No_gne__c, Product_gne__c, Quantity_gne__c, Date_gne__c
                 FROM Call_PFG_Details__r),
                (SELECT id FROM Call2_Key_Message_vod__r)
            FROM Call2_vod__c
            WHERE   (Parent_Call_vod__c = null AND iPhone_Request_Id_gne__c = :iPhoneRequestId)
                OR (Parent_Call_vod__r.iPhone_Request_Id_gne__c = :iPhoneRequestId)
        ]) {
            if(call.Parent_Call_vod__c == null) {
                callsCache.put(call.Id, call);
            }

            for(Call2_Sample_vod__c cSample : call.Call2_Sample_vod__r) {
                callSampleCache.put(cSample.id,cSample);
            }
        }


    }

    private static void assertWsResponse(iPhoneApex_2.Response wsResult, iPhoneApex_2.CallAttributes cAttrs, Boolean success) {
        System.assertEquals(String.isBlank(wsResult.ErrorCode), success, 'iPhone Request should ' + (success ? 'Succeed' : 'Fail'));
        System.assertEquals(String.isBlank(wsResult.ErrorMessage), success, 'iPhone Request should ' + (success ? 'Succeed' : 'Fail'));

        if(wsResult.RequestIdResponseIdList!=null) {
            for(iPhoneApex_2.RequestIdResponseIdMap reqResMap : wsResult.RequestIdResponseIdList) {
                System.assert(callAttributesCache.containsKey(reqResMap.RequestId),
                    'No matching Call Attribute Element for RequestId = ' + reqResMap.RequestId + ', ObjectType = ' + reqResMap.ObjectType);
            }
        }
    }

    private static void assertWsResponse(iPhoneApex_2.Response wsResult, iPhoneApex_2.CallAttributes cAttrs, String errorMsg) {
        assertWsResponse(wsResult, cAttrs, false);
        System.assert(wsResult.ErrorMessage!=null && wsResult.ErrorMessage.contains(errorMsg),
            'iPhone Response Error Message should contains \'' + errorMsg + '\'');
    }

    private static void assertCall(iPhoneApex_2.CallAttributes cAttrs) {
        System.assertEquals(1, callsCache.size(), 'There should be only one call with iPhone Request Id ' + cAttrs.RequestId);

        Call2_vod__c call = callsCache.values()[0];

        assertParentCall(call, cAttrs);

        Set<String> notVisitedRequestIds = new Set<String>(callAttributesCache.keySet());
        notVisitedRequestIds.remove(cAttrs.RequestId);

        for(Call2_vod__c cAtt : call.Call2_vod__r) {
            notVisitedRequestIds.remove(cAtt.iPhone_Request_Id_gne__c);
            assertCallAttendee(cAtt, (iPhoneApex_2.CallAttendee)callAttributesCache.get(cAtt.iPhone_Request_Id_gne__c), cAttrs);
        }

        for(Call2_Detail_vod__c cDetail : call.Call2_Detail_vod__r) {
            notVisitedRequestIds.remove(cDetail.iPhone_Request_Id_gne__c);
            assertCallDetail(cDetail, (iPhoneApex_2.CallDetail)callAttributesCache.get(cDetail.iPhone_Request_Id_gne__c));
        }

        for(Call2_Discussion_vod__c cDiscussion : call.Call2_Discussion_vod__r) {
            notVisitedRequestIds.remove(cDiscussion.iPhone_Request_Id_gne__c);
            assertCallDiscussion(cDiscussion, (iPhoneApex_2.CallDiscussion)callAttributesCache.get(cDiscussion.iPhone_Request_Id_gne__c), cAttrs);
        }

        for(Call2_Sample_vod__c cSample : callSampleCache.values()) {
            notVisitedRequestIds.remove(cSample.iPhone_Request_Id_gne__c);
            assertCallSample(cSample, (iPhoneApex_2.CallSample)callAttributesCache.get(cSample.iPhone_Request_Id_gne__c), cAttrs);
        }

        for(Call_PFG_Detail_gne__c cPfgDetail : call.Call_PFG_Details__r) {
            notVisitedRequestIds.remove(cPfgDetail.iPhone_Request_Id_gne__c);
            assertCallPfgDetail(cPfgDetail, (iPhoneApex_2.CallPfgDetail)callAttributesCache.get(cPfgDetail.iPhone_Request_Id_gne__c));
        }

        for(String reqId : notVisitedRequestIds) {
            Object callAttrElement = callAttributesCache.get(reqId);
            System.assert(false,'Missing record for Request Id ' + reqId + ', ' + callAttrElement);
        }
    }

    private static void assertParentCall(Call2_vod__c call, iPhoneApex_2.CallAttributes cAttrs) {
        Id expectedAccountId = loserToWinnerMap!=null && loserToWinnerMap.containsKey(cAttrs.Account) ? loserToWinnerMap.get(cAttrs.Account) : (Id)cAttrs.Account;
        System.assertEquals(expectedAccountId, call.Account_vod__c, '[Parent Call] Different Account');

        System.assertEquals(cAttrs.CallDateTime, call.Call_Datetime_vod__c, '[Parent Call] Different CallDateTime');
        System.assertEquals(UserInfo.getUserId(), call.OwnerId, '[Parent Call] Different Owner');
        System.assertEquals(cAttrs.IsComplete, call.Completed_gne__c, '[Parent Call] Different IsComplete');

        if(cAttrs.IsComplete == true) {
            System.assertEquals('Completed', call.Interaction_Status_gne__c, '[Parent Call] Different Intraction Status');
            System.assertEquals(System.today(), call.Date_Completed_gne__c, '[Parent Call] Different Date Completed');
        }

        //System.assertEquals(???, call.Call_Type_vod__c, '[Parent Call] Different Call Type');
        System.assertEquals('Saved_vod', call.Status_vod__c, '[Parent Call] Different Status');
        Id expectedAddressId = loserToWinnerMap!=null && loserToWinnerMap.containsKey(cAttrs.Address) ? loserToWinnerMap.get(cAttrs.Address) : (Id)cAttrs.Address;
        System.assertEquals(expectedAddressId, call.Parent_Address_vod__c, '[Parent Call] Different Parent Address ID');
        System.assertEquals(cAttrs.AddressText, call.Address_vod__c, '[Parent Call] Different Address Text');
        System.assertEquals(call.Parent_Address_vod__r.Name, call.Address_Line_1_vod__c, '[Parent Call] Different Address Line 1');
        System.assertEquals(call.Parent_Address_vod__r.Address_Line_2_vod__c, call.Address_Line_2_vod__c, '[Parent Call] Different Address Line 2');
        System.assertEquals(call.Parent_Address_vod__r.City_vod__c, call.City_vod__c, '[Parent Call] Different City');
        System.assertEquals(call.Parent_Address_vod__r.State_vod__c, call.State_vod__c, '[Parent Call] Different State');
        System.assertEquals(call.Parent_Address_vod__r.Zip_vod__c, call.Zip_vod__c, '[Parent Call] Different Zip');
        //System.assertEquals(???, call.Detailed_Products_vod__c, '[Parent Call] Different Detailed Products');
        System.assertEquals('iPhone_gne', call.Last_Device_vod__c, '[Parent Call] Different Last Device');
        System.assertEquals(cAttrs.MealOptOut, call.HCP_Account_Meal_Opt_Out_gne__c, '[Parent Call] Different Meal Opt Out');
    }

    private static void assertCallAttendee(Call2_vod__c cAttendee, iPhoneApex_2.CallAttendee cAttAttr, iPhoneApex_2.CallAttributes cAttrs) {
        System.assertNotEquals(null, cAttAttr, '[Call Attendee] Record should not exists because there is no CallAttendee Attribute');

        String attendeeType = cAttAttr.CallAttendeeType == iPhoneApex_2.AttendeeType.ACCOUNT || cAttAttr.CallAttendeeType == iPhoneApex_2.AttendeeType.PERSONACCOUNT
                ? 'Person_Account_vod'
                : (cAttAttr.CallAttendeeType == iPhoneApex_2.AttendeeType.CONTACT
                    ? 'Contact_vod'
                    : (cAttAttr.CallAttendeeType == iPhoneApex_2.AttendeeType.USER ? 'User_vod' : null));
        Id expectedAccountId = loserToWinnerMap!=null && loserToWinnerMap.containsKey(cAttAttr.Attendee) ? loserToWinnerMap.get(cAttAttr.Attendee) : (Id)cAttAttr.Attendee;
        System.assertEquals(expectedAccountId, cAttendee.Account_vod__c, '[Call Attendee] Different Attendee ID');
        System.assertEquals(attendeeType, cAttendee.Attendee_Type_vod__c, '[Call Attendee] Different Call Attendee Type');
        System.assertEquals(cAttAttr.MealOptOut, cAttendee.HCP_Attendee_Meal_Opt_Out_gne__c, '[Call Attendee] Different Meal Opt Out');

        System.assertEquals(cAttrs.CallDateTime, cAttendee.Call_Datetime_vod__c, '[Call Attendee] Different CallDateTime');
        System.assertEquals(UserInfo.getUserId(), cAttendee.OwnerId, '[Call Attendee] Different Owner');
        System.assertEquals(cAttrs.IsComplete, cAttendee.Completed_gne__c, '[Call Attendee] Different IsComplete');

        if(cAttrs.IsComplete == true) {
            System.assertEquals('Completed', cAttendee.Interaction_Status_gne__c, '[Call Attendee] Different Intraction Status');
            System.assertEquals(System.today(), cAttendee.Date_Completed_gne__c, '[Call Attendee] Different Date Completed');
        }

        //System.assertEquals(???, cAttendee.Call_Type_vod__c, '[Call Attendee] Different Call Type');
        System.assertEquals('Saved_vod', cAttendee.Status_vod__c, '[Call Attendee] Different Status');
        Id expectedAddressId = loserToWinnerMap!=null && loserToWinnerMap.containsKey(cAttrs.Address) ? loserToWinnerMap.get(cAttrs.Address) : (Id)cAttrs.Address;
        System.assertEquals(expectedAddressId, cAttendee.Parent_Address_vod__c, '[Call Attendee] Different Parent Address ID');
        System.assertEquals(cAttrs.AddressText, cAttendee.Address_vod__c, '[Call Attendee] Different Address Text');
        System.assertEquals(cAttendee.Parent_Address_vod__r.Name, cAttendee.Address_Line_1_vod__c, '[Call Attendee] Different Address Line 1');
        System.assertEquals(cAttendee.Parent_Address_vod__r.Address_Line_2_vod__c, cAttendee.Address_Line_2_vod__c, '[Call Attendee] Different Address Line 2');
        System.assertEquals(cAttendee.Parent_Address_vod__r.City_vod__c, cAttendee.City_vod__c, '[Call Attendee] Different City');
        System.assertEquals(cAttendee.Parent_Address_vod__r.State_vod__c, cAttendee.State_vod__c, '[Call Attendee] Different State');
        System.assertEquals(cAttendee.Parent_Address_vod__r.Zip_vod__c, cAttendee.Zip_vod__c, '[Call Attendee] Different Zip');
        //System.assertEquals(???, cAttendee.Detailed_Products_vod__c, '[Call Attendee] Different Detailed Products');
        System.assertEquals('iPhone_gne', cAttendee.Last_Device_vod__c, '[Call Attendee] Different Last Device');
    }

    private static void assertCallDetail(Call2_Detail_vod__c cDetail, iPhoneApex_2.CallDetail cDetailAttr) {
        System.assertNotEquals(null, cDetailAttr, '[Call Detail] Record should not exists because there is no CallDetail Attribute');
        System.assertEquals(cDetailAttr.Product, cDetail.Product_vod__c, '[Call Detail] Different Product');
        System.assertEquals(Double.valueOf(cDetailAttr.DetailPriority), cDetail.Detail_Priority_vod__c, '[Call Detail] Different Detail Priority');
        System.assertEquals(cDetailAttr.TherapeuticArea, cDetail.Therapeutic_Area_gne__c, '[Call Detail] Different Therapeutic Area');
        System.assertEquals(cDetailAttr.DiseaseIndication, cDetail.Indication_gne__c, '[Call Detail] Different Disease Indication');
    }

    private static void assertCallDiscussion(Call2_Discussion_vod__c cDisc, iPhoneApex_2.CallDiscussion cDiscAttr, iPhoneApex_2.CallAttributes cAttrs) {
        System.assertNotEquals(null, cDiscAttr, '[Call Discussion] Record should not exists because there is no CallDiscussion Attribute');
        System.assertEquals(cDiscAttr.Product, cDisc.Product_vod__c, '[Call Discussion] Different Product');
        Id expectedAccountId = loserToWinnerMap!=null && loserToWinnerMap.containsKey(cAttrs.Account) ? loserToWinnerMap.get(cAttrs.Account) : (Id)cAttrs.Account;
        System.assertEquals(expectedAccountId, cDisc.Account_vod__c, '[Call Discussion] Different Account');
        System.assertEquals(Double.valueOf(cDiscAttr.DetailPriority), cDisc.Detail_Priority_gne__c, '[Call Discussion] Different Detail_Priority_gne__c');
        System.assertEquals(cDiscAttr.ProductStrategy, cDisc.Product_Strategy_vod__c, '[Call Discussion] Different ProductStrategy');
        System.assertEquals(cDiscAttr.ProductTactic, cDisc.Product_Tactic_vod__c, '[Call Discussion] Different ProductTactic');
        System.assertEquals(cDiscAttr.AccountTactic, cDisc.Account_Tactic_vod__c, '[Call Discussion] Different AccountTactic');
        System.assertEquals(cDiscAttr.Reaction, cDisc.Reaction_gne__c, '[Call Discussion] Different Reaction');
        System.assertEquals(cDiscAttr.NbrPatientsImpacted, cDisc.Number_of_Patients_Impacted_gne__c, '[Call Discussion] Different NbrPatientsImpacted');
        System.assertEquals(cDiscAttr.Curriculum, cDisc.Event_Curriculum_gne__c, '[Call Discussion] Different Curriculum');
        System.assertEquals(cDiscAttr.Activity, cDisc.Activity_gne__c, '[Call Discussion] Different Activity');
        System.assertEquals(cDiscAttr.EventRelated, cDisc.Event_gne__c, '[Call Discussion] Different EventRelated');
        System.assertEquals(cDiscAttr.ActivityTimeSpent, cDisc.Activity_Time_Spent_gne__c, '[Call Discussion] Different ActivityTimeSpent');
        System.assertEquals(cDiscAttr.Answer, cDisc.Answer_gne__c, '[Call Discussion] Different Answer');
        System.assertEquals(cDiscAttr.Question, cDisc.Question_gne__c, '[Call Discussion] Different Question');
        System.assertEquals(cDiscAttr.Topic, cDisc.Topic_gne__c, '[Call Discussion] Different Topic');

    }

    private static void assertCallSample(Call2_Sample_vod__c cSample, iPhoneApex_2.CallSample cSampleAttr, iPhoneApex_2.CallAttributes cAttrs) {
        System.assertNotEquals(null, cSampleAttr, '[Call Sample] Record should not exists because there is no CallSample Attribute');
        System.assertEquals(cSampleAttr.Product, cSample.Product_vod__c, '[Call Sample] Different Product');
        Id expectedAccountId = loserToWinnerMap!=null && loserToWinnerMap.containsKey(cSampleAttr.Account) ? loserToWinnerMap.get(cSampleAttr.Account) : (Id)cSampleAttr.Account;
        System.assertEquals(expectedAccountId, cSample.Account_vod__c, '[Call Sample] Different Account');
        System.assertEquals(cAttrs.CallDateTime.date(), cSample.Call_Date_vod__c, '[Call Sample] Different Call Date');
        System.assertEquals(cSampleAttr.Quantity, cSample.Quantity_vod__c, '[Call Sample] Different Quantity');
        System.assertEquals(cSampleAttr.LotNo, cSample.Lot_vod__c, '[Call Sample] Different Lot Number');
    }

    private static void assertCallPfgDetail(Call_PFG_Detail_gne__c cPfgDetail, iPhoneApex_2.CallPfgDetail cPfgDetailAttr) {
        System.assertNotEquals(null, cPfgDetailAttr, '[Call PFG Detail] Record should not exists because there is no CallPfgDetail Attribute.');
        Id expectedAccountId = loserToWinnerMap!=null && loserToWinnerMap.containsKey(cPfgDetailAttr.Account) ? loserToWinnerMap.get(cPfgDetailAttr.Account) : (Id)cPfgDetailAttr.Account;
        System.assertEquals(expectedAccountId, cPfgDetail.Account_gne__c, '[Call PFG Detail] Different Account');
        System.assertEquals(cPfgDetailAttr.DistributionMethod, cPfgDetail.Distribution_Method_gne__c, '[Call PFG Detail] Different Distribution Method');
        System.assertEquals(cPfgDetailAttr.LotNo, cPfgDetail.Lot_No_gne__c, '[Call PFG Detail] Different Lot Number');
        System.assertEquals(cPfgDetailAttr.Product, cPfgDetail.Product_gne__c, '[Call PFG Detail] Different Product');
        System.assertEquals(cPfgDetailAttr.Quantity, cPfgDetail.Quantity_gne__c.intValue(), '[Call PFG Detail] Different Quantity');
        System.assertEquals(cPfgDetailAttr.cDate, cPfgDetail.Date_gne__c, '[Call PFG Detail] Different Date');
    }

    private static void assertErrorLog(iPhoneApex_2.CallAttributes cAttrs, String errorMsg) {
        List<iPhone_API_Errors__c> errorLogs = [
            SELECT
                Details__c, Details_Exception__c, Exception_Type__c, Part_No__c,
                Request_Class__c, Request_Id__c, Request_Type__c, Stack_Trace__c, User__c, Application_Name__c
            FROM iPhone_API_Errors__c];

        System.assertEquals(1, errorLogs.size(), '[Error Log] There should be exactly one Error Log Record');

        for(iPhone_API_Errors__c errorLog : errorLogs) {
            System.assertEquals(iPhoneBase.serializeRequest(cAttrs), errorLog.Details__c, '[Error Log] Details is not valid');
            System.assert(errorLog.Details_Exception__c!=null && errorLog.Details_Exception__c.contains(errorMsg), '[Error Log] Detail Exception is not valid');
            System.assertNotEquals(null, errorLog.Exception_Type__c, '[Error Log] Exception Type is not set');
            System.assertEquals(1, errorLog.Part_No__c, '[Error Log] Part NO is not valid');
            System.assertEquals(iPhoneApex_2.CallAttributes.class.getName(), errorLog.Request_Class__c, '[Error Log] Request Class is not valid');
            System.assertEquals(cAttrs.RequestId, errorLog.Request_Id__c, '[Error Log] Request Id is not valid');
            System.assertNotEquals(null, errorLog.Stack_Trace__c, '[Error Log] Stack Trace is not set');
            System.assertEquals(cAttrs.isOtrRequest ? 'OTR' : null, errorLog.Application_Name__c, '[Error Log] Application Name is not valid');
        }
    }

    public class AccountTestHelper {

        private final String US_CODE = 'US';
        private final String CANADA_CODE = 'CAN';

        public Map<Id,Account> accountsCache;
        public Map<String,Set<Id>> accountsByTypeCache;
        public Map<Id,Address_vod__c> addressCache;

        public void insertAccountsWithAddresses(Integer numberOfAccts) {
            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);

            List<Account> accountsToInsert = new List<Account>();
            List<Address_vod__c> addressesToInsert = new List<Address_vod__c>();

            String hcpFirstName = 'JOHN', hcpLastName = 'SMITH', hcoName = 'MEDICAL CENTER';
            String addressName = 'TEST STREET', addressLine2 = 'STE', city = 'SAN FRANCISCO', state = 'CA', zip = '99999', zip4 = '1111';
            String canProvince = 'ON', canPostalCode = 'A1A 2B2';

            Integer idx = 0;
            for(String mode : new String[]{'US_HCP','US_HCO','CAN_HCP','CAN_HCO'}) {
                Id recTypeId = accRecTypesCache.get(mode);

                for(Integer i = 0; i < numberOfAccts; i++) {
                    idx++;
                    Account acc = new Account(
                        RecordTypeId = recTypeId,
                        OwnerId = (mode.startsWith(US_CODE) ? usOwner.Id : canOwner.Id ));

                    if(mode.endsWith('HCP')) {
                        acc.FirstName = hcpFirstName + idx;
                        acc.LastName = hcpLastName + idx;
                    } else {
                        acc.Name = hcoName;
                    }

                    accountsToInsert.add(acc);
                }
            }

            insert accountsToInsert;

            idx = 0;
            for(Account acc : accountsToInsert) {
                idx++;
                Id recTypeId = addrRecTypesCache.get(getAccountType(acc));

                Address_vod__c addr = new Address_vod__c(
                    RecordTypeId = recTypeId,
                    Account_vod__c = acc.Id,
                    Name = addressName + ' ' + idx,
                    Address_Line_2_vod__c = addressLine2 + ' ' + idx,
                    Primary_vod__c = true,
                    City_vod__c = city);

                if(acc.OwnerId == usOwner.Id) {
                    addr.State_vod__c = state;
                    addr.Zip_vod__c = zip;
                    addr.Zip_4_vod__c = zip4;
                } else {
                    addr.Province_can_gne__c = canProvince;
                    addr.Postal_Code_can_gne__c = canPostalCode;
                }

                addressesToInsert.add(addr);
            }

            insert addressesToInsert;

            cacheAccounts(new Map<Id,Account>(accountsToInsert).keySet());

            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
        }

        public void cacheAccounts(Set<Id> accIds) {
            List<Account> accs = [
                SELECT Id, Name, OwnerId, FirstName, LastName, IsPersonAccount, RecordTypeId, RecordType.Name,
                    (SELECT Id, Primary_vod__c, Account_vod__c, Name, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c
                     FROM Address_vod__r)
                FROM Account
                WHERE Id IN :accIds
            ];

            for(Account acc : accs) {
                cacheAccount(acc);

                for(Address_vod__c addr : acc.Address_vod__r) {
                    cacheAddress(addr);
                }
            }
        }

        public void cacheAccount(Account acc) {
            if(accountsCache==null) {
                accountsCache = new Map<Id,Account>();
                accountsByTypeCache = new Map<String,Set<Id>>{
                    'US_HCP' => new Set<Id>(),
                    'US_HCO' => new Set<Id>(),
                    'CAN_HCP' => new Set<Id>(),
                    'CAN_HCO' => new Set<Id>()
                };
            }

            accountsCache.put(acc.Id, acc);
            String accType = getAccountType(acc);
            accountsByTypeCache.get(accType).add(acc.Id);
        }

        public void cacheAddress(Address_vod__c addr) {
            if(addressCache==null) {
                addressCache = new Map<Id,Address_vod__c>();
            }

            addressCache.put(addr.Id, addr);
        }

        private String getAccountType(Account acc) {
            String region = acc.OwnerId == usOwner.Id ? US_CODE : CANADA_CODE;
            String accMode = acc.RecordTypeId == accRecTypesCache.get(region + '_HCP') ? 'HCP' : 'HCO';
            return region + '_' + accMode;
        }
    }

    public class MergeTestHelper {
        public User mergeRunnerUser;
        public final String MERGE_RUNNER_PROFILE = 'GNE-SYS-Support';

        public Map<Id,Id> createLoserAccountsWithPlaceholders(Set<Id> winnerIds) {
            return createLoserAccountsWithPlaceholders(winnerIds,true);
        }

        public Map<Id,Id> createLoserAccountsWithPlaceholders(Set<Id> winnerIds, Boolean isCreatePlaceholdersMode) {
            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);

            List<Account> winnerAccounts =
            [
                SELECT Id, Name, IsPersonAccount, FirstName, LastName, Account_Type_gne__c, RecordTypeId, OwnerId,
                (SELECT Id, Name, RecordTypeId, City_vod__c, Zip_vod__c, State_vod__c
                 FROM Address_vod__r WHERE Primary_vod__c = true LIMIT 1),
                (SELECT AccountAccessLevel, AccountId, CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel, RowCause, UserOrGroupId
                 FROM Shares WHERE RowCause IN ('Territory', 'TerritoryRule')),
                (SELECT Territory_vod__c, My_Target_vod__c, Address_vod__c, My_Tier_gne__c, My_Segment_gne__c
                 FROM TSF_vod__r WHERE My_Target_vod__c = true AND Address_vod__r.Primary_vod__c = true),
                (SELECT Products_vod__c
                 FROM Product_Metrics_vod__r)
                FROM Account
                WHERE ID IN :winnerIds
            ];

            List<RecordType> archivedRecTypes = [SELECT ID, IsPersonType FROM RecordType WHERE SObjectType = 'Account' AND Name like 'Archived%' ORDER BY IsPersonType asc];
            Id hcoArchRecordTypeId = archivedRecTypes[0].Id;
            Id hcpArchRecordTypeId = archivedRecTypes[1].Id;
            Id archAddrRecTypeId = [SELECT ID, IsPersonType FROM RecordType WHERE SObjectType = 'Address_vod__c' AND Name like 'Archived%' LIMIT 1].Id;

            Id archivedOwnerId = [SELECT Id FROM User WHERE Email = 'archivedUseruser@gene.com' LIMIT 1].Id;

            List<Account> loserAccountsToInsert = new List<Account>();
            List<Account> winnerAccountsToUpdate = new List<Account>();
            List<Address_vod__c> winnerAddressesToUpdate = new List<Address_vod__c>();
            List<Address_vod__c> loserAddressesToInsert = new List<Address_vod__c>();
            List<AccountShare> loserAccSharesToInsert = new List<AccountShare>();
            List<TSF_vod__c> loserTsfsToInsert = new List<TSF_vod__c>();
            List<Product_Metrics_vod__c> loserBrandAffsToInsert = new List<Product_Metrics_vod__c>();
            List<Account> placeholderAccountsToInsert = new List<Account>();
            List<Address_vod__c> placeholderAddressesToInsert = new List<Address_vod__c>();

            Map<Id,Id> winnerToLoserIds = new Map<Id,Id>();
            Map<Id,Id> accToAddrIds = new Map<Id,Id>();
            Map<Id,Address_vod__c> winnerToLoserAddrs = new Map<Id,Address_vod__c>();
            Map<Id,Account> winnerToPlchAccs = new Map<Id,Account>();

            for(Account wAcc : winnerAccounts) {
                loserAccountsToInsert.add(createLoserAccount(wAcc));
                wAcc.DCH_Approval_Status_gne__c = 'Default Approval';
                winnerAccountsToUpdate.add(wAcc);

                for(Address_vod__c wAddr : wAcc.Address_vod__r) {
                    wAddr.DCH_Approval_Status_gne__c = 'Default Approval';
                    winnerAddressesToUpdate.add(wAddr);
                }
            }

            insert loserAccountsToInsert;
            update winnerAccountsToUpdate;
            update winnerAddressesToUpdate;

            Integer idx = 0;
            for(Account wAcc : winnerAccounts) {
                Account lAcc = loserAccountsToInsert[idx++];
                winnerToLoserIds.put(wAcc.Id, lAcc.Id);

                if(isCreatePlaceholdersMode == true) {
                    Account wPchl = createPlaceholder(wAcc, wAcc, wAcc.isPersonAccount ? hcpArchRecordTypeId : hcoArchRecordTypeId, archivedOwnerId);
                    wPchl.DCH_Action_gne__c = 'Related List Logic';
                    winnerToPlchAccs.put(wAcc.Id, wPchl);
                    placeholderAccountsToInsert.add(wPchl);
                    placeholderAccountsToInsert.add(createPlaceholder(wAcc, wAcc, wAcc.isPersonAccount ? hcpArchRecordTypeId : hcoArchRecordTypeId, archivedOwnerId));
                    placeholderAccountsToInsert.add(createPlaceholder(lAcc, wAcc, wAcc.isPersonAccount ? hcpArchRecordTypeId : hcoArchRecordTypeId, archivedOwnerId));
                }

                for(Address_vod__c wAddr : wAcc.Address_vod__r) {
                    Address_vod__c lAddr = createLoserAddress(wAddr, wAcc);
                    winnerToLoserAddrs.put(wAddr.Id, lAddr);
                    loserAddressesToInsert.add(lAddr);
                    loserAddressesToInsert.add(createLoserAddress(wAddr, lAcc));

                }

                for(AccountShare wShare : wAcc.Shares) {
                    loserAccSharesToInsert.add(createAccShareAddress(wShare, lAcc));
                }

                for(Product_Metrics_vod__c wBrandAff : wAcc.Product_Metrics_vod__r) {
                    loserBrandAffsToInsert.add(createBrandAff(wBrandAff, lAcc));
                }
            }

            insert loserAddressesToInsert;

            if(isCreatePlaceholdersMode == true) {
                insert placeholderAccountsToInsert;

                for(Account wAcc : winnerAccounts) {
                    Account wPchl = winnerToPlchAccs.get(wAcc.Id);
                    for(Address_vod__c wAddr : wAcc.Address_vod__r) {
                        Address_vod__c lAddr = winnerToLoserAddrs.get(wAddr.Id);
                        winnerToLoserIds.put(wAddr.Id,lAddr.Id);
                        placeholderAddressesToInsert.add(createAddressPlaceholder(wAddr, wAddr, archAddrRecTypeId, wPchl));
                        placeholderAddressesToInsert.add(createAddressPlaceholder(lAddr, wAddr, archAddrRecTypeId, wPchl));
                    }
                }

                insert placeholderAddressesToInsert;
            }

            if(!loserAccSharesToInsert.isEmpty()) {
                insert loserAccSharesToInsert;
            }

            if(!loserBrandAffsToInsert.isEmpty()) {
                insert loserBrandAffsToInsert;
            }

            for(Address_vod__c lAddr : loserAddressesToInsert) {
                accToAddrIds.put(lAddr.Account_vod__c, lAddr.Id);
            }

            idx = 0;
            for(Account wAcc : winnerAccounts) {
                Account lAcc = loserAccountsToInsert[idx++];
                Id lAddrId = accToAddrIds.get(lAcc.Id);

                for(TSF_vod__c wTsf : wAcc.TSF_vod__r) {
                    loserTsfsToInsert.add(createTSF(wTsf, lAcc, new Address_vod__c(Id = lAddrId)));
                }
            }

            if(!loserTsfsToInsert.isEmpty()) {
                insert loserTsfsToInsert;
            }

            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);

            return winnerToLoserIds;
        }

        public void init() {
            mergeRunnerUser = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = :MERGE_RUNNER_PROFILE LIMIT 1];
            createMergeBusinessRules();
        }

        private void createMergeBusinessRules() {
            List<GNE_Merge_BusinessRules_gne__c> gneMergeList = new List<GNE_Merge_BusinessRules_gne__c>();
            gneMergeList.add(new GNE_Merge_BusinessRules_gne__c(
                object_name_gne__c = 'Account',
                field_applies_to_gne__c = 'Account;Person Account',
                field_type_gne__c = 'Sort By Columns',
                field_name_gne__c = 'MDMId_gne__c desc, createddate asc',
                //relatedlist_query_text_gne__c = null,
                //exception_code_gne__c = null,
                //log_exception_column_values_gne__c = null,
                active_gne__c = true
            ));

            gneMergeList.add(new GNE_Merge_BusinessRules_gne__c(
                object_name_gne__c = 'Address_vod__c',
                field_type_gne__c = 'Sort By Columns',
                field_name_gne__c = 'MDM_Address_id_gne__c desc, createddate asc',
                active_gne__c = true
            ));

            insert gneMergeList;
        }

        public void executeMerge(String mergeMode, Set<Id> winnerIds) {
            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);

            GNE_SFA2_Merge_Mode_gne__c mergeModeSetting = GNE_SFA2_Merge_Mode_gne__c.getInstance(UserInfo.getUserId());
            mergeModeSetting.GNE_SFA2_Is_Merge_Mode__c = true;
            upsert mergeModeSetting;

            Set<String> winnerIdsStringSet = new Set<String>();

            for(Id winnerId : winnerIds) {
                winnerIdsStringSet.add(winnerId);
            }

            System.runAs(mergeRunnerUser) {

                Database.Batchable<SObject> batch = mergeMode == 'HCP'
                    ? (Database.Batchable<SObject>)new GNE_Merge_Batch_PersonAccount(false,winnerIdsStringSet)
                    : (mergeMode == 'HCO'
                        ? (Database.Batchable<SObject>)new GNE_Merge_Batch_OrgAccount(false,winnerIdsStringSet)
                        : (Database.Batchable<SObject>)new GNE_Merge_Batch_Address(false,winnerIdsStringSet));

                Database.QueryLocator qLocator = (Database.QueryLocator)batch.start(null);

                // Variables needed to execute query returned by batch.start()
                Set<String> parentIdSet          = winnerIdsStringSet;
                String archivedRecordType    = 'Archived%';
                String actionType            = 'Default Logic';
                String mergeType             = mergeMode == 'HCP' ? 'Person Account' : (mergeMode == 'HCO' ? 'Account' : 'Address');
                String defaultApprovalStatus = 'Default Approval';
                String approvedStatus        = 'Approved';

                List<SObject> plchs = Database.query(qLocator.getQuery());
                System.assertEquals(winnerIds.size()*2, plchs.size(), 'Wrong number of Placeholders');

                for(SObject plch : plchs) {
                    batch.execute(null,new List<SObject>{plch});
                }

                batch.finish(null);
            }

            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
        }

        private Account createLoserAccount(Account wAcc) {
            Account lAcc = new Account(
                RecordTypeId = wAcc.RecordTypeId,
                OwnerId = wAcc.OwnerId,
                Account_Type_gne__c = wAcc.Account_Type_gne__c);
            String sufix = ' (Loser)';
            if(wAcc.isPersonAccount) {
                lAcc.FirstName = wAcc.FirstName;
                lAcc.LastName = wAcc.LastName + sufix;
            } else {
                lAcc.Name = wAcc.Name + sufix;
            }

            return lAcc;
        }

        private Address_vod__c createLoserAddress(Address_vod__c wAddr, Account lAcc) {
            String sufix = ' (Loser)';
            Address_vod__c lAddr = new Address_vod__c(
                    Account_vod__c = lAcc.Id,
                    Name = wAddr.Name + sufix,
                    City_vod__c = wAddr.City_vod__c,
                    State_vod__c = wAddr.State_vod__c,
                    Zip_vod__c = wAddr.Zip_vod__c
            );

            return lAddr;
        }

        private Account createPlaceholder(Account lAcc, Account wAcc, Id recTypeId, Id ownerId) {
            Account pchl = new Account(
                RecordTypeId = recTypeId,
                OwnerId = ownerId);

            if(wAcc.isPersonAccount) {
                pchl.FirstName = lAcc.FirstName;
                pchl.LastName = lAcc.LastName;
            } else {
                pchl.Name = lAcc.Name;
            }

            pchl.dch_previous_id_gne__c = lAcc.Id;
            pchl.dch_parent_id_gne__c = wAcc.Id;
            pchl.DCH_Action_gne__c = 'Default Logic';

            return pchl;
        }

        private Address_vod__c createAddressPlaceholder(Address_vod__c lAddr, Address_vod__c wAddr, Id recTypeId, Account pchlAcc) {
            Address_vod__c pchl = new Address_vod__c(
                RecordTypeId = recTypeId,
                Account_vod__c = pchlAcc.Id);
            pchl.Name = lAddr.Name;
            pchl.dch_previous_id_gne__c = lAddr.Id;
            pchl.dch_parent_id_gne__c = wAddr.Id;
            pchl.DCH_Action_gne__c = 'Default Logic';

            return pchl;
        }

        private AccountShare createAccShareAddress(AccountShare wShare, Account lAcc) {
            AccountShare lShare = wShare.clone();
            lShare.AccountId = lAcc.Id;
            return lShare;
        }

        private TSF_vod__c createTSF(TSF_vod__c wTsf, Account lAcc, Address_vod__c lAddr) {
            TSF_vod__c lTsf = wTsf.clone();
            lTsf.Account_vod__c = lAcc.Id;
            lTsf.Address_vod__c = lAddr.Id;
            lTsf.External_Id_vod__c = lAcc.Id + '__' + lTsf.Territory_vod__c;
            return lTsf;
        }

        private Product_Metrics_vod__c createBrandAff(Product_Metrics_vod__c wBrandAff, Account lAcc) {
            Product_Metrics_vod__c lBrandAff = wBrandAff.clone();
            lBrandAff.Account_vod__c = lAcc.Id;
            return lBrandAff;
        }

        private Set<String> getTerrNamesForUser(Id userId) {
            Set<String> names = new Set<String>();
            Set<Id> terrIds = new Set<Id>();

            for(UserTerritory2Association ut : [SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :userId]) {
                terrIds.add(ut.Territory2Id);
            }

            for(Territory2 terr : [SELECT Name FROM Territory2 WHERE Id IN :terrIds]) {
                names.add(terr.Name);
            }

            return names;
        }
    }
}