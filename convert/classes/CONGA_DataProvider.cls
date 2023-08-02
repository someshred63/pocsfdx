public with sharing class CONGA_DataProvider {
private static final Datetime MAXDATE = Datetime.valueOf('2999-01-01 00:00:00');
    
    public List<CONGA_Attendance_gne__c> getAttendances(Set<ID> myTargetedAccountsIds,CONGA_ResponseGenerationParameters parameters){
						System.debug(LoggingLevel.INFO, 'myTargetedAccountsIds: ' + myTargetedAccountsIds);
    					List<CONGA_Attendance_gne__c> retAttendances; 
    					Datetime syncDate = parameters.inputTokenDateTime; 
    					if (parameters.firstSync()){
    						/*filter only attendances of my targetted accounts*/
    						retAttendances = ([select
                                Event__c,
                                Physician__c,
                                Sponsor__c,
                                Attendance_Status__c, 
                                lastmodifieddate
                             from 
                                CONGA_Attendance_gne__c 
                             where 
                                Physician__c in :myTargetedAccountsIds and 
                                    Event__r.isActive__c = true 
                                    and Event__r.isActive_Last_Modification_Datetime__c > :syncDate
                                    /* and ( Sponsor__c = null or Sponsor__r.isActive__c = true)*/
    						]); 
    						System.debug(LoggingLevel.INFO, retAttendances);
    						return retAttendances; 
    					}
    					if (parameters.secondSync){
    						/*filter attendances of NOT my targetted accounts, or modified attendances of my targetted accounts*/
    						return([select
                                Event__c,
                                Physician__c,
                                Sponsor__c,
                                Attendance_Status__c, 
                                lastmodifieddate
                             from 
                                CONGA_Attendance_gne__c 
                             where 
                             	lastmodifieddate >: syncDate 
                             	or 
                             	( 
		                            Physician__c NOT in :myTargetedAccountsIds //during secon sync we return mainly attendances of my not targeted physicianas 
		                            and Event__r.isActive__c = true 
		                            /*and(Sponsor__c=nullorSponsor__r.isActive__c=trueorSponsor__r.isActive_Last_Modification_Datetime__c>:syncDate)*/ 
	                            )
    						] ); 
    					}  
    					
    					System.assert(parameters.firstSync() || parameters.secondSync, 'This method is meant only to be used in first or second synchronization');
    					return null; 
    }
    
  	/*used during delta synchronization, returns changed attendances, but also those belonging to physicians that had their territory changed to My Targeted Territory*/ 
    public List<CONGA_Attendance_gne__c> getAttendancesBelongingToOrChangedSince(Set<ID> physicians,Datetime syncDate){
     
						return([select
                            Event__c,
                            Physician__c,
                            Sponsor__c,
                            Attendance_Status__c, 
                            lastmodifieddate
                         from 
                            CONGA_Attendance_gne__c 
                         where 
                         	Physician__c in :physicians
                         	or
                         	lastmodifieddate >: syncDate 
                         	or 
                            (
                             Sponsor__r.isActive_Last_Modification_Datetime__c >: syncDate
                             and 
                             Sponsor__r.isActive__c = true
                            )
                            or
                            (/*case where parent event is activated, and iPad did not receive that Attendance previously, because parent event was inActive when first and second sync took place*/
							 Event__r.isActive__c = true 
                             and
                             Event__r.isActive_Last_Modification_Datetime__c >= :syncDate
                            )
                            ] );
    }
    


    

    public Map<Id,CONGA_Event_gne__c> getEvents(Datetime syncDate){
        Datetime isActiveChange_since= syncDate != null ? syncDate : CONGA_DataProvider.MAXDATE ; 
        return new Map<Id,CONGA_Event_gne__c>(
                                            [select 
                                                Name, 
                                                Description__c,
                                                Start_Date__c,
                                                End_Date__c,
                                                BU__c,
                                                Global_Oncology__c,
                                                Event_Location__c,
                                                Key_Target_Audience__c,
                                                Event_Category__c,
                                                lastmodifieddate,
                                                isActive__c
                                             from 
                                                CONGA_Event_gne__c
                                             where 
                                                (
                                                isActive__c = true 
                                                and
                                                lastmodifieddate >= :syncDate
                                                )
                                                or 
                                                (
                                                isActive__c = false
                                                and
                                                isActive_Last_Modification_Datetime__c >= :isActiveChange_since
                                                )
                                            ]); 
    }
    
    public Map<Id,CONGA_Event_Location_gne__c> getEventsLocations(Datetime syncDate){
        return new Map<Id,CONGA_Event_Location_gne__c>(
                                            [select 
                                                Name,
                                                Country__c,
                                                Latitude__c,
                                                Longitude__c,
                                                Postal_Code__c,
                                                Province_can__c,
                                                lastmodifieddate
                                             from 
                                                CONGA_Event_Location_gne__c
                                             where 
                                                lastmodifieddate >= :syncDate
                                            ]);
    }
    
    public Map<Id,CONGA_Sponsor_gne__c> getSponsors(Datetime syncDate){
    	Map<Id,CONGA_Sponsor_gne__c> sponsors;
    	if (null == syncDate)
    	{
    		//first synchronization. Send all active sponsors and those that are selected as a sponsor for any CONGA_Attendance_gne__c
    		sponsors = new Map<Id,CONGA_Sponsor_gne__c> (
                                            [select name,   
                                                    isActive__c,
                                                    BU__c
                                             from 
                                                CONGA_Sponsor_gne__c
                                             where 
                                                isActive__c = true 
                                                ]);
                                                
                                                //Due to "Semi join sub-selects are not allowed with the 'OR' operator" limitation we split the query to 2 subqueries
			sponsors.putAll(             [select name,   
                                                    isActive__c,
                                                    BU__c
                                             from 
                                                CONGA_Sponsor_gne__c
                                             where 
                                                id in (select Sponsor__c from CONGA_Attendance_gne__c )]
                               );                                                 
                                                
    	}
    	else 
    	{
 	   		
			sponsors = new Map<Id,CONGA_Sponsor_gne__c> ([select name,isActive__c,BU__c
                                             from 
                                                CONGA_Sponsor_gne__c
        									 where 
                                                lastmodifieddate >= :syncDate
                                                ]); 
    	}
    	return sponsors; 
    }


        

              
}