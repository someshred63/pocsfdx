public class SCM_Lookup_Case {
//the string to use in the search    
public string SearchString {
      get { return SearchString; }
      set { SearchString = value; }
   }
  //Case list of found cases
   public List<Case> Results {
      get { return Results; }
      set { Results = value; }
   }
   
//method to use the search string to populate the case list
    Public void Lookup() {
    List<case> Cas;
  	string str = SearchString;//pageRef.getParameters().get('searchvalue'); //+ '*';
        // check to see if the string is nothing
                if (str == '') {
        	str = '%';
        	     	}
    //convert the * to % so the database can query correctly
    str = str.replace('*','%');
    
    Cas = [Select Case_Treating_Physician_gne__c, RecordTypeId, Status, Product_gne__c, Patient_gne__r.Name, Foundation_Specialist_gne__r.Name,Date_Enrolled_gne__c, Case_Manager__r.Name, CaseNumber,case_referral_reason_gne__c From Case  where Casenumber Like :str order by systemmodstamp desc limit 20];
   //populate case list
    Results =  Cas;
    
    }
public static testmethod void mytest() {
SCM_Lookup_Case c = New SCM_Lookup_Case();
c.searchstring = '*';
c.lookup();
}
  }