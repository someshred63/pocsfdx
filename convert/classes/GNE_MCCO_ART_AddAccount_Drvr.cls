public class GNE_MCCO_ART_AddAccount_Drvr {
	
	public Contact act {get; set;}
	public Task task {get; set;}
	
	
	public GNE_MCCO_ART_AddAccount_Drvr (ApexPages.StandardController controller) {
		
		this.act = new Contact();
		//act.Name ='Same';
		system.debug('ActInfo: '+this.act);
		task = new Task(id=ApexPages.currentPage().getParameters().get('id'));
	
	}

	public pageReference processId() {
		system.debug('I am in next');
	    system.debug('I am in next: '+act);
		
		if(this.act.AccountId == null){	
			system.debug('I am there');							
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select an Account'));
			return null;
		}
		else{
			system.debug('I am here');
			Account a_x = new Account();
			a_x = [select ID, Name from Account where id = :this.act.AccountId limit 1];
			task.Account_ID_gne__c = a_x.Id;
			//task.Account_Name_gne__c = [select Name from Account where id=:act.Id].Name;
			task.Account_Name_gne__c = a_x.Name;
			update task;
			
			PageReference pageRef = new PageReference('/'+task.Id);
			return pageRef;
		}
	}
	
   	public pageReference cancel() {
   		
   		PageReference pageRef = new PageReference('/'+task.Id);
		return pageRef;

   	}
	
}