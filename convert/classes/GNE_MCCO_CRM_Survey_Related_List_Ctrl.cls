public with sharing class GNE_MCCO_CRM_Survey_Related_List_Ctrl {

    public final Account ACCOUNT_OBJ { get; private set; }

    public List<GNE_MCCO_CRM_Field_Intelligence__c> fieldIntelligenceList { get; private set; }
    public String fieldIntelligenceListJson { get; private set; }
    public Integer fieldIntelligenceCount { get; private set; }
    public Boolean hasfieldIntelligence { get; private set; }
    public String userTimeZone { get; private set; }    
    public Boolean isBamCrmUser { get; private set; }

    public GNE_MCCO_CRM_Survey_Related_List_Ctrl(ApexPages.StandardController stdController) {
        ACCOUNT_OBJ   = (Account)stdController.getRecord();
        
        fieldIntelligenceList       = getFieldIntelligences();
        fieldIntelligenceListJson   = JSON.serializePretty(fieldIntelligenceList);
        fieldIntelligenceCount      = fieldIntelligenceList.size();
        
        if(fieldIntelligenceCount > 0) {
            hasfieldIntelligence = true;
        } else {
            hasfieldIntelligence = false;
        }
        
        userTimeZone = String.valueOf(UserInfo.getTimeZone());
        isBamCrmUser = GNE_SFA2_Util.isBamCrmUser();
    }
    
    private List<GNE_MCCO_CRM_Field_Intelligence__c> getFieldIntelligences() {
        return [SELECT Id, Name, Account_gne__c, Available_gne__c, Comment_gne__c, Previous_Status__c, Survey_gne__c, Survey_Status_gne__c, Title_gne__c, User_gne__c, User_gne__r.Name, Survey_gne__r.Title_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Account_gne__c = :ACCOUNT_OBJ.Id AND Available_gne__c = true ORDER BY LastModifiedDate DESC];  
    }

}