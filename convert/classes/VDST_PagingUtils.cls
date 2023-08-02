/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Paging Util class
*/
public without sharing virtual class VDST_PagingUtils {
    public  Integer     actualPage      { get; set; }
    public  Integer     totalElements   { get; set; }
    public  Integer     totalPages      { get; set; }
    private Integer     maxOnPage       { get; set; }

    public Integer perPage {
	    get;
	    set {
	        perPage = value;
	        if(totalElements > 0) {
	            setParameters(totalElements);
	        }
	    }
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description VDST_PagingUtils constructor
    */
    public VDST_PagingUtils(Integer perPageVal) {
    	totalElements = 0;
        perPage = perPageVal;
        actualPage = 1;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Get per page options
    * @return List<SelectOption>
    */
    public List<SelectOption> getPerPageOptions() {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('5', '5'));
        optionList.add(new SelectOption('10', '10'));
        optionList.add(new SelectOption('25', '25'));
        optionList.add(new SelectOption('50', '50'));
        optionList.add(new SelectOption('100', '100'));
        optionList.add(new SelectOption('500', '500'));
        return optionList;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Set first page
    * @return PageReference
    */
    public PageReference firstPage() {
        actualPage = 1;
        return null;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Set previous page
    * @return PageReference
    */
    public PageReference prevPage() {
        if(actualPage > 1) actualPage--;
        return null;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Set next page
    * @return PageReference
    */
    public PageReference nextPage() {
        if(actualPage < totalPages) actualPage++;
        return null;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Set last page
    * @return PageReference
    */
    public PageReference lastPage() {
        actualPage = totalPages;
        return null;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Change per page value
    * @return PageReference
    */
    public PageReference changePerPageValue() {
        actualPage = 1;
        return null;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Set pagination util parameters
    * @param Integer listSize
    */
    public void setParameters(Integer listSize) {
        if(listSize > 0) {
            if(actualPage <= 0) {
                actualPage = 1;
            }
            if(perPage == null) {
                perPage = 5;
            }
            maxOnPage = actualPage * perPage;
            if(listSize < actualPage * perPage) {
                maxOnPage = listSize;
            }
            Decimal totalPagesDec = (Decimal)listSize / (Decimal)perPage;
            totalPages = (totalPagesDec.round(RoundingMode.UP)).intValue();
            totalElements = listSize;
            if(actualPage > totalPages) {
                actualPage = totalPages;
            }
        } else {
            totalElements = 0;
            totalPages = 0;
        }
    }
}