/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-19
*  Description: This is a controller class for GNE_SFA2_Speaker_Training_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_STraining_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_STraining_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_STraining_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_STraining_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
}