/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com
*  Created: 2013-07-12
*  Project: FCR
*  Description: Helper class for FCR webservices (REST).
***************************************************************************************************/
global class GNE_FCR_Services_Helper{
	/**
	A template method - builds a webservice response object. Specialized for a 'data
	retrieval' requests. The response object contains a reqested data and an operation
	status (and some debugging information).
	*/
	public static RestResponse buildResponse(ResponseBuilder builder, Object args) {
		system.debug('Building Response: ' + args);
		RestResponse response = null;
		try {
			response = builder.build(args);
			response.setSuccessStatus();
		} catch (Exception ex) {
			response = new BasicResponse(ex);
			response.setErrorStatus(ex);
		}
		system.debug('Response: ' + response);
		return response;
	}

	public static SObject getFirstSObject(List<SObject> sObjects) {
		if(sObjects.size() == 0)
		return null;
		return sObjects[0];
	}

	public static User getUserByExternalId(String externalId) {
		return (User)getFirstSObject([
		SELECT
		Id,
		Name,
		AccountId,
		CompanyName,
		Profile_Name_gne__c,
		ProfileId,
		FirstName,
		LastName,
		External_ID_gne__c
		FROM
		User
		WHERE
		External_ID_gne__c =: externalId
		]);
	}

	public static List<UserTerritory2Association> getUserTerritories(String userId) {
		return  [
		SELECT
		Territory2Id
		FROM
		UserTerritory2Association
		WHERE
		IsActive   = true
		AND userid     =:userId
		];
	}

	public static List<Territory2> getTerritories(List<String> territoriesIds) {
		return  [
		SELECT
		Id,
		Name
		FROM
		Territory2
		WHERE
		id in : territoriesIds
		];
	}


	public static List<Group> getGroupsForTerritories(List<Territory2> territories) {
		return  [
		SELECT
		Id,
		relatedId
		FROM
		Group
		WHERE
		relatedId in: territories
		];
	}

	public static List<AccountShare> getAccountSharesForGroups(List<Group> groups) {
		return  [
		SELECT
		UserOrGroupId,
		accountId
		FROM
		AccountShare
		WHERE
		UserOrGroupId in: groups limit 24500
		];
	}

	public static List<Account> getAccountsByIds(List<String> accountIds) {
		return  [
		SELECT
		a.Id,a.MDMID_gne__c,a.Name
		FROM
		Account a WHERE
		Id in: accountIds
		ORDER BY
		CreatedDate
		];
	}

	public static List<Franchise_Objective_gne__c> getFranchiseObjective(Id franchiseId){
		List<Franchise_Objective_gne__c> result = [ SELECT Name,Objective_gne__c,CreatedDate,SystemModStamp,LastModifiedDate,IsDeleted
		FROM Franchise_Objective_gne__c WHERE Franchise_gne__c=:franchiseId order by LastModifiedDate desc LIMIT 1];
		return result;
	}

	public static List<SFA2_User_Sales_Roster_gne__c> getFranchiseId(Id userId){
		List<SFA2_User_Sales_Roster_gne__c> result = [ SELECT Sales_Roster_gne__r.Franchise__r.Id
		FROM SFA2_User_Sales_Roster_gne__c WHERE User_gne__c=:userId AND Is_Active_gne__c = true AND Sales_Roster_gne__r.Runs_in_SFA2_Mode_gne__c = true AND Sales_Roster_gne__r.Franchise__c!=null];
		return result;
	}

	public static List<SFA2_User_Sales_Roster_gne__c> getFranchise(Id userId){
		List<SFA2_User_Sales_Roster_gne__c> result = [ SELECT Sales_Roster_gne__r.Franchise__c
		FROM SFA2_User_Sales_Roster_gne__c WHERE User_gne__c=:userId AND Is_Active_gne__c = true AND Sales_Roster_gne__r.Runs_in_SFA2_Mode_gne__c = true AND Sales_Roster_gne__r.Franchise__c!=null];
		return result;
	}

	public static String getUserRole(Id userId){
		String profileName = getProfile(userId);
		if(profileName.startsWith('GNE-SFA') && profileName.endsWith('-DM')){
			return 'DM';
		}else if (profileName.startsWith('GNE-SFA') & profileName.endsWith('-CS')){
			return 'CS';
		}else if(profileName.startsWith('GNE-SYS-SOIM')){
			List<User> userList = [ SELECT Id FROM User WHERE ManagerId=:userId and isActive = true];
			if(userList.size()>0){
				return 'DM';
			}else{
				return 'CS';
			}
		}
		return 'NoFcrAccess';
	}

	public static String getProfile(Id userId){
		User u = [select Profile.Name from User where Id=:userId];
		return u!=null?u.Profile.Name:null;
	}

	public static List<String> buildStringList(List<SObject> sObjects, String fieldName) {
		List<String> resultList = new List<String>();
		for(SObject sObj: sObjects) {
			resultList.add(String.valueOf(sObj.get(fieldName)));
		}
		return resultList;
	}

	/* ************************************************************************************** */
	/* ****************************** PUBLIC CLASSES AND INTERFACES ************************* */
	/* ************************************************************************************** */

	/**
	Designated for the classes responsible for the (REST) response generation. The 'build'
	method builds response for the parmeters passed as an Object. Cooperates with the
	template method: buildResponse.
	*/
	public interface ResponseBuilder {
		RestResponse build(Object args);
	}

	/**
	An ancestor for all classes that holds data of a single SFDC table record.
	*/
	public abstract class RestRecord {
		public String AccountId;
		public String Name;
		public String MdmId;
	}

	/**
	A base class for all webservice response objects. Contains an operation status and
	some debugging information.
	*/
	global abstract class RestResponse {
		public Boolean success = false;
		public ExceptionInfo error;
		public Map<String, String> debugInfo = new Map<String,String>();

		public void setSuccessStatus() {
			this.success = true;
			this.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
			this.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
			this.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
			System.debug('success.');
		}

		public void setErrorStatus(Exception ex) {
			this.success = false;
			this.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
			this.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
			this.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
			this.error = new ExceptionInfo(ex);
			System.debug('failed: ' + this.error);
		}
	}

	/* ************************************************************************************** */
	/* ****************************** PRIVATE CLASSES AND INTERFACES ************************ */
	/* ************************************************************************************** */

	private class ExceptionInfo {
		public String stackTrace;
		public String typeName;
		public String cause;
		public Integer lineNumber;
		public String message;

		public ExceptionInfo(Exception ex) {
			Exception cEx = ex.getCause();

			stackTrace  = ex.getStackTraceString();
			typeName  = ex.getTypeName();
			cause    = cEx!=null ? cEx.getMessage() : '';
			lineNumber  = ex.getLineNumber();
			message    = ex.getMessage();
		}
	}

	private class BasicResponse extends RestResponse {

		public BasicResponse() {
			setSuccessStatus();
		}

		public BasicResponse(Exception ex) {
			setErrorStatus(ex);
		}
	}
}