public class gFRS_Ltng_ElePay_Parser {

	public class Pages {
		public Integer form_id;
		public String template_name;
		public Integer batch_file_id;
		public String sheet_name;
		public Integer instance_id;
		public String page_name;
		public Object batch_page_id;
		public Integer sheet_id;
		public Integer page_id;
		public Integer order;
	}

	public class Forms {
		public List<Tables_data> tables_data;
		public String name;
		public Integer template_id;
		public List<Tables_data> unstructured_data;
		public Integer id;
		public List<Data> data;
		public List<Pages> pages;
	}

	public class Batch_file_metadata {
		public Integer batch_file_id;
		public Tables_data metadata;
	}

	public String name;
	public List<Forms> forms;
	public Integer workflow_id;
	public Integer batch_id;
	public Integer id;
	public Metadata metadata;

	public class Tables_data {
	}

	public class Metadata {
		public List<Batch_file_metadata> batch_file_metadata;
	}

	public class Data {
		public Double confidence;
		public String uuid;
		public String data_type;
		public Object original_value;
		public Boolean is_active;
		public Integer schema_field_id;
		public Integer field_id;
		public String value;
		public String finalization_criteria_used;
		public Boolean was_edited;
		public Integer shred_id;
		public String field_name;
		public Integer form_schema_id;
		public Integer page_id;
		public Integer form_id;
	}

	
	public static gFRS_Ltng_ElePay_Parser parse(String json) {
		return (gFRS_Ltng_ElePay_Parser) System.JSON.deserialize(json, gFRS_Ltng_ElePay_Parser.class);
	}
}