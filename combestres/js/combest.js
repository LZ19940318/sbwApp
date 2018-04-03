//生成列表文件,datas,表示服务器返回的json数据，templateId表示条目模板，contentId表示容器的标识，ifBefore追加位置，0表示在后面追加，1表示在前面追加，2表示替换
function list(json,templateId,contentId,isBefore){
    var template=$("#"+templateId).html();//取id里的所以html内容，包括元素
    var rows="";
    var content=$("#"+contentId)[0].innerHTML;
    
    if(json.error){
        $("#"+contentId)[0].innerHTML=json.error;
        return;
    }
    var datas=json.list;
    for(var i=0;i<datas.length;i++){
        var row=template;
        var data=datas[i];
        for(var r in data){
            var reg=new RegExp("\{"+r+"\}","gi");
            row=row.replace(reg,data[r]);
        }
        var index=row.indexOf("<%");
        if(index!=-1){
            var eIndex=row.indexOf("%>");
            if(eIndex!=-1){
                var compute=row.substring(index+2,eIndex);
                var computeAll=row.substring(index,eIndex+2);
                try{
                    row=row.replace(computeAll,eval(compute));
                }catch(e){
                    row.replace(computeAll,"");
                }
            }
        }
        rows+=row;//加上行元素
    }
    
    
    if(isBefore=="1"){
        content=rows+content;
    }else if(isBefore=="2"){
        content=rows;
    }else{
        content+=rows;
    }
    
    $("#"+contentId)[0].innerHTML=content;
    if(document.getElementById("loadStaut")){
        document.getElementById("loadStaut").style.display="none";
    }
    //数据加载完成之后再调用删除列表的方法
    try{
        runDefinFun();
    }catch(e){}
}


//加载文档，data为文档的字段
function edit(data){
    for(var r in data){
        try{
            $("[name='"+r+"']").each(function(i){
                                     var type=this.type.toLowerCase()
                                     var value=data[r];
                                     if(type=="checkbox"){
                                     value=value.split(",");
                                     for(var i=0;i<value.length;i++){
                                     if(value[i]==this.value){
                                     this.checked=true;
                                     return;
                                     }
                                     }
                                     }else if(type=="radio"){
                                     if(this.value==value){
                                     this.checked=true;
                                     }
                                     }else if(type=="select"){
                                     var options=select.options;
                                     value=value.split(",");
                                     for(var i=0;i<options.length;i++){
                                     for(var j=0;j<value.length;j++){
                                     if(options[i].value==value[j]){
                                     options[i].selected=true;
                                     }
                                     }
                                     }
                                     }else{
                                     
                                     this.value=data[r];
                                     }
                                     
                                     });
        }catch(e){
            alert(e)
        }
        
    }
    custom($("#customType").val())
}
//加载文档，data为文档的字段
function editTemplate(data){
    for(var r in data){
        try{
            $("[name='"+r+"']").each(function(i){
                                     if(this.type=="undefined" || this.type==undefined){
                                     this.innerHTML = data[r];
                                     }else{
                                     var type=this.type.toLowerCase();
                                     var value=data[r];
                                     if(type=="checkbox"){
                                     value=value.split(",");
                                     for(var i=0;i<value.length;i++){
                                     if(value[i]==this.value){
                                     this.checked=true;
                                     return;
                                     }
                                     }
                                     }else if(type=="radio"){
                                     if(this.value==value){
                                     this.checked=true;
                                     }
                                     }else if(type=="select-one"){
                                     if(this.options.length>0){
                                     //替换值
                                     for(var i=0;i<options.length;i++){
                                     for(var j=0;j<value.length;j++){
                                     if(options[i].value==value[j]){
                                     options[i].selected=true;
                                     }
                                     }
                                     }
                                     }else{
                                     //动态创建options
                                     value=value.toString().split(",");
                                     for(var j=0;j<value.length;j++){
                                     var newOption  = document.createElement("option");
                                     newOption.value=value[j];
                                     newOption.text=value[j];
                                     this.options.add(newOption);
                                     }
                                     }
                                     
                                     }else{
                                     this.value=value;
                                     }
                                     }
                                     
                                     });
        }catch(e){
            alert("解析出错"+e)
        }
        
    }
    try{
        exectueUserdefined();
    }catch(e){
        //没有这个方法
    }
}

