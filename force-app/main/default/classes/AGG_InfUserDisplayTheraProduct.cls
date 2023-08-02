public class AGG_InfUserDisplayTheraProduct 
{
    /*##################################################
    #Project Name           : Genentec - Infrequent Users Search
    # File                  : AGG_InfUserDisplayTheraProduct.cls
    # Version               : 1.0 
    # Created by            : <<Sandeep Kumar>> 
    # Created Date          : <<19 Nov 09>> 
    # Last Modified by      : <<Sandeep Kumar>> 
    # Last Modified Date    : <<19 Nov 09>> 
    # Description           : <<This is the controller class for Infrequent User Search that searches Therapeautic Products>>  
    #  
    # 
    ##################################################*/
    
    Product_vod__c objProductCatalog;
    List<Product_vod__c> lstProductCatalog = new List<Product_vod__c>();
    List<Therapeutic_Area_Code_gne__c> lstTheraArea = new List<Therapeutic_Area_Code_gne__c>();
    List<Disease_Indication_gne__c> lstDiseaseIndication = new List<Disease_Indication_gne__c>();
    List<Product_vod__c> ProdcatalogTheraArea = new List<Product_vod__c>();//Added by chaitanya
    List<Product_vod__c> ProdcatalogDiseaseIndication = new List<Product_vod__c>();//Added by chaitanya
    public String sErrMessage{get; set;}
    public String sSelectedProductId{get; set;}
    public String sProductAddName{get; set;}
    public String sProductAddNameType{get; set;}
    public String sProductButtonName{get; set;}
    public String sProductTheraArea{get; set;}
    public String sProductTheraIndication{get; set;}
    public String sNonCommProductId{get; set;}
    public String sProductNonCommercial{get; set;}
    
    
    public String sTheraArea{get; set;}
    public String sTheraBrand{get; set;}
    
    
    public AGG_InfUserDisplayTheraProduct()
    {
        
    }
    public AGG_InfUserDisplayTheraProduct(ApexPages.StandardController stdController)
    {
        //names of input Text fields in calling form pased as parameter values. 
        //These names will be referenced from called form to post values back to parent/called form
        if(System.currentPageReference().getParameters().get('hcpname')!=null )
        {
            sProductAddName=System.currentPageReference().getParameters().get('hcpname');
        }
        if(System.currentPageReference().getParameters().get('hcpnametype')!=null )
        {
            sProductAddNameType=System.currentPageReference().getParameters().get('hcpnametype');
        }
        if(System.currentPageReference().getParameters().get('hcpbutton')!=null )
        {
            sProductButtonName=System.currentPageReference().getParameters().get('hcpbutton');
        }
        if(System.currentPageReference().getParameters().get('hcptheraArea')!=null )
        {
            sProductTheraArea=System.currentPageReference().getParameters().get('hcptheraArea');
        }
        if(System.currentPageReference().getParameters().get('hcptheraIndication')!=null )
        {
            sProductTheraIndication=System.currentPageReference().getParameters().get('hcptheraIndication');
        }
        
        //lstProductCatalog=[SELECT Id, Name, Product_Code_gne__c, Product_Type_vod__c, GNE_Part_Number_gne__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c FROM Product_Vod__c WHERE Product_Type_vod__c='Market' order BY Name ];
        try
        {
            lstProductCatalog=[SELECT Id, Name, Product_Code_gne__c, Product_Type_vod__c, GNE_Part_Number_gne__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c FROM Product_Vod__c WHERE Product_Type_vod__c='Detail' and Name Like 'Non-Commercial%' order by Name ];
        }
        catch(Exception ex)
        {
            //do nothing
        }
        if(lstProductCatalog!=null && lstProductCatalog.size()>0)
        {
            sNonCommProductId=lstProductCatalog[0].Id;
            sProductNonCommercial=lstProductCatalog[0].Name;
        }
        lstTheraArea=[SELECT ID, Name, Reference_List__c, Code__c, Description__c FROM Therapeutic_Area_Code_gne__c];
        
        lstDiseaseIndication=[SELECT ID, Name, Reference_List__c, Code__c, Description__c FROM Disease_Indication_gne__c];
        
        ProdcatalogTheraArea = [Select Name,p.Detail_Product_Subtype_Code_gne__c,p.Therapeutic_Area_vod__c from Product_vod__c p  where Product_Type_vod__c = 'Detail' and Detail_Product_Subtype_Code_gne__c = 'Therapeutic Area' order by Name];
        ProdcatalogDiseaseIndication = [Select Name,p.Detail_Product_Subtype_Code_gne__c, p.Disease_Indication_gne__c from Product_vod__c p  where Product_Type_vod__c = 'Detail' and Detail_Product_Subtype_Code_gne__c = 'Disease Indication' order by Name];
        system.debug('ProdcatalogDiseaseIndication'+ProdcatalogDiseaseIndication);
    }
    
    public List<SelectOption> getTheraProducts() 
    {       
        List<SelectOption> options=new List<SelectOption>();

        //options.add(new SelectOption('', '--None--'));
        if (lstProductCatalog != null && lstProductCatalog.size()>0)
        {
            for(Product_vod__c prd: lstProductCatalog)  
            {           
                options.add(new SelectOption(prd.Id, prd.Name));        
            }
        }
        
        return options;
    }
    
    
    public PageReference returnSelected()
    { 
        
        return null;
    }
    
    
    public List<SelectOption> getTherapeuticArea() 
    {       
        List<SelectOption> options = new List<SelectOption>();
    //  options.add(new SelectOption('', '--None--'));  Commented on may 25 to remove NONE option
        options.add(new SelectOption('Unspecified', 'Unspecified'));
    /*  if (lstTheraArea != null )
        {
            if (lstTheraArea.Size() >0)
            {
                for(Therapeutic_Area_Code_gne__c th: lstTheraArea)
                {                               
                    //options.add(new SelectOption(th.Code__c, th.Code__c));
                    options.add(new SelectOption(th.Description__c, th.Description__c));
                }               
            }
        }
        */
        if (ProdcatalogTheraArea != null )
        {
            if (ProdcatalogTheraArea.Size() >0)
            {
                for(Product_vod__c ds: ProdcatalogTheraArea)
                {                               
                    //options.add(new SelectOption(ds.Code__c, ds.Code__c));
                    if(ds.Name!=Null)
                    {
                    options.add(new SelectOption(ds.Name, ds.Name));
                    }
                }               
            }
        }
        return options;
    }
     
    public List<SelectOption> getDiseaseIndication() 
    {       
        List<SelectOption> options = new List<SelectOption>();
    //  options.add(new SelectOption('', '--None--'));  Commented on may 25 to remove NONE option
        options.add(new SelectOption('Unspecified', 'Unspecified'));
    /*  if (lstDiseaseIndication != null )
        {
            if (lstDiseaseIndication.Size() >0)
            {
                for(Disease_Indication_gne__c ds: lstDiseaseIndication)
                {                               
                    //options.add(new SelectOption(ds.Code__c, ds.Code__c));
                    options.add(new SelectOption(ds.Description__c, ds.Description__c));
                }               
            }
        }
        
    */
    if (ProdcatalogDiseaseIndication != null)
        {
            if (ProdcatalogDiseaseIndication.Size() >0)
            {
                for(Product_vod__c ds: ProdcatalogDiseaseIndication)
                {   
                    if(ds.Name!=Null)  
                    {                       
                    //options.add(new SelectOption(ds.Code__c, ds.Code__c));
                    options.add(new SelectOption(ds.Name, ds.Name));
                    }
                }               
            }
        }
        return options;
    }
    
}