trigger SRW_SalesData_Is_Actual_Setter on SRW_Sales_Data_gne__c (before insert) {
	List<SRW_Sales_Data_gne__c> salesDataForUpdate  = [SELECT id, Is_Actual_gne__c FROM SRW_Sales_Data_gne__c 
													   WHERE TP_Data_Month_gne__c = :Trigger.new[0].TP_Data_Month_gne__c
			                                           AND Trading_Partner_gne__c = :Trigger.new[0].Trading_Partner_gne__c
			                                           AND Prescriber_Organization_Location_gne__c = :Trigger.new[0].Prescriber_Organization_Location_gne__c
			                                           AND Is_Actual_gne__c = true];
    for(SRW_Sales_Data_gne__c sd : salesDataForUpdate){
    	sd.Is_Actual_gne__c = false;
    }
    if(!salesDataForUpdate.isEmpty()) update salesDataForUpdate;
}