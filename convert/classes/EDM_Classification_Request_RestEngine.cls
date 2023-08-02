public virtual class EDM_Classification_Request_RestEngine implements 
		GNE_SFA2_S2S_Interface.RestServiceCallInterface, 
		GNE_SFA2_S2S_Interface.RestServiceExecuteInterface,
		GNE_SFA2_S2S_Interface.EngineErrorListenerInterface {

	public EDM_Classification_Request_RestEngine() {}
	
	public virtual System.Type getSelfClass() {
		return EDM_Classification_Request_RestEngine.class;
	}
	
	public void executeRestMethod(GNE_SFA2_S2S_Interface.EngineInterface engine) {
		GNE_SFA2_S2S_Util.startDebugAction('executeRestMethod');

		EDM_Classification_Request_RestUtil.ClassificationRequestResults results;
		if (engine.getHttpMethod() == 'GET') {
			results = EDM_Classification_Request_Rest_Get.getClassificationRequests();
		} else if (engine.getHttpMethod() == 'POST') {
			EDM_Classification_Request_RestUtil.ClassificationRequestWrapper classificationRequestData = (EDM_Classification_Request_RestUtil.ClassificationRequestWrapper)engine.getRequest();
			Id classificationRequestId;

			/*UpdateClassificationMode means create classification request and review in one call*/
			Boolean isUpdateClassificationMode = classificationRequestData.reviewOutcome != null && engine.getFeatureName() == EDM_Classification_Request_RestUtil.Feature.ClassifReqCreate.name();
			
			if (engine.getFeatureName() == EDM_Classification_Request_RestUtil.Feature.ClassifReqCreate.name()) {
				classificationRequestId = createClassificationRequest(classificationRequestData, isUpdateClassificationMode);
				classificationRequestData.setLocalId(classificationRequestId);
			}

			if (engine.getFeatureName() == EDM_Classification_Request_RestUtil.Feature.ClassifReqReview.name() ||
					isUpdateClassificationMode) {
				classificationRequestId = classificationRequestData.getLocalId();
				updateClassificationReviewOutcome(classificationRequestId, classificationRequestData.reviewOutcome, isUpdateClassificationMode);
			}

			results = EDM_Classification_Request_Rest_Get.getClassificationRequests(classificationRequestId);
		}

		EDM_Classification_Request_RestUtil.ClassificationRequestResults castedResponse = (EDM_Classification_Request_RestUtil.ClassificationRequestResults)engine.getResponse();
		castedResponse.cloneResultsFrom(results);

		GNE_SFA2_S2S_Util.endDebugAction('executeRestMethod');
	}

	public void onRestEngineError(Exception ex, GNE_SFA2_S2S_Interface.EngineInterface engine) {
		RestResponse res = RestContext.response;
		if (res != null) {
			res.statusCode = 400;
		}
	}	

	private static String createClassificationRequest(EDM_Classification_Request_RestUtil.ClassificationRequestWrapper classificationRequestData, Boolean isUpdateClassificationMode) {
		checkIfAllRequiredDataProvided(classificationRequestData);
		Account acc = obtainAccount(classificationRequestData.account);
		return createClassificationRequest(acc, classificationRequestData, isUpdateClassificationMode);
	}

	private static Account obtainAccount(EDM_Classification_Request_RestUtil.AccountWrapper accountWrp) {
		GNE_SFA2_S2S_Util.startDebugAction('obtainAccount');
		Account acc = accountWrp.searchOrCreate(accountWrp.getAddress());
		GNE_SFA2_S2S_Util.endDebugAction('obtainAccount');
		if (acc != null) {
			return acc;
		}
		throw GNE_SFA2_S2S_Util.createException(EDM_Classification_Request_RestUtil.S2S_ERROR_CODE_ACCOUNT_CANNOT_BE_FOUND_CREATED);
	}

	private static Id createClassificationRequest(Account acc, EDM_Classification_Request_RestUtil.ClassificationRequestWrapper classificationRequestData, Boolean isUpdateClassificationMode) {
		if (EDM_Classification_Utils.checkIfPendingClassificationRequest(acc.id, classificationRequestData.classificationType.name())) {
			if (classificationRequestData.classificationType == EDM_Classification_Request_RestUtil.ClassificationType.Business) {
				throw GNE_SFA2_S2S_Util.createException(EDM_Classification_Request_RestUtil.S2S_ERROR_CODE_PENDING_BUSINESS_CLASSIFICATION_REQUEST_EXISTS);
			} else {
				throw GNE_SFA2_S2S_Util.createException(EDM_Classification_Request_RestUtil.S2S_ERROR_CODE_PENDING_CLINICAL_CLASSIFICATION_REQUEST_EXISTS);
			}
		}
		EDM_Classification_Request_gne__c classificationRequest = new EDM_Classification_Request_gne__c();
		setTypeOfClassification(classificationRequest, classificationRequestData.classificationType.name());
		classificationRequest.EDM_Account_gne__c = acc.id;
		classificationRequest.EDM_Requestor_gne__c = getUserId(classificationRequestData.requestor);
		classificationRequest.EDM_Status_gne__c = isUpdateClassificationMode ? 'Completed' : 'Pending';
		classificationRequest.EDM_Account_Primary_Address_gne__c = EDM_Cl_Req_Edit_Create_Ext.getAddress(acc.id);
		classificationRequest.EDM_Account_Specialty_gne__c = classificationRequestData.account.getSpecialties();
		classificationRequest.EDM_Requestor_Comments_gne__c = classificationRequestData.classificationRequestNotes;
		classificationRequest.EDM_Medical_Unit_gne__c = classificationRequestData.classificationRequestMedicalUnit;
		
		if (classificationRequestData.classificationType == EDM_Classification_Request_RestUtil.ClassificationType.Business) {
			classificationRequest.EDM_Business_Role_gne__c = classificationRequestData.classificationRequestBusinessRole;
		}

		GNE_SFA2_S2S_Util.startDebugAction('insertClassificationRequest');
		insert classificationRequest;
		GNE_SFA2_S2S_Util.endDebugAction('insertClassificationRequest');

		GNE_SFA2_S2S_Util.startDebugAction('insertCvAttachment');
		Attachment attachmentCV = prepateAttachmentCV(classificationRequestData.classificationRequestCV);
		if (EDM_Classification_Utils.insertAttachment(attachmentCV, classificationRequest.Id)) {
			futureSaveAttachmentLinkndSendNotifications(classificationRequest.Id, attachmentCV.Id);
		}
		GNE_SFA2_S2S_Util.endDebugAction('insertCvAttachment');

		return classificationRequest.Id;
	}

	@future
	private static void futureSaveAttachmentLinkndSendNotifications(String classificationRequestId, String attachId) {
		EDM_Classification_Request_gne__c classificationRequest = [
				SELECT Id, EDM_CV_Attachment_Link_gne__c
				FROM EDM_Classification_Request_gne__c
				WHERE Id = :classificationRequestId
				LIMIT 1];
		classificationRequest.EDM_CV_Attachment_Link_gne__c = EDM_Classification_Request_RestUtil.prepareLinkToAttachment(attachId);
		update classificationRequest;
	}

	private static Id getUserId(EDM_Classification_Request_RestUtil.UserWrapper userWrp) {
		List<User> users = [SELECT Id FROM User WHERE External_Id_gne__c = :userWrp.getUnixId()];
		if (users.isEmpty()) {
			throw GNE_SFA2_S2S_Util.createException(EDM_Classification_Request_RestUtil.S2S_ERROR_CODE_INVALID_USER);
		}
		return users.get(0).Id;
	}

	private static void setTypeOfClassification(EDM_Classification_Request_gne__c classificationRequest, String typeOfClassification) {
		try {
			Id recTypeId = Schema.SObjectType.EDM_Classification_Request_gne__c.getRecordTypeInfosByName().get(typeOfClassification).getRecordTypeId();
			classificationRequest.RecordTypeId = recTypeId;
			classificationRequest.EDM_Type_of_Classification_gne__c = typeOfClassification;
		} catch (Exception e) {
			throw new InvalidClassificationRequestException('Unknown Classification Type: ' + typeOfClassification, e);
		}
	}

	private static Attachment prepateAttachmentCV(EDM_Classification_Request_RestUtil.ClassificationRequestCV cv) {
		Attachment a = new Attachment();
		a.Name = cv.filename;
		a.Body = EncodingUtil.base64Decode(cv.data);

		cv.data = cv.data.left(32) + '...'; //shorten to not have in s2s log very long string 
		return a;
	}

	private static void updateClassificationReviewOutcome(Id classificationRequestId, EDM_Classification_Request_RestUtil.ClassificationReviewOutcome reviewOutcome, Boolean isUpdateClassificationMode) {
		checkIfAllRequiredDataProvidedForReview(reviewOutcome);

		EDM_Classification_Request_gne__c classificationRequest = [
				SELECT Id, EDM_Status_gne__c, EDM_Account_gne__c, EDM_Type_of_Classification_gne__c,
					EDM_Business_Role_gne__c
				FROM EDM_Classification_Request_gne__c
				WHERE Id = :classificationRequestId LIMIT 1];
		if (classificationRequest.EDM_Status_gne__c == 'Completed' && !isUpdateClassificationMode) {
			throw GNE_SFA2_S2S_Util.createException(EDM_Classification_Request_RestUtil.S2S_ERROR_CODE_CLASSIFICATION_REQUEST_ALREADY_REVIEWED);
		}

		classificationRequest.EDM_Action_Taken_gne__c = reviewOutcome.actionTaken;
		classificationRequest.EDM_Action_Comments_gne__c = reviewOutcome.actionComments;
		classificationRequest.EDM_Status_gne__c = 'Completed';
		classificationRequest.EDM_Reviewer_gne__c = getUserId(reviewOutcome.reviewer);
		classificationRequest.EDM_Reviewed_Date_gne__c = System.now();

		update classificationRequest;

		changeClassificationOnAccount(classificationRequest, getUserId(reviewOutcome.reviewer));
	}

	private static void changeClassificationOnAccount(EDM_Classification_Request_gne__c classificationRequest, Id reviewerId) {
		if (classificationRequest.EDM_Action_Taken_gne__c == 'Decline to Classify') {
			//TODO how to notify 
			return;
		}

		String attachmentLink = retrieveAttachmentLink(classificationRequest);

		Account acc = [SELECT Id from Account WHERE Id = :classificationRequest.EDM_Account_gne__c LIMIT 1];
		if (classificationRequest.EDM_Type_of_Classification_gne__c == 'Business') {
			acc.EDM_Business_Classification_gne__c = classificationRequest.EDM_Action_Taken_gne__c;
			acc.EDM_Business_Classification_Date_gne__c = System.today();
			acc.EDM_Business_Classification_DateTime_gne__c = System.now();
			acc.EDM_Business_Cl_Performed_By_gne__c = reviewerId;

			acc.EDM_Business_Cl_Role_gne__c = classificationRequest.EDM_Business_Role_gne__c;
			acc.EDM_Business_Classification_CV_gne__c = attachmentLink;
		} else {
			acc.EDM_Clinical_Classification_gne__c = classificationRequest.EDM_Action_Taken_gne__c;
			acc.EDM_Clinical_Classification_Date_gne__c = System.today();
			acc.EDM_Clinical_Classification_DateTime_gne__c = System.now();
			acc.EDM_Clinical_Cl_Performed_By_gne__c = reviewerId;

			acc.EDM_Clinical_Classification_CV_gne__c = attachmentLink;
		}

		GNE_SFA2_S2S_Util.startDebugAction('changeClassificationOnAccount');
		update acc;
		GNE_SFA2_S2S_Util.endDebugAction('changeClassificationOnAccount');

		List<Speaker_Bureau_Membership_gne__c> sbms = [SELECT Speaker_Status_gne__c, Bureau_Member_gne__c, Speaker_Bureau_ID_gne__c, Current_Speaker_Scope_gne__c, Current_Speaker_Scope_Date_gne__c, Current_Exclusion_Status_gne__c, Current_Exclusion_Status_Date_gne__c
				FROM Speaker_Bureau_Membership_gne__c
				WHERE Bureau_Member_gne__c = :acc.Id];
		GNE_SFA2_Spkr_Bur_Mem_Validation_Rules.takeSnapshotClassificationAndExclusion(sbms);
		if(sbms != null)
			update sbms;
	}

	private static String retrieveAttachmentLink(EDM_Classification_Request_gne__c classificationRequest) {
		List<EDM_Classification_Request_gne__c> classReqAttach = [Select EDM_CV_Attachment_Link_gne__c From EDM_Classification_Request_gne__c where id = :classificationRequest.id LIMIT 1];
		return (!classReqAttach.isEmpty() ? classReqAttach.get(0).EDM_CV_Attachment_Link_gne__c : '');
	}

	private static void checkIfAllRequiredDataProvided(EDM_Classification_Request_RestUtil.ClassificationRequestWrapper classificationRequestData) {
		if (classificationRequestData.account == null) {
			throw new InvalidClassificationRequestException('Classification Request: Account parameter is missing');
		}

		if (classificationRequestData.account.getAddress() == null) {
			throw new InvalidClassificationRequestException('Classification Request: Account address parameter is missing');
		}

		if (classificationRequestData.requestor == null || String.isBlank(classificationRequestData.requestor.getUnixId())) {
			throw new InvalidClassificationRequestException('Classification Request: Requestor parameter is required');
		}
		if (String.isBlank(classificationRequestData.classificationRequestNotes)) {
			throw new InvalidClassificationRequestException('Classification Request: Description of Planned Activity is required');
		}
		if (classificationRequestData.classificationType == EDM_Classification_Request_RestUtil.ClassificationType.Business) {
			if (String.isBlank(classificationRequestData.classificationRequestBusinessRole)) {
				throw new InvalidClassificationRequestException('Classification Request: Specialty/Business Role is required');
			}
		}
		if (classificationRequestData.classificationRequestCV == null
				|| String.isBlank(classificationRequestData.classificationRequestCV.filename)
				|| String.isBlank(classificationRequestData.classificationRequestCV.data)) {
			throw new InvalidClassificationRequestException('Classification Request: CV is required');
		}

		if (classificationRequestData.reviewOutcome != null) {
			checkIfAllRequiredDataProvidedForReview(classificationRequestData.reviewOutcome);
		}
	}

	private static void checkIfAllRequiredDataProvidedForReview(EDM_Classification_Request_RestUtil.ClassificationReviewOutcome reviewOutcome) {
		if (reviewOutcome == null) {
			throw new InvalidClassificationRequestException('Classification Outcome: reviewOutcome parameter is missing');
		}
		if (String.isBlank(reviewOutcome.actionTaken)) {
			throw new InvalidClassificationRequestException('Classification Outcome: Action Taken is required');
		}
		if (reviewOutcome.reviewer == null || String.isBlank(reviewOutcome.reviewer.getUnixId())) {
			throw new InvalidClassificationRequestException('Classification Outcome: Reviewer parameter is missing');
		}
		if (reviewOutcome.actionTaken == 'Decline to Classify' && String.isBlank(reviewOutcome.actionComments)) {
			throw new InvalidClassificationRequestException('Classification Outcome: Classification Comments are required');
		}
	}

	private class InvalidClassificationRequestException extends Exception {}

	@future(callout=true)
	public static void futureNotifyExtSystemOnClassificationRequestCreation(Id classificationRequestId) {
		System.debug('futureNotifyExtSystemOnClassificationRequestCreation: ' + classificationRequestId);
		(new EDM_Classification_Request_RestEngine()).notifyExtSystemOnClassificationRequestCreation(classificationRequestId);
	}

	private void notifyExtSystemOnClassificationRequestCreation(Id classificationRequestId) {
		System.debug('notifyExtSystemOnClassificationRequestCreation: ' + classificationRequestId);
		(new ExtSystemNotification()).notify(classificationRequestId, this);
	}

	private class ExtSystemNotification {
		public void notify(Id classificationRequestId, GNE_SFA2_S2S_Interface.RestServiceCallInterface service) {
			EDM_Classification_Request_RestUtil.ClassificationRequestWrapper req = this.prepareRequest(classificationRequestId);

			EDM_Classification_Request_RestUtil.ClassificationRequestResults result = (EDM_Classification_Request_RestUtil.ClassificationRequestResults)GNE_SFA2_S2S_ServiceEngine.callRestPostMethod(
					EDM_Classification_Request_RestUtil.EXTERNAL_SYSTEM_NAME, EDM_Classification_Request_RestUtil.Feature.ClassifReqNotifyMAOnCreation.name(),
					service, req, EDM_Classification_Request_RestUtil.ClassificationRequestResults.class);

			System.debug('notifyExtSystemOnClassificationRequestCreation result: ' + result);
			if (result.isSuccess() && !result.getRecords().isEmpty()) {
				EDM_Classification_Request_RestUtil.ClassificationRequestWrapper res = (EDM_Classification_Request_RestUtil.ClassificationRequestWrapper)result.getRecords().get(0);
				this.updateAccountMaId(req.account, res.account);
			}
		}

		private EDM_Classification_Request_RestUtil.ClassificationRequestWrapper prepareRequest(Id classificationRequestId) {
			EDM_Classification_Request_RestUtil.ClassificationRequestResults results =
					EDM_Classification_Request_Rest_Get.getClassificationRequests(classificationRequestId);
			EDM_Classification_Request_RestUtil.ClassificationRequestWrapper req = 
					(EDM_Classification_Request_RestUtil.ClassificationRequestWrapper)results.getRecords().get(0);

			System.debug('notifyExtSystemOnClassificationRequestCreation request: ' + req);

			return req;
		}

		private void updateAccountMaId(EDM_Classification_Request_RestUtil.AccountWrapper accountWrpLocal, 
				EDM_Classification_Request_RestUtil.AccountWrapper accountWrpMA) {
			if (accountWrpLocal.getExtId() == null && accountWrpMA.getLocalId() != null &&
						accountWrpLocal.getLocalId() == accountWrpMA.getExtId()) {
					Account accToUpdate = [SELECT Id, MA_id__c FROM Account where Id = :accountWrpLocal.getLocalId() LIMIT 1];
					System.debug('To update: ' + accToUpdate);
					System.debug('MA_id__c: ' + accountWrpMA.getLocalId());
					accToUpdate.MA_id__c = accountWrpMA.getLocalId();
					update accToUpdate;
				}
		}
	}
}