//加载文档，data为文档的字段
function editTemplatePayment(data){   //付款申请
    for(var r in data){
        try{
            $("[name='"+r+"']").each(function(i){
                                     if(this.type=="undefined" || this.type==undefined){
                                     this.innerHTML = data[r];
                                     }else{
                                     var type=this.type.toLowerCase();
                                     var value=data[r];
                                     if(type=="checkbox"){
                                     value=value.split(",");
                                     if(value=="0"){
                                     this.checked=true;
                                     $("#first_Payment_Flag").css({"display":"inline-block"}); //首付款
                                     $("#over_Limits_Flag").css({"display":"inline-block"}); //超标
                                     return;
                                     }
                                     //                             for(var i=0;i<value.length;i++){
                                     //                                 if(value[i]==this.value){
                                     //                                     this.checked=true;
                                     //                                     return;
                                     //                                 }
                                     //                             }
                                     }else if(type=="radio"){
                                     if(this.value==value){
                                     this.checked=true;
                                     }
                                     }else if(type=="select-one"){
                                     if(this.options.length>0){
                                     //替换值
                                     for(var i=0;i<options.length;i++){
                                     for(var j=0;j<value.length;j++){
                                     if(options[i].value==value[j]){
                                     options[i].selected=true;
                                     }
                                     }
                                     }
                                     }else{
                                     //动态创建options
                                     value=value.toString().split(",");
                                     for(var j=0;j<value.length;j++){
                                     var newOption  = document.createElement("option");
                                     newOption.value=value[j];
                                     newOption.text=value[j];
                                     this.options.add(newOption);
                                     }
                                     }
                                     
                                     }else{
                                     this.value=value;
                                     }
                                     }
                                     
                                     });
        }catch(e){
            alert("解析出错"+e)
        }
        
    }
    try{
        exectueUserdefined();
    }catch(e){
        //没有这个方法
    }
}

//加载文档，data为文档的字段
function edits(data){
    for(var r in data){
        try{
            $("[name='"+r+"']").each(function(i){
                                     var type=this.type.toLowerCase()
                                     var value=data[r];
                                     if(type=="checkbox"){
                                     value=value.split(",");
                                     for(var i=0;i<value.length;i++){
                                     if(value[i]==this.value){
                                     this.checked=true;
                                     return;
                                     }
                                     }
                                     }else if(type=="radio"){
                                     if(this.value==value){
                                     this.checked=true;
                                     }
                                     }else if(type=="select"){
                                     var options=select.options;
                                     value=value.split(",");
                                     for(var i=0;i<options.length;i++){
                                     for(var j=0;j<value.length;j++){
                                     if(options[i].value==value[j]){
                                     options[i].selected=true;
                                     }
                                     }
                                     }
                                     }else{
                                     
                                     this.value=data[r];
                                     }
                                     
                                     });
        }catch(e){
            alert(e)
        }
        
    }
    changebutton();
}

//加载文档，data为文档的字段
//投资类型数据的处理
function custom(data){
    var text = data.split(",");
    //customform
    //alert(text[1])
    for(var i = 1;i<=text.length;i++){
        var number="ckbox"+Number(text[i-1])
        $("#"+number).attr("checked","true");
        
    }
}

//加载文档，data为文档的字段
function editDaily(data){
    for(var r in data){
        try{
            $("[name='"+r+"']").each(function(i){
                                     var type=this.type.toLowerCase()
                                     var value=data[r];
                                     if(type=="checkbox"){
                                     value=value.split(",");
                                     if(value=="0"){
                                     this.checked=true;
                                     $("#isCheck").css({"display":"block"});
                                     return;
                                     }
                                     /*
                                      for(var i=0;i<value.length;i++){
                                      if(value[i]==this.value){
                                      this.checked=true;
                                      return;
                                      }
                                      }*/
                                     }else if(type=="radio"){
                                     if(this.value==value){
                                     this.checked=true;
                                     }
                                     }else if(type=="select"){
                                     var options=select.options;
                                     value=value.split(",");
                                     for(var i=0;i<options.length;i++){
                                     for(var j=0;j<value.length;j++){
                                     if(options[i].value==value[j]){
                                     options[i].selected=true;
                                     }
                                     }
                                     }
                                     }else{
                                     this.value=data[r];
                                     }
                                     
                                     });
        }catch(e){
            alert(e)
        }
        
    }
}

