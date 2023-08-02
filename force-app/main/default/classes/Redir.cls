public without sharing class Redir {

    public Boolean isChatterPolicyApproval {get; set;}
    public String sErrMessage {get; set;}
    public String maOrgUrl {get; set;}

    public Redir() {
        isChatterPolicyApproval = isChatterPolicyApproval();
        maOrgUrl = GNE_SFA2_S2S_Config_Items_gne__c.getInstance('MABaseUrl').Value_gne__c;
    }
    
    public PageReference TargetRedirect() {
        
        //Meddaffais override
        if(GNE_SFA2_S2S_Util.isFeatureEnabled('MeddfairsRedir') && GNE_SFA2_Util.isMedAffairsUser()){
            if(GNE_SFA2_S2S_Util.isFeatureEnabled('MeddfairsRedirAlert')){
                PageReference pr = Page.GNE_SFA2_MA_Redir;
                pr.setRedirect(true); 
                return pr;
            }else{
                return new PageReference(maOrgUrl);
            }
        }
        
        sErrMessage = 'TargetRedirect';
        String targetURL;
        String UserId = UserInfo.getUserId();
        sErrMessage = 'UserId:' + UserId;

        try {
            String mySFDCAppURL = ApexPages.currentPage().getParameters().get('mySFDCAppURL');
            if (String.isBlank(mySFDCAppURL)) {
                mySFDCAppURL = 'NONE';
            }
            System.debug('SFDC app URL passed on from b2b SSO = ' + mySFDCAppURL);
        } catch (Exception e) {
            System.debug(e);
        }
        
        List<User> userRedirct = [SELECT AGS_Redirect_Url__c, External_ID_gne__c FROM User WHERE Id =: UserId];
        System.debug('USER from redirect class' + UserId);

        try {
            targetURL = userRedirct[0].AGS_Redirect_Url__c;
            sErrMessage = 'targetURL:' + targetURL;
        } catch (Exception e) {
            System.debug(e);
        }

        if (String.isBlank(targetURL)) {
            targetURL = '/home/home.jsp';
        }

        // CRM override
        if (GNE_SFA2_Util.isCrmUser() || GNE_SFA2_Util.isFrmUser()) {
        	String appName = null;        	
        	String roleName = null;
        	if (GNE_SFA2_Util.isFrmUser()){ // MCCO FRM users
        		appName = 'MCCO';
        	} else if (GNE_SFA2_Util.isMccoCrmUser()){ // MCCO users
            	appName = 'MCCO CRM';
            } else if (GNE_SFA2_Util.isCCCrmUser() ) { // CC users
                appName = 'SFA-US';
                roleName = 'CC';
        	} else { // BAM users
        		appName = 'SFA-US';
        		roleName = 'BAM';
        	}        	
        	targetURL = [SELECT App_URL_gne__c FROM IC_Calc_Sales_Roster_gne__c WHERE Type_gne__c = :appName AND User_Role_gne__c = :roleName LIMIT 1].App_URL_gne__c;
            try{
                GNE_SFA2_User_App_Context_gne__c userContext = GNE_SFA2_Util.getUserApplicationContext();
                SFA2_User_Group_Mapping_gne__c ugm = [SELECT Application_gne__c, Brand_gne__c, Role_gne__c FROM SFA2_User_Group_Mapping_gne__c 
                	WHERE Application_gne__c = :appName AND Profile_Name_gne__c = :GNE_SFA2_Util.getCurrentUserProfileName() LIMIT 1];
                userContext.App_Name_gne__c = ugm.Application_gne__c;
                userContext.Brand_gne__c = ugm.Brand_gne__c;
                userContext.Role_gne__c = ugm.Role_gne__c;
                userContext.Run_in_SFA2_UI_gne__c = false;
                upsert userContext;
            } catch(Exception e){
                System.debug(e);       
            }
        }

        if (GNE_SFA2_Util.isCanadaINFUUser()) {
            targetURL = '/apex/EMS_Concur_Interaction_Connector';
        } else if (GNE_SFA2_Util.isSFA2UserForUI()) { // SFA2 override
            targetURL = '/apex/GNE_SFA2_Application_Dispatcher';
        }

        if(isChatterPolicyApproval) {
            PageReference pg = new PageReference(targetURL);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

    public Boolean isChatterPolicyApproval() {
        Boolean result = true;
        if(GNE_SFA2_Util.isMccoCrmUser() || GNE_SFA2_Util.isChatterUser() || GNE_SFA2_Util.isChatterFreeUser()) {
            result = [SELECT Chatter_Policy_Accepted__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].Chatter_Policy_Accepted__c;
        }
        return result;
    }

    @RemoteAction
    public static Boolean acceptChatterPolicy() {
        User user = [SELECT Chatter_Policy_Accepted__c, Chatter_Policy_Accepted_Date__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        user.Chatter_Policy_Accepted__c = true;
        user.Chatter_Policy_Accepted_Date__c = System.now();

        update user;
        return user.Chatter_Policy_Accepted__c;
    }
    
    public String getRedirInfo() {
    	String result;
    	if (GNE_SFA2_Util.isCanadaUser()){
    		result = System.Label.GNE_SFA2_MA_Redir_Canada;
    	} else {
    		result = System.Label.GNE_SFA2_MA_Redir;
    	}
    	return result;
    }
}