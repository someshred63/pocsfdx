/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-14
*  Project: FCR
*  Description: REST Webservice, used to retrieve, insert, update and delete FCR Days Plan Account objects.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/DaysPlanAccount/*')
global with sharing class GNE_FCR_DaysPlanAccount_Webservice {
    @HttpDelete
    global static GNE_FCR_Util.RestResponse doDelete() {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String daysPlanAccId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_Days_Plan_Account_gne__c daysPlanAccount = [SELECT Id,Local_guid_gne__c FROM FCR_Days_Plan_Account_gne__c WHERE Id = :daysPlanAccId];
            delete daysPlanAccount;
            records.add(daysPlanAccount);
            r.deletedRecords =records;
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
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('DaysPlanAccount'));
            String daysPlanAccId = null;
            if(index >= 0){
                daysPlanAccId = req.requestURI.substring(index+1);
            } 
            List<FCR_Days_Plan_Account_gne__c> result = new List<FCR_Days_Plan_Account_gne__c>();
            if(daysPlanAccId != null && daysPlanAccId != '')
            {
                result = [select Id, Name, SystemModstamp, IsDeleted, Account_gne__c,Local_guid_gne__c, CreatedById, CreatedDate, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, OwnerId, Territory_gne__c from FCR_Days_Plan_Account_gne__c WHERE Id = :daysPlanAccId ALL ROWS];
            }
            else{
                result = [select Id, Name, SystemModstamp, IsDeleted, Account_gne__c,Local_guid_gne__c, CreatedById, CreatedDate, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, OwnerId, Territory_gne__c from FCR_Days_Plan_Account_gne__c ALL ROWS];
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
    global static GNE_FCR_Util.RestResponse doPost(Id Account, Id FcrDaysPlan, String Territory, String LocalGuid) {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            FCR_Days_Plan_Account_gne__c daysPlanAccount = new FCR_Days_Plan_Account_gne__c();
            daysPlanAccount.Account_gne__c = Account;
            daysPlanAccount.Local_guid_gne__c = LocalGuid;
            daysPlanAccount.FCR_Days_Plan_gne__c = FcrDaysPlan;
            daysPlanAccount.Territory_gne__c = Territory;        
            insert daysPlanAccount;
            records.add(daysPlanAccount);
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
                  r.records.add([select Id, Name, SystemModstamp, IsDeleted, Account_gne__c,Local_guid_gne__c, CreatedById, CreatedDate, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, OwnerId, Territory_gne__c from FCR_Days_Plan_Account_gne__c WHERE Id = :DuplicateId]);
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
    global static GNE_FCR_Util.RestResponse doPut(Id Account, Id FcrDaysPlan, String Territory, String LocalGuid) {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String daysPlanAccId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_Days_Plan_Account_gne__c daysPlanAccount = [select Id, Name, SystemModstamp, IsDeleted, Account_gne__c,Local_guid_gne__c, CreatedById, CreatedDate, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, OwnerId, Territory_gne__c from FCR_Days_Plan_Account_gne__c WHERE Id = :daysPlanAccId];
            if (Account !=null)
            {
                daysPlanAccount.Account_gne__c = Account;
            }
            if (LocalGuid!=null)
            {
                daysPlanAccount.Local_guid_gne__c = LocalGuid;
            }
            if (FcrDaysPlan!=null)
            {
                daysPlanAccount.FCR_Days_Plan_gne__c = FcrDaysPlan;
            }
            if (Territory !=null)
            {
                daysPlanAccount.Territory_gne__c = Territory;
            }                   
            update daysPlanAccount;
            records.add(daysPlanAccount);
            r.setRecords(records);
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
                  r.records.add([select Id, Name, SystemModstamp, IsDeleted, Account_gne__c,Local_guid_gne__c, CreatedById, CreatedDate, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, OwnerId, Territory_gne__c from FCR_Days_Plan_Account_gne__c WHERE Id = :DuplicateId]);
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