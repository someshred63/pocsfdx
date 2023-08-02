/** @date 2/24/2014
* @Author Konrad Malinowski
* @description Test Class with methods for Header Controller
*/
@isTest
private class VDST_HeaderController_Test {
	/** @date 2/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - testing sendEmail() method
    */
    @IsTest
    static void shouldSendEmail_Test() {
        Test.startTest();
        // GIVEN
        Integer emailBefore = Limits.getEmailInvocations();
        VDST_HeaderController headerController = new VDST_HeaderController();
        // WHEN
        headerController.sendEmail();
        // THEN
        System.assertNotEquals( emailBefore, Limits.getEmailInvocations() );
        Test.stopTest();
    }
}