/* This function returns signature using HmacSHA1 Algorithm. 

Author: Rakesh 09/09/2011. 
   */ 


public class TISL_GenerateKey {

 

  private static String keyString = 'nswTg7SRvNCPdEs5r_TkSW2L3jQ=';
  
  
  private blob  key;
  // This variable stores the binary key, which is computed from the string (Base64) key
    
  public String getSig(String inputUrl)  {
    
     
    // Convert the string to a URL so we can parse it
    URL url = new URL(inputUrl);
    
    System.debug('my url'+ url);
 
    String path,query;
    path=url.getPath();
    
    System.debug('my path'+path);
    query=url.getQuery();
     System.debug('my query'+query);
    // Convert the key from 'web safe' base 64 to binary
   // keyString=inputUrl;
    keyString = keyString.replace('-', '+');
    keyString = keyString.replace('_', '/');
   
    
     
    // Retrieve the proper URL components to sign
    String resource = path + '?' + query;
    System.debug('resource'+ resource);
     Blob mac = Crypto.generateMac('HmacSHA1',  Blob.valueof(resource), 
                                                    EncodingUtil.base64Decode(keyString));
     String signature = EncodingUtil.base64Encode(mac);
     signature = signature.replace('+', '-');
     signature = signature.replace('/', '_');
     System.debug('my final signature'+ signature);
    return    url.getProtocol() + '://' + url.getHost()+resource + '&signature=' + signature;
   
  }
}