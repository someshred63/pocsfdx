/******************************************************************************************
*  @author: Michal Hrycenko, Roche
*  @email: michal.hrycenko@contractors.roche.com   
*  Created: 2013-08-01
*  Project: OTR2
*  Description: REST Webservice, returns a list of Speaker Trainings for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountSpeakerTrainings/*')
global with sharing class iPhone_Get_Account_SpeakerTrainings_gne {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, List<String> accountIds) {
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountSpeakerTrainingsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, accountIds)    		
    	);     	    	    	    	
    } 
	
	class GetAccountSpeakerTrainingsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    													
    	public Map<Id,List<String>> modulesForPRCMap {get;set;}
    	
    	public GetAccountSpeakerTrainingsResponseBuilder() {
    		this.modulesForPRCMap = prepareModulesForPRCMap();
    	}
    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getSpeakerTrainingsByAccountIds(args.accountIds);      
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountSpeakerTrainingsRecord((Speaker_Training_gne__c)sObj, modulesForPRCMap);    		    		
    	}
    	
    	private Map<Id,List<String>> prepareModulesForPRCMap() {
    		List<Curriculum_Module_gne__c> modulesForPRCList = iPhone_DAO.getModulesForPRC();
    		Map<Id,List<String>> result = new Map<Id,List<String>>();
    		for(Curriculum_Module_gne__c cm : modulesForPRCList) {
    			if(!result.containsKey(cm.Event_Curriculum_gne__c)) {
    				result.put(cm.Event_Curriculum_gne__c, new List<String>());
    			}
    			
    			result.get(cm.Event_Curriculum_gne__c).add(cm.PRC_ID_gne__c);
    		}
    		return result;
    	}     	
    } 
      
    class GetAccountSpeakerTrainingsRecord extends iPhone_Commons_gne.DeltaRecord {
    	
        public String id;					// Id
        public String tn;           		// Name
        public String cn;					// Curriculum_Name__c
        public String ci;					// Event_Curriculum_gne__c
        public String si;					// Speaker_gne__c
        public String ts;		      		// Training_Status_gne__c
        public String sn;					// Speaker_gne__r.Name 
        public String td;					// Trained_Date_gne__c
        public String dd;					// Event_Curriculum_gne__r.Deactivation_date_gne__c
        public String dm;					// Delivery_Method_gne__c
        public String cb;					// CreatedById
        public String cbn;					// CreatedBy.Name
        public List<String> prc;			// PRC Codes 
        
        public GetAccountSpeakerTrainingsRecord(Speaker_Training_gne__c speakerTraining, Map<Id,List<String>> modulesForPRCMap) {
            this.id  = speakerTraining.Id;        
            this.tn  = speakerTraining.Name ;                                               
            this.cn = speakerTraining.Curriculum_Name__c;                                                           
            this.ci  = speakerTraining.Event_Curriculum_gne__c;                       
            this.si  = speakerTraining.Speaker_gne__c;  
            this.ts  = speakerTraining.Training_Status_gne__c;           
            this.sn  = speakerTraining.Speaker_gne__r.Name;           
            this.td  = iPhone_StringUtil.getString(speakerTraining.Trained_Date_gne__c);            
            this.dd  = iPhone_StringUtil.getString(speakerTraining.Event_Curriculum_gne__r.Deactivation_date_gne__c);           
            this.dm  = speakerTraining.Delivery_Method_gne__c;            
            this.cb  = speakerTraining.CreatedById;     
            this.cbn  = speakerTraining.CreatedBy.Name;
            if(modulesForPRCMap.containsKey(speakerTraining.Event_Curriculum_gne__c)) {          
            	this.prc  = modulesForPRCMap.get(speakerTraining.Event_Curriculum_gne__c);
            } else {
            	this.prc = new List<String>();
            }
        }                	
    }
	
}