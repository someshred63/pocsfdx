/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-15
*  Project: FCR
*  Description: REST Webservice, used to retrieve list of FCR Days Plan Job Accountabilities for particular FCR.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/ListFcrJobAccountabilities/*')
global with sharing class GNE_FCR_ListFCR_JA_Webservice {
    @HttpGet
    global static GNE_FCR_Util.RestResponse doGet(){
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('ListFcrJobAccountabilities'));
            String fcrId = null;
            if(index >= 0){
                fcrId = req.requestURI.substring(index+1);
            }
            List<FCR_Daysplan_Job_Accountability_gne__c> result = new List<FCR_Daysplan_Job_Accountability_gne__c>();
            if(fcrId != null && fcrId != ''){
                result = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Display_Order_gne__c, FCR_Days_Plan_gne__c, Job_Accountability_Description_fcr__c, Job_Accountability_gne__c, Job_Accountability_Title_gne__c, LastModifiedById, LastModifiedDate, Rating_gne__c,Local_guid_gne__c from FCR_Daysplan_Job_Accountability_gne__c where FCR_Days_Plan_gne__c =:fcrId];
            }
            if(result!=null && result.size()>0)
            {
                String timestamp = req.params.get('TimeStamp');
            	if(timestamp != null && timestamp != ''){
	            	r.deltaCalculator = new GNE_FCR_Util.DeltaCalculator(timestamp);
	            }
                r.setRecords(result);
            }
            r.setSuccessStatus();
            return r;
        }
        catch(Exception ex){
            r.setErrorStatus(ex);
            return r;
        }
    }
}