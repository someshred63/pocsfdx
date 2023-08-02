/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-09-28
*  Description: This is a controller extension for GNE_SFA2_Affiliation_Layout page
*  
*  Modification History
*  Date        Name        Description
*  2012-12-13  lewandj2    New approach with configuration object
*            
*************************************************************/
public with sharing class GNE_SFA2_Affiliation_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Affiliation_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Affiliation_Layout');
    }

    public PageReference edit(){
        String retURL = System.currentPageReference().getParameters().get('retURL');
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Affiliation_Edit_Create_Layout?id='+myObject.Id+'&retURL='+retURL);
        pageref.setredirect(true);
        return pageref;
    }
}