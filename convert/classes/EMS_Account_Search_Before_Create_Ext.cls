public with sharing class EMS_Account_Search_Before_Create_Ext extends GNE_SFA2_Account_SBC_Controller {

    private static final String ALLOWED_ACCOUNT_TYPE = 'HCP';

    public EMS_Account_Search_Before_Create_Ext(ApexPages.StandardController controller) {
    }

    public EMS_Account_Search_Before_Create_Ext() {
        super();

        fakeAddress = new Address_vod__c();
        fakeAddress.RecordTypeId = getAddrRecTypeId();
    }

    private Address_vod__c saveAccountSBC() {
        GNE_Account_Dao acctDao = new GNE_Account_Dao(false);
        Address_vod__c address = new Address_vod__c();

        address.name = newAddr.Street_gne__c;

        address.Address_1_gne__c = newAddr.Street_gne__c;
        address.Address_line_2_vod__c = newAddr.Street_2_gne__c;
        address.City_vod__c = newAddr.City_gne__c;
        address.Province_can_gne__c = newAddr.Province_can_gne__c;
        address.Postal_Code_can_gne__c = newAddr.Postal_Code_can_gne__c;
        address.Primary_vod__c = true;
        address.Active_Flag_gne__c = true;
        address.Country_gen__c = 'CANADA';
        address.Address_Type_gne__c = fakeAddress.Address_Type_gne__c;

        setAccountType();

        //save Account
        Exception ex = acctDao.saveSObjectEx(newAcct);
        if (ex != null) {
            throw ex;
        }

        newId = newAcct.Id;

        //set address record type to RepMaintained and save it
        List<RecordType> recTypes;
        if (acctType == 'HCP') {
            recTypes = fetchRecordTypes('Address_vod__c', REC_TYPE_ADDR_CAN_HCP);
        } else {
            recTypes = fetchRecordTypes('Address_vod__c', REC_TYPE_ADDR_CAN_HCO);
        }

        if (recTypes != null && recTypes.size() > 0) {
            address.RecordTypeId = recTypes[0].Id;
        }

        address.Account_vod__r = newAcct;
        address.Account_vod__c = newAcct.Id;
        ex = acctDao.saveSObjectEx(address);
        if (ex != null) {
            throw ex;
        }

        //save territory alignment
        if (!isNullOrEmpty(selectedTerritory)) {
            if (selectedTerritory != NO_TERRITORY_SELECTED) {
                GNE_Territory_Dao terrDao = new GNE_Territory_Dao();
                ex = terrDao.alignAccountToTerritory(newAcct.Id, address.Id, selectedTerritory);
                Account_Alignment_WS.InsertBrandAffiliation(selectedTerritory, newAcct.Id);
                if (ex != null) {
                    throw ex;
                }

                makeNotMyTargetCanadaAccount(newAcct.Id);
            } else {
                System.debug('Do not align was selected');
            }
        }

        return address;
    }

    public EMS_Remote_Response saveAccount() {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = true;
        Savepoint savePoint = Database.setSavepoint();

        try {
            newAcct.LastName = newAddr.LastName_gne__c;
            newAcct.FirstName = newAddr.FirstName_gne__c;

            response.responseObject = saveAccountSBC();
        } catch (DMLException ex) {
            Database.rollback(savePoint);
            response.isSuccess = false;
            response.errorMessages = new List<String>();

            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.addError(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            Database.rollback(savePoint);
            response.isSuccess = false;
            response.errorMessages = new List<String>{
                    ex.getMessage()
            };
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response createAccount(String firstName, String middleName, String lastName, String street, String suite, String city, String province, String postalCode, String accountType, String addressType, String territory) {
        EMS_Account_Search_Before_Create_Ext sbc = new EMS_Account_Search_Before_Create_Ext();
        sbc.init();
        sbc.acctType = ALLOWED_ACCOUNT_TYPE;
        sbc.allowedType = ALLOWED_ACCOUNT_TYPE;
        sbc.newId = null;
        sbc.newAddr = new SFASearchStrings_gne__c();
        sbc.newAcct = new Account();
        sbc.newAddr.FirstName_gne__c = firstName;
        sbc.newAcct.Middle_vod__c = middleName;
        sbc.newAddr.LastName_gne__c = lastName;
        sbc.newAddr.Street_gne__c = street;
        sbc.newAddr.Street_2_gne__c = suite;
        sbc.newAddr.City_gne__c = city;
        sbc.newAddr.Province_can_gne__c = province;
        sbc.newAddr.Postal_Code_can_gne__c = postalCode;
        sbc.selectedProfType = accountType;
        sbc.fakeAddress.Address_Type_gne__c = addressType;
        sbc.selectedTerritory = territory;

        return sbc.saveAccount();
    }
}