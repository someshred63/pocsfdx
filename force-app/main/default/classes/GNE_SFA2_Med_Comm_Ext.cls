/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-02-08
*  Description: This is a controller extension for GNE_SFA2_Med_Comm_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Med_Comm_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Med_Comm_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Med_Comm_Layout');
    }

    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Med_Comm_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    public override PageReference deleteClick() {
        Id accId = null;
        List<Medical_Communication_gne__c> medComAsList = [SELECT Account_gne__c FROM Medical_Communication_gne__c WHERE ID = :myObject.Id LIMIT 1];
        
        for(Medical_Communication_gne__c medCom : medComAsList) {
            accId = medCom.Account_gne__c;
        }
        
        PageReference result = super.deleteClick();
        
        if(result!=null && result!=Page.GNE_SFA2_Access_Denied && accId!=null) {
            result = new PageReference('/' + accId); 
        }
        
        return result;
    }
}