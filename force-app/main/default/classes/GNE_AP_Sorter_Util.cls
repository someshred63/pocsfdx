public class GNE_AP_Sorter_Util {

    private String column;
    public String sortDirection;
    public final static String SORT_ASC = 'ASC';
    public final static String SORT_DESC = 'DESC';
 
    public GNE_AP_Sorter_Util(String defaultSortColumn, String defaultSortDirection){
        this.column = defaultSortColumn;
        this.sortDirection = defaultSortDirection;
    }
 
    public String getSortDirection() {
        return this.sortDirection;
    }
 
    public String getColumn() {
        return this.column;
    }
 
    public void setColumn(String columnName) {
        if (column.equalsIgnoreCase(columnName)) {
            sortDirection = (sortDirection.equals(SORT_ASC)) ? SORT_DESC : SORT_ASC;
        } else {
            this.sortDirection = SORT_ASC;
            this.column = columnName;
        }
    }
}