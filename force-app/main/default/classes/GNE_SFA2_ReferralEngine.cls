public virtual class GNE_SFA2_ReferralEngine implements 
        GNE_SFA2_S2S_Interface.RestServiceCallInterface, 
        GNE_SFA2_S2S_Interface.RestServiceExecuteInterface,
        GNE_SFA2_S2S_Interface.EngineListenerInterface {
    public GNE_SFA2_ReferralEngine() {}
    
    public virtual System.Type getSelfClass() {
        return GNE_SFA2_ReferralEngine.class;
    }
    
    public void onRestEngineStart(GNE_SFA2_S2S_Interface.EngineInterface engine) {}
    
    public void onRestEngineFinish(GNE_SFA2_S2S_Interface.EngineInterface engine) {
        if(engine.getFeatureName()==GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_CREATE) {
            validateReferralCreateResponse(engine.getResponse());
            
            if(engine.getResponse().isSuccess()) {
                GNE_SFA2_ReferralUtil.ReferralWrapper referral = (GNE_SFA2_ReferralUtil.ReferralWrapper)engine.getRequest().getRecords()[0];
                GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper resReferral = (GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper)engine.getResponse().getRecords()[0];
            
                updateReferralFromExternalSystem(referral.getLocalId(), resReferral.getLocalId(), resReferral, engine.getRequest().getActor());
            }
        } else if(engine.getFeatureName()==GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_ASSIGNEE_CHECK) {
            validateCheckModeResponse(engine.getResponse());
        }
    }
    
    public void executeRestMethod(GNE_SFA2_S2S_Interface.EngineInterface engine) {
        if(engine.getFeatureName()==GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_UPDATE) {
            validateReferralUpdateRequest(engine.getRequest());
            
            for(GNE_SFA2_S2S_Interface.RecordInterface record : engine.getRequest().getRecords()) {
                GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper referral = (GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper)record;
                updateReferralFromExternalSystem(referral.getExtId(), referral.getLocalId(), referral, engine.getRequest().getActor());
            }
        }
    }
    
    public virtual GNE_SFA2_ReferralUtil.UserWrapper checkAutoAssignment(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        GNE_SFA2_ReferralUtil.UserWrapper autoAssignee = null;
        if(GNE_SFA2_S2S_Util.isFeatureEnabled(GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_CREATE) && referral!=null && (referral.getAssignee()==null || !referral.getAssignee().fetchWithLocalUser())) {
            try {
	            validateReferral(referral);
		        fetchAccountAndAddress(referral);
		        fetchProducts(referral);
		        fetchRequestor(referral);
		        referral.setAutoMode(true);
	            referral.setAutoAssignee(null);
	            referral.setLocalId('assignee_check_' + referral.getRequestor().getAlias() + '_' + DateTime.now().formatGmt('yyyyMMdd_HHmmss'));
	            
	            GNE_SFA2_ReferralUtil.ReferralRequest req = new GNE_SFA2_ReferralUtil.ReferralRequest(new List<GNE_SFA2_ReferralUtil.ReferralWrapper>{referral}, null, true);
	            GNE_SFA2_S2S_Interface.ResponseInterface response = GNE_SFA2_S2S_ServiceEngine.callRestPostMethod(
	                GNE_SFA2_ReferralUtil.EXTERNAL_SYSTEM_NAME, GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_ASSIGNEE_CHECK,
	                this, req, GNE_SFA2_ReferralUtil.ReferralResultWrapper.class);
	            
                if(!response.isSuccess()) {
	                throw new GNE_SFA2_ReferralUtil.AutoAssignmentFailedException(true);
	            }
	            
	            GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper responseRec = (GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper)response.getRecords()[0];
	            autoAssignee = responseRec.getAssignee();
	            referral.setAutoMode(false);
	            referral.setAutoAssignee(autoAssignee);
	            referral.setLocalId(null);
            } catch(GNE_SFA2_ReferralUtil.AutoAssignmentFailedException aafex) {
                throw aafex;
            } catch(Exception ex) {}
        }
        return autoAssignee;
    }
    
    public virtual Medical_Communication_gne__c createReferral(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        Medical_Communication_gne__c medComm = null;
        validateReferral(referral);
        fetchAccountAndAddress(referral);
        fetchProducts(referral);
        fetchRequestor(referral);
        referral.getAssignee().fetchWithLocalUser();
        System.Savepoint sp = Database.setSavepoint();
        
        try {
            if (GNE_SFA2_Util.isCanadaUser()){
                referral.setIsUSARequest(false);
            } else {
            	referral.setIsUSARequest(true);
            }  
            if(GNE_SFA2_S2S_Util.isFeatureEnabled(GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_CREATE)) {
                medComm = intCreateReferral(referral);
                futureNotifyExtSystemOnReferralCreation(JSON.serialize(referral));
            } else {
                medComm = intCreateReferralOldWay(referral);
            } 
        } catch(Exception ex) {
            Database.rollback(sp);
            throw ex;
        }
        
        return medComm;
    }    
    
    public virtual Medical_Communication_gne__c updateReferral(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        Medical_Communication_gne__c medComm = null;
        fetchRequestor(referral);
        System.Savepoint sp = Database.setSavepoint();
        
        try {
            if (GNE_SFA2_Util.isCanadaUser()){
                medComm = intUpsertReferralOldWayCanada(referral);
            }
        } catch(Exception ex) {
            Database.rollback(sp);
            throw ex;
        }
        
        return medComm;
    }
    
    
    protected virtual void validateCheckModeResponse(GNE_SFA2_S2S_Interface.ResponseInterface response) {
        GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper referral;
        
        if(response==null) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_ASSIGNEE_CHECK_MISSING_RESPONSE);
        } else if(response.isSuccess()) {
            if(response.getRecords().isEmpty()) {
                throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_ASSIGNEE_CHECK_MISSING_RESPONSE_RECORD);
            } else if((referral = (GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper)response.getRecords()[0])==null) {
                throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_ASSIGNEE_CHECK_MISSING_RESPONSE_RECORD);
            } else if(referral.getAssignee()==null) {
                throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_ASSIGNEE_CHECK_MISSING_ASSIGNEE);
            } else if(!referral.getAssignee().fetchWithLocalUser()) {
                throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_ASSIGNEE_CHECK_INVALID_ASSIGNEE);
            }
        }
    }
    
    public virtual Medical_Communication_gne__c intCreateReferral(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
    	referral.getAssignee().fetchWithLocalUser();
        Medical_Communication_gne__c medComm = createReferralMedComm(referral);
        createReferralAssignment(medComm, referral);
	    referral.setLocalId(medComm.Id);
	    referral.setExtId(null);
        return medComm;
    }
    
    public virtual Medical_Communication_gne__c intCreateReferralOldWay(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        Medical_Communication_gne__c medComm = null;
        GNE_Med_iPhone_CreateReferral.ReferralInfo refInfo = getReferralWrapperOldWay(referral);
        GNE_Med_iPhone_CreateReferral.Response callResponse = GNE_Med_iPhone_CreateReferral.createReferral(refInfo, false);
        
        if(String.isNotBlank(callResponse.ErrorMessage)) {
            throw new GNE_Med_iPhone_CreateReferral.CreateReferralException(callResponse.ErrorMessage);
        } else {
            medComm = callResponse.getResponseReferral();
            List<Medical_Communication_gne__c> medComms = [
                SELECT Id, iPhone_Request_Id_gne__c, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c
                FROM Medical_Communication_gne__c
                WHERE Id = :medComm.Id];
            medComm = !medComms.isEmpty() ? medComms[0] : null;
        }
        
        return medComm;
    }
    
    public virtual Medical_Communication_gne__c intUpsertReferralOldWayCanada(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        Medical_Communication_gne__c medComm = null;
        GNE_Med_iPhone_CreateReferral.ReferralInfo refInfo = getReferralWrapperOldWay(referral);
        GNE_Med_iPhone_CreateReferral.Response callResponse = GNE_Med_iPhone_CreateReferral.upsertReferralOldWayCanada(refInfo, false);
        
        if(String.isNotBlank(callResponse.ErrorMessage)) {
            throw new GNE_Med_iPhone_CreateReferral.CreateReferralException(callResponse.ErrorMessage);
        } else {
            medComm = callResponse.getResponseReferral();
            List<Medical_Communication_gne__c> medComms = [
                SELECT Id, iPhone_Request_Id_gne__c, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c
                FROM Medical_Communication_gne__c
                WHERE Id = :medComm.Id];
            medComm = !medComms.isEmpty() ? medComms[0] : null;
        }
        
        return medComm;
    }

    protected virtual GNE_Med_iPhone_CreateReferral.ReferralInfo getReferralWrapperOldWay(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        GNE_Med_iPhone_CreateReferral.ReferralInfo refInfo = new GNE_Med_iPhone_CreateReferral.ReferralInfo();
        refInfo.AccountId =referral.getAccount().getLocalId();
        if (referral.getAccount().getAddress() != null) {
        	refInfo.AddressId = referral.getAccount().getAddress().getLocalId();
        }
        refInfo.MedicalQuestion = referral.getReferralData().getQuestion();
        refInfo.FollowupMethod = referral.getReferralData().getFollowUpMethod();
        refInfo.ProductId = referral.getReferralData().getProduct()!=null ? referral.getReferralData().getProduct().getLocalId() : null;
        refInfo.TA_SubTAId = referral.getReferralData().getTA()!=null ? referral.getReferralData().getTA().getLocalId() : null;
        refInfo.MoleculeId = referral.getReferralData().getMolecule()!=null ? referral.getReferralData().getMolecule().getLocalId() : null;
        refInfo.phone = referral.getAccount().getPhone();
        refInfo.RequestedCompletionDate = referral.getReferralData().getReqCompletionDate();
        refInfo.Priority = referral.getReferralData().getPriority();
        refInfo.RequestedById = referral.getRequestor().getLocalId();
        refInfo.UserId = referral.getRequestor().getLocalId();
        refInfo.AssignedToId = referral.getAssignee()!=null ? referral.getAssignee().getLocalId() : null;
        refInfo.isMedComm = false;
        refInfo.RevisedCompletionDate = referral.getReferralData().getRevCompletionDate();
        refInfo.Status = referral.getReferralData().getStatus();
        refInfo.Comment = referral.getReferralData().getComment();
        refInfo.RecordId = referral.getsfaId();
        refInfo.isOtrRequest = referral.getIsOtrRequest();
        refInfo.Language = referral.getReferralData().getLanguage();

        return refInfo;
    }
    
    protected virtual void validateReferral(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        List<String> errorCodes = new List<String>();
        
        if(referral.getAccount()==null) {
            errorCodes.add(GNE_SFA2_ReferralUtil.ERROR_CODE_ACCOUNT_IS_MISSING);
        } else if(referral.getAccount().getAddress()==null) {
            errorCodes.add(GNE_SFA2_ReferralUtil.ERROR_CODE_ADDRESS_IS_MISSING);
        }
        
        if(referral.getReferralData()==null || String.isBlank(referral.getReferralData().getPriority())) {
            errorCodes.add(GNE_SFA2_ReferralUtil.ERROR_CODE_PRIORITY_IS_MISSING);
        }
        
        if(referral.getReferralData()==null || String.isBlank(referral.getReferralData().getQuestion())) {
            errorCodes.add(GNE_SFA2_ReferralUtil.ERROR_CODE_QUESTION_IS_MISSING);
        }
        
        if(referral.getReferralData()==null || String.isBlank(referral.getReferralData().getFollowUpMethod())) {
            errorCodes.add(GNE_SFA2_ReferralUtil.ERROR_CODE_FOLLOWUPMETHOD_IS_MISSING);
        }
        
        if(referral.getReferralData()==null || String.isBlank(referral.getReferralData().getFollowUpMethod())) {
            errorCodes.add(GNE_SFA2_ReferralUtil.ERROR_CODE_FOLLOWUPMETHOD_IS_MISSING);
        }
        
        if (!GNE_SFA2_Util.isCanadaUser()) {
	        if(referral.getReferralData()==null || referral.getReferralData().getTA()==null || String.isBlank(referral.getReferralData().getTA().getLocalId())) {
	            errorCodes.add(GNE_SFA2_ReferralUtil.ERROR_CODE_TA_IS_MISSING);
	        }
        }
        
        if(!errorCodes.isEmpty()) {
            throw new GNE_SFA2_ReferralUtil.InvalidReferralException(errorCodes);
        }
    }
    
    protected virtual void fetchAccountAndAddress(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        if(!referral.isAccountAndAddressFetched()) {
	        GNE_SFA2_ReferralUtil.AccountWrapper accWrapper = referral.getAccount();
	        
	        if(accWrapper!=null && String.isNotBlank(accWrapper.getLocalId())) {
	            Set<Id> ids = new Set<Id>{(Id)accWrapper.getLocalId()};
	            GNE_SFA2_S2S_Interface.AddressInterface addrWrapper = accWrapper.getAddress();
	            
	            if(addrWrapper!=null && String.isNotBlank(addrWrapper.getLocalId())) {
	                ids.add((Id)addrWrapper.getLocalId());
	                Map<Id,Id> winnerIdsMap = CORE_Merge_Util.getWinnerIdsMap(ids);
	                
	                accWrapper.setLocalId(winnerIdsMap.get((Id)accWrapper.getLocalId()));
	                addrWrapper.setLocalId(winnerIdsMap.get((Id)addrWrapper.getLocalId()));
	                
	                List<Account> accs = GNE_SFA2_S2S_Util.getAccountRecords(new Set<Id>{(Id)accWrapper.getLocalId()}, new Set<Id>{(Id)addrWrapper.getLocalId()});
	                
	                for(Account acc : accs) {
	                    referral.setAccount(new GNE_SFA2_ReferralUtil.AccountWrapper(acc, !acc.Address_vod__r.isEmpty() ? acc.Address_vod__r[0] : null, accWrapper.getPhone()));
	                }  
	            }
	        }
	        
	        referral.setAccountAndAddressFetched(true);
        }
    }
    
    protected virtual void fetchProducts(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        if(!referral.isProductsFetched()) {
	        GNE_SFA2_ReferralUtil.ReferralDataWrapper refData = referral.getReferralData();
	        Map<Id,GNE_SFA2_ReferralUtil.ProductWrapper> prodsMap = new Map<Id,GNE_SFA2_ReferralUtil.ProductWrapper>();
	        
	        if(refData!=null && refData.getProduct()!=null && String.isNotBlank(refData.getProduct().getLocalId())) {
	            prodsMap.put((Id)refData.getProduct().getLocalId(), refData.getProduct());
	        }
	        
	        if(refData!=null && refData.getTA()!=null && String.isNotBlank(refData.getTA().getLocalId())) {
	            if(refData.getTA().getLocalId() instanceof Id) {
	               prodsMap.put((Id)refData.getTA().getLocalId(), refData.getTA());
	            } else {
	               refData.getTA().setName(refData.getTA().getLocalId());
	            }
	        }
	        
	        if(refData!=null && refData.getMolecule()!=null && String.isNotBlank(refData.getMolecule().getLocalId())) {
	            prodsMap.put((Id)refData.getMolecule().getLocalId(), refData.getMolecule());
	        }
	        
	        if(!prodsMap.isEmpty()) {
	            for(Product_vod__c prodRec : (new iPhoneBase.WithoutSharingQueryExecutor()).getProducts(prodsMap.keySet())) {
	                GNE_SFA2_ReferralUtil.ProductWrapper prod = prodsMap.get(prodRec.Id);
	                prod.setName(GNE_SFA2_ReferralUtil.getProductName(prodRec));
	            }
	        }
	        
	        referral.setProductsFetched(true);
        }
    }
    
    protected virtual void fetchRequestor(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        if(!referral.isRequestorFetched()) {
	        GNE_SFA2_ReferralUtil.UserWrapper requestor = referral.getRequestor()!=null && referral.getRequestor().fetchWithLocalUser() ? referral.getRequestor() : null;
	        
	        if(requestor==null) {
	            requestor = new GNE_SFA2_ReferralUtil.UserWrapper(UserInfo.getUserId());
	            requestor.fetchWithLocalUser();
	            referral.setRequestor(requestor);
	        }
	        
	        referral.setRequestorFetched(true);
        }
    }
    
    protected virtual Medical_Communication_gne__c createReferralMedComm(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        Medical_Communication_gne__c medComm = intCreateReferralMedComm(referral);
        Database.insert(medComm);
        return medComm;
    }

    protected virtual Medical_Communication_gne__c intCreateReferralMedComm(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {  
        //GNE_Referral_Utils.isMedicalReferral = true;
        GNE_SFA2_ReferralUtil.AccountWrapper acc = referral.getAccount();
        GNE_SFA2_S2S_Interface.AddressInterface addr = acc.getAddress();
        GNE_SFA2_ReferralUtil.ReferralDataWrapper refData = referral.getReferralData();
        GNE_SFA2_ReferralUtil.UserWrapper requestor = referral.getRequestor();
        
        Medical_Communication_gne__c medComm = new Medical_Communication_gne__c(
            iPhone_Request_Id_gne__c = referral.getExtId(),
            RecordTypeId = GNE_SFA2_ReferralUtil.getReferralRecordType(),
            Account_gne__c = acc.getLocalId(),
            Account_Referral_gne__c = acc.getLocalId(),
            
            Address_Line_1_gne__c=addr.getName(),
            Address_Line_2_gne__c=addr.getSuite(),
            City_gne__c=addr.getCity(),
            State_gne__c=addr.getState(),
            Zip_gne__c=addr.getZip()!=null ? addr.getZip().left(5) : null,
            Zip_4_gne__c=addr.getZip4(),
            Country_gne__c=addr.getCountry(),
            
            Email_gne__c=acc.getEmail(),
            Phone_gne__c=acc.getPhone(),
            Phone_1_gne__c=acc.getMobilePhone(),
            Fax_gne__c=acc.getFax(),
            
            Priority_gne__c = refData.getPriority(),
            Medical_Question_gne__c = refData.getQuestion(),
            Follow_up_Method_gne__c = refData.getFollowUpMethod(),
            Product_gne__c = refData.getProduct()!=null ? refData.getProduct().getLocalId() : null,
            Is_MedComm_gne__c = false,
            Requested_By_gne__c = referral.getRequestor().getLocalId(),
            Referral_Source_gne__c = GNE_SFA2_ReferralUtil.getReferralSource(referral.getRequestor()),
            Requested_Completion_Date_gne__c = refData.getReqCompletionDate()
        );
		if (!GNE_SFA2_Util.isCanadaUser()){		        
        	medComm.TA_SubTA_gne__c = refData.getTA().getLocalId() instanceof Id ? refData.getTA().getLocalId() : null;
        	medComm.TA_gne__c = !(refData.getTA().getLocalId() instanceof Id) ? refData.getTA().getLocalId() : null;
        	medComm.Molecule_gne__c = refData.getMolecule()!=null ? refData.getMolecule().getLocalId() : null;
		} else {
			medComm.TA_SubTA_gne__c = null;
			medComm.TA_gne__c = null;
			medComm.Molecule_gne__c = null;
		}
        
        refData.setSource(medComm.Referral_Source_gne__c);

        return medComm;
    }
    
    protected virtual Referral_Assignment_gne__c createReferralAssignment(Medical_Communication_gne__c medComm, GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        Referral_Assignment_gne__c refAssignment = intCreateReferralAssignment(medComm, referral);
        Database.insert(refAssignment);
        medComm.Referral_Assignment_gne__c = refAssignment.Id;
        medComm.Referral_Assignment_gne__r = refAssignment;
        Database.update(medComm);
        return refAssignment;
    }
    
    protected virtual Referral_Assignment_gne__c intCreateReferralAssignment(Medical_Communication_gne__c medComm, GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        GNE_SFA2_ReferralUtil.UserWrapper assignee = referral.getAssignee(); 
        Referral_Assignment_gne__c refAssignment = new Referral_Assignment_gne__c(
            Medical_Request_gne__c = medComm.Id,
            OwnerId = referral.getRequestor().getLocalId(),
            Assigned_To_gne__c = assignee!=null ? assignee.getLocalId() : null,
            Referral_Assigned_User_Email_gne__c = assignee!=null ? assignee.getEmail() : null,
            Status_Referral_gne__c = assignee!=null ? GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ASSIGNED : GNE_SFA2_ReferralUtil.REFERRAL_STATUS_UNASSIGNED,
            Status_Referral_Date_gne__c = DateTime.now()
        );
        
        List<GNE_SFA2_ReferralUtil.ActionWrapper> actions = new List<GNE_SFA2_ReferralUtil.ActionWrapper>{
            new GNE_SFA2_ReferralUtil.ActionWrapper(DateTime.now(), GNE_SFA2_ReferralUtil.REFERRAL_WORKFLOW_ACTION_CREATED, referral.getRequestor(), assignee, refAssignment.Status_Referral_gne__c)
        };
        
        medComm.Referral_History_gne__c = JSON.serialize(actions);
        return refAssignment;
    }
    
    @future(callout=true)
    public static void futureNotifyExtSystemOnReferralCreation(String referralAsJSON) {
        (new GNE_SFA2_ReferralEngine()).notifyExtSystemOnReferralCreation((GNE_SFA2_ReferralUtil.ReferralWrapper)JSON.deserialize(referralAsJSON, GNE_SFA2_ReferralUtil.ReferralWrapper.class));
    }
    
    protected virtual void notifyExtSystemOnReferralCreation(GNE_SFA2_ReferralUtil.ReferralWrapper referral) {
        referral.getLocalId();
        List<Medical_Communication_gne__c> mComms = [SELECT Id, Name, Referral_Assignment_gne__r.Name FROM Medical_Communication_gne__c WHERE Id = :referral.getLocalId()];
        
        if(!mComms.isEmpty()) {
            referral.setName(mComms[0].Referral_Assignment_gne__r.Name);
            referral.setMedCommName(mComms[0].Name);
            GNE_SFA2_ReferralUtil.ReferralRequest req = new GNE_SFA2_ReferralUtil.ReferralRequest(new List<GNE_SFA2_ReferralUtil.ReferralWrapper>{referral}, null, true);
	        GNE_SFA2_ReferralUtil.ReferralResultWrapper response = (GNE_SFA2_ReferralUtil.ReferralResultWrapper)GNE_SFA2_S2S_ServiceEngine.callRestPostMethod(
                GNE_SFA2_ReferralUtil.EXTERNAL_SYSTEM_NAME, GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_CREATE,
                this, req, GNE_SFA2_ReferralUtil.ReferralResultWrapper.class);
        }
    }
    
    private void validateReferralCreateResponse(GNE_SFA2_S2S_Interface.ResponseInterface response) {
        GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper referral;
        
        if(response==null) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_CREATE_MISSING_RESPONSE);
        } else if(response.isSuccess()) {
            if(response.getRecords().isEmpty()) {
                throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_CREATE_MISSING_RESPONSE_RECORD);
            } else if((referral = (GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper)response.getRecords()[0])==null) {
                throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_UPDATE_MISSING_RECORD);
            } else if(String.isBlank(referral.getLocalId()) || String.isBlank(referral.getExtId())) {
                throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_MISSING_RECORD_IDS);
            } else if(referral.getAssignee()!=null && !referral.getAssignee().fetchWithLocalUser()) {
                throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_INVALID_ASSIGNEE);
            }
        }
    }
    
    private void validateReferralUpdateRequest(GNE_SFA2_S2S_Interface.RequestInterface request) {
        GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper referral;
        
        if(!GNE_SFA2_S2S_Util.isFeatureEnabled(GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_UPDATE)) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_UPDATE_DISABLED_FEATURE);
        } else if(request==null) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_UPDATE_MISSING_REQUEST);
        } else if(request.getRecords().isEmpty()) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_UPDATE_MISSING_RECORD);
        } else if(request.getRecords().size()>1) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_UPDATE_BULK_NOT_SUPPORTED);
        } else if((referral = (GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper)request.getRecords()[0])==null) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_UPDATE_MISSING_RECORD);
        } else if(String.isBlank(referral.getLocalId()) || String.isBlank(referral.getExtId())) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_MISSING_RECORD_IDS);
        } else if(referral.getAssignee()!=null && !referral.getAssignee().fetchWithLocalUser()) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_INVALID_ASSIGNEE);
        }
    }
    
    protected virtual void updateReferralFromExternalSystem(String medCommLocalId, String medCommExtId, GNE_SFA2_ReferralUtil.ReferralUpdateDataWrapper referral, GNE_SFA2_S2S_Interface.ActorInterface actor) {
        List<Medical_Communication_gne__c> medComms = String.isNotBlank(medCommLocalId) ? [
            SELECT Id, MA_Id__c, Unsolicited_Request_Verified_gne__c, Referral_History_gne__c,
                Referral_Assignment_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c, Referral_Assignment_gne__r.Status_Referral_gne__c,
                Referral_Assignment_gne__r.Revised_Requested_Completion_Date_gne__c 
            FROM Medical_Communication_gne__c
            WHERE Id = :medCommLocalId
        ] : null;
        
        medComms = medComms!=null && !medComms.isEmpty() ? medComms 
            : String.isNotBlank(medCommExtId) ? [
	            SELECT Id, MA_Id__c, Unsolicited_Request_Verified_gne__c, Referral_History_gne__c,
	               Referral_Assignment_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c, Referral_Assignment_gne__r.Status_Referral_gne__c,
	               Referral_Assignment_gne__r.Revised_Requested_Completion_Date_gne__c
	            FROM Medical_Communication_gne__c
	            WHERE MA_Id__c = :medCommExtId
	        ] : null;
	    
	    Medical_Communication_gne__c medComm = medComms!=null && !medComms.isEmpty() ? medComms[0] : null;
        
        if(medComm==null || medComm.Referral_Assignment_gne__r==null) {
            throw GNE_SFA2_S2S_Util.createException(GNE_SFA2_ReferralUtil.S2S_ERROR_CODE_MISSING_LOCAL_RECORD);
        } else {
            Boolean medCommChanged = false;
            Boolean refAssignmentChanged = false;
            Referral_Assignment_gne__c refAssign = medComm.Referral_Assignment_gne__r;
            Medical_Communication_gne__c medCommToUpdate = new Medical_Communication_gne__c(Id = medComm.Id);
            Referral_Assignment_gne__c refAssignToUpdate = new Referral_Assignment_gne__c(Id = medComm.Referral_Assignment_gne__c);
            GNE_SFA2_ReferralUtil.UserWrapper newAssignee = referral.getAssignee();
            GNE_SFA2_ReferralUtil.UserWrapper newAssigneeManager = newAssignee!=null && newAssignee.getManager()!=null && newAssignee.getManager().fetchWithLocalUser() ? newAssignee.getManager() : null;
            
            if(String.isNotBlank(medCommExtId) && medComm.MA_Id__c!=medCommExtId) {
                medCommToUpdate.MA_Id__c=medCommExtId;
                medCommChanged = true;
            }
            
            List<GNE_SFA2_ReferralUtil.ActionWrapper> actions = GNE_SFA2_ReferralUtil.getReferralHistoryActions(medComm.Referral_History_gne__c);
            Integer prevActionSize = actions.size();
            DateTime lastActionDt = actions.size()>1 ? actions[actions.size()-1].getCreatedDate() : null;
            DateTime nowDt = referral.getActionDate();
            // make sure that current update request is the latest one
            Boolean canUpdateReferral = nowDt==null || lastActionDt==null || lastActionDt<=nowDt;
            nowDt = nowDt!=null ? nowDt : DateTime.now();
            
            GNE_SFA2_ReferralUtil.UserWrapper prevAssignee = new GNE_SFA2_ReferralUtil.UserWrapper(refAssign.Assigned_To_gne__c);
            prevAssignee.fetchWithLocalUser();
            GNE_SFA2_ReferralUtil.UserWrapper actionActor = actor!=null && actor.fetchWithLocalUser() ? new GNE_SFA2_ReferralUtil.UserWrapper(actor) : prevAssignee;
            GNE_SFA2_ReferralUtil.UserWrapper actionAssignee = newAssignee!=null ? newAssignee : prevAssignee;
            String actionStatus = String.isNotBlank(referral.getStatus()) ? referral.getStatus() : refAssign.Status_Referral_gne__c;
            
            
            if(referral.getUnsolicitedRequestData()!=null && referral.getUnsolicitedRequestData().getVerified()==true && !medComm.Unsolicited_Request_Verified_gne__c) {
                GNE_SFA2_ReferralUtil.UnsolicitedRequestWrapper urData = referral.getUnsolicitedRequestData();
                GNE_SFA2_ReferralUtil.UserWrapper verifiedBy = urData.getVerifiedBy();
                verifiedBy = verifiedBy!=null && verifiedBy.fetchWithLocalUser() ? verifiedBy : null;
                actions.add(new GNE_SFA2_ReferralUtil.ActionWrapper(nowDt, GNE_SFA2_ReferralUtil.REFERRAL_WORKFLOW_ACTION_REQUEST_VERIFIED, actionActor, actionAssignee, actionStatus));
                
                if(canUpdateReferral) {
                    medCommToUpdate.Unsolicited_Request_Verified_gne__c = urData.getVerified();
                    medCommToUpdate.Unsolicited_Request_Verified_Date_gne__c = urData.getVerifiedDate()!=null ? urData.getVerifiedDate() : System.today();
                    medCommToUpdate.Unsolicited_Request_Verified_By_gne__c = verifiedBy!=null ? verifiedBy.getLocalId() : null;
                    medCommChanged = true;
                }
            }
            
            if(referral.getRevisedCompletionDate()!=null && referral.getRevisedCompletionDate()!=refAssign.Revised_Requested_Completion_Date_gne__c) {
                refAssignToUpdate.Revised_Requested_Completion_Date_gne__c = referral.getRevisedCompletionDate();
                actions.add(new GNE_SFA2_ReferralUtil.ActionWrapper(nowDt, GNE_SFA2_ReferralUtil.REFERRAL_WORKFLOW_ACTION_CREATION_DATE_UPDATE, actionActor, actionAssignee, actionStatus)); 
                refAssignmentChanged = true;
            }
            
            if(canUpdateReferral && newAssignee!=null && newAssignee.getLocalId()!=prevAssignee.getLocalId()) {
                refAssignToUpdate.Assigned_To_gne__c = newAssignee.getLocalId();
                refAssignToUpdate.Referral_Assigned_User_Email_gne__c = newAssignee.getEmail();
                refAssignToUpdate.Assigned_To_Manager_gne__c = newAssigneeManager!=null ? newAssigneeManager.getLocalId() : null;
                refAssignToUpdate.Referral_Assigned_Manager_Email_gne__c = newAssigneeManager!=null ? newAssigneeManager.getEmail() : null;
                actions.add(new GNE_SFA2_ReferralUtil.ActionWrapper(nowDt, GNE_SFA2_ReferralUtil.REFERRAL_WORKFLOW_ACTION_REASSIGNED, actionActor, actionAssignee, actionStatus));
                refAssignmentChanged = true;
            }
            
            if(String.isNotBlank(referral.getStatus()) && refAssign.Status_Referral_gne__c!=referral.getStatus()) {
                refAssignToUpdate.Status_Referral_gne__c = actionStatus = referral.getStatus();
                refAssignToUpdate.Status_Referral_Date_gne__c = DateTime.now();
                refAssignToUpdate.Status_Email_gne__c = String.format('{0} - {1}', new String[]{GNE_SFA2_ReferralUtil.REFERRAL_EMAIL_STATUS_PREFIX, refAssign.Status_Referral_gne__c});
                refAssignToUpdate.Status_Email_Date_gne__c = DateTime.now();
                actions.add(new GNE_SFA2_ReferralUtil.ActionWrapper(nowDt, GNE_SFA2_ReferralUtil.REFERRAL_WORKFLOW_ACTION_STATUS_UPDATE, actionActor, actionAssignee, actionStatus));
                refAssignmentChanged = true;
            }
            
            if(prevActionSize!=actions.size()) {
                actions.sort();
                medCommToUpdate.Referral_History_gne__c = JSON.serialize(actions);
                medCommChanged = true; 
            }
            
            List<SObject> recsToUpdate = new List<SObject>();
            
            if(medCommChanged) {
                recsToUpdate.add(medCommToUpdate);
            }
            
            if(canUpdateReferral && refAssignmentChanged) {
                recsToUpdate.add(refAssignToUpdate);
            }
            
            if(!recsToUpdate.isEmpty()) {
                Database.update(recsToUpdate);
            }
        }
    }
}