global class GNE_Subscribe_Territory_WS {
	WebService static String executeProcess(Boolean prevMode) {
		System.enqueueJob(new GNE_Subscribe_Territory_Queueable(prevMode));
    	return null;
	}
}