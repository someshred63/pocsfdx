public without sharing class GNE_AP_Util{

	public static final String AP_NEW_STATUS = 'CSNeedToSubmitInitialAP';
	public static final String AP_RESUBMIT_STATUS = 'CSToResubmitInitialAPAfterDMReject';
	public static final String AP_COMPLETED_STATUS = 'DMAccountPlanIsCompleted';
	public static final String AP_APPROVED_STATUS = 'DMNeedToApproveInitialAP';
	public static final String AP_APPROVED_RESUBMITED_STATUS = 'DMNeedToApproveResubmittedAP';
	public static final String AP_ARCHIVED_STATUS = 'AccountPlanIsArchive';

	public static final String AP_INTERNAL_ACCOUNT_PREFIX = GNE_FCR_Util.FCR_INTERNAL_ACCOUNT_PREFIX;

	public static final String AP_IN_PROGRESS = 'In Progress';
	public static final String AP_SUBMITTED = 'Submitted';
	public static final String AP_RETURNED = 'Returned';
	public static final String AP_APPROVED = 'Approved';
	public static final String AP_ARCHIVED = 'Archived';

	public static final Pattern SFA_PROFILE_PATTERN = Pattern.compile('GNE-SFA.*');

	private static Id apCompliancePermissionSetId;

	private static Map<Id, Boolean> usersToBioOncProfilesMap;

	private static Map<Id, String> userToSalesforceCode;

	public static void setAccountPlanActionAndStatus(AP_Account_Planning_gne__c accountPlan, String statusKey){
		GNE_AP_Status_Key__c accountPlanKey = GNE_AP_Status_Key__c.getValues(statusKey);
		if (accountPlanKey != null){
			accountPlan.Display_Status_gne__c = accountPlanKey.Display_Status_gne__c;
			accountPlan.Action_gne__c = accountPlanKey.Action_gne__c;
			accountPlan.Status_gne__c = accountPlanKey.Status_gne__c;
		}else{
			accountPlan.Display_Status_gne__c = statusKey;
			accountPlan.Action_gne__c = statusKey;
			accountPlan.Status_gne__c = statusKey;
		}
	}

	public static String getNewAccountPlanName(){
		String franchiseName = GNE_AP_Util.getFranchiseName(UserInfo.getUserId());
		String strConvertedDate = GNE_AP_Util.getLocalDate(System.now());
		return UserInfo.getLastName() + ','+UserInfo.getFirstName() + '-'+franchiseName + '-' + strConvertedDate;
	}

	public static void shareAccountPlanToTerritory(Id accountPlanId, String territoryId){
		Id terrToGroup = GNE_SFA2_Util.getTerritoryGroup(territoryId);
		if(terrToGroup == null) {
			AP_Account_Planning_gne__Share apShare = new AP_Account_Planning_gne__Share();
			apShare.ParentId = accountPlanId;
			apShare.AccessLevel = 'Read';
			apShare.RowCause = Schema.AP_Account_Planning_gne__Share.RowCause.Territory_Sharing_gne__c;
			apShare.UserOrGroupId = terrToGroup;
			insert apShare;
		}
	}

	public static void removeAccountPlanSharing(Id accountPlanId){
		List<AP_Account_Planning_gne__Share>sharingList = [SELECT id FROM AP_Account_Planning_gne__Share WHERE ParentId =:accountPlanId AND RowCause = :Schema.AP_Account_Planning_gne__Share.RowCause.Manual];
		if(!sharingList.isEmpty()){
			delete sharingList;
		}
	}
	/*Remove sharing to territory and to FM user */
	public static void removeAccountPlanSharing(Set<Id> accountPlanIds){
		delete [SELECT id FROM AP_Account_Planning_gne__Share WHERE ParentId IN :accountPlanIds AND ((RowCause = :Schema.AP_Account_Planning_gne__Share.RowCause.Manual AND AccessLevel='Edit') OR RowCause = :Schema.AP_Account_Planning_gne__Share.RowCause.Territory_Sharing_gne__c)];
	}

	public static AP_Account_Planning_gne__c createNewAccountPlan(){
		AP_Account_Planning_gne__c newPlan = new AP_Account_Planning_gne__c();
		newPlan.CS_User_gne__c = UserInfo.getUserId();
		newPlan.DM_User_gne__c = GNE_AP_DAO.getUserManagerId(UserInfo.getUserId());
		GNE_AP_Util.setAccountPlanActionAndStatus(newPlan, GNE_AP_Util.AP_NEW_STATUS);
		newPlan.Name = GNE_AP_Util.getNewAccountPlanName();
		return newPlan;
	}

	public static String getLocalDateTime(DateTime dateinput){
		List<User> userZone = [SELECT timezonesidkey FROM user WHERE id=:UserInfo.getUserId()];
		String strConvertedDate = '';
		if (userZone.size() > 0){
			strConvertedDate = dateinput.format('MM/dd/yyyy HH:mm:ss', userZone.get(0).timezonesidkey);
		}
		return strConvertedDate;
	}

	public static String getLocalDate(DateTime dateinput){
		List<User> userZone = [SELECT timezonesidkey FROM user WHERE id=:UserInfo.getUserId()];
		String strConvertedDate = '';
		if (userZone.size() > 0){
			strConvertedDate = dateinput.format('MM/dd/yyyy', userZone.get(0).timezonesidkey);
		}
		return strConvertedDate;
	}

	public static List<Franchise_Goal_gne__c> getFranchiseGoal(Id franchiseId){
		return [SELECT Name, Objective_gne__c, Goal_gne__c, Message_gne__c
		FROM Franchise_Goal_gne__c WHERE Franchise_gne__c = :franchiseId ORDER BY LastModifiedDate DESC LIMIT 1];
	}

	public static List<AP_ResourceRequest_gne__c> getResourceRequest(Id franchiseId){
		return [SELECT Name	FROM AP_ResourceRequest_gne__c WHERE Franchise_gne__c=:franchiseId ORDER BY LastModifiedDate DESC];
	}

	public static List<SFA2_User_Sales_Roster_gne__c> getFranchiseId(Id userId){
		return [SELECT Sales_Roster_gne__r.Franchise__r.Id, Sales_Roster_gne__r.Franchise__r.Name
		FROM SFA2_User_Sales_Roster_gne__c
		WHERE User_gne__c=:userId AND Is_Active_gne__c = true AND Sales_Roster_gne__r.Runs_in_SFA2_Mode_gne__c = true AND Sales_Roster_gne__r.Franchise__c != null];
	}

	public static String getFranchiseIdFromTerritoryMapping(Id userId){
		String brandName = null;
		String franchiseId = null;
		String salesforceCode = getCurrentTerritorySalesforceCode(userId);
		GNE_SFA2_Territory_Record_Type_mapping__c terrToRTmapping = GNE_SFA2_Territory_Record_Type_mapping__c.getInstance(salesforceCode);
        if(terrToRTmapping != null){
            brandName = terrToRTmapping.Brand_gne__c;
        }
        if(String.isNotBlank(brandName)){
        	for(IC_Calc_Sales_Roster_gne__c icCalc :[SELECT Franchise__c FROM IC_Calc_Sales_Roster_gne__c WHERE Type_gne__c = 'SFA-US' AND Brand_Name_gne__c = :brandName AND Franchise__c != null]){
        		franchiseId = icCalc.Franchise__c;
        	}

        }
        return franchiseId;
	}

	public static String getFranchiseNameFromTerritoryMapping(Id userId){
		String brandName = null;
		String franchiseName = '';
		String salesforceCode = getCurrentTerritorySalesforceCode(userId);
		GNE_SFA2_Territory_Record_Type_mapping__c terrToRTmapping = GNE_SFA2_Territory_Record_Type_mapping__c.getInstance(salesforceCode);
        if(terrToRTmapping != null){
            brandName = terrToRTmapping.Brand_gne__c;
        }
        if(String.isNotBlank(brandName)){
        	for(IC_Calc_Sales_Roster_gne__c icCalc :[SELECT Franchise__r.Name FROM IC_Calc_Sales_Roster_gne__c WHERE Type_gne__c = 'SFA-US' AND Brand_Name_gne__c = :brandName AND Franchise__c != null]){
        		franchiseName = icCalc.Franchise__r.Name;
        	}

        }
        return franchiseName;
	}

	public static String getCurrentTerritorySalesforceCode(){
		return getCurrentTerritorySalesforceCode(UserInfo.getUserId());
	}

	public static String getCurrentTerritorySalesforceCode(Id userId){
		if(userToSalesforceCode == null){
			userToSalesforceCode = new Map<Id, String>();
		} else if(userToSalesforceCode.get(userId) != null){
			return userToSalesforceCode.get(userId);
		}

        Id currentTerritoryId = null;
        String salesforceCode = null;

        List<Territory2> userTerritories = GNE_SFA2_Util.getUserTerritories(userId);
        Map<Id, Territory2> userTerritoriesMap = new Map<Id, Territory2>(userTerritories);

        List<SFA2_User_Preferences_gne__c> userPreferences = [
          SELECT Last_Territory_Used_gne__c
          FROM  SFA2_User_Preferences_gne__c
          WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts'
            AND OwnerId = :userId
            AND Last_Territory_Used_gne__c IN :userTerritoriesMap.keySet()
          LIMIT 1
        ];

        if (!userPreferences.isEmpty()) {
            currentTerritoryId = (Id)userPreferences[0].Last_Territory_Used_gne__c;
        } else if (!userTerritories.isEmpty()) {
            currentTerritoryId = userTerritories[0].Id;
        }

        if (currentTerritoryId != null) {
            salesforceCode = userTerritoriesMap.get(currentTerritoryId).Salesforce_Code_gne__c;
        } else {
        	salesforceCode = '';
        }
        userToSalesforceCode.put(userId, salesforceCode);
        return salesforceCode;
	}

	/*Return franchise name, if franchise not exists return empty string.*/
	public static String getFranchiseName(Id userId){
		List<SFA2_User_Sales_Roster_gne__c> franchise = GNE_AP_Util.getFranchiseId(userId);
		String franchiseName = '';
		if(franchise.size() > 0){
			franchiseName = franchise.get(0).Sales_Roster_gne__r.Franchise__r.Name;
		} else {
			franchiseName = GNE_AP_Util.getFranchiseNameFromTerritoryMapping(userId);
		}
		return franchiseName;
	}

	public static Boolean getIsReadOnly(){
		Boolean readOnly = false;
		if(!isFE()){
			readOnly = true;
		}else{
			String accountPlanId = ApexPages.currentPage().getParameters().get('planId');
			if(String.isNotEmpty(accountPlanId)){
				AP_Account_Planning_gne__c accPlan = [SELECT Id, CS_User_gne__c, Status_gne__c FROM AP_Account_Planning_gne__c WHERE id= :accountPlanId];
				if(UserInfo.getUserId() != accPlan.CS_User_gne__c || accPlan.Status_gne__c == GNE_AP_Util.AP_ARCHIVED || accPlan.Status_gne__c == GNE_AP_Util.AP_SUBMITTED){
					readOnly = true;
				}
			}else{
				List<AP_Account_Planning_gne__c> accPlans = [SELECT Id FROM AP_Account_Planning_gne__c WHERE CS_User_gne__c=:Userinfo.getUserId() AND Status_gne__c NOT IN (:GNE_AP_Util.AP_ARCHIVED, :GNE_AP_Util.AP_SUBMITTED) LIMIT 1];
				if(accPlans.size() == 0){
					readOnly = true;
				}
			}
		}
		return readOnly;
	}

	public static String getCSName(Id userId){
		User user = [SELECT LastName, FirstName FROM User WHERE Id = :userId];
		return ' - ' + user.FirstName + ' ' + user.LastName;
	}

	public static Boolean isFE(){
		return GNE_FCR_Util.getIsFE();
	}

	public static Boolean isFM(){
		String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
		return !isFE() && SFA_PROFILE_PATTERN.matcher(profileName).matches();
	}

	public static Boolean getIsDataViewerAdmin(){
		Id permissionSetId = getApCompliancePermissionSetId();
		List<PermissionSetAssignment> assigment = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSetId AND AssigneeId = :UserInfo.getUserId()];
		return assigment.size() > 0;
	}

	public static Boolean getIsBioOncUser(Id userId){
		Boolean result = false;
		if (usersToBioOncProfilesMap == null){
			usersToBioOncProfilesMap = new Map<Id, Boolean>();
		}
		if (!usersToBioOncProfilesMap.containsKey(userId)){
			String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
			for (String configProfileName : GNE_SFA2_BioOnc_Profiles_Prefixes__c.getAll().keyset()){
				if (profileName.startsWithIgnoreCase(configProfileName)){
					result = true;
					break;
				}
			}
			usersToBioOncProfilesMap.put(userId, result);
		}
		return usersToBioOncProfilesMap.get(userId);
	}

	private static Id getApCompliancePermissionSetId(){
		if(apCompliancePermissionSetId==null){
			apCompliancePermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'SFA_AP_Compliance'].Id;
		}
		return apCompliancePermissionSetId;
	}

	public static PageReference redirectToErrorPage(String errorMessage, String currentURL, String developerMessage, Integer lineNumber) {
		PageReference pageref = Page.GNE_AP_Error;
		pageref.setredirect(true);
		pageref.getParameters().put('exMessage', errorMessage);
		pageref.getParameters().put('exUrl', currentURL);
		pageref.getParameters().put('developerMessage', developerMessage);
		pageref.getParameters().put('lineNumber', String.valueOf(lineNumber));
		return pageref;
	}

	public static PageReference redirectToErrorPage(String errorMessage, String currentURL, String developerMessage) {
		return redirectToErrorPage(errorMessage, currentURL, developerMessage, null);
	}

	public static String getCustomLabel(String key, String team, String subTeam){
		List<AP_Custom_Label_gne__c>labels = [SELECT Key_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Value_gne__c FROM AP_Custom_Label_gne__c WHERE Key_gne__c = :key];
		Boolean founded = false;
		String result = key;
		for(AP_Custom_Label_gne__c label: labels){
			if(label.Salesforce_Code_gne__c == team && label.Salesforce_SubTeam_Code_gne__c == subTeam){
				result = label.Value_gne__c;
				break;
			}
			if(label.Salesforce_Code_gne__c == team){
				result = label.Value_gne__c;
				founded = true;
			}
			if(!founded){
				result = label.Value_gne__c;
			}
		}
		return result;
	}

	public static Map<String, String> getCustomLabel(List<String> keys, String team, String subTeam){
		List<AP_Custom_Label_gne__c>labels = [SELECT Key_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Value_gne__c FROM AP_Custom_Label_gne__c WHERE Key_gne__c IN :keys];
		system.debug(labels);
		Map<String, String>results = new Map<String, String>();

		for(String key: keys){
			Boolean founded = false;
			String result = key;
			for(AP_Custom_Label_gne__c label: labels){
				if(label.Key_gne__c == key && label.Salesforce_Code_gne__c == team && label.Salesforce_SubTeam_Code_gne__c == subTeam){
					result = label.Value_gne__c;
					founded = true;
				}
				if(!founded && label.Key_gne__c == key && label.Salesforce_Code_gne__c == team && label.Salesforce_SubTeam_Code_gne__c == null){
					result = label.Value_gne__c;
					founded = true;
				}
				if(!founded && label.Key_gne__c == key && label.Salesforce_Code_gne__c == null && label.Salesforce_SubTeam_Code_gne__c == null){
					result = label.Value_gne__c;
					founded = true;
				}
			}
			if(founded){
				results.put(key, result);
			}
		}
		return results;
	}

	/*Return user territories sorted by  LastModifiedDate */
	public static List<Territory2>getUserTerritories(String userId){
		List<Id>territoriesIds =  new List<Id>();
		List<Territory2>result = new List<Territory2>();
		for(UserTerritory2Association ut : [SELECT Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND userid =:userId ORDER BY LastModifiedDate ASC]){
			territoriesIds.add(ut.Territory2Id);
		}
		if(territoriesIds.size() > 0){
			Map<Id, Territory2>territories = new Map<Id, Territory2>([SELECT Id, Name, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c FROM Territory2 WHERE id IN : territoriesIds]);
			for(Id terrId: territoriesIds){
				result.add(territories.get(terrId));
			}
		}
		return result;
	}

	public static void savePerformanceData(AP_Account_Planning_gne__c apPlan){
		try{
			if(GNE_FCR_Util.isSupportedBySLDx(apPlan.CS_User_gne__c) && String.isNotEmpty(apPlan.Territory_Number_gne__c)){
				MetricsRequest request = new MetricsRequest(apPlan.Territory_Number_gne__c);

				Map<String, Id>accountOrgIdToId = new Map<String, String>();

				for(AP_Detail_gne__c detail : [SELECT AP_Account_gne__r.OrgId_gne__c, AP_Account_gne__c FROM AP_Detail_gne__c WHERE AP_Account_Planning_gne__c = :apPlan.id]){
					if(!accountOrgIdToId.containsKey(detail.AP_Account_gne__r.OrgId_gne__c) && !detail.AP_Account_gne__r.OrgId_gne__c.startsWith(GNE_AP_Util.AP_INTERNAL_ACCOUNT_PREFIX)){
						accountOrgIdToId.put(detail.AP_Account_gne__r.OrgId_gne__c, detail.AP_Account_gne__c);
						request.addMericRequest(new AccountBrandWrapper(detail.AP_Account_gne__r.OrgId_gne__c));
					}
				}

				Map<Integer, AP_Account_PTP_gne__c>accountsMetrics = new Map<Integer, AP_Account_PTP_gne__c>();
				Map<Integer, List<AP_Competitor_Metric_gne__c>>competitorMetrics = new Map<Integer, List<AP_Competitor_Metric_gne__c>>();
				List<AP_PTP_gne__c>territoryMetrics = new List<AP_PTP_gne__c>();

				Integer index = 0;
				system.debug(JSON.serialize(request));
				HTTPResponse res = getPTPData(JSON.serialize(request));

				if(res.getStatusCode() == 200){
					System.debug(logginglevel.info, 'Response: '+ res.toString());
					System.debug(logginglevel.info, 'Respons body: '+ res.getBody());
					List<AP_PTP_gne__c>result = new List<AP_PTP_gne__c>();
					JSONParser parser = JSON.createParser(res.getBody());

					while (parser.nextToken() != null) {
						if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
							String fieldName = parser.getText();
							if(fieldName == 'accounts'){
								//parse accounts
								while(parser.nextToken() != JSONToken.END_ARRAY){
									if(parser.getCurrentToken() == JSONToken.FIELD_NAME  && parser.getText()=='account'){
										AP_Account_PTP_gne__c accountPerformance = new AP_Account_PTP_gne__c();
										accountsMetrics.put(index, accountPerformance);
										parser.nextToken();
										String accountId = parser.getText();
										system.debug('accountId: '+accountId);
										accountPerformance.AP_Account_gne__c = accountOrgIdToId.get(accountId);
										accountPerformance.AP_Account_Planning_gne__c = apPlan.Id;
										parser.nextToken();
										parser.nextToken();
										accountPerformance.Brand_gne__c = parser.getText();
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RCP_R3_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RCP_R6_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RCP_R12_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RVA_R3_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RVA_R6_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RVA_R12_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RGPA_R3_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RGPA_R6_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RGPA_R12_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.YOYGP_R3_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.YOYGP_R6_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.YOYGP_R12_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RCR6_CTRB_PC_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RCR6_CTRB_RNK_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RCR6_GRWTH_PC_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();
										accountPerformance.RCR6_GRWTH_RNK_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
										parser.nextToken();
										parser.nextToken();

										List<AP_Competitor_Metric_gne__c>metrics = new List<AP_Competitor_Metric_gne__c>();
										competitorMetrics.put(index, metrics);

										for(String cm: parser.getText().split(';')){
											AP_Competitor_Metric_gne__c metric = new AP_Competitor_Metric_gne__c();
											metric.Brand_gne__c = accountPerformance.Brand_gne__c;
											List<String>brandWithValue = cm.split(':');
											metric.Competitor_Brand_gne__c = brandWithValue[0];
											if(brandWithValue.size()==1){
												metric.CBGR6_PC_gne__c = 0;
											}else{
												metric.CBGR6_PC_gne__c = Decimal.valueOf(brandWithValue[1]);
											}
											metrics.add(metric);
										}
										index++;
									}

								}
								parser.nextToken();
							}

							String repType = parser.getText();
							while(parser.nextToken() != JSONToken.END_ARRAY){
								if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText()=='brand'){
									AP_PTP_gne__c performance = new AP_PTP_gne__c();
									performance.Type_gne__c = repType;
									performance.AP_Account_Planning_gne__c=apPlan.id;
									parser.nextToken();
									performance.Brand_gne__c = parser.getText();
									parser.nextToken();
									parser.nextToken();
									performance.Territory_Month_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Territory_Quarter_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Territory_Year_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Division_Month_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Division_Quarter_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Division_Year_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Region_Month_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Region_Quarter_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Region_Year_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Franchise_Month_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Franchise_Quarter_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
									parser.nextToken();
									parser.nextToken();
									performance.Franchise_Year_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());

									territoryMetrics.add(performance);
								}
							}
						}
					}
					system.debug(territoryMetrics.size());
					system.debug(accountsMetrics.size());
					system.debug(accountsMetrics.values());
					insert territoryMetrics;
					insert accountsMetrics.values();

					List<AP_Competitor_Metric_gne__c>metrics = new List<AP_Competitor_Metric_gne__c>();
					for(Integer idx : competitorMetrics.keySet()){
						for(AP_Competitor_Metric_gne__c metric: competitorMetrics.get(idx)){
							metric.AP_Account_PTP_gne__c = accountsMetrics.get(idx).Id;
							metrics.add(metric);
						}
					}
					system.debug(metrics);
					insert metrics;
				}else{
					System.debug(logginglevel.error, 'Respons body: '+ res.getBody());
					System.debug(logginglevel.error, 'Respons to string: '+ res.toString());
					System.debug(logginglevel.error, 'Respons status: ' + res.getStatus());
					System.debug(logginglevel.error, 'Respons status code: ' + res.getStatusCode());
				}
			}
		}catch(Exception e){
			system.debug(LoggingLevel.Error, e.getMessage());
		}
	}

	private static HTTPResponse getPTPData(String reqJSON){
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('content-type', 'application/json');
		req.setHeader('Api-Key', Utilities.getGlobalVariable('GNE_AP_ApiKey'));
		req.setBody(reqJSON);

		String endpoint= Utilities.getGlobalVariable('GNE_AP_PerformanceMetricsApiUrl');
		req.setEndpoint(endpoint);
		req.setClientCertificateName('GNE_AP_Commercial');
		String authorizationHeader = Utilities.getGlobalVariable('GNE_AP_PerformanceMetricsApiAuthHeader');
		req.setHeader('Authorization', authorizationHeader);
		system.debug(authorizationHeader);
		req.setTimeout(120000);
		System.debug(logginglevel.info, 'Request: '+ req.toString());
		Http http = new Http();
		HTTPResponse res = http.send(req);
		return res;
	}

	class AccountBrandWrapper{
		public String acc_id{get; set;}

		public AccountBrandWrapper(String id){
			this.acc_id = id;
		}
	}

	class MetricsRequest{
		public String territory_number{get; set;}
		public List<AccountBrandWrapper>accounts{get; set;}

		public MetricsRequest(String territoryNumber){
			this.territory_number = territoryNumber;
			this.accounts = new List<AccountBrandWrapper>();
		}

		public void addMericRequest(AccountBrandWrapper wrapper){
			this.accounts.add(wrapper);
		}
	}
}