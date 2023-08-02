/*
*X33_of_Fiscal_Revenue
*/
public class gFRS_CoPay_Operational_Budget {
    
    public static Final Integer JAN                 = 1;
    public static Final Integer FEB                 = 2;
    public static Final Integer MAR                 = 3;
    public static Final Integer APR                 = 4;
    public static Final Integer MAY                 = 5;
    public static Final Integer JUN                 = 6;
    public static Final Integer JUL                 = 7;
    public static Final Integer AUG                 = 8;
    public static Final Integer SEP                 = 9;
    public static Final Integer OCT                 = 10;
    public static Final Integer NOV                 = 11;
    public static Final Integer DEC                 = 12;
    public static Final String quarter_1            = 'Q1';
    public static Final String quarter_2            = 'Q2';
    public static Final String quarter_3            = 'Q3';
    public static final String quarter_4            = 'Q4';
    public static Final String fiscalYear_JAN_DEC   = 'January-December';
    public static Final String fiscalYear_JUL_JUN   = 'July-June';
    public static Date cutOffDate                   = GFRS_OrgSettings__c.getOrgDefaults().Copay_33_New_Logic_Cutoff_Date__c;
    

    /*
    *
    */
    public static void setTotalDonation(GFRS_CoPay_Funding_Request__c fundingRequest){
        
        GFRS_Organization__c org = [SELECT id, Fiscal_Year_Ending__c, 
                                    (select Total_Approved_Amt__c, Date_for_33_logic__c, Date_Submitted__c from gFRS_Copay_Funding_Request__r where id != : fundingRequest.id),
                                    (select Approved_Amount__c, Date_for_33_logic__c, sub_status__c,Date_Submitted__c from Grant_Requests__r where SYS_Request_Approved__c = 'Yes' and Funding_Type__c in ('Health Care-Related Charitable','Fellowships','Scientific Project Support') and Foundation_Classified__c = 'FALSE')
                                    from GFRS_Organization__c where id = : fundingRequest.Organization__c];
        
        Decimal YTDapprovedDonations = 0.0;
        Date yearStartDate = determineYearStartDate(fundingRequest.Date_Submitted__c,fundingRequest.Date_for_33_logic__c,org.Fiscal_Year_Ending__c);
        Date yearEndDate = determineYearEndDate(yearStartDate);
        //system.assertEquals(yearStartDate, yearEndDate);

        if(yearStartDate!=null && yearEndDate!=null){
            
            for(gFRS_copay_Funding_Request__c orgsApprovedCopayReqs : org.gFRS_Copay_Funding_Request__r){
                if(orgsApprovedCopayReqs.Total_Approved_Amt__c != null 
                        && considerRequest(yearStartDate, yearEndDate, orgsApprovedCopayReqs.Date_Submitted__c, orgsApprovedCopayReqs.Date_for_33_logic__c)){
                    YTDapprovedDonations += orgsApprovedCopayReqs.Total_Approved_Amt__c;
                }
            }
            
            for(gFRS_Funding_Request__c orgsApprovedNonCopayReqs : org.Grant_Requests__r){
                if(orgsApprovedNonCopayReqs.Approved_Amount__c != null 
                        && considerRequest(yearStartDate, yearEndDate, orgsApprovedNonCopayReqs.Date_Submitted__c, orgsApprovedNonCopayReqs.Date_for_33_logic__c)){
                    YTDapprovedDonations += orgsApprovedNonCopayReqs.Approved_Amount__c;
                }
            }
            
            if(fundingRequest.Total_Approved_Amt__c > 0.0){
                YTDapprovedDonations += fundingRequest.Total_Approved_Amt__c;
            }
        
        }
        
        fundingRequest.YTD_Total_Approved_Donations__c = YTDapprovedDonations;
    }
    
    
    /*
    *
    */
    public static void calculateExhaustedOperationalBudget(GFRS_CoPay_Funding_Request__c fundingRequest){
        
        Decimal revenue = 0.0;
        String orgQuarter  = fundingRequest.Org_Quarter__c;
   
        GFRS_Organization__c org = [SELECT id, Fiscal_Year_Ending__c, Actual_Annual_Revenue_for_Prior_Fiscal_Y__c,
                                    Actual_YeartoDate_Annual_Revenue_for_Fis__c, Projected_Annual_Revenue_for_Fiscal_Year__c
                                    from GFRS_Organization__c where id = : fundingRequest.Organization__c];
                                    
        if(fundingRequest.YTD_Total_Approved_Donations__c == null){
            fundingRequest.YTD_Total_Approved_Donations__c = 0.0;
        }
        
        defaultNullRevenuesToZero(org);

        if(org.Fiscal_Year_Ending__c == fiscalYear_JAN_DEC || org.Fiscal_Year_Ending__c == fiscalYear_JUL_JUN){
            if(orgQuarter == quarter_1 || orgQuarter == quarter_2){
                if(org.Projected_Annual_Revenue_for_Fiscal_Year__c  > 0.0 && org.Projected_Annual_Revenue_for_Fiscal_Year__c < org.Actual_Annual_Revenue_for_Prior_Fiscal_Y__c){
                    revenue = org.Projected_Annual_Revenue_for_Fiscal_Year__c;
                }
                else{
                    revenue = org.Actual_Annual_Revenue_for_Prior_Fiscal_Y__c;
                }
            }
            else if(orgQuarter == quarter_3 || orgQuarter == quarter_4){
                revenue = org.Actual_YeartoDate_Annual_Revenue_for_Fis__c;
            }
        }
    
        fundingRequest.Estimated_Donation_Limit__c = 0.33 * revenue;
        
        if(revenue > 0.0){
            fundingRequest.Estimated_Remaining_Donation_Limit__c = (revenue * 0.33) - fundingRequest.YTD_Total_Approved_Donations__c;
            fundingRequest.Estimated_Current_Revenue_Percent__c = (fundingRequest.YTD_Total_Approved_Donations__c)/revenue * 100;           
        }
        else{
            fundingRequest.Estimated_Remaining_Donation_Limit__c = 0.0;
            fundingRequest.Estimated_Current_Revenue_Percent__c = 0.0;
        }
        
    }
    
    
    /*
    *
    */
    public static decimal getFiscalRevenuePercent(GFRS_Funding_Request__c fundingRequest){

        decimal revenuePercent = 0.0;
        Set<String> allFundingTypes = new Set<String>{'Health Care-Related Charitable', 'Fellowships', 'Scientific Project Support'};
       
        GFRS_Organization__c org = [SELECT id, Fiscal_Year_Ending__c, Actual_Annual_Revenue_for_Prior_Fiscal_Y__c,
                                    Actual_YeartoDate_Annual_Revenue_for_Fis__c, Projected_Annual_Revenue_for_Fiscal_Year__c, 
                                    (select Total_Approved_Amt__c, Date_Submitted__c, Date_for_33_logic__c from gFRS_Copay_Funding_Request__r),
                                    (select Approved_Amount__c, Date_Submitted__c, sub_status__c, Date_for_33_logic__c from Grant_Requests__r where SYS_Request_Approved__c = 'Yes' and Foundation_Classified__c = 'FALSE'
                                            and Funding_Type__c in : allFundingTypes and id != : fundingRequest.id )
                                    from GFRS_Organization__c where id = : fundingRequest.Organization__c];
                                    
        revenuePercent = calculatePercent(fundingRequest,org);
        return revenuePercent;
    }
   
   
    /*
    *
    */
    public static decimal calculatePercent(GFRS_Funding_Request__c fundingRequest, GFRS_Organization__c org){
        Decimal revenue = 0.0;
        Decimal fiscalRevenuePercent = 0.0;
        Decimal YTDapprovedDonations = 0.0;
        Date yearStartDate = determineYearStartDate(fundingRequest.Date_Submitted__c,fundingRequest.Date_for_33_logic__c,org.Fiscal_Year_Ending__c);
        Date yearEndDate = determineYearEndDate(yearStartDate);

        if(yearStartDate!=null && yearEndDate!=null){
            String orgQuarter  = determineOrgQuarter(fundingRequest.Date_Submitted__c, fundingRequest.Date_for_33_logic__c, org.Fiscal_Year_Ending__c);

            for(gFRS_copay_Funding_Request__c orgsApprovedCopayReqs : org.gFRS_Copay_Funding_Request__r){
                if(orgsApprovedCopayReqs.Total_Approved_Amt__c != null 
                        && considerRequest(yearStartDate, yearEndDate, orgsApprovedCopayReqs.Date_Submitted__c, orgsApprovedCopayReqs.Date_for_33_logic__c)){
                    YTDapprovedDonations += orgsApprovedCopayReqs.Total_Approved_Amt__c;
                }
            }
            
            for(gFRS_Funding_Request__c orgsApprovedNonCopayReqs : org.Grant_Requests__r){
                if(orgsApprovedNonCopayReqs.Approved_Amount__c != null
                        && considerRequest(yearStartDate, yearEndDate, orgsApprovedNonCopayReqs.Date_Submitted__c, orgsApprovedNonCopayReqs.Date_for_33_logic__c)){
                    YTDapprovedDonations += orgsApprovedNonCopayReqs.Approved_Amount__c;
                }
            }

            if(fundingRequest.Approved_Amount__c > 0.0){
                YTDapprovedDonations += fundingRequest.Approved_Amount__c;
            }
            
            defaultNullRevenuesToZero(org);
    
            if((org.Fiscal_Year_Ending__c == fiscalYear_JAN_DEC || org.Fiscal_Year_Ending__c == fiscalYear_JUL_JUN) && (orgQuarter != null)){
                if(orgQuarter == quarter_1 || orgQuarter == quarter_2){
                    if(org.Projected_Annual_Revenue_for_Fiscal_Year__c  > 0.0 && org.Projected_Annual_Revenue_for_Fiscal_Year__c < org.Actual_Annual_Revenue_for_Prior_Fiscal_Y__c){
                        revenue = org.Projected_Annual_Revenue_for_Fiscal_Year__c;
                    }
                    else{
                        revenue = org.Actual_Annual_Revenue_for_Prior_Fiscal_Y__c;
                    }
                }
                else if(orgQuarter == quarter_3 || orgQuarter == quarter_4){
                    revenue = org.Actual_YeartoDate_Annual_Revenue_for_Fis__c;
                }
            }
            
            if(revenue > 0.0 ){
                system.debug('revenue --- ' + revenue);
                fiscalRevenuePercent = (YTDapprovedDonations)/revenue * 100;
                //calculating the amount that was above the exceeded 33% limit. Used for validation purposes.
                fundingRequest.Allowed_Operational_Budget__c = YTDapprovedDonations - revenue*0.33;
            }
            else{
                fiscalRevenuePercent = 0.0;
            }
        }
        return fiscalRevenuePercent;
    }

