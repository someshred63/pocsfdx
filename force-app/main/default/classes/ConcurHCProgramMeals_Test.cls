@isTest 
private class ConcurHCProgramMeals_Test{
    public static testmethod void testcaseConcurHCPProgramMeals(){
        ConcurHCPProgramMeals objTest = new ConcurHCPProgramMeals();
        PageReference pageTest = Page.ConcurHCPProgramMeals;
        String strURL = pageTest.getUrl();
        strUrl += 'Amount=100.00000000&ExpenseType=Business+Meal+with+HCPs&ExpKey=01025&ItemUrl=https%3A%2F%2Fimplementation.concursolutions.com%2Fapi%2Fexpense%2Fexpensereport%2Fv1.1%2Freport%2Fn%24pSkLiyn8QGYPcbcgpdabtDzif8WR%24svlt%2Fentry%2Fn6WTCxtvKKqya4s7MQOD8pBQvYGn6HVMI&ReportCreator=00570000001BnPy&ReportOwner=null&TransactionAmount=100.00000000&TransactionDate=2010-08-18&XUserID=628173%40roche.com';
        pageTest = new PageReference(strUrl);
        Test.setCurrentPageReference(pageTest);
        List<ConcurHCPProgramMeals.Result> listRes = new List<ConcurHCPProgramMeals.Result>();
        listRes = objTest.getresultItems();
        objTest.openPopup();
        objTest.closePopup();
        listRes[0].Selected = true;
        objTest.getExpenseAmount();
        objTest.SaveInfo();
    }
}