public with sharing class GNE_SFA2_ART_Site_Ext extends GNE_SFA2_DynamicVFLoader {
   
   
   public GNE_SFA2_ART_Site_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_ART_Site_Layout');
         //visualforceIncludesMap.put('GNE_MCCO_ART_Matrix', false);
    }
   
    public PageReference editARTSite(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_ART_Site_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
        //return null;
    }
    
    public PageReference deleteARTSite(){
       
       delete myObject;
        pagereference pageref = new pagereference('/apex/GNE_SFA2_MCCO_ART_Tab');
        pageref.setredirect(true);
        return pageref;
        //return null;
    }

    public PageReference addAttachment(){
        String sbcURL = '/apex/GNE_SFA2_UploadAttachment?Id='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }     
     public PageReference updateAttachment(){
     
      UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), myObject.Id);
                if (!userRecordAccess.HasEditAccess){
                    return GNE_SFA2_Util.redirectToErrorPage('You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.', Apexpages.currentPage().getUrl(), 
                        'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary');                                   
                }
        pagereference pageref = new pagereference('/apex/GNE_SFA2_UploadAttachment?Id='+myObject.Id);
        pageref.getParameters().put('retURL', myObject.Id);
        pageref.setredirect(true);
        return pageref;
        
     }
    
    
     public PageReference viewAttachment(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Attachment_layout?Id='+myObject.Id);
        pageref.getParameters().put('retURL', myObject.Id);
        pageref.setredirect(true);
        return pageref;
      
    }
    
    
    
}