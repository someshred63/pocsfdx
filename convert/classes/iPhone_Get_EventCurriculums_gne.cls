/******************************************************************************************
*  @author: Michal Hrycenko, Roche
*  @email: michal.hrycenko@contractors.roche.com   
*  Created: 2013-08-01
*  Project: OTR2
*  Description: REST Webservice, returns a list of Event Curriculums.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetEventCurriculums/*')
global with sharing class iPhone_Get_EventCurriculums_gne {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate) {
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountEventCurriculumsResponseBuilder(),
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, null, null)
	    );    	    	    	    	
    } 
	
	class GetAccountEventCurriculumsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getEventCurriculums();      
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountEventCurriculumsRecord((Event_Curriculum_gne__c)sObj);    		    		
    	}
    	     	
    } 
      
    class GetAccountEventCurriculumsRecord extends iPhone_Commons_gne.DeltaRecord {
    	
        public String id;					// Id
        public String nm;           		// Name
        
        public GetAccountEventCurriculumsRecord(Event_Curriculum_gne__c eventCurriculum) {
            this.id  = eventCurriculum.Id;        
            this.nm  = eventCurriculum.Name;
        }                	
    }
}