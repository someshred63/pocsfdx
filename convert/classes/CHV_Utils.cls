public with sharing class CHV_Utils {

	public static String getEncodedImageFromUrl(String documentURL){
		if (isNotEmpty(documentURL)){
			String documentId = documentURL.substring(documentURL.lastIndexOf('=') + 1);
			return getEncodedImageById(documentId);
		}
		return null;
	}
	
	public static String getEncodedImageById(String documentId){
		if (isNotEmpty(documentId)){
			List<Document> docs = [SELECT Body FROM Document WHERE Id =: documentId];
			if (listNotEmpty(docs)){
				return EncodingUtil.base64Encode(docs.get(0).Body);
			}
		}
		return null;
	}
	
	public static String getImageId(String documentURL){
		//return isNotEmpty(documentURL) ? documentURL.substring(documentURL.lastIndexOf('=') + 1) : null;
		String retVal;
		if (isNotEmpty(documentURL)) {
			retVal = documentURL.substring(documentURL.lastIndexOf('=') + 1);
			if(!((retVal.length() == 15 || retVal.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', retVal) && retVal.startsWith(Document.sObjectType.getDescribe().getKeyPrefix()))) {
				retVal = null;
			}
		}
		return retVal;
	}
	
	public static String getUserAccessLevel(){
		String userId = String.valueOf(UserInfo.getUserId());
		String userAccessLevel = 'accessDenied';
		List<GroupMember> currentUserGroup = [select GroupId, Group.Name, UserOrGroupId from GroupMember where UserOrGroupId =: userId and Group.Name IN ('CHV_View_Limited_Group', 'CHV_Super_User_Group', 'CHV_View_All_Group')];
		if (listNotEmpty(currentUserGroup)) {
			if (isNotEmpty(currentUserGroup[0].Group.Name)) {
				if ((currentUserGroup[0].Group.Name).equals('CHV_Super_User_Group') || (currentUserGroup[0].Group.Name).equals('CHV_View_All_Group')){
					userAccessLevel = 'viewAllContent';
				}
				else if ((currentUserGroup[0].Group.Name).equals('CHV_View_Limited_Group')) {
					userAccessLevel = 'viewUnrestrictedContent';
				}
			}
		}
		//users not belonging to CHV groups but assigned to profiles that can view whole CHV content
		else {
			Profile p = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
			if ((p.Name).equals('GNE-SYS-Support') || (p.Name).equals('GNE-SFA-InternalUser') || (p.Name).equals('System Administrator')){
				userAccessLevel = 'viewAllContent';
			}
		}
		return userAccessLevel;
	}
	
	public static String getCurrentTimeInTimestampGMT() {
		 return String.valueOf(System.now().getTime()/1000);
	}
	
	public static Boolean isNotEmpty(String s){
		return s != null && '' != s; 
	}
	
	public static Boolean listNotEmpty(List<Object> l){
		return l!= null && !l.isEmpty();
	}

}