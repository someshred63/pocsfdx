/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-12-29
*  Description: 
*  This is FOR MPS UNIT TESTING PURPOSE ONLY!
*  Modification History
*  Date        Name        Description
*                
*************************************************************/

public without sharing class GNE_CM_MPS_UnitTestDataCreator 
{
	public static MpsUserWithAccount getMPSUser(String userName, Map<String, RecordType> recordTypes)
	{
		if(Test.isRunningTest())
		{		
	        String email_ext;
	        String username_ext;
	        String environment = GlobalUtils.getEnvironment();             
	        if(environment == 'prod')
	            email_ext = 'gene.com';
	        else
	            email_ext = 'gene.com.' + environment;
	            
	        if(environment == 'prod')
	            username_ext='gene.mps';
	        else
	            username_ext='gene.mps.' + environment;
	            
			Profile p = [select id from profile where name = 'GNE-CM-Physician Profile' LIMIT 1];
			Account testAcct = getPersonAccount(recordTypes, 'Dennis', 'Rodman', 'Medical Doctor');
			insert testAcct;
			List<Account> accounts = [Select id, LastName, FirstName, IsPersonAccount, RecordType.Name, PersonContactId, Professional_Type_gne__c
	                                        from Account where id =: testAcct.id];        
	                                        		
			User u = new User(alias = userName, email = userName + '@' + email_ext, 
					    	lastName = accounts[0].LastName,
					    	firstName = accounts[0].FirstName,
					    	ContactId = accounts[0].PersonContactId, 
					    	isActive = true,
					    	OverrideSpringCMUserFlag__c = false,
					    	languagelocalekey = 'en_US', emailencodingkey='UTF-8',  
					    	localesidkey = 'en_US', profileid = p.Id,
					    	timezonesidkey = 'America/Los_Angeles', 
					    	username = userName + '@' + username_ext,
					    	External_ID_gne__c = userName + '@' + username_ext);
			insert u;				
			return new MpsUserWithAccount(u, testAcct);
		}
		else
		{
			return null;
		}
	}
	
	private static Account getPersonAccount(Map<String, RecordType> recordTypes, String firstName, String lastName, String professionalType)
	{				
		Id prescriberType = recordTypes.get('Professional_vod').Id;	
		Account personAcct = new Account(recordTypeId = prescriberType,
											FirstName = firstName,
											LastName = lastName,
											Professional_Type_gne__c = professionalType,
											Credentials_gne__pc = 'DO',											
											City__pc = 'Chicago',
											State_gne__pc = 'IL',
											Zip_4_gne__pc = '1234',											
											Status_gne__c = 'Active',
											MDMID_Status_gne__c = 'Active',
											GNE_CM_MPS_General__pc = true,
											GNE_CM_MPS_Document__pc = true,
											GNE_CM_MPS_GATCF_Prescription__pc = true,
											GNE_CM_MPS_GATCF_SMN_Expiring__pc = true,
											GNE_CM_MPS_PAN_Expiring__pc = true,
											GNE_CM_MPS_Product_Shipped__pc = true,
											GNE_CM_MPS_BI_Report_Available__pc = true,
											GNE_CM_MPS_Features_Services__pc = true);
		return personAcct;
	}
	
	public class MpsUserWithAccount
	{
		public User mpsUser {get; private set;}
		public Account mpsAcct {get; private set;}
		public MpsUserWithAccount(User u, Account a)
		{
			this.mpsUser = u;
			this.mpsAcct = a;
		}
	}
	
	public class MPSRegistrationStructure
	{
		public GNE_CM_MPS_Registration__c registration {get; private set;}
		public List<GNE_CM_MPS_User__c> users {get; private set;}
		public List<GNE_CM_MPS_Location__c> locations {get; private set;}
		public List<GNE_CM_MPS_Prescriber__c> prescribers {get; private set;}
		public List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreements {get; private set;}			
		public List<GNE_CM_MPS_Practice_Agreement_Location__c> mpsUserLocations {get; private set;}
		public String defaultState {get; private set;}	
		public User intakeUser {get; private set;}
		
		//private Map<Id, GNE_CM_MPS_User__c> usersMap; //wilczekk: do we still need this?
		private Map<String, RecordType> recordTypes;		
		private Map<Id, List<Address_vod__c>> accountAddressMap;
		private Map<String, Account> newAccounts;
		private User sfdcUser;
		private Account sfdcUserAccount;		
		private Set<Id> mpsUserAddresses;		
		
		public MPSRegistrationStructure(Integer numberOfUsers, Integer numberOfLocations, Integer numberOfPrescribers, Map<String, RecordType> recordTypes, MpsUserWithAccount userAndAcct)
		{
			if(Test.isRunningTest())
			{
				this.defaultState = 'CA';
				this.recordTypes = recordTypes;
				this.sfdcUser = userAndAcct.mpsUser;
				this.sfdcUserAccount = userAndAcct.mpsAcct;
				this.intakeUser = createIntakeUser('kw');
				this.mpsUserAddresses = new Set<Id>();	
				this.mpsUserLocations = new List<GNE_CM_MPS_Practice_Agreement_Location__c>();		
				this.registration = new GNE_CM_MPS_Registration__c(Address__c = '8631 W 3rd St.',
																	Address_Suite__c = '#925E',																
																	Authorized_Representative_Email__c = 'cmrtest@yahoo.com.test',
																	Authorized_Representative_First_Name__c = 'Brian',
																	Authorized_Representative_Last_Name__c = 'Saavadra',
																	Authorized_Representative_Phone__c = '(310) 657-4600',
																	Authorized_Representative_Phone_Ext__c = '(310) 657-',
																	City__c = 'Los Angeles',																
																	Phone__c = '(310) 657-4600',
																	Practice_Name__c = 'Tower Allergy',
																	Practice_Product__c = 'XOLAIR® (omalizumab)',
																	Registration_Status__c = 'Approved',
																	Role_in_Practice__c = 'Medical Doctor',
																	State__c = defaultState,
																	Zip_Code__c = '90048');
				insert registration;
				shareRegistration(sfdcUser, registration);
				shareRegistration(intakeUser, registration);
				
				//users
				users = new List<GNE_CM_MPS_User__c>();
				Boolean hasAdmin = false;
				for(Integer counter = 0; counter < numberOfUsers; counter++)
				{
					GNE_CM_MPS_User__c user = new GNE_CM_MPS_User__c(Disabled__c = false,
																	Email_address__c = 'cmrtest@mailinator.com' + counter, 
																	First_name__c = 'Brian' + counter,
																	GNE_CM_MPS_Registration__c = registration.Id,
																	Intake_Status__c = 'Processed',																
																	Last_name__c = 'Saavadra',
																	Phone_number__c = '(310) 657-4600',
																	Role_in_Practise__c = 'Medical Doctor',
																	User_Status__c = 'Approved');
					if(!hasAdmin)
					{
						user.Admin__c = true;
						hasAdmin = true;
					}
					users.add(user);
				}
				newAccounts = new Map<String, Account>();
				for(GNE_CM_MPS_User__c user : users)
				{
					newAccounts.put(user.First_name__c + user.Last_name__c, createAccount(user.First_name__c, user.Last_name__c));
				}
				insert newAccounts.values();			
				
				Boolean sfdcUserCreated = false;
				//wilczekk: commented out as the trigger is creating PA records when mapped account != null				
				for(GNE_CM_MPS_User__c user : users)
				{
					//user.Mapped_Account__c = newAccounts.get(user.First_name__c + user.Last_name__c).Id;
					if(!sfdcUserCreated)
					{					
						user.SFDC_User__c = userAndAcct.mpsUser.Id;
						//user.Mapped_Account__c = userAndAcct.mpsAcct.Id;
						//user.First_name__c = userAndAcct.mpsAcct.FirstName;
						//user.Last_name__c = userAndAcct.mpsAcct.LastName;						
						newAccounts.put(user.First_name__c + user.Last_name__c, userAndAcct.mpsAcct);
						sfdcUserCreated = true;					
					}
				}
				
				shareAccounts(sfdcUser, newAccounts.values());
				shareAccounts(intakeUser, newAccounts.values());
				
				createAddressesForAccount(newAccounts.values(), 2);					
				insert users;
				shareUsers(sfdcUser, users);
				shareUsers(intakeUser, users);
				
				//locations
				locations = new List<GNE_CM_MPS_Location__c>();
				for(Integer counter = 0; counter < numberOfLocations; counter++)
				{
					GNE_CM_MPS_Location__c loc = new GNE_CM_MPS_Location__c(City__c = 'Gilroy',
																			Disabled__c = false,
																			GNE_CM_MPS_Registration__c = registration.Id,
																			Intake_Status__c = 'Processed',
																			Office_Location_Address__c = '7453 Dornoch CT' + counter,
																			State__c = defaultState,
																			Suite__c = '#925E',
																			Zip__c = '95020');				
					locations.add(loc);
				}
				insert locations;
				shareLocations(sfdcUser, locations);
				shareLocations(intakeUser, locations);
				
				//prescribers
				prescribers = new List<GNE_CM_MPS_Prescriber__c>();
				for(Integer counter = 0; counter < numberOfPrescribers; counter++)
				{
					GNE_CM_MPS_Prescriber__c pres = new GNE_CM_MPS_Prescriber__c(Disabled__c = false,
																				First_Name__c = 'Brian' + counter,
																				GNE_CM_MPS_Registration__c = registration.Id,
																				Intake_Status__c = 'Processed',
																				Last_Name__c = 'Saavadra',
																				Mapped_to_PA__c = false,
																				Prescriber_Type__c = 'Medical Doctor',
																				State_License__c = 'N/A');
					prescribers.add(pres);
				}					
				insert prescribers;
				sharePrescribers(sfdcuser, prescribers);
				sharePrescribers(intakeUser, prescribers);
				
				createPA();
				createProxy();
				createLicenseInformation();
			}
		}
		
		private User createIntakeUser(String userName)
		{
			if(Test.isRunningTest())
			{		
				Profile p = [select id from profile where name='GNE-CM-INTAKE'];
				string environment = GlobalUtils.getEnvironment();
				string userTail = '';
				if (environment != '' && environment != 'prod')
					userTail = '.' + environment;
				
				User u = new User(alias = userName, email = userName + 'test@gene.com', 
						    	emailencodingkey='UTF-8', lastname='Testing', isActive = true, OverrideSpringCMUserFlag__c = false, languagelocalekey='en_US', 
						    	localesidkey='en_US', profileid = p.Id, 
						    	timezonesidkey='America/Los_Angeles', username = userName + 'test@gene.com' + userTail);
				insert u;
				return u;
			}
			else
			{
				return null;
			}
		}
				
		private void createLicenseInformation()
		{
			List<ProfileID_License_gne__c> licenseInfos = new List<ProfileID_License_gne__c>();
			Set<String> licenseTypes = new Set<String>{'State License', 'NPI #', 'PTAN', 'Tax ID', 'DEA #'};
			Integer licenseNumberCtr = 1;
			String licNumStr;
			for(Account a : newAccounts.values())
			{
				for(String licType : licenseTypes)
				{
					if(licType == 'DEA #')
					{
						licNumStr = 'AP5836727';						
					}
					else
					{
						licNumStr = '123456-' + licenseNumberCtr;
					}
					licenseInfos.add(new ProfileID_License_gne__c(Account_Name_gne__c = a.Id,
																	ID_License_Type_gne__c = licType,
																	State_gne__c = defaultState,
																	Address_gne__c = accountAddressMap.get(a.Id)[0].Id,
																	ID_License_gne__c = licNumStr));
					licenseNumberCtr++;
				}
			}
			insert licenseInfos;			
		}
						
		private void createProxy()
		{
			List<GNE_CM_MPS_Proxy_Management__c> proxies = new List<GNE_CM_MPS_Proxy_Management__c>();
			for(GNE_CM_MPS_Prescriber__c pres : prescribers)
			{
				proxies.add(new GNE_CM_MPS_Proxy_Management__c(Is_Proxy_Enabled__c = true,
																MPS_Prescriber__c = pres.Id,
																User_Account__c = sfdcUserAccount.Id));
			}
			insert proxies;
			shareProxies(sfdcUser, proxies);
			shareProxies(intakeUser, proxies);
		}
		
		private void createPA()
		{
			practiceAgreements = new List<GNE_CM_MPS_Practice_Agreement__c>();
						
			//usersMap = new Map<Id, GNE_CM_MPS_User__c>();			
			for(GNE_CM_MPS_User__c user : users)
			{
				String key = user.First_name__c + user.Last_name__c;				
				GNE_CM_MPS_Practice_Agreement__c pa = new GNE_CM_MPS_Practice_Agreement__c(Account__c = newAccounts.get(key).Id,
																							Is_User__c = true,
																							MPS_Registration__c = registration.Id,
																							MPS_User__c = user.Id);
				for(GNE_CM_MPS_Prescriber__c pres : prescribers)
				{
					if(user.First_name__c == pres.First_Name__c && user.Last_name__c == pres.Last_Name__c)
					{//flag prescriber
						pa.Is_Prescriber__c = true;
						pa.MPS_Prescriber__c = pres.Id;
						break;
					}
				}				
				practiceAgreements.add(pa);
				//usersMap.put(user.Id, user);
			}			
			insert practiceAgreements;
			sharePracticeAgreements(sfdcUser, practiceAgreements);
			sharePracticeAgreements(intakeUser, practiceAgreements);	
			createPALocation(practiceAgreements);		
		}
		
		private void createPALocation(List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreements)
		{
			List<GNE_CM_MPS_Practice_Agreement_Location__c> paLocations = new List<GNE_CM_MPS_Practice_Agreement_Location__c>();
			for(GNE_CM_MPS_Practice_Agreement__c pa : practiceAgreements)
			{
				Integer numberOfLocations = locations.size();
				for(Address_vod__c addr : accountAddressMap.get(pa.Account__c))
				{
					if(numberOfLocations > 0)
					{
						paLocations.add(new GNE_CM_MPS_Practice_Agreement_Location__c(Account__c = pa.Account__c,
																					Address__c = addr.Id,
																					MPS_Location__c = locations[numberOfLocations - 1].Id,
																					MPS_Practice_Agreement__c = pa.Id,
																					MPS_Registration__c = registration.Id));						
						numberOfLocations--;
					}
				}
			}
			insert paLocations;
			for(GNE_CM_MPS_Practice_Agreement_Location__c paLoc : paLocations)
			{
				if(mpsUserAddresses.contains(paLoc.Address__c))
				{
					mpsUserLocations.add(paLoc);
				}
			}
			sharePALocations(sfdcUser, paLocations);
			sharePALocations(intakeUser, paLocations);
		}
		
		private void createAddressesForAccount(List<Account> accounts, Integer numberOfAddressesPerAcct)
		{
			List<Address_vod__c> addresses = new List<Address_vod__c>();
			Id compMaintained = Schema.SObjectType.Address_vod__c.getRecordTypeInfosByName().get('Company Maintained').getRecordTypeId();
			accountAddressMap = new Map<Id, List<Address_vod__c>>();
			for(Account a : accounts)
			{
				List<Address_vod__c> accountAddresses = new List<Address_vod__c>();
				for(Integer counter = 0; counter < numberOfAddressesPerAcct; counter++)
				{
					Address_vod__c addressItem = new Address_vod__c(recordTypeId = compMaintained,												
												Account_vod__c = a.Id,
												Address_1_gne__c = 'first line address ' + counter,												
												Name = 'test address',
												Phone_vod__c = '1234',
												Address_line_2_vod__c = 'second addr line',
												City_vod__c = 'New York',
												Address_Line_3_gne__c = 'third addr line',
												Address_Line_4_gne__c = 'fourth addr line',
												State_vod__c = defaultState,
												Zip_vod__c = '666');
					addresses.add(addressItem);
					accountAddresses.add(addressItem);
				}
				accountAddressMap.put(a.Id, accountAddresses);				
			}
			insert addresses;
			for(Address_vod__c addr : addresses)
			{
				if(addr.Account_vod__c == sfdcUserAccount.Id)
				{
					mpsUserAddresses.add(addr.Id);
				}
			}			
		}				
		
		private Account createAccount(String firstName, String lastName)
		{			
			return GNE_CM_MPS_UnitTestDataCreator.getPersonAccount(recordTypes, firstName, lastName, 'Office/Billing Manager');			
		}
		
		private void shareRegistration(User newOwner, GNE_CM_MPS_Registration__c reg)
		{
			GNE_CM_MPS_Registration__Share regShare = new GNE_CM_MPS_Registration__Share();
			regShare.ParentId = reg.Id;
			regShare.UserOrGroupId = newOwner.Id;
			regShare.AccessLevel = 'Read';
			insert regShare;
		}
		
		private void shareAccounts(User newOwner, List<Account> accounts)
		{
			List<AccountShare> acctShares = new List<AccountShare>();
			for(Account a : accounts)
			{
				acctShares.add(new AccountShare(AccountId = a.Id,
												UserOrGroupId = newOwner.Id,
												AccountAccessLevel = 'Read',
												OpportunityAccessLevel = 'Read'));
			}
			insert acctShares;
		}
		
		private void shareUsers(User newOwner, List<GNE_CM_MPS_User__c> users)
		{
			List<GNE_CM_MPS_User__Share> userShares = new List<GNE_CM_MPS_User__Share>();
			for(GNE_CM_MPS_User__c u : users)
			{
				userShares.add(new GNE_CM_MPS_User__Share(ParentId = u.Id,
															UserOrGroupId = newOwner.Id,
															AccessLevel = 'Read'));
			}
			insert userShares;
		}
		
		private void shareLocations(User newOwner, List<GNE_CM_MPS_Location__c> locations)
		{
			List<GNE_CM_MPS_Location__Share> locShares = new List<GNE_CM_MPS_Location__Share>();
			for(GNE_CM_MPS_Location__c l : locations)
			{
				locShares.add(new GNE_CM_MPS_Location__Share(ParentId = l.Id,
																UserOrGroupId = newOwner.Id,
																AccessLevel = 'Read'));
			}
			insert locShares;
		}
		
		private void sharePrescribers(User newOwner, List<GNE_CM_MPS_Prescriber__c> prescribers)
		{
			List<GNE_CM_MPS_Prescriber__Share> presShares = new List<GNE_CM_MPS_Prescriber__Share>();
			for(GNE_CM_MPS_Prescriber__c p : prescribers)
			{
				presShares.add(new GNE_CM_MPS_Prescriber__Share(ParentId = p.Id,
																UserOrGroupId = newOwner.Id,
																AccessLevel = 'Read'));
			}
			insert presShares;
		}
		
		private void sharePracticeAgreements(User newOwner, List<GNE_CM_MPS_Practice_Agreement__c> pracAgreements)
		{
			List<GNE_CM_MPS_Practice_Agreement__Share> paShares = new List<GNE_CM_MPS_Practice_Agreement__Share>();
			for(GNE_CM_MPS_Practice_Agreement__c pa : pracAgreements)
			{
				paShares.add(new GNE_CM_MPS_Practice_Agreement__Share(ParentId = pa.Id,
																		UserOrGroupId = newOwner.Id,
																		AccessLevel = 'Read'));
			}
			insert paShares;
		}
		
		private void sharePALocations(User newOwner, List<GNE_CM_MPS_Practice_Agreement_Location__c> paLocations)
		{
			List<GNE_CM_MPS_Practice_Agreement_Location__Share> paLocShares = new List<GNE_CM_MPS_Practice_Agreement_Location__Share>();
			for(GNE_CM_MPS_Practice_Agreement_Location__c pLoc : paLocations)
			{
				paLocShares.add(new GNE_CM_MPS_Practice_Agreement_Location__Share(ParentId = pLoc.Id,
																					UserOrGroupId = newOwner.Id,
																					AccessLevel = 'Read'));
			}
			insert paLocShares;
		}
		
		private void shareProxies(User newOwner, List<GNE_CM_MPS_Proxy_Management__c> proxies)
		{
			List<GNE_CM_MPS_Proxy_Management__Share> proxiesShare = new List<GNE_CM_MPS_Proxy_Management__Share>();
			for(GNE_CM_MPS_Proxy_Management__c proxy : proxies)
			{
				proxiesShare.add(new GNE_CM_MPS_Proxy_Management__Share(ParentId = proxy.Id,
																		UserOrGroupId = newOwner.Id,
																		AccessLevel = 'Read'));
			}
		}
	}	
}