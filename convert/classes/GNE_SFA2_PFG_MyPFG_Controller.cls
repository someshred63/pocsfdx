public with sharing class GNE_SFA2_PFG_MyPFG_Controller extends GNE_SFA2_PFG_Base_Controller {
	public String title {get; private set;}
	public String userRole {get; private set;}
	public Boolean isDebugMode {get; private set;}

	public String csDtpPfgToTerritoryDetailsListTitle {get { return System.Label.GNE_SFA2_PFG_MY_DTP_ALLOCATIONS_TITLE; }}
	public String csHcTransfersListTitle {get { return System.Label.GNE_SFA2_PFG_MY_HC_TRANSFERS_TO_CONFIRM_TITLE; }}
	public String csLotsListTitle {get { return System.Label.GNE_SFA2_PFG_MY_HC_ACTIVE_LOTS_TITLE; }}
	public String csStorageLocationTitle {get { return System.Label.GNE_SFA2_PFG_MY_STORAGE_LOCATION_TITLE; }}

	public PageBlockTableEngine csStorageLocationListEngine {get; private set;}
	public PageBlockTableEngine dmStorageLocationListEngine {get; private set;}
	public PageBlockTableEngine csHcTransfersListEngine {get; private set;}

	public SFA2_PFG_Storage_Location_gne__c csStorageLocation;
	public DateTime csStorageLocationApprovalDate;
	private Id currentUserId;

	public GNE_SFA2_PFG_MyPFG_Controller() {
		title = System.Label.GNE_SFA2_PFG_MAIN_PAGE_NAME;
		currentUserId = UserInfo.getUserId();
		String debugMode = ApexPages.currentPage().getParameters().get('debugMode');
		isDebugMode = new Set<String>{'yes', '1', 'true'}.contains((debugMode!=null ? debugMode : '').ToLowerCase());

		csHcTransfersListEngine = new PageBlockTableEngine(this);
		csStorageLocationListEngine = new PageBlockTableEngine(this);
		dmStorageLocationListEngine = new PageBlockTableEngine(this);
	}

	protected override PageReference intInitCotroller() {
		setUserRole();
		return null;
	}

	public void setUserRole() {
		GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
		if(userApplicationContext!=null) {
			userRole = userApplicationContext.Role_gne__c;
		}

		if(userRole==null) {
			throw new InitPage_Exception(System.Label.GNE_SFA2_PFG_ROLE_NOT_DEFINED);
		}
	}

	public PageReference redirectTo(PageReference pageRef) {
		return redirectTo(pageRef, new Map<String,String>());
	}

	public PageReference redirectTo(PageReference pageRef, Map<String, String> parameters) {
		pageRef.setRedirect(true);
		Map<String,String> params = pageRef.getParameters();
		params.putAll(parameters);

		if(!params.containsKey('retURL')) {
			params.put('retURL', Page.GNE_SFA2_PFG_MyPFG.getUrl());
		}

		return pageRef;
	}

	private String getCreatePageUrl(Schema.sObjectType objType) {
		return '/' + objType.getDescribe().getKeyPrefix() + '/e';
	}

	public PageReference viewTransactions() {
		return redirectTo(Page.GNE_SFA2_PFG_View_Transactions_Layout);
	}

	public PageReference viewReports() {
		return redirectTo(Page.GNE_SFA2_PFG_Report_Filters);
	}

	public PageReference newAllocationTransfer() {
		return redirectTo(new PageReference(getCreatePageUrl(SFA2_PFG_Transaction_gne__c.getSobjectType())),
			new Map<String, String>{
				'transactionType' => GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER
			});
	}

	public PageReference allocateDtpInventory() {
		return redirectTo(Page.GNE_SFA2_PFG_Inventory_Allocation,
			new Map<String, String>{
				'type' => GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP
			});
	}

	public String getDetailedReportURL() {
		return GNE_SFA2_PFG_Config.DETAILED_REPORTS_LINK;
	}

	public String getStatusReportURL() {
		return GNE_SFA2_PFG_Config.STATUS_REPORT_LINK;
	}

	public PageReference newAdjustment() {
		return redirectTo(new PageReference(getCreatePageUrl(SFA2_PFG_Transaction_gne__c.getSobjectType())),
			new Map<String, String>{
				'transactionType' => GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT
			});
	}

	public PageReference newReturn() {
		return redirectTo(new PageReference(getCreatePageUrl(SFA2_PFG_Transaction_gne__c.getSobjectType())),
			new Map<String, String>{
				'transactionType' => GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN
			});
	}

	public PageReference newTransfer() {
		return redirectTo(new PageReference(getCreatePageUrl(SFA2_PFG_Transaction_gne__c.getSobjectType())),
			new Map<String, String>{
				'transactionType' => GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER
			});
	}

	public PageReference countMyInventory() {
		return redirectTo(new PageReference(getCreatePageUrl(SFA2_PFG_Inventory_Count_gne__c.getSobjectType())));
	}
	public PageReference detailedPIReport() {
		return redirectTo(Page.GNE_SFA2_PFG_IC_ListView);
	}
	public PageReference printInventoryWorksheet() {
		return redirectTo(Page.GNE_SFA2_PFG_PrintProductsFromSL);
	}
	public PageReference allocateHcInventory() {
		return redirectTo(Page.GNE_SFA2_PFG_Inventory_Allocation,
			new Map<String, String>{
				'type' => GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC
			});
	}
	public PageReference viewPfgRequests() {
		return redirectTo(Page.GNE_SFA2_PFG_ViewRequests);
	}
	public PageReference requestAdditionalPfg() {
		return redirectTo(new PageReference(getCreatePageUrl(SFA2_PFG_Transaction_gne__c.getSobjectType())),
			new Map<String, String>{
				'transactionType' => GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER
			});
	}
	public PageReference viewAllocatedInventory() {
		return redirectTo(Page.GNE_SFA2_PFG_Inventory_Allocations_View);
	}
	public PageReference openPfgRequests() {
		return redirectTo(Page.GNE_SFA2_PFG_ViewRequests);
	}
	public PageReference storageLocationsListView() {
		return redirectTo(Page.GNE_SFA2_PFG_SL_View,
			new Map<String, String>{
				'type' => GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC
			});
	}
	public PageReference blockCs() {
		return redirectTo(Page.GNE_SFA2_PFG_UpdSalesRepCertStatus);
	}
	public PageReference setQuantityLimits() {
		return redirectTo(Page.GNE_SFA2_PFG_QuantityLimitForHCP);
	}

	public List<SFA2_PFG_to_Territory_Detail_gne__c> getCsDtpPfgToTerritoryDetails() {
		Set<String> terrNames = new Set<String>();
		String currentTerrName = GNE_SFA2_Interaction_Util.selectInteractionTerritory();

		for(Territory2 terr : GNE_SFA2_PFG_Util.getTerritoriesForUser(currentUserId)) {
			if(terr.Name == currentTerrName) {
				terrNames.add(terr.Name);
			}
		}
		return GNE_SFA2_PFG_DAO.getPFGtoTerritoryDetailsByTerritoryName(terrNames, new Set<Integer>{GNE_SFA2_PFG_Util.getYear()});
	}

	public List<SFA2_PFG_Inventory_Count_gne__c> getCsInventoryCounts() {
		List<SFA2_PFG_Inventory_Count_gne__c> result = new List<SFA2_PFG_Inventory_Count_gne__c>();

		for(SFA2_PFG_Inventory_Count_gne__c ic : GNE_SFA2_PFG_DAO.getInventoryCountsForUsers(new Set<Id>{currentUserId})) {
			result.add(ic);
			break;
		}

		return result;
	}

	public List<SFA2_PFG_Transaction_gne__c> getCsHcTransfers() {
		return GNE_SFA2_PFG_DAO.getTransactions(
			new Set<String>{
				GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER,
				GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER,
				GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER
				},
			null,
			new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
				new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_Is_CS_Flag_gne__c', '=', true),
				new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Shipped_Quantity_gne__c', '>', 0),
				new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Status_gne__c', 'IN', new Set<String>{
					GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED,
					GNE_SFA2_PFG_Util.TRANSACTION_STATUS_APPROVED}),
				new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_gne__c', '=', currentUserId),
				new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Distribution_Method_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC)
			},
			new List<String>{
				'Product_gne__r.Name asc'
			});
	}

	public List<SFA2_PFG_to_User_Detail_gne__c> getCsHcLots() {
		List<SFA2_PFG_to_User_Detail_gne__c> result = new List<SFA2_PFG_to_User_Detail_gne__c>();

		for(SFA2_PFG_to_User_Detail_gne__c uDetail : GNE_SFA2_PFG_DAO.getPFGToUserDetailsForUsers(
				new Set<Id>{currentUserId},
				new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC})) {
			if(uDetail.Qty_Total_Available_gne__c > 0) {
				result.add(uDetail);
			}
		}

		return result;
	}

	public List<SFA2_PFG_Storage_Location_gne__c> getCsStorageLocation() {
		if(csStorageLocation==null) {
			for(SFA2_PFG_Storage_Location_gne__c sl : GNE_SFA2_PFG_DAO.getStorageLocationsByUserIds(new Set<Id>{currentUserId})) {
				if(sl.Status_gne__c == GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_APPROVED) {
					csStorageLocation = sl;
					break;
				} else if(csStorageLocation==null) {
					csStorageLocation = sl;
				}
			}

			if(csStorageLocation!=null) {
				List<ProcessInstance> piList = GNE_SFA2_PFG_Util.getApprovalProcesses(new Set<Id>{csStorageLocation.Id}).get(csStorageLocation.Id);
				ProcessInstance pi = (piList!=null && !piList.isEmpty()) ? piList[0] : null;
				ProcessInstanceStep pis = (pi!=null && pi.Steps!=null && !pi.Steps.isEmpty()) ? pi.Steps[0] : null;

				if(pis!=null && pi.Status == GNE_SFA2_PFG_Util.PROCESS_STATUS_APPROVED) {
					csStorageLocationApprovalDate = pis.CreatedDate;
				}
			}
		}

		return (csStorageLocation!=null ? new List<SFA2_PFG_Storage_Location_gne__c>{csStorageLocation} : new List<SFA2_PFG_Storage_Location_gne__c>());
	}

	public PageReference csCreateOrEditSL(){
		return (csStorageLocation!=null
			? redirectTo(new ApexPages.StandardController(csStorageLocation).edit())
			: redirectTo(new PageReference(getCreatePageUrl(SFA2_PFG_Storage_Location_gne__c.getSobjectType()))));
	}

	public List<SFA2_PFG_Storage_Location_gne__c> getDmStorageLocations() {
		return GNE_SFA2_PFG_DAO.getStorageLocationsByManagerIds(
			new Set<Id>{currentUserId},
			new Set<String>{GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED});
	}

	public PageReference dmApproveSL() {
		return approveOrRejectSelected(true);
	}

	public PageReference dmRejectSL() {
		return approveOrRejectSelected(false);
	}

	private PageReference approveOrRejectSelected(Boolean approveOrReject) {
    	PageReference result = null;
    	Set<Id> slIds = dmStorageLocationListEngine.getSelectedRecords();

    	if(slIds!=null && !slIds.isEmpty()) {
    		try {
    			GNE_SFA2_PFG_Util.approveOrRejectStorageLocations(currentUserId, slIds, approveOrReject);
    		} catch(Exception ex) {
    			result = setErrorPageReference(ex);
    		}
    	} else {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.GNE_SFA2_PFG_SELECT_STORAGE_LOCATION));
    	}

    	return result;
    }

	public class PageBlockTableEngine extends GNE_SFA2_PBT_Controller.ListenerEngine {
		private GNE_SFA2_PFG_MyPFG_Controller controller;
		public PageBlockTableEngine(GNE_SFA2_PFG_MyPFG_Controller controller) {
			super();
			this.controller = controller;

		}
		public override Object getColumnValueForRecord(SObject obj, String columnName) {
			Object result = null;

			if(columnName == 'slApprovalDate') {
				result = controller.csStorageLocationApprovalDate;
			} else if(columnName == 'slAddress') {
				SFA2_PFG_Storage_Location_gne__c sl = (SFA2_PFG_Storage_Location_gne__c)obj;
				result = sl.Address_Line_1_gne__c
				 + (sl.Address_Line_2_gne__c!=null ? (' ' + sl.Address_Line_2_gne__c) : '')
				 + ', ' + sl.City_gne__c + ', ' + sl.State_gne__c + ' ' + sl.Zip_gne__c;
			} else if(columnName == 'slCreatedDate') {
				SFA2_PFG_Storage_Location_gne__c sl = (SFA2_PFG_Storage_Location_gne__c)obj;
				result = sl.CreatedDate;
			}

			return result;
		}

		public override String getCustomActionLink(String actionName, SObject obj) {
			String result = super.getCustomActionLink(actionName, obj);

			if(actionName == 'confirmQuantity') {
				result = controller.redirectTo(new ApexPages.StandardController(obj).edit()).getUrl();
			}

			return result;
	    }
	}

	public class InitPage_Exception extends Exception {}


}