/**
 * Utility class for various eBI operations.
 * @author Radek Krawiec and Wojciech Twardowski, Roche
 * @created 05/15/2013
 *
 * Test class: GNE_CM_EBI_Util_Test.cls
 */
public without sharing class GNE_CM_EBI_Util
{   
    public static final String EBI_PRODUCTS_envVar = 'GNE_CM_EBI_Products';
    public static final String EBI_PROFILES_envVar = 'GNE_CM_EBI_Profiles';
    public static final String EBI_BI_TASK_SUBJECTS_envVar = 'GNE_CM_EBI_BI_Task_Subjects';
    public static final String EBI_METHOD = 'eBI';
    public static final String MPS_INSTANT_BI_METHOD = 'MPS Instant BI';
    public static final String BLIZZARD_PRODUCTS_envVar = 'GNE_CM_EBI_BLIZZARD_PROD';
    
    // Plan Accumulators keys
    public static final String PA_PLAN_INDIVIDUAL_DEDUCTIBLE = 'plan individual deductible';
    public static final String PA_PLAN_INDIVIDUAL_DEDUCTIBLE_MET = 'plan individual deductible met';
    public static final String PA_PLAN_INDIVIDUAL_OOP_MAX = 'plan individual oop max';
    public static final String PA_PLAN_INDIVIDUAL_OOP_MET = 'plan individual oop met';
    public static final String PA_PLAN_FAMILY_DEDUCTIBLE = 'plan family deductible';
    public static final String PA_PLAN_FAMILY_DEDUCTIBLE_MET = 'plan family deductible met';
    public static final String PA_PLAN_FAMILY_OOP_MAX = 'plan family oop max';
    public static final String PA_PLAN_FAMILY_OOP_MET = 'plan family oop met';
    public static final String PA_PLAN_PATIENT_COST_SHARE = 'plan patient cost share';
    public static final String PA_PLAN_INSURER_COST_SHARE = 'plan insurer cost share';
    public static final String PA_PLAN_OFFICE_COPAY = 'plan office copay';
    public static final String PA_OUTPATIENT_SURGICAL_DEDUCTIBLE = 'outpt surg deductible';
    public static final String PA_OUTPATIENT_SURGICAL_DEDUCTIBLE_MET = 'outpt surg deductible met';
    public static final String PA_OUTPATIENT_HOSPITAL_DEDUCTIBLE = 'outpt hospital deductible';
    public static final String PA_OUTPATIENT_HOSPITAL_DEDUCTIBLE_MET = 'outpt hospital deductible met';
    public static final String PA_OUTPATIENT_SURGICAL_COPAY = 'outpt surgical copay';
    public static final String PA_OUTPATIENT_HOSPITAL_COPAY = 'outpt hospital copay';
    public static final String PA_SPEND_DOWN_EFFECTIVE_DATE = 'spend down effective date';
    public static final String PA_SPEND_DOWN_AMOUNT = 'spend down amount';
    public static final String PA_SPEND_DOWN_MET_DATE = 'spend down met date';
    public static final String PA_PLAN_OFFICE_COPAY_VALUE_EXCEPTION_046 = 'Multiple Found; click View Full Response to review all copays reported by the Payer. (046)';
    public static final String PA_PLAN_OFFICE_COPAY_VALUE_EXCEPTION_46 = 'Multiple Found; click View Full Response to review all copays reported by the Payer. (46)';
    
    // Rule Results keys
    public static final String RR_PRIOR_AUTHORIZATION_REQUIRED = 'prior auth required';
    public static final String RR_NOTIFICATION_REQUIRED = 'notification required';
    public static final String RR_MEDICAL_DOCUMENTATION_REQUIRED = 'medical documentation required';
    public static final String RR_PRE_DETERMINATION = 'pre-determination';
    public static final String RR_DEDUCTIBLE_APPLIES = 'deductible applies';
    public static final String RR_PATIENT_COST_SHARE_APPLIES = 'patient cost share applies';
    public static final String RR_OOP_MAX_APPLIES = 'oop max applies';
    public static final String RR_COPAY_APPLIES = 'copay applies';
    public static final String RR_BUY_AND_BILL_PERMITTED = 'buy and bill permitted';
    public static final String RR_SPECIALTY_PHARMACY = 'specialty pharmacy';
    public static final String RR_COB_BENEFIT_DESIGN_TYPE = 'cob benefit type';
    public static final String RR_BUY_AND_BILL_AND_SPECIALTY_PHARMACY_BENEFITS_DIFFERENCE = 'buy and bill and specialty pharmacy benefits difference';
        
    private static final Map<String,Schema.SobjectField> biFieldsMap = Schema.SObjectType.Benefit_Investigation_gne__c.fields.getMap();
    
    public static String biFieldLabel(String apiName, String customLabel)
    {
        return GNE_CM_EBI_Util.biFieldsMap.containsKey(apiName) ? GNE_CM_EBI_Util.biFieldsMap.get(apiName).getDescribe().getLabel() : customLabel;
    }
    
    public static String biFieldLabel(String apiName)
    {
        return GNE_CM_EBI_Util.biFieldLabel(apiName, null);
    }
    
    public static Set<String> ebiEligibleProducts {
        get {
        	/*
            if (GNE_CM_EBI_Util.ebiEligibleProducts == null) {
                GNE_CM_EBI_Util.ebiEligibleProducts = new Set<String>();
                for (Environment_Variables__c ev : GNE_CM_Environment_variable.get_envVariable(new Set<String>{GNE_CM_EBI_Util.EBI_PRODUCTS_envVar})) {
                    ebiEligibleProducts.add(ev.Value__c);
                }
            }
            return GNE_CM_EBI_Util.ebiEligibleProducts;
            */
            if (GNE_CM_EBI_Util.ebiEligibleProducts == null) {
                GNE_CM_EBI_Util.ebiEligibleProducts = new Set<String>();            
		        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
				for(GNE_CM_EBI_Products__c envVar : GNE_CM_EBI_Products__c.getAll().values()){
					if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
				    	ebiEligibleProducts.add(envVar.Value__c);
				    }
				}
            }
			return GNE_CM_EBI_Util.ebiEligibleProducts;
        }
        set;
    }
    
    public static Set<String> BlizzardProducts {
        get {
        	/*
            if (GNE_CM_EBI_Util.BlizzardProducts  == null) {
                GNE_CM_EBI_Util.BlizzardProducts  = new Set<String>();
                for (Environment_Variables__c ev : GNE_CM_Environment_variable.get_envVariable(new Set<String>{GNE_CM_EBI_Util.BLIZZARD_PRODUCTS_envVar})) {
                    BlizzardProducts.add(ev.Value__c);
                }
            }
            return GNE_CM_EBI_Util.BlizzardProducts;
            */
            if (GNE_CM_EBI_Util.BlizzardProducts  == null) {
                GNE_CM_EBI_Util.BlizzardProducts  = new Set<String>();
		        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
				for(GNE_CM_EBI_BLIZZARD_PROD__c envVar : GNE_CM_EBI_BLIZZARD_PROD__c.getAll().values()){
					if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
				    	BlizzardProducts.add(envVar.Value__c);
				    }
				}
            }
			return GNE_CM_EBI_Util.BlizzardProducts;
        }
        set;
    }
    
    public static Set<String> ebiEligibleProfiles {
        get {
        	/*
            if (GNE_CM_EBI_Util.ebiEligibleProfiles == null) {
                GNE_CM_EBI_Util.ebiEligibleProfiles = new Set<String>();
                for (Environment_Variables__c ev : GNE_CM_Environment_variable.get_envVariable(new Set<String>{GNE_CM_EBI_Util.EBI_PROFILES_envVar})) {
                    ebiEligibleProfiles.add(ev.Value__c);
                }
            }
            return GNE_CM_EBI_Util.ebiEligibleProfiles;
            */
            if (GNE_CM_EBI_Util.ebiEligibleProfiles == null) {
                GNE_CM_EBI_Util.ebiEligibleProfiles = new Set<String>();
		        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
				for(GNE_CM_EBI_Profiles__c envVar : GNE_CM_EBI_Profiles__c.getAll().values()){
					if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
				    	ebiEligibleProfiles.add(envVar.Value__c);
				    }
				}
            }
			return GNE_CM_EBI_Util.ebiEligibleProfiles;
        }
        set;
    }
    
    public static Set<String> ebiBiTaskSubjects {
        get {
        	/*
            if (GNE_CM_EBI_Util.ebiBiTaskSubjects == null) {
                GNE_CM_EBI_Util.ebiBiTaskSubjects = new Set<String>();
                for (Environment_Variables__c ev : GNE_CM_Environment_variable.get_envVariable(new Set<String>{GNE_CM_EBI_Util.EBI_BI_TASK_SUBJECTS_envVar})) {
                    ebiBiTaskSubjects.add(ev.Value__c);
                }
            }
            return GNE_CM_EBI_Util.ebiBiTaskSubjects;
            */
            if (GNE_CM_EBI_Util.ebiBiTaskSubjects == null) {
                GNE_CM_EBI_Util.ebiBiTaskSubjects = new Set<String>();
		        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
				for(GNE_CM_EBI_BI_Task_Subjects__c envVar : GNE_CM_EBI_BI_Task_Subjects__c.getAll().values()){
					if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
				    	ebiBiTaskSubjects.add(envVar.Value__c);
				    }
				}
            }
			return GNE_CM_EBI_Util.ebiBiTaskSubjects;
        }
        set;
    }
    
    public static Map<String,Schema.SObjectType> globalDescribe {
        get {
            if (GNE_CM_EBI_Util.globalDescribe == null) {
                GNE_CM_EBI_Util.globalDescribe = Schema.getGlobalDescribe();
            }
            return GNE_CM_EBI_Util.globalDescribe;
        }
        set;
    }
    
    public static Boolean isCaseEbiEligible(Case c, Id PayerId)
    {
        if (c == null ||
            c.Id == null ||
            c.Product_gne__c == null ||
            c.Product_gne__c.trim() == '' ||
            c.GNE_CM_MPS_IS_PAN_Valid__c == 'False' ||
            GNE_CM_EBI_Util.isProductEbiEligible(c.Product_gne__c) == false ||
            GNE_CM_EBI_Util.isProfileEbiEligible(UserInfo.getProfileId()) == false ||
            [SELECT COUNT() FROM Task WHERE WhatId = :c.Id AND Subject IN :GNE_CM_EBI_Util.ebiBiTaskSubjects AND Status <> 'Completed' AND IsDeleted = false ALL ROWS] == 0) {
            return false;
        }
        if (payerId == null && ([SELECT COUNT() FROM GNE_CM_EBI_Payer_Mapping__c WHERE Account_gne__c IN (SELECT Payer_gne__c FROM Insurance_gne__c WHERE Case_Insurance_gne__c = :c.Id)] == 0)) {
            return false;
        }
        else if (payerId != null && ([SELECT COUNT() FROM GNE_CM_EBI_Payer_Mapping__c WHERE Account_gne__c = :payerId] == 0)) {
            return false;
        }
        return true;
    }
    
    public static Boolean isCaseEbiEligible(Case c)
    {
        return GNE_CM_EBI_Util.isCaseEbiEligible(c, null);
    }
    
    public static Boolean isCaseEbiEligible(Id caseId, String product, Id payerId)
    {
        return GNE_CM_EBI_Util.isCaseEbiEligible(new Case(Id = caseId, Product_gne__c = product), payerId);
    }
    
    public static Boolean isCaseEbiEligible(Id caseId, String product)
    {
        return GNE_CM_EBI_Util.isCaseEbiEligible(caseId, product, null);
    }
    
    public static Boolean isProductEbiEligible(String productName)
    {
        if (productName == null) {
            return false;
        }
        return GNE_CM_EBI_Util.ebiEligibleProducts.contains(productName);
    }
    
    public static Boolean isBlizzardProduct(String productName)
    {
        if (productName == null) {
            return false;
        }
        return GNE_CM_EBI_Util.BlizzardProducts.contains(productName);
    }
    
    public static Boolean isProfileEbiEligible(String profileIdOrName)
    {
        String profileKeyPrefix = GNE_CM_EBI_Util.globalDescribe.get('Profile').getDescribe().getKeyPrefix();
        if (profileIdOrName.startsWithIgnoreCase(profileKeyPrefix)) {
            profileIdOrName = GNE_SFA2_Util.getCurrentUserProfileName();
        }
        return GNE_CM_EBI_Util.ebiEligibleProfiles.contains(profileIdOrName);
    }
    
    public static Boolean isEBIFlagVisibleForCurrentUser()
    {
        return ([SELECT COUNT() FROM Profile WHERE Id = :UserInfo.getProfileId() AND Name IN :GNE_CM_EBI_Util.ebiEligibleProfiles LIMIT 1] == 1);
    }
    
    public static GNE_CM_EBI_Payer_Mapping__c getPayerMapping (Id accountId)
    {
        List<GNE_CM_EBI_Payer_Mapping__c> mappings = [SELECT Id, TransEngen_Payer_Id_gne__c, TransEngen_Payer_Name_gne__c FROM GNE_CM_EBI_Payer_Mapping__c WHERE Account_gne__c = :accountId];
        
        if (mappings.size() > 1)
        {
            throw new GNE_CM_Exception('More than one payer mapping found for account Id = ' + accountId);
        }
        
        return mappings.isEmpty() ? null : mappings.get(0);
    }
    
    public static Map<Id,GNE_CM_EBI_Payer_Mapping__c> payerMappings(Set<Id> payerIds)
    {
        Map<Id,GNE_CM_EBI_Payer_Mapping__c> pms = new Map<Id,GNE_CM_EBI_Payer_Mapping__c>();
        for (GNE_CM_EBI_Payer_Mapping__c pm : [
            SELECT Id, Account_gne__c, TransEngen_Payer_Id_gne__c, TransEngen_Payer_Name_gne__c
            FROM GNE_CM_EBI_Payer_Mapping__c
            WHERE Account_gne__c IN :payerIds
        ]) {
            pms.put(pm.Account_gne__c, pm);
        }
        return pms;
    }

    public static List<GNE_CM_EBI_Plan_Payer_Mapping__c> planPayerMappings(List<PayerAndPlanPayerRecord> records)
    {
        String query = 'SELECT ID, Account_gne__c, Account_gne__r.Name, Plan_Account_gne__c, TransEngen_Payer_Id_gne__c, TransEngen_Payer_Name_gne__c' +
        ' FROM GNE_CM_EBI_Plan_Payer_Mapping__c' + ' WHERE';
        
        Integer r = 0;
        for(; r < records.size() - 1; r++)
        {
            query += ' (Account_gne__c = \'' + records.get(r).payerId + '\' AND Plan_Account_gne__c = \'' + records.get(r).planPayerId + '\') OR'; 
        }
        query += ' (Account_gne__c = \'' + records.get(r).payerId + '\' AND Plan_Account_gne__c = \'' + records.get(r).planPayerId + '\')';
        return (List<GNE_CM_EBI_Plan_Payer_Mapping__c>)Database.query(query);
    }
    
    // Tells if the given benefit investigation should be displayed as a Medicare Part D form
    public static Boolean isMedicarePartD (Benefit_Investigation_gne__c bi, String product)
    {
        Set<String> products = new Set<String>{'zelboraf', 'tarceva', 'erivedge', 'pegasys', 'actemra', 'rituxan ra', 'xolair'};
        Boolean isProduct = (products.contains(product.toLowerCase()));
        Boolean isMedPartD = (bi.BI_Insurance_gne__r.ins_eligible_for_Medicare_Part_D_gne__c == 'Yes');
        return isProduct && isMedPartD;
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // EBI Data Model utilities
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public static Map<String,String> adminCodes {
        get {
            if (GNE_CM_EBI_Util.adminCodes == null) {
                GNE_CM_EBI_Util.adminCodes = new Map<String,String>();
                for (GNE_CM_EBI_Admin_Code__c ac : [SELECT Id, Admin_Code_gne__c, Product_gne__c FROM GNE_CM_EBI_Admin_Code__c]) {
                    GNE_CM_EBI_Util.adminCodes.put(ac.Product_gne__c + '_' + ac.Admin_Code_gne__c, ac.Id);
                }
            }
            return GNE_CM_EBI_Util.adminCodes;
        }
        private set;
    }
    
    public static List<GNE_CM_EBI_Admin_Code_Request__c> createAdminCodeRequests(Id requestId, String productName, String fhCtp, String shCtp)
    {
        List<GNE_CM_EBI_Admin_Code_Request__c> adminCodeRequests = new List<GNE_CM_EBI_Admin_Code_Request__c>();
        if (requestId != null && productName != null && productName.trim() != '') {
            if (fhCtp != null && fhCtp.trim() != '') {
                String fhacKey = productName + '_' + fhCtp;
                if (GNE_CM_EBI_Util.adminCodes.containsKey(fhacKey)) {
                    adminCodeRequests.add(new GNE_CM_EBI_Admin_Code_Request__c(
                        EBI_Request_gne__c = requestId,
                        EBI_Admin_Code_gne__c = GNE_CM_EBI_Util.adminCodes.get(fhacKey)
                    ));
                }
            }
            if (shCtp != null && shCtp.trim() != '') {
                String shacKey = productName + '_' + shCtp;
                if (GNE_CM_EBI_Util.adminCodes.containsKey(shacKey)) {
                    adminCodeRequests.add(new GNE_CM_EBI_Admin_Code_Request__c(
                        EBI_Request_gne__c = requestId,
                        EBI_Admin_Code_gne__c = GNE_CM_EBI_Util.adminCodes.get(shacKey)
                    ));
                }
            }
        }
        return adminCodeRequests;
    }
    
    public static List<GNE_CM_EBI_Admin_Code_Request__c> createAdminCodeRequests(Id requestId, String productName, String fhCtp)
    {
        return GNE_CM_EBI_Util.createAdminCodeRequests(requestId, productName, fhCtp, null);
    }
    
    public static List<GNE_CM_EBI_Admin_Code_Request__c> createAdminCodeRequests(GNE_CM_EBI_Request__c r)
    {
        return GNE_CM_EBI_Util.createAdminCodeRequests(r.Id, r.Product_Name_gne__c, r.First_Hour_Tx_CPT_gne__c, r.Subsequent_Hours_CPT__c);
    }
    
    public static List<GNE_CM_EBI_Diagnosis_Code__c> createDiagnosisCodes(Id requestId, List<String> dCodes)
    {
        List<GNE_CM_EBI_Diagnosis_Code__c> diagnosisCodes = new List<GNE_CM_EBI_Diagnosis_Code__c>();
        if (requestId != null && !dCodes.isEmpty()) {
            Integer dCodesCount = dCodes.size();
            for (Integer i = 0; i < dCodesCount; i++) {
                if (dCodes[i] == null) {
                    continue;
                }
                diagnosisCodes.add(new GNE_CM_EBI_Diagnosis_Code__c(
                    Diagnosis_Code_gne__c = dCodes[i],
                    Diagnosis_Rank_gne__c = GNE_CM_EBI_Util.diagnosisRankIntegerToString(i + 1),
                    EBI_Request_gne__c = requestId
                ));
            }
        }
        return diagnosisCodes;
    }
    
    public static List<GNE_CM_EBI_Diagnosis_Code__c> createDiagnosisCodes(Id requestId, Medical_History_gne__c mh)
    {
        if (requestId == null || mh == null) {
            return new List<GNE_CM_EBI_Diagnosis_Code__c>();
        }
        List<String> dCodes = new List<String>();
        if (mh.ICD9_Code_1_gne__c != null) {
            dCodes.add(mh.ICD9_Code_1_gne__r.ICD9_Code_gne__c);
        }
        if (mh.ICD9_Code_2_gne__c != null) {
            dCodes.add(mh.ICD9_Code_2_gne__r.ICD9_Code_gne__c);
        }
        if (mh.ICD9_Code_3_gne__c != null) {
            dCodes.add(mh.ICD9_Code_3_gne__r.ICD9_Code_gne__c);
        }
        return GNE_CM_EBI_Util.createDiagnosisCodes(requestId, dCodes);
    }
    
    public static List<GNE_CM_EBI_Diagnosis_Code__c> createDiagnosisCodes(Id requestId, Patient_Enrollment_Request_gne__c per)
    {
        List<GNE_CM_EBI_Diagnosis_Code__c> diagnosisCodes = new List<GNE_CM_EBI_Diagnosis_Code__c>();
        if (requestId != null) {
            String perCode = GNE_CM_EBI_Util.resolvePERdiagnosisCode(per);
            if (perCode != null) {
                diagnosisCodes.add(new GNE_CM_EBI_Diagnosis_Code__c(
                    Diagnosis_Code_gne__c = perCode,
                    Diagnosis_Rank_gne__c = GNE_CM_EBI_Util.diagnosisRankIntegerToString(1),
                    EBI_Request_gne__c = requestId
                ));
            }
        }
        return diagnosisCodes;
    }
    
    public static GNE_CM_EBI_Payer__c createPayer(Id requestId, Insurance_gne__c insurance)
    {
        if (requestId == null || insurance == null) {
            return null;
        }
        GNE_CM_EBI_Payer_Mapping__c payerMapping = GNE_CM_EBI_Util.getPayerMapping(insurance.Payer_gne__c);
        if (payerMapping == null) {
            throw new GNE_CM_Exception('Payer with Id ' + insurance.Payer_gne__c + ' is not mapped');
        }

        String normalizedMemberId = Pattern.compile('[^0-9A-z]').matcher(insurance.Subscriber_Num_gne__c).replaceAll('');
        return new GNE_CM_EBI_Payer__c(
            Member_ID_gne__c = (normalizedMemberId != '' ? normalizedMemberId : null),
            Payer_gne__c = insurance.Payer_gne__c,
            Plan_Payer_gne__c = insurance.Plan_gne__c,
            Policy_Rank_gne__c = insurance.Rank_gne__c,
            Relationship_gne__c = insurance.Patient_Relationship_to_Subscriber_gne__c,
            Request_gne__c = requestId,
            Subscriber_DOB_gne__c = insurance.Subscriber_DOB_gne__c,
            Subscriber_First_Name_gne__c = insurance.Subscriber_First_Name_gne__c,
            Subscriber_Last_Name_gne__c = insurance.Subscriber_Name_gne__c,
            Subscriber_Member_ID_gne__c = (normalizedMemberId != '' ? normalizedMemberId : null),
            Subscriber_Middle_Name_gne__c = null
        );
    }
    
    /* deprecated
    public static GNE_CM_EBI_Payer__c createPayer(Id requestId, Patient_Enrollment_Request_gne__c per)
    {
        if (requestId == null || per == null) {
            return null;
        }
        GNE_CM_EBI_Payer_Mapping__c payerMapping = GNE_CM_EBI_Util.getPayerMapping(per.Primary_Payer_gne__c);
        if (payerMapping == null) {
            throw new GNE_CM_Exception('Payer with Id ' + per.Primary_Payer_gne__c + ' is not mapped');
        }
        String normalizedMemberId = Pattern.compile('[^0-9A-z]').matcher(per.PI_Subscriber_ID_gne__c).replaceAll('');
        return new GNE_CM_EBI_Payer__c(
            Member_ID_gne__c = (normalizedMemberId != '' ? normalizedMemberId : null),
            Payer_gne__c = per.Primary_Payer_gne__c,
            Plan_Payer_gne__c = per.Plan_Product_gne__c,
            Policy_Rank_gne__c = 'Primary',
            Relationship_gne__c = per.PI_Patient_Relationship_to_Subs_gne__c,
            Request_gne__c = requestId,
            Subscriber_DOB_gne__c = per.PI_Subscriber_DOB_gne__c,
            Subscriber_First_Name_gne__c = per.PI_Subscriber_First_Name_gne__c,
            Subscriber_Last_Name_gne__c = per.PI_Subscriber_Name_gne__c,
            Subscriber_Member_ID_gne__c = (normalizedMemberId != '' ? normalizedMemberId : null),
            Subscriber_Middle_Name_gne__c = null
        );
    }*/
    
    // ML/DP eServices COB
    public static List<GNE_CM_EBI_Payer__c> createPayers(Id requestId, Patient_Enrollment_Request_gne__c per)
    {
        if (requestId == null || per == null) {
            return null;
        }
        GNE_CM_EBI_Payer_Mapping__c primaryPayerMapping = GNE_CM_EBI_Util.getPayerMapping(per.Primary_Payer_gne__c);
        if (primaryPayerMapping == null) {
            throw new GNE_CM_Exception('Payer with Id ' + per.Primary_Payer_gne__c + ' is not mapped');
        }
        String primaryNormalizedMemberId = Pattern.compile('[^0-9A-z]').matcher(per.PI_Subscriber_ID_gne__c).replaceAll('');
        
        String secondaryNormalizedMemberId;
        if (per.Secondary_Payer_gne__c != null && String.valueOf(per.Secondary_Payer_gne__c) != '') {
            GNE_CM_EBI_Payer_Mapping__c secondaryPayerMapping = GNE_CM_EBI_Util.getPayerMapping(per.Secondary_Payer_gne__c);
            if (secondaryPayerMapping == null) {
                throw new GNE_CM_Exception('Payer with Id ' + per.Secondary_Payer_gne__c + ' is not mapped');
            }
            secondaryNormalizedMemberId = Pattern.compile('[^0-9A-z]').matcher(per.SI_Subscriber_ID_gne__c).replaceAll('');
        }
        
        // DP eServices COB
        Map<ID, ID> payerToPlanProduct = new Map<ID, ID>();
        Set<Id> findPlanProductByPayerId = new Set<Id>();
        if(per.Plan_Product_gne__c == null && per.Primary_Insurance_Carrier_Name_gne__c=='AARP')
        {
            findPlanProductByPayerId.add(per.Primary_Payer_gne__c);
        }
        else
        {
            payerToPlanProduct.put(per.Primary_Payer_gne__c, per.Plan_Product_gne__c);
        }
        
        if(per.Secondary_Payer_gne__c != null)
        {
            if(per.Plan_Product_gne__c == null)
            {
                findPlanProductByPayerId.add(per.Secondary_Payer_gne__c);
            }
            else
            {
                payerToPlanProduct.put(per.Secondary_Payer_gne__c, per.Plan_Product_gne__c);
            }
        }
        
        if(findPlanProductByPayerId.size() > 0)
        {
            List<GNE_CM_EBI_Plan_Payer_Mapping__c> planProductPayers = [
                SELECT Account_gne__c, Plan_Account_gne__c 
                FROM GNE_CM_EBI_Plan_Payer_Mapping__c 
                WHERE Account_gne__c IN :findPlanProductByPayerId
            ];

            for(GNE_CM_EBI_Plan_Payer_Mapping__c planProductPayer : planProductPayers)
            {
                payerToPlanProduct.put(planProductPayer.Account_gne__c, planProductPayer.Plan_Account_gne__c);
            }
        }

        system.debug('createPayers payerToPlanProduct is:' +payerToPlanProduct);
                
        List<GNE_CM_EBI_Payer__c> payers = new List<GNE_CM_EBI_Payer__c>();
        //primary payer
        payers.add(new GNE_CM_EBI_Payer__c(
            Member_ID_gne__c = (primaryNormalizedMemberId != '' ? primaryNormalizedMemberId : null),
            Payer_gne__c = per.Primary_Payer_gne__c,
            Plan_Payer_gne__c = payerToPlanProduct.get(per.Primary_Payer_gne__c),
            Policy_Rank_gne__c = 'Primary',
            Relationship_gne__c = per.PI_Patient_Relationship_to_Subs_gne__c,
            Request_gne__c = requestId,
            Subscriber_DOB_gne__c = per.PI_Subscriber_DOB_gne__c,
            Subscriber_First_Name_gne__c = per.PI_Subscriber_First_Name_gne__c,
            Subscriber_Last_Name_gne__c = per.PI_Subscriber_Name_gne__c,
            Subscriber_Member_ID_gne__c = (primaryNormalizedMemberId != '' ? primaryNormalizedMemberId : null),
            Subscriber_Middle_Name_gne__c = null
            )
        );
        //secondary payer
        if (per.Secondary_Payer_gne__c != null) {
            payers.add(new GNE_CM_EBI_Payer__c(
                Member_ID_gne__c = (secondaryNormalizedMemberId != '' ? secondaryNormalizedMemberId : null),
                Payer_gne__c = per.Secondary_Payer_gne__c,
                Plan_Payer_gne__c = payerToPlanProduct.get(per.Secondary_Payer_gne__c),
                Policy_Rank_gne__c = 'Secondary',
                Relationship_gne__c = per.SI_Patient_Relationship_to_Subs_gne__c,
                Request_gne__c = requestId,
                Subscriber_DOB_gne__c = per.SI_Subscriber_DOB_gne__c,
                Subscriber_First_Name_gne__c = per.SI_Subscriber_First_Name_gne__c,
                Subscriber_Last_Name_gne__c = per.SI_Subscriber_Name_gne__c,
                Subscriber_Member_ID_gne__c = (secondaryNormalizedMemberId != '' ? secondaryNormalizedMemberId : null),
                Subscriber_Middle_Name_gne__c = null
                )
            );
        }
        
        return payers;
    }
    
    public static GNE_CM_EBI_Request__c createRequest(Case c, String fhctp, String shctp, String npi, Date sdd, String sdl)
    {
        if (c == null) {
            return null;
        }
        return new GNE_CM_EBI_Request__c(
            Benefit_Investigation_Date_Time_gne__c = system.now(),
            Case_gne__c = c.Id,
            First_Hour_Tx_CPT_gne__c = fhctp,
            NPI_gne__c = npi,
            Patient_gne__c = c.Patient_gne__c,
            PER_gne__c = null,
            Prescriber_gne__c = c.Case_Treating_Physician_gne__c,
            Prescriber_First_Name_gne__c = c.Case_Treating_Physician_gne__r.FirstName,
            Prescriber_Last_Name_gne__c = c.Case_Treating_Physician_gne__r.LastName,
            Prescriber_State_gne__c = c.State_Treating_Physician_gne__c,
            Product_Name_gne__c = c.Product_gne__c,
            Requester_gne__c = UserInfo.getUserId(),
            Service_Delivery_Date_gne__c = sdd,
            Service_Delivery_Location_gne__c = sdl,
            Subsequent_Hours_CPT__c = shctp
        );
    }
    
    public static GNE_CM_EBI_Request__c createRequest(Patient_Enrollment_Request_gne__c per, Id caseId)
    {
        if (per == null) {
            return null;
        }
        return new GNE_CM_EBI_Request__c(
            Benefit_Investigation_Date_Time_gne__c = system.now(),
            Case_gne__c = caseId,
            First_Hour_Tx_CPT_gne__c = GNE_CM_EBI_Util.resolvePERadminCode(per),
            NPI_gne__c = per.Prescriber_NPI_gne__c,
            Patient_gne__c = per.Patient_gne__c,
            PER_gne__c = per.Id,
            Prescriber_gne__c = per.Prescriber_gne__c,
            Prescriber_First_Name_gne__c = per.Prescriber_First_Name_gne__c,
            Prescriber_Last_Name_gne__c = per.Prescriber_Name__c,
            Prescriber_State_gne__c = per.Prescriber_State_gne__c,
            Product_Name_gne__c = GNE_CM_EBI_Util.resolvePERproductName(per),
            Requester_gne__c = UserInfo.getUserId(),
            Service_Delivery_Date_gne__c = system.today(),
            Service_Delivery_Location_gne__c = GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per),
            Subsequent_Hours_CPT__c = null
        );
    }
    
    public static GNE_CM_EBI_Request__c createRequest(Patient_Enrollment_Request_gne__c per)
    {
        return GNE_CM_EBI_Util.createRequest(per, null);
    }
    
    public static String resolvePERadminCode(Patient_Enrollment_Request_gne__c per)
    {
        if (per == null || per.Product_gne__c == null) {
            return null;
        }
        String product = per.Product_gne__c.trim().toLowerCase();
        String aCode = null;
        if (product == 'lucentis') {
            aCode = '67028';
        }
        else if (product == 'rheumatology' && per.Indicate_Patient_s_therapy_Rheum_gne__c != null) {
            String iptr = per.Indicate_Patient_s_therapy_Rheum_gne__c.trim().toLowerCase();
            if (iptr == 'actemra' || iptr == 'rituxan ra') {
                aCode = '96413';
            }
        }
        return aCode;
    }
    
    public static String resolvePERdiagnosisCode(Patient_Enrollment_Request_gne__c per)
    {
        if (per == null || per.Product_gne__c == null) {
            return null;
        }
        String product = per.Product_gne__c.trim().toLowerCase();
        String dCode = null;
        if (product == 'lucentis') {
            if (per.LUC_Dx1_gne__c != null) {
                dCode = per.LUC_Dx1_gne__c;
            }
            else if (per.LUC_Dx2_gne__c != null) {
                dCode = per.LUC_Dx2_gne__c;
            }
            else if (per.LUC_Dx3_gne__c != null) {
                dCode = per.LUC_Dx3_gne__c;
            }
            else if (per.LUC_Dx4_gne__c != null) {
                dCode = per.LUC_Dx4_gne__c;
            }
            else {
                throw new GNE_CM_Exception('Product on PER [ID = ' + per.Id + '] is Lucentis, but neither Primary Left nor Primary Right ICD9 code is set');
            }
        }
        else if (product == 'rheumatology') {
            dCode = per.Diagnosis_Dx_gne__c;
        }
        else if (product == 'xolair') {
            dCode = per.Diagnosis_Xolair_gne__c;
        }
        else if (product == 'biooncology infused products') {
            dCode = per.Primary_ICD9_Code_gne__c;
        }
        
        // extract ICD9 from the field that contains both the code and its description
        return dCode != 'Other' ? GNE_CM_DiagnosisCodeUtil.extract(dCode, true) : dCode;
    }
        
    public static String[] resolvePERProductNames(Patient_Enrollment_Request_gne__c per){
        if (per == null || per.Product_gne__c == null) {
            return new String[0];
        }
        String product = per.Product_gne__c.trim().toLowerCase();
        if(product == 'xolair' || product == 'lucentis' || product == 'pegasys' || product == 'pulmozyme' || product == 'esbriet' || product == System.Label.GNE_CM_Venetoclax_Product_Name.toLowerCase() || product == System.label.GNE_CM_Ocre_Product_Name.toLowerCase())
        {
            return new String[]{ per.Product_gne__c };
        }
        if(per.Indicate_Patient_s_Therapy_gne__c != null && product == 'biooncology infused products'){
            String[] ipt = per.Indicate_Patient_s_Therapy_gne__c.trim().split(';');
            String[] result = new List<String>();
            for(integer i = 0; i < ipt.size(); i++){
                String ipt2Lwr = ipt[i].trim().toLowerCase();
                if(ipt2Lwr == 'avastin' || ipt2Lwr == 'herceptin' || ipt2Lwr == 'rituxan' || ipt2Lwr == 'rituxan hycela' || ipt2Lwr == 'kadcyla' || ipt2Lwr == 'perjeta' || ipt2Lwr == 'gazyva' || ipt2Lwr == 'tecentriq') {
                    result.add(ipt[i]);
                }               
            }
            return result;
        }
        else if(per.Indicate_Patient_s_therapy_Rheum_gne__c != null && product == 'rheumatology')
        {
            String ipt = per.Indicate_Patient_s_therapy_Rheum_gne__c.trim().toLowerCase();
            if(ipt == 'rituxan' || ipt == 'rituxan ra')
            {
                return new String[] {'Rituxan RA'};
            }
            if(ipt == 'actemra')
            {
                return new String[] {'Actemra'};
            }
            if(ipt == 'actemra subcutaneous')
            {
                return new String[] {'Actemra Subcutaneous'};
            }                   
        }
        else if(per.Indicate_Patient_s_Therapy_BioOncOra_gne__c  != null && product == 'biooncology oral products'){
            String[] ipt = per.Indicate_Patient_s_Therapy_BioOncOra_gne__c.trim().split(';');
            String[] result = new List<String>();
            for(integer i = 0; i < ipt.size(); i++){
                String ipt2Lwr = ipt[i].trim().toLowerCase();
                if(ipt2Lwr == 'erivedge' || ipt2Lwr == 'zelboraf' || ipt2Lwr == 'tarceva' || ipt2Lwr == 'xeloda' || ipt2Lwr == 'cotellic' || ipt2Lwr == 'alecensa'){
                    result.add(ipt[i]);
                }               
            }
            return result;
        }
        return new String[0];
    }
    
    public static String resolvePERproductName(Patient_Enrollment_Request_gne__c per)
    {
        if (per == null || per.Product_gne__c == null) {
            return null;
        }
        String product = per.Product_gne__c.trim().toLowerCase();
        String pName = null;
        if (product == 'xolair' || product == 'lucentis' || product == System.Label.GNE_CM_Venetoclax_Product_Name.toLowerCase()) {
            pName = per.Product_gne__c;
        }
        else if (product == 'biooncology infused products' && per.Indicate_Patient_s_Therapy_gne__c != null) {
            String ipt = per.Indicate_Patient_s_Therapy_gne__c.trim().toLowerCase();
            if (ipt == 'avastin' || ipt == 'herceptin' || ipt == 'rituxan') {
                pName = per.Indicate_Patient_s_Therapy_gne__c;
            }
        }
        else if (product == 'rheumatology' && per.Indicate_Patient_s_therapy_Rheum_gne__c != null) {
            pName = per.Indicate_Patient_s_therapy_Rheum_gne__c;
            if (pName == 'Rituxan') {
                pName = 'Rituxan RA';
            }
        }
        return pName;
    }
        
    public static String resolveServiceDeliveryLocation (String placeOfAdministration)
    {
        if (placeOfAdministration == null)
        {
            return null;
        }
        
        String poa = placeOfAdministration.trim().toLowerCase();
        Map<String,String> poaToSdlMap = new Map<string,String>{
            'free standing infusion center' => 'AIC',
            'home' => 'Office',
            'hospital inpatient' => 'Office',
            'hospital outpatient' => 'Hospital Outpatient Setting',
            'md office / clinic' => 'Office',
            'non prescribing md office' => 'Office',
            'other' => 'Office',
            'prescribing md office' => 'Office'
        };
        
        return !poaToSdlMap.containsKey(poa) ? placeOfAdministration : poaToSdlMap.get(poa);
    }
    
    public static String resolveServiceDeliveryLocationV2(String placeOfAdministration)
    {
        if (placeOfAdministration == null) {
            return null;
        }
        
        String poa = placeOfAdministration.trim().toLowerCase();
        Map<String,String> poaToSdlMap = new Map<string,String>{
            'free standing infusion center' => '2',
            'home' => '2',
            'hospital inpatient' => '2',
            'hospital outpatient' => '2',
            'md office / clinic' => '2',
            'non prescribing md office' => '2',
            'other' => '2',
            'prescribing md office' => '2'
        };
        return !poaToSdlMap.containsKey(poa) ? placeOfAdministration : poaToSdlMap.get(poa);
    }
    
    public static String resolveServiceDeliveryLocation(Patient_Enrollment_Request_gne__c per)
    {
        if (per == null || per.Product_gne__c == null) {
            return null;
        }
        String product = per.Product_gne__c.trim().toLowerCase();
        String fallback = null;
        String poa = null;
        Map<String,String> poaToSdlMap = new Map<String,String>();
        
        if (product == 'lucentis') {
            return 'Office';
        }
        else if (product == 'xolair' && per.Place_of_Administration_Xolair_gne__c != null) {
            fallback = per.Place_of_Administration_Xolair_gne__c;
            poa = fallback.trim().toLowerCase();
            poaToSdlMap = new Map<String,String>{
                'physicianâ€™s office' => 'Office',
                'hopd' => null,
                'alternate injection center' => 'AIC'
            };          
        }
        else if (product == 'rheumatology' && per.Place_of_infusion_gne__c != null) {
            fallback = per.Place_of_infusion_gne__c;
            poa = fallback.trim().toLowerCase();
            poaToSdlMap = new Map<String,String>{
                'prescribing physicianâ€™s office' => 'Office',
                'other physicianâ€™s office' => 'Office',
                'hospital outpatient' => null,
                'other' => 'AIC'
            };
        }
        else if (product == 'biooncology infused products' && per.Place_of_Administration_gne__c != null) {
            fallback = per.Place_of_Administration_gne__c;
            poa = fallback.trim().toLowerCase();
            poaToSdlMap = new Map<String,String>{
                'physicianâ€™s office' => 'Office',
                'hospital - outpatient' => null,
                'hospital - inpatient' => 'Office'
            };
        }
        return !poaToSdlMap.containsKey(poa) ? fallback : poaToSdlMap.get(poa);
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // EBI Response to BI object mapping utilities
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public static final Map<String,String> SERVICE_CODE_TYPES = new Map<String,String>{'JCODE' => 'jCode', 'ADMIN_CODE' => 'aCode'};
    
    public static final Map<String,String> ynuMap = new Map<String,String>{'yes' => 'Yes', 'no' => 'No', 'undetermined' => null};
    
    public static final Map<String,String> ynunapMap = new Map<String,String>{'yes' => 'Yes', 'no' => 'No', 'undetermined' => null, 'not applicable (n/a)' => null};
    
    public class EBItoBIplanAccumulator
    {   
        public String biField;
        public String biLabel;
        
        public EBItoBIplanAccumulator(String apiName, String customLabel)
        {
            this.biField = apiName;
            this.biLabel = customLabel;
        }
        
        public EBItoBIplanAccumulator(String apiName)
        {
            this.biField = apiName;
            this.biLabel = GNE_CM_EBI_Util.biFieldLabel(apiName);
        }
    }
    
    public class PayerAndPlanPayerRecord
    {
        public ID payerId;
        public ID planPayerId;
    
        public PayerAndPlanPayerRecord(ID payerId, ID planPayerId)
        {
            this.payerId = payerId;
            this.planPayerId = planPayerId;
        }   
    }
    
    public static Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>> planAccumulatorMappings = new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>>{
        GNE_CM_EBI_Util.PA_PLAN_INDIVIDUAL_DEDUCTIBLE => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IND_Individual_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OTD_Individual_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_INDIVIDUAL_DEDUCTIBLE_MET => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IND_Indv_Amount_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OTD_Indv_Amount_Met_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_INDIVIDUAL_OOP_MAX => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IN_Pocket_Individual_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OT_Out_Pocket_Individual_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_INDIVIDUAL_OOP_MET => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IN_Pocket_Individual_Amt_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OT_Out_Pocket_Individual_Amount_Met_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_FAMILY_DEDUCTIBLE => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IND_Family_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OTD_Family_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_FAMILY_DEDUCTIBLE_MET => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IND_Fam_Amount_Met_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OTD_Fam_Amount_Met_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_FAMILY_OOP_MAX => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IN_Pocket_Family_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OT_Out_Pocket_Family_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_FAMILY_OOP_MET => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IN_PocketFamily_Amount_Met_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OT_Out_Pocket_Family_Amount_Met_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_PATIENT_COST_SHARE => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('INC_Patient_pc_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OTC_Patient_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_INSURER_COST_SHARE => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('INC_Insurer_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('OTC_Insurer_gne__c')
        },
        GNE_CM_EBI_Util.PA_PLAN_OFFICE_COPAY => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('I_N_Office_Visit_Co_pay_Coinsurance_gne__c'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('O_N_Office_Visit_Co_pay_Coinsurance_gne__c')
        },
        GNE_CM_EBI_Util.PA_OUTPATIENT_SURGICAL_DEDUCTIBLE => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator(null, 'I/N Outpatient Surgical Deductible'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator(null, 'O/N Outpatient Surgical Deductible')
        },
        GNE_CM_EBI_Util.PA_OUTPATIENT_SURGICAL_DEDUCTIBLE_MET => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator(null, 'I/N Outpatient Surgical Deductible Met'),
            'OUT' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator(null, 'O/N Outpatient Surgical Deductible Met')
        },
        GNE_CM_EBI_Util.PA_OUTPATIENT_HOSPITAL_DEDUCTIBLE => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => null,
            'OUT' => null
        },
        GNE_CM_EBI_Util.PA_OUTPATIENT_HOSPITAL_DEDUCTIBLE_MET => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => null,
            'OUT' => null
        },
        GNE_CM_EBI_Util.PA_OUTPATIENT_SURGICAL_COPAY => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => null,
            'OUT' => null
        },
        GNE_CM_EBI_Util.PA_OUTPATIENT_HOSPITAL_COPAY => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => null,
            'OUT' => null
        },
        GNE_CM_EBI_Util.PA_SPEND_DOWN_EFFECTIVE_DATE => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IN_Spend_Down_Effective_Date_gne__c'),
            'OUT' => null
        },
        GNE_CM_EBI_Util.PA_SPEND_DOWN_AMOUNT => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('I_N_Medicaid_Spend_Down_Amount_gne__c'),
            'OUT' => null
        },
        GNE_CM_EBI_Util.PA_SPEND_DOWN_MET_DATE => new Map<String,GNE_CM_EBI_Util.EBItoBIplanAccumulator>{
            'IN' => new GNE_CM_EBI_Util.EBItoBIplanAccumulator('IN_Spend_Down_Met_Date_gne__c'),
            'OUT' => null
        }
    };
    
    public class EBItoBIruleResult
    {
        public String biField;
        public String biLabel;      
        private Map<String,String> ebiToBiValues;
        
        public EBItoBIruleResult(String apiName, String customLabel, Map<String,String> etbValues)
        {
            this.biField = apiName;
            this.biLabel = customLabel;
            this.ebiToBiValues = etbValues;
        }
        
        public EBItoBIruleResult(String apiName, Map<String,String> etbValues)
        {
            this.biField = apiName;
            this.biLabel = GNE_CM_EBI_Util.biFieldLabel(apiName);
            this.ebiToBiValues = etbValues;
        }
        
        public String value(String ebiValue)
        {
            if (ebiValue == null) {
                return null;
            }
            String normalizedValue = ebiValue.toLowerCase();
            return (this.ebiToBiValues == null || !this.ebiToBiValues.containsKey(normalizedValue)) ? ebiValue : this.ebiToBiValues.get(normalizedValue);
        }
    }
    
    public static Map<String,Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>> ruleResultMappings = new Map<String,Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>>{
        GNE_CM_EBI_Util.RR_PRIOR_AUTHORIZATION_REQUIRED => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Prior_Authorization_Required_gne__c', GNE_CM_EBI_Util.ynunapMap),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Prior_Authorization_Required_gne__c', GNE_CM_EBI_Util.ynunapMap)
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Admin_Prior_Auth_Required_gne__c', GNE_CM_EBI_Util.ynunapMap),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Admin_Prior_Auth_Required_gne__c', GNE_CM_EBI_Util.ynunapMap)
            }
        },
        GNE_CM_EBI_Util.RR_NOTIFICATION_REQUIRED => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Notification_Required_gne__c', GNE_CM_EBI_Util.ynunapMap),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Notification_Required_gne__c', GNE_CM_EBI_Util.ynunapMap)
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult(null, 'I/N Notification Required', GNE_CM_EBI_Util.ynunapMap),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult(null, 'O/N Notification Required', GNE_CM_EBI_Util.ynunapMap)
            }
        },
        GNE_CM_EBI_Util.RR_MEDICAL_DOCUMENTATION_REQUIRED => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Medical_Documents_Required_gne__c', new Map<String,String>{
                    'yes' => 'Medical Documents', 'no' => 'None Required', 'undetermined' => 'Undetermined', 'not applicable (n/a)' => null}),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Medical_Documents_Required_gne__c', new Map<String,String>{
                    'yes' => 'Medical Documents', 'no' => 'None Required', 'undetermined' => 'Undetermined', 'not applicable (n/a)' => null})
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Admin_Network_Med_Doc_Required_gne__c', GNE_CM_EBI_Util.ynunapMap),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Admin_Network_Med_Doc_Required_gne__c', GNE_CM_EBI_Util.ynunapMap)
            }
        },
        GNE_CM_EBI_Util.RR_PRE_DETERMINATION => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Predetermination_Available_gne__c', new Map<String,String>{
                    'available, optional' => 'Yes',
                    'available, required' => 'Yes',
                    'not available' => 'No',
                    'undetermined' => null,
                    'unavailable' => 'No',
                    'unavailable, optional' => 'No',
                    'not applicable (n/a)' => null}),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Predetermination_Available_gne__c', new Map<String,String>{
                    'available, optional' => 'Yes',
                    'available, required' => 'Yes',
                    'not available' => 'No',
                    'undetermined' => null,
                    'unavailable' => 'No',
                    'unavailable, optional' => 'No',
                    'not applicable (n/a)' => null})
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Admin_Predetermination_Available_gne__c', new Map<String,String>{
                    'available, optional' => 'Yes',
                    'available, required' => 'Yes',
                    'not available' => 'No',
                    'undetermined' => null,
                    'unavailable' => 'No',
                    'unavailable, optional' => 'No',
                    'not applicable (n/a)' => null}),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Admin_Predetermination_Available_gne__c', new Map<String,String>{
                    'available, optional' => 'Yes',
                    'available, required' => 'Yes',
                    'not available' => null,
                    'undetermined' => null,
                    'unavailable' => null,
                    'unavailable, optional' => null,
                    'not applicable (n/a)' => null})
            }
        },
        GNE_CM_EBI_Util.RR_DEDUCTIBLE_APPLIES => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IND_None_gne__c', GNE_CM_EBI_Util.ynunapMap),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('OTD_None_gne__c', null)
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Admin_Network_Deductible_Applies_gne__c', GNE_CM_EBI_Util.ynunapMap),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Admin_Network_Deductible_Applies_gne__c', GNE_CM_EBI_Util.ynunapMap)
            }
        },
        GNE_CM_EBI_Util.RR_PATIENT_COST_SHARE_APPLIES => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult(null, 'I/N Patient Cost Share Applies', null),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult(null, 'O/N Patient Cost Share Applies', null)
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Admin_Patient_Cost_Share_Applies_gne__c', GNE_CM_EBI_Util.ynunapMap),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Admin_Patient_Cost_Share_Applies_gne__c', GNE_CM_EBI_Util.ynunapMap)
            }
        },
        GNE_CM_EBI_Util.RR_OOP_MAX_APPLIES => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Max_Year_gne__c', new Map<String,String>{
                    'yes' => 'Yes',
                    'no' => 'No',
                    'undetermined' => null,
                    'n/a' => null
                }),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('OT_Out_Pocket_N_A_gne__c', null)
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Admin_OOP_Max_Applies_gne__c', new Map<String,String>{
                    'yes' => 'Yes',
                    'no' => 'No',
                    'undetermined' => null,
                    'n/a' => null
                }),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Admin_OOP_Max_Applies_gne__c', GNE_CM_EBI_Util.ynunapMap)
            }
        },
        GNE_CM_EBI_Util.RR_COPAY_APPLIES => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult(null, 'I/N Copay Applies', null),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult(null, 'O/N Copay Applies', null)
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Admin_Copay_Applies_gne__c', GNE_CM_EBI_Util.ynunapMap),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Admin_Copay_Applies_gne__c', GNE_CM_EBI_Util.ynunapMap)
            }
        },
        GNE_CM_EBI_Util.RR_BUY_AND_BILL_PERMITTED => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Buy_and_Bill_Available_gne__c', new Map<String,String>{
                    'yes' => 'Yes', 'no' => 'No', 'not applicable (n/a)'  => 'Not Applicable (N/A)'}),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Buy_and_Bill_Available_gne__c', new Map<String,String>{
                    'yes' => 'Yes', 'no' => 'No', 'not applicable (n/a)'  => 'Not Applicable (N/A)', 'undetermined' => null})
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => null,
                'OUT' => null
            }
        },
        GNE_CM_EBI_Util.RR_SPECIALTY_PHARMACY => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Specialty_Pharmacy_Available_gne__c', new Map<String,String>{
                    'yes' => 'Yes', 'no' => 'No', 'undetermined' => 'Undetermined', 'not applicable (n/a)' => 'Not Applicable (N/A)'}),
                'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Specialty_Pharmacy_Available_gne__c', new Map<String,String>{
                    'yes' => 'Yes', 'no' => 'No', 'undetermined' => null, 'not applicable (n/a)' => 'Not Applicable (N/A)'})
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => null,
                'OUT' => null
            }
        },
        GNE_CM_EBI_Util.RR_COB_BENEFIT_DESIGN_TYPE => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('COB_Benefit_Design_gne__c', new Map<String,String>{
                    'COW' => 'Come Out Whole', 'ND' => 'Non-Duplication', 'Neither' => 'None', 'Standard' => 'Standard', 'Supplement' => 'Supplement'}),
                'OUT' => null
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => null,
                'OUT' => null
            }
        },
        GNE_CM_EBI_Util.RR_BUY_AND_BILL_AND_SPECIALTY_PHARMACY_BENEFITS_DIFFERENCE => new Map<String,Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>>{
            'JCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => null,
                'OUT' => null
            },
            'AdminCode' => new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
                'IN' => null,
                'OUT' => null
            }
        }
    };
    
    public static Map<String,GNE_CM_EBI_Util.EBItoBIruleResult> jCodePreDetReqMapping = new Map<String,GNE_CM_EBI_Util.EBItoBIruleResult>{
        'IN' => new GNE_CM_EBI_Util.EBItoBIruleResult('IN_Is_Pre_D_Required_or_Voluntary_gne__c', new Map<String,String>{
            'available, optional' => 'Voluntary',
            'available, required' => 'Required',
            'not available' => null,
            'undetermined' => null,
            'unavailable' => null,
            'unavailable, optional' => null,
            'not applicable (n/a)' => null}),
        'OUT' => new GNE_CM_EBI_Util.EBItoBIruleResult('ON_Is_Pre_D_Required_or_Voluntary_gne__c', new Map<String,String>{
            'available, optional' => 'Voluntary',
            'available, required' => 'Required',
            'unavailable' => null,
            'undetermined' => null,
            'unavailable, optional' => null,
            'not available' => null,
            'not applicable (n/a)' => null})
    };
    
    public static String calculateBuyAndBillRequired(String buyAndBillAvailable, String specialtyPharmacyAvailable)
    {
        if (String.isNotBlank(buyAndBillAvailable)) {
            if (specialtyPharmacyAvailable == 'No' && buyAndBillAvailable != 'No') {
                return 'Yes';
            }
            if (specialtyPharmacyAvailable == 'Yes' || (buyAndBillAvailable == 'No' && String.isBlank(specialtyPharmacyAvailable))) {
                return 'No';
            }
        }
        return null;
    }
    
    public static String calculateSpecialtyPharmacyRequired(String specialtyPharmacyAvailable, String buyAndBillAvailable)
    {
        if (String.isNotBlank(specialtyPharmacyAvailable)) {
            if (buyAndBillAvailable == 'No' && specialtyPharmacyAvailable != 'No') {
                return 'Yes';
            }
            if (buyAndBillAvailable == 'Yes' || (specialtyPharmacyAvailable == 'No' && String.isBlank(buyAndBillAvailable))) {
                return 'No';
            }
        }
        return null;
    }
    
    public static String coverageMessageIdToProductNotCovered(String messageId, String fallback)
    {
        if (messageId == null) {
            return null;
        }
        Map<String,String> m = new Map<String,String>{
            '71' => 'Site of Treatment',
            '70' => 'Pre-Existing Clause',
            '69' => 'No Benefit for Injectables',
            '68' => 'Not on Formulary',
            '67' => 'No Benefit',
            '66' => 'No Drug Coverage',
            '65' => 'Experimental / Investigational',
            '64' => 'Diagnosis off label',
            '63' => 'Diagnosis',
            '62' => 'Out-of-Network Coverage Undetermined',
            '61' => 'In-Network Coverage Undetermined',
            '7' => 'No Out of Network Benefit'
        };
        return m.containsKey(messageId) ? m.get(messageId) : fallback;
    }
    
    public static String coverageMessageIdToProductNotCovered(String messageId)
    {
        return GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered(messageId, null);
    }
    
    public static String coverageStatusToProductCovered(String status, String fallback)
    {
        if (status == null) {
            return null;
        }
        status = status.trim().toLowerCase();
        Map<String,String> m = new Map<String,String>{'covered' => 'Yes, if Medically Necessary', 'not covered' => 'No', 'undetermined ' => null};
        return m.containsKey(status) ? m.get(status) : fallback;
    }
    
    public static String coverageStatusToProductCovered(String status)
    {
        return GNE_CM_EBI_Util.coverageStatusToProductCovered(status, null);
    }
    
    public static String insuranceStatusPayerResultToInsurance(String status, String fallback)
    {
        if (status == null) {
            return null;
        }
        status = status.trim().toLowerCase();
        Map<String,String> m = new Map<String,String>{'active' => 'Active', 'inactive' => 'Terminated', 'incomplete' => null, 'ineligible' => null, 'not found' => null};
        return m.containsKey(status) ? m.get(status) : fallback;
    }
    
    public static String insuranceStatusPayerResultToInsurance(String status)
    {
        return GNE_CM_EBI_Util.insuranceStatusPayerResultToInsurance(status, null);
    }
    
    public static Decimal parseStringToDecimal(String text)
    {
        if (text == null) {
            return null;
        }
        String normalized = Pattern.compile('[^0-9.]').matcher(text).replaceAll('');
        return (normalized != null && normalized != '') ? Decimal.valueOf(normalized) : null;
    }
    
    public static Integer parseStringToInteger(String text)
    {
        if (text == null) {
            return null;
        }
        String normalized = Pattern.compile('[^0-9.]').matcher(text).replaceAll('');
        return (normalized != null && normalized != '') ? Integer.valueOf(normalized) : null;
    }
    
    public static String parseStringToNumericString(String text)
    {
        return text == null ? null : Pattern.compile('[^0-9.]').matcher(text).replaceAll('');
    }
    
    public static Object parseFieldValueByType(String field, Object value)
    {
        system.debug(field + ' ' + String.valueof(value));
        if (value == null || !GNE_CM_EBI_Util.biFieldsMap.containsKey(field)) {
            return null;
        }
        Schema.DescribeFieldResult dfr = biFieldsMap.get(field).getDescribe();
        if (dfr.getType() == Schema.DisplayType.Currency || dfr.getType() == Schema.DisplayType.Percent || dfr.getType() == Schema.DisplayType.Double) {
            return GNE_CM_EBI_Util.parseStringToDecimal(String.valueOf(value));
        }
        if (dfr.getType() == Schema.DisplayType.Date) {
            return Date.parse(String.valueOf(value));
        }
        return String.valueOf(value);
    }
    
    public static String serviceDeliveryLocationToBenefitType(String sdl, String fallback)
    {
        if (sdl == null) {
            return fallback;
        }
        sdl = sdl.trim().toLowerCase();
        Map<String,String> m = new Map<String,String>{'office' => 'In Office', 'aic' => 'In Office', 'hospital outpatient setting' => 'HOPD'};
        return m.containsKey(sdl) ? m.get(sdl) : fallback;
    }
    
    public static String serviceDeliveryLocationToBenefitType(String sdl)
    {
        return GNE_CM_EBI_Util.serviceDeliveryLocationToBenefitType(sdl, null);
    }
    
    public static String mapRankToICD9(String rank)
    {
        if (rank == null) {
            return null;
        }
        String normalizedRank = rank.trim().toLowerCase();
        if (normalizedRank == 'primary') {
            return 'ICD9-1';
        }
        if (normalizedRank == 'secondary') {
            return 'ICD9-2';
        }
        if (normalizedRank == 'tertiary') {
            return 'ICD9-3';
        }
        return rank;
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // TransEngen to EBI data model mappings
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public static Date dateTimeToDate(DateTime dt)
    {
        if (dt == null) {
            return null;
        }
        try {
            return Date.newInstance(dt.year(), dt.month(), dt.day());
        }
        catch (Exception ex) {
            system.debug('GNE_CM_EBI_Util.dateTimeToDate exception thrown: invalid parameter for conversion:\n' + ex.getMessage());
            return null;
        }
    }
    
    public static Datetime dateToDateTime(Date dt)
    {
        if (dt == null) {
            return null;
        }
        try {
            return Datetime.newInstance(dt.year(), dt.month(), dt.day());
        }
        catch (Exception ex) {
            system.debug('GNE_CM_EBI_Util.dateToDateTime exception thrown: invalid parameter for conversion:\n' + ex.getMessage());
            return null;
        }
    }
    
    public static String dateToString(Date d, String f)
    {
        if (d == null) {
            return null;
        }
        if (f == null) {
            f = 'yyyy-MM-dd';
        }
        try {
            return DateTime.newInstance(d.year(), d.month(), d.day()).format(f);
        }
        catch (Exception ex) {
            system.debug('GNE_CM_EBI_Util.dateToString exception thrown: invalid parameter(s) for conversion:\n' + ex.getMessage());
            return null;
        }
    }
    
    public static String dateToString(Date d)
    {
        return GNE_CM_EBI_Util.dateToString(d, null);
    }
    
    public static String diagnosisRankIntegerToString(Integer dr, String fallback)
    {
        Map<Integer,String> m = new Map<Integer,String>{0 => 'Unknown', 1 => 'Primary', 2 => 'Secondary', 3 => 'Tertiary', 4 => 'Quaternary', 5 => 'N/A'};
        return m.containsKey(dr) ? m.get(dr) : fallback;
    }
    
    public static String diagnosisRankIntegerToString(Integer dr)
    {
        return GNE_CM_EBI_Util.diagnosisRankIntegerToString(dr, null);
    }
    
    public static Integer diagnosisRankStringToInteger(String dr, Integer fallback)
    {
        if (dr == null) {
            return fallback;
        }
        dr = dr.trim().toLowerCase();
        Map<String,Integer> m = new Map<String,Integer>{'unknown' => 0, 'primary' => 1, 'secondary' => 2, 'tertiary' => 3, 'quaternary' => 4, 'n/a' => 5};
        return m.containsKey(dr) ? m.get(dr) : fallback;
    }
    
    public static Integer diagnosisRankStringToInteger(String dr)
    {
        return GNE_CM_EBI_Util.diagnosisRankStringToInteger(dr, 0);
    }
    
    public static String diagnosisRankToICD9(String dr, String fallback)
    {
        if (dr == null) {
            return null; 
        }
        Integer dri = GNE_CM_EBI_Util.diagnosisRankStringToInteger(dr);
        return (dri == 1 || dri == 2 || dri == 3) ? 'Diagnosis Code - ' + dri : (fallback == null ? null : 'Diagnosis Code - ' + fallback);
    }
    
    public static String diagnosisRankToICD9(String dr)
    {
        return GNE_CM_EBI_Util.diagnosisRankToICD9(dr, null);
    }
    
    public static Integer patientRelationshipStringToInteger(String pr, Integer fallback)
    {
        if (pr == null) {
            return fallback;
        }
        pr = pr.trim().toLowerCase();
        Map<String,Integer> m = new Map<String,Integer>{'child' => 19, 'dependent adult' => 34, 'dependent minor (18 and under)' => 19,
            'domestic partner' => 34, 'guardian' => 34, 'other' => 34, 'power of attorney' => 34, 'self' => 18, 'spouse' => 1};
        return m.containsKey(pr) ? m.get(pr) : fallback;
    }
    
    public static Integer patientRelationshipStringToInteger(String pr)
    {
        return GNE_CM_EBI_Util.patientRelationshipStringToInteger(pr, 34);
    }

    public static String payerRankIntegerToString(Integer pr, String fallback)
    {
        Map<Integer,String> m = new Map<Integer,String>{0 => 'Unknown', 1 => 'Primary', 2 => 'Secondary', 3 => 'Tertiary'};
        return m.containsKey(pr) ? m.get(pr) : fallback;
    }
    
    public static String payerRankIntegerToString(Integer pr)
    {
        return GNE_CM_EBI_Util.payerRankIntegerToString(pr, null);
    }
    
    public static Integer payerRankStringToInteger(String pr, Integer fallback)
    {
        if (pr == null) {
            return fallback;
        }
        pr = pr.trim().toLowerCase();
        Map<String,Integer> m = new Map<String,Integer>{'unknown' => 0, 'primary' => 1, 'secondary' => 2, 'tertiary' => 3};
        return m.containsKey(pr) ? m.get(pr) : fallback;
    }
    
    public static Integer payerRankStringToInteger(String pr)
    {
        return GNE_CM_EBI_Util.payerRankStringToInteger(pr, 0);
    }
    
    public static String responseStatusIntegerToString(Integer rs, String fallback)
    {
        if (rs == null) {
            return fallback;
        }
        Map<Integer,String> m = new Map<Integer,String>{0 => 'Success', 1 => 'Partial Error', 2 => 'Complete Error', 3 => 'System Error'};
        return m.containsKey(rs) ? m.get(rs) : fallback;
    }
    
    public static String responseStatusIntegerToString(Integer rs)
    {
        return GNE_CM_EBI_Util.responseStatusIntegerToString(rs, null);
    }
    
    public static String serviceDeliveryLocationIntegerToString(Integer sdl, String fallback)
    {
        Map<Integer,String> m = new Map<Integer,String>{0 => 'Office', 1 => 'AIC', 2 => 'Hospital Outpatient Setting'};
        return m.containsKey(sdl) ? m.get(sdl) : fallback;
    }
    
    public static String serviceDeliveryLocationIntegerToString(Integer sdl)
    {
        return GNE_CM_EBI_Util.serviceDeliveryLocationIntegerToString(sdl, null);
    }
    
    public static Integer serviceDeliveryLocationStringToInteger(String sdl, Integer fallback)
    {
        if (sdl == null) {
            return fallback;
        }
        sdl = sdl.trim().toLowerCase();
        Map<String,Integer> m = new Map<String,Integer>{'office' => 0, 'aic' => 1, 'hospital outpatient setting' => 2};
        return m.containsKey(sdl) ? m.get(sdl) : fallback;
    }
    
    public static Integer serviceDeliveryLocationStringToInteger(String sdl)
    {
        return GNE_CM_EBI_Util.serviceDeliveryLocationStringToInteger(sdl, null);
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Instant eBI utilities
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
    public class InstantBIResult
    {
        public Benefit_Investigation_gne__c primaryBI { get; private set; }
        public Benefit_Investigation_gne__c secondaryBI { get; private set; }
        
        public InstantBIResult(Benefit_Investigation_gne__c primaryBI, Benefit_Investigation_gne__c secondaryBI)
        {
            this.primaryBI = primaryBI;
            this.secondaryBI = secondaryBI;
        }
    }
    
    // Extract an ICD9 code from a string that contains a code and a description
    public static String extractICD9(String description)
    {
        if (description == null || description == '') {
            return description;
        }
        Matcher icd9Matcher = Pattern.compile('.*(\\d\\d\\d\\.\\d\\d?).*').matcher(description);
        system.debug('icd9Matcher string**:'+icd9Matcher );
        return !icd9Matcher.matches() ? description : icd9Matcher.group(1);
    }
    
    public static Boolean isInstantBiPossibleForPER(Patient_Enrollment_Request_gne__c per)
    { 
        // check that the practice is ebi-able (according to ebi-31)
        if (!GNE_CM_MPS_Utils.isEbiFunctionalityEnabledForMPSRegistration(per.GNE_CM_MPS_RegId__c))
        {
            system.debug('[IBI] EBI functionality not enabled for registration ' + per.GNE_CM_MPS_RegId__c + ' or disabled for all registrations');
            Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError('GNE_CM_EBI_Util', 'Low', 'isInstantBiPossibleForPER', 'Apex Code', 'EBI functionality not enabled for registration ' + per.GNE_CM_MPS_RegId__c + ' or disabled for all registrations');
            return false;
        }
        
        // check that the payer is connected
        if (per.Primary_Payer_gne__c == null)
        {
            system.debug('[IBI] Primary payer on PER is not set');
            Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError('GNE_CM_EBI_Util', 'Low', 'isInstantBiPossibleForPER', 'Apex Code', 'Primary payer on PER is not set');
            // Insurance is not required on PER, but if there is no insurance (i.e. no primary payer),
            // Instant BI will also not be possible
            return false;
        }
        
        GNE_CM_EBI_Payer_Mapping__c payerMapping = GNE_CM_EBI_Util.getPayerMapping(per.Primary_Payer_gne__c);
        if (payerMapping == null)
        {
            system.debug('[IBI] Instant BI not possible: payer ' + per.Primary_Payer_gne__c + ' not mapped');
            Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError('GNE_CM_EBI_Util', 'Low', 'isInstantBiPossibleForPER', 'Apex Code', 'Instant BI not possible: payer ' + per.Primary_Payer_gne__c + ' not mapped');
            return false;
        }
        
        String product = GNE_CM_EBI_Util.resolvePERproductName(per);
        // TODO
        // Ask Rosano which product to check
        // Also make sure multiple products are not selected
        if (!GNE_CM_EBI_Util.isProductEbiEligible(product))
        {
            system.debug('[IBI] Instant BI not possible: product ' + product + ' not EBI-able');
            Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError('GNE_CM_EBI_Util', 'Low', 'isInstantBiPossibleForPER', 'Apex Code', 'Instant BI not possible: product ' + product + ' not EBI-able');
            return false;
        }
        
        // get Dx code
        String dxCode = GNE_CM_EBI_Util.resolvePERDiagnosisCode(per);
        Integer version = GNE_CM_DiagnosisCodeUtil.getVersion(dxCode);
        if (dxCode == null || dxCode == 'Other' || version==null || version<10)
        {
            // If the returned ICD9 code is null, Instant BI is not possible for this PER. Method GNE_CM_EBI_Util.resolvePERDiagnosisCode contains
            // business logic that filters out some PERs for which Instant BI is impossible.
            Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError('GNE_CM_EBI_Util', 'Low', 'isInstantBiPossibleForPER', 'Apex Code', 'dxCode == null || dxCode == Other || version==null || version<10');
            return false;
        }
        
        // We also need to filter out special cases for Lucentis
        /* ICD9s will never get here
        Set<String> invalidICD9s = new Set<String> {'250.50', '250.51', '250.52', '250.53', '362.01', '362.02', '362.03', '362.04', '362.05', '362.06', '362.07' };
        Set<String> invalidSigs = new Set<String>
        {
            'Inject 0.5 mg (0.05 mL) intravitreally monthly',
            'Inject 0.5 mg (0.05 mL) intravitreally monthly x3 months then as needed (PRN)',
            'Inject 0.5 mg (0.05 mL) intravitreally monthly x4 months then quarterly'
        };
        
        if (product == 'Lucentis' && (invalidICD9s.contains(dxCode) && (invalidSigs.contains(per.SIG_Lucentis_gne__c) || invalidSigs.contains(per.SIG_Lucentis_Right_gne__c))))
        {
            return false;
        }
        
        // issue 28315 start
        if( product == 'Lucentis' &&
            per.Primary_Left_gne__c != null && per.Primary_Left_gne__c != '' &&
            per.Primary_Right_gne__c != null && per.Primary_Right_gne__c != '' &&
            per.Primary_Left_gne__c != per.Primary_Right_gne__c ){
                
            return false;
        }  */      
        //issue 28315 stop
        // make sure the patient has valid PAN
        if (per.Patient_gne__c == null)
        {
            throw new GNE_CM_Exception('Patient not set on PER');
        }
        
        List<Patient_gne__c> patients = [SELECT Pan_gne__c, PAN_Form_1_Product_gne__c, PAN_Form_2_gne__c, PAN_Form_2_Product_gne__c 
                                        FROM Patient_gne__c WHERE Id = :per.Patient_gne__c];
        if (patients.get(0).PAN_gne__c != 'Yes' || patients.get(0).PAN_Form_1_Product_gne__c != product)
        {
            if (patients.get(0).PAN_Form_2_gne__c != 'Yes' || patients.get(0).PAN_Form_2_Product_gne__c != product)
            {
                system.debug('[IBI] Instant BI not possible: patient does not have a valid PAN');
                Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError('GNE_CM_EBI_Util', 'Low', 'isInstantBiPossibleForPER', 'Apex Code', 'Instant BI not possible: patient does not have a valid PAN'); 
                // cannot perform instant BI for patients without a valid PAN
                return false;
            }
        }
        
        if (GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per) == null)
        {
            system.debug('[IBI] Instant BI not possible because of invalid service delivery location ' + per.Place_of_Administration_gne__c + ' and product ' + per.Product_gne__c);
            return false;
        }
        
        if(per.Anticipated_Date_of_Treatment_gne__c != null && per.Anticipated_Date_of_Treatment_gne__c != date.today()){
            system.debug('[IBI] Instant BI not possible because of invalid anticipated date of treatment ' + per.Anticipated_Date_of_Treatment_gne__c);
            return false;
        }
        
        //EBI-184
        if (per.Secondary_Payer_gne__c != null && String.valueOf(per.Secondary_Payer_gne__c) != '') {
            GNE_CM_EBI_Payer_Mapping__c secondaryPayerMapping = GNE_CM_EBI_Util.getPayerMapping(per.Secondary_Payer_gne__c);
            if (secondaryPayerMapping == null)
            {
                system.debug('[IBI] Instant BI not possible: secondary payer ' + per.Secondary_Payer_gne__c + ' not mapped');
                Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError('GNE_CM_EBI_Util', 'Low', 'isInstantBiPossibleForPER', 'Apex Code', 'Instant BI not possible: payer ' + per.Secondary_Payer_gne__c + ' not mapped');
                return false;
            }
        }
        
        System.debug('[IBI] Instant BI is possible');
        
        return true;
    }
    
    public static Map<String, Boolean> isBiForPayer(List<Benefit_Investigation_gne__c> biList)
    {
        Map<String, Boolean> biPayerMap = new Map<String, Boolean>();
        
        Set<String> tNumbers = new Set<String>();
        Set<String> payerIds = new Set<String>();
        
        for (Benefit_Investigation_gne__c bi : biList) 
        {
            if (bi.eBI_Transaction_Num_gne__c != null) 
            {
                tNumbers.add(bi.eBI_Transaction_Num_gne__c);    
            }
            if (bi.Payer_BI_gne__c != null) 
            {
                payerIds.add(bi.Payer_BI_gne__c);
            }
            if (bi.eBI_Transaction_Num_gne__c != null && bi.Payer_BI_gne__c != null)
            {
                biPayerMap.put((bi.eBI_Transaction_Num_gne__c + '_' + bi.Payer_BI_gne__c), false);
            }
        }
        
        for (Benefit_Investigation_gne__c bi : [
            SELECT Id, eBI_Transaction_Num_gne__c, Payer_BI_gne__c, Payer_BI_gne__r.Name
            FROM Benefit_Investigation_gne__c
            WHERE eBI_Transaction_Num_gne__c IN :tNumbers
            AND Payer_BI_gne__c IN :payerIds
        ]) 
        {
            biPayerMap.put((bi.eBI_Transaction_Num_gne__c + '_' + bi.Payer_BI_gne__c), true);
        }
        
        return biPayerMap;
    }
    
    public static final String RESPONSE_NOT_FOUND = 'Instant BI Response not found';
    public static final String PAYER_RESULT_NOT_FOUND = 'Instant BI Payer Result not found';
    public static final String MULTIPLE_PAYER_RESULTS = 'Multiple Payer Results found; expected exactly one';
    
    
    // twardoww [03/13/2014]: updated method to handle multiple Payer Results 
    public static String instantBiDisplayCriteriaError(Id perId)
    {
        List<GNE_CM_EBI_Benefit_Verification_Response__c> responses = [
            SELECT Id, Status_gne__c, Error_Message_gne__c
            FROM GNE_CM_EBI_Benefit_Verification_Response__c
            WHERE Request_gne__r.PER_gne__c = :perId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (responses.isEmpty()) {
            return GNE_CM_EBI_Util.RESPONSE_NOT_FOUND;
        }
        
        List<GNE_CM_EBI_Payer_Result__c> payerResults = [
            SELECT Id, Payer_Name_gne__c, Insurance_Status_gne__c, Response_Error_Message_gne__c, Other_Response_Message_gne__c, Transaction_ID_gne__c, Payer_Rank_gne__c,
                (SELECT Id, Coverage_Status_gne__c, In_Network_gne__c, Rule_ID_gne__c FROM Rule_Result_Set__r)
            FROM GNE_CM_EBI_Payer_Result__c
            WHERE EBI_Benefit_Verification_Response_gne__c = :responses[0].Id
        ];
        if (payerResults.isEmpty()) {
            return GNE_CM_EBI_Util.PAYER_RESULT_NOT_FOUND;
        }
        List<String> instantBiDisplayCriteriaErrorList = new List<String>();
        for (GNE_CM_EBI_Payer_Result__c payerResult : payerResults) {
            String instantBiDisplayCriteriaErrorMessage = GNE_CM_EBI_Util.instantBiDisplayCriteriaError(responses[0], payerResult);
            if (String.isNotBlank(instantBiDisplayCriteriaErrorMessage)) {
                instantBiDisplayCriteriaErrorList.add('Payer Result for ' + payerResult.Payer_Name_gne__c + '(' + payerResult.Id + ') errors: ' + instantBiDisplayCriteriaErrorMessage);
            }
        }
        return instantBiDisplayCriteriaErrorList.isEmpty() ? null : String.join(instantBiDisplayCriteriaErrorList, '\n\n');
    }
    
    public static String instantBiDisplayCriteriaError(GNE_CM_EBI_Benefit_Verification_Response__c response, GNE_CM_EBI_Payer_Result__c payerResult)
    {
        List<String> errorList = new List<String>();
        
        if (response == null) {
            return GNE_CM_EBI_Util.RESPONSE_NOT_FOUND;
        }
        if (payerResult == null) {
            return GNE_CM_EBI_Util.PAYER_RESULT_NOT_FOUND;
        }
        
        //if (!response.Status_gne__c.equalsIgnoreCase('Success')) {
        if (!'Success'.equalsIgnoreCase(response.Status_gne__c)) {
            errorList.add('eBI Response not successfull');
        }
        if (String.isNotBlank(response.Error_Message_gne__c)) {
            errorList.add('Response Error Message');
        }
        //if (!payerResult.Insurance_Status_gne__c.equalsIgnoreCase('Active')) {
        if (!'Active'.equalsIgnoreCase(payerResult.Insurance_Status_gne__c)) {      
            errorList.add('Insurance is not active');
        }
        if (String.isNotBlank(payerResult.Response_Error_Message_gne__c)) {
            errorList.add('Payer Error Message');
        }
        if (String.isNotBlank(payerResult.Other_Response_Message_gne__c)) {
            errorList.add('Payer Other Error Message');
        }
        if (payerResult.Rule_Result_Set__r == null) {
            errorList.add('Rule status is not Covered');
        }
        else {
            //PKambalpally 2/13/2014 Changed set to type String to avoid error when adding Rule_ID_gne__c to ruleIds.
            Set<String> ruleIds = new Set<String>();
            Set<Id> inNetworkRuleResultSets = new Set<Id>();
            Boolean containsInvalidRuleResultSet = false;
            for (GNE_CM_EBI_Rule_Result_Set__c rrs : payerResult.Rule_Result_Set__r) {
                ruleIds.add(rrs.Rule_ID_gne__c);
                if (rrs.In_Network_gne__c) {
                    inNetworkRuleResultSets.add(rrs.Id);
                }
                //if (rrs.In_Network_gne__c == true && !rrs.Coverage_Status_gne__c.equalsIgnoreCase('Covered')) {
                if (rrs.In_Network_gne__c == true && !'Covered'.equalsIgnoreCase(rrs.Coverage_Status_gne__c)) {
                    containsInvalidRuleResultSet = true;
                }
                //else if (!rrs.Coverage_Status_gne__c.equalsIgnoreCase('Covered') && !rrs.Coverage_Status_gne__c.equalsIgnoreCase('Not Covered')) {
                else if (!'Covered'.equalsIgnoreCase(rrs.Coverage_Status_gne__c) && !'Not Covered'.equalsIgnoreCase(rrs.Coverage_Status_gne__c)) {
                    containsInvalidRuleResultSet = true;
                }
            }
            if (containsInvalidRuleResultSet) {
                errorList.add('Rule status is not Covered');
            }           
            if ([SELECT COUNT() FROM GNE_CM_EBI_Rule_Issue__c WHERE RuleId_gne__c IN :ruleIds AND (NOT Status_gne__c LIKE 'Closed%')] > 0) {
                errorList.add('Rule Issue exists for Response');
            }           
            
            //if EBI Rule Result.COB Benefit Type = "Supplement", ignore criteria (Show Instant BI = Yes)
            List<GNE_CM_EBI_Rule_Result__c> rrWithSupplementCobType = [
                SELECT Value_Name_gne__c, Value_Result_gne__c
                FROM GNE_CM_EBI_Rule_Result__c
                WHERE EBI_Rule_Result_Set_gne__c IN :inNetworkRuleResultSets
                AND Value_Name_gne__c = :RR_COB_BENEFIT_DESIGN_TYPE
            ];

            Boolean isCOB = (rrWithSupplementCobType.size() > 0 && 'Supplement'.equalsIgnoreCase(rrWithSupplementCobType[0].Value_Result_gne__c));

            system.debug(LoggingLevel.INFO, 'COORDINATION OF BENEFITS ' + (isCOB ? 'TRUE' : 'FALSE'));

            if (!isCOB) {
                Boolean invalidBuyAndBillFound = false;
                Boolean invalidPharmacyFound = false;
                for (GNE_CM_EBI_Rule_Result__c ruleResult : [
                    SELECT Value_Name_gne__c, Value_Result_gne__c
                    FROM GNE_CM_EBI_Rule_Result__c
                    WHERE EBI_Rule_Result_Set_gne__c IN :inNetworkRuleResultSets
                        AND (Value_Name_gne__c = 'Specialty Pharmacy' OR Value_Name_gne__c = 'Buy And Bill Permitted')
                ]) {
                    //if (ruleResult.Value_Name_gne__c.equalsIgnoreCase('Buy And Bill Permitted') && ruleResult.Value_Result_gne__c.equalsIgnoreCAse('No')) {
                    if ('Buy And Bill Permitted'.equalsIgnoreCase(ruleResult.Value_Name_gne__c) && 'No'.equalsIgnoreCAse(ruleResult.Value_Result_gne__c)) {
                        invalidBuyAndBillFound = true;
                    }
                    //else if (ruleResult.Value_Name_gne__c.equalsIgnoreCase('Specialty Pharmacy') && ruleResult.Value_Result_gne__c.equalsIgnoreCase('Yes')) {
                    else if ('Specialty Pharmacy'.equalsIgnoreCase(ruleResult.Value_Name_gne__c) && 'Yes'.equalsIgnoreCase(ruleResult.Value_Result_gne__c)) {
                        invalidPharmacyFound = true;
                    }
                }           
                if (invalidBuyAndBillFound && invalidPharmacyFound) {
                    errorList.add('Speciality Pharmacy is Required');
                }
                if (rrWithSupplementCobType.size() > 0 && 
                    payerResult.Payer_Rank_gne__c==2 &&
                    String.isBlank(rrWithSupplementCobType[0].Value_Result_gne__c))
                {
                    errorList.add('Secondary Payer with a COB Benefit Design Rule Result must contain a value');
                }
            }
            
            Set<String> checkedPlanAccumulators = new Set<String>();
            if (!isCOB) {
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_INDIVIDUAL_DEDUCTIBLE);
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_INDIVIDUAL_DEDUCTIBLE_MET);
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_PATIENT_COST_SHARE);
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_INSURER_COST_SHARE);
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_OFFICE_COPAY);
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_FAMILY_DEDUCTIBLE);
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_FAMILY_DEDUCTIBLE_MET);
            }
            
            if (!isCOB && !payerResult.Payer_Name_gne__c.startsWithIgnoreCase('medicare')) {
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_INDIVIDUAL_OOP_MAX);
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_FAMILY_OOP_MAX);
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_INDIVIDUAL_OOP_MET);
                checkedPlanAccumulators.add(GNE_CM_EBI_Util.PA_PLAN_FAMILY_OOP_MET);
            }
            
            System.debug('checkedPlanAccumulators are: '+checkedPlanAccumulators);
            
            List<GNE_CM_EBI_Plan_Accumulator__c> planAccumulators = [
                SELECT Id, Value_Name_gne__c, Value_Result_gne__c
                FROM GNE_CM_EBI_Plan_Accumulator__c
                WHERE EBI_Payer_Result_gne__c  = :payerResult.Id
                    AND In_Network_gne__c = true
                    AND Value_Name_gne__c IN :checkedPlanAccumulators
            ];

            if (planAccumulators.size() > 0) {
                Map<String, List<GNE_CM_EBI_Plan_Accumulator__c>> planAccumulatorsGroupedBySuffix = new Map<String, List<GNE_CM_EBI_Plan_Accumulator__c>>();
                Set<GNE_CM_EBI_Plan_Accumulator__c> groupCheckedSet = new Set<GNE_CM_EBI_Plan_Accumulator__c>();
                Set<String> planAccumulatorSuffixes = new Set<String>{
                    'deductible',
                    'deductible met',
                    'cost share',
                    'oop max',
                    'oop met'
                };
                
                for (String suffix : planAccumulatorSuffixes) {
                    List<GNE_CM_EBI_Plan_Accumulator__c> tempGrouping = new List<GNE_CM_EBI_Plan_Accumulator__c>();

                    for (GNE_CM_EBI_Plan_Accumulator__c pa : planAccumulators) {
                        if (pa.Value_Name_gne__c.toLowerCase().endsWith(suffix)) {
                            tempGrouping.add(pa);
                        }
                    }
                    if (tempGrouping.size() > 0) {
                        planAccumulatorsGroupedBySuffix.put(suffix, tempGrouping);
                    }
                }
                System.debug('planAccumulatorsGroupedBySuffix are: '+planAccumulatorsGroupedBySuffix);

                for (String suffix : planAccumulatorsGroupedBySuffix.keyset()) {
                    Boolean groupAllEmpty = true;
                    // AND check between same suffix plan accumulators - at least one must have a value
                    for (GNE_CM_EBI_Plan_Accumulator__c pa : planAccumulatorsGroupedBySuffix.get(suffix)) {
                        if (!String.isBlank(pa.Value_Result_gne__c)) {
                            groupAllEmpty = false;
                            continue;
                        }
                    }
                    if (groupAllEmpty) {
                        errorList.add('Plan Accumulators ending with '+suffix+' all contained empty values');
                    }
                }

                // to except out in the below block, since already checked as a group
                for (List<GNE_CM_EBI_Plan_Accumulator__c> tempList : planAccumulatorsGroupedBySuffix.values()) {
                    groupCheckedSet.addAll(tempList);
                }

                for (GNE_CM_EBI_Plan_Accumulator__c pa : planAccumulators) {
                    if (String.isBlank(pa.Value_Name_gne__c)) {
                        errorList.add('Plan Accumulator with Id ' + pa.Id + ' contains empty Value_Name_gne__c field');
                        continue;
                    }
                    if (GNE_CM_EBI_Util.PA_PLAN_OFFICE_COPAY.equalsIgnoreCase(pa.Value_Name_gne__c)) {
                        if (String.isNotBlank(pa.Value_Result_gne__c) && 'Multiple Found; click View Full Response to review all copays reported by the Payer. (046)'.equalsIgnoreCase(pa.Value_Result_gne__c)) {
                            errorList.add('Plan office copay is not valid value');
                        }
                        continue;
                    }
                    if (String.isBlank(pa.Value_Result_gne__c) && !groupCheckedSet.contains(pa)) {
                        errorList.add('Plan Accumulator ' + pa.Value_Name_gne__c + ' contains empty value');
                        continue;
                    }
                    if (!String.isBlank(pa.Value_Result_gne__c)) {
                        String value = pa.Value_Result_gne__c.endsWith('*') ? GlobalUtils.trimRight(pa.Value_Result_gne__c, '*') : pa.Value_Result_gne__c;
                        value = value.endsWith('%') ? GlobalUtils.trimRight(value, '%') : value;
                        value = value.replaceAll(',', '');
                        try {
                            Decimal.valueOf(value);
                        }
                        catch (TypeException te) {
                            errorList.add('Plan Accumulator ' + pa.Value_Name_gne__c + ' contains invalid value');
                        }
                    }
                }
            }

        }
        
        return String.join(errorList, '\n');
    }
}