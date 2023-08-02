/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-01-16
*  Description: This is a controller extension for GNE_SFA2_Advoc_Assess_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Advoc_Assess_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_Advoc_Assess_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Advoc_Assess_Layout');
        
        String brandAffiliationId = ApexPages.currentPage().getParameters().get('objectId');
        String ownerId = UserInfo.getUserId();
        
        if(myObject == null){
            myObject = new Advocacy_Assessment_gne__c();
        }
        
        if(brandAffiliationId != null && brandAffiliationId != '' && myObject.id == null){
            myObject.put('Brand_Affiliations_gne__c', brandAffiliationId);
            myObject.put('OwnerId', ownerId);
        }
    }
}