public class PlayWithUserMode {
    public static void doSmth(){
        List<Account> acc = [SELECT Id FROM Account]; // CWE 284
        for (Account a: acc){
            System.debug('Result: ' + a.Id);
        }
    }
}