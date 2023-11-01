# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "JosefonNix"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  
  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps";
  
  environment.pathsToLink = ["/libexec"]; # links /libexec from derivations to /run/current-system/sw

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };
    
    displayManager = {
      defaultSession = "none+i3";
      sessionCommands = ''
	xcape -e 'Control_L=Escape'
	'';
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ 
        dmenu
        i3status
        i3lock
	i3lock-color
	xorg.xdpyinfo
	dunst
        betterlockscreen
        i3blocks
      ];
    };
   };
  

  # Capslock as Control + Escape everywhere
  /*
  services.interception-tools = let
	  dfkConfig = pkgs.writeText "dual-function-keys.yaml" ''
	  MAPPINGS:
	  - KEY: KEY_CAPSLOCK
	  TAP: KEY_ESC
	  HOLD: KEY_LEFTCTRL
	  '';
  in {
	  enable = true;
	  plugins = lib.mkForce [
		  pkgs.interception-tools-plugins.dual-function-keys
	  ];
	  udevmonConfig = ''
		  - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c ${dfkConfig} | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
		  DEVICE:
                    NAME: "Kinesis Advantage2 Keyboard"
		    EVENTS:
	              EV_KEY: [[KEY_CAPSLOCK, KEY_ESC, KEY_LEFTCTRL]]
	  '';
  };
  */


  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
    hardware = {
        pulseaudio = {
                enable = true;
                # Enable extra bluetooth codecs
                package = pkgs.pulseaudioFull;
                # Automatically switch audio to connected bluetooth device when it connects
                extraConfig = "
                        load-module module-switch-on-connect
                ";
        };
        bluetooth = {
                # Enable support for bluetooth
                enable = true;
                # Powers up the default bluetooth controller on boot
                powerOnBoot = true;
                # Modern headsets will generally try to connect using the A2DP profile, enables it
                settings.General.Enable = "Source,Sink,Media,Socket";
        };
    };
  # hardware.enableAllFirmware = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.josef = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager"]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      brave
      discord
      tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    neovim
    wget
    nerdfonts
    alacritty
    xcape bat picom
    # interception-tools
    zsh
    oh-my-zsh
    eww
    zip unzip git gnumake gcc htop gdb file xsel feh
    man-pages
    man-pages-posix
    bluezFull
    blueberry
    bluez-tools
    pavucontrol
    imagemagick
    flameshot
    sshfs
    krb5
# -- lsp packages
    llvmPackages_rocm.clang-unwrapped
    llvmPackages_rocm.clang-tools-extra
    pkgs.nodePackages_latest.pyright
    pkgs.nodePackages_latest.yaml-language-server
    pkgs.lua-language-server
    lua nodejs_20 rustc rustup rustfmt rust-analyzer
    bear
  ];

  #extra documentation from added libs
  documentation.dev.enable = true;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      nerdfonts
    ];
  };

  programs = {
    zsh = {
	    enable = true;
	    enableCompletion = true;
	    ohMyZsh = {
		enable = true;
		plugins = [ "git" "python" "man" ];
		theme = "gallois";
	    };
    };
    direnv.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

