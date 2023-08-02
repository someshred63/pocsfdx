/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-12
*  Project: FCR
*  Description: REST Webservice, used to retrieve, insert, update and delete FCR Action Plan objects.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/ActionPlan/*')
global with sharing class GNE_FCR_ActionPlan_Webservice {
    @HttpDelete
    global static GNE_FCR_Util.RestResponse doDelete() {
         GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String ActionPlanId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_Action_Plan_gne__c actionPlan = [SELECT Id,Local_guid_gne__c FROM FCR_Action_Plan_gne__c WHERE Id = :ActionPlanId];
            delete actionPlan;
            List<sObject> records = new List<sObject>();
            records.add(actionPlan);
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
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('ActionPlan'));
            String actionPlanId = null;
            if(index >= 0){
                actionPlanId = req.requestURI.substring(index+1);
            }
            System.debug('Action Plan Id:' + actionPlanId );
            List<FCR_Action_Plan_gne__c> result = new List<FCR_Action_Plan_gne__c>();
            if(actionPlanId != null && actionPlanId != ''){
                result = [select Id, Name, Order_gne__c, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Description_gne__c, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Status_gne__c, Title_gne__c from FCR_Action_Plan_gne__c WHERE Id = :actionPlanId ALL ROWS];
            }
            else{
                result = [select Id, Name, Order_gne__c, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Description_gne__c, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Status_gne__c, Title_gne__c from FCR_Action_Plan_gne__c ALL ROWS];
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
    global static GNE_FCR_Util.RestResponse doPost(String Description, Id FcrDaysPlan, Integer Order, String LocalGuid, String Status, String Title) {
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            FCR_Action_Plan_gne__c actionPlan = new FCR_Action_Plan_gne__c();
            actionPlan.Description_gne__c = Description;
            actionPlan.FCR_Days_Plan_gne__c = FcrDaysPlan;
            actionPlan.Order_gne__c = Order;
            actionPlan.Local_guid_gne__c = LocalGuid;
            actionPlan.Status_gne__c = Status;
            actionPlan.Title_gne__c = Title;        
            insert actionPlan;
            List<sObject> records = new List<sObject>();
            records.add(actionPlan);
            r.records=records;
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
                  r.records.add([select Id, Name, Order_gne__c, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Description_gne__c, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Status_gne__c, Title_gne__c from FCR_Action_Plan_gne__c WHERE Id = :DuplicateId]);
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
    global static GNE_FCR_Util.RestResponse doPut(String Description, Id FcrDaysPlan, Integer Order, String LocalGuid, String Status, String Title) {
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        r.deltaCalculator = new GNE_FCR_Util.DeltaCalculator(DateTime.now());                 
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String ActionPlanId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_Action_Plan_gne__c actionPlan  = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, Order_gne__c, CreatedDate, Description_gne__c, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Status_gne__c, Title_gne__c from FCR_Action_Plan_gne__c WHERE Id = :ActionPlanId];
            if(Description !=null)
            {
                actionPlan.Description_gne__c = Description;
            }
            if(FcrDaysPlan !=null)
            {
                actionPlan.FCR_Days_Plan_gne__c = FcrDaysPlan;
            }
            if(Order !=null)
            {
                actionPlan.Order_gne__c = Order;
            }
            if(LocalGuid !=null)
            {
                actionPlan.Local_guid_gne__c = LocalGuid;
            }
            if(Status !=null)
            {
                actionPlan.Status_gne__c = Status;
            }
            if(Title !=null)
            {
                actionPlan.Title_gne__c = Title;   
            }
            update actionPlan;
            List<sObject> records = new List<sObject>();
            records.add(actionPlan);
            r.updateRecords= records;
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
                  r.records.add([select Id, Name, Order_gne__c, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Description_gne__c, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Status_gne__c, Title_gne__c from FCR_Action_Plan_gne__c WHERE Id = :DuplicateId]);
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