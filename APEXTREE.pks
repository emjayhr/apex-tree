create or replace package apextree is

  -- Author  : MARIO
  -- Created : 19.02.2017 10:11:28 PM
  -- Purpose : 
  type t_hij_record is record (
      id number
      , master_id number
      , name varchar2(300)
      , description varchar2(4000)
      , description_2 varchar2(4000)
      , node_type varchar2(400)
      , class_name varchar2(300)
      , icon varchar2(100)
      , ord varchar2(500)
      , link1 varchar2(100)
      , link2 varchar2(100)
      , link3 varchar2(100)
      , error varchar2(4000)
      , searchable number(1)
      
  )
  ;
  type t_hij_cur is ref cursor return t_hij_record;
  type t_hij_table is table of t_hij_record;
  -- Public type declarations

  function get_data (
    i_region_source in varchar2
    , i_region_name in varchar2
    , i_master_id in number default null
    ) return t_hij_table pipelined;
    
function render_report (
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
    return apex_plugin.t_region_render_result;



  function ajax_report (
    p_region in apex_plugin.t_region,
    p_plugin in apex_plugin.t_plugin )
    return apex_plugin.t_region_ajax_result;
      


end apextree;
