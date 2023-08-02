/** @date 7/27/2013
* @Author Paweł Sprysak
* @description Controller for Header
*/
public without sharing class VDST_HeaderController {
    public String emailContent { get; set; }

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Method for sending email to gSSP Support Team
    * @return PageReference
    */
    public PageReference sendEmail() {
        String adminEmail = 'oconnell.james@gene.com';
        VDST_Settings__c vdstSet = VDST_Utils.getCustomSettingsIntExt();
        if(vdstSet != null) {
            String userName = vdstSet.Admin_Username__c;
            if(userName != null) {
                User usr = [SELECT Email FROM User WHERE Username = :userName LIMIT 1];
                if(usr != null) {
                    adminEmail = usr.Email;
                }
            }
        }
        String body = '<p>' + emailContent + '</p>';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[]{ adminEmail }; //gssp-support-d@gene.com
        mail.setToAddresses(toAddress);
        //mail.setSenderDisplayName('gSSP Support');
        mail.setSubject('Genentech Spend Submission Portal - Contact Us');
        mail.setHtmlBody(body);
        Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
        return null;
    }
}