@isTest(SeeAllData=true)
public with sharing class GNE_CM_User_Agreement_Test
{
	private static final String LWO_PROFILE = 'GNE-LWO-USER';
	public static testMethod void testSetUserAgreement()
	{
		//---------------------------------------------------------------------------------
		// Prepating test data
		//---------------------------------------------------------------------------------
		
		// insert account
		Account oldAccount = new Account();
		oldAccount.Name = 'TestName';
		oldAccount.MPSUserAgreement__c = 'false';
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
		
		//---------------------------------------------------------------------------------
		// Run tests
		//---------------------------------------------------------------------------------
		
		GNE_CM_Webservice_UserAgreement.setUserAgreement(new List<Id> { oldSfdcUser.Id }, true);
		
		// fetch account again
		Account updatedAccount = [SELECT Id, MPSUserAgreement__c FROM Account WHERE Id = :oldAccount.Id];
		
		System.assert(updatedAccount.MPSUserAgreement__c == 'true', 'MPSUserAgreement__c field not properly updated');
		
		// run test again with different value
		GNE_CM_Webservice_UserAgreement.setUserAgreement(new List<Id> { oldSfdcUser.Id }, false);
		
		// fetch account again
		updatedAccount = [SELECT Id, MPSUserAgreement__c FROM Account WHERE Id = :oldAccount.Id];
		
		System.assert(updatedAccount.MPSUserAgreement__c == 'false', 'MPSUserAgreement__c field not properly updated');
	}
}