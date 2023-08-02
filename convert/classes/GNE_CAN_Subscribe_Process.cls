public without sharing class GNE_CAN_Subscribe_Process {
    
    private class Subscribe_Cache {
        public List<Stg_SFA_Cust_Can__c>                stgCustomersList;
        public Map<Id, Account>                         accountsBySfdcIdMap;
        public Map<String, List<Account>>               accountsByRocheIdMap;
        public Map<Id, Address_vod__c>                  addressesBySfdcIdMap;
        public Map<String, List<Address_vod__c>>		addressesByRocheIdMap;
        public List<Stg_SFA_Subscribe_Apex_Job_Error__c> errorsToInsert;
        public Map<String,Id>                           recordTypeNameToIdMap;
        public Map<Id,String>                           recordTypeIdToNameMap;
        public Map<Id, Stg_SFA_Cust_Can__c>             stgCustomersToUpdate;
        public Map<Id,Stg_SFA_Cust_Addr_Can__c>         stgAddressesToUpdate;
        public Set<String>                              provinceValues; 
        
        public Subscribe_Cache() {
            stgCustomersList        = new List<Stg_SFA_Cust_Can__c>();
            accountsBySfdcIdMap     = new Map<Id, Account>();
            accountsByRocheIdMap	= new Map<String, List<Account>>();
            addressesBySfdcIdMap    = new Map<Id, Address_vod__c>();
            addressesByRocheIdMap	= new Map<String, List<Address_vod__c>>();
            errorsToInsert          = new List<Stg_SFA_Subscribe_Apex_Job_Error__c>();
            recordTypeNameToIdMap   = new Map<String,Id>();
            recordTypeIdToNameMap   = new Map<Id,String>();
            stgCustomersToUpdate    = new Map<Id,Stg_SFA_Cust_Can__c>();
            stgAddressesToUpdate    = new Map<Id,Stg_SFA_Cust_Addr_Can__c>();
            provinceValues          = new Set<String>();
        }
    }
    
    private Subscribe_Cache cache;
    private Stg_SFA_Subscribe_Apex_Job__c currentApexJob;
    private GNE_CAN_Subscribe_Metrics mainMetrics;
    
    private void initCache(Set<Id> stgCustIds) {
        cache = new Subscribe_Cache();
        
        for(RecordType rt : GNE_CAN_Subscribe_DAO.getAccountAndAddressRecordTypes()) {
            cache.recordTypeIdToNameMap.put(rt.Id, rt.Name);
            cache.recordTypeNameToIdMap.put(rt.Name, rt.Id);
        }
        
        for(Schema.PickListEntry plEntry : Address_vod__c.Province_can_gne__c.getDescribe().getPicklistvalues()) {
            cache.provinceValues.add(plEntry.getValue());
        }
        
        cache.stgCustomersList = GNE_CAN_Subscribe_DAO.getCustomersWithAddressesByIds(stgCustIds);
        
        Set<String> rocheIds = new Set<String>();
        
        for(Stg_SFA_Cust_Can__c stgCustomer : cache.stgCustomersList) {
        	rocheIds.add(stgCustomer.Roche_Cust_Id_can__c);
        }
        
        for(Account sfdcAccount : GNE_CAN_Subscribe_DAO.getAccountsByRocheIds(rocheIds)) {
        	String rocheId = sfdcAccount.Roche_Id_can_gne__c.toUpperCase();
        	if(!cache.accountsByRocheIdMap.containsKey(rocheId)) {
        		cache.accountsByRocheIdMap.put(rocheId, new List<Account>());
        	}
        	cache.accountsByRocheIdMap.get(rocheId).add(sfdcAccount);
        }
          
        Set<String> accountSfdcIds  = new Set<String>();
        Set<String> addressRocheIds = new Set<String>();
        Set<String> addressSfdcIds  = new Set<String>();
          
        for(Stg_SFA_Cust_Can__c stgCustomer : cache.stgCustomersList) {
            if(stgCustomer.Src_Cust_Id_can__c!=null) {
                accountSfdcIds.add(stgCustomer.Src_Cust_Id_can__c);
            }
            
            for(Stg_SFA_Cust_Addr_Can__c stgAddress : stgCustomer.Stg_SFA_Cust_ref_can__r) {
                if(stgAddress.Roche_Addr_Id_can__c!=null) {
                    addressRocheIds.add(stgAddress.Roche_Addr_Id_can__c);
                }
                
                if(stgAddress.Src_Addr_Id_can__c!=null) {
                    addressSfdcIds.add(stgAddress.Src_Addr_Id_can__c);
                }
            }
        }
        
        for(Account sfdcAccount : GNE_CAN_Subscribe_DAO.getAccountsBySfdcIds(accountSfdcIds)) {
            cache.accountsBySfdcIdMap.put(sfdcAccount.Id, sfdcAccount);
        }
        
        for(Address_vod__c sfdcAddress : GNE_CAN_Subscribe_DAO.getAddressesBySfdcIds(addressSfdcIds)) {
            cache.addressesBySfdcIdMap.put(sfdcAddress.Id, sfdcAddress);
        }
        
        for(Address_vod__c sfdcAddress : GNE_CAN_Subscribe_DAO.getAddressesByRocheIds(addressRocheIds)) {
        	String rocheId = sfdcAddress.Roche_Address_Id_can__c.toUpperCase();
        	if(!cache.addressesByRocheIdMap.containsKey(rocheId)) {
        		cache.addressesByRocheIdMap.put(rocheId, new List<Address_vod__c>());
        	}
        	cache.addressesByRocheIdMap.get(rocheId).add(sfdcAddress);
        }
        
        
    }
    
    private Account getSfdcAccountForStgCustomer(Stg_SFA_Cust_Can__c stgCustomer) {
        Account sfdcAccount = null;
        
        if(stgCustomer.Src_Cust_Id_can__c!=null && cache.accountsBySfdcIdMap.containsKey((Id)stgCustomer.Src_Cust_Id_can__c)) {
            sfdcAccount = cache.accountsBySfdcIdMap.get((Id)stgCustomer.Src_Cust_Id_can__c);
        } 
        
        return sfdcAccount;
    }
    
    private Address_vod__c getSfdcAddressForStgAddress(Stg_SFA_Cust_Addr_Can__c stgAddress) {
        Address_vod__c sfdcAddress = null;
        
        if(stgAddress.Src_Addr_Id_can__c!=null && cache.addressesBySfdcIdMap.containsKey((Id)stgAddress.Src_Addr_Id_can__c)) {
            sfdcAddress = cache.addressesBySfdcIdMap.get((Id)stgAddress.Src_Addr_Id_can__c);
        }
        
        return sfdcAddress;
    }
    
    private Id getRecordTypeIdFromStagingObject(Stg_SFA_Cust_Can__c stgCustomer, Account targetAccount) {
        Id recordTypeId;
        if(stgCustomer.Cust_class_can__c == GNE_CAN_Subscribe_Util.HCO_CUSTOMER_CLASS_NAME) {
        	Id existingRecTypeId = targetAccount.RecordTypeId;
        	
        	// if existing Account has one of Canada HCO Record Type, no need to check Account Type to get correct Record Type
        	if(existingRecTypeId != null) {
        		String existingRecTypeName = cache.recordTypeIdToNameMap.get(existingRecTypeId);
        		if(existingRecTypeName == GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO_DEPARTMENT || 
        		   existingRecTypeName == GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO) {
        		
        			recordTypeId = existingRecTypeId;
        		}
        	}
        	
        	if(recordTypeId==null) {
	            recordTypeId = stgCustomer.Acount_Type_can__c == GNE_CAN_Subscribe_Util.DEPARTMENT_ACCOUNT_TYPE ?
	                                cache.recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO_DEPARTMENT) :
	                                cache.recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO);
        	}
        } else {
            recordTypeId = cache.recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_HCP);
        }
        
        return recordTypeId;
    }
    
    private Id getRecordTypeIdFromStagingObject(Stg_SFA_Cust_Addr_Can__c stgAddress, Address_vod__c sfdcAddress) {
        Account sfdcAccount = cache.accountsBySfdcIdMap.get(sfdcAddress.Account_vod__c);
            
        Id recordTypeId = cache.recordTypeIdToNameMap.get(sfdcAccount.RecordTypeId) == GNE_CAN_Subscribe_Util.RECORD_TYPE_HCP ?
                            cache.recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_ADDRESS_HCP) :
                            cache.recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_ADDRESS_HCO);
        return recordTypeId;
    }
    
    private Boolean updateSfdcAccountFields(Stg_SFA_Cust_Can__c stgCustomer, Account targetAccount, Account targetAccountCopy) {
        Boolean somethingChanged = false;
        
        Set<String> excludedFieldsSet = new Set<String>();
        
        if(targetAccount.RecordTypeId==null) {
            somethingChanged = true;
            targetAccount.RecordTypeId = targetAccountCopy.RecordTypeId = getRecordTypeIdFromStagingObject(stgCustomer, targetAccount);
        }
        
        if(targetAccount.Region_code_gne__c==null) {
            somethingChanged = true;
            targetAccount.Region_code_gne__c = targetAccountCopy.Region_code_gne__c = GNE_CAN_Subscribe_Util.ACOUNT_DEFAULT_REGION_CODE;
        }
        
        if(stgCustomer.Cust_class_can__c == GNE_CAN_Subscribe_Util.HCO_CUSTOMER_CLASS_NAME) {
            excludedFieldsSet.add('SALUTATION_CAN__C');
            excludedFieldsSet.add('LASTNAME_CAN__C');
            excludedFieldsSet.add('FIRSTNAME_CAN__C');
            excludedFieldsSet.add('GENDER_CAN__C');
            excludedFieldsSet.add('MIDDLE_CAN__C');
        }else{
            excludedFieldsSet.add('ORG_NAME_CAN__C');   
        }
        
        return updateSfdcObjectFields(stgCustomer, targetAccount, targetAccountCopy, excludedFieldsSet) || somethingChanged;
    }
    
    private Boolean updateSfdcAddressFields(Stg_SFA_Cust_Addr_Can__c stgAddress, Address_vod__c targetAddress, Address_vod__c targetAddressCopy) {
        Boolean somethingChanged = false;
        Set<String> excludedFieldsSet = new Set<String>();
        
        if(targetAddress.RecordTypeId==null) {
            somethingChanged = true;
            targetAddress.RecordTypeId = targetAddressCopy.RecordTypeId = getRecordTypeIdFromStagingObject(stgAddress, targetAddress);
        }
        
        Set<String> yesValues = new Set<String>{'Y','1','TRUE'};
        if(stgAddress.Pri_Addr_Ind_can__c!=null && targetAddress.Primary_vod__c != yesValues.contains(stgAddress.Pri_Addr_Ind_can__c.toUpperCase())) {
            somethingChanged = true;
            targetAddress.Primary_vod__c = targetAddressCopy.Primary_vod__c = yesValues.contains(stgAddress.Pri_Addr_Ind_can__c.toUpperCase());
        }
        excludedFieldsSet.add('PRI_ADDR_IND_CAN__C');
        
        String inactiveFlagValue = GNE_CAN_Subscribe_Util.ADDRESS_UAD_INDICATOR_INACTIVE;
        if(stgAddress.UAD_Ind_can__c!=null && targetAddress.Inactive_vod__c != (stgAddress.UAD_Ind_can__c.toUpperCase()==inactiveFlagValue)) {
            somethingChanged = true;
            targetAddress.Inactive_vod__c = targetAddressCopy.Inactive_vod__c = (stgAddress.UAD_Ind_can__c.toUpperCase()==inactiveFlagValue);
            if(targetAddress.Inactive_vod__c) {
            	targetAddress.Inactivate_Reason_gne__c = targetAddressCopy.Inactivate_Reason_gne__c = GNE_CAN_Subscribe_Util.ADDRESS_INACTIVATE_REASON;
            }
        }
        excludedFieldsSet.add('UAD_IND_CAN__C');
        
        return updateSfdcObjectFields(stgAddress, targetAddress, targetAddressCopy, excludedFieldsSet) || somethingChanged;
    }
    
    private Boolean updateSfdcObjectFields(SObject stgObj, SObject targetObj, SObject targetObjCopy, Set<String> excludedFieldsSet) {
        Boolean somethingChanged = false;
        Boolean isNewObj = targetObj.Id == null;
        String stgSObjectName = stgObj.getSObjectType().getDescribe().getName();
        Map<String, String> fieldsMapping = GNE_CAN_Subscribe_Util.getFieldMappings(stgSObjectName, targetObj.getSObjectType().getDescribe().getName());
        
        for(String stgFieldName : fieldsMapping.keySet()) {
            if(excludedFieldsSet.contains(stgFieldName.toUpperCase())) {
                continue;
            }
            
            GNE_CAN_Subscribe_Util.FieldMappingUpdateMode updateMode = GNE_CAN_Subscribe_Util.getFieldUpdateMode(stgSObjectName, stgFieldName);
            Boolean isCaseSensitive = GNE_CAN_Subscribe_Util.isFieldCaseSensitiveMode(stgSObjectName, stgFieldName);
            Boolean canUpdate = false;
            
            String targetFieldName = fieldsMapping.get(stgFieldName);
            Object stgFieldValue = stgObj.get(stgFieldName);
            Object targetFieldValue = targetObj.get(targetFieldName);
            
            if((isNewObj && updateMode!=null) || updateMode == GNE_CAN_Subscribe_Util.FieldMappingUpdateMode.ALWAYS) {
                canUpdate = true;
            } else if(updateMode == GNE_CAN_Subscribe_Util.FieldMappingUpdateMode.SOURCE_FIELD_NOT_NULL && stgFieldValue!=null) {
                canUpdate = true;
            } else if(updateMode == GNE_CAN_Subscribe_Util.FieldMappingUpdateMode.TARGET_FIELD_NULL && targetFieldValue==null) {
                canUpdate = true;
            }
            
            if(canUpdate && (isNewObj || fieldValueNotEquals(stgFieldValue, targetFieldValue, isCaseSensitive))) {
                somethingChanged = true;
                // Store the new value on both objects. Only copied object will be used used in upsert operation. 
                targetObj.put(targetFieldName, stgFieldValue);
                targetObjCopy.put(targetFieldName, stgFieldValue);
            }
        }
        
        return somethingChanged;
    }
    
    private Boolean fieldValueNotEquals(Object stgFieldValue, Object targetFieldValue, Boolean isCaseSensitive) {
    	return (!isCaseSensitive && targetFieldValue!=stgFieldValue) || (isCaseSensitive && !String.valueOf(targetFieldValue!=null ? targetFieldValue : '').equals(String.valueOf(stgFieldValue!=null ? stgFieldValue : '')));
    }
    
    private void executeDML(List<SObject> objs, List<SObject> stgObjs) { 
        Database.UpsertResult[] results = Database.upsert(objs, false);
        
        if(results!=null) {
            Integer i = 0;
            for(Database.UpsertResult result : results) {
                SObject obj = objs[i];
                SObject stgObj = stgObjs!=null ? stgObjs[i] : null;
                i++;
                try {
                    if(result.isSuccess()) {
                        updateStagingRecord(obj, stgObj, true);
                        Boolean isNewRecord = updateCacheWithNewRecord(obj);
                        mainMetrics.updateMetricsWithObject(obj, GNE_CAN_Subscribe_Metrics.MetricTypeName.SUCCESS, isNewRecord);
                    } else {
                        for (Database.Error err : result.getErrors()) {
                            reportException(err,obj, stgObj);
                        }
                        
                        updateStagingRecord(obj, stgObj, false);
                    }
                } catch(Exception ex) {
                    reportException(ex, obj, stgObj);
                }
            }
        }
    }
    
    private Boolean updateCacheWithNewRecord(SObject obj) {
    	Boolean isNewRecord = false;
        if(obj.getSObjectType() == Account.sObjectType && !cache.accountsBySfdcIdMap.containsKey(obj.Id)) {
        	isNewRecord = true;
            cache.accountsBySfdcIdMap.put(obj.id,(Account)obj);
        } else if(obj.getSObjectType() == Address_vod__c.sObjectType  && !cache.addressesBySfdcIdMap.containsKey(obj.Id)) {
        	isNewRecord = true;
            cache.addressesBySfdcIdMap.put(obj.id,(Address_vod__c)obj);
        }
        
        return isNewRecord;
    }
    
    private void updateStagingRecord(SObject obj, SObject stgObj, Boolean isSuccess) {
        if (stgObj!=null) {
            if(stgObj.getSObjectType() == Stg_SFA_Cust_Can__c.sObjectType) {
                Stg_SFA_Cust_Can__c stgCustomer = (Stg_SFA_Cust_Can__c)stgObj;
                Account sfdcAccount = (Account)obj;
                
                stgCustomer.Src_Cust_Id_can__c=sfdcAccount!=null ? sfdcAccount.Id : null;
                    
                cache.stgCustomersToUpdate.put(stgCustomer.Id, new Stg_SFA_Cust_Can__c(
                    Id = stgCustomer.Id,
                    Src_Cust_Id_can__c = sfdcAccount!=null ? sfdcAccount.Id : null,
                    Last_Subscribe_Date_can__c = System.now(),
                    Subscribe_Status_can__c = isSuccess ? GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_SUCCESS : GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED
                ));
            } else if (stgObj.getSObjectType() == Stg_SFA_Cust_Addr_Can__c.sObjectType) {
                Stg_SFA_Cust_Addr_Can__c stgAddress = (Stg_SFA_Cust_Addr_Can__c)stgObj;
                Address_vod__c sfdcAddress = (Address_vod__c)obj;
                
                if(isSuccess) {
                    stgAddress.Src_Addr_Id_can__c=sfdcAddress.Id;
                    stgAddress.Src_Id_can__c=sfdcAddress.Account_vod__c;
                    
                    cache.stgAddressesToUpdate.put(stgAddress.Id, new Stg_SFA_Cust_Addr_Can__c(
                        Id = stgAddress.Id,
                        Src_Addr_Id_can__c=sfdcAddress.Id,
                        Src_Id_can__c=sfdcAddress.Account_vod__c
                    ));
                } else {
                    if(cache.stgCustomersToUpdate.containsKey(stgAddress.Stg_SFA_Cust_ref_can__c)) {
                        Stg_SFA_Cust_Can__c stgCustomer = cache.stgCustomersToUpdate.get(stgAddress.Stg_SFA_Cust_ref_can__c);
                        stgCustomer.Subscribe_Status_can__c = GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED_ON_ADDRESS;
                    }
                }
            }
        }
    }
    
    private void reportException(Database.Error err, SObject obj, SObject stgObj) {
        reportException(new GNE_CAN_Subscribe_Util.ExceptionInfo(err), obj, stgObj);
    }
    
    private void reportException(GNE_CAN_Subscribe_Util.SubscribeException ex, SObject obj, SObject stgObj) {
    	Boolean updateMetricsOnlyOnce = true;
    	for(GNE_CAN_Subscribe_Util.KnownException exType : ex.errors) {
    		reportException(new GNE_CAN_Subscribe_Util.ExceptionInfo(exType), obj, stgObj, updateMetricsOnlyOnce);
    		updateMetricsOnlyOnce = false;	
    	}
    }
    
    private void reportException(Exception ex, SObject obj, SObject stgObj) {
        reportException(new GNE_CAN_Subscribe_Util.ExceptionInfo(ex), obj, stgObj);
    }
    
    private void reportException(GNE_CAN_Subscribe_Util.ExceptionInfo exInfo, SObject obj, SObject stgObj) {
    	reportException(exInfo, obj, stgObj, true);
    }
    
    private void reportException(GNE_CAN_Subscribe_Util.ExceptionInfo exInfo, SObject obj, SObject stgObj, Boolean updateMetrics) {
        GNE_CAN_Subscribe_Util.addDebugMessage(exInfo.print());
        if(updateMetrics) {
        	mainMetrics.updateMetricsWithObject(obj, GNE_CAN_Subscribe_Metrics.MetricTypeName.ERROR);
        }
        
        if(currentApexJob!=null) {
            // Error need to be connected to existing record.
            // We cannot connect it to record that failed during insert operation. 
            if(obj.id==null) {
                obj = stgObj!=null ? stgObj : obj;
            }
            
            Stg_SFA_Subscribe_Apex_Job_Error__c err = 
                new Stg_SFA_Subscribe_Apex_Job_Error__c(
                    Job_Id_can__c = currentApexJob.Id, 
                    Object_Name_can__c = (String)obj.get('Name'),
                    Object_Type_can__c = obj.getSObjectType().getDescribe().getName(),
                    Record_ID_can__c = obj.Id);
            
            exInfo.fillApexJobError(err);
            cache.errorsToInsert.add(err);
        }
    }
    
    private void validateAccount(Stg_SFA_Cust_Can__c stgCustomer, Account sfdcAccount) {
        List<GNE_CAN_Subscribe_Util.KnownException> errorMsgs = new List<GNE_CAN_Subscribe_Util.KnownException>();
        
        if(stgCustomer.UAD_Ind_can__c==GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE) {
        	if(sfdcAccount==null) {
        		errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.TARGET_ACCOUNT_FOR_UPDATE_NOT_FOUND);
        	}
        } else if(stgCustomer.UAD_Ind_can__c==GNE_CAN_Subscribe_Util.UAD_INDICATOR_INSERT) {
        	if(cache.accountsByRocheIdMap.containsKey(stgCustomer.Roche_Cust_Id_can__c.toUpperCase())) {
        		errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.TARGET_ACCOUNT_WITH_GIVEN_ROCHE_ID_ALREADY_EXISTS);
        	}
        	
        	if(stgCustomer.Stg_SFA_Cust_ref_can__r.isEmpty()) {
            	errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ACCOUNT_HAS_NO_ADDRESS);
        	} else {
        		Boolean isOk = false;
        		List<GNE_CAN_Subscribe_Util.KnownException> addrErrorMsgs = new List<GNE_CAN_Subscribe_Util.KnownException>();
        		for(Stg_SFA_Cust_Addr_Can__c stgAddress : stgCustomer.Stg_SFA_Cust_ref_can__r) {
        			try {
        				validateAddress(stgAddress, null, stgCustomer, sfdcAccount);
        				// if we are here, it means that at least one address passed the validation
        				isOk = true;
        				break;
        			} catch (GNE_CAN_Subscribe_Util.SubscribeException se) {
        				for(GNE_CAN_Subscribe_Util.KnownException ke : se.errors) {
        					addrErrorMsgs.add(ke);	
        				}
        			}
        		}
        		
        		if(!isOk) {
        			errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ACCOUNT_HAS_NO_VALID_ADDRESS);
        			errorMsgs.addAll(addrErrorMsgs);
        		}
        	}
        } else {
        	errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ACCOUNT_UAD_INDICATOR_NOT_VALID);
        }
        
        if(stgCustomer.Cust_class_can__c == GNE_CAN_Subscribe_Util.HCP_CUSTOMER_CLASS_NAME) {
            if(stgCustomer.FirstName_can__c == null) {
                errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.HCP_CUSTOMER_FIRST_NAME_IS_NULL);
            }
            
            if(stgCustomer.LastName_can__c == null) {
                errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.HCP_CUSTOMER_LAST_NAME_IS_NULL);
            }
        } else {
            if(stgCustomer.Org_Name_can__c == null) {
                errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.HCO_CUSTOMER_NAME_IS_NULL);
            }
        }
        
        if(stgCustomer.Acount_Type_can__c == null) {
            errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.CUSTOMER_TYPE_IS_NULL);
        }
        
        if(sfdcAccount!=null && sfdcAccount.RecordTypeId!=null && sfdcAccount.RecordTypeId!=getRecordTypeIdFromStagingObject(stgCustomer,sfdcAccount)) {
        	
            errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.CANNOT_CHANGE_RECORD_TYPE);
        }
        
        if(!errorMsgs.isEmpty()) {
            throw new GNE_CAN_Subscribe_Util.SubscribeException(errorMsgs);
        }
    }
    
    private void validateAddress(Stg_SFA_Cust_Addr_Can__c stgAddress, Address_vod__c sfdcAddress, Stg_SFA_Cust_Can__c stgCustomer, Account sfdcAccount) {
        List<GNE_CAN_Subscribe_Util.KnownException> errorMsgs = new List<GNE_CAN_Subscribe_Util.KnownException>();
        
        if(stgAddress.UAD_Ind_can__c==GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE || 
           stgAddress.UAD_Ind_can__c==GNE_CAN_Subscribe_Util.ADDRESS_UAD_INDICATOR_INACTIVE) {
           	if(sfdcAddress==null) {
           		errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.TARGET_ADDRESS_FOR_UPDATE_NOT_FOUND);
           	} else if(sfdcAddress.Account_vod__c != sfdcAccount.Id) {
            	// Something wrong, existing address is asigned to different Account - report an error
            	errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_ASSIGNED_TO_DIFFERENT_ACCOUNT);
           	}
        } else if(stgAddress.UAD_Ind_can__c==GNE_CAN_Subscribe_Util.UAD_INDICATOR_INSERT) {
        	String addrRocheId = stgAddress.Roche_Addr_Id_can__c.toUpperCase();
        	if(cache.addressesByRocheIdMap.containsKey(addrRocheId)) {
        		errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.TARGET_ADDRESS_WITH_GIVEN_ROCHE_ID_ALREADY_EXISTS);
        	}
        } else {
        	errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_UAD_INDICATOR_NOT_VALID);
        }
        
        if(stgAddress.Address_Line1_can__c == null) {
            errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_NAME_IS_NULL);
        }
        
        if(stgAddress.City_can__c == null) {
            errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_CITY_IS_NULL);
        }
        
        if(stgAddress.Province_can__c == null) {
            errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_PROVINCE_IS_NULL);
        } else if(!cache.provinceValues.contains(stgAddress.Province_can__c)) {
            errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_PROVINCE_WRONG_VALUE);
        }
        
        Pattern p = Pattern.compile(GNE_CAN_Subscribe_Util.ADDRESS_POSTAL_CODE_REG_EXP);
        if(stgAddress.Postal_Code_can__c != null){
            Matcher matcher = p.matcher(stgAddress.Postal_Code_can__c);
            if(!matcher.matches()) {
                errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_POSTAL_CODE_WRONG_VALUE);
            }
        }else{
        	errorMsgs.add(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_POSTAL_CODE_IS_NULL);
        }
        
        if(!errorMsgs.isEmpty()) {
            throw new GNE_CAN_Subscribe_Util.SubscribeException(errorMsgs);
        }
    }
    
    public GNE_CAN_Subscribe_Metrics executeSubscribe(List<Id> stgCustIds) {
        return executeSubscribe(stgCustIds, null, new GNE_CAN_Subscribe_Metrics());
    }
    
    public GNE_CAN_Subscribe_Metrics executeSubscribe(List<Id> stgCustIds,
            Stg_SFA_Subscribe_Apex_Job__c currentApexJob,
            GNE_CAN_Subscribe_Metrics metrics) {
                
        GNE_CAN_Subscribe_Util.addDebugMessage('Staging Ids in Scope: {' + String.join(stgCustIds, ',') + '}');
                
        this.currentApexJob = currentApexJob;
        this.mainMetrics = metrics;
        
        initCache(new Set<Id>(stgCustIds));
        
        List<Stg_SFA_Cust_Can__c> matchingStgCusts = new List<Stg_SFA_Cust_Can__c>();
        List<Account> accountsToUpsert = processSubscribeForAccounts(matchingStgCusts);
        executeDML(accountsToUpsert, matchingStgCusts);
        
        List<Stg_SFA_Cust_Addr_Can__c> matchingStgAddrs = new List<Stg_SFA_Cust_Addr_Can__c>();
        List<Address_vod__c> addressesToUpsert = processSubscribeForAddresses(matchingStgAddrs);
        executeDML(addressesToUpsert, matchingStgAddrs);
        
        GNE_CAN_Subscribe_Util.addDebugMessage('Staging Customers to Update: ' + cache.stgCustomersToUpdate.size());
        if(!cache.stgCustomersToUpdate.isEmpty()) {
        	executeDML(cache.stgCustomersToUpdate.values(), null);
        }
        
        GNE_CAN_Subscribe_Util.addDebugMessage('Staging Addresses to Update: ' + cache.stgAddressesToUpdate.size());
        if(!cache.stgAddressesToUpdate.isEmpty()) {
        	executeDML(cache.stgAddressesToUpdate.values(), null);
        }
        
        if(!cache.errorsToInsert.isEmpty()) {
            GNE_CAN_Subscribe_Util.addDebugMessage('Number of Errors to be logged: ' + cache.errorsToInsert.size());
            insert cache.errorsToInsert;
        } else {
            GNE_CAN_Subscribe_Util.addDebugMessage('No Errors to be logged.');
        }
        
        return mainMetrics;
    }
    
    private List<Account> processSubscribeForAccounts(List<Stg_SFA_Cust_Can__c> matchingStgCustomers) {
    	List<Account> accountsToUpsert = new List<Account>();
    	
    	for (Stg_SFA_Cust_Can__c stgCustomer : cache.stgCustomersList) {
            Account sfdcAccount = null;
            try {
                GNE_CAN_Subscribe_Util.addDebugMessage('Processing: ' + stgCustomer);
                
                if(stgCustomer.UAD_Ind_can__c == GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE) {
                	sfdcAccount = getSfdcAccountForStgCustomer(stgCustomer);
                	GNE_CAN_Subscribe_Util.addDebugMessage('Matching SFDC Account (Roche id = '+ stgCustomer.Roche_Cust_Id_can__c+ '): ' + sfdcAccount);
                } else if(stgCustomer.UAD_Ind_can__c == GNE_CAN_Subscribe_Util.UAD_INDICATOR_INSERT) {
                	if(GNE_CAN_Subscribe_Util.ACCOUNT_INSERT_MODE) {
                        GNE_CAN_Subscribe_Util.addDebugMessage('Creating new Account (Roche id = '+ stgCustomer.Roche_Cust_Id_can__c+ ')');
                        sfdcAccount = new Account(
                            OwnerId = GNE_CAN_Subscribe_Util.RECORD_OWNER_ID,
                            Roche_Id_can_gne__c = stgCustomer.Roche_Cust_Id_can__c,
                            Prim_IMS_Id_can__c = stgCustomer.Prim_IMS_Id_can__c,
                            UCI_Id_can__c = stgCustomer.UCI_Id_can__c
                        );
                    } else {
                        continue;
                    }
                }
                
                validateAccount(stgCustomer, sfdcAccount);
                    
                // Create a copy of Account - we don't want to update all fields, only those which are changed.
                Account acc = sfdcAccount; 
                if(sfdcAccount.Id!=null) {
                    acc = new Account(
                        Id = sfdcAccount.Id,
                        Roche_Id_can_gne__c = stgCustomer.Roche_Cust_Id_can__c,
                        Prim_IMS_Id_can__c = stgCustomer.Prim_IMS_Id_can__c,
                        UCI_Id_can__c = stgCustomer.UCI_Id_can__c
                    );
                }
                
                if(updateSfdcAccountFields(stgCustomer, sfdcAccount, acc)) {
                    GNE_CAN_Subscribe_Util.addDebugMessage('Account fields changed (' + String.join(
                                                                        new List<String>{'Roche id = '+ stgCustomer.Roche_Cust_Id_can__c,
                                                                            'Account Id = ' + sfdcAccount.Id}, ', ') + ') => ' + acc);
                    accountsToUpsert.add(acc);
                    matchingStgCustomers.add(stgCustomer);
                } else {
                    GNE_CAN_Subscribe_Util.addDebugMessage('No change to Account fields (' + String.join(
                                                                        new List<String>{'Roche id = '+ stgCustomer.Roche_Cust_Id_can__c,
                                                                            'Account Id = ' + sfdcAccount.Id}, ', ') + ')');
                    updateStagingRecord(acc, stgCustomer, true);
                }
            } catch(GNE_CAN_Subscribe_Util.SubscribeException ex) {
            	reportException(ex, stgCustomer, stgCustomer);
                updateStagingRecord(sfdcAccount, stgCustomer, false);
            } catch(Exception ex) {
                reportException(ex, stgCustomer, stgCustomer);
                updateStagingRecord(sfdcAccount, stgCustomer, false);
            }
        }
        GNE_CAN_Subscribe_Util.addDebugMessage('Accounts to upsert: ' + accountsToUpsert.size());
        
        return accountsToUpsert;
    }
    
    private List<Address_vod__c> processSubscribeForAddresses(List<Stg_SFA_Cust_Addr_Can__c> matchingStgAddrs) {
    	List<Address_vod__c> addressesToUpsert = new List<Address_vod__c>();
         
        for (Stg_SFA_Cust_Can__c stgCustomer : cache.stgCustomersList) {
            if(cache.stgCustomersToUpdate.containsKey(stgCustomer.Id) 
                && cache.stgCustomersToUpdate.get(stgCustomer.Id).Subscribe_Status_can__c <> GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_SUCCESS) {
                continue;       
            }
            
            try {
                Account sfdcAccount = getSfdcAccountForStgCustomer(stgCustomer);
                
                GNE_CAN_Subscribe_Util.addDebugMessage('Matching Account after upsert (Roche id = '+ stgCustomer.Roche_Cust_Id_can__c+ '): ' + sfdcAccount);
                
                if(sfdcAccount == null) {
                    // It means that account did not pass the validation or wasn't created for some reason.
                    // Do not subscribe this address.
                    continue;
                }
                
                for(Stg_SFA_Cust_Addr_Can__c stgAddress : stgCustomer.Stg_SFA_Cust_ref_can__r) {
                    Address_vod__c sfdcAddress = null;
                    try {
                        GNE_CAN_Subscribe_Util.addDebugMessage('Processing Staging Address (' + String.join(
                                                                        new List<String>{'Roche id = '+ stgCustomer.Roche_Cust_Id_can__c,
                                                                            'Account Id = ' + sfdcAccount.Id}, ', ') + 
                                                                    '): ' + stgAddress);
                        if(stgAddress.UAD_Ind_can__c == GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE ||
                           stgAddress.UAD_Ind_can__c == GNE_CAN_Subscribe_Util.ADDRESS_UAD_INDICATOR_INACTIVE) {
                           	
                			sfdcAddress = getSfdcAddressForStgAddress(stgAddress);
                			GNE_CAN_Subscribe_Util.addDebugMessage('Matching SFDC Address (' + String.join(
                                                                        new List<String>{'Roche id = '+ stgCustomer.Roche_Cust_Id_can__c,
                                                                            'Account Id = ' + sfdcAccount.Id,
                                                                            'Roche_Addr_Id_can__c = ' + stgAddress.Roche_Addr_Id_can__c}, ', ') + 
                                                                    '): ' + sfdcAddress);
                		} else if(stgAddress.UAD_Ind_can__c == GNE_CAN_Subscribe_Util.UAD_INDICATOR_INSERT) {
                			if(GNE_CAN_Subscribe_Util.ADDRESS_INSERT_MODE) {
                                GNE_CAN_Subscribe_Util.addDebugMessage('Creating new Address (' + String.join(
                                                                            new List<String>{'Roche id = '+ stgCustomer.Roche_Cust_Id_can__c,
                                                                                'Account Id = ' + sfdcAccount.Id,
                                                                                'Roche_Addr_Id_can__c = ' + stgAddress.Roche_Addr_Id_can__c}, ', ') + ')');
                                sfdcAddress = new Address_vod__c(Account_vod__c = sfdcAccount.Id,
                                                                 Roche_Address_Id_can__c = stgAddress.Roche_Addr_Id_can__c);
                            } else {
                                continue;
                            }
                		}
                                                            
                        // Validate address. If something wrong, this method can throw Subscribe_Exception.
                        validateAddress(stgAddress, sfdcAddress, stgCustomer, sfdcAccount);
                        
                        // Create a copy of Address - we don't want to update all fields. 
                        // Method updateSfdcAddressFields() will set only those which are changed.
                        Address_vod__c addr = sfdcAddress; 
                        
                        if(sfdcAddress.Id!=null) {
                            addr = new Address_vod__c(Id = sfdcAddress.Id,
                                                      Roche_Address_Id_can__c = stgAddress.Roche_Addr_Id_can__c);
                        }
                                
                        if(updateSfdcAddressFields(stgAddress, sfdcAddress, addr)) {
                            GNE_CAN_Subscribe_Util.addDebugMessage('Address fields changed (' + String.join(
                                                                    new List<String>{'Roche id = '+ stgCustomer.Roche_Cust_Id_can__c,
                                                                        'Account Id = ' + sfdcAccount.Id,
                                                                        'Roche_Addr_Id_can__c = ' + stgAddress.Roche_Addr_Id_can__c,
                                                                        'Address Id = ' + sfdcAddress.Id}, ', ') + ') => ' + addr);
                            addressesToUpsert.add(addr);
                            matchingStgAddrs.add(stgAddress);
                        } else {
                            GNE_CAN_Subscribe_Util.addDebugMessage('No change to Address fields (' + String.join(
                                                                    new List<String>{'Roche id = '+ stgCustomer.Roche_Cust_Id_can__c,
                                                                        'Account Id = ' + sfdcAccount.Id,
                                                                        'Roche_Addr_Id_can__c = ' + stgAddress.Roche_Addr_Id_can__c,
                                                                        'Address Id = ' + sfdcAddress.Id}, ', ') + ')');
                            updateStagingRecord(addr, stgAddress, true);
                        }
                    } catch(GNE_CAN_Subscribe_Util.SubscribeException ex) {
                    	reportException(ex, stgAddress, stgAddress);
                        updateStagingRecord(sfdcAddress, stgAddress, false);
                    } catch(Exception ex) {
                        reportException(ex, stgAddress, stgAddress);
                        updateStagingRecord(sfdcAddress, stgAddress, false);
                    }
                }
            } catch(Exception ex) {
                reportException(ex, stgCustomer, stgCustomer);
            }
        }
        
        GNE_CAN_Subscribe_Util.addDebugMessage('Addresses to upsert: ' + addressesToUpsert.size());
        
        return addressesToUpsert;
    }

}