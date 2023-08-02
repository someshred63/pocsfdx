public class GNE_SFA2_ProductCatalog_list_Ctlr extends GNE_SFA2_List_View_Base_Controller {

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
     
    public GNE_SFA2_ProductCatalog_list_Ctlr () {
        super('Product_vod__c');
        thisController = this;
    }
    
    public PageReference newClick(){
        PageReference pg = Page.GNE_SFA2_PCatalog_Edit_Create_Layout;
        pg.getParameters().put('retURL', '/apex/GNE_SFA2_PCatalog');
        return pg;
    }

}