function open(data){
    for(var r in data){
        try{
            $("#"+r).each(function(i){
                          var value=data[r];
                          
                          if(r=="lastModify"){
                          
                          value=getDate_month(value);
                          
                          }
                          $("#"+r).html(value)
                          });
        }catch(e){
            alert(e)
        }
        
    }
}
//公告
function openInfo(data){
    for(var r in data){
        try{
            $("#"+r).each(function(i){
                          var value=data[r];
                          if(r=="lastModify"){
                          value=getDates(value);
                          }
                          $("#"+r).html(value)
                          });
        }catch(e){
            alert(e)
        }
    }
    var atts=json.atts;
    var attHmtl="<div class=\"list-group\">";
    
    for(var i=0;i<atts.length;i++){
        var att=atts[i];
        var attName=att.substring(att.lastIndexOf("/")+1);
        attHmtl+="<a class='list-group-item' href='"+att+"' >"+attName+"</a>"
    }
    attHmtl+="</div>";
    $("#attContent").html(attHmtl);
    $("#textAtt").html("附件("+atts.length+")");
}

//更新视图上的数据
function refresh(){
    //监听滚动条
    $(window).scroll(function(){
                     　　var scrollTop = $(this).scrollTop();
                     　　var scrollHeight = $(document).height();
                     　　var windowHeight = $(this).height();
                     
                     　　if(scrollTop + windowHeight == scrollHeight){
                     　　　　try{
                     getDatas(start,true);
                     }catch(e){
                     }
                     }
                     });
}
//更新视图上的数据
function refresh_userlist(){
    //监听滚动条
    $(window).scroll(function(){
                     　　var scrollTop = $(this).scrollTop();
                     　　var scrollHeight = $(document).height();
                     　　var windowHeight = $(this).height();
                     
                     　　if(parseInt(scrollTop) + parseInt(windowHeight) + 5 == scrollHeight){
                     　　　　try{
                     getDatas(start,true);
                     }catch(e){
                     }
                     }
                     });
}
//通过父窗口跳转
function redirectParentPage(toUrl){
    var url=location.href;
    app.put("page",url);
    //parent.location.href=toUrl;
}
//加载主页面
function redirectMainPage(){
    var lastPage=app.get("page");
    if(lastPage!=""){
        $('#conter').attr('src',lastPage);
    }
}

//加载自定义表单界面

function showForm(json){
    
    var html=json.html;
    $("#content").html(html);
    var data=json.items;
    
    for(var r in data){
        try{
            $("[name='"+r+"']").each(function(i){
                                     
                                     if(this.type=="undefined" || this.type==undefined){
                                     this.innerHTML = data[r];
                                     }else{
                                     var type=this.type.toLowerCase();
                                     var value=data[r];
                                     if(type=="checkbox"){
                                     value=value.split(",");
                                     for(var i=0;i<value.length;i++){
                                     if(value[i]==this.value){
                                     this.checked=true;
                                     return;
                                     }
                                     }
                                     }else if(type=="select" || type=="select-one"){
                                     var options=this.options;
                                     value=value.split(",");
                                     for(var i=0;i<options.length;i++){
                                     for(var j=0;j<value.length;j++){
                                     if(options[i].value==value[j]){
                                     options[i].selected=true;
                                     break;
                                     break;
                                     }
                                     }
                                     }
                                     }else if(type=="radio"){
                                     if(this.value==value){
                                     this.checked=true;
                                     }
                                     }else{
                                     this.value=data[r];
                                     }
                                     }
                                     })
            //document.getElementById(r).value=items[r];
        }catch(e){
        }
    }
    var atts=json.atts;
    var attHmtl="<div class=\"list-group\">";
    for(var i=0;i<atts.length;i++){
        var att=atts[i];
        var attName=att.substring(att.lastIndexOf("/")+1);
        attHmtl+="<a class='list-group-item' href='"+att+"' >"+attName+"</a>"
    }
    attHmtl+="</div>";
    $("#attContent").html(attHmtl);
    $("#textAtt").html("附件("+atts.length+")");
    
    var mainBody=json.mainBody;
    
    var count=0;
    if(mainBody!=""){
        $("#mainBodyHref").val(mainBody);
    }
    $("#textMainBody").html("正文("+count+")");
    
    //意见
    var yjList=json.yjList;
    
    for(var yj in yjList){
        
        try{
            $("#"+yj).html(yjList[yj]);
        }catch(e){
        }
        
    }
    
    
}


