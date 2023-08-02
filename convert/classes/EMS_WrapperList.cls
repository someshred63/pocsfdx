public with sharing class EMS_WrapperList {
    public String actionLabel { get; set; }
    public String selectLabel { get; set; }
    public List<EMS_Wrapper> objectList { get; set; }
    public Map<String, String> headersMap { get; set; }
    public List<String> fieldNames { get; set; }

    public Map<String, String> fieldTypesMap { get; set; }
    public Map<String, String> linkActionMap { get; set; }

    public Map<String, String> actionColumnMap { get; set; }
    public Map<String, Boolean> selectCheckboxesColumnMap { get; set; }

}