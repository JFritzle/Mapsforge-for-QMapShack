# Mapsforge-for-QMapShack
Graphical user interface between Mapsforge tile server and QMapShack 

### Preliminary
QMapShack currently does not support local Mapsforge maps out of the box. Prebuilt Mapsforge maps are provided amongst others by [mapsforge.org](http://download.mapsforge.org) and [openandromaps.org](https://www.openandromaps.org). 

QMapShack however is able to handle maps provided as tiles by a [Tile Map Service](https://en.wikipedia.org/wiki/Tile_Map_Service) (TMS), which is mainly used by web mapping servers. To make local Mapsforge maps nevertheless available within QMapShack, a local tile server can be set up to render these Mapsforge maps and to interact with QMapShack via TMS protocol. The corresponding tile server is available at this [mapsforgesrv](https://github.com/telemaxx/mapsforgesrv) repository.  

Section [Mapsforge Maps](https://github.com/Maproom/qmapshack/wiki/DocBasicsMapDem#user-content-mapsforge-maps) of QMapShack’s wiki shortly describes how to set up this tile server and manually connect it to QMapShack by an appropriate TMS file. 

### Graphical user interface
This project’s intension is to easily let the user interactively and comfortably select the numerous available options of tile server. In addition, option settings as well as position and font size of graphical user interface automatically get saved and restored. Tile server and QMapShack get started/restarted using these options without need to manually set up any configuration files. 

Graphical user interface is a single script written in _Tcl/Tk_ scripting language and is executable on _Microsoft Windows_ and _Linux_ operating system. Language-neutral script file _Mapsforge-for-QMapShack.tcl_ an additional user settings file and at least one localized resource file. Additional files must follow _Tcl/Tk_ syntax rules too. 

User settings file is named is named _Mapsforge-for-QMapShack.ini_. A template file is provided.

Resource files are named _Mapsforge-for-QMapShack.<locale\>_, where _<locale\>_ matches locale’s 2 lowercase letters ISO 639-1 code. English localized resource file _Mapsforge-for-QMapShack.en_ and German localized resource file _Mapsforge-for-QMapShack.de_ are provided. Script can be easily localized to any other system’s locale by providing a corresponding resource file using English resource file as a template. 

Screenshot of graphical user interface on Microsoft Windows operating system: 
![GUI_Windows](https://user-images.githubusercontent.com/62614244/160844887-4ea08f4f-538a-4aa6-bf5b-c98705989780.png)

Screenshot of graphical user interface on Linux operating system (Ubuntu):
![GUI_Linux](https://user-images.githubusercontent.com/62614244/160844901-4584a473-54e8-4eb1-adf7-a87bea3d9337.png)

### Installation

1.	QMapShack  
Windows: If not yet installed, download and install latest QMapShack version from [download section](https://github.com/Maproom/qmapshack/releases).  
Linux: If not yet installed, install QMapShack package using Linux package manager.  
(Ubuntu: _apt install qmapshack gdal-bin gdal-data proj-bin proj-data routino_)

2.	Java runtime environment version 8 or higher   
Windows: If not yet installed, download and install Java, e.g. from [Oracle](https://www.java.com).  
Linux: If not yet installed, install Java runtime package using Linux package manager.  
(Ubuntu: _apt install openjdk-version-jre_ where _version_ is 8 or higher)

3.	Mapsforge tile server  
Open [mapsforgesrv](https://github.com/telemaxx/mapsforgesrv) repository.  
For Java version 11 or higher, switch branch to _master_, navigate to folder _mapsforgesrv/bin/jars_ready2use_ and download jar file _mapsforgesrv-fatjar.jar_.  
For Java version 8 (or higher), switch branch to _Java8_, navigate to folder _mapsforgesrv/bin/jars_ready2use_ and download jar file _mapsforgesrv4java8.jar_.  
Windows: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _%programfiles%/MapsforgeSrv_.  
Linux: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  
Note: Mapsforge tile server version 0.16.3 or higher is required for hillshading. Otherwise hillshading cannot be enabled by graphical user interface.

4. Alternative Marlin rendering engine (optional)  
Open [mapsforgesrv](https://github.com/telemaxx/mapsforgesrv) repository.  
For Java version 11 or higher, switch branch to _master_, navigate to folder _mapsforgesrv/libs_ and download jar file(s) _marlin-*.jar_.  
For Java version 8, switch branch to _Java8_, navigate to folder _mapsforgesrv/bin/jars_ready2use_ and download jar file(s) _marlin-*.jar_.  
Windows: Copy downloaded jar file(s) into Mapsforge tile server’s installation folder, e.g. into folder _%programfiles%/MapsforgeSrv_.  
Linux: Copy downloaded jar file(s) into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  
Note: [Marlin](https://github.com/bourgesl/marlin-renderer) is an open source Java2D rendering engine optimized for performance. Mapsforge tile server version 0.17.0 or higher is required for alternative renderer engine. Otherwise alternative renderer engine cannot be enabled by graphical user interface.

5.	Tcl/Tk scripting language version 8.6 or higher binaries  
Windows: Download and install latest stable version of Tcl/Tk. See https://wiki.tcl-lang.org/page/Binary+Distributions for available binary distributions. Recommended distribution is [teclab’s tcltk](https://github.com/teclab-at/tcltk/tree/tcl86/releases) repository. First select most recent installation file _tcltk86-8.6.x.y.tcl86.Win10.x86_64.tgz_, then press _Download_ button. Unpack zipped tar archive (file extension _.tgz_) into your Tcl/Tk installation folder, e.g. _%programfiles%/Tcl_.  
Linux: Install packages _tcl, tcllib, tk_ and _tklib_ using Linux package manager. Package _tklib_ is required for tooltips. 
(Ubuntu: _apt install tcl tcllib tk tklib_)

6.	Mapsforge maps  
Download Mapsforge maps for example from [openandromaps.org](https://www.openandromaps.org).  
Each downloaded OpenAndroMaps map archive contains a map file (file extension _.map_) and a points-of-interest file (file extension _.poi_). Tile server will render the former file, QMapShack is able to handle the latter file by itself.  
Note: Mapsforge tile server version 0.17.4 or higher is required for optionally appending built-in Mapsforge world map.

7.	Mapsforge themes  
Mapsforge themes _Elevate_ and _Elements_ (file extension _.xml_) suitable for OpenAndroMaps are available for download at [openandromaps.org](https://www.openandromaps.org).  
Note: In order hillshading to be applied to rendered map tiles, hillshading has to be enabled in theme file too. _Elevate_ and _Elements_ themes version 5 or higher do enable hillshading.

8. DEM data (optional, required for hillshading)  
Download and store HGT files with DEM (Digital Elevation Model) data for the regions to be rendered. HGT files with 3 arc seconds resolution are available for example at [viewfinderpanoramas.org](http://www.viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org3.htm).

9.	Mapsforge for QMapShack graphical user interface script  
Download language-neutral script file _Mapsforge-for-QMapShack.tcl_, user settings file _Mapsforge-for-QMapShack.ini_ and at least one localized resource file.  
Windows: Copy downloaded files into Mapsforge tile server’s installation folder, e.g. into folder _%programfiles%/MapsforgeSrv_.  
Linux: Copy downloaded files into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  
Edit _user-defined script variables settings section_ of user settings file _Mapsforge-for-QMapShack.ini_ to match files and folders of your local installation of Java, Mapsforge tile server and QMapShack. Important: Always use character slash “/” as directory separator in script, for Microsoft Windows too!

### Script file execution

Windows:  
Associate file extension _.tcl_ to Tcl/Tk window shell’s binary _wish.exe_. 
Right-click script file and open file’s properties window. Change data type _.tcl_ to get opened by _Wish application_ e.g. by executable _%programfiles%/Tcl/bin/wish.exe_.  
Once file extension has been associated, double-click file to run script.

Linux:  
Either run script file from command line by
```
wish <path-to-script>/Mapsforge-for-QMapShack.tcl
```
or create a desktop starter file _Mapsforge-for-QMapShack.desktop_
```
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=Mapsforge-for-QMapShack
Exec=wish <path-to-script>/Mapsforge-for-QMapShack.tcl
```
or associate file extension _.tcl_ to Tcl/Tk window shell’s binary _/usr/bin/wish_ and run script file by double-click file in file manager.

After selecting map(s), theme file, theme style, style's overlays etc. in graphical user interface, hit _Start_ button to start tile server and QMapShack. After QMapShack has started successfully, activate QMapShack's map _Mapsforge_ to show map(s) selected in graphical user interface. If changing any settings while QMapShack is running, a restart of tile server is required to adopt new option settings. To restart, hit _Start_ button again. As QMapShack is caching tiles already loaded with previous settings, it is necessary to clear QMapShack's tile cache. This is achieved by right-clicking QMapShack's maps list and force QMapShack to reload maps. Closing either graphical user interface or QMapShack window will close tile server too.

Use keyboard keys Ctrl-plus to increase and keyboard keys Ctrl-minus to decrease font size of graphical user interface and/or output console.

### Example

Screenshot of QMapShack showing Nuremberg (Germany) and using
* OpenAndroMaps map file _Germany_oam.osm.map_
* OpenAndroMaps poi file _Germany_oam.osm.poi_ showing _Accommodations_
* OpenAndroMaps rendering theme _Elevate_
* Theme file's style _elv-hiking_ aka _Hiking_ 
* Style's default overlays plus additional overlay _elv-waymarks_ aka _Waymarks_
* Hillshading _not_ enabled in contrast to settings shown above

![Nuremberg](https://user-images.githubusercontent.com/62614244/124951039-431e6d00-e013-11eb-8d36-93af148c0a05.png)

### Hints
If QMapShack is showing rendered Mapsforge map a little blurred, then within QMapShack
*	first open “View -> Setup Map View” and set “Scale” to “Square”  
*	then hit “symbol grid” button at upper right corner above and set “Projection” to “World Mercator (OSM)”
