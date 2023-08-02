public class GNE_SFA2_CADS_My_Issues_Controller {
	    
    private List<CADS_Account_Address_Issues_gne__c> myIssues;
    private Integer IssueCnt = 0;
    public Boolean SalesTeam { get; private set; }
        
    public GNE_SFA2_CADS_My_Issues_Controller(){
    	try {
    		SalesTeam = true;
    		List<User> actionUser = [select External_ID_gne__c from user where id = :UserInfo.getUserId()];
    		User actionOwner = (actionUser != null && actionUser.size() == 1) ? actionUser.get(0) : null;          	
          	if (actionOwner != null && !String.isBlank(actionOwner.External_ID_gne__c)){
          		List<All_User_Hierarchy_gne__c> userH = [select id from All_User_Hierarchy_gne__c Where User_External_Id_gne__c = :actionOwner.External_ID_gne__c];
          		Id userH_Id = (userH != null && userH.size() == 1) ? userH.get(0).Id : null;
          		if (userH_Id != null) {
          			this.myIssues = [Select Id, name, Current_Action_Type_gne__c,Current_Action_Comment_gne__c,Issue_Opened_Date_gne__c,Current_Action_Email_Date_gne__c,Current_Action_Condition_gne__c,
                              Current_Action_Owner_gne__c from CADS_Account_Address_Issues_gne__c
                                      Where Current_Action_Owner_gne__c = :userH_Id and Current_Action_Email_Status_gne__c = 'Sent' and STEWARD_REVIEW_STS_gne__c !='N'                                       
                                      order by Current_Action_Email_Date_gne__c];
          
          			IssueCnt = myIssues != null ? myIssues.size() : 0;
          
	        		List<Group> Groups = [Select id from group where name = 'Data Stewardship' or name='GNE-AGS-CCO-Manager-Group' or name='GNE-AGS-CCO-Analyst-Group' or name='GNE-AGS-CCO-TempAnalyst-Group' or name='GNE-AGS-CCO-TEAM'];
              
          			List<Id> groupId = new List<Id>();
          			if (Groups != null){
          				for(Group grp : Groups){
          					groupId.add(grp.Id);
          				}          	
          			}          
          
          			Integer grpCnt = [Select count() FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId() and groupId in :groupId];
          			if (grpCnt == 0)
              			SalesTeam = true;
          			else
              			SalesTeam = false;
          		}
          	}
      	} catch (Exception e) {
      		ApexPages.addMessages(e);
      	}
    }
    
    public list<CADS_Account_Address_Issues_gne__c> getMyIssues(){
        return myIssues;
    }
    
    public Integer getIssueCnt(){
        return IssueCnt;
    }
}