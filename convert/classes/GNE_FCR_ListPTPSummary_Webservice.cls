/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-15
*  Project: FCR
*  Description: REST Webservice, used to retrieve list of FCR PTP Summary for particular FCR.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/ListPTPSummary/*')
global with sharing class GNE_FCR_ListPTPSummary_Webservice {
    @HttpGet
    global static GNE_FCR_Util.RestResponse doGet(){
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('ListPTPSummary'));
            String fcrId = null;
            if(index >= 0){
                fcrId = req.requestURI.substring(index+1);
            }
            List<FCR_PTP_Summary_gne__c> result = new List<FCR_PTP_Summary_gne__c>();
            if(fcrId != null && fcrId != ''){
                result = [select Id, Name, CreatedById, CreatedDate, Division_Product1_gne__c, Division_Product2_gne__c, Division_Product3_gne__c, FCR_Days_Plan_gne__c, Geography_Product1_gne__c, Geography_Product2_gne__c, Geography_Product3_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, Nation_Product1_gne__c, Nation_Product2_gne__c, Nation_Product3_gne__c, Notes_gne__c, OwnerId, Region_Product1_gne__c, Region_Product2_gne__c, Region_Product3_gne__c, SystemModstamp, Territory_Product1_gne__c, Territory_Product2_gne__c, Territory_Product3_gne__c from FCR_PTP_Summary_gne__c WHERE FCR_Days_Plan_gne__c = :fcrId];
            }
            GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
            if(result!=null && result.size()>0)
            {
                r.records = result;
            }
            r.setSuccessStatus();
            return r;
        }
        catch(Exception ex){
            GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
            r.setErrorStatus(ex);
            return r;
        }
    }
}