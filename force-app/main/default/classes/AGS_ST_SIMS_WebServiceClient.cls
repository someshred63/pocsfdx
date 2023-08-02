public without sharing class AGS_ST_SIMS_WebServiceClient 
{
    private final String wsEndpoint;
    
    public AGS_ST_SIMS_WebServiceClient(String wsEndpoint)
    {
        this.wsEndpoint = wsEndpoint; 
    } 
        
    public Boolean createSimsUser(String firstName, String lastName, String phone, String email)
    {
        try
        {
            String jsonContent = prepareJsonRequestContent(firstName, lastName, phone, email);
            HttpResponse response = doJsonWsRequest(jsonContent);
            Boolean status = checkSimsWsResponseStatus(response);
            return status;
        }
        catch(Exception e)
        {
            System.debug('CREATE SIMS USER ERROR.');
            System.debug(Logginglevel.ERROR, e);
            return false;
        }
    }
    
    private String prepareJsonRequestContent(String firstName, String lastName, String phone, String email)
    {
        System.debug('Preparing JSON request content for SIMS webservice');         
                        
        SimsCreateUserData simsCreateUserData = new SimsCreateUserData(                                         
                                                        firstName,
                                                        lastName,
                                                        phone,
                                                        email                                                                                               
                                                    );
                                                    
        String reqBodyJson = JSON.serialize(simsCreateUserData);           
        return reqBodyJson;
    }  
    
    private HttpResponse doJsonWsRequest(String jsonContent)
    {
        System.debug('JSON request content: ' + jsonContent);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(this.wsEndpoint);
        req.setBody(jsonContent);               
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Content-length', String.valueOf(req.getBody().length()));    
        req.setHeader('Authorization', 'Basic Z29yZG9uLmZyZWVtYW5AbWFpbGluYXRvci5jb206bGV0bWVpbg==');
        //req.setCompressed(true); Causes 'char(31) error'.
    
        System.debug('SIMS webservice request ready, url: ' + this.wsEndpoint);
        Http httpr = new Http();  
        HttpResponse res = httpr.send(req);
        return res;
    }       
    
    private Boolean checkSimsWsResponseStatus(HttpResponse response)
    {                   
        if (response.getBody().contains('exception')) 
        {
            System.debug('SIMS RESPONSE EXCEPTION');            
            SimsExceptionResponse ser = (SimsExceptionResponse) JSON.deserialize(response.getBody(), SimsExceptionResponse.class);                  
            System.debug(Logginglevel.ERROR, response.getBody());
            String content = subString(ser.exceptionObj.stackTrace);                    
            AGS_ST_Utils.logRegistrationError('AGS_ST_SIMSRegistrationHelper__gne', content, ser.exceptionObj.message, 'checkSimsWsResponseStatus', null, null, null);

            return false;
        }   
        if ((response.getStatusCode() != 200) && (response.getStatusCode() != 201)) 
        {
            System.debug('SIMS RESPONSE NOT SUCCESS');                      
            String content = subString(response.getBody());                 
            String errorMessage = 'Error ' + response.getStatusCode() + ':' + response.getStatus(); 
            System.debug(Logginglevel.ERROR, errorMessage);         
            AGS_ST_Utils.logRegistrationError('AGS_ST_SIMSRegistrationHelper__gne', content, errorMessage, 'checkSimsWsResponseStatus', null, null, null);
            
            return false;
        }     
         
        System.debug('SIMS user creating WS response: statusCode: ' + response.getStatusCode() + ', status: ' + response.getStatus() + ', user sims id (body): ' + response.getBody());        
        return true;                            
    }
        
    private String subString(String s)
    {
        if(s == null)
            return '';
        if(s.length()>254)
            return s.substring(254);                     
        return s;       
    } 
    
    class SimsCreateUserData
    {               
        public List<String> apps {get;set;}                
        public String firstName {get;set;}    
        public String lastName {get;set;}    
        public String phone {get;set;}    
        public String email {get;set;}     
        
        public SimsCreateUserData(String firstName, String lastName, String phone, String email)
        {
            this.apps = new List<String>();    
            this.apps.add('sun');                  
            //this.apps.add('mas');
            //this.apps.add('elib');   
    
            this.firstName = firstName;
            this.lastName = lastName;
            this.phone = phone;
            this.email = email;
        }
    }
               
    class SimsExceptionResponse
    {
        public SimsExceptionClass exceptionObj;
        
        public SimsExceptionResponse()
        {
            exceptionObj = new SimsExceptionClass();
        }
    }
    
    class SimsExceptionClass
    {
        public String message;
        public String stackTrace;
        
        public SimsExceptionClass()
        {
            this.message = '';
            this.stackTrace = '';           
        }               
    }

}