@isTest
public class CORE_Pub_Sub_Admin_Console_Ctrl_Test {
	
	private static testMethod void adminConsoleCtrlInitTest() {
        
        Test.startTest();
        CORE_Pub_Sub_Admin_Console_Controller ctrl = new CORE_Pub_Sub_Admin_Console_Controller();
        Test.stopTest();
        
        System.assertEquals(0, ctrl.completedAutoSubJobs.size());
        System.assertNotEquals(0, ctrl.sectionsContent.size());

    }

    private static testMethod void getAutoSubJobInProgressTest() {

    	Test.startTest();
        String autoSubJob = CORE_Pub_Sub_Admin_Console_Controller.getAutoSubJobInProgress();
        Test.stopTest();

        System.assertEquals(null, autoSubJob);

    }

}