/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-10-10
*  Description: 
*  This is a singleton wrapper to custom settings object used by MPS
*  To access the custom setting use following line in your code:
*  GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Default_Portal_Address__c;
*  Modification History
*  Date        Name        Description
*  19.03.2012 # Wojciech Twardowski # added conveniece methods for easier/shorter access to custom settings with defaults 
*                
*************************************************************/
public class GNE_CM_MPS_CustomSettingsHelper 
{
	public static final String EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED = 'enabled';
	public static final String EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED = 'disabled';
	public static final String EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED_FOR_SELECTED = 'enabledForSelected';
	public static final String EBI_FUNCTIONALITY_FOR_REGISTRATION_DISABLED_FOR_SELECTED = 'disabledForSelected'; 
    public static final String CM_MPS_CONFIG = 'MPS_Configuration';
    public static final String ENV = 'DEV'; //wilczekk: the default environment name should always be DEV
    private static final Map<String,GNE_CM_MPS_Custom_Setting__c> settingsDefaults = new Map<String,GNE_CM_MPS_Custom_Setting__c>{
    	'mps_configuration' => new GNE_CM_MPS_Custom_Setting__c(
    		Name = CM_MPS_CONFIG,
    		Environment_name__c = ENV,
		    SetupOwnerId = UserInfo.getOrganizationId(),
		    Default_Portal_Address__c = 'https://gene.dev.cs12.force.com/ihcp/GNE_CM_MPS_Login',
		    NO_OF_RECORDS_LIMIT__c = 950,
		    MPS_Bookmark_URL__c = 'https://mps.gene.com/mypatientsolutions/home.jsp',
		    Submitted_Enrollment_Queue__c = 'Submitted Patient Enrollment Requests',
		    Recaptcha_Enabled__c = true,
		    Recaptcha_Secret__c = '6LfqqsUSAAAAAMewsP0UHMf0OtSktpts7tl-9Xqf',
		    Recaptcha_PublicKey__c = '6LfqqsUSAAAAAJhspF7brHcZR3bh2pXL9DpCeypZ',
		    Recaptcha_URL__c = 'http://api-verify.recaptcha.net/verify',
		    Footer_Home_Page_Unsecure_Link__c = 'http://www.genentechaccesssolutions.com/portal/site/AS/',
		    Activation_Email_Send_Interval__c = 7,
		    Activation_Email_Send_Period__c = 30,
		    Change_Profile_Site_URL__c = 'http://gene.dev.cs12.force.com',
		    Login_Attempt_Limit__c = 3,
		    Practice_Registration_Site_Guest_User_Id__c = '00570000001oTZP',
		    Multi_Portals_Confirm_Reset_Pwd_Template__c = 'GNE_CM_MPS_MULTI_PORTAL_CONFIRM_RESET_PASSWORD',
		    Multi_Portals_Reset_Pwd_Template__c = 'GNE_CM_MPS_MULTI_PORTAL_RESET_PASSWORD',
		    API_Host_URL__c = 'https://cs1.salesforce.com',
		    Confirm_Profile_Settings_Template__c = 'GNE_CM_MPS_CONFIRM_PROFILE_SETTINGS',
		    Confirm_Question_Settings_Template__c = 'GNE_CM_MPS_CONFIRM_QUESTION_SETTINGS',
		    Confirm_Reset_Password_Template__c = 'GNE_CM_MPS_CONFIRM_RESET_PASSWORD',
		    Convert_User_Both_Template__c = 'GNE_CM_MPS_CONVERT_BOTH',
		    Convert_User_Template__c = 'GNE_CM_MPS_CONVERT_USER',
		    Initial_Activation_Template__c = 'GNE_CM_MPS_INITIAL_ACTIVATION_EMAIL',
		    Lockout_Time_minutes__c = 15,
		    Multi_Portal_Activation_Template__c = 'GNE_CM_MPS_MULTI_PORTAL_ACTIVATION_EMAIL',
		    Reminder_Activation_Template__c = 'GNE_CM_MPS_REMINDER_ACTIVATION_EMAIL',
		    ReplyTo__c = 'mypatientsolutions_donotreply-d@gene.com',
		    Reset_Password_Link_Validity_Days__c = 7,
		    Reset_Password_Template__c = 'GNE_CM_MPS_RESET_PASSWORD', 
		    SenderDisplayName__c = 'My Patient Solutions',
		    WAC_address__c = 'https://mps-dev.gene.com/mypatientsolutions/',
		    EBI_Functionality_For_Registration_gne__c = EBI_FUNCTIONALITY_FOR_REGISTRATION_ENABLED_FOR_SELECTED
    	)
    };
    
    public static GNE_CM_MPS_Custom_Setting__c getSettings(String settingsName)
    {
    	if (settingsName == null || settingsName.trim() == '') {
    		settingsName = CM_MPS_CONFIG;
    	}
    	GNE_CM_MPS_Custom_Setting__c cs = GNE_CM_MPS_Custom_Setting__c.getInstance(settingsName);
    	if (cs == null) {
    		cs = GNE_CM_MPS_Custom_Setting__c.getInstance(settingsName.toLowerCase()); // Api versions prior to 21.0 use lower case names
    		if (cs == null) {
    			cs = setDefaults(settingsName.toLowerCase());
    		}
    	}
    	return cs;
    }
    
    public static GNE_CM_MPS_Custom_Setting__c getSettings()
    {
    	return getSettings(null);
    }
    
    private static GNE_CM_MPS_Custom_Setting__c setDefaults(String settingsName)
    {
    	GNE_CM_MPS_Custom_Setting__c cs;
    	settingsName = settingsName.toLowerCase();
    	if (settingsDefaults.containsKey(settingsName)) {
    		cs = settingsDefaults.get(settingsName);
    		upsert cs Name;
    	}
    	return cs;
    }
    
    public static void setDefaults()
    {
    	setDefaults(CM_MPS_CONFIG);
    }
    
    private static GNE_CM_MPS_CustomSettingsHelper self;
    
    // Nobody needs to construct it, a single reference will suffice.
    private GNE_CM_MPS_CustomSettingsHelper() 
    {     
    }
    
    public static GNE_CM_MPS_CustomSettingsHelper self() 
    {
        if (self != null) return self;
        
        // To create org wide defaults in new org automatically. This
        // will prevent NPE's in future.
        
        createCustomSettingsMPS(new String[]{CM_MPS_CONFIG});
        
        self = new GNE_CM_MPS_CustomSettingsHelper();
        return self;
    }
    
    // This method can be used to access the custom settings
    public Map<String, GNE_CM_MPS_Custom_Setting__c> getMPSConfig() 
    {   
        return GNE_CM_MPS_Custom_Setting__c.getall();
    }
    
    private static void createCustomSettingsMPS(List<String> names)
    {    	
        List<GNE_CM_MPS_Custom_Setting__c> settings = new List<GNE_CM_MPS_Custom_Setting__c>();
        for (String name : names)
        {
        	GNE_CM_MPS_Custom_Setting__c cs = GNE_CM_MPS_Custom_Setting__c.getInstance(name);
	    	if (cs == null) {
	    		String normalizedName = name.toLowerCase();
	    		cs = GNE_CM_MPS_Custom_Setting__c.getInstance(normalizedName); // Api versions prior to 21.0 use lower case names
	    		if (cs == null) {
	    			if (settingsDefaults.containsKey(normalizedName)) {
	    				settings.add(settingsDefaults.get(normalizedName));
	    			}
	    		}
	    	}
        }       
        upsert settings Name; 
        return;
    }
}