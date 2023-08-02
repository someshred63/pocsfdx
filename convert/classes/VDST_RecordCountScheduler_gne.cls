/** @date 5/20/2015
* @Author Konrad Malinowski
* @description Scheduler class for counting records in VDST custom objects
*/
global class VDST_RecordCountScheduler_gne implements Schedulable {

    /** @date 5/20/2015
    * @Author Konrad Malinowski
    * @description Overrided Schedulable interface method for executing scheduler
    * @param SchedulableContext sc
    */
    global void execute(SchedulableContext sc) {
        (new VDST_RecordCount_gne()).execute();
    }
}