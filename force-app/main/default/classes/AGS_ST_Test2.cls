public with sharing class AGS_ST_Test2 
{
    
    public String run()
    {
        AGS_ST_ARX_WebServiceClient client = new AGS_ST_ARX_WebServiceClient();
        client.wsUrl = 'http://dev.sunshine.iassist.com';
        
        AGS_ST_ARX_WebServiceClient.LoginRequest lr = new AGS_ST_ARX_WebServiceClient.LoginRequest();
        lr.username = 'gene';
        lr.password = 'f0l0wth3wr';
                    
        AGS_ST_ARX_WebServiceClient.LoginResponse loginResponse = client.login(lr);
                                             
        AGS_ST_ARX_WebServiceClient.QuizRequest quizRequest = new AGS_ST_ARX_WebServiceClient.QuizRequest();                        
        quizRequest.session_id = loginResponse.session_id;
        quizRequest.first_name = 'MARY';
        quizRequest.last_name = 'MILLER';
        quizRequest.gender = 'F';
        quizRequest.dob = '07/31/1959';
        quizRequest.ssn = '4994';
        quizRequest.home_address_1 = '51 CHESTNUT ST'; 
        quizRequest.home_city = 'NASHUA';
        quizRequest.home_state = 'IA';
        quizRequest.home_zip = '50658';
    //  quizRequest.home_phone = '';
        
        AGS_ST_ARX_WebServiceClient.QuizResponse quizResponse = client.quiz(quizRequest);                                                           
        String s = quizResponse.dataToString();
    
        return s;   
        
        
    }
            
    
    
    

}