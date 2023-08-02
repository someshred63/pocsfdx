public with sharing class GNE_SFA2_ART_Issue_Ext extends GNE_SFA2_DynamicVFLoader {
    
    public GNE_SFA2_ART_Issue_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_ART_Issue_Layout');
        visualforceIncludesMap.put('GNE_SFA2_Record_History_Page', false);
    }
   
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_ART_Issue_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);        
        return pageref;
        //return null;
    }
    
    public PageReference cloneARTIssue(){        
        pagereference pageref = new pagereference('/apex/GNE_SFA2_ART_Issue_Edit_Create_Layout?id='+myObject.Id+'&isClone=true');
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference deleteARTIssue(){
        delete myObject;
        pagereference pageref = new pagereference('/apex/GNE_SFA2_My_ART_Issues');
        pageref.setredirect(true);
        return pageref;
        //return null;
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

    public PageReference addAttachmentsClick(){
        String sbcURL = '/apex/GNE_SFA2_UploadAttachment?Id='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    } 
            
    public PageReference viewAttachment(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Attachment_layout?Id='+myObject.Id);
        pageref.getParameters().put('retURL', myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference createNote(){        
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Test?parentId='+myObject.Id);
        pageref.getParameters().put('retURL', myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    public boolean getcancreate(){
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
        List<ART_Team_gne__c> memberships = [select id from ART_Team_gne__c where ART_Site_gne__c = :myObject.Id and Team_Member_gne__c = :Userinfo.getUserId()];
        if(memberships!=null && memberships.size()>0){
            return true;
        }
        // userApplicationContext.Brand_gne__c+ '***role**'+userApplicationContext.Role_gne__c + '***app type**' + userApplicationContext.App_Name_gne__c
        String role =userApplicationContext.Role_gne__c.toLowerCase();
        if(!role.contains('mcl-manager')) {
            if(role.contains('manager') || role.contains('ops')|| role.contains('leadership')) {
                return true;
            }
        }
        return false;
    }
}