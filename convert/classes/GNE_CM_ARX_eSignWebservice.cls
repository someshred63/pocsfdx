public class GNE_CM_ARX_eSignWebservice {
    public class AssistRx_SMN_SoapPort {
         //public String endpoint_x = 'http://dev.smn.iassist.com/index.php/esmn_service/wsdl';
        public Set<String> envVarNameSet = new Set<String>{GNE_CM_MPS_Utils.GNE_CM_MPS_ARX_ESIGN_ENDPOINT};
        public Map<String, List<Environment_Variables__c>> envVarMultiValues = GNE_CM_MPS_Utils.populateEnvVariables(envVarNameSet);
        public List<Environment_Variables__c> envVarList = envVarMultiValues.get(GNE_CM_MPS_Utils.GNE_CM_MPS_ARX_ESIGN_ENDPOINT);
        //public String endpoint_x = envVarList[0].value__c + '/index.php/esmn_service/wsdl';
        public String endpoint_x = envVarList[0].value__c + '/esmn_service/wsdl';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:AssistRx_SMN_Soap', 'GNE_CM_ARX_eSignWebservice'};
        public GNE_CM_ARX_eSignWebservice.ProcessDocumentResponseType ProcessDocument(String UserId,String SessionId,String ObjectId,String TransactionId) {
            GNE_CM_ARX_eSignWebservice.ProcessDocumentRequestType request_x = new GNE_CM_ARX_eSignWebservice.ProcessDocumentRequestType();
            GNE_CM_ARX_eSignWebservice.ProcessDocumentResponseType response_x;
            request_x.UserId = UserId;
            request_x.SessionId = SessionId;
            request_x.ObjectId = ObjectId;
            request_x.TransactionId = TransactionId;
            Map<String, GNE_CM_ARX_eSignWebservice.ProcessDocumentResponseType> response_map_x = new Map<String, GNE_CM_ARX_eSignWebservice.ProcessDocumentResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:AssistRx_SMN_Soap#ProcessDocument',
              'urn:AssistRx_SMN_Soap',
              'ProcessDocument',
              'urn:AssistRx_SMN_Soap',
              'ProcessDocumentResponse',
              'GNE_CM_ARX_eSignWebservice.ProcessDocumentResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
    public class ProcessDocumentRequestType {
        public String UserId;
        public String SessionId;
        public String ObjectId;
        public String TransactionId;
        private String[] UserId_type_info = new String[]{'UserId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] SessionId_type_info = new String[]{'SessionId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] ObjectId_type_info = new String[]{'ObjectId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] TransactionId_type_info = new String[]{'TransactionId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:AssistRx_SMN_Soap','true','false'};
        private String[] field_order_type_info = new String[]{'UserId','SessionId','ObjectId','TransactionId'};
    }
    public class ProcessDocumentResponseType {
        public String Status;
        public String StatusDescription;
        public String DocumentId;
        private String[] Status_type_info = new String[]{'Status','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] StatusDescription_type_info = new String[]{'StatusDescription','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] DocumentId_type_info = new String[]{'DocumentId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:AssistRx_SMN_Soap','false','false'};
        private String[] field_order_type_info = new String[]{'Status','StatusDescription','DocumentId'};
    }
}