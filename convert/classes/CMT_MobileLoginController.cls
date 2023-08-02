global class CMT_MobileLoginController
{
    private static final String STANDARD_PASSWORD = 'zHJ7%w@KlL9_pQ#';
    private static final String EMAIL_SUFFIX = '-imeet';
    private static final String LOGIN_REDIRECT = null;
    //private static String BASE_SITE_URL;// = 'a--dev.dev.cs3.force.com/CommercialMeetingsLogin';
    private static final String CUSTOMER_PORTAL_ACCOUNT_NAME = 'Commercial Meeting Customer Portal Admin';
    
    global String serializedResult { get; private set; }
    
    global CMT_MobileLoginController()
    {
    	//CMT_Settings_gne__c settings = [SELECT LoginURL_gne__c FROM CMT_Settings_gne__c WHERE Name = 'CMT'];
    	//BASE_SITE_URL = settings.LoginURL_gne__c + '/CommercialMeetingsLogin';
    }
    
    /**
     * The valid URL to call this page is 'https://a--dev.dev.cs3.force.com/CommercialMeetingsLogin?email=vaihtoopiskelija@gmail.com'
     */
    global PageReference login()
    {   
        // read the username param
        String email = ApexPages.currentPage().getParameters().get('email');
        
        if (email == null || email == '')
        {
        	String errorMessage = 'The \'email\' parameter is missing - user cannot be logged in without any credentials';
        	this.serializedResult = JSON.serialize(new CMT_LoginErrorInfo(errorMessage));
        	return null;
        }
        
        String standardizedEmail = null;
        
        try
        {
        	standardizedEmail = convertEmailToCustomerPortalTemplate(email);
        }
        catch (CMT_Exception e)
        {
        	this.serializedResult = JSON.serialize(new CMT_LoginErrorInfo(e.getMessage()));
        	return null;
        }
        
        try
        {

        	// try to log in the user
        	PageReference pageRef = loginUser (standardizedEmail);
        	
        	// if login failed, try to create a new account
        	if (pageRef == null)
        	{
        		String newUserId = registerUser(standardizedEmail);
        		
        		// if user successfully created, try to log them in
        		if (newUserId != null)
        		{
        			pageRef = loginUser (standardizedEmail);
        		}
        	}
        	
        	// if pageRef is null, login or registration failed
        	if (pageRef != null)
        	{
				User u =[select Id from User where email=:standardizedEmail];        		
        		System.setPassword(u.id, STANDARD_PASSWORD);
        		pageRef = loginUser (standardizedEmail);

        		// return user info
        		this.serializedResult = JSON.serialize(new CMT_LoginUserInfo(standardizedEmail, STANDARD_PASSWORD));
        	}
        	else
        	{
        		// return error message
        		this.serializedResult = JSON.serialize(new CMT_LoginErrorInfo('Login/Registration failed'));
        	}
        }
        catch (Exception e)
        {
        	this.serializedResult = JSON.serialize(new CMT_LoginErrorInfo(e.getMessage()));
        }
        
        return null;
    }
    
    /** 
     * Converts an email address to a standard form of a Commercial Meetings Customer Portal user, by adding a suffix to the username
     * before the '@' character.
     */
    private String convertEmailToCustomerPortalTemplate (String email)
    {
    	String[] emailParts = email.split('@');
    	
    	if (emailParts.size() < 2)
    	{
    		throw new CMT_Exception('Invalid email address \'' + email + '\'');
    	}
    	
    	return emailParts[0] + EMAIL_SUFFIX + '@' + emailParts[1];
    }
    
    private PageReference loginUser (String email)
    {	
        return Site.login(email, STANDARD_PASSWORD, LOGIN_REDIRECT);
    }
    
    private static String registerUser (String sEmail)
    {
    	List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Commercial Meeting Customer Portal Admin' LIMIT 1];
    	if (accounts == null || accounts.isEmpty())
    	{
    		throw new CMT_Exception('Account for customer portal not found. Make sure the account exists and that you have access to query it.');
    	}
    	
    	Id customerPortalAccountId = accounts.get(0).Id;
    	
    	if (CMT_Config.CUSTOMER_PORTAL_REGISTRATION_ENABLED == false)
    	{
    		// change the email address to the default
    		sEmail = CMT_Config.DEFAULT_NEW_CUSTOMER_PORTAL_USER;	
    	}
        
        User u = new User();
        u.Username = sEmail;
        u.Email = sEmail;
        u.CommunityNickname = sEmail;
        
        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        try
        {
        	// NOTE: if user creation fails, make sure this method in invoked from a profile with a Guest User License.
        	// For this to happen, you must not be logged in/authenticated when executing this call.
        	return Site.createPortalUser(u, customerPortalAccountId, STANDARD_PASSWORD);
        }
        catch (Exception e)
        {
        	throw new CMT_Exception('Error registering user: \'' + e.getMessage() + '\'');
        }
        
        return null;
    }
    
    global static testMethod void testLoginRedirectUrl()
    {
    	System.assert(!LOGIN_REDIRECT.startsWith('http'));
    	System.assert(LOGIN_REDIRECT.startsWith('/'));
    }
}