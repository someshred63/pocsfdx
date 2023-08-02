public with sharing class CFAR_MilestonesController extends CFAR_TrialBaseController {
    
    public Set<String> milestoneActivitiesToDisable {
        get{
            return CFAR_Inactive_Milestone_Activities__c.getAll().keySet();
        } set;
    }

    public override void save(){
        if(validatePlannedEnrollment()){
        super.save();
        //after saving upper section user sorting is lost (coming back to default), so the same should be shown on layout
        setDefaultSortExpressionAndDirection();
        refreshChildObjectsAffectedByTrialChange(); 
        }
    }
    
    public Boolean correct = true;
    public Boolean getCorrect(){
        return correct;
    }
    
    public Boolean validatePlannedEnrollment(){
        List<CFAR_Cohort_gne__c> totalCohortPatients = [SELECT Total_Cohort_Patients_gne__c, Trial_ref_gne__c FROM CFAR_Cohort_gne__c WHERE Trial_ref_gne__c =: trial.id];
        Decimal sum = 0;
        for(CFAR_Cohort_gne__c cohort : totalCohortPatients){
            sum += cohort.Total_Cohort_Patients_gne__c;
        }
        
        if(trial.Planned_Enrollment_gne__c < sum){
            return correct = false;
        } else {
        return correct = true;
        }
    }
    
    public Boolean getLpiError() {
        List<CFAR_Milestone_Activity_gne__c> activityLPI = [select Id, Name, Planned_Date_gne__c, Actual_Date_gne__c, Baselined_Date_gne__c, Comments_gne__c 
                    from CFAR_Milestone_Activity_gne__c where Name = 'LPI' and CFAR_Trial_ref_gne__c = :trial.Id];
        return !activityLPI.isEmpty() && trial.CFAR_Enrollment_End_Date_gne__c != activityLPI[0].Planned_Date_gne__c && activityLPI[0].Planned_Date_gne__c != null;
    }
    
    public String LPI_MESSAGE {
        get {
            return 'Enrollment end date and LPI planned date are out of sync, please adjust the LPI planned date to match enrollment end date'; 
        }
        set;
    }
    
    public Boolean getTotalProjectedAccrualNotEqualPlannedEnrolledError() {
        
        List<AggregateResult> res = [select sum(Projected_Accrual_gne__c) sumProjected from CFAR_Projected_Subject_Accrual_gne_ref__c 
            where CFAR_Trial_ref_gne__c = :trial.Id and Projected_Accrual_gne__c != null];
        
        if(res.isEmpty() || res[0].get('sumProjected') == null) return false;
        
        return trial.Planned_Enrollment_gne__c != Double.valueOf(res[0].get('sumProjected'));
    }
    
    public String TOTAL_PROJECTED_ACCRUAL_NOT_EQUAL_PLANNED_ENROLLED_MESSAGE {
        get {
            return 'The total projected accrual is not equal to GNE Contractual Enrollment. Please update either.';   
        }
        set;
    }
    
    public Boolean getLastProjectedAccrualNotEqualActualsError() {
        Date currentDate = System.today();
        Boolean after10January = (currentDate.month() > 1 || currentDate.day() >= 10);
        
        List<CFAR_Projected_Subject_Accrual_gne_ref__c> res = [select Id, Projected_Accrual_gne__c, Actual_gne__c from CFAR_Projected_Subject_Accrual_gne_ref__c 
            where CFAR_Trial_ref_gne__c = :trial.Id and CFAR_Year_gne__c = :(currentDate.year()-1)];
            
        if(after10January && !res.isEmpty() && res[0].Projected_Accrual_gne__c != res[0].Actual_gne__c) return true;
        
        return false;
    }
    
    public String LAST_PROJECTED_ACCRUAL_NOT_EQUAL_ACTUAL_MESSAGE {
        get {
            integer previousYear = System.today().year() - 1;
            return 'The projected accrual does not match actual enrollment total for ' + previousYear + ', please ensure actual enrollment for ' + previousYear + ' is up to date and update projected accrual';
        }
        set;
    }
    

    /*refreshes ALL related child objects - used when trialId/reference is changed */ 
    public override void refreshTrialChildObjects(){
        system.debug('CFAR_MilestonesController::refreshTrialChildObjects + trialId=' + trial.Id);
        stdSetControllerProjectedSubjectAccrual = new ApexPages.StandardSetController(CFAR_DAO.getAccrualRelatedToTrial(trial.id));
        fillProjectedSubjectAccruals();
    }

    public void refreshChildObjectsAffectedByTrialChange(){
        system.debug('CFAR_MilestonesController::refreshChildObjectsAffectedByTrialChange + trialId=' + trial.Id);
        stdSetControllerProjectedSubjectAccrual = new ApexPages.StandardSetController(CFAR_DAO.getAccrualRelatedToTrial(trial.id));
        stdSetControllerProjectedSubjectAccrual.setPageSize(pageSize);
        fillProjectedSubjectAccruals();
    }

    public ApexPages.StandardSetController stdSetControllerMilestoneActivity;
    public ApexPages.StandardSetController stdSetControllerActualEnrollment;
    public ApexPages.StandardSetController stdSetControllerProjection;
    private CFAR_Milestone_Activity_gne__c[] milestoneActivities;
    public Map<Id,CFAR_Milestone_Activity_gne__c> initialMilestoneActivities = new Map<Id, CFAR_Milestone_Activity_gne__c>();
    
    public CFAR_Milestone_Activity_gne__c[] getMilestoneActivities() {
        stdSetControllerMilestoneActivity = new ApexPages.StandardSetController(CFAR_DAO.getMilestoneActivitiesByTrialId(trial.Id));
        stdSetControllerMilestoneActivity.setPageSize(100);
        milestoneActivities = stdSetControllerMilestoneActivity.getRecords();
        if (!milestoneActivities.isEmpty()) {
            if (!initialMilestoneActivities.containsKey(milestoneActivities[0].Id)) {
                setInitialMilestoneActivities();
            }
        }
        return milestoneActivities;
    }

    public void setInitialMilestoneActivities() {
        try {
            initialMilestoneActivities.clear();
            for (CFAR_Milestone_Activity_gne__c ma : milestoneActivities) {
                initialMilestoneActivities.put(ma.Id, ma);
            }
        } catch (Exception ex) {
            super.addErrorMessage(ex.getMessage());
        }
    }

    public CFAR_Actual_Enrollment_gne__c[] getActualEnrollments() {
        searchParam = new CFAR_SearchParameters();
        stdSetControllerActualEnrollment = new ApexPages.StandardSetController(CFAR_DAO.getActualEnrollmentsByTrialId(trialId));
        stdSetControllerActualEnrollment.setPageSize(100);
        return stdSetControllerActualEnrollment.getRecords();
    }
    
    public CFAR_MilestonesController (){
        super(true);
        componentId = 'Milestones Component';
        //set parameters in the beggining, to fix accruals sorting problem, when enrollments are saved
        setDefaultSortExpressionAndDirection(); 
        if(trialId != null) {
            stdSetControllerProjectedSubjectAccrual = new ApexPages.StandardSetController(CFAR_DAO.getAccrualRelatedToTrial(trialId));
            stdSetControllerProjectedSubjectAccrual.setPageSize(pageSize);
            fillProjectedSubjectAccruals();
        }        
        addEditMilestoneActivity = false;
        system.debug('CFAR_MilestonesController ' + trialId);
    }
    
    private void setDefaultSortExpressionAndDirection() {
        sortExpression = 'CFAR_Year_gne__c'; 
        sortDirection = 'asc';
    }
    
    /*
    *   Milestone Activity 
    */
    public CFAR_Milestone_Activity_gne__c currentMilestoneActivity {get; set;}
    public Boolean addEditMilestoneActivity {get;set;}
    public String milestoneActivityId {get; set;}
    
    public Integer getActiveMonths() {
        Integer activeMonths;
        // This functionality must be reflected in reports, accrual tab CFAR-296
        for(CFAR_Milestone_Activity_gne__c ma :getmilestoneActivities()) {
            if(ma.Name == 'Activation' && ma.Actual_Date_gne__c != null && ma.Actual_Date_gne__c <= Date.today()) {
                Integer mb = ma.Actual_Date_gne__c.monthsBetween(Date.Today());
                Date tmpDate = ma.Actual_Date_gne__c.addMonths(mb);
                Integer db = tmpDate.daysBetween(Date.Today());
                activeMonths = mb +  (db > 15 ? 1 : 0);
                return activeMonths;
            }
        }
        return activeMonths;
    }
    
    public void editMilestoneActivity() {
        resetError();
        currentMilestoneActivity = [select Id, Name, Planned_Date_gne__c, Actual_Date_gne__c, Baselined_Date_gne__c, Comments_gne__c 
                    from CFAR_Milestone_Activity_gne__c where Id = :milestoneActivityId];
        addEditMilestoneActivity = true;
    }

    public void createNewMilestoneActivity() {
        currentMilestoneActivity = new CFAR_Milestone_Activity_gne__c(CFAR_Trial_ref_gne__c = trialId);
        addEditMilestoneActivity = true;
    }

    public void editAllMilestoneActivity(){
        addEditMilestoneActivity = true;
    }

    public void cancelAllMilestoneActivities(){
        addEditMilestoneActivity = false;
    }
    
    public CFAR_Milestone_Activity_gne__c[] filterModifiedMilestoneActivities(List<CFAR_Milestone_Activity_gne__c> allActivities) {
        CFAR_Milestone_Activity_gne__c[] modifiedMileStoneActivities = new List<CFAR_Milestone_Activity_gne__c>();
        for (CFAR_Milestone_Activity_gne__c ma : allActivities) {
            if ((ma.Comments_gne__c != initialMilestoneActivities.get(ma.Id).Comments_gne__c && !(ma.Comments_gne__c == '' && initialMilestoneActivities.get(ma.Id).Comments_gne__c == null))
            || (ma.Planned_Date_gne__c != initialMilestoneActivities.get(ma.Id).Planned_Date_gne__c )
            || (ma.Actual_Date_gne__c != initialMilestoneActivities.get(ma.Id).Actual_Date_gne__c  )
               ) {
                modifiedMileStoneActivities.add(ma);
            }
        }
        return modifiedMileStoneActivities;
    }

    public PageReference saveAllMilestoneActivities() {
        try {
            CFAR_Milestone_Activity_gne__c[] modifiedMileStoneActivities =  filterModifiedMilestoneActivities(milestoneActivities);
            ApexPages.StandardSetController ctrl = new ApexPages.StandardSetController(modifiedMileStoneActivities);
            CFAR_ConfigUtil.setDisabled('Disabled_Validation_Rules_gne__c', new List<String>{'CFAR_Trial_gne__c.LPO_Actual_Date_VS_Enrollment_Validation'});
            PageReference pr = ctrl.save();
            CFAR_ConfigUtil.setDisabled('Disabled_Validation_Rules_gne__c', new List<String>());
            isError = pr == null && ApexPages.hasMessages();
            refreshTrial();
            if (isError) {
                logMessage();
            } else {
                setInitialMilestoneActivities();
                addEditMilestoneActivity = false;
            }
        } catch (Exception ex) {
            super.addErrorMessage(ex.getMessage());
        }
        return null;
    }

    public PageReference submitMilestoneActivity() {
        ApexPages.StandardController ctrl = new ApexPages.StandardController(currentMilestoneActivity);
        CFAR_ConfigUtil.setDisabled('Disabled_Validation_Rules_gne__c', new List<String>{'CFAR_Trial_gne__c.LPO_Actual_Date_VS_Enrollment_Validation'});
        PageReference pr = ctrl.save();
        CFAR_ConfigUtil.setDisabled('Disabled_Validation_Rules_gne__c', new List<String>());
        isError = pr == null && ApexPages.hasMessages();
        if(isError) {
            logMessage();
        } else {
            refreshTrial();
            getMilestoneActivities();
            //after saving milest act user sorting is lost (coming back to default), so the same should be shown on layout
            setDefaultSortExpressionAndDirection();
            refreshChildObjectsAffectedByTrialChange();
            addEditMilestoneActivity = false;
        }
        return null;
    }
        
    public void cancelCreateMilestoneActivity() {
        addEditMilestoneActivity = false;
        resetError();
    }
    
    public String getMilestonesSize(){
        String size = String.valueOf(getMilestoneActivities().size());
        return size ; 
    }
    
    ///////////////////////////////////////////////////Enrolment Record //////////////////////////////////////////////////////////////////////////
    public CFAR_Actual_Enrollment_gne__c currentEnrollment {
        get{
            return currentEnrollment;  
        }
        set{
            currentEnrollment = value; 
        }
        }
    private CFAR_Actual_Enrollment_gne__c currentEnrollmentComparisonClone; 
    public Boolean addEditEnrollment {get;set;}                                         //flag used to display / hide Enrollment edit popup 
    public String enrollmentId {get; set;}
    
    public void editEnrollment() {
        //TODO change to selection from DAO
        prepareCurrentEnrollmentForEdit(    CFAR_DAO.getActualenrollmentsById(enrollmentId) , false ); 
    }
    
    public void createNewEnrollment() {
        prepareCurrentEnrollmentForEdit (new CFAR_Actual_Enrollment_gne__c(CFAR_Trial_ref_gne__c = trialId, Date_gne__c = Date.today()),true );
    }
    
    private void prepareCurrentEnrollmentForEdit(CFAR_Actual_Enrollment_gne__c enrollment, Boolean enrollmentIsCreated){
        resetError();
        currentEnrollment = enrollment; 
        currentEnrollmentComparisonClone = enrollmentIsCreated ? new CFAR_Actual_Enrollment_gne__c() : currentEnrollment.clone(true,true,true,true);            
        addEditEnrollment = true;
        
    }
    

    public PageReference submitEnrollment() {
        resetError();
        Savepoint sp = Database.setSavepoint();
        try{
            if (currentEnrollment.Date_gne__c == null) {
                isError = true; 
                errorMessage = 'Date cannot be empty. Please insert value.'; 
                return null;
            }
            
            Boolean blockFutureDate = true;
            CFAR_Boolean_Settings_gne__c blockEnrollmentFutureDateSetting = CFAR_Boolean_Settings_gne__c.getInstance('BlockEnrollmentFutureDate');
            if (blockEnrollmentFutureDateSetting != null && blockEnrollmentFutureDateSetting.Value_gne__c != null) {
                blockFutureDate = blockEnrollmentFutureDateSetting.Value_gne__c;
            }
            if (currentEnrollment.Date_gne__c > System.today() && blockFutureDate) {
                isError = true; 
                errorMessage = 'Actual Enrollment Record Date cannot be a Future Date. Please Enter Past or Current Date.'; 
                return null;
            }
            
            List<CFAR_Actual_Enrollment_gne__c> l = [select Id, Date_gne__c, Enrolled_Num_gne__c, Discontinued_Num_gne__c 
                from CFAR_Actual_Enrollment_gne__c 
                where CFAR_Trial_ref_gne__c = :currentEnrollment.CFAR_Trial_ref_gne__c 
                    and Date_gne__c < :currentEnrollment.Date_gne__c and Enrolled_Num_gne__c != null order by Date_gne__c desc];
            
            if(!l.isEmpty() && currentEnrollment.Enrolled_Num_gne__c != null 
                && l[0].Enrolled_Num_gne__c > currentEnrollment.Enrolled_Num_gne__c) {
                    isError = true; 
                    errorMessage = '# enrolled value is lower than previous, please update.'; 
                    //logMessage();
                    return null;
            }
            
            //security so that we cannot add/edit enrollments in this way, that previous ones would be bigger than next
            List<CFAR_Actual_Enrollment_gne__c> l1 = [select Id, Date_gne__c, Enrolled_Num_gne__c, Discontinued_Num_gne__c 
                from CFAR_Actual_Enrollment_gne__c 
                where CFAR_Trial_ref_gne__c = :currentEnrollment.CFAR_Trial_ref_gne__c 
                    and Date_gne__c > :currentEnrollment.Date_gne__c and Enrolled_Num_gne__c != null order by Date_gne__c asc];
            
            if(!l1.isEmpty() && currentEnrollment.Enrolled_Num_gne__c != null 
                && l1[0].Enrolled_Num_gne__c < currentEnrollment.Enrolled_Num_gne__c) {
                    isError = true; 
                    errorMessage = '# enrolled value is higher than next, please update.'; 
                    //logMessage();
                    return null;
            }
            
            upsert currentEnrollment; 
            
            CFAR_EnrollmentHandler enrollmentHandler = new CFAR_EnrollmentHandler(); 
            enrollmentHandler.handleEnrollmentChange(currentEnrollmentComparisonClone, currentEnrollment); 
            refreshTrial();
            
            getActualEnrollments();
            sortProjectedSubjectAccrual(); //fetches data from db, but looses pagination index 
        } catch (Exception e) {
            isError = true; 
            errorMessage = e.getMessage(); 
            logMessage();
            Database.rollback(sp);
            super.addErrorMessage(e.getMessage()); 
        }
        
        return null;
    }

    public void cancelCreateEnrollment() {
        addEditEnrollment = false;
        resetError();
    }
    

    //////////////////////////////////////////////////////BASELINE & REBASELINE /////////////////////////////////////////////////////// 
    public void baseline() {
        try {
            for ( CFAR_Milestone_Activity_gne__c activity : milestoneActivities  ) {
                if (!milestoneActivitiesToDisable.contains(activity.Name)) {
                    activity.Baselined_Date_gne__c = activity.Planned_Date_gne__c;
                }
            }
            update milestoneActivities;
            trial.Baselined__c = true;
            super.save();
        } catch (Exception ex) {
            super.addErrorMessage(ex.getMessage());
        }
    }

    public Boolean getAllowBaseline(){
        return ((milestoneActivities != null) && (trial.Baselined__c != true) && allActivitiesHavePlannedDates()); 
    }

    public Boolean allActivitiesHavePlannedDates() {
        Boolean allActivitiesHavePlannedDates = true; 
        for( CFAR_Milestone_Activity_gne__c activity : milestoneActivities ){
            if(activity.Planned_Date_gne__c == null && !milestoneActivitiesToDisable.contains(activity.Name)){
                allActivitiesHavePlannedDates=false; 
                break; 
            }
        }
        return allActivitiesHavePlannedDates; 
    }
    
    public Boolean allActivitiesHaveActualDates() {
        Boolean allActivitiesHaveActualDates = true; 
        for( CFAR_Milestone_Activity_gne__c activity : milestoneActivities ){
            if(activity.Actual_Date_gne__c == null && !milestoneActivitiesToDisable.contains(activity.Name) ){
                allActivitiesHaveActualDates=false; 
                break; 
            }
        }
        return allActivitiesHaveActualDates; 
    }
    
    //REBASELINE
    
    public Boolean getAllowReBaseline(){
        //return ( (milestoneActivities != null) && ((trial.Baselined__c == true && (!allActivitiesHaveActualDates() || getCurrentUserIsAdmin())) || (super.trialhasContractAmendment() || getCurrentUserIsAdmin() ))  ); 
        return ((milestoneActivities != null && allActivitiesHavePlannedDates()) && (!allActivitiesHaveActualDates() || super.trialhasContractAmendment() || getCurrentUserIsAdmin()));
    }

    public void reBaseline() {
        try {
            for (CFAR_Milestone_Activity_gne__c activity : milestoneActivities) {
                if (!milestoneActivitiesToDisable.contains(activity.Name)) {
                    activity.Baselined_Date_gne__c = activity.Planned_Date_gne__c;
                }
            }
            update milestoneActivities;
            trial.Last_Re_Baseline_Time_gne__c = Datetime.now();
            super.save();
        } catch (Exception ex) {
            super.addErrorMessage(ex.getMessage());
        }
    }

    //Once LPO  Actual Date is entered under the Milestone Activity, then # Discontinued + # Completed Trial should = to # Enrolled
    public Boolean getDiscontinuedPlusCompletedEqualsEnrolled(){
    //Actual Enrollment Record:
        //CFAR_Actual_Enrollment_gne__c[] enrollments = getActualEnrollments();
        Decimal discontinuedCount = 0; 
        Decimal completedCount = 0; 
        Decimal enrolledCount = 0; 
         
        for(CFAR_Actual_Enrollment_gne__c enrollment : getActualEnrollments()){
            discontinuedCount += enrollment.Discontinued_Num_gne__c != null ? enrollment.Discontinued_Num_gne__c : 0 ; 
            completedCount += enrollment.Completed_Trial_Num_gne__c != null ? enrollment.Completed_Trial_Num_gne__c : 0 ; 
            enrolledCount += enrollment.Enrolled_Num_gne__c != null ? enrollment.Enrolled_Num_gne__c : 0 ; 
        }
        
        return ((discontinuedCount+completedCount) == enrolledCount);
    }
    
//////////////////////////////////////////Projected Subject Accrual
    public String objectId {get;set;}
    public SObject s_object {get; set;}
    final Integer pageSize = 10;
    public Map<Id, CFAR_AccrualWrapper> objectMapProjectedSubjectAccrual {get; set;}
    public List<CFAR_AccrualWrapper> objectListProjectedSubjectAccrual {get; set;}
    private ApexPages.StandardSetController stdSetControllerProjectedSubjectAccrual;        
            //save
    public void sortProjectedSubjectAccrual() {
        searchParam = new CFAR_SearchParameters();
        searchParam.andEqualsParameters.put('CFAR_Trial_ref_gne__c',trialId);
        if (null!=sortDirection)
            searchParam.sortDirection = sortDirection;
        if (null!=sortExpression)
            searchParam.sortExpression = sortExpression;
        
        stdSetControllerProjectedSubjectAccrual = new ApexPages.StandardSetController(CFAR_DAO.getAccruals(searchParam));       
        stdSetControllerProjectedSubjectAccrual.setPageSize(pageSize);
        fillProjectedSubjectAccruals();
    }
    
        //cancel
    public void cancelCreateProjectedSubjectAccrual() {
        objectMapProjectedSubjectAccrual.get(objectId).selected = false;
        
    }
    
        //prevoius
    public void previousProjectedSubjectAccrual() 
    {
        stdSetControllerProjectedSubjectAccrual.previous();
        fillProjectedSubjectAccruals();
    }
    
        //next
    public void nextProjectedSubjectAccrual() 
    {
        stdSetControllerProjectedSubjectAccrual.next();
        fillProjectedSubjectAccruals();
    }
    
        //first
    public void firstProjectedSubjectAccrual() 
    {
        stdSetControllerProjectedSubjectAccrual.first();
        fillProjectedSubjectAccruals();
    }
    
        //last
    public void lastProjectedSubjectAccrual() 
    {
        stdSetControllerProjectedSubjectAccrual.last();
        fillProjectedSubjectAccruals();
    }
    
        //hasNext
    public Boolean hasNextProjectedSubjectAccrual 
    {
        get {
            return stdSetControllerProjectedSubjectAccrual.getHasNext();
        }
        private set;
    }
    
        //hasPrevoius
    public Boolean hasPreviousProjectedSubjectAccrual 
    {
        get {
            return stdSetControllerProjectedSubjectAccrual.getHasPrevious();
        }
        private set;
    }   
    
        //edit
    public void editProjectedSubjectAccrual() {
        objectMapProjectedSubjectAccrual.get(objectId).selected = true;
        s_object = objectMapProjectedSubjectAccrual.get(objectId).innerObject.clone(true, true, true, true);
        
        for(CFAR_SObjectWrapper obj : objectMapProjectedSubjectAccrual.values()) {
            if(obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }
    
        //cancel edit
    public void cancelEditProjectedSubjectAccrual() {
        objectMapProjectedSubjectAccrual.get(objectId).selected = false;
    }
    
        //save
    public void saveProjectedSubjectAccrual() {
        Savepoint sp = Database.setSavepoint();
        try{
            CFAR_AccrualWrapper accrualWrapper = objectMapProjectedSubjectAccrual.get(s_object.Id); 
            ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
            objectMapProjectedSubjectAccrual.get(s_object.Id).selected = false;
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages())
                objectMapProjectedSubjectAccrual.get(s_object.Id).innerObject = s_object;

            //if the record is frozen it means that it was frozen during this request and parent trial needs to be updated concerning frozen years
            if(accrualWrapper.isFrozen ){
                CFAR_Utils.logError('frozen CFAR_Year_gne__c:' + s_object.get('CFAR_Year_gne__c'));
                trialWrapper.addFrozenDate((Decimal)s_object.get('CFAR_Year_gne__c'));
                super.save(); //it also refreshes trial 
            }
                
            //Database.rollback(sp);
                
        } catch (Exception e) {
            isError = true; 
            errorMessage = e.getMessage();
            logMessage();
            CFAR_Utils.logError('There is error in saveProjectedSubjectAccrual,errorMessage:' + errorMessage); 
            Database.rollback(sp);
            super.addErrorMessage(e.getMessage());
        }
    }

        //view list
    private void fillProjectedSubjectAccruals() {
        objectMapProjectedSubjectAccrual = new Map<Id, CFAR_AccrualWrapper>();
        objectListProjectedSubjectAccrual = new List<CFAR_AccrualWrapper>(); 
        for(SObject s : stdSetControllerProjectedSubjectAccrual.getRecords()) {
            CFAR_AccrualWrapper obj = new CFAR_AccrualWrapper(s, false);
            objectListProjectedSubjectAccrual.add(obj);
            objectMapProjectedSubjectAccrual.put(s.Id, obj);
        }
    }
}