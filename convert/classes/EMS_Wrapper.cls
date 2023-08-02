public with sharing virtual class EMS_Wrapper implements Comparable {
    public String compareBy { get; set; }
    public Boolean ascending { get; set; }
    public Boolean selected { get; set; }

    public virtual Integer compareTo(Object compareTo) {
        return null;
    }
}