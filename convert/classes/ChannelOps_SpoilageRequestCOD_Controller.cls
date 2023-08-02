/**********************************************************************
Purpose: ChannelOps_SpoilageRequestCOD_Controller class is used to save 
         the signed COD form site.
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      Vijay       09/19/2019      INITIAL DEVELOPMENT
***********************************************************************/
public class ChannelOps_SpoilageRequestCOD_Controller {
    
    public String sapQuatationId {get;set;}
    public String requestNumber {get;set;}
    public ChannelOps_Spoilage_Request_COD__c spoilageRequestCOD {get;set;}
    public String subTitle {get;set;}
    public String errorMsg {get;set;}
    public List<ChannelOps_Spoilage_Request_Product__c> spoilageRequestProducts {get;set;} 
    public String otherTitleDisplayAttribut {get;set;}    
    private ChannelOps_GoogleCaptchaHandler googleCaptchHandler;
    public String publicKey {get;set;}
    public Boolean verified {get; private set;}
    public String captchaResponse {get;set;}
    public String otherCredential {get;set;}
    public String tittle {get;set;}
    public String hcpName {get;set;}

    public ChannelOps_SpoilageRequestCOD_Controller(){
        ChannelOps_App_Property__c property = [SELECT Id, CS_subTitle__c, GSKey__c, GSite__c, GCKey__c FROM ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
        subTitle =property.CS_subTitle__c;
        publicKey =property.GCKey__c;
        spoilageRequestCOD = new ChannelOps_Spoilage_Request_COD__c();
        errorMsg = '';
        synchOtherTitleFields();
        googleCaptchHandler = new ChannelOps_GoogleCaptchaHandler(property.GCKey__c, property.GSKey__c, property.GSite__c);
        this.verified = false;
        captchaResponse = '';       
    }
    
    /*public void init(){
        String spoilageRequestCODId = Apexpages.currentPage().getParameters().get('id');
        if(String.isNotBlank(spoilageRequestCODId)){
            List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = fetchSpoilageRequestCODById(spoilageRequestCODId);
            if(spoilageRequestCODList != null && !spoilageRequestCODList.isEmpty()){
                spoilageRequestProducts = fetchSpoilageRequestProducts(spoilageRequestCODList[0].ChannelOps_Spoilage_Request__c);
                spoilageRequestCOD = spoilageRequestCODList[0];              
            }
        }        
    }*/
    
    
    public PageReference searchCOD(){
        PageReference spoilageReqCODFormPage = null;
        errorMsg = '';
        if(validateSearchParams()){
            List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = fetchSpoilageRequestCOD(requestNumber,sapQuatationId);
            if(spoilageRequestCODList != null && !spoilageRequestCODList.isEmpty()){
                if(spoilageRequestCODList[0].ChannelOps_Spoilage_Request__r.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_WAITING_FOR_COD){
                   errorMsg = 'Spoilage request '+ spoilageRequestCODList[0].ChannelOps_Spoilage_Request__r.Name + ' is being processed '+   
                              'and not available for COD. If you have questions, please contact Genentech Customer Service at 800-551-2231.';
                }else{
                    spoilageRequestProducts = fetchSpoilageRequestProducts(spoilageRequestCODList[0].ChannelOps_Spoilage_Request__c);
                    spoilageRequestCOD = spoilageRequestCODList[0];  
                    otherCredential=spoilageRequestCODList[0].Other_Credential__c;
                    tittle=spoilageRequestCODList[0].Title__c;
                    hcpName=spoilageRequestCODList[0].HCP_Name__c;
                    spoilageReqCODFormPage = Page.ChannelOps_SpoilageRequest_CODForm;
                    spoilageReqCODFormPage.setRedirect(false);
                    errorMsg ='';
                }              
            }else{
               errorMsg = ChannelOps_Constants.NO_SPOILAGE_REQ_COD_FOUND;  
            }            
        }        
        return spoilageReqCODFormPage;
    }
    
    private Boolean validateSearchParams(){
        Boolean isValid = true;
        if(String.isBlank(sapQuatationId)){
            errorMsg += 'Please enter valid SAP Quotation Id';
            isValid = false;
        } 
        if(String.isBlank(requestNumber)){
            if(String.isNotBlank(errorMsg)){
               errorMsg += '<br/>';
            }
            errorMsg += 'Please enter request number';
            isValid = false;
        }        
        return isValid;
    }
    
    private List<ChannelOps_Spoilage_Request_Product__c> fetchSpoilageRequestProducts(Id spoilageRequestId){
		List<ChannelOps_Spoilage_Request_Product__c> spoilageRequestProductList = new List<ChannelOps_Spoilage_Request_Product__c>();        
        if(spoilageRequestId != null){
        	spoilageRequestProductList = [SELECT Id, brand__c,Indication__c,Lot_Number__c,MayEdit,Name,NDC__c,
                                          		 Other_Indication__c,Product_Name__c,Product__c,Quantity__c,Serial_Number__c,
                                          		 Spoilage_Request__c 
                                          FROM	 ChannelOps_Spoilage_Request_Product__c
                                          WHERE	 Spoilage_Request__c =: spoilageRequestId];
        }
        return spoilageRequestProductList;        
    }
    
    
    
    private List<ChannelOps_Spoilage_Request_COD__c> fetchSpoilageRequestCOD(String requestNumber, String sapQuotationId){
		List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = null;
        if(String.isNotBlank(requestNumber) && String.isNotBlank(sapQuotationId)){
            spoilageRequestCODList = [SELECT Id, ChannelOps_Spoilage_Request__c, ChannelOps_Spoilage_Request__r.Id, ChannelOps_Spoilage_Request__r.Name, 
                							ChannelOps_Spoilage_Request__r.Status__c, ChannelOps_Spoilage_Request__r.Submission_Date__c,
                                            City__c,Contact_Email__c,Contact_Name__c,Contact_Phone__c,Credentials__c,
                							DEA__c,HCP_Name__c,Name,Other_Credential__c,Quotation_Document_Date__c,
                							Quotation_Request_Date__c,SAP_Quotation_End_Date__c,SAP_Quotation_ID__c,
                							SAP_Ship_To_ID__c,Ship_To_Name__c,State_License__c,State__c,
                							Street_Address2__c,Street_Address__c,Title__c,Zip_Code__c, Facility_Name__c 
                					  FROM	ChannelOps_Spoilage_Request_COD__c
                                      WHERE ChannelOps_Spoilage_Request__r.Name =:requestNumber.trim() AND SAP_Quotation_ID__c=: sapQuotationId.trim()]; 
        }
        return spoilageRequestCODList;
    }
    
    private List<ChannelOps_Spoilage_Request_COD__c> fetchSpoilageRequestCODById(String spoilageRequestCODId){
		List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = null;
        if(String.isNotBlank(spoilageRequestCODId)){
            spoilageRequestCODList = [SELECT Id, ChannelOps_Spoilage_Request__c, ChannelOps_Spoilage_Request__r.Id, ChannelOps_Spoilage_Request__r.Name, 
                							ChannelOps_Spoilage_Request__r.Status__c, ChannelOps_Spoilage_Request__r.Submission_Date__c,
                                            City__c,Contact_Email__c,Contact_Name__c,Contact_Phone__c,Credentials__c,
                							DEA__c,HCP_Name__c,Name,Other_Credential__c,Quotation_Document_Date__c,
                							Quotation_Request_Date__c,SAP_Quotation_End_Date__c,SAP_Quotation_ID__c,
                							SAP_Ship_To_ID__c,Ship_To_Name__c,State_License__c,State__c,
                							Street_Address2__c,Street_Address__c,Title__c,Zip_Code__c,Facility_Name__c 
                					  FROM	ChannelOps_Spoilage_Request_COD__c
                                      WHERE Id =: spoilageRequestCODId]; 
        }
        return spoilageRequestCODList;
    }
    
    public PageReference saveCOD(){
        PageReference codHiddenPage = null;
        errorMsg = '';
        try{
            System.debug('captchaResponse----------'+captchaResponse);
            System.debug('verified----------'+verified);
            synchOtherTitleFields();
            if(!this.verified){
                if(googleCaptchHandler.verifyCaptcha(captchaResponse)){
                    this.verified = true;
                }else{
                    errorMsg ='Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';
                    this.verified = false;
                }
                
            }
            if(this.verified && validateSignature()){
                spoilageRequestCOD.Other_Credential__c = otherCredential;
                spoilageRequestCOD.Title__c =tittle;
                spoilageRequestCOD.HCP_Name__c=hcpName;
            	update spoilageRequestCOD;
                ChannelOps_Spoilage_Request__c spoilageRequest = spoilageRequestCOD.ChannelOps_Spoilage_Request__r;
                System.debug('-----------'+ spoilageRequest);
                update spoilageRequestProducts;
                spoilageRequest.Status__c = ChannelOps_Constants.SPOILAGE_STATUS_SIGNED_COD_AWAITING_REVIEW;                
                update spoilageRequest;
                codHiddenPage = Page.ChannelOps_COD_HiddenPage;
               	codHiddenPage.getParameters().put('id',spoilageRequestCOD.Id);
                codHiddenPage.setRedirect(true);
            }
        }catch(Exception e){
            System.debug(Logginglevel.ERROR, e.getMessage());
            errorMsg = 'There was some error occurred while submission. Please contact to System Administrator';
        }
        return codHiddenPage;
    }
    
    public PageReference cancel(){
        PageReference spoilageRequestCODSearchPage = Page.ChannelOps_SpoilageRequest_CODSearch;
        spoilageRequestCODSearchPage.setRedirect(true);
        return spoilageRequestCODSearchPage;
    }
    
    private Boolean validateSignature(){
        Boolean isValid = true;
    	errorMsg = '';     
       
        if(String.isBlank(hcpName)) {
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg +='Error: Name in the Terms & Conditions section is required';
            isValid = false;
        }        
        if(String.isBlank(tittle)) {
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: Title in the Terms & Conditions section is required';
            isValid = false;
        }
        if(String.isBlank(spoilageRequestCOD.Credentials__c)) {
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: Credentials in the Terms & Conditions section is required';
            isValid = false;
        }
        if(String.isNotBlank(spoilageRequestCOD.Credentials__c) && spoilageRequestCOD.Credentials__c.contains('Other') &&  String.isBlank(otherCredential)) {
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: Other credentials in the Terms & Conditions section is required';
            isValid = false;
        }
        return isValid;
    }
    
    //make sure other title display attribut matches title selection
    private void synchOtherTitleFields(){
        if(spoilageRequestCOD != null && String.isNotBlank(spoilageRequestCOD.Credentials__c) && spoilageRequestCOD.Credentials__c.containsIgnoreCase('Other')){
            otherTitleDisplayAttribut ='block';
        }else {
            otherTitleDisplayAttribut = 'none';
           // spoilageRequestCOD.Other_Credential__c ='';
            otherCredential='';
        }
    }
    
    public PageReference viewSignedCODFormPDF(){
         string encryptedRecordId=GCS_Util.encryptData(spoilageRequestCOD.id,GCS_Util.getCryptoKey());
     	 PageReference signedCODFormPDF = Page.ChannelOps_CODForm_PDF;
         signedCODFormPDF.getParameters().put('id',encryptedRecordId);
         signedCODFormPDF.setRedirect(true);
         return signedCODFormPDF;   
    }
    
    public PageReference initConfirmationPage(){
        PageReference curPage = ApexPages.currentPage();       
           if(curPage.getParameters()!=null) {
                String spoilageRequestCODId =GCS_Util.decryptData(Apexpages.currentPage().getParameters().get('id'),GCS_Util.getCryptoKey());
                if(String.isNotBlank(spoilageRequestCODId)){
                    List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = fetchSpoilageRequestCODById(spoilageRequestCODId);
                    if(spoilageRequestCODList != null && !spoilageRequestCODList.isEmpty()){
                        spoilageRequestCOD = spoilageRequestCODList[0];              
                    }
                }    
           }
        return null;
    }
    
    public PageReference initHiddenPage(){
        PageReference curPage = ApexPages.currentPage();       
           if(curPage.getParameters()!=null) {
                String codId=curPage.getParameters().get('id');
               List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = fetchSpoilageRequestCODById(codId);
               
               if(spoilageRequestCODList != null && !spoilageRequestCODList.isEmpty()){
                   spoilageRequestCOD = spoilageRequestCODList[0];              
               }
               Id attachmentId = saveSignedCODFormPDF();
                //send COD confirmation email 
                sendCODConfirmationEmail(attachmentId, spoilageRequestCOD.Id, ChannelOps_Constants.CHANNELOPS_SPOILAGE_CODE_CONF_EMAIL_TEMPLATE);
           }
        string encryptedRecordId=GCS_Util.encryptData(spoilageRequestCOD.id,GCS_Util.getCryptoKey());
        PageReference nextPage = Page.ChannelOps_CODForm_Confirmation;
        nextPage.getParameters().put('id',encryptedRecordId);
        nextPage.setRedirect(true);     
        return nextPage;
    }
    
    private Id saveSignedCODFormPDF(){
        string encryptedRecordId=GCS_Util.encryptData(spoilageRequestCOD.id,GCS_Util.getCryptoKey());
		PageReference signedCODFormPDF = Page.ChannelOps_CODForm_PDF; 
        signedCODFormPDF.getParameters().put('id',encryptedRecordId);     
        Attachment attach = new Attachment();
        // the contents of the attachment from the pdf
        Blob body;
        try {
            // returns the output of the page as a PDF
            body = signedCODFormPDF.getContentasPDF();
            system.debug('body:---------------'+body);
        } catch (VisualforceException e) {
            body = Blob.valueOf('Unable to create Spoilage Request PDF file.');
            system.debug('unable to get content as pdf due to: '+e.getMessage());
        }
        attach.Body = body;
        // add the user entered name
        attach.Name = ChannelOps_Constants.PDFFILE_PREFIX_SIGNEDCOD + ' '+ spoilageRequestCOD.ChannelOps_Spoilage_Request__r.Name +'.pdf';
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.parentId = spoilageRequestCOD.id; 
        attach.ContentType = 'application/pdf';
        try{ 
            insert attach;
         } catch (Exception e){
             system.debug('insert request PDF attachment failed due to: '+e.getMessage());
         }         
         return attach.id;        
    }
    
    @future
    public static void sendCODConfirmationEmail(Id attachmentId, Id spoilageRequestCODId, String emailTemplate) {
        Messaging.EmailFileAttachment[] emailAttachmentList = new List<Messaging.EmailFileAttachment>();
        ChannelOps_Spoilage_Request_COD__c spoilageRequestCOD = null;
        String attachmentNames = '';
        String subject ='';
        String body = '';
        String recipients = '';
        List<ChannelOps_Spoilage_Request_Product__c> spoilageRequestProductList = new List<ChannelOps_Spoilage_Request_Product__c>();
        
        if(spoilageRequestCODId != null){
            List<ChannelOps_Spoilage_Request_COD__c> spoilageRequestCODList = [SELECT Id, Name, ChannelOps_Spoilage_Request__c, Contact_Email__c, 
                                                                               		  Request_Confirmation_Number__c,Contact_Name__c,SAP_Quotation_ID__c,
                                                                               		  SAP_Ship_To_ID__c, Ship_To_Name__c,Facility_Name__c,Street_Address__c,
                                                                               		  Street_Address2__c, City__c, State__c, Zip_Code__c, Contact_Phone__c,
                                                                                      PDF_Attachment_ID__c, ChannelOps_Spoilage_Request__r.PDF_Attachment_ID__c
                                                                               FROM	  ChannelOps_Spoilage_Request_COD__c WHERE Id =: spoilageRequestCODId];
            
            if(spoilageRequestCODList != null && !spoilageRequestCODList.isEmpty()){
                SpoilageRequestCOD = spoilageRequestCODList[0];                                               
                // Create the email attachment
                List<Attachment> codAttachmentList = [SELECT Id, Name, Body FROM Attachment WHERE Id =: attachmentId AND ParentId =: spoilageRequestCODId limit 1];
                if(codAttachmentList!= null && !codAttachmentList.isEmpty()){
                    Attachment att = codAttachmentList[0];
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();     
                    efa.setFileName(att.name);
                    efa.setBody(att.body);
                    emailAttachmentList.add(efa);
                     attachmentNames += att.Name + ';';
                }
            }
        }
        if(SpoilageRequestCOD != null ){
             List<Attachment> spoilageReqAttachmentList = [SELECT Id, Name, Body FROM Attachment WHERE Id =: spoilageRequestCOD.ChannelOps_Spoilage_Request__r.PDF_Attachment_ID__c AND ParentId =: spoilageRequestCOD.ChannelOps_Spoilage_Request__c limit 1];                                                           
                // Create the email attachment
                if(spoilageReqAttachmentList != null && !spoilageReqAttachmentList.isEmpty()){
                    Attachment att = spoilageReqAttachmentList[0];
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();     
                    efa.setFileName(att.name);
                    efa.setBody(att.body);
                    emailAttachmentList.add(efa);
                    attachmentNames += att.Name + ';';
                }
               
            spoilageRequestProductList = [SELECT Id, Name, Product_Name__c, Lot_Number__c, Quantity__c, Serial_Number__c, NDC__c 
                                          FROM   ChannelOps_Spoilage_Request_Product__c 
                                          WHERE	 Spoilage_Request__c =: spoilageRequestCOD.ChannelOps_Spoilage_Request__c];                               
        }                                     
        // Define the email 
        List<EmailTemplate> emailTemplateList = [SELECT Id, name,Subject,HtmlValue, body FROM EmailTemplate WHERE DeveloperName =:emailTemplate ];
        if(!emailTemplateList.isEmpty()){
            subject = emailTemplateList[0].subject.replace('{!ChannelOps_Spoilage_Request_COD__c.Request_Confirmation_Number__c}', SpoilageRequestCOD.Request_Confirmation_Number__c);
            recipients =(String.isNotBlank(SpoilageRequestCOD.Contact_Email__c)) ? SpoilageRequestCOD.Contact_Email__c: '';
            body = emailTemplateList[0].HtmlValue;
            body = (String.isNotBlank(SpoilageRequestCOD.Contact_Name__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.Contact_Name__c}', SpoilageRequestCOD.Contact_Name__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.Contact_Name__c}', 'Customer');
            body = (String.isNotBlank(SpoilageRequestCOD.SAP_Ship_To_ID__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.SAP_Ship_To_ID__c}', SpoilageRequestCOD.SAP_Ship_To_ID__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.SAP_Ship_To_ID__c}', '');
            body = (String.isNotBlank(SpoilageRequestCOD.SAP_Quotation_ID__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.SAP_Quotation_ID__c}', SpoilageRequestCOD.SAP_Quotation_ID__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.SAP_Quotation_ID__c}', '');
            body = (String.isNotBlank(SpoilageRequestCOD.Ship_To_Name__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.Ship_To_Name__c}', SpoilageRequestCOD.Ship_To_Name__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.Ship_To_Name__c}', '');
            body = (String.isNotBlank(SpoilageRequestCOD.Facility_Name__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.Facility_Name__c}', SpoilageRequestCOD.Facility_Name__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.Facility_Name__c}', '');
            body = (String.isNotBlank(SpoilageRequestCOD.Street_Address__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.Street_Address__c}', SpoilageRequestCOD.Street_Address__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.Street_Address__c}', '');
            body = (String.isNotBlank(SpoilageRequestCOD.Street_Address2__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.Street_Address2__c}',','+ SpoilageRequestCOD.Street_Address2__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.Street_Address2__c}', '');
            body = (String.isNotBlank(SpoilageRequestCOD.City__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.City__c}', SpoilageRequestCOD.City__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.City__c}', '');
            body = (String.isNotBlank(SpoilageRequestCOD.State__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.State__c}', SpoilageRequestCOD.State__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.State__c}', '');
            body = (String.isNotBlank(SpoilageRequestCOD.Zip_Code__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.Zip_Code__c}', SpoilageRequestCOD.Zip_Code__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.Zip_Code__c}', '');
            body = (String.isNotBlank(SpoilageRequestCOD.Contact_Phone__c)) ? body.replace('{!ChannelOps_Spoilage_Request_COD__c.Contact_Phone__c}', SpoilageRequestCOD.Contact_Phone__c) : body.replace('{!ChannelOps_Spoilage_Request_COD__c.Contact_Phone__c}', '');
            
            String table = '';
            if(spoilageRequestProductList != null && !spoilageRequestProductList.isEmpty()){
                table = '<table style="width: 100%;boarder:1px solid #dddddd"><tr><th style="border: 1px solid #dddddd;text-align: left;padding: 8px;">NDC</th><th style="border: 1px solid #dddddd;text-align: left;padding: 8px;">Product Description</th><th style="border: 1px solid #dddddd;text-align: left;padding: 8px;">Quantity</th> </tr>';
                for(ChannelOps_Spoilage_Request_Product__c requestProduct : spoilageRequestProductList){
                	   table += '<tr><td style="border: 1px solid #dddddd;text-align: left;padding: 8px;">' + requestProduct.NDC__c + '</td>';     
                       table += '<td style="border: 1px solid #dddddd;text-align: left;padding: 8px;">' + requestProduct.Product_Name__c + '</td>';     
                       table += '<td style="border: 1px solid #dddddd;text-align: left;padding: 8px;">' + requestProduct.Quantity__c + '</td></tr>';     
                } 
                table += '</table></br>';
            } 
            body = (String.isNotBlank(table)) ? body.replace('{!SpoilageRequestProductTable}', table) : body.replace('{!SpoilageRequestProductTable}', '');
            System.debug('Body-------'+body);
        } 

        if(String.isNotBlank(recipients) && String.isNotBlank(subject) && String.isNotBlank(body)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setHtmlBody(body);
            mail.setToAddresses(new List<String>{recipients});
            mail.setSubject(subject);
            //set from email address to org wide email address
            OrgWideEmailAddress orgWideAddress = null;
            try{
                string sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                
                orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreplyco-d@gene.com'];
                
                if(sfdcBaseURL.contains('dev') || sfdcBaseURL.contains('sqa') || sfdcBaseURL.contains('uat')){
                    orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'gneforms-d@gene.com'];
                }
                
            } catch (Exception ex){
                system.debug('OrgWide address or configuration not found');
            }
            if(orgWideAddress != null){
                mail.setOrgWideEmailAddressId(orgWideAddress.Id);
            }            
            
            //set reply to to ChannelOpsCasesSendtemplatereply email service
            EmailServicesFunction emsf = [select id, FunctionName from EmailServicesFunction where functionname='ChannelOpsCasesSendtemplatereply'];
            EmailServicesAddress emsa = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId=: emsf.id];
            string replyemail = emsa.LocalPart+'@'+emsa.EmailDomainName;
            mail.setReplyTo(replyemail);
            
            if(emailAttachmentList != null && !emailAttachmentList.isEmpty()){
                mail.setFileAttachments(emailAttachmentList);
            }    
            // Sends the email 
            try{
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
            }catch(Exception e){
                System.debug('failed to send spoilage request confirmation email due to: '+e.getMessage());
            }        
            
			SpoilageRequestCOD.PDF_Attachment_ID__c = attachmentId;
            SpoilageRequestCOD.Confirmation_Email_Sent__c = true;
            SpoilageRequestCOD.Confirmation_Email_Sent_Date__c = System.now();
            try{
                update SpoilageRequestCOD; 
            }catch(Exception e){
                System.debug('update spoilage request record after confirmation email sending failed due to: '+e.getMessage());
            }
          
            //log outbound emails
            GNE_Channel_Ops_Email_Tracker__c newEmail = new GNE_Channel_Ops_Email_Tracker__c();
            newEmail.From_Address__c =orgWideAddress.Address ;
            newEmail.ChannelOps_Spoilage_Request_COD__c = spoilageRequestCOD.Id;
            newEmail.Use_email_Tempate__c=true;
            newEmail.Subject__c = subject;
            //newEmail.Body__c = body;
            newEmail.Email_Template_Name__c = emailTemplate;
            newEmail.Time_Stamp__c = System.now();
            newEmail.To_Address__c= recipients;

            if(String.isNotBlank(attachmentNames)){
                attachmentNames = attachmentNames.removeEnd(';');
                newEmail.Attachments__c = attachmentNames;

            }
            
            try{
                insert newEmail;
            }catch(Exception e){
                System.debug('Log email failed due to: '+e.getMessage());
            }
        }
    }     
}