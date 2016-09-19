node default { 
    include apt
    include cronpuppet
    include install
    include remove
    include repository
    include libreoffice
    include synology
    #include firefox
    include config
    include plymouth
    include gnome_dependencies
    include pdfstudio
    #include thunderbird
}

class apt {
	require repository
	exec { "apt-update":
		command => "/usr/bin/apt-get update",
	}
	file {"/etc/apt/apt.conf.d/99brandenbourger":
		owner  => root,
		group  => root,
		mode   => '644',
		source => "/etc/puppet/manifests/files/etc/apt/apt.conf.d/99brandenbourger",
	}
	exec {"correct_hunspell_dependency":
		command => "/bin/grep thunderbird /var/lib/dpkg/status | /bin/grep Conflicts | /bin/sed -i 's/thunderbird/thunderbird (<< 2.0.0.3-2)/g'"
	}
}

class config {
	file {"/etc/papersize":
		owner   => root,
		group   => root,
		mode    => '644',
		content => "a4\n",
	}
	file {"/etc/cron.daily/update-flashplugins":
		owner  => root,
		group  => root,
		mode   => '755',
		source => "/etc/puppet/manifests/files/etc/cron.daily/update-flashplugins",
	}
	file {"/etc/dconf":
		owner   => root,
		group   => root,
		ensure  => directory,
		recurse => true,
		source  => "/etc/puppet/manifests/files/etc/dconf/",
	}
}

class pdfstudio {
	file {"/usr/share/applications/pdfstudio11.desktop":
		owner   => root,
		group   => root,
		mode    => '644',
		source  => "/opt/pdfstudio11/pdfstudio11.desktop",
		require => Package['pdfstudio'],
	}
	$languages = ["deu", "fra", "eng", "spa"]
	$languages.each |String $languages| {
		exec {"/usr/bin/curl http://download.qoppa.com/ocr/tess302/tesseract-ocr-3.02.$languages.tar.gz | /bin/tar xvz -C /opt/pdfstudio11/lib/tess":
			require => Package['pdfstudio','curl'],
			unless  => "/usr/bin/test -e /opt/pdfstudio11/lib/tess/tesseract-ocr/tessdata/$languages.traineddata",
		}
	}
	file {"/opt/pdfstudio11/.pdfstudio":
		owner   => root,
		group   => root,
		mode    => '644',
		source  => "/etc/puppet/manifests/files/opt/pdfstudio11/pdfstudio.key",
		require => Package['pdfstudio'],
	}
	file { ["/home/$installed_user/.pdfstudio11/", "/home/$installed_user/.pdfstudio11/tess/"]:
		owner  => $installed_user,
		group  => $installed_user,
		mode   => '755',
		ensure => directory,
	}
	file{"/home/$installed_user/.pdfstudio11/tess/tessdata":
		owner   => $installed_user,
		group   => $installed_user,
		mode    => '644',
		ensure  => link,
		require => File["/home/$installed_user/.pdfstudio11/", "/home/$installed_user/.pdfstudio11/tess/"],
		target  => "/opt/pdfstudio11/lib/tess/tesseract-ocr/tessdata/",
	}
	file {"/opt/pdfstudio11/lib/tess/tesseract-ocr/tessdata/languages11.xml":
		source  => "http://download.qoppa.com/pdfstudio/ocr/languages11.xml",
		require => Package['pdfstudio'],
	}
}

class firefox {
	file {"/etc/firefox-esr/firefox_brandenbourger.js":
		owner  => root,
		group  => root,
		mode   => '644',
		source => "/etc/puppet/manifests/files/etc/firefox-esr/firefox_brandenbourger.js",
	}
	file {"/usr/lib/firefox-esr/firefox_brandenbourger.cfg":
		owner  => root,
		group  => root,
		mode   => '644',
		source => "/etc/puppet/manifests/files/usr/lib/firefox-esr/firefox_brandenbourger.cfg",
	}
}

