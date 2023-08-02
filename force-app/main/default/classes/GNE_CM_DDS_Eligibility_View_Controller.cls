public with sharing class GNE_CM_DDS_Eligibility_View_Controller
{
	public Boolean isReadonly{ get { if (isReadonly == null) return false; return isReadonly; }	set; }
	public Boolean isOverrideColumnEnabled { get;set; }
	
	public Boolean visible {	get; set; }

	public Boolean outcomeEnabled {get { if(outcomeEnabled == null) return true; return outcomeEnabled;} set;}
	
	public Case getCase() 
	{
		return this.parentControllerReference.getCase();
	}

	public GNE_CM_DDS_Embeddable_Controller parentControllerReference
	{
		get;
		set
		{
			this.parentControllerReference = value;
			this.parentControllerReference.setDdsController(this);
			this.initialize();
		}
	}
	
	/**
	 * Save the DDS eligibility for the current case.
	 */
	public Boolean save()
	{
		return true;
	}
	
	
	private void initialize()
	{
		Case sourceCase = this.parentControllerReference.getCase();
 		String caseRecordType = System.currentPageReference().getParameters().get('caseRecType');
 		String currentUserProfileName = [Select Name from Profile where ID=:UserInfo.getProfileId()].Name;
		Boolean isEligibleProfile = false;
		if(currentUserProfileName.startsWith('GNE-CM')
				|| currentUserProfileName=='GNE-SYS-Support'
				|| currentUserProfileName=='System Administrator')
		{
			isEligibleProfile = true;
		}
		GNE_CM_DDS_Settings__c ddsSettings = GNE_CM_DDS_Settings__c.getInstance();
		this.visible = (sourceCase.RecordType.name == 'C&R - Standard Case' || (caseRecordType != null && caseRecordType == 'CRS')) && !ddsSettings.Functionality_Disabled__c && isEligibleProfile;
		this.parentControllerReference.setRequestServicesVisible(!((sourceCase.RecordType.name == 'C&R - Standard Case' || (caseRecordType != null && caseRecordType == 'CRS')) && !ddsSettings.Functionality_Disabled__c));
		this.isOverrideColumnEnabled = ddsSettings.Override_Enabled__c;
	}
	
	private Boolean validatePatientAge(Patient_gne__c patient, Decimal requiredMinAge, Decimal requiredMaxAge) 
	{
		return (requiredMinAge == null || patient.Age_gne__c >= requiredMinAge) && (requiredMaxAge == null || patient.Age_gne__c <= requiredMaxAge);
	}
}