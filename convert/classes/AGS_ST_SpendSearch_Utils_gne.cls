global without sharing class AGS_ST_SpendSearch_Utils_gne {
    global static AGS_ST_User_gne__c stUser {
        get {
            return AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
        }
        set;
    }
    
    public static SpendsData getSpends(String spendType, List<String> spendIds) {
        try {
            Set<String> spendsToSkip = new Set<String>();
            Set<String> paymentMethods = new Set<String>();
            Set<String> paymentReasons = new Set<String>();
            Set<String> brands = new Set<String>();
            Decimal totalAmount = 0.0;

            AGS_Spend_Expense_Transaction_gne__c[] spends;
            if('Research'.equals(spendType)) {
            	spends = getResearchTransactions( null, null );
            } else {
            	spends = getNonResearchTransactions( null, null );
            }

            Integer spendNo = spends.size();
            Map<Id,Id> disputesIds = new Map<Id,Id>();
            Set<ID> spendsId = new Set<ID>();
            for(AGS_Spend_Expense_Transaction_gne__c spend : spends) {
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                    // fist check Opt Out flag on DispueManagement, if true skip this spend
                    if(checkOptOut(spend)) {             
                        spendsToSkip.add(spend.Id);
                        spendNo--;
                        continue;
                    }
                    for(Integer i=0;i<spend.AGS_ST_DisputeManagement_gne__r.size();i++) {
                        disputesIds.put(spend.AGS_ST_DisputeManagement_gne__r[i].Id, spend.Id);
                    }
                }
                spendsId.add(spend.id);
            }
            
            List<AGS_ST_DisputeManagement_gne__History> disputesHistory = [SELECT CreatedDate, Field, NewValue, OldValue, ParentId, Parent.Name FROM AGS_ST_DisputeManagement_gne__History WHERE ParentId in :disputesIds.keySet() ORDER BY CreatedDate];
                
            Map<Id,List<String>> disputeHistoryMap = new Map<Id,List<String>>();
            for(AGS_ST_DisputeManagement_gne__History disputeHistory:disputesHistory) {
                if(disputeHistory.Field == 'External_Status_gne__c' || disputeHistory.Field == 'created')   {
                    String historyDescription = getHistoryDescription(disputeHistory);
                    if(historyDescription!=null) {
                        if(!disputeHistoryMap.containsKey(disputeHistory.ParentId)) {
                            disputeHistoryMap.put(disputeHistory.ParentId, new List<String>());
                        }
                        disputeHistoryMap.get(disputeHistory.ParentId).add(historyDescription);
                    }
                }
            }
            AGS_ST_User_gne__c stUserLocal = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
            SpendsData vd = new SpendsData();
            vd.noBookmarked = 0;
            vd.hcpName = stUserLocal.First_name__c +' '+ stUserLocal.Last_name__c;
            vd.hcpSpecialty = String.isBlank(stUserLocal.Mapped_Account__r.Specialties_gne__c) ? '' : stUserLocal.Mapped_Account__r.Specialties_gne__c;
            Address_vod__c addr = AGS_ST_DbUtils.getGoldAddressByAccountId(stUserLocal.Mapped_Account__c);
            vd.hcpStreetAddress = addr.Name;
            vd.hcpCity = addr.City_vod__c;
            vd.hcpState = addr.State_vod__c;
            vd.hcpZip = addr.Zip_vod__c;
            if(stUserLocal.Email_address__c != null && stUserLocal.Email_address__c != '') {
                vd.userEmailAddress = stUserLocal.Email_address__c;
            } else {
                vd.userEmailAddress = stUserLocal.SFDC_User__r.username;
            }
            
            Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>> spendHistoryMap = new Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>>();
            List<AGS_Spend_Expense_Transaction_gne__History> spendsHistory = [SELECT CreatedDate,Field,ParentId,NewValue,OldValue FROM AGS_Spend_Expense_Transaction_gne__History where ParentId in :spendsId];
            for(AGS_Spend_Expense_Transaction_gne__History spendHistory:spendsHistory) {
                if(!spendHistoryMap.containsKey(spendHistory.ParentId)) {
                    spendHistoryMap.put(spendHistory.ParentId, new List<AGS_Spend_Expense_Transaction_gne__History>());
                }
                spendHistoryMap.get(spendHistory.ParentId).add(spendHistory);
            }
            List<Spend> spendsListForView = new List<Spend>();
            System.debug('----------- spends size ' + spends.size());
            for(AGS_Spend_Expense_Transaction_gne__c spend : spends) {
                if(spendsToSkip.contains(spend.Id)) {
                    continue;
                }
                System.debug('----------- spend ' + spend);

                Spend slw = new Spend();
                slw.id = spend.id;
                slw.studyTitle = 'Study Title: ' + cleanString(spend.Study_Name_gne__c);
                slw.spendType = spend.Event_Type_gne__c;
                slw.speakerName = spend.Speaker_Name_gne__c;
                //slw.delayed = String.valueOf(spend.Delayed_Reporting_Indicator_gne__c);
                if('1-R&D on New Product'.equals(spend.Delayed_Reporting_Code_gne__c)) {
                    slw.delayed = 'true';
                } else { 
                    slw.delayed = 'false';
                }
                slw.eventDate = String.valueOf(spend.Event_Date_gne__c);
                slw.eventTime = spend.Event_Date_gne__c;
                /* START checking CMS Payment Id display */
                Date spendEventDate = spend.Event_Date_gne__c;
                // Check CMS Payment Id DISPLAY DATE
                AGS_ST_Settings_gne__c agsStSet = AGS_ST_Utils.getDefaultCustomSettings();
                Boolean showCmsPaymentId = false;
                if(agsStSet != null && agsStSet.CmsPaymentIdDisplayDate_gne__c != null) {
                    Date displayDate = agsStSet.CmsPaymentIdDisplayDate_gne__c;
                    Date currentDate = Date.today();
                    if(displayDate <= currentDate) {
                        showCmsPaymentId = true;
                    }
                }
                // Managing CMS Payment Id
                if(showCmsPaymentId) {
                    if(spendEventDate != null && spendEventDate.year() < Date.today().year()) {
                       slw.cmsId = spend.CMS_Payment_ID_gne__c;
                    } else {
                       slw.cmsId = '';
                    }
                }
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                    slw.status = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].External_Status_gne__c;
                    slw.cmsDisputeId = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].Dispute_List_gne__r.CmsDisputeId_gne__c;
                } else {
                    slw.status = 'Undisputed';
                }
                
                // Event Location
                String eventLocation = cleanString(spend.Street_Address_gne__c + ' ' + spend.Event_City_gne__c + ' ' + spend.Event_State_gne__c + ' ' + spend.Event_Zip_Code_gne__c);
                // For SFA & Out Of Office transaction, Event Location should be blank
                if( ('SAPTESFDC_SFA'.equals(spend.Source_System_Code_gne__c) || 'SFDCGIFTSFDC_SFA'.equals(spend.Source_System_Code_gne__c) || 'SFA'.equals(spend.Source_System_Code_gne__c)) && spend.SCH_Expense__c.startsWithIgnoreCase('Out of Office') ) {
                    eventLocation = '';
                }
                slw.context = String.valueOf(spend.Context_gne__c);

                String recipient             = cleanString(spend.Party1_Name_gne__c + ', ' + spend.Party1_ADDRESS_LINE1_gne__c + ', ' + spend.Party1_CITY_gne__c + ', ' + spend.Party1_State_gne__c + ', ' + spend.Party1_ZIP_gne__c + ', ' + (('ORGANIZATION'.equalsIgnoreCase(spend.Party1_TYPE_gne__c)) ? spend.Party1_TIN_gne__c : spend.Party1_NPI_gne__c) );
                String principalInvestigator = cleanString(spend.Party2_Name_gne__c + ', ' + spend.Party2_ADDRESS_LINE1_gne__c + ', ' + spend.Party2_City_gne__c + ', ' + spend.Party2_State_gne__c + ', ' + spend.Party2_ZIP_gne__c + ', ' + (('INDIVIDUAL'.equalsIgnoreCase(spend.Party2_TYPE_gne__c)) ? spend.Party2_NPI_gne__c : spend.Party2_TIN_gne__c) ); 

                if(checkIfTakeFromDispute(spend)) {
                    AGS_ST_DisputeManagement_gne__c dispute = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1];
                    slw.amount = String.valueOf(dispute.Amount_gne__c);
                    totalAmount += dispute.Amount_gne__c;
                    slw.paymentMethod = dispute.Form_Of_Payment_gne__c;
                    slw.paymentReason = dispute.Nature_Of_Payment_gne__c;
                    slw.brand = prepareBrands(dispute.Drug_Name_gne__c);
                } else {
                    slw.amount = String.valueOf(spend.Allocated_Transaction_Amount_gne__c);
                    totalAmount += spend.Allocated_Transaction_Amount_gne__c;
                    slw.paymentMethod = spend.Form_Of_Payment_gne__c;
                    slw.paymentReason = spend.Nature_Of_Payment_gne__c;
                    slw.brand = prepareBrands(spend.Brands_gne__c);
                }
                if( 'NonResearch'.equalsIgnoreCase(spendType) ) {
                	slw.recipient = recipient; //principalInvestigator;
                } else {
	                slw.recipient = recipient;
	                slw.principalInvestigator = principalInvestigator;
                }
                slw.eventLocation = eventLocation;
                slw.genetechRep = !String.isBlank(spend.Spend_User_Name_gne__c) ? spend.Spend_User_Name_gne__c : '';
                if(spend.Sch_Category_gne__c != null) {
                    slw.locationDet = getSpendDetails(spend);
                } else {
                    slw.locationDet = new List<SpendAdditionalInfo>();
                }
                System.debug('----------- 3 ' + spend.AGS_ST_Expense_Bookmarks__r.size());
                if(spend.AGS_ST_Expense_Bookmarks__r.size() > 0) {
                    slw.bookmarked = 'true';
                    vd.noBookmarked++;
                } else {
                    slw.bookmarked = 'false';
                }
                System.debug('----------- 4 ' + spend.AGS_ST_DisputeManagement_gne__r.size());
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                    for(integer i=0;i<spend.AGS_ST_DisputeManagement_gne__r.size();i++) {
                        slw.historyList.addAll(disputeHistoryMap.get(spend.AGS_ST_DisputeManagement_gne__r[i].id));
                    }
                } else {
                    slw.historyList = new String[]{};
                }
                spendsListForView.add(slw);
            }
            vd.spendNo = String.valueOf(spendNo);
            vd.totalAmount = String.valueOf(totalAmount);
            vd.spendList = spendsListForView;
            System.debug('----------- data finish ' + vd);
            return vd;
        } catch(Exception e) {
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'getSpends');
            return null;
        }
    }
    
    public static NonResearchPaymentsData getNonResearchSpends(Boolean isFirstCall,Boolean isDateFilterApply, Boolean isAmountFilterApply, Boolean isYearFilterApply, String dateFrom, String dateTo,String amountFrom,List<String> status, List<String> method, List<String> reason, List<String> brand,Boolean bookmarkedSpends,Boolean getNewest, Decimal dateRangeDays, String cmsPaymentId) {   
        try {
            system.debug('----isFirstCall='+isFirstCall+'----isDateFilterApply='+isDateFilterApply+'----isAmountFilterApply='+isAmountFilterApply+'----dateFrom='+dateFrom+'----dateTo='+dateTo+'----amountFrom='+amountFrom+'----status='+status+'----method='+method+'----reason='+reason+'----brand='+brand+'----bookmarkedSpends='+bookmarkedSpends+'----getNewest='+getNewest+'----dateRangeDays='+dateRangeDays);
            
            List<String> yearList = new List<String>();
            yearList.add(String.valueof(Date.today().year()-1));
            yearList.add(String.valueof(Date.today().year()));
            Set<String> spendsToSkip = new Set<String>();
            Set<String> paymentMethods = new Set<String>();
            Set<String> paymentReasons = new Set<String>();
            Set<String> brands = new Set<String>();
            Integer spendNo = 0;
            // Total amount and No. Bookmarked are counted only on first call (without filters)!!!
            Decimal totalAmount = 0.0;
            Integer noBookmarked = 0;
            
            AGS_Spend_Expense_Transaction_gne__c[] spends; 
            if(isFirstCall) {
                spends = getNonResearchTransactions(null,null);           
                Date df = Date.valueof(dateFrom);
                Date dt = Date.valueof(dateTo);
                Integer optOutNr = 0;
                AGS_Spend_Expense_Transaction_gne__c[] spendsTmp = new AGS_Spend_Expense_Transaction_gne__c[]{};                
                for(AGS_Spend_Expense_Transaction_gne__c spend : spends) {
                    if(spend.Event_Date_gne__c != null && spend.Event_Date_gne__c >= df && spend.Event_Date_gne__c <= dt) {
                        spendsTmp.add(spend);
                    }
                    // Fix for showing ALL FOP/NOP
                    AGS_ST_DisputeManagement_gne__c dispute;
                    if(checkIfTakeFromDispute(spend)) {
                    	dispute = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1];
                        paymentMethods.add(dispute.Form_Of_Payment_gne__c);
                        paymentReasons.add(dispute.Nature_Of_Payment_gne__c);
                        String brandsVal = prepareBrands(dispute.Drug_Name_gne__c);
                        if(brandsVal != null) {
                            brands.addAll(brandsVal.split(', ', 0));
                        }
                    } else {
                        paymentMethods.add(spend.Form_Of_Payment_gne__c);
                        paymentReasons.add(spend.Nature_Of_Payment_gne__c);
                        if(spend.AGS_expense_products_intercations1__r.size()>0) {
                            for(Integer i=0;i<spend.AGS_expense_products_intercations1__r.size();i++) {
                                brands.add(spend.AGS_expense_products_intercations1__r[i].AGS_Brand_gne__r.Brand_Name__c); 
                            }
                        }
                    }
                    
                    if(!checkOptOut(spend)) {               
                        if(checkIfTakeFromDispute(spend)) {
                            totalAmount += dispute.Amount_gne__c;
                        } else {
                            totalAmount += spend.Allocated_Transaction_Amount_gne__c;                    
                        }
                    } else {
                        optOutNr++;
                    }   
                    if(spend.AGS_ST_Expense_Bookmarks__r.size() > 0) {
                        noBookmarked++;
                    }
                }
                spendNo = spends.size() - optOutNr;
                spends = spendsTmp;
            } else {
                spends = getNonResearchTransactions(dateFrom,dateTo);
                spendNo = spends.size();
            }
            
            Map<Id,Id> disputesIds = new Map<Id,Id>();
            Set<ID> spendsId = new Set<ID>();
            for(AGS_Spend_Expense_Transaction_gne__c spend : spends) {
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                    // fist check Opt Out flag on DispueManagement, if true skip this spend
                    if(checkOptOut(spend)) {             
                        spendsToSkip.add(spend.Id);
                        continue;
                    }
                    
                    for(Integer i=0;i<spend.AGS_ST_DisputeManagement_gne__r.size();i++) {
                        disputesIds.put(spend.AGS_ST_DisputeManagement_gne__r[i].Id, spend.Id);
                    }
                }
                spendsId.add(spend.id);
            }
            
            List<AGS_ST_DisputeManagement_gne__History> disputesHistory = [SELECT CreatedDate,Field,NewValue,OldValue,ParentId,Parent.Name FROM AGS_ST_DisputeManagement_gne__History where ParentId in :disputesIds.keySet() order by createddate];
            Map<Id,List<String>> disputeHistoryMap = new Map<Id,List<String>>();
            for(AGS_ST_DisputeManagement_gne__History disputeHistory:disputesHistory) {
                if(disputeHistory.Field == 'External_Status_gne__c' || disputeHistory.Field == 'created') {
                    String historyDescription = getHistoryDescription(disputeHistory);
                    if(disputeHistoryMap.containsKey(disputeHistory.ParentId)) {
                        if(historyDescription != null) {
                            disputeHistoryMap.get(disputeHistory.ParentId).add(historyDescription);
                        }
                    } else {
                        if(historyDescription != null) {
                            List<String> tmpDisputeHistList = new List<String>();
                            tmpDisputeHistList.add(String.valueof(historyDescription));
                            disputeHistoryMap.put(disputeHistory.ParentId,tmpDisputeHistList);
                        }
                    }
                }
            }
            AGS_ST_User_gne__c stUserLocal = stUser;
            NonResearchPaymentsData vd = new NonResearchPaymentsData();
            vd.noBookmarked = noBookmarked;
            if(isFirstCall) {
                vd.hcpName = stUserLocal.First_name__c +' '+ stUserLocal.Last_name__c;
                vd.hcpSpecialty = String.isBlank(stUserLocal.Mapped_Account__r.Specialties_gne__c) ? '' : stUserLocal.Mapped_Account__r.Specialties_gne__c;
                Address_vod__c addr = AGS_ST_DbUtils.getGoldAddressByAccountId(stUserLocal.Mapped_Account__c);
                vd.hcpStreetAddress = addr.Name;
                vd.hcpCity = addr.City_vod__c;
                vd.hcpState = addr.State_vod__c;
                vd.hcpZip = addr.Zip_vod__c;
                
                vd.years = yearList;
                if(stUserLocal.Email_address__c != null && stUserLocal.Email_address__c != '') {
                    vd.userEmailAddress = stUserLocal.Email_address__c;
                } else {
                    vd.userEmailAddress = stUserLocal.SFDC_User__r.username;
                }
                if(stUserLocal.Filter_date_from_gne__c != null && stUserLocal.Filter_date_to_gne__c != null && stUserLocal.Filter_date_from_gne__c != '' && stUserLocal.Filter_date_to_gne__c != '') {
                    vd.filterDateFrom = stUserLocal.Filter_date_from_gne__c;
                    vd.filterDateTo = stUserLocal.Filter_date_to_gne__c ;
                }
                if(stUserLocal.Filter_date_range_gne__c  != null && stUserLocal.Filter_date_range_gne__c != 0) {
                    vd.filterDaysRange = stUserLocal.Filter_date_range_gne__c;
                } else {
                    vd.filterDaysRange = 0;
                }
                if(stUserLocal.Filter_amount__c != null && stUserLocal.Filter_amount__c != '') {
                    vd.filterAmount = stUserLocal.Filter_amount__c;
                }
            } else {
                vd.filterDateFrom = dateFrom;
                vd.filterDateTo = dateTo;
                vd.filterAmount = amountFrom;
                vd.filterDaysRange = dateRangeDays;
                if(isDateFilterApply || isAmountFilterApply) {
                    updateStUserWithFilter(false,isDateFilterApply,isAmountFilterApply,isYearFilterApply,dateFrom,dateTo,dateRangeDays,amountFrom);
                }
            }
            DateTime userLastLogin = getUserLastLogin(stUserLocal.SFDC_User__c);
            System.debug('--------- userLastLogin ' + userLastLogin);
            Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>> spendHistoryMap = new Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>>();
            List<AGS_Spend_Expense_Transaction_gne__History> spendsHistory = [SELECT CreatedDate,Field,ParentId,NewValue,OldValue FROM AGS_Spend_Expense_Transaction_gne__History where ParentId in :spendsId and createddate > :userLastLogin];
            for(AGS_Spend_Expense_Transaction_gne__History spendHistory : spendsHistory) {
                if(spendHistoryMap.containsKey(spendHistory.ParentId)) {
                    spendHistoryMap.get(spendHistory.ParentId).add(spendHistory);
                } else {
                    List<AGS_Spend_Expense_Transaction_gne__History> tmpSpendHistory = new List<AGS_Spend_Expense_Transaction_gne__History>();
                    tmpSpendHistory.add(spendHistory);
                    spendHistoryMap.put(spendHistory.ParentId,tmpSpendHistory);
                }
            }
            system.debug('----spendHistoryMap'+spendHistoryMap);
            List<NonResearchPayment> spendsListForView = new List<NonResearchPayment>();
            for(AGS_Spend_Expense_Transaction_gne__c spend:spends) {
                if(spendsToSkip.contains(spend.Id))
                    continue;
                    
                system.debug('---spend in the loop'+spend);
                NonResearchPayment slw = new NonResearchPayment();
                slw.id = spend.id;
                slw.rcpt = setRecipient('NonResearch', spend);                
                if('1-R&D on New Product'.equals(spend.Delayed_Reporting_Code_gne__c)) {
                    slw.delayed = 'true';
                } else { 
                    slw.delayed = 'false';
                }
                slw.eventDate = String.valueOf(spend.Event_Date_gne__c);

                Date spendEventDate = spend.Event_Date_gne__c;
                // Check CMS Payment Id DISPLAY DATE
                AGS_ST_Settings_gne__c agsStSet = AGS_ST_Utils.getDefaultCustomSettings();
                Boolean showCmsPaymentId = false;
                if(agsStSet != null && agsStSet.CmsPaymentIdDisplayDate_gne__c != null) {
                    Date displayDate = agsStSet.CmsPaymentIdDisplayDate_gne__c;
                    Date currentDate = Date.today();
                    if(displayDate <= currentDate) {
                        showCmsPaymentId = true;
                    }
                }
                // Managing CMS Payment Id
                if(showCmsPaymentId) {
                    if(spendEventDate != null && spendEventDate.year() < Date.today().year()) {
                       slw.cmsId = spend.CMS_Payment_ID_gne__c;
                    } else {
                       slw.cmsId = '';
                    }
                    if(!String.isBlank(cmsPaymentId) && slw.cmsId != cmsPaymentId) {
                        continue;
                    }
                }
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                    slw.status = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].External_Status_gne__c;
                    slw.cmsDisputeId = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].Dispute_List_gne__r.CmsDisputeId_gne__c;
                    if(status.size()>0) {
                        Boolean isStatusFound = false;
                        for(String st:status) {
                            if(slw.status == st) {
                                isStatusFound = true;
                            }
                        }
                        if(!isStatusFound) {
                            continue;
                        }
                    }
                } else {
                    slw.status = 'Undisputed';
                    if(status.size()>0) {
                        continue;
                    }
                }
                slw.context = String.valueOf(spend.Context_gne__c);
                if(checkIfTakeFromDispute(spend)) {
                    AGS_ST_DisputeManagement_gne__c dispute = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1];
                    slw.amount = String.valueOf(dispute.Amount_gne__c);
                    //totalAmount += dispute.Amount_gne__c;
                    if(amountFrom != '') {
                        system.debug('----Decimal.valueOf(amountFrom)'+Decimal.valueOf(amountFrom)+'dispute.Amount_gne__c'+dispute.Amount_gne__c);
                        if(Decimal.valueOf(amountFrom) > dispute.Amount_gne__c)
                            continue;
                    }
                    slw.paymentMethod = dispute.Form_Of_Payment_gne__c;
                    if(method.size()>0) {
                        Boolean isFopFound = false;
                        for(String m:method) {
                            if(slw.paymentMethod.toUpperCase().contains(m.toUpperCase())) {
                                isFopFound = true;
                            }
                        }
                        if(!isFopFound) {
                            continue;
                        }
                    }
                    slw.paymentReason = dispute.Nature_Of_Payment_gne__c;
                    if(reason.size()>0) {
                        Boolean isNopFound = false;
                        for(String r:reason) {
                            if(slw.paymentReason.toUpperCase().contains(r.toUpperCase())) {
                                isNopFound = true;
                            }
                        }
                        if(!isNopFound) {
                            continue;
                        }
                    }
                    // Brands
                    slw.brand = prepareBrands(dispute.Drug_Name_gne__c);
                    if(brand.size()>0) {
                        Boolean isBrandFound = false;
                        for(String br:brand) {
                            if(slw.brand.toUpperCase().contains(br)) {
                                isBrandFound = true;
                            }
                        }
                        if(!isBrandFound) {
                            continue;
                        }
                    }
                    // Fix for showing ALL FOP/NOP
                    //paymentMethods.add(dispute.Form_Of_Payment_gne__c);
                    //paymentReasons.add(dispute.Nature_Of_Payment_gne__c);
                    //if(slw.brand != null)
                    //    brands.addAll(slw.brand.split(', ', 0));
                } else {
                    // Fix for showing ALL FOP/NOP/Brand
                    //paymentMethods.add(spend.Form_Of_Payment_gne__c);
                    //paymentReasons.add(spend.Nature_Of_Payment_gne__c);
                    slw.amount = String.valueOf(spend.Allocated_Transaction_Amount_gne__c);
                    //totalAmount += spend.Allocated_Transaction_Amount_gne__c;
                    if(amountFrom != '') {
                        system.debug('----Decimal.valueOf(amountFrom)'+Decimal.valueOf(amountFrom)+'spend.Allocated_Transaction_Amount_gne__c'+spend.Allocated_Transaction_Amount_gne__c);
                        if(Decimal.valueOf(amountFrom) > spend.Allocated_Transaction_Amount_gne__c)
                            continue;
                    }
                    slw.paymentMethod = spend.Form_Of_Payment_gne__c;
                    if(method.size()>0) {
                        Boolean isFopFound = false;
                        for(String m:method) {
                            if(slw.paymentMethod.toUpperCase().contains(m.toUpperCase())) {
                                isFopFound = true;
                            }
                        }
                        if(!isFopFound) {
                            continue;
                        }
                    }
                    slw.paymentReason = spend.Nature_Of_Payment_gne__c;
                    if(reason.size()>0) {
                        Boolean isNopFound = false;
                        for(String r:reason) {
                            if(slw.paymentReason.toUpperCase().contains(r.toUpperCase())) {
                                isNopFound = true;
                            }
                        }
                        if(!isNopFound) {
                            continue;
                        }
                    }
                    // Brands
                    system.debug('spend.AGS_expense_products_intercations1__r'+spend.AGS_expense_products_intercations1__r);
                    if(spend.AGS_expense_products_intercations1__r.size()>0) {
                        for(Integer i=0;i<spend.AGS_expense_products_intercations1__r.size();i++) {
                            slw.brand += spend.AGS_expense_products_intercations1__r[i].AGS_Brand_gne__r.Brand_Name__c + ', ';
                            //brands.add(spend.AGS_expense_products_intercations1__r[i].AGS_Brand_gne__r.Brand_Name__c);  // Fix for showing ALL FOP/NOP/Brand
                        }
                        system.debug('---slw.brand'+slw.brand);
                        if(brand.size()>0) {
                            Boolean isBrandFound = false;
                            for(String br:brand) {
                                if(slw.brand.toUpperCase().contains(br)) {
                                    isBrandFound = true;
                                }
                            }
                            if(!isBrandFound) {
                                continue;
                            }
                        }
                    } else {
                        slw.brand = '';
                        if(brand.size()>0) {
                            continue;
                        }
                    }
                    slw.brand = removeLastComma(slw.brand);
                }
                if(spend.Sch_Category_gne__c != null) {
                    slw.locationDet = getSpendDetails(spend);
                } else {
                    slw.locationDet = new List<SpendAdditionalInfo>();
                }
                Boolean newSpend = isNewUpdatedSpendNew(spend, spendHistoryMap.get(spend.id));
                System.debug('-------------- newSpend ' + newSpend);
                if(newSpend) {
                    vd.noNewest++;
                }
                if(getNewest)    {
                    if(!newSpend)
                        continue;
                }
                if(spend.AGS_ST_Expense_Bookmarks__r.size() > 0) {
                    slw.bookmarked = 'true';
                    //vd.noBookmarked++;
                } else {
                    slw.bookmarked = 'false';
                }
                if(bookmarkedSpends && slw.bookmarked == 'false') {
                    continue;
                }
                system.debug('------'+spend.AGS_ST_Expense_Bookmarks__r.size());
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                    for(integer i= spend.AGS_ST_DisputeManagement_gne__r.size()-1;i>=0;i--) {
                        slw.historyList.addAll(disputeHistoryMap.get(spend.AGS_ST_DisputeManagement_gne__r[i].id));
                    }
                } else {
                    slw.historyList = new String[]{};
                }
                spendsListForView.add(slw);
                system.debug('------slw'+slw);
            }
            system.debug('------'+spendsListForView);
            system.debug('------spendsListForView.size()'+spendsListForView.size());
            vd.paymentMethods.addAll(paymentMethods);
            vd.paymentReasons.addAll(paymentReasons);
            vd.brands.addAll(brands); 
            vd.spendNo = String.valueOf(spendNo);
            vd.totalAmount = String.valueOf(totalAmount);
            vd.spendList = spendsListForView;
            system.debug('------'+spendsListForView);
            system.debug('------'+spendsListForView.size());
            system.debug('------'+vd);
            return vd;
        }
        catch(Exception e)
        {
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'getSpends');
            return null;
        }
    }

    public static ResearchPaymentsData getResearchSpends(Boolean isFirstCall,Boolean isDateFilterApply, Boolean isAmountFilterApply, Boolean isYearFilterApply, String dateFrom, String dateTo,String amountFrom,List<String> status, List<String> brand,Boolean bookmarkedSpends,Boolean getNewest, Decimal dateRangeDays, String cmsPaymentId) {
        try {
            Set<String> spendsToSkip = new Set<String>();
            Set<String> statusSet = new Set<String>();
            List<String> yearList = new List<String>();
            yearList.add(String.valueof(Date.today().year()-1));
            yearList.add(String.valueof(Date.today().year()));
            if(status != null) {
                for(String st : status) {
                    statusSet.add(st.toUpperCase());    
                }
            }
                              
            Set<String> brands = new Set<String>();
            Integer spendNo = 0;
            // Total amount and No. Bookmarked are counted only on first call (without filters)!!!
            Decimal totalAmount = 0.0;
            Integer noBookmarked = 0;
                      
            AGS_Spend_Expense_Transaction_gne__c[] spends; 
            if(isFirstCall) {
                spends = getResearchTransactions(null,null);   
                Integer optOutNr = 0;        
                Date df = Date.valueof(dateFrom);
                Date dt = Date.valueof(dateTo);
                AGS_Spend_Expense_Transaction_gne__c[] spendsTmp = new AGS_Spend_Expense_Transaction_gne__c[]{};                
                for(AGS_Spend_Expense_Transaction_gne__c spend:spends) {
                    if(spend.Event_Date_gne__c != null && spend.Event_Date_gne__c >= df && spend.Event_Date_gne__c <= dt) {
                        spendsTmp.add(spend);
                    }
                    AGS_ST_DisputeManagement_gne__c dispute;
                    if(!checkOptOut(spend)) {
                        if(checkIfTakeFromDispute(spend)) {
                        	dispute = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1];
                            totalAmount += dispute.Amount_gne__c;
                        } else {
                            totalAmount += spend.Allocated_Transaction_Amount_gne__c;                    
                        }
                    } else {
                        optOutNr++;
                    }
                    if(spend.AGS_ST_Expense_Bookmarks__r.size() > 0) {
                        noBookmarked++;
                    }
	                // Fix for showing ALL FOP/NOP/Brand
	                String brandVal = '';
	                if(dispute != null && dispute.Internal_Status_gne__c == 'Corrected Pending SSR') {
	                    brandVal = prepareBrands(dispute.Drug_Name_gne__c);
	                } else {
	                    brandVal = prepareBrands(spend.Brands_gne__c);
	                }
	                if(brandVal != null) {
	                    brands.addAll(brandVal.split(', ', 0));
	                }
                }
                spendNo = spends.size()- optOutNr;
                spends = spendsTmp;
            } else {
                spends = getResearchTransactions(dateFrom,dateTo);
                spendNo = spends.size();
            }
            Map<Id,Id> disputesIds = new Map<Id,Id>();
            Set<ID> spendsId = new Set<ID>();
            for(AGS_Spend_Expense_Transaction_gne__c spend:spends) {
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                    // fist check Opt Out flag on DispueManagement, if true skip this spend
                    if(checkOptOut(spend)) {             
                        spendsToSkip.add(spend.Id);                
                        continue;
                    }
                    for(Integer i=0;i<spend.AGS_ST_DisputeManagement_gne__r.size();i++) {
                        disputesIds.put(spend.AGS_ST_DisputeManagement_gne__r[i].Id, spend.Id);
                    } 
                }
                spendsId.add(spend.id);
            }
            
            List<AGS_ST_DisputeManagement_gne__History> disputesHistory = [SELECT CreatedDate,Field,NewValue,OldValue,ParentId,Parent.Name FROM AGS_ST_DisputeManagement_gne__History where ParentId in :disputesIds.keySet() order by createddate];
            Map<Id,List<String>> disputeHistoryMap = new Map<Id,List<String>>();
            for(AGS_ST_DisputeManagement_gne__History disputeHistory:disputesHistory) {
                if(disputeHistory.Field == 'External_Status_gne__c' || disputeHistory.Field == 'created') {
                    String historyDescription = getHistoryDescription(disputeHistory);
                    if(historyDescription!=null) {
                        if(!disputeHistoryMap.containsKey(disputeHistory.ParentId)) {
                            disputeHistoryMap.put(disputeHistory.ParentId, new List<String>());
                        }
                        disputeHistoryMap.get(disputeHistory.ParentId).add(historyDescription);
                    }
                }
            }
            AGS_ST_User_gne__c stUserLocal = stUser;
            //NonResearchPaymentsData vd = new NonResearchPaymentsData();
            ResearchPaymentsData vd = new ResearchPaymentsData();
            vd.noBookmarked = noBookmarked;
            if(isFirstCall) {
                vd.years = yearList;
                if(stUserLocal.Research_Spends_Date_From_gne__c != null && stUserLocal.Research_Spends_Date_To_gne__c != null && stUserLocal.Research_Spends_Date_From_gne__c != '' && stUserLocal.Research_Spends_Date_To_gne__c != '') {
                    vd.filterDateFrom = stUserLocal.Research_Spends_Date_From_gne__c;
                    vd.filterDateTo = stUserLocal.Research_Spends_Date_To_gne__c ;
                }
                if(stUserLocal.Research_Spends_Date_Range_gne__c  != null && stUserLocal.Research_Spends_Date_Range_gne__c != 0) {
                    vd.filterDaysRange = stUserLocal.Research_Spends_Date_Range_gne__c;
                } else {
                    vd.filterDaysRange = 0;
                }
                if(stUserLocal.Research_Spends_Filter_Amount_gne__c != null && stUserLocal.Research_Spends_Filter_Amount_gne__c != '') {
                    vd.filterAmount = stUserLocal.Research_Spends_Filter_Amount_gne__c;
                }
            } else {
                vd.filterDateFrom = dateFrom;
                vd.filterDateTo = dateTo;
                vd.filterAmount = amountFrom;
                vd.filterDaysRange = dateRangeDays;
                if(isDateFilterApply || isAmountFilterApply)
                    updateStUserWithFilter(true,isDateFilterApply,isAmountFilterApply,isYearFilterApply,dateFrom,dateTo,dateRangeDays,amountFrom);
            }
            DateTime userLastLogin = getUserLastLogin(stUserLocal.SFDC_User__c);
            System.debug('--------- userLastLogin ' + userLastLogin);
            Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>> spendHistoryMap = new Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>>();
            List<AGS_Spend_Expense_Transaction_gne__History> spendsHistory = [SELECT CreatedDate,Field,ParentId,NewValue,OldValue FROM AGS_Spend_Expense_Transaction_gne__History where ParentId in :spendsId and createddate > :userLastLogin];
            for(AGS_Spend_Expense_Transaction_gne__History spendHistory:spendsHistory) {
                if(!spendHistoryMap.containsKey(spendHistory.ParentId)) {
                    spendHistoryMap.put(spendHistory.ParentId, new List<AGS_Spend_Expense_Transaction_gne__History>());
                }
                spendHistoryMap.get(spendHistory.ParentId).add(spendHistory);
            }
            system.debug('----spendHistoryMap'+spendHistoryMap);
            List<ResearchPayment> spendsListForView = new List<ResearchPayment>();
            for(AGS_Spend_Expense_Transaction_gne__c spend:spends) {
                if(spendsToSkip.contains(spend.Id)) {
                    continue;
                }
                system.debug('---spend in the loop'+spend);
                
                AGS_ST_DisputeManagement_gne__c dispute = null;
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0)
                    dispute = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1];
                
                ResearchPayment slw = new ResearchPayment();
                slw.id = spend.id;
                slw.rcpt = setRecipient('Research', spend);
                slw.pInvestigator = setPrincipalInvestigator('Research', spend);
                if('1-R&D on New Product'.equals(spend.Delayed_Reporting_Code_gne__c)) {
                    slw.delayed = 'true';
                } else { 
                    slw.delayed = 'false';
                }
                slw.eventDate = String.valueOf(spend.Event_Date_gne__c);
                Date spendEventDate = spend.Event_Date_gne__c;
                // Check CMS Payment Id DISPLAY DATE
                AGS_ST_Settings_gne__c agsStSet = AGS_ST_Utils.getDefaultCustomSettings();
                Boolean showCmsPaymentId = false;
                if(agsStSet != null && agsStSet.CmsPaymentIdDisplayDate_gne__c != null) {
                    Date displayDate = agsStSet.CmsPaymentIdDisplayDate_gne__c;
                    Date currentDate = Date.today();
                    if(displayDate <= currentDate) {
                        showCmsPaymentId = true;
                    }
                }
                // Managing CMS Payment Id
                if(showCmsPaymentId) {
                    if(spendEventDate != null && spendEventDate.year() < Date.today().year()) {
                       slw.cmsId = spend.CMS_Payment_ID_gne__c;
                    } else {
                       slw.cmsId = '';
                    }
                    if(!String.isBlank(cmsPaymentId) && slw.cmsId != cmsPaymentId) {
                        continue;
                    }
                }
                if(dispute!=null) {
                    slw.status = dispute.External_Status_gne__c;
                    slw.cmsDisputeId = dispute.Dispute_List_gne__r.CmsDisputeId_gne__c;
                    if(!statusSet.isEmpty() && !statusSet.contains(slw.status.toUpperCase()))
                        continue;
                } else {
                    slw.status = 'Undisputed';
                    if(status.size()>0)
                        continue;
                }
                Decimal tmpAmount = 0.0;
                slw.context = String.valueOf(spend.Context_gne__c);
                if(dispute != null && dispute.Internal_Status_gne__c == 'Corrected Pending SSR') {
                    if(amountFrom != '') {
                        system.debug('----Decimal.valueOf(amountFrom)'+Decimal.valueOf(amountFrom)+'dispute.Amount_gne__c'+dispute.Amount_gne__c);
                        if(Decimal.valueOf(amountFrom) > dispute.Amount_gne__c)
                            continue;
                    }
                    tmpAmount = dispute.Amount_gne__c;
                    slw.amount = String.valueOf(dispute.Amount_gne__c);
                    slw.brand = prepareBrands(dispute.Drug_Name_gne__c);
                } else {
                    tmpAmount = spend.Allocated_Transaction_Amount_gne__c;
                    slw.amount = String.valueOf(spend.Allocated_Transaction_Amount_gne__c);
                    slw.brand = prepareBrands(spend.Brands_gne__c);
                }
                if(amountFrom != '') {
                    if(Decimal.valueOf(amountFrom) > tmpAmount)
                            continue;
                }
                if(brand.size()>0) {
                    Boolean isBrandFound = false;
                    for(String br:brand) {
                        if(slw.brand.toUpperCase().contains(br.toUpperCase())) {
                            isBrandFound = true;
                            break;
                        }    
                    }
                    if(!isBrandFound)
                        continue;
                }
                // Fix for showing ALL FOP/NOP/Brand
                if(spend.Study_Name_gne__c != null) {
                    slw.studyTitle = spend.Study_Name_gne__c;
                }
                if(spend.Sch_Category_gne__c != null) {
                    slw.locationDet = getSpendDetails(spend);
                } else {
                    slw.locationDet = new List<SpendAdditionalInfo>();
                }
                
                Boolean newSpend = isNewUpdatedSpendNew(spend, spendHistoryMap.get(spend.id));
                System.debug('-------------- newSpend ' + newSpend);
                if(newSpend) {
                    vd.noNewest++;
                }
                if(getNewest) {
                    if(!newSpend) {
                        continue;
                    }
                }
                if(spend.AGS_ST_Expense_Bookmarks__r.size() > 0) {
                    slw.bookmarked = 'true';
                } else {
                    slw.bookmarked = 'false';
                }
                if(bookmarkedSpends && slw.bookmarked == 'false') {
                    continue;
                }
                system.debug('------'+spend.AGS_ST_Expense_Bookmarks__r.size());
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                    for(integer i=0;i<spend.AGS_ST_DisputeManagement_gne__r.size();i++) {
                        slw.historyList.addAll(disputeHistoryMap.get(spend.AGS_ST_DisputeManagement_gne__r[i].id));
                    }
                } else {
                    slw.historyList = new String[]{};
                }
                spendsListForView.add(slw);
            }
            vd.brands.addAll(brands);
            vd.spendNo = String.valueOf(spendNo);
            vd.totalAmount = String.valueOf(totalAmount);
            vd.spendList = spendsListForView;
            
            List<AGS_ST_FAQ_DYK_gne__c> descriptions = [SELECT id,Type_gne__c,ToolTip_Type_gne__c,TC_Description_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c where Type_gne__c='ToolTip' and ToolTip_Type_gne__c in ('BothPaymentTypesDescription', 'ResearchTypeDescription', 'NonResearchTypeDescription', 'HeaderDescriptionType') order by createddate];
            for(AGS_ST_FAQ_DYK_gne__c description : descriptions) {
                if('BothPaymentTypesDescription'.equals(description.ToolTip_Type_gne__c)) {
                    vd.bothTypesDesc = description.TC_Description_Text_gne__c;
                } else if('ResearchTypeDescription'.equals(description.ToolTip_Type_gne__c)) {
                    vd.researchTypeDesc = description.TC_Description_Text_gne__c;
                } else if('NonResearchTypeDescription'.equals(description.ToolTip_Type_gne__c)) {
                    vd.nonresearchTypeDesc = description.TC_Description_Text_gne__c;
                } else if('HeaderDescriptionType'.equals(description.ToolTip_Type_gne__c)) {
                	vd.paymentDetailHeaderDesc = description.TC_Description_Text_gne__c;
                }    
            }
            return vd;
        }
        catch(Exception e)
        {   
            System.debug('------------- exc ' + e);
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'getSpends');
            return null;
        }
    }
    
    public static Datetime getUserLastLogin(String userId) {
        // we cannot filter by Status, becasuse its not filterable field
        //if never logged in
        Datetime defaultLoginDate = datetime.newInstance(1900, 1, 1); 
        // check only last 100 logins
        List<LoginHistory> logHistory = [SELECT Id,LoginTime,Status,UserId FROM LoginHistory  where Userid =: userId  order by LoginTime desc limit 100];
        Boolean skipFirstSuccess = true;
        for(LoginHistory lHist : logHistory) {
            if('Success'.equals(lHist.Status) && skipFirstSuccess)
                skipFirstSuccess = false;
            else if('Success'.equals(lHist.Status) && !skipFirstSuccess)
                return lHist.LoginTime;
        }
        return defaultLoginDate;
    }
    
    public static Recipient setRecipient(String spendType, AGS_Spend_Expense_Transaction_gne__c spend) {
        Recipient rec = new Recipient();
        // TODO: Should this work this way for Non-Research? Should we add NPI?
        /*
        if( 'NonResearch'.equals(spendType) ) {
            rec.name = spend.Party2_Name_gne__c;
            rec.taxId = spend.Party2_TIN_gne__c;
            rec.npi = spend.Party2_NPI_gne__c;
            rec.primaryAddress = spend.Party2_ADDRESS_LINE1_gne__c;
            rec.city = spend.Party2_City_gne__c;
            rec.state = spend.Party2_State_gne__c;
            rec.zipCode = spend.Party2_ZIP_gne__c;
        } else if( 'Research'.equals(spendType) ) {           
            rec.name = spend.Party1_Name_gne__c;
            rec.taxId = spend.Party1_TIN_gne__c;
            rec.npi = spend.Party1_NPI_gne__c;
            rec.primaryAddress = spend.Party1_ADDRESS_LINE1_gne__c;
            rec.city = spend.Party1_CITY_gne__c;
            rec.state = spend.Party1_State_gne__c;
            rec.zipCode = spend.Party1_ZIP_gne__c;    
        }
        */
        rec.name = spend.Party1_Name_gne__c;
        rec.taxId = spend.Party1_TIN_gne__c;
        rec.npi = spend.Party1_NPI_gne__c;
        rec.primaryAddress = spend.Party1_ADDRESS_LINE1_gne__c;
        rec.city = spend.Party1_CITY_gne__c;
        rec.state = spend.Party1_State_gne__c;
        rec.zipCode = spend.Party1_ZIP_gne__c;
        return rec;
    }
    
    public static PrincipalInvestigator setPrincipalInvestigator(String spendType, AGS_Spend_Expense_Transaction_gne__c spend) {
        PrincipalInvestigator pi = new PrincipalInvestigator();
        if( 'Research'.equals(spendType) ) {
            pi.name = spend.Party2_Name_gne__c;
            pi.taxId = spend.Party2_TIN_gne__c;
            pi.npi = spend.Party2_NPI_gne__c;
            pi.primaryAddress = spend.Party2_ADDRESS_LINE1_gne__c;
            pi.city = spend.Party2_City_gne__c;
            pi.state = spend.Party2_State_gne__c;
            pi.zipCode = spend.Party2_ZIP_gne__c;
        }
        return pi;
    }

    public static List<SpendAdditionalInfo> getSpendDetails(AGS_Spend_Expense_Transaction_gne__c orgSpend) {
        List<SpendAdditionalInfo> loc = new List<SpendAdditionalInfo>();
        // SAPTEAPRIMO, APRIMO (gSSP, Excel), IHCP
        if('APRIMO'.equals(orgSpend.Source_System_Code_gne__c) || 'Excel'.equals(orgSpend.Source_System_Code_gne__c) || 'gSSP'.equals(orgSpend.Source_System_Code_gne__c) || 'IHCP'.equalsIgnoreCase(orgSpend.Source_System_Code_gne__c) || 'SAPTEAPRIMO'.equals(orgSpend.Source_System_Code_gne__c)) {
            // show Event Type, Speaker Name, Event Location, Genentech Representative
            loc.add(new SpendAdditionalInfo('Event Type', orgSpend.Event_Type_gne__c));
            if(orgSpend.Speaker_Name_gne__c != null && orgSpend.Speaker_Name_gne__c != '' ) {
                loc.add(new SpendAdditionalInfo('Speaker Name', orgSpend.Speaker_Name_gne__c));
            }
            loc.add(new SpendAdditionalInfo('Genentech Representative', !String.isBlank(orgSpend.Spend_User_Name_gne__c) ? orgSpend.Spend_User_Name_gne__c : ''));
            // Event Location
            String evlocation;
            if('IHCP'.equalsIgnoreCase(orgSpend.Source_System_Code_gne__c)) { 
                evlocation = orgSpend.Street_Address_gne__c + ' ' + orgSpend.Event_City_gne__c +', '+ orgSpend.Event_State_gne__c +' '+ orgSpend.Event_Zip_Code_gne__c+', '+orgSpend.Country_gne__c;
            } else { 
                evlocation = orgSpend.Street_Address_gne__c + ' ' + orgSpend.Event_City_gne__c +', '+ orgSpend.Event_State_gne__c +' '+ orgSpend.Event_Zip_Code_gne__c;
            }
            loc.add(new SpendAdditionalInfo('Event Location', cleanString(evlocation)));
        //  CRO, SFDCGIFTSFDC_SFA, like SAPTESFDC%, CONCUR, SFA               
        } else if('CRO'.equals(orgSpend.Source_System_Code_gne__c) || 'CONCUR'.equals(orgSpend.Source_System_Code_gne__c) || 'SFA'.equals(orgSpend.Source_System_Code_gne__c) || 'SFDCGIFTSFDC_SFA'.equals(orgSpend.Source_System_Code_gne__c) || (orgSpend.Source_System_Code_gne__c != null && orgSpend.Source_System_Code_gne__c.startsWith('SAPTESFDC'))) {
            // show Event Location
            String evlocation = orgSpend.Street_Address_gne__c +' ' +  orgSpend.Event_City_gne__c +', '+ orgSpend.Event_State_gne__c +' '+ orgSpend.Event_Zip_Code_gne__c;
            // For SFA & Out Of Office transaction, Event Location should be blank
            if( ('SAPTESFDC_SFA'.equals(orgSpend.Source_System_Code_gne__c) || 'SFA'.equals(orgSpend.Source_System_Code_gne__c) || 'SFDCGIFTSFDC_SFA'.equals(orgSpend.Source_System_Code_gne__c) ) && orgSpend.SCH_Expense__c.startsWithIgnoreCase('Out of Office') ) {
                evlocation = '';
            }
            loc.add(new SpendAdditionalInfo('Event Location',cleanString(evlocation)));
            // Genentech Representative
            loc.add(new SpendAdditionalInfo('Genentech Representative',!String.isBlank(orgSpend.Spend_User_Name_gne__c) ? orgSpend.Spend_User_Name_gne__c : ''));             
        // SAPBW, A/P
        } else if('SAPBW'.equals(orgSpend.Source_System_Code_gne__c) || 'A/P'.equals(orgSpend.Source_System_Code_gne__c)) {
            // show Event Location, Genentech Representative
            String evlocation = orgSpend.Event_City_gne__c + ', ' + orgSpend.Event_State_gne__c  +' '+ orgSpend.Event_Zip_Code_gne__c;
            loc.add(new SpendAdditionalInfo('Event Location',cleanString(evlocation)));  
            loc.add(new SpendAdditionalInfo('Genentech Representative',!String.isBlank(orgSpend.Spend_User_Name_gne__c) ? orgSpend.Spend_User_Name_gne__c : ''));
        } 
        return loc;
    }
    
    public static Boolean checkOptOut(AGS_Spend_Expense_Transaction_gne__c spend) {
        // fist check Opt Out flag on DispueManagement, if true skip this spend
        if(spend.AGS_ST_DisputeManagement_gne__r.size()>0 && spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].Internal_Status_gne__c == 'Corrected Pending SSR'
            && spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].Opt_Out_gne__c == true) 
        {
            return true;
        }
        return false;
    }
    
    public static Boolean checkIfTakeFromDispute(AGS_Spend_Expense_Transaction_gne__c spend) {
        if(spend.AGS_ST_DisputeManagement_gne__r.size()>0 && spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].Internal_Status_gne__c == 'Corrected Pending SSR')
            return true;
        return false;           
    }
    
    public static String recognizeSystem(AGS_Spend_Expense_Transaction_gne__c orgSpend) {
        if('APRIMO'.equals(orgSpend.Source_System_Code_gne__c) || 'Excel'.equals(orgSpend.Source_System_Code_gne__c) || 'gSSP'.equals(orgSpend.Source_System_Code_gne__c) || 'IHCP'.equals(orgSpend.Source_System_Code_gne__c) || 'SAPTEAPRIMO'.equals(orgSpend.Source_System_Code_gne__c)) {
            return 'APRIMO/iHCP';
        } else if('CRO'.equals(orgSpend.Source_System_Code_gne__c)) {
            return 'CRO';
        } else if('SAP BW'.equals(orgSpend.Source_System_Code_gne__c) || 'SAPBW'.equals(orgSpend.Source_System_Code_gne__c) || 'A/P'.equals(orgSpend.Source_System_Code_gne__c)) {
            return 'SAPBW';
        } else if('SFDCGIFTSFDC_SFA'.equals(orgSpend.Source_System_Code_gne__c) || 'SFA'.equals(orgSpend.Source_System_Code_gne__c) || 'CONCUR'.equals(orgSpend.Source_System_Code_gne__c) || (orgSpend.Source_System_Code_gne__c != null && orgSpend.Source_System_Code_gne__c.startsWith('SAPTESFDC'))) {
            return 'SFDC';
        }
        return 'DEFAULT';
    }
    
    public static Boolean isNewUpdatedSpendNew(AGS_Spend_Expense_Transaction_gne__c spend, List<AGS_Spend_Expense_Transaction_gne__History> orgSpendHistory) {
        System.debug('---------- isNewUpdatedSpendNew ' + spend.id+ ' ' + orgSpendHistory);
        String sys = recognizeSystem(spend);
        if(orgSpendHistory == null || orgSpendHistory.isEmpty())
            return false;
            
        Map<String, List<String>> fieldsMap = new Map<String, List<String>>();
        fieldsMap.put('APRIMO/iHCP', new List<String>{'Event_City_gne__c','Event_State_gne__c','Street_Address_gne__c','Speaker_Name_gne__c','Spend_User_gne__c','Event_Type_gne__c'});
        //fieldsMap.put('iHCP', new List<String>{'Event_City_gne__c','Event_State_gne__c','Street_Address_gne__c','Speaker_Name_gne__c','Spend_User_gne__c','Event_Type_gne__c','Country_gne__c'});    
        fieldsMap.put('CRO', new List<String>{'Event_City_gne__c','Event_State_gne__c','Street_Address_gne__c','Spend_User_gne__c'});    
        fieldsMap.put('SAPBW', new List<String>{'Event_City_gne__c','Event_State_gne__c','Spend_User_gne__c'});    
        fieldsMap.put('SFDC', new List<String>{'Event_City_gne__c','Event_State_gne__c','Street_Address_gne__c','Spend_User_gne__c'});    
        List<String> allSpendsCheck = new List<String>{'Dispute_Number_gne__c','Allocated_Transaction_Amount_gne__c','Form_Of_Payment_gne__c','Nature_Of_Payment_gne__c','Brands_gne__c'};
        
        for(String categoryName :  fieldsMap.keySet()) {
            if(sys.contains(categoryName)) {
                for(AGS_Spend_Expense_Transaction_gne__History hist:orgSpendHistory) {
                    for(String field : fieldsMap.get(categoryName)) {
                        if(field.equals(hist.Field))
                            return true;
                    }
                }
            }
        }
        for(AGS_Spend_Expense_Transaction_gne__History hist:orgSpendHistory) {
            for(String field : allSpendsCheck) {
                if(field.equals(hist.Field))
                            return true;
            }
        }
        return false;
    }
    
