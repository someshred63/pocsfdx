//Generated by wsdl2apex

public class gFRS_updateUserSchema {
    public class LogInfo {
        public String category;
        public String level;

        private String[] category_type_info    = new String[]{'category','http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','LogCategory','1','1','false'};
        private String[] level_type_info       = new String[]{'level','http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','LogCategoryLevel','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
    }
    public class AllowFieldTruncationHeader_element {
        public Boolean allowFieldTruncation;

        private String[] allowFieldTruncation_type_info = new String[]{'allowFieldTruncation','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] apex_schema_type_info          = new String[]{'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','true','false'};
        private String[] field_order_type_info          = new String[]{'allowFieldTruncation'};
    }
    public class DebuggingHeader_element {
        public gFRS_updateUserSchema.LogInfo[] categories;
        public String debugLevel;

        private String[] categories_type_info  = new String[]{'categories','http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','LogInfo','0','-1','false'};
        private String[] debugLevel_type_info  = new String[]{'debugLevel','http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','LogType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','true','false'};
        private String[] field_order_type_info = new String[]{'categories','debugLevel'};
    }
    public class CallOptions_element {
        public String client;

        private String[] client_type_info      = new String[]{'client','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','true','false'};
        private String[] field_order_type_info = new String[]{'client'};
    }
    public class updateUser_element {
        public String userName;
        public String firstName;
        public String lastName;
        public String userRole;
        public String email;
        public String phoneNumber;
        public String pin;

        private String[] userName_type_info    = new String[]{'userName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] firstName_type_info   = new String[]{'firstName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] lastName_type_info    = new String[]{'lastName','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] userRole_type_info    = new String[]{'userRole','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] email_type_info       = new String[]{'email','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] phoneNumber_type_info = new String[]{'phoneNumber','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] pin_type_info         = new String[]{'pin','http://www.w3.org/2001/XMLSchema','string','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','true','false'};
        private String[] field_order_type_info = new String[]{'userName','firstName','lastName','userRole','email','phoneNumber','pin'};
    }
    public class gFRS_UpdateUserWebService {
        public String endpoint_x = 'https://cs1-api.salesforce.com/services/Soap/class/gFRS_UpdateUserWebService';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;

        public gFRS_updateUserSchema.DebuggingHeader_element DebuggingHeader;
        public gFRS_updateUserSchema.SessionHeader_element SessionHeader;
        public gFRS_updateUserSchema.CallOptions_element CallOptions;
        public gFRS_updateUserSchema.DebuggingInfo_element DebuggingInfo;
        public gFRS_updateUserSchema.AllowFieldTruncationHeader_element AllowFieldTruncationHeader;

        private String DebuggingHeader_hns            = 'DebuggingHeader=http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService';
        private String SessionHeader_hns              = 'SessionHeader=http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService';
        private String CallOptions_hns                = 'CallOptions=http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService';
        private String DebuggingInfo_hns              = 'DebuggingInfo=http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService';
        private String AllowFieldTruncationHeader_hns = 'AllowFieldTruncationHeader=http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService';
        private String[] ns_map_type_info             = new String[]{'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService', 'gFRS_updateUserSchema'};

        public String updateUser(String userName,String firstName,String lastName,String userRole,String email,String phoneNumber,String pin) {

            gFRS_updateUserSchema.updateUser_element request_x = new gFRS_updateUserSchema.updateUser_element();
            gFRS_updateUserSchema.updateUserResponse_element response_x;

            request_x.userName    = userName;
            request_x.firstName   = firstName;
            request_x.lastName    = lastName;
            request_x.userRole    = userRole;
            request_x.email       = email;
            request_x.phoneNumber = phoneNumber;
            request_x.pin         = pin;

            Map<String, gFRS_updateUserSchema.updateUserResponse_element> response_map_x = new Map<String, gFRS_updateUserSchema.updateUserResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService',
              'updateUser',
              'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService',
              'updateUserResponse',
              'gFRS_updateUserSchema.updateUserResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
    }
    public class SessionHeader_element {
        public String sessionId;

        private String[] sessionId_type_info   = new String[]{'sessionId','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
    }
    public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info    = new String[]{'debugLog','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','true','false'};
        private String[] field_order_type_info = new String[]{'debugLog'};
    }
    public class updateUserResponse_element {
        public String result;
        
        private String[] result_type_info      = new String[]{'result','http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','ID','1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/schemas/class/gFRS_UpdateUserWebService','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
}