//加载自定义表单界面
function showForm_doc(json){
    var html=json.html;
    $("#content").html(html);
    var data=json.items;
    for(var r in data){
        try{
            $("[name='"+r+"']").each(function(i){
                                     
                                     if(this.type=="undefined" || this.type==undefined){
                                     this.innerHTML = data[r];
                                     }else{
                                     var type=this.type.toLowerCase();
                                     var value=data[r];
                                     if(type=="checkbox"){
                                     value=value.split(",");
                                     for(var i=0;i<value.length;i++){
                                     if(value[i]==this.value){
                                     this.checked=true;
                                     return;
                                     }
                                     }
                                     }else if(type=="radio"){
                                     if(this.value==value){
                                     this.checked=true;
                                     }
                                     }else if(type=="select"){
                                     var options=select.options;
                                     value=value.split(",");
                                     for(var i=0;i<options.length;i++){
                                     for(var j=0;j<value.length;j++){
                                     if(options[i].value==value[j]){
                                     options[i].selected=true;
                                     }
                                     }
                                     }
                                     }else{
                                     this.value=data[r];
                                     }
                                     }
                                     })
            //document.getElementById(r).value=items[r];
        }catch(e){
        }
    }
    var atts=json.atts;
    var attHmtl="<div class=\"list-group\">";
    var arrHref="";
    for(var i=0;i<atts.length;i++){
        var att=atts[i];
        arrHref+=att+",";
        var attName=att.substring(att.lastIndexOf("/")+1);
        //attHmtl+="<a class='list-group-item' href='"+att+"' >"+attName+"</a>";
        attHmtl+="<a class='list-group-item' href='#' onclick=\"openfile('"+att+"')\">"+attName+"</a>";
        
    }
    attHmtl+="</div>";
    $("#attContent").html(attHmtl);
    $("#attrHref").val(arrHref);//附件连接
    $("#textAtt").html("附件("+atts.length+")");
    
    //意见附件
    var yjatts=json.yjatts;
    var yjattHmtl="<div class=\"list-group\">";
    var yjHref="";
    for(var i=0;i<yjatts.length;i++){
        var yjatt=yjatts[i];
        yjHref+=yjatt+",";
        var yjattName=yjatt.substring(yjatt.lastIndexOf("/")+1);
        yjattHmtl+="<a class='list-group-item' href='#' onclick=\"openfile('"+yjatt+"')\">"+yjattName+"</a>";
        //yjattHmtl+="<a class='list-group-item' href='"+yjatt+"' >"+yjattName+"</a>";
    }
    yjattHmtl+="</div>";
    
    $("#yjattContent").html(yjattHmtl);
    $("#yjHref").val(yjHref);//意见附件连接
    $("#yjtextAtt").html("意见附件("+yjatts.length+")");
    
    var mainBody=json.mainBody;
    var count=0;
    if(mainBody!=""){
        $("#mainBodyHref").val(mainBody);
        count=1;
    }
    $("#textMainBody").html("正文("+count+")");
    
    
    //意见
    var yjList=json.yjList;
    for(var yj in yjList){
        try{
            $("#"+yj).html(yjList[yj]);
        }catch(e){
        }
    }
    
}




traceType="";
CanTraceFlag="";
//显示节点及人员选择信息
function showNextNode1(json){

    CanTraceFlag=json.CanTraceFlag;
    if(CanTraceFlag=="3"){
        $("#divSuggestion").css({"display":"none"});
    }
    var nodeSubject = json.nodeSubject;
    if(nodeSubject == "经办人销假"||nodeSubject == "申请人."){
        document.getElementById("sjxjsj").removeAttribute("readOnly");
    }
    $("#nodeSubject").val(nodeSubject);
    
    traceType=json.SelTraceType;
    var checkNodeHtml="";
    var userHtml="";
    //var tempCheck='<input style="display:none" id="endNodeFlag" value="{endNodeFlag}"/>';
    var tempCheck = '<label onclick="selNode(this)" mainDeptUser="{mainDeptUser}" id="{value}" class="{class}"><input type="{type}" name="selNode" endNodeFlag="{endNodeFlag}" value="{value}"/>{text}</label>';
    for(var i=0;i<json.nodeList.length;i++){
        var checkHtml=tempCheck;
        var data=json.nodeList[i];
        //  alert(data);
        var subject=data.Subject;
        var nodeId=data.nodeId;
        var type=data.condition;
        var mainDeptUser = data.mainDeptUser;
        
        var endNodeFlag = data.endNodeFlag;
        checkHtml=checkHtml.replace("{mainDeptUser}", mainDeptUser);
        checkHtml=checkHtml.replace("{value}",nodeId);
        checkHtml=checkHtml.replace("{text}",subject);
        
        checkHtml=checkHtml.replace("{endNodeFlag}",endNodeFlag);
        if(type=="3"||type=="8"){
            checkHtml=checkHtml.replace("{class}","checkbox-inline");
            checkHtml=checkHtml.replace("{type}","checkbox");
        }else{
            checkHtml=checkHtml.replace("{class}","radio-inline");
            checkHtml=checkHtml.replace("{type}","radio");
        }
        checkNodeHtml+=checkHtml;
        if(endNodeFlag=="1" || endNodeFlag==1){
            userHtml += "";
        }else{
            userHtml+=showUserList(data);
        }
        
        
        // divSelUser
    }
    $("#divSelNode").html(checkNodeHtml);
    $("#divSelUser").html(userHtml);
    selectDefault(json);
    
    
}
function selectDefault(json){
    if(json.nodeList.length==1){
        $("#divSelNode").find("input").each(function(){
                                            this.checked=true;
                                            });
        $("#divSelUser").find("ul").css({"display":""});
        if(json.nodeList[0].userList.length==1){
            $("#divSelUser").find("input").each(function(){
                                                this.checked=true;
                                                });
        }
    }
}
/*
 *显示人员信息列表
 */
