public class MedicalAffairOptions {

     public String selectedOption{get;set;}
     public String IsContracted;
     //public String SErrMessage {get;set;}
     
     public MedicalAffairOptions(){
     	  IsContracted      = ApexPages.currentPage().getParameters().get('contracted');
     	/* 
     	if(IsContracted.contains('Contracted Services')){
     		selectedOption =  IsContracted + '-- Contracted Services';
     	}
     	if(IsContracted.contains('Without Contracted Services')){     	
     		selectedOption =  IsContracted + '-- Without Contracted Services';
     	}*/
     	
     }
     
    public List<SelectOption>  getMedicalAffairOptions()
	{
		system.debug('----IsContracted'+IsContracted);
		List<SelectOption> options= new List<SelectOption>();
		if(IsContracted.contains('Contracted Services'))
		{
			IsContracted = IsContracted.substring(0,IsContracted.indexOf('-'));
		}
		options.add(new SelectOption(IsContracted + '-- Contracted Services', 'Yes')); 
		options.add(new SelectOption(IsContracted + '-- Without Contracted Services','No'));
		return options; 
	}

}