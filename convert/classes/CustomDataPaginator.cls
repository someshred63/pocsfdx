/**
 * Utility class to encapsulate the basics of custom pagination for any custom 
 * data container/controller when the data is organized into collection of elements 
 * which can be divided into pages.
 * @author michal.zaganczyk@contractors.roche.com
 */
public virtual class CustomDataPaginator 
{
	/**
	 * Stores the size of the page (number of items per one page).
	 */
	private Integer pageSize = 10;
	
	/**
	 * Stores the number of all items (on all pages).
	 */
	private Integer numItems = 0;
	
	/**
	 * Stores the number of pages calculated from number of all items and page size.
	 */
	private Integer numPages = 0;
	
	/**
	 * Stores the current page index (zero based).
	 */
	private Integer pageIndex = 0;
	
	/**
	 * Returns the size of the page (number of items per one page).
	 */
	public Integer getPageSize()
	{
		return this.pageSize;
	}
	
	/**
	 * Sets the size of the page (number of items per one page).
	 *
	 * @param value The size of page to set. 
	 *			  This value is normalized to always be greater than 0. 
	 */
	public void setPageSize(Integer value)
	{
		if ((value > 0) && (value != this.pageSize))
		{
			this.pageSize = value;
			this.numPages = this.numItems / this.pageSize;
			if (Math.mod(this.numItems, this.pageSize) != 0)
				this.numPages++;
			this.setPageIndex(0);
		}
	}
	
	/**
	 * Returns the number of all items (on all pages).
	 */
	public Integer getNumItems()
	{
		return this.numItems;
	}
	
	/**
	 * Sets the number of all items (on all pages).
	 *
	 * @param value The number of all items (on all pages) to set. 
	 *			  This value is normalized to always be greater than or equal to 0.
	 */
	public void setNumItems(Integer value)
	{
		if ((value >= 0) && (value != this.numItems))
		{
			this.numItems = value;
			this.numPages = this.numItems / this.pageSize;
			if (Math.mod(this.numItems, this.pageSize) != 0)
				this.numPages++; 
			this.setPageIndex(0);
		}
	}
	
	/**
	 * Returns the number of pages calculated from number of all items and page size.
	 */
	public Integer getNumPages()
	{
		return this.numPages;
	}

	/**
	 * Returns the current page index (zero based).
	 */
	public Integer getPageIndex()
	{
		return this.pageIndex;
	}
	
	/**
	 * Sets the current page index (zero based).
	 *
	 * @param value The current page index to set.
	 *			  This value is normalized to always be greater than or equal to 0, and less than number of pages. 
	 */
	public void setPageIndex(Integer value)
	{
		if ((value >= 0) && (value < this.numPages))
		{
			if (value != this.pageIndex)
			{
				this.pageIndex = value;
				this.pageIndexChanged();
			}
		}
	}
	
	/**
	 * Virtual method to override in descendant classes to handle the change of the current page index.
	 */
	public virtual void pageIndexChanged()
	{
	}
	
	/**
	 * Returns the absolute index of the first item of the current page. 
	 */
	public Integer getAbsIndexOfFirstItemOnCurrentPage()
	{
		return (this.pageIndex * this.pageSize);
	}
	
	/**
	 * Returns the absolute index of the last item of the current page.
	 */
	public Integer getAbsIndexOfLastItemOnCurrentPage()
	{
		if ((this.pageIndex + 1) < this.numPages)
			return (((this.pageIndex + 1) * this.pageSize) - 1);
		else
			return this.numItems - 1;
	}
	
	/**
	 * Moves current page index to the first page (page index 0).
	 */
	public void gotoFirstPage()
	{
		this.setPageIndex(0);
	}
	
	/**
	 * Moves current page index to the previous page if possible.
	 */
	public void gotoPrevPage()
	{
		this.setPageIndex(this.pageIndex - 1);
	}
	
	/**
	 * Moves current page index to the next page if possible.
	 */
	public void gotoNextPage()
	{
		this.setPageIndex(this.pageIndex + 1);
	}
	
	/**
	 * Moves current page index to the last page.
	 */
	public void gotoLastPage()
	{
		this.setPageIndex(this.numPages - 1);
	}
	
	/**
	 * Checks if moving back (to previous or first page) is possible from the current page. 
	 */
	public Boolean getCanGoBack()
	{
		return (this.pageIndex > 0);
	}
	
	/**
	 * Checks if moving forward (to next or last page) is possible from the current page.
	 */
	public Boolean getCanGoForward()
	{
		return (this.pageIndex < this.numPages - 1);
	}
}