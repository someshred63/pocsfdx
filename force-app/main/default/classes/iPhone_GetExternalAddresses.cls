@RestResource(urlMapping='/iPhoneGetExternalAddresses/*')
global without sharing class iPhone_GetExternalAddresses {

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(List<String> accountIds) {
        return iPhone_Commons_gne.buildResponse(
                new ExternalAddressResponseBuilder(),
                new iPhone_Commons_gne.DefaultDeltaArgs(null, accountIds)
        );
    }

    class ExternalAddressResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args) {
            List<ExternalAddress> addresses = new List<ExternalAddress>();
            return new DeltaRecordsResponse(addresses);
        }
    }

    class ExternalAddress extends iPhone_Commons_gne.DeltaRecord {
        String ai;
        String al1;
        String al2;
        String ct;
        String st;
        String zip;
        String pr;
        String geo;
        String ac;
    }

    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public final List<DeltaRecord> records;

        public DeltaRecordsResponse(List<iPhone_Commons_gne.DeltaRecord> records) {
            this.records = records;
        }
    }
}