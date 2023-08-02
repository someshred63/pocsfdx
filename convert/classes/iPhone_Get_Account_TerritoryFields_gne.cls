/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of TSFs for the specified accounts.
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountTerritoryFields/*')
global with sharing class iPhone_Get_Account_TerritoryFields_gne {

	@HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, List<String> territoriesIds, Boolean enhDelta, String otrVersion) {
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountTerritoryFieldsResponseBuilder(territoriesIds),
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);
    }

	public without sharing class GetAccountTerritoryFieldsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {

		public List<String> territoriesIds {get;set;}

    	public GetAccountTerritoryFieldsResponseBuilder(List<String> territoriesIds) {
    		this.territoriesIds = territoriesIds;
    	}

		private Map<String, Id> territoryName2TerritoryIdMap;

		protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
			User user = iPhone_DAO.getUserByExternalId(args.unixId);
			List<Territory2> territories = iPhone_DAO.getTerritories(territoriesIds);
			List<String> territoriesName = iPhone_StringUtil.buildStringList(territories, 'Name');
			this.territoryName2TerritoryIdMap = buildTerritoryName2TerritoryIdMap(territories);
			return getTSFForTerritoriesNameAndAccountId(args.accountIds, territoriesName, user, args);
    }

    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		TSF_vod__c tsf = (TSF_vod__c)sObj;
			String territoryId = territoryName2TerritoryIdMap.get(tsf.Territory_vod__c.toUpperCase());
			return new GetAccountTerritoryFieldsRecord(territoryId, tsf);
    	}

    	private Map<String, Id> buildTerritoryName2TerritoryIdMap(List<Territory2> territories) {
			Map<String, Id> territoriesMap = new Map<String, Id>();
			for(Territory2 territory: territories) {
				territoriesMap.put(territory.Name.toUpperCase(), territory.Id);
			}
			return territoriesMap;
		}

		private List<TSF_vod__c> getTSFForTerritoriesNameAndAccountId(List<String> accountIds, List<String> territoriesName, User user, iPhone_Commons_gne.DeltaArgs args) {
			if (iPhone_REST_Utils.getOnlyTargetedAccounts() && GNE_SFA2_Util.isCanadaUser()){
        		List<String> filterConditions = new List<String>{
        			//' AND Account_vod__r.IsPersonAccount = false ',
        			' AND Account_vod__r.IsPersonAccount = true ' + GNE_SFA2_MyAccounts_Controller.getMyTargetAndTiersTsfQueryCondition(territoriesName)
        		};
        		List<TSF_vod__c> tsfs = new List<TSF_vod__c>();
        		for (String filterExt : filterConditions){
        			tsfs.addAll(getTSFForTerritoriesNameAndAccountId(accountIds, territoriesName, user, filterExt, args));
        		}
        		return tsfs;
        	} else {
        		return getTSFForTerritoriesNameAndAccountId(accountIds, territoriesName, user, null, args);
        	}
		}

		private List<TSF_vod__c> getTSFForTerritoriesNameAndAccountId(List<String> accountIds, List<String> territoriesName, User user, String additionalCondition, iPhone_Commons_gne.DeltaArgs args) {
			String query = String.format('SELECT Id, {0}, {1}, {2}, {3}, {4}, {5}, ' +
				'Address_vod__r.Name, Account_vod__r.{6}, LastModifiedDate, CreatedDate ',
					new String[] {
						String.valueOf(TSF_vod__c.My_Frequency_gne__c), 			// 0
						String.valueOf(TSF_vod__c.My_Target_vod__c),				// 1
						String.valueOf(TSF_vod__c.Planned_Frequency_can_gne__c),	// 2
						String.valueOf(TSF_vod__c.Territory_vod__c),				// 3
						String.valueOf(TSF_vod__c.Account_vod__c),					// 4
						String.valueOf(TSF_vod__c.Address_vod__c),					// 5
						String.valueOf(Account.Target__c)							// 6
					}
			);

			query += 'FROM TSF_vod__c ' +
				'WHERE Territory_vod__c in :territoriesName ' +
				'AND Account_vod__c in :accountIds ' +
				'AND Address_vod__c != null ' +
				'AND External_Id_vod__c != null ';

			if (iPhone_REST_Utils.getOnlyTargetedAccounts()) {
        query += 'AND My_Target_vod__c = true ';
      }

      if (iPhone_REST_Utils.getOnlyHCOSAccounts()){
        query += 'AND Account_vod__r.IsPersonAccount = false ';
      }

      DateTime lastSyncDt = args.getLastSyncDate();
      if(args.isEnhancedDelta()) {
        query += 'AND LastModifiedDate >= :lastSyncDt ';
      }

      if (String.isNotBlank(additionalCondition)){
        query += additionalCondition;
      }

      query += 'ORDER BY Account_vod__c';

			return Database.query(query);
		}
	}

	class GetAccountTerritoryFieldsRecord extends iPhone_Commons_gne.DeltaRecord {
		public String te; //territory id
		public String ai; //accountId
		public String tf; //target
		public String fq; //freq
		public String pf; //planned freq
		public String ta; //territory address
		public String mt; //account_vod__r.Target__c (new)

		public GetAccountTerritoryFieldsRecord(String territoryId, TSF_vod__c tsf) {
			this.te = territoryId;
			this.id = tsf.Id;
			this.ai = tsf.Account_vod__c;
			this.tf = iPhone_StringUtil.getString(tsf.My_Target_vod__c);   			// IsTargeted
			this.fq = iPhone_StringUtil.getString(tsf.My_Frequency_gne__c); 		// Frequency
			this.pf = iPhone_StringUtil.getString(tsf.Planned_Frequency_can_gne__c);// Planned Frequency
			this.ta = iPhone_StringUtil.getString(tsf.Address_vod__c); 				// Territory address
			this.mt = iPhone_StringUtil.getString(tsf.Account_vod__r.Target__c);
		}
	}
}