@isTest 
public class GT_ChangeDataCaptureMDMHelperTest {
    static testMethod void MDMSyncActionTest1() {
        Account a = new Account(Name='testacc');
        insert a;
        List<account> lAccounts = new   List<account>();
        lAccounts.add(a);
        GT_ChangeDataCaptureMDMHelper.ActionRequest  ar = 
        new  GT_ChangeDataCaptureMDMHelper.ActionRequest();
        ar.newRecord= a;
        ar.eventType ='CREATED';
        ar.objectType='Account';
 
      List<GT_ChangeDataCaptureMDMHelper.ActionRequest> lreq = new List<GT_ChangeDataCaptureMDMHelper.ActionRequest>();
      lreq.add(ar);  
      GT_ChangeDataCaptureMDMHelper.MDMSyncAction(
            lreq
        );
     }

     static testMethod void MDMSyncActionTest2() {
        Account a = new Account(Name='testacc');
        insert a;
        List<account> lAccounts = new   List<account>();
        lAccounts.add(a);
        GT_ChangeDataCaptureMDMHelper.ActionRequest  ar = 
        new  GT_ChangeDataCaptureMDMHelper.ActionRequest();
        ar.newRecord= null; 
        ar.recordId= a.Id; 
        ar.eventType ='CREATED';
       
       
      List<GT_ChangeDataCaptureMDMHelper.ActionRequest> lreq = new List<GT_ChangeDataCaptureMDMHelper.ActionRequest>();
      lreq.add(ar);
      GT_ChangeDataCaptureMDMHelper.MDMSyncAction(
            lreq
        );
     }

     
     static testMethod void createDataChangeEventForMDMTest() {
        Account a = new Account(lastName='unverified');
        insert a;
        List<account> lAccounts = new   List<account>();
        lAccounts.add(a);
        GT_ChangeDataCaptureMDMHelper.createDataChangeEventForMDM(
            lAccounts,
            null,
            'CREATED',
            'Account'
        );
     }

     static testMethod void createDataChangeEventForMDMTest6() {
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='abc', firstname='abc', Account=a);
        insert c;
        List<Contact> lContacts = new   List<Contact>();
        lContacts.add(c);
        GT_ChangeDataCaptureMDMHelper.createDataChangeEventForMDM(
            lContacts,
            null,
            'CREATED',
            'Contact'
        );
     }

     static testMethod void createDataChangeEventForMDMTest3() {
        Account a = new Account(lastName='testacc');
        insert a;
        Map<Id, SObject> oldItemsMap = new   Map<Id, SObject>();
        oldItemsMap.put(a.Id,a);
        List<account> lAccounts = new   List<account>();
        a.lastName='updatedname';
        lAccounts.add(a);
       
        GT_ChangeDataCaptureMDMHelper.createDataChangeEventForMDM(
            lAccounts,
            oldItemsMap,
            'UPDATED',
            'Account'
        );
     }

     static testMethod void createDataChangeEventForMDMTest2() {
        Account a = new Account(lastName='testacc');
        insert a;
        Map<Id, SObject> oldItemsMap = new   Map<Id, SObject>();
        oldItemsMap.put(a.Id,a);
        List<account> lAccounts = new   List<account>();
        a.GT_Reltio_ID__c='abc';
        lAccounts.add(a);
       
        GT_ChangeDataCaptureMDMHelper.createDataChangeEventForMDM(
            lAccounts,
            oldItemsMap,
            'UPDATED',
            'Account'
        );
     }

     static testMethod void createDataChangeEventForMDMTest4() {
        Account a = new Account(lastName='testacc',GT_Reltio_ID__c='abc');
        insert a;
       
        List<account> lAccounts = new   List<account>();
        lAccounts.add(a);

        Map<Id, SObject> oldItemsMap = new   Map<Id, SObject>();
        oldItemsMap.put(a.Id,a);
       
        GT_ChangeDataCaptureMDMHelper.createDataChangeEventForMDM(
            lAccounts,
            oldItemsMap,
            'DELETED',
            'Account'
        );
     }

     static testMethod void testGetNestedObjPayLoad() {

      GT_ChangeDataCaptureMDMHelper.request r = new  GT_ChangeDataCaptureMDMHelper.request();
      r.source='test';
      
      Account a = new Account(lastName='testacc',GT_Reltio_ID__c='abc');
        insert a;
        Map<Id, Map<String, List<GT_ChangeDataCaptureMDMHelper.request>>> mParentToNestedObj = new  Map<Id, Map<String, List<GT_ChangeDataCaptureMDMHelper.request>>> ();
        List<GT_ChangeDataCaptureMDMHelper.request> lr = new List<GT_ChangeDataCaptureMDMHelper.request>{r};
        Map<String, List<GT_ChangeDataCaptureMDMHelper.request>> m = new  Map<String, List<GT_ChangeDataCaptureMDMHelper.request>>{a.id=>lr};
        mParentToNestedObj.put(a.id,m );

        GT_ChangeDataCaptureMDMHelper.getNestedObjPayLoad(mParentToNestedObj);

     }

     @testSetup public static void setup(){
        GT_Data_Change_Capture_MDM_Setting__c setting = new GT_Data_Change_Capture_MDM_Setting__c();
        setting.SetupOwnerId=UserInfo.getOrganizationId();
        setting.Entity_Id_Field__c='Account::GT_Reltio_ID__c;';
        setting.MDMId_Field__c='Account::Id;';
        setting.MDMSourceId__c='testSrcId';
        
        setting.Unverified_Filter__c='Account::lastName:unverified;';
        insert setting;
     }

}