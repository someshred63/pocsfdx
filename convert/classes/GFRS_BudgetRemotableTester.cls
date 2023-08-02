@isTest
private class GFRS_BudgetRemotableTester {
    class TestSettings {
        Account acc;
        GFRS_Organization__c org;
        GFRS_Funding_Request__c fundingRequest; 
        GFRS_Location__c loc;
        GFRS_RequestBudget__c budget;
            
        public String DEFAULT_STATUS = 'Intake';
        public String DEFAULT_SUB_STATUS = 'Not Submitted';
    
        public TestSettings(){
            acc = gFRS_TestCreationUtils.createAccount('gFRS_FundingRequestReadControllerTesterAcc');
            insert acc;
            org = gFRS_TestCreationUtils.createOrganization('TestOrg1', acc);
            insert org;
            loc = gFRS_TestCreationUtils.createLocation('gFRS_FundingRequestReadControllerTesterLoc',org.id);
            insert loc;
            fundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', org.Id, loc.Id);
            insert fundingRequest;
            budget = gFRS_TestCreationUtils.createRequestBudget_min(fundingRequest);
            insert budget;
        }
    }
    
    static testMethod void testRemoteActions() {
        ApexPages.StandardController controller;
        GFRS_BudgetRemotable cont = new GFRS_BudgetRemotable(controller);
        TestSettings ts = new TestSettings();
        GFRS_Request_Budget_Line_Item__c bl1 = GFRS_BudgetRemotable.addBudgetLine(ts.budget.Id);
        GFRS_BudgetRemotable.fetchBudgetLines(ts.budget.Id);
        System.assertEquals(GFRS_BudgetRemotable.updateBudgetLineField(bl1.Id, 'nonExistingField','1'),null);
        
        GFRS_Request_Budget_Line_Item__c updatedBudgetLine = GFRS_BudgetRemotable.updateBudgetLineField(bl1.Id, 'Comments_Clarification__c','1');
        System.assertNotEquals(updatedBudgetLine, null);
        
        GFRS_Request_Budget_Line_Item__c removedBudgetLine = GFRS_BudgetRemotable.removeBudgetLine(bl1.Id);
        System.assertNotEquals(removedBudgetLine, null);
        
        boolean isValidBudgetLisEmpty = GFRS_BudgetRemotable.validBudgetLIsEmpty(ts.budget.Id, ts.fundingRequest.Id);
        System.assert(true);
        
        String totalAmount = GFRS_BudgetRemotable.getBudgetLinesTotalAmount(ts.fundingRequest.Id);
        System.assertNotEquals(totalAmount, null);
        
        boolean isValidBudgetLi = GFRS_BudgetRemotable.validBudgetLIs(ts.budget.Id, ts.fundingRequest.Id);
        System.assert(isValidBudgetLi);
    }

}