class thunderbird {
	file {"/etc/icedove/pref/icedove_brandenbourger.js":
		owner   => root,
		group   => root,
		mode    => '644',
		source  => "/etc/puppet/manifests/files/etc/icedove/icedove_brandenbourger.js",
		require => Package["icedove"],
	}
	file {"/usr/lib/icedove/icedove_brandenbourger.cfg":
		owner   => root,
		group   => root,
		mode    => '644',
		source  => "/etc/puppet/manifests/files/usr/lib/icedove/icedove_brandenbourger.cfg",
		require => Package["icedove"],
	}
	file {"/usr/lib/thunderbird/extensions/{3550f703-e582-4d05-9a08-453d09bdfdc6}/provide_for_google_calendar-3.1-sm+tb.xpi":
		owner   => root,
		group   => root,
		mode    => '644',
		source  => "https://addons.mozilla.org/thunderbird/downloads/latest/provider-for-google-calendar/addon-4631-latest.xpi",
		require => Exec["download_and_extract_thunderbird"],
	}
}

class plymouth {
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
	if $graphic_chipset == 'gk106' {
		file {"/etc/initramfs-tools/hooks/nvidia/":
			owner   => root,
			group   => root,
			mode    => '755',
			source  => "/etc/puppet/manifests/files/etc/initramfs-tools/hooks/nvidia/",
			before  => Exec["set_default_theme"],
		}
	}
}

class repository {
	file {"/etc/apt/trusted.gpg.d/":
		path    => "/etc/apt/trusted.gpg.d",
		ensure  => directory,
		owner   => root,
		group   => root,
		mode    => '644',
		source  => "/etc/puppet/manifests/files/etc/apt/trusted.gpg.d",
		recurse => true,
	}
	file {	"/etc/apt/sources.list":
		owner   => root,
		group   => root,
		mode    => '644',
		source  => "/etc/puppet/manifests/files/etc/apt/sources.list",
	}
	file {"/etc/apt/sources.list.d/":
		ensure  => directory,
		owner   => root,
		group   => root,
		mode    => '644',
		purge   => true,
		source  => "/etc/puppet/manifests/files/etc/apt/sources.list.d",
		recurse => true,
	}
	file {"/var/cache/debconf/mscorefonts.seeds":
		source => "/etc/puppet/manifests/files/var/cache/debconf/mscorefonts.seeds",
		owner  => root,
		group  => root,
		mode   => '644',
	}
}

class libreoffice {
	file {"/usr/lib/libreoffice/share/registry/brandenbourger.xcd":
		owner  => root,
		group  => root,
		mode   => '644',
		source => "/etc/puppet/manifests/files/usr/lib/libreoffice/share/registry/brandenbourger.xcd",
	}
}

class synology {
	file {"/usr/share/icons/hicolor/64x64/apps/":
		ensure  => directory,
		source  => "/etc/puppet/manifests/files/usr/share/icons/hicolor/64x64/apps",
		owner   => root,
		group   => root,
		mode    => '644',
		recurse => 'true',
	}
	file {"/usr/share/applications/":
		ensure  => directory,
		source  => "/etc/puppet/manifests/files/usr/share/applications",
		owner   => root,
		group   => root,
		mode    => '644',
		recurse => 'true',
	}
}

