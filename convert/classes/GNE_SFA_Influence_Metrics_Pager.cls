public without sharing class GNE_SFA_Influence_Metrics_Pager extends GNE_Base_Pager
{
	public List<Influence_Metrics_gne__c> dispList {get; private set;}
	public Integer metricsSize
	{
		get
		{
			return getFullListSize();
		}
		private set;
	}
	public String accountId {get; set;}
	public List<Influence_Metrics_gne__c> searchResults { get; set; }
	private GNE_SFA_Influence_Metrics_Dao dao;
	public GNE_SFA_Influence_Metrics_Pager(Boolean testVal)
	{
		IsTestCase = testVal;
		dao = new GNE_SFA_Influence_Metrics_Dao(IsTestCase);
		currSort = 'Physician_Name_gne__c';
		currSortOrder = 'asc';
	}
	public override List<SObject> getByPager(GNE_Base_Pager pager)
	{		
		searchResults = dao.getByPager(this);
		fullList = searchResults;
		return fullList;
	}
	public override void changeDispData()
    {	
    	dispList = new List<Influence_Metrics_gne__c>{};    	
    	
    	setRecordCount(fullList.size());
    	if (fullList != null && fullList.size() > 0)
    	{   		
    		if (fullList.size() < pageEndPos) pageEndPos = fullList.size();
	    	for (Integer i = pageStartPos; i < pageEndPos + 1; i++) 
	    	{
				dispList.add((Influence_Metrics_gne__c) fullList[i-1]);
			}
		}
    }
    public void sortListBySelfInfluence(String sortField) 
    {
        if (fullList != null && fullList.size() > 0)
        {
            String prevSort = CurrSort;
            List<SObject> tmpfullList = new List<SObject>();
            
            //if previous sort was on same field, switch to do opposite sort
            if (prevSort != null && prevSort.equals(sortField))
            {  
                if (currSortOrder == 'asc')
                {
                    currSortOrder = 'desc';
                } else
                {
                    currSortOrder = 'asc';
                }
            }
            else
            {
                currSortOrder = 'asc';
            }
            
            if (!IsTestCase) 
            {
               Map<double ,List<SObject>> mapToSort = new Map<double ,List<SObject>>();
               
               for(sObject tmp :fullList)
               {
                   Influence_Metrics_gne__c tmp1 = (Influence_Metrics_gne__c)tmp;
                 if(tmp1.Self_Influence_Formula_gne__c != null)
                 {
                       if (pattern.matches('[0-9.]+',tmp1.Self_Influence_Formula_gne__c))
                       {
                           if(mapToSort.containsKey(double.valueof(tmp1.Self_Influence_Formula_gne__c)))
                           {
                                mapToSort.get(double.valueof(tmp1.Self_Influence_Formula_gne__c)).add(tmp1); 
                           }
                           else
                           {
                                List<SObject> influencelist = new List<SObject>();
                                influencelist.add(tmp1);
                                mapToSort.put(double.valueof(tmp1.Self_Influence_Formula_gne__c),influencelist);
                           }
                       }
                       else
                       {
                           tmpfullList.add(tmp1);
                       }
                 }
				 else
                 {
                           tmpfullList.add(tmp1);
                 }
               }
               List<double> keys = new List<double>(mapToSort.keySet());
               keys.sort();
               
               fullList.clear();
                       
                if(currSortOrder.toLowerCase() == 'asc'){
                    for(double t1 : keys)
                    {
                        fullList.addAll(mapToSort.get(t1));
                    }
                    }else if(currSortOrder.toLowerCase() == 'desc'){
                        for(integer i = keys.size()-1; i >= 0; i--){
                            fullList.addAll(mapToSort.get(keys[i]));
                    }
                }
            }
            
            fullList.addAll(tmpfullList);
            CurrSort = sortField;
            setCurrentPage(1);
            changeDispData();
        }
    }
    public void sortListByInboundInfluence(String sortField) 
    {
        if (fullList != null && fullList.size() > 0)
        {
            String prevSort = CurrSort;
            List<SObject> tmpfullList = new List<SObject>();
            
            //if previous sort was on same field, switch to do opposite sort
            if (prevSort != null && prevSort.equals(sortField))
            {  
                if (currSortOrder == 'asc')
                {
                    currSortOrder = 'desc';
                } else
                {
                    currSortOrder = 'asc';
                }
            }
            else
            {
                currSortOrder = 'asc';
            }
            
            if (!IsTestCase) 
            {
               Map<double ,List<SObject>> mapToSort = new Map<double ,List<SObject>>();
               
               for(sObject tmp :fullList)
               {
                   Influence_Metrics_gne__c tmp1 = (Influence_Metrics_gne__c)tmp;
                 if(tmp1.Inbound_Influence_Formula_gne__c != null)
                 {
                       if (pattern.matches('[0-9.]+',tmp1.Inbound_Influence_Formula_gne__c))
                       {
                           if(mapToSort.containsKey(double.valueof(tmp1.Inbound_Influence_Formula_gne__c)))
                           {
                                mapToSort.get(double.valueof(tmp1.Inbound_Influence_Formula_gne__c)).add(tmp1); 
                           }
                           else
                           {
                                List<SObject> influencelist = new List<SObject>();
                                influencelist.add(tmp1);
                                mapToSort.put(double.valueof(tmp1.Inbound_Influence_Formula_gne__c),influencelist);
                           }
                       }
                       else
                       {
                           tmpfullList.add(tmp1);
                       }
                 }
				 else
                 {
                           tmpfullList.add(tmp1);
                 }
               }
               List<double> keys = new List<double>(mapToSort.keySet());
               keys.sort();
               
               fullList.clear();
                       
                if(currSortOrder.toLowerCase() == 'asc'){
                    for(double t1 : keys)
                    {
                        fullList.addAll(mapToSort.get(t1));
                    }
                    }else if(currSortOrder.toLowerCase() == 'desc'){
                        for(integer i = keys.size()-1; i >= 0; i--){
                            fullList.addAll(mapToSort.get(keys[i]));
                    }
                }
            }
            
            fullList.addAll(tmpfullList);
            CurrSort = sortField;
            setCurrentPage(1);
            changeDispData();
        }
    }
    public void sortListByOutboundInfluence(String sortField) 
    {
        if (fullList != null && fullList.size() > 0)
        {
            String prevSort = CurrSort;
            List<SObject> tmpfullList = new List<SObject>();
            
            //if previous sort was on same field, switch to do opposite sort
            if (prevSort != null && prevSort.equals(sortField))
            {  
                if (currSortOrder == 'asc')
                {
                    currSortOrder = 'desc';
                } else
                {
                    currSortOrder = 'asc';
                }
            }
            else
            {
                currSortOrder = 'asc';
            }
            
            if (!IsTestCase) 
            {
               Map<double ,List<SObject>> mapToSort = new Map<double ,List<SObject>>();
               
               for(sObject tmp :fullList)
               {
                   Influence_Metrics_gne__c tmp1 = (Influence_Metrics_gne__c)tmp;
                 if(tmp1.Outbound_Influence_Formula_gne__c != null)
                 {
                       if (pattern.matches('[0-9.]+',tmp1.Outbound_Influence_Formula_gne__c))
                       {
                           if(mapToSort.containsKey(double.valueof(tmp1.Outbound_Influence_Formula_gne__c)))
                           {
                                mapToSort.get(double.valueof(tmp1.Outbound_Influence_Formula_gne__c)).add(tmp1); 
                           }
                           else
                           {
                                List<SObject> influencelist = new List<SObject>();
                                influencelist.add(tmp1);
                                mapToSort.put(double.valueof(tmp1.Outbound_Influence_Formula_gne__c),influencelist);
                           }
                       }
                       else
                       {
                           tmpfullList.add(tmp1);
                       }
                 }
				 else
                 {
                           tmpfullList.add(tmp1);
                 }
               }
               List<double> keys = new List<double>(mapToSort.keySet());
               keys.sort();
               
               fullList.clear();
                       
                if(currSortOrder.toLowerCase() == 'asc'){
                    for(double t1 : keys)
                    {
                        fullList.addAll(mapToSort.get(t1));
                    }
                    }else if(currSortOrder.toLowerCase() == 'desc'){
                        for(integer i = keys.size()-1; i >= 0; i--){
                            fullList.addAll(mapToSort.get(keys[i]));
                    }
                }
            }
            
            fullList.addAll(tmpfullList);
            CurrSort = sortField;
            setCurrentPage(1);
            changeDispData();
        }
    }
    public void sortListByTotalInfluence(String sortField) 
    {
        if (fullList != null && fullList.size() > 0)
        {
            String prevSort = CurrSort;
            List<SObject> tmpfullList = new List<SObject>();
            
            //if previous sort was on same field, switch to do opposite sort
            if (prevSort != null && prevSort.equals(sortField))
            {  
                if (currSortOrder == 'asc')
                {
                    currSortOrder = 'desc';
                } else
                {
                    currSortOrder = 'asc';
                }
            }
            else
            {
                currSortOrder = 'asc';
            }
            
            if (!IsTestCase) 
            {
               Map<double ,List<SObject>> mapToSort = new Map<double ,List<SObject>>();
               
               for(sObject tmp :fullList)
               {
                   Influence_Metrics_gne__c tmp1 = (Influence_Metrics_gne__c)tmp;
                 if(tmp1.Total_Influence_Formula_gne__c != null)
                 {
                       if (pattern.matches('[0-9.]+',tmp1.Total_Influence_Formula_gne__c))
                       {
                           if(mapToSort.containsKey(double.valueof(tmp1.Total_Influence_Formula_gne__c)))
                           {
                                mapToSort.get(double.valueof(tmp1.Total_Influence_Formula_gne__c)).add(tmp1); 
                           }
                           else
                           {
                                List<SObject> influencelist = new List<SObject>();
                                influencelist.add(tmp1);
                                mapToSort.put(double.valueof(tmp1.Total_Influence_Formula_gne__c),influencelist);
                           }
                       }
                       else
                       {
                           tmpfullList.add(tmp1);
                       }
                 }
				 else
                 {
                           tmpfullList.add(tmp1);
                 }
               }
               List<double> keys = new List<double>(mapToSort.keySet());
               keys.sort();
               
               fullList.clear();
                       
                if(currSortOrder.toLowerCase() == 'asc'){
                    for(double t1 : keys)
                    {
                        fullList.addAll(mapToSort.get(t1));
                    }
                    }else if(currSortOrder.toLowerCase() == 'desc'){
                        for(integer i = keys.size()-1; i >= 0; i--){
                            fullList.addAll(mapToSort.get(keys[i]));
                    }
                }
            }
            
            fullList.addAll(tmpfullList);
            CurrSort = sortField;
            setCurrentPage(1);
            changeDispData();
        }
    }
}