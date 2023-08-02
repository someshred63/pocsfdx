@IsTest
private class GFRS_NotificationUtilTest {

    private static final String OWEA = 'fundingrequestsystem-donotreply-d@gene.com';
    private static final String INBOUND_EMAIL = 'fundingrequestsystem-donotreply-d=gene.com@example.com';
    private static final String SENDER_DISPLAY_NAME = 'Funding Requests System';
    private static final String EMAIL_TEMPLATE_NAME = 'UC_12_Reconcile_Request_Reminder_Email_39';
    private static final String MERGE_FIELD = '{!GFRS_Funding_Request__c.Name}';
    private static final List<String> toAddresses = new List<String>{'test@test.test'};
    private static final List<String> ccAddresses = new List<String>{'test@test2.2test'};

    @testSetup
    private static void setup() {
        insertSettings();

        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');

        Contact communicationContact = new Contact(FirstName = 'test', LastName = 'test', Email = 'test@test.com');
        insert communicationContact;
    }

    private static void insertSettings() {
        GFRS_OrgSettings__c orgCS = GFRS_OrgSettings__c.getOrgDefaults();
        orgCS.gFRS_Inbound_Email__c = INBOUND_EMAIL;
        orgCS.Org_Wide_Email_Address__c = OWEA;
        orgCS.Notification_Sender_Display_Name__c = SENDER_DISPLAY_NAME;
        upsert orgCS;
    }

    private static testMethod void  getGFRSCommunicationEmailTest() {
        System.assertEquals(INBOUND_EMAIL, GFRS_NotificationUtil.getGFRSCommunicationEmail(), 'Wrong Inbound Email address');
    }

    private static testMethod void getGFRSCommunicationContactIdTest() {
        System.assertNotEquals(null, GFRS_NotificationUtil.getGFRSCommunicationContactId(), 'Communication Contact Id is required for generating proper email templates');
    }

    private static testMethod void getOWEATest() {
        System.assertEquals(OWEA, GFRS_NotificationUtil.getOWEA().Address, 'Wrong OWD address');
    }

    private static testMethod void getSenderDisplayNameTest() {
        System.assertEquals(SENDER_DISPLAY_NAME, GFRS_NotificationUtil.getSenderDisplayName(), 'Wrong Sender Display Name');
    }

    private static testMethod void prepareEmailTestForContactWithTemplateId() {

        GFRS_Funding_Request__c fundingRequest =  gFRS_DAO.getFundingRequestById([SELECT Id, RecordType.Name FROM GFRS_Funding_Request__c WHERE RecordType.Name = 'IMED' LIMIT 1][0].Id).get(0);

        Test.startTest();

            Id targetObjectId = GFRS_NotificationUtil.getGFRSCommunicationContactId();

            Messaging.SingleEmailMessage emailMsg = GFRS_NotificationUtil.prepareEmailMessage(
                targetObjectId,
                fundingRequest.Id,
                EMAIL_TEMPLATE_NAME,
                null
            );

            System.assertEquals(1, GFRS_NotificationUtil.getEmailsCache().size(), 'Only 1 email should be in the notifications queue');
            System.assertNotEquals(null, emailMsg, 'Email Message should be created');
            System.assertEquals(targetObjectId, emailMsg.getTargetObjectId(), 'Wrong Target Object');
            System.assert(String.isBlank(emailMsg.getSubject()), 'Subject should be blank for this message before sending but equals: ' + emailMsg.getSubject());
            System.assert(String.isBlank(emailMsg.getHTMLBody()) && String.isBlank(emailMsg.getPlainTextBody()), 'HTML and Plain Text body should be blank for this message before sending');

            GFRS_NotificationUtil.sendNotifications();

            System.assertEquals(0, GFRS_NotificationUtil.getEmailsCache().size(), 'Emails Cache should be empty');
            System.assert(String.isNotBlank(emailMsg.getSubject()), 'Subject should be blank for this message after sending');
            System.assert(String.isNotBlank(emailMsg.getHTMLBody()) || String.isNotBlank(emailMsg.getPlainTextBody()), 'HTML or Plain Text body should not be blank for this message after sending');



        Test.stopTest();

    }

