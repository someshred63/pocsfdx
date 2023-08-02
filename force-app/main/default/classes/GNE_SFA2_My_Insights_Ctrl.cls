global with sharing class GNE_SFA2_My_Insights_Ctrl extends GNE_SFA2_List_View_Base_Controller {

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }

    public GNE_SFA2_My_Insights_Ctrl () {
        super('Independent_Insight_vod__c');
        thisController = this;
    }

    public Boolean getIsMenuVisible() {
        return !GNE_SFA2_Util.isCanadaINFUUser();
    }

    public PageReference createEdit(){
        PageReference pr = new PageReference('/apex/GNE_SFA2_Independent_Insight_Edit_Create');
        pr.setRedirect(true);
        return pr;
    }

}