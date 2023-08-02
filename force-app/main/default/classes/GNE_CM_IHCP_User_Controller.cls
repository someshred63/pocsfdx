/**
 * @author Radek Krawiec
 * @created 10/07/2012
 */ 
public without sharing class GNE_CM_IHCP_User_Controller
{
    private ApexPages.StandardController standardController;
    public GNE_CM_MPS_User__c existingMpsUser { get; set; }    
    public String uname { get; set; }
    public String email { get; set; }
    //public Boolean isEmailEditable { get; private set; }
    public Boolean isASOProfile {get; private set; }
    public Boolean isCustOpsProfile {get; private set; }
    public Boolean isAGSProfile {get; private set; }
    public Boolean isSysAdmin { get; private set; }
    
    private User sfdcUser;
    private GNE_CM_MPS_User__c mpsUser;
    private GNE_CM_IHCP_User__c ihcpUser;
    private String lwoUserHolder;
    private static final String LWO_CUSTOPS_PROFILE = 'GNE-LWO-CUSTOPS';
    private String oldLWOStatus, oldMPSStatus;
    
    public String backToListURL
    {
        get
        {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/' + GNE_CM_IHCP_User__c.sObjectType.getDescribe().getKeyPrefix();
        }
        private set;
    }
    
    public GNE_CM_IHCP_User_Controller (ApexPages.StandardController ctrl)
    {
        try
        {
            this.standardController = ctrl;        
            ihcpUser = (GNE_CM_IHCP_User__c)standardController.getRecord();
            oldLWOStatus=ihcpUser.LWO_Status__c;
            oldMPSStatus=ihcpUser.MPS_Status__c;
            
            List<User> users = [Select FirstName, LastName, Email, Username from User 
                                                     where ID = :ihcpUser.SFDC_User__c];
            sfdcUser = users.get(0);
            uname = sfdcUser.Username;
            lwoUserHolder=uname;
            //isEmailEditable = true;    
            isCustOpsProfile = false;
            isAGSProfile = false;
            isASOProfile = false;
            isSysAdmin = false;
            
            Profile currentProf = [SELECT Name FROM Profile WHERE Id =: Userinfo.getProfileid()];
        
            String currentProfile = currentProf.Name;
            if(currentProfile == LWO_CUSTOPS_PROFILE)
            {
                //isEmailEditable = false;
                isCustOpsProfile = true;
            }
            else if(currentProfile.startsWith('GNE-CM'))
            {
                isASOProfile = true;
            }
            else if(currentProfile.startsWith('GNE-AGS'))
            {
                isAGSProfile = true;
            }
            if(currentProfile == 'System Administrator' || currentProfile.startsWith('GNE-SYS-') || currentProfile== 'GNE-CM-OPS' || currentProfile.startsWith('GNE-SFA-InternalUser') || currentProfile.startsWithIgnoreCase('GNE-SFA-OPS'))
                isSysAdmin = true;      
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + GlobalUtils.getExceptionDescription(ex)));
        }
    }
    
    public PageReference init()
    {
    if (System.currentPageReference().getParameters().get('statusChange')=='1') 
      {
        return updatePermissionSets();
      }
      return null;
    }
    
    public PageReference reset()
    { 
        PageReference pageRef = new PageReference('/apex/GNE_CM_IHCP_CUSTOPS_ResetPassword?ihcpUserId='+ihcpUser.Id+'&retUrl=/' + ihcpUser.Id);
        return pageRef;
    }
    
    public PageReference unlock()
    { 
        List<GNE_CM_IHCP_User__c> localIhcpUsers = [Select IsLocked__c from GNE_CM_IHCP_User__c 
                                                     WHERE ID =:ihcpUser.ID];
        if(localIhcpUsers.isEmpty())
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'IHCP User not found.');
            ApexPages.addMessage(myMsg);
            return null;
        }                                             
        GNE_CM_IHCP_User__c localIhcpUser = localIhcpUsers.get(0);
        if(localIhcpUser.IsLocked__c == true)
        {
            lockIhcpUser(localIhcpUser.ID, false); 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'User unlocked successfully.');
            ApexPages.addMessage(myMsg);
            ihcpUser.IsLocked__c=false;
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'User is not locked.');
            ApexPages.addMessage(myMsg);

        }
        return null;
        
    }
    
    @future
    private static void lockIhcpUser(ID ihcpUserId, Boolean isLocked)
    {
        List<GNE_CM_IHCP_User__c> localIhcpUsers = [Select IsLocked__c, Locked_Date_Time__c, Login_Failed__c from GNE_CM_IHCP_User__c 
                                                     WHERE ID =:ihcpUserId];
        GNE_CM_IHCP_User__c localIhcpUser = localIhcpUsers.get(0);
        localIhcpUser.IsLocked__c = isLocked; 
        if (!isLocked) {
            localIhcpUser.IsLocked__c=false;
            localIhcpUser.Locked_Date_Time__c=null;     
            localIhcpUser.Login_Failed__c=0;    
        } else {
            localIhcpUser.IsLocked__c=true;
            localIhcpUser.Locked_Date_Time__c=System.now();         
        }
        update localIhcpUser;                                                    
    }
    
    public PageReference save()
    {
      try
      { 
          ID proId= Userinfo.getProfileId();
          List<Profile> currentProfiles = [Select Name from Profile WHERE ID = :proId];
          Profile currentProfile = currentProfiles.get(0);
          
          if (lwoUserHolder != uname)
          {   
              if (currentProfile.Name != LWO_CUSTOPS_PROFILE && ihcpUser.LWO_Status__c == 'Approved')
              {
                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact Customer Operations at 800-963-1778 to change the Username.');
                  ApexPages.addMessage(myMsg);
                  return null;
              }
              // check if the new username does not already exist
          Integer userCount = [SELECT COUNT() FROM User WHERE Username = :uname];
          if (userCount > 0)
          {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A user with this user name already exists.'));
              return null;
          }  
          updateSFDCUsername(ihcpUser.SFDC_User__c, uname);
          if(currentProfile.Name == LWO_CUSTOPS_PROFILE)
          {
            ihcpUser.Email_Address__c = GNE_CM_IHCP_User_Util.trimEnvironmentSuffix(uname);
            Map<String, String> userId2Email = new Map<String, String>();
            userId2Email.put(ihcpUser.SFDC_User__c, ihcpUser.Email_Address__c);
            GNE_CM_IHCP_Utils.updateUserContactEmailsFuture(userId2Email);
            ihcpUser.Name = uname;
          }
          }          
          standardController.save();
          // goto redir page and wait while SFDC user record updates
          
        PageReference pageRef = new PageReference('/apex/GNE_CM_IHCP_User_Detail');
          
          if (oldLWOStatus!=ihcpUser.LWO_Status__c || oldMPSStatus!=ihcpUser.MPS_Status__c)
          {
        pageRef = new PageReference('/apex/GNE_CM_IHCP_User_Edit');
            pageRef.getParameters().put('statusChange', '1');
          }

          pageRef.getParameters().put('id', standardController.getId());
          pageRef.setRedirect(true);
          return pageRef;
      }
      catch(Exception ex)
      {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + GlobalUtils.getExceptionDescription(ex)));
        return null;
      }       
    }
    
    /*
    no email notification per Suzie
    private void sendActivationNotification (GNE_CM_IHCP_User__c user)
    {
        User sfdcUser = [select Contact.Email FROM User where Id = :user.SFDC_User__c];
        //create email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {sfdcUser.Contact.Email};   
        mail.setToAddresses(toAddresses);
        mail.setSubject('Your IHCP account has been activated');
        
        String activatedAccounts = '';
        Integer activatedAccountCount = 0;
        
        if (user.MPS_Status__c == 'Approved')
        {
            activatedAccounts += 'MPS';
            activatedAccountCount++;
        }
        if (user.LWO_Status__c == 'Approved')
        {
            activatedAccounts += (activatedAccountCount > 0 ? ' and ' : '') + 'LWO';
            activatedAccountCount++;
        }
        activatedAccounts += ' account' + (activatedAccountCount > 1 ? 's have' : ' has');
        
        String body = 'Congratulations!<p>Your ' + activatedAccounts + ' been activated. You can now log in and explore the features of our portals.</p>';
        body += '<p>Your username is: <b>' + user.Name + '</b></p>';
        
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    */
    
    public PageReference updatePermissionSets()
    {
        Id ihcpUserId = System.currentPageReference().getParameters().get('id');
        List<GNE_CM_IHCP_User__c> users = [SELECT Id, Name, LWO_Status__c, MPS_Status__c, SFDC_User__c FROM GNE_CM_IHCP_User__c where Id = :ihcpUserId];

        activateUsersByPortalStatus(users);
        
        GNE_CM_IHCP_User_Util.updateIHCPUserPermissionSets(users);
        
        // no email notification per Suzie
        // sendActivationNotification(users.get(0));
        
        PageReference pageRef = new PageReference('/apex/GNE_CM_IHCP_User_Detail');
        pageRef.getParameters().put('id', ihcpUserId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private void activateUsersByPortalStatus (List<GNE_CM_IHCP_User__c> ihcpUsers)
    {   
        List<Id> sfdcUserIds = new List<Id>();
        for (GNE_CM_IHCP_User__c ihcpUser : ihcpUsers)
        {
            /*results.put(ihcpUser.Id, new ActivationResult());
            results.get(ihcpUser.Id).MPSStatus = ihcpUser.MPS_Status__c;
            results.get(ihcpUser.Id).LWOStatus = ihcpUser.LWO_Status__c;*/
            
            // activate user if they are given permissions to any portal
            if (ihcpUser.MPS_Status__c == 'Approved' || ihcpUser.LWO_Status__c == 'Approved')
            {
                sfdcUserIds.add(ihcpUser.SFDC_User__c);
            }   
        }
        
        List<User> sfdcUsers = [SELECT IsActive FROM User WHERE Id IN :sfdcUserIds];
        
        if (sfdcUserIds != null && sfdcUserIds.size() > 0)
        {
            // make them active
            for (User u : sfdcUsers)
            { 
                u.IsActive = true; 
            }
            
            update sfdcUsers;
        }
    }
    
    @future
    private static void updateSFDCUsername (ID id, String uname)
    {
       try 
       {                        
            List<User> users = [Select FirstName, LastName, Email, Username from User where ID = :id];
            User sfdcUser = users.get(0);
            sfdcUser.Username = uname;
            update sfdcUser;
        }
        catch (Exception e)
        {
            System.Debug('Error: ' + GlobalUtils.getExceptionDescription(e));
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_Utils', 'High', 'updateSFDCUsername', 'Apex Class', e);
            insert err;            
        }
    }
}