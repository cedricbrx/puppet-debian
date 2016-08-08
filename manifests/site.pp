node default { 
    include apt
    include cronpuppet
    include install
    include remove
    include repository
    include libreoffice
    include synology
    include firefox
    include config
    include plymouth
    include gnome_dependencies
    include pdfstudio
    #include icedove
}

class apt{
	require repository
	exec { "apt-update":
		command => "/usr/bin/apt-get update",
	}
}

#case $::hostname {
#	mars05: {
#		$main_user='anne04'
#	}
#	default: {
#		$main_user='brand10'
#	}
#}


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
#	file {"/etc/dconf/profile":
#		owner   => root,
#		group   => root,
#		ensure  => directory,
#		require => File["/etc/dconf"],
#	}
#	file {"/etc/dconf/db":
#		owner   => root,
#		group   => root,
#		ensure  => directory,
#		require => File["/etc/dconf"],
#	}
#	file {"/etc/dconf/db/site.d":
#		owner   => root,
#		group   => root,
#		ensure  => directory,
#		recurse => true,
#		source  => "/etc/puppet/manifests/files/etc/dconf/db/site.d/",
#		require => File["/etc/dconf/db"],
#	}
#	file {"/etc/dconf/profile/user":
#		owner   => root,
#		group   => root,
#		mode    => '644',
#		source  => "/etc/puppet/manifests/files/etc/dconf/profile/user",
#		require => File["/etc/dconf/profile"],
#	}
}

class pdfstudio {
	file {"/usr/share/applications/pdfstudio11.desktop":
		owner   => root,
		group   => root,
		mode    => '755',
		source  => "/opt/pdfstudio11/pdfstudio11.desktop",
		require => Package['pdfstudio'],
	}
	$languages = ["deu", "fra", "eng", "spa"]
	$languages.each |String $languages| {
		exec {"/usr/bin/wget -qO- http://download.qoppa.com/ocr/tess302/tesseract-ocr-3.02.$languages.tar.gz | /bin/tar xvz -C /opt/pdfstudio11/lib/tess/tessdata":
			require => Package['pdfstudio'],
			unless  => "/usr/bin/find /opt/pdfstudio11/lib/tess/tessdata/tesseract-ocr/tessdata -iname $languages.traineddata",
		}
	}
	file {"/opt/pdfstudio11/lib/tess/tessdata/tesseract-ocr/tessdata/languages11.xml":
		source => "http://download.qoppa.com/pdfstudio/ocr/languages11.xml"
	}
}

class firefox {
	file {"/etc/firefox-esr/firefox_brandenbourger.js":
		owner  => root,
		group  => root,
		mode   => '644',
		source => "/etc/puppet/manifests/files/etc/firefox-esr/firefox_brandenbourger.js",
	}
}

class icedove {
	file {"/etc/icedove/pref/icedove_brandenbourger.js":
		owner  => root,
		group  => root,
		mode   => '644',
		source => "/etc/puppet/manifests/files/etc/icedove/pref/icedove_brandenbourger.js",
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
	require repository
	package {"aptitude":
        	ensure => installed,
	}
	package {"git":
        	ensure => installed,
	}
	package {"icedove":
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
	package {"ttf-mscorefonts-installer":
		responsefile => "/var/cache/debconf/mscorefonts.seeds",
		ensure       => installed,
		require      => File["/var/cache/debconf/mscorefonts.seeds"],
	}
	package {"plymouth-x11":
		ensure => installed,
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
	#exec {"/bin/bash /etc/puppet/manifests/files/gnome-dependencies":
	#	require => Package['aptitude'],
	#	onlyif  => '/usr/bin/test `/usr/bin/dpkg -l | /bin/grep gnome-core`'
	#}
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
