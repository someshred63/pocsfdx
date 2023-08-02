global with sharing class CHV_DeletedObjectWrapper {
	
	public String Id;
	
	global CHV_DeletedObjectWrapper(CHV_Deleted_Object__c d){
		this.Id = d.Deleted_Object_Id__c;
	}
		
}