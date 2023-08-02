/**
* @author gFRS 2.0 Team
* @date 08/03/2021
* @description gFRS_Ltng_PaymentUtil class - util helper class for payment process.
*/
public without sharing class gFRS_Ltng_PaymentUtil
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

    /**
    * @author ADMD Team
    * @date 19/03/2015
    * @description setPaymentMethod method - sets Payment Method.
    */
    public static String getPaymentMethod(String paymentMethodFromESB){
        
        String result = null;
        
        if(paymentMethodFromESB == PAYMENT_METHOD_C){
            result = System.Label.gFRS_PaymentMethodCheck;
        }else if(paymentMethodFromESB == PAYMENT_METHOD_V){
            result = System.Label.gFRS_PaymentMethodACH;
        }else if(paymentMethodFromESB == PAYMENT_METHOD_Z){
            result = System.Label.gFRS_PaymentMethodWire;
        }/*
        else if(paymentMethodFromESB == PAYMENT_METHOD_5){
            result = System.Label.gFRS_PaymentMethodVirtualCreditCard;
        }*/

        return result;
    }
    
    
    /**
    * @author ADMD Team
    * @date 19/03/2015
    * @description setPaymentSubStatus method - sets Payment Sub-Status.
    */
    public static String getPaymentSubStatus(String paymentStatus, String LOASigned, String sapPaymentDocumentId, String sapDocId, Date encashmentDate,String paymentType){
        
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
    }
    
    /**
    * @author 
    * @date 
    * @description getGrantSubmitSplitLines method - Determines the splitllines for the funding request.
    * @PRECONDITION: splitLine.GL_Account_Code__c is set
    * @PRECONDITION: splitLine.line_Item_Total__c is set
    * @PRECONDITION: splitLine.Cost_Center__c is set
    * @PRECONDITION: splitLine.WBS__c is set
    * @PRECONDITION: fundingRequest.Approved_Amount__c is set
    * @PRECONDITION: fundingRequest.Record_Type_Name__c is queried
    * @param fundingRequest (gFRS_Funding_Request__c)
    * @param splitLines (GFRS_Funding_Allocation_Line_Item__c[]) - splits for the funding request
    * @return gFRS_SubmitGrantSAP.Split_element[]
    */
    public static gFRS_SubmitGrantSAP.Split_element[] getGrantSubmitSplitLines( gFRS_Ltng_Application__c fundReq, gFRS_Ltng_Funding_Allocation_Line_Item__c[] splitLines ){
        Double totalApproved = fundReq.Approved_Amount__c != null ? fundReq.Approved_Amount__c : 0;
        Double splitTotal = 0;
        
        String fundingType = gFRS_Util.convertFundingTypeSAP( fundReq.Record_Type_Name__c );
        
        Double paymentAmount = 0; 
        
        gFRS_SubmitGrantSAP.Split_element[] sapSplitLines = new List<gFRS_SubmitGrantSAP.Split_element>(); 
        for(gFRS_Ltng_Funding_Allocation_Line_Item__c l : splitLines){
            String helperCommActivity=null;
            paymentAmount = l.Line_Item_Total__c;
            
            gFRS_SubmitGrantSAP.Split_element line = new gFRS_SubmitGrantSAP.Split_element();
            //Modification by Karol
            //system.debug('CHECK PASSED VALUE GL ACCOUNT'+ l.gFRS_Funding_Allocation__r.GL_Account_Ref__c);
            line.glAccountCode = String.valueOf(l.gFRS_Funding_Allocation__r.gFRS_GL_Account__r.Name);
            line.splitAmount   = String.valueOf(paymentAmount);
            line.costCenter    = String.valueOf(l.Cost_Center_Code__r.Cost_Center__c);      // Cost Center
            line.wbsCode       = String.valueOf(l.WBS_Code__r.WBS__c);      //
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
    public static Boolean handleSubmitGrantResponse(gFRS_SubmitGrantSAP.submitGrantResponse_element response, String sapRequestId, gFRS_Ltng_Payment_History__c activePaymentHistory, gFRS_Ltng_Application__c fundReq ){
        
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

    //New Payment 
    
     public static void updateltngPaymentMethod(gFRS_Ltng_Application__c fundingRequest, gFRS_Ltng_Payment_History__c paymentHistory, gFRS_SubmitGrantSAP.Details_element detailsElement) {
        if (String.isNotBlank(fundingRequest.Payment_Method__c) && fundingRequest.Payment_Method__c == 'Check') {
            detailsElement.paymentMethod = 'C';
            paymentHistory.Payment_Method__c = 'C';
        } else {
            if (String.isNotBlank(fundingRequest.Vendor_Detail__r.Payment_Method__c) && fundingRequest.Vendor_Detail__r.Payment_Method__c == '5') {
                detailsElement.paymentMethod = 'C';
                paymentHistory.Payment_Method__c = 'C';
            } else {
                detailsElement.paymentMethod = fundingRequest.Vendor_Detail__r.Payment_Method__c;
                paymentHistory.Payment_Method__c = fundingRequest.Vendor_Detail__r.Payment_Method__c;
            }
        }
    }

    
    
    
    
    @Future(callout=true)
    public static void sendltngFundingAllocationPaymentToESB(id fundReqId,Id fundAlocId, id activePaymentHistoryId ){

        gFRS_Ltng_App_Funding_Allocation__c fundAlloc=[SELECT Id, Name, gFRS_Application__c, Approved_Amount__c, 
                                                       Check_Number__c, Payment_Amounts__c, Organization_Name__c,
                                                       Record_Type_Name__c, Baseline_Date__c FROM gFRS_Ltng_App_Funding_Allocation__c Where Id=:fundAlocId];
        
        
        gFRS_Ltng_Application__c gfrsApp=[Select Id,name ,Requested_Amount__c,Approved_Amount__c,Payment_Method__c,
                                          Record_Type_Name__c,Vendor_Detail__r.Vendor_id__c,Attention_To__c,Vendor_Detail__r.Payment_Method__c,
                                          Partner_Bank_Type__c,Payment_Call_Counter__c,Event_Program_Title__c,LOA_Signed__c,Shrink_Wrap_LOA__c,
                                          Record_Type__c,Payment_Email_Notification__c,Genentech_Employee_Email__c From gFRS_Ltng_Application__c
                                          Where Id=:fundAlloc.gFRS_Application__c];
        
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> fundalcintem=[SELECT Id, Name,Commercial_Activity_ID__c,Line_Item_Total__c, gFRS_Funding_Allocation__c, Amount__c, gFRS_Funding_Allocation__r.gFRS_GL_Account__r.Name,
                                                                      Percent__c, WBS_Description__c, Cost_Center_Description__c,Cost_Center_Code__r.SAP_Company_Code__c,
                                                                      Are_there_multiple_payments_associated_w__c,Cost_Center_Code__r.Cost_Center__c,WBS_Code__r.WBS__c,
                                                                      Payment_Type__c FROM gFRS_Ltng_Funding_Allocation_Line_Item__c Where gFRS_Funding_Allocation__c=:fundAlloc.Id];
        
        gFRS_Ltng_Payment_History__c activePaymentHistory=[SELECT Id,Status__c, Name, RecordTypeId, Amount__c, gFRS_Application__c, Payment_Method__c,  SAP_Doc_ID__c, SAP_Payment_Document_ID__c, gFRS_Funding_Allocation__c, Date__c, Payment_Type__c, Action__c, InvokeType__c, SAP_Request_ID__c, Payment_Refund_Status__c, Type_of_Check_Received__c, Signed_Amount__c, ESB_Error__c, Payment_Sub_status__c, Check_Number__c, Created_Timestamp__c, Encashment_Date__c, I_Block_Released__c, Integration_Id__c, Invoice_Block_Status__c, Note__c
                                                           ,Payment_Block__c, SAP_Payment_Sent_Date__c 
                                                           FROM gFRS_Ltng_Payment_History__c Where Id=:activePaymentHistoryId];        
        
        String sapRequestId = gfrsApp.Name + '_' + gfrsApp.Payment_Call_Counter__c;        
        Double paymentAmount = fundAlloc.Payment_Amounts__c;        
        String sapRequestId1 = gfrsApp.Name + '_' + gfrsApp.Payment_Call_Counter__c;
        String companyCode = gFRS_Ltng_Util.determineCompanyCode(fundalcintem);
        Boolean isSuccess = true;

        gFRS_SubmitGrantLtngWS.GneCOMM_Grants_SFDC_O_1Port0 sapGrant = new gFRS_SubmitGrantLtngWS.GneCOMM_Grants_SFDC_O_1Port0();
        sapGrant.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();        
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        sapGrant.timeout_x = (integer)myOrgCS.ESBWebServiceTimeOut__c;
        String headerText = gfrsApp.Event_Program_Title__c;
        
        if( headerText != null && headerText.length() > 25 )headerText=headerText.substring(0,25);
        
        //-- determine details
        gFRS_SubmitGrantSAP.Details_element details = new gFRS_SubmitGrantSAP.Details_element();
        details.vendorId = gfrsApp.Vendor_Detail__r.Vendor_id__c; // Need clarity '0010462446';
        details.totalAmount = String.valueOf(paymentAmount);
        
        updatePaymentMethod(gfrsApp, activePaymentHistory, details);
        
        details.paymentBlock = (gfrsApp.LOA_Signed__c == gFRS_Util.YES || gfrsApp.Shrink_Wrap_LOA__c == gFRS_Util.YES ||  gFRS_Ltng_Util.Field_Exhibits.equals(gfrsApp.Record_Type__c)) ? null : 'I';
       // details.programTitle = '*'+gfrsApp.Event_Program_Title__c;
        details.programTitle =  '*' + gfrsApp.name + ',' + gfrsApp.Event_Program_Title__c;
        details.accountableEmployee = null; //(fundReq.Delivery_Method__c == gFRS_Util.SFDC_SALES_REP || fundReq.Delivery_Method__c == gFRS_Util.SFDC_ORANGE_POUCH) ? fundReq.Unix_ID__c : null;
        details.delivaryMethods = 'Vendor'; //gFRS_Util.translateDeliveryMethodToESB( gfrsApp.Delivery_Method__c );
        details.fedExRequested = false;
        details.attentionTo = ('ATTN: '+gfrsApp.Attention_To__c).left(20);
        details.businessPartnerNotificationEmail = gfrsApp.Genentech_Employee_Email__c;
        details.Split=gFRS_Ltng_PaymentUtil.getGrantSubmitSplitLines(gfrsApp,fundalcintem );
        details.partnerBankType=gfrsApp.Partner_Bank_Type__c;
        system.debug('@@@ Baseline Date : '+fundAlloc.Baseline_Date__c);
        system.debug('@@@ Today Date : '+date.today());
        if (fundAlloc.Baseline_Date__c != null){
            
            gFRS_SubmitGrantSAP.submitGrantResponse_element response=sapGrant.submitGrant(sapRequestId1,'Expense',companyCode,date.today(),fundAlloc.Baseline_Date__c,'USD',headerText,details );
            System.debug('@@@ response '+response);
            
            isSuccess = gFRS_Ltng_PaymentUtil.handleSubmitGrantltngResponse(response, sapRequestId, activePaymentHistory, gfrsApp );
        }
        else{
        	gFRS_SubmitGrantSAP.submitGrantResponse_element response=sapGrant.submitGrant(sapRequestId1,'Expense',companyCode,date.today(),date.today(),'USD',headerText,details );
            System.debug('@@@ response '+response);

            isSuccess = gFRS_Ltng_PaymentUtil.handleSubmitGrantltngResponse(response, sapRequestId, activePaymentHistory, gfrsApp );
        }   
       // System.debug('@@@ response '+response);

       // isSuccess = gFRS_Ltng_PaymentUtil.handleSubmitGrantltngResponse(response, sapRequestId, activePaymentHistory, gfrsApp );
       
    }
    
    
    @Future(callout=true)
    public static void sendltngFundingAllocationRefundToESB(id fundReqId,Id fundAlocId, id activePaymentHistoryId ){

        // Funding Allocation 
        
        gFRS_Ltng_App_Funding_Allocation__c fundAlloc=[SELECT Id, Name, gFRS_Application__c, Approved_Amount__c, 
                                                       Check_Number__c, Payment_Amounts__c, Organization_Name__c,
                                                       Record_Type_Name__c, Baseline_Date__c FROM gFRS_Ltng_App_Funding_Allocation__c Where Id=:fundAlocId];
        
        
         // Application Query
        
        gFRS_Ltng_Application__c gfrsApp = [Select Id,name ,Requested_Amount__c,Approved_Amount__c,Refund_Due__c,Payment_Method__c,Payment_Email_Notification__c,
                                            Record_Type_Name__c,Vendor_Detail__r.Vendor_id__c,Attention_To__c,Vendor_Detail__r.Payment_Method__c,
                                            Partner_Bank_Type__c,Payment_Call_Counter__c,Event_Program_Title__c,LOA_Signed__c,Refund_Amount_Internal__c,
                                            Record_Type__c From gFRS_Ltng_Application__c
                                            Where Id=:fundAlloc.gFRS_Application__c];
        
        // Funding Allocation Line Item
        
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> fundalcintem = [SELECT Id, Name,Line_Item_Total__c, gFRS_Funding_Allocation__c, Amount__c, gFRS_Funding_Allocation__r.gFRS_GL_Account__r.Name,
                                                                        Percent__c, WBS_Description__c, Cost_Center_Description__c,Cost_Center_Code__r.SAP_Company_Code__c,
                                                                        Are_there_multiple_payments_associated_w__c,Cost_Center_Code__r.Cost_Center__c,WBS_Code__r.WBS__c,
                                                                        Payment_Type__c FROM gFRS_Ltng_Funding_Allocation_Line_Item__c Where gFRS_Funding_Allocation__c=:fundAlloc.Id];
        
        gFRS_Ltng_Payment_History__c activePaymentHistory = [SELECT Id,Status__c, Name, RecordTypeId, Amount__c, gFRS_Application__c, Payment_Method__c,  SAP_Doc_ID__c, SAP_Payment_Document_ID__c, gFRS_Funding_Allocation__c, Date__c, Payment_Type__c, Action__c, InvokeType__c, SAP_Request_ID__c, Payment_Refund_Status__c, Type_of_Check_Received__c, Signed_Amount__c, ESB_Error__c, Payment_Sub_status__c, Check_Number__c, Created_Timestamp__c, Encashment_Date__c, I_Block_Released__c, Integration_Id__c, Invoice_Block_Status__c, Note__c
                                                             ,Payment_Block__c, SAP_Payment_Sent_Date__c 
                                                             FROM gFRS_Ltng_Payment_History__c Where Id=:activePaymentHistoryId];       
        
        String sapRequestId = gfrsApp.Name + '_' + gfrsApp.Payment_Call_Counter__c;        
        Double paymentAmount = gfrsApp.Refund_Amount_Internal__c;        
        String sapRequestId1 = gfrsApp.Name + '_' + gfrsApp.Payment_Call_Counter__c;
        String companyCode = gFRS_Ltng_Util.determineCompanyCode(fundalcintem);//'1010';
        Boolean isSuccess = true;
        
        //if request is internal substract Refundable_Deposit_Amount_if_any__c
        //Double paymentAmount = fundReq.Approved_Amount__c;
        
        gFRS_SubmitGrantLtngWS.GneCOMM_Grants_SFDC_O_1Port0 sapGrant = new gFRS_SubmitGrantLtngWS.GneCOMM_Grants_SFDC_O_1Port0();
        sapGrant.inputHttpHeaders_x=gFRS_Util.createAuthenticationHeaderMap();
        
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        sapGrant.timeout_x=(integer)myOrgCS.ESBWebServiceTimeOut__c;
        String headerText=gfrsApp.Event_Program_Title__c;
        
        if( headerText != null && headerText.length() > 25 )headerText=headerText.substring(0,25);
        
        //-- determine details
        gFRS_SubmitGrantSAP.Details_element details =new gFRS_SubmitGrantSAP.Details_element();
        details.vendorId= gfrsApp.Vendor_Detail__r.Vendor_id__c; // Need clarity '0010462446';
        details.totalAmount=String.valueOf(paymentAmount);
        
        //updatePaymentMethod(gfrsApp, activePaymentHistory, details);        
        //details.paymentBlock=(gfrsApp.LOA_Signed__c ==gFRS_Util.YES ||  gFRS_Ltng_Util.Field_Exhibits.equals(gfrsApp.Record_Type__c)) ? null : 'I';
        //details.accountableEmployee=null; //(fundReq.Delivery_Method__c == gFRS_Util.SFDC_SALES_REP || fundReq.Delivery_Method__c == gFRS_Util.SFDC_ORANGE_POUCH) ? fundReq.Unix_ID__c : null;
        //details.businessPartnerNotificationEmail =null;//gfrsApp.Payment_Email_Notification__c;
        
        details.paymentMethod = 'C';//added only for a valid call. ESB will not use this field while processing the refund.
        details.paymentBlock = 'I';
        details.accountableEmployee = gfrsApp.Payment_Email_Notification__c;
        details.businessPartnerNotificationEmail = gfrsApp.Payment_Email_Notification__c;
        
        details.programTitle='*'+ gfrsApp.Event_Program_Title__c;
        details.delivaryMethods='Vendor'; //gFRS_Util.translateDeliveryMethodToESB( gfrsApp.Delivery_Method__c );
        details.fedExRequested=false;
        details.attentionTo=('ATTN: '+gfrsApp.Attention_To__c).left(20);//null;//

        details.Split=gFRS_Ltng_PaymentUtil.getGrantSubmitSplitLines(gfrsApp,fundalcintem );
        details.partnerBankType=gfrsApp.Partner_Bank_Type__c;
        System.debug('@@@ sapRequestId1 '+sapRequestId1);
        System.debug('@@@ companyCode '+companyCode);
        System.debug('@@@ headerText '+headerText);
        System.debug('@@@ details '+details);
        
        
        gFRS_SubmitGrantSAP.submitGrantResponse_element response=sapGrant.submitGrant(sapRequestId1,'Refund',companyCode,date.today(),date.today(),'USD',headerText,details );
        System.debug('@@@ response '+response);

        isSuccess = gFRS_Ltng_PaymentUtil.handleSubmitGrantltngResponse(response, sapRequestId, activePaymentHistory, gfrsApp );
       
    }
    
    public static Boolean handleSubmitGrantltngResponse(gFRS_SubmitGrantSAP.submitGrantResponse_element response, String sapRequestId, gFRS_Ltng_Payment_History__c activePaymentHistory, gFRS_Ltng_Application__c fundReq ){
        
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
                
                activePaymentHistory.Status__c    = PAYMENT_STATUS_SUBMITTED;
                activePaymentHistory.Payment_Sub_status__c    = PAYMENT_SUB_STATUS_WAITING;
                activePaymentHistory.ESB_Error__c =  status;
                update activePaymentHistory;
                
                update (new gFRS_Ltng_App_Funding_Allocation__c(Id = activePaymentHistory.gFRS_Funding_Allocation__c, Payment_Status__c=PAYMENT_STATUS_SUBMITTED));
              
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
                update activePaymentHistory;
                update (new gFRS_Ltng_App_Funding_Allocation__c(Id = activePaymentHistory.gFRS_Funding_Allocation__c, Payment_Status__c=PAYMENT_STATUS_ERROR));
                retVal = false;
            }
        } catch (Exception e ){
            system.debug('=== Exception thrown');
            errMsg = gFRS_Util.getPrettyMessage(e);
            if( !System.isFuture() ) ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            activePaymentHistory.ESB_Error__c = errMsg;
            activePaymentHistory.Status__c    = PAYMENT_STATUS_ERROR;
            update activePaymentHistory;
            retVal                            = false;
        }
        
        system.debug('=== retVal->' + retVal);
        return(retVal);
    }
    
        
    /**
    * @author CHAVVAS - GFRS 2.0 DEV TEAM
    * @date 19/10/2021
    * @description set Block And SubStatus For Updated Payments for collection of payments
    */
    public static void setBlockAndSubStatusForPayments(Map<Id,gFRS_Ltng_Payment_History__c> paymentsMap, Map<Id,gFRS_Ltng_Payment_History__c> oldPaymentsMap){
        Map<ID,Set<ID>> applicationPaymentsMap = new Map<ID,Set<Id>>();
        
        for(gFRS_Ltng_Payment_History__c p : paymentsMap.values()){
            gFRS_Ltng_Payment_History__c paymentOld = oldPaymentsMap.get(p.id);
            if(p.SAP_Doc_ID__c != paymentOld.SAP_Doc_ID__c || p.SAP_Payment_Document_ID__c != paymentOld.SAP_Payment_Document_ID__c || p.Encashment_Date__c != paymentOld.Encashment_Date__c || p.Status__c != paymentOld.Status__c){
                if(applicationPaymentsMap.containsKey(p.gFRS_Application__c)){
                    applicationPaymentsMap.get(p.gFRS_Application__c).add(p.id);
                }else{
                    applicationPaymentsMap.put(p.gFRS_Application__c,new Set<Id>{p.id});
                }
            }
        }
        
        Map<Id,gFRS_Ltng_Application__c> applicationMap = new Map<Id,gFRS_Ltng_Application__c>([SELECT LOA_Signed__c, Record_Type__c, Shrink_Wrap_LOA__c FROM gFRS_Ltng_Application__c WHERE id IN :applicationPaymentsMap.keySet()]);
        for(Set<Id> paymentSetIDs : applicationPaymentsMap.values()){
            for(Id paymentId : paymentSetIDs){
                
                gFRS_Ltng_Payment_History__c paymentSubStatusToUpdate = paymentsMap.get(paymentId);
                gFRS_Ltng_Application__c application = applicationMap.get(paymentSubStatusToUpdate.gFRS_Application__c);
                
                if(application != null){
                    
                    Boolean notLOASigned = application.LOA_Signed__c == 'Yes' ? False : True;
                    Boolean notFieldExhibit = !gFRS_Ltng_Util.Field_Exhibits.equals(application.Record_Type__c);
                    Boolean notShrinkWrapLOA = application.Shrink_Wrap_LOA__c == 'Yes' ? False : True;
                    
                    if ( notLOASigned && paymentSubStatusToUpdate.SAP_Doc_ID__c != null && paymentSubStatusToUpdate.SAP_Doc_ID__c != ''
                        && notFieldExhibit && notShrinkWrapLOA){
                            paymentSubStatusToUpdate.Payment_Sub_status__c = 'Pending LOA';
                            paymentSubStatusToUpdate.Payment_Block__c = 'I';    
                        }                    
                }                
            }
        }    
    }
    
    /**
	* @author CHAVVAS - GFRS 2.0 DEV TEAM
	* @date 19/10/2021
	* @description SAP Call to release I Block
	*/
    public static void releaseIBlock(Map<Id,gFRS_Ltng_Application__c> applicationMap,Map<Id,gFRS_Ltng_Application__c> oldApplicationMap){
        
        for(gFRS_Ltng_Application__c app : applicationMap.values()){
            gFRS_Ltng_Application__c appOld = oldApplicationMap.get(app.id);{
                if(app.LOA_Signed__c != null && app.LOA_Signed__c == 'Yes' && app.LOA_Signed__c !=  appOld.LOA_Signed__c){
                    gFRS_Ltng_PaymentUtil.invokeReleaseIBlock(app.Id);                    
                }
            }            
        }
        
    }
    
    /**
    * @author CHAVVAS - GFRS 2.0 DEV TEAM
    * @date 19/10/2021
    * @description Post LOA signature SubStatus updates for collection of payments
    */
    public static void setSubStatusForPaymentsLoaChanged(Map<Id,gFRS_Ltng_Application__c> applicationMap, Map<Id,gFRS_Ltng_Application__c> oldApplicationMap){
        
        Set<Id> applicationIds = new Set<Id>();
        List<gFRS_Ltng_Payment_History__c> paymentsToUpdate = new List<gFRS_Ltng_Payment_History__c>();
        
        for(gFRS_Ltng_Application__c app : applicationMap.values()){
            gFRS_Ltng_Application__c appOld = oldApplicationMap.get(app.id);
            if(appOld != null && app.LOA_Signed__c != appOld.LOA_Signed__c && app.LOA_Signed__c == 'Yes'){
                applicationIds.add(app.Id);    
            }
        }
        
        gFRS_Ltng_Application__c[] appList = applicationIds.isEmpty() ? new gFRS_Ltng_Application__c[] { } : [
            SELECT (
                SELECT Payment_Sub_status__c, Payment_Block__c FROM FRS_Payment_Historys__r WHERE Payment_Sub_status__c = 'Pending LOA'
            ) FROM gFRS_Ltng_Application__c WHERE Id IN : applicationIds
        ];
        
        for(gFRS_Ltng_Application__c application : appList){
            String loaSigned = applicationMap.get(application.id).LOA_Signed__c;
            for(gFRS_Ltng_Payment_History__c payment : application.FRS_Payment_Historys__r){
                payment.Payment_Sub_status__c = 'Payment Processing';
                payment.Payment_Block__c = null;
                paymentsToUpdate.add(payment);
            }
        }
        
        update paymentsToUpdate;
        
    }
    
    /**
    * @author CHAVVAS - GFRS 2.0 DEV TEAM
    * @date 29/10/2021
    * @description Publishing Platform Event with updated record details   
    */
    public static void publishPaymentUpdateEvent(String sObjectType, String recordId, String customMessage){
        
        gFRS_Record_Update_Event__e paymentEvent = new gFRS_Record_Update_Event__e();
        paymentEvent.sObject_Type__c = sObjectType;
        paymentEvent.Record_Id__c = recordId;
        paymentEvent.Custom_Message__c = customMessage;
        Database.SaveResult sr = EventBus.publish(paymentEvent);
        
        if (sr.isSuccess()) {
            System.debug('publishPaymentUpdateEvent : Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('publishPaymentUpdateEvent - Error : ' + err.getStatusCode() + ' - ' +   err.getMessage());
            }
        }        
    }
    
    /**
    * @author : CHAVVAS - GFRS 2.0 DEV TEAM
    * @date : 29/10/2021
    * @description : Publishing Platform Event with updated record details   
    */
    public static void handlePaymentUpdates(List<gFRS_Ltng_Payment_History__c> newList, Map<Id,gFRS_Ltng_Payment_History__c> oldPaymentMap) {
        String sObjectType = 'gFRS_Ltng_Payment_History__c';
        Set<Id> applicationIds = new Set<Id>();
        for (gFRS_Ltng_Payment_History__c paymentHist : newList) {
            gFRS_Ltng_Payment_History__c oldPayment = oldPaymentMap.get(paymentHist.Id);
            Boolean publishEvent = false;
            if (paymentHist.SAP_Doc_ID__c != oldPayment.SAP_Doc_ID__c) {
                publishEvent = true;
            } else if (paymentHist.Status__c != oldPayment.Status__c) {
                publishEvent = true;  
            } else if (paymentHist.ESB_Error__c != oldPayment.ESB_Error__c) {
                publishEvent = true;
            } else if (paymentHist.Signed_Amount__c != oldPayment.Signed_Amount__c) {
                publishEvent = true;
            }
            if (
                String.isNotBlank(paymentHist.SAP_Doc_ID__c) && 
                paymentHist.SAP_Doc_ID__c != oldPayment.SAP_Doc_ID__c
            ) { // Collect GFRS Application Id once there is a change in SAP Id and that is not blank
                applicationIds.add(paymentHist.gFRS_Application__c);
            }
            if (publishEvent == true) {
                publishPaymentUpdateEvent(sObjectType,paymentHist.Id,'AppId:' + paymentHist.gFRS_Application__c);     
            }
        }
        // Release invoice block once LOA is signed and SAP Id is generated
        if (!applicationIds.isEmpty() && !System.isBatch() && !System.isFuture()) {
            verifyLOASignNReleaseIBlock(applicationIds);
        }
    }

    /**
     * @description This method checks if LOA is signed once the SAP Payment ID 
     *              is generated and then invokes SAP to release invoice block
     * @param A set of GFRS Application Id
     */
    public static void verifyLOASignNReleaseIBlock(Set<Id> applicationIds) {
        for (gFRS_Ltng_Application__c application : [
            SELECT Id, LOA_Signed__c FROM gFRS_Ltng_Application__c WHERE Id IN :applicationIds
        ]) {
            if (String.isNotBlank(application.LOA_Signed__c) && application.LOA_Signed__c == gFRS_Util.YES) {
                invokeReleaseIBlock(application.Id);
            }
        }
    }
    
    public static void updatePaymentMethod(gFRS_Ltng_Application__c app, gFRS_Ltng_Payment_History__c paymentHistory, gFRS_SubmitGrantSAP.Details_element detailsElement) {

        if (String.isNotBlank(app.Vendor_Detail__r.Payment_Method__c) && app.Vendor_Detail__r.Payment_Method__c == '5') {
            detailsElement.paymentMethod = 'C';
            paymentHistory.Payment_Method__c = 'C';
        } else {
            detailsElement.paymentMethod = app.Vendor_Detail__r.Payment_Method__c;
            paymentHistory.Payment_Method__c = app.Vendor_Detail__r.Payment_Method__c;
        }
        
    }
    
        /**
    * @author : CHAVVAS - GFRS 2.0 DEV TEAM
    * @date : 24/12/2021
    * @description : Update Payment Id in application level   
    */
    public static void updateAppPaymntId(List<gFRS_Ltng_Payment_History__c> newList, Map<Id,gFRS_Ltng_Payment_History__c> oldPaymentMap){
        
        for(gFRS_Ltng_Payment_History__c paymentHist : newList){
            
            gFRS_Ltng_Payment_History__c oldPayment = oldPaymentMap.get(paymentHist.Id);
            
            if(paymentHist.SAP_Doc_ID__c != oldPayment.SAP_Doc_ID__c){
                update (new gFRS_Ltng_Application__c(Id = paymentHist.gFRS_Application__c, SAP_Payment_ID__c=paymentHist.SAP_Doc_ID__c));        
            } 
            
        }
    }
    
    @Future(callout=true)
    public static void invokeReleaseIBlock(Id appId){
        
        gFRS_Ltng_Payment_History__c[] appPayments = [SELECT SAP_Doc_ID__c, CreatedDate,Date__c FROM gFRS_Ltng_Payment_History__c WHERE gFRS_Application__c =:appId AND Payment_Type__c = 'Payment' AND SAP_Doc_ID__c != NULL order BY lastModifiedDate DESC LIMIT 1];    
        
        if( appPayments != null && appPayments.size() > 0 ){
            gFRS_Ltng_Payment_History__c paymentHist = appPayments[0];
            Date current = date.today();
            String fiscalYear = paymentHist != null ? String.valueOf( paymentHist.Date__c.year() ):null;
            try{
                gFRS_ReleaseInvoiceBlockLtngWS.GneCOMM_Grants_SFDC_O_1Port0 sapReleaseInvoice = new gFRS_ReleaseInvoiceBlockLtngWS.GneCOMM_Grants_SFDC_O_1Port0();
                sapReleaseInvoice.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
                gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element response =  sapReleaseInvoice.releaseInvoiceBlock(paymentHist.SAP_Doc_ID__c, fiscalYear);
                system.debug('releaseIBlock : Status ' + response.status);
            }catch (Exception e){
                String errMsg = gFRS_Util.getPrettyMessage(e);
                system.debug('releaseIBlock : Error ' + errMsg);
            }            
        } 
        
    }

    class CustomException extends Exception {}
}