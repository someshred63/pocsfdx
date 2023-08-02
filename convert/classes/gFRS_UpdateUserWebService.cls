global with sharing class gFRS_UpdateUserWebService {

    global class gFRS_updateUserResult {
        webservice String userId;
        webservice String error;
        
        public gFRS_updateUserResult(Id userIdentifier, string errorMessage) {
            userId = userIdentifier;
            error  = errorMessage;
        }
    }

    webService static gFRS_updateUserResult updateUser(String userName, String firstName, String lastName, String userRole, String email, String phoneNumber, String pin) {
        SavePoint sp = Database.setSavepoint(); 
        try{
            User[] users = [select Id, ContactId from user where username = :userName];
            User userToUpdate;
            Contact userContact;
            if(users != null && users.size() >0){
   
                userToUpdate = users[0];
    
                userContact            = [select Id from Contact where Id = :userToUpdate.ContactId limit 1];
                userContact.FirstName  = firstName;
                userContact.LastName   = lastName;
                userContact.Email      = email;
                userContact.Phone      = phoneNumber;
                userContact.Title      = userRole;          
                update userContact;
                
                userToUpdate.FirstName         = firstName;
                userToUpdate.LastName          = lastName;
                userToUpdate.Email             = email;
                userToUpdate.Security_PIN__c   = pin;
                userToUpdate.Title             = userRole;
                userToUpdate.Phone             = phoneNumber;
                update userToUpdate;
            } else {
                userContact = new Contact(
                    FirstName   = firstName,
                    LastName    = lastName,
                    Email       = email,
                    Phone       = phoneNumber,
                    Title       = userRole,
                    AccountID   = gFRS_Util.getCustomSettingStringValue('Portal_Account_ID') == null ? System.Label.GFRS_HOLDING_ACCOUNT : gFRS_Util.getCustomSettingStringValue('Portal_Account_ID')
                );
                insert userContact;
                
                Profile p = [select Id, Name, Type from Profile where Name =:gFRS_Util.PROFILE_NAME_GNEGFRSEXTERNALREQUESTOR limit 1];
                
                userToUpdate = new User(
                    username            = userName,
                    FirstName           = firstName,
                    LastName            = lastName,
                    Email               = email,
                    Security_PIN__c     = pin,
                    Phone               = phoneNumber,
                    Title               = userRole,
                    ProfileId           = p.Id,
                    IsActive            = true,
                    ContactId           = userContact.Id,
                    TimeZoneSidKey      = 'America/Los_Angeles',
                    LocaleSidKey        = 'en_US',
                    LanguageLocaleKey   = 'en_US',
                    EmailEncodingKey    = 'UTF-8'
                ); 
                insert userToUpdate;
                if(userToUpdate.id != null){
                    Boolean success = gFRS_Util_NoShare.applySharingRulesForNewUser(email, userToUpdate.id);
                    if(success == false){
                        Database.rollback(sp); 
                        System.debug( 'Error occured while applying sharing rules for a new user' );
                        return new gFRS_updateUserResult(userToUpdate.id, 'Error occured while applying sharing rules for a new user');
                    }
                } else {
                    Database.rollback(sp); 
                    System.debug( 'Error occured while adding new user' );
                    return new gFRS_updateUserResult(null, 'Error occured while adding new user');
                }
            }
            return new gFRS_updateUserResult(userToUpdate.Id, null);
        } catch( Exception err ){
            Database.rollback(sp); 
            System.debug( 'Error occured while updating user:' + err.getMessage()  );
            return new gFRS_updateUserResult(null, err.getMessage());
        }
    }
    class CustomException extends Exception {}
}