/**
 * @author          Kiran Machhewar
 * @date            mm/dd/yyyy
 * @description     Trigger to handle events on <SOBJECT_NAME>
 */

trigger <SOBJECT_CAMEL_CASED>Trigger on <SOBJECT_NAME> (before insert, before update, after insert, after update) {
    //BEFORE INSERT
    if(Trigger.isInsert && Trigger.isBefore){

    }

    //AFTER INSERT
    if(Trigger.isInsert && Trigger.isAfter){

    }

    //BEFORE UPDATE
    if(Trigger.isUpdate && Trigger.isBefore){

    }
    
    //AFTER UPDATE
    if(Trigger.isUpdate && Trigger.isAfter){

    }
}