public without sharing class GNE_SFA2_ReferralUtil {
    
    public static final String MA_PROFILE_PREFIX = 'GNE-MedAffairs';
    public static final String MSLCanadaProfile = 'RCanada-SFA-MSL';
    
    public static final String REFERRAL_RECORD_TYPE_NAME = 'Referral';
    public static final String REFERRAL_RECORD_TYPE_NAME_CANADA = 'ReferralCanada';
    public static final String REFERRAL_STATUS_ASSIGNED = 'Assigned';
    public static final String REFERRAL_STATUS_UNASSIGNED = 'Unassigned';
    public static final String REFERRAL_STATUS_ACKNOWLEDGED_CANADA = 'Acknowledged';
    public static final String REFERRAL_STATUS_FULFILLED_CANADA = 'Fulfilled';
	public static final String REFERRAL_STATUS_CLOSED_NOTV_CANADA = 'Closed – Not Verifiable';
	public static final String REFERRAL_STATUS_CLOSED_HCPU_CANADA = 'Closed – HCP Unresponsive';
    public static final String strAssigned = 'Assigned';
    public static final String strClosedDuplicate = 'Closed - Duplicate';
    public static final String strClosedHCPUnresponsive = 'Closed - HCP Unresponsive';
    public static final String strClosedNotVerifiable = 'Closed - Not Verifiable';
    public static final String strFulfilled = 'Fulfilled';
    public static final String strFulfilledMedComm = 'Fulfilled and Med Comm';
    public static final String strUrgentEscalation = 'Urgent Escalation';
    public static final String strNormalEscalation = 'Normal Escalation';    

    public static final String REFERRAL_EMAIL_STATUS_PREFIX = 'Email Sent';
    
    public static final String REFERRAL_WORKFLOW_ACTION_CREATED = 'Created';
    public static final String REFERRAL_WORKFLOW_ACTION_REQUEST_VERIFIED = 'Request Verified';
    public static final String REFERRAL_WORKFLOW_ACTION_CREATION_DATE_UPDATE = 'Completion Date Update';
    public static final String REFERRAL_WORKFLOW_ACTION_REASSIGNED = '  Reassigned';
    public static final String REFERRAL_WORKFLOW_ACTION_STATUS_UPDATE = 'Status Update';
    
    public static final Map<String,Integer> REFERRAL_WORKFLOW_ACTIONS_ORDER_MAP = new Map<String,Integer>{
        REFERRAL_WORKFLOW_ACTION_CREATED => 0,
        REFERRAL_WORKFLOW_ACTION_REQUEST_VERIFIED => 1,
        REFERRAL_WORKFLOW_ACTION_CREATION_DATE_UPDATE => 2,
        REFERRAL_WORKFLOW_ACTION_REASSIGNED => 3,
        REFERRAL_WORKFLOW_ACTION_STATUS_UPDATE => 4
    };
        
    public static final String PRODUCT_MOLECULE_TYPE = 'Molecule';
    public static final String PRODUCT_DETAIL_TYPE = 'Detail';
    public static final String PRODUCT_THERA_DISEASE_TYPE = 'TheraDisease';
    public static final String PRODUCT_BRAND_TYPE = 'Brand';
    public static final String PRODUCT_APPROVED_INDICATION_TYPE = 'Approved Product Indications';
    public static final String PRODUCT_TA_TYPE = 'TA';
    
    public static final String REFERRAL_TASUBTA_OTHER_SUFIX = '- Other';
    public static final String REFERRAL_TASUBTA_OTHERS_SUFIX = '- Others';
    public static final String REFERRAL_ROSTER_PRIMARY_FLAG = 'P';
    
    public static final Set<String> REFERRAL_MANUAL_ASSIGNEE_PROFILES = new Set<String>{
        'GNE-MedAffairs-MSL'
    };
    
    public static final Set<String> PRODUCT_NOT_VALID_OWNERS = new Set<String>{
        'GNE-INACTIVE-PROD-QUEUE',
        System.Label.GNE_SFA_Canada_Queue
    };
    
    public static final Set<String> PRODUCT_NOT_VALID_OWNERS_CANADA = new Set<String>{
        'GNE-INACTIVE-PROD-QUEUE',
        'GNE-CANADA-INACTIVE-PROD-QUEUE',
        'GNE-SFA-QUEUE'
    };

    public static final String ERROR_REFERRAL_NOT_VALID_PREFIX = 'Referral is not valid';
    public static final String ERROR_CODE_ACCOUNT_IS_MISSING = 'AccountIsMissing';
    public static final String ERROR_CODE_ADDRESS_IS_MISSING = 'AddressIsMissing';
    public static final String ERROR_CODE_PRIORITY_IS_MISSING = 'PriorityIsMissing';
    public static final String ERROR_CODE_QUESTION_IS_MISSING = 'QuestionIsMissing';
    public static final String ERROR_CODE_FOLLOWUPMETHOD_IS_MISSING = 'FollowUpMethodIsMissing';
    public static final String ERROR_CODE_TA_IS_MISSING = 'TaIsMissing';
    public static final String ERROR_CODE_AUTO_ASSIGNMENT_FAILED = 'AutoAssignmentFailed';
    
    public static final String EXTERNAL_SYSTEM_NAME = 'MA';
    public static final String FEATURE_REFERRAL_ASSIGNEE_CHECK = 'ReferralAssigneeCheck';
    public static final String FEATURE_REFERRAL_CREATE = 'ReferralCreate';
    public static final String FEATURE_REFERRAL_UPDATE = 'ReferralUpdate';
    public static final String FEATURE_REFERRAL_EMAIL_REDIRECT = 'ReferralEmailRedirect';
    
    public static final String S2S_CONFIG_ITEM_REFERRAL_REDIRECT_URL = 'ReferralEmailRedirectUrl';
    public static final String S2S_CONFIG_ITEM_EXT_SYSTEM_BASE_URL = 'MABaseUrl';
    
    public static final String S2S_ERROR_CODE_ASSIGNEE_CHECK_MISSING_RESPONSE = 'ReferralAssigneeCheckMissingResponse';
    public static final String S2S_ERROR_CODE_ASSIGNEE_CHECK_MISSING_RESPONSE_RECORD = 'ReferralAssigneeCheckMissingResponseRecord';
    public static final String S2S_ERROR_CODE_ASSIGNEE_CHECK_MISSING_ASSIGNEE = 'ReferralAssigneeCheckMissingAssignee';
    public static final String S2S_ERROR_CODE_ASSIGNEE_CHECK_INVALID_ASSIGNEE = 'ReferralAssigneeCheckInvalidAssignee';
    public static final String S2S_ERROR_CODE_CREATE_MISSING_RESPONSE = 'ReferralCreateMissingResponse';
    public static final String S2S_ERROR_CODE_CREATE_MISSING_RESPONSE_RECORD = 'ReferralCreateMissingResponseRecord';
    public static final String S2S_ERROR_CODE_UPDATE_DISABLED_FEATURE = 'ReferralUpdateDisabled';
    public static final String S2S_ERROR_CODE_UPDATE_MISSING_REQUEST = 'ReferralUpdateMissingRequest';
    public static final String S2S_ERROR_CODE_UPDATE_MISSING_RECORD = 'ReferralUpdateMissingRecord';
    public static final String S2S_ERROR_CODE_UPDATE_BULK_NOT_SUPPORTED = 'ReferralUpdateBulkNotSupported';
    public static final String S2S_ERROR_CODE_MISSING_RECORD_IDS = 'ReferralMissingRecrodIds';
    public static final String S2S_ERROR_CODE_INVALID_ASSIGNEE = 'ReferralInvalidAssignee';
    public static final String S2S_ERROR_CODE_MISSING_LOCAL_RECORD = 'ReferralMissingLocalRecord';
    public static final String S2S_ERROR_CODE_READONLY_REFERRAL_ROSTER = 'ReferralRosterIsReadOnly';
    
    private static Set<String> rosterTaSubTaNames;
    
    public static Date parseDateString(String dateAsString) {
        return GNE_SFA2_S2S_Util.parseDateString(dateAsString);
    }
    
    public static DateTime parseDateTimeString(String dateTimeAsString) {
        return GNE_SFA2_S2S_Util.parseDateTimeString(dateTimeAsString);
    }
    
    public static Set<String> getManualAssigneeProfiles() {
        return REFERRAL_MANUAL_ASSIGNEE_PROFILES;
    }
    
    public static Id getReferralRecordType() {
        return Medical_Communication_gne__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(GNE_SFA2_Util.isCanadaUser() ? REFERRAL_RECORD_TYPE_NAME_CANADA : REFERRAL_RECORD_TYPE_NAME).getRecordTypeId();
    }
    
    public static String getReferralSource(UserWrapper requestor) {
        String source = null;
        String profileName = requestor.getProfileName();
        
        if(String.isNotBlank(profileName)) {
            source = profileName;
            List<Referral_Source_gne__c> referralSourceConfig = [
                SELECT Id, Name, Profile_Name_gne__c, Source_Name_gne__c
                FROM Referral_Source_gne__c
                WHERE Profile_Name_gne__c= :profileName
                LIMIT 1];
            
            source = !referralSourceConfig.isEmpty() ? referralSourceConfig[0].Source_Name_gne__c : source;
        }
        
        return source;
    }
    
    public static List<ReferralProduct> getProducts() {
        List<ReferralProduct> result = new List<ReferralProduct>();
        
        if (GNE_SFA2_Util.isCanadaUser()) {
	        Integer userRegionCode = 2;
	        List<Product_vod__c> prods = [
	            SELECT Id, Name, Active__c, Parent_Product_vod__c, Product_Type_vod__c, Detail_Product_Subtype_code_gne__c, TheraDisease_Reference_gne__c
	            FROM Product_vod__c
	            WHERE Name <> null
	            	AND Product_Type_vod__c = 'Detail'  
	            	AND Active__c = true
                    AND (Detail_Product_Subtype_Code_gne__c != 'Molecule' AND Detail_Product_Subtype_Code_gne__c != 'TheraDisease')
	                AND Region_Code_gne__c = 2
	            	AND Owner.Name NOT IN :PRODUCT_NOT_VALID_OWNERS_CANADA
	            ORDER BY Name, Id
	        ];	        
	        
	        Set<String> visited = new Set<String>();
	        for(Product_vod__c prodRec : prods) {
	            ReferralProduct prod = new ReferralProduct(prodRec, PRODUCT_BRAND_TYPE);
	            if(prod.isValid() && visited.add(prod.getKey())) {
	                result.add(prod);
	            }
	        }	   	    
        } else {
	        List<Product_vod__c> prods = [
	            SELECT Id, Name, Active__c, Parent_Product_vod__c, Product_Type_vod__c, Detail_Product_Subtype_code_gne__c, TheraDisease_Reference_gne__c
	            FROM Product_vod__c
	            WHERE Name <> null 
	                AND Name NOT IN :getRestrictedProductName()
	                AND Owner.Name NOT IN :PRODUCT_NOT_VALID_OWNERS
	                AND (Product_Type_vod__c=:PRODUCT_DETAIL_TYPE OR Detail_Product_Subtype_Code_gne__c=:PRODUCT_MOLECULE_TYPE)
	            ORDER BY Name, Id
	        ];

	        Set<String> visited = new Set<String>();
	        
	        for(Product_vod__c prodRec : prods) {
	            String pType = isBrandProduct(prodRec) ? PRODUCT_BRAND_TYPE : isTA(prodRec) ? PRODUCT_TA_TYPE : isMolecule(prodRec) ? PRODUCT_MOLECULE_TYPE : null;
	            ReferralProduct prod = new ReferralProduct(prodRec, pType);
	            if(prod.isValid() && visited.add(prod.getKey())) {
	                result.add(prod);
	            }
	        }
	        
	        if(GNE_SFA2_S2S_Util.isFeatureEnabled(FEATURE_REFERRAL_CREATE)) {
	            result.addAll(getTAsFromReferralRosters());
	        }
        }

        return result;
    }
    
    private static List<ReferralProduct> getTAsFromReferralRosters() {
        List<ReferralProduct> result = new List<ReferralProduct>();
        
        List<MA_Referral_Roster__c> rosters = [
            SELECT Id, TA__c
            FROM MA_Referral_Roster__c
            WHERE ConnectionReceivedId <> null AND Is_Active__c = true 
                AND Unixid__c <> null AND User__r.IsActive = true AND Is_Active_User__c = true
                AND TA__c <> null 
            ORDER BY TA__c
        ];
        Set<String> visited = new Set<String>();
        
        for(MA_Referral_Roster__c roster : rosters) {
            ReferralProduct rProd = new ReferralProduct(roster);
            
            if(rProd.isValid() && visited.add(rProd.getKey())) {
                result.add(rProd);
            }
        }
        
        return result;
    }
    
    private static Set<String> getRestrictedProductName() {
        Set<String> result = new Set<String>();
        
        for(MedAffairs_Molecules_gne__c molecule : [SELECT Molecule_Name_gne__c FROM MedAffairs_Molecules_gne__c WHERE Molecule_Name_gne__c <> null]) {
            result.add(molecule.Molecule_Name_gne__c);
        }
        
        return result;
    }
    
    public static Boolean isBrandProduct(Product_vod__c prodRec) {
        return prodRec.Product_Type_vod__c==PRODUCT_DETAIL_TYPE && (prodRec.Detail_Product_Subtype_Code_gne__c == PRODUCT_BRAND_TYPE || prodRec.Detail_Product_Subtype_Code_gne__c == PRODUCT_APPROVED_INDICATION_TYPE);
    }
    
    public static Boolean isTA(Product_vod__c prodRec) {
        return !GNE_SFA2_S2S_Util.isFeatureEnabled(FEATURE_REFERRAL_CREATE) && prodRec.Product_Type_vod__c == PRODUCT_DETAIL_TYPE && prodRec.Detail_Product_Subtype_Code_gne__c == PRODUCT_THERA_DISEASE_TYPE;
    }
    
    public static Boolean isMolecule(Product_vod__c prodRec) {
        return prodRec.Detail_Product_Subtype_Code_gne__c==PRODUCT_MOLECULE_TYPE;
    }
    
    public static Boolean isReferralProduct(Product_vod__c prodRec) {
        return isBrandProduct(prodRec) || isTA(prodRec) || isMolecule(prodRec);
    }
    
    public static List<AssigneeUser> getManualAssigneeUsers() {
        List<AssigneeUser> result = new List<AssigneeUser>();
    	
        if (GNE_SFA2_S2S_Util.isFeatureEnabled(FEATURE_REFERRAL_CREATE)) {
        	Integer regionCode = GNE_SFA2_Util.isCanadaUser() ? 2 : 1;
            List<MA_Referral_Roster__c> rosters = [
                SELECT Id, TA__c, State__c,
                    User__c, User__r.Id, User__r.Name, User__r.FirstName, User__r.LastName, User__r.Business_Role_gne__c, User__r.UserRole.Name, User__r.Profile.Name,
                    User__r.Email, User__r.Phone, User__r.MobilePhone, User__r.External_ID_gne__c, User__r.title
                FROM MA_Referral_Roster__c
                WHERE ConnectionReceivedId <> null AND Is_Active__c = true AND Is_Active_User__c = true AND Unixid__c <> null AND User__r.IsActive = true AND User__r.Region_Code_gne__c = :regionCode
                ORDER BY User__r.Name
            ];
            
            if ( GNE_SFA2_Util.isCanadaUser()) {
            	for(MA_Referral_Roster__c roster : rosters) {
            		result.add(new AssigneeUser(roster.User__r, null, null));
            	}
            } else {
	            Set<Id> userIds = new Set<Id>();
	            List<User> users = new List<User>();
	            Map<Id,Set<String>> userToTAs = new Map<Id,Set<String>>();
	            Map<Id,Set<String>> userToStates = new Map<Id,Set<String>>();
	            
	            for(MA_Referral_Roster__c roster : rosters) {
	                Id userId = roster.User__c;
	                Set<String> taSet = roster.TA__c!=null ? new Set<String>{roster.TA__c.toUpperCase()}: new Set<String>();
	                Set<String> stateSet = roster.State__c!=null ? new Set<String>(roster.State__c.toUpperCase().split(';')) : new Set<String>();
	                
	                if(!userToTAs.containsKey(userId)) {
	                    userToTAs.put(userId, new Set<String>());
	                    userToStates.put(userId, new Set<String>());
	                }
	                
	                userToTAs.get(userId).addAll(taSet);
	                userToStates.get(userId).addAll(stateSet);
	                
	                if(userIds.add(userId)) {
	                    users.add(roster.User__r);
	                }
	            }
            
	            for(User usr : users) {
	                result.add(new AssigneeUser(usr, userToTAs.get(usr.Id), userToStates.get(usr.Id)));
	            }
            }
        } else if  (GNE_SFA2_Util.isCanadaUser()) {
        	List<User> users = [
            SELECT Id, Name, FirstName, LastName, Business_Role_gne__c, UserRole.Name, Profile.Name,
                Email, Phone, MobilePhone, Title, External_ID_gne__c
            FROM User
            WHERE IsActive = true AND Profile.Name = :MSLCanadaProfile
            ORDER BY Name
	        ];
	        
	        for(User u : users) {
	            result.add(new AssigneeUser(u, null, null));
	        }    		
    	} else {
	        Set<Id> visitedIds = new Set<Id>();
	        
	        List<Referral_Roster_gne__c> rosters = [
	            SELECT User_gne__c, User_gne__r.Id, User_gne__r.Name, User_gne__r.FirstName, User_gne__r.LastName, User_gne__r.Business_Role_gne__c, User_gne__r.UserRole.Name, User_gne__r.Profile.Name,
                    User_gne__r.Email, User_gne__r.Phone, User_gne__r.MobilePhone, User_gne__r.External_ID_gne__c,
	                (SELECT Therapeutic_Area_gne__c, State_gne__c
	                 FROM Referral_Roster_Details__r
	                 WHERE Therapeutic_Area_gne__c <> null AND State_gne__c <> null)
	            FROM Referral_Roster_gne__c
	            WHERE User_gne__r.IsActive = true AND User_gne__r.Profile.Name IN :getManualAssigneeProfiles()
	            ORDER BY User_gne__r.Name
	        ];
	        
	        for(Referral_Roster_gne__c roster : rosters) {
	            if(visitedIds.add(roster.User_gne__c)) {
		            Set<String> tAreas = new Set<String>();
		            Set<String> states = new Set<String>();
		            
		            for(Referral_Roster_Detail_gne__c rDetail : roster.Referral_Roster_Details__r) {
		                tAreas.add(rDetail.Therapeutic_Area_gne__c.toUpperCase());
		                states.add(rDetail.State_gne__c.toUpperCase());
		            }
		            
		            result.add(new AssigneeUser(roster.User_gne__r, tAreas, states));
	            }
	        }
        }
        return result;
    }
    
    public static Boolean isAutoAssignmentSupported(Product_vod__c taSubTaRec) {
        Boolean result = false;
        if(GNE_SFA2_S2S_Util.isFeatureEnabled(FEATURE_REFERRAL_CREATE)) {
            // Auto Assignment is fully supported by Med Affairs External System (for all taSubTas)
            result = true;
        } else {
            if(rosterTaSubTaNames==null) {
	            rosterTaSubTaNames = new Set<String>();
	            List<Referral_Roster_Detail_gne__c> rosters = [
                    SELECT Product_TA_SubTA_gne__r.Name
                    FROM Referral_Roster_Detail_gne__c
                    WHERE Product_TA_SubTA_gne__r.Name <> null
                        AND (Referral_Roster_gne__r.User_gne__r.IsActive = true OR Referral_Roster_gne__r.Manager_gne__r.IsActive = true)
                ];
		        
		        for(Referral_Roster_Detail_gne__c roster : rosters) {
                    rosterTaSubTaNames.add(getProductName(roster.Product_TA_SubTA_gne__r).toUpperCase());
                }
            }
            
            Set<String> taSubTaNames = getRosterTaSubTaNames(getProductName(taSubTaRec));
            taSubTaNames.retainAll(rosterTaSubTaNames);
            result = !taSubTaNames.isEmpty();
        }
        
        return result;
    }
    
    public static String getProductName(Product_vod__c prod) {
        return prod.Name;
    }
    
    private static Set<String> getRosterTaSubTaNames(String taSubTaName) {
        return new Set<String>{
            taSubTaName.toUpperCase(), 
            (taSubTaName.substringBefore('-') + REFERRAL_TASUBTA_OTHER_SUFIX).toUpperCase(),
            (taSubTaName.substringBefore('-') + REFERRAL_TASUBTA_OTHERS_SUFIX).toUpperCase()
        };
    }
    
    public static UserWrapper getAutoAssignee(ProductWrapper taSubTa, String state) {
        UserWrapper assignee = null;
        if(GNE_SFA2_S2S_Util.isFeatureEnabled(FEATURE_REFERRAL_CREATE)) {
            // Auto Assignment is fully handled by Med Affairs External System
        } else {
            Set<String> taSubTaNames = getRosterTaSubTaNames(taSubTa.getName());
            List<RosterWrapper> rosters = new List<RosterWrapper>();
	        List<Referral_Roster_Detail_gne__c> rosterRecs = [
	            SELECT Product_TA_SubTA_gne__r.Name, State_gne__c, Referral_Roster_gne__r.Primary_OR_Secondary_gne__c,
	                Referral_Roster_gne__r.User_gne__c, Referral_Roster_gne__r.Manager_gne__c,
	                Referral_Roster_gne__r.User_gne__r.Id, Referral_Roster_gne__r.User_gne__r.IsActive,
	                Referral_Roster_gne__r.Manager_gne__r.Id, Referral_Roster_gne__r.Manager_gne__r.IsActive
	            FROM Referral_Roster_Detail_gne__c
	            WHERE Product_TA_SubTA_gne__r.Name IN :taSubTaNames
	                AND (Referral_Roster_gne__r.User_gne__r.IsActive = true OR Referral_Roster_gne__r.Manager_gne__r.IsActive = true)
	        ];
	        
	        if(!rosterRecs.isEmpty()) {
	            for(Referral_Roster_Detail_gne__c rosterRec : rosterRecs) {
	                Boolean isPrimary = rosterRec.Referral_Roster_gne__r.Primary_OR_Secondary_gne__c==REFERRAL_ROSTER_PRIMARY_FLAG;
	                rosters.add(new RosterWrapper(rosterRec.Referral_Roster_gne__r.User_gne__r, rosterRec.Referral_Roster_gne__r.Manager_gne__r, getProductName(rosterRec.Product_TA_SubTA_gne__r), rosterRec.State_gne__c, isPrimary, taSubTa.getName(), state));
	            }
	        }
	        
	        rosters.sort();
            assignee = !rosters.isEmpty() ? new UserWrapper(rosters[0].getUserId()) : null;
        }
        
        return assignee;
    }
    
    public static List<ActionWrapper> getReferralHistoryActions(String historyAsJsonString) {
        List<ActionWrapper> result = null;
        
        if(String.isNotBlank(historyAsJsonString)) {
            try {
                result = (List<ActionWrapper>)JSON.deserialize(historyAsJsonString, List<ActionWrapper>.class);
            } catch(Exception e) {}
            
            if(result==null) {
                result = new List<ActionWrapper>();
                
                for (String actionAsCsvRow : historyAsJsonString.split(';')) {
                    String[] actionCells = actionAsCsvRow.split(',');
                    Integer cellsSize = actionCells.size();
                    
                    String cdAsString = cellsSize>0 ? actionCells[0] : null;
                    String actionName = cellsSize>1 ? actionCells[1] : null;
                    String actionBy = cellsSize>2 ? actionCells[2] : null;
                    String assignedTo = cellsSize>3 ? actionCells[3] : null;
                    String assignedToId = cellsSize>4 ? actionCells[4] : null;
                    String assignedToProfile = cellsSize>5 ? actionCells[5] : null;
                    String status = cellsSize>6 ? actionCells[6] : null;
                    DateTime cDate = getDateTimeFromPST(cdAsString);
                    
                    if(cDate!=null && String.isNotBlank(actionName)) {
                        ActionWrapper action = new ActionWrapper(cDate, actionName, actionBy, assignedToId, assignedTo, assignedToProfile, status);
                        result.add(action);
                    }
                }
            }
        }
        
        return result!=null ? result : new List<ActionWrapper>();
    }

    public static List<ActionWrapper> getReferralCommentsActions(String commentsAsJsonString) {
        List<ActionWrapper> result = null;
        
        if(String.isNotBlank(commentsAsJsonString)) {
            try {
                result = (List<ActionWrapper>)JSON.deserialize(commentsAsJsonString, List<ActionWrapper>.class);
            } catch(Exception e) {}
            
            if(result==null) {
                result = new List<ActionWrapper>();
                
                for (String actionAsCsvRow : commentsAsJsonString.split(',#,')) {
                    String[] actionCells = actionAsCsvRow.split(',@,');
                    Integer cellsSize = actionCells.size();
                    
                    String cdAsString = cellsSize>0 ? actionCells[0] : null;
                    String actionName = cellsSize>1 ? actionCells[1] : null;
                    String actionBy = cellsSize>2 ? actionCells[2] : null;
                    DateTime cDate = getDateTimeFromPST(cdAsString);
                    
                    if(cDate!=null && String.isNotBlank(actionName)) {
                        ActionWrapper action = new ActionWrapper(cDate, actionName, actionBy, null, null, null, null);
                        result.add(action);
                    }
                }
            }
        }
        
        return result!=null ? result : new List<ActionWrapper>();
    }
    
    private static DateTime getDateTimeFromPST(String dtAsString) {
        DateTime result = null;
        
        if(String.isNotBlank(dtAsString)) {
            Matcher m = Pattern.compile('^(\\d{2})/(\\d{2})/(\\d{4})\\s(\\d{2}):(\\d{2})\\s(\\w{2})$').matcher(dtAsString);
        
            if(m.matches()) {
                Integer month = Integer.valueOf(m.group(1));
                Integer day = Integer.valueOf(m.group(2));
                Integer year = Integer.valueOf(m.group(3));
                Integer hour = Integer.valueOf(m.group(4));
                Integer minute = Integer.valueOf(m.group(5));
                String amPmTag = m.group(6);
                hour += amPmTag=='PM' ? 12 : 0;
                result = DateTime.newInstanceGmt(year, month, day, hour, minute, 0);
                result = DateTime.newInstance(result.getTime() - TimeZone.getTimeZone('PST').getOffset(result));
            }
        }
        
        return result;
    }
    
    private static Map<String,String> getErrorMessagesMap(List<String> errorCodes) {
        Map<String,String> result = new Map<String,String>();
        String cLabelPrefix = 'GNE_SFA2_Referral_Error_';
        Set<String> cLabelNames = new Set<String>();
        
        for(String errorCode : errorCodes) {
            cLabelNames.add(cLabelPrefix + errorCode);
            result.put(errorCode.toUpperCase(), errorCode);
        }
        
        if(!cLabelNames.isEmpty()) {
            List<ExternalString> cLabels = [SELECT Name, Value FROM ExternalString WHERE Category = 'Referral' AND Name IN :cLabelNames];
            
            for(ExternalString cLabel : cLabels) {
                result.put(cLabel.Name.substringAfter(cLabelPrefix).toUpperCase(), cLabel.Value);
            }
        }
        
        return result;
    }
    
    public static Boolean isRosterChanged(DateTime lastSynchronized) {
        Boolean isChanged = false;
        
        if(GNE_SFA2_S2S_Util.isFeatureEnabled(FEATURE_REFERRAL_CREATE)) {
            isChanged = ![
                SELECT Id
                FROM MA_Referral_Roster__c
                WHERE LastModifiedDate >= :lastSynchronized
                    OR User__r.LastModifiedDate >= :lastSynchronized
                LIMIT 1
                ALL ROWS
            ].isEmpty() || ![
                SELECT Id
                FROM PartnerNetworkRecordConnection
                WHERE LocalRecordId IN (SELECT Id FROM MA_Referral_Roster__c WHERE ConnectionReceivedId = null)
                    AND Status IN :GNE_SFA2_S2S_Util.EXT_SHARING_INACTIVE_STATUSES
                    AND EndDate >= :lastSynchronized
                LIMIT 1
            ].isEmpty() || ![
                SELECT Id
                FROM GNE_SFA2_S2S_Config_Items_gne__c
                WHERE Name IN (:GNE_SFA2_S2S_Config.ConfigItem.S2SEnabled.name(), :GNE_SFA2_S2S_Config.ConfigItem.DisabledFeatures.name())
                    AND LastModifiedDate >= :lastSynchronized
                LIMIT 1
            ].isEmpty();
        } else {
            isChanged = ![
                SELECT Id
                FROM Referral_Roster_gne__c
                WHERE LastModifiedDate >= :lastSynchronized
                    OR User_gne__r.LastModifiedDate >= :lastSynchronized
                LIMIT 1
                ALL ROWS
            ].isEmpty() || ![
                SELECT Id
                FROM Referral_Roster_Detail_gne__c
                WHERE LastModifiedDate >= :lastSynchronized
                LIMIT 1
                ALL ROWS
            ].isEmpty() || ![
                SELECT Id
                FROM GNE_SFA2_S2S_Config_Items_gne__c
                WHERE Name IN (:GNE_SFA2_S2S_Config.ConfigItem.S2SEnabled.name(), :GNE_SFA2_S2S_Config.ConfigItem.DisabledFeatures.name())
                    AND LastModifiedDate >= :lastSynchronized
                LIMIT 1
            ].isEmpty();
        }
        
        return isChanged;
    }
    
    public static void validateOnReferralRosterDml(List<MA_Referral_Roster__c> triggerNew) {
        if(!GNE_SFA2_S2S_Config.isS2SConnectionUser(UserInfo.getName()) && !System.isBatch()) {
            Exception ex = GNE_SFA2_S2S_Util.createException(S2S_ERROR_CODE_READONLY_REFERRAL_ROSTER);
            
            for(MA_Referral_Roster__c roster : triggerNew) {
                roster.addError(ex);
            }
        }
    }
    
    public static void onReferralRosterUpsert(List<MA_Referral_Roster__c> triggerNew, List<MA_Referral_Roster__c> triggerOld) {
        Map<String,List<MA_Referral_Roster__c>> unixIdToRostersMap = new Map<String,List<MA_Referral_Roster__c>>();
        
        Integer idx = 0;
        for(MA_Referral_Roster__c roster : triggerNew) {
            MA_Referral_Roster__c rosterOld = triggerOld!=null ? triggerOld[idx++] : new MA_Referral_Roster__c();
            
            if(roster.Unixid__c!=rosterOld.Unixid__c || (roster.Unixid__c!=null && roster.User__c==null) || (roster.Unixid__c==null && roster.User__c!=null)) {
                roster.User__c = null;
                String key = roster.Unixid__c!=null ? roster.Unixid__c.toUpperCase() : null;
        
                if(key!=null) {
                    if(!unixIdToRostersMap.containsKey(key)) {
                        unixIdToRostersMap.put(key, new List<MA_Referral_Roster__c>());
                    }
                    
                    unixIdToRostersMap.get(key).add(roster);
                }
            }
        }
        
        if(!unixIdToRostersMap.isEmpty()) {
            List<User> users = [SELECT Id, External_Id_gne__c FROM User WHERE IsActive = true AND External_Id_gne__c IN :unixIdToRostersMap.keySet()];
            
            for(User usr : users) {
                String key = usr.External_Id_gne__c.toUpperCase();
                
                for(MA_Referral_Roster__c roster : unixIdToRostersMap.get(key)) {
                    roster.User__c = usr.Id;
                }
            }
        }
        
        GNE_SFA2_S2S_Util.scheduleExternalSharingCleanupJob();
    }
    
    public class ReferralProduct {
        private String id;
        private String name;
        private String type;
        private String ta;
        private Boolean autoMode;
        
        public ReferralProduct(Product_vod__c prodRec, String pType) {
            this(prodRec.Id, getProductName(prodRec), pType, pType==PRODUCT_BRAND_TYPE ? prodRec.TheraDisease_Reference_gne__c : null, pType==PRODUCT_TA_TYPE ? isAutoAssignmentSupported(prodRec) : null);
        }
        
        public ReferralProduct(MA_Referral_Roster__c roster) {
            this(roster.TA__c, roster.TA__c, PRODUCT_TA_TYPE, null, true);
        }
        
        public ReferralProduct(String id, String name, String type, String ta, Boolean autoMode) {
            this.id = id;
            this.name = name;
            this.type = type;
            this.ta = ta;
            this.autoMode = autoMode;
        }
        
        public String getId() {
            return this.id;
        }
        
        public String getName() {
            return this.name;
        }
        
        public String getType() {
            return this.type;
        }
        
        public String getTA() {
            return this.ta;
        }
        
        public Boolean isAutoMode() {
            return this.autoMode==true;
        }
        
        public Boolean isBrand() {
            return this.getType()==PRODUCT_BRAND_TYPE;
        }
        
        public Boolean isTA() {
            return this.getType()==PRODUCT_TA_TYPE;
        }
        
        public Boolean isMolecule() {
            return this.getType()==PRODUCT_MOLECULE_TYPE;
        }
        
        public Boolean isValid() {
            return isBrand() || isTA() || isMolecule();
        }
        
        private String getKey() {
            return (this.name + '_' + this.type).toUpperCase();
        }
    }
    
    public class AssigneeUser {
        private String id;
        private String name;
        private String firstName;
        private String lastName;
        private String title;
        private String profileName;
        private String email;
        private String phone;
        private String mobilePhone;
        private String unixId;
        private List<String> states;
        private List<String> tAreas;
        
        public AssigneeUser(User u, Set<String> tAreas, Set<String> states) {
            this.id = u.Id;
            this.name = u.Name;
            this.firstName = u.FirstName;
            this.lastName = u.LastName;
            this.unixId = u.External_ID_gne__c;
            this.title = GNE_SFA2_Util.isCanadaUser() ? u.title : u.Business_Role_gne__c;
            this.profileName = u.Profile.Name;
            this.email = u.Email;
            this.phone = u.Phone;
            this.mobilePhone = u.MobilePhone;
            this.tAreas = tAreas!=null ? new List<String>(tAreas) : new List<String>();
            this.states = states!=null ? new List<String>(states) : new List<String>();
            this.tAreas.sort();
            this.states.sort();
        }
        
        public String getId() {
            return this.id;
        }
        
        public String getName() {
            return this.name;
        }
        
        public String getFirstName() {
            return this.firstName;
        }
        
        public String getLastName() {
            return this.lastName;
        }
        
        public String getTitle() {
            return this.title;
        }
        
        public String getProfileName() {
            return this.profileName;
        }
        
        public String getEmail() {
            return this.email;
        }
        
        public String getPhone() {
            return this.phone;
        }
        
        public String getMobilePhone() {
            return this.mobilePhone;
        }
        
        public List<String> getStates() {
            return this.states;
        }
        
        public List<String> getTAreas() {
            return this.tAreas;
        }
    }
    
    private class RosterWrapper implements Comparable {
        private transient Double rank;
        private transient Id userId;
        
        private RosterWrapper(User usr, User manager, String rosterTaSubTa, String rosterState, Boolean isPrimary, String taSubTaName, String state) {
            this.userId = usr.IsActive ? usr.Id : manager!=null && manager.IsActive ? manager.Id : null;
            this.rank = calculateRank(rosterTaSubTa, rosterState, isPrimary, taSubTaName, state);
        }
        
        private Double getRank() {
            return this.rank;
        }
        
        private Double calculateRank(String rosterTaSubTa, String rosterState, Boolean isPrimary, String taSubTaName, String state) {
            Double rank = rosterTaSubTa==taSubTaName ? 100.0 : 0.0;
            rank+=rosterState==state ? 10.0 : 0.0;
            rank+=isPrimary==true ? 1.0 : 0.0;
            rank+=Math.random();
            return rank;
        }
        
        private Id getUserId() {
            return this.userId;
        }
        
        public Integer compareTo(Object otherRoster) {
            Double rank = this.getRank();
            Double otherRank = ((RosterWrapper)otherRoster).getRank();
            Double result = rank-otherRank;
            return result==0.0 ? 0 : result>0.0 ? -1 : 1;
        }
    }
    
    public virtual class ReferralRequest extends GNE_SFA2_S2S_Util.Request {
        protected List<ReferralWrapper> records;
        
        public ReferralRequest() {
            super();
        }
        
        public ReferralRequest(List<GNE_SFA2_S2S_Interface.RecordInterface> records, Actor actor, Boolean allOrOne) {
            super(records, actor, allOrOne);
        }
        
        public virtual override System.Type getSelfClass() {
            return ReferralRequest.class;
        }
        
        public virtual override List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<ReferralWrapper>();
            }
            
            return this.records;
        }
    }
    
    public virtual class ReferralWrapper extends GNE_SFA2_S2S_Util.Record {
        protected String name;
        protected String medCommName;
        protected AccountWrapper account;
        protected ReferralDataWrapper referralData;
        protected String sfaId;
        protected UserWrapper assignee;
        protected Boolean autoMode;
        protected UserWrapper requestor;
        protected Boolean isOtrRequest;
        protected Boolean isUSARequest;
        protected transient Boolean isProductsFetched;
        protected transient Boolean isAccountAndAddressFetched;
        protected transient Boolean isRequestorFetched;
        
        public ReferralWrapper() {
        	this.isUSARequest = true;
        }
        
        public ReferralWrapper(String localId, String extId, String name, AccountWrapper account, ReferralDataWrapper referralData, UserWrapper assignee, UserWrapper requestor) {
            super(localId, extId);
            this.isUSARequest = true;
            this.name = name;
            this.account = account;
            this.referralData = referralData;
            this.assignee = assignee;
            this.requestor = requestor;
        }
        
        public virtual String getName() {
            return this.name;
        }
        
        public virtual void setName(String name) {
            this.name = name;
        }
        
        public virtual String getMedCommName() {
            return this.medCommName;
        }
        
        public virtual String getsfaId() {
            return this.sfaId;
        }
        
        public virtual void setsfaId(String Id) {
            this.sfaId = id;
        }

        public virtual void setMedCommName(String medCommName) {
            this.medCommName = medCommName;
        }
        
        public virtual AccountWrapper getAccount() {
            return this.account;
        }
        
        public virtual void setAccount(AccountWrapper account) {
            this.account = account;
        }
        
        public virtual ReferralDataWrapper getReferralData() {
            return this.referralData;
        }
        
        public virtual UserWrapper getAssignee() {
            return this.assignee;
        }
        
        public virtual void setAutoAssignee(UserWrapper assignee) {
            this.assignee = assignee;
        }
        
        public virtual Boolean getAutoMode() {
            return this.autoMode==true;
        }
        
        public virtual void setAutoMode(Boolean autoMode) {
            this.autoMode = autoMode;
        }
        
        public virtual UserWrapper getRequestor() {
            return this.requestor;
        }
        
        public virtual void setRequestor(UserWrapper requestor) {
            this.requestor = requestor;
        }
        
        public virtual Boolean isProductsFetched() {
            return this.isProductsFetched==true;
        }
        
        public virtual void setProductsFetched(Boolean isProductsFetched) {
            this.isProductsFetched=isProductsFetched;
        }
        
        public virtual Boolean isAccountAndAddressFetched() {
            return this.isAccountAndAddressFetched==true;
        }
        
        public virtual void setAccountAndAddressFetched(Boolean isAccountAndAddressFetched) {
            this.isAccountAndAddressFetched=isAccountAndAddressFetched;
        }
        
        public virtual Boolean isRequestorFetched() {
            return this.isRequestorFetched==true;
        }
        
        public virtual void setRequestorFetched(Boolean isRequestorFetched) {
            this.isRequestorFetched=isRequestorFetched;
        }

        public virtual void setIsOtrRequest(Boolean isOtrRequest){
            this.isOtrRequest = isOtrRequest;
        }

        public virtual Boolean getIsOtrRequest(){
            return this.isOtrRequest != null && this.isOtrRequest == true;
        }
        
        public virtual void setIsUSARequest(Boolean isUSARequest){
            this.isUSARequest = isUSARequest;
        }

        public virtual Boolean getIsUSARequest(){
            return this.isUSARequest != null && this.isUSARequest == true;
        }
    }
    
    public virtual class AccountWrapper extends GNE_SFA2_S2S_Util.PersonAccount {
        public AccountWrapper(Id accId, Id addrId, String phone) {
            super(accId, addrId);
            this.phone = String.isNotBlank(phone) ? phone : this.phone;
        }
        
        public AccountWrapper(Account acc, Address_vod__c addr, String phone) {
            super(acc, addr);
            this.phone = String.isNotBlank(phone) ? phone : this.phone;
        }
    }
    
    public virtual class ReferralDataWrapper {
        protected ProductWrapper product;
        protected ProductWrapper ta;
        protected ProductWrapper molecule;
        protected String question;
        protected String followUpMethod;
        protected String language;
        protected String priority;
        public String reqCompletionDate;
        protected String source;
        public String revCompletionDate;
        protected String status;
        protected String comment;

        public ReferralDataWrapper(ProductWrapper product, ProductWrapper ta, ProductWrapper molecule,
                String question, String followUpMethod, String priority, Date reqCompletionDate) {
            initReferralDataWrapper(product, ta, molecule, question, followUpMethod, priority, reqCompletionDate, null);
        }

        public ReferralDataWrapper(ProductWrapper product, ProductWrapper ta, ProductWrapper molecule,
                String question, String followUpMethod, String priority, Date reqCompletionDate, String language) {
            initReferralDataWrapper(product, ta, molecule, question, followUpMethod, priority, reqCompletionDate, language);
        }

        private void initReferralDataWrapper(ProductWrapper product, ProductWrapper ta, ProductWrapper molecule,
                String question, String followUpMethod, String priority, Date reqCompletionDate, String language) {
            this.product = product;
            this.ta = ta;
            this.molecule = molecule;
            this.question = question;
            this.followUpMethod = followUpMethod;
            this.language = language;
            this.priority = priority;
            this.reqCompletionDate = reqCompletionDate!=null ? DateTime.newInstanceGmt(reqCompletionDate.year(), reqCompletionDate.month(), reqCompletionDate.day()).formatGmt('yyyy-MM-dd') : null;
        }
        
        public virtual ProductWrapper getProduct() {
            return this.product;
        }
        
        public virtual ProductWrapper getTA() {
            return this.ta;
        }
        
        public virtual ProductWrapper getMolecule() {
            return this.molecule;
        }
        
        public virtual String getQuestion() {
            return this.question;
        }
        
        public virtual String getFollowUpMethod() {
            return this.followUpMethod;
        }
        
        public virtual String getLanguage() {
            return this.language;
        }
        
        public virtual String getPriority() {
            return this.priority;
        }
        
        public virtual Date getReqCompletionDate() {
            return parseDateString(this.reqCompletionDate);
        }
        
        public virtual String getSource() {
            return this.source;
        }
        
        public virtual void setSource(String source) {
            this.source = source;
        }

        public virtual Date getRevCompletionDate() {
			return parseDateString(this.revCompletionDate);
        }

        public virtual String getStatus() {
            return this.status;
        }

        public virtual String getComment() {
            return this.comment;
        }
        
    }
    
    public virtual class ProductWrapper extends GNE_SFA2_S2S_Util.Record {
        protected String name;
        
        public ProductWrapper(Id prodId) {
            super(prodId, null);
        }
        
        public ProductWrapper(String localId, String extId, String name) {
            super(localId, extId);
            this.name = name;
        }
        
        public virtual String getName() {
            return this.name;
        }
        
        public virtual void setName(String name) {
            this.name = name;
        }
    }
    
    public virtual class UserWrapper extends GNE_SFA2_S2S_Util.Actor {
        protected UserWrapper manager;
        
        public UserWrapper() {}
        
        public UserWrapper(Id uId) {
            super(uId);
        }
        
        public UserWrapper(User u) {
            super(u);
        }
        
        public UserWrapper(GNE_SFA2_S2S_Interface.ActorInterface other) {
            super(other);
        }
        
        public UserWrapper(String userId, String name, String profileName) {
            super(userId instanceof Id ? (Id)userId : null);
            this.name = name;
            this.profileName = profileName;
        }
        
        public virtual UserWrapper getManager() {
            return this.manager;
        }
    }
    
    public virtual class ReferralResultWrapper extends GNE_SFA2_S2S_Util.Response {
        protected List<ReferralUpdateDataWrapper> records;
        
        public ReferralResultWrapper() {}
        
        public ReferralResultWrapper(Boolean success, List<ReferralUpdateDataWrapper> records, List<GNE_SFA2_S2S_Util.Error> errors) {
            this.success = false;
            this.records = records;
            this.errors = errors;
        }
        
        public virtual override System.Type getSelfClass() {
            return ReferralResultWrapper.class;
        }
        
        public virtual override List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<ReferralUpdateDataWrapper>();
            }
            
            return this.records;
        }
    }
    
    public virtual class ReferralUpdateDataWrapper extends GNE_SFA2_S2S_Util.Record {
        protected String name;
        protected String actionDate;
        protected UserWrapper assignee;
        protected String status;
        protected String revisedCompletionDate;
        protected UnsolicitedRequestWrapper unsolicitedRequestData;
        protected List<ActionWrapper> actions;
        
        public ReferralUpdateDataWrapper() {}
        
        public virtual String getName() {
            return this.name;
        }
        
        public virtual DateTime getActionDate() {
            return parseDateTimeString(this.actionDate);
        }
        
        public virtual UserWrapper getAssignee() {
            return this.assignee;
        }
        
        public virtual String getStatus() {
            return this.status;
        }
        
        public virtual Date getRevisedCompletionDate() {
        	return parseDateString(this.revisedCompletionDate);
        }
        
        public virtual UnsolicitedRequestWrapper getUnsolicitedRequestData() {
            return this.unsolicitedRequestData;
        }
        
        public virtual List<ActionWrapper> getActions() {
            if(this.actions==null) {
                this.actions = new List<ActionWrapper>();
            }
            
            return this.actions;
        }
    }
    
    public virtual class UnsolicitedRequestWrapper {
        protected Boolean verified;
        protected UserWrapper verifiedBy;
        protected String verifiedDate;
        
        public UnsolicitedRequestWrapper() {}
        
        public virtual Boolean getVerified() {
            return this.verified==true;
        }
        
        public virtual UserWrapper getVerifiedBy() {
            return this.verifiedBy;
        }
        
        public virtual Date getVerifiedDate() {
            return parseDateString(this.verifiedDate);
        }
    }
    
    public virtual class ActionWrapper implements Comparable {
        protected String createdDate;
        protected String action;
        protected UserWrapper actor;
        protected UserWrapper assignee;
        protected String status;
        
        public ActionWrapper(DateTime createdDate, String action, UserWrapper actor, UserWrapper assignee, String status) {
            this.createdDate = GNE_SFA2_S2S_Util.formatDateTime(createdDate);
            this.action = action;
            this.actor = actor;
            this.assignee = assignee;
            this.status = status;
        }
        
        public ActionWrapper(DateTime cDate, String action, String actionBy, String assignedToId, String assignedTo, String assignedToProfile, String status) {
            this(cDate, action, new UserWrapper(null, actionBy, null), new UserWrapper(assignedToId, assignedTo, assignedToProfile), status);
        }
        
        public virtual DateTime getCreatedDate() {
            return parseDateTimeString(this.createdDate);
        }
        
        public virtual String getAction() {
            return this.action;
        }
        
        public virtual UserWrapper getActor() {
            return this.actor;
        }
        
        public virtual UserWrapper getAssignee() {
            return this.assignee;
        }
        
        public virtual String getStatus() {
            return this.status;
        }
        
        public Integer compareTo(Object other) {
            DateTime createdDate = getCreatedDate();
            DateTime otherCreatedDate = other!=null ? ((ActionWrapper)other).getCreatedDate() : null;
            Integer actionOrder = REFERRAL_WORKFLOW_ACTIONS_ORDER_MAP.get(getAction());
            Integer otherActionOrder = REFERRAL_WORKFLOW_ACTIONS_ORDER_MAP.get(((ActionWrapper)other).getAction());
            return createdDate==otherCreatedDate ? ((actionOrder!=null ? actionOrder : 0) - (otherActionOrder!=null ? otherActionOrder : 0)) : (createdDate<otherCreatedDate ? -1 : 1);
        }
    }
    
    public class InvalidReferralException extends Exception {
        private List<String> errorCodes;
        
        public InvalidReferralException(List<String> errorCodes) {
            setMessage(ERROR_REFERRAL_NOT_VALID_PREFIX + ': ' + errorCodesAsMessage(errorCodes));
            this.errorCodes = errorCodes;
        }
        
        private String errorCodesAsMessage(List<String> errorCodes) {
            List<String> errorMessages = new List<String>();
            Map<String,String> messagesMap = getErrorMessagesMap(errorCodes);
            
            for(String errorCode : errorCodes) {
                errorMessages.add(messagesMap.get(errorCode.toUpperCase()));
            }
            
            return String.join(errorMessages, '\n');
        }
    }
    
    public class AutoAssignmentFailedException extends Exception {
        public AutoAssignmentFailedException(Boolean arg) {
            this();
            String errorCode = GNE_SFA2_ReferralUtil.ERROR_CODE_AUTO_ASSIGNMENT_FAILED;
            setMessage(getErrorMessagesMap(new List<String>{errorCode}).get(errorCode.toUpperCase()));
        }
    }
}