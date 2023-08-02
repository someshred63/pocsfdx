global without sharing class EDM_Classification_Request_URL_Ctr {
	public String profileName { get; set; }
	public String accountId { get; set; }
	public String classificationType { get; set; }

	private Set<String> sfdcProfiles = new Set<String> { 
							'GNE-AGS-CCO-Analyst', 
							'GNE-AGS-CCO-Manager', 
							'GNE-AGS-CCO-TempAnalyst', 
							'GNE-AGS-CCG-Exclusions', 
							'GNE-SYS-ADMIN-SBL',
							'GNE-VDST-Partner-External',
							'System Administrator' 
						};
	private Set<String> newProfiles = new Set<String> {
							'GNE-TLS',
							'GNE-TLS-AB-SB-Admin',
							'GNE-TLS-ABM-Approver',
							'GNE-TLS-ABM-Reviewer',
							'GNE-TLS-Manager',
							'GNE-TLS-SpeakerBureauLead',
							'GNE-MedAffairs-MCL',
							'GNE-MedAffairs-MCL-Manager',
							'GNE-MedAffairs-MSL',
							'GNE-MedAffairs-MSL-Manager',
							'GNE-MedAffairs-SP',
							'GNE-MedAffairs-SP-Manager'
						};

	public EDM_Classification_Request_URL_Ctr() {
		
	}

	public String getClassificationURL() {
		Integer d = checkWhichLayout();
		if (d == 0) {
			return getUrlForSFDC(classificationType);
		} else if (d == 1) {
			return getUrlForNew(classificationType);
		} else if (d == 2) {
			return EDM_Classification_Request_RestUtil.getUrlToCreateNewClassificationRequestForMA(accountId, classificationType);
		}
		return 'no url';
	}

	private Integer checkWhichLayout() { 
		//String usrProfileName = request.EDM_Requestor_Profile_gne__c;
		String usrProfileName = profileName;
		if (GNE_SFA2_S2S_Util.isFeatureEnabled(EDM_Classification_Request_RestUtil.Feature.ClassifReqRedirectCreationToMA.name()) &&
				usrProfileName.startsWith('GNE-MedAffairs')) {
			return 2;
		}
		if (sfdcProfiles.contains(usrProfileName)) {
			return 0;
		}
		else if (newProfiles.contains(usrProfileName)) {
			return 1;
		}
		return -1;
	}

	private String getUrlForSFDC(String typeOfClassification) {
		String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
		PageReference pr = Page.EDM_Classification_Request_Create_SFDC;
		pr.getParameters().put('accountId', accountId);
		pr.getParameters().put('retUrl', '/' + accountId);
		pr.getParameters().put('typeOfClassification', typeOfClassification);
		return baseURL + pr.getUrl();
	}

	private String getUrlForNew(String typeOfClassification) {
		String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
		PageReference pr = Page.EDM_Classification_Request_Edit_Create;
		pr.getParameters().put('accountId', accountId);
		pr.getParameters().put('retUrl', '/' + accountId);
		pr.getParameters().put('typeOfClassification', typeOfClassification);
		return baseURL + pr.getUrl();
	}
}