public class GNE_SFA2_AccSocMem_Trigger_Helper {
	private static Boolean inAccSocMemTrig;

	public static Boolean inAccSocMemTrig() {
		return inAccSocMemTrig==true;
	}
	
	public static void setAccSocMemTrig(Boolean newValue) {
		inAccSocMemTrig = newValue;
	}
}