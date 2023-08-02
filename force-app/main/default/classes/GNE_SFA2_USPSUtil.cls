public with sharing class GNE_SFA2_USPSUtil {

	private static final Set<String> USPS_XML_LABELS = new Set<String>{'Address1','Address2','City','State','Zip5','Zip4','Number','Source','Description','HelpFile','HelpContext'};
	
	public static String buildAddressValidateRequest(String uspsUserId, Map<String, String> params) {
    	String result = '<AddressValidateRequest USERID="' + uspsUserId + '"><Address>';
    	result += '<Address1>' + (params.containsKey('address1') && String.isNotBlank(params.get('address1')) ? params.get('address1') : '') + '</Address1>';
		result += '<Address2>' + (params.containsKey('address2') && String.isNotBlank(params.get('address2')) ? params.get('address2') : '') + '</Address2>';
		result += '<City>' + (params.containsKey('city') && String.isNotBlank(params.get('city')) ? params.get('city') : '') + '</City>';
		result += '<State>' + (params.containsKey('state') && String.isNotBlank(params.get('state')) ? params.get('state') : '') + '</State>';
		result += '<Zip5>' + (params.containsKey('zip5') && String.isNotBlank(params.get('zip5')) ? params.get('zip5') : '') + '</Zip5>';
		result += '<Zip4>' + (params.containsKey('zip4') && String.isNotBlank(params.get('zip4')) ? params.get('zip4') : '') + '</Zip4>';
		result += '</Address></AddressValidateRequest>';
		return result;
    }

    public static String buildAddressesValidateRequest(String uspsUserId, Map<String, Map<String, String>> params) {
        Integer count = 0;
        String result = '<AddressValidateRequest USERID="' + uspsUserId + '">';
        for(String key : params.keySet()) {
            count += 1;
            if(count <= 5) {
                result += '<Address ID="' + key + '">';
                result += '<Address1>' + (params.get(key).containsKey('address1') && String.isNotBlank(params.get(key).get('address1')) ? params.get(key).get('address1') : '') + '</Address1>';
                result += '<Address2>' + (params.get(key).containsKey('address2') && String.isNotBlank(params.get(key).get('address2')) ? params.get(key).get('address2') : '') + '</Address2>';
                result += '<City>' + (params.get(key).containsKey('city') && String.isNotBlank(params.get(key).get('city')) ? params.get(key).get('city') : '') + '</City>';
                result += '<State>' + (params.get(key).containsKey('state') && String.isNotBlank(params.get(key).get('state')) ? params.get(key).get('state') : '') + '</State>';
                result += '<Zip5>' + (params.get(key).containsKey('zip5') && String.isNotBlank(params.get(key).get('zip5')) ? params.get(key).get('zip5') : '') + '</Zip5>';
                result += '<Zip4>' + (params.get(key).containsKey('zip4') && String.isNotBlank(params.get(key).get('zip4')) ? params.get(key).get('zip4') : '') + '</Zip4>';
                result += '</Address>';
            }
        }
        result += '</AddressValidateRequest>';

        return result;
    }

    public static String buildCityStateLookupRequest(String uspsUserId, Map<String, String> params) {
    	String result = '<CityStateLookupRequest USERID="' + uspsUserId + '"><ZipCode>';
		result += '<Zip5>' + (params.containsKey('zip5') && String.isNotBlank(params.get('zip5')) ? params.get('zip5') : '') + '</Zip5>';
		result += '</ZipCode></CityStateLookupRequest>';
		return result;
    }

    public static String buildZipCodeLookupRequest(String uspsUserId, Map<String, String> params) {
    	String result = '<ZipCodeLookupRequest USERID="' + uspsUserId + '"><Address>';
    	result += '<Address1>' + (params.containsKey('address1') && String.isNotBlank(params.get('address1')) ? params.get('address1') : '') + '</Address1>';
		result += '<Address2>' + (params.containsKey('address2') && String.isNotBlank(params.get('address2')) ? params.get('address2') : '') + '</Address2>';
		result += '<City>' + (params.containsKey('city') && String.isNotBlank(params.get('city')) ? params.get('city') : '') + '</City>';
		result += '<State>' + (params.containsKey('state') && String.isNotBlank(params.get('state')) ? params.get('state') : '') + '</State>';
		result += '</Address></ZipCodeLookupRequest>';
		return result;
    }

    public static String parseResponse(HTTPResponse res) {
    	Map<String, String> response = GNE_SFA2_XMLParser.getValuesForXMLElements(USPS_XML_LABELS, res);
    	USPSAddress uspsAddress = new USPSAddress(response.get('Address1'),
    											  response.get('Address2'),
    											  response.get('City'),
    											  response.get('State'),
    											  response.get('Zip5'),
    											  response.get('Zip4')
    								  );

    	USPSError uspsError = new USPSError(response.get('Number'),
    									    response.get('Source'),
    									    String.isNotBlank(response.get('Description')) ? response.get('Description').replaceAll( '[ ]{2,}', ' ').removeEnd(' ') : null,
    									    response.get('HelpFile'),
    									    response.get('HelpContext')
    							  );
    	return JSON.serialize(new USPSResponse(uspsAddress, uspsError));
    }

    public class USPSResponse {
    	protected USPSAddress uspsAddress;
    	protected USPSError uspsError;

    	public USPSResponse() {}

    	public USPSResponse(USPSAddress uspsAddress, USPSError uspsError) {
    		this.uspsAddress = uspsAddress;
    		this.uspsError = uspsError;
    	}
    }

    public class USPSAddress {
    	protected String address1;
		protected String address2;
		protected String city;
		protected String state;
		protected String zip5;
		protected String zip4;

		public USPSAddress() {}
		
		public USPSAddress(String address1, String address2, String city, String state, String zip5, String zip4) {
			this.address1 = address1;
			this.address2 = address2;
			this.city = city;
			this.state = state;
			this.zip5 = zip5;
			this.zip4 = zip4;
		}
    }

    public class USPSError {
    	protected String errorNumber;
    	protected String source;
    	protected String description;
    	protected String helpFile;
    	protected String helpContext;

    	public USPSError() {}

    	public USPSError(String errorNumber, String source, String description, String helpFile, String helpContext) {
    		this.errorNumber = errorNumber;
    		this.source = source;
    		this.description = description;
    		this.helpFile = helpFile;
    		this.helpContext = helpContext;
    	}
    }

}