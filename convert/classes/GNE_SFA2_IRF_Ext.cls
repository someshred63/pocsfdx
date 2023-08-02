/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-18
*  Description: This is a controller extension for GNE_SFA2_IRF page
*  
*  Modification History
*  Date        Name        Description
*  2012-12-14  lewandj2    New approach with configuration object
*            
*************************************************************/
public with sharing class GNE_SFA2_IRF_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_IRF_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_IRF_Layout');
        
        // we have to put all possible included pages into the map with "false" value to fix sf bug with maps on vf pages
        //visualforceIncludesMap.put('visualforce_page_name', false);
    }

    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_IRF_edit_create_layout?id='+myObject.Id);
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
        return null;
    }
    
}