@isTest
private class CustomDataPaginator_Test
{
	static testMethod void testCalculations()
	{
		CustomDataPaginator p = new CustomDataPaginator();
		p.setNumItems(27);
		System.assertEquals(27, p.getNumItems());
		
		p.setPageSize(1);
		System.assertEquals(1, p.getPageSize());
		System.assertEquals(27, p.getNumPages());
		
		p.setPageSize(10);
		System.assertEquals(10, p.getPageSize());
		System.assertEquals(3, p.getNumPages());

		p.gotoFirstPage();
		System.assertEquals(0, p.getPageIndex());
		System.assertEquals(true, p.getCanGoForward());
		System.assertEquals(false, p.getCanGoBack());
		System.assertEquals(0, p.getAbsIndexOfFirstItemOnCurrentPage());
		System.assertEquals(9, p.getAbsIndexOfLastItemOnCurrentPage());
		
		p.gotoNextPage();
		System.assertEquals(1, p.getPageIndex());
		System.assertEquals(true, p.getCanGoBack());
		System.assertEquals(true, p.getCanGoForward());
		System.assertEquals(10, p.getAbsIndexOfFirstItemOnCurrentPage());
		System.assertEquals(19, p.getAbsIndexOfLastItemOnCurrentPage());
		
		p.gotoLastPage();
		System.assertEquals(2, p.getPageIndex());
		System.assertEquals(true, p.getCanGoBack());
		System.assertEquals(false, p.getCanGoForward());
		System.assertEquals(20, p.getAbsIndexOfFirstItemOnCurrentPage());
		System.assertEquals(26, p.getAbsIndexOfLastItemOnCurrentPage());
		
		p.setPageIndex(2);
		p.gotoPrevPage();
		System.assertEquals(1, p.getPageIndex());
		System.assertEquals(true, p.getCanGoBack());
		System.assertEquals(true, p.getCanGoForward());
		System.assertEquals(10, p.getAbsIndexOfFirstItemOnCurrentPage());
		System.assertEquals(19, p.getAbsIndexOfLastItemOnCurrentPage());
		
		p.setPageIndex(1);
		System.assertEquals(1, p.getPageIndex());
		System.assertEquals(true, p.getCanGoBack());
		System.assertEquals(true, p.getCanGoForward());
		System.assertEquals(10, p.getAbsIndexOfFirstItemOnCurrentPage());
		System.assertEquals(19, p.getAbsIndexOfLastItemOnCurrentPage());
		
	}
}