public class CFAR_MilestonesUtils{


    public static Map<String, String> maTypeToTrialStatus = new Map<String, String> {
        'Proposal Approval' => Label.CFAR_GSTARS_TRIAL_STATUS_PROPOSAL_APPROVED,
        'SRT Protocol Approval' => Label.CFAR_GSTARS_TRIAL_STATUS_PROTOCOL_APPROVED,
        'Activation' => Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_ENROLLMENT,
        'LPI' => Label.CFAR_GSTARS_TRIAL_STATUS_COMPLETED_ENROLLMENT,
        'LPO' => Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_PUBLICATION,
		'FSR' => Label.CFAR_GSTARS_TRIAL_STATUS_CLOSURE_PENDING
    };

    /* finds trials with cfar start / end dates changed  
     * method used in Trial trigger - before update 
     * changes can be triggered by user changes on milestones activities, or modification of number of months on trial. 
     */ 
    public static void handleTrialsChange(Map<id,CFAR_Trial_gne__c> oldTrialMap, Map<id,CFAR_Trial_gne__c> newTrialMap){
        Map<id,CFAR_Trial_gne__c> trialsWithYearsStartOrEndDateChanged = getTrialsWithYearsStartOrEndDateChanged( oldTrialMap, newTrialMap);
        Map<String, Map<String,List<sObject> > >trialId2Year2Accruals = generateTrialId2Year2Accruals(trialsWithYearsStartOrEndDateChanged); 
        Map<String,List<CFAR_Actual_Enrollment_gne__c>> trialId2Enrollments = CFAR_Utils.sObjectListToFieldToSobjectMap( CFAR_DAO.getTrialsActualEnrollments(CFAR_Utils.setToList(newTrialMap.keySet())) ,'CFAR_Trial_ref_gne__c' );
        CFAR_Projected_Subject_Accrual_gne_ref__c[] accrualsToBeCreated = createMissingAccrualsForTrials(trialsWithYearsStartOrEndDateChanged,trialId2Year2Accruals,trialId2Enrollments );
        CFAR_Projected_Subject_Accrual_gne_ref__c[] accrualsToBeDeleted = findAccrualsToBeDeletedForTrials(trialsWithYearsStartOrEndDateChanged,trialId2Year2Accruals );
        updateTrialsFrozenAccrualDates(newTrialMap, accrualsToBeCreated, accrualsToBeDeleted); 
        
        CFAR_Utils.logError('accrualsToBeCreated,will be inserted '+accrualsToBeCreated);
        CFAR_Utils.logError('accrualsToBeCreated,will be deleted '+accrualsToBeDeleted );
        //upsert accrualsToBeCreated;
        insert accrualsToBeCreated;
        CFAR_SecurityUtils.deleteRecords(accrualsToBeDeleted);
        
        //CFAR_Utils.setAlreadyProcessed();

		for (CFAR_Trial_gne__c trial: newTrialMap.Values())
		{
			system.debug('trial.Frozen_Accruals_JSON_gne__c: ' + trial.Frozen_Accruals_JSON_gne__c);
		}
		
		//recalculate and freeze/unfreeze for all
		fixCalculationsWithPriorYearsValuesMultipleTrials(trialsWithYearsStartOrEndDateChanged, trialId2Enrollments);		
    }
    
