//Generated by wsdl2apex

public class gFRS_EmployeeCostCenterSAP {
    public class employeeCostCenterResponse {
        public gFRS_EmployeeCostCenterWS.employeeCostCenterResponse_element employeeCostCenterResponse;
        private String[] employeeCostCenterResponse_type_info = new String[]{'employeeCostCenterResponse',System.Label.gFRS_WS_ESB_SAP_TYPES,'employeeCostCenterResponse_element','1','1','false'};
        private String[] apex_schema_type_info                = new String[]{'http://localhost/GneCOMM_CostCenter/GFRS_O_1_LDAP_I_1/Services/employeeCostCenter','false','false'};
        private String[] field_order_type_info                = new String[]{'employeeCostCenterResponse'};
    }
    public class employeeCostCenterRequest {
        public gFRS_EmployeeCostCenterWS.employee_element employee;
        
        private String[] employee_type_info    = new String[]{'employee',System.Label.gFRS_WS_ESB_SAP_TYPES,'employee_element','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://localhost/GneCOMM_CostCenter/GFRS_O_1_LDAP_I_1/Services/employeeCostCenter','false','false'};
        private String[] field_order_type_info = new String[]{'employee'};
    }
}