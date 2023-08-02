/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 2012-02-21
*  Description: This is a controller extension for GNE_SFA2_Account_Goal_And_Obj_Layout page
*  
*  Modification History
*  Date        Name        Description
*  
*            
*************************************************************/
public with sharing class GNE_SFA2_Account_Goal_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Account_Goal_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Account_Goal_And_Obj_Layout');
         visualforceIncludesMap.put('GNE_SFA2_Record_History_Page', false); 
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Account_Goal_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference deleteAccountGAO(){
        String accountPlanId = (String) myObject.get(Schema.Account_Goal_and_Objective_gne__c.Account_Plan_gne__c);       
        try{
            delete myObject;
        }catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pr;
        if(retURL == null){
            if(null != accountPlanId) pr = new PageReference('/'+accountPlanId);
            else pr = new PageReference('/a0y');
        }else{
            pr = new PageReference(retUrl);
        }
        pr.setRedirect(true);
        return pr;
    }
}