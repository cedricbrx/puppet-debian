node default { 
	include apt
	include repository
  	include libreoffice
	include utilities
 	include synology
	include keepassx
  	include firefox
	include thunderbird
  	include config
  	include plymouth
  	include gnome_shell_extensions
	include games
}

class repository {
	$mirror="deb http://debian.mirror.root.lu/debian/"
	$security="deb http://security.debian.org/"
	$packages="main contrib non-free"
	file {'/etc/apt/trusted.gpg.d/libdvdcss.gpg':
		owner    => root,
		group    => root,
		mode     => '644',
		source   => 'https://github.com/cedricbrx/puppet-debian/raw/master/files/etc/apt/trusted.gpg.d/libdvdcss.gpg',
		checksum => 'sha256',
		checksum_value => 'fdcea01d04c835da00132bc255d80fc14106172d489b05a7e68f1fd5e564cf88',
	}
	file {'/etc/apt/sources.list':
		owner   => root,
		group   => root,
		mode    => '644',
		content => "$mirror stretch $packages\n$security stretch/updates $packages\n$mirror stretch-updates $packages",
	}
	file {'/etc/apt/sources.list.d/libdvdcss.list':
		owner   => root,
		group   => root,
		mode    => '644',
		content => 'deb http://download.videolan.org/pub/debian/stable/ /',
	}
	file {"/etc/apt/apt.conf.d/99brandenbourger":
		owner  => root,
		group  => root,
		mode   => '644',
		source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/manifests/files/etc/apt/apt.conf.d/99brandenbourger",
		checksum => 'sha256',
		checksum_value => "acb63f0a4810573f88db892c6529ec3843a3f3273c47cd55187a07cb8b226a34",
	}
	#file {'/etc/apt/sources.list.d/virtualbox.list':
	#	owner   => root,
	#	group   => root,
	#	mode    => '644',
	#	content => 'deb http://download.virtualbox.org/virtualbox/debian stretch contrib',
	#}
}

class apt {
	require repository
	exec {"apt-update":
		command => "/usr/bin/apt-get update",
	}
	package{"unattended-upgrades":
		ensure  => installed,
		require => Exec["apt-update"],
	}
	package {"aptitude":
        	ensure => installed,
		require => Exec["apt-update"],
	}
	#file {"/usr/bin/dpkg-get":
	#	owner  => root,
	#	group  => root,
	#	mode   => '755',
	#	source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/manifests/files/usr/bin/dpkg-get",
	#	checksum => 'sha256',
	#	checksum_value => "",
	#}
}

class config {
	file {"/etc/papersize":
		owner   => root,
		group   => root,
		mode    => '644',
		content => "a4\n",
	}
	$gd = ["gnome", "gnome-core", "gnome-desktop-environment"]
	$gd.each |String $gd| {
		exec {"/usr/bin/aptitude unmarkauto '?reverse-depends($gd) | ?reverse-recommends($gd)'":
			require => Package['aptitude'],
			onlyif  => '/usr/bin/test `/usr/bin/dpkg -l | /bin/grep $gd`'
		}
	}
	exec {'accept-msttcorefonts-license':
		command => '/bin/sh -c "echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | /usr/bin/debconf-set-selections"',
		unless  => '/usr/bin/debconf-get-selections | /begrep "msttcorefonts/accepted-mscorefonts-eula.*true"'
	}
	package {'ttf-mscorefonts-installer':
		ensure => installed,
		require => Exec['accept-msttcorefonts-license']
	}
	#file {["/etc/dconf/", "/etc/dconf/db/", "/etc/dconf/db/site.d", "/etc/dconf/db/site.d/locks", "/etc/dconf/profile"]:
    	#	ensure => directory,
	#	alias  => "create_dconf_tree",
  	#}
  	#file {"/etc/dconf/profile/user":
    	#	content => "user-db:user\nsystem-db:site",
	#	require => File["create_dconf_tree"],
	#}
}

class utilities {
	require apt
	package {"pyrenamer":
		ensure => installed,
	}
	package {"fdupes":
		ensure => installed,	
	}
	package {"fslint":
		ensure => installed,
	}
	package {"unrar":
		ensure => installed,
	}
	package {"lshw":
		ensure => installed,
	}
	package {"mlocate":
		ensure => installed,
	}
	package {"vim":
		ensure => installed,
	}
	package {"hfsprogs":
		ensure => installed,
	}
	package {"curl":
		ensure => installed,
	}
}

