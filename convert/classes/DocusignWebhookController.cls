@RestResource(urlMapping='/DocusignWebhookToSFRest/*')
global class DocusignWebhookController {
    
   @HttpPost
    global static String doPost() {
        string envelopeId;
        string pdfContent;
        Map<String,Id>  appEnvelopeMap = new Map<String,Id>();
        for(gFRS_Ltng_Application__c recObj : [SELECT Id,EnvelopeId__c FROM gFRS_Ltng_Application__c WHERE EnvelopeId__c != '']){
            appEnvelopeMap.put(recObj.EnvelopeId__c,recObj.Id);
        }
        string signedDocumentResponse = RestContext.request.requestbody.tostring();
        system.debug('signedDocumentResponse'+signedDocumentResponse);
        
        dom.document doc = new dom.document();
        doc.load(signedDocumentResponse);
        
        dom.XMLNode rootElement = doc.getRootElement();
        system.debug('rootElement '+ rootElement.getName());
        List<Dom.XMLNode> rootChildElements = rootElement.getChildElements();
        for(Dom.XMLNode rootchildElement : rootChildElements){
            if(rootchildElement.getName() == 'EnvelopeStatus'){
                List<Dom.XMlNode>  envelopeChild =  rootchildElement.getChildElements();
                for(Dom.XmlNode childElement : envelopeChild){
                    if(childElement.getName() == 'EnvelopeID'){
                        envelopeId = childElement.gettext();
                    }
                }
            }
            if(rootchildElement.getName() == 'DocumentPDFs'){ 
                List<Dom.XMLNode> documentChild = rootchildElement.getChildElements();
                for(Dom.XMLNode docChild : documentChild){
                     system.debug('checkChild '+docChild.getName());
                    if(docChild.getName() == 'DocumentPDF'){
                        List<Dom.XMLNode> contentElement = docChild.getChildElements();
                        
                        for(Dom.XMLNode cont : contentElement){
                           
                            if(cont.getName() == 'PDFBytes'){
                                 Attachment attach = new Attachment();
                                 attach.contentType = 'application/pdf';
                                 attach.name = 'ExecutedLOA.pdf';
                                 attach.parentId = appEnvelopeMap.get(envelopeId);
                                 attach.body = EncodingUtil.base64Decode(cont.gettext());
                                 insert attach;
                            }
                            
                            system.debug('Inside PDF '+cont.getName());
                            system.debug('LOOKOUT '+cont.gettext());
                        }
                       
                    }   
                }
            }
        }
        return '';
    } 
}