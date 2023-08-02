public without sharing class CORE_Subscribe_DAO {

    public static CORE_Subscribe_Job__c getSubscribeJob(Id jobId) {
        return [SELECT Id, Name, Subscribe_Object_gne__c, Subscribe_Object_gne__r.Retriever_Interface_gne__c, Subscribe_Object_gne__r.Validation_Interface_gne__c, Subscribe_Object_gne__r.Postprocess_Interface_gne__c, Status_gne__c, Subscribe_Metrics_json_gne__c, Summary_gne__c, Batch_Ids_json_gne__c FROM CORE_Subscribe_Job__c WHERE Id = :jobId];
    }

    public static CORE_Subscribe_Job__c getSubscribeJobForUpdate(Id jobId) {
        return [SELECT Id, Name, Subscribe_Object_gne__c, Status_gne__c, Subscribe_Metrics_json_gne__c, Summary_gne__c, Batch_Ids_json_gne__c FROM CORE_Subscribe_Job__c WHERE Id = :jobId FOR UPDATE];
    }

    public static Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> getMappingConfiguration(Id subscribeObjectId) {
        Map<String, List<CORE_Subscribe_Mapping_Configuration__c>>result = new Map<String, List<CORE_Subscribe_Mapping_Configuration__c>>();
        for (CORE_Subscribe_Mapping_Configuration__c config : [
                SELECT Source_Object_gne__c, Target_Object_gne__c, Default_Record_Owner_gne__c, Type_gne__c, Handler_gne__c, Create_New_Record_gne__c, Is_Full_Synchronization_gne__c, (
                        SELECT Source_Field_gne__c, Target_Field_gne__c, Is_External_Id_gne__c, Overwrite_Type_gne__c, Handler_gne__c, Parent_External_Field_Name_gne__c,
                                Reference_CustomSetting_gne__c, Reference_Field_gne__c, Parent_Object_gne__c, Mapping_Configuration_gne__r.Target_Object_gne__c
                        FROM Field_Configurations__r
                        WHERE Active_gne__c = TRUE
                        ORDER BY Order_gne__c
                )
                FROM CORE_Subscribe_Mapping_Configuration__c
                WHERE Subscribe_Object_gne__c = :subscribeObjectId
                ORDER BY Order_gne__c
        ]) {
            if (!result.containsKey(config.Source_Object_gne__c)) {
                result.put(config.Source_Object_gne__c, new List<CORE_Subscribe_Mapping_Configuration__c>());
            }
            result.get(config.Source_Object_gne__c).add(config);
        }
        return result;
    }

    /**
    * Retreives party hierarchy from staging objects for a given list of CADS party ids
    */
    public static List<CORE_Pub_Party__c>getPublishParties(Set<String> partyIds, Set<String>partyMdmIds, Set<String> validSources) {
        return [
                SELECT Id, Alt_Names_json_gne__c, Birthdate_gne__c, Comm_Channel_json_gne__c, Credentials_json_gne__c, Do_Not_Contact_gne__c,
                        Education_json_gne__c, FirstName_gne__c, Gender_gne__c, LastName_gne__c, Mdm_Id_gne__c, Mdm_Updt_Date_gne__c,
                        MiddleName_gne__c, Org_Name_gne__c, Org_Type_json_gne__c, Party_Id_gne__c, PDRP_Opt_Out_Date_gne__c, PDRP_Opt_Out_gne__c,
                        Prof_Type_json_gne__c, Salutation_gne__c, Specialties_json_gne__c, Spend_Rest_json_gne__c, Status_gne__c, Suffix_gne__c, Type_gne__c, (
                        SELECT Id, Party_Id_gne__c, Party_Id_ref_gne__c, Bldg_Desc_gne__c, Bldg_Fl_Desc_gne__c, City_gne__c, Comm_Chan_json_gne__c, Country_gne__c, Default_gne__c,
                                Latitude_gne__c, Loc_Use_json_gne__c, Longitude_gne__c, MDM_Id_gne__c, MDM_Status_gne__c, Party_Location_Id_gne__c, State_gne__c, Street_gne__c,
                                Unit_Type_gne__c, Unit_Value_gne__c, Zip_4_gne__c, Zip_gne__c
                        FROM Publish_Party_Locations__r
                ), (
                        SELECT Id, Party_Id_ref_gne__c, Party_Id_gne__c, Party_Id_ref_gne__r.Mdm_Id_gne__c, Adj_Lic_Exp_Date_gne__c, Designation_gne__c, Exp_Date_gne__c, Grace_Period_gne__c, Name,
                                License_Number_gne__c, External_Id_gne__c, License_State_gne__c, License_Status_gne__c, Smpl_Ovrl_Elig_Flag_gne__c, Profsnl_Dsgt_Rk_Nbr_gne__c, Profsnl_Dsgt_Fm_gne__c
                        FROM Publish_Licenses__r
                ), (
                        SELECT Id, Name, Exp_Date_gne__c, License_Number_gne__c, License_State_gne__c, License_Status_gne__c, Org_Address_gne__c, Org_Name_gne__c, Party_Id_gne__c,
                                Party_Id_ref_gne__c, Party_Id_ref_gne__r.Mdm_Id_gne__c
                        FROM Publish_TDDD_Licenses__r
                )
                FROM CORE_Pub_Party__c
                WHERE Party_Id_gne__c IN :partyIds OR Mdm_Id_gne__c IN :partyMdmIds
                ORDER BY Type_gne__c DESC
        ];
    }

    public static List<CORE_Pub_Party__c>getPublishParties(Map<String, Set<String>> partyIdToPartyLocIdMap, Map<String, Set<String>> partyMdmIdToPartyLocMdmIdMap, Set<String> validSources) {
        Set<String>partyLocIds = new Set<String>();
        for (Set<String>locIds : partyIdToPartyLocIdMap.values()) {
            partyLocIds.addAll(locIds);
        }

        Set<String>partyLocMdmIds = new Set<String>();
        for (Set<String>locMdmIds : partyMdmIdToPartyLocMdmIdMap.values()) {
            partyLocMdmIds.addAll(locMdmIds);
        }

        return [
                SELECT Id, Alt_Names_json_gne__c, Birthdate_gne__c, Comm_Channel_json_gne__c, Credentials_json_gne__c, Do_Not_Contact_gne__c,
                        Education_json_gne__c, FirstName_gne__c, Gender_gne__c, LastName_gne__c, Mdm_Id_gne__c, Mdm_Updt_Date_gne__c,
                        MiddleName_gne__c, Org_Name_gne__c, Org_Type_json_gne__c, Party_Id_gne__c, PDRP_Opt_Out_Date_gne__c, PDRP_Opt_Out_gne__c,
                        Prof_Type_json_gne__c, Salutation_gne__c, Specialties_json_gne__c, Spend_Rest_json_gne__c, Status_gne__c, Suffix_gne__c, Type_gne__c, (
                        SELECT Id, Party_Id_gne__c, Party_Id_ref_gne__c, Bldg_Desc_gne__c, Bldg_Fl_Desc_gne__c, City_gne__c, Comm_Chan_json_gne__c, Country_gne__c, Default_gne__c,
                                Latitude_gne__c, Loc_Use_json_gne__c, Longitude_gne__c, MDM_Id_gne__c, MDM_Status_gne__c, Party_Location_Id_gne__c, State_gne__c, Street_gne__c,
                                Unit_Type_gne__c, Unit_Value_gne__c, Zip_4_gne__c, Zip_gne__c
                        FROM Publish_Party_Locations__r
                        WHERE Party_Location_Id_gne__c IN :partyLocIds OR MDM_Id_gne__c IN :partyLocMdmIds
                ), (
                        SELECT Id, Party_Id_ref_gne__c, Party_Id_gne__c, Party_Id_ref_gne__r.Mdm_Id_gne__c, Adj_Lic_Exp_Date_gne__c, Designation_gne__c, Exp_Date_gne__c, Grace_Period_gne__c, Name,
                                License_Number_gne__c, External_Id_gne__c, License_State_gne__c, License_Status_gne__c, Smpl_Ovrl_Elig_Flag_gne__c, Profsnl_Dsgt_Rk_Nbr_gne__c, Profsnl_Dsgt_Fm_gne__c
                        FROM Publish_Licenses__r
                )
                FROM CORE_Pub_Party__c
                WHERE Party_Id_gne__c IN :partyIdToPartyLocIdMap.keySet() OR Mdm_Id_gne__c IN :partyMdmIdToPartyLocMdmIdMap.keySet()
        ];
    }

    /**
    * Return map: code -> value from custom setting passed as param 
    */
    public static Map<String, Object> getCodeMapping(String customSetting, String valueField) {
        Map<String, Object>mapping = new Map<String, Object>();
        if (customSetting == 'CORE_Pub_Prof_Typ__c') {
            Map<String, CORE_Pub_Prof_Typ__c> mapCodes = CORE_Pub_Prof_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Spcl_Typ__c') {
            Map<String, CORE_Pub_Spcl_Typ__c> mapCodes = CORE_Pub_Spcl_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Gndr_Typ__c') {
            Map<String, CORE_Pub_Gndr_Typ__c> mapCodes = CORE_Pub_Gndr_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Ind_Sts_Typ__c') {
            Map<String, CORE_Pub_Ind_Sts_Typ__c> mapCodes = CORE_Pub_Ind_Sts_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Org_Sts_Typ__c') {
            Map<String, CORE_Pub_Org_Sts_Typ__c> mapCodes = CORE_Pub_Org_Sts_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Org_Typ_Map__c') {
            Map<String, CORE_Pub_Org_Typ_Map__c> mapCodes = CORE_Pub_Org_Typ_Map__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Pln_Prodt_Typ__c') {
            Map<String, CORE_Pub_Pln_Prodt_Typ__c> mapCodes = CORE_Pub_Pln_Prodt_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Pln_Prodt_Model_Typ__c') {
            Map<String, CORE_Pub_Pln_Prodt_Model_Typ__c> mapCodes = CORE_Pub_Pln_Prodt_Model_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Loc_Use_Typ__c') {
            Map<String, CORE_Pub_Loc_Use_Typ__c> mapCodes = CORE_Pub_Loc_Use_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Indv_Role_Typ__c') {
            Map<String, CORE_Pub_Indv_Role_Typ__c> mapCodes = CORE_Pub_Indv_Role_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Indv_Role_To_Prof_Type_Map__c') {
            Map<String, CORE_Pub_Indv_Role_To_Prof_Type_Map__c> mapCodes = CORE_Pub_Indv_Role_To_Prof_Type_Map__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Hlth_Pln_Typ__c') {
            Map<String, CORE_Pub_Hlth_Pln_Typ__c> mapCodes = CORE_Pub_Hlth_Pln_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Pub_Edu_Degr_Typ__c') {
            Map<String, CORE_Pub_Edu_Degr_Typ__c> mapCodes = CORE_Pub_Edu_Degr_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        } else if (customSetting == 'CORE_Comm_Chnl_Typ__c') {
            Map<String, CORE_Comm_Chnl_Typ__c> mapCodes = CORE_Comm_Chnl_Typ__c.getAll();
            for (String code : mapCodes.keySet()) {
                mapping.put(code, mapCodes.get(code).get(valueField));
            }
        }
        return mapping;
    }

    public static Map<Id, List<CORE_Pub_Plan_Product__c>> getProductPlans(Set<Id> partyIds) {
        Map<Id, List<CORE_Pub_Plan_Product__c>>partyToProductPlans = new Map<Id, List<CORE_Pub_Plan_Product__c>>();
        for (CORE_Pub_Plan_Product__c prodPlan : [
                SELECT Id, Party_Id_ref_gne__c, Party_Id_gne__c, Hlth_Pln_Typ_gne__c, Mdcr_Pdp_Intr_Flag_gne__c, Mdcr_Sctr_Flag_gne__c, Pln_Prodt_End_Dt_gne__c, Pln_Prodt_Id_gne__c, Pln_Prodt_Lv_Cnt_gne__c, Pln_Prodt_Model_Typ_gne__c,
                        Pln_Prodt_Nm_gne__c, Pln_Prodt_Start_Dt_gne__c, Pln_Prodt_Typ_gne__c, Pln_Prodt_W_Phmcy_BenLv_Cnt_gne__c
                FROM CORE_Pub_Plan_Product__c
                WHERE Party_Id_ref_gne__c IN :partyIds
        ]) {
            if (!partyToProductPlans.containsKey(prodPlan.Party_Id_ref_gne__c)) {
                partyToProductPlans.put(prodPlan.Party_Id_ref_gne__c, new List<CORE_Pub_Plan_Product__c>());
            }
            partyToProductPlans.get(prodPlan.Party_Id_ref_gne__c).add(prodPlan);
        }
        return partyToProductPlans;
    }

    public static Map<Id, List<CORE_Pub_TDDD_License__c>> getTdddLicenses(Set<Id> partyIds) {
        Map<Id, List<CORE_Pub_TDDD_License__c>> partyToTdddLicenses = new Map<Id, List<CORE_Pub_TDDD_License__c>>();
        for (CORE_Pub_TDDD_License__c tdddLicense : [
                SELECT Id, Name, Exp_Date_gne__c, External_Id_gne__c, License_Number_gne__c, License_State_gne__c, License_Status_gne__c,
                        Org_Address_gne__c, Org_Name_gne__c, Party_Id_gne__c, Party_Id_ref_gne__c, Party_Id_ref_gne__r.MDM_Id_gne__c, PRVD_TDDD_LIC_ID_GNE__c
                FROM CORE_Pub_TDDD_License__c
                WHERE Party_Id_ref_gne__c IN :partyIds
        ]) {
            if (!partyToTdddLicenses.containsKey(tdddLicense.Party_Id_ref_gne__c)) {
                partyToTdddLicenses.put(tdddLicense.Party_Id_ref_gne__c, new List<CORE_Pub_TDDD_License__c>());
            }
            partyToTdddLicenses.get(tdddLicense.Party_Id_ref_gne__c).add(tdddLicense);
        }
        return partyToTdddLicenses;
    }

    public static Map<Id, List<CORE_Pub_License__c>> getLicenses(Set<Id> partyIds) {
        Map<Id, List<CORE_Pub_License__c>> partyToLicenses = new Map<Id, List<CORE_Pub_License__c>>();
        for (CORE_Pub_License__c license : [
                SELECT Id, Party_Id_ref_gne__c, Party_Id_gne__c, Party_Id_ref_gne__r.MDM_Id_gne__c, Adj_Lic_Exp_Date_gne__c, Designation_gne__c,
                        Exp_Date_gne__c, Grace_Period_gne__c, Name, External_Id_gne__c, License_Number_gne__c, License_State_gne__c, License_Status_gne__c, Smpl_Ovrl_Elig_Flag_gne__c, Profsnl_Dsgt_Rk_Nbr_gne__c, Profsnl_Dsgt_Fm_gne__c
                FROM CORE_Pub_License__c
                WHERE Party_Id_ref_gne__c IN :partyIds
        ]) {
            if (!partyToLicenses.containsKey(license.Party_Id_ref_gne__c)) {
                partyToLicenses.put(license.Party_Id_ref_gne__c, new List<CORE_Pub_License__c>());
            }
            partyToLicenses.get(license.Party_Id_ref_gne__c).add(license);
        }
        return partyToLicenses;
    }

    public static Map<Id, List<CORE_Pub_Location__c>> getLocations(Set<Id> partyIds) {
        Map<Id, List<CORE_Pub_Location__c>> partyToLocations = new Map<Id, List<CORE_Pub_Location__c>>();
        for (CORE_Pub_Location__c location : [
                SELECT Id, Party_Id_gne__c, Party_Id_ref_gne__c, Bldg_Desc_gne__c, Bldg_Fl_Desc_gne__c, City_gne__c, Comm_Chan_json_gne__c, Country_gne__c, Default_gne__c,
                        Latitude_gne__c, Loc_Use_json_gne__c, Longitude_gne__c, MDM_Id_gne__c, MDM_Status_gne__c, Party_Location_Id_gne__c, State_gne__c, Street_gne__c,
                        Unit_Type_gne__c, Unit_Value_gne__c, Zip_4_gne__c, Zip_gne__c
                FROM CORE_Pub_Location__c
                WHERE Party_Id_ref_gne__c IN :partyIds
        ]) {
            if (!partyToLocations.containsKey(location.Party_Id_ref_gne__c)) {
                partyToLocations.put(location.Party_Id_ref_gne__c, new List<CORE_Pub_Location__c>());
            }
            partyToLocations.get(location.Party_Id_ref_gne__c).add(location);
        }
        return partyToLocations;
    }

}