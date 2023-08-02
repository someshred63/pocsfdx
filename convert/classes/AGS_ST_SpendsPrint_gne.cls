public with sharing class AGS_ST_SpendsPrint_gne {
    public List<String> spendIds {get; set;}
    public ViewData spendData {get; set;}
    public List<Integer> index {get; set;}    
    public List<Integer> tmp {get; set;}    
    
    public PageReference doIt() {   
        spendData = getSpends(spendIds);  
        return null;
    }
    
    public AGS_ST_SpendsPrint_gne() {
        index = new List<Integer>();
        index.add(0);
        index.add(1);
        
        tmp = new List<Integer>();
        tmp.add(1);
        
        String spendIdsParam = ApexPages.currentPage().getParameters().get('spendIds');
        if(!String.isBlank(spendIdsParam)) {
            spendIds = new List<String>(spendIdsParam.split(';'));
        } else {
            spendIds = new List<String>();
        }
        System.debug('---------- SPENDIDS ' + spendIds);
        if(spendIds!=null && !spendIds.isEmpty()) {
            
        }
        doIt();
    }
    public static ViewData getSpends(List<String> spendsId)
    {
        //try
       // {
            
            Set<String> paymentMethods = new Set<String>();
            Set<String> paymentReasons = new Set<String>();
            Set<String> brands = new Set<String>();
            Integer spendNo = 0;
            Decimal totalAmount = 0.0;
            
            AGS_Spend_Expense_Transaction_gne__c[] spends = getTransactions(spendsId);
            spendNo = spends.size();
            Map<Id,Id> disputesIds = new Map<Id,Id>();
            //Set<ID> spendsId = new Set<ID>();
            for(AGS_Spend_Expense_Transaction_gne__c spend:spends)
            {
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0)
                {
                    for(Integer i=0;i<spend.AGS_ST_DisputeManagement_gne__r.size();i++)
                        disputesIds.put(spend.AGS_ST_DisputeManagement_gne__r[i].Id, spend.Id); 
                }
                //spendsId.add(spend.id);
            }
            
            List<AGS_ST_DisputeManagement_gne__History> disputesHistory = [SELECT CreatedDate,Field,NewValue,OldValue,ParentId,Parent.Name FROM AGS_ST_DisputeManagement_gne__History where ParentId in :disputesIds.keySet() order by createddate];
                
            Map<Id,List<String>> disputeHistoryMap = new Map<Id,List<String>>();
            for(AGS_ST_DisputeManagement_gne__History disputeHistory:disputesHistory)
            {
                if(disputeHistory.Field == 'External_Status_gne__c' || disputeHistory.Field == 'created')
                {
                    String historyDescription = getHistoryDescription(disputeHistory);
                    if(disputeHistoryMap.containsKey(disputeHistory.ParentId))
                    {
                        if(historyDescription != null)
                            disputeHistoryMap.get(disputeHistory.ParentId).add(historyDescription);
                    }
                    else
                    {
                        if(historyDescription != null)
                        {
                            List<String> tmpDisputeHistList = new List<String>();
                            tmpDisputeHistList.add(String.valueof(historyDescription));
                            disputeHistoryMap.put(disputeHistory.ParentId,tmpDisputeHistList);
                        }
                    }
                }
            }
            AGS_ST_User_gne__c stUser = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()); 
            AGS_ST_User_gne__c stUserLocal = stUser;
            ViewData vd = new ViewData();
            //if(isFirstCall)
            //{
               /* vd.hcpName = stUserLocal.First_name__c + stUserLocal.Last_name__c;
                vd.hcpSpecialty = stUserLocal.Mapped_Account__r.Specialties_gne__c;
                Address_vod__c addr = AGS_ST_DbUtils.getGoldAddressByAccountId(stUserLocal.Mapped_Account__c);
                vd.hcpStreetAddress = addr.Name;
                vd.hcpCity = addr.City_vod__c;
                vd.hcpState = addr.State_vod__c;
                vd.hcpZip = addr.Zip_vod__c;
                if(stUserLocal.Email_address__c != null && stUserLocal.Email_address__c != '')
                    vd.userEmailAddress = stUserLocal.Email_address__c;
                else 
                    vd.userEmailAddress = stUserLocal.SFDC_User__r.username;
                if(stUserLocal.Filter_date_from_gne__c != null && stUserLocal.Filter_date_to_gne__c != null && stUserLocal.Filter_date_from_gne__c != '' && stUserLocal.Filter_date_to_gne__c != '')
                {
                    //vd.filterDateFrom = stUserLocal.Filter_date_from_gne__c;
                    //vd.filterDateTo = stUserLocal.Filter_date_to_gne__c ;
                }
                if(stUserLocal.Filter_date_range_gne__c  != null && stUserLocal.Filter_date_range_gne__c != 0)
                {
                    vd.filterDaysRange = stUserLocal.Filter_date_range_gne__c;
                }
                else
                {
                    vd.filterDaysRange = 0;
                }
                if(stUserLocal.Filter_amount__c != null && stUserLocal.Filter_amount__c != '')
                {
                    vd.filterAmount = stUserLocal.Filter_amount__c;
                }
            /*}
            else
            {
                vd.filterDateFrom = dateFrom;
                vd.filterDateTo = dateTo;
                vd.filterAmount = amountFrom;
                vd.filterDaysRange = dateRangeDays;
                if(isDateFilterApply || isAmountFilterApply)
                    updateStUserWithFilter(isDateFilterApply,isAmountFilterApply,dateFrom,dateTo,dateRangeDays,amountFrom);
            }*/
            //DateTime userLastLogin = stUserLocal.SFDC_User__r.LastLoginDate;
            
            Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>> spendHistoryMap = new Map<Id,List<AGS_Spend_Expense_Transaction_gne__History>>();
            List<AGS_Spend_Expense_Transaction_gne__History> spendsHistory = [SELECT CreatedDate,Field,ParentId FROM AGS_Spend_Expense_Transaction_gne__History where ParentId in :spendsId /*and createddate > :userLastLogin*/];
            for(AGS_Spend_Expense_Transaction_gne__History spendHistory:spendsHistory)
            {
                if(spendHistoryMap.containsKey(spendHistory.ParentId))
                {
                    spendHistoryMap.get(spendHistory.ParentId).add(spendHistory);
                }
                else
                {
                    List<AGS_Spend_Expense_Transaction_gne__History> tmpSpendHistory = new List<AGS_Spend_Expense_Transaction_gne__History>();
                    tmpSpendHistory.add(spendHistory);
                    spendHistoryMap.put(spendHistory.ParentId,tmpSpendHistory);
                }
            }
            system.debug('----spendHistoryMap'+spendHistoryMap);
            List<SpendListWrap> spendsListForView = new List<SpendListWrap>();
            Integer idx = 1;
            for(AGS_Spend_Expense_Transaction_gne__c spend:spends)
            {
                system.debug('---spend in the loop'+spend);
                SpendListWrap slw = new SpendListWrap();
                slw.idx = String.valueof(idx);
                idx++;
                slw.id = spend.id;
                slw.eventDate = String.valueOf(spend.Event_Date_gne__c);
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0)
                {
                    slw.status = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].External_Status_gne__c;                   
                }
                else
                {
                    slw.status = 'Undisputed';
                }
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0 && spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1].Internal_Status_gne__c == 'Corrected Pending SSR')
                {
                    AGS_ST_DisputeManagement_gne__c dispute = spend.AGS_ST_DisputeManagement_gne__r[spend.AGS_ST_DisputeManagement_gne__r.size() - 1];
                    slw.amount = String.valueOf(dispute.Amount_gne__c);
                    totalAmount += dispute.Amount_gne__c;
                    
                    slw.paymentMethod = dispute.Form_Of_Payment_gne__c;
                    
                    slw.paymentReason = dispute.Nature_Of_Payment_gne__c;
                    
                    slw.brand = dispute.Drug_Name_gne__c;
                    
                    paymentMethods.add(dispute.Form_Of_Payment_gne__c);
                    paymentReasons.add(dispute.Nature_Of_Payment_gne__c);
                    if(slw.brand != null)
                        brands.addAll(slw.brand.split(',', 0));
                }
                else
                {
                    paymentMethods.add(spend.Form_Of_Payment_gne__c);
                    paymentReasons.add(spend.Nature_Of_Payment_gne__c);
                    slw.amount = String.valueOf(spend.Allocated_Transaction_Amount_gne__c);
                    totalAmount += spend.Allocated_Transaction_Amount_gne__c;
                                        slw.paymentMethod = spend.Form_Of_Payment_gne__c;
                    
                    slw.paymentReason = spend.Nature_Of_Payment_gne__c;
                    
                    system.debug('spend.AGS_expense_products_intercations1__r'+spend.AGS_expense_products_intercations1__r);
                    if(spend.AGS_expense_products_intercations1__r.size()>0)
                    {
                        for(Integer i=0;i<spend.AGS_expense_products_intercations1__r.size();i++)
                        {
                            slw.brand += spend.AGS_expense_products_intercations1__r[i].AGS_Brand_gne__r.Brand_Name__c + ',';
                            brands.add(spend.AGS_expense_products_intercations1__r[i].AGS_Brand_gne__r.Brand_Name__c);
                        }
                        system.debug('---slw.brand'+slw.brand);
                        
                    }
                    else
                    {
                        slw.brand = '';
                    }
                    slw.brand = removeLastComma(slw.brand);
                }
                if(spend.Sch_Category_gne__c != null)
                {
                    slw.locationDet = getSpendDetails(spend);
                }
                else
                {
                    slw.locationDet = new List<String>();
                }
               
                if(spend.AGS_ST_Expense_Bookmarks__r.size() > 0)
                {
                    slw.bookmarked = 'true';
                    vd.noBookmarked++;
                }
                else
                {
                    slw.bookmarked = 'false';
                }
                //if(/*bookmarkedSpends && */slw.bookmarked == 'false')
                //    continue;
                system.debug('------'+spend.AGS_ST_Expense_Bookmarks__r.size());
                slw.historyList = new String[]{};
                if(spend.AGS_ST_DisputeManagement_gne__r.size()>0)
                {
                    for(integer i=0;i<spend.AGS_ST_DisputeManagement_gne__r.size();i++)
                    {
                        slw.historyList.addAll(disputeHistoryMap.get(spend.AGS_ST_DisputeManagement_gne__r[i].id));
                    }
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
        /*}
        catch(Exception e)
        {
            System.debug(e);
            //AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'getSpends');
            return null;
        }*/
    }
    
    public static AGS_Spend_Expense_Transaction_gne__c[] getTransactions(List<String> spendIds)
    {
        AGS_ST_User_gne__c stUser = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()); 
            
        AGS_Spend_Expense_Transaction_gne__c[] spends;
        String qr = 'SELECT LogicalDeleteFlag_gne__c,LastModifiedDate,Form_Of_Payment_gne__c,Nature_Of_Payment_gne__c,id,Name,';
        qr += 'Event_Date_gne__c, Allocated_Transaction_Amount_gne__c,Event_Actual_Attendee_Count_gne__c,';
        qr += 'Sch_Category_gne__c,Event_City_gne__c,Event_State_gne__c,Speaker_Name_gne__c,Country_gne__c,Street_Address_gne__c,Spend_User_gne__r.Name,';
        qr += '(select id,External_Status_gne__c,Internal_Status_gne__c,Amount_gne__c,Form_Of_Payment_gne__c,Drug_Name_gne__c,Nature_Of_Payment_gne__c from AGS_ST_DisputeManagement_gne__r where isPrivate__c=false),';
        qr += '(select AGS_Brand_gne__r.Brand_Name__c from AGS_expense_products_intercations1__r),';
        qr += '(select id from AGS_ST_Expense_Bookmarks__r where Bookmarked_User_gne__c=\''+UserInfo.getUserId()+ '\') FROM AGS_Spend_Expense_Transaction_gne__c ';
        List<String> whereClauses = new List<String>();
        //whereClauses.add('MDM_ID_gne__c=\''+stUser.Mapped_Account_MDM_Id__c+'\'');
        //whereClauses.add('Report_Code_gne__c=\'XC_MON\'');
        //whereClauses.add('LogicalDeleteFlag_gne__c=false');
        //whereClauses.add('Allocated_Transaction_Amount_gne__c >= 0');
        /*if(dateFrom != '' && dateTo != '' )
        {
            whereClauses.add('(Event_Date_gne__c >='+dateFrom+' and Event_Date_gne__c<='+dateTo+')');
        }
        if (whereClauses.size()>0)
        {
            String queryWhere = '';
            queryWhere += ' WHERE';
            for (String wh: whereClauses){
                queryWhere += ' ' + wh + ' AND';
            }
            queryWhere = queryWhere.substring(0,queryWhere.length()-4);  
            qr+= queryWhere;
        }*/
        if(spendIds != null && !spendIds.isEmpty())
            qr+= ' WHERE Id in (';
        
        for(ID spendId : spendIds) {
            qr+= '\''+spendId+'\',';
        }
        qr = qr.substring(0,qr.length()-1);
        if(spendIds != null && !spendIds.isEmpty())
            qr+= ') ';
        
        
        qr+= ' order by Event_Date_gne__c desc';
        system.debug('----qr'+qr);
        return Database.query(qr);
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
    
    public static List<String> getSpendDetails(AGS_Spend_Expense_Transaction_gne__c orgSpend)
    {
        List<String> loc = new List<String>();
        if(orgSpend.SCh_Category_gne__c == 'APRIMO')
        {
            loc.add('Event Type: '+orgSpend.Event_Type_gne__c);
            loc.add('Speaker Name: '+orgSpend.Speaker_Name_gne__c);
            loc.add('Event Location: '+orgSpend.Street_Address_gne__c+' '+orgSpend.Event_City_gne__c+','+orgSpend.Event_State_gne__c);
            loc.add('Genentech Representative: '+orgSpend.Spend_User_gne__r.Name);
        }
        if(orgSpend.SCh_Category_gne__c == 'iHCP')
        {
            loc.add('Event Type: '+orgSpend.Event_Type_gne__c);
            loc.add('Speaker Name: '+orgSpend.Speaker_Name_gne__c);
            loc.add('Event Location: '+orgSpend.Street_Address_gne__c+' '+orgSpend.Event_City_gne__c+','+orgSpend.Event_State_gne__c+' '+orgSpend.Country_gne__c);
            loc.add('Genentech Representative: '+orgSpend.Spend_User_gne__r.Name);
        }
        if(orgSpend.SCh_Category_gne__c == 'CRO')
        {
            loc.add('Event Location: '+orgSpend.Street_Address_gne__c+' '+orgSpend.Event_City_gne__c+','+orgSpend.Event_State_gne__c);
            loc.add('Genentech Representative: '+orgSpend.Spend_User_gne__r.Name);
        }
        if(orgSpend.SCh_Category_gne__c.contains('SAP BW') || orgSpend.SCh_Category_gne__c.contains('SAPBW') || orgSpend.SCh_Category_gne__c == 'gFRS')
        {
            loc.add('Event Location: '+orgSpend.Event_City_gne__c+','+orgSpend.Event_State_gne__c);
            loc.add('Genentech Representative: '+orgSpend.Spend_User_gne__r.Name);
        }
        if(orgSpend.SCh_Category_gne__c == 'SFDC' || orgSpend.SCh_Category_gne__c == 'HCP Meal')
        {
            loc.add('Event Location: '+orgSpend.Street_Address_gne__c+' '+orgSpend.Event_City_gne__c+','+orgSpend.Event_State_gne__c);
            loc.add('Genentech Representative: '+orgSpend.Spend_User_gne__r.Name);
        }
        
        return loc;
    }
    
    public static String removeLastComma(String stringToRemove)
    {
        return stringToRemove.substringBeforeLast(',');
    }
    
    public class ViewData
    {
        public String[] paymentMethods = new String[]{};
        public String[] paymentReasons = new String[]{};
        public String[] brands = new String[]{};
        public String spendNo;
        public String totalAmount;
        public SpendListWrap[] spendList {get; set;}
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
    
    public class SpendListWrap
    {
        public String idx {get; set;}
        public String id;
        public String eventDate {get; set;}
        public String amount {get; set;}
        public String paymentMethod {get; set;}
        public String paymentReason {get; set;}
        public String brand {get; set;}
        public String status {get; set;}
        public String[] locationDet {get; set;}
        public String bookmarked;
        public String[] historyList {get; set;}
    }
}