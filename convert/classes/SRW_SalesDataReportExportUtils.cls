public without sharing class SRW_SalesDataReportExportUtils {
    public String choosenTPDataMonthId {get; set;}
    public String tradingPartnerId {get; set;}
    public String dataMonthCal {get; set;}

    public String customer {get; set;}
    public Boolean isQuantityGreaterThanZero {get; set;}
    public Boolean history {get; set;}

    public List<salesDataPerPrescriberWrapper> salesDataPerPrescriber {get; set;}
    public List<AggregateResult> countProductsSalesForChoosenDataMonth {get; set;}

    Transient List<String> csvContent {get; set;} //contains csv data. List of Tables, containg csv rows in format:[0] tpDatMonth, Prescriber, product, quantity; [1] tpDataMonth, product, quantity 


    public SRW_SalesDataReportExportUtils(String tradingPartnerId, String choosenTPDataMonthId, Boolean history, String customer, Boolean isQuantityGreaterThanZero) {
        this.choosenTPDataMonthId = choosenTPDataMonthId;
        this.tradingPartnerId = tradingPartnerId;
        this.history = history;
        this.customer = customer;
        this.isQuantityGreaterThanZero = isQuantityGreaterThanZero;
        List<SRW_TP_Data_Months__c> temp = !choosenTPDataMonthId.equals('all') ? [SELECT id, SRW_Data_Month_gne__r.Data_Month_Cal_gne__c FROM SRW_TP_Data_Months__c WHERE id =: choosenTPDataMonthId LIMIT 1] : new List<SRW_TP_Data_Months__c>(); 
        dataMonthCal = temp.isEmpty() ? 'All Data Months' : temp[0].SRW_Data_Month_gne__r.Data_Month_Cal_gne__c;
        salesDataPerPrescriber = findSalesDataPerPrescriber();
        countProductsSalesForChoosenDataMonth = findCountProductsSalesForChoosenDataMonth();
        csvContent = new List<String>();
    }

    public void prepareCsvContent(){
        csvContent.add(generateCSVContentFromSalesPerPrescriberData(salesDataPerPrescriber));
        csvContent.add(generateCSVContentFromTotalSales(countProductsSalesForChoosenDataMonth));
    }

    public String csvPerPerscriber(){
        return generateCSVContentFromSalesPerPrescriberData(salesDataPerPrescriber);
    }
    public String csvTotals(){
        return generateCSVContentFromTotalSales(countProductsSalesForChoosenDataMonth);
    }

    private String generateCSVContentFromSalesPerPrescriberData(List<salesDataPerPrescriberWrapper> data){
        List<String> headers = new List<String>();
        if(history)
            headers.add('Data Month');
        headers.add('Customer');
        headers.add('Product');
        headers.add('Quantity (Vials Only)');

        Transient String fullCSV = '';

                for(String tmp : headers) {

                    fullCSV +=  '\"' + tmp + '\",';
                }
                fullCSV += '\n';
                for(salesDataPerPrescriberWrapper tempRow : data) {
                    for(SalesDataValue tempSalesData : tempRow.salesData){
                        if(history)
                            fullCSV += '\"' + tempRow.dataMonth + '\",';
                        //fullCSV += '\"' + tempRow.dataMonth + '\",' + '\"' + tempRow.prescriberName + ' ' + tempRow.prescriberAddress + ' ' + tempRow.prescriberAddress2 + ' ' + tempRow.prescriberCityStateZip + '\",' + '\"' + tempSalesData.name + '\",' +  '\"' + tempSalesData.quantity + '\",' + '\n'; 
                        fullCSV += '\"' + tempRow.prescriberName + ' ' + tempRow.prescriberAddress + ' ' + tempRow.prescriberAddress2 + ' ' + tempRow.prescriberCityStateZip + '\",';
                        fullCSV += '\"' + tempSalesData.name + '\",';
                        fullCSV += '\"' + tempSalesData.quantity + '\",';
                        fullCSV +=  '\n';
                        system.debug('row added to csv');
                    }
                }
                
        return fullCSV;
    }
    private String generateCSVContentFromTotalSales(List<AggregateResult> data){
        List<String> headers = new List<String>();
        if(history)
            headers.add('Data Month');
        headers.add('Product');
        headers.add('NDC Number');
        headers.add('Quantity (Vials Only)');

        String fullCSV = '';

                for(String tmp : headers) {

                    fullCSV +=  '\"' + tmp + '\",';
                }
                fullCSV += '\n';
                for(AggregateResult tempRow : data) {
                    if(history)
                        fullCSV += '\"' + tempRow.get('dataMonth') + tempRow.get('dataYear') +  '\",';
                    fullCSV += '\"' + tempRow.get('n') + '\",';
                    fullCSV += '\"' + tempRow.get('ndc') + '\",';
                    fullCSV += '\"' + tempRow.get('quantitySum') + '\",';
                    fullCSV +=  '\n';
                    system.debug('row added to csv');
                }
                
        return fullCSV;
    }

    private List<AggregateResult> findCountProductsSalesForChoosenDataMonth(){  
        if('all'.equals(choosenTPDataMonthId)) {
            return [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c datayear, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c datamonth, Product_gne__r.Name n, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum 
                    FROM SRW_Sales_Data_gne__c 
                    WHERE Trading_Partner_gne__c = :tradingPartnerId
                    AND Is_Actual_gne__c = true
                    GROUP BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c,Product_gne__r.Name ASC];
        }else{
            return [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c datayear, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c datamonth, Product_gne__r.Name n, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum 
                    FROM SRW_Sales_Data_gne__c 
                    WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                    AND Trading_Partner_gne__c = :tradingPartnerId
                    AND Is_Actual_gne__c = true
                    GROUP BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c,Product_gne__r.Name ASC];
        }
    }

    private List<salesDataPerPrescriberWrapper> findSalesDataPerPrescriber(){
        List<salesDataPerPrescriberWrapper> sdpp = new List<salesDataPerPrescriberWrapper>();
        List<SRW_Sales_Data_gne__c> sdl = new List<SRW_Sales_Data_gne__c>();
        Integer minQuantity = isQuantityGreaterThanZero ? 0 : -1;
        if('all'.equals(choosenTPDataMonthId) && 'all'.equals(customer)) {
            sdl = [SELECT id, Product_gne__r.Name, Product_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__c, 
                             Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, Set_Sequence_Number_gne__c,
                             Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,
                             Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c,
                             TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c
                        FROM SRW_Sales_Data_gne__c  
                        WHERE Trading_Partner_gne__c = :tradingPartnerId
                        AND Is_Actual_gne__c = true
                        AND Quantity_gne__c > :minQuantity
                        ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc, Product_gne__r.Name asc];
        }else if('all'.equals(customer)){
            sdl = [SELECT id, Product_gne__r.Name, Product_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__c, 
                         Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, Set_Sequence_Number_gne__c,
                         Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,
                         Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c,
                         TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c
                    FROM SRW_Sales_Data_gne__c  
                    WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                    AND Trading_Partner_gne__c = :tradingPartnerId
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
                        WHERE Trading_Partner_gne__c = :tradingPartnerId
                        AND Prescriber_Organization_Location_gne__c = :customer
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
                    AND Prescriber_Organization_Location_gne__c = :customer
                    AND Trading_Partner_gne__c = :tradingPartnerId
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

    /*public List<AggregateResult> findCountProductsSalesForChoosenDataMonth1(){
        List<SRW_Sales_Data_gne__c> sdl;
        if('all'.equals(choosenTPDataMonthId)) {
            sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c, TP_Data_Month_gne__r.id
                                          FROM SRW_Sales_Data_gne__c  
                                          WHERE Trading_Partner_gne__c = :tradingPartnerid
                                          ORDER BY Product_gne__r.Name Desc];
        } else {
            sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c, TP_Data_Month_gne__r.id
                                          FROM SRW_Sales_Data_gne__c  
                                          WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                                              AND Trading_Partner_gne__c = :tradingPartnerid
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
    }

    public List<salesDataPerPrescriberWrapper> findSalesDataPerPrescriber1(String choosenTPDataMonthId){
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
                                                WHERE Trading_Partner_gne__c = :tradingPartnerId 
                                                ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c desc, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c desc, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc, Product_gne__r.Name asc]);
        } else {
                sdl1 = new Map<Id, SRW_Sales_Data_gne__c>([SELECT Prescriber_Organization_Location_gne__r.Name, Prescriber_Organization_Location_gne__r.id,
                                                Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Set_Sequence_Number_gne__c,
                                                Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, 
                                                Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c,
                                                Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c
                                                FROM SRW_Sales_Data_gne__c  
                                                WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                                                AND Trading_Partner_gne__c = :tradingPartnerId
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
    }

    //wrappers for salesdataPerPrescriber
    public class SalesDataKey{
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
            this.prescriberAddress2 = prescriberAddress2;
            this.prescriberCityStateZip = prescriberCityStateZip;
            this.prescriberLocationId = prescriberLocationId;
            this.salesData = salesData;
            salesData.sort();
        }

        public salesDataPerPrescriberWrapper(String prescriberName, String prescriberAddress, String prescriberAddress2, String prescriberCityStateZip, Id prescriberLocationId, String dataMonth, List<SalesDataValue> salesData){
            this.prescriberName = prescriberName;
            this.prescriberAddress2 = prescriberAddress2;
            this.prescriberAddress = prescriberAddress;
            this.prescriberCityStateZip = prescriberCityStateZip;
            this.prescriberLocationId = prescriberLocationId;
            this.salesData = salesData;
            this.dataMonth = dataMonth;
            salesData.sort();
        }
    }

}