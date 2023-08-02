/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-15
*  Project: FCR
*  Description: REST Webservice, used to retrieve list of FCR Days Plan JobCompetency for particular FCR.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/ListJobCompetency/*')
global with sharing class GNE_FCR_ListJobCompetency_Webservice {
    @HttpGet
    global static GNE_FCR_Util.RestResponse doGet(){
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
			Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('ListJobCompetency'));
            String fcrId = null;
            if(index >= 0){
                fcrId = req.requestURI.substring(index+1);
            }
            List<FCR_DaysPlan_Job_Competency_gne__c> result = new List<FCR_DaysPlan_Job_Competency_gne__c>();
            if(fcrId != null && fcrId != ''){
                result = [select Id, Name, Assess_Comments_gne__c, Assess_Gather_Insights_gne__c, Assess_Identifying_Shifts_gne__c, Assess_Strategic_Account_Planning_gne__c, Clarify_Comments_gne__c, Clarify_Check_Assumptions_gne__c, Clarify_Effective_Probing_gne__c, Clarify_Reflective_Listening_gne__c, CreatedById, CreatedDate, Execute_Aligning_Information_gne__c, Execute_Closing_gne__c, Execute_Comments_gne__c, Execute_Objection_Handling_gne__c, FCR_Days_Plan_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, SystemModstamp from FCR_DaysPlan_Job_Competency_gne__c WHERE FCR_Days_Plan_gne__c = :fcrId];
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