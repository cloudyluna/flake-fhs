{
  description = ''
    A nix flake for setting up Linux's File Hierarchy System (FHS) environment.
    This enables user to download a pre-compiled executables, compiled from other
    Linux systems and run them as if they were natively produced on here.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fhs = pkgs.buildFHSEnv {
          name = "flake-fhs";
          targetPkgs = (
            let
              XPackages = with pkgs.xorg; [
                libX11
                libXcursor
                libXcomposite
                libXdamage
                libXScrnSaver
                libXxf86vm
                libXext
                libXfixes
                libXrandr
                libXrender
                libxcb
                libXinerama
                libXi
              ];
              commonPackages = with pkgs; [
                cmake
                automake
                autoconf
                gnumake
                pkg-config
                wayland
                openssl
                clang
                lldb
                valgrind
                libxkbcommon
                libdrm
                dbus
                gmp
                nss
                libpng
                zlib
                SDL
                SDL_gfx
                SDL_image
                SDL_mixer
                SDL_ttf
                SDL2
                SDL2_image
                SDL2_mixer
                SDL2_ttf
                libGL
                libGLU
              ];
            in
            pkgs': XPackages ++ commonPackages
          );

          multiPkgs =
            pkgs':
            (with pkgs; [
              udev
              alsa-lib
            ]);

          runScript = "bash";
        };

      in
      {
        devShells.default = fhs.env;
        packages.default = fhs;
      }
    );
}
