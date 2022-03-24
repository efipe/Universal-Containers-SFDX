trigger CaseTrigger on Case (before insert, before update, after insert, after update, after delete ) {

    if(Trigger.isAFter && Trigger.isUpdate){
        System.debug('Trigger is after update');
    }

    CaseTriggerHandler handler = new CaseTriggerHandler();
    handler.run();


}