//Created by: Sharmas 04/21/2010
//Class created to update username on user record when Portal Username field on account is updated.
public class GNE_CM_Update_Account_Portal_Username 
{
	//Sharmas 04/21/2010: Defect ID : 11369. Method for updating User with new value of Physician_Portal_Username_gne__c
	@future
	public static void updateUser(Map<string,string> accountMap)
	{
		List<User> userListToUpdate = new List<User>();
    	try
    	{
    		//Sharmas 04/21/2010: Get list of associated Users based on PersonContactId field of Account
    		userListToUpdate = [Select u.Username, u.Id, u.ContactId From User u where u.ContactId in : accountMap.keyset() LIMIT 1000];
	    	if(userListToUpdate.size() > 0)
	    	{
	    		//Sharmas 04/29/2010: Defect 11584: Code added to append environment type to Username.
	    		String username=UserInfo.getUserName();   
				String env='';
				String username_ext='';
				if(username.indexOf('@gene.com') > 0 && username.indexOf('@gene.com.') <0)      
					env= 'prod';      
				else if(username.indexOf('@gene.com.') >0)     
					env=username.Substring(username.indexOf('@gene.com.')+10, username.length()); 
		                      
				if(env == 'prod')
					username_ext='gene.mps';
				else
					username_ext='gene.mps.' + env;
					
	    		for(User updateUser:userListToUpdate)
	    		{
	    			//Sharmas 04/21/2010: Assign updated value of Physician_Portal_Username_gne__c to Username field.
	    			updateUser.Username = accountMap.get(updateUser.ContactId) + '.' + username_ext;
	    		}
	    		Database.SaveResult[] saveResultUpdate = database.update(userListToUpdate,false);
	    		
				/**************************************************************************
    			// 							D E B U G - L O G
    			//				To view User records that were not updated
    			**************************************************************************/
	    		for(integer i = 0; i < saveResultUpdate.size(); i++)
	    		{
	    			if(!saveResultUpdate[i].isSuccess())
	    				system.debug(' Failed to update record ---> ' + saveResultUpdate[i]);
	    		}
	    	}
    	}
    	catch(Exception ex)
    	{
    		System.debug('ERROR: '+ ex);
    	}
	} 
}