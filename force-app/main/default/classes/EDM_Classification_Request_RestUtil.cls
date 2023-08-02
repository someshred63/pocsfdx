global class EDM_Classification_Request_RestUtil {
	public static final String EXTERNAL_SYSTEM_NAME = 'MA';

	public enum Feature {
			ClassifReqNotifyMAOnCreation, ClassifReqRedirectReviewToMA, 
			ClassifReqRedirectCreationToMA,
			ClassifReqCreate, ClassifReqReview, ClassifReqGet}

	public enum ClassificationType {Business, Clinical}

	public static final String S2S_ERROR_CODE_PENDING_BUSINESS_CLASSIFICATION_REQUEST_EXISTS = 'ClassificationRequestPendingBusinessExists';
	public static final String S2S_ERROR_CODE_PENDING_CLINICAL_CLASSIFICATION_REQUEST_EXISTS = 'ClassificationRequestPendingClinicalExists';
	public static final String S2S_ERROR_CODE_CLASSIFICATION_REQUEST_ALREADY_REVIEWED = 'ClassificationRequestAlreadyReviewed';
	public static final String S2S_ERROR_CODE_ACCOUNT_CANNOT_BE_FOUND_CREATED = 'ClassificationRequestAccountCannotBeFoundCreated';
	public static final String S2S_ERROR_CODE_INVALID_USER = 'ClassificationRequestInvalidUser';

	global virtual class ClassificationRequestWrapper extends GNE_SFA2_S2S_Util.Record implements GNE_SFA2_S2S_Interface.RequestInterface {
		public UserWrapper requestor;
		public AccountWrapper account;
		public ClassificationType classificationType;
		public String classificationRequestBusinessRole;
		public String classificationRequestNotes;
		public Date classificationRequestDateSubmitted;
		public String classificationRequestAccountSpecialty;
		public String classificationRequestMedicalUnit;

		public ClassificationRequestCV classificationRequestCV;

		public String classificationRequestStatus;
		public ClassificationReviewOutcome reviewOutcome;

		Map<String, List<PicklistValue>> picklistValues;

		public ClassificationRequestWrapper() {}

		public ClassificationRequestWrapper(EDM_Classification_Request_gne__c classificationRequest,
					User requestorUser, User reviewerUser, Account acc) {
			for (ClassificationType classType : EDM_Classification_Request_RestUtil.ClassificationType.values()) {
				if (classType.name() == classificationRequest.EDM_Type_of_Classification_gne__c) {
					this.classificationType = classType;
				}
			}
			this.setLocalId(classificationRequest.Id);
			this.classificationRequestBusinessRole = classificationRequest.EDM_Business_Role_gne__c;
			this.classificationRequestNotes = classificationRequest.EDM_Requestor_Comments_gne__c;
			this.classificationRequestStatus = classificationRequest.EDM_Status_gne__c;
			this.classificationRequestDateSubmitted = classificationRequest.EDM_Date_Submitted_gne__c;
			this.classificationRequestAccountSpecialty = classificationRequest.EDM_Account_Specialty_gne__c;
			this.classificationRequestMedicalUnit = classificationRequest.EDM_Medical_Unit_gne__c;

			if (requestorUser != null) {
				this.requestor = new UserWrapper(requestorUser);
			}
			if (acc != null) {
				Address_vod__c mainAddr;
				if (acc.Address_vod__r != null && !acc.Address_vod__r.isEmpty()) {
					mainAddr = acc.Address_vod__r.get(0);
				}
				this.account = new AccountWrapper(acc, mainAddr);
			}

			if (classificationRequest.EDM_Status_gne__c == 'Completed') {
				this.reviewOutcome = new ClassificationReviewOutcome(
						classificationRequest.EDM_Action_Taken_gne__c, 
						classificationRequest.EDM_Action_Comments_gne__c,
						classificationRequest.EDM_Reviewed_Date_Formula_gne__c.date(),
						reviewerUser);
			} else {
				prepareSynapsePossibleActions();
			}

			if (!classificationRequest.attachments.isEmpty()) {
				this.classificationRequestCV = new classificationRequestCV(
						classificationRequest.attachments.get(0),
						prepareLinkToAttachment(classificationRequest.attachments.get(0).Id));
						//classificationRequest.EDM_CV_Attachment_Link_gne__c);
			}
		}

		private void prepareSynapsePossibleActions() {
			this.picklistValues = new Map<String, List<PicklistValue>>();
			List<PicklistValue> synapsePossibleActions = new List<PicklistValue>();
			List<SelectOption> possibleActions = EDM_Classification_Utils.getPickListValues(EDM_Classification_Request_gne__c.getSObjectType(), 'EDM_Action_Taken_gne__c');
			for (SelectOption possibleAction : possibleActions) {
				synapsePossibleActions.add(
					new PicklistValue(
							possibleAction.getLabel(), possibleAction.getValue()
					));
			}
			this.picklistValues.put('actionTaken', synapsePossibleActions);
		}

		public virtual System.Type getSelfClass() {
			return ClassificationRequestWrapper.class;
		}

		public virtual List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
			return null;
		}
		
		public virtual void addRecord(GNE_SFA2_S2S_Interface.RecordInterface rec) {
		}
		
		public virtual Actor getActor() {
			if (reviewOutcome != null && reviewOutcome.reviewer != null) {
				return reviewOutcome.reviewer;
			}

			if (requestor != null) {
				return requestor;
			}
			
			return null;
		}
		
		public virtual void setActor(GNE_SFA2_S2S_Interface.ActorInterface actor) {
		}
		
		public virtual Boolean isAllOrNone() {
			return true;//only one
		}
	}

	public static String prepareLinkToAttachment(Id attachId) {
		String viewURL = '/servlet/servlet.FileDownload?file=';
		return viewURL + attachId;
	}

	public class PicklistValue {
		public Boolean active;
		public Boolean defaultValue;
		public String label;
		public String value;

		public PicklistValue(String label, String value) {
			this.active = true;
			this.defaultValue = false;
			this.label = label;
			this.value = value;
		}
	}


	public class UserWrapper extends GNE_SFA2_S2S_Util.Actor {
		public UserWrapper(User u) {
			super(u);
		}
	}

	public class AccountWrapper extends GNE_SFA2_S2S_Util.PersonAccount {
		public AccountWrapper(Account acc, Address_vod__c addr) {
			super(acc, addr);
			this.setExtId(acc.MA_id__c);

			GNE_SFA2_S2S_Interface.AddressInterface address = getAddress();
			if (address != null) {
				address.setExtId(addr.MA_id__c);
			}
		}
	}

	public class ClassificationRequestCV {
		public String filename;
		public String data;

		public ClassificationRequestCV(Attachment attach, String link) {
			this.filename = attach.Name;
			/*data - to download CV use /ClassificationRequests/RequestId/CV path or */
			this.data = URL.getSalesforceBaseUrl().toExternalForm() + link;
		}
	}

	public class ClassificationReviewOutcome {
		public String actionTaken;
		public String actionComments;
		public UserWrapper reviewer;
		public Date classificationDate;

		public ClassificationReviewOutcome(String actionTaken, String actionComments, 
				Date classificationDate, User reviewerUser) {
			this.actionTaken = actionTaken;
			this.actionComments = actionComments;
			this.classificationDate = classificationDate;
			this.reviewer = new UserWrapper(reviewerUser);
		}
	}

	global virtual class ClassificationRequestResults extends GNE_SFA2_S2S_Util.Response {
		protected List<ClassificationRequestWrapper> records;

		@TestVisible String next;
		@TestVisible String prev;
		Integer countWithoutLimit;

		public ClassificationRequestResults(Boolean success, List<ClassificationRequestWrapper> classificationRequestWrappers,
				Integer countWithoutLimit,
				String next,
				String prev) {
			this.success = success;
			this.records = classificationRequestWrappers;
			this.countWithoutLimit = countWithoutLimit;
			this.next = next;
			this.prev = prev;
		}

		public ClassificationRequestResults() {
		}

		public void cloneResultsFrom(ClassificationRequestResults resultsToClone) {
			this.success = resultsToClone.success;
			this.records = resultsToClone.records;
			this.countWithoutLimit = resultsToClone.countWithoutLimit;
			this.next = resultsToClone.next;
			this.prev = resultsToClone.prev;
		}

		public virtual override System.Type getSelfClass() {
			return ClassificationRequestResults.class;
		}

		public virtual override List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
			if (this.records == null) {
				this.records = new List<ClassificationRequestWrapper>();
			}
			
			return this.records;
		}
	}

	public static String getUrlForReviewOnMA(Id classificationRequestId) {
		String baseUrlOnMA = GNE_SFA2_S2S_Config_Items_gne__c.getInstance('MABaseUrl').Value_gne__c;
		String page = GNE_SFA2_S2S_Config_Items_gne__c.getInstance('MAClassificationRequestReviewPage').Value_gne__c;
		if (String.isBlank(page)) {
			System.debug('MAClassificationRequestReviewPage param is blank');
			return baseUrlOnMA;
		} else {
			page = page.replace('{{id}}', classificationRequestId);
			return baseUrlOnMA + (page.startsWith('/') ? '' : '/') + page;
		}
		
	}

	public static String getUrlToCreateNewClassificationRequestForMA(Id accountId, String typeOfClassification) {
		String baseUrlOnMA = GNE_SFA2_S2S_Config_Items_gne__c.getInstance('MABaseUrl').Value_gne__c;
		List<Account> accs = [SELECT Id, MA_Id__c FROM Account WHERE Id = :accountId LIMIT 1];
		if (!accs.isEmpty() && accs.get(0).MA_Id__c != null) {
			return baseUrlOnMA + getClassificationRequestPageWithParamForMA(accs.get(0).MA_Id__c, typeOfClassification);
		} else {
			return baseUrlOnMA;
		}
	}

	private static String getClassificationRequestPageWithParamForMA(Id maAccountId, String typeOfClassification) {
		String classificationRequestPageOnMA = GNE_SFA2_S2S_Config_Items_gne__c.getInstance('MAClassificationRequestPage').Value_gne__c;
		if (String.isBlank(classificationRequestPageOnMA)) {
			return '';
		} else {
			return (classificationRequestPageOnMA.startsWith('/') ? '' : '/') + classificationRequestPageOnMA
					.replace('{{maAccountId}}', maAccountId)
					.replace('{{typeOfClassification}}', typeOfClassification)
					.replace('{{retURL}}', '/' + maAccountId);
		}
	}
}