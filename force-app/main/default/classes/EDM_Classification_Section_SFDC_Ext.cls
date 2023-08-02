public with sharing class EDM_Classification_Section_SFDC_Ext {

	private enum ClassificationType {Business, Clinical}

	public Boolean isBusinessClassifcationPending {get; private set;}
	public Boolean isClinicalClassifcationPending {get; private set;}
	public String newClinicalRequestUrl {get; private set;}
	public String newBusinessRequestUrl {get; private set;}
	public Date clinicalClassDate{get;set;}
	public Date businessClassDate{get;set;}

	private Id accountId;

	public EDM_Classification_Section_SFDC_Ext(ApexPages.StandardController controller) {
		accountId = controller.getId();

		newBusinessRequestUrl = getUrlFor(ClassificationType.Business);
		newClinicalRequestUrl = getUrlFor(ClassificationType.Clinical);

		//check if pending

		Map<String, EDM_Classification_Request_gne__c> classificationRequestsByType = EDM_Classification_Utils.getPendingClassificationRequestsByTypes(accountId);

        isBusinessClassifcationPending = classificationRequestsByType.containsKey('Business');
        isClinicalClassifcationPending = classificationRequestsByType.containsKey('Clinical');
        if (isClinicalClassifcationPending){
			clinicalClassDate = classificationRequestsByType.get('Clinical').CreatedDate.Date();
		}
		if (isBusinessClassifcationPending){
			businessClassDate = classificationRequestsByType.get('Business').CreatedDate.Date();
		}
	}

	private String getUrlFor(ClassificationType typeOfClassification) {
		PageReference pr = Page.EDM_Classification_Request_Create_SFDC;
		pr.getParameters().put('accountId', accountId);
		pr.getParameters().put('retUrl', '/' + accountId);
		pr.getParameters().put('typeOfClassification', typeOfClassification.name());
		return pr.getUrl();
	}

}