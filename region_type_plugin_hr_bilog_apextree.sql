set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_release=>'5.1.0.00.45'
,p_default_workspace_id=>6109153816785650820
,p_default_application_id=>112993
,p_default_owner=>'EMJAY'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/region_type/hr_bilog_apextree
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(6269475665535097993)
,p_plugin_type=>'REGION TYPE'
,p_name=>'HR.BILOG.APEXTREE'
,p_display_name=>'apextree'
,p_supported_ui_types=>'DESKTOP'
,p_javascript_file_urls=>'#APP_IMAGES#apextree.js'
,p_css_file_urls=>'#APP_IMAGES#apextree.css'
,p_api_version=>1
,p_render_function=>'apextree.render_report'
,p_ajax_function=>'apextree.ajax_report'
,p_standard_attributes=>'SOURCE_SQL:AJAX_ITEMS_TO_SUBMIT:NO_DATA_FOUND_MESSAGE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Upit mora sadrzavati slijedece kolone:',
'',
'ID NUMBER -- required (podredjeni_id)/n',
'MASTER_ID NUMBER-- required (nadredjeni_id)',
'NAME VARCHAR2-- required (naziv node)',
'DESCRIPTION VARCHAR2 (prvi redak opisa node)',
'DESCRIPTION_2 VARCHAR2 (drugi redak opisa node)',
'NODE_TYPE VARCHAR2 (desno u kutu opis node)',
'CLASS_NAME VARCHAR2 (css klasa koja se nadodje na nodu)',
'ICON VARCHAR2 (font awesome icon koji se dodaje u nodu)',
'ORD varchar2 (order po toj koloni ide)'))
,p_version_identifier=>'1.0'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6269587347540471536)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Expand/collapse:'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Da li se koristi expand/collapse:',
'Ako je ''Yes'' tada se mogu expand/collapse node',
'Ako je ''No'' tada je cijelo stablo prikazano po defaultu bez mogucnosti expand/collapse'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6269588297893478919)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Level:'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(6269587347540471536)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'do kojeg levela je inicijalno expandirano'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6269590554418512222)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Ajax on expand:'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(6269587347540471536)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Da li radi ajax request prilikom expanda? ',
'Yes - Da (prilikom collapse node se brise html dom child, a prilikom expand node se radi ajax request na bazu za dovhatom childova)',
'No - Cijelo stablo je učitano po defaultu'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6269637885632118047)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Search item:'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Item za pretrazivanje'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6269859770897667208)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Clickable:'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Da li ce okinuti event ako se klikne na node?',
'Yes - fire event ''Node clicked''',
'No - nema eventa',
'',
'event propagira javascript object {id: [id elementa na koji je kliknuto], element: [dom element na koji je kliknuto]}'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6270215544220858247)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Selectable:'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(6269859770897667208)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Da li ce okinuti event ako se klikne na node?',
'Yes ',
'  - fire event ''Node selected'' (ako noda nije selektirana)',
'  - fire event ''Node unselected'' (ako je noda selektirana)',
'  ',
'No - nema eventa',
'',
'event propagira javascript object {id: [id elementa na koji je kliknuto], element: [dom element na koji je kliknuto]}'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6270235410297102945)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>22
,p_prompt=>'Expand button:'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(6269587347540471536)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'potrebno upisati ''Static ID'' od buttona'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6270240205784170687)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>24
,p_prompt=>'Collapse button:'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(6269587347540471536)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'potrebno upisati ''Static ID'' od buttona'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6270242363850178036)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>45
,p_prompt=>'Clear search button:'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(6269637885632118047)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_NULL'
,p_help_text=>'potrebno upisati ''Static ID'' od buttona'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(6195449907660362699)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_name=>'SOURCE_SQL'
,p_sql_min_column_count=>1
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Upit mora sadrzavati slijedece kolone:',
'',
'ID NUMBER -- required (podredjeni_id)',
'MASTER_ID NUMBER-- required (nadredjeni_id)',
'NAME VARCHAR2-- required (naziv node)',
'DESCRIPTION VARCHAR2 (prvi redak opisa node)',
'DESCRIPTION_2 VARCHAR2 (drugi redak opisa node)',
'NODE_TYPE VARCHAR2 (desno u kutu opis node)',
'CLASS_NAME VARCHAR2 (css klasa koja se nadodje na nodu)',
'ICON VARCHAR2 (font awesome icon koji se dodaje u nodu)',
'ORD WHATEVER (order po toj koloni ide)',
'',
'npr.:',
'select id, nadredjeni_id as master_id, naziv as name from neka_tablica'))
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(6269886789026031663)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_name=>'nodeclick'
,p_display_name=>'Node clicked'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(6270260455276881822)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_name=>'nodelink'
,p_display_name=>'Node link clicked'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(6269866075995742467)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_name=>'nodeselect'
,p_display_name=>'Node selected'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(6269869943250797259)
,p_plugin_id=>wwv_flow_api.id(6269475665535097993)
,p_name=>'nodeunselect'
,p_display_name=>'Node unselected'
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
