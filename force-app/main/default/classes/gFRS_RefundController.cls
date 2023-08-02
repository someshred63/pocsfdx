public with sharing class gFRS_RefundController {
    
    public static final String CONTENT_TYPE = 'Reconciliation';
    public static final String PATH_HOME    = '/apex/gFRS_Home';
    
    public Map<String,String> contentItems     { get; set; }    
    public GFRS_Funding_Request__c request     { get; set; }
    public GFRS_Program__c lastProgram         { get; set; }
    public Boolean isEditable                  { get; set; }    
    public String reconciliationInstructions   { get{ return( this.contentItems.get('Reconciliation instructions')); }}
    public String reconciliationMailingAddress { get{ return( this.contentItems.get('Reconciliation mailing address')); }}
    public String  refundDate                  { get; set; }
    
    public String[] topFieldSet {
        get {
    		return( new String[]{ 
                'Grant_Only_Used_for_Activity_Detailed__c',
                'Reason_Funds_Not_Used_as_Intended__c',
                'Total_Amount_Used__c',
                'Program_Changes_if_any__c',
                'Description_of_How_the_Funds_were_Used__c' } );
        }
    }
    
    public gFRS_RefundController( ApexPages.StandardController std ){
        request      = (GFRS_Funding_Request__c)std.getRecord();
        contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( CONTENT_TYPE, UserInfo.getLanguage() );
        refreshRequest();
        isEditable   = false;
    }
    /**
     *  Refresh the request (to update formula field values)
     *  <p>POST-CONDITION: this.request is refreshed</p>
     **/
    private void refreshRequest(){
        try {
    		this.request = [SELECT 
                    Id,
                    Name, Event_Program_Title__c,
                    Approved_Amount__c,
                    Total_Amount_Used__c,
                    Refund_Due__c,
                    Refund_Request_Date__c,
                    Description_of_How_the_Funds_were_Used__c,
                    Refunded_Amount__c ,
                    Grant_Only_Used_for_Activity_Detailed__c,
                    Reason_Funds_Not_Used_as_Intended__c,
                    Program_Changes_if_any__c
                    
                FROM GFRS_Funding_Request__c
                WHERE Id = :this.request.id
               ];
            this.refundDate = '';
            if(request != null && request.Refund_Request_Date__c != null){
                 this.refundDate = request.Refund_Request_Date__c.format();
            }
            if( this.request.Approved_Amount__c == null){
                ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Approved Amount not found' ));
                return;
            }
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find funding request' ));
            return;
        }

        try {
            this.lastProgram = [
                SELECT End_Date__c
                FROM GFRS_Program__c
                WHERE Funding_Request__c = :this.request.id
                ORDER BY End_Date__c DESC
                LIMIT 1
               ];
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find funding request program' ));
            return;
        }
    }

    
    public ApexPages.Pagereference closePage(){
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_HOME, null, null ) ));  
    }
}