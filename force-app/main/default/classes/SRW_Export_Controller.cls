public without sharing class SRW_Export_Controller {
    
    public List<ContentWrapper> contentList {get;set;}
    public List<String> headerList {get;set;}
    public List<String> contentCSV {get;set;}
    public SRW_SalesDataReportExportUtils salesDataReportExportUtils {get; set;}
    public Boolean salesDataReport {get; set;}
    public Boolean history {get; set;}
    public String fileName {get;set;}

    private String pageMode;
    private String csvMode;
    private String filter;
    private String brandFilter;
    

    public SRW_Export_Controller() {
        
        pageMode = ApexPages.currentPage().getParameters().get('mode');
        csvMode =  ApexPages.currentPage().getParameters().get('csv');
        filter =  ApexPages.currentPage().getParameters().get('filter');
        system.debug(filter );
        brandFilter = ApexPages.currentPage().getParameters().get('brand');
        fileName = 'export';
        contentList = new List<ContentWrapper>();
        headerList = new List<String>();
        contentCSV = new List<String>();

        salesDataReport = false;
        history = false;


        if(pageMode == 'Products') {
            fileName = 'ProductsReport_' + system.now();
            headerList = new List<String>{'Brand','Product Name','NDC','Product Effective Date','Product De-activation Date','Comments','Product Status'};
            String queryString  = 'Select Id,active__c,SRW_Product_De_activation_Date_gne__c,SRW_Product_Effective_Date_gne__c,Product_Type_vod__c,Name,NDC_Number_gne__c,SRW_Comments_gne__c,Brand_Code_gne__c  From Product_vod__c  where Product_Type_vod__c = \'SRW\' ';
            if(filter == 'Active') 
                queryString += ' and active__c = true';
            else if (filter == 'Inactive')
                queryString += ' and active__c = false';

            if(brandFilter != null && brandFilter != '' && brandFilter != '[]' && brandFilter != '[all]') {
                queryString += ' and Brand_Code_gne__c IN ' + changeTableTOSoqlFormat(brandFilter);
            }

            queryString += ' ORDER BY Brand_Code_gne__c, Name ASC';

            system.debug('MICK_LOKO : query ->  ' + queryString);

            for(Product_vod__c tmp : Database.query(queryString) ){

                    ContentWrapper tempContent = new ContentWrapper();
                        tempContent.column1Body = tmp.Brand_Code_gne__c;
                        tempContent.column2Body = tmp.Name;
                        tempContent.column3Body = tmp.NDC_Number_gne__c;
                        tempContent.column4Body = String.valueOf(tmp.SRW_Product_Effective_Date_gne__c);
                        tempContent.column5Body = String.valueOf(tmp.SRW_Product_De_activation_Date_gne__c);
                        tempContent.column6Body = tmp.SRW_Comments_gne__c;
                        tempContent.column7Body = tmp.active__c ? 'Active' : 'Inactive';
                    contentList.add(tempContent);

            }

            if(csvMode == 'yes') {
                contentCSV.add(generateCSVContent(contentList,headerList));
            }
        }

        else if(pageMode == 'partner'){

            fileName = 'TradingPartnersReport_' + system.now();
            headerList = new List<String>{'Trading Partner Name','Account Status','Contract Effective Date','Contract Termination Date'};
            List<TradingPartnerWrapper> tpList = new List<TradingPartnerWrapper>();
            tpList = findTradingPartnersByStatus(filter);
            for(TradingPartnerWrapper tmp : tpList){
                ContentWrapper tempContent = new ContentWrapper();
                tempContent.column1Body = tmp.tradingPartner.Trading_Partner_Name_gne__c;
                tempContent.column2Body = tmp.tradingPartnerStatus;
                tempContent.column3Body = string.ValueOf(tmp.tradingPartner.Contract_Effective_Date_gne__c);
                tempContent.column4Body = string.ValueOf(tmp.tradingPartner.Contract_Termination_Date_gne__c);
            contentList.add(tempContent);
            }
            if(csvMode == 'yes') {
                contentCSV.add(generateCSVContent(contentList,headerList));
            }
        }

        else if(pageMode == 'Prescribers') {
            fileName = 'PrescribersReport_' + system.now();

            headerList = new List<String>{'Prescriber / Organization Name','Type of Identifier','Identifier Value','Street Address 1', 'Street Address 2', 'City', 'State', 'ZIP', 'Location Identifier'};
            List<Profile> FOIMs = [SELECT Name, Id FROM Profile WHERE (Id = :UserInfo.getProfileId() AND Name = 'GNE-GST-Partner-External')];
            Boolean isFOIM = FOIMs.isEmpty();
            User currentUser = [SELECT id, ContactId FROM User WHERE id = :UserInfo.getUserId()];
            
            List<SRW_Prscr_or_Org_Location__c> presList;
            if(!isFOIM)
                presList = [SELECT id, Prescriber_or_Organization_gne__r.Type_gne__c, Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,  Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,  Prescriber_or_Organization_gne__r.Organization_Name_gne__c, Unique_Identifier_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c, Street_Address_1_gne__c, Street_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Location_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE isActive_gne__c = true and Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_gne__c =: currentUser.ContactId  ORDER BY Unique_Identifier_gne__c Asc];
            else {
                List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: currentUser.Id]; 
                if(!mimicData.isEmpty()) {
                    presList = [SELECT id, Prescriber_or_Organization_gne__r.Type_gne__c, Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,  Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,  Prescriber_or_Organization_gne__r.Organization_Name_gne__c, Unique_Identifier_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c, Street_Address_1_gne__c, Street_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Location_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE isActive_gne__c = true and Prescriber_or_Organization_gne__r.Trading_Partner_gne__c =: mimicData.get(0).SRW_Trading_Partner_Profile_gne__c ORDER BY Unique_Identifier_gne__c Asc];  
                }
            }

            for(SRW_Prscr_or_Org_Location__c tmp : presList ){
                ContentWrapper tempContent = new ContentWrapper();
                    tempContent.column1Body = tmp.Prescriber_or_Organization_gne__r.Type_gne__c.equals('Prescriber') ? tmp.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + tmp.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c : tmp.Prescriber_or_Organization_gne__r.Organization_Name_gne__c;
                    tempContent.column2Body = tmp.Type_of_Identifier_gne__c;
                    tempContent.column3Body = tmp.Identifier_gne__c;
                    tempContent.column4Body = tmp.Street_Address_1_gne__c;
                    tempContent.column5Body = tmp.Street_Address_2_gne__c;
                    tempContent.column6Body = tmp.City_gne__c;
                    tempContent.column7Body = tmp.State_gne__c;
                    tempContent.column8Body = tmp.Zip_Code_gne__c;
                    tempContent.column9Body = tmp.Location_Identifier_gne__c;
                contentList.add(tempContent);
            }
            if(csvMode == 'yes') {
                contentCSV.add(generateCSVContent(contentList,headerList));
            }
        }

        else if(pageMode == 'salesDataReport') {
            fileName = 'SalesDataReport_' + system.now();

            salesDataReport = true;
            String tradingPartnerDataMonth = ApexPages.currentPage().getParameters().get('tpdm');
            String tradingPartner = ApexPages.currentPage().getParameters().get('tp');
            String totals = ApexPages.currentPage().getParameters().get('totals');
            String historyReport = ApexPages.currentPage().getParameters().get('history');
            String customer = ApexPages.currentPage().getParameters().get('customer');
            Boolean isQuantityGreaterThanZero = 'yes'.equals(ApexPages.currentPage().getParameters().get('isquantitygreater0')); 
            history = 'yes'.equals(historyReport) ? true : false;
            salesDataReportExportUtils = new SRW_SalesDataReportExportUtils(tradingPartner, tradingPartnerDataMonth, history, customer, isQuantityGreaterThanZero);
            if(csvMode == 'yes') {
                system.debug('totals.equals(yes) : ' + totals.equals('yes'));
                //salesDataReportExportUtils.prepareCsvContent();
                contentCSV.add(totals.equals('yes') ? salesDataReportExportUtils.csvTotals() : salesDataReportExportUtils.csvPerPerscriber());
            }
        }

    }
    private String generateCSVContent(List<ContentWrapper> data,List<String> headers){

        String fullCSV = '';

                for(String tmp : headers) {

                    fullCSV +=  '\"' + tmp + '\",';
                }
                fullCSV += '\n';
                for(ContentWrapper tempRow : data) {

                    fullCSV += headerList.size() >=1 ? '\"' + valueOrBlank(tempRow.column1Body) + '\",' : '';
                    fullCSV += headerList.size() >=2 ? '\"' + valueOrBlank(tempRow.column2Body) + '\",' : '';
                    fullCSV += headerList.size() >=3 ? '\"' + valueOrBlank(tempRow.column3Body) + '\",' : '';
                    fullCSV += headerList.size() >=4 ? '\"' + valueOrBlank(tempRow.column4Body) + '\",' : '';
                    fullCSV += headerList.size() >=5 ? '\"' + valueOrBlank(tempRow.column5Body) + '\",' : '';
                    fullCSV += headerList.size() >=6 ? '\"' + valueOrBlank(tempRow.column6Body) + '\",' : '';
                    fullCSV += headerList.size() >=7 ? '\"' + valueOrBlank(tempRow.column7Body) + '\",' : '';
                    fullCSV += headerList.size() >=8 ? '\"' + valueOrBlank(tempRow.column8Body) + '\",' : '';
                    fullCSV += headerList.size() >=9 ? '\"' + valueOrBlank(tempRow.column9Body) + '\",' : '';
                    fullCSV +=  '\n';

                }
                
        return fullCSV;
    }

    private String changeTableTOSoqlFormat(String param) {
            
            param = param.replace(' ,', ',');
            param = param.replace(', ', ',');
            param = param.replace('[', '(\'');
            param = param.replace(']', '\')');  
            param = param.replace(',', '\',\''); 

            return param;

    }

    private String valueOrBlank(String val) {

        if(val == null)
            return '';
        else
            return val;
    }
    public class ContentWrapper {

        public String column1Body {get;set;}
        public String column2Body {get;set;}
        public String column3Body {get;set;}
        public String column4Body {get;set;}
        public String column5Body {get;set;}
        public String column6Body {get;set;}
        public String column7Body {get;set;}
        public String column8Body {get;set;}
        public String column9Body {get;set;}

        public ContentWrapper(){

        }

    }
    
        public  List<TradingPartnerWrapper> findTradingPartnersByStatus(String tpStatus){
            List<TradingPartnerWrapper> tradingPartnerList = new List<TradingPartnerWrapper>();
            list<string> statuses;
            if(tpStatus==null || tpstatus =='' || tpStatus=='All'){
                statuses = new LIST<string>{'Active','Inactive','Locked'};
            }else{
                statuses = new LIST<string>{tpStatus};
            }
             // nowy mechanizm
             SRW_Trading_Partner_Profile__c[] tpList = [Select Id,Contact_gne__c from SRW_Trading_Partner_Profile__c];
            //map ContactId to TPProf
            Map<String, String> conId2TPProfId = new map<String,String>();
            Map<string, string> tpId2status = new map<String, String>();
            List<SRW_Security_Community_Data__c> securCommList = new List<SRW_Security_Community_Data__c>();
            securCommList = [Select Id,Trading_Partner_gne__c, Trading_Partner_gne__r.Contact_gne__c, Status_gne__c from SRW_Security_Community_Data__c
                                                                WHERE Trading_Partner_gne__r.Contact_gne__c != null and Status_gne__c in :statuses];
            
             map<string, SRW_Security_Community_Data__c> conId2SecurComDat = new map<string, SRW_Security_Community_Data__c>();
            for(SRW_Security_Community_Data__c tempsecCommDat : securCommList){
                system.debug(tempsecCommDat.Trading_Partner_gne__r.Contact_gne__c+' \n\n'+tempsecCommDat.Status_gne__c);
                conId2TPProfId.put(tempsecCommDat.Trading_Partner_gne__r.Contact_gne__c, tempsecCommDat.Trading_Partner_gne__c);
                tpId2status.put(tempsecCommDat.Trading_Partner_gne__c, tempsecCommDat.Status_gne__c);
                system.debug('Contact_gne__c: '+tempsecCommDat.Trading_Partner_gne__r.Contact_gne__c);
                conId2SecurComDat.put(tempsecCommDat.Trading_Partner_gne__r.Contact_gne__c, tempsecCommDat);
            }
            //map userId to security status
            for(UserLogin tempUsrLog : [Select id, UserId, IsFrozen From UserLogin where UserId in (Select Id from User where ContactId in :conId2TPProfId.keySet())]){
                system.debug(tempUsrLog.UserId);
            }
            Map<string,string> conId2Usr = new Map<string,string>{};
            for(User tempUsr : [Select Id, ContactId from User where ContactId in :conId2TPProfId.keySet()]){
                conId2Usr.put(tempUsr.ContactId, tempUsr.Id);
            }
            system.debug('Info');
            //final TPProf list
            string[] tppprodIdList = new string[]{};
            for(string tmpConId : conId2Usr.keySet()){
                tppprodIdList.add(conId2TPProfId.get(tmpConId));
            }
            system.debug('tppprodIdList list: '+tppprodIdList);
            //for(SRW_Trading_Partner_Profile__c tmpTpprof : [select id, name, Active_gne__c, Contact_gne__c, Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, Trading_Partner_Name_gne__c, Trading_Partner_User_Name_gne__c,  Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c, Contact_Email_Address_gne__c from SRW_Trading_Partner_Profile__c where id in :tppprodIdList order by Trading_Partner_Name_gne__c asc ]){
            for(SRW_Trading_Partner_Profile__c tmpTpprof : [select id, name, Active_gne__c, Contact_gne__c, Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, Trading_Partner_Name_gne__c, Trading_Partner_User_Name_gne__c,  Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c, Contact_Email_Address_gne__c from SRW_Trading_Partner_Profile__c where id in :conId2TPProfId.values() order by Trading_Partner_Name_gne__c asc ]){
                string tpStatusForTP = tpId2status.get(tmpTpprof.Id);
                tradingPartnerList.add(new TradingPartnerWrapper(tmpTpprof, tpStatusForTP));
                //tpMap.put(tmpTpprof.Id, tmpTpprof);
            }
                
            
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'tp.size: '+tradingPartnerList.size()));
            system.debug(tradingPartnerList);
            return tradingPartnerList;
         }
         public class TradingPartnerWrapper {
            public SRW_Trading_Partner_Profile__c tradingPartner {get;set;}
            public String tradingPartnerStatus {get; set;}
            
            public TradingPartnerWrapper(SRW_Trading_Partner_Profile__c tradingPartner, string statusFromSecurityObject) {
                this.tradingPartner = tradingPartner;
                this.tradingPartnerStatus = statusFromSecurityObject;
            }
         }
}