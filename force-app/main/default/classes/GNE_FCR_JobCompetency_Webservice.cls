/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-14
*  Project: FCR
*  Description: REST Webservice, used to retrieve, insert, update and delete FCR Days Plan JobCompetency objects.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/JobCompetency/*')
global with sharing class GNE_FCR_JobCompetency_Webservice {

    @HttpDelete
    global static GNE_FCR_Util.RestResponse doDelete() {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String jobCompetencyId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_DaysPlan_Job_Competency_gne__c jobCompetency = [SELECT Id,Local_guid_gne__c FROM FCR_DaysPlan_Job_Competency_gne__c WHERE Id = :jobCompetencyId];
            delete jobCompetency;
            records.add(jobCompetency);
            r.deletedRecords = records;
            r.setSuccessStatus();
            return r;
        }
        catch(Exception ex){
            r.setErrorStatus(ex);
            return r;        
        }
    }
  
    @HttpGet
    global static GNE_FCR_Util.RestResponse doGet() {
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('JobCompetency'));
            String jobCompetencyId = null;
            if(index >= 0){
                jobCompetencyId = req.requestURI.substring(index+1);
            } 
            List<FCR_DaysPlan_Job_Competency_gne__c> result = new List<FCR_DaysPlan_Job_Competency_gne__c>();
            if(jobCompetencyId != null && jobCompetencyId != ''){
                result = [select Id, Name, Assess_Comments_gne__c, Assess_Gather_Insights_gne__c, Assess_Identifying_Shifts_gne__c, Assess_Strategic_Account_Planning_gne__c, Clarify_Comments_gne__c, Clarify_Check_Assumptions_gne__c, Clarify_Effective_Probing_gne__c, Clarify_Reflective_Listening_gne__c, CreatedById, CreatedDate, Execute_Aligning_Information_gne__c, Execute_Closing_gne__c, Execute_Comments_gne__c, Execute_Objection_Handling_gne__c, FCR_Days_Plan_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, SystemModstamp from FCR_DaysPlan_Job_Competency_gne__c WHERE Id = :jobCompetencyId ALL ROWS];
            }
            else{
                result = [select Id, Name, Assess_Comments_gne__c, Assess_Gather_Insights_gne__c, Assess_Identifying_Shifts_gne__c, Assess_Strategic_Account_Planning_gne__c, Clarify_Comments_gne__c, Clarify_Check_Assumptions_gne__c, Clarify_Effective_Probing_gne__c, Clarify_Reflective_Listening_gne__c, CreatedById, CreatedDate, Execute_Aligning_Information_gne__c, Execute_Closing_gne__c, Execute_Comments_gne__c, Execute_Objection_Handling_gne__c, FCR_Days_Plan_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, SystemModstamp from FCR_DaysPlan_Job_Competency_gne__c ALL ROWS];
            }
            if(result != null && result.size() > 0){
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
  
    @HttpPost
    global static GNE_FCR_Util.RestResponse doPost(String AssessComments, 
                                                    String AssessInsights, 
                                                    String AssessShifts, 
                                                    String AssessPlanning, 
                                                    String ClarifyAssumptions, 
                                                    String ClarifyComments,
                                                    String ClarifyProbing,
                                                    String ClarifyListening,
                                                    String ExecuteAlignInfo,
                                                    String ExecuteClosing,
                                                    String ExecuteComments,
                                                    String ExecuteHandling,
                                                    Id FcrDaysPlan,
                                                    String LocalGuid) {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            FCR_DaysPlan_Job_Competency_gne__c jobCompetency = new FCR_DaysPlan_Job_Competency_gne__c();
            jobCompetency.Assess_Comments_gne__c = AssessComments;
            jobCompetency.Assess_Gather_Insights_gne__c = AssessInsights;
            jobCompetency.Assess_Identifying_Shifts_gne__c = AssessShifts;
            jobCompetency.Assess_Strategic_Account_Planning_gne__c = AssessPlanning;
            jobCompetency.Clarify_Check_Assumptions_gne__c = ClarifyAssumptions;
            jobCompetency.Clarify_Comments_gne__c = ClarifyComments;
            jobCompetency.Clarify_Effective_Probing_gne__c = ClarifyProbing;
            jobCompetency.Clarify_Reflective_Listening_gne__c = ClarifyListening;
            jobCompetency.Execute_Aligning_Information_gne__c = ExecuteAlignInfo;
            jobCompetency.Execute_Closing_gne__c = ExecuteClosing;
            jobCompetency.Execute_Comments_gne__c = ExecuteComments;
            jobCompetency.Execute_Objection_Handling_gne__c = ExecuteHandling;
            jobCompetency.FCR_Days_Plan_gne__c = FcrDaysPlan;
            jobCompetency.Local_guid_gne__c = LocalGuid;
            insert jobCompetency;
            records.add(jobCompetency);
            r.records = records;
            r.setSuccessStatus();
            return r;
        }
        catch(DmlException dex){
            If(dex.getDmlType(0)==StatusCode.DUPLICATE_VALUE)
            {
              r.success = false;
              r.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
              r.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
              r.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
              r.error = new GNE_FCR_Util.ExceptionInfo();
              r.error.typeName = 'DuplicateValue';
              r.error.message = dex.getDmlMessage(0);
              Integer index = r.error.message.indexof('id: ');
              if(index >=0){
              Id DuplicateId = r.error.message.substring(index+4,r.error.message.length());
              if(DuplicateId !=null){
                  r.records.add([select Id, Name, Assess_Comments_gne__c, Assess_Gather_Insights_gne__c, Assess_Identifying_Shifts_gne__c, Assess_Strategic_Account_Planning_gne__c, Clarify_Check_Assumptions_gne__c, Clarify_Effective_Probing_gne__c, Clarify_Reflective_Listening_gne__c, CreatedById, CreatedDate, Execute_Aligning_Information_gne__c, Execute_Closing_gne__c, Execute_Comments_gne__c, Execute_Objection_Handling_gne__c, FCR_Days_Plan_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, SystemModstamp from FCR_DaysPlan_Job_Competency_gne__c WHERE Id = :DuplicateId]);
              }}
              System.debug('failed: ' + r.error);
            }
            else
            {
                r.setErrorStatus(dex);
            }
            return r;
        }
        catch(Exception ex){
            r.setErrorStatus(ex);
            return r;
        }
    }
    
    @HttpPut
    global static GNE_FCR_Util.RestResponse doPut(String AssessComments, 
                                                    String AssessInsights, 
                                                    String AssessShifts, 
                                                    String AssessPlanning, 
                                                    String ClarifyAssumptions, 
                                                    String ClarifyComments,
                                                    String ClarifyProbing,
                                                    String ClarifyListening,
                                                    String ExecuteAlignInfo,
                                                    String ExecuteClosing,
                                                    String ExecuteComments,
                                                    String ExecuteHandling,
                                                    Id FcrDaysPlan,
                                                    String LocalGuid) {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String jobCompetencyId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_DaysPlan_Job_Competency_gne__c jobCompetency = [select Id, Name, Assess_Comments_gne__c, Assess_Gather_Insights_gne__c, Assess_Identifying_Shifts_gne__c, Assess_Strategic_Account_Planning_gne__c, Clarify_Check_Assumptions_gne__c, Clarify_Effective_Probing_gne__c, Clarify_Reflective_Listening_gne__c, CreatedById, CreatedDate, Execute_Aligning_Information_gne__c, Execute_Closing_gne__c, Execute_Comments_gne__c, Execute_Objection_Handling_gne__c, FCR_Days_Plan_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, SystemModstamp from FCR_DaysPlan_Job_Competency_gne__c WHERE Id = :jobCompetencyId];
            if(AssessComments !=null)
            {
                jobCompetency.Assess_Comments_gne__c = AssessComments;
            }
            if(AssessInsights!=null)
            {
                jobCompetency.Assess_Gather_Insights_gne__c = AssessInsights;
            }
            if(AssessShifts!=null)
            {
                jobCompetency.Assess_Identifying_Shifts_gne__c = AssessShifts;
            }
            if(AssessPlanning!=null)
            {
                jobCompetency.Assess_Strategic_Account_Planning_gne__c = AssessPlanning;
            }
            if(ClarifyAssumptions!=null)
            {
                jobCompetency.Clarify_Check_Assumptions_gne__c = ClarifyAssumptions;
            }
            if(ClarifyComments!=null)
            {
                jobCompetency.Clarify_Comments_gne__c = ClarifyComments;
            }
            if(ClarifyProbing!=null)
            {
                jobCompetency.Clarify_Effective_Probing_gne__c = ClarifyProbing;
            }
            if(ClarifyListening!=null)
            {
                jobCompetency.Clarify_Reflective_Listening_gne__c = ClarifyListening;
            }
            if(ExecuteAlignInfo!=null)
            {
                jobCompetency.Execute_Aligning_Information_gne__c = ExecuteAlignInfo;
            }
            if(ExecuteClosing !=null)
            {
                jobCompetency.Execute_Closing_gne__c = ExecuteClosing;
            }
            if(ExecuteComments !=null)
            {
                jobCompetency.Execute_Comments_gne__c = ExecuteComments;
            }
            if(ExecuteHandling !=null)
            {
                jobCompetency.Execute_Objection_Handling_gne__c = ExecuteHandling;
            }
            if(FcrDaysPlan !=null)
            {
                jobCompetency.FCR_Days_Plan_gne__c = FcrDaysPlan;
            }
            if(LocalGuid !=null)
            {
                jobCompetency.Local_guid_gne__c = LocalGuid;               
            }
            update jobCompetency;
            records.add(jobCompetency);
            r.updateRecords = records;
            r.setSuccessStatus();
            return r;
        }
        catch(DmlException dex){
            If(dex.getDmlType(0)==StatusCode.DUPLICATE_VALUE)
            {
              r.success = false;
              r.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
              r.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
              r.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
              r.error = new GNE_FCR_Util.ExceptionInfo();
              r.error.typeName = 'DuplicateValue';
              r.error.message = dex.getDmlMessage(0);
              Integer index = r.error.message.indexof('id: ');
              if(index >=0){
              Id DuplicateId = r.error.message.substring(index+4,r.error.message.length());
              if(DuplicateId !=null){
                  r.records.add([select Id, Name, Assess_Comments_gne__c, Assess_Gather_Insights_gne__c, Assess_Identifying_Shifts_gne__c, Assess_Strategic_Account_Planning_gne__c, Clarify_Check_Assumptions_gne__c, Clarify_Effective_Probing_gne__c, Clarify_Reflective_Listening_gne__c, CreatedById, CreatedDate, Execute_Aligning_Information_gne__c, Execute_Closing_gne__c, Execute_Comments_gne__c, Execute_Objection_Handling_gne__c, FCR_Days_Plan_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, SystemModstamp from FCR_DaysPlan_Job_Competency_gne__c WHERE Id = :DuplicateId]);
              }}
              System.debug('failed: ' + r.error);
            }
            else
            {
                r.setErrorStatus(dex);
            }
            return r;
        }
        catch(Exception ex){
            r.setErrorStatus(ex);
            return r;
        }
    }
}