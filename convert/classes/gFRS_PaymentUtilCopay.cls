/**
* @author ADMD Team
* @date 12/04/2013
* @description gFRS_PaymentUtil class - util helper class for payment process.
*/
public without sharing class gFRS_PaymentUtilCopay
{
    
    //Payment Types
    public static final String PAYMENT_TYPE                          = 'Payment';
    public static final String REFUND_TYPE                           = 'Refund';
    
    //gCOI actions if an error occurrs while the payment was being sent.
    public static final String ACTION_PAYMENT_FAILED                 = 'Payment to SAP Failed';
    public static final String UPDATE_PAYMENT_FAILED                 = 'Update payment process info failed';
    
    //Payment statuses
    public static final String PAYMENT_STATUS_CANCELED               = 'Canceled';
    public static final String PAYMENT_STATUS_INITIALIZED            = 'Initialized';
    public static final String PAYMENT_STATUS_PROCESSING             = 'Processing';
    public static final String PAYMENT_STATUS_SUBMITTED              = 'Submitted';
    public static final String PAYMENT_STATUS_SUCCESS                = 'Success';
    public static final String PAYMENT_STATUS_ERROR                  = 'Error';
    
    //Payment substatuses
    public static final String PAYMENT_SUB_STATUS_PENDING_LOA        = 'Pending LOA';
    public static final String PAYMENT_SUB_STATUS_PAYMENT_PROCESSING = 'Payment Processing';
    public static final String PAYMENT_SUB_STATUS_PAYMENT_SENT       = 'Payment Sent';
    public static final String PAYMENT_SUB_STATUS_CHECK_CACHED       = 'Check Cashed';
    public static final String PAYMENT_SUB_STATUS_WAITING            = 'Waiting for Response';
    public static final String PAYMENT_SUB_STATUS_ERROR              = 'Error';
    
    //SAP Payment methods
    public static final String PAYMENT_METHOD_C                      = 'US/C';
    public static final String PAYMENT_METHOD_V                      = 'US/V';
    public static final String PAYMENT_METHOD_Z                      = 'US/Z';
    
    public static final String SAPFUNDINGTYPE                        = 'Copay';
    

    /**
    * @author ADMD Team
    * @date 19/03/2015
    * @description setPaymentMethod method - sets Payment Method.
    */
  /*  public static String getPaymentMethod(String paymentMethodFromESB){
      
      String result = null;
      
    if(paymentMethodFromESB == PAYMENT_METHOD_C){
      result = System.Label.gFRS_PaymentMethodCheck;
    }else if(paymentMethodFromESB == PAYMENT_METHOD_V){
      result = System.Label.gFRS_PaymentMethodACH;
    }else if(paymentMethodFromESB == PAYMENT_METHOD_Z){
            result = System.Label.gFRS_PaymentMethodWire;
        }
        else if(paymentMethodFromESB == PAYMENT_METHOD_5){
            result = System.Label.gFRS_PaymentMethodVirtualCreditCard;
        }
        return result;
    } */

    
    
    /**
    * @author ADMD Team
    * @date 19/03/2015
    * @description setPaymentSubStatus method - sets Payment Sub-Status.
    */
  /*  public static String getPaymentSubStatus(String paymentStatus, String LOASigned, String sapPaymentDocumentId, String sapDocId, Date encashmentDate,String paymentType){
      
      String resultSubStatus = null;
      
    if(paymentStatus == PAYMENT_STATUS_ERROR){
      resultSubStatus = PAYMENT_SUB_STATUS_ERROR;
    }else if(paymentStatus == PAYMENT_STATUS_SUCCESS){
      if(paymentType == REFUND_TYPE){
        
        resultSubStatus = REFUND_TYPE;
      }else{
        //if not refund by default it should be payment type
        if(LOASigned != 'Yes' && sapDocId != null){
          resultSubStatus = PAYMENT_SUB_STATUS_PENDING_LOA;
        }else if(LOASigned == 'Yes' && sapDocId != null){
                  resultSubStatus = PAYMENT_SUB_STATUS_PAYMENT_PROCESSING;
              } 
              if(sapPaymentDocumentId != null){
                  resultSubStatus = PAYMENT_SUB_STATUS_PAYMENT_SENT;
              }
              if(encashmentDate != null){
                  resultSubStatus = PAYMENT_SUB_STATUS_CHECK_CACHED;
              }
      }
        }else if(paymentStatus == PAYMENT_STATUS_SUBMITTED){
            resultSubStatus = PAYMENT_SUB_STATUS_WAITING;
        } 
    
    
    return resultSubStatus;
    }  */ 
    
    /**
    * @author ADMD Team
    * @date 19/03/2015
    * @description setPaymentSubStatus for collection of payments
    */
 /*   public static void setSubStatusAndBlockForPayments(Map<Id,GFRS_Payment_History__c> paymentsMap,Map<Id,GFRS_Payment_History__c> oldPaymentsMap){
        Map<ID,Set<ID>> requestPaymentsMap = new Map<ID,Set<Id>>();
        
        for(GFRS_Payment_History__c p : paymentsMap.values()){
            GFRS_Payment_History__c paymentOld = oldPaymentsMap.get(p.id);
            if(p.SAP_Doc_ID__c != paymentOld.SAP_Doc_ID__c || p.SAP_Payment_Document_ID__c != paymentOld.SAP_Payment_Document_ID__c || p.Encashment_Date__c != paymentOld.Encashment_Date__c || p.Status__c != paymentOld.Status__c){
                if(requestPaymentsMap.containsKey(p.Grant__c)){
                    Set<ID> tmpSet = requestPaymentsMap.get(p.Grant__c);
                    tmpSet.add(p.id);
                }else{
                    requestPaymentsMap.put(p.Grant__c,new Set<Id>{p.id});
                }
            }
        }
        
        Map<Id,GFRS_Funding_Request__c> fundingRequestMap = new Map<Id,GFRS_Funding_Request__c>([Select LOA_Signed__c from GFRS_Funding_Request__c where id in :requestPaymentsMap.keySet()]);
        for(Set<Id> paymentSetIDs : requestPaymentsMap.values()){
            for(Id paymentId : paymentSetIDs){
              
                GFRS_Payment_History__c paymentSubStatusToUpdate = paymentsMap.get(paymentId);
                String requestLOA = fundingRequestMap.get(paymentSubStatusToUpdate.Grant__c) != null ? fundingRequestMap.get(paymentSubStatusToUpdate.Grant__c).LOA_Signed__c : null;
                String subStatusResult = getPaymentSubStatus(paymentSubStatusToUpdate.Status__c, requestLOA, paymentSubStatusToUpdate.SAP_Payment_Document_ID__c, paymentSubStatusToUpdate.SAP_Doc_ID__c, paymentSubStatusToUpdate.Encashment_Date__c,paymentSubStatusToUpdate.Payment_Type__c);
                
                if(subStatusResult != null){
                  paymentSubStatusToUpdate.Payment_Sub_status__c = subStatusResult;
                }
                
                if (requestLOA != 'Yes' && paymentSubStatusToUpdate.SAP_Doc_ID__c != null && paymentSubStatusToUpdate.SAP_Doc_ID__c != ''){
                    paymentSubStatusToUpdate.Payment_Block__c = 'I';  
                }
                
            }
        }    
    }  */
    
    
     /**
    * @author ADMD Team
    * @date 19/03/2015
    * @description setSubStatusForPaymentsWhenLoaChanged for collection of payments
    */
    
 /*   public static void setSubStatusForPaymentsWhenLoaChanged(Map<Id,GFRS_Funding_Request__c> requestMap, Map<Id,GFRS_Funding_Request__c> oldRequestMap){
        Set<id> requestsToRetriv = new Set<ID>();
        List<GFRS_Payment_History__c> paymentsToUpdate = new List<GFRS_Payment_History__c>();
        Map<Id,List<GFRS_Payment_History__c>> requestPayments = new Map<Id,List<GFRS_Payment_History__c>>();
        for (GFRS_Funding_Request__c r : requestMap.values()) {
            GFRS_Funding_Request__c tmpRequest = oldRequestMap.get(r.id);
            if(tmpRequest != null && r.LOA_Signed__c != tmpRequest.LOA_Signed__c && r.LOA_Signed__c == 'Yes') {
                requestsToRetriv.add(r.id);
            }
        }
        for (GFRS_Funding_Request__c r : requestsToRetriv.isEmpty() ? new GFRS_Funding_Request__c[]{ } : [
            select (
                select Encashment_Date__c, Status__c, Payment_Sub_status__c, SAP_Payment_Document_ID__c, SAP_Doc_ID__c,Payment_Type__c,Payment_Block__c from Payment_History__r where Payment_Sub_status__c=: PAYMENT_SUB_STATUS_PENDING_LOA
            ) from GFRS_Funding_Request__c where id in: requestsToRetriv
        ]) {
            String LoaSign = requestMap.get(r.id).LOA_Signed__c;
            for(GFRS_Payment_History__c p : r.Payment_History__r){
              String subStatusResult = getPaymentSubStatus(p.Status__c, LoaSign, p.SAP_Payment_Document_ID__c, p.SAP_Doc_ID__c, p.Encashment_Date__c,p.Payment_Type__c);
              if(subStatusResult != null){
                  p.Payment_Sub_status__c = subStatusResult;
                  p.Payment_Block__c=null;
                  paymentsToUpdate.add(p);
              } else {
                //always reset Payment_Block__c to null when LOA is signed
                p.Payment_Block__c=null;
                  paymentsToUpdate.add(p);
              }
            }
        }
        update paymentsToUpdate;
    }  */
    
    
    /**
    * @author ADMD Team
    * @date 13/12/2013
    * @description canSubmitFundingAllocationPayment method - Checks whether the funding request can be submitted for payment.
    * @param checkActiveHistory (Boolean) - whether to check if the activePaymentHistory exists as another flag to raise.
    */
    public static Boolean canSubmitFundingAllocationPayment(Boolean stopIfBadActiveHistory, gFRS_Copay_Payment_History__c activePaymentHistory, gFRS_Copay_Funding_Request__c fundReq, GFRS_Copay_Funding_Allocation__c fa, GFRS_Copay_Funding_Allocation_Line_Item__c[] splitLines)
    {
        //check if there is any INITIALIZED payment.
        List<gFRS_Copay_Payment_History__c> lstPaymentHistoryInit = new List<gFRS_Copay_Payment_History__c>();
        
        if(activePaymentHistory!=null)
        {
            //check other initialized payments
            lstPaymentHistoryInit = [ SELECT Id, Status__c FROM gFRS_Copay_Payment_History__c WHERE Payment_Type__c = 'Payment' AND Id !=:activePaymentHistory.Id AND (Status__c =: PAYMENT_STATUS_INITIALIZED OR Status__c =: PAYMENT_STATUS_PROCESSING OR Status__c =: PAYMENT_STATUS_SUBMITTED ) AND Grant__c =: fundReq.Id AND isDeleted = false ]; 
        }
        else
        {
            lstPaymentHistoryInit = [ SELECT Id, Status__c FROM gFRS_Copay_Payment_History__c WHERE Payment_Type__c = 'Payment' AND (Status__c =: PAYMENT_STATUS_INITIALIZED OR Status__c =: PAYMENT_STATUS_PROCESSING OR Status__c =: PAYMENT_STATUS_SUBMITTED ) AND Grant__c =: fundReq.Id AND isDeleted = false];
        }  
        
        if (lstPaymentHistoryInit.size()>0)
        {
            System.debug(System.Label.gFRS_Msg_NoCreatePayInit);
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_Msg_NoCreatePayInit ));
            return( false );
        }
        
        if(fa.Payment_Amount__c <=0){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_PAY_AMT_ZERO_UI ));
            return( false );
        }
                
        //QC 24147 Add validation from validation rule
    /*    if(fundReq.Delivery_Method__c == 'Vendor' && (fundReq.Attention_To__c == null || fundReq.Attention_To__c == '')){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please specify Attention To for Vendor delivery method.' ));
            return( false );
        }  */
        
        //-- check for valid values
        if( stopIfBadActiveHistory && (activePaymentHistory == null || activePaymentHistory.SAP_Request_ID__c == null )){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_HISTORY_COULD_NOT_CREATE ));
            return( false );
        }
        
        if( fundReq.Delivery_Method__c == gFRS_Util.DELIVERY_METHOD_MANUAL ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_DELIVERY_METHOD_MANUAL ));
            return(false);
        }
        
        if( fundReq.Status__c != gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION || (fundReq.Status__c == gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION && fundReq.Sub_Status__c != gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA && fundReq.Sub_Status__c != gFRS_Util.REQUEST_SUB_STATUS_PAYMENT && fundReq.Sub_Status__c != gFRS_Util.REQUEST_SUB_STATUS_APPROVED)){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_STATUSES_NOT_VALID ));
            return(false);
        }
        
        system.debug('tot '+splitLines);
        Double totalApproved = fundReq.Total_Payment_Amount__c != null ? fundReq.Total_Payment_Amount__c : 0;
    /*    if( fundReq.Refundable_Deposit_Amount_if_any__c != null ) totalApproved -= fundReq.Refundable_Deposit_Amount_if_any__c;
        if( totalApproved < 0 ) totalApproved = 0;  */
        
        Double splitTotal = 0;
        gFRS_SubmitGrantSAPCopay.Split_element line = null;
        for(GFRS_Copay_Funding_Allocation_Line_Item__c l : splitLines)
        {
            line = new gFRS_SubmitGrantSAPCopay.Split_element();
            if(l.Line_Item_Total__c != null){
                splitTotal += l.Line_Item_Total__c;
            }   
        }
        //-- if the total Amount does not match the split total
        if( !gFRS_Util.floatEquals( totalApproved, splitTotal )){
            System.debug('<<<<<DIFFERS '+totalApproved+'<<<< '+splitTotal);
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_SUM_SPLITS_DIFFER ));
            return(false);
        }
      
        return( true );
    }

    

    /**
    * @author ADMD Team
    * @date 13/12/2013
    * @description createActivePaymentHistory method - Creates the temporary payment history record.
    * @INVARIANT: Payment_Call_Counter__c incremented by one
    * @INVARIANT: gFRS_Payment_History__c record is created and saved to the temporary payment history
    */
 /*   public static GFRS_Payment_History__c createActivePaymentHistory(gFRS_Funding_Request__c fundReq)
    {
        if( fundReq == null || fundReq.id == null ) return (null);
        
        //-- increment the call counter
        fundReq.Payment_Call_Counter__c += 1;
        try {
            update (new GFRS_Funding_Request__c(Id = fundReq.Id, Payment_Call_Counter__c = fundReq.Payment_Call_Counter__c ));
            
            String sapRequestId = fundReq.Name + '_' + fundReq.Payment_Call_Counter__c;
            
            Double paymentAmount = fundReq.Total_Approved_Amount__c;
            if( fundReq.Refundable_Deposit_Amount_if_any__c != null ) paymentAmount -= fundReq.Refundable_Deposit_Amount_if_any__c;
            
            //-- need to preserve the documentId to what is sent to the web service.
            //-- the request id must be stored on the payment history, and the document id (used in release) is set by an external system (based on the request id)
            GFRS_Payment_History__c paymentHistory = new GFRS_Payment_History__c();
            paymentHistory.SAP_Request_ID__c    = sapRequestId;
            paymentHistory.Date__c              = date.today();
            paymentHistory.Grant__c             = fundReq.Id;
            paymentHistory.Amount__c            = paymentAmount;
            paymentHistory.Payment_Type__c      = 'Payment';
            paymentHistory.Action__c            = 'Payment Sent';
            paymentHistory.RecordTypeId         = [ SELECT id from RecordType where DeveloperName = :gFRS_Util.RT_PAYHISTORY_READONLY and SobjectType = 'GFRS_Payment_History__c' ].id;
            //System.debug( 'paymentHistory:' + paymentHistory );
            insert paymentHistory;
            
            //-- only set the activePaymentHistory if successful
            return  paymentHistory;
        } catch (Exception e ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR,  gFRS_Util.getPrettyMessage(e)));
            return null;
        }
        
    } */

    /**
    * @author ADMD Team
    * @date 13/12/2013
    * @description createActivePaymentHistoryUI method - Creates the temporary payment history record for UI.
    * @INVARIANT: Payment_Call_Counter__c incremented by one
    * @INVARIANT: gFRS_Payment_History__c record is created and saved to the temporary payment history
    */
    public static GFRS_Copay_Payment_History__c createActivePaymentHistoryUI(gFRS_Copay_Funding_Request__c fundReq)
    {
        if( fundReq == null || fundReq.id == null ) return (null);
        
        //-- increment the call counter
        fundReq.Payment_Call_Counter__c += 1;
        try {
            update (new GFRS_Copay_Funding_Request__c(Id = fundReq.Id, Payment_Call_Counter__c = fundReq.Payment_Call_Counter__c ));
            
            String sapRequestId = fundReq.Name + '_' + fundReq.Payment_Call_Counter__c;
            
            Double paymentAmount = fundReq.Total_Payment_Amount__c;
        //    if( fundReq.Refundable_Deposit_Amount_if_any__c != null ) paymentAmount -= fundReq.Refundable_Deposit_Amount_if_any__c;
            
            //-- need to preserve the documentId to what is sent to the web service.
            //-- the request id must be stored on the payment history, and the document id (used in release) is set by an external system (based on the request id)
            GFRS_Copay_Payment_History__c paymentHistory = new GFRS_Copay_Payment_History__c();
            paymentHistory.SAP_Request_ID__c    = sapRequestId;
            paymentHistory.Date__c              = date.today();
            paymentHistory.Grant__c             = fundReq.Id;
            paymentHistory.Amount__c            = paymentAmount;
            paymentHistory.Payment_Type__c      = 'Payment';
            paymentHistory.Action__c            = 'Payment Sent';
            paymentHistory.RecordTypeId         = [ SELECT id from RecordType where DeveloperName = :gFRS_Util.RT_PAYHISTORY_READONLY and SobjectType = 'GFRS_Copay_Payment_History__c' ].id;
            paymentHistory.InvokeType__c        = 'UI';
            paymentHistory.Status__c            = PAYMENT_STATUS_INITIALIZED;
            insert paymentHistory;
            
            //-- only set the activePaymentHistory if successful
            return  paymentHistory;
        } catch (Exception e ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR,  gFRS_Util.getPrettyMessage(e)));
            return null;
        }
        
    }
    

    /**
    * @author ADMD Team
    * @date 13/12/2013
    * @description cleanupActivePaymentHistory method - Deletes the temporary payment history record if a failure occurs as part of the cleanup process.
    * @param paymentHistory (gFRS_Payment_History__c) - the payment history to clean-up - delete
    * @throws (Exception) if could not delete the activePaymentHistory.
    */
    public static GFRS_Copay_Payment_History__c cleanupActivePaymentHistory(final GFRS_Copay_Payment_History__c payment) {
        final Set<Id> deletedPaymentIds = new Set<Id>();
        final Id paymentId = payment == null ? null : payment.Id;
        // ESB Error as long text cannot be filtered out in the WHERE clause of the query
        final gFRS_Copay_Payment_History__c[] paymentHistory = paymentId == null ? new gFRS_Copay_Payment_History__c[]{ } : [
            SELECT ESB_Error__c FROM gFRS_Copay_Payment_History__c WHERE Id = :paymentId LIMIT 1
        ];
        // delete payment only when ESB error is blank
        deletedPaymentIds.add(paymentHistory.isEmpty() || String.isNotBlank(paymentHistory[0].ESB_Error__c) ? null : paymentId);
        deletedPaymentIds.remove(null);
        // GFRS-797: suppress any deletion errors including ENTITY_IS_DELETED error
        System.debug('Payment cleanup result: ' + Database.delete(new List<Id>(deletedPaymentIds), false));
        return payment;
    }
    

    /**
    * @author ADMD Team
    * @date 13/12/2013
    * @description sendFutureFundingAllocationPaymentToESB method - Method that submits a funding request from a trigger.
    * This MUST be done via a future method, as web service calls
    * are currently not supported by salesforce at this time.
    */
 /*   @Future(callout=true)
    public static void sendFutureFundingAllocationPaymentToESB( id fundReqId, id activePaymentHistoryId ){
        
        //Get last funding allocation record. Most recent.
        GFRS_Funding_Allocation__c fundingAlloc = [select Id from GFRS_Funding_Allocation__c where Grant_Request__c=: fundReqId ORDER BY CreatedDate DESC Limit 1];
        
        if(fundingAlloc!=null)
        {
            if( ! sendFundingAllocationPaymentToESB( fundReqId, fundingAlloc.Id, null ))
            {
                System.debug('Submit payment fails!' );
            } 
            else
            {
                System.debug('Submit payment success!' );
            }
        }
        else
        {
            system.debug('Cannot send payment. Missing funding allocation.');
        }
    } */


    /**
    * @author ADMD Team
    * @date 13/12/2013
    * @description sendFundingAllocationPaymentToESB method - Submits a funding request for payment.
    * Note: this is to bypass the issue where salesforce cannot allow an update
    * or any DML statement before a web service call.
    * @param requestId (id) - the id of the request to submit
    * @postcondition: request is submitted to the ESB, and sent to response after result
    */
    public static Boolean sendFundingAllocationPaymentToESB(Id fundReqId, Id fundingAllocationId, GFRS_Copay_Payment_History__c activePaymentHistory)
    {
        gFRS_Copay_Funding_Request__c fundReq = null;
        gFRS_Copay_Funding_Allocation__c fundingalloc = null;
        GFRS_Copay_Funding_Allocation_Line_Item__c[] splitLines = null;
        
        //-- for simplicity, query includes the same in both submission and before call out to ensure that validation is correct.
        try 
        {
            fundReq = [ select Id, Name, OwnerId, Organization__r.Organization_Name__c, Funding_Type__c, Total_Approved_Amt__c, Total_Payment_Amount__c, Total_Paid_Amount__c, gCOI_Pending_Actions__c, Refundable_Deposit_Amount_if_any__c,  Status__c, Sub_Status__c,   Organization__r.Id, Request_AutoNumber__c, Payment_Email_Notification__c, LOA_Signed__c, Locationcopay__r.Vendor_Id__c, Locationcopay__r.Payment_Method__c, Locationcopay__r.Partner_Bank_Type__c, Event_Program_Title__c, Requested_Amount__c, Record_Type_Name__c, Delivery_Method__c, Payment_Method__c, Unix_ID__c, Building__c, Send_By_FedEx_cost_center_will_be_charg__c, Attention_To__c, Payment_Call_Counter__c, Payment_Type__c, Payment_Type_Temp__c, Payment_Automation__c, Payment_Automation_Temp__c, Recom_Desk__c, CST_Approver__c, Finance_Approver__c, VP_Approver__c, CFO_Approver__c
                from GFRS_Copay_Funding_Request__c where id = :fundReqId limit 1];
                
            fundingalloc = [ select Id, Name, Baseline_Date__c from gFRS_Copay_Funding_Allocation__c where id = :fundingAllocationId];
            
            splitLines = [select Id, Name, Line_Item_Total__c, GL_Account_Code__c, Amount__c, WBS__c, Cost_Center__c, Cost_Center_Lookup__r.SAP_Company_Code__c,Funding_Allocation__r.GL_Account_Ref__r.name,Commercial_Activity_ID__c from GFRS_Copay_Funding_Allocation_Line_Item__c where Funding_Allocation__c = : fundingAllocationId];
            
        } 
        catch( Exception err )
        {
            String errMsg = gFRS_Util.getPrettyMessage( err );
            if( !System.isFuture() ) ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            return( false );
        }
        
        //-- if the active payment history is null, find the first paymentHistory that is ready for submission.
        try {
            if( activePaymentHistory == null ){
                
                activePaymentHistory                       = [ select id, SAP_Request_ID__c, Status__c, InvokeType__c, Funding_Allocation__c from gFRS_Copay_Payment_History__c where Payment_Type__c = 'Payment' and Grant__c = :fundReq.id and SAP_Request_ID__c != null and Amount__c = null limit 1 ][0];
                activePaymentHistory.Status__c             = PAYMENT_STATUS_INITIALIZED;
                activePaymentHistory.InvokeType__c         = 'TR';
                activePaymentHistory.Funding_Allocation__c = fundingAllocationId;
                
            }
        } 
        catch( Exception err )
        {
            System.debug( 'No Active Payment History sent, and could not find a valid payment history for sending:' + err.getMessage() );
            fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( fundReq.gCOI_Pending_Actions__c, gFRS_PaymentUtil.ACTION_PAYMENT_FAILED );
            fundReq.GeneralExceptionMsg__c = fundReq.GeneralExceptionMsg__c == null ? '' : fundReq.GeneralExceptionMsg__c;
            fundReq.GeneralExceptionMsg__c += String.format('[{0}][{1}] Could not find a valid payment history for sending: {2}\n', new String[]{
                '' + System.now().getTime(), UserInfo.getUserId(), err.getMessage()
            });
            update fundReq;
            return false;
        }
        
        /*2012-03-22 Double Payment Fix */
        //start processing payment
        activePaymentHistory.Status__c = PAYMENT_STATUS_PROCESSING;
        /*********************************************************/
        
        String sapRequestId = activePaymentHistory.SAP_Request_ID__c;
        String companyCode  = gFRS_UtilCopay.determineCompanyCode( splitLines );
        Boolean isSuccess   = true;
        
        //if request is internal substract Refundable_Deposit_Amount_if_any__c
        Decimal paymentAmount = fundReq.Total_Payment_Amount__c;
    /*    if( fundReq.Refundable_Deposit_Amount_if_any__c != null )
        {
            paymentAmount -= fundReq.Refundable_Deposit_Amount_if_any__c;     
        }  */
        
        if (paymentAmount<=0|| paymentAmount==null)
        {
            //if paymnetAmount is equal or less than zero do not submit payment
            paymentAmount                     = 0;
            activePaymentHistory.Status__c    = PAYMENT_STATUS_ERROR;
            activePaymentHistory.ESB_Error__c = System.Label.gFRS_ERROR_PAY_AMT_ZERO;        
            isSuccess                         = false;
        }
        else
        {
            try
            {
            gFRS_SubmitGrantWSCopay.GneCOMM_Grants_SFDC_O_1Port0 sapGrant = new gFRS_SubmitGrantWSCopay.GneCOMM_Grants_SFDC_O_1Port0();
            sapGrant.inputHttpHeaders_x                              = gFRS_Util.createAuthenticationHeaderMap();
            
            GFRS_OrgSettings__c myOrgCS                              = GFRS_OrgSettings__c.getOrgDefaults();
            sapGrant.timeout_x                                       = (integer)myOrgCS.ESBWebServiceTimeOut__c;
            String headerText                                        = fundReq.Event_Program_Title__c;

            if( headerText != null && headerText.length() > 25 ) headerText = headerText.substring(0,25);
            
            //-- determine details
            gFRS_SubmitGrantSAPCopay.Details_element details = new gFRS_SubmitGrantSAPCopay.Details_element();
            details.vendorId                            = fundReq.Locationcopay__r.Vendor_id__c;
          //  details.totalAmount                         = String.valueOf(paymentAmount);
            details.totalAmount                         = paymentAmount.toPlainString();            

        /*    if (fundReq.Payment_Method__c=='Check' || fundReq.Locationcopay__r.Payment_Method__c=='C' || fundReq.Locationcopay__r.Payment_Method__c=='5') {
                details.paymentMethod                  = gFRS_Util.ESB_CHEQUE;
                activePaymentHistory.Payment_Method__c = 'Check';
            } else if (fundReq.Locationcopay__r.Payment_Method__c==null) {
                details.paymentMethod = null;
            } else {
                details.paymentMethod = gFRS_Util.ESB_ACH;
                activePaymentHistory.Payment_Method__c = 'ACH';
            }   */
            details.paymentMethod                  = 'Q';
            activePaymentHistory.Payment_Method__c = 'Q';            
            
            details.paymentBlock                     = (fundReq.LOA_Signed__c == gFRS_Util.YES ||  gFRS_Utilcopay.TYPE_CO_PAY_NAME.equals( fundReq.Record_Type_Name__c ) )? null : 'I';
            details.programTitle                     = '*' + fundReq.Name + ', Donation to Co-pay Assistance Foundation' ;
            details.accountableEmployee              = (fundReq.Delivery_Method__c == gFRS_Util.SFDC_SALES_REP || fundReq.Delivery_Method__c == gFRS_Util.SFDC_ORANGE_POUCH) ? fundReq.Unix_ID__c : null;
            details.delivaryMethods                  = gFRS_Util.translateDeliveryMethodToESB( fundReq.Delivery_Method__c );
            details.fedExRequested                   = fundReq.Send_By_FedEx_cost_center_will_be_charg__c == 'Yes' ? true : false;
            details.attentionTo                      = null;
            details.businessPartnerNotificationEmail = fundReq.Payment_Email_Notification__c;
            details.Split                            = gFRS_PaymentUtilCopay.getGrantSubmitSplitLines( fundReq, splitLines );
            details.partnerBankType                  = fundReq.Locationcopay__r.Partner_Bank_Type__c;
            
            gFRS_SubmitGrantSAPCopay.submitGrantResponse_element response =  sapGrant.submitGrant(sapRequestId, 'Expense', companyCode, date.today(), fundingalloc.Baseline_Date__c, 'USD', headerText, details );
                        
            isSuccess = gFRS_PaymentUtilCopay.handleSubmitGrantResponse(response, sapRequestId, activePaymentHistory, fundReq );
            } 
            catch(System.CalloutException e)
            {
                system.debug('CalloutException line Number:' + e.getLineNumber());
                system.debug('CalloutException getMessage:' + e.getMessage());
                String errMsg = gFRS_Util.getPrettyMessage(e);
            
                if(errMsg.contains('Read timed out'))
                {
                 //ESB sometimes closes connection but it doesn't mean that payment fails.
                 //We need mark such payment as still in processing.
                 activePaymentHistory.Status__c = PAYMENT_STATUS_PROCESSING;
                 activePaymentHistory.ESB_Error__c='';
                }
                else
                {
                //-- since this can be sent through a trigger, we attempt to add in a page message if possible
                if( !System.isFuture() ) ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
                activePaymentHistory.ESB_Error__c = errMsg + '\n';
                activePaymentHistory.Status__c    = PAYMENT_STATUS_ERROR;          
                isSuccess                         = false;
                }           
            }
            catch( Exception err )
            {
            /*2012-03-22 Double Payment Fix commented for further use*/
            activePaymentHistory.Status__c = PAYMENT_STATUS_ERROR;          
            isSuccess = false;
            
            String errMsg = gFRS_Util.getPrettyMessage(err);
            //-- since this can be sent through a trigger, we attempt to add in a page message if possible
            if( !System.isFuture() ) ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            }
        }
        //-- update the payment history now that it has gone through.
        activePaymentHistory.Date__c            = date.today();
        activePaymentHistory.Amount__c          = paymentAmount;
        activePaymentHistory.Payment_Type__c    = gFRS_Util.PAYMENT_TYPE_PAYMENT;
        activePaymentHistory.Action__c          = gFRS_Util.PAYMENT_ACTION_SENT;
        activePaymentHistory.Funding_Allocation__c = fundingAllocationId;
        
        try
        {
            update activePaymentHistory;
        }
        catch (DmlException dmlEx)
        {   
            string errMsg='update activePaymentHistory :'; 
            
            for (Integer i = 0; i < dmlEx.getNumDml(); i++)
            {
                // Process exception here 
                errMsg = errMsg + dmlEx.getDmlMessage(i); 
            }
            fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( fundReq.gCOI_Pending_Actions__c, gFRS_PaymentUtil.UPDATE_PAYMENT_FAILED );
            fundReq.GeneralExceptionMsg__c = fundReq.GeneralExceptionMsg__c == null ? '' : fundReq.GeneralExceptionMsg__c;
            fundReq.GeneralExceptionMsg__c += String.format('[{0}][{1}] {2}\n', new String[]{
                '' + System.now().getTime(), UserInfo.getUserId(), errMsg
            });
            update fundReq;
            
            if( !System.isFuture() ) ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg));
        }
        
        if( !isSuccess ){
            //-- set the payment so it has an action item.
            fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( fundReq.gCOI_Pending_Actions__c, gFRS_PaymentUtil.ACTION_PAYMENT_FAILED );
            fundReq.Sub_Status__c           = 'Process Payment';
            system.debug('isSucces='+isSuccess);
            update fundReq;
        }
    /*    else {
            list<gFRS_CoPay_Disease_State__c> DiseaseSt = new list<gFRS_CoPay_Disease_State__c>();
            list<gFRS_CoPay_Disease_State__c> DisSt = new list<gFRS_CoPay_Disease_State__c>();
            List<EmailTemplate> emailTemplateForIntenttoDonate       = null;
            string intentToDonateEmailBody                           = null;
            string intentToDonateEmailSubject                        = null;
            string ccEmailAddress                                    = 'genentect_cst@gene.com';
            User recipient;
            
            gFRS_Copay_Funding_Allocation__c fundAlloc = [select id, Payment_Amount__c, Paid_Amount__c, Amount_Paid_Flag__c FROM gFRS_Copay_Funding_Allocation__c where id = :fundingAllocationId];
            fundAlloc.Paid_Amount__c = fundAlloc.Payment_Amount__c;
            fundAlloc.Amount_Paid_Flag__c = 'Yes';
            
            update fundAlloc;
            
            DiseaseSt = [Select id, Disease_State_Fund_Name__c, Approved_Amount__c, Payment_Amount__c, PmtAmtTemp__c FROM gFRS_CoPay_Disease_State__c WHERE Copay_Funding_Request__c =:fundReqId ];
            
            emailTemplateForIntenttoDonate=[SELECT TemplateType, Subject, Name, Body,HtmlValue 
                                            FROM EmailTemplate 
                                            WHERE Name = 'Intent to Donate'
                                            AND Folder.DeveloperName='gFRS_Templates'
                                            ORDER BY Name ASC ];
            recipient=[SELECT Id, FirstName, LastName, Name, Email 
                                    FROM User WHERE Id =:fundReq.OwnerId].get(0);                                           
            
            if(emailTemplateForIntenttoDonate.size()>0 ){
                    intentToDonateEmailBody    = replaceEmailBody(emailTemplateForIntenttoDonate[0].Body, fundReq, DiseaseSt) ;
                    intentToDonateEmailSubject = replaceEmailSubject(emailTemplateForIntenttoDonate[0].Subject,fundReq.name);
                    intentToDonateEmailBody   +='\n\n'+'[ref:'+fundReq.id+']';
                    sendIntentToDonateEmail(recipient, intentToDonateEmailSubject, ccEmailAddress, intentToDonateEmailBody);
            }               
            
            for(gFRS_CoPay_Disease_State__c DS : DiseaseSt){
                DS.PmtAmtTemp__c = DS.Payment_Amount__c;
                DS.Approved_Amount__c += DS.Payment_Amount__c;
                DS.Payment_Amount__c = null;                
                DisSt.add(DS);
            }
            update DisSt;
            
            list<gFRS_CoPay_Disease_State__c> DiSt = new list<gFRS_CoPay_Disease_State__c>();
            DiSt = [Select id, Approved_Amount__c, Payment_Amount__c FROM gFRS_CoPay_Disease_State__c WHERE Copay_Funding_Request__c =:fundReqId ];

            fundReq.Total_Paid_Amount__c = 0;
            for(gFRS_CoPay_Disease_State__c DS1 : DiSt){
                fundReq.Total_Paid_Amount__c += DS1.Approved_Amount__c;
            }
            if(fundReq.Payment_Type__c != 'Full'){
                if(fundReq.Payment_Type_Temp__c == ''){
                    fundReq.External_Sub_status__c  = 'Intent to Donate';                   
                }
                fundReq.Payment_Type_Temp__c    = fundReq.Payment_Type__c;
                fundReq.Payment_Automation_Temp__c   = fundReq.Payment_Automation__c;
                fundReq.Payment_Type__c         = '';
           //     fundReq.Payment_Automation__c   = '';
                fundReq.Recom_Desk__c           = '';
           //     fundReq.Sub_Status__c           = 'Process Payment';
                fundReq.CST_Reviewer_Decision__c          = null;
                fundReq.CST_Reviewer_Decision_Date__c     = null;
                fundReq.CST_Approver__c                   = null;
                fundReq.CST_Approver_Decision__c          = null;
                fundReq.CST_Approver_Decision_Date__c     = null;
                fundReq.Finance_Approver__c               = null;
                fundReq.Finance_Approver_Decision__c      = null;
                fundReq.Finance_Approver_Decision_Date__c = null;
                fundReq.VP_Approver__c                    = null;
                fundReq.VP_Approver_Decision__c           = null;
                fundReq.VP_Approver_Decision_Date__c      = null;
                fundReq.CFO_Approver__c                   = null;
                fundReq.CFO_Approver_Decision__c          = null;
                fundReq.CFO_Approver_Decision_Date__c     = null;
                fundReq.Decision_Date__c                  = null;
                fundReq.Decision_Compliance_Flags_PDF__c  = null;
                fundReq.Summary_PDF_snapshot__c           = null;
                fundReq.Vendor_Bank_Reviewed__c           = false;
            }
            else{
                if(fundReq.Payment_Type_Temp__c == ''){
                    fundReq.External_Sub_status__c  = 'Intent to Donate';                   
                }               
                fundReq.Payment_Type_Temp__c    = fundReq.Payment_Type__c;
                fundReq.Payment_Automation_Temp__c   = fundReq.Payment_Automation__c;               
                fundReq.Sub_Status__c           = 'Process Payment'; 
            }
            update fundReq;         
                       
        }  */
        
        return( isSuccess );
    }
    

    /**
    * @author ADMD Team
    * @date 13/12/2013
    * @description getGrantSubmitSplitLines method - Determines the splitllines for the funding request.
    * @PRECONDITION: splitLine.GL_Account_Code__c is set
    * @PRECONDITION: splitLine.line_Item_Total__c is set
    * @PRECONDITION: splitLine.Cost_Center__c is set
    * @PRECONDITION: splitLine.WBS__c is set
    * @PRECONDITION: fundingRequest.Approved_Amount__c is set
    * @PRECONDITION: fundingRequest.Record_Type_Name__c is queried
    * @param fundingRequest (gFRS_Funding_Request__c)
    * @param splitLines (GFRS_Funding_Allocation_Line_Item__c[]) - splits for the funding request
    * @return gFRS_SubmitGrantSAPCopay.Split_element[]
    */
    public static gFRS_SubmitGrantSAPCopay.Split_element[] getGrantSubmitSplitLines( gFRS_Copay_Funding_Request__c fundReq, GFRS_Copay_Funding_Allocation_Line_Item__c[] splitLines ){
        Double totalApproved = fundReq.Total_Approved_Amt__c != null ? fundReq.Total_Approved_Amt__c : 0;
        Double splitTotal = 0;
        
        //String fundingType = gFRS_Util.convertFundingTypeSAP( fundReq.Record_Type_Name__c );
        String fundingType = SAPFUNDINGTYPE;
        
        Decimal paymentAmount = 0; 
        
        gFRS_SubmitGrantSAPCopay.Split_element[] sapSplitLines = new List<gFRS_SubmitGrantSAPCopay.Split_element>(); 
        for(GFRS_Copay_Funding_Allocation_Line_Item__c l : splitLines){
          String helperCommActivity=null;
            paymentAmount = l.Line_Item_Total__c;
            
            gFRS_SubmitGrantSAPCopay.Split_element line = new gFRS_SubmitGrantSAPCopay.Split_element();
            //Modification by Karol
            system.debug('CHECK PASSED VALUE GL ACCOUNT'+ l.Funding_Allocation__r.GL_Account_ref__c);
            line.glAccountCode = String.valueOf(l.Funding_Allocation__r.GL_Account_ref__r.name);
          //  line.splitAmount   =  String.valueOf(paymentAmount);
            line.splitAmount   =  paymentAmount.toPlainString();            
            line.costCenter    = l.Cost_Center__c;
            line.wbsCode       = String.valueOf(l.WBS__c);
            line.fundingType   = fundingType;
            helperCommActivity = String.valueOf(l.Commercial_Activity_ID__c);
            try{
              if(helperCommActivity != null && !helperCommActivity.contains('N/A')){
                line.commericalActivityID=helperCommActivity.substring(0,3);
              }
            }catch(Exception e){system.debug('error occued while passing Commercial_Activity_ID__c to web service');}
            system.debug('check if commercial activity was set properly to webservice:'+line);    
            sapSplitLines.add(line);
        }
        
        return sapSplitLines;
    }
    

    /**
    * @author ADMD Team
    * @date 13/12/2013
    * @description handleSubmitGrantResponse method - Method that handles the response from the web service and applies final logic.
    * @POSTCONDITION: if an error was returned (or thrown) then it is added to the payment history
    * @POSTCONDITION: the current activePaymentHistory is cleared so a new payment can be re-tried
    */
    public static Boolean handleSubmitGrantResponse(gFRS_SubmitGrantSAPCopay.submitGrantResponse_element response, String sapRequestId, GFRS_Copay_Payment_History__c activePaymentHistory, gFRS_Copay_Funding_Request__c fundReq ){
        
        Boolean retVal    = true;
        String errMsg     = null;
        String status     = response.status;
        String allMessage = response.message;
        
        if( status != null ) status = status.toLowerCase();
        
        system.debug('=================');
        system.debug('requestId: ' + sapRequestId + ', response:' + response);
        system.debug('=================');
        system.debug('==response.status->' + response.status);
        system.debug('==response.message->' + response.message);
        
        try {
            if( ('successful').equals( status ))
            {
                /*2012-03-22 Double Payment Fix commented for further use*/
                activePaymentHistory.Status__c    = PAYMENT_STATUS_SUBMITTED;
                activePaymentHistory.ESB_Error__c =  status;
                retVal = true;
            }
            else
            {
                system.debug('=== Payment failed');
                /*2012-03-22 Double Payment Fix commented for further use*/
                activePaymentHistory.Status__c = PAYMENT_STATUS_ERROR;
                
                gFRS_XmlErrorMessageReader errorReader = new gFRS_XmlErrorMessageReader();
                
                XmlStreamReader reader = new XmlStreamReader(gFRS_Util.prepareXmlMessageToParse(response.message));
                gFRS_XmlErrorMessageReader.Error[] errors = errorReader.parseErrors(reader);
                
                activePaymentHistory.ESB_Error__c = '';
                
                for(gFRS_XmlErrorMessageReader.Error err : errors){
                    errMsg = err.getMessage();
                    System.debug( 'fullError:' + err.getMessage() );
                    if( !System.isFuture() ) ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
                    
                    //-- update the error message on the 
                    activePaymentHistory.ESB_Error__c += errMsg + '\n';
                }
                
                if((activePaymentHistory.ESB_Error__c==null || activePaymentHistory.ESB_Error__c =='') && allMessage !='')
                {
                  activePaymentHistory.ESB_Error__c =  allMessage;
                }
                retVal = false;
            }
        } catch (Exception e ){
            system.debug('=== Exception thrown');
            errMsg = gFRS_Util.getPrettyMessage(e);
            if( !System.isFuture() ) ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            activePaymentHistory.ESB_Error__c = errMsg;
            activePaymentHistory.Status__c    = PAYMENT_STATUS_ERROR;
            retVal                            = false;
        }
        
        system.debug('=== retVal->' + retVal);
        return(retVal);
    }
    
    /** 
* @Author gFRS CoPay Team
* @date 26/02/2018
* @description replaceEmailBody method set dynamic values in defined in body of emailTemplate
* 
*/
 /*   public static String replaceEmailBody(String emailBody, gFRS_Copay_Funding_Request__c fundReq, list<gFRS_CoPay_Disease_State__c> DiseaseSt){
        
        String outputBody = '';
        String DisStateDetails = '';
        
        if(emailBody != null){
            outputBody           = emailBody.replace('<<G-#####>>', fundReq.Name);            
            outputBody           = outputBody.replace('<<Foundation name>>', fundReq.Organization__r.Organization_Name__c);  
            for(gFRS_CoPay_Disease_State__c DS : DiseaseSt){
                DisStateDetails     =   DisStateDetails + DS.Disease_State_Fund_Name__c + ',  $' + DS.Payment_Amount__c + '\n';
            }
            outputBody           = outputBody.replace('<<Disease area, amount for each donation line item>>', DisStateDetails); 
        }
        
        return outputBody;
    }  */

        /** 
* @Author gFRS CoPay Team
* @date 26/02/2018
* @description replaceEmailSubject method replace dynamic values defined in subject of emailTemplate
* 
*/
  /*  public static String replaceEmailSubject(String emailSub, string fundReqName){
        if(emailSub != null){
            return EmailSub.replace('<<G-#####>>', fundReqName);
        }
        return '';      
        
    }   */
    
     /** 
* @Author gFRS CoPay Team
* @date 26/02/2018
* @description sendIntentToDonateEmail method - Method used to send intent to donate email
*/
 /*   public static void sendIntentToDonateEmail(user recipient, string intentToDonateEmailSubject, string ccEmailAddress, string intentToDonateEmailBody){
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{recipient.Email});
            mail.setSubject( intentToDonateEmailSubject );     
            mail.setCcAddresses(new List<String>{ccEmailAddress});
            
            mail.setPlainTextBody(intentToDonateEmailBody);
            mail.setOrgWideEmailAddressId([SELECT Id, Address 
                                            FROM OrgWideEmailAddress 
                                            WHERE Address='fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
            
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }catch(Exception ex){
            
        }  
    } */
    
    
     class CustomException extends Exception {}
}