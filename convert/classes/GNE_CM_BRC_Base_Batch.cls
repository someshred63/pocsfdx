public abstract class GNE_CM_BRC_Base_Batch
{
    protected String productName;

    protected final String BRC_STATUS = 'Draft';
    protected final Date CURRENT_DATE = Date.today();
    protected final Integer CURRENT_DAY = this.CURRENT_DATE.day();
    protected final Integer CURRENT_MONTH = this.CURRENT_DATE.month();
    protected final Integer CURRENT_YEAR = this.CURRENT_DATE.year();
    protected final String IN_NETWORK = 'In Network Benefits';    
    protected final String INSURANCE_BILL_LEVEL_1 = '1';
    protected final String INSURANCE_BILL_LEVEL_2 = '2';
    protected final String INSURANCE_RANK_PRIMARY = 'Primary';
    protected final String INSURANCE_RANK_SECONDARY = 'Secondary';

    protected Boolean debugMode = false;

    protected String addressFilterConditions,patientFilterConditions,caseFilterConditions;

    private final List<String> invalidCaseStatuses = new List<String>{
        'Closed. Non-Compliance to Tx',
        'Closed. Adverse Reaction',
        'Closed. Therapy Complete',
        'Closed. Patient Deceased',
        'Closed. No Response to Tx',
        'Closed. Copay Unaffordable',
        'Closed. Created in Error',
        'Closed. Family chose competitor',
        'Closed. MD Decision',
        'Closed. MD unsatisfied w/AccSolns',
        'Closed. Tx Declined, Family Decision',
        'Closed. Payer dictated comp. drug use',
        'Closed. Referred In Error',
        'Closed. MD chose competitor',
        'Closed. GATCF Non-Compliant',
        'Pending APA Program Expenditure',
        'Closed. Dist. Unsatisfied w/AccSolns',
        'Closed. TX Denied'
    };

    protected Map<Id,Set<GNE_CM_MPS_Practice_Agreement_Location__c>> addressIdsToPALs = new Map<Id,Set<GNE_CM_MPS_Practice_Agreement_Location__c>>();
    
    
    //protected Set<Id> registrationIds = new Set<Id>();
    
    protected List<Error_Log_gne__c> executeErrors = new List<Error_Log_gne__c>();

    protected String mapInsuranceProductTypeToPER(String pt)
    {
        if (pt == 'Indemnity' || pt == 'POS' || pt == 'PPO') {
            return pt;
        }
        if (pt == 'EPO' || pt == 'HMO') {
            return 'HMO/EPO';
        }
        if (pt == 'Managed Medicaid' || pt == 'Medicare Part A' || pt == 'Medicare Part B' || pt == 'Medicare Advantage (Part C)' || pt == 'Medicare Supplemental') {
            return 'Medicare/ Medicaid';
        }
        return null;
    }

    // default for Actemra and Lucentis, override for Rituxan RA
    public virtual Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        String palQuery = 'SELECT Id, Account__c, Address__c, Address__r.Location_Specific_Preferences_gne__c, Address__r.Proactive_BI_Opt_In_gne__c,'
                        +' MPS_Registration__c, MPS_Practice_Agreement__c, MPS_Practice_Agreement__r.MPS_Prescriber__c, MPS_Location__c'
                        +' FROM GNE_CM_MPS_Practice_Agreement_Location__c '
                        + (String.isNotBlank(this.addressFilterConditions) ? this.addressFilterConditions : '');
        List<GNE_CM_MPS_Practice_Agreement_Location__c> pals = Database.query(palQuery);
        for (GNE_CM_MPS_Practice_Agreement_Location__c pal : pals)
        {
            if (pal.MPS_Registration__c == null || pal.MPS_Practice_Agreement__c == null || (pal.Address__r.Location_Specific_Preferences_gne__c !=null && pal.Address__r.Location_Specific_Preferences_gne__c.contains('Automatic Yearly BI Opt Out'))) {
                continue;
            }
            if (!this.addressIdsToPALs.containsKey(pal.Address__c)) {
                this.addressIdsToPALs.put(pal.Address__c, new Set<GNE_CM_MPS_Practice_Agreement_Location__c>());
            }
            this.addressIdsToPALs.get(pal.Address__c).add(pal);
        }
        
        String query = 'SELECT Id, PAN_Form_1_Product_gne__c, PAN_Form_1_Expiration_Date_gne__c, PAN_Form_2_Product_gne__c, PAN_Form_2_Exipration_Date_gne__c'
            +' FROM Patient_gne__c'
            +' WHERE pat_patient_deceased_gne__c != \'Yes\''
            +' AND Active_GATCF_Case__c = false '
            + (String.isNotBlank(this.patientFilterConditions) ? this.patientFilterConditions : '');
            
        return Database.getQueryLocator(query);
    }

    // default for Actemra, Lucentis and Rituxan RA
    public virtual void execute(Database.BatchableContext BC, List<Patient_gne__c> scope)
    {
        
        Integer queryLimit = Limits.getLimitQueryRows()-1000;
        Set<Id> addressIds = this.addressIdsToPALs.keySet();
        addressIds.remove(null);

        GNE_CM_MPS_Custom_Setting__c mpsConfig = GNE_CM_MPS_Custom_Setting__c.getInstance('MPS_Configuration');
        Date brCaseEligibilityStartDate = mpsConfig.Blizzard_Case_Eligibility_Start_Date__c;
        Set<Case> brCases = new Set<Case>();
        Set<Id> brCaseIds = new Set<Id>();

        Map<Id,Patient_gne__c> patientIdsToPatients = new Map<Id,Patient_gne__c>(scope);
        Map<String,Case> compositeKeyToMostRecentCases = new Map<String,Case>();
        String contextName = 'GNE_CM_BRC_'+this.productName+'_Batch.execute';

        try 
        {
            String query = 'SELECT BI_Insurance_gne__r.Case_Insurance_gne__r.Medical_History_gne__c, BI_Insurance_gne__r.Case_Insurance_gne__r.Id,BI_Insurance_gne__r.Case_Insurance_gne__r.CreatedDate,'
                            +' BI_Insurance_gne__r.Case_Insurance_gne__r.Case_Treating_Physician_gne__c,BI_Insurance_gne__r.Case_Insurance_gne__r.Patient_gne__c,'
                            +' BI_Insurance_gne__r.Case_Insurance_gne__r.Product_gne__c,BI_Insurance_gne__r.Case_Insurance_gne__r.Address_gne__c'
                            +' FROM Benefit_Investigation_gne__c'
                            +' WHERE BI_Insurance_gne__r.Rank_gne__c =:INSURANCE_RANK_PRIMARY'
                            +' AND Print_on_BI_Report_gne__c = \'Yes\''         
                            +' AND BI_Insurance_gne__r.Case_Insurance_gne__r.Patient_gne__c in :scope'
                            +' AND BI_Insurance_gne__r.Case_Insurance_gne__r.Product_gne__c = :productName'
                            +' AND BI_Insurance_gne__r.Case_Insurance_gne__r.RecordType.Name = \'C&R - Standard Case\''
                            +' AND BI_Insurance_gne__r.Case_Insurance_gne__r.Status NOT IN:invalidCaseStatuses'
                            +' AND BI_Insurance_gne__r.Case_Insurance_gne__r.Address_gne__c IN :addressIds'
                            +' AND BI_Insurance_gne__r.Case_Insurance_gne__r.CreatedDate>=:brCaseEligibilityStartDate'
                            + (String.isNotBlank(this.caseFilterConditions) ? this.caseFilterConditions : '')
                            +' ORDER BY BI_Insurance_gne__r.Case_Insurance_gne__r.CreatedDate DESC'
                            +' LIMIT :queryLimit';
        
            System.debug('query==='+query);
            for (Benefit_Investigation_gne__c bi : Database.query(query)) 
            {
                Case c = bi.BI_Insurance_gne__r.Case_Insurance_gne__r;
                // Skip if address is null or no eligible PALs found
                if (c.Address_gne__c == null 
                    || !this.addressIdsToPALs.containsKey(c.Address_gne__c)) 
                {
                    continue;
                }
                
                // cache the most recent Case for a given Patient within a given Registration (based on Practice Agreement Location)

                for (GNE_CM_MPS_Practice_Agreement_Location__c pal : this.addressIdsToPALs.get(c.Address_gne__c))
                {
                    String compositeKey = c.Patient_gne__c + '_' + pal.MPS_Registration__c;
                    System.debug('compositeKey===='+compositeKey);
                    if (!compositeKeyToMostRecentCases.containsKey(compositeKey)) {
                        compositeKeyToMostRecentCases.put(compositeKey,c);
                        brCaseIds.add(c.Id);
                        brCases.add(c);
                    }
                    
                }
            }//end for on Cases

            System.debug('brCases==='+brCases);
            System.debug('compositeKeyToMostRecentCases===='+compositeKeyToMostRecentCases);
            /*Gather all the BR eligible Cases for all patients in one list and use this list to 
                1)Gather additional information about Fulfillments, Insurances, Benefit Investigations
                2)Check Eligibility criteria based on whether Case has Benefit Investigation
            */
            List<GNE_CM_MPS_BRC_RituxanRA__c> brsToInsert = this.getBRsToInsert(brCases,brCaseIds,patientIdsToPatients);
            if(!brsToInsert.isEmpty())
            {
                List<String> patientIdsBeingProcessed = new List<String>();
                for(GNE_CM_MPS_BRC_RituxanRA__c br: brsToInsert){
                    patientIdsBeingProcessed.add(br.Patient_Id_gne__c);
                }
                List<Database.SaveResult> brInsertResults = Database.insert(brsToInsert,false);
                
                //Since list is ordered, we know that the index of the patient matches the index of the corresponding br record.
                GNE_CM_MPS_Utils.createAndLogErrors(brInsertResults, 'Error in Batch while inserting Benefit Reverification records for patients with IDs : {0}', new List<String>{String.join(patientIdsBeingProcessed,',')}, 'GNE_CM_MPS_BRC_RituxanRA__c', contextName, brsToInsert);   
            }
            
        }
        catch (Exception ex) {
            system.debug('Error occured while processing Batch scope: ' + ex.getStackTraceString());
            GNE_CM_MPS_Utils.createAndLogErrors(new List<Database.SaveResult>(), 'Exception in Batch while inserting Benefit Reverification records for patients in scope:{0} The exception message is: {1}', new List<String>{String.join(new List<Id>(patientIdsToPatients.keySet()),','),GlobalUtils.getExceptionDescription(ex)}, 'GNE_CM_MPS_BRC_RituxanRA__c', contextName,null);
            
        }
    }//end execute()

    public virtual List<GNE_CM_MPS_BRC_RituxanRA__c> getBRsToInsert(Set<Case> brCases,Set<Id> brCaseIds, Map<Id,Patient_gne__c> patientIdsToPatients )
    {
        Integer queryLimit = Limits.getLimitQueryRows()-1000;
        List<GNE_CM_MPS_BRC_RituxanRA__c> brcsToInsert = new List<GNE_CM_MPS_BRC_RituxanRA__c>();
        Map<Id,Benefit_Investigation_gne__c> brCaseIdsToPrimaryBIs = new Map<Id,Benefit_Investigation_gne__c>();
        Map<Id,Benefit_Investigation_gne__c> brCaseIdsToSecondaryBIs = new Map<Id,Benefit_Investigation_gne__c>();
        Map<Id,String> brCaseIdsToAccountNames = new Map<Id,String>();
        Map<Id,Insurance_gne__c> brCaseIdsToPrimaryInsurances = new Map<Id,Insurance_gne__c>();
        Map<Id,Insurance_gne__c> brCaseIdsToSecondaryInsurances = new Map<Id,Insurance_gne__c>();

        // cache Insurances for all Cases in scope;
        // there may be multiple primary/secondary Insurances for a given Case, but we only care for the most recent ones
        for (Insurance_gne__c i : [
            SELECT Id, Can_Contact_gne__c, Case_Insurance_gne__c, Subscriber_DOB_gne__c, ins_eligible_for_Medicare_Part_D_gne__c, Employer_gne__c,
                Employer_Phone_gne__c, Group_Num_gne__c, ins_Insurance_gne__c, Main_Payer_gne__c, ins_Network_IPA_gne__c,
                Patient_Insurance_gne__c, Patient_Relationship_to_Subscriber_gne__c, Payer_gne__c, Payer_Ph_Provided_by_Customer_gne__c,
                Payer_Type_gne__c, Plan_gne__c, Plan_Product_gne__c, Payer_gne__r.Name, Plan_Product_Type_gne__c, Plan_Type_gne__c, Policy_Number_gne__c,
                Product_Insurance_gne__c, Profile_Type_gne__c, Program_Type_gne__c, Rank_gne__c, Region_Code_gne__c, Release_gne__c,
                Self_Funded_gne__c, ssn_gne__c, Subscriber_Num_gne__c, Subscriber_Name_gne__c, Termination_Date_gne__c,
                Subscriber_First_Name_gne__c
            FROM Insurance_gne__c
            WHERE Case_Insurance_gne__c IN :brCaseIds
            ORDER BY CreatedDate DESC
            LIMIT :queryLimit
        ]) 
        {
            if (i.Rank_gne__c == this.INSURANCE_RANK_PRIMARY && !brCaseIdsToPrimaryInsurances.containsKey(i.Case_Insurance_gne__c)) {
                brCaseIdsToPrimaryInsurances.put(i.Case_Insurance_gne__c, i);
            }
            else if (i.Rank_gne__c == this.INSURANCE_RANK_SECONDARY && !brCaseIdsToSecondaryInsurances.containsKey(i.Case_Insurance_gne__c)) {
                brCaseIdsToSecondaryInsurances.put(i.Case_Insurance_gne__c, i);
            }
        }

        // cache Benefit Investigations for all Cases in scope
        // there may be multiple primary/secondary BIs for a given Case, but we only care for the most recent ones
        for (Benefit_Investigation_gne__c bi : [
            SELECT Id, BI_Insurance_gne__r.Case_Insurance_gne__c, BI_Insurance_gne__r.Rank_gne__c, BI_Insurance_gne__r.Bill_Level_gne__c, Product_Covered_By_gne__c,
                BI_Insurance_gne__r.Subscriber_Name_gne__c, IN_Prior_Authorization_Required_gne__c, ON_Prior_Authorization_Required_gne__c
            FROM Benefit_Investigation_gne__c
            WHERE BI_Insurance_gne__r.Case_Insurance_gne__c IN :brCaseIds
            AND Print_on_BI_Report_gne__c = 'Yes'
            ORDER BY CreatedDate DESC
            LIMIT :queryLimit
        ]) 
        {
            if (bi.BI_Insurance_gne__r.Rank_gne__c ==  this.INSURANCE_RANK_PRIMARY &&
                //bi.BI_Insurance_gne__r.Bill_Level_gne__c == this.INSURANCE_BILL_LEVEL_1 &&
                !brCaseIdsToPrimaryBIs.containsKey(bi.BI_Insurance_gne__r.Case_Insurance_gne__c)
            ) {
                brCaseIdsToPrimaryBIs.put(bi.BI_Insurance_gne__r.Case_Insurance_gne__c, bi);
            }
            else if (bi.BI_Insurance_gne__r.Rank_gne__c ==  this.INSURANCE_RANK_SECONDARY &&
                //bi.BI_Insurance_gne__r.Bill_Level_gne__c == this.INSURANCE_BILL_LEVEL_2 &&
                !brCaseIdsToSecondaryBIs.containsKey(bi.BI_Insurance_gne__r.Case_Insurance_gne__c)
            ) {
                brCaseIdsToSecondaryBIs.put(bi.BI_Insurance_gne__r.Case_Insurance_gne__c, bi);
            }
        }

        // cache Fulfillments fo all Cases in scope;
        // assuming there is exactly one Fulfillment for a given Case
        String fulfillmentValue = null;
        for (Fulfillment_gne__c f : [
            SELECT Id, Case_Fulfillment_gne__c, Patient_fulfillment_gne__c, Fulfillment_Pending_Status_Reason_gne__c,
                In_network_name_gne__c, In_network_name_gne__r.Name, In_Network_Selected_Distributor_gne__c,
                Out_network_Name_gne__c, Out_network_name_gne__r.Name, Out_Network_Selected_Distributor_gne__c
            FROM Fulfillment_gne__c
            WHERE Case_Fulfillment_gne__c IN :brCaseIds
            LIMIT :queryLimit
        ]) 
        {
            if (f.In_Network_Selected_Distributor_gne__c == 'Yes' && f.Out_Network_Selected_Distributor_gne__c == 'Yes') {
                fulfillmentValue = '';
            }
            else if (f.In_Network_Selected_Distributor_gne__c == 'Yes') {
                fulfillmentValue = f.In_network_name_gne__r.Name;
            }
            else if (f.Out_Network_Selected_Distributor_gne__c == 'Yes') {
                fulfillmentValue = f.Out_network_name_gne__r.Name;
            }
            brCaseIdsToAccountNames.put(f.Case_Fulfillment_gne__c, fulfillmentValue);
        }

        //This is to prevent duplicate BRs when same address is mapped to same MPS REG via multiple PALs.
        Set<String> compositeKeySet = new Set<String>();

        for (Case c : brCases) 
        {
            Benefit_Investigation_gne__c primaryBI = brCaseIdsToPrimaryBIs.get(c.Id);
            if ((this.productName == 'Actemra' || this.productName == 'Lucentis') && primaryBI == null) {
                continue;
            }
            Benefit_Investigation_gne__c secondaryBI = brCaseIdsToSecondaryBIs.get(c.Id);
            Insurance_gne__c primaryInsurance = brCaseIdsToPrimaryInsurances.get(c.Id);
            Insurance_gne__c secondaryInsurance = brCaseIdsToSecondaryInsurances.get(c.Id);
            Patient_gne__c patient = patientIdsToPatients.get(c.Patient_gne__c);
            String specialtyPharmacyName = brCaseIdsToAccountNames.get(c.Id);
            
            // create one GNE_CM_MPS_BRC_RituxanRA__c record for each PAL with Address matching that of the Case currently processed;
            // disregard non-recent Cases;
            // this will lead for aparent duplicates for a given Case;
            // skip if no eligible PALs found
            if (!this.addressIdsToPALs.containsKey(c.Address_gne__c)) {
                continue;
            }
            for (GNE_CM_MPS_Practice_Agreement_Location__c pal : this.addressIdsToPALs.get(c.Address_gne__c)) 
            {
                String compositeKey = c.Patient_gne__c + '_' + pal.MPS_Registration__c;
                //If a BR record already exists for this patient and MPS REG combination, skip the current PAL.
                if(compositeKeySet.contains(compositeKey)){
                    continue;
                }
                compositeKeySet.add(compositeKey);

                // set Case related field values
                GNE_CM_MPS_BRC_RituxanRA__c brc = new GNE_CM_MPS_BRC_RituxanRA__c(
                    Case_gne__c = c.Id,
                    medical_history__c = c.Medical_History_gne__c,
                    Patient_Id_gne__c = c.Patient_gne__c,
                    Product_gne__c = c.Product_gne__c,
                    Address_gne__c = c.Address_gne__c,
                    Cycle_Start_Date_gne__c = this.CURRENT_DATE,
                    Anticipated_Date_of_Treatment__c = Date.newInstance(this.CURRENT_YEAR + 1, 1, c.CreatedDate.day()),
                    Prescriber_Id_Name_gne__c = c.Case_Treating_Physician_gne__c,
                    Status_gne__c = this.BRC_STATUS
                );                  
                brc.Cycle_End_Date_gne__c = this.CURRENT_DAY < 16
                    ? Date.newInstance(this.CURRENT_YEAR, this.CURRENT_MONTH, Date.daysInMonth(this.CURRENT_YEAR, this.CURRENT_MONTH))
                        : Date.newInstance(this.CURRENT_YEAR, this.CURRENT_MONTH, 15).addMonths(1);
                
                // set BI related field values
                if (primaryBI != null) {
                    brc.Pri_Prior_Auth_Reqd_gne__c = primaryBI.Product_Covered_By_gne__c == this.IN_NETWORK
                        ? primaryBI.IN_Prior_Authorization_Required_gne__c
                            : primaryBI.ON_Prior_Authorization_Required_gne__c;
                }
                if (secondaryBI != null) {
                    brc.Sec_Prior_Auth_Reqd__c = secondaryBI.Product_Covered_By_gne__c == this.IN_NETWORK
                        ? secondaryBI.IN_Prior_Authorization_Required_gne__c
                            : secondaryBI.ON_Prior_Authorization_Required_gne__c;
                }
                
                // set Insurance related field values
                if (primaryInsurance != null || secondaryInsurance != null) {
                    brc.Is_Patient_Insured__c = 'Yes';
                }
                if (primaryInsurance != null) {
                    brc.Primary_Insurance_Select_Type__c = this.mapInsuranceProductTypeToPER(primaryInsurance.Plan_Product_Type_gne__c);
                    brc.Primary_Insurance_PI_Name__c = GNE_CM_MPS_Utils.trimStringToMaxLength(primaryInsurance.Payer_gne__r.Name,80);
                    brc.PI_Phone_gne__c = primaryInsurance.Payer_Ph_Provided_by_Customer_gne__c;
                    brc.PI_Subscriber_Name__c = GNE_CM_MPS_Utils.trimStringToMaxLength(primaryInsurance.Subscriber_Name_gne__c,80);
                    brc.PI_Subscriber_ID__c = primaryInsurance.Subscriber_Num_gne__c;
                    brc.PI_Policy_Group_gne__c = primaryInsurance.Policy_Number_gne__c;
                    brc.PI_Subscriber_First_Name__c = GNE_CM_MPS_Utils.trimStringToMaxLength(primaryInsurance.Subscriber_First_Name_gne__c,80);
                }
                if (secondaryInsurance != null) {
                    brc.Secondary_Insurance_Select_Type__c = this.mapInsuranceProductTypeToPER(secondaryInsurance.Plan_Product_Type_gne__c);
                    brc.Secondary_Insurance_SI_Name__c = GNE_CM_MPS_Utils.trimStringToMaxLength(secondaryInsurance.Payer_gne__r.Name,80);
                    brc.SI_Phone__c = secondaryInsurance.Payer_Ph_Provided_by_Customer_gne__c;
                    brc.SI_Subscriber_Name__c = GNE_CM_MPS_Utils.trimStringToMaxLength(secondaryInsurance.Subscriber_Name_gne__c,80);
                    brc.SI_Subscriber_ID__c = secondaryInsurance.Subscriber_Num_gne__c;
                    brc.SI_Policy_Group__c = secondaryInsurance.Policy_Number_gne__c;
                    brc.SI_Subscriber_First_Name__c = GNE_CM_MPS_Utils.trimStringToMaxLength(secondaryInsurance.Subscriber_First_Name_gne__c,80);
                }
                
                // set Patient related field values
                if (patient != null) {
                    Date expirationDate = null;
                    if (patient.PAN_Form_1_Product_gne__c == this.productName) {
                        expirationDate = patient.PAN_Form_1_Expiration_Date_gne__c;
                    }
                    else if (patient.PAN_Form_2_Product_gne__c == this.productName) {
                        expirationDate = patient.PAN_Form_2_Exipration_Date_gne__c;
                    }
                    brc.PAN_Expiration_Date_gne__c = expirationDate;
                }
                
                // set Fulfillment-related field values
                brc.Specialty_Pharmacy_Name__c = specialtyPharmacyName;
                
                // set Practice Agreement Location related field values
                brc.MPS_Registration_gne__c = pal.MPS_Registration__c;
                brc.MPS_Location_gne__c = pal.MPS_Location__c;
                brc.MPS_Prescriber_gne__c = pal.MPS_Practice_Agreement__r.MPS_Prescriber__c;
                
                if (this.productName == 'Actemra') {
                    Date adot= Date.newInstance(Date.today().year() + 1, 1, c.CreatedDate.day());

                    //If the calculated ADOT is < Eligible ADOT Start Date, set it to the eligible ADOT start date. Otherwise, leave it as is.
                    if(adot < GNE_CM_Blizzard_Utils.ELIGIBLE_ADOT_START_DATE){
                        adot = GNE_CM_Blizzard_Utils.ELIGIBLE_ADOT_START_DATE;
                    }
                    brc.Anticipated_Date_of_Treatment__c = GNE_CM_MPS_Utils.getNextBusinessDay(adot);
                }else if(this.productName == 'Lucentis') {
                    brc.Anticipated_Date_of_Treatment__c = null;
                }

                brcsToInsert.add(brc);
            }//end for on PALs
        }//end for on Cases
        return brcsToInsert;
    }//end getBRsToInsert

    // default for Actemra and Lucentis, override for Rituxan RA
    public virtual void finish(Database.BatchableContext BC)
    {
        //insert this.executeErrors;
        
        /*
        Feature is Here email is sent separately using the Benefits_Reverification_Schedulers_gne__c table now. 
        if (!this.debugMode) {
            this.sendEmailsOnFinish();
        }*/
    }
    
    public virtual void sendEmailsOnFinish()
    {
        Set<Id> registrationIds = new Set<Id>();
        for (Set<GNE_CM_MPS_Practice_Agreement_Location__c> pals : this.addressIdsToPALs.values()) {
            for (GNE_CM_MPS_Practice_Agreement_Location__c pal : pals) {
                if (pal.Address__r.Proactive_BI_Opt_In_gne__c == true) {
                    registrationIds.add(pal.MPS_Registration__c);
                }
            }
        }
        if (!registrationIds.isEmpty()) {
            GNE_CM_MPS_BenefitReverificationEmail.emailToMPSUsers(registrationIds, this.productName);
        }
    }
}