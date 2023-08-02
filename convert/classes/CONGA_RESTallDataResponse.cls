global with sharing class CONGA_RESTallDataResponse {
	
	public List<CONGA_EventProperties> events {public get; private set; }
	public List<CONGA_LocationProperties> locations {public get; private set; } /*this property stores both data for Event Locations and Address data for Account*/ 
	public List<CONGA_SponsorProperties> sponsors {public get; private set; }
	public List<CONGA_PhysicianProperties> physicians {public get; private set; }
	public List<CONGA_AttendanceProperties> attendances {public get; private set; }
	public List<ID>activeTargetedPhysicians{public get; private set;}
	public List<String> oncologicalBusinessUnitsList {public get; public set;}
	public List<String> nonOncologicalBusinessUnitsList {public get; public set;}
	public String token{public get; private set;}

	public with sharing class CONGA_Exception extends Exception{
	
	}

	public CONGA_RESTallDataResponse(	CONGA_ResponseGenerationParameters processRequestParameters,
										Map<Id,CONGA_Event_gne__c> mEvents,
										Map<Id,CONGA_Event_Location_gne__c> mEventLocations, 
										Map<Id,CONGA_Sponsor_gne__c> mSponsors,
										List<CONGA_Attendance_gne__c> lAttendances, 
										Map<ID,TSF_vod__c> availableAccountIds2Targetting,
										Set<ID>activeTargetedPhysiciansSet,
										Map<Id, List<TSF_vod__c>> phycisianIdToTerrListMap,
										Map<Id, List<TSF_vod__c>> allTargetedTerritoryPhycisians)
						{
							List<Schema.PicklistEntry> buEntries = CONGA_Event_gne__c.BU__c.getDescribe().getPicklistValues();
							List<String> buValues = new List<String>();
							for(Schema.PicklistEntry entry : buEntries){
								buValues.add(entry.getValue());
							}
							if(PROSPECT_Configuration__c.getInstance('Configuration') == null){
								throw new CONGA_Exception('PROSPECT_Configuration__c custom setting instance with name "Configuration" does not exist');
							}
                            String toSplit = PROSPECT_Configuration__c.getInstance('Configuration').Oncology_List__c;
                            oncologicalBusinessUnitsList = new List<String>();
                            Set<String> compareSet = new Set<String>();
                            compareSet.addAll(buValues);
                            for(String oncologyBU : toSplit.split(',')){
                            	if(compareSet.contains(oncologyBU) && oncologyBU != '-- None --' && oncologyBU != '--None--' && oncologyBU != null){
                            		oncologicalBusinessUnitsList.add(oncologyBU);
                            	} else {
                            		System.debug('Value specified in oncology list field of PROSPECT Configuration custom setting is not value of business unit picklist of PROSPECT Event object, value: ' + oncologyBU);
                            	}
                            }
                            nonOncologicalBusinessUnitsList = new List<String>();
                            compareSet = new Set<String>();
                            compareSet.addAll(oncologicalBusinessUnitsList);
                            for(String value : buValues){
                            	if(!compareSet.contains(value) && value != '-- None --' && value != '--None--' && value != null){
                            		nonOncologicalBusinessUnitsList.add(value);
                            	}
                            }
			                this.events = new List<CONGA_EventProperties>(); 
			                this.locations = new List<CONGA_LocationProperties>();
			                this.sponsors = new List<CONGA_SponsorProperties>();
			                this.physicians = new List<CONGA_PhysicianProperties>();
			                this.attendances = new List<CONGA_AttendanceProperties>();
			                if ( ! processRequestParameters.firstSync())
			                {
                            	activeTargetedPhysicians = new List<ID>(activeTargetedPhysiciansSet);
			                } 
							token = processRequestParameters.outputToken; 
			                for (CONGA_Sponsor_gne__c sponsor: mSponsors.values()){
			                    this.sponsors.add(new CONGA_SponsorProperties(sponsor)); 
			                }
			        
			                for (CONGA_Event_gne__c event: mEvents  != null ? mEvents.values() : new List<CONGA_Event_gne__c>()  ){
			                    this.events.add(new CONGA_EventProperties(event)); 
			                }
			        
			                for (CONGA_Event_Location_gne__c eventLocation: mEventLocations != null ? mEventLocations.values() : new List<CONGA_Event_Location_gne__c>() ){
			                    this.locations.add(new CONGA_LocationProperties(eventLocation)); 
			                }
			                
			                for (CONGA_Attendance_gne__c attendance: lAttendances){
			                    this.attendances.add(new CONGA_AttendanceProperties(attendance)); 
			                }										
							
							for (TSF_vod__c tsf: availableAccountIds2Targetting.values()){
								if (tsf.My_Target_vod__c)
								{
									if (processRequestParameters.firstSync()){
										CONGA_PhysicianProperties physician = new CONGA_PhysicianProperties(tsf.Account_vod__r,tsf.My_Target_vod__c,phycisianIdToTerrListMap.get(tsf.Account_vod__c), allTargetedTerritoryPhycisians.get(tsf.Account_vod__c));
										this.physicians.add(physician);
										for(TSF_vod__c targetTerr : phycisianIdToTerrListMap.get(tsf.Account_vod__c)){
											if(physician.locationId == targetTerr.Address_vod__c){
												this.locations.add(new CONGA_LocationProperties(targetTerr.Address_vod__r));	
											}			
										}	
									} else {
										//Boolean isTargeted = activeTargetedPhysiciansSet.contains(tsf.Account_vod__c) ? true : false; 
										if(activeTargetedPhysiciansSet.contains(tsf.Account_vod__c)){
											CONGA_PhysicianProperties physician = new CONGA_PhysicianProperties(tsf.Account_vod__r,tsf.My_Target_vod__c,phycisianIdToTerrListMap.get(tsf.Account_vod__c), allTargetedTerritoryPhycisians.get(tsf.Account_vod__c));
											this.physicians.add(physician); 	
											for(TSF_vod__c targetTerr : phycisianIdToTerrListMap.get(tsf.Account_vod__c)){
												if(physician.locationId != null && physician.locationId == targetTerr.Address_vod__c){
													this.locations.add(new CONGA_LocationProperties(targetTerr.Address_vod__r));	
												}			
											}										
										} else {
											//this.physicians.add(new CONGA_PhysicianProperties(tsf.Account_vod__r, false, tsf.Address_vod__c)); 	
											this.physicians.add(new CONGA_PhysicianProperties(tsf.Account_vod__r,tsf.My_Target_vod__c,phycisianIdToTerrListMap.get(tsf.Account_vod__c), allTargetedTerritoryPhycisians.get(tsf.Account_vod__c)));
											this.locations.add(new CONGA_LocationProperties(tsf.Address_vod__r));										
										}
										
									}

								}
								else 
								{
									this.physicians.add(new CONGA_PhysicianProperties(tsf.Account_vod__r,tsf.My_Target_vod__c,phycisianIdToTerrListMap.get(tsf.Account_vod__c), allTargetedTerritoryPhycisians.get(tsf.Account_vod__c)));
									//this.physicians.add(new CONGA_PhysicianProperties(tsf.Account_vod__r, false, tsf.Address_vod__c));
									this.locations.add(new CONGA_LocationProperties(tsf.Address_vod__r));
								}
							}
						}
}