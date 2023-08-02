@RestResource(urlMapping='/FCR/detectUser/*')
global class FCR_DetectUser {
    public static final Map<String, GNE_PeepsAPI_Config__c> peepsConfig = GNE_PeepsAPI_Config__c.getAll();
    private static final String ERROR_MISSING_CONF = 'Missing configuration for {0}, please contact with admin.';
    
    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String searchText, String googleId) {
        return iPhone_Commons_gne.buildResponse(
            new GetUserPeepsStructureResponseBuilder(),
            new RequestArgs(lastSyncDate,  getUnixId(), searchText, googleId)            
        );
    }
    
    private static String getUnixId() {
        return [SELECT External_Id_gne__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].External_Id_gne__c;
    }
    
     class GetUserPeepsStructureResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args) {
            RequestArgs reqArgs = (RequestArgs)args;
            ResData responseData = callPeepsApiUsersStructure(reqArgs.googleId, reqArgs.searchText );
            //process on SF side googleId only for login initLoad
            if(responseData.peepResCode == 200) {
                if(responseData.totalRows > 0 && reqArgs.googleId != null){
                    FCR_UserPeepsStructure ups = responseData.results[0];
                    List<FCR_Peep_gne__c> toUpsert = new List<FCR_Peep_gne__c>();
                    FCR_Peep_gne__c peepForProcess = FCR_UserPeepsStructure.createPeepEntry(ups);
                    
                    if([SELECT UserUnixId__c, Manager_gne__c FROM FCR_Peep_gne__c WHERE Google_Id_gne__c = :reqArgs.googleId ].isEmpty()) {
                        peepForProcess.Do_Not_Delete__c = true;
                    }
                    toUpsert.add(peepForProcess);
                    //logic to create peeps entry for manager
                    if(peepForProcess.Manager_gne__c != null && [SELECT UserUnixId__c, Manager_gne__c FROM FCR_Peep_gne__c WHERE UserUnixId__c = :peepForProcess.Manager_gne__c  ].isEmpty()) {
                        
                        ResData responseDataManager  = callPeepsApiUsersStructure(peepForProcess.Manager_gne__c, null);
                        FCR_UserPeepsStructure manager = responseDataManager.results[0];
                        FCR_Peep_gne__c peepManager = FCR_UserPeepsStructure.createPeepEntry(manager);
                        peepManager.Do_Not_Delete__c = true;
                        toUpsert.add(peepManager);
                    }                    
                    
                    Database.upsert(toUpsert, FCR_Peep_gne__c.UserUnixId__c, true);
                } 
                
            } else { //logic to query SF DB in case the Peep service not working
                List<FCR_UserPeepsStructure> upss = new List<FCR_UserPeepsStructure>();
                if(reqArgs.googleId != null){
                    for(FCR_Peep_gne__c peep :[
                        SELECT First_Name_gne__c, Last_Name_gne__c, Google_Id_gne__c, UserUnixId__c, Job_Title_gne__c, Manager_gne__c, Email_gne__c, Mobile_Phone_Number_gne__c, Phone_Number_gne__c, Location_gne__c
                        FROM FCR_Peep_gne__c WHERE Google_Id_gne__c=:reqArgs.googleId
                    ]) {
                        upss.add(createRespStructure(peep));
                    }
                } else {
                    String searchTxt = '%'+reqArgs.searchText +'%';
                    for(FCR_Peep_gne__c peep :[
                        SELECT First_Name_gne__c, Last_Name_gne__c, Google_Id_gne__c, UserUnixId__c, Job_Title_gne__c, Manager_gne__c, Email_gne__c, Mobile_Phone_Number_gne__c, Phone_Number_gne__c, Location_gne__c
                        FROM FCR_Peep_gne__c WHERE Full_Name_gne__c LIKE :searchTxt OR Google_Id_gne__c = :reqArgs.searchText OR Email_gne__c = :reqArgs.searchText 
                    ]) {
                        upss.add(createRespStructure(peep));
                    }
                }

                System.debug('responseData '+responseData);
                responseData.results = upss; 
            }
            
            return new DeltaRecordsResponse(responseData);
        }
         
         private ResData callPeepsApiUsersStructure(String googleId, String searchText) {
             String authorizationMethod = peepsConfig.get('authorizationMethod').Configuration_Value_gne__c != null ? peepsConfig.get('authorizationMethod').Configuration_Value_gne__c : null;
             String authorizationToken = peepsConfig.get('authorizationToken').Configuration_Value_gne__c != null ? peepsConfig.get('authorizationToken').Configuration_Value_gne__c : null;
             if(authorizationMethod == null){
                 throw new MissingPeepsConfigurationException(String.format(ERROR_MISSING_CONF, new List<String> {'authorizationMethod'}));
             }
             if(authorizationToken == null){
                 throw new MissingPeepsConfigurationException(String.format(ERROR_MISSING_CONF, new List<String> {'authorizationToken'}));
             }
             if(searchText != null)searchText = EncodingUtil.urlEncode(searchText, 'UTF-8');
             System.debug('>> '+searchText);
             if(googleId == null) {
                 googleId = searchText;
             }
             HttpRequest req = prepareRequest(googleId, authorizationMethod, authorizationToken);
             Http http = new Http();
             HTTPResponse res = http.send(req);  
      
             return parseResponse(res);
         }
         
         private HttpRequest prepareRequest(String googleId, String authorizationMethod, String authorizationToken){
            HttpRequest req = new HttpRequest(); 
            req.setMethod('GET');
            
            req.setEndpoint(peepsConfig.get('endpointForGW').Configuration_Value_gne__c + prepareParamsString(googleId));

            if(authorizationMethod.equalsIgnoreCase('google')){
                req.setHeader('Authorization', 'Bearer ' + authorizationToken);
                req.setHeader('X-OAuth-Provider', 'Google');
            } else if(authorizationMethod.equalsIgnoreCase('basic')){
                req.setHeader('Authorization', 'Basic ' + authorizationToken);
            }
            req.setTimeout(120000);
            return req;
        }

        private String prepareParamsString(String googleId) {
            String paramsString = '/users/search?appKey=' + peepsConfig.get('appKey').Configuration_Value_gne__c +'&query='+googleId+'&apiKey=' + peepsConfig.get('apiKey').Configuration_Value_gne__c+'&size=100';
           
            return paramsString;
        }
         
         private ResData parseResponse(HTTPResponse res){
             ResData ups = new ResData();             
             if(res.getStatusCode() == 200){
                 ups = (ResData)JSON.deserialize(res.getBody(), ResData.class);			
             } else {
                 system.debug(ups.peepResCode);
             }
             ups.peepResCode = res.getStatusCode();
             
             return ups;
         }
         
         private FCR_UserPeepsStructure createRespStructure(FCR_Peep_gne__c peep) {
             FCR_UserPeepsStructure result = new FCR_UserPeepsStructure();
             result.firstName = peep.First_Name_gne__c;
             result.lastName = peep.Last_Name_gne__c;
             result.googleId = peep.Google_Id_gne__c;
             result.userId = peep.UserUnixId__c;
             result.jobTitle = peep.Job_Title_gne__c;
             result.managerUnixId = peep.Manager_gne__c;
             result.email = peep.Email_gne__c;
             result.mobilePhoneNumber = peep.Mobile_Phone_Number_gne__c;
             result.phoneNumber = peep.Phone_Number_gne__c;
             result.location = peep.Location_gne__c;
             
             return result;             
         }
     }
    
    public class ResData {
        Integer peepResCode;
        Decimal pageNumber;
        Decimal totalPages;
        Decimal totalRows;
        List<FCR_UserPeepsStructure> results;
    }
    
    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
        public String searchText;
        public String googleId;
        public RequestArgs(String lastSyncDate, String unixId, String searchText, String googleId) {
            super(lastSyncDate, unixId, null, null, null);
            this.searchText = searchText;
            this.googleId = googleId;
        }               
    }   
    
    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public ResData result;
        public DeltaRecordsResponse(ResData result) {
            this.result = result;           
        }
    }
    
    public class MissingPeepsConfigurationException extends Exception{}
}