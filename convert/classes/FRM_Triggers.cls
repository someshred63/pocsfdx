/**
* Contains all trigger business logic for the FRM_Metrics_gne__c object.
*
* @author JH - houj8@gene.com
* @date Oct 4, 2012
*/
 
public without sharing class FRM_Triggers {
     private final Map<Id, FRM_Metrics_gne__c> oldMap;
     private final Map<Id, FRM_Metrics_gne__c> newMap;
     private final List<FRM_Metrics_gne__c> newObjs;
     private final Boolean isInsert;
     private final Boolean isUpdate;
     private final Boolean isDelete;
     private final Boolean isBulk;

/**
* The constructor
*
* @param xoldMap The old map from the trigger
* @param xnewObj The list of new objects from the trigger
* @param isBefore If the trigger is in before or after
*/
     public FRM_Triggers(Map<Id, FRM_Metrics_gne__c> xoldMap, List<FRM_Metrics_gne__c> xnewObjs, Boolean isBefore) {
          oldMap = xoldMap;
          newObjs = xnewObjs;

          if (!isBefore && newObjs != null) {
               newMap = new Map<Id, FRM_Metrics_gne__c>(newObjs);
          }

          isDelete = (((newObjs == null || newObjs.isEmpty()) && isBefore) || ((newMap == null || newMap.isEmpty()) && !isBefore));
          isUpdate = ! (isDelete || oldMap == null || oldMap.isEmpty());
          isInsert = ! (isDelete || isUpdate);
          isBulk = (newObjs != null && newObjs.size() > 1) ? true : false;
     }
/**
* FRM Territory target metric values
* JH - 10/4/2012
* 
* Before Update, Before Insert and target metrics population from
* FRM_Metrics_Goal_gne__c table
*
* Updates:
* JH - 3/2013 - GSR644: Metric changes and addition of Territories factored into color coding
*/
    public void updateMetricTargets() {    
        // Routing
        if ( isUpdate || isInsert || isBulk ) {
            // Getting a map of team/territory to their respective goals where Name is the key later used (goalName)
            Map<String, FRM_Metrics_Goal_gne__c> goalMap = new Map<String, FRM_Metrics_Goal_gne__c>();
            
            for ( FRM_Metrics_Goal_gne__c obj : [Select Name, TAT_gne__c, TAT_Oral_gne__c, MPS_Utilization_gne__c, Enrollment_Complete_gne__c 
                                                 From FRM_Metrics_Goal_gne__c] ) {
                goalMap.put(obj.Name, obj);
            }
system.debug( 'updateMetricTargets goalMap keySet(): '+ goalMap.keyset());
            
            for ( FRM_Metrics_gne__c frm: newObjs ) {
                integer targetMissed = 0;
                string goalName = frm.FRM_Team_gne__c + '_' + frm.Territory_Name_gne__c;
                string frmTeam = frm.FRM_Team_gne__c;
                decimal oralGoal = null;
                boolean misalignedTerr = (goalMap.get(goalName) == null) ? true : false;
                
system.debug( 'updateMetricTargets goalName: ' + goalName );
system.debug( 'updateMetricTargets misalignedTerr: ' + misalignedTerr );       
                
                /*
                JH - GSR644 - obsoleted for territory dependent goal(s)
                decimal asiTarget = FRM_Metric_Targets__c.getInstance(frmTeam).ASI_Growth__c;
                decimal smnTarget = FRM_Metric_Targets__c.getInstance(frmTeam).SMN_Completion_Rate__c;
                decimal caseTarget = FRM_Metric_Targets__c.getInstance(frmTeam).Case_TAT__c;
                */       
                // Use map of FRM Metrics Goal
                decimal caseGoal = misalignedTerr ? 0 : goalMap.get(goalName).TAT_gne__c;
                if ( frmTeam == 'BFRM' ) {
                    oralGoal = misalignedTerr ? 0 : goalMap.get(goalName).TAT_Oral_gne__c;
                }
                decimal completionGoal = misalignedTerr ? 0 : goalMap.get(goalName).Enrollment_Complete_gne__c;
                decimal mpsGoal = misalignedTerr ? 0 : goalMap.get(goalName).MPS_Utilization_gne__c;
                
                /* JH 10/11/12 - PFS-303
                   JH - GSR644 - updated for territory dependent goal(s)
                // Higher is better     
                if(frm.ASI_Growth_gne__c < asiTarget) {
                    targetMissed++;
                }
                // Lower is better
                if(frm.Case_TAT_Improvement_gne__c > caseTarget) {
                    targetMissed++;
                }
                // Higher is better
                if(frm.SMN_Completion_Rate_gne__c < smnTarget) {
                    targetMissed++;
                }*/
                
                if ( !misalignedTerr ) {
                    if ( frmTeam != 'BFRM' ) {
                        if ( frm.Case_TAT_Improvement_gne__c > caseGoal )
                           targetMissed++;
                    } else {
                        if ( frm.Case_TAT_Improvement_gne__c > caseGoal || frm.Case_TAT_Oral_gne__c > oralGoal )
                           targetMissed++;
                    }
                    if ( frm.SMN_Completion_Rate_gne__c < completionGoal )
                        targetMissed++;
                    if ( frm.MPS_Utilization_gne__c < mpsGoal )
                        targetMissed++;
                    // Set Colors
                    if ( targetMissed > 1 ) {
                        frm.Color_Code_gne__c = 'Red';
                    } else if ( targetMissed == 1 ) {
                        frm.Color_Code_gne__c = 'Yellow';
                    } else if ( targetMissed == 0 ) {
                        frm.Color_Code_gne__c = 'Green';
                    }   
                } else {
                    frm.Color_Code_gne__c = 'Red';
                }                   
            }
        // End routing   
        } else {
        return;
        }
        
    }
    
/**
* Method to initiate trigger logic
*
* @param oldMap The old map from the trigger
* @param newObj The list of new objects from the trigger
* @param isBefore If the trigger is in before or after
*/
     public static void processTrigger(Map<Id, FRM_Metrics_gne__c> oldMap, List<FRM_Metrics_gne__c> newObj, Boolean isBefore) {
          final FRM_Triggers myTrigger = new FRM_Triggers(oldMap, newObj, isBefore);

          if (isBefore) {
               myTrigger.updateMetricTargets();
          }
     }
}