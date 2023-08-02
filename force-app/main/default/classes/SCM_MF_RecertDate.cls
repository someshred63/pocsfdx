public class SCM_MF_RecertDate extends scm_MergeField{
    
   public SCM_MF_RecertDate (Benefit_Investigation_gne__c bi)
   {
    key = 'RecertDate';
    fieldValue= '';
    className = 'SCM_MF_RecertDate';
    checked = false;
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    List <Prior_Authorization_gne__c> biLocal;
    try
    {
    	//Select p.Recertification_Date_gne__c, p.Benefit_Investigation_gne__c 
    	//From Prior_Authorization_gne__c p where p.Benefit_Investigation_gne__c ='a0lS00000008VMUIA2'
    biLocal = [Select p.Recertification_Date_gne__c, p.Benefit_Investigation_gne__c From 
    Prior_Authorization_gne__c p where  p.Benefit_Investigation_gne__c =:bi.Id];
    //order by LastModifiedDate desc LIMIT 1];
        
    //Select b.Id,
    //(Select Recertification_Date_gne__c From Prior_Authorization_gne__r),Prior_Authorization_gne__r.Recertification_Date_gne__c
    // From Benefit_Investigation_gne__c b where b.Id=:bi.Id order by LastModifiedDate desc LIMIT 1];
    }
    catch(Exception ex)
    {
    	biLocal = null;
    }
    
     if ((biLocal.Size()>0))
     {
    	fieldValue=biLocal[0].Recertification_Date_gne__c ==  null?'':biLocal[0].Recertification_Date_gne__c.format();
    
     //	if(bi.Prior_Authorization_Required_gne__c.contains('Y'))
     //		fieldValue=biLocal[0].Recertification_Date_gne__c ==  null?'':biLocal[0].Recertification_Date_gne__c.format();
     //	else
     //		fieldValue= 'No Prior Authorization required.';
     		//biLocal[0].Recertification_Date_gne__c ==  null?'':biLocal[0].Recertification_Date_gne__c.format();
     }
     if (biLocal== null)
     	fieldValue=(fieldValue==null)? '' :fieldValue;
   //  else
   //  	fieldValue= '';
   }
    
}