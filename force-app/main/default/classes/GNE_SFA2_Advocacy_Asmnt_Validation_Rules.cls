public with sharing class GNE_SFA2_Advocacy_Asmnt_Validation_Rules {
	
	
	public static void onBeforeInsert(List<Advocacy_Assessment_gne__c> triggerNewList){
		runAdvocacyAsmntValidations(triggerNewList);
	}
	
	public static void onBeforeUpdate(List<Advocacy_Assessment_gne__c> triggerNewList,List<Advocacy_Assessment_gne__c> triggerOldList){
		runAdvocacyAsmntValidations(triggerNewList);
		
	}
	
	
	public static void runAdvocacyAsmntValidations(List<Advocacy_Assessment_gne__c> triggerNewList){
		
		
		
		for(Advocacy_Assessment_gne__c advcyNew : triggerNewList)
		{
			
			//RULE 1: ALL_FIELDS_Value_between_1_and_3
			
			if(  
					(advcyNew.Usage_of_15_mg_gne__c<1 || advcyNew.Usage_of_15_mg_gne__c>3) || ( 
						(advcyNew.Standard_of_Care_for_1L_MCRC_pats_gn__c<1 || advcyNew.Standard_of_Care_for_1L_MCRC_pats_gn__c>3) || ( 
							(advcyNew.Level_of_support_for_Genentech_Prod_gne__c<1 || advcyNew.Level_of_support_for_Genentech_Prod_gne__c>3) || ( 
								(advcyNew.Level_of_support_for_competing_prod_gne__c<1 || advcyNew.Level_of_support_for_competing_prod_gne__c>3) || ( 
									(advcyNew.Level_of_Peer_Influence_gne__c<1 || advcyNew.Level_of_Peer_Influence_gne__c>3) || (
										(advcyNew.Eligibility_of_centrally_located_gne__c<1 || advcyNew.Eligibility_of_centrally_located_gne__c>3) || (
											(advcyNew.Willingness_to_Engage_gne__c<1 || advcyNew.Willingness_to_Engage_gne__c>3) || ( (advcyNew.Impact_of_TL_gne__c<1 || advcyNew.Impact_of_TL_gne__c>3) || (
													(advcyNew.Avastin_GI_BM6_gne__c<1 || advcyNew.Avastin_GI_BM6_gne__c>3) || ( (advcyNew.Avastin_GI_BM3_gne__c<1 || advcyNew.Avastin_GI_BM3_gne__c>3) || (
															(advcyNew.Defining_patient_pop_gne__c<1 || advcyNew.Defining_patient_pop_gne__c>3) || ( 
																(advcyNew.Avastin_GI_BM4_gne__c<1 || advcyNew.Avastin_GI_BM4_gne__c>3) || ( 
																	(advcyNew.Benefit_risk_discussion_gne__c<1 || advcyNew.Benefit_risk_discussion_gne__c>3) || ( 
																		(advcyNew.Avastin_GI_BM2_gne__c<1 ||advcyNew.Avastin_GI_BM2_gne__c>3) || (
																			(advcyNew.Avastin_GI_BM5_gne__c<1 || advcyNew.Avastin_GI_BM5_gne__c>3) || (
																				(advcyNew.Avoid_Surgical_Wound_Healing_Complicatio__c<1 || advcyNew.Avoid_Surgical_Wound_Healing_Complicatio__c>3) || (advcyNew.Treatment_of_mixed_histology_gne__c<1 || advcyNew.Treatment_of_mixed_histology_gne__c>3))
																			)) ) ) ) ) ) ) ) ) ) ) ) ) 
					){
				
				advcyNew.addError(System.Label.Advocay_Assmnt_Value_Check);
			}
			
			
			//RULE 2: GENERIC_All_Values_between_1_and_3
			
			if(  (advcyNew.Brand_Message_3_gne__c <1 || advcyNew.Brand_Message_3_gne__c>3) || ( (advcyNew.Brand_Message_2_gne__c <1 || advcyNew.Brand_Message_2_gne__c>3) || (advcyNew.Brand_Message_1_gne__c <1 || advcyNew.Brand_Message_1_gne__c>3) ) 
					){
				
				advcyNew.addError(System.Label.Advocay_Assmnt_Value_Check);
				
			}
			
			//RULE 3: HERCEPTIN_All_Values_between_1_and_3
			
			if(   (advcyNew.Benefit_in_multiple_lines_of_therapy_gne__c <1 || advcyNew.Benefit_in_multiple_lines_of_therapy_gne__c >3) || ( (advcyNew.Only_HER2_agent_w_survival_benefit_gne__c <1 || advcyNew.Only_HER2_agent_w_survival_benefit_gne__c >3) || ( (advcyNew.Benefit_risk_of_therapy_gne__c <1 || advcyNew.Benefit_risk_of_therapy_gne__c >3) || ( (advcyNew.Patient_selection_and_HER2_testing_gne__c <1 || advcyNew.Patient_selection_and_HER2_testing_gne__c >3) || ( (advcyNew.Herceptin_significantly_improves_DFS_gne__c <1 ||  advcyNew.Herceptin_significantly_improves_DFS_gne__c >3) || ( (advcyNew.Flexible_dosing_options_gne__c <1 || advcyNew.Flexible_dosing_options_gne__c>3) || ( (advcyNew.Benefit_demo_across_diverse_patients_gne__c <1 ||  advcyNew.Benefit_demo_across_diverse_patients_gne__c>3) || ( (advcyNew.Indicated_in_HER2_positive_breast_gne__c <1 ||  advcyNew.Indicated_in_HER2_positive_breast_gne__c >3) || (advcyNew.Well_established_safety_profile_gne__c <1 ||  advcyNew.Well_established_safety_profile_gne__c >3) )) ) )))) 


					){
				
				advcyNew.addError(System.Label.Advocay_Assmnt_Value_Check);
				
			}
			
			//RULE 4: RAPTIVA_All_Values_between_1_and_3
			
			if (  (advcyNew.Flare_Management_gne__c <1 || advcyNew.Flare_Management_gne__c >3) || ( (advcyNew.Twohundred_lbs_and_above_gne__c <1 || advcyNew.Twohundred_lbs_and_above_gne__c >3) || ( (advcyNew.Anti_TNF_IR_gne__c <1 || advcyNew.Anti_TNF_IR_gne__c >3) || ( (advcyNew.Safety_profile_gne__c <1 || advcyNew.Safety_profile_gne__c >3) || ( (advcyNew.Efficacy_maintained_over_time_gne__c <1 || advcyNew.Efficacy_maintained_over_time_gne__c >3) || (advcyNew.Hands_and_feet_gne__c <1 || advcyNew.Hands_and_feet_gne__c >3))))) 
					){
				
				advcyNew.addError(System.Label.Advocay_Assmnt_Value_Check);
			}
			
			//RULE 5: RituxinRA_ALL_FIELDS_between_1_and_5
			
			if( (advcyNew.Treatment_until_disease_progression_gne__c <1 || advcyNew.Treatment_until_disease_progression_gne__c >3) || ( (advcyNew.Importance_of_B_Cell_MOA_in_RA_gne__c <1 || advcyNew.Importance_of_B_Cell_MOA_in_RA_gne__c>3) || ( (advcyNew.Clinical_Response_Efficacy_Data_gne__c <1 || advcyNew.Clinical_Response_Efficacy_Data_gne__c>3) || ( (advcyNew.Retreatment_gne__c <1 || advcyNew.Retreatment_gne__c>3) || ( (advcyNew.aTNF_Cycling_Switching_gne__c <1 || advcyNew.aTNF_Cycling_Switching_gne__c>3) || ( (advcyNew.Infusion_Reactions_gne__c <1 || advcyNew.Infusion_Reactions_gne__c>3) || (advcyNew.B_Cell_Select_gne__c <1 ||advcyNew.B_Cell_Select_gne__c>3)))) ))
					
					){
				
				advcyNew.addError(System.Label.Advocay_Assmnt_Value_Check);
				
			}
			
			//RULE 6: TARCEVA_LUNG_All_Values_between_1_and_3
			
			if( (advcyNew.Avastin_Lung_Standard_of_Care_gne__c <1 ||advcyNew.Avastin_Lung_Standard_of_Care_gne__c>3) || 
					( (advcyNew.Rash_Management_Tarceva_Lung_gne__c <1 ||advcyNew.Rash_Management_Tarceva_Lung_gne__c >3) || ( (advcyNew.Tarceva_dosing_150_mg_gne__c <1 || advcyNew.Tarceva_dosing_150_mg_gne__c >3) || ( (advcyNew.Prolonged_survival_of_sub_pop_2_line_gne__c <1 || advcyNew.Prolonged_survival_of_sub_pop_2_line_gne__c >3)|| ( (advcyNew.Disease_control_rate_improved_gne__c <1 || advcyNew.Disease_control_rate_improved_gne__c >3) || ( (advcyNew.Greater_surv_advantage_PS_0_1_pts_gne__c <1 || advcyNew.Greater_surv_advantage_PS_0_1_pts_gne__c >3) || ((advcyNew.Increased_survival_compared_to_BSC_gne__c <1 ||advcyNew.Increased_survival_compared_to_BSC_gne__c >3) || (advcyNew.Significantly_prolonged_survival_gne__c <1 || advcyNew.Significantly_prolonged_survival_gne__c >3)))) )))
					)	{
				
				advcyNew.addError(System.Label.Advocay_Assmnt_Value_Check);
				
			}
			
			//RULE 7 : TARCEVA_PANC_All_Values_between_1_and_3
			
			if( 
					(advcyNew.Rash_management_Tarceva_Pancreatic_gne__c <1 || advcyNew.Rash_management_Tarceva_Pancreatic_gne__c >3) || 
					((advcyNew.Tarceva_dosing_100mg_gne__c <1 || advcyNew.Tarceva_dosing_100mg_gne__c >3) || ( (advcyNew.Disease_control_rate_improved_w_Tarc_gne__c <1 || advcyNew.Disease_control_rate_improved_w_Tarc_gne__c>3)||( (advcyNew.Tarceva_gem_increased_1_yr_survival_gne__c <1 || advcyNew.Tarceva_gem_increased_1_yr_survival_gne__c >3) || (advcyNew.Tarceva_gem_prolonged_overall_surv_gne__c <1 ||  advcyNew.Tarceva_gem_prolonged_overall_surv_gne__c >3))))
					) {
				
				advcyNew.addError(System.Label.Advocay_Assmnt_Value_Check);
				
			}   

			
			
		}
	}
}