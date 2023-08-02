public with sharing class GNE_SFA2_HPSMUtil {

	public static String getDoCreateIncidentSoap(Map<String, String> params) {
		String result = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="' + params.get('tibcoUrl') + '">';
		result += '<soap:Header/>';
		result += '<soap:Body>';
		result += '<v1:createIncidentRequest>';
		result += '<v1:createIncidentRequest>';
		result += '<v1:registrationId>' + params.get('regId') + '</v1:registrationId>';
		result += '<v1:contactId>' + params.get('unixId') + '</v1:contactId>';
		result += '<v1:affectedUserId>' + params.get('unixId') + '</v1:affectedUserId>';
		result += '<v1:serviceId>' + params.get('serviceId') +'</v1:serviceId>';
		result += '<v1:priority>4</v1:priority>';
		result += '<v1:title>' + replaceSpecialCharacters(params.get('title')) + '</v1:title>';
		result += '<v1:description>' + replaceSpecialCharacters(params.get('description')) + '</v1:description>';
		result += '<v1:submittedBy>' + params.get('unixId') + '</v1:submittedBy>';
		result += '<v1:assignmentGroup>' + params.get('assignmentGroup') + '</v1:assignmentGroup>';
		result += '<v1:externalReferenceId>12345</v1:externalReferenceId>';
		result += '<v1:category>incident</v1:category>';
		result += '</v1:createIncidentRequest>';
		result += '</v1:createIncidentRequest>';
		result += '</soap:Body>';
		result += '</soap:Envelope>';
		system.debug(result);
		return result;
	}

	public static String getDoReadIncidentsSoap(Map<String, String> params) {
		String result = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="' + params.get('tibcoUrl') + '">';
		result += '<soap:Header/>';
		result += '<soap:Body>';
		result += '<v1:readIncidentsRequest>';
		result += '<v1:readIncidentsRequest>';
		result += '<v1:registrationId>' + params.get('regId') + '</v1:registrationId>';
		result += '<v1:userId>' + params.get('unixId') + '</v1:userId>';
		result += '</v1:readIncidentsRequest>';
		result += '</v1:readIncidentsRequest>';
		result += '</soap:Body>';
		result += '</soap:Envelope>';

		return result;
	}

	public static String getDoCreateServiceRequestSoap(Map<String, String> params) {
		String result = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="' + params.get('tibcoUrl') + '">';
		result += '<soap:Header/>';
		result += '<soap:Body>';
		result += '<v1:createServiceRequestRequest>';
		result += '<v1:createServiceRequestRequest>';
		result += '<v1:registrationId>' + params.get('regId') + '</v1:registrationId>';
		result += '<v1:requestedBy>' + params.get('unixId') + '</v1:requestedBy>';
		result += '<v1:submittedBy>' + params.get('unixId') + '</v1:submittedBy>';
		result += '<v1:externalReferenceId></v1:externalReferenceId>';
		result += '<v1:cartItemList>';
		result += '<v1:cartItem>';
		result += '<v1:itemName>Genentech Database Request</v1:itemName>';
		result += '<v1:recipientId>' + params.get('unixId') + '</v1:recipientId>';
		result += '<v1:businessReason>' + params.get('businessReason') + '</v1:businessReason>';
		result += '<v1:description>' + params.get('description') + '</v1:description>';
		result += '</v1:cartItem>';
		result += '</v1:cartItemList>';
		result += '</v1:createServiceRequestRequest>';
		result += '</v1:createServiceRequestRequest>';
		result += '</soap:Body>';
		result += '</soap:Envelope>';

		return result;
	}

	public static String getDoReadServiceRequestsSoap(Map<String, String> params) {
		String result = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="' + params.get('tibcoUrl') + '">';
		result += '<soap:Header/>';
		result += '<soap:Body>';
		result += '<v1:readServiceRequestsRequest>';
		result += '<v1:readServiceRequestsRequest>';
		result += '<v1:registrationId>' + params.get('regId') + '</v1:registrationId>';
		result += '<v1:userId>' + params.get('unixId') + '</v1:userId>';
		result += '</v1:readServiceRequestsRequest>';
		result += '</v1:readServiceRequestsRequest>';
		result += '</soap:Body>';
		result += '</soap:Envelope>';

		return result;
	}

	public static Map<String, String> generateRequestParamsFromRecord(GNE_CRM_HPSM_Incident__c incident){
        Map<String, String> params = new Map<String, String>();
        //Map<String, GNE_SFA2_HPSM_Config__c> hpsmConfig = GNE_SFA2_HPSM_Config__c.getAll();
        //params.put('assignmentGroup', String.valueOf(hpsmConfig.get('IncidentDefaultAssignmentGroup').Configuration_Value_gne__c));
        //params.put('regId', String.valueOf(hpsmConfig.get('HPSMRegistrationId').Configuration_Value_gne__c));
        //params.put('tibcoUrl', String.valueOf(hpsmConfig.get('TibcoUrlForIncidents').Configuration_Value_gne__c));
        //params.put('serviceId', String.valueOf(hpsmConfig.get('serviceId').Configuration_Value_gne__c));
        params.put('unixId', incident.Unix_Id_gne__c);
        params.put('title', incident.Summary_gne__c);
        params.put('description', incident.Details_gne__c);
        return params;
    }

    public static String replaceSpecialCharacters(String value){
    	if(value!=null){
    		return value.replace('&','&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('\'', '&apos;').replace('"', '&quot;');
    	}
    	return value;
    }
}