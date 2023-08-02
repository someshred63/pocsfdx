/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-15
*  Description: This is a controller class for GNE_SFA2_Product_Plan_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Product_Plan_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Product_Plan_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Product_Plan_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Product_Plan_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference addAttachmentsClick(){
        String sbcURL = '/apex/GNE_SFA2_UploadAttachment?Id='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    } 

    public PageReference viewAttachmentsClick(){
        String sbcURL = '/apex/GNE_SFA2_Attachment_layout?Id='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }     
}