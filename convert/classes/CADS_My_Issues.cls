public class CADS_My_Issues {
    
    List<CADS_Account_Address_Issues_gne__c> myIssues;
    Integer IssueCnt =0;
    public Boolean SalesTeam { get; set; }
        
    public CADS_My_Issues(){        
	    try
	    {
	        SalesTeam = true;
	        User actionOwner = [select External_ID_gne__c from user 
	                                            where id = :UserInfo.getUserId() limit 1];
	                
	        Id userH_Id = [select id from All_User_Hierarchy_gne__c
	                                                Where User_External_Id_gne__c = :actionOwner.External_ID_gne__c].id;
	                
	        this.myIssues = [Select Id, name, Current_Action_Type_gne__c,Current_Action_Comment_gne__c,Issue_Opened_Date_gne__c,Current_Action_Email_Date_gne__c,Current_Action_Condition_gne__c,
	                            Current_Action_Owner_gne__c
	                                    from CADS_Account_Address_Issues_gne__c
	                                    Where Current_Action_Owner_gne__c = :userH_Id // :UserInfo.getUserId()
	                                    and Current_Action_Email_Status_gne__c = 'Sent' and STEWARD_REVIEW_STS_gne__c !='N'
	                                    //and Current_Action_Type_gne__c  ='Corrective'
	                                    //and Email_Status_gne__c = 'Closed' 
	                                    order by Current_Action_Email_Date_gne__c ];
	        IssueCnt = myissues.size();
	        
	        /*
	        Id GroupId = [Select id from group where name = 'Data Stewardship'].id;
	            
	            Integer grpCnt = [Select count() FROM GroupMember 
	                                WHERE UserOrGroupId = :UserInfo.getUserId()
	                                and groupId = :GroupId];*/
	        List<Group> Groups = [Select id from group where name = 'Data Stewardship' or name='GNE-AGS-CCO-Manager-Group' or name='GNE-AGS-CCO-Analyst-Group' or name='GNE-AGS-CCO-TempAnalyst-Group' or name='GNE-AGS-CCO-TEAM'];
	            
	        List<Id> groupId = new List<Id>();
	        for(Group grp :Groups)
	        {
	        	groupId.add(grp.Id);
	        }
	        
	        Integer grpCnt = [Select count() FROM GroupMember 
	        WHERE UserOrGroupId = :UserInfo.getUserId()
	        and groupId in :groupId];
	        if (grpCnt == 0)
	            SalesTeam = true;
	        else
	            SalesTeam = false;
	    }
	    catch (Exception e)
	    {
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