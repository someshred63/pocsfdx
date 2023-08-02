/**
 * Groups information about payer for display in different MPS BI forms.
 * @author Radek Krawiec, Roche
 * @created 08/01/2013
 */
public with sharing class GNE_CM_MPS_BI_Payer_Info
{
    public Map<String, NameValuePair> fieldsByName { get; private set; }
    public String payerRank { get; set; }
    public String payerName { get; set; }
    public String planType { get; set; }
    public String planName { get; set; }
    public String benefitType { get; set; }
    public String subscriberId { get; set; }
    public String groupId { get; set; }
    public String effectiveDate { get; set; }
    public String eligibilityPeriod { get; set; }
    public String biObtainedDate { get; set; }
    public String payerPhone { get; set; }
    public String biReferenceContact { get; set; }
    public String biReferenceNumber { get; set; }
    public String billingInstructions { get; set; }
    
    public String prescribingPhysician { get; set; }
    public String icd9Code { get; set; }
    public String icd9Code2 { get; set; }
    public String icd9Code3 { get; set; }
    public String patientDOB { get; set; }
    public String patientName { get; set; }
    public String product { get; set; }
    public String inProductCoverage { get; set; }
    public String onProductCoverage { get; set; }
    
    public String lowIncomeSubsidy { get; set; }
    public String drugTierLevels { get; set; }
    public String stage1Deductible { get; set; }
    public String deductibleMet { get; set; }
    public String deductibleAmountMet { get; set; }
    public String stage2CopayCoinsurance { get; set; }
    public String initialCoverageStageLimit { get; set; }
    public String initialCoverageAmountMet { get; set; }
    public String daySupply { get; set; }
    public String stage3CoverageGapLimit { get; set; }
    public String coverageGapAmountMet { get; set; }
    public String catastrophicStageCopayCoIns { get; set; }
    
    public Boolean isMedicare { get; set; }
    
    public static String NOT_APPLICABLE = '';
    
    public GNE_CM_MPS_BI_Payer_Info (Benefit_Investigation_gne__c bi)
    {
        // set effective date
        if (bi.Effective_Date_gne__c <> NULL)
        {
            String[] efdt = String.valueOf(bi.Effective_Date_gne__c).split('-');
            String effect = efdt.get(1) + '/' + efdt.get(2) + '/' + efdt.get(0); 
            this.effectiveDate = effect;
        }
        else
        {
            this.effectiveDate = NOT_APPLICABLE;
        }
        
        this.prescribingPhysician = bi.Physician_Full_Name_gne__c;
        this.icd9Code = bi.ICD9_Code_gne__c;
        this.icd9Code2 = bi.ICD9_Code2_gne__c;
        this.icd9Code3 = bi.ICD9_Code3_gne__c;
        //this.patientName = String.valueOf(bi.Patient_Full_Name_gne__c);
        this.patientName = String.valueOf(bi.Patient_BI_gne__r.Full_Name_gne__c);
        if (bi.Patient_BI_gne__r.pat_dob_gne__c != null)
        {
            String[] dobDt = String.valueOf(bi.Patient_BI_gne__r.pat_dob_gne__c).split('-');
            String dobDate = dobDt.get(1) + '/' + dobDt.get(2) + '/' + dobDt.get(0); 
            this.patientDOB = dobDate;
        } 
        else
        {
            this.patientDOB = NOT_APPLICABLE;
        }
        this.product = GlobalUtils.coalesce(bi.Product_BI_gne__c, NOT_APPLICABLE);
        this.inProductCoverage = bi.IN_ProductCoverage_gne__c;
        this.onProductCoverage = bi.ON_ProductCoverage_gne__c;
        this.payerRank = GlobalUtils.coalesce(bi.BI_Insurance_gne__r.Rank_gne__c, NOT_APPLICABLE);
        this.payerName = GlobalUtils.coalesce(bi.Payer_BI_gne__r.Name, NOT_APPLICABLE);
        //this.planName = GlobalUtils.coalesce(bi.BI_Insurance_gne__r.Plan_gne__r.Name, NOT_APPLICABLE);
        this.planName = (String.isEmpty(bi.eBI_Plan_Plan_Product_gne__c) ? GlobalUtils.coalesce(bi.BI_Insurance_gne__r.Plan_gne__r.Name, NOT_APPLICABLE) : GlobalUtils.coalesce(bi.eBI_Plan_Plan_Product_gne__c, NOT_APPLICABLE));
        this.planType = GlobalUtils.coalesce(bi.BI_Insurance_gne__r.Plan_Type_gne__c, NOT_APPLICABLE);
        this.benefitType = GlobalUtils.coalesce(bi.Benefit_Type_gne__c, NOT_APPLICABLE);
        this.subscriberId = GlobalUtils.coalesce(bi.BI_Insurance_gne__r.Subscriber_Num_gne__c, NOT_APPLICABLE);
        this.groupId = GlobalUtils.coalesce(bi.BI_Insurance_gne__r.Group_Num_gne__c, NOT_APPLICABLE);
        this.eligibilityPeriod = GlobalUtils.coalesce(bi.Plan_Year_gne__c, NOT_APPLICABLE);
        if (bi.BI_Obtained_Date_gne__c != null)
        {
            String[] obdt = String.valueOf(bi.BI_Obtained_Date_gne__c.date()).split('-');
            String obtainDate = obdt.get(1) + '/' + obdt.get(2) + '/' + obdt.get(0); 
            this.biObtainedDate = obtainDate;
        } 
        else
        {
            this.biObtainedDate = NOT_APPLICABLE;
        }
        this.payerPhone = GlobalUtils.coalesce(bi.BI_Contact_Phone_gne__c, NOT_APPLICABLE);
        this.biReferenceContact = GlobalUtils.coalesce(bi.BI_Contact_Name_gne__c, NOT_APPLICABLE);
        this.biReferenceNumber = GlobalUtils.coalesce(bi.BI_Reference_num_gne__c, NOT_APPLICABLE);
        this.billingInstructions = GlobalUtils.coalesce(bi.Billing_Instructions_gne__c, NOT_APPLICABLE);
        
        this.fieldsByName = new Map<String, NameValuePair>();
        
        addFieldValue ('Product Rx Covered', bi.IN_RXCovered_gne__c, bi.ON_RXCovered_gne__c);
        addFieldValue ('Billing Code', bi.IN_BillingCode_gne__c, bi.ON_BillingCode_gne__c);
        addFieldValue ('Billing Prior Auth/PreD Required', bi.IN_PriorAuthReq_gne__c, bi.ON_PriorAuthReq_gne__c);
        addFieldValue ('Admin Code', bi.IN_AdminCodes_gne__c, bi.ON_AdminCodes_gne__c);
        addFieldValue ('Admin Prior Auth/PreD Required', bi.IN_AdminPriorAuthReq_gne__c, bi.ON_AdminPriorAuthReq_gne__c);
        addFieldValue ('Billing Code Pt Deductible', bi.IN_BillingCodeDeduct_gne__c, bi.ON_BillingCodeDeduct_gne__c);
        addFieldValue ('Individual Deductible', currency(bi.IN_IndDeduct_gne__c), currency(bi.ON_IndDeduct_gne__c));
        addFieldValue ('Individual Deductible Met', currency(bi.IN_IndDeductMet_gne__c), currency(bi.ON_IndDeductMet_gne__c));
        addFieldValue ('Family Deductible', currency(bi.IN_FamDeduct_gne__c), currency(bi.ON_FamDeduct_gne__c));
        addFieldValue ('Family Deductible Met', currency(bi.IN_FamDeductMet_gne__c), currency(bi.ON_FamDeductMet_gne__c));
        addFieldValue ('Insurer Cost Share', formatPercent(bi.IN_InsCostShares_gne__c), formatPercent(bi.ON_InsCostShares_gne__c));
        addFieldValue ('Patient Cost Share', formatPatientCostShare(bi.IN_Patient_Cost_Share_gne__c), formatPatientCostShare(bi.ON_Patient_Cost_Share_gne__c));
        
		addFieldValue ('Office Co-pay', bi.IN_Office_Copay_gne__c != null && GlobalUtils.isDecimal(bi.IN_Office_Copay_gne__c) ? currency(bi.IN_Office_Copay_gne__c) : GlobalUtils.coalesce(bi.IN_Office_Copay_gne__c, ''), bi.ON_Office_Copay_gne__c != null && GlobalUtils.isDecimal(bi.ON_Office_Copay_gne__c) ? currency(bi.ON_Office_Copay_gne__c) : GlobalUtils.coalesce(bi.ON_Office_Copay_gne__c, ''));
        
        addFieldValue ('Individual Out of Pocket Max', currency(bi.IN_Individual_Out_Of_Pocket_Max_gne__c), currency(bi.ON_Individual_Out_Of_Pocket_Max_gne__c));
        addFieldValue ('Individual Out of Pocket Max Met', currency(bi.IN_Individual_Out_Of_Pocket_Max_Met_gne__c), currency(bi.ON_Individual_Out_Of_Pocket_Max_Met_gne__c));
        addFieldValue ('Family Out of Pocket Max', currency(bi.IN_Family_Out_Of_Pocket_Max_gne__c), currency(bi.ON_Family_Out_Of_Pocket_Max_gne__c));
        addFieldValue ('Family Out of Pocket Max Met', currency(bi.IN_Family_Out_Of_Pocket_Max_Met_gne__c), currency(bi.ON_Family_Out_Of_Pocket_Max_Met_gne__c));
        addFieldValue ('Deductible(s) Applies to Out of Pocket Max', bi.IN_Deductible_App_to_Out_Of_Pocket_gne__c, bi.ON_Deductible_App_to_Out_Of_Pocket_gne__c);
        addFieldValue ('Annual Benefit Max', bi.IN_AnnualBenefitMax_gne__c, bi.ON_AnnualBenefitMax_gne__c);
        addFieldValue ('Buy and Bill', bi.IN_Buy_and_Bill_Available_Formula_gne__c, bi.ON_Buy_and_Bill_Available_Formula_gne__c);
        addFieldValue ('Specialty Pharmacy Available', bi.IN_Specialty_Pharmacy_Avail_Formula_gne__c, bi.ON_Specialty_Pharmacy_Avail_Formula_gne__c);
        addFieldValue ('Specialty Pharmacy Required', bi.IN_Specialty_Pharmacy_Req_Formula_gne__c, bi.ON_Specialty_Pharmacy_Req_Formula_gne__c);
        
        // Specialty Pharmacy/Phone/Fax
        addFieldValue ('Specialty Pharmacy/Phone/Fax 1', bi.IN_SpecPharm_1_gne__c, bi.ON_SpecPharm_1_gne__c);
        addFieldValue ('Specialty Pharmacy/Phone/Fax 2', bi.IN_SpecPharm_2_gne__c, bi.ON_SpecPharm_2_gne__c);
        addFieldValue ('Specialty Pharmacy/Phone/Fax 3', bi.IN_SpecPharm_3_gne__c, bi.ON_SpecPharm_3_gne__c);
        
        this.lowIncomeSubsidy = GlobalUtils.coalesce(bi.Low_Income_Subsidy_formula_gne__c, NOT_APPLICABLE);
        this.drugTierLevels = GlobalUtils.coalesce(bi.Drug_Tier_Levels_formula_gne__c, NOT_APPLICABLE);
        this.stage1Deductible = GlobalUtils.coalesce(currency(bi.Stage_1_Deductible_gne__c), NOT_APPLICABLE);
        this.deductibleMet = GlobalUtils.coalesce(bi.Deductible_Met_gne__c, NOT_APPLICABLE);
        this.deductibleAmountMet = GlobalUtils.coalesce(String.valueOf(currency(bi.Deductible_Amount_Met_gne__c)), NOT_APPLICABLE);
        this.stage2CopayCoinsurance = GlobalUtils.coalesce(bi.Stage_2_Co_pay_Co_insurance_gne__c, NOT_APPLICABLE);
        this.initialCoverageStageLimit = GlobalUtils.coalesce(currency(bi.Initial_Coverage_Stage_Limit_gne__c), NOT_APPLICABLE);
        this.initialCoverageAmountMet = GlobalUtils.coalesce(currency(bi.Initial_Coverage_Amount_Met_gne__c), NOT_APPLICABLE);
        this.daySupply = GlobalUtils.coalesce(bi.Day_Supply_formula_gne__c, NOT_APPLICABLE);
        this.stage3CoverageGapLimit = GlobalUtils.coalesce(currency(bi.Stage_3_Coverage_Gap_Limit_gne__c), NOT_APPLICABLE);
        this.coverageGapAmountMet = GlobalUtils.coalesce(currency(bi.Coverage_Gap_Amount_Met_gne__c), NOT_APPLICABLE);
        this.catastrophicStageCopayCoIns = GlobalUtils.coalesce(bi.Catastrophic_stage_Co_pay_Co_ins_gen__c, NOT_APPLICABLE);
    }
    
    public static String formatPatientCostShare(String value)
    {
        if (value == null || value == '')
        {
            return value;
        }
        else
        {
            String[] parts = value.split(';');
            if(parts.size() > 1){
            	return parts[0] + '; ' + currency(parts[1].trim());
            }else if(parts[0].contains('%')){
            	return parts[0];
            }
            return currency(parts[0].trim());
        }
    }
    
    public static String formatPercent (Decimal percent)
    {
        if (percent == null)
        {
            return null;
        }
        else
        {
            return percent.setScale(0).format() + '%';
        }
    }
    
    public static String currency (Decimal value)
    {
        return value != null ? '$' + formatDecimalPlaces(value) : '';
    }
    
    public static String currency (String value)
    {
        if (value == null)
        {
            return '';
        }
        else
        {
            value = value.startsWith('$') ? value.substring(1) : value;
            return '$' + formatDecimalPlaces(value);
        }
    }
    
    public static String formatDecimalPlaces (Decimal i)
    {
        String s = (i.setScale(2) + 0.001).format();
        return s.substring(0,s.length()-1);
    }
    
    public static String formatDecimalPlaces (String i)
    {
        String s = (Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001).format();
        return s.substring(0,s.length()-1);
    }
    
    private void addFieldValue (String name, Decimal inValue, Decimal onValue)
    {
        addField (new NameValuePair(name, inValue != null ? String.valueOf(inValue) : NOT_APPLICABLE, onValue != null ? String.valueOf(onValue) : NOT_APPLICABLE));
    }
    
    private void addFieldValue (String name, String inValue, String onValue)
    {
        addField (new NameValuePair(name, inValue != null && inValue != '' ? inValue : NOT_APPLICABLE, onValue != null && onValue != '' ? onValue : NOT_APPLICABLE));
    }
    
    private void addField (NameValuePair fieldInfo)
    {
        this.fieldsByName.put(fieldInfo.Name, fieldInfo);
    }
    
    public NameValuePair getField(String name)
    {
        return this.fieldsByName.get(name);
    }
    
    public class NameValuePair
    {
       public String Name { get; set; }
       public String InValue { get; set; }
       public String OnValue { get; set; }
       
       public NameValuePair (String name, String inValue, String onValue)
       {   
           this.name = name.trim(); 
           this.inValue = inValue;
           this.onValue = onValue;
       }
    }
}