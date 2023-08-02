public class gFRS_ReleaseIBlockController{

    public List<GFRS_Payment_History__c> PaymentRecs {get; set;}
    public map<string,GFRS_Payment_History__c> PaymentRecsMap;
    public GFRS_Payment_History__c paymentRec;
    public string currentRefId {get; set;}    
    public List<string> requests {get; set;} 

    public gFRS_ReleaseIBlockController(){
        PaymentRecsMap = new map<string,GFRS_Payment_History__c>();
        requests = new List<string>();      
        gFRS_Release_I_Block__c customSettingFields = gFRS_Release_I_Block__c.getOrgDefaults();
        if(String.isNotBlank(customSettingFields.Value__c)){
                requests = customSettingFields.Value__c.split(';');  
        }
        if(requests.size() > 0){
            PaymentRecs = [Select Id, Name, Funding_Allocation__c, Funding_Allocation__r.Approved_Fiscal_Year__c, Status__c, Payment_Block__c, Grant__c, Grant__r.name,Grant__r.Funding_Type__c,Grant__r.Organization__r.Organization_Name__c, SAP_Doc_ID__c, SAP_Request_ID__c,Date__c FROM GFRS_Payment_History__c WHERE  Grant__r.LOA_Signed__c = 'Yes' and Payment_Block__c = 'I' and SAP_Doc_ID__c != '' and I_Block_Released__c = false and Status__c = 'Success' and Grant__r.name NOT IN : requests];
        }
        else {
            PaymentRecs = [Select Id, Name, Funding_Allocation__c, Funding_Allocation__r.Approved_Fiscal_Year__c, Status__c, Payment_Block__c, Grant__c, Grant__r.name,Grant__r.Funding_Type__c,Grant__r.Organization__r.Organization_Name__c, SAP_Doc_ID__c, SAP_Request_ID__c,Date__c FROM GFRS_Payment_History__c WHERE  Grant__r.LOA_Signed__c = 'Yes' and Payment_Block__c = 'I' and SAP_Doc_ID__c != '' and I_Block_Released__c = false and Status__c = 'Success'];
        }
        for(GFRS_Payment_History__c rec : PaymentRecs){
            PaymentRecsMap.put(rec.SAP_Request_ID__c, rec);
        }        
    }
    
    public ApexPages.PageReference releaseIBlock(){

        if(currentRefId == null || currentRefId == ''){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Record not selected. Please select a record.' ));
            return null;
        }

        paymentRec = PaymentRecsMap.get(this.currentRefId);
        String fiscalYear = String.valueOf( paymentRec.Date__c.year() );
        
        gFRS_ReleaseInvoiceBlockWS.GneCOMM_Grants_SFDC_O_1Port0 sapReleaseInvoice = new gFRS_ReleaseInvoiceBlockWS.GneCOMM_Grants_SFDC_O_1Port0();
        sapReleaseInvoice.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
        gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element response =  sapReleaseInvoice.releaseInvoiceBlock(paymentRec.SAP_Doc_ID__c, fiscalYear); 
        
        if( response.status != 'successful'){
            System.debug( 'message was sent' );
            gFRS_XmlErrorMessageReader errorReader = new gFRS_XmlErrorMessageReader();

            XmlStreamReader reader = new XmlStreamReader(gFRS_Util.prepareXmlMessageToParse(response.message));
            gFRS_XmlErrorMessageReader.Error[] errors = errorReader.parseErrors(reader);
            for(gFRS_XmlErrorMessageReader.Error error : errors){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, error.getMessage() ));
            }
            return null;
         }    
         paymentRec.I_Block_Released__c = true;
         update paymentRec;
        
        return( new ApexPages.PageReference( '/apex/gFRS_Release_IBlock').setRedirect(true));
    }

}