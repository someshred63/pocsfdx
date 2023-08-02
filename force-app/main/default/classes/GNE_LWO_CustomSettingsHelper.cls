/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-10-10
*  Description: 
*  This is a singleton wrapper to custom settings object used by LWO
*  To access the custom setting use following line in your code:
*  GNE_LWO_CustomSettingsHelper.self().getLWOConfig().ESB_URL__c;
*  Modification History
*  Date        Name        Description
*                
*************************************************************/
public class GNE_LWO_CustomSettingsHelper
{
    public static final String LWO_DEV_CONFIG = 'DEV';
    public static final String LWO_SQA_CONFIG = 'SQA';
    public static final String LWO_UAT_CONFIG = 'UAT';
    public static final String LWO_PROD_CONFIG = 'PROD';
    public static final String LWO_ORD_CONFIG = 'ORD';
        
    private static GNE_LWO_CustomSettingsHelper self;
    
    // Nobody needs to construct it, a single reference will suffice.
    private GNE_LWO_CustomSettingsHelper() 
    {     
    }
    
    public static GNE_LWO_CustomSettingsHelper self() 
    {
        if (self != null) return self;
        
        // To create org wide defaults in new org automatically. This
        // will prevent NPE's in future.
        
        createCustomSettingsLWO(new String[]{LWO_DEV_CONFIG, LWO_SQA_CONFIG, LWO_UAT_CONFIG, LWO_PROD_CONFIG, LWO_ORD_CONFIG});
        
        self = new GNE_LWO_CustomSettingsHelper();
        return self;
    }
    
    // This method can be used to access the custom settings
    public GNE_LWO_Custom_Setting__c getLWOConfig() 
    {
        Map<String, GNE_LWO_Custom_Setting__c> allSettings = GNE_LWO_Custom_Setting__c.getAll();
        String env = getEnvironment();
        if (env == null || env == '')
        {
        	throw new GNE_CM_Exception('Environment name could not be retrieved');	
        }
        
        return allSettings.get(env.toUpperCase());      
    }
    
    public static String getEnvironment()
    {
       return GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;   
    }
    
