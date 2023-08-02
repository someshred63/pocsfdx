public with sharing class EMS_Table_With_Pagination_Ext {

    private static Integer BUFFER = 10;
    private EMS_WrapperList wrappers;

    public Boolean hasPrevious {
        get {
            return currentPage > 1;
        }
    }

    public Boolean hasNext {
        get {
            return currentPage < countPages;
        }
    }

    public Map<Integer, Boolean> pageNumberButtons { get; set; } // Reflects page number buttons
    public Boolean ascending { get; set; }
    public Integer currentPage { get; set; }
    public Integer countPages { get; set; }
    public Integer objectsCount { get; set; }
    public String compareBy { get; set; }
    public List<EMS_Wrapper> records { get; set; }
    public EMS_Table_With_Pagination_Base parentController { get; set; }
    public Id recordId { get; set; }
    public String sectionName { get; set; }


    public EMS_Table_With_Pagination_Ext() {
        currentPage = 1;
        countPages = 0;
        ascending = true;
        pageNumberButtons = new Map<Integer, Boolean>();
    }

    public EMS_WrapperList getWrappersList() {
        return wrappers;
    }

    public void setWrappersList(EMS_WrapperList wrappers) {
        this.wrappers = wrappers;
        if (wrappers != null) {
            countPages = (math.mod(wrappers.objectList.size(), BUFFER) == 0) ? (wrappers.objectList.size() / BUFFER) : ((wrappers.objectList.size() / BUFFER) + 1);
            if (countPages == 0) {
                countPages = 1;
            }
            objectsCount = wrappers.objectList.size();
            pupulatePageNumberButtons();
        }

        if (currentPage == 1 && wrappers != null) {
            fetchFirstPage(wrappers.objectList);
        }
    }

    public void sortTable() {
        for (EMS_Wrapper wrapper : wrappers.objectList) {
            wrapper.compareBy = this.compareBy;
            wrapper.ascending = this.ascending;
        }
        wrappers.objectList.sort();
        showFirstPage();
    }

    private void fetchFirstPage(List<EMS_Wrapper> objects) {
        records = new List<EMS_Wrapper>();
        Integer size = BUFFER;
        if (objects.size() < BUFFER) {
            size = objects.size();
        }
        for (Integer i = 0; i < size; i++) {
            records.add(objects[i]);
        }
    }

    private void fetchLastPage(List<EMS_Wrapper> objects) {
        records = new List<EMS_Wrapper>();
        for (Integer i = ((countPages - 1) * BUFFER); i < objects.size(); i++) {
            records.add(objects[i]);
        }
    }

    private void fetchPreviousOrNextPage(List<EMS_Wrapper> objects) {
        records = new List<EMS_Wrapper>();
        for (Integer i = ((currentPage - 1) * BUFFER) + 1; i <= (currentPage * BUFFER); i++) {
            records.add(objects[i]);
        }
    }

    public void showFirstPage() {
        fetchFirstPage(wrappers.objectList);
        currentPage = 1;
    }

    public void showPreviousPage() {
        currentPage--;
        if (currentPage <= 1) {
            fetchFirstPage(wrappers.objectList);
        } else {
            fetchPreviousOrNextPage(wrappers.objectList);
        }
    }

    public void showNextPage() {
        currentPage++;
        if (currentPage >= countPages) {
            fetchLastPage(wrappers.objectList);
        } else {
            fetchPreviousOrNextPage(wrappers.objectList);
        }
    }

    public void showLastPage() {
        fetchLastPage(wrappers.objectList);
        currentPage = countPages;
    }

    public void goToPage() {
        if (currentPage <= 1) {
            fetchFirstPage(wrappers.objectList);
        } else if (currentPage >= countPages) {
            fetchLastPage(wrappers.objectList);
        } else {
            fetchPreviousOrNextPage(wrappers.objectList);
        }
    }

    private void pupulatePageNumberButtons() {
        pageNumberButtons.clear();
        Boolean renderNext = false;
        for (Integer bNumber = 1; bNumber <= countPages; bNumber++) {
            if (bNumber == 1) {
                pageNumberButtons.put(bNumber, true);// always render first page button

                if (currentPage == 1) { // if current page is the first page, render next one to it
                    renderNext = true;
                } else {
                    renderNext = false;
                }
            } else if (bNumber == countPages) {
                pageNumberButtons.put(bNumber, true);// always render last page button

                if (currentPage == countPages) { // if current page is the last page, render previous two before it
                    if (countPages > 1) { // if there are more then 2 pages, render previous one
                        pageNumberButtons.put(bNumber - 1, true); // replace existing map data
                    }
                }
            } else {
                if (bNumber == currentPage) { // if buttonNumber is currentPage (currentPage), then render it
                    pageNumberButtons.put(bNumber, true); // always render first page button
                    renderNext = true; // next one should be rendered
                    if (countPages > 1) { // render previous one
                        pageNumberButtons.put(bNumber - 1, true); // replace existing map data
                    }
                } else {
                    if (renderNext) {
                        pageNumberButtons.put(bNumber, true);
                        renderNext = false;
                    } else {
                        pageNumberButtons.put(bNumber, false);
                    }
                }
            }
        }
    }
}