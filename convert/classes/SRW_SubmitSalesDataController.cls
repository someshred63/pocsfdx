public without sharing class SRW_SubmitSalesDataController {

    public SRW_DataMonths__c currentDataMonth {get; set;}
    public Id currentTPDataMonth {get;set;}
    public SRW_Trading_Partner_Profile__c tradingPartner {get; set;}
    public List<ProductWrapper> avaliableProducts {private get; set;}

    public List<SelectOption> avaliableTPDataMonths {private get; set;}
    public Boolean noTPDataMonths {get; set;}
    public Id choosenTPDataMonthId {get; set;} 
    public SRW_DataMonths__c choosenDataMonth {get; set;}

    public List<SelectOption> avaliablePrescribers;
    public Id choosenPrescriberLocationId {get; set;}
    public String choosenPrescriberLocationUniqueIdentifier {get; set;}

    public List<SRW_Sales_Data_gne__c> salesDataForChoosenPrescriber {get; set;}
    public Boolean isProductFormDisabled {get; set;}

    public Boolean hasPreviousDataMonthsNotSubmitted {get; set;}
    public List<SRW_TP_Data_Months__c> previousNotSubmittedDataMonths {get; set;}

    public Boolean hasOpenedUponRequestDataMonths {get; set;}
    public List<SRW_TP_Data_Months__c> openedUponRequestDataMonths {get; set;}

    public Boolean incompleteTradingPartnerProfile {get; set;}
    public Boolean isFoim {get; set;}
    public Boolean isCurrentMonthSubmitted {get; set;}
    public Boolean noAccess {get; set;}
    public Boolean noSalesReportedForChoosenDataMonth {get; set;}
    public Boolean reopenedNoSales{get;set;}
    public Boolean isGetDataAvaliable{get;set;}

    public List<Id> listDataMonthsToAssign {get; set;}
    public List<SelectOption> avaliableDataMonthsToAssign;

    transient List<AggregateResult> countProductsSalesForChoosenDataMonth;
    public Boolean showDataMonthReport {get; set;}
    transient List<salesDataPerPrescriberWrapper> salesDataPerPrescriber {private get; set;}

    public Id prescriberToEdit {get; set;}
    public String prescriberToDeleteUniqueIdentifier {get; set;}

    public String selectedFileFormat {get;set;}

    public List<PageReference> exportToCsvUrls;


    public SRW_SubmitSalesDataController(){
        List<Profile> FOIMs = [SELECT Name, Id FROM Profile WHERE (Id = :UserInfo.getProfileId() AND Name = 'GNE-GST-Partner-External')];
        isFoim = FOIMs.isEmpty();
        salesDataPerPrescriber = new List<salesDataPerPrescriberWrapper>();
        countProductsSalesForChoosenDataMonth = new List<AggregateResult>();
        List<SRW_DataMonths__c> cdm = [SELECT id, Data_Month_Cal_gne__c FROM SRW_DataMonths__c WHERE Sweep_Status_gne__c = 'Current'];
        currentDataMonth = cdm.isEmpty() ? null : cdm[0];
        User currentUser = [SELECT id, ContactId FROM User WHERE id = :UserInfo.getUserId()];
        if(!isFoim) {
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
                         WHERE Id = :mimicData.get(0).SRW_Trading_Partner_Profile_gne__c LIMIT 1];
            }    
        }
        if(tradingPartner == null) {
            noAccess = true;
            return;
        }
        else 
            noAccess = false;

        isProductFormDisabled = true;
        showDataMonthReport = false;
        isCurrentMonthSubmitted = false;
        isGetDataAvaliable = true;
        system.debug('presc to edit: ' + prescriberToEdit);

        incompleteTradingPartnerProfile = isTradingPartnerProfileIncomplete();

        system.debug('after incomplete profile.');

        avaliableTPDataMonths = fillAvaliableTPDataMonths();
        if(!avaliableTPDataMonths.isEmpty()){
            choosenTPDataMonthId = avaliableTPDataMonths[0].getValue();
            system.debug('tp data month : ' + choosenTPDataMonthId);
            currentTPDataMonth = choosenTPDataMonthId;
            changeChoosenDataMonth();
        }
        if(currentDataMonth != null){
            choosenDataMonth = currentDataMonth;
            List<SRW_TP_Data_Months__c> tpdm = [SELECT id, Data_Month_Status_gne__c FROM SRW_TP_Data_Months__c WHERE Trading_Partner_gne__c = :tradingPartner.id AND SRW_Data_Month_gne__c = :currentDataMonth.id LIMIT 1];
            system.debug('tp datamonth for current month: ' +tpdm);
            if(tpdm.isEmpty()){
                isCurrentMonthSubmitted = true;
            } else {
                currentTPDataMonth = tpdm[0].id;
                system.debug('current tpdm: ' + currentTPDataMonth);
                isCurrentMonthSubmitted = (tpdm[0].Data_Month_Status_gne__c.equals('Submitted - Sales') || tpdm[0].Data_Month_Status_gne__c.equals('Submitted - No Sales Reported') || tpdm[0].Data_Month_Status_gne__c.equals('Resubmitted')) ? true : false;
                choosenTPDataMonthId = tpdm[0].Data_Month_Status_gne__c.equals('Submitted - No Sales Reported') ? choosenTPDataMonthId : tpdm[0].id;
                changeChoosenDataMonth();
            }
        } else {
            isCurrentMonthSubmitted = true;
        }
        previousNotSubmittedDataMonths = fillPreviousNotSubmittedDataMonths();
        openedUponRequestDataMonths = fillOpenedUponRequestDataMonths();
        if(avaliableTPDataMonthForCurrentTradingPartner().isEmpty()){
            noTPDataMonths = true;
        }else {
            noTPDataMonths = false;
        }
     }

     public Boolean currentTPDataMonthSubmitted(){
        List<SRW_TP_Data_Months__c> temp = [SELECT id, Data_Month_Status_gne__c FROM SRW_TP_Data_Months__c WHERE id = :currentTPDataMonth LIMIT 1];
        return 'Open'.equals(temp[0].Data_Month_Status_gne__c) ? false : true;
     }

    public List<SRW_TP_Data_Months__c> fillOpenedUponRequestDataMonths(){
        List<SRW_TP_Data_Months__c> ourdm = [SELECT id, SRW_Data_Month_gne__r.Data_Month_Cal_gne__c FROM SRW_TP_Data_Months__c WHERE Trading_Partner_gne__c = :tradingPartner.id AND Data_Month_Status_gne__c = 'Reopen' ORDER BY CreatedDate DESC];
        if(ourdm.isEmpty()){
            hasOpenedUponRequestDataMonths = false;         
        }else {
            hasOpenedUponRequestDataMonths = true;
        }
        return ourdm;
    }

    public List<SRW_TP_Data_Months__c> fillPreviousNotSubmittedDataMonths(){
        List<SRW_TP_Data_Months__c> pnsdm = new List<SRW_TP_Data_Months__c>();
        if(currentDataMonth != null){
            pnsdm = [SELECT id, SRW_Data_Month_gne__r.Data_Month_Cal_gne__c FROM SRW_TP_Data_Months__c WHERE Trading_Partner_gne__c = :tradingPartner.id AND Data_Month_Status_gne__c = 'Open' AND SRW_Data_Month_gne__c != :currentDataMonth.id ORDER BY CreatedDate DESC];
        } else {
            pnsdm = [SELECT id, SRW_Data_Month_gne__r.Data_Month_Cal_gne__c FROM SRW_TP_Data_Months__c WHERE Trading_Partner_gne__c = :tradingPartner.id AND Data_Month_Status_gne__c = 'Open' ORDER BY CreatedDate DESC];
        }
        if(pnsdm.isEmpty()){
            hasPreviousDataMonthsNotSubmitted = false;
        }else {
            hasPreviousDataMonthsNotSubmitted = true;
        }
        return pnsdm;
    }

    public List<SelectOption> getAvaliableDataMonthsToAssign(){
        List<String> openedDataMonthsStatus = new List<String>();
        openedDataMonthsStatus.add('Sweep');
        openedDataMonthsStatus.add('Resweep');
        List<SRW_TP_Data_Months__c> sweptDataMonths = [SELECT id, Name, SRW_Data_Month_gne__r.Data_Month_Cal_gne__c FROM SRW_TP_Data_Months__c WHERE Trading_Partner_gne__c = :tradingPartner.id AND Data_Month_Status_gne__c IN :openedDataMonthsStatus ORDER BY CreatedDate DESC];
        List<SelectOption> options = new List<SelectOption>();
        for (SRW_TP_Data_Months__c sdm : sweptDataMonths) {
            options.add(new SelectOption(sdm.Id, sdm.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c));
        }
        return options;
    }

    public List<SRW_TP_Data_Months__c> avaliableTPDataMonthForCurrentTradingPartner(){
        List<String> openedDataMonthsStatus = new List<String>();
        openedDataMonthsStatus.add('Open');
        openedDataMonthsStatus.add('Reopen');
        openedDataMonthsStatus.add('Submitted - Sales');
        openedDataMonthsStatus.add('Submitted - No Sales Reported');
        openedDataMonthsStatus.add('Resubmitted');
        return [SELECT id, Name, SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, SRW_Data_Month_gne__r.id FROM SRW_TP_Data_Months__c WHERE Trading_Partner_gne__c = :tradingPartner.id AND Data_Month_Status_gne__c IN :openedDataMonthsStatus ORDER BY CreatedDate ASC];
    }

    public List<SelectOption> fillAvaliableTPDataMonths(){
        List<SRW_TP_Data_Months__c> openedDataMonths = avaliableTPDataMonthForCurrentTradingPartner();
        List<SelectOption> options = new List<SelectOption>();
        for (SRW_TP_Data_Months__c odm : openedDataMonths) {
            options.add(new SelectOption(odm.Id, odm.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c));
        }
        return options;
    }
    public List<SelectOption> getAvaliableTPDataMonths(){
        system.debug('In getAvaliableTPDataMonths');
        return fillAvaliableTPDataMonths();
    }

    public List<SRW_Prscr_or_Org_Location__c> getAvaliablePrescribers(){
        Set<Id> deletedPrescribersWithSalesReported = new Set<Id>();
        system.debug('in avaliabe prescribers');
        if(noAccess)
            return new List<SRW_Prscr_or_Org_Location__c>();

        for(AggregateResult temp : [SELECT Prescriber_Organization_Location_gne__c FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId AND Trading_Partner_gne__c = :tradingPartner.id GROUP BY Prescriber_Organization_Location_gne__c]){
            deletedPrescribersWithSalesReported.add( (Id) temp.get('Prescriber_Organization_Location_gne__c'));
        }
        return [SELECT id, Unique_Identifier_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c, Street_Address_1_gne__c, Street_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Location_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE (Prescriber_or_Organization_gne__r.Trading_Partner_gne__c = :tradingPartner.id AND isActive_gne__c = true) OR ( id IN :deletedPrescribersWithSalesReported) ORDER BY Unique_Identifier_gne__c Asc];
    }
