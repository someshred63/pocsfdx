public class gFRS_CAF_PDF_VendorDetailsController {
public gFRS_CAF_PDF_VendorDetailsController(final ApexPages.StandardController std) { }
    @InvocableMethod(label='Vendor PDF')
    public static void fromGenerateVendorPDF(List<String> reqId) {
      if(!System.isFuture() && !System.isBatch()){
        fromGenerateVendorPDF1(reqId.get(0));
      }
    }
    @future(callout=true)
        public static void fromGenerateVendorPDF1(Id reqId) {
        PageReference pdfPage = new PageReference('/apex/gFRS_CAF_VendorDetailsPDF?Id='+reqId);
        Blob pdfContent;
        pdfPage.setRedirect(true);
     //   pdfPage.getParameters().put('Id',reqId);
       pdfContent = pdfPage.getContentAsPDF();
        
        gFRS_Ltng_CAF_Application__c gfrsapp=[SELECT Id,name,Vendor_PDF_Call_Counter__c,Vendor_PDF_Id__c FROM gFRS_Ltng_CAF_Application__c WHERE Id=:reqId LIMIT 1];
     System.debug('-Inside before-'+gfrsApp.Vendor_PDF_Call_Counter__c);    
    if(gfrsApp.Vendor_PDF_Call_Counter__c==null){
            System.debug('-Inside-'+gfrsApp.Vendor_PDF_Call_Counter__c);
            gfrsApp.Vendor_PDF_Call_Counter__c=0;
        }
        gfrsApp.Vendor_PDF_Call_Counter__c =  gfrsApp.Vendor_PDF_Call_Counter__c+1;
        System.debug('-counter->'+gfrsApp.Vendor_PDF_Call_Counter__c);
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'Vendor Details '+gfrsApp.name+'_V'+gfrsApp.Vendor_PDF_Call_Counter__c+'.pdf';//File name with extention
        
        cVersion.Title = 'Vendor Details '+gfrsApp.name+'_V'+gfrsApp.Vendor_PDF_Call_Counter__c+'.pdf';//Name of the file
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
        
        gfrsApp.Vendor_PDF_Id__c=conDocument;
        update gfrsApp;
    }
}