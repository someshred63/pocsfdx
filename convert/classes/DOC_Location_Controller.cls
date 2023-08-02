public with sharing class DOC_Location_Controller {
//------------------------------
// Author:      Nathan
// Date:        09/11/2010
// Description:
//    This controller is for creating Department of Corrections(DOC) Location.
//    Location and Address informations are input from user and Location
//    is created as a child of DOC and Address is created as a child of
//    Location.
//
// Change History:
//    09/11/2010 Nathan: Initial implementation of DoC Type 3 Visualforce Page
//    09/20/2010 Nathan: Added code to align Territory
//    10/26/2010 Nathan: Added code to create affiliation from Account to DoC Location
//------------------------------

    public Account docLocation {get; set;}
    public Address_vod__c doclAddress {get; set;}

    public Id docId {get; set;}    // Debug
    public Id locationId {get; set;}
    public List<selectOption> AccountTypeOption {get; set;}
    public String selectedAccountType {get; set;}
    public String parentAccountName {get; set;}

    public DOC_Location_Controller() {
        if (docLocation == null) {
            docLocation = new Account();
            docLocation.Record_Type_Text_GNE__c = 'Department of Corrections Location';
        }
        if (doclAddress == null) {
            doclAddress = new Address_vod__c();
        }
        if (AccountTypeOption == null) {
            AccountTypeOption = getAccountTypes();
        }

        docId = ApexPages.currentPage().getParameters().get('DoCId');
        locationId = docLocation.Id;

        // set DOC Location record type
        List <RecordType> rtList = [select Id, Name from RecordType
                                    where Name = 'Department of Corrections Location'
                                            and sObjectType = 'Account'];
        if (rtList.size() > 0) {
            docLocation.RecordTypeId = rtList[0].Id;
        } else {
            ErrorMsg('Account Record Type: "Department of Corrections Location" not available');
        }

        // Set DOC Id. This is the Account Id from where ' New DOC Location'
        // button is clicked.

        //docLocation.Parent_Hospital_gne__c = docId;
        docLocation.Parent_DoC_gne__c = docId;
        /*
        List <Account> aL = [select Id, Name from Account where Id =:docId];
        if (aL.size() > 0)
        {
            docLocation.ParentId = aL[0].Id;
            parentAccountName = aL[0].Name;
        }
        */
        // set DOC Location Address record type
        List <RecordType> rtAddrList = [select Id, Name from RecordType
                                        where Name = 'Rep Maintained'
                                                and sObjectType = 'Address_vod__c'];
        if (rtAddrList.size() > 0) {
            doclAddress.RecordTypeId = rtAddrList[0].Id;
        } else {
            ErrorMsg('Address Record Type: "Rep Maintained" not available');
        }


    }

    public PageReference saveDOCLocation() {
        // Validate input

        if (selectedAccountType == null || selectedAccountType == '--None--') {
            docLocation.Account_Type_gne__c.addError('Account Type is required');
            return null;
        }
        if (doclAddress.Name == null) {
            doclAddress.Name.addError('Street Address is required');
            return null;
        }
        if (doclAddress.City_vod__c == null) {
            doclAddress.City_vod__c.addError('City is required');
            return null;
        }
        if (doclAddress.State_vod__c == null) {
            doclAddress.State_vod__c.addError('State is required');
            return null;
        }
        if (doclAddress.Zip_vod__c == null) {
            doclAddress.Zip_vod__c.addError('Zip is required');
            return null;
        }

        // Save DOC Location record
        if (selectedAccountType != '--None--') {
            docLocation.Account_Type_gne__c = selectedAccountType;
        }
        try {
            insert docLocation;
        } catch (Exception e) {
            ErrorMsg('Error while creating DoC Location ...' + e.getMessage());
            return null;
        }


        // Save DoC Address

        doclAddress.Account_vod__c = docLocation.Id;
        doclAddress.primary_vod__c = True;

        try {
            insert doclAddress;
        } catch (Exception e) {
            ErrorMsg('Error while creating Address ...' + e.getMessage());
            return null;
        }


        // Create Affiliation Forward Affiliation

        Affiliation_vod__c af = new Affiliation_vod__c();
        af.From_Account_vod__c = docId;
        af.To_Account_vod__c = docLocation.Id;
        af.Role_vod__c = 'DoC Location';

        try {
            insert af;
        } catch (Exception e) {
            ErrorMsg('Error while creating Affiliation ...' + e.getMessage());
            return null;
        }


        // Align DoC Location to user territories

        List < Territory2 > terList = getUserTerritories(UserInfo.getUserId());
        for (Territory2 t : terList) {
            Boolean isAligned = InsertAccountShare(t.Id, docLocation.Id, true);
            if (isAligned == false) {
                ErrorMsg('Error while aligning to Territory: ' + t.Name);
                return null;
            }
        }

        // Return to newly created DOC Location detail record
        return new PageReference('/' + docLocation.Id);

        //return null;
    }
    public PageReference cancel() {
        // Return to account detail page
        return new PageReference('/' + docId);
        //return null;
    }
    // Write error message to vf page when validation fails
    void ErrorMsg(String s) {
        if (s != null) {
            ApexPages.Message Msg = new ApexPages.Message(ApexPages.severity.ERROR, s);
            ApexPages.addMessage(Msg);
        }
    }

    // Get Account Types from custom settings

    private List<selectOption> getAccountTypes() {
        List<selectOption> AccountTypeOption = new List<selectOption>();
        AccountTypeOption.add(new selectOption('--None--', '--None--'));
        Map < String, GNE_Foun_Misc_Config_Items_gne__c > configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
        if ((configItemsMap.containsKey('DocLocationTypes')) && (configItemsMap.get('DocLocationTypes').Configuration_Value_gne__c.length() > 0)) {
            List < String > AccountTypeList = new List < String > (configItemsMap.get('DocLocationTypes').Configuration_Value_gne__c.split(','));
            AccountTypeList.sort();
            for (Integer i = 0; i < AccountTypeList.size(); i++) {
                AccountTypeOption.add(new selectOption(AccountTypeList[i], AccountTypeList[i]));
            }
        }
        return AccountTypeOption;
    }
    private List < Territory2 > getUserTerritories(string userID) {
        List < Territory2 > terList = new List < Territory2 > ();
        List < UserTerritory2Association > utList =
            [Select u.Territory2Id, u.UserId
             from UserTerritory2Association u
             where u.UserId = : userID];
        for (UserTerritory2Association ut : utList) {
            terList.add([Select t.Id, t.Name from Territory2 t where t.Id = : ut.Territory2Id]);
        }
        return terList;
    }
    private String getTerritoryName(String territoryId) {

        String terrName = '';
        try {
            List < Territory2 > terrList = [select Id, Name from Territory2
                                            where Id = : territoryId];
            terrName = terrList[0].Name;
        } catch (Exception e) {
            ErrorMsg('Error while getting territory Name ...' + e.getMessage());
            return null;
        }
        return terrName;
    }
    private Boolean InsertAccountShare(String territoryId, String accountId, Boolean tsfFlag) {
        Boolean isAligned = false;
        ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = accountId, Territory2Id = territoryId, AssociationCause='Territory2Manual');

        try {
            insert territoryAssociation;
            isAligned = true;
        } catch (Exception e) {
            isAligned = false;
            ErrorMsg('Error while inserting Account Share ...' + e.getMessage());
            return null;
        }

        // Insert Territory Field record. My Target flag is from this record

        if (isAligned == true && tsfFlag == true) {
            isAligned = false; //Reset to false until insert the tsf record
            tsf_vod__c tsf = new tsf_vod__c();
            tsf.Account_Vod__c = accountId;
            tsf.My_Target_vod__c = True;
            tsf.Territory_vod__c = getTerritoryName(territoryId);
            try {
                insert(tsf);
                isAligned = true;
            } catch (Exception e) {
                isAligned = false;
                ErrorMsg('Error while inserting Territory2 Field ...' + e.getMessage());
                return null;
            }
        }

        return isAligned;
    }
}