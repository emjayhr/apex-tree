(function($){
	$.widget("ui.hijerarhija_report",{
		options:{
			ajaxID:null
			, regionID:null
			, pageItemsToSubmit:null
			, searchItem:null
			, ajaxOnExpand: false
			, unselectOnCollapse: true
			, classSelected: "selected"
			, classExpanded: "expanded"
			, clickable: false
			, selectable: false
			, mode: "NORMAL"
			, expandButton: null
			, collapseButton: null
			, clearSearchButton: null,
		},
     innerData: {
          timer:null,
          searchLagMiliseconds: 300,
 	},
		getElement: function (){
		return $('#'+this.options.regionID);
	},
	 getContainer: function (){
	 return $('#'+this.options.regionID+"_container");
	 },
	
		resetMode: function (){
			var opt = this.options;
			var c = this.getContainer();
			
        if (opt.searchItem) {
            opt.mode = $("#"+opt.searchItem).val()?"SEARCH":"NORMAL";
            
            if (opt.mode=="SEARCH"){
                c.addClass("search-mode");
								opt.expandButton?$("#"+opt.expandButton).hide():null;
								opt.collapseButton?$("#"+opt.collapseButton).hide():null;
								opt.clearSearchButton?$("#"+opt.clearSearchButton).show():null;
            } else {
                c.removeClass("search-mode");
								opt.expandButton?$("#"+opt.expandButton).show():null;
								opt.collapseButton?$("#"+opt.collapseButton).show():null;
								opt.clearSearchButton?$("#"+opt.clearSearchButton).hide():null;
            }
        }
		},
		setTimer: function (data, time){
          var p = this;
          if (p.innerData.timer)  clearTimeout(p.innerData.timer);
          
				p.innerData.timer = setTimeout(function(){
                   p.search(data);
              }, time);
              
		},
	
	refreshNode: function (data){
		this.makeRequest({x01: "REFRESH_NODE", x02: data.id, x09: p.getExpandedElements(node)}, 
			function(pData) {
				
				node.replaceWith(pData);
		});
		
	},
	refreshParentNode: function (data){
		var p = this;
		
		var el = this.getContainer().find("li[hid="+data.id+"]");
		var parentNode = el.parent().closest("li");
		if (parentNode) {
			var obj = {id: parentNode.attr("hid")};
			var result = Object.assign({},data, obj);
			this.refreshNode(result);
		}
	},
	getExpandedElements: function (node) {
		var el = node?$(node).parent():this.getContainer();
		return el.find("li.expanded").map(function(d,e){
			return $(e).attr("hid");
		}).get().join(":");
		
		
	},

	_init:function(){
		var p = this;
     var tree = this.getElement();
		 var c = this.getContainer();
		 
		tree.on('apexrefresh', function(){ 
			p.refreshReport();
		});
		
		
		if (p.options.selectable)	c.addClass("selectable");
		
		 tree.on('noderefresh', function(event, data){ 
			p.refreshNode(data);
		});
		
		tree.on('parentnoderefresh', function(event, data){ 
			p.refreshParentNode(data);
		});
		
		tree.on('picknode', function(event, data) {
			
			p.pickNodeIdAfterSearch(data.id);
		});
		
		if (p.options.expandButton) {
			$("#"+p.options.expandButton).attr("onclick","void(0)").click(function(e){
				p.expandAll();
				e.preventDefault();
				return false;
			});
		}
        
        if (p.options.collapseButton) {
			$("#"+p.options.collapseButton).attr("onclick","void(0)").click(function(e){
				p.collapseAll();
				e.preventDefault();
				return false;
			});
		}
        
        if (p.options.clearSearchButton) {
			$("#"+p.options.clearSearchButton).attr("onclick","void(0)").click(function(e){
				if (p.options.searchItem) {
                    $("#"+p.options.searchItem).val("");
                }
                p.search();
				return false;
			});
		}
        
        if (p.options.searchItem){
            
          $("#"+p.options.searchItem).on('keydown', function(e) {
            if (e.keyCode==13) {
                e.preventDefault();
                p.setTimer(data = $(this).val(), 0);
                  return false;
              }
          });
            
          $("#"+p.options.searchItem).on('keyup', function(e) {
            p.setTimer(data = $(this).val(), p.innerData.searchLagMiliseconds);
          });
        }
        
        p.resetMode();
		
		this.getElement().on('click', 'a', function (e){
			
			var el = $(this);
			
			var obj2send = {link:el.attr("hl"), linkdata:el.attr('hdata')}
			
			var obj = el.attr("hjson");
			
			if (obj) {
				try {
					obj = jQuery.parseJSON( obj);
					obj2send = Object.assign(obj2send, obj);
				} catch (err){
					
				}
				
			}
			
			
			p.triggerNodeEvent('nodelink',el.closest("li"), obj2send);
			
			e.stopPropagation();
			return false;
		});
      
        $('#'+p.options.regionID).on('click', 'li > div.node', function(e){
            p.nodeClick($(this).parent());
        });

        $('#'+p.options.regionID).on('click', 'li > span.toggler', function(e){
            p.nodeToggle($(this).parent());
        });

	},
    setData: function (data){
        this.getContainer().html(data);
    }
	, makeRequest: function (obj, f){
		
		var p = this;
		
		var lobj = Object.assign({
			x01: "REFRESH_REPORT",
			x09: p.getExpandedElements(),
			pageItems: p.options.pageItemsToSubmit
		}, obj)
		
		//console.log(lobj);
		//console.log('request: '+lobj.x01);
		apex.server.plugin (p.options.ajaxID,
	      lobj,
		    {
            dataType: 'text',
            loadingIndicator: p.getElement(),
	        success: function(pData) {
					if (f) {
						f(pData);
					} else {
						p.setData(pData);
					}
				}
			}
			)
	},
	refreshReport: function(){
		this.makeRequest();
	},
	highlightNode: function (id) {
		var p = this;
		var node = this.getElement().find("li[hid="+id+"]");
		
		if (node){
        node.addClass("highlight");
        setTimeout(function(){
            node.removeClass("highlight");
            setTimeout(function(){
                node.addClass("highlight");
                setTimeout(function(){
                    node.removeClass("highlight");
                
                },700);
            },300);
        },700);
				
		$('html, body').animate({
				scrollTop: node.offset().top -200
		}, 1000);	
		}		
	},
	
	pickNodeIdAfterSearch: function(id){
			var p = this;
			
			var node = this.getElement().find("li[hid="+id+"]");
			
			if (this.options.mode!="NORMAL"||node.length==0){
				this.makeRequest({x01:'PICK_NODE', x02: id},
					function(pData){
						if (p.options.searchItem) {
								$("#"+p.options.searchItem).val("");
									}
									p.resetMode();
					
									p.setData(pData);
									p.highlightNode(id);
					});
			} else {
				node.parents("li").not(".expanded").each(function(a, n){
					p.nodeExpand(n);
				});
				p.highlightNode(id);
			} 
			/*return;
			
			
			apex.server.plugin (p.options.ajaxID,{
	        x01: "PICK_NODE",
           x02: id,
			x03: p.getExpandedElements(),
	        pageItems: p.options.pageItemsToSubmit
	      },
		    {
          dataType: 'text',
	        success: function(pData) {
                if (p.options.searchItem) {
                    $("#"+p.options.searchItem).val("");
                }
                p.resetMode();
				
                p.setData(pData);
                var elem = $(p.innerData.element).find("li[hid="+id+"]");
                p.highlightNode(elem);
                
                $('html, body').animate({
                    scrollTop: elem.offset().top -200
                }, 1000);
                
               
				}
			})*/
    },
    nodeClick: function(node){
        var p = this;
        
        if (this.options.mode=="SEARCH"){
            p.pickNodeIdAfterSearch($(node).attr('hid'));
        } else if (this.options.selectable) {
					
            if ($(node).hasClass(p.options.classSelected)){
                p.nodeUnselect(node, true);    
            } else {
                p.nodeSelect(node, false);
            }
        } else if (this.options.clickable) {
            p.triggerNodeEvent('nodeclick',node);
			
        } else { // ako nije clickable onda mozemo expand/collapse odradit 
            p.nodeToggle(node);
        }
        
    },
    nodeUnselect: function(node, fireUnselectEvent){
        var p = this;

        if (fireUnselectEvent) p.triggerNodeEvent('nodeunselect',node);
        
        $(node).removeClass(p.options.classSelected);
          
    },
    nodeUnselectSelected: function(d, fireUnselectEvent){
    	var p = this;
        
        var elements;
        
        
        elements = d.find("li.selected");
        
        elements.each(function(i, el){
            p.nodeUnselect(el, fireUnselectEvent);
        });
          
    },
    nodeSelect: function(node){
		var p = this;
        
     p.nodeUnselectSelected(this.getElement(), false);
     p.triggerNodeEvent('nodeselect',node);//{id:$(node).attr('hid')});
		$(node).addClass(p.options.classSelected);
        
	},
    nodeToggle: function(node){
        var p = this;
        
			if ($(node).hasClass("leaf")) return;
				
        if ($(node).hasClass(p.options.classExpanded)){
            p.nodeCollapse(node);    
        } else {
            p.nodeExpand(node);
        }
    },
	nodeExpand: function(node) {
		var p = this;
				
     if (p.options.ajaxOnExpand){
			this.makeRequest({x01: "EXPAND", x02: $(node).attr("hid")},
				function(pData){
					$(node).children('ul').html(pData);
					$(node).addClass(p.options.classExpanded);
					$(node).find("> span.toggler i").removeClass("fa-caret-right").addClass("fa-caret-down");
				});
		} else {
			$(node).addClass(p.options.classExpanded);
        $(node).find("> span.toggler i").removeClass("fa-caret-right").addClass("fa-caret-down");
		}
    },
    nodeCollapse: function(node) {
          var p = this;
          
          if (p.options.unselectOnCollapse)  p.nodeUnselectSelected(node, true);
          
          if (p.options.ajaxOnExpand){
              $(node).children("ul").html("");
              p.nodeUnselectSelected(node, true);
          }
          $(node).removeClass(p.options.classExpanded);
          $(node).find("> span.toggler i").addClass("fa-caret-right").removeClass("fa-caret-down");
          
    },
		expandAll: function (){
			this.makeRequest({x01: "EXPAND_ALL"});
		},
		collapseAll: function (){
			this.makeRequest({x01: "COLLAPSE_ALL"});
		},
		search: function (searchString) {
			var p = this;

			this.makeRequest({x01: "SEARCH",x02: searchString},
				function(pData){
					p.nodeUnselectSelected(p.getElement(), true);
					p.resetMode();
					p.setData(pData);
			});

		},
		triggerNodeEvent: function (event, node, obj2){
			apex.event.trigger(this.getElement(), event, Object.assign({},{id:$(node).attr('hid'), element:$(node)}, obj2));
		}
	});

})(apex.jQuery);