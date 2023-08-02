public class GNE_SFA_Account_Trigger {
	
	// Check if the GNE_SFA_Canada_MRM_Account_Validation_BefUpdate trigger is done
	private static Boolean canadaMRMAccountChecked = false;
	
	public static void setCanadaMRMAccountChecked(Boolean checked){
		canadaMRMAccountChecked = checked;
	}
	
	public static Boolean getCanadaMRMAccountChecked(){
		return canadaMRMAccountChecked;
	}
}