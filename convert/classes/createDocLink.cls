global  class createDocLink implements Schedulable  {
	String oldid;
    String newid;
    public createDocLink ( String oldrecid,String recid) {
        oldid = oldrecid;
        newid = recid;
    }
    global void execute(SchedulableContext sc) {
   	emailSyncToPRPEmailTracker.createContentLink(oldid, newid);
  }
}