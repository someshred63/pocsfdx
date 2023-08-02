@RestResource(urlMapping='/changesSinceToken/*')
global with sharing class CONGA_ChangesSinceTokenRest {

@HttpGet 
    global static CONGA_RESTallDataResponse getEventsSponsorsAndTargetedPhysiciansData(){
        RestRequest req = RestContext.request;
        String token = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        CONGA_ResponseGenerationParameters params = new CONGA_ResponseGenerationParameters(token);
        return CONGA_ChangesSinceTokenRest.processRequest(params);
    }
    
    public static CONGA_RESTallDataResponse processRequest(CONGA_ResponseGenerationParameters parameters)
    {
		CONGA_SynchronizedPhysicians synchronizedPhysicians = new CONGA_SynchronizedPhysicians(parameters);
        Map<ID,TSF_vod__c> availableAccountIds2Targetting  =synchronizedPhysicians.aggregatedAllPhysicians;  
        CONGA_DataProvider provider = new CONGA_DataProvider();
		System.assertNotEquals(NULL,availableAccountIds2Targetting,'returned accounts can not be null'); 
        Map<Id,CONGA_Event_gne__c> events = provider.getEvents(parameters.inputTokenDateTime); 
        Map<Id,CONGA_Event_Location_gne__c> eventLocations = provider.getEventsLocations(parameters.inputTokenDateTime);
        Map<Id,CONGA_Sponsor_gne__c> sponsors = provider.getSponsors(parameters.inputTokenDateTime);
		Set<ID> activePhysicians = synchronizedPhysicians.activeTargetedPhysicians; 
        System.debug(LoggingLevel.Info, 'Active Physicians: ' + activePhysicians);         
        
        List<CONGA_Attendance_gne__c> attendances; 
        if (parameters.deltaSync)
        	attendances = provider.getAttendancesBelongingToOrChangedSince (synchronizedPhysicians.activeEventAttendeesWithModifiedTSF.keySet(), parameters.inputTokenDateTime); 
        else 	        
        	attendances = provider.getAttendances( activePhysicians, parameters); 
        System.debug(LoggingLevel.Info, 'Attendances size:' + attendances.size() ); 
        
        CONGA_RESTallDataResponse allAttendencesWithRelatedData = 
            new CONGA_RESTallDataResponse(parameters,events,eventLocations,sponsors,attendances,availableAccountIds2Targetting,synchronizedPhysicians.activeTargetedPhysicians,synchronizedPhysicians.allTerritoryPhycisians,synchronizedPhysicians.allTargetedTerritoryPhycisians);
        return allAttendencesWithRelatedData;
    }
}