/*
    public List<ProductWrapper> getAvaliableProducts1(){
        List<ProductWrapper> pw = new List<ProductWrapper>();
        AggregateResult[] maxSequenceForTPDataMonth = [SELECT MAX(Set_Sequence_Number_gne__c) maxSeq FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId AND Trading_Partner_gne__c = :tradingPartner.id];
        Decimal seqNumber = (maxSequenceForTPDataMonth[0].get('maxSeq')==null) ? 1 : (Decimal) maxSequenceForTPDataMonth[0].get('maxSeq');
        system.debug('BEST_DEBUG: seqNumber: ' + seqNumber);
        List<SRW_Sales_Data_gne__c> previousSalesEntry = [SELECT id, Product_gne__r.Name, Product_gne__r.id, Product_gne__r.SRW_Data_Type_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Sweep_Data_Month_gne__c, Set_Sequence_Number_gne__c, TP_Data_Month_gne__c, Trading_Partner_gne__c,Prescriber_Organization_Location_gne__c, CreatedDate
                                                  FROM SRW_Sales_Data_gne__c 
                                                  WHERE Prescriber_Organization_Location_gne__c = :choosenPrescriberLocationId 
                                                    AND TP_Data_Month_gne__c = :choosenTPDataMonthId
                                                    AND Trading_Partner_gne__c = :tradingPartner.id 
                                                    ORDER BY Product_gne__r.Name, Set_Sequence_Number_gne__c Desc]; 
        List<Product_vod__c> productsVisibleForTradingPartner = [SELECT id, Name, NDC_Number_gne__c, SRW_Data_Type_gne__c FROM Product_vod__c WHERE id IN (SELECT Product_gne__c FROM SRW_Trd_Prt_Product_gne__c WHERE Trading_Partner_gne__c = :tradingPartner.id AND Is_Visible_gne__c = true) ORDER BY Name ASC];
        List<SRW_TP_Data_Months__c> tempTPDataMonth = [SELECT id, Data_Month_Status_gne__c, SRW_Data_Month_gne__c FROM SRW_TP_Data_Months__c WHERE id = :choosenTPDataMonthId];
        seqNumber = tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Reopen') ? ++seqNumber : (tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Open') ? 1 : seqNumber);
        if (!previousSalesEntry.isEmpty()){
            //get all previous sales data, gropu by product, pick one with max seq number in for loop
            Map<id, Decimal> productMaxSequenceNumber = new Map<id, Decimal>();
            AggregateResult[] maxSequenceNumberPerProduct = [SELECT Product_gne__r.id product, MAX(Set_Sequence_Number_gne__c) maxSeq FROM SRW_Sales_Data_gne__c WHERE Prescriber_Organization_Location_gne__c = :choosenPrescriberLocationId AND TP_Data_Month_gne__c = :choosenTPDataMonthId AND Trading_Partner_gne__c = :tradingPartner.id GROUP BY Product_gne__r.id ORDER BY MAX(Set_Sequence_Number_gne__c) DESC];
            //get max seq number per product
            for(AggregateResult ar : maxSequenceNumberPerProduct){
                productMaxSequenceNumber.put((Id) ar.get('product'), (Decimal) ar.get('maxSeq'));
            }
            //previous salesData in to list and create set that contain productsIds that are in previous salesData
            Set<id> productsInSalesData = new Set<id>();
            for (SRW_Sales_Data_gne__c sd : previousSalesEntry){
                if(productMaxSequenceNumber.containsKey(sd.Product_gne__r.id)){
                    if(productMaxSequenceNumber.get(sd.Product_gne__r.id) == sd.Set_Sequence_Number_gne__c){
                        sd.Set_Sequence_Number_gne__c = seqNumber;
                        pw.add(new ProductWrapper(sd, sd.Product_gne__r.Name, sd.Product_gne__r.NDC_Number_gne__c, sd.Quantity_gne__c, sd.Product_gne__r.SRW_Data_Type_gne__c));
                        productsInSalesData.add(sd.Product_gne__r.id);
                    }
                }
            }
            system.debug('pw with previous sales data: ' + pw);
            for (Product_vod__c p : productsVisibleForTradingPartner){
                if(!productsInSalesData.contains(p.id)){
                    pw.add(new ProductWrapper(new SRW_Sales_Data_gne__c(Product_gne__c = p.id, TP_Data_Month_gne__c = choosenTPDataMonthId, Trading_Partner_gne__c = tradingPartner.id, Set_Sequence_Number_gne__c = seqNumber, Prescriber_Organization_Location_gne__c = choosenPrescriberLocationId, Quantity_gne__c = 0), p.Name, p.NDC_Number_gne__c, 0, p.SRW_Data_Type_gne__c));
                }
            }
        } else {
            for (Product_vod__c p: productsVisibleForTradingPartner){
                pw.add(new ProductWrapper(new SRW_Sales_Data_gne__c(Product_gne__c = p.id, TP_Data_Month_gne__c = choosenTPDataMonthId, Trading_Partner_gne__c = tradingPartner.id, Set_Sequence_Number_gne__c = seqNumber, Prescriber_Organization_Location_gne__c = choosenPrescriberLocationId, Quantity_gne__c = 0), p.Name, p.NDC_Number_gne__c, 0, p.SRW_Data_Type_gne__c));
            }
        }
        avaliableProducts = pw;
        system.debug('avaliable products: ' + avaliableProducts);
        return pw;
    }*/

    public List<ProductWrapper> getAvaliableProducts(){
        system.debug('In getAvalidableProducts');
        List<ProductWrapper> pw = new List<ProductWrapper>();
        AggregateResult[] maxSequenceForTPDataMonth = [SELECT MAX(Set_Sequence_Number_gne__c) maxSeq FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId AND Trading_Partner_gne__c = :tradingPartner.id AND Is_Actual_gne__c = true AND Set_Sequence_Number_gne__c > 1];
        Decimal seqNumber = (maxSequenceForTPDataMonth[0].get('maxSeq')==null) ? 1 : (Decimal) maxSequenceForTPDataMonth[0].get('maxSeq');
        List<SRW_Sales_Data_gne__c> previousSalesEntry = [SELECT id, Product_gne__r.Name, Product_gne__r.id, Product_gne__r.SRW_Data_Type_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Sweep_Data_Month_gne__c, Set_Sequence_Number_gne__c, TP_Data_Month_gne__c, Trading_Partner_gne__c,Prescriber_Organization_Location_gne__c, CreatedDate
                                                  FROM SRW_Sales_Data_gne__c 
                                                  WHERE Prescriber_Organization_Location_gne__c = :choosenPrescriberLocationId 
                                                    AND TP_Data_Month_gne__c = :choosenTPDataMonthId
                                                    AND Trading_Partner_gne__c = :tradingPartner.id 
                                                    AND Is_Actual_gne__c = true
                                                    ORDER BY Product_gne__r.Name Desc]; 
        List<Product_vod__c> productsVisibleForTradingPartner = [SELECT id, Name, NDC_Number_gne__c, SRW_Data_Type_gne__c FROM Product_vod__c WHERE id IN (SELECT Product_gne__c FROM SRW_Trd_Prt_Product_gne__c WHERE Trading_Partner_gne__c = :tradingPartner.id AND Is_Visible_gne__c = true) ORDER BY Name ASC];
        List<SRW_TP_Data_Months__c> tempTPDataMonth = [SELECT id, Data_Month_Status_gne__c, SRW_Data_Month_gne__c FROM SRW_TP_Data_Months__c WHERE id = :choosenTPDataMonthId];
        seqNumber = tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Reopen') ? ++seqNumber : (tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Open') ? 1 : seqNumber);
        if (!previousSalesEntry.isEmpty()){
            //previous salesData in to list and create set that contain productsIds that are in previous salesData
            Set<id> productsInSalesData = new Set<id>();
            for (SRW_Sales_Data_gne__c sd : previousSalesEntry){
                sd.Set_Sequence_Number_gne__c = seqNumber;
                pw.add(new ProductWrapper(sd, sd.Product_gne__r.Name, sd.Product_gne__r.NDC_Number_gne__c, sd.Quantity_gne__c, sd.Product_gne__r.SRW_Data_Type_gne__c));
                productsInSalesData.add(sd.Product_gne__r.id);
            }
            for (Product_vod__c p : productsVisibleForTradingPartner){
                if(!productsInSalesData.contains(p.id)){
                    pw.add(new ProductWrapper(new SRW_Sales_Data_gne__c(Product_gne__c = p.id, TP_Data_Month_gne__c = choosenTPDataMonthId, Trading_Partner_gne__c = tradingPartner.id, Set_Sequence_Number_gne__c = seqNumber, Prescriber_Organization_Location_gne__c = choosenPrescriberLocationId, Quantity_gne__c = 0), p.Name, p.NDC_Number_gne__c, 0, p.SRW_Data_Type_gne__c));
                }
            }
        } else {
            for (Product_vod__c p: productsVisibleForTradingPartner){
                pw.add(new ProductWrapper(new SRW_Sales_Data_gne__c(Product_gne__c = p.id, TP_Data_Month_gne__c = choosenTPDataMonthId, Trading_Partner_gne__c = tradingPartner.id, Set_Sequence_Number_gne__c = seqNumber, Prescriber_Organization_Location_gne__c = choosenPrescriberLocationId, Quantity_gne__c = 0), p.Name, p.NDC_Number_gne__c, 0, p.SRW_Data_Type_gne__c));
            }
        }
        pw.sort();
        avaliableProducts = pw;
        return pw;
    }

    public PageReference submitSalesData(){

        if(avaliableProducts.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No assigned products.'));
            return null;
        } 

        List<SRW_Sales_Data_gne__c> salesDataToUpsert = new List<SRW_Sales_Data_gne__c>();
        SRW_Sales_Data_gne__c tempSD = new SRW_Sales_Data_gne__c();
        Id sweepDataMonthId = null;
        Id customerLocationToUpsert = avaliableProducts[0].salesData.Prescriber_Organization_Location_gne__c;

        Boolean logException = false;
        Boolean isUpdate = false;
        String updateHistoricalMonth;
        List<SRW_Sales_Data_Exception__c> exceptions = new List<SRW_Sales_Data_Exception__c>();
        Savepoint sp = Database.setSavepoint();

        AggregateResult[] maxSequenceForTPDataMonthForCustomer = [SELECT MAX(Set_Sequence_Number_gne__c) maxSeq FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId AND Trading_Partner_gne__c = :tradingPartner.id AND Prescriber_Organization_Location_gne__c = :customerLocationToUpsert];
        Decimal seqNumber = (maxSequenceForTPDataMonthForCustomer[0].get('maxSeq')==null) ? 1 : (Decimal) maxSequenceForTPDataMonthForCustomer[0].get('maxSeq');
        Decimal salesDataSequenceNumber = avaliableProducts[0].salesData.Set_Sequence_Number_gne__c;

        List<SRW_TP_Data_Months__c> tempTPDataMonth = [SELECT id, Data_Month_Status_gne__c, SRW_Data_Month_gne__c, SRW_Data_Month_gne__r.Sweep_Status_gne__c FROM SRW_TP_Data_Months__c WHERE id = :choosenTPDataMonthId];
        if(!tempTPDataMonth.isEmpty()){
            isUpdate = ('Open'.equals(tempTPDataMonth[0].Data_Month_Status_gne__c) || 'Reopen'.equals(tempTPDataMonth[0].Data_Month_Status_gne__c)) ? false : ( salesDataSequenceNumber == seqNumber ? true : false);
            system.debug('Should I update records? ' + isUpdate);
            if(tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Open') || tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Submitted - Sales') || tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Submitted - No Sales Reported')){
                tempTPDataMonth[0].Data_Month_Status_gne__c = 'Submitted - Sales';
                sweepDataMonthId = tempTPDataMonth[0].SRW_Data_Month_gne__c;
                List<SRW_Sales_Data_Exception__c> exceptionList = [SELECT id FROM SRW_Sales_Data_Exception__c WHERE SRW_TP_Data_Month_gne__c = :choosenTPDataMonthId AND SRW_Trading_Partner_Profile_gne__c = :tradingPartner.id];
                logException = 'Current'.equals(tempTPDataMonth[0].SRW_Data_Month_gne__r.Sweep_Status_gne__c) ? false : (exceptionList.isEmpty() ? true : false);
                updateHistoricalMonth = 'No';
            }else if(tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Reopen') || tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Resubmitted')){
                system.debug('tpdm = reopen ' + tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Reopen') + '  or resubmitted ' + tempTPDataMonth[0].Data_Month_Status_gne__c.equals('Resubmitted'));
                List<SRW_Sales_Data_gne__c> temp = [SELECT Sweep_Data_Month_gne__c FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId AND Trading_Partner_gne__c = :tradingPartner.id AND Sweep_Data_Month_gne__c != null LIMIT 1];
                sweepDataMonthId = temp.isEmpty() ? tempTPDataMonth[0].SRW_Data_Month_gne__c : temp[0].Sweep_Data_Month_gne__c;
                tempTPDataMonth[0].Data_Month_Status_gne__c = 'Resubmitted';
                updateHistoricalMonth = 'Yes';
                logException = true;
            }
            system.debug('update historical tpdm: ' + updateHistoricalMonth);
            update tempTPDataMonth;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured. Try again later.'));
            System.debug('No such TP data month in DB.');
            Database.rollback(sp);
            return null;
        }
        system.debug('should i log exception? ' + logException);
        Integer scale; 
        Decimal tempQ;
        for (productWrapper pw : avaliableProducts){
            if(pw.quantity < 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Sales data cannot be negative.'));
                Database.rollback(sp);
                return null;
            }
            tempSD = isUpdate ? pw.salesData : new SRW_Sales_Data_gne__c(Product_gne__c = pw.salesData.Product_gne__c, TP_Data_Month_gne__c = pw.salesData.TP_Data_Month_gne__c, Trading_Partner_gne__c = pw.salesData.Trading_Partner_gne__c, Set_Sequence_Number_gne__c = pw.salesData.Set_Sequence_Number_gne__c, Prescriber_Organization_Location_gne__c = pw.salesData.Prescriber_Organization_Location_gne__c);
            scale = '0.01'.equals(pw.step) ? 2 : 0;
            tempQ = pw.quantity;
            tempQ.setScale(scale);
            tempSD.Quantity_gne__c = tempQ;
            tempSD.Is_Actual_gne__c = true;
            tempSD.Sweep_Data_Month_gne__c = sweepDataMonthId;
            salesDataToUpsert.add(tempSD);
        }
        upsert salesDataToUpsert;
        for(SRW_Sales_Data_gne__c salesDataAfterUpsert : salesDataToUpsert){
            if(logException){
                SRW_Sales_Data_Exception__c e = new SRW_Sales_Data_Exception__c(Historical_Sales_Data_Update_gne__c = updateHistoricalMonth,
                                                                                SRW_Sales_Data_gne__c = salesDataAfterUpsert.id,
                                                                                SRW_Trading_Partner_Profile_gne__c = salesDataAfterUpsert.Trading_Partner_gne__c,
                                                                                SRW_TP_Data_Month_gne__c = salesDataAfterUpsert.TP_Data_Month_gne__c,
                                                                                SRW_Prescriber_Organization_Location_gne__c = salesDataAfterUpsert.Prescriber_Organization_Location_gne__c,
                                                                                Quantity_gne__c = salesDataAfterUpsert.Quantity_gne__c,
                                                                                Product_gne__c = salesDataAfterUpsert.Product_gne__c,
                                                                                Original_Submission_Time_Stamp_gne__c = salesDataAfterUpsert.CreatedDate == null ? System.now() : salesDataAfterUpsert.CreatedDate);
                exceptions.add(e);
            }
        }
        system.debug('... logException : ' + logException + ' ...updateHistoricalMonth ' + updateHistoricalMonth);
        if(logException || 'Yes'.equals(updateHistoricalMonth)){
            sendExceptionEmail(updateHistoricalMonth);
        }
        if (logException && !exceptions.isEmpty()) insert exceptions;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Sales data saved.'));
        disableProductForm();
        previousNotSubmittedDataMonths = fillPreviousNotSubmittedDataMonths();
        openedUponRequestDataMonths = fillOpenedUponRequestDataMonths();
        showDataMonthReport = true;
        isGetDataAvaliable = true;
        noSalesReportedForChoosenDataMonth = false;
        isCurrentMonthSubmitted = choosenTPDataMonthId == currentTPDataMonth ? currentTPDataMonthSubmitted() : isCurrentMonthSubmitted;
        return null;
    }

    public void sendExceptionEmail(String updateHistoricalMonth){
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
        String htmlBody = '<div>Trading Partner: ' + tradingPartner.Trading_Partner_Name_gne__c +'</div><div>Data Month: ' + choosenDataMonth.Data_Month_Cal_gne__c + '</div>';
        String subject = 'Yes'.equals(updateHistoricalMonth) ? 'HISTORIC DATA MONTH UPDATE EXCEPTION' : 'BACKFILL EXCEPTION';
        List<String> addresses = new List<String>();
        sem.setHtmlBody(htmlBody);
        sem.setSubject(subject);
        String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
        addresses.add(owea[0].Address);
        sem.setToAddresses(addresses);
        sem.setOrgWideEmailAddressId(owea[0].id);
        Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
    }

    public PageReference setParamPrescriberToEdit(){
        choosenPrescriberLocationId = prescriberToEdit;
        undeletePrescriber();
        isGetDataAvaliable = false;
        return selectPrescriber();
    }

    public PageReference editPrescriber(){
        SRW_Prscr_or_Org_Location__c tempLoc = [SELECT id, Prescriber_or_Organization_gne__r.id, Prescriber_or_Organization_gne__r.Organization_Name_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE id = :prescriberToEdit];
        PageReference pr = new PageReference(Page.SRW_AddNewPrescriberOrOrganization.getURL());
        if(!String.isBlank(tempLoc.Prescriber_or_Organization_gne__r.Organization_Name_gne__c)){
            pr.getParameters().put('type', 'Organization');
        } else {
            pr.getParameters().put('type', 'Prescriber');
        }
        pr.getParameters().put('id', (String) tempLoc.Prescriber_or_Organization_gne__r.id);
        pr.setRedirect(true);
        return pr;
    }

    public void undeletePrescriber(){
        SRW_Prscr_or_Org_Location__c loc = [SELECT id, isActive_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE id = :prescriberToEdit];
        if(!loc.isActive_gne__c){
            loc.isActive_gne__c = true;
            update loc;
        }
    }

    public void preparePrescriberSalesDataToDelete(){
        SRW_Prscr_or_Org_Location__c temp = [SELECT Unique_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE id =:prescriberToEdit LIMIT 1];
        prescriberToDeleteUniqueIdentifier = temp.Unique_Identifier_gne__c;
        isGetDataAvaliable = false;
    }

    public PageReference deletePrescriberSalesData(){
        SRW_TP_Data_Months__c choosenTPDM = [SELECT id, Data_Month_Status_gne__c FROM SRW_TP_Data_Months__c WHERE id = :choosenTPDataMonthId];
        Boolean openDM = 'Submitted - Sales'.equals(choosenTPDM.Data_Month_Status_gne__c) ? deleteInOpenDataMonth(choosenTPDM) : deleteInReopenDataMonths(choosenTPDM);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Sales deleted.'));
        isGetDataAvaliable = true;
        return null;
    }

    public Boolean deleteInOpenDataMonth(SRW_TP_Data_Months__c choosenTPDM){
        List<SRW_Sales_Data_gne__c> sd = [SELECT id
                                          FROM SRW_Sales_Data_gne__c 
                                          WHERE Prescriber_Organization_Location_gne__c = :prescriberToEdit 
                                            AND TP_Data_Month_gne__c = :choosenTPDM.id
                                            AND Trading_Partner_gne__c = :tradingPartner.id 
                                            AND Is_Actual_gne__c = true]; 
        delete sd;
        List<SRW_Sales_Data_gne__c> isAnySalesDataForChoosenTPDataMonth = [SELECT id FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c =:choosenTPDataMonthId];
        if(isAnySalesDataForChoosenTPDataMonth.isEmpty()){
            choosenTPDM.Data_Month_Status_gne__c = choosenTPDM.Data_Month_Status_gne__c.equals('Submitted - Sales') ? 'Open' : 'Reopen';
            update choosenTPDM;
        }
        previousNotSubmittedDataMonths = fillPreviousNotSubmittedDataMonths();
        openedUponRequestDataMonths = fillOpenedUponRequestDataMonths();
        checkSalesDataInChoosenDataMonth();
        return true;
    }

    public Boolean deleteInReopenDataMonths(SRW_TP_Data_Months__c choosenTPDM){
        List<SRW_Sales_Data_gne__c> sd = [SELECT id, Quantity_gne__c
                                          FROM SRW_Sales_Data_gne__c 
                                          WHERE Prescriber_Organization_Location_gne__c = :prescriberToEdit 
                                            AND TP_Data_Month_gne__c = :choosenTPDM.id
                                            AND Trading_Partner_gne__c = :tradingPartner.id 
                                            AND Is_Actual_gne__c = true]; 
        for(SRW_Sales_Data_gne__c temp : sd){
            temp.Quantity_gne__c = 0;
        }
        update sd;
        choosenTPDM.Data_Month_Status_gne__c = 'Resubmitted';
        update choosenTPDM;
        previousNotSubmittedDataMonths = fillPreviousNotSubmittedDataMonths();
        openedUponRequestDataMonths = fillOpenedUponRequestDataMonths();
        checkSalesDataInChoosenDataMonth();
        return false;
    }

    /*public Boolean deleteInOpenDataMonth1(SRW_TP_Data_Months__c choosenTPDM){
        List<id> salesIds = new List<id>();
        for(salesDataPerPrescriberWrapper sdppw : salesDataPerPrescriber){
            if(sdppw.prescriberLocationId == prescriberToEdit){
                for(SalesDataValue sdv : sdppw.salesData){
                    salesIds.add(sdv.salesId);
                }
            }
        }
        List<SRW_Sales_Data_gne__c> sd = [SELECT id FROM SRW_Sales_Data_gne__c WHERE id IN :salesIds];
        delete sd;
        List<SRW_Sales_Data_gne__c> isAnySalesDataForChoosenTPDataMonth = [SELECT id FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c =:choosenTPDataMonthId];
        if(isAnySalesDataForChoosenTPDataMonth.isEmpty()){
            choosenTPDM.Data_Month_Status_gne__c = choosenTPDM.Data_Month_Status_gne__c.equals('Submitted - Sales') ? 'Open' : 'Reopen';
            update choosenTPDM;
        }
        previousNotSubmittedDataMonths = fillPreviousNotSubmittedDataMonths();
        openedUponRequestDataMonths = fillOpenedUponRequestDataMonths();
        checkSalesDataInChoosenDataMonth();
        return true;
    }

    public Boolean deleteInReopenDataMonths1(SRW_TP_Data_Months__c choosenTPDM){
        List<id> salesIds = new List<id>();
        for(salesDataPerPrescriberWrapper sdppw : salesDataPerPrescriber){
            if(sdppw.prescriberLocationId == prescriberToEdit){
                for(SalesDataValue sdv : sdppw.salesData){
                    salesIds.add(sdv.salesId);
                }
            }
        }
        List<SRW_Sales_Data_gne__c> salesDataToDelete = [SELECT id, Quantity_gne__c FROM SRW_Sales_Data_gne__c WHERE id IN :salesIds];
        for(SRW_Sales_Data_gne__c temp : salesDataToDelete){
            temp.Quantity_gne__c = 0;
        }
        system.debug('before update : sales data: ' + salesDataToDelete);
        update salesDataToDelete;
        choosenTPDM.Data_Month_Status_gne__c = 'Resubmitted';
        update choosenTPDM;
        previousNotSubmittedDataMonths = fillPreviousNotSubmittedDataMonths();
        openedUponRequestDataMonths = fillOpenedUponRequestDataMonths();
        checkSalesDataInChoosenDataMonth();
        return false;
    }

    public List<AggregateResult> getCountProductsSalesForChoosenDataMonth1(){
        //count product per datamonth - sum quantity per presc/loc with max(seq) number
        List<SRW_Sales_Data_gne__c> sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c
                                          FROM SRW_Sales_Data_gne__c  
                                          WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                                              AND Trading_Partner_gne__c = :tradingPartner.id
                                              ORDER BY Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc];
        system.debug('previous sales Data: ' + sdl); 
        system.debug('count previous sales data : ' + sdl.size());  
        List<AggregateResult> retList = new List<AggregateResult>();                                   
        Map<SalesDataKey, SalesDataValue> salesMap = new Map<SalesDataKey, SalesDataValue>();

        for (SRW_Sales_Data_gne__c sd : sdl){
            if (salesMap.containsKey(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id))){
                if(salesMap.get(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id)).sequenceNumber < sd.Set_Sequence_Number_gne__c){
                    salesMap.put(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id), new SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
                }
            }else {
                salesMap.put(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id), new SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
            }
        }
        system.debug('salesMap keys: ' + salesMap.keySet());
        system.debug('salesMap values: ' + salesMap.values());
        List<id> productIds = new List<id>();
        for(SalesDataKey sdk : salesMap.keySet()){
            productIds.add(salesMap.get(sdk).salesId);
        }
        retList = [SELECT Product_gne__r.Name n, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum FROM SRW_Sales_Data_gne__c WHERE id IN :ProductIds GROUP BY Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c ORDER BY Product_gne__r.Name ASC];
        countProductsSalesForChoosenDataMonth = retList.clone();
        system.debug('count products for choosen data month: ' + retlist);
        return retList;
    }*/

    public List<AggregateResult> getCountProductsSalesForChoosenDataMonth(){
        system.debug('In getCountProductsSalesForChoosenDataMonth');
        if(!isGetDataAvaliable){
            return null;
        }else{
            List<AggregateResult> retList = new List<AggregateResult>();  
            retList = [SELECT Product_gne__r.Name n, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum 
                        FROM SRW_Sales_Data_gne__c 
                        WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                        AND Trading_Partner_gne__c = :tradingPartner.id
                        AND Is_Actual_gne__c = true
                        GROUP BY Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c ORDER BY Product_gne__r.Name ASC];
            countProductsSalesForChoosenDataMonth = retList.clone();
            system.debug('count products for choosen data month: ' + retlist);
            return retList;
        }
    }

