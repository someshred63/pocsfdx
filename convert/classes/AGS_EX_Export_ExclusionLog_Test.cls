@isTest
private class AGS_EX_Export_ExclusionLog_Test{

	public static testMethod void testGeneratedView(){

		ApexPages.currentPage().getparameters().put('viewId','');
		ApexPages.currentPage().getparameters().put('columns',
			'Created By Alias,Created By,Last Modified By Alias,Last Modified By,Exclusion Request,Reviewed By,Attachment,NPI ID');

		AGS_EX_Export_ExclusionLog ctrl = new AGS_EX_Export_ExclusionLog();

		System.assert(ctrl.fieldAPINames.contains('CreatedBy.Alias'));
	}
}