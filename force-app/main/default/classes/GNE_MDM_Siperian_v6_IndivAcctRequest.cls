//Generated by wsdl2apex

public class GNE_MDM_Siperian_v6_IndivAcctRequest {
    public class SearchIndividualAccountRequestType {
        public String firstName;
        public String familyName;
        public String alternateFirstName;
        public String alternateFamilyName;
        public String address1;
        public String state;
        public String city;
        public String postalCode;
        public String licenseNumber;
        public String licenseState;
        public Integer recordsToReturn;
        public String sortCriteria;
        public String ruleSetName;
        private String[] firstName_type_info = new String[]{'firstName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] familyName_type_info = new String[]{'familyName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] alternateFirstName_type_info = new String[]{'alternateFirstName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] alternateFamilyName_type_info = new String[]{'alternateFamilyName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] address1_type_info = new String[]{'address1','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] state_type_info = new String[]{'state','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] city_type_info = new String[]{'city','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] postalCode_type_info = new String[]{'postalCode','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] licenseNumber_type_info = new String[]{'licenseNumber','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] licenseState_type_info = new String[]{'licenseState','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] recordsToReturn_type_info = new String[]{'recordsToReturn','http://www.w3.org/2001/XMLSchema','int','1','1','true'};
        private String[] sortCriteria_type_info = new String[]{'sortCriteria','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] ruleSetName_type_info = new String[]{'ruleSetName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://sfdc.gene.com/mdm/SearchIndividualAccountRequest.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'firstName','familyName','alternateFirstName','alternateFamilyName','address1','state','city','postalCode','licenseNumber','licenseState','recordsToReturn','sortCriteria','ruleSetName'};
    }
}