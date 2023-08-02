/**
* @author ADMD Team
* @date 10/04/2013
* @description gFRS_FundingProcess class - main abstract class for implementation ESB/SAP payment and refund process.
*/
public abstract without sharing class gFRS_FundingProcess
{
    public id idPaymentType{get;set;}
    public id idRefundType{get;set;}
    
    public gFRS_FundingProcess(){
        
        for (RecordType rt :[SELECT Id, Name FROM RecordType WHERE SObjectType = 'GFRS_Funding_Allocation__c' AND DeveloperName IN ('Payment', 'Refund')])
        {
            if (rt.Name == 'Payment') idPaymentType = rt.Id;
            if (rt.Name == 'Refund') idRefundType = rt.Id;
        } 
    }
    
    public virtual void createFundingAllocation(Map<ID, GFRS_Funding_Request__c> newRequests, Map<id,gFRS_Funding_Request__c> oldRequests)
    {
       //do nothing implementation must be overrided in Payment/Refund classes
    }
    
    public virtual void createDefaultFALineItems( GFRS_Funding_Allocation__c[] arrFundingAllocations )
    {
      //do nothing implementation must be overrided in Payment/Refund classes
    }
     
    public virtual void  updateFieldInitiatedExhibitsSplits(GFRS_Funding_Request__c[] newRequests, Map<id,GFRS_Funding_Request__c> oldMap, Map<id,GFRS_Funding_Request__c> newMap)
    {
        
    }
    
    public virtual void resetFALITotalAmount( gFRS_Funding_Request__c[] arrNewRequest, Map<id,gFRS_Funding_Request__c> oldMapRequest )
    {
        //do nothing implementation must be overrided in Payment/Refund classes   
    }
    
     public virtual gFRS_Funding_Allocation_Line_Item__c[] updateFALIFundingRequestType( gFRS_Funding_Request__c[] newRequests, Map<id,gFRS_Funding_Request__c> oldRequestMap ){
        //do nothing implementation must be overrided in Payment/Refund classes
        return null;  
     }
     
    /**
    * @author ADMD Team
    * @date 10/04/2013
    * @description CheckESBPaymentUpdate method - update Payment/Refund history record staus to Success
    *  if ESB populated SAP_Doc_ID__c field on gFRS_Payment_History__c object.
    *
    */
     public static void CheckESBPaymentUpdate(gFRS_Payment_History__c[] newPaymenList,Map<Id,gFRS_Payment_History__c> oldMap)
     {
        
        
        for(gFRS_Payment_History__c currentPayment: newPaymenList)
         {
            gFRS_Payment_History__c oldItem=oldMap.get(currentPayment.id);
            if (currentPayment.SAP_Doc_ID__c !=null && currentPayment.SAP_Doc_ID__c != oldItem.SAP_Doc_ID__c)
            {
                //update status to Success.
                currentPayment.Status__c = 'Success';
                
                //set the payment/refund date to today's date
                currentPayment.Date__c = Date.today();
            }

         }
     }
     
    /**
    * @author ADMD Team
    * @date 10/04/2013
    * @description releasePaymentHistoryApprovesFR - sets the status to approved if the paymentHistory is set to released by the ESB
    */
    public static void releasePaymentHistoryApprovesFR( gFRS_Payment_History__c[] newList, Map<id,gFRS_Payment_History__c> oldMap ){
        gFRS_Payment_History__c[] changedHistories = new gFRS_Payment_History__c[]{};

        //-- filter to only those objects changing the approval steps
        gFRS_ObjectUtil.filterChangedObjects( newList, oldMap, 'ESB_Error__c', changedHistories );
        
        if( changedHistories == null || changedHistories.size() < 1 ) return;

        Set<id> paymentRequestIds                         = GFRS_ObjectUtil.createIdFieldSet( changedHistories, 'Grant__c' );
        gFRS_Funding_Request__c[] paymentRequests         = [ select id, Status__c, Sub_Status__c, LOA_Signed__c, Record_Type_Name__c,Foundation_Classified__c from gFRS_Funding_Request__c where id in :paymentRequestIds ];
        Map<id,gFRS_Funding_Request__c> paymentRequestMap = new Map<id,gFRS_Funding_Request__c>( paymentRequests );
        
        gFRS_Funding_Request__c changedRequest            = null;
        gFRS_Funding_Request__c[] changedRequests         = new gFRS_Funding_Request__c[]{};
        
        String lowerMsg                                   = null;
        String newSubStatus                               = null;
       
        for( gFRS_Payment_History__c changedHistory : changedHistories ){
            if( changedHistory.ESB_Error__c != null ){
                lowerMsg = changedHistory.ESB_Error__c.toLowerCase();
                if( lowerMsg.indexOf( gFRS_Util.IS_SUCCESSFULLY_RELEASED ) > 0 ||
                    (gFRS_Util.PAYMENT_TYPE_PAYMENT.equals( changedHistory.Payment_Type__c ) && lowerMsg.indexOf( gFRS_Util.IS_SUCCESSFULLY_SUBMITTED ) > 0 )
                ){
                    changedRequest = paymentRequestMap.get( changedHistory.Grant__c );
                     
                    if( gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals( changedRequest.Record_Type_Name__c ) ){

                        changedRequest.Sub_Status__c          = gFRS_Util.REQUEST_SUB_STATUS_PAYMENT;
                        changedRequest.External_Sub_Status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;

                    } else if( !gFRS_Util.YES.equals( changedRequest.LOA_Signed__c )){

                        changedRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA;
                        
                    } else if( gFRS_Util.TYPE_HC_CHAR_NAME.equals( changedRequest.Record_Type_Name__c ) ||
                        gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals( changedRequest.Record_Type_Name__c ) ||
                        gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME.equals( changedRequest.Record_Type_Name__c ) ||
                        gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals( changedRequest.Record_Type_Name__c )
                    ){
                    	//according to jira 3776 Status is changing to Approved only for non foundation when sap doc id is updated form esb side	
                    	if( changedRequest.Foundation_Classified__c == 'FALSE'){
                            changedRequest.Sub_Status__c          = gFRS_Util.REQUEST_SUB_STATUS_APPROVED;
                            changedRequest.External_Sub_status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;	
                    	}
                    } else if (gFRS_Util.TYPE_IMED_NAME.equals( changedRequest.Record_Type_Name__c )){
                        // After Payment is successfully submitted, for IMED the sub-status and external sub-status are handled through
                        // Workflow Rule : gFRS Change IMED Status Payment LOA Signed
                        // Workflow Rule : gFRS Change IMED Status Payment LOA Not Signed
                    } else {
                        changedRequest.Sub_Status__c          = gFRS_Util.REQUEST_SUB_STATUS_PAYMENT;
                        changedRequest.External_Sub_status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;
                    }

                    changedRequests.add( changedRequest );
                }
            }
        }

        if( changedRequests.size() > 0 ) update changedRequests;
    }
        
      /**
    * @author ADMD Team
    * @date 10/04/2013
    * @description updateRefundedAmountAfterRefundHistoryDeleted method - updates Refunded Amount on FOR while refund history record was submitted successfully.
    * Invoked on after delete trigger on GFRS_Payment_History__c object.
    */    
     public static void updateRefundedAmountAfterRefundHistoryDeleted(gFRS_Payment_History__c[] listPaymentHistory )
     {
         
         gFRS_Funding_Request__c[] listFRForUpdate = new gFRS_Funding_Request__c[]{};
         
         //create list of FR ids for update. 
         Set<Id> setOfFRIds = gFRS_ObjectUtil.createIdFieldSet(listPaymentHistory, 'Grant__c' );
         //get list of funding requests records.
         gFRS_Funding_Request__c[] tabFR = [select Id, Refunded_Amount__c from gFRS_Funding_Request__c where id in : setOfFRIds];
         //Create map of Funding requests records
         Map<id, gFRS_Funding_Request__c> mapFR = new Map<id,gFRS_Funding_Request__c>(tabFR);   
         
            
         for (gFRS_Payment_History__c payRec : listPaymentHistory)
         {
             
             if(payRec.Payment_Type__c=='Refund' && (payRec.Status__c=='Success' || payRec.Status__c=='Submitted'))
             {
                 gFRS_Funding_Request__c fr = mapFR.get(payRec.Grant__c);
                 fr.Refunded_Amount__c      -=payRec.Amount__c;

                 listFRForUpdate.Add(fr);
             }
         }
         
         if(listFRForUpdate.Size()>0)
         {
            update listFRForUpdate;
         }
     }
     
        /**
    * @author ADMD Team
    * @date 10/04/2013
    * @description updateRefundedAmountAfterRefundHistorySuccess method - updates Refunded Amount on FOR while refund history record was submitted successfully.
    * Invoked on after update trigger on GFRS_Payment_History__c object.
    */    
     public static void updateRefundedAmountAfterRefundHistorySuccess(gFRS_Payment_History__c[] listRefundHistory, Map<id,gFRS_Payment_History__c> oldMap)
     {
        gFRS_Payment_History__c[] changedRecordsRefHist = new gFRS_Payment_History__c[]{};
        //-- filter to only those objects changing the status
        gFRS_ObjectUtil.filterChangedObjects( listRefundHistory, oldMap, 'Status__c', changedRecordsRefHist );

        if( changedRecordsRefHist == null || changedRecordsRefHist.size() < 1 ) return;
         
         gFRS_Funding_Request__c[] listFRForUpdate = new gFRS_Funding_Request__c[]{};
         
         //create list of FR ids for update. 
         Set<Id> setOfFRIds = gFRS_ObjectUtil.createIdFieldSet(changedRecordsRefHist, 'Grant__c' );
         //get list of funding requests records.
         gFRS_Funding_Request__c[] tabFR = [select Id, Refunded_Amount__c from gFRS_Funding_Request__c where id in : setOfFRIds];
         //Create map of Funding requests records
         Map<id, gFRS_Funding_Request__c> mapFR = new Map<id,gFRS_Funding_Request__c>(tabFR);   
         
            
         for (gFRS_Payment_History__c refRec : listRefundHistory)
         {
             
             if(refRec.Payment_Type__c=='Refund' && refRec.Status__c=='Success')
             {
                 gFRS_Funding_Request__c fr = mapFR.get(refRec.Grant__c);
                 fr.Refunded_Amount__c      +=refRec.Amount__c;

                 listFRForUpdate.Add(fr);
             }
         }
         
         system.debug('listFRForUpdate.Size() ->' + listFRForUpdate.Size());
         if(listFRForUpdate.Size()>0)
         {
         	update listFRForUpdate;
         }
     }
}