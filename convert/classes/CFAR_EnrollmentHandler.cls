public class CFAR_EnrollmentHandler{
    
    public void handleEnrollmentChange(CFAR_Actual_Enrollment_gne__c oldEnrollment,CFAR_Actual_Enrollment_gne__c newEnrollment){
    	CFAR_Utils.logError('handleEnrollmentChange oldEnrollment: '+ oldEnrollment +  ' newEnrollment:  ' + newEnrollment);       
       
        CFAR_Actual_Enrollment_gne__c[] trialEnrollments = CFAR_DAO.getTrialsActualEnrollments(new List<String>{newEnrollment.CFAR_Trial_ref_gne__c});
        
        
        CFAR_Trial_gne__c trial = CFAR_DAO.getTrial(newEnrollment.CFAR_Trial_ref_gne__c); 
 		handleEnrollmentChange(oldEnrollment, newEnrollment,trialEnrollments,trial ); 

    }
    
    public void handleEnrollmentChange(CFAR_Actual_Enrollment_gne__c oldEnrollment,CFAR_Actual_Enrollment_gne__c newEnrollment,CFAR_Actual_Enrollment_gne__c[] trialEnrollments,CFAR_Trial_gne__c trial ){
    
    	//if enrollment is latest enrollment prpopagate it's number to trial  
        if( enrollmentIsLatestEnrollment(newEnrollment,trialEnrollments ))
            propagateEnrollmentChangeToTrial(newEnrollment,trial);  
        
        /**    
		//if only number of enrollment has changed update accruals for current Enrollment
		Boolean newTrialYearAccrualHasBeenRecalculated = false;             
        if(enrollmentNumChanged(oldEnrollment, newEnrollment)){
        	CFAR_Projected_Subject_Accrual_gne_ref__c newAccrual = CFAR_DAO.getAccrualByTrialAndYear(newEnrollment.CFAR_Trial_ref_gne__c,newEnrollment.Date_gne__c.year() ) ;
        	recalculateAccrualAndUpsert(trialEnrollments,newAccrual,trial );
        	newTrialYearAccrualHasBeenRecalculated=true; 
    	}
		//if year of enrollment has changed update also accruals for previous Year. 
        if(enrollmentYearChanged(oldEnrollment, newEnrollment)){
        	if(null != oldEnrollment.id && null != oldEnrollment.Date_gne__c ){
        		CFAR_Projected_Subject_Accrual_gne_ref__c oldAccrual = CFAR_DAO.getAccrualByTrialAndYear(oldEnrollment.CFAR_Trial_ref_gne__c,oldEnrollment.Date_gne__c.year() ) ;
        		recalculateAccrualAndUpsert(trialEnrollments,oldAccrual,trial );
        	}
        	if( (!newTrialYearAccrualHasBeenRecalculated) && (null != oldEnrollment.id) && (null != newEnrollment.Date_gne__c) ) {
        		CFAR_Projected_Subject_Accrual_gne_ref__c newAccrual = CFAR_DAO.getAccrualByTrialAndYear(newEnrollment.CFAR_Trial_ref_gne__c,newEnrollment.Date_gne__c.year() ) ;
        		recalculateAccrualAndUpsert(trialEnrollments,newAccrual,trial );
        	}
    	}
    	*/
        
        List<CFAR_Projected_Subject_Accrual_gne_ref__c> accrualsToUpdate = fixCalculationsWithPriorYearsValues(trial, CFAR_DAO.getAccrualRelatedToTrial(String.valueOf(trial.Id)), trialEnrollments);
        if (accrualsToUpdate != null && !accrualsToUpdate.isEmpty()) {
        	update accrualsToUpdate;
        }
        update trial;
    }
    
    
    private void propagateEnrollmentChangeToTrial(CFAR_Actual_Enrollment_gne__c sourceEnrollment,CFAR_Trial_gne__c trial){
		trial.Enrollment_Completed_Num_gne__c = sourceEnrollment.Completed_Trial_Num_gne__c;
		trial.Enrollment_Discontinued_Num_gne__c = sourceEnrollment.Discontinued_Num_gne__c;
		trial.Enrollment_Enrolled_Num_gne__c = sourceEnrollment.Enrolled_Num_gne__c;
    }
    
    private Boolean enrollmentIsLatestEnrollment( CFAR_Actual_Enrollment_gne__c enrollment, List<CFAR_Actual_Enrollment_gne__c> trialEnrollments ){
    	for(CFAR_Actual_Enrollment_gne__c e: trialEnrollments){
    		if(e.Date_gne__c > enrollment.Date_gne__c)
    			return false; 
    		else if ( (e.Date_gne__c == enrollment.Date_gne__c)	 &&	 (e.createddate > enrollment.createddate) )
    			return false; 
    	}
    	return true; 
    }

    
    /**
    private Boolean enrollmentYearChanged(CFAR_Actual_Enrollment_gne__c oldEnrollment,CFAR_Actual_Enrollment_gne__c newEnrollment){
    	
    	Integer oldEnrollmentYear = oldEnrollment == null || oldEnrollment.Date_gne__c == null ? null : oldEnrollment.Date_gne__c.year(); 
    	Integer newEnrollmentYear = newEnrollment == null || newEnrollment.Date_gne__c == null ? null : newEnrollment.Date_gne__c.year(); 
    	
    	if (oldEnrollmentYear != newEnrollmentYear)
    		return true; 
    	return false; 

    }
    */

    /**
    private Boolean enrollmentNumChanged(CFAR_Actual_Enrollment_gne__c oldEnrollment,CFAR_Actual_Enrollment_gne__c newEnrollment){
        if (oldEnrollment == null || newEnrollment ==null)
            return true; 
    	if(oldEnrollment.Enrolled_Num_gne__c != newEnrollment.Enrolled_Num_gne__c)
            return true; 
        return false; 
    }
    */
    
    
    /* sets updated value for accrual with year equal to  enrollment.date.year
    * @enrollment is enrollment that triggers update on accrual.
    * Method modifies input accrual and trial.
    * If accrual is modified, method returns Accrual, otherwiese null. 
    */
    
    /**
    public static CFAR_Projected_Subject_Accrual_gne_ref__c recalculateAccrual( CFAR_Actual_Enrollment_gne__c[] trialEnrollments,CFAR_Projected_Subject_Accrual_gne_ref__c accrual,CFAR_Trial_gne__c trial ){
    	System.debug('recalculateAccrual.trialEnrollments:'+trialEnrollments);
    	if (null != accrual ){
	    		Decimal enrolledSum = 0; 
	    		for(CFAR_Actual_Enrollment_gne__c enrollment: (trialEnrollments == null ? new List<CFAR_Actual_Enrollment_gne__c>() : trialEnrollments  ) ){
	    			if(enrollment.Enrolled_Num_gne__c != null && enrollment.Date_gne__c != null && enrollment.Date_gne__c.year() == accrual.CFAR_Year_gne__c)
	    				enrolledSum = Math.max(enrolledSum, enrollment.Enrolled_Num_gne__c);
	    				//enrolledSum += enrollment.Enrolled_Num_gne__c; 
	    		}
	    		
	    		//if there is change on sum of enrollments for this year
	    		if(enrolledSum != accrual.Actual_gne__c ){
	    			accrual.Actual_gne__c = enrolledSum;
	    			if(accrual.Actual_gne__c != accrual.Projected_Accrual_gne__c)
	    				new CFAR_TrialWrapper(trial).removeFrozenDate(accrual.CFAR_Year_gne__c);
	    			else 
	    				new CFAR_TrialWrapper(trial).addFrozenDate(accrual.CFAR_Year_gne__c);
	    			return accrual; 
	    		}
    	}
    	return null; 
    }
    */
	
	/**
    public static void recalculateAccrualAndUpsert( CFAR_Actual_Enrollment_gne__c[] trialEnrollments,CFAR_Projected_Subject_Accrual_gne_ref__c accrual,CFAR_Trial_gne__c trial ){
    	CFAR_Projected_Subject_Accrual_gne_ref__c racalculatedAccrual = recalculateAccrual(trialEnrollments,accrual,trial); 
    	if (racalculatedAccrual != null)
    		upsert racalculatedAccrual; 
    }
    */
    
    public static List<CFAR_Projected_Subject_Accrual_gne_ref__c> fixCalculationsWithPriorYearsValues(CFAR_Trial_gne__c trial, List<CFAR_Projected_Subject_Accrual_gne_ref__c> trialAccruals, List<CFAR_Actual_Enrollment_gne__c> trialEnrollments) {
    	//1. populate Actuals with respective #Enrolled (max val. from Accr Enroll Rec for this year) - if there's no val. then leave as it is)
    	//2. having these values perform proper calculations
    	//3. update accruals
    	//List<CFAR_Projected_Subject_Accrual_gne_ref__c> trialAccruals = CFAR_DAO.getAccrualRelatedToTrial(String.valueOf(trial.Id));
    	//if fixing is also for 1-st value it means that we assume, that in trigger we should also put recalculations in case of changing dates!
    	//change in trigger will be needed because actual enrollments can be created before projected accruals!
    	if (trialAccruals != null && !trialAccruals.isEmpty()) {
    		for (CFAR_Projected_Subject_Accrual_gne_ref__c accrual : trialAccruals) {
    			Decimal valueToAssign = getMaxAERValueForYear(trialEnrollments, Integer.valueOf(accrual.CFAR_Year_gne__c));
    			if (valueToAssign != null) {
    				accrual.Actual_gne__c = valueToAssign;
    			}
    			else {
    				//it needs to be set so, because logic can fail if enrollment was moved to another year and there's no enrollment for initial year
    				//(accrual value would stay the same)
    				accrual.Actual_gne__c = 0;
    			}
    		}
    		
    		//fix values and manage freezing
    		Decimal sumOfPreviousActuals = 0;
    		for (CFAR_Projected_Subject_Accrual_gne_ref__c accrual : trialAccruals) {
    			if (accrual.Actual_gne__c == 0) {
    				continue;
    			}
    			accrual.Actual_gne__c = accrual.Actual_gne__c - sumOfPreviousActuals;
    			sumOfPreviousActuals += accrual.Actual_gne__c;
    		}
    		for (CFAR_Projected_Subject_Accrual_gne_ref__c accrual : trialAccruals) {
    			if(accrual.Actual_gne__c != accrual.Projected_Accrual_gne__c){
	    			new CFAR_TrialWrapper(trial).removeFrozenDate(accrual.CFAR_Year_gne__c);
    			}
	    		else {
	    			new CFAR_TrialWrapper(trial).addFrozenDate(accrual.CFAR_Year_gne__c);
	    		}
    		}
    		//update trialAccruals;
    	}
    	return trialAccruals;
    }
    
    public static Decimal getMaxAERValueForYear(CFAR_Actual_Enrollment_gne__c[] trialEnrollments, Integer year) {
    	if (trialEnrollments != null && !trialEnrollments.isEmpty()) {
    		Date startDate = Date.newInstance(year, 1, 1);
    		Date endDate = Date.newInstance(year, 12, 31);
    		//List<CFAR_Actual_Enrollment_gne__c> enrollmentsForCurrentYear = [select Id, Enrolled_Num_gne__c from CFAR_Actual_Enrollment_gne__c where CFAR_Trial_ref_gne__c = :trialId and Date_gne__c != null and Date_gne__c >= :startDate and Date_gne__c <= :endDate];
    		List<CFAR_Actual_Enrollment_gne__c> enrollmentsForCurrentYear = new List<CFAR_Actual_Enrollment_gne__c>();
    		for (CFAR_Actual_Enrollment_gne__c enrollment : trialEnrollments) {
    			if (enrollment.Enrolled_Num_gne__c != null && enrollment.Date_gne__c != null && enrollment.Date_gne__c >= startDate && enrollment.Date_gne__c <= endDate) {
    				enrollmentsForCurrentYear.add(enrollment);
    			}
    		}
    		if (!enrollmentsForCurrentYear.isEmpty()) {
    			Decimal maxVal = 0;
    			for (CFAR_Actual_Enrollment_gne__c enrollment : enrollmentsForCurrentYear) {
    				maxVal = Math.max(maxVal, enrollment.Enrolled_Num_gne__c);
    			}
    			return maxVal;
    		}
    	}
    	return null;
    }
    

}