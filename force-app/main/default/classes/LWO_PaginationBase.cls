public virtual class LWO_PaginationBase 
{
	private ApexPages.StandardSetController stdSetController;
	public integer currPageNumber {get;set;}	

	protected void initSetController(List<sObject> collection, Integer pageSize)
	{
		
		
		stdSetController = new ApexPages.StandardSetController(collection);
		
        system.debug('---------------------------------------------------------------------stdSetController------------'+stdSetController);
		
		stdSetController.setPageSize(pageSize);
		
		system.debug('---------------------------------------------------------------------currPageNumber------------'+ stdSetController.getPageNumber());
		
		
		currPageNumber = stdSetController.getPageNumber();
		
		
		
	}
	
	public void setPageNumber(Integer pageNumber)
	{
		stdSetController.setPageNumber(pageNumber);
		currPageNumber = pageNumber;
	}

	protected ApexPages.StandardSetController getSetController()
	{
		return stdSetController;
	}
	
	public void previous() 
	{
		stdSetController.previous();
		currPageNumber = stdSetController.getPageNumber();
	}
	
	// returns the next page of records
	public void next() 
	{
		stdSetController.next();
		currPageNumber = stdSetController.getPageNumber();
		system.debug('---------------------------------stdSetController-------------'+ stdSetController.getPageNumber());
	}
	
	// returns the first page of records
	public void first() 
	{
		system.debug('---------------------------------stdSetController-------------'+stdSetController);
		stdSetController.first();
	    system.debug('---------------------------------stdSetController.first()-------------'+stdSetController.first());
		
		currPageNumber = stdSetController.getPageNumber();
	}
	
	// returns the last page of records
	public void last() 
	{
		stdSetController.last();	
		currPageNumber = stdSetController.getPageNumber();
	}
	
	// indicates whether there are more records after the current page set. 
	public Boolean hasNext 
	{
		get {
			return stdSetController.getHasNext();
		}
		private set;
	}
	
	// indicates whether there are more records before the current page set.
	public Boolean hasPrevious 
	{
		get {
			return stdSetController.getHasPrevious();
		}
		private set;
	}	 
	
	public integer pageNumber 
	{
		get {
			return (stdSetController.getPageNumber()-1) * stdSetController.getPageSize() + 1;
		}
		private set;
	}
	
	public integer resultsSize 
	{
		get {
			return stdSetController.getResultSize();
		}
		private set;	
	}
	
	public integer pageSize 
	{
		get 
		{
			if(stdSetController.getPageSize() * stdSetController.getPageNumber() > stdSetController.getResultSize())
				return stdSetController.getResultSize(); 
			else
				return stdSetController.getPageSize() * stdSetController.getPageNumber();
		}
		private set;
	}
	
	public integer pageNumbers 
	{
		get 
		{
			return stdSetController.getResultSize() / stdSetController.getPageSize() + 1;
		}
		private set;
	}
	
	public integer resultSize 
	{
		get 
		{
			return stdSetController.getResultSize();
		}
		private set;
	}
	
	public integer pagesSize 
	{
		get 
		{
			return stdSetController.getPageSize();
		}
		private set;
	}
}