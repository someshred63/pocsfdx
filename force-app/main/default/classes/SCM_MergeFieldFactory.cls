global class SCM_MergeFieldFactory{
	
	
	
public static string getValue(string classname,string arg){
	if (classname == 'SCM_MF_Physician_FieldFactory.PhysicianFax') 
		return SCM_MF_Physician_FieldFactory.PhysicianFax(string.valueof(arg)).fieldValue;
	else if (classname == 'SCM_MF_Fulfillment_Factory.DispensingCenter') 
		return SCM_MF_Fulfillment_Factory.DispensingCenter(arg).fieldValue;	
	else if (classname == 'SCM_MF_PatientFieldFactory.PatientFirstAndLastName') 
		return SCM_MF_PatientFieldFactory.PatientFirstAndLastName(arg).fieldValue;
	else if (classname == 'SCM_MF_PatientFieldFactory.PatientDOB') 
		return SCM_MF_PatientFieldFactory.PatientDOB(arg).fieldValue;
	else if (classname == 'SCM_MF_Fulfillment_Factory.DispensingCenter') 
		return SCM_MF_Fulfillment_Factory.DispensingCenter(arg).fieldValue;
	else if (classname == 'SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName') 
		return SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName(arg).fieldValue;
	else if (classname == 'SCM_MF_CurrentDate') 
		return new SCM_MF_CurrentDate().fieldValue;
	else if (classname == 'SCM_MF_Product_AccessSolutions') 
		return new  SCM_MF_Product_AccessSolutions(arg).fieldValue;
	else {
		
		return '';
	}	
	
}
public static string getValue(string classname,Case arg){
	
	if (classname == 'SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX') 
		return SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(arg).fieldValue;
	else if (classname == 'SCM_MF_PhysicianContactFactory.PhysicianContactFullName') 
		return SCM_MF_PhysicianContactFactory.PhysicianContactFullName(arg).fieldValue;
	
	else if (classname == 'SCM_MF_DRUG') 
		return new SCM_MF_DRUG(arg).fieldValue;
	else if (classname == 'SCM_MF_Product_PrivacyNotice') 
		return new  SCM_MF_Product_PrivacyNotice(arg).fieldValue;
	else if (classname == 'SCM_MF_Product_ConfidentialityNotice') 
		return new  SCM_MF_Product_ConfidentialityNotice(arg).fieldValue;

	 
	else if (classname == 'SCM_MF_AA_ReferralDate') 
		return new  SCM_MF_AA_ReferralDate(arg).fieldValue;
	else if (classname == 'SCM_MF_AA_PanExpiration') 
		return new  SCM_MF_AA_PanExpiration(arg).fieldValue;
	else if (classname == 'SCM_MF_AA_PriorAuth') 
		return new  SCM_MF_AA_PriorAuth(arg).fieldValue;
	else if (classname == 'SCM_MF_PatientId') 
		return new  SCM_MF_PatientId(arg).fieldValue;
	else if (classname == 'SCM_MF_AccCa_ICD9') 
		return new  SCM_MF_AccCa_ICD9(arg).fieldValue;
	else if (classname == 'SCM_MF_CaseStatus') 
		return new  SCM_MF_CaseStatus(arg).fieldValue;
	else if (classname == 'SCM_MF_AA_SpecificStatus') 
		return new  SCM_MF_AA_SpecificStatus(arg).fieldValue;
	else if (classname == 'SCM_MF_CaseType') 
		return new  SCM_MF_CaseType(arg).fieldValue;
	else if (classname == 'SCM_MF_RefferalReason') 
		return new  SCM_MF_RefferalReason(arg).fieldValue;
	else if (classname == 'SCM_MF_CaseNumber') 
		return new  SCM_MF_CaseNumber(arg).fieldValue;
	else if (classname == 'SCM_MF_CaseNotes') 
		return new  SCM_MF_CaseNotes(arg).fieldValue;
	else if (classname == 'SCM_MF_AA_InsuranceByRankPrimary') 
		return new  SCM_MF_AA_InsuranceByRank(arg,'Primary').fieldValue;
	else if (classname == 'SCM_MF_AA_InsuranceByRankSecondary') 
		return new  SCM_MF_AA_InsuranceByRank(arg,'Secondary').fieldValue;
	else if (classname == 'SCM_MF_AA_InsuranceByRankTertiary') 
		return new  SCM_MF_AA_InsuranceByRank(arg,'Tertiary').fieldValue;	
	else if (classname == 'SCM_MF_AA_InsuranceByRankACPrimary') 
		return new  SCM_MF_AA_InsuranceByRankAC(arg,'Primary').fieldValue;
	else if (classname == 'SCM_MF_AA_InsuranceByRankACSecondary') 
		return new  SCM_MF_AA_InsuranceByRankAC(arg,'Secondary').fieldValue;
	else if (classname == 'SCM_MF_AA_InsuranceByRankACTertiary') 
		return new  SCM_MF_AA_InsuranceByRankAC(arg,'Tertiary').fieldValue;	
	
	
	
	else if (classname == 'SCM_MF_PriorAuth_Short') 
		return new  SCM_MF_PriorAuth_Short(arg).fieldValue;	
	else {
		
		
		
		
		
		
		
		return '';
	}	
	
}
}