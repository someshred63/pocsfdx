public with sharing class GNE_SFA2_PFG_InventoryCount_Ctrl extends GNE_SFA2_DynamicVFLoader {
    
    public List<SFA2_PFG_Inventory_Count_gne__c> inventoryCounts {get; private set;}
    
    public GNE_SFA2_PFG_InventoryCount_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PFG_InventoryCount_Layout');
        inventoryCounts = GNE_SFA2_PFG_DAO.getInventoryCountsByRefNo(GNE_SFA2_PFG_DAO.getInventoryCountRefNo(controller.getRecord().Id));
    }
    
    public String getPfgActiveMenuItem() {
        return GNE_SFA2_PFG_Base_Controller.MY_PFG_PAGE_NAME;
    }
}