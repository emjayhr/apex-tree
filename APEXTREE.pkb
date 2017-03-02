create or replace package body apextree is
    type t_config is record (
      expandCollapse boolean
      , ajaxOnExpand boolean
      , expandedToLevel number
      , searchItem varchar2(100)
      , clickable boolean
      , selectable boolean
    );
    
    function config (
      p_region in apex_plugin.t_region
      ) return t_config
    is
      v_config t_config;
    begin
      v_config.expandCollapse := p_region.attribute_01 = 'Y';
      v_config.ajaxOnExpand := p_region.attribute_03 = 'Y';
      v_config.expandedToLevel := nvl(p_region.attribute_02,999999);
      v_config.searchItem := p_region.attribute_04;
      v_config.clickable :=  p_region.attribute_05 = 'Y';
      v_config.selectable :=  p_region.attribute_06 = 'Y';
      return v_config;
    end;
      
    procedure setSearchFieldState (
      p_region in apex_plugin.t_region
      , i_value in varchar2
    )
    is
    begin
      if config(p_region).searchItem is not null then 
        apex_Util.set_session_state(config(p_region).searchItem, i_value);
      end if;
    end;
     
    function get_data (
      i_region_source in varchar2
      , i_region_name in varchar2
        , i_master_id in number default null
      ) return t_hij_table pipelined
    is
      v_tab apex_plugin_util.t_column_value_list2;
      v_rec t_hij_record;
      v_query varchar2(32000);
    begin
      if i_master_id is not null then 
        v_query := 'select * from ('||i_region_source||') where master_id = '||i_master_id;
      else
        v_query := i_region_source;
      end if;
    
      v_tab := apex_plugin_util.get_data2(
        p_sql_statement  => v_query
        , p_min_columns    => 3
        , p_max_columns    => 20
        , p_component_name => i_region_name);

        for j in 1..v_tab(1).value_list.count loop
          v_rec := null;
          for i in 1..v_tab.count loop
          
          
            --v_rec := null;
            
            case v_tab(i).name
              when 'ID' then            v_rec.id := v_tab(i).value_list(j).number_value;
              when 'MASTER_ID' then     v_rec.master_id := v_tab(i).value_list(j).number_value;
              when 'NAME' then          v_rec.name := v_tab(i).value_list(j).varchar2_value;
              when 'DESCRIPTION' then   v_rec.description := v_tab(i).value_list(j).varchar2_value;
              when 'DESCRIPTION_2' then v_rec.description_2 := v_tab(i).value_list(j).varchar2_value;
              when 'NODE_TYPE' then     v_rec.node_type := v_tab(i).value_list(j).varchar2_value;
              when 'CLASS_NAME' then    v_rec.class_name := v_tab(i).value_list(j).varchar2_value;
              when 'ICON' then          v_rec.icon := v_tab(i).value_list(j).varchar2_value;
              when 'LINK1' then          v_rec.link1 := v_tab(i).value_list(j).varchar2_value;
              when 'LINK2' then          v_rec.link2 := v_tab(i).value_list(j).varchar2_value;
              when 'LINK3' then          v_rec.link3 := v_tab(i).value_list(j).varchar2_value;
              when 'ORD' then           v_rec.ord := v_tab(i).value_list(j).varchar2_value;
              when 'ERROR' then           v_rec.error := v_tab(i).value_list(j).varchar2_value;
              when 'SEARCHABLE' then     v_rec.searchable := v_tab(i).value_list(j).number_value;
                --v_rec.ord_num := v_tab(i).value_list(j).number_value;
              else null;
            end case;
            
           
          end loop;
           pipe row (v_rec);
        end loop;
        
        return;

    end get_data;
    
    
    procedure print_report (
      p_region in apex_plugin.t_region
      , p_plugin in apex_plugin.t_plugin
      , i_ajax_mode in varchar2 default null
    )
    is
    
     
    



      v_last_lvl number := -1;
      v_last_print_lvl number := -1;
      
      v_expandedToLevel number := config(p_region).expandedToLevel;
      v_expandCollapse boolean := config(p_region).expandCollapse;
      v_ajaxOnExpand boolean := config(p_region).ajaxOnExpand;
      v_ajaxOnExpandNumber number;
     /* hasExpandCollapse boolean := p_region.attribute_01 = 'Y';
      ajaxOnExpand boolean := p_region.attribute_03 = 'Y';
      v_expandedToLevel number :=p_region.attribute_02;
      v_searchItem varchar2(100) := p_region.attribute_04;
      */
      v_expandedElements varchar2(32000) := apex_application.g_x09;
      isExpanded boolean;
      v_master_id_include number;
      v_searchValue varchar2(500);

      v_pick_node_id number;
      v_master_id number;
      v_class_name varchar2(200);
      
      type t_data_record is record (
        lvl number
        , id number(30)
        , name varchar2(500)
        , is_leaf number(1)
        , master_id number(30)
        , description varchar2(4000)
        , description_2 varchar2(4000)
        , node_type varchar2(500)
        , class_name varchar2(300)
        , icon varchar2(100)
       -- , ord varchar2(300)
        , expand number(1)
      --  , print number(1)
        , link1 varchar2(100)
        , link2 varchar2(100)
        , link3 varchar2(100)
        
        , error varchar2(4000)
     --   , print number(1)
      );
      
      v_rec t_data_record;
      
      type t_data_cur is ref cursor return t_data_record;
      v_cur t_data_cur;
    
      v_print boolean;
      type t_node_expanded is table of number(1) index by pls_integer;
      
      expandedNodes t_node_expanded;
      v_clickable boolean := config(p_region).clickable;
      
       procedure printLink (
        i_link in varchar2
        , i_n in number
        )
      is
        v_pos number;
        v_string varchar2(500) := i_link;
        v_label varchar2(500);
        v_hdata varchar2(200);
        v_icon varchar2(100);
        v_jsondata varchar2(200);
        function get (
          i_str in varchar2
          , i_nth in number
          ) return varchar2
        is
        begin
          return trim(rtrim(regexp_substr(i_str,'[^;]*;',1,i_nth),';'));
        end;
      begin 
        
        
        
        if v_string is not null then 
          v_string := rtrim(v_string,';')||';';
          
          v_label := get(v_string,1);
          v_hdata := get(v_string,2);
          v_icon :=  get(v_string,3);
          v_jsondata := get(v_string,4);
          
          if v_jsondata is not null then 
            v_jsondata := '{'||v_jsondata||'}';
          end if;
        
          sys.htp.prn('<a href="javascript:void(0);" hl="'||i_n||'" hdata="'||v_hdata||'" hjson='''||v_jsondata||'''>');
          if v_icon is not null then 
            sys.htp.prn('<i class="fa '||v_icon||'"></i> ');
          end if;
          sys.htp.prn(v_label||'</a>');
        end if;
      end;
    begin
        v_ajaxOnExpandNumber := case when v_ajaxOnExpand then 1 else 0 end;
    
      case nvl(i_ajax_mode,'REFRESH_REPORT')
        when 'REFRESH_REPORT' then  
  --        v_expandedElements := apex_application.g_x02;
          null;
        when 'SEARCH' then 
          setSearchFieldState(p_region, apex_application.g_x02);

        when 'EXPAND' then  
          v_master_id := apex_application.g_x02;
        when 'EXPAND_ALL' then  
          v_expandedToLevel := 999;
        when 'COLLAPSE_ALL' then 
          v_expandedToLevel := 1;
          v_expandedElements := Null;
        when 'PICK_NODE' then 
          setSearchFieldState(p_region, null);
          v_pick_node_id := apex_application.g_x02;
         -- v_expandedElements := apex_application.g_x03;
       /* when 'REFRESH_NODE' then
          v_master_id_include := apex_application.g_x02;
          --v_expandedElements := apex_application.g_x03;*/
        else 
          sys.htp.p(nvl(i_ajax_mode,'REFRESH_REPORT'));
      end case;
    
    
     
      if config(p_region).searchItem is not null then
        v_searchValue := v(config(p_region).searchItem);
      end if;
      
      
     /* if v_master_id_include is not null then 
        open v_cur for 
           select level lvl, id, name, connect_by_isleaf as is_leaf, master_id, description, description_2, node_type, class_name, icon--, ord
            , case 
                when v_expandedElements is not null and instr(v_expandedElements,to_char(id))!=0 then 1 
                else 0 
              end as expand
            \*, case 
                when id = v_master_id_include then 1
                when v_expandedElements is not null and instr(v_expandedElements,to_char(prior id))!=0 then 1 
                else 0 
              end as print*\
            , link1, link2, link3
            , error
          from table(get_data(p_region.source, p_region.name))
          connect by prior id = master_id
          start with id = v_master_id_include
          order siblings by ord;
       
      els*/
      if v_searchValue is not null then 
        v_expandCollapse := false;
           
        open v_cur for
          select 1 as lvl, id, name, 1 as is_leaf, null master_id, description, description_2, node_type, class_name, icon--, ord_char, ord_num
            , 0 as expand
           -- , 1 as print
            , null, null, null
            ,  error
          from table(get_data(p_region.source, p_region.name))
          where instr(upper(name||'$'||description||'$'||description_2),upper(v_searchValue)) != 0
              and searchable = 1
          order by ord;
          
      elsif v_pick_node_id is not null then 
         
         open v_cur for 
          with v_query as (
            select /*+ materialize */ *
            from table(get_data(p_region.source, p_region.name))
          )
           select level lvl, t.id, t.name, connect_by_isleaf as is_leaf, t.master_id, t.description, t.description_2, t.node_type, t.class_name, t.icon--, t.ord
            , case 
                when x.id is not null and connect_by_isleaf = 0 and x.id != v_pick_node_id then 1 
             --   when v_expandedElements is not null and instr(v_expandedElements,to_char(t.id))!=0 and connect_by_isleaf = 0 then 1 
                else 0 
                end as expand
            , link1, link2, link3
            ,  error
          from v_query t
          left join (
            select id
            from v_query
            connect by id = prior master_id
            start with id = v_pick_node_id) x on (x.id = t.id)
          connect by prior t.id = t.master_id
          start with t.master_id is null
          order siblings by t.ord;
                     
      elsif v_master_id is null then -- OSNOVNI QUERY
        open v_cur for 
          select level lvl, id, name, connect_by_isleaf as is_leaf, master_id, description, description_2, node_type, class_name, icon--, ord
            , case 
              --  when v_expandedElements is not null and instr(v_expandedElements,to_char(id))!=0 and connect_by_isleaf = 0 then 1 
                when  level < v_expandedToLevel then 1 
                else 0 
              end as expanded
            , link1, link2, link3
            , error
          from table(get_data(p_region.source, p_region.name))
          connect by prior id = master_id
          start with master_id is null
          order siblings by ord;
               
      elsif v_master_id is not null then  -- EXPAND NODE
      
  --      v_expandedToLevel := 1;

        open v_cur for 
           select level lvl, id, name, connect_by_isleaf as is_leaf, master_id, description, description_2, node_type, class_name, icon--, ord
            , 0 as expanded 
            , link1, link2, link3
            , error
          from table(get_data(p_region.source, p_region.name))
          connect by prior id = master_id
          start with master_id = v_master_id
          order siblings by ord;
      
            
      end if;
      
        
        
      if v_cur%isopen then 
        loop
          fetch v_cur into v_rec;
          exit when v_cur%notfound;
          
          
       
          case 
            when v_expandCollapse and not v_ajaxOnExpand then 
              v_print := true;
            when v_rec.expand = 1 then 
              v_print := true;
            when v_rec.master_id is null then 
              v_print := true;
            when v_rec.master_id = v_master_id then 
              v_print := true;
            when v_searchValue is not null then 
              v_print := true;
            when v_expandedElements is not null and instr(v_expandedElements,to_char(v_rec.id))!=0 and v_rec.is_leaf = 0 then 
              v_print := true; 
              v_rec.expand := 1;
            else
              begin
                 v_print := expandedNodes(v_rec.master_id) = 1;
              exception
                when others then 
                  v_print := false;
              end;
           end case;
             
              

          
          
          if not v_print  then
              v_last_lvl := v_last_print_lvl+1;
              continue;
          end if;
          
          for x in 1..(v_last_lvl - v_rec.lvl ) loop
            sys.htp.prn('</li></ul>');
          end loop;
         
          
          sys.htp.p('<li hid="'||v_rec.id||'" ');
          
          
          v_class_name := v_rec.class_name;
          
          if v_rec.expand = 1 then 
            v_class_name := v_class_name||' expanded';
          end if;
          if v_rec.is_leaf = 1 then 
            v_class_name := v_class_name||' leaf';
          end if;
          
          if v_expandCollapse and v_rec.is_leaf = 0 then 
            v_class_name := v_class_name||' toggler';
          end if;
          
          if v_class_name is not null then 
            sys.htp.prn('class="'||trim(v_class_name)||'"');
          end if;
          
          sys.htp.p('>');


          if v_expandCollapse and v_rec.is_leaf = 0 then 
              sys.htp.prn('<span class="toggler">');
              if v_rec.expand = 1 then 
                  sys.htp.prn('<i class="fa fa-caret-down"></i>');
              else
                  sys.htp.prn('<i class="fa fa-caret-right"></i>');
              end if;
              sys.htp.prn('</span>');
          end if;
          
          sys.htp.prn('<div class="node">');
          sys.htp.prn('<div class="body">');
          if v_rec.node_type is not null then 
              sys.htp.prn('<div class="node-type">'||v_rec.node_type||'</div>');
          end if;
          
          if v_rec.icon is not null then 
            sys.htp.prn('<div class="node-icon"><i class="fa '||v_rec.icon||'"></i></div>');
          end if;
          
          sys.htp.prn('<h6>'||v_rec.name||'</h6>');
          
          
  --        if coalesce(v_rec.description,v_rec.description_2, v_rec.link1, v_rec.link2, v_rec.link3, v_rec.error) is not null then 
            

            if coalesce(v_rec.description,v_rec.description_2) is not null then 
              sys.htp.prn('<div class="desc">');  
              if v_rec.description is not null then 
                sys.htp.prn('<p>'||v_rec.description||'</p>');
              end if;
              if v_rec.description_2 is not null then 
                sys.htp.prn('<p>'||v_rec.description_2||'</p>');
              end if;
              sys.htp.prn('</div>'); -- end of desc
            end if;
            
            sys.htp.p('</div>'); -- body 
            sys.htp.prn('<div class="content clearfix"></div>');
            if v_searchValue is null and coalesce(v_rec.link1,v_rec.link2, v_rec.link3, v_rec.error) is not null then 
              sys.htp.prn('<div class="footer clearfix">');
  --            sys.htp.prn('<div class="links">');
              printLink(v_rec.link1, 1);
              printLink(v_rec.link2, 2);
              printLink(v_rec.link3, 3);
              sys.htp.prn('<span class="error">'||v_rec.error||'</span>');
  --            sys.htp.prn('<div style="clear:left"></div>');
            sys.htp.prn('</div>');
            end if;
  /*          
            if v_rec.error is not null then 
              sys.htp.prn('<div class="error">'||v_rec.error||'</div>');
            end if;*/
          sys.htp.prn('</div>'); -- end of node
          
          if v_rec.is_leaf = 0 then 

              sys.htp.prn('<ul>');
          end if;

          v_last_lvl := v_rec.lvl;
          v_last_print_lvl := v_rec.lvl;
          expandedNodes(v_rec.id) := v_rec.expand;
        end loop;
        close v_cur;
      else
        sys.htp.p('greška: nije otvoren cursor');
      end if;
      
      for x in 1..(nvl(v_last_lvl,0) - nvl(v_rec.lvl,0) ) loop
          sys.htp.prn('</li></ul>');
      end loop;      
        
      
      
     
      
      
    end;
    
    function render_report (
      p_region              in apex_plugin.t_region,
      p_plugin              in apex_plugin.t_plugin,
      p_is_printer_friendly in boolean )
      return apex_plugin.t_region_render_result
    is
     
      v_onload_code varchar2(32000);
      v_containerID varchar2(200);
      hasExpandCollapse boolean := p_region.attribute_01 = 'Y';
      ajaxOnExpand boolean := p_region.attribute_03 = 'Y';
      --clickable boolean := p_region.attribute_05 = 'Y';
      v_expandedClass varchar2(100) := 'expanded';
    begin
    
      v_containerID := sys.HTF.escape_sc(p_Region.static_id)||'_container';

      v_onload_code := 'apex.jQuery("#' || sys.HTF.escape_sc(p_Region.static_id) || '").hijerarhija_report({' ||
          apex_javascript.add_attribute('ajaxID'  , sys.HTF.escape_sc(apex_plugin.get_ajax_identifier))||
          apex_javascript.add_attribute('pageItemsToSubmit'  , apex_plugin_util.page_item_names_to_jquery(p_Region.ajax_items_to_submit))||
          apex_javascript.add_attribute('ajaxOnExpand', ajaxOnExpand)||
          apex_javascript.add_attribute('clickable', config(p_region).clickable)||
          apex_javascript.add_attribute('selectable', config(p_region).selectable)||
          apex_javascript.add_attribute('searchItem', p_region.attribute_04)||
          apex_javascript.add_attribute('expandButton', p_region.attribute_07)||
          apex_javascript.add_attribute('collapseButton', p_region.attribute_08)||
          apex_javascript.add_attribute('clearSearchButton', p_region.attribute_09)||
          apex_javascript.add_attribute('regionID', sys.HTF.escape_sc(p_Region.static_id),FALSE,FALSE)||'});';
          
          
      apex_javascript.add_onload_code(p_code => v_onload_code);
        
        

        sys.htp.p('<style type="text/css"> ');
  /*      sys.htp.p('#'||v_containerID||' {margin:0;} ');
        sys.htp.p('#'||v_containerID||' div.node-type {float:right;font-size:0.8em;color:#999} ');
        sys.htp.p('#'||v_containerID||' div.node-icon{float:left;width:30px;font-size:2rem;color:#ccc;margin-left:-7px}');
        
        if config(p_region).clickable then 
          sys.htp.p('#'||v_containerID||' li > div {cursor:pointer}');
        end if; */
        if hasExpandCollapse then 
  --          sys.htp.p('#'||v_containerID||' span.toggler {position:absolute;padding:10px 0;cursor:pointer;font-size:2rem;line-height:1}');
    --        sys.htp.p('#'||v_containerID||'.toggler li > div {margin-left:20px} ');
            sys.htp.p('#'||v_containerID||'.toggler li > ul {display:none} ');
            sys.htp.p('#'||v_containerID||'.toggler li.expanded > ul {display:block} ');
            
            
        end if;
        sys.htp.p('</style>');
                  

        
      --  sys.htp.p('region static id: '||p_region.static_id||'<br/>');
        sys.htp.p('<div class="hijerarhija" id ="'||p_region.static_id||'">');
        if hasExpandCollapse then 
            sys.htp.p('<ul id="'|| v_containerID||'" class="toggler" style="margin:0 0 0 5px">');
        else 
            sys.htp.p('<ul id="'|| v_containerID||'" style="margin:0 0 0 5px">');
        end if;
        
        print_report(p_region, p_plugin);
          

      sys.htp.prn('</ul>');
      sys.htp.prn('</div>');

      return null;
    end;

    
    function ajax_report (
      p_region in apex_plugin.t_region,
      p_plugin in apex_plugin.t_plugin )
      return apex_plugin.t_region_ajax_result
    is
      v_searchItem varchar2(100) := p_region.attribute_04;
      t timestamp := systimestamp;
    begin
      /*  loop 
            exit when extract(second from systimestamp - t)>15;
         end loop;
                       
      */
      print_report(p_region, p_plugin, apex_application.g_x01);
      return null;
    end;

  end apextree;
