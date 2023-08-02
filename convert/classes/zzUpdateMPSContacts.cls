global class zzUpdateMPSContacts implements Database.Batchable<sObject>{
  private string query='SELECT Id, Email_address__c, SFDC_User__r.Contact.Id, SFDC_User__r.Contact.Email FROM GNE_CM_MPS_User__c WHERE Email_address__c!=null AND SFDC_User__r.ContactId!=null AND SFDC_User__r.Contact.Email=null';
  
  global zzUpdateMPSContacts() {
  }

  global zzUpdateMPSContacts(String pQuery) {
    query=pQuery;
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    List<Contact> lst=new List<Contact>();
    
    for(sobject s : scope){
      GNE_CM_MPS_User__c u=(GNE_CM_MPS_User__c) s;
      u.SFDC_User__r.Contact.Email=u.Email_address__c;
      lst.add( u.SFDC_User__r.Contact );
    }
    update lst;
  }

  global void finish(Database.BatchableContext BC){
  }
  
  static testMethod void myUnitTest() {
    // create the account and Contact
    Account a = new Account(name = 'TEST ACCOUNT');
    Database.insert(a);
	
    Contact c = new Contact(AccountId = a.id, lastname = 'lastname', email=null);
    Database.insert(c);
	        
    /* Get any profile for the given type.*/
    Profile p = [select id 
	                  from profile 
	                 where Name = 'GNE-LWO-USER'
	                 limit 1];   
	        
    String testemail = 'puser000@amamama.com';
    User pu = new User(profileId = p.id, 
          username = testemail, 
          email = testemail, 
          emailencodingkey = 'UTF-8', 
          localesidkey = 'en_US', 
          languagelocalekey = 'en_US', 
          timezonesidkey = 'America/Los_Angeles', 
          alias='cspu', 
          lastname='lastname', 
          contactId = c.id);
	        
    Database.insert(pu);
	    
    // MPS User
    GNE_CM_MPS_User__c mpsUser=new GNE_CM_MPS_User__c(Email_address__c=testemail, SFDC_User__c=pu.Id);
    insert mpsUser;
	    
    // Clear the email (trigger set it)
    c.Email=null;
    update c;

    Test.startTest();
    zzUpdateMPSContacts job = new zzUpdateMPSContacts('SELECT Id, Email_address__c, SFDC_User__r.Contact.Id, SFDC_User__r.Contact.Email FROM GNE_CM_MPS_User__c WHERE Email_address__c!=null AND SFDC_User__r.ContactId!=null AND SFDC_User__r.Contact.Email=null and Id=\'' + mpsUser.Id + '\'');
    ID batchprocessid = Database.executeBatch(job, 1);
    Test.stopTest();

    System.assertEquals(1,[SELECT COUNT() FROM Contact WHERE Id=:c.Id AND Email=:testemail]);
  }
}