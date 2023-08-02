/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2011-09-27
*  Description:
*  This batch class processes Staging_User_Assignment_gne__c records and basing on Activaction_Date_gne__c and
*  Unalign_Date_gne__c fields, assigns Users to Territories or unassigns Uses from Territories.
*
*  Modification History
*  Date        Name                 Description
*  03.10.2011  Michal Szewczyk      Changes made to fields name
*  10.04.2012  Bartosz Osowiecki    Change in Scope query - checking only Activation Date
*  07-12-2013 Dominik Wasilewski    Added logic for setting Manager field on User object based on Manager_UnixID_gne__c
*  09-03-2013 Bartosz Osowiecki     Fix in executing DMLs
*  16-07-2014 Lukasz Bieniawski     Removed logic based on Manager_UnixID_gne__c (per SFA-784 point 5)
*  31-07-2019 Jaroslaw Laniecki     fix for duplicted record (SFA-3651)
*************************************************************/


global class GNE_UserToTerritoryAssignment_Batch extends GNE_Subscribe_Batch_Base implements Database.Batchable<SObject>, Database.Stateful {

    private static final String COMMENT_TERRITORY_NOT_FOUND = 'Input Data Error: Territory not found.';
    private static final String COMMENT_USER_NOT_FOUND = 'Input Data Error: User not found.';
    private static final String COMMENT_USER_NOT_ASSIGNED = 'Input Data Error: The user is not currently assigned to the given territory';
    private static final String BATCH_NAME = 'User To Territory Assignment';
    private static final String COMMENT_USER_ALREADY_ASSIGNED = 'User already assigned to territory.';
    private static final String DUPLICATE_RECORD = 'Duplicate record.';
    private static final String STATUS_ASSIGNED = 'Assigned';
    private static final String STATUS_OUTOFDATE = 'Out-of-date';

    private Map<String, Territory2> allTerritoriesMap = new Map<String, Territory2>();
    private Map<Id, Set<Id>> userToTerritoriesMap = new Map<Id, Set<Id>>();
    private List<Staging_User_Assignment_gne__c> allStagingUserAssignmentList = new List<Staging_User_Assignment_gne__c>();
    Map<Id, Staging_User_Assignment_gne__c> mapForQuickUpdate = new Map<Id, Staging_User_Assignment_gne__c>();

	private String userName;
	private String batchId;

	private Integer usersAssingedCount = 0;
	private Integer usersUnassingedCount = 0;
	private Integer assignmentsAlreadyExists = 0;
	private Integer validationErrorsCount = 0;
	private Integer errorsCount = 0;
	private Integer recordsCount = 0;
	private Integer duplicatesCount = 0;
	private Staging_User_Assignment_gne__c lastElementFromPreviousChunk;
    private List<ErrorWrapper> validationErrors = new List<ErrorWrapper>();
    private List<ErrorWrapper> runtimeErrors = new List<ErrorWrapper>();
    private static String myURL = URL.getSalesforceBaseUrl().getHost();
    
    private Map<String, List<Staging_User_Assignment_gne__c>> keyToStagingRecords;

    public GNE_UserToTerritoryAssignment_Batch(Boolean prev_mode, String userName) {
        previewMode = prev_mode;
        this.userName = userName;
    }

    protected override String getBatchName() {
        return BATCH_NAME;
    }

    global Database.QueryLocator start(Database.batchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, CreatedDate, Name, User_UnixID_gne__c, Territory_Key_gne__c, Activaction_Date_gne__c, Unalign_Date_gne__c, Status_gne__c,
                SFDC_User_gne__c, SFDC_UserTerritory_gne__c, Comment_gne__c, External_Id_gne__c
            FROM Staging_User_Assignment_gne__c
            WHERE Activaction_Date_gne__c <= TODAY 
                AND (Status_gne__c = 'Loaded' OR (Status_gne__c = 'Assigned' AND Unalign_Date_gne__c <= TODAY))
            ORDER BY User_UnixID_gne__c, Territory_Key_gne__c, LastModifiedDate DESC
        ]);
    }

    protected override void initCache(List<SObject> stgObjs) {
        super.initCache(stgObjs);
        for (User usr : [SELECT Id, Name, External_ID_gne__c, ManagerId FROM User WHERE External_ID_gne__c IN :stagingCache.keySet()]) {
            cacheTargetObject(usr);
        }
    }

    protected override String getKeyFromTargetObject(SObject targetObj) {
        return ((User)targetObj).External_ID_gne__c.toUpperCase();
    }

    protected override String getKeyFromStagingObject(SObject stgObj) {
        String key = ((Staging_User_Assignment_gne__c)stgObj).User_UnixID_gne__c;
        return String.isNotBlank(key) ? key.toUpperCase() : '';
    }
    /*
    If exists more than one record per pair (User + Territory) than newest record is processed others are marked as duplicate.
    Variable lastElementFromPreviousChunk is used to store information about last record processed between batch chunks.
    */
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
    	batchId = String.valueOf(bc.getJobId()) + '-' + String.valueOf(Datetime.now().getTime());
        List<Staging_User_Assignment_gne__c> stagingUserAssignmentList = (List<Staging_User_Assignment_gne__c>)scope;
        initCache(stagingUserAssignmentList);
       
        List<Staging_User_Assignment_gne__c> winnersStagingUserAssignmentList = new List<Staging_User_Assignment_gne__c>();
        List<Staging_User_Assignment_gne__c> forQuickUpdatestagingUserAssignmentList = new List<Staging_User_Assignment_gne__c>();
        cacheMapForProcess(scope);

        Set<Id> userIds = new Set<Id>();
    	Set<String> territoryNames = new Set<String>();
    	Set<Id> territoryIds = new Set<Id>();
    	Map<String, List<Staging_User_Assignment_gne__c>> userTerrToStagingUserAssignment = new Map<String, List<Staging_User_Assignment_gne__c>>();
        Set<Id> processedStagingUserAssignments = new Set<Id>();
		Set<Id> processedRecordsLevel1 = new Set<Id>();

        for (Staging_User_Assignment_gne__c stgUsrAsgnmt : stagingUserAssignmentList) {
            String uniqueKey = stgUsrAsgnmt.User_UnixID_gne__c +'_'+stgUsrAsgnmt.Territory_Key_gne__c;
            List<Staging_User_Assignment_gne__c> cachedRecords = keyToStagingRecords.get(uniqueKey);

            Staging_User_Assignment_gne__c winner;
            if(cachedRecords != null && !cachedRecords.isEmpty() ){
                winner = findWinner(cachedRecords);
             
                if(winner.CreatedDate > stgUsrAsgnmt.CreatedDate) {
                    cachedRecords.add(stgUsrAsgnmt);
                    proccessLosers(winner, cachedRecords, forQuickUpdatestagingUserAssignmentList);
                    stgUsrAsgnmt = winner;
                } else {
                    proccessLosers(stgUsrAsgnmt, cachedRecords, forQuickUpdatestagingUserAssignmentList);
                }
            }
            if(processedRecordsLevel1.contains(stgUsrAsgnmt.Id)) continue;
            winnersStagingUserAssignmentList.add(stgUsrAsgnmt);    
            processedRecordsLevel1.add(stgUsrAsgnmt.Id);

            clearStagingObjectComment(stgUsrAsgnmt);
            stgUsrAsgnmt.SFDC_User_gne__c = null;
            stgUsrAsgnmt.SFDC_UserTerritory_gne__c = null;
            territoryNames.add(stgUsrAsgnmt.Territory_Key_gne__c);
            String key = getKey(stgUsrAsgnmt);
            
            if (!userTerrToStagingUserAssignment.containsKey(key)) {
                userTerrToStagingUserAssignment.put(key, new List<Staging_User_Assignment_gne__c>());
            }
            if(!processedStagingUserAssignments.contains(stgUsrAsgnmt.Id)) {
                userTerrToStagingUserAssignment.get(key).add(stgUsrAsgnmt);
            }
            processedStagingUserAssignments.add(stgUsrAsgnmt.Id);
        }        

        // let's find incorrect input territories and users
        for (Territory2 territory : [SELECT Id, External_Id_gne__c FROM Territory2 WHERE External_Id_gne__c in :territoryNames]) {
            territoryIds.add(territory.Id);
            String upperCaseTerrExtId = territory.External_Id_gne__c.toUpperCase();
            if (!allTerritoriesMap.containsKey(upperCaseTerrExtId)) {
                allTerritoriesMap.put(upperCaseTerrExtId, territory);
            }
        }
        for (User user : (List<User>)targetCache.values()) {
            userIds.add(user.Id);
        }

        // query all UserTerritory records matching our User - Territory combination for further user
      	Map<String, Id> userTerritoryMap = new Map<String, Id>();
        for (UserTerritory2Association ut : [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association WHERE UserId IN :userIds AND Territory2Id IN :territoryIds]) {
            if (!userToTerritoriesMap.containsKey(ut.UserId)) {
            	userToTerritoriesMap.put(ut.UserId, new Set<Id>());
            }
            userToTerritoriesMap.get(ut.UserId).add(ut.Territory2Id);
            userTerritoryMap.put(ut.UserId + '_' + ut.Territory2Id, ut.Id);
        }

        List<Id> userTerritoriesToDelete = new List<Id>();
        List<UserTerritory2Association> userTerritoriesToCreate = new List<UserTerritory2Association>();

        Map<Integer, Staging_User_Assignment_gne__c> indexToStagingUsrAsgnmtForCreate = new Map<Integer, Staging_User_Assignment_gne__c>();
        Map<Integer, Staging_User_Assignment_gne__c> indexToStagingUsrAsgnmtForDelete = new Map<Integer, Staging_User_Assignment_gne__c>();
        
        Set<Id> processedRecordsLevel2 = new Set<Id>();
		for (Staging_User_Assignment_gne__c stgUsrAsgnmt : winnersStagingUserAssignmentList) {
            if(processedRecordsLevel2.contains(stgUsrAsgnmt.Id)) continue;

        	recordsCount++;
        	List<Staging_User_Assignment_gne__c> assigmentsPerUserAndTerritory = userTerrToStagingUserAssignment.get(getKey(stgUsrAsgnmt));
            
        	if (isMarkedAsProcessed(stgUsrAsgnmt)) {
        		continue;
        	}
        	if (lastElementFromPreviousChunk != null && getKey(stgUsrAsgnmt) == getKey(lastElementFromPreviousChunk)) {

        		for (Integer i = 0; i < assigmentsPerUserAndTerritory.size(); i++) {
        			markStagingObjectWithComment(stgUsrAsgnmt, DUPLICATE_RECORD);
        			markStagingObjectAsProcessedWitComment(assigmentsPerUserAndTerritory.get(i), DUPLICATE_RECORD + 'with '+assigmentsPerUserAndTerritory.get(0).Id);
        			duplicatesCount++;
        		}
        	} else if (assigmentsPerUserAndTerritory.size() > 1){                             
        		for (Integer i = 1; i < assigmentsPerUserAndTerritory.size(); i++) {
        			markStagingObjectWithComment(stgUsrAsgnmt, DUPLICATE_RECORD);
        			markStagingObjectAsProcessedWitComment(assigmentsPerUserAndTerritory.get(i), DUPLICATE_RECORD+ 'with '+assigmentsPerUserAndTerritory.get(0).Id);                    
        			duplicatesCount++;
        		}
        	}            

        	if (!isMarkedAsProcessed(stgUsrAsgnmt)) {
	            User user = (User)getTargetForStagingObject(stgUsrAsgnmt);

	            if (!allTerritoriesMap.containsKey(stgUsrAsgnmt.Territory_Key_gne__c.toUpperCase())) {
	                markStagingObjectWithError(stgUsrAsgnmt, COMMENT_TERRITORY_NOT_FOUND);
	            }

	            if (user == null) {
	                markStagingObjectWithError(stgUsrAsgnmt, COMMENT_USER_NOT_FOUND);
	            }
	            
	            if (!isMarkedAsError(stgUsrAsgnmt) && stgUsrAsgnmt.Unalign_Date_gne__c != null && stgUsrAsgnmt.Unalign_Date_gne__c <= Date.Today()) {
					if (!userToTerritoriesMap.containsKey(user.Id)) {
	                	markStagingObjectWithError(stgUsrAsgnmt, COMMENT_USER_NOT_ASSIGNED);
					} else if (!userToTerritoriesMap.get(user.Id).contains(allTerritoriesMap.get(stgUsrAsgnmt.Territory_Key_gne__c.toUpperCase()).Id)) {
						markStagingObjectWithError(stgUsrAsgnmt, COMMENT_USER_NOT_ASSIGNED);
					} else {
						indexToStagingUsrAsgnmtForDelete.put(userTerritoriesToDelete.size(), stgUsrAsgnmt);
						userTerritoriesToDelete.add(userTerritoryMap.get(user.Id + '_' + allTerritoriesMap.get(stgUsrAsgnmt.Territory_Key_gne__c.toUpperCase()).Id));

						if (previewMode) {
							markStagingObjectWithComment(stgUsrAsgnmt, 'User assignment to delete: ' + userTerritoryMap.get(user.Id + '_' + allTerritoriesMap.get(stgUsrAsgnmt.Territory_Key_gne__c.toUpperCase()).Id));
						} else {
							markStagingObjectAsProcessed(stgUsrAsgnmt);
						}
					}
				} else if (!isMarkedAsError(stgUsrAsgnmt) && stgUsrAsgnmt.Status_gne__c != STATUS_ASSIGNED) {
					stgUsrAsgnmt.SFDC_User_gne__c = user.Id;
	                stgUsrAsgnmt.SFDC_UserTerritory_gne__c = allTerritoriesMap.get(stgUsrAsgnmt.Territory_Key_gne__c.toUpperCase()).Id;
	                if (userToTerritoriesMap.containsKey(user.Id) && userToTerritoriesMap.get(user.Id).contains(allTerritoriesMap.get(stgUsrAsgnmt.Territory_Key_gne__c.toUpperCase()).Id)) {
	                	assignmentsAlreadyExists++;
	                	markStagingObjectWithComment(stgUsrAsgnmt, COMMENT_USER_ALREADY_ASSIGNED);
	                	if (!previewMode) {
	                		markStagingObjectAsProcessed(stgUsrAsgnmt, false);
	                	}
	                } else {
	                	indexToStagingUsrAsgnmtForCreate.put(userTerritoriesToCreate.size(), stgUsrAsgnmt);
	                	userTerritoriesToCreate.add(new UserTerritory2Association(UserId = stgUsrAsgnmt.SFDC_User_gne__c, Territory2Id = stgUsrAsgnmt.SFDC_UserTerritory_gne__c, RoleInTerritory2='JAMS'));
	                	if (previewMode) {
		        			markStagingObjectWithComment(stgUsrAsgnmt, 'User territory assignment to create.');
		                } else {
		                	markStagingObjectAsProcessed(stgUsrAsgnmt, false);
		                }
	                }	                
	            }

	            if (previewMode) {
	        		markStgObjectInPreviewMode(stgUsrAsgnmt);
                    
	        	}
	        	if (isMarkedAsError(stgUsrAsgnmt)) {
	        		system.debug('Validation error: '+ stgUsrAsgnmt);
	        		validationErrorsCount++;
                    ErrorWrapper ew = new ErrorWrapper(stgUsrAsgnmt);
                    validationErrors.add(ew);                    
	        	}
        	}
            processedRecordsLevel2.add(stgUsrAsgnmt.Id);
        }
        if (!winnersStagingUserAssignmentList.isEmpty()) {
        	lastElementFromPreviousChunk = winnersStagingUserAssignmentList.get(winnersStagingUserAssignmentList.size() - 1);
        }
        if (!previewMode) {
        	List<Database.DeleteResult> deleteResults = deleteUserTerritories(userTerritoriesToDelete);
	    	List<Database.SaveResult> createResults = createUserTerritories(userTerritoriesToCreate);
	    	Integer i = 0;
	    	for (Database.SaveResult re : createResults) {
	    		if (!re.isSuccess()) {
	    			errorsCount++;
	    			Staging_User_Assignment_gne__c stgUsrAsgnmt = indexToStagingUsrAsgnmtForCreate.get(i);
	    			for (Database.Error err : re.getErrors()) {
	    				String errorMsg = err.getStatusCode() + ' - ' + err.getMessage();
	    				markStagingObjectWithError(stgUsrAsgnmt, errorMsg);
	    			}
	    		} else {
	    			usersAssingedCount++;
	    		}
	    		i++;
	    	}

	    	i = 0;
	    	for (Database.DeleteResult re : deleteResults) {
	    		if (!re.isSuccess()) {
	    			errorsCount++;
	    			Staging_User_Assignment_gne__c stgUsrAsgnmt = indexToStagingUsrAsgnmtForDelete.get(i);
	    			List<Database.Error> errs = re.getErrors();
					for (Database.Error err : re.getErrors()) {
	    				String errorMsg = err.getStatusCode() + ' - ' + err.getMessage();
	    				markStagingObjectWithError(stgUsrAsgnmt, errorMsg);
					}
	    		} else {
	    			usersUnassingedCount++;
	    		}
	    		i++;
	    	}
        }
        
        allStagingUserAssignmentList.addAll(winnersStagingUserAssignmentList);
       
        for(Staging_User_Assignment_gne__c sua: forQuickUpdatestagingUserAssignmentList) {
            mapForQuickUpdate.put(sua.Id, sua);
        }
    }

    global void finish(Database.BatchableContext bc) {
        Map<Id, Staging_User_Assignment_gne__c> mapForUpdate = new Map<Id, Staging_User_Assignment_gne__c>();

        for(Staging_User_Assignment_gne__c sua: allStagingUserAssignmentList) {
            mapForUpdate.put(sua.Id, sua);
        }

    	executeDml(mapForUpdate.values(), GNE_Subscribe_Batch_Base.DmlType.STAGING_UPDATE);

        update mapForQuickUpdate.values();

    	String summary = 'Records processed: ' + recordsCount;
    	summary += '<BR>Already assigned users count: ' + assignmentsAlreadyExists;
    	summary += '<BR>Newly assigned users count: ' + usersAssingedCount;
    	summary += '<BR>Unassigned users count: ' + usersUnassingedCount;
    	summary += '<BR>Duplicate records count: ' + duplicatesCount;
    	summary += '<BR>Validation errors count: ' + validationErrorsCount;
    	summary += '<BR>Runtime errors count: ' + errorsCount;
        if(!validationErrors.isEmpty()) {
            summary += '<BR><BR>Validation errors:';
            summary += buildErrorTable(validationErrors);
        }
        if(!runtimeErrors.isEmpty()) {
            summary += '<BR><BR>Runtime errors:';
            summary += buildErrorTable(runtimeErrors);
        }
    	sendSummaryMail('GNE_UserToTerritoryAssignment_Batch', summary, true);
        doFinish(BC);
    }
    
    /**
     * 1. cache
     * 2. find winner by CreatedDate (the newest is winner) 
     * 3. make decision for skip or mark as /unassigned - for old and unasign date = today , error processing for older and unasign date <= today,
     */
    private void cacheMapForProcess(List<Staging_User_Assignment_gne__c> stagingUserAssignmentList) {
        keyToStagingRecords = new Map<String, List<Staging_User_Assignment_gne__c>>();
        Set<String> userKey = new Set<String>();
        Set<String> territoryKey = new Set<String>();
        for(Staging_User_Assignment_gne__c sua :stagingUserAssignmentList) {
            userKey.add(sua.User_UnixID_gne__c);
            territoryKey.add(sua.Territory_Key_gne__c);
        }
        for(Staging_User_Assignment_gne__c sua :[
            SELECT Id, Name, CreatedDate, User_UnixID_gne__c, Territory_Key_gne__c, Activaction_Date_gne__c, Unalign_Date_gne__c, Status_gne__c, SFDC_User_gne__c, SFDC_UserTerritory_gne__c, Comment_gne__c, External_Id_gne__c
            FROM Staging_User_Assignment_gne__c
            WHERE Territory_Key_gne__c IN :territoryKey
            	AND User_UnixID_gne__c IN :userKey
            	AND Status_gne__c IN ('Assigned', 'Loaded')  
                AND Activaction_Date_gne__c <= TODAY 
                //AND (Status_gne__c = 'Loaded' OR (Status_gne__c = 'Assigned' AND Unalign_Date_gne__c <= TODAY))
        ]){
            String uniqueKey = sua.User_UnixID_gne__c +'_'+sua.Territory_Key_gne__c;
            List<Staging_User_Assignment_gne__c> recordList = (keyToStagingRecords.get(uniqueKey) == null) ? new List<Staging_User_Assignment_gne__c>() : keyToStagingRecords.get(uniqueKey);
            recordList.add(sua);
            keyToStagingRecords.put(uniqueKey, recordList);            
        }        
    }
    
    private Staging_User_Assignment_gne__c findWinner(List<Staging_User_Assignment_gne__c> xstagingUserAssignmentList) {
        Staging_User_Assignment_gne__c winner;

        for(Staging_User_Assignment_gne__c sua : xstagingUserAssignmentList) {
            if(winner == null || sua.CreatedDate > winner.CreatedDate ) {
                winner = sua;
            }
        }
        
        return winner;
    }
    
    private void proccessLosers(Staging_User_Assignment_gne__c winner, List<Staging_User_Assignment_gne__c> losers, List<Staging_User_Assignment_gne__c> forQuickUpdatestagingUserAssignmentList) {
        for(Staging_User_Assignment_gne__c sua :losers) {
            if(winner.Id != sua.Id) {
                String oldStatus = sua.Status_gne__c;
                sua.Status_gne__c = STATUS_OUTOFDATE;
                sua.Comment_gne__c = 'Record replaced by newer record '+winner.Id;
                forQuickUpdatestagingUserAssignmentList.add(sua);
                if (previewMode) {
	        		markStgObjectInPreviewModeKeepOldStatus(sua, oldStatus);
	        	}
            }
        }        
    }   
    
    private void markStgObjectInPreviewModeKeepOldStatus(SObject stgObj, String oldStatus) {
        if(previewMode) {
            System.debug('markStgObjectInPreviewModeKeepOldStatus '+oldStatus);
            String comment = (String)stgObj.get(COMMENT_FIELD_API_NAME);
            String status = (String)stgObj.get(STATUS_FIELD_API_NAME);
            String previewComment = '[' + COMMENT_PREVIEW_MODE_PREFIX + ' Status:' + status + ']' + 
            (String.isBlank(comment) ? '' : COMMENT_PREVIEW_MODE_DELIMETER + comment);
            
            stgObj.put(COMMENT_FIELD_API_NAME, previewComment);
            stgObj.put(STATUS_FIELD_API_NAME, oldStatus);
        }
    }
      
    private String buildErrorTable(List<ErrorWrapper> errors) {
        String tableTxt = '<TABLE border="1" ><TH style="background:rgb(242,243,243)">Staging User Assignment ID</TH>'+
            '<TH style="background:rgb(242,243,243)">User Unix ID</TH><TH style="background:rgb(242,243,243)">Territory Key</TH><TH style="background:rgb(242,243,243)">Activaction Date</TH>'+
            '<TH style="background:rgb(242,243,243)">Unassignment Date</TH><TH style="background:rgb(242,243,243)">Status</TH><TH style="background:rgb(242,243,243)">Comment</TH>';
        for(ErrorWrapper ew : errors) {
            tableTxt += '<TR><TD><a href="https://'+myURL+'/'+ew.assignmentId+'">'+ew.name+'</a></TD><TD>'+ ew.userUnixId +'</TD><TD>'+ ew.territoryKey +'</TD><TD>'+ ew.activationDate +'</TD><TD>'+ ew.unassignmentDate +'</TD><TD>'+ ew.status+'</TD><TD>'+ ew.comment +'</TD></TR>';
        }
        tableTxt += '</TABLE>';
        return tableTxt;
    }

    private String getKey(Staging_User_Assignment_gne__c ua) {
    	return ua.User_UnixID_gne__c + '_' + ua.Territory_Key_gne__c;
    }
    /*
		Create UserTerritory2Association entries using soap api
	*/
	private List<Database.SaveResult> createUserTerritories(List<UserTerritory2Association> userTerritoriesToCreate) {
		List<Database.SaveResult> results = new List<Database.SaveResult>();
		if (userTerritoriesToCreate != null && userTerritoriesToCreate.size() > 0) {
			results = Database.insert(userTerritoriesToCreate, false);
		}
		return results;
	}

	/*
		Delete UserTerritory2Association entries using soap api
	*/
	private List<Database.DeleteResult> deleteUserTerritories(List<Id> userTerritoriesToDelete) {
		List<Database.DeleteResult> results = new List<Database.DeleteResult>();
		if (userTerritoriesToDelete != null && userTerritoriesToDelete.size() > 0) {
			results = Database.delete(userTerritoriesToDelete, false);
		}
		return results;
	}

    /*
		Prepare err log record
	*/
	private Error_Log_gne__c logError(String message, String method, String objName, String recordId) {
		Error_Log_gne__c err = new Error_Log_gne__c();
		err.Code_Type__c = 'Apex Batch Class';
		err.Error_Level_gne__c = 'Low';
		err.Error_Description__c = message;
		err.Object_Name__c = objName;
		err.Record_Id_gne__c = recordId;
		err.Snippet_Name__c = 'GNE_UserToTerritoryAssignment_Batch.' + method + '.batchId-' + batchId;
		err.User_Name__c = userName;
		return err;
	}
	
	protected override void markStagingObjectAsProcessed(SObject stgObj, Boolean clearComments) {
		Staging_User_Assignment_gne__c stgUsrAsgnmt = (Staging_User_Assignment_gne__c)stgObj;
		if (stgUsrAsgnmt.Unalign_Date_gne__c != null && stgUsrAsgnmt.Unalign_Date_gne__c > Date.Today()) {
			stgObj.put(STATUS_FIELD_API_NAME, STATUS_ASSIGNED);
			stgObj.put(COMMENT_FIELD_API_NAME, '');
		} else {
        	stgObj.put(STATUS_FIELD_API_NAME, STATUS_PROCESSED);
		}
        
        if (clearComments == true) {
            stgObj.put(COMMENT_FIELD_API_NAME, '');
        }
    }
    
    private void markStagingObjectAsProcessedWitComment(SObject stgObj, String comments) {
		Staging_User_Assignment_gne__c stgUsrAsgnmt = (Staging_User_Assignment_gne__c)stgObj;
        String errors = (String) stgUsrAsgnmt.get(Schema.Staging_User_Assignment_gne__c.Comment_gne__c);
		if (stgUsrAsgnmt.Unalign_Date_gne__c != null && stgUsrAsgnmt.Unalign_Date_gne__c > Date.Today()) {
			stgObj.put(STATUS_FIELD_API_NAME, STATUS_ASSIGNED);
            if(!errors.contains(comments))
			markStagingObjectWithComment(stgObj, comments);
		} else {
        	stgObj.put(STATUS_FIELD_API_NAME, STATUS_PROCESSED);
            if(!errors.contains(comments))
            markStagingObjectWithComment(stgObj, comments);
		}
    }
    
    class ErrorWrapper {
        String name;
        String assignmentId;
        String userUnixId;
        String territoryKey;
        String activationDate;
        String unassignmentDate;
        String status;
        String comment;        
        
        public ErrorWrapper(Staging_User_Assignment_gne__c record) {
            assignmentId = record.Id;
            name = record.Name;
            userUnixId= record.User_UnixID_gne__c;
            territoryKey = record.Territory_Key_gne__c;
            Date da = record.Activaction_Date_gne__c;
            if(da != null) activationDate = da.month() +'/' + da.day() +'/'+ da.year() ;
            Date du = record.Unalign_Date_gne__c;
            if(du != null) unassignmentDate = du.month() +'/' + du.day() +'/'+ du.year() ;
            status = record.Status_gne__c;
            comment = record.Comment_gne__c;            
        }
    }   
}