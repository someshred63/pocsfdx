//********************************************************************************************************//
//  Controller Class for Email Functionality For MPS Users
//
//  Created Date:   17 June, 2013       Created By:                     Version Comments: New Class
//  Modified Date:                      Modified By:                    Version Comments: 
// 
//
// ********************************************************************************************************//
public without sharing class GNE_CM_MPS_BenefitReverificationEmail {
    
    public static String emailHtmlBodyNewListRituxanRA =
        'Dear %USER_NAME%,<br/><br/>' +
        'A new Anticipated Access Rituxan (for RA) patient list is available for your review and processing. '+
        +'With the Benefits Reverification feature in the Genentech Access Solutions My Patient Solutions system, you can select multiple patients at once and request Benefits Reverifications. '
        +'Patients are made available through this feature based on their dosing cycle and the preferred time interval your practice selected when signing up for this program. <br/><br/>'
        +'If you need further assistance, please contact us at (866) 4ACCESS / (866) 422-2377, 6am - 5pm PST, Monday through Friday.<br/><br/>' +
        'Thank You,<br/><br/>' +
        'Genentech Access Solutions<br/><br/><br/>' +
        'If you no longer wish to receive email notifications for this type of Alert from My Patient Solutions, please log in to My Patient Solutions, click on My Profile Settings and change your Email and Location Settings.<br/><br/>' +
        'If you wish to stop receiving email notifications for all Alerts, ' + 
        '<a href="mailto:%UNSUB_EMAIL%?subject=Unsubscribe%20from%20Email%20Alerts.&' +
        'body=Dear%20Genentech%20Access%20Solutions%2C%0A%0AThis%20email%20confirms%20that%20I%20no%20longer%20wish%20to%20receive%20email%20alerts%20from%20My%20Patient%20Solutions.' +
        '%0A%0ANOTE%3A%20We%20cannot%20respond%20to%20emails%20sent%20to%20this%20mailbox.%20%20If%20you%20have%20questions%20please%20contact%20Genentech%20Access%20Solutions%20at%20866-4-ACCESS.' + '"> click here to Unsubscribe </a>.<br/><br/>' +
        '------------------------------------------------------------------------------------------------------------------------<br/>' +
        'This is an automated message. Please do not reply to this message.';
    public static String emailHtmlBodySubmissionActemraAndLucentis =
        'Dear %USER_NAME%,<br/><br/>' +
        'You have successfully submitted %PatientCount% patient(s) using the Benefits Reverification feature in My Patient Solutions (MPS). '+
        +'These patients will no longer show up in your Benefits Reverification list unless you choose to see them by changing the settings '+
        +'under the "Display Patients" filter.<br/><br/>'  
        +'Please retain this email for your records.<br/><br/>'
        +'If you need further assistance, please contact us at (866) 4ACCESS / (866) 422-2377, 6am - 5pm PST, Monday through Friday.<br/><br/>' +
        'Thank You,<br/><br/>' +
        'Genentech Access Solutions<br/><br/><br/>' +
        'If you no longer wish to receive email notifications for this type of Alert from My Patient Solutions, please log in to My Patient Solutions, click on My Profile Settings and change your Email and Location Settings.<br/><br/>' +
        'If you wish to stop receiving email notifications for all Alerts, ' + 
        '<a href="mailto:%UNSUB_EMAIL%?subject=Unsubscribe%20from%20Email%20Alerts.&' +
        'body=Dear%20Genentech%20Access%20Solutions%2C%0A%0AThis%20email%20confirms%20that%20I%20no%20longer%20wish%20to%20receive%20email%20alerts%20from%20My%20Patient%20Solutions.' +
        '%0A%0ANOTE%3A%20We%20cannot%20respond%20to%20emails%20sent%20to%20this%20mailbox.%20%20If%20you%20have%20questions%20please%20contact%20Genentech%20Access%20Solutions%20at%20866-4-ACCESS.' + '"> click here to Unsubscribe </a>.<br/><br/>' +
        '------------------------------------------------------------------------------------------------------------------------<br/>' +
        'This is an automated message. Please do not reply to this message.';
    public static String emailHtmlBodySubmissionRituxan =
        'Dear %USER_NAME%,<br/><br/>' +
        'You have successfully submitted patient list #%SubmissionName% using the Benefits Reverification feature in My Patient Solutions (MPS). '+
        +'This patient list was for %PrescriberFirstName% %PrescriberLastName% for patients taking %Product% being treated at location %Location%.  Please retain this email for your records. <br/><br/>'
        +'If you need further assistance, please contact us at (866) 4ACCESS / (866) 422-2377, 6am - 5pm PST, Monday through Friday.<br/><br/>' +
        'Thank You,<br/><br/>' +
        'Genentech Access Solutions<br/><br/><br/>' +
        'If you no longer wish to receive email notifications for this type of Alert from My Patient Solutions, please log in to My Patient Solutions, click on My Profile Settings and change your Email and Location Settings.<br/><br/>' +
        'If you wish to stop receiving email notifications for all Alerts, ' + 
        '<a href="mailto:%UNSUB_EMAIL%?subject=Unsubscribe%20from%20Email%20Alerts.&' +
        'body=Dear%20Genentech%20Access%20Solutions%2C%0A%0AThis%20email%20confirms%20that%20I%20no%20longer%20wish%20to%20receive%20email%20alerts%20from%20My%20Patient%20Solutions.' +
        '%0A%0ANOTE%3A%20We%20cannot%20respond%20to%20emails%20sent%20to%20this%20mailbox.%20%20If%20you%20have%20questions%20please%20contact%20Genentech%20Access%20Solutions%20at%20866-4-ACCESS.' + '"> click here to Unsubscribe </a>.<br/><br/>' +
        '------------------------------------------------------------------------------------------------------------------------<br/>' +
        'This is an automated message. Please do not reply to this message.';        
    public static String emailHtmlBodyNewListLucentis =
        'Dear %USER_NAME%,<br/><br/>' +
        'You can now request Benefits Reverifications for multiple patients at once for LUCENTISÂ®. Process your patient enrollments now before the start of the annual Benefits Reverification season, also known as â€œThe Blizzardâ€. ' +
        'The Benefits Reverification feature will be available in MPS under the Enroll Patients tab from November 18, %lst_year% through December 31, %lst_year%. ' +
        'Genentech Access Solutions will conduct these Benefits Reverifications in January, %nxt_year%. <br/><br/>'
        +'If you need further assistance, please contact us at (866) 4ACCESS / (866) 422-2377, 6am - 5pm PST, Monday through Friday.<br/><br/>' +
        'Thank You,<br/><br/>' +
        'Genentech Access Solutions<br/><br/><br/>' +
        'If you no longer wish to receive email notifications for this type of Alert from My Patient Solutions, please log in to My Patient Solutions, click on My Profile Settings and change your Email and Location Settings.<br/><br/>' +
        'If you wish to stop receiving email notifications for all Alerts, ' + 
        '<a href="mailto:%UNSUB_EMAIL%?subject=Unsubscribe%20from%20Email%20Alerts.&' +
        'body=Dear%20Genentech%20Access%20Solutions%2C%0A%0AThis%20email%20confirms%20that%20I%20no%20longer%20wish%20to%20receive%20email%20alerts%20from%20My%20Patient%20Solutions.' +
        '%0A%0ANOTE%3A%20We%20cannot%20respond%20to%20emails%20sent%20to%20this%20mailbox.%20%20If%20you%20have%20questions%20please%20contact%20Genentech%20Access%20Solutions%20at%20866-4-ACCESS.' + '"> click here to Unsubscribe </a>.<br/><br/>' +
        '------------------------------------------------------------------------------------------------------------------------<br/>' +
        'This is an automated message. Please do not reply to this message.';
    public static String emailHtmlBodyNewListActemra =
        'Dear %USER_NAME%,<br/><br/>' +
        'You can now request Benefits Reverifications for multiple patients at once for ACTEMRAÂ®. Process your patient enrollments now before the start of the annual Benefits Reverification season, also known as â€œThe Blizzardâ€. ' +
        'The Benefits Reverification feature will be available in MPS under the Enroll Patients tab from November 18, %lst_year% through December 31, %lst_year%. ' +
        'Genentech Access Solutions will conduct these Benefits Reverifications in January, %nxt_year%. <br/>'
        +'If you need further assistance, please contact us at (866) 4ACCESS / (866) 422-2377, 6am - 5pm PST, Monday through Friday.<br/><br/>' +
        'Thank You,<br/><br/>' +
        'Genentech Access Solutions<br/><br/><br/>' +
        'If you no longer wish to receive email notifications for this type of Alert from My Patient Solutions, please log in to My Patient Solutions, click on My Profile Settings and change your Email and Location Settings.<br/><br/>' +
        'If you wish to stop receiving email notifications for all Alerts, ' + 
        '<a href="mailto:%UNSUB_EMAIL%?subject=Unsubscribe%20from%20Email%20Alerts.&' +
        'body=Dear%20Genentech%20Access%20Solutions%2C%0A%0AThis%20email%20confirms%20that%20I%20no%20longer%20wish%20to%20receive%20email%20alerts%20from%20My%20Patient%20Solutions.' +
        '%0A%0ANOTE%3A%20We%20cannot%20respond%20to%20emails%20sent%20to%20this%20mailbox.%20%20If%20you%20have%20questions%20please%20contact%20Genentech%20Access%20Solutions%20at%20866-4-ACCESS.' + '"> click here to Unsubscribe </a>.<br/><br/>' +
        '------------------------------------------------------------------------------------------------------------------------<br/>' +
        'This is an automated message. Please do not reply to this message.';
    
    private static String unsubEmail;     
    public static void emailToMPSUsers(Set<ID> regIds, String product)
    {
        system.debug('INside emailToMPSUsers');      
        Map<Id, String> sfdcUserContactToFullName = new Map<Id, String>();
        Map<String, List<Environment_Variables__c>> envs = GNE_CM_MPS_Utils.populateEnvVariables(new Set<String>{'GNE_CM_MPS_Portal_Address', 'UNSUBSCRIBE_EMAIL'});
        List<Environment_Variables__c> unsubEmails = envs.get('UNSUBSCRIBE_EMAIL');
        
        if (unsubEmails != null && unsubEmails.size() > 0)
        {
            unsubEmail = unsubEmails.get(0).Value__c;
        }
        else
        {
            throw new GNE_CM_Exception('"UNSUBSCRIBE_EMAIL" Environment variable is missing. Please contact administrator.');
        }
        
        Set<Id> mpsSfdcUserContactIds = new Set<Id>();
        Map<Id, String> contactIdToEmailMap = new Map<Id, String>();
        List<GNE_CM_MPS_User__c> mpsUserList = new List<GNE_CM_MPS_User__c>();
        mpsUserList = [Select id, Admin__c, GNE_CM_MPS_Registration__c, Email_address__c, 
                                                First_Name__c, Last_Name__c, SFDC_User__r.Contact.Email, SFDC_User__r.ContactId 
                                                from GNE_CM_MPS_User__c where Admin__c = true 
                                                AND Disabled__c != true and GNE_CM_MPS_Registration__c in :regIds];
                                                
        if (mpsUserList != null && mpsUserList.size() > 0)
        { 
            for (GNE_CM_MPS_User__c mpsUserObj : mpsUserList)
            {
                if (mpsUserObj.SFDC_User__r.ContactId != null)
                {
                    contactIdToEmailMap.put(mpsUserObj.SFDC_User__r.ContactId, mpsUserObj.SFDC_User__r.Contact.Email);
                    mpsSfdcUserContactIds.add(mpsUserObj.SFDC_User__r.ContactId);
                    sfdcUserContactToFullName.put(mpsUserObj.SFDC_User__r.ContactId, mpsUserObj.First_Name__c + ' ' + mpsUserObj.Last_Name__c);
                }
            }   
        }
        
        string todayDate         = String.ValueOf(system.Today()); 
        String[] todayDateArray  = todayDate.split('-');
        integer currentYear      = Integer.valueof(todayDateArray[0]);
        integer nextYear         = currentYear+1;
                 
        
        
        List<Messaging.SingleEmailMessage> mailPack = new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = new EmailTemplate();
        if (product == 'RituxanRA')
        {
            for (Id userContactId : mpsSfdcUserContactIds)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToaddresses(new List<String>{contactIdToEmailMap.get(userContactId)});
                mail.setSubject('A new Rituxan (for RA) patient list is available for processing using the Benefits Reverification feature in MPS');
                mail.setReplyTo('MyPatientSolutions-DoNotReply@gene.com');
                mail.setSenderDisplayName('Genentech Portal Support');
                mail.setHtmlBody(emailHtmlBodyNewListRituxanRA.replace('%USER_NAME%', sfdcUserContactToFullName.get(userContactId))
                                                                    .replace('%UNSUB_EMAIL%', unsubEmail));
                mailPack.add(mail);
            }
        }
        else if (product == 'Actemra')
        {
            for (Id userContactId : mpsSfdcUserContactIds)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToaddresses(new List<String>{contactIdToEmailMap.get(userContactId)});
                mail.setSubject('Benefits Reverification feature is here for My Patient Solutions users for ACTEMRA.');
                mail.setReplyTo('MyPatientSolutions-DoNotReply@gene.com');
                mail.setSenderDisplayName('Genentech Portal Support');
                mail.setHtmlBody(emailHtmlBodyNewListActemra.replace('%USER_NAME%', sfdcUserContactToFullName.get(userContactId))
                                                        .replace('%lst_year%', String.valueOf(currentYear))
                                                        .replace('%nxt_year%', String.valueOf(nextYear))
                                                        .replace('%UNSUB_EMAIL%', unsubEmail));
                mailPack.add(mail);
            }
        }
        else if (product == 'Lucentis')
        {
            for (Id userContactId : mpsSfdcUserContactIds)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToaddresses(new List<String>{contactIdToEmailMap.get(userContactId)});
                mail.setSubject('Benefits Reverification feature is here for My Patient Solutions users for LUCENTIS.');
                mail.setReplyTo('MyPatientSolutions-DoNotReply@gene.com');
                mail.setSenderDisplayName('Genentech Portal Support');
                mail.setHtmlBody(emailHtmlBodyNewListLucentis.replace('%USER_NAME%', sfdcUserContactToFullName.get(userContactId))
                                                        .replace('%lst_year%', String.valueOf(currentYear))
                                                        .replace('%nxt_year%', String.valueOf(nextYear))
                                                        .replace('%UNSUB_EMAIL%', unsubEmail));
                mailPack.add(mail);
            }
        }
        
        if (mailPack.size() > 0)
        {
            Messaging.sendEmail(mailPack, false);
        } 
    }
    
    public static void sendSubmitConfirmationEmail(String regId, String SubmissionId, String product, Integer patientCount)
    {       
        
        system.debug('PRODUCT::: ' + Product);
        system.debug('SUB NUM::: '+ SubmissionId);
        Set<Id> emailRecipient = new Set<Id>();
        
        // maps user email to user name
        Map<Id, String> sfdcUserContactToFullName = new Map<Id, String>();
        
        Set<Id> allemailRecipients = new Set<Id>();
        Map<Id, String> contactIdToEmailMap = new Map<Id, String>();
        List<GNE_CM_MPS_User_Preferences__c> mpsUserPreferenceList = new List<GNE_CM_MPS_User_Preferences__c>();
        
        List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id, First_name__c, Last_Name__c, Email_address__c, GNE_CM_MPS_Registration__c,
                                             SFDC_User__r.Contact.Email, SFDC_User__r.ContactId 
                                            FROM GNE_CM_MPS_User__c 
                                            WHERE SFDC_User__c = :UserInfo.getUserId()];
        Map<String, List<Environment_Variables__c>> envs = GNE_CM_MPS_Utils.populateEnvVariables(new Set<String>{'GNE_CM_MPS_Portal_Address', 'UNSUBSCRIBE_EMAIL'});
        List<Environment_Variables__c> unsubEmails = envs.get('UNSUBSCRIBE_EMAIL');
        
        if (unsubEmails != null && unsubEmails.size() > 0)
        {
            unsubEmail = unsubEmails.get(0).Value__c;
        }
        else
        {
            throw new GNE_CM_Exception('"UNSUBSCRIBE_EMAIL" Environment variable is missing. Please contact administrator.');
        }
        
        if (!mpsUsers.isEmpty())
        {
            emailRecipient.add(mpsUsers[0].SFDC_User__r.ContactId);
            sfdcUserContactToFullName.put(mpsUsers[0].SFDC_User__r.ContactId, mpsUsers[0].First_Name__c + ' ' + mpsUsers[0].Last_Name__c);
        }
        
        system.debug('ER 1::: ' + emailRecipient);
        mpsUserPreferenceList = [SELECT id, MPS_User__c, Email_Settings__c, MPS_User__r.Email_address__c, MPS_User__r.SFDC_User__r.Contact.Email, 
                                    MPS_User__r.SFDC_User__r.ContactId, MPS_User__r.First_Name__c, MPS_User__r.Last_Name__c
                                    FROM GNE_CM_MPS_User_Preferences__c 
                                    WHERE MPS_User__r.GNE_CM_MPS_Registration__c = :regId
                                    AND MPS_User__r.Disabled__c != true];
        
        if (mpsUserPreferenceList != null && mpsUserPreferenceList.size() > 0)
        { 
            for (GNE_CM_MPS_User_Preferences__c mpsUserPreferenceObj : mpsUserPreferenceList)
            {
                if (mpsUserPreferenceObj.Email_Settings__c != null && mpsUserPreferenceObj.Email_Settings__c.contains('Benefits Reverification'))
                {
                    if (mpsUserPreferenceObj.MPS_User__r.SFDC_User__r != null && mpsUserPreferenceObj.MPS_User__r.SFDC_User__r.ContactId != null)
                    {
                        emailRecipient.add(mpsUserPreferenceObj.MPS_User__r.SFDC_User__r.ContactId);
                        contactIdToEmailMap.put(mpsUserPreferenceObj.MPS_User__r.SFDC_User__r.ContactId, mpsUserPreferenceObj.MPS_User__r.SFDC_User__r.Contact.Email);  
                        sfdcUserContactToFullName.put(mpsUserPreferenceObj.MPS_User__r.SFDC_User__r.ContactId, mpsUserPreferenceObj.MPS_User__r.First_Name__c + ' ' + mpsUserPreferenceObj.MPS_User__r.Last_Name__c);
                    }
                }
            }   
        }
        allemailRecipients.addAll(emailRecipient);    
        BRC_Submission__c BRC = [Select id, Name, Prescriber_Account__r.FirstName, 
                                Prescriber_Account__r.LastName, MPS_Location__r.Office_Location_Address__c, 
                                MPS_Location__r.Suite__c, MPS_Location__r.State__c, MPS_Location__r.City__c,
                                MPS_Location__r.Zip__c, Product__c, Address__r.Name from BRC_Submission__c where id =:SubmissionId];
        List<Messaging.SingleEmailMessage> mailPack = new List<Messaging.SingleEmailMessage>();
        
        for (Id userContactId : allemailRecipients)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToaddresses(new List<String>{contactIdToEmailMap.get(userContactId)});
            mail.setReplyTo('MyPatientSolutions-DoNotReply@gene.com');
            mail.setSenderDisplayName('Genentech Portal Support');
            if (product == 'Rituxan RA') {
            mail.setSubject('You have successfully submitted patient list #'+BRC.Name+' for Benefits Reverification in MPS.');
                mail.setHtmlBody(emailHtmlBodySubmissionRituxan.replace('%USER_NAME%', sfdcUserContactToFullName.get(userContactId))
                                .replace('%SubmissionName%',BRC.Name)
                                .replace('%PrescriberFirstName%',BRC.Prescriber_Account__r.FirstName)
                                .replace('%PrescriberLastName%',BRC.Prescriber_Account__r.LastName)
                                .replace('%Product%',BRC.Product__c)
                                .replace('%Location%',BRC.MPS_Location__r.Office_Location_Address__c + ' ' + BRC.MPS_Location__r.City__c + ' ' + BRC.MPS_Location__r.State__c + ' ' + BRC.MPS_Location__r.Zip__c)
                                .replace('%UNSUB_EMAIL%', unsubEmail));
            } else {
                mail.setSubject('You have successfully submitted ' + patientCount + ' patient(s) for benefits reverification in MPS.');
                mail.setHtmlBody(emailHtmlBodySubmissionActemraAndLucentis.replace('%USER_NAME%', sfdcUserContactToFullName.get(userContactId))
                                .replace('%PatientCount%', String.valueOf(patientCount))
                                .replace('%UNSUB_EMAIL%', unsubEmail));
            }
            mailPack.add(mail);
        }
        if (mailPack.size() > 0)
        {
            Messaging.sendEmail(mailPack, false);
        }     
    }
}