public class gFRS_Ltng_FetchReqController {
    
    @AuraEnabled
    public static list<GFRS_Funding_Request__c> getallRecords(Date myFromdate, Date myTodate, String myFundingList) {
        
        List<String> lstAlpha = myFundingList.split(';');
        
        System.debug('Funding Type : ' + lstAlpha);

        List<GFRS_Funding_Request__c> requestList = new List<GFRS_Funding_Request__c>();
        
        requestList = [SELECT Name, CreatedBy.Name, CreatedBy.Email FROM GFRS_Funding_Request__c where Funding_Type__c IN:lstAlpha AND Date_Submitted__c>=:myFromdate AND Date_Submitted__c<=:myTodate];
        system.debug('GFRS_Req_List : ' + requestList);
        
        return requestList;       
    }
}