global class AGS_INF_Deactivation_invoke {
		
	global void AGS_INF_Deactivation_invoke()
	{
		
	}
	public static void start()
	{
		String query = 'select Id, Username, Name,  IsActive, LastLoginDate, Profile.name, External_ID_gne__c from User where ((lastlogindate <= YESTERDAY or lastlogindate= null) and profile.name =\'GNE-INFREQUENT-USER\') AND IsActive = true';
		
        system.debug(query);      
        
        AGS_INF_Deactivation Test = new AGS_INF_Deactivation(query);          
        ID batchprocessid = Database.executeBatch(Test,1);
        
           System.debug('Watch out');	
	}
}