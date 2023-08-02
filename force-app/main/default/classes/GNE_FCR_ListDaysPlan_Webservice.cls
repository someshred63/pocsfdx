/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-15
*  Project: FCR
*  Description: REST Webservice, used to retrieve list of FCR Days Plan for particular CS user or a DM user.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/ListDaysPlan/*')
global with sharing class GNE_FCR_ListDaysPlan_Webservice {
    @HttpGet
    global static GNE_FCR_Util.RestResponse doGet(){
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('ListDaysPlan'));
			String timestamp = req.params.get('TimeStamp');                            

            Set<Id> daysPlanIds = new Set<Id>();
            Map<Id,String> attachmentMap = new Map<Id,String>();  
            Map<Id,FCR_Days_Plan_gne__c> daysPlanMap = new Map<Id,FCR_Days_Plan_gne__c>(); 
            
            String unixId = null;
            if(index >= 0){
                unixId = req.requestURI.substring(index+1);
            }
            User user = GNE_FCR_Services_Helper.getUserByExternalId(unixId);        
            List<FCR_Days_Plan_gne__c> result = new List<FCR_Days_Plan_gne__c>();
            String role = null;
            if(user!=null)
            {
                role = GNE_FCR_Services_Helper.getUserRole(user.Id);
            }
            if (role!=null)
            {
                if(role == 'CS')
                {
                    result = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Information_Backup_gne__c, Other_Accounts_gne__c, CreatedDate, Version_gne__c, CS_User_gne__c, Franchise_Objective_gne__c, DM_Comments_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c WHERE CS_User_gne__c = :user.Id];
                }
                else
                {
                    result = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Information_Backup_gne__c, Other_Accounts_gne__c, CreatedDate, Version_gne__c, CS_User_gne__c, Franchise_Objective_gne__c, DM_Comments_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c WHERE DM_User_gne__c = :String.valueOf(user.Id)];
                }
            }
            if(result!=null && result.size()>0)
            {
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
            		for(Attachment a : [select Id, Body,ParentId from Attachment where ParentId in: daysPlanMap.values() ]){ 
	            		attachmentMap.put(a.ParentId,a.Body.toString());
	            	}
            	}
            }
            else{
            	for(Attachment a : [select Id, Body,ParentId from Attachment where ParentId in: daysPlanMap.values()  and SystemModstamp >=: GNE_FCR_Util.formatTimeStamp(timestamp)]){ 
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
}