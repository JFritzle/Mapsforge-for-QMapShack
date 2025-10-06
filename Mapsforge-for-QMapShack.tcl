# GUI to make Mapsforge maps and themes available to QMapShack
# ============================================================

# Important:
# - Only new "tasks" server type supported!
# - At least Java version 11 required!

# Notes:
# - Additional user settings file is mandatory!
#   Name of file = this script's full path
#   where file extension "tcl" is replaced by "ini"
# - At least one additional localized resource file is mandatory!
#   Name of file = this script's full path
#   where file extension "tcl" is replaced by
#   2 lowercase letters ISO 639-1 code, e.g. "en"

# Force file encoding "utf-8"
# Usually required for Tcl/Tk version < 9.0 on Windows!

if {[encoding system] != "utf-8"} {
   encoding system utf-8
   exit [source $argv0]
}

if {![info exists tk_version]} {package require Tk}
wm withdraw .

set version "2025-10-06"
set script [file normalize [info script]]
set title [file tail $script]

# Workaround running script by "Open with" on Windows
# Fatal Qt6WebEngineCore issue!
if {[pwd] == "C:/Windows/System32"} {cd [file dirname $script]}
set cwd [pwd]

# Required packages

foreach item {Thread msgcat tooltip http md5} {
  if {[catch "package require $item"]} {
    ::tk::MessageBox -title $title -icon error \
	-message "Could not load required Tcl package '$item'" \
	-detail "Please install missing $tcl_platform(os) package!"
    exit
  }
}

# Procedure aliases

interp alias {} ::send {} ::thread::send
interp alias {} ::mc {} ::msgcat::mc
interp alias {} ::messagebox {} ::tk::MessageBox
interp alias {} ::tooltip {} ::tooltip::tooltip
interp alias {} ::style {} ::ttk::style
interp alias {} ::button {} ::ttk::button
interp alias {} ::checkbutton {} ::ttk::checkbutton
interp alias {} ::combobox {} ::ttk::combobox
interp alias {} ::radiobutton {} ::ttk::radiobutton
interp alias {} ::scrollbar {} ::ttk::scrollbar
interp alias {} ::md5 {} ::md5::md5

# Define color palette

foreach {item value} {
Background #f0f0f0
ButtonHighlight #ffffff
Border #a0a0a0
ButtonText #000000
DisabledText #6d6d6d
Focus #e0e0e0
Highlight #0078d7
HighlightText #ffffff
InfoBackground #ffffe1
InfoText #000000
Trough #c8c8c8
Window #ffffff
WindowFrame #646464
WindowText #000000
} {set color$item $value}

# Global widget options

foreach {item value} {
background Background
foreground ButtonText
activeBackground Background
activeForeground ButtonText
disabledBackground Background
disabledForeground DisabledText
highlightBackground Background
highlightColor WindowFrame
readonlyBackground Background
selectBackground Highlight
selectForeground HighlightText
selectColor Window
troughColor Trough
Entry.background Window
Entry.foreground WindowText
Entry.insertBackground WindowText
Entry.highlightColor WindowFrame
Listbox.background Window
Listbox.highlightColor WindowFrame
Tooltip*Label.background InfoBackground
Tooltip*Label.foreground InfoText
} {option add *$item [set color$value]}

set dialog.wrapLength [expr [winfo screenwidth .]/2]
foreach {item value} {
Dialog.msg.wrapLength ${dialog.wrapLength}
Dialog.dtl.wrapLength ${dialog.wrapLength}
Dialog.msg.font TkDefaultFont
Dialog.dtl.font TkDefaultFont
Entry.highlightThickness 1
Label.borderWidth 1
Label.padX 0
Label.padY 0
Labelframe.borderWidth 0
Scale.highlightThickness 1
Scale.showValue 0
Scale.takeFocus 1
Tooltip*Label.padX 2
Tooltip*Label.padY 2
} {eval option add *$item $value}

# Global ttk widget options

style theme use clam

if {$tcl_version > 8.6} {
  if {$tcl_platform(os) == "Windows NT"} \
	{lassign {23 41 101 69 120} ry ul ll cy ht}
  if {$tcl_platform(os) == "Linux"} \
	{lassign { 3 21  81 49 100} ry ul ll cy ht}
  set CheckOff "
	<rect width='94' height='94' x='3' y='$ry'
	style='fill:white;stroke-width:3;stroke:black'/>
	"
  set CheckOn "
	<rect width='94' height='94' x='3' y='$ry'
	style='fill:white;stroke-width:3;stroke:black'/>
	<path d='M20 $ll L80 $ul M20 $ul L80 $ll'
	style='fill:none;stroke:black;stroke-width:14;stroke-linecap:round'/>
	"
  set RadioOff "
	<circle cx='49' cy='$cy' r='47'
	fill='white' stroke='black' stroke-width='3'/>
	"
  set RadioOn "
	<circle cx='49' cy='$cy' r='37'
	fill='black' stroke='white' stroke-width='20'/>
	<circle cx='49' cy='$cy' r='47'
	fill='none' stroke='black' stroke-width='3'/>
	"
  foreach item {CheckOff CheckOn RadioOff RadioOn} \
    {image create photo $item \
	-data "<svg width='125' height='$ht'>[set $item]</svg>"}

  foreach item {Check Radio} {
    style element create ${item}button.sindicator image \
	[list ${item}Off selected ${item}On]
    style layout T${item}button \
	[regsub indicator [style layout T${item}button] sindicator]
  }
}

