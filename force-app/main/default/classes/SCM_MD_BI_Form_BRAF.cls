// 
//  
//
public class SCM_MD_BI_Form_BRAF extends SCM_MergeDocument {
    
    protected String patientIdLocal;
    protected SCM_MergeField formatDate;
    private SCM_MergeSection distSec = new SCM_MergeSection();
    // PD - supporting objects
    protected Case patientCase;
    
     
    public SCM_MD_BI_Form_BRAF(String caseId,String argLookupId)
    {
        super(caseId,argLookupId);
    }

    public override void createMergeFields()
    { 
        distsec.key = 'CheckforDistributor';
        
        // AccessSolutions - (AccessSolutions)
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        
        // Case number
        mergefields.add( new SCM_MF_CaseNumber(selectedCase));

        // CR_Phone
        mergefields.add( new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR_Fax
        mergefields.add( new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR_URL
        mergefields.add( new SCM_MF_Product_URL_CR(selectedCase));
         
        // ReferralOffice
        mergefields.add(SCM_MF_ReferralFieldFactory.ReferralOffice(selectedCase));
 
        // Date
        mergefields.add( new SCM_MF_CurrentDate());
        
        // PhtysicianFullName
        mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(Selectedcase.Case_Treating_Physician_gne__r.Id));
        
        // Enroll Date
        SCM_MergeField EnrollDate = NewMergefield('EnrollDate',string.valueof(Selectedcase.Referred_By_Date_gne__c));     
        EnrollDate.fieldValue = 
            EnrollDate.fieldValue != '' ? SCM_FaxSender_Doc.ConverDate(EnrollDate.fieldValue).format('MM/dd/yyyy') : '';
        
        // GetADate        
        mergefields.add(EnrollDate);
        
        // Patient Full Name
        mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
        
        // Patient DOB
        mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        
        // Product
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
       
        // Product Name
        this.mergefields.add(new SCM_MF_Product_DrugName(selectedCase));
      
        // In Or Out Network  Key : DispensingCenterType
        this.mergefields.add(SCM_MF_Fulfillment_Factory.DispensingCenterType(selectedcase.id));
        
        // Key : Dispensing Center
        scm_mergeField MFDC = SCM_MF_Fulfillment_Factory.DispensingCenter(selectedcase.id);
        this.mergefields.add(MFDC);
        
        // Set Distsec visibility
        distsec.visible = MFDC.Fieldvalue == '' ? false : true;
        
        this.mergeSections.add(distsec);
        
        // Key : RECNAME_To
        this.mergefields.add(SCM_MF_Fulfillment_Factory.DispensingFullAddress(selectedcase.id));
            
        // Key : DispensingContactName
        this.mergefields.add(SCM_MF_Fulfillment_Factory.DispensingContactName(selectedcase.id));
        
        // Key : DispensingContactPhone
        this.mergefields.add(SCM_MF_Fulfillment_Factory.DispensingContactPhone(selectedcase.id));
     
        // Key : DespensigFaxNo
        this.mergefields.add(SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber_BI(selectedcase.id));
    
        // Repeater bi info
        SCM_MergeRepeater rpt = new SCM_MergeRepeater();
        mergeRepeaters = new list<SCM_MergeRepeater>(); 
        list<Benefit_Investigation_gne__c> bis= [select b.OT_Out_Pocket_N_A_gne__c,
                                                        b.OTD_Individual_gne__c,
                                                        b.IND_Indv_Amount_gne__c,
                                                        b.OTD_None_gne__c,
                                                        b.IND_None_gne__c,
                                                        b.Payer_BI_gne__r.Name,
                                                        b.Product_Covered_By_gne__c,
                                                        b.Product_Covered_gne__c, 
                                                        b.Medically_Necessary_gne__c, 
                                                        b.Effective_Date_gne__c, 
                                                        b.I_N_Payer_Allowable_percent_gne__c,
                                                        b.INA_Drug_Payer_gne__c,
                                                        b.INC_Patient_Amount_gne__c,
                                                        b.INC_Patient_PC_gne__c,
                                                        b.OTC_Patient_Amount_gne__c,
                                                        b.OTC_Patient_gne__c,
                                                        b.OTA_Drug_Payer_Allowable_gne__c,
                                                        b.O_N_Payer_Allowable_percent_gne__c,
                                                        b.IN_Max_Year_gne__c,
                                                        b.IN_Pocket_Individual_gne__c, 
                                                        b.Billing_Instructions_gne__c,
                                                        b.IN_Pocket_Individual_amt_gne__c,
                                                        b.OT_Out_Pocket_Individual_gne__c,
                                                        b.OT_Out_Pocket_Individual_amount_met_gne__c,
                                                        b.IN_Max_Benefit_Individual_gne__c,
                                                        b.IN_Max_Benefit_Individual_Met_gne__c,
                                                        b.IN_Max_Benefit_Amount_Used_gne__c,
                                                        b.OT_Max_Benefit_Individual_gne__c,
                                                        b.OT_Max_Benefit_Individual_Met_gne__c,
                                                        b.OT_Max_Benefit_Indv_Used_gne__c,
                                                        b.IN_Max_Life_gne__c,
                                                        b.IN_Max_Life_Amount_gne__c,
                                                        b.IND_Individual_gne__c,
                                                        b.OTD_Indv_Amount_Met_gne__c,
                                                        b.INC_Insurer_gne__c,
                                                        b.OTC_Insurer_gne__c,
                                                        b.IN_Max_Remaining_Amount_gne__c,
                                                        b.OT_Max_Life_gne__c,
                                                        b.OT_Max_Life_Amount_gne__c,
                                                        b.OT_Max_Remaining_Amount_gne__c,
                                                        b.IN_Condtn_gne__c,
                                                        b.OT_Condtn_gne__c,
                                                        b.First_Hour_cpt_gne__c,
                                                        b.Subsequent_hours_cpt_gne__c,
                                                        b.Prior_Authorization_est_tat_gne__c,
                                                        b.est_tat_pre_determination_gne__c,
                                                        b.Plan_Year_gne__c,
                                                        b.Retroactive_gne__c, 
                                                        b.Drug_Billing_Code_gne__c,
                                                        b.Prior_Authorization_required_gne__c,
                                                        b.BI_Obtained_Date_gne__c,
                                                        b.Benefit_Type_gne__c,
                                                        b.BI_reference_num_gne__c, 
                                                        b.BI_Contact_Phone_gne__c,
                                                        b.required_for_billing_gne__c,
                                                        b.BI_Contact_name_gne__c,
                                                        b.BI_Insurance_gne__r.Group_Num_gne__c,
                                                        b.BI_Insurance_gne__r.Policy_Number_gne__c,
                                                        b.BI_Insurance_gne__r.Subscriber_Num_gne__c,
                                                        b.COORD_BEN_flag_gne__c, 
                                                        b.BI_Insurance_gne__r.Rank_gne__c, 
                                                        b.BI_Insurance_gne__r.Plan_Type_gne__c,
                                                        b.BI_Insurance_gne__r.ins_eligible_for_Medicare_Part_D_gne__c,
                                                        b.BI_Insurance_gne__c,
                                                        b.Low_Income_Subsidy_gne__c,
                                                        b.Drug_Tier_Levels_gne__c,
                                                        b.Deductible_gne__c,
                                                        b.Deductible_Individual_gne__c,
                                                        b.Deductible_Met_Individual_gne__c,
                                                        b.Deductible_Amount_Met_Individual_gne__c,
                                                        b.Amount_Percent2_gne__c,
                                                        b.Stage_2_Limit2_gne__c,
                                                        b.Day_Supply_gne__c,
                                                        b.Stage2_Amount_Met_gne__c,
                                                        b.Until_the_following_is_met_gne__c,
                                                        b.Stage_3_Amount_Met_gne__c,
                                                        b.Remaining_in_the_calendar_year__c,
                                                        b.Preferred_Specialty_Pharmacy_1_gne__r.Name,
                                                        b.Preferred_Specialty_Pharmacy_2_gne__r.Name,
                                                        b.Preferred_Specialty_Pharmacy_3_gne__r.Name,
                                                        b.Preferred_AIC_1_gne__r.Name,
                                                        b.Preferred_AIC_2_gne__r.Name,
                                                        b.Preferred_AIC_3_gne__r.Name
                                                   from Benefit_Investigation_gne__c b 
                                                  where Case_BI_gne__c = :selectedcase.id 
                                                    and Print_on_BI_Report_gne__c = 'Yes' 
                                               order by BI_Insurance_gne__r.Rank_gne__c];
                                                  
        list<SCM_MergeRepeaterItem> rptii = new list<SCM_MergeRepeaterItem>();
        rpt.repeaterItems = rptii;
        rpt.targetTextBox = 'repeate';
        
        if (bis.size() > 0 ) 
        {
            for (Benefit_Investigation_gne__c bi:bis)
            {               
                SCM_MergeRepeaterItem rptI = new SCM_MergeRepeaterItem();
                rptI.mergeFields = new list<ScM_MergeField>();
                

                // Insurance Rank 
                rptI.mergeFields.add(NewMergefield('InsuranceRank',bi.BI_Insurance_gne__r.Rank_gne__c));
    
                rpti.mergeFields.add(new SCM_MF_BI_PlanName(bi.BI_Insurance_gne__c));
                
                // Payer
                rptI.mergeFields.add(new SCM_MF_BI_Payer(bi));
                
                // Benefit type
                rptI.mergeFields.add(NewMergefield('BenefitType',bi.Benefit_Type_gne__c));
                
                // Benefit Claim PA Note            
                String RquiredBilling_Gne = bi.required_for_billing_gne__c == null? '' : bi.required_for_billing_gne__c;
                
                if(RquiredBilling_Gne == 'None Required')
                {
                    rptI.mergeFields.add(NewMergefield('BillingClaimsPANote',''));
                }
                else 
                {
                    rptI.mergeFields.add(NewMergefield('BillingClaimsPANote',
                        bi.required_for_billing_gne__c == null ? '' : bi.required_for_billing_gne__c));
                }
                
                if (bi.required_for_billing_gne__c =='None Required') 
                {
                    rptI.mergeFields.add(NewMergefield('BillingClaimsPANoteTxt',''));
                }
                else if  (bi.required_for_billing_gne__c == '') 
                {
                    rptI.mergeFields.add(NewMergefield('BillingClaimsPANoteTxt',''));
                }
                else if  (bi.required_for_billing_gne__c == null) 
                {
                    rptI.mergeFields.add(NewMergefield('BillingClaimsPANoteTxt',''));
                }
                else 
                {
                    rptI.mergeFields.add(NewMergefield('BillingClaimsPANoteTxt',
                        'The Payer requires the following to be submitted with your claim: '));         
                }
                
                // BillingInstructions
                rptI.mergeFields.add(NewMergefield('BillingInstructions',
                    bi.Billing_Instructions_gne__c == null ? '' : bi.Billing_Instructions_gne__c));
                          
                // Subscriber id
                rptI.mergeFields.add(NewMergefield('SubscriberID',bi.BI_Insurance_gne__r.Subscriber_Num_gne__c));
                
                // Policy Number
                rptI.mergeFields.add(NewMergefield('PolicyNum',bi.BI_Insurance_gne__r.Policy_Number_gne__c));
                
                // GroupNum
                rptI.mergeFields.add(NewMergefield('GroupNum',bi.BI_Insurance_gne__r.Group_Num_gne__c));
                
                // Payer Contact
                rptI.mergeFields.add(NewMergefield('PayerContact',bi.BI_Contact_name_gne__c));
                
                // Payer Phone
                rptI.mergeFields.add(NewMergefield('PayerPhone',bi.BI_Contact_Phone_gne__c));
                
                // BIRefNum
                rptI.mergeFields.add(NewMergefield('BIRefNum',bi.BI_reference_num_gne__c));
                
                // Obtained date
                string obdate = bi.BI_Obtained_Date_gne__c != null ? bi.BI_Obtained_Date_gne__c.Format('MM/dd/yyyy') : '';
                
                formatDate = NewMergefield('BIObtainedDate',obdate);     
       
                rptI.mergeFields.add(formatDate);
                
                // Plan Type
                rptI.mergeFields.add(NewMergefield('PlanType',bi.BI_Insurance_gne__r.Plan_Type_gne__c));
                
                // Plan eff date
                formatDate = NewMergefield('PlanEffDate',string.valueof(bi.Effective_Date_gne__c));    
                 
                formatDate.fieldValue = 
                    formatDate.fieldValue != '' ? SCM_FaxSender_Doc.ConverDate(formatDate.fieldValue).format('MM/dd/yyyy') : '';
                    
                rptI.mergeFields.add(formatDate);
                
                // Plan Plan Term date
                rptI.mergeFields.add(NewMergefield('PlanTermDate',bi.Plan_Year_gne__c));
                
                // RX Covered
                String rxcovered = '';
                String strProductCoveredByGne = bi.Product_Covered_gne__c;
                
                if (strProductCoveredByGne =='Yes')
                {   
                    String strMedicallyNecessaryGne = bi.Medically_Necessary_gne__c == 'Yes' ? 'Yes' : 'No';
                    
                    if (strMedicallyNecessaryGne == 'Yes')
                    {
                        rxcovered = 'Yes, if medically necessary';
                    }
                    else
                    {
                        rxcovered = 'Yes';
                    }
                }
                else
                {
                    rxcovered = bi.Product_Covered_gne__c;
                }
                
                rptI.mergeFields.add(NewMergefield('RXCovered',rxcovered));
                
                // Coord of Benefits
                rptI.mergeFields.add(NewMergefield('CoordofBenefits',bi.COORD_BEN_flag_gne__c));  

                // isElgibleForMedicarePartD used by multiple fields to show/hide value
                Boolean isElgibleForMedicarePartD = bi.BI_Insurance_gne__r.ins_eligible_for_Medicare_Part_D_gne__c == 'Yes' ? true : false;

                // Low Income Subsidy
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('LowIncomeSubsidy', bi.Low_Income_Subsidy_gne__c)));
                
                // Drug Tier Level
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('DrugTierLevel', bi.Drug_Tier_Levels_gne__c)));
                
