public  with sharing virtual class GNE_CM_IntPer_MH_Base_Ctrllr 
{
	public Patient_Enrollment_Request_gne__c patenrol { get { return pageController.patenrol; } }
	private Medical_History_gne__c mh=null;
	private Map<String,Medical_History_gne__c> mapMH=null;
	private List<Medical_History_gne__c> listMH=null;

	public Map<String,String> errors { get; set; }
	
	//private transient String mhSOQL=null;

	private Boolean bPERFieldsInit=false;
	
	private string mhSOQL 
	{
		get
		{
			return GNE_CM_MPS_Utils.getSelectStarSOQL('Medical_history_gne__c') +
				' WHERE Patient_Med_Hist_gne__c =:patientId ' +
				' AND RecordType.Name in :setProds ' +
				' ORDER BY CreatedDate DESC';
		}
	}

	public GNE_CM_IntPer_MH_Base_Ctrllr()
	{ 
		errors=new Map<String,String>();

		/*mhSOQL=GNE_CM_MPS_Utils.getSelectStarSOQL('Medical_history_gne__c') +
				' WHERE Patient_Med_Hist_gne__c =:patientId ' +
				' AND RecordType.Name in :setProds ' +
				' ORDER BY CreatedDate DESC';*/
	}
	
	// once medical histories are saved we should
	// force a reload if there's a subsequent intake (case) error
	public void clearCache()
	{
		mh=null;
		listMH=null;
		mapMH=null;
		initPERFields();			     		 
	}
	
 	public Set<Id> getMissingMHIds()
 	{
        Set<Id> missingMHIds = new Set<Id>();
        for(Medical_History_gne__c aMh : medicalHistories.values()) {
            missingMHIds.add(aMh.Id);
        }               

        List<Medical_History_gne__c> validMHs = [SELECT Id FROM Medical_History_gne__c WHERE Id IN :missingMHIds];
        Set<Id> validIds = new Set<Id>();
        for(Medical_History_gne__c validMH : validMHs) {
            validIds.add(validMH.Id);   
        }

        missingMHIds.removeAll(validIds);

        return missingMHIds;
	}	

	public Medical_History_gne__c medicalHistory 
	{ 
		get
		{
			if (mh==null)
			{
				medicalHistoryFetchFromDB = false;
				String mhRecordTypeId = null;
				Map<String, Schema.RecordTypeInfo> mapRecordTypes=Schema.SObjectType.Medical_history_gne__c.getRecordTypeInfosByName();
				Set<String> setProds=getProducts();
				String patientId=patenrol.Patient_gne__c;
				String perProduct=patenrol.Product_gne__c;
				
				if (mapRecordTypes.containsKey(perProduct))
				{
					if (medicalHistoryList.size()>0)
					{
						mh = medicalHistoryList[0];
						medicalHistoryFetchFromDB = true;						
					}
					else
					{
						mh=new Medical_History_gne__c(Patient_Med_Hist_gne__c = patenrol.Patient_gne__c, 
								RecordTypeId = mapRecordTypes.get(patenrol.Product_gne__c).getRecordTypeId());						
					}			
				}
				else
				{
					Map<String, Schema.SObjectField> M = Schema.getGlobalDescribe().get('Medical_History_gne__c').getDescribe().fields.getMap();
					
					/*
					// fetch ALL MH from franchise
					String mhFormSOQL=GNE_CM_MPS_Utils.getSelectStarSOQL('Medical_history_gne__c') +
							' WHERE Patient_Med_Hist_gne__c =:patientId ' +
							' AND SMN_Form_gne__c = :perProduct ' +
							' ORDER BY CreatedDate DESC';
					*/
					
					mh=new Medical_History_gne__c(Patient_Med_Hist_gne__c = patenrol.Patient_gne__c);		
					for (String prod : setProds)
					{
						mh.RecordTypeId = mapRecordTypes.get(prod).getRecordTypeId();		
						break;				
					}

					for (Medical_History_gne__c mhist : medicalHistoryList) //(List<Medical_History_gne__c>) Database.query(mhFormSOQL) 
					{
						// merge fields
						for (Schema.SObjectField f : M.values())
						{
							Schema.Describefieldresult dr = f.getDescribe();
						
							String fldName=dr.getName();
							Schema.Displaytype fldType=dr.getType();
						
							if (dr.isUpdateable())
							{
								if (fldType==Schema.Displaytype.MultiPicklist)
								{
									// merge picklists
									Set<String> setSel=new Set<String>();
									setSel.addAll(mh.get(fldName)!=null ? String.valueOf(mh.get(fldName)).split(';') : new List<String>());
									setSel.addAll(mhist.get(fldName)!=null ? String.valueOf(mhist.get(fldName)).split(';') : new List<String>());
							
									String tmp='';
									for (String s : setSel)
									{
										tmp+=(s+';');
									}
									mh.put(fldName, tmp);
								} 
								else
								{
									// replace nulls
									if (mh.get(fldName)==null && mhist.get(fldName)!=null)
									{
										mh.put(fldName, mhist.get(fldName));
									}
								}
							}
						}
					}
				}
			}
			return mh;
		}
		set {
			mh = value;	
		}
	}
	
	public Boolean medicalHistoryFetchFromDB 
	{
		get {
			if (medicalHistoryFetchFromDB == null){
				medicalHistoryFetchFromDB = false;
			}
			return medicalHistoryFetchFromDB;
		}
		set;
	}
	
	// does the mh query for the patient
	public List<Medical_History_gne__c> medicalHistoryList
	{
		get
		{
			if (listMH==null)
			{
				Set<String> setProds=getProducts();
				String patientId=patenrol.Patient_gne__c;
			
				listMH=(List<Medical_History_gne__c>) Database.query(mhSOQL);	
			}
			return listMH;
		}
	}
	
	// gets latest medical histories for the patient and the selected product list
	public Map<String,Medical_History_gne__c> medicalHistories 
	{ 
		get
		{
			if (mapMH==null)
			{
				Map<String, Schema.RecordTypeInfo> mapRecordTypes=Schema.SObjectType.Medical_history_gne__c.getRecordTypeInfosByName();
				Set<String> setProds=getProducts();
				String patientId=patenrol.Patient_gne__c;

				mapMH=new Map<String,Medical_History_gne__c> ();
				
				
				for (Medical_History_gne__c mhist: medicalHistoryList) 
				{
					if (!mapMH.containsKey(mhist.Recordtype.Name))
					{
						mapMH.put(mhist.Recordtype.Name, mhist);					
					}
				}
				
				for (String prod : setProds)
				{
					if (!mapMH.containsKey(prod))
					{   
						mapMH.put(prod, new Medical_History_gne__c(Patient_Med_Hist_gne__c = patenrol.Patient_gne__c, 
														RecordTypeId = mapRecordTypes.get(prod).getRecordTypeId()));
					}				
				}
			}
			return mapMH;
		}
	}
	
	//the new property
	public String product 
	{ 
		get;
		set
		{
			if(value != null)
			{
				product  = value;
				if(pageController != null) 
				{
					pageController.setComponentControllerMap(product, this);
					if (!bPERFieldsInit)
					{
						// make sure we can do product specific mapping
						initPERFields();
						// notify our controller that we're setup.
						pageController.componentControllerSetupComplete(product);
						bPERFieldsInit=true;
					}
				}
			}
		}
	}

	public GNE_CM_IntPER_MainClass_Base pageController 
	{
		get; 
		set 
		{
			if (value != null) 
			{
				pageController = value;
				pageController.setComponentController(this);
			}
		}
	}
	
	
	// method to copy any missing MH fields to the PER
	// for cases where we'll still need to use the per
	public virtual void initPERFields()
	{  
		if(medicalHistory != null)
		{		
	     patenrol.Drug_Allergies_gne__c = (medicalHistory.NKDA_gne__c=='Yes' ? 'NKDA' : (medicalHistory.Drug_Allergies_gne__c!=null ? 'Drug Allergies' : null));
		} 
	}
	
	// helper to get Pickval
	protected String getNKDAValue()
	{
		return (patenrol.Drug_Allergies_gne__c=='NKDA' ? 'Yes' : (patenrol.Drug_Allergies_gne__c=='Drug Allergies' ? 'No' : null));
	}
	
    
    public string ICD9_Code_match(string inputval)
    {
        try
        {
            Pattern MyPattern = Pattern.compile('[0-9]{3}[.][0-9]{1,2}|[0-9]{3}');
            Matcher MyMatcher = MyPattern.matcher(inputval);
            if(MyMatcher.find())
            {
                return MyMatcher.group(0);
            }
            else
            	return null;
        }
        catch(exception e)
        {
            ApexPages.addMessages(e);
            return null; 
        }
    }
	
	public static String lookupDiseaseState(String IDC9Id)
	{
		String ret=null;
		List<ICD9_Code_gne__c> lst=[SELECT Id, Disease_State_gne__c FROM ICD9_Code_gne__c WHERE Id=:IDC9Id];
		
		if (!lst.IsEmpty())
		{
			ret=lst[0].Disease_State_gne__c;
		}
		
		return ret;
	}
	
	public virtual String getErrorsJSON()
	{
		return JSON.serialize(errors);	
	}
	
	public virtual Boolean validateInput()
	{
		errors.clear();		
		return (errors.size()==0);
	}
		
	public virtual Set<String> getProducts()
	{
		return new Set<String>();
	}
	
	public virtual List<String> getMHKeys()
	{
		List<String> lst=new List<String>();
		lst.addAll(getProducts());
		return lst;
	}

	public virtual Map<String, String> saveMH()
	{
		 Map<String, String> mapRet=new Map<String, String>();
		 
		 return mapRet;
	}
	
	
	// helper to get configured Disease States
	public List<SelectOption> getDiseaseStates() 
	{
		List<SelectOption> lstSel=new List<SelectOption>();
		
		lstSel.add(new SelectOption('',''));
		for (Schema.Picklistentry ple : Medical_History_gne__c.Disease_state_gne__c.getDescribe().getPicklistValues())
		{
			lstSel.add(new SelectOption(ple.getLabel(), ple.getValue()));
		}
		return lstSel;
	}
	
	public PageReference lookupPopulate()
	{
		if (patenrol.ICD9_Code_1_gne__c!=null) 
		{
			patenrol.Disease_state_gne__c=lookupDiseaseState(patenrol.ICD9_Code_1_gne__c);
		}
		return null;
	}
	
}