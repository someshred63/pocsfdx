public with sharing class GNE_SFA2_CAN_SPAM_Get_Opt_Out {

	private static final String AUTHORIZATION_TOKEN = GNE_SFA2_CAN_SPAM_Config__c.getInstance('AuthorizationToken').Configuration_Value_gne__c;
	private static final String ENDPOINT_FOR_EMAIL = GNE_SFA2_CAN_SPAM_Config__c.getInstance('EndpointForEmail').Configuration_Value_gne__c;
	private static final String ENDPOINT_FOR_LIST = GNE_SFA2_CAN_SPAM_Config__c.getInstance('EndpointForList').Configuration_Value_gne__c;
	public GNE_SFA2_CAN_SPAM_Get_Opt_Out() {
	}

	public static List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> getAllUserOpts(Integer pageSize){
		return getAllUserOpts(pageSize, null);
	}

	public static List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> getAllUserOpts(Integer pageSize, String since){
		List<Map<String, String>> optOuts = new List<Map<String, String>>();
		Integer pageNumber = 1;
		HTTPResponse res = getUserOpts(pageNumber, pageSize, since);
		if(res.getStatusCode() == 200){
			optOuts.addAll((List<Map<String, String>>)JSON.deserialize(res.getBody(), List<Map<String, String>>.class));
			Integer pageCount = Integer.valueOf(res.getHeader('pageCount'));
			for(pageNumber = 2; pageNumber <= pageCount; pageNumber++){
				HTTPResponse resp = getUserOpts(pageNumber, pageSize, since);
				if(resp.getStatusCode() == 200){
					optOuts.addAll((List<Map<String, String>>)JSON.deserialize(resp.getBody(), List<Map<String, String>>.class));
				} else {
					system.debug(res.getStatusCode());
					system.debug(res.getBody());
					return null;
				}
			}
		} else {
			system.debug(res.getStatusCode());
			system.debug(res.getBody());
			return null;
		}
		List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> recordsToReturn = new List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData>();
		for(Map<String, String> optOut :optOuts){
			String email = optOut.get('email');
			String type = optOut.get('type');
			String dateTimeString = optOut.get('datetime');
			DateTime optOutDateTime = String.isBlank(dateTimeString) ? null : DateTime.valueofGmt(dateTimeString.replace('T', ' ').replace('Z', ' '));
			recordsToReturn.add(new GNE_SFA2_CAN_SPAM_opt_out.OptOutData(email, type, optOutDateTime));
		}
		return recordsToReturn;
	}

	public static HTTPResponse getUserOpts(Integer page, Integer pageSize, String since){
		HttpRequest req = prepareRequest(page, pageSize, since);
		Http http = new Http();
		HTTPResponse res = http.send(req);
		system.debug(res);
		return res;
	}

	public static String getOptOutForEmail(String email){
		List<Map<String, String>> optOuts = new List<Map<String, String>>();
		HttpRequest req = prepareRequest(email);
		Http http = new Http();
		HTTPResponse res = http.send(req);
		if(res.getStatusCode() == 200){
			optOuts.addAll((List<Map<String, String>>)JSON.deserialize(res.getBody(), List<Map<String, String>>.class));
		}
		if(optOuts.size()>0){
			return optOuts[0].get('datetime');
		}
		return null;
	}

	private static HttpRequest prepareRequest(String email){
		HttpRequest req = new HttpRequest(); 
		req.setMethod('GET');
		req.setHeader('content-type', 'application/json');
		req.setHeader('Authorization', AUTHORIZATION_TOKEN);
		req.setEndpoint(ENDPOINT_FOR_EMAIL + email);
		req.setTimeout(120000);
		system.debug(req);
		return req;
	}

	private static HttpRequest prepareRequest(Integer page, Integer pageSize, String since){
		String requestParams = '';
		if(page != null){
			requestParams = '?page=' + page;
		}
		if(pageSize != null){
			requestParams += (String.isBlank(requestParams) ? '?' : '&') + 'pageSize=' + pageSize;
		}
		if(since != null){
			requestParams += (String.isBlank(requestParams) ? '?' : '&') + 'since=' + since.replace(':', '%3A');
		}
		HttpRequest req = new HttpRequest(); 
		req.setMethod('GET');
		req.setHeader('content-type', 'application/json');
		req.setHeader('Authorization', AUTHORIZATION_TOKEN);
		req.setEndpoint(ENDPOINT_FOR_LIST + requestParams);
		req.setTimeout(120000);
		system.debug(req);
		return req;
	}

}