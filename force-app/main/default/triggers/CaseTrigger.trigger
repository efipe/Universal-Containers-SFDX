trigger CaseTrigger on Case (before insert, before update, after insert, after update, after delete ) {

    CaseTriggerHandler handler = new CaseTriggerHandler();
    handler.run();

}