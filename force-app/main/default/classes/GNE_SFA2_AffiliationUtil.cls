public with sharing class GNE_SFA2_AffiliationUtil {
	
	public static Boolean isMyBrandCalculated(){
    	return isCalculatedByConfig(); // && hasActiveForMyBrandButton();
    }

    private static Boolean isCalculatedByConfig(){
		GNE_SFA2_Affiliation_Calculated_Profiles__c configWinner = null;
		for (GNE_SFA2_Affiliation_Calculated_Profiles__c profileConfig : getCalculatedProfiles()){
			if (configWinner == null || (configWinner != null && profileConfig.Name.length() > configWinner.Name.length())){
				configWinner = profileConfig;
			}
		}

		if (configWinner != null){
			return !configWinner.Except_Sharing_Calculation_gne__c;
		}

		return false;
    }

    private static List<GNE_SFA2_Affiliation_Calculated_Profiles__c> getCalculatedProfiles(){ 	
    	String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
    	List<GNE_SFA2_Affiliation_Calculated_Profiles__c> calculatedProfiles = new List<GNE_SFA2_Affiliation_Calculated_Profiles__c>();
    	for (GNE_SFA2_Affiliation_Calculated_Profiles__c profileConfig : GNE_SFA2_Affiliation_Calculated_Profiles__c.getAll().values()){
			if (profileName.startsWithIgnoreCase(profileConfig.Name)){
				calculatedProfiles.add(profileConfig);
			}
		}
		
		return calculatedProfiles;
    }

	public virtual class AffiliationWrapper {
		public String rid;
        public Id id;
        public Id fromAccountId;
        public Id toAccountId;
        public Id toContactId;
        public String type;
        public String role;
        public String influence;
        public Boolean activeForFRM;
        public String comments;

        public AffiliationWrapper() {}
        
        public AffiliationWrapper(String rid, Id id, Id fromAccountId, Id toAccountId, Id toContactId, String type, String role, String influence, Boolean activeForFRM, String comments) {
            this.rid = rid;
            this.id = id;
            this.fromAccountId = fromAccountId;
            this.toAccountId = toAccountId;
            this.toContactId = toContactId;
            this.type = type;
            this.role = role;
            this.influence = influence;
            this.activeForFRM = activeForFRM;
            this.comments = comments;
        }
    }

    public virtual class ResponseWrapper {
    	public String rid;
    	public String sfdcId;
    	public String status;
    	public String error;

    	public ResponseWrapper() {}

    	public ResponseWrapper(String rid, String sfdcId, String status, String error) {
    		this.rid = rid;
    		this.sfdcId = sfdcId;
    		this.status = status;
    		this.error = error;
    	}
    }
}