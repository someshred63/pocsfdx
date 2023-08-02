/*************************************************************************
Name : TestMyPreferredAccountsController
Author : Neha Jain, (Appirio Offshore)
Date : 15th Jan, 2010
Usage : This class is used to test class MyPreferredAccountsController.
**************************************************************************/
@isTest
   private class TestMyPreferredAccountsController{

   @isTest
   private static void TestMyPreferredAccountsControllerHCPS(){
       MyPreferredAccountsController controller = new MyPreferredAccountsController();
       List<SelectOption> allViewType = controller.allViewType;
       controller.selectedViewType = 'My HCPs';
       controller.doSorting();

       system.assertequals('Account Name', controller.getObjectLabel('Account_vod__c','Name'));

       string sortDirection = 'asc';
       String sortDirectionImageSrc = '/img/sort_' + sortDirection + '_arrow.gif';
       controller.sortDirection  = sortDirection;
       system.assertequals(sortDirectionImageSrc , controller.sortDirectionImageSrc);


   }

   @isTest
   private static void TestMyPreferredAccountsControllerHCOS(){
       MyPreferredAccountsController controller = new MyPreferredAccountsController();
       List<SelectOption> allViewType = controller.allViewType;
       controller.selectedViewType = 'My HCOs';
       controller.doPaging();
       system.assertequals('Account Name', controller.getObjectLabel('Account_vod__c','Name'));

       string sortDirection = 'asc';
       String sortDirectionImageSrc = '/img/sort_' + sortDirection + '_arrow.gif';
       controller.sortDirection  = sortDirection;
       system.assertequals(sortDirectionImageSrc , controller.sortDirectionImageSrc);
       system.assertequals('Account Name', controller.getReferenceLabel('Account Name'));
       system.assertequals('Name', controller.getReferenceLabel('Name'));
       List<String> lstValue = new List<String>();
       lstValue.add('Account');
       MyPreferredAccountsController.childObjects childObject = new MyPreferredAccountsController.childObjects(lstValue);
   }

   @isTest
   private static void TestMyPreferredAccountsUserTerritory(){
       List<UserTerritory2Association>  listUserTerritory = [Select Territory2Id, UserId from UserTerritory2Association  where Territory2Id != null and UserId != null limit 1];
       if(listUserTerritory.size()>0){
           User testUser = new User(Id = listUserTerritory[0].UserId);
           system.runAs(testUser){
               MyPreferredAccountsController controller = new MyPreferredAccountsController();
               controller.selectedViewType = 'My HCOs';
               controller.SearchOnChangeType();
           }
       }
   }
}