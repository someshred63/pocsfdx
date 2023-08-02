// author of this class

public with sharing class AAR_Contact_Email_Controller {
    
   @AuraEnabled
    public static Campaign getCampaignAndUserDetails(String recordId) {
        //User userDetails = getUserDetails();
        //Campaign campaignDetails = getCampaignDetails(recordId);
        return getCampaignDetails(recordId);
    }

    @AuraEnabled
    public static Campaign getCampaignDetails(String recordId) {
        Campaign campaignDetails = new Campaign();
        if(String.isNotEmpty(recordId)) {
            //VK 1/29/21 Added HasOptedOutOfEmail to the query as part of CAN-SPAM
            campaignDetails = [
                SELECT Id, (SELECT Id, Name, Email, Title, HasOptedOutOfEmail, Contact.Account.Name FROM CampaignMembers) 
                FROM Campaign 
                WHERE Id =:recordId
            ];
        }
        return campaignDetails;  
    }

   /**public static User getUserDetails(){
    // query current user information  
        User userDetails = [
            SELECT Id, Name, Email, Profile.Name 
            FROM User 
            WHERE id =: userInfo.getUserId()
            WITH SECURITY_ENFORCED
        ];
        return userDetails;
    }

    public class CampaignAndUserDetails {
        @AuraEnabled
        public Campaign campaignDetails; 
        @AuraEnabled
        public User userDetails;

        public CampaignAndUserDetails(Campaign campaignDetails, User userDetails) {
            this.campaignDetails = campaignDetails;
            this.userDetails = userDetails;
        }
    } **/
}