class multimedia {
	require apt
	package {"handbrake":
		ensure => installed,
	}
	package {"shotwell":
		ensure => installed,
	}
	package {"youtube-dl":
		ensure => installed,
	}
	package {"libdvdcss":
		ensure => installed,
	}
	package {"mpv":
		ensure => purged,
	}
	package {"goobox":
		ensure => purged,
	}
	package {"gnome-dictionary":
		ensure => purged,
	}
	package {"eog":
		ensure => purged,
	}
	package {"gnome-sound-recorder":
		ensure => purged,
	}
}

class firefox {
#change to debian!!!!!!
	file {"/usr/lib/firefox-esr/firefox_brandenbourger.cfg":
 		ensure => present,
      	 	checksum => md5,
       		checksum_value => '8fc1f930e5b71bab8bafa931294556f8',
		source => "https://raw.githubusercontent.com/cedricbrx/puppet-fedora/master/files/usr/lib64/firefox/firefox_brandenbourger.cfg",
	}
	file {"/usr/lib/firefox-esr/defaults/pref/firefox_brandenbourger.js":
		source => "https://raw.githubusercontent.com/cedricbrx/puppet-fedora/master/files/usr/lib64/firefox/defaults/pref/firefox_brandenbourger.js",
        	ensure => present,
       		require => File["/usr/lib/firefox-esr/firefox_brandenbourger.cfg"],
       		checksum => md5,
        	checksum_value => 'ba2ad1fb1f70195b555339423b5a3cf3',
	}
}

class thunderbird {
	package {"thunderbird":
        	ensure => installed,
	}
	file {"/usr/lib/thunderbird/thunderbird_brandenbourger.cfg":
        	source => "https://raw.githubusercontent.com/cedricbrx/puppet-fedora/master/files/usr/lib64/thunderbird/thunderbird_brandenbourger.cfg",
		ensure => present,
		require => Package["thunderbird"],
		checksum => md5,
		checksum_value => '14ab62b9fc68f2bbb3e0b659d8dee07a',
 	}
  	file {"/usr/lib/thunderbird/defaults/pref/thunderbird_brandenbourger.js":
		source => "https://raw.githubusercontent.com/cedricbrx/puppet-fedora/master/files/usr/lib64/thunderbird/defaults/pref/thunderbird_brandenbourger.js",
		ensure => present,
		require => File["/usr/lib/thunderbird/thunderbird_brandenbourger.cfg"],
		checksum => md5,
		checksum_value => '8c164db2cedf2d4eaaa7707eb075ac1a',
    	}
    	file {"/usr/bin/mozilla-extension-manager":
		source => "https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/mozilla/mozilla-extension-manager",
		ensure => present,
		mode => "755",
		checksum => md5,
		checksum_value => 'c9aa114ca488606242f2176f1c29a1ce',
	}
    	exec {"google-calendar":
        	command => "/usr/bin/mozilla-extension-manager --global --install https://addons.mozilla.org/thunderbird/downloads/latest/provider-for-google-calendar/addon-4631-latest.xpi",
        	unless => "/usr/bin/test -e /usr/lib/thunderbird/extensions/{a62ef8ec-5fdc-40c2-873c-223b8a6925cc}",
    	}
    	exec {"gContactSync":
        	command => "/usr/bin/mozilla-extension-manager --global --install https://addons.mozilla.org/thunderbird/downloads/latest/gcontactsync/addon-8451-latest.xpi",
       		unless => "/usr/bin/test -e /usr/lib/thunderbird/extensions/gContactSync@pirules.net.xpi",
    	}
    	exec {"google-task-sync":
        	command => "/usr/bin/mozilla-extension-manager --global --install https://addons.mozilla.org/thunderbird/downloads/latest/google-tasks-sync/addon-382085-latest.xpi",
        	unless => "/usr/bin/test -e /usr/lib/thunderbird/extensions/google_tasks_sync@tomasz.lewoc.xpi",
    	}
}

class plymouth {
	require apt
	package {"plymouth-x11":
		ensure => installed,
	}
	exec {"set_default_theme":
		command => "/usr/sbin/plymouth-set-default-theme -R joy",
		onlyif  => "/usr/sbin/plymouth-set-default-theme | /bin/grep -v joy",
		require => Package['plymouth-x11'],
	}
	exec {"modify-update_grub":
		command => "/bin/sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/g' /etc/default/grub; /usr/sbin/update-grub",
		unless  => "/bin/grep splash /etc/default/grub",
		require => Exec["set_default_theme"],
	}
	#if $facts['is_gtx660'] {
	#	file {"/etc/initramfs-tools/hooks/nvidia/":
	#		owner  => root,
	#		group  => root,
	#		mode   => '755',
	#		source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/manifests/files/etc/initramfs-tools/hooks/nvidia",
	#		checksum => 'sha256',
	#		checksum_value => '',
	#		before => Exec["set_default_theme"],
	#	}
	#}
}

