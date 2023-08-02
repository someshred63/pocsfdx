@RestResource(urlMapping='/S2S/ReferralUpdate/*')
global without sharing class GNE_SFA2_ReferralRestUpdate extends GNE_SFA2_ReferralEngine {
    @HttpPost 
    global static RestResponse processRequest(RestRequest request) {
        return (RestResponse)GNE_SFA2_S2S_ServiceEngine.executeRestPostMethod(GNE_SFA2_ReferralUtil.EXTERNAL_SYSTEM_NAME, GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_UPDATE,
            new GNE_SFA2_ReferralRestUpdate(), request, RestResponse.class);
    }
    
    public virtual override System.Type getSelfClass() {
        return GNE_SFA2_ReferralRestUpdate.class;
    }
    
    global class RestRequest extends GNE_SFA2_ReferralUtil.ReferralRequest {
        private List<ReferralUpdateDataWrapper> records;
        
        public RestRequest() {}
        
        public virtual override System.Type getSelfClass() {
            return RestRequest.class;
        }
        
        public virtual override List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<ReferralUpdateDataWrapper>();
            }
            
            return this.records;
        }
    }
    
    global class RestResponse extends GNE_SFA2_ReferralUtil.ReferralResultWrapper {
        public RestResponse() {}
        
        public virtual override System.Type getSelfClass() {
            return RestResponse.class;
        }
    }
}