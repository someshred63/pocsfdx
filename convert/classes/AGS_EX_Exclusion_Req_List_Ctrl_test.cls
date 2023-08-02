@isTest(seeAllData=false)
private class AGS_EX_Exclusion_Req_List_Ctrl_test{

    static testMethod void constructorTest(){
    	String listViewId;

    	Account a = new Account(
            AGS_EX_Exclusion_Status_base_gne__c='Not Checked',Firstname='Exclusion',Lastname = 'Check',PersonEmail='test@roche.com',
         	recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Professional_vod').getRecordTypeId()
        );
        insert a;
        insert new Contact(
            Firstname='Exclusion',
            Lastname = 'Check',
            Account = a,
            Email='test@roche.com'
        );
    	Address_vod__c add = new Address_vod__c(Account_vod__c=a.Id);
    	insert add;
    	AGS_EX_Exclusion_Utils.createRequest(a);

        String query = 'SELECT Name FROM AGS_EX_Exclusion_Request_gne__c LIMIT 1';
        ApexPages.StandardSetController acc = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        List<SelectOption> ListViews = acc.getListViewOptions();

        System.debug(ListViews);
        for(SelectOption w : ListViews ) {
          	if(w.getLabel() == 'Pending Exclusion Requests') {
               	ListViewId = w.getValue().left(15);
            }
        }

    	AGS_EX_Exclusion_Utils.getListViewId('AGS_EX_Exclusion_Request_gne__c', 'Pending Exclusion Requests');
        AGS_EX_Exclusion_Req_List_Controller ctrl = new AGS_EX_Exclusion_Req_List_Controller();

        System.assertEquals(ListViewId,ctrl.listViewId);

        AGS_EX_Exclusion_Utils.createRequest(a);
    }
}