/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2013-06-18
*  Description: 
*  This is a singleton wrapper to custom settings object used by CM
*  To access the custom setting use following line in your code:
*  GNE_CM_CustomSettingsHelper.self().getCMConfig().EBI_Accept_Issue_List_View__c;
*  Modification History
*  Date        Name        Description
*                
*************************************************************/

public without sharing class GNE_CM_CustomSettingsHelper 
{
	public static final String CM_DEV_CONFIG = 'DEV';
    public static final String CM_SQA_CONFIG = 'SQA';
    public static final String CM_UAT_CONFIG = 'UAT';
    public static final String CM_PROD_CONFIG = 'PROD';
        
    private static GNE_CM_CustomSettingsHelper self;
    
    // Nobody needs to construct it, a single reference will suffice.
    private GNE_CM_CustomSettingsHelper() 
    {     
    }
    
    public static GNE_CM_CustomSettingsHelper self() 
    {
        if (self != null) return self;
        
        // To create org wide defaults in new org automatically. This
        // will prevent NPE's in future.
        
        createCustomSettingsCM(new String[]{CM_DEV_CONFIG, CM_SQA_CONFIG, CM_UAT_CONFIG, CM_PROD_CONFIG});
        
        self = new GNE_CM_CustomSettingsHelper();
        return self;
    }
    
    // This method can be used to access the custom settings
    public GNE_CM_Custom_Setting__c getCMConfig() 
    {
        Map<String, GNE_CM_Custom_Setting__c> allSettings = GNE_CM_Custom_Setting__c.getAll();
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
    
    private static void createCustomSettingsCM(List<String> names)
    {
        List<GNE_CM_Custom_Setting__c> settings = new List<GNE_CM_Custom_Setting__c>();
        for (String name : names)
        {
            //default DEV values:
            if (GNE_CM_Custom_Setting__c.getInstance(name) == null && name == CM_DEV_CONFIG) 
            {
                settings.add(new GNE_CM_Custom_Setting__c (
                	Name = name, 
                	EBI_Accept_Issue_List_View__c = 'My eBI Rule Issues',
                	EBI_Tx_Data_Cleanup_Treshold__c = 60,
                	EBI_Rule_Issue_Cleanup_Treshold__c = 30,
                	//EBI_Eligible_Profiles__c = 'GNE-CM-CASEMANAGER,GNE-CM-CRMANAGER,GNE-CM-CRSUPERVISOR,GNE-CM-INTAKE,GNE-CM-INTAKESUPERVISOR,GNE-CM-REIMBSPECIALIST'
 					Medical_Eligibility_Forbidden_ICD9_gne__c = '999.99'              
                ));         
            }            
                       
            //default SQA values:
            if (GNE_CM_Custom_Setting__c.getInstance(name) == null && name == CM_SQA_CONFIG) 
            {
            	settings.add(new GNE_CM_Custom_Setting__c (
            		Name = name, 
                	EBI_Accept_Issue_List_View__c = 'My eBI Rule Issues',
                	EBI_Tx_Data_Cleanup_Treshold__c = 60,
                	EBI_Rule_Issue_Cleanup_Treshold__c = 30,
                	//EBI_Eligible_Profiles__c = 'GNE-CM-CASEMANAGER,GNE-CM-CRMANAGER,GNE-CM-CRSUPERVISOR,GNE-CM-INTAKE,GNE-CM-INTAKESUPERVISOR,GNE-CM-REIMBSPECIALIST'
					Medical_Eligibility_Forbidden_ICD9_gne__c = '999.99'                
                ));          
            }
            
            //default UAT values:
            if (GNE_CM_Custom_Setting__c.getInstance(name) == null && name == CM_UAT_CONFIG) 
            {
                settings.add(new GNE_CM_Custom_Setting__c (
                	Name = name, 
                	EBI_Accept_Issue_List_View__c = 'My eBI Rule Issues',
                	EBI_Tx_Data_Cleanup_Treshold__c = 60,
                	EBI_Rule_Issue_Cleanup_Treshold__c = 30,
                	//EBI_Eligible_Profiles__c = 'GNE-CM-CASEMANAGER,GNE-CM-CRMANAGER,GNE-CM-CRSUPERVISOR,GNE-CM-INTAKE,GNE-CM-INTAKESUPERVISOR,GNE-CM-REIMBSPECIALIST'
                	Medical_Eligibility_Forbidden_ICD9_gne__c = '999.99'
                ));   
            }
            
            //default PROD values:
            if (GNE_CM_Custom_Setting__c.getInstance(name) == null && name == CM_PROD_CONFIG) 
            {
                settings.add(new GNE_CM_Custom_Setting__c (
                	Name = name, 
					//CBO_SCM_Server_URL__c = 'https://www.springcm.com',
                	EBI_Accept_Issue_List_View__c = 'My eBI Rule Issues',
                	EBI_Tx_Data_Cleanup_Treshold__c = 60,
                	EBI_Rule_Issue_Cleanup_Treshold__c = 30,
                	//EBI_Eligible_Profiles__c = 'GNE-CM-CASEMANAGER,GNE-CM-CRMANAGER,GNE-CM-CRSUPERVISOR,GNE-CM-INTAKE,GNE-CM-INTAKESUPERVISOR,GNE-CM-REIMBSPECIALIST'
                	Medical_Eligibility_Forbidden_ICD9_gne__c = '999.99'
                ));     
            }
        }
        if(settings.size() > 0) {       
            upsert settings Name; 
        }
        return;
    }
}