@RestResource(urlMapping='/iPhoneGetReferralMSLs/*')
global with sharing class iPhone_Get_ReferralMSLs implements iPhone_Commons_gne.ResponseBuilder {
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, Boolean enhDelta, String otrVersion) {
        return iPhone_Commons_gne.buildResponse(
                new iPhone_Get_ReferralMSLs(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, null, enhDelta, otrVersion)
        );                              
    }
    
    public iPhone_Commons_gne.RestResponse build(Object args) {
        List<MSLWrapper> msls = new List<MSLWrapper>();
        
        for(GNE_SFA2_ReferralUtil.AssigneeUser usr : GNE_SFA2_ReferralUtil.getManualAssigneeUsers()) {
            msls.add(new MSLWrapper(usr));
        }
        
        return new Response(msls);
    }
    
    private virtual class MSLWrapper extends iPhone_Commons_gne.RestRecord {
        private String id;
        private String fn;
        private String ln;
        private String pn;
        private String em;
        private String ph;
        private String mph;
        private List<String> tareas;
        private List<String> states;
        
        public MSLWrapper(GNE_SFA2_ReferralUtil.AssigneeUser usr) {
            this.id = usr.getId();
            this.fn = usr.getFirstName();
            this.ln = usr.getLastName();
            this.pn = usr.getProfileName();
            this.em = usr.getEmail();
            this.ph = usr.getPhone();
            this.mph = usr.getMobilePhone();
            this.tareas = usr.getTAreas();
            this.states = usr.getStates();
        }
    }
    
    private class Response extends iPhone_Commons_gne.RestResponse {
        private List<MSLWrapper> msls;
        
        private Response(List<MSLWrapper> msls) {
            this.msls = msls;
        }
    }
}