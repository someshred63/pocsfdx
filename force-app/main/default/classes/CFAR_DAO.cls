public class CFAR_DAO {
    private final static Id SRT_TEAM_PICKLIST_VALUE_RECORDTYPEID = Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('SRT Team').getRecordTypeId();
    public static List<Schema.PicklistEntry> milestoneActivityTypes {
        get {
            if (milestoneActivityTypes == null) {
                milestoneActivityTypes = CFAR_Milestone_Activity_gne__c.sfdc_Type_gne__c.getDescribe().getPicklistValues();
            }
            return milestoneActivityTypes;
        }
    }

    public static CFAR_Contact_gne__c[] getActiveContacts() {
        return [select name from CFAR_Contact_gne__c];
    }

    public static Map<ID, CFAR_Trial_gne__c> geTrialsByIds(List<ID> trialIds) {
        return new Map<ID, CFAR_Trial_gne__c>([
                select name,Received_Date_gne__c,SRT_Chair_ref_gne__c,MSL_ref_gne__c,Investigator_ref_gne__c,Original_Amount_gne__c,
                        CFAR_Specific_Indication_ref_gne__c,CFAR_General_Indication_ref_gne__c,Subject_Type__c, CTMS_gne__c,
                        Study_Phase_gne__c,Genentech_Primary_Contact_ref_gne__c,Product_ref_gne__c,Other_Trial_gne_Id__c,
                        Has_Amendment_Amount_gne__c, frm_Amendment_Amount_gne__c, frm_Current_Amount_gne__c
                from CFAR_Trial_gne__c
                where id in:trialIds
        ]);
    }

    public static CFAR_Trial_gne__c getTrial(string trialId) {
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.andEqualsParameters.put('Id', trialId);
        List<CFAR_Trial_gne__c> l = CFAR_DAO.getTrials(params);
        CFAR_Trial_gne__c rettrial = !l.isEmpty() ? l[0] : null;
        CFAR_Utils.logInfo('gotTrial!: ' + rettrial);
        return rettrial;
    }

    public static CFAR_Contact_gne__c[] getContacts(CFAR_SearchParameters parameters) {
        String queryString = 'select name,Active_Date_gne__c,Alternate_Phone_gne__c,Comments_gne__c,Degrees_gne__c,Email_gne__c,Employee_Type_gne__c, ' +
                'Fax_gne__c,First_Name_gne__c,Inactive_Date_gne__c,Last_Name_gne__c,Middle_Initials_gne__c,Mobile_Phone_gne__c,Phone_gne__c,Search_Name__c, ' +
                'Previous_Names_gne__c,Primary_Role_Function_gne__c,Role_Function_gne__c,Salutation_gne__c,Suffix_gne__c from CFAR_Contact_gne__c ';
        queryString += queryParametersString(parameters);
        queryString += ' limit 3999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Contact_gne__c[] getContactsForSelectOptions(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Search_Name__c from CFAR_Contact_gne__c ';
        queryString += queryParametersString(parameters);
        queryString += ' limit 3999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Product_gne__c[] getProducts(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Theme_ref_gne__r.name, Theme_ref_gne__r.Theme_Name_gne__c,name, Active_gne__c, Other_GNE_Agent_Active_gne__c, Generic_Name_gne__c from CFAR_Product_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static Database.QueryLocator getProductsForAdminQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getProductsForAdminQueryString(parameters));
    }

    private static String getProductsForAdminQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Abbreviation_gne__c, Theme_ref_gne__r.name, name, Active_gne__c, Other_GNE_Agent_Active_gne__c, Generic_Name_gne__c from CFAR_Product_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static CFAR_Product_gne__c[] getProductsForSelectOptions(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Generic_Name_gne__c, Active_gne__c from CFAR_Product_gne__c WHERE Active_gne__c = true';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Product_gne__c[] getStudiedProductsForSelectOptions(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Generic_Name_gne__c, Active_gne__c from CFAR_Product_gne__c WHERE Other_GNE_Agent_Active_gne__c = true';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_WBS_gne__c[] getWBSCodesForSelectOptions(CFAR_SearchParameters parameters) {
        String queryString = 'select id, Name, GSR_WBS_gne__c from CFAR_WBS_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_Status_gne__c[] getStudyStatusesForSelectOptions(CFAR_SearchParameters parameters) {
        String queryString = 'select id, Name from CFAR_Trial_Status_gne__c ' + queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static Database.QueryLocator getRdtsQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getRdtsQueryString(parameters));
    }

    private static String getRdtsQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c, Study_Stage__c from CFAR_Tracking_Activity_gne__c';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static Database.QueryLocator getThemesQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getThemesQueryString(parameters));
    }

    private static String getThemesQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c, Theme_Name_gne__c from CFAR_Theme_gne__c';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static CFAR_Theme_gne__c [] getThemesForSelectOptions(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name from CFAR_Theme_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_WBS_gne__c[] getWBSes(CFAR_SearchParameters parameters) {
        String queryString = 'select Id,Name,GSR_WBS_gne__c from CFAR_WBS_gne__c ';
        parameters.sortExpression = 'GSR_WBS_gne__c';
        parameters.sortDirection = 'asc';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Budget_Contract_Type_gne__c[] getContractTrackings(CFAR_SearchParameters parameters) {
        String queryString = 'select Id,Name from CFAR_Budget_Contract_Type_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Payment_Schedule_Status_gne__c[] getPaymentScheduleStatuses(CFAR_SearchParameters parameters) {
        String queryString = 'select Id,Name,Active_gne__c from CFAR_Payment_Schedule_Status_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);

    }

    public static CFAR_Tracking_Activity_gne__c[] getRegDocTrackingActivity(CFAR_SearchParameters parameters) {
        String queryString = 'select Id,Name, Active_gne__c, Study_Stage__c from CFAR_Tracking_Activity_gne__c ';
        parameters.sortExpression = 'Name';
        parameters.sortDirection = 'asc';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_WBS_gne__c[] getAllWBSes(CFAR_SearchParameters parameters) {
        return Database.query(getAllWBSesQueryString(parameters));
    }

    public static Database.QueryLocator getAllWBSesQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getAllWBSesQueryString(parameters));
    }

    private static String getAllWBSesQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name,GSR_WBS_gne__c, Active_gne__c,Old_WBS_Code_gne__c from CFAR_WBS_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static Database.QueryLocator getAllCostCentersQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getAllCostCentersQueryString(parameters));
    }

    private static String getAllCostCentersQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c from CFAR_Cost_Center__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static CFAR_Address_Type_gne__c[] getAddressTypes(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c from CFAR_Address_Type_gne__c ';

        queryString += queryParametersString(parameters);

        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Parent_Organization_gne__c[] getParentOrganizations(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c from CFAR_Parent_Organization_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Unit_Type_gne__c[] getUnitTypes(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c from CFAR_Unit_Type_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Partnership_gne__c[] getPartnerships(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c from CFAR_Partnership_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Picklist_Value_gne__c[] getSRTTeams(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c from CFAR_Picklist_Value_gne__c ';
        parameters.andEqualsParameters.put('RecordTypeId', SRT_TEAM_PICKLIST_VALUE_RECORDTYPEID);
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Institution_gne__c[] getInstitutions(CFAR_SearchParameters parameters) {
        return Database.query(getInstitutionsQueryString(parameters));
    }

    public static Database.QueryLocator getInstitutionsQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getInstitutionsQueryString(parameters));
    }

    public static String getInstitutionsQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Parent_Organization__c,Parent_Organization__r.Name, Active_gne__c from CFAR_Institution_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static Database.QueryLocator getInstitutionAddressesQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getInstitutionAddressesQueryString(parameters));
    }

    public static CFAR_Contact_Address_gne__c[] getInstitutionAddresses(CFAR_SearchParameters parameters) {
        return Database.query(getInstitutionAddressesQueryString(parameters));
    }

    private static String getInstitutionAddressesQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Institution_gne__c, Department_Division_gne__c, Institution_Company_gne__c,Postal_Code_gne__c, Zip_gne__c, Title_gne__c, Province_gne__c, State_gne__c, '
                + 'City_gne__c, Country_gne__c, Address_gne__c, Address_Type_ref_gne__c, Address_Type_ref_gne__r.Name, Active_gne__c, frm_Address_Type_ref_gne__c,Address_Type_gne__c from CFAR_Contact_Address_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static CFAR_Molecule_Configuration_gne__c[] getMoleculeConfigurations(CFAR_SearchParameters parameters) {
        return Database.query(getMoleculeConfigurationsQueryString(parameters));
    }

    public static Database.QueryLocator getMoleculeConfigurationsQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getMoleculeConfigurationsQueryString(parameters));
    }

    private static String getMoleculeConfigurationsQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Configuration_gne__c, Product_gne__c, CFAR_Unit_Type_ref_gne__c, CFAR_Unit_Type_ref_gne__r.Name, CFAR_Unit_Type_ref_gne__r.Active_gne__c, Active_gne__c, Product_gne__r.Name, Product_gne__r.Generic_Name_gne__c from CFAR_Molecule_Configuration_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static CFAR_Cohort_Molecule_gne__c[] getMolecules(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Dosage_Qty_gne__c, Cohort_ref_gne__c, Molecule_Configuration_ref_gne__c, Molecule_Configuration_ref_gne__r.CFAR_Unit_type_ref_gne__c, Molecule_Configuration_ref_gne__r.CFAR_Unit_type_ref_gne__r.Name, Molecule_Configuration_ref_gne__r.CFAR_Unit_type_ref_gne__r.Active_gne__c, Molecule_Configuration_ref_gne__r.Active_gne__c, Molecule_Configuration_ref_gne__r.Configuration_gne__c, Molecule_Configuration_ref_gne__r.Product_gne__r.Name, Molecule_Configuration_ref_gne__r.Product_gne__r.Generic_Name_gne__c, Molecule_Configuration_ref_gne__r.Product_gne__c, Months_On_Therapy_gne__c, Dosage_Frequency_gne__c, Dosage_Interval_gne__c, Comments_gne__c from CFAR_Cohort_Molecule_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Cohort_gne__c[] getCohorts(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Trial_ref_gne__c, Total_Cohort_Patients_gne__c, Cohort_number_gne__c from CFAR_Cohort_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_Other_GNE_Agent_gne__c [] getTrialOtherGNEAgents(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, frm_Other_GNE_Agent_Generic_gne__c, Other_GNE_Agent_ref_gne__r.Name, Other_GNE_Agent_ref_gne__c, CFAR_Trial_ref_gne__c, Other_GNE_Agent_ref_gne__r.Other_GNE_Agent_Active_gne__c from CFAR_Trial_Other_GNE_Agent_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_IMP_Shipped__c [] getTrialIMPShipped(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, frm_IMP_Shipped_Generic__c, IMP_Shipped_ref__r.Name, IMP_Shipped_ref__c, CFAR_Trial_ref_gne__c, IMP_Shipped_ref__r.Other_GNE_Agent_Active_gne__c from CFAR_Trial_IMP_Shipped__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Team_Member_gne__c[] getTeamMembers(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Active_On_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Phone_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Email_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, '
                + 'CFAR_Trial_ref_gne__c,CFAR_Trial_ref_gne__r.Genentech_Primary_Contact_ref_gne__r.Search_Name__c, Comments_gne__c, frm_Function_Role_gne__c, '
                + 'Dollar_and_Drug_ref_gne__r.Name, Inactive_On_gne__c, frm_Name_gne__c, frm_Is_Inactive_gne__c, Is_Trial_Primary_Contact_gne__c, Is_Trial_MSL_gne__c, '
                + 'Function_Role_gne__c, Alerts_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.User_ref_gne__c, '
                + 'Address_Type_ref_gne__c, Address_Type_ref_gne__r.Name, Dollar_and_Drug_ref_gne__c, contact_address_ref_gne__r.Department_Division_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c, '
                + 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c, contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c, contact_address_ref_gne__r.Contact_Address_ref_gne__r.Active_gne__c, '
                + 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_Company_gne__c, contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c, '
                + 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c, contact_address_ref_gne__r.Contact_Address_ref_gne__r.Region_Code_gne__c, contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c,  '
                + 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.frm_State_and_Province_gne__c, contact_address_ref_gne__r.Contact_Address_ref_gne__r.Title_gne__c, contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c, contact_address_ref_gne__r.contact_address_ref_gne__r.Institution_gne__c, contact_address_ref_gne__r.contact_address_ref_gne__r.Institution_gne__r.Name, '
                + 'Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Primary_Role_Function_gne__c, Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Role_Function_gne__c, Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Tertiary_Role_Function_gne__c '
                + 'from CFAR_Team_Member_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Budget_Contract_gne__c[] getBudgetContracts(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Total_Payments_gne__c, Total_Rate_Table_Amount_gne__c, Amount_Left_to_Project_gne__c, PO_Number_gne__c, frm_Original_Amount_gne__c, frm_Current_Amount_gne__c, Prior_Years_Paid_gne__c, Year_to_Date_Paid_gne__c, frm_Total_Paid_gne__c, frm_Balance_gne__c, Total_Withholding_gne__c, Contract_End_Date_gne__c, Original_Contract_Execution_Date_gne__c from CFAR_Budget_Contract_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public Set<Id> ids = new Set<Id>();

    public static void setParamsWithNotInTrailStatusAdminFix(CFAR_SearchParameters parameters) {
        String adminFixStatus = Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX;
        List<CFAR_Trial_Status_gne__c> statuses = [select Id from CFAR_Trial_Status_gne__c where Name = :adminFixStatus];
        if (!statuses.isEmpty()) {
            parameters.andNOTInParameters.put('Trial_Status_ref_gne__c', new List<String>{
                    String.valueOf(statuses[0].Id)
            });
        }
    }

    public static String queryParametersString(CFAR_SearchParameters parameters) {
        final String AND_OPERATOR = ' and ';
        final String OR_OPERATOR = ' or ';
        final String LEFT_PARENTHESIS = ' (';
        final String RIGHT_PARENTHESIS = ' )';

        String queryString = '';
        System.debug(parameters);
        if (!parameters.isEmpty()) {
            queryString += ' where ';
        }
        system.debug('1 querry ' + queryString);
        for (String fieldName : parameters.andEqualsParameters.keyset()) {
            if ((parameters.andEqualsParameters.get(fieldName)) instanceof String) {
                String fieldValue = (String) parameters.andEqualsParameters.get(fieldName);
                queryString += (fieldName + ' = \'' + String.escapeSingleQuotes(fieldValue) + '\'' + AND_OPERATOR);
            } else {
                queryString += (fieldName + ' = ' + parameters.andEqualsParameters.get(fieldName) + ' ' + AND_OPERATOR);
            }
        }
        system.debug('2 querry ' + queryString);
        for (String fieldName : parameters.andNotEqualsParameters.keyset()) {
            if ((parameters.andEqualsParameters.get(fieldName)) instanceof String) {
                String fieldValue = (String) parameters.andNotEqualsParameters.get(fieldName);
                queryString += (fieldName + ' != \'' + String.escapeSingleQuotes(fieldValue) + '\'' + AND_OPERATOR);
            } else {
                queryString += (fieldName + ' != ' + parameters.andNotEqualsParameters.get(fieldName) + ' ' + AND_OPERATOR);
            }
        }
        system.debug('3 querry ' + queryString);
        for (String fieldName : parameters.andLikeParameters.keyset()) {
            queryString += (fieldName + ' like \'%' + String.escapeSingleQuotes(parameters.andLikeParameters.get(fieldName)) + '%\'' + AND_OPERATOR);
        }
        system.debug('4 querry ' + queryString);
        for (String fieldName : parameters.andStartsWithParameters.keyset()) {
            queryString += (fieldName + ' like \'' + String.escapeSingleQuotes(parameters.andStartsWithParameters.get(fieldName)) + '%\'' + AND_OPERATOR);
        }
        system.debug('5 querry ' + queryString);
        for (String fieldName : parameters.andInParameters.keySet()) {
            if (fieldName == 'Non_Interventional_gne__c' || fieldName == 'Subject_Type__c' || fieldName == 'Inclusive_Research_gne__c' || fieldName == 'Impacts_gne__c') {
                List<String> stringList = parameters.andInParameters.get(fieldName);
                queryString += (fieldName + ' in ' + LEFT_PARENTHESIS + '\'' + String.join(new List<String>(stringList), '\',\'') + '\'' + RIGHT_PARENTHESIS + AND_OPERATOR);
            } else {
                List<Id> idsList = parameters.andInParameters.get(fieldName);
                queryString += (fieldName + ' in ' + LEFT_PARENTHESIS + '\'' + String.join(new List<Id>(idsList), '\',\'') + '\'' + RIGHT_PARENTHESIS + AND_OPERATOR);
            }
        }
        system.debug('6 querry ' + queryString);
        for (String fieldName : parameters.andNOTInParameters.keySet()) {
            List<Id> idsList = parameters.andNOTInParameters.get(fieldName);
            queryString += (fieldName + ' NOT in ' + LEFT_PARENTHESIS + '\'' + String.join(new List<Id>(idsList), '\',\'') + '\'' + RIGHT_PARENTHESIS + AND_OPERATOR);
        }
        system.debug('7 querry ' + queryString);
        system.debug('orEqualsSize: ' + parameters.orEqualsParameters.keySet().size());
        for (String fieldName : parameters.orEqualsParameters.keySet()) {
            System.debug('fieldname: ' + fieldname);
            List<String> valuesList = parameters.orEqualsParameters.get(fieldName);

            queryString += LEFT_PARENTHESIS;
            for (String s : valuesList) {
                system.debug('s: ' + s);
                queryString += (fieldName + ' = \'' + s + '\'' + OR_OPERATOR);
            }
            queryString = queryString.removeEnd(OR_OPERATOR);
            queryString += RIGHT_PARENTHESIS;

            queryString += +AND_OPERATOR;
        }
        system.debug('8 querry ' + queryString);
        for (String fieldName : parameters.orGreaterParameters.keySet()) {
            List<String> valuesList = parameters.orGreaterParameters.get(fieldName);
            queryString += LEFT_PARENTHESIS;
            for (String s : valuesList) {
                queryString += (fieldName + ' > ' + s + ' ' + OR_OPERATOR);
            }
            queryString = queryString.removeEnd(OR_OPERATOR);
            queryString += RIGHT_PARENTHESIS;

            queryString += +AND_OPERATOR;
        }
        system.debug('9 querry ' + queryString);
        for (String fieldName : parameters.orLesserParameters.keySet()) {
            List<String> valuesList = parameters.orLesserParameters.get(fieldName);
            queryString += LEFT_PARENTHESIS;
            for (String s : valuesList) {
                queryString += (fieldName + ' < ' + s + ' ' + OR_OPERATOR);
            }
            queryString = queryString.removeEnd(OR_OPERATOR);
            queryString += RIGHT_PARENTHESIS;
            queryString += +AND_OPERATOR;
        }
        system.debug('10 querry ' + queryString);
        if (parameters.orLikeParameters != null && !parameters.orLikeParameters.isEmpty()) {
            for (String searchPageField : parameters.orLikeParameters.keySet()) {
                queryString += LEFT_PARENTHESIS;
                for (String fieldName : parameters.orLikeParameters.get(searchPageField).keySet()) {
                    queryString += (fieldName + ' like \'%' + String.escapeSingleQuotes(parameters.orLikeParameters.get(searchPageField).get(fieldName)) + '%\'' + OR_OPERATOR);
                }
                queryString = queryString.removeEnd(OR_OPERATOR);
                queryString += RIGHT_PARENTHESIS;
                queryString += +AND_OPERATOR;
            }
        }
        system.debug('11 querry ' + queryString);
        for (String fieldName : parameters.orInMultipicklistParameters.keySet()) {
            System.debug('fieldname: ' + fieldname);
            List<String> valuesList = parameters.orInMultipicklistParameters.get(fieldName);
            String operator = (parameters.multipicklistFieldOrAndLogic.get(fieldName) == 'AND') ? AND_OPERATOR : OR_OPERATOR;
            queryString += LEFT_PARENTHESIS;
            for (String s : valuesList) {
                system.debug('s: ' + s);
                queryString += (fieldName + ' like \'%' + String.escapeSingleQuotes(s) + '%\'' + operator);
            }
            queryString = queryString.removeEnd(operator);
            queryString += RIGHT_PARENTHESIS;
            queryString += +AND_OPERATOR;
        }
        system.debug('12 querry ' + queryString);
        for (String fieldName : parameters.inJunctionOrAndParameters.keySet()) {
            System.debug('junction fieldname: ' + fieldname);
            List<String> valuesList = parameters.inJunctionOrAndParameters.get(fieldName);
            String operator = (parameters.junctionOrAndLogic.get(fieldName) == 'AND') ? AND_OPERATOR : OR_OPERATOR;
            if (operator.equals(OR_OPERATOR)) {
                String orString = '';
                for (String id : valuesList) {
                    orString += '\'' + id + '\',';
                }
                orString = orString.removeEnd(',');
                queryString += fieldName + LEFT_PARENTHESIS + orString;
                queryString += RIGHT_PARENTHESIS + RIGHT_PARENTHESIS;
                queryString += +AND_OPERATOR;
            } else {
                for (String id : valuesList) {
                    queryString += fieldName + '\'' + id + '\'' + RIGHT_PARENTHESIS + AND_OPERATOR;
                }
            }
        }
        system.debug('13 querry ' + queryString);
        for (String fieldName : parameters.includesAll.keySet()) {
            queryString += fieldName + ' includes (\'';
            for (String pickVal : parameters.includesAll.get(fieldName)) {
                queryString += pickVal + ';';
            }
            queryString = queryString.removeEnd(';');
            queryString += '\') and ';
        }
        for (String fieldName : parameters.includesAny.keySet()) {
            queryString += fieldName + ' includes (\'';
            for (String pickVal : parameters.includesAny.get(fieldName)) {
                queryString += pickVal + '\',\'';
            }
            queryString = queryString.removeEnd(',\'');
            queryString += ') and ';
        }
        System.debug('14 querry ' + queryString);
        queryString = queryString.replace('\'true\'', 'true');
        queryString = queryString.replace('\'false\'', 'false');
        queryString = queryString.removeEnd(AND_OPERATOR);

        if (parameters.sortExpression != '') {
            queryString += ' order by ';
            for (String parameter : parameters.sortExpression.split(';')) {
                queryString += parameter;
                queryString += ' ' + parameters.sortDirection;
                if (parameters.sortDirection != '') {
                    queryString += ' NULLS LAST';
                }
                queryString += ', ';
            }
            queryString = queryString.removeEnd(', ');
        }
        System.debug('---- queryParametersString ' + queryString);
        return queryString;
    }

    public static String queryParametersStringComments(CFAR_SearchParameters parameters) {
        String queryString = '';
        if (parameters.sortExpression != '') {
            queryString += ' order by ' + parameters.sortExpression;
            queryString += ' ' + parameters.sortDirection;
            if (parameters.sortDirection != '') {
                queryString += ' NULLS LAST';
                if (parameters.sortExpression == 'Activity_Date_gne__c') {
                    queryString += ', LastModifiedDate ' + parameters.sortDirection;
                }
            }
        }
        return queryString;
    }

    public static List<CFAR_Trial_gne__c> getAccrualsTrialForReportsControler(CFAR_SearchParameters parameters) {
        String yearString = ' (\'' + String.valueof(Date.today().year()) + '\'';
        for (Integer i = 1; i <= 4; i++) {
            yearString = yearString + ',\'' + String.valueof(Date.today().year() + i) + '\'';
        }
        yearString = yearString + ') ';
        String queryString = 'Select id,name, frm_Genentech_Primary_Contact_ref_gne__c, Other_Trial_gne_Id__c, CTMS_gne__c ,Brief_Title_gne__c,frm_CFAR_WBS_ref_gne__c,CFAR_WBS_ref_gne__r.GSR_WBS_gne__c, CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c, Balance_gne__c, Total_Paid_gne__c, '
                + 'Investigator_ref_gne__c,frm_Investigator_ref_gne__c ,frm_General_Indication_ref_gne__c ,frm_Orginal_Amount_gne__c , frm_Amendment_Amount_gne__c,frm_Trial_Status_ref_gne__c ,Received_Date_gne__c ,Dollar_and_Drug_ref_gne__r.Name ,Planned_Enrollment_gne__c , '
                + 'Enrolled_Sum_rollup_gne__c ,frm_Current_Amount_gne__c, frm_Trial_Type_ref_gne__c, ' +
                +'(Select id, name, Actual_gne__c, Projected_Accrual_gne__c, CFAR_Year_gne__c from CFAR_Projected_Subject_Accrual__r where CFAR_Year_gne__c >= ' + Date.today().year() + ' AND CFAR_Year_gne__c <= ' + (Date.today().year() + 4) + ' order by CFAR_Year_gne__c), ' +
                +'(select Actual_Date_gne__c from CFAR_Milestone_Activities__r where Name = \'Activation\' order by createddate desc limit 1), ' +
                +'(Select Id, Quarter_1_gne__c, Quarter_2_gne__c, Quarter_3_gne__c, Quarter_4_gne__c, Comments_gne__c, Year_gne__c, Total_Paid_gne__c, frm_Total_Amount_gne__c from CFAR_Budget_Projections__r where Year_gne__c in ' + yearString + ' order by Year_gne__c asc) ' +
                +'from CFAR_Trial_gne__c';
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getProgramSummaryTrialForReportsControler(CFAR_SearchParameters parameters) {
        String queryString = 'Select Id,Name,Regimen_gne__c,Title_gne__c,Other_Trial_gne_Id__c,MSL_ref_gne__c,Investigator_ref_gne__c,Investigator_State_Province_gne__c,frm_Product_ref_gne__c,Investigator_Institution_Company_gne__c,Investigator_City_gne__c,frm_General_Indication_ref_gne__c,frm_Trial_Status_ref_gne__c,Other_GNE_Agents_ref_gne__c,CFAR_WBS_ref_gne__r.Name,Planned_Enrollment_gne__c,CFAR_General_Indication_ref_gne__r.Name,frm_MSL_ref_gne__c,frm_Investigator_ref_gne__c,Enrolled_Sum_rollup_gne__c,CTMS_gne__c,Trial_Status_ref_gne__r.Name, Dollar_and_Drug_ref_gne__r.Name, ' +
                +'(select Id, frm_Name_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c,frm_Function_Role_gne__c from CFAR_Team_Members__r where (frm_Function_Role_gne__c = \'MSD = Medical Science Director\' or frm_Function_Role_gne__c = \'MSL = Medical Science Liaison\' or frm_Function_Role_gne__c = \'PI = Primary (or Principal) Investigator\') and frm_Is_Inactive_gne__c = false) from CFAR_Trial_gne__c ';
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getBudgetSummaryTrialForReportsControler(CFAR_SearchParameters parameters) {
        String yearString = ' (\'' + String.valueof(Date.today().year()) + '\'';
        for (Integer i = 1; i <= 4; i++) {
            yearString = yearString + ',\'' + String.valueof(Date.today().year() + i) + '\'';
        }
        yearString = yearString + ') ';
        String queryString = 'Select Id,Name, frm_Genentech_Primary_Contact_ref_gne__c, Regimen_gne__c,Title_gne__c,Other_Trial_gne_Id__c,Investigator_State_Province_gne__c,'
                + 'frm_Product_ref_gne__c,Investigator_Institution_Company_gne__c,Investigator_City_gne__c,frm_General_Indication_ref_gne__c,'
                + 'frm_Trial_Status_ref_gne__c,Other_GNE_Agents_ref_gne__c,CFAR_WBS_ref_gne__r.GSR_WBS_gne__c,CFAR_WBS_ref_gne__r.Name,CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c,Planned_Enrollment_gne__c,'
                + 'CFAR_General_Indication_ref_gne__r.Name,frm_MSL_ref_gne__c,Investigator_ref_gne__c,frm_Investigator_ref_gne__c,Enrolled_Sum_rollup_gne__c,'
                + 'CTMS_gne__c,Trial_Status_ref_gne__r.Name, frm_Trial_Type_ref_gne__c, '
                + '(Select id, name, Actual_gne__c, Projected_Accrual_gne__c, CFAR_Year_gne__c from CFAR_Projected_Subject_Accrual__r where CFAR_Year_gne__c >= ' + Date.today().year() + ' AND CFAR_Year_gne__c <= ' + (Date.today().year() + 4) + ' order by CFAR_Year_gne__c), ' +
                +'(select Quarter_1_gne__c, Quarter_2_gne__c, Quarter_3_gne__c, Quarter_4_gne__c, Year_gne__c, Total_Paid_gne__c, frm_Total_Amount_gne__c from CFAR_Budget_Projections__r where Year_gne__c in ' + yearString + ' order by Year_gne__c asc), '
                + '(select Id, frm_Function_Role_gne__c, frm_Name_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c from CFAR_Team_Members__r where (frm_Function_Role_gne__c IN (\'PI = Primary (or Principal) Investigator\', \'CSA = Clinical Study Associate\') and frm_Is_Inactive_gne__c = false) or (frm_Function_Role_gne__c = \'CSM = Clinical Study Manager\' and Is_Trial_Primary_Contact_gne__c = true)) from CFAR_Trial_gne__c ';
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getPaymentsTrialForReportsControler(CFAR_SearchParameters parameters) {
        String queryString = 'Select Id,Name, frm_Genentech_Primary_Contact_ref_gne__c, Regimen_gne__c,Title_gne__c,Other_Trial_gne_Id__c,Investigator_State_Province_gne__c,'
                + 'frm_Product_ref_gne__c,Investigator_Institution_Company_gne__c,Investigator_City_gne__c,frm_General_Indication_ref_gne__c,'
                + 'frm_Trial_Status_ref_gne__c,Other_GNE_Agents_ref_gne__c,CFAR_WBS_ref_gne__r.GSR_WBS_gne__c,CFAR_WBS_ref_gne__r.Name,CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c,Planned_Enrollment_gne__c,'
                + 'CFAR_General_Indication_ref_gne__r.Name,frm_MSL_ref_gne__c,frm_Investigator_ref_gne__c,Enrolled_Sum_rollup_gne__c,'
                + 'CTMS_gne__c,Trial_Status_ref_gne__r.Name, frm_Trial_Type_ref_gne__c, '
                + '(select frm_Name_gne__c, frm_Function_Role_gne__c from CFAR_Team_Members__r where (frm_Function_Role_gne__c = \'CSA = Clinical Study Associate\' and frm_Is_Inactive_gne__c = false) or (frm_Function_Role_gne__c = \'CSM = Clinical Study Manager\' and Is_Trial_Primary_Contact_gne__c = true))'
                + ' from CFAR_Trial_gne__c ';
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getInfrepTrialForReportsControler(CFAR_SearchParameters parameters) {
        String queryString = 'Select Name, Other_GNE_Agents_Multi_gne__c, IMP_Shipped_Multi_gne__c,(Select frm_IMP_Shipped_Generic__c FROM gSTARS_Trial_IMP_Shipped__r), Therapeutic_Area_ref_gne__r.Name, frm_Genentech_Primary_Contact_ref_gne__c, Brief_title_gne__c, Regimen_gne__c,Title_gne__c,Other_Trial_gne_Id__c,Investigator_State_Province_gne__c,frm_Product_ref_gne__c,Investigator_Institution_Company_gne__c,Investigator_City_gne__c, Investigator_ref_gne__r.First_Address_Address_gne__c, Investigator_ref_gne__r.First_Address_Department_Division_gne__c, Investigator_ref_gne__r.First_Address_Zip_Postal_Code_gne__c, frm_General_Indication_ref_gne__c, frm_Trial_Status_ref_gne__c, Other_GNE_Agents_ref_gne__r.Name, Other_Agents_gne__c,CFAR_WBS_ref_gne__r.Name,Planned_Enrollment_gne__c,CFAR_General_Indication_ref_gne__r.Name,MSL_ref_gne__c,frm_MSL_ref_gne__c,frm_Investigator_ref_gne__c,Enrolled_Sum_rollup_gne__c,CTMS_gne__c,Trial_Status_ref_gne__r.Name, Lab_Support_gne__c, frm_Trial_Type_ref_gne__c, Non_Interventional_gne__c, Impacts_gne__c, Tiering_gne__c, SRT_Team_ref_gne__r.Name, Product_ref_gne__r.Theme_ref_gne__r.Name, Dollar_and_Drug_ref_gne__r.Name, ' +
                +'(SELECT Actual_Date_gne__c, Baselined_Date_gne__c, CFAR_Trial_ref_gne__c, Comments_gne__c, Name, Planned_Date_gne__c, Actual_Date_Last_change_gne__c, Id FROM CFAR_Milestone_Activities__r  order by name), ' +
                +'(SELECT Active_gne__c, Activity_Date_gne__c, Comments_gne__c, CreatedDate, LastModifiedDate FROM CFAR_Comments__r where Active_gne__c = true ORDER BY Activity_Date_gne__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 1), ' +
                +'(select Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, frm_Function_Role_gne__c, frm_Name_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Department_Division_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c from CFAR_Team_Members__r where (frm_Function_Role_gne__c IN (\'CSS = Clinical Study Specialist\', \'MSL = Medical Science Liaison\', \'MSD = Medical Science Director\', \'PI = Primary (or Principal) Investigator\', \'CSA = Clinical Study Associate\', \'SRT = Study Review Team Chair\') and frm_Is_Inactive_gne__c = false) or (frm_Function_Role_gne__c = \'CSM = Clinical Study Manager\' and Is_Trial_Primary_Contact_gne__c = true)), '
                + '(select frm_Other_GNE_Agent_Generic_gne__c from gSTARS_Trial_Other_GNE_Agents__r order by frm_Other_GNE_Agent_Generic_gne__c), '
                + '(select CFAR_Specific_Indication_ref_gne__r.Name from gstars_Specific_Indications_for_Trial__r order by CFAR_Specific_Indication_ref_gne__r.Name)'
                + ' from CFAR_Trial_gne__c ';
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getBOMTrialForReportsControler(CFAR_SearchParameters parameters) {
        String queryString = 'Select Id,Name, Other_GNE_Agents_Multi_gne__c, Sub_Patient_Population_gne__c, Biomarker_Description_gne__c, Biomarker_Questions_gne__c, Brief_title_gne__c, Regimen_gne__c,Title_gne__c,Other_Trial_gne_Id__c,Investigator_State_Province_gne__c,frm_Product_ref_gne__c,Investigator_Institution_Company_gne__c,Investigator_City_gne__c, Investigator_ref_gne__r.First_Address_Address_gne__c, Investigator_ref_gne__r.First_Address_Department_Division_gne__c, Investigator_ref_gne__r.First_Address_Zip_Postal_Code_gne__c, frm_General_Indication_ref_gne__c, frm_Trial_Status_ref_gne__c, Other_GNE_Agents_ref_gne__r.Name, Other_Agents_gne__c,CFAR_WBS_ref_gne__r.Name,Planned_Enrollment_gne__c,CFAR_General_Indication_ref_gne__r.Name,MSL_ref_gne__c,frm_MSL_ref_gne__c,frm_Investigator_ref_gne__c,Enrolled_Sum_rollup_gne__c,CTMS_gne__c,Trial_Status_ref_gne__r.Name, Lab_Support_gne__c, frm_Trial_Type_ref_gne__c, Non_Interventional_gne__c, Impacts_gne__c, Tiering_gne__c, SRT_Team_ref_gne__r.Name, Product_ref_gne__r.Theme_ref_gne__r.Name, frm_Genentech_Primary_Contact_ref_gne__c, ' +
                +'(SELECT Actual_Date_gne__c, Baselined_Date_gne__c, CFAR_Trial_ref_gne__c, Comments_gne__c, Name, Planned_Date_gne__c, Actual_Date_Last_change_gne__c, Id FROM CFAR_Milestone_Activities__r  order by name), ' +
                +'(SELECT Active_gne__c, Activity_Date_gne__c, Comments_gne__c, CreatedDate, LastModifiedDate FROM CFAR_Comments__r where Active_gne__c = true ORDER BY Activity_Date_gne__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 1), ' +
                +'(select Id, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, frm_Function_Role_gne__c, frm_Name_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Department_Division_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c from CFAR_Team_Members__r where (frm_Function_Role_gne__c IN (\'MSL = Medical Science Liaison\', \'MSD = Medical Science Director\', \'PI = Primary (or Principal) Investigator\', \'CSA = Clinical Study Associate\', \'SRT = Study Review Team Chair\') and frm_Is_Inactive_gne__c = false) or (frm_Function_Role_gne__c = \'CSM = Clinical Study Manager\' and Is_Trial_Primary_Contact_gne__c = true)), '
                + '(select frm_Other_GNE_Agent_Generic_gne__c from gSTARS_Trial_Other_GNE_Agents__r order by frm_Other_GNE_Agent_Generic_gne__c), '
                + '(select CFAR_Specific_Indication_ref_gne__r.Name from gstars_Specific_Indications_for_Trial__r order by CFAR_Specific_Indication_ref_gne__r.Name)'
                + ' from CFAR_Trial_gne__c';
        parameters.andEqualsParameters.put('Lab_Support_gne__c', 'YES');
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getPublicationTrialForReportsControler(CFAR_SearchParameters parameters) {
        String queryString = 'Select Id, Name, frm_Genentech_Primary_Contact_ref_gne__c, Other_Trial_gne_Id__c, CTMS_gne__c, frm_Trial_Type_ref_gne__c, '
                + '(select frm_Name_gne__c, frm_Function_Role_gne__c from CFAR_Team_Members__r where (frm_Function_Role_gne__c = \'CSA = Clinical Study Associate\' and frm_Is_Inactive_gne__c = false) or (frm_Function_Role_gne__c = \'CSM = Clinical Study Manager\' and Is_Trial_Primary_Contact_gne__c = true)), '
                + '(SELECT Author_gne__c, CFAR_Trial_ref_gne__c, Source_gne__c, Date_Planned_gne__c, Date_Received_gne__c, Date_Published_gne__c, Id, Status_gne__c, Reviewed_By_GNE_Prior_to_Submission_gne__c FROM CFAR_Publications__r) from CFAR_Trial_gne__c ';
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getCommentsTrialForReportsControler(CFAR_SearchParameters parameters) {
        String queryString = 'Select Id, Name, Other_Trial_gne_Id__c, CTMS_gne__c, frm_Trial_Type_ref_gne__c, frm_Product_ref_gne__c, frm_Investigator_ref_gne__c, frm_Trial_Status_ref_gne__c, Investigator_ref_gne__c,Investigator_ref_gne__r.First_Address_Department_Division_gne__c,Investigator_ref_gne__r.First_Address_Address_gne__c,Investigator_City_gne__c,Investigator_State_Province_gne__c,Investigator_ref_gne__r.First_Address_Zip_Postal_Code_gne__c,'
                + '(select Id, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c,frm_Function_Role_gne__c, frm_Name_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Department_Division_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c from CFAR_Team_Members__r), '
                + '(select Id, Name, Created_By_CFAR_Contact_ref_gne__c, Created_By_CFAR_Contact_ref_gne__r.Search_Name__c, Activity_Date_gne__c, Comments_gne__c, Active_gne__c, Trial_Status_ref_gne__c, frm_Trial_Status_gne__c from CFAR_Comments__r WHERE Active_gne__c = true) '
                + ' from CFAR_Trial_gne__c ';
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getTrials(CFAR_SearchParameters parameters) {
        String queryString = 'SELECT Id, FPI_Actual_Date_gne__c, Payments_With_Invoice_Paid_Or_Cancelled__c , Study_Closure_Letter_Received_gne__c, Study_Closure_Received_Date_gne__c, IRB_Closure_Letter_Received_gne__c, IRB_Closure_Received_Date_gne__c, LPI_Actual_Date_gne__c, LPO_Actual_Date_gne__c, Enrollment_Completed_Num_gne__c,Enrollment_Discontinued_Num_gne__c,Enrollment_Enrolled_Num_gne__c, ' +
                'Contract_End_Date_gne__c, Received_Date_gne__c, MQAG_Execution_Attachment_Date__c, Name, Brief_Title_gne__c, Original_Contract_Execution_Date_gne__c, Latest_Comment_Date_gne__c, ' +
                'Baselined__c, CFAR_Rate_of_Accrual_gne__c,Number_Of_Months_Of_Enrollment__c,CFAR_Enrollment_Start_Date_gne__c,CFAR_Enrollment_End_Date_gne__c,CFAR_Actual_Enrollment_gne__c,CFAR_Actual_Centers_gne__c, ' +
                'Inclusive_Research_gne__c, Inclusive_Research_Description_gne__c, Investigator_ref_gne__c, Investigator_ref_gne__r.Name, Cost_Center_gne__c,Cost_Element_gne__c,Is_Budget_Straight_Line__c, ' +
                'Total_Withholding_gne__c, Prior_Years_Paid_gne__c,Balance_gne__c, Last_Amendment_Amount_gne__c, Milestones_Without_Actual_Date_gne__c, SRT_Team_ref_gne__c, SRT_Team_ref_gne__r.Name, ' +
                'Genentech_Primary_Contact_ref_gne__c, Genentech_Primary_Contact_ref_gne__r.Name,Regulatory_Document_Complete_Date_gne__c, IIS_Portal_RO_Number_gne__c,' +
                'frm_Specific_Indication_ref_gne__c,frm_General_Indication_ref_gne__c,frm_Trial_Status_ref_gne__c, SDEA_Required__c, Capability_Assessment_Required__c, MQAG_Execution_Date__c, IRB_Required_gne__c,Next_Payment_Due_gne__c,' +
                'frm_Product_ref_gne__c, Product_ref_gne__r.Theme_ref_gne__c, Product_ref_gne__r.Theme_ref_gne__r.Name,frm_Investigator_ref_gne__c, frm_Genentech_Primary_Contact_ref_gne__c,frm_MSL_ref_gne__c, ' +
                'CFAR_General_Indication_ref_gne__c, Trial_Status_ref_gne__c, Trial_Status_ref_gne__r.Name, Product_ref_gne__c, frm_CFAR_WBS_ref_gne__c, FSR_Required_gne__c,' +
                'CFAR_Specific_Indication_ref_gne__c,CFAR_WBS_ref_gne__c,CFAR_WBS_ref_gne__r.GSR_WBS_gne__c, Non_Interventional_gne__c, Interventional_Picklist_Comment__c, Other_Trial_gne_Id__c, Partnership_Multi_gne__c,' +
                'Planned_Enrollment_gne__c, Total_Study_Enrollment__c, Planned_Centers_gne__c, Dollar_to_Drug_gne__c, Trial_Type_gne__c ,frm_Is_Closed_gne__c,IRB_Renewal_Date_gne__c, Final_Study_Report_Received_gne__c, Final_Study_Report_Received_Date_gne__c, ' +
                'Type_of_Sample_ref_gne__c, Type_of_Sample_ref_gne__r.Name, Dollar_and_Drug_ref_gne__c, Dollar_and_Drug_ref_gne__r.Name, Other_GNE_Agents_ref_gne__r.Name, ' +
                'Title_gne__c, Regimen_gne__c, Lab_Support_gne__c, Therapy_Type_gne__c, IND_Exempt_Letter_Date_gne__c, IND_Required_gne__c, IND_gne__c, ' +
                'Vendor_gne__c, Other_GNE_Agents_ref_gne__c, Sample_Type_gne__c, Other_Agents_gne__c, Type_of_Sample_Other_gne__c, Subject_Type_Other_gne__c, Trial_Type_ref_gne__c, frm_Trial_Type_ref_gne__c, Therapeutic_Area_ref_gne__r.Name, ' +
                'MSL_ref_gne__c, MSL_ref_gne__r.Name, Subject_Type__c, Planned_Amount_gne__c, Has_Orginal_Amount_gne__c, frm_Orginal_Amount_gne__c, frm_Amendment_Amount_gne__c, frm_Current_Amount_gne__c, Has_Amendment_Amount_gne__c, ' +
                'Enrolled_Sum_rollup_gne__c, CTMS_gne__c,Frozen_Accruals_JSON_gne__c, Disease_Status_gne__c, General_Indication_Other_gne__c,Specific_Indication_Other_gne__c, ' +
                'CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c, (SELECT Cost_Center_Name__c, Cost_Center__c, Value__c FROM Cost_Centers_for_Trial__r),Line_of_Therapy_gne__c, Pediatric_Study_gne__c, Treatment_Duration_Text_gne__c, Treatment_Duration_Type_gne__c, Treatment_Duration_gne__c, Randomization_gne__c, Blinding_gne__c, Comparison_gne__c,Design_gne__c, Combination_gne__c, Study_Phase_Multi_gne__c, ' +
                'Line_of_Therapy_Other_gne__c, Disease_Status_Picklist_gne__c, Disease_Status_Other_gne__c, Biomarker_Selected_Population_gne__c, Biomarker_Description_gne__c, Sub_Patient_Population_gne__c, Ethnicity_Description_gne__c, Medical_Comorbidity_Description_gne__c, ' +
                'Sub_Patient_Population_Other_Desc_gne__c, Treatment_Refractory_Description_gne__c, Treatment_Sensitive_Description_gne__c, Other_GNE_Agents_Multi_gne__c, IMP_Shipped_Multi_gne__c, Specific_Indication_Multi_gne__c, General_Indication_Multi_gne__c, Original_Amount_gne__c, Current_Amount_gne__c, Year_to_Date_Paid_gne__c, Total_Paid_gne__c, Tiering_gne__c, IRES__c, Is_Legacy__c, Biomarker_Questions_gne__c ' +
                'FROM CFAR_Trial_gne__c';
        if (!CFAR_Utils.isCurrentUserAdmin()) setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getTrialsLessFields(CFAR_SearchParameters parameters) {
        String queryString = 'SELECT Id, Name, Other_Trial_gne_id__c, frm_Trial_Status_ref_gne__c, frm_Investigator_ref_gne__c, frm_Genentech_Primary_Contact_ref_gne__c, ' +
                'frm_MSL_ref_gne__c, Subject_Type__c, CTMS_gne__c, Title_gne__c ' +
                'FROM CFAR_Trial_gne__c';
        if (!CFAR_Utils.isCurrentUserAdmin()) setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c[] getTrialsForSelectOptionsList(CFAR_SearchParameters parameters) {
        String queryString = 'SELECT Id, Name FROM CFAR_Trial_gne__c';
        if (!CFAR_Utils.isCurrentUserAdmin()) setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 3999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Dollar_and_Drug_gne__c[] getGNESupportForSelectOptions(CFAR_SearchParameters parameters) {
        String queryString = 'SELECT Id, Name FROM CFAR_Dollar_and_Drug_gne__c';
        queryString += queryParametersString(parameters);
        queryString += ' limit 3999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Comment_gne__c[] getComments(CFAR_SearchParameters parameters, String trialId) {
        String queryString = 'select Id, Name, Created_By_CFAR_Contact_ref_gne__c, Created_By_CFAR_Contact_ref_gne__r.Search_Name__c, Activity_Date_gne__c, Comments_gne__c, Active_gne__c, Trial_Status_ref_gne__c, frm_Trial_Status_gne__c ' +
                'from CFAR_Comment_gne__c ' +
                'where CFAR_Trial_ref_gne__c = \'' + String.escapeSingleQuotes(trialId) + '\' ';
        queryString += queryParametersStringComments(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Milestone_Activity_gne__c[] getMilestoneActivitiesByTrialId(String trialId) {
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.andEqualsParameters.put('CFAR_Trial_ref_gne__c', trialId);
        parameters.sortDirection = 'asc';
        return getMilestoneActivities(parameters);
    }

    public static CFAR_Milestone_Activity_gne__c[] getMilestoneActivities(CFAR_SearchParameters parameters) {
        String queryString = 'select Actual_Date_gne__c, Baselined_Date_gne__c, Name, ' +
                'Comments_gne__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, ' +
                'Planned_Date_gne__c, Id, sfdc_Type_gne__c,CFAR_Trial_ref_gne__c ' +
                'from CFAR_Milestone_Activity_gne__c ';
        queryString += queryParametersString(parameters);

        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Actual_Enrollment_gne__c[] getTrialsActualEnrollments(List<String> trialIds) {
        CFAR_SearchParameters parms = new CFAR_SearchParameters();
        parms.andInParameters = new Map<String, List<String>>{
                'CFAR_Trial_ref_gne__c' => trialIds
        };
        return getActualEnrollments(parms);
    }

    public static CFAR_Actual_Enrollment_gne__c[] getActualEnrollmentsByTrialId(String trialId) {
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.andEqualsParameters.put('CFAR_Trial_ref_gne__c', trialId);
        parameters.sortExpression = 'Date_gne__c';
        parameters.sortDirection = 'asc';
        return getActualEnrollments(parameters);
    }

    public static CFAR_Actual_Enrollment_gne__c[] getActualEnrollments(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Completed_Trial_Num_gne__c, Date_gne__c, Discontinued_Num_gne__c, Enrolled_Num_gne__c,In_Follow_Up_Num_gne__c, createddate, CFAR_Trial_ref_gne__c, This_Years_Accrual_is_frozen_gne__c  ' +
                'from CFAR_Actual_Enrollment_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo('getActualEnrollments: ' + queryString);
        return Database.query(queryString);
    }

    public static CFAR_Actual_Enrollment_gne__c getActualEnrollmentsById(id enrollmentId) {
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.andEqualsParameters.put('id', enrollmentId);
        CFAR_Actual_Enrollment_gne__c[] accruals = getActualEnrollments(parameters);
        return accruals.size() == 0 ? null : accruals[0];
    }

    public static CFAR_Publication_gne__c getPubicationById(String publicationId) {
        CFAR_SearchParameters parms = new CFAR_SearchParameters();
        parms.andEqualsParameters.put('id', publicationId);
        CFAR_Publication_gne__c[] publications = getPubications(parms);
        return (publications.size() == 0) ? null : publications[0];
    }

    public static CFAR_Publication_gne__c[] getPubicationsBytrialId(String trialId) {
        CFAR_SearchParameters parms = new CFAR_SearchParameters();
        parms.andEqualsParameters.put('CFAR_Trial_ref_gne__c', trialId);
        return getPubications(parms);
    }

    public static CFAR_Publication_gne__c[] getPubications(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name,Author_gne__c, Date_Published_gne__c, Date_Received_gne__c, Source_gne__c, Status_gne__c, Reviewed_By_GNE_Prior_to_Submission_gne__c, Date_Planned_gne__c ' +
                'from CFAR_Publication_gne__c ';
        queryString += queryParametersString(parameters);

        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Projected_Subject_Accrual_gne_ref__c[] getAccrualRelatedToTrial(String trialId) {
        return getAccrualRelatedToTrials(new List<String>{
                trialId
        });
    }

    public static List<CFAR_Projected_Subject_Accrual_gne_ref__c> getAccrualRelatedToTrials(List<String> trialIds) {
        CFAR_SearchParameters parms = new CFAR_SearchParameters();
        parms.andInParameters = new Map<String, List<String>>{
                'CFAR_Trial_ref_gne__c' => (List<String>) trialIds
        };
        parms.sortExpression = ' CFAR_Year_gne__c ';
        parms.sortDirection = ' asc ';
        return CFAR_DAO.getAccruals(parms) ;
    }

    public static CFAR_Projected_Subject_Accrual_gne_ref__c[] getAccruals(CFAR_SearchParameters parameters) {
        String queryString = 'select Projected_Accrual_gne__c, Actual_gne__c, Name, CFAR_Trial_ref_gne__c, Id, CFAR_Year_gne__c,    Trials_Frozen_Accrual_Years_JSON_gne__c  ' +
                'from CFAR_Projected_Subject_Accrual_gne_ref__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Budget_Contract_Tracking_gne__c[] getBudgetContractTrackings(CFAR_SearchParameters parameters) {
        //DONE: ITERATION2
        String queryString = 'select Id, Name, Amount_gne__c, Contract_Requested_Date__c, Comments_gne__c, Contract_Expiry_Date_gne__c, Variance_gne__c, Budget_contract_ref_gne__c, ' +
                'Contract_ID_gne__c, Fully_Executed_Date_gne__c, Type_ref_gne__c, Type_ref_gne__r.Name, Amendment_Number_gne__c,frm_sfdc_Completed_gne__c, Frm_Trial_Id_gne__c ' +
                'from CFAR_Budget_Contract_Tracking_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Rate_Table_gne__c[] getRateTables(CFAR_SearchParameters parameters) {
        //DONE: ITERATION2 MultiContract
        String queryString = 'SELECT Status_gne__c, Total_Type_gne__c, Sum_Total_Amount_gne__c, Sum_Remaining_Balance_gne__c, Sum_Remaining_Units_gne__c, Remaining_Balance_gne__c , Remaining_Units_gne__c, ' +
                'PI_Sub_I_Name_gne__c, Comments_gne__c, Contract_Term_gne__c, Cost_gne__c, Net_Cost_gne__c, Net_Unit_Cost_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, Payment_Type_gne__c, Name, Id, ' +
                'SystemModstamp, Total_Amount_gne__c, Total_Paid_Amount_gne__c, Unit_gne__c, WithHold_Type_gne__c, WithHold_Value_gne__c, WithHold_Amount_gne__c, Remaining_Withholding_Units_gne__c ' +
                'FROM CFAR_Rate_Table_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Budget_CPS_Payments_gne__c[] getPayments(CFAR_SearchParameters parameters) {
        //DONE: ITERATION2 MultiContract
        String queryString = 'select Id, Name, Check_Num_gne__c, Comments_gne__c, frm_Investigator_ref_gne__c, ' +   //DONE: ITERATION2 deleted field Investigator_ref_gne__c - seems like it's unused
                'Invoice_gne__c, Invoice_Amount_gne__c, Invoice_Date_gne__c, Invoice_Submitted_Date_gne__c, Line_Num_gne__c, ' +
                'Paid_On_gne__c, Payment_Explanation_Text_gne__c, Payment_Status_ref_gne__c, Payment_Status_ref_gne__r.Name, Planned_Amount_gne__c, Planned_Date_gne__c, frm_sfdc_Completed_gne__c, ' +
                'frm_Trial_Id_gne__c, Rate_Table_ref_gne__c, Rate_Table_ref_gne__r.PI_Sub_I_Name_gne__c, Withhold_Indicator_gne__c ' +
                'from CFAR_Budget_CPS_Payments_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Budget_CPS_Projection_gne__c[] getProjections(CFAR_SearchParameters parameters, String trialId) {
        String queryString = 'select Id, Name, Quarter_1_gne__c, Quarter_2_gne__c, Quarter_3_gne__c, Quarter_4_gne__c, ' +
                'frm_Total_Amount_gne__c, Total_Paid_gne__c, frm_Total_Remaining_Forecast_gne__c, Year_gne__c, Comments_gne__c, CFAR_Trial_ref_gne__c, CFAR_Trial_ref_gne__r.Is_Budget_Straight_Line__c ' +
                'from CFAR_Budget_CPS_Projection_gne__c where CFAR_Trial_ref_gne__c =\'' + String.escapeSingleQuotes(trialId) + '\' ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_General_Indication_gne__c [] getGeneralIndications(CFAR_SearchParameters parameters) {
        return Database.query(getGeneralIndicationsQueryString(parameters));
    }

    private static String getGeneralIndicationsQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, CreatedById, CreatedDate, IsDeleted, IsLocked, LastModifiedById,  ' +
                'LastModifiedDate, MayEdit, OwnerId, SystemModstamp, Active_gne__c from CFAR_General_Indication_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static CFAR_General_Indication_gne__c [] getGeneralIndicationsForSelectOptions(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name from CFAR_General_Indication_gne__c ';

        queryString += queryParametersString(parameters);

        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static Set<String> getGeneralIndicationsByTherapeuticArea(String ta) {
        List<CFAR_Indication_for_Therapeutic_Area_gne__c> indications = new List<CFAR_Indication_for_Therapeutic_Area_gne__c>();
        Set<String> stringIndications = new Set<String>();
        String queryString = 'select General_Indication_gne__c from CFAR_Indication_for_Therapeutic_Area_gne__c where Therapeutic_Area_gne__c like \'' + ta + '\'';
        system.debug(queryString);
        indications = Database.query(queryString);
        for (CFAR_Indication_for_Therapeutic_Area_gne__c i : indications) {
            stringIndications.add(i.General_Indication_gne__c);
        }
        system.debug(stringIndications);
        return stringIndications;
    }

    public static Set<String> getSpecificIndicationsByTherapeuticAreaGeneralIndication(String ta, List<String> gi) {
        Set<String> giSet = new Set<String>(gi);
        List<CFAR_Indication_for_Therapeutic_Area_gne__c> indications = [
                SELECT Specific_Indication_gne__c
                FROM CFAR_Indication_for_Therapeutic_Area_gne__c
                WHERE Therapeutic_Area_gne__c LIKE :ta AND General_Indication_gne__c IN :giSet
        ];
        Set<String> stringIndications = new Set<String>();
        for (CFAR_Indication_for_Therapeutic_Area_gne__c i : indications) {
            stringIndications.add(i.Specific_Indication_gne__c);
        }
        return stringIndications;
    }

    public static List<String> getSelectedGeneralIndicationNames(List<String> generalIndications) {
        Set<String> indicationSet = new Set<String>(generalIndications);
        List<CFAR_General_Indication_gne__c> gi = [SELECT Id, Name FROM CFAR_General_Indication_gne__c WHERE Id IN :indicationSet];
        List<String>giNames = new List<String>();
        for (CFAR_General_Indication_gne__c ind : gi) {
            giNames.add(ind.Name);
        }
        return giNames;
    }


    public static CFAR_Specific_Indication_gne__c [] getSpecificIndications(CFAR_SearchParameters parameters) {
        return Database.query(getSpecificIndicationsQueryString(parameters));
    }

    private static String getSpecificIndicationsQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name,  Active_gne__c from CFAR_Specific_Indication_gne__c ';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static CFAR_Specific_Indication_gne__c [] getSpecificIndicationsForSelectOptions(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name from CFAR_Specific_Indication_gne__c ';

        queryString += queryParametersString(parameters);

        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_Type_gne__c [] getTrialTypes(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c' +
                ' from CFAR_Trial_Type_gne__c';

        queryString += queryParametersString(parameters);

        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_Status_gne__c [] getTrialStatuses(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c' +
                ' from CFAR_Trial_Status_gne__c';

        queryString += queryParametersString(parameters);

        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static Database.QueryLocator getUnitTypeQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getUnitTypeQueryString(parameters));
    }

    private static String getUnitTypeQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c' +
                ' from CFAR_Unit_Type_gne__c';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static Database.QueryLocator getPartnershipQL(CFAR_SearchParameters parameters) {
        return Database.getQueryLocator(getPartnershipQueryString(parameters));
    }

    public static Database.QueryLocator getSRTTeamQL(CFAR_SearchParameters parameters) {
        parameters.andEqualsParameters.put('RecordTypeId', SRT_TEAM_PICKLIST_VALUE_RECORDTYPEID);
        return Database.getQueryLocator(getSRTTeamQueryString(parameters));
    }

    private static String getPartnershipQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c' +
                ' from CFAR_Partnership_gne__c';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    private static String getSRTTeamQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c' +
                ' from CFAR_Picklist_Value_gne__c';
        parameters.andEqualsParameters.put('RecordTypeId', SRT_TEAM_PICKLIST_VALUE_RECORDTYPEID);
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static CFAR_Therapeutic_Area_gne__c [] getTherapeuticAreas(CFAR_SearchParameters parameters) {
        return Database.query(getTherapeuticAreasQueryString(parameters));
    }

    private static String getTherapeuticAreasQueryString(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c' +
                ' from CFAR_Therapeutic_Area_gne__c';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return queryString;
    }

    public static CFAR_Type_of_Sample_gne__c [] getTypeOfSample(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c' +
                ' from CFAR_Type_of_Sample_gne__c';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Picklist_Value_gne__c [] getSRTTeams() {
        return [SELECT ID, Name, Active_gne__c FROM CFAR_Picklist_Value_gne__c WHERE RecordType.Name = 'SRT Team' ORDER BY Name LIMIT 1000];
    }

    public static CFAR_Picklist_Value_gne__c [] getImpacts() {
        return [SELECT ID, Name, Active_gne__c FROM CFAR_Picklist_Value_gne__c WHERE RecordType.Name = 'Impact' AND Active_gne__c = true ORDER BY Name LIMIT 1000];
    }

    public static CFAR_Dollar_and_Drug_gne__c [] getDollarAndDrug(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, Active_gne__c' +
                ' from CFAR_Dollar_and_Drug_gne__c';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static List<CFAR_Dollar_and_Drug_gne__c> getDollarAndDrugActive() {
        return [SELECT Id, Name FROM CFAR_Dollar_and_Drug_gne__c WHERE Active_gne__c = true order by Name asc];
    }

    public static CFAR_Trial_gne__c [] getTrialsForRegDocReport(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name, CTMS_gne__c, frm_Investigator_ref_gne__c, Other_Trial_gne_Id__c,' +
                ' frm_Genentech_Primary_Contact_ref_gne__c, Investigator_Institution_Company_gne__c, Dollar_and_Drug_ref_gne__c, Dollar_and_Drug_ref_gne__r.Name, frm_Trial_Status_ref_gne__c, Contract_End_Date_gne__c, IND_gne__c, IND_Exempt_Letter_Date_gne__c, IND_Required_gne__c,' +
                ' CFAR_Enrollment_End_Date_gne__c, Investigator_City_gne__c, Investigator_State_Province_gne__c, Investigator_ref_gne__r.First_Address_Address_gne__c, Investigator_ref_gne__r.First_Address_Department_Division_gne__c, Investigator_ref_gne__r.First_Address_Zip_Postal_Code_gne__c,' +
                ' Investigator_ref_gne__r.Phone_gne__c, Investigator_ref_gne__r.Fax_gne__c, Investigator_ref_gne__r.Email_gne__c, Investigator_ref_gne__c,' +
                ' (select Id, frm_Regulatory_Tracking_Activity_gne__c, Date_Received_gne__c, Expiry_Date_gne__c, Comments2_gne__c, Reg_Doc_Investigator_gne__c, Reg_Doc_Investigator_gne__r.frm_Name_gne__c, Reg_Doc_Investigator_gne__r.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c from CFAR_Regulatory_Document_Trackings__r order by Date_Received_gne__c asc NULLS first),' +
                ' (select Actual_Date_gne__c from CFAR_Milestone_Activities__r where Name = \'Activation\' limit 1),' +
                ' (select Id, Dollar_and_Drug_ref_gne__r.Name, Contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name, frm_Function_Role_gne__c, frm_Name_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, frm_Is_Inactive_gne__c from CFAR_Team_Members__r where frm_Function_Role_gne__c in (\'PI = Primary (or Principal) Investigator\', \'Sub-I = Sub-investigator\') OR (frm_Function_Role_gne__c = \'CSA = Clinical Study Associate\' AND frm_Is_Inactive_gne__c = false) order by frm_Function_Role_gne__c, frm_Name_gne__c)' +
                ' from CFAR_Trial_gne__c';
        parameters.sortExpression = 'CreatedDate';
        parameters.sortDirection = 'desc';
        addNullToNonPediatricStudyParam(parameters);
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' limit 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_gne__c [] getCommentsForRegDocReport(CFAR_SearchParameters parameters) {
        String queryString = 'select Id, Name,' +
                ' (select Id, frm_Regulatory_Tracking_Activity_gne__c, Comments2_gne__c from CFAR_Regulatory_Document_Trackings__r order by LastModifiedDate desc)' +
                ' from CFAR_Trial_gne__c';
        parameters.sortExpression = 'CreatedDate';
        parameters.sortDirection = 'desc';
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static CFAR_Trial_Type_of_Sample_gne__c [] getTrialTypeOfSampleRecords(Id trialId) {
        String queryString = 'select Id, Comments_gne__c, Type_of_Sample_ref_gne__c, frm_Type_of_Sample_ref_gne__c, Type_of_Sample_Other_gne__c' +
                ' from CFAR_Trial_Type_of_Sample_gne__c';
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.andEqualsParameters.put('CFAR_Trial_ref_gne__c', trialId);
        parameters.sortExpression = 'frm_Type_of_Sample_ref_gne__c';
        parameters.sortDirection = 'asc';
        queryString += queryParametersString(parameters);
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static Map<Id, String> getTypeOfSampleRecordsByTrial(List<String> trialIds) {
        Map<Id, String> resultMap = new Map<Id, String>();
        String queryString = 'select Id, Comments_gne__c, Type_of_Sample_ref_gne__c, frm_Type_of_Sample_ref_gne__c, Type_of_Sample_Other_gne__c, CFAR_Trial_ref_gne__c, CFAR_Trial_Type_of_Sample_gne__c.Name ' +
                ' from CFAR_Trial_Type_of_Sample_gne__c';
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.andInParameters.put('CFAR_Trial_ref_gne__c', trialIds);
        parameters.sortExpression = 'frm_Type_of_Sample_ref_gne__c';
        parameters.sortDirection = 'asc';
        queryString += queryParametersString(parameters);
        for (CFAR_Trial_Type_of_Sample_gne__c tos : Database.query(queryString)) {
            if (resultMap.containsKey(tos.CFAR_Trial_ref_gne__c)) {
                if (resultMap.get(tos.CFAR_Trial_ref_gne__c) != null) {
                    String temp = resultMap.get(tos.CFAR_Trial_ref_gne__c) + tos.frm_Type_of_Sample_ref_gne__c + ', ';
                    resultMap.put(tos.CFAR_Trial_ref_gne__c, temp);
                } else {
                    resultMap.put(tos.CFAR_Trial_ref_gne__c, tos.frm_Type_of_Sample_ref_gne__c + ', ');
                }
            } else {
                resultMap.put(tos.CFAR_Trial_ref_gne__c, tos.frm_Type_of_Sample_ref_gne__c + ', ');
            }
        }
        for (Id trialId : resultMap.keyset()) {
            resultMap.put(trialId, resultMap.get(trialId).removeEnd(', '));
        }
        return resultMap;
    }

    public static CFAR_FinanceReport_DataModel.CFAR_Trial [] getTrialWrappersForFinanceReport(CFAR_SearchParameters parameters) {
        CFAR_FinanceReport_DataModel.CFAR_Trial [] trialWrappers = new CFAR_FinanceReport_DataModel.CFAR_Trial []{};
        Map<Id, List<CFAR_Budget_Contract_gne__c>> id2budgetContacts = fetchTrial2BudgetContacts(fetchBudgetContracts());
        List<CFAR_Trial_gne__c> trials = fetchTrialsForFinanceReport(parameters);
        for (CFAR_Trial_gne__c tg : trials) {
            CFAR_FinanceReport_DataModel.CFAR_Trial trial = new CFAR_FinanceReport_DataModel.CFAR_Trial(tg);
            if (id2budgetContacts.get(tg.Id) != null) {
                trial.contracts = id2budgetContacts.get(tg.Id);
            }
            trialWrappers.add(trial);
        }
        return trialWrappers;
    }

    private static List<CFAR_Budget_Contract_gne__c> fetchBudgetContracts() {
        return [
                SELECT Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c,
                        Team_Member_ref_gne__r.frm_Function_Role_gne__c,
                        Team_Member_ref_gne__r.Contact_Address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name,
                        frm_Investigator_Vendor_gne__c, PO_Number_gne__c, Amount_Left_to_Project_gne__c,
                        frm_Balance_gne__c, frm_Current_Amount_gne__c, Total_payments_gne__c,
                        (SELECT Fully_Executed_Date_gne__c, Contract_Expiry_Date_gne__c
                            FROM Budget_Contract_Trackings__r
                            WHERE frm_Type_gne__c != :CFAR_BudgetContractTrackingHelper.TYPE_CONTRACT_CANCELED
                            ORDER BY Contract_Expiry_Date_gne__c DESC NULLS LAST
                        ) FROM CFAR_Budget_Contract_gne__c
                        WHERE Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c != null
                        ORDER BY frm_Investigator_Vendor_gne__c];
    }

    private static Map<Id, List<CFAR_Budget_Contract_gne__c>> fetchTrial2BudgetContacts(List<CFAR_Budget_Contract_gne__c> budgetContacts) {
        Map<Id, List<CFAR_Budget_Contract_gne__c>> id2BudgetConts = new Map<Id, List<CFAR_Budget_Contract_gne__c>>();
        for (CFAR_Budget_Contract_gne__c bcg : budgetContacts) {
            Id trialId = bcg.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c;
            if (trialId != null) {
                if (id2BudgetConts.containsKey(trialId)) {
                    id2BudgetConts.get(trialId).add(bcg);
                } else {
                    id2BudgetConts.put(trialId, new List<CFAR_Budget_Contract_gne__c>{bcg});
                }
            }
        }
        return id2BudgetConts;
    }

    private static List<CFAR_Trial_gne__c> fetchTrialsForFinanceReport(CFAR_SearchParameters parameters) {
        addNullToNonPediatricStudyParam(parameters);
        String queryString =
                'SELECT Name, CreatedDate, frm_Product_ref_gne__c, Other_GNE_Agents_Multi_gne__c, Other_Trial_gne_Id__c, CTMS_gne__c, CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c, frm_CFAR_WBS_ref_gne__c, ' +
                        'frm_Trial_Status_ref_gne__c, Therapeutic_Area_ref_gne__r.Name, ' +
                        'Enrolled_Sum_rollup_gne__c, frm_General_Indication_ref_gne__c, frm_Current_Amount_gne__c, Theme_ref_gne__r.Theme_Name_gne__c, ' +
                        'Dollar_and_drug_ref_gne__r.Name, frm_MSL_ref_gne__c, frm_Trial_Type_ref_gne__c, Title_gne__c, ' +
                        'Other_Agents_gne__c, Regimen_gne__c, Non_Interventional_gne__c, Product_ref_gne__r.Theme_ref_gne__r.Name, ' +
                        'Planned_enrollment_gne__c, frm_Genentech_Primary_Contact_ref_gne__c, ' +
                        '(SELECT frm_Name_gne__c, frm_function_role_gne__c ' +
                        ' FROM CFAR_Team_Members__r ' +
                        ' WHERE Function_Role_gne__c IN  ( \'' + CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER + '\', \'' + CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE + '\') ' +
                        ' AND frm_Is_Inactive_gne__c = false ), ' +
                        '(SELECT frm_Other_GNE_Agent_Generic_gne__c FROM gSTARS_Trial_Other_GNE_Agents__r),' +
                        '(SELECT Name, Planned_Date_gne__c, Actual_Date_gne__c FROM CFAR_Milestone_Activities__r ORDER BY Planned_Date_gne__c), ' +
                        '(SELECT Quarter_1_gne__c, Quarter_2_gne__c, Quarter_3_gne__c, Quarter_4_gne__c, Total_Paid_gne__c, ' +
                        'frm_Total_Amount_gne__c, Year_gne__c ' +
                        ' FROM CFAR_Budget_Projections__r ' +
                        ' WHERE Year_gne__c != null order by Year_gne__c), ' +
                        '(SELECT CFAR_Specific_Indication_ref_gne__r.Name FROM gstars_Specific_Indications_for_Trial__r ), ' +
                        '(SELECT Comments_gne__c FROM CFAR_Comments__r ORDER BY Activity_Date_gne__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 1), ' +
                        '(SELECT Cost_Center_Name__c, Value__c FROM Cost_Centers_for_Trial__r) ' + 
                        'FROM CFAR_Trial_gne__c';

        parameters.sortExpression = 'Therapeutic_Area_ref_gne__r.Name, frm_Product_ref_gne__c, frm_CFAR_WBS_ref_gne__c';
        parameters.sortDirection = 'ASC';
        setParamsWithNotInTrailStatusAdminFix(parameters);
        queryString += queryParametersString(parameters);
        queryString += ' LIMIT 9999';
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static List<String> getTrialIdsForContactsInRole(String role, String contacts) {
        Set<String> resultSet = new Set<String>();
        if (role == 'CSM = Clinical Study Manager') {
            for (CFAR_Trial_gne__c trial : [SELECT Id FROM CFAR_Trial_gne__c WHERE Genentech_Primary_Contact_ref_gne__c in :contacts.split(',', -1)]) {
                resultSet.add(trial.Id);
            }
        } else if (role == 'MSL = Medical Science Liaison') {
            for (CFAR_Trial_gne__c trial : [SELECT Id FROM CFAR_Trial_gne__c WHERE MSL_ref_gne__c in :contacts.split(',', -1)]) {
                resultSet.add(trial.Id);
            }
        }
        for (CFAR_Team_Member_gne__c member : [SELECT CFAR_Trial_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE frm_Function_Role_gne__c = :role AND contact_address_ref_gne__r.CFAR_Contact_ref_gne__c IN :contacts.split(',', -1)]) {
            resultSet.add(member.CFAR_Trial_ref_gne__c);
        }
        return new List<String>(resultSet);
    }

    public static Map<Id, List<String>> getTrialToRoleForTrials(String role, List<CFAR_Trial_gne__c> trials) {
        Map<Id, List<String>> trialToRoleUsers = new Map<Id, List<String>>();
        for (CFAR_Team_Member_gne__c tm : [SELECT Id, frm_Name_gne__c, CFAR_Trial_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c IN :trials AND Function_Role_gne__c = 'BOM = Biomarker Operations Manager']) {
            if (trialToRoleUsers.containsKey(tm.CFAR_Trial_ref_gne__c)) {
                trialToRoleUsers.get(tm.CFAR_Trial_ref_gne__c).add(tm.frm_Name_gne__c);
            } else {
                trialToRoleUsers.put(tm.CFAR_Trial_ref_gne__c, new List<String>{tm.frm_Name_gne__c});
            }
        }
        return trialToRoleUsers;
    }

    public static void addNullToNonPediatricStudyParam(CFAR_SearchParameters parameters) {
        if (parameters.orEqualsParameters.containsKey('Pediatric_Study_gne__c') && new Set<String>(parameters.orEqualsParameters.get('Pediatric_Study_gne__c')).contains('No')) {
            parameters.orEqualsParameters.get('Pediatric_Study_gne__c').add('');
        }
    }

    public static List<CFAR_Picklist_Value_gne__c> getCFARPicklistValues(Id recordTypeId) {
        return [SELECT Id, Name FROM CFAR_Picklist_Value_gne__c WHERE RecordTypeId = :recordTypeId];
    }
}