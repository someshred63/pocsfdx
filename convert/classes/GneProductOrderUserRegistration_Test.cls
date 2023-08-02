@IsTest(SeeAllData=true)
private class GneProductOrderUserRegistration_Test 
{
	
	@isTest static void testProvisionUser() 
	{
		string email='test' + String.valueOf(Math.round(Math.random()*10000)) + '@mailinator.com';
		Test.StartTest();
        
		GneProductOrderUserRegistration.provisionUser ('90335286', 'Tiffany', 'Smith', null, 
				email, '(215) 741-6728', true, 'Account Manager');
        
        Test.StopTest();

        system.assertEquals(1, [SELECT COUNT() FROM User WHERE Email=:email]);
	}
		
}