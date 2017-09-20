public with sharing class Util {
	
	/*
	@description    : Gives the date filter so as to use in SOQL
	@param apiName  : apiName to be used in query string
	@operator       : <,<=,>,>=,=,!=
	@return         : Filter string for SOQL
	*/
	public static String getDateFilter (String apiName,String operator, String value) {                
	        return ' '+apiName+' '+operator+' '+' '+getSOQLFormat(value)+' ';
	}
	
	/*
	@description    : Gives the String format of date so as to use in SOQL
	@param date     : Date in the format mm/dd/yyyy
	@return         : Equivalent date string to be used in SOQL
	*/
	public static String getSOQLFormat(String theDate){
	        return getSOQLFormat(Date.parse(theDate));
	}
	
	/*
	@description    : Gives the String format of date so as to use in SOQL
	@param date     : Instance of date
	@return         : Equivalent date string to be used in SOQL
	*/
	public static String getSOQLFormat(Date theDate){
	        return getSOQLFormat(DateTime.newInstance(theDate.year(),theDate.month(),theDate.day()));
	}
	
	/*
	@description            : Gives the String format of date so as to use in SOQL
	@param theDateTime      : Instance of date time
	@return                 : Equivalent date string to be used in SOQL
	*/
	public static String getSOQLFormat(DateTime theDateTime){
	        return theDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
	}
	
	
	/**
	* @description  : Formats the date according to the specified formatting
	* @param        : date which has to be formatted
	* @format       : Formatting string
	*/
	public static String formatDate(Date theDate, String format){
	 //if date is null then dont format and return blank string
	 if(theDate==null){ 
	         return '';
	 }
	 return Datetime.newInstance(theDate, Time.newInstance(0,0,0,0)).format(format);                 
	}
	
	/**
 	* @description  : Gives the param from the page
 	* @param		: paramName Name of the parameter
 	* @return 		: String value of the parameter
 	*/
 	public static String getParam(String paramName){ 		
 		return ApexPages.currentPage().getParameters().get(paramName); 		
 	} 
 	
	/**
 	* @description  : 
 	* @param		:
 	* @return 		:
 	*/
    public static List<SelectOption> getListOfOptions(String sObjectName, String fieldAPIName, Boolean hasNone){
        List<SelectOption> options = new List<SelectOption>();        
        if(hasNone){
                options.add(new SelectOption('','-None-'));
        }       
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(sObjectName);
        Schema.DescribeSObjectResult objDescribe = SObjectTypeObj.getDescribe();       
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        List<Schema.PicklistEntry> values = fieldMap.get(fieldAPIName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry e : values){ 
                options.add(new SelectOption(e.getLabel(), e.getValue())); 
        }
        return options;
    }

	
	private static Map<String,Id> recordTypeIdMap = new Map<String,Id>();
	/**
	* @description  		:
	* @param recordTypeName	
	* @parma sobjectName
	*/
	public static ID getRecordTypeID(String sobjectName, String recordTypeName) {
		if(sobjectName == null || recordTypeName == null)return null;
		if(!recordTypeIdMap.keySet().contains(sobjectName.toLowerCase()+':'+recordTypeName.toLowerCase())){				
	        List<RecordType> recordTypeList = [Select Id from RecordType where name = :recordTypeName and SObjectType=:sobjectName];        
	        if(recordTypeList != null && recordTypeList.size() > 0){
	        	recordTypeIdMap.put(sobjectName.toLowerCase()+':'+recordTypeName.toLowerCase(),recordTypeList[0].Id);	
	        }           
		}		
        return recordTypeIdMap.get(sobjectName.toLowerCase()+':'+recordTypeName.toLowerCase());
    }
    
    /**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
    public static void handleException(Exception e){
    	System.debug('STACK TRACE:'+e.getStackTraceString());
    	if(e instanceof DMLException){
    		addErrorMessage(((DMLException)e).getDMLMessage(0));				
    	}else {
    		addErrorMessage(e.getMessage());
    	}
    }
    
    /**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
    public static void addErrorMessage(String message){
    	//Checking if operation is safe
    	if(ApexPages.currentPage()!=null){
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,message));    	
    	}
    }
    
    /**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
    public static void addConfirmMessage(String message){
    	//Checking if operation is safe
    	if(ApexPages.currentPage()!=null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,message));
    	}
    }
     
     /**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/   
     public static Object getData(SObject sObjectRecord, String fieldFullPath){    	
		if(fieldFullPath!=null && fieldFullPath.contains('.')){             
	        SObject lookupSObject = sObjectRecord.getSObject(fieldFullPath.substring(0,fieldFullPath.indexOfIgnoreCase('.')));                  
	        if(lookupSObject!=null){    
				return getData(lookupSObject,fieldFullPath.substring(fieldFullPath.indexOfIgnoreCase('.')+1));                            
	        }else {
	        	return null;
	        }   
	   	}
	   	return sObjectRecord.get(fieldFullPath);
    }

	/**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
	public static Boolean isValidField(Sobject sobjectRecord , String fieldPath){
		Boolean isValid = true; 
		try{
			Object temp = sobjectRecord.get(fieldPath);
		}catch(System.SObjectException e){
			if(e.getMessage().contains('Invalid field')){
				isValid = false;
			}else{
				throw e;
			}
		}
		return isValid;		
	}
	
	/**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
	public static Boolean isFieldRetrieved(Sobject sobjectRecord , String fieldPath){		
		try{
			Object temp = getData(sobjectRecord,fieldPath);
			return true;
		}catch(System.SObjectException e){
			if(e.getMessage().contains('without querying')){
				return false;				
			}else{
				throw e;
			}
		}		
	}
	
	/**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
	public static String getHostName(){
		return URL.getSalesforceBaseUrl().toExternalForm();
	}
	
	
	/**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
	public static void startScheduler(String schedulerName,Integer seconds) { 
        Type t = Type.forName(schedulerName);                 
    	Schedulable scheduler = (Schedulable)t.newInstance(); 
        Datetime sysTime = System.now().addSeconds(seconds);     
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule(schedulerName+'TIME:' + sysTime, chronExpression, scheduler);
	}
	
	/**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
	public static List<String>  getAllFields(String sobjectName){
		
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType theSObjectType = schemaMap.get(sobjectName);
        Map<String, Schema.SObjectField> theFieldMap = theSObjectType.getDescribe().fields.getMap();
        List<String> fields = new List<String>();        
        for(String field:theFieldMap.keySet()){
            fields.add(field);
        }
        return fields;
	}

	/**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
	public static List<String> splitString(String str, Integer length){		
		 return getMatches('.{1,'+length+'}',str);
	}
	
	/**
 	* @description  :
 	* @param		:
 	* @return 		:
 	*/
	public static List<String> getMatches(String regex, String str){
		 List<String> result = new List<String>();
		 Matcher m = Pattern.compile(regex).matcher(str);
		 while(m.find()){
		 	result.add(str.substring(m.start(), m.end()));
		 }
		 return result;
	}	
	
	public static Boolean regexMatch(String str, String regex){
		if(str==null) return false;
		 Matcher m = Pattern.compile(regex).matcher(str);
		 return m.find();
	}
	
	public static String getFirstMatch(String regex, String str){
	     Matcher m = Pattern.compile(regex).matcher(str);
		 while(m.find()){
		 	return str.substring(m.start(), m.end());
		 } 
		 return '';		 
	}
	
	public static String getDataBetweenTags(String tagName, String str){
	     Matcher m = Pattern.compile('(<'+tagName+'>)([\\s\\S]*?)(</'+tagName+'>)').matcher(str);
		 while(m.find()){
		 	String result = str.substring(m.start(), m.end());
		 	result = result.replaceAll('<'+tagName+'>','');
		 	result = result.replaceAll('</'+tagName+'>','');
		 	return result;
		 } 
		 return '';		 
	}
	 
	
	
	public static String replaceSObjectFieldValues(String content, sObject sobj) {
        if(content == null || sobj == null) return content;      
        Map<String, SObjectField> fieldMap = sobj.getSobjectType().getDescribe().fields.getMap();
        Pattern pat = Pattern.compile('\\{!(.*?)\\}');
        Matcher matcher = pat.matcher(content);
        while(matcher.find()) {                      
            String value = String.valueOf(sobj.get(matcher.group(1)));
            value = value == null? '': value;
            if(value != null && value != '') {
                Schema.DescribeFieldResult dfr = fieldMap.get(matcher.group(1)).getDescribe();
                if(dfr.getType() == DisplayType.Double || dfr.getType() == DisplayType.Currency) {
                    value = String.valueOf(Decimal.valueOf(value).setScale(dfr.getScale()));
                }
            }
            content = content.replace(matcher.group(0), value);
        }
        return content; 
    }
    
    /**
    * @description: gives the string before any operator like "+","-","/","*","(",")"
    */  
    public static String getFirstNumericValue(String str){
       Matcher m = Pattern.compile('[^- | ^+ | ^/ | ^( | ^) | ^*]*').matcher(str);
       while(m.find()){
         return str.substring(m.start(), m.end());
       } 
       return '';     
    }
    
    
    public static List<SObject> cloneSObjects(List<SObject> sourceSObjects){
    	if(sourceSObjects==null || (sourceSObjects!=null && sourceSObjects.size()==0)) return new List<Sobject>();
    	Map<String, Schema.SObjectField> theFieldMap = sourceSObjects[0].getSObjectType().getDescribe().fields.getMap();
    	List<SObject> sobjectList = new List<SObject>();
        List<String> fields = new List<String>();
        for(Sobject sourceSObject : sourceSObjects){
        	Sobject targetSObject = sourceSObjects[0].getSObjectType().newSObject();
	        for(String field:theFieldMap.keySet()){        	
	            if(!theFieldMap.get(field).getDescribe().isCalculated()){
	            	targetSObject.put(field,sourceSObject.get(field));	            	            
	            }            
	        }    	            	
        }     
        return sobjectList;  
    }
    
	  public static List<String> getFieldSetFields(String objectName,String fieldSetName){
	  	  List<String> fieldList = new List<String>();
	  	  Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	      Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
	      Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
	      Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);               	  
	      if(fieldSetName!=null && objectName!=null){
	        //To avoid duplicate entries using set to add elements	        
	        for(Schema.FieldSetMember member : fieldSetObj.getFields()){
	            fieldList.add(member.fieldPath.toLowerCase());
	        }   
	      }     
	      return fieldList;  
	  }
	  
	  
	    
	  public static String sendToolingQueryRequest(String queryStr){  
	     HttpRequest req = new HttpRequest();
	     //Set the tooling api endpoint  
	     req.setEndpoint('query/?q='+queryStr);  
	     /*Set authorization by using current users session Id*/  
	     req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());  
	     req.setHeader('Content-Type', 'application/json');      
	     req.setMethod('GET');  
	     Http http = new Http();  
	     HTTPResponse res = http.send(req);  
	     return res.getBody();  
   	  }
   	  
   	  public static String getTotalCount(String sobjectName){  
	     HttpRequest req = new HttpRequest();
	     //Set the tooling api endpoint  
	     req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v28.0/query?q=Select+COUNT(Id)+FROM+'+sobjectName);  
	     /*Set authorization by using current users session Id*/  
	     req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());  
	     req.setHeader('Content-Type', 'application/json');      
	     req.setMethod('GET');  
	     Http http = new Http();  
	     HTTPResponse res = http.send(req);  
	     return res.getBody();  
   	  }

   	   /**
		    @param input        Blob data representing correct string in @inCharset encoding
		    @param inCharset    encoding of the Blob data (for example 'ISO 8859-2','UTF-8')
	   */
	   public static String blobToString(Blob input, String inCharset){
		    String hex = EncodingUtil.convertToHex(input);		    
		    final Integer bytesCount = hex.length() >> 1;
		    String[] bytes = new String[bytesCount];
		    for(Integer i = 0; i < bytesCount; ++i)
		        bytes[i] =  hex.mid(i << 1, 2);
		    return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
	   }
   	  	
   	   /**
   	      @description: Getting all batchable classes from the org
		*/   	   	
	   public static List<String> getBatchClasses(){
		   	List<String> batchableClasses = new List<String>();
			for(ApexClass ac : [SELECT Name, Body FROM ApexClass]){
			       String body = ac.Body.toLowerCase();
			       body.replaceAll('\\s','');
			       if( body.contains('implementsdatabase.batchable')){
			            batchableClasses.add(ac.Name);
			       }
			       
			}
			return batchableClasses;
	   }	
}