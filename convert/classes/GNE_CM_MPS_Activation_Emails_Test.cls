@isTest
public with sharing class GNE_CM_MPS_Activation_Emails_Test
{
    /**
     * Test sending activation emails to MPS users and some general preconditions on an MPS user object.
     */
    public static testMethod void testSendActivationEmail()
    {
        String email = 'test-email-1234@gene.com';
        
        // create test user
        GNE_CM_MPS_User__c mpsUser = new GNE_CM_MPS_User__c();      
        mpsUser.First_name__c = 'John';
        mpsUser.Email_address__c = email;
        mpsUser.SFDC_User__c = GNE_CM_Test_Helper.addTestUser('System Administrator', 'gene.com').Id;
        insert mpsUser;
        
        // make sure activation date is null
        System.assert (mpsUser.Activation_Email_Sent_Date__c == null, 'Field \'Activation_Email_Sent_Date__c\' for new MPS users should be null, its actual value is: ' + mpsUser.Activation_Email_Sent_Date__c);
        //System.assert (mpsUser.Workflow_State__c == 'APPROVED', 'Field \'Workflow_State__c\' for new users has to have value \'NEW\', the actual value is ' + mpsUser.Workflow_State__c);
        
        GNE_CM_MPS_Activation_Email_Bundle emailBundle = GNE_CM_MPS_Email_Utils.prepareActivationEmails(new List<Id> { mpsUser.Id }, true, false);
        
        // save the objects returned by the GNE_CM_IHCP_Utils.prepareActivationEmails method
        update emailBundle.mpsUsers;
        
        System.assert (emailBundle.mpsUsersToEmails != null && emailBundle.mpsUsersToEmails.size() > 0, 'Email bundle should contain at least one element');
        
        Messaging.SingleEmailMessage emailMsg = emailBundle.mpsUsersToEmails.get(mpsUser.Id);
        System.assert (emailMsg != null, 'Activation email not created');
        
        String body = emailMsg.getHtmlBody();
        if (body == null)
        {
            body = emailMsg.getPlainTextBody();
        }
        
        // refetch MPS user to reflect changes made in the GNE_CM_IHCP_Utils.prepareActivationEmails method
        mpsUser = [SELECT Id, Activation_Hash_Number__c, Activation_Email_Sent_Date__c FROM GNE_CM_MPS_User__c WHERE Id = :mpsUser.Id LIMIT 1];
        
        if (mpsUser.Activation_Email_Sent_Date__c == null)
        {
            System.assert(false, 'Field MPS_User.Activation_Email_Sent_Date__c not set. Make sure that the object has been saved and refetched. If yes, this is a bug in the method preparing activation emails');
        }
        
        if (mpsUser.Activation_Hash_Number__c == null)
        {
            System.assert(false, 'Field MPS_User.Activation_Hash_Number__c not set. Make sure that the object has been saved and refetched. If yes, this is a bug in the method preparing activation emails');
        }
        
        // make sure the activation email contains the users hash token
        System.assert (body.contains(mpsUser.Activation_Hash_Number__c), 'Activation email does not contain the user\'s hash token');
        // make sure that the user's activation link sent date has been set to the current date
        System.assert (mpsUser.Activation_Email_Sent_Date__c == System.today(), 'MPS user\'s Activation_Email_Sent_Date__c date not set to the current date as it should be');
    }
    
    /**
     * Tests batch class GNE_CM_MPS_Activation_Email_Sender for sending activation email reminders
     */
    public static testMethod void testActivationReminders()
    {
        String email = 'test-email-1234@gene.com';        
        
        Integer sendInterval = (Integer)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Activation_Email_Send_Interval__c;
        Integer sendPeriod = (Integer)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Activation_Email_Send_Period__c;
        
        // skip trigger that caused a MIXED_DML_Exception (the cause of this exception was not investigated)
        GNE_CM_UnitTestConfig.skipTriggerForTests('trigUserUpdateProfileGroups');
        GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_User_PublicGroup_Association');
        GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_Update_Speaker_Bureau_MembershipsV1');
        
        Map<String, RecordType> recordTypes = GlobalUtils.getRecordTypes('Account', new List<String>{'Professional_vod'});
        GNE_CM_MPS_UnitTestDataCreator.MpsUserWithAccount userWithAcct = GNE_CM_MPS_UnitTestDataCreator.getMPSUser('incognit', recordTypes);
        GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure struct = new GNE_CM_MPS_UnitTestDataCreator.MPSRegistrationStructure(2, 2, 2, recordTypes, userWithAcct);
        
        List<GNE_CM_MPS_User__c> usersForTest = new List<GNE_CM_MPS_User__c>();
        //----------------------------------------------------------------------------------------------------
        // create test user that is valid for sending reminders
        //----------------------------------------------------------------------------------------------------
        GNE_CM_MPS_User__c validMpsUser = new GNE_CM_MPS_User__c();     
        validMpsUser.First_name__c = 'John';
        validMpsUser.Email_address__c = email;
        validMpsUser.Workflow_State__c = 'ACTIVATION_EMAIL_SENT';
        validMpsUser.Activation_Email_Sent_Date__c = System.today().addDays(-1 * sendInterval);
        validMpsUser.SFDC_User__c = GNE_CM_Test_Helper.addTestUser('System Administrator', 'gene.com').Id;
        validMpsUser.GNE_CM_MPS_Registration__c = struct.registration.Id;
        usersForTest.add(validMpsUser);
        //----------------------------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------------------------------------
        // Create test user that is invalid for sending reminders because of the value of Workflow_State
        // although its send date is correct
        //----------------------------------------------------------------------------------------------------
        GNE_CM_MPS_User__c mpsUserInvalidDueToState = new GNE_CM_MPS_User__c();     
        mpsUserInvalidDueToState.First_name__c = 'John';
        mpsUserInvalidDueToState.Email_address__c = email;
        mpsUserInvalidDueToState.Workflow_State__c = 'APPROVED';
        mpsUserInvalidDueToState.Activation_Email_Sent_Date__c = System.today().addDays(-1 * sendInterval);
        mpsUserInvalidDueToState.SFDC_User__c = GNE_CM_Test_Helper.addTestUser('System Administrator', 'gene.com').Id;
        mpsUserInvalidDueToState.GNE_CM_MPS_Registration__c = struct.registration.Id;
        usersForTest.add(mpsUserInvalidDueToState);
        //----------------------------------------------------------------------------------------------------
        // Create test user that is invalid for sending reminders because their send date is equal to the
        // current date
        //----------------------------------------------------------------------------------------------------
        GNE_CM_MPS_User__c mpsUserInvalidDueToCurrentDate = new GNE_CM_MPS_User__c();     
        mpsUserInvalidDueToCurrentDate.First_name__c = 'John';
        mpsUserInvalidDueToCurrentDate.Email_address__c = email;
        mpsUserInvalidDueToCurrentDate.Workflow_State__c = 'APPROVED';
        mpsUserInvalidDueToCurrentDate.Activation_Email_Sent_Date__c = System.today();
        mpsUserInvalidDueToCurrentDate.SFDC_User__c = GNE_CM_Test_Helper.addTestUser('System Administrator', 'gene.com').Id;
        mpsUserInvalidDueToCurrentDate.GNE_CM_MPS_Registration__c = struct.registration.Id;
        usersForTest.add(mpsUserInvalidDueToCurrentDate);
        //----------------------------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------------------------------------
        // Create test user that is invalid for sending reminders because of the value of send date
        // (send interval does not match)
        //----------------------------------------------------------------------------------------------------
        GNE_CM_MPS_User__c mpsUserInvalidDueToInterval = new GNE_CM_MPS_User__c();      
        mpsUserInvalidDueToInterval.First_name__c = 'John';
        mpsUserInvalidDueToInterval.Email_address__c = email;
        mpsUserInvalidDueToInterval.Workflow_State__c = 'ACTIVATION_EMAIL_SENT';
        mpsUserInvalidDueToInterval.Activation_Email_Sent_Date__c = System.today().addDays(-1 * (sendInterval-1));
        mpsUserInvalidDueToInterval.SFDC_User__c = GNE_CM_Test_Helper.addTestUser('System Administrator', 'gene.com').Id;
        mpsUserInvalidDueToInterval.GNE_CM_MPS_Registration__c = struct.registration.Id;
        usersForTest.add(mpsUserInvalidDueToInterval);
        //----------------------------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------------------------------------
        // Create test user that is invalid for sending reminders because of the value of send date
        // (the date is past the send period)
        //----------------------------------------------------------------------------------------------------
        Integer outdatedPeriod = sendPeriod + 10;
        
        GNE_CM_MPS_User__c mpsUserInvalidDueToOutdated = new GNE_CM_MPS_User__c();      
        mpsUserInvalidDueToOutdated.First_name__c = 'John';
        mpsUserInvalidDueToOutdated.Email_address__c = email;
        mpsUserInvalidDueToOutdated.Workflow_State__c = 'ACTIVATION_EMAIL_SENT';
        mpsUserInvalidDueToOutdated.Activation_Email_Sent_Date__c = System.today().addDays(-1 * outdatedPeriod);
        mpsUserInvalidDueToOutdated.SFDC_User__c = GNE_CM_Test_Helper.addTestUser('System Administrator', 'gene.com').Id;
        mpsUserInvalidDueToOutdated.GNE_CM_MPS_Registration__c = struct.registration.Id;
        usersForTest.add(mpsUserInvalidDueToOutdated);
        //----------------------------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------------------------------------
        // Create test user that is invalid for sending reminders because of the value of send date
        // (send interval does not match)
        //----------------------------------------------------------------------------------------------------
        GNE_CM_MPS_User__c mpsUserInvalidDueToPeriod = new GNE_CM_MPS_User__c();
        
        // find a date greater than sendPeriod and a multiple of sendInterval
        Integer incorrectInterval = 2;
        while (incorrectInterval <= sendPeriod)
        {
            incorrectInterval += sendInterval;
        }
        
                
        mpsUserInvalidDueToPeriod.First_name__c = 'John';
        mpsUserInvalidDueToPeriod.Email_address__c = email;
        mpsUserInvalidDueToPeriod.Workflow_State__c = 'ACTIVATION_EMAIL_SENT';
        mpsUserInvalidDueToPeriod.Activation_Email_Sent_Date__c = System.today().addDays(-1 * incorrectInterval);
        mpsUserInvalidDueToPeriod.SFDC_User__c = GNE_CM_Test_Helper.addTestUser('System Administrator', 'gene.com').Id;
        mpsUserInvalidDueToPeriod.GNE_CM_MPS_Registration__c = struct.registration.Id;
        usersForTest.add(mpsUserInvalidDueToPeriod);
        //----------------------------------------------------------------------------------------------------
        
        insert usersForTest;
        GNE_CM_MPS_Activation_Email_Sender batch = new GNE_CM_MPS_Activation_Email_Sender();
        String query = batch.query;
        
        Test.startTest();
        System.assert (batch.query != null, 'String query must not be null');
        batch.query = batch.query + ' LIMIT 10';
        List<SObject> objs = Database.query(batch.query);
        List<GNE_CM_MPS_User__c> mpsUsers = (List<GNE_CM_MPS_User__c>)objs;
        
        // get list of IDs of MPS users to which activation reminders will be sent
        Set<Id> mpsUsersForSendingEmails = new Set<Id>();
        mpsUsersForSendingEmails.addAll(batch.filterMpsUsersByEmailInterval(mpsUsers));
        
        // check that the valid user is among those to whom reminders will be sent
        System.assert(mpsUsersForSendingEmails.contains(validMpsUser.Id), 'A user that fulfills all conditions for sending a reminder is not on the list');
        
        System.assert(!mpsUsersForSendingEmails.contains(mpsUserInvalidDueToState.Id), 'A user that does not fulfill conditions on field Workflow_State for sending a reminder is on the list');
        System.assert(!mpsUsersForSendingEmails.contains(mpsUserInvalidDueToInterval.Id), 'A user that does not fulfill conditions on send date (wrong interval) for sending a reminder is on the list');
        System.assert(!mpsUsersForSendingEmails.contains(mpsUserInvalidDueToPeriod.Id), 'A user that does not fulfill conditions on send date (send date older than allowed send period) for sending a reminder is on the list');
        System.assert(!mpsUsersForSendingEmails.contains(mpsUserInvalidDueToCurrentDate.Id), 'A user that does not fulfill conditions on send date (send date is equal to the current date) for sending a reminder is on the list');
        
        //Test workflow state update for outdated users
        List<GNE_CM_MPS_User__c> outdatedUser = [SELECT Workflow_State__c FROM GNE_CM_MPS_User__c WHERE Id =: mpsUserInvalidDueToOutdated.Id];
        System.assertEquals('ACTIVATION_LINK_EXPIRED', outdateduser[0].Workflow_State__c, 'Workflow state for outdated user not updated correctly!');
        //--------------------------------------------------------------------------------------------------------
        // Test e-mail content
        //--------------------------------------------------------------------------------------------------------
        // assign practice representative that we will be using for tests
        
        // we need to execute two queries, because subqueries on the same object are not allowed in Salesforce
        User mpsSfdcUser = [SELECT CreatedById FROM User WHERE Id = :validMpsUser.SFDC_User__c];
        User creatingUser = [SELECT FirstName, LastName FROM User WHERE Id = :mpsSfdcUser.CreatedById];
        String registeringUser = creatingUser.FirstName + ' ' + creatingUser.lastName;
        
        GNE_CM_MPS_Activation_Email_Bundle emailBundle = GNE_CM_MPS_Email_Utils.prepareActivationEmails(new List<Id> { validMpsUser.Id }, true, true);
        String body = emailBundle.mpsUsersToEmails.get(validMpsUser.Id).getHtmlBody();
        if (body == null)
        {
            body = emailBundle.mpsUsersToEmails.get(validMpsUser.Id).getPlainTextBody();
        }
        System.assert (body.contains(registeringUser), 'Activation reminder email should contain the name of the registering user (\'' + registeringUser + '\'), but the actual email content is: ' + body);
        Test.stopTest();
    }
}