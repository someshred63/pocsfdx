public class CMT_RESTUtils
{
    public static String DELTA_PARAM_NAME = 'lastSyncDate';
    
    public static String getIdFromUrl (String serviceName, String url)
    {
        // extract the part of the URL that starts after the 'SERVICE_NAME/' substring
        String urlPart = url.substring(url.lastIndexOf(serviceName)+serviceName.length()+1);
        String id = urlPart.split('/')[0];
        
        return id;
    }
    
    public static String getDeltaParam (RestRequest req)
    {
        return req.params.get(DELTA_PARAM_NAME);
    }
    
    /*
    public static String getQueryParam (String url, String paramName)
    {
        Map<String, String> params = getQueryParams(url);
        return params != null ? params.get(paramName) : null;
    }
    
    private static Map<String, String> getQueryParams (String url)
    {
        if (url == null)
        {
            return null;
        }
        String queryString = getQueryString(url);
        
        Map<String, String> params = new Map<String, String>();
        
        if (queryString == null)
        {
            // return empty params
            return params;
        }
        
        // split query string by the ampersand character
        String[] paramPairs = queryString.split('&');
        
        for (String paramPair : paramPairs)
        {
            String[] pair = paramPair.split('=');
            params.put(pair[0], pair[1]);
        }
        
        return params;
    }
    
    private static String getQueryString (String url)
    {
        if (url == null)
        {
            return null;
        }
        String[] urlParts = url.split('\\?');
        return urlParts.size() > 1 ? urlParts[1] : null;
    }*/
}