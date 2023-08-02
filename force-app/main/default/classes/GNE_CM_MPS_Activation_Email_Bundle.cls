/** 
 * A bundle of activation emails and user to whom these emails are sent
 */
public class GNE_CM_MPS_Activation_Email_Bundle
{
	// maps MPS user IDs to their activation emails
	public Map <Id, Messaging.SingleEmailMessage> mpsUsersToEmails { get; set; }
	public List<GNE_CM_MPS_User__c> mpsUsers { get; set; }
	
	public GNE_CM_MPS_Activation_Email_Bundle (Map <Id, Messaging.SingleEmailMessage> mpsUsersToEmails, List<GNE_CM_MPS_User__c> mpsUsers)
	{
		this.mpsUsersToEmails = mpsUsersToEmails;
		this.mpsUsers = mpsUsers;
	}
}