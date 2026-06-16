public class UserModeDemoUndefSharing {

    public List<Dialog__c> allDialoguesUser {get; set;}
    public List<Dialog__c> allDialoguesSystem {get; set;}
    public List<Dialog__c> allDialoguesUndef {get; set;}
    public Dialog__c newDialog {get; set;}
    public Dialog__c toBeEditedDialog {get; set;}
    public String param1 {get; set;}



    public UserModeDemoUndefSharing() {
        System.debug('UserModeDemoUndefSharing .ctor');
        allDialoguesSystem = [SELECT name, Message__c, OwnerId FROM Dialog__c WITH SYSTEM_MODE]; // CWE 284 or FP
        allDialoguesUser = [SELECT name, Message__c, OwnerId FROM Dialog__c WITH USER_MODE]; // SAFE
        allDialoguesUndef = [SELECT name, Message__c, OwnerId FROM Dialog__c]; // CWE 284
        newDialog = new Dialog__c();
    }

    // This method is not vulnerable because of the @AuraEnabled annotation. This method is like it is executed inside with 'with sharing'
    @AuraEnabled
    public static List<Dialog__c> getMyDialogues() {
        List<Dialog__c> allDialoguesAuraEnabled;
        allDialoguesAuraEnabled = [SELECT name, Message__c, OwnerId FROM Dialog__c]; // CWE 274 because row access is safe but column access is not checked
        if(allDialoguesAuraEnabled.size()>0)
        {
            return allDialoguesAuraEnabled;
        }
        return null;
    }



    public void addDialogAsUser() {
        System.debug('addDialog called');
        insert as user newDialog; // FP
    }

    public void addDialogAsSystem() {
        System.debug('addDialog called');
        insert as system newDialog; // CWE 274
    }

    public void addDialogUnspecified() {
        System.debug('addDialog called');
        

        insert newDialog; // CWE 284

    }

    public void prepareEditAsSystem(){
        System.debug('prepareEdit. param1=' + param1);
        toBeEditedDialog = Database.query('SELECT name, Message__c, OwnerId FROM Dialog__c where id = :param1 WITH SYSTEM_MODE');
    }

    public void prepareEditAsUser(){
        System.debug('prepareEdit. param1=' + param1);
        toBeEditedDialog = Database.query('SELECT name, Message__c, OwnerId FROM Dialog__c where id = :param1 WITH USER_MODE');
    }


    public void updateDialogAsUser() {
        System.debug('updateDialog called. toBeEditedDialog.ID=' + toBeEditedDialog.id);
        update as user toBeEditedDialog;
    }

    public void updateDialogAsSystem() {
        System.debug('updateDialog called. toBeEditedDialog.ID=' + toBeEditedDialog.id);
        update as system toBeEditedDialog;  // CWE 274
    }

    public void updateDialogUnspecified() {
        System.debug('updateDialog called. toBeEditedDialog.ID=' + toBeEditedDialog.id);
        update toBeEditedDialog;            // CWE 274
    }
}