/************************************************************
*  @author: Krzysztof Wilczek, Radek Krawiec Roche
*  Date: 2010-10-13
*  Description: 
*  Helper class for test methods used in unit test of Case Managment functionalities
*  Modification History
*  Date        Name                     Description
*  05/29/12     Radek Krawiec           Added method 'addTestUser'
*  05/29/12     Radek Krawiec           Added method 'addTestAccount'
*  05/29/12     Radek Krawiec           Added method 'addTestInfusion'
*  05/29/12     Radek Krawiec           Added method 'addTestCase'
*  05/29/12     Radek Krawiec           Added method 'addTestShipment'
*  05/29/12     Radek Krawiec           Added method 'addTestMedicalHistory'
*  05/29/12     Radek Krawiec           Added method 'addShipmentsAndInfusionsToAccount'
*                
*************************************************************/
public class GNE_CM_Test_Helper
{
    private static Integer counter = 0;
    private static final String LWO_PROFILE = 'GNE-LWO-USER';
    private static RecordType personAccountRT 
    {
        get
        {
            if(personAccountRT == null)
            {
                personAccountRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true limit 1];
                return personAccountRT;
            }
            else
            {
                return personAccountRT;
            }
        }   
        private set;
    }
    /*
    public class CaseStructureNew
    {
        public Patient_gne__c patient { get; set; }
        public ICD9_Code_gne__c icd9 { get; set; }
        public Medical_History_gne__c medicalHistory { get; set; }
        public User caseManager { get; set; }
        public Case caseObj { get; set; }
        public Account prescriber { get; set; }
        public Insurance_gne__c insurance { get; set; }
    }*/
    
    public class CaseStructure
    {
        public Patient_gne__c patient { get; set; }
        public ICD9_Code_gne__c icd9 { get; set; }
        public Medical_History_gne__c medicalHistory { get; set; }
        public User caseManager { get; set; }
        public Case caseObj { get; set; }
        public Case crCase { get; set; }
        public Case gatcfCase { get; set; }
        public Case gesCase { get; set; }
        public Account prescriber { get; set; }
        public Insurance_gne__c insurance { get; set; }
    }
    
    public class BenefitInvestigationStructure
    {
        public Account payer { get; set; }
        public Insurance_gne__c insurance { get; set; }
        public User reimbSpecialist { get; set; }
        public Benefit_Investigation_gne__c benefitInvestigation { get; set; }    
    }
    
    public static List<Actual_Working_Days_gne__c> addTestActualWorkingDays(Integer daysCount)
    {
        List<Actual_Working_Days_gne__c> testActualWorkingDays = new List<Actual_Working_Days_gne__c>();
        for (Integer i = 1; i <= daysCount; i++)
        {
            testActualWorkingDays.add(new Actual_Working_Days_gne__c(Date_gne__c = Date.today().addDays(i)));   
        }
        insert testActualWorkingDays;
        return testActualWorkingDays;
    }
    
    public static List<Actual_Working_Days_gne__c> addTestActualWorkingDays()
    {
        return addTestActualWorkingDays(10);
    }
    
    public static List<Business_Hours__c> addTestBusinessHours()
    {
        List<Business_Hours__c> testBusinessHours = new List<Business_Hours__c>();
        testBusinessHours.add(new Business_Hours__c(Name = 'Business Hour Values', Business_Day_Start_Time__c = 6, Business_Day_End_Time__c = 17, Business_Date_Full_Duration__c = 11));
        insert testBusinessHours;
        return testBusinessHours;
    }
    
    public static CaseStructure addTestData(User testUser, String product, String caseRecordType)
    {
        return addTestData(testUser, product, caseRecordType, 'Primary');
    }
    
    public static CaseStructure addTestData(User testUser, String product, String caseRecordType, String insuranceRank)
    {
        //******************************** Prepare test data **************************         
        
        String userTail = getUserTail(testUser.username);
        CaseStructure structure = new CaseStructure();
        
        // ICD9 code
        structure.icd9 = addTestICD9();
        
        // Patient
        structure.patient = addTestPatient();
        
        // Medical History
        structure.medicalHistory = addTestMedicalHistory(product, structure.patient.Id);
        
        // Case Manager
        structure.caseManager = addTestCaseManager();
        
        // Case
        Account acc = addTestAccount();
        structure.caseObj = addTestCase(product, caseRecordType, acc, structure.caseManager.Id, structure.medicalHistory.Id, structure.patient.Id);
        structure.caseObj.Cvg_gne__c = 'Coverage Established';
        structure.caseObj.case_referral_reason_gne__c = 'AIC Search';
        structure.caseObj.Referred_By_Type_gne__c = 'Patient';
        
        update structure.caseObj;
        
        // Insurance
        structure.insurance = addTestInsurance(structure.caseObj, acc, insuranceRank);
        
        System.debug('Inserted case: ' + structure.caseObj);
        
        return structure;
    }
    
    public static User addTestLWOUser()
    {
        // insert account
        Account acc = new Account();
        acc.Name = 'TestName';
        acc.OwnerId = GNE_LWO_Utils.getLwoOwnerUserId();
        insert acc;
        
        String firstName = 'Mary';
        String lastName = 'Rebskasdkld';
        String email = 'mary.rebskasdkld' + Math.round((Math.random() * 1000)) + '@ddd.ccc.com';
        String phone = '389238923390';
        
        // create contact
        Contact testContact = new Contact(AccountId = acc.Id);
        testContact.FirstName = firstName;
        testContact.LastName = lastName;
        testContact.Email = email;
        testContact.Phone = phone;  
        testContact.OwnerId = GNE_LWO_Utils.getLwoOwnerUserId();
        insert testContact;
        
        // create LWO SFDC user
        return GNE_CM_Test_Helper.addTestUser(LWO_PROFILE, 'gene.com', testContact.Id);
    }
    
    public static BenefitInvestigationStructure createBIForCase(Case relatedCase, User reimbSpec, Map<String, RecordType> recordTypes)
    {
        String userTail = getUserTail(reimbSpec.username);
        BenefitInvestigationStructure structure = new BenefitInvestigationStructure();
        
        //PAYER
        Id payerType = recordTypes.get('MCO_vod').Id;
        structure.payer = new Account(recordTypeId = payerType, Name = 'test payer', Status_gne__c = 'Active', MDMID_Status_gne__c = 'Active');
        
        //INSURANCE
        structure.insurance = new Insurance_gne__c(
            Case_Insurance_gne__c = relatedCase.Id,
            Payer_gne__c = structure.payer.Id,
            Payer_gne__r = structure.payer,
            Rank_gne__c = 'Primary'
        );
                                           
        //REIMBURSEMENT SPECIALIST
        structure.reimbSpecialist = new User(
            alias = 'cmReimb',
            email = 'cmReimbTest@gene.com',
            emailencodingkey = 'UTF-8',
            lastname = 'Testing',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = reimbSpec.ProfileId,
            timezonesidkey = 'America/Los_Angeles',
            username = 'cmReimbTest@gene.com' + userTail
        );
                                                 
        //BENEFIT INVESTIGATION
        structure.benefitInvestigation = new Benefit_Investigation_gne__c(
            Case_BI_gne__c = relatedCase.Id,
            BI_Type_gne__c = 'BI for Appeal Referral',
            BI_Insurance_gne__c = structure.insurance.Id,
            BI_Insurance_gne__r = structure.insurance,
            Benefit_Type_gne__c = 'Home Health',
            BI_Contact_Name_gne__c = 'test',
            BI_Contact_Phone_gne__c = '1234567890',
            BI_Obtained_Date_gne__c = DateTime.now(),
            BI_BI_Status_gne__c = 'Approved',
            Product_Covered_By_gne__c = 'In Network Benefits',
            IN_Prior_Authorization_Required_gne__c = 'No',
            Reimbursement_Specialist_gne__c = structure.reimbSpecialist.Id,
            Reimbursement_Specialist_gne__r = structure.reimbSpecialist
        );
        
        return structure;
    }
    
    public static Address_vod__c createTestAddress(Id accountId)
    {
        Id compMaintained = Schema.SObjectType.Address_vod__c.getRecordTypeInfosByName().get('Company Maintained').getRecordTypeId();
        return new Address_vod__c(
            recordTypeId = compMaintained,
            Account_vod__c = accountId,
            Name = 'test address',
            Phone_vod__c = '1234',
            Address_line_2_vod__c = 'second addr line',
            City_vod__c = 'New York',
            Address_Line_3_gne__c = 'third addr line',
            Address_Line_4_gne__c = 'fourth addr line',
            State_vod__c = 'NY',
            Zip_vod__c = '666'
       );
    }
    
    public static CaseStructure createTestData(User testUser, String product, String caseRecordType, Boolean insertCaseDependantObjects)
    {
        String userTail = getUserTail(testUser.UserName);
        CaseStructure structure = new CaseStructure();
                
        structure.patient = insertCaseDependantObjects == true ? addTestPatient() : createTestPatient();
        structure.icd9 = insertCaseDependantObjects == true ? addTestICD9() : createTestICD9();
        
        structure.medicalHistory = insertCaseDependantObjects == true ? createTestMedicalHistory(product, structure.patient.Id) : createTestMedicalHistoryFromObject(product, structure.patient);
        structure.caseManager = insertCaseDependantObjects == true ? addTestCaseManager() : createTestCaseManager();
        if (caseRecordType == null)
        {
            structure.crCase = insertCaseDependantObjects == true
                ? createTestCase(product, 'C&R - Standard Case', null, structure.caseManager.Id, structure.medicalHistory.Id, structure.patient.Id)
                : createTestCaseFromObjects(product, 'C&R - Standard Case', null, structure.caseManager, structure.medicalHistory, structure.patient);
            structure.crCase.Cvg_gne__c = 'Coverage Established';
            structure.crCase.case_referral_reason_gne__c = 'AIC Search';
            structure.crCase.Referred_By_Type_gne__c = 'Patient';
            
            structure.gatcfCase = insertCaseDependantObjects == true
                ? createTestCase(product, 'GATCF - Standard Case', null, structure.caseManager.Id, structure.medicalHistory.Id, structure.patient.Id)
                : createTestCaseFromObjects(product, 'GATCF - Standard Case', null, structure.caseManager, structure.medicalHistory, structure.patient);
            structure.gatcfCase.Cvg_gne__c = 'Coverage Established';
            structure.gatcfCase.case_referral_reason_gne__c = 'AIC Search';
            structure.gatcfCase.Referred_By_Type_gne__c = 'Patient';
            
            structure.gesCase = insertCaseDependantObjects == true
                ? createTestCase(product, 'GATCF - Eligibility Screening', null, structure.caseManager.Id, structure.medicalHistory.Id, structure.patient.Id)
                : createTestCaseFromObjects(product, 'GATCF - Eligibility Screening', null, structure.caseManager, structure.medicalHistory, structure.patient);
            structure.gesCase.Cvg_gne__c = 'Coverage Established';
            structure.gesCase.case_referral_reason_gne__c = 'AIC Search';
            structure.gesCase.Referred_By_Type_gne__c = 'Patient';
        }
        else
        {
            structure.caseObj = insertCaseDependantObjects == true
                ? createTestCase(product, caseRecordType, null, structure.caseManager.Id, structure.medicalHistory.Id, structure.patient.Id)
                : createTestCaseFromObjects(product, caseRecordType, null, structure.caseManager, structure.medicalHistory, structure.patient);
            structure.caseObj.Cvg_gne__c = 'Coverage Established';
            structure.caseObj.case_referral_reason_gne__c = 'AIC Search';
            structure.caseObj.Referred_By_Type_gne__c = 'Patient';
        }
        return structure;
    }
    
    public static CaseStructure createTestData(User testUser, String product, String caseRecordType)
    {
        return createTestData(testUser, product, caseRecordType, false);
    }
    
    /*public static CaseStructure createTestData(User testUser, String product)
    {
        return createTestData(testUser, product, null, false);
    }*/
    
    public static CaseStructure createTestData(User testUser, String product)
    {
        //******************************** Prepare test data **************************         
        
        String userTail = getUserTail(testUser.username);
        CaseStructure structure = new CaseStructure();      
            
        //PATIENT
        structure.patient = new Patient_gne__c(name = 'Jordan',
                                               pat_first_name_gne__c = 'Michael');
        
        
        //ICD9 code
        structure.icd9 = new ICD9_Code_gne__c(name = 'test ICD9 code',
                                                    ICD9_Code_gne__c = '666',
                                                    ICD9_Descrption_gne__c = 'test ICD9 code description');
                    
        //MEDICAL HISTORY
        Id avastinID = Schema.SObjectType.Medical_History_gne__c.getRecordTypeInfosByName().get(product).getRecordTypeId();
        structure.medicalHistory = new Medical_History_gne__c(recordTypeId = avastinID,
                                                                Patient_Med_Hist_gne__c = structure.patient.Id,
                                                                Patient_Med_Hist_gne__r = structure.patient,
                                                                ICD9_Code_1_gne__c = structure.icd9.Id,
                                                                ICD9_Code_1_gne__r = structure.icd9);                                                               
        
        //Case Manager
        structure.caseManager = new User(alias = 'cm', email='cmtest@gene.com', 
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                        localesidkey='en_US', profileid = testUser.ProfileId, 
                        timezonesidkey='America/Los_Angeles', username='cmtest@gene.com' + userTail);
        
        //CASE
        Id cr = Schema.SObjectType.Case.getRecordTypeInfosByName().get('C&R - Standard Case').getRecordTypeId();
        structure.crCase = new Case(recordTypeId = cr,
                            Case_Manager__r = structure.caseManager,
                            Product_gne__c = product,
                            Cvg_gne__c = 'Coverage Established',
                            case_referral_reason_gne__c = 'AIC Search',
                            Referred_By_Type_gne__c = 'Patient',
                            Medical_History_gne__c = structure.medicalHistory.Id,
                            Medical_History_gne__r = structure.medicalHistory,
                            Patient_gne__c = structure.patient.Id,
                            Patient_gne__r = structure.patient);
        
        Id gatcf = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GATCF - Standard Case').getRecordTypeId();
        structure.gatcfCase = new Case(recordTypeId = gatcf,
                            Case_Manager__r = structure.caseManager,
                            Product_gne__c = product,
                            Cvg_gne__c = 'Coverage Established',
                            case_referral_reason_gne__c = 'AIC Search',
                            Referred_By_Type_gne__c = 'Patient',
                            Patient_gne__c = structure.patient.Id,
                            Patient_gne__r = structure.patient);
        
        Id ges = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GATCF - Eligibility Screening').getRecordTypeId();
        structure.gesCase = new Case(recordTypeId = ges,
                            Case_Manager__r = structure.caseManager,
                            Product_gne__c = product,
                            Cvg_gne__c = 'Coverage Established',
                            case_referral_reason_gne__c = 'AIC Search',
                            Referred_By_Type_gne__c = 'Patient',
                            Medical_History_gne__c = structure.medicalHistory.Id,
                            Medical_History_gne__r = structure.medicalHistory,
                            Patient_gne__c = structure.patient.Id,
                            Patient_gne__r = structure.patient);
        return structure;
    }
    
    public static CaseStructure createTestDataWithAccounts(User testUser, String product, Map<String, RecordType> recordTypes)
    {
        CaseStructure structure = createTestData(testUser, product);
        Id prescriberType = recordTypes.get('Professional_vod').Id;
        structure.prescriber = new Account(
            recordTypeId = prescriberType,
            FirstName = 'Dennis',
            LastName = 'Rodman',
            Professional_Type_gne__c = 'Medical Doctor',
            Credentials_gne__pc = 'DO',                                         
            City__pc = 'Chicago',
            State_gne__pc = 'IL',
            Zip_4_gne__pc = '1234',
            Status_gne__c = 'Active',
            MDMID_Status_gne__c = 'Active'
        );
            
        return structure;
    }
    
    public static Account addShipmentsAndInfusionsToAccount(String product, Case c, Account acc, String shipmentStatus, String shipmentAction)
    {   
        // create 1st infusion
        addTestInfusion (product, acc, c, 'Pretreatment');
        addTestInfusion (product, acc, c, 'Replacementment');
        // create 2nd infusion - commented out because it caused a 'too many soql queries' in a trigger
        // addTestInfusion(product, acc);
        addTestShipment (product, c, acc, shipmentStatus, shipmentAction);
        
        return acc;
    }
    
        
    public static User createTestUser(String profileName, String domain, Id passedContactId)
    {
        if (domain == null || domain == '')
        {
            domain = 'gene.com';
        }
        
        String name = GlobalUtils.getRandomAlphaNumeric(10, 'tu-', '@' + domain);
        
        Profile userProfile;
        try
        {
            userProfile = [SELECT Id FROM Profile WHERE Name = :profileNAme];
        }
        catch (Exception e)
        {
            throw new GNE_CM_InfusionConsoleException('Error getting profile with name \'' + profileName + '\'');
        }
        
        User testUser = passedContactId != null ? new User(contactId = passedContactId) : new User();
        testUser.Username = name;
        testUser.Email = name;
        testUser.LastName = name;
        testUser.Alias = 'test';
        testUser.CommunityNickname = name;
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.ProfileId = userProfile.Id;
        
        return testUser;
    }
    
    // Added more entropy for random user name - Wojciech Twardowski
    /**
     * Adds a test user with the given profile name and the given domain.
     * @param profileName - name of the profile for the new user, e.g. 'System Administrator'
     * @param domain - email domain, defaults to 'gene.com'
     */
    public static User addTestUser (String profileName, String domain, Id passedContactId)
    {
        String name = GlobalUtils.getRandomAlphaNumeric(10, 'tu-', '@' + domain);
        //String name = 'infusion-test-' + Math.round((Math.random() * 1000)) + '@' + domain;
        return addTestUser(name, name, name, null, profileName, domain, passedContactId);
    }
    
    /**
     * Adds a test user with the given profile name and the given domain.
     * @param profileName - name of the profile for the new user, e.g. 'System Administrator'
     * @param domain - email domain, defaults to 'gene.com'
     */
    public static User addTestUser (String lastName, String username, String email, String federationId, String profileName, String domain, Id passedContactId)
    {
        Profile p = null;
        
        // get profile
        try
        {
            p = [SELECT Id FROM Profile WHERE Name = :profileName];
        }
        catch (Exception e)
        {
            throw new GNE_CM_InfusionConsoleException('Error getting profile with name \'' + profileName + '\'');
        }
        
        if (domain == null || domain == '')
        {
            domain = 'gene.com';
        }
        
        User u = passedContactId != null ? new User(contactId = passedContactId) : new User();
        
        u.Username = username;
        u.Email = email;
        u.LastName = lastName;
        u.Alias = 'test';
        u.CommunityNickname = username;
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        
        if (federationId != null)
        {
            u.FederationIdentifier = federationId;
        }
        
        insert u;
        return u;
    }
    
    /**
     * Adds a test user with the given profile name and the given domain.
     * @param profileName - name of the profile for the new user, e.g. 'System Administrator'
     * @param domain - email domain, defaults to 'gene.com'
     */
    public static User addTestUser (String profileName, String domain)
    {
        return addTestUser(profileName, domain, null);
    }
    
    /**
     * Adds a test account.
     */
    public static Account addTestAccount()
    {
        Account testAccount = createTestAccount();
        insert testAccount;
        return testAccount;
    }
    
    public static Account createTestAccount()
    {
        Account testAccount = new Account(
            LastName = 'Some Account'
        );
        testAccount.recordTypeId = personAccountRT.Id;
        return testAccount;
    }
    
    public static ICD9_Code_gne__c addTestICD9(String name, String code, String description)
    {
        ICD9_Code_gne__c testICD9 = createTestICD9(name, code, description);
        insert testICD9;        
        return testICD9;
    }
    
    public static ICD9_Code_gne__c addTestICD9()
    {
        ICD9_Code_gne__c testICD9 = createTestICD9();
        insert testICD9;        
        return testICD9;
    }
    
    public static ICD9_Code_gne__c createTestICD9(String name, String code, String description)
    {
        ICD9_Code_gne__c testICD9 = new ICD9_Code_gne__c(Name = name, ICD9_Code_gne__c = code, ICD9_Descrption_gne__c = description);
        return testICD9;
    }
    
    public static ICD9_Code_gne__c createTestICD9()
    {
        return createTestICD9('Test ICD9', '123', 'ICD9 Dummy Code');
    }
    
    public static ICD9Code_ProductEligibility__c createTestProductEligibility(ICD9_Code_gne__c icd9Code)
    {    	
        return new ICD9Code_ProductEligibility__c(
        	/*Comments__c = 'comments1',*/
        	ICD9_Code_gne__c = icd9Code.Id,
        	Eligibility_gne__c = GNE_CM_ICD9_Code_Dictionary.ELIGIBILITY_ELIGIBLE,
        	ICD9_Code_Text_gne__c =  icd9Code.ICD9_Code_gne__c,
        	Maximum_Age__c = 999,
        	Medical_Eligibility_Requirements_gne__c	= 'requirements',
        	Minimum_Age__c = 0,
        	Product__c = 'Actemra'
        );
    }
    
    /**
     * Adds a test infusion to the database and returns it.
     * @param product - product name, e.g. 'Herceptin'
     * @param acc - account
     * @param c - case
     * @param infusionType - value for the field infusion.Infusion_Type_gne__c
     */
    public static Infusion_gne__c addTestInfusion(String product, Account acc, Case c, String infusionType)
    {
        return addTestInfusion(product, acc, c, infusionType, 100, 'Debit');
    }

    public static Infusion_gne__c addTestInfusion(String product, Account acc, Case c, String infusionType, Double mgrams, String txnType)
    {
        Infusion_gne__c infusion = new Infusion_gne__c();
        infusion.Milligrams_gne__c = mgrams; // any value
        infusion.Infusion_Type_gne__c = infusionType;
        infusion.Infusion_Injection_Status_gne__c = 'Processed';
        infusion.Infusion_Debit_Credit_gne__c = txnType;
        infusion.Case_gne__c = c != null ? c.Id : addTestCase(product, 'GATCF - Standard Case', acc).Id;
        
        // account info can be filled only for herceptin cases
        if (acc != null && product == 'Herceptin')
        {
            infusion.Account_gne__c = acc.Id;
        }
        
        insert infusion;
        
        return infusion;
    }
    
    public static Insurance_gne__c addTestInsurance(Case cs, Account payer, String rank)
    {
        Insurance_gne__c testInsurance = createTestInsurance(cs, payer, rank);
        insert testInsurance;        
        return testInsurance;
    }
    
    public static Insurance_gne__c createTestInsurance(Case cs, Account payer, String rank)
    {
        Insurance_gne__c testInsurance = new Insurance_gne__c(
            Rank_gne__c = rank,
            ins_Insurance_gne__c = 'Active',
            Case_Insurance_gne__c = cs.Id,
            Plan_Product_Type_gne__c = 'EPO',
            Payer_gne__c = payer.Id,
            Payer_gne__r = payer,
            Payer_Ph_Provided_by_Customer_gne__c = '(555) 555-5555',
            Subscriber_Name_gne__c = 'John',
            Subscriber_Num_gne__c = '123456',
            Policy_Number_gne__c = '098765'
        );
        return testInsurance;
    }
    
    public static Case addTestCase(String product, String recordType, Account commonAccount, Id caseManagerId, Id medicalHistoryId, Id patientId, Id foundationSpecialistId)
    {
        Case testCase = createTestCase(product, recordType, commonAccount.Id, caseManagerId, medicalHistoryId, patientId, foundationSpecialistId);
        insert testCase;
        return testCase;
    }
    
    public static Case addTestCase(String product, String recordType, Account commonAccount, Id caseManagerId, Id medicalHistoryId, Id patientId)
    {
        Case testCase = createTestCase(product, recordType, commonAccount.Id, caseManagerId, medicalHistoryId, patientId);
        insert testCase;
        return testCase;
    }
    
    public static Case addTestCase(String product, String recordType, Account commonAccount, Id caseManagerId, Id medicalHistoryId)
    {
        Case testCase = createTestCase(product, recordType, commonAccount.Id, caseManagerId, medicalHistoryId);
        insert testCase;
        return testCase;
    }
    
    public static Case addTestCase(String product, String recordType, Account commonAccount, Id caseManagerId)
    {
        Case testCase = createTestCase(product, recordType, commonAccount.Id, caseManagerId);
        insert testCase;
        return testCase;
    }
    
    public static Case addTestCase(String product, String recordType, Account commonAccount)
    {
        Case testCase = createTestCase(product, recordType, commonAccount.Id);
        insert testCase;
        return testCase;
    }
    
    public static Case addTestCase(String product, String recordType)
    {
        Case testCase = createTestCase(product, recordType);
        insert testCase;
        return testCase;
    }
    
    // Convenience method
    public static Case createTestCase(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId, Id patientId, Id foundationSpecialistId)
    {
        return createTestCaseFromIds(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, patientId, foundationSpecialistId);
    }
    
    public static Case createTestCaseFromIds(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId, Id patientId, Id foundationSpecialistId)
    {
        Case testCase = new Case();
        testCase.Product_gne__c = product;
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        if (commonAccountId == null)
        {
            commonAccountId = addTestAccount().Id;
        }
        testCase.Case_Treating_Physician_gne__c = commonAccountId;
        testCase.Case_Manager__c = caseManagerId != null ? caseManagerId : addTestCaseManager('tcm-' + String.valueOf(Math.round(Math.random() * 10000))).Id;
        if (patientId == null)
        {
            patientId = addTestPatient().Id;
        }
        if(recordType == 'GATCF - Standard Case'){
            testCase.Ins_Eligibility_Determination_gne__c = 'Approved';
        }		
        testCase.Patient_gne__c = patientId;
        testCase.Medical_History_gne__c = medicalHistoryId != null ? medicalHistoryId : addTestMedicalHistory(product, patientId).Id;       
        testCase.Reason = 'Other';
        testCase.case_referral_reason_gne__c = 'New Treating MD';
        testCase.GATCF_Status_gne__c = 'Approved';
        testCase.Medical_Eligibility_gne__c = 'Approved';
        testCase.Medical_Eligibility_Year_gne__c = '2009';
        testCase.Medical_Eligibility_Month_gne__c = 'January';
        testCase.Indication_gne__c = 'Uninsured';
        testCase.Approval_Date_gne__c = Date.today();
        testCase.Eligibility_gne__c = 'Approved';
        testCase.Eligibility_Determination_Date_gne__c = Date.today();
        testCase.Enrollment_Form_Rec_gne__c = Date.today().addDays(-1);
        testCase.Roll_Up_Infuisons_To_gne__c = null;
		testCase.Verified_Income_gne__c = 100;
		testCase.AGI_Qualified_gne__c = 'Yes';
		testCase.Income_Source_gne__c = 'Income Letter';
		testCase.Tax_Return_Year_gne__c = '2014';	
        if (product == 'Herceptin')
        {   
            testCase.Roll_Up_Infuisons_To_gne__c = 'Hospital';            
            testCase.Facility_gne__c = commonAccountId;
        }
        testCase.Foundation_Specialist_gne__c = foundationSpecialistId != null ? foundationSpecialistId : addTestUser('System Administrator', 'gene.com').Id ;
        return testCase;
    }
    
    public static Case createTestCaseFromObjects(String product, String recordType, Account commonAccount, User caseManager, Medical_History_gne__c medicalHistory, Patient_gne__c patient, User foundationSpecialist)
    {
        Case testCase = new Case();
        testCase.Product_gne__c = product;
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        if (commonAccount == null)
        {
            commonAccount = createTestAccount();
        }
        //testCase.Case_Treating_Physician_gne__c = commonAccount.Id;
        testCase.Case_Treating_Physician_gne__r = commonAccount;
        if (caseManager == null)
        {
            caseManager = createTestCaseManager('tcm-' + String.valueOf(Math.round(Math.random() * 1000)));
        }
        testCase.Case_Manager__c = caseManager.Id;
        testCase.Case_Manager__r = caseManager;
        if (patient == null)
        {
            patient = createTestPatient();
        }
        testCase.Patient_gne__c = patient.Id;
        testCase.Patient_gne__r = patient;
        if (medicalHistory == null)
        {
            medicalHistory = createTestMedicalHistoryFromObject(product, patient);
        }
        if(recordType == 'GATCF - Standard Case'){
            testCase.Ins_Eligibility_Determination_gne__c = 'Approved';
        }		
        testCase.Medical_History_gne__c = medicalHistory.Id;
        testCase.Medical_History_gne__r = medicalHistory;
        testCase.Reason = 'Other';
        testCase.case_referral_reason_gne__c = 'New Treating MD';
        testCase.GATCF_Status_gne__c = 'Approved';
        testCase.Medical_Eligibility_gne__c = 'Approved';
        testCase.Medical_Eligibility_Year_gne__c = '2009';
        testCase.Medical_Eligibility_Month_gne__c = 'January';
        testCase.Indication_gne__c = 'Uninsured';
        testCase.Approval_Date_gne__c = Date.today();
        testCase.Eligibility_gne__c = 'Approved';
        testCase.Eligibility_Determination_Date_gne__c = Date.today();
        testCase.Enrollment_Form_Rec_gne__c = Date.today().addDays(-1);
        testCase.Roll_Up_Infuisons_To_gne__c = null;
		testCase.Verified_Income_gne__c = 100;
		testCase.AGI_Qualified_gne__c = 'Yes';
		testCase.Income_Source_gne__c = 'Income Letter';
		testCase.Tax_Return_Year_gne__c = '2014';        
        if (product == 'Herceptin')
        {   
            testCase.Roll_Up_Infuisons_To_gne__c = 'Hospital';            
            testCase.Facility_gne__c = commonAccount.Id;
            testCase.Facility_gne__r = commonAccount;
        }
        if (foundationSpecialist == null)
        {
            foundationSpecialist = createTestUser('System Administrator', 'gene.com', null);
        }
        testCase.Foundation_Specialist_gne__c = foundationSpecialist.Id;
        testCase.Foundation_Specialist_gne__r = foundationSpecialist;
        return testCase;
    }
    
    
    
    public static Case createTestCase(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId, Id patientId)
    {
        return createTestCase(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, patientId, null);
    }
    
    public static Case createTestCaseFromIds(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId, Id patientId)
    {
        return createTestCaseFromIds(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, patientId, null);
    }
    
    public static Case createTestCaseFromObjects(String product, String recordType, Account commonAccount, User caseManager, Medical_History_gne__c medicalHistory, Patient_gne__c patient)
    {
        return createTestCaseFromObjects(product, recordType, commonAccount, caseManager, medicalHistory, patient, null);
    }
    
    public static Case createTestCase(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId)
    {
        return createTestCase(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, null, null);
    }
    
    public static Case createTestCaseFromIds(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId)
    {
        return createTestCaseFromIds(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, null, null);
    }
    
    public static Case createTestCaseFromObjects(String product, String recordType, Account commonAccount, User caseManager, Medical_History_gne__c medicalHistory)
    {
        return createTestCaseFromObjects(product, recordType, commonAccount, caseManager, medicalHistory, null, null);
    }
    
    public static Case createTestCase(String product, String recordType, Id commonAccountId, Id caseManagerId)
    {
        return createTestCase(product, recordType, commonAccountId, caseManagerId, null, null, null);
    }
    
    public static Case createTestCaseFromIds(String product, String recordType, Id commonAccountId, Id caseManagerId)
    {
        return createTestCaseFromIds(product, recordType, commonAccountId, caseManagerId, null, null, null);
    }
    
    public static Case createTestCaseFromObjects(String product, String recordType, Account commonAccount, User caseManager)
    {
        return createTestCaseFromObjects(product, recordType, commonAccount, caseManager, null, null, null);
    }
    
    public static Case createTestCase(String product, String recordType, Id commonAccountId)
    {
        return createTestCase(product, recordType, commonAccountId, null, null, null, null);
    }
    
    public static Case createTestCaseFromIds(String product, String recordType, Id commonAccountId)
    {
        return createTestCaseFromIds(product, recordType, commonAccountId, null, null, null, null);
    }
    
    public static Case createTestCaseFromObjects(String product, String recordType, Account commonAccount)
    {
        return createTestCaseFromObjects(product, recordType, commonAccount, null, null, null, null);
    }
    
    public static Case createTestCase(String product, String recordType)
    {
        return createTestCase(product, recordType, null, null, null, null, null);
    }
    
    public static Case createTestCaseFromIds(String product, String recordType)
    {
        return createTestCaseFromIds(product, recordType, null, null, null, null, null);
    }
    
    public static Case createTestCaseFromObjects(String product, String recordType)
    {
        return createTestCaseFromObjects(product, recordType, null, null, null, null, null);
    }
    
    public static User addTestCaseManager(String userName)
    {
        User testCaseManager = createTestCaseManager(userName);
        insert testCaseManager;        
        return testCaseManager;
    }
    
    public static User addTestCaseManager()
    {
        return addTestCaseManager('cm-');
    }
    
    public static User createTestCaseManager(String userName)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'GNE-CM-CASEMANAGER'];
        String environment = GlobalUtils.getEnvironment();
        String userTail = '';
        if (environment != '' && environment != 'prod')
        {
            userTail = '.' + environment;
        }
        User testCaseManager = new User(
            alias = userName,
            email = userName + 'test@gene.com', 
            emailencodingkey = 'UTF-8',
            lastname = 'Testing',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles',
            username = userName + 'test@gene.com' + userTail
        );
        return testCaseManager;
    }
    
    public static User createTestCaseManager()
    {
        return createTestCaseManager('cm-');
    }
        
    public static Medical_History_gne__c addTestMedicalHistory(String product, Patient_gne__c patient)
    {
        Medical_History_gne__c testMedicalHistory = createTestMedicalHistoryFromObject(product, patient);
        insert testMedicalHistory;
        return testMedicalHistory;
    }
    
    public static Medical_History_gne__c addTestMedicalHistory(String product, Id patientId)
    {
        Medical_History_gne__c testMedicalHistory = createTestMedicalHistory(product, patientId);
        insert testMedicalHistory;
        return testMedicalHistory;
    }
    
    public static Medical_History_gne__c addTestMedicalHistory(String product)
    {
        Medical_History_gne__c testMedicalHistory = createTestMedicalHistory(product, null);
        insert testMedicalHistory;
        return testMedicalHistory;
    }
    
    public static Medical_History_gne__c createTestMedicalHistory(String product, Id patientId)
    {
        Medical_History_gne__c testMedicalHistory = new Medical_History_gne__c();
        testMedicalHistory.RecordTypeId = Schema.SObjectType.Medical_History_gne__c.getRecordTypeInfosByName().get(product).getRecordTypeId();
        testMedicalHistory.Product_gne__c = product;
        testMedicalHistory.Patient_Med_Hist_gne__c = patientId;
        testMedicalHistory.Starter_Dispense_gne__c = '14';
        testMedicalHistory.GATCF_SMN_Expiration_Date_gne__c = Date.today().addDays(1);
        testMedicalHistory.Rx_Expiration_gne__c = Date.today().addDays(1);
        if (product == 'Xeloda')
        {
            testMedicalHistory.CM_500mg_tablets_gne__c = '1';
            testMedicalHistory.CM_150mg_tablets_gne__c = '0';
            testMedicalHistory.CM_500mg_times_per_day_gne__c = '1';
            testMedicalHistory.CM_150mg_times_per_day_gne__c = '0';
            testMedicalHistory.CM_500mg_of_days_on_gne__c = 1;
            testMedicalHistory.CM_150mg_of_days_on_gne__c = 0;
            testMedicalHistory.CM_500mg_of_days_off_gne__c = 0;
            testMedicalHistory.CM_150mg_of_days_off_gne__c = 0;
            testMedicalHistory.CM_500mg_Total_tablets_per_cycle_gne__c = 1;
            testMedicalHistory.CM_150mg_Total_tablets_per_cycle_gne__c = 0;
            testMedicalHistory.Cycles_per_fill_gne__c = '1';
        }
        if (product == 'Xeloda' || product == 'Rituxan RA')
        {
            testMedicalHistory.Num_of_Refills_gne__c = '0'; 
        }        
        return testMedicalHistory;
    }
    
    public static Medical_History_gne__c createTestMedicalHistory(String product)
    {
        return createTestMedicalHistory(product, null);
    }
    
    public static Medical_History_gne__c createTestMedicalHistoryFromObject(String product, Patient_gne__c patient)
    {
        Medical_History_gne__c testMedicalHistory = new Medical_History_gne__c();
        testMedicalHistory.RecordTypeId = Schema.SObjectType.Medical_History_gne__c.getRecordTypeInfosByName().get(product).getRecordTypeId();
        testMedicalHistory.Product_gne__c = product;
        testMedicalHistory.Patient_Med_Hist_gne__c = patient.Id;
        testMedicalHistory.Patient_Med_Hist_gne__r = patient;
        testMedicalHistory.Starter_Dispense_gne__c = '14';
        testMedicalHistory.GATCF_SMN_Expiration_Date_gne__c = Date.today().addDays(1);
        testMedicalHistory.Rx_Expiration_gne__c = Date.today().addDays(1);
        if (product == 'Xeloda')
        {
            testMedicalHistory.CM_500mg_tablets_gne__c = '1';
            testMedicalHistory.CM_150mg_tablets_gne__c = '0';
            testMedicalHistory.CM_500mg_times_per_day_gne__c = '1';
            testMedicalHistory.CM_150mg_times_per_day_gne__c = '0';
            testMedicalHistory.CM_500mg_of_days_on_gne__c = 1;
            testMedicalHistory.CM_150mg_of_days_on_gne__c = 0;
            testMedicalHistory.CM_500mg_of_days_off_gne__c = 0;
            testMedicalHistory.CM_150mg_of_days_off_gne__c = 0;
            testMedicalHistory.CM_500mg_Total_tablets_per_cycle_gne__c = 1;
            testMedicalHistory.CM_150mg_Total_tablets_per_cycle_gne__c = 0;
            testMedicalHistory.Cycles_per_fill_gne__c = '1';
        }
        if (product == 'Xeloda' || product == 'Rituxan RA')
        {
            testMedicalHistory.Num_of_Refills_gne__c = '0'; 
        }        
        return testMedicalHistory;
    }
    
    public static Medical_History_gne__c createTestMedicalHistoryFromObject(String product)
    {
        return createTestMedicalHistoryFromObject(product, null);
    }
    
    public static Patient_gne__c addTestPatient(String firstName, String lastName)
    {
        Patient_gne__c testPatient = createTestPatient(firstName, lastName);
        insert testPatient;        
        return testPatient;
    }
    
    public static Patient_gne__c addTestPatient()
    {
        return addTestPatient('John', 'Doe');
    }
    
    public static Patient_gne__c createTestPatient(String firstName, String lastName)
    {
        Patient_gne__c testPatient = new Patient_gne__c(Name = lastName, pat_first_name_gne__c = firstName);
        return testPatient;
    }
    
    public static Patient_gne__c createTestPatient()
    {
        return createTestPatient('John', 'Doe');
    }
    
    public static Shipment_gne__c addTestShipment (String product, Case c, Account acc, String shipmentStatus, String shipmentAction)
    {
        Shipment_gne__c shipment = new Shipment_gne__c();
        
        shipment.Account_gne__c = acc.Id;
        shipment.Product_gne__c = product;
        shipment.Case_Shipment_gne__c = c.Id;
        shipment.Status_gne__c = shipmentStatus;
        shipment.Action_gne__c = shipmentAction;
        
        shipment.City_gne__c = 'Chicago';
        shipment.Expected_Ship_Date_gne__c = Date.today();
        shipment.Name_gne__c = 'Some name';
        shipment.Street_gne__c = 'Aaa av.';
        shipment.Zip_gne__c = '90210';
        shipment.Phone_gne__c = '222-333-444';
        
        // this call executes 1 query and can be moved up in the call hierarchy to decrease number of soql calls
        // however, this would not be logical
        String ndcNumber = getExampleVialNumberForProduct(product);
        
        shipment.NDC_Product_Vial_1_gne__c = ndcNumber;
        shipment.NDC_Product_Vial_2_gne__c = ndcNumber;
        shipment.NDC_Product_Vial_3_gne__c = ndcNumber;
        
        insert shipment;
        
        return shipment;
    }
    
    public static void addLWOAffiliation (Id contactId)
    {
        Account affAccount = new Account();
        affAccount.Name = 'TestName';
        affAccount.OwnerId = GNE_LWO_Utils.getLwoOwnerUserId();
        insert affAccount;
        
        addLWOAffiliation(contactId, affAccount.Id);    
    }
    
    public static void addLWOAffiliation (Id contactId, Id parentAccountId)
    {   
        Affiliation_vod__c aff = new Affiliation_vod__c();
        aff.From_account_vod__c = parentAccountId;
        aff.To_Contact_vod__c = contactId;
        aff.Role_vod__c = 'Affiliated with';
        aff.Web_Order_Enabled_gne__c = true;
        
        insert aff;
    }
    
    public static User getCaseManagerUser()
    {
        return getCaseManagerUser('krzyszwi');
    }
    
    public static User getCaseManagerUser(String userName)
    {
        Profile p = [select id from profile where name='GNE-CM-CASEMANAGER'];
        string environment = GlobalUtils.getEnvironment();
        string userTail = '';
        if (environment != '' && environment != 'prod')
        {
            userTail = '.' + environment;
        }
        User u = new User(
            alias = userName,
            email = userName + 'test@gene.com', 
            emailencodingkey = 'UTF-8',
            lastname = 'Testing',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles',
            username = userName + 'test@gene.com' + userTail
        );
        
        return u;
    }
    
    private static String getExampleVialNumberForProduct (String product)
    {
        List<Product_vod__c> productVialSizes = [SELECT NDC_Number_gne__c FROM Product_vod__c WHERE Product_Type_vod__c ='NDC' AND Parent_Product_vod__r.name = :product];
        
        return productVialSizes.get(0).NDC_Number_gne__c;
    }
    
    private static String getUserTail(String userName)
    {
        string userTail = '';
        if (userName.indexOf('@gene.com') > 0 && userName.indexOf('@gene.com.') < 0)
        {
            userTail = 'prod';
        }            
        else if (userName.indexOf('@gene.com.') > 0)
        {
            userTail = userName.Substring(userName.indexOf('@gene.com.') + 10, userName.length());
        }
        if (userTail != '' && userTail != 'prod')
        {
            userTail = '.' + userTail;
        }
           
        return userTail;
    }
    
    /********************************************************************* NEW METHODS *****************************************************************************/
    
    public static Account createAccount (String recordTypeName)
    {
        List<RecordType> rts = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :recordTypeName limit 1];
        counter++;
        
        if (rts.isEmpty())
        {
            return createAccount();
        }
        
        return new Account(
            RecordTypeId = rts.get(0).Id,
            Name = 'Test Account ' + String.valueOf(DateTime.now()) + counter 
        );
    }
    
    public static Account createAccount(Boolean personAccount)
    {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = :personAccount limit 1];
        counter++;
        return new Account(
            RecordTypeId = rt.Id,
            Name = 'Test Account ' + String.valueOf(DateTime.now()) + counter 
        );
        
    }
    
    public static Account createAccount()
    {
        return new Account(
            recordTypeId = personAccountRT.Id,
            LastName = 'SomeAccount'
        );
    }
    
    public static Account createAndInsertAccount(String recordTypeName)
    {
        Account accountData = createAccount(recordTypeName);
        insert accountData;
        return accountData;
    }
    
    public static Account createAndInsertAccount(Boolean personAccount)
    {
        Account accountData = createAccount(personAccount);
        insert accountData;
        return accountData;
    }
    
    public static Account createAndInsertAccount()
    {
        Account accountData = createAccount();
        insert accountData;
        return accountData;
    }
    
    public static List<Actual_Working_Days_gne__c> createActualWorkingDays(Integer daysCount)
    {
        List<Actual_Working_Days_gne__c> actualWorkingDays = new List<Actual_Working_Days_gne__c>();
        for (Integer i = 1; i <= daysCount; i++)
        {
            actualWorkingDays.add(new Actual_Working_Days_gne__c(Date_gne__c = Date.today().addDays(i)));   
        }
        return actualWorkingDays;
    }
    
    public static List<Actual_Working_Days_gne__c> createActualWorkingDays()
    {
        return createActualWorkingDays(10);
    }
    
    public static List<Actual_Working_Days_gne__c> createAndInsertActualWorkingDays(Integer daysCount)
    {
        List<Actual_Working_Days_gne__c> actualWorkingDays = createActualWorkingDays(daysCount);
        insert actualWorkingDays;
        return actualWorkingDays;
    }
    
    public static List<Actual_Working_Days_gne__c> createAndInsertActualWorkingDays()
    {
        return createAndInsertActualWorkingDays(10);
    }
    
    public static BenefitInvestigationData createBenefitInvestigationData(Id caseId, String insuranceRank, Account payer, User specialist)
    {
        BenefitInvestigationData biData = new BenefitInvestigationData();
                
        if (payer == null)
        {
            RecordType payerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'MCO_vod'];
            payer = new Account(
                RecordTypeId = payerRecordType.Id,
                Name = 'TestBIPayer',
                Status_gne__c = 'Active',
                MDMID_Status_gne__c = 'Active'
            );
            insert payer;
        }
        biData.payer = payer;
        
        if (specialist == null)
        {
            specialist = createAndInsertCaseManager('reimb-');
        }
        biData.specialist = specialist;
        
        biData.insurance = createAndInsertInsurance(caseId, biData.payer.Id, insuranceRank);
        
        biData.benefitInvestigation = new Benefit_Investigation_gne__c(
            Case_BI_gne__c = caseId,
            BI_Type_gne__c = 'BI for Appeal Referral',
            BI_Insurance_gne__c = biData.insurance.Id,
            Benefit_Type_gne__c = 'Home Health',
            BI_Contact_Name_gne__c = 'testBIContact',
            BI_Contact_Phone_gne__c = '(555) 123-4567',
            BI_Obtained_Date_gne__c = DateTime.now(),
            BI_BI_Status_gne__c = 'Approved',
            IN_Prior_Authorization_Required_gne__c = 'No',
            Product_Covered_By_gne__c = 'In Network Benefits',
            IN_Product_Covered_gne__c = 'Yes',
            Reimbursement_Specialist_gne__c = biData.specialist.Id,
            ON_Medical_Documents_Required_gne__c = 'Yes',
            IN_Medical_Documents_Required_gne__c = 'Yes',
            ON_Admin_Code_Coverage_Rule_gne__c = 'Test',
            IN_Product_Not_Covered_Reason_gne__c = 'Test',
            IN_Admin_Prior_Auth_Required_gne__c = 'Test',
            ON_Admin_Prior_Auth_Required_gne__c = 'Test',
            IN_Drug_Code_Coverage_Rule_gne__c = 'Test',
            ON_Drug_Code_Coverage_Rule_gne__c = 'Test',
            IN_Admin_Code_Coverage_Rule_gne__c = 'Test'
        );
        
        return biData;
    }
    
    public static BenefitInvestigationData createBenefitInvestigationData(Id caseId, String insuranceRank, Account payer)
    {
        return createBenefitInvestigationData(caseId, insuranceRank, payer, null);
    }
    
    public static BenefitInvestigationData createBenefitInvestigationData(Id caseId, String insuranceRank)
    {
        return createBenefitInvestigationData(caseId, insuranceRank, null, null);
    }
    
    public static BenefitInvestigationData createBenefitInvestigationData(Id caseId)
    {
        return createBenefitInvestigationData(caseId, null, null, null);
    }
    
    public static BenefitInvestigationData createAndInsertBenefitInvestigationData(Id caseId, String insuranceRank, Account payer, User specialist)
    {
        BenefitInvestigationData biData = createBenefitInvestigationData(caseId, insuranceRank, payer, specialist);
        insert biData.benefitInvestigation;
        return biData;
    }
    
    public static BenefitInvestigationData createAndInsertBenefitInvestigationData(Id caseId, String insuranceRank, Account payer)
    {
        BenefitInvestigationData biData = createBenefitInvestigationData(caseId, insuranceRank, payer);
        insert biData.benefitInvestigation;
        return biData;
    }
    
    public static BenefitInvestigationData createAndInsertBenefitInvestigationData(Id caseId, String insuranceRank)
    {
        BenefitInvestigationData biData = createBenefitInvestigationData(caseId, insuranceRank);
        insert biData.benefitInvestigation;
        return biData;
    }
    
    public static BenefitInvestigationData createAndInsertBenefitInvestigationData(Id caseId)
    {
        BenefitInvestigationData biData = createBenefitInvestigationData(caseId);
        insert biData.benefitInvestigation;
        return biData;
    }
    
    public static List<Business_Hours__c> createBusinessHours()
    {
        List<Business_Hours__c> businessHours = new List<Business_Hours__c>();
        businessHours.add(new Business_Hours__c(Name = 'Business Hour Values', Business_Day_Start_Time__c = 6, Business_Day_End_Time__c = 17, Business_Date_Full_Duration__c = 11));
        return businessHours;
    }
    
    public static List<Business_Hours__c> createAndInsertBusinessHours()
    {
        List<Business_Hours__c> businessHours = createBusinessHours();
        insert businessHours;
        return businessHours;
    }
    
    public static Case createCase(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId, Id patientId, Id foundationSpecialistId)
    {
        Case caseData = new Case();
        caseData.Product_gne__c = product;
        caseData.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        if (commonAccountId == null)
        {
            commonAccountId = createAndInsertAccount().Id;
        }
        caseData.Case_Treating_Physician_gne__c = commonAccountId;
        if (caseManagerId == null)
        {
            caseManagerId = createAndInsertCaseManager('tcm-' + String.valueOf(Math.round(Math.random() * 1000))).Id;
        }
        caseData.Case_Manager__c = caseManagerId;
        if (patientId == null)
        {
            patientId = createAndInsertPatient().Id;
        }
        caseData.Patient_gne__c = patientId;
        if (medicalHistoryId == null)
        {
            medicalHistoryId = createAndInsertMedicalHistory(product, patientId).Id;
        }
        caseData.Medical_History_gne__c = medicalHistoryId;     
        caseData.Reason = 'Other';
        caseData.case_referral_reason_gne__c = 'New Treating MD';
        caseData.GATCF_Status_gne__c = 'Approved';
        caseData.Medical_Eligibility_gne__c = 'Approved';
        caseData.Medical_Eligibility_Year_gne__c = '2009';
        caseData.Medical_Eligibility_Month_gne__c = 'January';
        caseData.Indication_gne__c = 'Uninsured';
        caseData.Approval_Date_gne__c = Date.today();
        caseData.Eligibility_gne__c = 'Approved';
        caseData.Eligibility_Determination_Date_gne__c = Date.today();
        caseData.Enrollment_Form_Rec_gne__c = Date.today().addDays(-1);
        caseData.Roll_Up_Infuisons_To_gne__c = null;
		caseData.Verified_Income_gne__c = 100;
		caseData.AGI_Qualified_gne__c = 'Yes';
		caseData.Income_Source_gne__c = 'Income Letter';
		caseData.Tax_Return_Year_gne__c = '2014';	        
        if (product == 'Herceptin')
        {   
            caseData.Roll_Up_Infuisons_To_gne__c = 'Hospital';            
            caseData.Facility_gne__c = commonAccountId;
        }
        if (foundationSpecialistId == null)
        {
            foundationSpecialistId = createAndInsertUser('System Administrator', 'gene.com').Id;
        }
        caseData.Foundation_Specialist_gne__c = foundationSpecialistId;
        
        caseData.Cvg_gne__c = 'Coverage Established';
        caseData.case_referral_reason_gne__c = 'AIC Search';
        caseData.Referred_By_Type_gne__c = 'Patient';
        
		caseData = GNE_CM_Test_Helper.setAllowAllDDSFIelds(caseData);
        
        return caseData;
    }
    
    public static Case createCase(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId, Id patientId)
    {
        return createCase(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, patientId, null);
    }
    
    public static Case createCase(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId)
    {
        return createCase(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, null, null);
    }
    
    public static Case createCase(String product, String recordType, Id commonAccountId, Id caseManagerId)
    {
        return createCase(product, recordType, commonAccountId, caseManagerId, null, null, null);
    }
    
    public static Case createCase(String product, String recordType, Id commonAccountId)
    {
        return createCase(product, recordType, commonAccountId, null, null, null, null);
    }
    
    public static Case createCase(String product, String recordType)
    {
        return createCase(product, recordType, null, null, null, null, null);
    }
    
    public static Case createAndInsertCase(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId, Id patientId, Id foundationSpecialistId)
    {
        Case caseData = createCase(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, patientId, foundationSpecialistId);
        insert caseData;
        return caseData;
    }
    
    public static Case createAndInsertCase(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId, Id patientId)
    {
        return createAndInsertCase(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, patientId, null);
    }
    
    public static Case createAndInsertCase(String product, String recordType, Id commonAccountId, Id caseManagerId, Id medicalHistoryId)
    {
        return createAndInsertCase(product, recordType, commonAccountId, caseManagerId, medicalHistoryId, null, null);
    }
    
    public static Case createAndInsertCase(String product, String recordType, Id commonAccountId, Id caseManagerId)
    {
        return createAndInsertCase(product, recordType, commonAccountId, caseManagerId, null, null, null);
    }
    
    public static Case createAndInsertCase(String product, String recordType, Id commonAccountId)
    {
        return createAndInsertCase(product, recordType, commonAccountId, null, null, null, null);
    }
    
    public static Case createAndInsertCase(String product, String recordType)
    {
        return createAndInsertCase(product, recordType, null, null, null, null, null);
    }
    
    // CaseData with Patient, Medical History, Case Manager inserted and ICD9 Code, Case object created 
    public static CaseData createCaseData(String product, String caseRecordType)
    {
        CaseData caseDataObject = new CaseData();
        caseDataObject.patient = createAndInsertPatient(); // need to insert Patient for Medical History and Case dependency
        caseDataObject.icd9 = createICD9Code();
        caseDataObject.medicalHistory = createAndInsertMedicalHistory(product, caseDataObject.patient.Id); // need to insert Medical History for Case dependency
        caseDataObject.caseManager = createAndInsertCaseManager(); // need to insert Case Manager for Case dependency
        caseDataObject.caseObj = createCase(product, caseRecordType, null, caseDataObject.caseManager.Id, caseDataObject.medicalHistory.Id, caseDataObject.patient.Id);
        
        caseDataObject.caseObj.Cvg_gne__c = 'Coverage Established';
        caseDataObject.caseObj.case_referral_reason_gne__c = 'AIC Search';
        caseDataObject.caseObj.Referred_By_Type_gne__c = 'Patient';
        
		caseDataObject.caseObj = GNE_CM_Test_Helper.setAllowAllDDSFIelds(caseDataObject.caseObj);
      
        return caseDataObject;
    }
    
    public static CaseData createAndInsertCaseData(String product, String caseRecordType)
    {
        CaseData caseDataObject = createCaseData(product, caseRecordType);
        insert caseDataObject.icd9;
        insert caseDataObject.caseObj;
        return caseDataObject;
    }
    
    public static User createCaseManager(String userName)
    {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'GNE-CM-CASEMANAGER'];
        String environment = GlobalUtils.getEnvironment();
        String userTail = '';
        if (environment != '' && environment != 'prod')
        {
            userTail = '.' + environment;
        }
        User caseManager = new User();
        caseManager.Alias = 'testcm';
        caseManager.Email = userName + 'test@gene.com';
        caseManager.LastName = 'TestCM';
        caseManager.EmailEncodingKey = 'UTF-8';
        caseManager.LanguageLocaleKey = 'en_US';
        caseManager.LocaleSidKey = 'en_US';
        caseManager.TimeZoneSidKey = 'America/Los_Angeles';
        caseManager.ProfileId = profileId.Id;
        caseManager.UserName = userName + 'test@gene.com' + userTail;
        return caseManager;
    }
    
    public static User createCaseManager()
    {
        return createCaseManager('tcm-' + String.valueOf(Math.round(Math.random() * 1000)));
    }
    
    public static User createAndInsertCaseManager(String userName)
    {
        User caseManager = createCaseManager(userName);
        insert caseManager;
        return caseManager;
    }
    
    public static User createAndInsertCaseManager()
    {
        return createAndInsertCaseManager('tcm-' + String.valueOf(Math.round(Math.random() * 1000)));
    }

    public static ICD9_Code_gne__c createICD9Code(String name, String code, String description)
    {
        return createICD9Code(name, code, description, null);
    }
    
    public static ICD9_Code_gne__c createICD9Code(String name, String code, String description, String version)
    {
        ICD9_Code_gne__c ICD9Code = new ICD9_Code_gne__c(Name = name, ICD9_Code_gne__c = code, ICD9_Descrption_gne__c = description, ICD_version_gne__c = version);
        return ICD9Code;
    }
    
    public static ICD9_Code_gne__c createICD9Code()
    {
        return createICD9Code('Test ICD9 Code' ,'123' , 'Test ICD9 Code Description', 'ICD-9');
    }

    public static ICD9_Code_gne__c createAndInsertICD9Code(String name, String code, String description, String version)
    {
        ICD9_Code_gne__c ICD9Code = createICD9Code(name, code, description, version);
        insert ICD9Code;
        return ICD9Code;
    }    

    public static ICD9_Code_gne__c createAndInsertICD9Code(String name, String code, String description)
    {
        return createAndInsertICD9Code(name, code, description, null);
    }
    
    public static ICD9_Code_gne__c createAndInsertICD9Code()
    {
        return createAndInsertICD9Code('Test ICD9 Code' ,'123' , 'Test ICD9 Code Description', 'ICD-9');
    }
    
    public static Insurance_gne__c createInsurance(Id caseId, Id payerId, String rank)
    {
        Insurance_gne__c insurance = new Insurance_gne__c();
        insurance.Case_Insurance_gne__c = caseId;
        insurance.ins_Insurance_gne__c = 'Active';
        insurance.Plan_Product_Type_gne__c = 'EPO';
        insurance.Payer_gne__c = payerId;
        insurance.Payer_Ph_Provided_by_Customer_gne__c = '(555) 555-5555';
        insurance.Subscriber_Name_gne__c = 'JohnDoe';
        insurance.Subscriber_Num_gne__c = '123456';
        insurance.Policy_Number_gne__c = '098765';
        insurance.Rank_gne__c = rank == null ? 'Primary' : rank ;
        return insurance;
    }
    
    public static Insurance_gne__c createAndInsertInsurance(Id caseId, Id payerId, String rank)
    {
        Insurance_gne__c insurance = createInsurance(caseId, payerId, rank);
        insert insurance;
        return insurance;
    }
    
    public static Medical_History_gne__c createMedicalHistory(String product, Id patientId)
    {
        Medical_History_gne__c medicalHistory = new Medical_History_gne__c();
        medicalHistory.RecordTypeId = Schema.SObjectType.Medical_History_gne__c.getRecordTypeInfosByName().get(product).getRecordTypeId();
        medicalHistory.Product_gne__c = product;
        if (patientId == null)
        {
            patientId = createAndInsertPatient().Id;
        }
        medicalHistory.Patient_Med_Hist_gne__c = patientId;
        medicalHistory.Starter_Dispense_gne__c = '14';
        medicalHistory.GATCF_SMN_Expiration_Date_gne__c = Date.today().addDays(1);
        medicalHistory.Rx_Expiration_gne__c = Date.today().addDays(1);
        if (product == 'Xeloda')
        {
            medicalHistory.CM_500mg_tablets_gne__c = '1';
            medicalHistory.CM_150mg_tablets_gne__c = '0';
            medicalHistory.CM_500mg_times_per_day_gne__c = '1';
            medicalHistory.CM_150mg_times_per_day_gne__c = '0';
            medicalHistory.CM_500mg_of_days_on_gne__c = 1;
            medicalHistory.CM_150mg_of_days_on_gne__c = 0;
            medicalHistory.CM_500mg_of_days_off_gne__c = 0;
            medicalHistory.CM_150mg_of_days_off_gne__c = 0;
            medicalHistory.CM_500mg_Total_tablets_per_cycle_gne__c = 1;
            medicalHistory.CM_150mg_Total_tablets_per_cycle_gne__c = 0;
            medicalHistory.Cycles_per_fill_gne__c = '1';
        }
        if (product == 'Xeloda' || product == 'Rituxan RA')
        {
            medicalHistory.Num_of_Refills_gne__c = '0'; 
        }        
        return medicalHistory;
    }
    
    public static Medical_History_gne__c createMedicalHistory(String product)
    {
        return createMedicalHistory(product, null);
    }
    
    public static Medical_History_gne__c createAndInsertMedicalHistory(String product, Id patientId)
    {
        Medical_History_gne__c medicalHistory = createMedicalHistory(product, patientId);
        insert medicalHistory;
        return medicalHistory;
    }
    
    public static Medical_History_gne__c createAndInsertMedicalHistory(String product)
    {
        return createAndInsertMedicalHistory(product, null);
    }
    
    public static Patient_gne__c createPatient(String firstName, String lastName)
    {
        Patient_gne__c patient = new Patient_gne__c();
        patient.Name = lastName;
        patient.pat_first_name_gne__c = firstName;
        return patient;
    }
    
    public static Patient_gne__c createPatient()
    {
        return createPatient('John', 'Doe');
    }
    
    public static Patient_gne__c createAndInsertPatient(String firstName, String lastName)
    {
        Patient_gne__c patient = createPatient(firstName, lastName);
        insert patient;
        return patient;
    }
    
    public static Patient_gne__c createAndInsertPatient()
    {
        return createAndInsertPatient('John', 'Doe');
    }
    /*
    public static User createUser(String profileName, String domain, Id relatedContactId, String roleName)
    {
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = :profileName];
        if (userProfile == null)
        {
            return null;
        }
        if (domain == null)
        {
            domain = 'gene.com';
        }
        String userName = GlobalUtils.getRandomAlphaNumeric(10);
        User userData = relatedContactId != null ? new User(contactId = relatedContactId) : new User() ;
        userData.UserName = userName + '@' + domain;
        userData.LastName = userName + '@' + domain;
        userData.Email = userName + '@gene.com';
        userData.Alias = userName.substring(0, 7);
        userData.CommunityNickname = userName + '@' + domain;
        userData.LocaleSidKey = 'en_US';
        userData.TimeZoneSidKey = 'America/Los_Angeles';
        userData.EmailEncodingKey = 'UTF-8';
        userData.LanguageLocaleKey = 'en_US';
        userData.ProfileId = userProfile.Id;
        if(roleName != null){
            UserRole usrRole = [SELECT Id FROM UserRole WHERE Name = :roleName];
            userData.UserRole = usrRole;
        }
        return userData;
    }
    */
    
    public static User createUser(String profileName, String domain, Id relatedContactId)
    {
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = :profileName];
        if (userProfile == null)
        {
            return null;
        }
        if (domain == null)
        {
            domain = 'gene.com';
        }
        String userName = GlobalUtils.getRandomAlphaNumeric(10);
        User userData = relatedContactId != null ? new User(contactId = relatedContactId) : new User() ;
        userData.UserName = userName + '@' + domain;
        userData.LastName = userName + '@' + domain;
        userData.Email = userName + '@gene.com';
        userData.Alias = userName.substring(0, 7);
        userData.CommunityNickname = userName + '@' + domain;
        userData.LocaleSidKey = 'en_US';
        userData.TimeZoneSidKey = 'America/Los_Angeles';
        userData.EmailEncodingKey = 'UTF-8';
        userData.LanguageLocaleKey = 'en_US';
        userData.ProfileId = userProfile.Id;
        return userData;
    }
    
    public static User createUser(String profileName, String domain)
    {
        return createUser(profileName, domain, null);
    }
    
    public static User createUser(String profileName)
    {
        return createUser(profileName, null, null);
    }
    
    public static User createAndInsertUser(String profileName, String domain, Id relatedContactId)
    {
        User userData = createUser(profileName, domain, relatedContactId);
        insert userData;
        return userData;
    }
    
    public static User createAndInsertUser(String profileName, String domain)
    {
        User userData = createUser(profileName, domain);
        insert userData;
        return userData;
    }
    
    public static User createAndInsertUser(String profileName)
    {
        User userData = createUser(profileName);
        insert userData;
        return userData;
    }
    
    public static void insertTestProductFranchises(Map<String, String> productToFranchise)
    {
        List<GNE_CM_Product_Franchise__c> settings = new List<GNE_CM_Product_Franchise__c>();
        for (String prod : productToFranchise.keySet())
        {
            settings.add(new GNE_CM_Product_Franchise__c(Name = prod, Product__c = prod, Product_Franchise__c = productToFranchise.get(prod)));
        }
        insert settings;
    }

    public static GNE_CM_DDS_Service_Eligibility__c createDdsServiceEligibility(ICD9_Code_gne__c icd9, String productName, String biApproved, String appealService, String cafService, String compendiaListed, String copayCardService, String fdaApproved, String starterService, Integer minAge, Integer maxAge)
    {
        return createDdsServiceEligibility(icd9, productName, biApproved, appealService, cafService, compendiaListed, copayCardService, fdaApproved, starterService, minAge, maxAge, 'No');
    }

 	public static GNE_CM_DDS_Service_Eligibility__c createDdsServiceEligibility(ICD9_Code_gne__c icd9, String productName, String biApproved, String appealService, String cafService, String compendiaListed, String copayCardService, String fdaApproved, String starterService, Integer minAge, Integer maxAge, String infCopayCardService)
    {
		GNE_CM_DDS_Service_Eligibility__c dds1 = new GNE_CM_DDS_Service_Eligibility__c();	
		//ICD09
		dds1.ICD9_Code__c = icd9 != null ? icd9.id : null;	
		//Product related
      	dds1.Product__c = productName;
		dds1.BI_Approved__c = biApproved;
		dds1.Appeal_Service__c = appealService;
		dds1.CAF_Service__c = cafService;
		dds1.Compendia_Listed__c = compendiaListed;
        dds1.Compendia_listed_Date__c = compendiaListed=='Yes' ? system.today() : null;
		dds1.Copay_Card_Service__c = copayCardService;
        dds1.Copay_Infusion_Card_Service__c = infCopayCardService;
		dds1.FDA_Approved__c = fdaApproved;
        dds1.FDA_Approved_Date__c = fdaApproved=='Yes' ? system.today() : null;
		dds1.Starter_Service__c = starterService;
		//Patient related
      	dds1.Min_Age__c = minAge;
      	dds1.Max_Age__c = maxAge;
      	dds1.Change_Notes__c = 'test_change_notes';
      	return dds1;
	}
    
    public class BenefitInvestigationData
    {
        public Account payer { get; set; }        
        public User specialist { get; set; }
        public Insurance_gne__c insurance { get; set; }
        public Benefit_Investigation_gne__c benefitInvestigation { get; set; }    
    }
    
    public class CaseData
    {
        public Patient_gne__c patient { get; set; }
        public ICD9_Code_gne__c icd9 { get; set; }
        public Medical_History_gne__c medicalHistory { get; set; }
        public User caseManager { get; set; }
        public Case caseObj { get; set; }
        public Account prescriber { get; set; }
        public Insurance_gne__c insurance { get; set; }
    }
    
    public static Case setDefaultDDSFIelds(Case caseObj) 
    {
    	caseObj.DDS_Appeal_Eligible_gne__c = false;
		caseObj.DDS_Appeal_Override_gne__c = false;
		caseObj.DDS_Appeal_Request_gne__c = false;
		caseObj.DDS_Appeal_Outcome_gne__c = null;
		caseObj.DDS_BI_Eligible_gne__c = false;
		caseObj.DDS_BI_Override_gne__c = false;
		caseObj.DDS_BI_Request_gne__c = false;
		caseObj.DDS_BI_Outcome_gne__c = null;
		caseObj.DDS_Copay_Refer_Eligible_gne__c = false;
		caseObj.DDS_Copay_Refer_Override_gne__c = false;
		caseObj.DDS_Copay_Refer_Request_gne__c = false;
		caseObj.DDS_Copay_Refer_Outcome_gne__c = null;
		caseObj.DDS_Copay_Card_Eligible_gne__c = false;
		caseObj.DDS_Copay_Card_Override_gne__c = false;
		caseObj.DDS_Copay_Card_Request_gne__c = false;
		caseObj.DDS_Copay_Card_Outcome_gne__c = null;

		caseObj.DDS_Starter_Eligible_gne__c = false;
		caseObj.DDS_Starter_Override_gne__c = false;
		caseObj.DDS_Starter_Request_gne__c = false;
		caseObj.DDS_Starter_Outcome_gne__c = null;
        
        caseObj.DDS_GES_Request_gne__c = false;
		caseObj.DDS_GES_Outcome_gne__c = null;
		caseObj.DDS_GATCF_Request_gne__c = false;
		caseObj.DDS_GATCF_Outcome_gne__c = null;
        
        caseObj.DDS_Override_Comments_gne__c = 'Test changes';
		
    	return caseObj;
    }
    public static Case setAllowAllDDSFIelds(Case caseObj) 
    {
		caseObj.DDS_Appeal_Override_gne__c = true;
		caseObj.DDS_Appeal_Request_gne__c = true;
		caseObj.DDS_Appeal_Outcome_gne__c = 'Service Provided';

		caseObj.DDS_BI_Override_gne__c = true;
		caseObj.DDS_BI_Request_gne__c = true;
		caseObj.DDS_BI_Outcome_gne__c = 'Service Provided';

		caseObj.DDS_Copay_Refer_Override_gne__c = true;
		caseObj.DDS_Copay_Refer_Request_gne__c = true;
		caseObj.DDS_Copay_Refer_Outcome_gne__c = 'Service Provided';

		caseObj.DDS_Copay_Card_Override_gne__c = true;
		caseObj.DDS_Copay_Card_Request_gne__c = true;
		caseObj.DDS_Copay_Card_Outcome_gne__c = 'Service Provided';

		caseObj.DDS_Starter_Override_gne__c = true;
		caseObj.DDS_Starter_Request_gne__c = true;
		caseObj.DDS_Starter_Outcome_gne__c = 'Service Provided';     
		
        caseObj.DDS_Override_Comments_gne__c = 'Test changes';
        
    	return caseObj;
    }
    
    public static void disableDDSFunctionality() 
    {
		GNE_CM_DDS_Settings__c setting = GNE_CM_DDS_Settings__c.getOrgDefaults();
		if (setting == null) 
		{
			setting = new GNE_CM_DDS_Settings__c();
		}
		setting.Functionality_Disabled__c = true;
		upsert setting;
    }
}