    /*
    *
    */
    public static void defaultNullRevenuesToZero(GFRS_Organization__c org){
        
        if(org.Actual_YeartoDate_Annual_Revenue_for_Fis__c == null){
            org.Actual_YeartoDate_Annual_Revenue_for_Fis__c = 0.0;
        }
        
        if(org.Projected_Annual_Revenue_for_Fiscal_Year__c == null){
            org.Projected_Annual_Revenue_for_Fiscal_Year__c = 0.0;
        }
        
        if(org.Actual_Annual_Revenue_for_Prior_Fiscal_Y__c == null){
            org.Actual_Annual_Revenue_for_Prior_Fiscal_Y__c = 0.0;
        }
        
    }
    
    
    /*
    *
    */
    public static String determineOrgQuarter(DateTime dateSubmitted, Date datefor33Logic, String fiscalYear){
        
        String quarter;
        String quarterForJanDec;
        if(cutOffDate != null && (dateSubmitted >= cutOffDate || datefor33Logic != null)){
            if(datefor33Logic == null){
                quarterForJanDec = null;
            }else{
                switch
                    on datefor33Logic.month() {
                    when  1, 2, 3{
                        quarterForJanDec = quarter_1;
                    }
                    when  4, 5, 6{
                        quarterForJanDec = quarter_2;
                    }
                    when  7, 8, 9{
                        quarterForJanDec = quarter_3;
                    }
                    when  10, 11, 12{
                        quarterForJanDec = quarter_4;
                    }
                    when else{
                        quarterForJanDec = null;
                    }
                }
            }
                
        }else{
            Integer monthOfDate = dateSubmitted.month();        
            Integer dayOfDate = dateSubmitted.day();

            if(monthOfDate >= AUG && monthOfDate <= NOV){
                if(monthOfDate == AUG && dayOfDate >= 16){
                    quarterForJanDec = quarter_1;
                }else if(monthOfDate == NOV && dayOfDate <= 15){
                    quarterForJanDec = quarter_1;
                }
                else if(monthOfDate == SEP || monthOfDate == OCT){
                    quarterForJanDec = quarter_1;
                }
            }
            

            if(monthOfDate >= NOV || monthOfDate <= FEB){
                if(monthOfDate == NOV && dayOfDate >= 16){
                    quarterForJanDec = quarter_2;
                }else if(monthOfDate == FEB && dayOfDate <= 15){
                    quarterForJanDec = quarter_2;
                }
                else if(monthOfDate == DEC || monthOfDate == JAN){
                    quarterForJanDec = quarter_2;
                }
            }
            
            if(monthOfDate >= FEB && monthOfDate <= MAY){
                if(monthOfDate == FEB && dayOfDate >= 16){
                    quarterForJanDec = quarter_3;
                }else if(monthOfDate == MAY && dayOfDate <= 15){
                    quarterForJanDec = quarter_3;
                }
                else if(monthOfDate == MAR || monthOfDate == APR){
                    quarterForJanDec = quarter_3;
                }
            }
            
            if(monthOfDate >= MAY && monthOfDate <= AUG){
                if(monthOfDate == MAY && dayOfDate >= 16){
                    quarterForJanDec = quarter_4;
                }else if(monthOfDate == AUG && dayOfDate <= 15){
                    quarterForJanDec = quarter_4;
                }
                else if(monthOfDate == JUN || monthOfDate == JUL){
                    quarterForJanDec = quarter_4;
                }
            }
        }
        
        if(quarterForJanDec == null){
           return null;
        }else if(fiscalYear == fiscalYear_JAN_DEC){
            system.debug('fiscalYear --- ' + fiscalYear_JAN_DEC);
            quarter = quarterForJanDec;
        }else if(fiscalYear == fiscalYear_JUL_JUN){
            system.debug('fiscalYear --- ' + fiscalYear_JUL_JUN);
            if(quarterForJanDec == quarter_1){quarter = quarter_3;}
            else if(quarterForJanDec == quarter_2){quarter = quarter_4;}
            else if(quarterForJanDec == quarter_3){quarter = quarter_1;}
            else if(quarterForJanDec == quarter_4){quarter = quarter_2;}
        }
        system.debug('org quarter --- ' + quarter);
        return quarter;
    }
    
