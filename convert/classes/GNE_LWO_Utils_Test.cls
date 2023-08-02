/**
 * Test class for class GNE_LWO_Utils.cls
 *
 * @author Radek Krawiec
 * @created 08/16/2012
 */
// we need to set see all data to be able to access the GNE LWO profile
@isTest(SeeAllData=true)
public class GNE_LWO_Utils_Test
{
    private static final String LWO_PROFILE = 'GNE-LWO-USER';
    
    public static testMethod void testLWOUserConversion()
    {
        //---------------------------------------------------------------------------------
        // Prepating test data
        //---------------------------------------------------------------------------------
        
        // insert account
        Account oldAccount = new Account();
        oldAccount.Name = 'TestName';
        oldAccount.OwnerId = GNE_LWO_Utils.getLwoOwnerUserId();
        insert oldAccount;
        
        String firstName = 'Mary';
        String lastName = 'Rebskasdkld';
        String email = 'mary.rebskasdkld@ddd.ccc.com';
        String phone = '389238923390';
        
        // create contact
        Contact oldContact = new Contact(AccountId = oldAccount.Id);
        oldContact.FirstName = firstName;
        oldContact.LastName = lastName;
        oldContact.Email = email;
        oldContact.Phone = phone;  
        oldContact.OwnerId = GNE_LWO_Utils.getLwoOwnerUserId();
        insert oldContact;
        
        // create LWO SFDC user
        User oldSfdcUser = GNE_CM_Test_Helper.addTestUser(LWO_PROFILE, 'gene.com', oldContact.Id);
        
        // create an affiliation for the contact
        addAffiliation(oldContact.Id);
        
        //---------------------------------------------------------------------------------
        // Do the actual testing
        //---------------------------------------------------------------------------------
        try
        {
            GNE_LWO_Utils.LWOConversionData conversionData = GNE_LWO_Utils.convertLWOUserToIHCP(oldSfdcUser.Id, 'ABcd1234');
            System.assert(false, 'An exception should have been thrown because GNE_LWO_User does not exist');
        }
        catch (GNE_LWO_User_Creation_Exception e)
        {
            // this failure was expected because no LWO exists at this stage
        }
        
        // create LWO users from SFDC users
        GNE_LWO_Utils.createLWOUsers(new List<Id> { oldSfdcUser.Id }, false);
        // try to convert again - this time it should not fail
        GNE_LWO_Utils.LWOConversionData conversionData = GNE_LWO_Utils.convertLWOUserToIHCP(oldSfdcUser.Id, 'ABcd1234');
        
        // make sure new SFDC user has been created
        System.assert(conversionData.newSfdcUser != null, 'New SFDC user not created');
        Integer newUserCount = [SELECT COUNT() FROM User WHERE ID = :conversionData.newSfdcUser.Id];
        System.assert(newUserCount > 0, 'New SFDC user not found by ID');
    }
    
    
    /**
     * Test for the method GNE_LWO_Utils.createLWOUsers
     */
    public static testMethod void testCreatingLWOUsers()
    {
    	GNE_CM_UnitTestConfig.skipTriggerForTests('SCM_UserProfileChange');
    	
        // create some SFDC users
        User firstUser = GNE_CM_Test_Helper.addTestLWOUser();
        User secondUser = GNE_CM_Test_Helper.addTestLWOUser();
        
        // make sure there are not LWO users at this stage
        Integer lwoUserCount = [SELECT COUNT() FROM GNE_LWO_User__c WHERE SFDC_User__c = :firstUser.Id OR SFDC_User__c = :secondUser.Id];
        System.assert(lwoUserCount == 0, 'Precondition not fulfilled - there should exist no LWO users for newly-created SFDC users');
        
        try
        {
        	// create LWO users from SFDC users
        	GNE_LWO_Utils.createLWOUsers(new List<Id> { firstUser.Id, secondUser.Id }, false);
        	System.assert(false, 'An exception should be thrown because the users have no affiliations');
        }
        catch (GNE_CM_Exception e)
        {
        	// this exception was expected
        }
        
        Test.startTest();
        
        // 
        firstUser = GNE_CM_Test_Helper.addTestLWOUser();
        //secondUser = GNE_CM_Test_Helper.addTestLWOUser();
        // add affiliations
        addAffiliation(firstUser.ContactId);
        //addAffiliation(secondUser.ContactId);
        
        // create LWO users from SFDC users
        GNE_LWO_Utils.createLWOUsers(new List<Id> { firstUser.Id }, false);
        
        // make sure 2 LWO users have been created
        lwoUserCount = [SELECT COUNT() FROM GNE_LWO_User__c WHERE SFDC_User__c = :firstUser.Id];
        System.assert(lwoUserCount == 1, 'One LWO user should have been created for the first SFDC user, actual number of created = ' + lwoUserCount);
        //lwoUserCount = [SELECT COUNT() FROM GNE_LWO_User__c WHERE SFDC_User__c = :secondUser.Id];
        //System.assert(lwoUserCount == 1, 'One LWO user should have been created for thr second SFDC user, actual number of created = ' + lwoUserCount);
        
        User thirdUser = GNE_CM_Test_Helper.addTestLWOUser();
        addAffiliation(thirdUser.ContactId);
        
        // create LWO users from SFDC users
        GNE_LWO_Utils.createLWOUsers(new List<Id> { firstUser.Id, thirdUser.Id }, false);
        
        // make sure that no duplicate users have been created for the SFDC users that already possessed a related LWO user
        lwoUserCount = [SELECT COUNT() FROM GNE_LWO_User__c WHERE SFDC_User__c = :firstUser.Id OR SFDC_User__c = :thirdUser.Id];
        System.assert(lwoUserCount == 2, 'Two SFDC users should have exactly the same number of corresponding LWO users, instead there are ' + lwoUserCount);
        
        Test.stopTest();
    }
    
