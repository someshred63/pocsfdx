public with sharing class GNE_SFA2_PROSPECT_Location_Ext extends GNE_SFA2_DynamicVFLoader {
    
    private ApexPages.Standardcontroller controller;
    
    public GNE_SFA2_PROSPECT_Location_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PROSPECT_Location_Layout');
        this.controller = controller;
    }
    
    public PageReference editClick(){
        PageReference pageref = Page.GNE_SFA2_PROSPECT_Location_Edit_Create;
        pageref.getParameters().put('id', myObject.id);
        pageref.setredirect(true);
        return pageref;
    }
}