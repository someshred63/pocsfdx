@RestResource(urlMapping='/FCR/deleteVisits/*')
global class FCR_Delete_Visits {
    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(List<String> rids) {
        return iPhone_Commons_gne.buildResponse(
            new DeleteVisitsResponseBuilder(),
            new RequestArgs(rids,  getUnixId())            
        );
    }
    
    private static String getUnixId() {
        return [SELECT External_Id_gne__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].External_Id_gne__c;
    }
    
    class DeleteVisitsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        String[] removedRids = new String[]{};
        public iPhone_Commons_gne.RestResponse build(Object args) {
            RequestArgs reqArgs = (RequestArgs)args;
            Database.DeleteResult [] drList = Database.delete([SELECT Id FROM Visit_gne__c WHERE RequestId_gne__c IN : reqArgs.rids]);
            
            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                    removedRids.add(dr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
            return new DeleteResponse(removedRids);
        }
    }
    
    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
		private List<String> rids;
        public RequestArgs(List<String> rids, String unixId) {
            super(null, unixId, null, null, null);
            this.rids = rids;
        }               
    } 
    
    public class DeleteResponse extends iPhone_Commons_gne.RestResponse {
        public String[] removedRids;

        public DeleteResponse(String[] removedRids) {
            this.removedRids = removedRids;     
        }
    }
}