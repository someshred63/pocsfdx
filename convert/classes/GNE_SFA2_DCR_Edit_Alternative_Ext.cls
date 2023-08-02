/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-02-23
*  Description: This is a controller extension for GNE_SFA2_DCR_Edit_Alternative_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_DCR_Edit_Alternative_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_DCR_Edit_Alternative_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_DCR_Dispatcher');
        
       // String brandAffiliationId = ApexPages.currentPage().getParameters().get('objectId');
        
        if(myObject == null){
            myObject = new Change_Request_gne__c();
        }
        
        //myObject.put('Brand_Affiliations_gne__c', brandAffiliationId);
    }
    
    public override PageReference init() {
     	PageReference result = super.init();
     	
     	// Set Request Analyst if current user is Home Office
     	if(result==null && myObject.Id!=null) {
     		GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_Util.getUserApplicationContext();
        	if(userAppContext!=null && userAppContext.Brand_gne__c == null && userAppContext.Role_gne__c == GNE_SFA2_PFG_Util.USER_ROLE_MANAGER) {
        		Change_Request_gne__c dcr = (Change_Request_gne__c)myObject;
        		dcr.Assigned_Analyst_gne__c = UserInfo.getUserId();
        	}	
     	}
     	
     	return result;	
     }
}