/*
    public static Boolean isNewUpdatedSpend(List<AGS_Spend_Expense_Transaction_gne__History> orgSpendHistory, String schCategory, DateTime lastLogIn) {
        if(orgSpendHistory == null || orgSpendHistory.isEmpty())
            return false;
            
        Map<String, List<String>> fieldsMap = new Map<String, List<String>>();
        fieldsMap.put('APRIMO', new List<String>{'Event_City_gne__c','Event_State_gne__c','Street_Address_gne__c','Speaker_Name_gne__c','Spend_User_gne__c','Event_Type_gne__c'});
        fieldsMap.put('iHCP', new List<String>{'Event_City_gne__c','Event_State_gne__c','Street_Address_gne__c','Speaker_Name_gne__c','Spend_User_gne__c','Event_Type_gne__c','Country_gne__c'});    
        fieldsMap.put('CRO', new List<String>{'Event_City_gne__c','Event_State_gne__c','Street_Address_gne__c','Spend_User_gne__c'});    
        fieldsMap.put('SAPBW', new List<String>{'Event_City_gne__c','Event_State_gne__c','Spend_User_gne__c'});    
        fieldsMap.put('SFDC', new List<String>{'Event_City_gne__c','Event_State_gne__c','Street_Address_gne__c','Spend_User_gne__c'});    
        List<String> allSpendsCheck = new List<String>{'Dispute_Number_gne__c,Allocated_Transaction_Amount_gne__c','Form_Of_Payment_gne__c','Nature_Of_Payment_gne__c','Brands_gne__c'};
        
        for(String categoryName :  fieldsMap.keySet()) {
            if(schCategory.contains(categoryName)) {
                for(AGS_Spend_Expense_Transaction_gne__History hist:orgSpendHistory) {
                    for(String field : fieldsMap.get(categoryName)) {
                        if(field.equals(hist.Field))
                            return true;
                    }
                }
            }
        }
        for(AGS_Spend_Expense_Transaction_gne__History hist:orgSpendHistory) {
            for(String field : allSpendsCheck) {
                if(field.equals(hist.Field))
                            return true;
            }
        }
        return false;
    }
*/
    
    public static String removeLastComma(String stringToRemove)
    {
        return stringToRemove.substringBeforeLast(',');
    }
    
    public static Boolean isResearchSpend(AGS_Spend_Expense_Transaction_gne__c exp) {
        return (exp.Research_Pymt_Typ_Cd_gne__c != null &&  ('CLINICAL'.equals(exp.Research_Pymt_Typ_Cd_gne__c.toUpperCase()) || 'PRECLINICAL'.equals(exp.Research_Pymt_Typ_Cd_gne__c.toUpperCase())));
    }
    
    public static void updateStUserWithFilter(Boolean researchPayment, Boolean isDateFilterApply, Boolean isAmountFilterApply, Boolean isYearFilterApply, String dateFrom, String dateTo, Decimal dateRangeDays, String amount)
    {
        AGS_ST_User_gne__c st = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
        if(researchPayment == true && isDateFilterApply && !isYearFilterApply) {
            st.Research_Spends_Date_From_gne__c = dateFrom;
            st.Research_Spends_Date_Range_gne__c = dateRangeDays;
            st.Research_Spends_Date_To_gne__c = dateTo;         
        } else if(isDateFilterApply && !isYearFilterApply) {
            st.Filter_date_from_gne__c = dateFrom;
            st.Filter_date_to_gne__c = dateTo;
            st.Filter_date_range_gne__c = dateRangeDays;
        }
        if(researchPayment == true && isAmountFilterApply) {
            st.Research_Spends_Filter_Amount_gne__c = amount;
        } else if(isAmountFilterApply) {
            st.Filter_amount__c = amount;
        }
        update st;
    }
    
    public static String getHistoryDescription(AGS_ST_DisputeManagement_gne__History disputeHistory)
    {
        String histTxt; 
        if(disputeHistory.Field == 'created')
        {
            histTxt = 'Disputed on ' + disputeHistory.CreatedDate.format('MMM d yyyy HH:mm:ss') + ' (Case: '+ disputeHistory.Parent.Name+')';
        }
        else if(disputeHistory.Field == 'External_Status_gne__c')
        {
            histTxt = 'Status changed to '+disputeHistory.NewValue + ' on ' + disputeHistory.CreatedDate.format('MMM d yyyy HH:mm:ss');
        }
        else
        {
            return null;
        }
        return histTxt;
    }
    
    public static String cleanString(String text) {
        if(String.isBlank(text))
            return '';
        text = text.replace(' null', '').replace('null ', '').replace('null', '');
        while(text.endsWith(','))
            text = text.removeEnd(',');
        return text;    
    } 
    
    public static String prepareBrands(String brands) {
        // returned string will be allways like xxxx, xxx, xx, xxx
        if(brands == null || ''.equals(brands))
            return '';
            
        brands = brands.replace(', ', ',');
        brands = brands.replace(',', ', ');
        return brands;
    } 

    public static AGS_Spend_Expense_Transaction_gne__c[] getNonResearchTransactions(String dateFrom, String dateTo) {
        if(String.isBlank(stUser.Mapped_Account_MDM_Id__c)) {
            return new List<AGS_Spend_Expense_Transaction_gne__c>();
        }
        AGS_Spend_Expense_Transaction_gne__c[] spends;
        String qr = 'SELECT Context_gne__c, Dispute_Number_gne__c, Spend_User_Name_gne__c, Research_Pymt_Typ_Cd_gne__c, Delayed_Reporting_Code_gne__c, Event_Type_gne__c, Source_System_Code_gne__c,';
                qr += 'Brands_gne__c, LogicalDeleteFlag_gne__c, LastModifiedDate, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, Id, Name,';
                qr += 'Study_Name_gne__c, Event_Date_gne__c, Allocated_Transaction_Amount_gne__c,Event_Actual_Attendee_Count_gne__c,CMS_Payment_ID_gne__c,';
                qr += 'Sch_Category_gne__c, SCH_Expense__c, Event_City_gne__c, Event_State_gne__c, Speaker_Name_gne__c, Country_gne__c, Event_Zip_Code_gne__c, Street_Address_gne__c, Spend_User_gne__r.Name,';

                qr += 'Party1_Name_gne__c, Party1_ADDRESS_LINE1_gne__c, Party1_CITY_gne__c, Party1_State_gne__c, ';
                qr += 'Party1_ZIP_gne__c, Party1_TYPE_gne__c, Party1_TIN_gne__c, Party1_NPI_gne__c, ';
                qr += 'Party2_Name_gne__c, Party2_ADDRESS_LINE1_gne__c, Party2_City_gne__c, Party2_State_gne__c, ';
                qr += 'Party2_ZIP_gne__c, Party2_TYPE_gne__c, Party2_NPI_gne__c, Party2_TIN_gne__c, ';

                qr += '(select id, External_Status_gne__c, Internal_Status_gne__c, Amount_gne__c, Form_Of_Payment_gne__c, Drug_Name_gne__c, Nature_Of_Payment_gne__c, Dispute_Resolver_gne__r.Name, Opt_Out_gne__c, Dispute_List_gne__r.CmsDisputeId_gne__c from AGS_ST_DisputeManagement_gne__r where isPrivate__c=false order by CreatedDate asc),';
                qr += '(select AGS_Brand_gne__r.Brand_Name__c from AGS_expense_products_intercations1__r),';
                qr += '(select id from AGS_ST_Expense_Bookmarks__r where Bookmarked_User_gne__c=\''+UserInfo.getUserId()+ '\') FROM AGS_Spend_Expense_Transaction_gne__c ';
        
                qr += getSpendWhereString(stUser.Mapped_Account_MDM_Id__c, 'NonResearch', 0, dateFrom, dateTo, null);
                qr+= ' order by Event_Date_gne__c desc';
        system.debug('----qr'+qr);
        return Database.query(qr); 
    }

    public static AGS_Spend_Expense_Transaction_gne__c[] getResearchTransactions(String dateFrom, String dateTo)
    {
        if(String.isBlank(stUser.Mapped_Account_MDM_Id__c)) {
            return new List<AGS_Spend_Expense_Transaction_gne__c>();
        }
        AGS_Spend_Expense_Transaction_gne__c[] spends; 
        String qr = 'SELECT Context_gne__c, Dispute_Number_gne__c, Spend_User_Name_gne__c, Research_Pymt_Typ_Cd_gne__c, Delayed_Reporting_Code_gne__c, Event_Type_gne__c, Source_System_Code_gne__c,';
                qr += 'Study_Name_gne__c, SCH_Activity_gne__c, SCH_Spend_gne__c, SCH_Expense__c, Brands_gne__c, LogicalDeleteFlag_gne__c, LastModifiedDate, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, Id, Name,';
                qr += 'Event_Date_gne__c, Allocated_Transaction_Amount_gne__c, Event_Actual_Attendee_Count_gne__c, CMS_Payment_ID_gne__c,';
                qr += 'Sch_Category_gne__c, Event_City_gne__c, Event_State_gne__c, Speaker_Name_gne__c, Country_gne__c, Event_Zip_Code_gne__c, Street_Address_gne__c, Spend_User_gne__r.Name,';

                qr += 'Party1_Name_gne__c, Party1_ADDRESS_LINE1_gne__c, Party1_CITY_gne__c, Party1_State_gne__c, ';
                qr += 'Party1_ZIP_gne__c, Party1_TYPE_gne__c, Party1_TIN_gne__c, Party1_NPI_gne__c, ';
                qr += 'Party2_Name_gne__c, Party2_ADDRESS_LINE1_gne__c, Party2_City_gne__c, Party2_State_gne__c, ';
                qr += 'Party2_ZIP_gne__c, Party2_TYPE_gne__c, Party2_NPI_gne__c, Party2_TIN_gne__c, ';

                qr += '(select id, External_Status_gne__c, Internal_Status_gne__c, Amount_gne__c, Form_Of_Payment_gne__c, Drug_Name_gne__c, Nature_Of_Payment_gne__c, Dispute_Resolver_gne__r.Name, Opt_Out_gne__c, Dispute_List_gne__r.CmsDisputeId_gne__c from AGS_ST_DisputeManagement_gne__r where isPrivate__c=false order by CreatedDate asc),';
                qr += '(select id from AGS_ST_Expense_Bookmarks__r where Bookmarked_User_gne__c=\''+UserInfo.getUserId()+ '\') FROM AGS_Spend_Expense_Transaction_gne__c ';
        
                qr += getSpendWhereString(stUser.Mapped_Account_MDM_Id__c, 'Research', 0, dateFrom, dateTo, null);
                qr+= ' order by Event_Date_gne__c desc';
        system.debug('----qr'+qr);
        return Database.query(qr);
    }

    public static String getSpendWhereString(String mdmId, String spendType, Decimal transactionAmount, String dateFrom, String dateTo, String createdDateFrom) {
        
        transactionAmount = (transactionAmount == null) ? 0 : transactionAmount;
        
        List<String> whereClauses = new List<String>();
        if(!String.isBlank(mdmId)) {
            whereClauses.add(' (Primary_Recipient_MDM_ID_gne__c=\''+mdmId+'\' OR Secondary_Recipient_MDM_ID_gne__c=\''+mdmId+'\') '); // stUser.Mapped_Account_MDM_Id__c
        }
        
        if(Date.today().year() <= 2014)
            whereClauses.add('Event_Date_gne__c >= 2013-08-01');        
        else{
            whereClauses.add('Event_Date_gne__c >= '+ (Date.today().year()-1) +'-01-01');
        }
        whereClauses.add('Event_Date_gne__c <= '+ String.valueof(Date.today()));
        
        whereClauses.add('Report_Code_gne__c=\'XC_MON\'');
        whereClauses.add('Home_Payment_ID_gne__c!=null'); // new CMS 2014 condition
        whereClauses.add('LogicalDeleteFlag_gne__c=false');
        whereClauses.add('Allocated_Transaction_Amount_gne__c >= ' + transactionAmount);

        if('Research'.equals(spendType))
            whereClauses.add('(Research_Pymt_Typ_Cd_gne__c = \'CLINICAL\' OR Research_Pymt_Typ_Cd_gne__c = \'PRECLINICAL\')');
        else if('NonResearch'.equals(spendType))    
            whereClauses.add('Research_Pymt_Typ_Cd_gne__c != \'CLINICAL\' AND Research_Pymt_Typ_Cd_gne__c != \'PRECLINICAL\'');
        
        if(!String.isBlank(dateFrom))
        {
            whereClauses.add('Event_Date_gne__c>='+dateFrom);
        }
        if(!String.isBlank(dateTo)) {
            whereClauses.add('Event_Date_gne__c<='+dateTo);
        }
        if(!String.isBlank(createdDateFrom)) {
            whereClauses.add('CreatedDate>='+createdDateFrom);
        
        }
        String queryWhere = '';
        
        if (whereClauses.size()>0)
        {
            
            queryWhere += ' WHERE';
            for (String wh: whereClauses){
                queryWhere += ' ' + wh + ' AND';
            }
            queryWhere = queryWhere.substring(0,queryWhere.length()-4);  
        }   
        return queryWhere; 
    }

    public class SpendsData {
        public Spend[] spendList            { get; set; }        
        public String spendNo               { get; set; }
        public String totalAmount           { get; set; }
        public Integer noNewest             { get; set; }
        public Integer noBookmarked         { get; set; }
        public String hcpName               { get; set; }
        public String hcpSpecialty          { get; set; }
        public String hcpStreetAddress      { get; set; }
        public String hcpCity               { get; set; }
        public String hcpState              { get; set; }
        public String hcpZip                { get; set; }
        public String userEmailAddress      { get; set; }
    }
    
    public class Spend {   
        public String id                    { get; set; }
        public String studyTitle            { get; set; }       
        public String delayed               { get; set; }
        public String eventDate             { get; set; }
        public String amount                { get; set; }
        public String paymentMethod         { get; set; }
        public String paymentReason         { get; set; }
        public String brand                 { get; set; }
        public String status                { get; set; }
        public Date eventTime               { get; set; }
        public String recipient             { get; set; }
        public String genetechRep           { get; set; }
        public String eventLocation         { get; set; }
        public String principalInvestigator { get; set; }
        public String spendType             { get; set; }
        public String speakerName           { get; set; }
        public String cmsId                 { get; set; }
        public String cmsDisputeId          { get; set; }
        public String context               { get; set; }

        public String bookmarked;        
        public List<SpendAdditionalInfo> locationDet;
        public String[] historyList = new String[]{};
    }
    
    global class ResearchPaymentsData {
        public String[] brands = new String[]{};
        public String[] years = new String[]{};
        public String filterAmount = '';
        public String filterDateFrom = '';
        public String filterDateTo = '';
        public Decimal filterDaysRange = 0;
        public Integer noBookmarked = 0;
        public Integer noNewest = 0;
        public ResearchPayment[] spendList = new ResearchPayment[]{};
        public String spendNo = '';
        public String totalAmount = '';
        
        public String researchTypeDesc;
        public String nonresearchTypeDesc;
        public String bothTypesDesc;
        public String paymentDetailHeaderDesc;
    }    
    
    global class ResearchPayment {
        public String amount = '';
        public String delayed = '';
        public String bookmarked = '';
        public String brand = '';
        public String eventDate = '';
        public String[] historyList = new String[]{};
        public String id = '';
        public String status = '';
        public String studyTitle = '';
        public String cmsId = '';
        public String cmsDisputeId = '';
        public String context = '';
        public List<SpendAdditionalInfo> locationDet;
        public Recipient rcpt = new Recipient();    
        public PrincipalInvestigator pInvestigator = new PrincipalInvestigator();
        
    }
    
    global class NonResearchPaymentsData {
        public String[] paymentMethods = new String[]{};
        public String[] paymentReasons = new String[]{};
        public String[] brands = new String[]{};
        public String[] years = new String[]{};
        public String spendNo = '';
        public String totalAmount;
        public NonResearchPayment[] spendList = new NonResearchPayment[]{};
        public String filterDateFrom = '';
        public String filterDateTo = '';
        public String filterAmount = '';
        public Decimal filterDaysRange;
        public Integer noNewest = 0;
        public Integer noBookmarked = 0;
        public String hcpName = '';
        public String hcpSpecialty = '';
        public String hcpStreetAddress = '';
        public String hcpCity = '';
        public String hcpState = '';
        public String hcpZip = '';
        public String userEmailAddress = '';
    }
    
    global class NonResearchPayment {
        public String id;
        public String delayed;
        public String eventDate;
        public String amount;
        public String paymentMethod;
        public String paymentReason;
        public String brand = '';
        public String status;
        public String cmsId = '';
        public String cmsDisputeId = '';
        public String context = '';
        public List<SpendAdditionalInfo> locationDet;
        public String bookmarked;
        public String[] historyList = new String[]{};
        public Recipient rcpt = new Recipient();    
    }
    
    global class Recipient {
        public String name;
        public String taxId;
        public String npi;
        public String primaryAddress;
        public String city;
        public String state;
        public String zipCode;
    }
    
    global class PrincipalInvestigator {
        public String name;
        public String taxId;
        public String npi;
        public String primaryAddress;
        public String city;
        public String state;
        public String zipCode;
    }
    
    global class SpendAdditionalInfo {
        public String field;
        public String value;
        
        public SpendAdditionalInfo(String field, String val) {
            this.field = field;
            this.value = val;
        }
    }
}