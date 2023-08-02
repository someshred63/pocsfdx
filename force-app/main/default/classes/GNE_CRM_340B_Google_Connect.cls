public with sharing class GNE_CRM_340B_Google_Connect {

    public string valueToShow { get; set; } 
    public Integer noOfEmailsToProcess { get; set; } 
    public Integer noOfAttachmentsToProcess { get; set; } 
    public DateTime VFLastSync { get; set; } 

    public Boolean showAuthorizeApp { get; set; } 
    public Boolean showSaveTokens { get; set; } 
    public Boolean showRetrieveEmails { get; set; } 
    public Boolean showEmailsToProcess { get; set; } 
    public Boolean showAttachmentsToProcess { get; set; } 
    public Boolean showDisconnectApp { get; set; } 
    public Boolean showRetrieveLabels { get; set; } 
    public Boolean showCS { get; set; } 

    private String REDIRECT_URI;

    public string authorizationCode = '';
    public string state = 'gmail';
    public string accessToken;
    public string refreshToken;
    public string expiresIn;
    public string tokenType;

    private Integer retrieveGoogleAccessTokenCode {get; set;}
    private Integer tokenInfoStatusCode {get; set;}
    private Integer refreshTokenStatusCode {get; set;}

    public GNE_MCCO_CRM_340B_Google_Tokens__c gt { get; set; }
    public GTWrapper gtw { get; set; }
    public String url { get; set; }

    private Map<String, Map<String, String>> requestTypeToMessage = new Map<String, Map<String, String>> {
        'TOKEN_RETRIEVE' => new Map<String, String> { 'SUCCESS' => 'AUTHORIZATION PASSED: RETRIVE TOKEN OK', 'INFO' => 'AUTHORIZATION RETRIVE TOKEN NOT PASSED, PLEASE AUTHORIZE APP'},
        'TOKEN_INFO' => new Map<String, String> { 'SUCCESS' => 'AUTHORIZATION PASSED: TOKEN INFO OK', 'INFO' => 'AUTHORIZATION TOKEN INFO NOT PASSED, PLEASE AUTHORIZE APP'},
        'TOKEN_REFRESH' => new Map<String, String> { 'SUCCESS' => 'AUTHORIZATION PASSED: TOKEN REFRESH OK', 'INFO' => 'AUTHORIZATION TOKEN NOT VALID, PLEASE AUTHORIZE APP'},  
        'TOKEN_REVOKE' => new Map<String, String> { 'SUCCESS' => 'TOKEN REVOKE OK', 'ERROR' => 'TOKEN REVOKE ERROR'},
        'TOKEN_SAVED' => new Map<String, String> { 'SUCCESS' => 'TOKEN SAVED OK', 'ERROR' => 'TOKEN SAVED ERROR'}
    };
    private ParametersHandler paramHandler {get; set;}
    private Boolean showCsMode {get; set;}

    public GNE_CRM_340B_Google_Connect() {
        showAuthorizeApp = true;
        showDisconnectApp = false;
        showSaveTokens = false;
        this.paramHandler = new ParametersHandler(System.currentPageReference().getParameters());
        this.authorizationCode = this.paramHandler.getAuthorizationCode();
        this.gt = GNE_CRM_340B_Google_Utlis.getGoogleAccessTokenFromDataBase();
        this.getLastSyncBasedOnRecordInDatabase();
        if(this.paramHandler.getShowCsMode() == 'true') {
            this.setGoogleTokenWrapper();
            this.showAuthorizeApp = false;
            this.showSaveTokens = false;
            this.showDisconnectApp = true;
            this.showRetrieveLabels = false;
            this.showRetrieveEmails = false;
            return;
        } else if (!String.isBlank(this.authorizationCode)) {
            this.retrieveGoogleAccessTokenCode = this.retrieveGoogleAccessToken(authorizationCode);
            this.showAuthorizeApp = false;
            this.showDisconnectApp = true;
            this.setApexPageMessage('TOKEN_RETRIEVE', this.retrieveGoogleAccessTokenCode);
        } else {
            if(gt != null) {
                this.tokenInfoStatusCode = GNE_CRM_340B_Google_Utlis.getAccessTokenInfo(this.gt);
                if(this.tokenInfoStatusCode==200) {
                    this.setApexPageMessage('TOKEN_INFO', this.tokenInfoStatusCode);
                    this.showDisconnectApp = true;
                } else {
                    ApexPages.getMessages().clear();
                    HttpResponse refreshTkRes = GNE_CRM_340B_Google_Utlis.refreshAccessToken(this.gt);
                    this.processRefreshAccessTokenResponse(refreshTkRes);
                    this.refreshTokenStatusCode = refreshTkRes.getStatusCode();
                    this.setApexPageMessage('TOKEN_REFRESH', this.refreshTokenStatusCode);
                }
            }
            showAuthorizeApp = this.tokenInfoStatusCode==200 || this.refreshTokenStatusCode==200 ? false : true;
            showRetrieveEmails = this.tokenInfoStatusCode==200 ? true : false;
            showRetrieveLabels = this.tokenInfoStatusCode==200 ? true : false;
            updateNumerOfEmailsAndAttachments();
        }
        showDisconnectApp = this.showSaveTokens == true || this.showAuthorizeApp == true ? false : true;
        showRetrieveLabels = this.showSaveTokens == true || this.showAuthorizeApp == true ? false : true;
    }

    private void setApexPageMessage(String requestType, Integer statusCode) {

        if(requestType.equalsIgnoreCase('TOKEN_RETRIEVE')) {
            this.setMessage(statusCode, requestTypeToMessage.get('TOKEN_RETRIEVE'));
        } else if(requestType.equalsIgnoreCase('TOKEN_INFO')) {
            this.setMessage(statusCode, requestTypeToMessage.get('TOKEN_INFO'));
        } else if(requestType.equalsIgnoreCase('TOKEN_REFRESH')) {
            this.setMessage(statusCode, requestTypeToMessage.get('TOKEN_REFRESH'));
        }
    }

    private void setMessage(Integer statusCode, Map<String, String> messageTypeToMessageMap) {
        if(statusCode==200) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, statusCode + ': '+ messageTypeToMessageMap.get('SUCCESS')));
        } else {
            if(!String.isEmpty(messageTypeToMessageMap.get('INFO'))) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, statusCode + ': '+ messageTypeToMessageMap.get('INFO')));
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, statusCode + ': '+ messageTypeToMessageMap.get('ERROR')));
            }
        }
    }

    private String getValueFromParameterByKey(String key) {
        return System.currentPageReference().getParameters().get(key);
    }

    private void getLastSyncBasedOnRecordInDatabase() {
        if (gt != null) {
            if (gt.Last_Sync__c != null) {
                VFLastSync = convertLastSyncToDateTime(gt.Last_Sync__c);
            }
        }
    }

    private void setGoogleTokenWrapper() {
        showCS = !String.isBlank(this.getValueFromParameterByKey('showCS'));
        gtw = new GTWrapper(); 
        if (showCS && gt != null) {
            gtw.Name = gt.Name; 
            gtw.AccessToken = gt.Access_Token__c;
            gtw.AuthorizationCode = gt.Authorization_Code__c; 
            gtw.ExpiresIn = gt.Expires_In__c; 
            gtw.Label = gt.Label__c;
            gtw.LabelNames = gt.Label_Names__c;
            gtw.LastSync = gt.Last_Sync__c;
            gtw.NextPage = gt.Next_Page__c;
            gtw.RefreshToken = gt.Refresh_Token__c;
            gtw.TokenType = gt.Token_Type__c;
            gtw.AesKey = gt.Aes_Key__c;
        }
    }

    private void setRedirectURI() {
        REDIRECT_URI = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + Apexpages.currentPage().getUrl();
        if (REDIRECT_URI.contains('?')) {
            REDIRECT_URI = REDIRECT_URI.substringBefore('?');
        }
        url = REDIRECT_URI;
    }

    public void processRefreshAccessTokenResponse(HttpResponse res) {
        if(res.getStatusCode() == 200) {
            map<string, string> jsonValues = new map<string, string>();
            jsonValues = GNE_CRM_340B_Google_Utlis.parseJSONToMap(res.getBody());
            gt.Access_Token__c = jsonValues.get('access_token');
            DateTime dt = system.now().addSeconds(Integer.valueOf(jsonValues.get('expires_in')));
            gt.Expires_In__c = String.valueofGmt(dt);
            
            accessToken = gt.Access_Token__c;
            authorizationCode = gt.Authorization_Code__c;
            expiresIn = gt.Expires_In__c;
            refreshToken = gt.Refresh_Token__c;
            tokenType = gt.Token_Type__c;
            showSaveTokens = true;
        }
    }
    
    private DateTime convertLastSyncToDateTime(String ls) {
        if (String.isBlank(ls)) {
            return null;
        }
        return DateTime.newInstance(Long.valueOf(ls)*1000);
    }

    public Boolean setCustomSettingGoogleTokens(String authCode, String accessToken, String expiresIn, String refreshToken, String tokenType) {
        Blob aeskey = Crypto.generateAesKey(128);
        String aesKeyAsString = EncodingUtil.base64Encode(aesKey);
        Boolean firstTimeToken = false;
        if (gt == null) {
            gt = new GNE_MCCO_CRM_340B_Google_Tokens__c();
            gt.Name = UserInfo.getUserName();
            firstTimeToken = true;
        }
        if (!String.isEmpty(authCode)) {
            gt.Authorization_Code__c = GNE_CRM_340B_Google_Utlis.encriptToken(authCode, aesKeyAsString, UserInfo.getUserId());
        }
        gt.Access_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken(accessToken, aesKeyAsString, UserInfo.getUserId());
        gt.Expires_In__c = expiresIn;
        if (!String.isEmpty(refreshToken)) {
            gt.Refresh_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken(refreshToken, aesKeyAsString, UserInfo.getUserId());
        }
        gt.Token_Type__c = tokenType;
        if (firstTimeToken && String.isEmpty(refreshToken)) {
            return false;
        }
        gt.Aes_Key__c = EncodingUtil.base64Encode(aeskey);
        upsert gt Name;
        return true;
    }

    public PageReference retrieveGoogleAutorizationCode() {
        this.setRedirectURI();
        PageReference pr = new PageReference(
            'https://accounts.google.com/o/oauth2/auth' +
            '?response_type=code' +
            '&client_id=' + GNE_CRM_340B_Google_Utlis.GOOGLE_CLIENT_ID + 
            '&redirect_uri=' + REDIRECT_URI +
            '&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fgmail.readonly' +
            '&state=' + state + 
            '&access_type=offline'
         );         
        return pr;
    }

    public Integer retrieveGoogleAccessToken(String authCode){
        this.setRedirectURI();
        String bodyRequest = '';
        bodyRequest = 'code=' + EncodingUtil.urlEncode(authCode, 'UTF-8');
        bodyRequest += '&client_id=' + EncodingUtil.urlEncode(GNE_CRM_340B_Google_Utlis.GOOGLE_CLIENT_ID, 'UTF-8');
        bodyRequest += '&client_secret=' + EncodingUtil.urlEncode(GNE_CRM_340B_Google_Utlis.GOOGLE_SECRET_CODE, 'UTF-8');
        bodyRequest += '&redirect_uri=' + EncodingUtil.urlEncode(REDIRECT_URI, 'UTF-8');
        bodyRequest += '&grant_type=authorization_code';
        bodyRequest += '&access_type=offline';
        bodyRequest += '&approval_prompt=force';

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        req.setBody(bodyRequest);       
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));  
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        if(res.getStatusCode()==200) {
            map<string, string> jsonValues = new map<string, string>();
            jsonValues = GNE_CRM_340B_Google_Utlis.parseJSONToMap(res.getBody());
            accessToken = jsonValues.get('access_token');
            refreshToken = jsonValues.get('refresh_token');
            DateTime dt = system.now().addSeconds(Integer.valueOf(jsonValues.get('expires_in')));
            expiresIn = String.valueofGmt(dt);
            tokenType = jsonValues.get('token_type');
            showSaveTokens = true;
            showRetrieveLabels = gt != null;
            showAuthorizeApp = false;
        }
        
        return res.getStatusCode();
    }

    public PageReference revokeGoogleAccessToken() {
        try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://accounts.google.com/o/oauth2/revoke?token='+gt.Access_Token__c);
            req.setMethod('GET');
            req.setTimeout(10000);
            HttpResponse res = h.send(req);
            if(res.getStatusCode()==200) {
                ApexPages.getMessages().clear();
                this.setApexPageMessage('TOKEN_REVOKE', res.getStatusCode());
                PageReference pr = new PageReference('/apex/GNE_CRM_340B_Google_Connect');
	            pr.setRedirect(true);
                while(GNE_CRM_340B_Google_Utlis.getAccessTokenInfo(this.gt)==200) {
                    wait(2500);
                }
	            return pr;
            }
            return null;
        } catch(Exception e) {
            return null;
        }
    }

    public PageReference saveTokensInCustomSetting(){    
        Boolean csSaved = setCustomSettingGoogleTokens(authorizationCode, accessToken, expiresIn, refreshToken, tokenType);
        if (csSaved) {
	        showSaveTokens = false;
	        showRetrieveEmails = true;
	        showRetrieveLabels = true;
            showDisconnectApp = true;
            this.setApexPageMessage('TOKEN_SAVED', 200);

        } else {
	        PageReference pr = new PageReference('/apex/GNE_CRM_340B_Google_Connect');
            this.setApexPageMessage('TOKEN_SAVED', 0);
	        pr.setRedirect(true);
	        return pr;
        }
        this.gt = GNE_CRM_340B_Google_Utlis.getGoogleAccessTokenFromDataBase();
        updateNumerOfEmailsAndAttachments();
        return null;
    }   
    
    public PageReference retrieveEmails() {
        if(GNE_CRM_340B_Google_Utlis.getAccessTokenInfo(this.gt) != 200) {
            HttpResponse refreshTkRes = GNE_CRM_340B_Google_Utlis.refreshAccessToken(this.gt);
            this.processRefreshAccessTokenResponse(refreshTkRes);
            return null;
        }
        GNE_CRM_340B_Google_Utlis.retrieveEmails(gt);        
        gt = GNE_CRM_340B_Google_Utlis.getGoogleAccessTokenFromDataBase();
        VFLastSync = convertLastSyncToDateTime(gt.Last_Sync__c);
        updateNumerOfEmailsAndAttachments();
        return null;
    }
    
    private void updateNumerOfEmailsAndAttachments() {
        noOfEmailsToProcess = [ SELECT Id FROM GNE_CRM_340B_Email__c WHERE From__c = NULL AND Username__c = :UserInfo.getUserName() ].size();
        showEmailsToProcess = noOfEmailsToProcess > 0 && showSaveTokens == false && showAuthorizeApp == false;

        noOfAttachmentsToProcess = [ SELECT Id FROM GNE_CRM_340B_Attachment__c WHERE Username__c = :UserInfo.getUserName() ].size();
        showAttachmentsToProcess = noOfAttachmentsToProcess > 0  && showSaveTokens == false && showAuthorizeApp == false;
    }

    
    public PageReference retrieveEmailInfo() {
        if(GNE_CRM_340B_Google_Utlis.getAccessTokenInfo(this.gt) != 200) {
            HttpResponse refreshTkRes = GNE_CRM_340B_Google_Utlis.refreshAccessToken(this.gt);
            this.processRefreshAccessTokenResponse(refreshTkRes);
            return null;
        }
        Integer MAX_EMAILS_PER_REQUEST =  10;
        List<GNE_CRM_340B_Email__c> emailToProcess = [ SELECT Id, Body__c, Date__c, From__c, Message_ID__c, Subject_Line__c, To__c, Username__c FROM GNE_CRM_340B_Email__c WHERE From__c = NULL AND Username__c = :UserInfo.getUserName() LIMIT :MAX_EMAILS_PER_REQUEST ];
        GNE_CRM_340B_Google_Utlis.processEmailInfo(emailToProcess);
        updateNumerOfEmailsAndAttachments();
        return null;
    }
    
    public PageReference retrieveAttachmentInfo() {
        if(GNE_CRM_340B_Google_Utlis.getAccessTokenInfo(this.gt) != 200) {
            HttpResponse refreshTkRes = GNE_CRM_340B_Google_Utlis.refreshAccessToken(this.gt);
            this.processRefreshAccessTokenResponse(refreshTkRes);
            return null;
        }
        Integer MAX_PER_REQUEST = 1;
        List<GNE_CRM_340B_Attachment__c> attToProcess = [ SELECT Id, X340B_Email__c, X340B_Email__r.Message_ID__c, Attachment_ID__c, FileName__c, MIME_Type__c, Username__c FROM GNE_CRM_340B_Attachment__c WHERE Username__c = :UserInfo.getUserName() LIMIT :MAX_PER_REQUEST ];
        GNE_CRM_340B_Google_Utlis.processAttachmentInfo(attToProcess);        
        updateNumerOfEmailsAndAttachments();
        return null;
    }
    
    
    public PageReference retrieveLabels() {
        if(GNE_CRM_340B_Google_Utlis.getAccessTokenInfo(this.gt) != 200) {
            HttpResponse refreshTkRes = GNE_CRM_340B_Google_Utlis.refreshAccessToken(this.gt);
            this.processRefreshAccessTokenResponse(refreshTkRes);
            return null;
        }
        String reqResult = GNE_CRM_340B_Google_Utlis.sendRequest('https://www.googleapis.com/gmail/v1/users/me/labels', '', 'GET', gt.Access_Token__c);
        GNE_CRM_340B_Google_Utlis.GmailLabels labelsList = (GNE_CRM_340B_Google_Utlis.GmailLabels)JSON.deserialize(reqResult, GNE_CRM_340B_Google_Utlis.GmailLabels.class);
        Boolean labelFound = false;
        String csLabels = '';
        String csLabelNames = '';
        for (GNE_CRM_340B_Google_Utlis.GmailLabel label : labelsList.labels) {
            if (label.type == 'user' && label.name.contains('340B')) {
                csLabels += label.Id + '; ';
                csLabelNames += label.name + '; ';
                labelFound = true;
            }
        }
        if (String.isNotBlank(csLabels)) {
            gt.Label__c = csLabels = csLabels.removeEnd('; ');
            gt.Label_Names__c = csLabelNames = csLabelNames.removeEnd('; ');
            gt.Access_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken(gt.Access_Token__c, gt.Aes_Key__c, UserInfo.getUserId());
            gt.Authorization_Code__c = GNE_CRM_340B_Google_Utlis.encriptToken(gt.Authorization_Code__c, gt.Aes_Key__c, UserInfo.getUserId());
            gt.Refresh_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken(gt.Refresh_Token__c, gt.Aes_Key__c, UserInfo.getUserId());
            update gt;
            gt = GNE_CRM_340B_Google_Utlis.getGoogleAccessTokenFromDataBase();
        }
        valueToShow = 'Label was ' + (!labelFound ? 'not' : '') + ' found';
        if (labelFound) {
            valueToShow += ': '+csLabels+ ' ('+csLabelNames+')';
        }
        return null;
    }
    
    public PageReference saveCurrentCS() {
        gt.Name = gtw.Name; 
        gt.Access_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken(gtw.AccessToken, gtw.AesKey, UserInfo.getUserId());
        gt.Authorization_Code__c = GNE_CRM_340B_Google_Utlis.encriptToken(gtw.AuthorizationCode, gtw.AesKey, UserInfo.getUserId());
        gt.Expires_In__c = gtw.ExpiresIn; 
        gt.Label__c = gtw.Label;
        gt.Label_Names__c = gtw.LabelNames;
        gt.Last_Sync__c = gtw.LastSync;
        gt.Next_Page__c = gtw.NextPage;
        gt.Refresh_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken(gtw.RefreshToken, gtw.AesKey, UserInfo.getUserId());
        gt.Token_Type__c = gtw.TokenType;
        update gt;

        PageReference pr = new PageReference('/apex/GNE_CRM_340B_Google_Connect');
        pr.setRedirect(true);
        return pr;            
    }

    public static void wait(Integer millisec) {
        if(millisec == null || millisec < 0) {
            millisec = 0;
        }
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < millisec) {
            finishTime = DateTime.now().getTime();
        }
    }

    public class GTWrapper {
         public String Name  { get; set;}
         public String AccessToken { get; set;}
         public String AuthorizationCode { get; set;}
         public String ExpiresIn { get; set;}
         public String Label { get; set;}
         public String LabelNames { get; set;}
         public String LastSync { get; set;}
         public String NextPage { get; set;}
         public String RefreshToken { get; set;}
         public String TokenType { get; set;}
         public String AesKey {get; set;}
    }

    public class ParametersHandler {

        private Map<String, String> parameters;
        public String authorizationCode {get; private set;}
        public String showCsMode {get; private set;}
        public ParametersHandler(Map<String, String> parametersFromCurrentPage) {
            parameters = parametersFromCurrentPage;

        }
        public ParametersHandler(System.PageReference currentPageReference) {
            this.parameters = currentPageReference.getParameters();
            this.authorizationCode = this.getAuthorizationCode();
            this.showCsMode = this.getShowCsMode();
        }

        public String getAuthorizationCode() {
            return this.getParameterValue('code');
        }

        public String getShowCsMode() {
            return this.getParameterValue('showCS');
        }

        private String getParameterValue(String key) {
            if(!parameters.isEmpty() && parameters.containsKey(key)) {
                return parameters.get(key);
            }
            return '';
        }
    }

}