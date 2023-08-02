/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-31
*  Description: This is a controller class for GNE_SFA2_EventCurclm_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_EventCurclm_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_EventCurclm_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_ECurriculum_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_ECurriculum_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
     
}