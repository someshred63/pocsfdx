/******************************************************************************************
*  @author: Bartosz Osowiecki, Roche (contractor)
*  @email: bartosz.osowiecki@contractors.roche.com   
*  Created: 2013-07-02
*  First version was createdy by Karl Simon (2013-06-17) to refactor to use Promotional Free Goods (PFG) solution object, Call_PFG_Detail_gne__c, and deprecate defunct use of Veeva Call2Samples.
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call_PFG_Detail_gne__c child records for the specified accounts.         
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCallPFGDetail/*')
global with sharing class iPhone_Get_Account_CallPFGDetail_gne {
    
    @HttpPost 
     global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {       
        return iPhone_Commons_gne.buildResponse(
                new GetAccountCallPFGDetailResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)           
        );        
    } 

    class GetAccountCallPFGDetailResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
                                                        
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            return args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallPFGDetailsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallPFGDetailsByAccountIds(args.accountIds);
        }   
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new GetAccountCallPFGDetailsRecord((Call_PFG_Detail_gne__c)sObj);                      
        }                   
    } 
    
    class GetAccountCallPFGDetailsRecord extends iPhone_Commons_gne.DeltaRecord {          
        public String at;  // Call_PFG_Detail_gne__c.Account_gne__c
        public String iid; // Call_PFG_Detail_gne__c.Call_gne__c
        public String lt;  // Call_PFG_Detail_gne__c.Lot_No_gne__c
        public String pd;  // Call_PFG_Detail_gne__c.Product_gne__c
        public String qu;  // Call_PFG_Detail_gne__c.Quantity_gne__c
        public String dm;  // Call_PFG_Detail_gne__c.Distribution_Method_gne__c
        public String dtpaocst;  // Call_PFG_Detail_gne__c.DTP_AOC_Status_gne__c
        public String ordst;  // Call_PFG_Detail_gne__c.Order_Status_gne__c
        public String shpid;  // Call_PFG_Detail_gne__c.Shipment_ID_gne__c
        public String ordid; // SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c      
        public String shpd; // SFA2_PFG_Transaction_gne__c.Shipped_Date_gne__c
        public String pcks; // SFA2_PFG_Transaction_gne__c.Pick_Slip_Number_gne__c
        
        public GetAccountCallPFGDetailsRecord(Call_PFG_Detail_gne__c pfgDetail) {
            this.id  = pfgDetail.Id;
            this.iid = pfgDetail.Call_gne__c;            
            this.at  = iPhone_StringUtil.getString(pfgDetail.Account_gne__c);          
            this.pd  = iPhone_StringUtil.getString(pfgDetail.Product_gne__c);
            this.qu  = iPhone_StringUtil.getString(pfgDetail.Quantity_gne__c);
            this.lt  = iPhone_StringUtil.getString(pfgDetail.Lot_No_gne__c);
            this.dm  = iPhone_StringUtil.getString(pfgDetail.Distribution_Method_gne__c);
            this.dtpaocst  = iPhone_StringUtil.getString(pfgDetail.DTP_AOC_Status_gne__c);  //OTR should determine use based upon Distribution Method = 'DTP'
            this.ordst  = iPhone_StringUtil.getString(pfgDetail.Order_Status_gne__c);  //OTR should determine use based upon Distribution Method = 'DTP'
            this.shpid  = iPhone_StringUtil.getString(pfgDetail.Shipment_ID_gne__c);  //OTR should determine use based upon Distribution Method = 'DTP'
            
            // There should be only one PFG Transaction related to Call PFG Detail
            for(SFA2_PFG_Transaction_gne__c trx : pfgDetail.PFG_Transactions__r) {
            	this.ordid	= iPhone_StringUtil.getString(trx.Transaction_Ref_Number_gne__c);
            	this.shpd	= iPhone_StringUtil.getStringDate(trx.Shipped_Date_gne__c);
            	this.pcks	= iPhone_StringUtil.getString(trx.Pick_Slip_Number_gne__c);
            }         
        }
    }   
}