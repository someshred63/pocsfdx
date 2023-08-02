public with sharing class GNE_MCCO_CRM_QlikView {

	public String dashboardUrl { get; set; }
	public Boolean isGiam { get; set; }

    public GNE_MCCO_CRM_QlikView() {
    	String env = getEnvironmentByUsername();
    	String key = 'GNE_MCCO_CRM_QlikView_Url';
    	String profileName = [ SELECT Id, Name from Profile WHERE Id = :UserInfo.getProfileId() ].Name;
        if (profileName.contains('340B')) {
            key = 'GNE_MCCO_CRM_340B_QlikView_Url';
        }
    	
    	dashboardUrl = getEnvironmentVariable(key, env);
    	isGiam = containsUserTerritoryCodes();
    }

    private static String getEnvironmentVariable(String key, String env) {
		try {
	    	return [ SELECT Environment__c, Key__c, Value__c
	    			 FROM Environment_Variables__c
	    			 WHERE Key__c = :key AND Environment__c = :env][0].Value__c;
		}
        catch (Exception ex)
        {
            return '';
        }
	}

    public static String getEnvironmentByUsername()
    {
        string userName = userinfo.getUserName();

	    if(userName.indexOf('.com.dev') > 0)
	        return 'dev';
	    else if(userName.indexOf('.com.sqa') > 0)
	        return 'sqa';
	    else if(userName.indexOf('.com.uat') > 0)
	        return 'uat';
	    else if(userName.endswith('.com'))
	        return 'prod';
	    else if(userName.indexOf('@gene.com.') >0)
	    	return userName.Substring(userName.indexOf('@gene.com.')+10, userName.length());
	    else return 'prod';
	}


	private static Boolean containsUserTerritoryCodes()
    {
    	Set<String> giamCodes = new Set<String>();
    	List<GNE_MCCO_CRM_GIAM_Codes__c> csGiamCodes = GNE_MCCO_CRM_GIAM_Codes__c.getall().values();
		for (GNE_MCCO_CRM_GIAM_Codes__c cs : csGiamCodes) {
			giamCodes.add(cs.Salesforce_Code__c + '/' + cs.Salesforce_SubTeam_Code__c);
		}

    	Territory2[] userTerrCodes = [
    		SELECT Id, Name, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
    		FROM Territory2
    		WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE isActive = true AND userId = :UserInfo.getUserId() )
    	];

		for (Territory2 t : userTerrCodes) {
			if (giamCodes.contains(t.Salesforce_Code_gne__c + '/' + t.Salesforce_SubTeam_Code_gne__c)) {
				return true;
			}
		}

    	return false;
    }
}