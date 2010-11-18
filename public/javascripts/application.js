jQuery.fn.limit = function(n){
  var self = this;
  return this.click(function(){
    return self.filter(":checked").length <= n;
  });
};

$(function(){
  //for autofocus: cf: http://diveintohtml5.org/forms.html
  if (!("autofocus" in document.createElement("input"))) { 
    $(".pastearea").focus(); 
  }

  //for autogrow:
  $(".pastearea").elastic();

  //for limit: http://www.slideshare.net/gueste8d8bc/growing-jquery
  $(".version-box").limit(2);
});
