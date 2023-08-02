public virtual class GNE_SFA2_AffiliationEngine {

    private static final String DEFAULT_AFFILIATION_TYPE = 'AFFILIATION';
    private static final String DEFAULT_AFFILIATION_ROLE = 'Affiliated with';

	public virtual List<GNE_SFA2_AffiliationUtil.ResponseWrapper> upsertAffiliations(List<GNE_SFA2_AffiliationUtil.AffiliationWrapper> records) {
        List<GNE_SFA2_AffiliationUtil.ResponseWrapper> result = new List<GNE_SFA2_AffiliationUtil.ResponseWrapper>();
        Map<String, String> iphoneReqToAffId = checkIfAffExist(records);
        for(GNE_SFA2_AffiliationUtil.AffiliationWrapper record : records) {
        	Affiliation_vod__c affiliation = prepareAffiliation(record, iphoneReqToAffId);
        	String validateException = validateAffiliation(affiliation);
        	if(validateException != null) {
        		result.add(new GNE_SFA2_AffiliationUtil.ResponseWrapper(record.rid, null, 'Error', validateException));
        	} else {
        		Database.UpsertResult ur = Database.upsert(affiliation, false);
			    if (ur.isSuccess()) {
			        result.add(new GNE_SFA2_AffiliationUtil.ResponseWrapper(record.rid, ur.getId(), 'Success', null));
			    }
			    else {
			    	String error = '';
			    	for(Database.Error err : ur.getErrors()) {
			            error = 'The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage();
			        }
			        result.add(new GNE_SFA2_AffiliationUtil.ResponseWrapper(record.rid, record.id, 'Error', error));   
			    }
        	}
        }

        return result;
    }

    private Affiliation_vod__c prepareAffiliation(GNE_SFA2_AffiliationUtil.AffiliationWrapper record, Map<String, String> iphoneReqToAffId) {

        if(String.isNotBlank(record.Id)) {
            return new Affiliation_vod__c(
                Id = record.Id,
                Affiliation_Type_gne__c = String.isNotBlank(record.type) && checkIfPicklistValueExist('Affiliation_vod__c', 'Affiliation_Type_gne__c', record.type) ? record.type : DEFAULT_AFFILIATION_TYPE,
                Role_vod__c = String.isNotBlank(record.role) && checkIfPicklistValueExist('Affiliation_vod__c', 'Role_vod__c', record.role) ? record.role : DEFAULT_AFFILIATION_ROLE,
                Influence_vod__c = record.influence,
                Active_for_FRM_gne__c = record.activeForFRM != null ? record.activeForFRM : false,
                Comments_vod__c = record.comments

            );
        } else {
            String key = record.fromAccountId + '_' + record.toAccountId + '_' + record.toContactId;
            if(iphoneReqToAffId.containsKey(key) || iphoneReqToAffId.containsKey(record.rid)) {
                return new Affiliation_vod__c(
                    Id = iphoneReqToAffId.containsKey(key) ? iphoneReqToAffId.get(key) : iphoneReqToAffId.get(record.rid),
                    Affiliation_Type_gne__c = String.isNotBlank(record.type) && checkIfPicklistValueExist('Affiliation_vod__c', 'Affiliation_Type_gne__c', record.type) ? record.type : DEFAULT_AFFILIATION_TYPE,
                    Role_vod__c = String.isNotBlank(record.role) && checkIfPicklistValueExist('Affiliation_vod__c', 'Role_vod__c', record.role) ? record.role : DEFAULT_AFFILIATION_ROLE,
                    Influence_vod__c = record.influence,
                    Comments_vod__c = record.comments,
                    iPhone_Request_Id_gne__c = record.rid
                );
            } else {
                return new Affiliation_vod__c(
                    From_Account_vod__c = record.fromAccountId,
                    To_Account_vod__c = record.toAccountId,
                    To_Contact_vod__c = record.toContactId,
                    Affiliation_Type_gne__c = String.isNotBlank(record.type) && checkIfPicklistValueExist('Affiliation_vod__c', 'Affiliation_Type_gne__c', record.type) ? record.type : DEFAULT_AFFILIATION_TYPE,
                    Role_vod__c = String.isNotBlank(record.role) && checkIfPicklistValueExist('Affiliation_vod__c', 'Role_vod__c', record.role) ? record.role : DEFAULT_AFFILIATION_ROLE,
                    Influence_vod__c = record.influence,
                    Comments_vod__c = record.comments,
                    iPhone_Request_Id_gne__c = record.rid
                );
            }
        }

    }	

    private String validateAffiliation(Affiliation_vod__c record) {
        if(String.isBlank(record.Id)) {
    		if (String.isBlank(record.To_Account_vod__c) && String.isBlank(record.To_Contact_vod__c)) {
                return 'You must specify a To Account or To Contact.'; 
            }
            
            if (String.isNotBlank(record.To_Account_vod__c) && String.isNotBlank(record.To_Contact_vod__c)) {
                return 'Only one To Account or To Contact is allowed, not both.'; 
            }
            
            if (String.isNotBlank(record.To_Account_vod__c) && record.To_Account_vod__c == record.From_Account_vod__c) {
                return 'To Account may not be the same as the From Account.  Please choose a different To Account before saving this Affiliation.';  
            }
        }
        
        return null;

	}

    
    private Map<String, String> checkIfAffExist(List<GNE_SFA2_AffiliationUtil.AffiliationWrapper> records) {
        List<String> iphoneReqIds = new List<String>();
        List<String> fromAcctIds = new List<String>();
        List<String> toAcctIds = new List<String>();
        List<String> toConIds = new List<String>();
        for(GNE_SFA2_AffiliationUtil.AffiliationWrapper record : records) {
            if(record.rid != null && String.isNotBlank(record.rid)) {
                iphoneReqIds.add(record.rid);
            }

            if(record.fromAccountId != null && String.isNotBlank(record.fromAccountId)) {
                fromAcctIds.add(record.fromAccountId);
            }

            if(record.toAccountId != null && String.isNotBlank(record.toAccountId)) {
                toAcctIds.add(record.toAccountId);
            }

            if(record.toContactId != null && String.isNotBlank(record.toContactId)) {
                toConIds.add(record.toContactId);
            }
        }

        Map<String, String> result = new Map<String, String>();  
        for(Affiliation_vod__c aff : [SELECT Id, From_Account_vod__c, To_Account_vod__c, To_Contact_vod__c, iPhone_Request_Id_gne__c FROM Affiliation_vod__c WHERE (iPhone_Request_Id_gne__c IN : iphoneReqIds) OR(From_Account_vod__c IN :fromAcctIds AND To_Account_vod__c IN :toAcctIds) OR (From_Account_vod__c IN :fromAcctIds AND To_Contact_vod__c IN :toConIds)]) {
            if(String.isNotBlank(aff.iPhone_Request_Id_gne__c)) {
                result.put(aff.iPhone_Request_Id_gne__c, aff.Id);
            } else {
                String key = aff.From_Account_vod__c + '_' + aff.To_Account_vod__c + '_' + aff.To_Contact_vod__c;
                result.put(key, aff.Id);
            }    
        }

        return result;
        
    }

    private Boolean checkIfPicklistValueExist(String sObjectName, String fieldName, String value) {
        Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        if(fields.containsKey(fieldName)) {
            DescribeFieldResult field = fields.get(fieldName).getDescribe();
            if(String.valueOf(field.getType()) == 'Picklist') {
                List<Schema.PicklistEntry> plEntries = field.getPicklistValues();
                for(Schema.PicklistEntry plEntry : plEntries) {
                    if(plEntry.getValue() == value) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

}