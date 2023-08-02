@isTest
public with sharing class GNE_CAN_Subscribe_ConsoleCtrTest 
{	
	public static testMethod void testSubscribeHCO() 
	{
		prepareEnv();
		System.debug('Fireing Subscribe HCOs job.');
		GNE_CAN_Subscribe_ConsoleCtr ctr = new GNE_CAN_Subscribe_ConsoleCtr();
		ctr.subscribeHcoAction();
		 
		System.debug('Checking if Subscribe job has been fired.');
		Boolean isRunning = ctr.isSubscribeHcoRunning;
		System.assert(isRunning, 'Job GNE_CAN_Subscribe_Batch_OrgAccount has not been fired!');		 		
	}

	public static testMethod void testSubscribeHCP() 
	{
		prepareEnv();
		System.debug('Fireing Subscribe HCPs job.');
		GNE_CAN_Subscribe_ConsoleCtr ctr = new GNE_CAN_Subscribe_ConsoleCtr();
		ctr.subscribeHcpAction();
		 
		System.debug('Checking if Subscribe job has been fired.');
		Boolean isRunning = ctr.isSubscribeHcpRunning;
		System.assert(isRunning, 'Job GNE_CAN_Subscribe_Batch_PersonAccount has not been fired!');		 					
	}
	
	private static void prepareEnv() {
		GNE_CAN_Subscribe_Test.setUpProps('true', 'true');
		GNE_CAN_Subscribe_Test.createStagingFieldMapList();
	}
}