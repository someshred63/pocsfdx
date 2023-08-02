public with sharing class EMS_Event_Message_Handler {

    public static String cannotReopenEvent() {
        return 'Cannot reopen event, because event history is not available.';
    }

    public static String cannotUncancelEvent() {
        return 'Cannot uncancel event, because event history is not available.';
    }

    public static String successfulSubmission() {
        return 'Your event was submitted successfully';
    }

    public static String validationException(String errorMessage) {
        if (errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
            errorMessage = errorMessage.substring(errorMessage.indexOf('_EXCEPTION,')).removeStart('_EXCEPTION,');
            errorMessage = errorMessage.substring(0, errorMessage.indexOf(': ['));
        }
        return errorMessage;
    }

    public static String approveEventException(String errorMessage) {
        if (errorMessage.contains('MANAGER_NOT_DEFINED')) {
            return 'Event approver not found. Please verify if the event approver is active and not empty.';
        } else if (errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
            return errorMessage.substring(errorMessage.indexOf('_EXCEPTION,')).removeStart('_EXCEPTION,').removeEnd(': []');
        } else {
            return errorMessage;
        }
    }


}