    /*
    *
    */
    public static Boolean considerRequest(Date startDate, Date endDate, Date submittedDate, Date logicDate){
        Date consideredDate = submittedDate;
        Boolean isRequestConsidered = False;
        
        if(cutOffDate != null && logicDate != null){
            consideredDate = logicDate;
        }else if(cutOffDate != null && submittedDate >= cutOffDate){
            return isRequestConsidered;
        }
        
        if((consideredDate >= startDate) && (consideredDate < endDate)){
             isRequestConsidered = True;
        }
        return isRequestConsidered;
    }
    
    /*
    *
    */
    public static Date determineYearStartDate(Date submittedDate, Date logicDate, String fiscalYear){
        Date yearStartDate = null; 

        if(cutOffDate != null && (submittedDate >= cutOffDate || logicDate != null)){
            if(logicDate == null){
                return yearStartDate;
            }
            Integer currentYear = logicDate.year();
            Integer currentMonth = logicDate.month();
            Integer currentDay = logicDate.day();

            if(fiscalYear == fiscalYear_JAN_DEC){
                yearStartDate = Date.newInstance(currentYear, JAN, 1);
            }
            else if(fiscalYear == fiscalYear_JUL_JUN){
                if(currentMonth < JUL){
                    yearStartDate = Date.newInstance(currentYear - 1, JUL, 1);
            }else{
                    yearStartDate = Date.newInstance(currentYear, JUL, 1);
                }      
            }

        }else{
            if(submittedDate == null){
                return yearStartDate;
            }
            Integer currentYear = submittedDate.year();
            Integer currentMonth = submittedDate.month();
            Integer currentDay = submittedDate.day();

            if(fiscalYear == fiscalYear_JAN_DEC){
                if(currentMonth < AUG ||(currentMonth == AUG && currentDay < 16)){
                    yearStartDate = Date.newInstance(currentYear-1, AUG, 16); 
                }else{
                    yearStartDate = Date.newInstance(currentYear, AUG, 16);
                }   
            }
            else if(fiscalYear == fiscalYear_JUL_JUN){
                if(currentMonth < FEB || (currentMonth == FEB && currentDay < 16)){
                    yearStartDate = Date.newInstance(currentYear-1, FEB, 16);
                }else{
                    yearStartDate = Date.newInstance(currentYear, FEB, 16);
                }      
            }

        }
        return yearStartDate;
        
    }
    
    /*
    *
    */
    public static Date determineYearEndDate(Date yearStartDate){
        if(yearStartDate == null){
            return null;
        }
        Integer year = yearStartDate.year();
        Integer month = yearStartDate.month();
        Integer day = yearStartDate.day();
        return Date.newInstance(year+1, month, day);
    }
    
}