    public static void fixCalculationsWithPriorYearsValuesMultipleTrials(Map<Id,CFAR_Trial_gne__c> trials, Map<String,List<CFAR_Actual_Enrollment_gne__c>> trialIdInString2Enrollments) {
    	if (trials != null && !trials.isEmpty()) {
    		//build map trialIdToAccruals, accruals should be ordered by year asc for proper calculations
    		List<CFAR_Projected_Subject_Accrual_gne_ref__c> accruals = [select Projected_Accrual_gne__c, Actual_gne__c, Name, CFAR_Trial_ref_gne__c, Id, CFAR_Year_gne__c, Trials_Frozen_Accrual_Years_JSON_gne__c 
    																	from CFAR_Projected_Subject_Accrual_gne_ref__c
    																	where CFAR_Trial_ref_gne__c IN :trials.keySet()
    																	order by CFAR_Year_gne__c asc];
    		if (!accruals.isEmpty()) {
    			//convert trialIdInString2Enrollments map so that keys are Ids, not Strings
    			Map<Id, List<CFAR_Actual_Enrollment_gne__c>> trialIdInId2Enrollments = new Map<Id, List<CFAR_Actual_Enrollment_gne__c>>();
    			for (String idInString : trialIdInString2Enrollments.keySet()) {
    				trialIdInId2Enrollments.put(Id.valueOf(idInString), trialIdInString2Enrollments.get(idInString));
    			}
    			Map<Id, List<CFAR_Projected_Subject_Accrual_gne_ref__c>> trialIdToAccruals = new Map<Id, List<CFAR_Projected_Subject_Accrual_gne_ref__c>>();
    			for (CFAR_Projected_Subject_Accrual_gne_ref__c accrual : accruals) {
    				List<CFAR_Projected_Subject_Accrual_gne_ref__c> psa = trialIdToAccruals.get(accrual.CFAR_Trial_ref_gne__c);
    				if (psa == null) {
    					trialIdToAccruals.put(accrual.CFAR_Trial_ref_gne__c, new List<CFAR_Projected_Subject_Accrual_gne_ref__c> {accrual});
    				}
    				else {
    					psa.add(accrual);
    				}
    			}
    			//perform calculation for every trial with accruals
    			for (Id trialId : trialIdToAccruals.keySet()) {
    				CFAR_EnrollmentHandler.fixCalculationsWithPriorYearsValues(trials.get(trialId), trialIdToAccruals.get(trialId), trialIdInId2Enrollments.get(trialId));
    			}
    			//update trialIdToAccruals.values(); //it's list of lists... we can simply make update on list "accruals", initially taken from DB
    			update accruals;
    		}
    	}
    }
    
