/* Class to log errors to LWO_Log__c and email error logs. All logs are written to system log regardless
 * if there are errors or not.
 *
 * 4/11/11 FL - Created
 */
public without sharing class GNE_LWO_Logger {

public static String ENV; 

// Override this in the static method for DEV environment
//static String[] SUPPORT_EMAIL = new String[] {'lwo-support-d@gene.com'};



// log levels
public static final String ERROR = 'Error';
public static final String DEBUG = 'Debug';

// Categories
public static final String SAP_INT = 'SAP Interface';
public static final String DATA = 'Data';
public static final String SYSTEM_ERROR = 'System';

private List<String> logLine;

static {
    ENV = GNE_LWO_CustomSettingsHelper.getEnvironment();
    if(ENV!=null) ENV=ENV.toUpperCase();
    /*if (ENV == 'DEV') {
        // SUPPORT_EMAIL = new String[] {'jiezhenw@gene.com'};
        // SUPPORT_EMAIL = new String[] {'flam@gene.com'};
        SUPPORT_EMAIL = new String[0]; // Use String[0] to disable email notification
    }*/
}


public GNE_LWO_Logger () {
    logLine = new List<String>();
}

private void sendEmail(string MessageBody)
{
    system.debug('Sending email:');
    System.debug(MessageBody);
    String SUPPORT_EMAIL = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().SUPPORT_EMAIL__c;
    
    /*if (SUPPORT_EMAIL.size() == 0) {
        system.debug('Email notification disabled');
        return;
    }*/
    
    try {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(new String[] {SUPPORT_EMAIL});

        // Specify the address used when the recipients reply to the email.
        //mail.setReplyTo('ftahir@salesforce.com');

        // Specify the name used as the display name.
        //mail.setSenderDisplayName('DO NOT REPLY');

        // Specify the subject line for your email address.
        mail.setSubject('SFDC LWO Error');

        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);

        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);

        // Specify the text content of the email.
        mail.setPlainTextBody(MessageBody);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } catch(Exception e) {
        System.debug('Exception is => ' + e.getMessage());
    }
}

/* Append a line to the end of log list */
public void addLine(String textLine) {
    // Add start timestamp
    if (logLine.size() == 0) {
        logLine.add(System.Now().format('MM/dd/yyyy kk:mm:ss'));
    }
    
    logLine.add(textLine);
}

/* Concatenate logs into one string */
private String getString() {
    String logDetail = ENV + ' User ' + GNE_LWO_Controller.userName + '\n\n';
    for (integer i = 0; i < logLine.size(); i++) {
        logDetail += logLine.get(i) + '\n';
    }
        
    if (logDetail.length() > 31940) {
        integer i = logDetail.length();
        logDetail = logDetail.substring(0, 31940) + '...[' + (i-31940) + ' characters discarded]\n';
    }
        
    // Add end timestamp
    logDetail += System.Now().format('MM/dd/yyyy kk:mm:ss');
    
    return logDetail;
}

/* Log errors */
public void save(String textLine, String logLevel, String logCat) {
    if (textLine != null)
        logLine.add(textLine);
    
    if (logLine.size() > 0) {
        // Concate all log lines into 1 string
        String logDetail = getString();
                
        try {
            LWO_Log__c logRec = new LWO_Log__c();
            logRec.level__c = logLevel;
            logRec.category__c = logCat;
            logRec.detail__c = logDetail;
            insert logRec;
            
        } catch (Exception e) {
            System.debug('Error inserting into GNE_LWO_Log: ' + e.getMessage());
        }
        
        sendEmail(logDetail);

        clear();   // clear log entries
    }
}

/* Log debug log */
public void logDebug(String textLine) {
    
    if (textLine != null)
        logLine.add(textLine);
    
    if (logLine.size() > 0) {
        // Concate all log lines into 1 string
        String logDetail = getString();
        
        if (GNE_LWO_Controller.debug) {
            try {
                LWO_Log__c logRec = new LWO_Log__c();
                logRec.level__c = DEBUG;
                logRec.category__c = null;
                logRec.detail__c = logDetail;
                insert logRec;
            
            } catch (Exception e) {
                system.debug('Error inserting into GNE_LWO_Log: ' + e.getMessage());
            }
        }

        System.debug(logDetail);
    }
    
    clear();   // clear log entries}
}

/* Clear the logs */
public void clear() {
    logLine.clear();
}
}