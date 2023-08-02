public class IssueLogStatusChange{
	
	@AuraEnabled
	public static void changeStatuToClose(String recordId){
		
		try{
		Issue_log__c issue= new Issue_log__c(id=recordId);
		issue.Issue_Status__c='Closed';
		update issue;
		}
		catch(exception ex){
            String errorMessage='';
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errorMessage = ex.getMessage().subStringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,' , ': []');
            }else{
                errorMessage = ex.getMessage();
            }
			throw new AuraHandledException(errorMessage);
		}
	}
	@AuraEnabled
	public static void changeStatuToOpen(String recordId){
		
		try{
		Issue_log__c issue= new Issue_log__c(id=recordId);
		issue.Issue_Status__c='Open';
		update issue;
		}
		catch(exception exp){
		throw new AuraHandledException(exp.getMessage());
		}
	}
    @AuraEnabled
	public static void changeStatusToReOpen(String recordId,String reopenreason){
		system.debug('reopenreason@@'+reopenreason);
        system.debug('recordId@@'+recordId);
		try{
		Issue_log__c issue= new Issue_log__c(id=recordId);
		issue.Issue_Status__c='Re-Open';
        issue.Re_Open_Reason__c=reopenreason;
		update issue;
		}
		catch(exception exp){
        system.debug('exp@@'+exp);
		throw new AuraHandledException(exp.getMessage());
		}
	}
}