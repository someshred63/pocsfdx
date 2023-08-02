/*********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call2KeyMessages for the specified accounts.             
**********************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCallKeyMessages/*')
global with sharing class iPhone_Get_Account_CallKeyMessages_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountCallKeyMessagesResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     	  
    } 
              
    class GetAccountCallKeyMessagesResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallKeyMessagesByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallKeyMessagesByAccountIds(args.accountIds);      
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountCallKeyMessagesRecord((Call2_Key_Message_vod__c)sObj);     		    		
    	}     	
    } 
    
    class GetAccountCallKeyMessagesRecord extends iPhone_Commons_gne.DeltaRecord {   
		public String nm;  // Call2_Key_Message_vod__c.Name
		public String km;  // Call2_Key_Message_vod__c.Key_Message_vod__c
		public String mn;  // Call2_Key_Message_vod__c.Key_Message_vod__r.Name
		public String de;  // Call2_Key_Message_vod__c.Key_Message_vod__r.Description_vod__c
		public String ac;  // Call2_Key_Message_vod__c.Key_Message_vod__r.Active_vod__c
		public String iid; // Call2_Key_Message_vod__c.Call2_vod__c           
        
        public GetAccountCallKeyMessagesRecord(Call2_Key_Message_vod__c callKeyMsg) {
        	this.id	 = callKeyMsg.Id;
			this.nm	 = callKeyMsg.Name;
			this.km	 = iPhone_StringUtil.getString(callKeyMsg.Key_Message_vod__c);
			this.mn	 = iPhone_StringUtil.getString(callKeyMsg.Key_Message_vod__r.Name);
			this.de  = iPhone_StringUtil.getString(callKeyMsg.Key_Message_vod__r.Description_vod__c);
			this.ac	 = iPhone_StringUtil.getString(callKeyMsg.Key_Message_vod__r.Active_vod__c);
			this.iid = iPhone_StringUtil.getString(callKeyMsg.Call2_vod__c);	
        }
    }
}