if {$tcl_platform(os) == "Windows NT"}	{lassign {1 1} yb yc}
if {$tcl_platform(os) == "Linux"}	{lassign {0 2} yb yc}
foreach {item option value} {
. background $colorBackground
. bordercolor $colorBorder
. focuscolor $colorFocus
. darkcolor $colorWindowFrame
. lightcolor $colorWindow
. troughcolor $colorTrough
. selectbackground $colorHighlight
. selectforeground $colorHighlightText
TButton borderwidth 2
TButton padding "{0 -2 0 $yb}"
TCombobox arrowsize 15
TCombobox padding 0
TCheckbutton padding "{0 $yc}"
TRadiobutton padding "{0 $yc}"
} {eval style configure $item -$option [eval set . \"$value\"]}

foreach {item option value} {
TButton darkcolor {pressed $colorWindow}
TButton lightcolor {pressed $colorWindowFrame}
TButton background {focus $colorFocus pressed $colorFocus}
TCombobox background {focus $colorFocus pressed $colorFocus}
TCombobox bordercolor {focus $colorWindowFrame}
TCombobox selectbackground {!focus $colorWindow}
TCombobox selectforeground {!focus $colorWindowText}
TCheckbutton background {focus $colorFocus}
TRadiobutton background {focus $colorFocus}
Arrow.TButton bordercolor {focus $colorWindowFrame}
} {style map $item -$option [eval list {*}$value]}

# Global widget bindings

foreach item {TButton TCheckbutton TRadiobutton} \
	{bind $item <Return> {%W invoke}}
bind TCombobox <Return> {event generate %W <Button-1>}

bind Entry <FocusIn> {grab %W}
bind Entry <Tab> {grab release %W}
foreach item {Button-1 Control-Button-1 Shift-Button-1} \
	{bind Entry <$item> "+entry-button-1 $item %W %X %Y"}

proc scale_updown {w d} {$w set [expr [$w get]+$d*[$w cget -resolution]]}
bind Scale <MouseWheel> {scale_updown %W [expr %D>0?+1:-1]}
bind Scale <Button-4> {scale_updown %W -1}
bind Scale <Button-5> {scale_updown %W +1}
bind Scale <Button-1> {+focus %W}

proc entry-button-1 {E W X Y} {
  set w [winfo containing $X $Y]
  if {"$w" == "$W"} {focus $W; return}
  grab release $W
  if {"$w" == ""} return
  focus -force $w
  update
  event generate $w <$E> \
	-x [expr $X-[winfo rootx $w]] -y [expr $Y-[winfo rooty $w]]
}

# Bitmap arrow down

image create bitmap ArrowDown -data {
  #define x_width 9
  #define x_height 7
  static char x_bits[] = {
  0x00,0xfe,0x00,0xfe,0xff,0xff,0xfe,0xfe,0x7c,0xfe,0x38,0xfe,0x10,0xfe
  };
}

# Try using system locale for script
# If corresponding localized file does not exist, try locale "en" (English)
# Localized filename = script's filename where file extension "tcl"
# is replaced by 2 lowercase letters ISO 639-1 code

set locale [regsub {(.*)[-_]+(.*)} [::msgcat::mclocale] {\1}]
if {$locale == "c"} {set locale en}

set prefix [file rootname $script]

set list [list $locale en]
foreach item [glob -nocomplain -tails -path $prefix. -type f ??] \
	{lappend list [lindex [split $item .] end]}

unset locale
foreach item $list {
  set file $prefix.$item
  if {![file exists $file]} continue
  if {[catch {source $file} result]} {
    messagebox -title $title -icon error \
	-message "Error reading locale file '[file tail $file]':\n$result"
    exit
  }
  set locale $item
  ::msgcat::mclocale $locale
  break
}
if {![info exists locale]} {
  messagebox -title $title -icon error \
	-message "No locale file '[file tail $file]' found"
  exit
}

# Read user settings from file
# Filename = script's filename where file extension "tcl" is replaced by "ini"

set file [file rootname $script].ini
if {![file exist $file]} {
  messagebox -title $title -icon error \
	-message "[mc i01 [file tail $file]]"
  exit
} elseif {[catch {source $file} result]} {
  messagebox -title $title -icon error \
	-message "[mc i00 [file tail $file]]:\n$result"
  exit
}

# Process user settings:
# replace commands resolved by current search path
# replace relative paths by absolute paths

# - commands
set cmds {java_cmd qms_cmd}
# - commands + folders + files
set list [concat $cmds ini_folder maps_folder themes_folder server_jar]

set drive [regsub {((^.:)|(^//[^/]*)||(?:))(?:.*$)} $cwd {\1}]
if {$tcl_platform(os) == "Windows NT"}	{cd $env(SystemDrive)/}
if {$tcl_platform(os) == "Linux"}	{cd /}

foreach item $list {
  if {![info exists $item]} continue
  set value [set $item]
  if {$value == ""} continue
  if {$tcl_version >= 9.0} {set value [file tildeexpand $value]}
  if {$item in $cmds} {
    set exec [auto_execok $value]
    if {$exec == ""} {
      messagebox -title $title -icon error -message [mc e04 $value $item]
      exit
    }
    set value [lindex $exec 0]
  }
  switch [file pathtype $value] {
    absolute		{set $item [file normalize $value]}
    relative		{set $item [file normalize $cwd/$value]}
    volumerelative	{set $item [file normalize $drive/$value]}
  }
}

cd $cwd

# Check if QMapShack already running
# and check operating system

if {$tcl_platform(os) == "Windows NT"} {
  set exe [file tail $qms_cmd]
  catch {exec TASKLIST /NH /FO CSV /FI "IMAGENAME eq $exe" \
	/FI "USERNAME eq $tcl_platform(user)"} result
  set result [split $result ,]
  if {[llength $result] == 5} {
    eval set pid [lindex $result 1]
    set rc [messagebox -title $title -type yesno -default no -icon question \
	-message [mc e01 QMapShack $exe $pid] -detail [mc e02]]
    if {$rc == "no"} exit
    catch {exec TASKKILL /F /PID $pid /T}
  }
  if {$language == ""} {
    package require registry
    set language [registry get \
	{HKEY_CURRENT_USER\Control Panel\International} {LocaleName}]
    set language [regsub {(.*)-(.*)} $language {\1}]
  }
  if {![info exists env(TMP)]} {set env(TMP) $env(HOME)]}
  set tmpdir [file normalize $env(TMP)]
  set nprocs $env(NUMBER_OF_PROCESSORS)
} elseif {$tcl_platform(os) == "Linux"} {
  set exe [file tail $qms_cmd]
  set rc [catch {exec pgrep -n -u $tcl_platform(user) $exe} result]
  if {$rc == 0} {
    set pid $result
    set rc [messagebox -title $title -type yesno -default no -icon question \
	-message [mc e01 QMapShack $exe $pid] -detail [mc e02]]
    if {$rc == "no"} exit
    catch {exec kill -SIGTERM $pid}
  }
  if {$language == ""} {
    set language [regsub {(.*)_(.*)} $env(LANG) {\1}]
    if {$env(LANG) == "C"} {set language en}
  }
  if {![info exists env(TMPDIR)]} {set env(TMPDIR) /tmp}
  set tmpdir $env(TMPDIR)
  set nprocs [exec /usr/bin/nproc]
} else {
  error_message [mc e03 $tcl_platform(os)] exit
}

# Trying to force Qt application QMapShack to use XCB instead of Wayland
# to be able to handle X11 events, in particular WM_DELETE_WINDOW

if {[tk windowingsystem] == "x11"} {set env(QT_QPA_PLATFORM) "xcb;wayland"}

# Restore saved settings from folder ini_folder

if {![info exists ini_folder]} {set ini_folder $env(HOME)/.Mapsforge}
file mkdir $ini_folder

set maps.selection {}
set maps.world 0
set maps.contrast 0
set maps.gamma 1.00
set user.scale 1.00
set text.scale 1.00
set symbol.scale 1.00
set line.scale 1.00
set font.size [font configure TkDefaultFont -size]
set console.show 0
set console.geometry ""
set console.font.size 8

set dem.folder ""
set shading.onoff 0
set shading.layer onmap
set shading.magnitude 1.
set shading.algorithm simple
set shading.simple.linearity 0.1
set shading.simple.scale 0.666
set shading.diffuselight.angle 50.
set shading.asy.values [list 0.5 0 80 [expr max(1,$nprocs/3)] $nprocs true]
array set shading.asy.array {}
set shading.zoom.min.apply false
set shading.zoom.min.value 9
set shading.zoom.max.apply false
set shading.zoom.max.value 17

set tcp.port $tcp_port
set tcp.interface $interface
set tcp.maxconn 1024
set log.requests 0

set min_zoom_level [expr max( 4,$min_zoom_level)]
set max_zoom_level [expr min(20,$max_zoom_level)]

set qms.conf 0
set qms.file ""
set qms.args ""
set qms.default {splash 0 style Fusion scale 1.00 debug 0}
lmap {i v} ${qms.default} {set qms.$i $v}

# Save/restore settings

proc save_settings {file args} {
  array set save {}
  set fd [open $file a+]
  seek $fd 0
  while {[gets $fd line] != -1} {
    regexp {^(.*?)=(.*)$} $line "" name value
    set save($name) $value
  }
  foreach name $args {set save($name) [set ::$name]}
  seek $fd 0
  chan truncate $fd
  foreach name [lsort [array names save]] {puts $fd $name=$save($name)}
  close $fd
}

proc restore_settings {file} {
  if {![file exists $file]} return
  set fd [open $file r]
  while {[gets $fd line] != -1} {
    regexp {^(.*?)=(.*)$} $line "" name value
    set ::$name $value
  }
  close $fd
}

# Restore saved settings

foreach item {global hillshading qmapshack} \
	{restore_settings $ini_folder/$item.ini}
set i 0
lmap v ${shading.asy.values} {set shading.asy.array($i) $v; incr i}

# Restore saved font sizes

foreach item {TkDefaultFont TkTextFont TkFixedFont TkTooltipFont} \
	{font configure $item -size ${font.size}}

# Configure main window

set title [mc l01]
wm title . $title
wm protocol . WM_DELETE_WINDOW "set action 0"
wm resizable . 0 0
. configure -bd 5 -bg $colorBackground

# Output console window

set console 0;			# Valid values: 0=hide, 1=show

set ctid [thread::create -joinable "
  package require Tk
  package require tcl::chan::fifo2
  wm withdraw .
  wm title . \"$title - [mc l99]\"
  set font_size ${console.font.size}
  set geometry {${console.geometry}}
  ttk::style theme use clam
  ttk::style configure . -border $colorBorder -troughcolor $colorTrough
  thread::wait
  "]

proc ctsend {script} "return \[send $ctid \$script\]"

ctsend {
  foreach item {Consolas "Ubuntu Mono" "Noto Mono" "Liberation Mono"
  	[font configure TkFixedFont -family]} {
    set family [lsearch -nocase -exact -inline [font families] $item]
    if {$family != ""} break
  }
  font create font -family $family -size $font_size
  text .txt -font font -wrap none -setgrid 1 -state disabled -undo 0 \
	-width 120 -xscrollcommand {.sbx set} \
	-height 24 -yscrollcommand {.sby set}
  ttk::scrollbar .sbx -orient horizontal -command {.txt xview}
  ttk::scrollbar .sby -orient vertical   -command {.txt yview}
  grid .txt -row 1 -column 1 -sticky nswe
  grid .sby -row 1 -column 2 -sticky ns
  grid .sbx -row 2 -column 1 -sticky we
  grid columnconfigure . 1 -weight 1
  grid rowconfigure    . 1 -weight 1

  bind .txt <Control-a> {%W tag add sel 1.0 end;break}
  bind .txt <Control-c> {tk_textCopy %W;break}
  bind . <Control-plus>  {incr_font_size +1}
  bind . <Control-minus> {incr_font_size -1}
  bind . <Control-KP_Add>      {incr_font_size +1}
  bind . <Control-KP_Subtract> {incr_font_size -1}

  bind . <Configure> {
    if {"%W" != "."} continue
    scan [wm geometry %W] "%%dx%%d+%%d+%%d" cols rows x y
    set geometry "$x $y $cols $rows"
  }

  proc incr_font_size {incr} {
    set px [.txt xview]
    set py [.txt yview]
    set size [font configure font -size]
    incr size $incr
    if {$size < 5 || $size > 20} return
    font configure font -size $size
    update idletasks
    .txt xview moveto [lindex $px 0]
    .txt yview moveto [lindex $py 0]
  }

  proc write {text} {
    .txt configure -state normal
    foreach item [split $text \n] {
      if {[string index $item 0] == "\r"} {
	set item [string range $item 1 end]
	.txt delete end-2l end-1l
      }
      if {[string index $item end] == "\b"} {
	set item [string range $item 0 end-1]
      } else {
	append item \n
      }
      .txt insert end $item
    }
    .txt configure -state disabled
    if {[winfo ismapped .]} {.txt see end}
  }

  proc show_hide {show} {
    if {$show} {
      .txt see end
      if {$::geometry == ""} {
	wm deiconify .
      } else {
	lassign $::geometry x y cols rows
	if {$x > [expr [winfo vrootx .]+[winfo vrootwidth .]] ||
	    $x < [winfo vrootx .]} {set x [winfo vrootx .]}
	wm positionfrom . program
	wm geometry . ${cols}x${rows}+$x+$y
	wm deiconify .
	wm geometry . +$x+$y
      }
    } else {
      wm withdraw .
    }
  }

  lassign [::tcl::chan::fifo2] fdi fdo
  thread::detach $fdo
  fconfigure $fdi -blocking 0 -buffering full -buffersize 131072 -translation lf
  fileevent $fdi readable "
    set text {}
    while {\[gets $fdi line\] >= 0} {lappend text \$line}
    write \[join \$text \\n\]
  "
}

set fdo [ctsend "set fdo"]
thread::attach $fdo
fconfigure $fdo -blocking 0 -buffering line -translation lf
interp alias {} ::cputs {} ::puts $fdo

if {$console == 1} {
  set console.show 1
  ctsend "show_hide 1"
}

# Write to console

proc cputi {text} {cputs "\[---\] $text"}
proc cputw {text} {cputs "\[+++\] $text"}

cputw [mc m51 [pid] [file tail [info nameofexecutable]]]
cputw "Tcl/Tk version $tcl_patchLevel"
cputw "Script '[file tail $script]' version $version"

# Show error message

proc error_message {message exit_return} {
  messagebox -title $::title -icon error -message $message
  eval $exit_return
}

# Get shell command from exec command

proc get_shell_command {command} {
  return [join [lmap item $command {regsub {^(.* +.*|())$} $item {"\1"}}]]
}

# Check commands, files & folders

foreach item {qms_cmd java_cmd} {
  set value [set $item]
  if {$value == ""} {error_message [mc e04 $value $item] exit}
}
foreach item {server_jar} {
  set value [set $item]
  if {![file isfile $value]} {error_message [mc e05 $value $item] exit}
}
foreach item {maps_folder themes_folder} {
  set value [set $item]
  if {![file isdirectory $value]} {error_message [mc e05 $value $item] exit}
}

# Work around Oracle's Java wrapper "java.exe" issue:
# Wrapper requires running within real Windows console,
# therefore not working within Tcl script called by "wish"!
# -> Try getting Java's real path from Windows registry

if {$tcl_platform(os) == "Windows NT" &&
  ([regexp -nocase {^.*/Program Files.*/Common Files/Oracle/Java/.*/java.exe$} $java_cmd]
   || [regexp -nocase {^.*/ProgramData/Oracle/Java/.*/java.exe$} $java_cmd])} {
  set exec ""
  foreach item {HKEY_LOCAL_MACHINE\\SOFTWARE\\JavaSoft \
		HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\JavaSoft} {
    foreach key {JRE "Java Runtime Environment" JDK "Java Development Kit"} {
      if {[catch {registry get $item\\$key CurrentVersion} value]} continue
      if {[catch {registry get $item\\$key\\$value JavaHome} value]} continue
      set exec [auto_execok "[file normalize $value]/bin/java.exe"]
      if {$exec != ""} break
    }
    if {$exec == ""} continue
    set java_cmd [lindex $exec 0]
    break
  }
}

# Get major Java version

set java_version 0
set java_string unknown
set command [list $java_cmd -version]
set rc [catch "exec $command 2>@1" result]
if {!$rc} {
  set line [lindex [split $result \n] 0]
  regsub -nocase {^.* version "(.*)".*$} $line {\1} data
  set java_string $data
  if {[regsub {^1\.([1-9]+)\.[0-9]+.*$} $java_string {\1} data] > 0} {
    set java_version $data; # Oracle Java version <= 8
  } elseif {[regsub {^([1-9][0-9]*)((\.0)*\.[1-9][0-9]*)*([+-].*)?$} \
	$java_string {\1} data] > 0} {
    set java_version $data; # Other Java versions >= 9
  }
}

if {$rc || $java_version == 0} \
  {error_message [mc e08 Java [get_shell_command $command] $result] exit}

# Check minimum required Java version

set java_version_min 11
if {$java_version < $java_version_min} \
  {error_message [mc e07 Java $java_string $java_version_min] exit}

# Prepend Java executable's path to PATH environment variable
# to force same Java executable for nested Java calls

set path [file dirname $java_cmd]
if {$tcl_platform(os) == "Windows NT"} \
	{set env(PATH) "[file nativename $path]\;$env(PATH)"}
if {$tcl_platform(os) == "Linux"} \
	{set env(PATH) "$path:$env(PATH)"}

# Evaluate numeric Mapsforge server version
# from output line ending with version string " version: x.y.z.c"

set server_version 0
set server_string unknown
set command [list $java_cmd -jar $server_jar -help]
set rc [catch "exec $command 2>@1" result]
foreach line [split $result \n] {
  if {![regexp -nocase {^(?:.* version: )([0-9.]+)$} $line "" data]} continue
  set server_string $data
  set data [split $data .]
  if {[llength $data] != 4} \
    {error_message [mc e07 "Mapsforge Server" $server_string 0.21.0.0] exit}
  foreach item $data {set server_version [expr 100*$server_version+$item]}
  break
}

if {$rc || $server_version == 0} \
  {error_message [mc e08 Server [get_shell_command $command] $result] exit}
if {$server_version < 210000} \
  {error_message [mc e07 "Mapsforge Server" $server_string 0.21.0.0] exit}

# Recursively find files

proc find_files {folder pattern} {
  set list [glob -nocomplain -directory $folder -type f $pattern]
  foreach subfolder [glob -nocomplain -directory $folder -type d *] \
	{lappend list {*}[find_files $subfolder $pattern]}
  return $list
}

# Get list of available Mapsforge maps

cd $maps_folder
set maps [find_files "" "*.map"]
cd $cwd
set maps [lsort -dictionary $maps]
if {[llength $maps] == 0} {error_message [mc e11] exit}

# Get list of available Mapsforge themes
# and add Mapsforge built-in themes

cd $themes_folder
set themes [find_files "" "*.xml"]
cd $cwd
lappend themes (OSMARENDER)
if {$server_version >= 260100} {
  lappend themes (BIKER) (DARK) (INDIGO) (MOTORIDER)
} elseif {$server_version >= 250000} {
  lappend themes (BIKER) (MOTORIDER)
} elseif {$server_version >= 220000} {
  lappend themes (MOTORIDER) (MOTORIDER_DARK)
}
set themes [lsort -dictionary $themes]
set themes [linsert $themes 0 (DEFAULT)]

# --- Begin of main window

# Title

font create title_font {*}[font configure TkDefaultFont] \
	-underline 1 -weight bold
label .title -text $title -font title_font -fg blue
pack .title -expand 1 -fill x

set github https://github.com/JFritzle/Mapsforge-for-QMapShack
tooltip .title $github
if {$tcl_platform(platform) == "windows"} \
	{set exec "exec cmd.exe /C START {} $github"}
if {$tcl_platform(os) == "Linux"} \
	{set exec "exec nohup xdg-open $github >/dev/null"}
bind .title <Button-1> "catch {$exec}"

# Menu column

frame .f
pack .f

# Server task(s)

set task.active (default)
set task.name ${task.active}

lappend task.set (default)
foreach task [glob -nocomplain -path $ini_folder/ \
	-type f -tails task.*.ini] \
	{lappend task.set [regsub {^task.(.*).ini$} $task {\1}]}
set task.set [lsort -unique ${task.set}]

lappend task.use (default)
set task.use [lmap task ${task.set} \
	{if {$task ni ${task.use}} continue;set task}]

labelframe .task -labelanchor w -text "[mc l02]: " -bd 0
entry .task.name -width 32 -textvariable task.name \
	-takefocus 1 -highlightthickness 0
bind .task.name <Return> task_item_add
button .task.post -image ArrowDown -command task_list_post
pack .task.post -side right -fill y
pack .task.name -side right -fill x -expand 1
pack .task -in .f -expand 1 -fill x -pady {8 0}
foreach item {.task .task.name} {tooltip $item [mc l02t]}

proc task_updown {d} {
  set l [llength ${::task.set}]
  if {$l == 1} {return}
  set v ${::task.active}
  save_task_settings $v
  set i [lsearch ${::task.set} $v]
  incr i $d
  if {$i == $l} {set i 0}
  if {$i == -1} {incr i $l}
  set v [lindex ${::task.set} $i]
  set ::task.name $v
  .task.name icursor end
  set ::task.active $v
  catch ".task_list.listbox activate $i"
  restore_task_settings $v
}
bind .task.name <MouseWheel> {task_updown [expr %D>0?-1:+1]}
foreach item {Down Button-4} {bind .task.name <$item> {task_updown +1}}
foreach item {Up   Button-5} {bind .task.name <$item> {task_updown -1}}

proc task_list_post {} {
  if {![task_item_add]} return

  set tl .task_list
  set lb $tl.listbox
  set sb $tl.scrollbar

  if {[winfo exists $lb]} {
    task_list_unpost
    return
  }

  set tn .task.name
  set x [winfo rootx $tn]
  set y [winfo rooty $tn]
  scan [winfo geometry $tn] "%dx%d" w h
  incr w [winfo width .task.post]
  incr y $h

  toplevel $tl -relief flat -bd 0
  wm withdraw $tl
  switch -- [tk windowingsystem] {
    x11 {
      wm attributes $tl -type combo
      wm overrideredirect $tl true
    }
    win32 {
      wm overrideredirect $tl true
      wm attributes $tl -topmost 1
    }
  }
  wm geometry $tl +$x+$y
  wm minsize $tl $w 0

  scrollbar $sb -command "$lb yview"
  set len [llength ${::task.set}]
  listbox $lb -selectmode multiple -activestyle underline -bd 0 \
	-takefocus 1 -exportselection 0 -height [expr min($len,5)]
  if {$len > 5} {
    pack $sb -side right -fill y
    $lb configure -yscrollcommand "$sb set"
  }
  pack $lb -side left -fill x -expand 1
  tooltip $lb [mc l03t]

  $lb insert 0 {*}${::task.set}
  $lb activate 0
  set i 0
  foreach v ${::task.set} {
     if {$v in ${::task.use}} {$lb selection set $i}
     if {$v == ${::task.name}} {$lb activate $i}
     incr i
  }

  foreach v {Map Enter} \
	{bind $lb <$v> {focus -force %W}}
  bind $lb <Delete> task_item_delete
  bind $lb <Tab> task_item_toggle
  bind $lb <Key-space> {task_item_toggle;break}
  bind $lb <Button-1> \
	{%W activate @%x,%y;task_name_update;task_item_toggle;break}
  foreach v {<PrevLine> <NextLine>} \
	{bind $lb <$v> "[bind Listbox <$v>];task_name_update;break"}
  foreach v {ButtonRelease-3 Escape FocusOut} \
	{bind $lb <$v> {task_list_unpost;break}}
  bind $tl <Button> \
	{if {"[winfo containing %X %Y]" != "%W"} {task_list_unpost;break}}

  wm transient $tl .
  wm attribute $tl -topmost 1
  update idletasks
  wm deiconify $tl
  raise $tl
  grab -global $tl
}

proc task_list_unpost {} {
  focus -force .task.name
  set tl .task_list
  set lb $tl.listbox
  set ::task.use {}
  foreach i [$lb curselection] {lappend ::task.use [$lb get $i]}
  destroy $tl
}

proc task_name_update {} {
  set lb .task_list.listbox
  set i [$lb index active]
  set v [$lb get $i]
  if {$v == ${::task.active}} return
  save_task_settings ${::task.active}
  set ::task.name $v
  set ::task.active $v
  restore_task_settings ${::task.active}
}

proc task_item_toggle {} {
  set lb .task_list.listbox
  set i [$lb index active]
  set v [$lb get $i]
  if {$v == "(default)"} return
  if {$i in [$lb curselection]} {
    $lb selection clear $i
  } else {
    $lb selection set $i
  }
}

proc task_item_delete {} {
  set lb .task_list.listbox
  set sb .task_list.scrollbar
  set i [$lb index active]
  set v [$lb get $i]
  if {$v == "(default)"} return
  $lb delete $i
  set ::task.set [lreplace ${::task.set} $i $i]
  set len [llength ${::task.set}]
  $lb configure -height [expr min($len,5)]
  if {$len <= 5} {pack forget $sb}
  task_name_update
  set file $::ini_folder/task.$v.ini
  file delete $file
  set ::task.active [$lb get active]
  restore_task_settings ${::task.active}
}

proc task_item_add {} {
  set tn .task.name
  set v [$tn get]
  set i [lsearch ${::task.set} $v]
  if {$i != -1} {
    if {$v == ${::task.active}} {return 1}
    save_task_settings ${::task.active}
    set ::task.active $v
    restore_task_settings ${::task.active}
  } elseif {[regexp "^\[0-9A-Za-z\]+(\[_.+-\]?\[0-9A-Za-z\]+)*$" $v]} {
    save_task_settings ${::task.active}
    set ::task.active $v
    set ::task.set [lsort [lappend ::task.set $v]]
    set ::task.use [lsort [lappend ::task.use $v]]
  } else {
    error_message [mc l02e $v] return
    set ::task.name ${::task.active}
    return 0
  }
  return 1
}

# Save active task settings

proc save_task_settings {task} {
  lmap {i v} [array get ::shading.asy.array] {lset ::shading.asy.values $i $v}
  set file $::ini_folder/task.$task.ini
  file delete $file
  save_settings $file \
	maps.language maps.selection maps.world maps.contrast maps.gamma \
	theme.selection user.scale text.scale symbol.scale line.scale \
	shading.layer shading.onoff shading.algorithm \
	shading.simple.linearity shading.simple.scale \
	shading.diffuselight.angle shading.asy.values \
	shading.magnitude dem.folder \
	shading.zoom.min.apply shading.zoom.min.value \
	shading.zoom.max.apply shading.zoom.max.value

  lassign [get_selected_style_overlays] style.id overlay.ids
  if {${style.id} != ""} {
    set fd [open $file a+]
    puts $fd style.id=${style.id}\noverlay.ids=${overlay.ids}
    close $fd
  }
}

# Restore task settings

proc restore_task_settings {task} {
  set theme_selection ${::theme.selection}
  restore_settings $::ini_folder/task.$task.ini
  set list [.maps.values get 0 end]
  .maps.values selection clear 0 end
  foreach item ${::maps.selection} {
    set i [lsearch -exact $list $item]
    if {$i != -1} {.maps.values selection set $i}
  }
  set i 0
  lmap v ${::shading.asy.values} {set ::shading.asy.array($i) $v; incr i}
  update_shading_window

  if {$theme_selection != ${::theme.selection}} {update_theme_styles_overlays}
  if {[info exists ::style.id]} {
    set_selected_style_overlays ${::style.id} ${::overlay.ids}
    unset -nocomplain ::style.id ::overlay.ids
  }
  update_overlays_selection
}

# Preferred maps language (2 lowercase letters ISO 639-1 code)

if {![info exists maps.language]} {set maps.language $language}
labelframe .lang -labelanchor w -text [mc l11]:
pack .lang -in .f -expand 1 -fill x -pady 1
entry .lang.value -textvariable maps.language -width 4 -justify center
pack .lang.value -side right
foreach item {.lang .lang.value} {tooltip $item [mc l11t]}

.lang.value configure -validate key -vcmd {
  if {%d < 1} {return 1}
  if {[string length %P] > 2} {return 0}
  if {![string is lower %S]}  {return 0}
  return 1
}

# Mapsforge map selection

labelframe .maps_folder -labelanchor nw -text [mc l13]:
pack .maps_folder -in .f -expand 1 -fill x -pady 1
entry .maps_folder.value -textvariable maps_folder \
	-state readonly -takefocus 0 -highlightthickness 0
pack .maps_folder.value -expand 1 -fill x

labelframe .maps -labelanchor nw -text [mc l14]:
pack .maps -in .f -expand 1 -fill x -pady 1
scrollbar .maps.scroll -command ".maps.values yview"
listbox .maps.values -selectmode extended -activestyle none \
	-takefocus 1 -exportselection 0 \
	-width 0 -height [expr min([llength $maps],8)] \
	-yscrollcommand ".maps.scroll set"
pack .maps.scroll -side right -fill y
pack .maps.values -side left -expand 1 -fill both
tooltip .maps.values [mc l14t]

foreach map $maps {
  .maps.values insert end $map
  if {$map in ${maps.selection}} {.maps.values selection set end}
}
set selection [.maps.values curselection]
if {[llength $selection] > 0} {.maps.values see [lindex $selection 0]}

bind .maps.values <<ListboxSelect>> {
  set maps.selection [lmap index [.maps.values curselection] \
	{.maps.values get $index}]
}

# Append Mapsforge world map

checkbutton .maps_world -text [mc l15] -variable maps.world
pack .maps_world -in .f -expand 1 -fill x

# Mapsforge theme selection

labelframe .themes_folder -labelanchor nw -text [mc l16]:
pack .themes_folder -in .f -expand 1 -fill x -pady 1
entry .themes_folder.value -textvariable themes_folder \
	-state readonly -takefocus 0 -highlightthickness 0
pack .themes_folder.value -expand 1 -fill x

set width 0
foreach item $themes \
	{set width [expr max([font measure TkTextFont $item],$width)]}
set width [expr $width/[font measure TkTextFont "0"]+1]

labelframe .themes -labelanchor nw -text [mc l17]:
pack .themes -in .f -expand 1 -fill x -pady 1
combobox .themes.values -width $width \
	-validate key -validatecommand {return 0} \
	-textvariable theme.selection -values $themes
if {[.themes.values current] < 0} {.themes.values current 0}
pack .themes.values -expand 1 -fill x

# Mapsforge theme style selection

labelframe .styles -labelanchor nw -text [mc l18]:
combobox .styles.values -validate key -validatecommand {return 0}
pack .styles.values -expand 1 -fill x
bind .styles.values <<ComboboxSelected>> update_overlays_selection

# Mapsforge theme overlays selection

checkbutton .overlays_show_hide -text [mc c01] \
	-command "show_hide_toplevel_window .overlays"
pack .overlays_show_hide -in .styles -expand 1 -fill x -pady {2 0}

# Show hillshading options

checkbutton .shading_show_hide -text [mc c02] \
	-command "show_hide_toplevel_window .shading"
pack .shading_show_hide -in .f -expand 1 -fill x

# Show visual rendering effects options

checkbutton .effects_show_hide -text [mc c03] \
	-command "show_hide_toplevel_window .effects"
pack .effects_show_hide -in .f -expand 1 -fill x

# Show server settings

checkbutton .server_show_hide -text [mc c04] \
	-command "show_hide_toplevel_window .server"
pack .server_show_hide -in .f -expand 1 -fill x

# Show QMapShack settings

checkbutton .qms_show_hide -text [mc c05] \
	-command "show_hide_toplevel_window .qms"
pack .qms_show_hide -in .f -expand 1 -fill x

# Action buttons

frame .buttons
button .buttons.continue -text [mc b01] -width 12 -command {set action 1}
tooltip .buttons.continue [mc b01t]
button .buttons.cancel -text [mc b02] -width 12 -command {set action 0}
tooltip .buttons.cancel [mc b02t]
pack .buttons.continue .buttons.cancel -side left
pack .buttons -pady 5

focus .buttons.continue

proc busy_state {state} {
  set busy {.f .buttons.continue .overlays .shading .effects .server}
  if {$state} {
    foreach item $busy {tk busy hold $item}
    .buttons.continue state pressed
  } else {
    .buttons.continue state !pressed
    foreach item $busy {tk busy forget $item}
  }
  update idletasks
}

# Show/hide output console window (show with saved geometry)

checkbutton .output -text [mc c99] \
	-variable console.show -command show_hide_console
pack .output -expand 1 -fill x

proc show_hide_console {} {
  update idletasks
  ctsend "show_hide ${::console.show}"
}
show_hide_console

# Map/Unmap events are generated by Windows only!
set tid [thread::id]
ctsend "
  wm protocol . WM_DELETE_WINDOW \
	{thread::send -async $tid {.output invoke}}
  bind . <Unmap> {if {\"%W\" == \".\"} \
	{thread::send -async $tid {set console.show 0}}}
  bind . <Map>   {if {\"%W\" == \".\"} \
	{thread::send -async $tid {set console.show 1}}}
"

# --- End of main window

# Create toplevel windows for
# - overlays selection
# - hillshading settings
# - visual rendering effects
# - server settings

foreach widget {.overlays .shading .effects .server .qms} {
  set parent ${widget}_show_hide
  toplevel $widget -bd 5
  wm withdraw $widget
  wm title $widget [$parent cget -text]
  wm protocol $widget WM_DELETE_WINDOW "$parent invoke"
  wm resizable $widget 0 0
  wm positionfrom $widget program
  if {[tk windowingsystem] == "x11"} {wm attributes $widget -type dialog}

  bind $widget <Double-ButtonRelease-3> "$parent invoke"
  set ::$parent 0
}

# Show/hide toplevel window

proc show_hide_toplevel_window {widget} {
  set onoff [set ::${widget}_show_hide]
  if {$onoff} {
    resize_toplevel_window $widget
    position_toplevel_window $widget
    scan [wm geometry $widget] "%*dx%*d+%d+%d" x y
    wm transient $widget .
    wm deiconify $widget
    if {[tk windowingsystem] == "x11"} {after idle "wm geometry $widget +$x+$y"}
  } else {
    scan [wm geometry $widget] "%*dx%*d+%d+%d" x y
    set ::{$widget.dx} [expr $x - [set ::{$widget.x}]]
    set ::{$widget.dy} [expr $y - [set ::{$widget.y}]]
    wm withdraw $widget
  }
}

# Recalculate and force toplevel window size

proc resize_toplevel_window {widget} {
  update idletask
  lassign [wm minsize $widget] w0 h0
  set w1 [winfo reqwidth $widget]
  set h1 [winfo reqheight $widget]
  if {$w0 == $w1 && $h0 == $h1} return
  wm minsize $widget $w1 $h1
  wm maxsize $widget $w1 $h1
}

# Position toplevel window right/left besides main window

proc position_toplevel_window {widget} {
  if {![winfo ismapped .]} return
  update idletasks
  scan [wm geometry .] "%dx%d+%d+%d" width height x y
  if {[tk windowingsystem] == "win32"} {
    set bdwidth [expr [winfo rootx .]-$x]
  } elseif {[tk windowingsystem] == "x11"} {
    set bdwidth 2
    if {[auto_execok xwininfo] == ""} {
      cputw "Please install program 'xwininfo' by Linux package manager"
      cputw "to evaluate exact window border width."
    } elseif {![catch {exec bash -c "export LANG=C;xwininfo -id [wm frame .] \
	| grep Width | cut -d: -f2"} wmwidth]} {
      set bdwidth [expr ($wmwidth-$width)/2]
      set width $wmwidth
    }
  }
  set reqwidth [winfo reqwidth $widget]
  set right [expr $x+$bdwidth+$width]
  set left  [expr $x-$bdwidth-$reqwidth]
  if {[expr $right+$reqwidth > [winfo vrootx .]+[winfo vrootwidth .]]} {
    set x [expr $left < [winfo vrootx .] ? 0 : $left]
  } else {
    set x $right
  }
  set ::{$widget.x} $x
  set ::{$widget.y} $y
  if {[info exists ::{$widget.dx}]} {
    incr x [set ::{$widget.dx}]
    incr y [set ::{$widget.dy}]
  }
  wm geometry $widget +$x+$y
}

# Global toplevel bindings

foreach widget {. .overlays .shading .effects .server .qms} {
  bind $widget <Control-plus>  {incr_font_size +1}
  bind $widget <Control-minus> {incr_font_size -1}
  bind $widget <Control-KP_Add>      {incr_font_size +1}
  bind $widget <Control-KP_Subtract> {incr_font_size -1}
}

# --- Begin of hillshading

# Enable/disable hillshading

checkbutton .shading.onoff -text [mc c80] -variable shading.onoff
pack .shading.onoff -expand 1 -fill x

# Hillshading on map or as separate transparent overlay map

radiobutton .shading.onmap -text [mc c81] -state disabled \
	-variable shading.layer -value onmap
tooltip .shading.onmap [mc c81t]
radiobutton .shading.asmap -text [mc c82] \
	-variable shading.layer -value asmap
tooltip .shading.asmap [mc c82t]
pack .shading.onmap .shading.asmap -anchor w -fill x

# Choose DEM folder with HGT files

if {![file isdirectory ${dem.folder}]} {set dem.folder ""}

labelframe .shading.dem_folder -labelanchor nw -text [mc l81]:
tooltip .shading.dem_folder [mc l81t]
pack .shading.dem_folder -fill x -expand 1 -pady 1
entry .shading.dem_folder.value -textvariable dem.folder \
	-state readonly -takefocus 0 -highlightthickness 0
tooltip .shading.dem_folder.value [mc l81t]
button .shading.dem_folder.button -style Arrow.TButton \
	-image ArrowDown -command choose_dem_folder
pack .shading.dem_folder.button -side right -fill y
pack .shading.dem_folder.value -side left -fill x -expand 1

proc choose_dem_folder {} {
  set folder [tk_chooseDirectory -parent . -initialdir ${::dem.folder} \
	-mustexist 1 -title "$::title - [mc l82]"]
  if {$folder != "" && [file isdirectory $folder]} {set ::dem.folder $folder}
}

# Hillshading algorithm

labelframe .shading.algorithm -labelanchor w -text [mc l83]:
pack .shading.algorithm -expand 1 -fill x -pady 2
set list {}
if {$server_version >= 230001} {lappend list adaptasy}
if {$server_version >= 220000} {lappend list stdasy simplasy hiresasy}
lappend list simple diffuselight
combobox .shading.algorithm.values -width 12 \
	-validate key -validatecommand {return 0} \
	-textvariable shading.algorithm -values $list
if {[.shading.algorithm.values current] < 0} \
	{.shading.algorithm.values current 0}
pack .shading.algorithm.values -side right -anchor e -expand 1

# Hillshading algorithm parameters

labelframe .shading.simple -labelanchor w -text [mc l84]:
entry .shading.simple.value1 -textvariable shading.simple.linearity \
	-width 8 -justify right
set .shading.simple.value1.minmax {0 1 0.1}
tooltip .shading.simple.value1 "0 ≤ [mc l84] ≤ 1"
label .shading.simple.label2 -text [mc l85]:
entry .shading.simple.value2 -textvariable shading.simple.scale \
	-width 8 -justify right
set .shading.simple.value2.minmax {0 10 0.666}
tooltip .shading.simple.value2 "0 ≤ [mc l85] ≤ 10"
pack .shading.simple.value1 .shading.simple.label2 .shading.simple.value2 \
	-side left -anchor w -expand 1 -fill x -padx {5 0}

labelframe .shading.diffuselight -labelanchor w -text [mc l86]:
entry .shading.diffuselight.value -textvariable shading.diffuselight.angle \
	-width 8 -justify right
set .shading.diffuselight.value.minmax {0 90 50.}
tooltip .shading.diffuselight.value "0° ≤ [mc l86] ≤ 90°"
pack .shading.diffuselight.value -side right -anchor e -expand 1

frame .shading.asy
foreach i {0 1 2} {
  label .shading.asy.label$i -anchor w -text [mc l88$i]:
  entry .shading.asy.value$i -textvariable shading.asy.array($i) \
	-width 8 -justify right
  grid .shading.asy.label$i -row $i -column 1 -sticky w -padx {0 2}
  grid .shading.asy.value$i -row $i -column 2 -sticky e
}
set .shading.asy.value0.minmax {0 1 0.5}
tooltip .shading.asy.value0 "0 ≤ [mc l880] ≤ 1"
set .shading.asy.value1.minmax {0 99 0}
tooltip .shading.asy.value1 "0 ≤ [mc l881] < [mc l882]"
set .shading.asy.value2.minmax {1 100 80}
tooltip .shading.asy.value2 "[mc l881] < [mc l882] ≤ 100"
checkbutton .shading.asy.hq -text [mc l885] -variable shading.asy.array(5) \
	-onvalue true -offvalue false
grid .shading.asy.hq -row 4 -column 1 -columnspan 2 -sticky we
grid columnconfigure .shading.asy 1 -weight 1

# Hillshading magnitude

labelframe .shading.magnitude -labelanchor w -text [mc l87]:
pack .shading.magnitude -expand 1 -fill x
entry .shading.magnitude.value -textvariable shading.magnitude \
	-width 8 -justify right
set .shading.magnitude.value.minmax {0 4 1.}
tooltip .shading.magnitude.value "0 ≤ [mc l87] ≤ 4"
pack .shading.magnitude.value -anchor e -expand 1

# Theme's hillshading zoom

frame .shading.zoom
checkbutton .shading.zoom.min_apply -text [mc l891]: \
	-variable shading.zoom.min.apply \
	-onvalue true -offvalue false -command update_shading_zoom_levels
entry .shading.zoom.min_value -textvariable shading.zoom.min.value \
	-width 8 -justify right
set .shading.zoom.min_value.minmax {0 20 9}
tooltip .shading.zoom.min_value "0 ≤ [mc l891] ≤ 20"
checkbutton .shading.zoom.max_apply -text [mc l892]: \
	-variable shading.zoom.max.apply \
	-onvalue true -offvalue false -command update_shading_zoom_levels
entry .shading.zoom.max_value -textvariable shading.zoom.max.value \
	-width 8 -justify right
set .shading.zoom.max_value.minmax {0 20 17}
tooltip .shading.zoom.max_value "0 ≤ [mc l892] ≤ 20"

set row 0
foreach item {min max} {
  incr row
  grid .shading.zoom.${item}_apply -row $row -column 1 -sticky we -padx {0 2}
  grid .shading.zoom.${item}_value -row $row -column 2 -sticky we
}
grid columnconfigure .shading.zoom 1 -weight 1
if {$server_version >= 230002} {pack .shading.zoom -expand 1 -fill x}

# Reset hillshading values

button .shading.reset -text [mc b92] -width 8 -command reset_shading_values
tooltip .shading.reset [mc b92t]
pack .shading.reset -pady {5 0}

proc update_shading_zoom_levels {} {
  foreach item {shading.zoom.min shading.zoom.max} {
    if {[set ::$item.apply] == true} {.${item}_value configure -state normal} \
    else {.${item}_value configure -state disabled}
  }
}

proc update_shading_window {} {
  catch "pack forget .shading.simple .shading.diffuselight .shading.asy"
  if {${::shading.algorithm} ni [.shading.algorithm.values cget -values]} \
	{.shading.algorithm.values current 0}
  set widget ${::shading.algorithm}
  regsub {.*asy$} $widget {asy} widget
  pack .shading.$widget -after .shading.algorithm -expand 1 -fill x -pady 1
  update_shading_zoom_levels
  resize_toplevel_window .shading
}

set shading_widgets_float {.shading.simple.value1 .shading.simple.value2 \
	.shading.diffuselight.value .shading.magnitude.value \
	.shading.asy.value0}
set shading_widgets_int {.shading.asy.value1 .shading.asy.value2 \
	.shading.zoom.min_value .shading.zoom.max_value}

proc reset_shading_values {} {
  foreach item [concat $::shading_widgets_float $::shading_widgets_int] \
	{set ::[$item cget -textvariable] [lindex [set ::$item.minmax] 2]}
  set ::shading.asy.array(5) true
  .shading.algorithm.values current 0
  foreach item {min max} {set ::shading.zoom.$item.apply false}
  update_shading_window
}

foreach item $shading_widgets_float {
  $item configure -validate all -vcmd {validate_number %W %V %P " " float}
}

foreach item $shading_widgets_int {
  $item configure -validate all -vcmd {validate_number %W %V %P " " int}
}

foreach item [concat $shading_widgets_float $shading_widgets_int] {
  bind $item <Shift-ButtonRelease-1> \
	{set [%W cget -textvariable] [lindex ${::%W.minmax} 2]}
}

# Save hillshading settings to folder ini_folder

proc save_shading_settings {} {
  lmap {i v} [array get ::shading.asy.array] {lset ::shading.asy.values $i $v}
  save_settings $::ini_folder/hillshading.ini \
	shading.layer shading.onoff shading.algorithm \
	shading.simple.linearity shading.simple.scale \
	shading.diffuselight.angle shading.asy.values \
	shading.magnitude dem.folder \
	shading.zoom.min.apply shading.zoom.min.value \
	shading.zoom.max.apply shading.zoom.max.value
}

bind .shading.algorithm.values <<ComboboxSelected>> update_shading_window
update_shading_window

# --- End of hillshading
# --- Begin of visual rendering effects

# Scaling

label .effects.scaling -text [mc s01]

label .effects.user_label -text [mc s02]: -anchor w
scale .effects.user_scale -from 0.05 -to 2.50 -resolution 0.05 \
	-orient horizontal -variable user.scale
bind .effects.user_scale <Shift-ButtonRelease-1> "set user.scale 1.00"
label .effects.user_value -textvariable user.scale -width 4 \
	-relief sunken -anchor center

label .effects.text_label -text [mc s03]: -anchor w
scale .effects.text_scale -from 0.05 -to 2.50 -resolution 0.05 \
	-orient horizontal -variable text.scale
bind .effects.text_scale <Shift-ButtonRelease-1> "set text.scale 1.00"
label .effects.text_value -textvariable text.scale -width 4 \
	-relief sunken -anchor center

label .effects.symbol_label -text [mc s04]: -anchor w
scale .effects.symbol_scale -from 0.05 -to 2.50 -resolution 0.05 \
	-orient horizontal -variable symbol.scale
bind .effects.symbol_scale <Shift-ButtonRelease-1> "set symbol.scale 1.00"
label .effects.symbol_value -textvariable symbol.scale -width 4 \
	-relief sunken -anchor center

label .effects.line_label -text [mc s05]: -anchor w
scale .effects.line_scale -from 0.05 -to 2.50 -resolution 0.05 \
	-orient horizontal -variable line.scale
bind .effects.line_scale <Shift-ButtonRelease-1> "set line.scale 1.00"
label .effects.line_value -textvariable line.scale -width 4 \
	-relief sunken -anchor center

set row 0
grid .effects.scaling -row $row -column 1 -columnspan 3 -sticky we
foreach item {user text symbol line} {
  incr row
  grid .effects.${item}_label -row $row -column 1 -sticky w \
	-padx {0 2} -pady {0 4}
  grid .effects.${item}_scale -row $row -column 2 -sticky we
  grid .effects.${item}_value -row $row -column 3 -sticky e
}

# Gamma correction & Contrast-stretching

label .effects.color -text [mc s06]

label .effects.gamma_label -text [mc s07]: -anchor w
scale .effects.gamma_scale -from 0.01 -to 4.99 -resolution 0.01 \
	-orient horizontal -variable maps.gamma
bind .effects.gamma_scale <Shift-ButtonRelease-1> "set maps.gamma 1.00"
label .effects.gamma_value -textvariable maps.gamma -width 4 \
	-relief sunken -anchor center

label .effects.contrast_label -text [mc s08]: -anchor w
scale .effects.contrast_scale -from 0 -to 254 -resolution 1 \
	-orient horizontal -variable maps.contrast
bind .effects.contrast_scale <Shift-ButtonRelease-1> "set maps.contrast 0"
label .effects.contrast_value -textvariable maps.contrast -width 4 \
	-relief sunken -anchor center

set row 10
grid .effects.color -row $row -column 1 -columnspan 3 -sticky we
foreach item {gamma contrast} {
  incr row
  grid .effects.${item}_label -row $row -column 1 -sticky w \
	-padx {0 2} -pady {0 4}
  grid .effects.${item}_scale -row $row -column 2 -sticky we
  grid .effects.${item}_value -row $row -column 3 -sticky e
}

grid columnconfigure .effects {1 2} -uniform 1

# Reset visual rendering effects

button .effects.reset -text [mc b92] -width 8 -command reset_effects_values
tooltip .effects.reset [mc b92t]
grid .effects.reset -row 99 -column 1 -columnspan 3 -pady {5 0}

proc reset_effects_values {} {
  foreach item {user.scale text.scale symbol.scale line.scale maps.gamma} \
	{set ::$item 1.00}
  set ::maps.contrast 0
}

# --- End of visual rendering effects
# --- Begin of server settings

# Server information

label .server.info -text [mc x01]
pack .server.info

# Java runtime version

labelframe .server.jre_version -labelanchor w -text [mc x02]:
pack .server.jre_version -expand 1 -fill x -pady 1
label .server.jre_version.value -anchor e -textvariable java_string
pack .server.jre_version.value -side right -anchor e -expand 1

# Mapsforge server version

labelframe .server.version -labelanchor w -text [mc x03]:
pack .server.version -expand 1 -fill x -pady 1
label .server.version.value -anchor e -textvariable server_string
pack .server.version.value -side right -anchor e -expand 1

# Mapsforge server version jar archive

labelframe .server.jar -labelanchor nw -text [mc x04]:
pack .server.jar -expand 1 -fill x -pady 1
entry .server.jar.value -textvariable server_jar \
	-state readonly -takefocus 0 -highlightthickness 0
pack .server.jar.value -expand 1 -fill x

# Server configuration

label .server.config -text [mc x11]
pack .server.config -pady {5 0}

# Rendering engine

set pattern marlin-*-Unsafe-OpenJDK
if {$java_version < 17} {
  append pattern 11
} else  {
  append pattern 1\[17\]
}
set engines [glob -nocomplain -tails -type f \
	-directory [file dirname $server_jar] $pattern.jar]
lappend engines (default)
set engines [lsort -dictionary $engines]

set width 0
foreach item $engines \
	{set width [expr max([font measure TkTextFont $item],$width)]}
set width [expr $width/[font measure TkTextFont "0"]+1]

labelframe .server.engine -labelanchor nw -text [mc x12]:
combobox .server.engine.values -width $width \
	-validate key -validatecommand {return 0} \
	-textvariable rendering.engine -values $engines
if {[.server.engine.values current] < 0} \
	{.server.engine.values current 0}
if {[llength $engines] > 1} {
  pack .server.engine -expand 1 -fill x -pady 1
  pack .server.engine.values -anchor e -expand 1 -fill x
}

# Server interface

labelframe .server.interface -labelanchor w -text [mc x13]:
combobox .server.interface.values -width 10 \
	-textvariable tcp.interface -values {localhost all}
if {[.server.interface.values current] < 0} \
	{.server.interface.values current 0}
pack .server.interface -expand 1 -fill x -pady {6 2}
pack .server.interface.values -side right -anchor e -expand 1 -padx {3 0}

# Server TCP port number

labelframe .server.port -labelanchor w -text [mc x15]:
entry .server.port.value -textvariable tcp.port \
	-width 6 -justify center
set .server.port.value.minmax "1024 65535 $tcp_port"
tooltip .server.port.value "1024 ≤ [mc x15] ≤ 65535"
pack .server.port -expand 1 -fill x -pady 1
pack .server.port.value -side right -anchor e -expand 1 -padx {3 0}

# Maximum size of TCP listening queue

labelframe .server.maxconn -labelanchor w -text [mc x16]:
entry .server.maxconn.value -textvariable tcp.maxconn \
	-width 6 -justify center
set .server.maxconn.value.minmax {0 {} 1024}
tooltip .server.maxconn.value "[mc x16] ≥ 0"
pack .server.maxconn -expand 1 -fill x -pady 1
pack .server.maxconn.value -side right -anchor e -expand 1 -padx {3 0}

# Enable/disable server request logging

checkbutton .server.logrequests -text [mc x19] -variable log.requests
pack .server.logrequests -expand 1 -fill x

# Reset server configuration

button .server.reset -text [mc b92] -width 8 -command reset_server_values
tooltip .server.reset [mc b92t]
pack .server.reset -pady {5 0}

proc reset_server_values {} {
  foreach widget {.server.port.value .server.maxconn.value} \
	{set ::[$widget cget -textvariable] [lindex [set ::$widget.minmax] 2]}
  .server.engine.values current 0
  .server.interface.values set $::interface
}

foreach widget {.server.port.value .server.maxconn.value} {
  $widget configure -validate all -vcmd {validate_number %W %V %P " " int}
  bind $widget <Shift-ButtonRelease-1> \
	{set [%W cget -textvariable] [lindex ${::%W.minmax} 2]}
}

# --- End of server settings
# --- Begin of QMapShack settings

# Configuration file

checkbutton .qms.conf -text [mc y01]: -variable qms.conf
tooltip .qms.conf [mc y01t]
pack .qms.conf -fill x

frame .qms.file
entry .qms.file.value -textvariable qms.file -width 40 \
	-state readonly -takefocus 0 -highlightthickness 0
.qms.file.value xview end
button .qms.file.button -style Arrow.TButton \
	-image ArrowDown -command choose_qms_file
pack .qms.file.button -side right -fill y
pack .qms.file.value -side left -fill x -expand 1
pack .qms.file -fill x

proc choose_qms_file {} {
  lappend ini [mc y02i] {.ini .cfg .conf}
  lappend all [mc y02a] *
  set file [tk_getSaveFile -parent . -title "$::title - [mc y02]" \
	-filetypes [list $ini $all] -initialfile ${::qms.file}]
  if {$file != ""} {set ::qms.file $file}
  .qms.file.value xview end
}

# Enable/disable debug output

checkbutton .qms.debug -text [mc y03] -variable qms.debug
pack .qms.debug -expand 1 -fill x

# Show splash screen

checkbutton .qms.splash -text [mc y04] -variable qms.splash
pack .qms.splash -expand 1 -fill x

# Window style

if {$tcl_platform(os) == "Windows NT"} {
  set qtstyles {Fusion Windows Windows11 WindowsVista ""}
} elseif {$tcl_platform(os) == "Linux"} {
  set qtstyles {Fusion Windows ""}
}
labelframe .qms.style -labelanchor w -text [mc y05]:
pack .qms.style -expand 1 -fill x -pady 1
combobox .qms.style.values \
	-validate key -validatecommand {return 0} \
	-textvariable qms.style -values $qtstyles
if {[.qms.style.values current] < 0} {.qms.style.values current 0}
pack .qms.style.values -expand 1 -fill x -padx {5 0}

# Additional command line parameters

labelframe .qms.args -labelanchor nw -text [mc y06]:
pack .qms.args -expand 1 -fill x -pady 1
entry .qms.args.value -textvariable qms.args -width 40 \
	-takefocus 1 -highlightthickness 0
pack .qms.args.value -expand 1 -fill x

# Scale window

labelframe .qms.scale -labelanchor w -text [mc y07]:
tooltip .qms.scale [mc y07t]
scale .qms.scale.scale -from 0.50 -to 2.50 -resolution 0.05 \
	-orient horizontal -variable qms.scale
bind .qms.scale.scale <Shift-ButtonRelease-1> "set qms.scale 1.00"
label .qms.scale.value -textvariable qms.scale -width 4 \
	-relief sunken
pack .qms.scale -expand 1 -fill x -pady 1
pack .qms.scale.value -side right -padx {3 0}
pack .qms.scale.scale -side right -padx {3 0} -expand 1 -fill x

# Reset settings

button .qms.reset -text [mc b92] -width 8 -command reset_qms_values
tooltip .qms.reset [mc b92t]
pack .qms.reset -pady {5 0}

proc reset_qms_values {} {
  uplevel #0 {lmap {i v} ${qms.default} {set qms.$i $v}}
}

# --- End of QMapShack settings
# --- Begin of theme file processing

# Get list of attributes from given xml element

proc get_element_attributes {name string} {
  set attributes {}
  regsub ".*<$name\\s+(.*?)\\s*/?>.*" $string {\1} string
  set items [regsub -all {(\S+?)\s*=\s*(".*?"|'.*?')} $string {{\1=\2}}]
  foreach item $items \
    {lappend attributes {*}[lrange [regexp -inline {(\S+)=.(.*).} $item] 1 2]}
  return $attributes
}

# Recursively find all overlays in layers list for given layer id

proc find_overlays_for_layer {layer_id layers} {
  set overlays {}
  set layer_index [lsearch -exact -index 0 $layers $layer_id]
  array set layer [lindex $layers [list $layer_index 1]]
  if {[info exists layer(parent)]} \
	{lappend overlays {*}[find_overlays_for_layer $layer(parent) $layers]}
  lappend overlays {*}$layer(overlays)
  foreach overlay_id $overlays \
	{lappend overlays {*}[find_overlays_for_layer $overlay_id $layers]}
  return $overlays
}

# Read theme file and create styles & overlays lookup table
# Update lookup table by presets from ini file, if any
# Initialize style & overlays selection dialogs

proc update_theme_selection {} {
  update_theme_styles_overlays
  update_overlays_selection
}

proc update_theme_styles_overlays {} {

  # Save current settings, hide style & overlays selection
  save_theme_settings
  destroy [winfo children .overlays]

  set theme ${::theme.selection}
  if {![regexp {^\(.*\)$} $theme] && ![file exists $::themes_folder/$theme]} {
    # Theme file no longer exists, use built-in default
    set ::theme.selection [lindex $::themes 0]
  }

  # Read theme from server's assets or from file

  if {[regexp {^\(.*\)$} $theme]} {
    set rc [catch "package require zipfile::decode"]
    if {!$rc} {
      set file "assets/mapsforge/[string tolower [string trim $theme ()]].xml"
      set rc [catch "zipfile::decode::open {$::server_jar}"]
      if {!$rc} {
	set dict [zipfile::decode::archive]
	set rc [catch "zipfile::decode::getfile {$dict} {$file}" data]
	zipfile::decode::close
	if {$rc} {unset data} \
	else {set data [encoding convertfrom utf-8 $data]}
      }
    }
  } else {
    set rc [catch "open {$::themes_folder/$theme} r" fd]
    if {!$rc} {
      set data [read $fd]
      close $fd
    }
  }

  if {![info exists data]} {
    # No theme data
    .shading.onmap configure -state normal
    set menu_first -1
  } else {
    # Process theme
    set ::style.theme $theme

    # Split into list of elements between "<" and ">"
    set elements [regexp -inline -all {<.*?>} $data]

    # Search for hillshading element
    if {[lsearch -regexp $elements {<hillshading\s+.*?>}] == -1} {
      # Hillshading element not found: disable hillshading configuration
      .shading.onmap configure -state disabled
    } else {
      # Hillshading element found: enable hillshading configuration
      .shading.onmap configure -state normal
    }

    # Search for stylemenu element
    set menu_first [lsearch -regexp $elements {<stylemenu\s+.*?>}]
  }

  # No style menu found
  if {$menu_first == -1} {
    unset -nocomplain ::style.table ::style.theme
    if {[winfo ismapped .overlays]} {.overlays_show_hide invoke}
    if {[winfo manager .styles] != ""} {
      pack forget .styles
      resize_toplevel_window .
    }
    return
  }

  # Stylemenu found
  set menu_last [lsearch -start $menu_first -regexp $elements {</stylemenu>}]
  set menu_data [lrange $elements $menu_first $menu_last]

  # Analyze stylemenu element for attribute defaultvalue
  array set stylemenu [get_element_attributes stylemenu [lindex $menu_data 0]]
  set defaultstyle $stylemenu(defaultvalue)
  set defaultlang  $stylemenu(defaultlang)
  unset stylemenu

  # Search for layer elements within stylemenu
  set layers {}
  set layer_indices [lsearch -all -regexp $menu_data {<layer\s+.*?>}]
  foreach layer_first $layer_indices {
    set layer_last [lsearch -start $layer_first -regexp $menu_data {</layer>}]
    set layer_data [lrange $menu_data $layer_first $layer_last]
    array unset layer
    array set layer [get_element_attributes layer [lindex $layer_data 0]]
    set layer(name) $layer(id)

    # Find layer's localized layer name
    set indices [lsearch -all -regexp $layer_data {<name\s+.*?>}]
    foreach index $indices {
      array unset name
      array set name [get_element_attributes name [lindex $layer_data $index]]
      if {![info exists name(lang)]} continue
      if {$name(lang) == $::language} {
	set layer(name) $name(value)
	break
      } elseif {$name(lang) == $defaultlang} {
	set layer(name) $name(value)
      }
    }

    # Replace escaped characters within layer's name
    set s $layer(name)
    set i 0
    while {[regexp -start $i -indices {&.*?;} $s r]} {
      set t [string range $s {*}$r]
      switch -glob [string range $t 1 end-1] {
	quot	{set t \"}
	amp	{set t \&}
	apos	{set t '}
	lt	{set t <}
	gt	{set t >}
	{#x[0-9A-Fa-f]*} {set t [subst \\U[string range $t 3 end-1]]}
	{#[0-9]*} {set t [subst \\U[format %x [string range $t 2 end-1]]]}
      }
      set s [string replace $s {*}$r $t]
      set i [lindex $r 0]+1
    }
    set layer(name) $s

    # Find layer's direct overlays
    set layer(overlays) {}
    set indices [lsearch -all -regexp $layer_data {<overlay\s+.*?>}]
    foreach index $indices {
      array unset overlay
      array set overlay \
	[get_element_attributes overlay [lindex $layer_data $index]]
      lappend layer(overlays) $overlay(id)
    }

    lappend layers [list $layer(id) [array get layer]]
  }
  unset -nocomplain layer name overlay

  # Append overlay elements to each style and fill global lookup table
  set ::style.table {}
  foreach item $layers {
    array unset layer
    array set layer [lindex $item 1]
    if {![info exists layer(visible)]} continue
    set overlays {}
    foreach overlay_id [find_overlays_for_layer $layer(id) $layers] {
      set overlay_index [lsearch -exact -index 0 $layers $overlay_id]
      array unset overlay_layer
      array set overlay_layer [lindex $layers [list $overlay_index 1]]
      if {![info exists overlay_layer(enabled)]} \
	{set overlay_layer(enabled) false}
      lappend overlays [list $overlay_layer(id) $overlay_layer(name) \
	$overlay_layer(enabled) $overlay_layer(enabled)]
    }
    lappend ::style.table [list $layer(id) $layer(name) $overlays]
  }
  unset -nocomplain layer overlay_layer

  # Restore style & overlays from folder ini_folder
  set file "$::ini_folder/theme.[regsub -all {/} $theme {.}].ini"
  array set preset {}
  set fd [open $file a+]
  seek $fd 0
  while {[gets $fd line] != -1} {
    regexp {^(.*?)=(.*)$} $line "" name value
    set preset($name) $value
  }
  close $fd

  # Restore selected style
  if {[info exists preset(defaultstyle)] &&
      [lsearch -exact -index 0 ${::style.table} $preset(defaultstyle)] >= 0} {
    set defaultstyle $preset(defaultstyle)
  }

  # Restore selected overlays
  set style_index 0
  foreach style ${::style.table} {
    set style_id [lindex $style 0]
    set overlays [lindex $style 2]
    set overlay_index 0
    foreach overlay $overlays {
      set overlay_id [lindex $overlay 0]
      set name $style_id.$overlay_id
      if {[info exists preset($name)]} {
	lset overlay 2 $preset($name)
	lset overlays $overlay_index $overlay
      }
      incr overlay_index
    }
    lset style 2 $overlays
    lset ::style.table $style_index $style
    incr style_index
  }

  # Fill style selection & select default style
  .styles.values configure -values [lmap i ${::style.table} {lindex $i 1}]
  .styles.values current \
	[lsearch -exact -index 0 ${::style.table} $defaultstyle]

  # Show style selection
  pack configure .styles -in .f -after .themes -expand 1 -fill x -pady 1
  resize_toplevel_window .
}

# Update overlay selection to selected style

proc update_overlays_selection {} {
  destroy [winfo children .overlays]
  if {![info exists ::style.table]} return
  set style [lindex ${::style.table} [.styles.values current]]
  set style_id [lindex $style 0]
  set parent [string tolower .overlays.$style_id]
  frame $parent
  label $parent.label -text [lindex $style 1]
  frame $parent.separator1 -bd 2 -height 2 -relief sunken
  pack $parent.label $parent.separator1 -expand 1 -fill x -pady {0 2}
  set overlays [lindex $style 2]
  foreach overlay $overlays {
    set overlay_id [lindex $overlay 0]
    set child [string tolower $parent.$overlay_id]
    set variable [string range $child 1 end]
    set ::$variable [lindex $overlay 2]
    checkbutton $child -text [lindex $overlay 1] -padding 0 \
	-variable $variable -onvalue true -offvalue false \
	-command "update_style_overlay $style_id $overlay_id"
    pack $child -expand 1 -fill x
  }
  frame $parent.separator2 -bd 2 -height 2 -relief sunken
  pack $parent.separator2 -expand 1 -fill x -pady 2
  frame $parent.buttons
  pack $parent.buttons -anchor n -expand 1
  button $parent.buttons.all -text [mc b91] -width 8 \
	-command "select_style_overlays $style_id all"
  tooltip $parent.buttons.all [mc b91t]
  button $parent.buttons.reset -text [mc b92] -width 8 \
	-command "select_style_overlays $style_id default"
  tooltip $parent.buttons.reset [mc b92t]
  button $parent.buttons.none -text [mc b93] -width 8 \
	-command "select_style_overlays $style_id none"
  tooltip $parent.buttons.none [mc b93t]
  pack $parent.buttons.all $parent.buttons.reset $parent.buttons.none \
	-side left -pady {2 0}
  pack $parent -anchor nw
  resize_toplevel_window .overlays
}

# Update style's lookup table entry to current overlay selection

proc update_style_overlay {style_id overlay_id} {
  set style_index [lsearch -exact -index 0 ${::style.table} $style_id]
  set style [lindex ${::style.table} $style_index]
  set overlays [lindex $style 2]
  set overlay_index [lsearch -exact -index 0 $overlays $overlay_id]
  set overlay [lindex $overlays $overlay_index]
  lset overlay 2 [set ::overlays.$style_id.$overlay_id]
  lset overlays $overlay_index $overlay
  lset style 2 $overlays
  lset ::style.table $style_index $style
}

# Select style's overlays from theme file:
# - select all overlays
# - deselect all overlays
# - select default overlays only

proc select_style_overlays {style_id select} {
  switch $select {
    all		{set check {$enabled != true}}
    none	{set check {$enabled == true}}
    default	{set check {$enabled != $default}}
  }
  set style_index [lsearch -exact -index 0 ${::style.table} $style_id]
  set style [lindex ${::style.table} $style_index]
  set overlays [lindex $style 2]
  foreach overlay $overlays {
    set enabled [lindex $overlay 2]
    set default [lindex $overlay 3]
    if {[expr $check]} {
      set overlay_id [lindex $overlay 0]
      [string tolower .overlays.$style_id.$overlay_id] invoke
    }
  }
}

# Get currently selected style & overlays

proc get_selected_style_overlays {} {
  if {![info exists ::style.table]} return
  set style_index [.styles.values current]
  set style [lindex ${::style.table} $style_index]
  set style_id [lindex $style 0]
  set overlays [lindex $style 2]
  set overlay_ids {}
  foreach overlay $overlays {
    if {[lindex $overlay 2]} {lappend overlay_ids [lindex $overlay 0]}
  }
  return [list $style_id [join $overlay_ids]]
}

# Set selected style & overlays

proc set_selected_style_overlays {style_id overlay_ids} {
  if {![info exists ::style.table]} return
  set style_index [lsearch -exact -index 0 ${::style.table} $style_id]
  if {$style_index < 0} return
  set style [lindex ${::style.table} $style_index]
  set overlays [lindex $style 2]
  set overlay_index 0
  foreach overlay $overlays {
    set overlay_id [lindex $overlay 0]
    lset overlay 2 [expr {$overlay_id in $overlay_ids} ? true : false]
    lset overlays $overlay_index $overlay
    incr overlay_index
  }
  lset style 2 $overlays
  lset ::style.table $style_index $style
  .styles.values current $style_index
}

# Save theme settings to folder ini_folder

proc save_theme_settings {} {
  if {![info exists ::style.table]} return
  set theme ${::style.theme}
  set style_index [.styles.values current]
  set style [lindex ${::style.table} $style_index]
  set style_id [lindex $style 0]
  set file "$::ini_folder/theme.[regsub -all {/} $theme {.}].ini"
  set fd [open $file w]
  puts $fd defaultstyle=$style_id
  foreach style ${::style.table} {
    set style_id [lindex $style 0]
    set overlays [lindex $style 2]
    foreach overlay $overlays {
      set overlay_id [lindex $overlay 0]
      puts $fd $style_id.$overlay_id=[lindex $overlay 2]
    }
  }
  close $fd
}

# Enable styles & overlays selection

bind .themes.values <<ComboboxSelected>> update_theme_selection
update_theme_selection

# --- End of theme file processing

# Save global settings to folder ini_folder

proc save_global_settings {} {
  scan [wm geometry .] "%dx%d+%d+%d" width height x y
  set ::window.geometry "$x $y $width $height"
  set ::font.size [font configure TkDefaultFont -size]
  set ::console.geometry [ctsend "set geometry"]
  set ::console.font.size [ctsend "font configure font -size"]
  save_settings $::ini_folder/global.ini \
	rendering.engine maps.language \
	maps.selection maps.world maps.contrast maps.gamma \
	theme.selection user.scale text.scale symbol.scale line.scale \
	tcp.maxconn log.requests \
	window.geometry font.size \
	console.show console.geometry console.font.size
}

# Save application dependent settings to folder ini_folder

proc save_qmapshack_settings {} {
  save_settings $::ini_folder/qmapshack.ini \
	qms.conf qms.file qms.debug qms.splash qms.style qms.args qms.scale \
	tcp.interface tcp.port task.use
}

# Validate signed/unsigned int/float number value

proc validate_number {widget event value sign number} {
  set name ::[$widget cget -textvariable]
  set value [string trim $value]
  set sign "\[$sign\]?";	# sign: " ", "+", "-", "+-"
  set int   {\d*}
  set float {\d*\.?\d*}
  set pattern [set $number];	# number: "int", "float"
  if {$event == "key"} {
    return [regexp "^($sign|$sign$pattern)$" $value];
  } elseif {$event == "focusin"} {
    set $name.prev $value
  } elseif {$event == "focusout"} {
    set prev [set $name.prev]
    if {[regexp "^$sign$pattern$" $value] &&
       ![regexp "^($sign|$sign\\.)$" $value]} {
      if {![info exists ::$widget.minmax]} {return 1}
      lassign [set ::$widget.minmax] min max
      set test [regsub {([+-]?)0*([0-9]+.*)} $value {\1\2}]
      if {$min != "" && [expr $test < $min]} {set $name $prev}
      if {$max != "" && [expr $test > $max]} {set $name $prev}
    } else {
      set $name $prev
    }
    after idle "$widget config -validate all"
  }
  return 1
}

# Increase/decrease font size

proc incr_font_size {incr} {
  set size [font configure TkDefaultFont -size]
  if {$size < 0} {set size [expr round(-$size/[tk scaling])]}
  incr size $incr
  if {$size < 5 || $size > 20} return
  set fonts {TkDefaultFont TkTextFont TkFixedFont TkTooltipFont title_font}
  foreach item $fonts {font configure $item -size $size}
  set height [expr [winfo reqheight .title]-2]

  if {$::tcl_version > 8.6} {
    set scale [expr ($height+2)*0.0065]
    foreach item {CheckOff CheckOn RadioOff RadioOn} \
	{$item configure -format [list svg -scale $scale]}
  } else {
    set size [expr round(($height+3)*0.6)]
    set padx [expr round($size*0.3)]
    if {$::tcl_platform(os) == "Windows NT"} {set pady 0.1}
    if {$::tcl_platform(os) == "Linux"} {set pady -0.1}
    set pady [expr round($size*$pady)]
    set margin [list 0 $pady $padx 0]
    foreach item {TCheckbutton TRadiobutton} \
	{style configure $item -indicatorsize $size -indicatormargin $margin}
  }
  update idletasks

  foreach item {.themes.values .styles.values .shading.algorithm.values \
	.server.engine.values .server.interface.values} \
	{if {[winfo exists $item]} {$item configure -justify left}}
  foreach item {.effects.user_scale .effects.text_scale \
	.effects.symbol_scale .effects.line_scale \
	.effects.gamma_scale .effects.contrast_scale} \
	{if {[winfo exists $item]} {$item configure -width $height}}
  foreach item {. .overlays .shading .effects .server .qms} \
	{resize_toplevel_window $item}
}

# Check selection for completeness

proc selection_ok {} {
  if {${::shading.onoff} && ![file isdirectory ${::dem.folder}]} {
    error_message [mc e45] return
    return 0
  }
  return 1
}

# Write Mapsforge TMS files as QMapShack online maps

proc write_mapsforge {task} {

  if {![file isdirectory $::tms_folder]} return
  set name "Mapsforge [regsub {^(.*)\.(.*)$} $task {\1 \2}]"
  set map $::tms_folder/$name.tms
  cputi "[mc m62 $map] ..."

  set data {}
  lappend data <TMS>
  lappend data {<Layer idx="0">}
  lappend data <Title>$name</Title>
  set min [expr 21-$::max_zoom_level]
  set max [expr 21-$::min_zoom_level]
  lappend data <MinZoomLevel>$min</MinZoomLevel>
  lappend data <MaxZoomLevel>$max</MaxZoomLevel>
  set url http://127.0.0.1:${::tcp.port}/%1/%2/%3.png?task=$task
  if {$::tile_size != 256} {append url &tileRenderSize=$::tile_size}
  lappend data <ServerUrl>$url</ServerUrl>"
  lappend data </Layer>
  lappend data </TMS>

  set fd [open $map w]
  puts $fd [join $data \n]
  close $fd
  cputi [mc m63 $name]
  cputi "URL: '[regsub "%1/%2/%3" $url "{z}/{x}/{y}"]'"

}

# Delete Mapsforge TMS files and tile caches

proc clean_mapsforge {task} {

  set name "Mapsforge [regsub {^(.*)\.(.*)$} $task {\1 \2}]"
  if {[file isdirectory $::tiles_folder]} {
    set cache $::tiles_folder/$name
    if {[file exists $cache]} {
      cputi "[mc m60 $cache] ..."
      catch {file delete -force $cache}
    }
  }
  if {[file isdirectory $::tms_folder]} {
    set map $::tms_folder/$name.tms
    if {[file exists $map]} {
      cputi "[mc m61 $map] ..."
      catch {file delete -force $map}
    }
  }

}

# Process start

proc process_start {command process} {

  set tid [thread::create -joinable "
    set command {$command}
    thread::wait
  "]

  proc tsend {script} "return \[send $tid \$script\]"

  set rc [tsend {catch {open "| $command 2>@1" r} result}]
  set result [tsend "set result"]

  if {$rc} {
    thread::release $tid
    error_message $result return
    after 0 {set action 0}
    return
  }

  namespace eval $process {}
  namespace upvar $process fd fd pid pid exe exe
  set ${process}::command $command

  set fd $result
  set pid [tsend "pid $fd"]

  set exe [file tail [lindex $command 0]]
  set mark \[[string toupper $process]\]
  cputi "[mc m51 $pid $exe] $mark"

  tsend "thread::detach $fd"
  thread::attach $fd
  fconfigure $fd -blocking 0 -buffering full -buffersize 131072

  unset -nocomplain ::$process.eof
  fileevent $fd readable "
    set text {}
    while {\[gets $fd line\] >= 0} {lappend text \"\\$mark \$line\"}
    if {\$text != {}} {cputs \[join \$text \\n\]}
    if {\[eof $fd\]} {
      thread::release $tid
      namespace delete $process
      cputi \"\[mc m52 $pid $exe\] \\$mark\"
      set $process.eof 1
      set action 0
      close $fd
    }"

}

# Process kill

proc process_kill {process} {

  if {![process_running $process]} return
  namespace upvar $process fd fd pid pid

  fileevent $fd readable [regsub {m52} [fileevent $fd readable] {m53}]

  if {$::tcl_platform(os) == "Windows NT"} {
    catch {exec TASKKILL /F /PID $pid /T}
  }
  if {$::tcl_platform(os) == "Linux"} {
    set rc [catch {exec pgrep -P $pid} list]
    if {$rc} {set list $pid} else {lappend list $pid}
    foreach item $list {catch {exec kill -SIGTERM $item}}
  }

  if {![info exist ::$process.eof]} {
    after 5000 "set $process.eof 1"
    vwait $process.eof
  }

}

# Check if process is running

proc process_running {process} {
  return [expr [namespace exists $process] && ![info exists ::$process.eof]]
}

# Mapsforge server start

proc srv_task_create {task} {
  set file $::ini_folder/task.$task.ini
  if {![file exists $file]} continue
  set fd [open $file r]
  while {[gets $fd line] != -1} {
    regexp {^(.*?)=(.*)$} $line "" name value
    set $name $value
  }
  close $fd

  # Map: on, off?

  set map ${maps.world}
  if {[llength ${maps.selection}] >= 0} {set map 1}

  # Hillshading: off, on map, as map?

  set shading ${shading.onoff}
  if {$shading && ${shading.layer} == "asmap"} {incr shading}

  # Configure subtasks

  foreach subtask {Map Hillshading} {

    set name [regsub ".(.default)." $subtask.$task ""]
    set file $::tmpdir/tasks/$name.properties

    set params {}

    if {$subtask == "Map" && $map == 1} {
      set language ${maps.language}
      if {$language != ""} {lappend params language $language}
      set map_list [lmap item ${maps.selection} {set map $::maps_folder/$item}]
      lappend params mapfiles [join $map_list ,]
      if {${maps.world} == 1} {lappend params worldmap true}
      set theme ${theme.selection}
      if {[regexp {^\(.*\)$} $theme]} {
	lappend params themefile [string trim $theme ()]
      } else {
	lappend params themefile $::themes_folder/$theme
      }
      if {[info exists style.id]} {
	lappend params style ${style.id}
	lappend params overlays [join ${overlay.ids} ,]
      }
      lappend params gamma-correction ${maps.gamma}
      lappend params contrast-stretch ${maps.contrast}
      lappend params text-scale ${text.scale}
      lappend params symbol-scale ${symbol.scale}
      lappend params user-scale ${user.scale}
      lappend params line-scale ${line.scale}
    }

    if {($subtask == "Map" && $shading == 1) || \
	($subtask == "Hillshading" && $shading == 2)} {
      set algorithm ${shading.algorithm}
      if {$algorithm == "simple"} {
	set linearity ${shading.simple.linearity}
	set scale ${shading.simple.scale}
	if {$linearity == ""} {set linearity 0.1}
	if {$scale == ""} {set scale 0.666}
	lappend params hillshading-algorithm $algorithm\($linearity,$scale\)
      } elseif {$algorithm == "diffuselight"} {
	set angle ${shading.diffuselight.angle}
	if {$angle == ""} {set angle 50.}
	lappend params hillshading-algorithm $algorithm\($angle\)
      } elseif {[regexp {asy$} $algorithm]} {
	lmap {i v} [array get shading.asy.array] \
	  {lset shading.asy.values $i $v}
	set values [join ${shading.asy.values} ,]
	lappend params hillshading-algorithm $algorithm\($values\)
      }
      set magnitude ${shading.magnitude}
      if {$magnitude == ""} {set magnitude 1.}
      lappend params hillshading-magnitude $magnitude
      foreach item {min max} {
	lassign [list shading.zoom.$item.apply shading.zoom.$item.value] i v
	if {[info exists $i] && [set $i] == true} {
	  lappend params hillshading-zoom-$item [set $v]
	}
      }
      lappend params demfolder ${dem.folder}
    }

    if {[llength $params] == 0} {
      clean_mapsforge $name
      file delete $file
      unset -nocomplain ::md5_$name
      continue
    }

    set data ""
    foreach {item value} $params {append data $item=$value\n}
    set md5 [md5 -hex [encoding convertto utf-8 $data]]
    if {[info exists ::md5_$name] && [set ::md5_$name] == $md5} continue
    if {[info exists ::md5_$subtask] && [set ::md5_$subtask] == $md5} continue

    clean_mapsforge $name
    set fd [open $file w]
    puts $fd $data
    close $fd
    write_mapsforge $name
    set ::md5_$name $md5
  }
}

proc srv_task_delete {task} {
  foreach subtask {Map Hillshading} {
    set name [regsub ".(.default)." $subtask.$task ""]
    set file $::tmpdir/tasks/$name.properties
    clean_mapsforge $name
    file delete $file
    unset -nocomplain ::md5_$name
  }
}

proc srv_start {} {

  if {$::restart_srv} {srv_stop}

  # Compose command line

  set params {-Xmx1G -Xms256M -Xmn256M}
  if {[info exists ::java_args]} {lappend params {*}$::java_args}
  lappend params -Dfile.encoding=UTF-8

  set engine ${::rendering.engine}
  if {$engine != "(default)"} {
    set engine [file dirname $::server_jar]/$engine
    lappend params --patch-module java.desktop="$engine"
  }

# set now [clock format [clock seconds] -format "%Y-%m-%d_%H-%M-%S"]
# lappend params -Xloggc:$::cwd/gc.$now.log -XX:+PrintGCDetails
  lappend params -Dslf4j.internal.verbosity=WARN
# lappend params -Dlog4j.debug
  lappend params -Dlog4j.configuration=file:"$::tmpdir/log4j.properties"

  lappend params -Dsun.java2d.opengl=true
# lappend params -Dsun.java2d.d3d=true
# lappend params -Dsun.java2d.accthreshold=0
# lappend params -Dsun.java2d.translaccel=true
# lappend params -Dsun.java2d.ddforcevram=true
# lappend params -Dsun.java2d.ddscale=true
# lappend params -Dsun.java2d.ddblit=true
# lappend params -Dsun.java2d.renderer.log=true
  lappend params -Dsun.java2d.renderer.log=false
  lappend params -Dsun.java2d.renderer.useLogger=true
# lappend params -Dsun.java2d.renderer.doStats=true
# lappend params -Dsun.java2d.renderer.doChecks=true
# lappend params -Dsun.java2d.renderer.useThreadLocal=true
  lappend params -Dsun.java2d.renderer.profile=speed
  lappend params -Dsun.java2d.renderer.useRef=hard
  lappend params -Dsun.java2d.renderer.pixelWidth=2048
  lappend params -Dsun.java2d.renderer.pixelHeight=2048
  lappend params -Dsun.java2d.renderer.tileSize_log2=8
  lappend params -Dsun.java2d.renderer.tileWidth_log2=8
  lappend params -Dsun.java2d.renderer.subPixel_log2_X=2
  lappend params -Dsun.java2d.renderer.subPixel_log2_Y=2
  lappend params -Dsun.java2d.renderer.useFastMath=true
  lappend params -Dsun.java2d.render.bufferSize=524288
# lappend params -Dawt.useSystemAAFontSettings=on

  set fd [open $::tmpdir/java_args w]
  foreach item $params {puts $fd $item}
  close $fd
  lappend command $::java_cmd @$::tmpdir/java_args -jar $::server_jar
  lappend command -config [file nativename $::tmpdir]

  # Configure server

  set data terminate=true\n
  append data requestlog-format=
  if {${::log.requests}} {append data "From %{client}a Get %U%q Status %s Size %O bytes Time %{ms}T ms"}
  append data \n
  if {${::tcp.interface} == "localhost"} {append data host=localhost\n}
  set port [set ::tcp.port]
  append data port=$port\n
  append data acceptQueueSize=${::tcp.maxconn}\n

  set md5 [md5 -hex [encoding convertto utf-8 $data]]
  if {![info exists ::md5_server] || $::md5_server != $md5} {
    srv_stop
    set fd [open $::tmpdir/server.properties w]
    puts $fd $data
    close $fd
    set ::md5_server $md5
  }

  save_task_settings ${::task.active}
  foreach task ${::task.set} {
    if {$task in ${::task.use}} {srv_task_create $task} \
    else {srv_task_delete $task}
  }

  if {[process_running srv]} {
    if {$command == ${srv::command}} return
    srv_stop
  }

  set text "Mapsforge Server \[SRV\]"
  # Server not yet running: TCP port is currently in use?
  set count 0
  while {$count < 5} {
    set rc [catch {socket -server {} -myaddr 127.0.0.1 $port} fd]
    if {!$rc} break
    incr count
    after 200
  }
  if {$rc} {
    error_message [mc m59 $text $port $fd] return
    return
  }
  close $fd
  update

  # Start server

  cputi "[mc m54 $text] ..."
  cputs [get_shell_command $command]

  process_start $command srv
  set ::restart_srv 0

  # Wait until port becomes ready to accept connections or server aborts
  # Send dummy render request and wait for rendering initialization

  set url http://127.0.0.1:$port
  while {[process_running srv]} {
    if {[catch {::http::geturl $url} token]} {after 10; continue}
    set size [::http::size $token]
    ::http::cleanup $token
    if {$size} break
  }
  after 20
  update

  if {![process_running srv]} {error_message [mc m55 $text] return; return}
  set srv::port $port

}

# Mapsforge server stop

proc srv_stop {} {

  if {![process_running srv]} return
  namespace upvar srv fd fd port port

  fileevent $fd readable [regsub "action" [fileevent $fd readable] "{}"]

  set url http://127.0.0.1:$port/terminate
  if {![catch {::http::geturl $url} token]} {
    if {[::http::status $token] == "eof"} {set code 200} \
    else {set code [::http::ncode $token]}
    if {$code != 200} {process_kill srv; return}
    ::http::cleanup $token
  }
  if {![info exist ::srv.eof]} {vwait srv.eof}

}

# QMapShack start

proc qms_start {} {

  lappend command $::qms_cmd

  lappend command {*}${::qms.args}
  if {!${::qms.splash}} {lappend command --no-splash}
  if {${::qms.style} != ""} {lappend command --style ${::qms.style}}
  if {${::qms.conf} && ${::qms.file} != ""} {lappend command -c ${::qms.file}}
  if {${::qms.debug}} {lappend command -d}
  set ::env(QT_SCALE_FACTOR) ${::qms.scale}

  set name "QMapShack \[QMS\]"
  cputi "[mc m54 $name] ..."
  cputs [get_shell_command $command]

  process_start $command qms

}

# Stop QMapShack by closing its desktop window(s)
# and give process a chance to terminate itself gracefully
# before being killed forcibly

proc qms_stop {} {

  set process qms
  if {![namespace exists $process]} return
  namespace upvar $process pid pid exe exe

  cputi "[mc m56 $pid $exe] ..."

  set window_ids {}
  if {$::tcl_platform(os) == "Windows NT"} {
    # Search main desktop window of process
    set tmp $::tmpdir/tmp
    set fd [open $tmp.ps1 w]
    puts $fd "\$PROCESS = Get-Process -id $pid"
    puts $fd "\$PROCESS.MainWindowHandle | out-file -encoding ASCII \"$tmp.log\""
    close $fd
    set rc [catch {exec cmd.exe /C START /MIN powershell.exe \
	-NoProfile -ExecutionPolicy ByPass -File "$tmp.ps1"} result]
    file delete $tmp.ps1
    if {$rc} {cputw "PowerShell ended abnormally"; cputw "$result"}
    set rc [catch {open $tmp.log r} fd]
    if {$rc == 0} {
      set window_ids [read $fd]
      close $fd
    }
    file delete $tmp.log
  } elseif {$::tcl_platform(os) == "Linux"} {
    if {[auto_execok wmctrl] == ""} {
      cputw "Please install program 'wmctrl' by Linux package manager"
      cputw "to be able to close desktop windows of process '$exe'."
      return
    }
    # Search desktop windows of process and children
    set rc [catch {exec pgrep -P $pid} list]
    if {$rc} {set list $pid} else {lappend list $pid}
    foreach item $list {
      set rc [catch {open "| wmctrl -l -p | grep \" $item \"" r} fd]
      if {$rc != 0} continue
      while {[gets $fd line] != -1} {lappend window_ids [lindex $line 0]}
      catch {close $fd}
    }
  }

  if {![llength $window_ids]} {
    cputi [mc m57 $pid $exe]
    return
  }

  cputi [mc m58 $pid $exe]

  if {$::tcl_platform(os) == "Windows NT"} {
    # Send WM_CLOSE (0x0010) message to main desktop window
    set fd [open $tmp.ps1 w]
    puts $fd {$MemberDefinition = @"}
    puts $fd {[DllImport("user32.dll")]}
    puts $fd {public static extern IntPtr SendMessageTimeout(IntPtr hWnd,uint hMsg,IntPtr wParam,IntPtr lParam,uint fuFlags,uint uTimeout, IntPtr lpdwResult);}
    puts $fd {"@}
    puts $fd {Add-Type -MemberDefinition $MemberDefinition -Name Function -Namespace Win32Api}
    puts $fd "\[Win32Api.Function\]::SendMessageTimeout($window_ids,0x0010,0,0,0,5000,0)"
    close $fd
    set rc [catch {exec cmd.exe /C START /MIN powershell.exe \
	-NoProfile -ExecutionPolicy ByPass -File "$tmp.ps1"} result]
    file delete $tmp.ps1
    if {$rc} {cputw "PowerShell ended abnormally"; cputw "$result"; return}
  } elseif {$::tcl_platform(os) == "Linux"} {
    # Send WM_DELETE_WINDOW event to desktop window(s)
    foreach item $window_ids {catch {exec wmctrl -i -c $item}}
  }

  # Give process some time (max $count sec) to terminate itself
  # otherwise process will be killed
  set count 5
  while {$count>=0} {
    if {![process_running $process]} break
    update; # Process outstanding file events
    after 1000
    incr count -1
  }

}

# Show main window (at saved position)

restore_task_settings ${task.active}

wm positionfrom . program
if {[info exists window.geometry]} {
  lassign ${window.geometry} x y width height
  # Adjust horizontal position if necessary
  set x [expr max($x,[winfo vrootx .])]
  set x [expr min($x,[winfo vrootx .]+[winfo vrootwidth .]-$width)]
  wm geometry . +$x+$y
}
incr_font_size 0
wm deiconify .

# Wait for valid selection or finish

while {1} {
  vwait action
  if {$action == 0} {
    save_task_settings ${task.active}
    restore_task_settings (default)
    foreach item {global theme shading qmapshack} {save_${item}_settings}
    exit
  }
  unset action
  if {[selection_ok]} break
}

# Create server's temporary files folder

append tmpdir /[format "TMS%8.8x" [pid]]
file mkdir $tmpdir/tasks

# Create server logging properties

set fd [open $tmpdir/log4j.properties w]
puts $fd "log4j.rootLogger=INFO, stdout"
puts $fd "log4j.appender.stdout.encoding=UTF-8"
puts $fd "log4j.appender.stdout=org.apache.log4j.ConsoleAppender"
puts $fd "log4j.appender.stdout.Target=System.out"
puts $fd "log4j.appender.stdout.layout=org.apache.log4j.PatternLayout"
puts $fd "log4j.appender.stdout.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss.SSS} %m%n"
close $fd

# Get QMapShack's cache & map folder paths

if {${qms.conf} && ${qms.file} != ""} {
  set file ${qms.file}
} elseif {$tcl_platform(os) == "Windows NT"} {
  unset -nocomplain file
} elseif {$tcl_platform(os) == "Linux"} {
  set file $env(HOME)/.config/QLandkarte/QMapShack.conf
}

set list {cachePath mapPath}
lassign {} {*}$list
if {[info exists file]} {
  if {![catch {open $file r} fd]} {
    set data [split [read $fd] \n]
    close $fd
    foreach item $list {
      set index [lsearch -regexp $data "^$item="]
      if {$index < 0} continue
      regexp {^.*?=(.*)$} [lindex $data $index] "" value
      set $item [string trim [lindex [split $value ,] 0]]
    }
    unset data
  }
} else {
  foreach item $list {
    if {[catch {registry get \
	{HKEY_CURRENT_USER\SOFTWARE\QLandkarte\QMapShack\Canvas} $item} \
	value]} continue
    switch [registry type \
	{HKEY_CURRENT_USER\SOFTWARE\QLandkarte\QMapShack\Canvas} $item] {
      sz	{set $item $value}
      multi_sz	{set $item [lindex $value 0]}
    }
  }
}
foreach item $list {
  set value [set $item]
  if {$value != "" && $value != "@Invalid()"} {catch "file mkdir $value"}
}
if {![file isdirectory $cachePath] || ![file isdirectory $mapPath]} \
	{error_message [mc e06] return}
set tiles_folder $cachePath
set tms_folder $mapPath
unset {*}$list

# Start Mapsforge server

tk busy hold .qms -cursor X_cursor

busy_state 1
set restart_srv 0
srv_start

# Start QMapShack (if server is running)

if {[process_running srv]} {qms_start}
busy_state 0

# Wait for new selection or finish

bind .buttons.continue <Double-ButtonPress-1> "set restart_srv 1"

update idletasks
if {![info exists action]} {vwait action}

# Restart Mapsforge server with new settings

while {$action == 1} {
  unset action
  if {[selection_ok]} {
    busy_state 1
    srv_start
    busy_state 0
    update idletasks
  }
  if {![info exists action]} {vwait action}
}
unset action

# Stop Mapsforge server first, avoid 'sendError' exception

srv_stop

# Stop QMapShack or kill, if not terminating on request

qms_stop
if {[process_running qms]} {process_kill qms}

# Linux: work-around forcing Tcl to clean up it's background zombie processes
catch {exec /bin/true}

# Delete file Mapsforge tms file(s) and tile cache folder(s)
# Delete temporary files folder

foreach task ${task.use} {
  foreach subtask {Map Hillshading} {
    set name [regsub ".(.default)." $subtask.$task ""]
    clean_mapsforge $name
  }
}
catch {file delete -force $tmpdir}

# Unmap main toplevel window

wm withdraw .

# Save settings to folder ini_folder

save_task_settings ${task.active}
restore_task_settings (default)
foreach item {global theme shading qmapshack} {save_${item}_settings}

# Wait until output console window was closed

if {[ctsend "winfo ismapped ."]} {
  ctsend "
    write \"\n[mc m99]\b\"
    wm protocol . WM_DELETE_WINDOW {}
    bind . <ButtonRelease-3> {destroy .}
    tkwait window .
  "
}

# Done

destroy .
exit
