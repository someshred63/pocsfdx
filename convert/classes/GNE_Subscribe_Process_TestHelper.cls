public class GNE_Subscribe_Process_TestHelper {
	
    public static void assertLicense(Address_vod__c adr) {
        System.assertEquals(adr.License_vod__c, GNE_Subscribe_Process_TestDataPrepare.LICENSE_NUMBER);
        System.assertEquals(adr.License_Status_vod__c, 'Valid_vod');
        System.assertEquals(adr.Designation_gne__c, GNE_Subscribe_Process_TestDataPrepare.DESIGNATION_DESCR);
    }
    
    public static Address_vod__c fetchAddress(Id accountId) {
        return [select City_vod__c, Name, MDM_Address_Id_gne__c, State_vod__c,
                    Country_gen__c, Zip_vod__c, Zip_4_vod__c, Active_Flag_gne__c,
                    Inactive_vod__c, Primary_vod__c, Gold_record_gne__c, Fax_vod__c,
                    Phone_vod__c, Phone_1_Ext_gne__c, Phone_2_vod__c, Phone_2_Ext_gne__c,
                    Address_line_2_vod__c, Address_line_3_gne__c, License_vod__c,
                    License_Expiration_Date_vod__c, License_Status_vod__c, Designation_gne__c,
                    Shipping_vod__c, Mailing_vod__c, Billing_vod__c, Business_vod__c,
                    Office_gne__c, Hospital_gne__c
                from Address_vod__c where Account_vod__r.Id = :accountId];
    }
    
    public static Address_vod__c fetchAddressById(Id addressId) {
        return [select City_vod__c, Name, MDM_Address_Id_gne__c, State_vod__c,
                    Country_gen__c, Zip_vod__c, Zip_4_vod__c, Active_Flag_gne__c,
                    Inactive_vod__c, Primary_vod__c, Gold_record_gne__c, Fax_vod__c,
                    Phone_vod__c, Phone_1_Ext_gne__c, Phone_2_vod__c, Phone_2_Ext_gne__c,
                    Address_line_2_vod__c, Address_line_3_gne__c, License_vod__c,
                    License_Expiration_Date_vod__c, License_Status_vod__c, Designation_gne__c,
                    Shipping_vod__c, Mailing_vod__c, Billing_vod__c, Business_vod__c,
                    Office_gne__c, Hospital_gne__c
                from Address_vod__c where Id = :addressId];
    }
    
    public static Account fetchCreatedAccount() {
        return [select Id, OwnerId, Owner.External_ID_gne__c, Name, FirstName, LastName, Middle_vod__c, MDMID_gne__c,
                    Gender_vod__c, Date_of_Birth_gne__c, Credentials_gne__c,
                    Professional_Type_gne__c, Specialties_gne__c, Cell_Phone_gne__c,
                    Phone, Website, RecordTypeId, MDMID_Status_gne__c,
                    MDM_Update_Date_gne__c, Account_Type_gne__c, PDRP_Opt_Out_vod__c, PDRP_Opt_Out_Date_vod__c
                from Account
                where MDMID_gne__c = :GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID];
    }
    
    public static Account fetchAccount(Id accountId) {
        return [select Id, OwnerId, Owner.External_ID_gne__c, Name, FirstName, LastName, Middle_vod__c, MDMID_gne__c,
                    Gender_vod__c, Date_of_Birth_gne__c, Credentials_gne__c,
                    Professional_Type_gne__c, Specialties_gne__c, Cell_Phone_gne__c,
                    Phone, Website, RecordTypeId, MDMID_Status_gne__c,
                    MDM_Update_Date_gne__c, Account_Type_gne__c, PDRP_Opt_Out_vod__c, PDRP_Opt_Out_Date_vod__c
                from Account where Id = :accountId];
    }
    
    public static void assertAddressPhisical(Address_vod__c adr) {
        System.assertEquals(adr.Name, GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_PRIAMRY);
        System.assertEquals(adr.City_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_CITY);
        System.assertEquals(adr.State_vod__c, GNE_Subscribe_Process_TestDataPrepare.STATE_PROVINCE);
        System.assertEquals(adr.Country_gen__c, GNE_Subscribe_Process_TestDataPrepare.COUNTRY);
        System.assertEquals(adr.Zip_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_NAME);
        System.assertEquals(adr.Zip_4_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_CODE);
        System.assert(adr.Active_Flag_gne__c);
        //System.assert(!adr.Inactive_vod__c);
        System.assert(adr.Gold_record_gne__c);
        System.assertEquals(adr.Fax_vod__c, GNE_Subscribe_Process_TestDataPrepare.FAX_NUM);
        System.assertEquals(adr.Phone_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_1_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_2_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
        System.assertEquals(adr.Phone_2_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
    }
    
    public static void assertAccountIndividual(Account a) {
        System.assertNotEquals(a, null);
        System.assertEquals(a.FirstName, GNE_Subscribe_Process_TestDataPrepare.INDIVIDUAL_FIRST_NAME);
        System.assertEquals(a.Middle_vod__c, GNE_Subscribe_Process_TestDataPrepare.INDIVIDUAL_MIDDLE_NAME);
        System.assertEquals(a.LastName, GNE_Subscribe_Process_TestDataPrepare.INDIVIDUAL_LAST_NAME);
        System.assertEquals(a.Date_of_Birth_gne__c, '1975-2-4');
        System.assertEquals(a.Credentials_gne__c, GNE_Subscribe_Process_TestDataPrepare.ACCOUNT_CREDENTIALS);
        Map<String, GNE_Foun_Role_Ranking_gne__c> mapRoleRanking = GNE_Foun_Role_Ranking_gne__c.getAll();
        String profType = mapRoleRanking.get(GNE_Subscribe_Process_TestDataPrepare.ROLE_NURSE_PRACTITIONER).Account_Professional_Type_gne__c;
        System.assertEquals(a.Professional_Type_gne__c, profType);
        System.assertEquals(a.Specialties_gne__c, GNE_Subscribe_Process_TestDataPrepare.SPECIALITY_2+';'+GNE_Subscribe_Process_TestDataPrepare.SPECIALITY_1);
        System.assertEquals(a.Cell_Phone_gne__c, GNE_Subscribe_Process_TestDataPrepare.CELL_PHONE);
        System.assertEquals(a.Phone, GNE_Subscribe_Process_TestDataPrepare.PHONE);
        System.assertEquals(a.PDRP_Opt_Out_Date_vod__c, Date.newinstance(2009, 12, 31));
        System.assertEquals(a.PDRP_Opt_Out_vod__c, true);
        System.assertEquals(a.Owner.External_ID_gne__c, 'krzysztl');
        System.assertEquals(a.OwnerId, '00570000001RGAtAAO');   
    }
    
    public static void assertAddressSecondary(Address_vod__c adr) {
        String name = GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_UNIT_TYPE_CODE + ' ' +
            GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_VALUE;
        System.assertEquals(adr.Name, name);
        System.assertEquals(adr.City_vod__c, null);
        System.assertEquals(adr.State_vod__c, null);
        System.assertEquals(adr.Country_gen__c, GNE_Subscribe_Process_TestDataPrepare.COUNTRY_DEFAULT);
        System.assertEquals(adr.Zip_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_NAME);
        System.assertEquals(adr.Zip_4_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_CODE);
        System.assert(adr.Active_Flag_gne__c);
        //System.assert(!adr.Inactive_vod__c);
        System.assert(adr.Gold_record_gne__c);
        System.assertEquals(adr.Fax_vod__c, GNE_Subscribe_Process_TestDataPrepare.FAX_NUM);
        System.assertEquals(adr.Phone_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_1_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_2_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
        System.assertEquals(adr.Phone_2_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
    }
    
    public static void assertNullsecondaryAddressUnitTypeCode(Address_vod__c adr) {
        String name = GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_VALUE;
        System.assertEquals(adr.Name, name);
        System.assertEquals(adr.City_vod__c, null);
        System.assertEquals(adr.State_vod__c, null);
        System.assertEquals(adr.Country_gen__c, GNE_Subscribe_Process_TestDataPrepare.COUNTRY_DEFAULT);
        System.assertEquals(adr.Zip_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_NAME);
        System.assertEquals(adr.Zip_4_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_CODE);
        System.assert(adr.Active_Flag_gne__c);
        //System.assert(!adr.Inactive_vod__c);
        System.assert(adr.Gold_record_gne__c);
        System.assertEquals(adr.Fax_vod__c, GNE_Subscribe_Process_TestDataPrepare.FAX_NUM);
        System.assertEquals(adr.Phone_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_1_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_2_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
        System.assertEquals(adr.Phone_2_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
    }
        
    public static void assertAddressPhysicalAndSecondary(Address_vod__c adr) {
        System.assertEquals(adr.Name, GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_PRIAMRY);
        System.assertEquals(adr.City_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_CITY);
        System.assertEquals(adr.State_vod__c, GNE_Subscribe_Process_TestDataPrepare.STATE_PROVINCE);
        System.assertEquals(adr.Country_gen__c, GNE_Subscribe_Process_TestDataPrepare.COUNTRY);
        System.assertEquals(adr.Zip_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_NAME);
        System.assertEquals(adr.Zip_4_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_CODE);
        System.assert(adr.Active_Flag_gne__c);
        //System.assert(!adr.Inactive_vod__c);
        System.assert(adr.Gold_record_gne__c);
        System.assertEquals(adr.Fax_vod__c, GNE_Subscribe_Process_TestDataPrepare.FAX_NUM);
        System.assertEquals(adr.Phone_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_1_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_2_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
        System.assertEquals(adr.Phone_2_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
        String addrLine2 = GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_UNIT_TYPE_CODE + ' ' +
            GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_VALUE;
        System.assertEquals(adr.Address_line_2_vod__c, addrLine2);
        String addrLine3 = GNE_Subscribe_Process_TestDataPrepare.BLDG_DESC + ' ' +
            GNE_Subscribe_Process_TestDataPrepare.BLDG_FL_DESC;
        System.assertEquals(adr.Address_line_3_gne__c, addrLine3);
    }
    
    public static void assertAddressPhysicalAndSecondaryWithoutUtypeCode(Address_vod__c adr) {
        System.assertEquals(adr.Name, GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_PRIAMRY);
        System.assertEquals(adr.City_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_CITY);
        System.assertEquals(adr.State_vod__c, GNE_Subscribe_Process_TestDataPrepare.STATE_PROVINCE);
        System.assertEquals(adr.Country_gen__c, GNE_Subscribe_Process_TestDataPrepare.COUNTRY);
        System.assertEquals(adr.Zip_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_NAME);
        System.assertEquals(adr.Zip_4_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_CODE);
        System.assert(adr.Active_Flag_gne__c);
        //System.assert(!adr.Inactive_vod__c);
        System.assert(adr.Gold_record_gne__c);
        System.assertEquals(adr.Fax_vod__c, GNE_Subscribe_Process_TestDataPrepare.FAX_NUM);
        System.assertEquals(adr.Phone_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_1_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_2_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
        System.assertEquals(adr.Phone_2_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
        String addrLine2 = GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_VALUE;
        System.assertEquals(adr.Address_line_2_vod__c, addrLine2);
        String addrLine3 = GNE_Subscribe_Process_TestDataPrepare.BLDG_DESC + ' ' +
            GNE_Subscribe_Process_TestDataPrepare.BLDG_FL_DESC;
        System.assertEquals(adr.Address_line_3_gne__c, addrLine3);
    }
    
    public static void assertAddressMissingBldgFloorDesc(Address_vod__c adr) {
    	System.assertEquals(adr.Name, GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_PRIAMRY);
        System.assertEquals(adr.City_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_CITY);
        System.assertEquals(adr.State_vod__c, GNE_Subscribe_Process_TestDataPrepare.STATE_PROVINCE);
        System.assertEquals(adr.Country_gen__c, GNE_Subscribe_Process_TestDataPrepare.COUNTRY);
        System.assertEquals(adr.Zip_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_NAME);
        System.assertEquals(adr.Zip_4_vod__c, GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_CODE);
        System.assert(adr.Active_Flag_gne__c);
        //System.assert(!adr.Inactive_vod__c);
        System.assert(adr.Gold_record_gne__c);
        System.assertEquals(adr.Fax_vod__c, GNE_Subscribe_Process_TestDataPrepare.FAX_NUM);
        System.assertEquals(adr.Phone_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_1_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE2);
        System.assertEquals(adr.Phone_2_vod__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
        System.assertEquals(adr.Phone_2_Ext_gne__c, GNE_Subscribe_Process_TestDataPrepare.PHONE3);
        String addrLine2 = GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_UNIT_TYPE_CODE + ' ' +
            GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_VALUE;
        System.assertEquals(adr.Address_line_2_vod__c, addrLine2);
        String addrLine3 = GNE_Subscribe_Process_TestDataPrepare.BLDG_FL_DESC;
        System.assertEquals(adr.Address_line_3_gne__c, addrLine3);
    }
    
    public static void assertAccountOrg(Account a) {
        System.assertNotEquals(a, null);
        System.assertEquals(a.Name, GNE_Subscribe_Process_TestDataPrepare.ORGANIZATION_NAME);
        System.assertEquals(a.MDMID_gne__c, GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID);
        System.assertEquals(a.MDMID_Status_gne__c, 'Active');
        System.assertNotEquals(a.RecordTypeId, null);
        System.assertEquals(a.Account_Type_gne__c, 'Hospital');
        System.assertEquals(a.Website, GNE_Subscribe_Process_TestDataPrepare.ORGANIZATION_WEBSITE);
    }
 
    public static void PrepareGNE_Suppress_Execution_Settings(Boolean SES_switch) {
        /*GNE_Suppress_Execution_Settings__c SES;
        SES = GNE_Suppress_Execution_Settings__c.getInstance();
        SES.Disable_gne__c = SES_Switch;
        update SES;
        */
    }
}