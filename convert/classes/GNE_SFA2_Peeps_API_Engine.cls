public with sharing class GNE_SFA2_Peeps_API_Engine {

	public static final Map<String, GNE_PeepsAPI_Config__c> peepsConfig = GNE_PeepsAPI_Config__c.getAll();
    private static final String ERROR_MISSING_CONF = 'Missing configuration for {0}, please contact with admin.';

	private static Set<Id> matchingProfileIds;

	public static Set<Id> getMatchingProfileIds(){
		if(matchingProfileIds==null){
			matchingProfileIds = new Set<Id>();
			List<String> validLicenses = peepsConfig.get('userLicenses').Configuration_Value_gne__c.split(',');
			for(Profile prof :[SELECT Id FROM Profile WHERE UserLicense.Name IN :validLicenses]){
				matchingProfileIds.add(prof.Id);
			}
		}
		return matchingProfileIds;
	}

	@future(callout=true)
	public static void enrichUserData(List<Id> userIds){
		try{
			List<User> usersToEnrich = [SELECT Id, Title, Department, Phone, MobilePhone, Street, City, FullPhotoUrl, External_Id_gne__c FROM User WHERE Id IN :userIds];
			Map<String, User> unixIdToUserMap = new Map<String, User>();
			for(User u :usersToEnrich){
				unixIdToUserMap.put(u.External_ID_gne__c, u);
			}
			Map<String, UserRecord> unixIdToUserDetailsMap = getUsersDetails(unixIdToUserMap.keySet());
			List<User> usersToUpdate = new List<User>();
			List<String> userUnixIdsToUpdatePhoto = new List<String>();
			for(String unixId :unixIdToUserDetailsMap.keySet()){
				User u = unixIdToUserMap.get(unixId);
				UserRecord ur = unixIdToUserDetailsMap.get(unixId);
				if(modifyUserData(u, ur)){
					usersToUpdate.add(u);
				}
				if(modifyUserPicture(u, ur)){
					userUnixIdsToUpdatePhoto.add(unixId);
				}
			}
			if(usersToUpdate.size() > 0){
				update usersToUpdate;
			}
			for(String unixId :userUnixIdsToUpdatePhoto){
				UserRecord ur = unixIdToUserDetailsMap.get(unixId);
				Id userId = unixIdToUserMap.get(unixId).Id;
				updateUserPicture(ur.photoBody, ur.pictureContentType, ur.pictureFileName, userId);
			}
		} catch(Exception ex){
			system.debug('User Enrichment failed: ' + ex);
		}
	}

	public static Boolean modifyUserPicture(User u, UserRecord userDetails){
		return u.FullPhotoUrl.endsWith('/005/F') && String.isNotBlank(userDetails.photoUrl) && userDetails.photoBody != null && String.isNotBlank(userDetails.pictureContentType) && String.isNotBlank(userDetails.pictureFileName);
	}

	public static void updateUserPicture(Blob body, String contentType, String fileName, Id userId){
		ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(body, contentType, fileName);
		ConnectApi.UserProfiles.setPhoto(null, userId, fileUpload);
	}

	public static Boolean modifyUserData(User u, UserRecord userDetails){
		Boolean userModified = false;
		if(String.isBlank(u.Title) && String.isNotBlank(userDetails.jobTitle)){
			u.Title = userDetails.jobTitle;
			userModified = true;
		}
		if(String.isBlank(u.Department) && String.isNotBlank(userDetails.departmentName)){
			u.Department = userDetails.departmentName;
			userModified = true;
		}
		if(String.isBlank(u.Phone) && String.isNotBlank(userDetails.phoneNumber)){
			u.Phone = userDetails.phoneNumber;
			userModified = true;
		}
		if(String.isBlank(u.MobilePhone) && String.isNotBlank(userDetails.mobilePhoneNumber)){
			u.MobilePhone = userDetails.mobilePhoneNumber;
			userModified = true;
		}
		if(String.isBlank(u.Street) && String.isNotBlank(userDetails.street)){
			u.Street = userDetails.street;
			userModified = true;
		}
		if(String.isBlank(u.City) && String.isNotBlank(userDetails.location)){
			u.City = userDetails.location;
			userModified = true;
		}
		return userModified;
	}

	public static Map<String, UserRecord> getUsersDetails(Set<String> unixIds){
		return getUsersDetails(unixIds, null, null);
	}

	public static Map<String, UserRecord> getUsersDetails(Set<String> unixIds, String authorizationMethod, String authorizationToken){
		if(authorizationMethod == null){
			authorizationMethod = peepsConfig.get('authorizationMethod').Configuration_Value_gne__c;
		}
		if(authorizationToken == null){
			authorizationToken = peepsConfig.get('authorizationToken').Configuration_Value_gne__c;
		}
		HttpRequest req = prepareRequest(unixIds, authorizationMethod, authorizationToken);
		Http http = new Http();
		HTTPResponse res = http.send(req);
		return parseResponse(res);
	}
    
    public static Map<String, UserRecord> getPeepsDetails(Set<String> unixIds){
		String authorizationMethod = peepsConfig.get('authorizationMethod').Configuration_Value_gne__c != null ? peepsConfig.get('authorizationMethod').Configuration_Value_gne__c : null;
        String authorizationToken = peepsConfig.get('authorizationToken').Configuration_Value_gne__c != null ? peepsConfig.get('authorizationToken').Configuration_Value_gne__c : null;
        if(authorizationMethod == null){
                throw new MissingPeepsConfigurationException(String.format(ERROR_MISSING_CONF, new List<String> {'authorizationMethod'}));
            }
            if(authorizationToken == null){
                throw new MissingPeepsConfigurationException(String.format(ERROR_MISSING_CONF, new List<String> {'authorizationToken'}));
            }
		HttpRequest req = prepareRequest(unixIds, authorizationMethod, authorizationToken);
		Http http = new Http();
		HTTPResponse res = http.send(req);
		return parseResponseNoPhoto(res);
	}
    
    private static Map<String, UserRecord> parseResponseNoPhoto(HTTPResponse res){
		Map<String, UserRecord> unixIdToUserDetails = new Map<String, UserRecord>();
		if(res.getStatusCode() == 200){
			List<UserRecord> userRecords = (List<UserRecord>)JSON.deserialize(res.getBody(), List<UserRecord>.class);
			for(UserRecord ur :userRecords){
				ur.setStreet();
				
				unixIdToUserDetails.put(ur.userId, ur);
			}
		} else {
			system.debug(res.getStatusCode());
		}
        System.debug(unixIdToUserDetails);
		return unixIdToUserDetails;
	}

	private static HttpRequest prepareRequest(Set<String> unixIds, String authorizationMethod, String authorizationToken){
		HttpRequest req = new HttpRequest(); 
		req.setMethod('GET');
		req.setEndpoint(peepsConfig.get('endpointForGW').Configuration_Value_gne__c + prepareParamsString(new List<String>(unixIds)));
		if(authorizationMethod.equalsIgnoreCase('google')){
			req.setHeader('Authorization', 'Bearer ' + authorizationToken);
			req.setHeader('X-OAuth-Provider', 'Google');
		} else if(authorizationMethod.equalsIgnoreCase('basic')){
			req.setHeader('Authorization', 'Basic ' + authorizationToken);
		}
		req.setTimeout(120000);
		return req;
	}

	private static String prepareParamsString(List<String> unixIds){
		String paramsString = '/users?appKey=' + peepsConfig.get('appKey').Configuration_Value_gne__c + '&apiKey=' + peepsConfig.get('apiKey').Configuration_Value_gne__c + '&userIds=';
		if(unixIds.size()>0){
			paramsString += String.join(unixIds, '%2C');
		}
		system.debug(paramsString);

		return paramsString;
	}

	private static Map<String, UserRecord> parseResponse(HTTPResponse res){
		Map<String, UserRecord> unixIdToUserDetails = new Map<String, UserRecord>();
		if(res.getStatusCode() == 200){
			List<UserRecord> userRecords = (List<UserRecord>)JSON.deserialize(res.getBody(), List<UserRecord>.class);
			for(UserRecord ur :userRecords){
				ur.setStreet();
				ur.setPictureInformation();
				if(String.isNotBlank(ur.photoUrl)){
					ur.photoBody = getBlobBody(ur.photoUrl);
				}
				unixIdToUserDetails.put(ur.userId, ur);
			}
		} else {
			system.debug(res.getStatusCode());
		}
		return unixIdToUserDetails;
	}

	public static Blob getBlobBody(String photoUrl){
		Blob bodyBlob;
		try{
			HttpRequest req = new HttpRequest();
		    req.setMethod('GET');
			req.setEndpoint(photoUrl);
			req.setTimeout(120000);
			Http http = new Http();
			HTTPResponse res = http.send(req);
	    	bodyBlob = res.getBodyAsBlob();
	    } catch(Exception ex){
	    	system.debug('Exception during picture retrieve: ' + ex);
	    }
	    return bodyBlob;
	}

	public class UserRecord{
		public String buildingNumber;
		public String canonicalFirstName;
		public String canonicalLastName;
		public String company;
		public String costCenterName;
		public String costCenterNumber;
		public String departmentCode;
		public String departmentName;
		public String email;
		public String employmentType;
		public String firstName;
		public String fullName;
		public String googleId;
		public String jobTitle;
		public String labNumber;
		public String lastName;
		public String location;
		public String locationCD;
		public String mailStop;
		public String managerUnixId;
		public String mobilePhoneNumber;
		public String odgName;
		public String odgNumber;
		public String phoneNumber;
		public String photoEtag;
		public String roomNumber;
		public String salutation;
		public String street;
		public String userId;
		public String photoUrl;
		public Blob photoBody;
		public String pictureContentType;
		public String pictureFileName;

		public void setStreet(){
			street = String.isNotBlank(buildingNumber) ? 'Building: ' + buildingNumber + ', ' : '';
			street += String.isNotBlank(roomNumber) ? 'Office: ' + roomNumber + ', ' : '';
			street += String.isNotBlank(mailStop) ? 'Mail Stop: ' + mailStop : '';
			street = street.removeEnd(', ');
		}

		public void setPictureInformation(){
			if(String.isNotBlank(photoUrl)){
				pictureFileName = photoUrl.substringAfterLast('/').substringBefore('?');
				pictureContentType = 'image/' + pictureFileName.substringAfter('.');
			}
		}
	}
    public class MissingPeepsConfigurationException extends Exception{}
}