/**
* Class is used to parse web servoces error messages.
*/
public  class gFRS_XmlErrorMessageReader {

   /**
   * Custom class which holds one error data
   */
   public class Error {
     public String pathName;
     public String errorCode;
     public String errorMessage;
     
     public String getMessage(){
     	String[] fieldNames = this.pathName.split('/');
     	return fieldNames[fieldNames.size()-1]+': '+this.errorMessage.replaceAll('\\[.+?\\]','');
     }
   }

   /**
   * Method parses root element
   */	
   public Error[] parseErrors(XmlStreamReader reader) {
     Error[] errors = new Error[0];
     while(reader.hasNext()) {
         if (reader.getEventType() == XmlTag.START_ELEMENT) {
            if ('errors' == reader.getLocalName()) {
                Error error = parseError(reader);
                errors.add(error);
            }
         }
        reader.next();
     }
    return errors;
   }
   
   /**
   * Method parses errors element
   */
   private Error parseError(XmlStreamReader reader) {
     Error error = new Error();
     while(reader.hasNext()) {
     	if(reader.getLocalName() == null){
     		reader.next();
     	}
     	if(reader.getLocalName() == 'errors' && reader.getEventType() == XmlTag.END_ELEMENT){
     		break;
     	}
        if (reader.getEventType() == XmlTag.START_ELEMENT) {
			if ('pathName' == reader.getLocalName()) {
            	reader.next();
            	error.pathName = reader.getText();
            } else if ('errorCode' == reader.getLocalName()){
            	reader.next();
            	error.errorCode = reader.getText();
            } else if ('errorMessage' == reader.getLocalName()){
            	reader.next();
            	error.errorMessage = reader.getText();
            }
        }
        reader.next();
     }
     return error;
   }


}