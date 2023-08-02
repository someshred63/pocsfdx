@isTest 
private class ConcurHCPMealController_Test{
    public static testmethod void testcaseConcurHCPMealController(){
        ConcurHCPMealController objTest = new ConcurHCPMealController();
        PageReference pageTest = Page.ConcurHCPMealsPage;
        String strURL = pageTest.getUrl();
        strUrl += '?Amount=100.00000000&ExpenseType=Business+Meal+with+HCPs&ExpKey=01025&ItemUrl=https://implementation.concursolutions.com/api/expense/expensereport/v1.1/report/n$pSkLiyn8QGYPcbcgpdabtDzif8WR$svlt/entry/n6WTCxtvKKqya4s7MQOD8pBQvYGn6HVMI&ReportCreator=00570000001BnPy&ReportOwner=00570000001BnPy&TransactionAmount=100.00000000&TransactionDate=2010-08-18&XUserID=628173@roche.com';
        pageTest = new PageReference(strUrl);
        Test.setCurrentPageReference(pageTest);
        List<ConcurHCPMealController.Results> listRes = new List<ConcurHCPMealController.Results>();
        listRes = objTest.getAllResults();
        objTest.openPopup();
        objTest.closePopup();
        listRes[0].Selected = true;
        objTest.getExpenseAmount();
        objTest.SaveInfo();
    }
}