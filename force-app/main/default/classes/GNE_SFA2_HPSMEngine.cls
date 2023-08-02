public with sharing class GNE_SFA2_HPSMEngine {

    private enum actionType {
        DoCreateIncident, DoReadIncidents, DoCreateServiceRequest, DoReadServiceRequests
    }
    //private Map<String, GNE_SFA2_HPSM_Config__c> hpsmConfig = GNE_SFA2_HPSM_Config__c.getAll();

    public List<Map<String, String>> executeHPSMRequest(String soapAction, Map<String, String> params) {
        HttpRequest req = prepareRequest(soapAction, params);
        Http http = new Http();
        //HttpResponse res = http.send(req);
        //System.debug(res);

        List<Map<String, String>> result = new List<Map<String, String>>();
        /*if (soapAction == String.valueOf(actionType.DoCreateIncident)) {
            result.add(GNE_SFA2_XMLParser.getValuesForXMLElements(new Set<String>{
                    'returnMessage', 'returnIncidentId', 'errorCode', 'description', 'adapterTrackingId'
            }, res));
        } else if (soapAction == String.valueOf(actionType.DoReadIncidents)) {
            result = GNE_SFA2_XMLParser.getValuesForListOfXMLElements(new Set<String>{
                    'incidentId', 'status', 'opentime', 'priority', 'title', 'description', 'assignmentgroup', 'service', 'solution', 'solutionCode', 'closeTime', 'resolvedTime'
            }, res);
        } else if (soapAction == String.valueOf(actionType.DoCreateServiceRequest)) {
            result.add(GNE_SFA2_XMLParser.getValuesForXMLElements(new Set<String>{
                    'returnMessage', 'returnServiceRequestId'
            }, res));
        } else if (soapAction == String.valueOf(actionType.DoReadServiceRequests)) {
            result.add(GNE_SFA2_XMLParser.getValuesForXMLElements(new Set<String>{
                    'servicerequestid', 'status', 'opentime', 'priority', 'title', 'description', 'assignmentgroup', 'service'
            }, res));
        }*/

        return result;
    }

    private HttpRequest prepareRequest(String soapAction, Map<String, String> params) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        req.setHeader('SOAPAction', soapAction);

        String soap = null;
        if (soapAction == String.valueOf(actionType.DoCreateIncident)) {
            soap = GNE_SFA2_HPSMUtil.getDoCreateIncidentSoap(params);
        } else if (soapAction == String.valueOf(actionType.DoReadIncidents)) {
            soap = GNE_SFA2_HPSMUtil.getDoReadIncidentsSoap(params);
        } else if (soapAction == String.valueOf(actionType.DoCreateServiceRequest)) {
            soap = GNE_SFA2_HPSMUtil.getDoCreateServiceRequestSoap(params);
        } else if (soapAction == String.valueOf(actionType.DoReadServiceRequests)) {
            soap = GNE_SFA2_HPSMUtil.getDoReadServiceRequestsSoap(params);
        }

        req.setBody(soap);
        //req.setEndpoint(soapAction.contains('Incident') ? String.valueOf(hpsmConfig.get('GWUrlForIncidents').Configuration_Value_gne__c) : String.valueOf(hpsmConfig.get('GWUrlForServiceRequests').Configuration_Value_gne__c));
        //req.setClientCertificateName(String.valueOf(hpsmConfig.get('ClientCertificateName').Configuration_Value_gne__c));
        //req.setHeader('Authorization', String.valueOf(hpsmConfig.get('ClientAuthorization').Configuration_Value_gne__c));
        req.setTimeout(120000);
        System.debug(req);
        System.debug(soap);
        return req;
    }

}