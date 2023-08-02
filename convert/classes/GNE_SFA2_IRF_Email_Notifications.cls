/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-12
*  Description: This is a helper class for handling IRF e-mail notifications
*  Test class: GNE_SFA2_IRF_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_IRF_Email_Notifications {
	
	//Email Notification is based on the Workflow Rules: GNE_SFA2_IRF_Assignment_On_Insert & GNE_SFA2_IRF_Assignment_On_Update 
	
	/*
	private static void emailNotificationWhenIssueInsert(List<Issue_gne__c> triggerNew){
    	List<Issue_gne__c> currentIssue = new List<Issue_gne__c>();
        for(Issue_gne__c issue : triggerNew){
            if (issue.Status_frm_gne__c == 'Open'){
                currentIssue.add(issue);
            }
        }        
        List<Issue_gne__c> issueToSend =  new List<Issue_gne__c>([Select Id, Name, Assigned_FRM_gne__c, Assigned_FRM_gne__r.Email,CreatedById, CreatedBy.Email, LastModifiedById, LastModifiedBy.LastName, LastModifiedBy.FirstName, LastModifiedBy.Email, Assigned_FRM_gne__r.LastName, Assigned_FRM_gne__r.FirstName, Practice_Name_frm_gne__c, Practice_Name_frm_gne__r.Name from Issue_gne__c where Id IN :currentIssue]);
        for(Issue_gne__c item : issueToSend){
            for(Issue_gne__c issue : currentIssue){
                if(item.Id == issue.Id){
                    item.Issue_Source_frm_gne__c = issue.Issue_Source_frm_gne__c;
                    item.Product_gne__c = issue.Product_gne__c;
                }
            }
        }              
        GNE_SFA2_IRF_Trigger_Helper.sendEmailNotification(true, issueToSend);
	}
	
	private static void emailNotificationWhenIssueUpdate(List<Issue_gne__c> triggerOld, List<Issue_gne__c> triggerNew){
    	List<Issue_gne__c> currentIssue = new List<Issue_gne__c>();
        for(Issue_gne__c issue : triggerNew){
            if ((issue.Status_frm_gne__c == 'Open' && issue.Assigned_FRM_gne__c != triggerOld[0].Assigned_FRM_gne__c) || (issue.Status_frm_gne__c == 'Open' && triggerOld[0].Status_frm_gne__c == 'Resolved')){
                currentIssue.add(issue);
            }
        }        
        List<Issue_gne__c> issueToSend =  new List<Issue_gne__c>([Select Id, Name, Assigned_FRM_gne__c, Assigned_FRM_gne__r.Email,CreatedById, CreatedBy.Email, LastModifiedById, LastModifiedBy.LastName, LastModifiedBy.FirstName, LastModifiedBy.Email, Assigned_FRM_gne__r.LastName, Assigned_FRM_gne__r.FirstName, Practice_Name_frm_gne__c, Practice_Name_frm_gne__r.Name from Issue_gne__c where Id IN :currentIssue]);
        for(Issue_gne__c item : issueToSend){
            for(Issue_gne__c issue : currentIssue){
                if(item.Id == issue.Id){
                    item.Issue_Source_frm_gne__c = issue.Issue_Source_frm_gne__c;
                    item.Product_gne__c = issue.Product_gne__c;
                }
            }
        }              
        GNE_SFA2_IRF_Trigger_Helper.sendEmailNotification(false, issueToSend);                         
	}
	
	public static void onAfterInsert(List<Issue_gne__c> triggerNew){
		emailNotificationWhenIssueInsert(triggerNew);	
	}
	
	public static void onAfterUpdate(List<Issue_gne__c> triggerOld, List<Issue_gne__c> triggerNew){
		emailNotificationWhenIssueUpdate(triggerOld, triggerNew);	
	}
	*/
}