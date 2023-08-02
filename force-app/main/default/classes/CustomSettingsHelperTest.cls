/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2010-01-11
*  Description: 
*  
*  Modification History
*  Date        Name        Description
*                
*************************************************************/
@isTest
private class CustomSettingsHelperTest 
{

    static testmethod void testCustomSetting() 
    {
		System.assertEquals(CustomSettingsHelper.PRES_LKP_ACCOUNTCASEID, CustomSettingsHelper.self().getPresLkpIds().get(CustomSettingsHelper.PRES_LKP_ACCOUNTCASEID).Name);
		System.assertEquals(CustomSettingsHelper.BATCH_FAX_EMAIL_RECIPIENT, CustomSettingsHelper.batchFaxSelf().getEmailRecipient().get(CustomSettingsHelper.BATCH_FAX_EMAIL_RECIPIENT).Name);
		System.assertEquals(CustomSettingsHelper.CM_TERRITORY_ALIGNMENT_RUN, CustomSettingsHelper.CMAlignmentSelf().getCurrentRun().get(CustomSettingsHelper.CM_TERRITORY_ALIGNMENT_RUN).Name);
		System.assertEquals(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG, CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Name);
	}
}