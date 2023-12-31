//Generated by wsdl2apex

public class mdm0620SearchOrgAcctRQ {
    public class SearchOrganizationAccountRequestType {
        public String organizationFullName;
        public String address1;
        public String city;
        public String state;
        public String postalCode;
        public Integer recordsToReturn;
        private String[] organizationFullName_type_info = new String[]{'organizationFullName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] address1_type_info = new String[]{'address1','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] city_type_info = new String[]{'city','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] state_type_info = new String[]{'state','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] postalCode_type_info = new String[]{'postalCode','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] recordsToReturn_type_info = new String[]{'recordsToReturn','http://www.w3.org/2001/XMLSchema','int','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://sfdc.gene.com/mdm/SearchOrganizationAccountRequest.xsd','true'};
        private String[] field_order_type_info = new String[]{'organizationFullName','address1','city','state','postalCode','recordsToReturn'};
    }
}