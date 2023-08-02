@RestResource(urlMapping='/iPhoneGetAddressesToAutocomplete')
global without sharing class iPhone_GetAddressesToAutocomplete  {

    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String state) {
        
        return iPhone_Commons_gne.buildResponse(
                new AddressResponseBuilder(),
                state
        );                              
    }

    global class AddressResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args){
            String state = (String)args;
            List<AddressRecord> addresses = new List<AddressRecord>();
            
            Map<String, Set<String>> tempAddressMap = new Map<String, Set<String>>();
            for(USPS_Address_gne__c addr : [SELECT City_gne__c, Zip_gne__c FROM USPS_Address_gne__c WHERE State_gne__c =: state]) {
                if(!tempAddressMap.containsKey(addr.City_gne__c)) {
                    tempAddressMap.put(addr.City_gne__c, new Set<String>{addr.Zip_gne__c});
                } else {
                    tempAddressMap.get(addr.City_gne__c).add(addr.Zip_gne__c);
                }
            }

            for(String key : tempAddressMap.keySet()) {
                addresses.add(new AddressRecord(key, state, tempAddressMap.get(key)));
            }                  
            return new DeltaRecordsResponse(addresses);
        }
    }

    global class AddressRecord {
        protected String city;
        protected String state;
        protected Set<String> zip;

        public AddressRecord(String city, String state, Set<String> zip) {
            this.city = city;
            this.state = state;
            this.zip = zip;
        }
    }

    global class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse{
        public final List<AddressRecord> addresses;
        
        public DeltaRecordsResponse(List<AddressRecord> addresses) {
            this.addresses = addresses;
        }
    }
}