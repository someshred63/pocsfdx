public with sharing class C_OPS_IAP_ConfirmationPage_Controller {
    private ID requestId;
    public boolean showfooter {set; get;}
    public String requestRefNum {set; get;}
    public String Deniedstatus {set; get;}
    public String facilityName {get;set;}
    public String newstatusProducts {get;set;}
    public String allstatusProducts {get;set;}
    public String DeniedstatusProducts {get;set;}
    public C_Ops_SPLOA_Request__c request {set; get;}
    public  List<APL__c> apls{set; get;}
    public String RequestType {get;set;}
    
    private without sharing class IAP_Controller_internal{
        Public Attachment saveattachment(Attachment att){
            upsert att;
            return att;
        }
        private  PRP_Email_Tracker__c savephar(PRP_Email_Tracker__c PRPEmail){
            upsert PRPEmail;
            return PRPEmail;
        }
        private  Messaging.SendEmailResult [] sendemail(Messaging.SingleEmailMessage email){
            Messaging.SendEmailResult [] r =Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            return r;
        }
        private C_Ops_SPLOA_Request__c Getrequest(string requestId){
            
            return [select id,Name,Denial_Reason__c,Request_PDF_Version_Number__c,Request_Type__c,C_Ops_SPLOA_Product_Name__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Pharmacy_Name__c,C_Ops_SPLOA_Email__c from C_Ops_SPLOA_Request__c where id=:requestId limit 1];
        }
        
        private blob Getblobpdf(PageReference ref){
            
            return ref.getContentAsPDF();
        }
        private list<Attachment> Getattachment(string requestId,string names){
        return [select id from Attachment where Name=:names and ParentId =:requestId limit 2];
        }
        Private list<C_Ops_SPLOA_Additional_Pharmacy__c> getadditionalphar(string requestId )
        {
            return [select id,name, C_Ops_SPLOA_DEA_Number__c,Pharmacy_Name__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,C_Ops_SPLOA_State__c,C_Ops_SPLOA_Zip__c,C_Ops_SPLOA_Request__c,Accreditation__c,Is_Primary_Pharmacy__c,Denial_Reason_Code__c,Request_Status__c from C_Ops_SPLOA_Additional_Pharmacy__c where C_Ops_SPLOA_Request__c =:requestId];
            
        }
    }
    
    public void initialise() {
        try{
            IAP_Controller_internal internalsave= new IAP_Controller_internal();
            PageReference curPage=Page.C_OPS_IAP_ConfirmationPageEmail;  
            curPage.getParameters().put('id',requestId );
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            list<string> EmailIds = new list<string>();
            EmailIds.add(request.C_Ops_SPLOA_Email__c);   
            email.setSubject( 'Genentech Product Access Request: '+request.name);
            system.debug(EmailIds);
            email.setToAddresses( EmailIds  );
            PageReference ref = Page.c_ops_iap_requestdetails_pdf;
            ref.setRedirect(true);
            ref.getParameters().put('id',requestId );
            request=internalsave.Getrequest(requestId);
            Blob b = internalsave.Getblobpdf(ref);
          // Blob b=ref.getContentAsPDF();
            system.debug('Blob Retrived ');
            Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
            efa1.setFileName(request.Name +'.pdf');
            efa1.setBody(b);
            email.setOrgWideEmailAddressId([select id, Address, DisplayName from OrgWideEmailAddress where DisplayName ='Indirect Access Program' limit 1].id);
            email.setHtmlBody(curPage.getContent().tostring());
            email.setReplyTo('ssf.limited_distribution@roche.com');
            //email.setSenderDisplayName('Indirect Access Program');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
            
            Attachment att = new Attachment();
            decimal vernum=1;
            // add the request id to the parameters for standardcontroller
            if (request.Request_PDF_Version_Number__c  != null){
                vernum=request.Request_PDF_Version_Number__c ;
            } 
            att.Body = ref.getContent();
            att.Name = request.Name + ' Version ' + vernum+'.pdf';
            att.IsPrivate = false;
            att.ParentId = requestId;
            att.ContentType = 'application/pdf';
            list<Attachment> attlist = new list<Attachment>();
            attlist=internalsave.Getattachment(requestId,att.Name);
            if(attlist.size() == 0){
                // Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                Messaging.SendEmailResult [] r = internalsave.sendemail(email);
                // insert att;
                att=internalsave.saveattachment(att);
                PRP_Email_Tracker__c PRPEmail = new PRP_Email_Tracker__c();
                curPage.getParameters().put('showfooter',requestId );
                PRPEmail.Body__c =string.valueOf(curPage.getContent().tostring());
                if(String.isNotBlank(request.C_Ops_SPLOA_Email__c)){
                    PRPEmail.CC_Address__c = request.C_Ops_SPLOA_Email__c;
                }
                PRPEmail.C_Ops_IAP_Submitted_Requests__c = requestId;
                PRPEmail.Sent__c = 'Indirect Access Program Site Guest User';
                PRPEmail.Sent_On__c = DateTime.now();
                PRPEmail.Subject__c = 'Genentech Product Access Request: '+request.name;
                PRPEmail.To_Address__c = request.C_Ops_SPLOA_Email__c;
                //insert PRPEmail;
                PRPEmail= internalsave.savephar(PRPEmail);
                Attachment att2 = new Attachment();
                vernum=1;
                // add the request id to the parameters for standardcontroller
                if (request.Request_PDF_Version_Number__c  != null){
                    vernum=request.Request_PDF_Version_Number__c ;
                } 
                att2.Body = ref.getContent();
                att2.Name = request.Name + ' Version ' + vernum+'.pdf';
                att2.IsPrivate = false;
                att2.ParentId = PRPEmail.id;
                att2.ContentType = 'application/pdf';
                //  insert att2;
                att2=internalsave.saveattachment(att2);
                system.debug('send email result'+r);
            }
        }catch(exception ex){
            system.debug('--> ex-->'+ex);
        }
    }
    
    
    public C_OPS_IAP_ConfirmationPage_Controller(ApexPages.StandardController controller) {
        showfooter=true;
        newstatusProducts ='';
        DeniedstatusProducts  ='';
        Deniedstatus='';
        allstatusProducts='';
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        PageReference curPage=ApexPages.currentPage();   
        if(curPage.getParameters()!=null) {
            requestId=curPage.getParameters().get('id'); 
            
            if(string.isnotblank(curPage.getParameters().get('showfooter')))
                showfooter=false;                                     
        }  
        else requestId=controller.getRecord().id; 
        request=internalsave.Getrequest(requestId);
        apls =[SELECT Id,Request_Status__c,C_Ops_IAP_Submitted_Requests__c,Product__c FROM APL__c WHERE C_Ops_IAP_Submitted_Requests__c=:requestId ];
        list<C_Ops_SPLOA_Additional_Pharmacy__c> pharmas= new list<C_Ops_SPLOA_Additional_Pharmacy__c>();
        pharmas= internalsave.getadditionalphar(string.valueof(requestId));
        for(C_Ops_SPLOA_Additional_Pharmacy__c pharma:pharmas){
            if(pharma.Denial_Reason_Code__c=='Not Accredited')
            Deniedstatus='Not Accredited';
        }
        if(request!=null) {
            requestRefNum = request.Name;
            facilityName = request.C_Ops_SPLOA_Pharmacy_Name__c ;
            RequestType  = request.Request_Type__c;
        }
        if(apls.size() > 0){
            for(APL__c apl : apls ){
                allstatusProducts=allstatusProducts  +  apl.Product__c + ', ' ;
                if(apl.Request_Status__c == 'New'){
                    newstatusProducts  = newstatusProducts  +  apl.Product__c + ', ' ;
                }
                else if(apl.Request_Status__c == 'Denied'){
                    DeniedstatusProducts  = DeniedstatusProducts  +  apl.Product__c + ', ' ;
                }
            }
        }
        if(newstatusProducts != ''){newstatusProducts = newstatusProducts.removeEnd(', '); }
        if(DeniedstatusProducts != ''){DeniedstatusProducts = DeniedstatusProducts.removeEnd(', ');} 
        if(allstatusProducts != ''){allstatusProducts = allstatusProducts.removeEnd(', ');} 
       
        //nextPagetemp.getContent().tostring()
        // system.debug(curPage.getContent().tostring());
    }
    
    public PageReference redirectoHome(){
        PageReference homePage=Page.c_ops_iap_request_homepage;
        return homePage; 
    }
    
    public PageReference redirectoconpage() {                
        PageReference nextPage=Page.C_OPS_IAP_CONTACT_INFOPG;
        nextPage.getParameters().put('id',request.id);
        nextPage.getParameters().put('requestType',request.Request_Type__c);
        return nextPage; 
    }
    public PageReference viewRequestPDFPage() {
        
        PageReference nextPage=Page.C_OPS_IAP_RequestDetails_PDF;
        nextPage.getParameters().put('id',request.id);
        nextPage.getParameters().put('requestType',request.Request_Type__c);
        return nextPage;
    }
  
}