public without sharing class AGS_ST_UserRegLogger 
{
    @future
    public static void updateRegistrationStatus(String agsStUserId, String status)
    {
        system.debug('UpdateRegistrationStatus, agsStUserId: ' + agsStUserId + ', status: ' + status);
        if(AGS_ST_Utils.hasValue(agsStUserId))
        {
            AGS_ST_User_gne__c agsStUser = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);
            if(agsStUser != null)
            {
                String stat1 = status;
                if(status.length() > 255)
                    stat1 = status.substring(254);
                
                agsStUser.Registration_Status__c = stat1;
                update agsStUser;
                system.debug('UpdateRegistrationStatus UPDATED.');
            }
        }
    }

}