@isTest
private class UtilTestClass {
	
    public static testMethod void runCurrentUserProfileNameTest() {
    
        String ProfileName = 'GNE-SFA-Nutropin-CS';
        Profile p = [select id from profile where name= :ProfileName];      
        User u = new User(alias = 'Test101', email='Test101@gene.com',
                          emailencodingkey='UTF-8', 
                          lastname='Test101', firstname ='User', 
                          languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', 
                          username='Test101@gene.com');
                                                    
        System.runAs(u) {
            System.assertEquals ( Util.CurrentUserProfileName, ProfileName, 
                                'Profile Name Does Not Match Profile Name: ' + ProfileName + 
                                '. Returned Profile ' +  Util.CurrentUserProfileName );
        }
                    
    }        


}