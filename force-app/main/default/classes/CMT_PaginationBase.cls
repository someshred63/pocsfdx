public virtual class CMT_PaginationBase 
{
	private ApexPages.StandardSetController stdSetController;	
	
	protected void initSetController(List<sObject> collection, Integer pageSize)
	{
		stdSetController = new ApexPages.StandardSetController(collection);
		stdSetController.setPageSize(pageSize);
	}
	
	protected ApexPages.StandardSetController getSetController()
	{
		return stdSetController;
	}
	
	public void previous() 
	{
		stdSetController.previous();
	}
	
	// returns the next page of records
	public void next() 
	{
		stdSetController.next();
	}
	
	// returns the first page of records
	public void first() 
	{
		stdSetController.first();
	}
	
	// returns the last page of records
	public void last() 
	{
		stdSetController.last();	
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
}