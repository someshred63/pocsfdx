/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-10
*  Description: This is a controller class for GNE_SFA2_Curriculum_Module_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Curriculum_Module_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Curriculum_Module_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_CModule_Layout');
    }
    
    public PageReference editCurriculumModule(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_CModule_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
     
}