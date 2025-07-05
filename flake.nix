{
  description = ''
    A nix flake for setting up Linux's File Hierarchy System (FHS) environment.
    This enables user to download a pre-compiled executables, compiled from other
    Linux systems and run them as if they were natively produced on here.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # We use this git rev (24.04 is because ncurses is not yet in the cache.nixos.org
    # So we use this old package set to prevent user from building anything manually,
    # if possible.
    nixpkgs-2404.url = "github:NixOS/nixpkgs/78d9f40fd6941a1543ffc3ed358e19c69961d3c1";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-2404,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nixpkgs2404 = nixpkgs-2404.legacyPackages.${system};
        fhs = pkgs.buildFHSEnv {
          name = "flake-fhs";
          targetPkgs = (
            let
              xPackages = with pkgs.xorg; [
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

              sdlPackages = with pkgs; [
                SDL
                SDL_gfx
                SDL_image
                SDL_mixer
                SDL_ttf
                SDL2
                SDL2_image
                SDL2_mixer
              ];

              commonPackages = with pkgs; [
                cmake
                automake
                autoconf
                gnumake
                pkg-config
                wayland
                openssl
                nixpkgs2404.libtinfo
                nixpkgs2404.ncurses
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
                libGL
                libGLU
              ];
            in
            pkgs': xPackages ++ commonPackages ++ sdlPackages
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
