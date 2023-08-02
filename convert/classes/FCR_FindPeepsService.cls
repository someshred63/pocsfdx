@RestResource(urlMapping='/FCR/findPeeps/*')
global class FCR_FindPeepsService {
    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String searchText) {
        return iPhone_Commons_gne.buildResponse(
            new GetUserPeepsResponseBuilder(),
            new RequestArgs(searchText,  getUnixId() )
            
        );
    }
    
    private static String getUnixId() {
        return [SELECT External_Id_gne__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].External_Id_gne__c;
    }
    
    class GetUserPeepsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args) {
            RequestArgs reqArgs = (RequestArgs)args;
            List<FCR_Get_PeepUserDetails.UserPeepsStructure> ups = new List<FCR_Get_PeepUserDetails.UserPeepsStructure>();
            
            for(FCR_Peep_gne__c peep :findPeepsByNameFields(reqArgs.searchTxt)) {
                ups.add(new FCR_Get_PeepUserDetails.UserPeepsStructure(peep));
            }

            return new DeltaRecordsResponse(ups);
        }
        
        private List<FCR_Peep_gne__c> findPeepsByNameFields(String searchTxt) {
            List<FCR_Peep_gne__c> peeps = new List<FCR_Peep_gne__c>();
            String sQuery = 'FIND \''+searchTxt+'*\' IN ALL FIELDS RETURNING FCR_Peep_gne__c('+
                'UserUnixId__c, Department_Code_gne__c, Department_Name_gne__c, Email_gne__c, Employment_Type_gne__c, First_Name_gne__c, Full_Name_gne__c, Job_Title_gne__c, '+
                'Last_Name_gne__c, Location_gne__c, Location_Id_gne__c, Manager_gne__c, LastMOdifiedDate, CreatedDate, Mobile_Phone_Number_gne__c, Phone_Number_gne__c ) ';
            Search.SearchResults searchResults = Search.find(sQuery);
            List<Search.SearchResult> resultlist = searchResults.get('FCR_Peep_gne__c');
            
            for(Search.SearchResult searchResult : resultlist) {
                FCR_Peep_gne__c record = (FCR_Peep_gne__c) searchResult.getSObject();
                if(isCorrectResult(record, searchTxt)) {
                    peeps.add(record); 
                }
                                           
            }
            
            
            return peeps;
        }
        
        private Boolean isCorrectResult(FCR_Peep_gne__c rec, String searchTxt) {
            String cphone = rec.Phone_Number_gne__c != null ? rec.Phone_Number_gne__c : '';
			String pho = cphone.replaceAll('\\D','');
            String mphone = rec.Mobile_Phone_Number_gne__c != null ? rec.Mobile_Phone_Number_gne__c : '';
			String mpho = mphone.replaceAll('\\D','');
            String convertTosearchNmber = searchTxt.replaceAll('\\D','');
            System.debug(pho + ' mp '+mpho + ' c 2 num '+convertTosearchNmber);
            Boolean result = false;
            result |= rec.Full_Name_gne__c.contains(searchTxt);
            result |= pho.contains(convertTosearchNmber);
            result |= mpho.contains(convertTosearchNmber);
            result |= rec.Email_gne__c.contains(searchTxt);
            result |= rec.UserUnixId__c.contains(searchTxt);
            
            return result;
        }
    }
    
    
    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
		private String searchTxt;
        public RequestArgs(String searchTxt, String unixId) {
            super(null, unixId, null, null, null);
            this.searchTxt = searchTxt;
        }               
    }    
    
    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public FCR_Get_PeepUserDetails.UserPeepsStructure[] peepsUsers;
        public DeltaRecordsResponse(FCR_Get_PeepUserDetails.UserPeepsStructure[] peepsUsers) {
            this.peepsUsers = peepsUsers;           
        }
    }

}