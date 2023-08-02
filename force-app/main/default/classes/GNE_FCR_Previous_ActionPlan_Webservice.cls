/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-15
*  Project: FCR
*  Description: REST Webservice, used to retrieve list of previous FCR Action Plans for a CS User.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/PreviousActionPlans/*')
global with sharing class GNE_FCR_Previous_ActionPlan_Webservice {
    @HttpGet
    global static GNE_FCR_Util.RestResponse doGet(){
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('PreviousActionPlans'));
            String UnixId = null;
            if(index >= 0){
                UnixId = req.requestURI.substring(index+1);
            }
            User user = GNE_FCR_Services_Helper.getUserByExternalId(UnixId);                    
            List<FCR_Days_Plan_gne__c> fcrDaysPlan = new List<FCR_Days_Plan_gne__c>();
            List<FCR_Action_Plan_gne__c> result = new List<FCR_Action_Plan_gne__c>();
            if(user != null){
                fcrDaysPlan = [select Id, Name, SystemModstamp, IsDeleted, CreatedById, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Other_Accounts_gne__c, CreatedDate, Version_gne__c, DM_Comments_gne__c, Franchise_Objective_gne__c, CS_User_gne__c, Date_Field_Visit_gne__c, DM_User_gne__c,DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c from FCR_Days_Plan_gne__c WHERE CS_User_gne__c = :user.Id and Status_gne__c = 'Form Complete' order by SystemModstamp desc];
            }
            if(fcrDaysPlan!=null && fcrDaysPlan.size()>0)
            {
                result = [select Id, Name, SystemModstamp, IsDeleted, Order_gne__c, CreatedById, CreatedDate, Description_gne__c, FCR_Days_Plan_gne__c, LastModifiedById, LastModifiedDate, Local_guid_gne__c, OwnerId, Status_gne__c, Title_gne__c from FCR_Action_Plan_gne__c WHERE FCR_Days_Plan_gne__c = :fcrDaysPlan.get(0).Id];
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