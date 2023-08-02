global class AGS_ST_HCP_Notification_batch implements Database.Batchable<sObject> {
    global final String query;
    
    global AGS_ST_HCP_Notification_batch(String passedQuery) {
        query = passedQuery;
    }
    
    global AGS_ST_HCP_Notification_batch() {
        query = Label.AGS_ST_HCP_Notification_Batch_Query;
    }
    
    global void finish(Database.BatchableContext ctx) {
        // nothing to do in this matter
    }
    global Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext ctx, List<sObject> scope) {
        Boolean sendEmail = false;
        AGS_ST_User_gne__c stUser = ((List<AGS_ST_User_gne__c >)scope)[0];
        Date actualDate = Date.today();
        Date lastSentDate;
        String newSpends='';
        String disputedSpends='';
        try {
            if ('Weekly Digest'.equals(stUser.Alert_Frequency_gne__c) && actualDate.isSameDay(actualDate.toStartofWeek().addDays(1))) {
                System.debug('------------- Weekly Digest');
                sendEmail = true;
                lastSentDate=actualDate.addDays(-7);
            } else if ('Monthly Digest'.equals(stUser.Alert_Frequency_gne__c) && actualDate.isSameDay(actualDate.toStartOfMonth())) {
                System.debug('------------- Monthly Digest');
                sendEmail = true;
                lastSentDate=actualDate.addMonths(-1);
            } else if ('Quarterly Digest'.equals(stUser.Alert_Frequency_gne__c)) {
                if (actualDate.isSameDay(Date.newInstance(actualDate.Year(), 1, 1)) ||
                    actualDate.isSameDay(Date.newInstance(actualDate.Year(), 4, 1)) ||
                    actualDate.isSameDay(Date.newInstance(actualDate.Year(), 7, 1)) ||
                    actualDate.isSameDay(Date.newInstance(actualDate.Year(), 10, 1))
                ) {
                    System.debug('------------- Quarterly Digest');
                    sendEmail = true;
                    lastSentDate=actualDate.addMonths(-3);
                }
            } else if ('Annual Digest'.equals(stUser.Alert_Frequency_gne__c) && actualDate.isSameDay(Date.newInstance(actualDate.Year(), 1, 31))) {
                System.debug('------------- Annual Digest');
                sendEmail = true;
                lastSentDate=actualDate.addYears(-1);
            }
            if (sendEmail) {
                if (stUser.Alert_New_Payments_gne__c) {
                    newSpends = getNewPayments(stUser.Alert_New_Payments_Amount_gne__c, lastSentDate, stUser.Mapped_Account_MDM_Id__c);
                    System.debug('------------- new spends -----' + newSpends);
                }
                if (stUser.Alert_Dispute_Updates_gne__c) {
                    disputedSpends = getDisputedPayments(lastSentDate, stUser.Mapped_Account_MDM_Id__c);
                    System.debug('------------- disputedSpends  -----' + disputedSpends);
                }
            }
            if (sendEmail && (newSpends != '' || disputedSpends != '')) {
                sendNotificationEmailWithSpends(stUser,newSpends,disputedSpends);
            }
        } catch(Exception e) {
            String content = 'type: ' + e.getTypeName() + ' line:' + e.getLineNumber() + ' stack: ' + e.getStackTraceString();
            AGS_ST_Utils.logStErrorByUserIdNoFuture(stUser.id, 'Notification Batch', 'AGS_ST_HCP_Notification_batch', content, e.getMessage(), 'execute','Code');
        }
    }
    
    private String getNewPayments(Decimal targetAmount, Date lastSent, String mdmId) {
        if (targetAmount == null) {
            targetAmount=0;
        }
        System.debug('---------- getNewPayments targetAmount lastSent mdmId ' + targetAmount + ' ' + lastSent + ' ' + mdmId);
        String body='';
        List<AGS_Spend_Expense_Transaction_gne__c> listToSend =  getSpends(mdmId, targetAmount, lastSent);
        System.debug('---------- getNewPayments size ' + listToSend.size());
        Set<String> spendsToSkip = new Set<String>();
        for (AGS_Spend_Expense_Transaction_gne__c spend:listToSend) {
            if (spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                if (AGS_ST_SpendSearch_Utils_gne.checkOptOut(spend)) {
                        spendsToSkip.add(spend.Id);
                        continue;
                }
            }
        }
        List<AGS_Spend_Expense_Transaction_gne__c> researchPayments = new List<AGS_Spend_Expense_Transaction_gne__c>();
        List<AGS_Spend_Expense_Transaction_gne__c> nonResearchPayments = new List<AGS_Spend_Expense_Transaction_gne__c>();
        for (AGS_Spend_Expense_Transaction_gne__c exp : listToSend) {
            if (spendsToSkip.contains(exp.Id)) {
                continue;
            }
            if (AGS_ST_SpendSearch_Utils_gne.isResearchSpend(exp)) {
                researchPayments.add(exp);
            } else {
                nonResearchPayments.add(exp);
            }
        }
        return  generateResearchAndNonResearchTables(researchPayments, nonResearchPayments);
    }
    
    private String getDisputedPayments(Date lastSent, String mdmId) {
        List<String> userSpendsWithDisputesIds = new List<String>();
        List<AGS_Spend_Expense_Transaction_gne__c> listToSend =  getSpends(mdmId, 0, null);
        Map<Id, AGS_Spend_Expense_Transaction_gne__c> userSpends = new Map<Id, AGS_Spend_Expense_Transaction_gne__c>();
        System.debug('---------- getDisputedPayments size ' + listToSend.size());
        Set<String> spendsToSkip = new Set<String>();
        for (AGS_Spend_Expense_Transaction_gne__c spend:listToSend) {
            if (spend.AGS_ST_DisputeManagement_gne__r.size()>0) {
                // fist check Opt Out flag on DispueManagement, if true skip this spend
                if (AGS_ST_SpendSearch_Utils_gne.checkOptOut(spend)) {
                        spendsToSkip.add(spend.Id);
                        continue;
                } else {
                    userSpends.put(spend.Id, spend);
                    //userSpendsWithDisputesIds.add(spend.Id);
                }
            } else { // skip if there is no dispute
                spendsToSkip.add(spend.Id);
                        continue;
            }
        }
        List<AGS_Spend_Expense_Transaction_gne__History> spendsHistory = [SELECT CreatedDate,Field,ParentId,NewValue,OldValue,Parent.Spend_User_gne__c FROM AGS_Spend_Expense_Transaction_gne__History where createddate > :lastSent AND ParentId in:userSpends.keySet() order by createddate];// Parent.Spend_User_gne__c =: recipientId order by createddate];
        Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>> spendHistoryMap = new Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>>();
        for (AGS_Spend_Expense_Transaction_gne__History spendHistory:spendsHistory) {
            if (!spendHistoryMap.containsKey(spendHistory.ParentId)) {
                spendHistoryMap.put(spendHistory.ParentId, new List<AGS_Spend_Expense_Transaction_gne__History>());
            }
            spendHistoryMap.get(spendHistory.ParentId).add(spendHistory);
        }
        List<AGS_Spend_Expense_Transaction_gne__c> researchPayments = new List<AGS_Spend_Expense_Transaction_gne__c>();
        List<AGS_Spend_Expense_Transaction_gne__c> nonResearchPayments = new List<AGS_Spend_Expense_Transaction_gne__c>();
        for (Id spendId:spendHistoryMap.keySet()) {
            Boolean updatedSpend = AGS_ST_SpendSearch_Utils_gne.isNewUpdatedSpendNew(userSpends.get(spendId), spendHistoryMap.get(spendId));
            if (updatedSpend) {
                if (AGS_ST_SpendSearch_Utils_gne.isResearchSpend(userSpends.get(spendId))) {
                    researchPayments.add(userSpends.get(spendId));
                } else {
                    nonResearchPayments.add(userSpends.get(spendId));
                }
            }
        }
        return generateResearchAndNonResearchTables(researchPayments, nonResearchPayments);
    }
    
    private String generateResearchAndNonResearchTables(List<AGS_Spend_Expense_Transaction_gne__c> researchPayments, List<AGS_Spend_Expense_Transaction_gne__c> nonResearchPayments) {
        String body = '<p style="font-family: Arial, sans-serif; font-size: 14px; font-weight: bold; margin: 0 0 1em 0; color:#195695;">Non-Research Payments:</p>';
        String endrow = '</tbody></table>';
        if (nonResearchPayments!=null && nonResearchPayments.size() > 0) {
            body += '<table border="0" cellspacing="0" style="border: 1px solid #EBEEEE;"><tbody><tr><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Date</th><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Amount</th><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Form</th><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Nature</th><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Brand</th><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Status</th></tr>';
            for (AGS_Spend_Expense_Transaction_gne__c nonRes : nonResearchPayments) {
                body += generateNonResearchRow(nonRes);
            }
            body += endrow;
        } else {
            body += '<p style="font-family: Arial, sans-serif; font-size: 14px; margin: 1em 0; color:#111111;">No payments to report for this period.</p>';
        }
        body+='<p style="font-family: Arial, sans-serif; font-size: 14px; font-weight: bold; margin: 1em 0; color:#195695;">Research Payments:</p>';
        if (researchPayments!=null && researchPayments.size() > 0) {
            body += '<table border="0" cellspacing="0" style="border: 1px solid #EBEEEE;"><tbody><tr><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Date</th><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Amount</th><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Study Title</th><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Brand</th><th style="font-family: Arial, sans-serif; font-size: 12px; font-weight: bold; padding: 0.5em 1em; color:#111111; border: 1px solid #ffffff; text-align: left; background-color: #EBEEEE;">Status</th></tr>';
            for (AGS_Spend_Expense_Transaction_gne__c res : researchPayments) {
                body += generateResearchRow(res);
            }
            body += endrow;
        } else {
            body += '<p style="font-family: Arial, sans-serif; font-size: 14px; margin: 1em 0; color:#111111;">No payments to report for this period.</p>';
        }
        return body;
    }
    
    private static String createSingleRow(String data) {
        List<String> tempList = data.split(';');
        String toReturn = '<tr>';
        for (Integer i=0;i<tempList.size();i++) {
            toReturn+='<td style="font-family: Arial, sans-serif; font-size: 12px; font-weight: normal; padding: 0.5em 1em; color:#565656; border: 1px solid #EBEEEE;">'+tempList[i]+'</td>';
        }
        toReturn+='</tr>';
        return toReturn;
    }
    
    private static List<AGS_Spend_Expense_Transaction_gne__c> getSpends(String mdmId, Decimal transactionAmount, Date dateFrom) {
        String qr = 'SELECT Dispute_Number_gne__c,Research_Pymt_Typ_Cd_gne__c,Event_Type_gne__c,Source_System_Code_gne__c,Primary_Recipient_Name_gne__c,';
        qr += 'Study_Name_gne__c,Brands_gne__c,LogicalDeleteFlag_gne__c,LastModifiedDate,Form_Of_Payment_gne__c,Nature_Of_Payment_gne__c,id,Name,';
        qr += 'Event_Date_gne__c, Allocated_Transaction_Amount_gne__c,';
        qr += '(select id,External_Status_gne__c,Internal_Status_gne__c,Amount_gne__c,Form_Of_Payment_gne__c,Drug_Name_gne__c,Nature_Of_Payment_gne__c,Opt_Out_gne__c from AGS_ST_DisputeManagement_gne__r where isPrivate__c=false order by CreatedDate asc) FROM AGS_Spend_Expense_Transaction_gne__c ';
        System.debug('------------ getSpends ' + mdmId + ' ' + transactionAmount + ' ' + dateFrom);
        String dateFromString = (dateFrom != null ? ((DateTime)dateFrom).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''): null);
        qr += AGS_ST_SpendSearch_Utils_gne.getSpendWhereString(mdmId, null, transactionAmount, null, null, dateFromString); //'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'' //.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        qr+= ' order by Event_Date_gne__c desc';
        system.debug('----qr'+qr);
        return Database.query(qr);
    }

    private static String generateNonResearchRow(AGS_Spend_Expense_Transaction_gne__c spend) {
        //     Date     Amount     Form     Nature     Brand     Status
        String row = '';
        if (AGS_ST_SpendSearch_Utils_gne.checkIfTakeFromDispute(spend)) {
            AGS_ST_DisputeManagement_gne__c dispute = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1];
            row =  String.valueOf(spend.Event_Date_gne__c)+';'+String.valueOf(dispute.Amount_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.cleanString(dispute.Form_Of_Payment_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.cleanString(dispute.Nature_Of_Payment_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.prepareBrands(dispute.Drug_Name_gne__c);
        } else {
            row =  String.valueOf(spend.Event_Date_gne__c)+';'+String.valueOf(spend.Allocated_Transaction_Amount_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.cleanString(spend.Form_Of_Payment_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.cleanString(spend.Nature_Of_Payment_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.prepareBrands(spend.Brands_gne__c);
        }
        if (spend.AGS_ST_DisputeManagement_gne__r.size() > 0) {
            row += ';' + spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].External_Status_gne__c;
        } else {
            row += ';Undisputed';
        }
        return createSingleRow(row);
    }
    
    private String generateResearchRow(AGS_Spend_Expense_Transaction_gne__c spend) {
        //     Date     Amount     Study Name     Brand     Status
        String row = '';
        if (AGS_ST_SpendSearch_Utils_gne.checkIfTakeFromDispute(spend)) {
            AGS_ST_DisputeManagement_gne__c dispute = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1];
            row =  String.valueOf(spend.Event_Date_gne__c)+';'+String.valueOf(dispute.Amount_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.cleanString(spend.Study_Name_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.prepareBrands(dispute.Drug_Name_gne__c);
        } else {
            row =  String.valueOf(spend.Event_Date_gne__c)+';'+String.valueOf(spend.Allocated_Transaction_Amount_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.cleanString(spend.Study_Name_gne__c)+';'+AGS_ST_SpendSearch_Utils_gne.prepareBrands(spend.Brands_gne__c);
        }
        if (spend.AGS_ST_DisputeManagement_gne__r.size() > 0) {
            row += ';' + spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].External_Status_gne__c;
        } else {
             row += ';Undisputed';
        }
        return createSingleRow(row);
    }
    
    private void sendNotificationEmailWithSpends(AGS_ST_User_gne__c stUser, String newSpends, String disputedSpends) {
        String portalAddress = AGS_ST_Utils.getDefaultCustomSettings().Site_Domain_gne__c + '/SunshineTrackLogin/AGS_ST_Home_gne';
        Messaging.SingleEmailMessage e = new Messaging.SingleEmailMessage();
        String b = '<div><table border="0" cellpadding="0" cellspacing="0" style="font-family: Arial, sans-serif; font-size: 14px; margin: 0 0 2em 0; width: 100%;"><tbody><tr><td style="width: 167px; height: 50px; background-color: #FAFAFA; padding-left: 10px;"><img src="http://www.gene.com/assets/frontend/img/logo.png" width="150" height="39" alt="Genentech - A Member of the Roche Group"></td><td style="font-family: Arial, sans-serif; font-size: 17px; line-height: 1em; border-left: 1px solid #7E8083; padding-left: 1em; color:#B2BB21; background-color: #FAFAFA;">Sunshine<br>Track</td></tr></tbody></table><p style="font-family: Arial, sans-serif; font-size: 14px; margin: 1em 0; color:#111111;">Dear Dr. '+stUser.First_name__c+' '+stUser.Last_name__c+',<br>Per your Sunshine Track notification settings, we are sending your activity report.</p>';
        if (newSpends!='') {
            b+='<p style="font-family: Arial, sans-serif; font-size: 15px; font-weight: normal; margin: 2em 0 0 0; color:#B2BB21; text-transform: uppercase;">NEW SPEND</p>' + newSpends;
        }
        if (disputedSpends!='') {
            b+= '<p style="font-family: Arial, sans-serif; font-size: 15px; font-weight: normal; margin: 2em 0 0 0; color:#B2BB21; text-transform: uppercase;">DISPUTED SPEND</p>' + disputedSpends;
        }
        String sunshineAddress = AGS_ST_Utils.getSunshineOrgWideAddress();
        b+='<p style="font-family: Arial, sans-serif; font-size: 14px; margin: 1em 0; color:#111111;">To view a complete list of your current reportable payments, please visit <a href="'+portalAddress+'">Sunshine Track</a>.</p><p style="font-family: Arial, sans-serif; font-size: 14px; margin: 1em 0; color:#111111;">If you have any questions, please contact the Genentech Sunshine Help Desk at <a href="mailto:SunshineQuestions-d@gene.com">SunshineQuestions-d@gene.com</a> or (877) 313-5778 between 8am and 5pm Pacific Time, Monday through Friday.</p><p style="font-family: Arial, sans-serif; font-size: 14px; margin: 1em 0; color:#111111;">Thank you,<br>The Genentech Sunshine Help Desk Team<br><br><span style="font-family: Arial, sans-serif; font-size: 12px; margin: 1em 0; color:#565656;">To manage your activity report notification settings, please log in to <a href="'+portalAddress+'">Sunshine Track</a>, click “View Account & Settings”, and then click on “Notifications”.</span></p></div>';
        e.setSubject('Sunshine Track ' + stUser.Alert_Frequency_gne__c);
        e.setHtmlBody(b);
        String orgWideAddressId = AGS_ST_Utils.getSunshineOrgWideAddressId();
        if (!String.isBlank(orgWideAddressId)) {
            e.setOrgWideEmailAddressId(orgWideAddressId);
        }
        e.setToAddresses(new List<String>{stUser.Email_address__c});
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{e});
    }
    
    /*private void sendNotificationEmailWithoutSpends(AGS_ST_User_gne__c stUser) {
        Messaging.SingleEmailMessage e = new Messaging.SingleEmailMessage();
        String body = '<html><body><br>Dear Dr. '+stUser.First_name__c+' '+stUser.Last_name__c+',</br>'+
            '<br>As per your request in the Sunshine Track settings, we are sending your activity report.</br>'+
            '<br>No payments to report for this period</br>'+
            '<br>Notifications include any activity alerts that were requested. This notification includes all payments that we have received and processed to current date.</br>'+
            '<br>Please reach out to us at < insert CCO d_list)>, if you have any questions.</br>'+
            '<br>Thanks</br>'+
            '<br>Customer Services Team</br>'+
            '<br>Sunshine Track</br>'+
            '</body></html>';
        e.setHtmlBody(body);
        e.setSubject('Sunshine Track ' + stUser.Alert_Frequency_gne__c);
        e.setToAddresses(new List<String>{stUser.Email_address__c});
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{e});
    }*/
    
}