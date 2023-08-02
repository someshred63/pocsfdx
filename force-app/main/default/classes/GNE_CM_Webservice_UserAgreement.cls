// ******** Return true if user agreement is checked for the userid passed on the account object. ********
// Test class: GNE_CM_User_Agreement_Test
public without sharing class GNE_CM_Webservice_UserAgreement  
{    
    public class GNE_CM_UserAgreement
    {            
         public String UserAgreement = 'false';
         public String Status = 'SUCCESS'; 
         public String Error_Description = '';
         public boolean updateLater =false;         
    }
    
    private class UserAgreementStructure
    {
        public Account agreementAccount {get; set;}
        public User agreementUser {get; set;}
        public GNE_CM_UserAgreement userAgreement {get; set;}
    }    

    public static GNE_CM_UserAgreement getUserAgreement(String inUserId)      
    {  
        System.debug('---inUserId value --- '+ inUserId);      
        GNE_CM_UserAgreement result;
        System.debug ('++++++++++++ CURRENT DATE TIME : ' + System.Now());
        datetime CurrDateTime = System.Now(); 
        System.debug ('++++++++++++++++++++++++++++++++++++++++++++++++');  
        /************************** DEBUG **************************/                                       
        // datetime CurrDateTime = datetime.newInstanceGMT(2010,4,2,12,20,0);
        /************************** DEBUG **************************/
        try
        {   
            UserAgreementStructure resultWithAccount = getAccountForAgreementInfo(inUserId);
            if (resultWithAccount.agreementAccount == null)
            {
                result = resultWithAccount.userAgreement;            
            }
            else
            {   
                if (resultWithAccount.agreementAccount.MPSUserAgreement__c != null && resultWithAccount.agreementAccount.MPSUserAgreement__c.equalsIgnoreCase('true'))
                {
                    result = getUserAgreementInfo('SUCCESS', '', 'true');                               
                }
                else //test for LWO user profile ->> agreement still might result in true
                {
                    result = getLWOUserAgreementInfo(resultWithAccount,inUserId);
                }   
            }                           
        }
        catch(Exception e)
        {
            result = getUserAgreementInfo('FAILURE', 'AN ERROR HAS OCCURRED: ' + e.getmessage(), '');
        }           
        return result;                   
    }
    
    /**
     * 
     */
    public static void setUserAgreement (List<Id> sfdcUserIds, Boolean isAgreementConfirmed)
    {       
        // get sfdc user IDs mapped to their accounts
        Map<Id, Account> accountsBySfdcUserId = getAccountsForAgreement(sfdcUserIds);
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : accountsBySfdcUserId.values())
        {
            acc.MPSUserAgreement__c = isAgreementConfirmed ? 'true' : 'false';
            accountsToUpdate.add(acc);  
        }
        
        update accountsToUpdate;
    }
    
    public static GNE_CM_UserAgreement setUserAgreement(String inUserId)      
    {      
        GNE_CM_UserAgreement result;
        datetime CurrDateTime = System.Now(); 
            
        try
        {
            UserAgreementStructure resultWithAccount = getAccountForAgreementInfo(inUserId);
            if (resultWithAccount.agreementAccount == null)
            {
                result = resultWithAccount.userAgreement;            
            }
            else
            {   
                resultWithAccount.agreementAccount.MPSUserAgreement__c = 'true';
                update resultWithAccount.agreementAccount;
                result = getUserAgreementInfo('SUCCESS', '', 'true');   
            }                        
        }   
        catch(Exception e)
        {
            result = getUserAgreementInfo('FAILURE', 'AN ERROR HAS OCCURRED: ' + e.getmessage(), '');
        }
        return result;
    }
    
    private static Map<Id, Account> getAccountsForAgreement (List<ID> sfdcUserIds)
    {
        Map<Id, Account> accountsBySFDCUserId = new Map<Id, Account>();
        Map<Id, User> sfdcUsers = new Map<Id, User>([Select Username, ContactId, AccountId From User Where Id IN :sfdcUserIds]);
        List<Id> accountIds = new List<Id>();
        
        for (Id sfdcUserId : sfdcUserIds)
        {
            User sfdcUser = sfdcUsers.get(sfdcUserId);
            
            if (sfdcUser == null)
            {
                throw new GNE_CM_Exception('No user found for ID = ' + sfdcUserId);
            }
            if (sfdcUser.ContactId == null)
            {
                throw new GNE_CM_Exception('SFDC user ' + sfdcUserId + ' has no contact');
            }
            if (sfdcUser.AccountId == null)
            {
                throw new GNE_CM_Exception('SFDC user ' + sfdcUserId + ' has contact with null account ID');
            }
            
            accountIds.add(sfdcUser.AccountId);
        }
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, MPSUserAgreement__c FROM Account WHERE Id IN :accountIds]);
        
        for (Id sfdcUserId : sfdcUserIds)
        {
            accountsBySFDCUserId.put(sfdcUserId, accountsById.get(sfdcUsers.get(sfdcUserId).AccountId));
        }
        
        return accountsBySFDCUserId;
    }
    
    private static UserAgreementStructure getAccountForAgreementInfo(String inUserId)
    {
        UserAgreementStructure result = new UserAgreementStructure();       
        GNE_CM_UserAgreement resultAgreementInfo;
        if(inUserId != null && inUserId != '')
        {
            List<User> user_Info = new List<User>([Select Username,accountId, ContactId From User Where Id =: inUserId limit 1]);                
            if (user_Info.size() == 0)
            {  
                resultAgreementInfo = getUserAgreementInfo('FAILURE', 'AN ERROR HAS OCCURRED: USER DOES NOT EXIST', '');
            }
            else 
            {
                result.agreementUser = user_Info[0];                 
                if (user_Info[0].accountId == null)
                {
                    resultAgreementInfo = getUserAgreementInfo('FAILURE', 'NO CONTACT ACCOUNT FOR USER ID', '');                        
                }
                else
                {
                    List<Account> accountInfo = [SELECT Id, MPSUserAgreement__c FROM Account WHERE Id =: user_Info[0].accountId];
                    if (accountInfo.size() == 0)
                    {
                        resultAgreementInfo = getUserAgreementInfo('FAILURE', 'AN ERROR HAS OCCURRED: ACCOUNT DOES NOT EXIST', '');
                    }
                    else
                    {
                        result.agreementAccount = accountInfo[0];                       
                    }                  
                }
            }
        }
        else
        {
            resultAgreementInfo = getUserAgreementInfo('FAILURE', 'USER ID IS NULL.', '');                
        }
        result.userAgreement = resultAgreementInfo;
        return result;
    }
    
    private static GNE_CM_UserAgreement getUserAgreementInfo(String status, String errDesc, String userAgreement)
    {
        GNE_CM_UserAgreement result = new GNE_CM_UserAgreement();
        result.Status = status;
        result.Error_Description = errDesc;
        result.UserAgreement = userAgreement;
        return result;
    }
    
    private static GNE_CM_UserAgreement getLWOUserAgreementInfo(UserAgreementStructure agreement,String inUserId)
    {
        GNE_CM_UserAgreement result;
        String userEmail = getUserEmail(agreement.agreementUser.Username);
        List<User> lwoUsers = [SELECT id, ContactId FROM User WHERE Profile.name in ('GNE-LWO-USER','GNE-LWO-USER-FREQUENT') AND username LIKE : userEmail + '%'];
        if (lwoUsers.size() > 0) //the case when LWO user EXISTS
        {  
            result = getUserAgreementInfo('SUCCESS', '', 'false');
        }
        else //the case when LWO user NOT EXISTS
        {           
            //agreement.agreementAccount.MPSUserAgreement__c = 'true';
            //update agreement.agreementAccount;
            result = getUserAgreementInfo('SUCCESS', '', 'true');
            //The above two lines are commented, because A DML Operation cannot be performed when this method is called from a Constructor
            result.updateLater=true;
        }
            
        return result;
    }
    
    private static String getUserEmail(String userName)
    {
        String result = '';
        if (userName.indexOf('@') > 0)
        {
            String userDomain = userName.substring(userName.indexOf('@') + 1, userName.length());
            if (userDomain.indexOf('.gene') > 0)
            {
                result = userName.substring(0, userName.indexOf('@')) + '@' + userDomain.substring(0, userDomain.indexOf('.gene'));
            }
        }
        return result;      
    }
}