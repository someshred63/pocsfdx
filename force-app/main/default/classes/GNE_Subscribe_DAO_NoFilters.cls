/************************************************************
*  @author: Krzysztof Leszek, Roche
*  Date: 06-July-2010
*  Description: Contains queries required by the subscribe
*               process
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public without sharing class GNE_Subscribe_DAO_NoFilters {

    private static final String CONFIG_ITEM_NAME_LICENSE_CR     = 'LicenseChangeRequestRecordTypeName';
    private static final String CONFIG_ITEM_NAME_VALID_SOURCES  = 'ValidSourcesXREFList';
    private static final String RECORD_TYPE_NAME_LICENSE_CR;    // Record Type Name for License Data Change Request
    private static final Set<String> VALID_SOURCES;             // Valid contributor sources for a party to be processed (as defined in the CONFIG_ITEM_NAME_VALID_SOURCES custom setting)
    
    static {
        // Valid Sources
        Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_VALID_SOURCES)) && (configItemsMap.get(CONFIG_ITEM_NAME_VALID_SOURCES).Configuration_Value_gne__c.length() > 0)) {
            List<String> configItemList = new List<String>(configItemsMap.get(CONFIG_ITEM_NAME_VALID_SOURCES).Configuration_Value_gne__c.split(','));
            for (Integer i = 0; i < configItemList.size(); i++){
                configItemList[i] =  configItemList[i].trim();
            }
            VALID_SOURCES = new Set<String>(configItemList);
        } else VALID_SOURCES = new Set<String>();
        // Licanse Change Request Record Type Name
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_LICENSE_CR)) && (configItemsMap.get(CONFIG_ITEM_NAME_LICENSE_CR).Configuration_Value_gne__c.length() > 0)) {
            RECORD_TYPE_NAME_LICENSE_CR = configItemsMap.get(CONFIG_ITEM_NAME_LICENSE_CR).Configuration_Value_gne__c;
        } else{
            RECORD_TYPE_NAME_LICENSE_CR = '';
        }
    }
    
    /**
    * Retreives account hierarchy (accounts and associated addresses and external Ids) from
    * the Account object for a given list of account SFDC Ids or MDM Ids
    */
    public static List<Account> fetchAccounts(Set<String> accountIDList, Set<String> mdmIDList) {
        return [SELECT
        Id,                         // SFDC Account Id
        CreatedDate,                // SFDC Account Created Date
        Account_Type_gne__c,        // Account Type (Clinic, Pharmacy, Health Case Professional etc.)
        AMS_ID_gne__c,              // AMD ID
        Cell_Phone_gne__c,          // Cell Phone Number
        Credentials_gne__c,         // Credentials (BA, MS, PHD etc.)
        Date_of_Birth_gne__c,       // Date of Birth
        FirstName,                  // First Name
        Gender_vod__c,              // Gender of the professional (Person Account) (M, F)
        LastName,                   // Last Name
        MDM_Update_Date_gne__c,     // DW Last Updated timestamp
        MDMID_gne__c,               // MDM ID
        MDMID_Status_gne__c,        // MDMID Status (Active,Inactive)
        Status_gne__c,              // Account Status (Active, Dead, Retired, Inactive, Indeterminate)
        Middle_vod__c,              // Middle name of the professional (Person Account)
        Phone,                      // Phone
        Professional_Type_gne__c,   // Professional Type (Medical Doctor, Thought Leader etc.)
        RecordTypeId,               // Record Type Id
        RecordType.Name,            // Record Type Name
        RecordType.Description,     // Record Type Description
        Salutation,                 // Salutation
        Specialties_gne__c,         // Specialties (Picklist Multi-Select)
        Suffix_gne__c,              // Suffix (Used for person accounts)
        Suffix_vod__c,              // =||=
        Website,                    // Website
        
        (SELECT
        Account_vod__c,         // SFDC Account Id reference
        MDM_Address_ID_gne__c,  // MDM Address Id
        Name,                   // Street Address
        Address_line_2_vod__c,  // Suite/Floor/Unit
        Address_Line_3_gne__c,  // Department Name
        City_vod__c,            // City
        State_vod__c,           // State (Country dependent picklist)
        Country_gen__c,         // Country
        Zip_vod__c,             // Zip code of the Address
        Zip_4_vod__c,           // ZIP + 4 of the Address
        Shipping_vod__c,        // Shipping (checkbox that determines if an Address serves as a shipping address)
        Mailing_vod__c,         // Mailing (checkbox that determines if an Address serves as a mailing address)
        Billing_vod__c,         // Billing (checkbox to determine if an Address serves as a billing address)
        Business_vod__c,        // Business (checkbox to determine if an Address serves as a business address)
        Office_gne__c,          // Office
        Hospital_gne__c,        // Hospital (checkbox to determine if the address is a Hospital address)
        Fax_vod__c,             // Fax number for the Account at the Address
        Phone_vod__c,           // Primary phone number for the Account at the Address
        Phone_1_Ext_gne__c,     // Extension number for Phone
        Phone_2_vod__c,         // Alternate phone number for the Account at the Address
        Phone_2_Ext_gne__c,     // Extension number for Phone 2
        License_vod__c,         // State License Number for the corresponding State of the Address
        License_Expiration_Date_vod__c, // State License Expiration Date
        License_Status_vod__c,  // State License Status
        Designation_gne__c,     // Designation
        Active_Flag_gne__c,     // Active flag
        GOLD_RECORD_gne__c,     // Gold Address Flag
        MDM_Status_gne__c       // Address Status
        FROM
        Address_vod__r),        // Address
        
        (SELECT
        Address_gne__c,             // SFDC Address FK
        Account_gne__c,             // SFDC Account FK
        MDMID_gne__c,               // MDM ID of the account
        Third_Party_gne__c,         // External System Name (NVTS, PW, TSG etc.) (CADS Contributor Source Code)
        Third_Party_Id_gne__c,      // CADS Contributor Source Id
        Third_Party_Index_gne__c    // Third Party Index (concat. Third Party with Third Party Id)
        FROM
        Account_External_Id_gne__r),//  Account External Id

        (SELECT
        Account_gne__c,                             // SFDC Account Id
        License_Expiration_Date_gne__c,             // Licanse Expiration Date
        License_Number_gne__c,                      // License Number
        License_Overwrite_Expiration_Date_gne__c,   // License Expiration Date
        License_Sample_ability_gne__c,              // License Sample-ablility
        License_State_gne__c                        // License State
        FROM
        R00N70000001woYtEAI                         // Data Change Request
        WHERE
        RecordType.Name = :RECORD_TYPE_NAME_LICENSE_CR AND
        (NOT Status_gne__c like 'Closed%'))
        
        FROM
        Account
        WHERE
        Id IN :accountIDList OR MDMID_gne__c IN :mdmIDList];
    }

    
    /**
    * Retreives addresses from SFDC (including external Ids) from
    * the Address object for a given list of SFDC Ids or MDM Ids
    */
    public static List<Address_vod__c> fetchAddresses(Set<String> addressIDList, Set<String> mdmAddressIDList) {
        return [SELECT
        Id,                     // SFDC Address Id
        CreatedDate,            // SFDC Address Created Date
        Account_vod__c,         // SFDC Account Id reference
        MDM_Address_ID_gne__c,  // MDM Address Id
        Name,                   // Street Address
        Address_line_2_vod__c,  // Suite/Floor/Unit
        Address_Line_3_gne__c,  // Department Name
        City_vod__c,            // City
        State_vod__c,           // State (Country dependent picklist)
        Country_gen__c,         // Country
        Zip_vod__c,             // Zip code of the Address
        Zip_4_vod__c,           // ZIP + 4 of the Address
        Shipping_vod__c,        // Shipping (checkbox that determines if an Address serves as a shipping address)
        Mailing_vod__c,         // Mailing (checkbox that determines if an Address serves as a mailing address)
        Billing_vod__c,         // Billing (checkbox to determine if an Address serves as a billing address)
        Business_vod__c,        // Business (checkbox to determine if an Address serves as a business address)
        Office_gne__c,          // Office
        Hospital_gne__c,        // Hospital (checkbox to determine if the address is a Hospital address)
        Fax_vod__c,             // Fax number for the Account at the Address
        Phone_vod__c,           // Primary phone number for the Account at the Address
        Phone_1_Ext_gne__c,     // Extension number for Phone
        Phone_2_vod__c,         // Alternate phone number for the Account at the Address
        Phone_2_Ext_gne__c,     // Extension number for Phone 2
        License_vod__c,         // State License Number for the corresponding State of the Address
        License_Expiration_Date_vod__c, // State License Expiration Date
        License_Status_vod__c,  // State License Status
        Designation_gne__c,     // Designation
        Active_Flag_gne__c,     // Active flag
        GOLD_RECORD_gne__c,     // Gold Address Flag
        AMS_gold_record_gne__c, // AMS Gold Address Flag
        MDM_Status_gne__c,      // Address Status
        
        (SELECT
        Id,                         // SFDC Address External Id
        Address_gne__c,             // SFDC Address Id
        Third_Party_gne__c,         // External System Name (PW, TSG etc.) (CADS Contributor Source Code)
        Third_Party_Id_gne__c,      // CADS Contributor Source Id
        Third_Party_Index_gne__c    // Third Party Index (concat. Third Party with Third Party Id)
        FROM
        R00N70000002Gy6UEAS)        // Address External Id reference
        
        FROM
        Address_vod__c
        WHERE
        Id IN :addressIDList OR MDM_Address_ID_gne__c IN :mdmAddressIDList];
    }


    /**
    * Retreives Record Types
    */
    public static List<RecordType> fetchRecordTypes() {
        return [SELECT
        Id,                         // SFDC Record Type Id
        Name,                       // Record Type Name
        SobjectType,                // SObject Type
        Description                 // Record Type Descriprion
        FROM
        RecordType
        WHERE
        SobjectType IN ('Account')
        ORDER BY
        SobjectType ASC];
    }
}