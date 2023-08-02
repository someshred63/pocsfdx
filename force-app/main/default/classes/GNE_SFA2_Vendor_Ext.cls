public with sharing class GNE_SFA2_Vendor_Ext extends GNE_SFA2_DynamicVFLoader {
	
    public GNE_SFA2_Vendor_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Vendor_Layout');
	}
	
	public String getPfgActiveMenuItem() {
        return GNE_SFA2_PFG_Base_Controller.MY_PFG_PAGE_NAME;
    }

}