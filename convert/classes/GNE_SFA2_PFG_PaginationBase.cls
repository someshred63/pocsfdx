public virtual class GNE_SFA2_PFG_PaginationBase 
{
	private Map<String, Boolean> sortDirection;  
    private ApexPages.StandardSetController stdSetController;
    private List<Object> dataset;
  	private Integer offset=0;
    private Integer pageSize=10;
    
    public String sortImage {get; set;}
    public String sortField {get; set;}
    
    public GNE_SFA2_PFG_PaginationBase()
    {
      sortDirection = new Map<String, Boolean>(); 
    }
    
    protected Boolean getSortDirection(String sortField)    
    {      
        if(sortDirection.keySet().contains(sortField))
        {
            Boolean isAsc = !sortDirection.get(sortField);
            sortDirection.put(sortField, isAsc);
        }
        else
        {
            sortDirection.put(sortField, false);
        }
        return sortDirection.get(sortField);    
    }
    
    protected void initSetController(List<sObject> collection, Integer pageSize)
    {  	
        stdSetController = new ApexPages.StandardSetController(collection);
        stdSetController.setPageSize(pageSize);
    }
    
    protected void initSetController(List<Object> collection, Integer pPageSize)
    {
        dataset = collection;
        Integer recordLimit = 1000;    
    	// if we're bigger that the limit
	    if (dataset.size()>recordLimit)
	    {
	      List<Object> lstTemp=new List<Object>();
	      for (Integer idx=0; idx<recordLimit; idx++)
	      {
	        lstTemp.add(dataset[idx]);
	      }
	      
	      dataset.clear();
	      dataset.addAll(lstTemp);
	    }
        pageSize = pPageSize;
        offset = 0;
    }

    
  protected List<Object> getRecords()
  {
    List<Object> lstRet=new List<Object>();
    if (stdSetController!=null)
    {
      return (List<Object>) stdSetController.getRecords();
    }
    else if (dataset!=null)
    {
      for (Integer idx=offset; idx<(offset+pageSize) && idx<dataset.size(); idx++)
      {
        lstRet.add(dataset[idx]);
      }
    }
    return lstRet;
  }    
  
    protected ApexPages.StandardSetController getSetController()
    {
        return stdSetController;
    }    
    
   public void previous() 
    {
    if (stdSetController!=null)
    {
      stdSetController.previous();
    }
    else if (dataset!=null)
    {
      offset-=pageSize;
      if (offset<0)
      {
        offset=0;
      }
    }
    }
    
    // returns the next page of records
    public void next() 
    {
    if (stdSetController!=null)
    {
      stdSetController.next();
    }
    else if (dataset!=null)
    {
    	
      if (offset+pageSize<(dataset.size()))
      {
        offset+=pageSize;
      }
      system.debug(offset);
    }
    }
    
    // returns the first page of records
    public void first() 
    {
    if (stdSetController!=null)
    {
      stdSetController.first();
    }
    else if (dataset!=null)
    {
      offset=0;
    }
    }
    
    // returns the last page of records
    // returns the last page of records
    public void last() 
    {
        if (stdSetController!=null)
        {
            stdSetController.last();
        }
        else if (dataset!=null)
        {
            offset = (dataset.size()/pageSize)*pageSize;
            if (offset >= dataset.size() && offset > pageSize)
            {
                offset -= pageSize;
            }
        }
    }
    
    // indicates whether there are more records after the current page set. 
    public Boolean hasNext 
    {
        get 
    {
          if(stdSetController != null)
      {
              return stdSetController.getHasNext();
            }
      else if (dataset!=null)
      {
              return ((dataset.size()-offset)>pageSize);
      }
      else
      {
        return false;
      }
        }
        private set;
    }
    
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious 
    {
        get 
    {
           if(stdSetController != null)
      {
              return stdSetController.getHasPrevious();
            }
      else if (dataset!=null)
      {
              return (offset>0);
      }
      else
      {
        return false;
      }
    }
        private set;
    }
}