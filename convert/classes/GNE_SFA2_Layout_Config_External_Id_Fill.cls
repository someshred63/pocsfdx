/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-10-23
*  Description: This is a helper class for handling GNE_SFA2_Layout_Configuration External Id field fill
*  Test class: GNE_SFA2_Layout_Config_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*  11/21/2012     Kaavya Karanam    Changing this class to work with the new Configuration Object.      
*************************************************************/
public without sharing class GNE_SFA2_Layout_Config_External_Id_Fill {
    
    private static void setExternalIdValueInsert(List<SFA2_Configuration_Object_gne__c> triggerNew){
        for(SFA2_Configuration_Object_gne__c layoutConfiguration : triggerNew){
            if(layoutConfiguration.Order_gne__c!=null && (!(String.valueof(layoutConfiguration.Order_gne__c).contains('.'))))
        {
            layoutConfiguration.Order_gne__c=Decimal.valueOf(String.valueof(layoutConfiguration.Order_gne__c)+'.0');
            
        }
            
            layoutConfiguration.External_ID_gne__c = layoutConfiguration.Application_Type__c + '_' +  layoutConfiguration.Object_Name_gne__c + '_' + layoutConfiguration.Record_Type_gne__c + '_' +
                                                            + layoutConfiguration.Name+'_'+ layoutConfiguration.Order_gne__c + '_' + layoutConfiguration.Brand_gne__c + '_' +
                                                            + layoutConfiguration.Role_gne__c;
        }
    }
    
    private static void setExternalIdValueUpdate(List<SFA2_Configuration_Object_gne__c> triggerOld, List<SFA2_Configuration_Object_gne__c> triggerNew){
        for(SFA2_Configuration_Object_gne__c layoutConfiguration : triggerNew){
        
        if(layoutConfiguration.Order_gne__c!=null && (!(String.valueof(layoutConfiguration.Order_gne__c).contains('.'))))
        {
            layoutConfiguration.Order_gne__c=Decimal.valueOf(String.valueof(layoutConfiguration.Order_gne__c)+'.0');
            
        }
        
            layoutConfiguration.External_ID_gne__c = layoutConfiguration.Application_Type__c + '_' + layoutConfiguration.Object_Name_gne__c + '_' + layoutConfiguration.Record_Type_gne__c + '_' +
                                                            + layoutConfiguration.Name+'_'+ layoutConfiguration.Order_gne__c + '_' + layoutConfiguration.Brand_gne__c + '_' +
                                                            + layoutConfiguration.Role_gne__c;
                                                            
                                                            
             
                                                                         
        }
    }
    
    public static void onBeforeInsert(List<SFA2_Configuration_Object_gne__c> triggerNew) {
        setExternalIdValueInsert(triggerNew);
    }
    
    public static void onBeforeUpdate(List<SFA2_Configuration_Object_gne__c> triggerOld, List<SFA2_Configuration_Object_gne__c> triggerNew) {
        setExternalIdValueUpdate(triggerOld, triggerNew);
    }
}