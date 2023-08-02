@RestResource(UrlMapping='/iPhoneGetExternalAccounts/*')
global without sharing class iPhone_GetExternalAccounts {

    private static final String HCP = 'hcp';
    private static final String HCO = 'hco';

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId) {
        return iPhone_Commons_gne.buildResponse(
                new ExternalAccountsResponseBuilder(),
                new iPhone_Commons_gne.DefaultDeltaArgs(null, unixId) // Can't use 'Delta' feature here (Territory object does not have CreatedDate field)
        );
    }

    class ExternalAccountsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args) {
            List<ExternalAccountRecord> accounts = new List<ExternalAccountRecord>();
            return new DeltaRecordsResponse(accounts);
        }
    }

    class ExternalAccountRecord extends iPhone_Commons_gne.DeltaRecord {
        String fn;
        String ln;
        String em;
        String ph;
        String rt;
        String nm;
        String ty;
        String rty;
        String sty;
    }

    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public final List<DeltaRecord> records;

        public DeltaRecordsResponse(List<iPhone_Commons_gne.DeltaRecord> records) {
            this.records = records;
        }
    }
}