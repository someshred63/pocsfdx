public without sharing class gFRS_ContactUserController {
    public List<User> userDetail {get;set;}
    public gFRS_ContactUserController(ApexPages.StandardController std){
        
        Id contactId = std.getId();
      
        if(contactId != null){
            userDetail = [SELECT Email, LastLoginDate, Phone, Profile_Name_gne__c, Username, ContactId, IsActive FROM User WHERE ContactId =: contactId Limit 1];    
            
        }else{
           userDetail = new List<User>(); 
        }
        
        
    }
}