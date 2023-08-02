public class SCM_BatchFaxpoll {
public boolean istest = false;
private string ptoken;
private string pObjectUrl;

public string ObjectUrl{
    get{
        if (pObjectUrl == null){
            pObjectUrl = SCM_Security.getEnvironmentVariable('SCM_ObjectRestURL');
        }
        return pObjectUrl;
    }
    
}

public string Token{get{
        if (ptoken == null){
            GetToken();
            
        }
        return ptoken;
    }
}


public string GetToken(){
    
    
    
        HttpRequest req = new HttpRequest(); 
            
                String url = 'https://na15.salesforce.com/services/Soap/u/18.0/'+UserInfo.getOrganizationId();
                    if (ApexPages.currentPage() != null){
                            url= 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/18.0/'+UserInfo.getOrganizationId();
                    }
                                req.setHeader('Accept', 'application/json');
                                req.setHeader('content-type', 'application/x-www-form-urlencoded'); 
                                req.setEndpoint('https://' + SCM_Security.getEnvironmentVariable('SCM_AuthRestURL') + '/oauth/201309/token/sfaccesstoken');   
                                req.setMethod('POST');
                                req.setBody('SFSession=' + UserInfo.getSessionId() + '|' + EncodingUtil.urlEncode(url, 'UTF-8') + '&ClientId=' + SCM_Security.getEnvironmentVariable('SCM_ClientID')+ '&ClientSecret=' + SCM_Security.getEnvironmentVariable('SCM_ClientSecret'));
                                    
                                Http http = new Http();
                                         
                                 //Execute web service call here      
                                if (!Test.isRunningTest()){
                                        HTTPResponse res = http.send(req);   
                                        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());            
                                        ptoken = string.ValueOf(m.get('AccessTokenValue'));
                                        return ptoken;               
                                                                                                
                                 }
                                 else {
                                        return 'test passed';
                                 }
}
public string complete {

      get {
          return '';
      }
      set { complete = value; }
   } 
   
  
}