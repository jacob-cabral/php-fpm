{{/*
Expand the name of the chart.
*/}}
{{- define "php-fpm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "php-fpm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "php-fpm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "php-fpm.labels" -}}
helm.sh/chart: {{ include "php-fpm.chart" . }}
{{ include "php-fpm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "php-fpm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "php-fpm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "php-fpm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "php-fpm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define the PHP pool configurations.
*/}}

{{/*
Per pool prefix
It only applies on the following directives:
- 'access.log'
- 'slowlog'
- 'listen' (unixsocket)
- 'chroot'
- 'chdir'
- 'php_values'
- 'php_admin_values'
When not set, the global prefix (or NONE) applies instead.
Note: This directive can also be relative to the global prefix.
Default Value: none
*/}}
{{- define "php-fpm.pool.prefix" -}}
{{- if .Values.pool.prefix }}
{{- printf "prefix = %s" .Values.pool.prefix }}
{{- end }}
{{- end }}

{{/*
; Set listen(2) backlog.
; Default Value: 511 (-1 on Linux, FreeBSD and OpenBSD)
*/}}
{{- define "php-fpm.pool.listen.backlog" -}}
{{- if and .Values.pool.listen .Values.pool.listen.backlog }}
{{- printf "listen.backlog = %d" .Values.pool.listen.backlog }}
{{- end }}
{{- end }}

{{/*
Set permissions for unix socket, if one is used. In Linux, read/write
permissions must be set in order to allow connections from a web server. Many
BSD-derived systems allow connections regardless of permissions. The owner
and group can be specified either by name or by their numeric IDs.
Default Values: Owner is set to the master process running user. If the group
                is not set, the owner's group is used. Mode is set to 0660.
*/}}
{{- define "php-fpm.pool.listen.owner" -}}
{{- if and .Values.pool.listen .Values.pool.listen.owner -}}
{{- printf "listen.owner = %s" .Values.pool.listen.owner }}
{{- end }}
{{- end }}

{{- define "php-fpm.pool.listen.group" -}}
{{- if and .Values.pool.listen .Values.pool.listen.group -}}
{{- printf "listen.group = %s" .Values.pool.listen.group }}
{{- end }}
{{- end }}

{{- define "php-fpm.pool.listen.mode" -}}
{{- if and .Values.pool.listen .Values.pool.listen.mode -}}
{{- printf "listen.mode = %s" .Values.pool.listen.mode }}
{{- end }}
{{- end }}

{{/*
When POSIX Access Control Lists are supported you can set them using
these options, value is a comma separated list of user/group names.
When set, listen.owner and listen.group are ignored.
*/}}
{{- define "php-fpm.pool.listen.acl_users" -}}
{{- if and .Values.pool.listen .Values.pool.listen.acl_users -}}
{{- printf "listen.acl_users = %s" .Values.pool.listen.acl_users }}
{{- end }}
{{- end }}

{{- define "php-fpm.pool.listen.acl_groups" -}}
{{- if and .Values.pool.listen .Values.pool.listen.acl_groups -}}
{{- printf "listen.acl_groups = %s" .Values.pool.listen.acl_groups }}
{{- end }}
{{- end }}

{{/*
List of addresses (IPv4/IPv6) of FastCGI clients which are allowed to connect.
Equivalent to the FCGI_WEB_SERVER_ADDRS environment variable in the original
PHP FCGI (5.2.2+). Makes sense only with a tcp listening socket. Each address
must be separated by a comma. If this value is left blank, connections will be
accepted from any ip address.
Default Value: any
*/}}
{{- define "php-fpm.pool.listen.allowed_clients" -}}
{{- if and .Values.pool.listen .Values.pool.listen.allowed_clients -}}
{{- printf "listen.allowed_clients = %s" .Values.pool.listen.allowed_clients }}
{{- end }}
{{- end }}

{{/*
Specify the nice(2) priority to apply to the pool processes (only if set)
The value can vary from -19 (highest priority) to 20 (lower priority)
Note: - It will only work if the FPM master process is launched as root
      - The pool processes will inherit the master process priority
        unless it specified otherwise
Default Value: no set
*/}}
{{- define "php-fpm.pool.process.priority" -}}
{{- if and .Values.pool.process .Values.pool.process.priority -}}
{{- printf "process.priority = %d" .Values.pool.process.priority }}
{{- end }}
{{- end }}

{{/*
Set the process dumpable flag (PR_SET_DUMPABLE prctl) even if the process user
or group is differrent than the master process user. It allows to create process
core dump and ptrace the process for the pool user.
Default Value: no
*/}}
{{- define "php-fpm.pool.process.dumpable" -}}
{{- if and .Values.pool.process .Values.pool.process.dumpable -}}
{{- printf "process.dumpable = %s" .Values.pool.process.dumpable }}
{{- end }}
{{- end }}

{{/*
The number of rate to spawn child processes at once.
Note: Used only when pm is set to 'dynamic'
Note: Mandatory when pm is set to 'dynamic'
Default Value: 32
*/}}
{{- define "php-fpm.pool.pm.max_spawn_rate" -}}
{{- if .Values.pool.pm.max_spawn_rate -}}
{{- printf "pm.max_spawn_rate = %d;" .Values.pool.pm.max_spawn_rate }}
{{- end }}
{{- end }}

{{/*
The number of seconds after which an idle process will be killed.
Note: Used only when pm is set to 'ondemand'
Default Value: 10s
*/}}
{{- define "php-fpm.pool.pm.process_idle_timeout" -}}
{{- if .Values.pool.pm.process_idle_timeout -}}
{{- printf "pm.process_idle_timeout = %s;" .Values.pool.pm.process_idle_timeout }}
{{- end }}
{{- end }}

{{/*
The number of requests each child process should execute before respawning.
This can be useful to work around memory leaks in 3rd party libraries. For
endless request processing specify '0'. Equivalent to PHP_FCGI_MAX_REQUESTS.
Default Value: 0
*/}}
{{- define "php-fpm.pool.pm.max_requests" -}}
{{- if .Values.pool.pm.max_requests -}}
{{- printf "pm.max_requests = %d;" .Values.pool.pm.max_requests }}
{{- end }}
{{- end }}

{{/*
The URI to view the FPM status page. If this value is not set, no URI will be
recognized as a status page. It shows the following informations:
  pool                 - the name of the pool;
  process manager      - static, dynamic or ondemand;
  start time           - the date and time FPM has started;
  start since          - number of seconds since FPM has started;
  accepted conn        - the number of request accepted by the pool;
  listen queue         - the number of request in the queue of pending
                         connections (see backlog in listen(2));
  max listen queue     - the maximum number of requests in the queue
                         of pending connections since FPM has started;
  listen queue len     - the size of the socket queue of pending connections;
  idle processes       - the number of idle processes;
  active processes     - the number of active processes;
  total processes      - the number of idle + active processes;
  max active processes - the maximum number of active processes since FPM
                         has started;
  max children reached - number of times, the process limit has been reached,
                         when pm tries to start more children (works only for
                         pm 'dynamic' and 'ondemand');
Value are updated in real time.
Example output:
  pool:                 www
  process manager:      static
  start time:           01/Jul/2011:17:53:49 +0200
  start since:          62636
  accepted conn:        190460
  listen queue:         0
  max listen queue:     1
  listen queue len:     42
  idle processes:       4
  active processes:     11
  total processes:      15
  max active processes: 12
  max children reached: 0

By default the status page output is formatted as text/plain. Passing either
'html', 'xml' or 'json' in the query string will return the corresponding
output syntax. Example:
  http://www.foo.bar/status
  http://www.foo.bar/status?json
  http://www.foo.bar/status?html
  http://www.foo.bar/status?xml

By default the status page only outputs short status. Passing 'full' in the
query string will also return status for each pool process.
Example:
  http://www.foo.bar/status?full
  http://www.foo.bar/status?json&full
  http://www.foo.bar/status?html&full
  http://www.foo.bar/status?xml&full
The Full status returns for each process:
  pid                  - the PID of the process;
  state                - the state of the process (Idle, Running, ...);
  start time           - the date and time the process has started;
  start since          - the number of seconds since the process has started;
  requests             - the number of requests the process has served;
  request duration     - the duration in µs of the requests;
  request method       - the request method (GET, POST, ...);
  request URI          - the request URI with the query string;
  content length       - the content length of the request (only with POST);
  user                 - the user (PHP_AUTH_USER) (or '-' if not set);
  script               - the main script called (or '-' if not set);
  last request cpu     - the %cpu the last request consumed
                         it's always 0 if the process is not in Idle state
                         because CPU calculation is done when the request
                         processing has terminated;
  last request memory  - the max amount of memory the last request consumed
                         it's always 0 if the process is not in Idle state
                         because memory calculation is done when the request
                         processing has terminated;
If the process is in Idle state, then informations are related to the
last request the process has served. Otherwise informations are related to
the current request being served.
Example output:
  ************************
  pid:                  31330
  state:                Running
  start time:           01/Jul/2011:17:53:49 +0200
  start since:          63087
  requests:             12808
  request duration:     1250261
  request method:       GET
  request URI:          /test_mem.php?N=10000
  content length:       0
  user:                 -
  script:               /home/fat/web/docs/php/test_mem.php
  last request cpu:     0.00
  last request memory:  0

Note: There is a real-time FPM status monitoring sample web page available
      It's available in: /usr/local/share/php/fpm/status.html

Note: The value must start with a leading slash (/). The value can be
      anything, but it may not be a good idea to use the .php extension or it
      may conflict with a real PHP file.
Default Value: not set
*/}}
{{- define "php-fpm.pool.pm.status_path" -}}
{{- if .Values.pool.pm.status_path -}}
{{- printf "pm.status_path = %s" .Values.pool.pm.status_path }}
{{- end }}
{{- end }}

{{/*
The address on which to accept FastCGI status request. This creates a new
invisible pool that can handle requests independently. This is useful
if the main pool is busy with long running requests because it is still possible
to get the status before finishing the long running requests.

Valid syntaxes are:
  'ip.add.re.ss:port'    - to listen on a TCP socket to a specific IPv4 address on
                           a specific port;
  '[ip:6:addr:ess]:port' - to listen on a TCP socket to a specific IPv6 address on
                           a specific port;
  'port'                 - to listen on a TCP socket to all addresses
                           (IPv6 and IPv4-mapped) on a specific port;
  '/path/to/unix/socket' - to listen on a unix socket.
Default Value: value of the listen option
*/}}
{{- define "php-fpm.pool.pm.status_listen" -}}
{{- if .Values.pool.pm.status_listen -}}
{{- printf "pm.status_listen = %s" .Values.pool.pm.status_listen }}
{{- end }}
{{- end }}

{{/*
The ping URI to call the monitoring page of FPM. If this value is not set, no
URI will be recognized as a ping page. This could be used to test from outside
that FPM is alive and responding, or to
- create a graph of FPM availability (rrd or such);
- remove a server from a group if it is not responding (load balancing);
- trigger alerts for the operating team (24/7).
Note: The value must start with a leading slash (/). The value can be
      anything, but it may not be a good idea to use the .php extension or it
      may conflict with a real PHP file.
Default Value: not set
*/}}
{{- define "php-fpm.pool.ping.path" -}}
{{- if and .Values.pool.ping .Values.pool.ping.path -}}
{{- printf "ping.path = %s" .Values.pool.ping.path }}
{{- end }}
{{- end }}

{{/*
This directive may be used to customize the response of a ping request. The
response is formatted as text/plain with a 200 response code.
Default Value: pong
*/}}
{{- define "php-fpm.pool.ping.response" -}}
{{- if and .Values.pool.ping .Values.pool.ping.response -}}
{{- printf "ping.response = %s" .Values.pool.ping.response }}
{{- end }}
{{- end }}

{{/*
The log file for slow requests
Default Value: not set
Note: slowlog is mandatory if request_slowlog_timeout is set
*/}}
{{- define "php-fpm.pool.slowlog" -}}
{{- if .Values.pool.slowlog -}}
{{- printf "slowlog = %s" .Values.pool.slowlog }}
{{- end }}
{{- end }}

{{/*
The timeout for serving a single request after which a PHP backtrace will be
dumped to the 'slowlog' file. A value of '0s' means 'off'.
Available units: s(econds)(default), m(inutes), h(ours), or d(ays)
Default Value: 0
*/}}
{{- define "php-fpm.pool.request_slowlog_timeout" -}}
{{- if .Values.pool.request_slowlog_timeout -}}
{{- printf "request_slowlog_timeout = %d" .Values.pool.request_slowlog_timeout }}
{{- end }}
{{- end }}

{{/*
Depth of slow log stack trace.
Default Value: 20
*/}}
{{- define "php-fpm.pool.request_slowlog_trace_depth" -}}
{{- if .Values.pool.slowlog -}}
{{- default 20 .Values.pool.request_slowlog_trace_depth | printf "request_slowlog_trace_depth = %d" }}
{{- end }}
{{- end }}

{{/*
The timeout for serving a single request after which the worker process will
be killed. This option should be used when the 'max_execution_time' ini option
does not stop script execution for some reason. A value of '0' means 'off'.
Available units: s(econds)(default), m(inutes), h(ours), or d(ays)
Default Value: 0
*/}}
{{- define "php-fpm.pool.request_terminate_timeout" -}}
{{- if .Values.pool.request_terminate_timeout -}}
{{- printf "request_terminate_timeout = %d" .Values.pool.request_terminate_timeout }}
{{- end }}
{{- end }}

{{/*
The timeout set by 'request_terminate_timeout' ini option is not engaged after
application calls 'fastcgi_finish_request' or when application has finished and
shutdown functions are being called (registered via register_shutdown_function).
This option will enable timeout limit to be applied unconditionally
even in such cases.
Default Value: no
*/}}
{{- define "php-fpm.pool.request_terminate_timeout_track_finished" -}}
{{- if .Values.pool.request_terminate_timeout_track_finished -}}
{{- printf "request_terminate_timeout_track_finished = %s" .Values.pool.request_terminate_timeout_track_finished }}
{{- end }}
{{- end }}

{{/*
Set open file descriptor rlimit.
Default Value: system defined value
*/}}
{{- define "php-fpm.pool.rlimit_files" -}}
{{- if .Values.pool.rlimit_files -}}
{{- printf "rlimit_files = %d" .Values.pool.rlimit_files }}
{{- end }}
{{- end }}

{{/*
Set max core size rlimit.
Possible Values: 'unlimited' or an integer greater or equal to 0
Default Value: system defined value
*/}}
{{- define "php-fpm.pool.rlimit_core" -}}
{{- if .Values.pool.rlimit_core -}}
{{- printf "rlimit_core = %d" .Values.pool.rlimit_core }}
{{- end }}
{{- end }}

{{/*
Chroot to this directory at the start. This value must be defined as an
absolute path. When this value is not set, chroot is not used.
Note: you can prefix with '$prefix' to chroot to the pool prefix or one
of its subdirectories. If the pool prefix is not set, the global prefix
will be used instead.
Note: chrooting is a great security feature and should be used whenever
      possible. However, all PHP paths will be relative to the chroot
      (error_log, sessions.save_path, ...).
Default Value: not set
*/}}
{{- define "php-fpm.pool.chroot" -}}
{{- if .Values.pool.chroot -}}
{{- printf "chroot = %s" .Values.pool.chroot }}
{{- end }}
{{- end }}

{{/*
Chdir to this directory at the start.
Note: relative path can be used.
Default Value: current directory or / when chroot
*/}}
{{- define "php-fpm.pool.chdir" -}}
{{- if .Values.pool.chdir -}}
{{- printf "chdir = %s" .Values.pool.chdir }}
{{- end }}
{{- end }}

{{/*
Limits the extensions of the main script FPM will allow to parse. This can
prevent configuration mistakes on the web server side. You should only limit
FPM to .php extensions to prevent malicious users to use other extensions to
execute php code.
Note: set an empty value to allow all extensions.
Default Value: .php
*/}}
{{- define "php-fpm.pool.security.limit_extensions" -}}
{{- if and .Values.pool.security .Values.pool.security.limit_extensions -}}
{{- printf "security.limit_extensions = %s" .Values.pool.security.limit_extensions }}
{{- end }}
{{- end }}

{{/*
Pass environment variables like LD_LIBRARY_PATH. All $VARIABLEs are taken from
the current environment.
Default Value: clean env
*/}}
{{- define "php-fpm.pool.env" -}}
{{- range $key, $val := .Values.pool.env -}}
{{- printf "env[%s] = %s\n" ($key | upper) $val }}
{{- end }}
{{- end }}

{{/*
Additional php.ini defines, specific to this pool of workers. These settings
overwrite the values previously defined in the php.ini. The directives are the
same as the PHP SAPI:
  php_value/php_flag             - you can set classic ini defines which can
                                   be overwritten from PHP call 'ini_set'.
  php_admin_value/php_admin_flag - these directives won't be overwritten by
                                    PHP call 'ini_set'
For php_*flag, valid values are on, off, 1, 0, true, false, yes or no.

Defining 'extension' will load the corresponding shared extension from
extension_dir. Defining 'disable_functions' or 'disable_classes' will not
overwrite previously defined php.ini values, but will append the new value
instead.

Note: path INI options can be relative and will be expanded with the prefix
(pool, global or /usr/local)

Default Value: nothing is defined by default except the values in php.ini and
               specified at startup with the -d argument
*/}}
{{- define "php-fpm.pool.php_value" -}}
{{- range $key, $val := .Values.pool.php_value -}}
{{- printf "php_value[%s] = %s\n" $key $val }}
{{- end }}
{{- end }}

{{- define "php-fpm.pool.php_flag" -}}
{{- range $key, $val := .Values.pool.php_flag -}}
{{- printf "php_flag[%s] = %s\n" $key $val }}
{{- end }}
{{- end }}

{{- define "php-fpm.pool.php_admin_value" -}}
{{- range $key, $val := .Values.pool.php_admin_value -}}
{{- printf "php_admin_value[%s] = %s\n" $key $val }}
{{- end }}
{{- end }}

{{- define "php-fpm.pool.php_admin_flag" -}}
{{- range $key, $val := .Values.pool.php_admin_flag -}}
{{- printf "php_admin_flag[%s] = %s\n" $key $val }}
{{- end }}
{{- end }}