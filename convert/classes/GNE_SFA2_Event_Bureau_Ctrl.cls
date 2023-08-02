/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-11
*  Description: This is a controller class for GNE_SFA2_Event_Bureau_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Event_Bureau_Ctrl extends GNE_SFA2_DynamicVFLoader { 
  
    public GNE_SFA2_Event_Bureau_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_EBureau_Layout');
    }
    
    public PageReference editEventBureau(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_EBureau_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
     
}