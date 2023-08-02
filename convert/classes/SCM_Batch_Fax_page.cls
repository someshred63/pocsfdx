public class SCM_Batch_Fax_page  {

public string Product {get;set;}

public List<SelectOption> getProd()
{
  List<SelectOption> options = new List<SelectOption>();
        
   Schema.DescribeFieldResult fieldResult =
 Fax_Batch_gne__c.Product__c.getDescribe();
   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
   for( Schema.PicklistEntry f : ple)
   {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
   }       
   return options;
}
 


public pageReference CreateNew() {
	
	Fax_Batch_gne__c fb = new Fax_Batch_gne__c();
	fb.Product__c = Product;
	insert fb;
	
	return new PageReference('/' + fb.Id);
}


}