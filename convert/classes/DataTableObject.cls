global class DataTableObject {

    private Integer iTotalRecords {get; set;}
    private Integer iTotalDisplayRecords {get; set;}
    private String  sEcho {get; set;}
    private List<sObject> aaData {get; set;}

    public DataTableObject() {}

    public DataTableObject(Integer iTotalRecords, Integer iTotalDisplayRecords, String sEcho, List<sObject> aaData) {
        this.iTotalRecords = iTotalRecords;
        this.iTotalDisplayRecords = iTotalDisplayRecords;
        this.sEcho = sEcho;
        this.aaData = aaData;
    }

}