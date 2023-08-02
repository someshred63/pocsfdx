public with sharing class SRW_DateConverterController {
	public SRW_DateConverterController() {
		
	}

	public DateTime dateTimeValue { get; set; }
    public String getTimeZoneValue() {
        if( dateTimeValue != null ) {
            String localeFormatDT = dateTimeValue.format('MM/dd/yyyy hh:mm a');
            return localeFormatDT;
        }
        return null;
    }
}