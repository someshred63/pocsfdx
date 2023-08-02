/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-22
*  Description: This is a helper clsass for GNE_SFA2_Time_Off_Territory_Day_Trigger for handling child record updates
*  Test class: GNE_SFA2_Time_Off_Territory_Day_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_ToT_Day_Child_Record_Updates {
	
	public static void onAfterInsert(List<Time_off_Territory_Day_gne__c> triggerNew) {
		TimeOffTerritory_WS.createEventsOnToTDayRecordCreation(triggerNew);
	}
}