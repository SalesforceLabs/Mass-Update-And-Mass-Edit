/**
 * The massupdater is used to update a field of a set of records to a value
 * @author cchen
 */

public with sharing class MassUpdater {
	private final Schema.SObjectField field;
	private final Object fieldValue;
	private final List<SObject> objsToUpdate;
	private ApexPages.Message currentMsg;
	
	public MassUpdater(List<SObject> objs, Schema.SObjectField f, Object value) {
		objsToUpdate = objs;
		field = f;
		fieldValue = value;
	}
	
	public ApexPages.Message massUpdate() {
    	if (field==null || objsToUpdate==null || objsToUpdate.size()<1) return currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'No record selected for update.  Please click cancle to return');
    	
    	DisplayType t = field.getDescribe().getType();
    	
    	try{
	    	for (SObject o: objsToUpdate) {	    		
	    		o.put(field, fieldValue);
	    	}
	    } catch (System.SObjectException e){
          	System.debug('Type exception: ' + e.getMessage());
          	return new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + '<br></br>0 record updated');
        }  	
    	
		try{
		   update objsToUpdate;
		   currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Updated ' + objsToUpdate.size() + ' Records');
		}catch(System.DmlException e){
           currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0) + '  No record updated');
        }
        return currentMsg;
	}
	

}