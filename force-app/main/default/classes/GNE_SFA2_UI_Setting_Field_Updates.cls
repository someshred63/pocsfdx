/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-02-13
*  Description: This is a trigger for handling SFA2 View Config validations, field updates and child record updates
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_UI_Setting_Field_Updates {
	
	private static void fillExternalId(List<SFA2_UI_Setting_gne__c> triggerNew) {
		for(SFA2_UI_Setting_gne__c uiSetting : triggerNew){
            uiSetting.External_ID_gne__c = uiSetting.Application_gne__c + '_' +  uiSetting.Brand_gne__c + '_' + uiSetting.Role_gne__c + '_' +
                                                            + uiSetting.Type_gne__c + '_' + uiSetting.Sidebar_Item_Type_gne__c + '_' +
                                                            + uiSetting.Order_gne__c;
        }
	}
	
	public static void onBeforeInsertUpdate(List<SFA2_UI_Setting_gne__c> triggerNew) {
		fillExternalId(triggerNew);
	}
}