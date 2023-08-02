Public class autoPaymentForExtenalTypes
{
    @InvocableMethod
    public static void submitpaymentEBS(List<Id> appIds)    {
        
        List<gFRS_Ltng_App_Funding_Allocation__c> fundAlclst =             
            [SELECT Id,Name,Approved_Amount__c,Payment_Amounts__c,Payment_Status__c,Auto_Process_Check__c, Created_By_Process__c, Baseline_Date__c,gFRS_Application__r.Name,Record_Type_Name__c,Multiple_payments_associated_with_Rqst__c,Funding_Total__c,Payment_Type__c
             FROM gFRS_Ltng_App_Funding_Allocation__c Where gFRS_Application__c=:appIds limit 5];  
        for(gFRS_Ltng_App_Funding_Allocation__c fundRec:fundAlclst){
            gFRS_Ltng_FundAllcViewController.submitPaymenttoEBS(fundRec.Id);			
        }													
    }

}