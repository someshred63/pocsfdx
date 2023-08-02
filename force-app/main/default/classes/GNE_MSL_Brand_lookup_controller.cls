public class GNE_MSL_Brand_lookup_controller{

    public string lookupID {get; set;}
    public string caseNumber {get; set;}
    public string searchName {get; set;}
    public integer recordcount {get; set;} 
    public integer flg {get; set;}
    public string patientID {get; set;}
    private boolean returnAll = false;  
    public List<Product_vod__c> products {get; set;}

    public GNE_MSL_Brand_lookup_controller()
    {
        recordcount=0;
        lookupID = System.currentPageReference().getParameters().get('lknm');
        //DoSearch();
    }

    public PageReference cont()
    {
        DoSearch();
        return null;
    }
  
    private void DoSearch() 
    {  
        recordcount=0;
        flg=0;      
        
        if (searchname == null || searchname == '')
        {  
            flg = 1;                       
            products = [select p.name from Product_vod__c p where p.Detail_Product_Subtype_Code_gne__c ='Molecule' or p.Detail_Product_Subtype_Code_gne__c ='TheraDisease' limit 50];
            recordcount = products.size();
        } 
        
        else if (searchName.length() >= 2)
        {          
            Pattern pat=Pattern.Compile('\\*');
            string srchname=pat.Matcher(searchname).replaceall('%');
            if (srchname.indexOf('%',0)==-1)
            srchname=srchname+'%';

            flg = 1;            
            products = [select p.name from Product_vod__c p where (p.Detail_Product_Subtype_Code_gne__c ='Molecule' or p.Detail_Product_Subtype_Code_gne__c ='TheraDisease' ) and p.name like :srchname limit 50];
            recordcount = products.size();
            if(recordcount ==0)
                flg=0;
        }             
    }
}