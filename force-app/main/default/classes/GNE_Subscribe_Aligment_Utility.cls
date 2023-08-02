public without sharing class GNE_Subscribe_Aligment_Utility {

	private static final String ACCOUNT_TYPE = 'ACCOUNT';
	private static final String ADDRESS_TYPE = 'ADDRESS';
	private static final String ERROR_TYPE = 'ERROR';

	private static final String STG_ALIGNMENT_NEW_STATE = 'Loaded';
	private static final String STG_ALIGNMENT_ERROR_STATE = 'Error Processing';
	private static final String STG_ALIGNMENT_SUCCESS_STATE = 'Processed';

	private static final String STG_ALIGNMENT_INVALID_TERR_STATE = 'Invalid Terr';
	private static final String STG_ALIGNMENT_DOUBLED_TERR_STATE = 'Doubled Terr';

	public static void alignAccountToTerritories (map<String,GNE_Subscribe_Metrics> subMetrics , Map<String,List<Staging_Alignment_gne__c>> stgAligmentData, GNE_Subscribe_Metrics subscribeMetrics)
	{
		Set<Id> accIds = new Set<Id>();
		Set<Id> groupTerrIds = new Set<Id>();
		Set<Id> terrIds = new Set<Id>();
		Set<String> terrNames = new Set<String>();
		List<AccountShare> accountShareToUpsert = new List<AccountShare>();
		List<AccountShare> accountShareToDelete= new List<AccountShare>();
		Map<String,Set<String>> mdmToTerritories = 	new Map<String,Set<String>>();
		Map<Id,List<AccountShare>> accIdToAccShare = new Map<Id,List<AccountShare>>();
		Map<String,Id> terrNamesToId = new Map<String,Id>();
		Map<Id,Id>  territoryIdToGroup = new Map<Id,Id>();
		Map<String,Account> mdmToAccount = new Map<String,Account>();
	 	List<Account> subscribedAcc = new List<Account>();
		List<Address_vod__c> subscribedAddress = new List<Address_vod__c>();
		List<Error_Log_gne__c> errorLog = new List<Error_Log_gne__c>();

		//get data from Metrics for Accounts and Addresses and Errors
		if(subMetrics.containsKey(ACCOUNT_TYPE))
			subscribedAcc = (List<Account>)subMetrics.get(ACCOUNT_TYPE).upsertList;
		if(subMetrics.containsKey(ADDRESS_TYPE))
			subscribedAddress = (List<Address_vod__c>)subMetrics.get(ADDRESS_TYPE).upsertList;
		if(subMetrics.containsKey(ERROR_TYPE))
			errorLog =(List<Error_Log_gne__c>)subMetrics.get(ERROR_TYPE).upsertList;

		// colect all Ids from upserted accounts
		for(Account tmpAcc : subscribedAcc)
		{
			accIds.add(tmpAcc.Id);
			System.debug('MICK XX :subscribedAcc :' + tmpAcc);
			// build map MDMtoAccount
			mdmToAccount.put(tmpAcc.MDMID_gne__c ,tmpAcc);
		}

		// get accounts territory aligments in order to unalign
		for(AccountShare tmpAccShare :[Select UserOrGroupId, RowCause, Id, AccountId From AccountShare where AccountId IN :accIds])
		{
			if(accIdToAccShare.containsKey(tmpAccShare.AccountId))
				accIdToAccShare.get(tmpAccShare.AccountId).add(tmpAccShare);
			else{
			    List<AccountShare> tmpAccs = new List<AccountShare>();
			    tmpAccs.add(tmpAccShare);
				accIdToAccShare.put(tmpAccShare.AccountId,tmpAccs);
			}
		}
		System.debug('MICK XX :accIdToAccShare:' + accIdToAccShare);

		// build list of territories store in Stg Aligment records  stgAligmentData structure - > (Map<String,List<Staging_Alignment_gne__c>> )
		System.debug('MICK XX :stgAligmentData.keySet(): ' + stgAligmentData.keySet());
		for(String tmpId : stgAligmentData.keySet())
		{
			if(stgAligmentData.containsKey(tmpId))
			{
				List<Staging_Alignment_gne__c> tmpStgRecords = stgAligmentData.get(tmpId);
				System.debug('MICK XX :tmpStgRecords' + tmpStgRecords);
				for(Staging_Alignment_gne__c tmpStg : tmpStgRecords)
				{
					System.debug('MICK XX :tmpStg' + tmpStg);
					if (tmpStg.Territory_Key_gne__c == null || tmpStg.Territory_Key_gne__c == '') {
						continue;
					}
					if(mdmToTerritories.containsKey(tmpId))
					{
						mdmToTerritories.get(tmpId).add(tmpStg.Territory_Key_gne__c);
					}
					else
					{
						Set<String> terrTmp = new Set<String>();
						terrTmp.add(tmpStg.Territory_Key_gne__c);
						mdmToTerritories.put(tmpId ,terrTmp);
					}
					terrNames.addAll(mdmToTerritories.get(tmpId));
				}
			}
		}
		System.debug('MICK XX :terrNames: ' + terrNames);
		System.debug('MICK XX :mdmToTerritories: ' + mdmToTerritories);
		for(String tmp : mdmToTerritories.keyset())
		{
			system.Debug('MICK XX: MDM ID - > ' + tmp +' Terr:' + mdmToTerritories.get(tmp));
		}


		// fetch all territories records which will be used in aligmnet
	    Map<Id,Territory2> territories = new Map<Id,Territory2>([SELECT source_gne__c, parent_external_id_gne__c, external_id_gne__c, Territory_Number_gne__c, ParentTerritory2Id, Name, Id
	    							   FROM Territory2
	    							   WHERE Name IN : terrNames]);
	    for(Territory2 tmpTerr :territories.values())
	    {
	    	terrNamesToId.put(tmpTerr.Name , tmpTerr.Id);
	    }

	    //build map to hold territory Id to Group Id
	    for(Group tmpGroup : [Select Type, RelatedId, Id From Group where Type = 'Territory' AND RelatedId IN :territories.keySet()])
	    {
	    	territoryIdToGroup.put(tmpGroup.RelatedId,tmpGroup.Id);
	    }

	    //check that stgAligment Data has valid territory
	    for(String tmpId : stgAligmentData.keySet())
		{
			if(stgAligmentData.containsKey(tmpId))
			{
				List<Staging_Alignment_gne__c> tmpStgRecords = stgAligmentData.get(tmpId);
				for(Staging_Alignment_gne__c tmpStg : tmpStgRecords)
				{
					if(tmpStg.Territory_Key_gne__c != null && tmpStg.Territory_Key_gne__c != '' && !terrNamesToId.containsKey(tmpStg.Territory_Key_gne__c))
					{
						tmpStg.Status_gne__c = STG_ALIGNMENT_INVALID_TERR_STATE;
					}
					if (terrNamesToId.containsKey(tmpStg.Territory_Key_gne__c) && territoryIdToGroup.containsKey(terrNamesToId.get(tmpStg.Territory_Key_gne__c)))
					{
						if(tmpStg.Unalign_Date_gne__c != null && tmpStg.Unalign_Date_gne__c <=  Date.Today())
						{
							// remove AccountShare records for subscribed Accounts
							System.debug('MICK XX :Unalign_Date_gne__c ' + tmpStg.Unalign_Date_gne__c);
							if(accIdToAccShare.containsKey(mdmToAccount.get(tmpStg.MDM_ID_gne__c).Id))
							{
								for(AccountShare tmpShare :accIdToAccShare.get(mdmToAccount.get(tmpStg.MDM_ID_gne__c).Id))
								{
									System.debug('MICK XX :check tmpShare fetched from DB :' +  tmpShare);
									if(tmpShare.UserOrGroupId ==  territoryIdToGroup.get(terrNamesToId.get(tmpStg.Territory_Key_gne__c)))
									accountShareToDelete.add(tmpShare);
								}
							}
						}
						else
						{	// create AccountShare records for subscribed Accounts
							tmpStg.SFDC_Group_gne__c = territoryIdToGroup.get(terrNamesToId.get(tmpStg.Territory_Key_gne__c));

							Boolean addNewShare = true;
							if(accIdToAccShare.containsKey(mdmToAccount.get(tmpStg.MDM_ID_gne__c).Id))
							{
								for(AccountShare tmpShare :accIdToAccShare.get(mdmToAccount.get(tmpStg.MDM_ID_gne__c).Id))
								{
									System.debug('MICK XX :check tmpShare fetched from DB :' +  tmpShare);
									if(tmpShare.UserOrGroupId ==  territoryIdToGroup.get(terrNamesToId.get(tmpStg.Territory_Key_gne__c))) {
										addNewShare = false;
										break;
									}
								}
							}
							if (addNewShare) {
								accountShareToUpsert.add(new AccountShare (UserOrGroupId = territoryIdToGroup.get(terrNamesToId.get(tmpStg.Territory_Key_gne__c)) ,
	    													   AccountId = mdmToAccount.get(tmpStg.MDM_ID_gne__c).Id,
	    													   AccountAccessLevel = ''));
							}
						}
					}
				}
			}
		}
 		/*
	    for(Account subTmpAcc :subscribedAcc)
	    {
	    	System.debug('MICK XX :subTmpAcc: ' + subTmpAcc);
	    	if(mdmToTerritories.containsKey(subTmpAcc.MDMID_gne__c))
	    	{
	    		Set<String> territoriesForAccount = mdmToTerritories.get(subTmpAcc.MDMID_gne__c);
	    		System.debug('MICK XX :territoriesForAccount: ' + territoriesForAccount);
	    		for(String terrName : territoriesForAccount)
	    		{
	    			if(terrNamesToId.containsKey(terrName))
	    			{
	    				if(territoryIdToGroup.containsKey(terrNamesToId.get(terrName)))
	    				{
	    					accountShareToUpsert.add(new AccountShare (UserOrGroupId = territoryIdToGroup.get(terrNamesToId.get(terrName)) ,
	    													   AccountId = mdmToAccount.get(subTmpAcc.MDMID_gne__c).Id,
	    													   AccountAccessLevel = ''));
	    				}
	    			}
	    		}
	    	}
	    }*/
	    System.debug('MICK XX :accountShareToUpsert.size: ' + accountShareToUpsert.size());
	    System.debug('MICK XX :accountShareToDelete.size: ' + accountShareToDelete.size());

	    System.debug('MICK XX :accountShareToUpsert: ' + accountShareToUpsert);
	    System.debug('MICK XX :accountShareToDelete: ' + accountShareToDelete);

	    Database.DeleteResult[] delResults = Database.delete(accountShareToDelete);
    	if (delResults != null) {
        	Integer iCount = 0;
        	for (Database.DeleteResult result : delResults) {
        		AccountShare accountShare = accountShareToDelete[iCount];

            	if (result.isSuccess()) {
            		GNE_Subscribe_Aligment_Utility.updateSubscribeMetrics(accountShare, GNE_Subscribe_Metrics.MetricTypeName.UNALIGN, subscribeMetrics);
            	}
            	iCount++;
        	}
    	}

	    Database.UpsertResult[] results = Database.upsert(accountShareToUpsert);
    	if (results != null) {
        	Integer iCount = 0;
        	for (Database.UpsertResult result : results) {
        		AccountShare accountShare = accountShareToUpsert[iCount];

            	if (!result.isSuccess()) {
                	GNE_Subscribe_Aligment_Utility.updateSubscribeMetrics(accountShare, GNE_Subscribe_Metrics.MetricTypeName.ERROR, subscribeMetrics);
            	} else {
            		GNE_Subscribe_Aligment_Utility.updateSubscribeMetrics(accountShare, GNE_Subscribe_Metrics.MetricTypeName.INSERT_UPDATE, subscribeMetrics);
            	}
            	iCount++;
        	}
    	}
	}

	public static void alignAccountToTSF(Map<String, GNE_Subscribe_Metrics> metricsMap , Map<String, List<Staging_Alignment_gne__c>> stagingAlignmentMap, GNE_Subscribe_Metrics subscribeMetrics) {
		System.debug('MICK XX alignAccountToTSF');
		Map<String, Account> mdmIdToAccount = new Map<String, Account>();
		Map<Id, List<TSF_vod__c>> accountIdToTSF = new Map<Id, List<TSF_vod__c>>();
		Map<Id, Account> accountIdToAccount = new Map<Id, Account>();
		Set<Id> accountIds = new Set<Id>();
	 	List<Account> subscribedAccount = new List<Account>();
		List<Address_vod__c> subscribedAddress = new List<Address_vod__c>();
		List<TSF_vod__c> TSFToUpsert = new List<TSF_vod__c>();
		List<TSF_vod__c> TSFToDelete = new List<TSF_vod__c>();
		Map<Id, TSF_vod__c> stgAlignmentToTSF = new Map<Id, TSF_vod__c>();

		//get data from Metrics for Accounts and Addresses
		if(metricsMap.containsKey(ACCOUNT_TYPE))
			subscribedAccount = (List<Account>)metricsMap.get(ACCOUNT_TYPE).upsertList;
		if(metricsMap.containsKey(ADDRESS_TYPE))
			subscribedAddress = (List<Address_vod__c>)metricsMap.get(ADDRESS_TYPE).upsertList;

		for(Account tmpAcc : subscribedAccount) {
			mdmIdToAccount.put(tmpAcc.MDMID_gne__c, tmpAcc);
			accountIdToAccount.put(tmpAcc.Id, tmpAcc);
			accountIds.add(tmpAcc.Id);
			System.debug('MICK XX mdmIdToAccount: ' + tmpAcc.MDMID_gne__c + ' => ' + tmpAcc.Id);
		}
		System.debug('MICK XX mdmIdToAccount size: ' + mdmIdToAccount.size());


		List<TSF_vod__c> accountsTSFList = [SELECT Id, Account_vod__c, My_Target_vod__c, Territory_vod__c, Zip_Code_gne__c, Aligment_Source_gne__c
											FROM TSF_vod__c
											WHERE Account_vod__c IN :accountIds];


		for(TSF_vod__c tsf : accountsTSFList) {
			if (!accountIdToTSF.containsKey(tsf.Account_vod__c)) {
				accountIdToTSF.put(tsf.Account_vod__c, new List<TSF_vod__c>());
			}
			accountIdToTSF.get(tsf.Account_vod__c).add(tsf);

			System.debug('MICK XX accountIdToTSF: ' + tsf.Account_vod__c + ' => ' + tsf.Territory_vod__c);
		}
		System.debug('MICK XX accountIdToTSF size: ' + accountIdToTSF.size());

		Map<String, Map<String, String>> mdmIdToTerrMsg = new Map<String, Map<String, String>>();
		Map<Id, Set<String>> uniqueTerritoryNamesMap = new Map<Id, Set<String>>();
		for(String mdmID : stagingAlignmentMap.keySet()) {
			Account account = mdmIdToAccount.get(mdmID);
			if (account == null) {
				continue;
			}
			List<TSF_vod__c> accountTSF = accountIdToTSF.get(account.Id);
			if (!uniqueTerritoryNamesMap.containsKey(account.Id)) {
				uniqueTerritoryNamesMap.put(account.Id, new Set<String>());
			}
			for (Staging_Alignment_gne__c stgAlignment : stagingAlignmentMap.get(mdmID)) {
				if (stgAlignment.Status_gne__c == STG_ALIGNMENT_INVALID_TERR_STATE) {
					if (stgAlignment.Comment_gne__c == null) {
						stgAlignment.Comment_gne__c = '';
					} else if (stgAlignment.Comment_gne__c != '') {
						stgAlignment.Comment_gne__c += ', ';
					}
					stgAlignment.Comment_gne__c += 'Invalid territory name';
					if (!mdmIdToTerrMsg.containsKey(mdmID)) {
	            		mdmIdToTerrMsg.put(mdmID, new Map<String, String>());
	            	}
					continue;
				}
				if (stgAlignment.Territory_Key_gne__c == null || stgAlignment.Territory_Key_gne__c == '') {
					continue;
				}
				String territory = stgAlignment.Territory_Key_gne__c;

				if (stgAlignment.Unalign_Date_gne__c != null && stgAlignment.Unalign_Date_gne__c <= date.today()) { // unalignment
					TSF_vod__c tsf = null;
					if (accountTSF != null && accountTSF.size() > 0) {
						for (TSF_vod__c oldTSF : accountTSF) {
							if (oldTSF.Territory_vod__c == territory) {
								tsf = oldTSF;
								break;
							}
						}
					}
					if (tsf != null) {
						TSFToDelete.add(tsf);
						System.debug('MICK XX unalign: mdmID:' + mdmID + ', territory:' + territory);
					} else {
						if (!mdmIdToTerrMsg.containsKey(mdmID)) {
							mdmIdToTerrMsg.put(mdmID, new Map<String, String>());
						}
						mdmIdToTerrMsg.get(account.MDMID_gne__c).put(territory, 'Account doesn\'t belong to this territory');
						System.debug('MICK XX unalign: mdmID:' + mdmID + ', territory:' + territory + 'Account doesn\'t belong to this territory');
					}
				} else {	//alignment
					if (uniqueTerritoryNamesMap.get(account.Id).add(territory)) {
						TSF_vod__c tsf = null;
						if (accountTSF != null && accountTSF.size() > 0) {
							for (TSF_vod__c oldTSF : accountTSF) {
								if (oldTSF.Territory_vod__c == territory) {
									tsf = oldTSF;
									break;
								}
							}
						}

						tsf = tsf!=null ? tsf : new TSF_vod__c(Account_vod__c = account.Id, Territory_vod__c = territory, My_Target_vod__c = false);

						if(stgAlignment.Target_gne__c!=null) {
							tsf.My_Target_vod__c = stgAlignment.Target_gne__c;
						}

						if(String.isNotBlank(stgAlignment.Zip_Code_gne__c)) {
							tsf.Zip_Code_gne__c = stgAlignment.Zip_Code_gne__c;
						}

						tsf.Aligment_Source_gne__c = String.isNotBlank(stgAlignment.Source_gne__c) ? stgAlignment.Source_gne__c : 'JAMS';
						stgAlignmentToTSF.put(stgAlignment.Id, tsf);
						System.debug('MICK XX tsf: mdmID:' + mdmID + ', territory:' + territory + ', target(' + stgAlignment.Target_gne__c + '):' + tsf.My_Target_vod__c);
						TSFToUpsert.add(tsf);
					} else {
						stgAlignment.Status_gne__c = STG_ALIGNMENT_DOUBLED_TERR_STATE;
						if (stgAlignment.Comment_gne__c == null) {
							stgAlignment.Comment_gne__c = '';
						} else {
							stgAlignment.Comment_gne__c += ', ';
						}
						stgAlignment.Comment_gne__c += 'Doubled territoryName for one MDM_ID';
						if (!mdmIdToTerrMsg.containsKey(mdmID)) {
		            		mdmIdToTerrMsg.put(mdmID, new Map<String, String>());
		            	}
					}
				}
			}
		}
        if (TSFToUpsert.size() > 0) {
			Database.UpsertResult[] results = Database.upsert(TSFToUpsert, false);
			if (results != null) {
	        	Integer iCount = 0;
	        	for (Database.UpsertResult result : results) {
	        		TSF_vod__c tsf = TSFToUpsert[iCount];
	        		Account account = accountIdToAccount.get(tsf.Account_vod__c);
	        		if (!result.isSuccess()) {
        				GNE_Subscribe_Aligment_Utility.updateSubscribeMetrics(tsf, GNE_Subscribe_Metrics.MetricTypeName.ERROR, subscribeMetrics);
        			} else {
        				GNE_Subscribe_Aligment_Utility.updateSubscribeMetrics(tsf, GNE_Subscribe_Metrics.MetricTypeName.INSERT_UPDATE, subscribeMetrics);
        			}
	        		if (account == null) {
	        			iCount++;
	        			continue;
	        		}
	        		if (!mdmIdToTerrMsg.containsKey(account.MDMID_gne__c)) {
	            		mdmIdToTerrMsg.put(account.MDMID_gne__c, new Map<String, String>());
	            	}
	            	if (!result.isSuccess()) {
	                	String errorMsg;
	                	Database.Error[] errs = result.getErrors();
	                	for(Database.Error err : errs)
	                    	errorMsg = errorMsg + ' | ' + err.getStatusCode() + ' - ' + err.getMessage();

	                	if (tsf.Id != null) {
	                    	errorMsg = 'TSF_ID:' + TSFToUpsert[iCount].Id + errorMsg;
	                	}

	                	mdmIdToTerrMsg.get(account.MDMID_gne__c).put(tsf.Territory_vod__c, errorMsg);
	                	System.debug('MICK XX mdmIdToTerrMsg: ' + account.MDMID_gne__c + ' => ' + tsf.Territory_vod__c + ' => ' + errorMsg);
	            	}
	            	iCount++;
	        	}
	    	}
        }
    	if (TSFToDelete.size() > 0) {
			Database.DeleteResult[] DR_Dels = Database.delete(TSFToDelete, false);
			if (DR_Dels != null) {
				Integer iCount = 0;
				for (Database.DeleteResult result : DR_Dels) {
					TSF_vod__c tsf = TSFToDelete[iCount];
					Account account = accountIdToAccount.get(tsf.Account_vod__c);
					if (result.isSuccess()) {
						GNE_Subscribe_Aligment_Utility.updateSubscribeMetrics(tsf, GNE_Subscribe_Metrics.MetricTypeName.UNALIGN, subscribeMetrics);
					}
					if (account == null) {
						iCount++;
						continue;
					}
					if (!mdmIdToTerrMsg.containsKey(account.MDMID_gne__c)) {
						mdmIdToTerrMsg.put(account.MDMID_gne__c, new Map<String, String>());
					}

					if (!result.isSuccess()) {
						String errorMsg;
						Database.Error[] errs = result.getErrors();
						for(Database.Error err : errs)
							errorMsg = errorMsg + ' | ' + err.getStatusCode() + ' - ' + err.getMessage();

						mdmIdToTerrMsg.get(account.MDMID_gne__c).put(tsf.Territory_vod__c, errorMsg);
						System.debug('MICK XX mdmIdToTerrMsg: ' + account.MDMID_gne__c + ' => ' + tsf.Territory_vod__c + ' => ' + errorMsg);
					}
					iCount++;
				}
			}
		}
    	for (String mdmId : mdmIdToTerrMsg.keySet()) {
			if (stagingAlignmentMap.containsKey(mdmId)) {

				for (Staging_Alignment_gne__c alignment : stagingAlignmentMap.get(mdmId)) {
					String comment = '';
					if (alignment.Status_gne__c == STG_ALIGNMENT_INVALID_TERR_STATE) {
						alignment.Status_gne__c = STG_ALIGNMENT_ERROR_STATE;
					} else if (alignment.Status_gne__c == STG_ALIGNMENT_DOUBLED_TERR_STATE) {
						alignment.Status_gne__c = STG_ALIGNMENT_ERROR_STATE;

						for (Staging_Alignment_gne__c tmpAlignment : stagingAlignmentMap.get(mdmID)) {
							if (tmpAlignment.Id != alignment.Id &&
								alignment.Territory_Key_gne__c == tmpAlignment.Territory_Key_gne__c &&
								tmpAlignment.SFDC_TSF_gne__c != null) {

								alignment.SFDC_TSF_gne__c = tmpAlignment.SFDC_TSF_gne__c;
								break;
							}
						}
					} else if (mdmIdToTerrMsg.get(mdmId).containsKey(alignment.Territory_Key_gne__c)) {
						comment = mdmIdToTerrMsg.get(mdmId).get(alignment.Territory_Key_gne__c);
						alignment.Status_gne__c = STG_ALIGNMENT_ERROR_STATE;
					} else {
						TSF_vod__c tsf = stgAlignmentToTSF.get(alignment.Id);
						if (alignment.Status_gne__c == STG_ALIGNMENT_NEW_STATE) {
							alignment.Status_gne__c = STG_ALIGNMENT_SUCCESS_STATE;
						}
						if (tsf != null) {
    						alignment.SFDC_TSF_gne__c = tsf.Id;
						}
					}
					if (comment != '') {
						if (alignment.Comment_gne__c == null || alignment.Comment_gne__c == '') {
							alignment.Comment_gne__c = comment;
						} else {
							alignment.Comment_gne__c += ', ' + comment;
						}
					}
				}
			}
		}
	}

	public static void processErrorLog(Map<String, String> ptyIdToMdmId, Map<String, String> ptyLocIdToMdmId, Map<String, GNE_Subscribe_Metrics> metricsMap , List<Staging_Alignment_gne__c> stagingAlignmentList) {
		System.debug('MICK XX processErrorLog metricsMap.containsKey(ERROR_TYPE):' + metricsMap.containsKey(ERROR_TYPE));
		if (metricsMap.containsKey(ERROR_TYPE)) {
			Map<String, String> addressMdmIdToMsg = new Map<String, String>();
			Map<String, String> accountMdmIdToMsg = new Map<String, String>();
			Map<String, Id> addressMdmIdToId = new Map<String, Id>();
			Map<String, Id> accountMdmIdToId = new Map<String, Id>();

			for (Error_Log_gne__c errorLog : (List<Error_Log_gne__c>)metricsMap.get(ERROR_TYPE).upsertList) {
				System.debug('MICK XX errorLog: ' + errorLog);
				String recordId = errorLog.Record_Id_gne__c;
				String addressMdmId = null;
				String accountMdmId = null;
				String msg = '';
				ID sID = null;
				if (recordId == null || recordId == '') {
					continue;
				}
				if (recordId.contains('PTY-')) { // ptyId
					msg = recordId;
					recordId = recordId.replace('PTY-', '');
					accountMdmId = ptyIdToMdmId.get(recordId);
					recordId = null;
				} else if (recordId.contains('PTYLOC-')) { // ptyLocId
					msg = recordId;
					recordId = recordId.replace('PTYLOC-', '');
					addressMdmId = ptyLocIdToMdmId.get(recordId);
					recordId = null;
				} else {
				    try{								// sfdcId
					   sID = recordId;
					   msg = 'ADDRESS_ID-' + recordId;
					} catch (System.StringException e){	// mdmId
						addressMdmId = recordId;
						msg = 'MDM_ADDRESS_ID-' + recordId;
						recordId = null;
					}
				}
				if (accountMdmId != null) {
					accountMdmIdToMsg.put(accountMdmId, msg);
					if (recordId != null) {
						accountMdmIdToId.put(accountMdmId, recordId);
					}
					System.debug('MICK XX accountMdmId: ' + accountMdmId + ', msg:' + msg);
				}
				if (addressMdmId != null) {
					addressMdmIdToMsg.put(addressMdmId, msg);
					if (recordId != null) {
 						addressMdmIdToId.put(addressMdmId, recordId);
					}
					System.debug('MICK XX addressMdmId: ' + addressMdmId + ', msg:' + msg);
				}
			}

			for (Staging_Alignment_gne__c alignment : stagingAlignmentList) {
				String comment = '';
				if (accountMdmIdToMsg.containsKey(alignment.MDM_ID_gne__c)) {
					alignment.Status_gne__c = STG_ALIGNMENT_ERROR_STATE;
					if (accountMdmIdToId.containsKey(alignment.MDM_ID_gne__c)) {
						alignment.SFDC_Account_gne__c = accountMdmIdToId.get(alignment.MDM_ID_gne__c);
					}
					comment = 'Invalid Account subscription: ' + accountMdmIdToMsg.get(alignment.MDM_ID_gne__c);
				}
				if (addressMdmIdToMsg.containsKey(alignment.MDM_Address_Id_gne__c)) {
					alignment.Status_gne__c = STG_ALIGNMENT_ERROR_STATE;
					if (addressMdmIdToId.containsKey(alignment.MDM_Address_Id_gne__c)) {
						alignment.SFDC_Address_gne__c = addressMdmIdToId.get(alignment.MDM_Address_Id_gne__c);
					}
					if (comment != '') {
						comment += ', ';
					}
					comment += 'Invalid Address subscription: ' + addressMdmIdToMsg.get(alignment.MDM_Address_Id_gne__c);
				}
				if (comment != '') {
					alignment.Comment_gne__c = comment;
				}
			}
		}
	}

	public static Map<String, GNE_Subscribe_Metrics> getMetricsMap(GNE_Subscribe_Metrics metrics) {
		System.debug('MICK XX : metrics ' + metrics);
    	Set<String> validTypes = new Set<String>{
    		ACCOUNT_TYPE,
    		ADDRESS_TYPE,
    		ERROR_TYPE
    	};
    	Map<String, GNE_Subscribe_Metrics> metricsMap = new Map<String, GNE_Subscribe_Metrics>();
    	for (GNE_Subscribe_Metrics record : metrics.relatedSubscribeMetrics) {
    		if (validTypes.contains(record.entityType.name())) {
    			if (record.entityType.name() == ADDRESS_TYPE && record.upsertList != null && record.upsertList.size() > 0) {
    				Set<Id> addressIds = new Set<Id>();
    				for (Address_vod__c address : (List<Address_vod__c>)record.upsertList) {
    					addressIds.add(address.Id);
    				}
    				record.upsertList = [Select Id, MDM_Address_Id_gne__c, Account_vod__c From Address_vod__c Where Id =: addressIds];
    			}
    			metricsMap.put(record.entityType.name(), record);
    		}
    	}
    	return metricsMap;
    }

    public static Map<String, List<Staging_Alignment_gne__c>> getStagingAlignmentMap(Map<String, GNE_Subscribe_Metrics> metricsMap, List<Staging_Alignment_gne__c> stagingAlignmentList) {
    	Map<String, List<Staging_Alignment_gne__c>> stagingAlignmentMap = new Map<String, List<Staging_Alignment_gne__c>>();

    	for (Staging_Alignment_gne__c stagingAlignment : stagingAlignmentList) {
    		stagingAlignment.SFDC_Account_gne__c = null;
    		stagingAlignment.SFDC_Address_gne__c = null;
    		stagingAlignment.SFDC_Group_gne__c = '';
    		stagingAlignment.SFDC_TSF_gne__c = null;
    		stagingAlignment.Comment_gne__c = '';

    		if (stagingAlignment.Status_gne__c == STG_ALIGNMENT_ERROR_STATE) {
    			continue;
    		}
			Boolean error = !(metricsMap.containsKey(ADDRESS_TYPE) && metricsMap.containsKey(ACCOUNT_TYPE));
			String accountId = '';
			String addressId = '';
			if (!error) {
				error = true;

				for (Account account : (List<Account>)metricsMap.get(ACCOUNT_TYPE).upsertList) {
					if (account.MDMID_gne__c == stagingAlignment.MDM_ID_gne__c) {
						accountId = account.Id;
						for (Address_vod__c address : (List<Address_vod__c>)metricsMap.get(ADDRESS_TYPE).upsertList) {
		    				if (address.MDM_Address_ID_gne__c == stagingAlignment.MDM_Address_Id_gne__c && address.Account_vod__c == account.id) {
		    					addressId = address.Id;
		    					error = false;
		    					break;
		    				}
		    			}
						break;
					}
				}

			}
			if (error) {
				if (accountId != '') {
					stagingAlignment.Status_gne__c = STG_ALIGNMENT_ERROR_STATE;
					stagingAlignment.SFDC_Account_gne__c = accountId;
    				stagingAlignment.Comment_gne__c = 'Account having ID: ' + accountId + ' does not have Address with MDM: ' + stagingAlignment.MDM_Address_Id_gne__c;
    				System.debug('AS XX comment ' + stagingAlignment.Comment_gne__c);
				} else {
					stagingAlignment.Status_gne__c = STG_ALIGNMENT_ERROR_STATE;
    				stagingAlignment.Comment_gne__c = 'Unable to subscribe account/address please contact gRemedy for support';
				}
				continue;
			}
    		String mdmId = stagingAlignment.MDM_ID_gne__c;

    		if (!stagingAlignmentMap.containsKey(mdmId)) {
    			stagingAlignmentMap.put(mdmId, new List<Staging_Alignment_gne__c>());
    		}
    		stagingAlignment.Status_gne__c = STG_ALIGNMENT_SUCCESS_STATE;
    		stagingAlignment.SFDC_Account_gne__c = accountId;
    		stagingAlignment.SFDC_Address_gne__c = addressId;
    		stagingAlignment.Comment_gne__c = '';
    		stagingAlignment.SFDC_Group_gne__c = '';
    		stagingAlignment.SFDC_TSF_gne__c = null;
    		stagingAlignmentMap.get(mdmId).add(stagingAlignment);
    	}

    	return stagingAlignmentMap;
    }

    /**
    * Updates subscribe statistics
    */
    static public void updateSubscribeMetrics(SObject obj, GNE_Subscribe_Metrics.MetricTypeName metricType, GNE_Subscribe_Metrics subscribeMetrics) {
        GNE_Subscribe_Metrics metricTemp = new GNE_Subscribe_Metrics();

        if (obj.getSObjectType() == Staging_Alignment_gne__c.sObjectType)
            metricTemp.entityType = GNE_Subscribe_Metrics.EntityTypeName.STAGING_ALIGNMENT;
        else if (obj.getSObjectType() == TSF_vod__c.sObjectType)
            metricTemp.entityType = GNE_Subscribe_Metrics.EntityTypeName.TSF;
        else if (obj.getSObjectType() == AccountShare.sObjectType)
            metricTemp.entityType = GNE_Subscribe_Metrics.EntityTypeName.ACCOUNT_SHARE;
        else
            metricTemp.entityType = GNE_Subscribe_Metrics.EntityTypeName.UNDEFINED;

        if (metricTemp.entityType != null) {
            if (metricType == GNE_Subscribe_Metrics.MetricTypeName.ERROR) {
                metricTemp.errorCount++;
            } else if (metricType == GNE_Subscribe_Metrics.MetricTypeName.UNALIGN) {
            	metricTemp.deleteCount++;
            } else {
                metricTemp.upsertCount++;
                metricTemp.upsertList.add(obj);
            }

            Integer i = 0;
            Boolean metricExists = false;
            subscribeMetrics.errorCount += metricTemp.errorCount;       // Increment totals
            subscribeMetrics.upsertCount+= metricTemp.upsertCount;      // Increment totals
            subscribeMetrics.deleteCount+= metricTemp.deleteCount;      // Increment totals
            List<GNE_Subscribe_Metrics> relatedMetricList = subscribeMetrics.relatedSubscribeMetrics;
            while ((i < relatedMetricList.size()) && (!metricExists)) {
                if (relatedMetricList[i].entityType == metricTemp.entityType)
                    metricExists = true;
                i++;
            }
            if (metricExists) {
                subscribeMetrics.relatedSubscribeMetrics[i-1].errorCount += metricTemp.errorCount;
                subscribeMetrics.relatedSubscribeMetrics[i-1].upsertCount+= metricTemp.upsertCount;
                subscribeMetrics.relatedSubscribeMetrics[i-1].deleteCount+= metricTemp.deleteCount;

                if (metricTemp.entityType != GNE_Subscribe_Metrics.EntityTypeName.UNDEFINED)                // Undefined metric contains statistics for unknown object types therefore update list is not maintained
                    subscribeMetrics.relatedSubscribeMetrics[i-1].upsertList.addAll(metricTemp.upsertList);

            } else {
                subscribeMetrics.relatedSubscribeMetrics.add(metricTemp);
            }
        }
    }
}