/*
    public List<salesDataPerPrescriberWrapper> getSalesDataPerPrescriber1(){
        List<salesDataPerPrescriberWrapper> sdpp = new List<salesDataPerPrescriberWrapper>();
        List<SRW_Sales_Data_gne__c> sdl = [SELECT Product_gne__r.Name, Product_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__c, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, Set_Sequence_Number_gne__c
                                          FROM SRW_Sales_Data_gne__c  
                                          WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                                              AND Trading_Partner_gne__c = :tradingPartner.id
                                              ORDER BY Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc];                                   

        Map<SalesDataKey, SalesDataValue> salesMap = new Map<SalesDataKey, SalesDataValue>();
        Set<Id> allPrescriberLocationsIds = new Set<Id>();
        for (SRW_Sales_Data_gne__c sd : sdl){
            if (salesMap.containsKey(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c))){
                if(salesMap.get(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c)).sequenceNumber < sd.Set_Sequence_Number_gne__c){
                    salesMap.put(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c), new SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
                }
            }else {
                salesMap.put(new SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c), new SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
            }
            allPrescriberLocationsIds.add(sd.Prescriber_Organization_Location_gne__c);
        }
        List<id> salesDataToRetrieve = new List<id>();
        for (SalesDataValue sdv : salesMap.values()){
            salesDataToRetrieve.add(sdv.salesId);
            system.debug('sales data id to retrieve: ' + sdv.salesId);
        }
        sdl.clear();
        system.debug('V: sales data ids to retrieve : ' + salesDataToRetrieve);
        sdl = [SELECT Product_gne__r.Name, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c, Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c FROM SRW_Sales_Data_gne__c WHERE id IN :salesDataToRetrieve ORDER BY Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c ASC, Product_gne__r.Name ASC];
        List<SalesDataValue> tempsd = new  List<SalesDataValue>();
        String address;
        String address2;
        String cityStateZip;
        for (Id prescLocId : allPrescriberLocationsIds){
            for(SRW_Sales_Data_gne__c sd : sdl){
                if(sd.Prescriber_Organization_Location_gne__r.id == prescLocId){
                    tempsd.add(new SalesDataValue(sd.Quantity_gne__c, null, sd.Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, sd.Product_gne__r.Name, sd.id));
                    address = sd.Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c;
                    address2 = sd.Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c;
                    cityStateZip = sd.Prescriber_Organization_Location_gne__r.City_gne__c + ', ' + sd.Prescriber_Organization_Location_gne__r.State_gne__c + ', ' + sd.Prescriber_Organization_Location_gne__r.Zip_Code_gne__c;
                }
            }
            sdpp.add(new salesDataPerPrescriberWrapper(tempsd[0].ndcNumber, address, address2, cityStateZip, prescLocId, new List<SalesDataValue>(tempsd)));
            tempsd.clear();
        }
        salesDataPerPrescriber.clear();
        salesDataPerPrescriber = sdpp.clone();
        return sdpp;
    }*/

    public List<salesDataPerPrescriberWrapper> getSalesDataPerPrescriber(){
        system.debug('In getSalesDataPerPrescriber');
        system.debug('isGetDataAvaliable: ' + isGetDataAvaliable);
        if(!isGetDataAvaliable){
            isGetDataAvaliable = true;
            return null;
        }else{
            List<salesDataPerPrescriberWrapper> sdpp = new List<salesDataPerPrescriberWrapper>();
            List<SRW_Sales_Data_gne__c> sdl = [SELECT id, Product_gne__r.Name, Product_gne__c, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__c, 
                                                     Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, Set_Sequence_Number_gne__c,
                                                     Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,
                                                     Prescriber_Organization_Location_gne__r.City_gne__c, Prescriber_Organization_Location_gne__r.State_gne__c, Prescriber_Organization_Location_gne__r.Zip_Code_gne__c
                                                FROM SRW_Sales_Data_gne__c  
                                                WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId
                                                    AND Trading_Partner_gne__c = :tradingPartner.id
                                                    AND Is_Actual_gne__c = true
                                                    AND Quantity_gne__c > 0
                                                    ORDER BY Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c asc, Product_gne__r.Name asc];
            List<SalesDataValue> temp = new List<SalesDataValue>();
            if (!sdl.isEmpty()){
                    for(Integer i = 0 ; i < sdl.size() - 1 ; i++){
                        if(sdl[i].Prescriber_Organization_Location_gne__c == sdl[i+1].Prescriber_Organization_Location_gne__c){
                            temp.add(new SalesDataValue(sdl[i].Quantity_gne__c, sdl[i].Set_Sequence_Number_gne__c, sdl[i].Product_gne__r.NDC_Number_gne__c, sdl[i].Product_gne__r.Name, sdl[i].id));
                        }else{
                            temp.add(new SalesDataValue(sdl[i].Quantity_gne__c, sdl[i].Set_Sequence_Number_gne__c, sdl[i].Product_gne__r.NDC_Number_gne__c, sdl[i].Product_gne__r.Name, sdl[i].id));
                            sdpp.add(new salesDataPerPrescriberWrapper(sdl[i].Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, sdl[i].Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, sdl[i].Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c, sdl[i].Prescriber_Organization_Location_gne__r.City_gne__c + ' ' + sdl[i].Prescriber_Organization_Location_gne__r.State_gne__c + ' ' + sdl[i].Prescriber_Organization_Location_gne__r.Zip_Code_gne__c, sdl[i].Prescriber_Organization_Location_gne__c, temp));
                            temp = new List<SalesDataValue>();
                        }
                    }           
                    Integer j = sdl.size() - 1;                         
                    temp.add(new SalesDataValue(sdl[j].Quantity_gne__c, sdl[j].Set_Sequence_Number_gne__c, sdl[j].Product_gne__r.NDC_Number_gne__c, sdl[j].Product_gne__r.Name, sdl[j].id));
                    sdpp.add(new salesDataPerPrescriberWrapper(sdl[j].Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c, sdl[j].Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c, sdl[j].Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c, sdl[j].Prescriber_Organization_Location_gne__r.City_gne__c + ' ' + sdl[j].Prescriber_Organization_Location_gne__r.State_gne__c + ' ' + sdl[j].Prescriber_Organization_Location_gne__r.Zip_Code_gne__c, sdl[j].Prescriber_Organization_Location_gne__c, temp));
                }
            return sdpp;
        }
    }

    public Boolean isTradingPartnerProfileIncomplete(){
        return(tradingPartner != null ? (
         tradingPartner.Contact_Email_Address_gne__c == null ||
         tradingPartner.Contact_First_Name_gne__c == null ||
         tradingPartner.Contact_Last_Name_gne__c == null ||
         tradingPartner.Contact_Phone_gne__c == null ||
         tradingPartner.Trading_Partner_Name_gne__c == null ||
         tradingPartner.Trading_Partner_Phone_gne__c == null ||
         tradingPartner.Trading_Partner_Address_1_gne__c == null ||
         tradingPartner.City_gne__c == null ||
         tradingPartner.State_gne__c == null ||
         tradingPartner.Zip_Code_gne__c == null ||
         tradingPartner.Type_of_Identifier_gne__c == null ||
         tradingPartner.Identifier_gne__c == null) : true);
    }
    public void checkSalesDataInChoosenDataMonth(){
        List<SRW_Sales_Data_gne__c> temp = [SELECT id FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__c = :choosenTPDataMonthId AND Trading_Partner_gne__c = :tradingPartner.id LIMIT 1];
        isCurrentMonthSubmitted = choosenTPDataMonthId == currentTPDataMonth ? currentTPDataMonthSubmitted() : isCurrentMonthSubmitted;
        showDataMonthReport = temp.isEmpty() ? false : true;
        system.debug('check sales. temp.isEmpty : ' + temp.isEmpty() + '   ||  reopenedNoSales: ' + reopenedNoSales);
        reopenedNoSales = reopenedNoSales ? temp.isEmpty() : false;
        system.debug('reopenedNoSales: ' + reopenedNoSales);
    }
    public PageReference noSalesReported(){
        isProductFormDisabled = true;
        SRW_TP_Data_Months__c tpdm = [SELECT id, Data_Month_Status_gne__c, SRW_Data_Month_gne__r.Data_Month_Cal_gne__c FROM SRW_TP_Data_Months__c WHERE id = :choosenTPDataMonthId LIMIT 1];
        tpdm.Data_Month_Status_gne__c = 'Submitted - No Sales Reported';
        update tpdm;
        changeChoosenDataMonth();
        disableProductForm();
        previousNotSubmittedDataMonths = fillPreviousNotSubmittedDataMonths();
        openedUponRequestDataMonths = fillOpenedUponRequestDataMonths();
        isCurrentMonthSubmitted = choosenTPDataMonthId == currentTPDataMonth ? currentTPDataMonthSubmitted() : isCurrentMonthSubmitted;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'No sales for ' + tpdm.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c + ' reported.'));
        return null;
    }
    public PageReference selectPrescriber(){
        system.debug('In selectPrescriber');
        SRW_Prscr_or_Org_Location__c pool = [SELECT Unique_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE id = :choosenPrescriberLocationId LIMIT 1];
        choosenPrescriberLocationUniqueIdentifier = pool.Unique_Identifier_gne__c;
        isProductFormDisabled = false;
        return null;
    }
    public void changeChoosenDataMonth(){
        reopenedNoSales = false;
        if(choosenTPDataMonthId != null){
            SRW_TP_Data_Months__c tpdm = [SELECT SRW_Data_Month_gne__r.id, Data_Month_Status_gne__c FROM SRW_TP_Data_Months__c WHERE id = :choosenTPDataMonthId LIMIT 1];
            noSalesReportedForChoosenDataMonth =  'Submitted - No Sales Reported'.equals(tpdm.Data_Month_Status_gne__c);
            if('Submitted - No Sales Reported'.equals(tpdm.Data_Month_Status_gne__c)){
                disableProductForm();
            } else if('Reopen'.equals(tpdm.Data_Month_Status_gne__c)){
                system.debug('reopen? tpdm: ' +tpdm );
                reopenedNoSales = true;
            }
            choosenDataMonth = [SELECT id, Sweep_Status_gne__c, Data_Month_Cal_gne__c FROM SRW_DataMonths__c WHERE id = :tpdm.SRW_Data_Month_gne__r.id LIMIT 1];
            checkSalesDataInChoosenDataMonth();
        }
    }
    public PageReference openNoSalesReportedDataMonth(){
        if(choosenTPDataMonthId != null){
            SRW_TP_Data_Months__c tpdm = [SELECT id, SRW_Data_Month_gne__r.id, Data_Month_Status_gne__c FROM SRW_TP_Data_Months__c WHERE id = :choosenTPDataMonthId LIMIT 1];
            tpdm.Data_Month_Status_gne__c = 'Open';
            update tpdm;
            noSalesReportedForChoosenDataMonth = false;
            choosenDataMonth = [SELECT id, Sweep_Status_gne__c, Data_Month_Cal_gne__c FROM SRW_DataMonths__c WHERE id = :tpdm.SRW_Data_Month_gne__r.id LIMIT 1];
            checkSalesDataInChoosenDataMonth();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'No Sales Reported reverted.'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select Data Months.'));
        }
        previousNotSubmittedDataMonths = fillPreviousNotSubmittedDataMonths();
        openedUponRequestDataMonths = fillOpenedUponRequestDataMonths();
        return null;
    }

    public PageReference openDataMonthsForTradingPartner(){
        system.debug('opedDataMonthsForTP start');
        List<SRW_TP_Data_Months__c> tpdm = [SELECT id, Data_Month_Status_gne__c, Reopen_Date_gne__c FROM SRW_TP_Data_Months__c WHERE id IN :listDataMonthsToAssign];
        List<SRW_TP_Data_Month_Exception__c> tpdmExceptions = new List<SRW_TP_Data_Month_Exception__c>();
        system.debug('Data Months to reopen: ' + tpdm);
        for(SRW_TP_Data_Months__c dm : tpdm){
            dm.Data_Month_Status_gne__c = 'Reopen';
            dm.Reopen_Date_gne__c = system.today();
            tpdmExceptions.add(new SRW_TP_Data_Month_Exception__c(SRW_TP_Data_Month_gne__c = dm.id, SRW_Trading_Partner_Profile_gne__c = tradingPartner.id));
        }
        if(!tpdm.isEmpty()){
            update tpdm;
            insert tpdmExceptions;
            system.debug('after update');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Data Months Assigned.'));
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select Data Months to Assign.'));
        }
        return null;
    }

    public void disableProductForm(){
        isProductFormDisabled = true;
        choosenPrescriberLocationUniqueIdentifier = '';
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
        pr.getParameters().put('customer', 'all');
        pr.getParameters().put('isquantitygreater0','yes');

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
            newPageRef.getParameters().put('customer', 'all');
            newPageRef.getParameters().put('isquantitygreater0','yes');
            newPageRef.setRedirect(false);
          } else if (selectedFileFormat == 'pdf') {
            newPageRef = Page.SRW_Export_Pdf;
            newPageRef.getParameters().put('mode', 'salesDataReport');
            newPageRef.getParameters().put('csv', 'no');
            newPageRef.getParameters().put('tpdm', choosenTPDataMonthId);
            newPageRef.getParameters().put('tp', tradingPartner.id);
            newPageRef.getParameters().put('customer', 'all');
            newPageRef.getParameters().put('isquantitygreater0','yes');
            newPageRef.setRedirect(true);
          } else {
            /*newPageRef = Page.SRW_Export_CSV;
            newPageRef.getParameters().put('mode', 'salesDataReport');
            newPageRef.getParameters().put('csv', 'yes');
            newPageRef.getParameters().put('tpdm', choosenTPDataMonthId);
            newPageRef.getParameters().put('tp', tradingPartner.id);
            newPageRef.getParameters().put('totals', 'no');
            newPageRef.setRedirect(true);*/
            newPageRef = null;
          }
        return newPageRef;
      }

      public List<PageReference> getExportToCsvUrls(){
        
        if(noAccess)
            return null;
        
        PageReference pr;
        List<PageReference> returnList = new List<PageReference>();
        
        if(!isFoim){
            pr = new PageReference('/partner/srw_export_csv?csv=yes&mode=salesDataReport&tpdm='+choosenTPDataMonthId+'&tp='+tradingPartner.id+'&totals=no&customer=all&isquantitygreater0=yes');
            returnList.add(pr);
            pr = new PageReference('/partner/srw_export_csv?csv=yes&mode=salesDataReport&tpdm='+choosenTPDataMonthId+'&tp='+tradingPartner.id+'&totals=yes&customer=all&isquantitygreater0=yes');
        }else{ 
            pr = new PageReference('/apex/srw_export_csv?csv=yes&mode=salesDataReport&tpdm='+choosenTPDataMonthId+'&tp='+tradingPartner.id+'&totals=no&customer=all&isquantitygreater0=yes');
            returnList.add(pr);
            pr = new PageReference('/apex/srw_export_csv?csv=yes&mode=salesDataReport&tpdm='+choosenTPDataMonthId+'&tp='+tradingPartner.id+'&totals=yes&customer=all&isquantitygreater0=yes');
        }
        returnList.add(pr);
        return returnList;
      }

    public PageReference salesReportRedirect() {
        PageReference pr;
        pr = Page.SRW_SalesReportHistory;
        pr.getParameters().put('datamonth', choosenTPDataMonthId);
        pr.setRedirect(true);
        return pr;
    }  

    public class ProductWrapper implements Comparable{
        public SRW_Sales_Data_gne__c salesData {get; set;}
        public String name {get; set;}
        public String ndcNumber {get; set;}
        public String step {get;set;}
        public Decimal quantity {get; set;}
        
        public ProductWrapper(SRW_Sales_Data_gne__c salesData, String name, String ndcNumber, Decimal quantity, String srwDataType){
            this.salesData = salesData;
            this.name = name;
            this.ndcNumber = ndcNumber;
            this.quantity = quantity;
            this.step = 'Decimal'.equals(srwDataType) ? '0.01' : '1';
        }

        public Integer compareTo(Object compareTo){
            ProductWrapper temp = (ProductWrapper) compareTo;
            return name.compareTo(temp.name);
        }
    }
    /*public class SalesDataKey{
        public String ndcNumber {get;set;}
        public id prescLoc {get; set;}

        public SalesDataKey(String ndcNumber, id prescLoc){
            this.ndcNumber = ndcNumber;
            this.prescLoc = prescLoc;
        }
        public SalesDataKey(String ndcNumber){
            this.ndcNumber = ndcNumber;
            this.prescLoc = null;
        }
        public SalesDataKey(){}

        public Boolean equals(Object obj){
            if(obj instanceof SalesDataKey){
                SalesDataKey temp = (SalesDataKey) obj;
                return  (ndcNumber.equals(temp.ndcNumber) && (prescLoc == temp.prescLoc));
            }
            return false;
        }
        public Integer hashCode(){
            return ((ndcNumber.hashCode()) ^ (String.valueOf(prescLoc).hashCode()));
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
            SalesDataValue temp = (SalesDataValue) compareTo;
            return name.compareTo(temp.name);
        }
    }
    public class salesDataPerPrescriberWrapper{
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
            //this.salesData.sort();
        }

        public salesDataPerPrescriberWrapper(){}
    }
}