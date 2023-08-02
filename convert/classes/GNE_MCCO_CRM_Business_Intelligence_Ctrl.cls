public with sharing class GNE_MCCO_CRM_Business_Intelligence_Ctrl {

    public String getQlikUrl(){
    	String environment = GNE_SFA2_Util.getEnvironment().toUpperCase();
        GNE_MCCO_CRM_Qlikview__c defaultValue = GNE_MCCO_CRM_Qlikview__c.getInstance('DEV');
    	GNE_MCCO_CRM_Qlikview__c qlikSetting;
    	
    	if(GNE_SFA2_Util.isFRMUser()){
    		defaultValue = GNE_MCCO_CRM_Qlikview__c.getInstance(environment);
    		qlikSetting = GNE_MCCO_CRM_Qlikview__c.getInstance('FRM_' + environment);
        } else { 
            qlikSetting = GNE_MCCO_CRM_Qlikview__c.getInstance(environment);
        }
        if(qlikSetting != null){
	        return qlikSetting.Qlikview_Url__c;
        } 
       	return defaultValue.Qlikview_Url__c;
    }
}