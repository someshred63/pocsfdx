@isTest
private class EDM_Multiselect_Controller_Test {
	static testMethod void testMultiselectController() {
		EDM_Multiselect_Controller c = new EDM_Multiselect_Controller();
		c.leftOptions = new List<SelectOption>();
		c.rightOptions = new List<SelectOption>();
		c.leftOptionsHidden = 'A&a&b&b&C&c';
		c.rightOptionsHidden = '';
		System.assertEquals(c.leftOptions.size(), 3);
		System.assertEquals(c.rightOptions.size(), 0);
	}
}