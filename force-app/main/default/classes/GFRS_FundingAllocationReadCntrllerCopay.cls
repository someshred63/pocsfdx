/**
* @author ADMD Team
* @date 13/03/2013
* @description GFRS_FundingAllocationReadCntrllerCopay class - extension class GFRS_FundingAllocationRead page.
*
*/
public with sharing class GFRS_FundingAllocationReadCntrllerCopay {
    
    public static final String PATH_REQUEST = Page.GFRS_FundingAllocationReadCopay.getURL();
    
    public GFRS_Copay_Funding_Request__c myFundingReq              { get; set; }
    public GFRS_Copay_Funding_Allocation__c allocation                      { get; set; }
    public GFRS_Copay_Funding_Allocation_Line_Item__c[] allocationLineItems { get; set; }
    public GFRS_Copay_Payment_History__c activePaymentHistory               { get; set; }
    public list<GFRS_Copay_Payment_History__c> PaymentHistory               { get; set; }
      
    public Boolean isUserFinancialApprover3                           { get; set; }
    public Boolean isPaymentSubmitted                                 { get; set; }
    public Boolean isPaymentSent                                      { get; set; }
    public Boolean isPaymentConfirmPopUpShown                         { get; set; }
    public Boolean isFAPaymentType                                    { get; set; }
    public Boolean showSubmitButtons                                  { get; set; }
    public Boolean isLineItemEditable                                 { get; set; }
    public Boolean isCostCenterEditable                               { get; set; }
    public String userProfileName                                     { get; set; }
    public Boolean isInternalRequest                                  { get; set; }
    private Boolean isTraceOn                                         = false;
    public Boolean enableSubmitForPaymentButton                       { get; set; }
    public String vendorBlockMessage                                  { get; set; }
    public Boolean glAccountEditable                                  { get; set; }
    
    private final ApexPages.StandardController ctrl;
    private GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
    
    /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description GFRS_FundingAllocationReadCntrllerCopay constructor method.  
    */  
    public GFRS_FundingAllocationReadCntrllerCopay( ApexPages.StandardController std )
    {    
        ctrl = std;
        if(this.allocation == null)
        {
            this.allocation = (GFRS_Copay_Funding_Allocation__c)std.getRecord();
            if(this.allocation != null && this.allocation.Id != null){
              this.allocation = refreshAllocation(this.allocation.Id);
            }
        }

        populateGLAccountIfExists();

        this.allocationLineItems = getLineItemsForGivenFundingAllocation(this.allocation);
        
        if(this.allocation.RecordType.Name=='Payment'){ isFAPaymentType=true;}
        else{isFAPaymentType=false;}
        
        this.myFundingReq = [select RecordType.DeveloperName, Financial_Approver_1__c,Financial_Approver_1_Decision_Date__c,Financial_Approver_2__c,Financial_Approver_2_Decision_Date__c,Financial_Approver_3__c,Financial_Approver_3_Decision_Date__c,id, name, Refundable_Deposit_Amount_if_any__c, Payment_Call_Counter__c, Payment_Automation__c, Total_Approved_Amt__c, Total_Payment_Amount__c, Status__c, Sub_Status__c, Delivery_Method__c,Attention_To__c,Record_Type_Name__c,Locationcopay__r.Vendor_id__c,( select id from Copay_Payment_History__r ) from GFRS_Copay_Funding_Request__c where id = :this.allocation.Grant_Request__r.id limit 1 ];

/*        if(GFRS_Util.showWarningMessageForGLAccount(this.myFundingReq))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.gFRS_Check_GL_Account));  */

        if( this.allocation.Grant_Request__r.Total_Approved_Amt__c == null ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_NO_APPROVED_AMOUNT ));
        }
        
        isInternalRequest = allocation.Grant_Request__r.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME;
        isUserFinancialApprover3 = false;
        this.PaymentHistory = [Select id, Status__c FROM GFRS_Copay_Payment_History__c where Status__c = 'Success' and Funding_Allocation__c = :this.allocation.Id limit 1];
        if(this.PaymentHistory.size() > 0){
            showSubmitButtons=false;
            glAccountEditable=false;
        }
        else {
            showSubmitButtons=true;
            glAccountEditable=true;
        }

        String userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;
        if( userProfileName == 'GNE-GFRS-Copay-User' ){
             showSubmitButtons=false;             
        }        
        
        if (myOrgCS.TraceFundingAllocationReadController__c)  isTraceOn=true;
        
        userProfileName = gFRS_DAOCopay.getProfileById(Userinfo.getProfileId()).Name;
        if( userProfileName == gFRS_Util.PROFILE_NAME_GFRS_ADMIN || userProfileName == gFRS_Util.PROFILE_NAME_SYS_ADMIN ){
                this.isLineItemEditable = true; 
        }else{
                if(gFRS_Util_NoShareCopay.checkIsPaymentSuccesfullySubmitted(this.allocation)){
                        this.isLineItemEditable=false;
                }else{this.isLineItemEditable=true;}
        }
        
        List<GFRS_Copay_Payment_History__c> tmpPaymentList = gFRS_DAOCopay.getPaymentHistoryByFundingAllocation(this.allocation);
        this.isPaymentSent = tmpPaymentList.size()>0 ? true : false;
        isCostCenterEditable = true;
        
    }

    void populateGLAccountIfExists() {
 /*       if (this.allocation.get('GL_Account_ref__c') == null && String.isNotBlank(this.allocation.GL_Account__c)) {
            try {
                this.allocation.put('GL_Account_ref__c', [
                        SELECT Id FROM GFRS_GL_Account__c WHERE Name = :this.allocation.GL_Account__c LIMIT 1
                ].Id);
            } catch (QueryException e) {}
        }  */
    }

  /*  public Boolean glAccountEditable {
        get {
            final String fTypes = GFRS_OrgSettings__c.getOrgDefaults().GL_Account_Not_Editable_Funding_Types__c;
            return String.isBlank(fTypes) || !fTypes.containsIgnoreCase(myFundingReq.RecordType.DeveloperName);
        }
    }  */

    public void glAccountChanged() {
        try {
            upsert this.allocation;
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex)));
        }
        if(this.allocation != null && this.allocation.Id != null) {
            this.allocation = refreshAllocation(this.allocation.Id);
        }
    }

    public void checkVendorLock(){
      if(myFundingReq.Attention_To__c != null) {
        this.vendorBlockMessage = gFRS_Vendor_Block_WSCopay.checkVendorBlock(myFundingReq.Id);
        id userProfileId = UserInfo.getProfileId();
        if ([select Name from profile where id = :userProfileId].Name=='GNE-GFRS-User'){
                this.vendorBlockMessage = '';
        }
      } else {
        this.vendorBlockMessage = '';
      }
    }
    
    private GFRS_Copay_Funding_Allocation__c refreshAllocation(Id allocationId){
      return [
      select 
        Id, 
        Name,
        CreatedById,
        Fiscal_Year__c,
        Pct_Covered__c,
        Baseline_Date__c,       
        RecordType.Name, 
        Approved_Amount__c,
        Refundable_Amount__c,
        Funding_Total__c,
        Request_Amount__c, 
        Payment_Amount__c,
        Funding_Allocation_PDF_Snapshot__c,
        Funding_Allocation_PDF__c, 
        Grant_Request__c,
        Grant_Request__r.Record_Type_Name__c,  
        Grant_Request__r.Total_Approved_Amt__c, 
        Grant_Request__r.Financial_Approver_3__c, 
        Grant_Request__r.Refundable_Deposit_Amount_if_any__c,
        LastModifiedById,
        Organization_Name__c, 
        Type_of_Check_Received__c, 
        Check_Number__c, 
        Refund_Amount__c, 
        Amount_Paid_Flag__c,
        Paid_Amount__c,
        GL_Account_ref__c
      from GFRS_Copay_Funding_Allocation__c
      where id = :this.allocation.id
       
    ];
       
    }
    
    //*** Buttons, Links, Inputs events, Action page ***
    
    public ApexPages.PageReference actionActivities(){
    //  createDefaulFALineItems();  
      
      if(this.allocation != null && this.allocation.Id != null){
          
            if(String.isBlank(this.allocation.Funding_Allocation_PDF__c) &&
               this.allocation.Paid_Amount__c > 0){
                   
                   PageReference pageRefPdf = null;
                   pageRefPdf               = new ApexPages.Pagereference( Page.gFRS_FundingAllocationSnap.getURL() );
                   pageRefPdf.getParameters().put('id',this.allocation.id);   
                   pageRefPdf.setRedirect(true);
                   String documentName      = 'Funding_Allocation_PDF_' + this.allocation.Name + '.pdf';
                   
                   gFRS_Util_NoSharecopay.insertAllocationPDFAttachment(documentName,pageRefPdf.getContent(),this.allocation);
            }   
            this.allocation = refreshAllocation(this.allocation.Id);
         /*     if(this.allocation.GL_Account_ref__c == null){
                  this.allocation.GL_Account_ref__c = GFRS_Copay__c.getOrgDefaults().GL_Account__c;
              }       */
            populateGLAccountIfExists();
            this.allocationLineItems = getLineItemsForGivenFundingAllocation(this.allocation);                  
          
        }

      validateCoverageOfPayments();
      return null;
      
    }
