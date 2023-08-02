public without sharing class GNE_CM_PACT_Integration { 
 	public String username{ get; set; }
	public String password { get; set; }
	public String question { get; set; }
	public String answer { get; set; }
 	public Boolean invalidLogin { get; set; }
 	public Boolean resetSuccess { get; set; }
  	public String redirectURL  { get; set; }
  	public String sotRedirectURL  { get; set; }
  	public String registrationLink { get; set; }
  	public String sotRegistrationLink { get; set; }
	public Boolean inactive { get; set; }
	
    public String changeAnswersResponse { get { if (changeAnswersResponse == null) {changeAnswersResponse = 'false';} return changeAnswersResponse; } set; }
    public Boolean showErrors { get { if (showErrors == null) {showErrors = false;} return showErrors; } set; }
    
    public GNE_CM_PACT_Integration() {
    	this.redirectURL = GNE_CM_IHCP__c.getInstance().Redirect_URL__c;
    	this.sotRedirectURL = GNE_CM_IHCP__c.getInstance().SOT_Redirect_URL__c;
    	this.registrationLink = GNE_CM_IHCP__c.getInstance().Services_URL__c + '/PracticeRegistration';
    	this.sotRegistrationLink = GNE_CM_IHCP__c.getInstance().Services_URL__c + '/InfusionSiteRegistration';
		inactive = ApexPages.currentPage().getParameters().get('logoutReason') == 'inactive';
		resetSuccess = ApexPages.currentPage().getParameters().get('resetSuccess') == 'true';
    }
    
 	public PageReference login() {
 		PageReference result = null;
 		this.showErrors = false;
 		this.resetSuccess = false;
 		if (!String.isBlank(question) && !String.isBlank(answer) && !String.isBlank(username) && !String.isBlank(password)) {
 			List<GNE_CM_IHCP_User__c> ihcpUsers = [SELECT Id, SFDC_User__r.IsActive, MPS_Status__c, SOT_Status__c,
 													Security_Question_Answer_City_Of_Birth__c, Security_Question_Answer_City_Of_Job__c, Security_Question_Answer_Day_Of_Birth__c 
 													FROM GNE_CM_IHCP_User__c 
 													WHERE SFDC_User__r.Username = :username];
 			if (ihcpUsers.size() == 1) {
 				GNE_CM_IHCP_User__c user = ihcpUsers.get(0);
 				if (user.SFDC_User__r.IsActive && (user.MPS_Status__c == 'Approved' || user.SOT_Status__c == 'Approved') &&
 					((question.startsWith('City of birth') && answer.equalsIgnoreCase(user.Security_Question_Answer_City_Of_Birth__c)) || 
 					(question.startsWith('Day of birth') && answer.equalsIgnoreCase(user.Security_Question_Answer_Day_Of_Birth__c)) ||
	 				(question.startsWith('City of your first') && answer.equalsIgnoreCase(user.Security_Question_Answer_City_Of_Job__c)))) {
	 					
	 				String redirectTo = 'GNE_CM_PACT_Redirect';
	 				if (user.MPS_Status__c == 'Approved' && user.SOT_Status__c == 'Approved') {
	 					redirectTo = 'GNE_CM_PACT_Redirect';
	 				} else if (user.SOT_Status__c == 'Approved') {
	 					redirectTo = 'GNE_CM_PACT_SOT_Redirect';
	 				}	
 					result = Site.login(username, password, '/' + redirectTo);
 					if (result != null) {
 						result = result.setRedirect(true);
 					}
 				}
 			} 
 		}
 		invalidLogin = result == null;
		return result;
 	}
 	
 	public PageReference loginWithoutAnswers() {
 		this.changeAnswersResponse = 'false';
 		this.showErrors = true;
 		this.resetSuccess = false;
		if (!String.isBlank(username) && !String.isBlank(password)) {
 			List<GNE_CM_IHCP_User__c> ihcpUsers = [SELECT Id, SFDC_User__r.IsActive, MPS_Status__c, SOT_Status__c 
 													FROM GNE_CM_IHCP_User__c 
 													WHERE SFDC_User__r.Username = :username];
 			if (ihcpUsers.size() == 1) {
 				GNE_CM_IHCP_User__c user = ihcpUsers.get(0);
 				if (user.SFDC_User__r.IsActive && (user.MPS_Status__c == 'Approved' || user.SOT_Status__c == 'Approved')) {
 					if (Site.login(username, password, null) != null) {
 						List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id, Activation_Hash_Number__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :user.SFDC_User__c];
				    	if (mpsUsers.size() == 1) {
				    		mpsUsers.get(0).Activation_Hash_Number__c = GNE_CM_IHCP_Email_Utility.generateActivationHash(100); 
				    		update mpsUsers.get(0);
				    		this.changeAnswersResponse = Json.serialize(mpsUsers.get(0));
				    		this.showErrors = false;
				    	}
 					}
 				}
 			}
		}
		return null;
 	}
 
 	@RemoteAction
    public static Map<String, Object> getMpsUser(String mpsUserId, String hashCode) {
		List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id, Activation_Email_Sent_Date__c, First_name__c, Last_name__c, Email_address__c, Workflow_State__c
                                            FROM GNE_CM_MPS_User__c 
                                            WHERE Id = :mpsUserId AND Activation_Hash_Number__c = :hashCode 
                                            AND (Workflow_State__c = 'ACTIVATION_EMAIL_SENT' OR Workflow_State__c = 'ACTIVATION_LINK_EXPIRED')];
		Integer activationPeriod = (Integer)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Activation_Link_Validity_Days__c;
        Map<String, Object> result = new Map<String, Object>();
        Boolean isActivation = mpsUsers.size() == 1 && DateTime.now().addDays(-1 * activationPeriod) > mpsUsers.get(0).Activation_Email_Sent_Date__c;
        result.put('user', !isActivation && mpsUsers.size() == 1 ? mpsUsers.get(0) : null);
        result.put('isActivation', isActivation);
        return result;
    }
    
    @RemoteAction
    public static String updateMpsUser(GNE_CM_MPS_User__c mpsUser, String password, String cityOfBirth, Integer dayOfBirth, String cityOfYourFirstJob) {
    	try {
		 	Id sfdcUserId = [SELECT SFDC_User__c FROM GNE_CM_MPS_User__c WHERE Id = :mpsUser.Id].SFDC_User__c;
	        List<GNE_CM_IHCP_User__c> ihcpUsers = [SELECT Id, SOT_Status__c FROM GNE_CM_IHCP_User__c WHERE SFDC_User__c = :sfdcUserId];
	        if (ihcpUsers.size() == 1){
	            ihcpUsers.get(0).Security_Question_Answer_City_Of_Birth__c = cityOfBirth;
	            ihcpUsers.get(0).Security_Question_Answer_City_Of_Job__c = cityOfYourFirstJob;
	            ihcpUsers.get(0).Security_Question_Answer_Day_Of_Birth__c = String.valueOf(dayOfBirth);  
	            update ihcpUsers;
		        System.setPassword(sfdcUserId, password);
		        mpsUser.Workflow_State__c = 'ACTIVATED';    
		        update mpsUser;
		        GNE_CM_IHCP_PACT_Service.sendNotificationEmail(mpsUser.Id, ihcpUsers.get(0).SOT_Status__c == 'Approved');
		        GNE_CM_Webservice_UserAgreement.setUserAgreement(sfdcUserId);
	        } else {
	        	return 'Problem with IHCP User.';
	        }
    	} catch (Exception e){
    		return e.getMessage();
    	}
    	return null;
    }

    @RemoteAction
    public static boolean saveAuthQuestions(GNE_CM_MPS_User__c user, Integer dayOfBirth, String cityOfBirth, String cityOfYourFirstJob) {
    	GNE_CM_MPS_User__c databaseUser = [SELECT SFDC_User__c, Activation_Hash_Number__c FROM GNE_CM_MPS_User__c WHERE Id = :user.Id];
    	if (databaseUser.Activation_Hash_Number__c.equals(user.Activation_Hash_Number__c)) {
	        List<GNE_CM_IHCP_User__c> ihcpUsers = [SELECT Id FROM GNE_CM_IHCP_User__c WHERE SFDC_User__c = :databaseUser.SFDC_User__c];
	        if (ihcpUsers.size() == 1){
	        	ihcpUsers.get(0).Security_Question_Answer_City_Of_Birth__c = cityOfBirth;
	            ihcpUsers.get(0).Security_Question_Answer_City_Of_Job__c = cityOfYourFirstJob;
	            ihcpUsers.get(0).Security_Question_Answer_Day_Of_Birth__c = String.valueOf(dayOfBirth);
	            update ihcpUsers;
	            sendAccountAuthenticationAnswersHaveBeenUpdated(databaseUser.SFDC_User__c);
	            return true;  
	        }
    	}
        return false;
    }
    
    @RemoteAction
    public static CheckAnswers checkAnswers(String mpsUserId, String hashCode, String cityOfBirth, Integer dayOfBirth, String cityOfYourFirstJob) {
    	Id sfdcUserId = [SELECT SFDC_User__c FROM GNE_CM_MPS_User__c WHERE Id = :mpsUserId].SFDC_User__c;
        List<GNE_CM_IHCP_User__c> ihcpUsers = [SELECT Id, SFDC_User__r.Email, Security_Question_Answer_City_Of_Birth__c, Security_Question_Answer_City_Of_Job__c, Security_Question_Answer_Day_Of_Birth__c FROM GNE_CM_IHCP_User__c WHERE SFDC_User__c = :sfdcUserId];
       	CheckAnswers result = new CheckAnswers();
       	result.result = false;
       	if (ihcpUsers.size() == 1){
	        integer c = (ihcpUsers.get(0).Security_Question_Answer_City_Of_Birth__c == cityOfBirth) ? 1 : 0;
	        c = (ihcpUsers.get(0).Security_Question_Answer_City_Of_Job__c == cityOfYourFirstJob) ? c + 1 : c;
	        c = (ihcpUsers.get(0).Security_Question_Answer_Day_Of_Birth__c == String.valueOf(dayOfBirth)) ? c + 1 : c;	
	        result.result = c > 1;
	        result.email = ihcpUsers.get(0).SFDC_User__r.Email;
	    }
    	return result;
    }
    
    @RemoteAction
    public static boolean savePassword(String mpsUserId, String hashCode, String password) {
	 	List<GNE_CM_MPS_User__c> mpsUsers = [SELECT SFDC_User__c, Reset_Password_Email_Sent_Date__c FROM GNE_CM_MPS_User__c WHERE Id = :mpsUserId and Activation_Hash_Number__c = :hashCode];
        if (mpsUsers.size() == 1 && system.now().addDays(-7) < mpsUsers.get(0).Reset_Password_Email_Sent_Date__c){
	        System.setPassword(mpsUsers.get(0).SFDC_User__c, password);
	        sendResetPasswordConfirmation(mpsUsers.get(0).SFDC_User__c);
	        return true;
        }
    	return false;
    }
        
    @RemoteAction
    public static boolean resetPassword(String email) {
    	List<GNE_CM_IHCP_User__c> ihcpUsers = [SELECT Id, SFDC_User__c FROM GNE_CM_IHCP_User__c WHERE SFDC_User__r.Email = :email];
 		if (ihcpUsers.size() == 1) {
 			ID sfdcUserId = ihcpUsers.get(0).SFDC_User__c;
	    	List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id, Activation_Hash_Number__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :sfdcUserId];
		    if (mpsUsers.size() == 1) {
		    	mpsUsers.get(0).Activation_Hash_Number__c = GNE_CM_IHCP_Email_Utility.generateActivationHash(100);
		    	mpsUsers.get(0).Reset_Password_Email_Sent_Date__c = System.now(); 
		    	update mpsUsers.get(0);
		    	sendResetPasswordEmail(ihcpUsers.get(0).SFDC_User__c);
		    }
 			return true;
 		}											
		return false;
    }
        
    @future
    private static void sendResetPasswordEmail(Id sfdcUserId) {
    	GNE_CM_MPS_User__c mpsUser = [SELECT First_name__c, Last_name__c, Activation_Server__c, Activation_Hash_Number__c, Email_address__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :sfdcUserId LIMIT 1];
    	String body = '<p>Dear ${name},</p>'+
		'<p>Please click on the following to reset your account password:</p>'+
		'<p><a href="${link}">Reset Your Password</a></p>'+
		'<p>Your password is shared across all secure Genentech websites for Health Care Providers. Once you have completed the password change please use your new password to access these websites.</p>'+
		'<p>Please reset your password within 7 calendar days of receiving this message, after which the link will expire. If that occurs, or if you have any questions, please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p>'+
		'<p>Thank you,</p>'+
		'<p>Genentech Access Solutions</p>';
		body = body.replace('${name}', mpsUser.First_name__c + ' ' + mpsUser.Last_name__c);
       	body = body.replace('${link}', mpsUser.Activation_Server__c + '/GNE_CM_PACT_Reset#!/' + mpsUser.Id + '/'  + mpsUser.Activation_Hash_Number__c + '/authQuestions');
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { mpsUser.Email_address__c });
        mail.setSubject('My Patient Solutions password reset link');
        mail.setSenderDisplayName('My Patient Solutions');                          
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    @future
    private static void sendResetPasswordConfirmation(Id sfdcUserId) {
    	GNE_CM_MPS_User__c mpsUser = [SELECT First_name__c, Last_name__c, Email_address__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :sfdcUserId LIMIT 1];
    	String body = '<p>Dear ${name},</p>' +
		'<p>Your account password has been updated as per your request. If you did not request this change, or if you have any further questions, please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p>' +
		'<p>Thank you,</p>' +
		'<p>Genentech Access Solutions</p>';
		body = body.replace('${name}', mpsUser.First_name__c + ' ' + mpsUser.Last_name__c);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { mpsUser.Email_address__c });
        mail.setSubject('Your My Patient Solutions Account password reset confirmation');
        mail.setSenderDisplayName('My Patient Solutions');                          
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    @future
    private static void sendAccountAuthenticationAnswersHaveBeenUpdated(Id sfdcUserId) {
    	GNE_CM_MPS_User__c mpsUser = [SELECT First_name__c, Last_name__c, Email_address__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :sfdcUserId LIMIT 1];
    	String body = '<p>Dear ${name},<p/>' +
		'<p>Your account authentication answers have been updated as per your request. If you did not request this change, or if you have any further questions, please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p>' +
		'<p>Thank you,</p>' +
		'<p>Genentech Access Solutions</p>';
    	body = body.replace('${name}', mpsUser.First_name__c + ' ' + mpsUser.Last_name__c);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { mpsUser.Email_address__c });
        mail.setSubject('Your My Patient Solution Solutions Update');
        mail.setSenderDisplayName('My Patient Solutions');                          
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    private class CheckAnswers { 
    	public boolean result { get; set; }
    	public String email { get; set; } 
    }
 }