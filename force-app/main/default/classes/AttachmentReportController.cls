public class AttachmentReportController{

  /** Results of Query */
  List<Attachment> results;
  /** Current Results based on starting postion in results list */
  List<Attachment> CurResults = new List<Attachment>() ;
  /** Current Posiiton */
  integer  CurrentPos=0;
  /** Number of lines in CurResults */
  integer  PAGE_SIZE=20;
  /** indicates if more records exist after CurResults in Results */
  public boolean  hasNext{get;set;}
  /** Indicates if more record exist before CurResults in Results */
  public boolean  hasPrev{get;set;}

  

  /**
   * Call each time page is displayed tracking current posiiton in report
   */
  public List<Attachment> getResults() {
     doSearch();
     
     return CurResults;
   }

  /**
   * Perform query to get results. Only run first time
   */
  public PageReference doSearch() {

     // Only query the first time this is run then just parse list.
     if (CurResults == null || CurResults.size() == 0)
         CurResults = [Select id, name, ownerid, owner.name, owner.profile.name, owner.userrole.name, parentid, parent.name,  Contenttype, Createddate, lastmodifieddate  from attachment order by id  LIMIT :PAGE_SIZE+1];

     hasNext= 
     hasPrev=false;
     
     if (CurResults.size() > PAGE_SIZE){
         hasNext = true;
         CurResults.Remove(PAGE_SIZE);
     }
     return null;
  }
 
   /**
    * got to previous page
    */
   public void prev(){
        if (CurResults.size() > 0){
         CurResults = [Select id, name, ownerid, owner.name, owner.profile.name, owner.userrole.name, parentid, parent.name,  Contenttype, Createddate, lastmodifieddate  from attachment where id < :CurResults[0].Id order by id LIMIT :PAGE_SIZE+1];
         if (CurResults.size() > PAGE_SIZE){
             hasPrev = true;
             CurResults.remove(PAGE_SIZE);
          }
          else
            hasPrev = false;
         }
   }
 
   /**
    * Go to next page
    */
   public void next(){
      if (CurResults.size() == PAGE_SIZE){
          hasPrev = true;
          CurResults = [Select id, name, ownerid, owner.name, owner.profile.name, owner.userrole.name, parentid, parent.name,  Contenttype, Createddate, lastmodifieddate  from attachment where id > :CurResults[PAGE_SIZE-1].Id order by id LIMIT :PAGE_SIZE+1];
          if (CurResults.size() > PAGE_SIZE){
             hasNext = true;
             CurResults.remove(PAGE_SIZE);
          }else
            hasNext = false;
      }             
   }

}