    private static void createCustomSettingsLWO(List<String> names)
    {
        List<GNE_LWO_Custom_Setting__c> settings = new List<GNE_LWO_Custom_Setting__c>();
        for (String name : names)
        {
            //default DEV values:
            if (GNE_LWO_Custom_Setting__c.getInstance(name) == null && name == LWO_DEV_CONFIG) 
            {
                settings.add(new GNE_LWO_Custom_Setting__c (Name = name, 
                ESB_URL__c = 'http://commesb8-dev.gene.com',
                SUPPORT_EMAIL__c = 'lwo_cust_ops_testing-d@gene.com',
                CUSTOPS_EMAIL__c = 'lwo_cust_ops_testing-d@gene.com',
                SIMS_URL__c = 'https://extsimsit.gene.com/idm/ext/main.jsp?site=lwo',
                EMAIL_LUCENTIS_LOGO__c = 'http://122.180.105.99:8080/LucentisDirect/images/email-lucentis-logo.gif',
                EMAIL_LETSCONNECT_IMAGE__c = 'http://122.180.105.99:8080/LucentisDirect/images/email-letsconnect.gif',
                EMAIL_GENE_LOGO__c = 'http://122.180.105.99:8080/LucentisDirect/images/email-genentech-logo.gif',
                NUMBER_OF_RECORDS__c = '300'
                ));         
            }

            //default ORD values:
            if (GNE_LWO_Custom_Setting__c.getInstance(name) == null && name == LWO_ORD_CONFIG) 
            {
                settings.add(new GNE_LWO_Custom_Setting__c (Name = name, 
                ESB_URL__c = 'http://commesb8-dev.gene.com',
                SUPPORT_EMAIL__c = 'lwo_cust_ops_testing-d@gene.com',
                CUSTOPS_EMAIL__c = 'lwo_cust_ops_testing-d@gene.com',
                SIMS_URL__c = 'https://extsimsit.gene.com/idm/ext/main.jsp?site=lwo',
                EMAIL_LUCENTIS_LOGO__c = 'http://122.180.105.99:8080/LucentisDirect/images/email-lucentis-logo.gif',
                EMAIL_LETSCONNECT_IMAGE__c = 'http://122.180.105.99:8080/LucentisDirect/images/email-letsconnect.gif',
                EMAIL_GENE_LOGO__c = 'http://122.180.105.99:8080/LucentisDirect/images/email-genentech-logo.gif',
                NUMBER_OF_RECORDS__c = '300'
                ));         
            } 
                       
            //default SQA values:
            if (GNE_LWO_Custom_Setting__c.getInstance(name) == null && name == LWO_SQA_CONFIG) 
            {
                settings.add(new GNE_LWO_Custom_Setting__c (Name = name, 
                ESB_URL__c = 'http://commesb8-it.gene.com',
                SUPPORT_EMAIL__c = 'lwo_cust_ops_testing-d@gene.com',
                CUSTOPS_EMAIL__c = 'lwo_cust_ops_testing-d@gene.com',
                SIMS_URL__c = 'https://extsimsit.gene.com/idm/ext/main.jsp?site=lwo',                
                EMAIL_LUCENTIS_LOGO__c = 'http://lucentisdirect-qa.gene.com/LucentisDirect/images/email-lucentis-logo.gif',
                EMAIL_LETSCONNECT_IMAGE__c = 'http://lucentisdirect-qa.gene.com/LucentisDirect/images/email-letsconnect.gif',
                EMAIL_GENE_LOGO__c = 'http://lucentisdirect-qa.gene.com/LucentisDirect/images/email-genentech-logo.gif',
                NUMBER_OF_RECORDS__c = '300'
                ));         
            }
            
            //default UAT values:
            if (GNE_LWO_Custom_Setting__c.getInstance(name) == null && name == LWO_UAT_CONFIG) 
            {
                settings.add(new GNE_LWO_Custom_Setting__c (Name = name, 
                ESB_URL__c = 'http://commesb8-ua.gene.com',
                SUPPORT_EMAIL__c = 'lwo_cust_ops_testing-d@gene.com',
                CUSTOPS_EMAIL__c = 'lwo_cust_ops_testing-d@gene.com',
                SIMS_URL__c = 'https://extsimsval.gene.com/idm/ext/main.jsp?site=lwo',  
                EMAIL_LUCENTIS_LOGO__c = 'http://lucentisdirect-ua.gene.com/LucentisDirect/images/email-lucentis-logo.gif',
                EMAIL_LETSCONNECT_IMAGE__c = 'http://lucentisdirect-ua.gene.com/LucentisDirect/images/email-letsconnect.gif',
                EMAIL_GENE_LOGO__c = 'http://lucentisdirect-ua.gene.com/LucentisDirect/images/email-genentech-logo.gif',
                NUMBER_OF_RECORDS__c = '300'
                ));         
            }
            
            //default PROD values:
            if (GNE_LWO_Custom_Setting__c.getInstance(name) == null && name == LWO_PROD_CONFIG) 
            {
                settings.add(new GNE_LWO_Custom_Setting__c (Name = name, 
                ESB_URL__c = 'http://commesb8.gene.com',
                SUPPORT_EMAIL__c = 'lwo-support-d@gene.com',
                CUSTOPS_EMAIL__c = 'lwochange-d@gene.com',
                SIMS_URL__c = 'https://extsims.gene.com/idm/ext/main.jsp?site=lwo',  
                EMAIL_LUCENTIS_LOGO__c = 'http://www.lucentisdirect.com/LucentisDirect/images/email-lucentis-logo.gif',
                EMAIL_LETSCONNECT_IMAGE__c = 'http://www.lucentisdirect.com/LucentisDirect/images/email-letsconnect.gif',
                EMAIL_GENE_LOGO__c = 'http://www.lucentisdirect.com/LucentisDirect/images/email-genentech-logo.gif',
                NUMBER_OF_RECORDS__c = '300'
                ));         
            }
        }       
        upsert settings Name; 
        return;
    }
}