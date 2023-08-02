public with sharing class EMS_GSD_Detail_Validation_Rules {

    public static Set<String> existingGsdDetails = new Set<String>();
    public static Boolean skipValidationRules = false;

    // Public
    public static boolean onBeforeInsert(List<EMS_GSD_Detail__c> triggerNew) {
        if (skipValidationRules) return false;

        fetchExistingGsdDetails(triggerNew);

        for (EMS_GSD_Detail__c gsdDetail : triggerNew) {
            if (validateRecord(gsdDetail)) {
                return true;
            }

            if (validateDuplicateGsdDetail(gsdDetail)) {

                gsdDetail.HCP_HCO_Name__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Recipient_Job_Title_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Institution_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Street_1_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Street_2_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.City_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Province_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Postal_Code_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Country_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Website_URL_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.GSD_Type_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Purpose_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Date_of_Request_Letter_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                gsdDetail.Request_Summary_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
                return true;
            }
        }
        return false;
    }


    public static boolean onBeforeUpdate(List<EMS_GSD_Detail__c> triggerNew) {
        if (skipValidationRules) return false;

        fetchExistingGsdDetails(triggerNew);

        for (EMS_GSD_Detail__c gsdDetail : triggerNew) {
            if (validateRecord(gsdDetail)) {
                return true;
            }
			/*if (validateDuplicateGsdDetail(gsdDetail)) {
				
				gsdDetail.HCP_HCO_Name__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);  
				gsdDetail.Recipient_Job_Title_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Institution_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Street_1_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Street_2_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.City_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Province_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Postal_Code_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Country_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Website_URL_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.GSD_Type_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Purpose_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Date_of_Request_Letter_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				gsdDetail.Request_Summary_gne__c.addError(System.Label.EMS_GSD_Detail_Already_Exists);
				return true;
			}*/
        }
        return false;
    }

    public static Boolean validateRecord(EMS_GSD_Detail__c gsdDetail) {
        if (validatePostalCode(gsdDetail)) {
            gsdDetail.Postal_Code_gne__c.addError(System.Label.Address_Invalid_Canada_Postal_Code);
            return true;
        }
        if (validateURL(gsdDetail)) {
            gsdDetail.Website_URL_gne__c.addError(System.Label.Invalid_URL);
            return true;
        }
        if (validateEmail(gsdDetail.Email_Address_gne__c)) {
            gsdDetail.Email_Address_gne__c.addError('Invalid email address');
            return true;
        }
        if (validateEmail(gsdDetail.Email_Address_Vendor_Signatory_gne__c)) {
            gsdDetail.Email_Address_Vendor_Signatory_gne__c.addError('Invalid email address');
            return true;
        }
        return false;
    }

    // Validation rules
    private static boolean validatePostalCode(EMS_GSD_Detail__c record) {
        String regExString = '[A-Z]\\d[A-Z]\\s\\d[A-Z]\\d';
        Pattern p = Pattern.compile(regExString);

        if (record.Postal_Code_gne__c != null) {
            Matcher matcher = p.matcher(record.Postal_Code_gne__c);

            if (!matcher.matches()) {
                return true;
            }
        }
        return false;
    }

    private static boolean validateURL(EMS_GSD_Detail__c record) {
        String regExString = '(^((http|https):)??(www[.])??([a-zA-Z0-9]|-)+?([.][a-zA-Z0-9(-|/|=|?)??]+?)+?)';
        Pattern p = Pattern.compile(regExString);

        if (record.Website_URL_gne__c != null) {
            Matcher matcher = p.matcher(record.Website_URL_gne__c);

            if (!matcher.matches()) {
                return true;
            }
        }
        return false;
    }

    private static Boolean validateEmail(String field) {
        String regExString = '(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+[.][a-zA-Z0-9-.]+$)';
        Pattern p = Pattern.compile(regExString);
        if (String.isNotBlank(field)) {
            Matcher matcher = p.matcher(field);

            if (!matcher.matches()) {
                return true;
            }
        }
        return false;
    }

    private static void fetchExistingGsdDetails(List<EMS_GSD_Detail__c> triggerNew) {
        for (EMS_GSD_Detail__c gsdDetail : [SELECT EMS_Event__c FROM EMS_GSD_Detail__c WHERE NOT (Id IN :triggerNew)]) {
            existingGsdDetails.add(gsdDetail.EMS_Event__c);
        }
    }

    private static boolean validateDuplicateGsdDetail(EMS_GSD_Detail__c record) {
        if (existingGsdDetails.contains(record.EMS_Event__c)) {
            return true;
        } else {
            existingGsdDetails.add(record.EMS_Event__c);
        }
        return false;
    }
}