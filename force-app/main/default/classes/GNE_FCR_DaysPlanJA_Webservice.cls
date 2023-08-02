/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-14
*  Project: FCR
*  Description: REST Webservice, used to retrieve, update and delete FCR DaysPlan Job Accountabilities objects.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/DaysPlanJA/*')
global with sharing class GNE_FCR_DaysPlanJA_Webservice {
    @HttpDelete
    global static GNE_FCR_Util.RestResponse doDelete() {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String daysPlanJaId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_Daysplan_Job_Accountability_gne__c daysPlanJa = [SELECT Id,Local_guid_gne__c FROM FCR_Daysplan_Job_Accountability_gne__c WHERE Id = :daysPlanJaId];
            delete daysPlanJa;
            records.add(daysPlanJa);
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
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('DaysPlanJA'));
            String daysPlanJaId = null;
            if(index >= 0){
                daysPlanJaId = req.requestURI.substring(index+1);
            } 
            List<FCR_Daysplan_Job_Accountability_gne__c> result = new List<FCR_Daysplan_Job_Accountability_gne__c>();            
            if(daysPlanJaId != null && daysPlanJaId != ''){
                result = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Display_Order_gne__c, FCR_Days_Plan_gne__c, Job_Accountability_Description_fcr__c, Job_Accountability_gne__c, Job_Accountability_Title_gne__c, LastModifiedById, LastModifiedDate, Rating_gne__c,Local_guid_gne__c from FCR_Daysplan_Job_Accountability_gne__c where Id = :daysPlanJaId ALL ROWS];            
            }
            else{
                result = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Display_Order_gne__c, FCR_Days_Plan_gne__c, Job_Accountability_Description_fcr__c, Job_Accountability_gne__c, Job_Accountability_Title_gne__c, LastModifiedById, LastModifiedDate, Rating_gne__c,Local_guid_gne__c from FCR_Daysplan_Job_Accountability_gne__c ALL ROWS];            
            }
            String timestamp = req.params.get('TimeStamp');                
            if(result != null && result.size() > 0){
                if(timestamp != null && timestamp != ''){
                    r.deltaCalculator = new GNE_FCR_Util.DeltaCalculator(timestamp);
                }
                r.setRecords(result);                 
            }
            if(timestamp!=null && timestamp !=''){
                List<FCR_Job_Accountability_gne__c> fcrJaList = [select Id, Name, CreatedById, CreatedDate, Description_gne__c, Display_Order_gne__c, Franchise_name_gne__c, IsDeleted, IsLocked, LastModifiedById, LastModifiedDate, MayEdit, OwnerId, SystemModstamp, Title_gne__c from FCR_Job_Accountability_gne__c where SystemModstamp >=: GNE_FCR_Util.formatTimeStamp(timestamp) ALL ROWS]; 
                Set<Id> fcrJaIds = new Set<Id>();
                for(FCR_Job_Accountability_gne__c fcrJa: fcrJaList){
                    fcrJaIds.add(fcrJa.Id);
                }
                Set<Id> daysPlanJaIds = new Set<Id>();                
                for(sObject daysPlanJas: r.updateRecords){
                    daysPlanJaIds.add(daysPlanJas.Id);
                }
                for(sObject  daysPlanJas: r.deletedRecords){
                    daysPlanJaIds.add(daysPlanJas.Id);
                }
                for(sObject  daysPlanJas: r.records){
                    daysPlanJaIds.add(daysPlanJas.Id);
                }
                System.debug('Days Pla Ja Ids' + daysPlanJaIds);
                System.debug('FCR js Ids' + fcrJaIds);
                List<FCR_Daysplan_Job_Accountability_gne__c> daysPlanJaList = new List<FCR_Daysplan_Job_Accountability_gne__c>(); 
                if(daysPlanJaId == null || daysPlanJaId == '')
                {
                    daysPlanJaList = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Display_Order_gne__c, FCR_Days_Plan_gne__c, Job_Accountability_Description_fcr__c, Job_Accountability_gne__c, Job_Accountability_Title_gne__c, LastModifiedById, LastModifiedDate, Rating_gne__c,Local_guid_gne__c from FCR_Daysplan_Job_Accountability_gne__c where Job_Accountability_gne__c in: fcrJaIds and Id not in:daysPlanJaIds];
                }
                else
                {
                    if (result !=null && result.size()==0)
                    {                                  
                        daysPlanJaList = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Display_Order_gne__c, FCR_Days_Plan_gne__c, Job_Accountability_Description_fcr__c, Job_Accountability_gne__c, Job_Accountability_Title_gne__c, LastModifiedById, LastModifiedDate, Rating_gne__c,Local_guid_gne__c from FCR_Daysplan_Job_Accountability_gne__c where Job_Accountability_gne__c in: fcrJaIds and Id =:daysPlanJaId];                
                    }                    
                }
                System.debug('Days Plan Ja list ' + daysPlanJaList );
                for (Integer i=0;i<daysPlanJaList.size();i++)
                {
                    r.updateRecords.add(daysPlanJaList.get(i));
                }
            }
            r.setSuccessStatus();
            return r;
        }
        catch(Exception ex){
            r.setErrorStatus(ex);
            return r;
        }
    }
    
    @HttpPut
    global static GNE_FCR_Util.RestResponse doPut(String Rating, String LocalGuid) {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String daysPlanJaId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_Daysplan_Job_Accountability_gne__c daysPlanJa  = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Display_Order_gne__c, FCR_Days_Plan_gne__c, Job_Accountability_Description_fcr__c, Job_Accountability_gne__c, Job_Accountability_Title_gne__c, LastModifiedById, LastModifiedDate, Rating_gne__c,Local_guid_gne__c from FCR_Daysplan_Job_Accountability_gne__c WHERE Id = :daysPlanJaId];
            if(Rating !=null)
            {
                daysPlanJa.Rating_gne__c = Rating;
            }
            if(LocalGuid !=null)
            {
                daysPlanJa.Local_guid_gne__c = LocalGuid;                  
            }
            update daysPlanJa;
            records.add(daysPlanJa);
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
                  r.records.add([select Id, Name, SystemModstamp, IsDeleted, CreatedById, CreatedDate, Display_Order_gne__c, FCR_Days_Plan_gne__c, Job_Accountability_Description_fcr__c, Job_Accountability_gne__c, Job_Accountability_Title_gne__c, LastModifiedById, LastModifiedDate, Rating_gne__c,Local_guid_gne__c from FCR_Daysplan_Job_Accountability_gne__c where Id = :DuplicateId]);
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