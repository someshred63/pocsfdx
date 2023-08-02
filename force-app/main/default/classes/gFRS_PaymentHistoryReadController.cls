/**
 *  Controller that handles the READ view of the Payment History.
 *  <p>This allows the custom buttons to make apex calls (through actionFunctions)</p>
 **/
public with sharing class gFRS_PaymentHistoryReadController {
    
    GFRS_Payment_History__c paymentHistory;
    public GFRS_Funding_Request__c fundReq {get; set;}
    public GFRS_Funding_Allocation__c allocation;
    
    /** READONLY payment history record type **/
    private RecordType RT_PAY_HISTORY_READONLY;
    
    public String userProfileName {get; set;}
    public Boolean isLineItemEditable {get; set;}
    
    public gFRS_PaymentHistoryReadController( ApexPages.Standardcontroller std )
    {
        paymentHistory = (GFRS_Payment_History__c) std.getRecord();
        
        if( this.paymentHistory == null || this.paymentHistory.id == null )
        {
            ApexPages.addMessages( new CustomException( 'Payment history was not sent' ));
            return;
        }
        
         try
         {
            this.paymentHistory = [
                select Amount__c, Cost_Center__c, Cost_Center__r.Cost_Center__c, Cost_Center__r.SAP_Company_Code__c, Funding_Allocation__c, Grant__c, Id, Integration_Id__c, Payment_Type__c, SAP_Doc_ID__c, SAP_Request_ID__c, WBS_Code__c, WBS_Code__r.WBS__c
                from GFRS_Payment_History__c where id = :this.paymentHistory.id limit 1];
            
            this.fundReq = [
                select Id, Organization__r.Id, Request_AutoNumber__c, Refund_Due__c, GL_Account_Code__c, Payment_Email_Notification__c, LOA_Signed__c, Location__r.Vendor_Id__c,Refunded_Amount__c, Approved_Amount__c, Total_Amount_Used__c, Event_Program_Title__c, Requested_Amount__c, Record_Type_Name__c, Delivery_Method__c, Unix_ID__c, Building__c, Send_By_FedEx_cost_center_will_be_charg__c, Attention_To__c, Name, Payment_Call_Counter__c
                from GFRS_Funding_Request__c where id = :this.paymentHistory.Grant__c limit 1];
            
            if( this.fundReq.Payment_Call_Counter__c == null ) this.fundReq.Payment_Call_Counter__c = 0;
            if(this.paymentHistory.Funding_Allocation__c != null){
        		this.allocation = [SELECT Id FROM GFRS_Funding_Allocation__c WHERE Id = :this.paymentHistory.Funding_Allocation__c];
            }else{
            	this.allocation =null;
            }	
            
         }
         catch( Exception err )
         {
         	
	            System.debug( 'unable to load funding request info:' + err.getMessage() );
	            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the funding request' ));
	            return;
         	
         }
        
        RT_PAY_HISTORY_READONLY = [ SELECT id from RecordType 
            where DeveloperName = :gFRS_Util.RT_PAYHISTORY_READONLY and SobjectType = 'GFRS_Payment_History__c' ];
           
       userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;
        if( userProfileName == gFRS_Util.PROFILE_NAME_GFRS_ADMIN || userProfileName == gFRS_Util.PROFILE_NAME_SYS_ADMIN || userProfileName == gFRS_Util.PROFILE_NAME_SUPER_USER){
    		this.isLineItemEditable = true;	
        }else{
    		this.isLineItemEditable = !gFRS_Util_NoShare.checkIsPaymentSuccesfullySubmitted(this.allocation);	
        }

     }
       
    class CustomException extends Exception {}
}