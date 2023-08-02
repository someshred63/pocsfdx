/**
* @author GFRS Dev Team - MG
* @date 26/08/2013
* @description gFRS_InternalCancellationProcess - Cancellation process implementation. 
* http://jira.intranet.roche.com/jira/browse/GFRS-420
* 
*/
public without sharing class gFRS_InternalCancellationProcess
{
    /**
    * @author GFRS Dev Team 
    * @date 09/03/2015
    * @description  processRejectedRequest method -  this method process request after rejection. 
    * Used on before update trigger
    * It checks if rejection was come from standard approval process screen or from Close Funding Request Button.
    * if rejection was from standard approval screen set Ext Status -> Denied, Status -> Closed, Sub-Stat - Denied
    * and send gFRS Internal Denial Email Notification
    * if rejection was from Close Funding Request, statues should remain as is and no additional email.
    */
    public static void processRejectedRequest(gFRS_Funding_Request__c[] newRequestsList, Map<id,gFRS_Funding_Request__c> oldRequests )
    {
        gFRS_Funding_Request__c[] tmpRequestsList = new gFRS_Funding_Request__c[]{}; //this list will contain only cancelled requests.
        gFRS_ObjectUtil.filterChangedObjects( newRequestsList, oldRequests, 'SYS_Request_Approved__c', tmpRequestsList );
        
        //loop on new after update requests only these which has been recently rejected.  
        for(gFRS_Funding_Request__c req : tmpRequestsList)
        {
            //check if internal request and is rejected.
            if(gFRS_Util.isInternalRequest(req.Record_Type_Name__c) && req.SYS_Request_Approved__c == 'No')
            {
                //check if has been rejected from standard approval process. Need set appropriate statues and Decsion Reasons
                if(req.Status__c!='Closed' && req.Sub_Status__c!='Canceled')
                {
                    req.Status__c              = 'Closed';
                    req.Sub_Status__c          = 'Denied';
                    req.External_Sub_status__c = 'Denied';
                    req.Decision_Reasons__c    = GetRejectedDecisionReason(req);
                }
               
            }
            
        }
    }
    
     /**
    * @author GFRS Dev Team - MG 
    * @date 09/03/2015
    * @description  autoRejectRecord method -  this method automaticly rejects request.  
    * Used in gFRS_FundingRequestReadController
    */
    public static void autoRejectRecord(gFRS_Funding_Request__c p_req)
    {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(System.Label.gFRS_AutomatedRejection);
        req.setAction('Reject');

        Id workItemId = getWorkItemId(p_req.id);
 
        if(workItemId == null)
        {
            p_req.addError('Error Occured in autoRejectRecord. WorkItemId is null');
        }
        else
        {
            req.setWorkitemId(workItemId);
            // Submit the request for reject
            Approval.ProcessResult result =  Approval.process(req);
        }
    }
    
     /**
    * @author GFRS Dev Team - MG 
    * @date 09/03/2015
    * @description  getWorkItemId method -  helper method. gets WorkItemId.  
    */
    private static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
 
        for(ProcessInstanceWorkitem workItem  : [SELECT p.Id FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId =: targetObjectId])
        {

            retVal  =  workItem.Id;
        }
        return retVal;
    }
    
     /**
    * @author GFRS Dev Team - MG 
    * @date 09/11/2015
    * @description  GetRejectedDecisionReason method -  Returns Decision Reason based on 
    * Corp Mem/Field Exhbt/Other Promo/Sci/Pip approval process rejected step.
    */
    private static string GetRejectedDecisionReason(gFRS_Funding_Request__c req)
    {
        string decisionReason = '';
        
        if(req.CCO_Decision__c=='Rejected')//if CCO Review step set -> CCO Compliance Denial
        {
            decisionReason = 'CCO Compliance Denial';
        }
        else if(req.Legal_Decision__c=='Rejected')//if Legal Reviewer step set -> Denied by Legal Approver
        {
            decisionReason = 'Denied by Legal Approver';
        }
        else if(req.Financial_Approver_1_Decision__c=='Rejected')//if Business/Financial Approver step set - > Denied by Business/Financial Approver
        {
            decisionReason = 'Denied by Business/Financial Approver';
        } 
        else if(req.Financial_Approver_2_Decision__c=='Rejected')//if Financial Approver 2 step set -> Denied by Business/Financial Approver
        {
            decisionReason = 'Denied by Business/Financial Approver';
        }
        else if(req.Financial_Approver_3_Decision__c=='Rejected')//if Financial Approver 3 step set -> Denied by Business/Financial Approver
        {
            decisionReason = 'Denied by Business/Financial Approver';
        }
        
        return decisionReason;
    }

}