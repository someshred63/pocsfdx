global without sharing class CRM_Login {
	
	public static final String PROFILE_NAME = 'GNE-Chatter-Free'; 

	@RemoteAction
	global static AuthResult checkUser(String credentials) {

		// LDAP Prod User Validation
		HttpRequest reg = new HttpRequest();
		reg.setEndpoint('https://b2b.gene.com/esbDispatcher?cType=json&apiKey=fc447464202c7ab312062dff866&NSName=GneENT_Mobility.iPhone:checkUserRoleAppStatus_v2');
		reg.setMethod('GET');
		reg.setHeader('Authorization', credentials);

		Http http = new Http();
		HTTPResponse res = http.send(reg);

		if(res.getStatusCode() != 302) {
			if(!checkIfSFDCUserExist(res.getBody())) {
				try {
					createNewChatterFreeUser(res.getBody());
					return new AuthResult(true, '', '');
				} catch (Exception ex) {
					return new AuthResult(false, String.valueOf(ex), '');
				}
			} else {
				return new AuthResult(true, '', '');
			}
		} else {
			return new AuthResult(false, 'The Username or Password you entered is incorrect, please try again.', '');
		}
	}

	@RemoteAction
	global static AuthResult authUser(String credentials) {

		String cookies = null;
		GNE_MCCO_CRM_Login_Config__c loginConfig = [Select ESB_Dispatcher__c, SSO__c, Frontdoor__c FROM GNE_MCCO_CRM_Login_Config__c WHERE Name =: UserInfo.getOrganizationId() LIMIT 1];

		// #1 Request
		HttpRequest req = new HttpRequest();
		req.setEndpoint(loginConfig.ESB_Dispatcher__c);
		req.setMethod('GET');
		req.setHeader('Authorization', credentials);

		Http http = new Http();
		HTTPResponse res = http.send(req);

		if(res.getStatusCode() == 302) {
			return new AuthResult(false, 'The Username or Password you entered is incorrect, please try again.', '');
		}

		// Set cookies
		cookies = res.getHeader('Set-Cookie');

		// #2 Request
		req = new HttpRequest();
		req.setEndpoint(loginConfig.SSO__c);
		req.setMethod('GET');
		req.setHeader('Cookie', cookies);
		req.setHeader('Authorization', credentials);

		http = new Http();
		res = http.send(req);

		cookies = cookies + addCookie('PF', res.getHeader('Set-Cookie')) + addCookie('BIGipServerpgfedua_9030_pool', res.getHeader('Set-Cookie'));

		// #3 Request
		req = new HttpRequest();
		req.setEndpoint(getValueFromAttribute('action', res.getBody()));
		req.setMethod('POST');
		req.setbody('SAMLResponse=' + EncodingUtil.urlEncode(getValueFromTag('SAMLResponse', res.getBody()), 'UTF-8') + '&RelayState=' + EncodingUtil.urlEncode(getValueFromTag('RelayState', res.getBody()), 'UTF-8'));
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

		http = new Http();
		res = http.send(req);

		// #4 Request
		req = new HttpRequest();
		if(UserInfo.getOrganizationId() == '00D70000000IrdaEAC') {
			req.setEndpoint('https://login.salesforce.com/services/Soap/u/33.0');
		} else {
			req.setEndpoint('https://test.salesforce.com/services/Soap/u/33.0');
		}
		req.setMethod('POST');
		req.setbody(prepareSoapBody(getValueFromUrl('un', res.getHeader('Location')), getValueFromUrl('pw', res.getHeader('Location'))));
		req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
		req.setHeader('SOAPAction', 'login');

		http = new Http();
		res = http.send(req);

		if(String.isNotBlank(getValueFromSoapResponse('sessionId', res.getBody()))) {
			return new AuthResult(true, getValueFromSoapResponse('sessionId', res.getBody()), loginConfig.Frontdoor__c);
		} else {
			return new AuthResult(false, 'Server error.', '');
		}

	}

	global static Boolean checkIfSFDCUserExist(String ldapData) {
		String federationIdentifier = getValueFromJSONResponse('EMAIL_ADDR', ldapData);
		return !([SELECT Id FROM USER WHERE FederationIdentifier =: federationIdentifier].isEmpty());
	}

	global static void createNewChatterFreeUser(String ldapData) {
		User newUser = new User();
		newUser.FirstName = getValueFromJSONResponse('LEGAL_FIRST_NM', ldapData);
		newUser.LastName = getValueFromJSONResponse('LEGAL_LAST_NM', ldapData);
		newUser.CommunityNickname = getValueFromJSONResponse('USER_ID', ldapData);
		newUser.Email = getValueFromJSONResponse('EMAIL_ADDR', ldapData);
		newUser.External_ID_gne__c = getValueFromJSONResponse('USER_ID', ldapData);
		newUser.FederationIdentifier = getValueFromJSONResponse('EMAIL_ADDR', ldapData);
		newUser.IsActive = true;
		newUser.Phone = getValueFromJSONResponse('PHONE_NBR', ldapData);
		newUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: PROFILE_NAME LIMIT 1].id;
		newUser.Username = getValueFromJSONResponse('EMAIL_ADDR', ldapData);
		newUser.UserPreferencesHideS1BrowserUI = false;
		newUser.TimeZoneSidKey = 'America/Los_Angeles';
		newUser.LanguageLocaleKey = 'en_US';
		newUser.LocaleSidKey = 'en_US';
		newUser.EmailEncodingKey = 'ISO-8859-1';

		insert newUser;
	}

	global static String getValueFromJSONResponse(String attrName, String data) {
		String result = data.substring(data.indexOf('"' + attrName + '":"') + (('"' + attrName + '":"').length()));
		return result.substring(0, result.indexOf('"'));
	}

	global static String prepareSoapBody(String un, String pw) {
		String result = '<s:Envelope xmlns="urn:partner.soap.sforce.com" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><s:Header/><s:Body><login>';
		result += '<username>' + un + '</username>';
		result += '<password>' + pw + '</password>';
		result += '</login></s:Body></s:Envelope>';
		return result;
	}

	global static String getValueFromAttribute(String attrName, String data) {
		String result = data.substring(data.indexOf(attrName + '="') + ((attrName + '="').length()));
		return result.substring(0, result.indexOf('"'));
	}

	global static String getValueFromTag(String tagName, String data) {
		String result = data.substring(data.indexOf(tagName + '" value="') + ((tagName + '" value="').length()));
		return result.substring(0, result.indexOf('"'));
	}

	global static String getValueFromUrl(String name, String data) {
		String result = data.substring(data.indexOf(name + '=') + ((name + '=').length()));
		return result.indexOf('&') > 0 ? result.substring(0, result.indexOf('&')) : result;
	}

	global static String getValueFromSoapResponse(String attrName, String data) {
		String result = data.substring(data.indexOf(attrName + '>') + ((attrName + '>').length()));
		return result.substring(0, result.indexOf('</'));
	}

	global static String addCookie(String cookieName, String data) {
		String result = data.substring(data.indexOf(cookieName + '=') + ((cookieName + '=').length()));
		return ';' + cookieName + '=' + result.substring(0, result.indexOf(';'));
	}

	global class AuthResult {
		private Boolean status {get; set;}
		private String data {get; set;}
		private String frontdoorUrl {get; set;}

		public AuthResult(Boolean status, String data, String frontdoorUrl) {
			this.status = status;
			this.data = data;
			this.frontdoorUrl = frontdoorUrl;
		}
	}

}