public class AGS_ST_ARX_Verification_HD_gne
{
    public String agsStUserId;
    public String acctId;
    public String ihcpUserId;
    public String userId;
    private List<ResponseRequest> wsLogItems = null;
    public List<AGS_ST_QuizQuestionWithAnswers> questions{get; set;}
    public String assistRxSessionId {get; private set;}
    public String quizId {get; set;}
    public Boolean questionRefreshed{get;set;}

    public PageReference assistRxVerificationLoadData()
    {
        questionRefreshed = true;
        agsStUserId = ApexPages.currentPage().getParameters().get('agsstuserid');
        acctId =  ApexPages.currentPage().getParameters().get('accountId');
        ihcpUserId = ApexPages.currentPage().getParameters().get('ihcpUserId');
        AGS_ST_User user;
        try
        {          
            System.debug('Parameter agsStUserId='+agsStUserId+' loaded');
            user = AGS_ST_DbUtils.findRegistrationUserData(agsStUserId);
            system.debug('### User found (X1): ' + user);
            userId = AGS_ST_DbUtils.findUserIdByEmail(user.email);  // where username = email
            if(user == null)
            {
                System.debug('AGS ST User not found: ' + agsStUserId);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unknown user!'));
                return null;
            }           
        }
        catch (Exception e)
        {
            System.debug(e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No AGS ST User while preparing to AssistRx service!'));
            return null;      
        }
        this.wsLogItems = new List<ResponseRequest>();                                              
        AGS_ST_ARX_WsHelper wsHelper = new AGS_ST_ARX_WsHelper();       
        AGS_ST_ARX_WebServiceClient.LoginResponse loginResponse = wsHelper.arxRequestLogIn(); 
        addLogItem(wsHelper);  
        if(loginResponse.error != null)
        {
            // removed 06/27/13 
            //AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'ARX_LOGIN_REQUEST_FAILED.');
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, loginResponse.error));
            logWsItems();
            return null;
        }  
        this.assistRxSessionId = loginResponse.session_id;
        AGS_ST_ARX_WsHelper wsHelperQuiz = new AGS_ST_ARX_WsHelper(); 
        AGS_ST_ARX_WebServiceClient.QuizResponse quizResponse = wsHelperQuiz.arxRequestQuiz(this.assistRxSessionId, user);
        addLogItem(wsHelperQuiz);
        logWsItems();   
        if(quizResponse.error != null)
        {
            // removed 06/27/13 
            //AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'ARX_QUIZ_REQUEST_FAILED.');  
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, quizResponse.error));  
        }
        if(quizResponse.is_identified == 'Y' && quizResponse.error == null)
        {
            System.debug('Quiz data retrieved.');                       
            this.questions = wsHelperQuiz.convertToQuizQuestionsWithAnswers(quizResponse);
            this.quizId = quizResponse.quiz_id;
        }   
        return null;
    }
    
    public PageReference assistRxVerificationCheck()
    { 
        questionRefreshed = false;
        AGS_ST_User_gne__c tmpStUser = null;
        tmpStUser = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);  
        AGS_ST_ARX_WsHelper wsHelper = new AGS_ST_ARX_WsHelper();   
        List<AGS_ST_ARX_WebServiceClient.QuestionChoice> questionsChoices = wsHelper.convertFromQuizQuestionsWithAnswers(this.questions);                           
        List<ResponseRequest> wsLogItems = new List<ResponseRequest>();     
        AGS_ST_ARX_WebServiceClient.ScoreQuizResponse scoreQuizResponse = wsHelper.arxRequestScoreQuiz(this.assistRxSessionId, this.quizId, questionsChoices);
        addLogItem(wsHelper);
        logWsItems();
        if(scoreQuizResponse.error == null && scoreQuizResponse.quiz_status == 'PASS')
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Quiz passed!'));            
        }       
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quiz failed. You have to refresh questions and check again.'));
        }
        return null;
    }

    private void addLogItem(AGS_ST_ARX_WsHelper wsHelper)
    {
        ResponseRequest rr = new ResponseRequest();
        rr.request = wsHelper.lastRequest;
        rr.response = wsHelper.lastResponse;
        rr.status = wsHelper.lastRequestStatus;
        rr.level = wsHelper.lastLevel;
        rr.error = wsHelper.error;
        this.wsLogItems.add(rr);
    }
    
    private void logWsItems()
    {
        for(integer i=0; i< this.wsLogItems.size(); i++)
        {
            ResponseRequest rr = this.wsLogItems[i];            
            AGS_ST_DbUtils.insertAssistRxManagement(this.agsStUserId, rr.level, rr.error, rr.status, rr.request, rr.response);
        }
    }       
        
    private class Message
    {
        String text {get; set;}
    }
    
    private class ResponseRequest
    {
        String response {get; set;}
        String request {get; set;}
        String status {get; set;}
        String level {get; set;}
        String error {get; set;}
    }
}