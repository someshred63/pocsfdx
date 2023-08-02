@RestResource(urlMapping='/FCR/getPicklists/*')
global  class FCR_Get_Picklists {
    static final String FCR_VERSION = 'GNE_InTheField_Version';
    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest() {
        return iPhone_Commons_gne.buildResponse(
            new GetPicklistsResponseBuilder(),
            null
        );
    }
    
    class GetPicklistsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        final Base64BitsUtil base64BitsUtil = new Base64BitsUtil();
        public iPhone_Commons_gne.RestResponse build(Object arg) {
            GetPicklistsResponse response = new GetPicklistsResponse();
            setupDevelopmentGoalResponse(response);
            setupNetworkPriorityResponse(response);
            setupVisitResponse(response);
            setAppVersion(response);
            return response;
        }
        
        private void setAppVersion(GetPicklistsResponse response) {           
            Map<String, List<Environment_Variables__c>> environmentVariables = GNE_CM_MPS_Utils.populateEnvVariables(new Set<String>{FCR_VERSION}); 
            List<Environment_Variables__c> envVar = environmentVariables.get(FCR_VERSION);   
            response.appVersion  = envVar.isEmpty() ? null : envVar[0].Value__c;         
        }
        
        private void setupVisitResponse(GetPicklistsResponse response) {
			response.visitStatus = getPicklistValues(Visit_gne__c.Status_gne__c);	
            response.visitTypes = getPicklistValues(Visit_gne__c.Type_gne__c);
            response.visitVistTypess = getPicklistValues(Visit_gne__c.Visit_Type__c);
		}
        
        private void setupDevelopmentGoalResponse(GetPicklistsResponse response) {
			response.developmentGoalCategories = getPicklistValues(Development_Goal_gne__c.Category_gne_pl__c);			
		}
        
        private void setupNetworkPriorityResponse(GetPicklistsResponse response) {
			response.networkPriorityCategories = getPicklistValues(Network_Priority_gne__c.Category_gne_pl__c);			
		}
        
        private List<PicklistItem> getPicklistValues(Schema.SObjectField sObjectField) {
			List<PicklistItem> result = new List<PicklistItem>();
			Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();
			List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
			Schema.sObjectField controllingField = fieldDescribe.getController();

			if (controllingField == null && picklistValues != null) {
				for (Schema.PicklistEntry ple : picklistValues) {
					if (ple.isActive()) {
						result.add(new PicklistItem(ple.getValue()));
					}
				}
			} else if (controllingField != null && picklistValues != null) {
				Schema.DescribeFieldResult ctrFieldDescribe = controllingField.getDescribe();

				List<String> ctrValues = new List<String>();
				List<String> ctrAllValues = new List<String>();

				if (ctrFieldDescribe.getType() == Schema.DisplayType.Picklist) {
					List<Schema.PicklistEntry> ctrPicklistValues = ctrFieldDescribe.getPicklistValues();

					for (Schema.PicklistEntry ple : ctrPicklistValues) {
						if (ple.isActive()) {
							ctrValues.add(ple.getValue());
						}
						ctrAllValues.add(ple.getValue());
					}
				} else if (ctrFieldDescribe.getType() == Schema.DisplayType.Boolean) {
					ctrValues.addAll(new List<String> {'False', 'True'});
					ctrAllValues.addAll(ctrValues);
				}

				Map<String, List<String>> ctr2depMap = new Map<String, List<String>>();
				for (String ctrValue : ctrValues) {
					ctr2depMap.put(ctrValue, new List<String>());
				}

				List<PicklistEntryWrapper> pleWrappers = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(picklistValues), List<PicklistEntryWrapper>.class);

				for (PicklistEntryWrapper pleWrapper : pleWrappers) {
					if (pleWrapper.active) {
						List<Integer> ctrIndexes = this.base64BitsUtil.getNonZeroBits(pleWrapper.validFor);
						List<String> ctrMatchingValues = selectControllingValues(ctrIndexes, ctrAllValues);

						for (String ctrValue : ctrMatchingValues) {
							List<String> depValues = ctr2depMap.get(ctrValue);
							depValues.add(pleWrapper.value);
						}
					}
				}

				for (String ctrValue : ctrValues) {
					List<String> depValues = ctr2depMap.get(ctrValue);
					result.add(new DependentPicklistItem(ctrValue, depValues));
				}
			}

			return result;
		}
        
        private List<String> selectControllingValues(List<Integer> ctrIndexes, List<String> ctrAllValues) {
			List<String> result = new List<String>();

			for (Integer index : ctrIndexes) {
				String val = ctrAllValues[index];
				result.add(val);
			}

			return result;
		}
    }
    
    public class GetPicklistsResponse extends iPhone_Commons_gne.RestResponse {
        public List<PicklistItem> developmentGoalCategories;           // Development_Goal_gne__c.Category_gne_pl__c
		public List<PicklistItem> networkPriorityCategories;           // Network_Priority_gne__c.Category_gne_pl__c
		public List<PicklistItem> visitStatus;                         // Visit_gne__c.Status_gne__c
        public List<PicklistItem> visitTypes;                          // Visit_gne__c.Type_gne__c
        public List<PicklistItem> visitVistTypess;                     // Visit_gne__c.Visit_Type__c    
        public String appVersion;
    }
    
    public class GroupPicklistItem extends PicklistItem {
		private String category;

		private GroupPicklistItem(String value, String category) {
			super(value);
			this.category = category;
		}
	}

	private class DependentPicklistItem extends PicklistItem {
		private List<String> children;
		public List<PicklistItem> childrenList;

		private DependentPicklistItem(String value, List<String> children) {
			super(value);
			this.children = children;
			this.childrenList = getChildren();
		}

		private List<PicklistItem> getChildren() {
			List<PicklistItem> result = new List<PicklistItem>();
			if (this.children != null && !this.children.isEmpty()) {
				for (String childValue : this.children) {
					result.add(new PicklistItem(childValue));
				}
			}
			return result;
		}
	}

	private virtual class PicklistItem {
		private String value;

		private PicklistItem(String value) {
			this.value = value;
		}
	}

	private class PicklistEntryWrapper {
		private Boolean active;
		private Boolean defaultValue;
		private String value;
		private String label;
		private String validFor;
	}

	private class Base64BitsUtil {
		Map<String, List<Integer>> b64NonZeroBits = new Map<String, List<Integer>>();

		private Base64BitsUtil() {
			b64NonZeroBits.put('A', new List<Integer> {});
			b64NonZeroBits.put('B', new List<Integer> {5});
			b64NonZeroBits.put('C', new List<Integer> {4});
			b64NonZeroBits.put('D', new List<Integer> {4, 5});
			b64NonZeroBits.put('E', new List<Integer> {3});
			b64NonZeroBits.put('F', new List<Integer> {3, 5});
			b64NonZeroBits.put('G', new List<Integer> {3, 4});
			b64NonZeroBits.put('H', new List<Integer> {3, 4, 5});
			b64NonZeroBits.put('I', new List<Integer> {2});
			b64NonZeroBits.put('J', new List<Integer> {2, 5});
			b64NonZeroBits.put('K', new List<Integer> {2, 4});
			b64NonZeroBits.put('L', new List<Integer> {2, 4, 5});
			b64NonZeroBits.put('M', new List<Integer> {2, 3});
			b64NonZeroBits.put('N', new List<Integer> {2, 3, 5});
			b64NonZeroBits.put('O', new List<Integer> {2, 3, 4});
			b64NonZeroBits.put('P', new List<Integer> {2, 3, 4, 5});
			b64NonZeroBits.put('Q', new List<Integer> {1});
			b64NonZeroBits.put('R', new List<Integer> {1, 5});
			b64NonZeroBits.put('S', new List<Integer> {1, 4});
			b64NonZeroBits.put('T', new List<Integer> {1, 4, 5});
			b64NonZeroBits.put('U', new List<Integer> {1, 3});
			b64NonZeroBits.put('V', new List<Integer> {1, 3, 5});
			b64NonZeroBits.put('W', new List<Integer> {1, 3, 4});
			b64NonZeroBits.put('X', new List<Integer> {1, 3, 4, 5});
			b64NonZeroBits.put('Y', new List<Integer> {1, 2});
			b64NonZeroBits.put('Z', new List<Integer> {1, 2, 5});
			b64NonZeroBits.put('a', new List<Integer> {1, 2, 4});
			b64NonZeroBits.put('b', new List<Integer> {1, 2, 4, 5});
			b64NonZeroBits.put('c', new List<Integer> {1, 2, 3});
			b64NonZeroBits.put('d', new List<Integer> {1, 2, 3, 5});
			b64NonZeroBits.put('e', new List<Integer> {1, 2, 3, 4});
			b64NonZeroBits.put('f', new List<Integer> {1, 2, 3, 4, 5});
			b64NonZeroBits.put('g', new List<Integer> {0});
			b64NonZeroBits.put('h', new List<Integer> {0, 5});
			b64NonZeroBits.put('i', new List<Integer> {0, 4});
			b64NonZeroBits.put('j', new List<Integer> {0, 4, 5});
			b64NonZeroBits.put('k', new List<Integer> {0, 3});
			b64NonZeroBits.put('l', new List<Integer> {0, 3, 5});
			b64NonZeroBits.put('m', new List<Integer> {0, 3, 4});
			b64NonZeroBits.put('n', new List<Integer> {0, 3, 4, 5});
			b64NonZeroBits.put('o', new List<Integer> {0, 2});
			b64NonZeroBits.put('p', new List<Integer> {0, 2, 5});
			b64NonZeroBits.put('q', new List<Integer> {0, 2, 4});
			b64NonZeroBits.put('r', new List<Integer> {0, 2, 4, 5});
			b64NonZeroBits.put('s', new List<Integer> {0, 2, 3});
			b64NonZeroBits.put('t', new List<Integer> {0, 2, 3, 5});
			b64NonZeroBits.put('u', new List<Integer> {0, 2, 3, 4});
			b64NonZeroBits.put('v', new List<Integer> {0, 2, 3, 4, 5});
			b64NonZeroBits.put('w', new List<Integer> {0, 1});
			b64NonZeroBits.put('x', new List<Integer> {0, 1, 5});
			b64NonZeroBits.put('y', new List<Integer> {0, 1, 4});
			b64NonZeroBits.put('z', new List<Integer> {0, 1, 4, 5});
			b64NonZeroBits.put('0', new List<Integer> {0, 1, 3});
			b64NonZeroBits.put('1', new List<Integer> {0, 1, 3, 5});
			b64NonZeroBits.put('2', new List<Integer> {0, 1, 3, 4});
			b64NonZeroBits.put('3', new List<Integer> {0, 1, 3, 4, 5});
			b64NonZeroBits.put('4', new List<Integer> {0, 1, 2});
			b64NonZeroBits.put('5', new List<Integer> {0, 1, 2, 5});
			b64NonZeroBits.put('6', new List<Integer> {0, 1, 2, 4});
			b64NonZeroBits.put('7', new List<Integer> {0, 1, 2, 4, 5});
			b64NonZeroBits.put('8', new List<Integer> {0, 1, 2, 3});
			b64NonZeroBits.put('9', new List<Integer> {0, 1, 2, 3, 5});
			b64NonZeroBits.put('+', new List<Integer> {0, 1, 2, 3, 4});
			b64NonZeroBits.put('/', new List<Integer> {0, 1, 2, 3, 4, 5});
		}

		private List<Integer> getNonZeroBits(String str) {
			List<Integer> result = new List<Integer>();

			if (str == null) {
				return result;
			}

			for (Integer charIndex = 0; charIndex < str.length(); charIndex++) {
				String character = str.substring(charIndex, charIndex + 1);
				List<Integer> bits = b64NonZeroBits.get(character);
				Integer shift = charIndex * 6;

				for (Integer bit : bits) {
					result.add(bit + shift);
				}
			}

			return result;
		}
	}
}