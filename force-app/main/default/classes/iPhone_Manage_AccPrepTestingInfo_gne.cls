@RestResource(urlMapping='/iPhoneManageAccPrepTestingInfo/*')
global with sharing class iPhone_Manage_AccPrepTestingInfo_gne {
	
	@HttpPost 
	global static iPhone_Commons_gne.RestResponse processRequest(String unixId, List<TestingInfoWrapper> records) {		
		return iPhone_Commons_gne.executeAlterData(
			new ManageAccPrepTestingInfoExecutor(), 
			new ManageAccPrepTestingInfoArg(unixId, records)
		);						 																					
	}
	
	class ManageAccPrepTestingInfoArg implements iPhone_Commons_gne.BaseArgs {
		public String unixId;
		public List<TestingInfoWrapper> recordWrappers;
		
		public ManageAccPrepTestingInfoArg(String unixId, List<TestingInfoWrapper> recordWrappers) {
			this.unixId = unixId;
			this.recordWrappers = recordWrappers;
		}
		
		public String getIPhoneRequestId(){
            return (recordWrappers!=null && !recordWrappers.isEmpty()) ? recordWrappers[0].rid : null;
        }		
	}
	
	public without sharing class ManageAccPrepTestingInfoExecutor implements iPhone_Commons_gne.Runnable {
		
		public Object run(Object obj) {
			ManageAccPrepTestingInfoArg arg = (ManageAccPrepTestingInfoArg)obj;
			List<SFA2_PREP_Account_Testing_Info_gne__c> recstoDelete = new List<SFA2_PREP_Account_Testing_Info_gne__c>();
			List<SFA2_PREP_Account_Testing_Info_gne__c> recstoUpsert = new List<SFA2_PREP_Account_Testing_Info_gne__c>();
			
			if(arg.recordWrappers!=null) {
				Map<String,Id> requestIdToSfdcIdMap = getSfdcIdsForRequestIds(arg.recordWrappers);
				
				for(TestingInfoWrapper recWrapper : arg.recordWrappers) {
					Id sfdcId = recWrapper.rid!=null ? requestIdToSfdcIdMap.get(recWrapper.rid.toUpperCase()) : null;
					recWrapper.manageRecord(sfdcId, recstoDelete, recstoUpsert);
				}
			}
			
			if(!recstoDelete.isEmpty()) {
				delete recstoDelete;
			}
			
			if(!recstoUpsert.isEmpty()) {
				upsert recstoUpsert;
			}

			Map<String,Id> result = new Map<String,Id>();
			fillRequestIdSfdcIdMap(result, recstoUpsert, false);
			return result;
		}
		
		private Map<String,Id> getSfdcIdsForRequestIds(List<TestingInfoWrapper> recordWrappers) {
			Map<String,Id> requestIdToSfdcIdMap = new Map<String,Id>();
			
			for(TestingInfoWrapper recWrapper : recordWrappers) {
				if(String.isNotBlank(recWrapper.rid) && String.isBlank(recWrapper.Id)) {
					requestIdToSfdcIdMap.put(recWrapper.rid.toUpperCase(), null);
				}
			}
			
			if(!requestIdToSfdcIdMap.isEmpty()) {
				fillRequestIdSfdcIdMap(
					requestIdToSfdcIdMap,
					iPhone_DAO.getRecordsWithRequestIds(requestIdToSfdcIdMap.keySet(), SFA2_PREP_Account_Testing_Info_gne__c.sObjectType.getDescribe().getName()),
					true
				);
			}
			
			return requestIdToSfdcIdMap;
		}
		
		private void fillRequestIdSfdcIdMap(Map<String,Id> requestIdToSfdcIdMap, List<SObject> recs, Boolean upperCaseMode) {
			for(SObject rec : recs) {
				String reqId = (String)rec.get('iPhone_Request_Id_gne__c');
				reqId = upperCaseMode ? reqId.toUpperCase() : reqId;
				requestIdToSfdcIdMap.put(reqId, rec.Id);
			}
		}
	}
	
	global class TestingInfoWrapper extends iPhone_Get_Account_PrepTestingInfo_gne.GetAccountPrepTestingInfoRecord {
		private String rid;
		
		private void manageRecord(Id sfdcId, List<SObject> recstoDelete, List<SObject> recstoUpsert) {
			
			SFA2_PREP_Account_Testing_Info_gne__c rec = ax == 'd'
					? new SFA2_PREP_Account_Testing_Info_gne__c()
					: new SFA2_PREP_Account_Testing_Info_gne__c(
						MDT_Lead_gne__c = this.mtl,
						MDT_Lead_Title_gne__c = this.mtlt,
						Percent_of_Global_gne__c = this.pog,
						Percent_of_TC_gne__c = this.pot,
						Referred_Account_gne__c = String.isNotBlank(this.ra) ? this.ra : null,
						Stage_Tested_gne__c = this.stg,
						Test_Component_gne__c = this.tc,
						Test_Hierarchy_gne__c = this.th,
						Test_Initiator_gne__c = this.ti,
						Test_Method_gne__c = this.tm,
						Test_Type_gne__c = this.tt,
						Testing_Volume_Month_gne__c = this.tv,
						iPhone_Request_Id_gne__c = this.rid);
			
			if(String.isNotBlank(this.id)) {
				rec.Id = this.Id;
			} else if(sfdcId!=null) {
				rec.Id = sfdcId;
			} else if(String.isNotBlank(this.at)) {
				rec.Account_gne__c = this.at;
			}
			
			if(this.ax == 'd') {
				if(String.isNotBlank(rec.Id)) {
					recstoDelete.add(rec);
				}
			} else {
				recstoUpsert.add(rec);
			}
		}		
	}			
}