function showUserList(data){
    var userList=data.userList;
    var nodeId=data.nodeId;
    var type="radio"
    if(data.isSign=="1"||data.timeHuiqian=="1"){
        type="checkbox";
    }
    var userListHtml="<ul class='list-group'' id='"+nodeId+"User' style='display:none'>";
    var temp="<li onclick='selectUser(this)' class='list-group-item'>{user}<span  style='float:right;margin-right:10px'><input type='{type}' name='selUser' value='{user}$"+data.nodeId+"' /></span></li>"
    for(var i=0;i<userList.length;i++){
        var userHtml=temp;
        var user=userList[i];
        userHtml=userHtml.replace(/{user}/gi,user);
        userHtml=userHtml.replace(/{type}/gi,type);
        userListHtml+=userHtml;
    }
    userListHtml+="</ul>";
    return userListHtml;
    // divSelUser
}
//选择人员
function selectUser(obj){
    $(obj).find("input").each(function(){
                              this.checked=!this.checked;
                              });
}
/*
 *选择节点
 */
function selNode(obj){
    var mainDeptUser = obj.getAttribute("mainDeptUser");
    var id=obj.id;
    id+="User";
    $("#divSelUser").find("ul").each(function(){
                                     if(this.id!=id){
                                     $(this).css({"display":"none"})
                                     }else{
                                     if(mainDeptUser=="1"){
                                     $(this).find("input").each(function(){
                                                                this.checked=true;
                                                                });
                                     }
                                     $(this).css({"display":""})
                                     }
                                     });
}

