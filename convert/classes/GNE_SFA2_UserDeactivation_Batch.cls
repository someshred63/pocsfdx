global class GNE_SFA2_UserDeactivation_Batch implements Database.Batchable<sObject> {

	global GNE_SFA2_UserDeactivation_Batch() {
	}
	
	global Iterable<sObject> start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
				SELECT Id, IsActive 
				FROM User 
				WHERE IsActive = true AND lastlogindate < LAST_N_DAYS:45 AND
					profile.name ='GNE-Chatter-Free']);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<User> users = (List<User>)scope;

		for(User u : users) {
			u.isActive = false;
		}

		update users;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}