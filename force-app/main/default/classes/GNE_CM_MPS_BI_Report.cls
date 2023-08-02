public without sharing class GNE_CM_MPS_BI_Report
{
    public static String NOT_APPLICABLE = 'N/A';
    public Id benefitInvestigationId { get; set; }
    public Benefit_Investigation_gne__c benefitInvestigation { get; private set; }
    public Case currentCase { get; private set; }
    private Prior_Authorization_gne__c currentPA;
    public String prescribingPhysician { get; private set; }
    public String icd9Code { get; private set; }
    public String icd9Code2 { get; private set; }
    public String icd9Code3 { get; private set; }
    public String patientDOB { get; private set; }
    public String patientName { get; private set; }
    public String product { get; private set; }
    public GNE_CM_MPS_BI_Payer_Info payerInfo { get; private set; }
    public String inProductCoverage { get; private set; }
    public String onProductCoverage { get; private set; }
    public String billingInstructions { get; private set; }
    public String crPhone { get; private set; }
    public String crFax { get; private set; }
    public String crUrl { get; private set; }
    public String logoURL{get; set;}
    public String altLogo{get; set;}
        
    public GNE_CM_MPS_BI_Report(ApexPages.StandardController controller)
    {
        try
        {
            if (ApexPages.currentPage().getParameters().get('id')!=null)
            {
                benefitInvestigationId = ApexPages.currentPage().getParameters().get('id');
            }
            
            benefitInvestigation = [SELECT id, Name, Case_BI_gne__c, Benefit_type_gne__c, Physician_Full_Name_gne__c, ICD9_Code_gne__c, ICD9_Code2_gne__c, ICD9_Code3_gne__c,
                        BI_Insurance_gne__r.Rank_gne__c, BI_Insurance_gne__r.Name, BI_Insurance_gne__r.Plan_gne__c, BI_Insurance_gne__r.Plan_gne__r.Name, Patient_Full_Name_gne__c, DOB_gne__c, IN_ProductCoverage_gne__c, ON_ProductCoverage_gne__c, 
                        BI_Insurance_gne__r.Subscriber_Num_gne__c, BI_Insurance_gne__r.Plan_Type_gne__c, Product_BI_gne__c,
                        BI_Insurance_gne__r.Group_Num_gne__c, Effective_Date_gne__c, Plan_Year_gne__c, BI_Obtained_Date_gne__c, BI_Contact_Phone_gne__c,
                        BI_Contact_name_gne__c, BI_reference_num_gne__c, BI_Insurance_gne__r.Plan_Product_Type_gne__c, Billing_Instructions_gne__c, IN_Product_Covered_gne__c, ON_Product_Covered_gne__c,
                        IN_BillingCode_gne__c, ON_BillingCode_gne__c, IN_PriorAuthReq_gne__c, ON_PriorAuthReq_gne__c,IN_AdminCodes_gne__c, ON_AdminCodes_gne__c,
                        IN_AdminPriorAuthReq_gne__c, ON_AdminPriorAuthReq_gne__c, IN_BillingCodeDeduct_gne__c, ON_BillingCodeDeduct_gne__c, IND_Individual_gne__c,
                        OTD_Individual_gne__c, IN_IndDeductMet_gne__c, ON_IndDeductMet_gne__c, IN_InsCostShares_gne__c, ON_InsCostShares_gne__c, IN_Patient_Cost_Share_gne__c,
                        ON_Patient_Cost_Share_gne__c, IN_Office_Copay_gne__c, ON_Office_Copay_gne__c, IN_Individual_Out_Of_Pocket_Max_gne__c, ON_Individual_Out_Of_Pocket_Max_gne__c,
                        IN_Individual_Out_Of_Pocket_Max_Met_gne__c, ON_Individual_Out_Of_Pocket_Max_Met_gne__c, IN_Family_Out_Of_Pocket_Max_gne__c, ON_Family_Out_Of_Pocket_Max_gne__c,
                        IN_Family_Out_Of_Pocket_Max_Met_gne__c, ON_Family_Out_Of_Pocket_Max_Met_gne__c,
                        IN_Deductible_App_to_Out_Of_Pocket_gne__c, ON_Deductible_App_to_Out_Of_Pocket_gne__c, IN_FamDeduct_gne__c, ON_FamDeduct_gne__c, IN_FamDeductMet_gne__c, ON_FamDeductMet_gne__c, 
                        IN_AnnualBenefitMax_gne__c, ON_AnnualBenefitMax_gne__c, IN_Buy_and_Bill_Available_Formula_gne__c, ON_Buy_and_Bill_Available_Formula_gne__c,
                        IN_Specialty_Pharmacy_Avail_Formula_gne__c, ON_Specialty_Pharmacy_Avail_Formula_gne__c, IN_Specialty_Pharmacy_Req_Formula_gne__c, ON_Specialty_Pharmacy_Req_Formula_gne__c,
                        IN_SpecPharm_1_gne__c, ON_SpecPharm_1_gne__c, IN_SpecPharm_2_gne__c, ON_SpecPharm_2_gne__c, IN_SpecPharm_3_gne__c, ON_SpecPharm_3_gne__c, 
                        BI_Insurance_gne__r.ins_eligible_for_Medicare_Part_D_gne__c, 
                        Low_Income_Subsidy_formula_gne__c, Drug_Tier_Levels_formula_gne__c, Stage_1_Deductible_gne__c, Deductible_Met_gne__c, Deductible_Amount_Met_gne__c,
                        Stage_2_Co_pay_Co_insurance_gne__c, Initial_Coverage_Stage_Limit_gne__c, Initial_Coverage_Amount_Met_gne__c, Day_Supply_formula_gne__c,
                        Stage_3_Coverage_Gap_Limit_gne__c, Coverage_Gap_Amount_Met_gne__c, Catastrophic_stage_Co_pay_Co_ins_gen__c, IN_IndDeduct_gne__c, ON_IndDeduct_gne__c,
                        IN_RXCovered_gne__c, ON_RXCovered_gne__c, Payer_BI_gne__c, Payer_BI_gne__r.Name,  eBI_Plan_Plan_Product_gne__c,
                        Patient_BI_gne__r.Full_Name_gne__c, Patient_BI_gne__r.pat_dob_gne__c
                        FROM Benefit_Investigation_gne__c WHERE id =:benefitInvestigationId];
                                     
            system.debug('benefitInvestigation AFTER' + this.benefitInvestigation);
            
            List<String> logoInfo = GNE_CM_MPS_Utils.getProductLogo(benefitInvestigation.Product_BI_gne__c);
            if (logoInfo.size() > 0)
            {
                logoURL = logoInfo[0];
                altLogo = logoInfo[1];
            }
            
            List<Case> currentCases = [SELECT id, CaseNumber, Account.Name, Case_Treating_Physician_gne__r.Name FROM Case WHERE Id = :benefitInvestigation.Case_BI_gne__c LIMIT 1];
            
            if (!currentCases.isEmpty())
            {
                this.currentCase = currentCases.get(0);
            }
            else
            {
                throw new GNE_CM_Exception('Case with ID ' + benefitInvestigation.Case_BI_gne__c + ' does not exist');
            }
            
            this.prescribingPhysician = benefitInvestigation.Physician_Full_Name_gne__c;
            this.icd9Code = benefitInvestigation.ICD9_Code_gne__c;
            this.icd9Code2 = benefitInvestigation.ICD9_Code2_gne__c;
            this.icd9Code3 = benefitInvestigation.ICD9_Code3_gne__c;
            this.patientName = String.valueOf(benefitInvestigation.Patient_Full_Name_gne__c);
            if (benefitInvestigation.DOB_gne__c != null)
            {
                String[] dobDt = String.valueOf(benefitInvestigation.DOB_gne__c).split('-');
                String dobDate = dobDt.get(1) + '/' + dobDt.get(2) + '/' + dobDt.get(0); 
                this.patientDOB = dobDate;
            } 
            else
            {
                this.patientDOB = NOT_APPLICABLE;
            }
            this.product = GlobalUtils.coalesce(benefitInvestigation.Product_BI_gne__c, NOT_APPLICABLE);
            this.inProductCoverage = benefitInvestigation.IN_ProductCoverage_gne__c;
            this.onProductCoverage = benefitInvestigation.ON_ProductCoverage_gne__c;
            this.billingInstructions = benefitInvestigation.Billing_Instructions_gne__c;
            
            if (product != NOT_APPLICABLE)
            {
                CR_Specific_Values__c val = CR_Specific_Values__c.getValues(product);
                this.crPhone = val.Phone__c;
                this.crFax = val.Fax__c;
                this.crUrl = val.URL__c;
            }
            else
            {
                this.crPhone = NOT_APPLICABLE;
                this.crFax = NOT_APPLICABLE;
                this.crUrl = NOT_APPLICABLE;
            }
            
            this.payerInfo = new GNE_CM_MPS_BI_Payer_Info(benefitInvestigation);
            this.payerInfo.isMedicare = isMedicarePartD(benefitInvestigation);
        }
        catch (Exception e)
        {
            System.debug('EXCEPTION OCCURRED:' + e);
            throw new GNE_CM_Exception('An error occurred in creating the Benefits Investigation Report: ' + e.getMessage());
        }
    }
    
    public Boolean isMedicarePartD(Benefit_Investigation_gne__c bi)
    {
        Set<String> products = new Set<String>{'zelboraf', 'tarceva', 'erivedge', 'pegasys', 'actemra', 'rituxan ra', 'xolair'};
        Boolean isProduct = (products.contains(product.toLowerCase()));
        Boolean isMedPartD = (bi.BI_Insurance_gne__r.ins_eligible_for_Medicare_Part_D_gne__c == 'Yes');
        return isProduct && isMedPartD;
    }
}