/*    public void createDefaulFALineItems()
    {
        system.debug('check values of allocation');
        system.debug(this.allocationLineItems);
        if(this.allocationLineItems!=null)
        {
            if(this.allocation.Grant_Request__r.Record_Type_Name__c=='IMED' && this.allocationLineItems.size()==0)
            {
              gFRS_PaymentProcess paymentProcess = new gFRS_PaymentProcess();
              GFRS_Funding_Allocation__c[] arr   = new GFRS_Funding_Allocation__c[]{};
              arr.Add(this.allocation);
              paymentProcess.createDefaultFALineItemsWBSForIMED(arr);
             
              this.allocationLineItems = getLineItemsForGivenFundingAllocation(this.allocation);
            }
        }
        
 
    }  */
    
     /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description saveRefunds method - saves Refunds funding allocation and allocation line itmes.  
    */
 /*   public ApexPages.Pagereference saveRefunds()
    {    
        try
        {
            boolean isValidData = validateRefundData();
            
            if(!isValidData) return null;

            saveRefundsData();

        }
        catch(Exception ex)
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex) ) );
            return null;
        }
        
      return( new ApexPages.PageReference(PATH_REQUEST+'?id=' + this.allocation.id).setRedirect(true));
    }  */
    
     /** 
    * @Author ADMD Team
    * @date 25/04/2013
    * @description savePage method - old method. Should be removed. Added only to resolve deployment problems. 
    */  
