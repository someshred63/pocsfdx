public class CADS_ETL_Override_Email {

	public CADS_ETL_Override_Email(){
		
	}
	
	
	public PageReference sent()
    {     
    	sent_email();             
    	ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,'Email Sent.'));
    	return null;
    }
    
    public static void sent_email()
    {
    	String env = GlobalUtils.getEnvironment();
    	List<String> lstToEmail = new List<String>();			
		MAP<String,CADS_Steward_Email_gne__c> inf_profiles = CADS_Steward_Email_gne__c.getAll();
        for(CADS_Steward_Email_gne__c env_email : inf_profiles.values())
        {
            if (env_email.Environment_gne__c == env)
            {
                lstToEmail.add(env_email.Email_gne__c);
            }
        }
        String[] toAddresses = lstToEmail;
    	List<CADS_Account_Address_Issues_gne__c> issuesList = new List<CADS_Account_Address_Issues_gne__c>();
    	issuesList = [Select id,name from CADS_Account_Address_Issues_gne__c where ETL_Override_Flag_gne__c='T' and Issue_Closed_Date_gne__c=null and Current_Action_Code_gne__c!=null limit 50000];
    	if(issuesList.size() != 0)
    	{
	    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(lstToEmail);
	        mail.setSubject('ETL Overriden Issues');
	        String mailText = '******PLEASE DO NOT REPLY TO THIS EMAIL****** <br/><br/>';
	        mailText += 'Dear Steward,<br/><br/>'; 
	        mailText += 'The following issues has been overridden by ETL process:<br/><br/>';
	        for(CADS_Account_Address_Issues_gne__c issue: issuesList)
	        {
	        	if(env == 'prod')
	        	{
	        		mailText += '<a href="https://login.salesforce.com/'+issue.id+'">'+ issue.Name +'</a><br/>';
	        	}
	        	else
	        	{
	        		mailText += '<a href="https://test.salesforce.com/'+issue.id+'">'+ issue.Name +'</a><br/>';
	        	}
	        }
	        mailText += '<br/>Best regards,<br/>';
	        mailText += 'System Administrator';
	        System.Debug('-------------mailText'+mailText);
	        mail.sethtmlBody(mailText);
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}
    }
}