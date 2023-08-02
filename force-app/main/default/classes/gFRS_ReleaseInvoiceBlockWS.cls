public class gFRS_ReleaseInvoiceBlockWS {
    public class GneCOMM_Grants_SFDC_O_1Port0 {
        public String endpoint_x = gFRS_Util.getCustomSettingStringValue('WS_ReleaseInvoiceBlock_Endpoint');
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{System.Label.gFRS_WS_ESB_SAP_TYPES, 'gFRS_ReleaseInvoiceBlockSAP', 'http://localhost/GneCOMM_Grants/SFDC_O_1/releaseInvoiceBlock', 'gFRS_ReleaseInvoiceBlockGFRS'};
        
        public gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element releaseInvoiceBlock(String SAPDocumentId,String fiscalYear) {
            gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlock_element request_x = new gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlock_element();
            gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element response_x;
            request_x.SAPDocumentId = SAPDocumentId;
            request_x.fiscalYear    = fiscalYear;
            Map<String, gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element> response_map_x = new Map<String, gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(this, request_x, response_map_x, new String[]{
                String.isBlank(endpoint_x) ? System.Label.gFRS_WS_ESB_ReleaseInvoiceBlock_ENDPOINT : endpoint_x,
                '',
                System.Label.gFRS_WS_ESB_SAP_TYPES,
                'releaseInvoiceBlock',
                System.Label.gFRS_WS_ESB_SAP_TYPES,
                'releaseInvoiceBlockResponse',
                'gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element'
            });
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}