//Generated by wsdl2apex

public class mdm0620MDMProxyService {
    public class MdmProxyPortType {
        public String endpoint_x = 'https://sfdcproxy.gene.com/MdmProxyService/services/MdmProxyPortType';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCert_x;
        public Integer timeout_x = 30000;
        public String clientCertPasswd_x;
        private String[] ns_map_type_info = new String[]{'http://sfdc.gene.com/mdm/MdmProxyService.wsdl', 'mdm0620MDMProxyService', 'http://sfdc.gene.com/mdm/UpdateSfdcAccountByMdmIdResponse.xsd', 'mdm0620UpdateSFDCAcctByMdmIdRS', 'http://sfdc.gene.com/mdm/SearchIndividualAccountResponse.xsd', 'mdm0620SearchIndividualAcctRS', 'http://sfdc.gene.com/mdm/MdmProxyFaults.xsd', 'mdm0620MdmProxyFaults', 'http://sfdc.gene.com/mdm/SearchOrganizationAccountRequest.xsd', 'mdm0620SearchOrgAcctRQ', 'http://sfdc.gene.com/mdm/SearchOrganizationAccountResponse.xsd', 'mdm0620SearchOrgAcctRS', 'http://sfdc.gene.com/mdm/common/PingResponse.xsd', 'mdm0620PingRS', 'http://sfdc.gene.com/mdm/common/PingRequest.xsd', 'mdm0620PingRQ', 'http://sfdc.gene.com/mdm/SearchIndividualAccountRequest.xsd', 'mdm0620SearchIndividualAcctRQ', 'http://sfdc.gene.com/mdm/UpdateSfdcAccountByMdmIdRequest.xsd', 'mdm0620UpdateSFDCAcctByMdmIdRQ'};
        public Boolean updateSfdcAccountByMdmId(String mdmId,String mdmPartyType,String sfdcAccountId) {
            mdm0620UpdateSFDCAcctByMdmIdRQ.UpdateSfdcAccountByMdmIdRequestType request_x = new mdm0620UpdateSFDCAcctByMdmIdRQ.UpdateSfdcAccountByMdmIdRequestType();
            mdm0620UpdateSFDCAcctByMdmIdRS.UpdateSfdcAccountByMdmIdResponseType response_x;
            request_x.mdmId = mdmId;
            request_x.mdmPartyType = mdmPartyType;
            request_x.sfdcAccountId = sfdcAccountId;
            Map<String, mdm0620UpdateSFDCAcctByMdmIdRS.UpdateSfdcAccountByMdmIdResponseType> response_map_x = new Map<String, mdm0620UpdateSFDCAcctByMdmIdRS.UpdateSfdcAccountByMdmIdResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'updateSfdcAccountByMdmId',
              'http://sfdc.gene.com/mdm/UpdateSfdcAccountByMdmIdRequest.xsd',
              'updateSfdcAccountByMdmId',
              'http://sfdc.gene.com/mdm/UpdateSfdcAccountByMdmIdResponse.xsd',
              'updateSfdcAccountByMdmIdResponse',
              'mdm0620UpdateSFDCAcctByMdmIdRS.UpdateSfdcAccountByMdmIdResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.acknowledgement;
        }
        public mdm0620SearchOrgAcctRS.OrganizationAccountItemType[] searchOrganizationAccount(String organizationFullName,String address1,String city,String state,String postalCode,Integer recordsToReturn) {
            mdm0620SearchOrgAcctRQ.SearchOrganizationAccountRequestType request_x = new mdm0620SearchOrgAcctRQ.SearchOrganizationAccountRequestType();
            mdm0620SearchOrgAcctRS.searchOrganizationAccountResponse_element response_x;
            request_x.organizationFullName = organizationFullName;
            request_x.address1 = address1;
            request_x.city = city;
            request_x.state = state;
            request_x.postalCode = postalCode;
            request_x.recordsToReturn = recordsToReturn;
            Map<String, mdm0620SearchOrgAcctRS.searchOrganizationAccountResponse_element> response_map_x = new Map<String, mdm0620SearchOrgAcctRS.searchOrganizationAccountResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'searchOrganizationAccount',
              'http://sfdc.gene.com/mdm/SearchOrganizationAccountRequest.xsd',
              'searchOrganizationAccount',
              'http://sfdc.gene.com/mdm/SearchOrganizationAccountResponse.xsd',
              'searchOrganizationAccountResponse',
              'mdm0620SearchOrgAcctRS.searchOrganizationAccountResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.item;
        }
        public DateTime ping(String request) {
            mdm0620PingRQ.PingRequestType request_x = new mdm0620PingRQ.PingRequestType();
            mdm0620PingRS.PingResponseType response_x;
            request_x.request = request;
            Map<String, mdm0620PingRS.PingResponseType> response_map_x = new Map<String, mdm0620PingRS.PingResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'ping',
              'http://sfdc.gene.com/mdm/common/PingRequest.xsd',
              'ping',
              'http://sfdc.gene.com/mdm/common/PingResponse.xsd',
              'pingResponse',
              'mdm0620PingRS.PingResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.timestamp;
        }
        public mdm0620SearchIndividualAcctRS.IndividualAccountItemType[] searchIndividualAccount(String firstName,String familyName,String address1,String state,String city,String postalCode,Integer recordsToReturn) {
            mdm0620SearchIndividualAcctRQ.SearchIndividualAccountRequestType request_x = new mdm0620SearchIndividualAcctRQ.SearchIndividualAccountRequestType();
            mdm0620SearchIndividualAcctRS.searchIndividualAccountResponse_element response_x;
            request_x.firstName = firstName;
            request_x.familyName = familyName;
            request_x.address1 = address1;
            request_x.state = state;
            request_x.city = city;
            request_x.postalCode = postalCode;
            request_x.recordsToReturn = recordsToReturn;
            Map<String, mdm0620SearchIndividualAcctRS.searchIndividualAccountResponse_element> response_map_x = new Map<String, mdm0620SearchIndividualAcctRS.searchIndividualAccountResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'searchIndividualAccount',
              'http://sfdc.gene.com/mdm/SearchIndividualAccountRequest.xsd',
              'searchIndividualAccount',
              'http://sfdc.gene.com/mdm/SearchIndividualAccountResponse.xsd',
              'searchIndividualAccountResponse',
              'mdm0620SearchIndividualAcctRS.searchIndividualAccountResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.item;
        }
    }
}