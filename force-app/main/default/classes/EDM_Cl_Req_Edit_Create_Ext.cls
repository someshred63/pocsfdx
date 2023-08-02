public with sharing class EDM_Cl_Req_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {
	private EDM_Classification_Request_gne__c classificationRequest;

	public Attachment attachmentCV {get; set;}

	//need to show popup at the end, but can't use AJAX, oncomplete on save, because of inputFile.
	public String returnMessage {get; set;}
	//public String returnURL {get; set;}
	public String accountId {get;set;}
	public String nameOfSavedFile {get; set;}
	public String nomination{get;set;}
	private Boolean sfdcMode = true;

	public EDM_Cl_Req_Edit_Create_Ext(ApexPages.StandardController controller) {        
		super(controller, getPageUrl());
		checkIfInSFDCMode();
		attachmentCV = new Attachment();
		returnMessage = '';
		//returnURL = '';
		nameOfSavedFile = '';
		initClassificationRequest();
		nomination = ApexPages.currentPage().getParameters().get('nomination');
	}
    
    private static String getPageUrl() {
        return GNE_SFA2_Util.isCCCrmUser() ?'/apex/EDM_CRM_Classification_Request' :'/apex/EDM_Classification_Request_Edit_Create';
    }

	private void initClassificationRequest() {
		classificationRequest = (EDM_Classification_Request_gne__c)controller.getRecord();

		accountId = ApexPages.currentPage().getParameters().get('accountId');
		String typeOfClassification = ApexPages.currentPage().getParameters().get('typeOfClassification');

		setAccount(accountId);
		setTypeOfClassification(typeOfClassification);

		if (EDM_Classification_Utils.checkIfPendingClassificationRequest(accountId, typeOfClassification)) {
			prepareReturnMessageAlreadySubmitted();
		}
	}

	private void prepareReturnMessageAlreadySubmitted() {
		prepareReturnMessage('Request for this Account has already been submitted');
	}

	private void prepareReturnMessage(String returnMessage) {
		this.returnMessage = returnMessage;
		if (sfdcMode) {
			Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, returnMessage));
		}
		//returnURL = getReturnURL();
	}

	protected override void initController(ApexPages.StandardController controller) {
		if(controller.getRecord().Id == null) {
			myObject = classificationRequest;
		}
		super.initController(controller);
		recordTypeName = ApexPages.currentPage().getParameters().get('typeOfClassification');
	}

	private void checkIfInSFDCMode() {
		if (ApexPages.currentPage().getUrl().split('apex/')[1].contains('SFDC')) {
			sfdcMode = true;
		}
	}

	private void setAccount(String accountId) {
		classificationRequest.EDM_Account_gne__c = accountId;

		if (String.isBlank(accountId)) {
			Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Account need to be provided by URL'));
		}
	}

	private void setTypeOfClassification(String typeOfClassification) {
		try {
			Id recTypeId = Schema.SObjectType.EDM_Classification_Request_gne__c.getRecordTypeInfosByName().get(typeOfClassification).getRecordTypeId();
			classificationRequest.RecordTypeId = recTypeId;
			classificationRequest.EDM_Type_of_Classification_gne__c = typeOfClassification;
		} catch (Exception e) {
			Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Unknown record type: ' + typeOfClassification));
		}
	}

	public override PageReference cancel() {
		return EDM_Classification_Utils.createPageRef(getReturnURL());
	}

	public PageReference cancelNominationAndRedirect(){
		String bureauId = ApexPages.currentPage().getParameters().get('bureauId');
        return EDM_SB_Nomination_Ext.cancelNomination(accountId, bureauId);
    }

	public override void prepareHelpTextExistsMap(Map<String,Schema.SObjectField> sObjectFieldMap, String viewField, String layoutDetailsId) {   
		try {
			if (viewField == 'EDM_Business_Role_gne__c') {
				String helpTextHC = 'Please select the category below that best describes the HCP:</br><b>Hospital C-Suite/VP/Director:</b> Hospital leadership (not limited to: CEO, President, CIO, Executive Director, VP Operations, etc.)</br><b>Clinical Business Practice Leader</b>(with clinical background, e.g., MD, PharmD, etc.): Leadership of a large practice or network of practices with clinical training, experience and credentials (not limited to: CEO, Administrator, Director)</br><b>Non-Clinical Business Practice Leader</b> (without clinical background, e.g., MBA, MPH, BA, BS, etc.): Leadership of a large practice or network of practices without clinical training, experience and credentials (not limited to: CEO, Administrator, Director)</br><b>Managed Care Expert:</b> Leaders and highly experienced in the field of managed care</br><b>Case Manager Expert:</b> Experienced in the field of case management (not limited to: ACM, CCM, RN)</br><b>Practice Manager Expert:</b> Experienced practice manager of a large practice or a practice with several satellite offices�';
				helpTextExistsMap.put(layoutDetailsId, true);
				helpTextValueMap.put(layoutDetailsId, helpTextHC);
			}
			else {
				super.prepareHelpTextExistsMap(sObjectFieldMap, viewField, layoutDetailsId);
			}
		} catch (Exception ex) { 
			System.debug('override prepareHelpTextExistsMap in EDM_Cl_Req_Edit_Create_Ext ' + ex.getMessage());
		}
    }

	public override PageReference save() {
		Attachment attachmentCVCopy = attachmentCV; //copy attachmentCV to not exceeded viewstate when giving response
		attachmentCV = new Attachment();

		if (EDM_Classification_Utils.checkIfPendingClassificationRequest(classificationRequest.EDM_Account_gne__c, classificationRequest.EDM_Type_of_Classification_gne__c)) {
			prepareReturnMessageAlreadySubmitted();
			return null;
		}
		if(attachmentCVCopy.body == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please choose a CV to upload'));
			return ApexPages.currentPage();
		}

		setDefaultValues();

		super.save();
		if (Apexpages.hasMessages()){
			return ApexPages.currentPage();
		}
		
		nameOfSavedFile = insertCvAttachmentAndSaveURL(classificationRequest, attachmentCVCopy);

		if (GNE_SFA2_S2S_Util.isFeatureEnabled(EDM_Classification_Request_RestUtil.Feature.ClassifReqNotifyMAOnCreation.name())) {
			EDM_Classification_Request_RestEngine.futureNotifyExtSystemOnClassificationRequestCreation(classificationRequest.Id);
		}

		prepareReturnMessage('Classification request has been submitted');
		
		if(nomination=='true'){
			String bureauId = ApexPages.currentPage().getParameters().get('bureauId');
			EDM_SB_Nomination_Ext.updateExisitngSBMStatus(accountId, bureauId, 'Pending');
			return redirectUser();
		}
		
		return null;
	}

	private void setDefaultValues() {
		classificationRequest.EDM_Requestor_gne__c = UserInfo.getUserId();
		classificationRequest.EDM_Status_gne__c = 'Pending';
		classificationRequest.EDM_Account_Primary_Address_gne__c = getAddress(classificationRequest.EDM_Account_gne__c);
		classificationRequest.EDM_Account_Specialty_gne__c = [SELECT Id,Specialties_gne__c FROM Account WHERE Id=:classificationRequest.EDM_Account_gne__c].Specialties_gne__c;
	}

	public static String getAddress(Id accountId) {
		List<Address_vod__c> addressList = [
				SELECT Address_1_gne__c, City_vod__c, State_vod__c, Zip_vod__c
				FROM Address_vod__c
				WHERE Account_vod__c = :accountId 
				ORDER BY Primary_vod__c DESC, GOLD_RECORD_gne__c DESC, LastModifiedDate DESC
				LIMIT 1];

		if (!addressList.isEmpty()) {
			Address_vod__c address = addressList.get(0);
			return (String.isNotBlank(address.Address_1_gne__c) ? ' ' + address.Address_1_gne__c : '') +
					(String.isNotBlank(address.City_vod__c) ? ' ' + address.City_vod__c : '') +
					(String.isNotBlank(address.State_vod__c) ? ', ' + address.State_vod__c : '') +
					(String.isNotBlank(address.Zip_vod__c) ? ' ' + address.Zip_vod__c : '');
		}
		return null;
	}

	public static String insertCvAttachmentAndSaveURL(EDM_Classification_Request_gne__c classificationRequest, Attachment attachmentCV) {
		if (EDM_Classification_Utils.insertAttachment(attachmentCV, classificationRequest.id)) {
			classificationRequest.EDM_CV_Attachment_Link_gne__c = EDM_Classification_Utils.prepareLinkToAttachment(attachmentCV);
			update classificationRequest;

			return attachmentCV.name;
		}

		return '';
	}

	public String getReturnURL() {
		return EDM_Classification_Utils.getReturnURL(classificationRequest.EDM_Account_gne__c);
	}


	public PageReference redirectUser() {
		//PageReference pr = new PageReference(getReturnURL());
		PageReference pr = new PageReference('/apex/GNE_SFA2_Account_Dispatcher?id='+accountId+'&nomination=true');
		pr.setRedirect(true);
		return pr;
	}
}