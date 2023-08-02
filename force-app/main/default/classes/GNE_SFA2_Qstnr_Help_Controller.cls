public class GNE_SFA2_Qstnr_Help_Controller{


  public String helpText {get;set;}
 public GNE_SFA2_Qstnr_Help_Controller(){
 
   helpText = (System.currentPageReference().getParameters().get('helpText')!=null)?(System.currentPageReference().getParameters().get('helpText')):'';
   
 }
 
 }