public without sharing class SRW_ReportWrappers {
    public SRW_ReportWrappers() {
        
    }

    public class SRW_PicklistSelectOptions {
        public String key       {get; set;}
        public String value     {get; set;}

        public SRW_PicklistSelectOptions(String key, String value) {
            this.key = key;
            this.value = value;
        }
    }

    public class SRW_ReportTable {
        public String reportName                {get; set;}
        public List<SRW_ReportData> reportData  {get; set;}
        
        public SRW_ReportTable() {
        }
        
        public SRW_ReportTable(String reportName, List<SRW_ReportData> reportData) {
            this.reportName = reportName;
            this.reportData = reportData;
        }
    }

    public virtual class SRW_ReportData {
        public SRW_ReportData() {
        }
    }

    // ###################################################################################
    // ########################### REPORT 1 ##############################################
    // ################# Trading Partner List by Status ##################################
    // ###################################################################################
    
    public class SRW_Report1Table1 extends SRW_ReportData {
        public String tPName        {get; set;}
        public String mccoAccMgr    {get; set;}
        public String str1          {get; set;}
        public String str2          {get; set;}
        public String city          {get; set;}
        public String state         {get; set;}
        public String zip           {get; set;}
        public String tpStatus      {get; set;}
        public Date conEffDate      {get; set;}
        public Date conTerDate      {get; set;}

        public SRW_Report1Table1(String tPName,String mccoAccMgr,String str1,String str2,String city,String state,String zip,String tpStatus,Date conEffDate,Date conTerDate) {
            this.tPName=tPName;
            this.mccoAccMgr=mccoAccMgr;
            this.str1=str1;
            this.str2=str2;
            this.city=city;
            this.state=state;
            this.zip=zip;
            this.tpStatus= tpStatus;
            this.conEffDate = conEffDate;
            this.conTerDate = conTerDate;
        }
    }

    // ###################################################################################
    // ########################### REPORT 2 ##############################################
    // ################# Trading Partner List by By Data Submission Status ###############
    // ###################################################################################
    
    public class SRW_Report2Table1Helper {
    	public String lastUpdated {get;set;}
    	public SRW_TP_Data_Months__c dataMonth {get;set;}

    	public SRW_Report2Table1Helper(SRW_TP_Data_Months__c tpdm){
    		this.lastUpdated = tpdm.LastModifiedDate != null ? tpdm.LastModifiedDate.format('MM/dd/yyyy hh:mm a') : '';
    		this.datamonth = tpdm;
    		System.debug('Rep 2: tpdm.lastModifiedDate: ' + tpdm.LastModifiedDate + ' ||| formated dateTime: ' + this.lastUpdated);
    	}
    }

    public class SRW_Report2Table1 extends SRW_ReportData {
        public String tPName                            {get; set;}
        public String str1                              {get; set;}
        public String mccoAccMgr                        {get; set;}
        public String tpStatus                          {get; set;}
        public List<SRW_Report2Table1Helper> dataMonths   {get;set;} 

        public SRW_Report2Table1(String tPName,String str1,String mccoAccMgr,String tpStatus,List<SRW_TP_Data_Months__c> dataMonths ) {
            this.tPName=tPName;
            this.mccoAccMgr=mccoAccMgr;
            this.str1=str1;
            this.tpStatus= tpStatus;
            this.dataMonths = new List<SRW_Report2Table1Helper>();
            for(SRW_TP_Data_Months__c tpdm : dataMonths){
            	this.dataMonths.add(new SRW_Report2Table1Helper(tpdm));
            }
        }
    }

    /*public class SRW_Report2Table1 extends SRW_ReportData {
        public String tPName                            {get; set;}
        public String str1                              {get; set;}
        public String mccoAccMgr                        {get; set;}
        public String tpStatus                          {get; set;}
        public List<SRW_TP_Data_Months__c> dataMonths   {get;set;}
        //public Map<SRW_TP_Data_Months__c, string> datMonToLastUpdated     {get; set;}

        public SRW_Report2Table1(String tPName,String str1,String mccoAccMgr,String tpStatus,List<SRW_TP_Data_Months__c> dataMonths ) {
            this.tPName=tPName;
            this.mccoAccMgr=mccoAccMgr;
            this.str1=str1;
            this.tpStatus= tpStatus;
            this.dataMonths = dataMonths;

            Map<SRW_TP_Data_Months__c, string> tempdatMonToLastUpdated = new Map<SRW_TP_Data_Months__c, string>();
             system.debug(' ---- dataMonths '+dataMonths.size());
            for(SRW_TP_Data_Months__c tempDatMon :  dataMonths ){
                //Map<SRW_TP_Data_Months__c, string> tempdatMonToLastUpdateMap = new Map<SRW_TP_Data_Months__c, string>();
                if(tempDatMon.LastModifiedDate != null){
                    string tempLastModifiedDate = '';
                    tempLastModifiedDate  = tempDatMon.LastModifiedDate.format('MM/dd/yyyy hh:mm a');
                    //system.debug(' ##-- tempLastModifiedDate   ' +tempLastModifiedDate  );
                    tempdatMonToLastUpdated.put(tempDatMon, tempLastModifiedDate);
                     system.debug(' ---- dat mon id: '+tempDatMon +' tempLastModifiedDate  ' + tempLastModifiedDate);
                }else{
                    tempdatMonToLastUpdated.put(tempDatMon,'');
                    system.debug(' ---- dat mon id: '+tempDatMon +' tempLastModifiedDate  ' + 'date is null');
                }
               
                //tempdatMonToLastUpdated.add(tempdatMonToLastUpdateMap);
            }
            system.debug(' ---- tempdatMonToLastUpdated' + tempdatMonToLastUpdated.size());
            this.datMonToLastUpdated = tempdatMonToLastUpdated;
        }
        public Map<SRW_TP_Data_Months__c, string> addDataMonthLastUpdatedMap(List<SRW_TP_Data_Months__c> dataMonths){
            Map<SRW_TP_Data_Months__c, string> tempdatMonToLastUpdated = new Map<SRW_TP_Data_Months__c, string>();
             system.debug(' ---- dataMonths '+dataMonths.size());
            for(SRW_TP_Data_Months__c tempDatMon :  dataMonths ){
                //Map<SRW_TP_Data_Months__c, string> tempdatMonToLastUpdateMap = new Map<SRW_TP_Data_Months__c, string>();
                if(tempDatMon.LastModifiedDate != null){
                    string tempLastModifiedDate = '';
                    tempLastModifiedDate  = tempDatMon.LastModifiedDate.format('MM/dd/yyyy hh:mm a');
                    //system.debug(' ##-- tempLastModifiedDate   ' +tempLastModifiedDate  );
                    tempdatMonToLastUpdated.put(tempDatMon, tempLastModifiedDate);
                     system.debug(' ---- dat mon id: '+tempDatMon +' tempLastModifiedDate  ' + tempLastModifiedDate);
                }else{
                    tempdatMonToLastUpdated.put(tempDatMon,'');
                    system.debug(' ---- dat mon id: '+tempDatMon +' tempLastModifiedDate  ' + 'date is null');
                }
               
                //tempdatMonToLastUpdated.add(tempdatMonToLastUpdateMap);
            }
            system.debug(' ---- tempdatMonToLastUpdated' + tempdatMonToLastUpdated.size());
            return tempdatMonToLastUpdated ;
        }
    }*/

    public class SRW_Report2Table2 extends SRW_ReportData {
        public String header    {get; set;}

        public SRW_Report2Table2(String header) {
            this.header=header;
        }
    }

    // ###################################################################################
    // ########################### REPORT 3 & 4 ##########################################
    // ################# Product List by Status ##########################################
    // ################# Product List by Brand ###########################################
    // ###################################################################################

    public class SRW_Report34Table1 extends SRW_ReportData {
        public String brandCode {get; set;}
        public String  prodName {get;set;}
        public String  ndcNrb {get;set;}
        public Datetime  effDate {get;set;}
        public Datetime  deactivDate {get;set;}
        public String  comments {get;set;}
        public String  status {get;set;}

        public SRW_Report34Table1(String brandCode,String prodName,String ndcNrb,Datetime effDate,Datetime deactivDate,String comments,String status) {
            this.brandCode=brandCode;
            this.prodName=prodName;
            this.ndcNrb=ndcNrb;
            this.effDate=effDate;
            this.deactivDate=deactivDate;
            this.comments=comments;
            if(status == 'true')
                this.status ='Active';
            else if(status=='false')
                this.status = 'Inactive'; 
        }
    }

    // ###################################################################################
    // ########################### REPORT 5 ##############################################
    // ################# Prescriber List by Trading Partner ##############################
    // ###################################################################################
    
    public class SRW_Report5Table1 extends SRW_ReportData {
        public String tpid {get; set;}
        public String tpName {get; set;}
        public String tpAddress {get; set;} 
        public String tpStatus {get; set;}
        public String poName {get; set;}
        public String typeOfIdent {get; set;}
        public String identValue {get; set;}
        public String streetAddress1 {get; set;}
        public String streetAddress2 {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String zip {get; set;}
        public String locIdent {get; set;}

        public SRW_Report5Table1(String tpid, String tpName,String tpAddress,String tpStatus,String poName,String typeOfIdent,String identValue,String streetAddress1,String streetAddress2,String city,String state,String zip,String locIdent) {
            this.tpid = tpid;
            this.tpName=tpName;
            this.tpAddress=tpAddress;   
            this.tpStatus=tpStatus;
            this.poName=poName;
            this.typeOfIdent=typeOfIdent;
            this.identValue=identValue;
            this.streetAddress1=streetAddress1;
            this.streetAddress2=streetAddress2;
            this.city=city;
            this.state=state;
            this.zip=zip;
            this.locIdent=locIdent;
        }
    }
        
    // ###################################################################################
    // ########################### REPORT 6 ##############################################
    // ################# Trading Partner Sales Activity ##################################
    // ###################################################################################
    
    public class SRW_Report6Table1 extends SRW_ReportData implements Comparable {
        public String tpid          {get; set;}
        public String dataMonth     {get; set;}
        public String tpName        {get; set;}
        public String tpAddress     {get; set;} 
        public String tpStatus      {get; set;}
        public String presid        {get; set;}
        public String presName      {get; set;}
        public String product       {get; set;}
        public String quantity      {get; set;}
        public String year          {get; set;}
        public Decimal month        {get; set;}


        public SRW_Report6Table1(String tpid, String dataMonth, String tpName,String tpAddress,String tpStatus,String presid,String presName,String product,String quantity, String year, Decimal month) {
            this.tpid=tpid;
            this.dataMonth = dataMonth;
            this.tpName=tpName;
            this.tpAddress=tpAddress;   
            this.tpStatus=tpStatus;
            this.presid=presid;
            this.presName=presName;
            this.product=product;
            this.quantity=quantity;
            this.year=year;
            this.month=month;
        }

        public Integer compareTo(Object compareTo) {

            SRW_Report6Table1 compareToWrap = (SRW_Report6Table1)compareTo;         
            if (this.year > compareToWrap.year) 
                return -1;
            else if(this.year < compareToWrap.year) 
                return 1;
            else {
                if(this.month > compareToWrap.month) 
                    return -1;
                else if(this.month < compareToWrap.month)
                    return 1;
            }
            return 0;       
        }
    }

    public class SRW_Report6Table2 extends SRW_ReportData{
        public String tpId {get; set;}
        public String tpName {get; set;}
        public List<SRW_Report6ProductTotals> prodTotals {get; set;} 

        public SRW_Report6Table2(String tpId, String tpName, List<SRW_Report6ProductTotals> prodTotals) {
            this.tpId = tpId;
            this.tpName = tpName;
            this.prodTotals = prodTotals;
        }
        
        public SRW_Report6Table2() {
        } 
    }   

    public class SRW_Report6ProductTotals {
        public String productName {get; set;}
        public List<SRW_Report6YearData> years {get; set;}

        public SRW_Report6ProductTotals(String productName, List<SRW_Report6YearData> years) {
            this.productName = productName;
            this.years = years;
        }

    }

    public class SRW_Report6YearData {
        public String year {get; set;}
        public Decimal yearTotal {get; set;}
        public SRW_Report6QuaterData quater1 {get; set;}
        public SRW_Report6QuaterData quater2 {get; set;}
        public SRW_Report6QuaterData quater3 {get; set;}
        public SRW_Report6QuaterData quater4 {get; set;}

        public SRW_Report6YearData(String year) {
            this.year = year;
            this.yearTotal = 0;
            this.quater1 = new SRW_Report6QuaterData();
            this.quater2 = new SRW_Report6QuaterData();
            this.quater3 = new SRW_Report6QuaterData();
            this.quater4 = new SRW_Report6QuaterData();
        }

        public void countYearTotal() {
            Decimal total = 0;

            if(quater1.quaterTotal != null)
                total += quater1.quaterTotal;
            if(quater2.quaterTotal != null)
                total += quater2.quaterTotal;
            if(quater3.quaterTotal != null)
                total += quater3.quaterTotal;
            if(quater4.quaterTotal != null)
                total += quater4.quaterTotal;
            this.yearTotal = total;
        }
    }

    public class SRW_Report6QuaterData {
        public List<SRW_Report6MonthData> months {get; set;}
        public Decimal quaterTotal {get; set;}

        public SRW_Report6QuaterData() {
            this.months = new List<SRW_Report6MonthData>();
            this.quaterTotal = 0;
        }

        public void countTotal() {
            Decimal total = 0;
            if(this.months == null) {
                this.quaterTotal = total;
                return;
            }
            for(SRW_Report6MonthData md : this.months) {
                if(md.quantity!=null)
                    total += md.quantity;
            }
            this.quaterTotal = total;
        }
    }

    public class SRW_Report6MonthData {
        public String month {get; set;}
        public Decimal quantity {get; set;}

        public SRW_Report6MonthData(String month, Decimal quantity) {
            this.month = month;
            this.quantity = quantity;
        }
    }


    // ###################################################################################
    // ########################### REPORT 7 ##############################################
    // ################# Trading Partners Identifier Match Not found #####################
    // ###################################################################################
    

    

    public class SRW_Report7Table1 extends SRW_ReportData {
        public String tpid {get; set;}
        public String tpName {get; set;}
        public String tpAddress {get; set;}
        public String typeOfIdent {get; set;}
        public String identValue {get; set;}
        public String contactName {get; set;}
        public String contactPhone {get; set;}
        public String logDate {get; set;}

        public SRW_Report7Table1(String tpid, String tpName,String tpAddress,String typeOfIdent,String identValue,String contactName,String contactPhone,String logDate) {
            this.tpid = tpid;
            this.tpName=tpName;
            this.tpAddress=tpAddress;
            this.typeOfIdent=typeOfIdent;
            this.identValue=identValue;
            this.contactName=contactName;
            this.contactPhone=contactPhone;
            this.logDate=logDate;
        }
    }

    // ###################################################################################
    // ########################### REPORT 8 ##############################################
    // ################# Prescriber/Organization Identifier Match Not found ##############
    // ###################################################################################

    public class SRW_Report8Table1 extends SRW_ReportData  {
        public String poid {get; set;}
        public String tpName {get; set;}
        public String poName {get; set;}
        public String poAddr {get; set;}
        public String typeOfIdent {get; set;}
        public String identValue {get; set;}
        public String contactName {get; set;}
        public String contactPhone {get; set;}
        public String logDate {get; set;}

        public SRW_Report8Table1(String poid, String tpName,String poName,String poAddr,String typeOfIdent,String identValue,String contactName,String contactPhone,String logDate) {
            this.poid = poid;
            this.tpName=tpName;
            this.poName=poName;
            this.poAddr=poAddr;
            this.typeOfIdent=typeOfIdent;
            this.identValue=identValue;
            this.contactName=contactName;
            this.contactPhone=contactPhone;
            this.logDate=logDate;
        }
    }
    // ###################################################################################
    // ########################### REPORT 9 ##############################################
    // ################# Historical Data Month Backfill ##################################
    // ###################################################################################
    public class SRW_Report9Table1 extends SRW_ReportData implements Comparable{
        public String dataMonth {get; set;}
        public String tradingPartnerName {get;set;}
        public String tradingPartnerAddress {get;set;}
        public String customerName {get;set;}
        public String productName {get;set;}
        public Decimal quantity {get;set;}
        public String lastUpdated {get;set;}

        public SRW_Report9Table1(String dataMonth, String tradingPartnerName, String tradingPartnerAddress, String customerName, String productName, Decimal quantity, Datetime lastUpdated){
            this.dataMonth = dataMonth;
            this.tradingPartnerName = tradingPartnerName;
            this.tradingPartnerAddress = tradingPartnerAddress;
            this.customerName = customerName;
            this.productName = productName;
            this.quantity = quantity;
            if(lastUpdated != null)
                this.lastUpdated = lastUpdated.format('MM/dd/yyyy hh:mm a');
        }

        public Integer compareTo(Object compareTo){
            SRW_Report9Table1 temp = (SRW_Report9Table1) compareTo;
            if(dataMonth.equals(temp.dataMonth)){
                if(tradingPartnerName.equals(temp.tradingPartnerName)){
                    if(customerName.equals(temp.customerName)){
                        return productName.compareTo(temp.productName);
                    } else {
                        return customerName.compareTo(temp.customerName);
                    }
                } else {
                    return tradingPartnerName.compareTo(temp.tradingPartnerName);
                }
            } else {
                return dataMonth.compareTo(temp.dataMonth);
            }
        }

    }

    public class SRW_Report9Table2 extends SRW_ReportData{
        public String datayear {get; set;}
        public String datamonth {get;set;}
        public String tradingPartnerName {get;set;}
        public String productName {get;set;}
        public String ndc {get;set;}
        public Decimal quantitySum {get;set;}

        public SRW_Report9Table2(String datayear, String datamonth, String tradingPartnerName, String productName, String ndc, Decimal quantitySum){
            this.dataMonth = dataMonth;
            this.datayear = datayear;
            this.tradingPartnerName = tradingPartnerName;
            this.ndc = ndc;
            this.productName = productName;
            this.quantitySum = quantitySum;
        }
    }


    public class SRW_Report9SalesDataKey{
        public String ndcNumber {get;set;}
        public id tradingPartnerdataMonthId {get; set;}
        public id prescLoc {get; set;}

        public SRW_Report9SalesDataKey(String ndcNumber, id prescLoc, id tradingPartnerdataMonthId){
            this.tradingPartnerdataMonthId = tradingPartnerdataMonthId;
            this.ndcNumber = ndcNumber;
            this.prescLoc = prescLoc;
        }
        public Boolean equals(Object obj){
            if(obj instanceof SRW_Report9SalesDataKey){
                SRW_Report9SalesDataKey temp = (SRW_Report9SalesDataKey) obj;
                //system.debug('this : ' + this + '   obj: ' + obj);
                //system.debug('equals? ' + (ndcNumber.equals(temp.ndcNumber) && (prescLoc == temp.prescLoc) && (tradingPartnerdataMonthId == temp.tradingPartnerdataMonthId)));
                return  (ndcNumber.equals(temp.ndcNumber) && (prescLoc == temp.prescLoc) && (tradingPartnerdataMonthId == temp.tradingPartnerdataMonthId));
            }
            return false;
        }
    }
    public class SRW_Report9SalesDataValue {
        public Decimal quantity {get; set;}
        public Decimal sequenceNumber {get; set;}
        public String ndcNumber {get;set;}
        public String name {get;set;}
        public id salesId {get; set;}

        public SRW_Report9SalesDataValue(Decimal quantity, Decimal sequenceNumber, String ndcNumber, String Name, id salesId){
            this.quantity = quantity;
            this.sequenceNumber = sequenceNumber;
            this.ndcNumber  = ndcNumber;
            this.name = name;
            this.salesId = salesId;
        }
    }
    // ###################################################################################
    // ########################### REPORT 10 #############################################
    // ################# Historical Sales Data Update ####################################
    // ###################################################################################

    public class SRW_Report10Table1 extends SRW_ReportData {
        public String hdm {get; set;}
        public String tpName {get; set;}
        public String tpAddress {get; set;}
        public String presName {get; set;}
        public String prodName {get; set;}
        public String quantity1 {get; set;}
        public String prevSubmission {get; set;}
        public String quantity2 {get; set;}
        public String lastUpdated {get; set;}

        public SRW_Report10Table1(String hdm, String tpName, String tpAddress, String presName, String prodName, String quantity1, String prevSubmission, String quantity2, String lastUpdated) {
            this.hdm  = hdm;
            this.tpName  = tpName;
            this.tpAddress  = tpAddress;
            this.presName  = presName;
            this.prodName  = prodName;
            this.quantity1  = quantity1;
            this.prevSubmission  = prevSubmission;
            this.quantity2  = quantity2;
            this.lastUpdated  = lastUpdated;
        }
    }

    public class SRW_Report10Table2 extends SRW_ReportData {
        public String hdm {get; set;}
        public String tpName {get; set;}
        public String prodName {get; set;}
        public String ndc {get; set;}
        public String ptq {get; set;}
        public String lutQuantity {get; set;}

        public SRW_Report10Table2(String hdm, String tpName, String prodName, String ndc, String ptq, String lutQuantity) {
            this.hdm  = hdm;
            this.tpName  = tpName;
            this.prodName  = prodName;
            this.ndc  = ndc;
            this.ptq  = ptq;
            this.lutQuantity  = lutQuantity;
        }

    }
    // ###################################################################################
    // ########################### REPORT 11 #############################################
    // ################# Opened Data Month Request #######################################
    // ###################################################################################


        public class SRW_Report11Table1 extends SRW_ReportData  {
        public String hdmo {get; set;}
        public String tpName {get; set;}
        public String baUsername {get; set;}
        public String dmOpenedDate {get; set;}
        public String hsdUpdateFlag {get; set;}
        public String rSweepDate {get; set;}

        public SRW_Report11Table1 (String hdmo ,String tpName ,String baUsername ,String dmOpenedDate ,String hsdUpdateFlag ,String rSweepDate) {
            this.hdmo = hdmo;
            this.tpName = tpName;
            this.baUsername = baUsername;
            this.dmOpenedDate = dmOpenedDate;
            this.hsdUpdateFlag = hsdUpdateFlag;
            this.rSweepDate = rSweepDate;
        }
    }

    // ###################################################################################
    // ########################### REPORT 12 #############################################
    // ################# Variance ########################################################
    // ###################################################################################
    
    public class SRW_Report12Table1 extends SRW_ReportData   implements Comparable {
        public String dataMonth {get;set;}
        public String tradingPartnerName {get;set;}
        public String tradingPartnerAddress {get;set;}
        public String customerName {get;set;}
        public String productName {get;set;}
        public String quantity {get;set;}
        public String submissionTimeStamp {get;set;}
        public String sweepResweepDate {get;set;}

        public SRW_Report12Table1(String dataMonth, String tradingPartnerName, String tradingPartnerAddress, String customerName, String productName, String quantity, Datetime submissionTimeStamp, Datetime sweepResweepDate){
            this.dataMonth = dataMonth;
            this.tradingPartnerName = tradingPartnerName;
            this.tradingPartnerAddress = tradingPartnerAddress;
            this.customerName = customerName;
            this.productName = productName;
            this.quantity = quantity;
            if(submissionTimeStamp != null)
                this.submissionTimeStamp = submissionTimeStamp.format('MM/dd/yyyy hh:mm a');
            else 
                this.submissionTimeStamp = '';
            if(sweepResweepDate != null)
                this.sweepResweepDate = sweepResweepDate.format('MM/dd/yyyy hh:mm a');
            else 
                this.sweepResweepDate = '';
        }

        public SRW_Report12Table1(String dataMonth, String tradingPartnerName, String tradingPartnerAddress, String customerName, String productName, String quantity, String submissionTimeStampString, String sweepResweepDateString){
            this.dataMonth = dataMonth;
            this.tradingPartnerName = tradingPartnerName;
            this.tradingPartnerAddress = tradingPartnerAddress;
            this.customerName = customerName;
            this.productName = productName;
            this.quantity = quantity;
            this.submissionTimeStamp = submissionTimeStampString;
            this.sweepResweepDate = sweepResweepDateString;
        }

        public Integer compareTo(Object compareTo){
            SRW_Report12Table1 temp = (SRW_Report12Table1) compareTo;
            if(dataMonth.equals(temp.dataMonth)){
                if(tradingPartnerName.equals(temp.tradingPartnerName)){
                    if(customerName.equals(temp.customerName)){
                        if(productName.equals(temp.productName)){
                            return (submissionTimeStamp > temp.submissionTimeStamp) ? 1 : -1 ;
                        } else {
                            return productName.compareTo(temp.productName);
                        }
                    } else {
                        return customerName.compareTo(temp.customerName);
                    }
                } else {
                    return tradingPartnerName.compareTo(temp.tradingPartnerName);
                }
            } else {
                return dataMonth.compareTo(temp.dataMonth);
            }
        }

        public Boolean isTheSameToProduct(SRW_Report12Table1 toCompare){
            return (dataMonth.equals(toCompare.dataMonth) && tradingPartnerName.equals(toCompare.tradingPartnerName) && customerName.equals(toCompare.customerName) && productName.equals(toCompare.productName));
        }
    }

    public class SRW_Report12Table2 extends SRW_ReportData implements Comparable{
        public String dataMonth {get; set;}
        public String tradingPartnerName {get; set;}
        public String productName {get; set;}
        public String ndc {get; set;}
        public String lastButOneQuantity {get;set;}
        public Decimal quantity {get; set;}

        public SRW_Report12Table2(String dataMonth, String tradingPartnerName, String productName, String ndc, String lastButOneQuantity, Decimal quantity){
            this.dataMonth = dataMonth;
            this.tradingPartnerName = tradingPartnerName;
            this.productName = productName;
            this.ndc = ndc;
            this.lastButOneQuantity = lastButOneQuantity;
            this.quantity = quantity;
        }

        public Integer compareTo(Object compareTo){
            SRW_Report12Table2 temp = (SRW_Report12Table2) compareTo;
            if(dataMonth.equals(temp.dataMonth)){
                if(tradingPartnerName.equals(temp.tradingPartnerName)){     
                    return productName.compareTo(temp.productName);
                } else {
                    return tradingPartnerName.compareTo(temp.tradingPartnerName);
                }
            } else {
                return dataMonth.compareTo(temp.dataMonth);
            }
        }
    }

    public class SRW_Report12LastButOneKey {
        public String datayear {get; set;}
        public String dataMonth {get; set;}
        public String tradingPartnerName {get;set;}
        public String ndc {get; set;}

        public SRW_Report12LastButOneKey(String datayear, String dataMonth, String tradingPartnerName, String ndc){
            this.datayear = datayear;
            this.dataMonth = dataMonth;
            this.tradingPartnerName = tradingPartnerName;
            this.ndc = ndc;
        }

        public Boolean equals(Object obj){
            if(obj instanceof SRW_Report12LastButOneKey){
                SRW_Report12LastButOneKey temp = (SRW_Report12LastButOneKey) obj;
                return  (ndc.equals(temp.ndc) && (datayear.equals(temp.datayear)) && (dataMonth.equals(temp.dataMonth)) && (tradingPartnerName.equals(temp.tradingPartnerName)));
            }
            return false;
        }
    }

    public class SRW_Report12SalesDataKey{
        public String ndcNumber {get;set;}
        public id tradingPartnerdataMonthId {get; set;}
        public id prescLoc {get; set;}

        public SRW_Report12SalesDataKey(String ndcNumber, id prescLoc, id tradingPartnerdataMonthId){
            this.tradingPartnerdataMonthId = tradingPartnerdataMonthId;
            this.ndcNumber = ndcNumber;
            this.prescLoc = prescLoc;
        }
        public Boolean equals(Object obj){
            if(obj instanceof SRW_Report12SalesDataKey){
                SRW_Report12SalesDataKey temp = (SRW_Report12SalesDataKey) obj;
                if (ndcNumber != null ){
                    return (ndcNumber.equals(temp.ndcNumber) && (prescLoc == temp.prescLoc) && (tradingPartnerdataMonthId == temp.tradingPartnerdataMonthId));
                } else{
                    return (temp.ndcNumber == null && (prescLoc == temp.prescLoc) && (tradingPartnerdataMonthId == temp.tradingPartnerdataMonthId));
                } 
            }
            return false;
        }
        public Integer hashCode(){
            return (((ndcNumber.hashCode()) ^ (String.valueOf(tradingPartnerdataMonthId).hashCode())) ^ (String.valueOf(prescLoc).hashCode()));
        }
    }
    public class SRW_Report12SalesDataValue implements Comparable{
        public Decimal quantity {get; set;}
        public Decimal sequenceNumber {get; set;}
        public String ndcNumber {get;set;}
        public String name {get;set;}
        public id salesId {get; set;}

        public SRW_Report12SalesDataValue(Decimal quantity, Decimal sequenceNumber, String ndcNumber, String Name, id salesId){
            this.quantity = quantity;
            this.sequenceNumber = sequenceNumber;
            this.ndcNumber  = ndcNumber;
            this.name = name;
            this.salesId = salesId;
        }

        public Integer compareTo(Object compareTo){
            SRW_Report12SalesDataValue compateSalesDataValue = (SRW_Report12SalesDataValue) compareTo;
            return name.compareTo(compateSalesDataValue.name);
        }
    }

    // ###################################################################################
    // ########################### REPORT 13 #############################################
    // ################# Login History ###################################################
    // ###################################################################################
    

    public class SRW_Report13Table1 extends SRW_ReportData{
        public String username {get; set;}
        public String tpName {get; set;}
        public String loginTime {get; set;}
        public String loginStatus {get; set;}

        public SRW_Report13Table1(String username, String tpName,String loginTime,String loginStatus) {
            this.username = username;
            this.tpName=tpName;
            this.loginTime=loginTime;
            this.loginStatus=loginStatus;
        }
    }

    // ###################################################################################
    // ########################### REPORT 15 #############################################
    // ################# Prescriber List by Trading Partner bz data month#################
    // ###################################################################################
    public class SRW_Report15Table1 extends SRW_ReportData{
        public String dataMonthName {get; set;}
        public String tpName {get; set;}
        public String poName {get; set;}
        public String presNbr {get; set;}

        public String monthId {get; set;}
        public String tpId {get; set;}

        public SRW_Report15Table1(String dataMonthName, String tpName,String poName,String presNbr,String monthId,String tpId) {
            this.dataMonthName = dataMonthName;
            this.tpName=tpName;
            this.poName=poName; 
            this.presNbr=presNbr;
            this.monthId = monthId;
            this.tpId = tpId;

        }
    }
}