public with sharing class GNE_SFA2_Calendar_Controller {
	
	public String eventType { get; set; }
	public String objectId { get; set; }
	public String objectField { get; set; }
	public List<String> visibleFields { get; set; }
	public String dateTimeField { get; set; }
	public String separator { get; set; }
	public Boolean weekMode { get; set; }
	
	private static String DATE_FORMAT = 'h:mm a'; 	
	
	public List<GNE_SFA2_Calendar_Item> calendarItems { get; set; }
	
	private static List<String> trimStrings(List<String> strings) {
		List<String> result = new List<String>();
		for(String item : strings) {
			result.add(item.trim());
		}
		return result;
	}
	
	@RemoteAction
	public static List<GNE_SFA2_Calendar_Item> getCalendarEvents(String eventType, String startDateString, String endDateString, String objectId, String objectField, String separator, List<String> visibleFields, String dateTimeField) {
		visibleFields = GNE_SFA2_Calendar_Controller.trimStrings(visibleFields);
		Set<String> visibleFieldsSet = new Set<String>(visibleFields);
		visibleFieldsSet.remove(dateTimeField);
		
		List<String> parsedStartDate = startDateString.split('/');	// assume date format YYYY/MM/dd
		Datetime startDate = Datetime.newInstance(Integer.valueOf(parsedStartDate[0]), Integer.valueOf(parsedStartDate[1]), Integer.valueOf(parsedStartDate[2]), 0, 0, 0);
		system.debug('startDate: '+startDate);
		
		List<String> parsedEndDate = endDateString.split('/');	// assume date format YYYY/MM/dd
		Datetime endDate = Datetime.newInstance(Integer.valueOf(parsedEndDate[0]), Integer.valueOf(parsedEndDate[1]), Integer.valueOf(parsedEndDate[2]), 23, 59, 59);
		system.debug('endDate: '+endDate);
		
		String theQuery = 'SELECT ' + dateTimeField + ',';
        // Continue building your dynamic query string
        for(String field : new List<String>(visibleFieldsSet)){
           theQuery += field + ',';
        }
        // Trim last comma
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        theQuery += ' FROM '+ eventType + ' WHERE ' + dateTimeField + ' > :startDate AND ' + dateTimeField + ' < :endDate';

        if(objectField != null && objectId != null) {
			theQuery += ' AND ' + objectField + '= \'' + objectId + '\'';
		}
		system.debug('getCalendarEvents query: '+theQuery);
		
		List<GNE_SFA2_Calendar_Item> result = new List<GNE_SFA2_Calendar_Item>();
		for(List<sObject> records : Database.query(theQuery)) {
			for(sObject record : records) {
				String eventDescription = '';
				for(String visibleField : visibleFields) {
					System.debug(record.get(visibleField.trim()));
					if(record.get(visibleField.trim()) instanceof Datetime) {
						eventDescription += ((Datetime)record.get(visibleField.trim())).format(DATE_FORMAT) + ' ' + separator + ' ';
					} else {
						eventDescription += record.get(visibleField.trim()) + ' ' + separator + ' ';
					}
				}
				eventDescription = eventDescription.subString(0, eventDescription.length() - 3);
				
				Datetime eventDateTime = (Datetime)record.get(dateTimeField.trim());
				System.debug(eventDateTime);
				String dateTimeString = '';
				if(eventDateTime != null) {
					dateTimeString = eventDateTime.format('yyyy/MM/dd H:mm');
				}				

				result.add(new GNE_SFA2_Calendar_Item((Id)record.get('Id'), dateTimeString, eventDescription));
			}
		}
		return result;
	}
}