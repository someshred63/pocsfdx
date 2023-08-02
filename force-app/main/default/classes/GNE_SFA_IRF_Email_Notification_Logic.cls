public without sharing class GNE_SFA_IRF_Email_Notification_Logic 
{
    public void emailNotification(Boolean isInsert, List<Issue_gne__c> issueList)
    {
        for(Issue_gne__c issue : issueList)
        {
            sendEmailNotification(isInsert, issue);
        }
    }
    private void sendEmailNotification(Boolean isInsert, Issue_gne__c issue)
    {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(isInsert == true)
        {
            List<String> ccAddress = ccRecipent(issue);
            message.setCcAddresses(ccAddress);
        }
        String sender = notificationSender(issue);
        message.setsenderDisplayName(sender);
        String replyToAddress = replyToSender(issue);
        message.setreplyTo(replyToAddress);
        List<String> sendTo = recipent(issue);
        message.settoAddresses(sendTo);
        String notSubject = notificationSubject(issue);
        message.setsubject(notSubject);
        String notificationBody = emailNotificationContent(issue);
        message.sethtmlBody(notificationBody);
        List<Messaging.SendEmailResult> results =  Messaging.sendEmail(new Messaging.Email[] {  message });
        sendTo.clear(); 
    }
    private List<String> recipent(Issue_gne__c issue)
    {
        List<String> target = new List<String>();
        target.add(issue.Assigned_FRM_gne__r.Email);
        return target;
    }
    private List<String> ccRecipent(Issue_gne__c issue)
    {
        List<String> ccTarget = new List<String>();
        ccTarget.add(issue.CreatedBy.Email);
        return ccTarget;
    }
    private String notificationSender(Issue_gne__c issue)
    {
        String sendFrom = issue.LastModifiedBy.FirstName + ' ' + issue.LastModifiedBy.LastName;
        return sendFrom;
    }
    private String replyToSender(Issue_gne__c issue)
    {
        String replyToSender = issue.LastModifiedBy.Email;
        return replyToSender;
    }
    private String emailNotificationContent(Issue_gne__c issue)
    {
        String sendThis = '';
        String orgId = UserInfo.getOrganizationId();
        //if(orgId == '00D70000000Irda')
        //{
            sendThis += 'The&nbsp;<a href="https://login.salesforce.com/'+issue.Id+'">'+ issue.Name +'</a>&nbsp;has been assigned to&nbsp;'+ issue.Assigned_FRM_gne__r.FirstName +' '+issue.Assigned_FRM_gne__r.LastName+ '&nbsp;by&nbsp;'+issue.LastModifiedBy.FirstName + ' '+issue.LastModifiedBy.LastName+'.<br/><br/>';
        //}
        //else
        //{
        //sendThis += 'The&nbsp;<a href="https://test.salesforce.com/'+issue.Id+'">'+ issue.Name +'</a>&nbsp;has been assigned to&nbsp;'+ issue.Assigned_FRM_gne__r.FirstName +' '+issue.Assigned_FRM_gne__r.LastName+ '&nbsp;by&nbsp;'+issue.LastModifiedBy.FirstName + ' '+issue.LastModifiedBy.LastName+'.<br/><br/>';
        //}
        sendThis += 'IRF Summary:<br/>';
        sendThis += '<table>';
        sendThis += '<tr><td style="border-bottom:1px #ccc dotted;"><b>Practice:</b></td><td style="border-bottom:1px #ccc dotted;">'+issue.Practice_Name_frm_gne__r.Name+'</td></tr>';
        if(issue.Issue_Source_frm_gne__c != null)
        {
            sendThis += '<tr><td style="border-bottom:1px #ccc dotted;"><b>Issue Source:</b></td><td style="border-bottom:1px #ccc dotted;">'+issue.Issue_Source_frm_gne__c+'</td></tr>';
        }
        else
        {
            sendThis += '<tr><td style="border-bottom:1px #ccc dotted;"><b>Issue Source:</b></td><td style="border-bottom:1px #ccc dotted;">'+'</td></tr>';
        }
        if(issue.Product_gne__c != null)
        {
            sendThis += '<tr><td style="border-bottom:1px #ccc dotted;"><b>Product:</b></td><td style="border-bottom:1px #ccc dotted;">'+issue.Product_gne__c+'</td></tr>';
        }
        else
        {
            sendThis += '<tr><td style="border-bottom:1px #ccc dotted;"><b>Product:</b></td><td style="border-bottom:1px #ccc dotted;">'+'</td></tr>';
        }
        sendThis += '</table><br/><br/>';
        sendThis +='Please Note: In order to access this IRF, you must access it via your laptop and also be signed in to the web-based version of SFDC. You will not be able to access the IRF link from your iPhone or iPad.<br/><br/>';
        sendThis +='Confidentiality Note: This message is intended only for the use of the named recipient(s) and may contain confidential and/or proprietary information. If you are not the intended recipient, please contact the sender and delete this message. Any unauthorized use of the information contained in this message is prohibited.';
        return sendThis;
    }
    private String notificationSubject(Issue_gne__c issue)
    {
        String subject = issue.Name + ' has been assigned to ' + issue.Assigned_FRM_gne__r.FirstName +' '+issue.Assigned_FRM_gne__r.LastName;
        return subject;
    }
    
}