@RestResource(urlMapping='/iPhoneManageAffiliation/*')
global with sharing class iPhone_ManageAffiliation extends GNE_SFA2_AffiliationEngine implements iPhone_Commons_gne.Runnable {
    
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(RestRequest request) {
        iPhone_ManageAffiliation engine = new iPhone_ManageAffiliation();
        return iPhone_Commons_gne.executeAlterData(engine, request);
    }
        
    public Object run(Object arg) {
        RestRequest request = (RestRequest)arg;
        List<GNE_SFA2_AffiliationUtil.ResponseWrapper> affiliations = upsertAffiliations(request.affiliations);
        return buildResponse(affiliations);
    }

    private RestResponse buildResponse(List<GNE_SFA2_AffiliationUtil.ResponseWrapper> affiliations) {
        List<ResponseItem> responseItems = new List<ResponseItem>();

        for(GNE_SFA2_AffiliationUtil.ResponseWrapper rw : affiliations) {
        	responseItems.add(new ResponseItem(rw.rid, rw.sfdcId, rw.status, rw.error));
        }

        return new RestResponse(responseItems);
    }

    global class RestRequest implements iPhone_Commons_gne.BaseArgs, iPhoneBase.RequestTestable2 {
	    public List<GNE_SFA2_AffiliationUtil.AffiliationWrapper> affiliations;
	    
	    public String getIPhoneRequestId(){
	      return affiliations != null && !affiliations.isEmpty() ? affiliations[0].rid : null;
	    }
	    
	    public void testRequest() {
	      new iPhone_ManageAffiliation().run(this);
	    }
	    
	    public System.Type getRequestType() {
	    	return RestRequest.class;
	    }
    }

    global class RestResponse extends iPhone_Commons_gne.AlterDataResponse {
        private List<ResponseItem> responseItems;
        
        private RestResponse(List<ResponseItem> responseItems) {
            this.responseItems = responseItems;
        }
    }
    
    public class ResponseItem extends iPhone_Commons_gne.AlterDataResponseItem {
        private String status;
        private String error;
        
        public ResponseItem(String rid, Id id, String status, String error) {
            super(rid, id);
            this.status = status;
            this.error = error;
        }
    }

    
    
    
}