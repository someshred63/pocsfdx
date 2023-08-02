global with sharing class GNE_MCCO_CRM_Interactions_Rel_List_Ctrl {

    public final Account ACCOUNT_OBJ { get; private set; }

    public List<Call2_vod__c> interactionList { get; private set; }
    public String interactionListJson { get; private set; }
    public Integer interactionCount { get; private set; }
    public Boolean hasInteractions { get; private set; }

    public String userTimeZone { get; private set; }
    public Boolean isBamCrmUser { get; private set; }
    public Boolean isEsbrietCrmUser { get; private set; }
    public String columnsDefinitionName {get; private set; }

    public GNE_MCCO_CRM_Interactions_Rel_List_Ctrl(ApexPages.StandardController stdController) {
        ACCOUNT_OBJ         = (Account)stdController.getRecord();
        interactionList     = getInteractions();
        interactionListJson = JSON.serializePretty(interactionList);
        interactionCount    = interactionList.size();

        if (interactionList.size() > 0) {
            hasInteractions = true;
        } else {
            hasInteractions = false;
        }

        userTimeZone = String.valueOf(UserInfo.getTimeZone());
        isBamCrmUser = GNE_SFA2_Util.isBamCrmUser();
        isEsbrietCrmUser = GNE_SFA2_Util.isEsbrietCrmUser();
        
        if (isEsbrietCrmUser) {  
        	columnsDefinitionName = 'ESBRIET_' + ((ACCOUNT_OBJ.isPersonAccount == true) ? 'HCP' : 'HCO');
        } else if (isBamCrmUser) {
            columnsDefinitionName = 'BAM_' + ((ACCOUNT_OBJ.isPersonAccount == true) ? 'HCP' : 'HCO');
        } else {
            columnsDefinitionName = 'default';
        }
    }

    private List<Call2_vod__c> getInteractions() {
        return [SELECT Id, Name, Subject_vod__c, Call_Date_vod__c, Interaction_Status_gne__c, Interaction_Type_gne__c ,Date_of_Interaction_gne__c, CreatedBy.Name, CreatedById, CreatedDate,
                        Owner.Name
                FROM Call2_vod__c
                WHERE Account_vod__c = :ACCOUNT_OBJ.Id
                    AND Parent_Call_vod__c = NULL
                ORDER BY Name DESC];
    }

    @RemoteAction
    global static String deleteInteraction(String callId){
        String errorMessage = '';
        try{
            delete new Call2_vod__c(Id=callId);
        }
        catch(Exception ex){
            System.debug('GNE_MCCO_CRM_Interactions_Rel_List_Ctrl.deleteInteraction Exception' + ex);
            errorMessage = ex.getMessage();
        }
        return errorMessage;
    }

}