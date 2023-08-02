/************************************************************
*  @author: 
*  Date: 
*  Description: 
*  Modification History
*  Date        Name        Description
*  11-06-2013    Lukasz Bieniawski    Manage access to the page: new canBeCreatedOrEdited method, override init method.        
*************************************************************/

public with sharing class GNE_SFA2_ART_Issue_Edit_Create_Ext  extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    
    public GNE_SFA2_ART_Issue_Edit_Create_Ext(ApexPages.StandardController controller){
         super(controller,'/apex/GNE_SFA2_ART_Issue_Layout');
        
        String objectId = ApexPages.currentPage().getParameters().get('objectId');
        
        if(myObject == null){
            myObject = new ART_Issue_gne__c();
        }
        
        if(objectId != null && objectId != '' && myObject.id == null){
            myObject.put('ART_Site_Local_gne__c', objectId);
        }
    }
    
    public override PageReference init(){       
        try{
            if (canBeCreatedOrEdited()){
                system.debug('===>'+canBeCreatedOrEdited());
                return GNE_SFA2_Util.redirectToAccessDeniedPage();              
            } else {
                return super.init();
            }
        } catch(Exception ex){
            return GNE_SFA2_Util.redirectToErrorPage('An error occured during loading the page', Apexpages.currentPage().getUrl(), ex.getMessage());
        }       
    }
    
    private Boolean canBeCreatedOrEdited(){
        Boolean result = false;
        
        String currentUserProfileName = GNE_SFA2_Util.getCurrentUserProfileName();
        if (currentUserProfileName.containsIgnoreCase('GNE-MCCO-MCL-Manager')){
            return result;
        }
        
        Map<String, String> parametersMap = ApexPages.currentPage().getParameters();
        String artSite = parametersMap.get('objectId');
        List<ART_Team_gne__c> memberships = [select id from ART_Team_gne__c where ART_Site_gne__c = :artSite and Team_Member_gne__c = :Userinfo.getUserId()];
        
        result = !memberships.isEmpty() || currentUserProfileName.containsIgnoreCase('Manager') || currentUserProfileName.containsIgnoreCase('Ops') 
            || currentUserProfileName.containsIgnoreCase('Leadership');

        return result;
    }
}