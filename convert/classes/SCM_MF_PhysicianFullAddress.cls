//condition is as follows
//Join Case.Address_gne__c to Address_vod__c.Account_vod__c and select Address_vod__c.Address_1_gne__c
// || Address_vod__c.City_vod__c || Address_vod__c.State_vod__c || Address_vod__c..Zip_vod__c
public class SCM_MF_PhysicianFullAddress extends SCM_MergeField
 {
   
   public SCM_MF_PhysicianFullAddress(Case cseLocal)
    {
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='PhysicianFullAddress';
    className='SCM_MF_PhysicianFullAddress';
    fieldValue = obtainPhysicianFullAddress(cseLocal);
    }
     
    public string obtainPhysicianFullAddress(Case cseLocal)
    {
    	try {
       String returnString='';
       List<Case> caseName = [Select c.Address_gne__r.Name,c.Address_gne__r.Address_1_gne__c,c.Address_gne__r.Address_line_2_vod__c, c.Address_gne__r.State_vod__c, 
                              c.Address_gne__r.Zip_vod__c, c.Address_gne__r.City_vod__c, c.Address_gne__c From Case c 
                                                where c.Address_gne__c=:cseLocal.Address_gne__c
													order by c.LastModifiedDate desc LIMIT 1];													
												
	   if(caseName[0].Address_gne__r.Name!=null)
	   {
	   	returnString= caseName[0].Address_gne__r.Name +' ';
	   }
	   else
	   {
	    returnString=' '; 
	   }
	   if(caseName[0].Address_gne__r.Address_line_2_vod__c!=null)
	   {
	   	returnString += caseName[0].Address_gne__r.Address_line_2_vod__c +' ';
	   }
	   else
	   {
	    returnString +=' '; 
	   }
	   if(caseName[0].Address_gne__r.City_vod__c!=null)
	   {
	   	returnString+= caseName[0].Address_gne__r.City_vod__c;
	   }
	   else
	   {
	    returnString+=' '; 
	   }
	   
	   if(caseName[0].Address_gne__r.State_vod__c!=null)
	   {
	   	returnString+= ', ' + caseName[0].Address_gne__r.State_vod__c;
	   }
	   else
	   {
	    returnString+=' '; 
	   }
	   
	    if(caseName[0].Address_gne__r.Zip_vod__c!=null)
	   {
	   	returnString+= ' ' + caseName[0].Address_gne__r.Zip_vod__c;
	   }
	   else
	   {
	    returnString+=' '; 
	   }
	   
       //returnString= caseName[0].Address_gne__r.Address_1_gne__c+caseName[0].Address_gne__r.City_vod__c+caseName[0].Address_gne__r.State_vod__c+caseName[0].Address_gne__r.Zip_vod__c;     
       if(returnString==null)
       {
        returnString='';
       }
        
       return returnString; 
    }  catch (exception ex) {
   	return '';
   }
    }
   
    public override String getFieldvalue()
   {
    return fieldValue;
   }
}