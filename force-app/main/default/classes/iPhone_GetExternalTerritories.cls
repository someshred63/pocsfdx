@RestResource(UrlMapping='/iPhoneGetExternalTerritories/*')
global without sharing class iPhone_GetExternalTerritories {


    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId) {
        return iPhone_Commons_gne.buildResponse(
                new ExternalAccountsResponseBuilder(),
                new iPhone_Commons_gne.DefaultDeltaArgs(null, unixId) // Can't use 'Delta' feature here (Territory object does not have CreatedDate field)
        );
    }

    class ExternalAccountsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args) {
            List<ExternalTerritoryRecord> territories = new List<ExternalTerritoryRecord>();
            return new DeltaRecordsResponse(territories);
        }
    }

    class ExternalTerritoryRecord extends iPhone_Commons_gne.DeltaRecord {
        String dn;
        String nm;
    }

    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public final List<DeltaRecord> records;

        public DeltaRecordsResponse(List<iPhone_Commons_gne.DeltaRecord> records) {
            this.records = records;
        }
    }
}