/*    public ApexPages.Pagereference savePage()
    {
        return null;
    }  */
    
     /** 
    * @Author ADMD Team
    * @date 25/04/2013
    * @description deleteLI method - old method. Should be removed. Added only to resolve deployment problems. 
    */  
 /*   public ApexPages.Pagereference deleteLI()
    {
        return null;
    }
    
    public ApexPages.Pagereference createLI()
    {
        return null;
    }  */
    
    /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description savePayment method - saves Funding allocation and allocation line itmes.  
    */  
 /*   public ApexPages.Pagereference savePayment()
    {

        Boolean isDataValid = false;
        try
        {
            
            isDataValid = validatePayments();
            if(!isDataValid) return null;
            
      system.debug('after validations');
            setLinesWithInformation();
                       
            if(isUserFinancialApprover3)
            {
                system.debug(this.allocationLineItems);
                gFRS_Util_NoShare.saveLockedAllocationLIs(this.allocationLineItems);  
            }
            else
            {        
                update this.allocationLineItems;
        //    }
            
            gFRS_Copay_Funding_Request__c fundReq = new gFRS_Copay_Funding_Request__c( id = this.allocation.Grant_Request__c );
               
            if(isUserFinancialApprover3)
            {
                gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(fundReq);
            }
            else
            {     
                update fundReq;
        //    }

            
        }
        catch( Exception err )
        {
            system.debug('this exception was catched');
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
            return null;
        }
        
        return( new ApexPages.PageReference(PATH_REQUEST+'?id=' + this.allocation.id).setRedirect(true));
    }  */
    
    /** 
    * @Author ADMD Team
    * @date 04/12/2013
    * @description validatePayments method - validates payments - checks whether SAP Company Code in Cost Center and WBS Code are equal. 
    */ 
  /*  private Boolean validatePayments(){
        Set<String> costCentersIds = new Set<String>();
        Set<String> wbsCodesIds    = new Set<String>();
        
        for( gFRS_Copay_Funding_Allocation_Line_Item__c lineItem : this.allocationLineItems ){
            costCentersIds.add(lineItem.Cost_Center_Lookup__c); 
            wbsCodesIds.add(lineItem.WBS_Code_Lookup__c);   
        }
        
        Map<Id,GFRS_Cost_Center_Code__c> costCentersMap = gFRS_Util.getCostCentersMapByIds(costCentersIds);
        Map<Id,GFRS_WBS_Codes__c> wbsCodesMap           = gFRS_Util.getWbsCodesMapByIds(wbsCodesIds);
        Set<String> sapCompanyCodeFLI                   = new Set<String>();

        for( gFRS_Copay_Funding_Allocation_Line_Item__c li : this.allocationLineItems )
        {   
            if(li.Cost_Center_Lookup__c == null){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_COST_CENTER_NULL) );
                return false;
            //    break;  
            }
            if(li.WBS_Code_Lookup__c == null){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_WBS_NULL ) );
                return false;
            //    break;  
            }
            if(costCentersMap.get(li.Cost_Center_Lookup__c) == null || wbsCodesMap.get(li.WBS_Code_Lookup__c) == null ||  costCentersMap.get(li.Cost_Center_Lookup__c).SAP_Company_Code__c != wbsCodesMap.get(li.WBS_Code_Lookup__c).SAP_Company_Code__c){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_SAP_CC ) );
                return false;
            //    break;  
            }
            //check if Company Code is 1010 and user is F3 then Commercial Activity ID is mandatory field.
            if( costCentersMap.get(li.Cost_Center_Lookup__c).SAP_Company_Code__c=='1010' 
            && wbsCodesMap.get(li.WBS_Code_Lookup__c).SAP_Company_Code__c=='1010' 
            && isUserFinancialApprover3==true && li.Commercial_Activity_ID__c==null)
            {
                 ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_SelectComActivity));
                 return false;
                 break;
            }  
            //cheick if Company Code is 1000 and Commercial Activity ID is set. Must be null.
            if( costCentersMap.get(li.Cost_Center_Lookup__c).SAP_Company_Code__c=='1000' 
            && wbsCodesMap.get(li.WBS_Code_Lookup__c).SAP_Company_Code__c=='1000' 
            && li.Commercial_Activity_ID__c!=null)
            {
                 ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_SelectComActivityToNull));
                 return false;
                 break;
            }  
            sapCompanyCodeFLI.add(costCentersMap.get(li.Cost_Center_Lookup__c).SAP_Company_Code__c);
            //GFRS-287 splits need to have the same cost center sap company codes
            if(sapCompanyCodeFLI.size()>1){
                
              //FLI have cost centers with different sap company codes payment will fail block user for savig such allocations
              ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_FLI_Diff_Cost_Center_Company_Code ) );
                return false;
            //    break; 
            }
            
        }
        
        if( !gFRS_Util_NoShareCopay.validatePercentageOfLineItems(this.allocationLineItems)){
          ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_PaymentPercentageErrorPlainText));
          return false;
        }

        
        return true;
    }  */
    
     /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description newFundingAllocationLineItem() method - creates funding allocation line items for both types refund/payment 
    */
  /*  public void newFundingAllocationLineItem()
    {
        try
        {
      GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
          List<GFRS_Cost_Center_Code__c> hcAndPhilantrophicCostCenterCodeToPopulate =
                      [  SELECT 
                          Id
                        FROM GFRS_Cost_Center_Code__c
                        WHERE IsActive__c = true AND Name =:myOrgCS.CapDefaultCostCenterForLI__c LIMIT 1];
                        
      List<GFRS_Cost_Center_Code__c> imedCostCenterCodeToPopulate =
                      [  SELECT 
                          Id
                        FROM GFRS_Cost_Center_Code__c
                        WHERE IsActive__c = true AND Name =:myOrgCS.IMEDDefaultCostCenterForLI__c LIMIT 1];
        
      Id tmpCostCenterId = null;                
      if( this.allocation.Grant_Request__r.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){
                if (imedCostCenterCodeToPopulate.size() > 0){
                    tmpCostCenterId = imedCostCenterCodeToPopulate.get(0).Id;
                } else {
                    isCostCenterEditable = true;
                    isLineItemEditable = true;
                }
      } else if(this.allocation.Grant_Request__r.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME || this.allocation.Grant_Request__r.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME || this.allocation.Grant_Request__r.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME || this.allocation.Grant_Request__r.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
                if (hcAndPhilantrophicCostCenterCodeToPopulate.size() > 0){
                    tmpCostCenterId = hcAndPhilantrophicCostCenterCodeToPopulate.get(0).Id;
                } else {
                    isCostCenterEditable = true;
                    isLineItemEditable = true;
                }                
      }    
                 GFRS_Copay__c gc = GFRS_Copay__c.getOrgDefaults();
             
            GFRS_Copay_Funding_Allocation_Line_Item__c  li = new GFRS_Copay_Funding_Allocation_Line_Item__c
              ( Funding_Allocation__c = this.allocation.id,
              Percent__c              = 100,
              Funding_Record_Type__c  = this.allocation.Grant_Request__r.Record_Type_Name__c,
             Cost_Center_Lookup__c   = gc.Cost_Center__c,
              WBS_Code_Lookup__c      = gc.WBS_Code__c
               );
              
            if(isFAPaymentType)
            {
                //Payment Type
                //If user is FinancialApprover3. He need to have right to modify even if records are locked.
                if(isUserFinancialApprover3)
                {
                    li=gFRS_Util_NoShare.insertFundingAllocLineItem(li);
                }
                else
                {   
                    //insert based on sharing rules for rest of users.
                    insert li;
                }
            }
            else
            {
                //Refund Type. No restrictions. All users can do refunds even if records are locked.
                //No sharing.
                li=gFRS_Util_NoShare.insertFundingAllocLineItem(li);
            }  
            
            li = getLineItemDetails(li).get(0); 
            this.allocationLineItems.add(li);   
           // this.allocationLineItems = getLineItemsForGivenFundingAllocation(this.allocation);
                              
        } 
        catch( Exception ex )
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex) ) );
        }
    }  */
    
    /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description deleteFundingLineItem method - deletes funding allocation line items
    */  
 /*   public ApexPages.Pagereference deleteFundingLineItem()
    {       
        System.debug( 'indexToModify:' + this.indexToModify );
        
        GFRS_Copay_Funding_Allocation_Line_Item__c removed = getMatchingFundingAllocationLineItem( this.indexToModify );
        if( removed == null ){
            System.debug( 'cannot find the allocation item to remove:' + this.indexToModify );
            return null; 
        }
        
        try{
            if( removed != null && removed.id != null )
            {
                if(isFAPaymentType)
                {
                    //Payment type.
                    //if user is FinancialApprover3. He need to have right to modify even if records are locked.
                    if(isUserFinancialApprover3)
                    {
                        gFRS_Util_NoShare.deleteFundingAllocLineItem(removed);
                    }
                    else
                    {   
                        //delete based on sharing rules for rest of users.
                        delete removed;
                     }
                }
                else
                {
                   //Refund Type. No restrictions. All users can do refunds even if records are locked.
                   //No sharing.
                   gFRS_Util_NoShare.deleteFundingAllocLineItem(removed);
                }   
                
                //we have to refresh line items list after deleting one of the included item
                this.allocationLineItems = getLineItemsForGivenFundingAllocation(this.allocation);
            }
        } catch( Exception err )
        {
            String errMsg = gFRS_Util.getPrettyMessage(err);
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            
            //-- add back to the list
            this.allocationLineItems.add( removed );
        }
        
        return  (new ApexPages.PageReference(PATH_REQUEST+'?id=' + this.allocation.id).setRedirect(true));
    }  */
    
     /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description showPaymentConfirmPopup() method - shows payment popup.
    */ 
    public void showPaymentConfirmPopup()
    {
        try
        {   
            if(this.myFundingReq.Payment_Automation__c == 'Manual'){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Manual_payments_cannot_be_processed_through_the_system ) );             
                return;
            }
            
            if(this.allocation.Baseline_Date__c == null || this.allocation.Baseline_Date__c < date.today()){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_CoPay_Baseline_Date_is_missing ) );             
                return;
            }           
            //-- check before making the payment history, so don't check if the history already exists
            if( !gFRS_PaymentUtilCopay.canSubmitFundingAllocationPayment( false, this.activePaymentHistory, this.myFundingReq, this.allocation , this.allocationLineItems ) ){
                enableSubmitForPaymentButton = true;
                return;
            } 
            if(validatePaymentData()){
                this.activePaymentHistory = gFRS_PaymentUtilCopay.createActivePaymentHistoryUI(this.myFundingReq);
                
                if( this.activePaymentHistory == null ){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_HISTORY_NO_CREATE));
                } else {
                    this.isPaymentConfirmPopUpShown = true;
                    isPaymentSubmitted=false;
                }
            }
        }
        catch(Exception ex)
        {
             ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex) ) );
        }        
    }
    
    
    /** 
    * @Author ADMD Team
    * @date 24/05/2013
    * @description validatePaymentData() method - validation method for payment submition
    */ 
    private Boolean validatePaymentData(){
        Boolean retVal = true;
        if(String.isBlank(this.allocation.GL_Account_Ref__c))
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_GL_ACCOUNT_REQUIRED));
            retVal = false;
        }
        for( gFRS_Copay_Funding_Allocation_Line_Item__c li : this.allocationLineItems )
        {
            if(li.Cost_Center_Lookup__c==null )
            {
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_COST_CENTER_NULL) );
                retVal = false;
                break;
            }    
            else if(li.WBS_Code_Lookup__c==null)
            {
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_WBS_NULL) );
                retVal = false;
                break;
            }   
        }
        
        return retVal;
    }
    
    /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description hidePaymentConfirmPopup method - hides payemnt popup.
    */ 
    public ApexPages.PageReference hidePaymentConfirmPopup()
    {
        //-- ONLY delete the payment history if it was not submitted to the ESB
        if( !this.isPaymentSubmitted ) gFRS_PaymentUtilCopay.cleanupActivePaymentHistory( this.activePaymentHistory );
        
        return( new ApexPages.PageReference(PATH_REQUEST+'?id=' + this.allocation.id).setRedirect(true) );
    }

 /*   Boolean validateGLAccountForRefund() {
        if(String.isBlank(this.allocation.GL_Account__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_GL_ACCOUNT_REQUIRED));
            return false;
        }
        return true;
    }  */

     /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description showRefundConfirmPopup() method - shows refund popup.
    */ 
 /*   public void showRefundConfirmPopup()
    {
         //Check can send Refund.
         if(canSubmitFundingAllocationRefund())
         {

           //Check is refund data valid.
           if(validateGLAccountForRefund() && validateRefundData() && validateCoverageOfPayments())
           {
             //create refund history record. SF do not allows to executes dml after web service callout.
             if(createActivePaymentHistoryRefund())
             {
                 isRefundConfirmPopUpShown=true;
                 this.isRefundSubmitted=false;
             }
           }  
         }         
    }  */  
    
    /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description hideRefundConfirmPopup method - hides refund popup.
    */ 
 /*   public ApexPages.PageReference hideRefundConfirmPopup()
    {
        //delete the payment history if it was not submitted to the ESB
        if( !this.isRefundSubmitted ) gFRS_PaymentUtil.cleanupActivePaymentHistory( this.activePaymentHistory );
        
        return( new ApexPages.PageReference(PATH_REQUEST+'?id=' + this.allocation.id).setRedirect(true) );
    }  */
    
     /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description sendFundingAllocToESB method - sends payment to SAP.
    */ 
    public ApexPages.PageReference sendFundingAllocToESB()
    {
        
        GFRS_Funding_Request__c fundReq                   = null;
        GFRS_Funding_Allocation_Line_Item__c[] splitLines = null;
        
        if( !gFRS_PaymentUtilCopay.canSubmitFundingAllocationPayment(true, this.activePaymentHistory, myFundingReq, this.allocation, this.allocationLineItems) ) return( null );
        
        if( this.isPaymentSubmitted ){
            System.debug( 'already submitted, so cannot submit until the confirmation is opened again' );
            return( null );
        }
        
        this.isPaymentSubmitted = true;        
        
        Boolean result = gFRS_PaymentUtilCopay.sendFundingAllocationPaymentToESB(this.allocation.Grant_Request__r.id, this.allocation.id, this.activePaymentHistory);
        
        PageReference pageRefPdf = null;
        pageRefPdf = Page.gFRS_VendorDetailsPDFCopay;
        pageRefPdf.getParameters().put('id',myFundingReq.id);   

        List<Attachment> requestAttachments = [Select Name From Attachment Where ParentId =: this.myFundingReq.Id and Name like '%Vendor_Details%'];
        Integer max = 0;
        if ( requestAttachments.size() > 0 ){
            for ( Attachment att : requestAttachments ){
                String attachmentNumber = att.Name.substring( att.Name.indexOf('_V')+2, att.Name.length()-4 );
                if ( max < Integer.valueOf( attachmentNumber )){
                    max = Integer.valueOf( attachmentNumber );
                }    
            }    
        }            
        max = max + 1;
        String documentName = 'Vendor_Details_' + this.myFundingReq.Name + '_V'+ max +'.pdf';
        if (Test.isRunningTest()) {
            gFRS_Util_NoShareCopay.insertVendorDetailsAttachmentExternal(documentName, blob.valueOf('Unit.Test'), this.myFundingReq);
        } else {
            gFRS_Util_NoShareCopay.insertVendorDetailsAttachmentExternal(documentName, pageRefPdf.getContent(), this.myFundingReq);
        }

        if(result== true){                    
            return( new ApexPages.PageReference(PATH_REQUEST+'?id=' + this.allocation.id).setRedirect(true));
        }
        else {
            
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_HISTORY_NO_CREATE ));
        }
        
        return( null );
    }
    
      /** 
    * @Author ADMD Team
    * @date 08/04/2013
    * @description sendFundingRefundAllocToESB method - sends refund to ESB/SAP.
    */ 
   /* public ApexPages.PageReference sendFundingRefundAllocToESB()
    {
        try
        {
            //Processing callout
            this.activePaymentHistory.Status__c='Processing';
            this.activePaymentHistory.Date__c = date.today();
            
            //create ESB/SAP interface callout object
            gFRS_SubmitGrantWS.GneCOMM_Grants_SFDC_O_1Port0 sapGrant = new gFRS_SubmitGrantWS.GneCOMM_Grants_SFDC_O_1Port0();
            sapGrant.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
            String headerText = myFundingReq.Event_Program_Title__c;
        
            if( headerText != null && headerText.length() > 25 ) headerText = headerText.substring(0,25);
        
            String sapRequestId                         = this.activePaymentHistory.SAP_Request_ID__c;
            gFRS_SubmitGrantSAP.Details_element details = new gFRS_SubmitGrantSAP.Details_element();

            details.vendorId                            = myFundingReq.Locationcopay__r.Vendor_id__c;
            details.totalAmount                         = String.valueOf(this.activePaymentHistory.Amount__c);
            details.paymentMethod                       = gFRS_Util.ESB_CHEQUE; //added only for a valid call. ESB will not use this field while processing the refund.
            details.paymentBlock                        = 'I';
            details.programTitle                        = myFundingReq.Delivery_Method__c == gFRS_Util.SFDC_ORANGE_POUCH ? '*OP '+myFundingReq.Unix_ID__c+' '+myFundingReq.Building__c : '*' + myFundingReq.Event_Program_Title__c;
            details.accountableEmployee                 = myFundingReq.Unix_ID__c;
            details.delivaryMethods                     = gFRS_Util.translateDeliveryMethodToESB( myFundingReq.Delivery_Method__c );
            details.fedExRequested                      = false;
            details.attentionTo                         = myFundingReq.Attention_To__c;
            details.businessPartnerNotificationEmail    = myFundingReq.Payment_Email_Notification__c;
            details.Split                               = getGrantRefundSplitLines();
            String companyCode                          = gFRS_Util.determineCompanyCode( this.allocationLineItems );
             
            gFRS_SubmitGrantSAP.submitGrantResponse_element response =  sapGrant.submitGrant(sapRequestId, 'Refund', companyCode, date.today(), 'USD', headerText, details );
            
            handleSubmitRefundResponse(response, sapRequestId);
            
            this.isRefundSubmitted = true;
            
        }    
        catch(System.CalloutException e)
        {
            system.debug('CalloutException line Number:' + e.getLineNumber());
            system.debug('CalloutException getMessage:' + e.getMessage());
            String errMsg = gFRS_Util.getPrettyMessage(e);
            if(errMsg.contains('Read timed out'))
            {
                 //ESB sometimes closes connection but it doesn't mean that refund fails.
                 //We need mark such refund is still in processing.
                 this.activePaymentHistory.Status__c    = 'Processing';
                 this.activePaymentHistory.ESB_Error__c ='';
            }
            else
            {
                 this.activePaymentHistory.ESB_Error__c = errMsg + '\n';
                 this.activePaymentHistory.Status__c    = 'Error';
            }
            return null;
          
        } 
        catch (Exception ex )
        {
            String errMsg                          = gFRS_Util.getPrettyMessage( ex );
            this.activePaymentHistory.Status__c    = 'Error';
            this.activePaymentHistory.ESB_Error__c = errMsg + '\n';
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            return null;
        }
        
        try
        {
            update this.activePaymentHistory;
            update this.myFundingReq; 
        }
        catch (DmlException dmlEx)
        {   
            string errMsg='update activePaymentHistory and myFundingReq:'; 
            
            for (Integer i = 0; i < dmlEx.getNumDml(); i++)
            {
                // Process exception here 
                errMsg = errMsg + dmlEx.getDmlMessage(i); 
            }
            
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg));
            return null; 
        }
        
        //Refund send successfuly. Refresh page.
        return( new ApexPages.PageReference(PATH_REQUEST+'?id=' + this.allocation.id).setRedirect(true)); 
    }  */
    
     /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description updateTotal() method - update values FALI
    */
 /*   public void updateTotal()
    {
        System.debug( 'updateTotal Called(' + this.fieldTypeChanged + ', ' + this.currentLineItemIndex + ', ' + this.lastInputValue + ')');
        
        GFRS_Copay_Funding_Allocation_Line_Item__c lineToUpdate = null;
        
        try
        {
            lineToUpdate = [select  Amount__c, Percent__c from GFRS_Copay_Funding_Allocation_Line_Item__c where id =: this.currentLineItemIndex ];
        }
        catch( Exception err )
        {
            System.debug( 'error finding line to update[' + this.currentLineItemIndex + ']:' + lineToUpdate );
            return;
        }
        
        
        Decimal newValue = 0;
        try
        {
            newValue = Decimal.valueOf( this.lastInputValue );
        }
        catch( Exception err )
        {
            System.debug( 'errorDeterminingvalue[' + this.lastInputValue + ']:' + newValue );
            return;
        }
      
        try
        {
            if( lineToUpdate != null )
            {
                if(this.fieldTypeChanged == 'percent')
                {
                    lineToUpdate.Percent__c = newValue;
                    lineToUpdate.Amount__c  = null;
                } else if(this.fieldTypeChanged == 'amount')
                {
                    lineToUpdate.Amount__c  = newValue;
                    lineToUpdate.Percent__c = null;
                }
                System.debug( 'before the update:' + lineToUpdate );
                update lineToUpdate;
            }
        } 
        catch( Exception err )
        {
            String errMsg = gFRS_Util.getPrettyMessage(err);
            System.debug( 'exception occurred:' + errMsg );
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, errMsg ) );
        }
    }  */
    
    /*** private methods ***/
    
     /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description setLinesWithInformation() method - sets funding allocation line items
    */ 
  /*  private void setLinesWithInformation()
    {
        gFRS_Copay_Funding_Allocation_Line_Item__c[] filledLineItems = new gFRS_Copay_Funding_Allocation_Line_Item__c[]{};
        gFRS_Copay_Funding_Allocation_Line_Item__c[] emptyLineItems  = new gFRS_Copay_Funding_Allocation_Line_Item__c[]{};
        
        if( this.allocationLineItems != null )
        {
            for( gFRS_Copay_Funding_Allocation_Line_Item__c item : this.allocationLineItems )
            {
                if( item.Accountable_Employee__c != null ||
                    item.Cost_Center_Lookup__c != null ||
                    item.WBS_Code_Lookup__c != null
                ){
                    filledLineItems.add( item );
                } else {
                    emptyLineItems.add( item );
                }
            }
        }
        
        delete emptyLineItems;
        this.allocationLineItems = filledLineItems;
    }  */
    
     /** 
    * @Author ADMD Team
    * @date 08/03/2013
    * @description getMatchingFundingAllocationLineItem method - returns FALI to remove 
    */  
  /*  private GFRS_Copay_Funding_Allocation_Line_Item__c getMatchingFundingAllocationLineItem( id targetId ){
        if( targetId == null ){
            System.debug( 'indexToModify[' + this.indexToModify + '] could not be found');
            return(null);
        }
        
        GFRS_Copay_Funding_Allocation_Line_Item__c removed;
        for( Integer i = 0; i < this.allocationLineItems.size(); i++ ){
            removed = this.allocationLineItems[i];
            if(removed.id == this.indexToModify ){
                //-- remove this one
                this.allocationLineItems.remove(i);
                return( removed );
            }
        }
        return( null );
    }  */
    
     /** 
    * @Author ADMD Team
    * @date 29/03/2013
    * @description validateRefundData method - check are whole refund data is valid.
    */ 
  /*  private boolean validateRefundData()
    {
        Boolean retVal       = true;
        Boolean isAmountUsed = true;
        Decimal sumOfPercent = 0.0;
        Decimal sumOfAmount  = 0.0;

        if(this.allocation.Refund_Amount__c <=0)
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_AMT_GRT) );
            retVal = false;
        }
        else if(this.allocation.Refund_Due__c <=0)
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REFDUE_GRT) );
            retVal = false;
        }
        //check FALI
        Set<String> costCentersIds = new Set<String>();
        Set<String> wbsCodesIds    = new Set<String>();
        
        for( gFRS_Funding_Allocation_Line_Item__c lineItem : this.allocationLineItems ){
            costCentersIds.add(lineItem.Cost_Center_Lookup__c); 
            wbsCodesIds.add(lineItem.WBS_Code_Lookup__c);   
        }
        
        Map<Id,GFRS_Cost_Center_Code__c> costCentersMap = gFRS_Util.getCostCentersMapByIds(costCentersIds);
        Map<Id,GFRS_WBS_Codes__c> wbsCodesMap           = gFRS_Util.getWbsCodesMapByIds(wbsCodesIds);
        Set<String> sapCompanyCodeFLI                   = new Set<String>();
        
        for( gFRS_Funding_Allocation_Line_Item__c li : this.allocationLineItems )
        {
            system.debug('li.Cost_Center_Lookup__c->' + li.Cost_Center_Lookup__c);
            system.debug('li.WBS_Code_Lookup__c->' + li.WBS_Code_Lookup__c);
            system.debug('li.Percent__c->' + li.Percent__c);
            system.debug('li.Amount__c->' + li.Amount__c);
            
            
            if(li.Cost_Center_Lookup__c==null )
            {
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_COST_CENTER_NULL) );
                retVal = false;
                break;
            }    
            else if(li.WBS_Code_Lookup__c==null)
            {
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_WBS_NULL) );
                retVal = false;
                break;
            }
            else if(li.Percent__c==null && li.Amount__c==null)
            {
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_AMT_PER_NULL) );
                retVal = false;
                break;
            }
            else if(li.Percent__c!=null && li.Amount__c==null)
            {
                isAmountUsed=false;
                if(li.Percent__c<0 || li.Percent__c>100)
                {
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_SUM_PER ) );
                retVal = false;
                break;
                }
                sumOfPercent += li.Percent__c;   
            }
            else if(li.Amount__c!=null && li.Percent__c==null)
            {
                isAmountUsed=true;
                if(li.Amount__c<=0 )
                {
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_SUM_AMT ) );
                retVal = false;
                break;
                }
                sumOfAmount +=li.Amount__c; 
            }
            
           if(li.Cost_Center_Lookup__c != null && li.WBS_Code_Lookup__c != null){
     
                if(costCentersMap.get(li.Cost_Center_Lookup__c).SAP_Company_Code__c != wbsCodesMap.get(li.WBS_Code_Lookup__c).SAP_Company_Code__c){
                    ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_SAP_CC) );
                    retVal = false;
                    break;  
                }
               
               sapCompanyCodeFLI.add(costCentersMap.get(li.Cost_Center_Lookup__c).SAP_Company_Code__c);                   
               //GFRS-287 splits need to have the same cost center sap company codes
               if(sapCompanyCodeFLI.size()>1){
                   
                   //FLI have cost centers with different sap company codes payment will fail block user for savig such allocations
                   ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_FLI_Diff_Cost_Center_Company_Code ) );
                   retVal = false;
                   break; 
               }
            }
            
        }
        
        //validate sum of precent
        
        if( (sumOfPercent > 100 ||  sumOfPercent < 100) && isAmountUsed==false)
        {
             ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.label.gFRS_ERROR_SUM_PER) );
             retVal = false;   
        }      
        
        //validate sum of amount
        if((sumOfAmount>this.allocation.Refund_Due__c) && isAmountUsed==true)
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_AMT_GRT_REFDUE) );
            retVal = false;      
        }
        
        if((sumofAmount<>this.allocation.Refund_Amount__c) && isAmountUsed==true)
        {
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_SUMAMT_NOT_EQ_REFAMT) );
            retVal = false;  
        } 
        
        if( !gFRS_Util_NoShare.validatePercentageOfLineItems(this.allocationLineItems)){
          ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_PaymentPercentageErrorPlainText));
          retVal = false;
        }
        
        
        
        return retVal;
    }  */
    
    private Boolean validateCoverageOfPayments(){

      if( !gFRS_Util_NoShareCopay.validateCoverageOfPayment(new List<GFRS_Copay_Funding_Allocation__c>{this.allocation})){
          ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, System.Label.gFRS_PaymentPercentageErrorPlainText));
          return false;
        }else{
          return true;
        }
    }
    
     /** 
    * @Author ADMD Team
    * @date 03/04/2013
    * @description saveRefundsData() method - saves funding allocation and allocation line items
    */ 
 /*   private void saveRefundsData()
    {
       system.debug('update refund allocation');
       gFRS_Util_NoShare.saveLockedFundingAllocation(this.allocation);
       system.debug('update refund allocation->ok;');
       system.debug('save refund allocation line items');
       gFRS_Util_NoShare.saveLockedAllocationLIs(this.allocationLineItems);
       system.debug('save refund allocation line items->ok');
    }  */
    
    /** 
    * @Author ADMD Team
    * @date 04/08/2013
    * @description canSubmitFundingAllocationRefund() method - checks was Refund submitted before, is in status processing or is hanging during processing.
    */ 
 /*   private Boolean canSubmitFundingAllocationRefund()
    {
        List<gFRS_Payment_History__c> listPaymentHistory=null;
        Boolean retVal = true;
        listPaymentHistory = [select Id from gFRS_Payment_History__c where Payment_Type__c = 'Refund' and Funding_Allocation__c=:allocation.id and Status__c in('Success','Processing','Submitted') and Grant__c =: myFundingReq.id];

        if (listPaymentHistory.size()>0)
        {
            System.debug(System.Label.gFRS_MSG_NO_CREATE_REF_INIT);
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_MSG_NO_CREATE_REF_INIT ));
            retVal = false;
        }
        
        return retVal;
    }  */
    
      /** 
    * @Author ADMD Team
    * @date 04/08/2013
    * @description createActivePaymentHistoryRefund method - creates refund history record.
    */ 
  /*  private Boolean createActivePaymentHistoryRefund()
    {  
        boolean retVal = true;
        
        try
        {
           //increment the call counter 
           this.myFundingReq.Payment_Call_Counter__c += 1;
           update (new GFRS_Funding_Request__c(Id = this.myFundingReq.Id, Payment_Call_Counter__c = this.myFundingReq.Payment_Call_Counter__c ));
           
           //get read only record type. inherited from Payment.
           RecordType RT_PAY_HISTORY_READONLY = [ SELECT id from RecordType where DeveloperName = 'ReadOnly' and SobjectType = 'GFRS_Payment_History__c' ];
            
           //create sap ID  
           string sapRequestId                                 = myFundingReq.Name + '_' + myFundingReq.Payment_Call_Counter__c;
           this.activePaymentHistory                           = new GFRS_Payment_History__c(Grant__c=this.myFundingReq.id,Funding_Allocation__c=allocation.id);
           this.activePaymentHistory.SAP_Request_ID__c         = sapRequestId;
           this.activePaymentHistory.Date__c                   = date.today();
           this.activePaymentHistory.Action__c                 = 'Refund Request';
           this.activePaymentHistory.RecordTypeId              = RT_PAY_HISTORY_READONLY.id;
           this.activePaymentHistory.Status__c                 = 'Initialized';
           this.activePaymentHistory.InvokeType__c             = 'UI';
           this.activePaymentHistory.Type_of_Check_Received__c = this.allocation.Type_of_Check_Received__c;
           this.activePaymentHistory.Payment_Type__c           = 'Refund';
           this.activePaymentHistory.Check_Number__c           = this.allocation.Check_Number__c;
           this.activePaymentHistory.Amount__c                 = this.allocation.Refund_Amount__c;
           insert this.activePaymentHistory;
        } 
        catch (Exception ex )
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR,  gFRS_Util.getPrettyMessage(ex)));
            retVal = false;
        }
        
        return retVal;
    }  */
    
    
      /** 
    * @Author ADMD Team
    * @date 04/08/2013
    * @description handleSubmitRefundResponse method - parse ESB/SAP refund respond.
    */ 
  /*  private void handleSubmitRefundResponse(gFRS_SubmitGrantSAP.submitGrantResponse_element response, String sapRequestId)
    {
         try
         {
            String errMsg = null;
            String status = response.status;
            if( status != null ) status = status.toLowerCase();
             
            if(status == 'successful')
            {
                this.activePaymentHistory.ESB_Error__c = response.message;
                this.activePaymentHistory.Status__c    ='Submitted';
                update this.activePaymentHistory;
                
                if( this.myFundingReq.Refunded_Amount__c == null ) this.myFundingReq.Refunded_Amount__c = 0;
                
                System.debug('this.myFundingReq.Refunded_Amount__c ->' + this.myFundingReq.Refunded_Amount__c);
                System.debug('this.allocation.Refund_Amount__c ->' + this.allocation.Refund_Amount__c);
            }
            else
            {   
                gFRS_XmlErrorMessageReader errorReader = new gFRS_XmlErrorMessageReader();
                
                XmlStreamReader reader = new XmlStreamReader(gFRS_Util.prepareXmlMessageToParse(response.message));
                gFRS_XmlErrorMessageReader.Error[] errors = errorReader.parseErrors(reader);
                System.debug( 'web service returned errors:' + errors );
                
                for(gFRS_XmlErrorMessageReader.Error error : errors){
                    errMsg = error.getMessage();
                    System.debug( 'fullError:' + errMsg );
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error: ' + errMsg ));
                }
                this.activePaymentHistory.ESB_Error__c = response.message;
                this.activePaymentHistory.Status__c    ='Error';
                //update this.activePaymentHistory;
            }
         }
         catch (Exception ex )
         {
            String errMsg = gFRS_Util.getPrettyMessage(ex);
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
         }
     }  */
     
   /*  private gFRS_SubmitGrantSAP.Split_element[] getGrantRefundSplitLines()
     {
        //-- find the split line that matches the WBS code
        GFRS_Funding_Allocation_Line_Item__c matchingSplit = null;
        Set<String> attemptedWBS                           = new Set<String>();
        String fundingType                                 = gFRS_Util.convertFundingTypeSAP(this.myFundingReq.Record_Type_Name__c );
        
        gFRS_SubmitGrantSAP.Split_element[] sapSplitLines = new List<gFRS_SubmitGrantSAP.Split_element>(); 
        
        Double refundLineAmount = 0;
        
        for(GFRS_Funding_Allocation_Line_Item__c li : this.allocationLineItems)
        {    
            refundLineAmount = li.Line_Item_Total__c;
            
            gFRS_SubmitGrantSAP.Split_element sapline = new gFRS_SubmitGrantSAP.Split_element();
            sapline.glAccountCode                     = String.valueOf(this.allocation.GL_Account__c);
            sapline.splitAmount                       =  String.valueOf(refundLineAmount);
            sapline.costCenter                        = String.valueOf(li.Cost_Center__c);
            sapline.wbsCode                           = String.valueOf(li.WBS__c);
            sapline.fundingType                       = fundingType;
            sapSplitLines.add(sapline);    
        }
        
        return sapSplitLines;
    }  */
    
    
    /** 
    * @Author ADMD Team
    * @date 05/07/2013
    * @description getLineItemsForGivenFundingAllocation method - getter for gFRS Funding Allocations.
    */
    private List<GFRS_Copay_Funding_Allocation_Line_Item__c> getLineItemsForGivenFundingAllocation(GFRS_Copay_Funding_Allocation__c fundingAllocation){

        return [
            select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Funding_Allocation__c, Amount__c, Biogen_Idec_WBS_Logos__c, Cost_Center_Description__c, Cost_Center_Lookup__c, Accountable_Employee__c, Cost_Center__c, Grant_Request__c, Line_Item_Total__c, Percent__c, Request_Name__c, WBS_Code_Lookup__c, WBS_Description__c, WBS__c,  GL_Account_Code__c,Cost_Center_Lookup__r.SAP_Company_Code__c, Funding_Record_Type__c 
            from GFRS_Copay_Funding_Allocation_Line_Item__c
            where Funding_Allocation__c = : fundingAllocation.id AND isDeleted = false
        ];
        
        
    }
    
    /** 
    * @Author ADMD Team
    * @date 05/07/2013
    * @description getLineItemDetails method - getter for gFRS Funding Allocations.
    */
 /*   private List<GFRS_Copay_Funding_Allocation_Line_Item__c> getLineItemDetails(GFRS_Copay_Funding_Allocation_Line_Item__c fundingAllocationLineItem){

        return [
            select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Funding_Allocation__c, Amount__c, Biogen_Idec_WBS_Logos__c, Cost_Center_Description__c, Cost_Center_Lookup__c, Accountable_Employee__c, Cost_Center__c, Grant_Request__c, Line_Item_Total__c, Percent__c, Request_Name__c, WBS_Code_Lookup__c, WBS_Description__c, WBS__c,  GL_Account_Code__c,Cost_Center_Lookup__r.SAP_Company_Code__c, Funding_Record_Type__c 
            from GFRS_Copay_Funding_Allocation_Line_Item__c
            where Id = : fundingAllocationLineItem.Id AND isDeleted = false
        ];
        
        
    }  */
    
    class CustomException extends Exception {}
}