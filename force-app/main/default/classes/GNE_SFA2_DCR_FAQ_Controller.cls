public with sharing class GNE_SFA2_DCR_FAQ_Controller {
  
    private SFA2_Configuration_Object_gne__c pageConfiguration;
  
    public GNE_SFA2_DCR_FAQ_Controller() {
      pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Change_Request_gne__c');
    }

    public String getActiveMenuItem() {
       String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
        result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }
}