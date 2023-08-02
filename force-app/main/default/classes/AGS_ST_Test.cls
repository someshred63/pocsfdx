public without sharing class AGS_ST_Test 
{           
    public String reqMsg {get; set;} 

    public String respHdr {get; set;}        
    public String respMsg {get; set;}
     
    public String respStatusCode {get;set;}
    public String respStatus {get;set;}
    public String fakeRespMsg {get;set;}
    
    private SimsUserObjectClass simsUserObject {get;set;}
     
    public static final String TEST_SIMS_ENDPOINT ='http://simsit01.gene.com:10112/idm/ext/ajax?operation=spring';
    public static final String TEST_SIMS_ENDPOINT2 ='http://extsimsit01.gene.com:10112/idm/ext/ajax?operation=spring';    
    public static final String TEST_SIMS_ENDPOINT3 ='https://extsimsit.gene.com/idm/ext/ajax?operation=spring';  
    public static final String TEST_SIMS_ENDPOINT4 ='https://extsimsit.gene.com/idm/ext/mvc/ext/users';


    public AGS_ST_Test(){
        reqMsg = '';
    } 

    public void run()
    {
        AGS_ST_ARX_WebServiceClient.LoginRequest req = new AGS_ST_ARX_WebServiceClient.LoginRequest(); 
        
        
        AGS_ST_SIMS_RegistrationHelper_gne a = new AGS_ST_SIMS_RegistrationHelper_gne();
        Boolean b = a.registerUser('a8SS00000000nYyMAI');
        
        System.debug('ZZZZZZZZZZ status:' + b );
        
        //this.generateRequest();
        //this.send();
    }
    
    public void generateRequest(){
        simsUserObject = new SimsUserObjectClass();
        simsUserObject.firstName = 'michal';
        simsUserObject.lastName = 'jordan';
        simsUserObject.phone = '+48999999999';
        simsUserObject.email = 'lk_sunshine@mailinator.com';

        SimsCreateUser simsCreateUserObj = new SimsCreateUser(simsUserObject);
        reqMsg = JSON.serialize(simsCreateUserObj);   
              
        system.debug('JSON: ' + reqMsg);
    }
    
    
    public void send()
    {
        
        fakeRespMsg = respMsg;
        
       try {        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http httpr = new Http();  
        
        req.setEndpoint(TEST_SIMS_ENDPOINT4);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Content-length', String.valueOf(req.getBody().length()));
        req.setBody(reqMsg);        
       // req.setCompressed(true);
         
        res = httpr.send(req);
        respStatus = res.getStatus();
        system.debug('---'+respStatus+'----'+res.getBody()+'-----'+res.getStatusCode());
        respStatusCode = String.valueOf( res.getStatusCode());
        
        respMsg = res.getBody(); 
    
        }
        catch (Exception e){
            respMsg += e.getMessage() + '\n'+e.getTypeName() + '\n'+e.getStackTraceString();
            
            system.debug('XXXX: ' + respMsg);
        }
              
    }
            
    class SimsCreateUser
    {
        //String service;
        //String method;
        List<String> apps;
        //SimsUserObjectClass userObject;
        String firstName;
        String lastName;
        String phone;
        String email;
        
        private SimsCreateUser(){}
        
        public SimsCreateUser(SimsUserObjectClass newUser){
            //service = 'externalUserService';
            //method = 'create';
            apps = new List<String>();
            apps.add('mas');
            apps.add('elib');
            //userObject = new SimsUserObjectClass();
            
            firstName = newUser.firstname;
            lastName = newUser.lastname;
            phone = newUser.phone;
            email = newUser.email;
        }
    }
    
    class SimsUserObjectClass
    {
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String phone{get;set;}
        public String email{get;set;}
    }       

}