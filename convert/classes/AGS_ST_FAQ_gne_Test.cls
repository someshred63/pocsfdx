/** @date 5/5/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track FAQ Controller
*/
@isTest
private class AGS_ST_FAQ_gne_Test {
	
	/** @date 5/5/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for faqs getter
    */
	@isTest static void shouldGetFaqs() {
		// GIVEN
		AGS_ST_TestUtils.createFaq();
		AGS_ST_FAQ_gne ctrl = new AGS_ST_FAQ_gne();

		// WHEN
		String faqsText = ctrl.faqs;

		// THEN
		List<AGS_ST_FAQ_DYK_gne__c> faqs = (List<AGS_ST_FAQ_DYK_gne__c>)JSON.deserialize(
			faqsText, List<AGS_ST_FAQ_DYK_gne__c>.class
		);
		System.assertEquals( 1, faqs.size() );
	}
}