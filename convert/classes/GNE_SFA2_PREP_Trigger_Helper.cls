public class GNE_SFA2_PREP_Trigger_Helper {
	private static Boolean inTestingStrategyTrig;
	private static Boolean inMboTrig;
	private static Boolean inAccTestingObjectiveTrig;
	private static Boolean inAccTestingInfoTrig;
	private static Boolean inAccStrategyTrig;
	private static Boolean inAccMBOTrig;
	
	public static Boolean inTestingStrategyTrig() {
		return inTestingStrategyTrig==true;
	}
	
	public static void setTestingStrategyTrig(Boolean newValue) {
		inTestingStrategyTrig = newValue;
	}
	
	public static Boolean inMboTrig() {
		return inMboTrig==true;
	}
	
	public static void setMboTrig(Boolean newValue) {
		inMboTrig = newValue;
	}
	
	public static Boolean inAccTestingObjectiveTrig() {
		return inAccTestingObjectiveTrig==true;
	}
	
	public static void setAccTestingObjectiveTrig(Boolean newValue) {
		inAccTestingObjectiveTrig = newValue;
	}
	
	public static Boolean inAccStrategyTrig() {
		return inAccStrategyTrig==true;
	}
	
	public static void setAccStrategyTrig(Boolean newValue) {
		inAccStrategyTrig = newValue;
	}
	
	public static Boolean inAccMBOTrig() {
		return inAccMBOTrig==true;
	}
	
	public static void setAccMBOTrig(Boolean newValue) {
		inAccMBOTrig = newValue;
	}
	
	public static Boolean inAccTestingInfoTrig() {
		return inAccTestingInfoTrig==true;
	}
	
	public static void setAccTestingInfoTrig(Boolean newValue) {
		inAccTestingInfoTrig = newValue;
	}
}