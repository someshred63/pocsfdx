global without sharing class iPhone_Event_Curriculums_Webservice_gne 
{
	WebService String userId; 
	
	WebService List<String> curriculumIds;
	
	global class EventCurriculums
	{
		WebService String evCurrId;
		WebService String evCurrOwnerId;
		WebService String evCurrName;
		WebService String evCurrRecordTypeId;
		WebService String evCurrExternalId;
		WebService Date evCurrApprovalDate;
		WebService Date evCurrDeactivationDate;
		WebService String evCurrDescription;
		WebService Date evCurrStartDate;
		WebService String evCurrVersionNumber;
		WebService String evSpeakerBureauId;
	}
	global class ResponseItem
	{
		WebService String productId;
		WebService List<EventCurriculums> eventCurriculums;
	}
	global class FullResponse
	{
		WebService List<ResponseItem> response;
	}
	
	static List<Product_vod__c> systemProducts()
	{
		List<Product_vod__c> productsList = new List<Product_vod__c>();
		productsList = 
		[
			Select
			Id
			From
			Product_vod__c
		];
		system.debug('>>>>>>>>>>>>>>>>>>>>>>>Products= ['+productsList+']');
		return productsList;
	}
	static Map<Id, List<Id>> speakerBureauPerProductMap(List<Product_vod__c> productsList)
	{
		List<Speaker_Bureau_Product_gne__c> tmpSpeakerBureauList = [Select Product_vod_gne__c, Speaker_Bureau_gne__c from Speaker_Bureau_Product_gne__c where Product_vod_gne__c IN : productsList];
		Map<Id, List<Id>> tmpMap = new Map<Id, List<Id>>();
		for(Speaker_Bureau_Product_gne__c item : tmpSpeakerBureauList)
		{
			if(tmpMap.containsKey(item.Product_vod_gne__c))
			{
				tmpMap.get(item.Product_vod_gne__c).add(item.Speaker_Bureau_gne__c);
			}
			else
			{
				List<Id> newSpeakerBureauIds = new List<Id>();
				newSpeakerBureauIds.add(item.Speaker_Bureau_gne__c);
				tmpMap.put(item.Product_vod_gne__c, newSpeakerBureauIds);
			}
		}
		return tmpMap;
	}
	static Map<Id, List<Curriculum_Speaker_Bureau_gne__c>> eventCurriculumPerProductMap(Map<Id, List<Id>> spkBrPerProdMap)
	{
		List<Id> tmpSBidsList = new List<Id>();
		for(Id prodId : spkBrPerProdMap.keySet())
		{
			for(Id sbId : spkBrPerProdMap.get(prodId))
			{
				tmpSBidsList.add(sbId);
			}
		}
		List<Curriculum_Speaker_Bureau_gne__c> curriculumSBtmpList = 
		[
			Select
			Id,
			Event_Curriculum_gne__r.Id,
			Event_Curriculum_gne__r.OwnerId,
			Event_Curriculum_gne__r.Name,
			Event_Curriculum_gne__r.RecordTypeId,
			Event_Curriculum_gne__r.Curriculum_External_Id_gne__c,
			Event_Curriculum_gne__r.Approval_Date_gne__c,
			Event_Curriculum_gne__r.Deactivation_Date_gne__c,
			Event_Curriculum_gne__r.Description_gne__c,
			Event_Curriculum_gne__r.Start_Date_gne__c,
			Event_Curriculum_gne__r.Version_Number_gne__c,
			Speaker_Bureau_gne__c
			From
			Curriculum_Speaker_Bureau_gne__c
			Where
			Speaker_Bureau_gne__c IN : tmpSBidsList
			/*AND  // [BOS]: REMOVED, because of new OTR approach. Those records will be filtered on the OTR side. 
			Event_Curriculum_gne__r.Deactivation_Date_gne__c >  LAST_QUARTER
			AND
			Event_Curriculum_gne__r.Start_Date_gne__c < NEXT_QUARTER*/
		];
		Map<Id, List<Curriculum_Speaker_Bureau_gne__c>> tmpEventCurriculumPerProductMap = new Map<Id, List<Curriculum_Speaker_Bureau_gne__c>>();
		for(Id prodId : spkBrPerProdMap.keySet())
		{
			for(Id sbId : spkBrPerProdMap.get(prodId))
			{
				for(Curriculum_Speaker_Bureau_gne__c item : curriculumSBtmpList)
				{
					if(sbId == item.Speaker_Bureau_gne__c)
					{
						if(tmpEventCurriculumPerProductMap.containsKey(prodId))
						{
							tmpEventCurriculumPerProductMap.get(prodId).add(item);
						}
						else
						{
							List<Curriculum_Speaker_Bureau_gne__c> tmpEventCurrList = new List<Curriculum_Speaker_Bureau_gne__c>();
							tmpEventCurrList.add(item);
							tmpEventCurriculumPerProductMap.put(prodId, tmpEventCurrList);
						}
					}
				}
			}
		}
		return tmpEventCurriculumPerProductMap;	
	}
	WebService static FullResponse returnEventCurriculums(String userId)
	{
		//ResponseItem respItem = new ResponseItem();
		FullResponse fullResp = new FullResponse();	
		fullResp.response = new List<ResponseItem>();
		List<Product_vod__c> products = new List<Product_vod__c>();
		Map<Id, List<Id>> bureauProductMap = new Map<Id, List<Id>>();
		Map<Id, List<Curriculum_Speaker_Bureau_gne__c>> curriculumPerProduct = new Map<Id, List<Curriculum_Speaker_Bureau_gne__c>>();
		products = systemProducts();
		bureauProductMap = speakerBureauPerProductMap(products);
		curriculumPerProduct = eventCurriculumPerProductMap(bureauProductMap);
		
		for(Id key : curriculumPerProduct.keySet())
		{
			ResponseItem respItem = new ResponseItem();
			
			respItem.eventCurriculums = new List<EventCurriculums>();
			respItem.productId = key;
			for(Curriculum_Speaker_Bureau_gne__c curriculum : curriculumPerProduct.get(key))
			{
				EventCurriculums evCurr = new EventCurriculums();
				evCurr.evCurrApprovalDate = curriculum.Event_Curriculum_gne__r.Approval_Date_gne__c;
				evCurr.evCurrDeactivationDate = curriculum.Event_Curriculum_gne__r.Deactivation_Date_gne__c;
				evCurr.evCurrDescription = curriculum.Event_Curriculum_gne__r.Description_gne__c;
				evCurr.evCurrExternalId = curriculum.Event_Curriculum_gne__r.Curriculum_External_Id_gne__c;
				evCurr.evCurrId = curriculum.Event_Curriculum_gne__r.Id;
				evCurr.evCurrName = curriculum.Event_Curriculum_gne__r.Name;
				evCurr.evCurrOwnerId = curriculum.Event_Curriculum_gne__r.OwnerId;
				evCurr.evCurrRecordTypeId = curriculum.Event_Curriculum_gne__r.RecordTypeId;
				evCurr.evCurrStartDate = curriculum.Event_Curriculum_gne__r.Start_Date_gne__c;
				evCurr.evCurrVersionNumber = curriculum.Event_Curriculum_gne__r.Version_Number_gne__c;
				evCurr.evSpeakerBureauId = curriculum.Speaker_Bureau_gne__c;
				respItem.eventCurriculums.add(evCurr);
			}
			system.debug('>>>>>>>>>>>>>>>>>>>>>>>respItem= '+respItem);
			fullResp.response.add(respItem);
		}
		system.debug('>>>>>>>>>>>>>>>>>>>>>>>fullResp= ['+fullResp+']');
		return fullResp;
		
	}
	/*
		[OTR-1415/1416,SFA-234, Bartosz Osowiecki]: 
		Previous Web Service method doesn't return all Event Curriculums 
		(only those with Speaker Bureaus related at least to one Product), so 
		this WS method is used to retrieve the rest of Curriculums by given Ids.
		This is needed to display related Interactions correctly. 
	*/
	WebService static FullResponse returnEventCurriculumsByIds(List<String> curriculumIds) {
		FullResponse fullResp = new FullResponse();
		ResponseItem respItem = new ResponseItem();	
		fullResp.response = new List<ResponseItem>{respItem};
		respItem.eventCurriculums = new List<EventCurriculums>();
		for (Event_Curriculum_gne__c ec : [SELECT Id, OwnerId, Name, RecordTypeId, Curriculum_External_Id_gne__c,
												  Approval_Date_gne__c, Deactivation_Date_gne__c, Description_gne__c,
												  Start_Date_gne__c, Version_Number_gne__c
										   FROM Event_Curriculum_gne__c
										   WHERE Id IN :curriculumIds]) {
			EventCurriculums evCurr = new EventCurriculums();
			evCurr.evCurrApprovalDate = ec.Approval_Date_gne__c;
			evCurr.evCurrDeactivationDate = ec.Deactivation_Date_gne__c;
			evCurr.evCurrDescription = ec.Description_gne__c;
			evCurr.evCurrExternalId = ec.Curriculum_External_Id_gne__c;
			evCurr.evCurrId = ec.Id;
			evCurr.evCurrName = ec.Name;
			evCurr.evCurrOwnerId = ec.OwnerId;
			evCurr.evCurrRecordTypeId = ec.RecordTypeId;
			evCurr.evCurrStartDate = ec.Start_Date_gne__c;
			evCurr.evCurrVersionNumber = ec.Version_Number_gne__c;
			evCurr.evSpeakerBureauId = null;
			respItem.eventCurriculums.add(evCurr);					   	
		}
		
		return fullResp;
	}
}