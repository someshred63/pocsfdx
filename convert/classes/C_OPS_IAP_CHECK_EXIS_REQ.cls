public without sharing class C_OPS_IAP_CHECK_EXIS_REQ {

    public String response { get; set; }
    public String publicKey { get; set; }



        public C_Ops_Captcha_Property__c prop{get;set;}
    public String RecaptchaPublicSecret { get; set; }
        private string recaptchaPrivateSecret;
    private String baseUrl;
    
        public string getRecaptchaPublicSecret() {
        return this.recaptchaPublicSecret;
    }
    

     public boolean recaptchaVerified {public get; public set;}
    public String requestNumber {get;set;}
    public String DEANumber {get;set;}
    public String errorMessage{get;set;}
    private List<C_Ops_SPLOA_Request__c>  reqlist ;
    public Id reqId{get;set;}
    public String pageName;
    
    public C_OPS_IAP_CHECK_EXIS_REQ(){
    
    this.recaptchaVerified = true;
    
        prop = [SELECT ID, GSiteKey__c, GSecurityKey__c, GSite__c,Active__c FROM C_Ops_Captcha_Property__c WHERE Active__c=true LIMIT 1];        
               
        recaptchaPublicSecret = prop.GSiteKey__c;
        recaptchaPrivateSecret = prop.GSecurityKey__c;
        baseUrl=prop.GSite__c;
        
    }
    
    public PageReference cancelToHome(){
        PageReference nextPage;    
        nextPage=Page.C_OPS_IAP_Request_HomePage;  
        return nextPage;    
    }
    
    @testVisible private boolean verifyCaptcha()
    {
        system.debug('response'+response+'this.recaptchaVerified'+this.recaptchaVerified);
        if (this.recaptchaVerified) return true;
        
        if( String.IsBlank(response))
        {
            errorMessage ='123Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';
            handleError(errorMessage);
            return false;
        }
        
        String urlbody='secret=' + recaptchaPrivateSecret + '&response='  +  response;
        HttpResponse r = makeRequest(baseUrl, urlbody);
        if( r!= null )
        {
            
            
            JSONParser parser = JSON.createParser(r.getBody());
            
            if(r.getBody()!=null && r.getBody().containsIgnoreCase('timeout-or-duplicate')){
                this.recaptchaVerified = true;
                
            }
            
            while (parser.nextToken() != null) {
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'success')) {              
                    parser.nextToken();
                    if(parser.getText()=='true') this.recaptchaVerified = true;
                }
                
                
            }
        }else {
            errorMessage ='456Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';            
            handleError(errorMessage);
            return false;
        }
        
        if(this.recaptchaVerified)
        {
            return true;
        }
        else
        {
            errorMessage ='Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';
            handleError(errorMessage);
            return false;
        }
    }
    
    
    @testVisible private HttpResponse makeRequest(string url, string body)
    {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();  
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try
        {
            Http http = new Http();
            response = http.send(req);
            
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        }
        catch(System.Exception e)
        {
            System.debug('ERROR: ' + e);
        }
        return response;
    }
    
    
    public PageReference checkdetails(){        
        errorMessage  ='';
         if(!this.recaptchaVerified){
            verifyCaptcha();
        }
        if(String.IsBlank(requestNumber) || String.IsBlank(DEANumber)){
            errorMessage ='Please fill in all the details';
            handleError(errorMessage);  
        }
        if(errorMessage == ''){
             reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c,Name,C_Ops_SPLOA_DEA_Number__c,Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c 
                                                         FROM C_Ops_SPLOA_Request__c WHERE Name = :requestNumber AND C_Ops_SPLOA_DEA_Number__c = :DEANumber]);
            if(reqlist.size() == 0){
                errorMessage ='The entered details don\'t match our records, please retry.';
                handleError(errorMessage);  
            }
            else if(reqlist.size()>0){
            reqId  = reqlist[0].Id;
            }
            if(reqId != null && errorMessage == ''){
                PageReference conPage =Page.C_OPS_IAP_REQDETAILSPG;
                conPage.getParameters().put('reqid',reqId);
                return conPage ; 
            }
        }
        return null;
    }    

    public void handleError(string errorText){
        if(String.isBlank(errorText)){
            return;
        }
        ApexPages.Message[] curMsgs=ApexPages.getMessages();
        boolean notFind=true;
        if(curMsgs!=null && curMsgs.size()>=1){
            for (ApexPages.Message msg:curMsgs){
                if(msg!=null && (!String.isBlank(msg.getSummary())) && msg.getSummary().trim().equalsIgnoreCase(errorText.trim())){
                    notFind=false;
                    break;
                }
            }
        }
        
        if(notFind) {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorText);
            ApexPages.addMessage(errorMsg);
        }
        
        return;
    }
    

                
    
}