/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com
*  Created: 2013-05-24
*  Project: OTR2
*  Description: Returns a list of Territories for the specified user id (unixId).
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetUserTerritories/*')
global with sharing class iPhone_Get_User_Territories_gne {

	@HttpPost
     global static iPhone_Commons_gne.RestResponse processRequest(String unixId) {
    	return iPhone_Commons_gne.buildResponse(
	    		new UserTerritoriesResponseBuilder(),
	    		new iPhone_Commons_gne.DefaultDeltaArgs(null, unixId) // Can't use 'Delta' feature here (Territory object does not have CreatedDate field)
    	);
    }

    class UserTerritoriesResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

    	public iPhone_Commons_gne.RestResponse build(Object args){
    		iPhone_Commons_gne.DefaultDeltaArgs deltaArgs = (iPhone_Commons_gne.DefaultDeltaArgs)args;
    		User user = iPhone_DAO.getUserByExternalId(deltaArgs.unixId);
    		List<Territory2> userTerritories = GNE_SFA2_Util.getUserTerritories(user.id);

    		Set<String>terrNumbers = new Set<String>();
            Set<String>terrNames = new Set<String>();
    		for(Territory2 terr : userTerritories){
    			if(!String.isEmpty(terr.Territory_Number_gne__c)){
    				terrNumbers.add(terr.Territory_Number_gne__c);
    			}
                terrNames.add(terr.Name);
    		}
    		Map<String, Set<String>> terrNumberToZip = new Map<String, Set<String>>();
    		for(Zip_to_Territory_gne__c zipToTerr : iPhone_DAO.getZipToTerritory(terrNumbers)) {
    			if(!terrNumberToZip.containsKey(zipToTerr.Territory_Number_gne__c)){
    				terrNumberToZip.put(zipToTerr.Territory_Number_gne__c, new Set<String>());
    			}
    			terrNumberToZip.get(zipToTerr.Territory_Number_gne__c).add(zipToTerr.Zip_Code_gne__c);
    		}

            Map<String, Integer> terr2AccountSizeMap = new Map<String, Integer>();
            String query = 'select Territory_vod__c, count(id) accSize from TSF_vod__c where Territory_vod__c in :terrNames group by Territory_vod__c';
            for (sObject ter : Database.query(query)) {
                terr2AccountSizeMap.put(String.valueOf(ter.get('Territory_vod__c')), Integer.valueOf(ter.get('accSize')));
            }

    		List<UserTerritoryRecord> records = new List<UserTerritoryRecord>();
    		for(Territory2 terr : userTerritories){
    			if(String.isEmpty(terr.Territory_Number_gne__c)) {
    				records.add(new UserTerritoryRecord(terr, null, (terr2AccountSizeMap.containsKey(terr.Name) ? terr2AccountSizeMap.get(terr.Name) : 0)));
    			} else {
    				records.add(new UserTerritoryRecord(terr, terrNumberToZip.get(terr.Territory_Number_gne__c), (terr2AccountSizeMap.containsKey(terr.Name) ? terr2AccountSizeMap.get(terr.Name) : 0)));
    			}
    		}
    		return new DeltaRecordsResponse(records);
    	}
    }

    class UserTerritoryRecord extends iPhone_Commons_gne.DeltaRecord {
		public String nm; //(name)
		public Set<String> zc; //(zip codes)
		public String pid;
        public Integer ac;
        public String tc;
        public String stc;

		public UserTerritoryRecord(Territory2 territory, Set<String> zipCodes, Integer accountSize) {
			this.id = territory.Id;
			this.nm = territory.Name;
			this.zc = zipCodes;
            this.pid = territory.ParentTerritory2Id;
            this.ac = accountSize;
            this.tc = territory.Salesforce_Code_gne__c;
            this.stc = territory.Salesforce_SubTeam_Code_gne__c;
		}
    }

    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse{
    	public final List<DeltaRecord> records;

        public DeltaRecordsResponse(List<iPhone_Commons_gne.DeltaRecord> records) {
            this.records = records;
        }
    }
}