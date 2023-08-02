public class AGS_FormRawWrapper {

    public String reportFieldLabel { get; private set; }
    public String reportFieldLink { get; private set; }
    public String reportFieldValue { get; private set; }

    public String srcFieldLabel { get; private set; }
    public String srcFieldValue { get; private set; }
    public Boolean isComparable { get; private set; }
    private Boolean isSrcAndReportNotBlankAndDifferent;

    public AGS_FormRawWrapper(String reportFieldLabel, String reportFieldValue, String srcFieldLabel, String srcFieldValue) {
        this(reportFieldLabel, reportFieldValue, srcFieldLabel, srcFieldValue, true);
    }
    public AGS_FormRawWrapper(String reportFieldLabel, String reportFieldValue, String srcFieldLabel, String srcFieldValue, Boolean compare) {
        this.reportFieldLabel = reportFieldLabel;
        this.reportFieldValue = reportFieldValue;
        this.srcFieldLabel = srcFieldLabel;
        this.srcFieldValue = srcFieldValue;
        this.isSrcAndReportNotBlankAndDifferent = (reportFieldValue != null && srcFieldValue != null && reportFieldValue.toLowerCase().trim() != srcFieldValue.toLowerCase().trim());
        this.isComparable = compare && isSrcAndReportNotBlankAndDifferent;
    }
}