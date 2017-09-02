/**
* @ApexClass 	: <APEX_CLASS_NAME>
* @Description 	: This a schedulable batch.
*/
global class <APEX_CLASS_NAME> implements schedulable, Database.Batchable<sObject>,  Database.AllowsCallouts {
    global String query = '';
	
    global <APEX_CLASS_NAME>(){
	query = '<QUERY_GOES_HERE>';
    }
	
    /**
    *Check whether given apex class already in queue
    */
    public static boolean isJobAlreadyRunning(String apexClassName) {
        ApexClass batchApexClass = [Select Id From ApexClass Where Name = :apexClassName limit 1][0];
        List<AsyncApexJob> apexJobs = [Select Id, CompletedDate From AsyncApexJob Where JobType = 'BatchApex' AND ApexClassID = :batchApexClass.Id AND CompletedDate = null];
        if(apexJobs != null && apexJobs.size() > 0)
            return [SELECT Id FROM AsyncApexJob WHERE Status='Processing' OR Status='Preparing'].size()<5; 
        else
            return false; 
    }
	
	 
    //Schedule execution
    global void execute( SchedulableContext SC ) {        
		if(isJobAlreadyRunning('<APEX_CLASS_NAME>') ) {
			System.debug('Do not shedule, either there is nothing to process or previous job is still in progress.');	
		} else  {
			//Check if we are not using more than 5 batches at a time.
			if([SELECT Id FROM AsyncApexJob WHERE Status='Processing' OR Status='Preparing'].size()<5){
				if(!Test.isRunningTest()){
					Database.executeBatch(this, 1);
				}				
			}
		}				
        start();
        // Abort job and start again
        if(!Test.isRunningTest()){
	        System.abortJob( SC.getTriggerId() );             
        }
    }
    
    //initate batch jobs
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);  
    }
	
    public static void start() { 
        Datetime sysTime = System.now().addMinutes(Integer.valueOf(<INTERVAL_IN_MINUTES>));      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        if(!Test.isRunningTest()){
        		System.schedule('<JOB NAME TO BE APPEARED IN SCHEDULED JOBS>' + sysTime, chronExpression, new <APEX_CLASS_NAME>());
        }
    }
    
    //batch apex execution
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
	//logic goes here
    } 
    
    //finish batch jobs
    global void finish(Database.BatchableContext BC){
	System.debug('Batch is finished');
    }
    
}