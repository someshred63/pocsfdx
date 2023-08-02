public with sharing class GNE_SFA2_ART_Team_Ext extends GNE_SFA2_DynamicVFLoader {
   
   
   public GNE_SFA2_ART_Team_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_ART_Team_Layout');
         
    }
   
    public PageReference editARTIssue(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_ART_Team_Edit_Create_Layout?id='+myObject.Id);
        pageref.getParameters().put('retURL', System.currentPageReference().getParameters().get('retURL')); 
        pageref.setredirect(true);
        return pageref;
        //return null;
    }
    
    public PageReference deleteARTIssue(){
       
       delete myObject;
        pagereference pageref = new pagereference('/apex/GNE_SFA2_MCCO_ART_Tab');
        pageref.setredirect(true);
        return pageref;
        //return null;
    }
    
     
    
    
}