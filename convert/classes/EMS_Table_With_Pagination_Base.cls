public abstract class EMS_Table_With_Pagination_Base {
    public Map<String, String> filterMap { get; set; }
    public Map<String, Set<SelectOption>> picklistValueMap { get; set; }
    public Map<String, List<String>> picklistFilterMap { get; set; }

    public EMS_Table_With_Pagination_Base() {
        filterMap = new Map<String, String>();
        picklistValueMap = new Map<String, Set<SelectOption>>();
        picklistFilterMap = new Map<String, List<String>>();
    }

    public virtual PageReference updateSelectedRecords() {
        return null;
    }

    public virtual pageReference applyFilters() {
        return null;
    }

    protected void initializeFilters(List<String> fieldNames) {
        for (String fieldName : fieldNames) {
            initializeFilter(fieldName);
        }
    }

    protected void checkFilters(List<String> fieldNames) {
        for (String fieldName : fieldNames) {
            checkFilter(fieldName);
        }
    }

    protected void checkFilter(String fieldName) {
        if (!filterMap.containsKey(fieldName) || filterMap.get(fieldName) == null) {
            filterMap.put(fieldName, '');
        }
        if (!picklistFilterMap.containsKey(fieldName) || picklistFilterMap.get(fieldName) == null) {
            picklistFilterMap.put(fieldName, new List<String>());
        }
    }

    protected void initializeFilter(String fieldName) {
        filterMap.put(fieldName, '');
        picklistFilterMap.put(fieldName, new List<String>());
        picklistValueMap.put(fieldName, new Set<SelectOption>());
    }

    protected void clearPicklistValues() {
        for (String key : picklistValueMap.keySet()) {
            picklistValueMap.get(key).clear();
        }
    }

    protected void addPicklistFilterValue(String fieldName, String picklistValue) {
        addPicklistFilterValue(fieldName, picklistValue, picklistValue);
    }

    protected void addPicklistFilterValue(String fieldName, String picklistLabel, String picklistValue) {
        if (!picklistValueMap.containsKey(fieldName)) {
            picklistValueMap.put(fieldName, new Set<SelectOption>());
        }

        picklistValueMap.get(fieldName).add(new SelectOption(picklistValue, picklistLabel));
    }
}