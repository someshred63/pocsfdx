/******************************************************************************************
*  @author: Waldemar Kaczor, Roche (contractor)
*  @email: waldemar.kaczor@contractors.roche.com
*  Created: 2018-08-01
*  Project: OTR2
*  Description: Returns a list of available Territories.
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAvailableTerritories/*')
global with sharing class iPhone_Get_Available_Territories_gne {

    private static final String GENE_STRING = 'GNE';
    private static final String ROCHE_STRING = 'RCanada';

	@HttpPost
	global static iPhone_Commons_gne.RestResponse processRequest(String unixId) {

		return iPhone_Commons_gne.buildResponse(
				new UserTerritoriesResponseBuilder(),
                new iPhone_Commons_gne.DefaultDeltaArgs(null, unixId)
		);

	}

    class UserTerritoriesResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

		public iPhone_Commons_gne.RestResponse build(Object args){

            iPhone_Get_Available_Territories_Helper availableTerritoriesHelper = new iPhone_Get_Available_Territories_Helper(args);
            return new RestRecordsResponse(availableTerritoriesHelper.getUserTerritoryRecordsList());

    	}

    }

    public abstract class iPhone_Get_Available_Territories_Helper_Base {

        private iPhone_Commons_gne.DefaultDeltaArgs deltaArgs {get; set;}
        private String unixId {get; set;}
        private User user {get; set;}
        private String userProfileName {get; set;}
        private String userAssociation {get; set;}
        private Boolean getChildRecords = false;

        private Map<String, String> profileNameToTerritoryDeveloperNameMap = new Map<String, String> {
                'GNE' => 'GNEUS',
                'RCanada' => 'ROCHECANADA'
        };

        private Set<Id> rootTerritoryIdsSet {get; set;}
        private Set<Id> parentTerritoryIdsSet {get; set;}
        private List<UserTerritoryRecord> userTerritoryRecordsList {get; set;}
        private List<Territory2> allAvailableTerritoriesList {get; set;}

        private abstract User getUser();
        private abstract String getProfileNameFromUser();
        private abstract String getUserAssociation();
        private abstract Map<Id, Territory2> getTerritoriesBasedOnProfileName();
        private abstract Set<Id> getTerritoriesIds();
        private abstract Set<Id> getRootTerritoryIds();
        private abstract List<Territory2> getAllAvailableTerritories();
        private abstract Boolean needToGetChildRecords(Set<Id> parentRecordIds);
        private abstract void filterOutTerritoryRecordsBasedOnUserAssociation();
        private abstract void findTerritoryRecordsBasedOnParentsIds();
        public abstract List<UserTerritoryRecord> getUserTerritoryRecordsList();

    }

    public class iPhone_Get_Available_Territories_Helper extends iPhone_Get_Available_Territories_Helper_Base {

        public iPhone_Get_Available_Territories_Helper(Object args) {

            this.userTerritoryRecordsList = new List<UserTerritoryRecord>();
            this.deltaArgs = (iPhone_Commons_gne.DefaultDeltaArgs)args;
            this.unixId = this.deltaArgs.unixId;
            this.user =  getUser();
            this.userProfileName = getProfileNameFromUser();
            this.userAssociation = getUserAssociation();
            this.rootTerritoryIdsSet = getRootTerritoryIds();
            this.allAvailableTerritoriesList = getAllAvailableTerritories();
            filterOutTerritoryRecordsBasedOnUserAssociation();

        }

        private override User getUser() {
            return iPhone_DAO.getUserByExternalId(this.unixId);
        }

        private override String getProfileNameFromUser() {
            return this.user.Profile_Name_gne__c;
        }

        private override String getUserAssociation() {
            return this.userProfileName.contains(GENE_STRING) ? GENE_STRING : this.userProfileName.contains(ROCHE_STRING) ? ROCHE_STRING : '';
        }

        private override Set<Id> getRootTerritoryIds() {
            return getTerritoriesIds();
        }

        private override Map<Id, Territory2> getTerritoriesBasedOnProfileName() {
            return new Map<Id, Territory2>(GNE_SFA2_Util.getTerritoriesBasedOnProfileName(this.profileNameToTerritoryDeveloperNameMap.get(this.userAssociation)));
        }

        private override Set<Id> getTerritoriesIds() {
            return getTerritoriesBasedOnProfileName().keySet();
        }

        private override List<Territory2> getAllAvailableTerritories() {
            return GNE_SFA2_Util.getAllAvailableTerritories();
        }

        private override Boolean needToGetChildRecords(Set<Id> parentRecordIds) {
            return !parentRecordIds.isEmpty();
        }

        private override void filterOutTerritoryRecordsBasedOnUserAssociation() {

            this.getChildRecords = needToGetChildRecords(rootTerritoryIdsSet);
            this.parentTerritoryIdsSet = this.rootTerritoryIdsSet;

            while(this.getChildRecords) {
                findTerritoryRecordsBasedOnParentsIds();
            }

        }

        private override void findTerritoryRecordsBasedOnParentsIds() {

            Set<Id> tmpParentTerritoryIdsSet = new Set<Id>();

            for(Territory2 terr : this.allAvailableTerritoriesList) {

                if(this.parentTerritoryIdsSet.contains(terr.ParentTerritory2Id)) {
                    this.userTerritoryRecordsList.add(new UserTerritoryRecord(terr));
                    tmpParentTerritoryIdsSet.add(terr.Id);
                }

            }

            this.parentTerritoryIdsSet.clear();
            this.parentTerritoryIdsSet = tmpParentTerritoryIdsSet;
            this.getChildRecords = needToGetChildRecords(this.parentTerritoryIdsSet);
        }

        public override List<UserTerritoryRecord> getUserTerritoryRecordsList() {
            return this.userTerritoryRecordsList;
        }
    }

	class UserTerritoryRecord extends iPhone_Commons_gne.RestRecord {

		public String nm {get; private set;}
		public String pid {get; private set;}

		public UserTerritoryRecord(Territory2 territoryRecord) {

			this.id = territoryRecord.id;
			this.nm = territoryRecord.Name;
            this.pid = territoryRecord.ParentTerritory2Id;

		}
	}

    public class RestRecordsResponse extends iPhone_Commons_gne.RestResponse{
    	public final List<iPhone_Commons_gne.RestRecord> records;

        public RestRecordsResponse(List<iPhone_Commons_gne.RestRecord> records) {
            this.records = records;
        }
    }

}