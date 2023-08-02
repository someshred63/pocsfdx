public class GNE_CM_MPS_Test_Helper
{
	private static final String DEFAULT_ADDRESS = 'Top Secret Location';
	private static final String DEFAULT_CITY = 'San Francisco';
	private static final String DEFAULT_EMAIL = 'mpsRegistrationTest@mailinator.com';
	private static final String DEFAULT_FAX = '(000) 000-0001';
	private static final String DEFAULT_PHONE = '(000) 000-0000';
	private static final String DEFAULT_PROFILE = 'GNE-CM-Physician Profile';
	private static final String DEFAULT_ROLE = 'Medical Doctor';
	private static final String DEFAULT_STATE = 'CA';
	private static final String DEFAULT_SUITE = '#001';
	private static final String DEFAULT_ZIP = '94122';
	private static final Set<String> LICENSE_TYPES = new Set<String>{'State License', 'NPI #', 'PTAN', 'Tax ID', 'DEA #'};
	
	private static final Map<String,Map<String,Object>> defaults = new Map<String,Map<String,Object>>{
		'Address_vod__c' => new Map<String,Object>{
			'Name' => 'mpsTestAddress',
			'Address_Type_gne__c' => 'Clinic',
			'Address_1_gne__c' => DEFAULT_ADDRESS,
			'Address_line_2_vod__c' => DEFAULT_SUITE,
			'City_vod__c' => DEFAULT_CITY,
			'State_vod__c' => DEFAULT_STATE,
			'Zip_vod__c' => DEFAULT_ZIP,
			'Country_gen__c' => 'UNITED STATES',
			'Country_vod__c' => 'us',
			'Account_vod__c' => null,
			'Clinic_gne__c' => true,
			'Primary_vod__c' => true
		},
		'GNE_CM_MPS_Location__c' => new Map<String,Object>{
			'GNE_CM_MPS_Registration__c' => null,
			'Office_Location_Address__c' => DEFAULT_ADDRESS,
			'Suite__c' => DEFAULT_SUITE,
			'City__c' => DEFAULT_CITY,
			'State__c' => DEFAULT_STATE,
			'Zip__c' => DEFAULT_ZIP,
			'Disabled__c' => false,
			'Intake_Status__c' => 'Processed'
		},
		'GNE_CM_MPS_Practice_Agreement__c' => new Map<String,Object>{
			'Account__c' => null,
			'MPS_Registration__c' => null,
			'MPS_User__c' => null,
			'MPS_Prescriber__c' => null,
			'Is_User__c' => true,
			'Is_Prescriber__c' => false
		},
		'GNE_CM_MPS_Practice_Agreement_Location__c' => new Map<String,Object>{
			'Account__c' => null,
			'Address__c' => null,
			'MPS_Location__c' => null,
			'MPS_Practice_Agreement__c' => null,
			'MPS_Registration__c' => null
		},
		'GNE_CM_MPS_Prescriber__c' => new Map<String,Object>{
			'First_Name__c' => 'Harrison',
			'Last_Name__c' => 'Jones',
			'GNE_CM_MPS_Registration__c' => null,
			'Mapped_to_PA__c' => false,
			'Disabled__c' => false,
			'Intake_Status__c' => 'Processed',
			'State_License__c' => 'N/A',
			'Prescriber_Type__c' => DEFAULT_ROLE
			
		},
		'GNE_CM_MPS_Registration__c' => new Map<String,Object>{
			'Authorized_Representative_First_Name__c' => 'Harrison',
			'Authorized_Representative_Last_Name__c' => 'Jones',
			'Authorized_Representative_Email__c' => 'harrisonjones@mailinator.com',
			'Authorized_Representative_Phone__c' => DEFAULT_PHONE,
			'Authorized_Representative_Phone_Ext__c' => null,
			'Role_in_Practice__c' => DEFAULT_ROLE,
			'Practice_Name__c' => 'Hollywood Staff',
			'Address__c' => DEFAULT_ADDRESS,
			'Address_Suite__c' => DEFAULT_SUITE,
			'City__c' => DEFAULT_CITY,
			'State__c' => DEFAULT_STATE,
			'Zip_Code__c' => DEFAULT_ZIP,
			'Phone__c' => DEFAULT_PHONE,
			'Phone_Extension__c' => null,
			'Fax__c' => DEFAULT_FAX,
			'Practice_Product__c' => getPracticeProductString(),
			'Registration_Status__c' => 'Approved',
			'Is_Ebi_Functionality_Enabled_gne__c' => false
		},
		'GNE_CM_MPS_User__c' => new Map<String,Object>{
			'GNE_CM_MPS_Registration__c' => null,
			'SFDC_User__c' => null,
			'First_name__c' => 'Harrison',
			'Last_name__c' => 'Jones',
			'Email_Address__c' => 'harrisonjones@mailinator.com',
			'Phone_number__c' => DEFAULT_PHONE,
			'Phone_number_ext__c' => null,
			'Role_in_Practise__c' => DEFAULT_ROLE,
			'Workflow_State__c' => 'ACTIVATED',
			'Intake_Status__c' => 'Processed',
			'User_Status__c' => 'Approved',
			'Disabled__c' => false,
			'Admin__c' => true
		},
		'GNE_CM_MPS_User_Preferences__c' => new Map<String,Object>{
			'Email_Settings__c' => String.join(Alerts_gne__c.Type_gne__c.getDescribe().getpicklistValues(), ';'),
			'Location_Settings__c' => null,
			'MPS_User__c' => null
		}
	};
	
	public class FullMpsRegistration
	{
		public GNE_CM_MPS_Registration__c registration {get; private set;}
		public List<GNE_CM_MPS_User__c> users {get; private set;}
		public List<GNE_CM_MPS_Location__c> locations {get; private set;}
		public List<GNE_CM_MPS_Prescriber__c> prescribers {get; private set;}
        public List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreements {get; private set;}
        public List<GNE_CM_MPS_Practice_Agreement_Location__c> practiceAgreementLocations {get; private set;}
        
        public FullMpsRegistration(Account sfdcAccount, User sfdcUser, User intakeUser, String testMailbox, Integer userCount, Integer prescriberCount, Integer locationCount)
        {
        	if(Test.isRunningTest()) {
        		
        		this.users = new List<GNE_CM_MPS_User__c>();
        		this.locations = new List<GNE_CM_MPS_Location__c>();
        		this.prescribers = new List<GNE_CM_MPS_Prescriber__c>();
        		this.practiceAgreements = new List<GNE_CM_MPS_Practice_Agreement__c>();
        		this.practiceAgreementLocations = new List<GNE_CM_MPS_Practice_Agreement_Location__c>();
        		
        		// create and insert MPS Registration
	        	this.registration = GNE_CM_MPS_Test_Helper.createRegistration();
	        	insert this.registration;        	
	        	GNE_CM_MPS_Test_Helper.shareRegistration(sfdcUser.Id, this.registration.Id);
	        	GNE_CM_MPS_Test_Helper.shareRegistration(intakeUser.Id, this.registration.Id);
	        	
	        	// create and insert a desired number of MPS Locations
	        	// MPS Locations need to be inserted before MPS Users in order for MPS User Preferences to be created with proper values
	        	// (this is done in a trigger on MPS User after insert)
	        	for (Integer lc = 0; lc < locationCount; lc++) {
	        		this.locations.add(GNE_CM_MPS_Test_Helper.createLocation(
	    				new Map<String,Object>{
	    					'@reg' => this.registration,
	    					'GNE_CM_MPS_Registration__c' => 'reg.Id',
	    					'Office_Location_Address__c' => 'reg.Address__c',
	    					'Suite__c' => 'reg.Address_Suite__c',
	    					'City__c' => 'reg.City__c',
	    					'State__c' => 'reg.State__c',
	    					'Zip__c' => 'reg.Zip_Code__c'
	    				}
	    			));
	        	}
	        	insert this.locations;
	        	GNE_CM_MPS_Test_Helper.shareLocations(sfdcUser.Id, this.locations);
	        	GNE_CM_MPS_Test_Helper.shareLocations(intakeUSer.Id, this.locations);
	        	
	        	// update email on contact
	        	GNE_CM_IHCP_Utils.updateUserContactEmailsFuture(new Map<String,String>{sfdcUser.Id => testMailbox});
	        	
	        	// create and insert a desired number of MPS Users
	        	Boolean adminCreated = false;
	        	for (Integer uc = 0; uc < userCount; uc++) {
	        		this.users.add(GNE_CM_MPS_Test_Helper.createUser(
	        			new Map<String,Object>{
	        				'GNE_CM_MPS_Registration__c' => this.registration.Id,
	        				'First_name__c' => 'Test #' + (uc + 1),
	        				'Last_name__c' => 'Mps User',
	        				'Admin__c' => adminCreated ? false : true,
	        				'SFDC_User__c' => adminCreated ? null : sfdcUser.Id
	        			}
	        		));
	        		adminCreated = true;
	        	}
	        	insert this.users;
	        	Id mainUserId = this.users.get(0).Id; // mark main MPS User
	        	GNE_CM_MPS_Test_Helper.shareUsers(sfdcUser.Id, this.users);
	        	GNE_CM_MPS_Test_Helper.shareUsers(intakeUser.Id, this.users);
	        	
	        	// create and insert Accounts for all MPS Users
	        	Map<Id,Account> userIdsToAccounts = new Map<Id,Account>();
	        	for (GNE_CM_MPS_User__c u : this.users) {
	        		if (u.Id == mainUserId) {
	        			continue;
	        		}
	        		userIdsToAccounts.put(u.Id, GNE_CM_MPS_Test_Helper.createSfdcAccount(
	        			new Map<String,Object>{'FirstName' => u.First_Name__c, 'LastName' => u.Last_Name__c, 'Email_Address__c' => testMailbox})
	        		);
	        	}
	        	insert userIdsToAccounts.values();
	        	userIdsToAccounts.put(mainUserId, sfdcAccount); // map main MPS User Id to sfdcAccount
	        	GNE_CM_MPS_Test_Helper.shareAccounts(sfdcUser.Id, userIdsToAccounts.values());
	        	GNE_CM_MPS_Test_Helper.shareAccounts(intakeUser.Id, userIdsToAccounts.values());
	        	
	        	// define AccountIds to Addresses map
	        	Map<Id,Address_vod__c> accountIdsToAddresses = new Map<Id,Address_vod__c>();
	        	
	        	//create and insert Addresses for Accounts
	        	Id aRtId = Schema.SObjectType.Address_vod__c.getRecordTypeInfosByName().get('Company Maintained').getRecordTypeId();
	        	for (Account a : userIdsToAccounts.values()) {
	        		accountIdsToAddresses.put(a.Id, GNE_CM_MPS_Test_Helper.createAddress(new Map<String,Object>{'Account_vod__c' => a.Id, 'RecordTypeId' => aRtId}));
	        	}
	        	insert accountIdsToAddresses.values();
	        	
	        	// create and insert a desired number of MPS Prescribers
	        	for (Integer pc = 0; pc < prescriberCount; pc++) {
	        		this.prescribers.add(GNE_CM_MPS_Test_Helper.createPrescriber(
	    				new Map<String,Object>{
	    					'GNE_CM_MPS_Registration__c' => this.registration.Id,
	    					'First_Name__c' => 'Test #' + (pc + 1),
	    					'Last_Name__c' => 'Mps User'
	    				}
	    			));
	        	}
	        	insert this.prescribers;
	        	GNE_CM_MPS_Test_Helper.sharePrescribers(sfdcUser.Id, this.prescribers);
	        	GNE_CM_MPS_Test_Helper.sharePrescribers(intakeUser.Id, this.prescribers);
	        	
	        	
	        	
	        	// create and insert Practice Agreements
	        	for (GNE_CM_MPS_User__c u : this.users) {
	        		Id prescriberId = null;
	        		for (GNE_CM_MPS_Prescriber__c p : this.prescribers) {
	        			if (p.First_Name__c == u.First_name__c && p.Last_Name__c == u.Last_name__c) {
	        				prescriberId = p.Id;
	        				break;
	        			}
	        		}
	        		this.practiceAgreements.add(GNE_CM_MPS_Test_Helper.createPracticeAgreement(new Map<String,Object>{
	        			'Account__c' => userIdsToAccounts.get(u.Id).Id,
	        			'MPS_Registration__c' => this.registration.Id,
	        			'MPS_User__c' => u.Id,
	        			'Is_User__c' => true,
	        			'Is_Prescriber__c' => prescriberId == null ? false : true ,
	        			'MPS_Prescriber__c' => prescriberId
	        		}, false));
	        	}
	        	insert this.practiceAgreements;
	        	GNE_CM_MPS_Test_Helper.sharePracticeAgreements(sfdcUser.Id, this.practiceAgreements);
	        	GNE_CM_MPS_Test_Helper.sharePracticeAgreements(intakeUser.Id, this.practiceAgreements);
	        	
	        	// create and insert Practice Agreement Locations
	        	for (GNE_CM_MPS_Practice_Agreement__c pa : this.practiceAgreements) {
	        		for (Integer lc = 0; lc < this.locations.size(); lc++) {
	        			this.practiceAgreementLocations.add(GNE_CM_MPS_Test_Helper.createPracticeAgreementLocation(new Map<String,Object>{
	        				'Account__c' => pa.Account__c,
	        				'Address__c' => accountIdsToAddresses.get(pa.Account__c).Id,
	        				'MPS_Location__c' => this.locations.get(lc).Id,
	        				'MPS_Practice_Agreement__c' => pa.Id,
	        				'MPS_Registration__c' => this.registration.Id 				
	        			}, false));
	        		}
	        	}
	        	insert this.practiceAgreementLocations;
	        	GNE_CM_MPS_Test_Helper.sharePracticeAgreementLocations(sfdcUser.Id, this.practiceAgreementLocations);
	        	GNE_CM_MPS_Test_Helper.sharePracticeAgreementLocations(intakeUser.Id, this.practiceAgreementLocations);
	        	
	        	// create and insert Proxy Managements
	        	List<GNE_CM_MPS_Proxy_Management__c> proxies = new List<GNE_CM_MPS_Proxy_Management__c>();
	        	for (GNE_CM_MPS_Prescriber__c p : this.prescribers) {
	        		proxies.add(GNE_CM_MPS_Test_Helper.createProxyManagement(p.Id, sfdcAccount.Id));
	        	}
	        	insert proxies;
	        	GNE_CM_MPS_Test_Helper.shareProxies(sfdcUser.Id, proxies);
	        	GNE_CM_MPS_Test_Helper.shareProxies(intakeUser.Id, proxies);
	        	
	        	// create and insert License Informations
	        	List<ProfileID_License_gne__c> licenseInfos = new List<ProfileID_License_gne__c>();
	        	for (Account a : userIdsToAccounts.values()) {
	        		Integer lCounter = 0;
	        		for (String lt : GNE_CM_MPS_Test_Helper.LICENSE_TYPES) {
	        			licenseInfos.add(GNE_CM_MPS_Test_Helper.createLicenseInfo(
	        				a.Id, accountIdsToAddresses.get(a.Id).Id, lt, (lt == 'DEA #') ? 'AP5836727' : '123456-' + (lCounter + 1)
	        			));
	        		}
	        	}
	        	insert licenseInfos;
        	}
        }
	}
			
	public static Address_vod__c createAddress(Map<String,Object> values, Boolean useDefaults)
	{
		if (useDefaults) {
			ObjectFactory.setDefaults('Address_vod__c', defaults.get('Address_vod__c'));
		}
		return (Address_vod__c)ObjectFactory.make('Address_vod__c', values, useDefaults);
	}
	
	public static Address_vod__c createAddress(Map<String,Object> values)
	{
		return createAddress(values, true);
	}
	
	public static Address_vod__c createAddress()
	{
		return createAddress(null, true);
	}
	
	public static FullMpsRegistration createFullMpsRegistration(Account sfdcAccount, User sfdcUser, User intakeUser, String testMailbox, Integer userCount, Integer prescriberCount, Integer locationCount)
	{
		if (!Test.isRunningTest()) {
			return null;
		}
		if (intakeUser == null) {
			intakeUser = createIntakeUser('fakeMpsIntake', new Map<String,Object>{'FirstName' => 'Christian', 'LastName' => 'Wayne'});
			insert intakeUser;
		}
		if (testMailbox == null || testMailbox == '') {
			testMailbox = DEFAULT_EMAIL;
		}		
		return new FullMpsRegistration(sfdcAccount, sfdcUser, intakeUser, testMailbox, userCount, prescriberCount, locationCount);
	}
	
	public static FullMpsRegistration createFullMpsRegistration(Account sfdcAccount, User sfdcUser, User intakeUser, String testMailbox)
	{
		return createFullMpsRegistration(sfdcAccount, sfdcUser, intakeUser, testMailbox, 1, 1, 1);
	}
	
	public static FullMpsRegistration createFullMpsRegistration(Account sfdcAccount, User sfdcUser, User intakeUser)
	{
		return createFullMpsRegistration(sfdcAccount, sfdcUser, intakeUser, null, 1, 1, 1);
	}
	
	public static FullMpsRegistration createFullMpsRegistration(Account sfdcAccount, User sfdcUser)
	{
		return createFullMpsRegistration(sfdcAccount, sfdcUser, null, null, 1, 1, 1);
	}
	
	public static User createIntakeUser(String userName, Map<String,Object> values)
	{
		Profile prof = [SELECT Id FROM Profile WHERE Name = 'GNE-CM-INTAKE'];
		GNE_CM_MPS_Custom_Setting__c csr = [SELECT Environment_Name__c FROM GNE_CM_MPS_Custom_Setting__c];
		String env = csr.Environment_Name__c;
		String ext = '';		
		if (env.toLowerCase() != 'prod') {
			ext = '.' + env;
		}
		Map<String,Object> inits = new Map<String,Object>{
			'UserName' => userName + '@gene.com' + ext,
			'FirstName' => 'Test',
			'LastName' => 'Mps Intake',
			'Alias' => userName.substring(0,8),
			'Email' => userName + '_test@gene.com',
			'LanguageLocaleKey' => 'en_US',
			'LocaleSidKey' => 'en_US',
			'EmailEncodingKey' => 'UTF-8',
			'TimeZoneSidKey' => 'America/Los_Angeles',
			'External_ID_gne__c' => userName + '@gene.com' + ext,
			'IsActive' => true,
			'OverrideSpringCMUserFlag__c' => false
		};
		if (values != null && !values.isEmpty()) {
			for (String fName : values.keySet()) {
				inits.put(fName, values.get(fName));
			}
		}
		User intake = new User(ProfileId = prof.Id);
		ObjectFactory.assignFields(intake, inits);
		return intake;
	}
	
	public static User createIntakeUser(String userName)
	{
		return createIntakeUser(userName, null);
	}
	
	public static ProfileID_License_gne__c createLicenseInfo(Id accountId, Id addressId, String licenseType, String licenseNo)
	{
		return new ProfileID_License_gne__c(
			Account_Name_gne__c = accountId,
			Address_gne__c = addressId,
			ID_License_Type_gne__c = licenseType,
			ID_License_gne__c = licenseNo,
			State_gne__c = DEFAULT_STATE
		);
	}
	
	public static GNE_CM_MPS_Location__c createLocation(Map<String,Object> values, Boolean useDefaults)
	{
		if (useDefaults) {
			ObjectFactory.setDefaults('GNE_CM_MPS_Location__c', defaults.get('GNE_CM_MPS_Location__c'));
		}
		return (GNE_CM_MPS_Location__c)ObjectFactory.make('GNE_CM_MPS_Location__c', values, useDefaults);
	}
	
	public static GNE_CM_MPS_Location__c createLocation(Map<String,Object> values)
	{
		return createLocation(values, true);
	}
	
	public static GNE_CM_MPS_Location__c createLocation()
	{
		return createLocation(null, true);
	}
	
	public static GNE_CM_MPS_Practice_Agreement__c createPracticeAgreement(Map<String,Object> values, Boolean useDefaults)
	{
		if (useDefaults) {
			ObjectFactory.setDefaults('GNE_CM_MPS_Practice_Agreement__c', defaults.get('GNE_CM_MPS_Practice_Agreement__c'));
		}
		return (GNE_CM_MPS_Practice_Agreement__c)ObjectFactory.make('GNE_CM_MPS_Practice_Agreement__c', values, useDefaults);
	}
	
	public static GNE_CM_MPS_Practice_Agreement__c createPracticeAgreement(Map<String,Object> values)
	{
		return createPracticeAgreement(values, true);
	}
	
	public static GNE_CM_MPS_Practice_Agreement__c createPracticeAgreement()
	{
		return createPracticeAgreement(null, true);
	}
	
	public static GNE_CM_MPS_Practice_Agreement_Location__c createPracticeAgreementLocation(Map<String,Object> values, Boolean useDefaults)
	{
		if (useDefaults) {
			ObjectFactory.setDefaults('GNE_CM_MPS_Practice_Agreement_Location__c', defaults.get('GNE_CM_MPS_Practice_Agreement_Location__c'));
		}
		return (GNE_CM_MPS_Practice_Agreement_Location__c)ObjectFactory.make('GNE_CM_MPS_Practice_Agreement_Location__c', values, useDefaults);
	}
	
	public static GNE_CM_MPS_Practice_Agreement_Location__c createPracticeAgreementLocation(Map<String,Object> values)
	{
		return createPracticeAgreementLocation(values, true);
	}
	
	public static GNE_CM_MPS_Practice_Agreement_Location__c createPracticeAgreementLocation()
	{
		return createPracticeAgreementLocation(null, true);
	}
	
	public static GNE_CM_MPS_Prescriber__c createPrescriber(Map<String,Object> values, Boolean useDefaults)
	{
		if (useDefaults) {
			ObjectFactory.setDefaults('GNE_CM_MPS_Prescriber__c', defaults.get('GNE_CM_MPS_Prescriber__c'));
		}
		return (GNE_CM_MPS_Prescriber__c)ObjectFactory.make('GNE_CM_MPS_Prescriber__c', values, useDefaults);
	}
	
	public static GNE_CM_MPS_Prescriber__c createPrescriber(Map<String,Object> values)
	{
		return createPrescriber(values, true);
	}
	
	public static GNE_CM_MPS_Proxy_Management__c createProxyManagement(Id prescriberId, Id accountId)
	{
		return new GNE_CM_MPS_Proxy_Management__c(
			MPS_Prescriber__c = prescriberId, 
			User_Account__c = accountId,
			Is_Proxy_Enabled__c = true
		);
	}
	
	public static GNE_CM_MPS_Registration__c createRegistration(Map<String,Object> values, Boolean useDefaults)
	{
		if (useDefaults) {
			ObjectFactory.setDefaults('GNE_CM_MPS_Registration__c', defaults.get('GNE_CM_MPS_Registration__c'));
		}
		return (GNE_CM_MPS_Registration__c)ObjectFactory.make('GNE_CM_MPS_Registration__c', values, useDefaults);
	}
	
	public static GNE_CM_MPS_Registration__c createRegistration(Map<String,Object> values)
	{
		return createRegistration(values, true);
	}
	
	public static GNE_CM_MPS_Registration__c createRegistration()
	{
		return createRegistration(null, true);
	}
	
	public static Account createSfdcAccount(Map<String,Object> values)
	{
		RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Professional_vod' AND SObjectType = 'Account'];
		
		Map<String,Object> inits = new Map<String,Object>{
			'RecordTypeId' => rt.Id,
			'FirstName' => 'Harrison',
			'LastName' => 'Jones',
			'Professional_Type_gne__c' => DEFAULT_ROLE,
			'Credentials_gne__pc' => 'DO',
			'City__pc' => DEFAULT_CITY,
			'State_gne__pc' => DEFAULT_STATE,
			'Zip_4_gne__pc' => '0000',
			'Status_gne__c' => 'Active',
			'MDMID_Status_gne__c' => 'Active'
		};
		if (values != null && !values.isEmpty()) {
			for (String fName : values.keySet()) {
				inits.put(fName, values.get(fName));
			}
		}
		return (Account)ObjectFactory.make('Account', inits, false);
	}
	
	public static Account createSfdcAccount()
	{
		return createSfdcAccount(null);
	}
	
	public static User createSfdcUser(String userName, Account personAccount, Map<String,Object> values)
	{
		Profile prof = [SELECT Id FROM Profile WHERE Name = :DEFAULT_PROFILE limit 1];
		GNE_CM_MPS_Custom_Setting__c csr = [SELECT Environment_Name__c FROM GNE_CM_MPS_Custom_Setting__c];
		String env = csr.Environment_Name__c;
		String ext = '';		
		if (env.toLowerCase() != 'prod') {
			ext = '.' + env;
		}
		Map<String,Object> inits = new Map<String,Object>{
			'UserName' => userName + '@gene.com' + ext,
			'FirstName' => personAccount.FirstName,
			'LastName' => personAccount.LastName,
			'Alias' => userName.substring(0,8),
			'Email' => userName + '_test@gene.com',
			'ContactId' => personAccount.PersonContactId,
			'LanguageLocaleKey' => 'en_US',
			'LocaleSidKey' => 'en_US',
			'EmailEncodingKey' => 'UTF-8',
			'TimeZoneSidKey' => 'America/Los_Angeles',
			'External_ID_gne__c' => userName + '@gene.com' + ext,
			'IsActive' => true,
			'OverrideSpringCMUserFlag__c' => false
		};
		if (values != null && !values.isEmpty()) {
			for (String fName : values.keySet()) {
				inits.put(fName, values.get(fName));
			}
		}
		User sfdcUser = new User(ProfileId = prof.Id);
		ObjectFactory.assignFields(sfdcUser, inits);
		return sfdcUser;
	}
	
	public static User createSfdcUser(String userName, Account personAccount)
	{
		return createSfdcUser(userName, personAccount, null);
	}
	
	public static GNE_CM_MPS_User__c createUser(Map<String,Object> values, Boolean useDefaults)
	{
		if (useDefaults) {
			ObjectFactory.setDefaults('GNE_CM_MPS_User__c', defaults.get('GNE_CM_MPS_User__c'));
		}
		return (GNE_CM_MPS_User__c)ObjectFactory.make('GNE_CM_MPS_User__c', values, useDefaults);
	}
	
	public static GNE_CM_MPS_User__c createUser(Map<String,Object> values)
	{
		return createUser(values, true);
	}
	
	public static GNE_CM_MPS_User__c createUser()
	{
		return createUser(null, true);
	}
	
	public static GNE_CM_MPS_User_Preferences__c createUserPreferences(Map<String,Object> values, Boolean useDefaults)
	{
		if (useDefaults) {
			ObjectFactory.setDefaults('GNE_CM_MPS_User_Preferences__c', defaults.get('GNE_CM_MPS_User_Preferences__c'));
		}
		return (GNE_CM_MPS_User_Preferences__c)ObjectFactory.make('GNE_CM_MPS_User_Preferences__c', values, useDefaults);
	}
	
	public static GNE_CM_MPS_User_Preferences__c createUserPreferences(Map<String,Object> values)
	{
		return createUserPreferences(values, true);
	}
	
	public static GNE_CM_MPS_User_Preferences__c createUserPreferences()
	{
		return createUserPreferences(null, true);
	}
	
	public static List<String> getPracticeProductList()
	{
		List<String> practiceProductList = new List<String>();
		for (Schema.PicklistEntry ple : GNE_CM_MPS_Registration__c.Practice_Product__c.getDescribe().getPickListValues()) {
			practiceProductList.add(ple.getValue());
		}
		return practiceProductList;
	}
	
	public static String getPracticeProductString()
	{
		List<String> practiceProductList = GNE_CM_MPS_Test_Helper.getPracticeProductList();
		if (practiceProductList.isEmpty()) {
			return null;
		}
		String practiceProductString = '';
		for (String pp : practiceProductList) {
			practiceProductString += pp + ';';
		}
		return practiceProductString.removeEnd(';');
	}
	
	public static void shareAccount(Id ownerId, Id accountId)
	{
		shareAccounts(ownerId, new List<Id>{accountId});
	}
	
	public static void shareAccounts(Id ownerId, List<Account> accounts)
	{
		List<Id> accountIds = new List<Id>();
		for (Account a : accounts) {
			accountIds.add(a.Id);
		}
		shareAccounts(ownerId, accountIds);
	}
	
	public static void shareAccounts(Id ownerId, List<Id> accountIds)
	{
		if (ownerId != null && accountIds != null && !accountIds.isEmpty()) {
			List<AccountShare> shares = new List<AccountShare>();
			for (Id aId : accountIds) {
				shares.add(new AccountShare(
					AccountId = aId,
					UserOrGroupId = ownerId,
					AccountAccessLevel = 'Read',
					OpportunityAccessLevel = 'Read'
				));
			}
			insert shares;
		}
	}
	
	public static void shareLocation(Id ownerId, Id locationId)
	{
		shareLocations(ownerId, new List<Id>{locationId});
	}
	
	public static void shareLocations(Id ownerId, List<GNE_CM_MPS_Location__c> locations)
	{
		List<Id> locationIds = new List<Id>();
		for (GNE_CM_MPS_Location__c l : locations) {
			locationIds.add(l.Id);
		}
		shareLocations(ownerId, locationIds);
	}
	
	public static void shareLocations(Id ownerId, List<Id> locationIds)
	{
		if (ownerId != null && locationIds != null && !locationIds.isEmpty()) {
			List<GNE_CM_MPS_Location__Share> shares = new List<GNE_CM_MPS_Location__Share>();
			for (Id lId : locationIds) {
				shares.add(new GNE_CM_MPS_Location__Share(
					ParentId = lId,
					UserOrGroupId = ownerId,
					AccessLevel = 'Read'
				));
			}
			insert shares;
		}
	}
	
	public static void sharePracticeAgreement(Id ownerId, Id practiceAgreementId)
	{
		sharePracticeAgreements(ownerId, new List<Id>{practiceAgreementId});
	}
	
	public static void sharePracticeAgreements(Id ownerId, List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreements)
	{
		List<Id> practiceAgreementIds = new List<Id>();
		for (GNE_CM_MPS_Practice_Agreement__c pa : practiceAgreements) {
			practiceAgreementIds.add(pa.Id);
		}
		sharePracticeAgreements(ownerId, practiceAgreementIds);
	}
	
	public static void sharePracticeAgreements(Id ownerId, List<Id> practiceAgreementIds)
	{
		if (ownerId != null && practiceAgreementIds != null && !practiceAgreementIds.isEmpty()) {
			List<GNE_CM_MPS_Practice_Agreement__Share> shares = new List<GNE_CM_MPS_Practice_Agreement__Share>();
			for (Id paId : practiceAgreementIds) {
				shares.add(new GNE_CM_MPS_Practice_Agreement__Share(
					ParentId = paId,
					UserOrGroupId = ownerId,
					AccessLevel = 'Read'
				));
			}
			insert shares;
		}
	}
	
	public static void sharePracticeAgreementLocation(Id ownerId, Id practiceAgreementLocationId)
	{
		sharePracticeAgreementLocations(ownerId, new List<Id>{practiceAgreementLocationId});
	}
	
	public static void sharePracticeAgreementLocations(Id ownerId, List<GNE_CM_MPS_Practice_Agreement_Location__c> practiceAgreementLocations)
	{
		List<Id> practiceAgreementLocationIds = new List<Id>();
		for (GNE_CM_MPS_Practice_Agreement_Location__c pal : practiceAgreementLocations) {
			practiceAgreementLocationIds.add(pal.Id);
		}
		sharePracticeAgreementLocations(ownerId, practiceAgreementLocationIds);
	}
	
	public static void sharePracticeAgreementLocations(Id ownerId, List<Id> practiceAgreementLocationIds)
	{
		if (ownerId != null && practiceAgreementLocationIds != null && !practiceAgreementLocationIds.isEmpty()) {
			List<GNE_CM_MPS_Practice_Agreement_Location__Share> shares = new List<GNE_CM_MPS_Practice_Agreement_Location__Share>();
			for (Id palId : practiceAgreementLocationIds) {
				shares.add(new GNE_CM_MPS_Practice_Agreement_Location__Share(
					ParentId = palId,
					UserOrGroupId = ownerId,
					AccessLevel = 'Read'
				));
			}
			insert shares;
		}
	}
	
	public static void sharePrescriber(Id ownerId, Id prescriberId)
	{
		sharePrescribers(ownerId, new List<Id>{prescriberId});
	}
	
	public static void sharePrescribers(Id ownerId, List<GNE_CM_MPS_Prescriber__c> prescribers)
	{
		List<Id> prescriberIds = new List<Id>();
		for (GNE_CM_MPS_Prescriber__c p : prescribers) {
			prescriberIds.add(p.Id);
		}
		sharePrescribers(ownerId, prescriberIds);
	}
	
	public static void sharePrescribers(Id ownerId, List<Id> prescriberIds)
	{
		if (ownerId != null && prescriberIds != null && !prescriberIds.isEmpty()) {
			List<GNE_CM_MPS_Prescriber__Share> shares = new List<GNE_CM_MPS_Prescriber__Share>();
			for (Id pId : prescriberIds) {
				shares.add(new GNE_CM_MPS_Prescriber__Share(
					ParentId = pId,
					UserOrGroupId = ownerId,
					AccessLevel = 'Read'
				));
			}
			insert shares;
		}
	}
	
	public static void shareProxy(Id ownerId, Id proxyId)
	{
		shareProxies(ownerId, new List<Id>{proxyId});
	}
	
	public static void shareProxies(Id ownerId, List<GNE_CM_MPS_Proxy_Management__c> proxies)
	{
		List<Id> proxyIds = new List<Id>();
		for (GNE_CM_MPS_Proxy_Management__c p : proxies) {
			proxyIds.add(p.Id);
		}
		shareProxies(ownerId, proxyIds);
	}
	
	public static void shareProxies(Id ownerId, List<Id> proxyIds)
	{
		if (ownerId != null && proxyIds != null && !proxyIds.isEmpty()) {
			List<GNE_CM_MPS_Proxy_Management__Share> shares = new List<GNE_CM_MPS_Proxy_Management__Share>();
			for (Id pId : proxyIds) {
				shares.add(new GNE_CM_MPS_Proxy_Management__Share(
					ParentId = pId,
					UserOrGroupId = ownerId,
					AccessLevel = 'Read'
				));
			}
			insert shares;
		}
	}
	
	public static void shareRegistration(Id ownerId, Id registrationId)
	{
		shareRegistrations(ownerId, new List<Id>{registrationId});
	}
	
	public static void shareRegistrations(Id ownerId, List<GNE_CM_MPS_Registration__c> registrations)
	{
		List<Id> registrationIds = new List<Id>();
		for (GNE_CM_MPS_Registration__c r : registrations) {
			registrationIds.add(r.Id);
		}
		shareRegistrations(ownerId, registrationIds);
	}
	
	public static void shareRegistrations(Id ownerId, List<Id> registrationIds)
	{
		if (ownerId != null && registrationIds != null && !registrationIds.isEmpty()) {
			List<GNE_CM_MPS_Registration__Share> shares = new List<GNE_CM_MPS_Registration__Share>();
			for (Id rId : registrationIds) {
				shares.add(new GNE_CM_MPS_Registration__Share(
					ParentId = rId,
		 			UserOrGroupId = ownerId,
		 			AccessLevel = 'Read'
				));
			}
			insert shares;
		}
	}
	
	public static void shareUser(Id ownerId, Id userId)
	{
		shareUsers(ownerId, new List<Id>{userId});
	}
	
	public static void shareUsers(Id ownerId, List<GNE_CM_MPS_User__c> users)
	{
		List<Id> userIds = new List<Id>();
		for (GNE_CM_MPS_User__c u : users) {
			userIds.add(u.Id);
		}
		shareUsers(ownerId, userIds);
	}
	
	public static void shareUsers(Id ownerId, List<Id> userIds)
	{
		if (ownerId != null && userIds != null && !userIds.isEmpty()) {
			List<GNE_CM_MPS_User__Share> shares = new List<GNE_CM_MPS_User__Share>();
			for (Id uId : userIds) {
				shares.add(new GNE_CM_MPS_User__Share(
					ParentId = uId,
					UserOrGroupId = ownerId,
					AccessLevel = 'Read'
				));
			}
			insert shares;
		}
	}
	
	public static GNE_CM_MPS_User_Preferences__c createMpsUserPreferences(String userId, Map<String,String> initFieldValues)
    {
    	GNE_CM_MPS_User_Preferences__c prefs = new GNE_CM_MPS_User_Preferences__c(MPS_User__c = userId);
    	if (initFieldValues != null && !initFieldValues.isEmpty()) {
    		for (String fn : initFieldValues.keySet()) {
    			prefs.put(fn, initFieldValues.get(fn));
    		}
    	}
    	return prefs;
    }
    
    public static GNE_CM_MPS_User_Preferences__c createMpsUserPreferences(String userId)
    {
    	return GNE_CM_MPS_Test_Helper.createMpsUserPreferences(userId, null);
    }
	
	public static GNE_CM_MPS_Registration__c createMpsRegistration(Map<String,String> initFields)
	{
		Map<String,String> defaultFields = new Map<String,String>{
			'Authorized_Representative_First_Name__c' => 'Harrison',
			'Authorized_Representative_Last_Name__c' => 'Jones',
			'Authorized_Representative_Email__c' => 'harrisonjones@mailinator.com',
			'Authorized_Representative_Phone__c' => '(000) 000-000',
			'Authorized_Representative_Phone_Ext__c' => null,
			'Role_in_Practice__c' => 'Medical Doctor',
			'Practice_Name__c' => 'Temple of Skulls',
			'Address__c' => 'Secret location',
			'Address_Suite__c' => '001',
			'City__c' => 'San Francisco',
			'State__c' => 'CA',
			'Zip_Code__c' => '00000',
			'Phone__c' => '(000) 000-0000',
			'Phone_Extension__c' => null,
			'Fax__c' => '(000) 000-0001',
			'Practice_Product__c' => GNE_CM_MPS_Test_Helper.getPracticeProductString(),
			'Registration_Status__c' => 'Approved'
		};
		
		if (initFields == null) {
			initFields = new Map<String,String>();
		}
		
		GNE_CM_MPS_Registration__c mpsRegistration = new GNE_CM_MPS_Registration__c();
		
		for (String field : defaultFields.keySet()) {
			mpsRegistration.put(field, initFields.containsKey(field) ? initFields.get(field) : defaultFields.get(field));
		}
		
		return mpsRegistration;
	}
	
	public static GNE_CM_MPS_Registration__c createMpsRegistration()
	{
		return GNE_CM_MPS_Test_Helper.createMpsRegistration(null);
	}
	
	public static GNE_CM_MPS_Location__c createMpsLocation(GNE_CM_MPS_Registration__c mpsReg, Map<String,String> initFields)
	{
		Map<String,String> defaultFields = new Map<String,String>{
			'GNE_CM_MPS_Registration__c' => mpsReg.Id,
			'Office_Location_Address__c' => mpsReg.Address__c,
			'Suite__c' => mpsReg.Address_Suite__c,
			'City__c' => mpsReg.City__c,
			'State__c' => mpsReg.State__c,
			'Zip__c' => mpsReg.Zip_Code__c,
			'Intake_Status__c' => 'Processed'
		};
		Map<String,Boolean> defaultBooleanFields = new Map<String,Boolean>{'Disabled__c' => false};
		
		if (initFields == null) {
			initFields = new Map<String,String>();
		}
		
		GNE_CM_MPS_Location__c mpsLocation = new GNE_CM_MPS_Location__c();
		
		for (String field : defaultFields.keySet()) {
			mpsLocation.put(field, initFields.containsKey(field) ? initFields.get(field) : defaultFields.get(field));
		}
		for (String booleanField : defaultBooleanFields.keySet()) {
			mpsLocation.put(booleanField, initFields.containsKey(booleanField) ? Boolean.valueOf(initFields.get(booleanField)) : defaultBooleanFields.get(booleanField));
		}
		
		return mpsLocation;
	}
	
	public static GNE_CM_MPS_Location__c createMpsLocation(GNE_CM_MPS_Registration__c mpsReg)
	{
		return GNE_CM_MPS_Test_Helper.createMpsLocation(mpsReg, null);
	}
	
	public static GNE_CM_MPS_Practice_Agreement__c createMpsPracticeAgreement(Id accId, Id userId, Id regId, Map<String,String> initFields)
	{
		Map<String,String> defaultFields = new Map<String,String>{
			'Account__c' => accId,
			'MPS_Registration__c' => regId,
			'MPS_User__c' => userId
		};
		Map<String,Boolean> defaultBooleanFields = new Map<String,Boolean>{'Is_User__c' => true};
		
		if (initFields == null) {
			initFields = new Map<String,String>();
		}
		
		GNE_CM_MPS_Practice_Agreement__c mpsPracticeAgreement = new GNE_CM_MPS_Practice_Agreement__c();
		
		for (String field : defaultFields.keySet()) {
			mpsPracticeAgreement.put(field, initFields.containsKey(field) ? initFields.get(field) : defaultFields.get(field));
		}
		for (String booleanField : defaultBooleanFields.keySet()) {
			mpsPracticeAgreement.put(booleanField, initFields.containsKey(booleanField) ? Boolean.valueOf(initFields.get(booleanField)) : defaultBooleanFields.get(booleanField));
		}
		
		return mpsPracticeAgreement;
	}
	
	public static GNE_CM_MPS_Practice_Agreement__c createMpsPracticeAgreement(Id accId, Id userId, Id regId)
	{
		return GNE_CM_MPS_Test_Helper.createMpsPracticeAgreement(accId, userId, regId, null);
	}
	
	public static GNE_CM_MPS_Practice_Agreement_Location__c createMpsPracticeAgreementLocation(GNE_CM_MPS_Practice_Agreement__c pa, Id locId, Id addrId)
	{
		return new GNE_CM_MPS_Practice_Agreement_Location__c(
			MPS_Practice_Agreement__c = pa.Id,
			MPS_Location__c = locId,
			MPS_Registration__c = pa.MPS_Registration__c,
			Account__c = pa.Account__c,
			Address__c = addrId
		); 
	}
	
	public static GNE_CM_MPS_User__c createMpsUser(Id regId, Map<String,String> initFields)
	{
		Map<String,String> defaultFields = new Map<String,String>{
			'GNE_CM_MPS_Registration__c' => regId,
			'First_name__c' => 'John',
			'Last_name__c' => 'Doe',
			'Email_Address__c' => 'johndoe@mailinator.com',
			'Phone_number__c' => '(111) 111-1111',
			'Phone_number_ext__c' => null,
			'Role_in_Practise__c' => 'Medical Doctor',
			'Workflow_State__c' => 'ACTIVATED',
			'Intake_Status__c' => 'Processed',
			'User_Status__c' => 'Approved'
		};
		Map<String,Boolean> defaultBooleanFields = new Map<String,Boolean>{'Disabled__c' => false, 'Admin__c' => true};
		
		if (initFields == null) {
			initFields = new Map<String,String>();
		}
		
		GNE_CM_MPS_User__c mpsUser = new GNE_CM_MPS_User__c();
		
		for (String field : defaultFields.keySet()) {
			mpsUser.put(field, initFields.containsKey(field) ? initFields.get(field) : defaultFields.get(field));
		}
		for (String booleanField : defaultBooleanFields.keySet()) {
			mpsUser.put(booleanField, initFields.containsKey(booleanField) ? Boolean.valueOf(initFields.get(booleanField)) : defaultBooleanFields.get(booleanField));
		}
		
		return mpsUser;
	}
	
	public static GNE_CM_MPS_User__c createMpsUser(Id regId)
	{
		return GNE_CM_MPS_Test_Helper.createMpsUser(regId, null);
	}
	
	public static Account createPersonAccount(Map<String,String> initFields)
	{		
		Map<String,String> defaultFields = new Map<String,String>{
			'RecordTypeId' => Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional_vod').getRecordTypeId(),
			'FirstName' => 'John',
			'LastName' => 'Doe',
			'Professional_Type_gne__c' => 'Medical Doctor',
			'Credentials_gne__pc' => 'DO',
			'City__pc' => 'San Francisco',
			'State_gne__pc' => 'CA',
			'Zip_4_gne__pc' => '0000',
			'Status_gne__c' => 'Active',
			'MDMID_Status_gne__c' => 'Active'
		};
		
		if (initFields == null) {
			initFields = new Map<String,String>();
		}
		
		Account personAccount = new Account();
		
		for (String field : defaultFields.keySet()) {
			personAccount.put(field, initFields.containsKey(field) ? initFields.get(field) : defaultFields.get(field));
		}
		
		return personAccount;
	}
	
	public static Account createPersonAccount()
	{
		return GNE_CM_MPS_Test_Helper.createPersonAccount(null);
	}
	
	public static Address_vod__c createPersonAddress(Id accId, Map<String,String> initFields)
	{
		Map<String,String> defaultFields = new Map<String,String>{
			'Name' => 'mpsTestAddress',
			'Address_Type_gne__c' => 'Clinic',
			'Address_1_gne__c' => 'Imaginaray Street',
			'Address_line_2_vod__c' => '001',
			'City_vod__c' => 'San Francisco',
			'State_vod__c' => 'CA',
			'Zip_vod__c' => '00000',
			'Country_gen__c' => 'UNITED STATES',
			'Country_vod__c' => 'us',
			'Account_vod__c' => accId
		};
		Map<String,Boolean> defaultBooleanFields = new Map<String,Boolean>{'Clinic_gne__c' => true, 'Primary_vod__c' => true};
		
		if (initFields == null) {
			initFields = new Map<String,String>();
		}
		
		Address_vod__c personAddress = new Address_vod__c();
		
		for (String field : defaultFields.keySet()) {
			personAddress.put(field, initFields.containsKey(field) ? initFields.get(field) : defaultFields.get(field));
		}
		for (String booleanField : defaultBooleanFields.keySet()) {
			personAddress.put(booleanField, initFields.containsKey(booleanField) ? Boolean.valueOf(initFields.get(booleanField)) : defaultBooleanFields.get(booleanField));
		}
		
		return personAddress;
	}
	
	public static Address_vod__c createPersonAddress(Id accId)
	{
		return GNE_CM_MPS_Test_Helper.createPersonAddress(accId, null);
	}
	
	public static User createPersonUser(String userName, Account personAccount, Map<String,String> initFields)
	{
		Profile prof = [SELECT Id FROM Profile WHERE Name = 'GNE-CM-Physician Profile' limit 1];
		
		GNE_CM_MPS_Custom_Setting__c csr = [SELECT Environment_Name__c FROM GNE_CM_MPS_Custom_Setting__c];
		String env = csr.Environment_Name__c;
		String ext = '';		
		if (env.toLowerCase() != 'prod') {
			ext = '.' + env;
		}
		
		Map<String,String> defaultFields = new Map<String,String>{
			'UserName' => userName + '@gene.com' + ext,
			'FirstName' => personAccount.FirstName,
			'LastName' => personAccount.LastName,
			'Alias' => userName.substring(0,8),
			'Email' => userName + '@mailinator.com',
			'ContactId' => personAccount.PersonContactId,
			'LanguageLocaleKey' => 'en_US',
			'LocaleSidKey' => 'en_US',
			'EmailEncodingKey' => 'UTF-8',
			'TimeZoneSidKey' => 'America/Los_Angeles',
			'External_ID_gne__c' => userName + '@gene.com' + ext
		};
		Map<String,Boolean> defaultBooleanFields = new Map<String,Boolean>{'IsActive' => true, 'OverrideSpringCMUserFlag__c' => false};
		
		if (initFields == null) {
			initFields = new Map<String,String>();
		}
		
		User personUser = new User(ProfileId = prof.Id);
		
		for (String field : defaultFields.keySet()) {
			personUser.put(field, initFields.containsKey(field) ? initFields.get(field) : defaultFields.get(field));
		}
		for (String booleanField : defaultBooleanFields.keySet()) {
			personUser.put(booleanField, initFields.containsKey(booleanField) ? Boolean.valueOf(initFields.get(booleanField)) : defaultBooleanFields.get(booleanField));
		}
		
		return personUser;
	}
	
	public static User createPersonUser(String userName, Account personAccount)
	{
		return GNE_CM_MPS_Test_Helper.createPersonUser(userName, personAccount, null);
	}
	
	public static void shareMpsRegistration(Id regId, Id ownerId)
	{
		 GNE_CM_MPS_Registration__Share regShare = new GNE_CM_MPS_Registration__Share(
		 	ParentId = regId,
		 	UserOrGroupId = ownerId,
		 	AccessLevel = 'Read'
		 );
		 insert regShare;
	}
}