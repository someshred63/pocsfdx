@RestResource(urlMapping='/V1/UserCreation/*')
global class gFRS_UserCreationFromSAP {
    
   @HttpPost
    global static String createCommunityUser(String firstName,String lastName,String userEmail,String username)
    {
        String successMsg;
        try
        {
            Account accnt=[Select id ,name From Account Where Name='gFRS Lightning External Holding' LIMIT 1];
            List<Contact> contacts = new List<Contact>();
            contacts = [SELECT Id, FirstName, Lastname, Email FROM Contact WHERE Email =: userEmail];
            
            if(contacts.size() > 0){
                contacts[0].FirstName = firstName;
                contacts[0].Lastname  = lastName;
                contacts[0].AccountId = accnt.Id;
                
                Database.upsert(contacts[0]);
                
                List<User> userRecord = new List<User>();
                userRecord = [SELECT Id, Name, email, UserName, ProfileId, FirstName, LastName FROM User WHERE email =: userEmail];
                Profile portalProfile = [SELECT Id FROM Profile WHERE Name='GNE-GFRS-External Applicant' Limit 1];
                
                if(userRecord.size() > 0){
                    /* userRecord[0].FirstName = firstName;
                    userRecord[0].LastName = lastName;
                    userRecord[0].ProfileId = portalProfile.Id;
                    
                    Database.upsert(userRecord[0]); */
                    
                    successMsg='Successfully updated user in Salesforce : User ID is :: '+userRecord[0].Id;
                    userUpdateMethod(firstName, lastName, userEmail, portalProfile.Id);
                } else {
                    
                    User communityUsr = new User(
                        UserName =username,
                        FirstName = firstName,
                        LastName = lastName,
                        //Alias =firstName.substring(1,3)+lastName.substring(1,3),
                        IsActive=true,
                        email = userEmail,
                        ContactId = contacts[0].Id,
                        ProfileId = portalProfile.Id,
                        EmailEncodingKey = 'UTF-8',
                        //CommunityNickname = firstName.substring(1,3)+lastName.substring(1,3),
                        TimeZoneSidKey = 'America/Los_Angeles',
                        LocaleSidKey = 'en_US',
                        LanguageLocaleKey = 'en_US',
                        UserPreferencesContentNoEmail = false,
                        UserPreferencesContentEmailAsAndWhen = false
                    );
                    
                    Database.insert(communityUsr);
                }
            } else {
                Contact custCont = new Contact(
                    FirstName =firstName,
                    Lastname =lastName,
                    AccountId = accnt.Id,
                    Email = userEmail
                );
                Database.insert(custCont);
                
                Profile portalProfile = [SELECT Id FROM Profile WHERE Name='GNE-GFRS-External Applicant' Limit 1];
                User communityUsr = new User(
                    UserName =username,
                    FirstName = firstName,
                    LastName = lastName,
                    //Alias =firstName.substring(1,3)+lastName.substring(1,3),
                    IsActive=true,
                    email = userEmail,
                    ContactId = custCont.Id,
                    ProfileId = portalProfile.Id,
                    EmailEncodingKey = 'UTF-8',
                    //CommunityNickname = firstName.substring(1,3)+lastName.substring(1,3),
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US',
                    UserPreferencesContentNoEmail = false,
                    UserPreferencesContentEmailAsAndWhen = false
                );
                
                Database.insert(communityUsr);
                
                successMsg='Successfully created user in Salesforce : User ID is :: '+communityUsr.Id;
            }
 
        }
        catch(Exception ex) {
            system.debug('@@@ Exception while : '+ex.getMessage()+'@@Error NUmber::'+ex.getLineNumber());   
            //String exMessage=String.valueOf(ex.getMessage());
            //System.debug('An exception occurred: ' + ex.getMessage()); 
            successMsg=ex.getMessage(); 
        }
        return  successMsg;
    }
    
    @future
    public static void userUpdateMethod(String firstName,String lastName,string userEmail, Id profileId)
    {   
        User userRecord = [SELECT Id, Name, email, UserName, ProfileId, FirstName, LastName FROM User WHERE email =: userEmail];
        
        userRecord.FirstName = firstName;
        userRecord.LastName = lastName;
        userRecord.ProfileId = profileId;
        
        Database.upsert(userRecord);
        
        system.debug('Successfully updated user in Salesforce : User ID is :: '+userRecord.Id);
    }
}