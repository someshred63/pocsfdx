public class CADS_ActionHistory {
	List<Stewardship_Issue_Action_History_gne__c> ActionHistory;
	Id issue_id ;
	
	public CADS_ActionHistory(){		
    try{
    	issue_id = ApexPages.currentPage().getParameters().get('Issue_Id');
    	
    	this.ActionHistory = [Select Action_Condition_gne__c,
    								Action_Owner_gne__r.Name,
           							Action_Type_gne__c, Comment_gne__c, 
           							CreatedDate //, CreatedById,LastModifiedDate, LastModifiedById
           							from Stewardship_Issue_Action_History_gne__c
           							Where Issue_Id_gne__c = :issue_id
           							Order by CreatedDate desc ];
    	}
    	 catch (Exception e){
            ApexPages.addMessages(e);
        }
	}
	public list<Stewardship_Issue_Action_History_gne__c> getActionHistory(){
        return ActionHistory;
    }
    
}