@RestResource(urlMapping='/iPhoneChangeAccPrepMBOsStatus/*')
global with sharing class iPhone_ChangeAccPrepMBOsStatus_gne {
	@HttpPost 
	global static iPhone_Commons_gne.RestResponse processRequest(String unixId, List<AccStrategyWrapper> records) {		
		return iPhone_Commons_gne.executeAlterData(
			new ChangeAccPrepMBOsStatusExecutor(), 
			new ChangeAccPrepMBOsStatusArg(unixId, records)
		);						 																					
	}
	
	class ChangeAccPrepMBOsStatusArg implements iPhone_Commons_gne.BaseArgs {
		public String unixId;
		public List<AccStrategyWrapper> recordWrappers; 
		
		public ChangeAccPrepMBOsStatusArg(String unixId, List<AccStrategyWrapper> recordWrappers) {
			this.unixId = unixId;
			this.recordWrappers = recordWrappers;
			
		}
		
		public String getIPhoneRequestId(){
            return (recordWrappers!=null && !recordWrappers.isEmpty()) ? recordWrappers[0].rid : null;
        }
	}
	
	public without sharing class ChangeAccPrepMBOsStatusExecutor implements iPhone_Commons_gne.Runnable {
		
		public Object run(Object obj) {
			Map<String,Id> result = new Map<String,Id>();
			
			ChangeAccPrepMBOsStatusArg arg = (ChangeAccPrepMBOsStatusArg)obj;
			List<SFA2_PREP_Account_Testing_Strategy_gne__c> strategiesToInsert = new List<SFA2_PREP_Account_Testing_Strategy_gne__c>();
			List<SFA2_PREP_Account_Testing_Strategy_gne__c> strategiesToUpdate = new List<SFA2_PREP_Account_Testing_Strategy_gne__c>();
			List<SFA2_PREP_Account_MBO_gne__c> mbosToUpsert = new List<SFA2_PREP_Account_MBO_gne__c>();
			
			if(arg.recordWrappers!=null) {
				Set<Id> accIds = new Set<Id>();
				Map<String,AccStrategyWrapper> strategyWrappersMap = new Map<String,AccStrategyWrapper>();
				Map<String,MboWrapper> mboWrappersMap = new Map<String,MboWrapper>();
				
				for(AccStrategyWrapper strategyWrapper : arg.recordWrappers) {
					try {
						accIds.add(Id.valueOf(strategyWrapper.at));
					} catch(Exception ex) {}
					
					strategyWrappersMap.put(strategyWrapper.getKey(), strategyWrapper);
					
					if(strategyWrapper.mbos!=null) {
						for(MboWrapper mboWrapper : strategyWrapper.mbos) {
							mboWrappersMap.put(mboWrapper.getKey(strategyWrapper), mboWrapper);
						}	
					}
					
				}
				
				Map<String,SFA2_PREP_Account_Testing_Strategy_gne__c> aStrategiesMap = new Map<String,SFA2_PREP_Account_Testing_Strategy_gne__c>();
				Map<String,SFA2_PREP_Account_MBO_gne__c> aMBOsMap = new Map<String,SFA2_PREP_Account_MBO_gne__c>();
				
				for(SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy : GNE_SFA2_PREP_Util.getActiveForAccountStrategies(accIds)) {
					aStrategiesMap.put(GNE_SFA2_PREP_Util.getRecordKey(aStrategy), aStrategy);
			
					for(SFA2_PREP_Account_MBO_gne__c aMBO : aStrategy.Account_MBOs_gne__r) {
						aMBOsMap.put(GNE_SFA2_PREP_Util.getRecordKey(aMBO), aMBO);
					}
				}
				
				List<SFA2_PREP_Testing_Strategy_gne__c> tStrategies = GNE_SFA2_PREP_Util.getActiveForAccountTestingStrategiesWithMBOs();
				
				for(Id accId : accIds) {
					for(SFA2_PREP_Testing_Strategy_gne__c tStrategy : tStrategies) {
						String aStrategyKey = GNE_SFA2_PREP_Util.getRecordKey(tStrategy) + '_' + accId;
						SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy = aStrategiesMap.get(aStrategyKey);
						AccStrategyWrapper strategyWrapper = strategyWrappersMap.get(aStrategyKey);
						
						if(aStrategy==null) {
							aStrategy = new SFA2_PREP_Account_Testing_Strategy_gne__c(
								Testing_Strategy_gne__c = tStrategy.Id,
								Testing_Strategy_gne__r = tStrategy, 
								Account_gne__c = accId,
								Status_gne__c = (strategyWrapper!=null ? strategyWrapper.st : GNE_SFA2_PREP_Util.PREP_STATUS_RED)
							);
							
							aStrategiesMap.put(GNE_SFA2_PREP_Util.getRecordKey(aStrategy), aStrategy);
							strategiesToInsert.add(aStrategy);
						} else {
							strategiesToUpdate.add(aStrategy);
						}
						
						aStrategy.iPhone_Request_Id_gne__c = strategyWrapper!=null ? strategyWrapper.rid : aStrategy.iPhone_Request_Id_gne__c;
					}
				}
				
				if(!strategiesToInsert.isEmpty()) {
					insert strategiesToInsert;
				}
				
				if(!strategiesToUpdate.isEmpty()) {
					GNE_SFA2_PREP_Trigger_Helper.setAccStrategyTrig(true);
					update strategiesToUpdate;
					GNE_SFA2_PREP_Trigger_Helper.setAccStrategyTrig(false);
				}
				
				for(Id accId : accIds) {
					for(SFA2_PREP_Testing_Strategy_gne__c tStrategy : tStrategies) {
						String aStrategyKey = GNE_SFA2_PREP_Util.getRecordKey(tStrategy) + '_' + accId;
						SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy = aStrategiesMap.get(aStrategyKey);
						
						for(SFA2_PREP_MBO_gne__c mbo : tStrategy.MBOs_gne__r) {
							String aMboKey = GNE_SFA2_PREP_Util.getRecordKey(mbo) + '_' + accId;
							SFA2_PREP_Account_MBO_gne__c aMBO = aMBOsMap.get(aMboKey);
							MboWrapper mboWrapper = mboWrappersMap.get(aMboKey);
							
							if(aMBO==null) {
								aMBO = new SFA2_PREP_Account_MBO_gne__c(
									MBO_gne__c = mbo.Id, MBO_gne__r = mbo, 
									Account_Testing_Strategy_gne__c = aStrategy.Id, Account_Testing_Strategy_gne__r = aStrategy,
									Status_gne__c = (String.isNotBlank(mbo.Default_Status_gne__c) ? mbo.Default_Status_gne__c : GNE_SFA2_PREP_Util.PREP_STATUS_RED)
								);
							}
							
							aMBO.iPhone_Request_Id_gne__c = mboWrapper!=null ? mboWrapper.rid : aMBO.iPhone_Request_Id_gne__c;
							aMBO.Status_gne__c = mboWrapper!=null ? mboWrapper.st : aMBO.Status_gne__c;
							mbosToUpsert.add(aMbo);
						}
					}
				}
				
				if(!mbosToUpsert.isEmpty()) {
					upsert mbosToUpsert;
				}
				
				fillRequestIdSfdcIdMap(result, strategiesToInsert, false);
				fillRequestIdSfdcIdMap(result, strategiesToUpdate, false);
				fillRequestIdSfdcIdMap(result, mbosToUpsert, false);
			}
						
			return result;
		}
		
		private void fillRequestIdSfdcIdMap(Map<String,Id> requestIdToSfdcIdMap, List<SObject> recs, Boolean upperCaseMode) {
			for(SObject rec : recs) {
				String reqId = (String)rec.get('iPhone_Request_Id_gne__c');
				reqId = upperCaseMode ? reqId.toUpperCase() : reqId;
				
				if(String.isNotBlank(reqId)) {
					requestIdToSfdcIdMap.put(reqId, rec.Id);
				}
			}
		}
	}
	
	global class AccStrategyWrapper extends iPhone_Get_Account_PrepStrategies_gne.GetAccountPrepStrategyRecord {
		private String rid;
		public List<MboWrapper> mbos;
		
		private String getKey() {
			return this.tsi + '_' + this.at; 
		}
	}
	
	global class MboWrapper extends iPhone_Get_Account_PrepStrategies_gne.MboWrapper {
		private String rid;
		
		private String getKey(AccStrategyWrapper strategyWrapper) {
			return strategyWrapper.tsi + '_' + this.mboi + '_' + strategyWrapper.at; 
		}
	}
}