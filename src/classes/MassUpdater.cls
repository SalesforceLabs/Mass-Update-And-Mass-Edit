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
    	if (field==null || objsToUpdate==null || objsToUpdate.size()<1) return currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.NoRecordSelectedForUpdate);
    	
    	DisplayType t = field.getDescribe().getType();
    	
    	try{
	    	for (SObject o: objsToUpdate) {	    		
	    		o.put(field, fieldValue);
	    	}
	    } catch (System.SObjectException e){
          	System.debug('Type exception: ' + e.getMessage());
          	return new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + '<br></br>' + System.Label.ZeroRecordUpdated);
        }  	
    	
		try{
		   update objsToUpdate;
		   currentMsg = new ApexPages.Message(ApexPages.severity.INFO, System.Label.Updated + ' ' + objsToUpdate.size() + ' ' + System.Label.Records);
		}catch(System.DmlException e){
           currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0) + '  ' + System.Label.NoRecordUpdated);
        }
        return currentMsg;
	}
	

}