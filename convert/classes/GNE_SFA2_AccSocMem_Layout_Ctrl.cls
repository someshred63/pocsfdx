public class GNE_SFA2_AccSocMem_Layout_Ctrl extends GNE_SFA2_DynamicVFLoader {
	public GNE_SFA2_AccSocMem_Layout_Ctrl(ApexPages.StandardController controller) {
		super(controller,'/apex/GNE_SFA2_AccSocMem_Layout');
	}
	
	public override PageReference deleteClick() {
		PageReference result = super.deleteClick();
    	
    	if(result!=null && result!=Page.GNE_SFA2_Access_Denied) {
    		result = Page.GNE_SFA2_Account_Layout;
        	result.getParameters().put('id', ((SFA2_Account_Society_Membership_gne__c)myObject).Account_gne__c);
        	result.setredirect(true);
    	}
    	
    	return result;
	}
}