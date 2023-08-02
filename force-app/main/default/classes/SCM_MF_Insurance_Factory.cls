public class SCM_MF_Insurance_Factory {
    private static List<Insurance_gne__c> Insurance;
    private static List<Insurance_gne__c> InsuranceNoRank;
    private static List<Insurance_gne__c> InsuranceAllBillLevels;
    private static List<Insurance_gne__c> InsurancePrimary;
    private static List<Insurance_gne__c> InsuranceSecondary;
    private static List<Insurance_gne__c> InsuranceTeriary;    
    private static Insurance_gne__c InsuranceResult;
	private static Insurance_gne__c InsuranceResult2;

    private static List<Benefit_Investigation_gne__c> BIListAll;
    private static List<Benefit_Investigation_gne__c> BIList;
    private static List<Benefit_Investigation_gne__c> BIListFil = new List<Benefit_Investigation_gne__c>();
    private static List<Prior_Authorization_gne__c> PAList;
    private static List<Prior_Authorization_gne__c> PAListFil = new List<Prior_Authorization_gne__c>();
    private Prior_Authorization_gne__c PA;
    private static Insurance_gne__c InsureancPA;
    
    private static string mInsuranceName_PA = '';
    private static string mInsuranceConFullName_PA = '';
    private static string mInsuranceStAddress_PA = '';
    private static string mInsuranceCityStateZip_PA = '';
    private static string mSubscriberID_PA = '';
    private static string mGroupNum_PA = '';
    private static string mPolicyNum_PA = '';

    private static SCM_MergeField createMergeField(String key)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        mf.fieldValue =''; 
        return mf;
    }
    
    private static Insurance_gne__c getInsuranceByBillLevel(string caseId, string BillLevel){
    	
    	List<Insurance_gne__c> fullins = getInsuranceAllBillLevels(caseId);
    	string rank = 'Primary';
    	 if(BillLevel == '1')
        {
            
            rank = 'Primary';
        }
        else if(BillLevel == '2')
        {
            rank = 'Secondary';
        }
        else if(BillLevel == '3')
        {
            rank = 'Tertiary';
        }
    	
    	if (fullins != null){
    		for(Insurance_gne__c i:fullins)
    		{
    			
    			if(i.Bill_Level_gne__c == BillLevel && i.Rank_gne__c == rank ){
    			InsuranceResult2 = i;
    				return i;
    			}
    		}
    		
    	}
    	
    	return null;
    }
    
    
     private static List<Insurance_gne__c> getInsuranceAllBillLevels(String caseID)
    {
        if( InsuranceAllBillLevels == null )
        {
            InsuranceAllBillLevels = [Select  i.id, i.LastModifiedDate,i.Payer_gne__r.Phone, i.Payer_gne__c, i.Case_Insurance_gne__r.CaseNumber,
                                                     i.Case_Insurance_gne__c, i.Bill_Level_gne__c,i.Rank_gne__c
                                                      From Insurance_gne__c i where i.Case_Insurance_gne__c=:caseID 
                                                      order by i.LastModifiedDate desc LIMIT 50];
        
                      
        }
        
        return InsuranceAllBillLevels;
    }
    
    private static List<Insurance_gne__c> getInsurance(String caseID)
    {
        if( Insurance == null )
        {
            Insurance = [Select  i.id, i.LastModifiedDate,i.Payer_gne__r.Phone, i.Payer_gne__c, i.Case_Insurance_gne__r.CaseNumber,
                                                     i.Case_Insurance_gne__c, i.Bill_Level_gne__c,i.Rank_gne__c
                                                      From Insurance_gne__c i where i.Case_Insurance_gne__c=:caseID 
                                                      //i.Case_Insurance_gne__r.CaseNumber=:caseID 
                                                      and i.Bill_Level_gne__c='1' and i.Rank_gne__c='Primary'
                                                      order by i.LastModifiedDate desc LIMIT 1];
        
                      
        }
        
        return Insurance;
    }
    private static List<Insurance_gne__c> getInsuranceNonRank(String caseID)
    {
        if( InsuranceNoRank == null )
        {
            InsuranceNoRank = [Select  i.id, i.LastModifiedDate,i.Payer_gne__r.Phone, i.Payer_gne__c, i.Case_Insurance_gne__r.CaseNumber,
                                                     i.Case_Insurance_gne__c, i.Bill_Level_gne__c,i.Rank_gne__c
                                                      From Insurance_gne__c i where i.Case_Insurance_gne__c=:caseID 
                                                      //i.Case_Insurance_gne__r.CaseNumber=:caseID 
                                                      and i.Bill_Level_gne__c='1' 
                                                      order by i.LastModifiedDate desc LIMIT 1];
        
                      
        }
        
        return InsuranceNoRank;
    }
    private static Insurance_gne__c getInsuranceById(String InsID)
    {
         Insurance_gne__c ins = [Select  i.id, i.LastModifiedDate,i.Payer_gne__r.Phone, i.Payer_gne__c, i.Case_Insurance_gne__r.CaseNumber,
                                                     i.Case_Insurance_gne__c, i.Bill_Level_gne__c,i.Rank_gne__c
                                                      From Insurance_gne__c i 
                                                      WHERE id =: InsID];        
        return ins;
    }
        
    private static Benefit_Investigation_gne__c getBenefit_InvestigationById(String BiID)
    {
        Benefit_Investigation_gne__c bi = [SELECT b.Id, b.BI_Insurance_gne__r.Payer_gne__r.Name,
                                                  b.BI_Insurance_gne__r.Subscriber_Num_gne__c, 
                                                  b.BI_Insurance_gne__r.Group_Num_gne__c,
                                                  b.Drug_Billing_Code_gne__c
                                             FROM Benefit_Investigation_gne__c b
                                            WHERE Id =: BiID];
        return bi;
    }
    
    private static List<Benefit_Investigation_gne__c> getBIByBillLevel(string caseId,string BillLevel){
    	List<Benefit_Investigation_gne__c> bis= new List<Benefit_Investigation_gne__c>();
    	Insurance_gne__c ins =   getInsuranceByBillLevel(caseId, BillLevel);
    	if (ins != null){
    		List<Benefit_Investigation_gne__c> allBis =  getAllBIList(caseId);
    		
    		for(Benefit_Investigation_gne__c b:allBis){
    			
    			if (b.BI_Insurance_gne__c == ins.Id){
    				bis.add(b);
    			}
    			
    		}
    		
    	}
    	
    	return bis;
    	
    }
    
    
    
     private static List<Benefit_Investigation_gne__c> getAllBIList(String caseId)
    {
        if(BIListAll==null)
        {
            try
            {
                if( null != getInsuranceAllBillLevels(caseId))
                {
                    List<String> insuranceIds = new List<String>();
                    for(Insurance_gne__c ins:InsuranceAllBillLevels){
                        insuranceIds.add(ins.Id);
                    }
            
                    BIListAll=[Select b.Id, b.BI_Insurance_gne__r.Payer_gne__c,
                                b.BI_Insurance_gne__r.Subscriber_Num_gne__c, 
                                b.BI_Insurance_gne__r.Group_Num_gne__c,
                                b.Drug_Billing_Code_gne__c,Benefit_Type_gne__c,Prior_Authorization_Required_Formula_gne__c
                            From Benefit_Investigation_gne__c b
                            where BI_Insurance_gne__c in :insuranceIds
                             order by b.LastModifiedDate desc 
                            LIMIT 40];
                   
              
                }
                else
                    return null;
            }
            catch(Exception exp)
            {
                return null;
            }
        }
         return BIListAll;
    }
    
    
    
    private static List<Benefit_Investigation_gne__c> getBIList(String caseId)
    {
        if(BIList==null)
        {
            try 
            {
                if( null != getInsurance(caseId))
                {
                    List<String> insuranceIds = new List<String>();
                    for(Insurance_gne__c ins:insurance)
                        insuranceIds.add(ins.Id);
                
            
                    BIList=[Select b.Id, b.BI_Insurance_gne__r.Payer_gne__c,
                                b.BI_Insurance_gne__r.Subscriber_Num_gne__c, 
                                b.BI_Insurance_gne__r.Group_Num_gne__c,
                                b.Drug_Billing_Code_gne__c
                            From Benefit_Investigation_gne__c b
                            where b.BI_BI_Status_gne__c = 'Complete - Pending PA' 
                                and BI_Insurance_gne__c in :insuranceIds
                             order by b.LastModifiedDate desc 
                            LIMIT 5];
                   
              
                }
                else
                    return null;
            }
            catch(Exception exp)
            {
                return null;
            }
        }
         return BIList;
    }
    
    
    private static  List<Prior_Authorization_gne__c> getPAList(String caseId)
    {
        if(PAList==null)
        {
            try
            {
                if( getBIList(caseId)!=null)
                {
                    List<String> BIIds = new List<String>();
                    for(Benefit_Investigation_gne__c bi:BIList)
                            BIIds.add(bi.Id);

                    PAList = [select p.Address_Line_1_gne__c, 
                                     p.Address_Line_2_gne__c, 
                                   
                                     p.Author_gne__c,
                                     p.Author_Type_gne__c, 
                                     p.Benefit_Investigation_gne__c, 
                                     p.City_gne__c, 
                                     p.Counter_gne__c, 
                                     p.Date_LMN_Requested_gne__c, 
                                    
                                    
                                    
                                     p.Fax_gne__c, p.Id, p.Letter_to_Payer_gne__c, 
                                     p.PA_Authorization_Num_gne__c, 
                                     p.PA_Contact_Name_gne__c, 
                                   
                                   
                                   
                                   
                                   
                                    
                                     p.PA_Term_gne__c, p.PA_Type_gne__c, p.Phone_gne__c, 
                                     p.Recertification_Date_gne__c, p.Release_gne__c, 
                                     p.State_gne__c, p.Status_gne__c, 
                                     p.Therapy_Authorized_gne__c, p.Vendor_XFER_Status_Date_gne__c, 
                                     p.Vendor_XFER_Status_gne__c, p.Zip_gne__c  
                                from Prior_Authorization_gne__c p
                               where p.Benefit_Investigation_gne__c in :BIIds
                            order by p.LastModifiedDate desc LIMIT 5];                
                }
                else
                    return null;
            }
            catch(Exception exp)
            {
                return null;
            }
        }
        return PAList;
    }

	
	
	
    public static void getPA(String CaseID)
    {
        List<Insurance_gne__c> ins = [select i.Id,
                                             i.Payer_gne__r.name,
                                             i.Subscriber_Num_gne__c,
                                             i.Group_Num_gne__c,
                                             i.Policy_Number_gne__c
                                        from Insurance_gne__c i 
                                       where i.Case_Insurance_gne__c =:CaseID LIMIT 15];

        List<String> iIDs = new List<String>();
        for(Insurance_gne__c i:ins)
        {
            iIDs.add(i.Id);
        }

        List<Benefit_Investigation_gne__c> bis =[select b.BI_Insurance_gne__c, b.BI_BI_Status_gne__c 
                                                   from Benefit_Investigation_gne__c b
                                                  where b.BI_BI_Status_gne__c like '%Complete - Pending PA%' 
                                                    and BI_Insurance_gne__c in :iIDs
                                               order by b.LastModifiedDate desc LIMIT 15];
 
        List<String> biIDs = new List<String>();

        for(Benefit_Investigation_gne__c bi:bis)
        {
            biIDs.add(bi.Id);
        }

        List<Prior_Authorization_gne__c> pas = [select p.Address_Line_1_gne__c, 
                                                       p.Address_Line_2_gne__c, 
                                                       p.Benefit_Investigation_gne__c, 
                                                       p.City_gne__c, 
                                                       p.Fax_gne__c, p.Id, 
                                                       p.Letter_to_Payer_gne__c, 
                                                       p.PA_Contact_Name_gne__c, 
                                                       p.State_gne__c,
                                                       p.Phone_gne__c, 
                                                       p.Zip_gne__c  
                                                  from Prior_Authorization_gne__c p
                                                 where p.Benefit_Investigation_gne__c in :biIDs
                                              order by p.LastModifiedDate desc LIMIT 15];


        if(bis.size() == 0)
        {
            mInsuranceName_PA = string.valueOf(bis.size());
            mInsuranceConFullName_PA = '';
            mInsuranceStAddress_PA = '';
            mInsuranceCityStateZip_PA = '';
            mSubscriberID_PA = '';
            mGroupNum_PA = '';
            mPolicyNum_PA = '';
        }

        if(bis.size() >= 1)
        {
            for(Insurance_gne__c i:ins)
            {
                if(bis[0].BI_Insurance_gne__c == i.Id)
                {
                    mInsuranceName_PA = i.Payer_gne__r.name;
                }
                
                if(i.Subscriber_Num_gne__c != null)
                {
                    mSubscriberID_PA = i.Subscriber_Num_gne__c;
                }
                
                if(i.Group_Num_gne__c != null)
                {
                    mGroupNum_PA = i.Group_Num_gne__c;
                }
                
                if(i.Policy_Number_gne__c != null)
                {
                    mPolicyNum_PA = i.Policy_Number_gne__c;
                }
            }
            
            for(Prior_Authorization_gne__c p:pas)
            {
                if(bis[0].id == p.Benefit_Investigation_gne__c)
                {
                    if(p.PA_Contact_Name_gne__c != null)
                    {
                        mInsuranceConFullName_PA = p.PA_Contact_Name_gne__c;
                    }

                    if(p.Address_Line_1_gne__c != null)
                    {
                        mInsuranceStAddress_PA = p.Address_Line_1_gne__c;
                    }

                    if(p.Address_Line_2_gne__c != null)
                    {
                        mInsuranceStAddress_PA += ' ' + p.Address_Line_2_gne__c;
                    }

                    if(p.City_gne__c != null)
                    {
                        mInsuranceCityStateZip_PA = p.City_gne__c;
                    }
                    
                    if(p.State_gne__c != null)
                    {
                        mInsuranceCityStateZip_PA += ', ' + p.State_gne__c;
                    }
                    
                    if(p.Zip_gne__c != null)
                    {
                        mInsuranceCityStateZip_PA += ' ' + p.Zip_gne__c;
                    }
                }
            }
        }
    }

    private static Insurance_gne__c getInsuranceResult()
    {
        if(InsuranceResult == null)
        {
            try
            {
                InsuranceResult = getInsuranceById(getBenefit_InvestigationById(PAList[0].Benefit_Investigation_gne__c).Id);
            }
            catch(Exception ex)
            {
                InsuranceResult = null;
            }
        }
        return InsuranceResult;
    }

    private static Insurance_gne__c getInsurance(String caseID, String rank)
    {
        List<Insurance_gne__c> InsuranceLocal = new List<Insurance_gne__c>();
        
        String rankDesc = '';
        
        if(rank.ToLowerCase() == '1')
        {
            InsuranceLocal = InsurancePrimary;
            rankDesc = 'Primary';
        }
        else if(rank.ToLowerCase() == '2')
        {
            InsuranceLocal = InsuranceSecondary;
            rankDesc = 'Secondary';
        }
        else if(rank.ToLowerCase() == '3')
        {
            InsuranceLocal = InsuranceTeriary;
            rankDesc = 'Teriary';
        }
        
        if( InsuranceLocal == null )
        {
            try
            {
                   InsuranceLocal = [select i.Payer_gne__r.Name,
                                            i.Payer_gne__r.Phone,
                                            i.Subscriber_Num_gne__c,
                                            i.Subscriber_Name_gne__c,
                                            i.Policy_Number_gne__c,
                                            i.Payer_gne__c,
                                            i.Plan_Product_type_gne__c,
                                            i.Group_Num_gne__c,
                                            i.Employer_gne__c 
                                       from Insurance_gne__c i 
                                      where i.Case_Insurance_gne__c =:caseID
                                        and i.Rank_gne__c =:rankDesc
                                   order by i.LastModifiedDate desc 
                                       LIMIT 5];   
            }
            catch(Exception ex)
            {
                InsuranceLocal = null;
            }
        }
        
        if(rank.ToLowerCase() == '1')
        {
             InsurancePrimary = InsuranceLocal;
        }
        else if(rank.ToLowerCase() == '2')
        {
            InsuranceSecondary = InsuranceLocal;
        }
        else if(rank.ToLowerCase() == '3')
        {
            InsuranceTeriary = InsuranceLocal;
        }

        Insurance_gne__c returnInsurance = null;
        
        if(InsuranceLocal.size() == 1)
        {
            returnInsurance = InsuranceLocal[0];
        }
        
        if(InsuranceLocal.size() > 1)
        {
            for(Insurance_gne__c ins:InsuranceLocal)
            {
                if(ins.Plan_Product_type_gne__c != 'Prescription Drug Plan' && ins.Plan_Product_type_gne__c != 'Mail Order') {
                  returnInsurance = ins;
                  break;
                }
            }
        }
        return returnInsurance;
    }

    public static SCM_MergeField InsuranceContactNamePA(String caseId)
    {
        SCM_MergeField mf = createMergeField('ATTN_PA');
        if(getPAList(caseId)!=null)
        {
            mf.fieldValue=''; 
            if(PAList.size()>0 && PAList[0].PA_Contact_Name_gne__c!=null)
            {
                mf.fieldValue = PAList[0].PA_Contact_Name_gne__c;
            }
        }
        mf.displayTextBox = true;
        mf.label = 'Attn:';
        mf.displayLabel = true;
        mf.isRequired = true;
        if (mf.fieldValue == null)
            mf.fieldValue = '';

        return mf;
    }

    public static SCM_MergeField InsuranceContactFaxPA(String caseId)
    {
        SCM_MergeField mf = createMergeField('RECFAX_PA');
        if(getPAList(caseId)!=null)
        {
            if(PAList.size()>0 && PAList[0].Fax_gne__c!=null)
            {
                mf.fieldValue = PAList[0].Fax_gne__c;
            }
        }
        mf.displayTextBox = true;
        mf.label = 'Fax Number:';
        mf.displayLabel = true;
        mf.isRequired = true;
        mf.FieldType = SCM_MergeField.FieldTypes.phoneNumberField;
        if (mf.fieldValue == null)
            mf.fieldValue = '';
        return mf;
    }

    public static SCM_MergeField InsurancePhone(String caseId)
    {
        string returnString;
        SCM_MergeField mf = createMergeField('InsurancePhone');
        mf.fieldvalue = '';
        if( null != getInsurance(caseId) )
        {
        if(Insurance.size()>0)
        {
             returnString=Insurance[0].Payer_gne__r.Phone;
             
      
       String payer_gen_c = Insurance[0].Payer_gne__c;
       
       List<Address_vod__c> address = [Select a.Phone_vod__c, a.Id,  a.Account_vod__c From Address_vod__c a
                         where a.Account_vod__c=:payer_gen_c and a.Primary_vod__c = true order by lastmodifieddate desc limit 5];       
             
             
                         
       if(address.size() >0)
       {
           returnString =   address[0].Phone_vod__c;
       }
       
       
       }
      if(returnString==null)
       {
        returnString ='';
       }
      
       mf.fieldvalue = returnString;
            
         }   
        
        
        return mf;
    }
    
    public static SCM_MergeField InsuranceNamePA(String caseId)
    {
        SCM_MergeField mf = createMergeField('RECNAME_Payor');
        /* The below will never work it goes in 4 levels SF only goes in 2.
        if(getPAList(caseId)!=null)
        {
            mf.fieldValue=''; 
            if(PAList.size()>0)
            {
                try {
                    mf.fieldValue = PAList[0].Benefit_Investigation_gne__r.BI_Insurance_gne__r.Payer_gne__r.Name;
                }
                catch (Exception e) {
                    mf.fieldValue = '';
                }
            }
        }
        */
        mf.fieldValue = mInsuranceName_PA;
        mf.displayTextBox = true;
        mf.label = 'Addressed To:';
        mf.displayLabel = true;
        mf.isRequired = true;
        if (mf.fieldValue == null)
            mf.fieldValue = '';

        return mf;
    }
    
    public static SCM_MergeField SelfFunded(Insurance_gne__c ins)
    {
      SCM_MergeField mf = createMergeField('SelfFunded');
      if (ins == null){
        mf.fieldValue = '';
        return mf;
      }
       try {
                       
           
           mf.fieldValue = ins.Self_Funded_gne__c;
           
           if (mf.fieldValue == null){
             mf.fieldValue = '';  
           }
       }
       catch(exception e){
         mf.fieldValue = '';
       }
       return mf;
      }    
    
    
    public static SCM_MergeField InsuranceConFullName_PA(String caseId)
    {
        SCM_MergeField mf = createMergeField('InsuranceConFullName_PA');
        /*
        if(getPAList(caseId)!=null)
        {
            mf.fieldValue=''; 
            if(PAList.size() > 0 && PAList[0].PA_Contact_Name_gne__c != null)
            {
                mf.fieldValue = PAList[0].PA_Contact_Name_gne__c;
            }
        }
        */
        mf.fieldValue = mInsuranceConFullName_PA;
        if (mf.fieldValue == null)
            mf.fieldValue = '';

        return mf;
    }

    public static SCM_MergeField InsuranceStAddress_PA(String caseId)
    {
        SCM_MergeField mf = createMergeField('InsuranceStAddress_PA');
        /*
        if(getPAList(caseId)!=null)
        {
            mf.fieldValue=''; 
            if(PAList.size() > 0 && PAList[0].Address_Line_1_gne__c != null)
            {
                mf.fieldValue = PAList[0].Address_Line_1_gne__c;
                if(PAList[0].Address_Line_2_gne__c != null)
                {
                    mf.fieldValue += PAList[0].Address_Line_2_gne__c;
                }
            }
        }
        */
        mf.fieldValue = mInsuranceStAddress_PA;
        return mf;
    }
    
    public static SCM_MergeField InsuranceCityStateZip_PA(String caseId)
    {
        SCM_MergeField mf = createMergeField('InsuranceCityStateZip_PA');
        /*
        if(getPAList(caseId)!=null)
        {
            mf.fieldValue=''; 
            if(PAList.size() > 0 && PAList[0].City_gne__c != null)
            {
                mf.fieldValue = PAList[0].City_gne__c;
            }
            
            if(PAList.size() > 0 && PAList[0].State_gne__c != null)
            {
                mf.fieldValue += ', ' + PAList[0].State_gne__c;
            }
            
            if(PAList.size() > 0 && PAList[0].Zip_gne__c != null)
            {
                mf.fieldValue += ' ' + PAList[0].Zip_gne__c;
            }            
        }
        */
        mf.fieldValue = mInsuranceCityStateZip_PA;
        return mf;
    }
    
    public static SCM_MergeField SubscriberID_PA(String caseId)
    {
        SCM_MergeField mf = createMergeField('SubscriberID_PA');
        
        if(getPAList(caseId)!=null)
        {
            mf.fieldValue = '';
           
            if(getInsuranceResult() != null)
            {
                mf.fieldValue = getInsuranceResult().Subscriber_Num_gne__c;
            }
                
        }
        
        if (mf.fieldValue == null)
            mf.fieldValue = '';
        return mf;
    }

    public static SCM_MergeField GroupNum_PA(String caseId)
    {
        SCM_MergeField mf = createMergeField('GroupNum_PA');
        /*
        if(getPAList(caseId)!=null)
        {
            mf.fieldValue = '';
            if(getInsuranceResult() != null)
            {
                mf.fieldValue = getInsuranceResult().Group_Num_gne__c;
            }
                
        }
        */
        mf.fieldValue = mGroupNum_PA;
        if (mf.fieldValue == null)
            mf.fieldValue = '';
        return mf;
    }  
    
    public static SCM_MergeField PolicyNum_PA(String caseId)
    {
        SCM_MergeField mf = createMergeField('PolicyNum_PA');
        /*
        if(getPAList(caseId)!=null)
        {
            mf.fieldValue = '';
            if(getInsuranceResult() != null)
            {
                mf.fieldValue = getInsuranceResult().Policy_Number_gne__c;
            } 
        }
        */
        mf.fieldValue = mPolicyNum_PA;
        if (mf.fieldValue == null)
            mf.fieldValue = '';
        return mf;
    } 

    public static SCM_MergeField InsuranceNameSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('InsuranceNameSMN' + rank);

        try
        {
            if(getInsurance(selectedCase.Id, rank) != null)
            {
                mf.FieldValue = getInsurance(selectedCase.Id, rank).Payer_gne__r.Name;
            }
            else
            {
                mf.FieldValue = '';
            }
        }
        catch (Exception ex)
        {

        }
        if(mf.FieldValue == null)
        {
            mf.FieldValue = '';
        }
        
        return mf;
    }
    
        public static SCM_MergeField InsuranceName(Case selectedCase)
    {
        SCM_MergeField mf = createMergeField('InsuranceName');

        try
        {
            if(getInsuranceNonRank(selectedCase.Id) != null)
            {
                mf.FieldValue = getInsuranceNonRank(selectedCase.Id)[0].Payer_gne__r.Name;
            }
            else
            {
                mf.FieldValue = '';
            }
        }
        catch (Exception ex)
        {

        }
        if(mf.FieldValue == null)
        {
            mf.FieldValue = '';
        }
        
        return mf;
    }
    
    public static SCM_MergeField InsurancePhoneSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('InsurancePhoneSMN' + rank);

    mf.FieldValue = '';
        try
        {
        if(getInsurance(selectedCase.Id, rank).Payer_gne__c != null)
        {
          
         String payer_gen_c = getInsurance(selectedCase.Id, rank).Payer_gne__c;
       
         List<Address_vod__c> address = [Select a.Phone_vod__c, a.Id,  a.Account_vod__c From Address_vod__c a
                         where a.Account_vod__c=:payer_gen_c and a.Primary_vod__c = true limit 5];       
             
             
                         
       if(address.size() >0)
       {
            mf.FieldValue =address[0].Phone_vod__c;
       }
          
         //   mf.FieldValue = getInsurance(selectedCase.Id, rank).Payer_gne__r.Phone;
        }
        else
        {
            mf.FieldValue = '';
        }
        }
        catch (Exception ex)
        {

        }
        
        if(mf.FieldValue == null)
        {
            mf.FieldValue = '';
        }
        return mf;
    }
    
    public static SCM_MergeField SubscriberNameSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('SubscriberNameSMN' + rank);
        try
        {
        if(getInsurance(selectedCase.Id, rank) != null)
        {
            mf.FieldValue = getInsurance(selectedCase.Id, rank).Subscriber_Name_gne__c;
        }
        else
        {
            mf.FieldValue = '';
        }
        }
        catch (Exception ex)
        {

        }
        if(mf.FieldValue == null)
        {
            mf.FieldValue = '';
        }
        return mf;
    }
    public static SCM_MergeField PriorAuthorization(Case selectedCase, String BillLevel)
    {
    	SCM_MergeField mf = createMergeField('PriorAuthorization' + BillLevel);
    	try{
    		
    		
    		boolean FoundBi = false;
    		List<Benefit_Investigation_gne__c> BIs  = getBIByBillLevel(selectedCase.Id, BillLevel);
    	 	
    	 	if(BIs != null )
        	{
        		if (bis.size() == 1){
        			mf.fieldValue = bis[0].Prior_Authorization_Required_Formula_gne__c;
        			
        			if (bis[0].Prior_Authorization_Required_Formula_gne__c == 'Yes'){
        				mf.FieldValue += '\r\nIf the insurance requires additional documents for renewal of the prior-authorization, we will request those separately once they are identified.';
        			}
        			
        		}
        		else if (bis.size() > 1){
        			for(Benefit_Investigation_gne__c b:BIs){
        				mf.FieldValue += b.Benefit_Type_gne__c + ':' + b.Prior_Authorization_Required_Formula_gne__c + '\r\n';
        				if (b.Prior_Authorization_Required_Formula_gne__c == 'Yes'){
        					FoundBi = true;
        				}
        			}
        			if (FoundBi == true){
         	   			mf.FieldValue += 'If the insurance requires additional documents for renewal of the prior-authorization, we will request those separately once they are identified.';
        			}
        		}
        		else {
        			
        			mf.fieldValue = '';
        		}
        		
        	}
        	else
        	{
        	    mf.FieldValue = '';
        	}
    	}
    	catch (Exception e){
    		mf.FieldValue = '';
    	}
    	return mf;
    }
    
    public static SCM_MergeField SubscriberIDSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('SubscriberIDSMN' + rank);
        try
        {
        if(getInsurance(selectedCase.Id, rank) != null)
        {
            mf.FieldValue = getInsurance(selectedCase.Id, rank).Subscriber_Num_gne__c;
        }
        else
        {
            mf.FieldValue = '';
        }
        }
        catch (Exception ex)
        {

        }
        if(mf.FieldValue == null)
        {
            mf.FieldValue = '';
        }
        return mf;
    }
    
    public static SCM_MergeField GroupNumSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('GroupNumSMN' + rank);
        try
        {
        Insurance_gne__c ins = getInsurance(selectedCase.Id, rank); 
        if(ins != null)
        {
            mf.fieldValue = ins.Group_Num_gne__c;
            if (mf.fieldValue == null)
                mf.fieldValue = ins.Policy_Number_gne__c;
                if (mf.fieldValue == null)
                    mf.fieldValue = ''; 
        }
        else
        {
            mf.FieldValue = '';
        }
        }
        catch (Exception ex)
        {

        }
        if(mf.FieldValue == null)
        {
            mf.FieldValue = '';
        }
        return mf;
    }
    
    public static SCM_MergeField InsuranceEmployerSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('InsuranceEmployerSMN' + rank);
        try
        {
        if(getInsurance(selectedCase.Id, rank) != null)
        {
            mf.FieldValue = getInsurance(selectedCase.Id, rank).Employer_gne__c;
        }
        else
        {
            mf.FieldValue = '';
        }
        }
        catch (Exception ex)
        {

        }
        if(mf.FieldValue == null)
        {
            mf.FieldValue = '';
        }
        return mf;
    }
}