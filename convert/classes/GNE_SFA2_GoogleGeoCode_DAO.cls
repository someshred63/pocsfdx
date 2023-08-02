public with sharing class GNE_SFA2_GoogleGeoCode_DAO {
  private static final String ERROR_STATUS_DAILY_LIMIT_EXCEEDED = 'You have exceeded your daily request quota for this API.';
  
  private transient String clientId;
  private transient String key;
  
  public GNE_SFA2_GoogleGeoCode_DAO() {
  }
  
  public AddressCoords getAddressCoords(Address_vod__c addr) {
    return getAddressCoords(getAddressSearchText(addr), false);
  }
  
  public AddressCoords getAddressCoords(Address_vod__c addr, Boolean safeMode) {
    return getAddressCoords(getAddressSearchText(addr), safeMode);
  }
  
  public AddressCoords getAddressCoords(String addrInputText, Boolean safeMode) {
  	AddressCoords result = null;
  	
  	try {
  		result = intGetAddressCoords(addrInputText);
  	} catch(GoogleGeoCodeServiceException ggce) {
  		if(safeMode!=true) {
  		  throw ggce;
  		}
  	}
  	
  	return result;
  }
  
  private String getClientId() {
    readAuthData();
    return clientId;
  }
  
  private String getKey() {
    readAuthData();
    return key;
  }
  
  public void encryptData(String currentClientId, String currentKey, String clientId, String key) {
    if(currentClientId.equals(getClientId()) && currentKey.equals(getKey())) {
      String clientIdAsKey = clientId + '='.repeat(14-clientId.length());
      Blob enryptedKey = Crypto.encryptWithManagedIV('AES128', Blob.valueof(JSON.serialize(clientIdAsKey).substring(0,16)), Blob.valueof(key));
      Blob enryptedClientId = Crypto.encryptWithManagedIV('AES128', Blob.valueOf(JSON.serialize(enryptedKey).substring(0,16)), Blob.valueof(clientId));
  
      System.debug(JSON.serialize(enryptedClientId));
      System.debug(JSON.serialize(enryptedKey));
    } else {
      System.debug('Authorization failed!');
    }
  }
  
  private void readAuthData() {
    if(clientId==null) {
      String clientIdString = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCGeoCodeClientId);
      String keyString = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCGeoCodeKey);
      
      Blob decryptedClientId = Crypto.decryptWithManagedIV('AES128', Blob.valueof(keyString.substring(0,16)), (Blob)JSON.deserialize(clientIdString, Blob.class));
      clientId = decryptedClientId.toString();
      String clientIdAsKey = clientId + '='.repeat(14-clientId.length());
      Blob decryptedKey = Crypto.decryptWithManagedIV('AES128', Blob.valueof(JSON.serialize(clientIdAsKey).substring(0,16)), (Blob)JSON.deserialize(keyString, Blob.class));
      key = decryptedKey.toString();
    }
  }
  
  private AddressCoords intGetAddressCoords(String addrInputText) {
  	AddressCoords result = null;
  	HttpRequest req = new HttpRequest();
    Http http = new Http();
    req.setMethod('GET');
    String url= String.format('{0}?address={1}&client={2}', new String[]{
    	'http://maps.googleapis.com/maps/api/geocode/json',
    	EncodingUtil.urlEncode(addrInputText,'UTF-8'),
    	getClientId()
    });
    
    url = new KeyGenerator(getKey()).getSig(url);
    req.setEndpoint(url);
    HTTPResponse res = http.send(req);
    
    
    if(res.getStatus() == 'OK' && res.getStatusCode() == 200) {
      String bodyInJSON = res.getBody();
      GoogleGeoCodeResponse ggcResponse = (GoogleGeoCodeResponse)JSON.deserialize(bodyInJSON, GoogleGeoCodeResponse.class);
      
      if(ggcResponse==null) {
        throw new GoogleGeoCodeServiceException('No response for ||' + addrInputText, 200);
      } else if(ggcResponse.status!='OK' && ggcResponse.status!='ZERO_RESULTS') {
      	String message = String.isNotBlank(ggcResponse.error_message) ? ggcResponse.error_message : ggcResponse.status;
      	throw new GoogleGeoCodeServiceException(message, 200);
      } else if(ggcResponse.status=='OK') {
      	GoogleGeoCodeAddress ggcAddr = ggcResponse.results[0];
      	result = new AddressCoords(ggcAddr.geometry.location);
      }
    } else {
    	String status = res.getStatus();
      Integer statusCode = res.getStatusCode();
      throw new GoogleGeoCodeServiceException(status, statusCode);
    }
    
    return result;
  }
  
  private String getGoogleClientId() {
  	return GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCGeoCodeClientId);
  }
  
  private String getAddressSearchText(Address_vod__c addr) {
  	return String.isNotBlank(addr.Name)
  	  ? String.format('{0}, {1}, {2} {3}', new String[] {addr.Name, addr.City_vod__c, addr.State_vod__c, addr.Zip_vod__c})
  	  : String.format('{1}, {2} {3}', new String[] {addr.City_vod__c, addr.State_vod__c, addr.Zip_vod__c}); 
  }
  
  private class GoogleGeoCodeResponse {
  	private List<GoogleGeoCodeAddress> results;
  	private String status;
  	private String error_message;
  }
  
  private class GoogleGeoCodeAddress {
  	private GoogleGeoCodeGeometry geometry;
  	private String formatted_address;
  	private String place_id;
  	
  }
  
  private class GoogleGeoCodeGeometry {
    private GoogleGeoCodeLocation location;
    private String location_type;
  }
  
  private class GoogleGeoCodeLocation {
  	private Double lat;
  	private Double lng;
  }
  
  private class KeyGenerator {
    private Blob key;
    
    private KeyGenerator(String key) {
      this.key = EncodingUtil.base64Decode(key.replace('-', '+').replace('_', '/'));
    }
    
    // This variable stores the binary key, which is computed from the string (Base64) key
    private String getSig(String inputUrl)  {
      // Convert the string to a URL so we can parse it
      URL url = new URL(inputUrl);
      String path, query;
      path=url.getPath();
      query=url.getQuery();
      // Retrieve the proper URL components to sign
      String resource = path + '?' + query;
      Blob mac = Crypto.generateMac('HmacSHA1',  Blob.valueof(resource), key);
      String signature = EncodingUtil.base64Encode(mac);
      signature = signature.replace('+', '-');
      signature = signature.replace('/', '_');
	    return url.getProtocol() + '://' + url.getHost()+resource + '&signature=' + signature;
    }
  }
  
  public class AddressCoords {
  	public Double latitude;
  	public Double longitude;
  	
  	public AddressCoords(GoogleGeoCodeLocation ggcLoc) {
  		this.latitude = ggcLoc.lat;
  		this.longitude = ggcLoc.lng;
  	}
  }
  
  public class GoogleGeoCodeServiceException extends Exception {
  	public String status;
    public Integer statusCode;
    
  	public GoogleGeoCodeServiceException(String status, Integer statusCode) {
  		this(String.format('Google GeoCode Service Error [Status = {0}, Code = {1}]', new String[]{status, String.valueOf(statusCode)}));
      this.status = status;
      this.statusCode = statusCode;
  	}
  	
  	public Boolean isLimitExceeded() {
  	    return this.status==ERROR_STATUS_DAILY_LIMIT_EXCEEDED;
  	}
  }
}