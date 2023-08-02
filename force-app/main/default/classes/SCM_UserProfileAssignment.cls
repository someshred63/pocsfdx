global class SCM_UserProfileAssignment
{
    webService String Row_ID;
    webService String Status;
    webService String SFDC_User_Id;
    webService String [] SCM_Group_Id;
    
    public static SCM_UserProfileAssignment getSCM_UserProfileAssignment(String varRowId, String varStatus, 
                                      String varUser, List<String> groupId)
    {
         SCM_UserProfileAssignment assignment= new SCM_UserProfileAssignment();
         assignment.Row_ID = varRowId;
         assignment.Status = varStatus;
         assignment.SFDC_User_Id = varUser;
         assignment.SCM_Group_Id = groupId;
         return assignment;
    }
    static testMethod void SCM_SecurityUnitTest() {
             SCM_UserProfileAssignment.getSCM_UserProfileAssignment('', '', '',new  List<String>());
        }
}