class libreoffice {
	require apt
	file {"/usr/lib/libreoffice/share/registry/brandenbourger.xcd":
		owner  => root,
		group  => root,
		mode   => '644',
		source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/manifests/files/usr/lib/libreoffice/share/registry/brandenbourger.xcd",
		checksum => 'sha256',
		checksum_value => 'd34fdaad1cef9322b2d3d32384b900ed4a4940a68eff23818a293e1abec0458c',
	}
	package {"libreoffice-gtk3":
        	ensure => installed,
	}
}

class synology {
    require apt
    $quickconnect_URL = $pc_owner ? {
	brand10 => 'https://brandenbourger.quickconnect.to',
	anne04 => 'https://brandenbourger.quickconnect.to',
	default => 'https://brandenbourg.quickconnect.to',
    }   
    $title_df='[Desktop Entry]'
    $terminal_df='Terminal=false'
    $type_df='Type=Application'
    $icon_df='Icon=/usr/share/icons/hicolor/64x64/apps/synology_'
    $name_df='Name=Brandenbourger'
    $exec_df='Exec=xdg-open'
#   $syn_camera="$title_df\n$terminal_df\n$type_df\n${icon_df}cameras.png\n$name_df Cameras\n$exec_df $quickconnect_URL/camera"
    $syn_video="$title_df\n$terminal_df\n$type_df\n${icon_df}video.png\n$name_df Videos\n$exec_df $quickconnect_URL/video"
    $syn_photo="$title_df\n$terminal_df\n$type_df\n${icon_df}photos.png\n$name_df Photos\n$exec_df $quickconnect_URL/photo"

#   exec {"synology-cloud-station_installation":
#       provider => shell,
#       command => "if $synology_cloud_update; then /usr/bin/dpkg-get https://dropbox/synology-cloud-station-drive-$synology_cloud_version.x86_64.deb; fi",
#       unless => "/usr/bin/dpkg -l synology-cloud-station | grep $synology_cloud_version",
#	timeout => 1800,
#   }
#   exec {"synology-assistant_installation":
#       provider => shell,
#       command => "if $synology_assistant_update; then /usr/bin/dpkg-get http://dedl.synology.com/download/Tools/Assistant/6.1-15030/Ubuntu/x86_64/synology-assistant_6.1-15030_amd64.deb; fi",
#        unless => "/usr/bin/dpkg -l synology-assistant | grep $synology_assistant_version",
#	timeout => 1800,
#    }
#    file {"/usr/share/applications/brandenbourger-cameras.desktop":
#       content => "$syn_camera",
#    }
    file {"/usr/share/applications/brandenbourger-photos.desktop":
        content => "$syn_photo",
    }
    file {"/usr/share/applications/brandenbourger-videos.desktop":
        content => "$syn_video",
    }
#    file {"/usr/share/icons/hicolor/64x64/apps/synology_cameras.png":
#        source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/files/usr/share/icons/hicolor/64x64/apps/synology_cameras.png",
#        ensure => present,
#        checksum => md5,
#        checksum_value => 'dcaad9387f02b8e9bb522c418e0580d3',
#    }
    file {"/usr/share/icons/hicolor/64x64/apps/synology_videos.png":
        source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/files/usr/share/icons/hicolor/64x64/apps/synology_videos.png",
        ensure => present,
        checksum => md5,
        checksum_value => '998653e5331a38c68f3164705e6021bd',
    }
    file {"/usr/share/icons/hicolor/64x64/apps/synology_photos.png":
        source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/files/usr/share/icons/hicolor/64x64/apps/synology_photos.png",
        ensure => present,
        checksum => md5,
        checksum_value => '1acddd4b3da197f666451c60bf5f909c',
    }
}     

