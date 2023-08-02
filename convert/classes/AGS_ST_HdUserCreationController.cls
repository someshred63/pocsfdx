public class AGS_ST_HdUserCreationController
{    
    Id userId;
    String agsStUserId;
    String ihcpUserId;
    public PageReference finishUserCreation()
    {
        try
        {
            agsStUserId = ApexPages.currentPage().getParameters().get('agsstuserid');
            userId = ApexPages.currentPage().getParameters().get('usr');
            //String activationLink = AGS_ST_MailUtil.sendUserActivationEmail(agsStUserId);
            GNE_CM_IHCP_User__c ihcpUser = AGS_ST_DbUtils.getIHCPUser(userId);
            if(ihcpUser == null) {
                ihcpUserId = AGS_ST_DbUtils.insertIHCPUser('Approved', null, null,'','','');
            } else {
            	if('Approved'.equals(ihcpUser.AGS_ST_Status__c)) {
            		// How to show error?
            		return null;
            	} else {
            		ihcpUserId = ihcpUser.Id;
            	}
            }
            AGS_ST_DbUtils.updateIHCPStatus(ihcpUserId, userId);  
            AGS_ST_DbUtils.updateSTUser(agsStUserId, userId);
			
			if(Site.getDomain() != null)         
            	AGS_ST_MailUtil.sendAfterActivationEmail(userId);

            AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'Registration successfull.');
            PageReference registrationFinishRef = new PageReference('/'+agsStUserId);
            registrationFinishRef.setRedirect(true);
            return registrationFinishRef;
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, e);    
            AGS_ST_Utils.logException(agsStUserId,'Registration','AGS_ST_RegistrationController_gne',e, 'sendToActivate'); 
            return null;             
        }
    }
}