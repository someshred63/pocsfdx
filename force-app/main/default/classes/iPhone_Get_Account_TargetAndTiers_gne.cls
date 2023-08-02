/********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of TargetsAndTiers for the specified accounts.
*********************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountTargetAndTiers/*')
global with sharing class iPhone_Get_Account_TargetAndTiers_gne {

	@HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, List<String> accountIds, List<String> territoriesIds) {
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountTargetAndTiersResponseBuilder(territoriesIds),
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, accountIds)
    	);
    }

    class GetAccountTargetAndTiersResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {

    	public List<String> territoriesIds { get;set; }
    	public Id userId { get; set; }
    	public Map<Id, My_Setup_Products_vod__c> userSetupProducts { get; set; }

    	public GetAccountTargetAndTiersResponseBuilder(List<String> territoriesIds) {
    		this.territoriesIds = territoriesIds;
    		this.userId = UserInfo.getUserId();
    		this.userSetupProducts = getUserSetupProductsMap(this.userId);
    	}

    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		List<Id> productsIds = new List<Id>(this.userSetupProducts.keyset());
    		List<Territory2> territories = iPhone_DAO.getTerritories(territoriesIds);
			List<String> territoriesName = iPhone_StringUtil.buildStringList(territories, 'Name');
    		List<Targets_and_Tiers_can_gne__c> tntRows = iPhone_DAO.getTargetAndTiersByAccountIds(args.accountIds, territoriesName, productsIds);
			tntRows.addAll(getMissedTargetAndTiersRecords(userId, productsIds, territoriesIds, tntRows));
			return tntRows;
    	}

    	/* This method is being used to add Targets and tiers records if do not exist for user selected products */
    	private List<Targets_and_Tiers_can_gne__c> getMissedTargetAndTiersRecords(Id userId, List<Id> userProductsIds, List<String> selectedTerritoriesIds, List<Targets_and_Tiers_can_gne__c> tntRows){
    		List<Targets_and_Tiers_can_gne__c> result = new List<Targets_and_Tiers_can_gne__c>();

    		Set<String> userTerritoriesNamesUC = getUserFirstLevelTerritories(userId, selectedTerritoriesIds);
    		if (userProductsIds.isEmpty() || userTerritoriesNamesUC.size() == 0 || tntRows.isEmpty()){
    			return result;
    		}

    		Map<String, Set<Id>> tntToProductsMap = new Map<String, Set<Id>>();
			for (Targets_and_Tiers_can_gne__c tntRow : tntRows){
				if (String.isBlank(tntRow.Territory_gne__c) || !userTerritoriesNamesUC.contains(tntRow.Territory_gne__c.toUpperCase()) || String.isBlank(tntRow.Account_can_gne__c)){
					continue;
				}
				String externalId = getExternalId(tntRow);
				if (!tntToProductsMap.containsKey(externalId)){
					tntToProductsMap.put(externalId, new Set<Id>());
				}
				tntToProductsMap.get(externalId).add(tntRow.product_Catalog_gne__c);
			}

			List<Targets_and_Tiers_can_gne__c> toBeAdded = new List<Targets_and_Tiers_can_gne__c>();
			for (String tntRowExternalId : tntToProductsMap.keyset()){
				for (Id userProduct : userProductsIds){
					if (!tntToProductsMap.get(tntRowExternalId).contains(userProduct)){
						toBeAdded.add(new Targets_and_Tiers_can_gne__c(
                        	Account_can_gne__c = tntRowExternalId.Split('__')[0],
                        	Territory_gne__c = tntRowExternalId.Split('__')[1],
                        	Product_Catalog_gne__c = userProduct
						));
					}
				}
			}
			if (!toBeAdded.isEmpty()){
				insert toBeAdded;
				Map<Id, Targets_and_Tiers_can_gne__c> mapOfTnts = new Map<Id, Targets_and_Tiers_can_gne__c>(toBeAdded);
				result = iPhone_DAO.getTargetAndTiersByIds(new List<Id>(mapOfTnts.keyset()));
			}
			return result;
    	}

    	private Map<Id, My_Setup_Products_vod__c> getUserSetupProductsMap(Id userId){
    		Map<Id, My_Setup_Products_vod__c> productIdToMySetup = new Map<Id, My_Setup_Products_vod__c>();
    		for (My_Setup_Products_vod__c userProduct : [Select Id, Product_vod__r.id, CreatedDate, LastModifiedDate From My_Setup_Products_vod__c where OwnerId = :userId AND Product_vod__r.id != null]){
    			productIdToMySetup.put(userProduct.Product_vod__r.id, userProduct);
    		}
    		return productIdToMySetup;
    	}

    	private Set<String> getUserFirstLevelTerritories(Id userId, List<String> selectedTerritoriesIds){
    		Set<String> territoriesNames = new Set<String>();
    		for (Territory2 territory : [Select Name From Territory2 Where Id In (Select Territory2Id From UserTerritory2Association Where UserId = :userId) And Id In :selectedTerritoriesIds And Name != null]){
    			territoriesNames.add(territory.Name.toUpperCase());
    		}
    		return territoriesNames;
    	}

    	private String getExternalId(Targets_and_Tiers_can_gne__c tntRow){
    		return String.format('{0}__{1}',
    			new String[]{
    				tntRow.Account_can_gne__c,
    				tntRow.Territory_gne__c
    			}
    		);
    	}

    	protected override iPhone_Commons_gne.DeltaCalculator getDeltaCalculator(String lastSyncDate){
        	return new TargetAndTiersDeltaCalculator(lastSyncDate, userSetupProducts);
        }

    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountTargetAndTiersRecord((Targets_and_Tiers_can_gne__c)sObj);
    	}
    }

    class TargetAndTiersDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator{

    	private Map<Id, My_Setup_Products_vod__c> userSetupProducts { get; set; }

	    public TargetAndTiersDeltaCalculator(String lastSyncDate, Map<Id, My_Setup_Products_vod__c> userSetupProducts){
    		super(lastSyncDate);
    		this.userSetupProducts = userSetupProducts;
    	}

    	/* TO DO - compare by my setup roducts date created */
		protected override String getDeltaStatus(SObject sObj) {
            if(lastSynchronized == null) { // delta is OFF.
            	return null;
            }
            Datetime created = (Datetime)sObj.get('CreatedDate');
            Datetime lastModified = (Datetime)sObj.get('LastModifiedDate');
            Id productId = (Id)sObj.get('Product_Catalog_gne__c');

            if(created >= lastSynchronized || (userSetupProducts.containsKey(productId) && userSetupProducts.get(productId).CreatedDate >= lastSynchronized)) {
                return STAT_INSERT;     // created AFTER last synchronization.
            } else {
                if(lastModified >= lastSynchronized) {
                    return STAT_UPDATE; // created BEFORE last synchonization but updated AFTER last synchronization.
                } else {
                    return STAT_SYNC; // created and updated BEFORE last synchronization (is eXisting = already synchronized).
                }
            }
        }
	}

    class GetAccountTargetAndTiersRecord extends iPhone_Commons_gne.DeltaRecord {
    	public String ai; //(account id)
		public String pd; //(product id)
		public String tr; //(territory name)
		public String tg; //(target)
		public String sg; //(segment)
		public String ti; //(tier)
		public String mt; //(my target)
		public String pn; //(product name)

		public GetAccountTargetAndTiersRecord(Targets_and_Tiers_can_gne__c targetAndTiers) {
			this.id = targetAndTiers.Id;
			this.ai = iPhone_StringUtil.getString(targetAndTiers.Account_can_gne__c);
			this.pd = iPhone_StringUtil.getString(targetAndTiers.Product_Catalog_gne__c);
			this.pn = iPhone_StringUtil.getString(targetAndTiers.Product_Catalog_gne__r.Name);
			this.tr = iPhone_StringUtil.getString(targetAndTiers.Territory_gne__c);
			this.tg = iPhone_StringUtil.getString(targetAndTiers.Target_gne__c);
			this.sg = iPhone_StringUtil.getString(targetAndTiers.Segment_gne__c);
			this.ti = iPhone_StringUtil.getString(targetAndTiers.Tier_can_gne__c);
			this.mt = iPhone_StringUtil.getString(targetAndTiers.My_Target_gne__c);
		}
    }
}