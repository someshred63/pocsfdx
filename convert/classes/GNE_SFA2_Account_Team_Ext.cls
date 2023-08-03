/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-01-16
*  Description: This is a controller extension for GNE_SFA2_Account_Team_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Account_Team_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Account_Team_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Account_Team_Layout');
    }

    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Account_Team_Edit_Create_Layout?id='+myObject.id);
        pageref.setredirect(true);
        return pageref;
    }
}