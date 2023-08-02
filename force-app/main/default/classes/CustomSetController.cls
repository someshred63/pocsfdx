/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-11-26
*  Description: This is a class for handling pagination of List of objects
*  
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public with sharing class CustomSetController {
	private Integer pageSize;
	private Integer currentPageNumber;
	private Integer currentPageSize;
	private Integer totalPageNumber;
	private List<Object> objectList;
	
	public CustomSetController(List<Object> objectList, Integer pageSize) {
		this.objectList = objectList;
		this.pageSize = pageSize;
		
		initVariables(0);
	}
	
	private void initVariables(Integer pageNum) {
		currentPageNumber = pageNum;		
		totalPageNumber = (Integer.valueOf(Math.ceil(Double.valueOf(objectList.size()) / Double.valueOf(pageSize))));
		if(totalPageNumber == 0) {
			//handle no records case
			totalPageNumber++;
		}
		if((currentPageNumber + 1) > totalPageNumber) {
			currentPageNumber = totalPageNumber - 1;
		}
	}
	
	public void setObjectList(List<Object> objectList) {
		this.objectList = objectList;
		initVariables(currentPageNumber);
	}
	
	public List<Object> getRecords() {
		List<Object> result = new List<Object>();
		Integer startIndex = currentPageNumber * pageSize;
		Integer endIndex;
		
		if((currentPageNumber * pageSize) + pageSize > objectList.size()) {
			endIndex = objectList.size();
		} else {
			endIndex = (currentPageNumber * pageSize) + pageSize;
		}
		for(Integer i = startIndex; i < endIndex; i++) {
			result.add(objectList[i]);
		}
		currentPageSize = objectList.size();
		return result;
	}
	
	public void last() {
		currentPageNumber = totalPageNumber;
	}
	
	public void first() {
		currentPageNumber = 0;
	}
	
	public void next() {
		currentPageNumber++;
	}
	
	public void previous() {
		currentPageNumber--;
	}
	
	public Boolean hasNext() {
		return (currentPageNumber != totalPageNumber - 1);
	}
	
	public Boolean hasPrevious() {
		return (currentPageNumber > 0);
	}
	
	public Integer getPageNumber() {
		return (currentPageNumber + 1);
	}
	
	public Integer getTotalPageNumbers() {
		return totalPageNumber;
	}
	
	public Integer getPageSize() {
		return pageSize;
	}
	
	public Integer getCurrentPageSize() {
		return currentPageSize;
	}
}