public with sharing class GNE_SFA2_PFG_Reports_Helper 
{
    public final static String REPORT_TYPE_ADJUSTEMNTS = 'Adjustments';
    public final static String REPORT_TYPE_DISBURSEMENTS = 'Disbursements';
    public final static String REPORT_TYPE_HC_EXCEPTION = 'HC Exception';
    public final static String REPORT_TYPE_LOT_EXPIRATION = 'Lot Expiration';
    public final static String REPORT_TYPE_QTY_LMT_CHG_HISTORY = 'Quantity Limits for HCP Change History';
    public final static String REPORT_TYPE_RETURNS = 'Returns';
    public final static String REPORT_TYPE_UNACKNOWLEDGED_SHIPMENTS = 'Unacknowledged Shipments';
    public final static String REPORT_CATEGORY_HC = 'HC Reports';
    public final static String REPORT_CATEGORY_DTP = 'DTP Reports';
    public final static String REPORT_TYPE_DTP_EXCEPTION = 'DTP Exception';
    public final static String REPORT_TYPE_QTY_LMT_CHG_HISTORY_DTP = 'Quantity Limits for HCP Change History DTP';
    public final static String REPORT_TYPE_OUTSTANDING_AOC = 'Outstanding AOC';
    
    public static List<WrappedCS> searchForCSs(String searchString, Integer recordLimit)
    {
        List<SFA2_User_Sales_Roster_gne__c> csSalesRosters = new List<SFA2_User_Sales_Roster_gne__c>([Select User_gne__c,Profile_Name_gne__c, User_gne__r.Name, User_gne__r.Username from SFA2_User_Sales_Roster_gne__c where Role_gne__c =: GNE_SFA2_PFG_Util.USER_ROLE_CS AND Is_Active_gne__c = true AND User_gne__r.Name LIKE :searchString  Order By User_gne__r.Name LIMIT :recordLimit]);
        List<WrappedCS> results = new List<WrappedCS>();
        for(SFA2_User_Sales_Roster_gne__c csRoster : csSalesRosters)
        {
            WrappedCS wrappedUser = new WrappedCS(csRoster);
            results.add(wrappedUser);
        }
        return results;
    }
    public static List<WrappedProduct> searchForProducts(String searchString, Integer recordLimit, String distMethod)
    {
        List<Product_vod__c> pfgProducts = new List<Product_vod__c>([Select Id, Name, NDC_Number_gne__c from Product_vod__c where Product_Type_vod__c =: GNE_SFA2_PFG_Util.PRODUCT_TYPE AND Name Like :searchString Order By Name LIMIT :recordLimit]);
        List<Product_vod__c> filteredProducts = new List<Product_vod__c>();
        if(distMethod == REPORT_CATEGORY_HC)
        {
            for(Product_vod__c prod : pfgProducts)
            {
                if(GNE_SFA2_PFG_Util.isProductHandCarry(prod.Id))
                {
                    filteredProducts.add(prod);
                }
            }
        }
        else if(distMethod == REPORT_CATEGORY_DTP)
        {
            for(Product_vod__c prod : pfgProducts)
            {
                if(GNE_SFA2_PFG_Util.isProductDtp(prod.Id))
                {
                    filteredProducts.add(prod);
                }
            }
        }
        system.debug('filteredProducts= '+filteredProducts);
        List<WrappedProduct> results = new List<WrappedProduct>();
        for(Product_vod__c fProd : filteredProducts)
        {
            WrappedProduct wProd = new WrappedProduct(fProd);
            results.add(wProd);
        }
        return results;
    }
    public static List<WrappedLot> searchForLots(String searchString, Integer recordLimit, String distMethod)
    {
    	String distributionMethod ='';
    	if(distMethod == REPORT_CATEGORY_HC)
        {
        	distributionMethod = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC;
        }
        else if(distMethod == REPORT_CATEGORY_DTP)
        {
        	distributionMethod = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
        }
        List<SFA2_Lot_Catalog_gne__c> lotCatalogs = new List<SFA2_Lot_Catalog_gne__c>([Select Id, Name, Product_gne__r.Name from SFA2_Lot_Catalog_gne__c where Active_gne__c = true AND Name Like :searchString AND Distribution_Method_gne__c =: distributionMethod Order By Name LIMIT :recordLimit]);
        List<WrappedLot> results = new List<WrappedLot>();
        for(SFA2_Lot_Catalog_gne__c lotCat : lotCatalogs)
        {
            WrappedLot wLot = new WrappedLot(lotCat);
            results.add(wLot);
        }
        return results;
    }
    public static List<WrappedAccount> searchForHCPs (String searchString, Integer recordLimit, Boolean searchById, Boolean searchByName, Boolean searchByMDM)
    {
        List<Account> accounts = new List<Account>();
        List<WrappedAccount> results = new List<WrappedAccount>();
        if(searchById)
        {
            accounts = [Select Id, Name, MDMID_gne__c from Account where IsPersonAccount = true AND Id =: searchString.replaceAll('%', '')];
        }
        if(searchByName)
        {
            accounts = [Select Id, Name, MDMID_gne__c from Account where IsPersonAccount = true AND Name LIKE :searchString Order By Name LIMIT :recordLimit];
        }
        if(searchByMDM)
        {
            accounts = [Select Id, Name, MDMID_gne__c from Account where IsPersonAccount = true AND MDMID_gne__c LIKE :searchString Order By MDMID_gne__c LIMIT :recordLimit];
        }
        for(Account acc : accounts)
        {
            WrappedAccount wAcc = new WrappedAccount(acc);
            results.add(wAcc);
        }
        system.debug('account results ='+results);
        return results;
    }
    public static List<WrappedShipment> searchForShipmentId(String searchText, Integer recordLimit)
    {
        List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>([Select Shipment_Id_gne__c from SFA2_PFG_Transaction_gne__c where Shipment_Id_gne__c Like :searchText Order By Shipment_Id_gne__c LIMIT :recordLimit]);
        List<WrappedShipment> results = new List<WrappedShipment>();
        for(SFA2_PFG_Transaction_gne__c trx : transactions)
        {
            WrappedShipment wShipment = new WrappedShipment(trx);
            results.add(wShipment);
        }
        return results;
    }
    public static List<WrappedOrder> searchForOrderId(String searchText, Integer recordLimit)
    {
        List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>([Select Id, Transaction_Ref_Number_gne__c from SFA2_PFG_Transaction_gne__c where Transaction_Ref_Number_gne__c Like :searchText AND Transaction_Type_gne__c = 'Order' Order By Transaction_Ref_Number_gne__c LIMIT :recordLimit]);
        List<WrappedOrder> results = new List<WrappedOrder>();
        for(SFA2_PFG_Transaction_gne__c trx : transactions)
        {
            WrappedOrder wOrder = new WrappedOrder(trx);
            results.add(wOrder);
        }
        return results;
    }
    public static String returnFirstDayOfQuater()
    {
        Double monthCountInQuater = Double.valueOf(Date.today().month())/3;
        Integer quater = Integer.valueOf(Math.ceil(monthCountInQuater));
        Integer month = 0;
        if(quater == 1)
        {
            month = 1;
        }
        else if(quater == 2)
        {
            month = 4;
        }
        else if(quater == 3)
        {
            month = 7;
        }
        else
        {
            month = 10;
        }

        return DateTime.newInstance(Date.today().year(), month, 1).format('MM/dd/yyyy');
    }
    public static Date dateNewInstance(String dateVar)
    {
        List<String> splitList = dateVar.split('/');
        String year = splitList[2];
        Date newDate = Date.newInstance(Integer.valueOf(year), Integer.valueOf(splitList[0]), Integer.valueOf(splitList[1]));
        return newDate;
    }   
    //CS Wrapper
    public class WrappedCS
    {
        public Id userId {get;set;}
        public String csName {get;set;}
        public String csUnix {get; set;}
        public String csProfile {get;set;}
        
        public WrappedCS (SFA2_User_Sales_Roster_gne__c csUserSR)
        {
            this.userId = csUserSR.User_gne__c;
            this.csName = csUserSR.User_gne__r.Name;
            this.csUnix = csUserSR.User_gne__r.Username.substringBefore('@');
            this.csProfile = csUserSR.Profile_Name_gne__c;
        }
    }
    //Product Wrapper
    public class WrappedProduct
    {
        public Id prodId {get;set;}
        public String productName {get;set;}
        public String ndcNumber {get;set;}
        public String distMethod {get;set;}
        
        public WrappedProduct (Product_vod__c pfgProduct)
        {
            this.prodId = pfgProduct.Id;
            this.productName = pfgProduct.Name;
            this.ndcNumber = pfgProduct.NDC_Number_gne__c;
        }
    }
    //Lot Wrapper
    public class WrappedLot
    {
        public Id lotId {get;set;}
        public String lotName {get;set;}
        public Date expirationDate {get;set;}
        public String prodName {get;set;}
        
        public WrappedLot (SFA2_Lot_Catalog_gne__c lotCat)
        {
            this.lotId = lotCat.Id;
            this.lotName = lotCat.Name;
            this.prodName = lotCat.Product_gne__r.Name;
        }
    }
    public class WrappedAccount
    {
        public Id accId {get;set;}
        public String accountName {get;set;}
        public String mdm {get;set;}
        
        public WrappedAccount (Account acc)
        {
            this.accId = acc.Id;
            this.accountName = acc.Name;
            this.mdm = acc.MDMID_gne__c;
        }
    }
    public class WrappedShipment
    {
        public String shipmentId {get;set;}
        
        public WrappedShipment(SFA2_PFG_Transaction_gne__c trx)
        {
            this.shipmentId = trx.Shipment_Id_gne__c;
        }
    }
    public class WrappedOrder
    {
        public String orderId {get;set;}
        public String orderName {get;set;}
        
        public WrappedOrder(SFA2_PFG_Transaction_gne__c trx)
        {
            this.orderName = trx.Transaction_Ref_Number_gne__c;
            this.orderId = trx.Id;
        }
    }
}