class install {
	require apt
	package {"aptitude":
        	ensure => installed,
	}
	package {"git":
        	ensure => installed,
	}
	package {"thunderbird-mozilla-build":
        	ensure => installed,
	}
	package {"pyrenamer":
		ensure => installed,
	}
	package {"handbrake":
		ensure => installed,
	}
	package {"keepassx":
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
	package {"dconf-editor":
		ensure => installed,
	}
	package {"pdfstudio":
		ensure => installed,
	}
	package {"mlocate":
		ensure => installed,
	}
	package {"vim":
		ensure => installed,
	}
	package {"shotwell":
		ensure => installed,	
	}
	package {"browser-plugin-freshplayer-pepperflash":
		ensure => installed,	
	}
	package {"youtube-dl":
		ensure => installed,		
	}
	package {"libreoffice-gtk3":
        	ensure => installed,
	}
	package {"hfsprogs":
		ensure => installed,
	}
	package {"ttf-mscorefonts-installer":
		responsefile => "/var/cache/debconf/mscorefonts.seeds",
		ensure       => installed,
		require      => File["/var/cache/debconf/mscorefonts.seeds"],
	}
	package {"plymouth-x11":
		ensure => installe,
	}
	package {"curl":
		ensure => installed,
	}
	if $network_vendor == 'realtek' {
		if $wireless_vendor == 'intel' {
			$firmware_packages = ['firmware-iwlwifi','firmware-realtek','firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
		}
		else {
			$firmware_packages = ['firmware-realtek','firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
		}
	}	
	elsif $network_vendor == 'intel' {
		if $wireless_vendor == 'realtek' {
			$firmware_packages = ['firmware-realtek','firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
		}
		elsif $wireless_vendor == 'intel' {
			$firmware_packages = ['firmware-iwlwifi','firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
		}
	}
	else {
		$firmware_packages = ['firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
	}
	package {$firmware_packages:
		ensure => installed,
	}
	if $network_r8168 {
		package {"dkms":
			ensure => installed,
		}
		package {"r8168":
			ensure  => installed,
			name => "r8168-dkms",
			source  => "/etc/puppet/manifests/files/r8168-dkms_8.042.00-1_all.deb",
			require => Package["dkms"],
		}
	}
}

class gnome_dependencies {
	$gd = ["gnome", "gnome-core", "gnome-desktop-environment"]
	$gd.each |String $gd| {
		exec {"/usr/bin/aptitude unmarkauto '?reverse-depends($gd) | ?reverse-recommends($gd)'":
			require => Package['aptitude'],
			onlyif  => '/usr/bin/test `/usr/bin/dpkg -l | /bin/grep $gd`'
		}
	}
}

class remove {
	require gnome_dependencies
	package {"inkscape":
		ensure => purged,
	}
	package {"gnome-orca":
		ensure => purged,
	}
	package {"gnome-games":
		ensure => purged,
	}
	package {"transmission-common":
		ensure => purged,
	}
	package {"aisleriot":
		ensure => purged,
	}
	package {"hamster-applet":
		ensure => purged,
	}
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
	package {"goobox":
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
	package {"gnome-shell-extension-weather":
		ensure => purged,
	}
	package {"synaptic":
		ensure => purged,
	}
	package {"swell-foop":
		ensure => purged,
	}
	package {"quadrapassel":
		ensure => purged,
	}
	package {"lightsoff":
		ensure => purged,
	}
	package {"iagno":
		ensure => purged,
	}
	package {"hitori":
		ensure => purged,
	}
	package {"gnome-taquin":
		ensure => purged,
	}
	package {"gnome-sudoku":
		ensure => purged,
	}
	package {"gnome-robots":
		ensure => purged,
	}
	package {"gnome-nibbles":
		ensure => purged,
	}
	package {"gnome-mines":
		ensure => purged,
	}
	package {"gnome-klotski":
		ensure => purged,
	}
	package {"five-or-more":
		ensure => purged,
	}
	package {"vinagre":
		ensure => purged,
	}
	package {"vino":
		ensure => purged,
	}
	package {"tali":
		ensure => purged,
	}
	package {["xboard","fairymax","hoichess"]:
		ensure => purged,
	}
	package {"bijiben":
		ensure => purged,
	}
	package {"tracker":
		ensure => purged,
	}
	package {"empathy-common":
		ensure => purged,
	}
	package {"gnome-maps":
		ensure => purged,
	}
	package {"mpv":
		ensure => purged,
	}
	package {"polari":
		ensure => purged,
	}
	package {"gnome-nettool":
		ensure => purged,
	}
	package {"rhythmbox-data":
		ensure => purged,
	}
	package {"gnome-dictionary":
		ensure => purged,
	}
	package {"eog":
		ensure => purged,
	}
	package {"gnome-packagekit":
		ensure => purged,
	}
	package {"gnome-sound-recorder":
		ensure => purged,
	}
	package {"icedove":
		ensure => purged,
	}
}

class cronpuppet {
    file { 'post-hook':
        ensure  => file,
        path    => '/etc/puppet/.git/hooks/post-merge',
        source  => '/etc/puppet/manifests/files/post-merge',
        mode    => '0755',
        owner   => root,
        group   => root,
    }
    cron { 'puppet-apply':
        ensure  => present,
        command => "cd /etc/puppet ; /usr/bin/git pull",
        user    => root,
        minute  => '*/30',
        require => File['post-hook'],
    }
}
