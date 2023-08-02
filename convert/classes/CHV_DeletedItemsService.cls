@RestResource(urlMapping='/DeletedItemsService/*')
global with sharing class CHV_DeletedItemsService {
	
	@HttpGet
	global static CHV_DeletedObjectsWithTimestampWrapper getDeletedItemsService(){
		RestRequest req = RestContext.request;
		String timestamp = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
		Long timestampL = Long.valueOf(timestamp) * 1000;
		Datetime luDate = Datetime.newInstance(timestampL);
		
		List<CHV_DeletedObjectWrapper> deletedObjects = new List<CHV_DeletedObjectWrapper>();
		if (luDate != null){
			List<CHV_Deleted_Object__c> dObjs = [SELECT Id, Deleted_Object_Id__c, Deleted_Object_Type__c FROM CHV_Deleted_Object__c WHERE CreatedDate >: luDate];
			if (CHV_Utils.listNotEmpty(dObjs)){
				for (CHV_Deleted_Object__c dObj : dObjs){
					deletedObjects.add(new CHV_DeletedObjectWrapper(dObj));
				}
			}
		}
		return new CHV_DeletedObjectsWithTimestampWrapper(deletedObjects);
	}
	
	global class CHV_DeletedObjectsWithTimestampWrapper {
		
		List<CHV_DeletedObjectWrapper> deletedObjectsList = new List<CHV_DeletedObjectWrapper>();
		String currentTimestamp;
		
		public CHV_DeletedObjectsWithTimestampWrapper(List<CHV_DeletedObjectWrapper> delObjs) {
			this.currentTimestamp = CHV_Utils.getCurrentTimeInTimestampGMT();
			this.deletedObjectsList = delObjs;
		}
	}	
}