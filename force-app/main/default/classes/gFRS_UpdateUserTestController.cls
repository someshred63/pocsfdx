public with sharing class gFRS_UpdateUserTestController {
    public static String userId {get;set;} 
	public gFRS_UpdateUserTestController( ApexPages.StandardController std ){
	        gFRS_UpdateUserSchema.gFRS_UpdateUserWebService ws = new gFRS_UpdateUserSchema.gFRS_UpdateUserWebService();
	        
	        gFRS_UpdateUserSchema.SessionHeader_element sessionHeader = new gFRS_UpdateUserSchema.SessionHeader_element();
	        sessionHeader.sessionId = UserInfo.getSessionId();
	        ws.SessionHeader = sessionHeader;
	        testUpdateExistingUser();
	}
	  
	public static void  testUpdateNotExistingUser(){
	    gFRS_UpdateUserSchema.gFRS_UpdateUserWebService ws = new gFRS_UpdateUserSchema.gFRS_UpdateUserWebService();
	    gFRS_UpdateUserSchema.SessionHeader_element sessionHeader = new gFRS_UpdateUserSchema.SessionHeader_element();
	    sessionHeader.sessionId = UserInfo.getSessionId();
	    ws.SessionHeader = sessionHeader;
	    userId = ws.UpdateUser('paultest25@modelmetrics.com','paulTestWs2', 'Ptak1234', 'Director of Operations', 'paultest@modelmetrics.com', '555777444', '2345');
	}
	  
	public static void  testUpdateExistingUser(){
	    gFRS_UpdateUserSchema.gFRS_UpdateUserWebService ws = new gFRS_UpdateUserSchema.gFRS_UpdateUserWebService();
	    gFRS_UpdateUserSchema.SessionHeader_element sessionHeader = new gFRS_UpdateUserSchema.SessionHeader_element();
	    sessionHeader.sessionId = UserInfo.getSessionId();
	    ws.SessionHeader = sessionHeader;
	    userId = ws.updateUser('paultest25@modelmetrics.com','paulTestWs3', 'Ptak1234', 'Director of Operations', 'paultest4@modelmetrics.com', '555777444', '33333');
	}
}