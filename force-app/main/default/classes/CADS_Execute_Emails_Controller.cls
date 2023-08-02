public class CADS_Execute_Emails_Controller 
{   
    Public PageReference executeBatch()
    { 
        List<CADS_Email_Batch_Process_gne__c> batchStatus = CADS_Email_Batch_Process_gne__c.getall().values();
        system.debug('----batchStatus[0].Status_gne__c'+batchStatus[0].Status_gne__c);
        if(batchStatus[0].Status_gne__c == 'Processing')
        {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Batch is still processing. Please try again later.'));
        }
        else
        { 
            batchStatus[0].Status_gne__c = 'Processing';
            update batchStatus; 
            /*
            String query = 'Select Name,Id,Is_Infrequent_gne__c, Is_Alert_User_Active_gne__c, Alert_user_Unix_Id_gne__c,Alert_User_Email_Id_gne__c from CADS_Account_Address_Issues_gne__c  where Alert_the_User_gne__c = \'yes\' and Current_Action_Email_Status_gne__c= \'Not Sent\' and Alert_User_Email_Id_gne__c != null and LastModifiedDate =today and lastmodifiedbyid in (';
            List<String> idList = new List<String>();    
			List<String> mailToAddresses = new List<String>();    
			Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'Data Stewardship']; 
			for (integer i=0;i<g.groupMembers.size();i++) 
			{        
				if(i == g.groupMembers.size()-1)
				{
					query += '\''+g.groupMembers[i].userOrGroupId+'\''; 
				}
				else
					query += '\''+g.groupMembers[i].userOrGroupId+'\',';    
			}  
            query += ')';*/
              
            String query = 'Select Name,Id,Is_Infrequent_gne__c, Is_Alert_User_Active_gne__c, Alert_user_Unix_Id_gne__c,Alert_User_Email_Id_gne__c from CADS_Account_Address_Issues_gne__c  where Alert_the_User_gne__c = \'yes\' and Current_Action_Email_Status_gne__c= \'Not Sent\' and Alert_User_Email_Id_gne__c != null and LastModifiedDate =today and lastmodifiedby.name != \'ETL Publish\'';
            CADS_CreateEmailsBatch emailsBatch =  new CADS_CreateEmailsBatch(query);    
            ID batchprocessid = Database.executeBatch(emailsBatch);
            System.debug('Created emailsBatch');
        }
        return null;
    }
}