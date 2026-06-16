({
    doInit : function(component, event, helper) {
       let action = component.get("c.getMyDialogues");
       action.setCallback(this, function(response)
                          {
                              let state = response.getState();
                              if(state=='SUCCESS')
                              {
                                  component.set("v.dialogues",response.getReturnValue());
                              }
                              else
                              {
                                  console.log('Failed to Retrieve To Dialogues');
                              }
                          });
       $A.enqueueAction(action);
   }
})
