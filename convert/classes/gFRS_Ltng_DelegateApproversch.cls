/**
* @author GFRS Dev Team
* @date 29/06/2021
* @description gFRS_Ltng_DelegateApproversch class - schdule job for set user delegation for approval processes. 
* 
*/
global class gFRS_Ltng_DelegateApproversch implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
        gFRS_Ltng_SetDelegateApproverBatch delegatedbtch = new gFRS_Ltng_SetDelegateApproverBatch();
        Database.executeBatch(delegatedbtch,200);
    } 
}