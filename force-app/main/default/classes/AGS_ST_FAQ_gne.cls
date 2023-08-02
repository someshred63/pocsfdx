public class AGS_ST_FAQ_gne
{
    public String faqs
    {
        get
        {
            return AGS_ST_DbUtils.getFAQ();
        }
        set;
    }

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