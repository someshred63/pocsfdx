/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Gfrs_Ltng_FetchAppRecordsLWC {
    @AuraEnabled(cacheable=true)
    public static List<gFRS_Ltng_Application__c> getApplicationRecds(String recId) {       
        set<id> appIds=new set<id>();
        GFRS_Administrative_Budget_Line_Item__c rec=[select id,name,Cost_Center__c,WBS_Code__c from GFRS_Administrative_Budget_Line_Item__c where id=:recId];
        list<gFRS_Ltng_Funding_Allocation_Line_Item__c >  recordList=[Select Id,name,gFRS_Funding_Allocation__r.gfrs_application__r.Name,Cost_Center_Code__c,WBS_Code__c from gFRS_Ltng_Funding_Allocation_Line_Item__c where Cost_Center_Code__r.Cost_Center__c =:rec.Cost_Center__c and WBS_Code__r.WBS__c =:rec.WBS_Code__c];
        for(gFRS_Ltng_Funding_Allocation_Line_Item__c fal:recordList){
            appIds.add(fal.gFRS_Funding_Allocation__r.gfrs_application__c);                
            
        }
       

        return [SELECT Id, Name,Status__c, Sub_Status__c,Requested_Amount__c,Approved_Amount__c,Record_Type__c
            FROM gFRS_Ltng_Application__c where Id=:appIds];
    }
}