    public static void handleNumOfMonthsChanged(Map<id, CFAR_Trial_gne__c> oldTrialMap, Map<id, CFAR_Trial_gne__c> newTrialMap) {

        Map<id, CFAR_Trial_gne__c> trialsWithNumOfMonthsChanged = getTrialsWithNumOfMonthsChanged( oldTrialMap, newTrialMap);

        if (!trialsWithNumOfMonthsChanged.isEmpty()) {
            List<CFAR_Milestone_Activity_gne__c> milestoneActivities = [SELECT CFAR_Trial_ref_gne__c, Planned_Date_gne__c FROM CFAR_Milestone_Activity_gne__c
            WHERE CFAR_Trial_ref_gne__c IN :trialsWithNumOfMonthsChanged.keySet() AND Name = 'LPI' AND Planned_Date_gne__c = null];

            if (!milestoneActivities.isEmpty()) {
                for (CFAR_Milestone_Activity_gne__c ma : milestoneActivities) {
                    Date startDate = trialsWithNumOfMonthsChanged.get(ma.CFAR_Trial_ref_gne__c).CFAR_Enrollment_Start_Date_gne__c;
                    if (startDate != null && trialsWithNumOfMonthsChanged.get(ma.CFAR_Trial_ref_gne__c).Number_Of_Months_Of_Enrollment__c != null) {
                        ma.Planned_Date_gne__c = startDate.addMonths(Integer.valueOf(trialsWithNumOfMonthsChanged.get(ma.CFAR_Trial_ref_gne__c).Number_Of_Months_Of_Enrollment__c));
                    }
                }
                CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_MilestoneActivityTrigger'});
                update milestoneActivities;
                CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {});
            }
        }
    }

    /*
    *modifies @trialMap. Latest requirements specify that change of trial can only remove frozen accruals from trial . 
    */
	private static void updateTrialsFrozenAccrualDates(Map<id,CFAR_Trial_gne__c> trialMap, CFAR_Projected_Subject_Accrual_gne_ref__c[] accrualsToBeCreated , CFAR_Projected_Subject_Accrual_gne_ref__c[] accrualsToBeDeleted  ){
		System.debug('updateTrialsFrozenAccrualDates start: \n'+
		 ' trialMap:  '+trialMap +
		 ' \n accrualsToBeCreated:  '+accrualsToBeCreated+
		 ' \n accrualsToBeDeleted: '+accrualsToBeDeleted  ); 
		
		//remove Frozen Dates
		for (CFAR_Projected_Subject_Accrual_gne_ref__c accrToDel: accrualsToBeDeleted){
			Decimal year = accrToDel.CFAR_Year_gne__c; 
			CFAR_TrialWrapper trialWrapper = new CFAR_TrialWrapper(trialMap.get(accrToDel.CFAR_Trial_ref_gne__c)); 
			trialWrapper.removeFrozenDate(year);
		}

	}
    
    /* adds new accruals once Enrollment Start or End date is changed and new accruals should be created()
     * method used in Trial trigger 
     */
	public static CFAR_Projected_Subject_Accrual_gne_ref__c[] createMissingAccrualsForTrials(Map<id,CFAR_Trial_gne__c> trials, Map<String, Map<String,List<sObject>>> trialId2Year2Accruals,Map<String,List<sObject>> trialId2Enrollments){
        CFAR_Projected_Subject_Accrual_gne_ref__c[] accrualsToBeCreated = new List<CFAR_Projected_Subject_Accrual_gne_ref__c>();         
		
        for(CFAR_Trial_gne__c trial : trials.values() ) {
        	
        	//year2enrollments mapping for a certain trial 
        	Map<String,List<CFAR_Actual_Enrollment_gne__c>> year2Enrollments=getYear2Enrollments( (List<CFAR_Actual_Enrollment_gne__c>)trialId2Enrollments.get(trial.id)); 
        	
        	accrualsToBeCreated.addAll(updateAccrualsForYears(trial, trialId2Year2Accruals.get(trial.id),year2Enrollments) ); 
        }
        return accrualsToBeCreated;
    }
    
    private static Map<String,List<CFAR_Actual_Enrollment_gne__c>> getYear2Enrollments(List<CFAR_Actual_Enrollment_gne__c>enrollments){
    	Map<String,List<CFAR_Actual_Enrollment_gne__c>> year2enrollments = new Map<String,List<CFAR_Actual_Enrollment_gne__c>>();
    	if (null != enrollments){
	    	for (CFAR_Actual_Enrollment_gne__c e: enrollments){
	    		Date eDate = e.Date_gne__c; 
	    		String year = eDate == null ? '' : String.valueof(eDate.year());
	    		if (year2enrollments.get(year) == null){
	    			year2enrollments.put(year,new List<CFAR_Actual_Enrollment_gne__c>()); 
	    		}
	    		year2enrollments.get(year).add(e); 
	    	}
    	}
    	return year2enrollments; 
    }

	public static CFAR_Projected_Subject_Accrual_gne_ref__c[] findAccrualsToBeDeletedForTrials(Map<id,CFAR_Trial_gne__c> trials, Map<String, Map<String,List<sObject>>> trialId2Year2Accruals){
        CFAR_Projected_Subject_Accrual_gne_ref__c[] accrualsToBeDeleted = new List<CFAR_Projected_Subject_Accrual_gne_ref__c>();

        for(CFAR_Trial_gne__c trial : trials.values() ) {
        	accrualsToBeDeleted.addAll(findAccrualsToBeDeletedForTrial(trial, trialId2Year2Accruals.get(trial.id))); 
        }
        return accrualsToBeDeleted;
    }


