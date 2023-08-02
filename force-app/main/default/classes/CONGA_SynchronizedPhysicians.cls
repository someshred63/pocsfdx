public class CONGA_SynchronizedPhysicians{
        private Map<ID,TSF_vod__c> createdOrUpdatedTargetedPhysicians; 
    	private Map<ID,TSF_vod__c> createdOrUpdatedAttendees; 
    	private Map<ID,TSF_vod__c> myTargetedphysiciansWithModifiedTSF; 
    	
    	public Map<ID,TSF_vod__c> aggregatedAllPhysicians { public get; private set;}
    	public Map<ID,TSF_vod__c> activeEventAttendeesWithModifiedTSF{ public get; private set;}
    	public Set<ID>activeTargetedPhysicians{public get; private set;}  		
    	public Map<Id, List<TSF_vod__c>> allTerritoryPhycisians	{public get; private set;}											/*holds Set of all Targeted Physicians assigned to user territories*/ 
    	public Map<Id, List<TSF_vod__c>> allTargetedTerritoryPhycisians	{public get; private set;}
    	
    	public CONGA_SynchronizedPhysicians(CONGA_ResponseGenerationParameters parameters){
    		init(); 
	    	CONGA_PhysicianProvider provider;
	    	if(parameters.firstSync()){
	    		provider = new CONGA_PhysicianProvider();
	    	} else {
	    		provider = new CONGA_PhysicianProvider(UserInfo.getuserId(), parameters.inputTokenDateTime);
	    	}
			/*get set of ids of active targeted physicians - this property is used to */ 
	        activeTargetedPhysicians = provider.activeTargetedPhysicians.keySet();
	        
	       	 if (parameters.firstSync()){
				createdOrUpdatedTargetedPhysicians = provider.activeTargetedPhysicians;
			 } else if (parameters.secondSync){
				//due to "Maximum 2 semi-join sub-select limitation" data fetching was diveded to several subqueries
	        	// get changes of my targeged accounts - those modified directly, and who were affected by TSF modification
	        	createdOrUpdatedTargetedPhysicians = provider.getModifiedPhysicians(parameters.inputTokenDateTime, provider.userTerritoryNames);
	        	myTargetedphysiciansWithModifiedTSF = provider.getPhysiciansWithModifiedTSF(parameters.inputTokenDateTime, provider.userTerritoryNames); 
	        	
	        	createdOrUpdatedTargetedPhysicians.putAll( myTargetedphysiciansWithModifiedTSF);
			    //get only untargeted attendees that are assigned to any event - we do not need all attendees, because physicians with changed targeting were fetched previously    		
			    createdOrUpdatedAttendees = provider.getUntargetedEventAttendees();
	        
	        } else if (parameters.deltaSync){
	        	// get changes of my targeged accounts
	        	createdOrUpdatedTargetedPhysicians = provider.getModifiedPhysicians(parameters.inputTokenDateTime, provider.userTerritoryNames);
	        	myTargetedphysiciansWithModifiedTSF = provider.getPhysiciansWithModifiedTSF(parameters.inputTokenDateTime, provider.userTerritoryNames); 
	        	createdOrUpdatedTargetedPhysicians.putAll( myTargetedphysiciansWithModifiedTSF);
	        	
	        	// get changes of accounts assigned to active events
	        	createdOrUpdatedAttendees = provider.getCreatedActiveEventAttendees(parameters.inputTokenDateTime);
	        	createdOrUpdatedAttendees.putAll(provider.getModifiedActiveEventAttendees(parameters.inputTokenDateTime));
	        	
	        	activeEventAttendeesWithModifiedTSF = provider.getActiveEventAttendeesWithModifiedTSF(parameters.inputTokenDateTime); 
	        	createdOrUpdatedAttendees.putAll( activeEventAttendeesWithModifiedTSF );

	        }
	        
	        aggregatePhysicians(); 
	        provider.setAllTerritoryForPhycisians(aggregatedAllPhysicians.keySet());
	        allTerritoryPhycisians = provider.allTerritoryPhycisians;
	        allTargetedTerritoryPhycisians = provider.allTargetedTerritoryPhycisians;
	        
			if(provider.territoryHierarchyChanged){
				List<TSF_vod__c> allTSFList = new List<TSF_vod__c>();
				for(List<TSF_vod__c> tsfList : provider.allTerritoryPhycisians.values()){
					allTSFList.addAll(tsfList);
				}
        		createdOrUpdatedTargetedPhysicians.putAll(provider.convertTSFto_AccontIdToTSFmap(allTSFList));
        	}

	        

    	}
    	
    	private void init(){
			createdOrUpdatedTargetedPhysicians = new Map<ID,TSF_vod__c>(); 
    		createdOrUpdatedAttendees = new Map<ID,TSF_vod__c>(); 
            aggregatedAllPhysicians = new Map<ID,TSF_vod__c>();
            myTargetedphysiciansWithModifiedTSF = new Map<ID,TSF_vod__c>();
    	}
    	
    	/*accumulates both targeted and untar*/  //TODO change into property instead of initialization 
    	private void aggregatePhysicians(){
    		aggregatedAllPhysicians = new Map<ID,TSF_vod__c> (createdOrUpdatedTargetedPhysicians);
    		aggregatedAllPhysicians.putAll(createdOrUpdatedAttendees);
    	}
    	
    	
    }