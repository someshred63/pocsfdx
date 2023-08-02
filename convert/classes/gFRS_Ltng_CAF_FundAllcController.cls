public class gFRS_Ltng_CAF_FundAllcController {
    
    @AuraEnabled
    Public static List<gFRS_CAF_Funding_Allocation__c> getfundAllocationData(Id applicationId){
        List<gFRS_CAF_Funding_Allocation__c> fundAlclst = [SELECT Id,gFRS_CAF_Application__r.Total_Payment_Amount_Rollup__c,Name, Baseline_Date__c,RecordType.Name, GL_Account__c, GL_Account_Name__c, Fiscal_Year__c, Paid_Amount__c, Status__c,
                                                           (Select Id, Name, Cost_Center__c, Cost_Center_Description__c, WBS_Code__c, WBS_Description__c,  
                                                            gFRS_CAF_Funding_Allocation__c, Amount__c, Percent__c from gFRS_CAF_Allocation_Line_Items__r),
                                                           (Select Id, Name, SAP_Request_ID__c, SAP_Doc_ID__c, Status__c, Amount__c, 
                                                            Date__c, Baseline_Date__c, Payment_Method__c, ESB_Error__c,Grant__r.Payment_Type__c,Grant__r.Status__c,Grant__r.Total_Requested_Amount__c,Grant__r.Total_Apprv_Amount__c from gFRS_CAF_Payment_Refund_History__r)
                                                            FROM gFRS_CAF_Funding_Allocation__c Where gFRS_CAF_Application__c =: applicationId];
                                                           return fundAlclst;
    }
    
    @AuraEnabled
    public static gFRS_CAF_Funding_Allocation__c createNewPaymentAllocation(Id cafAppId) {
        gFRS_CAF_Funding_Allocation__c newPaymentAlloc = gFRS_Ltng_CAF_PaymentUtil.createPaymentAllocation(cafAppId);
        return newPaymentAlloc; 
    }
    
    @AuraEnabled
    public static void deletePaymentAllocation(Id allocId) {
		gFRS_Ltng_CAF_PaymentUtil.deletePaymentAllocation(allocId);
    }
    
    @AuraEnabled
    public static gFRS_CAF_Payment_Refund_History__c createNewPaymentHistory(Id cafAppId) {        
        gFRS_CAF_Payment_Refund_History__c newPaymentHistory = gFRS_Ltng_CAF_PaymentUtil.createPaymentHistory(cafAppId);
        return newPaymentHistory;
    }
    
    @AuraEnabled
    public static void deletePayment(Id paymentId) {
		gFRS_Ltng_CAF_PaymentUtil.deletePaymentHistory(paymentId);
    }
    
    @AuraEnabled
    public static gFRS_CAF_Payment_Refund_History__c submitForPayment(Id allocId){
        gFRS_CAF_Payment_Refund_History__c paymentHistory = gFRS_Ltng_CAF_PaymentUtil.sendFundingAllocationPaymentToESB(allocId);
        return paymentHistory;
    }
    @AuraEnabled
    public static String submitForPaymentEnhanced(Id allocId){
      gFRS_CAF_Funding_Allocation__c allocation = [SELECT Id,Name, GL_Account_Name__c, Payment_Amount__c,Baseline_Date__c, gFRS_CAF_Application__c,
                                                         (Select Id, Name, Cost_Center__c,gFRS_Cost_Center_Lookup__r.SAP_Company_Code__c, Cost_Center_Description__c, WBS_Code__c,gFRS_WBS_Code_Lookup__c, WBS_Description__c,  
                                                          gFRS_CAF_Funding_Allocation__c, Amount__c, Percent__c From gFRS_CAF_Allocation_Line_Items__r) 
                                                         from gFRS_CAF_Funding_Allocation__c where id =: allocId];
            
            gFRS_Ltng_CAF_Application__c cafApp = [SELECT Id, Name, Total_Payment_Amount_Rollup__c, Payment_Method__c, Payment_Call_Counter__c, Vendor_Detail__c FROM gFRS_Ltng_CAF_Application__c WHERE Id =: allocation.gFRS_CAF_Application__c];
            
                  
            
            if(cafApp.Payment_Call_Counter__c==null){
            System.debug('-Inside-'+cafApp.Payment_Call_Counter__c);
            cafApp.Payment_Call_Counter__c=0;
        }
        cafApp.Payment_Call_Counter__c =  cafApp.Payment_Call_Counter__c+1;
                   update (new gFRS_Ltng_CAF_Application__c(Id = cafApp.Id, Payment_Call_Counter__c = cafApp.Payment_Call_Counter__c ));
        
        String sapRequestId =cafApp.Name + '_' + cafApp.Payment_Call_Counter__c;
        
        Double paymentAmount =allocation.Payment_Amount__c;
        
        gFRS_CAF_Payment_Refund_History__c paymentHistory=new gFRS_CAF_Payment_Refund_History__c();
        paymentHistory.SAP_Request_ID__c= sapRequestId;
        paymentHistory.Date__c= date.today();
        paymentHistory.Grant__c= cafApp.Id;
        paymentHistory.Funding_Allocation__c=allocation.Id;
        paymentHistory.Amount__c= paymentAmount;
        paymentHistory.Payment_Type__c='Payment';
        paymentHistory.Action__c='Payment Sent';
        paymentHistory.InvokeType__c='UI';
        paymentHistory.Status__c='Initialized';
        
        
        Insert 	paymentHistory;	
        
        gFRS_Ltng_PaymentUtil.sendltngFundingAllocationPaymentToESB(cafApp.Id,allocation.id,paymentHistory.id);
        
        return paymentHistory.Id;
   
    }
    @AuraEnabled
    Public static gFRS_Ltng_CAF_Application__c getCAFData(Id applicationId){
      return  [SELECT Id,Payment_Type__c,Manual_Automated_Payment__c,Status__c,Total_Requested_Amount__c,Total_Apprv_Amount__c FROM gFRS_Ltng_CAF_Application__c WHERE Id=:applicationId];
    }
    @AuraEnabled
    public static Boolean isSubmitForPaymentDisabled(String appStatus){
        
        GFRS_Ltng_OrgSettings__c orgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        String disabledStatusStr = orgCS.Submit_For_Payment_Disabled_Sub_Statuses__c;
        if(String.isNotBlank(disabledStatusStr)){
            String[] disabledStatusList = disabledStatusStr.split(',');
            for(String status : disabledStatusList){
                String statusTrim = status.trim();
                if(statusTrim.equalsIgnoreCase(appStatus)){
                    return true;    
                }   
            }    
        }
        
        return false;
        
    }
    @AuraEnabled
    public static void SubmitForApproval(gFRS_Ltng_CAF_Application__c request){
        user u= [Select Id,Name From User Where Id =:UserInfo.getUserId()];
        if(string.isNotBlank(request.Compliance_Owner__c)){
            request.Compliance_Owner__c = u.id;
        }
        request.Sys_Approved__c=false;
 
        List<gFRS_CAF_Disease_State__c> lstdiesease=[SELECT ID FROM gFRS_CAF_Disease_State__c WHERE Id=:request.Id];
        if(lstdiesease.size()>0&&!lstdiesease.isEmpty()){
            for(gFRS_CAF_Disease_State__c dis:lstdiesease){
                dis.Payment_Amount__c=0;
                lstdiesease.add(dis);
            }
            update lstdiesease;
        }
        
        update request;
        Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
        approvalReq.setComments('Submitting request for approval.');
        approvalReq.setObjectId(request.Id);
        //approvalReq.setProcessDefinitionNameOrId('IME_Approval_Process');
        approvalReq.setProcessDefinitionNameOrId('');
        approvalReq.setSkipEntryCriteria(true);
        Approval.ProcessResult processResult = Approval.process(approvalReq);
        //return StatusVal;
    }
@InvocableMethod(label='Payment PDF Generation')   
public static void generatePDF(List<String> reqId) {
  if(!System.isFuture() && !System.isBatch()){
generatePDF1(reqId.get(0));
  }
}
@future(callout=true)
public static void generatePDF1(Id reqId) {
    System.debug('-->Entered Payment start<--'+reqId);
        PageReference pdfPage;
            pdfPage = new PageReference('/apex/gFRS_Ltng_FundingAllocationSnap');
       
    pdfPage.getParameters().put('Id',reqId);
        Blob pdfContent = pdfPage.getContentAsPDF();
		
		gFRS_CAF_Funding_Allocation__c gfrsapp=[SELECT Id,Payment_Call_Counter__c,Payment_PDF_Id__c FROM gFRS_CAF_Funding_Allocation__c WHERE Id=:reqId LIMIT 1];
	 System.debug('-Inside before-'+gfrsApp.Payment_Call_Counter__c);	
    if(gfrsApp.Payment_Call_Counter__c==null){
            System.debug('-Inside-'+gfrsApp.Payment_Call_Counter__c);
            gfrsApp.Payment_Call_Counter__c=0;
        }
        gfrsApp.Payment_Call_Counter__c =  gfrsApp.Payment_Call_Counter__c+1;
		System.debug('-counter->'+gfrsApp.Payment_Call_Counter__c);
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Payment'+'_V'+gfrsApp.Payment_Call_Counter__c+'.pdf';//File name with extention
        
        cVersion.Title = 'Payment'+'_V'+gfrsApp.Payment_Call_Counter__c+'.pdf';//Name of the file
        cVersion.VersionData =  pdfContent;//File content
        Insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        System.debug('-->'+conDocument);
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = reqId;//Add attachment parentId
        Insert cDocLink;
        
		gfrsApp.Payment_PDF_Id__c=conDocument;
		update gfrsApp;
       System.debug('-->Entered Payment End<--'+reqId);
    }
   @AuraEnabled
     public static void fromGeneratePDF1(Id reqId, Id allocId) {
         fromGeneratePDF(reqId, allocId);
     }
    @future(callout=true)
    public static void fromGeneratePDF(Id reqId, Id allocId) {
        PageReference pdfPage = new PageReference('/apex/gFRS_Ltng_FundingAllocationSnap?Id='+reqId);
        Blob pdfContent;
        pdfPage.setRedirect(true);
     //   pdfPage.getParameters().put('Id',reqId);
       pdfContent = pdfPage.getContentAsPDF();
			//gFRS_CAF_Funding_Allocation__c gfrsapp=[SELECT Id,Payment_Call_Counter__c,Payment_PDF_Id__c,gFRS_CAF_Application__c FROM gFRS_CAF_Funding_Allocation__c WHERE gFRS_CAF_Application__c=:reqId LIMIT 1];
        
		gFRS_CAF_Funding_Allocation__c gfrsapp=[SELECT Id,Payment_Call_Counter__c,Payment_PDF_Id__c FROM gFRS_CAF_Funding_Allocation__c WHERE Id=:allocId LIMIT 1];
	 System.debug('-Inside before-'+gfrsApp.Payment_Call_Counter__c);	
    if(gfrsApp.Payment_Call_Counter__c==null){
            System.debug('-Inside-'+gfrsApp.Payment_Call_Counter__c);
            gfrsApp.Payment_Call_Counter__c=0;
        }
        gfrsApp.Payment_Call_Counter__c =  gfrsApp.Payment_Call_Counter__c+1;
		System.debug('-counter->'+gfrsApp.Payment_Call_Counter__c);
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Payment'+'_V'+gfrsApp.Payment_Call_Counter__c+'.pdf';//File name with extention
        
        cVersion.Title = 'Payment'+'_V'+gfrsApp.Payment_Call_Counter__c+'.pdf';//Name of the file
        cVersion.VersionData =  pdfContent;//File content
        Insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        System.debug('-->'+conDocument);
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = reqId;//Add attachment parentId
        Insert cDocLink;
        
		gfrsApp.Payment_PDF_Id__c=conDocument;
		update gfrsApp;
    }
    
    public static void sendIntentToDonateEmail(Id reqid){
        gFRS_Ltng_CAF_Application__c caf=[SELECT Id,name,owner.email FROM gFRS_Ltng_CAF_Application__c WHERE Id=:reqid];
        List<gFRS_CAF_Disease_State__c> lstdis=[SELECT Id,Name,Payment_Amount__c,gFRS_CAF_Application__c FROM gFRS_CAF_Disease_State__c WHERE gFRS_CAF_Application__c=:reqid];
        String refferId = '[ref:'+reqid+']';
        Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
         List<String> tobCCddresses = new List<String>();
         GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_CAF_Inbound_Email__c != null){
            String bccEmailAddress=myOrgCS.gFRS_CAF_Inbound_Email__c;
            tobCCddresses.add(bccEmailAddress);
        }
        message.setBccAddresses(tobCCddresses);
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address='fundingrequestsystem-donotreply-d@gene.com' LIMIT 1];
        message.setOrgWideEmailAddressId(owea.Id);
    //    message.setTargetObjectId(reqid); 
    message.setWhatId(reqid);
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='Intent_to_Donate_CoPay'];
        message.setTemplateID(emailTemplate.Id);
        String body=emailTemplate.Body;
       String DisStateDetails = '';
        if(lstdis.size()>0&&!lstdis.isEmpty()){
            for(gFRS_CAF_Disease_State__c DS:lstdis){
          Decimal pA = DS.Payment_Amount__c;
                List<String> args = new String[]{'0','number','##,###,##0'};
                String pmtAmt = String.format(pA.format(), args);

                DisStateDetails = DisStateDetails + DS.Name + ': $' + pmtAmt + '\n';
            }
             body = body.replace('<Disease area: $ amount for each donation line item>',DisStateDetails);
        }
        message.toAddresses = new String[] { caf.owner.email};
        message.setPlainTextBody(body);
     //   message.setReferences(refferId);
        message.setTreatBodiesAsTemplate(true);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send:' +  results[0].errors[0].message);
        }
    }
    @AuraEnabled
    public static gFRS_CAF_Payment_Refund_History__c paymentHistoryCreate(Id reqId,Id cafId){
        gFRS_Ltng_CAF_Application__c cafapp=[SELECT Id,Name FROM gFRS_Ltng_CAF_Application__c WHERE Id=:cafId];
        gFRS_CAF_Payment_Refund_History__c cafpay=new gFRS_CAF_Payment_Refund_History__c();
        cafpay.SAP_Request_ID__c=cafapp.Name+'_1';
        cafpay.Grant__c=cafId;
        cafpay.Funding_Allocation__c=reqId;
        insert cafpay;
        return cafpay;
    }
    
   
   
    
        
}