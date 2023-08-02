/*------------      Name of class : GNE_CM_case_trigger_monitor                 --------------*/
/*------------                                                                  --------------*/
/*------------      This code stores variables indicating whether the           --------------*/
/*------------      GNE_CM_Affiliation Trigger is running                       --------------*/
/*------------      due to the vod trigger or due to data manipulations         --------------*/
/*------------      by the Trigger.  The Trigger checks this Class to           --------------*/
/*------------      prevent infinite-loop recursion.                            --------------*/
/*------------                                                                  --------------*/
/*------------      Created by: GDC                                             --------------*/
/*------------      Last Modified: 03/03/2009                                   --------------*/

public class GNE_CM_case_trigger_monitor {
    
    // Delare variable and initialize it to false
    private static boolean inProcess = false;
    
    private static boolean inProcessTrig1 = false;
    private static boolean inProcessTrig2 = false;
    private static boolean inProcessTrig3 = false;
    private static boolean inProcessTrig4 = false;
    private static boolean inProcessTrig5 = false;
    private static boolean inProcessTrig6 = false;
    private static boolean inProcessTrigCaseUpdate = false;
    // This function is called by the Trigger to see if an instance of the Trigger is already in process
    public static boolean triggerIsInProcess() {
        return inProcess;
    }
    
    public static boolean triggerIsInProcessTrig1() {
        return inProcessTrig1;
    }
    
    public static boolean triggerIsInProcessTrig2() {
        return inProcessTrig2;
    }
    
    public static boolean triggerIsInProcessTrig3() {
        return inProcessTrig3;
    }
    
    public static boolean triggerIsInProcessTrig4() {
        return inProcessTrig4;
    }
    
    public static boolean triggerIsInProcessTrig5() {
        return inProcessTrig5;
    }
    
    public static boolean triggerIsInProcessTrig6() {
        return inProcessTrig6;
    }
    public static boolean triggerIsInProcessCaseUpdate() {
        return inProcessTrigCaseUpdate;
    }
    
    // This function is called by the Trigger after all the in-memory processing and before the DML execution to inform the Class
    // that it is already in process.
    public static void setTriggerInProcess() {
        inProcess = true;
    }
    
    public static void setTriggerInProcessTrig1() {
        inProcessTrig1 = true;
    }
    
    public static void setTriggerInProcessTrig2() {
        inProcessTrig2 = true;
    }
    
    public static void setTriggerInProcessTrig3() {
        inProcessTrig3 = true;
    }
    
    public static void setTriggerInProcessTrig4() {
        inProcessTrig4 = true;
    }
    
    public static void setTriggerInProcessTrig5() {
        inProcessTrig5 = true;
    }
    
    public static void setTriggerInProcessTrig6() {
        inProcessTrig6 = true;
    }
    public static void setTriggerInProcessCaseUpdate() {
        inProcessTrigCaseUpdate = true;
    }
    // This function is called by the Unit Test to simulate completion of a DML statement.  
    // This functionis NOT intended for any other purpose
    
    public static void resetTriggerInProcess() {
        inProcess = false;
    }
    
    public static void resetTriggerInProcessTrig1() {
        inProcessTrig1 = false;
    }
    
    public static void resetTriggerInProcessTrig2() {
        inProcessTrig2 = false;
    }
    
    public static void resetTriggerInProcessTrig3() {
        inProcessTrig3 = false;
    }
    
    public static void resetTriggerInProcessTrig4() {
        inProcessTrig4 = false;
    }
    
    public static void resetTriggerInProcessTrig5() {
        inProcessTrig5 = false;
    }
    
    public static void resetTriggerInProcessTrig6() {
        inProcessTrig6 = false;
    }
    public static void resetTriggerInProcessCaseUpdate() {
        inProcessTrigCaseUpdate = false;
    }
}