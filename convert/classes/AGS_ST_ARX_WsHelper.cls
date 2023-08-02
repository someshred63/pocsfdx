public with sharing class AGS_ST_ARX_WsHelper 
{               
    public String lastRequest { get; private set;}
    public String lastResponse { get; private set;}     
    public String lastRequestStatus { get; private set;}   
    public String lastLevel { get; private set;} 
    public String error { get; private set;} 
    
    public static AGS_ST_Settings_gne__c stSetting 
    { 
        get
        {
            if(Site.getDomain() == null)
                return AGS_ST_Utils.getCustomSettings();
            else
                return AGS_ST_Utils.getCustomSettingsInSite();
        }
        private set;
    } 
    
    public AGS_ST_ARX_WebServiceClient.LoginResponse arxRequestLogIn()
    {                               
        AGS_ST_ARX_WebServiceClient.LoginRequest loginRequest = new AGS_ST_ARX_WebServiceClient.LoginRequest();
        system.debug('------'+stSetting);
        loginRequest.username = stSetting.ARX_User__c; //'gene';
        loginRequest.password = stSetting.ARX_Password_gne__c; //'f0l0wth3wr';
        
        system.debug('---loginRequest'+loginRequest);
        
        AGS_ST_ARX_WebServiceClient wsClient = getWsClient();                       
        AGS_ST_ARX_WebServiceClient.LoginResponse loginResponse = wsClient.login(loginRequest, stSetting.ARX_QuizAccount__c);
        
        System.debug('AGS_ST_ARX_WebServiceClient.login response: ' + loginResponse);
        if(loginResponse == null)
            return null;

        this.lastRequest = wsClient.lastRequest;
        this.lastResponse = wsClient.lastResponse;
        this.lastLevel = 'Login'; 
        if(loginResponse.error != null)
        {
            this.lastRequestStatus = 'Login failed';
            this.error = loginResponse.error;
        }
        else
        {
            this.lastRequestStatus = 'Login success';
            this.error = '';
        }
        return loginResponse;       
    }       
    
    public AGS_ST_ARX_WebServiceClient.QuizResponse arxRequestQuiz(String sessionId, AGS_ST_User user)
    { 
        System.debug('Preparing AGS_ST_ARX_WebServiceClient.quiz method.');             
        AGS_ST_ARX_WebServiceClient.QuizRequest quizRequest = new AGS_ST_ARX_WebServiceClient.QuizRequest();                        
        quizRequest.session_id = sessionId; 
    
// -----------------------------------------    
/*
        quizRequest.first_name = 'MARY';
        quizRequest.last_name = 'MILLER';
        quizRequest.gender = 'F';
        quizRequest.dob = '07/31/1959';
        quizRequest.ssn = '4994';
        quizRequest.home_address_1 = '51 CHESTNUT ST'; 
        quizRequest.home_city = 'NASHUA';
        quizRequest.home_state = 'IA';
        quizRequest.home_zip = '50658';
*/
// -----------------------------------------
    


        quizRequest.first_name = user.firstName;
        quizRequest.last_name = user.lastName;
        quizRequest.gender = user.gender;
        quizRequest.dob = user.dob; 
        quizRequest.ssn = user.ssn;
        quizRequest.home_address_1 = user.street;
        quizRequest.home_city = user.city;
        quizRequest.home_state = user.state;
        quizRequest.home_zip = user.zip;
        
    
     
        system.debug('---quizRequest'+quizRequest);
        
        AGS_ST_ARX_WebServiceClient wsClient = getWsClient();       
        AGS_ST_ARX_WebServiceClient.QuizResponse quizResponse = wsClient.quiz(quizRequest); 
        
        System.debug('AGS_ST_ARX_WebServiceClient.quiz response: ' + quizResponse);     
        if(quizResponse == null)
            return null;
                
        this.lastRequest = wsClient.lastRequest;
        this.lastResponse = wsClient.lastResponse;
        this.lastLevel = 'Request Quiz';  
        if(quizResponse.error != null)
        {
            this.lastRequestStatus = 'Loading quiz failed';
            this.error = quizResponse.error;
        }
        else
        {
            this.lastRequestStatus = 'Loading quiz success';
            this.error = '';
        }
        return quizResponse;
    }
       
    public AGS_ST_ARX_WebServiceClient.ScoreQuizResponse arxRequestScoreQuiz(String sessionId, String quizId, List<AGS_ST_ARX_WebServiceClient.QuestionChoice> questionsChoices)
    {
        System.debug('Preparing data for AGS_ST_ARX_WebServiceClient.ScoreQuizRequest.');
                
        AGS_ST_ARX_WebServiceClient.QuestionResponse questionResponse = new AGS_ST_ARX_WebServiceClient.QuestionResponse();
        questionResponse.quiz_id  = quizId;
        questionResponse.response = questionsChoices;                     
                            
        AGS_ST_ARX_WebServiceClient.ScoreQuizRequest scoreQuizRequest = new AGS_ST_ARX_WebServiceClient.ScoreQuizRequest();  
        scoreQuizRequest.session_id = sessionId;                
        scoreQuizRequest.question_response = questionResponse;              
        
        AGS_ST_ARX_WebServiceClient wsClient = getWsClient();
        AGS_ST_ARX_WebServiceClient.ScoreQuizResponse scoreQuizResponse = wsClient.scoreQuiz(scoreQuizRequest);    
        System.debug('AGS_ST_ARX_WebServiceClient.ScoreQuizResponse: ' + scoreQuizResponse);
        
        if(scoreQuizResponse == null)
            return null;
                
        this.lastRequest = wsClient.lastRequest;
        this.lastResponse = wsClient.lastResponse;      
        this.lastLevel = 'Score Quiz';
        if(scoreQuizResponse.error != null)
        {
            this.lastRequestStatus = 'Answer questions failed';
            this.error = scoreQuizResponse.error;
        }
        else
        {
            this.lastRequestStatus = 'Answer questions success';
            this.error = '';
        }
        return scoreQuizResponse;
    }
               
    public List<AGS_ST_QuizQuestionWithAnswers> convertToQuizQuestionsWithAnswers(AGS_ST_ARX_WebServiceClient.QuizResponse quizResponse)
    { 
        List<AGS_ST_QuizQuestionWithAnswers> questions = new List<AGS_ST_QuizQuestionWithAnswers>();
        for(integer i=0; i < quizResponse.questions.size(); i++)
        {
            AGS_ST_ARX_WebServiceClient.QuizQuestion qr = quizResponse.questions[i];

            AGS_ST_QuizQuestionWithAnswers questionWithAnswers = new AGS_ST_QuizQuestionWithAnswers();          
            questionWithAnswers.question = qr.text;
            questionWithAnswers.questionId = qr.question_id;
                                            
            questionWithAnswers.answers = new List<SelectOption>();         
            for (integer k = 0; k < qr.choices.size(); k++)
            {                                       
                SelectOption option = new SelectOption(qr.choices[k].id ,qr.choices[k].text);
                questionWithAnswers.answers.add(option);
            }               
            // .....                            
            questions.add(questionWithAnswers);
        }
        return questions;
    }
             
    public List<AGS_ST_ARX_WebServiceClient.QuestionChoice> convertFromQuizQuestionsWithAnswers(List<AGS_ST_QuizQuestionWithAnswers> quizQuestionsWithAnswers)
    {
        List<AGS_ST_ARX_WebServiceClient.QuestionChoice> questionsChoice = new List<AGS_ST_ARX_WebServiceClient.QuestionChoice>();      
        if(quizQuestionsWithAnswers == null)
            return questionsChoice;
            
        for(integer i = 0; i < quizQuestionsWithAnswers.size(); i++)
        {
            AGS_ST_QuizQuestionWithAnswers qa = quizQuestionsWithAnswers[i];
            
            AGS_ST_ARX_WebServiceClient.QuestionChoice qc = new AGS_ST_ARX_WebServiceClient.QuestionChoice();
            qc.question_id = qa.questionId;
            qc.choice_id = qa.choice; 
            
            questionsChoice.add(qc);
        }           
        return questionsChoice; 
    }
        
    private  AGS_ST_ARX_WebServiceClient getWsClient()
    {
        AGS_ST_ARX_WebServiceClient wsClient = new AGS_ST_ARX_WebServiceClient();
        wsClient.wsUrl = stSetting.ARX_Url_gne__c; //'http://dev.sunshine.iassist.com';    
        return wsClient;
    }                   
}