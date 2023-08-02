/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-15
*  Project: FCR
*  Description: REST Webservice, used to retrieve list of FCR Days Plan Account for particular FCR.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/ListDaysPlanAccount/*')
global with sharing class GNE_FCR_ListDaysPlanAccount_Webservice {
    @HttpGet
    global static GNE_FCR_Util.RestResponse doGet(){
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('ListDaysPlanAccount'));
            String unixId = null;
            if(index >= 0){
                unixId = req.requestURI.substring(index+1);
            }
            User user = GNE_FCR_Services_Helper.getUserByExternalId(unixId);        
            List<FCR_Days_Plan_gne__c> daysPlans = new List<FCR_Days_Plan_gne__c>();
            List<FCR_Days_Plan_Account_gne__c> result = new List<FCR_Days_Plan_Account_gne__c>();            
            String role = null;
            if(user!=null)
            {
                role = GNE_FCR_Services_Helper.getUserRole(user.Id);
            }
            if (role!=null)
            {
                if(role == 'CS')
                {
                    daysPlans = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Other_Accounts_gne__c, CreatedDate, Version_gne__c, CS_User_gne__c, Franchise_Objective_gne__c, DM_Comments_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c WHERE CS_User_gne__c = :user.Id];
                }
                else
                {
                    daysPlans = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Other_Accounts_gne__c, CreatedDate, Version_gne__c, CS_User_gne__c, Franchise_Objective_gne__c, DM_Comments_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c WHERE DM_User_gne__c = :String.valueOf(user.Id)];
                }
            }
            if(daysPlans.size()>0){
                result = [select Id, Name, Account_gne__c,Local_guid_gne__c, SystemModstamp, IsDeleted, CreatedById, CreatedDate, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, OwnerId, Territory_gne__c from FCR_Days_Plan_Account_gne__c WHERE FCR_Days_Plan_gne__c in: daysPlans];
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