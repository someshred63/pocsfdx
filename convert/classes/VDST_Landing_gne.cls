public class VDST_Landing_gne
{
/* Deprecated:
    public PageReference goToExternalLogin()
    {
        PageReference pr = new PageReference('/VDST_SiteLogin');
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference goToInternalLogin()
    {
        MAP<String,VDST_Settings__c> domains = VDST_Settings__c.getAll();
        String myDomain = '';
        for(VDST_Settings__c env_domain : domains.values()) 
        {
            if(env_domain.Site_Domain__c != null)
            {
                system.debug('---Site.getDomain()'+Site.getDomain() );
                system.debug('---env_domain.Site_Domain_gne__c'+env_domain.Site_Domain__c);
                if (env_domain.Site_Domain__c.contains(Site.getDomain()) )
                {
                    myDomain = env_domain.SSO_Domain__c;
                }
            }
        }
        PageReference pr = new PageReference('https://'+myDomain + '/apex/VDST_EventList');
        pr.setRedirect(true);
        return pr;
    }
*/
}