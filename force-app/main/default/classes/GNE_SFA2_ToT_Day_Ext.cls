/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-02-18
*  Description: This is a controller extension for GNE_SFA2_ToT_Day_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_ToT_Day_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_ToT_Day_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_ToT_Day_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_ToT_Day_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    override public PageReference deleteClick(){
        Id timeOffTerritoryId = (Id) myObject.get('Time_Off_Territory_gne__c');
        try{
            delete(myObject);
        } catch (DMLException ex){
            if(ex.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_OR_READONLY || ex.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY) {
                return Page.GNE_SFA2_Access_Denied;
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getdmlMessage(0)));
                return null;
            }
        }
        PageReference pageref = new PageReference('/' + timeOffTerritoryId);
        pageref.setredirect(true);
        return pageref; 
    }
}