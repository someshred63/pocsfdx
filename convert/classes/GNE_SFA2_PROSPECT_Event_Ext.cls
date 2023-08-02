public with sharing class GNE_SFA2_PROSPECT_Event_Ext extends GNE_SFA2_DynamicVFLoader {
    
    private ApexPages.Standardcontroller controller;
    
    public GNE_SFA2_PROSPECT_Event_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PROSPECT_Event_Layout');
        this.controller = controller;
    }
    
    public PageReference editClick(){
        PageReference pageref = Page.GNE_SFA2_PROSPECT_Event_Edit_Create;
        pageref.getParameters().put('id', myObject.id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference cloneClick(){
        PageReference pageref = Page.GNE_SFA2_PROSPECT_Event_Edit_Create;
        pageref.getParameters().put('retUrl', '/' + myObject.id);
        pageref.getParameters().put('cloneFrom', myObject.id);
        pageref.setredirect(true);
        return pageref;
    }
}