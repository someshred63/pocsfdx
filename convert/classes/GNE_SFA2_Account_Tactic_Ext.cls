/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 2012-02-21
*  Description: This is a controller extension for GNE_SFA2_Account_Tactic_Layout page
*  
*  Modification History
*  Date        Name        Description
*  
*            
*************************************************************/
public with sharing class GNE_SFA2_Account_Tactic_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Account_Tactic_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Account_Tactic_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Account_Tactic_Edit_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference editStd(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Acc_Tactic_Std_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
}