function submitWorkFlow(){
    var params="";
    var selUser="";
    var url="";
    $("input[name=selUser]").each(function(){
                                  if(this.checked){
                                  selUser=selUser==""?this.value:selUser+","+this.value;
                                  //alert(">>selUser>>"+selUser);
                                  }
                                  });
    
    $("input[name=selNode]").each(function(){
                                  
                                  if(this.checked){
                                  if(selUser==""){
                                  if(this.getAttribute("endNodeFlag")!="1"){
                                  // if(selUser==""){
                                  alert("请选择人员");
                                  return false;
                                  }else{
                                  url=location.href;
                                  }
                                  }else{
                                  url=location.href;
                                  }
                                  
                                  }
                                  });
    //var url=location.href;
    var unid=url.substring(url.indexOf("unid=")+5);
    if(unid.indexOf("&")>0){
        unid=unid.substring(0,unid.indexOf("&"));
    }
    
    var appdb=url.substring(url.indexOf("appdb=")+6);
    if(appdb.indexOf("&")>0){
        appdb=appdb.substring(0,appdb.indexOf("&"));
    }
    if(appdb.indexOf("#")){
        appdb=appdb.replace("#","");
    }
    
    params="unid="+encodeURI(unid);
    params+="&selUser="+encodeURI(selUser);
    $("#content").find("input").each(function(){
                                     
                                     var inputType=this.type.toLowerCase();
                                     
                                     var name=this.name==""?this.name:this.id;
                                     
                                     if(name==""){
                                     return true;
                                     }
                                     if(inputType=="text"){
                                     params+="&"+name+"="+encodeURI(this.value);
                                     }else if(inputType=="radio"){
                                     if(this.checked){
                                     params+="&"+name+"="+encodeURI(this.value);
                                     }
                                     }else if(inputType=="checkbox"){
                                     var name=this.name;
                                     if(params.indexOf("&"+name+"=")!=-1){
                                     return true;
                                     }
                                     var value="";
                                     $("[name="+name+"]").each(function(){
                                                               if(this.checked){
                                                               value=value==""?this.value:value+","+this.value;
                                                               }
                                                               });
                                     params+="&"+name+"="+encodeURI(value);
                                     }else{
                                     params+="&"+name+"="+encodeURI(this.value);
                                     }
                                     });
    $("#content").find("textarea").each(function(){
                                        var name=this.name==""?this.name:this.id;
                                        if(name==""){
                                        return true;
                                        }
                                        params+="&"+name+"="+encodeURI(this.value);
                                        });
    $("#content").find("select").each(function(){
                                      var name=this.name==""?this.name:this.id;
                                      if(name==""){
                                      return true;
                                      }
                                      var value="";
                                      for(var i=0;i<this.options.length;i++){
                                      if(this.options[i].selected){
                                      value=value==""?this.options[i].value:value+","+this.options[i];
                                      }
                                      }
                                      params+="&"+name+"="+ encodeURI(value);
                                      })
    var suggestion=$("#suggestion").val();
    if(suggestion!=""){
        params+="&suggestion="+ encodeURI(suggestion);
    }else{
        $("input[name=selNode]").each(function(){
                                      if(this.checked){
                                      if(this.getAttribute("endNodeFlag")=="1"){
                                      if(document.getElementById("divSuggestion").style.display != "none"){
                                      params+="&suggestion="+ encodeURI(document.getElementById("divSelNode").innerHTML);
                                      }
                                      }
                                      
                                      }
                                      }
                                      )
        
    }
    var url = "";
    $("input[name=selNode]").each(function(){
                                  if(this.checked){
                                  if(this.getAttribute("endNodeFlag")=="1"){
                                  url="http://app.server_address/"+appdb+"/CBXsp_saveDocument_End.xsp";
                                  }else{
                                  url="http://app.server_address/"+appdb+"/CBXsp_saveDocument.xsp";
                                  }
                                  
                                  }
                                  })
    var post = app.postData(url,params);
    if(post!=null){
        eval(post);
        //提交后刷新
        AppUI.chg();
    }
    //document.getElementById("ok").style.display="none";
}

//app新建审批提交处理过程
function submitWorkFlowNew(){
    if(!confirm("是否确认提交?")){
        return false;
    }
    //AppUI.showDialog('正在提交数据','正在提交');
    
    //    var Subject = document.getElementById("Subject").value;
    //    if(Subject==""){
    //        alert("标题不能为空!");
    //        return false;
    //    }
    var params="";
    var selUser="";
    $("input[name=selUser]").each(function(){
                                  if(this.checked){
                                  selUser=selUser==""?this.value:selUser+","+this.value;
                                  }
                                  });
    if(selUser==""){
        var mustSelUser=true;
        $("input[name=selNode]").each(function(){
                                      if(this.checked && (this.getAttribute("nodetype")=="EndNode" || this.getAttribute("nodetype")=="AutoActivity")){
                                      mustSelUser=false;
                                      return false;
                                      }
                                      });
        if(mustSelUser){
            alert("请选择人员");
            return false;
            
        }else{
            alert("当前环节为自动节点，请在电脑端处理");
            return false;
        }
    }
    
    var unid=getQueryString("unid"); //流程unid
    var appdb=getQueryString("wfpath"); //关联主数据库路径
    //var flowName=getQueryString("flowName"); //使用流程名
    var url=location.href;
    var flowName=url.substring(url.indexOf("flowName=")+9);
    params="wfunid="+encodeURI(unid);
    params+="&flowName="+flowName;
    params+="&selUser="+encodeURI(selUser);
    
    
    $("#content").find("input").each(function(){
                                     var inputType=this.type.toLowerCase();
                                     var name=this.name==""?this.name:this.id;
                                     if(name==""){
                                     return true;
                                     }
                                     if(inputType=="text"){
                                     params+="&"+name+"="+encodeURI(this.value);
                                     }else if(inputType=="radio"){
                                     name=this.name;
                                     if(this.checked){
                                     params+="&"+name+"="+encodeURI(this.value);
                                     }
                                     }else if(inputType=="checkbox"){
                                     var name=this.name;
                                     if(params.indexOf("&"+name+"=")!=-1){
                                     return true;
                                     }
                                     var value="";
                                     $("[name="+name+"]").each(function(){
                                                               if(this.checked){
                                                               value=value==""?this.value:value+","+this.value;
                                                               }
                                                               });
                                     params+="&"+name+"="+encodeURI(value);
                                     }else if(inputType=="date"){
                                     params+="&"+name+"="+encodeURI(this.value);
                                     }
                                     });
    
    $("#content").find("textarea").each(function(){
                                        var name=this.name==""?this.name:this.id;
                                        if(name==""){
                                        return true;
                                        }
                                        params+="&"+name+"="+encodeURI(this.value);
                                        });
    $("#content").find("select").each(function(){
                                      var name=this.name==""?this.name:this.id;
                                      if(name==""){
                                      return true;
                                      }
                                      var value="";
                                      for(var i=0;i<this.options.length;i++){
                                      if(this.options[i].selected){
                                      value=value==""?this.options[i].value:value+","+this.options[i];
                                      }
                                      }
                                      params+="&" +name+ "="+ encodeURI(value);
                                      })
    var suggestion=$("#suggestion").val();
    if(suggestion!=""){
        params+="&suggestion="+ encodeURI(suggestion);
    }
    var url="http://app.server_address/"+appdb+"/CBXsp_saveNewDocument.xsp";
    var post = app.postData(url,params);
    if(post!=null){
        eval(post)
        //AppUI.hideDialog();
    }
}



