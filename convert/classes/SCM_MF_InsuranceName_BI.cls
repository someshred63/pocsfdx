public class SCM_MF_InsuranceName_BI extends scm_MergeField{
  
  public  SCM_MF_InsuranceName_BI (Benefit_Investigation_gne__c bi)
  {
    key = 'InsuranceName';
    className = 'SCM_MF_InsuranceName_BI';
    checked = false;
    fieldValue = '';
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    List<Insurance_gne__c> ListBillLevel1;
    List<Insurance_gne__c> ListBillLevel2;
    List<Insurance_gne__c> ListBillLevel3;
	try {    
    try
    {
    	ListBillLevel1=[Select i.Main_Payer_gne__r.Name, i.Main_Payer_gne__c, i.Id, 
    	i.Bill_Level_gne__c From Insurance_gne__c i where i.Id=:bi.BI_Insurance_gne__c
    	and  i.Bill_Level_gne__c ='1' order by i.LastModifiedDate desc ];
    }
    catch(Exception e)
    {
        ListBillLevel1 = null;
    }  
    
    try
    { 
    	ListBillLevel2=[Select i.Main_Payer_gne__r.Name, i.Main_Payer_gne__c, i.Id, 
    	i.Bill_Level_gne__c From Insurance_gne__c i where i.Id=:bi.BI_Insurance_gne__c
    	and  i.Bill_Level_gne__c ='2' order by i.LastModifiedDate desc ];
    }
    catch(Exception e) 
    {
        ListBillLevel2 = null;
    }   
    
    try 
    {
    	ListBillLevel3=[Select i.Main_Payer_gne__r.Name, i.Main_Payer_gne__c, i.Id, 
    	i.Bill_Level_gne__c From Insurance_gne__c i where i.Id=:bi.BI_Insurance_gne__c
    	and  i.Bill_Level_gne__c ='3' order by i.LastModifiedDate desc ];
    }
    catch(Exception e) 
    {
        ListBillLevel3 = null;
    } 
   
    if(ListBillLevel1.Size() ==1)
    {
     fieldValue+=(ListBillLevel1[0].Main_Payer_gne__r.Name==null)?'':ListBillLevel1[0].Main_Payer_gne__r.Name;
    }
    
    if(ListBillLevel2.Size()==1)
    {
     fieldValue+=(ListBillLevel2[0].Main_Payer_gne__r.Name==null)?'':ListBillLevel2[0].Main_Payer_gne__r.Name;
    }
    
    if(ListBillLevel3.Size()==1)
    {
     fieldValue+=(ListBillLevel3[0].Main_Payer_gne__r.Name==null)?'':ListBillLevel3[0].Main_Payer_gne__r.Name;
    }
    } 
   	catch (Exception ex){
   		fieldValue = '';
   	}
   
  }
}