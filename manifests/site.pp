node default {
    include cronpuppet
    include install
    include remove
    include repository
    include libreoffice
    include synology
    include firefox
    include config
    #include icedove
}

exec { "apt-update":
    command => "/usr/bin/apt-get update"
}

Exec["apt-update"] -> Package <| |>

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
	file {"/usr/share/applications/pdfstudio11.desktop":
		owner   => root,
		group   => root,
		mode    => '755',
		source  => "/opt/pdfstudio11/pdfstudio11.desktop",
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
		require => Package['plymouth'],
	}
	exec {"modify_grub":
		command => "/bin/sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/g' /etc/default/grub; /usr/sbin/update-grub",
		onlyif  => "/bin/grep -v splash /etc/default/grub",
		require => Exec["set_default_theme"],
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
	}
	#package {"plymouth-x11":
	#	ensure => installed,
	#}
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
		else {
			$firmware_packages = ['firmware-linux-free','firmware-misc-nonfree','firmware-linux-nonfree']
		}
	}
	package {$firmware_packages:
		ensure => installed,
	}
}

class remove {
	exec {"/bin/bash /etc/puppet/manifests/files/gnome-dependencies":
		require => Package['aptitude'],
		onlyif  => 'test `/usr/bin/dpkg -l | /bin/grep gnome-core`'
	}
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
