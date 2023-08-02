public class Util{
    public static boolean isQuestionsAfterInsert = true;
    public static boolean isLucentis = true; 
    
    public static String cftProfileName = 'GNE-MCCO-CFT';
    public static String GNECMProfileName = 'GNE-CM-';
    public static String GNELWOProfileName = 'GNE-LWO';
    public static String cftGroupName = 'GNE-CFT-AFFILIATION MASTER';
    public static String cftQueueName = 'GNE-CFT-Affiliation-Owner-Queue';
    
    public static String strQueue = 'Queue';
    public static String GNEAffiliationQueueName = 'GNE-Affiliation-Owner-Queue';

    public static String GNEAffiliationOwnerQueueNameId;
    public static String CurrentUserProfileName;
    
    static {        
        CurrentUserProfileName         = [select Profile_Name_gne__c from User 
                                          where Id = :Userinfo.getUserId()].Profile_Name_gne__c;                        
        
        GNEAffiliationOwnerQueueNameId = [select Id, OwnerId, name from Group 
									      where     Name = : Util.GNEAffiliationQueueName 
											    and Type =: Util.strQueue ].Id; 
    }           
}