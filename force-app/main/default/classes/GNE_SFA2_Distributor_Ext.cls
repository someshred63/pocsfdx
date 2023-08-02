public with sharing class GNE_SFA2_Distributor_Ext {

	private String retUrl;
	private String parentId;
	public String mode {get; private set;}
	private ApexPages.StandardController controller;
    
	public GNE_SFA2_Distributor_Ext(ApexPages.StandardController stdController) {
		controller = stdController;
		String objId = ApexPages.currentPage().getParameters().get('id');
		retUrl = ApexPages.currentPage().getParameters().get('retUrl');
		parentId = ApexPages.currentPage().getParameters().get('accountId');
		if (String.isBlank(parentId)){
			parentId = ApexPages.currentPage().getParameters().get('objectId');
		}
		if(objId == null || objId == ''){
			mode = 'Create';
		} else {
			mode = 'Edit';
		}
	}

	public PageReference save(){
		if(mode == 'Create'){
			Distributor_fpm_gne__c currentRecord = (Distributor_fpm_gne__c)controller.getRecord();
			currentRecord.Account_ref_gne__c = parentId;
		}
		if(String.isNotEmpty(retUrl)){
			controller.save();
			return new PageReference(retUrl);
		}
		return controller.save();
	}
}