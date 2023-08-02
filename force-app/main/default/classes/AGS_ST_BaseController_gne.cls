public without sharing class AGS_ST_BaseController_gne {
    public static AGS_ST_Settings_gne__c stSettingPub { 
        get {
            if(Site.getDomain()!=null)
                return AGS_ST_Utils.getCustomSettingsInSite();
            else
                return AGS_ST_Utils.getCustomSettings();
        }
        private set;
    } 
}