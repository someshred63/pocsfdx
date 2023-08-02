/** @date 2/11/2014
* @Author Konrad Malinowski
* @description Test Class for Paging Utils Class
*/
@isTest
private class VDST_PagingUtils_Test {
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getPerPageOptions() method
	*/
	@isTest static void shouldGetPerPageOptions() {
		// GIVEN
		VDST_PagingUtils pageUtil = new VDST_PagingUtils(5);

		// WHEN
		List<SelectOption> perPageOptions = pageUtil.getPerPageOptions();

		// THEN
		Integer numberOfPerPageOptions = 6;
		System.assertEquals( numberOfPerPageOptions, perPageOptions.size() );

		Set<String> recordsPerPageSet = new Set<String>{'5', '10', '25', '50', '100', '500'};
		for(SelectOption so : perPageOptions) {
			System.assert( recordsPerPageSet.contains( so.getValue() ) );
			System.assert( recordsPerPageSet.contains( so.getLabel() ) );
			System.assertEquals( so.getValue(), so.getLabel() );
		}
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changing actual page
	*/
	@isTest static void shouldChangePage() {
		// GIVEN
		VDST_PagingUtils pageUtil = new VDST_PagingUtils(5);
		Integer numberOfListElements = 10;
		pageUtil.setParameters( numberOfListElements );

		// WHEN
		pageUtil.firstPage();
		Integer firstPage = pageUtil.actualPage;

		pageUtil.changePerPageValue();
		Integer firstPageAfterChange = pageUtil.actualPage;
		
		pageUtil.nextPage();
		Integer secondPageAfterNext = pageUtil.actualPage;

		pageUtil.prevPage();
		Integer firstPageAfterPrevious = pageUtil.actualPage;

		pageUtil.lastPage();
		Integer lastPage = pageUtil.actualPage;

		// THEN
		System.assertEquals( 1, firstPage );
		System.assertEquals( 1, firstPageAfterChange );
		System.assertEquals( 2, secondPageAfterNext );
		System.assertEquals( 1, firstPageAfterPrevious );
		System.assertEquals( 2, lastPage );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for setting paging parameters
	*/
	@isTest static void shouldSetParameters() {
		// GIVEN
		VDST_PagingUtils pageUtil = new VDST_PagingUtils(5);
		Integer numberOfListElements = 20;
		pageUtil.setParameters( numberOfListElements );

		// WHEN
		pageUtil.perPage = null;
		pageUtil.setParameters( numberOfListElements );
		Integer perPageShouldBeSetToFive = pageUtil.perPage;

		pageUtil.perPage = 10;
		pageUtil.setParameters( numberOfListElements );
		Integer totalPagesAfterChangeNumberOfDisplayedElements = pageUtil.totalPages;

		pageUtil.actualPage = 0;
		pageUtil.setParameters( numberOfListElements );
		Integer actualPageShouldBeSetToFirst = pageUtil.actualPage;

		pageUtil.actualPage = 3;
		pageUtil.setParameters( numberOfListElements );
		Integer actualPageShouldBeSetToLast = pageUtil.actualPage;

		pageUtil.setParameters( 0 );
		Integer totalElementsShouldBeZero = pageUtil.totalElements;
		Integer totalPagesShouldBeZero = pageUtil.totalPages;

		// THEN
		System.assertEquals( 5, perPageShouldBeSetToFive );
		System.assertEquals( 2, totalPagesAfterChangeNumberOfDisplayedElements );
		System.assertEquals( 1, actualPageShouldBeSetToFirst );
		System.assertEquals( 2, actualPageShouldBeSetToLast );
		System.assertEquals( 0, totalElementsShouldBeZero );
		System.assertEquals( 0, totalPagesShouldBeZero );
	}
}