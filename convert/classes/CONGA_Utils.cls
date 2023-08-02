public with sharing class CONGA_Utils {

	public Set<String> userTerritoryNames  ;

    public TSF_vod__c[] getTargetedPersonAccounts(){
        //TODO Can it be joined with getMyTargetedPhysiciansFromMyTerritory? are there accounts without history?
        				return [SELECT Id,My_Target_vod__c,
                                Account_vod__c, Account_vod__r.Name, Territory_vod__c,
                                Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate
                                FROM TSF_vod__c
                                WHERE  Territory_vod__c In:userTerritoryNames
                                AND Account_vod__c <> null
                                AND Address_vod__c <> null
                                AND Account_vod__r.isPersonAccount = true
                                AND My_Target_vod__c = true
                                ORDER BY Account_vod__r.Name ASC NULLS FIRST];
    }


    /*returns tsf for physicians that were changed since @sinceTimestamp */
    public TSF_vod__c[] getTargetedPhysiciansFromMyTerritory(Datetime sinceTimestamp){
    					return [SELECT Id,My_Target_vod__c,lastmodifieddate,
                                Account_vod__c, Account_vod__r.Name, Territory_vod__c,
                                Address_vod__r.Name, Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate

                                FROM TSF_vod__c
                                WHERE
                                Account_vod__r.isPersonAccount = true
                                AND Account_vod__c <> null
                                AND Address_vod__c <> null
                                AND My_Target_vod__c = true
                                AND Territory_vod__c In:userTerritoryNames
                       			AND Account_vod__c in ( select AccountId
                                                       from AccountHistory
                                                       where createddate > :sinceTimestamp
                                                       and (field = 'LastName' or field = 'FirstName' )
                                                      )
                                ];
    }

   /*returns tsf for physicians that were changed since @sinceTimestamp */
    public TSF_vod__c[] getTargetedPhysiciansFromMyTerritoryWithChangedAddressOrCreatedTSF(Datetime sinceTimestamp){
    					return [SELECT Id,My_Target_vod__c,lastmodifieddate,
                                Account_vod__c, Account_vod__r.Name, Territory_vod__c,
                                Address_vod__r.Name, Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate

                                FROM TSF_vod__c
                                WHERE
                                Account_vod__r.isPersonAccount = true
                                AND Account_vod__c <> null
                                AND Address_vod__c <> null
                                AND My_Target_vod__c = true
                                AND Territory_vod__c In:userTerritoryNames

			                    AND
                                (//physician addres was modified --not sure if it's needed
                                    Address_vod__r.lastmodifieddate >:sinceTimestamp
                                OR
                         		createddate > :sinceTimestamp
                                )
                                ];
    }

    public TSF_vod__c[] getChangedTSFforTargetedPhysiciansFromMyTerritoryWithChangedTSF(Datetime sinceTimestamp){
    					return [SELECT Id,My_Target_vod__c,lastmodifieddate,
                                Account_vod__c, Account_vod__r.Name, Territory_vod__c,
                                Address_vod__r.Name, Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate
                                FROM TSF_vod__c
                                WHERE
                                Account_vod__r.isPersonAccount = true
                                AND Account_vod__c <> null
                                AND Address_vod__c <> null
                                AND My_Target_vod__c = true
                                AND Territory_vod__c In:userTerritoryNames
                                AND id in ( SELECT ParentId
							                                FROM TSF_vod__History
				                                						where createddate > :sinceTimestamp
				                                						and ( field = 'Account_vod__c'	or field = 'My_Target_vod__c'	or field = 'Territory_vod__c'	)
			                                			)
                               ];
    }

	/* return tsfs related to attendees of active events*/
    public TSF_vod__c[] getPhysiciansAssignedToActiveEvents(){
    					return [SELECT Id,My_Target_vod__c,lastmodifieddate,
                                Account_vod__c, Account_vod__r.Name, Territory_vod__c,
                                Address_vod__r.Name, Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate
                                FROM TSF_vod__c
                                WHERE
                                Account_vod__c in ( SELECT Physician__c
							                                FROM CONGA_Attendance_gne__c
				                                						where
				                                						Event__r.isActive__c = true
			                                	  )
                               ];
    }

	/* return tsfs related to attendees of active events*/
    public TSF_vod__c[] getPhysiciansAssignedToActiveEventsOrTargetedPhysicians(Datetime sinceTimestamp){
    					return [SELECT Id,My_Target_vod__c,lastmodifieddate,
                                Account_vod__c, Account_vod__r.Name, Territory_vod__c,
                                Address_vod__r.Name, Address_vod__r.City_vod__c, Address_vod__r.Province_can_gne__c, Address_vod__r.Postal_Code_can_gne__c,Address_vod__r.Country_vod__c,Address_vod__r.Country_gen__c,Address_vod__r.Latitude_vod__c,Address_vod__r.Longitude_vod__c, Address_vod__r.lastmodifieddate
                                FROM TSF_vod__c
                                WHERE
                                Account_vod__c in ( SELECT Physician__c
							                                FROM CONGA_Attendance_gne__c
				                                						where
				                                						Event__r.isActive__c = true
			                                	  )

                               ];
    }



    public Set<String> getUserTerritoriesNames(String userId){
        UserTerritory2Association[] userTerritories = [select id,Territory2Id,UserId from UserTerritory2Association where isActive = true and userId =: userId  ];
        Set<String> userTerritoryIds = CONGA_Utils.getPropertySetFromList((List<Sobject>)userTerritories,'Territory2Id');
        Territory2[] territories = [select id,Name from Territory2 where id in: userTerritoryIds];
        return userTerritoryNames = CONGA_Utils.getPropertySetFromList(territories,'Name');
    }

    public static user getUserByUserName(String username){
    	return [select id from user where username like :username+'%'][0];
    }


	public static String encodeToTokenInBase64(Long timestamp, Boolean secondTokenFlag){
		Blob TokenAndFlag = Blob.valueOf(''+timestamp +';'+ secondTokenFlag);
		return EncodingUtil.base64Encode(TokenAndFlag );
	}


    public static Set<ID> getSObjectsSetIds(List<sObject> sobjectList ){
    	Set<ID>  retIdSet = new Set<ID> ();
    	for (sObject obj: sobjectList){
    		System.assertNotEquals(null,obj.id, 'getSObjectsSetIds - object.id was null ' );
    		retIdSet.add(obj.id);
    	}
    	return retIdSet;
    }


    public static Set<ID> getIpropertiesSetIds(List<CONGA_Iproperties> propertiesList){
    	Set<ID>  retIdSet = new Set<ID> ();
    	for (CONGA_Iproperties property: propertiesList){
    		System.assertNotEquals(null,property.id, 'getSObjectsSetIds - object.id was null ' );
    		retIdSet.add(property.id);
    	}
    	return retIdSet;
    }

    public static Map<ID,CONGA_Iproperties> getIPropertiesIdMap(List<CONGA_Iproperties> propertiesList){
    	Map<ID,CONGA_Iproperties> retIdMap = new Map<ID,CONGA_Iproperties> ();
    	for (CONGA_Iproperties property: propertiesList){
    		if (property.id != null)
    			retIdMap.put(property.id, property);
    	}
    	return retIdMap;
    }

    public static Map<String,SObject> getUniqueField2sObj(List<SObject> sObjList, String uniqueFieldName){
    	Map<String,SObject> retIdMap = new Map<String,SObject> ();
    	for (SObject sobj: sObjList){
    		if ( (retIdMap.get((String)sobj.get(uniqueFieldName))!= null ) || sobj==null ) System.assert(false,'this external field already exists' +  retIdMap.get((String)sobj.get(uniqueFieldName)) + '  xxx -new: ' + sobj); //TODO remove this liene
    		retIdMap.put((String)sobj.get(uniqueFieldName), sobj);
    		System.debug(LoggingLevel.Info,sobj.get(uniqueFieldName));
    	}
        System.assertEquals(sObjList.size(), retIdMap.values().size(), 'Probably ' + uniqueFieldName + ' is not Unique key');
    	return retIdMap;
    }

    public static Set<String> getPropertySetFromList(List<SObject> sObjList, String fieldName){
    	Set<String>  retSet = new Set<String> ();
    	for (SObject sObj: sObjList){
    		retSet.add((String)sObj.get(fieldName));
    	}
    	return retSet;
    }



}