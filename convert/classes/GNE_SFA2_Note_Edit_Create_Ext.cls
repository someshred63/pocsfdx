public with sharing class GNE_SFA2_Note_Edit_Create_Ext  { 

   public Note note_obj{get;set;}
   public String availabilityMode{get;set;}
  
    public GNE_SFA2_Note_Edit_Create_Ext(ApexPages.StandardController controller){
       
       controller.addFields(new List<String>{'IsPrivate', 'Body','ParentId','Title'});
       note_obj = (Note)controller.getRecord();
       
       availabilityMode = controller.getRecord().id != null ? 'Edit' : 'New';
       
       if(controller.getRecord().id==null) 
       note_obj.parentId= System.currentPageReference().getParameters().get('objectId');
       
       
      
    }
    
    
    public PageReference checkRedirect(){
    
    String objectId=(System.currentPageReference().getParameters().get('objectId'))!=null ?(System.currentPageReference().getParameters().get('objectId')):'' ;
    
      if(objectId!=null){
           UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), objectId);
           if (!userRecordAccess.HasEditAccess){
             PageReference pg = Page.GNE_SFA2_Exception_Layout;
             pg.getParameters().put('developerMessage','INSUFFICIENT_ACCESS');
             pg.getParameters().put('exMessage','You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary. ');
             pg.setredirect(true);
             return pg;
           }
           
        }
    
        return null;
    
    
    }
    
    
    public PageReference Save(){
        
        try{
            upsert note_obj;
            String retURL=note_obj.parentId!=null?note_obj.parentId:null;
            Pagereference pg= new pagereference('/'+retURL);
            pg.setredirect(true);
            return pg;
        }
        catch(exception e){
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
        
        return null;
         
    }
}