public class gFRS_Ltng_W8_Parser {

	public class Pages {
		public Integer order;
		public Integer form_id;
		public Integer page_id;
		public Integer sheet_id;
		public String page_name;
		public String sheet_name;
		public Integer instance_id;
		public Integer batch_file_id;
		public String batch_page_id;
		public String template_name;
	}

	public class Forms {
		public Integer id;
		public List<Data> data;
		public String name;
		public List<Pages> pages;
		public List<Tables_data> tables_data;
		public Integer template_id;
		public List<Tables_data> unstructured_data;
	}

	public class Batch_file_metadata {
		public Metadata metadata;
		public Integer batch_file_id;
	}

	public Integer id;
	public String name;
	public List<Forms> forms;
	public Integer batch_id;
	public Metadata_Z metadata;
	public Integer workflow_id;

	public class Metadata_Z {
		public List<Batch_file_metadata> batch_file_metadata;
	}

	public class Tables_data {
	}

	public class Metadata {
		public String item;
		public String envName;
	}

	public class Data {
		public String uuid;
		public String value;
		public Integer form_id;
		public Integer page_id;
		public Integer field_id;
		public Integer shred_id;
		public String data_type;
		public Boolean is_active;
		public Double confidence;
		public String field_name;
		public Boolean was_edited;
		public Integer form_schema_id;
		public String original_value;
		public Integer schema_field_id;
		public String finalization_criteria_used;
	}

	
	public static gFRS_Ltng_W8_Parser parse(String json) {
		return (gFRS_Ltng_W8_Parser) System.JSON.deserialize(json, gFRS_Ltng_W8_Parser.class);
	}
}