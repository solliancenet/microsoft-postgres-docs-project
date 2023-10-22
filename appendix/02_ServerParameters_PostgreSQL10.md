# Appendix C: Default server parameters PostgreSQL 10.0

```text
                name                 |                       setting                       |                                    enumvals                                    
-------------------------------------+-----------------------------------------------------+--------------------------------------------------------------------------------
 allow_system_table_mods             | off                                                 | 
 application_name                    | psql                                                | 
 archive_command                     | (disabled)                                          | 
 archive_mode                        | off                                                 | {always,on,off}
 archive_timeout                     | 0                                                   | 
 array_nulls                         | on                                                  | 
 authentication_timeout              | 60                                                  | 
 autovacuum                          | on                                                  | 
 autovacuum_analyze_scale_factor     | 0.1                                                 | 
 autovacuum_analyze_threshold        | 50                                                  | 
 autovacuum_freeze_max_age           | 200000000                                           | 
 autovacuum_max_workers              | 3                                                   | 
 autovacuum_multixact_freeze_max_age | 400000000                                           | 
 autovacuum_naptime                  | 60                                                  | 
 autovacuum_vacuum_cost_delay        | 20                                                  | 
 autovacuum_vacuum_cost_limit        | -1                                                  | 
 autovacuum_vacuum_scale_factor      | 0.2                                                 | 
 autovacuum_vacuum_threshold         | 50                                                  | 
 autovacuum_work_mem                 | -1                                                  | 
 backend_flush_after                 | 0                                                   | 
 backslash_quote                     | safe_encoding                                       | {safe_encoding,on,off}
 bgwriter_delay                      | 200                                                 | 
 bgwriter_flush_after                | 0                                                   | 
 bgwriter_lru_maxpages               | 100                                                 | 
 bgwriter_lru_multiplier             | 2                                                   | 
 block_size                          | 8192                                                | 
 bonjour                             | off                                                 | 
 bonjour_name                        |                                                     | 
 bytea_output                        | hex                                                 | {escape,hex}
 check_function_bodies               | on                                                  | 
 checkpoint_completion_target        | 0.5                                                 | 
 checkpoint_flush_after              | 0                                                   | 
 checkpoint_timeout                  | 300                                                 | 
 checkpoint_warning                  | 30                                                  | 
 client_encoding                     | WIN1252                                             | 
 client_min_messages                 | notice                                              | {debug5,debug4,debug3,debug2,debug1,log,notice,warning,error}
 cluster_name                        |                                                     | 
 commit_delay                        | 0                                                   | 
 commit_siblings                     | 5                                                   | 
 config_file                         | C:/Program Files/PostgreSQL/10/data/postgresql.conf | 
 constraint_exclusion                | partition                                           | {partition,on,off}
 cpu_index_tuple_cost                | 0.005                                               | 
 cpu_operator_cost                   | 0.0025                                              | 
 cpu_tuple_cost                      | 0.01                                                | 
 cursor_tuple_fraction               | 0.1                                                 | 
 data_checksums                      | off                                                 | 
 data_directory                      | C:/Program Files/PostgreSQL/10/data                 | 
 data_sync_retry                     | off                                                 | 
 DateStyle                           | ISO, MDY                                            | 
 db_user_namespace                   | off                                                 | 
 deadlock_timeout                    | 1000                                                | 
 debug_assertions                    | off                                                 | 
 debug_pretty_print                  | on                                                  | 
 debug_print_parse                   | off                                                 | 
 debug_print_plan                    | off                                                 | 
 debug_print_rewritten               | off                                                 | 
 default_statistics_target           | 100                                                 | 
 default_tablespace                  |                                                     | 
 default_text_search_config          | pg_catalog.english                                  | 
 default_transaction_deferrable      | off                                                 | 
 default_transaction_isolation       | read committed                                      | {serializable,"repeatable read","read committed","read uncommitted"}
 default_transaction_read_only       | off                                                 | 
 default_with_oids                   | off                                                 | 
 dynamic_library_path                | $libdir                                             | 
 dynamic_shared_memory_type          | windows                                             | {windows,none}
 effective_cache_size                | 524288                                              | 
 effective_io_concurrency            | 0                                                   | 
 enable_bitmapscan                   | on                                                  | 
 enable_gathermerge                  | on                                                  | 
 enable_hashagg                      | on                                                  | 
 enable_hashjoin                     | on                                                  | 
 enable_indexonlyscan                | on                                                  | 
 enable_indexscan                    | on                                                  | 
 enable_material                     | on                                                  | 
 enable_mergejoin                    | on                                                  | 
 enable_nestloop                     | on                                                  | 
 enable_seqscan                      | on                                                  | 
 enable_sort                         | on                                                  | 
 enable_tidscan                      | on                                                  | 
 escape_string_warning               | on                                                  | 
 event_source                        | PostgreSQL                                          | 
 exit_on_error                       | off                                                 | 
 external_pid_file                   |                                                     | 
 extra_float_digits                  | 0                                                   | 
 force_parallel_mode                 | off                                                 | {off,on,regress}
 from_collapse_limit                 | 8                                                   | 
 fsync                               | on                                                  | 
 full_page_writes                    | on                                                  | 
 geqo                                | on                                                  | 
 geqo_effort                         | 5                                                   | 
 geqo_generations                    | 0                                                   | 
 geqo_pool_size                      | 0                                                   | 
 geqo_seed                           | 0                                                   | 
 geqo_selection_bias                 | 2                                                   | 
 geqo_threshold                      | 12                                                  | 
 gin_fuzzy_search_limit              | 0                                                   | 
 gin_pending_list_limit              | 4096                                                | 
 hba_file                            | C:/Program Files/PostgreSQL/10/data/pg_hba.conf     | 
 hot_standby                         | on                                                  | 
 hot_standby_feedback                | off                                                 | 
 huge_pages                          | try                                                 | {off,on,try}
 ident_file                          | C:/Program Files/PostgreSQL/10/data/pg_ident.conf   | 
 idle_in_transaction_session_timeout | 0                                                   | 
 ignore_checksum_failure             | off                                                 | 
 ignore_system_indexes               | off                                                 | 
 integer_datetimes                   | on                                                  | 
 IntervalStyle                       | postgres                                            | {postgres,postgres_verbose,sql_standard,iso_8601}
 join_collapse_limit                 | 8                                                   | 
 krb_caseins_users                   | off                                                 | 
 krb_server_keyfile                  |                                                     | 
 lc_collate                          | English_United States.1252                          | 
 lc_ctype                            | English_United States.1252                          | 
 lc_messages                         | English_United States.1252                          | 
 lc_monetary                         | English_United States.1252                          | 
 lc_numeric                          | English_United States.1252                          | 
 lc_time                             | English_United States.1252                          | 
 listen_addresses                    | *                                                   | 
 lo_compat_privileges                | off                                                 | 
 local_preload_libraries             |                                                     | 
 lock_timeout                        | 0                                                   | 
 log_autovacuum_min_duration         | -1                                                  | 
 log_checkpoints                     | off                                                 | 
 log_connections                     | off                                                 | 
 log_destination                     | stderr                                              | 
 log_directory                       | log                                                 | 
 log_disconnections                  | off                                                 | 
 log_duration                        | off                                                 | 
 log_error_verbosity                 | default                                             | {terse,default,verbose}
 log_executor_stats                  | off                                                 | 
 log_file_mode                       | 0600                                                | 
 log_filename                        | postgresql-%Y-%m-%d_%H%M%S.log                      | 
 log_hostname                        | off                                                 | 
 log_line_prefix                     | %m [%p]                                             | 
 log_lock_waits                      | off                                                 | 
 log_min_duration_statement          | -1                                                  | 
 log_min_error_statement             | error                                               | {debug5,debug4,debug3,debug2,debug1,info,notice,warning,error,log,fatal,panic}
 log_min_messages                    | warning                                             | {debug5,debug4,debug3,debug2,debug1,info,notice,warning,error,log,fatal,panic}
 log_parser_stats                    | off                                                 | 
 log_planner_stats                   | off                                                 | 
 log_replication_commands            | off                                                 | 
 log_rotation_age                    | 1440                                                | 
 log_rotation_size                   | 10240                                               | 
 log_statement                       | none                                                | {none,ddl,mod,all}
 log_statement_stats                 | off                                                 | 
 log_temp_files                      | -1                                                  | 
 log_timezone                        | UTC                                                 | 
 log_truncate_on_rotation            | off                                                 | 
 logging_collector                   | on                                                  | 
 maintenance_work_mem                | 65536                                               | 
 max_connections                     | 100                                                 | 
 max_files_per_process               | 1000                                                | 
 max_function_args                   | 100                                                 | 
 max_identifier_length               | 63                                                  | 
 max_index_keys                      | 32                                                  | 
 max_locks_per_transaction           | 64                                                  | 
 max_logical_replication_workers     | 4                                                   | 
 max_parallel_workers                | 8                                                   | 
 max_parallel_workers_per_gather     | 2                                                   | 
 max_pred_locks_per_page             | 2                                                   | 
 max_pred_locks_per_relation         | -2                                                  | 
 max_pred_locks_per_transaction      | 64                                                  | 
 max_prepared_transactions           | 0                                                   | 
 max_replication_slots               | 10                                                  | 
 max_stack_depth                     | 2048                                                | 
 max_standby_archive_delay           | 30000                                               | 
 max_standby_streaming_delay         | 30000                                               | 
 max_sync_workers_per_subscription   | 2                                                   | 
 max_wal_senders                     | 10                                                  | 
 max_wal_size                        | 1024                                                | 
 max_worker_processes                | 8                                                   | 
 min_parallel_index_scan_size        | 64                                                  | 
 min_parallel_table_scan_size        | 1024                                                | 
 min_wal_size                        | 80                                                  | 
 old_snapshot_threshold              | -1                                                  | 
 operator_precedence_warning         | off                                                 | 
 parallel_setup_cost                 | 1000                                                | 
 parallel_tuple_cost                 | 0.1                                                 | 
 password_encryption                 | md5                                                 | {md5,scram-sha-256}
 port                                | 5432                                                | 
 post_auth_delay                     | 0                                                   | 
 pre_auth_delay                      | 0                                                   | 
 quote_all_identifiers               | off                                                 | 
 random_page_cost                    | 4                                                   | 
 replacement_sort_tuples             | 150000                                              | 
 restart_after_crash                 | on                                                  | 
 row_security                        | on                                                  | 
 search_path                         | "$user", public                                     | 
 segment_size                        | 131072                                              | 
 seq_page_cost                       | 1                                                   | 
 server_encoding                     | UTF8                                                | 
 server_version                      | 10.16                                               | 
 server_version_num                  | 100016                                              | 
 session_preload_libraries           |                                                     | 
 session_replication_role            | origin                                              | {origin,replica,local}
 shared_buffers                      | 16384                                               | 
 shared_preload_libraries            |                                                     | 
 ssl                                 | off                                                 | 
 ssl_ca_file                         |                                                     | 
 ssl_cert_file                       | server.crt                                          | 
 ssl_ciphers                         | HIGH:MEDIUM:+3DES:!aNULL                            | 
 ssl_crl_file                        |                                                     | 
 ssl_dh_params_file                  |                                                     | 
 ssl_ecdh_curve                      | prime256v1                                          | 
 ssl_key_file                        | server.key                                          | 
 ssl_prefer_server_ciphers           | on                                                  | 
 standard_conforming_strings         | on                                                  | 
 statement_timeout                   | 0                                                   | 
 stats_temp_directory                | pg_stat_tmp                                         | 
 superuser_reserved_connections      | 3                                                   | 
 synchronize_seqscans                | on                                                  | 
 synchronous_commit                  | on                                                  | {local,remote_write,remote_apply,on,off}
 synchronous_standby_names           |                                                     | 
 syslog_facility                     | none                                                | {none}
 syslog_ident                        | postgres                                            | 
 syslog_sequence_numbers             | on                                                  | 
 syslog_split_messages               | on                                                  | 
 tcp_keepalives_count                | 0                                                   | 
 tcp_keepalives_idle                 | -1                                                  | 
 tcp_keepalives_interval             | -1                                                  | 
 temp_buffers                        | 1024                                                | 
 temp_file_limit                     | -1                                                  | 
 temp_tablespaces                    |                                                     | 
 TimeZone                            | UTC                                                 | 
 timezone_abbreviations              | Default                                             | 
 trace_notify                        | off                                                 | 
 trace_recovery_messages             | log                                                 | {debug5,debug4,debug3,debug2,debug1,log,notice,warning,error}
 trace_sort                          | off                                                 | 
 track_activities                    | on                                                  | 
 track_activity_query_size           | 1024                                                | 
 track_commit_timestamp              | off                                                 | 
 track_counts                        | on                                                  | 
 track_functions                     | none                                                | {none,pl,all}
 track_io_timing                     | off                                                 | 
 transaction_deferrable              | off                                                 | 
 transaction_isolation               | read committed                                      | 
 transaction_read_only               | off                                                 | 
 transform_null_equals               | off                                                 | 
 unix_socket_directories             |                                                     | 
 unix_socket_group                   |                                                     | 
 unix_socket_permissions             | 0777                                                | 
 update_process_title                | off                                                 | 
 vacuum_cost_delay                   | 0                                                   | 
 vacuum_cost_limit                   | 200                                                 | 
 vacuum_cost_page_dirty              | 20                                                  | 
 vacuum_cost_page_hit                | 1                                                   | 
 vacuum_cost_page_miss               | 10                                                  | 
 vacuum_defer_cleanup_age            | 0                                                   | 
 vacuum_freeze_min_age               | 50000000                                            | 
 vacuum_freeze_table_age             | 150000000                                           | 
 vacuum_multixact_freeze_min_age     | 5000000                                             | 
 vacuum_multixact_freeze_table_age   | 150000000                                           | 
 wal_block_size                      | 8192                                                | 
 wal_buffers                         | 512                                                 | 
 wal_compression                     | off                                                 | 
 wal_consistency_checking            |                                                     | 
 wal_keep_segments                   | 0                                                   | 
 wal_level                           | replica                                             | {minimal,replica,logical}
 wal_log_hints                       | off                                                 | 
 wal_receiver_status_interval        | 10                                                  | 
 wal_receiver_timeout                | 60000                                               | 
 wal_retrieve_retry_interval         | 5000                                                | 
 wal_segment_size                    | 2048                                                | 
 wal_sender_timeout                  | 60000                                               | 
 wal_sync_method                     | open_datasync                                       | {fsync,fsync_writethrough,open_datasync}
 wal_writer_delay                    | 200                                                 | 
 wal_writer_flush_after              | 128                                                 | 
 work_mem                            | 4096                                                | 
 xmlbinary                           | base64                                              | {base64,hex}
 xmloption                           | content                                             | {content,document}
 zero_damaged_pages                  | off                                                 | 
```