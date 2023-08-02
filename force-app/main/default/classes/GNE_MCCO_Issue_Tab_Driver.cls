public class GNE_MCCO_Issue_Tab_Driver {


//Created By Claudia Morales, Veeva Systems for November 2009 SFA R2 Release 
//Version #: 1 
//Date: 8/31/2009 
//Begin Code: 
//For managing Issues 

public List<Issue_gne__c> myIssues {get; set;} 
public List<Issue_gne__c> myTerrIssues {get; set;} 

    public GNE_MCCO_Issue_Tab_Driver(ApexPages.StandardController stdController){ 
    
    //query for Open Issues that are Assigned to the active user 
    myIssues = [select id, Name, Physician_Name_frm_gne__c, Practice_Name_frm_gne__c, 
                           Clinical_Specialist__c, Assigned_FRM_gne__c, Assigned_To_gne__c, Due_Date_frm_gne__c,
                           createddate, lastmodifieddate, Status_frm_gne__c 
                    from Issue_gne__c    
                    where Status_frm_gne__c = 'Open' 
                            AND (Clinical_Specialist__c =: UserInfo.getUserId() OR
                            Assigned_FRM_gne__c =: UserInfo.getUserId() OR
                            Assigned_To_gne__c =: UserInfo.getUserId() )
                            order by due_date_frm_gne__c desc ]; 
                            

}
   
    public GNE_MCCO_Issue_Tab_Driver() { 
        
        //select existing Issues for current user
        } 
   
    public PageReference redirect(){
    
      PageReference pageRef = new PageReference('/a1t/e' );
            pageRef.setRedirect(true);
             return pageRef;

    
     }
}