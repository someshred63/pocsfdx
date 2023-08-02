public class gFRS_Ltng_FundAllcViewController {
    
    @AuraEnabled
    Public static List<gFRS_Ltng_App_Funding_Allocation__c> getfundAllocationData(Id applicationId){
        List<gFRS_Ltng_App_Funding_Allocation__c> fundAlclst = [SELECT Id,Name,Approved_Amount__c,Payment_Amounts__c,Payment_Status__c,Auto_Process_Check__c, Created_By_Process__c, Baseline_Date__c,gFRS_Application__r.Name,Record_Type_Name__c,gFRS_GL_Account__c,
                                                                gFRS_Application__r.Total_Amount_Used__c,gFRS_Application__r.Refund_Due__c,gFRS_Application__r.Refund_Amount_Internal__c,gFRS_Application__r.Refund_Due_External__c,gFRS_Application__r.Reason_for_refund_due__c,gFRS_Application__r.Transaction_Check_Number__c,gFRS_Application__r.Record_Type_Name__c,Multiple_payments_associated_with_Rqst__c,Total_Amount_Payable__c,Total_Amount_Payable_funded__c,Payment_Type__c,Multiple_Refunds_associated_with_Rqst__c
                                                                FROM gFRS_Ltng_App_Funding_Allocation__c Where gFRS_Application__c=:applicationId order by name];
        return fundAlclst;
    }
    
    @AuraEnabled
    Public static List<gFRS_Ltng_Funding_Allocation_Line_Item__c> getfundAllocationlineData(Id applicationId){
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> fundAlclinelst = [Select id, name, Cost_Center_Code__c,WBS_Code__c,gFRS_Funding_Allocation__r.Multiple_payments_associated_with_Rqst__c,WBS_Description__c,Cost_Center_Description__c,gFRS_Funding_Allocation__r.gFRS_Application__c,gFRS_Funding_Allocation__c, Amount__c, Percent__c, Commercial_Activity_ID__c 
                                                                          From gFRS_Ltng_Funding_Allocation_Line_Item__c Where gFRS_Funding_Allocation__c=:applicationId];
        //System.debug('@@@@'+fundAlclinelst);
        return fundAlclinelst;
    }
    
    @AuraEnabled
    public static gFRS_Ltng_App_Funding_Allocation__c fetchfundAllocationData(Id applicationId){              
        gFRS_Ltng_App_Funding_Allocation__c appFundingRec = new gFRS_Ltng_App_Funding_Allocation__c();
        try{
            appFundingRec = [SELECT Id,Name,Approved_Amount__c,Payment_Amounts__c,Payment_Status__c,Auto_Process_Check__c, Created_By_Process__c, Baseline_Date__c,gFRS_Application__r.Name,Record_Type_Name__c,
                                                                gFRS_Application__r.Total_Amount_Used__c,gFRS_Application__r.Refund_Due__c,gFRS_Application__r.Refund_Amount_Internal__c,gFRS_Application__r.Refund_Due_External__c,gFRS_Application__r.Reason_for_refund_due__c,gFRS_Application__r.Transaction_Check_Number__c,gFRS_Application__r.Record_Type_Name__c,Multiple_payments_associated_with_Rqst__c,Total_Amount_Payable__c,Payment_Type__c,Multiple_Refunds_associated_with_Rqst__c
                                                                FROM gFRS_Ltng_App_Funding_Allocation__c Where Id=:applicationId];
            return appFundingRec;
        }
        catch(Exception e){ 
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    } 
    
    @AuraEnabled
    public static void updateFundAlclineItems(List<gFRS_Ltng_Funding_Allocation_Line_Item__c> upReclst,
                                              List<gFRS_Ltng_Funding_Allocation_Line_Item__c> newReclst,
                                              List<Id> delReclst,
                                              String appId,
                                              gFRS_Ltng_App_Funding_Allocation__c upFundAlc)
        //Integer paymentAmt,String mulitpt,String ptype,Date baselineDate)
    {
        
        update upFundAlc;
        
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> newlst=new List<gFRS_Ltng_Funding_Allocation_Line_Item__c>();
        if(newReclst.size()>0)
        {
            
            for(gFRS_Ltng_Funding_Allocation_Line_Item__c chItem:newReclst){
                
                chItem.gFRS_Funding_Allocation__c=appId;
                newlst.add(chItem);  
            } 
            
        }
        
        
        Database.SaveResult[] upResults= Database.update(upReclst,false);
        Database.SaveResult[] inRresults= Database.insert(newlst,false);
        delLineItems(delReclst);
        
        //system.debug('@@@ Veera Debug upResults'+upResults);
        //system.debug('@@@ Veera Debug inRresults'+inRresults);
        
    }
    
    @AuraEnabled
    Public static String submitPaymenttoEBS(Id fundAlocId){
        
        /* Payment History */
        
        // Application Query
        
        
        
        // Funding Allocation 
        
        
        gFRS_Ltng_App_Funding_Allocation__c fundAlloc=[SELECT Id, Name, gFRS_Application__c, Approved_Amount__c, 
                                                       Check_Number__c, Payment_Amounts__c, Organization_Name__c,
                                                       Record_Type_Name__c, Baseline_Date__c FROM gFRS_Ltng_App_Funding_Allocation__c Where Id=:fundAlocId];
        
        Organization org = [select IsSandbox from Organization ];
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(org.IsSandbox == true&&myOrgCS.WS_SubmitGrant_Endpoint__c.contains('prd.roche.com')){
          /*  system.debug('@@@ You can not submit payment as you are in Sandbox and the Grant Submit endpoint URL pointing to Production.');
            
            gFRS_Record_Update_Event__e paymentEvent = new gFRS_Record_Update_Event__e();
            paymentEvent.sObject_Type__c = '';
            paymentEvent.Record_Id__c = fundAlloc.gFRS_Application__c;
            paymentEvent.Custom_Message__c = '';
            Database.SaveResult sr = EventBus.publish(paymentEvent);
            
            if (sr.isSuccess()) {
                System.debug('Event Successfully published.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Event - Error : ' + err.getStatusCode() + ' - ' +   err.getMessage());
                }
            }*/ 
            return 'prodURLCheck';
        } else {
            system.debug('@@@ Proceeding with Payment submission');
        }
        
        gFRS_Ltng_Application__c gfrsApp=[Select Id,name ,Requested_Amount__c,Approved_Amount__c,Record_Type_Name__c,Vendor_Detail__r.Vendor_id__c,Attention_To__c,Partner_Bank_Type__c,Payment_Call_Counter__c,Event_Program_Title__c  From gFRS_Ltng_Application__c
                                          Where Id=:fundAlloc.gFRS_Application__c];
        
        // Funding Allocation Line Item
        
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> fundalcintem=[SELECT Id, Name,Line_Item_Total__c, gFRS_Funding_Allocation__c, Amount__c, 
                                                                      Percent__c,WBS_Description__c, Cost_Center_Description__c,Cost_Center_Code__r.SAP_Company_Code__c,
                                                                      Are_there_multiple_payments_associated_w__c,
                                                                      Payment_Type__c FROM gFRS_Ltng_Funding_Allocation_Line_Item__c Where gFRS_Funding_Allocation__c=:fundAlloc.Id];
        
        //gFRS_Ltng_PaymentUtil.getGrantSubmitSplitLines( gfrsApp, fundalcintem );
        
        // Create Payment History for Funding Allocation 
        System.debug('@@@'+gfrsApp.Payment_Call_Counter__c);
        
        if(gfrsApp.Payment_Call_Counter__c==null){
            gfrsApp.Payment_Call_Counter__c=0;
        }
        
        
        gfrsApp.Payment_Call_Counter__c =  gfrsApp.Payment_Call_Counter__c+1;
        update (new gFRS_Ltng_Application__c(Id = gfrsApp.Id, Payment_Call_Counter__c = gfrsApp.Payment_Call_Counter__c ));
        
        String sapRequestId =gfrsApp.Name + '_' + gfrsApp.Payment_Call_Counter__c;
        
        Double paymentAmount =fundAlloc.Payment_Amounts__c;
        
        gFRS_Ltng_Payment_History__c paymentHistory=new gFRS_Ltng_Payment_History__c();
        paymentHistory.SAP_Request_ID__c= sapRequestId;
        paymentHistory.Date__c= date.today();
        paymentHistory.gFRS_Application__c= gfrsApp.Id;
        paymentHistory.gFRS_Funding_Allocation__c=fundAlloc.Id;
        paymentHistory.Amount__c= paymentAmount;
        paymentHistory.Payment_Type__c='Payment';
        paymentHistory.Action__c='Payment Sent';
        paymentHistory.RecordTypeId=[SELECT id FROM RecordType where DeveloperName='ReadOnly' and SobjectType='gFRS_Ltng_Payment_History__c'].id;
        paymentHistory.InvokeType__c='UI';
        paymentHistory.Status__c='Initialized';
        
        
        Insert  paymentHistory; 
        
        gFRS_Ltng_PaymentUtil.sendltngFundingAllocationPaymentToESB(gfrsApp.Id,fundAlloc.id,paymentHistory.id);
        
        return paymentHistory.Id;
        
    }
    
    @AuraEnabled
    Public static String submitPaymenttoFRB(Id fundAlocId){
       gFRS_Ltng_App_Funding_Allocation__c fundAlloc=[SELECT Id, Name, gFRS_Application__c, Approved_Amount__c, 
                                                       Check_Number__c, Payment_Amounts__c, Organization_Name__c,
                                                       Record_Type_Name__c, Baseline_Date__c FROM gFRS_Ltng_App_Funding_Allocation__c Where Id=:fundAlocId];
        
        
        gFRS_Ltng_Application__c gfrsApp=[Select Id,name ,Requested_Amount__c,Approved_Amount__c,Record_Type_Name__c,Vendor_Detail__r.Vendor_id__c,Attention_To__c,Partner_Bank_Type__c,Payment_Call_Counter__c,Event_Program_Title__c  From gFRS_Ltng_Application__c
                                          Where Id=:fundAlloc.gFRS_Application__c];
        
        // Funding Allocation Line Item
        
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> fundalcintem=[SELECT Id, Name,Line_Item_Total__c,Cost_Center_Code__c,WBS_Code__c, gFRS_Funding_Allocation__c, Amount__c, 
                                                                      Percent__c,WBS_Description__c, Cost_Center_Description__c,
                                                                      Are_there_multiple_payments_associated_w__c,
                                                                      Payment_Type__c FROM gFRS_Ltng_Funding_Allocation_Line_Item__c Where gFRS_Funding_Allocation__c=:fundAlloc.Id];
        
        //gFRS_Ltng_PaymentUtil.getGrantSubmitSplitLines( gfrsApp, fundalcintem );
        System.debug('@@@'+gfrsApp.Payment_Call_Counter__c);
        
        if(gfrsApp.Payment_Call_Counter__c==null){
            gfrsApp.Payment_Call_Counter__c=0;
        }
        
        
        gfrsApp.Payment_Call_Counter__c =  gfrsApp.Payment_Call_Counter__c+1;
       // update (new gFRS_Ltng_Application__c(Id = gfrsApp.Id, Payment_Call_Counter__c = gfrsApp.Payment_Call_Counter__c ));
        
        String sapRequestId =gfrsApp.Name + '_' + gfrsApp.Payment_Call_Counter__c;
        
        Double paymentAmount =fundAlloc.Payment_Amounts__c;
        
        gFRS_Ltng_Payment_History__c paymentHistory=new gFRS_Ltng_Payment_History__c();
        paymentHistory.SAP_Request_ID__c= sapRequestId;
        paymentHistory.Date__c= date.today();
        paymentHistory.gFRS_Application__c= gfrsApp.Id;
        paymentHistory.gFRS_Funding_Allocation__c=fundAlloc.Id;
        paymentHistory.Amount__c= gfrsApp.Approved_Amount__c;
        paymentHistory.Payment_Type__c='Payment';
        paymentHistory.Action__c='Payment Sent';
        paymentHistory.RecordTypeId=[SELECT id FROM RecordType where DeveloperName='ReadOnly' and SobjectType='gFRS_Ltng_Payment_History__c'].id;
        paymentHistory.InvokeType__c='UI';
        paymentHistory.Status__c='Initialized';
        insert paymentHistory;
        
      gFRS_FRB_PaymentCallout.makeFRB_PaymentCallout(gfrsApp.Id,fundAlloc.id,paymentHistory.id);
        update (new gFRS_Ltng_Application__c(Id = gfrsApp.Id, Payment_Call_Counter__c = gfrsApp.Payment_Call_Counter__c ));        
        return paymentHistory.Id;
        
       
        
    }
    
    @AuraEnabled
    Public static void createFundingAllocation(Id applicationId){
        
        gFRS_Ltng_App_Funding_Allocation__c gfrsAlc=new gFRS_Ltng_App_Funding_Allocation__c();
        gfrsAlc.gFRS_Application__c=applicationId;
        gfrsAlc.RecordTypeId=[SELECT id FROM RecordType where DeveloperName='Payment' and SobjectType='gFRS_Ltng_App_Funding_Allocation__c'].id;
        insert gfrsAlc;
        
    }
    
    
    @AuraEnabled
    Public static List<gFRS_Ltng_Payment_History__c> getPaymentHistory(Id applicationId){
        
        List<gFRS_Ltng_Payment_History__c> paymentHistorylst = [SELECT Id,Status__c, Name, gFRS_Application__c, Amount__c, Payment_Method__c, 
                                                                SAP_Doc_ID__c, SAP_Payment_Document_ID__c,gFRS_Funding_Allocation__r.Auto_Process_Check__c,
                                                                gFRS_Funding_Allocation__c, Date__c, Payment_Type__c, InvokeType__c, Action__c, 
                                                                SAP_Request_ID__c, Payment_Refund_Status__c, Type_of_Check_Received__c, Signed_Amount__c,
                                                                ESB_Error__c, Payment_Sub_status__c, Check_Number__c, Created_Timestamp__c, I_Block_Released__c, 
                                                                Integration_Id__c, Invoice_Block_Status__c, Note__c,Refund_Amount__c,
                                                                Payment_Block__c, SAP_Payment_Sent_Date__c 
                                                                FROM gFRS_Ltng_Payment_History__c Where gFRS_Funding_Allocation__c=:applicationId order by Name];
        return paymentHistorylst;
        
        
    }
    
    
    
    @AuraEnabled
    public static List<LayoutSection> getPageLayoutFields(Id recordId) {
         gFRS_Ltng_Payment_History__c paymentHistoryRec = [SELECT Id,Status__c, Name, gFRS_Application__c,gFRS_Application__r.Record_Type__c, Amount__c, Payment_Method__c
                                                FROM gFRS_Ltng_Payment_History__c Where id=:recordId];
        List<LayoutSection> lstSections = new List<LayoutSection>();
        List<String> componentNameList = new List<String>();
        Map<String,String> pageLayMap=new  Map<String,String>();
        Set<String> sectionSets=new Set<String>();
        if(paymentHistoryRec.gFRS_Application__r.Record_Type__c=='Foundation Safety Net Support' || paymentHistoryRec.gFRS_Application__r.Record_Type__c=='Foundation Undergraduate'){
            sectionSets.add('Information');
        }else
        {
            sectionSets.add('Information');
            sectionSets.add('Payment/Refund Processing Information'); 
        }
        componentNameList.add('gFRS_Ltng_Payment_History__c-gFRS Payment History Layout');
        
        try {
            // Provide the page layout name here
            // You can give multiple page layout names here as well
            //List<String> componentNameList = new List<String>{'gFRS_Ltng_Program__c-gFRS Program Layout'};
            // Retrieve page layout details
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
            Metadata.Layout contLayout = (Metadata.Layout) components.get(0);
            
            // We are going to find the fields names and will keep them according to columns so
            // we can show them as per page layout
            for( Metadata.LayoutSection ls : contLayout.layoutSections ) {
                
                system.debug('@@ Layout Name'+ ls.label);
                
                //ls.label!='Custom Links'
                if(sectionSets.contains(ls.label))
                {
                    LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );
                    
                    List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                    Integer maxFieldsInColumn = 0;
                    for( Metadata.LayoutColumn lc : ls.layoutColumns ) {
                        
                        LayoutColumn column = new LayoutColumn();
                        // check if there are fields available in that column
                        if( lc.layoutItems != null ) {
                            // Get the max number of fields in a column to preserve the alignment
                            if( maxFieldsInColumn < lc.layoutItems.size() ) {
                                maxFieldsInColumn = lc.layoutItems.size();
                            }
                            for( Metadata.LayoutItem li : lc.layoutItems ) {
                                
                                // Pass the LayoutItem object in the LayoutField consturctor    
                                column.lstFields.add( new LayoutField( li ) );
                            }
                        }
                        // No need to add a column in the section if there is no field available
                        if( column.lstFields.size() > 0 ) {
                            lstColumns.add( column );
                        }
                    }
                    
                    // Now, we need to arrange the fields in section so we can use them in the iteration
                    // on the component so we will have to arrange them in the order
                    if( maxFieldsInColumn > 0 ) {
                        for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                            for( Integer j = 0; j < lstColumns.size(); j++ ){
                                if( lstColumns[j].lstFields.size() > i ) {
                                    section.lstFields.add( lstColumns[j].lstFields[i] );    
                                }    
                                else {
                                    section.lstFields.add( new LayoutField() );
                                }
                            }    
                        }    
                    }
                    
                    lstSections.add( section );
                }
                
            }
        }
        catch( Exception e ){
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage() );
        }
        return lstSections;
    }
    
    
    public class LayoutSection {  
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
        }
    }
    
    private class LayoutColumn {
        private List<LayoutField> lstFields;    
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }
    
    public class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        
        public LayoutField() {}
        
        public LayoutField( Metadata.LayoutItem li ) {
            
            this.fieldName = li.field;
            if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
            else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }    
        }
    }
    
    @AuraEnabled
    public static void delLineItems(List<Id> lstIds){
        
        SavePoint sp = Database.setSavepoint();
        try{
            
            Database.DeleteResult[] delResults=Database.delete(lstIds,false);
            system.debug('@@@ deleted Records '+delResults);
            
        }
        catch(Exception e){
            
            Database.rollback(sp);
            System.debug('@@@@'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
    @AuraEnabled
    Public static void createRefundFundingAllocation(Id applicationId){
        
        gFRS_Ltng_App_Funding_Allocation__c gfrsAlc=new gFRS_Ltng_App_Funding_Allocation__c();
        gfrsAlc.gFRS_Application__c=applicationId;
        gfrsAlc.RecordTypeId=[SELECT id FROM RecordType where DeveloperName='Refund' and SobjectType='gFRS_Ltng_App_Funding_Allocation__c'].id;
        insert gfrsAlc;
        
    }
    
    
    @AuraEnabled
    Public static String submitRefundtoEBS(Id fundAlocId){
        
        // Funding Allocation 
        
        gFRS_Ltng_App_Funding_Allocation__c fundAlloc=[SELECT Id, Name, gFRS_Application__c, Approved_Amount__c, 
                                                       Check_Number__c, Payment_Amounts__c, Organization_Name__c,
                                                       Record_Type_Name__c, Baseline_Date__c FROM gFRS_Ltng_App_Funding_Allocation__c Where Id=:fundAlocId];
        
        
        gFRS_Ltng_Application__c gfrsApp=[Select Id,name ,Requested_Amount__c,Approved_Amount__c,Record_Type_Name__c,Refund_Due__c,Refund_Amount_Internal__c,Vendor_Detail__r.Vendor_id__c,Attention_To__c,Partner_Bank_Type__c,Payment_Call_Counter__c,Event_Program_Title__c  From gFRS_Ltng_Application__c
                                          Where Id=:fundAlloc.gFRS_Application__c];
        
        // Funding Allocation Line Item
        
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> fundalcintem=[SELECT Id, Name,Line_Item_Total__c, gFRS_Funding_Allocation__c, Amount__c, 
                                                                      Percent__c,WBS_Description__c, Cost_Center_Description__c,Cost_Center_Code__r.SAP_Company_Code__c,
                                                                      Are_there_multiple_payments_associated_w__c,
                                                                      Payment_Type__c FROM gFRS_Ltng_Funding_Allocation_Line_Item__c Where gFRS_Funding_Allocation__c=:fundAlloc.Id];
        
        //gFRS_Ltng_PaymentUtil.getGrantSubmitSplitLines( gfrsApp, fundalcintem );
        
        // Create Payment History for Funding Allocation 
        System.debug('@@@'+gfrsApp.Payment_Call_Counter__c);
        
        if(gfrsApp.Payment_Call_Counter__c==null){
            gfrsApp.Payment_Call_Counter__c=0;
        }
        
        
        gfrsApp.Payment_Call_Counter__c =  gfrsApp.Payment_Call_Counter__c+1;
        update (new gFRS_Ltng_Application__c(Id = gfrsApp.Id, Payment_Call_Counter__c = gfrsApp.Payment_Call_Counter__c ));
        
        String sapRequestId =gfrsApp.Name + '_' + gfrsApp.Payment_Call_Counter__c;
        
        Double paymentAmount =gfrsApp.Refund_Amount_Internal__c;
        
        gFRS_Ltng_Payment_History__c paymentHistory=new gFRS_Ltng_Payment_History__c();
        paymentHistory.SAP_Request_ID__c= sapRequestId;
        paymentHistory.Date__c= date.today();
        paymentHistory.gFRS_Application__c= gfrsApp.Id;
        paymentHistory.gFRS_Funding_Allocation__c=fundAlloc.Id;
        paymentHistory.Amount__c= paymentAmount;
        paymentHistory.Payment_Type__c='Refund';
        
        paymentHistory.Action__c='Refund Sent';
        paymentHistory.RecordTypeId=[SELECT id FROM RecordType where DeveloperName='ReadOnly' and SobjectType='gFRS_Ltng_Payment_History__c'].id;
        paymentHistory.InvokeType__c='UI';
        paymentHistory.Status__c='Initialized';
        
        
        Insert  paymentHistory; 
        
        gFRS_Ltng_PaymentUtil.sendltngFundingAllocationRefundToESB(gfrsApp.Id,fundAlloc.id,paymentHistory.id);
        
        return paymentHistory.Id;
        
        
    }
    
    
    @AuraEnabled
    public static void updateFundAlclineItemsInternal(List<gFRS_Ltng_Funding_Allocation_Line_Item__c> upReclst,
                                                      List<gFRS_Ltng_Funding_Allocation_Line_Item__c> newReclst,
                                                      Decimal RefAmt,
                                                      gFRS_Ltng_App_Funding_Allocation__c upFundAlc)
        //Integer paymentAmt,String mulitpt,String ptype,Date baselineDate)
    {
        
        
        update upFundAlc;
        
        gFRS_Ltng_App_Funding_Allocation__c fundAlloc=[SELECT Id, Name, gFRS_Application__c, Approved_Amount__c, 
                                                       Check_Number__c, Payment_Amounts__c, Organization_Name__c,
                                                       Record_Type_Name__c, Baseline_Date__c FROM gFRS_Ltng_App_Funding_Allocation__c Where Id=:upFundAlc.Id];
        
        //gFRS_Ltng_Application__c gfrsApp=[Select Id,name ,Requested_Amount__c,Approved_Amount__c,Total_Amount_Used__c,Refunded_Amount__c  From gFRS_Ltng_Application__c
        
        
        
        gFRS_Ltng_Application__c gfrsApp=new gFRS_Ltng_Application__c();        
        gfrsApp.Refund_Amount_Internal__c=RefAmt;
        gfrsApp.Id=fundAlloc.gFRS_Application__c;
        update gfrsApp;
        
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> newlst=new List<gFRS_Ltng_Funding_Allocation_Line_Item__c>();
        if(newReclst.size()>0)
        {
            
            for(gFRS_Ltng_Funding_Allocation_Line_Item__c chItem:newReclst){
                
                chItem.gFRS_Funding_Allocation__c=upFundAlc.Id;
                newlst.add(chItem);  
            } 
            
        }
        
        
        Database.SaveResult[] upResults= Database.update(upReclst,false);
        Database.SaveResult[] inRresults= Database.insert(newlst,false);
        
        
        
    }
    
    
    @AuraEnabled
    Public static Map<Id,double> getfundAllPaymentMap(Id applicationId){
        
        gFRS_Ltng_App_Funding_Allocation__c[] fundingPaymentAmount= [SELECT Id, Payment_Amounts__c FROM gFRS_Ltng_App_Funding_Allocation__c
                                                                        Where gFRS_Application__c =: applicationId];
        
        Map<Id,double> paymentMap = new Map<Id,double>();
        for(gFRS_Ltng_App_Funding_Allocation__c allocation : fundingPaymentAmount){
            paymentMap.put(allocation.Id, allocation.Payment_Amounts__c);
        }
        
        return paymentMap;
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchApplication(Id appId){
        return [Select Id, Name, Payment_Cost_Center__c, RecordType.Name, Status__c, Sub_Status__c,LOA_Signed__c, SAP_Vendor_Required__c, Partner_Bank_Type__c, Payment_Method__c FROM gFRS_Ltng_Application__c WHERE Id =:appId ];
    }
    
    @AuraEnabled
    public static gFRS_Default_GL_Account_Info__mdt getDefaultGLAccBU(String recordType, Id allocRecordId){
        
        String recordTypeStr = '';
        if(recordType.length() > 40){
            recordTypeStr = recordType.substring(0,40);
        }else{
            recordTypeStr = recordType;
        }
        gFRS_Default_GL_Account_Info__mdt defaultGLAccountInfo = new gFRS_Default_GL_Account_Info__mdt();
        
        recordTypeStr = recordTypeStr +'%';
        /*if(allocRecordId != null && allocRecordId != ''){
            gFRS_Ltng_App_Funding_Allocation__c fundingAllocation = [SELECT Id, gFRS_GL_Account__c FROM gFRS_Ltng_App_Funding_Allocation__c
                                                                        Where Id =: allocRecordId];
            
            defaultGLAccountInfo.GL_Account_Id__c = fundingAllocation.gFRS_GL_Account__c; 
        }*/ 
        
            gFRS_Ltng_App_Funding_Allocation__c fundingAllocation = [SELECT Id, gFRS_GL_Account__c FROM gFRS_Ltng_App_Funding_Allocation__c
                                                                        Where Id =: allocRecordId];
        if(fundingAllocation.gFRS_GL_Account__c != null && fundingAllocation.gFRS_GL_Account__c != ''){
            defaultGLAccountInfo.GL_Account_Id__c = fundingAllocation.gFRS_GL_Account__c; 
        } else {
            defaultGLAccountInfo = [SELECT Id, Label, GL_Account__c, GL_Account_Id__c, Editable__c
                                                                      FROM gFRS_Default_GL_Account_Info__mdt 
                                                                      WHERE Label LIKE :recordTypeStr LIMIT 1];
            
            if(defaultGLAccountInfo != null){
                GFRS_GL_Account__c glAcc = [SELECT Id, Name, IsActive__c FROM GFRS_GL_Account__c WHERE Name =: defaultGLAccountInfo.GL_Account__c AND IsActive__c = TRUE LIMIT 1];    
                if(glAcc != null){
                    defaultGLAccountInfo.GL_Account_Id__c = glAcc.Id;    
                }else{
                    defaultGLAccountInfo = null;
                }            
            }        
        }
        return defaultGLAccountInfo;
        
    }
    
    @AuraEnabled
    public static gFRS_Default_GL_Account_Info__mdt getDefaultGLAcc(String recordType){
        
        String recordTypeStr = '';
        if(recordType.length() > 40){
            recordTypeStr = recordType.substring(0,40);
        }else{
            recordTypeStr = recordType;
        }
        
        recordTypeStr = recordTypeStr +'%';
        gFRS_Default_GL_Account_Info__mdt defaultGLAccountInfo = [SELECT Id, Label, GL_Account__c, GL_Account_Id__c, Editable__c
                                                                        FROM gFRS_Default_GL_Account_Info__mdt 
                                                                        WHERE Label LIKE :recordTypeStr LIMIT 1];
  
        if(defaultGLAccountInfo != null){
            GFRS_GL_Account__c glAcc = [SELECT Id, Name, IsActive__c FROM GFRS_GL_Account__c WHERE Name =: defaultGLAccountInfo.GL_Account__c AND IsActive__c = TRUE LIMIT 1];    
            if(glAcc != null){
                defaultGLAccountInfo.GL_Account_Id__c = glAcc.Id;    
            }else{
                defaultGLAccountInfo = null;
            }            
        }        
        
        return defaultGLAccountInfo;
        
    }
    
    @AuraEnabled
    public static Id getCostCenterId(String CostCenterCode){
        
        Id costCenterId = null;
        
        GFRS_Cost_Center_Code__c costCenter = [SELECT Id, Name from GFRS_Cost_Center_Code__c WHERE Name =: CostCenterCode LIMIT 1];
        if(costCenter != null){
            costCenterId = costCenter.Id;  
        }
        
        return costCenterId;
    }
    
    @AuraEnabled
    public static Boolean isAllocReadOnly(Id allocId){
        Boolean isReadOnly = False;
        gFRS_Ltng_App_Funding_Allocation__c allocData = [SELECT id, (SELECT id, name, status__c, SAP_Doc_ID__c from FRS_Payment_Historys__r) 
                                                            FROM gFRS_Ltng_App_Funding_Allocation__c WHERE id =: allocId];
        
        List<gFRS_Ltng_Payment_History__c> paymentList = allocData.FRS_Payment_Historys__r;
        
        for(gFRS_Ltng_Payment_History__c paymentHist : paymentList){
            if(String.isBlank(paymentHist.status__c) || paymentHist.status__c == 'Error' || paymentHist.status__c == 'Canceled'){
                isReadOnly = False;
            }
            else{
                isReadOnly = True;
                return isReadOnly;                
            }    
        }        
        return isReadOnly;        
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
    public static Boolean isNewPaymentAllocDisabled(List<gFRS_Ltng_App_Funding_Allocation__c> allocList){
        
        Boolean disableNewAlloc = False;        
        Double totalPaybleAmt = allocList.size() > 0 ? allocList[0].Total_Amount_Payable__c : 0;
        Double fundsAvailable = (totalPaybleAmt == Null) ? 0 : totalPaybleAmt;
            
        for(gFRS_Ltng_App_Funding_Allocation__c fundAlloc : allocList){
            
            if(fundAlloc.Multiple_payments_associated_with_Rqst__c == 'No'){
                disableNewAlloc = True;
                return disableNewAlloc;
            }
            
            Boolean allocHasPayment = False;
            System.Debug('isNewPaymentAllocDisabled ' + allocHasPayment);
            List<gFRS_Ltng_Payment_History__c> paymentList = [SELECT Id, Status__c, Amount__c, Payment_Method__c, gFRS_Application__r.Id, gFRS_Application__r.Record_Type__c
                                                              FROM gFRS_Ltng_Payment_History__c Where gFRS_Funding_Allocation__c=: fundAlloc.Id];
            for(gFRS_Ltng_Payment_History__c paymentHist : paymentList){
                if(paymentHist.Status__c == 'Success'){
                    allocHasPayment = True;
                    fundsAvailable = fundsAvailable - paymentHist.Amount__c;
                }
            }
            if(allocHasPayment == False){
                disableNewAlloc = True;
                return disableNewAlloc;
            }
        }
        if(fundsAvailable <= 0 && allocList.size() > 0){
            disableNewAlloc = True; 
        }
        return disableNewAlloc;
    }
    
    @AuraEnabled
    public static Boolean  sendNotificationEmails(String RecId){

        EmailTemplate  emailCon = [SELECT Subject, Name, Id, Markup,Description,HTMLValue, Body,DeveloperName
                                   FROM EmailTemplate WHERE DeveloperName = 'gFRS_2_0_Foundation_Payment_Confirmation'];
        gFRS_Ltng_Application__c gfrsRequest=[SELECT Id,Name,Event_Program_Title__c,Payment_Method__c,owner.email FROM gFRS_Ltng_Application__c Where Id=:RecId];
        String emailSub = emailCon.Subject;
        //String htmlBody = emailCon.Body;
        String htmlBody = emailCon.HTMLValue;
        htmlBody = htmlBody.replace('ApplicationName', gfrsRequest.Name);
        
        if(gfrsRequest.Event_Program_Title__c != null && gfrsRequest.Event_Program_Title__c != '') {
            htmlBody = htmlBody.replace('EventProgramTitle', gfrsRequest.Event_Program_Title__c);
        }else {
            htmlBody = htmlBody.replace('EventProgramTitle', '');
        }
        
        if(String.isNotBlank(gfrsRequest.Payment_Method__c)) {
            htmlBody = htmlBody.replace('PaymentMethod', gfrsRequest.Payment_Method__c);
        }else {
            htmlBody = htmlBody.replace('PaymentMethod', '');
        }
        
        String refferId = '[ref:'+RecId+']';
        Boolean isSuccess = false;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'fundingrequestsystem-donotreply-d@gene.com'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        List<String> toAddresses = new List<String>();
        //List<String> toCCddresses = new List<String>();
        List<String> tobCCddresses = new List<String>();
        
        toAddresses.add(gfrsRequest.owner.email);
        toAddresses.add('thokalay@gene.com');
        
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){
            String bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
            tobCCddresses.add(bccEmailAddress.trim());
        }
        string str = '<'+RecId.left(9)+'@'+RecId.right(9)+'>';
        String reff = 'References: 1*'+str+' CRLF';
        
        htmlBody = htmlBody.replace(']]>', '');
        
        email.setToAddresses(toAddresses);
        //email.setCcAddresses(toccddresses);
        email.setBccAddresses(tobCCddresses);
        
        email.setReferences('References: 1*'+str+' CRLF');
        email.setSubject(emailSub);
        
        //EmailBody.replaceAll('\n', '<br/>');
        htmlBody =htmlBody +'\n\n' + '[ref:' + RecId + ']';
        
        email.setHtmlBody(htmlBody);
        
        //email.setplainTextBody(htmlBody);
        //email.setTreatBodiesAsTemplate(true);
        
        try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  
            if(results[0].success){
                isSuccess = TRUE;
                
            }else{
                isSuccess = FALSE;
            }
        } catch(Exception ex){
            isSuccess = FALSE;
        }
        return isSuccess;   
        
    }
    
    @AuraEnabled
    public static String validateLitemCompanyCode(List<gFRS_Ltng_Funding_Allocation_Line_Item__c> lineItemList){
        
        String validationMsg = null;        
        Set<Id> costCenterIds = new Set<Id>();
        Set<Id> wbsCodeIds = new Set<Id>();
        Set<String> companyCodes = new Set<String>();
        
        for(gFRS_Ltng_Funding_Allocation_Line_Item__c lineItem : lineItemList){
            costCenterIds.add(lineItem.Cost_Center_Code__c);
            wbsCodeIds.add(lineItem.WBS_Code__c);
        }
        
        Map<Id,GFRS_Cost_Center_Code__c> costCenterMap = New Map<Id,GFRS_Cost_Center_Code__c>([SELECT Id, Name, IsActive__c, SAP_Company_Code__c FROM GFRS_Cost_Center_Code__c WHERE Id in :costCenterIds]);
        Map<Id,GFRS_WBS_Codes__c> wbsCodeMap = New Map<Id,GFRS_WBS_Codes__c>([SELECT Id, Name, IsActive__c, SAP_Company_Code__c FROM GFRS_WBS_Codes__c WHERE Id in :wbsCodeIds]);
        
        for(gFRS_Ltng_Funding_Allocation_Line_Item__c lineItem : lineItemList )
        {
            
            if(costCenterMap.get(lineItem.Cost_Center_Code__c).IsActive__c != true){
                validationMsg = 'Cost Center ' + costCenterMap.get(lineItem.Cost_Center_Code__c).Name + ' is inactive. Please make sure the Cost Center is active.';
                return validationMsg;                
            }
            
            if(wbsCodeMap.get(lineItem.WBS_Code__c).IsActive__c  != true){
                validationMsg = 'WBS Code ' + wbsCodeMap.get(lineItem.WBS_Code__c).Name + ' is inactive. Please make sure the WBS Code is active.';
                return validationMsg;                
            }
            
            if(costCenterMap.get(lineItem.Cost_Center_Code__c).SAP_Company_Code__c != wbsCodeMap.get(lineItem.WBS_Code__c).SAP_Company_Code__c){
                validationMsg = 'The Cost Center and WBS Code\'s company code do not match. Please make sure the Cost Center and WBS Code are correct.';
                return validationMsg;    
            }
            
            companyCodes.add(costCenterMap.get(lineItem.Cost_Center_Code__c).SAP_Company_Code__c);
            if(companyCodes.size() > 1){
                validationMsg = 'Payment allocation line items Cost Center Company Codes do not match. Please enter appropriate Cost Centers under the same Company Code.';
                return validationMsg;   
            }
        }
        
        return validationMsg;
        
    }

    @AuraEnabled
    public static Boolean isGlAccActive(String glAccountId){
        
        Boolean isActiveAcc = False;
  
        if(glAccountId != null){
            GFRS_GL_Account__c glAcc = [SELECT Id, Name, IsActive__c FROM GFRS_GL_Account__c WHERE Id =: glAccountId];    
            if(glAcc != null && glAcc.IsActive__c == True){
                isActiveAcc = True;
            }           
        }        
        
        return isActiveAcc;        
    }    
}