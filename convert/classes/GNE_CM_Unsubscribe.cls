// Last modified by VKaul. 05/03/2010

Global class GNE_CM_Unsubscribe implements Messaging.inboundEmailHandler
{
public static List<Error_Log_gne__c> error_list = new List<Error_Log_gne__c>();

Global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env ) 
    {
    // Create an inboundEmailResult object for returning the result of the Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    
    try 
        {
            // Contact and Lead lists to hold all the updated records
            List<User> lc = new List <User>();
         
            // Convert the subject line to lower case, so I can match on lower case
            String mySubject = email.subject.toLowerCase();
            
            // String I am searching for in the subject line
            String s = 'unsubscribe';
         
            // Check variable to see if the word "unsubscribe" was found in the subject line 
            Boolean unsubMe;
            
            // Look for the unsubcribe word in the subject line, if it is found return true, otherwise false is returned
            unsubMe = mySubject.contains(s);
     
            // If unsubscribe is found in the subject line enter the if statement
            if (unsubMe == true) 
            {
                GNE_CM_Webservice_updateOptFieldsOnUser.updateOptFieldsOnUser(env.fromAddress);
                /************************************** DEBUG **************************************/
                system.debug ('UNSUBSCRIBE REQUEST FOR ' + env.fromAddress + ' PROCESSED BY EMAIL SERVICE.');
                // logprogress ('UNSUBSCRIBE REQUEST FOR ' + env.fromAddress + ' PROCESSED BY EMAIL SERVICE.', true);
                /************************************** DEBUG **************************************/
                System.debug('Found the unsubscribe word in the subject line.');
            } 
            else 
            {
                /************************************** DEBUG **************************************/
                // logprogress ('SUBJECT LINE DOES NOT CONTAIN UNSUBSCRIBE REQUEST FOR ' + env.fromAddress, true);
                system.debug('No Unsuscribe word found in the subject line.' );
                /************************************** DEBUG **************************************/
            }
        // Return true and exit. True will confirm it is complete and no bounced email should be send the sender of the unsubscribe request. 
        result.success = true;
        return result;
        }
        catch (Exception e)
        {
            /************************************** DEBUG **************************************/
            logprogress ('EMAIL SERVICE ERROR IN UNSUBSCRIBE REQUEST FOR ' + env.fromAddress + '. ERROR ' + e  , true);
            result.success = false;
            return result;
            /************************************** DEBUG **************************************/
        }
    } 
    
    public static void logprogress(String LogDescription, Boolean CompletionFlag)
    {
        Error_Log_gne__c error = new Error_Log_gne__c (Object_Name__c = 'APEX CLASS', 
                Error_Level_gne__c = 'Low', 
                Snippet_Name__c = 'GNE_CM_Unsubscribe', 
                Code_Type__c = 'Apex', 
                Error_Description__c = LogDescription, 
                User_Name__c = UserInfo.getUserName());
                
        error_list.add(error);
        
        if (CompletionFlag == true)
        {           
            Insert error_list;
        }
    }   
}