//@existingAccrualsMap - map from Year to Accruals 
public static CFAR_Projected_Subject_Accrual_gne_ref__c[] findAccrualsToBeDeletedForTrial( CFAR_Trial_gne__c trial, Map<String,List<sObject>> existingAccrualsMap  ){
	System.debug('findAccrualsToBeDeletedForTrial.existingAccrualsMap: ' + existingAccrualsMap);
	List<CFAR_Projected_Subject_Accrual_gne_ref__c> retAccruals = new List<CFAR_Projected_Subject_Accrual_gne_ref__c>();  
    	Integer startYear = trial.CFAR_Enrollment_Start_Date_gne__c != null ? trial.CFAR_Enrollment_Start_Date_gne__c.Year() : null; 
    	Integer endYear = 	trial.CFAR_Enrollment_End_Date_gne__c   != null ? trial.CFAR_Enrollment_End_Date_gne__c.Year() 	: null; 	
    	
    	if (null != startYear && null != endYear && null != existingAccrualsMap) {
	    	for(String year: existingAccrualsMap.keySet()){
	    		if ( Integer.valueOf(Year) < startYear || Integer.valueOf(Year) > endYear) {
	    			sObject[] accruals = existingAccrualsMap.get(year);
	    			if (null == accruals){
	    				//TODO throw exception? - such situation should not happen
	    			} else if(accruals.size() == 1){
	    				retAccruals.add((CFAR_Projected_Subject_Accrual_gne_ref__c)accruals[0] );
	    			} else {
	    				//TODO throw exception? - such situation should not happen
	    			}
    			}
	    	}
    	}
    	
        return retAccruals; 
}

/* updates all accruals related to @trial
*  @existingAccrualsMap - year to accrual for a certain trial
*
*  27.03.2014 Slawomir Brejwo: change method so that it returns only accruals to be created (without calculating them)
*  Calculations for all accruals referring to trials with dates changed would be performed by fixCalculationsWithPriorYearsValuesMultipleTrials method
*/ 
public static CFAR_Projected_Subject_Accrual_gne_ref__c[] updateAccrualsForYears( CFAR_Trial_gne__c trial, Map<String,List<CFAR_Projected_Subject_Accrual_gne_ref__c>> existingAccrualsMap,Map<String,List<CFAR_Actual_Enrollment_gne__c>> year2Enrollments  ){
        System.debug('updateAccrualsForYears.trial: ' + trial);
        System.debug('updateAccrualsForYears.existingAccrualsMap: ' + existingAccrualsMap);
           
    	List<CFAR_Projected_Subject_Accrual_gne_ref__c> retAccruals = new List<CFAR_Projected_Subject_Accrual_gne_ref__c>();
    	Integer startYear = trial.CFAR_Enrollment_Start_Date_gne__c != null ? trial.CFAR_Enrollment_Start_Date_gne__c.Year() : null;
    	Integer endYear = 	trial.CFAR_Enrollment_End_Date_gne__c   != null ? trial.CFAR_Enrollment_End_Date_gne__c.Year() 	: null;
    	
    	if (null != startYear && null != endYear ) {
        	 	for (Integer year = startYear ; year <= endYear ; year++ ){
    	 			
    	 			List<CFAR_Actual_Enrollment_gne__c>yearEnrollments = year2Enrollments.get(String.valueOf(year));
        	 		
        	 		if (null == existingAccrualsMap || null == existingAccrualsMap.get(String.valueOf(year))) {
    	 				CFAR_Projected_Subject_Accrual_gne_ref__c newAccrual = new CFAR_Projected_Subject_Accrual_gne_ref__c(CFAR_Trial_ref_gne__c = trial.id,CFAR_Year_gne__c = year ); 
        	 			//CFAR_EnrollmentHandler.recalculateAccrual( yearEnrollments , newAccrual, trial); 
        	 			retAccruals.add( newAccrual );
        	 		}
        	 		/**
        	 		else {
        	 			CFAR_Projected_Subject_Accrual_gne_ref__c existingAccrual = existingAccrualsMap.get(String.valueOf(year))[0];
        	 			if (null!=CFAR_EnrollmentHandler.recalculateAccrual( yearEnrollments , existingAccrual, trial)) 
        	 				retAccruals.add( existingAccrual );
        	 		}
        	 		*/
        	 			
        	 	}
        }
        return retAccruals; 
    }
    
    
    