    private static void addAffiliation (Id contactId)
    {
        Account affAccount = new Account();
        affAccount.Name = 'TestName';
        affAccount.OwnerId = GNE_LWO_Utils.getLwoOwnerUserId();
        insert affAccount;
        
        Affiliation_vod__c aff = new Affiliation_vod__c();
        aff.From_account_vod__c = affAccount.Id;
        aff.To_Contact_vod__c = contactId;
        aff.Role_vod__c = 'Affiliated with';
        aff.Web_Order_Enabled_gne__c = true;
        
        insert aff;
    }
    
    /**
     * Test for the method GNE_LWO_Utils.createLWOPersonAccount
     */
    public static testMethod void testCreatingPersonAccount()
    {
        String firstName = 'Richard';
        String lastName = 'Demebetekalewete';
        String email = 'Richard.Demebetekalewete@bbb.ccc.com';
        
        Account existingAccount = GNE_LWO_Utils.getPersonAccount(firstName, lastName, email);
        System.assert(existingAccount == null, 'Test precondition not fulfilled - account exists');
        
        GNE_LWO_Utils.createLWOPersonAccount(firstName, lastName, email);
        Account newAccount = GNE_LWO_Utils.getPersonAccount(firstName, lastName, email);
        System.assert(newAccount != null, 'Account not created');
        System.assert(newAccount.IsPersonAccount == true, 'Account created, but not as person account');
        System.assert(newAccount.PersonContactId != null, 'Account created, but no contact is associated with it');
        
        // fetch contact
        List<Contact> contacts = [SELECT FirstName, LastName, Email FROM Contact WHERE Id = :newAccount.PersonContactId];
        
        System.assert(contacts != null && !contacts.isEmpty(), 'No contacts found for the newly-created person account');
        Contact c = contacts.get(0);
        System.assert(c.FirstName == firstName, 'New contact has different first name than it should');
        System.assert(c.LastName == lastName, 'New contact has different last name than it should');
        System.assert(c.Email == email, 'New contact has different email than it should');
    }
}