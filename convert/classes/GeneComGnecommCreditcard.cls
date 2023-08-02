public class GeneComGnecommCreditcard {
    public class CreateUpdateCCardReply2 {
        public String status;
        public String message;
        private String[] status_type_info = new String[]{'status','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] message_type_info = new String[]{'message','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://corpesbdev02.gene.com/GneCOMM_CreditCard/CreateUpdateCreditCard/SFDC_O_1/WSD/CreateUpdateCreditCard','false','false'};
        private String[] field_order_type_info = new String[]{'status','message'};
    }
    public class CreateUpdateCCardRequest {
        public GeneComGnecommCreditcard.CreateUpdateCCardRequest2 CreateUpdateCCardRequest;
        public String debug;
        private String[] CreateUpdateCCardRequest_type_info = new String[]{'CreateUpdateCCardRequest','http://corpesbdev02.gene.com/GneCOMM_CreditCard/CreateUpdateCreditCard/SFDC_O_1/WSD/CreateUpdateCreditCard','CreateUpdateCCardRequest2','1','1','true'};
        private String[] debug_type_info = new String[]{'debug','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://corpesbdev02.gene.com/GneCOMM_CreditCard/CreateUpdateCreditCard/SFDC_O_1/WSD/CreateUpdateCreditCard','false','false'};
        private String[] field_order_type_info = new String[]{'CreateUpdateCCardRequest','debug'};
    }
    public class CreateUpdateCCardReply {
        public GeneComGnecommCreditcard.CreateUpdateCCardReply2 CreateUpdateCCardReply;
        private String[] CreateUpdateCCardReply_type_info = new String[]{'CreateUpdateCCardReply','http://corpesbdev02.gene.com/GneCOMM_CreditCard/CreateUpdateCreditCard/SFDC_O_1/WSD/CreateUpdateCreditCard','CreateUpdateCCardReply2','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://corpesbdev02.gene.com/GneCOMM_CreditCard/CreateUpdateCreditCard/SFDC_O_1/WSD/CreateUpdateCreditCard','false','false'};
        private String[] field_order_type_info = new String[]{'CreateUpdateCCardReply'};
    }
    public class GneCOMM_CreditCard_CreateUpdateCreditCard_SFDC_O_1_WSD_CreateUpdateCreditCard_Port {
        //public String endpoint_x = 'http://commesb8-dev.gene.com/ws/GneCOMM_CreditCard.CreateUpdateCreditCard.SFDC_O_1.WSD:CreateUpdateCreditCard';
        String esbURL = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().ESB_URL__c;
        public String endpoint_x = esbURL + '/ws/GneCOMM_CreditCard.CreateUpdateCreditCard.SFDC_O_1.WSD:CreateUpdateCreditCard';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x=60000;
        private String[] ns_map_type_info = new String[]{'http://corpesbdev02.gene.com/GneCOMM_CreditCard/CreateUpdateCreditCard/SFDC_O_1/WSD/CreateUpdateCreditCard', 'GeneComGnecommCreditcard'};
        public GeneComGnecommCreditcard.CreateUpdateCCardReply2 processInbound(GeneComGnecommCreditcard.CreateUpdateCCardRequest2 CreateUpdateCCardRequest,String debug) {
            GeneComGnecommCreditcard.CreateUpdateCCardRequest request_x = new GeneComGnecommCreditcard.CreateUpdateCCardRequest();
            GeneComGnecommCreditcard.CreateUpdateCCardReply response_x;
            request_x.CreateUpdateCCardRequest = CreateUpdateCCardRequest;
            request_x.debug = debug;
            Map<String, GeneComGnecommCreditcard.CreateUpdateCCardReply> response_map_x = new Map<String, GeneComGnecommCreditcard.CreateUpdateCCardReply>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'GneCOMM_CreditCard_CreateUpdateCreditCard_SFDC_O_1_WSD_CreateUpdateCreditCard_Binder_processInbound',
              'http://corpesbdev02.gene.com/GneCOMM_CreditCard/CreateUpdateCreditCard/SFDC_O_1/WSD/CreateUpdateCreditCard',
              'CreateUpdateCCardRequest',
              'http://corpesbdev02.gene.com/GneCOMM_CreditCard/CreateUpdateCreditCard/SFDC_O_1/WSD/CreateUpdateCreditCard',
              'CreateUpdateCCardReply',
              'GeneComGnecommCreditcard.CreateUpdateCCardReply'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.CreateUpdateCCardReply;
        }
    }
    public class CreateUpdateCCardRequest2 {
        public String accountNumber;
        public String creditCardNumber;
        public String creditCardTypeCode;
        public String creditCardExpirationDate;
        public String cardHolderName;
        public String action;
        private String[] accountNumber_type_info = new String[]{'accountNumber','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] creditCardNumber_type_info = new String[]{'creditCardNumber','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] creditCardTypeCode_type_info = new String[]{'creditCardTypeCode','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] creditCardExpirationDate_type_info = new String[]{'creditCardExpirationDate','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] cardHolderName_type_info = new String[]{'cardHolderName','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] action_type_info = new String[]{'action','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://corpesbdev02.gene.com/GneCOMM_CreditCard/CreateUpdateCreditCard/SFDC_O_1/WSD/CreateUpdateCreditCard','false','false'};
        private String[] field_order_type_info = new String[]{'accountNumber','creditCardNumber','creditCardTypeCode','creditCardExpirationDate','cardHolderName','action'};
    }
}