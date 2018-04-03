
var json={json};
var app={
    getUserName:function(){
        return "{userName}";
    },
 
    getAccount:function(){
        return "{account}";
    },
    getUserJob:function(){
        return "{etJobTitle}";
    },
    
    getDeptNum:function(){
        return "{deptNum}";
    },
    
    getOu:function(){
        return "{ou}";
    },
    
    getMail:function(){
        return "{mail}";
    },
    
    getDeptName:function(){
        return "{deptName}";
    },
    
    logout:function(){
        var url="logouturl:iostt:key:value";
        document.location=url;
    },
    
    postData:function(url,params){
        location.href="posturl:xxx$$$"+url+"$$$"+params+"$$$eval";
    },
    
    put:function(key,value){
        
        json[key]=value;
        location.href="puturl:xxx$$$"+key+"$$$"+value;
    },
    
    get:function(key){
        
        return json[key];
    },

    getPhoto:function(params){
        return "{imgStr}";
    },
    getUserPhoto:function(params){
        
        return "{UserimgStr}"
    },
    getUserAccount:function(){
        return "{Useraccount}";

    },
    userLocal:function(){
        return "{userLocal}";
    },
  
    longitude:function(){
        return "{longitude}";
    },
  
    latitude:function(){
        return "{latitude}";
    },
    subClick:function(){
      
        var url="subClick";
        document.location=url;
        
    },
    subClickWithTag:function(){
        
        //document.location="tag"+tag;
        var url="tagtag";
        document.location=url;


    },
    sendMainAdd:function(tag){
        
        var url="sendMainAdd"+tag;
        document.location=url;
        
    },
    sub:function(){
        
         document.location="sub";
    },
    playSP:function(unid){
        
        document.location="HuanxinplaySP"+unid;

    }
    
    
      
}/*记得新添加的函数前面要加逗号*/

var photo={
    takePhoto:function()
    {
        var url="takephotourl:showNewPhoto:photoclick:ioscamera";
        document.location=url;
    },
    
}
















