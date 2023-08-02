/** @date 5/13/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track User Validator Class
*/
@isTest
private class AGS_ST_UserValidator_Test {
	
	/** @date 5/13/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for validate() method
    */
	@isTest static void shouldValidateUser() {
		// GIVEN
		AGS_ST_User agsUser = new AGS_ST_User();

		AGS_ST_UserValidator userValidator = new AGS_ST_UserValidator(agsUser);

		String firstName	= 'Adam';
		String lastName		= 'Test';
		String email 		= 'test@gmail.com';
		String email2 		= 'test@gmail.com';
		String npi 			= '1234567';
		String street 		= 'Street';
		String suite 		= 'Suite';
		String city 		= 'Los Angeles';
		String state 		= 'CA';
		String zip 			= '12345';

		// WHEN
		String msgFirstNameLastNameBlank = userValidator.validate();

		agsUser.lastName = lastName;
		String msgFirstNameBlank = userValidator.validate();

		agsUser.firstName = firstName;
		agsUser.lastName = null;
		String msgLastNameBlank = userValidator.validate();

		agsUser.firstName = firstName + '1';
		agsUser.lastName = lastName;
		String msgFirstNameIsNotAlpha = userValidator.validate();

		agsUser.firstName = firstName;
		agsUser.lastName = lastName + '1';
		String msgLastNameIsNotAlpha = userValidator.validate();

		agsUser.lastName = lastName;
		String msgEmailAndEmail2Blank = userValidator.validate();

		agsUser.email2 = email2;
		String msgEmailBlank = userValidator.validate();

		agsUser.email = email;
		String msgNpiBlank = userValidator.validate();

		agsUser.npi = npi + 'a';
		String msgNpiFormatInvalid = userValidator.validate();

		agsUser.npi = npi;
		String msgStreetAndSuiteBlank = userValidator.validate();

		agsUser.suite = suite;
		String msgStreetBlank = userValidator.validate();

		agsUser.street = street;
		String msgCityAndStateAndZipBlank = userValidator.validate();

		agsUser.zip = zip;
		String msgCityAndStateBlank = userValidator.validate();

		agsUser.zip = null;
		agsUser.state = state;
		String msgCityAndZipBlank = userValidator.validate();

		agsUser.state = null;
		agsUser.city = city;
		String msgStateAndZipBlank = userValidator.validate();

		agsUser.zip = zip;
		agsUser.state = state;
		agsUser.city = null;
		String msgCityBlank = userValidator.validate();

		agsUser.state = null;
		agsUser.city = city;
		String msgStateBlank = userValidator.validate();

		agsUser.zip = null;
		agsUser.state = state;
		String msgZipBlank = userValidator.validate();

		agsUser.zip = zip;
		agsUser.city = city + '1';
		String msgCityIsNotAlpha = userValidator.validate();

		agsUser.city = city;
		agsUser.state = state + '1';
		String msgStateIsNotAlpha = userValidator.validate();

		agsUser.state = state;
		agsUser.zip = zip + 'a';
		String msgZipIsNotANumber = userValidator.validate();

		agsUser.zip = zip;
		String msgOk = userValidator.validate();

		// THEN
		System.assertEquals( '"Your First Name" and "Your Last Name" must be filled!', msgFirstNameLastNameBlank );
		System.assertEquals( '"Your First Name" must be filled!', msgFirstNameBlank );
		System.assertEquals( '"Your Last Name" must be filled!', msgLastNameBlank );
		System.assertEquals( '"Your First Name" can only contain letters!', msgFirstNameIsNotAlpha );
		System.assertEquals( '"Your Last Name" can only contain letters!', msgLastNameIsNotAlpha );
		System.assertEquals( '"Your Email Address" and "Re-enter Email Address" must be filled!', msgEmailAndEmail2Blank );
		System.assertEquals( '"Your Email Address" must be filled!', msgEmailBlank );
		System.assertEquals( 'Please enter either NPI ID or state LIC and state code!', msgNpiBlank );
		System.assertEquals( '"NPI#" can only contain digits!', msgNpiFormatInvalid );
		System.assertEquals( '"Street address" must be filled!', msgStreetAndSuiteBlank );
		System.assertEquals( '"Street address" must be filled!', msgStreetBlank );
		System.assertEquals( '"City", "State Code" and "Zip" must be filled!', msgCityAndStateAndZipBlank );
		System.assertEquals( '"City" and "State Code" must be filled!', msgCityAndStateBlank );
		System.assertEquals( '"City" and "Zip" must be filled!', msgCityAndZipBlank );
		System.assertEquals( '"Zip" and "State Code" must be filled!', msgStateAndZipBlank );
		System.assertEquals( '"City" must be filled!', msgCityBlank );
		System.assertEquals( '"State Code" must be filled!', msgStateBlank );
		System.assertEquals( '"Zip" must be filled!', msgZipBlank );
		System.assertEquals( '"City" can only contain letters!', msgCityIsNotAlpha );
		System.assertEquals( '"State" can only contain letters!', msgStateIsNotAlpha );
		System.assertEquals( '"Zip" can only contain digits!', msgZipIsNotANumber );
		System.assertEquals( null, msgOk );
	}
}