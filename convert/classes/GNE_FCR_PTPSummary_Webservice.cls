/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-12
*  Project: FCR
*  Description: REST Webservice, used to retrieve, insert, update and delete FCR PTP Summary objects.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/PTPSummary/*')
global with sharing class GNE_FCR_PTPSummary_Webservice {

    @HttpDelete
    global static GNE_FCR_Util.RestResponse doDelete() {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String ptpSummaryId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_PTP_Summary_gne__c ptpSummary = [SELECT Id,Local_guid_gne__c FROM FCR_PTP_Summary_gne__c WHERE Id = :ptpSummaryId];
            delete ptpSummary;
            records.add(ptpSummary);
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
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('PTPSummary'));
            String ptpSummaryId = null;
            if(index >= 0){
                ptpSummaryId = req.requestURI.substring(index+1);
            } 
            List<FCR_PTP_Summary_gne__c> result = new List<FCR_PTP_Summary_gne__c>();
            System.debug('ptp summary Id'+ptpSummaryId);
            if(ptpSummaryId != null && ptpSummaryId != ''){
                result = [select Id, Name, CreatedById, CreatedDate, Division_Product1_gne__c, Division_Product2_gne__c, Division_Product3_gne__c, FCR_Days_Plan_gne__c, Geography_Product1_gne__c, Geography_Product2_gne__c, Geography_Product3_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, Nation_Product1_gne__c, Nation_Product2_gne__c, Nation_Product3_gne__c, Notes_gne__c, OwnerId, Region_Product1_gne__c, Region_Product2_gne__c, Region_Product3_gne__c, SystemModstamp, Territory_Product1_gne__c, Territory_Product2_gne__c, Territory_Product3_gne__c from FCR_PTP_Summary_gne__c WHERE Id = :ptpSummaryId ALL ROWS];
            }
            else{
               result = [select Id, Name, CreatedById, CreatedDate, Division_Product1_gne__c, Division_Product2_gne__c, Division_Product3_gne__c, FCR_Days_Plan_gne__c, Geography_Product1_gne__c, Geography_Product2_gne__c, Geography_Product3_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, Nation_Product1_gne__c, Nation_Product2_gne__c, Nation_Product3_gne__c, Notes_gne__c, OwnerId, Region_Product1_gne__c, Region_Product2_gne__c, Region_Product3_gne__c, SystemModstamp, Territory_Product1_gne__c, Territory_Product2_gne__c, Territory_Product3_gne__c from FCR_PTP_Summary_gne__c ALL ROWS];
            }
            if(result != null && result.size() > 0){
                String timestamp = req.params.get('TimeStamp');
                System.debug('time stamp'+timestamp);                
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
    global static GNE_FCR_Util.RestResponse doPost(Double DivisionProduct1, 
                                                    Double DivisionProduct2, 
                                                    Double DivisionProduct3, 
                                                    Double NationProduct1, 
                                                    Double NationProduct2, 
                                                    Double NationProduct3,
                                                    Id FcrDaysPlan,
                                                    String Notes,
                                                    Double RegionProduct1,
                                                    Double RegionProduct2,
                                                    Double RegionProduct3,
                                                    Double TerritoryProduct1,
                                                    Double TerritoryProduct2,
                                                    Double TerritoryProduct3,
                                                    String GeographyProduct1,
                                                    String GeographyProduct2,
                                                    String GeographyProduct3,
                                                    String LocalGuid){
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            FCR_PTP_Summary_gne__c ptpSummary = new FCR_PTP_Summary_gne__c();
            ptpSummary.Division_Product1_gne__c = DivisionProduct1;
            ptpSummary.Division_Product2_gne__c = DivisionProduct2;
            ptpSummary.Division_Product3_gne__c = DivisionProduct3;
            ptpSummary.Nation_Product1_gne__c = NationProduct1;
            ptpSummary.Nation_Product2_gne__c = NationProduct2;        
            ptpSummary.Nation_Product3_gne__c = NationProduct3;
            ptpSummary.Notes_gne__c = Notes;
            ptpSummary.Region_Product1_gne__c = RegionProduct1;
            ptpSummary.Region_Product2_gne__c = RegionProduct2;
            ptpSummary.Region_Product3_gne__c = RegionProduct3; 
            ptpSummary.Territory_Product1_gne__c = TerritoryProduct1;
            ptpSummary.Territory_Product2_gne__c = TerritoryProduct2;
            ptpSummary.Territory_Product3_gne__c = TerritoryProduct3;
            ptpSummary.Geography_Product1_gne__c = GeographyProduct1;
            ptpSummary.Geography_Product2_gne__c = GeographyProduct2;
            ptpSummary.Geography_Product3_gne__c = GeographyProduct3;
            ptpSummary.FCR_Days_Plan_gne__c = FcrDaysPlan;            
            ptpSummary.Local_guid_gne__c = LocalGuid;
            insert ptpSummary;
            records.add(ptpSummary);
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
                  r.records.add([select Id, Name, CreatedById, CreatedDate, Division_Product1_gne__c, Division_Product2_gne__c, Division_Product3_gne__c, FCR_Days_Plan_gne__c, Geography_Product1_gne__c, Geography_Product2_gne__c, Geography_Product3_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, Nation_Product1_gne__c, Nation_Product2_gne__c, Nation_Product3_gne__c, Notes_gne__c, OwnerId, Region_Product1_gne__c, Region_Product2_gne__c, Region_Product3_gne__c, SystemModstamp, Territory_Product1_gne__c, Territory_Product2_gne__c, Territory_Product3_gne__c from FCR_PTP_Summary_gne__c WHERE Id = :DuplicateId]);
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
    global static GNE_FCR_Util.RestResponse doPut(Double DivisionProduct1, 
                                                    Double DivisionProduct2, 
                                                    Double DivisionProduct3, 
                                                    Double NationProduct1, 
                                                    Double NationProduct2, 
                                                    Double NationProduct3,
                                                    Id FcrDaysPlan,
                                                    String Notes,
                                                    Double RegionProduct1,
                                                    Double RegionProduct2,
                                                    Double RegionProduct3,
                                                    Double TerritoryProduct1,
                                                    Double TerritoryProduct2,
                                                    Double TerritoryProduct3,
                                                    String GeographyProduct1,
                                                    String GeographyProduct2,
                                                    String GeographyProduct3,
                                                    String LocalGuid) {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String ptpSummaryId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_PTP_Summary_gne__c ptpSummary = [select Id, Name, CreatedById, CreatedDate, Division_Product1_gne__c, Division_Product2_gne__c, Division_Product3_gne__c, FCR_Days_Plan_gne__c, Geography_Product1_gne__c, Geography_Product2_gne__c, Geography_Product3_gne__c, IsDeleted, IsLocked, LastModifiedById, LastModifiedDate, Local_guid_gne__c, MayEdit, Nation_Product1_gne__c, Nation_Product2_gne__c, Nation_Product3_gne__c, Notes_gne__c, OwnerId, Region_Product1_gne__c, Region_Product2_gne__c, Region_Product3_gne__c, SystemModstamp, Territory_Product1_gne__c, Territory_Product2_gne__c, Territory_Product3_gne__c from FCR_PTP_Summary_gne__c WHERE Id = :ptpSummaryId];
            if (DivisionProduct1 !=null)
            {
                ptpSummary.Division_Product1_gne__c = DivisionProduct1;
            }
            if (DivisionProduct2!=null)
            {
                ptpSummary.Division_Product2_gne__c = DivisionProduct2;
            }
            if (DivisionProduct3!=null)
            {
                ptpSummary.Division_Product3_gne__c = DivisionProduct3;
            }
            if (NationProduct1!=null)
            {
                ptpSummary.Nation_Product1_gne__c = NationProduct1;
            }
            if (NationProduct2!=null)
            {
                ptpSummary.Nation_Product2_gne__c = NationProduct2;        
            }
            if (NationProduct3!=null)
            {
                ptpSummary.Nation_Product3_gne__c = NationProduct3;
            }
            if (Notes!=null)
            {
                ptpSummary.Notes_gne__c = Notes;
            }
            if (RegionProduct1!=null)
            {
                ptpSummary.Region_Product1_gne__c = RegionProduct1;
            }
            if (RegionProduct2!=null)
            {
                ptpSummary.Region_Product2_gne__c = RegionProduct2;
            }
            if (RegionProduct3!=null)
            {
                ptpSummary.Region_Product3_gne__c = RegionProduct3; 
            }
            if (TerritoryProduct1!=null)
            {
                ptpSummary.Territory_Product1_gne__c = TerritoryProduct1;
            }
            if (TerritoryProduct2!=null)
            {
                ptpSummary.Territory_Product2_gne__c = TerritoryProduct2;
            }
            if (TerritoryProduct3!=null)
            {
                ptpSummary.Territory_Product3_gne__c = TerritoryProduct3;
            }
            if (GeographyProduct1!=null)
            {
                ptpSummary.Geography_Product1_gne__c = GeographyProduct1;
            }
            if (GeographyProduct2!=null)
            {
                ptpSummary.Geography_Product2_gne__c = GeographyProduct2;
            }
            if (GeographyProduct3!=null)
            {
                ptpSummary.Geography_Product3_gne__c = GeographyProduct3;
            }
            if (FcrDaysPlan!=null)
            {
                ptpSummary.FCR_Days_Plan_gne__c = FcrDaysPlan;            
            }
            if (LocalGuid!=null)
            {
                ptpSummary.Local_guid_gne__c = LocalGuid;                   
            }
            update ptpSummary;
            records.add(ptpSummary);
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
                  r.records.add([select Id, Name, CreatedById, CreatedDate, Division_Product1_gne__c, Division_Product2_gne__c, Division_Product3_gne__c, FCR_Days_Plan_gne__c, Geography_Product1_gne__c, Geography_Product2_gne__c, Geography_Product3_gne__c, IsDeleted, LastModifiedById, LastModifiedDate, Local_guid_gne__c, Nation_Product1_gne__c, Nation_Product2_gne__c, Nation_Product3_gne__c, Notes_gne__c, OwnerId, Region_Product1_gne__c, Region_Product2_gne__c, Region_Product3_gne__c, SystemModstamp, Territory_Product1_gne__c, Territory_Product2_gne__c, Territory_Product3_gne__c from FCR_PTP_Summary_gne__c WHERE Id = :DuplicateId]);
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