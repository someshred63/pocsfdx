global class MedAffairs_ErrorLogUtils 
{
	static final String EXCEPTION_MISSING = 'Exception thrown missing';
	static final String LINE_NUMBER_MISSING = 'Line number missing';
	static final String PROJECT_NAME_MISSING = 'Project Name missing';
	static final String SNIPPET_MISSING = 'Snippet missing';
	static final String UNABLE_TO_LOG_ERROR  = 'Unable to log error';
	/*
		Method used to log MedAffairs errors.
		Errors logged in MedAffairs_Error_Logs__c object.
		Exception exceptionObj - exception thrown by compiler - required
		String objectName - object on which error occured - only for DML exceptions
		String projectName - name which will point on MedAffairs project ex. gStars - required
		String snippet - ClassName:MethodName - required
		String recordId - Id of record for single record operations - optional
	*/
	public static String logError(Exception exceptionObj, String objectName, String projectName, String snippet, String recordId)
	{
		String operationStatus = 'Following errors occured during logging errors: ';
		Boolean hasErrors = false;
		if(exceptionObj == null)
		{
			hasErrors = true;
			operationStatus += '['+ EXCEPTION_MISSING + '] ';
		}
		if(projectName == '')
		{
			hasErrors = true;
			operationStatus += '[' + PROJECT_NAME_MISSING +'] ';
		}
		if(snippet == '')
		{
			hasErrors = true;
			operationStatus += '[' + SNIPPET_MISSING +'] ';
		}
		if(hasErrors != true)
		{
			try
			{
				MedAffairs_Error_Logs_gne__c errorLog = new MedAffairs_Error_Logs_gne__c(
					Error_Description_gne__c = exceptionObj.getMessage()  + ':' + exceptionObj.getCause() + ':' + exceptionObj.getStackTraceString(),
					Exception_Type_gne__c = exceptionObj.getTypeName(),
					Executed_By_gne__c = UserInfo.getUserId(),
					Line_Number_gne__c = String.valueOf(exceptionObj.getLineNumber()),
					Object_Name_gne__c = objectName,
					Project_Name_gne__c = projectName,
					Record_Id_gne__c = recordId,
					Snippet_Name_gne__c = snippet

				);
				CFAR_SecurityUtils.insertRecord(errorLog);
				operationStatus = 'Success';
			}
			catch(Exception ex)
			{
				operationStatus =  UNABLE_TO_LOG_ERROR + ' [ ' + 
                          exceptionObj.getMessage() + ']. ' + 
                          'logError exception --> ' + ex.getStackTraceString();
			}
		}
		return operationStatus;
	}
	/*
		String errorMessage - ex.getMessage()  + ':' + ex.getCause() + ':' + ex.getStackTraceString() - required
		String exceptionType - ex.getTypeName() - optional
		String lineNumber - String.valueOf(exceptionObj.getLineNumber()) - required
		String objectName - object on which error occured - only for DML exceptions
		String projectName - name which will point on MedAffairs project ex. gStars - required
		String snippet - ClassName:MethodName - required
		String recordId - Id of record for single record operations - optional
	*/
	@future(callout = true)
	public static void logErrorInFuture(String errorMessage, String exceptionType, String lineNumber, String objectName, String projectName, String snippet, String recordId)
	{
		String errors = 'Following errors occured during logging errors: ';
		Boolean hasErrors = false;
		if(errorMessage == '')
		{
			hasErrors = true;
			errors += '['+ EXCEPTION_MISSING + '] ';
		}
		if(lineNumber == '')
		{
			hasErrors = true;
			errors += '[' + LINE_NUMBER_MISSING +'] ';
		}
		if(projectName == '')
		{
			hasErrors = true;
			errors += '[' + PROJECT_NAME_MISSING +'] ';
		}
		if(snippet == '')
		{
			hasErrors = true;
			errors += '[' + SNIPPET_MISSING +'] ';
		}
		if(hasErrors != true)
		{
			try
			{
				MedAffairs_Error_Logs_gne__c errorLog = new MedAffairs_Error_Logs_gne__c(
					Error_Description_gne__c = errorMessage,
					Exception_Type_gne__c = exceptionType,
					Executed_By_gne__c = UserInfo.getUserId(),
					Line_Number_gne__c = lineNumber,
					Object_Name_gne__c = objectName,
					Project_Name_gne__c = projectName,
					Record_Id_gne__c = recordId,
					Snippet_Name_gne__c = snippet
				);
					CFAR_SecurityUtils.insertRecord(errorLog);
			}
			catch(Exception ex)
			{
				system.debug(UNABLE_TO_LOG_ERROR + ' [ ' + 
	                          errorMessage + ']. ' + 
	                          'logError exception --> ' + ex.getStackTraceString());
			}
		}
		else
		{
			system.debug(errors);
		}
	}
}