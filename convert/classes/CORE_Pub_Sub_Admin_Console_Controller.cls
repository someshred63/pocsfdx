public with sharing class CORE_Pub_Sub_Admin_Console_Controller {
	
	private static final String SECTIONS_NAME = 'Common Config,Reference Data Custom Settings,Publish Tables,Subscribe Process Tables';
	private static final String COMMON_CONFIG_CS_NAME = 'CORE_Found_Misc_Config__c';

	public List<String> sectionsList { get; set; }
	public Map<String, List<SectionWrapper>> sectionsContent { get; set; }
	public List<Core_Subscribe_Job__c> completedAutoSubJobs { get; set; }

	private Map<String, Schema.SObjectType> globalDescribe;
	private Set<String> coreObjectsNameSet;

	public CORE_Pub_Sub_Admin_Console_Controller() {
		completedAutoSubJobs = getCompletedAutoSubJobs();
		sectionsList = SECTIONS_NAME.split(',');
		sectionsContent = new Map<String, List<SectionWrapper>>();

		globalDescribe = Schema.getGlobalDescribe();
		coreObjectsNameSet = new Set<String>();
		
		for(String objectName : globalDescribe.keySet()) {
			if(objectName.toUpperCase().startsWith('CORE') && objectName != COMMON_CONFIG_CS_NAME && !objectName.toUpperCase().endsWith('HISTORY')) {
				coreObjectsNameSet.add(objectName);
			}
		}

		for(String sName : sectionsList) {
			sectionsContent.put(sName, getSectionWrapperList(sName));
		}
	}

	private List<Core_Subscribe_Job__c> getCompletedAutoSubJobs() {
		return [SELECT Id, Name, CreatedDate, LastModifiedDate, Success_Count_gne__c , Errors_Number_gne__c, Validation_Errors_Count_gne__c, Parties_Count_gne__c FROM Core_Subscribe_Job__c WHERE Name LIKE 'SUB_AUTO%' AND Status_gne__c = 'Completed' order by LastModifiedDate DESC LIMIT 10];
	}

	private List<SectionWrapper> getSectionWrapperList(String sectionName) {
		List<SectionWrapper> result = new List<SectionWrapper>();

		if(sectionName == 'Common Config') {
			Schema.DescribeSObjectResult sObjectDescribe = globalDescribe.get(COMMON_CONFIG_CS_NAME).getDescribe();
			result.add(new SectionWrapper(sObjectDescribe.getLabel(), sObjectDescribe.getName(), sObjectDescribe.getKeyPrefix(), sObjectDescribe.isCustomSetting()));
		} else if(sectionName == 'Reference Data Custom Settings') {
			for(String oName : coreObjectsNameSet) {
				Schema.DescribeSObjectResult sObjectDescribe = globalDescribe.get(oName).getDescribe();
				if(sObjectDescribe.isCustomSetting() && oName.toUpperCase().indexOf('_TYP_') !=-1) {
					result.add(new SectionWrapper(sObjectDescribe.getLabel(), sObjectDescribe.getName(), sObjectDescribe.getKeyPrefix(), sObjectDescribe.isCustomSetting()));
				}
			}
		} else if(sectionName == 'Publish Tables') {
			for(String oName : coreObjectsNameSet) {
				Schema.DescribeSObjectResult sObjectDescribe = globalDescribe.get(oName).getDescribe();
				if(!sObjectDescribe.isCustomSetting() && oName.toUpperCase().contains('PUB')) {
					result.add(new SectionWrapper(sObjectDescribe.getLabel(), sObjectDescribe.getName(), sObjectDescribe.getKeyPrefix(), sObjectDescribe.isCustomSetting()));
				}
			}
		} else if(sectionName == 'Subscribe Process Tables') {
			for(String oName : coreObjectsNameSet) {
				Schema.DescribeSObjectResult sObjectDescribe = globalDescribe.get(oName).getDescribe();
				if(!sObjectDescribe.isCustomSetting() && oName.toUpperCase().contains('SUBSCRIBE')) {
					result.add(new SectionWrapper(sObjectDescribe.getLabel(), sObjectDescribe.getName(), sObjectDescribe.getKeyPrefix(), sObjectDescribe.isCustomSetting()));
				}
			}
		}
		return result;
	}
	
	public PageReference runProcess() {
		Map<String, CORE_Found_Misc_Config__c> coreFoundMiscConfig = CORE_Found_Misc_Config__c.getAll();
       	Datetime publishLastSynch = coreFoundMiscConfig.containsKey('PublishLastSynchDateTime') && coreFoundMiscConfig.get('PublishLastSynchDateTime').Configuration_Value_gne__c != null ? Datetime.valueOf(coreFoundMiscConfig.get('PublishLastSynchDateTime').Configuration_Value_gne__c) : null;

        Datetime autoSubLastSynch = coreFoundMiscConfig.containsKey('AutoSubscribeLastSynchDateTime') && coreFoundMiscConfig.get('AutoSubscribeLastSynchDateTime').Configuration_Value_gne__c != null ? Datetime.valueOf(coreFoundMiscConfig.get('AutoSubscribeLastSynchDateTime').Configuration_Value_gne__c) : null;
        
        Integer batchSize = coreFoundMiscConfig.containsKey('AutoSubscribeBatchSize') && coreFoundMiscConfig.get('AutoSubscribeBatchSize').Configuration_Value_gne__c != null ? Integer.valueOf(coreFoundMiscConfig.get('AutoSubscribeBatchSize').Configuration_Value_gne__c) : 25;
        
        system.debug(publishLastSynch);
        system.debug(autoSubLastSynch);
        system.debug(batchSize);
        
        Integer numberOfBatches = CORE_Subscribe_Util.getNumberOfAutoSubBatches();
        Id jobId = CORE_Subscribe_Util.prepareSubscribeJobId('SUB_AUTO');
        CORE_Subscribe_Object__c subscribeObject = [SELECT Id FROM CORE_Subscribe_Object__c LIMIT 1];        
        for(Integer i = 0; i < numberOfBatches; i++) {
            CORE_Subscribe_Batch subscribeBatch = new CORE_Subscribe_Batch();
            subscribeBatch.initBatch(subscribeObject.Id, jobId, i, autoSubLastSynch, publishLastSynch);
            
            Id batchId = Database.executeBatch(subscribeBatch, batchSize);
            CORE_Subscribe_Util.addIdToJSONBatchIds(jobId, batchId);
		}
		return null;
	}

	@RemoteAction
	@ReadOnly
	public static String getAutoSubJobInProgress() {
		List<Core_Subscribe_Job__c> sJob = [SELECT Id, Name, Batch_Ids_json_gne__c, CreatedDate, LastModifiedDate, Success_Count_gne__c , Errors_Number_gne__c, Parties_Count_gne__c FROM Core_Subscribe_Job__c WHERE Name LIKE 'SUB_AUTO%' AND Status_gne__c != 'Completed' order by LastModifiedDate DESC LIMIT 1];

		if(!sJob.isEmpty() && String.isNotBlank(sJob.get(0).Batch_Ids_json_gne__c)) {
			List<String> bIds = (List<String>)JSON.deserialize(sJob.get(0).Batch_Ids_json_gne__c, List<String>.class);

			List<AsyncApexJob> apexJobs = [SELECT Id, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id IN : bIds AND Status NOT IN ('Holding','Queued','Preparing')];
			if(bIds.size() == CORE_Subscribe_Util.getNumberOfAutoSubBatches() && apexJobs.size() != CORE_Subscribe_Util.getNumberOfAutoSubBatches()) {
				return JSON.serializePretty(new AutoSubJobWrapper(sJob.get(0), 0, 0));
			} else {
				Integer totalItems = 0;
				Integer processedItems = 0;
				for(AsyncApexJob job : apexJobs) {
					totalItems += job.TotalJobItems;
					processedItems += job.JobItemsProcessed;
				}
				return JSON.serializePretty(new AutoSubJobWrapper(sJob.get(0), totalItems, processedItems));
			}

		} 
		return null;
	}

	@RemoteAction
	@ReadOnly
	public static String updateAutoSubJob(String jobId) {
		Core_Subscribe_Job__c sJob = [SELECT Id, Name, Batch_Ids_json_gne__c, Status_gne__c, CreatedDate, LastModifiedDate, Success_Count_gne__c , Errors_Number_gne__c, Parties_Count_gne__c FROM Core_Subscribe_Job__c WHERE Id = :jobId];
		List<String> bIds = (List<String>)JSON.deserialize(sJob.Batch_Ids_json_gne__c, List<String>.class);
		List<AsyncApexJob> apexJobs = [SELECT Id, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id IN : bIds AND Status NOT IN ('Holding','Queued','Preparing')];
		if(bIds.size() == CORE_Subscribe_Util.getNumberOfAutoSubBatches() && apexJobs.size() != CORE_Subscribe_Util.getNumberOfAutoSubBatches()) {
			return JSON.serializePretty(new AutoSubJobWrapper(sJob, 0, 0));
		} else {
			Integer totalItems = 0;
			Integer processedItems = 0;
			for(AsyncApexJob job : apexJobs) {
				totalItems += job.TotalJobItems;
				processedItems += job.JobItemsProcessed;
			}
			return JSON.serializePretty(new AutoSubJobWrapper(sJob, totalItems, processedItems));
		}
	}

	public class SectionWrapper {
		public String label { get; set; }
		public String name { get; set; }
		public String url { get; set; }

		public SectionWrapper(String label, String name, String url, Boolean isCustomSetting) {
			this.label = label;
			this.name = name;
			this.url = (isCustomSetting ? '/setup/ui/listCustomSettingsData.apexp?id=' : '/') + url;
		}
	}

	public class AutoSubJobWrapper {
		public Core_Subscribe_Job__c job { get; set; }
		public Integer totalItems { get; set; }
		public Integer processedItems { get; set; }

		public AutoSubJobWrapper(Core_Subscribe_Job__c job, Integer totalItems, Integer processedItems) {
			this.job = job;
			this.totalItems = totalItems;
			this.processedItems = processedItems;
		}
	}
}