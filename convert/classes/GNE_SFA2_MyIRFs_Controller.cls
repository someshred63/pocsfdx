public with sharing class GNE_SFA2_MyIRFs_Controller extends GNE_SFA2_List_View_Base_Controller{
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    public List<Issue_gne__c> myIssues {get; set;}
    public boolean showMessage{
        get{
            if(myIssues.size() == 0) return true;
            else return false;
        }
    }
    
    public PageReference newClick() {
        //Schema.DescribeSObjectResult describeResult = Issue_gne__c.SObjectType.getDescribe();
        //PageReference newIRF = new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        PageReference newIRF = Page.GNE_SFA2_IRF_Edit_Create_Layout;
        newIRF.getParameters().put('retURL', '/apex/GNE_SFA2_MyIRFs'); 
        return newIRF;
    }
    
    public GNE_SFA2_MyIRFs_Controller() {
        super('Issue_gne__c');
        thisController = this;
    //query for Open Issues that are Assigned to the active user 
    myIssues = [select id, Name, Physician_Name_frm_gne__c, Practice_Name_frm_gne__c, 
                           Clinical_Specialist__c,Clinical_Specialist__r.firstname, Clinical_Specialist__r.lastname, Assigned_FRM_gne__r.firstname, Assigned_FRM_gne__r.lastname, Assigned_FRM_gne__c, Assigned_To_gne__c, Due_Date_frm_gne__c,
                           createddate, lastmodifieddate, Status_frm_gne__c 
                    from Issue_gne__c    
                    where Status_frm_gne__c = 'Open' 
                            AND (Clinical_Specialist__c =: UserInfo.getUserId() OR
                            Assigned_FRM_gne__c =: UserInfo.getUserId() OR
                            Assigned_To_gne__c =: UserInfo.getUserId() )
                            order by due_date_frm_gne__c desc ]; 
    }
}