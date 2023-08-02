public with sharing class GNE_MCCO_CRM_Survey_Builder_Detail_Ctrl extends GNE_MCCO_CRM_Survey_Util {

    private String surveyId { get; set; }

    public GNE_MCCO_CRM_Survey__c surveyObject { get; private set; }
    public List<Account> accounts { get; private set; }
    public List<Territory2> territories { get; private set; }
    private List<GNE_MCCO_CRM_Survey_Question__c> questionsList { get; set; }
    private List<GNE_MCCO_CRM_Survey_Group__c> groupsList { get; set; }

    public SurveyWrapper survey { get; set; }

    public Boolean canEdit { get; private set; }

    public String iconBase64 { get; private set; }

    public GNE_MCCO_CRM_Survey_Builder_Detail_Ctrl() {

        surveyId    = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
        canEdit     = false;

        if(String.isNotBlank(surveyId)) {
            try {

                // SurveyObject with Questions and Groups
                surveyObject = [SELECT Id, Name, Assignment_Mode_gne__c, Close_Survey_gne__c, Account_Ids_gne__c, Ready_To_Use_gne__c, Record_Type_gne__c, Territories_gne__c, Title_gne__c, Status_gne__c, Notification_gne__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, Requested_By_gne__r.Id, Requested_By_gne__r.Name, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate FROM GNE_MCCO_CRM_Survey__c WHERE Id = :surveyId LIMIT 1];

				// QuestionsList
                questionsList = [SELECT Id, Name, Conditional_Help_Text_gne__c, Group_gne__c, Help_Text_gne__c, Order_gne__c, Required_gne__c, Question_gne__c, Type_gne__c, Values_gne__c FROM GNE_MCCO_CRM_Survey_Question__c WHERE Survey_gne__c = :surveyId];

                // GroupsList
                groupsList = [SELECT Id, Name, Order_gne__c, Title_gne__c FROM GNE_MCCO_CRM_Survey_Group__c WHERE Survey_gne__c = :surveyId];

                // Territories
                if(!String.isEmpty(surveyObject.Territories_gne__c)) {
	                List<String> territoriesIds = surveyObject.Territories_gne__c.split(';');
	                territories = [SELECT Id, Name FROM Territory2 WHERE Id IN :territoriesIds];
                }

                // Account
                if(!String.isEmpty(surveyObject.Account_Ids_gne__c)) {
	                List<String> accountIds = surveyObject.Account_Ids_gne__c.split(';');
	                accounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
                }

                // Create Wrapper From Objects
                survey = new SurveyWrapper();
                survey = survey.createWrapperFromObjects(surveyObject, questionsList, groupsList, false);

                if(surveyObject.Status_gne__c != 'Closed') {
                    canEdit = true;
                }

            } catch (Exception ex) {
            	System.debug(Logginglevel.ERROR, ex.getMessage());
            }
        }

        iconBase64 = GNE_MCCO_CRM_Util.getDocumentBase64('GNE_MCCO_CRM_Survey_Builder_Icon');
    }

    public PageReference checkIfSurveyExists() {
        if(surveyObject == null) {
            PageReference pageRef = new PageReference('/apex/GNE_MCCO_CRM_Survey_Builder');
            pageRef.setRedirect(true);
            return pageRef;
        } else {
            return null;
        }
    }

}