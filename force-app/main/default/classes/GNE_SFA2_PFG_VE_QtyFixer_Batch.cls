public with sharing class GNE_SFA2_PFG_VE_QtyFixer_Batch extends GNE_SFA2_PFG_VE_QtyChecker_Batch {
    public override System.Type getBatchClass() {
        return GNE_SFA2_PFG_VE_QtyFixer_Batch.class;
    }
    
    public override String getBatchName() {
        return 'PFG VE Quantity Fixer';
    }
    
    protected override void createReport(Database.BatchableContext BC) {
        Map<String,SFA2_PFG_to_Territory_Detail_gne__c> tDatailsToUpdate = new Map<String,SFA2_PFG_to_Territory_Detail_gne__c>();
        
        for(GNE_SFA2_PFG_VE_QtyChecker_Batch.ReportRowWrapper rowWrapper : reportRowsWrappers) {
            SFA2_PFG_to_Territory_Detail_gne__c tDetail = rowWrapper.tDetail!=null ? rowWrapper.tDetail : tDatailsToUpdate.get(rowWrapper.terrName + '_' + rowWrapper.productId + '_' + rowWrapper.year);
            rowWrapper.tDetail = tDetail;
            
            if(tDetail==null) {
                tDetail = rowWrapper.tDetail = createTerritoryDetail(rowWrapper.terrId, rowWrapper.terrName, rowWrapper.productId, rowWrapper.year);
            }
            
            Integer trxQty = rowWrapper.trxsQty;
            if(rowWrapper.qtyType == QTY_TYPE_ALLOCATED) {
                tDetail.YTD_Allocated_gne__c = trxQty;
            } else if(rowWrapper.qtyType == QTY_TYPE_PENDING) {
                tDetail.Qty_Reserved_gne__c = trxQty;
            } else if(rowWrapper.qtyType == QTY_TYPE_SHIPPED) {
                tDetail.Qty_Shipped_to_Physician_gne__c = trxQty;
            }
            
            tDatailsToUpdate.put(GNE_SFA2_PFG_Util.getRecordKey(tDetail),tDetail);
        }
        
        for(GNE_SFA2_PFG_VE_QtyChecker_Batch.ReportRowWrapper rowWrapper : reportRowsWrappers) {
            SFA2_PFG_to_Territory_Detail_gne__c tDetail = rowWrapper.tDetail;
            
            if(rowWrapper.qtyType == QTY_TYPE_REMAINING) {
                Integer tDetailAvailable = getTotalAvailable(tDetail);
                Integer trxQty = rowWrapper.trxsQty;
                tDetail.Qty_Total_Allocated_gne__c += trxQty-tDetailAvailable;
            }
        }
        
        if(!tDatailsToUpdate.isEmpty()) {
            GNE_Batch_Runner.executeDML(this, tDatailsToUpdate.values(), GNE_Batch_Runner.DMLType.UPSERT_DML, null, 'Upsert PFG Territory Details');
        
            List<String> columns = new List<String>(REPORT_COLUMNS);
            columns.add('Status');
            List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows = new List<GNE_SFA2_PFG_Report_Engine.ReportRow>{new GNE_SFA2_PFG_Report_Engine.ReportRow(columns)};
        
            for(GNE_SFA2_PFG_VE_QtyChecker_Batch.ReportRowWrapper row : reportRowsWrappers) {
                List<Object> rowAsList = row.getReportRowAsList();
                rowAsList.add('Fixed');
                reportRows.add(new GNE_SFA2_PFG_Report_Engine.ReportRow(rowAsList));
            }
            
            String reportExtId = GNE_SFA2_PFG_Report_Engine.getReportId(getBatchName(),System.now());
            Id reportId = GNE_SFA2_PFG_Report_Engine.saveReport(reportExtId, BC.getJobId(), reportRows);
            sendEmailReport(reportId, reportExtId, reportRows, wrongTerrProductCount, terrProductCount);
        }
    }
    
    private SFA2_PFG_to_Territory_Detail_gne__c createTerritoryDetail(Id terrId, String terrName, String prodId, Integer year) {
        Product_vod__c pfgProd = GNE_SFA2_PFG_Util.getPfgProduct(prodId);
        Territory2 terr = GNE_SFA2_PFG_Util.getTerritory(terrId);
        SFA2_PFG_to_Territory_Detail_gne__c tDetail = new SFA2_PFG_to_Territory_Detail_gne__c(
            Active_gne__c = true,
            Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP,
            Lot_NO_gne__c = GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE,
            Product_gne__c = prodId,
            Year_gne__c = year,
            Qty_Total_Allocated_gne__c = 0,
            YTD_Allocated_gne__c = 0,
            Qty_Reserved_gne__c = 0,
            Qty_Shipped_to_Physician_gne__c = 0,
            Territory_gne__c = (terrId!=null ? (String)terrId : terrName),
            Territory_Name_gne__c = terrName,
            Territory_Number_gne__c = (terr!=null ? terr.Territory_Number_gne__c : null),
            UOM_gne__c = (pfgProd!=null ? pfgProd.UOM_gne__c : null)
        );
        
        return tDetail;
    }
    
}