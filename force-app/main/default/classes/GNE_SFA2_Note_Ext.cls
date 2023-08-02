public with sharing class GNE_SFA2_Note_Ext {

    private Id note_id;

    public Note note_obj{get;set;}   
   
    public GNE_SFA2_Note_Ext(ApexPages.StandardController controller){
        note_id = ((Note)controller.getRecord()).Id;
        List<Note> notes = [select ownerId,parentId,IsPrivate,Title,Body,CreatedById,CreatedBy.Name,CreatedDate,LastModifiedById,LastModifiedBy.Name,LastModifiedDate from Note where Id=:note_id];
       
        if(notes!=null && notes.size()>0){
            note_obj = notes[0];
        }
    }
    
    public Boolean getCanEdit(){
        Boolean result = true;
        UserRecordAccess userAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), note_id);       
        if (userAccess != null){
            result = userAccess.HasEditAccess;
        }
        return result;
    }
   
    public Boolean getCanDelete(){
        Boolean result = true;
        UserRecordAccess userAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), note_id);
        if (userAccess != null){
            result = userAccess.HasDeleteAccess;
        }
        return result;
    }
    
    public PageReference editNote(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Note_Edit_Create_Layout?id='+note_obj.Id+'&objectId='+note_obj.ParentId+'&retURL='+note_obj.parentId);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference deleteNote(){
        try{
            String retURLID =note_obj.parentId;
            delete note_obj;
            pagereference pageref = new pagereference('/'+retURLID);
            pageref.setredirect(true);
            return pageref;
        } catch (Exception ex){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage())); 
           return null;
        }
    }
}