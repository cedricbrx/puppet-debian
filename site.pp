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
	include mailclients
	include chat
	include remove
	include masterpdfeditor
}

class repository {
	$mirror="deb http://debian.mirror.root.lu/debian/"
	$security="deb http://security.debian.org/"
	$packages="main contrib non-free"
	file {'/etc/apt/trusted.gpg.d/libdvdcss.gpg':
		source   => 'https://github.com/cedricbrx/puppet-debian/raw/master/files/etc/apt/trusted.gpg.d/libdvdcss.gpg',
		ensure => present,
		checksum => sha256,
		checksum_value => 'fdcea01d04c835da00132bc255d80fc14106172d489b05a7e68f1fd5e564cf88',
	}
	file {'/etc/apt/trusted.gpg.d/brandenbourger.gpg':
		source   => 'https://github.com/cedricbrx/puppet-debian/raw/master/files/etc/apt/trusted.gpg.d/brandenbourger.gpg',
		ensure => present,
		checksum => sha256,
		checksum_value => '1f36daf59e021d10d53d9aedb5d784db59ce2d73c01594352eb9c6b809a70161',
	}
	file {'/etc/apt/sources.list':
		ensure => present,
		owner   => root,
		group   => root,
		mode    => '644',
		content => "$mirror stretch $packages\n$security stretch/updates $packages\n$mirror stretch-updates $packages",
	}
	file {'/etc/apt/sources.list.d/libdvdcss.list':
		ensure => present,
		owner   => root,
		group   => root,
		mode    => '644',
		require => File['/etc/apt/trusted.gpg.d/libdvdcss.gpg'],
		content => 'deb http://download.videolan.org/pub/debian/stable/ /',
	}
	file {'/etc/apt/sources.list.d/brandenbourger.list':
		ensure => present,
		owner   => root,
		group   => root,
		mode    => '644',
		require => File['/etc/apt/trusted.gpg.d/brandenbourger.gpg'],
		content => 'deb https://raw.githubusercontent.com/cedricbrx/packages/master/ stretch main',
	}
	package {'apt-transport-https':
		ensure => installed,
	}
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
	file {'/etc/apt/apt.conf.d/99brandenbourger':
		ensure => present,
		owner   => root,
		group   => root,
		mode    => '644',
		require => Package["unattended-upgrades"],
		source => 'https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/files/etc/apt/apt.conf.d/99brandenbourger',
		checksum => sha256,
		checksum_value => 'acb63f0a4810573f88db892c6529ec3843a3f3273c47cd55187a07cb8b226a34',
	}
	package {"debconf-utils":
        	ensure => installed,
		require => Exec["apt-update"],
	}
	package {"aptitude":
        	ensure => installed,
		require => Exec["apt-update"],
	}
}

