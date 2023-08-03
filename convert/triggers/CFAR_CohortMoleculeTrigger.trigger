trigger CFAR_CohortMoleculeTrigger on CFAR_Cohort_Molecule_gne__c (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        CFAR_MilestonesUtils.generateMoleculeForecast(Trigger.newMap.keySet());
    }

}