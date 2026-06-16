public without sharing class DialogueFromTestController {

    @AuraEnabled
    public static List<Dialog__c> getDialogues() {
        System.debug('getDialogues called');
        return DialogueControllerTest.getDialogues();
    }

}