/*queries for all accrauls related to @trials and returns Map<String(trial identifier) => Map<String(accrual year) => Accrual > > 
*
*/  
//TODO change return type to Map<String, Map<String,CFAR_Projected_Subject_Accrual_gne_ref__c >>
public static Map<String, Map<String,List<sObject>>> generateTrialId2Year2Accruals(Map<id,CFAR_Trial_gne__c> trials){
        List<String> trialIds = CFAR_Utils.convertIdSet2IdList( trials.keyset() ) ; 
        
        CFAR_Projected_Subject_Accrual_gne_ref__c[] allRelatedAccruals = CFAR_DAO.getAccrualRelatedToTrials( trialIds); 
        
        System.debug('generateTrialId2Year2Accruals.allRelatedAccruals: ' + allRelatedAccruals);
        
        Map<String,List<sObject>> trialId2Accruals = CFAR_Utils.sObjectListToFieldToSobjectMap((List<sObject>)allRelatedAccruals,'CFAR_Trial_ref_gne__c');
        System.debug('generateTrialId2Year2Accruals.trialId2Accruals: ' + trialId2Accruals);
        
        Map<String, Map<String,List<sObject>>> trialId2Year2Accruals=new Map<String, Map<String,List<sObject>>> ();
        String debugStr = '';  
        
        for(String trialId : trialId2Accruals.keySet() ){
        	System.debug('trialId in the loop: ' + trialId);
        	
        	List<sObject> trialAccruals = trialId2Accruals.get(trialId);
    		if (null == trialId2Year2Accruals.get(trialId)){
    			trialId2Year2Accruals.put(trialId,new Map<String,List<sObject> >() );
    		}
    		
    		Map<String,List<sObject>> trialYears2Accruals = trialId2Year2Accruals.get(trialId); 
        	debugStr += '\n trialId: ' + trialId; 
        	trialYears2Accruals.putAll( CFAR_Utils.sObjectListToFieldToSobjectMap( (List<sObject>)trialAccruals,'CFAR_Year_gne__c') );
        	debugStr += '\n accrual: ' + trialYears2Accruals.Values(); 
        }
        
        System.debug('generateTrialId2Year2Accruals'+debugStr); 
		
		return trialId2Year2Accruals; 
}

    /*finds trials with cfar start / end dates are changed 
     * method used in Trial trigger 
    */ 
    public static Map<id,CFAR_Trial_gne__c> getTrialsWithYearsStartOrEndDateChanged(Map<id,CFAR_Trial_gne__c> oldTrialMap, Map<id,CFAR_Trial_gne__c> newTrialMap){
    
        if (null == oldTrialMap){
            return newTrialMap; 
        }
        
        Map<id,CFAR_Trial_gne__c> trialsWithYearsStartOrEndDateChanged = new Map<id,CFAR_Trial_gne__c>();
        
        for(CFAR_Trial_gne__c newTrial :newTrialMap.values()){
        	
            CFAR_Trial_gne__c oldTrial = oldTrialMap.get(newTrial.id);
			system.debug('getTrialsWithYearsStartOrEndDateChanged: '+ 
							'\n  oldTrial.CFAR_Enrollment_Start_Date_gne__c: ' + oldTrial.CFAR_Enrollment_Start_Date_gne__c +
							'\n  newTrial.CFAR_Enrollment_Start_Date_gne__c: ' + newTrial.CFAR_Enrollment_Start_Date_gne__c +
							'\n  oldTrial.CFAR_Enrollment_End_Date_gne__c: ' + oldTrial.CFAR_Enrollment_End_Date_gne__c +
							'\n  newTrial.CFAR_Enrollment_End_Date_gne__c: ' + newTrial.CFAR_Enrollment_End_Date_gne__c 
							);        	
            
            if (null == oldTrial) {
                trialsWithYearsStartOrEndDateChanged.put(newTrial.id,newTrial);
            }
            else{
            	if(	null == oldTrial.CFAR_Enrollment_Start_Date_gne__c && 
            		null == newTrial.CFAR_Enrollment_Start_Date_gne__c &&
            		null == oldTrial.CFAR_Enrollment_End_Date_gne__c && 
            		null == newTrial.CFAR_Enrollment_End_Date_gne__c )
            		continue; 	
            	
            	if(null == oldTrial.CFAR_Enrollment_Start_Date_gne__c )
            	{
            		if(null == newTrial.CFAR_Enrollment_Start_Date_gne__c)
		            	continue;
		            else{
			            trialsWithYearsStartOrEndDateChanged.put(newTrial.id,newTrial);
			         	continue;    
		            }
            	}
            	if(null == oldTrial.CFAR_Enrollment_End_Date_gne__c )
            	{
            		if(null == newTrial.CFAR_Enrollment_End_Date_gne__c)
		            	continue;
		            else{
			            trialsWithYearsStartOrEndDateChanged.put(newTrial.id,newTrial);
			         	continue;    
		            }
            	}
				
				//TODO remove assert
				/*System.assert(
					null != newTrial.CFAR_Enrollment_Start_Date_gne__c && 
	                null != oldTrial.CFAR_Enrollment_Start_Date_gne__c &&
	                null != newTrial.CFAR_Enrollment_End_Date_gne__c && 
	                null != oldTrial.CFAR_Enrollment_End_Date_gne__c
				);*/
            	
            	/*
                if  ( newTrial.CFAR_Enrollment_Start_Date_gne__c.year() 	!= oldTrial.CFAR_Enrollment_Start_Date_gne__c.year() ||
                      newTrial.CFAR_Enrollment_End_Date_gne__c.year() 	!= oldTrial.CFAR_Enrollment_End_Date_gne__c.year() )
                    {
                        trialsWithYearsStartOrEndDateChanged.put(newTrial.id,newTrial);
                    }
                    */
                if  ( newTrial.CFAR_Enrollment_Start_Date_gne__c 	!= oldTrial.CFAR_Enrollment_Start_Date_gne__c ||
                      newTrial.CFAR_Enrollment_End_Date_gne__c 	!= oldTrial.CFAR_Enrollment_End_Date_gne__c )
                    {
                        trialsWithYearsStartOrEndDateChanged.put(newTrial.id,newTrial);
                    }
            }
        }
        System.debug('trialsWithYearsStartOrEndDateChanged: ' + trialsWithYearsStartOrEndDateChanged );
        return trialsWithYearsStartOrEndDateChanged ; 
    }
    
    public static Map<id,CFAR_Trial_gne__c> getTrialsWithNumOfMonthsChanged(Map<id,CFAR_Trial_gne__c> oldTrialMap, Map<id,CFAR_Trial_gne__c> newTrialMap){
    
        if (null == oldTrialMap){
            return newTrialMap; 
        }
        
        Map<id,CFAR_Trial_gne__c> trialsWithNumOfMonthsChanged = new Map<id,CFAR_Trial_gne__c>();
        
        for(CFAR_Trial_gne__c newTrial :newTrialMap.values()){
        	
            CFAR_Trial_gne__c oldTrial = oldTrialMap.get(newTrial.id);       	
            
            if (null == oldTrial) {
                trialsWithNumOfMonthsChanged.put(newTrial.id,newTrial);
            }
            else{
            	if(	null == oldTrial.Number_Of_Months_Of_Enrollment__c && 
            		null == newTrial.Number_Of_Months_Of_Enrollment__c)
            		continue; 	
            	
            	if(null == oldTrial.Number_Of_Months_Of_Enrollment__c )
            	{
            		if(null == newTrial.Number_Of_Months_Of_Enrollment__c)
		            	continue;
		            else{
			            trialsWithNumOfMonthsChanged.put(newTrial.id,newTrial);
			         	continue;    
		            }
            	}
            	
            	 if  ( newTrial.Number_Of_Months_Of_Enrollment__c 	!= oldTrial.Number_Of_Months_Of_Enrollment__c )
                    {
                        trialsWithNumOfMonthsChanged.put(newTrial.id,newTrial);
                    }
            }
        }
        System.debug('trialsWithNumOfMonthsChanged: ' + trialsWithNumOfMonthsChanged );
        return trialsWithNumOfMonthsChanged ; 
    }

	public static void handleGenerateDrugSupplyForecasts(Map<Id,CFAR_Trial_gne__c> oldTrialMap, Map<Id,CFAR_Trial_gne__c> newTrialMap){
		Set<Id> trialIds = new Set<Id>();
		Set<Id> cohortIds = new Set<Id>();
		for(Id trialId : newTrialMap.keySet()) {
			if(oldTrialMap.get(trialId).Drug_Supply_Generate_Forecasts_Date__c == null
                    && newTrialMap.get(trialId).Drug_Supply_Generate_Forecasts_Date__c != null)
			{
				trialIds.add(trialId);
			}
		}
        Map<Id, CFAR_Trial_gne__c> trials = CFAR_Cohort_Molecule_DAO.fetchTrialsForClinicalReport(trialIds);
        for(CFAR_Trial_gne__c trial : trials.values()) {
            for(CFAR_Cohort_gne__c cohort : trial.gSTARS_Cohorts__r) {
				cohortIds.add(cohort.Id);
			}
        }
		List<CFAR_Cohort_Molecule_gne__c> molecules = CFAR_Cohort_Molecule_DAO.fetchCohortMoleculeForGenerateForecasts(cohortIds);

        List<CFAR_Cohort_Molecule_gne__c> moleculeToUpdate = new List<CFAR_Cohort_Molecule_gne__c>();
        Map<CFAR_Cohort_Molecule_gne__c, Map<String, Integer>> moleculeForecasts = generateMoleculeForecasts(trials, molecules);

        for(CFAR_Cohort_Molecule_gne__c molecule : moleculeForecasts.keySet()) {
            molecule.Generated_Forecasts__c = JSON.serialize(moleculeForecasts.get(molecule));
            moleculeToUpdate.add(molecule);
        }

        if(!moleculeToUpdate.isEmpty()) {
            CFAR_SecurityUtils.updateRecords(moleculeToUpdate);
        }
	}

	public static void generateMoleculeForecast(Set<Id> moleculesIds){
		List<CFAR_Cohort_Molecule_gne__c> molecules = CFAR_Cohort_Molecule_DAO.fetchCohortMoleculeForForecasts(moleculesIds);
		Set<Id> trialIds = new Set<Id>();
		for(CFAR_Cohort_Molecule_gne__c mol : molecules){
			trialIds.add(mol.Cohort_ref_gne__r.Trial_ref_gne__c);
		}
		Map<Id, CFAR_Trial_gne__c> trials = CFAR_Cohort_Molecule_DAO.fetchTrialsForClinicalReport(trialIds);
		Map<CFAR_Cohort_Molecule_gne__c, Map<String, Integer>> moleculeForecasts = generateMoleculeForecasts(trials, molecules);
		List<CFAR_Cohort_Molecule_gne__c> toUpdate = new List<CFAR_Cohort_Molecule_gne__c>();
		for(CFAR_Cohort_Molecule_gne__c molecule : moleculeForecasts.keySet()) {
			molecule.Generated_Forecasts__c = JSON.serialize(moleculeForecasts.get(molecule));
			toUpdate.add(molecule);
		}
		if(!toUpdate.isEmpty()) {
			CFAR_SecurityUtils.updateRecords(toUpdate);
		}
	}

    private static Map<CFAR_Cohort_Molecule_gne__c, Map<String, Integer>> generateMoleculeForecasts(Map<Id, CFAR_Trial_gne__c> id2Trial, List<CFAR_Cohort_Molecule_gne__c> cohortMoleculeList)
    {
        Map<CFAR_Cohort_Molecule_gne__c, Map<String, Integer>> moleculeForecasts =
                new Map<CFAR_Cohort_Molecule_gne__c, Map<String, Integer>>();
        List<CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper> wrappers = new List<CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper>();

        for(CFAR_Cohort_Molecule_gne__c cm : cohortMoleculeList) {
            CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper wrapper =
                    new CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper(cm, id2Trial.get(cm.Cohort_ref_gne__r.Trial_ref_gne__c));
            CFAR_ClinicalSupplyReport_DataModel.fillAllWrapperVariables(wrapper);
            moleculeForecasts.put(cm, CFAR_ClinicalSupplyReport_DataModel.fetchForecasts(wrapper));
        }
        return moleculeForecasts;
    }

}