public class CADS_ViewIssues{
    public PageReference ShowList{ get; set; }

    public Static String getKeyprefix(){   
        Schema.DescribeSObjectResult sObjectDescription = CADS_Account_Address_Issues_gne__c.sObjectType.getDescribe();  
        return '/'+ sObjectDescription.keyPrefix;
    }

    PageReference pageRef = new PageReference(getKeyPrefix());
  
    public PageReference ShowList()
    {
        return pageRef;
    }
            
  /*  public PageReference openReport()
    {
         String rptURL ;
         Environment_variables__c env_list = [select key__c, value__c from environment_variables__C 
                                                 where key__c = 'DataStewardshipIssueReport'  ];
         rptURL = '//' + ApexPages.currentPage().getHeaders().get('Host') + '/' + env_list.value__c;


        PageReference pageRef1 = new PageReference(rptURL);
        return(pageRef1);
    }
    */
}