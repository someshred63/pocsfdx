/** @date 7/16/2012
* @Author Pawel Sprysak
* @description Controller for AGS_ST_DisputeList_gne and AGS_ST_DisputeManagementLookup_gne pages
* with additional component AGS_ST_DisputeList_Controller_gne (search filter form)
*/
public without sharing class AGS_ST_DisputeList_Controller_gne {
    private final static String CCO_GROUP_NAME = 'GNE-AGS-CCO-Analyst-Group';
    private final static String TRIAGE_TEAM_GROUP_NAME = 'Data Support Group';
    private final static String DISPUTE_RESOLVER_OBJ_TYPE_NAME = 'AGS_ST_DisputeResolver_gne__c';
	private final static Integer MAX_DISPUTE_NUM_ON_LIST = 10000;
	// Getters and setters
	public Boolean isMaxDisputes {
		get {
			return disputeUtil.totalDisputes == MAX_DISPUTE_NUM_ON_LIST;
		}
	}
	public AGS_ST_DisputeList_Controller_gne controller { get; set; }
	public AGS_ST_DMPagingAndSortingUtils disputeUtil { get; set; }
	private transient ApexPages.StandardSetController physicianDisputeSSC { get; set; }
	private String soqlWhereStatement { get; set; }
    public List<SelectOption> stateOptionList { get; set; }
    public List<SelectOption> specialityOptionList { get; set; }
    public String lookupId { get; set; }
	// Search filter component
	public String selectedView { get; set; }
    public Boolean isSubmitted { get; set; }
    public Boolean isAssigned { get; set; }
    public Boolean isInProgress { get; set; }
    public Boolean isCorrectedPendingSSR { get; set; }
    public Boolean isResolvedWithCorrection { get; set; }
    public Boolean isResolvedNoCorrection { get; set; }
    public String disputeName { get; set; }
    public String resolver { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
	public String speciality { get; set; }
    public AGS_ST_DisputeManagement_gne__c disputeDateFromContainer { get; set; }
    public AGS_ST_DisputeManagement_gne__c disputeDateToContainer { get; set; }
    public AGS_ST_DisputeManagement_gne__c paymentDateFromContainer { get; set; }
    public AGS_ST_DisputeManagement_gne__c paymentDateToContainer { get; set; }
	public String drugName { get; set; }
    public String amountFromStr {
        get;
        set {
            amountFromStr = value;
            try {
                if(value != null) {
                    amountFrom = Decimal.valueOf(value);
                } else {
                    amountFrom = null;
                }
            } catch(TypeException te) {
                amountFrom = -9999999999999.99;
            }
        }
    }
    public String amountToStr {
        get;
        set {
            amountToStr = value;
            try {
                if(value != null) {
                    amountTo = Decimal.valueOf(value);
                } else {
                    amountTo = null;
                }
            } catch(TypeException te) {
                amountTo = 9999999999999.99;
            }
        }
    }
    public Decimal amountFrom { get; set; }
    public Decimal amountTo { get; set; }
    public String natureOfPaymet { get; set; }
    public String formOfPaymet { get; set; }
    public String state { get; set; }
    public String isCmsDispute { get; set; }
    public String cmsDisputeID { get; set; }

	public String filterName { get; set; }
    public String selectedFilterName { get; set; }
    public List<SelectOption> savedFilters;

	/** @date 7/16/2012
	* @Author Pawel Sprysak
	* @description Controller constructor
	*/
    public AGS_ST_DisputeList_Controller_gne() {
    	controller = this;
		// Initialization vars
    	lookupId = System.currentPageReference().getParameters().get('lknm');
    	disputeUtil = new AGS_ST_DMPagingAndSortingUtils();
        selectedView = 'Submitted';
		// Initialization search values
        disputeDateFromContainer = new AGS_ST_DisputeManagement_gne__c();
        disputeDateToContainer = new AGS_ST_DisputeManagement_gne__c();
        paymentDateFromContainer = new AGS_ST_DisputeManagement_gne__c();
        paymentDateToContainer = new AGS_ST_DisputeManagement_gne__c();
		// Initializing lists for customize search
        stateOptionList = new List<SelectOption>{new SelectOption('All', 'All')};
        stateOptionList.addAll(AGS_ST_Utils.getStatesNames());
        specialityOptionList = new List<SelectOption>{new SelectOption('All', 'All')};
        for(AGS_ST_RecipientSpeciality_gne__c rs : AGS_ST_DbUtils.getRecipientSpecialityList()) {
        	specialityOptionList.add(new SelectOption(rs.Speciality_Name_gne__c, rs.Speciality_Name_gne__c));
        }
		// Set default list values
		disputeUtil.sortField = 'Name';
		disputeUtil.sortOrder = 'desc';
		updateView();
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Converting Payment Date ("From" value) to Datetime
	* @return DateTime
	*/
    private DateTime getDisputeDateFromAsDateTime() {
        DateTime result = DateTime.newInstance(this.disputeDateFromContainer.Payment_Date_gne__c.year(),
            				this.disputeDateFromContainer.Payment_Date_gne__c.month(), this.disputeDateFromContainer.Payment_Date_gne__c.day());
        return result;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Converting Payment Date ("To" value) to Datetime
	* @return DateTime
	*/
    private DateTime getDisputeDateToAsDateTime() {
        DateTime result = DateTime.newInstance(this.disputeDateToContainer.Payment_Date_gne__c.year(),
            				this.disputeDateToContainer.Payment_Date_gne__c.month(), this.disputeDateToContainer.Payment_Date_gne__c.day());
        result = result.addDays(1);
        return result;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description View list: Getter for statuses
	* @return List<SelectOption>
	*/
    public List<SelectOption> getViews() {
    	List<SelectOption> optionList = AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Internal_Status_gne__c.getDescribe());
        return optionList;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Customize search: Getter for Nature of Payment
	* @return List<SelectOption>
	*/
    public List<SelectOption> getNaturesOfPayment() {
    	List<SelectOption> optionList = new List<SelectOption>{new SelectOption('All', 'All')};
    	optionList.addAll(AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Nature_Of_Payment_gne__c.getDescribe()));
        return optionList;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Customize search: Getter for Form of Payment
	* @return List<SelectOption>
	*/
    public List<SelectOption> getFormsOfPayment() {
    	List<SelectOption> optionList = new List<SelectOption>{new SelectOption('All', 'All')};
    	optionList.addAll(AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Form_Of_Payment_gne__c.getDescribe()));
        return optionList;
    }

    /** @date 4/23/2014
    * @Author Pawel Sprysak
    * @description Customize search: Getter for CMS Payment
    * @return List<SelectOption>
    */
    public List<SelectOption> getCmsPayment() {
        List<SelectOption> optionList = new List<SelectOption>{new SelectOption('All', 'All'), new SelectOption('true', 'yes'), new SelectOption('false', 'no')};
        return optionList;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Customize search: Getter for Drug Names (filtered data from Product_vod__c)
	* @return List<SelectOption>
	*/
    public List<SelectOption> getDrugNames() {
    	List<SelectOption> result = new List<SelectOption>{new SelectOption('All', 'All')};
    	result.addAll(AGS_ST_DbUtils.getDrugNames());
        return result;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
    * @description Returns the list of select options for the Dispute Resolver combobox. It reads the users from the CCO group,
    * Triage Team Members Group and a Queue, since only these can be set as the resolvers of the dispute management objects.
    * @return List<SelectOption>
    */
    public List<SelectOption> getResolvers() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('All', 'All'));
        //Get CCO Users
        List<SelectOption> ccoList = new List<SelectOption>();
        for (User u : AGS_ST_DbUtils.getUsersFromGroupsByGroupNames(new List<String> {CCO_GROUP_NAME})) {
            if((u.IsActive == true && u.Profile_Name_gne__c.equals('GNE-AGS-CCO-Analyst'))) {
                ccoList.add(new SelectOption(u.Id, u.Name));
            }
        }
        //Get Triage Users
        List<SelectOption> triageList = new List<SelectOption>();
        for (User u : AGS_ST_DbUtils.getUsersFromGroupsByGroupNames(new List<String> {TRIAGE_TEAM_GROUP_NAME})) {
            if ((u.IsActive == true && u.Profile_Name_gne__c.equals('GNE-SYS-DataSupport'))) {
                triageList.add(new SelectOption(u.Id, u.Name));
            }
        }
        //Get Queues
        List<SelectOption> queueList = new List<SelectOption>();
        for (Group g : AGS_ST_DbUtils.getQueuesForObjectTypes(new List<String> {DISPUTE_RESOLVER_OBJ_TYPE_NAME})) {
            queueList.add(new SelectOption(g.Id, g.Name));
        }
        ccoList.sort();
        triageList.sort();
        queueList.sort();
        result.addAll(ccoList);
        result.addAll(triageList);
        result.addAll(queueList);
        return result;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Getter for Id of Disputes Report
	* @return String
	*/
	public String getDisputesReportId() {
		return String.valueOf(AGS_ST_DbUtils.getDisputesReportId());
	}

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Getter for VF - Dispute List
	* @return List<AGS_ST_DMPagingAndSortingUtils.Dispute>
	*/
    public List<AGS_ST_DMPagingAndSortingUtils.Dispute> getDisputes() {
        setDisputesValues(false);
        return disputeUtil.disputeTransientList;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Method for setting Dispute List
	* @param Boolean initValue (true if method should initialize values)
	*/
    public void setDisputesValues(Boolean initValue) {
        if(initValue || !disputeUtil.compareValues()) {
        	//Get Id of all Disputes (limited to MAX_DISPUTE_NUM_ON_LIST)
            String selectQuery = 'SELECT Id FROM AGS_ST_DisputeManagement_gne__c';
            String selectQueryDR = '';
            if(!soqlWhereStatement.equals('')) {
            	selectQuery += soqlWhereStatement;
            }
            //Check whether additional query is needed for resolver
            if(disputeUtil.sortField!=null && disputeUtil.sortField.equals('Dispute_Resolver_gne__r.Owner.Name')) {
            	if(!soqlWhereStatement.equals('')) {
            		selectQuery += ' AND ';
            	} else {
            		selectQuery += ' WHERE ';
            	}
            	selectQueryDR = selectQuery;
            	if(disputeUtil.sortOrder.equals('asc')) {
            		selectQuery += 'Dispute_Resolver_gne__c = null';
            		selectQueryDR += 'Dispute_Resolver_gne__c != null ORDER BY Dispute_Resolver_gne__r.Owner.Name ASC';
            	} else {
            		selectQuery += 'Dispute_Resolver_gne__c != null ORDER BY Dispute_Resolver_gne__r.Owner.Name DESC';
            		selectQueryDR += 'Dispute_Resolver_gne__c = null';
            	}
            } else if(disputeUtil.sortField!=null && !disputeUtil.sortField.equals('')) {
                selectQuery += ' ORDER BY ' + disputeUtil.sortField + ' ' + disputeUtil.sortOrder;
                if('DESC'.equalsIgnoreCase(disputeUtil.sortOrder)) {
                	selectQuery += ' NULLS LAST ';
                } else {
                	selectQuery += ' NULLS FIRST ';
                }
            }
            selectQuery += ' LIMIT ' + MAX_DISPUTE_NUM_ON_LIST;
            //Check whether additional query is needed for resolver
            if(disputeUtil.sortField!=null && disputeUtil.sortField.equals('Dispute_Resolver_gne__r.Owner.Name')) {
	            List<AGS_ST_DisputeManagement_gne__c> interResult = Database.query(selectQuery);
	            if(interResult.size() < MAX_DISPUTE_NUM_ON_LIST) {
	            	selectQueryDR += ' LIMIT ' + String.valueOf(MAX_DISPUTE_NUM_ON_LIST - interResult.size());
	            	interResult.addAll((List<AGS_ST_DisputeManagement_gne__c>)Database.query(selectQueryDR));
	            }
	            physicianDisputeSSC = new ApexPages.StandardSetController(interResult);
            } else {
            	physicianDisputeSSC = new ApexPages.StandardSetController(Database.query(selectQuery));
            }
			//Get Id of Disputes to display
            disputeUtil.createDMList(physicianDisputeSSC);
            physicianDisputeSSC = null;
            List<Id> idList = disputeUtil.getDisputeIdList();
            disputeUtil.disputeTransientList.clear();
            //Get Disputes to display
            for(AGS_ST_DisputeManagement_gne__c dm : AGS_ST_DbUtils.getDisputeDetailListByIdList(idList)) {
                disputeUtil.disputeTransientList.add(new AGS_ST_DMPagingAndSortingUtils.Dispute(dm));
            }
            //Sort disputes
            if(disputeUtil.sortField!=null && !disputeUtil.sortField.equals('')) {
            	SuperSort.sortList(disputeUtil.disputeTransientList, disputeUtil.sortField, disputeUtil.sortOrder);
            }
			idList = null;
            disputeUtil.duplicateValues();
            physicianDisputeSSC = null;
        }
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Updating view: Show only disputes assigned to me
	* @return PageReference
	*/
    public PageReference updateAssignedToMe() {
        soqlWhereStatement = ' WHERE AGS_ST_Held_Transaction__c = null AND (Internal_Status_gne__c = \'Assigned\' OR Internal_Status_gne__c = \'In Progress\') AND (Dispute_Resolver_gne__r.OwnerId = \''+UserInfo.getUserId()+'\' OR OwnerId = \''+UserInfo.getUserId()+'\')';
        setDisputesValues(true);
        return null;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Updating view: Show disputes with status selected in by View List
	* @return PageReference
	*/
    public PageReference updateView() {
        String view = String.escapeSingleQuotes(selectedView);
        soqlWhereStatement = ' WHERE AGS_ST_Held_Transaction__c = null AND Internal_Status_gne__c = \'' + view + '\'';
        setDisputesValues(true);
        return null;
    }

	/** @date 01/22/2013
	* @Author Pawel Sprysak
	* @description Updating view: Show disputes filtered by Customize search
	* @return PageReference
	*/
    public PageReference updateFilter() {
        List<String> andStatementList = new List<String>();
        andStatementList.add('AGS_ST_Held_Transaction__c = null');
        if(isSubmitted || isAssigned || isInProgress || isCorrectedPendingSSR || isResolvedWithCorrection || isResolvedNoCorrection) {
            List<String> orStatementList = new List<String>();
            if(isSubmitted) {
            	orStatementList.add('Internal_Status_gne__c = \'Submitted\'');
            }
            if(isAssigned) {
            	orStatementList.add('Internal_Status_gne__c = \'Assigned\'');
            }
            if(isInProgress) {
            	orStatementList.add('Internal_Status_gne__c = \'In Progress\'');
            }
            if(isCorrectedPendingSSR) {
            	orStatementList.add('Internal_Status_gne__c = \'Corrected Pending SSR\'');
            }
            if(isResolvedWithCorrection) {
            	orStatementList.add('Internal_Status_gne__c = \'Resolved With Correction\'');
            }
            if(isResolvedNoCorrection) {
            	orStatementList.add('Internal_Status_gne__c = \'Resolved No Correction\'');
            }
            String orStatement = '';
            for(String orStat : orStatementList) {
            	if(orStatement.equals('')) {
                	orStatement = orStat;
                } else {
            		orStatement += ' OR ' + orStat;
            	}
            }
            andStatementList.add('(' + orStatement + ')');
        }
		String orStatementForCorrectedItems = '(Internal_Status_gne__c = \'Corrected Pending SSR\' OR Internal_Status_gne__c = \'Resolved With Correction\')';
		String orStatementForNotCorrectedItems = '(Internal_Status_gne__c != \'Corrected Pending SSR\' AND Internal_Status_gne__c != \'Resolved With Correction\')';
        if( !String.isBlank(amountFromStr) ) {
            andStatementList.add('Amount_frm_gne__c >= ' + amountFrom);
        }
        if( !String.isBlank(amountToStr) ) {
            andStatementList.add('Amount_frm_gne__c <= ' + amountTo);
        }
        if(!natureOfPaymet.equals('All')) {
            andStatementList.add('Nature_Of_Payment_frm_gne__c = \'' + String.escapeSingleQuotes(natureOfPaymet) + '\'');
        }
        if(!formOfPaymet.equals('All')) {
            andStatementList.add('Form_Of_Payment_frm_gne__c = \'' + String.escapeSingleQuotes(formOfPaymet) + '\'');
        }
        if(!isCmsDispute.equals('All')) {
        	andStatementList.add('Dispute_List_gne__r.IsCmsDispute_gne__c = ' + String.escapeSingleQuotes(isCmsDispute));
        }
        if(!cmsDisputeID.equals('')) {
            andStatementList.add('Dispute_List_gne__r.CmsDisputeId_gne__c LIKE \'' + String.escapeSingleQuotes(cmsDisputeID.trim()).replace('*', '%') + '\'');
        }
        if(!drugName.equals('All')) {
            andStatementList.add('Drug_Name_frm_gne__c LIKE \'%' + String.escapeSingleQuotes(drugName) + '%\'');
        }

		if(!disputeName.equals('')) {
			andStatementList.add('Name = \'' + String.escapeSingleQuotes(disputeName.trim()) + '\'');
		}
		if(!firstName.equals('') && !lastName.equals('')) {
			andStatementList.add('( (AGS_Spend_Expense_Transaction_gne__r.Party1_FirstName_gne__c LIKE \'' + String.escapeSingleQuotes(firstName.trim()).replace('*', '%') + '\' AND AGS_Spend_Expense_Transaction_gne__r.Party1_LastName_gne__c LIKE \'' + String.escapeSingleQuotes(lastName.trim()).replace('*', '%') + '\') OR (AGS_Spend_Expense_Transaction_gne__r.Party2_FirstName_gne__c LIKE \'' + String.escapeSingleQuotes(firstName.trim()).replace('*', '%') + '\' AND AGS_Spend_Expense_Transaction_gne__r.Party2_LastName_gne__c LIKE \'' + String.escapeSingleQuotes(firstName.trim()).replace('*', '%') + '\') )');
		} else if(!firstName.equals('')) {
        	andStatementList.add('(AGS_Spend_Expense_Transaction_gne__r.Party1_FirstName_gne__c LIKE \'' + String.escapeSingleQuotes(firstName.trim()).replace('*', '%') + '\' OR AGS_Spend_Expense_Transaction_gne__r.Party2_FirstName_gne__c LIKE \'' + String.escapeSingleQuotes(firstName.trim()).replace('*', '%') + '\')');
        } else if(!lastName.equals('')) {
        	andStatementList.add('(AGS_Spend_Expense_Transaction_gne__r.Party1_LastName_gne__c LIKE \'' + String.escapeSingleQuotes(lastName.trim()).replace('*', '%') + '\' OR AGS_Spend_Expense_Transaction_gne__r.Party2_LastName_gne__c LIKE \'' + String.escapeSingleQuotes(lastName.trim()).replace('*', '%') + '\')');
        }
        if(!speciality.equals('All')) {
            andStatementList.add('(AGS_Spend_Expense_Transaction_gne__r.Party1_Specialty_gne__c = \'' + String.escapeSingleQuotes(speciality) + '\' OR AGS_Spend_Expense_Transaction_gne__r.Party2_Specialty_gne__c = \'' + String.escapeSingleQuotes(speciality) + '\')');
        }
        if(!state.equals('All')) {
        	andStatementList.add('AGS_Spend_Expense_Transaction_gne__r.Event_State_gne__c = \'' + String.escapeSingleQuotes(state) + '\'');
        }
        if(!resolver.equals('All')) {
        	andStatementList.add('Dispute_Resolver_gne__r.OwnerId = \'' + String.escapeSingleQuotes(resolver) + '\'');
        }
        if(disputeDateFromContainer.Payment_Date_gne__c != null) {
        	andStatementList.add('CreatedDate >= ' + getDisputeDateFromAsDateTime().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        }
        if(disputeDateToContainer.Payment_Date_gne__c != null) {
        	andStatementList.add('CreatedDate < ' + getDisputeDateToAsDateTime().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        }
        if(paymentDateFromContainer.Payment_Date_gne__c != null) {
        	andStatementList.add('AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c >= ' + Datetime.newInstance(paymentDateFromContainer.Payment_Date_gne__c, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd'));
        }
        if(paymentDateToContainer.Payment_Date_gne__c != null) {
        	andStatementList.add('AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c <= ' + Datetime.newInstance(paymentDateToContainer.Payment_Date_gne__c, Time.newInstance(23,59,59,0)).format('yyyy-MM-dd'));
        }

        String whereStatement = '';
        for(String andStat : andStatementList) {
            if(whereStatement.equals('')) {
                whereStatement = andStat;
            } else {
                whereStatement += ' AND ' + andStat;
            }
        }
        if(!whereStatement.equals('')) {
        	whereStatement = ' WHERE ' + whereStatement;
        }
        soqlWhereStatement = whereStatement;
        setDisputesValues(true);
        return null;
    }


	/** @date 03/12/2013
	* @Author Piotr Skowroński
	* @description Save filter criteria: save all filter criteria selected by user
	* @return PageReference
	*/
    public PageReference saveAsANewFilter(){
    	AGS_ST_SearchFilter_gne__c sFilter = new AGS_ST_SearchFilter_gne__c();
    	filterName = ApexPages.currentPage().getParameters().get('namefilter');
    	if(filterName != null && filterName != ''){
	    	sFilter.Name = filterName;
	    	AGS_ST_SearchFilter_gne__c isExist;
	    	try {
	    	    isExist = [SELECT Name FROM AGS_ST_SearchFilter_gne__c WHERE Name = :filterName];
	    	} catch(QueryException qe) {
	    		isExist = null;
	    	}
	    	if(isExist != null) {
	    		return null;
	    	}
	        if(isSubmitted == true && sFilter.Status__c == null){
	    		sFilter.Status__c = 'Submitted';
	    	}else if(isSubmitted == true && sFilter.Status__c != null){
	    		sFilter.Status__c += ';Submitted';
	        }
	        if(isAssigned == true && sFilter.Status__c == null){
	    		sFilter.Status__c = 'Assigned';
	    	}else if(isAssigned == true && sFilter.Status__c != null){
	    		sFilter.Status__c += ';Assigned';
	        }
	        if(isInProgress == true && sFilter.Status__c == null){
	    		sFilter.Status__c = 'In Progress';
	    	}else if(isInProgress == true && sFilter.Status__c != null){
	    		sFilter.Status__c += ';In Progress';
	        }
	        if(isCorrectedPendingSSR == true && sFilter.Status__c == null){
	    		sFilter.Status__c = 'Corrected Pending SSR';
	    	}else if(isCorrectedPendingSSR == true && sFilter.Status__c != null){
	    		sFilter.Status__c += ';Corrected Pending SSR';
	        }
	        if(isResolvedWithCorrection == true && sFilter.Status__c == null){
	    		sFilter.Status__c = 'Resolved With Correction';
	    	}else if(isResolvedWithCorrection == true && sFilter.Status__c != null){
	    		sFilter.Status__c += ';Resolved With Correction';
	        }
	        if(isResolvedNoCorrection == true && sFilter.Status__c == null){
	    		sFilter.Status__c = 'Resolved No Correction';
	    	}else if(isResolvedNoCorrection == true && sFilter.Status__c != null){
	    		sFilter.Status__c += ';Resolved No Correction';
	        }
            try {
                if(amountFromStr != null) {
                    sFilter.Amount_From__c = Decimal.valueOf(amountFromStr);
                } else {
                    sFilter.Amount_From__c = null;
                }
            } catch(TypeException te) {
                sFilter.Amount_From__c = null;
            }
            try {
                if(amountToStr != null) {
                    sFilter.Amount_To__c = Decimal.valueOf(amountToStr);
                } else {
                    sFilter.Amount_To__c = null;
                }
            } catch(TypeException te) {
                sFilter.Amount_To__c = null;
            }
			sFilter.Nature_of_Payment__c = natureOfPaymet;
			sFilter.Form_of_Payment__c = formOfPaymet;
			sFilter.IsCmsDispute_gne__c = isCmsDispute;
            sFilter.CmsDisputeId_gne__c = cmsDisputeID;
			sFilter.Drug_Name__c = drugName;
			sFilter.Dispute_Name__c = disputeName;
	    	sFilter.Physician_First_Name__c = firstName;
	    	sFilter.Physician_Last_Name__c = lastName;
			sFilter.State__c = state;
			sFilter.Speciality__c = speciality;
			sFilter.Resolver__c = resolver;
	    	sFilter.Dispute_Date_From__c = disputeDateFromContainer.Payment_Date_gne__c;
	    	sFilter.Dispute_Date_To__c = disputeDateToContainer.Payment_Date_gne__c;
	    	sFilter.Date_of_Payment_From__c = paymentDateFromContainer.Payment_Date_gne__c;
	    	sFilter.Date_of_Payment_To__c = paymentDateToContainer.Payment_Date_gne__c;
	        insert sFilter;
	 	 	selectedFilterName = filterName;
	 	 	savedFilters = new List<SelectOption>();
	 	 	savedFilters.add(new SelectOption('All', 'All'));
	 	 	List<AGS_ST_SearchFilter_gne__c> listFilters = [SELECT Name FROM AGS_ST_SearchFilter_gne__c];
	 	 	for(AGS_ST_SearchFilter_gne__c filter : listFilters){
	 	 		savedFilters.add(new SelectOption(filter.Name, filter.Name));
	 	 	}
	 	 	loadFilter();
    	}
    	return null;
    }

	/** @date 03/12/2013
	* @Author Piotr Skowroński
	* @description Save filter criteria: update saved filter criteria with values selected by user
	* @return PageReference
	*/
    public PageReference SaveFilter(){
    	AGS_ST_SearchFilter_gne__c sFilter = [SELECT Name, Amount_From__c, Amount_To__c, Date_of_Payment_From__c, Date_of_Payment_To__c, Dispute_Date_From__c, Dispute_Date_To__c, Dispute_Name__c, Drug_Name__c, Form_of_Payment__c, Nature_of_Payment__c, IsCmsDispute_gne__c, CmsDisputeId_gne__c, Physician_First_Name__c, Physician_Last_Name__c, Resolver__c, Speciality__c, State__c, Status__c, Id FROM AGS_ST_SearchFilter_gne__c WHERE Name = :selectedFilterName];
    	sFilter.Status__c = null;
        if(isSubmitted == true && sFilter.Status__c == null){
    		sFilter.Status__c = 'Submitted';
    	}else if(isSubmitted == true && sFilter.Status__c != null){
    		sFilter.Status__c += ';Submitted';
        }
        if(isAssigned == true && sFilter.Status__c == null){
    		sFilter.Status__c = 'Assigned';
    	}else if(isAssigned == true && sFilter.Status__c != null){
    		sFilter.Status__c += ';Assigned';
        }
        if(isInProgress == true && sFilter.Status__c == null){
    		sFilter.Status__c = 'In Progress';
    	}else if(isInProgress == true && sFilter.Status__c != null){
    		sFilter.Status__c += ';In Progress';
        }
        if(isCorrectedPendingSSR == true && sFilter.Status__c == null){
    		sFilter.Status__c = 'Corrected Pending SSR';
    	}else if(isCorrectedPendingSSR == true && sFilter.Status__c != null){
    		sFilter.Status__c += ';Corrected Pending SSR';
        }
        if(isResolvedWithCorrection == true && sFilter.Status__c == null){
    		sFilter.Status__c = 'Resolved With Correction';
    	}else if(isResolvedWithCorrection == true && sFilter.Status__c != null){
    		sFilter.Status__c += ';Resolved With Correction';
        }
        if(isResolvedNoCorrection == true && sFilter.Status__c == null){
    		sFilter.Status__c = 'Resolved No Correction';
    	}else if(isResolvedNoCorrection == true && sFilter.Status__c != null){
    		sFilter.Status__c += ';Resolved No Correction';
        }
        try {
            if(amountFromStr != null) {
                sFilter.Amount_From__c = Decimal.valueOf(amountFromStr);
            } else {
                sFilter.Amount_From__c = null;
            }
        } catch(TypeException te) {
            sFilter.Amount_From__c = null;
        }
        try {
            if(amountToStr != null) {
                sFilter.Amount_To__c = Decimal.valueOf(amountToStr);
            } else {
                sFilter.Amount_To__c = null;
            }
        } catch(TypeException te) {
            sFilter.Amount_To__c = null;
        }
    	sFilter.Nature_of_Payment__c = natureOfPaymet;
    	sFilter.Form_of_Payment__c = formOfPaymet;
    	sFilter.IsCmsDispute_gne__c = isCmsDispute;
        sFilter.CmsDisputeId_gne__c = cmsDisputeID;
    	sFilter.Drug_Name__c = drugName;
		sFilter.Dispute_Name__c = disputeName;
    	sFilter.Physician_First_Name__c = firstName;
    	sFilter.Physician_Last_Name__c = lastName;
    	sFilter.State__c = state;
    	sFilter.Speciality__c = speciality;
    	sFilter.Resolver__c = resolver;
        if(disputeDateFromContainer.Payment_Date_gne__c != null) {
        	sFilter.Dispute_Date_From__c = disputeDateFromContainer.Payment_Date_gne__c;
        }
        if(disputeDateToContainer.Payment_Date_gne__c != null) {
        	sFilter.Dispute_Date_To__c = disputeDateToContainer.Payment_Date_gne__c;
        }
        if(paymentDateFromContainer.Payment_Date_gne__c != null) {
        	sFilter.Date_of_Payment_From__c = paymentDateFromContainer.Payment_Date_gne__c;
        }
        if(paymentDateToContainer.Payment_Date_gne__c != null) {
        	sFilter.Date_of_Payment_To__c = paymentDateToContainer.Payment_Date_gne__c;
        }
    	update sFilter;
    	return ApexPages.currentPage();
    }

	/** @date 03/12/2013
	* @Author Piotr Skowroński
	* @description Remove filter criteria: delete save filter in db
	* @return PageReference
	*/
    public PageReference RemoveFilter(){
    	if(selectedFilterName != 'All'){
    		List<AGS_ST_SearchFilter_gne__c> sFilter = [SELECT Name, Id FROM AGS_ST_SearchFilter_gne__c WHERE Name = :selectedFilterName];
    		delete sFilter;
    	}
    	clearFilterList();
    	selectedFilterName = 'All';
    	getSavedFilters();
    	loadFilter();
    	return null;
    }

	/** @date 03/12/2013
	* @Author Piotr Skowroński
	* @description Select filter criteria: build picklist from saved filters
	* @return PageReference
	*/
 	public List<SelectOption> getSavedFilters(){
 	 	savedFilters = new List<SelectOption>();
 	 	savedFilters.add(new SelectOption('All', 'All'));
 	 	List<AGS_ST_SearchFilter_gne__c> listFilters = [SELECT Name FROM AGS_ST_SearchFilter_gne__c order by Name asc];
 	 	for(AGS_ST_SearchFilter_gne__c filter : listFilters){
 	 		savedFilters.add(new SelectOption(filter.Name, filter.Name));
 	 	}
 	 	return savedFilters;
  	}

	/** @date 03/12/2013
	* @Author Piotr Skowroński
	* @description Save filter criteria: update saved filter criteria with values selected by user
	* @return PageReference
	*/
    public PageReference loadFilter(){
    	if(selectedFilterName != null && selectedFilterName != 'All'){
	    	AGS_ST_SearchFilter_gne__c sFilter = [SELECT Name, Amount_From__c, Amount_To__c, Date_of_Payment_From__c, Date_of_Payment_To__c, Dispute_Date_From__c, Dispute_Date_To__c, Dispute_Name__c, Drug_Name__c, Form_of_Payment__c, Nature_of_Payment__c, IsCmsDispute_gne__c, CmsDisputeId_gne__c, Physician_First_Name__c, Physician_Last_Name__c, Resolver__c, Speciality__c, State__c, Status__c, Id FROM AGS_ST_SearchFilter_gne__c WHERE Name = :selectedFilterName];
	        isSubmitted = false;
	        isAssigned = false;
	        isInProgress = false;
	        isCorrectedPendingSSR = false;
	        isResolvedWithCorrection = false;
	        isResolvedNoCorrection = false;
	    	drugName = '';
			disputeName = '';
	    	firstName = '';
	    	lastName = '';
	    	if(sFilter.Status__c != null && sFilter.Status__c != ''){
		        if(sFilter.Status__c.containsIgnoreCase('Submitted')) isSubmitted = true;
		        if(sFilter.Status__c.containsIgnoreCase('Assigned')) isAssigned = true;
		        if(sFilter.Status__c.containsIgnoreCase('In Progress')) isInProgress = true;
		        if(sFilter.Status__c.containsIgnoreCase('Corrected Pending SSR')) isCorrectedPendingSSR = true;
		        if(sFilter.Status__c.containsIgnoreCase('Resolved With Correction')) isResolvedWithCorrection = true;
		        if(sFilter.Status__c.containsIgnoreCase('Resolved No Correction')) isResolvedNoCorrection = true;
	    	}
	       	amountFrom = sFilter.Amount_From__c;
	       	amountFromStr = String.valueOf(sFilter.Amount_From__c);
	       	amountTo = sFilter.Amount_To__c;
	       	amountToStr = String.valueOf(sFilter.Amount_To__c);
	    	natureOfPaymet = sFilter.Nature_of_Payment__c;
	    	formOfPaymet = sFilter.Form_of_Payment__c;
	    	isCmsDispute = sFilter.IsCmsDispute_gne__c;
	    	if(String.isBlank(isCmsDispute)) {
	    		isCmsDispute = 'All';
	    	}
            cmsDisputeID = ( String.isBlank(sFilter.CmsDisputeId_gne__c) ? '' : sFilter.CmsDisputeId_gne__c );
	    	drugName = sFilter.Drug_Name__c;
			if(sFilter.Dispute_Name__c != null) disputeName = sFilter.Dispute_Name__c;
	    	if(sFilter.Physician_First_Name__c != null) firstName = sFilter.Physician_First_Name__c;
	    	if(sFilter.Physician_Last_Name__c != null) lastName = sFilter.Physician_Last_Name__c;
	    	state = sFilter.State__c;
	    	speciality = sFilter.Speciality__c;
	    	resolver = sFilter.Resolver__c;
	    	disputeDateFromContainer.Payment_Date_gne__c = sFilter.Dispute_Date_From__c;
	    	disputeDateToContainer.Payment_Date_gne__c = sFilter.Dispute_Date_To__c;
	    	paymentDateFromContainer.Payment_Date_gne__c = sFilter.Date_of_Payment_From__c;
	    	paymentDateToContainer.Payment_Date_gne__c = sFilter.Date_of_Payment_To__c;
    	}else if(selectedFilterName == 'All'){
			clearFilterList();
    	}
    	updateFilter();
    	return null;
    }

	/** @date 03/15/2013
	* @Author Piotr Skowroński
	* @descriptionClean filter criteria: clean all selected filter criteria
	* @return PageReference
	*/
    public void clearFilterList(){
        isSubmitted = false;
        isAssigned = false;
        isInProgress = false;
        isCorrectedPendingSSR = false;
        isResolvedWithCorrection = false;
        isResolvedNoCorrection = false;
       	amountFromStr = '';
       	amountToStr = '';
    	natureOfPaymet = 'All';
    	formOfPaymet = 'All';
    	isCmsDispute = 'All';
        cmsDisputeID = '';
    	drugName = 'All';
		disputeName = '';
    	firstName = '';
    	lastName = '';
    	state = 'All';
    	speciality = 'All';
    	resolver = 'All';
    	disputeDateFromContainer = new AGS_ST_DisputeManagement_gne__c();
    	disputeDateToContainer = new AGS_ST_DisputeManagement_gne__c();
    	paymentDateFromContainer = new AGS_ST_DisputeManagement_gne__c();
    	paymentDateToContainer = new AGS_ST_DisputeManagement_gne__c();
    }
}