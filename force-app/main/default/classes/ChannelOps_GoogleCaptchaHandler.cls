/**********************************************************************
Purpose: ChannelOps_SpoilageRequestCOD_Controller class is used to save 
         the signed COD form site.
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      Vijay       09/19/2019      INITIAL DEVELOPMENT
***********************************************************************/
public class ChannelOps_GoogleCaptchaHandler {
    private String publicKey;
    private String privateKey;
    private String baseUrl;
    //public String testMS {set; get;}
    
    public ChannelOps_GoogleCaptchaHandler(String  publicKey, String privateKey, String baseUrl){
        this.publicKey = publicKey;
        this.privateKey = privateKey;
        this.baseUrl = baseUrl;
    }
   
    public boolean verifyCaptcha(String response){
        System.debug('response----'+response);
        Boolean verified = false;
        if ( String.isBlank(response)) {
            return false;
        }
        String urlbody='secret=' + privateKey + '&response='  +  response;
        HttpResponse r = makeRequest(baseUrl, urlbody);
        
        if ( r!= null ){            
            // Parse JSON response to get all the totalPrice field values.
           JSONParser parser = JSON.createParser(r.getBody());           
           while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'success')) {
                // Get the value.
                parser.nextToken();
                if(parser.getText()=='true'){
                    verified = true;
                }
            }
          }
        }else {
            return false;
        }        
		return verified;
    }
    
    private HttpResponse makeRequest(string url, string body){
       // String tempurl='https://www.google.com/recaptcha/api/siteverify?secret=6LcPp20UAAAAAMowSOP8dB842maumm9JPNXcTMl2&response=03AHqfIOmyWq5nnqEyR5ZDjY9-fpRYOIf0j-MQg8Nk2L7KLOckbsKKfbWeeUFqTZxHGiFHpw6jRFINZ4ZDHkbTzqo6NmJays1KWvZGtjv9LA1EfM70YxLCgkpAH3bXmV5YGO9XaI8cJR_vsnoKO7Peoxe4NvbmDEz7lQfKWBEfthGO_e_xiwg-H76EszjV8Jk7Wva8zvTtsc-ikYqUPLiG5js0QzVU28IjUMWgLOWEe2uFchSLLakVqnffS_MN-IubSPV1ubbQBxEhnx8nP7muIoxN7YDoBVpZWETucsOAwv-T146qoWT6Ikc';
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
    
    private String remoteHost{
        get {
            String ret = '127.0.0.1';
            // also could use x-original-remote-host
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    } 
}