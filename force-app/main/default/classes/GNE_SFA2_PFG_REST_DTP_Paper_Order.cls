@RestResource(urlMapping='/sfa2_dtp_paperorder_inbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_DTP_Paper_Order extends GNE_SFA2_PFG_REST_Base {
	private static final String[] MANDATORY_FIELDS = new String[]{
			'Txn_ID', 'Txn_Date', 'Prod_Ln_ID', 'Txn_Type',
			'HCP_Id', 'HCP_Fst_Nm', 'HCP_Lst_Nm', 'HCP_Add_Ln_1', 'HCP_City', 'HCP_State', 'HCP_Zip', 'SLN', 'Prof_Des',
			'NDC', 'Prod_Nm', 'Txn_Qty',
			'Rep_Unix_ID', 'Rep_Fst_Nm', 'Rep_Lst_Nm', 'Terr_No'};

    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public transient List<SFA2_PFG_Transaction_gne__c> trxsToInsert;
    }

    global class DtpPaperOrder {
        public String Txn_ID;
        public String Txn_Date;
        public String Txn_Type;
        public String Prod_Ln_ID;
        public Integer Txn_Qty;
        public String NDC;
        public String Prod_Nm;
        public String HCP_Id;
        public String MDM_Id;
        public String HCP_Fst_Nm;
        public String HCP_Mid_Init;
        public String HCP_Lst_Nm;
        public String HCP_Add_Id;
        public String HCP_Add_Ln_1;
        public String HCP_Add_Ln_2;
        public String HCP_City;
        public String HCP_State;
        public String HCP_Zip;
        public String HCP_Fcty_Nm;
        public String SLN;
        public String Prof_Des;
        public String Rep_Unix_ID;
		public String Rep_ID;
		public String Rep_Fst_Nm;
		public String Rep_Lst_Nm;
		public String Rep_eMail;
		public String Terr_No;
		public String Terr_Nm;
		public String HCP_Spec;
		private transient Date trxDate;
		private transient Integer year;
		private transient String hcpFullName;
		private transient Account hcpAcc;

        public SFA2_PFG_Transaction_gne__c createTransaction() {
        	DateTime trxDateTime = GNE_SFA2_PFG_REST_Utils.parseDateTime(Txn_Date);
        	trxDate = trxDateTime!=null ? trxDateTime.dateGmt() : null;
        	year = trxDate!=null ? trxDate.year() : null;
        	hcpFullName = HCP_Fst_Nm + ' ' + (String.isNotBlank(HCP_Mid_Init) ? HCP_Mid_Init + ' ' : '') + HCP_Lst_Nm;

        	validateAttributes();

        	Product_vod__c pfgProd = GNE_SFA2_PFG_Util.getPfgProductByName(Prod_Nm);
        	Territory2 terr = GNE_SFA2_PFG_Util.getTerritoryByNumber(Terr_No);
        	User csUser = GNE_SFA2_PFG_Util.getUserByUnixId(Rep_Unix_ID);

            SFA2_PFG_Transaction_gne__c trx = new SFA2_PFG_Transaction_gne__c(
            	RecordTypeId = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER),
            	Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP,
            	Lot_No_gne__c = GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE,
            	Transaction_Ref_Number_gne__c = Txn_ID,
            	Line_Item_ID_gne__c = Prod_Ln_ID,
            	Transaction_Date_gne__c = trxDate,
            	Product_gne__c = pfgProd.Id,
            	NDC_Number__c = NDC,
            	Requested_Quantity_gne__c = Txn_Qty,
            	Account_gne__c = HCP_Id,
            	Account_Name_gne__c = hcpFullName,
            	Account_MDMID_gne__c = MDM_Id,
            	Address_ID_gne__c = (String.isNotBlank(HCP_Add_Id) ? HCP_Add_Id : null),
            	Address_Line_1_gne__c = HCP_Add_Ln_1,
            	Address_Line_2_gne__c = HCP_Add_Ln_2,
            	City_gne__c = HCP_City,
            	State_gne__c = HCP_State,
            	Zip_gne__c = HCP_Zip,
            	Facility_Name_gne__c = HCP_Fcty_Nm,
            	SLN_gne__c = SLN,
            	Designation_gne__c = Prof_Des,
            	CS_ID_gne__c = Rep_ID,
            	CS_First_Name_gne__c = Rep_Fst_Nm,
            	CS_Last_Name_gne__c = Rep_Lst_Nm,
            	CS_Email_gne__c = Rep_eMail,
            	From_User_gne__c = csUser.Id,
            	From_Territory_Name_gne__c = terr.Name,
            	From_Territory_Number_gne__c = terr.Territory_Number_gne__c,
            	From_User_Territory_gne__c = terr.Id,
            	HCP_Specialty_gne__c = HCP_Spec
            );

            return trx;
        }

        private void validateAttributes() {
        	validateMandatoryFields();
        	List<Exception> exList = new List<Exception>();

        	Territory2 terr;
        	if((terr = GNE_SFA2_PFG_Util.getTerritoryByNumber(Terr_No))==null) {
        		exList.add(new TerritoryNotFoundException(null, Terr_No));
        	} else if(String.isNotBlank(Terr_Nm) && terr.Name != Terr_Nm) {
        		// Report as a warning
        		GNE_SFA2_PFG_Util.handleException(new TerritoryDifferentNameException(null, terr.Name, Terr_Nm));
        	}

        	Product_vod__c pfgProd;
        	if((pfgProd = GNE_SFA2_PFG_Util.getPfgProductByName(Prod_Nm))==null) {
        		exList.add(new ProductNotFoundException(null, Prod_Nm));
        	}

        	validateUser(exList);
        	validateAccountWithAddress(exList);
        	validateHCPSpecialty(exList);

        	if(terr!=null && pfgProd!=null && hcpAcc!=null) {
        		validateQuantity(terr, pfgProd, exList);
        	}

        	if(!exList.isEmpty()) {
        		throw new PaperOrderException(exList);
        	}
        }

        private void validateMandatoryFields() {
        	List<Exception> exList = new List<Exception>();
        	Map<String, Object> fieldAndValues = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(this));
        	for(String fieldName : MANDATORY_FIELDS) {
        		Object fieldValue = fieldAndValues.get(fieldName);

        		if(fieldValue == null || (fieldValue instanceof String && String.isBlank((String)fieldValue))) {
        			exList.add(new MandatoryFieldException(fieldName, String.valueOf(fieldValue)));
        		}
        	}

        	if(!exList.isEmpty()) {
        		throw new PaperOrderException(exList);
        	}
        }

        private void validateUser(List<Exception> exList) {
			User csUser = null;
        	if((csUser = GNE_SFA2_PFG_Util.getUserByUnixId(Rep_Unix_ID))==null) {
        		exList.add(new UserNotFoundException(null, Rep_Unix_ID));
        	} else {
        		Boolean isLOA = GNE_SFA2_PFG_Util.checkIsUserLOAOnDate(csUser.Id, trxDate);
				Boolean isCertified = GNE_SFA2_PFG_Util.checkIsUserCertified(csUser.Id);

				if(isLOA) {
					exList.add(new UserOnLoaException(null, csUser.Name));
				}

				if(!isCertified) {
					exList.add(new UserUncertifiedException(null, csUser.Name));
				}
			}
		}

		private void validateAccountWithAddress(List<Exception> exList) {
			hcpAcc = null;
			for(Account acc : GNE_SFA2_PFG_REST_DAO.getAccountForPaperOrderValidation(HCP_Id)) {
				hcpAcc = acc;
			}

			if(hcpAcc==null) {
				exList.add(new HcpNotFoundException(null, HCP_Id));
			} else if(!hcpAcc.isPersonAccount) {
				exList.add(new AccountNotHcpException(null, HCP_Id));
			}

			if(String.isNotBlank(HCP_Add_Id)) {
				Address_vod__c hcpAddr = null;
				for(Address_vod__c adrr : GNE_SFA2_PFG_REST_DAO.getAddressForPaperOrderValidation(HCP_Add_Id)) {
					hcpAddr = adrr;
				}

				if(hcpAddr==null) {
					exList.add(new AddressNotFoundException(null, HCP_Add_Id));
				} else if(hcpAcc!=null && hcpAddr.Account_vod__c!=hcpAcc.Id) {
					exList.add(new AddressAssignedToDifferentAccountException(null, HCP_Add_Id, hcpAddr.Account_vod__c, HCP_Id));
				} else if(!GNE_SFA2_PFG_Util.checkIsSlnValid(hcpAddr)) {
					exList.add(new InvalidSlnException(null, HCP_Add_Id));
				}
			}
		}

		private void validateHCPSpecialty(List<Exception> exList){
        	User csUser = GNE_SFA2_PFG_Util.getUserByUnixId(Rep_Unix_ID);
        	if(String.isBlank(HCP_Spec) && csUser != null && GNE_SFA2_PFG_Util.isHCPSpecActiveForUser(csUser.Id)) {
        		exList.add(new HcpSpecNotFoundException(null, null));
        	}
        }

		private void validateQuantity(Territory2 terr, Product_vod__c pfgProd, List<Exception> exList) {
			List<Integer> minAndMaxValues = new List<Integer>{null, null};

			if(!GNE_SFA2_PFG_Util.validateTerritoryQuantity(terr.Name, pfgProd.Id, year, Txn_Qty, minAndMaxValues)) {
				exList.add(new TerritoryLimitException(null, terr.Name, pfgProd.Name, year, minAndMaxValues[1]));
			}

			if(!GNE_SFA2_PFG_Util.validateHcpQuantityLimit(hcpAcc.Id, pfgProd.Id, Txn_Qty, String.valueOf(year))) {
				exList.add(new HcpLimitException(
						null, hcpFullName + ' (' + hcpAcc.Id + ')', pfgProd.Name, year,
						GNE_SFA2_PFG_Util.getHcpQuantityLimit(hcpAcc.Id, pfgProd.Id, String.valueOf(year))));
			}
		}
 	}

    @HttpPost
    global static ResultSet insertPaperOrders(List<DtpPaperOrder> records) {
        return (ResultSet)(new GNE_SFA2_PFG_REST_DTP_Paper_Order()).processInputObjects(records, new ResultSet());
    }

    protected override void intProcessInputObjects(List<Object> a_inputObjects, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        List<DtpPaperOrder> paperOrders = (List<DtpPaperOrder>)a_inputObjects;
        ResultSet result = (ResultSet)a_result;
        Set<String> orderIDs = new Set<String>();
        Set<String> lineItemIDs = new Set<String>();
        result.trxsToInsert = new List<SFA2_PFG_Transaction_gne__c>();
        preparePfgCache(paperOrders);

        for(DtpPaperOrder paperOrderWrapper : paperOrders) {
        	if(String.isNotBlank(paperOrderWrapper.Txn_ID) && String.isNotBlank(paperOrderWrapper.Prod_Ln_ID)) {
        		orderIDs.add(paperOrderWrapper.Txn_ID);
            	lineItemIDs.add(paperOrderWrapper.Prod_Ln_ID);
        	}
        }

        Map<String,SFA2_PFG_Transaction_gne__c> existingTrxsMap = new Map<String,SFA2_PFG_Transaction_gne__c>();

        for(SFA2_PFG_Transaction_gne__c trx : GNE_SFA2_PFG_REST_DAO.getDtpPaperOrders(orderIDs, lineItemIDs)) {
        	existingTrxsMap.put(getKeyForOrder(trx), trx);
        }

        for(DtpPaperOrder paperOrderWrapper : paperOrders) {
        	if(String.isNotBlank(paperOrderWrapper.Txn_ID) && String.isNotBlank(paperOrderWrapper.Prod_Ln_ID) && existingTrxsMap.containsKey(getKeyForOrder(paperOrderWrapper))) {
        		throw new DuplicateOrderException(null, paperOrderWrapper.Txn_ID , paperOrderWrapper.Prod_Ln_ID);
        	} else {
        		SFA2_PFG_Transaction_gne__c trx = paperOrderWrapper.createTransaction();
        		existingTrxsMap.put(getKeyForOrder(trx), trx);
        		result.trxsToInsert.add(trx);
        	}
        }
    }

    protected override void executeDmls(GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        ResultSet result = (ResultSet)a_result;

        if(!result.trxsToInsert.isEmpty()) {
            insert result.trxsToInsert;
        }
    }

    private String getKeyForOrder(SFA2_PFG_Transaction_gne__c trx) {
    	return trx.Transaction_Ref_Number_gne__c.toUpperCase() + '_' + trx.Line_Item_ID_gne__c.toUpperCase();
    }

    private String getKeyForOrder(DtpPaperOrder paperOrderWrapper) {
    	return (String.isNotBlank(paperOrderWrapper.Txn_ID) ? paperOrderWrapper.Txn_ID.toUpperCase() : null) + '_' +
    			(String.isNotBlank(paperOrderWrapper.Prod_Ln_ID) ? paperOrderWrapper.Prod_Ln_ID.toUpperCase() : null);
    }

    private void preparePfgCache(List<DtpPaperOrder> paperOrders) {
    	List<String> terrNames = new List<String>();
    	List<Id> prodIds = new List<Id>();
    	List<Integer> years = new List<Integer>();
    	List<String> yearsAsString = new List<String>();
    	List<Id> accIds = new List<Id>();

    	for(DtpPaperOrder paperOrderWrapper : paperOrders) {
    		Territory2 terr = String.isNotBlank(paperOrderWrapper.Terr_No) ? GNE_SFA2_PFG_Util.getTerritoryByNumber(paperOrderWrapper.Terr_No) : null;
    		Product_vod__c pfgProd = String.isNotBlank(paperOrderWrapper.Prod_Nm) ? GNE_SFA2_PFG_Util.getPfgProductByName(paperOrderWrapper.Prod_Nm) : null;
    		DateTime trxDateTime = GNE_SFA2_PFG_REST_Utils.parseDateTime(paperOrderWrapper.Txn_Date);
        	Integer year = trxDateTime!=null ? trxDateTime.dateGmt().year() : null;
        	Id hcpId = null;
        	try { hcpId = ID.valueOf(paperOrderWrapper.HCP_Id); } catch(Exception ex) {}

    		if(terr!=null && pfgProd!=null && year!=null && hcpId!=null) {
    			terrNames.add(terr.Name);
    			prodIds.add(pfgProd.Id);
    			years.add(year);
    			yearsAsString.add(String.valueOf(year));
    			accIds.add(hcpId);
    		}
    	}

    	GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(terrNames, prodIds, years);
		// Cache HCP and Product Limit Records
		GNE_SFA2_PFG_Util.cachePfgToAccountDetails(accIds, prodIds, yearsAsString);
		GNE_SFA2_PFG_Util.cacheAccLimitExceptions(accIds, prodIds, yearsAsString);
		GNE_SFA2_PFG_Util.cacheProductLimits(prodIds, yearsAsString);
    }

    // START Exception definitions
    public class MandatoryFieldException extends Exception {
    	public MandatoryFieldException(String fieldName, String fieldValue) {
    		this(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_REQUIRED_FIELD, new String[]{fieldName, fieldValue}));
    	}
    }

    public class TerritoryNotFoundException extends Exception {
    	public TerritoryNotFoundException(String msg, String terrNumber) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_TERRITORY, new String[]{terrNumber}));
    	}
    }

    public class TerritoryDifferentNameException extends Exception {
    	public TerritoryDifferentNameException(String msg, String sfdcTerrName, String inputTerrName) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_TERRITORY_DIFF_NAME, new String[]{sfdcTerrName, inputTerrName}));
    	}
    }

    public class UserNotFoundException extends Exception {
    	public UserNotFoundException(String msg, String unixId) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_USER, new String[]{unixId}));
    	}
    }

    public class ProductNotFoundException extends Exception {
    	public ProductNotFoundException(String msg, String prodName) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_PRODUCT, new String[]{prodName}));
    	}
    }

    public class DuplicateOrderException extends Exception {
    	public DuplicateOrderException(String msg, String orderId, String lineItemId) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_DUPLICATE_ORDER, new String[]{orderId, lineItemId}));
    	}
    }

    public class UserOnLoaException extends Exception {
    	public UserOnLoaException(String msg, String userName) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_USER_ON_LOA, new String[]{userName}));
    	}
    }

    public class UserUncertifiedException extends Exception {
    	public UserUncertifiedException(String msg, String userName) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_USER_UNCERTIFIED, new String[]{userName}));
    	}
    }

    public class HcpNotFoundException extends Exception {
    	public HcpNotFoundException(String msg, String accId) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_HCP, new String[]{accId}));
    	}
    }

    public class AccountNotHcpException extends Exception {
    	public AccountNotHcpException(String msg, String accId) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_ACCOUNT_NOT_HCP, new String[]{accId}));
    	}
    }

    public class AddressNotFoundException extends Exception {
    	public AddressNotFoundException(String msg, String addrId) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_ADDRESS, new String[]{addrId}));
    	}
    }

    public class AddressAssignedToDifferentAccountException extends Exception {
    	public AddressAssignedToDifferentAccountException(String msg, String addrId, String addrAccId, String accId) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_ADDRESS_NOT_MATCH_HCP, new String[]{addrId, addrAccId, accId}));
    	}
    }

    public class InvalidSlnException extends Exception {
    	public InvalidSlnException(String msg, String addId) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_INVALID_SLN, new String[]{addId}));
    	}
    }

    public class TerritoryLimitException extends Exception {
    	public TerritoryLimitException(String msg, String terrName, String prodName, Integer year, Integer limitQty) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_TERRITORY_LIMIT_REACHED, new String[]{terrName, prodName, String.valueOf(year), String.valueOf(limitQty)}));
    	}
    }

    public class HcpLimitException extends Exception {
    	public HcpLimitException(String msg, String hcpName, String prodName, Integer year, Integer limitQty) {
    		setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_HCP_LIMIT_REACHED, new String[]{hcpName, prodName, String.valueOf(year), String.valueOf(limitQty)}));
    	}
    }

    public class HcpSpecNotFoundException extends Exception {
    	public HcpSpecNotFoundException(String msg, String HCP_Id){
    		setMessage(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_HCP_SPEC);
    	}
    }

    public class PaperOrderException extends Exception {
    	public List<Exception> exceptions;

    	public PaperOrderException(List<Exception> a_exceptions) {
        	exceptions = a_exceptions;
        	List<String> exMsgs = new List<String>();

        	for(Exception ex : exceptions) {
        		exMsgs.add(ex.getMessage());
        	}

        	setMessage(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_ERROR, new String[]{'[' + String.join(exMsgs,'], [') + ']'}));
        }
    }

    // END Exception definitions
}