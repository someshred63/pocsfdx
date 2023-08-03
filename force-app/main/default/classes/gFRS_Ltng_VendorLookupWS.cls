//Generated by wsdl2apex

public class gFRS_Ltng_VendorLookupWS {
    public class GneCOMM_VendorMaster_SAP_ServicesPort0 {
        //public String endpoint_x = gFRS_Util.getCustomSettingStringValue('WS_VendorLookup_Endpoint');
        //public String endpoint_x = 'https://wm103com-ext-qa.roche.com/ws/GneCOMM_VendorMaster.GFRS_I_1.WSD:VendorLookup_2/GneCOMM_VendorMaster_GFRS_I_1_ServicesBinding';
        //public String endpoint_x = System.Label.gFRS_2_0_Vendor_Lookup_Endpoint;
        public GFRS_Ltng_OrgSettings__c cs = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        public String endpoint_x = String.valueOf(cs.get('WS_VendorLookup_Endpoint__c'));
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        
        private String[] ns_map_type_info = new String[]{'http://www.webmethods.com/', 'gFRS_Ltng_VendorLookupWS', System.Label.gFRS_WS_ESB_SAP_TYPES, 'gFRS_Ltng_VendorLookupSAP', 'http://localhost/GneCOMM_VendorMaster/SAP/Services/VendorLookup', 'GFRS_VendorLookupGFRS'};
        
        public gFRS_Ltng_VendorLookupSAP.VendorLookupResponse_element VendorLookup(String Name,String Id,String TaxId,String Sort_x,String filterInactive,String MaxRecords) {
            gFRS_Ltng_VendorLookupSAP.VendorLookup_element request_x = new gFRS_Ltng_VendorLookupSAP.VendorLookup_element();
            gFRS_Ltng_VendorLookupSAP.VendorLookupResponse_element response_x;
            request_x.Name           = Name;
            request_x.Id             = Id;
            request_x.TaxId          = TaxId;
            request_x.Sort_x         = Sort_x;
            request_x.filterInactive = filterInactive;
            request_x.MaxRecords     = MaxRecords;
            Map<String, gFRS_Ltng_VendorLookupSAP.VendorLookupResponse_element> response_map_x = new Map<String, gFRS_Ltng_VendorLookupSAP.VendorLookupResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(this, request_x, response_map_x, new String[]{
                String.isBlank(endpoint_x) ? System.Label.gFRS_WS_ESB_VendorLookup_ENDPOINT : endpoint_x,
                '',
                System.Label.gFRS_WS_ESB_SAP_TYPES,
                'VendorLookup',
                System.Label.gFRS_WS_ESB_SAP_TYPES,
                'VendorLookupResponse',
                'gFRS_Ltng_VendorLookupSAP.VendorLookupResponse_element'
            });
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}