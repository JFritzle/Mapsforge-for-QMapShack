# Mapsforge-for-QMapShack
Graphical user interface between Mapsforge tile server and QMapShack 

### About
QMapShack currently does not support local Mapsforge maps out of the box. Prebuilt Mapsforge maps are provided amongst others by [mapsforge.org](http://download.mapsforge.org) and [openandromaps.org](https://www.openandromaps.org). 

QMapShack however is able to handle maps provided as tiles by a [Tile Map Service](https://en.wikipedia.org/wiki/Tile_Map_Service) (TMS), which is mainly used by web mapping tile servers. To make local Mapsforge maps nevertheless available within QMapShack, a local tile server can be set up to render these Mapsforge maps and to interact with QMapShack via TMS protocol. The corresponding Mapsforge tile server is available at this [mapsforgesrv](https://github.com/telemaxx/mapsforgesrv) repository.  

### Graphical user interface
This project’s intension is to easily let the user interactively and comfortably select the numerous available options of Mapsforge tile server. In addition, option settings as well as position and font size of graphical user interface automatically get saved and restored. Mapsforge tile server and QMapShack get started/restarted using these options without need to manually set up any configuration files. 

Graphical user interface is a single script written in _Tcl/Tk_ scripting language and is executable on _Microsoft Windows_ and _Linux_ operating system. Language-neutral script file _Mapsforge-for-QMapShack.tcl_ requires an additional user settings file and at least one localized resource file. Additional files must follow _Tcl/Tk_ syntax rules too. 

User settings file is named _Mapsforge-for-QMapShack.ini_. A template file is provided.

Resource files are named _Mapsforge-for-QMapShack.<locale\>_, where _<locale\>_ matches locale’s 2 lowercase letters ISO 639-1 code. English localized resource file _Mapsforge-for-QMapShack.en_, French localized resource file _Mapsforge-for-QMapShack.fr_ and German localized resource file _Mapsforge-for-QMapShack.de_ are provided. Script can be easily localized to any other system’s locale by providing a corresponding resource file using English resource file as a template. 

Screenshot of graphical user interface: 
![GUI_Windows](https://github.com/user-attachments/assets/461700db-a89f-4117-92db-bdfd5aa09e4a)


### Installation

1.	**QMapShack**  
**Windows**: If not yet installed, download and install latest QMapShack version from [download section](https://github.com/Maproom/qmapshack/releases).  
**Linux**: If not yet installed, install QMapShack package using Linux package manager.  
(Ubuntu: _apt install qmapshack gdal-bin gdal-data proj-bin proj-data routino_)  
**Note**: Run QMapShack at least once and initialize map & cache folders by _File -> Setup Map Paths_ before using _Mapsforge-for-QMapShack_.  

2.	**Java runtime environment (JRE) or Java development kit (JDK)**  
JRE version 11 or higher is required. JRE version 17 or higher is recommended.  
Each JDK contains JRE as subset.  
**Windows**: If not yet installed, download and install JRE or JDK, e.g. from [Oracle](https://www.java.com), [OpenLogic](https://www.openlogic.com/openjdk-downloads) or [Adoptium](https://adoptium.net/de/temurin/releases).  
**Linux**: If not yet installed, install JRE or JDK using Linux package manager.  
(Ubuntu: _apt install openjdk-<version\>-jre_ or _apt install openjdk-<version\>-jdk_ with required or newer _<version\>_)  
**macOS**: If not yet installed, install JDK using _Homebrew_ package manager by _brew install java_.  

3.	**Mapsforge tile server**  
Open [mapsforgesrv releases](https://github.com/telemaxx/mapsforgesrv/releases).  
Download most recently released jar file _mapsforgesrv-fatjar.jar_ from _<release\>\_for\_java11_tasks_ assets.  
**Windows**: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _%ProgramFiles%/MapsforgeSrv_.  
**Linux** / **macOS**: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  
**Note**: Mapsforge tile server version 0.22.0.0 or higher is required.  

4. **Alternative Marlin rendering engine** (optional, recommended)  
[Marlin](https://github.com/bourgesl/marlin-renderer) is an open source Java2D rendering engine optimized for performance, replacing the standard built into Java. Download is available at [Marlin-renderer releases](https://github.com/bourgesl/marlin-renderer/releases).  
For JRE version lower than 17, download jar file _marlin-\*.jar_  
from _Marlin-renderer \<latest version> for JDK11+_ section's assets.  
For JRE version 17 or higher, download jar file _marlin-\*.jar_  
from _Marlin-renderer \<latest version> for JDK17+_ section's assets.  
**Windows**: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _%ProgramFiles%/MapsforgeSrv_.  
**Linux** / **macOS**: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  

5.	**Tcl/Tk scripting language version 8.6 or higher binaries**  
**Windows**: Download and install latest stable version of Tcl/Tk, currently 9.0.  
See https://wiki.tcl-lang.org/page/Binary+Distributions for available binary distributions. Recommended Windows binary distribution is from [teclab’s tcltk](https://gitlab.com/teclabat/tcltk/-/packages) Windows repository. Select most recent installation file _tcltk90-9.0.\<x.y>.Win10.nightly.\<date>.tgz_. Unpack zipped tar archive (file extension _.tgz_) into your Tcl/Tk installation folder, e.g. _%ProgramFiles%/Tcl_.  
Note: [7-Zip](https://www.7-zip.org) file archiver/extractor is able to unpack _.tgz_ archives.   
**Linux**: Install packages _tcl, tcllib, tcl-thread, tk_, _tklib_, _x11-utils_  and _wmctrl_ using Linux package manager. 
(Ubuntu: _apt install tcl tcllib tcl-thread tk tklib_ _x11-utils_ _wmctrl_)   
**macOS**: If not yet installed, install _tcl-tk_ using _Homebrew_ package manager by _brew install tcl-tk_. Unfortunately, _tklib_ containing required package _tooltip_ is not part of _tcl-tk_. Advanced users can either download _tklib0.9_ from [sourceforge.net](https://sourceforge.net/projects/tcllib/files/tklib/0.9) and install into folder _\<root>/Cellar/tcl-tk/\<version>/lib/tklib0.9_. Alternatively and easier: download Windows distribution mentioned above, extract subfolder _tklib0.9_ from archive and install as folder _\<root>/Cellar/tcl-tk/\<version>/lib/tklib0.9_.  

6.	**Mapsforge maps**  
Download Mapsforge maps for example from [openandromaps.org](https://www.openandromaps.org). Each downloaded OpenAndroMaps map archive contains a map file (file extension _.map_).   
**Note**:  
Mapsforge tile server itself does not use points-of-interest files (POI, file extension _.poi_) supplied for download there. As QMapShack is not able to handle this kind of POI files, QMapShack suitable POI files can be found [here](https://ftp.gwdg.de/pub/misc/openstreetmap/openandromaps/pois/mapsforge_old).  

7.	**Mapsforge themes**  
Mapsforge themes _Elevate_ and _Elements_ (file extension _.xml_) suitable for OpenAndroMaps are available for download at [openandromaps.org](https://www.openandromaps.org).  
**Note**:  
In order "Hillshading on map" to be applied to rendered map tiles, hillshading has to be enabled in theme file too. _Elevate_ and _Elements_ themes version 5 or higher do enable hillshading.  

8. **DEM data** (optional, required for hillshading)  
Download and store DEM (Digital Elevation Model) data for the regions to be rendered.  
**Notes**:  
Either HGT files or ZIP archives containing 1 single equally named HGT file may be supplied.  
Example: ZIP archive N49E008.zip containing 1 single HGT file N49E008.hgt.  
While 1\" (arc second) resolution DEM data have a significantly higher accuracy than 3\" resolution, hillshading assumes significantly much more time. Therefore 3\" resolution usually is better choice.  
    
   \- HGT files with 3\" resolution SRTM (Shuttle Radar Topography Mission) data are available for whole world at [viewfinderpanoramas.org](http://www.viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org3.htm). Unzip downloaded ZIP files to DEM folder.  
\- HGT files with 1\" resolution DEM data are available for selected regions at [viewfinderpanoramas.org](http://www.viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org1.htm). Unzip downloaded ZIP files to DEM folder.  
\- ZIP archives with 3\" and 1\" resolution compiled and resampled by Sonny are available for selected regions at [Sonny's Digital LiDAR Terrain Models of European Countries](https://sonny.4lima.de). LiDAR data where available are more precise than SRTM data. Store downloaded ZIP files to DEM folder.  

9.	**Mapsforge for QMapShack graphical user interface script**  
Download language-neutral script file _Mapsforge-for-QMapShack.tcl_, user settings file _Mapsforge-for-QMapShack.ini_ and at least one localized resource file.  
**Windows**: Copy downloaded files into Mapsforge tile server’s installation folder, e.g. into folder _%ProgramFiles%/MapsforgeSrv_.  
**Linux** / **macOS**: Copy downloaded files into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  
**Note**: Edit _user-defined script variables settings section_ of user settings file _Mapsforge-for-QMapShack.ini_ to match files and folders of your local installation of Java, Mapsforge tile server and QMapShack. Always use character slash “/” as directory separator in _Mapsforge-for-QMapShack.ini_ file, for Microsoft Windows too!  

### Script file execution

**Windows**:  
Associate file extension _.tcl_ to Tcl/Tk window shell’s binary _wish.exe_. Right-click script file and open file’s properties window. Change data type _.tcl_ to be opened by _Wish application_ e.g. by executable _%ProgramFiles%/Tcl/bin/wish.exe_. Once file extension has been associated, double-click script file to run.  

**Linux**:  
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
or associate file extension _.tcl_ to Tcl/Tk window shell’s binary _/usr/bin/wish_ to run script file by double-click file in file manager.  

**macOS**:  
Either run script file from command line by
```
wish <path-to-script>/Mapsforge-for-QMapShack.tcl
```

or use _Automator -> Application -> Run Shell Script -> /usr/local/bin/wish \"$@\"_ to create an application for Tcl/Tk window shell’s binary _wish_, then associate all _.tcl_ files to this application and run script file by double-click file in file manager.

Having _.tcl_ files associated to this application, a desktop starter from script file can be created by _Make Alias_ and dragging the alias and dropping it to desktop.  

### Usage

* After selecting tasks(s), map(s), theme file, theme style, style's overlays etc. in graphical user interface, hit _Start_ button to start Mapsforge tile server and QMapShack. When QMapShack has started successfully, activate QMapShack's map(s) _Mapsforge Map …_ to show map(s) and/or _Mapsforge Hillshading …_ to show hillshading selected in graphical user interface. When changing settings while QMapShack is running, a reload of maps is required to adopt new settings. To reload, first hit _Start_ button again and QMapShack's tile cache containing tiles already loaded with previous settings gets cleared.
Second, right-click QMapShack's maps list and force QMapShack to reload maps.
* Closing either graphical user interface or QMapShack window also closes Mapsforge tile server.
* Use keyboard keys Ctrl-plus to increase and keyboard keys Ctrl-minus to decrease font size of graphical user interface and/or output console.
* See output console for Mapsforge tile server’s and QMapShack's output.

### Example

Screenshot of QMapShack showing Heidelberg (Germany) and using
* OpenAndroMaps map file _Germany_oam.osm.map_
* OpenAndroMaps poi file _Germany_oam.osm.poi_ showing _Accommodations -> Hotel,Guest Houses_
* OpenAndroMaps rendering theme _Elevate_
* Theme file's style _elv-hiking_ aka _Hiking_ 
* Style's default overlays plus additional overlay _elv-waymarks_ aka _Waymarks_
* Hillshading settings as above

![Heidelberg](https://github.com/user-attachments/assets/2d15cb64-2f9e-439a-a20a-79fff1f81532)

### Hints

* Output console  
While console output of Mapsforge tile server and/or QMapShack can be informative and helpful to verify what is happening as well as to analyze errors, writing to console costs some performance. Therefore the console should be hidden if not needed. 
* Built-in world map  
Since the built-in [Mapsforge world map](https://download.mapsforge.org/maps/world/world.map) only shows the coastline, it only serves as a rough overview. Due to map's low resolution, coastlines show inaccurate at high resolution.  
In order not to cover an accurate map, the built-in world map has been automatically deactivated at higher zoom levels.   
Starting with Mapsforge tile server version 0.23.0.3, built-in world map is rendered with lower priority than user-defined accurate maps. Zoom level restriction was therefore removed. 
* Hillshading  
  * When selecting "Hillshading on map", map and hillshading are rendered  into one single map.  
Same result can be achieved faster by not enabling hillshading in graphical user interface but enabling QMapShack's built-in hillshading.
  * When selecting "Hillshading as map", map and hillshading are rendered as two separate maps. Post-processing hillshading, gray value of flat area gets mapped to full transparency. Thus the flatter the area, the more the original colors of the map shine through. Finally, hillshading can be used as an alpha-transparent overlay for any map.  
[OpenTopoMap](https://opentopomap.org) uses same hillshading technique as hillshading algorithm "diffuselight".  
Activate <ins>first</ins> QMapShack's maps "Mapsforge Map" and <ins>second</ins> "Mapsforge Hillshading" if "Hillshading as map" was selected. Former shows map tiles without hillshading, latter shows hillshading as alpha-transparent overlay. Map "Mapsforge Hillshading" can also be used as overlay for other maps not containing hillshading, e.g. OpenStreetMap.  
Same result can not be achieved by QMapShack's built-in hillshading
* If QMapShack is showing rendered Mapsforge map a bit blurry, then within QMapShack  
  * first open “View -> Setup Map View” and set “Scale” to “Square”  
  * then hit “symbol grid” button at upper right corner above and set “Projection” to “World Mercator (OSM)”  
   As with QMapShack 1.17.1, projection “World Mercator (OSM)” built-in settings have been changed. As a workaround for QMapShack 1.17.1, replace “Projection & Datum” string manually from `EPSG:3857` to  
      `+proj=merc +a=6378137 +b=6378137 +lat_ts=0.001 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs +type=crs`  
  This workaround is no longer required for QMapShack 1.18.0 or newer.
 



