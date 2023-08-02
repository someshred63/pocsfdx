public class GNE_SFA2_TierLvlAssignmentTrigger_Helper {
    private static Boolean inTierLevelTrig;
   
    public static Boolean inTierLevelTrig() {
        return inTierLevelTrig == true;
    }
    
    public static void setInTierLevelTrig(Boolean newValue) {
        inTierLevelTrig = newValue;
    }
    
}