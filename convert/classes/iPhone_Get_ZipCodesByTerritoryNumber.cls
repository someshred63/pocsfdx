@RestResource(urlMapping='/iPhoneGetZipCodesByTerritoryNumber/*')
global class iPhone_Get_ZipCodesByTerritoryNumber {
    private static final Integer QUERY_LIMIT = 30000;

    @HttpPost
    global static iPhone_Commons_gne.RestResponse buildResponse(String unixId, String terrNumber, String lastZip) {
        return iPhone_Commons_gne.buildResponse(
            new ZipCodesByTerritoryNumberBuilder(),
            new RequestArgs(unixId, terrNumber, lastZip)
        );
    }

    global class ZipCodesByTerritoryNumberBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args){
            RequestArgs deltaArgs = (RequestArgs)args;
            String terrNumber = deltaArgs.territoryNumber;
            String lastZip = deltaArgs.lastZip == null ? '' : deltaArgs.lastZip;
            List<String> zips = prepareListOfZips(fetchZipCodes(terrNumber, lastZip));

            return new DeltaRecordsResponse(zips);
        }

        private List<String> prepareListOfZips(Zip_to_Territory_gne__c [] collection) {
            List<String> zips = new List<String>();
            for(Zip_to_Territory_gne__c zip : collection){
                zips.add(zip.Zip_Code_gne__c);
            }
            zips.sort();

            return zips;
        }

        private Zip_to_Territory_gne__c [] fetchZipCodes(String territoryNumber, String lastZip) {
            Territory2 [] terr = [SELECT Territory_Number_gne__c FROM Territory2 WHERE id = :territoryNumber AND Territory_Number_gne__c != null];
            if(terr.isEmpty()){
                return new List<Zip_to_Territory_gne__c>();
            } else {
                return [
                    SELECT Zip_Code_gne__c
                    FROM Zip_to_Territory_gne__c
                    WHERE Territory_Number_gne__c = : terr[0].Territory_Number_gne__c
                        AND Zip_Code_gne__c > :lastZip
                    ORDER BY Zip_Code_gne__c
                    LIMIT : QUERY_LIMIT
                ];
            }
        }
    }

    global class RequestArgs extends iPhone_Commons_gne.DefaultDeltaArgs{
        public String territoryNumber;
        public String lastZip;

        public RequestArgs(String unixId, String terrNumber, String lastZip){
            this(null, unixId, null, false, null);
            this.territoryNumber = terrNumber;
            this.lastZip = lastZip;
        }

        public RequestArgs(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion){
            super(lastSyncDate, unixId, accountIds, enhDelta, otrVersion);
        }
    }

    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse{
        public final List<String> zc;
        public String lastZip;

        public DeltaRecordsResponse(List<String> zips) {
            this.zc = zips;
            this.lastZip = zips.size() == QUERY_LIMIT ? lastZip = zips[QUERY_LIMIT -1] : '';
        }
    }
}