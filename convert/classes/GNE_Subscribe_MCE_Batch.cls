global without sharing class GNE_Subscribe_MCE_Batch extends GNE_Subscribe_Batch_Base implements Database.Batchable<sObject>, Database.Stateful {
  public static Boolean isMceBatchMode;
  private static final String COMMENT_HCP_NOT_FOUND = 'HCP not found';
  private static final String BATCH_NAME = 'MCE';
  private static final String REC_TYPE_HCP = 'Professional_vod';
  private static final String LAST_PROCESS_CONFIG_ITEM = 'MceLastProcessExecutionDateTime';
  
  private SubscribeMetrics metrics; 
  private Long processStartDateTime;
  private Boolean deltaMode;
  private Set<String> accountMdmIdsToRefresh;
  private Boolean includeDeleted;
  private transient Map<Id,String> stagingPrevAccountIdMap;
  
  global GNE_Subscribe_MCE_Batch(Boolean prevMode) {
    this(prevMode, false, null);
  }
  
  global GNE_Subscribe_MCE_Batch(Boolean deltaMode, Set<String> accountMdmIdsToRefresh) {
      this(false, deltaMode, accountMdmIdsToRefresh);
  }
  
  global GNE_Subscribe_MCE_Batch(Boolean prevMode, Boolean deltaMode, Set<String> accountMdmIdsToRefresh) {
    this.previewMode = prevMode;
    this.metrics = new SubscribeMetrics();
    this.deltaMode = deltaMode;
    this.accountMdmIdsToRefresh = accountMdmIdsToRefresh;
  }
  
  public override String getBatchName() {
    return BATCH_NAME;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    Database.QueryLocator result = null;
    this.processStartDateTime = System.now().getTime();
    
    if(deltaMode==true && accountMdmIdsToRefresh!=null) {
      result = Database.getQueryLocator([
        SELECT Id, Status_gne__c, Comment_gne__c, 
          SFDC_Account_Id_gne__c, MDM_Id_gne__c, Party_Id_gne__c,
          Team_Code_gne__c, Subteam_Code_gne__c, Brand_gne__c, Onlabel_gne__c,
          IsDeleted
        FROM Staging_MCE_gne__c
        WHERE MDM_Id_gne__c IN :accountMdmIdsToRefresh
      ]);
    } else if(deltaMode==true) {
      DateTime lastExecDateTime = getLastProcessExecutionDate();
      Set<String> accMdmIdsToRefresh = getAccountMdmIdsToRefresh(lastExecDateTime);
      
      result = Database.getQueryLocator([
        SELECT Id, Status_gne__c, Comment_gne__c, 
          SFDC_Account_Id_gne__c, MDM_Id_gne__c, Party_Id_gne__c,
          Team_Code_gne__c, Subteam_Code_gne__c, Brand_gne__c, Onlabel_gne__c,
          IsDeleted
        FROM Staging_MCE_gne__c
        WHERE MDM_Id_gne__c IN :accMdmIdsToRefresh
            OR LastModifiedDate > :lastExecDateTime
        ORDER BY IsDeleted ASC
        ALL ROWS 
      ]);
    } else {
      DateTime lastExecDateTime = getLastProcessExecutionDate();
      result = Database.getQueryLocator([
        SELECT Id, Status_gne__c, Comment_gne__c, 
          SFDC_Account_Id_gne__c, MDM_Id_gne__c, Party_Id_gne__c,
          Team_Code_gne__c, Subteam_Code_gne__c, Brand_gne__c, Onlabel_gne__c,
          IsDeleted
        FROM Staging_MCE_gne__c
        WHERE (IsDeleted = false AND Status_gne__c = :GNE_Subscribe_Batch_Base.STATUS_LOADED)
          OR (IsDeleted = true AND Status_gne__c = :GNE_Subscribe_Batch_Base.STATUS_PROCESSED AND LastModifiedDate > :lastExecDateTime)
        ORDER BY IsDeleted ASC
        LIMIT 40000000
        ALL ROWS
      ]);
    }
    
    return result;
  }
  
  private DateTime getLastProcessExecutionDate() {
    GNE_Foun_Misc_Config_Items_gne__c configItem = GNE_Foun_Misc_Config_Items_gne__c.getAll().get(LAST_PROCESS_CONFIG_ITEM);
    String lastProcessedAsString =  configItem!=null ? configItem.Configuration_Value_gne__c : null;
    return String.isNotBlank(lastProcessedAsString) ? DateTime.valueOfGmt(lastProcessedAsString) : DateTime.now().addDays(-14);
  }
  
  private void setLastProcessExecutionDate() {
    GNE_Foun_Misc_Config_Items_gne__c configItem = GNE_Foun_Misc_Config_Items_gne__c.getAll().get(LAST_PROCESS_CONFIG_ITEM);

    if(configItem==null) {
      configItem = new GNE_Foun_Misc_Config_Items_gne__c(Name = LAST_PROCESS_CONFIG_ITEM);
    }  
    
    configItem.Configuration_Value_gne__c = (deltaMode==true ? DateTime.newInstance(processStartDateTime) : System.now()).formatGmt('yyyy-MM-dd HH:mm:ss');
    Database.upsert(configItem, false);
  }
  
  private Set<String> getAccountMdmIdsToRefresh(DateTime lastExecDateTime) {
      Set<String> result = new Set<String>();
      List<Account> accs = [
        SELECT Id, MDMID_gne__c,
          (SELECT Id FROM MCEs_gne__r LIMIT 1)
        FROM Account
        WHERE
          CreatedDate > :lastExecDateTime
          AND RecordType.Name = :REC_TYPE_HCP
          AND MDMID_gne__c <> null
        LIMIT 15000];
      
      for(Account acc : accs) {
          if(acc.MCEs_gne__r.isEmpty()) {
            result.add(acc.MDMID_gne__c);
          }
      }
      
      return result;
  } 
  
  public override void initCache(List<SObject> stgObjs) {
    stagingCache = new Map<String,SObject>();
    targetCache = new Map<String,SObject>();
    stagingPrevAccountIdMap = new Map<Id,String>();
    
    Set<Id> accIds = new Set<Id>();
    Set<String> accMdmIds = new Set<String>();
    Map<String,Map<Id,Staging_MCE_gne__c>> stgMcesByHcpIdMap = new Map<String,Map<Id,Staging_MCE_gne__c>>();
    
    for(Staging_MCE_gne__c smce : (List<Staging_MCE_gne__c>)stgObjs) {
      if(String.isNotBlank(smce.SFDC_Account_Id_gne__c)) {
      	addHcpId(smce.SFDC_Account_Id_gne__c, smce, stgMcesByHcpIdMap);
        accIds.add((Id)smce.SFDC_Account_Id_gne__c);
      }
      
      if(String.isNotBlank(smce.MDM_Id_gne__c)) {
      	String mdmId = smce.MDM_Id_gne__c.toUpperCase();
      	addHcpId(mdmId, smce, stgMcesByHcpIdMap);
        accMdmIds.add(mdmId);
      }
    }
    
    List<Account> hcps = [
      SELECT Id, MDMID_gne__c,
        (SELECT Account_gne__c, Account_gne__r.MDMID_gne__c, Team_Code_gne__c, Subteam_Code_gne__c, Brand_gne__c, Onlabel_gne__c, LastModifiedDate
         FROM MCEs_gne__r)
      FROM Account
      WHERE ID IN :accIds OR MDMID_gne__c IN :accMdmIds
    ];
    
    for(Account hcp : hcps) {
      for(MCE_gne__c mce : hcp.MCEs_gne__r) {
        cacheTargetObject(mce);	
      }
      
      String key1 = hcp.Id;
      String key2 = String.isNotBlank(hcp.MDMID_gne__c) ? hcp.MDMID_gne__c.toUpperCase() : null;
      Map<Id,Staging_MCE_gne__c> smcesMap = new Map<Id,Staging_MCE_gne__c>();
      
      if(stgMcesByHcpIdMap.containsKey(key1)) {
      	smcesMap.putAll(stgMcesByHcpIdMap.get(key1));
      }
      
      if(stgMcesByHcpIdMap.containsKey(key2)) {
        smcesMap.putAll(stgMcesByHcpIdMap.get(key2));
      }
      
      for(Staging_MCE_gne__c smce : smcesMap.values()) {
      	if(smce.SFDC_Account_Id_gne__c!=hcp.Id) {
      	    stagingPrevAccountIdMap.put(smce.Id, smce.SFDC_Account_Id_gne__c);
      		smce.SFDC_Account_Id_gne__c = hcp.Id;
      	}
      	
      	cacheStagingObject(smce);
      	
      	String stgKey = getKeyFromStagingObject(smce);
      	
      	if(!smce.isDeleted && !targetCache.containsKey(stgKey)) {
      		MCE_gne__c mce = new MCE_gne__c(Account_gne__c = hcp.Id, Team_Code_gne__c = smce.Team_Code_gne__c, Subteam_Code_gne__c = smce.Subteam_Code_gne__c, Brand_gne__c = smce.Brand_gne__c);
      		cacheTargetObject(mce);
      	}
      }
    }
  }
  
  private void addHcpId(String hcpId, Staging_MCE_gne__c smce, Map<String,Map<Id,Staging_MCE_gne__c>> stgMcesByHcpIdMap) {
    if(String.isNotBlank(hcpId)) {
      if(!stgMcesByHcpIdMap.containsKey(hcpId)) {
        stgMcesByHcpIdMap.put(hcpId, new Map<Id,Staging_MCE_gne__c>());
      }
      
      stgMcesByHcpIdMap.get(hcpId).put(smce.Id,smce);
    }
  }

  protected override String getKeyFromTargetObject(SObject targetObj) {
  	MCE_gne__c mce = (MCE_gne__c)targetObj;
    return String.format('{0}:{1}:{2}:{3}', new String[]{mce.Account_gne__c, mce.Team_Code_gne__c, mce.Subteam_Code_gne__c, mce.Brand_gne__c}).toUpperCase();
  }

  protected override String getKeyFromStagingObject(SObject stgObj) {
    Staging_MCE_gne__c smce = (Staging_MCE_gne__c)stgObj;
    return String.format('{0}:{1}:{2}:{3}', new String[]{smce.SFDC_Account_Id_gne__c, smce.Team_Code_gne__c, smce.Subteam_Code_gne__c, smce.Brand_gne__c}).toUpperCase();
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    isMceBatchMode = true;
    initCache(scope);
    List<Staging_MCE_gne__c> stgObjs = (List<Staging_MCE_gne__c>)scope;
    List<Staging_MCE_gne__c> smcesToUpdate = new List<Staging_MCE_gne__c>();
    List<MCE_gne__c> mcesToUpsert = new List<MCE_gne__c>();
    List<MCE_gne__c> mcesToDelete = new List<MCE_gne__c>();
    Set<Id> updatedMceIds = new Set<Id>();
    
    for(Staging_MCE_gne__c smce : stgObjs) {
    	MCE_gne__c mce = (MCE_gne__c)getTargetForStagingObject(smce);
    	
    	if(smce.IsDeleted && mce!=null && !updatedMceIds.contains(mce.Id) && mce.LastModifiedDate.getTime()<processStartDateTime) {
    		mcesToDelete.add(mce);
    		metrics.deleted++;
    		updatedMceIds.add(mce.Id);
    	} else if(!smce.IsDeleted) {
	      clearStagingObjectComment(smce);
	      
	      if(mce==null) {
	      	markStagingObjectAsProcessed(smce);
	      	smce.Comment_gne__c = COMMENT_HCP_NOT_FOUND;
	      } else {
	      	markStagingObjectAsProcessed(smce);
	      	
	      	if(!new Set<MCE_gne__c>(mcesToUpsert).contains(mce)) {
		      mce.OnLabel_gne__c = smce.OnLabel_gne__c;
		      mcesToUpsert.add(mce);
	        
	          if(String.isBlank(mce.Id)) {
	        	metrics.inserted++;
	          } else {
	        	metrics.updated++;
	        	updatedMceIds.add(mce.Id);
	          }
	      	}
	      }
	      
	      if(stagingPrevAccountIdMap.containsKey(smce.Id)) {
	          smce.SFDC_Account_Id_gne__c = stagingPrevAccountIdMap.get(smce.Id); 
	      }
	      
	      smcesToUpdate.add(smce);
    	}
    }
    
    executeDml(mcesToDelete, GNE_Subscribe_Batch_Base.DmlType.TARGET_DELETE);
    executeDml(mcesToUpsert, GNE_Subscribe_Batch_Base.DmlType.TARGET_UPSERT);
    
    if(deltaMode!=true) {
        updateStagings(smcesToUpdate);
    }
    
    isMceBatchMode = false;
  }
  
  private void updateStagings(List<Staging_MCE_gne__c> smcesToUpdate) {
    executeDml(smcesToUpdate, GNE_Subscribe_Batch_Base.DmlType.STAGING_UPDATE);
  }
  
  global void finish(Database.BatchableContext BC) {
    doFinish(BC);
    if(previewMode!=true && (deltaMode!=true || accountMdmIdsToRefresh==null)) {
        setLastProcessExecutionDate();
    }
    sendSummaryMail('GNE_Subscribe_MCE_Batch' + (previewMode ? ' (Preview Mode)' : '') + (deltaMode==true ? ' (Delta Mode)' : ''), metrics.print(), 'SubscribeMceNotfyEmail');
  }
  
  private class SubscribeMetrics {
  	private Integer inserted;
  	private Integer updated;
  	private Integer deleted;
  	
  	private SubscribeMetrics() {
  		inserted = updated = deleted = 0;
  	}
  	
  	private String print() {
  		return String.format('MCEs (Inserted/Updated/Deleted): {0}/{1}/{2}', new String[]{String.valueOf(inserted), String.valueOf(updated), String.valueOf(deleted)});
  	}
  }
}