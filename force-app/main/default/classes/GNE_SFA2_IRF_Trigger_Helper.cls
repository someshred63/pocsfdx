/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-08-21
*  Description: This is a helper class for GNE_SFA2_IRF_Trigger
*  Test class: GNE_SFA2_IRF_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_IRF_Trigger_Helper {
	
	/*
	//Email Notification helper methods.
    public static List<Messaging.SingleEmailMessage> sendEmailNotification(Boolean isInsert, List<Issue_gne__c> issueList){
        List<Messaging.SingleEmailMessage> messagesToSend = new List<Messaging.SingleEmailMessage>();
        for(Issue_gne__c issue : issueList){
        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        	if(isInsert){    
		    	List<String> ccAddress = ccRecipent(issue);
		        message.setCcAddresses(ccAddress);
        	}
		    String sender = issue.LastModifiedBy.FirstName + ' ' + issue.LastModifiedBy.LastName;
		    message.setsenderDisplayName(sender);
		    String replyToAddress = issue.LastModifiedBy.Email;
		    message.setreplyTo(replyToAddress);
		    List<String> sendTo = recipent(issue);
		    message.settoAddresses(sendTo);
		    String emailSubject = issue.Name + ' has been assigned to ' + issue.Assigned_FRM_gne__r.FirstName +' '+issue.Assigned_FRM_gne__r.LastName;
		    message.setsubject(emailSubject);
		    String notificationBody = emailNotificationContent(issue);
		    message.sethtmlBody(notificationBody);
		    messagesToSend.add(message);
        }
        Messaging.sendEmail(messagesToSend);
        return messagesToSend; 
    }
    
    private static List<String> recipent(Issue_gne__c issue){
        List<String> rec = new List<String>();
        rec.add(issue.Assigned_FRM_gne__r.Email);
        return rec;
    }
    
    private static List<String> ccRecipent(Issue_gne__c issue){
        List<String> ccRec = new List<String>();
        ccRec.add(issue.CreatedBy.Email);
        return ccRec;
    }
    
    private static String emailNotificationContent(Issue_gne__c issue){
        String emailContent = '';
        String products = issue.Product_gne__c;
    	products = products.replaceAll(';',', ');
        //CSS
        emailContent += '<head><style type="text/css">p{font-family:\'Verdana\',\'Geneva\',sans-serif;font-size:14px;}.title{font-family:\'Verdana\',\'Geneva\',sans-serif;width:100%;font-size:11px;border-collapse:collapse;}.content{font-family:\'Verdana\',\'Geneva\',sans-serif;width:100%;font-size:11px;border-collapse:collapse;}.titleLabel{background-color:#EEECD1;color:#333;width:250px;height:17px;border-bottom:1px #fff solid;font-size:11px;font-weight:bold;padding-left:10px;}.titleValue{background-color:#EEECD1;border-bottom:1px #fff solid;}.label{background-color:#F3F3EC;color:#333;width:140px;height:17px;border-bottom:1px #E3DEB8 solid;text-align:right;font-size:10px;font-weight:bold;padding-right:10px;}.value{background-color:#F3F3EC;color:#333;border-bottom:1px #E3DEB8 solid;padding-left:10px;}.lastLabel{background-color:#F3F3EC;color:#333;height:18px;text-align:right;font-size:10px;font-weight:bold;padding-right:10px;}.lastValue{background-color:#F3F3EC;color:#333;padding-left:10px;}</style></head>';
        //Notification header
        emailContent += '<p>The&nbsp;<a href="https://login.salesforce.com/'+issue.Id+'">'+ issue.Name +'</a>&nbsp;has been assigned to&nbsp;'+ issue.Assigned_FRM_gne__r.FirstName +' '+issue.Assigned_FRM_gne__r.LastName+ '&nbsp;by&nbsp;'+issue.LastModifiedBy.FirstName + ' '+issue.LastModifiedBy.LastName+'.</p>';
        //Table	
        emailContent += '<table class="title"><tr><td class="titleLabel">Issue Resolution Form Detail</td><td class="titleValue"></td></tr></table>';
        emailContent += '<table class="content"><tr><td class="label">Practice</td><td class="value">'+issue.Practice_Name_frm_gne__r.Name+'</td></tr>';
        if(issue.Issue_Source_frm_gne__c != null){
            emailContent += '<tr><td class="label">Issue Source</td><td class="value">'+issue.Issue_Source_frm_gne__c+'</td></tr>';
        } else {
            emailContent += '<tr><td class="label">Issue Source</td><td class="value">'+'</td></tr>';
        }
        if(issue.Product_gne__c != null){
            emailContent += '<tr><td class="lastLabel">Product(s)</td><td class="lastValue">'+products+'</td></tr></table>';
        } else {
            emailContent += '<tr><td class="lastLabel">Product</td><td class="lastValue">'+'</td></tr></table>';
        }
        //Notes
        emailContent +='<p>'+System.Label.IRF_Email_Notification_Please_Note+'<p>';
        emailContent +='<p>'+System.Label.IRF_Email_Notification_Confidentiality_Note+'</p>';
        
        return emailContent;
    }
    */ 
}