class gnome_shell_extensions {
    package {"gnome-tweak-tool":
        ensure => installed,
    }
    package {"gnome-shell-extension-weather":
	ensure => purged,
    }
    package {"dconf-editor":
	ensure => installed,
    }
    file {"/usr/bin/gnomeshell-extension-manage":
        source => "https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnomeshell-extension-manage",
        ensure => present,
        mode => "755",
        checksum => md5,
        checksum_value => '7e43f7f6ffb78caa349f41a6abc12d69',
    }
    exec {"dash-to-dock":
        command => "/usr/bin/gnomeshell-extension-manage --install --system --extension-id 307",
        require => File["/usr/bin/gnomeshell-extension-manage"],
        unless => "/usr/bin/test -e /usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/",
    }
    exec {"topicons-plus":
        command => "/usr/bin/gnomeshell-extension-manage --install --system --extension-id 1031",
        require => File["/usr/bin/gnomeshell-extension-manage"],
        unless => "/usr/bin/test -e /usr/share/gnome-shell/extensions/TopIcons@phocean.net/",
    }
    exec {"suspend-button":
        command => "/usr/bin/gnomeshell-extension-manage --install --system --extension-id 826",
        require => File["/usr/bin/gnomeshell-extension-manage"],
        unless => "/usr/bin/test -e /usr/share/gnome-shell/extensions/suspend-button@laserb/",
    }
    exec {"remove-dropdown-arrows":
        command => "/usr/bin/gnomeshell-extension-manage --install --system --extension-id 800",
        require => File["/usr/bin/gnomeshell-extension-manage"],
        unless => "/usr/bin/test -e /usr/share/gnome-shell/extensions/remove-dropdown-arrows@mpdeimos.com/",
    }
}

class keepassx {
    require apt
    package {"keepassx":
        ensure => installed,
    }
}

#class mstcorefonts {
#	require apt

#	if $network_vendor == 'realtek' {
#		if $wireless_vendor == 'intel' {
#			$firmware_packages = ['firmware-iwlwifi','firmware-realtek','firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
#		}
#		else {
#			$firmware_packages = ['firmware-realtek','firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
#		}
#	}	
#	elsif $network_vendor == 'intel' {
#		if $wireless_vendor == 'realtek' {
#			$firmware_packages = ['firmware-realtek','firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
#		}
#		elsif $wireless_vendor == 'intel' {
#			$firmware_packages = ['firmware-iwlwifi','firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
#		}
#	}
#	else {
#		$firmware_packages = ['firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
#	}
#	package {$firmware_packages:
#		ensure => installed,
#	}
#	if $network_r8168 {
#		package {"dkms":
#			ensure => installed,
#		}
#		package {"r8168":
#			ensure  => installed,
#			name => "r8168-dkms",
#			source  => "/etc/puppet/manifests/files/r8168-dkms_8.042.00-2_all.deb",
#			require => Package["dkms"],
#		}
#	}
#}

class games {
	package {"gnome-games":
		ensure => purged,
	}
	package {"aisleriot":
		ensure => purged,
	}
	package {"gnome-tetravex":
		ensure => purged,
	}
	package {"four-in-a-row":
		ensure => purged,
	}
	package {"gnome-chess":
		ensure => purged,
	}
	package {"gnome-mahjongg":
		ensure => purged,
	}
	package {"gnome-sudoku":
		ensure => purged,
	}
	package {"five-or-more":
		ensure => purged,
	}
	package {"gnome-nibbles":
		ensure => purged,
	}
	package {"gnome-mines":
		ensure => purged,
	}
	package {"quadrapassel":
		ensure => purged,
	}
	package {"hitori":
		ensure => purged,
	}
	package {"iagno":
		ensure => purged,
	}
	package {"gnome-taquin":
		ensure => purged,
	}
	package {"gnome-robots":
		ensure => purged,
	}
	package {"gnome-klotski":
		ensure => purged,
	}
	package {"swell-foop":
		ensure => purged,
	}
	package {"lightsoff":
		ensure => purged,
	}
}

#class remove {
#	require gnome_dependencies
#	package {"inkscape":
#		ensure => purged,
#	}
#	package {"gnome-orca":
#		ensure => purged,
#	}
#	package {"transmission-common":
#		ensure => purged,
#	}
#	package {"hamster-applet":
#		ensure => purged,
#	}
#	package {"evolution-common":
#		ensure => purged,
#	}
#	package {"bsd-mailx":
#		ensure => purged,
#	}
#	package {"mutt":
#		ensure => purged,
#	}
#	package {["exim4-base","exim4-config"]:
#		ensure => purged,
#	}
#	package {"synaptic":
#		ensure => purged,
#	}
#	package {"vinagre":
#		ensure => purged,
#	}
#	package {"vino":
#		ensure => purged,
#	}
#	package {"tali":
#		ensure => purged,
#	}
#	package {["xboard","fairymax","hoichess"]:
#		ensure => purged,
#	}
#	package {"bijiben":
#		ensure => purged,
#	}
#	package {"empathy-common":
#		ensure => purged,
#	}
#	package {"polari":
#		ensure => purged,
#	}
#	package {"gnome-nettool":
#		ensure => purged,
#	}
#	package {"rhythmbox-data":
#		ensure => purged,
#	}
#}
