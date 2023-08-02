/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-14
*  Project: FCR
*  Description: REST Webservice, used to retrieve, insert, update and delete FCR Days Plan objects.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/DaysPlan/*')
global with sharing class GNE_FCR_DaysPlan_Webservice {
    @HttpDelete
    global static GNE_FCR_Util.RestResponse doDelete() {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String daysPlanId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            FCR_Days_Plan_gne__c daysPlan = [SELECT Id,Local_guid_gne__c FROM FCR_Days_Plan_gne__c WHERE Id = :daysPlanId];
            delete daysPlan;
            records.add(daysPlan);
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
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('DaysPlan'));
            String timestamp = req.params.get('TimeStamp');
                
            Set<Id> daysPlanIds = new Set<Id>();
            Map<Id,String> attachmentMap = new Map<Id,String>();  
            Map<Id,FCR_Days_Plan_gne__c> daysPlanMap = new Map<Id,FCR_Days_Plan_gne__c>();    
            String daysPlanId = null;
            if(index >= 0){
                daysPlanId = req.requestURI.substring(index+1);
            }            
            List<FCR_Days_Plan_gne__c> result = new List<FCR_Days_Plan_gne__c>();
            if(daysPlanId != null && daysPlanId != ''){
                result = [select Id, Name, SystemModstamp, IsDeleted,Information_Backup_gne__c, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Other_Accounts_gne__c, CreatedById, CreatedDate, DM_Comments_gne__c, Version_gne__c, Franchise_Objective_gne__c, CS_User_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c WHERE Id = :daysPlanId ALL ROWS];
            }
            else{
                system.debug('I am running this query');
                result = [select Id, Name, SystemModstamp, IsDeleted,Information_Backup_gne__c, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Other_Accounts_gne__c, CreatedById, CreatedDate, DM_Comments_gne__c, Version_gne__c, Franchise_Objective_gne__c, CS_User_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c ALL ROWS];
            }
            
            if(result != null && result.size() > 0){
                if(timestamp != null && timestamp != ''){
                    r.deltaCalculator = new GNE_FCR_Util.DeltaCalculator(timestamp);
                }
                r.setRecords(result);
                for(FCR_Days_Plan_gne__c d : result){
            		daysPlanMap.put(d.Id,d);
            	}
            }
            if(timestamp == null || timestamp == ''){
            	if(daysPlanMap.values().size() > 0){
	            	for(Attachment a : [select Id,Body,ParentId from Attachment where ParentId in: daysPlanMap.values() ]){ 
	            		attachmentMap.put(a.ParentId,a.Body.toString());
	            	}
            	}
            }
            else{
            	for(Attachment a : [select Id,Body,ParentId from Attachment where ParentId in: daysPlanMap.values()  and SystemModstamp >=: GNE_FCR_Util.formatTimeStamp(timestamp)]){ 
            		attachmentMap.put(a.ParentId,a.Body.toString());
            	}
            }
            System.debug('AttachmentMap: ' + attachmentMap);
        	for(sObject daysPlans: r.updateRecords){
                daysPlanIds.add(daysPlans.Id);
            }
            for(sObject  daysPlans: r.deletedRecords){
                daysPlanIds.add(daysPlans.Id);
            }
            for(sObject  daysPlans: r.records){
                daysPlanIds.add(daysPlans.Id);
            }
            for(Id id : attachmentMap.keySet()){
            	if(daysPlanMap.containsKey(id)){
            		daysPlanMap.get(id).Information_Backup_gne__c=attachmentMap.get(id);
            	}
            	if(!daysPlanIds.contains(id)){
            		r.updateRecords.add(daysPlanMap.get(id));
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
  
    @HttpPost
    global static GNE_FCR_Util.RestResponse doPost(String SummaryComments, Date FieldVisit, Integer Version, Id CsUser, String DmComments, String FieldObjectives, Id FranchiseObjectives, String LocalGuid, String StatusActionKey, String InfoBackup, String OtherAccounts, String PreviousActionCsComments, String DmActionPlan) {
        List<sObject> records = new List<sObject>();
        KeyRestResponse r = new KeyRestResponse();
        try{
            FCR_Days_Plan_gne__c daysPlan = new FCR_Days_Plan_gne__c();
            Attachment newAtmt = new Attachment();
            daysPlan.Summary_Comments_gne__c = SummaryComments;
            daysPlan.Date_Field_Visit_gne__c = FieldVisit;
            daysPlan.Version_gne__c = Version;
            daysPlan.CS_User_gne__c = CsUser;
            daysPlan.DM_Comments_gne__c = DmComments;
            daysPlan.Field_Objectives_gne__c = FieldObjectives;
            daysPlan.Franchise_Objective_gne__c = FranchiseObjectives;
            daysPlan.Local_guid_gne__c = LocalGuid;
            daysPlan.Status_Action_Key__c = StatusActionKey;
            daysPlan.Other_Accounts_gne__c = OtherAccounts;
            daysPlan.Previous_Action_Plan_CS_Comments__c = PreviousActionCsComments;
            daysPlan.DM_Action_Plan__c = DmActionPlan;
            if (StatusActionKey != null && StatusActionKey != '')
            {
                GNE_FCR_DaysPlan_Key__c daysPlanKey = GNE_FCR_DaysPlan_Key__c.getValues(StatusActionKey);
                System.debug('test'+StatusActionKey+daysPlanKey);
                daysPlan.Action_gne__c = daysPlanKey.Action__c;
                daysPlan.Status_gne__c = daysPlanKey.Status__c;
            }
            Integer existingDaysPlan = [select count() from FCR_Days_Plan_gne__c WHERE CS_User_gne__c = :CsUser and Status_Action_Key__c!='DMFormIsCompleted'];        
            if (existingDaysPlan > 0)
            {
                r.DaysPlanExistsForCurrentUser = true;
            }
            else
            {
                insert daysPlan;
                if(daysPlan.Id!=null && InfoBackup!=null)
                {                
                    newAtmt.Body = Blob.valueOf(InfoBackup);            
                    newAtmt.ParentId = daysPlan.Id;
                    FCR_Days_Plan_gne__c daysPlanName = [select Name from FCR_Days_Plan_gne__c where Id=:daysPlan.Id];
                    newAtmt.Name = String.valueOf(daysPlanName.Name);
                    insert newAtmt; 
                    daysPlan.Information_Backup_gne__c=InfoBackup;
                }
                List<Id> franchiseIds = new List<Id>();
                for(SFA2_User_Sales_Roster_gne__c salesRoster:GNE_FCR_Services_Helper.getFranchise(CsUser)){
                    franchiseIds.add(salesRoster.Sales_Roster_gne__r.Franchise__c); 
                }                  
                List<FCR_Job_Accountability_gne__c> jobAccountabilities = [select Id from FCR_Job_Accountability_gne__c where Franchise_name_gne__c in : franchiseIds ];
                List<FCR_Daysplan_Job_Accountability_gne__c> jaInsertList = new List<FCR_Daysplan_Job_Accountability_gne__c>();
                for(FCR_Job_Accountability_gne__c jobAccountability:jobAccountabilities){
                    FCR_Daysplan_Job_Accountability_gne__c insertJA = new FCR_Daysplan_Job_Accountability_gne__c();
                    insertJA.Job_Accountability_gne__c=jobAccountability.Id;
                    insertJA.FCR_Days_Plan_gne__c=daysPlan.Id;
                    jaInsertList.add(insertJA);
                }
                if(jaInsertList.size()>0)
                {
                    insert jaInsertList;
                }
                records.add(daysPlan);
                r.records =records;
                
                
            }
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
              if(index >=0)
              {
              	  Id DuplicateId = r.error.message.substring(index+4,r.error.message.length());
	              if(DuplicateId !=null){
	              	  List<FCR_Days_Plan_gne__c> duplicateResult = new List<FCR_Days_Plan_gne__c>();
	              	  duplicateResult = [select Id, Name, SystemModstamp, IsDeleted,Information_Backup_gne__c, CreatedById, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Other_Accounts_gne__c, CreatedDate, DM_Comments_gne__c, Version_gne__c, Franchise_Objective_gne__c, CS_User_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c WHERE Id = :DuplicateId];
	              	  r.records.add(duplicateResult.get(0));
	                  List<Attachment> atmtList = [select Id,Body from Attachment where ParentId=:DuplicateId];
	              	  if(atmtList.size()>0 && duplicateResult.size() > 0)
	              	  {
	              	  	duplicateResult.get(0).Information_Backup_gne__c = atmtList.get(0).Body.toString();
	              	  } 	  
	              }
              	System.debug('failed: ' + r.error);
        	}
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
    global static GNE_FCR_Util.RestResponse doPut(String SummaryComments, Date FieldVisit, Integer Version, Id CsUser, String DmComments, String FieldObjectives, Id FranchiseObjectives, String LocalGuid, String StatusActionKey,String InfoBackup, String OtherAccounts, String PreviousActionCsComments, String DmActionPlan) {
        List<sObject> records = new List<sObject>();
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String daysPlanId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            Attachment updateAtmt = null;
            List<Attachment> atmtList = [select Id, Name, Body, ParentId from Attachment where ParentId=:daysPlanId];
            if (atmtList.size()>0)
            {
            	updateAtmt = atmtList.get(0);
            }                
            FCR_Days_Plan_gne__c daysPlan= [select Id, Name, SystemModstamp, IsDeleted,Information_Backup_gne__c, CreatedById, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Other_Accounts_gne__c, CreatedDate,Version_gne__c, CS_User_gne__c, DM_Comments_gne__c, Franchise_Objective_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Status_gne__c, Action_gne__c, Status_Action_Key__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c WHERE Id = :daysPlanId];
            if (SummaryComments != null)
            {            
                daysPlan.Summary_Comments_gne__c = SummaryComments;
            }
            if (FieldVisit != null)
            {
                daysPlan.Date_Field_Visit_gne__c = FieldVisit;
            }
            if (Version !=null)
            {
                daysPlan.Version_gne__c = Version;
            }
            if (CsUser !=null)
            {
                daysPlan.CS_User_gne__c = CsUser;
            }
            if (DmComments !=null)
            {
                daysPlan.DM_Comments_gne__c = DmComments;
            }
            if (FieldObjectives !=null)
            {
                daysPlan.Field_Objectives_gne__c = FieldObjectives;
            }
            if (FranchiseObjectives !=null)
            {
                daysPlan.Franchise_Objective_gne__c = FranchiseObjectives;
            }
            if (LocalGuid !=null)
            {
                daysPlan.Local_guid_gne__c = LocalGuid;
            }
            if (InfoBackup !=null)            
            {
                if (updateAtmt!=null)
                {
                	updateAtmt.Body = Blob.valueOf(InfoBackup);
                }
                else
                {
                	updateAtmt = new Attachment();
                    updateAtmt.Body = Blob.valueOf(InfoBackup);            
                    updateAtmt.ParentId = daysPlan.Id;
                    updateAtmt.Name = String.valueOf(daysPlan.Name);
                }
            }
            if (OtherAccounts !=null)
            {
                daysPlan.Other_Accounts_gne__c = OtherAccounts;
            }
            if (StatusActionKey !=null)
            {
                daysPlan.Status_Action_Key__c = StatusActionKey;
            }
            if (PreviousActionCsComments !=null)
            {
                daysPlan.Previous_Action_Plan_CS_Comments__c = PreviousActionCsComments;
            }
            if (DmActionPlan !=null)
            {
                daysPlan.DM_Action_Plan__c = DmActionPlan;
            }            
            if (StatusActionKey != null)
            {
            	if(StatusActionKey != '')
            	{
	                GNE_FCR_DaysPlan_Key__c daysPlanKey = GNE_FCR_DaysPlan_Key__c.getValues(StatusActionKey);
	                daysPlan.Action_gne__c = daysPlanKey.Action__c;
	                daysPlan.Status_gne__c = daysPlanKey.Status__c;
	            } else 
	            {
	                daysPlan.Action_gne__c = '';
	                daysPlan.Status_gne__c = '';
	            }
            }                   
            update daysPlan;
            if (updateAtmt != null)
            {
            	upsert updateAtmt;
				daysPlan.Information_Backup_gne__c = updateAtmt.Body.toString();          	
            } 
            records.add(daysPlan);
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
	                  List<FCR_Days_Plan_gne__c> duplicateResult = new List<FCR_Days_Plan_gne__c>();
	              	  duplicateResult = [select Id, Name, SystemModstamp, IsDeleted,Information_Backup_gne__c, CreatedById, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Other_Accounts_gne__c, CreatedDate, DM_Comments_gne__c, Version_gne__c, Franchise_Objective_gne__c, CS_User_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c WHERE Id = :DuplicateId];
	              	  r.records.add(duplicateResult.get(0));
	                  List<Attachment> atmtList = [select Id,Body from Attachment where ParentId=:DuplicateId];
	              	  if(atmtList.size()>0 && duplicateResult.size() > 0)
	              	  {
	              	  	duplicateResult.get(0).Information_Backup_gne__c = atmtList.get(0).Body.toString();
	              	  } 
	              }
              }
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
    
    public class KeyRestResponse extends GNE_FCR_Util.SObjectRestResponse{
        public Boolean DaysPlanExistsForCurrentUser = false;
    }
}