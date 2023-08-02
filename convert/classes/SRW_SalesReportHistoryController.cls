public class SRW_SalesReportHistoryController {

    public SRW_Trading_Partner_Profile__c tradingPartner {get; set;}
    public List<SelectOption> avaliableTPDataMonths;
    public String choosenTPDataMonthId {get; set;}
    public SRW_DataMonths__c choosenDataMonth {get; set;}

    public String choosenCustomerId {get; set;}
    public List<SelectOption> avaliableCustomers;

    public String isQuantityGreaterThanZero {get; set;}
    public List<SelectOption> avaliableQuantities;


    public Boolean noTPDataMonths {get; set;}
    public Boolean showDataMonthReport {get; set;}
    public Boolean noSalesReported {get; set;}
    public Boolean isFOIM {get; set;}
    public Boolean noAccess {get; set;}
    public String monthString;

    transient List<AggregateResult> countProductsSalesForChoosenDataMonth;
    transient List<salesDataPerPrescriberWrapper> salesDataPerPrescriber {private get; set;}

    public String selectedFileFormat {get;set;}
    public List<PageReference> exportToCsvUrls;

    public SRW_SalesReportHistoryController() {
        List<Profile> FOIMs = [SELECT Name, Id FROM Profile WHERE (Id = :UserInfo.getProfileId() AND Name = 'GNE-GST-Partner-External')];
        isFOIM = FOIMs.isEmpty();
        salesDataPerPrescriber = new List<salesDataPerPrescriberWrapper>();
        User currentUser = [SELECT id, ContactId FROM User WHERE id = :UserInfo.getUserId()];
        if(!isFOIM) {
            tradingPartner = [SELECT Alt_Contact_Email_Address_gne__c, Alt_Contact_First_Name_gne__c, Alt_Contact_Last_Name_gne__c, Alt_Contact_Phone_Extn_gne__c, Alt_Contact_Phone_gne__c,
                         Contact_Email_Address_gne__c, Contact_Fax_Number_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c, Contact_Phone_Extn_gne__c, Contact_Phone_gne__c,
                         Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, MCCO_Account_Manger_gne__c, Comment_gne__c, 
                         Trading_Partner_Name_gne__c, Trading_Partner_Phone_gne__c, TP_Phone_Extn_gne__c, Trading_Partner_Fax_Extn_gne__c, Trading_Partner_Fax_gne__c, Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c,
                         City_gne__c, State_gne__c, Zip_Code_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c                 
                         FROM SRW_Trading_Partner_Profile__c 
                         WHERE Contact_gne__c = :currentUser.ContactId LIMIT 1];
        } else {
            List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: currentUser.Id]; 
            if(!mimicData.isEmpty()) {
                tradingPartner = [SELECT Alt_Contact_Email_Address_gne__c, Alt_Contact_First_Name_gne__c, Alt_Contact_Last_Name_gne__c, Alt_Contact_Phone_Extn_gne__c, Alt_Contact_Phone_gne__c,
                         Contact_Email_Address_gne__c, Contact_Fax_Number_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c, Contact_Phone_Extn_gne__c, Contact_Phone_gne__c,
                         Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, MCCO_Account_Manger_gne__c, Comment_gne__c, 
                         Trading_Partner_Name_gne__c, Trading_Partner_Phone_gne__c, TP_Phone_Extn_gne__c, Trading_Partner_Fax_Extn_gne__c, Trading_Partner_Fax_gne__c, Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c,
                         City_gne__c, State_gne__c, Zip_Code_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c                 
                         FROM SRW_Trading_Partner_Profile__c 
                         WHERE Id =: mimicData.get(0).SRW_Trading_Partner_Profile_gne__c LIMIT 1];
            }
        }
        showDataMonthReport = false;
        noSalesReported = false;
        if(tradingPartner == null) {
            noAccess = true;
            return;
        }
        else 
            noAccess = false;


        List<SRW_TP_Data_Months__c> tempTPMonths = avaliableTPDataMonthForCurrentTradingPartner();
        if(tempTPMonths.isEmpty()){
            noTPDataMonths = true;
        }else {
            noTPDataMonths = false;
            choosenDataMonth = [SELECT id, Data_Month_Cal_gne__c FROM SRW_DataMonths__c WHERE id = :tempTPMonths[0].SRW_Data_Month_gne__r.id];
            choosenTPDataMonthId = tempTPMonths[0].id;
        }
        choosenTPDataMonthId = !String.isBlank(ApexPages.currentPage().getParameters().get('datamonth')) ? choosenTPDataMonthId = ApexPages.currentPage().getParameters().get('datamonth') : choosenTPDataMonthId;
        changeChoosenDataMonth();

        isQuantityGreaterThanZero = 'yes';
        choosenCustomerId = 'all';

    }

    public List<SelectOption> getAvaliableTPDataMonths(){
        List<SRW_TP_Data_Months__c> openedDataMonths = avaliableTPDataMonthForCurrentTradingPartner();
        List<SelectOption> options = new List<SelectOption>();
        for (SRW_TP_Data_Months__c odm : openedDataMonths) {
            options.add(new SelectOption(odm.Id, odm.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c));
            system.debug('data month added - id: ' + odm.id + ' || datamonth: ' + odm.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c);
        }
        if(!options.isEmpty() && isFOIM) {
                options.add(new SelectOption('all', 'All'));                
        }
        return options;
    }
    public List<SRW_TP_Data_Months__c> avaliableTPDataMonthForCurrentTradingPartner(){
        return [SELECT id, Name, SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, SRW_Data_Month_gne__r.id FROM SRW_TP_Data_Months__c WHERE Trading_Partner_gne__c = :tradingPartner.id ORDER BY CreatedDate DESC];
    }
    public void changeChoosenDataMonth(){
        if(!'all'.equals(choosenTPDataMonthId) && choosenTPDataMonthId != null) {
                SRW_TP_Data_Months__c tpdm = [SELECT SRW_Data_Month_gne__r.id FROM SRW_TP_Data_Months__c WHERE id = :choosenTPDataMonthId LIMIT 1];
                choosenDataMonth = [SELECT id, Sweep_Status_gne__c, Data_Month_Cal_gne__c FROM SRW_DataMonths__c WHERE id = :tpdm.SRW_Data_Month_gne__r.id LIMIT 1];
                checkSalesDataInChoosenDataMonth();
        } else {
            system.debug('choosenTPDataMonthId: ' + choosenTPDataMonthId);
            showDataMonthReport = (choosenTPDataMonthId != null);
        }
        system.debug('showDataMonthReport: ' + showDataMonthReport);
    }

    public List<SelectOption> getAvaliableCustomers(){
        List<SRW_Prscr_or_Org_Location__c> customersInChoosenTPDataMonth = avaliableCustomersForDataMonthForCurrentTradingPartner();
        List<SelectOption> options = new List<SelectOption>();
        if(!customersInChoosenTPDataMonth.isEmpty()){
            options.add(new SelectOption('all', 'All')); 
        }
        for (SRW_Prscr_or_Org_Location__c customer : customersInChoosenTPDataMonth) {
            options.add(new SelectOption(customer.Id, customer.Unique_Identifier_gne__c));
            system.debug('customer added: ' + customer.Unique_Identifier_gne__c);
        }
        if(options.isEmpty()){
            options.add(new Selectoption('noCustomer', 'No Customer Avaliable'));
            system.debug('no customer');
        }             
        return options;
    }
    public List<SRW_Prscr_or_Org_Location__c> avaliableCustomersForDataMonthForCurrentTradingPartner(){
        Set<Id> deletedPrescribersWithSalesReported = new Set<Id>();
        if(noAccess || choosenTPDataMonthId == null)
            return new List<SRW_Prscr_or_Org_Location__c>();

        if('all'.equals(choosenTPDataMonthId)){
            for(AggregateResult temp : [SELECT Prescriber_Organization_Location_gne__c FROM SRW_Sales_Data_gne__c WHERE Trading_Partner_gne__c = :tradingPartner.id AND ( Quantity_gne__c > 0  OR Set_Sequence_Number_gne__c != 0) GROUP BY Prescriber_Organization_Location_gne__c]){
                deletedPrescribersWithSalesReported.add( (Id) temp.get('Prescriber_Organization_Location_gne__c'));
            }
        }else {
            for(AggregateResult temp : [SELECT Prescriber_Organization_Location_gne__c FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId AND Trading_Partner_gne__c = :tradingPartner.id AND ( Quantity_gne__c > 0  OR Set_Sequence_Number_gne__c != 0) GROUP BY Prescriber_Organization_Location_gne__c]){
                deletedPrescribersWithSalesReported.add( (Id) temp.get('Prescriber_Organization_Location_gne__c'));
            }
        }
        return [SELECT id, Unique_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE id IN :deletedPrescribersWithSalesReported ORDER BY Unique_Identifier_gne__c Asc];
    }

    public void checkSalesDataInChoosenDataMonth(){
        List<SRW_Sales_Data_gne__c> temp = [SELECT id FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId AND Trading_Partner_gne__c = :tradingPartner.id LIMIT 1];
        system.debug('choosenTPDataMonthId: ' + choosenTPDataMonthId);
        system.debug('no sales in choosenTPDataMonthId: ' + temp.isEmpty());
        showDataMonthReport = !temp.isEmpty();
        if(!showDataMonthReport){
            SRW_TP_Data_Months__c tempTPDM = [SELECT Data_Month_Status_gne__c FROM SRW_TP_Data_Months__c WHERE id = :choosenTPDataMonthId LIMIT 1];
            noSalesReported = 'Submitted - No Sales Reported'.equals(tempTPDM.Data_Month_Status_gne__c) || 'Sweep'.equals(tempTPDM.Data_Month_Status_gne__c) ? true : false;
        }
    }

    public List<SelectOption> getAvaliableQuantities(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('yes', 'YES')); 
        options.add(new SelectOption('no', 'NO')); 
        return options;
    }
    
    /*
    public List<AggregateResult> getCountProductsSalesForChoosenDataMonth1(){
        List<SRW_Sales_Data_gne__c> sdl;
        if('all'.equals(choosenTPDataMonthId)) {
            sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c, TP_Data_Month_gne__r.id
                                          FROM SRW_Sales_Data_gne__c  
                                          WHERE Trading_Partner_gne__c = :tradingPartner.id
                                          ORDER BY Product_gne__r.Name Desc];
        } else {
            sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c, TP_Data_Month_gne__r.id
                                          FROM SRW_Sales_Data_gne__c  
                                          WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                                              AND Trading_Partner_gne__c = :tradingPartner.id
                                              ORDER BY Product_gne__r.Name Desc];
        }
        system.debug('previous sales Data: ' + sdl);                                      
        Map<SalesDataKey, SalesDataValue> salesMap = new Map<SalesDataKey, SalesDataValue>();

        for (SRW_Sales_Data_gne__c sd : sdl){
            if (salesMap.containsKey(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id, sd.TP_Data_Month_gne__r.id))){
                if(salesMap.get(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id, sd.TP_Data_Month_gne__r.id)).sequenceNumber < sd.Set_Sequence_Number_gne__c){
                    salesMap.put(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id, sd.TP_Data_Month_gne__r.id), new SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
                }
            }else {
                salesMap.put(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id, sd.TP_Data_Month_gne__r.id), new SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
            }
        }
        system.debug('salesMap: ' + salesMap);
        List<id> productIds = new List<id>();
        for(SalesDataKey sdk : salesMap.keySet()){
            productIds.add(salesMap.get(sdk).salesId);
        }
        system.debug('productIds: ' + productIds);
        return [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c datayear, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c datamonth, Product_gne__r.Name n, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum FROM SRW_Sales_Data_gne__c WHERE id IN :ProductIds GROUP BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Product_gne__r.Name ASC];
    }*/

    public List<AggregateResult> getCountProductsSalesForChoosenDataMonth(){

        List<AggregateResult> retList = new List<AggregateResult>();  
        if('all'.equals(choosenTPDataMonthId)) {
            retList = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c datayear, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c datamonth, Product_gne__r.Name n, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum 
                    FROM SRW_Sales_Data_gne__c 
                    WHERE Trading_Partner_gne__c = :tradingPartner.id
                    AND Is_Actual_gne__c = true
                    GROUP BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c,Product_gne__r.Name ASC];
        }else{
            retList = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c datayear, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c datamonth, Product_gne__r.Name n, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum 
                    FROM SRW_Sales_Data_gne__c 
                    WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                    AND Trading_Partner_gne__c = :tradingPartner.id
                    AND Is_Actual_gne__c = true
                    GROUP BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c,Product_gne__r.Name ASC];
        }
        return retList;
    }

    public List<salesDataPerPrescriberWrapper> getSalesDataPerPrescriber1(){
        List<salesDataPerPrescriberWrapper> sdpp = new List<salesDataPerPrescriberWrapper>();
        List<SRW_Sales_Data_gne__c> sdl = new List<SRW_Sales_Data_gne__c>();
        system.debug('in get sales per presc');
        Integer minQuantity = 'yes'.equals(isQuantityGreaterThanZero) ? 0 : -1;
        if('all'.equals(choosenTPDataMonthId) && 'all'.equals(choosenCustomerId)) {
            sdl = [SELECT id, Product_gne__r.Name, Product_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__c, 
                             Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, Set_Sequence_Number_gne__c,
                             Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,
                             Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c,
                             TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c
                        FROM SRW_Sales_Data_gne__c  
                        WHERE Trading_Partner_gne__c = :tradingPartner.id
                        AND Is_Actual_gne__c = true
                        AND Quantity_gne__c > :minQuantity
                        ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc, Product_gne__r.Name asc];
        }else if('all'.equals(choosenCustomerId)){
            sdl = [SELECT id, Product_gne__r.Name, Product_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__c, 
                         Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, Set_Sequence_Number_gne__c,
                         Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,
                         Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c,
                         TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c
                    FROM SRW_Sales_Data_gne__c  
                    WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                    AND Trading_Partner_gne__c = :tradingPartner.id
                    AND Is_Actual_gne__c = true
                    AND Quantity_gne__c > :minQuantity
                    ORDER BY Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc, Product_gne__r.Name asc];
        }else if('all'.equals(choosenTPDataMonthId)){
            sdl = [SELECT id, Product_gne__r.Name, Product_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__c, 
                             Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, Set_Sequence_Number_gne__c,
                             Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,
                             Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c,
                             TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c
                        FROM SRW_Sales_Data_gne__c  
                        WHERE Trading_Partner_gne__c = :tradingPartner.id
                        AND Prescriber_Organization_Location_gne__c = :choosenCustomerId
                        AND Is_Actual_gne__c = true
                        AND Quantity_gne__c > :minQuantity
                        ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc, Product_gne__r.Name asc];
        }else {
            sdl = [SELECT id, Product_gne__r.Name, Product_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__c, 
                         Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, Set_Sequence_Number_gne__c,
                         Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,
                         Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c,
                         TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c
                    FROM SRW_Sales_Data_gne__c  
                    WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                    AND Prescriber_Organization_Location_gne__c = :choosenCustomerId
                    AND Trading_Partner_gne__c = :tradingPartner.id
                    AND Is_Actual_gne__c = true
                    AND Quantity_gne__c > :minQuantity
                    ORDER BY Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc, Product_gne__r.Name asc];
        }
        List<SalesDataValue> temp = new List<SalesDataValue>();
        if (!sdl.isEmpty()){
                for(Integer i = 0 ; i < sdl.size() - 1 ; i++){
                    if(sdl[i].Prescriber_Organization_Location_gne__c == sdl[i+1].Prescriber_Organization_Location_gne__c && sdl[i].TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c == sdl[i+1].TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c){
                        temp.add(new SalesDataValue(sdl[i].Quantity_gne__c, sdl[i].Set_Sequence_Number_gne__c, sdl[i].Product_gne__r.NDC_Number_gne__c, sdl[i].Product_gne__r.Name, sdl[i].id));
                    }else{
                        temp.add(new SalesDataValue(sdl[i].Quantity_gne__c, sdl[i].Set_Sequence_Number_gne__c, sdl[i].Product_gne__r.NDC_Number_gne__c, sdl[i].Product_gne__r.Name, sdl[i].id));
                        sdpp.add(new salesDataPerPrescriberWrapper(sdl[i].Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, sdl[i].Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, sdl[i].Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c, sdl[i].Prescriber_Organization_Location_gne__r.City_gne__c + ' ' + sdl[i].Prescriber_Organization_Location_gne__r.State_gne__c + ' ' + sdl[i].Prescriber_Organization_Location_gne__r.Zip_Code_gne__c, sdl[i].Prescriber_Organization_Location_gne__c, sdl[i].TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, temp));
                        temp = new List<SalesDataValue>();
                    }
                }           
                Integer j = sdl.size() - 1;                         
                temp.add(new SalesDataValue(sdl[j].Quantity_gne__c, sdl[j].Set_Sequence_Number_gne__c, sdl[j].Product_gne__r.NDC_Number_gne__c, sdl[j].Product_gne__r.Name, sdl[j].id));
                sdpp.add(new salesDataPerPrescriberWrapper(sdl[j].Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, sdl[j].Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, sdl[j].Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c, sdl[j].Prescriber_Organization_Location_gne__r.City_gne__c + ' ' + sdl[j].Prescriber_Organization_Location_gne__r.State_gne__c + ' ' + sdl[j].Prescriber_Organization_Location_gne__r.Zip_Code_gne__c, sdl[j].Prescriber_Organization_Location_gne__c, sdl[j].TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, temp));
            }
        return sdpp;
    }

    /*public List<salesDataPerPrescriberWrapper> getSalesDataPerPrescriber2(){
        salesDataPerPrescriber = new List<salesDataPerPrescriberWrapper>();
        List<salesDataPerPrescriberWrapper> sdpp;
        Map<String, List<SRW_Sales_Data_gne__c>> sdMap = new Map<String, List<SRW_Sales_Data_gne__c>>(); 
        Map<Id, SRW_Sales_Data_gne__c> sdl1;
        System.debug('--- choosenTPDataMonthId '+ choosenTPDataMonthId);
        if('all'.equals(choosenTPDataMonthId)) { 
                sdl1 = new Map<Id, SRW_Sales_Data_gne__c>([SELECT Prescriber_Organization_Location_gne__r.Name, Prescriber_Organization_Location_gne__r.id,
                                                Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Set_Sequence_Number_gne__c,
                                                Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                                TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c, 
                                                Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c,
                                                Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c
                                                FROM SRW_Sales_Data_gne__c  
                                                WHERE Trading_Partner_gne__c = :tradingPartner.id 
                                                ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c desc, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c desc, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc, Product_gne__r.Name asc]);
        } else {
                sdl1 = new Map<Id, SRW_Sales_Data_gne__c>([SELECT Prescriber_Organization_Location_gne__r.Name, Prescriber_Organization_Location_gne__r.id,
                                                Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Set_Sequence_Number_gne__c,
                                                Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, 
                                                Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c,
                                                Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c
                                                FROM SRW_Sales_Data_gne__c  
                                                WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                                                AND Trading_Partner_gne__c = :tradingPartner.id
                                                ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c desc, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c desc, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc, Product_gne__r.Name asc]);
        }

        for(SRW_Sales_Data_gne__c sd :sdl1.values()) {
            if(!sdMap.containsKey(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c))
                sdMap.put(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, new List<SRW_Sales_Data_gne__c>());
            sdMap.get(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c).add(sd);
        }

        for(String key : sdMap.keySet()) {
                sdpp = new List<salesDataPerPrescriberWrapper>();
                List<SRW_Sales_Data_gne__c> sdList = sdMap.get(key);
                Map<SalesDataKey, SalesDataValue> salesMap = new Map<SalesDataKey, SalesDataValue>();
                Set<Id> allPrescriberLocationsIds = new Set<Id>();

                for (SRW_Sales_Data_gne__c sd : sdList){
                    if (salesMap.containsKey(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id))){
                        if(salesMap.get(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id)).sequenceNumber < sd.Set_Sequence_Number_gne__c){
                            salesMap.put(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id), new SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
                        }
                    }else {
                        salesMap.put(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id), new SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
                    }
                    allPrescriberLocationsIds.add(sd.Prescriber_Organization_Location_gne__r.id);
                }

                List<SalesDataValue> tempsd = new  List<SalesDataValue>();
                String address;
                String address2;
                String cityStateZip;
                for (Id prescLocId : allPrescriberLocationsIds){
                        for (SalesDataValue sdv : salesMap.values()){
                            SRW_Sales_Data_gne__c sd = sdl1.get(sdv.salesId);                        
                            if(sd.Prescriber_Organization_Location_gne__r.id == prescLocId){
                                tempsd.add(new SalesDataValue(sd.Quantity_gne__c, null, sd.Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, sd.Product_gne__r.Name, sd.id));
                                address = sd.Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c;
                                address2 = sd.Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c;
                                cityStateZip = sd.Prescriber_Organization_Location_gne__r.City_gne__c + ', ' + sd.Prescriber_Organization_Location_gne__r.State_gne__c + ', ' + sd.Prescriber_Organization_Location_gne__r.Zip_Code_gne__c;
                            }
                        }
                        sdpp.add(new salesDataPerPrescriberWrapper(tempsd[0].ndcNumber, address, address2, cityStateZip, prescLocId, key, new List<SalesDataValue>(tempsd)));
                        tempsd.clear();
                }
                System.debug('--- sdpp '+ sdpp);
                salesDataPerPrescriber.addAll(sdpp);
        }
        return salesDataPerPrescriber;
    }*/

    public String getMonthString() {
        if('all'.equals(choosenTPDataMonthId))
            return 'All months';
        else 
            return choosenDataMonth.Data_Month_Cal_gne__c;
    }

    public List<SelectOption> getFileFormatOptions() {
        List<SelectOption> fileFormats = new List<SelectOption>();
        fileFormats.add(new Selectoption('pdf','pdf'));
        fileFormats.add(new Selectoption('csv','csv'));
        fileFormats.add(new Selectoption('xls','xls'));
        return fileFormats;
    }

    public PageReference printRedirect() {

        PageReference pr;
        if(isFOIM) 
            pr = new PageReference('/apex/SRW_Print_Preview');
        
        else 
            pr = new PageReference('/partner/SRW_Print_Preview');
        pr.getParameters().put('mode','salesDataReport');
        pr.getParameters().put('csv','no');
        pr.getParameters().put('tpdm', choosenTPDataMonthId);
        pr.getParameters().put('tp', tradingPartner.id);
        pr.getParameters().put('history', 'yes');
        pr.getParameters().put('customer', choosenCustomerId);
        pr.getParameters().put('isquantitygreater0',isQuantityGreaterThanZero);

        pr.setRedirect(true);
        return pr;
    }

    public PageReference exportDataToFile(){
        if(noAccess)
            return null;
            
        PageReference newPageRef ;
        if(selectedFileFormat == 'xls') {
            newPageRef = Page.SRW_Export_Excel;
            newPageRef.getParameters().put('mode', 'salesDataReport');
            newPageRef.getParameters().put('csv', 'no');
            newPageRef.getParameters().put('tpdm', choosenTPDataMonthId);
            newPageRef.getParameters().put('tp', tradingPartner.id);
            newPageRef.getParameters().put('history', 'yes');
            newPageRef.getParameters().put('customer', choosenCustomerId);
            newPageRef.getParameters().put('isquantitygreater0',isQuantityGreaterThanZero);
            newPageRef.setRedirect(false);
          } else if (selectedFileFormat == 'pdf') {
            newPageRef = Page.SRW_Export_Pdf;
            newPageRef.getParameters().put('mode', 'salesDataReport');
            newPageRef.getParameters().put('csv', 'no');
            newPageRef.getParameters().put('tpdm', choosenTPDataMonthId);
            newPageRef.getParameters().put('tp', tradingPartner.id);
            newPageRef.getParameters().put('history', 'yes');
            newPageRef.getParameters().put('customer', choosenCustomerId);
            newPageRef.getParameters().put('isquantitygreater0',isQuantityGreaterThanZero);
            newPageRef.setRedirect(true);
          } else {
            /*newPageRef = Page.SRW_Export_CSV;
            newPageRef.getParameters().put('mode', 'salesDataReport');
            newPageRef.getParameters().put('csv', 'yes');
            newPageRef.getParameters().put('tpdm', choosenTPDataMonthId);
            newPageRef.getParameters().put('tp', tradingPartner.id);
            newPageRef.getParameters().put('totals', 'no');
            newPageRef.getParameters().put('history', 'yes');
            newPageRef.setRedirect(true);*/
            newPageRef = null;
          }
        return newPageRef;
    } 

    public List<PageReference> getExportToCsvUrls(){
        
        if(noAccess)
            return null;

        PageReference pr ;
        List<PageReference> returnList = new List<PageReference>();

        if(!isFoim){
            pr = new PageReference('/partner/srw_export_csv?csv=yes&mode=salesDataReport&tpdm='+choosenTPDataMonthId+'&tp='+tradingPartner.id+'&totals=no&history=yes&customer=all&isquantitygreater0=yes');
            returnList.add(pr);
            pr = new PageReference('/partner/srw_export_csv?csv=yes&mode=salesDataReport&tpdm='+choosenTPDataMonthId+'&tp='+tradingPartner.id+'&totals=yes&history=yes&customer=all&isquantitygreater0=yes');
        }else{ 
            pr = new PageReference('/apex/srw_export_csv?csv=yes&mode=salesDataReport&tpdm='+choosenTPDataMonthId+'&tp='+tradingPartner.id+'&totals=no&history=yes&customer=all&isquantitygreater0=yes');
            returnList.add(pr);
            pr = new PageReference('/apex/srw_export_csv?csv=yes&mode=salesDataReport&tpdm='+choosenTPDataMonthId+'&tp='+tradingPartner.id+'&totals=yes&history=yes&customer=all&isquantitygreater0=yes');
        }   
        returnList.add(pr);
        return returnList;
    }

    /*public class SalesDataKey{
        public String ndcNumber {get;set;}
        public id tradingPartnerdataMonthId {get; set;}
        public id prescLoc {get; set;}

        public SalesDataKey(String ndcNumber, id prescLoc, id tradingPartnerdataMonthId){
            this.tradingPartnerdataMonthId = tradingPartnerdataMonthId;
            this.ndcNumber = ndcNumber;
            this.prescLoc = prescLoc;
        }
        public SalesDataKey(String ndcNumber, id prescLoc){
            this.ndcNumber = ndcNumber;
            this.prescLoc = prescLoc;
        }
        public SalesDataKey(String ndcNumber){
            this.ndcNumber = ndcNumber;
            this.prescLoc = null;
        }
        public Boolean equals(Object obj){
            if(obj instanceof SalesDataKey){
                SalesDataKey temp = (SalesDataKey) obj;
                system.debug('this : ' + this + '   obj: ' + obj);
                system.debug('equals? ' + (ndcNumber.equals(temp.ndcNumber) && (prescLoc == temp.prescLoc) && (tradingPartnerdataMonthId == temp.tradingPartnerdataMonthId)));
                return  (ndcNumber.equals(temp.ndcNumber) && (prescLoc == temp.prescLoc) && (tradingPartnerdataMonthId == temp.tradingPartnerdataMonthId));
            }
            return false;
        }
        public Integer hashCode(){
            if (ndcNumber!= null && tradingPartnerdataMonthId != null && prescLoc != null){
                return (((ndcNumber.hashCode()) ^ (String.valueOf(tradingPartnerdataMonthId).hashCode())) ^ (String.valueOf(prescLoc).hashCode()));
            } else if(ndcNumber!= null && tradingPartnerdataMonthId != null){
                return ((ndcNumber.hashCode()) ^ (String.valueOf(tradingPartnerdataMonthId).hashCode()));
            } else 
                return ndcNumber.hashCode();
        }
    }*/
    public class SalesDataValue implements Comparable{
        public Decimal quantity {get; set;}
        public Decimal sequenceNumber {get; set;}
        public String ndcNumber {get;set;}
        public String name {get;set;}
        public id salesId {get; set;}

        public SalesDataValue(Decimal quantity, Decimal sequenceNumber, String ndcNumber, String Name, id salesId){
            this.quantity = quantity;
            this.sequenceNumber = sequenceNumber;
            this.ndcNumber  = ndcNumber;
            this.name = name;
            this.salesId = salesId;
        }

        public Integer compareTo(Object compareTo){
            SalesDataValue compateSalesDataValue = (SalesDataValue) compareTo;
            return name.compareTo(compateSalesDataValue.name);
        }
    }
    public class salesDataPerPrescriberWrapper{
        public String dataMonth {get; set;}
        public String prescriberName {get; set;}
        public String prescriberAddress {get; set;}
        public String prescriberAddress2 {get; set;}
        public String prescriberCityStateZip {get; set;}
        public Id prescriberLocationId {get; set;}
        public List<SalesDataValue> salesData {get; set;}

        public salesDataPerPrescriberWrapper(String prescriberName, String prescriberAddress, String prescriberAddress2, String prescriberCityStateZip, Id prescriberLocationId, List<SalesDataValue> salesData){
            this.prescriberName = prescriberName;
            this.prescriberAddress = prescriberAddress;
            this.prescriberAddress2 = prescriberAddress;
            this.prescriberCityStateZip = prescriberCityStateZip;
            this.prescriberLocationId = prescriberLocationId;
            this.salesData = salesData;
            salesData.sort();
        }

        public salesDataPerPrescriberWrapper(String prescriberName, String prescriberAddress, String prescriberAddress2, String prescriberCityStateZip, Id prescriberLocationId, String dataMonth, List<SalesDataValue> salesData){
            this.prescriberName = prescriberName;
            this.prescriberAddress = prescriberAddress;
            this.prescriberAddress2 = prescriberAddress2;
            this.prescriberCityStateZip = prescriberCityStateZip;
            this.prescriberLocationId = prescriberLocationId;
            this.salesData = salesData;
            this.dataMonth = dataMonth;
            salesData.sort();
        }
    }
}