/*
GET /services/apexrest/ClassificationRequests
GET /services/apexrest/ClassificationRequests?limit=20
GET /services/apexrest/ClassificationRequests?limit=20&start=60
GET /services/apexrest/ClassificationRequests/aGj230000004C9DCAU
GET /services/apexrest/ClassificationRequests?mdmId=126
GET /services/apexrest/ClassificationRequests?status=Completed
GET /services/apexrest/ClassificationRequests?accountId=0017000000OYLzkAAH
GET /services/apexrest/ClassificationRequests?sort=CreatedDate%20DESC
GET /services/apexrest/ClassificationRequests?filter=CreatedDate>=LAST_N_MONTHS:3%20AND%20EDM_Status_gne__c!='Completed'
*/
public with sharing class EDM_Classification_Request_Rest_Get {

	private static final Integer DEFALUT_PAGE_SIZE = 10;

	public static EDM_Classification_Request_RestUtil.ClassificationRequestResults getClassificationRequests() {
		List<EDM_Classification_Request_gne__c> results;
		RestRequest req = RestContext.request;
		String classificationRequestId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

		if (classificationRequestId == 'ClassificationRequests') {
			ClassificationRequestSelector classificationRequestSelector = new ClassificationRequestSelector();

			String accountId = req.params.get('accountId');
			String accountIdOnMA = req.params.get('accountIdOnMA');
			if (String.isNotBlank(accountIdOnMA)) {
				classificationRequestSelector.accountIdsOnMA = urlDecode(accountIdOnMA).split(',');
			}

			if (!String.isBlank(accountId)) {
				Map<Id,Id> winnerIdsMap = CORE_Merge_Util.getWinnerIdsMap(new Set<Id> {accountId});
				if (winnerIdsMap.containsKey(accountId)) {
					accountId = winnerIdsMap.get(accountId);
				}
				if (String.isNotBlank(accountIdOnMA)) {
					classificationRequestSelector.addClause('(EDM_Account_gne__c = \'' + accountId + '\' OR EDM_Account_gne__r.MA_Id__c in :accountIdsOnMA)');
				} else {
					classificationRequestSelector.addClause('EDM_Account_gne__c = \'' + accountId + '\'');
				}
			} else if (String.isNotBlank(accountIdOnMA)) {
				classificationRequestSelector.addClause('EDM_Account_gne__r.MA_Id__c in :accountIdsOnMA');
			}

			String status = req.params.get('status');
			if (!String.isBlank(status)) {
				classificationRequestSelector.addClause('EDM_Status_gne__c = \'' + status + '\'');
			}

			String mdmId = req.params.get('mdmId');
			if (!String.isBlank(mdmId)) {
				classificationRequestSelector.addClause('EDM_Account_gne__r.MDMID_gne__c = \'' + mdmId + '\'');
			}

			Integer limitValue = String.isNotBlank(req.params.get('limit')) ?
					Integer.valueOf(req.params.get('limit')) : DEFALUT_PAGE_SIZE;
			Integer startValue = String.isNotBlank(req.params.get('start')) ?
					Integer.valueOf(req.params.get('start')) : 0;


			results = classificationRequestSelector
					.addClause(urlDecode(req.params.get('filter')))
					.orderBy(urlDecode(req.params.get('sort')))
					.withLimit(startValue + limitValue)
					.retrieveMore(startValue);

			return new ClassificationRequestResultsBuilder(results, 
				classificationRequestSelector.countWithoutLimit, limitValue, startValue).build();
		} else {
			return getClassificationRequests(classificationRequestId);
		}
	}

	public static EDM_Classification_Request_RestUtil.ClassificationRequestResults getClassificationRequests(Id classificationRequestId) {
		List<EDM_Classification_Request_gne__c> results = getClassificationRequest(classificationRequestId);

		return new ClassificationRequestResultsBuilder(results)
				.build();
	}

	private static String urlDecode(String value) {
		if (value != null) {
			value = Encodingutil.urlDecode(value, 'UTF-8');
		}
		return value;
	}

	private static List<EDM_Classification_Request_gne__c> getClassificationRequest(Id classificationRequestId) {
		return new ClassificationRequestSelector().addClause('Id = \'' + classificationRequestId + '\'').retrieve();
	}

	private class ClassificationRequestSelector {
		private String theQuery;
		private String theQueryToCount;
		private Boolean whereAdded;
		public Integer countWithoutLimit {get; private set;}
		public List<String> accountIdsOnMA {private get; set;}

		public ClassificationRequestSelector() {
			theQuery = 'SELECT Id, EDM_Account_gne__c, EDM_Requestor_gne__c, EDM_Status_gne__c, EDM_Type_of_Classification_gne__c, ';
			theQuery += 'EDM_Business_Role_gne__c, EDM_Requestor_Comments_gne__c, EDM_Date_Submitted_gne__c, ';
			theQuery += 'EDM_Action_Taken_gne__c, EDM_Action_Comments_gne__c, EDM_CV_Attachment_Link_gne__c, ';
			theQuery += 'LastModifiedDate, EDM_Reviewer_Formula_gne__c, EDM_Account_Specialty_gne__c, ';
			theQuery += 'EDM_Reviewed_Date_Formula_gne__c, ';
			theQuery += '(SELECT Id, Name FROM Attachments), EDM_Medical_Unit_gne__c ';
			theQuery += 'FROM EDM_Classification_Request_gne__c ';
			theQueryToCount = 'SELECT COUNT() FROM EDM_Classification_Request_gne__c ';
			whereAdded = false;
		}

		public ClassificationRequestSelector addClause(String afterFROMClause) {
			if (String.isNotEmpty(afterFROMClause)) {
				if (!whereAdded) {
					whereAdded = true;
					theQuery += ' WHERE';
					theQueryToCount += ' WHERE';
				} else {
					theQuery += ' AND ';
					theQueryToCount += ' AND ';
				}
				theQuery += ' (' + afterFROMClause + ')';
				theQueryToCount += ' (' + afterFROMClause + ')';
			}
			return this;
		}

		public ClassificationRequestSelector withLimit(Integer value) {
			theQuery += ' LIMIT ' + value;
			return this;
		}

		public ClassificationRequestSelector withOffset(Integer value) {
			theQuery += ' OFFSET ' + value;
			return this;
		}

		public ClassificationRequestSelector orderBy(String orderByClause) {
			if (String.isNotBlank(orderByClause)) {
				theQuery += ' ORDER BY ' + orderByClause + ', Id';
			}
			return this;
		}

		public List<EDM_Classification_Request_gne__c> retrieve() {
			countWithoutLimit = Database.countQuery(theQueryToCount);
			return Database.query(theQuery);
		}

		public List<EDM_Classification_Request_gne__c> retrieveMore(Integer startValue){
			countWithoutLimit = Database.countQuery(theQueryToCount);
			List<EDM_Classification_Request_gne__c> longList = Database.query(theQuery);
			List<EDM_Classification_Request_gne__c> finalList = new List<EDM_Classification_Request_gne__c>();
			for(Integer i = startValue; i < longList.size(); i++){
				finalList.add(longList[i]);
			}
			return finalList;
		}
	}

	private class ClassificationRequestResultsBuilder {
		List<EDM_Classification_Request_RestUtil.ClassificationRequestWrapper> classificationRequestWrappers;

		String next;
		String prev;
		Integer countWithoutLimit;

		public ClassificationRequestResultsBuilder(List<EDM_Classification_Request_gne__c> classificationRequests) {
			wrapClassificationRequest(classificationRequests);
		}

		public ClassificationRequestResultsBuilder(List<EDM_Classification_Request_gne__c> classificationRequests, 
					Integer countWithoutLimit,
					Integer limitValue,
					Integer offsetValue) {
			wrapClassificationRequest(classificationRequests);
			this.countWithoutLimit = countWithoutLimit;

			if (hasNext(countWithoutLimit, limitValue, offsetValue)) {
				next = preparePaginationLink(limitValue, offsetValue + limitValue);
			}

			if (hasPrev(limitValue, offsetValue)) {
				prev = preparePaginationLink(limitValue, offsetValue - limitValue);
			}
		}

		public EDM_Classification_Request_RestUtil.ClassificationRequestResults build() {
			return new EDM_Classification_Request_RestUtil.ClassificationRequestResults(
				true, classificationRequestWrappers, countWithoutLimit, next, prev);
		}

		private Boolean hasNext(Integer countWithoutLimit, Integer limitValue, Integer offsetValue) {
			return offsetValue + limitValue < countWithoutLimit;
		}

		private Boolean hasPrev(Integer limitValue, Integer offsetValue) {
			return offsetValue >= limitValue;
		}

		private String preparePaginationLink(Integer limitValue, Integer newOffsetValue) {
			String result = '';
			if (limitValue != DEFALUT_PAGE_SIZE) {
				result = 'limit=' + limitValue + '&';
			}
			return result + 'start=' + newOffsetValue;
		}

		private void wrapClassificationRequest(List<EDM_Classification_Request_gne__c> classificationRequests) {
			classificationRequestWrappers = new List<EDM_Classification_Request_RestUtil.ClassificationRequestWrapper>();
			Map<Id, User> actors = getActors(classificationRequests);
			Map<Id, Account> accounts = getAccounts(classificationRequests);

			for (EDM_Classification_Request_gne__c classificationRequest : classificationRequests) {
				EDM_Classification_Request_RestUtil.ClassificationRequestWrapper wrp = 
						new EDM_Classification_Request_RestUtil.ClassificationRequestWrapper(
								classificationRequest, 
								actors.get(classificationRequest.EDM_Requestor_gne__c),
								actors.get(classificationRequest.EDM_Reviewer_Formula_gne__c),
								accounts.get(classificationRequest.EDM_Account_gne__c));
				classificationRequestWrappers.add(wrp);
			}
		}

		private Map<Id, User> getActors(List<EDM_Classification_Request_gne__c> classificationRequests) {
			Set<Id> userIds = new Set<Id>();
			for (EDM_Classification_Request_gne__c classificationRequest : classificationRequests) {
				userIds.add(classificationRequest.EDM_Requestor_gne__c);
				userIds.add(classificationRequest.EDM_Reviewer_Formula_gne__c);
			}
			userIds.remove(null);

			return new Map<Id, User>([SELECT Id, Alias, External_Id_gne__c, FederationIdentifier, UserName, FirstName, LastName, Name, Email, Profile.Name, Phone, MobilePhone FROM User WHERE Id in :userIds]);
		}


		private Map<Id, Account> getAccounts(List<EDM_Classification_Request_gne__c> classificationRequests) {
			Set<Id> accountIds = new Set<Id>();
			for (EDM_Classification_Request_gne__c classificationRequest : classificationRequests) {
				accountIds.add(classificationRequest.EDM_Account_gne__c);
			}

			return new Map<Id, Account>(GNE_SFA2_S2S_Util.getAccountRecords(accountIds));
		}
	}
}