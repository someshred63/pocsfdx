public class GNE_SFA2_MCCO_AM_Profile_Schedule implements Schedulable{
   public void execute(SchedulableContext SC) {    
      GNE_SFA2_MCCO_AM_Profile_Utility mccoAMCheck = new GNE_SFA2_MCCO_AM_Profile_Utility();
      mccoAMCheck.checkMCCOUserDiscrepancy();
      mccoAMCheck.createExcelFromUserData();
      mccoAMCheck.emailUserData();
   }
}