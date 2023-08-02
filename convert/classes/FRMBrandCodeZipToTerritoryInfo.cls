public class FRMBrandCodeZipToTerritoryInfo {

    String frmBrandCode;
    Set<String> zipCodeSet;

    Set<String> territoryNbrSet = new Set<String>();
    Set<String> territoryIdSet  = new Set<String>();

    Map<String,String> ZipToTerrNbrMap       = new Map<String,String>();
    Map<String,String> TerrNbrToTerrIdMap    = new Map<String,String>();
    Map<String,String> TerrIdToGroupIdMap    = new Map<String,String>();

    private FRMBrandCodeZipToTerritoryInfo () {
    }

    void initialize () {

        // zip to territory nbr map
        Set<String> brandCodeZipKeySet = new Set<String>();
        for (String zip : zipCodeSet) {
            brandCodeZipKeySet.add ( frmBrandCode + '_'+ zip  );
        }


            Zip_To_Territory_gne__c[] zipToTerritoryList =
                    [ select territory_number_gne__c, zip_code_gne__c
                      from   zip_to_territory_gne__c
                      where  brandcode_zip_key_gne__c  in :brandCodeZipKeySet
                    ];

            for (Zip_To_Territory_gne__c zipToTerritory : zipToTerritoryList) {
                territoryNbrSet.add ( zipToTerritory.Territory_Number_gne__c);
                zipToTerrNbrMap.put ( zipToTerritory.zip_code_gne__c,
                                           zipToTerritory.Territory_Number_gne__c);
            }


        // Territory Nbr to Territory Id
        if ( territoryNbrSet.size() > 0 ) {
	            Territory2[] territoryList =
	                    [ select territory_number_gne__c, Id
	                      from   Territory2
	                      where  end_date__c = null
	                             and territory_number_gne__c in :territoryNbrSet
	                    ];

	            for (Territory2 territoryRecord : territoryList ){
	                territoryIdSet.add ( territoryRecord.Id );
	                TerrNbrToTerrIdMap.put ( territoryRecord.territory_number_gne__c,
	                                         territoryRecord.Id );

	            }


	        // Territory Id to Group Id
	            Group[] groupList =
	                    [ select Id, RelatedId
	                      from   Group
	                      where   Type = 'Territory'
	                              and relatedId in :territoryIdSet

	                    ];

	            for (Group groupRecord : groupList ){
	                TerrIdToGroupIdMap.put ( groupRecord.relatedId,
	                                         groupRecord.Id );

	            }
        }
    }

    public FRMBrandCodeZipToTerritoryInfo (String frmBrandCode,
                                           Set<String> zipCodeSet) {
        this.frmBrandCode = frmBrandCode;
        this.zipCodeSet   = zipCodeSet;
        initialize();
    }

    public string getTerritoryNumber (String zipCode) {
    	return zipToTerrNbrMap.get(zipCode);
    }

    public string getTerritoryId (String territoryNbr) {
        return TerrNbrToTerrIdMap.get(territoryNbr);
    }

    public string getGroupId (String territoryNbr) {
        String territoryId = TerrNbrToTerrIdMap.get(territoryNbr);
        String groupId     = null;
        if ( territoryId != null ) {
        	groupId = TerrIdToGroupIdMap.get(territoryId);
        }
        return groupId;
    }
}