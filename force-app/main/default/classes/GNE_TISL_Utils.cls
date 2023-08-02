public with sharing class GNE_TISL_Utils {
	
	public static final String TISL_PERMISSION_SET = 'TISL_Access_For_MSL';
	
	public static Boolean isCurrentUserMSLForTISL() {
		Boolean retVal = false;
		List<PermissionSet> TISLPermissionSets = [select Id from PermissionSet where Name = :TISL_PERMISSION_SET limit 1];
		if (TISLPermissionSets.isEmpty())
			return retVal;
		else {
			Id permissionSetTISLid = TISLPermissionSets[0].Id;
			retVal = Integer.valueOf([SELECT count(Id) counter FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() and PermissionSetId = :permissionSetTISLid][0].get('counter')) > 0;
		}
		return retVal;
	}
	
}