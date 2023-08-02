//@author CHAVVAS - GFRS DEV Team
//@date 25/11/2021
//@description - Manually created class to handle gFRS 2.0 Payments
public class gFRS_SubmitGrantLtngWS {
    public class GneCOMM_Grants_SFDC_O_1Port0 {
        public String endpoint = gFRS_Ltng_Util.getCustomSettingStringValue('WS_SubmitGrant_Endpoint');
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        
        private String[] ns_map_type_info = new String[]{'http://localhost/GneCOMM_Grants/SFDC_O_1/submitGrant', 'gFRS_SubmitGrantSAP', System.Label.gFRS_WS_ESB_SAP_TYPES, 'gFRS_SubmitGrantGFRS'};

        public gFRS_SubmitGrantSAP.submitGrantResponse_element submitGrant(String requestId,String documentType,String companyCode,Date postingDate,Date baselineDate,String currencyCode,String headerText,gFRS_SubmitGrantSAP.Details_element Details) {
            gFRS_SubmitGrantSAP.submitGrant_element request_x = new gFRS_SubmitGrantSAP.submitGrant_element();
            gFRS_SubmitGrantSAP.submitGrantResponse_element response_x;
            request_x.requestId    = requestId;
            request_x.documentType = documentType;
            request_x.companyCode  = companyCode;
            request_x.postingDate  = postingDate;
            request_x.baselineDate = baselineDate;
            request_x.currencyCode = currencyCode;
            request_x.headerText   = headerText;
            request_x.Details      = Details;
            Map<String, gFRS_SubmitGrantSAP.submitGrantResponse_element> response_map_x = new Map<String, gFRS_SubmitGrantSAP.submitGrantResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke( this, request_x, response_map_x, new String[]{
                endpoint,
                '',
                System.Label.gFRS_WS_ESB_SAP_TYPES,
                'submitGrant',
                System.Label.gFRS_WS_ESB_SAP_TYPES,
                'submitGrantResponse',
                'gFRS_SubmitGrantSAP.submitGrantResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}