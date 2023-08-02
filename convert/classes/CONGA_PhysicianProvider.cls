public class CONGA_PhysicianProvider{
	private static final String SELECT_REQ_DATA_FROM_TSF =	'SELECT Id,My_Target_vod__c,lastmodifieddate, '+
							                                	'Account_vod__c, Account_vod__r.Name,  Territory_vod__c, '+
							                                	'Address_vod__r.id,Address_vod__r.name,Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate '+
							                                'FROM '+
							                                	'TSF_vod__c ' +
							                                'WHERE ' +
							                                	'Account_vod__c <> null ' +
								                                'AND Address_vod__c <> null ' +
								                                'AND Account_vod__r.isPersonAccount = true ';


    public Set<String> userTerritoryNames{get; private set; }
    public TSF_vod__c[] targetedPersonAccounts{get; private set; }
    public Map<ID,TSF_vod__c> activeTargetedPhysicians{get; private set; }
    public Map<Id, List<TSF_vod__c>> allTerritoryPhycisians	{public get; private set;}											/*holds Set of all Targeted Physicians assigned to user territories*/
    public Map<Id, List<TSF_vod__c>> allTargetedTerritoryPhycisians	{public get; private set;}
    private Datetime lastTimestamp;
    public Boolean territoryHierarchyChanged = false;

    public ID userId {
        public get{ return userId != null ? userId :UserInfo.getuserId();}
        set {userId = value; }
    }

    public CONGA_PhysicianProvider(ID userId, Datetime lastTimestamp){
        this.userId = userId;
        this.lastTimestamp = lastTimestamp;
        userTerritoryNames = getUserTerritoriesNames();
        targetedPersonAccounts = this.getTargetedPersonAccounts();
        activeTargetedPhysicians = convertTSFto_AccontIdToTSFmap(targetedPersonAccounts);
        allTerritoryPhycisians = new Map<Id, List<TSF_vod__c>>();
        allTargetedTerritoryPhycisians = new Map<Id, List<TSF_vod__c>>();
    }

    public CONGA_PhysicianProvider(){
    	this(UserInfo.getuserId(), null);
    }

	/* Returns physicians that were creatd or had "first name" or "last name" modified since @sinceTimestamp
	*  the physician needs to
	*  		- be personAccount from within @territoryNames
	*		- be marked as Targeted
	*		- have Account_vod__c and Address_vod__c filled
	*/
	public Map<ID,TSF_vod__c> getModifiedPhysicians(Datetime sinceTimestamp,Set<String> territoryNames ){
		Set<ID> accountIds = new Map<ID,Account>([select id from Account
													   where
													   	   id in (
															   select AccountId
		                                                       from AccountHistory
		                                                       where createddate > :sinceTimestamp
		                                                       and (field = 'LastName' or field = 'FirstName' or Field = 'Name' or Field='created')
                                                       		)
                                                       		and
                                                       		id in (
	                                                       	   	select Account_vod__c
																from
																	TSF_vod__c
																where
																	Territory_vod__c in: territoryNames
																	and My_Target_vod__c = true
									                                AND Account_vod__c <> null
									                                AND Address_vod__c <> null
									                                AND Account_vod__r.isPersonAccount = true
                                                       		)
                                  					]
                                    			).keySet();
        return convertTSFto_AccontIdToTSFmap (getTSF(accountIds,territoryNames));
	}

	private TSF_vod__c[] getTSF(Set<ID> accountIds,Set<String> territoryNames){
			System.assert(accountIds != null,'AccountIDs are needed for filtering out');
			final String queryString =
	                                SELECT_REQ_DATA_FROM_TSF +
	                                'AND Account_vod__c in: accountIds ' +
	                                (territoryNames!=null ? 'and Territory_vod__c In:TerritoryNames' : '');
            System.debug(LoggingLevel.INFO, '###Dynamic query string: '+ queryString);
			return Database.query(queryString );
	}


	/* returns all physicians that started being "Targeted" since @sinceTimestamp or have changed their address since @sinceTimestamp*/
	public Map<ID,TSF_vod__c> getPhysiciansWithModifiedTSF(Datetime sinceTimestamp, Set<String> territoryNames ){
		TSF_vod__c[] modifiedTSF = [
															select Id,My_Target_vod__c,lastmodifieddate,
								                                Account_vod__c, Account_vod__r.Name, Territory_vod__c,
								                                Address_vod__r.id,Address_vod__r.name,Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate, Address_vod__r.Primary_vod__c
															from
																TSF_vod__c
															where
																Territory_vod__c in: territoryNames
																and My_Target_vod__c = true

								                                AND Account_vod__c <> null
								                                AND Address_vod__c <> null
								                                AND Account_vod__r.isPersonAccount = true

																and
																id in  (
																			select ParentId
				                                                    	    from
				                                                    	    	TSF_vod__History
			   		                                                        where
				   		                                                        createddate > :sinceTimestamp
					                                                        and
					                                                        (
							                                                    field = 'My_Target_vod__c'
						                                                        or
						                                                        field = 'Address_vod__c'
						                                                        or
						                                                        field = 'Territory_vod__c'
						                                                        or
						                                                        field = 'Account_vod__c'
						                                                        or
						                                                        field = 'created'

					                                                        )
		                                                      			)
                                             			];
        return convertTSFto_AccontIdToTSFmap ( modifiedTSF );
		//return new Map<ID,Account>([select id from Account where id in (select Account_vod__c from TSF_vod__c where id in :modifiedTSF.keySet() )] ).keySet();
	}


	/*returns event-attendees(not only my targeted accounts) which assignment was created after @sinceTimestamp*/
	public Map<ID,TSF_vod__c> getCreatedActiveEventAttendees(Datetime sinceTimestamp){
		Set<ID> accountIds = new Map<ID,Account>([select id from Account
													   where
                                                       		id in (
	                                                       	   	select Physician__c
																from
																	CONGA_Attendance_gne__c
																where
																	Event__r.isActive__c = true
																and createddate > :sinceTimestamp
                                                       		)
                                  	]
                                    ).keySet();
        return convertTSFto_AccontIdToTSFmap(getTSF(accountIds,null));
	}


	/*returns event-attendees(not only my targeted accounts) that got modified*/
	public Map<ID,TSF_vod__c> getModifiedActiveEventAttendees(Datetime sinceTimestamp){
		Set<ID> accountIds = new Map<ID,Account>([select id from Account
													   where
                                                       		id in (
	                                                       	   	select Physician__c
																from
																	CONGA_Attendance_gne__c
																where
																	Event__r.isActive__c = true
                                                       		)
                                                       	and
 													   	    id in (
															   select AccountId
		                                                       from AccountHistory
		                                                       where createddate > :sinceTimestamp
		                                                       and (field = 'LastName' or field = 'FirstName' or field = 'Name' or Field='created' )
                                                       		)
                                  	]
                                    ).keySet();
        return convertTSFto_AccontIdToTSFmap(getTSF(accountIds,null));
	}

	public Map<ID,TSF_vod__c>  getActiveEventAttendeesWithModifiedTSF(Datetime sinceTimestamp){
		List<TSF_vod__c> modifiedTSF = [ select Id,My_Target_vod__c,
				                                	Account_vod__c, Account_vod__r.Name, Territory_vod__c,
				                                	Address_vod__r.id,Address_vod__r.name,Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate, Address_vod__r.Primary_vod__c
												from
													TSF_vod__c


												where
													Account_vod__c in
													(
                                                   	   	select Physician__c
														from
															CONGA_Attendance_gne__c
														where
															Event__r.isActive__c = true
                                           			)
													and
													id in  (
																select ParentId
	                                                    	    from
	                                                    	    	TSF_vod__History
   		                                                        where
	   		                                                        createddate > :sinceTimestamp
		                                                        and
		                                                        (
			                                                        field = 'My_Target_vod__c'
			                                                        or
			                                                        field = 'Address_vod__c'
			                                                        or
			                                                        field = 'Territory_vod__c'
						                                            or
						                                            field = 'Account_vod__c'
						                                            or
						                                            field = 'created'
		                                                        )
                                                  			)
						                                AND Account_vod__c <> null
						                                AND Address_vod__c <> null
						                                AND Account_vod__r.isPersonAccount = true
                             			];
 		return convertTSFto_AccontIdToTSFmap(modifiedTSF);
	}



	public Map<ID,TSF_vod__c> getUntargetedEventAttendees(){
		List<TSF_vod__c> tsfsOfActiveEventAttendees =
											[ select Id,My_Target_vod__c,lastmodifieddate,
				                                	Account_vod__c, Account_vod__r.Name, Territory_vod__c,
				                                	Address_vod__r.id,Address_vod__r.name,Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate, Address_vod__r.Primary_vod__c
												from
													TSF_vod__c
												where
													Account_vod__c in
													(
                                                   	   	select Physician__c
														from
															CONGA_Attendance_gne__c
														where
															Event__r.isActive__c = true
													)
													and
													(
													Account_vod__c not in :
														this.activeTargetedPhysicians.keySet()
													)
					                                AND Account_vod__c <> null
					                                AND Address_vod__c <> null
					                                AND Account_vod__r.isPersonAccount = true

													];
		return convertTSFto_AccontIdToTSFmap(tsfsOfActiveEventAttendees);
	}


	public Map<ID,TSF_vod__c> convertTSFto_AccontIdToTSFmap(TSF_vod__c[] tsfs){
        Map<ID,TSF_vod__c>  retIdMap = new Map<ID,TSF_vod__c>();
        for (TSF_vod__c tsf: tsfs){
            if ( retIdMap.get(tsf.Account_vod__c) == null || (retIdMap.get(tsf.Account_vod__c) != null && retIdMap.get(tsf.Account_vod__c).My_Target_vod__c == true))
                retIdMap.put(tsf.Account_vod__c,tsf );
        }
        return retIdMap;
	}

	/*returns TSFs of targeted Physicians - used internally in constructor*/
    private TSF_vod__c[] getTargetedPersonAccounts(){
        				return [SELECT Id,My_Target_vod__c,
                                Account_vod__c, Account_vod__r.Name, Territory_vod__c,
                                Address_vod__r.id,Address_vod__r.name,Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate, Address_vod__r.Primary_vod__c
                                FROM TSF_vod__c
                                WHERE  Territory_vod__c In:userTerritoryNames
                                AND Account_vod__c <> null
                                AND Address_vod__c <> null
                                AND Account_vod__r.isPersonAccount = true
                                AND My_Target_vod__c = true
                                ORDER BY Account_vod__r.Name ASC NULLS FIRST];
    }

    private Set<String> getUserTerritoriesNames(){
        UserTerritory2Association[] userTerritories = [select id,Territory2Id,UserId,SystemModstamp from UserTerritory2Association where isActive = true and userId =: userId  ];
        Set<String> userTerritoryIds = CONGA_Utils.getPropertySetFromList((List<Sobject>)userTerritories,'Territory2Id');
        Territory2[] territories = [select id,Name,SystemModstamp,ParentTerritory2Id from Territory2 where id in: userTerritoryIds ];
        territories = getTerritoryHierarchy(territories);
		//checkTerritoryHierarchyHasBeenChanged(userTerritories, territories);
        return userTerritoryNames = CONGA_Utils.getPropertySetFromList(territories,'Name');
    }

	private void checkTerritoryHierarchyHasBeenChanged(UserTerritory2Association[] usrTerrs, Territory2[] terrs){
		if(lastTimestamp == null){
			return;
		}
		for(UserTerritory2Association usrTerr : usrTerrs){
			if(usrTerr.SystemModstamp > lastTimestamp){
				territoryHierarchyChanged = true;
				return;
			}
		}
		if(!territoryHierarchyChanged){
			for(Territory2 terr : terrs){
				if(terr.SystemModstamp > lastTimestamp){
					territoryHierarchyChanged = true;
					return;
				}
			}
		}
	}

	public List<Territory2> getTerritoryHierarchy(List<Territory2> tList){
		Set<Territory2> terrSet = new Set<Territory2>();
		for(Territory2 terr : tList){
			terrSet.add(terr);
		}
		terrSet = getTerritoryHierarchy(terrSet);
		List<Territory2> resultTerritoryList = new List<Territory2>();
		for(Territory2 terr : terrSet){
			resultTerritoryList.add(terr);
		}
		return resultTerritoryList;
	}

	public Set<Territory2> getTerritoryHierarchy(Set<Territory2> tSet){
		Set<Territory2> resultTerritoryHierarchy = tSet;
		Set<Id> terrIdSet = new Set<Id>();
		for(Territory2 terr : tSet){
			terrIdSet.add(terr.Id);
		}
		List<Territory2> childTerritoryList = [select id,Name,SystemModstamp,ParentTerritory2Id from Territory2 where ParentTerritory2Id in: terrIdSet];
		Set<Territory2> childTerritorySet = new Set<Territory2>(childTerritoryList);
		if(childTerritorySet.size() > 0){
			resultTerritoryHierarchy.addAll(getTerritoryHierarchy(childTerritorySet));
		}
		return resultTerritoryHierarchy;
	}

	public void setAllTerritoryForPhycisians(Set<Id> physicianIdSet){
		List<TSF_vod__c> terrList = [select Id,My_Target_vod__c,lastmodifieddate,Account_vod__c, Account_vod__r.Name, Territory_vod__c,Address_vod__r.id,Address_vod__r.name,Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate, Address_vod__r.Primary_vod__c from TSF_vod__c where Account_vod__c IN: physicianIdSet and Address_vod__c <> null AND Account_vod__r.isPersonAccount = true];
		for(TSF_vod__c tsf : terrList){
			if(!allTerritoryPhycisians.containsKey(tsf.Account_vod__c)){
				allTerritoryPhycisians.put(tsf.Account_vod__c, new List<TSF_vod__c>());
			}
			allTerritoryPhycisians.get(tsf.Account_vod__c).add(tsf);
			if(userTerritoryNames.contains(tsf.Territory_vod__c) && tsf.My_Target_vod__c == true){
				if(!allTargetedTerritoryPhycisians.containsKey(tsf.Account_vod__c)){
					allTargetedTerritoryPhycisians.put(tsf.Account_vod__c, new List<TSF_vod__c>());
				}
				allTargetedTerritoryPhycisians.get(tsf.Account_vod__c).add(tsf);
			}
		}
	}

}