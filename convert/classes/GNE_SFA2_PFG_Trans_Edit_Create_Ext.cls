public with sharing class GNE_SFA2_PFG_Trans_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create{
    public List<TransactionWrapper> transactions {get; private set;}
    public Map<Integer,TransactionWrapper> transactionsMap {get; set;}
    public String distributionMethod {get; private set;}
    public String recordTypeVisName {get; private set;}
    public Boolean isPfgInformationEnabled {
        get {
            Set<String> validRecTypes = new Set<String> {
                GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN,
                GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT,
                GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RECEIPT,
                GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER,
                GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER,
                GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER
            };
            return validRecTypes.contains(recordTypeVisName);
        }
    }
    public List<Territory2> hoDummyTerritory {get; private set;}

    public String productId {get; set;}
    public Boolean productIsSeleted {get; set;}
    public String lotId {get; set;}
    public String vendorId {get; set;}
    public String customRecId {get; set;}
    public String fieldName {get; set;}
    public String rowIdx {get; set;}

    private Id recordTypeId;
    @TestVisible private SFA2_PFG_Transaction_gne__c mainTrx;
    private SFA2_PFG_Transaction_gne__c callDetailTrx;
    private Id currentUserId;
    private Boolean isCs;
    private Boolean includeZeroPfg2UserDetails;

    public GNE_SFA2_PFG_Trans_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PFG_Trans_CreateEdit_Layout');
    }

    protected override void initController(ApexPages.StandardController controller){
        currentUserId = UserInfo.getUserId();
        isCs = GNE_SFA2_PFG_Util.checkIsUserCS(currentUserId);

        String trxType = ApexPages.currentPage().getParameters().get('transactionType');
        if(controller.getRecord().Id == null && trxType != null){
            RecordType rt = [Select Id, Name from RecordType where Name = :trxType limit 1];
            recordTypeId = rt.Id;
            recordTypeVisName = rt.Name;
            myObject = new SFA2_PFG_Transaction_gne__c(RecordTypeId = recordTypeId);
        }

        super.initController(controller);

        includeZeroPfg2UserDetails =
                recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT ||
                recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER;
    }

    public override PageReference init() {
        productIsSeleted = false;
        PageReference result = null;

        if(availabilityMode == 'New') {
            mainTrx = (SFA2_PFG_Transaction_gne__c)myObject;
            distributionMethod = distributionMethodOnCreate();
        } else {
            for (SFA2_PFG_Transaction_gne__c trx : GNE_SFA2_PFG_DAO.getTransactionById(myObject.Id)) {
                mainTrx = trx;
                productIsSeleted = trx.Product_gne__c!=null;
                distributionMethod = trx.Distribution_Method_gne__c;
            }

            RecordType rt = [Select Id, Name from RecordType where Id = :mainTrx.RecordTypeId limit 1];
            recordTypeId = rt.Id;
            recordTypeVisName = rt.Name;

            result = super.init();

        }

        result = super.init();
        myObject = mainTrx;

        TransactionWrapper trxWrapper = new TransactionWrapper(0,(SFA2_PFG_Transaction_gne__c)myObject);
        transactions = new List<TransactionWrapper>{trxWrapper};
        transactionsMap = new Map<Integer,TransactionWrapper>{0 => trxWrapper};

        setDefaultFieldValues();

        // Display short info after last request submitted action.
        if(recordTypeVisName==GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER) {
            String requestSubmitted = ApexPages.currentPage().getParameters().get('requestSubmitted');
            if(requestSubmitted=='1') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your request has been submitted for approval.'));
            }
        }

        return result;
    }

    public String getPfgActiveMenuItem() {
        return GNE_SFA2_PFG_Base_Controller.MY_PFG_PAGE_NAME;
    }

    private void setDefaultFieldValues() {
        SFA2_PFG_Transaction_gne__c trx = (SFA2_PFG_Transaction_gne__c)myObject;

        if(availabilityMode == 'Edit') {
            if((recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER ||
                recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER ||
                recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER) &&
               (trx.Received_Quantity_gne__c==null || trx.Received_Quantity_gne__c==0.0)) {

                trx.Received_Quantity_gne__c = trx.Requested_Quantity_gne__c;
            }
        } else {
            trx.Transaction_Date_gne__c = Date.today();

            if(recordTypeVisName==GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER) {
                // populate To User and address information
                customRecId = currentUserId;
                fieldName = 'To_User_gne__c';
                intUserLookupFieldActionMethod();
                populateFieldsOnFromUserChange(currentUserId);
                // make sure To User is set correctly to current user
                trx.To_User_gne__c = currentUserId;
            } else {
                if(isCs && GNE_SFA2_PFG_Util.getCsUserIdsWithActivePfgToUserDetails(distributionMethod,includeZeroPfg2UserDetails).contains(currentUserId)) {
                    trx.From_User_gne__c = currentUserId;
                    populateFieldsOnFromUserChange((String)currentUserId);
                }
            }
        }
    }

    private String distributionMethodOnCreate() {
        return recordTypeVisName==GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER
            ? GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP
            : GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC;
    }

    protected override void populateLookupInfos() {
        super.populateLookupInfos();

        lookupAvailableRecordIds.put('PRODUCT_VOD__C',currentUserId); // put fake product id to be sure that no product will be found
        lookupAvailableRecordIds.put('SFA2_LOT_CATALOG_GNE__C',currentUserId); // put fake lot id to be sure that no lot will be found

        if(fieldNames.contains('VENDOR_GNE__C')) {
            lookupAvailableRecordIds.put('VENDOR_GNE__C',currentUserId);
            lookupColumns.put('VENDOR_GNE__C','Name,Vendor_Name_gne__c,Address_Line_1_gne__c,City_gne__c,State_gne__c,Zip_gne__c');
        }

        if(fieldNames.contains('FROM_USER_GNE__C')) {
            String lookupUserColumns = 'Name[display=true;searchBy=true],Email[searchBy=true],Profile_Name_gne__c[searchBy=false]';
            lookupColumns.put('FROM_USER_GNE__C', lookupUserColumns);
            populateLookupUserIds(true);
        }

        if(fieldNames.contains('TO_USER_GNE__C')) {
            String lookupUserColumns = 'Name[display=true;searchBy=true],Email[searchBy=true],Profile_Name_gne__c[searchBy=false]';
            lookupColumns.put('TO_USER_GNE__C', lookupUserColumns);
            populateLookupUserIds(false);
        }

        if(fieldNames.contains('FROM_USER_TERRITORY_GNE__C')) {
            String lookupTerrColumns = 'Name[display=true;searchBy=true],Territory_Number_gne__c[searchBy=true]';
            lookupColumns.put('FROM_USER_TERRITORY_GNE__C', lookupTerrColumns);
            populateLookupTerritoryIds(true);
        }

        if(fieldNames.contains('TO_USER_TERRITORY_GNE__C')) {
            String lookupTerrColumns = 'Name[display=true;searchBy=true],Territory_Number_gne__c[searchBy=true]';
            lookupColumns.put('TO_USER_TERRITORY_GNE__C', lookupTerrColumns);
            populateLookupTerritoryIds(false);
        }

        if(fieldNames.contains('CALL_PFG_DETAIL_ID_GNE__C')) {
            lookupAvailableRecordIds.put('CALL_PFG_DETAIL_ID_GNE__C',currentUserId);
            List<String> callColumns = new List<String>{
                'Call_Name_gne__c[label=Interaction Id;display=true]',
                'Call_gne__r.Account_vod__r.Name[label=HCP;]',
                'Date_gne__c[searchBy=false;]',
                'Product_gne__r.NDC_Number_gne__c[label=NDC;]',
                'Product_gne__r.Name[label=Product Name;]',
                'Lot_No_gne__c'
            };
            lookupColumns.put('CALL_PFG_DETAIL_ID_GNE__C',String.join(callColumns,','));
        }

        if(fieldNames.contains('SHIPMENT_ID_GNE__C')) {
            populateShipmentWhereExpression();
        }
    }

    private void populateLookupUserIds(Boolean isFromUser) {
        Set<Id> userIds = new Set<Id>();

        if(isFromUser) {
                Set<Id> ids = GNE_SFA2_PFG_Util.getCsUserIdsWithActivePfgToUserDetails(distributionMethod,includeZeroPfg2UserDetails);

            if(isCs) {
                if(ids.contains(currentUserId)) {
                        userIds.add(currentUserId);
                }
            } else {
                for(Id userId : ids) {
                        userIds.add(userId);
                }

                userIds = filterUserByValidForHc(userIds);
            }

            if(userIds.isEmpty()) {
                        // To be sure that no matching record will be found
                    userIds.add(UserInfo.getProfileId());
                }

            lookupAvailableRecordIds.put('FROM_USER_GNE__C', String.join(new List<Id>(userIds),','));
                } else {
                        populateToUserLookupValues(isCs ? currentUserId : null);
                }
    }

    private Set<Id> filterUserByApprovedStorageLocation(Set<Id> userIds) {
        if(!userIds.isEmpty() &&
           recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER) {
                GNE_SFA2_PFG_Util.cacheStorageLocationsByUserIds(userIds,true);

            for(Id uId : userIds.clone()) {
                if(GNE_SFA2_PFG_Util.getApprovedStorageLocationForUser(uId) == null) {
                        userIds.remove(uId);
                }
            }
        }

        return userIds;
    }

    private Set<Id> filterUserByValidForHc(Set<Id> userIds) {
        if(!userIds.isEmpty() && distributionMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC) {
                Set<Id> filterUserIds = new Set<Id>();

            for(Id uId : userIds) {
                if(GNE_SFA2_PFG_Util.canCsUseHc(uId)) {
                        filterUserIds.add(uId);
                }
            }
            userIds = filterUserIds;
        }

        return userIds;
    }

    private void populateLookupTerritoryIds(Boolean isFromUser) {
        Set<String> terrIds = new Set<String>();
        String fromTerrId = mainTrx.From_User_Territory_gne__c;
        Set<Territory2> currentUserTerrs = new Set<Territory2>();

        if(GNE_SFA2_PFG_Util.checkIsUserManager(currentUserId)) {
        	Territory2 hoTerr = GNE_SFA2_PFG_Util.getHoTerritory();
        	hoDummyTerritory = new List<Territory2>{hoTerr};
        	currentUserTerrs.add(hoTerr);
        } else if(GNE_SFA2_PFG_Util.checkIsUserBrandManager(currentUserId)) {
        	currentUserTerrs.addAll(GNE_SFA2_PFG_Util.getTerritoriesForUser(currentUserId));
        }

        if(isFromUser || String.isBlank(fromTerrId)) {
        	for(Territory2 terr : currentUserTerrs) {
        		if(terr.Id!=null) {
        			terrIds.add(terr.Id);
        		}

        		for(Territory2 cTerr : GNE_SFA2_PFG_Util.getAllChildTerritories(terr.Id)) {
        			terrIds.add(cTerr.Id);
        		}
        	}
        } else {
        	Territory2 fromTerr = GNE_SFA2_PFG_Util.getTerritory((Id)fromTerrId);
        	Territory2 parentTerr = GNE_SFA2_PFG_Util.getParentTerritory((Id)fromTerrId);
        	if(parentTerr!=null) {
        		terrIds.add(parentTerr.Id);
        	}

            for(Territory2 cTerr : GNE_SFA2_PFG_Util.getChildTerritoriesBySalesforceCodes(
            		parentTerr!=null ? parentTerr.Id : null,
            		fromTerr.Salesforce_Code_gne__c, null)) {
            	if(cTerr.Id!=(Id)fromTerrId) {
                	terrIds.add(cTerr.Id);
                }
            }
        }

        if(!isFromUser &&
           String.isNotBlank(mainTrx.To_User_Territory_gne__c) &&
           !terrIds.contains(mainTrx.To_User_Territory_gne__c) &&
           mainTrx.To_User_Territory_gne__c != GNE_SFA2_PFG_Util.getHoTerritoryId()) {

            mainTrx.To_User_Territory_gne__c = null;
        }

        if(terrIds.isEmpty()) {
            // To be sure that no matching record will be found
            terrIds.add(currentUserId);
        }

        lookupAvailableRecordIds.put((isFromUser ? 'FROM_USER_TERRITORY_GNE__C' : 'TO_USER_TERRITORY_GNE__C'), String.join(new List<String>(terrIds),','));
    }

    private void populateShipmentWhereExpression(){
        String whereExpr = '';
        SFA2_PFG_Transaction_gne__c trx = mainTrx;

        if(String.isNotBlank(trx.From_User_gne__c) && String.isNotBlank(trx.NDC_Number__c) && String.isNotBlank(trx.Lot_No_gne__c)) {


            List<String> whereStatements = new List<String>{
                'Shipment_Id_gne__c!=null',
                'Transaction_Type_gne__c IN (\''+ GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER +'\', \''
                    + GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER +'\')',
                'To_User_gne__c = \'' + trx.From_User_gne__c + '\'',
                'NDC_Number__c = \'' + trx.NDC_Number__c  + '\'',
                'Lot_No_gne__c = \'' + trx.Lot_No_gne__c + '\''
            };

            whereExpr = String.join(whereStatements,' AND ');
        } else {

            whereExpr = 'Id = \'' + currentUserId + '\'';
        }

        lookupWhereExpressions.put('SHIPMENT_ID_GNE__C',whereExpr);
    }

    public PageReference addTransfer() {
        PageReference result = null;
        try {
            result = intAddTransfer();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intAddTransfer() {
        SFA2_PFG_Transaction_gne__c trx = new SFA2_PFG_Transaction_gne__c(RecordTypeId = recordTypeId);

        Integer maxUsedIdx = 0;
        for(Integer usedIdx : transactionsMap.keySet()) {
            maxUsedIdx = Math.max(usedIdx, maxUsedIdx);
        }

        Integer idx = Math.max(maxUsedIdx+1,transactions.size());
        TransactionWrapper trxWrapper = new TransactionWrapper(idx,trx);
        transactions.add(trxWrapper);
        transactionsMap.put(idx,trxWrapper);
        return null;
    }

    public PageReference removeTransfer() {
        PageReference result = null;
        try {
            result = intRemoveTransfer();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveTransfer() {
        Integer idx = Integer.valueOf(rowIdx);
        transactionsMap.remove(idx);

        Integer idxToRemove=0;
        for(TransactionWrapper trxWrapper : transactions) {
            if(trxWrapper.rowIdx == idx) {
                break;
            }
            idxToRemove++;
        }

        if(idxToRemove>0) {
            transactions.remove(idxToRemove);
        }

        return null;
    }

    public PageReference saveTransaction() {
        PageReference result = null;
        try {
            result = IntSaveTransaction();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(GNE_SFA2_PFG_Base_Controller.SAVE_ERROR_MESSAGE_PREFIX, ex);
        }

        return result;
    }

    private PageReference IntSaveTransaction() {
        PageReference result = null;

        SFA2_PFG_Transaction_gne__c mainTrx = (SFA2_PFG_Transaction_gne__c)myObject;
        List<SFA2_PFG_Transaction_gne__c> transactionToSave = new List<SFA2_PFG_Transaction_gne__c>{mainTrx};
        if(availabilityMode == 'New') {
            mainTrx.Distribution_Method_gne__c = distributionMethod;

            if(recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER) {
                for(TransactionWrapper trxWrapper : transactions) {
                    if(trxWrapper.rowIdx!=0) {
                        populateFieldValuesForTransfer(trxWrapper.record,mainTrx);
                        transactionToSave.add(trxWrapper.record);
                    }
                }
            } else if(recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN) {
                if(String.isNotBlank(mainTrx.Shipment_Id_gne__c)) {
                    mainTrx.Shipment_Id_gne__c = getShipmentId(mainTrx.Shipment_Id_gne__c);
                }
            }
        } else { // update mode
            if(recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER ||
               recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER ||
               recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER) {

                mainTrx.Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED;
                mainTrx.Receipt_Date_gne__c = System.now();
            }
        }

        Boolean isOk = false;
        SavePoint savePoint = Database.setSavepoint();

        try {
            validateTransactions(transactionToSave);
            GNE_SFA2_PFG_Util.saveTransaction(transactionToSave, (mainTrx.Id!=null ? mainTrx.Transaction_Ref_Number_gne__c : null), false);
            isOk = true;
        } catch(GNE_SFA2_PFG_Base_Controller.InvalidInputValueException ex) {
            for(String errorMsg : ex.errorMessages) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,errorMsg));
            }
        } catch(Exception ex) {
            Apexpages.addMessages(ex);
            Database.rollback(savePoint);
        }

        if(isOk) {
            if(availabilityMode == 'New' && recordTypeVisName==GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER) {
                result = redirectAfterOrderSubmitted();
            } else {
                result = new PageReference('/' + mainTrx.Id);
            }
        }

        return result;
    }

    private PageReference redirectAfterOrderSubmitted() {
        PageReference result = new PageReference('/' + mainTrx.getSobjectType().getDescribe().getKeyPrefix() + '/e');
        result.getParameters().put('transactionType', GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER);
        result.getParameters().put('requestSubmitted', '1');
        result.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        return result;
    }

    private void populateFieldValuesForTransfer(SFA2_PFG_Transaction_gne__c trx, SFA2_PFG_Transaction_gne__c mainTrx) {
        trx.Distribution_Method_gne__c = mainTrx.Distribution_Method_gne__c;
        for(String fieldName : fieldNames) {
            trx.put(fieldName,mainTrx.get(fieldName));
        }
    }

    private void validateTransactions(List<SFA2_PFG_Transaction_gne__c> trxs) {
        List<String> emptyRequiredFieldErrorMessages = new List<String>();
        SFA2_PFG_Transaction_gne__c mainTrx = (SFA2_PFG_Transaction_gne__c)myObject;

        for(List<SFA2_Configuration_Object_Detail_gne__c> fieldSet : fieldSetMap.values()) {
            for(SFA2_Configuration_Object_Detail_gne__c fieldDetail : fieldSet) {
                if(fieldDetail.Type_gne__c == FIELD && fieldDetail.Is_Required_gne__c) {
                        Object fieldValue = myObject.get(fieldDetail.API_Name_gne__c);
                        if(fieldValue==null || String.isBlank(String.valueOf(fieldValue))) {
                            emptyRequiredFieldErrorMessages.add(fieldDetail.Label_gne__c + GNE_SFA2_PFG_Base_Controller.MISSING_REQUIRED_FIELD_VALUE);
                        }
                }
            }
        }

        // needed during Quantity validation in GNE_SFA2_PFG_Util.validateRequestedQuantity() method
        if(recordTypeVisName==GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER &&  distributionMethod==GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP) {
            GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(trxs);
        } else {
            GNE_SFA2_PFG_Util.cachePfgToUserDetails(trxs);
        }

        Set<String> lotNos = new Set<String>();
        Integer i = 0;
        Boolean singleMode = trxs.size()==1;

        for(SFA2_PFG_Transaction_gne__c trx : trxs) {
            String rowPrefix = singleMode ? '' : ('Row ' + ++i + ': ');

            if(String.isBlank(trx.Product_gne__c)) {
                emptyRequiredFieldErrorMessages.add(rowPrefix + 'NDC' + GNE_SFA2_PFG_Base_Controller.MISSING_REQUIRED_FIELD_VALUE);
            }

            if(recordTypeVisName!=GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER && distributionMethod!=GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP && String.isBlank(trx.Lot_No_gne__c)) {
                emptyRequiredFieldErrorMessages.add(rowPrefix + SFA2_PFG_Transaction_gne__c.Lot_No_gne__c.getDescribe().getLabel() + GNE_SFA2_PFG_Base_Controller.MISSING_REQUIRED_FIELD_VALUE);
            }

            if(String.isNotBlank(trx.Lot_No_gne__c)) {
                if(lotNos.contains(trx.Lot_No_gne__c)) {
                                emptyRequiredFieldErrorMessages.add(rowPrefix + SFA2_PFG_Transaction_gne__c.Lot_No_gne__c.getDescribe().getLabel() + GNE_SFA2_PFG_Base_Controller.VALUE_ALREADY_IN_USE_MSG);
                        }
                lotNos.add(trx.Lot_No_gne__c);
            }

            List<Integer> minAndMaxValues = new List<Integer>{null,null};
            Boolean isInsert = trx.id==null ? true: false;

            if(!validateQuantityIsInteger(trx, isInsert)) {
                emptyRequiredFieldErrorMessages.add(rowPrefix + System.Label.GNE_SFA2_PFG_QUANTITY_IS_TOO_LARGE);
            } else if(!GNE_SFA2_PFG_Util.validateTransactionQuantity(trx, minAndMaxValues, isInsert)) {
                        //only min value
                        if(minAndMaxValues[1] == null) {
                        emptyRequiredFieldErrorMessages.add(rowPrefix + String.format(System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_GREATER, new String[]{minAndMaxValues[0].format()}));
                        //kozminls: max value == 0
                        }else if(minAndMaxValues[1] == 0){
                                emptyRequiredFieldErrorMessages.add(rowPrefix + System.Label.GNE_SFA2_PFG_QUANTITY_NOT_AVAILABLE);
                        //if max value > min value
                    } else if( minAndMaxValues[0] != minAndMaxValues[1]){
                        emptyRequiredFieldErrorMessages.add(rowPrefix + String.format(System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_BETWEEN, new String[]{minAndMaxValues[0].format(),minAndMaxValues[1].format()}));
                        } else{
                        emptyRequiredFieldErrorMessages.add(rowPrefix + String.format(System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_EQUAL, new String[]{minAndMaxValues[0].format()}));
                    }
                }
        }

        if(!emptyRequiredFieldErrorMessages.isEmpty()){
            throw new GNE_SFA2_PFG_Base_Controller.InvalidInputValueException(emptyRequiredFieldErrorMessages);
        }
    }

    private Boolean validateQuantityIsInteger(SFA2_PFG_Transaction_gne__c trx, Boolean isInsert) {
        Decimal qty = isInsert ? trx.Requested_Quantity_gne__c : trx.Received_Quantity_gne__c;
        return GNE_SFA2_PFG_Base_Controller.validateIsInteger(qty);
    }

    private String getShipmentId(String trxId){
        String shipId = null;
        for(SFA2_PFG_Transaction_gne__c trx : GNE_SFA2_PFG_DAO.getTransactionById(trxId)) {
            shipId = trx.Shipment_Id_gne__c;
        }
        return shipId;
    }

    //populates NDC number from choosed product into transaction
    public PageReference populateProductFields() {
        PageReference result = null;
        try {
            result = intPopulateProductFields();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intPopulateProductFields() {
        return intPopulateProductFields(false);
    }

    //populates NDC number from choosed product into transaction
    private PageReference intPopulateProductFields(Boolean causedByLotNoUpdate) {
        Integer idx = Integer.valueOf(rowIdx);
        System.debug('idx = ' + idx);
        if(transactionsMap.containsKey(idx)) {
            TransactionWrapper trxWrapper = transactionsMap.get(idx);
            SFA2_PFG_Transaction_gne__c trx = trxWrapper.record;
            Boolean productChanged = ((String)trx.Product_gne__c)!= productId;

            trx.Product_gne__c = null;
            trx.Product_gne__r = null;
            trx.NDC_Number__c = null;
            trx.UOM_gne__c = null;
            productIsSeleted = false;

            if(fieldNames.contains('VENDOR_GNE__C')) {
                lookupAvailableRecordIds.put('VENDOR_GNE__C',currentUserId);
            }

            if(!causedByLotNoUpdate) {
                trx.Lot_No_gne__c = null;
                trxWrapper.lotCatalogId = null;
                trxWrapper.lotWhereExpression = null;
            }

            if(String.isNotBlank(productId)) {
                for(Product_vod__c prod : GNE_SFA2_PFG_DAO.getProductsById(new Set<String>{ productId })) {
                    trx.Product_gne__c = prod.Id;
                    trx.Product_gne__r = prod;
                    trx.NDC_Number__c = prod.NDC_Number_gne__c;
                    trx.UOM_gne__c = prod.UOM_gne__c;
                    trxWrapper.lotWhereExpression = 'Product_gne__c = \''+ productId +'\'';

                    if(fieldNames.contains('VENDOR_GNE__C')) {
                        List<String> vendorIds = getAvailableVendors(trx.Product_gne__c);
                        if(vendorIds.isEmpty()) {
                            // just to be sure no vendor will be available to select
                            vendorIds.add(currentUserId);
                        }
                        lookupAvailableRecordIds.put('VENDOR_GNE__C',String.join(vendorIds,','));
                    }

                    productIsSeleted = true;

                    break;
                }
            }

            if(productChanged && fieldNames.contains('VENDOR_GNE__C')) {
                vendorId = null;
                intReturnToValueChanged();
            }
        }

        return null;
    }

    public PageReference lotNoSelectAction() {
        PageReference result = null;
        try {
            result = intLotNoSelectAction();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intLotNoSelectAction() {
        Integer idx = Integer.valueOf(rowIdx);

        if(transactionsMap.containsKey(idx)) {
            TransactionWrapper trxWrapper = transactionsMap.get(idx);
            SFA2_PFG_Transaction_gne__c trx = trxWrapper.record;

            trx.Lot_No_gne__c = null;
            trxWrapper.lotCatalogId = null;

            if(String.isNotBlank(lotId)) {
                for(SFA2_Lot_Catalog_gne__c lotCatalog : GNE_SFA2_PFG_DAO.getLotCatalogsForIds(new Set<String>{lotId})) {
                    trxWrapper.lotCatalogId = lotCatalog.Id;
                    trx.Lot_No_gne__c = lotCatalog.Name;
                    if(String.isBlank(trx.Product_gne__c) || lotCatalog.Product_gne__c!=trx.Product_gne__c) {
                        // Populate product fields
                        productId = lotCatalog.Product_gne__c;
                        intPopulateProductFields(true);
                    }

                    break;
                }
            }
        }

        if(fieldNames.contains('SHIPMENT_ID_GNE__C')) {
            populateShipmentWhereExpression();
        }

        return null;
    }

    private List<String> getAvailableVendors(Id productId) {
        List<String> result = new List<String>();

        for(Vendor_gne__c vdr : GNE_SFA2_PFG_Util.getVendorsForProducts(new Set<Id>{productId})) {
            result.add(vdr.Id);
        }

        return result;
    }

    public PageReference returnToValueChanged() {
        PageReference result = null;
        try {
            result = intReturnToValueChanged();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intReturnToValueChanged() {
        SFA2_PFG_Transaction_gne__c trx = (SFA2_PFG_Transaction_gne__c)myObject;
        GNE_SFA2_PFG_Transaction_Field_Update.populateTransactionAddressFromVendor(trx,null);
        trx.Vendor_gne__c = null;
        trx.Address_Line_1_gne__c = null;
        trx.Address_Line_2_gne__c = null;
        trx.City_gne__c = null;
        trx.State_gne__c = null;
        trx.Zip_gne__c = null;

        if(String.isNotBlank(vendorId)) {
                GNE_SFA2_PFG_Transaction_Field_Update.populateTransactionAddressFromVendor(
                        trx,GNE_SFA2_PFG_Util.getVendorById((Id)vendorId));
        }

        return null;
    }

    public PageReference userLookupFieldActionMethod() {
        PageReference result = null;
        try {
            result = intUserLookupFieldActionMethod();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intUserLookupFieldActionMethod() {
        SFA2_PFG_Transaction_gne__c mainTrx = (SFA2_PFG_Transaction_gne__c)myObject;

        if(String.isNotBlank(customRecId) && String.isNotBlank(fieldName)) {
            if(fieldName == 'From_User_gne__c') {
                mainTrx.From_User_gne__c = String.isNotBlank(customRecId) ? customRecId : null;
                populateFieldsOnFromUserChange(customRecId);
            } else if(fieldName == 'To_User_gne__c') {
                mainTrx.To_User_gne__c = String.isNotBlank(customRecId) ? customRecId : null;
                if(recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER
                || recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER) {
                    GNE_SFA2_PFG_Util.populateTransactionAddressFromUser(mainTrx,(Id)customRecId);
                }
            }
        }
        return null;
    }

    public PageReference territoryLookupFieldActionMethod() {
        PageReference result = null;
        try {
            result = intTerritoryLookupFieldActionMethod();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intTerritoryLookupFieldActionMethod() {
        if(fieldName == 'From_User_Territory_gne__c') {
            mainTrx.From_User_Territory_gne__c = String.isNotBlank(customRecId) ? customRecId : null;
            populateTerritryFields(true);
            populateLookupTerritoryIds(false);
            populateProductLookupOnTerritryChange();
        } else if(fieldName == 'To_User_Territory_gne__c') {
            mainTrx.To_User_Territory_gne__c = String.isNotBlank(customRecId) ? customRecId : null;
            populateTerritryFields(false);
        }

        return null;
    }

    private void populateTerritryFields(Boolean isFromField) {
        String terrId = isFromField ? mainTrx.From_User_Territory_gne__c : mainTrx.To_User_Territory_gne__c;
        String terrName = terrId;
        String terrNumber = null;
        System.debug('BOS::terrId=' + terrId);
        if(terrId != GNE_SFA2_PFG_Util.getHoTerritoryId() && String.isNotBlank(terrId)) {
            Territory2 terr = GNE_SFA2_PFG_Util.getTerritory((Id)terrId);
            terrName = terr.Name;
            terrNumber = terr.Territory_Number_gne__c;
        }

        if(isFromField) {
            mainTrx.From_Territory_Name_gne__c = terrName;
            mainTrx.From_Territory_Number_gne__c = terrNumber;
        } else {
            mainTrx.To_Territory_Name_gne__c = terrName;
            mainTrx.To_Territory_Number_gne__c = terrNumber;
        }
    }

    private void populateFieldsOnFromUserChange(String userId) {
        SFA2_PFG_Transaction_gne__c mainTrx = (SFA2_PFG_Transaction_gne__c)myObject;

        if(String.isNotBlank(userId)) {
                System.debug('BOS:: userId = "' + userId + '"');

                if(fieldNames.contains('CALL_PFG_DETAIL_ID_GNE__C')) {
                populateCallDetailLookupValues((Id)userId);
                }

            populateProductAndLotLookupValues((Id)userId);

            if(fieldNames.contains('TO_USER_GNE__C')) {
                populateToUserLookupValues((Id)userId);
            }
        }
    }

    private void populateToUserLookupValues(Id userId) {
        Set<Id> userIds = new Set<Id>();

        if(userId!=null) {
                Set<String> brandNames = GNE_SFA2_PFG_Util.getBrandNamesByUserTerritory(userId);

                for(SFA2_User_Sales_Roster_gne__c uRoster : GNE_SFA2_PFG_Util.getUsersByBrandsAndRole(brandNames, GNE_SFA2_PFG_Util.USER_ROLE_CS)) {
                        userIds.add(uRoster.User_gne__c);
                }

                // From and To User cannot be the same
                userIds.remove(userId);
        } else {
                for(SFA2_User_Sales_Roster_gne__c uRoster : GNE_SFA2_PFG_Util.getUsersByRoleName(GNE_SFA2_PFG_Util.USER_ROLE_CS)) {
                userIds.add(uRoster.User_gne__c);
            }
        }

        // Filter by Approved Storage Location
        userIds = filterUserByApprovedStorageLocation(userIds);
        // Filter by Valid Users for Hand Carry
        userIds = filterUserByValidForHc(userIds);

        if(userIds.isEmpty()) {
                // To be sure that no matching users will be found
            userIds.add(UserInfo.getProfileId());
        }

        lookupAvailableRecordIds.put('TO_USER_GNE__C',String.join(new List<Id>(userIds),','));

        if(String.isNotBlank(mainTrx.To_User_gne__c) && !userIds.contains(mainTrx.To_User_gne__c)) {
                mainTrx.To_User_gne__c = null;
        }
    }

    private void populateCallDetailLookupValues(Id userId) {
        Set<Id> callDetailIds = new Set<Id>();
        for(SFA2_PFG_Transaction_gne__c trx : GNE_SFA2_PFG_Util.getCallDetailTransactionsForUsers(
                                                                                        new Set<Id>{userId},
                                                                                        new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT})) {
            if(trx.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC) {
                callDetailIds.add(trx.Call_PFG_Detail_ID_gne__c);
            }
        }

        if(callDetailIds.isEmpty()) {
            callDetailIds.add(currentUserId);
        }

        lookupAvailableRecordIds.put('CALL_PFG_DETAIL_ID_GNE__C',String.join(new List<Id>(callDetailIds),','));

        if(String.isNotBlank(mainTrx.Call_PFG_Detail_ID_gne__c) && !callDetailIds.contains(mainTrx.Call_PFG_Detail_ID_gne__c)) {
            mainTrx.Call_PFG_Detail_ID_gne__c = null;
            callDetailTrx = null;
        }
    }

    private void populateProductAndLotLookupValues(Id userId) {
        if(callDetailTrx!=null) {
            lookupAvailableRecordIds.put('PRODUCT_VOD__C',callDetailTrx.Product_gne__c);

            for(SFA2_Lot_Catalog_gne__c lotC : GNE_SFA2_PFG_DAO.getLotCatalogsForLotNumber(new Set<String>{callDetailTrx.Lot_No_gne__c})) {
                lookupAvailableRecordIds.put('SFA2_LOT_CATALOG_GNE__C',lotC.Id);
            }
        } else { // From User
            Set<Id> userProductIds = GNE_SFA2_PFG_Util.getUsedPfgProductsIdsForUser(
                userId,
                distributionMethod,
                includeZeroPfg2UserDetails);

            if(userProductIds.isEmpty()) {
                // To be sure that no matching products will be found
                userProductIds.add(currentUserId);
            }

            lookupAvailableRecordIds.put('PRODUCT_VOD__C',String.join(new List<Id>(userProductIds),','));

            Set<Id> userLotCatalogIds = GNE_SFA2_PFG_Util.getUsedPfgLotCatalogsIdsForUser(
                (Id)userId,
                distributionMethod,
                includeZeroPfg2UserDetails);

            if(userLotCatalogIds.isEmpty()) {
                // To be sure that no matching lot catalog will be found
                userLotCatalogIds.add(currentUserId);
            }

            lookupAvailableRecordIds.put('SFA2_LOT_CATALOG_GNE__C',String.join(new List<Id>(userLotCatalogIds),','));

            // Reset dependent field values (if needed)
            productId = null;
            lotId = null;
            for(TransactionWrapper trxWrapper : transactions) {
                SFA2_PFG_Transaction_gne__c trx = trxWrapper.record;

                if(String.isNotBlank(trx.Product_gne__c) && !userProductIds.contains(mainTrx.Product_gne__c)) {
                    rowIdx = String.valueOf(trxWrapper.rowIdx);
                    intPopulateProductFields();
                } else if(String.isNotBlank(trxWrapper.lotCatalogId) && !userLotCatalogIds.contains((Id)trxWrapper.lotCatalogId)) {
                    rowIdx = String.valueOf(trxWrapper.rowIdx);
                    intLotNoSelectAction();
                }
            }
        }
    }

    private void populateProductLookupOnTerritryChange() {
        String terrId = mainTrx.From_User_Territory_gne__c;

        Set<Id> terrProductIds = new Set<Id>();

        if(String.isNotBlank(terrId)) {
        	Integer year = GNE_SFA2_PFG_Util.getYear(mainTrx);
        	year = year!=null ? year : GNE_SFA2_PFG_Util.getYear();
            terrProductIds = GNE_SFA2_PFG_Util.getUsedPfgProductsIdsForTerritory(
                new Set<String>{terrId}, new Set<Integer>{year});
        }

        if(terrProductIds.isEmpty()) {
            // To be sure that no matching products will be found
            terrProductIds.add(currentUserId);
        }

        lookupAvailableRecordIds.put('PRODUCT_VOD__C',String.join(new List<Id>(terrProductIds),','));
    }

    public PageReference callDetailChangeAction() {
        PageReference result = null;
        try {
            result = intCallDetailChangeAction();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intCallDetailChangeAction() {
        mainTrx.Call_PFG_Detail_ID_gne__c = null;
        callDetailTrx = null;

        if(String.isNotBlank(customRecId)) {
            mainTrx.Call_PFG_Detail_ID_gne__c = customRecId;
            for(SFA2_PFG_Transaction_gne__c trx : GNE_SFA2_PFG_DAO.getTransactionsByInteractionId(new Set<Id>{(Id)customRecId})) {
                callDetailTrx = trx;
                break;
            }
        }

        if(callDetailTrx!=null) {
            for(SFA2_Lot_Catalog_gne__c lotC : GNE_SFA2_PFG_DAO.getLotCatalogsForLotNumber(new Set<String>{callDetailTrx.Lot_No_gne__c})) {
                lotId = lotC.Id;
                rowIdx = '0';
                intLotNoSelectAction();

                break;
            }
        }

        populateProductAndLotLookupValues(mainTrx.From_User_gne__c);

        return null;
    }

    public class TransactionWrapper {
        public Integer rowIdx {get; private set;}
        public SFA2_PFG_Transaction_gne__c record {get; private set;}
        public String lotCatalogId {get; set;}
        public String lotWhereExpression {get; set;}

        public TransactionWrapper(Integer a_rowIdx, SFA2_PFG_Transaction_gne__c a_record) {
            rowIdx = a_rowIdx;
            record = a_record;
            lotCatalogId = null;
            lotWhereExpression = null;

            if(record.Lot_No_gne__c!=null) {
                for(SFA2_Lot_Catalog_gne__c lotC : GNE_SFA2_PFG_DAO.getLotCatalogsForLotNumber(new Set<String>{record.Lot_No_gne__c})) {
                    lotCatalogId = lotC.Id;
                    break;
                }
            }

            if(record.Product_gne__c!=null) {
                lotWhereExpression = 'Product_gne__c = \''+ record.Product_gne__c +'\'';
            }
        }
    }
}