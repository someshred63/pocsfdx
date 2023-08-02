public class CFAR_ClinicalSupplyReport_DataModel {
    private static final Decimal AVG_DAYS_IN_MONTH = 30.44;
    public static Integer NUM_OF_MONTHS_FOR_NEXT_YEAR = 6;
    public static Integer FIRST_MONTH_FOR_NEXT_YEAR_DIVIDED_FORECAST = 8;
    public static Date CURRENT_DATE = Date.today();
    public static Boolean isFirstMonthForNextYearDividedForecast = CURRENT_DATE.month() >= FIRST_MONTH_FOR_NEXT_YEAR_DIVIDED_FORECAST;

    public static Integer monthsAvgSince(Date forecastStartDate) {
        return monthsAvgBetween(forecastStartDate, System.today());
    }

    public static Integer monthsAvgBetween(Date forecastStartDate, Date forecastDate) {
        Decimal tmpRes = forecastStartDate.daysBetween(forecastDate)/CFAR_ClinicalSupplyReport_DataModel.AVG_DAYS_IN_MONTH;
        System.debug('tmpRes=' + tmpRes);
        Integer period = Math.round(tmpRes);
        if (period == 0) {
            period = 1;
        }
        return period;
    }

    public class CohortMoleculeWrapper{
        public CFAR_Trial_gne__c trial {get; set;}
        public CFAR_Cohort_Molecule_gne__c  cohortMolecule {get;set;}
        public Map <String, String> role2TeamMember {get;set;}
        public Map<String, Date> planned2Date {get;set;}
        public Map<String, Date> actual2Date {get;set;}
        public Map<Integer, MonthForecast> month2quota {get;set;}
        public Map<Integer, Integer> year2quota {get;set;}
        public Map<Integer, MonthForecast> firstFewMonthsOfNextYear {get; set;}

        public String protocol {get;set;}
        public String ctms {get;set;}
        public String gStars {get;set;}
        public String csm {get;set;}
        public String trialType {get;set;}
        public String piName {get;set;}
        public String configuration {get;set;}
        public String unitType {get;set;}
        public String doseRegiment {get;set;}
        public String impShipped {get;set;}
        public Date lpi {get;set;}
        public Date fpi {get;set;}
        public Decimal plannedEnrollment {get;set;}
        public Decimal actualEnrollment {get;set;}
        public Decimal cohort {get;set;}
        public Decimal patientsPerCohort {get;set;}
        public Decimal singleDose {get;set;}
        public Decimal monthsOnTherapy {get;set;}

        public CohortMoleculeWrapper(CFAR_Cohort_Molecule_gne__c cohortMolecule, CFAR_Trial_gne__c trial){
            this.cohortMolecule = cohortMolecule;
            this.trial = trial;
            fillActivities();
        }

        private void fillActivities(){
            planned2Date = new Map<String, Date>();
            actual2Date = new Map<String, Date>();
            for(CFAR_Milestone_Activity_gne__c ma : trial.CFAR_Milestone_Activities__r){
                if(ma.Planned_Date_gne__c != null){
                    planned2Date.put(ma.Name, ma.Planned_Date_gne__c);
                }
                if(ma.Actual_Date_gne__c != null){
                    actual2Date.put(ma.Name, ma.Actual_Date_gne__c);
                }
            }
        }
    }

    public class MonthForecast{
        public Integer forecast {get;set;}
        public Decimal previousMonthCohortAccrual {get;set;}
        public Decimal previousMonthPatientsCompletedTrial {get;set;}
        public Decimal cohortAccrual {get;set;}
        public Decimal patientsCompletedTrial {get;set;}

        private Boolean isFirstForecast;
        private Integer forecastYear;
        private Integer forecastMonth;
        private Integer numberDays;
        private Date    activationDate;
        private Date    forecastStartDate;
        private String  dosageInterval;
        private Decimal plannedRateOfAccrual;
        private Decimal rateOfAccrual;
        private Decimal patientsPerCohort;
        private Decimal actualEnrollment;
        private Decimal totalCohortPatientsInStudy;
        private Decimal monthsOnTherapy;
        private Decimal dosagePerDay;
        private Decimal singleDose;
        private Decimal cohortTotalPatients;
        private Decimal dosageFrequency;
        private CFAR_Trial_gne__c trial;
        private CFAR_Cohort_Molecule_gne__c molecule;
        CohortMoleculeWrapper wrapper;

        public MonthForecast(
                Integer month,
                CohortMoleculeWrapper wrapper,
                Boolean isFirstForecast,
                Decimal previousMonthCohortAccrual,
                Integer forecastYear,
                Decimal previousMonthPatientsCompletedTrial
        ){
            this.wrapper = wrapper;
            this.isFirstForecast                     = isFirstForecast;
            this.previousMonthCohortAccrual          = previousMonthCohortAccrual;
            this.previousMonthPatientsCompletedTrial = previousMonthPatientsCompletedTrial;
            this.forecastYear                        = forecastYear;
            this.trial                               = wrapper.trial;
            this.molecule                            = wrapper.cohortMolecule;
            this.forecastMonth                       = month;
            this.numberDays                          = date.daysInMonth(forecastYear, forecastMonth);
            fillValuesFromRecords();
            initData();
        }

        private void initData(){
            this.forecastStartDate                       = fetchForecastStartDate();
            if(forecastStartDate == null){
                forecast = 0;
            } else {
                this.totalCohortPatientsInStudy          = fetchTotalCohortPatientsInStudy();
                this.rateOfAccrual                       = fetchRateOfAccrual();
                this.previousMonthCohortAccrual          = fetchPreviousMonthCohortAccrual();
                this.cohortAccrual                       = fetchCohortAccrual();
                this.dosagePerDay                        = fetchDosagePerDay();
                this.previousMonthPatientsCompletedTrial = fetchPreviousMonthPatientsCompletedTrial();
                this.patientsCompletedTrial              = fetchPatientsCompletedTrial();
                this.forecast                            = calculateForecast();
            }
        }

        private void fillValuesFromRecords(){
            this.dosageFrequency      = molecule.Dosage_Frequency_gne__c;
            this.dosageInterval       = molecule.Dosage_Interval_gne__c;
            this.plannedRateOfAccrual = trial.CFAR_Rate_of_Accrual_gne__c == null ? 0 : trial.CFAR_Rate_of_Accrual_gne__c;
            this.activationDate       = wrapper.actual2Date.get('Activation') != null ?
                    wrapper.actual2Date.get('Activation') : null;
            this.patientsPerCohort    = molecule.Cohort_ref_gne__r.Total_Cohort_Patients_gne__c;
            this.actualEnrollment     = trial.Enrollment_Enrolled_Num_gne__c;
            this.monthsOnTherapy      = molecule.Months_On_Therapy_gne__c;
            this.singleDose           = molecule.Dosage_Qty_gne__c;
            this.cohortTotalPatients  = molecule.Cohort_ref_gne__r.Total_Cohort_Patients_gne__c;
        }

        private Decimal fetchDosagePerDay(){
            if(dosageFrequency == null || singleDose == null){
                return 0;
            }
            if(dosageInterval == CFAR_CohortMoleculeHelper.DOSAGE_INTERVAL_HOURS){
                return singleDose / (dosageFrequency / 24);
            } else if(dosageInterval == CFAR_CohortMoleculeHelper.DOSAGE_INTERVAL_DAYS){
                return singleDose / dosageFrequency;
            } else if(dosageInterval == CFAR_CohortMoleculeHelper.DOSAGE_INTERVAL_WEEKS){
                return singleDose / (dosageFrequency * 7);
            } else if(dosageInterval == CFAR_CohortMoleculeHelper.DOSAGE_INTERVAL_MONTHS){
                return singleDose / (dosageFrequency * numberDays);
            }
            return 0;
        }

        private Integer calculateForecast(){
            return Integer.valueOf(((cohortAccrual - patientsCompletedTrial) * dosagePerDay * numberDays).round(System.RoundingMode.UP));
        }

        private Decimal fetchPatientsCompletedTrial(){
            if(monthsOnTherapy == null || forecastStartDate == null){
                return 0;
            }
            Date forecastDate = date.newInstance(forecastYear, forecastMonth, 1);
            if(forecastStartDate.addMonths(monthsOnTherapy.intValue()) > forecastDate){
                return 0;
            }
            patientsCompletedTrial = rateOfAccrual + previousMonthPatientsCompletedTrial;
            if(patientsCompletedTrial > cohortTotalPatients){
                patientsCompletedTrial = cohortTotalPatients == null ? 0 : cohortTotalPatients;
            }
            return patientsCompletedTrial;
        }

        private Decimal fetchCohortAccrual(){
            Date forecastDate =  date.newInstance(forecastYear, forecastMonth, 1);
            if(forecastStartDate == null || forecastStartDate > forecastDate){
                return 0;
            }
            Decimal result = rateOfAccrual + previousMonthCohortAccrual;
            if(result > patientsPerCohort){
                result = patientsPerCohort;
            }
            return result;
        }

        private Date fetchForecastStartDate(){
            if(activationDate != null ){
                return activationDate.toStartOfMonth();
            }
            if(wrapper.fpi != null){
                return wrapper.fpi.toStartOfMonth();
            }
            return null;
        }

        private Decimal fetchRateOfAccrual(){
            if(activationDate == null){
                return (plannedRateOfAccrual * cohortTotalPatients / totalCohortPatientsInStudy) ;
            }
            Integer period = CFAR_ClinicalSupplyReport_DataModel.monthsAvgSince(activationDate);
            return (actualEnrollment / period) * cohortTotalPatients / totalCohortPatientsInStudy;
        }

        private Decimal fetchTotalCohortPatientsInStudy(){
            Decimal result = 0;
            for(CFAR_Cohort_gne__c c : trial.gSTARS_Cohorts__r){
                if(c.Total_Cohort_Patients_gne__c != null){
                    result += c.Total_Cohort_Patients_gne__c;
                }
            }
            return result;
        }

        private Decimal fetchPreviousMonthCohortAccrual(){
            if(isFirstForecast){
                return calculatePreviousMonthCohortAccrual();
            }
            return previousMonthCohortAccrual;
        }

        private Decimal fetchPreviousMonthPatientsCompletedTrial(){
            if(isFirstForecast){
                return calculatePreviousMonthPatientsCompletedTrial();
            }
            return previousMonthPatientsCompletedTrial;
        }

        private Decimal calculatePreviousMonthPatientsCompletedTrial(){
            Decimal result = 0;
            if(forecastStartDate == null || monthsOnTherapy == null){
                return result;
            }
            Date fpoDate = forecastStartDate.addMonths(monthsOnTherapy.intValue() );
            Date forecastDate = Date.newInstance(forecastYear, forecastMonth, 1);
            if(fpoDate > forecastDate){
                return result;
            }
            Integer period = forecastDate.monthsBetween(fpoDate);
            for(Integer x = 0; x < period; x++ ){
                result += rateOfAccrual;
                if(result >= patientsPerCohort){
                    result = patientsPerCohort;
                }
            }
            return result;
        }

        private Decimal calculatePreviousMonthCohortAccrual(){
            Decimal result = 0;
            Date forecastDate = Date.newInstance(forecastYear, forecastMonth, 1);
            Integer period = forecastStartDate.monthsBetween(forecastDate);
            if(forecastStartDate >= forecastDate){
                return result;
            }
            for(Integer x=0; x<period; x++ ){
                result += rateOfAccrual;
                if(previousMonthCohortAccrual >= patientsPerCohort ){
                    result = patientsPerCohort;
                    break;
                }
            }
            return result;
        }
    }

    public static void fillAllWrapperVariables(CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper wrapper){
        //values from Cohort Molecule
        wrapper.singleDose = wrapper.cohortMolecule.Dosage_Qty_gne__c;
        wrapper.monthsOnTherapy = wrapper.cohortMolecule.Months_On_Therapy_gne__c;

        //values from Cohort
        wrapper.cohort = wrapper.cohortMolecule.Cohort_ref_gne__r.Cohort_number_gne__c;
        wrapper.patientsPerCohort = wrapper.cohortMolecule.Cohort_ref_gne__r.Total_Cohort_Patients_gne__c;
        wrapper.doseRegiment = createDoseRegiment(wrapper.cohortMolecule);
        wrapper.impShipped = wrapper.cohortMolecule.Molecule_Configuration_ref_gne__r.Product_gne__r.Generic_Name_gne__c;

        //values from Molecule Configuration
        wrapper.configuration = wrapper.cohortMolecule.Molecule_Configuration_ref_gne__r.Configuration_gne__c;
        wrapper.unitType = wrapper.cohortMolecule.Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__r.Name;

        //values from Trial
        if(wrapper.trial != null){
            wrapper.protocol = wrapper.trial.Other_Trial_gne_Id__c != null ?
                    wrapper.trial.Other_Trial_gne_Id__c : wrapper.trial.CTMS_gne__c != null ?
                            wrapper.trial.CTMS_gne__c  : wrapper.trial.Name;
            wrapper.protocol = wrapper.protocol;
            wrapper.ctms = wrapper.trial.CTMS_gne__c;
            wrapper.gStars = wrapper.trial.Name;
            wrapper.csm = wrapper.trial.frm_Genentech_Primary_Contact_ref_gne__c;

            wrapper.trialType = wrapper.trial.frm_Trial_Type_ref_gne__c;
            //wrapper.piName = wrapper.role2TeamMember.get(CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR) != null ?
            //        wrapper.role2TeamMember.get(CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR) : '';
            wrapper.fpi = wrapper.actual2Date.get('FPI') != null ? wrapper.actual2Date.get('FPI') : wrapper.planned2Date.get('FPI');
            wrapper.lpi = wrapper.actual2Date.get('LPI') != null ?
                    wrapper.actual2Date.get('LPI') : wrapper.planned2Date.get('LPI') != null ?  wrapper.planned2Date.get('LPI') : null;
            wrapper.plannedEnrollment = wrapper.trial.Planned_Enrollment_gne__c;
            wrapper.actualEnrollment = wrapper.trial.Enrolled_Sum_rollup_gne__c;
        }
    }

    public static Map<String, Integer> fetchForecasts(CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper wrapper) {
        Map<String, Integer> month2forecast = new Map<String, Integer>();

        Boolean isFirstForecast = true;
        Decimal previousMonthCohortAccrual = 0;
        Decimal previousMonthPatientsCompletedTrial = 0;

        Integer currentYear = CURRENT_DATE.year();
        Integer currentMonth = CURRENT_DATE.month();

        for(Integer year = currentYear; year <= (currentYear+4) ; year++) {
            for (Integer month = (year == currentYear ? currentMonth : 1); month <= 12; month++) {
                CFAR_ClinicalSupplyReport_DataModel.MonthForecast forecast = calculateMonthForecast(
                        month,
                        wrapper,
                        isFirstForecast,
                        previousMonthCohortAccrual,
                        year,
                        previousMonthPatientsCompletedTrial
                );
                month2forecast.put(year + '-' + month, forecast.forecast);
                previousMonthCohortAccrual = forecast.cohortAccrual;
                previousMonthPatientsCompletedTrial = forecast.patientsCompletedTrial;
                isFirstForecast = false;
            }
        }
        return month2forecast;
    }

    private static CFAR_ClinicalSupplyReport_DataModel.MonthForecast calculateMonthForecast(
            Integer month,
            CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper wrapper,
            Boolean isFirstForecast,
            Decimal previousMonthCohortAccrual,
            Integer currentYear,
            Decimal previousMonthPatientsCompletedTrial
    ){
        CFAR_ClinicalSupplyReport_DataModel.MonthForecast forecast =
                new CFAR_ClinicalSupplyReport_DataModel.MonthForecast(
                        month,
                        wrapper,
                        isFirstForecast,
                        previousMonthCohortAccrual,
                        currentYear,
                        previousMonthPatientsCompletedTrial
                );
        return forecast;
    }

    private static String createDoseRegiment(CFAR_Cohort_Molecule_gne__c cohortMolecule){
        Decimal freq = cohortMolecule.Dosage_Frequency_gne__c;
        String interval = cohortMolecule.Dosage_Interval_gne__c;
        return freq == null || String.isEmpty(interval) ? 'no configuration' : freq + ' ' + interval;
    }

}