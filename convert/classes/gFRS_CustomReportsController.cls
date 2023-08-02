public with sharing class gFRS_CustomReportsController {
    
    public Boolean masterReportVisible {get; set;}
    
    public gFRS_CustomReportsController(){
        Id myUserId                                  = UserInfo.getUserId();
        PermissionSet myPS                           = [SELECT Id, Name FROM PermissionSet WHERE Name = 'gFRS_Compliance_Flags_Notes' LIMIT 1];
        Profile myProfile                            = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<PermissionSetAssignment> myPSAssignment = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =:myUserId AND PermissionSetId =:myPS.Id];
    	
    	if(UserInfo.getProfileId() == myProfile.Id){
    		masterReportVisible = true;
    	}else{
	    	if( myPSAssignment.size() > 0 ){
	    		masterReportVisible = true;
	    	}else{
	    		masterReportVisible = false;
	    	}
    	}
    }
}