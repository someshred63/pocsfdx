public with sharing class GNE_SFA2_Task_Ext extends GNE_SFA2_DynamicVFLoader {
   
   
   public GNE_SFA2_Task_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Task_Layout');
    }
   
    public PageReference editTask(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Task_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
        return null;
    }
    
     
     public PageReference createFollowUpTask(){
        /*pagereference pageref = new pagereference('/apex/GNE_SFA2_IRFDetail_edit_page?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;*/
        return null;
    }
    
     public PageReference updateAccountTask(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_MCCO_ART_AddAccount?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
        //return null;
    }
    
    public PageReference createFollowUpEvent(){
    	
        pagereference pageref = new pagereference('/apex/SFDCToGCalRedirectProgressPage');
        pageref.setredirect(true);
        return pageref;
    	
    }
    
    
    public PageReference deleteTask(){
    
    	delete myObject;
    	pagereference pageref = new pagereference('/apex/GNE_SFA2_MyTasks');
    	pageref.setredirect(true);
    	return pageref;
    	
    }
    
    
}