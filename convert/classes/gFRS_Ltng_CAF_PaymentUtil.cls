public without sharing class gFRS_Ltng_CAF_PaymentUtil {
    
    public static gFRS_CAF_Payment_Refund_History__c createPaymentHistory(Id cafAppId)
    {
        gFRS_CAF_Payment_Refund_History__c paymentHistory = new gFRS_CAF_Payment_Refund_History__c();        
        try {            
            gFRS_Ltng_CAF_Application__c cafApp = [SELECT Id, Payment_Call_Counter__c, Name, Total_Payment_Amount_Rollup__c FROM gFRS_Ltng_CAF_Application__c WHERE Id =: cafAppId];
            cafApp.Payment_Call_Counter__c += 1;
            update (new gFRS_Ltng_CAF_Application__c(Id = cafApp.Id, Payment_Call_Counter__c = cafApp.Payment_Call_Counter__c ));            
            String sapRequestId = cafApp.Name + '_' + cafApp.Payment_Call_Counter__c;
            Double paymentAmount = cafApp.Total_Payment_Amount_Rollup__c;            
            paymentHistory.SAP_Request_ID__c    = sapRequestId;
            paymentHistory.Date__c              = date.today();
            paymentHistory.Grant__c             = cafApp.Id;
            paymentHistory.Amount__c            = paymentAmount;
            paymentHistory.Payment_Type__c      = 'Payment';
            paymentHistory.Action__c            = 'Payment Sent';
            paymentHistory.InvokeType__c        = 'UI';
            insert paymentHistory;            
        }catch(Exception e){
            System.debug('createPaymentHistory '+ e.getMessage());
            return null; 
        }        
        return paymentHistory;
    }
    
    public static gFRS_CAF_Funding_Allocation__c createPaymentAllocation(Id cafAppId) {
        //Validations - not need of seperate method - refer gFRS_Copay_FundingRequestReadController
        RecordType rt = [SELECT Id FROM RecordType WHERE Name='Payment' AND SobjectType = 'gFRS_CAF_Funding_Allocation__c'];
        Boolean isValidStatus = true;//Hardcoded to true, need to be decided based on CAF App info
        gFRS_CAF_Funding_Allocation__c paymentFA;
        gFRS_CAF__mdt copayMdt = [select GL_Account__c, Cost_Center__c, WBS_Code__c from gFRS_CAF__mdt where MasterLabel = 'Default'];
        if(isValidStatus){
            paymentFA = new gFRS_CAF_Funding_Allocation__c(gFRS_CAF_Application__c = cafAppId, Fiscal_Year__c = String.valueOf(date.today().year()), GL_Account__c = copayMdt.GL_Account__c);
            insert paymentFA;
            gFRS_CAF_Allocation_Line_Item__c lineitem = new gFRS_CAF_Allocation_Line_Item__c(gFRS_CAF_Funding_Allocation__c = paymentFA.id,
                                                                                             Percent__c = 100,
                                                                                             gFRS_Cost_Center_Lookup__c = copayMdt.Cost_Center__c,
                                                                                             gFRS_WBS_Code_Lookup__c = copayMdt.WBS_Code__c
                                                                                            );
            insert lineitem;
        }
        return paymentFA;
    }
    
    public static void deletePaymentAllocation(Id allocId) {
        gFRS_CAF_Funding_Allocation__c paymentFA = new gFRS_CAF_Funding_Allocation__c(Id = allocId);
		delete paymentFA;
    }
    
        public static void deletePaymentHistory(Id paymentId) {
        gFRS_CAF_Payment_Refund_History__c paymentFA = new gFRS_CAF_Payment_Refund_History__c(Id = paymentId);
		delete paymentFA;
    }
    
    public static gFRS_CAF_Payment_Refund_History__c sendFundingAllocationPaymentToESB(Id allocId){
        
        gFRS_CAF_Payment_Refund_History__c activePaymentHistory = new gFRS_CAF_Payment_Refund_History__c();
        
          
        try{         
              gFRS_CAF_Funding_Allocation__c allocation = [SELECT Id,Name, GL_Account_Name__c, Baseline_Date__c, gFRS_CAF_Application__c,
                                                         (Select Id, Name, Cost_Center__c,gFRS_Cost_Center_Lookup__r.SAP_Company_Code__c, Cost_Center_Description__c, WBS_Code__c,gFRS_WBS_Code_Lookup__c, WBS_Description__c,  
                                                          gFRS_CAF_Funding_Allocation__c, Amount__c, Percent__c From gFRS_CAF_Allocation_Line_Items__r) 
                                                         from gFRS_CAF_Funding_Allocation__c where id =: allocId];
            
            gFRS_Ltng_CAF_Application__c cafApp = [SELECT Id, Name, Total_Payment_Amount_Rollup__c, Payment_Method__c, Payment_Call_Counter__c, Vendor_Detail__c FROM gFRS_Ltng_CAF_Application__c WHERE Id =: allocation.gFRS_CAF_Application__c];
            
                  
            
            if(cafApp.Payment_Call_Counter__c==null){
            System.debug('-Inside-'+cafApp.Payment_Call_Counter__c);
            cafApp.Payment_Call_Counter__c=0;
        }
        cafApp.Payment_Call_Counter__c =  cafApp.Payment_Call_Counter__c+1;
            
            gFRS_Ltng_CAF_Vendor_Detail__c vendor = null;
            if(cafApp.Vendor_Detail__c != null){
            	vendor = [SELECT Id, Vendor_ID__c, Payment_Method__c, Partner_Bank_Type__c FROM gFRS_Ltng_CAF_Vendor_Detail__c where Id =: cafApp.Vendor_Detail__c];    
            } 
         //   cafApp.Payment_Call_Counter__c = (cafApp.Payment_Call_Counter__c == null) ? 1 : cafApp.Payment_Call_Counter__c + 1;        
            activePaymentHistory.SAP_Request_ID__c =  cafApp.Name + '_' + cafApp.Payment_Call_Counter__c;
            activePaymentHistory.Status__c = 'Processing';
            activePaymentHistory.InvokeType__c = 'TR';
            activePaymentHistory.Funding_Allocation__c = allocation.Id;
            activePaymentHistory.Grant__c = cafApp.Id;
            activePaymentHistory.Amount__c = cafApp.Total_Payment_Amount_Rollup__c;
            
            String sapRequestId = activePaymentHistory.SAP_Request_ID__c;
            String companyCode  = allocation.gFRS_CAF_Allocation_Line_Items__r[0].gFRS_Cost_Center_Lookup__r.SAP_Company_Code__c;
            gFRS_SubmitGrantWSCopayLtng.GneCOMM_Grants_SFDC_O_1Port0 sapGrant = new gFRS_SubmitGrantWSCopayLtng.GneCOMM_Grants_SFDC_O_1Port0();
            sapGrant.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();            
            GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
            sapGrant.timeout_x = (integer)myOrgCS.ESBWebServiceTimeOut__c;
            String headerText = sapRequestId;
            gFRS_SubmitGrantSAPCopay.Details_element details = new gFRS_SubmitGrantSAPCopay.Details_element();
            details.vendorId = vendor != null ? vendor.Vendor_ID__c : null;
            Decimal paymentAmount = cafApp.Total_Payment_Amount_Rollup__c;
            details.totalAmount = paymentAmount.toPlainString();
            details.paymentMethod = 'Q'; //vendor != null ? vendor.Payment_Method__c : null;
            details.paymentBlock = null;
            details.programTitle = '*' + cafApp.Name + ', Donation to Co-pay Assistance Foundation';
            details.accountableEmployee = null;
            details.delivaryMethods = cafApp.Payment_Method__c;
            details.fedExRequested = false;
            details.attentionTo = null;
            details.businessPartnerNotificationEmail = null;
            details.partnerBankType = vendor != null ? vendor.Partner_Bank_Type__c : null;
            gFRS_SubmitGrantSAPCopay.Split_element[] sapSplitLines = new List<gFRS_SubmitGrantSAPCopay.Split_element>();
            gFRS_SubmitGrantSAPCopay.Split_element line = new gFRS_SubmitGrantSAPCopay.Split_element();
            gFRS_CAF_Allocation_Line_Item__c cafLineItem = allocation.gFRS_CAF_Allocation_Line_Items__r[0];
            line.glAccountCode = allocation.GL_Account_Name__c;
            line.splitAmount = String.valueOf(cafLineItem.Amount__c);
            line.costCenter = cafLineItem.Cost_Center__c;
            line.wbsCode = cafLineItem.WBS_Code__c;
            line.fundingType = 'Copay';
            line.commericalActivityID = null;
            sapSplitLines.add(line);
            details.Split = sapSplitLines;
            gFRS_SubmitGrantSAPCopay.submitGrantResponse_element response =  sapGrant.submitGrant(sapRequestId, 'Expense', companyCode, date.today(), allocation.Baseline_Date__c, 'USD', headerText, details );
            System.debug('CAF sendFundingAllocationPaymentToESB Response ' + response.message);            
            activePaymentHistory.Status__c    = 'Submitted';
            activePaymentHistory.Payment_Sub_status__c = 'Waiting for Response';
            activePaymentHistory.ESB_Error__c = response.message.substring(0,25);
            
            update cafApp;
            insert activePaymentHistory; 
            
        }catch(Exception e){
            activePaymentHistory.Status__c = 'Error';
            activePaymentHistory.ESB_Error__c = e.getMessage().substring(0,25);
            System.debug('CAF sendFundingAllocationPaymentToESB Response ' + e.getMessage());
            insert activePaymentHistory; 
            return activePaymentHistory;
        }
        
        return activePaymentHistory;
    }
    
 
}