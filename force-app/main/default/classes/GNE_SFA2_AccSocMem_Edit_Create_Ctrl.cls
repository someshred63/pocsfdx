public class GNE_SFA2_AccSocMem_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create {
	public Integer startYear {get; private set;}
	public Integer endYear {get; private set;}
	
	public GNE_SFA2_AccSocMem_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_AccSocMem_Layout');
        if(controller.getRecord().Id == null){
        	Id accId = (Id)System.currentPageReference().getParameters().get('accountId');
            myObject = new SFA2_Account_Society_Membership_gne__c(Account_gne__c = accId);
        }
        Integer currentYear = System.today().year();
        startYear = currentYear-10;
        endYear = currentYear+10;
    }
    
    public override PageReference save() {
    	PageReference result = super.save();
    	
    	if(result!=null && result.getUrl().startsWith('/apex/GNE_SFA2_AccSocMem_Layout')) {
    		result = new PageReference('/apex/GNE_SFA2_Account_Layout?id=' + ((SFA2_Account_Society_Membership_gne__c)myObject).Account_gne__c);
    	}
    	
    	return result;
    }
}