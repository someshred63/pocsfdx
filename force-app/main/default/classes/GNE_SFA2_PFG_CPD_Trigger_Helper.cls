public without sharing class GNE_SFA2_PFG_CPD_Trigger_Helper {
	private static Boolean inCPDTrig = false;
	private static Boolean isOtrRequest = false;
	private static OtrRequestInfo otrRequestInfo;
	
	public static void setCPDTrig(Boolean p_inCPDTrig) {
        inCPDTrig = p_inCPDTrig;
    }
            
    public static Boolean inCPDTrig()  {
        return inCPDTrig;
    }
    
    public static void setIsOtrRequest(Boolean p_isOtrRequest) {
        isOtrRequest = p_isOtrRequest;
    }
            
    public static Boolean isOtrRequest()  {
        return isOtrRequest;
    }
    
    public static void setOtrRequestInfo(OtrRequestInfo p_otrRequestInfo) {
    	otrRequestInfo = p_otrRequestInfo;
    }
    
    public static OtrRequestInfo getOtrRequestInfo() {
    	return otrRequestInfo;
    }
    
    public class OtrRequestInfo {
    	public Call2_vod__c cRec;
    	
    	public OtrRequestInfo(Call2_vod__c p_cRec) {
    		cRec = p_cRec;
    	}
    }
}