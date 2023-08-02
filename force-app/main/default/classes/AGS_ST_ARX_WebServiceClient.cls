public without sharing class AGS_ST_ARX_WebServiceClient 
{
    public String wsUrl{ get; set;} 
    public String lastRequest { get; private set;}
    public String lastResponse { get; private set;}
            
    public LoginResponse login(LoginRequest request, String quizaccount)
    {        
        clearLastResponseRequest();
        
        String params  = '';
        params = addParam(params, 'username', request.username);
        params = addParam(params, 'password', request.password);
        params = addParam(params, 'quizaccount', (String.isBlank(quizaccount)) ?'0':quizaccount);       
        params = cutLastChar(params);       
        
        this.lastRequest = params;
        System.debug('AGS_ST_ARX_WebServiceClient.login, request params: ' + params);                               
        String respString = doRequest(this.wsUrl + '/sunshine/login/format/json', params);              
        if(respString == null)
            return null;
        
        System.debug('AGS_ST_ARX_WebServiceClient.login, resonse: ' + respString);                      
                                
        LoginResponse response = (LoginResponse) JSON.deserialize(respString, LoginResponse.class);   
        this.lastResponse = respString;
        return response;
    }
     
    public QuizResponse quiz(QuizRequest request)
    {
        clearLastResponseRequest();
        
        String params  = '';
        params = addParam(params, 'session_id', request.session_id);
        params = addParam(params, 'first_name', request.first_name);
        params = addParam(params, 'last_name', request.last_name);
        params = addParam(params, 'gender', request.gender);
        params = addParam(params, 'dob', request.dob);
        params = addParam(params, 'ssn', request.ssn);
        params = addParam(params, 'home_address_1', request.home_address_1);
        params = addParam(params, 'home_address_2', request.home_address_2);
        params = addParam(params, 'home_city', request.home_city);
        params = addParam(params, 'home_state', request.home_state);
        params = addParam(params, 'home_zip', request.home_zip);
        params = addParam(params, 'home_phone', request.home_phone);                                    
        params = cutLastChar(params);       
        
        this.lastRequest = params;
        System.debug('AGS_ST_ARX_WebServiceClient.quiz, request params: ' + params);        
        String respString = doRequest(this.wsUrl + '/sunshine/quiz/format/json', params);       
        if(respString == null)
            return null;

        System.debug('AGS_ST_ARX_WebServiceClient.quiz response: ' + respString);               
    
        QuizResponse response = (QuizResponse) JSON.deserialize(respString, QuizResponse.class);   
        this.lastResponse = respString;
        return response;                                
    }
    
    public ScoreQuizResponse scoreQuiz(ScoreQuizRequest request)
    {
        clearLastResponseRequest();
                
        String params  = '';
        params = addParam(params, 'session_id', request.session_id);
        params = addParam(params, 'question_response', JSON.serialize(request.question_response));                              
        params = cutLastChar(params);       
        
        this.lastRequest = params;
        System.debug('AGS_ST_ARX_WebServiceClient.scoreQuiz, request params: ' + params);       
        String respString = doRequest(this.wsUrl + '/sunshine/scorequiz/format/json', params);  
        if(respString == null)
            return null;
        System.debug('AGS_ST_ARX_WebServiceClient.scoreQuiz, response: ' + respString); 
                                            
        ScoreQuizResponse response = (ScoreQuizResponse) JSON.deserialize(respString, ScoreQuizResponse.class);      
        this.lastResponse = respString;
        return response;            
    }
    
    public NpiLookupQuizResponse npiLookupQuiz(NpiLookupQuizRequest request)
    {
        clearLastResponseRequest();
        
        String params  = '';
        params = addParam(params, 'first_name', request.first_name);
        params = addParam(params, 'last_name', request.last_name);
        params = addParam(params, 'gender', request.gender);
        params = addParam(params, 'dob', request.dob);
        params = addParam(params, 'practice_address_1', request.practice_address_1);
        params = addParam(params, 'practice_address_2', request.practice_address_2);
        params = addParam(params, 'practice_city', request.practice_city);
        params = addParam(params, 'practice_state', request.practice_state);
        params = addParam(params, 'practice_zip', request.practice_zip);
        params = addParam(params, 'practice_phone', request.practice_phone);                                                        
        params = cutLastChar(params);       
                
        this.lastRequest = params;      
        System.debug('AGS_ST_ARX_WebServiceClient.npiLookupQuiz, request params: ' + params);                   
        String respString = doRequest(this.wsUrl + '/sunshine/NPILookup/format/json', params);  
        if(respString == null)
            return null;
        System.debug('AGS_ST_ARX_WebServiceClient.npiLookupQuiz, response: ' + respString);     
                            
        NpiLookupQuizResponse response = (NpiLookupQuizResponse) JSON.deserialize(respString, NpiLookupQuizResponse.class);   
        this.lastResponse = respString;                                                   
        return response;                            
    }
        
    private String doRequest(String endpoint, String body)
    {   
        HttpRequest req = new HttpRequest();
        // AGGSSUP-612: Host header removed
        // req.setHeader('Host', this.wsUrl);
        // system.debug('------host'+this.wsUrl);
        req.setEndpoint(endpoint);
        system.debug('------endpoint'+endpoint);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-length', String.valueOf(body.length()));
        req.setHeader('Accept', 'application/json'); // AGGSSUP-612: Accept header added
        req.setBody(body);
        system.debug('------body'+body);
        Http httpr = new Http();  
        HttpResponse res = httpr.send(req);
        system.debug('------request'+req); 
        system.debug('------res'+res); 
        Integer statusCode = res.getStatusCode();
        /*
        if (!(statusCode >= 200 && statusCode < 300))
        {
            System.debug('AGS_ST_ARX_WebServiceClient.doRequest, code: ' + statusCode + ', ' + res.getStatus());
            return null;
        }*/
        if(statusCode == 404)
        {
            return '{"is_identified":"N","error":"User cannot be found."}';
        }
        else if(statusCode == 400)
        {
            return '{"error":"Bad Request   Input parse error. A required input or JSON string is invalid or missing required elements."}';
        }
        else if(statusCode == 401)
        {
            return '{"error":"Authentication against the login method failed. Check the username and password combination."}';
        }
        else if(statusCode == 403)
        {
            return '{"error":"Invalid session id, or a session id was not included in the request. All methods other than login require a valid session id."}';
        }
        else
            return res.getBody();       
    } 
    
    private String cutLastChar(String s)
    {
        if(s==null)
            return null;
        if(s.length()==0)
            return '';
        
        return s.substring(0, s.length()-1);        
    }
    
    private String addParam(String params, String paramName, String paramValue)
    {
        if(!AGS_ST_Utils.hasValue(paramName))
            return params;
        if(!AGS_ST_Utils.hasValue(paramValue))
            return params;
                            
        //String p = paramName + '=' + EncodingUtil.urlEncode(paramValue, 'UTF-8') + '&';
        String p = paramName + '=' + paramValue + '&';              
        return params + p;
    }
    
    private void clearLastResponseRequest()
    {
        this.lastRequest = null;
        this.lastResponse = null;
    }
            
    // -------------------------------
    
    public class LoginRequest
    {
        public String username;
        public String password;     
                
        public String dataToString()
        {
            return 'username: ' + this.username + ', password: ' + password; 
        }       
    }

    public class LoginResponse
    {
        public String session_id;
        public String error;    
        
        public String dataToString()
        {
            return 'session_id: ' + this.session_id + ', error: ' + this.error; 
        }   
    }
    
    // -------------------------------  

    public class QuizRequest
    {
        public String session_id;
        public String first_name;
        public String last_name;
        public String gender;
        public String dob;
        public String ssn;
        public String home_address_1;
        public String home_address_2;
        public String home_city;
        public String home_state;
        public String home_zip;
        public String home_phone;
    
        public String dataToString()
        {
            return 'session_id: ' + this.session_id + ', first_name: ' + first_name + ', last_name: ' + this.last_name + ', gender: ' + gender + ', dob: ' + this.dob + ', ssn: ' + this.ssn + ', home_address_1: ' + this.home_address_1 + ', home_address_2: ' + this.home_address_2 +  + ', home_city: ' + this.home_city  + ', home_state: ' + this.home_state   + ', home_zip: ' + this.home_zip   + ', home_phone: ' + this.home_phone; 
        }                   
    }

    public class QuizResponse
    {
        public String quiz_id;
        public String quiz_status;
        public String is_identified;
        public List<QuizQuestion> questions;
        public String error;    
        
        public String dataToString()
        {
            return 'quiz_id: ' + this.quiz_id + ', quiz_status: ' + quiz_status + ',is_identified: ' + this.is_identified + ', questions: ' + this.questions + ', error: ' + this.error; 
        }                   
    }
    
    public class QuizQuestion
    {
        public string question_id;
        public string text;
        public List<ChoiceIdText> choices;
                        
        public String dataToString()
        {       
            return 'question_id: ' + this.question_id + ', text: ' + this.text; 
        }   
    }
    
    public class ChoiceIdText
    {
        public string id;
        public string text;
    }

    // -------------------------------  

    public class ScoreQuizRequest
    {
        public String session_id;
        public QuestionResponse question_response;      
        
        public String dataToString()
        {       
            return 'session_id: ' + this.session_id + ', question_response: ' + question_response; 
        }   
    }

    public class ScoreQuizResponse
    {
        public String quiz_status;
        public String error;    
        
        public String dataToString()
        {
            return 'quiz_status: ' + this.quiz_status + ', error: ' + error; 
        }       
    }
    
    public class QuestionResponse
    {
        public String quiz_id;
        public List<QuestionChoice> response;
        
        public String dataToString()
        {
            return 'quiz_id: ' + this.quiz_id + ', response: ' + response; 
        }           
    }
     
    public class QuestionChoice
    {
        public String question_id;
        public String choice_id;    
        
        public String dataToString()
        {
            return 'question_id: ' + this.question_id + ', choice_id: ' + choice_id; 
        }       
    }
    
    // -------------------------------  

    public class NpiLookupQuizRequest
    {
        public string session_id;
        public string first_name;
        public string last_name;
        public string gender;
        public string dob;
        public string practice_address_1;
        public string practice_address_2;
        public string practice_city;
        public string practice_state;
        public string practice_zip;
        public string practice_phone;                                   
    }

    public class NpiLookupQuizResponse
    {
        public string npi;
        public string first_name;
        public string last_name;
        public string gender;
        public string practice_address_1;
        public string practice_address_2;
        public string practice_city;
        public string practice_state;
        public string practice_zip;
        public string mailing_address_1;
        public string mailing_address_2;
        public string mailing_city;
        public string mailing_state;
        public string mailing_zip;
        public string error;            
    }

    public class LogData
    {
        public string request;
        public string response;
    }
    
}