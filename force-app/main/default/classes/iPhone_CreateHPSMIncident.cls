@RestResource(urlMapping='/iPhoneCreateHPSMIncident/*')
global with sharing class iPhone_CreateHPSMIncident {

	@HttpPost
	global static iPhone_Commons_gne.RestResponse processRequest(HPSMIncidentRequest request) {
		system.debug(request);
		return iPhone_Commons_gne.buildResponse(
			new CreateHPSMIncidentResponseBuilder(),
			new RequestParams(request)
		);
	}

	class CreateHPSMIncidentResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

		public iPhone_Commons_gne.RestResponse build(Object args) {
			system.debug(args);
			RequestParams params = (RequestParams)args;
            GNE_CRM_HPSM_Incident__c inc = params.generateIncidentRecord();
			insert inc;
            GNE_CRM_Support_Ctrl.sendEmail(inc);
			return new HPSMResponse();
		}
	}

	class HPSMResponse extends iPhone_Commons_gne.RestResponse {
		public HPSMResponse(){
		}
	}

	global class HPSMIncidentRequest{
		public String unixId;
		public String title;
		public String description;
		public String requestId;
		public String phoneNumber;
	}

	class RequestParams {
		private String assignmentGroup {get;set;}
		private String regId {get;set;}
		private String tibcoUrl {get;set;}
		private String unixId {get;set;}

		private String title {get;set;}
		private String description {get;set;}

		private String territories {get;set;}
		private String iosDetails {get;set;}
		private String phoneNumber {get;set;}
		private String profileName {get;set;}

		private User requestingUser {get;set;}

		private Map<String, String> paramsMap {get;set;}

		private Boolean isValid {get;set;}
		private List<String> errorMessages {get;set;}

		public RequestParams(HPSMIncidentRequest request){
			this.isValid = true;
			this.errorMessages = new List<String>();
			//Map<String, GNE_SFA2_HPSM_Config__c> hpsmConfig = GNE_SFA2_HPSM_Config__c.getAll();
			//this.tibcoUrl = String.valueOf(hpsmConfig.get('TibcoUrlForIncidents').Configuration_Value_gne__c);
			//this.regId = String.valueOf(hpsmConfig.get('HPSMRegistrationId').Configuration_Value_gne__c);
			this.unixId = request.unixId;
			//this.assignmentGroup = String.valueOf(hpsmConfig.get('IncidentDefaultAssignmentGroup').Configuration_Value_gne__c);

			this.title = request.title;
			this.description = request.description;
			try{
				this.requestingUser = [SELECT Id, Profile.Name FROM User WHERE External_Id_gne__c = :unixId AND isActive = true LIMIT 1];
				this.profileName = requestingUser.Profile.Name;
				try{
					this.territories = getUserTerritories(requestingUser);
				} catch(Exception ex){
					isValid = false;
					errorMessages.add('Error while retrieving territories for user ' + requestingUser + '.' + ex);
				}
			} catch (Exception ex){
				isValid = false;
				errorMessages.add('User with unixId ' + unixId + ' not found.' + ex);
			}
			this.iosDetails = request.requestId;
			this.phoneNumber = request.phoneNumber;


			prepareMapAndValidateRequest();
		}

		private String getUserTerritories(User requestingUser){
        	String userTerritories = '';
        	for(Territory2 terr :[SELECT Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :requestingUser.Id)]){
	            if(userTerritories != ''){
    	            userTerritories += ', ';
        	    }
            	userTerritories += terr.Name;
        	}
        	return userTerritories;
    	}

		public void prepareMapAndValidateRequest(){
			paramsMap = new Map<String,String>();

			if(String.isNotBlank(assignmentGroup)){
				paramsMap.put('assignmentGroup', assignmentGroup);
			} else {
				isValid = false;
				errorMessages.add(prepareErrorMessage('SFDC', 'Assignment Group'));
			}

			if(String.isNotBlank(regId)){
				paramsMap.put('regId', regId);
			} else {
				isValid = false;
				errorMessages.add(prepareErrorMessage('SFDC', 'Registration Id'));
			}

			if(String.isNotBlank(tibcoUrl)){
				paramsMap.put('tibcoUrl', tibcoUrl);
			} else {
				isValid = false;
				errorMessages.add(prepareErrorMessage('SFDC', 'Tibco Url'));
			}

			if(String.isNotBlank(unixId)){
				paramsMap.put('unixId', unixId);
			} else {
				isValid = false;
				errorMessages.add(prepareErrorMessage('OTR', 'Unix Id'));
			}

			if(String.isNotBlank(title)){
				paramsMap.put('title', title);
			} else {
				isValid = false;
				errorMessages.add(prepareErrorMessage('OTR', 'Title'));
			}

			String descriptionTemp = '';
			if(String.isNotBlank(description)){
				descriptionTemp = description;
			} else {
				isValid = false;
				errorMessages.add(prepareErrorMessage('OTR', 'Description'));
			}

			descriptionTemp += '\n\nExtended Information:';
			if(String.isNotBlank(phoneNumber)){
				descriptionTemp += '\nContact Phone Number: ' + phoneNumber;
			}

			if(String.isNotBlank(profileName)){
				descriptionTemp += '\nUser Profile: ' + profileName;
			} else {
				isValid = false;
				errorMessages.add(prepareErrorMessage('SFDC', 'Profile Name'));
			}

			if(String.isNotBlank(territories)){
				if(territories.contains(',')){
					descriptionTemp += '\nTerritories Assigned: ' + territories;
				} else {
					descriptionTemp += '\nTerritory Assigned: ' + territories;
				}
			}

			if(String.isNotBlank(iosDetails)){
				descriptionTemp += '\nDevice Information: ' + iosDetails;
			} else {
				isValid = false;
				errorMessages.add(prepareErrorMessage('OTR', 'Request Id'));
			}
			paramsMap.put('description', descriptionTemp);

		}

		public Map<String, String> getMap(){
    		return this.paramsMap;
    	}

    	public String prepareErrorMessage(String errorCode, String fieldName){
	   		return '[' + errorCode + '] No ' + fieldName + (errorCode.equalsIgnoreCase('OTR') ? ' provided.' : ' found.');
	   	}

	   	public Boolean isValid(){
	   		return isValid;
	   	}

	   	public List<String> getErrorMessages(){
	   		return this.errorMessages;
	   	}

	   	public GNE_CRM_HPSM_Incident__c generateIncidentRecord(){
	   		GNE_CRM_HPSM_Incident__c incident = new GNE_CRM_HPSM_Incident__c();
	   		incident.Details_gne__c = paramsMap.get('description');
	   		incident.Device_Information_gne__c = this.iosDetails;
	   		incident.Origin_gne__c = 'OTR';
	   		incident.Phone_Number_gne__c = this.phoneNumber;
	   		incident.Priority_gne__c = 4;
			incident.Status_gne__c = 'Not Synchronized';
			incident.Summary_gne__c = this.title;
			incident.Unix_Id_gne__c = this.unixId;
			return incident;
	   	}

    }

}