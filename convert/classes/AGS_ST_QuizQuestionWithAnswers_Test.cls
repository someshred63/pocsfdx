/** @date 5/6/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Quiz Question With Answers Class
*/
@isTest
private class AGS_ST_QuizQuestionWithAnswers_Test {
	
	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for creating class
	*/
	@isTest static void shouldCreateClass() {
		// GIVEN
		// WHEN
		AGS_ST_QuizQuestionWithAnswers ctrl = new AGS_ST_QuizQuestionWithAnswers();

		// THEN
		System.assertNotEquals( null, ctrl );
	}
}