                // Deductible
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('Deductible', bi.Deductible_gne__c)));
                
                // Deductible Individual
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('DeductibleIndividual', bi.Deductible_Individual_gne__c)));
                
                // Deductible Met Individual
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('DeductibleMetIndividual', bi.Deductible_Met_Individual_gne__c)));
                
                // Deductible Amount
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('DeductibleAmount', bi.Deductible_Amount_Met_Individual_gne__c)));
                
                // Stage 2 Limit
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('Stage2Limit', bi.Stage_2_Limit2_gne__c)));
                
                // Amount Percent
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('AmountPercent', bi.Amount_Percent2_gne__c)));

                // Day Supply
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('DaySupply', bi.Day_Supply_gne__c)));
                
                // Stage 2 Amount
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('Stage2Amount', bi.Stage2_Amount_Met_gne__c)));
                
                // Until the Following
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('UntiltheFoll', bi.Until_the_following_is_met_gne__c)));
                
                // Stage 3 Amount
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('Stage3Amount', bi.Stage_3_Amount_Met_gne__c)));
                
                // Remaining in the Calendar
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('RemCalendar', bi.Remaining_in_the_calendar_year__c)));
                
                // Preferred Specialty Pharmacy 1
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('PrefSP1', bi.Preferred_Specialty_Pharmacy_1_gne__r.Name)));
                
                // Preferred Specialty Pharmacy 2
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('PrefSP2', bi.Preferred_Specialty_Pharmacy_2_gne__r.Name)));
                
                // Preferred Specialty Pharmacy 3
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('PrefSP3', bi.Preferred_Specialty_Pharmacy_3_gne__r.Name)));
                
                // Preferred AIC 1
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('PrefAIC1', bi.Preferred_AIC_1_gne__r.Name)));
                
                // Preferred AIC 2
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('PrefAIC2', bi.Preferred_AIC_2_gne__r.Name)));
                
                // Preferred AIC 3
                rptI.mergeFields.add(EmptyFieldValue(!isElgibleForMedicarePartD, NewMergefield('PrefAIC3', bi.Preferred_AIC_3_gne__r.Name)));

                // PtDeduct
                rptI.mergeFields.add(EmptyFieldValue(isElgibleForMedicarePartD, new SCM_MF_PTDeduct(bi)));
                
                // InsCostShares
                rptI.mergeFields.add(EmptyFieldValue(isElgibleForMedicarePartD, new SCM_MF_InsurerCostShare(bi)));  

                // PatCostShares
                rptI.mergeFields.add(EmptyFieldValue(isElgibleForMedicarePartD, new SCM_MF_BI_PatientCostShare(bi)));

                // Insurance Allowable          
                rptI.mergeFields.add(EmptyFieldValue(isElgibleForMedicarePartD, new SCM_MF_BI_InsuranceAllowable(bi)));

                // Maxout pocket year
                rptI.mergeFields.add(EmptyFieldValue(isElgibleForMedicarePartD, new SCM_MF_BI_MaxOutPocketYear(bi)));

                // Max benefit per year
                rptI.mergeFields.add(EmptyFieldValue(isElgibleForMedicarePartD, new SCM_MF_BI_MaxBenefitPerYr(bi)));  

                // Life Time Max
                rptI.mergeFields.add(EmptyFieldValue(isElgibleForMedicarePartD, new SCM_MF_BI_Lifetimemax(bi)));  

                // Pre Existing
                rptI.mergeFields.add(EmptyFieldValue(isElgibleForMedicarePartD, new SCM_MF_PreExisting(bi)));  

                // Admin Codes
                rptI.mergeFields.add(new SCM_MF_AdminCodes(bi)); 

                // Billing code
                rptI.mergeFields.add(NewMergefield('BillingCode',bi.Drug_Billing_Code_gne__c));   

                // Prior authorization required
                rptI.mergeFields.add(NewMergefield('PriorAuthReq',bi.Prior_Authorization_required_gne__c));

                // Prior authorization required
                rptI.mergeFields.add(NewMergefield('PriorAuthReq',bi.Prior_Authorization_required_gne__c));

                // Prior authorization TAT
                rptI.mergeFields.add(new SCM_MF_BI_PriorAuthorization_TAT(bi));     

                // Retro Active
                rptI.mergeFields.add(NewMergefield('RetroActive',BI.Retroactive_gne__c));

                List<Prior_Authorization_gne__c> PAuths = [select p.Recertification_Date_gne__c, 
                                                                  p.Phone_gne__c, 
                                                                  p.PA_Term_gne__c, 
                                                                  p.PA_Effective_Date_gne__c, 
                                                                  p.PA_Contact_Name_gne__c, 
                                                                  p.PA_Authorization_Num_gne__c 
                                                             from Prior_Authorization_gne__c p 
                                                            where p.Benefit_Investigation_gne__c = :bi.id];

                Prior_Authorization_gne__c PAuth = new Prior_Authorization_gne__c();

                if (PAuths.size() != 0 ) 
                {
                    PAuth = PAuths[0];
                }            

                //Authorization date
                formatDate = NewMergefield('AuthorizationDate','');
                formatDate.fieldValue = getdate(PAuth.PA_effective_date_gne__c);
                rptI.mergeFields.add(formatDate);

                //Authorization Number
                rptI.mergeFields.add(NewMergefield('AuthorizationNumber',PAuth.PA_Authorization_Num_gne__c));

                //Authorized by
                rptI.mergeFields.add(NewMergefield('AuthorizedBy',PAuth.PA_contact_name_gne__c));

                //Authorization Phone
                rptI.mergeFields.add(NewMergefield('AuthorizationPhone',PAuth.Phone_gne__c));

                //Authorization Term
                rptI.mergeFields.add(NewMergefield('AuthorizationTerm',PAuth.PA_term_gne__c));

                //Recert Date           
                formatDate = NewMergefield('RecertDate','');     
                formatDate.fieldValue = getdate(PAuth.Recertification_Date_gne__c);
                rptI.mergeFields.add(formatDate);

                //Billing claims pa notice
                rptI.mergeFields.add(new SCM_MF_BillingClaimsPANote(bi));
  
                rpt.repeaterItems.add(rptI);
            }
        }
        
        rpt.AppendReturn = true;
        mergeRepeaters.add(rpt);
    }

    private string GetDate(DateTime dte) 
    {
         return dte != null ? dte.format('MM/dd/yyyy') : '';
    }
    
    private string GetDate(Date dte) 
    {
         return dte != null ? dte.format() : '';
    }
    
    private SCM_MergeField EmptyFieldValue(Boolean clear, SCM_MergeField mf)
    {
        if(clear)
        {
            mf.fieldValue = '';
        }
        
        return mf;
    }
    
    private SCM_MergeField NewMergefield(string mfkey, string mfvalue) 
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = mfkey;
        mf.className = 'SCM_MergeField';
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false; 
        mf.displayLabel = false;
        mf.fieldValue = mfvalue == null ? '' : mfvalue;
        
        return mf;
    }
    
    private SCM_MergeField NewMergefield(string mfkey, Decimal mfvalue) 
    {
        return NewMergefield(mfkey, mfvalue != null ? mfvalue.format() : ''); 
    }
}