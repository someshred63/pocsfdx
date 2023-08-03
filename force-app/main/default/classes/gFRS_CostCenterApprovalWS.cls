//Generated by wsdl2apex

public class gFRS_CostCenterApprovalWS {
    public class costCenterApprvers_element {
        public String costCenter;
        public String unixId;
        public String firstName;
        public String lastName;
        public String amount;
        public String expenseType;
        public String level;

        private String[] costCenter_type_info  = new String[]{'costCenter','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] unixId_type_info      = new String[]{'unixId','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] firstName_type_info   = new String[]{'firstName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] lastName_type_info    = new String[]{'lastName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] amount_type_info      = new String[]{'amount','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] expenseType_type_info = new String[]{'expenseType','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] level_type_info       = new String[]{'level','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] apex_schema_type_info = new String[]{System.Label.gFRS_WS_ESB_SAP_TYPES,'false','false'};
        private String[] field_order_type_info = new String[]{'costCenter','unixId','firstName','lastName','amount','expenseType','level'};
    }
    public class costCenterApproverRequest_element {
        public String amount;
        public String expenseType;
        public String maxCostCenter;
        public String minCostCenter;

        private String[] amount_type_info        = new String[]{'amount','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] expenseType_type_info   = new String[]{'expenseType','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] maxCostCenter_type_info = new String[]{'maxCostCenter','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] minCostCenter_type_info = new String[]{'minCostCenter','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info   = new String[]{System.Label.gFRS_WS_ESB_SAP_TYPES,'false','false'};
        private String[] field_order_type_info   = new String[]{'amount','expenseType','maxCostCenter','minCostCenter'};
    }
    public class GneCOMM_CostCenter_GFRS_O_1_SAP_I_1_ServicesPort0 {
        public String endpoint_x = gFRS_Util.getCustomSettingStringValue('WS_CostCenterApprover_Endpoint');
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;

        private String[] ns_map_type_info = new String[]{System.Label.gFRS_WS_ESB_SAP_TYPES, 'gFRS_CostCenterApprovalWS', 'http://localhost/GneCOMM_CostCenter/GFRS_O_1_SAP_I_1/Services/costCenterApprover', 'gFRS_CostCenterApproverESB'};
        public gFRS_CostCenterApprovalWS.costCenterApproverResponse_element costCenterApprover(String amount,String expenseType,String maxCostCenter,String minCostCenter) {
            gFRS_CostCenterApprovalWS.costCenterApproverRequest_element request_x = new gFRS_CostCenterApprovalWS.costCenterApproverRequest_element();
            gFRS_CostCenterApprovalWS.costCenterApproverResponse_element response_x;
            request_x.amount        = amount;
            request_x.expenseType   = expenseType;
            request_x.maxCostCenter = maxCostCenter;
            request_x.minCostCenter = minCostCenter;
            Map<String, gFRS_CostCenterApprovalWS.costCenterApproverResponse_element> response_map_x = new Map<String, gFRS_CostCenterApprovalWS.costCenterApproverResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(this, request_x, response_map_x, new String[]{
                String.isBlank(endpoint_x) ? System.Label.gFRS_WS_ESB_CostCenterApprover_ENDPOINT : endpoint_x,
                '',
                System.Label.gFRS_WS_ESB_SAP_TYPES,
                'costCenterApproverRequest',
                System.Label.gFRS_WS_ESB_SAP_TYPES,
                'costCenterApproverResponse',
                'gFRS_CostCenterApprovalWS.costCenterApproverResponse_element'
            });
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
    public class costCenterApproverResponse_element {
        public gFRS_CostCenterApprovalWS.costCenterApprvers_element[] costCenterApprvers;
        public String MessageType;
        public String MessageText;
        
        private String[] costCenterApprvers_type_info = new String[]{'costCenterApprvers',System.Label.gFRS_WS_ESB_SAP_TYPES,'costCenterApprvers_element','1','-1','true'};
        private String[] MessageType_type_info        = new String[]{'MessageType','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] MessageText_type_info        = new String[]{'MessageText','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info        = new String[]{System.Label.gFRS_WS_ESB_SAP_TYPES,'false','false'};
        private String[] field_order_type_info        = new String[]{'costCenterApprvers','MessageType','MessageText'};
    }
}