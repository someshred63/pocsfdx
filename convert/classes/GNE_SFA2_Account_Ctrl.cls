global with sharing class GNE_SFA2_Account_Ctrl extends GNE_SFA2_Base_Ctrl {
	private transient PfgQtyLimitCtrl pfgQtyLimitCtrl;
	private transient GNE_SFA2_UserPreference_Ctrl hiddenAddressCtrl;
	private transient String currentTeamCode;
	private transient String currentSubTeamCode;
	private transient Set<Id> hiddenAddrIds;
	private transient Boolean territoryAlignmentEnabled;
	private transient Boolean classificationEnabled;
	private transient Boolean exclusionStatusEnabled;
	private transient Boolean accountAttributesEnabled;
	private transient Boolean profilingEnabled;

	public GNE_SFA2_Account_Ctrl(ApexPages.StandardController sctrl) {
		this();
	}

	public GNE_SFA2_Account_Ctrl() {
		super();
	}

	@TestVisible
	protected override Boolean pageDispatcher() {
		Boolean isSbmButNotAbm = getCurrentUser().isSbm() && (getAppContext().appName == 'TLCRM' || getAppContext().appName == 'SFA-US');
		Boolean result = ((super.pageDispatcher() && getCurrentUser().isSfaBrand()) || getCurrentUser().isFrm() || getCurrentUser().isBam() || getCurrentUser().isCCEsbriet() || isSbmButNotAbm || getCurrentUser().isCCCrm() );
		return result;
	}

	@TestVisible
	protected override PageReference getDispatcherOtherPage() {
		PageReference result = null;

		recordId = params.get('id');
		sObjectType = String.isNotBlank(recordId) ? String.valueOf(recordId.getSObjectType()) : null;

		if (appContext.isSfa2Mode) {
			try {
				getRecordAccess(currentUser.id);
			} catch (GNE_SFA2_Base_Ctrl.RecordPermissionErrorException ex) {
				result = new PageReference('/apex/GNE_SFA2_Access_Denied');
				result.setredirect(true);
			}
			if (getCurrentUser().isEMSCanadaUser()) {
				result = Page.EMS_HCP_Layout;
			} else if (result == null) {
				result = mode == GNE_SFA2_Base_Ctrl.VIEW_MODE ? Page.GNE_SFA2_Account_Layout : Page.GNE_SFA2_Account_Edit_Create_Layout;
			}
		} else {
			result = new PageReference('/' + recordId + (mode == GNE_SFA2_Base_Ctrl.EDIT_MODE ? '/e' : ''));
			result.getParameters().put('nooverride', '1');
			result.setredirect(true);
		}

		return result;
	}

	@TestVisible
	protected override GNE_SFA2_Base_Ctrl.DataWrapper intInit(Map<String, String> params) {
		territoryAlignmentEnabled = false;
		classificationEnabled = false;
		exclusionStatusEnabled = false;
		accountAttributesEnabled = false;
		profilingEnabled = false;
		if(isSfaBrandUser == true) {
			activeMenuItem = 'My Customers';
		} else {
			activeMenuItem = 'My Accounts';
		}
		pageExtId = 'account';
		getCurrentUser().isTls();
		GNE_SFA2_Base_Ctrl.DataWrapper result = super.intInit(params);
		return result;
	}

	@TestVisible
	protected override GNE_SFA2_Base_Ctrl.DataWrapper initNewMode() {
		this.params.put('sObjectType', 'Account');
		return super.initNewMode();
	}

	@TestVisible
	protected override GNE_SFA2_Base_Ctrl.DataWrapper initViewMode() {
		DataWrapper result = (DataWrapper)super.initViewMode();

		initViewModeModifyFields(result);

		return result;
	}

	private void initViewModeModifyFields(DataWrapper dw) {
		//hide Date Checked field if necessary
		if (dw != null && dw.exclusionStatusData != null && dw.exclusionStatusData.isNotChecked && !dw.exclusionStatusData.isPendingWithExistingStatus
				&& dw.config != null && dw.config.sections != null) {
			for (GNE_SFA2_Base_Ctrl.Section sec : dw.config.sections) {
				if (sec.label == 'Exclusion Status') {
					for (Field f : sec.fields) {
						if (f.name == 'AGS_EX_Date_Checked_Exclusion_gne__c') {
							f.changeToBlankSpace();
							break;
						}
					}
				}
			}
		}
	}

	protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapperInstance() {
		return new DataWrapper();
	}

	protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapper(GNE_SFA2_Base_Ctrl.DataWrapper dataWrapper) {
		DataWrapper result = (DataWrapper)super.getDataWrapper(dataWrapper);

		if (territoryAlignmentEnabled) {
			result.territories = getTerritories();
			result.territoryAlignmentShowAlignInAllView = getCurrentUser().isSbm() || getCurrentUser().isBAM() || getCurrentUser().isCCCrm() ;
			result.territoryAlignmentShowAlignInAllViewLabel = getCurrentUser().isBAM()  || getCurrentUser().isCCCrm()  ? 'ALIGNED IN MY VIEW' : 'ALIGNED IN MY TERRITORY';
		}

		if (classificationEnabled) {
			result.classificationData = getClassificationData();
		}

		if (exclusionStatusEnabled) {
			result.exclusionStatusData = getExclusionStatusData();
		}

		if (accountAttributesEnabled) {
			result.accountAttributesData = getAccountAttributesData();
		}

		if (profilingEnabled) {
			result.profilingData = getProfilingData();
		}

		result.iconBase64 = getDocumentBase64('Account_Tab_Icon');
		result.canCreateCallBaseOnARA = true;
		result.isConnectedToCorporateNetwork = GNE_SFA2_Util.isUserConnectedToCorporateNetwork();

		result.pactUrl = GNE_SFA2_Util.getPactUrl();
		result.paceUrl = GNE_SFA2_Util.getPaceUrl();

		try{
			if(GNE_SFA2_Util.isPactUser()){
				result.canCreateCallBaseOnARA = Boolean.valueOf(record.get('Art_Account_frm_gne__c'));
			}
		}catch(Exception e){

		}
		return result;
	}

	protected override GNE_SFA2_Base_Ctrl.DataWrapper intSaveRecord() {
		DataWrapper dataWrapper = (DataWrapper)super.intSaveRecord();
		try{
			if(GNE_SFA2_Util.isPactUser()){
				dataWrapper.canCreateCallBaseOnARA = Boolean.valueOf(record.get('Art_Account_frm_gne__c'));
			}
		}catch(Exception e){

		}
		return dataWrapper;
	}

	private String getDocumentBase64(String name) {
		return EncodingUtil.base64Encode([SELECT Body FROM document WHERE DeveloperName = :name LIMIT 1].Body);
	}

	@TestVisible
	protected virtual override Map<String, String> getTranslationsMap() {
		return new Map<String, String> {
				'dcrSubmissionAlert1' => System.Label.GNE_SFA2_DCR_Info_SubmissionAlert1,
				'dcrSubmissionAlert2' => System.Label.GNE_SFA2_DCR_Info_SubmissionAlert2,
				'nominateToBureauError' => System.Label.EDM_Cannot_be_nominated_because_of_exclusion_list,
				'araRequiredAlert' => System.Label.GNE_CRM_FRM_ARA_Required,
				'gconnectRequiredAlert' => System.Label.GNE_CRM_FRM_VPN_Required
		};
	}

	protected override GNE_SFA2_Base_Ctrl.Section getSection(SFA2_Configuration_Object_gne__c conf) {
		GNE_SFA2_Base_Ctrl.Section result = super.getSection(conf);
		classificationEnabled |= result != null && result.label == 'Classification';
		exclusionStatusEnabled |= result != null && result.label == 'Exclusion Status';
		profilingEnabled |= result != null && result.label == 'Profiling';
		return result;
	}

	protected override GNE_SFA2_Base_Ctrl.Field getField(SFA2_Configuration_Object_Detail_gne__c confDetail) {
		GNE_SFA2_Base_Ctrl.Field fld = super.getField(confDetail);

		if (fld.name == 'ParentId' && fld.describe.lookupData != null) {
			fld.describe.lookupData.filter = new GNE_SFA2_Base_Ctrl.CustomLookupFilter('IsPersonAccount = false');
		}

		return fld;
	}

	@TestVisible
	protected override GNE_SFA2_Base_Ctrl.ConfigItem getIncludedPage(SFA2_Configuration_Object_gne__c conf, SFA2_Configuration_Object_Detail_gne__c confDetail,
			List<GNE_SFA2_Base_Ctrl.Section> sections, List<GNE_SFA2_Base_Ctrl.RelatedList> relatedList) {
		GNE_SFA2_Base_Ctrl.ConfigItem result = null;

		if (confDetail.API_Name_gne__c == 'PfgQtyLimit') {
			GNE_SFA2_Base_Ctrl.RelatedList rl = getPfgQtyLimitCtrl().getRelatedList(confDetail);
			relatedList.add(rl);
			result = rl;
		} else {
			territoryAlignmentEnabled |= confDetail.API_Name_gne__c == 'GNE_SFA2_Territory_Alignment_Layout';
			accountAttributesEnabled |= confDetail.API_Name_gne__c == 'GNE_SFA2_Ratings_Layout';
			profilingEnabled |= confDetail.API_Name_gne__c == 'GNE_SFA2_Activase_Questions_Layout';
			result = super.getIncludedPage(conf, confDetail, sections, relatedList);
		}
		return result;
	}

	@TestVisible
	protected override String getRelatedListQuery(GNE_SFA2_Base_Ctrl.RelatedList rl) {
		return rl.name == 'PfgQtyLimit' ? null : super.getRelatedListQuery(rl);
	}

	@TestVisible
	protected override void setRelatedListRecords(GNE_SFA2_Base_Ctrl.RelatedList rl, SObject rec) {
		if (rl.name == 'PfgQtyLimit') {
			rl.addRows(getPfgQtyLimitCtrl().getQtyLimitRows());
		} else {
			super.setRelatedListRecords(rl, rec);
		}
	}

	@TestVisible
	protected override String getRelatedListFilter(GNE_SFA2_Base_Ctrl.RelatedList rl) {
		String result = null;
		if (rl.name == 'Address_vod__c') {
			this.hiddenAddrIds = getHiddenAddressCtrl().getHiddenAddressIds(getCurrentUser().id, recordId);
			if (!this.hiddenAddrIds.isEmpty()) {
				result = 'Id NOT IN :hiddenAddrIds';
			}
		} else if (rl.name == 'MCE_gne__c') {
			Territory2 currTerr = getCurrentTerritory();
			this.currentTeamCode = currTerr != null ? currTerr.Salesforce_Code_gne__c : null;
			this.currentSubTeamCode = currTerr != null ? currTerr.Salesforce_SubTeam_Code_gne__c : null;
			result = 'Team_Code_gne__c = :currentTeamCode AND Subteam_Code_gne__c = :currentSubTeamCode';
		} else if (rl.name == 'Affiliation_vod__c') {
			result = applyAffiliationFilter(super.getRelatedListFilter(rl));
		} else {
			result = super.getRelatedListFilter(rl);
		}
		return result;
	}

	private String applyAffiliationFilter(String filter) {
		if (GNE_Account_Affiliation_Dao.canSetActiveForMyBrand() && String.isNotBlank(GNE_Account_Affiliation_Dao.getMyBrandFieldApiName())) {

			String myBrandFilter = String.format(' {0} = true ', new String[] {
					GNE_Account_Affiliation_Dao.getMyBrandFieldApiName()
			}
			);
			Boolean viewMyBrandsOnly = iPhone_DAO.getAffiliationsUserMode(UserInfo.getUserId()).isEmpty();
			if (viewMyBrandsOnly) {
				if (String.isBlank(filter)) {
					filter = myBrandFilter;
				} else if (!filter.containsIgnoreCase(myBrandFilter)) {
					filter += ' AND ' + myBrandFilter;
				}
			} else {
				if (String.isNotBlank(filter)) {
					String myBrandWithAndFilter = ' AND ' + myBrandFilter;
					if (filter.containsIgnoreCase(myBrandWithAndFilter)) {
						filter = filter.remove(myBrandWithAndFilter);
					} else if (filter.containsIgnoreCase(myBrandFilter)) {
						filter = filter.remove(myBrandFilter);
					}
				}
			}
		}

		if(GNE_SFA2_Util.isPactUser()){
			String condition = '(To_Account_vod__r.IsPersonAccount = true OR To_Account_vod__r.RecordTypeId = \'' + GNE_SFA2_Util.getFrmHcoAccountRecordTypeId() + '\' OR To_Contact_vod__c != null)';
			if(String.isBlank(filter)){
				filter = condition;
			} else {
				filter += ' AND ' + condition;
			}
		}else{
			String condition = '((To_Account_vod__r.RecordTypeId != null AND To_Account_vod__r.RecordTypeId != \'' + GNE_SFA2_Util.getFrmHcoAccountRecordTypeId() + '\') OR To_Contact_vod__c != null)';
			if(String.isBlank(filter)){
				filter = condition;
			} else {
				filter += ' AND ' + condition;
			}
		}
		return filter;
	}

	@TestVisible
	protected override List<SObject> queryRelatedListRecords(String query) {
		Set<Id> hiddenAddrIds = this.hiddenAddrIds;
		String currentTeamCode = this.currentTeamCode;
		String currentSubTeamCode = this.currentSubTeamCode;
		return Database.query(query);
	}

	private List<TerritoryWrapper> getTerritories() {
		List<TerritoryWrapper> result = new List<TerritoryWrapper>();

		List<Territory2> terrs = [
				SELECT Id, Name
				FROM Territory2
				WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId = :getCurrentUser().id)
				ORDER BY Name
		];

		Map<Id, Group> terrGroups = terrs.isEmpty() ? new Map<Id, Group>() : new Map<Id, Group>([
				SELECT Id, RelatedId
				FROM Group
				WHERE RelatedId IN :terrs
				AND Type = 'Territory'
		]);

		for (Id grpId : new Set<Id>(terrGroups.keySet())) {
			terrGroups.put(terrGroups.get(grpId).RelatedId, terrGroups.get(grpId));
		}

		List<AccountShare> aShares = terrGroups.isEmpty() && String.isNotBlank(recordId) ? new List<AccountShare>() : [
				SELECT Id, UserOrGroupId, LastModifiedById, LastModifiedBy.Name
				FROM AccountShare
				WHERE AccountId = :recordId
				AND UserOrGroupId IN :terrGroups.keySet()
				AND RowCause = 'Territory2AssociationManual'
		];

		Map<Id, AccountShare> terrShares = new Map<Id, AccountShare>();
		Map<Id, Territory2> terrsMap = new Map<Id, Territory2>(terrs);

		for (AccountShare aShare : aShares) {
			Territory2 terr = terrsMap.get(terrGroups.get(aShare.UserOrGroupId).RelatedId);
			terrShares.put(terr.Id, aShare);
		}

		Map<String, TSF_vod__c> tsfByTerritoryName = new Map<String, TSF_vod__c>();
		List<String> userTerritoriesNames = new List<String>();
		for (Territory2 terr : terrs) {
			userTerritoriesNames.add(terr.Name);
		}
		for (TSF_vod__c tsf : [
				SELECT Id, Territory_vod__c, My_Target_vod__c, LastModifiedBy.Name, LastModifiedby.Profile.Name
				FROM TSF_vod__c
				WHERE Account_vod__c = :recordId
				AND External_Id_vod__c != null AND Address_vod__c != null
				AND Territory_vod__c IN :userTerritoriesNames]) {
			tsfByTerritoryName.put(tsf.Territory_vod__c, tsf);
		}

		Map<String, Tier_Level_Assignment_gne__c> tierLevelAssignmentMap = new Map<String, Tier_Level_Assignment_gne__c>();
		if (getCurrentUser().isTls()) {
			Set<Id> territoryIds = new Map<Id, Territory2>(terrs).keyset();
			for (Tier_Level_Assignment_gne__c tierLevelAssignment : [
					SELECT Id, TSF_vod__c, Tier_Level_gne__c, Goal_gne__c, Account_gne__c, Territory_Id_gne__c, Territory_Name_gne__c
					FROM Tier_Level_Assignment_gne__c
					WHERE Account_gne__c = :recordId
					AND Territory_Id_gne__c In :territoryIds]) {
				tierLevelAssignmentMap.put(tierLevelAssignment.Territory_Id_gne__c, tierLevelAssignment);
			}
		}

		for (Territory2 terr : terrs) {
			TerritoryWrapper tWrapper = new TerritoryWrapper(getCurrentUser(), terr, terrGroups.get(terr.Id), terrShares.get(terr.Id), tsfByTerritoryName.get(terr.Name), tierLevelAssignmentMap.get(terr.Id));
			result.add(tWrapper);
		}

		return result;
	}

	private ProfilingData getProfilingData() {
		ProfilingData profilingData = new ProfilingData();

		List<Activase_Question_gne__c> questions = getQuestions();
		List<Activase_Answer_gne__c> answers = getAnswers(questions);

		List<ActivaseQuestionWrapper> activaseQuestionsWrappers = new List<ActivaseQuestionWrapper>();
		Map<String, Activase_Answer_gne__c> activaseAnswersByQuestion = new Map<String, Activase_Answer_gne__c>();

		for (Activase_Answer_gne__c answer : answers) {
			if (!activaseAnswersByQuestion.containsKey(answer.Activase_Question_gne__c)) {
				activaseAnswersByQuestion.put(answer.Activase_Question_gne__c, answer);
			}
		}

		for (Activase_Question_gne__c question : questions) {
			ActivaseQuestionWrapper questionWrapper = new ActivaseQuestionWrapper();
			questionWrapper.activaseQuestion = question;
			if (questionWrapper.activaseQuestion.Type_gne__c == 'List of Values') {
				questionWrapper.activaseQuestionAnswers = new List<String>();
				List<String> tmpAnswers = question.Answers_gne__c.split(',');
				for (String tmpAnswer : tmpAnswers) {
					questionWrapper.activaseQuestionAnswers.add(tmpAnswer.trim());
				}
				if (activaseAnswersByQuestion.containsKey(question.Id)) {
					questionWrapper.picklistAnswer = activaseAnswersByQuestion.get(question.Id).Value_gne__c;
				}
			} else if (questionWrapper.activaseQuestion.Type_gne__c == 'Numeric') {
				if (activaseAnswersByQuestion.containsKey(question.Id)) {
					questionWrapper.numericAnswer = activaseAnswersByQuestion.get(question.Id).Value_gne__c;
				}
			}
			activaseQuestionsWrappers.add(questionWrapper);
		}

		for (ActivaseQuestionWrapper wrapper : activaseQuestionsWrappers) {
			if (!activaseAnswersByQuestion.containsKey(wrapper.activaseQuestion.Id)) {
				Activase_Answer_gne__c tmpAnswer = new Activase_Answer_gne__c();
				tmpAnswer.Activase_Question_gne__c = wrapper.activaseQuestion.Id;
				tmpAnswer.Question_Value_gne__c = wrapper.activaseQuestion.Title_gne__c;
				tmpAnswer.Value_gne__c = null;
				tmpAnswer.Account_gne__c = recordId;
				activaseAnswersByQuestion.put(wrapper.activaseQuestion.Id, tmpAnswer);
			}
		}

		if (activaseQuestionsWrappers.size() > 0) {
			profilingData.foundConfig = true;
			profilingData.questions = activaseQuestionsWrappers;
		} else {
			profilingData.foundConfig = false;
		}

		return profilingData;
	}

	private List<Activase_Question_gne__c> getQuestions() {
		List<List<SObject>> questions = [FIND :GNE_SFA2_Util.getCurrentUserProfileName() IN ALL FIELDS RETURNING Activase_Question_gne__c (Id, Answers_gne__c, Profile_gne__c, Title_gne__c, Type_gne__c ORDER BY Id)];
		return questions[0];
	}

	private List<Activase_Answer_gne__c> getAnswers(List<Activase_Question_gne__c> activaseQuestions) {
		return [SELECT Id,
				Account_gne__c,
				Activase_Question_gne__c,
				Question_Value_gne__c,
				Value_gne__c
		FROM Activase_Answer_gne__c
		WHERE Activase_Question_gne__c in :activaseQuestions
		AND Account_gne__c = :recordId];
	}

	private ClassificationData getClassificationData() {
		return new ClassificationData(recordId, isStandardUI);
	}

	private ExclusionStatusData getExclusionStatusData() {
		return new ExclusionStatusData((Account)record);
	}

	private AccountAttributesData getAccountAttributesData() {
		return new AccountAttributesData(getAppContext(), getRecordDescribe());
	}

	@TestVisible
	private GNE_SFA2_UserPreference_Ctrl getHiddenAddressCtrl() {
		if (hiddenAddressCtrl == null) {
			hiddenAddressCtrl = new GNE_SFA2_UserPreference_Ctrl();
		}

		return hiddenAddressCtrl;
	}

	@TestVisible
	private PfgQtyLimitCtrl getPfgQtyLimitCtrl() {
		if (pfgQtyLimitCtrl == null) {
			pfgQtyLimitCtrl = new PfgQtyLimitCtrl(currentUser.id, recordId);
		}

		return pfgQtyLimitCtrl;
	}

	@TestVisible
	private DataWrapper intHideAddress() {
		List<Address_vod__c> addrsToHide = new List<Address_vod__c>();
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		DataWrapper resultData = (DataWrapper)this.dataWrapper;

		Set<String> addrIds = inputData.addressesToHide != null ? inputData.addressesToHide : new Set<String>();

		for (String addrId : addrIds) {
			addrsToHide.add(new Address_vod__c(Id = (Id)addrId, Account_vod__c = inputData.recordDescribe.recordId));
		}

		getHiddenAddressCtrl().hideAddresses(getCurrentUser().id, addrsToHide);
		resultData.addressesToHide = inputData.addressesToHide;
		return resultData;
	}

	private DataWrapper intChangeTerritoryAlignment() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		List<TerritoryWrapper> territories = inputData.territories;

		Set<String> terrNames = new Set<String>();
		Set<Id> groupIds = new Set<Id>();
		Map<String, TSF_vod__c> tsfsMap = new Map<String, TSF_vod__c>();
		Map<Id, AccountShare> aSharesMap = new Map<Id, AccountShare>();
		QueryExecutorWithoutSharing qExecutor = new QueryExecutorWithoutSharing();

		for (TerritoryWrapper tWrapper : territories) {
			terrNames.add(tWrapper.name);
			groupIds.add(tWrapper.groupId);
		}

		List<TSF_vod__c> tsfs = String.isNotBlank(recordId) && !terrNames.isEmpty() ? qExecutor.getTSFs(recordId, terrNames) : new List<TSF_vod__c>();

		for (TSF_vod__c tsf : tsfs) {
			tsfsMap.put(tsf.Territory_vod__c.toUpperCase(), tsf);
		}

		List<AccountShare> aShares = String.isNotBlank(recordId) && !groupIds.isEmpty() ? qExecutor.getAccountShares(recordId, groupIds) : new List<AccountShare>();

		for (AccountShare aShare : aShares) {
			aSharesMap.put(aShare.UserOrGroupId, aShare);
		}


		Map<Id, ObjectTerritory2Association> terrToObjTerrToAss = new Map<Id, ObjectTerritory2Association>();
		if(String.isNotBlank(recordId)) {
			for(ObjectTerritory2Association ot2a : [SELECT Id, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId =: recordId]) {
				terrToObjTerrToAss.put(ot2a.Territory2Id, ot2a);
			}
		}


		List<TSF_vod__c> tsfsToUpsert = new List<TSF_vod__c>();
		List<TSF_vod__c> tsfsToDelete = new List<TSF_vod__c>();
		List<ObjectTerritory2Association> objTerrToAssToInsert = new List<ObjectTerritory2Association>();
		List<ObjectTerritory2Association> objTerrToAssToDelete = new List<ObjectTerritory2Association>();
		List<BaseException> infos = new List<BaseException>();

		for (TerritoryWrapper tWrapper : territories) {
			TSF_vod__c tsf = new TSF_vod__c(Id = tsfsMap.containsKey(tWrapper.name.toUpperCase()) ? tsfsMap.get(tWrapper.name.toUpperCase()).Id : null, Account_vod__c = recordId, Territory_vod__c = tWrapper.name, Is_Self_Alignment_gne__c = true);
			ObjectTerritory2Association objTerrToAss = new ObjectTerritory2Association(Id = terrToObjTerrToAss.containsKey(tWrapper.id) ? terrToObjTerrToAss.get(tWrapper.id).Id : null, Territory2Id = tWrapper.id, ObjectId = recordId, AssociationCause = 'Territory2Manual');

			if (tWrapper.isAlignedInMyView) {
				tsf.My_Target_vod__c = true;
				tsfsToUpsert.add(tsf);

				if (objTerrToAss.Id == null) {
					objTerrToAssToInsert.add(objTerrToAss);
				}

				infos.add(createException(new TerritoryAlignmentMyViewsInfoException(tWrapper.name)));

			} else if (tWrapper.isAlignedInAllView) {
				tsf.My_Target_vod__c = false;
				tsfsToUpsert.add(tsf);

				if (objTerrToAss.Id == null) {
					objTerrToAssToInsert.add(objTerrToAss);
				}

				infos.add(createException(new TerritoryAlignmentAllViewsInfoException(tWrapper.name)));
			} else {
				if (tsf.Id != null) {
					tsfsToDelete.add(tsf);
				}

				if (objTerrToAss.Id != null) {
					objTerrToAssToDelete.add(objTerrToAss);
				}

				infos.add(createException(new TerritoryUnalignmentInfoException(tWrapper.name)));
			}
		}

		GNE_SFA2_Base_Ctrl.DmlExecutorWithoutSharing dmlExecutor = new GNE_SFA2_Base_Ctrl.DmlExecutorWithoutSharing();

		if (!tsfsToUpsert.isEmpty()) {
			executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, tsfsToUpsert, false);
		}

		if (!objTerrToAssToInsert.isEmpty()) {
			executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.INS, objTerrToAssToInsert, false);
		}

		if (!tsfsToDelete.isEmpty()) {
			executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.DEL, tsfsToDelete, false);
		}

		if (!objTerrToAssToDelete.isEmpty()) {
			executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.DEL, objTerrToAssToDelete, false);
		}

		resultData.recordDescribe = inputDataWrapper.recordDescribe;
		resultData.recordDescribe.recordAccess = getRecordAccess(getCurrentUser().id);
		resultData.territories = inputData.territories;

		for (BaseException info : infos) {
			resultData.addInfo(info);
		}

		return resultData;
	}

	private DataWrapper intChangeTierLevelGoal() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;

		TierAndGoalData tierAndGoal = inputData.tierAndGoal;
		String accountId = inputData.recordDescribe.recordId;

		List<Tier_Level_Assignment_gne__c> tlas = [SELECT Id, Tier_Level_gne__c, Goal_gne__c FROM Tier_Level_Assignment_gne__c WHERE Id = :tierAndGoal.tierLevelAssignmentId];
		if (tlas != null && !tlas.isEmpty()) {
			tlas[0].Tier_Level_gne__c = tierAndGoal.tierLevel;
			tlas[0].Goal_gne__c = tierAndGoal.goal;
		} else {
			Territory2 territory = [SELECT Id, Name FROM Territory2 WHERE Id = :tierAndGoal.territoryId];
			tlas.add(new Tier_Level_Assignment_gne__c(
					Tier_Level_gne__c = tierAndGoal.tierLevel,
					Goal_gne__c = tierAndGoal.goal,
					Territory_Id_gne__c = territory.Id,
					Territory_Name_gne__c = territory.Name,
					Account_gne__c = accountId,
					TSF_vod__c = tierAndGoal.tsfId
			));
		}
		upsert tlas;
		resultData.tierAndGoal = tierAndGoal;
		resultData.tierAndGoal.tierLevelAssignmentId = tlas[0].Id;
		return resultData;
	}

	private DataWrapper intUpdateProfilingData() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;

		ActivaseQuestionWrapper answeredQuestion = inputData.profilingData.questions[0];

		List<Activase_Answer_gne__c> existingAnswers = [
				SELECT Id,
						Account_gne__c,
						Activase_Question_gne__c,
						Question_Value_gne__c,
						Value_gne__c
				FROM Activase_Answer_gne__c
				WHERE Activase_Question_gne__c = :answeredQuestion.activaseQuestion.Id
				AND Account_gne__c = :inputData.recordDescribe.recordId];

		Boolean isTypePicklist = answeredQuestion.activaseQuestion.Type_gne__c == 'List of Values';

		if (existingAnswers.size() > 0) {
			existingAnswers[0].Value_gne__c = isTypePicklist ? answeredQuestion.picklistAnswer : answeredQuestion.numericAnswer;
		} else {
			Activase_Answer_gne__c newAnswer = new Activase_Answer_gne__c(
					Account_gne__c = inputData.recordDescribe.recordId,
					Activase_Question_gne__c = answeredQuestion.activaseQuestion.Id,
					Value_gne__c = isTypePicklist ? answeredQuestion.picklistAnswer : answeredQuestion.numericAnswer,
					Question_Value_gne__c = answeredQuestion.activaseQuestion.Title_gne__c
			);
			existingAnswers.add(newAnswer);
		}

		new QueryExecutorWithoutSharing().upsertRecords(existingAnswers);

		resultData.profilingData = new ProfilingData();
		resultData.profilingData.questions = new List<ActivaseQuestionWrapper>();
		resultData.profilingData.questions.add(answeredQuestion);

		return resultData;
	}

	private DataWrapper intExclusionCheckRequest() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		ExclusionStatusData exData = inputData.exclusionStatusData;
		List<GNE_SFA2_Base_Ctrl.BaseException> msgExs = exData.createRequest(inputData.recordDescribe.recordId);

		for (GNE_SFA2_Base_Ctrl.BaseException ex : msgExs) {
			ex = createException(ex);

			if (ex.getType() == GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name()) {
				resultData.addError(ex);
			} else {
				resultData.addInfo(ex);
			}
		}

		resultData.exclusionStatusData = exData;
		return resultData;
	}

	private DataWrapper intRunThreeSixtyDegreeReport() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		resultData.retUrl = GNE_SFA2_ThreeSixtyDegreeController.runThreeSixtyDegreeReport(inputData.recordDescribe.recordId);
		return resultData;
	}

	private DataWrapper intGetAccountTeam() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		List<User> users = GNE_SFA2_MCCO_View_Account_Team.getViewAccountTeam(inputData.recordDescribe.recordId, false);
		resultData.accountTeamData = new AccountTeamData(users);
		resultData.appContext = inputData.appContext;
		return resultData;
	}

	private DataWrapper intChangeAffiliationView() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		Boolean viewAllBrands = inputData.affiliationData.viewAllBrands == true;
		try {
			GroupVisibilityHandler.SetUserViewAllBrands_ws(getCurrentUser().id, viewAllBrands);
		} catch (Exception ex) {
			throw createException(new SwitchAffiliationViewErrorException());
		}

		resultData.config = inputData.config;

		for (GNE_SFA2_Base_Ctrl.RelatedList rl : resultData.config.relatedLists) {
			rl.rows = null;
		}

		prepareRelatedListRecords(resultData.config.relatedLists);
		return resultData;
	}

	private class PfgQtyLimitCtrl {
		private Id userId;
		private Id accountId;

		private PfgQtyLimitCtrl(Id userId, Id accountId) {
			this.userId = userId;
			this.accountId = accountId;
		}

		private GNE_SFA2_Base_Ctrl.RelatedList getRelatedList(SFA2_Configuration_Object_Detail_gne__c confDetail) {
			GNE_SFA2_Base_Ctrl.RelatedList rl = new GNE_SFA2_Base_Ctrl.RelatedList(confDetail, new List<RelatedListField> {
					new RelatedListField('ndc', 'NDC', 'string', false),
					new RelatedListField('product', 'Product Name', 'string', false),
					new RelatedListField('qtylimit', 'Quantity Limits for PFG', 'integer', false),
					new RelatedListField('qtydisbursed', 'YTD Disbursed', 'integer', false)
			});

			rl.sortBy = 'qtydisbursed';
			rl.sortDirection = 'DESC';
			return rl;
		}

		private List<QtyLimitWrapper> getQtyLimitRows() {
			List<QtyLimitWrapper> rows = new List<QtyLimitWrapper>();
			List<Product_vod__c> pfgProducts = getPfgAvailableUserProducts();

			if (!pfgProducts.isEmpty()) {
				String currentYear = GNE_SFA2_PFG_Util.currentYear();
				Map<Id, SFA2_PFG_Product_Limit_gne__c> productLimits = getProductLimits(currentYear, pfgProducts);
				List<Product_vod__c> pfgProductsWithLimits = new List<Product_vod__c>();

				for (Id pfgId : productLimits.keySet()) {
					pfgProductsWithLimits.add(productLimits.get(pfgId).Product_gne__r);
				}

				if (!pfgProductsWithLimits.isEmpty()) {
					Map<Id, PFG_Staging_Account_Limit_Exception_gne__c> hcpLimits = getHcpLimits(currentYear, pfgProductsWithLimits);
					Map<Id, SFA2_PFG_to_Account_Detail_gne__c> hcpDetails = getHcpDetails(currentYear, pfgProductsWithLimits);

					for (Product_vod__c pfgProduct : pfgProductsWithLimits) {
						QtyLimitWrapper row = new QtyLimitWrapper(pfgProduct, productLimits.get(pfgProduct.Id), hcpLimits.get(pfgProduct.Id), hcpDetails.get(pfgProduct.Id));
						rows.add(row);
					}

					rows.sort();
				}
			}

			return rows;
		}

		private List<Product_vod__c> getPfgAvailableUserProducts() {
			List<Product_vod__c> availableProducts = new List<Product_vod__c>();
			Set<String> userBrands = GNE_SFA2_PFG_Util.checkIsUserManager(userId)
					? GNE_SFA2_PFG_Util.getBrandNames()
					: GNE_SFA2_PFG_Util.getBrandNamesByUserTerritory(userId);

			for (String brandName : userBrands) {
				availableProducts.addAll(GNE_SFA2_PFG_Util.getProductsForBrand(brandName));
			}

			return availableProducts;
		}

		private Map<Id, SFA2_PFG_Product_Limit_gne__c> getProductLimits(String limitYear, List<Product_vod__c> pfgProducts) {
			Map<Id, SFA2_PFG_Product_Limit_gne__c> result = new Map<Id, SFA2_PFG_Product_Limit_gne__c>();

			for (SFA2_PFG_Product_Limit_gne__c pLimit : GNE_SFA2_PFG_DAO.getAllPFGProductsLimitsPerYearAndProducts(limitYear, pfgProducts)) {
				result.put(pLimit.Product_gne__c, pLimit);
			}

			return result;
		}

		private Map<Id, PFG_Staging_Account_Limit_Exception_gne__c> getHcpLimits(String limitYear, List<Product_vod__c> pfgProducts) {
			Map<Id, PFG_Staging_Account_Limit_Exception_gne__c> result = new Map<Id, PFG_Staging_Account_Limit_Exception_gne__c>();

			for (PFG_Staging_Account_Limit_Exception_gne__c pLimit : GNE_SFA2_PFG_DAO.getAccountProductsLimitsPerYear(accountId, limitYear, pfgProducts)) {
				result.put(pLimit.Product_gne__c, pLimit);
			}

			return result;
		}

		private Map<Id, SFA2_PFG_to_Account_Detail_gne__c> getHcpDetails(String limitYear, List<Product_vod__c> pfgProducts) {
			Map<Id, SFA2_PFG_to_Account_Detail_gne__c> result = new Map<Id, SFA2_PFG_to_Account_Detail_gne__c>();

			for (SFA2_PFG_to_Account_Detail_gne__c aDetail : GNE_SFA2_PFG_DAO.getPfgToAccountDetailsPerAccountAndLimitYearAndProducts(accountId, limitYear, pfgProducts)) {
				result.put(aDetail.Product_gne__c, aDetail);
			}

			return result;
		}
	}

	private class QtyLimitWrapper extends GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper implements Comparable {
		private transient Integer qtyDisbursed;

		private QtyLimitWrapper(Product_vod__c pfgProduct, SFA2_PFG_Product_Limit_gne__c productLimit,
				PFG_Staging_Account_Limit_Exception_gne__c hcpLimit, SFA2_PFG_to_Account_Detail_gne__c hcpDetail) {

			super(pfgProduct.Id, new Map<String, String> {
					'ndc' => pfgProduct.NDC_Number_gne__c,
					'product' => pfgProduct.Name,
					'qtylimit' => String.valueOf(hcpLimit != null ? hcpLimit.Exception_Quantity_gne__c.intValue() : productLimit.Limit_Quantity_gne__c.intValue()),
					'qtydisbursed' => String.valueOf(hcpDetail != null ? hcpDetail.Qty_Disbursed_gne__c.intValue() : 0)
			});

			qtyDisbursed = Integer.valueOf(values.get('qtydisbursed'));
		}

		public Integer compareTo(Object other) {
			QtyLimitWrapper otherWrapper = (QtyLimitWrapper)other;
			return qtyDisbursed - otherWrapper.qtyDisbursed;
		}
	}

	global class DataWrapper extends GNE_SFA2_Base_Ctrl.DataWrapper {
		protected Set<String> addressesToHide;
		protected List<TerritoryWrapper> territories;
		protected ClassificationData classificationData;
		protected ExclusionStatusData exclusionStatusData;
		protected AccountTeamData accountTeamData;
		protected AffiliationData affiliationData;
		protected ClassifHistoryResult accountClassificationHistoryData;
		protected ExclusionHistoryResult accountExclusionHistoryData;
		protected AccountAttributesData accountAttributesData;
		protected TierAndGoalData tierAndGoal;
		protected ProfilingData profilingData;
		protected String iconBase64;
		protected String pactUrl;
		protected String paceUrl;
		protected Boolean canCreateCallBaseOnARA;
		protected Boolean isConnectedToCorporateNetwork;
		protected Boolean territoryAlignmentShowAlignInAllView;
		protected String territoryAlignmentShowAlignInAllViewLabel;
	}

	private class TerritoryWrapper {
		private String id;
		private String name;
		private String groupId;
		private Boolean isAlignedInMyView;
		private String alignedBy;
		private Boolean hasTsf;
		private Boolean isAlignedInAllView;
		private Boolean isNotAligned;
		private TSF_vod__c tsf;
		private Field tierLevelField;
		private Field goalField;
		private Tier_Level_Assignment_gne__c tierLevelAssignment;


		private TerritoryWrapper(UserWrapper currentUser, Territory2 terr, Group terrGroup, AccountShare aShare, TSF_vod__c tsf, Tier_Level_Assignment_gne__c tierLevelAssignment) {
			this.id = terr.Id;
			this.name = terr.name;
			this.groupId = terrGroup.Id;
			this.tsf = tsf;
			this.hasTsf = (tsf != null);
			this.isAlignedInMyView = aShare != null && hasTsf && tsf.My_Target_vod__c;
			this.alignedBy = aShare != null ? aShare.LastModifiedBy.Name : null;
			this.isNotAligned = (tsf == null);
			this.isAlignedInAllView = aShare != null && hasTsf && !tsf.My_Target_vod__c;

			if (currentUser.isTls()) {
				if (tierLevelAssignment == null) {
					tierLevelAssignment = new Tier_Level_Assignment_gne__c();
				}
				this.tierLevelAssignment = tierLevelAssignment;
				this.tierLevelField = new Field('', tierLevelAssignment.Tier_Level_gne__c, false, false, Tier_Level_Assignment_gne__c.Tier_Level_gne__c.getDescribe(), 'Tier_Level_Assignment_gne__c');
				this.goalField = new Field('', tierLevelAssignment.Goal_gne__c, false, false, Tier_Level_Assignment_gne__c.Goal_gne__c.getDescribe(), 'Tier_Level_Assignment_gne__c');
			}
		}
	}

	private class TierAndGoalData {
		public String tierLevelAssignmentId;
		public String tierLevel;
		public String goal;
		public String territoryId;
		public String tsfId;
	}

	private class ProfilingData {
		public List<ActivaseQuestionWrapper> questions;
		public Boolean foundConfig;
	}

	private class ActivaseQuestionWrapper {
		public Activase_Question_gne__c activaseQuestion { get; set; }
		public List<String> activaseQuestionAnswers { get; set; }
		public String picklistAnswer { get; set; }
		public String numericAnswer { get; set; }
		private List<SelectOption> answerSelectOptions;
	}

	private class ClassificationData {
		private Classification business;
		private Classification clinical;
		private String info;

		private ClassificationData(Id accountId, Boolean isStandardUI) {
			Map<String, EDM_Classification_Request_gne__c> classRequestsByType = EDM_Classification_Utils.getPendingClassificationRequestsByTypes(accountId);
			PageReference pr = isStandardUI ? Page.EDM_Classification_Request_Create_SFDC : Page.EDM_Classification_Request_Edit_Create;
			pr.getParameters().put('accountId', accountId);
			pr.getParameters().put('retUrl', '/' + accountId);
			pr.getParameters().put('typeOfClassification', 'Business');
			this.business = new Classification(pr.getUrl(), classRequestsByType.get('Business'), 'HCPs acting in a non-clinical capacity or non-HCP business leaders (e.g., hospital C-suite, managed care experts, practice managers, etc.)');
			pr.getParameters().put('typeOfClassification', 'Clinical');
			this.clinical = new Classification(pr.getUrl(), classRequestsByType.get('Clinical'), 'HCPs acting in a clinical capacity (e.g., doctors, nurses, pharmacists, etc.)');
			this.info = EDM_Classification_Info_gne__c.getInstance().EDM_Value_gne__c;
		}
	}

	private class Classification {
		private String newRequestUrl;
		private Boolean isPending;
		private String createdDate;
		private String info;

		private Classification(String newRequestUrl, EDM_Classification_Request_gne__c request, String info) {
			this.newRequestUrl = newRequestUrl;
			this.isPending = request != null;
			this.createdDate = request != null ? request.CreatedDate.date().format() : null;
			this.info = info;
		}
	}

	private class ExclusionStatusData {
		private Boolean isNotChecked;
		private Boolean canRequestExclusion;
		private String info;
		private String exStatus;
		private String exDate;
		private String prevExStatus;
		private String prevExDate;
		private Boolean isPendingWithExistingStatus = false;


		private ExclusionStatusData(Account acc) {
			this.isNotChecked = acc.AGS_EX_Exclusion_Status_gne__c == 'Not Checked' || acc.AGS_EX_Exclusion_Status_gne__c == 'Request Pending' || acc.AGS_EX_Exclusion_Status_gne__c == 'In Process';
			this.canRequestExclusion = acc.AGS_EX_Exclusion_Status_gne__c != 'Request Pending' && acc.AGS_EX_Exclusion_Status_gne__c != 'In Process';
			this.info = AGS_EX_Exclusion_Info__c.getInstance().AGS_EX_Value__c;
			this.exStatus = getExclusionStatus(acc);

			AGS_EX_Exclusion_Check_gne__c prevExCheck = getPreviousExclusionStatus(acc);
			if (prevExCheck != null) {
				this.prevExStatus = prevExCheck.AGS_EX_Status_gne__c;
				this.prevExDate = prevExCheck.AGS_EX_Check_Date_gne__c.format();
				if(exStatus.contains('Pending')) {
					isPendingWithExistingStatus = true;
				}
			}
		}

		private String getExclusionStatus(Account acc) {
			String status = acc.AGS_EX_Exclusion_Status_gne__c == 'In Process' ? 'Request Pending' : acc.AGS_EX_Exclusion_Status_gne__c;

			if (status == 'Request Pending') {
				List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [
						SELECT Id, AGS_EX_Account_Name_gne__c, CreatedDate
						FROM AGS_EX_Exclusion_Request_gne__c
						WHERE (AGS_EX_Request_Status_gne__c = 'Pending' OR AGS_EX_Request_Status_gne__c = 'In Progress')
						AND AGS_EX_Account_Name_gne__c = :acc.Id
						LIMIT 1
				];

				if (!existingExclusionRequests.isEmpty()) {
					status = String.format('{0} (Submitted on {1})', new String[] {
							status,
							existingExclusionRequests[0].CreatedDate.date().format()
					});
					this.exDate = existingExclusionRequests[0].CreatedDate.date().format();
				}
			}

			return status;
		}

		private AGS_EX_Exclusion_Check_gne__c getPreviousExclusionStatus(Account acc) {
			AGS_EX_Exclusion_Check_gne__c previousExclusionCheck;
			List<AGS_EX_Exclusion_Request_gne__c> lastExclusionRequests = [
					SELECT Id, AGS_EX_Request_Status_gne__c, (SELECT AGS_EX_Status_gne__c, AGS_EX_Check_Date_gne__c FROM AGS_EX_Exclusion_Checks__r)
					FROM AGS_EX_Exclusion_Request_gne__c
					WHERE AGS_EX_Account_Name_gne__c = :acc.Id
					order by CreatedDate desc
					limit 2
			];
			if (lastExclusionRequests.size() > 1) {
				previousExclusionCheck = lastExclusionRequests[1].AGS_EX_Exclusion_Checks__r[0];
			}

			return previousExclusionCheck;
		}

		private List<GNE_SFA2_Base_Ctrl.BaseException> createRequest(Id accId) {
			List<GNE_SFA2_Base_Ctrl.BaseException> result = new List<GNE_SFA2_Base_Ctrl.BaseException>();
			Account acc = new Account(Id = accId);
			Boolean requestSent = AGS_EX_Exclusion_Utils.createRequest(acc);

			acc = [SELECT AGS_EX_Exclusion_Status_gne__c, AGS_EX_Date_Checked_Exclusion_gne__c FROM Account WHERE Id = :acc.Id LIMIT 1];
			this.exStatus = getExclusionStatus(acc);
			this.exDate = acc.AGS_EX_Date_Checked_Exclusion_gne__c != null ? acc.AGS_EX_Date_Checked_Exclusion_gne__c.format() : null;
			AGS_EX_Exclusion_Check_gne__c prevExclusionCheck = getPreviousExclusionStatus(acc);
			if(prevExclusionCheck != null) {
				this.prevExStatus = prevExclusionCheck.AGS_EX_Status_gne__c;
				this.prevExDate = prevExclusionCheck.AGS_EX_Check_Date_gne__c.format();
				isPendingWithExistingStatus = true;
			}
			this.canRequestExclusion = false;
			if (requestSent == true) {
				result.add(new ExclusionStatusCheckedInfoException());
			} else {
				for (ApexPages.Message msg : ApexPages.getMessages()) {
					if (msg.getSeverity() == ApexPages.Severity.ERROR) {
						result.add(new ExclusionStatusErrorException(msg.getSummary()));
					}
				}
			}

			return result;
		}
	}

	private class AccountTeamData {
		private List<AccountTeamMember> members;

		private AccountTeamData(List<User> users) {
			this.members = new List<AccountTeamMember>();

			for (User usr : users) {
				this.members.add(new AccountTeamMember(usr));
			}
		}
	}

	private class AccountTeamMember {
		private String name;
		private String team;
		private String brand;
		private String role;
		private String email;

		private AccountTeamMember(User usr) {
			this.name = usr.Name;
			this.team = usr.GNE_Team_frm_gne__c;
			this.brand = usr.Brand_Name_gne__c;
			this.role = usr.Business_Role_gne__c;
			this.email = usr.Email;
		}
	}

	private class AffiliationData {
		private Boolean viewAllBrands;
	}

	private without sharing class QueryExecutorWithoutSharing {
		private QueryExecutorWithoutSharing() {}

		private List<TSF_vod__c> getTSFs(Id accountId, Set<String> terrNames) {
			return [
					SELECT Id, Territory_vod__c, My_Target_vod__c, Is_Self_Alignment_gne__c
					FROM TSF_vod__c
					WHERE Account_vod__c = :accountId
					AND Territory_vod__c IN :terrNames
					AND External_Id_vod__c != null
			];
		}

		private List<AccountShare> getAccountShares(Id accountId, Set<Id> groupIds) {
			return [
					SELECT Id, UserOrGroupId
					FROM AccountShare
					WHERE AccountId = :accountId
					AND UserOrGroupId IN :groupIds
			];
		}

		public void upsertRecords(List<sObject> listToUpsert) {
			upsert listToUpsert;
		}
	}

	private static String getAccountsTabName() {
		return GNE_SFA2_Util.isFrmUser() ? 'Accounts' : 'My Accounts';
	}

	private class TerritoryAlignmentMyViewsInfoException extends GNE_SFA2_Base_Ctrl.BaseException {
		protected override void init() {
			type = GNE_SFA2_Base_Ctrl.ErrorTypes.Info.name();
			subType = 'TerritoryAlignmentInfo';
			label = 'Aligned to ' + getMessage() + ' as a target.\nWill now appear in the My... view(s) on the ' + getAccountsTabName() + ' tab.';
		}
	}

	private class TerritoryAlignmentAllViewsInfoException extends GNE_SFA2_Base_Ctrl.BaseException {
		protected override void init() {
			type = GNE_SFA2_Base_Ctrl.ErrorTypes.Info.name();
			subType = 'TerritoryAlignmentInfo';
			label = 'Aligned to ' + getMessage() + ' as a target.\nWill only be visible in the All... view(s) on the ' + getAccountsTabName() + ' tab.';
		}
	}

	private class TerritoryUnalignmentInfoException extends GNE_SFA2_Base_Ctrl.BaseException {
		protected override void init() {
			type = GNE_SFA2_Base_Ctrl.ErrorTypes.Info.name();
			subType = 'TerritoryUnalignmentInfo';
			label = 'Unaligned from ' + getMessage() + '.\nIt will not be in any of the ' + getMessage() + ' views on the ' + getAccountsTabName() + ' tab.';
		}
	}

	private class ExclusionStatusCheckedInfoException extends GNE_SFA2_Base_Ctrl.BaseException {
		protected override void init() {
			type = GNE_SFA2_Base_Ctrl.ErrorTypes.Info.name();
			subType = 'ExclusionStatusCheckedInfo';
			label = 'Your request has been submitted';
		}
	}

	private class ExclusionStatusErrorException extends GNE_SFA2_Base_Ctrl.BaseException {
		protected override void init() {
			type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
			subType = 'ExclusionStatusError';
			label = getMessage();
		}
	}

	private class SwitchAffiliationViewErrorException extends GNE_SFA2_Base_Ctrl.BaseException {
		protected override void init() {
			type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
			subType = 'SwitchAffiliationViewError';
			label = 'Could not change Affiliation View. Please try again later or contact your System Administrator.';
		}
	}


	protected override GNE_SFA2_Base_Ctrl.DataWrapper intPerformRemoteAction(String actionName) {
		GNE_SFA2_Base_Ctrl.DataWrapper result = null;

		if (actionName == 'HideAddress') {
			result = intHideAddress();
		} else if (actionName == 'ChangeTerritoryAlignment') {
			result = intChangeTerritoryAlignment();
		} else if (actionName == 'ExclusionCheckRequest') {
			result = intExclusionCheckRequest();
		} else if (actionName == 'RunThreeSixtyDegreeReport') {
			result = intRunThreeSixtyDegreeReport();
		} else if (actionName == 'GetAccountTeam') {
			result = intGetAccountTeam();
		} else if (actionName == 'ChangeAffiliationView') {
			result = intChangeAffiliationView();
		} else if (actionName == 'GetClassificationHistory') {
			result = intGetClassificationHistory();
		} else if (actionName == 'GetExclusionHistory') {
			result = intGetExclusionHistory();
		} else if (actionName == 'UpdateAccountAttributes') {
			result = intUpdateAccountAttributes();
		} else if (actionName == 'ChangeTierLevelGoal') {
			result = intChangeTierLevelGoal();
		} else if (actionName == 'updateProfiling') {
			result = intUpdateProfilingData();
		} else {
			result = super.intPerformRemoteAction(actionName);
		}

		return result;
	}


	@RemoteAction
	global static DataWrapper saveRecord(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).saveRecord(inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper hideAddress(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('HideAddress', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper changeTerritoryAlignment(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('ChangeTerritoryAlignment', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper changeTierLevelGoal(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('ChangeTierLevelGoal', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper exclusionCheckRequest(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('ExclusionCheckRequest', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper runThreeSixtyDegreeReport(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('RunThreeSixtyDegreeReport', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper getAccountTeam(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('GetAccountTeam', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper changeAffiliationView(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('ChangeAffiliationView', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper getClassificationHistory(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('GetClassificationHistory', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper getExclusionHistory(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('GetExclusionHistory', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper updateAccountAttributes(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('UpdateAccountAttributes', inputDataInJSON, GNE_SFA2_Account_Ctrl.AccountMetricsDataWrapper.class);
	}

	@RemoteAction
	global static DataWrapper updateProfiling(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_Account_Ctrl()).performRemoteAction('updateProfiling', inputDataInJSON, GNE_SFA2_Account_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	public static List<GNE_SFA2_HCPtoFRMHCOMappingEngine.AccountMappingWrapper> getAccountMappingData(Map<String, String> params) {
		if(params.containsKey('hcoId')) {
			return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getAccountMappingWrapper(params.get('hcoId'));
		} else {
			return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getAccountMappingWrapper();
		}
	}

	@RemoteAction
	public static GNE_SFA2_HCPtoFRMHCOMappingEngine.AccountMappingWrapper getNewHCP(Map<String, String> params) {
		return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getNewHCP(params);
	}

	@RemoteAction
	public static GNE_SFA2_HCPtoFRMHCOMappingEngine.FRMHCOWrapper getFRMHCO(Map<String, String> params) {
		return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getFRMHCO(params.get('accId'));
	}

	@RemoteAction
	public static GNE_SFA2_Base_Ctrl.DataWrapper getSBCConfig(Map<String, String> params) {
		return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getSBCConfig();
	}

	@RemoteAction
	public static GNE_SFA2_Base_Ctrl.DataWrapper createAccount(String inputDataWrapperInJSON) {
		return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).insertAccount(inputDataWrapperInJSON);
	}

	@RemoteAction
	public static GNE_SFA2_Base_Ctrl.DataWrapper upsertAccountFromMdm(String inputDataWrapperInJSON) {
		return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).upsertAccount(inputDataWrapperInJSON);
	}

	@RemoteAction
	public static GNE_SFA2_Base_Ctrl.DataWrapper sbcSearchAccounts(String searchDataWrapperInJSON) {
		return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).sbcSearchAccounts(searchDataWrapperInJSON);
	}

	@RemoteAction
	public static GNE_SFA2_Base_Ctrl.DataWrapper searchMore(String searchDataWrapperInJSON) {
		return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).searchMore(searchDataWrapperInJSON);
	}

	@RemoteAction
	public static GNE_SFA2_HCPtoFRMHCOMappingEngine.SaveMappingWrapper saveAccountMapping(Map<String, String> params) {
		return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).createAccountMapping(params);
	}

	public class ClassificationHistory {
		String classification { get; set; }
		String businessRole { get; set; }
		String clDate { get; set; }
		String clTime { get; set; }
		String cvLink { get; set; }
	}

	public class ClassifHistoryResult {
		Boolean showCV { get; set; }
		Map<String, List<ClassificationHistory>> historyItems { get; set; }
	}

	private DataWrapper intGetClassificationHistory() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		resultData.accountClassificationHistoryData = getClassificationHistoryResult(inputData.recordDescribe.recordId);
		resultData.appContext = inputData.appContext;
		return resultData;
	}

	private static ClassifHistoryResult getClassificationHistoryResult(String accountId) {
		List<EDM_Classification_Request_gne__c> classifications = [
				SELECT EDM_Account_gne__c, EDM_Status_gne__c, EDM_Type_of_Classification_gne__c, LastModifiedDate,
						EDM_Business_Classification_gne__c, EDM_Business_Classification_Date_gne__c, EDM_Reviewed_Date_Formula_gne__c,
						EDM_Clinical_Classification_gne__c, EDM_Clinical_Classification_Date_gne__c,
						EDM_CV_Attachment_Link_gne__c, EDM_Action_Taken_gne__c, EDM_Business_Role_gne__c
				FROM EDM_Classification_Request_gne__c
				WHERE EDM_Account_gne__c = :accountId
				AND EDM_Status_gne__c = 'Completed'
				AND EDM_Action_Taken_gne__c != 'Decline to Classify'
				ORDER BY EDM_Reviewed_Date_Formula_gne__c DESC];

		ClassifHistoryResult result = new ClassifHistoryResult();
		result.showCV = GNE_SFA2_Util.getCurrentUserProfileName().toLowerCase() == 'gne-tls-ab-sb-admin';
		result.historyItems = getClassificationHistoryMap(classifications);
		return result;
	}

	private static Map<String, List<ClassificationHistory>> getClassificationHistoryMap(List<EDM_Classification_Request_gne__c> classifications) {

		Map<String, List<ClassificationHistory>> result = new Map<String, List<ClassificationHistory>>();
		result.put('Business', new List<ClassificationHistory>());
		result.put('Clinical', new List<ClassificationHistory>());

		for (EDM_Classification_Request_gne__c item : classifications) {
			String type = item.EDM_Type_of_Classification_gne__c;

			ClassificationHistory historyItem = new ClassificationHistory();
			historyItem.clDate = getFormattedDateOrTime(item.EDM_Reviewed_Date_Formula_gne__c,true);
			historyItem.clTime = getFormattedDateOrTime(item.EDM_Reviewed_Date_Formula_gne__c,false);
			historyItem.cvLink = item.EDM_CV_Attachment_Link_gne__c;
			historyItem.classification = item.EDM_Action_Taken_gne__c;
			if (type == 'Business') {
				historyItem.businessRole = item.EDM_Business_Role_gne__c;
			}

			if (result.containsKey(type)) {
				result.get(type).add(historyItem);
			}
		}
		return result;
	}

	public class ExclusionHistory {
		String exclusion { get; set; }
		String exDate { get; set; }
	}

	public class ExclusionHistoryResult {
		List<ExclusionHistory> historyItems { get; set; }
	}

	private DataWrapper intGetExclusionHistory() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		resultData.accountExclusionHistoryData = getExclusionHistoryResult(inputData.recordDescribe.recordId);
		resultData.appContext = inputData.appContext;
		return resultData;
	}

	private static ExclusionHistoryResult getExclusionHistoryResult(String accountId) {
		List<AGS_EX_Exclusion_Check_gne__c> exclusions = [
				SELECT AGS_EX_Status_gne__c, AGS_EX_Check_Date_gne__c, AGS_EX_Account_Name_gne__c
				FROM AGS_EX_Exclusion_Check_gne__c
				WHERE AGS_EX_Exclusion_Request_gne__r.AGS_EX_Account_Name_gne__c =:accountId
				ORDER BY AGS_EX_Check_Date_gne__c desc];

		ExclusionHistoryResult result = new ExclusionHistoryResult();
		result.historyItems = getExclusionHistoryMap(exclusions);
		return result;
	}

	private static List<ExclusionHistory> getExclusionHistoryMap(List<AGS_EX_Exclusion_Check_gne__c> exclusions) {
		List<ExclusionHistory> result = new List<ExclusionHistory>();

		for (AGS_EX_Exclusion_Check_gne__c item : exclusions) {
			ExclusionHistory historyItem = new ExclusionHistory();
			historyItem.exDate = getFormattedDateOrTime(item.AGS_EX_Check_Date_gne__c,true);
			historyItem.exclusion = item.AGS_EX_Status_gne__c;

			result.add(historyItem);

		}
		return result;
	}

	private static String getFormattedDateOrTime(DateTime toFormat,Boolean isDate){
		String formatedDate = String.valueOfGmt(toFormat);
		List<String> dateParts = formatedDate.split(' ');
		if(isDate) {
			return dateParts[0];
		}
		return dateParts[1];
	}

	private static String getFormattedTime(Datetime toFormat) {
		String formatedDT = toFormat.format('MM/dd/yyyy hh:mm:ss a');
		List<String> dateTimeParts = formatedDT.split(' ');
		if (dateTimeParts.size() == 3) {
			return dateTimeParts[1] + ' ' + dateTimeParts[2];
		}
		return String.valueOf(toFormat.time());
	}

	private class AccountAttributesData {
		private Boolean foundConfig { get; set; }
		private Boolean showMore { get; set; }
		private List<ProductMetricsHeader> productHeaders { get; set; }
		private List<ProductMetricsRow> productMetricsRows { get; set; }

		public AccountAttributesData(AppContext appContext, RecordDescribe recDescribe) {
			this.foundConfig = false;
			this.showMore = false;
			List<String> orderedColumnList = retrieveColumnsFromConfig(appContext, recDescribe);
			if (this.foundConfig) {
				this.productHeaders = populateProductHeaders(orderedColumnList);
				this.productMetricsRows = populateProductMetricsRows(appContext, recDescribe);
			}
		}

		private List<String> retrieveColumnsFromConfig(AppContext appContext, RecordDescribe recDescribe) {
			List<String> result = new List<String>();

			List<GNE_SFA2_Ratings_Configuration__c> ratingConfig = [SELECT Columns_List_gne__c
			FROM GNE_SFA2_Ratings_Configuration__c
			WHERE Role_gne__c = :appContext.role
			AND Brand_gne__c = :appContext.brand
			AND Application_Type_gne__c = :appContext.appName
			AND Record_Type_gne__c = :recDescribe.recordType.DeveloperName
			LIMIT 1];
			if (ratingConfig.size() > 0 && String.isNotBlank(ratingConfig[0].Columns_List_gne__c)) {
				result.addAll(ratingConfig[0].Columns_List_gne__c.split(','));
				foundConfig = true;
			}
			return result;
		}

		private List<ProductMetricsHeader> populateProductHeaders(List<String> columnList) {
			List<ProductMetricsHeader> result = new List<ProductMetricsHeader>();
			result.add(new ProductMetricsHeader('Product Name', 'Products_vod__r.Name'));
			Map<String, Schema.SObjectField> productMetricsFieldMap = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap();

			for (String fieldName : columnList) {
				result.add(new ProductMetricsHeader(productMetricsFieldMap.get(fieldName).getDescribe().getLabel(), fieldName));
			}

			return result;
		}

		private List<ProductMetricsRow> populateProductMetricsRows(AppContext appContext, RecordDescribe recDescribe) {
			Map<Id, Product_Metrics_vod__c> productMetricsMapByProduct = retrieveProductMetricsMap(recDescribe);
			List<Product_vod__c> userProductsToDisplay = getMax10UserProductsSorted(productMetricsMapByProduct, recDescribe);
			Map<String, Map<String, Boolean>> readOnlyModeMatrixMap = getReadOnlyModeMatrixMap(appContext, recDescribe, userProductsToDisplay);
			Map<String, Schema.DescribeFieldResult> sObjectFieldsDescribe = GNE_SFA2_Util.getFieldDescribeMap('Product_Metrics_vod__c');

			List<ProductMetricsRow> result = new List<ProductMetricsRow>();
			for (Product_vod__c product : userProductsToDisplay) {
				result.add(new ProductMetricsRow(product, productMetricsMapByProduct.get(product.Id), readOnlyModeMatrixMap.get(product.Id), productHeaders, sObjectFieldsDescribe));
			}
			return result;
		}

		private Map<Id, Product_Metrics_vod__c> retrieveProductMetricsMap(RecordDescribe recDescribe) {
			List<String> queryColumns = new List<String> { 'Id', 'Products_vod__c' };
			for (ProductMetricsHeader header : productHeaders) {
				queryColumns.add(header.fieldName);
			}

			Id accountId = recDescribe.recordId;

			String columns = String.join(queryColumns, ',');
			List<String> queryParams = new List<String> { columns, ':accountId' };
			String query = String.format('SELECT {0} FROM Product_Metrics_vod__c WHERE Account_vod__c = {1}', queryParams);
			List<Product_Metrics_vod__c> retrievedProductMetrics = Database.query(query);

			Map<Id, Product_Metrics_vod__c> result = new Map<Id, Product_Metrics_vod__c>();
			for (Product_Metrics_vod__c pm : retrievedProductMetrics) {
				result.put(pm.Products_vod__c, pm);
			}
			return result;
		}

		private List<Product_vod__c> getMax10UserProductsSorted(Map<Id, Product_Metrics_vod__c> productMetricsMapByProduct, RecordDescribe recDescribe) {
			Map<Id, Product_vod__c> userSetupProductsMap = new Map<Id, Product_vod__c>();

			for (Product_vod__c product : [SELECT Id, Name FROM Product_vod__c WHERE Id IN (SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = : UserInfo.getUserId())]) {
				userSetupProductsMap.put(product.Id, product);
				if (!productMetricsMapByProduct.containsKey(product.Id)) {
					Product_Metrics_vod__c pm = new Product_Metrics_vod__c();
					pm.Products_vod__c = product.Id;
					pm.Account_vod__c = recDescribe.recordId;
					productMetricsMapByProduct.put(pm.Products_vod__c, pm);
				}
			}

			List<Product_vod__c> tempList = userSetupProductsMap.values().clone();
			GNE_SFA2_Util.sortList(tempList, 'Name', true);

			List<Product_vod__c> accountViewProductsList = new List<Product_vod__c>();
			if (tempList.size() > 10) {
				this.showMore = true;
				for (Integer i = 0; i < 10; i++) {
					accountViewProductsList.add(tempList.get(i));
				}
			}

			if (!accountViewProductsList.isEmpty()) {
				tempList = accountViewProductsList;
			}

			return tempList;
		}

		private Map<String, Map<String, Boolean>> getReadOnlyModeMatrixMap(AppContext appContext, RecordDescribe recDescribe, List<Product_vod__c> userProductsToDisplay) {
			Map<String, Map<String, Boolean>> result = new Map<String, Map<String, Boolean>>();

			Map<String, String> readOnlyModeMapFROMConfig = retrieveReadOnlyProductsMapFromConfig(appContext, recDescribe);

			for (Product_vod__c product : userProductsToDisplay) {
				Map<String, Boolean> readOnlyModeMap = new Map<String, Boolean>();
				for (ProductMetricsHeader header : productHeaders) {
					String column = header.fieldName;
					if (readOnlyModeMapFROMConfig.containsKey(column) && column != 'Products_vod__r.Name') {
						String productList = readOnlyModeMapFROMConfig.get(column);
						readOnlyModeMap.put(column, productList.contains(product.Id));
					} else {
						readOnlyModeMap.put(column, false);
					}
				}
				result.put(product.Id, readOnlyModeMap);
			}

			return result;
		}

		private Map<String, String> retrieveReadOnlyProductsMapFromConfig(AppContext appContext, RecordDescribe recDescribe) {
			List<GNE_SFA2_Ratings_Column_Setup__c> readOnlyProductList = [
					SELECT Column_Name_gne__c, Readonly_Products_List_gne__c
					FROM GNE_SFA2_Ratings_Column_Setup__c
					WHERE Role_gne__c = :appContext.role
					AND Brand_gne__c = :appContext.brand
					AND Application_Type_gne__c = :appContext.appName
					AND Record_Type_gne__c = :recDescribe.recordType.DeveloperName];
			Map<String, String> readOnlyProductsMap = new Map<String, String>();
			for (GNE_SFA2_Ratings_Column_Setup__c rcs : readOnlyProductList) {
				readOnlyProductsMap.put(rcs.Column_Name_gne__c, rcs.Readonly_Products_List_gne__c);
			}
			return readOnlyProductsMap;
		}
	}

	private class ProductMetricsHeader {
		public String label { get; set; }
		public String fieldName { get; set; }

		public ProductMetricsHeader(String label, String fieldName) {
			this.label = label;
			this.fieldName = fieldName;
		}
	}

	private class ProductMetricsRow {
		private Product_vod__c product { get; set; }
		private Product_Metrics_vod__c productMetric { get; set; }
		private List<Field> fields { get; set; }

		public ProductMetricsRow(Product_vod__c product, Product_Metrics_vod__c productMetric, Map<String, Boolean> readOnlyMode, List<ProductMetricsHeader> headers, Map<String, Schema.DescribeFieldResult> sObjectFieldsDescribe) {
			this.product = product;
			this.productMetric = productMetric;
			fields = new List<Field>();
			for (ProductMetricsHeader header : headers) {
				String fieldName = header.fieldName;
				if (fieldName != 'Products_vod__r.Name') {
					Boolean isReadOnly = readOnlyMode.get(fieldName) || !sObjectFieldsDescribe.get(fieldName.toLowerCase()).isUpdateable();
					fields.add(getField(fieldName, productMetric.get(fieldName), isReadOnly, sObjectFieldsDescribe));
				}
			}
		}

		private Field getField(String fieldName, Object value, Boolean isReadOnly, Map<String, Schema.DescribeFieldResult> sObjectFieldsDescribe) {
			Schema.DescribeFieldResult fieldDescribe = sObjectFieldsDescribe.get(fieldName.toLowerCase());
			Field fld = new Field('', value, isReadOnly, false, fieldDescribe, 'Product_Metrics_vod__c');
			return fld;
		}
	}

	public class AccountMetricsDataWrapper extends GNE_SFA2_Base_Ctrl.DataWrapper {
		List<Product_Metrics_vod__c> productMetrics;
	}

	private DataWrapper intUpdateAccountAttributes() {
		DataWrapper resultData = (DataWrapper)this.dataWrapper;
		AccountMetricsDataWrapper inputData = (AccountMetricsDataWrapper)this.inputDataWrapper;

		new QueryExecutorWithoutSharing().upsertRecords(inputData.productMetrics);

		return resultData;
	}

	// USPS Address Validation Logic

	@RemoteAction
	global static String addressValidate(Map<String, String> params) {
		return GNE_SFA2_USPSEngine.addressValidate(params);
	}

	@RemoteAction
	global static String cityStateLookup(Map<String, String> params) {
		return GNE_SFA2_USPSEngine.cityStateLookup(params);
	}

	@RemoteAction
	global static String zipCodeLookup(Map<String, String> params) {
		return GNE_SFA2_USPSEngine.zipCodeLookup(params);
	}
}