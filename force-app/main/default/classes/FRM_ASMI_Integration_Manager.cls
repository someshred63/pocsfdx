public with sharing class FRM_ASMI_Integration_Manager {
	private Call2_vod__c interaction;
	private Map<String, SFA2_FRM_ASMI_Mapping__c> topicMappersByName;
	private Map<String, SFA2_FRM_ASMI_Mapping__c> productMappersByNormalizedProductName;
	private List<Call2_Discussion_vod__c> discussionsToCreateMI;
    private Map<Id, String> productStrategyNamesById;
    private Map<Id, String> productNamesById;

    private enum mappingType { TOPIC, PRODUCT }

	public FRM_ASMI_Integration_Manager(Call2_vod__c interaction, List<GNE_SFA2_Interaction_Controller.DiscussionWrapper> wrappedDicussions) {
		this(interaction, unwrapDiscussions(wrappedDicussions));
	}

	public FRM_ASMI_Integration_Manager(Call2_vod__c interaction, List<Call2_Discussion_vod__c> discussions) {
		this.interaction = interaction;
		this.topicMappersByName = populateTopicMappersByName();
		this.productMappersByNormalizedProductName = populateProductMappersByNormalizedProductName();
        this.productStrategyNamesById = populateProductStrategyNamesById(discussions);
		this.discussionsToCreateMI = populateDiscussionsToCreateMI(discussions);
		this.productNamesById = populateProductNamesById(discussions);
		System.debug('$$ discussionsToCreateMI ' + discussionsToCreateMI);
		System.debug('$$ productNamesById ' + productNamesById);
	}

	public Boolean shouldCreateMarketInsigts() {
		return discussionsToCreateMI.size() > 0 && isFrmUser();
	}

	public void createMarketInsigts() {
		List<Market_Insight_gne__c> newMarketInsights = new List<Market_Insight_gne__c>();
		for (Call2_Discussion_vod__c discussion : discussionsToCreateMI) {
			Market_Insight_gne__c marketInsight = new Market_Insight_gne__c();
			marketInsight.Status_gne__c = 'Draft';
			marketInsight.Account_gne__c = interaction.Account_vod__c;
			marketInsight.Account_City_gne__c = interaction.City_vod__c;
			marketInsight.Account_State_gne__c = interaction.State_vod__c;
			marketInsight.Account_Zip_gne__c = interaction.Zip_vod__c;

			String productName = productNamesById.get(discussion.Product_vod__c);
			if (String.isNotBlank(productName)) {
				String normalizedProductName = productName.normalizeSpace();
				SFA2_FRM_ASMI_Mapping__c prodMapper = productMappersByNormalizedProductName.get(normalizedProductName);
				if (prodMapper != null) {
					marketInsight.Product_gne__c = prodMapper.ASMI_Product_Name_gne__c;
				}
			}
					
			String topicMapperLabel = trimPrefix(productStrategyNamesById.get(discussion.Product_Strategy_vod__c));
			SFA2_FRM_ASMI_Mapping__c mapper = topicMappersByName.get(topicMapperLabel);
			if (mapper != null) {
				marketInsight.Topic_gne__c = mapper.ASMI_Topic_gne__c;
				marketInsight.Category_gne__c = mapper.ASMI_Category_gne__c;
				marketInsight.Sub_Category_gne__c = mapper.ASMI_Subcategory_gne__c;
			}
			
            newMarketInsights.add(marketInsight);
		}
		System.debug('$$ newMarketInsights ' + newMarketInsights);
		insert newMarketInsights;
	}


	private static List<Call2_Discussion_vod__c> unwrapDiscussions(List<GNE_SFA2_Interaction_Controller.DiscussionWrapper> wrappedDicussions) {
		List<Call2_Discussion_vod__c> result = new List<Call2_Discussion_vod__c>();
		for (GNE_SFA2_Interaction_Controller.DiscussionWrapper wrapper : wrappedDicussions) {
			result.add(wrapper.callDiscussion);
		}
		return result;
	}

	private Map<String, SFA2_FRM_ASMI_Mapping__c> populateTopicMappersByName() {
		Map<String, SFA2_FRM_ASMI_Mapping__c> result = new Map<String, SFA2_FRM_ASMI_Mapping__c>();
		for (SFA2_FRM_ASMI_Mapping__c mapper : [SELECT Name, ASMI_Category_gne__c, ASMI_Product_Name_gne__c, ASMI_Subcategory_gne__c, ASMI_Topic_gne__c, 
														FRM_Product_Name_gne__c, Mapping_Type_gne__c
												 FROM SFA2_FRM_ASMI_Mapping__c
												 WHERE Mapping_Type_gne__c = :mappingType.TOPIC.name()]) {
			result.put(mapper.Name, mapper);
		}
		return result;
	}

	private Map<String, SFA2_FRM_ASMI_Mapping__c> populateProductMappersByNormalizedProductName() {
		Map<String, SFA2_FRM_ASMI_Mapping__c> result = new Map<String, SFA2_FRM_ASMI_Mapping__c>();
		for (SFA2_FRM_ASMI_Mapping__c mapper : [SELECT Name, ASMI_Category_gne__c, ASMI_Product_Name_gne__c, ASMI_Subcategory_gne__c, ASMI_Topic_gne__c, 
														FRM_Product_Name_gne__c, Mapping_Type_gne__c
												 FROM SFA2_FRM_ASMI_Mapping__c
												 WHERE Mapping_Type_gne__c = :mappingType.PRODUCT.name()]) {
			result.put(mapper.FRM_Product_Name_gne__c.normalizeSpace(), mapper);
		}
		return result;
	}
    
    private Map<Id, String> populateProductStrategyNamesById(List<Call2_Discussion_vod__c> discussions) {
        Map<Id, String> result = new Map<Id, String>();
        for (Call2_Discussion_vod__c discussion : discussions) {
            result.put(discussion.Product_Strategy_vod__c, null);
        }
        for (Product_Strategy_vod__c ps : [SELECT Id, Name FROM Product_Strategy_vod__c WHERE Id IN :result.keyset()]) {
            result.put(ps.Id, ps.Name);
        }
        return result;
    }

    private Map<Id, String> populateProductNamesById(List<Call2_Discussion_vod__c> discussions) {
        Map<Id, String> result = new Map<Id, String>();
        for (Call2_Discussion_vod__c discussion : discussions) {
            result.put(discussion.Product_vod__c, null);
        }
        for (Product_vod__c product : [SELECT Id, Name FROM Product_vod__c WHERE Id IN :result.keyset()]) {
            result.put(product.Id, product.Name);
        }
        return result;
    }

	private List<Call2_Discussion_vod__c> populateDiscussionsToCreateMI(List<Call2_Discussion_vod__c> discussions) {
		List<Call2_Discussion_vod__c> result = new List<Call2_Discussion_vod__c>();        
		for (Call2_Discussion_vod__c discussion : discussions) {
			if (discussion.FRM_Issue_entered_into_ASMI_gne__c && isPatientAccessIssue(productStrategyNamesById.get(discussion.Product_Strategy_vod__c))) {
				result.add(discussion);
			}
		}
		return result;
	}

	private Boolean isPatientAccessIssue(String stringToCheck) {
		return String.isNotBlank(stringToCheck) && stringToCheck.startsWithIgnoreCase('Patient Access Issue');
	}

	private String trimPrefix(String stringToTrim) {
		//different dashes are present in data, need to trim in both cases
		if (String.isNotBlank(stringToTrim)) {
			stringToTrim = stringToTrim.removeStart('Patient Access Issue - ');
        	stringToTrim = stringToTrim.removeStart('Patient Access Issue – ');
		}        
		return stringToTrim;
	}

	private static Boolean isFrmUser() {
        return Pattern.matches('GNE-MCCO-FRM-\\wFRM-{0,1}\\w*', GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase());
    }
}