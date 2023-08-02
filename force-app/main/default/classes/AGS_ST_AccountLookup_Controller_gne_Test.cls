/** @date 4/28/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Account Lookup Controller
*/
@isTest
private class AGS_ST_AccountLookup_Controller_gne_Test {
	
	/** @date 4/28/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updateFilter() method
	*/
	@isTest static void shouldUpdateFilter() {
		// GIVEN
		Account personAccount = AGS_ST_TestUtils.createPersonAccount();

		System.currentPageReference().getParameters().put('lknm', 'lknm');
		AGS_ST_AccountLookup_Controller_gne ctrl = new AGS_ST_AccountLookup_Controller_gne();
		ctrl.firstName 	= personAccount.FirstName;
		ctrl.lastName 	= personAccount.LastName;
		ctrl.mdmId 		= personAccount.MDMID_gne__c;
		ctrl.npi 		= personAccount.NPI_vod__c;

		// WHEN
		ctrl.updateFilter();

		// THEN
		System.assertEquals( 1, ctrl.getFinalAccountList().size() );
	}
}