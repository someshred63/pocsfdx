global without sharing class GNE_SFA2_USPS_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	private Enum apiType {Verify, CityStateLookup, ZipCodeLookup}
	private String uspsUserId = '079GENEN5934';
	private String uspsApiUrl = 'https://production.shippingapis.com/ShippingAPITest.dll';
	private static final Set<String> USPS_XML_LABELS = new Set<String>{'Address1','Address2','City','State','Zip5','Zip4','Number','Source','Description','HelpFile','HelpContext'};
	private Map<Id, Address_vod__c> addressesMap;
	private Map<String, Map<String, String>> addressesWrappersMap;
	private Datetime startTime;
	public Integer batchScopeSize;

	global Database.QueryLocator start(Database.BatchableContext BC) {
		setTriggerDisabled('GNE_SFA2_Address_Trigger', true);
		DateTime lastProcessExecutionTime = getLastProcessExecutionTime(bc);
		return Database.getQueryLocator('SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, USPS_Status_gne__c, USPS_Comment_gne__c FROM Address_vod__c WHERE  Inactive_vod__c = false AND RecordType.DeveloperName IN (\'CompanyMaintained\',\'RepMaintained\')' + (batchScopeSize != null ? (' AND (USPS_Status_gne__c = null OR USPS_Status_gne__c = \'Unverified\') LIMIT ' + batchScopeSize) : ' AND LastModifiedDate >= :lastProcessExecutionTime'));
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		addressesMap = new Map<Id, Address_vod__c>();
		addressesMap.putAll((List<Address_vod__c>)scope);
		System.debug(addressesMap);
		addressesWrappersMap = new Map<String, Map<String, String>>();
		for(Address_vod__c addr : addressesMap.values()) {
			addressesWrappersMap.put(addr.Id, new Map<String, String>{
				'address1' => addr.Address_line_2_vod__c,
		        'address2' => addr.Name,
		        'city' => addr.City_vod__c,
		        'state' => addr.State_vod__c,
		        'zip5' => addr.Zip_vod__c,
		        'zip4' => addr.Zip_4_vod__c
			});

		    if(addressesWrappersMap.size() == 5) {
		        Map<String, Map<String, String>> addressesValidatedMap = addressesValidate(addressesWrappersMap);
		        prepareAddressesToUpdate(addressesValidatedMap);
		        addressesWrappersMap = new Map<String, Map<String, String>>();
		    }
		}

		if(!addressesWrappersMap.isEmpty()) {
		    Map<String, Map<String, String>> addressesValidatedMap = addressesValidate(addressesWrappersMap);
		    prepareAddressesToUpdate(addressesValidatedMap);
		    addressesWrappersMap = new Map<String, Map<String, String>>();
		}

		update addressesMap.values();
	}
	
	global void finish(Database.BatchableContext BC) {
        setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
	}

	public System.Type getSelfClass() {
        return GNE_SFA2_USPS_Batch.class;
    }

	private DateTime getLastProcessExecutionTime(Database.BatchableContext bc) {
        DateTime result = null;
        Id currentJobId = bc != null ? bc.getJobId() : null;
        
        for(AsyncApexJob job : [SELECT CompletedDate 
                                FROM AsyncApexJob
                                WHERE ApexClass.Name = :getSelfClass().getName()
                                    AND Id != :currentJobId
                                    AND ParentJobId = null
                                    AND JobType = 'BatchApex'
                                    AND Status = 'Completed'
                                    AND NumberOfErrors = 0
                                ORDER BY CreatedDate desc
                                LIMIT 1]) {
            result = job.CompletedDate; 
        }

        return result != null ? result : DateTime.now().addDays(-1);        
    }

	private void prepareAddressesToUpdate(Map<String, Map<String, String>> addressesValidatedMap) {
	    for(String addrId : addressesValidatedMap.keySet()) {
	        Address_vod__c currentAddress = addressesMap.get(addrId);
	        Map<String, String> validationResult = addressesValidatedMap.get(addrId);
	        Map<String, Map<String, String>> validationComment = new Map<String, Map<String, String>>();
	        
	        if(String.isNotBlank(validationResult.get('Description'))) {
	            currentAddress.USPS_Status_gne__c  = 'Invalid';
	            validationComment.put('error', new Map<String, String>{
	                'description' => validationResult.get('Description')
	            });
	        } else {
	            currentAddress.USPS_Status_gne__c  = 'Valid';

	            // Street Address Differences
	            if(currentAddress.Name != validationResult.get('Address2')) {
	                validationComment.put('addressDifferences', new Map<String, String>{
	                    'sfdcAddress' => currentAddress.Name,
	                    'uspsAddress' => validationResult.get('Address2')
	                });
	            }

	            // City Differences
	            if(currentAddress.City_vod__c != validationResult.get('City')) {
	                validationComment.put('cityDifferences', new Map<String, String>{
	                    'sfdcCity' => currentAddress.City_vod__c,
	                    'uspsCity' => validationResult.get('City')
	                });
	            }

	            // State Differences
	            if(currentAddress.State_vod__c != validationResult.get('State')) {
	                validationComment.put('stateDifferences', new Map<String, String>{
	                    'sfdcState' => currentAddress.State_vod__c,
	                    'uspsState' => validationResult.get('State')
	                });
	            }

	            // Zip 5 Code Differences
	            if(currentAddress.Zip_vod__c != validationResult.get('Zip5')) {
	                validationComment.put('zip5CodeDifferences', new Map<String, String>{
	                    'sfdcZip5Code' => currentAddress.Zip_vod__c,
	                    'uspsZip5Code' => validationResult.get('Zip5')
	                });
	            }

	            // Zip 4 Code Differences
	            if(currentAddress.Zip_4_vod__c != validationResult.get('Zip4')) {
	                validationComment.put('zip4CodeDifferences', new Map<String, String>{
	                    'sfdcZip4Code' => currentAddress.Zip_4_vod__c,
	                    'uspsZip4Code' => validationResult.get('Zip4')
	                });
	            }

	            if(!validationComment.isEmpty()) {
	            	currentAddress.USPS_Status_gne__c = 'Partially valid';
	            }
	        }
	        

	        if(!validationComment.isEmpty()) {
	            currentAddress.USPS_Comment_gne__c = JSON.serialize(validationComment);
	        }

	        addressesMap.put(addrId, currentAddress);
	    }
	}

	private Map<String, Map<String, String>> callUspsApi(String apiName, String request) {
		HttpRequest req = new HttpRequest();
	    String endPoint = uspsApiUrl + '?API=' + apiName + '&XML=' + EncodingUtil.urlEncode(request, 'UTF-8');
	    req.setEndpoint(endPoint);
	    req.setMethod('GET');
	    req.setTimeout(120000);
	    
	    HTTPResponse res = (new Http()).send(req);
	    return getValuesForListOfXMLElements('AddressValidateResponse', USPS_XML_LABELS, res);
	}

	public Map<String, Map<String, String>> addressesValidate(Map<String, Map<String, String>> params) {
	    String request = GNE_SFA2_USPSUtil.buildAddressesValidateRequest(uspsUserId, params);
	    return callUspsApi(String.valueOf(apiType.Verify), request);
	}

	public List<dom.XMLNode> getRootList(String label, HttpResponse res){
	    List<dom.XMLNode> result = null;
	    if (res.getStatus() == 'OK') {
	        dom.Document doc = res.getBodyDocument();
	        if (doc != null) {
	            dom.XMLNode root = doc.getRootElement();
	            dom.XMLNode listRoot = findRootListInXML(label, root);
	            if(listRoot != null){
	                result = listRoot.getChildElements();
	            }
	        }
	    }

	    return result;
	}

	public dom.XMLNode findRootListInXML(String label, dom.XMLNode xmlNode){
	    if (xmlNode != null) {
	        if(xmlNode.getName() == label){
	            return xmlNode;
	        }
	        if (xmlNode.getChildElements().isEmpty()) {
	            if (xmlNode.getName() == label) {
	                return xmlNode;
	            } else {
	                return null;
	            }
	        } else {
	            for (dom.XMLNode child : xmlNode.getChildElements()) {
	                if (child.getName() == label) {
	                    return child;
	                } else {
	                    for (dom.XMLNode grandChild : child.getChildElements()) {
	                        if (findRootListInXML(label, grandchild) != null) {
	                            return findRootListInXML(label, grandchild);
	                        }
	                    }
	                }
	            }
	        }
	    }

	    return null;
	}

	public Map<String, Map<String, String>> getValuesForListOfXMLElements(String rootLabel, Set<String> labels, HttpResponse res){
	        List<dom.XMLNode> root = getRootList(rootLabel, res);
	        String responseStatus = res.getStatus();
	        Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
	        if(!labels.isEmpty()){
	            if(root != null){
	                for(dom.XMLNode r : root){
	                    Map<String, String> item = new Map<String, String>();
	                    for(String label :labels){
	                        item.put(label, findValueInXML(label, r));
	                    }
	                    item.put('responseStatus', responseStatus);
	                    result.put(r.getAttribute('ID', null) ,item);
	                }
	            }
	        }
	        return result;
	    }
	    
	private String findValueInXML(String label, dom.XMLNode xmlNode) {
	    if (xmlNode != null) {
	        if (xmlNode.getChildElements().isEmpty()) {
	            if (xmlNode.getName() == label) {
	                return xmlNode.getText();
	            } else {
	                return null;
	            }
	        } else {
	            for (dom.XMLNode child : xmlNode.getChildElements()) {
	                if (child.getName() == label) {
	                    return child.getText();
	                } else {
	                    for (dom.XMLNode grandChild : child.getChildElements()) {
	                        if (findValueInXML(label, grandchild) != null) {
	                            return findValueInXML(label, grandchild);
	                        }
	                    }
	                }
	            }
	        }
	    }

	    return null;
	}

	private static void setTriggerDisabled(String triggerName, Boolean isDisabled) {
	    try {
	        GNE_SFA2_Trigger_Execution_Exception_gne__c triggerSettings = GNE_SFA2_Trigger_Execution_Exception_gne__c.getInstance(UserInfo.getUserId());
	        if(triggerSettings == null || triggerSettings.Id == null) {
	            triggerSettings = new GNE_SFA2_Trigger_Execution_Exception_gne__c(SetupOwnerId = Userinfo.getUserId());
	            insert triggerSettings;
	        }
	        triggerSettings.put(triggerName + '__c', isDisabled);
	        update triggerSettings;
	    } catch (Exception ex) {
	        System.debug('Error while setting trigger ' + triggerName + ' to be skipped: ' + ex.getMessage());
	    }
	}
	
}