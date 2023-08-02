@RestResource(urlMapping='/iPhoneGetAccountMCEs/*')
global with sharing class iPhone_Get_Account_MCEs_gne extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
	private static Map<String,Set<Id>> teamsToTerrMap;

  @HttpPost
  global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, List<Id> territoryIds, Boolean enhDelta, String otrVersion) {
    return iPhone_Commons_gne.buildResponse(
	    new iPhone_Get_Account_MCEs_gne(),
	    new MceRequest(lastSyncDate, unixId, accountIds, territoryIds, enhDelta, otrVersion)
    );
  }

  protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
  	MceRequest request = (MceRequest)args;

  	teamsToTerrMap = new Map<String,Set<Id>>();
  	Set<String> teamCodes = new Set<String>();
  	Set<String> subTeamCodes = new Set<String>();

  	if(request.territoryIds!=null && !request.territoryIds.isEmpty()) {
	  	List<Territory2> terrs = iPhone_DAO.getTerritories(request.territoryIds);

	  	for(Territory2 terr : terrs) {
	  		teamCodes.add(terr.Salesforce_Code_gne__c);
	  		subTeamCodes.add(terr.Salesforce_SubTeam_Code_gne__c);
	  		String teamKey = (terr.Salesforce_Code_gne__c + ':' + terr.Salesforce_SubTeam_Code_gne__c).toLowerCase();

	  		if(!teamsToTerrMap.containsKey(teamKey)) {
	  			teamsToTerrMap.put(teamKey, new Set<Id>());
	  		}

	  		teamsToTerrMap.get(teamKey).add(terr.Id);
	  	}
  	}

    return args.isEnhancedDelta() ? iPhone_DeltaDAO.getMCEsByAccountIdsAndTeams(request.accountIds, teamCodes, subTeamCodes, args.getLastSyncDate()) : iPhone_DAO.getMCEsByAccountIdsAndTeams(request.accountIds, teamCodes, subTeamCodes);
  }

  protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    return new MceWrapper((MCE_gne__c)sObj);
  }

  private class MceRequest extends iPhone_Commons_gne.DefaultDeltaArgs implements iPhoneBase.RequestTestable2 {
  	private List<String> territoryIds;

  	private MceRequest(String lastSyncDate, String unixId, List<String> accountIds, List<Id> territoryIds, Boolean enhDelta, String otrVersion) {
  		super(lastSyncDate, unixId, accountIds, enhDelta, otrVersion);
  		this.territoryIds = territoryIds;
  	}

  	public void testRequest() {
      new iPhone_Get_Account_MCEs_gne().selectSObjects(this);
    }

    public System.Type getRequestType() {
      return MceRequest.class;
    }
  }

  private class MceWrapper extends iPhone_Commons_gne.DeltaRecord {
  	private Id aid;
  	private String brand;
  	private String team;
  	private String subTeam;
  	private String onLabel;
  	private List<Id> tids;

    private MceWrapper(MCE_gne__c mce) {
    	this.id = mce.id;
    	this.aid = mce.Account_gne__c;
    	this.team = iPhone_StringUtil.getString(mce.Team_Code_gne__c);
    	this.subTeam = iPhone_StringUtil.getString(mce.Subteam_Code_gne__c);
    	this.brand = iPhone_StringUtil.getString(mce.Brand_gne__c);
    	this.onLabel = iPhone_StringUtil.getString(mce.Onlabel_gne__c);

    	String teamKey = (mce.Team_Code_gne__c + ':' + mce.Subteam_Code_gne__c).toLowerCase();
    	this.tids = teamsToTerrMap.containsKey(teamKey) ? new List<Id>(teamsToTerrMap.get(teamKey)) : null;
    }
  }

}