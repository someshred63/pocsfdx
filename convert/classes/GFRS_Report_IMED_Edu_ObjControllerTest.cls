/**
* @author GFRS Dev Team
* @date 21/07/2014
* @description GFRS_Report_IMED_Edu_ObjControllerTest class - test class for GFRS_Report_IMED_Edu_ObjController
*/

@isTest
public with sharing class GFRS_Report_IMED_Edu_ObjControllerTest {

    public class TestSetting {

        public List<GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest> listToSort { get; set; }
        public GFRS_Report_IMED_Edu_ObjController controller { get; set; }
        public GFRS_Funding_Request__c request { get; set; }

        public TestSetting() {
            GFRS_Funding_Request__c req = createIMEDRequest();
            PageReference pageReference = Page.GFRS_Report_IMED_Edu_Obj;
            Test.setCurrentPage(pageReference);

            ApexPages.StandardController std = new ApexPages.StandardController(req);
            controller = new GFRS_Report_IMED_Edu_ObjController(std);
            request = req;
        }

        public GFRS_Funding_Request__c createIMEDRequest() {
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

            GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestApplicationStep(organizationId, localizationId);
            request.Therapeutic_Area__c = 'Juvenile Rheumatoid Arthritis';
            request.Funding_Type__c = 'Independent Medical Education';
            request.Date_Submitted__c = Date.today();
            request.Educational_Objectives__c = 'Test objective';
            request.Total_of_Expected_Learners__c = 100;

            update request;
            return request;
        }

        public void setTherapeuticAreas() {
            Schema.DescribeFieldResult result = GFRS_Funding_Request__c.Therapeutic_Area__c.getDescribe();

            for (PicklistEntry v : result.getPicklistValues()) {
                controller.therapeuticAreaSelected.add(v.getValue());
            }
        }

        public void generateSampleData(String sortByField, String sortOrder) {
            listToSort = new List<GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest>();
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('bbb', 1, 1, 1, 'bbb', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('aaa', 2, 2, 2, 'aaa', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('fac', 3, 3, 3, 'ccc', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('dad', 4, 4, 4, 'ddd', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('aab', 5, 5, 5, 'eee', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('fff', 6, 6, 6, 'fff', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('ffa', 7, 7, 7, 'ggg', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('hhh', 8, 8, 8, 'hhh', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('iii', 9, 9, 9, 'iii', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('jja', 10, 10, 10, 'jja', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('jjb', 11, 11, 11, 'jjb', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('jjd', 12, 12, 12, 'jjc', sortOrder, sortByField));
            listToSort.add(new GFRS_Report_IMED_Edu_ObjController.HelperFundingRequest('jjc', 13, 13, 13, 'jjd', sortOrder, sortByField));

        }
    }
    static testMethod void checkSortingAscDescBydiseaseState() {
        TestSetting t = new TestSetting();

        t.generateSampleData('DiseaseState', 'DESC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].diseaseState, 'jjd', 'While sorting descending jjd should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].diseaseState, 'aaa', 'While sorting descending aaa should be last element');

        t.generateSampleData('DiseaseState', 'ASC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].diseaseState, 'aaa', 'While sorting ascendign aaa should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].diseaseState, 'jjd', 'While sorting ascendign jjd should be last element');
    }

    static testMethod void checkSortingAscDescByeducationalObjectives() {
        TestSetting t = new TestSetting();

        t.generateSampleData('EducationalObjective', 'DESC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].educationalObjectives, 'jjd', 'While sorting descending jjd should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].educationalObjectives, 'aaa', 'While sorting descending aaa should be last element');

        t.generateSampleData('EducationalObjective', 'ASC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].educationalObjectives, 'aaa', 'While sorting ascendign aaa should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].educationalObjectives, 'jjd', 'While sorting ascendign jjd should be last element');
    }

    static testMethod void checkSortingAscDescByApprovedGrants() {
        TestSetting t = new TestSetting();

        t.generateSampleData('ApprovedGrants', 'DESC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].splitNumber, 13, 'While sorting descending 13 should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].splitNumber, 1, 'While sorting descending 1 should be last element');

        t.generateSampleData('ApprovedGrants', 'ASC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].splitNumber, 1, 'While sorting ascendign 1 should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].splitNumber, 13, 'While sorting ascendign 13 should be last element');
    }

    static testMethod void checkSortingAscDescByEstimatedAttendees() {
        TestSetting t = new TestSetting();

        t.generateSampleData('EstimatedAttendees', 'DESC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].splitNumber, 13, 'While sorting descending 13 should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].splitNumber, 1, 'While sorting descending 1 should be last element');

        t.generateSampleData('EstimatedAttendees', 'ASC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].splitNumber, 1, 'While sorting ascendign 1 should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].splitNumber, 13, 'While sorting ascendign 13 should be last element');
    }

    static testMethod void checkSortingAscDescByTotalGrantsGrants() {
        TestSetting t = new TestSetting();

        t.generateSampleData('TotalGrants', 'DESC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].numberOfTables, 13, 'While sorting descending 13 should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].numberOfTables, 1, 'While sorting descending 1 should be last element');

        t.generateSampleData('TotalGrants', 'ASC');
        t.listToSort.sort();
        system.assertEquals(t.listToSort[0].numberOfTables, 1, 'While sorting ascendign 1 should be first element');
        system.assertEquals(t.listToSort[t.listToSort.size() - 1].numberOfTables, 13, 'While sorting ascendign 13 should be last element');
    }

    static testMethod void checkPageFirstTimeVisit() {
        TestSetting t = new TestSetting();

        //check default request
        System.assertEquals(t.request.Id, t.controller.request.Id);

        //check picklist for Therapeutics Areas
        Schema.DescribeFieldResult result = GFRS_Funding_Request__c.Therapeutic_Area__c.getDescribe();
        Integer pickListSize = result.getPicklistValues().size();
        System.assertEquals(pickListSize, t.controller.getTherapeuticArea().size());
        System.assertEquals(pickListSize, t.controller.getLeftSelectOptions().size());

        //check default sorting
        System.assertEquals('', t.controller.therapeuticAreaSelectedString);
        System.assertEquals('DiseaseState', t.controller.sortExpression);
        System.assertEquals('ASC', t.controller.getSortDirection());
        t.controller.setSortDirection('DESC');
        System.assertEquals('DESC', t.controller.getSortDirection());
        t.controller.sortExpression = 'DESC';
        t.controller.doSort();
        System.assertEquals('ASC', t.controller.getSortDirection());
    }

    static testMethod void checkReportHeaderAndData() {
        TestSetting t = new TestSetting();

        //check default report header
        System.assert(!t.controller.getReportHeader().equals(''));
        //check no data report
        System.assertEquals('<tr><td>No data found.</td></tr>', t.controller.getReportData()[0]);

        t.generateSampleData('DiseaseState', 'DESC');
        t.controller.eduObjsList = t.listToSort;

        System.assertEquals(t.listToSort.size(), t.controller.getReportData().size());
    }

    static testMethod void checkExportDetails() {
        TestSetting t = new TestSetting();

        //check for messages on page
        t.controller.dateSubmitted = '';
        t.controller.closedDate = '';
        t.controller.exportDetails();
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));

        //check for report page generate
        t.generateSampleData('DiseaseState', 'DESC');
        t.setTherapeuticAreas();
        t.controller.eduObjsList = t.listToSort;
        t.controller.dateSubmitted = '11/6/2011';
        t.controller.closedDate = Date.today().format();
        System.assert(t.controller.exportDetails() != null);
    }

    static testMethod void checkEduObjectivesData() {
        TestSetting t = new TestSetting();
        t.setTherapeuticAreas();

        System.assert(t.controller.eduObjectivesData() == null);
    }
}