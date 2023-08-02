public class GNE_ReltioCalloutHandler {
    public static final String RELTIO_SBC_NAMED_CREDENTIALS = GNE_Foun_Misc_Config_Items_gne__c.getInstance('SBCNamedCredentials').Configuration_Value_gne__c;
    public static final String RELTIO_DCR_NAMED_CREDENTIALS = 'PHARMA_CMG_ICX_DCR_EXP';
    public static final Map<String, List<String>> servicesURLs;
    public static GNE_ReltioSettings__c reltioSettings = GNE_ReltioSettings__c.getInstance();
    static {
        servicesURLs = new Map<String, List<String>> {
            'Resolution_Status'                  => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.RESOLUTION_STATUS__c},
            'License_Sampleability_Info_gne'     => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.CREATE_LICENSE__c},
            'HCP_Reactivate_Address'             => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCP_ADDRESS_REASON__c},
            'HCP_Remove_Inactivate_Address'      => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCP_ADDRESS_REASON__c},
            'HCP_Change_HCP_Info'                => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCP_INFO__c},
            'HCP_Remove_Duplicate'               => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCP_REASON__c},
            'HCP_Remove_Inactivate_HCP'          => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCP_REASON__c},
            'HCP_Existing_Address_Typo_Missing_Info' => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCP_ADDRESS__c},
            'HCP_Reactivate_HCP'                 => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCP_REASON__c},
            'HCO_Change_Organization_Info'       => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCO_INFO__c},
            'HCO_Remove_Duplicate_Organization'  => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCO_REASON__c},
            'HCO_Remove_Inactivate_Organization' => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCO_REASON__c},
            'HCO_Reactivate_Account'             => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCO_REASON__c},
            'HCO_Remove_Inactivate_Address'      => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCO_ADDRESS_REASON__c},
            'HCO_Change_Address'                 => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCO_ADDRESS__c},
            'Duplicate_Address'                  => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.UPDATE_HCP_ADDRESS_REASON__c},
            'Create_Affiliation'                 => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.NEW_AFFILIATION__c},
            'Delete_Affiliation'                 => new List<String>{RELTIO_DCR_NAMED_CREDENTIALS,reltioSettings.END_AFFILIATION__c},
            'NameAddress'                        => new List<String>{RELTIO_SBC_NAMED_CREDENTIALS,reltioSettings.GET_BY_PROFILE__c},
            'License'                            => new List<String>{RELTIO_SBC_NAMED_CREDENTIALS,reltioSettings.GET_BY_LICENSE__c},
            'MDMId'                              => new List<String>{RELTIO_SBC_NAMED_CREDENTIALS,reltioSettings.GET_BY_MDMID__c}
        };
    }

    
    @future(callout=true)
    public static void asynccallReltioEndpoint(String resource, String httpMethod, String requestBody, String params, Map<String, String> mapOfHeaders) {
         callReltioEndpoint(resource, httpMethod, requestBody, params, mapOfHeaders);
    }
    
    public static HttpResponse callReltioEndpoint(String resource, String httpMethod, String requestBody, String params, Map<String, String> mapOfHeaders) {
        String serviceURL = getServiceUrl(resource);
        serviceURL += String.isBlank(params) ? '' : params;
        String namedCredentials = getNamedCredentials(resource);
        HttpResponse res = makeHttpRequest(namedCredentials, serviceURL, httpMethod, requestBody, mapOfHeaders);
        return res;
    }

    public static HttpResponse callReltioEndpoint(String accType, String resource, String httpMethod, String requestBody, String params, Map<String, String> mapOfHeaders) {
        String serviceURL = '/' + accType;
        serviceURL += getServiceUrl(resource);
        serviceURL += String.isBlank(params) ? '' : params;
        String namedCredentials = getNamedCredentials(resource);
        HttpResponse res = makeHttpRequest(namedCredentials, serviceURL, httpMethod, '', mapOfHeaders);
        return res;
    }
    
    public static HttpResponse makeHttpRequest(String namedCredentials, String serviceURL, String httpMethod, String requestBody, Map<String, String> mapOfHeaders) {
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        final String pathSeparator = String.isNotBlank(serviceURL) && serviceURL.startsWith('/') ? '' : '/';
       
        request.setEndpoint('callout:'+namedCredentials + pathSeparator + serviceURL);

        if(httpMethod == 'POST') {
            if(requestBody != null) {
                request.setBody(requestBody);
                System.debug('This is the request Body that we are sending---> '+requestBody);
            } else {
                request.setHeader('Content-Length', '0');
            }
        }

        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        if(mapOfHeaders!=null && mapOfHeaders.keySet().size() > 0) {
            for(String headerName: mapOfHeaders.keySet()){
                request.setHeader(headerName, mapOfHeaders.get(headerName));
            }
        }
        request.setMethod(httpMethod);
        request.setTimeout(120000);
        HttpResponse res;
        try {
            System.debug('Endpoint: ' + request.getEndpoint());
            System.debug('Endpoint: ' + request.getBody());
            res = h.send(request);
        } catch(Exception e) {
            System.debug('An Exception occured while doing a callout=====>>  '+res?.getStatusCode());
            System.debug('This is the Exception =====>  '+e);
            throw e;
        }
        System.debug('This is the Response we are receiving======>>  '+res?.getBody());
        return res;        
    }
    
    
    private static String getServiceUrl(String resource) {
        String result = servicesURLs.get(resource) == null ? '' : servicesURLs.get(resource)[1] ;
        return result;
    }
    
    private static String getNamedCredentials(String resource) {
        String result = servicesURLs.get(resource) == null ? '' : servicesURLs.get(resource)[0] ;
        return result;
    }
}