public with sharing class GNE_CRM_340B_Google_Utlis {
    
    public Static String GOOGLE_CLIENT_ID = GNE_Foun_Misc_Config_Items_gne__c.getInstance('GOOGLE_CLIENT_ID').Configuration_Value_gne__c;
    public Static String GOOGLE_SECRET_CODE = GNE_Foun_Misc_Config_Items_gne__c.getInstance('GOOGLE_SECRET_CODE').Configuration_Value_gne__c;
    
    public Static List<GNE_MCCO_CRM_340B_Google_Tokens__c> refreshSelectedGoogleAccessTokens(Set<String> userSet){
        Map<String, String> userNameToUserIdMap = getUserDetails(userSet);
        List<GNE_MCCO_CRM_340B_Google_Tokens__c> gtList = [ SELECT Id, Name, Access_Token__c, Authorization_Code__c, Expires_In__c, Refresh_Token__c, Token_Type__c, Aes_Key__c FROM GNE_MCCO_CRM_340B_Google_Tokens__c WHERE Name IN :userSet AND Refresh_Token__c != NULL ];
        for (GNE_MCCO_CRM_340B_Google_Tokens__c gtEntry : gtList) {
            if (gtEntry.Expires_In__c <= String.valueofGmt(system.now().addSeconds(-90))) {
                String bodyRequest = '';
                bodyRequest = 'client_id=' + EncodingUtil.urlEncode(GOOGLE_CLIENT_ID, 'UTF-8');
                bodyRequest += '&client_secret=' + EncodingUtil.urlEncode(GOOGLE_SECRET_CODE, 'UTF-8');
                String userId = userNameToUserIdMap.get(gtEntry.Name);
                gtEntry.Refresh_Token__c = decriptToken(gtEntry.Refresh_Token__c, gtEntry.Aes_Key__c, userId);
                bodyRequest += '&refresh_token=' + EncodingUtil.urlEncode(gtEntry.Refresh_Token__c, 'UTF-8');
                bodyRequest += '&grant_type=refresh_token';
                
                String reqResult = GNE_CRM_340B_Google_Utlis.sendRequest('https://accounts.google.com/o/oauth2/token', bodyRequest, 'POST', '');
                map<string, string> jsonValues = new map<string, string>();
                jsonValues = GNE_CRM_340B_Google_Utlis.parseJSONToMap(reqResult);

                if(!jsonValues.containsKey('error')){
                    String initVector = userNameToUserIdMap.get(gtEntry.Name).substring(0, 16);
                    gtEntry.Refresh_Token__c = encriptToken(gtEntry.Refresh_Token__c, gtEntry.Aes_Key__c, initVector); 
                    gtEntry.Access_Token__c = jsonValues.get('access_token');
                    gtEntry.Access_Token__c = encriptToken(gtEntry.Access_Token__c, gtEntry.Aes_Key__c, initVector);
                    DateTime dt = system.now().addSeconds(Integer.valueOf(jsonValues.get('expires_in')));
                    gtEntry.Expires_In__c = String.valueofGmt(dt);
                }
            }
        }
        return gtList;
    }

    public static Map<String, String> getUserDetails(Set<String> userSet) {
        Map<String, String> userNameToIdMapTmp = new Map<String, String>();
        for(User u : [Select Id, Username From User Where Username IN: userSet]) {
            userNameToIdMapTmp.put(u.Username, u.Id);
        }
        return userNameToIdMapTmp;
    }

    public Static void retrieveEmails(GNE_MCCO_CRM_340B_Google_Tokens__c gt) {
        retrieveEmails(new List<GNE_MCCO_CRM_340B_Google_Tokens__c>{gt}, false);
    }
    
    public Static void retrieveEmails(List<GNE_MCCO_CRM_340B_Google_Tokens__c> gtList, Boolean isBatchMode) {
        String MAX_EMAILS_PER_REQUEST = '500';     
        Set<String> userNames = new Set<String>();
        for (GNE_MCCO_CRM_340B_Google_Tokens__c gt : gtList) {
            userNames.add(gt.Name);
        }
        List<User> userList = [ SELECT Id, Username FROM User WHERE Username IN :userNames ];
        Map<String, Id> userMap = new Map<String, Id>();
        for (User u : userList) {
            userMap.put(u.Username, u.Id);
        }
        List<GNE_CRM_340B_Email__c> emailToInsert = new List<GNE_CRM_340B_Email__c>();
        for (GNE_MCCO_CRM_340B_Google_Tokens__c gt : gtList) {
	        gt.Last_Sync__c = gt.Last_Sync__c != null ? gt.Last_Sync__c : '';
	        gt.Next_Page__c = gt.Next_Page__c != null ? gt.Next_Page__c : '';
	        string endPointValue = 'https://www.googleapis.com/gmail/v1/users/me/messages';
	        endPointValue += '?maxResults='+MAX_EMAILS_PER_REQUEST;
	        if (String.isNotEmpty(gt.Last_Sync__c)) {
	            endPointValue += '&q=after:'+gt.Last_Sync__c;
	        }
	        if (String.isNotEmpty(gt.Next_Page__c)) {
	            endPointValue += '&pageToken='+gt.Next_Page__c;
	        }
	        String reqResult = '';
            if(isBatchMode) {
                String accessToken = decriptToken(gt.Access_Token__c, gt.Aes_Key__c, userMap.get(gt.Name));
                reqResult = GNE_CRM_340B_Google_Utlis.sendRequest(endPointValue, '', 'GET', accessToken);
            } else {
                reqResult = GNE_CRM_340B_Google_Utlis.sendRequest(endPointValue, '', 'GET', gt.Access_Token__c);
            }

            GNE_CRM_340B_Google_Utlis.GmailEmails emailsList = (GNE_CRM_340B_Google_Utlis.GmailEmails)JSON.deserialize(reqResult, GNE_CRM_340B_Google_Utlis.GmailEmails.class);
            Id ownerId = userMap.get(gt.Name);
	        if (emailsList.messages != null) {
	            for (GNE_CRM_340B_Google_Utlis.GmailEmail email : emailsList.messages) {
	                
	                emailToInsert.add(
	                    new GNE_CRM_340B_Email__c(
	                        Message_ID__c = email.id,
	                        Thread_ID__c = email.threadId,
	                        Username__c = gt.Name,
	                        OwnerId = ownerId
	                    )
	                );
	            }
	        
	            if (String.isBlank(emailsList.nextPageToken)) {
	                gt.Last_Sync__c = String.valueOf(DateTime.now().getTime()/1000);
	                gt.Next_Page__c = '';
	            } else {
	                gt.Next_Page__c = emailsList.nextPageToken;
	            } 
	        } else {
	            gt.Last_Sync__c = String.valueOf(DateTime.now().getTime()/1000);
	            gt.Next_Page__c = '';
	        }
            if(!isBatchMode) {
                gt.Access_Token__c = encriptToken(gt.Access_Token__c, gt.Aes_Key__c, UserInfo.getUserId());
                gt.Authorization_Code__c = encriptToken(gt.Authorization_Code__c, gt.Aes_Key__c, UserInfo.getUserId());
                gt.Refresh_Token__c = encriptToken(gt.Refresh_Token__c, gt.Aes_Key__c, UserInfo.getUserId());       
            }
        }
        
        if (!gtList.isEmpty()) {
            update gtList;
        }

        if (!emailToInsert.isEmpty()) {
            upsert emailToInsert Message_ID__c;
        }
    }
    
    
    public Static void retrieveEmailsInLabels(List<GNE_MCCO_CRM_340B_Google_Tokens__c> gtList) {

        String MAX_EMAILS_PER_REQUEST = '500';
              
        Set<String> userNames = new Set<String>();
        for (GNE_MCCO_CRM_340B_Google_Tokens__c gt : gtList) {
            userNames.add(gt.Name);
        }
        
        List<User> userList = [ SELECT Id, Username FROM User WHERE Username IN :userNames ];
        Map<String, Id> userMap = new Map<String, Id>();
        for (User u : userList) {
            userMap.put(u.Username, u.Id);
        }
        
        List<GNE_CRM_340B_Email__c> emailToUpdate = new List<GNE_CRM_340B_Email__c>();
        Set<String> messageIDs = new Set<String>();
        for (GNE_MCCO_CRM_340B_Google_Tokens__c gt : gtList) {
            string endPointValue = 'https://www.googleapis.com/gmail/v1/users/me/messages';
            endPointValue += '?maxResults='+MAX_EMAILS_PER_REQUEST;
            endPointValue += '&q=after:'+String.valueOf((DateTime.now().getTime()/1000)-(60*60*24*30));
            if (String.isNotEmpty(gt.Label__c)) {
                endPointValue += '&labelIds='+gt.Label__c.replace('; ', ',').removeEnd(',');
            }
            String accessToken = GNE_CRM_340B_Google_Utlis.decriptToken(gt.Access_Token__c, gt.Aes_Key__c, userMap.get(gt.Name));
            String reqResult = GNE_CRM_340B_Google_Utlis.sendRequest(endPointValue, '', 'GET', accessToken);
            GNE_CRM_340B_Google_Utlis.GmailEmails emailsList = (GNE_CRM_340B_Google_Utlis.GmailEmails)JSON.deserialize(reqResult, GNE_CRM_340B_Google_Utlis.GmailEmails.class);
            Id ownerId = userMap.get(gt.Name);
            if (emailsList.messages != null) {
                for (GNE_CRM_340B_Google_Utlis.GmailEmail email : emailsList.messages) {
                    messageIDs.add(email.id);
                }
            }
        }
        
        if (!gtList.isEmpty()) {
            update gtList;
        }

        if (!messageIDs.isEmpty()) {
            List<GNE_CRM_340B_Email__c> emailsWithLabels = [ SELECT Id, Message_ID__c, Inactive__c FROM GNE_CRM_340B_Email__c WHERE Message_ID__c IN :messageIDs AND Inactive__c = true ];
            for (GNE_CRM_340B_Email__c e : emailsWithLabels) {
                emailToUpdate.add(
                    new GNE_CRM_340B_Email__c(
                        Id = e.Id,
                        To__c = '',
                        From__c = '',
                        Inactive__c = false
                    )
                );
            }
            
            if (!emailToUpdate.isEmpty()) {
                update emailToUpdate;
            }
        }
    }
    
    public Static void processEmailInfo(List<GNE_CRM_340B_Email__c> emailToProcess) {
        
        Integer MAX_ATTACHMENT_SIZE = 5000000;
        
        Set<String> userNames = new Set<String>();
        for(GNE_CRM_340B_Email__c e: emailToProcess) {
            userNames.add(e.Username__c);
        }
        Map<String, String> userNameToUserIdMap = getUserDetails(userNames);

        List<GNE_CRM_340B_Attachment__c> attachmentList = new List<GNE_CRM_340B_Attachment__c>();
        for (GNE_CRM_340B_Email__c e : emailToProcess) {
            GNE_MCCO_CRM_340B_Google_Tokens__c gtEntry = getGoogleTokens(e.Username__c);
            String accessToken = decriptToken(gtEntry.Access_Token__c, gtEntry.Aes_Key__c, userNameToUserIdMap.get(gtEntry.Name));
            if (gtEntry != null) {
                String reqResult = GNE_CRM_340B_Google_Utlis.sendRequest('https://www.googleapis.com/gmail/v1/users/me/messages/'+e.Message_ID__c, '', 'GET', accessToken);
                GNE_CRM_340B_Google_Utlis.GmailEmailInfo emailsListInfo = (GNE_CRM_340B_Google_Utlis.GmailEmailInfo)JSON.deserialize(reqResult, GNE_CRM_340B_Google_Utlis.GmailEmailInfo.class);
                if (emailsListInfo != null && emailsListInfo.payload != null) {
                    e.Date__c = GNE_CRM_340B_Google_Utlis.getHeaderField(emailsListInfo, 'Date');
                    e.From__c = GNE_CRM_340B_Google_Utlis.getHeaderField(emailsListInfo, 'From');
                    if (emailsListInfo.labelIds != null && emailsListInfo.labelIds.size() > 0) {
                        e.Labels__c = String.join(emailsListInfo.labelIds, '; ');
                    }
                    String subjectFromHeader = GNE_CRM_340B_Google_Utlis.getHeaderField(emailsListInfo, 'Subject');
                    e.Subject_Line__c = subjectFromHeader.length() > 255 ? subjectFromHeader.substring(0, 255) : subjectFromHeader;
                    e.To__c = GNE_CRM_340B_Google_Utlis.getHeaderField(emailsListInfo, 'To');
                    if (e.To__c.length()>254) {
                        e.To__c = e.To__c.substring(0, 254);
                    }
                    e.User_Labels__c = gtEntry.Label__c;
                    
                    String bodyContentText = '';
                    String bodyContentHTML = '';
                    
                    if (emailsListInfo.payload.parts != null) {
	                    for (GNE_CRM_340B_Google_Utlis.GmailPart part : emailsListInfo.payload.parts) {
	                        if (part.parts != null) {
	                            for (GNE_CRM_340B_Google_Utlis.GmailPart insidePart : part.parts) {
	                                String mimeType = insidePart.mimeType;
	                                String bodyContent = GNE_CRM_340B_Google_Utlis.geBodyField(insidePart);
		                            if (bodyContent == null) {
		                                bodyContent = '';
		                            }	                                
	                                if (mimeType == 'text/plain') {
	                                    bodyContent = bodyContent.replace('-', '+').replace('_', '/');
	                                    bodyContent = EncodingUtil.base64Decode(bodyContent).toString();
	                                    bodyContentText += bodyContent;
	                                } else if (mimeType == 'text/html') {
	                                    bodyContent = bodyContent.replace('-', '+').replace('_', '/');
	                                    bodyContent = EncodingUtil.base64Decode(bodyContent).toString();
	                                    bodyContentHTML += bodyContent;
	                                }
	                            }
	                        }
	                        
	                        String mimeType = part.mimeType;
	                        String bodyContent = GNE_CRM_340B_Google_Utlis.geBodyField(part);
	                        if (bodyContent == null) {
	                            bodyContent = '';
	                        }
	                        
	                        if (mimeType == 'text/plain' && part.filename == '') {
	                            bodyContent = bodyContent.replace('-', '+').replace('_', '/');
	                            bodyContent = EncodingUtil.base64Decode(bodyContent).toString();
	                            bodyContentText += bodyContent;
	                        } else if (mimeType == 'text/html' && part.filename == '') {
	                            bodyContent = bodyContent.replace('-', '+').replace('_', '/');
	                            bodyContent = EncodingUtil.base64Decode(bodyContent).toString();
	                            bodyContentHTML += bodyContent;
	                        } else if ((mimeType.contains('application/') || mimeType.contains('image/') || mimeType.contains('text/')) && (part.filename != '') && part.body.size < MAX_ATTACHMENT_SIZE) {
	                            attachmentList.add(
	                                new GNE_CRM_340B_Attachment__c(
	                                    X340B_Email__c = e.Id,
	                                    Attachment_ID__c = part.body.attachmentId,
	                                    MIME_Type__c = mimeType,
	                                    FileName__c = part.filename,
	                                    Username__c = gtEntry.Name
	                                )
	                            );
	                        } 
	                    }                        
                    } else if (emailsListInfo.payload.parts == null && emailsListInfo.payload.body != null) {
                        String mimeType = 'text/plain';
                        String bodyContent = emailsListInfo.payload.body.data;
                        if (bodyContent == null) {
                            bodyContent = '';
                        }                        
                        bodyContent = bodyContent.replace('-', '+').replace('_', '/');
                        bodyContent = EncodingUtil.base64Decode(bodyContent).toString();
                        bodyContentText += bodyContent;
                        bodyContentHTML += bodyContent;
                        if (emailsListInfo.payload.body.attachmentId != null && emailsListInfo.payload.body.size < MAX_ATTACHMENT_SIZE) {
                            attachmentList.add(
                                new GNE_CRM_340B_Attachment__c(
                                    X340B_Email__c = e.Id,
                                    Attachment_ID__c = emailsListInfo.payload.body.attachmentId,
                                    MIME_Type__c = emailsListInfo.payload.mimeType,
                                    FileName__c = emailsListInfo.payload.filename,
                                    Username__c = gtEntry.Name
                                )
                            );
                        }
                    }

                    if (bodyContentText.length()>64000) {
                        bodyContentText = bodyContentText.substring(0, 64000);
                    }
                    if (bodyContentHTML.length()>64000) {
                        bodyContentHTML = bodyContentHTML.substring(0, 64000);
                    }
                    e.Body__c = bodyContentText;
                    e.Body_HTML__c = bodyContentHTML;
                }
            }
        }

        update emailToProcess;
        
        if (!attachmentList.isEmpty()) {
            Database.insert(attachmentList, false);
        }

    }

    public Static void processAttachmentInfo(List<GNE_CRM_340B_Attachment__c> attToProcess) {
        List<Attachment> attachmentList = new List<Attachment>();

        Set<String> userNames = new Set<String>();
        for(GNE_CRM_340B_Attachment__c e: attToProcess) {
            userNames.add(e.Username__c);
        }
        Map<String, String> userNameToUserIdMap = getUserDetails(userNames);

        for (GNE_CRM_340B_Attachment__c att : attToProcess) {
            GNE_MCCO_CRM_340B_Google_Tokens__c gtEntry = getGoogleTokens(att.Username__c);
            if (gtEntry != null) {
                String accessToken = decriptToken(gtEntry.Access_Token__c, gtEntry.Aes_Key__c, userNameToUserIdMap.get(gtEntry.Name));
	            String reqResult = GNE_CRM_340B_Google_Utlis.sendRequest('https://www.googleapis.com/gmail/v1/users/me/messages/'+att.X340B_Email__r.Message_ID__c+'/attachments/'+att.Attachment_ID__c, '', 'GET', accessToken);
	            GNE_CRM_340B_Google_Utlis.GmailAttachment attListInfo = (GNE_CRM_340B_Google_Utlis.GmailAttachment)JSON.deserialize(reqResult, GNE_CRM_340B_Google_Utlis.GmailAttachment.class);
	            if (attListInfo != null && attListInfo.data != null) {
	                attachmentList.add(
	                    new Attachment(
	                        ParentId = att.X340B_Email__c,
	                        ContentType = att.MIME_Type__c,
	                        Name = att.FileName__c,
	                        Body = EncodingUtil.base64Decode(attListInfo.data.replace('-', '+').replace('_', '/'))
	                    )
	                );
	            }
            }
        }
        
        if (!attachmentList.isEmpty()) {
            insert attachmentList;
            delete attToProcess;
        }
    }

    public Static GNE_MCCO_CRM_340B_Google_Tokens__c getGoogleTokens(String username) {
        GNE_MCCO_CRM_340B_Google_Tokens__c gtEntry = GNE_MCCO_CRM_340B_Google_Tokens__c.getInstance(username);
        return gtEntry;
    }

    public Static GNE_MCCO_CRM_340B_Google_Tokens__c getGoogleAccessTokenFromDataBase() {
        GNE_MCCO_CRM_340B_Google_Tokens__c gtTmp = getGoogleTokens(UserInfo.getUserName());
        if(gtTmp != null) {
            gtTmp.Authorization_Code__c = GNE_CRM_340B_Google_Utlis.decriptToken(gtTmp.Authorization_Code__c, gtTmp.Aes_Key__c, UserInfo.getUserId());
            gtTmp.Access_Token__c = GNE_CRM_340B_Google_Utlis.decriptToken(gtTmp.Access_Token__c, gtTmp.Aes_Key__c, UserInfo.getUserId());
            gtTmp.Refresh_Token__c = GNE_CRM_340B_Google_Utlis.decriptToken(gtTmp.Refresh_Token__c, gtTmp.Aes_Key__c, UserInfo.getUserId());
        }
        return gtTmp;
    }

    public Static GNE_MCCO_CRM_340B_Google_Tokens__c getOldestGoogleTokens() {
        List<GNE_MCCO_CRM_340B_Google_Tokens__c> gtList = GNE_MCCO_CRM_340B_Google_Tokens__c.getall().values();
        if (gtList.size()>0) {
            GNE_MCCO_CRM_340B_Google_Tokens__c oldestGT = gtList.get(0);    
            for (GNE_MCCO_CRM_340B_Google_Tokens__c gt : gtList) {
                if (gt.Last_Sync__c != null) {
                    if (gt.Last_Sync__c < oldestGT.Last_Sync__c) {
                        oldestGT = gt;                        
                    }
                } else {
                    return gt;
                }
            }
            return oldestGT;
        }
        return null;
    }

    public Static String sendRequest(String endpoint, String bodyRequest, String method, String accessToken) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        if (method == 'GET') {
            req.setHeader('Authorization', 'Bearer ' + accessToken);
        }
        if (String.isNotBlank(bodyRequest)) {
            req.setBody(bodyRequest);       
            req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));  
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        } else {
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        }
        req.setMethod(method);
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        return res.getBody();
    }

    public Static Map<string, string> parseJSONToMap(string JSONValue){
        JSONParser parser = JSON.createParser(JSONValue);
        map<string, string> jsonMap = new map<string, string>();
        string keyValue = '';
        string tempValue = '';
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                keyValue = parser.getText();
                parser.nextToken();
                tempValue = parser.getText();
                jsonMap.put(keyValue, tempValue);               
            }
        }
        return jsonMap;
    }
    
    
    /* methods to parse Gmail resposnes  */
    public Static String getHeaderField(GmailEmailInfo email, String field) {
        for (GmailHeader h : email.payload.headers) {
            if (h.name == field) {
                return h.value;
            }
        }
        return '';
    }

    public static Integer getAccessTokenInfo(GNE_MCCO_CRM_340B_Google_Tokens__c gt) {
        try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/oauth2/v2/tokeninfo?access_token='+gt.Access_Token__c);
            req.setMethod('GET');
            req.setTimeout(10000);
            HttpResponse res = h.send(req);
            return res.getStatusCode();
        } catch(Exception e) {
            return 0;
        }
    }

    public static HttpResponse refreshAccessToken(GNE_MCCO_CRM_340B_Google_Tokens__c gt) {
        String GOOGLE_CLIENT_ID = GNE_CRM_340B_Google_Utlis.GOOGLE_CLIENT_ID;
        String GOOGLE_SECRET_CODE = GNE_CRM_340B_Google_Utlis.GOOGLE_SECRET_CODE;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;

        if(!String.isBlank(gt.Refresh_Token__c)) {
            String bodyRequest = '';
            bodyRequest = 'client_id=' + EncodingUtil.urlEncode(GOOGLE_CLIENT_ID, 'UTF-8');
            bodyRequest += '&client_secret=' + EncodingUtil.urlEncode(GOOGLE_SECRET_CODE, 'UTF-8');
            bodyRequest += '&refresh_token=' + EncodingUtil.urlEncode(gt.Refresh_Token__c, 'UTF-8');
            bodyRequest += '&grant_type=refresh_token';

            req.setEndpoint('https://www.googleapis.com/oauth2/v4/token');
            req.setBody(bodyRequest);
            req.setHeader('Content-length', string.ValueOf(bodyRequest.length())); 
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setMethod('POST');
            req.setTimeout(10000);
            res = h.send(req);
        }
        return res;
    }

    public Static String getPartHeaderField(GmailPart part) {
        for (GmailHeader h : part.headers) {
            if (h.name == 'Content-Transfer-Encoding') {
                return h.value;
            }
        }
        return '';
    }
    
    public Static String geBodyField(GmailPart part) {
        return part.body.data;
    }

    public static String encriptToken(String token, String aesKey, String initVector) {
        if(!String.isBlank(token) && !String.isBlank(aesKey) && !String.isBlank(initVector)) {
            Blob initVectorAsBlob = Blob.valueOf(initVector.substring(0, 16));
            Blob aesKeyAsBlob = EncodingUtil.base64Decode(aesKey);
            Blob data = Blob.valueOf(token);
            Blob encryptedToken = Crypto.encrypt('AES128', aesKeyAsBlob, initVectorAsBlob, data);
            return EncodingUtil.base64Encode(encryptedToken);
        } 
        return '';
    }

    public static String decriptToken(String token, String aesKey, String userId) {
        try{
            if(!String.isBlank(token) && !String.isBlank(aesKey) && !String.isBlank(userId)) {
                Blob initVector = Blob.valueOf(userId.substring(0, 16));
                Blob key = EncodingUtil.base64Decode(aesKey);
                Blob tokenAsBlob = EncodingUtil.base64Decode(token);
                Blob decrypted = Crypto.decrypt('AES128', key, initVector, tokenAsBlob);
                return decrypted.toString();
            }
        } catch(Exception e) {
            System.debug('Exception: ' + e);
        }
        return token;
    }
    
    /* public classes to handle Gmail responses */
    public class GmailLabels {
         public List<GmailLabel> labels;
    }
    
    public class GmailLabel {
         public String id; 
         public String name; 
         public String messageListVisibility; 
         public String labelListVisibility; 
         public String type; 
    }

    public class GmailEmails {
         public List<GmailEmail> messages;
         public String nextPageToken;
         public Decimal resultSizeEstimate;
    }
    
    public class GmailEmail {
         public String id; 
         public String threadId; 
    }
    
    public class GmailHeader {
         public String name; 
         public String value; 
    }

    public class GmailBody {
         public String attachmentId; 
         public Integer size; 
         public String data; 
    }
    
    public class GmailPart {
         public String partId; 
         public String mimeType; 
         public String filename;
         public List<GmailHeader> headers; 
         public GmailBody body;
         public List<GmailPart> parts;
    }
    
    public class GmailPayload {
         public String partId; 
         public String mimeType; 
         public String filename; 
         public List<GmailHeader> headers; 
         public GmailBody body; 
         public List<GmailPart> parts; 
    }
    
    public class GmailEmailInfo {
         public String id; 
         public String threadId;
         public List<String> labelIds;
         public String snippet;
         public String historyId;
         public String internalDate;
         public GmailPayload payload;
         public Integer sizeEstimate;
    }
    
    public class GmailAttachment {
         public String size; 
         public String data;
    }
}