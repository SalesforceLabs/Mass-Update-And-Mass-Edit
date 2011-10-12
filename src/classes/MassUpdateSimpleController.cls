/**
 * This is the controller for the mass update app
 * @author cchen
 */

public with sharing class MassUpdateSimpleController {
    
   private final ApexPages.StandardSetController cntr;
   private final PageReference fromPage;
   private final List<SObject> objs;
   private Map<String, Schema.SObjectField> fieldMap;
   private transient ApexPages.Message currentMsg;
   private final String newLine ='<br></br>';
   private Schema.SObjectField field;
   private String sType;
   private Object convertedFieldData;
   private List<SelectOption> picklistValues;
   private String currentStep;
  
   
   public MassUpdateSimpleController(ApexPages.StandardSetController controller) {
       currentStep = '1';
       controller.setPageSize(1000);
       cntr = (ApexPages.StandardSetController)controller;
       fromPage = cntr.cancel();
       if (this.objs == null) {
            this.objs = (List<SObject>)cntr.getSelected();
       }
       if (getRecordSize()<1) {
            String msg = 'No record was selected on the list view.  Please click Previous button and select records for mass update.'; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
       } else {
            sType= discoverSObjectType(objs.get(0)).getName(); 
            String msg = 'Number of records selected for update: ' + getRecordSize(); 
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
       }
       ApexPages.addMessage(currentMsg);
       
       
   }
   
   
   /* public MassUpdateSimpleController() {
       System.debug('ids: ' + ApexPages.currentPage().getParameters().get('ids'));
       selected = ApexPages.currentPage().getParameters().get('id0');
       return; 
       cntr = new ApexPages.StandardSetController(objs);
       fromPage = cntr.cancel();
       if (this.objs == null) {
            this.objs = (List<SObject>)cntr.getSelected();
       }
       if (getRecordSize()<1) {
            String msg = 'No record was selected on the list view.  Please click Previous button and select records for mass update.'; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
       } else {
            sType= discoverSObjectType(objs.get(0)).getName(); 
            String msg = 'Number of records selected for update: ' + getRecordSize(); 
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
       }
       ApexPages.addMessage(currentMsg);
   } */
   

	public String getStep() {
		return currentStep;
	}
	
	public String getsType() {
		return sType;
	}	   
   
   	public integer getRecordSize() {
     if (objs!=null) {
        return objs.size();
     } else {
        return 0;
     }
    }
    
    public String filterId {
        get;
        set;    
    }
     
   
    public String getNow(Boolean bShowTime) {
        DateTime now = DateTime.now();
        if (bShowTime)
            return  now.year() + '-' + now.month()+ '-' + now.day()+' '+now.hour()+ ':' +now.minute() + ':' + now.second();
        else
            return  now.year() + '-' + now.month()+ '-' + now.day();
    }
   
    public List<SObject> objsToUpdate {
        get {
            return (List<SObject>) cntr.getSelected();
        }
        set;
    }
  
    public String valueToUpdate {
        get;
        set;    
    }
    
    public String fieldName {
        get;
        set {
            fieldName=value;
            field = fieldMap.get(value);
            fieldType = field.getDescribe().getType().name();
        }   
    }
    
    public String fieldType{
        get;
        set;    
    }
    
    private Object convertUserInputToFieldData(){
        if (field==null) return null;
        DisplayType t = field.getDescribe().getType();
        Object s = null;
        
        try {       
                if (t==DisplayType.Double||t==DisplayType.Currency || t==DisplayType.Integer || t==DisplayType.Percent){
                    s = decimal.valueOf((String)valueToupdate);         
                } else if (t==DisplayType.Boolean){                 
                    if (valueToUpdate=='true'){
                        s = true;               
                    } else if (valueToUpdate=='false'){
                        s = false;              
                    } else {
                        s = Boolean.valueOf(valueToUpdate);
                    }
                } else if (t==DisplayType.Date) {
                    s = Date.valueOf(valueToUpdate);
                } else if (t==DisplayType.DateTime) {
                    s = DateTime.valueOf(valueToUpdate);
                } else if ((t==DisplayType.PickList || t==DisplayType.PickList) && valueToUpdate==null) {
                    s = '';
                }else {
                    s = valueToupdate;
                }
        } catch (System.TypeException e){
            System.debug('Type exception: ' + e.getMessage());
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            return null;
        }  
        
        return s;
    }
    
    
    public String getFieldInfoToDisplay() {
        if (field==null) return '';
        String msg = 'Field type of selected field: ' + fieldType + newline;
        
        Schema.DescribeFieldResult d = field.getDescribe();
        
        if (d.getType()==DisplayType.TextArea || d.getType()==(DisplayType.String)||d.getType()==(DisplayType.URL)) {
            msg += 'Max lengh: ' + d.getLength();
            valueToUpdate='';
        } else if (d.getType()==DisplayType.DateTime ){
            msg += 'Format: yyyy-MM-dd HH:mm:ss';
            valueToUpdate=getNow(true);
        } else if (d.getType()==DisplayType.Date){
            msg += 'Format: yyyy-MM-dd';
            valueToUpdate=getNow(false);
        } else if (d.getType()==DisplayType.Picklist){
            
            picklistValues = new List<SelectOption>();      
            if (d.isNillable()) {
                picklistValues.add(new SelectOption('', '--None--'));
            }
            for (Schema.PicklistEntry p : d.getPickListValues()) {
                picklistValues.add(new SelectOption(p.getValue(), p.getLabel()));
            }
            msg += newline + 'Please select a picklist value';
        } else if (d.getType()==DisplayType.MultiPicklist){
            
            msg += 'Valid Picklist Values: ';
            String combined ='';
            
            for (Schema.PicklistEntry p : d.getPickListValues()) {
                msg += newLine + '&nbsp;&nbsp;&nbsp;&nbsp;<b>' +p.getValue()+'</b>';
                combined += p.getValue()+';';
            }
            msg += newline + 'Use ; to seperate each picklist value you want to select';
            msg += newline + 'For example, to select all the picklist values, enter <b>' + combined + '</b> in the textbox below to select all picklist values';
        } else if (d.getType()==DisplayType.Integer){
            msg += 'Max digits: ' + d.getDigits();
        } else if (d.getType()==DisplayType.String){
            msg += 'Max length: ' + d.getLength();
        } else if (d.getType()==DisplayType.Double || d.getType()==DisplayType.Currency || d.getType()==DisplayType.Percent){
            msg += 'Format: (' + (d.getPrecision()-d.getScale()) + ','+d.getScale() +')';
        } else if (d.getType()==DisplayType.Reference){
            msg += 'Use this to change selected records to reference a different record, or even dereference records if the filed is left blank' + newLine;
            msg += 'Please enter ' + d.getName() + ' that the selected records should reference to';
        }
        
        return msg;
    }
    
       
    public PageReference cancel() {
        return fromPage;
    }

    public PageReference step1() { 
    	currentStep='1';   	     
        return ApexPages.currentPage();
    }
    
    public PageReference step2() {
        if(getRecordSize()<1) return fromPage;      
    	currentStep='2';   	     
        return ApexPages.currentPage();
    }
    
    public PageReference step3() {
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
        ApexPages.addMessage(currentMsg);
        currentStep='3';   	     
        return ApexPages.currentPage();
    } 
  
    public PageReference step4() {
        convertedFieldData = convertUserInputToFieldData();
        
        // data type validation
        if (currentMsg!=null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
            ApexPages.addMessage(msg);
            ApexPages.addMessage(currentMsg);
            return ApexPages.currentPage();
        }
        
        String msg = 'Please review your selections before confirm: <br></br>'; 
        msg = msg + '<br><b>Records Selected:</b>    ' + getRecordSize() +'</br>';
        msg = msg + '<br><b>Field To Be Updated:</b> ' + fieldName + '</br>';
        msg = msg + '<br><b>New Value:</b>           ' + convertedFieldData + '</br>';
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        ApexPages.addMessage(currentMsg);
        currentStep='4';   	     
        return ApexPages.currentPage();
    } 
      
    public PageReference step5() {
        currentMsg = (new MassUpdater(objs, field, convertedFieldData)).massUpdate();
        ApexPages.addMessage(currentMsg);
        currentStep='5';   	     
        return ApexPages.currentPage();
    }
   
    public DescribeSObjectResult discoverSObjectType(SObject s) {
        Map<String, Schema.SObjectType> des = Schema.getGlobalDescribe();
        
        for(Schema.SObjectType o:des.values()) {
            if( s.getSObjectType()==o) {
                return o.getDescribe();
            }     
        }
        return null;
    }
   
    public List<SelectOption> getFieldTypeOptions() {
        // prevent url hacking
        if (objs.size()<1) return null;
        
        List<SelectOption> options = new List<SelectOption>();      
        options.add(new SelectOption('','-None-'));
                
        Schema.DescribeSObjectResult sObj = discoverSObjectType(objs.get(0));
        
        fieldMap = sObj.fields.getMap();
        
        List<String> keys = sortByFieldLabel(fieldMap);
        
        for(String key:keys) {
            Schema.DescribeFieldResult d = fieldMap.get(key).getDescribe();

            if(d.isAccessible() && d.isUpdateable()) {
                if (isSupportedFieldType(d)) {
                    String label = d.getLabel();
                    if(d.isCustom()) label += ' (' + key +  ')';
                    options.add(new SelectOption(key, label));
                }
            }
        }
        return options;
    }
   
    private List<String> sortByFieldLabel(Map<String, Schema.SObjectField> gd) {
        List<String> keys = new List<String>();
        
        Map<String, List<String>> labelMap = new Map<String, List<String>>();
        
        for(Schema.SObjectField s:gd.values()) {
            String label = s.getDescribe().getLabel();
            if(labelMap.get(label) == null) {
                labelMap.put(label, new List<String>());
            }
            
            labelMap.get(label).add(s.getDescribe().getName());        
        }
        
        List<String> labels = new List<String>(labelMap.keySet());
        labels.sort();
        
        for(String label:labels){
            keys.addAll(labelMap.get(label));
        }
        
        return keys;
    }
    
    public List<SelectOption> getPicklistValues() {
        return picklistValues;
    }
    
    private boolean isSupportedFieldType(DescribeFieldResult d) {
        // always return true for now, but in future some fields might not be supported
        return true;
    }
    
    
}