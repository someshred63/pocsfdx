@isTest
public with sharing class CFAR_Home_Controller_Test {
    @isTest
    static void alertForToday() {
        User testUser = CFAR_TestUtils.createTestAverageUser();

        System.runAs(testUser) {
            Test.startTest();
            CFAR_Contact_gne__c primaryContact = new CFAR_Contact_gne__c(User_ref_gne__c = testUser.Id,First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
            insert primaryContact;
            Date d = Date.today();
            CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
            t1.Genentech_Primary_Contact_ref_gne__c = primaryContact.Id;
            insert t1;
            CFAR_Parent_Organization_gne__c parentOrganization = CFAR_DataFactory.createParentOrganization();
            insert parentOrganization;
            CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrganization, 'Test');
            insert institution;
            CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
            insert contactAddress;
            CFAR_Contact_Address_JO_gne__c contactAddressJO = CFAR_DataFactory.createContactAddressJO(primaryContact, contactAddress);
            insert contactAddressJO;
            CFAR_Team_Member_gne__c teamMember = CFAR_DataFactory.createTeamMember(t1, 'Homer Simpson', contactAddressJO, 'CSM = Clinical Study Manager');
            teamMember.CFAR_Trial_ref_gne__c = t1.Id;
            teamMember.Alerts_gne__c = true;
            insert teamMember;
            CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(teamMember);
            insert budgetContract;
            CFAR_Budget_Contract_Type_gne__c budgetContractType = CFAR_DataFactory.createBudgetContractType();
            insert budgetContractType;
            CFAR_Budget_Contract_Tracking_gne__c budgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            budgetContractTracking.Contract_Expiry_Date_gne__c = d;
            insert budgetContractTracking;

            CFAR_Home_Controller homeController = new CFAR_Home_Controller();
            Test.stopTest();
            List<CFAR_Home_Controller.AlertWrapper> alert = homeController.createAlertWrappers();
            System.assertEquals('You have a Contract that will expire today.', String.valueOf(alert[0].alert));
            System.assert(alert.size() == 1);
        }
    }
    @isTest
    static void alertForTomorrow() {
        User testUser = CFAR_TestUtils.createTestAverageUser();

        System.runAs(testUser) {
            Test.startTest();
            CFAR_Contact_gne__c primaryContact = new CFAR_Contact_gne__c(User_ref_gne__c = testUser.Id,First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
            insert primaryContact;
            Date d = Date.today();
            CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
            t1.Genentech_Primary_Contact_ref_gne__c = primaryContact.Id;
            insert t1;
            CFAR_Parent_Organization_gne__c parentOrganization = CFAR_DataFactory.createParentOrganization();
            insert parentOrganization;
            CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrganization, 'Test');
            insert institution;
            CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
            insert contactAddress;
            CFAR_Contact_Address_JO_gne__c contactAddressJO = CFAR_DataFactory.createContactAddressJO(primaryContact, contactAddress);
            insert contactAddressJO;
            CFAR_Team_Member_gne__c teamMember = CFAR_DataFactory.createTeamMember(t1, 'Homer Simpson', contactAddressJO, 'CSM = Clinical Study Manager');
            teamMember.CFAR_Trial_ref_gne__c = t1.Id;
            teamMember.Alerts_gne__c = true;
            insert teamMember;
            CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(teamMember);
            insert budgetContract;
            CFAR_Budget_Contract_Type_gne__c budgetContractType = CFAR_DataFactory.createBudgetContractType();
            insert budgetContractType;
            CFAR_Budget_Contract_Tracking_gne__c budgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            budgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(1);
            insert budgetContractTracking;

            CFAR_Home_Controller homeController = new CFAR_Home_Controller();
            Test.stopTest();
            List<CFAR_Home_Controller.AlertWrapper> alert = homeController.createAlertWrappers();
            System.assertEquals('You have a Contract that will expire tomorrow.', String.valueOf(alert[0].alert));
            System.assert(alert.size() == 1);
        }
    }
    @isTest
    static void alertForYesterdayTest() {
        User testUser = CFAR_TestUtils.createTestAverageUser();

        System.runAs(testUser) {
            Test.startTest();
            CFAR_Contact_gne__c primaryContact = new CFAR_Contact_gne__c(User_ref_gne__c = testUser.Id,First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
            insert primaryContact;
            Date d = Date.today();
            CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
            t1.Genentech_Primary_Contact_ref_gne__c = primaryContact.Id;
            insert t1;
            CFAR_Parent_Organization_gne__c parentOrganization = CFAR_DataFactory.createParentOrganization();
            insert parentOrganization;
            CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrganization, 'Test');
            insert institution;
            CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
            insert contactAddress;
            CFAR_Contact_Address_JO_gne__c contactAddressJO = CFAR_DataFactory.createContactAddressJO(primaryContact, contactAddress);
            insert contactAddressJO;
            CFAR_Team_Member_gne__c teamMember = CFAR_DataFactory.createTeamMember(t1, 'Homer Simpson', contactAddressJO, 'CSM = Clinical Study Manager');
            teamMember.CFAR_Trial_ref_gne__c = t1.Id;
            teamMember.Alerts_gne__c = true;
            insert teamMember;
            CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(teamMember);
            insert budgetContract;
            CFAR_Budget_Contract_Type_gne__c budgetContractType = CFAR_DataFactory.createBudgetContractType();
            insert budgetContractType;
            CFAR_Budget_Contract_Tracking_gne__c budgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            budgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(-1);
            insert budgetContractTracking;

            CFAR_Home_Controller homeController = new CFAR_Home_Controller();
            Test.stopTest();
            List<CFAR_Home_Controller.AlertWrapper> alert = homeController.createAlertWrappers();
            System.assertEquals('You have a Contract that expired yesterday.', String.valueOf(alert[0].alert));
            System.assert(alert.size() == 1);
        }
    }

    @isTest
    static void alertForMaximumValueOfTheInterval() {
        User testUser = CFAR_TestUtils.createTestAverageUser();

        System.runAs(testUser) {
            Test.startTest();
            CFAR_Contact_gne__c primaryContact = new CFAR_Contact_gne__c(User_ref_gne__c = testUser.Id,First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
            insert primaryContact;
            Date d = Date.today();
            CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
            t1.Genentech_Primary_Contact_ref_gne__c = primaryContact.Id;
            insert t1;
            CFAR_Parent_Organization_gne__c parentOrganization = CFAR_DataFactory.createParentOrganization();
            insert parentOrganization;
            CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrganization, 'Test');
            insert institution;
            CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
            insert contactAddress;
            CFAR_Contact_Address_JO_gne__c contactAddressJO = CFAR_DataFactory.createContactAddressJO(primaryContact, contactAddress);
            insert contactAddressJO;
            CFAR_Team_Member_gne__c teamMember = CFAR_DataFactory.createTeamMember(t1, 'Homer Simpson', contactAddressJO, 'CSM = Clinical Study Manager');
            teamMember.CFAR_Trial_ref_gne__c = t1.Id;
            teamMember.Alerts_gne__c = true;
            insert teamMember;
            CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(teamMember);
            insert budgetContract;
            CFAR_Budget_Contract_Type_gne__c budgetContractType = CFAR_DataFactory.createBudgetContractType();
            insert budgetContractType;
            CFAR_Budget_Contract_Tracking_gne__c budgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            budgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(30);
            insert budgetContractTracking;

            CFAR_Home_Controller homeController = new CFAR_Home_Controller();
            Test.stopTest();
            List<CFAR_Home_Controller.AlertWrapper> alert = homeController.createAlertWrappers();
            System.assertEquals('You have a Contract that will expire in 30 days.', String.valueOf(alert[0].alert));
            System.assert(alert.size() == 1);
        }
    }
    @isTest
    static void alertForMinimumValueOfTheInterval() {
        User testUser = CFAR_TestUtils.createTestAverageUser();

        System.runAs(testUser) {
            Test.startTest();
            CFAR_Contact_gne__c primaryContact = new CFAR_Contact_gne__c(User_ref_gne__c = testUser.Id,First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
            insert primaryContact;
            Date d = Date.today();
            CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
            t1.Genentech_Primary_Contact_ref_gne__c = primaryContact.Id;
            insert t1;
            CFAR_Parent_Organization_gne__c parentOrganization = CFAR_DataFactory.createParentOrganization();
            insert parentOrganization;
            CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrganization, 'Test');
            insert institution;
            CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
            insert contactAddress;
            CFAR_Contact_Address_JO_gne__c contactAddressJO = CFAR_DataFactory.createContactAddressJO(primaryContact, contactAddress);
            insert contactAddressJO;
            CFAR_Team_Member_gne__c teamMember = CFAR_DataFactory.createTeamMember(t1, 'Homer Simpson', contactAddressJO, 'CSM = Clinical Study Manager');
            teamMember.CFAR_Trial_ref_gne__c = t1.Id;
            teamMember.Alerts_gne__c = true;
            insert teamMember;
            CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(teamMember);
            insert budgetContract;
            CFAR_Budget_Contract_Type_gne__c budgetContractType = CFAR_DataFactory.createBudgetContractType();
            insert budgetContractType;
            CFAR_Budget_Contract_Tracking_gne__c budgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            budgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(-30);
            insert budgetContractTracking;

            CFAR_Home_Controller homeController = new CFAR_Home_Controller();
            Test.stopTest();
            List<CFAR_Home_Controller.AlertWrapper> alert = homeController.createAlertWrappers();
            System.assertEquals('You had a Contract expired 30 days ago.', String.valueOf(alert[0].alert));
            System.assert(alert.size() == 1);
        }
    }
    @isTest
    static void alertForValueBeforeTheInterval() {
        User testUser = CFAR_TestUtils.createTestAverageUser();

        System.runAs(testUser) {
            Test.startTest();
            CFAR_Contact_gne__c primaryContact = new CFAR_Contact_gne__c(User_ref_gne__c = testUser.Id,First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
            insert primaryContact;
            Date d = Date.today();
            CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
            t1.Genentech_Primary_Contact_ref_gne__c = primaryContact.Id;
            insert t1;
            CFAR_Parent_Organization_gne__c parentOrganization = CFAR_DataFactory.createParentOrganization();
            insert parentOrganization;
            CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrganization, 'Test');
            insert institution;
            CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
            insert contactAddress;
            CFAR_Contact_Address_JO_gne__c contactAddressJO = CFAR_DataFactory.createContactAddressJO(primaryContact, contactAddress);
            insert contactAddressJO;
            CFAR_Team_Member_gne__c teamMember = CFAR_DataFactory.createTeamMember(t1, 'Homer Simpson', contactAddressJO, 'CSM = Clinical Study Manager');
            teamMember.CFAR_Trial_ref_gne__c = t1.Id;
            teamMember.Alerts_gne__c = true;
            insert teamMember;
            CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(teamMember);
            insert budgetContract;
            CFAR_Budget_Contract_Type_gne__c budgetContractType = CFAR_DataFactory.createBudgetContractType();
            insert budgetContractType;
            CFAR_Budget_Contract_Tracking_gne__c budgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            budgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(-31);
            insert budgetContractTracking;

            CFAR_Home_Controller homeController = new CFAR_Home_Controller();
            Test.stopTest();
            List<CFAR_Home_Controller.AlertWrapper> alert = homeController.createAlertWrappers();
            System.assert(alert.isEmpty());
        }
    }
    @isTest
    static void alertForValueAfterTheInterval() {
        User testUser = CFAR_TestUtils.createTestAverageUser();

        System.runAs(testUser) {
            Test.startTest();
            CFAR_Contact_gne__c primaryContact = new CFAR_Contact_gne__c(User_ref_gne__c = testUser.Id,First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
            insert primaryContact;
            Date d = Date.today();
            CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
            t1.Genentech_Primary_Contact_ref_gne__c = primaryContact.Id;
            insert t1;
            CFAR_Parent_Organization_gne__c parentOrganization = CFAR_DataFactory.createParentOrganization();
            insert parentOrganization;
            CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrganization, 'Test');
            insert institution;
            CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
            insert contactAddress;
            CFAR_Contact_Address_JO_gne__c contactAddressJO = CFAR_DataFactory.createContactAddressJO(primaryContact, contactAddress);
            insert contactAddressJO;
            CFAR_Team_Member_gne__c teamMember = CFAR_DataFactory.createTeamMember(t1, 'Homer Simpson', contactAddressJO, 'CSM = Clinical Study Manager');
            teamMember.CFAR_Trial_ref_gne__c = t1.Id;
            teamMember.Alerts_gne__c = true;
            insert teamMember;
            CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(teamMember);
            insert budgetContract;
            CFAR_Budget_Contract_Type_gne__c budgetContractType = CFAR_DataFactory.createBudgetContractType();
            insert budgetContractType;
            CFAR_Budget_Contract_Tracking_gne__c budgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            budgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(31);
            insert budgetContractTracking;

            CFAR_Home_Controller homeController = new CFAR_Home_Controller();
            Test.stopTest();
            List<CFAR_Home_Controller.AlertWrapper> alert = homeController.createAlertWrappers();
            System.assert(alert.isEmpty());
        }
    }
       
    @isTest
    static void alertForMultipleContractTrackings() {
        User testUser = CFAR_TestUtils.createTestAverageUser();

        System.runAs(testUser) {
            Test.startTest();
            CFAR_Contact_gne__c primaryContact = new CFAR_Contact_gne__c(User_ref_gne__c = testUser.Id,First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
            insert primaryContact;
            Date d = Date.today();
            CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
            t1.Genentech_Primary_Contact_ref_gne__c = primaryContact.Id;
            insert t1;
            CFAR_Parent_Organization_gne__c parentOrganization = CFAR_DataFactory.createParentOrganization();
            insert parentOrganization;
            CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrganization, 'Test');
            insert institution;
            CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
            insert contactAddress;
            CFAR_Contact_Address_JO_gne__c contactAddressJO = CFAR_DataFactory.createContactAddressJO(primaryContact, contactAddress);
            insert contactAddressJO;
            CFAR_Team_Member_gne__c teamMember = CFAR_DataFactory.createTeamMember(t1, 'Homer Simpson', contactAddressJO, 'CSM = Clinical Study Manager');
            teamMember.CFAR_Trial_ref_gne__c = t1.Id;
            teamMember.Alerts_gne__c = true;
            insert teamMember;
            CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(teamMember);
            insert budgetContract;
            CFAR_Budget_Contract_Type_gne__c budgetContractType = CFAR_DataFactory.createBudgetContractType();
            insert budgetContractType;
            CFAR_Budget_Contract_Tracking_gne__c budgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            budgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(31);
            insert budgetContractTracking;
            CFAR_Budget_Contract_Tracking_gne__c anotherBudgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            anotherBudgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(13);
            insert anotherBudgetContractTracking;

            CFAR_Home_Controller homeController = new CFAR_Home_Controller();
            Test.stopTest();
            List<CFAR_Home_Controller.AlertWrapper> alert = homeController.createAlertWrappers();
            System.assertEquals('You have a Contract that will expire in 13 days.', String.valueOf(alert[0].alert));
            System.assert(alert.size() == 1);
        }
    }
    @isTest
    static void emptyAlertForMultipleContractTrackings() {
        User testUser = CFAR_TestUtils.createTestAverageUser();

        System.runAs(testUser) {
            Test.startTest();
            CFAR_Contact_gne__c primaryContact = new CFAR_Contact_gne__c(User_ref_gne__c = testUser.Id,First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
            insert primaryContact;
            Date d = Date.today();
            CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
            t1.Genentech_Primary_Contact_ref_gne__c = primaryContact.Id;
            insert t1;
            CFAR_Parent_Organization_gne__c parentOrganization = CFAR_DataFactory.createParentOrganization();
            insert parentOrganization;
            CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrganization, 'Test');
            insert institution;
            CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
            insert contactAddress;
            CFAR_Contact_Address_JO_gne__c contactAddressJO = CFAR_DataFactory.createContactAddressJO(primaryContact, contactAddress);
            insert contactAddressJO;
            CFAR_Team_Member_gne__c teamMember = CFAR_DataFactory.createTeamMember(t1, 'Homer Simpson', contactAddressJO, 'CSM = Clinical Study Manager');
            teamMember.CFAR_Trial_ref_gne__c = t1.Id;
            teamMember.Alerts_gne__c = true;
            insert teamMember;
            CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(teamMember);
            insert budgetContract;
            CFAR_Budget_Contract_Type_gne__c budgetContractType = CFAR_DataFactory.createBudgetContractType();
            insert budgetContractType;
            CFAR_Budget_Contract_Tracking_gne__c budgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            budgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(13);
            insert budgetContractTracking;
            CFAR_Budget_Contract_Tracking_gne__c anotherBudgetContractTracking = CFAR_DataFactory.createBudgetContractTracking(budgetContract, budgetContractType, 1000.00);
            anotherBudgetContractTracking.Contract_Expiry_Date_gne__c = d.addDays(31);
            insert anotherBudgetContractTracking;

            CFAR_Home_Controller homeController = new CFAR_Home_Controller();
            Test.stopTest();
            List<CFAR_Home_Controller.AlertWrapper> alert = homeController.createAlertWrappers();
            System.assert(alert.isEmpty());
        }
    }
}