//验证手机号码和邮箱和身份证还有QQ号的;
var Verification = Verification||{}
Verification.email=function(emails){
    var regEmail=/^[_a-z 0-9]+@([_a-z 0-9]+\.)+[a-z 0-9]{2,3}$/;
    return regEmail.test(emails);
}//邮箱验证
Verification.tel=function(tel){
    var regTel=/^\d{6,12}$/;
    return regTel.test(tel);
}//电话号码验证
Verification.card=function(card){
    var regcard=/^\d{18,19}$/;
    return regcard.test(card);
}//身份证验证
Verification.QQ=function(QQ){
    var regQQ = /^\d{5,12}$/;
    return regQQ.test(QQ);
}//QQ验证
Verification.text=function(Class){
    var conter = $(Class).val();
    var ClassType = $(Class).attr("types");
    if(conter==""||conter==null){
        var text = $(Class).siblings('.labels').html();
        alert(text+"不能为空");
        return false;
    }
    if(ClassType=="tel"){
        if(!Verification.tel(conter)){
            alert("电话格式不对");
            return false;
        }
    }
    if(ClassType=="email"){
        if(!Verification.email(conter)){
            alert("邮箱格式不对");
            return false;
        }
    }
    if(ClassType=="card"){
        if(!Verification.card(conter)){
            alert("身份证号码不对");
            return false;
        }
    }
    if(ClassType=="QQ"){
        if(!Verification.QQ(conter)){
            alert("QQ号格式不对");
            return false;
        }
    }
}

//验证页面中的必填文本框是否为空通用方法
function checkRequried(){
    var flag =true;
    $("input").each(function(n){
                    var required=$(this).attr("need");
                    if(required!=null&&required!=""){
                    var type=$(this).attr("type");
                    if(type=="checkbox"){
                    //以下标示，复选框本为必选但是却没有选中，则返回false
                    if(!$(this).checked){
                    alert(required+"不能为空");
                    flag = false;
                    //return false;
                    }
                    }else{
                    if($(this).val().trim()==""){
                    alert(required+"不能为空");
                    $(this).focus();
                    flag = false;
                    //return false;
                    }
                    }
                    }
                    });
    return flag;
}
function checkRequrieds(){
    var flag =true;
    var msg = "";
    $("TEXTAREA").each(function(n){
                       var required=$(this).attr("need");
                       if(required!=null&&required!=""){
                       if($(this).val().trim()==""){
                       //msg+=required+",";
                       msg=required;
                       // alert(required+"不能为空");
                       $(this).focus();
                       flag = false;
                       //return false;
                       }
                       }
                       });
    if(msg!=""){
        alert(msg+"不能为空");
    }
    return flag;
}