class config {
	require apt
	file {"/etc/papersize":
		owner   => root,
		group   => root,
		mode    => '644',
		content => "a4\n",
	}
	$gd = ["gnome", "gnome-core", "gnome-desktop-environment"]
	$gd.each |String $gd| {
		exec {"/usr/bin/aptitude unmarkauto '?reverse-depends($gd) | ?reverse-recommends($gd)'":
			onlyif => '/usr/bin/dpkg-query -W -f="${Status}" "$gd" 2>/dev/null | /bin/grep -c "ok installed"',
		}
	}
	exec {'accept-msttcorefonts-license':
		command => '/bin/sh -c "echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | /usr/bin/debconf-set-selections"',
		unless  => '/usr/bin/debconf-get-selections | /bin/grep "msttcorefonts/accepted-mscorefonts-eula.*true"',
	}
	package {'ttf-mscorefonts-installer':
		ensure => installed,
		require => Exec['accept-msttcorefonts-license'],
	}
	file {"/etc/dconf/":
    		ensure => directory,
  	}
	file {"/etc/dconf/profile":
    		ensure  => directory,
		require => File["/etc/dconf"],
  	}
	file {["/etc/dconf/db/", "/etc/dconf/db/site.d", "/etc/dconf/db/site.d/locks"]:
		ensure  => directory,
		require => File["/etc/dconf"],
	}
  	file {"/etc/dconf/profile/user":
    		content => "user-db:user\nsystem-db:site",
		require => File["/etc/dconf/profile"],
	}
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
	package {"meld":
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
	package {"rhythmbox-data":
		ensure => purged,
	}
	package {"inkscape":
		ensure => purged,
	}
}

class firefox {
	file {"/usr/lib/firefox-esr/firefox_brandenbourger.cfg":
 		ensure => present,
      	 	checksum => sha256,
       		checksum_value => '345259392f685fb0d41e0994e376799021cd4fe1e69656137e34c49e2e344fec',
		source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/files/usr/lib/firefox-esr/firefox_brandenbourger.cfg",
	}
	file {"/usr/lib/firefox-esr/defaults/pref/firefox_brandenbourger.js":
		source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/files/usr/lib/firefox-esr/defaults/pref/firefox_brandenbourger.js",
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
        	source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/files/usr/lib/thunderbird/thunderbird_brandenbourger.cfg",
		ensure => present,
		require => Package["thunderbird"],
		checksum => md5,
		checksum_value => '14ab62b9fc68f2bbb3e0b659d8dee07a',
 	}
  	file {"/usr/lib/thunderbird/defaults/pref/thunderbird_brandenbourger.js":
		source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/files/usr/lib/thunderbird/defaults/pref/thunderbird_brandenbourger.js",
		ensure => present,
		require => File["/usr/lib/thunderbird/thunderbird_brandenbourger.cfg"],
		checksum => sha256,
		checksum_value => '2bd233475a28ff7061ccafa7b1269962443f635c461482de4f1e6f3792542423',
    	}
	package {"xul-ext-google-tasks-sync":
        	ensure => installed,
		require => Package["thunderbird"],
	}
	#package {"xul-ext-gcontactsync":
        #	ensure => installed,
	#	require => Package["thunderbird"],
	#}
	package {"calendar-google-provider":
        	ensure => installed,
		require => Package["thunderbird"],
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
			#checksum => 'sha256',
			#checksum_value => '',
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
		checksum => sha256,
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
    $syn_camera="$title_df\n$terminal_df\n$type_df\n${icon_df}cameras.png\n$name_df Cameras\n$exec_df $quickconnect_URL/camera"
    $syn_video="$title_df\n$terminal_df\n$type_df\n${icon_df}videos.png\n$name_df Videos\n$exec_df $quickconnect_URL/video"
    $syn_photo="$title_df\n$terminal_df\n$type_df\n${icon_df}photos.png\n$name_df Photos\n$exec_df $quickconnect_URL/photo"
    package {"synology-cloud-station":
        ensure => installed,
    }
    package {"synology-assistant":
        ensure => installed,
    }
    file {"/usr/share/applications/brandenbourger-cameras.desktop":
        content => "$syn_camera",
    }
    file {"/usr/share/applications/brandenbourger-photos.desktop":
        content => "$syn_photo",
    }
    file {"/usr/share/applications/brandenbourger-videos.desktop":
        content => "$syn_video",
    }
    file {"/usr/share/icons/hicolor/64x64/apps/synology_cameras.png":
        source => "https://raw.githubusercontent.com/cedricbrx/puppet-debian/master/files/usr/share/icons/hicolor/64x64/apps/synology_cameras.png",
        ensure => present,
        checksum => sha256,
        checksum_value => '29da1525a33cc4f4702d29bcdee9ab89b52bd86b31fa0c2635687e366dbe3825',
    }
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
    package {"gnome-shell-extension-dashtodock":
	ensure => installed,
    }
    package {"gnome-shell-extension-log-out-button":
	ensure => installed,
    }
    package {"gnome-shell-extension-remove-dropdown-arrows":
	ensure => installed,
    }
    package {"gnome-shell-extension-suspend-button":
	ensure => installed,
    }
    package {"gnome-shell-extension-top-icons-plus":
	ensure => installed,
    }
}

class keepassx {
    require apt
    package {"keepassx":
        ensure => installed,
    }
}

class firmware {
	require apt
	package { $facts[$firmware_install]:
		ensure => installed,
	}
	if $facts[$is_R8168] {
		package {"r8168-dkms":
			ensure  => installed,
		}
	}
}

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
	package {"tali":
		ensure => purged,
	}
	package {["xboard","fairymax","hoichess"]:
		ensure => purged,
	}
}

class mailclients {
	package {"evolution-common":
		ensure => purged,
	}
	package {"bsd-mailx":
		ensure => purged,
	}
	package {"mutt":
		ensure => purged,
	}
	package {["exim4-base","exim4-config"]:
		ensure => purged,
	}
}

class nautilus {
	require apt
	package {"nautilus-open-terminal":
        	ensure => installed,
    	}
}

class brasero {
    package { ["brasero", "brasero-nautilus"]:
        ensure => $cdrom_present ? {
            'true' => installed,
            default => purged,
        }
    }
}

class masterpdfeditor {
    	require apt
    	package {"master-pdf-editor":
    		ensure => installed,
    	}
}

class chat {
	require apt
	package {"empathy-common":
		ensure => purged,
	}
	package {"polari":
		ensure => purged,
	}
 }

class remove {
	require apt
	package {"gnome-orca":
		ensure => purged,
	}
	package {"transmission-common":
		ensure => purged,
	}
	package {"hamster-applet":
		ensure => purged,
	}
	package {"synaptic":
		ensure => purged,
	}
	package {"vinagre":
		ensure => purged,
	}
	package {"vino":
		ensure => purged,
	}
	package {"bijiben":
		ensure => purged,
	}
	package {"yelp":
		ensure => purged,
	}
}
