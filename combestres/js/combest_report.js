//生成列表文件,datas,表示服务器返回的json数据，templateId表示条目模板，contentId表示容器的标识，ifBefore追加位置，0表示在后面追加，1表示在前面追加，2表示替换
var canfresh=true;//是否可刷新标志
function onTab(key){
   if(key==1){
        //window.location.href="chinaWare-alyz_Ram.html";
//        window.location.href="chinaWare-alyz-sell.html";
window.location.href="html/html_cn/cnOrderDetail.html";
    }else if(key==2){
     	window.location.href="html/html_cn/chinaWare-alyz_Ram.html";
    }else if(key=="cc" || key=="zn"||key=="cxsh"||key=="sc"||key=="pb"){
         window.location.href="chinaWare-alyz_three.html?key="+key;
    }else{
         window.location.href="chinaWare-alyz.html?key="+key;
    }
 }
function lists(json,templateId,contentId,isBefore){
    var template=$("#"+templateId).html();
    var rows="";
    var content=$("#"+contentId)[0].innerHTML;

	if(json.error){
		$("#"+contentId)[0].innerHTML=json.error;
		return;
	}
	if(json.nomore){
		window.app.showMsg(json.nomore);//调用android的提示信息
		canfresh=false;
		if(document.getElementById("loadStaut")){
			document.getElementById("loadStaut").style.display="none";
		}
		return;
	}

	var datas=json.list;
	if(datas.length<1){
		checkLogin();
	}
    for(var i=0;i<datas.length;i++){
        var row=template;
        var data=datas[i];
        for(var r in data){
			//console.log(r);
            var reg=new RegExp("\{"+r+"\}","gi");
            row=row.replace(reg,data[r]);
        }
         var index=row.indexOf("{%");
         if(index!=-1){
              var eIndex=row.indexOf("%}");
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
         var index=row.indexOf("{#");
         if(index!=-1){
        	 var eIndex=row.indexOf("#}");
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

		 row=row.replace("ids","ids_"+i);
		 row=row.replace("iddd","iddd_"+i);
        rows+=row;//加上行元素

    }
    if(isBefore=="1"){
      content=rows+content;
    }else if(isBefore=="2"){
    	//console.log("执行本地替换>>>")
    	if(datas.length>0){
    		content=rows;
    	}
    }else{
        content+=rows;
    }

    $("#"+contentId)[0].innerHTML=content;
    if(document.getElementById("loadStaut")){
        document.getElementById("loadStaut").style.display="none";
    }
	 try{
    	exectueUserdefined();
    }catch(e){
    	//没有这个方法
    }
}
function list(json,templateId,contentId,isBefore){
    var template=$("#"+templateId).html();
    var rows="";
    var content=$("#"+contentId)[0].innerHTML;

	if(json.error){
		$("#"+contentId)[0].innerHTML=json.error;
		return;
	}
	//向下滑动没有更多数据
	if(json.nomore){
        canfresh=false;
        if(document.getElementById("loadStaut")){
            document.getElementById("loadStaut").style.display="none";
        }
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
}


function listAppend(json,templateId,contentId,isBefore){
    var template=$("#"+templateId)[0].innerHTML;
    template = template.replace("<tbody>","").replace("</tbody>","");

    var rows="";
    var content=$("#"+contentId)[0].innerHTML;
	if(json.error){
		$("#"+contentId)[0].innerHTML=json.error;
		return;
	}
    content = content.replace("<tbody>","").replace("</tbody>","");
	var datas=json.list;
    for(var i=0;i<datas.length;i++){
        var row=template;
        var data=datas[i];
        for(var r in data){
            var reg=new RegExp("\{"+r+"\}","gi");
            row=row.replace(reg,data[r]);
        }

        rows+=row;//加上行元素

    }

    $("#"+contentId)[0].innerHTML=content+rows;
    if(document.getElementById("loadStaut")){
        document.getElementById("loadStaut").style.display="none";
    }
}

function list_liu(json,templateId,contentId,isBefore){


    var template=$("#"+templateId).html();
    var rows="";
    var content=$("#"+contentId)[0].innerHTML;

	if(json.error){
		$("#"+contentId)[0].innerHTML=json.error;
		return;
	}
	//向下滑动没有更多数据
	if(json.nomore){
        canfresh=false;
        if(document.getElementById("loadStaut")){
            document.getElementById("loadStaut").style.display="none";
        }
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
         row=row.replace("choose","choose_"+i);
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
}
function editS(data){
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
function edit(data){
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

function open(data){
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
}

//更新视图上的数据
/*
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
}*/
function refresh(){
    //监听滚动条
    $(window).scroll(function(){
    　　var scrollTop = $(this).scrollTop();
    　　var scrollHeight = $(document).height();
    　　var windowHeight = $(this).height();
    　　if(scrollTop + windowHeight == scrollHeight){
    　　　　try{
                if(canfresh){
                    //是否可以执行更新数据
                    getDatas(start,true);
                }
             }catch(e){ }
         }
   });
}


function change(){
    //监听滚动条

    $(window).scroll(function(){
    　　var scrollLeft = $(this).scrollLeft();
  　　  var scrollWidth = $(document).width();
  　　  var windowWidth = $(this).height();

      //横向滑动判断
        if(scrollLeft + windowWidth >= scrollWidth ){
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

traceType="";
CanTraceFlag="";
//显示节点及人员选择信息
function showNextNode1(json){
    CanTraceFlag=json.CanTraceFlag;
    if(CanTraceFlag=="3"){
        $("#divSuggestion").css({"display":"none"});
    }
    $("#nodeSubject").html(json.nodeSubject);
    traceType=json.SelTraceType;
    var checkNodeHtml="";
    var userHtml="";
    var tempCheck='<label onclick="selNode(this)" id="{value}" class="{class}"> <input type="{type}" name="selNode"   value="{value}">{text}</label>';
    for(var i=0;i<json.nodeList.length;i++){
        var checkHtml=tempCheck;
        var data=json.nodeList[i];
        var subject=data.Subject;
        var nodeId=data.nodeId;
        var type=data.condition;
        checkHtml=checkHtml.replace("{value}",nodeId);
        checkHtml=checkHtml.replace("{text}",subject);
        if(type=="3"||type=="8"){
            checkHtml=checkHtml.replace("{class}","checkbox-inline");
            checkHtml=checkHtml.replace("{type}","checkbox");
        }else{
            checkHtml=checkHtml.replace("{class}","radio-inline");
            checkHtml=checkHtml.replace("{type}","radio");
        }
        checkNodeHtml+=checkHtml;
        userHtml+=showUserList(data);
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
    var id=obj.id;
    id+="User";
    $("#divSelUser").find("ul").each(function(){
        if(this.id!=id){
            $(this).css({"display":"none"})
        }else{
            $(this).css({"display":""})
        }
    });
}

function submitWorkFlow(){
    var params="";
    var selUser="";
    $("input[name=selUser]").each(function(){
        if(this.checked){
            selUser=selUser==""?this.value:selUser+","+this.value;
        }
    });
    if(selUser==""){
        alert("请选择人员");
        return false;
    }
    var url=location.href;

    var unid=url.substring(url.indexOf("unid=")+5);
    if(unid.indexOf("&")>0){
         unid=unid.substring(0,unid.indexOf("&"))
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
        params+="&name="+ encodeURI(value);
     })
     var suggestion=$("#suggestion").val();
     if(suggestion!=""){
        params+="&suggestion="+ encodeURI(suggestion);
     }
    
    var url="http://app.server_address/app.ou/oa/combest_fw.nsf/CBXsp_saveDocument.xsp";
    // var url="http://{app.server_address}/{app.ou}/oa/combest_fw.nsf/CBXsp_saveDocument.xsp";
    var post = app.postData(url,params);
    if(post!=null){
        eval(post)
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


//地图的经纬度 
var getLocation = app.getLocation();                                                                       
var longitude = getLocation.longitude//112.887859;
var latitude =getLocation.latitude //28.232925;
