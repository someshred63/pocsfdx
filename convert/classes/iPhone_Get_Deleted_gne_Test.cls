@isTest
public class iPhone_Get_Deleted_gne_Test {

    @isTest(seeAllData=true)
    static  void testGetDeletedOTRRecordsRest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/iPhoneGetDeletedRecords';  
        req.httpMethod = 'POST';
        req.addHeader('lastSyncDate', '2014-12-01 17:13:07');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            iPhone_Commons_gne.RestResponse resp=iPhone_Get_Deleted_gne.executeRequest('2014-12-01 17:13:07', '', null);
        Test.stopTest();
        System.debug(LoggingLevel.ERROR,'Response: '+resp);
    }
    
}