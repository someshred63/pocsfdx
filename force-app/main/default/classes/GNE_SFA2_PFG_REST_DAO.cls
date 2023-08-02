public with sharing class GNE_SFA2_PFG_REST_DAO {
    public static List<SFA2_PFG_Transaction_gne__c> getDtpAllocationTansfers(Object inputData) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Type_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Received_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            'Product_gne__r.NDC_Number_gne__c',
            'Product_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_Territory_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_Territory_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_Territory_Name_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_Territory_Name_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Distribution_Method_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.LastModifiedDate)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Distribution_Method_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Status_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED),
                (inputData instanceof DateTime ? 
                    new GNE_SFA2_PFG_DAO.WhereStatementWrapper('LastModifiedDate', '>=', inputData) :
                    new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Name', 'IN', inputData))
            },
            new List<String>{'CreatedDate asc'}
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getDtpAOCs(Object inputData) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipment_Id_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Call_PFG_Detail_ID_gne__c),
            'Call_PFG_Detail_ID_gne__r.Call_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Distribution_Method_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.LastModifiedDate)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Distribution_Method_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Signature_Date_gne__c', '!=', null),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Status_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED),
                (inputData instanceof DateTime ? 
                    new GNE_SFA2_PFG_DAO.WhereStatementWrapper('LastModifiedDate', '>=', inputData) :
                    new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', inputData))
            },
            new List<String>{'CreatedDate asc'}
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getHcAdjustments(DateTime lastSyncDateTime) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Type_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Reason_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Requested_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            'Product_gne__r.NDC_Number_gne__c',
            'Product_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Lot_No_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_User_gne__c),
            'From_User_gne__r.External_ID_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Call_PFG_Detail_ID_gne__c),
            'Call_PFG_Detail_ID_gne__r.Call_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Distribution_Method_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.LastModifiedDate)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Distribution_Method_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Status_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('LastModifiedDate', '>=', lastSyncDateTime)
            },
            new List<String>{'CreatedDate asc'}
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getHcTransfers(DateTime lastSyncDateTime) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Type_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Requested_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            'Product_gne__r.NDC_Number_gne__c',
            'Product_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Lot_No_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_User_gne__c),
            'From_User_gne__r.External_ID_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_User_gne__c),
            'To_User_gne__r.External_ID_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Receipt_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Received_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Distribution_Method_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.LastModifiedDate)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Distribution_Method_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Status_gne__c', 'IN', 
                                                            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED,
                                                                            GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED}),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('LastModifiedDate', '>=', lastSyncDateTime)
                
            },
            new List<String>{'CreatedDate asc'}
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getDtpOrders(Object inputData) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Call_PFG_Detail_ID_gne__c),
            'Call_PFG_Detail_ID_gne__r.Call_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Type_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Requested_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            'Product_gne__r.NDC_Number_gne__c',
            'Product_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Account_gne__c),
            'Account_gne__r.MDMID_gne__c',
            'Account_gne__r.FirstName',
            'Account_gne__r.Middle_vod__c',
            'Account_gne__r.LastName',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Address_Line_1_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Address_Line_2_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.City_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.State_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Zip_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Address_ID_gne__c),
            'Address_ID_gne__r.Zip_4_vod__c',
            'Address_ID_gne__r.Phone_vod__c',
            'Address_ID_gne__r.Fax_vod__c',
            'Address_ID_gne__r.Email_gne__c',
            'Address_ID_gne__r.License_vod__c',
            'Address_ID_gne__r.Designation_gne__c',
            'Address_ID_gne__r.PFG_BDTD_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.BDTD_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Request_Signature_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Request_Signature_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.CS_First_Name_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.CS_Last_Name_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_User_gne__c),
            'From_User_gne__r.FirstName',
            'From_User_gne__r.LastName',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Distribution_Method_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.CreatedDate),
            String.valueOf(SFA2_PFG_Transaction_gne__c.HCP_Specialty_gne__c)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Distribution_Method_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Status_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED),
                (inputData instanceof DateTime ? 
                    new GNE_SFA2_PFG_DAO.WhereStatementWrapper('CreatedDate', '>=', inputData) :
                    new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', inputData))
            },
            new List<String>{'CreatedDate asc'}
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getHcDisbursements(DateTime lastSyncDateTime) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            'Call_PFG_Detail_ID_gne__r.Call_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Type_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Requested_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            'Product_gne__r.Name',
            'Product_gne__r.NDC_Number_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Lot_No_gne__c),
            'From_User_gne__r.External_ID_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Account_gne__c),
            'Account_gne__r.MDMID_gne__c',
            'Account_gne__r.FirstName',
            'Account_gne__r.Middle_vod__c',
            'Account_gne__r.LastName',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Address_Line_1_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Address_Line_2_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.City_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.State_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Zip_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Address_ID_gne__c),
            'Address_ID_gne__r.Zip_4_vod__c',
            'Address_ID_gne__r.Phone_vod__c',
            'Address_ID_gne__r.Fax_vod__c',
            'Address_ID_gne__r.Email_gne__c',
            'Address_ID_gne__r.License_vod__c',
            'Address_ID_gne__r.Designation_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Distribution_Method_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.LastModifiedDate)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Distribution_Method_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Status_gne__c', 'IN', 
                                                            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED,
                                                                            GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED}),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('LastModifiedDate', '>=', lastSyncDateTime)
                
            },
            new List<String>{'CreatedDate asc'}
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getHcReturns(DateTime lastSyncDateTime) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Type_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Requested_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            'Product_gne__r.Name',
            'Product_gne__r.NDC_Number_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Lot_No_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_User_gne__c),
            'From_User_gne__r.External_ID_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Distribution_Method_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.LastModifiedDate)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Distribution_Method_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Status_gne__c', 'IN', 
                                                            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED}),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('LastModifiedDate', '>=', lastSyncDateTime)
                
            },
            new List<String>{'CreatedDate asc'}
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getHcShipmentReceipts(DateTime lastSyncDateTime) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipment_Id_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_User_gne__c),
            'To_User_gne__r.External_ID_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Receipt_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            'Product_gne__r.NDC_Number_gne__c',
            'Product_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Lot_No_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Received_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.LastModifiedDate)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Receipt_Date_gne__c', '<>', null),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('LastModifiedDate', '>=', lastSyncDateTime)
            },
            new List<String>{'CreatedDate asc'}
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getHcOrders(DateTime lastSyncDateTime) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipment_Request_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Distribution_Method_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_User_gne__c),
            'To_User_gne__r.External_ID_gne__c',
            'To_User_gne__r.FirstName',
            'To_User_gne__r.LastName',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            'Product_gne__r.NDC_Number_gne__c',
            'Product_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Requested_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_User_Is_CS_Flag_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Generate_Shipment_Flag__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.LastModifiedDate)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{
                GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER, 
                GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Distribution_Method_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_Is_CS_Flag_gne__c', '=', true),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Generate_Shipment_Flag__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Status_gne__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_STATUS_APPROVED),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('LastModifiedDate', '>=', lastSyncDateTime)
            },
            new List<String>{'CreatedDate asc'}
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getDtpOrderStatus(Set<String> refNos) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Delivery_Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Call_PFG_Detail_ID_gne__c),
            'Call_PFG_Detail_ID_gne__r.Order_Status_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Order_Status_Note_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Order_Status_Last_Updated_gne__c)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', refNos)
            },
            null
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getDtpAocStatus(Set<String> rffNames, Set<String> paperOrderRefNos, Set<String> paperOrderLineItemIds) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.RecordTypeId),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Line_Item_ID_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Call_PFG_Detail_ID_gne__c),
            'Call_PFG_Detail_ID_gne__r.Shipment_Id_gne__c',
            'Call_PFG_Detail_ID_gne__r.DTP_AOC_Status_gne__c',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipment_Id_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Status_gne__c)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Name', 'IN', rffNames),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', paperOrderRefNos),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Line_Item_ID_gne__c', 'IN', paperOrderLineItemIds)
            },
            null,
            '{0} AND ({1} OR ({2} AND {3}))'
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getDtpShipments(Set<String> rffNames, Set<String> paperOrderRefNos, Set<String> paperOrderLineItemIds) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipment_Id_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Pick_Slip_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipped_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Account_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipped_To_Address_By_Third_Party_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Line_Item_ID_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.NDC_Number__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Lot_No_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipped_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Carrier_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Tracking_Id_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Tracking_URL_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Call_PFG_Detail_ID_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.RecordTypeId),
            'Call_PFG_Detail_ID_gne__r.Shipment_Id_gne__c',
            'Call_PFG_Detail_ID_gne__r.DTP_AOC_Status_gne__c',
            'Call_PFG_Detail_ID_gne__r.Lot_No_gne__c'
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Name', 'IN', rffNames),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', paperOrderRefNos),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Line_Item_ID_gne__c', 'IN', paperOrderLineItemIds)
            },
            null,
            '{0} AND ({1} OR ({2} AND {3}))'
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getDtpPaperOrders(Set<String> refNos, Set<String> lineItemIds) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Line_Item_ID_gne__c)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', refNos),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Line_Item_ID_gne__c', 'IN', lineItemIds)
            },
            null
        );
    }
    
    public static List<SFA2_PFG_Transaction_gne__c> getHcShipments(Set<String> refNos) {
        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipment_Id_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Pick_Slip_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipped_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_User_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipped_To_Address_By_Third_Party_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.NDC_Number__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Lot_No_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipped_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Carrier_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Tracking_Id_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Tracking_URL_gne__c)
        };
        
        return GNE_SFA2_PFG_DAO.getTransactions(
            queryFields,
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER,GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_Is_CS_Flag_gne__c', '=', true),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', refNos)
            },
            null
        );
    }
    
    public static List<SFA2_PFG_Storage_Location_gne__c> getStorageLocs(DateTime lastSyncDateTime) {
        return [
        SELECT
            Name,
            User_gne__r.External_Id_gne__c,
            User_gne__r.FirstName,
            User_gne__r.LastName,
            Address_Line_1_gne__c,
            Address_Line_2_gne__c,
            City_gne__c,
            State_gne__c,
            Zip_gne__c,
            Phone_gne__c
        FROM SFA2_PFG_Storage_Location_gne__c
        WHERE LastModifiedDate >= :lastSyncDateTime
        ORDER BY CreatedDate asc
        ];
    }
    
    public static List<SFA2_PFG_Inventory_Count_gne__c> getInventoryCounts(DateTime lastSyncDateTime) {
        return [
        SELECT
            Name,
            Inventory_Ref_Number_gne__c,
            Inventory_Type_gne__c,
            Inventory_Count_Date_gne__c,
            Inventory_For_gne__r.External_ID_gne__c,
            Product_gne__r.NDC_Number_gne__c,
            Product_gne__r.Name,
            Lot_gne__c,
            Count_gne__c
        FROM SFA2_PFG_Inventory_Count_gne__c
        WHERE LastModifiedDate >= :lastSyncDateTime
        ORDER BY CreatedDate asc
        ];
    }
    
    public static Set<Id> getAccountInfoRecTypeIds(){
        Map<Id, RecordType> accRecTypeIds = new Map<Id, RecordType>([
            SELECT 
                Id 
            FROM 
                RecordType 
            WHERE SObjectType = 'Account' AND DeveloperName = 'Professional_vod'
        ]);
        return accRecTypeIds.keyset();
    }
    
    public static List<Address_vod__c> getAccountInfo(List<String> accIds) {
        String selectStatement = getAccountInfoBaseQuery();
        String whereCondition = 'WHERE ' + String.valueOf(Address_vod__c.Account_vod__c) + ' IN :accIds';
        
        // Must be sorted from oldest to newest because of query more - ASC !
        String query = String.format('{0} {1} ORDER BY CreatedDate ASC'
            , new String[]{
                selectStatement,                // 0
                whereCondition                  // 1
            } 
        );
        
        return Database.query(query);
    }
    
    public static List<Address_vod__c> getAccountInfo(Set<Id> accRecTypeIds, DateTime lastSyncDateTime, Integer recordsLimit, Boolean forAccount, String additionalWhereCondition){
        String selectStatement = getAccountInfoBaseQuery();
        
        String accountRelName = Address_vod__c.Account_vod__c.getDescribe().getRelationshipName();
        String accountLastModDateFN = String.valueOf(Account.REST_AccInfo_Fields_LastModDate_gne__c);
        String addressLastModDateFN = String.valueOf(Address_vod__c.Rest_AccInfo_Fields_LastModDate_gne__c);
        
        String whereCondition = String.format(' WHERE'
            + ' {0}.isPersonAccount = True'
            + ' AND {0}.RecordTypeId In {1}'
            + ' AND ({2} = \'\'{3}\'\' OR {0}.{4} != null)'                
            , new String[]{
                accountRelName,                                                     // 0
                GNE_SFA2_Util.createInListForQuery(new List<Id>(accRecTypeIds)),    // 1
                String.valueOf(Address_vod__c.License_Valid_To_Sample_vod__c),      // 2
                'Valid',                                                            // 3
                String.valueOf(Account.MDMID_gne__c)                                // 4
                                    
            }
        );
            
        if (forAccount == true){            
            whereCondition += String.format(                
                + ' AND {0} = True'
                + ' AND (CreatedDate >= {2} OR {3} >= {2} OR {1}.CreatedDate >= {2} OR {1}.{4} >= {2})'
                , new String[]{
                    String.valueOf(Address_vod__c.Primary_vod__c),                  // 0
                    accountRelName,                                                 // 1
                    GNE_SFA2_PFG_REST_Utils.formatDateTimeSOQL(lastSyncDateTime),   // 2
                    addressLastModDateFN,                                           // 3
                    accountLastModDateFN                                            // 4
                }
            );
        } else {
            whereCondition += String.format(
                + ' AND {0} = False'
                + ' AND (CreatedDate >= {1} OR {2} >= {1})'
                , new String[]{
                    String.valueOf(Address_vod__c.Primary_vod__c),                  // 0
                    GNE_SFA2_PFG_REST_Utils.formatDateTimeSOQL(lastSyncDateTime),   // 1
                    addressLastModDateFN                                            // 2                    
                }        
            );
        }
        if (String.isNotBlank(additionalWhereCondition)){
            whereCondition += ' ' + additionalWhereCondition + ' ';
        }        
        
        // Must be sorted from oldest to newest because of query more - ASC !
        String query = String.format('{0} {1} ORDER BY CreatedDate ASC LIMIT {2}'
            , new String[]{
                selectStatement,                // 0
                whereCondition,                 // 1
                String.valueOf(recordsLimit)    // 2
            } 
        );

        return Database.query(query);
    }
    
    private static String getAccountInfoBaseQuery() {
        List<String> accountFields = new List<String> {
            String.valueOf(Account.Rest_AccInfo_Fields_LastModDate_gne__c),
            String.valueOf(Account.MDMID_gne__c),
            'FirstName',
            String.valueOf(Account.Middle_vod__c),
            'LastName',
            String.valueOf(Account.Account_Type_gne__c),
            'CreatedDate'
        };
        List<String> addressFields = new List<String> {                        
            'Id',
            'Name',
            'CreatedDate',
            String.valueOf(Address_vod__c.Rest_AccInfo_Fields_LastModDate_gne__c),
            String.valueOf(Address_vod__c.Account_vod__c),
            String.valueOf(Address_vod__c.Address_Line_2_vod__c),
            String.valueOf(Address_vod__c.City_vod__c),
            String.valueOf(Address_vod__c.State_vod__c),
            String.valueOf(Address_vod__c.Zip_vod__c),
            String.valueOf(Address_vod__c.Zip_4_vod__c),
            String.valueOf(Address_vod__c.Phone_vod__c),
            String.valueOf(Address_vod__c.Fax_vod__c),
            String.valueOf(Address_vod__c.Email_gne__c),
            String.valueOf(Address_vod__c.Primary_vod__c),
            String.valueOf(Address_vod__c.DEA_vod__c),
            String.valueOf(Address_vod__c.DEA_Status_vod__c),
            String.valueOf(Address_vod__c.DEA_Expiration_Date_vod__c),
            String.valueOf(Address_vod__c.License_vod__c),
            String.valueOf(Address_vod__c.License_Expiration_Date_vod__c),
            String.valueOf(Address_vod__c.License_Status_vod__c),
            String.valueOf(Address_vod__c.Designation_gne__c)
        };
        
        String accountRelName = Address_vod__c.Account_vod__c.getDescribe().getRelationshipName();
        
        String selectStatement = 'SELECT ';
        for(String field : accountFields){
            selectStatement += String.format('{0}.{1}, ',
                new String[]{
                    accountRelName, // 0
                    field           // 1
                }
            );
        }
        
        selectStatement += String.join(addressFields, ', ');        
        selectStatement += ' FROM Address_vod__c';
        
        return selectStatement;
    }
    
    public static List<Account> getAccountForPaperOrderValidation(String accId) {
        return [SELECT Id, IsPersonAccount FROM Account WHERE Id = :accId LIMIT 1];
    }
    
    public static List<Address_vod__c> getAddressForPaperOrderValidation(String addrId) {
        return [SELECT Id, Account_vod__c, License_Valid_To_Sample_vod__c FROM Address_vod__c WHERE Id = :addrId LIMIT 1];
    }
}