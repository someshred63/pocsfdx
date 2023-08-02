@RestResource(urlMapping='/iPhoneManageAccSocMemberships/*')
global with sharing class iPhone_Manage_AccSocMemberships_gne {
	
	@HttpPost 
	global static iPhone_Commons_gne.RestResponse processRequest(String unixId, List<AccSocWrapper> records) {		
		return iPhone_Commons_gne.executeAlterData(
			new ManageAccSocMembershipExecutor(), 
			new ManageAccSocMembershipArg(unixId, records)
		);						 																					
	}
	
	class ManageAccSocMembershipArg implements iPhone_Commons_gne.BaseArgs {
		public String unixId;
		public List<AccSocWrapper> recordWrappers; 
		
		public ManageAccSocMembershipArg(String unixId, List<AccSocWrapper> recordWrappers) {
			this.unixId = unixId;
			this.recordWrappers = recordWrappers;
			
		}
		
		public String getIPhoneRequestId(){
            return (recordWrappers!=null && !recordWrappers.isEmpty()) ? recordWrappers[0].rid : null;
        }
	}
	
	public without sharing class ManageAccSocMembershipExecutor implements iPhone_Commons_gne.Runnable {
		
		public Object run(Object obj) {
			ManageAccSocMembershipArg arg = (ManageAccSocMembershipArg)obj;
			List<SFA2_Account_Society_Membership_gne__c> recstoDelete = new List<SFA2_Account_Society_Membership_gne__c>();
			List<SFA2_Account_Society_Membership_gne__c> recstoUpsert = new List<SFA2_Account_Society_Membership_gne__c>();
			
			if(arg.recordWrappers!=null) {
				Map<String,Id> requestIdToSfdcIdMap = getSfdcIdsForRequestIds(arg.recordWrappers);
				
				for(AccSocWrapper recWrapper : arg.recordWrappers) {
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
		
		private Map<String,Id> getSfdcIdsForRequestIds(List<AccSocWrapper> recordWrappers) {
			Map<String,Id> requestIdToSfdcIdMap = new Map<String,Id>();
			
			for(AccSocWrapper recWrapper : recordWrappers) {
				if(String.isNotBlank(recWrapper.rid) && String.isBlank(recWrapper.Id)) {
					requestIdToSfdcIdMap.put(recWrapper.rid.toUpperCase(), null);
				}
			}
			
			if(!requestIdToSfdcIdMap.isEmpty()) {
				fillRequestIdSfdcIdMap(
					requestIdToSfdcIdMap,
					iPhone_DAO.getRecordsWithRequestIds(requestIdToSfdcIdMap.keySet(), SFA2_Account_Society_Membership_gne__c.sObjectType.getDescribe().getName()),
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
	
	global class AccSocWrapper extends iPhone_Get_Account_SocMemberships_gne.GetAccountSocMembershipRecord {
		private String rid;
		
		private void manageRecord(Id sfdcId, List<SObject> recstoDelete, List<SObject> recstoUpsert) {
			SFA2_Account_Society_Membership_gne__c rec = ax == 'd'
					? new SFA2_Account_Society_Membership_gne__c()
					: new SFA2_Account_Society_Membership_gne__c(
						Membership_Name_gne__c = this.mn,
						Other_gne__c = this.ot,
						Year_gne__c = (this.yr!=null ? String.valueOf(this.yr) : null),
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