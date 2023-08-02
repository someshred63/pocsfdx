@isTest

private class CheckwebenabledTest{

  public static testmethod void testwebaccounts() {
  
  Check_WebEnabled_Accounts checkacc=new Check_webEnabled_Accounts();
  List<Check_WebEnabled_Accounts.Web_Enabled>  wrapper=new List<Check_WebEnabled_Accounts.Web_Enabled>();
  
   wrapper=Check_WebEnabled_Accounts.getAccounts('01/01/2000');
   
   System.debug('size-->'+wrapper.size());
   for(integer i=0;i<wrapper.size();i++)
   {
     System.debug('Account Name-->'+wrapper[i].Name);
     System.debug('SAP_ID-->'+wrapper[i].SAP_ID);
     System.debug('IS_Web_Enabled-->'+wrapper[i].IS_Web_Enabled);
     System.debug('IsActive-->'+wrapper[i].IsActive);
   }
  
  
 }
 
 }