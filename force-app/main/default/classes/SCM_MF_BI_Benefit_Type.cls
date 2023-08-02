public class SCM_MF_BI_Benefit_Type extends SCM_MF_BI_Collection
{
	public SCM_MF_BI_Benefit_Type(String patientId)
	{
		super(patientId);
		key = 'BenefitType';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		className = 'SCM_MF_BI_Benefit_Type';
	}
	
	public override String getFieldValue()
  	{     
    	if(BenefitInvest != null && BenefitInvest.Benefit_Type_gne__c !=null)
    	{
        	return String.valueOf(BenefitInvest.Benefit_Type_gne__c);
        	
    	}
    	else
        	return '';
  	}
}