    private static testMethod void prepareEmailTestForUserWithoutTemplateId() {

        GFRS_Funding_Request__c fundingRequest =  gFRS_DAO.getFundingRequestById([SELECT Id, RecordType.Name FROM GFRS_Funding_Request__c WHERE RecordType.Name = 'IMED' LIMIT 1][0].Id).get(0);

        Test.startTest();

            Id targetObjectId = GFRS_NotificationUtil.getGFRSCommunicationContactId();

            Messaging.SingleEmailMessage emailMsg = GFRS_NotificationUtil.prepareEmailMessage(
                targetObjectId,
                fundingRequest.Id,
                EMAIL_TEMPLATE_NAME,
                null
            );

            System.assertEquals(1, GFRS_NotificationUtil.getEmailsCache().size(), 'Only 1 email should be in the notifications queue');
            System.assertNotEquals(null, emailMsg, 'Email Message should be created');
            System.assertEquals(targetObjectId, emailMsg.getTargetObjectId(), 'Wrong Target Object');
            System.assert(String.isBlank(emailMsg.getSubject()), 'Subject should be blank for this message before sending but equals: ' + emailMsg.getSubject());
            System.assert(String.isBlank(emailMsg.getHTMLBody()) && String.isBlank(emailMsg.getPlainTextBody()), 'HTML and Plain Text body should be blank for this message before sending');

            Savepoint sp = Database.setSavepoint();
            GFRS_NotificationUtil.sendNotifications(false);
            Database.rollback(sp);

            System.assertEquals(1, GFRS_NotificationUtil.getEmailsCache().size(), 'Emails Cache should not be empty');

            GFRS_NotificationUtil.prepareEmailMessage(
                UserInfo.getUserId() ,
                null,
                null,
                null,
                null,
                EMAIL_TEMPLATE_NAME,
                null,
                false,
                emailMsg);

            System.assertEquals(1, GFRS_NotificationUtil.getEmailsCache().size(), 'Emails Cache should not be empty');

            GFRS_NotificationUtil.sendNotifications();

            System.assertEquals(0, GFRS_NotificationUtil.getEmailsCache().size(), 'Only 1 email should be in the notifications queue');
            System.assertEquals(UserInfo.getUserId(), emailMsg.getTargetObjectId(), 'Wrong Target Object');
            System.assert(String.isNotBlank(emailMsg.getSubject()), 'Subject should be blank for this message after sending');
            System.assert(String.isNotBlank(emailMsg.getHTMLBody()) || String.isNotBlank(emailMsg.getPlainTextBody()), 'HTML or Plain Text body should not be blank for this message after sending');

        Test.stopTest();

    }

    @IsTest
    private static void testPrepareEmailWithMergeFields() {
        GFRS_Funding_Request__c fundingRequest =  gFRS_DAO.getFundingRequestById([SELECT Id, RecordType.Name FROM GFRS_Funding_Request__c WHERE RecordType.Name = 'IMED' LIMIT 1][0].Id).get(0);
        Map<String, Object> mergeFields = new Map<String, Object>{'\\{!GFRS_Funding_Request__c.Name\\}' => fundingRequest.Name};

        Test.startTest();
        Id targetObjectId = GFRS_NotificationUtil.getGFRSCommunicationContactId();

        GFRS_NotificationUtil.prepareEmailMessage(
                UserInfo.getUserId(),
                null,
                toAddresses,
                ccAddresses,
                ccAddresses,
                EMAIL_TEMPLATE_NAME,
                mergeFields,
                true,
                null
        );

        System.assertEquals(1, GFRS_NotificationUtil.getEmailsCache().size(), 'Emails Cache should not be empty');

        GFRS_NotificationUtil.sendNotifications();

        System.assertEquals(0, GFRS_NotificationUtil.getEmailsCache().size(), 'Only 1 email should be in the notifications queue');
        System.assertEquals([SELECT Id, Email FROM Contact WHERE Email = 'test@test.com' LIMIT 1].Id, GFRS_NotificationUtil.getGFRSCommunicationContactId());
        System.assertEquals(INBOUND_EMAIL, GFRS_NotificationUtil.getGFRSCommunicationEmail());
        System.assertEquals(OWEA, GFRS_NotificationUtil.getOWEA().Address);
        System.assertEquals(SENDER_DISPLAY_NAME, GFRS_NotificationUtil.getSenderDisplayName());
        System.assertEquals(MERGE_FIELD, GFRS_NotificationUtil.fetchMergeFields('{!GFRS_Funding_Request__c.Name}', mergeFields));
    }

    @IsTest
    private static void testPrepareEmailWithRenderedStoredTemplate() {
        GFRS_Funding_Request__c fundingRequest =  gFRS_DAO.getFundingRequestById([SELECT Id, RecordType.Name FROM GFRS_Funding_Request__c WHERE RecordType.Name = 'Corporate Memberships' LIMIT 1][0].Id).get(0);

        Test.startTest();
        Id targetObjectId = GFRS_NotificationUtil.getGFRSCommunicationContactId();

        GFRS_NotificationUtil.prepareEmailMessage(
                UserInfo.getUserId(),
                fundingRequest.Id,
                EMAIL_TEMPLATE_NAME
        );

        System.assertEquals(1, GFRS_NotificationUtil.getEmailsCache().size(), 'Emails Cache should not be empty');

        GFRS_NotificationUtil.sendNotifications();

        System.assertEquals(0, GFRS_NotificationUtil.getEmailsCache().size(), 'Only 1 email should be in the notifications queue');
        System.assertEquals([SELECT Id, Email FROM Contact WHERE Email = 'test@test.com' LIMIT 1].Id, GFRS_NotificationUtil.getGFRSCommunicationContactId());
        System.assertEquals(SENDER_DISPLAY_NAME, GFRS_NotificationUtil.getSenderDisplayName());

        Test.stopTest();
    }

}