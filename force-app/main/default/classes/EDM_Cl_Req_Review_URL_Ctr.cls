public with sharing class EDM_Cl_Req_Review_URL_Ctr {
	public Id clReqId {set; get;}


	public String getClassificationReviewURL() {
		if (GNE_SFA2_S2S_Util.isFeatureEnabled(EDM_Classification_Request_RestUtil.Feature.ClassifReqRedirectReviewToMA.name())) {
			return EDM_Classification_Request_RestUtil.getUrlForReviewOnMA(clReqId);
		} else {
			return getUrlForReviewOnMainOrg();
		}
	}

	private String getUrlForReviewOnMainOrg() {
		String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
		PageReference pr = Page.EDM_Cl_Req_Review_Edit_Create;
		pr.getParameters().put('id', clReqId);
		pr.getParameters().put('retUrl', '/apex/EDM_Classification_Requests_List');
		return baseURL + pr.getUrl();
	}
}