function lodings(){
    var w = window.innerWidth;
    var imgh =$("#lodings>img").height();
    $("#lodings>img").css("top",w/2-imgh/2+"px")
}
function kailLodings(){
    $("#lodings").css("display","none")
}
function getDates(time) {
    var w_array=new Array("星期天","星期一","星期二","星期三","星期四","星期五","星期六");
    var d=new Date(time);
    var year=d.getFullYear();
    var month=d.getMonth()+1;
    var day=d.getDate();
    var week=d.getDay();
    var h=d.getHours();
    var mins=d.getMinutes();
    var s=d.getSeconds();
    
    if(month<10) month="0" + month
        if(day<10) day="0" + day
            if(h<10) h="0" + h
                if(mins<10) mins="0" + mins
                    if(s<10) s="0" + s
                        
                        return year + "-" + month + "-" + day + " " + h + ":" + mins +  ":" + s;
    
}
//时间格式 月-日 时间
function getDate_month(time) {
    var w_array=new Array("星期天","星期一","星期二","星期三","星期四","星期五","星期六");
    var d=new Date(time);
    var year=d.getFullYear();
    var month=d.getMonth()+1;
    var day=d.getDate();
    var week=d.getDay();
    var h=d.getHours();
    var mins=d.getMinutes();
    var s=d.getSeconds();
    
    //    if(month<10) month="0" + month
    //    if(day<10) day="0" + day
    if(h<10) h="0" + h
        if(mins<10) mins="0" + mins
            if(s<10) s="0" + s
                
                return month + "月" + day + "日" + h + ":" + mins;
    
}
/*
 提交数据
 */
function postDoc(url,contenter){
    
    var params="";
    $("#"+contenter).find("input").each(function(){
                                        var inputType=this.type.toLowerCase();
                                        var name=this.name==""?this.name:this.id;
                                        if(name==""){
                                        return true;
                                        }
                                        if(inputType=="text"){
                                        params+="&"+name+"="+encodeURI(this.value);
                                        
                                        }else if(inputType=="radio"){
                                        if(this.checked){
                                        params+="&"+name+"="+encodeURI(this.value);
                                        }
                                        }else if(inputType=="checkbox"){
                                        var name=this.name;
                                        if(params.indexOf("&"+name+"=")!=-1){
                                        return true;
                                        }
                                        var value="";
                                        $("[name="+name+"]").each(function(){
                                                                  if(this.checked){
                                                                  value=value==""?this.value:value+","+this.value;
                                                                  }
                                                                  });
                                        params+="&"+name+"="+encodeURI(value);
                                        }
                                        });
    $("#"+contenter).find("textarea").each(function(){
                                           var name=this.name==""?this.name:this.id;
                                           if(name==""){
                                           return true;
                                           }
                                           params+="&"+name+"="+encodeURI(this.value);
                                           });
    
    $("[contenteditable='true']").each(function(){
                                       var name=this.name==""?this.name:this.id;
                                       if(name==""){
                                       return true;
                                       }
                                       
                                       params+="&"+name+"="+encodeURI(this.innerHTML);
                                       });
    $(".form-group>.required[type=date]").each(function(i){
                                               params+="&"+$(this).attr("name")+"="+encodeURI($(this).val());
                                               })
    $("#"+contenter).find("select").each(function(){
                                         var name=this.name==""?this.name:this.id;
                                         if(name==""){
                                         return true;
                                         }
                                         var value="";
                                         for(var i=0;i<this.options.length;i++){
                                         if(this.options[i].selected){
                                         value=value==""?this.options[i].value:value+","+this.options[i];
                                         }
                                         }
                                         params+="&name="+ encodeURI(value);
                                         })
    params=params.substring(1);//去掉首字母的&
    return params;
}

//签到显示
function openSign(data){
    for(var r in data){
        try{
            $("#"+r).each(function(i){
                          var value=data[r];
                          
                          if(r=="lastModify"){
                          value=getDates(value);
                          }
                          if(r=="signNum"){
                          var signNum=data[r];
                          if(signNum==""||signNum==0||signNum==null){
                          $("#homeSign").css('display', 'block');
                          document.getElementById("team").innerHTML = "0";
                          }else{
                          $("#newSign").css('display', 'block');
                          document.getElementById("team").innerHTML = "1";
                          }
                          }
                          //$("#"+r).html(decodeURI(value))
                          $("#"+r).html(value)
                          });
        }catch(e){
            alert(e)
        }
        
    }
}


function getQueryString(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
    var r = window.location.search.substr(1).match(reg);
    if (r != null)
        return unescape(r[2]);
    return null;
}

//地图的经纬度
var getLocation = app.getLocation();
var longitude = getLocation.longitude//112.887859;
var latitude =getLocation.latitude //28.232925;
