public with sharing class GNE_SFA2_TLMap_Controller {
  
  	private SFA2_Configuration_Object_gne__c pageConfiguration;
  
  	public GNE_SFA2_TLMap_Controller() {
  		pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('TLMap');
  	}
  
  	public String getListPageName() {
        String result;
        if(pageConfiguration != null) {
            result = pageConfiguration.Section_Header_gne__c;
        } else {
            result = '';
        }
  	 	return result;
  	}
  
  	public String getActiveMenuItem() {
  	 	String result = '';
      	if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
    	  result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
      	}
      	return result;
  	}
   
  	public String envUrl{
    	get{
      		return Utilities.getGlobalVariable('BO_Server_Name');
    	}
    	private set;
  	}
}