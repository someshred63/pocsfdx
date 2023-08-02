@RestResource(urlMapping='/iPhoneManageReferral/*')
global without sharing class iPhone_ManageReferral extends GNE_SFA2_ReferralEngine implements iPhone_Commons_gne.Runnable {
    private static GNE_SFA2_ReferralUtil.AutoAssignmentFailedException aaException;
    
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(RestRequest request) {
        iPhone_ManageReferral engine = new iPhone_ManageReferral();
       
        if (!GNE_SFA2_Util.isCanadaUser()) {
	        try {
	            engine.checkAutoAssignment(request);
	        } catch(GNE_SFA2_ReferralUtil.AutoAssignmentFailedException aafex) {
	            aaException = aafex;
	        } catch(Exception ex) {}
        }
        
        return iPhone_Commons_gne.executeAlterData(
            engine, 
            request
        );
    }
    
    public Object run(Object arg) {
        if(aaException!=null) {
            //modified at OTR-3891. Pass even if synapse connection error occurrs 
            //throw aaException;
            String runnableClassName = String.valueOf(this).substringBefore(':');
            iPhoneBase.handleException(aaException, UserInfo.getUserId(), 'OTR', '[iPhone REST] ' + runnableClassName, 
                arg!=null && arg instanceof iPhoneBase.RequestTestable2 ? ((iPhoneBase.RequestTestable2)arg).getRequestType() : null,
                arg!=null && arg instanceof iPhone_Commons_gne.BaseArgs ? ((iPhone_Commons_gne.BaseArgs)arg).getIPhoneRequestId() : null, 
                arg,
                '[iPhone REST] Synapse connection error ' + runnableClassName);
        }
        
        RestRequest request = (RestRequest)arg;
        request.setIsOtrRequest(true);
        Medical_Communication_gne__c medComm = findExistingReferral(request);
        
        Boolean editReferralCanadaMode = medComm != null && GNE_SFA2_Util.isCanadaUser() && medComm.Referral_Assignment_gne__c != null && medComm.Referral_Assignment_gne__r.Assigned_To_gne__c == UserInfo.getUserId();
        if (editReferralCanadaMode){
        	medComm = updateReferral(request);
        } else {
        	medComm = medComm!=null ? medComm : createReferral(request);
        }
        return buildResponse(medComm);
    }
    
    private Medical_Communication_gne__c findExistingReferral(RestRequest request) {
        Medical_Communication_gne__c medComm = null;

        List<Medical_Communication_gne__c> medComms = 
            String.isNotBlank(request.getSfaId()) ? [
                SELECT Id, iPhone_Request_Id_gne__c, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c
                FROM Medical_Communication_gne__c
                WHERE Id =:request.getSfaId()]
            : String.isNotBlank(request.getRid()) ? [
                SELECT Id, iPhone_Request_Id_gne__c, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c
                FROM Medical_Communication_gne__c
                WHERE iPhone_Request_Id_gne__c =:request.getRid()]
            : String.isNotBlank(request.getLocalId()) ? [
                SELECT Id, iPhone_Request_Id_gne__c, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c
                FROM Medical_Communication_gne__c
                WHERE Id =:request.getLocalId()]
            : null;
        return medComms!=null && !medComms.isEmpty() ? medComms[0] : null;
    }
    
    protected override Medical_Communication_gne__c intCreateReferralMedComm(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        Medical_Communication_gne__c medComm = super.intCreateReferralMedComm(referral);
        medComm.iPhone_Request_Id_gne__c = ((RestRequest)referral).getRid();
        return medComm;
    }
    
    protected override GNE_Med_iPhone_CreateReferral.ReferralInfo getReferralWrapperOldWay(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        GNE_Med_iPhone_CreateReferral.ReferralInfo refInfo = super.getReferralWrapperOldWay(referral);
        refInfo.RequestId = ((RestRequest)referral).getRid();
        return refInfo;
    }
    
    private RestResponse buildResponse(Medical_Communication_gne__c medComm) {
        GNE_SFA2_ReferralUtil.UserWrapper assignee = null;
        
        if(String.isNotBlank(medComm.Referral_Assignment_gne__r.Assigned_To_gne__c)) {
            assignee = new GNE_SFA2_ReferralUtil.UserWrapper(medComm.Referral_Assignment_gne__r.Assigned_To_gne__c);
            assignee.fetchWithLocalUser();
        }
        
        return new RestResponse(new List<ResponseItem>{
            new ResponseItem(medComm.iPhone_Request_Id_gne__c, medComm.Id, medComm.Referral_Assignment_gne__c, assignee)
        });
    }
    
    global class RestRequest extends GNE_SFA2_ReferralUtil.ReferralWrapper implements iPhone_Commons_gne.BaseArgs, iPhoneBase.RequestTestable2 {
        private String rid;
        
        private RestRequest() {}
        
        private String getRid() {
            return this.rid;
        }
        
        public String getIPhoneRequestId(){
            return this.getRid();
        }
        
        public void testRequest() {
            new iPhone_ManageReferral().run(this);
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
        private Id raId;
        private GNE_SFA2_ReferralUtil.UserWrapper assignee;
        
        public ResponseItem(String rid, Id id, Id raId, GNE_SFA2_ReferralUtil.UserWrapper assignee) {
            super(rid, id);
            this.raId = raId;
            this.assignee = assignee;
        }
    }
}