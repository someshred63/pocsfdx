@RestResource(urlMapping = '/PACT/IHCP/User/Service')
global without sharing class GNE_CM_IHCP_PACT_Service {

	public static final String MPS_USER_APPROVED_FOR_PACT_STATUS = 'Approved for PACT';

	private static final String INITIAL_ACTIVATION_EMAIL_BODY = '<p>Hi ${name},</p>' +
																'<p>A My Patient Solutions ™ account has been registered on your behalf.</p>' +
																'<p>Your account user name is ${email}.  To complete the account activation process, you will need to set up your secure password and answer challenge questions.</p>' +
																'<p><a href="${link}">Click here</a> to complete your registration.</p>' +
																'<p>The activation link in this email will expire in 30 days. You will receive a reminder activation email every week for three weeks until you complete the activation. If you cannot complete the activation, or if you have any questions, please call Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am-5pm PST, Monday through Friday.</p>' +
																'<p>Thank you,<br/>Genentech Access Solutions</p>' +
																'<p><img src="https://www.genentech-access.com/hcp/_jcr_content/header-iparsys/header/logo.img.full.high.png/1470775631557.png"/></p>';

	private static final String ACTIVATION_EMAIL_BODY =  		'<p>Hi ${name},</p>' +
																'<p>As a reminder, a My Patient Solutions ™ account has been registered on your behalf.</p>' +
																'<p>Your account user name is ${email}.  To complete the account activation process, you will need to set up your secure password and answer challenge questions.</p>' +
																'<p><a href="${link}">Click here</a> to complete your registration.</p>' +
																'<p>The activation link in this email will expire on ${expirationDate}. If you cannot complete the activation, or if you have any questions, please call Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am-5pm PST, Monday through Friday.</p>' +
																'<p>Thank you,<br/>Genentech Access Solutions</p>' +
																'<p><img src="https://www.genentech-access.com/hcp/_jcr_content/header-iparsys/header/logo.img.full.high.png/1470775631557.png"/></p>';

    public static final String NOTIFICATION_EMAIL_BODY = 		'<p>Hi ${name},</p>' +
    															'<p>Your account has been activated. Your user name is ${email}. Please use your existing Genentech password to access My Patient Solutions.</p>' +
    															'<p>If you have any further questions, please contact the Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377.</p>' +
    															'<p>Thank you,<br/>Genentech Access Solutions</p>' +
    															'<p><img src="https://www.genentech-access.com/hcp/_jcr_content/header-iparsys/header/logo.img.full.high.png/1470775631557.png"/></p>';

    public static final String NOTIFICATION_EMAIL_SOT_BODY = 	'<p>Hi ${name},</p>' +
    															'<p>Your account has been activated. Your user name is ${email}. Please use your existing Genentech password to access Site of Treatment Portal.</p>' +
    															'<p>If you have any further questions, please contact the Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377.</p>' +
    															'<p>Thank you,<br/>Genentech Access Solutions</p>' +
    															'<p><img src="https://www.genentech-access.com/hcp/_jcr_content/header-iparsys/header/logo.img.full.high.png/1470775631557.png"/></p>';

	@HttpGet
    global static void processGetRequest() {
    	RestRequest request = RestContext.request;
    	String email = request.params.get('email');
    	RestResponse response = RestContext.response;
		Map<String, Object> RESPONSE_DETAILS = new Map<String, Object>();
    	Map<String, Object> result = new Map<String, Object>{
    		'IHCPUserResponse' => RESPONSE_DETAILS
    	};
    	if (String.isBlank(email)) {
			RESPONSE_DETAILS.put('Status', 'Error');
			RESPONSE_DETAILS.put('errorMsg', 'Email param is required.');
			response.statusCode = 404;
    	} else {
    		List<GNE_CM_IHCP_User__c> ihcpUsers = [SELECT SFDC_User__r.IsActive, MPS_Status__c, SOT_Status__c FROM GNE_CM_IHCP_User__c WHERE Email_Address__c = :email];
    		Boolean isUserActive = false;
    		if (!ihcpUsers.isEmpty())	 {
    			GNE_CM_IHCP_User__c user = ihcpUsers.get(0);
    			if ((user.MPS_Status__c == 'Approved' || user.SOT_Status__c == 'Approved') && user.SFDC_User__c != null && user.SFDC_User__r.IsActive) {
    				List<PermissionSet> permissions = [SELECT Id FROM PermissionSet WHERE Name = :GNE_CM_IHCP_Utils.MPS_PERMISSION_SET];
    				if (permissions.size() == 1) {
	    				PermissionSet permission = permissions.get(0);
		  				List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id
			                                                                	FROM PermissionSetAssignment
		    	                                                            	WHERE AssigneeId = :user.SFDC_User__c AND PermissionSetId = :permission.Id];
						if (!permissionSetAssignments.isEmpty()) {
							List<GNE_CM_MPS_User__c> mpsUsers = [SELECT User_Status__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :user.SFDC_User__c];
							if (!mpsUsers.isEmpty() && (mpsUsers.get(0).User_Status__c == 'Approved' || mpsUsers.get(0).User_Status__c == MPS_USER_APPROVED_FOR_PACT_STATUS)) {
								isUserActive = true;
							}
						}
    				}
    			}
    			RESPONSE_DETAILS.put('sotUser', user.SOT_Status__c == 'Approved');
    			RESPONSE_DETAILS.put('mpsUser', user.MPS_Status__c == 'Approved');
    		}
    		RESPONSE_DETAILS.put('Status', isUserActive ? 'true' : 'false');
			response.statusCode = 200;
    	}
    	response.addHeader('Content-Type', 'application/json;charset=UTF-8');
		response.responseBody = Blob.valueOf(JSON.serialize(result));
    }

  	@HttpPost
    global static void processPostRequest(IHCPUserRequest IHCPUserRequest) {
		RestResponse response = RestContext.response;
		Map<String, Object> RESPONSE_DETAILS = new Map<String, Object>();
    	Map<String, Object> result = new Map<String, Object>{
    		'IHCPUserResponse' => RESPONSE_DETAILS
    	};
    	if (String.isBlank(IHCPUserRequest.email)) {
			RESPONSE_DETAILS.put('Status', 'Error');
			RESPONSE_DETAILS.put('errorMsg', 'Email param is required.');
			response.statusCode = 404;
    	} else {
			if (((Integer)[SELECT count(Id) c FROM GNE_CM_IHCP_User__c WHERE Email_Address__c = :IHCPUserRequest.email].get(0).get('c')) == 0) {
				if (String.isBlank(IHCPUserRequest.firstName)) {
					RESPONSE_DETAILS.put('Status', 'Error');
					RESPONSE_DETAILS.put('errorMsg', 'FirstName param is required.');
					response.statusCode = 404;
				} else if (String.isBlank(IHCPUserRequest.lastName)) {
					RESPONSE_DETAILS.put('Status', 'Error');
					RESPONSE_DETAILS.put('errorMsg', 'LastName param is required.');
					response.statusCode = 404;
				} else if (String.isBlank(IHCPUserRequest.username)) {
					RESPONSE_DETAILS.put('Status', 'Error');
					RESPONSE_DETAILS.put('errorMsg', 'Username param is required.');
					response.statusCode = 404;
				} else {
					Savepoint sp  = Database.setSavepoint();
					try {
						Account personAccount = new Account(
							RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('LWO Health Care Professional').getRecordTypeId(),
							FirstName = IHCPUserRequest.firstName,
							LastName = IHCPUserRequest.lastName,
							PersonEmail = IHCPUserRequest.Email
						);
						insert personAccount;
						Id contactId = [SELECT PersonContactId FROM Account WHERE ID = :personAccount.Id].PersonContactId;

						Integer fl = IHCPUserRequest.firstName.length(), ll = IHCPUserRequest.lastName.length();
						String alias = IHCPUserRequest.firstName.substring(0, 1) + IHCPUserRequest.lastName.Substring(0, 1);
					    if (fl > ll && fl < 8) {
					        alias = IHCPUserRequest.FirstName + IHCPUserRequest.lastName.substring(0, 1);
					    } else if (ll > fl && ll < 8) {
					    	alias = IHCPUserRequest.LastName + IHCPUserRequest.firstName.substring(0, 1);
					    } else if (ll > 8) {
					    	alias = IHCPUserRequest.lastName.substring(0,  6) + IHCPUserRequest.firstName.substring(0, 1);
					    } else if (fl > 8){
					    	alias = IHCPUserRequest.firstName.substring(0, 6) + IHCPUserRequest.lastName.substring(0, 1);
					    }

					    String environmentName = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
						environmentName = (environmentName.equalsIgnoreCase('prod') ? '' : '.' + environmentName).toLowerCase();
						String username = IHCPUserRequest.username + environmentName;

						User user = new User(
				    		ProfileId = [SELECT ID FROM Profile WHERE Name = :GNE_CM_IHCP_Utils.getIHCPPortalProfileName()].Id,
				    		ContactId = contactId,
				    		IsActive = true,
				    		Username = username,
						    FirstName = IHCPUserRequest.firstName,
				    		LastName = IHCPUserRequest.lastName,
				    		Phone = IHCPUserRequest.phone,
				    		Extension = IHCPUserRequest.extension,
				    		Alias = alias,
				    		Email = IHCPUserRequest.email,
				    		CommunityNickname = username.length() > 40 ? username.substring(0,  40) : IHCPUserRequest.username,
				    		TimeZoneSidKey = 'America/Los_Angeles',
				    		LocaleSidKey = 'en_US',
				    		EmailEncodingKey = 'UTF-8',
				    		LanguageLocaleKey = 'en_US',
				    		FederationIdentifier = IHCPUserRequest.email
				    	);
				    	insert user;
				    	updateIHCPUserPermissionSets(user.Id, true);
				    	GNE_CM_IHCP_User__c ihcpUser = new GNE_CM_IHCP_User__c(
					        SFDC_User__c = user.Id,
			                MPS_Status__c = IHCPUserRequest.sotUser == null || !IHCPUserRequest.sotUser ? 'Approved' : 'No Access',
			                SOT_Status__c = IHCPUserRequest.sotUser == null || !IHCPUserRequest.sotUser ? 'No Access' : 'Approved',
							LWO_Status__c = 'No Access',
							Name = username,
							Email_Address__c = IHCPUserRequest.email
			            );
			            insert ihcpUser;

			            GNE_CM_MPS_User__c mpsUser = new GNE_CM_MPS_User__c(
	                		SFDC_User__c = user.Id,
	                		First_name__c = IHCPUserRequest.firstName,
	                		Last_name__c = IHCPUserRequest.lastName,
	                		Email_address__c = IHCPUserRequest.Email,
	                		Phone_number__c = IHCPUserRequest.phone,
			                Phone_number_ext__c = IHCPUserRequest.extension,
			                Admin__c = false,
			                User_Status__c = MPS_USER_APPROVED_FOR_PACT_STATUS,
			                Intake_Status__c = 'Processed',
			                Workflow_State__c = 'ACTIVATION_EMAIL_SENT',
        					Activation_Email_Sent_Date__c = DateTime.now(),
        					Activation_Server__c = GNE_CM_IHCP__c.getInstance().Community_URL__c,
                			Activation_Hash_Number__c = GNE_CM_IHCP_Email_Utility.generateActivationHash(100)
			            );
			            insert mpsUser;
		            	sendActivationEmail(mpsUser.Id, true);
			            RESPONSE_DETAILS.put('Status', 'Success [inserted: ' + ihcpUser.Id + ']');
						RESPONSE_DETAILS.put('errorMsg', '');
						RESPONSE_DETAILS.put('FederationIdentifier', [SELECT FederationIdentifier FROM User WHERE ID = :user.Id].FederationIdentifier + (IHCPUserRequest.sotUser ? '.sot' : ''));

						response.statusCode = 200;
						sp = null;
					} catch (Exception e){
						RESPONSE_DETAILS.put('Status', 'Failed');
						RESPONSE_DETAILS.put('errorMsg', e.getMessage());
						response.statusCode = 200;
					} finally {
						if (sp != null) {
							Database.rollback(sp);
						}
					}
				}
			} else {
				List<GNE_CM_IHCP_User__c> ihcpUsers = [SELECT Id,
													   SFDC_User__c, SFDC_User__r.FirstName, SFDC_User__r.LastName,
													   SFDC_User__r.Phone, SFDC_User__r.Extension, SFDC_User__r.Email,
													   SFDC_User__r.Contact.AccountId
													   FROM GNE_CM_IHCP_User__c
													   WHERE Email_Address__c = :IHCPUserRequest.email];
				if (ihcpUsers.size() > 1) {
					RESPONSE_DETAILS.put('Status', 'Error');
					RESPONSE_DETAILS.put('errorMsg', 'Found more than one IHCP User.');
					response.statusCode = 404;
				} else {
					GNE_CM_IHCP_User__c ihcpUser = ihcpUsers.get(0);
					if (ihcpUser.SFDC_User__c == null || ihcpUser.SFDC_User__r.Contact == null || ihcpUser.SFDC_User__r.Contact.AccountId == null) {
						RESPONSE_DETAILS.put('Status', 'Error');
						RESPONSE_DETAILS.put('errorMsg', 'Problem with structure of IHCP User.');
						response.statusCode = 404;
					} else {
						List<GNE_CM_MPS_User__c> mpsUsers = [SELECT ID, Workflow_State__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :ihcpUser.SFDC_User__c];
						if (mpsUsers.size() > 1) {
							RESPONSE_DETAILS.put('Status', 'Error');
							RESPONSE_DETAILS.put('errorMsg', 'Found more than one MPS User.');
							response.statusCode = 404;
						} else  {
							GNE_CM_MPS_User__c mpsUser;
							if (mpsUsers.isEmpty()) {
								insert (mpsUser = new GNE_CM_MPS_User__c(
			                		SFDC_User__c = ihcpUser.SFDC_User__c,
			                		First_name__c = ihcpUser.SFDC_User__r.FirstName,
			                		Last_name__c = ihcpUser.SFDC_User__r.LastName,
			                		Email_address__c = ihcpUser.SFDC_User__r.Email,
			                		Phone_number__c = ihcpUser.SFDC_User__r.Phone,
					                Phone_number_ext__c = ihcpUser.SFDC_User__r.Extension,
					                Admin__c = false,
					                User_Status__c = MPS_USER_APPROVED_FOR_PACT_STATUS,
					                Intake_Status__c = 'Processed',
			                		Workflow_State__c = 'ACTIVATION_EMAIL_SENT',
			                		Activation_Server__c = GNE_CM_IHCP__c.getInstance().Community_URL__c,
			                		Activation_Hash_Number__c = GNE_CM_IHCP_Email_Utility.generateActivationHash(100)
			            		));
							} else {
								mpsUser = mpsUsers.get(0);
							}

							Boolean active = IHCPUserRequest.action.equalsIgnoreCase('Active');
							if (active) {
								if (mpsUser.Workflow_State__c != 'ACTIVATED') {
									mpsUser.Workflow_State__c = 'ACTIVATION_EMAIL_SENT';
			                		mpsUser.Activation_Hash_Number__c = GNE_CM_IHCP_Email_Utility.generateActivationHash(100);
			                		mpsUser.Activation_Email_Sent_Date__c = DateTime.now();
			                		update mpsUser;

			                		if (IHCPUserRequest.skipNotifications == null || !IHCPUserRequest.skipNotifications) {
			                			sendActivationEmail(mpsUser.Id, false);
			                		}
								} else if (IHCPUserRequest.skipNotifications == null || !IHCPUserRequest.skipNotifications) {
									sendNotificationEmail(mpsUser.Id, IHCPUserRequest.sotUser);
								}
							}

							if (IHCPUserRequest.sotUser == null || !IHCPUserRequest.sotUser) {
								ihcpUser.MPS_Status__c = active ? 'Approved' : 'No Access';
							} else {
								ihcpUser.SOT_Status__c = active ? 'Approved' : 'No Access';
							}
							update ihcpUser;
							updateIHCPUserPermissionSets(ihcpUser.SFDC_User__c, active);
							RESPONSE_DETAILS.put('Status', 'Success [updated: ' + ihcpUser.Id + ']');
							RESPONSE_DETAILS.put('StatusDescription', mpsUser.Workflow_State__c);
							RESPONSE_DETAILS.put('errorMsg', '');
							RESPONSE_DETAILS.put('FederationIdentifier', [SELECT FederationIdentifier FROM User WHERE ID = :ihcpUser.SFDC_User__c].FederationIdentifier + (IHCPUserRequest.sotUser ? '.sot' : ''));
							response.statusCode = 200;
						}
					}
				}
			}
    	}
		response.addHeader('Content-Type', 'application/json;charset=UTF-8');
		response.responseBody = Blob.valueOf(JSON.serialize(result));
    }

    private static void sendActivationEmail(Id mpsUserId, Boolean newUser) {
    	sendActivationEmail(new List<Id>{mpsUserID}, newUser);
    }

    public static void sendActivationEmail(List<Id> mpsUserIds, Boolean newUser) {
    	List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
		Integer sendPeriod = (Integer)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Activation_Email_Send_Period__c;
		for (GNE_CM_MPS_User__c mpsUser : [SELECT SFDC_User__r.Username,
	    								  First_name__c, Last_name__c, Email_address__c,
	    								  Activation_Server__c, Activation_Hash_Number__c,
			                              Activation_Email_Sent_Date__c
	    								  FROM GNE_CM_MPS_User__c WHERE ID in :mpsUserIds]) {
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(new String[] { mpsUser.Email_address__c });
	        mail.setSubject('Activate your My Patient Solutions Account');
	        mail.setSenderDisplayName('My Patient Solutions');
	        String body = newUser ? INITIAL_ACTIVATION_EMAIL_BODY : ACTIVATION_EMAIL_BODY;
	        body = body.replace('${name}', mpsUser.First_name__c + ' ' + mpsUser.Last_name__c);
	        body = body.replace('${email}', mpsUser.SFDC_User__r.Username);
	       	body = body.replace('${link}', mpsUser.Activation_Server__c + '/GNE_CM_PACT_Activation?mpsUserId=' + mpsUser.Id + '&hash='  + mpsUser.Activation_Hash_Number__c);
			if (body.contains('${expirationDate}')) {
				DateTime dt = mpsUser.Activation_Email_Sent_Date__c.addDays(sendPeriod);
				body = body.replace('${expirationDate}', dt.month() + '/' + dt.day() + '/' + dt.year());
			}
	       	mail.setHtmlBody(body);
	       	messages.add(mail);
		}
        Messaging.sendEmail(messages);
    }

	public static void sendNotificationEmail(Id mpsUserId) {
		sendNotificationEmail(mpsUserId, false);
    }

    public static void sendNotificationEmail(Id mpsUserId, Boolean sotUser) {
    	GNE_CM_MPS_User__c mpsUser = [SELECT SFDC_User__r.Username, First_name__c, Last_name__c, Email_address__c FROM GNE_CM_MPS_User__c WHERE ID = :mpsUserId];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { mpsUser.Email_address__c });
        mail.setSubject('My Patient Solutions Account Activated');
        mail.setSenderDisplayName('My Patient Solutions');
        String body = NOTIFICATION_EMAIL_BODY;
        body = body.replace('${name}', mpsUser.First_name__c + ' ' + mpsUser.Last_name__c);
        body = body.replace('${email}', mpsUser.SFDC_User__r.Username);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

	@future
  	private static void updateIHCPUserPermissionSets (Id sfdcUserId, Boolean assign) {
		update new User(Id = sfdcUserId, IsActive = true);
  		List<PermissionSet> permissions = [SELECT Id FROM PermissionSet WHERE Name = :GNE_CM_IHCP_Utils.MPS_PERMISSION_SET];
  		if (permissions.size() == 1) {
  			PermissionSet permission = permissions.get(0);
  			List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id
	                                                                	FROM PermissionSetAssignment
    	                                                            	WHERE AssigneeId = :sfdcUserId AND PermissionSetId = :permission.Id];

  			if (permissionSetAssignments.isEmpty() && assign) {
  				insert new PermissionSetAssignment(AssigneeId = sfdcUserId, PermissionSetId = permission.Id);
  			} else if (!permissionSetAssignments.isEmpty() && !assign) {
  				delete permissionSetAssignments;
  			}
  		}
    }

    global class IHCPUserRequest {
  		global String action { get; set; }
  		global String email  { get; set; }
  		global String username  { get; set; }
  		global String firstName  { get; set; }
  		global String lastName  { get; set; }
  		global String phone  { get; set; }
  		global String extension  { get; set; }
  		global Boolean sotUser { get; set; }
  		global Boolean skipNotifications { get; set; }
  	}
}