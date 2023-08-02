global class GNE_MCCO_CRM_Field_Intelligence_Schedule implements Schedulable {
	
	global void execute(SchedulableContext sc){
        Database.executeBatch(new GNE_MCCO_CRM_Field_Intelligence_Batch(), 200);
    }

}