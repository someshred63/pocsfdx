@RestResource(urlMapping='/iPhoneAccount/*')
global without sharing class iPhone_Modify_Account {
    
    @HttpPost
    global static iPhone_Commons_gne.RestResponse hideAccounts(List<String> tsfIds, String territoryId) {
        try{
            GNE_SFA2_HCP_Helper.hideAccounts(tsfIds, territoryId);
        }catch(Exception e){
            return new BasicResponse(e);
        }
        return new BasicResponse();
    }
    
    
    class BasicResponse extends iPhone_Commons_gne.RestResponse{
        public BasicResponse() {
            setSuccessStatus();
        }   
        
        public BasicResponse(Exception ex) {            
            setErrorStatus(ex);
        }
    }

}