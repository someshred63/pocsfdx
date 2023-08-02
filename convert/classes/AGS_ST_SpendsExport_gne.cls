public without sharing class AGS_ST_SpendsExport_gne {
    public List<String> spendIds {get; set;}
    public AGS_ST_SpendSearch_Utils_gne.SpendsData spendData { get; set; }
    public String spendsType                        { get; set; }
    public Boolean showResearch                     { get; set; }
    public String csvFileName                       { get; set; }
    public String fromDate                          { get; set; }
    public String toDate                            { get; set; }
    public Boolean showCmsPaymentId                 { get; set; }
    
    public AGS_ST_SpendsExport_gne() { 
        String spendIdsParam = ApexPages.currentPage().getParameters().get('spendIds');
        if(!String.isBlank(spendIdsParam)) {
            spendIds = new List<String>(spendIdsParam.split(';'));
        } else {
            spendIds = new List<String>();
        }
        
        String spendsTypeParam = ApexPages.currentPage().getParameters().get('spendtype');
        if(!String.isBlank(spendsTypeParam) && 'research'.equals(spendsTypeParam.toLowerCase())) {
            spendsType = 'Research';
            showResearch = true;
        } else {
            spendsType = 'NonResearch';
            showResearch = false;
        }
        // Set showCmsPaymentId flag
        AGS_ST_Settings_gne__c agsStSet = AGS_ST_Utils.getDefaultCustomSettings();
        showCmsPaymentId = false;
        if(agsStSet != null && agsStSet.CmsPaymentIdDisplayDate_gne__c != null) {
            Date displayDate = agsStSet.CmsPaymentIdDisplayDate_gne__c;
            Date currentDate = Date.today();
            if(displayDate <= currentDate) {
                showCmsPaymentId = true;
            }
        }
    }
    
    public PageReference init() {
        //System.debug('---------- 1 ' + spendData.spendList);
        spendData = AGS_ST_SpendSearch_Utils_gne.getSpends(spendsType, spendIds);
        System.debug('---------- 2 ' + spendData.spendList);
        Date oldestSpendDate;
        Date newestSpendDate;
        for(AGS_ST_SpendSearch_Utils_gne.Spend spend : spendData.spendList){
            if(oldestSpendDate == null || oldestSpendDate > spend.eventTime){
                oldestSpendDate = spend.eventTime;
            }
        }
        fromDate = oldestSpendDate.format();  // String.valueOf(oldestSpendDate);
        toDate = Date.today().format(); 
        
        csvFileName = 'text/csv#' + 'SunshineTrack_' + UserInfo.getLastName() + '_' + fromDate + '_' + toDate + '_' + spendsType + 'Payments.csv';
        
        //csvFileName = 'application/x-excel#' + 'SunshineTrack_' + spendData.hcpName + '_' + fromDate + '_' + spendsType + '.csv';
        //csvFileName = 'application/vnd.ms-excel#' + 'SunshineTrack_' + spendData.hcpName + '_' + fromDate + '_' + spendsType + '.csv';
        return null;
    }
}