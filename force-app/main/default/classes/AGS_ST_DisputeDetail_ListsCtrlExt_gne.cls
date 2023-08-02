/** @date 1/2/2013
* @Author Pawel Sprysak
* @description Controller Extension - handling "All Disputes for this Physician to date" and "Other Disputes for this Event" sections 
*/
public without sharing class AGS_ST_DisputeDetail_ListsCtrlExt_gne {
	private AGS_ST_DisputeManagement_gne__c disputeMgmtObj;
    // Variables for "All Disputes for this Physician to date" section
    private transient ApexPages.StandardSetController physicianDisputeSSC { get; set; }
    public AGS_ST_DMPagingAndSortingUtils physicianDisputeUtil { get; set; }
    // Variables for "Other Disputes for this Event" section
    private transient ApexPages.StandardSetController otherDisputeSSC { get; set; }
    public AGS_ST_DMPagingAndSortingUtils otherDisputeUtil { get; set; }
    // Collision lists
    public AGS_ST_DMPagingAndSortingUtils disputeCollisionUtil { get; set; }
    public AGS_ST_DMPagingAndSortingUtils otherDisputeCollisionUtil { get; set; }
    // Flags
    public Boolean reloadPhysicianDisputes { get; set; }
    public Boolean reloadOtherDisputes { get; set; }

	/** @date 1/2/2013
	* @Author Pawel Sprysak
	* @description Constructor for Controller Extension 
	* @param ApexPages.StandardController controller
	*/
    public AGS_ST_DisputeDetail_ListsCtrlExt_gne(ApexPages.StandardController controller) {
        disputeMgmtObj = (AGS_ST_DisputeManagement_gne__c) controller.getRecord();
        // Reload Page flags
        reloadPhysicianDisputes = false;
        reloadOtherDisputes = false;
        // Collision lists
        disputeCollisionUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        disputeCollisionUtil.duplicateValues();
        otherDisputeCollisionUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        otherDisputeCollisionUtil.duplicateValues();
        // Init for "All Disputes for this Physician to date" section
        physicianDisputeUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        setPhysicianDisputesValues(true);
        // Init for "Other Disputes for this Event" section
        otherDisputeUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        setOtherDisputesValues(true);
    }

	/** @date 1/2/2013
	* @Author Pawel Sprysak
	* @description Getter for VF - All Disputes for this Physician to date 
	* @return List<AGS_ST_DMPagingAndSortingUtils.Dispute>
	*/
    public List<AGS_ST_DMPagingAndSortingUtils.Dispute> getPhysicianDispute() {
        setPhysicianDisputesValues(false);
        reloadPhysicianDisputes = false;
        return physicianDisputeUtil.disputeTransientList;
    }

	/** @date 1/2/2013
	* @Author Pawel Sprysak
	* @description All Disputes for this Physician to date -> Method for setting list 
	* @param Boolean initValue
	*/
    public void setPhysicianDisputesValues(Boolean initValue) {
        if(initValue || !physicianDisputeUtil.compareValues() || reloadPhysicianDisputes) {
            physicianDisputeSSC = new ApexPages.StandardSetController(AGS_ST_DbUtils.getDisputesIdsByPhysicianId(disputeMgmtObj.Dispute_List_gne__r.OwnerId, physicianDisputeUtil.sortField, physicianDisputeUtil.sortOrder));
        	physicianDisputeUtil.createDMList(physicianDisputeSSC);
        	physicianDisputeSSC = null;
        	List<Id> idList = physicianDisputeUtil.getDisputeIdList();
            physicianDisputeUtil.disputeTransientList.clear();
            for(AGS_ST_DisputeManagement_gne__c dm : AGS_ST_DbUtils.getDisputeDetailListByIdList2(idList)) {
                physicianDisputeUtil.disputeTransientList.add(new AGS_ST_DMPagingAndSortingUtils.Dispute(dm));
            }
            if(physicianDisputeUtil.sortField!=null && !physicianDisputeUtil.sortField.equals('')) {
            	SuperSort.sortList(physicianDisputeUtil.disputeTransientList, physicianDisputeUtil.sortField, physicianDisputeUtil.sortOrder);
            }
			idList = null;
            physicianDisputeUtil.duplicateValues();
			// Filling collision list
            if(initValue || reloadPhysicianDisputes) {
            	disputeCollisionUtil.actualPage = physicianDisputeUtil.actualPage;
            	disputeCollisionUtil.perPage = physicianDisputeUtil.perPage;
            	disputeCollisionUtil.setParameters(physicianDisputeUtil.totalDisputes);
            	disputeCollisionUtil.duplicateValues();
            	disputeCollisionUtil.disputeTransientList = physicianDisputeUtil.disputeTransientList.clone();
            }
        }
    }

	/** @date 1/2/2013
	* @Author Pawel Sprysak
	* @description Getter for VF - Modal window - All Disputes for this Physician to date 
	* @return List<AGS_ST_DMPagingAndSortingUtils.Dispute>
	*/
    public List<AGS_ST_DMPagingAndSortingUtils.Dispute> getModalPhysicianDispute() {
        setModalPhysicianDisputesValues();
        return disputeCollisionUtil.disputeTransientList;
    }

	/** @date 1/2/2013
	* @Author Pawel Sprysak
	* @description All Disputes for this Physician to date -> Method for setting list 
	*/
    public void setModalPhysicianDisputesValues() {
        if(!disputeCollisionUtil.compareValues()) {
            physicianDisputeSSC = new ApexPages.StandardSetController(AGS_ST_DbUtils.getDisputesIdsByPhysicianId(disputeMgmtObj.Dispute_List_gne__r.OwnerId, disputeCollisionUtil.sortField, disputeCollisionUtil.sortOrder));
        	disputeCollisionUtil.createDMList(physicianDisputeSSC);
        	physicianDisputeSSC = null;
        	List<Id> idList = disputeCollisionUtil.getDisputeIdList();
            disputeCollisionUtil.disputeTransientList.clear();
            for(AGS_ST_DisputeManagement_gne__c dm : AGS_ST_DbUtils.getDisputeDetailListByIdList2(idList)) {
                disputeCollisionUtil.disputeTransientList.add(new AGS_ST_DMPagingAndSortingUtils.Dispute(dm));
            }
            if(disputeCollisionUtil.sortField!=null && !disputeCollisionUtil.sortField.equals('')) {
            	SuperSort.sortList(disputeCollisionUtil.disputeTransientList, disputeCollisionUtil.sortField, disputeCollisionUtil.sortOrder);
            }
			idList = null;
            disputeCollisionUtil.duplicateValues();
        }
    }

	/** @date 1/2/2013
	* @Author Pawel Sprysak
	* @description Getter for VF - Other Disputes for this Event 
	* @return List<AGS_ST_DMPagingAndSortingUtils.Dispute>
	*/
    public List<AGS_ST_DMPagingAndSortingUtils.Dispute> getOtherDisputes() {
        setOtherDisputesValues(false);
        reloadOtherDisputes = false;
        return otherDisputeUtil.disputeTransientList;
    }

	/** @date 1/2/2013
	* @Author Pawel Sprysak
	* @description Other Disputes for this Event -> Method for setting list 
	* @param Boolean initValue
	*/
    public void setOtherDisputesValues(Boolean initValue) {
    	System.debug('----------- initValue otherDisputeUtil.compareValues() reloadOtherDisputes' + initValue + ' ' +otherDisputeUtil.compareValues()+ ' '+ reloadOtherDisputes);
    	
        if(initValue || !otherDisputeUtil.compareValues() || reloadOtherDisputes) {
        	String eventId = disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Unique_Transaction_Id_gne__c;
        	System.debug('----------- eventId, disputeMgmtObj.Dispute_List_gne__r.OwnerId, otherDisputeUtil.sortField, otherDisputeUtil.sortOrder' + eventId +' '+disputeMgmtObj.Dispute_List_gne__r.OwnerId+' '+ otherDisputeUtil.sortField +' '+otherDisputeUtil.sortOrder);
        	otherDisputeSSC = new ApexPages.StandardSetController(AGS_ST_DbUtils.getDisputesIdsByEventAndPhysicianId(eventId, disputeMgmtObj.Dispute_List_gne__r.OwnerId, otherDisputeUtil.sortField, otherDisputeUtil.sortOrder));
        	System.debug('----------- otherDisputeSSC.getRecords() ' + otherDisputeSSC.getRecords());
        	System.debug('----------- otherDisputeSSC.getRecords().size() ' + otherDisputeSSC.getRecords().size());
    	
        	otherDisputeUtil.createDMList(otherDisputeSSC);
        	otherDisputeSSC = null;
        	List<Id> idList = otherDisputeUtil.getDisputeIdList();
        	otherDisputeUtil.disputeTransientList.clear();
            for(AGS_ST_DisputeManagement_gne__c dm : AGS_ST_DbUtils.getDisputeDetailListByIdList2(idList)) {
                otherDisputeUtil.disputeTransientList.add(new AGS_ST_DMPagingAndSortingUtils.Dispute(dm));
            }
            System.debug('----------- otherDisputeUtil.disputeTransientList ' + otherDisputeUtil.disputeTransientList);
    		System.debug('----------- otherDisputeUtil.disputeTransientList.size() ' + otherDisputeUtil.disputeTransientList.size());
    	
            if(otherDisputeUtil.sortField!=null && !otherDisputeUtil.sortField.equals('')) {
            	SuperSort.sortList(otherDisputeUtil.disputeTransientList, otherDisputeUtil.sortField, otherDisputeUtil.sortOrder);
            }
			idList = null;
            otherDisputeUtil.duplicateValues();
			// Filling collision list
            if(initValue || reloadOtherDisputes) {
            	otherDisputeCollisionUtil.actualPage = otherDisputeUtil.actualPage;
            	otherDisputeCollisionUtil.perPage = otherDisputeUtil.perPage;
            	otherDisputeCollisionUtil.setParameters(otherDisputeUtil.totalDisputes);
            	otherDisputeCollisionUtil.duplicateValues();
            	otherDisputeCollisionUtil.disputeTransientList = otherDisputeUtil.disputeTransientList.clone();
            }
        }
    }

	/** @date 1/2/2013
	* @Author Pawel Sprysak
	* @description Getter for VF - Modal window - Other Disputes for this Event 
	* @return List<AGS_ST_DMPagingAndSortingUtils.Dispute>
	*/
    public List<AGS_ST_DMPagingAndSortingUtils.Dispute> getModalOtherDisputes() {
        setModalOtherDisputesValues();
        return otherDisputeCollisionUtil.disputeTransientList;
    }

	/** @date 1/2/2013
	* @Author Pawel Sprysak
	* @description Modal window - Other Disputes for this Event -> Method for setting list 
	*/
    public void setModalOtherDisputesValues() {
        if(!otherDisputeCollisionUtil.compareValues()) {
        	String eventId = disputeMgmtObj.AGS_Spend_Expense_Transaction_gne__r.Unique_Transaction_Id_gne__c;
        	otherDisputeSSC = new ApexPages.StandardSetController(AGS_ST_DbUtils.getDisputesIdsByEventAndPhysicianId(eventId, disputeMgmtObj.Dispute_List_gne__r.OwnerId, otherDisputeCollisionUtil.sortField, otherDisputeCollisionUtil.sortOrder));
        	otherDisputeCollisionUtil.createDMList(otherDisputeSSC);
        	otherDisputeSSC = null;
        	List<Id> idList = otherDisputeCollisionUtil.getDisputeIdList();
        	otherDisputeCollisionUtil.disputeTransientList.clear();
            for(AGS_ST_DisputeManagement_gne__c dm : AGS_ST_DbUtils.getDisputeDetailListByIdList2(idList)) {
                otherDisputeCollisionUtil.disputeTransientList.add(new AGS_ST_DMPagingAndSortingUtils.Dispute(dm));
            }
            if(otherDisputeCollisionUtil.sortField!=null && !otherDisputeCollisionUtil.sortField.equals('')) {
            	SuperSort.sortList(otherDisputeCollisionUtil.disputeTransientList, otherDisputeCollisionUtil.sortField, otherDisputeCollisionUtil.sortOrder);
            }
			idList = null;
            otherDisputeCollisionUtil.duplicateValues();
        }
    }
}